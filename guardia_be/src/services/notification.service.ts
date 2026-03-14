import { prisma } from "../config/database";
import { NotFoundError } from "../utils/errors";
import type { ListNotificationsInput } from "../validators/notification.validator";

export class NotificationService {
  async list(userId: string, options: ListNotificationsInput = {}) {
    const { limit = 20, offset = 0, unread_only = false } = options;
    const limitNum = Number(limit) || 20;
    const offsetNum = Number(offset) || 0;

    const where: {
      recipient_user_id: string;
      is_sent?: boolean;
    } = {
      recipient_user_id: userId,
    };

    if (unread_only) {
      where.is_sent = false;
    }

    const [notifications, total] = await Promise.all([
      prisma.notification.findMany({
        where,
        orderBy: { created_at: "desc" },
        take: limitNum,
        skip: offsetNum,
        select: {
          id: true,
          notification_type: true,
          title: true,
          body: true,
          is_sent: true,
          sent_at: true,
          created_at: true,
          related_journey_id: true,
          related_report_id: true,
        },
      }),
      prisma.notification.count({ where }),
    ]);

    return {
      notifications,
      pagination: {
        total,
        limit: limitNum,
        offset: offsetNum,
        has_more: offsetNum + notifications.length < total,
      },
    };
  }

  async markAsRead(userId: string, notificationId: string) {
    const notification = await prisma.notification.findFirst({
      where: { id: notificationId, recipient_user_id: userId },
    });

    if (!notification) {
      throw new NotFoundError("Notification not found");
    }

    await prisma.notification.update({
      where: { id: notificationId },
      data: { is_sent: true, sent_at: new Date() },
    });

    return { success: true };
  }

  async markAllAsRead(userId: string) {
    const result = await prisma.notification.updateMany({
      where: { recipient_user_id: userId, is_sent: false },
      data: { is_sent: true, sent_at: new Date() },
    });

    return { marked_count: result.count };
  }

  async getUnreadCount(userId: string) {
    const count = await prisma.notification.count({
      where: { recipient_user_id: userId, is_sent: false },
    });

    return { unread_count: count };
  }
}
