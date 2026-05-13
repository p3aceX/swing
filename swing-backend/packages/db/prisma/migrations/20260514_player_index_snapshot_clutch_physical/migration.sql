-- Adds the missing clutchIndex and physicalIndex columns to
-- PlayerIndexSnapshot. The swing-index calculator already emits these
-- values in `processVerifiedMatch`, but the schema didn't have the
-- columns — causing prisma.playerIndexSnapshot.createMany to throw
-- "Unknown argument" at the end of completeMatch and surface a 500
-- to the scoring client (even though the match was already marked
-- COMPLETED).

ALTER TABLE "player_index_snapshot"
  ADD COLUMN IF NOT EXISTS "clutchIndex"   DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS "physicalIndex" DOUBLE PRECISION;
