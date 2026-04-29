ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "sourceLabels" TEXT[] DEFAULT ARRAY[]::TEXT[];
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "createdVia" TEXT;

ALTER TABLE "SlotBooking" ADD COLUMN IF NOT EXISTS "guestUserId" TEXT;
ALTER TABLE "SlotBooking" ADD COLUMN IF NOT EXISTS "guestPlayerProfileId" TEXT;
ALTER TABLE "SlotBooking" ADD COLUMN IF NOT EXISTS "guestSource" TEXT;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'SlotBooking_guestUserId_fkey'
  ) THEN
    ALTER TABLE "SlotBooking"
      ADD CONSTRAINT "SlotBooking_guestUserId_fkey"
      FOREIGN KEY ("guestUserId") REFERENCES "User"("id")
      ON DELETE SET NULL ON UPDATE CASCADE;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'SlotBooking_guestPlayerProfileId_fkey'
  ) THEN
    ALTER TABLE "SlotBooking"
      ADD CONSTRAINT "SlotBooking_guestPlayerProfileId_fkey"
      FOREIGN KEY ("guestPlayerProfileId") REFERENCES "PlayerProfile"("id")
      ON DELETE SET NULL ON UPDATE CASCADE;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS "SlotBooking_guestUserId_idx" ON "SlotBooking"("guestUserId");
CREATE INDEX IF NOT EXISTS "SlotBooking_guestPlayerProfileId_idx" ON "SlotBooking"("guestPlayerProfileId");

UPDATE "SlotBooking" b
SET
  "guestUserId" = u.id,
  "guestPlayerProfileId" = p.id,
  "guestSource" = COALESCE(b."guestSource", 'ARENA_BOOKING')
FROM "User" u
LEFT JOIN "PlayerProfile" p ON p."userId" = u.id
WHERE b."isOfflineBooking" = true
  AND b."guestPhone" IS NOT NULL
  AND regexp_replace(b."guestPhone", '[^0-9]', '', 'g') = regexp_replace(u.phone, '[^0-9]', '', 'g')
  AND b."guestUserId" IS NULL;
