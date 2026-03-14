import { Response } from "express";
import { NotificationService } from "../services/notification.service";
import { sendSuccess } from "../utils/response";
import { asyncHandler } from "../utils/async-handler";
import type { AuthenticatedRequest } from "../middlewares/auth.middleware";

const notificationService = new NotificationService();

export class NotificationController {
  list = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
    const result = await notificationService.list(req.uid!, req.query as any);
    sendSuccess(res, result, "Notifications retrieved successfully");
  });

  markAsRead = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
    const { id } = req.params;
    const result = await notificationService.markAsRead(req.uid!, id);
    sendSuccess(res, result, "Notification marked as read");
  });

  markAllAsRead = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
    const result = await notificationService.markAllAsRead(req.uid!);
    sendSuccess(res, result, "All notifications marked as read");
  });

  getUnreadCount = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
    const result = await notificationService.getUnreadCount(req.uid!);
    sendSuccess(res, result, "Unread count retrieved successfully");
  });
}
