-- Add activeScorerId to Match
ALTER TABLE "Match" ADD COLUMN "activeScorerId" TEXT;

-- Create MatchRoleType enum
CREATE TYPE "MatchRoleType" AS ENUM ('OWNER', 'MANAGER', 'SCORER');

-- Create MatchRole table
CREATE TABLE "MatchRole" (
  "id"        TEXT NOT NULL,
  "matchId"   TEXT NOT NULL,
  "profileId" TEXT NOT NULL,
  "role"      "MatchRoleType" NOT NULL,
  "grantedBy" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "MatchRole_pkey" PRIMARY KEY ("id")
);

-- Unique constraint: one role per person per match
ALTER TABLE "MatchRole" ADD CONSTRAINT "MatchRole_matchId_profileId_role_key"
  UNIQUE ("matchId", "profileId", "role");

-- Foreign keys
ALTER TABLE "MatchRole" ADD CONSTRAINT "MatchRole_matchId_fkey"
  FOREIGN KEY ("matchId") REFERENCES "Match"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "MatchRole" ADD CONSTRAINT "MatchRole_profileId_fkey"
  FOREIGN KEY ("profileId") REFERENCES "PlayerProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- Indexes
CREATE INDEX "MatchRole_matchId_role_idx" ON "MatchRole"("matchId", "role");
CREATE INDEX "MatchRole_profileId_role_idx" ON "MatchRole"("profileId", "role");
