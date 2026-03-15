import { z } from "zod";

export const triggerPanicSchema = z.object({
  body: z.object({
    latitude: z.number().min(-90).max(90),
    longitude: z.number().min(-180).max(180),
    message: z.string().max(500).optional(),
  }),
});

export const cancelPanicSchema = z.object({
  body: z
    .object({
      emergency_code: z.string().length(6, "Emergency code must be 6 digits").optional(),
      emergency_pin: z.string().length(6, "Emergency PIN must be 6 digits").optional(),
    })
    .refine((data) => Boolean(data.emergency_code || data.emergency_pin), {
      message: "Emergency PIN is required",
      path: ["emergency_pin"],
    }),
});

export type TriggerPanicInput = z.infer<typeof triggerPanicSchema>["body"];
export type CancelPanicInput = z.infer<typeof cancelPanicSchema>["body"];
