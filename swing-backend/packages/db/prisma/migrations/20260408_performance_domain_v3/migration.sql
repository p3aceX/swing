-- Safe Create Enum: PerformanceDayType
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'PerformanceDayType') THEN
        CREATE TYPE "PerformanceDayType" AS ENUM ('TRAINING', 'MATCH', 'RECOVERY');
    END IF;
END $$;

-- Safe Create Enum: PerformanceSessionType
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'PerformanceSessionType') THEN
        CREATE TYPE "PerformanceSessionType" AS ENUM ('BATTING_NETS', 'BOWLING_NETS', 'FIELDING', 'GYM', 'RUNNING', 'MOBILITY', 'SHADOW_PRACTICE');
    END IF;
END $$;

-- Safe Create Enum: PerformanceSource
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'PerformanceSource') THEN
        CREATE TYPE "PerformanceSource" AS ENUM ('MANUAL', 'WEARABLE', 'COACH', 'SYSTEM', 'MATCH_ENGINE');
    END IF;
END $$;

-- Safe Create Enum: MatchSourceType
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'MatchSourceType') THEN
        CREATE TYPE "MatchSourceType" AS ENUM ('APP_MATCH', 'MANUAL_MATCH');
    END IF;
END $$;

-- CreateTable: performance_drills
CREATE TABLE IF NOT EXISTS "performance_drills" (
    "id" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "sessionType" "PerformanceSessionType" NOT NULL,
    "primarySkill" TEXT NOT NULL,
    "secondaryTags" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "difficulty" INTEGER NOT NULL DEFAULT 1,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "performance_drills_pkey" PRIMARY KEY ("id")
);

-- CreateTable: performance_metric_definitions
CREATE TABLE IF NOT EXISTS "performance_metric_definitions" (
    "id" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "label" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "description" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "performance_metric_definitions_pkey" PRIMARY KEY ("id")
);

-- CreateTable: performance_area_definitions
CREATE TABLE IF NOT EXISTS "performance_area_definitions" (
    "id" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "label" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "description" TEXT,

    CONSTRAINT "performance_area_definitions_pkey" PRIMARY KEY ("id")
);

