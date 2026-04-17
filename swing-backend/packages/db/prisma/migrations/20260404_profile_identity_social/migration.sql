-- ============================================================
-- Migration: profile_identity_social
-- Adds username, follower counters, and fills missing
-- competitive columns that were in schema.prisma but absent
-- from the 20260328 migration SQL.
-- ============================================================

-- 1. Player public handle (unique @username)
ALTER TABLE "PlayerProfile"
  ADD COLUMN IF NOT EXISTS "username" TEXT;

CREATE UNIQUE INDEX IF NOT EXISTS "PlayerProfile_username_key"
  ON "PlayerProfile"("username");

-- 2. Denormalised social counters (incremented/decremented by triggers
--    or service layer when follows are created / removed)
ALTER TABLE "PlayerProfile"
  ADD COLUMN IF NOT EXISTS "followersCount" INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS "followingCount"  INTEGER NOT NULL DEFAULT 0;

-- 3. Competitive columns missing from the 20260328 migration
ALTER TABLE "player_competitive_profile"
  ADD COLUMN IF NOT EXISTS "winStreak"             INTEGER   NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS "currentDivisionFloor"  INTEGER   NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS "lastRankedMatchAt"      TIMESTAMP(3),
  ADD COLUMN IF NOT EXISTS "hasPremiumPass"         BOOLEAN   NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS "premiumPassExpiresAt"   TIMESTAMP(3);

-- Index for leaderboard / social queries
CREATE INDEX IF NOT EXISTS "PlayerProfile_followersCount_idx"
  ON "PlayerProfile"("followersCount" DESC);
