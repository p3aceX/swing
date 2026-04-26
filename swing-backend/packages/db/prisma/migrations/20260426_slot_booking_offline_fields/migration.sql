ALTER TABLE "SlotBooking"
  ADD COLUMN IF NOT EXISTS "isOfflineBooking" BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS "createdByOwnerId"  TEXT,
  ADD COLUMN IF NOT EXISTS "guestName"         TEXT,
  ADD COLUMN IF NOT EXISTS "guestPhone"        TEXT,
  ADD COLUMN IF NOT EXISTS "paymentMode"       TEXT;
