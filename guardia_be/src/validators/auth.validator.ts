import { z } from "zod";

export const verifyTokenSchema = z.object({
  body: z.object({
    token: z.string().min(1),
  }),
});

export const registerSchema = z.object({
  body: z.object({
    full_name: z.string().min(1).max(100).optional(),
    fullName: z.string().min(1).max(100).optional(),
    email: z.string().email().max(150),
    phone_number: z.string().min(8).max(20).optional(),
    phoneNumber: z.string().min(8).max(20).optional(),
    password: z.string().min(6).max(128),
    emergency_pin: z.string().min(4).max(6).optional(),
    emergencyPin: z.string().min(4).max(6).optional(),
    "emergency pin": z.string().min(4).max(6).optional(),
  }),
});

export type VerifyTokenInput = z.infer<typeof verifyTokenSchema>["body"];
export type RegisterInput = z.infer<typeof registerSchema>["body"];
