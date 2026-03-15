import { firebaseAuth } from "../config/firebase";
import { prisma } from "../config/database";
import { Prisma } from "@prisma/client";
import { randomBytes, scryptSync } from "crypto";
import { BadRequestError, UnauthorizedError } from "../utils/errors";
import { generateEmergencyPin, hashEmergencyPin } from "../utils/emergency-pin";
import type { RegisterInput } from "../validators/auth.validator";

interface VerifyResult {
  uid: string;
  email?: string;
  name?: string;
  picture?: string;
}

interface RegisterResult {
  id: string;
  full_name: string | null;
  email: string | null;
  phone_number: string | null;
  role: string;
  is_anonymous_mode: boolean;
  is_verified: boolean;
  created_at: string;
}

function hashPassword(password: string): string {
  const salt = randomBytes(16).toString("hex");
  const hash = scryptSync(password, salt, 64).toString("hex");
  return `${salt}:${hash}`;
}

export class AuthService {
  async register(data: RegisterInput): Promise<RegisterResult> {
    const fullName = data.full_name ?? data.fullName ?? null;
    const phoneNumber = data.phone_number ?? data.phoneNumber ?? null;
    const emergencyPin = data.emergency_pin ?? data.emergencyPin ?? data["emergency pin"];

    const resolvedFullName = fullName ?? data.email.split("@")[0] ?? "Guardia User";
    const resolvedEmergencyPin = emergencyPin || generateEmergencyPin();

    if (process.env.NODE_ENV !== "production") {
      console.log("[Auth] Register request", {
        email: data.email,
        has_full_name: Boolean(fullName),
        has_phone_number: Boolean(phoneNumber),
        has_emergency_pin: Boolean(emergencyPin),
      });
    }

    try {
      const created = await prisma.user.create({
        data: {
          full_name: resolvedFullName,
          email: data.email,
          phone_number: phoneNumber,
          password_hash: hashPassword(data.password),
          emergency_pin_hash: hashEmergencyPin(resolvedEmergencyPin),
          role: "user",
          is_anonymous_mode: true,
          is_verified: false,
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
        },
      });

      return {
        id: created.id,
        full_name: created.full_name,
        email: created.email,
        phone_number: created.phone_number,
        role: created.role,
        is_anonymous_mode: created.is_anonymous_mode,
        is_verified: created.is_verified,
        created_at: created.created_at.toISOString(),
      };
    } catch (error) {
      if (
        error instanceof Prisma.PrismaClientKnownRequestError &&
        error.code === "P2002"
      ) {
        const target = (error.meta?.target as string[] | undefined) || [];
        if (target.includes("email")) {
          throw new BadRequestError("Email already registered");
        }
        if (target.includes("phone_number")) {
          throw new BadRequestError("Phone number already registered");
        }
        throw new BadRequestError("User already exists");
      }

      if (process.env.NODE_ENV !== "production") {
        console.error("[Auth] Register failed", error);
      }

      throw error;
    }
  }

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
