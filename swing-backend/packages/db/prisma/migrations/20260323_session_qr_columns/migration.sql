ALTER TABLE "PracticeSession"
  ADD COLUMN IF NOT EXISTS "sessionQrCode" TEXT,
  ADD COLUMN IF NOT EXISTS "qrGeneratedAt" TIMESTAMP(3),
  ADD COLUMN IF NOT EXISTS "qrExpiresAt" TIMESTAMP(3),
  ADD COLUMN IF NOT EXISTS "qrClosedAt" TIMESTAMP(3);

CREATE UNIQUE INDEX IF NOT EXISTS "PracticeSession_sessionQrCode_key" ON "PracticeSession"("sessionQrCode");
