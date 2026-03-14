import { z } from "zod";

export const updateReportStatusSchema = z.object({
  params: z.object({
    id: z.string().uuid(),
  }),
  body: z.object({
    status: z.enum(["received", "verified", "in_progress", "resolved", "rejected"]),
    notes: z.string().max(1000).optional(),
  }),
});

export const listReportsSchema = z.object({
  query: z.object({
    limit: z.coerce.number().min(1).max(100).default(20).optional(),
    offset: z.coerce.number().min(0).default(0).optional(),
    status: z.enum(["received", "verified", "in_progress", "resolved", "rejected"]).optional(),
    incident_type: z
      .enum([
        "verbal_harassment",
        "physical_harassment",
        "stalking",
        "theft",
        "intimidation",
        "other",
      ])
      .optional(),
  }),
});

export type UpdateReportStatusInput = z.infer<typeof updateReportStatusSchema>["body"];
export type ListReportsInput = z.infer<typeof listReportsSchema>["query"];
