import { z } from "zod";

export const triggerPanicSchema = z.object({
  body: z.object({
    latitude: z.number().min(-90).max(90),
    longitude: z.number().min(-180).max(180),
    message: z.string().max(500).optional(),
  }),
});

export const updatePanicLocationSchema = z.object({
  body: z.object({
    session_id: z.string().optional(),
    latitude: z.number().min(-90).max(90),
    longitude: z.number().min(-180).max(180),
  }),
});

export const cancelPanicSchema = z.object({
  body: z
    .object({
      emergency_code: z.string().min(4).max(6).optional(),
      emergency_pin: z.string().min(4).max(6).optional(),
      session_id: z.string().optional(),
    })
    .refine((data) => Boolean(data.emergency_code || data.emergency_pin || data.session_id), {
      message: "Emergency PIN or session_id is required",
      path: ["emergency_pin"],
    }),
});

export type TriggerPanicInput = z.infer<typeof triggerPanicSchema>["body"];
export type UpdatePanicLocationInput = z.infer<typeof updatePanicLocationSchema>["body"];
export type CancelPanicInput = z.infer<typeof cancelPanicSchema>["body"];
