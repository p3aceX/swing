-- Phase 3 (sticky-scorer flag): when an Owner or Manager has manually
-- assigned a SCORER, auto-shift on innings transitions must NOT overwrite
-- that assignment. Phase 4 will read this flag in autoAssignScorerForBowlingTeam.
ALTER TABLE "Match"
  ADD COLUMN "scorerLockedByOwner" BOOLEAN NOT NULL DEFAULT false;
