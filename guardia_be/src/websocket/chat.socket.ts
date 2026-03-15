import { IncomingMessage } from "http";
import { URL } from "url";
import { RawData, WebSocket, WebSocketServer } from "ws";
import type { Server } from "http";
import { firebaseAuth } from "../config/firebase";
import { ChatService } from "../services/chat.service";
import { prisma } from "../config/database";

interface WsEnvelope {
  event: string;
  payload?: any;
}

interface ChatSocket extends WebSocket {
  uid?: string;
}

const chatService = new ChatService();
const activeUsers = new Map<string, Set<ChatSocket>>();

function sendEnvelope(socket: WebSocket, event: string, payload: unknown) {
  if (socket.readyState !== WebSocket.OPEN) {
    return;
  }

  socket.send(JSON.stringify({ event, payload }));
}

function parseAuthFromRequest(request: IncomingMessage) {
  const base = `http://${request.headers.host || "localhost"}`;
  const url = new URL(request.url || "/", base);
  const uid = url.searchParams.get("uid")?.trim();
  const token = url.searchParams.get("token")?.trim();
  return { uid, token };
}

function registerConnection(uid: string, socket: ChatSocket) {
  if (!activeUsers.has(uid)) {
    activeUsers.set(uid, new Set());
  }

  activeUsers.get(uid)!.add(socket);
}

function unregisterConnection(uid: string, socket: ChatSocket) {
  const sockets = activeUsers.get(uid);
  if (!sockets) {
    return;
  }

  sockets.delete(socket);
  if (sockets.size === 0) {
    activeUsers.delete(uid);
  }
}

async function authenticateConnection(request: IncomingMessage): Promise<string | null> {
  const { uid, token } = parseAuthFromRequest(request);
  if (!uid) {
    return null;
  }

  if (token) {
    try {
      const decoded = await firebaseAuth.verifyIdToken(token);
      if (decoded.uid !== uid) {
        return null;
      }
    } catch {
      return null;
    }
  }

  const user = await prisma.user.findUnique({
    where: { id: uid, deleted_at: null },
    select: { id: true },
  });

  if (!user) {
    return null;
  }

  return uid;
}

async function handleSendMessage(socket: ChatSocket, payload: any) {
  const senderUid = payload?.sender_uid;
  const receiverUid = payload?.receiver_uid;
  const message = payload?.message;
  const timestamp = payload?.timestamp;

  if (!socket.uid || socket.uid !== senderUid) {
    sendEnvelope(socket, "error", { message: "Invalid sender uid" });
    return;
  }

  try {
    const saved = await chatService.sendMessage({
      sender_uid: senderUid,
      receiver_uid: receiverUid,
      message,
      timestamp,
    });

    sendEnvelope(socket, "message_sent", saved);

    const receiverSockets = activeUsers.get(receiverUid);
    if (receiverSockets) {
      for (const client of receiverSockets) {
        sendEnvelope(client, "receive_message", saved);
      }
    }
  } catch (error: any) {
    sendEnvelope(socket, "error", { message: error?.message || "Failed to send message" });
  }
}

export function setupChatWebSocket(server: Server) {
  const wss = new WebSocketServer({
    server,
    path: "/ws/chat",
  });

  wss.on("connection", async (socket: ChatSocket, request: IncomingMessage) => {
    const uid = await authenticateConnection(request);
    if (!uid) {
      sendEnvelope(socket, "error", { message: "Unauthorized websocket connection" });
      socket.close(1008, "Unauthorized");
      return;
    }

    socket.uid = uid;
    registerConnection(uid, socket);
    sendEnvelope(socket, "connected", { uid });

    socket.on("message", async (raw: RawData) => {
      try {
        const parsed = JSON.parse(raw.toString()) as WsEnvelope;

        if (parsed.event === "send_message") {
          await handleSendMessage(socket, parsed.payload);
          return;
        }

        sendEnvelope(socket, "error", { message: "Unsupported websocket event" });
      } catch {
        sendEnvelope(socket, "error", { message: "Invalid websocket payload" });
      }
    });

    socket.on("close", () => {
      if (socket.uid) {
        unregisterConnection(socket.uid, socket);
      }
    });

    socket.on("error", () => {
      if (socket.uid) {
        unregisterConnection(socket.uid, socket);
      }
    });
  });

  return wss;
}
