import { firebaseAuth } from "../config/firebase";
import { prisma } from "../config/database";
import { UnauthorizedError } from "../utils/errors";
import { generateEmergencyPin, hashEmergencyPin } from "../utils/emergency-pin";

interface VerifyResult {
  uid: string;
  email?: string;
  name?: string;
  picture?: string;
}

export class AuthService {
  async verifyToken(token: string): Promise<VerifyResult> {
    try {
      const decoded = await firebaseAuth.verifyIdToken(token);

      const existingUser = await prisma.user.findUnique({
        where: { id: decoded.uid },
        select: { id: true, emergency_pin_hash: true },
      });

      if (existingUser) {
        await prisma.user.update({
          where: { id: decoded.uid },
          data: {
            email: decoded.email || null,
            full_name: decoded.name || null,
            is_verified: decoded.email_verified || false,
            emergency_pin_hash:
              existingUser.emergency_pin_hash || hashEmergencyPin(generateEmergencyPin()),
            updated_at: new Date(),
          },
        });
      } else {
        await prisma.user.create({
          data: {
            id: decoded.uid,
            email: decoded.email || null,
            full_name: decoded.name || null,
            role: "user",
            is_anonymous_mode: !decoded.email,
            is_verified: decoded.email_verified || false,
            emergency_pin_hash: hashEmergencyPin(generateEmergencyPin()),
          },
        });
      }

      return {
        uid: decoded.uid,
        email: decoded.email,
        name: decoded.name,
        picture: decoded.picture,
      };
    } catch {
      throw new UnauthorizedError("Invalid or expired Firebase token");
    }
  }
}
