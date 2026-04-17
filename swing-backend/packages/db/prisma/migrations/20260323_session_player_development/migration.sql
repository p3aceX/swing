DO $$ BEGIN
  CREATE TYPE "PracticeSessionStatus" AS ENUM ('LIVE', 'COMPLETED', 'CANCELLED');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE "AttendanceJoinMethod" AS ENUM ('QR', 'SELF_APP', 'COACH_MARKED');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE "RoleTag" AS ENUM ('BATSMAN', 'BOWLER', 'ALL_ROUNDER', 'FIELDER', 'WICKET_KEEPER');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE "WatchSeverity" AS ENUM ('MONITOR', 'URGENT');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE "DrillCategory" AS ENUM ('TECHNIQUE', 'FITNESS', 'MENTAL', 'MATCH_SIMULATION');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE "DrillTargetUnit" AS ENUM ('BALLS', 'OVERS', 'MINUTES', 'REPS', 'SESSIONS');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE "SignalOverall" AS ENUM ('LOOKING_GOOD', 'NEEDS_WORK', 'WATCH_CLOSELY');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

ALTER TABLE "PracticeSession"
  ADD COLUMN IF NOT EXISTS "status" "PracticeSessionStatus" NOT NULL DEFAULT 'LIVE',
  ADD COLUMN IF NOT EXISTS "sessionTypeConfigId" TEXT;

ALTER TABLE "SessionAttendance"
  ADD COLUMN IF NOT EXISTS "joinMethod" "AttendanceJoinMethod",
  ADD COLUMN IF NOT EXISTS "markedAt" TIMESTAMP(3);

ALTER TABLE "Drill"
  ADD COLUMN IF NOT EXISTS "roleTags" "RoleTag"[] DEFAULT ARRAY[]::"RoleTag"[],
  ADD COLUMN IF NOT EXISTS "category" "DrillCategory",
  ADD COLUMN IF NOT EXISTS "targetUnit" "DrillTargetUnit" NOT NULL DEFAULT 'REPS',
  ADD COLUMN IF NOT EXISTS "isActive" BOOLEAN NOT NULL DEFAULT true;

ALTER TABLE "DrillAssignment"
  ADD COLUMN IF NOT EXISTS "sessionId" TEXT,
  ADD COLUMN IF NOT EXISTS "coachId" TEXT,
  ADD COLUMN IF NOT EXISTS "targetQuantity" INTEGER,
  ADD COLUMN IF NOT EXISTS "targetUnit" "DrillTargetUnit",
  ADD COLUMN IF NOT EXISTS "assignedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP;

UPDATE "DrillAssignment" SET "status" = 'ACTIVE' WHERE "status" = 'PENDING';
ALTER TABLE "DrillAssignment" ALTER COLUMN "status" SET DEFAULT 'ACTIVE';

ALTER TABLE "Drill"
  ALTER COLUMN "createdById" DROP NOT NULL;

