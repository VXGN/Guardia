import { Response } from "express";
import { AdminService } from "../services/admin.service";
import { sendSuccess } from "../utils/response";
import { asyncHandler } from "../utils/async-handler";
import type { AuthenticatedRequest } from "../middlewares/auth.middleware";

const adminService = new AdminService();

export class AdminController {
  listReports = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
    await adminService.checkIsAdmin(req.uid!);
    const result = await adminService.listReports(req.query as any);
    sendSuccess(res, result, "Reports retrieved successfully");
  });

  getReport = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
    await adminService.checkIsAdmin(req.uid!);
    const { id } = req.params;
    const report = await adminService.getReportById(id);
    sendSuccess(res, report, "Report retrieved successfully");
  });

  updateReportStatus = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
    await adminService.checkIsAdmin(req.uid!);
    const { id } = req.params;
    const result = await adminService.updateReportStatus(req.uid!, id, req.body);
    sendSuccess(res, result, "Report status updated successfully");
  });

  getDashboardStats = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
    await adminService.checkIsAdmin(req.uid!);
    const stats = await adminService.getDashboardStats();
    sendSuccess(res, stats, "Dashboard stats retrieved successfully");
  });
}
