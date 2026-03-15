import { z } from "zod";

export const verifyTokenSchema = z.object({
  body: z.object({
    token: z.string().min(1),
  }),
});

export const registerSchema = z.object({
  body: z
    .object({
      full_name: z.string().min(1).max(100).optional(),
      fullName: z.string().min(1).max(100).optional(),
      email: z.string().email().max(150),
      phone_number: z.string().min(8).max(20).optional(),
      phoneNumber: z.string().min(8).max(20).optional(),
      password: z.string().min(6).max(128),
      emergency_pin: z.string().length(6).optional(),
      emergencyPin: z.string().length(6).optional(),
      "emergency pin": z.string().length(6).optional(),
    })
    .superRefine((body, ctx) => {
      const fullName = body.full_name ?? body.fullName;
      if (!fullName) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          message: "full_name is required",
          path: ["full_name"],
        });
      }

      const emergencyPin = body.emergency_pin ?? body.emergencyPin ?? body["emergency pin"];
      if (!emergencyPin) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          message: "emergency pin is required",
          path: ["emergency_pin"],
        });
      }
    }),
});

export type VerifyTokenInput = z.infer<typeof verifyTokenSchema>["body"];
export type RegisterInput = z.infer<typeof registerSchema>["body"];
