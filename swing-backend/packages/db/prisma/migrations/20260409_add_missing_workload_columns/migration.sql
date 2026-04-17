-- Add missing columns to player_workload_events
-- These were in 20260408_apex_elite_journal_v3 but that migration was marked
-- as --applied without running, so the columns never landed in production.

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name='player_workload_events' AND column_name='isCheatDay') THEN
        ALTER TABLE "player_workload_events" ADD COLUMN "isCheatDay" BOOLEAN NOT NULL DEFAULT false;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name='player_workload_events' AND column_name='drillIds') THEN
        ALTER TABLE "player_workload_events" ADD COLUMN "drillIds" TEXT[] DEFAULT ARRAY[]::TEXT[];
    END IF;
END $$;

-- Add missing columns to player_wellness_checkins
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name='player_wellness_checkins' AND column_name='confidence') THEN
        ALTER TABLE "player_wellness_checkins" ADD COLUMN "confidence" INTEGER DEFAULT 5;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name='player_wellness_checkins' AND column_name='focus') THEN
        ALTER TABLE "player_wellness_checkins" ADD COLUMN "focus" INTEGER DEFAULT 5;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name='player_wellness_checkins' AND column_name='resilience') THEN
        ALTER TABLE "player_wellness_checkins" ADD COLUMN "resilience" INTEGER DEFAULT 5;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name='player_wellness_checkins' AND column_name='hydrationLiters') THEN
        ALTER TABLE "player_wellness_checkins" ADD COLUMN "hydrationLiters" DOUBLE PRECISION DEFAULT 0;
    END IF;
END $$;

-- Create elite_insights table (if not exists)
CREATE TABLE IF NOT EXISTS "elite_insights" (
    "id"        TEXT        NOT NULL,
    "playerId"  TEXT        NOT NULL,
    "category"  TEXT        NOT NULL,
    "title"     TEXT        NOT NULL,
    "message"   TEXT        NOT NULL,
    "priority"  INTEGER     NOT NULL DEFAULT 1,
    "isRead"    BOOLEAN     NOT NULL DEFAULT false,
    "matchId"   TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "elite_insights_pkey" PRIMARY KEY ("id")
);

CREATE INDEX IF NOT EXISTS "elite_insights_playerId_createdAt_idx"
    ON "elite_insights"("playerId", "createdAt");

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints
                   WHERE constraint_name = 'elite_insights_playerId_fkey') THEN
        ALTER TABLE "elite_insights"
            ADD CONSTRAINT "elite_insights_playerId_fkey"
            FOREIGN KEY ("playerId") REFERENCES "PlayerProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END $$;

-- Create performance_plans table (if not exists)
CREATE TABLE IF NOT EXISTS "performance_plans" (
    "id"                    TEXT             NOT NULL,
    "playerId"              TEXT             NOT NULL,
    "name"                  TEXT             NOT NULL,
    "sleepTargetHours"      DOUBLE PRECISION NOT NULL DEFAULT 8.0,
    "hydrationTargetLiters" DOUBLE PRECISION NOT NULL DEFAULT 3.0,
    "createdAt"             TIMESTAMP(3)     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt"             TIMESTAMP(3)     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "performance_plans_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "performance_plans_playerId_key" ON "performance_plans"("playerId");

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints
                   WHERE constraint_name = 'performance_plans_playerId_fkey') THEN
        ALTER TABLE "performance_plans"
            ADD CONSTRAINT "performance_plans_playerId_fkey"
            FOREIGN KEY ("playerId") REFERENCES "PlayerProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END $$;

-- Create performance_plan_activities table (if not exists)
CREATE TABLE IF NOT EXISTS "performance_plan_activities" (
    "id"           TEXT    NOT NULL,
    "planId"       TEXT    NOT NULL,
    "category"     TEXT    NOT NULL,
    "timesPerWeek" INTEGER NOT NULL,
    CONSTRAINT "performance_plan_activities_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "performance_plan_activities_planId_category_key"
    ON "performance_plan_activities"("planId", "category");

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints
                   WHERE constraint_name = 'performance_plan_activities_planId_fkey') THEN
        ALTER TABLE "performance_plan_activities"
            ADD CONSTRAINT "performance_plan_activities_planId_fkey"
            FOREIGN KEY ("planId") REFERENCES "performance_plans"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END $$;
