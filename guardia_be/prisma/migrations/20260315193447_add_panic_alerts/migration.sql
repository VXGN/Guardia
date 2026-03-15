-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('user', 'admin', 'partner');

-- CreateEnum
CREATE TYPE "IncidentType" AS ENUM ('verbal_harassment', 'physical_harassment', 'stalking', 'theft', 'intimidation', 'other');

-- CreateEnum
CREATE TYPE "ReportStatus" AS ENUM ('received', 'verified', 'in_progress', 'resolved', 'rejected');

-- CreateEnum
CREATE TYPE "MediaType" AS ENUM ('photo', 'audio', 'video');

-- CreateEnum
CREATE TYPE "JourneyStatus" AS ENUM ('active', 'completed', 'alert_triggered', 'cancelled');

-- CreateEnum
CREATE TYPE "TimeSlot" AS ENUM ('morning', 'afternoon', 'evening', 'night');

-- CreateEnum
CREATE TYPE "HeatmapIntensity" AS ENUM ('low', 'medium', 'high', 'critical');

-- CreateEnum
CREATE TYPE "NotificationType" AS ENUM ('journey_start', 'journey_safe_arrival', 'journey_alert', 'report_status_update', 'panic_alert', 'system');

-- CreateTable
CREATE TABLE "users" (
    "id" CHAR(36) NOT NULL,
    "full_name" VARCHAR(100),
    "email" VARCHAR(150),
    "phone_number" VARCHAR(20),
    "password_hash" TEXT,
    "role" "UserRole" NOT NULL DEFAULT 'user',
    "is_anonymous_mode" BOOLEAN NOT NULL DEFAULT true,
    "is_verified" BOOLEAN NOT NULL DEFAULT false,
    "fcm_token" TEXT,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) NOT NULL,
    "deleted_at" TIMESTAMP(6),

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "trusted_contacts" (
    "id" CHAR(36) NOT NULL,
    "user_id" CHAR(36) NOT NULL,
    "contact_name" VARCHAR(100) NOT NULL,
    "contact_phone" VARCHAR(20) NOT NULL,
    "contact_email" VARCHAR(150),
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) NOT NULL,

    CONSTRAINT "trusted_contacts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "incident_reports" (
    "id" CHAR(36) NOT NULL,
    "user_id" CHAR(36),
    "incident_type" "IncidentType" NOT NULL,
    "description" TEXT,
    "incident_at" TIMESTAMP(6) NOT NULL,
    "latitude" DECIMAL(10,8) NOT NULL,
    "longitude" DECIMAL(11,8) NOT NULL,
    "latitude_blurred" DECIMAL(7,5) NOT NULL,
    "longitude_blurred" DECIMAL(8,5) NOT NULL,
    "location_label" VARCHAR(255),
    "is_anonymous" BOOLEAN NOT NULL DEFAULT true,
    "status" "ReportStatus" NOT NULL DEFAULT 'received',
    "severity_score" SMALLINT,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) NOT NULL,
    "deleted_at" TIMESTAMP(6),

    CONSTRAINT "incident_reports_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "report_media" (
    "id" CHAR(36) NOT NULL,
    "report_id" CHAR(36) NOT NULL,
    "media_type" "MediaType" NOT NULL,
    "storage_url" TEXT NOT NULL,
    "file_size_kb" INTEGER,
    "is_encrypted" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "report_media_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "report_status_logs" (
    "id" CHAR(36) NOT NULL,
    "report_id" CHAR(36) NOT NULL,
    "changed_by" CHAR(36),
    "old_status" "ReportStatus" NOT NULL,
    "new_status" "ReportStatus" NOT NULL,
    "notes" TEXT,
    "changed_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "report_status_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "journeys" (
    "id" CHAR(36) NOT NULL,
    "user_id" CHAR(36) NOT NULL,
    "status" "JourneyStatus" NOT NULL DEFAULT 'active',
    "started_at" TIMESTAMP(6) NOT NULL,
    "ended_at" TIMESTAMP(6),
    "origin_lat" DECIMAL(10,8),
    "origin_lng" DECIMAL(11,8),
    "destination_lat" DECIMAL(10,8),
    "destination_lng" DECIMAL(11,8),
    "safe_arrival_confirmed" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) NOT NULL,

    CONSTRAINT "journeys_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "journey_location_logs" (
    "id" CHAR(36) NOT NULL,
    "journey_id" CHAR(36) NOT NULL,
    "latitude" DECIMAL(10,8) NOT NULL,
    "longitude" DECIMAL(11,8) NOT NULL,
    "recorded_at" TIMESTAMP(6) NOT NULL,
    "is_anomaly_flagged" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "journey_location_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "journey_contacts" (
    "id" CHAR(36) NOT NULL,
    "journey_id" CHAR(36) NOT NULL,
    "trusted_contact_id" CHAR(36) NOT NULL,
    "notified_at" TIMESTAMP(6),
    "alert_sent_at" TIMESTAMP(6),

    CONSTRAINT "journey_contacts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "panic_alerts" (
    "id" CHAR(36) NOT NULL,
    "user_id" CHAR(36) NOT NULL,
    "latitude" DECIMAL(10,8) NOT NULL,
    "longitude" DECIMAL(11,8) NOT NULL,
    "emergency_code" VARCHAR(6) NOT NULL,
    "message" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "triggered_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "cancelled_at" TIMESTAMP(6),
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) NOT NULL,

    CONSTRAINT "panic_alerts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "road_segments" (
    "id" CHAR(36) NOT NULL,
    "segment_name" VARCHAR(255),
    "start_lat" DECIMAL(10,8) NOT NULL,
    "start_lng" DECIMAL(11,8) NOT NULL,
    "end_lat" DECIMAL(10,8) NOT NULL,
    "end_lng" DECIMAL(11,8) NOT NULL,
    "length_meters" INTEGER,
    "has_street_light" BOOLEAN NOT NULL DEFAULT false,
    "is_main_road" BOOLEAN NOT NULL DEFAULT false,
    "near_security_post" BOOLEAN NOT NULL DEFAULT false,
    "osm_way_id" BIGINT,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) NOT NULL,

    CONSTRAINT "road_segments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "risk_scores" (
    "id" CHAR(36) NOT NULL,
    "segment_id" CHAR(36) NOT NULL,
    "time_slot" "TimeSlot" NOT NULL,
    "risk_score" DECIMAL(5,2) NOT NULL,
    "incident_count" INTEGER NOT NULL DEFAULT 0,
    "dominant_incident_type" "IncidentType",
    "calculated_at" TIMESTAMP(6) NOT NULL,
    "valid_until" TIMESTAMP(6),

    CONSTRAINT "risk_scores_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "heatmap_clusters" (
    "id" CHAR(36) NOT NULL,
    "center_lat_blurred" DECIMAL(7,5) NOT NULL,
    "center_lng_blurred" DECIMAL(8,5) NOT NULL,
    "radius_meters" INTEGER NOT NULL,
    "intensity" "HeatmapIntensity" NOT NULL,
    "incident_count" INTEGER NOT NULL,
    "dominant_type" "IncidentType",
    "time_slot" "TimeSlot",
    "valid_from" TIMESTAMP(6) NOT NULL,
    "valid_until" TIMESTAMP(6) NOT NULL,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "heatmap_clusters_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notifications" (
    "id" CHAR(36) NOT NULL,
    "recipient_user_id" CHAR(36),
    "recipient_phone" VARCHAR(20),
    "notification_type" "NotificationType" NOT NULL,
    "title" VARCHAR(150) NOT NULL,
    "body" TEXT NOT NULL,
    "related_journey_id" CHAR(36),
    "related_report_id" CHAR(36),
    "is_sent" BOOLEAN NOT NULL DEFAULT false,
    "sent_at" TIMESTAMP(6),
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "notifications_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "users_phone_number_key" ON "users"("phone_number");

-- CreateIndex
CREATE INDEX "users_role_idx" ON "users"("role");

-- CreateIndex
CREATE INDEX "users_deleted_at_idx" ON "users"("deleted_at");

-- CreateIndex
CREATE INDEX "users_verified_idx" ON "users"("is_verified");

-- CreateIndex
CREATE INDEX "trusted_contacts_user_id_idx" ON "trusted_contacts"("user_id");

-- CreateIndex
CREATE INDEX "trusted_contacts_active_idx" ON "trusted_contacts"("user_id", "is_active");

-- CreateIndex
CREATE INDEX "incident_reports_user_id_idx" ON "incident_reports"("user_id");

-- CreateIndex
CREATE INDEX "incident_reports_status_idx" ON "incident_reports"("status");

-- CreateIndex
CREATE INDEX "incident_reports_incident_at_idx" ON "incident_reports"("incident_at");

-- CreateIndex
CREATE INDEX "incident_reports_type_idx" ON "incident_reports"("incident_type");

-- CreateIndex
CREATE INDEX "incident_reports_blurred_loc_idx" ON "incident_reports"("latitude_blurred", "longitude_blurred");

-- CreateIndex
CREATE INDEX "incident_reports_deleted_at_idx" ON "incident_reports"("deleted_at");

-- CreateIndex
CREATE INDEX "report_media_report_id_idx" ON "report_media"("report_id");

-- CreateIndex
CREATE INDEX "report_media_type_idx" ON "report_media"("report_id", "media_type");

-- CreateIndex
CREATE INDEX "rsl_report_id_idx" ON "report_status_logs"("report_id");

-- CreateIndex
CREATE INDEX "rsl_changed_by_idx" ON "report_status_logs"("changed_by");

-- CreateIndex
CREATE INDEX "rsl_changed_at_idx" ON "report_status_logs"("changed_at");

-- CreateIndex
CREATE INDEX "journeys_user_id_idx" ON "journeys"("user_id");

-- CreateIndex
CREATE INDEX "journeys_status_idx" ON "journeys"("status");

-- CreateIndex
CREATE INDEX "journeys_started_at_idx" ON "journeys"("started_at");

-- CreateIndex
CREATE INDEX "jll_journey_id_idx" ON "journey_location_logs"("journey_id");

-- CreateIndex
CREATE INDEX "jll_recorded_at_idx" ON "journey_location_logs"("journey_id", "recorded_at");

-- CreateIndex
CREATE INDEX "jll_anomaly_idx" ON "journey_location_logs"("is_anomaly_flagged");

-- CreateIndex
CREATE INDEX "jc_journey_id_idx" ON "journey_contacts"("journey_id");

-- CreateIndex
CREATE INDEX "jc_trusted_contact_id_idx" ON "journey_contacts"("trusted_contact_id");

-- CreateIndex
CREATE UNIQUE INDEX "journey_contacts_journey_id_trusted_contact_id_key" ON "journey_contacts"("journey_id", "trusted_contact_id");

-- CreateIndex
CREATE INDEX "panic_alerts_user_id_idx" ON "panic_alerts"("user_id");

-- CreateIndex
CREATE INDEX "panic_alerts_active_idx" ON "panic_alerts"("user_id", "is_active");

-- CreateIndex
CREATE INDEX "panic_alerts_triggered_at_idx" ON "panic_alerts"("triggered_at");

-- CreateIndex
CREATE UNIQUE INDEX "road_segments_osm_way_id_key" ON "road_segments"("osm_way_id");

-- CreateIndex
CREATE INDEX "rs_osm_way_id_idx" ON "road_segments"("osm_way_id");

-- CreateIndex
CREATE INDEX "rs_start_coords_idx" ON "road_segments"("start_lat", "start_lng");

-- CreateIndex
CREATE INDEX "rs_end_coords_idx" ON "road_segments"("end_lat", "end_lng");

-- CreateIndex
CREATE INDEX "risk_scores_segment_id_idx" ON "risk_scores"("segment_id");

-- CreateIndex
CREATE INDEX "risk_scores_time_slot_idx" ON "risk_scores"("time_slot");

-- CreateIndex
CREATE INDEX "risk_scores_score_idx" ON "risk_scores"("risk_score");

-- CreateIndex
CREATE INDEX "risk_scores_valid_until_idx" ON "risk_scores"("valid_until");

-- CreateIndex
CREATE UNIQUE INDEX "risk_scores_segment_id_time_slot_key" ON "risk_scores"("segment_id", "time_slot");

-- CreateIndex
CREATE INDEX "heatmap_intensity_idx" ON "heatmap_clusters"("intensity");

-- CreateIndex
CREATE INDEX "heatmap_valid_until_idx" ON "heatmap_clusters"("valid_until");

-- CreateIndex
CREATE INDEX "heatmap_time_slot_idx" ON "heatmap_clusters"("time_slot");

-- CreateIndex
CREATE INDEX "heatmap_center_idx" ON "heatmap_clusters"("center_lat_blurred", "center_lng_blurred");

-- CreateIndex
CREATE INDEX "notif_recipient_user_id_idx" ON "notifications"("recipient_user_id");

-- CreateIndex
CREATE INDEX "notif_type_idx" ON "notifications"("notification_type");

-- CreateIndex
CREATE INDEX "notif_is_sent_idx" ON "notifications"("is_sent");

-- CreateIndex
CREATE INDEX "notif_created_at_idx" ON "notifications"("created_at");

-- CreateIndex
CREATE INDEX "notif_journey_id_idx" ON "notifications"("related_journey_id");

-- CreateIndex
CREATE INDEX "notif_report_id_idx" ON "notifications"("related_report_id");

-- AddForeignKey
ALTER TABLE "trusted_contacts" ADD CONSTRAINT "trusted_contacts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "incident_reports" ADD CONSTRAINT "incident_reports_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "report_media" ADD CONSTRAINT "report_media_report_id_fkey" FOREIGN KEY ("report_id") REFERENCES "incident_reports"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "report_status_logs" ADD CONSTRAINT "report_status_logs_report_id_fkey" FOREIGN KEY ("report_id") REFERENCES "incident_reports"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "report_status_logs" ADD CONSTRAINT "report_status_logs_changed_by_fkey" FOREIGN KEY ("changed_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "journeys" ADD CONSTRAINT "journeys_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "journey_location_logs" ADD CONSTRAINT "journey_location_logs_journey_id_fkey" FOREIGN KEY ("journey_id") REFERENCES "journeys"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "journey_contacts" ADD CONSTRAINT "journey_contacts_journey_id_fkey" FOREIGN KEY ("journey_id") REFERENCES "journeys"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "journey_contacts" ADD CONSTRAINT "journey_contacts_trusted_contact_id_fkey" FOREIGN KEY ("trusted_contact_id") REFERENCES "trusted_contacts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "panic_alerts" ADD CONSTRAINT "panic_alerts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "risk_scores" ADD CONSTRAINT "risk_scores_segment_id_fkey" FOREIGN KEY ("segment_id") REFERENCES "road_segments"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_recipient_user_id_fkey" FOREIGN KEY ("recipient_user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_related_journey_id_fkey" FOREIGN KEY ("related_journey_id") REFERENCES "journeys"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_related_report_id_fkey" FOREIGN KEY ("related_report_id") REFERENCES "incident_reports"("id") ON DELETE SET NULL ON UPDATE CASCADE;
