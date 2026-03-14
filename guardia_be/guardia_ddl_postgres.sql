-- =============================================================================
-- GUARDIA - Smart, Safe, and Inclusive Public Spaces
-- SQL DDL - PostgreSQL 14+ Compatible
-- Generated: 2026-03-11
-- Standards: snake_case, UUID PK, TIMESTAMPTZ, Soft Delete
-- =============================================================================

-- =============================================================================
-- EXTENSIONS / UTILITIES
-- =============================================================================
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role_enum') THEN
        CREATE TYPE user_role_enum AS ENUM ('user', 'admin', 'partner');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'incident_type_enum') THEN
        CREATE TYPE incident_type_enum AS ENUM ('verbal_harassment', 'physical_harassment', 'stalking', 'theft', 'intimidation', 'other');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'report_status_enum') THEN
        CREATE TYPE report_status_enum AS ENUM ('received', 'verified', 'in_progress', 'resolved', 'rejected');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'media_type_enum') THEN
        CREATE TYPE media_type_enum AS ENUM ('photo', 'audio', 'video');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'journey_status_enum') THEN
        CREATE TYPE journey_status_enum AS ENUM ('active', 'completed', 'alert_triggered', 'cancelled');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'time_slot_enum') THEN
        CREATE TYPE time_slot_enum AS ENUM ('morning', 'afternoon', 'evening', 'night');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'intensity_enum') THEN
        CREATE TYPE intensity_enum AS ENUM ('low', 'medium', 'high', 'critical');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'notification_type_enum') THEN
        CREATE TYPE notification_type_enum AS ENUM ('journey_start', 'journey_safe_arrival', 'journey_alert', 'report_status_update', 'panic_alert', 'system');
    END IF;
END $$;

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- TABLE: users
-- =============================================================================
CREATE TABLE IF NOT EXISTS users (
    id                UUID            NOT NULL DEFAULT gen_random_uuid(),
    full_name         VARCHAR(100),
    email             VARCHAR(150),
    phone_number      VARCHAR(20),
    password_hash     TEXT,
    role              user_role_enum  NOT NULL DEFAULT 'user',
    is_anonymous_mode BOOLEAN         NOT NULL DEFAULT TRUE,
    is_verified       BOOLEAN         NOT NULL DEFAULT FALSE,
    fcm_token         TEXT,
    created_at        TIMESTAMPTZ     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMPTZ     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at        TIMESTAMPTZ,

    CONSTRAINT pk_users PRIMARY KEY (id),
    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT uq_users_phone UNIQUE (phone_number),
    CONSTRAINT chk_users_email_or_phone CHECK (
        email IS NOT NULL OR phone_number IS NOT NULL OR is_anonymous_mode = TRUE
    )
);

COMMENT ON TABLE users IS 'Akun pengguna Guardia, mendukung mode anonim';
COMMENT ON COLUMN users.fcm_token IS 'Firebase Cloud Messaging token for push notification';
COMMENT ON COLUMN users.deleted_at IS 'Soft delete timestamp';

CREATE INDEX users_role_idx ON users (role);
CREATE INDEX users_deleted_at_idx ON users (deleted_at);
CREATE INDEX users_verified_idx ON users (is_verified);

