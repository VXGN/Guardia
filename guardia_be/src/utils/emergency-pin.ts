import { randomBytes, scryptSync, scrypt as scryptCb, timingSafeEqual } from "crypto";
import { promisify } from "util";

const scryptAsync = promisify(scryptCb);
const PIN_LENGTH = 4;

export function generateEmergencyPin(): string {
  return Math.floor(1000 + Math.random() * 9000).toString();
}

export function hashEmergencyPin(pin: string): string {
  const salt = randomBytes(16).toString("hex");
  const hash = scryptSync(pin, salt, 64).toString("hex");
  return `${salt}:${hash}`;
}

export async function verifyEmergencyPin(pin: string, storedHash: string): Promise<boolean> {
  const [salt, hash] = storedHash.split(":");
  if (!salt || !hash || pin.length < PIN_LENGTH) {
    return false;
  }

  const derived = (await scryptAsync(pin, salt, 64)) as Buffer;
  const stored = Buffer.from(hash, "hex");

  if (derived.length !== stored.length) {
    return false;
  }

  return timingSafeEqual(derived, stored);
}
