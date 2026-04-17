-- Update PerformanceSessionType Enum
-- Note: Postgres enums are hard to change in migrations without dropping/recreating or using ALTER TYPE.
-- Since we are in development, we'll use a safe addition or recreation.
ALTER TYPE "PerformanceSessionType" RENAME TO "PerformanceSessionType_old";
CREATE TYPE "PerformanceSessionType" AS ENUM ('NETS', 'SKILL_WORK', 'CONDITIONING', 'GYM', 'MATCH', 'RECOVERY');
ALTER TABLE "performance_drills" ALTER COLUMN "sessionType" TYPE "PerformanceSessionType" USING "sessionType"::text::"PerformanceSessionType";
ALTER TABLE "performance_sessions" ALTER COLUMN "type" TYPE "PerformanceSessionType" USING "type"::text::"PerformanceSessionType";
DROP TYPE "PerformanceSessionType_old";

-- CreateTable: performance_plans
CREATE TABLE "performance_plans" (
    "id" TEXT NOT NULL,
    "playerId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "sleepTargetHours" DOUBLE PRECISION NOT NULL DEFAULT 8.0,
    "hydrationTargetLiters" DOUBLE PRECISION NOT NULL DEFAULT 3.0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "performance_plans_pkey" PRIMARY KEY ("id")
);

-- CreateTable: performance_plan_activities
CREATE TABLE "performance_plan_activities" (
    "id" TEXT NOT NULL,
    "planId" TEXT NOT NULL,
    "category" "PerformanceSessionType" NOT NULL,
    "timesPerWeek" INTEGER NOT NULL,

    CONSTRAINT "performance_plan_activities_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "performance_plans_playerId_key" ON "performance_plans"("playerId");

-- CreateIndex
CREATE UNIQUE INDEX "performance_plan_activities_planId_category_key" ON "performance_plan_activities"("planId", "category");

-- AddForeignKey
ALTER TABLE "performance_plans" ADD CONSTRAINT "performance_plans_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "PlayerProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "performance_plan_activities" ADD CONSTRAINT "performance_plan_activities_planId_fkey" FOREIGN KEY ("planId") REFERENCES "performance_plans"("id") ON DELETE CASCADE ON UPDATE CASCADE;
