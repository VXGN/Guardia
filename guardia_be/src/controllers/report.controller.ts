import { Response } from "express";
import { ReportService } from "../services/report.service";
import { sendSuccess } from "../utils/response";
import { asyncHandler } from "../utils/async-handler";
import type { AuthenticatedRequest } from "../middlewares/auth.middleware";

const reportService = new ReportService();

export class ReportController {
  create = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
    const report = await reportService.create(req.uid!, req.body);
    sendSuccess(res, report, "Report created successfully", 201);
  });

  list = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
    const result = await reportService.list(req.query as any);
    sendSuccess(res, result, "Reports retrieved successfully");
  });

  getById = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
    const { id } = req.params;
    const report = await reportService.getById(id);
    sendSuccess(res, report, "Report retrieved successfully");
  });

  getMyReports = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
    const result = await reportService.getMyReports(req.uid!, req.query as any);
    sendSuccess(res, result, "Reports retrieved successfully");
  });

  updateStatus = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
    const { id } = req.params;
    const result = await reportService.updateStatus(req.uid!, id, req.body);
    sendSuccess(res, result, "Report status updated successfully");
  });

  getStats = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
    await reportService.checkIsAdmin(req.uid!);
    const stats = await reportService.getStats();
    sendSuccess(res, stats, "Stats retrieved successfully");
  });
}
