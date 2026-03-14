import { z } from "zod";

export const updateProfileSchema = z.object({
  body: z.object({
    full_name: z.string().min(1).max(100).optional(),
    phone_number: z
      .string()
      .regex(/^\+?[1-9]\d{1,14}$/, "Invalid phone number format")
      .optional(),
    is_anonymous_mode: z.boolean().optional(),
    fcm_token: z.string().optional(),
  }),
});

export type UpdateProfileInput = z.infer<typeof updateProfileSchema>["body"];
