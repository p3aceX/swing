-- Reputation tracking. Bumped on cancellation / no-show events. Initial
-- credibilityScore = 100 means every existing team starts in good standing
-- — counters only matter once a team starts cancelling.

ALTER TABLE "Team"
  ADD COLUMN "cancellationCount" INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN "lateCancelCount"   INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN "noShowCount"       INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN "credibilityScore"  INTEGER NOT NULL DEFAULT 100,
  ADD COLUMN "matchupBanUntil"   TIMESTAMP(3);

ALTER TABLE "Arena"
  ADD COLUMN "cancellationCount" INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN "noShowCount"       INTEGER NOT NULL DEFAULT 0;