CREATE TABLE IF NOT EXISTS "SessionTypeConfig" (
  "id" TEXT NOT NULL,
  "academyId" TEXT,
  "name" TEXT NOT NULL,
  "color" TEXT NOT NULL,
  "defaultDurationMinutes" INTEGER NOT NULL DEFAULT 90,
  "isActive" BOOLEAN NOT NULL DEFAULT true,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "SessionTypeConfig_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "SessionTypeConfig_name_key" ON "SessionTypeConfig"("name");

CREATE TABLE IF NOT EXISTS "SkillArea" (
  "id" TEXT NOT NULL,
  "academyId" TEXT,
  "name" TEXT NOT NULL,
  "roleTag" "RoleTag" NOT NULL,
  "isActive" BOOLEAN NOT NULL DEFAULT true,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "SkillArea_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "WatchFlag" (
  "id" TEXT NOT NULL,
  "academyId" TEXT,
  "name" TEXT NOT NULL,
  "roleTag" "RoleTag" NOT NULL,
  "severity" "WatchSeverity" NOT NULL DEFAULT 'MONITOR',
  "description" TEXT,
  "isActive" BOOLEAN NOT NULL DEFAULT true,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "WatchFlag_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "PlayerSessionSignal" (
  "id" TEXT NOT NULL,
  "sessionId" TEXT NOT NULL,
  "playerProfileId" TEXT NOT NULL,
  "coachId" TEXT NOT NULL,
  "overallSignal" "SignalOverall",
  "strengthSkillIds" TEXT[] DEFAULT ARRAY[]::TEXT[],
  "workOnSkillIds" TEXT[] DEFAULT ARRAY[]::TEXT[],
  "watchFlagIds" TEXT[] DEFAULT ARRAY[]::TEXT[],
  "followUpInDays" INTEGER,
  "coachNote" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "PlayerSessionSignal_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "PlayerSessionSignal_sessionId_playerProfileId_key"
  ON "PlayerSessionSignal"("sessionId", "playerProfileId");
CREATE INDEX IF NOT EXISTS "PlayerSessionSignal_playerProfileId_createdAt_idx"
  ON "PlayerSessionSignal"("playerProfileId", "createdAt");

CREATE TABLE IF NOT EXISTS "DrillProgressLog" (
  "id" TEXT NOT NULL,
  "drillAssignmentId" TEXT NOT NULL,
  "playerProfileId" TEXT NOT NULL,
  "loggedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "quantityDone" INTEGER NOT NULL,
  CONSTRAINT "DrillProgressLog_pkey" PRIMARY KEY ("id")
);

CREATE INDEX IF NOT EXISTS "DrillProgressLog_drillAssignmentId_loggedAt_idx"
  ON "DrillProgressLog"("drillAssignmentId", "loggedAt");

CREATE TABLE IF NOT EXISTS "PlayerGoal" (
  "id" TEXT NOT NULL,
  "playerProfileId" TEXT NOT NULL,
  "goalText" TEXT NOT NULL,
  "progressPercent" INTEGER NOT NULL DEFAULT 0,
  "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "PlayerGoal_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "PlayerGoal_playerProfileId_key" ON "PlayerGoal"("playerProfileId");

ALTER TABLE "PracticeSession"
  ADD CONSTRAINT "PracticeSession_sessionTypeConfigId_fkey"
  FOREIGN KEY ("sessionTypeConfigId") REFERENCES "SessionTypeConfig"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "SessionTypeConfig"
  ADD CONSTRAINT "SessionTypeConfig_academyId_fkey"
  FOREIGN KEY ("academyId") REFERENCES "Academy"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "SkillArea"
  ADD CONSTRAINT "SkillArea_academyId_fkey"
  FOREIGN KEY ("academyId") REFERENCES "Academy"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "WatchFlag"
  ADD CONSTRAINT "WatchFlag_academyId_fkey"
  FOREIGN KEY ("academyId") REFERENCES "Academy"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "PlayerSessionSignal"
  ADD CONSTRAINT "PlayerSessionSignal_sessionId_fkey"
  FOREIGN KEY ("sessionId") REFERENCES "PracticeSession"("id")
  ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "PlayerSessionSignal"
  ADD CONSTRAINT "PlayerSessionSignal_playerProfileId_fkey"
  FOREIGN KEY ("playerProfileId") REFERENCES "PlayerProfile"("id")
  ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "PlayerSessionSignal"
  ADD CONSTRAINT "PlayerSessionSignal_coachId_fkey"
  FOREIGN KEY ("coachId") REFERENCES "CoachProfile"("id")
  ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "DrillAssignment"
  ADD CONSTRAINT "DrillAssignment_sessionId_fkey"
  FOREIGN KEY ("sessionId") REFERENCES "PracticeSession"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "DrillAssignment"
  ADD CONSTRAINT "DrillAssignment_coachId_fkey"
  FOREIGN KEY ("coachId") REFERENCES "CoachProfile"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "DrillProgressLog"
  ADD CONSTRAINT "DrillProgressLog_drillAssignmentId_fkey"
  FOREIGN KEY ("drillAssignmentId") REFERENCES "DrillAssignment"("id")
  ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "DrillProgressLog"
  ADD CONSTRAINT "DrillProgressLog_playerProfileId_fkey"
  FOREIGN KEY ("playerProfileId") REFERENCES "PlayerProfile"("id")
  ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "PlayerGoal"
  ADD CONSTRAINT "PlayerGoal_playerProfileId_fkey"
  FOREIGN KEY ("playerProfileId") REFERENCES "PlayerProfile"("id")
  ON DELETE CASCADE ON UPDATE CASCADE;
