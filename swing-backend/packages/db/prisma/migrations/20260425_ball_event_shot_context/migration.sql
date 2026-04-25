-- Add shot context fields to BallEvent for smart scoring insights
-- shotType: the shot played by the batter (DRIVE, PULL, CUT, SWEEP, FLICK, etc.)
-- ballLine: where the ball pitched laterally (OUTSIDE_OFF, OFF_STUMP, MIDDLE, LEG_STUMP, OUTSIDE_LEG, WIDE_OUTSIDE_OFF)
-- ballLength: pitch length of the delivery (BOUNCER, SHORT, GOOD_LENGTH, FULL, YORKER, FULL_TOSS)
-- All nullable — additive only, no existing data affected.

ALTER TABLE "BallEvent" ADD COLUMN IF NOT EXISTS "shotType" TEXT;
ALTER TABLE "BallEvent" ADD COLUMN IF NOT EXISTS "ballLine" TEXT;
ALTER TABLE "BallEvent" ADD COLUMN IF NOT EXISTS "ballLength" TEXT;