CREATE TRIGGER trg_users_set_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- =============================================================================
-- TABLE: trusted_contacts
-- =============================================================================
CREATE TABLE IF NOT EXISTS trusted_contacts (
    id            UUID         NOT NULL DEFAULT gen_random_uuid(),
    user_id       UUID         NOT NULL,
    contact_name  VARCHAR(100) NOT NULL,
    contact_phone VARCHAR(20)  NOT NULL,
    contact_email VARCHAR(150),
    is_active     BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMPTZ  NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_trusted_contacts PRIMARY KEY (id),
    CONSTRAINT fk_trusted_contacts_user_id
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

COMMENT ON TABLE trusted_contacts IS 'Kontak kepercayaan pengguna untuk fitur Temani Perjalanan';

CREATE INDEX trusted_contacts_user_id_idx ON trusted_contacts (user_id);
CREATE INDEX trusted_contacts_active_idx ON trusted_contacts (user_id, is_active);

CREATE TRIGGER trg_trusted_contacts_set_updated_at
BEFORE UPDATE ON trusted_contacts
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- =============================================================================
-- TABLE: incident_reports
-- =============================================================================
CREATE TABLE IF NOT EXISTS incident_reports (
    id                UUID               NOT NULL DEFAULT gen_random_uuid(),
    user_id           UUID,
    incident_type     incident_type_enum NOT NULL,
    description       TEXT,
    incident_at       TIMESTAMPTZ        NOT NULL,
    latitude          DECIMAL(10,8)      NOT NULL,
    longitude         DECIMAL(11,8)      NOT NULL,
    latitude_blurred  DECIMAL(7,5)       NOT NULL,
    longitude_blurred DECIMAL(8,5)       NOT NULL,
    location_label    VARCHAR(255),
    is_anonymous      BOOLEAN            NOT NULL DEFAULT TRUE,
    status            report_status_enum NOT NULL DEFAULT 'received',
    severity_score    SMALLINT,
    created_at        TIMESTAMPTZ        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMPTZ        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at        TIMESTAMPTZ,

    CONSTRAINT pk_incident_reports PRIMARY KEY (id),
    CONSTRAINT fk_incident_reports_user_id
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_incident_severity
        CHECK (severity_score IS NULL OR (severity_score BETWEEN 1 AND 5)),
    CONSTRAINT chk_incident_lat
        CHECK (latitude BETWEEN -90 AND 90),
    CONSTRAINT chk_incident_lng
        CHECK (longitude BETWEEN -180 AND 180)
);

COMMENT ON TABLE incident_reports IS 'Laporan insiden warga, mendukung mode anonim';
COMMENT ON COLUMN incident_reports.user_id IS 'NULL jika laporan sepenuhnya anonim (guest)';
COMMENT ON COLUMN incident_reports.incident_at IS 'Waktu kejadian, bisa berbeda dari created_at';
COMMENT ON COLUMN incident_reports.latitude IS 'Koordinat presisi, hanya untuk internal/analitik';
COMMENT ON COLUMN incident_reports.latitude_blurred IS 'Koordinat dibulatkan untuk heatmap publik (~100-200m)';
COMMENT ON COLUMN incident_reports.severity_score IS 'Skor keparahan 1-5, diisi admin atau AI';
COMMENT ON COLUMN incident_reports.deleted_at IS 'Soft delete';

CREATE INDEX incident_reports_user_id_idx ON incident_reports (user_id);
CREATE INDEX incident_reports_status_idx ON incident_reports (status);
CREATE INDEX incident_reports_incident_at_idx ON incident_reports (incident_at);
CREATE INDEX incident_reports_type_idx ON incident_reports (incident_type);
CREATE INDEX incident_reports_blurred_loc_idx ON incident_reports (latitude_blurred, longitude_blurred);
CREATE INDEX incident_reports_deleted_at_idx ON incident_reports (deleted_at);

CREATE TRIGGER trg_incident_reports_set_updated_at
BEFORE UPDATE ON incident_reports
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- =============================================================================
-- TABLE: report_media
-- =============================================================================
CREATE TABLE IF NOT EXISTS report_media (
    id           UUID            NOT NULL DEFAULT gen_random_uuid(),
    report_id    UUID            NOT NULL,
    media_type   media_type_enum NOT NULL,
    storage_url  TEXT            NOT NULL,
    file_size_kb INTEGER,
    is_encrypted BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMPTZ     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_report_media PRIMARY KEY (id),
    CONSTRAINT fk_report_media_report_id
        FOREIGN KEY (report_id) REFERENCES incident_reports(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_report_media_size
        CHECK (file_size_kb IS NULL OR file_size_kb > 0)
);

COMMENT ON TABLE report_media IS 'File media (foto/audio/video) terenkripsi untuk laporan';
COMMENT ON COLUMN report_media.storage_url IS 'URL terenkripsi di cloud storage (S3/Firebase)';

CREATE INDEX report_media_report_id_idx ON report_media (report_id);
CREATE INDEX report_media_type_idx ON report_media (report_id, media_type);

-- =============================================================================
-- TABLE: report_status_logs
-- =============================================================================
CREATE TABLE IF NOT EXISTS report_status_logs (
    id         UUID             NOT NULL DEFAULT gen_random_uuid(),
    report_id  UUID             NOT NULL,
    changed_by UUID,
    old_status report_status_enum NOT NULL,
    new_status report_status_enum NOT NULL,
    notes      TEXT,
    changed_at TIMESTAMPTZ      NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_report_status_logs PRIMARY KEY (id),
    CONSTRAINT fk_rsl_report_id
        FOREIGN KEY (report_id) REFERENCES incident_reports(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_rsl_changed_by
        FOREIGN KEY (changed_by) REFERENCES users(id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_rsl_status_changed
        CHECK (old_status <> new_status)
);

COMMENT ON TABLE report_status_logs IS 'Riwayat perubahan status laporan (audit trail)';
COMMENT ON COLUMN report_status_logs.changed_by IS 'Admin/partner yang mengubah status';
COMMENT ON COLUMN report_status_logs.notes IS 'Catatan tindak lanjut yang ditampilkan ke pelapor';

CREATE INDEX rsl_report_id_idx ON report_status_logs (report_id);
CREATE INDEX rsl_changed_by_idx ON report_status_logs (changed_by);
CREATE INDEX rsl_changed_at_idx ON report_status_logs (changed_at);

-- =============================================================================
-- TABLE: journeys
-- =============================================================================
CREATE TABLE IF NOT EXISTS journeys (
    id                     UUID                NOT NULL DEFAULT gen_random_uuid(),
    user_id                UUID                NOT NULL,
    status                 journey_status_enum NOT NULL DEFAULT 'active',
    started_at             TIMESTAMPTZ         NOT NULL,
    ended_at               TIMESTAMPTZ,
    origin_lat             DECIMAL(10,8),
    origin_lng             DECIMAL(11,8),
    destination_lat        DECIMAL(10,8),
    destination_lng        DECIMAL(11,8),
    safe_arrival_confirmed BOOLEAN             NOT NULL DEFAULT FALSE,
    created_at             TIMESTAMPTZ         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at             TIMESTAMPTZ         NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_journeys PRIMARY KEY (id),
    CONSTRAINT fk_journeys_user_id
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_journeys_ended_after_started
        CHECK (ended_at IS NULL OR ended_at >= started_at)
);

COMMENT ON TABLE journeys IS 'Sesi Temani Perjalanan yang diaktifkan pengguna';

CREATE INDEX journeys_user_id_idx ON journeys (user_id);
CREATE INDEX journeys_status_idx ON journeys (status);
CREATE INDEX journeys_started_at_idx ON journeys (started_at);

CREATE TRIGGER trg_journeys_set_updated_at
BEFORE UPDATE ON journeys
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- =============================================================================
-- TABLE: journey_location_logs
-- =============================================================================
CREATE TABLE IF NOT EXISTS journey_location_logs (
    id                 UUID          NOT NULL DEFAULT gen_random_uuid(),
    journey_id         UUID          NOT NULL,
    latitude           DECIMAL(10,8) NOT NULL,
    longitude          DECIMAL(11,8) NOT NULL,
    recorded_at        TIMESTAMPTZ   NOT NULL,
    is_anomaly_flagged BOOLEAN       NOT NULL DEFAULT FALSE,

    CONSTRAINT pk_journey_location_logs PRIMARY KEY (id),
    CONSTRAINT fk_jll_journey_id
        FOREIGN KEY (journey_id) REFERENCES journeys(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_jll_lat CHECK (latitude BETWEEN -90 AND 90),
    CONSTRAINT chk_jll_lng CHECK (longitude BETWEEN -180 AND 180)
);

COMMENT ON TABLE journey_location_logs IS 'Log titik lokasi real-time selama sesi perjalanan aktif';
COMMENT ON COLUMN journey_location_logs.is_anomaly_flagged IS 'True jika sistem deteksi pengguna tidak bergerak di area berisiko';

CREATE INDEX jll_journey_id_idx ON journey_location_logs (journey_id);
CREATE INDEX jll_recorded_at_idx ON journey_location_logs (journey_id, recorded_at);
CREATE INDEX jll_anomaly_idx ON journey_location_logs (is_anomaly_flagged);

-- =============================================================================
-- TABLE: journey_contacts
-- =============================================================================
CREATE TABLE IF NOT EXISTS journey_contacts (
    id                 UUID        NOT NULL DEFAULT gen_random_uuid(),
    journey_id         UUID        NOT NULL,
    trusted_contact_id UUID        NOT NULL,
    notified_at        TIMESTAMPTZ,
    alert_sent_at      TIMESTAMPTZ,

    CONSTRAINT pk_journey_contacts PRIMARY KEY (id),
    CONSTRAINT uq_journey_contact UNIQUE (journey_id, trusted_contact_id),
    CONSTRAINT fk_jc_journey_id
        FOREIGN KEY (journey_id) REFERENCES journeys(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_jc_trusted_contact_id
        FOREIGN KEY (trusted_contact_id) REFERENCES trusted_contacts(id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

COMMENT ON TABLE journey_contacts IS 'Pivot: kontak kepercayaan yang diikutsertakan dalam sesi perjalanan';
COMMENT ON COLUMN journey_contacts.alert_sent_at IS 'Waktu notifikasi peringatan anomali dikirim';

CREATE INDEX jc_journey_id_idx ON journey_contacts (journey_id);
CREATE INDEX jc_trusted_contact_id_idx ON journey_contacts (trusted_contact_id);

-- =============================================================================
-- TABLE: road_segments
-- =============================================================================
CREATE TABLE IF NOT EXISTS road_segments (
    id                 UUID           NOT NULL DEFAULT gen_random_uuid(),
    segment_name       VARCHAR(255),
    start_lat          DECIMAL(10,8) NOT NULL,
    start_lng          DECIMAL(11,8) NOT NULL,
    end_lat            DECIMAL(10,8) NOT NULL,
    end_lng            DECIMAL(11,8) NOT NULL,
    length_meters      INTEGER,
    has_street_light   BOOLEAN        NOT NULL DEFAULT FALSE,
    is_main_road       BOOLEAN        NOT NULL DEFAULT FALSE,
    near_security_post BOOLEAN        NOT NULL DEFAULT FALSE,
    osm_way_id         BIGINT,
    created_at         TIMESTAMPTZ    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         TIMESTAMPTZ    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_road_segments PRIMARY KEY (id),
    CONSTRAINT uq_road_segments_osm UNIQUE (osm_way_id),
    CONSTRAINT chk_rs_length CHECK (length_meters IS NULL OR length_meters > 0)
);

COMMENT ON TABLE road_segments IS 'Segmen jalan untuk graf rute aman (OpenStreetMap / manual)';
COMMENT ON COLUMN road_segments.osm_way_id IS 'OpenStreetMap Way ID referensi';

CREATE INDEX rs_osm_way_id_idx ON road_segments (osm_way_id);
CREATE INDEX rs_start_coords_idx ON road_segments (start_lat, start_lng);
CREATE INDEX rs_end_coords_idx ON road_segments (end_lat, end_lng);
CREATE INDEX rs_street_light_idx ON road_segments (has_street_light);

CREATE TRIGGER trg_road_segments_set_updated_at
BEFORE UPDATE ON road_segments
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- =============================================================================
-- TABLE: risk_scores
-- =============================================================================
CREATE TABLE IF NOT EXISTS risk_scores (
    id                     UUID               NOT NULL DEFAULT gen_random_uuid(),
    segment_id             UUID               NOT NULL,
    time_slot              time_slot_enum     NOT NULL,
    risk_score             DECIMAL(5,2)       NOT NULL,
    incident_count         INTEGER            NOT NULL DEFAULT 0,
    dominant_incident_type incident_type_enum,
    calculated_at          TIMESTAMPTZ        NOT NULL,
    valid_until            TIMESTAMPTZ,

    CONSTRAINT pk_risk_scores PRIMARY KEY (id),
    CONSTRAINT uq_risk_scores_segment_slot UNIQUE (segment_id, time_slot),
    CONSTRAINT fk_risk_scores_segment_id
        FOREIGN KEY (segment_id) REFERENCES road_segments(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_risk_score_range
        CHECK (risk_score BETWEEN 0.00 AND 100.00),
    CONSTRAINT chk_risk_incident_count
        CHECK (incident_count >= 0)
);

COMMENT ON TABLE risk_scores IS 'Skor risiko per segmen jalan per time-slot dari AI microservice';
COMMENT ON COLUMN risk_scores.risk_score IS 'Skor 0.00-100.00, semakin tinggi semakin berisiko';
COMMENT ON COLUMN risk_scores.valid_until IS 'Cache/expiry management';

CREATE INDEX risk_scores_segment_id_idx ON risk_scores (segment_id);
CREATE INDEX risk_scores_time_slot_idx ON risk_scores (time_slot);
CREATE INDEX risk_scores_score_idx ON risk_scores (risk_score);
CREATE INDEX risk_scores_valid_until_idx ON risk_scores (valid_until);

-- =============================================================================
-- TABLE: heatmap_clusters
-- =============================================================================
CREATE TABLE IF NOT EXISTS heatmap_clusters (
    id                 UUID           NOT NULL DEFAULT gen_random_uuid(),
    center_lat_blurred DECIMAL(7,5)  NOT NULL,
    center_lng_blurred DECIMAL(8,5)  NOT NULL,
    radius_meters      INTEGER       NOT NULL,
    intensity          intensity_enum NOT NULL,
    incident_count     INTEGER       NOT NULL,
    dominant_type      incident_type_enum,
    time_slot          time_slot_enum,
    valid_from         TIMESTAMPTZ   NOT NULL,
    valid_until        TIMESTAMPTZ   NOT NULL,
    created_at         TIMESTAMPTZ   NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_heatmap_clusters PRIMARY KEY (id),
    CONSTRAINT chk_heatmap_radius CHECK (radius_meters > 0),
    CONSTRAINT chk_heatmap_incidents CHECK (incident_count >= 0),
    CONSTRAINT chk_heatmap_validity CHECK (valid_until > valid_from)
);

COMMENT ON TABLE heatmap_clusters IS 'Hasil clustering spatio-temporal untuk heatmap di aplikasi';
COMMENT ON COLUMN heatmap_clusters.center_lat_blurred IS 'Koordinat dibulatkan untuk privasi';

CREATE INDEX heatmap_intensity_idx ON heatmap_clusters (intensity);
CREATE INDEX heatmap_valid_until_idx ON heatmap_clusters (valid_until);
CREATE INDEX heatmap_time_slot_idx ON heatmap_clusters (time_slot);
CREATE INDEX heatmap_center_idx ON heatmap_clusters (center_lat_blurred, center_lng_blurred);

-- =============================================================================
-- TABLE: notifications
-- =============================================================================
CREATE TABLE IF NOT EXISTS notifications (
    id                 UUID                   NOT NULL DEFAULT gen_random_uuid(),
    recipient_user_id  UUID,
    recipient_phone    VARCHAR(20),
    notification_type  notification_type_enum NOT NULL,
    title              VARCHAR(150)           NOT NULL,
    body               TEXT                   NOT NULL,
    related_journey_id UUID,
    related_report_id  UUID,
    is_sent            BOOLEAN                NOT NULL DEFAULT FALSE,
    sent_at            TIMESTAMPTZ,
    created_at         TIMESTAMPTZ            NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_notifications PRIMARY KEY (id),
    CONSTRAINT fk_notif_recipient_user_id
        FOREIGN KEY (recipient_user_id) REFERENCES users(id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_notif_related_journey_id
        FOREIGN KEY (related_journey_id) REFERENCES journeys(id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_notif_related_report_id
        FOREIGN KEY (related_report_id) REFERENCES incident_reports(id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_notif_recipient
        CHECK (recipient_user_id IS NOT NULL OR recipient_phone IS NOT NULL)
);

COMMENT ON TABLE notifications IS 'Log semua notifikasi sistem ke pengguna atau kontak kepercayaan';
COMMENT ON COLUMN notifications.recipient_phone IS 'Untuk kontak kepercayaan non-user';

CREATE INDEX notif_recipient_user_id_idx ON notifications (recipient_user_id);
CREATE INDEX notif_type_idx ON notifications (notification_type);
CREATE INDEX notif_is_sent_idx ON notifications (is_sent);
CREATE INDEX notif_created_at_idx ON notifications (created_at);
CREATE INDEX notif_journey_id_idx ON notifications (related_journey_id);
CREATE INDEX notif_report_id_idx ON notifications (related_report_id);

-- =============================================================================
-- END OF DDL
-- =============================================================================
