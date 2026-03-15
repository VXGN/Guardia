ALTER TABLE "users"
  ADD COLUMN IF NOT EXISTS "emergency_pin_hash" TEXT,
  ADD COLUMN IF NOT EXISTS "panic_is_active" BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS "panic_triggered_at" TIMESTAMP(6),
  ADD COLUMN IF NOT EXISTS "panic_cancelled_at" TIMESTAMP(6),
  ADD COLUMN IF NOT EXISTS "panic_latitude" DECIMAL(10, 8),
  ADD COLUMN IF NOT EXISTS "panic_longitude" DECIMAL(11, 8),
  ADD COLUMN IF NOT EXISTS "panic_message" TEXT;

CREATE INDEX IF NOT EXISTS "users_panic_is_active_idx" ON "users"("panic_is_active");

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'panic_alerts'
  ) THEN
    WITH latest_panic AS (
      SELECT DISTINCT ON (user_id)
        user_id,
        is_active,
        triggered_at,
        cancelled_at,
        latitude,
        longitude,
        message
      FROM panic_alerts
      ORDER BY user_id, triggered_at DESC
    )
    UPDATE users u
    SET
      panic_is_active = p.is_active,
      panic_triggered_at = p.triggered_at,
      panic_cancelled_at = p.cancelled_at,
      panic_latitude = p.latitude,
      panic_longitude = p.longitude,
      panic_message = p.message
    FROM latest_panic p
    WHERE u.id = p.user_id;

    DROP TABLE panic_alerts;
  END IF;
END $$;
