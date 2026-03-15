import { prisma } from "../config/database";
import { NotFoundError, ForbiddenError } from "../utils/errors";
import type {
  CreateReportInput,
  ListReportsInput,
  UpdateReportStatusInput,
} from "../validators/report.validator";
import type { Prisma } from "@prisma/client";

export class ReportService {
  private blurCoordinate(coord: number, precision: number = 3): number {
    const factor = Math.pow(10, precision);
    return Math.round(coord * factor) / factor;
  }

  async create(userId: string, data: CreateReportInput) {
    const report = await prisma.incidentReport.create({
      data: {
        user_id: data.is_anonymous ? null : userId,
        incident_type: data.incident_type,
        description: data.description,
        incident_at: new Date(data.incident_at),
        latitude: data.latitude,
        longitude: data.longitude,
        latitude_blurred: this.blurCoordinate(data.latitude),
        longitude_blurred: this.blurCoordinate(data.longitude),
        location_label: data.location_label,
        is_anonymous: data.is_anonymous,
        status: "received",
      },
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
        created_at: true,
      },
    });

    return report;
  }

  async list(options: ListReportsInput = {}) {
    const { limit = 20, offset = 0, status, incident_type, user_id } = options;
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

    if (user_id) {
      where.user_id = user_id;
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

  async getById(reportId: string) {
    const report = await prisma.incidentReport.findUnique({
      where: { id: reportId, deleted_at: null },
      include: {
        user: {
          select: {
            id: true,
            full_name: true,
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

  async getMyReports(userId: string, options: ListReportsInput = {}) {
    return this.list({ ...options, user_id: userId });
  }

  async updateStatus(userId: string, reportId: string, data: UpdateReportStatusInput) {
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
          changed_by: userId,
          old_status: report.status,
          new_status: data.status,
          notes: data.notes,
        },
      }),
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

  async getStats() {
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
}
