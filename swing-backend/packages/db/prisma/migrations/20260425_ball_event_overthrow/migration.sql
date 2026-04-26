-- Add overthrow fields to BallEvent
-- isOverthrow: flags that the delivery resulted in overthrow runs
-- overthrowRuns: number of runs scored from the overthrow (boundary=4, or manual count)
-- Both are additive-only with safe defaults; no existing data affected.

ALTER TABLE "BallEvent" ADD COLUMN IF NOT EXISTS "isOverthrow" BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE "BallEvent" ADD COLUMN IF NOT EXISTS "overthrowRuns" INTEGER NOT NULL DEFAULT 0;
