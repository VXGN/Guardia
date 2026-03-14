import { z } from "zod";

export const listNotificationsSchema = z.object({
  query: z.object({
    limit: z.coerce.number().min(1).max(100).default(20).optional(),
    offset: z.coerce.number().min(0).default(0).optional(),
    unread_only: z.coerce.boolean().default(false).optional(),
  }),
});

export const notificationIdSchema = z.object({
  params: z.object({
    id: z.string().uuid(),
  }),
});

export type ListNotificationsInput = z.infer<typeof listNotificationsSchema>["query"];
