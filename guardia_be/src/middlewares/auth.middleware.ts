import { Request, Response, NextFunction } from "express";
import { firebaseAuth } from "../config/firebase";
import { UnauthorizedError } from "../utils/errors";
import { prisma } from "../config/database";
import { generateEmergencyPin, hashEmergencyPin } from "../utils/emergency-pin";

export interface AuthenticatedRequest extends Request {
  uid?: string;
  email?: string;
}

export async function authMiddleware(
  req: AuthenticatedRequest,
  _res: Response,
  next: NextFunction
): Promise<void> {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return next(new UnauthorizedError("Missing or invalid authorization header"));
  }

  const token = authHeader.substring(7).trim();

  if (!token) {
    return next(new UnauthorizedError("Token not provided"));
  }

  try {
    const decodedToken = await firebaseAuth.verifyIdToken(token);

    const existingUser = await prisma.user.findUnique({
      where: { id: decodedToken.uid },
      select: { id: true, emergency_pin_hash: true },
    });

    if (existingUser) {
      await prisma.user.update({
        where: { id: decodedToken.uid },
        data: {
          email: decodedToken.email || null,
          full_name: decodedToken.name || null,
          is_verified: decodedToken.email_verified || false,
          emergency_pin_hash:
            existingUser.emergency_pin_hash || hashEmergencyPin(generateEmergencyPin()),
          updated_at: new Date(),
        },
      });
    } else {
      await prisma.user.create({
        data: {
          id: decodedToken.uid,
          email: decodedToken.email || null,
          full_name: decodedToken.name || null,
          role: "user",
          is_anonymous_mode: !decodedToken.email,
          is_verified: decodedToken.email_verified || false,
          emergency_pin_hash: hashEmergencyPin(generateEmergencyPin()),
        },
      });
    }

    req.uid = decodedToken.uid;
    req.email = decodedToken.email;

    if (process.env.NODE_ENV !== "production") {
      console.log("[AuthMiddleware] Authenticated and synced user", {
        uid: decodedToken.uid,
        email: decodedToken.email || null,
      });
    }

    next();
  } catch {
    next(new UnauthorizedError("Invalid or expired token"));
  }
}
