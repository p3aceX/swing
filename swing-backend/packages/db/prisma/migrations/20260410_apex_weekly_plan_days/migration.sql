-- Phase 2 (Apex Plan): move from frequency-based plan activities to weekday-based plan days

-- Create enum PlanWeekday (if missing)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type WHERE typname = 'PlanWeekday'
  ) THEN
    CREATE TYPE "PlanWeekday" AS ENUM ('MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN');
  END IF;
END $$;

-- Add isActive to performance_plans (if missing)
ALTER TABLE "performance_plans"
  ADD COLUMN IF NOT EXISTS "isActive" BOOLEAN NOT NULL DEFAULT true;

-- Create weekday plan table
CREATE TABLE IF NOT EXISTS "performance_plan_days" (
  "id" TEXT NOT NULL,
  "planId" TEXT NOT NULL,
  "weekday" "PlanWeekday" NOT NULL,
  "netsMinutes" INTEGER NOT NULL DEFAULT 0,
  "drillsMinutes" INTEGER NOT NULL DEFAULT 0,
  "fitnessMinutes" INTEGER NOT NULL DEFAULT 0,
  "recoveryMinutes" INTEGER NOT NULL DEFAULT 0,
  "sleepTargetHours" DOUBLE PRECISION NOT NULL DEFAULT 8.0,
  "hydrationTargetLiters" DOUBLE PRECISION NOT NULL DEFAULT 3.5,
  CONSTRAINT "performance_plan_days_pkey" PRIMARY KEY ("id")
);

-- Indexes
CREATE UNIQUE INDEX IF NOT EXISTS "performance_plan_days_planId_weekday_key"
  ON "performance_plan_days"("planId", "weekday");

CREATE INDEX IF NOT EXISTS "performance_plan_days_planId_weekday_idx"
  ON "performance_plan_days"("planId", "weekday");

-- FK
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.table_constraints
    WHERE constraint_name = 'performance_plan_days_planId_fkey'
  ) THEN
    ALTER TABLE "performance_plan_days"
      ADD CONSTRAINT "performance_plan_days_planId_fkey"
      FOREIGN KEY ("planId") REFERENCES "performance_plans"("id")
      ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;
END $$;

-- Backfill: ensure every existing plan has all 7 weekdays
INSERT INTO "performance_plan_days" (
  "id",
  "planId",
  "weekday",
  "netsMinutes",
  "drillsMinutes",
  "fitnessMinutes",
  "recoveryMinutes",
  "sleepTargetHours",
  "hydrationTargetLiters"
)
SELECT
  p."id" || '_MON',
  p."id",
  'MON'::"PlanWeekday",
  0,
  0,
  0,
  0,
  COALESCE(p."sleepTargetHours", 8.0),
  COALESCE(p."hydrationTargetLiters", 3.5)
FROM "performance_plans" p
ON CONFLICT ("planId", "weekday") DO NOTHING;

INSERT INTO "performance_plan_days" (
  "id",
  "planId",
  "weekday",
  "netsMinutes",
  "drillsMinutes",
  "fitnessMinutes",
  "recoveryMinutes",
  "sleepTargetHours",
  "hydrationTargetLiters"
)
SELECT
  p."id" || '_TUE',
  p."id",
  'TUE'::"PlanWeekday",
  0,
  0,
  0,
  0,
  COALESCE(p."sleepTargetHours", 8.0),
  COALESCE(p."hydrationTargetLiters", 3.5)
FROM "performance_plans" p
ON CONFLICT ("planId", "weekday") DO NOTHING;

INSERT INTO "performance_plan_days" (
  "id",
  "planId",
  "weekday",
  "netsMinutes",
  "drillsMinutes",
  "fitnessMinutes",
  "recoveryMinutes",
  "sleepTargetHours",
  "hydrationTargetLiters"
)
SELECT
  p."id" || '_WED',
  p."id",
  'WED'::"PlanWeekday",
  0,
  0,
  0,
  0,
  COALESCE(p."sleepTargetHours", 8.0),
  COALESCE(p."hydrationTargetLiters", 3.5)
FROM "performance_plans" p
ON CONFLICT ("planId", "weekday") DO NOTHING;

INSERT INTO "performance_plan_days" (
  "id",
  "planId",
  "weekday",
  "netsMinutes",
  "drillsMinutes",
  "fitnessMinutes",
  "recoveryMinutes",
  "sleepTargetHours",
  "hydrationTargetLiters"
)
SELECT
  p."id" || '_THU',
  p."id",
  'THU'::"PlanWeekday",
  0,
  0,
  0,
  0,
  COALESCE(p."sleepTargetHours", 8.0),
  COALESCE(p."hydrationTargetLiters", 3.5)
FROM "performance_plans" p
ON CONFLICT ("planId", "weekday") DO NOTHING;

INSERT INTO "performance_plan_days" (
  "id",
  "planId",
  "weekday",
  "netsMinutes",
  "drillsMinutes",
  "fitnessMinutes",
  "recoveryMinutes",
  "sleepTargetHours",
  "hydrationTargetLiters"
)
SELECT
  p."id" || '_FRI',
  p."id",
  'FRI'::"PlanWeekday",
  0,
  0,
  0,
  0,
  COALESCE(p."sleepTargetHours", 8.0),
  COALESCE(p."hydrationTargetLiters", 3.5)
FROM "performance_plans" p
ON CONFLICT ("planId", "weekday") DO NOTHING;

INSERT INTO "performance_plan_days" (
  "id",
  "planId",
  "weekday",
  "netsMinutes",
  "drillsMinutes",
  "fitnessMinutes",
  "recoveryMinutes",
  "sleepTargetHours",
  "hydrationTargetLiters"
)
SELECT
  p."id" || '_SAT',
  p."id",
  'SAT'::"PlanWeekday",
  0,
  0,
  0,
  0,
  COALESCE(p."sleepTargetHours", 8.0),
  COALESCE(p."hydrationTargetLiters", 3.5)
FROM "performance_plans" p
ON CONFLICT ("planId", "weekday") DO NOTHING;

INSERT INTO "performance_plan_days" (
  "id",
  "planId",
  "weekday",
  "netsMinutes",
  "drillsMinutes",
  "fitnessMinutes",
  "recoveryMinutes",
  "sleepTargetHours",
  "hydrationTargetLiters"
)
SELECT
  p."id" || '_SUN',
  p."id",
  'SUN'::"PlanWeekday",
  0,
  0,
  0,
  0,
  COALESCE(p."sleepTargetHours", 8.0),
  COALESCE(p."hydrationTargetLiters", 3.5)
FROM "performance_plans" p
ON CONFLICT ("planId", "weekday") DO NOTHING;
