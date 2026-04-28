-- Arena public page slugs
ALTER TABLE "Arena" ADD COLUMN IF NOT EXISTS "citySlug" TEXT;
ALTER TABLE "Arena" ADD COLUMN IF NOT EXISTS "arenaSlug" TEXT;
ALTER TABLE "Arena" ADD COLUMN IF NOT EXISTS "customSlug" TEXT;
ALTER TABLE "Arena" ADD COLUMN IF NOT EXISTS "isPublicPage" BOOLEAN NOT NULL DEFAULT true;

-- Backfill slugs from existing city + name
UPDATE "Arena" SET
  "citySlug" = LOWER(REGEXP_REPLACE(REGEXP_REPLACE(TRIM(city), '[^a-zA-Z0-9 ]', '', 'g'), ' +', '-', 'g')),
  "arenaSlug" = LOWER(REGEXP_REPLACE(REGEXP_REPLACE(TRIM(name), '[^a-zA-Z0-9 ]', '', 'g'), ' +', '-', 'g'))
WHERE "citySlug" IS NULL;

-- Handle duplicates: append short id suffix to later duplicates
WITH ranked AS (
  SELECT id, ROW_NUMBER() OVER (PARTITION BY "citySlug", "arenaSlug" ORDER BY "createdAt") AS rn
  FROM "Arena"
)
UPDATE "Arena" a
SET "arenaSlug" = a."arenaSlug" || '-' || SUBSTRING(a.id, 1, 6)
FROM ranked r
WHERE a.id = r.id AND r.rn > 1;

-- Partial unique indexes (only enforced when values are non-null)
CREATE UNIQUE INDEX IF NOT EXISTS "Arena_citySlug_arenaSlug_key"
  ON "Arena"("citySlug", "arenaSlug")
  WHERE "citySlug" IS NOT NULL AND "arenaSlug" IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "Arena_customSlug_key"
  ON "Arena"("customSlug")
  WHERE "customSlug" IS NOT NULL;

-- ArenaUnit bulk pricing
ALTER TABLE "ArenaUnit" ADD COLUMN IF NOT EXISTS "minBulkDays" INT;
ALTER TABLE "ArenaUnit" ADD COLUMN IF NOT EXISTS "bulkDayRatePaise" INT;

-- SlotBooking multi-day + source tracking
ALTER TABLE "SlotBooking" ADD COLUMN IF NOT EXISTS "endDate" DATE;
ALTER TABLE "SlotBooking" ADD COLUMN IF NOT EXISTS "isBulkBooking" BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE "SlotBooking" ADD COLUMN IF NOT EXISTS "bulkDayRatePaise" INT;
ALTER TABLE "SlotBooking" ADD COLUMN IF NOT EXISTS "bookingSource" TEXT NOT NULL DEFAULT 'APP';

-- NotificationPreference arena-specific columns
ALTER TABLE "notification_preferences" ADD COLUMN IF NOT EXISTS "arenaBookings" BOOLEAN NOT NULL DEFAULT true;
ALTER TABLE "notification_preferences" ADD COLUMN IF NOT EXISTS "bookingReminders" BOOLEAN NOT NULL DEFAULT true;
