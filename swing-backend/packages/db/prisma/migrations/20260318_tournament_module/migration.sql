-- Add TournamentFormat enum
DO $$ BEGIN
  CREATE TYPE "TournamentFormat" AS ENUM ('LEAGUE', 'KNOCKOUT', 'GROUP_STAGE_KNOCKOUT', 'DOUBLE_ELIMINATION', 'SUPER_LEAGUE');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- Add new columns to Tournament
ALTER TABLE "Tournament"
  ADD COLUMN IF NOT EXISTS "tournamentFormat" "TournamentFormat" NOT NULL DEFAULT 'LEAGUE',
  ADD COLUMN IF NOT EXISTS "groupCount" INTEGER NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS "pointsForWin" INTEGER NOT NULL DEFAULT 2,
  ADD COLUMN IF NOT EXISTS "pointsForLoss" INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS "pointsForTie" INTEGER NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS "pointsForNoResult" INTEGER NOT NULL DEFAULT 1;

-- Add new columns to TournamentTeam
ALTER TABLE "TournamentTeam"
  ADD COLUMN IF NOT EXISTS "teamId" TEXT,
  ADD COLUMN IF NOT EXISTS "groupId" TEXT,
  ADD COLUMN IF NOT EXISTS "seed" INTEGER;

-- Create Team table
CREATE TABLE IF NOT EXISTS "Team" (
  "id" TEXT NOT NULL DEFAULT gen_random_uuid(),
  "name" TEXT NOT NULL,
  "shortName" TEXT,
  "logoUrl" TEXT,
  "city" TEXT,
  "captainId" TEXT,
  "playerIds" TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
  "createdByUserId" TEXT NOT NULL,
  "isActive" BOOLEAN NOT NULL DEFAULT true,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT "Team_pkey" PRIMARY KEY ("id")
);
CREATE INDEX IF NOT EXISTS "Team_city_idx" ON "Team"("city");

-- Create TournamentGroup table
CREATE TABLE IF NOT EXISTS "TournamentGroup" (
  "id" TEXT NOT NULL DEFAULT gen_random_uuid(),
  "tournamentId" TEXT NOT NULL,
  "name" TEXT NOT NULL,
  "groupOrder" INTEGER NOT NULL DEFAULT 0,
  CONSTRAINT "TournamentGroup_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "TournamentGroup_tournamentId_fkey" FOREIGN KEY ("tournamentId") REFERENCES "Tournament"("id") ON DELETE CASCADE,
  CONSTRAINT "TournamentGroup_tournamentId_name_key" UNIQUE ("tournamentId", "name")
);

-- Create TournamentStanding table
CREATE TABLE IF NOT EXISTS "TournamentStanding" (
  "id" TEXT NOT NULL DEFAULT gen_random_uuid(),
  "tournamentId" TEXT NOT NULL,
  "groupId" TEXT,
  "tournamentTeamId" TEXT NOT NULL,
  "position" INTEGER NOT NULL DEFAULT 0,
  "played" INTEGER NOT NULL DEFAULT 0,
  "won" INTEGER NOT NULL DEFAULT 0,
  "lost" INTEGER NOT NULL DEFAULT 0,
  "tied" INTEGER NOT NULL DEFAULT 0,
  "noResult" INTEGER NOT NULL DEFAULT 0,
  "points" INTEGER NOT NULL DEFAULT 0,
  "runsScored" INTEGER NOT NULL DEFAULT 0,
  "ballsFaced" INTEGER NOT NULL DEFAULT 0,
  "runsConceded" INTEGER NOT NULL DEFAULT 0,
  "ballsBowled" INTEGER NOT NULL DEFAULT 0,
  "nrr" DOUBLE PRECISION NOT NULL DEFAULT 0,
  CONSTRAINT "TournamentStanding_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "TournamentStanding_tournamentTeamId_key" UNIQUE ("tournamentTeamId"),
  CONSTRAINT "TournamentStanding_tournamentId_fkey" FOREIGN KEY ("tournamentId") REFERENCES "Tournament"("id") ON DELETE CASCADE,
  CONSTRAINT "TournamentStanding_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "TournamentGroup"("id"),
  CONSTRAINT "TournamentStanding_tournamentTeamId_fkey" FOREIGN KEY ("tournamentTeamId") REFERENCES "TournamentTeam"("id") ON DELETE CASCADE,
  CONSTRAINT "TournamentStanding_tournamentId_tournamentTeamId_key" UNIQUE ("tournamentId", "tournamentTeamId")
);
CREATE INDEX IF NOT EXISTS "TournamentStanding_tournamentId_points_idx" ON "TournamentStanding"("tournamentId", "points" DESC);

-- FK from TournamentTeam to TournamentGroup
ALTER TABLE "TournamentTeam"
  ADD CONSTRAINT IF NOT EXISTS "TournamentTeam_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "TournamentGroup"("id");

-- FK from TournamentTeam to Team
ALTER TABLE "TournamentTeam"
  ADD CONSTRAINT IF NOT EXISTS "TournamentTeam_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES "Team"("id");
