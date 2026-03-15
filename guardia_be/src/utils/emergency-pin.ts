import { randomBytes, scryptSync, timingSafeEqual } from "crypto";

const PIN_LENGTH = 6;

export function generateEmergencyPin(): string {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

export function hashEmergencyPin(pin: string): string {
  const salt = randomBytes(16).toString("hex");
  const hash = scryptSync(pin, salt, 64).toString("hex");
  return `${salt}:${hash}`;
}

export function verifyEmergencyPin(pin: string, storedHash: string): boolean {
  const [salt, hash] = storedHash.split(":");
  if (!salt || !hash || pin.length !== PIN_LENGTH) {
    return false;
  }

  const derived = scryptSync(pin, salt, 64);
  const stored = Buffer.from(hash, "hex");

  if (derived.length !== stored.length) {
    return false;
  }

  return timingSafeEqual(derived, stored);
}
