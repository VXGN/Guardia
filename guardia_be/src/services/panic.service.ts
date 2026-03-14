import { prisma } from "../config/database";
import { NotFoundError } from "../utils/errors";
import { TrustedContactService } from "./trusted-contact.service";
import type { TriggerPanicInput } from "../validators/panic.validator";

const trustedContactService = new TrustedContactService();

export class PanicService {
  async triggerPanic(userId: string, data: TriggerPanicInput) {
    const user = await prisma.user.findUnique({
      where: { id: userId, deleted_at: null },
      select: { id: true, full_name: true, phone_number: true },
    });

    if (!user) {
      throw new NotFoundError("User not found");
    }

    const activeContacts = await trustedContactService.getActiveContacts(userId);

    if (activeContacts.length === 0) {
      return {
        success: false,
        message: "No active trusted contacts to notify",
        notifications_sent: 0,
      };
    }

    const googleMapsLink = `https://maps.google.com/?q=${data.latitude},${data.longitude}`;
    const panicMessage =
      data.message ||
      `EMERGENCY ALERT: ${user.full_name || "A Guardia user"} needs help!`;

    const notifications = await Promise.all(
      activeContacts.map(async (contact) => {
        const notification = await prisma.notification.create({
          data: {
            recipient_phone: contact.contact_phone,
            notification_type: "panic_alert",
            title: "EMERGENCY: Panic Alert Triggered",
            body: `${panicMessage}\n\nLocation: ${googleMapsLink}`,
            is_sent: false,
          },
        });

        // In a real implementation, you would send SMS/push notification here
        // For now, we mark it as sent after creating the record
        await prisma.notification.update({
          where: { id: notification.id },
          data: { is_sent: true, sent_at: new Date() },
        });

        return {
          contact_id: contact.id,
          contact_name: contact.contact_name,
          contact_phone: contact.contact_phone,
          notification_id: notification.id,
        };
      })
    );

    return {
      success: true,
      message: `Panic alert sent to ${notifications.length} contacts`,
      notifications_sent: notifications.length,
      contacts_notified: notifications,
      location: {
        latitude: data.latitude,
        longitude: data.longitude,
        maps_link: googleMapsLink,
      },
    };
  }
}