-- CreateTable: performance_day_logs
CREATE TABLE IF NOT EXISTS "performance_day_logs" (
    "id" TEXT NOT NULL,
    "playerId" TEXT NOT NULL,
    "date" DATE NOT NULL,
    "type" "PerformanceDayType" NOT NULL,
    "dayTakeaway" TEXT,
    "isLocked" BOOLEAN NOT NULL DEFAULT false,
    "oneThingToday" TEXT,
    "whatDidWell" TEXT,
    "whatDidBadly" TEXT,
    "executionScore" DOUBLE PRECISION,
    "targetNetsMinutes" INTEGER DEFAULT 0,
    "targetDrillsMinutes" INTEGER DEFAULT 0,
    "targetGymMinutes" INTEGER DEFAULT 0,
    "targetRecoveryMinutes" INTEGER DEFAULT 0,
    "targetSleep" DOUBLE PRECISION DEFAULT 8.0,
    "targetHydration" DOUBLE PRECISION DEFAULT 3.5,
    "sleepHours" DOUBLE PRECISION,
    "sleepQuality" INTEGER,
    "hydrationLiters" DOUBLE PRECISION,
    "soreness" INTEGER,
    "fatigue" INTEGER,
    "stress" INTEGER,
    "motivation" INTEGER,
    "mentalFreshness" INTEGER,
    "readinessRating" INTEGER,
    "source" "PerformanceSource" NOT NULL DEFAULT 'MANUAL',
    "confidenceScore" DOUBLE PRECISION NOT NULL DEFAULT 1.0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "performance_day_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable: performance_sessions
CREATE TABLE IF NOT EXISTS "performance_sessions" (
    "id" TEXT NOT NULL,
    "dayLogId" TEXT NOT NULL,
    "type" "PerformanceSessionType" NOT NULL,
    "startTime" TIMESTAMP(3),
    "plannedDuration" INTEGER,
    "actualDuration" INTEGER,
    "plannedIntensity" INTEGER,
    "actualIntensity" INTEGER,
    "objective" TEXT,
    "takeaway" TEXT,
    "source" "PerformanceSource" NOT NULL DEFAULT 'MANUAL',

    CONSTRAINT "performance_sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable: performance_session_drills
CREATE TABLE IF NOT EXISTS "performance_session_drills" (
    "id" TEXT NOT NULL,
    "sessionId" TEXT NOT NULL,
    "drillId" TEXT NOT NULL,
    "plannedReps" INTEGER,
    "actualReps" INTEGER,
    "executionQuality" INTEGER,

    CONSTRAINT "performance_session_drills_pkey" PRIMARY KEY ("id")
);

-- CreateTable: performance_session_ratings
CREATE TABLE IF NOT EXISTS "performance_session_ratings" (
    "id" TEXT NOT NULL,
    "sessionId" TEXT NOT NULL,
    "metricCode" TEXT NOT NULL,
    "value" INTEGER NOT NULL,

    CONSTRAINT "performance_session_ratings_pkey" PRIMARY KEY ("id")
);

-- CreateTable: performance_match_reviews
CREATE TABLE IF NOT EXISTS "performance_match_reviews" (
    "id" TEXT NOT NULL,
    "dayLogId" TEXT NOT NULL,
    "matchSource" "MatchSourceType" NOT NULL,
    "matchId" TEXT,
    "manualMatchName" TEXT,
    "manualRuns" INTEGER,
    "manualBalls" INTEGER,
    "manualWickets" INTEGER,
    "manualOvers" DOUBLE PRECISION,
    "manualResult" TEXT,
    "role" TEXT,
    "intentCodes" TEXT[],
    "successDefinition" TEXT,
    "selfRating" INTEGER,
    "tacticalPivot" TEXT,
    "turningPoint" TEXT,

    CONSTRAINT "performance_match_reviews_pkey" PRIMARY KEY ("id")
);

-- CreateTable: performance_recovery_details
CREATE TABLE IF NOT EXISTS "performance_recovery_details" (
    "id" TEXT NOT NULL,
    "dayLogId" TEXT NOT NULL,
    "primaryActivity" TEXT NOT NULL,
    "notes" TEXT,

    CONSTRAINT "performance_recovery_details_pkey" PRIMARY KEY ("id")
);

-- CreateTable: performance_weekly_reviews
CREATE TABLE IF NOT EXISTS "performance_weekly_reviews" (
    "id" TEXT NOT NULL,
    "playerId" TEXT NOT NULL,
    "weekStartDate" DATE NOT NULL,
    "systemInsights" JSONB,
    "playerReflection" TEXT,
    "agreedWeaknesses" TEXT[],
    "nextWeekFocus" TEXT[],
    "isConfirmed" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "performance_weekly_reviews_pkey" PRIMARY KEY ("id")
);

-- CreateTable: performance_ambitions
CREATE TABLE IF NOT EXISTS "performance_ambitions" (
    "id" TEXT NOT NULL,
    "playerId" TEXT NOT NULL,
    "targetRole" TEXT NOT NULL,
    "targetFormat" TEXT NOT NULL,
    "styleIdentity" TEXT NOT NULL,
    "targetLevel" TEXT NOT NULL,
    "timeline" TEXT NOT NULL,
    "focusAreas" TEXT[],
    "commitmentStatement" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "performance_ambitions_pkey" PRIMARY KEY ("id")
);

-- CreateTable: weekly_plan_templates
CREATE TABLE IF NOT EXISTS "weekly_plan_templates" (
    "id" TEXT NOT NULL,
    "playerId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "weekly_plan_templates_pkey" PRIMARY KEY ("id")
);

-- CreateTable: weekly_plan_days
CREATE TABLE IF NOT EXISTS "weekly_plan_days" (
    "id" TEXT NOT NULL,
    "templateId" TEXT NOT NULL,
    "dayOfWeek" INTEGER NOT NULL,
    "targetNetsMinutes" INTEGER DEFAULT 0,
    "targetDrillsMinutes" INTEGER DEFAULT 0,
    "targetGymMinutes" INTEGER DEFAULT 0,
    "targetRecoveryMinutes" INTEGER DEFAULT 0,
    "targetSleep" DOUBLE PRECISION DEFAULT 8.0,
    "targetHydration" DOUBLE PRECISION DEFAULT 3.5,

    CONSTRAINT "weekly_plan_days_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX IF NOT EXISTS "performance_drills_code_key" ON "performance_drills"("code");
CREATE UNIQUE INDEX IF NOT EXISTS "performance_metric_definitions_code_key" ON "performance_metric_definitions"("code");
CREATE UNIQUE INDEX IF NOT EXISTS "performance_area_definitions_code_key" ON "performance_area_definitions"("code");
CREATE INDEX IF NOT EXISTS "performance_day_logs_playerId_date_idx" ON "performance_day_logs"("playerId", "date");
CREATE UNIQUE INDEX IF NOT EXISTS "performance_day_logs_playerId_date_key" ON "performance_day_logs"("playerId", "date");
CREATE INDEX IF NOT EXISTS "performance_sessions_dayLogId_idx" ON "performance_sessions"("dayLogId");
CREATE INDEX IF NOT EXISTS "performance_session_drills_sessionId_idx" ON "performance_session_drills"("sessionId");
CREATE INDEX IF NOT EXISTS "performance_session_ratings_sessionId_idx" ON "performance_session_ratings"("sessionId");
CREATE UNIQUE INDEX IF NOT EXISTS "performance_match_reviews_dayLogId_key" ON "performance_match_reviews"("dayLogId");
CREATE INDEX IF NOT EXISTS "performance_match_reviews_dayLogId_idx" ON "performance_match_reviews"("dayLogId");
CREATE INDEX IF NOT EXISTS "performance_match_reviews_matchId_idx" ON "performance_match_reviews"("matchId");
CREATE UNIQUE INDEX IF NOT EXISTS "performance_recovery_details_dayLogId_key" ON "performance_recovery_details"("dayLogId");
CREATE INDEX IF NOT EXISTS "performance_weekly_reviews_playerId_weekStartDate_idx" ON "performance_weekly_reviews"("playerId", "weekStartDate");
CREATE UNIQUE INDEX IF NOT EXISTS "performance_weekly_reviews_playerId_weekStartDate_key" ON "performance_weekly_reviews"("playerId", "weekStartDate");
CREATE UNIQUE INDEX IF NOT EXISTS "performance_ambitions_playerId_key" ON "performance_ambitions"("playerId");
CREATE INDEX IF NOT EXISTS "weekly_plan_templates_playerId_idx" ON "weekly_plan_templates"("playerId");
CREATE UNIQUE INDEX IF NOT EXISTS "weekly_plan_days_templateId_dayOfWeek_key" ON "weekly_plan_days"("templateId", "dayOfWeek");

-- Foreign Keys (wrapped in DO blocks for safety)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'performance_day_logs_playerId_fkey') THEN
        ALTER TABLE "performance_day_logs" ADD CONSTRAINT "performance_day_logs_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "PlayerProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'performance_sessions_dayLogId_fkey') THEN
        ALTER TABLE "performance_sessions" ADD CONSTRAINT "performance_sessions_dayLogId_fkey" FOREIGN KEY ("dayLogId") REFERENCES "performance_day_logs"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'performance_session_drills_sessionId_fkey') THEN
        ALTER TABLE "performance_session_drills" ADD CONSTRAINT "performance_session_drills_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "performance_sessions"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'performance_session_drills_drillId_fkey') THEN
        ALTER TABLE "performance_session_drills" ADD CONSTRAINT "performance_session_drills_drillId_fkey" FOREIGN KEY ("drillId") REFERENCES "performance_drills"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'performance_session_ratings_sessionId_fkey') THEN
        ALTER TABLE "performance_session_ratings" ADD CONSTRAINT "performance_session_ratings_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "performance_sessions"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'performance_session_ratings_metricCode_fkey') THEN
        ALTER TABLE "performance_session_ratings" ADD CONSTRAINT "performance_session_ratings_metricCode_fkey" FOREIGN KEY ("metricCode") REFERENCES "performance_metric_definitions"("code") ON DELETE RESTRICT ON UPDATE CASCADE;
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'performance_match_reviews_dayLogId_fkey') THEN
        ALTER TABLE "performance_match_reviews" ADD CONSTRAINT "performance_match_reviews_dayLogId_fkey" FOREIGN KEY ("dayLogId") REFERENCES "performance_day_logs"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'performance_match_reviews_matchId_fkey') THEN
        ALTER TABLE "performance_match_reviews" ADD CONSTRAINT "performance_match_reviews_matchId_fkey" FOREIGN KEY ("matchId") REFERENCES "Match"("id") ON DELETE SET NULL ON UPDATE CASCADE;
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'performance_recovery_details_dayLogId_fkey') THEN
        ALTER TABLE "performance_recovery_details" ADD CONSTRAINT "performance_recovery_details_dayLogId_fkey" FOREIGN KEY ("dayLogId") REFERENCES "performance_day_logs"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'performance_weekly_reviews_playerId_fkey') THEN
        ALTER TABLE "performance_weekly_reviews" ADD CONSTRAINT "performance_weekly_reviews_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "PlayerProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'performance_ambitions_playerId_fkey') THEN
        ALTER TABLE "performance_ambitions" ADD CONSTRAINT "performance_ambitions_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "PlayerProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'weekly_plan_templates_playerId_fkey') THEN
        ALTER TABLE "weekly_plan_templates" ADD CONSTRAINT "weekly_plan_templates_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "PlayerProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'weekly_plan_days_templateId_fkey') THEN
        ALTER TABLE "weekly_plan_days" ADD CONSTRAINT "weekly_plan_days_templateId_fkey" FOREIGN KEY ("templateId") REFERENCES "weekly_plan_templates"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END $$;
