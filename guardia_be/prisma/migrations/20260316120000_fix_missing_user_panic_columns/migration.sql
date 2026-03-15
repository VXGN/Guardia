ALTER TABLE "users"
  ADD COLUMN IF NOT EXISTS "panic_is_active" BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS "panic_triggered_at" TIMESTAMP(6),
  ADD COLUMN IF NOT EXISTS "panic_cancelled_at" TIMESTAMP(6),
  ADD COLUMN IF NOT EXISTS "panic_latitude" DECIMAL(10, 8),
  ADD COLUMN IF NOT EXISTS "panic_longitude" DECIMAL(11, 8),
  ADD COLUMN IF NOT EXISTS "panic_message" TEXT;

CREATE INDEX IF NOT EXISTS "users_panic_is_active_idx" ON "users"("panic_is_active");
