import { z } from "zod";

export const chatHistorySchema = z.object({
  query: z.object({
    sender_uid: z.string().min(1),
    receiver_uid: z.string().min(1),
  }),
});

export type ChatHistoryQuery = z.infer<typeof chatHistorySchema>["query"];
