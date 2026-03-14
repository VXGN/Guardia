import { z } from "zod";

export const createTrustedContactSchema = z.object({
  body: z.object({
    contact_name: z.string().min(1).max(100),
    contact_phone: z.string().regex(/^\+?[1-9]\d{1,14}$/, "Invalid phone number format"),
    contact_email: z.string().email().max(150).optional(),
  }),
});

export const updateTrustedContactSchema = z.object({
  params: z.object({
    id: z.string().uuid(),
  }),
  body: z.object({
    contact_name: z.string().min(1).max(100).optional(),
    contact_phone: z
      .string()
      .regex(/^\+?[1-9]\d{1,14}$/, "Invalid phone number format")
      .optional(),
    contact_email: z.string().email().max(150).optional().nullable(),
    is_active: z.boolean().optional(),
  }),
});

export const trustedContactIdSchema = z.object({
  params: z.object({
    id: z.string().uuid(),
  }),
});

export type CreateTrustedContactInput = z.infer<typeof createTrustedContactSchema>["body"];
export type UpdateTrustedContactInput = z.infer<typeof updateTrustedContactSchema>["body"];
