import { prisma } from "../config/database";
import { NotFoundError, ForbiddenError } from "../utils/errors";
import type { UpdateReportStatusInput, ListReportsInput } from "../validators/admin.validator";
import type { Prisma } from "@prisma/client";

export class AdminService {
  async checkIsAdmin(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId, deleted_at: null },
      select: { role: true },
    });

    if (!user) {
      throw new NotFoundError("User not found");
    }

    if (user.role !== "admin") {
      throw new ForbiddenError("Admin access required");
    }

    return true;
  }

  async listReports(options: ListReportsInput = {}) {
    const { limit = 20, offset = 0, status, incident_type } = options;
    const limitNum = Number(limit) || 20;
    const offsetNum = Number(offset) || 0;

    const where: Prisma.IncidentReportWhereInput = {
      deleted_at: null,
    };

    if (status) {
      where.status = status;
    }

    if (incident_type) {
      where.incident_type = incident_type;
    }

    const [reports, total] = await Promise.all([
      prisma.incidentReport.findMany({
        where,
        orderBy: { created_at: "desc" },
        take: limitNum,
        skip: offsetNum,
        select: {
          id: true,
          incident_type: true,
          description: true,
          incident_at: true,
          latitude_blurred: true,
          longitude_blurred: true,
          location_label: true,
          is_anonymous: true,
          status: true,
          severity_score: true,
          created_at: true,
          updated_at: true,
          user: {
            select: {
              id: true,
              full_name: true,
              email: true,
            },
          },
          _count: {
            select: { report_media: true },
          },
        },
      }),
      prisma.incidentReport.count({ where }),
    ]);

    return {
      reports,
      pagination: {
        total,
        limit: limitNum,
        offset: offsetNum,
        has_more: offsetNum + reports.length < total,
      },
    };
  }

  async getReportById(reportId: string) {
    const report = await prisma.incidentReport.findUnique({
      where: { id: reportId, deleted_at: null },
      include: {
        user: {
          select: {
            id: true,
            full_name: true,
            email: true,
          },
        },
        report_media: {
          select: {
            id: true,
            media_type: true,
            storage_url: true,
            file_size_kb: true,
            created_at: true,
          },
        },
        report_status_logs: {
          orderBy: { changed_at: "desc" },
          select: {
            id: true,
            old_status: true,
            new_status: true,
            notes: true,
            changed_at: true,
            user: {
              select: {
                id: true,
                full_name: true,
              },
            },
          },
        },
      },
    });

    if (!report) {
      throw new NotFoundError("Report not found");
    }

    return report;
  }

  async updateReportStatus(
    adminUserId: string,
    reportId: string,
    data: UpdateReportStatusInput
  ) {
    const report = await prisma.incidentReport.findUnique({
      where: { id: reportId, deleted_at: null },
    });

    if (!report) {
      throw new NotFoundError("Report not found");
    }

    const [updated] = await prisma.$transaction([
      prisma.incidentReport.update({
        where: { id: reportId },
        data: {
          status: data.status,
          updated_at: new Date(),
        },
        select: {
          id: true,
          status: true,
          updated_at: true,
        },
      }),
      prisma.reportStatusLog.create({
        data: {
          report_id: reportId,
          changed_by: adminUserId,
          old_status: report.status,
          new_status: data.status,
          notes: data.notes,
        },
      }),
      // Create notification for the report owner if they exist
      ...(report.user_id
        ? [
            prisma.notification.create({
              data: {
                recipient_user_id: report.user_id,
                notification_type: "report_status_update",
                title: "Report Status Updated",
                body: `Your report has been updated to: ${data.status}${data.notes ? `. Notes: ${data.notes}` : ""}`,
                related_report_id: reportId,
                is_sent: false,
              },
            }),
          ]
        : []),
    ]);

    return updated;
  }

  async getDashboardStats() {
    const [
      totalUsers,
      totalReports,
      reportsByStatus,
      reportsByType,
      recentReports,
      activeJourneys,
    ] = await Promise.all([
      prisma.user.count({ where: { deleted_at: null } }),
      prisma.incidentReport.count({ where: { deleted_at: null } }),
      prisma.incidentReport.groupBy({
        by: ["status"],
        where: { deleted_at: null },
        _count: true,
      }),
      prisma.incidentReport.groupBy({
        by: ["incident_type"],
        where: { deleted_at: null },
        _count: true,
        orderBy: { _count: { incident_type: "desc" } },
      }),
      prisma.incidentReport.findMany({
        where: { deleted_at: null },
        orderBy: { created_at: "desc" },
        take: 5,
        select: {
          id: true,
          incident_type: true,
          status: true,
          location_label: true,
          created_at: true,
        },
      }),
      prisma.journey.count({ where: { status: "active" } }),
    ]);

    return {
      total_users: totalUsers,
      total_reports: totalReports,
      active_journeys: activeJourneys,
      reports_by_status: reportsByStatus.map((r) => ({
        status: r.status,
        count: r._count,
      })),
      reports_by_type: reportsByType.map((r) => ({
        type: r.incident_type,
        count: r._count,
      })),
      recent_reports: recentReports,
    };
  }
}
