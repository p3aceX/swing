-- Add per-team payment tracking and ground fee fields to MatchmakingMatch
ALTER TABLE "MatchmakingMatch"
  ADD COLUMN "teamAPaid" BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN "teamBPaid" BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN "teamAPaymentId" TEXT,
  ADD COLUMN "teamBPaymentId" TEXT,
  ADD COLUMN "groundFeePaise" INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN "remainingFeePaise" INTEGER NOT NULL DEFAULT 0;

-- Migrate existing pending_confirm rows to pending_payment
UPDATE "MatchmakingMatch" SET "status" = 'pending_payment' WHERE "status" = 'pending_confirm';
