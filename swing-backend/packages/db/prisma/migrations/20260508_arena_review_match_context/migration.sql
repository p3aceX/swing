-- Match-context arena reviews. Captains rate the ground after a matchmaking
-- match concludes; reviews feed the L3 rating-weighted ground allocation.
--
-- Schema additions:
--   • Review.matchId, teamId, tags  — when set, the review belongs to a
--     specific matchmaking match and counts toward the arena's match-only
--     rating aggregates.
--   • Arena.matchRatingAvg, matchRatingCount  — Bayesian-smoothed (k=5,
--     prior=3.0). Separate from existing Arena.rating/totalRatings so
--     casual / non-match reviews don't pollute the matchmaking signal.
--
-- Idempotent: safe to run on a DB where these columns/indexes already
-- exist (no-op via IF NOT EXISTS guards where supported).

ALTER TABLE "Arena"
  ADD COLUMN IF NOT EXISTS "matchRatingAvg"   DOUBLE PRECISION NOT NULL DEFAULT 3.0,
  ADD COLUMN IF NOT EXISTS "matchRatingCount" INTEGER          NOT NULL DEFAULT 0;

ALTER TABLE "Review"
  ADD COLUMN IF NOT EXISTS "matchId" TEXT,
  ADD COLUMN IF NOT EXISTS "teamId"  TEXT,
  ADD COLUMN IF NOT EXISTS "tags"    TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[];

-- Foreign keys (separate so failures here don't roll back column adds).
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'Review_matchId_fkey'
  ) THEN
    ALTER TABLE "Review"
      ADD CONSTRAINT "Review_matchId_fkey"
      FOREIGN KEY ("matchId") REFERENCES "Match"("id")
      ON DELETE SET NULL ON UPDATE CASCADE;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'Review_teamId_fkey'
  ) THEN
    ALTER TABLE "Review"
      ADD CONSTRAINT "Review_teamId_fkey"
      FOREIGN KEY ("teamId") REFERENCES "Team"("id")
      ON DELETE SET NULL ON UPDATE CASCADE;
  END IF;
END$$;

-- Unique: one review per (matchId, teamId). NULL pair is allowed multiple
-- times (legacy non-match reviews) since Postgres treats NULLs as distinct.
CREATE UNIQUE INDEX IF NOT EXISTS "Review_matchId_teamId_key"
  ON "Review" ("matchId", "teamId");

CREATE INDEX IF NOT EXISTS "Review_arenaId_matchId_idx"
  ON "Review" ("arenaId", "matchId");
