import { z } from "zod";

export const triggerPanicSchema = z.object({
  body: z.object({
    latitude: z.number().min(-90).max(90),
    longitude: z.number().min(-180).max(180),
    message: z.string().max(500).optional(),
  }),
});

export type TriggerPanicInput = z.infer<typeof triggerPanicSchema>["body"];
