import { z } from "zod";

export const createReportSchema = z.object({
  body: z.object({
    incident_type: z.enum([
      "verbal_harassment",
      "physical_harassment",
      "stalking",
      "theft",
      "intimidation",
      "other",
    ]),
    description: z.string().min(10).max(2000),
    incident_at: z.string().datetime(),
    latitude: z.number().min(-90).max(90),
    longitude: z.number().min(-180).max(180),
    location_label: z.string().max(255).optional(),
    is_anonymous: z.boolean().default(false),
  }),
});

export const listReportsSchema = z.object({
  query: z.object({
    limit: z.coerce.number().min(1).max(100).default(20).optional(),
    offset: z.coerce.number().min(0).default(0).optional(),
    status: z
      .enum(["received", "verified", "in_progress", "resolved", "rejected"])
      .optional(),
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
    user_id: z.string().uuid().optional(),
  }),
});

export const updateReportStatusSchema = z.object({
  params: z.object({
    id: z.string().uuid(),
  }),
  body: z.object({
    status: z.enum(["received", "verified", "in_progress", "resolved", "rejected"]),
    notes: z.string().max(1000).optional(),
  }),
});

export const getReportSchema = z.object({
  params: z.object({
    id: z.string().uuid(),
  }),
});

export type CreateReportInput = z.infer<typeof createReportSchema>["body"];
export type ListReportsInput = z.infer<typeof listReportsSchema>["query"];
export type UpdateReportStatusInput = z.infer<typeof updateReportStatusSchema>["body"];
