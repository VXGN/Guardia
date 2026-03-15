import { prisma } from "../config/database";
import { NotFoundError, ForbiddenError } from "../utils/errors";
import type {
  CreateTrustedContactInput,
  UpdateTrustedContactInput,
} from "../validators/trusted-contact.validator";

export class TrustedContactService {
  async list(userId: string) {
    const contacts = await prisma.trustedContact.findMany({
      where: { user_id: userId },
      orderBy: { created_at: "desc" },
      select: {
        id: true,
        contact_name: true,
        contact_phone: true,
        contact_email: true,
        is_active: true,
        created_at: true,
        updated_at: true,
      },
    });

    return contacts;
  }

  async create(userId: string, data: CreateTrustedContactInput) {
    const contact = await prisma.trustedContact.create({
      data: {
        user_id: userId,
        contact_name: data.contact_name,
        contact_phone: data.contact_phone,
        contact_email: data.contact_email,
      },
      select: {
        id: true,
        contact_name: true,
        contact_phone: true,
        contact_email: true,
        is_active: true,
        created_at: true,
        updated_at: true,
      },
    });

    return contact;
  }

  async update(userId: string, contactId: string, data: UpdateTrustedContactInput) {
    const updateResult = await prisma.trustedContact.updateMany({
      where: {
        id: contactId,
        user_id: userId,
      },
      data: {
        contact_name: data.contact_name,
        contact_phone: data.contact_phone,
        contact_email: data.contact_email,
        is_active: data.is_active,
        updated_at: new Date(),
      },
    });

    if (updateResult.count === 0) {
      const existing = await prisma.trustedContact.findUnique({
        where: { id: contactId },
        select: { id: true },
      });

      if (!existing) {
        throw new NotFoundError("Trusted contact not found");
      }

      throw new ForbiddenError("You do not own this contact");
    }

    const updated = await prisma.trustedContact.findUnique({
      where: { id: contactId },
      select: {
        id: true,
        contact_name: true,
        contact_phone: true,
        contact_email: true,
        is_active: true,
        created_at: true,
        updated_at: true,
      },
    });

    if (!updated) {
      throw new NotFoundError("Trusted contact not found");
    }

    return updated;
  }

  async delete(userId: string, contactId: string) {
    const deleteResult = await prisma.trustedContact.deleteMany({
      where: {
        id: contactId,
        user_id: userId,
      },
    });

    if (deleteResult.count === 0) {
      const existing = await prisma.trustedContact.findUnique({
        where: { id: contactId },
        select: { id: true },
      });

      if (!existing) {
        throw new NotFoundError("Trusted contact not found");
      }

      throw new ForbiddenError("You do not own this contact");
    }
  }

  async getActiveContacts(userId: string) {
    return prisma.trustedContact.findMany({
      where: { user_id: userId, is_active: true },
    });
  }
}
