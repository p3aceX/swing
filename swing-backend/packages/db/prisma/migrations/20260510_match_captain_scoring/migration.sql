-- Add captainScoringEnabled flag. True by default so existing matches
-- (mostly player-created) keep the current rule: batting captain can
-- score via the batting guard. New matches stamp it from the creator's
-- activeRole — PLAYER → true, ARENA_OWNER / ACADEMY_OWNER / COACH /
-- BUSINESS_OWNER / ARENA_MANAGER → false.

ALTER TABLE "Match"
  ADD COLUMN IF NOT EXISTS "captainScoringEnabled" BOOLEAN NOT NULL DEFAULT true;
