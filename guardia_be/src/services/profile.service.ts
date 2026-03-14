import { prisma } from "../config/database";
import { NotFoundError } from "../utils/errors";
import type { UpdateProfileInput } from "../validators/profile.validator";

export class ProfileService {
  async getProfile(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId, deleted_at: null },
      select: {
        id: true,
        full_name: true,
        email: true,
        phone_number: true,
        role: true,
        is_anonymous_mode: true,
        is_verified: true,
        created_at: true,
        updated_at: true,
      },
    });

    if (!user) {
      throw new NotFoundError("User not found");
    }

    return user;
  }

  async updateProfile(userId: string, data: UpdateProfileInput) {
    const user = await prisma.user.findUnique({
      where: { id: userId, deleted_at: null },
    });

    if (!user) {
      throw new NotFoundError("User not found");
    }

    const updated = await prisma.user.update({
      where: { id: userId },
      data: {
        full_name: data.full_name,
        phone_number: data.phone_number,
        is_anonymous_mode: data.is_anonymous_mode,
        fcm_token: data.fcm_token,
        updated_at: new Date(),
      },
      select: {
        id: true,
        full_name: true,
        email: true,
        phone_number: true,
        role: true,
        is_anonymous_mode: true,
        is_verified: true,
        created_at: true,
        updated_at: true,
      },
    });

    return updated;
  }
}
