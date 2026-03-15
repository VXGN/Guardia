import { MessageRepository } from "../repositories/message.repository";
import { BadRequestError, ForbiddenError, NotFoundError } from "../utils/errors";
import { prisma } from "../config/database";

interface SendMessageInput {
  sender_uid: string;
  receiver_uid: string;
  message: string;
  timestamp?: string;
}

interface ConversationInput {
  sender_uid: string;
  receiver_uid: string;
}

const messageRepository = new MessageRepository();

export class ChatService {
  async sendMessage(input: SendMessageInput) {
    if (typeof input.sender_uid !== "string" || typeof input.receiver_uid !== "string") {
      throw new BadRequestError("Invalid sender_uid or receiver_uid");
    }

    if (typeof input.message !== "string") {
      throw new BadRequestError("Message must be a string");
    }

    const text = input.message.trim();
    if (!text) {
      throw new BadRequestError("Message cannot be empty");
    }

    const [sender, receiver] = await Promise.all([
      prisma.user.findUnique({ where: { id: input.sender_uid, deleted_at: null }, select: { id: true } }),
      prisma.user.findUnique({ where: { id: input.receiver_uid, deleted_at: null }, select: { id: true } }),
    ]);

    if (!sender) {
      throw new NotFoundError("Sender not found");
    }

    if (!receiver) {
      throw new NotFoundError("Receiver not found");
    }

    const timestamp = input.timestamp ? new Date(input.timestamp) : new Date();
    if (Number.isNaN(timestamp.getTime())) {
      throw new BadRequestError("Invalid timestamp");
    }

    const saved = await messageRepository.create({
      sender_uid: input.sender_uid,
      receiver_uid: input.receiver_uid,
      message: text,
      timestamp,
    });

    return {
      id: saved.id,
      sender_uid: saved.sender_uid,
      receiver_uid: saved.receiver_uid,
      message: saved.message,
      timestamp: saved.timestamp.toISOString(),
    };
  }

  async getConversation(authenticatedUid: string, input: ConversationInput) {
    const senderUid = input.sender_uid;
    const receiverUid = input.receiver_uid;

    if (authenticatedUid !== senderUid && authenticatedUid !== receiverUid) {
      throw new ForbiddenError("You can only access your own conversations");
    }

    const messages = await messageRepository.findConversation({
      userA: senderUid,
      userB: receiverUid,
    });

    return {
      messages: messages.map((item) => ({
        id: item.id,
        sender_uid: item.sender_uid,
        receiver_uid: item.receiver_uid,
        message: item.message,
        timestamp: item.timestamp.toISOString(),
      })),
    };
  }
}
