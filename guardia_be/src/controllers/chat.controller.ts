import { Response } from "express";
import { ChatService } from "../services/chat.service";
import { asyncHandler } from "../utils/async-handler";
import { sendSuccess } from "../utils/response";
import type { AuthenticatedRequest } from "../middlewares/auth.middleware";

const chatService = new ChatService();

export class ChatController {
  history = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
    const result = await chatService.getConversation(req.uid!, req.query as any);
    sendSuccess(res, result, "Chat history retrieved successfully");
  });
}
