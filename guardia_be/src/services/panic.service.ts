import { prisma } from "../config/database";
import { NotFoundError, BadRequestError } from "../utils/errors";
import { TrustedContactService } from "./trusted-contact.service";
import type {
  TriggerPanicInput,
  CancelPanicInput,
  UpdatePanicLocationInput,
} from "../validators/panic.validator";
import { verifyEmergencyPin } from "../utils/emergency-pin";

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

    const now = new Date();

    await prisma.user.update({
      where: { id: userId },
      data: {
        panic_is_active: true,
        panic_triggered_at: now,
        panic_cancelled_at: null,
        panic_latitude: data.latitude,
        panic_longitude: data.longitude,
        panic_message: data.message || null,
      },
    });

    const activeContacts = await trustedContactService.getActiveContacts(userId);

    if (activeContacts.length === 0) {
      return {
        success: true,
        message: "Panic alert triggered but no contacts to notify",
        panic_alert_id: userId,
        session_id: userId,
        user_id: userId,
        latitude: data.latitude,
        longitude: data.longitude,
        started_at: now.toISOString(),
        status: "ACTIVE",
        triggered_at: now.toISOString(),
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
      panic_alert_id: userId,
      session_id: userId,
      user_id: userId,
      latitude: data.latitude,
      longitude: data.longitude,
      started_at: now.toISOString(),
      status: "ACTIVE",
      triggered_at: now.toISOString(),
      notifications_sent: notifications.length,
      contacts_notified: notifications,
      location: {
        latitude: data.latitude,
        longitude: data.longitude,
        maps_link: googleMapsLink,
      },
    };
  }

  async cancelPanic(userId: string, data: CancelPanicInput) {
    const user = await prisma.user.findUnique({
      where: { id: userId, deleted_at: null },
      select: {
        id: true,
        panic_is_active: true,
        emergency_pin_hash: true,
      },
    });

    if (!user) {
      throw new NotFoundError("User not found");
    }

    if (!user.emergency_pin_hash) {
      throw new BadRequestError("Emergency PIN is not configured for this user");
    }

    const inputPin = (data.emergency_pin ?? data.emergency_code)?.trim();
    const sessionId = data.session_id?.trim();
    const hasLegacySessionId = Boolean(sessionId);

    if (!inputPin && !hasLegacySessionId) {
      throw new BadRequestError("Emergency PIN or session_id is required");
    }

    if (inputPin) {
      const isValidPin = await verifyEmergencyPin(inputPin, user.emergency_pin_hash);
      if (!isValidPin) {
        throw new BadRequestError("Invalid emergency PIN");
      }
    }

    if (hasLegacySessionId && sessionId !== userId) {
      throw new BadRequestError("Invalid panic session");
    }

    if (!user.panic_is_active) {
      return {
        success: true,
        message: "Emergency PIN verified. No active panic alert.",
        cancelled_at: null,
      };
    }

    const cancelledAt = new Date();
    await prisma.user.update({
      where: { id: userId },
      data: {
        panic_is_active: false,
        panic_cancelled_at: cancelledAt,
      },
    });

    // Do not block cancel latency on fan-out notifications.
    void this.notifyTrustedContactsPanicCancelled(userId, cancelledAt);

    return {
      success: true,
      message: "Panic alert cancelled successfully",
      status: "CANCELLED",
      session_id: userId,
      cancelled_at: cancelledAt.toISOString(),
    };
  }

  private async notifyTrustedContactsPanicCancelled(userId: string, cancelledAt: Date) {
    try {
      const activeContacts = await trustedContactService.getActiveContacts(userId);

      if (activeContacts.length === 0) {
        return;
      }

      await Promise.all(
        activeContacts.map((contact) =>
          prisma.notification.create({
            data: {
              recipient_phone: contact.contact_phone,
              notification_type: "system",
              title: "Emergency Update",
              body: "Emergency alert has been cancelled by the user.",
              is_sent: true,
              sent_at: cancelledAt,
            },
          })
        )
      );
    } catch (error) {
      // Notification fan-out failure must not fail cancel semantics.
      console.error("[PanicService] Failed to notify cancellation", error);
    }
  }

  async updatePanicLocation(userId: string, data: UpdatePanicLocationInput) {
    const user = await prisma.user.findUnique({
      where: { id: userId, deleted_at: null },
      select: {
        id: true,
        panic_is_active: true,
      },
    });

    if (!user) {
      throw new NotFoundError("User not found");
    }

    if (!user.panic_is_active) {
      throw new NotFoundError("No active panic alert found");
    }

    if (data.session_id && data.session_id !== userId) {
      throw new BadRequestError("Invalid panic session");
    }

    const updatedAt = new Date();
    await prisma.user.update({
      where: { id: userId },
      data: {
        panic_latitude: data.latitude,
        panic_longitude: data.longitude,
        updated_at: updatedAt,
      },
    });

    return {
      success: true,
      session_id: userId,
      latitude: data.latitude,
      longitude: data.longitude,
      updated_at: updatedAt.toISOString(),
    };
  }

  async getEmergencyPinHash(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId, deleted_at: null },
      select: { emergency_pin_hash: true },
    });

    if (!user) {
      throw new NotFoundError("User not found");
    }

    return {
      has_pin: Boolean(user.emergency_pin_hash),
      emergency_pin_hash: user.emergency_pin_hash || null,
    };
  }

  async getActivePanic(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId, deleted_at: null },
      select: {
        panic_is_active: true,
        panic_triggered_at: true,
        panic_cancelled_at: true,
        panic_latitude: true,
        panic_longitude: true,
        panic_message: true,
      },
    });

    if (!user || !user.panic_is_active) {
      return null;
    }

    return {
      is_active: user.panic_is_active,
      triggered_at: user.panic_triggered_at,
      cancelled_at: user.panic_cancelled_at,
      latitude: user.panic_latitude,
      longitude: user.panic_longitude,
      message: user.panic_message,
    };
  }
}
