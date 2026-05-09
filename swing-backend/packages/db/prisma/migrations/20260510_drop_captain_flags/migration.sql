-- Tear out the captain-scoring complexity. The new model is simple:
-- whoever creates the match is the OWNER, may assign one ACTIVE SCORER,
-- and only those two can record balls. No per-app rules, no batting
-- guard, no auto-shift on toss/innings — so neither flag is needed.

ALTER TABLE "Match"
  DROP COLUMN IF EXISTS "captainScoringEnabled",
  DROP COLUMN IF EXISTS "scorerLockedByOwner";
