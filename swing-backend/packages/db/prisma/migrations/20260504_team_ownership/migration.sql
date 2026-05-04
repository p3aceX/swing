ALTER TABLE "Team" ADD COLUMN IF NOT EXISTS "academyId" TEXT;
ALTER TABLE "Team" ADD COLUMN IF NOT EXISTS "coachId"   TEXT;
ALTER TABLE "Team" ADD COLUMN IF NOT EXISTS "arenaId"   TEXT;

CREATE INDEX IF NOT EXISTS "Team_academyId_idx" ON "Team"("academyId");
CREATE INDEX IF NOT EXISTS "Team_coachId_idx"   ON "Team"("coachId");
CREATE INDEX IF NOT EXISTS "Team_arenaId_idx"   ON "Team"("arenaId");
