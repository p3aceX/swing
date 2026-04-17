-- Add boundarySize to ArenaUnit (nullable, in yards, for full/half grounds)
ALTER TABLE "public"."ArenaUnit" ADD COLUMN IF NOT EXISTS "boundarySize" INTEGER;
