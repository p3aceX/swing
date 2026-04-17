-- Phase 3 (Apex Execute rewrite): activity-based daily execution + reflections

-- Activity enums
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'PerformanceDayActivityType') THEN
    CREATE TYPE "PerformanceDayActivityType" AS ENUM (
      'NETS',
      'SKILL_WORK',
      'GYM',
      'CONDITIONING',
      'MATCH',
      'RECOVERY',
      'PROPER_DIET'
    );
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'PerformanceActivityDomain') THEN
    CREATE TYPE "PerformanceActivityDomain" AS ENUM (
      'BATTING',
      'BOWLING',
      'FIELDING',
      'FITNESS',
      'RECOVERY',
      'NUTRITION',
      'MATCH'
    );
  END IF;
END $$;

-- Weekly plan day: add activity flags
ALTER TABLE "performance_plan_days"
  ADD COLUMN IF NOT EXISTS "hasNets" BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS "hasSkillWork" BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS "hasGym" BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS "hasConditioning" BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS "hasMatch" BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS "hasRecovery" BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS "hasProperDiet" BOOLEAN NOT NULL DEFAULT false;

-- Day log: add activity-based execution fields
ALTER TABLE "performance_day_logs"
  ADD COLUMN IF NOT EXISTS "note" TEXT,
  ADD COLUMN IF NOT EXISTS "cheatDay" BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS "tookProperDiet" BOOLEAN,
  ADD COLUMN IF NOT EXISTS "skippedMeal" BOOLEAN;

-- New table: top-level activity completion state for the day
CREATE TABLE IF NOT EXISTS "performance_day_activities" (
  "id" TEXT NOT NULL,
  "dayLogId" TEXT NOT NULL,
  "activityType" "PerformanceDayActivityType" NOT NULL,
  "wasPlanned" BOOLEAN NOT NULL DEFAULT false,
  "wasCompleted" BOOLEAN NOT NULL DEFAULT false,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "performance_day_activities_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "performance_day_activities_dayLogId_activityType_key"
  ON "performance_day_activities"("dayLogId", "activityType");

CREATE INDEX IF NOT EXISTS "performance_day_activities_dayLogId_activityType_idx"
  ON "performance_day_activities"("dayLogId", "activityType");

-- New table: optional reflection details within each top-level activity
CREATE TABLE IF NOT EXISTS "performance_day_activity_details" (
  "id" TEXT NOT NULL,
  "activityId" TEXT NOT NULL,
  "domain" "PerformanceActivityDomain" NOT NULL,
  "primaryFocus" TEXT,
  "secondaryFocuses" TEXT[] DEFAULT ARRAY[]::TEXT[],
  "whatLearned" TEXT,
  "whatMissed" TEXT,
  "notes" TEXT,
  "metadata" JSONB,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "performance_day_activity_details_pkey" PRIMARY KEY ("id")
);

CREATE INDEX IF NOT EXISTS "performance_day_activity_details_activityId_idx"
  ON "performance_day_activity_details"("activityId");

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'performance_day_activities_dayLogId_fkey'
  ) THEN
    ALTER TABLE "performance_day_activities"
      ADD CONSTRAINT "performance_day_activities_dayLogId_fkey"
      FOREIGN KEY ("dayLogId") REFERENCES "performance_day_logs"("id")
      ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'performance_day_activity_details_activityId_fkey'
  ) THEN
    ALTER TABLE "performance_day_activity_details"
      ADD CONSTRAINT "performance_day_activity_details_activityId_fkey"
      FOREIGN KEY ("activityId") REFERENCES "performance_day_activities"("id")
      ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;
END $$;

-- Backfill activity rows for historical day logs to keep GET payloads compatible.
INSERT INTO "performance_day_activities" (
  "id",
  "dayLogId",
  "activityType",
  "wasPlanned",
  "wasCompleted",
  "createdAt",
  "updatedAt"
)
SELECT
  l."id" || '_' || v."activityType",
  l."id",
  v."activityType"::"PerformanceDayActivityType",
  CASE
    WHEN v."activityType" = 'NETS' THEN COALESCE(l."targetNetsMinutes", 0) > 0
    WHEN v."activityType" = 'SKILL_WORK' THEN COALESCE(l."targetDrillsMinutes", 0) > 0
    WHEN v."activityType" = 'GYM' THEN COALESCE(l."targetGymMinutes", 0) > 0
    WHEN v."activityType" = 'CONDITIONING' THEN false
    WHEN v."activityType" = 'MATCH' THEN false
    WHEN v."activityType" = 'RECOVERY' THEN COALESCE(l."targetRecoveryMinutes", 0) > 0
    WHEN v."activityType" = 'PROPER_DIET' THEN false
    ELSE false
  END AS "wasPlanned",
  CASE
    WHEN v."activityType" = 'NETS' THEN COALESCE(l."actualNetsMinutes", 0) > 0
    WHEN v."activityType" = 'SKILL_WORK' THEN COALESCE(l."actualDrillsMinutes", 0) > 0
    WHEN v."activityType" = 'GYM' THEN COALESCE(l."actualFitnessMinutes", 0) > 0
    WHEN v."activityType" = 'CONDITIONING' THEN false
    WHEN v."activityType" = 'MATCH' THEN l."type" = 'MATCH'
    WHEN v."activityType" = 'RECOVERY' THEN COALESCE(l."actualRecoveryMinutes", 0) > 0
    WHEN v."activityType" = 'PROPER_DIET' THEN COALESCE(l."tookProperDiet", false)
    ELSE false
  END AS "wasCompleted",
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
FROM "performance_day_logs" l
CROSS JOIN (
  VALUES
    ('NETS'),
    ('SKILL_WORK'),
    ('GYM'),
    ('CONDITIONING'),
    ('MATCH'),
    ('RECOVERY'),
    ('PROPER_DIET')
) AS v("activityType")
ON CONFLICT ("dayLogId", "activityType") DO NOTHING;
