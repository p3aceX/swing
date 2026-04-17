-- CreateEnum
DO $$ BEGIN
    CREATE TYPE "BodyTransformDirection" AS ENUM ('CUT', 'BULK', 'RECOMPOSE', 'MAINTAIN');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "NutritionObjective" AS ENUM ('FAT_LOSS', 'MAINTENANCE', 'MUSCLE_GAIN', 'PERFORMANCE_FUELING');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- AlterTable: PlayerProfile
ALTER TABLE "PlayerProfile" ADD COLUMN IF NOT EXISTS "gender" TEXT;
ALTER TABLE "PlayerProfile" ADD COLUMN IF NOT EXISTS "heightCm" DOUBLE PRECISION;
ALTER TABLE "PlayerProfile" ADD COLUMN IF NOT EXISTS "weightKg" DOUBLE PRECISION;

-- AlterTable: performance_plans
ALTER TABLE "performance_plans" ADD COLUMN IF NOT EXISTS "dailyCalorieTarget" INTEGER;
ALTER TABLE "performance_plans" ADD COLUMN IF NOT EXISTS "isAlignedWithAmbition" BOOLEAN DEFAULT true;
ALTER TABLE "performance_plans" ADD COLUMN IF NOT EXISTS "lastSyncedAt" TIMESTAMP(3);

-- AlterTable: performance_ambitions
ALTER TABLE "performance_ambitions" ADD COLUMN IF NOT EXISTS "gender" TEXT;
ALTER TABLE "performance_ambitions" ADD COLUMN IF NOT EXISTS "targetWeight" DOUBLE PRECISION;
ALTER TABLE "performance_ambitions" ADD COLUMN IF NOT EXISTS "bodyTransformDirection" "BodyTransformDirection";
ALTER TABLE "performance_ambitions" ADD COLUMN IF NOT EXISTS "targetBodyFatPercent" DOUBLE PRECISION;
ALTER TABLE "performance_ambitions" ADD COLUMN IF NOT EXISTS "trainingDaysPerWeek" INTEGER;
ALTER TABLE "performance_ambitions" ADD COLUMN IF NOT EXISTS "fitnessFocuses" TEXT[] DEFAULT '{}';
ALTER TABLE "performance_ambitions" ADD COLUMN IF NOT EXISTS "nutritionObjective" "NutritionObjective";
ALTER TABLE "performance_ambitions" ADD COLUMN IF NOT EXISTS "dailySleepHoursGoal" DOUBLE PRECISION;
ALTER TABLE "performance_ambitions" ADD COLUMN IF NOT EXISTS "dailyHydrationLitresGoal" DOUBLE PRECISION;
ALTER TABLE "performance_ambitions" ADD COLUMN IF NOT EXISTS "morningWakeUpTime" TEXT;
ALTER TABLE "performance_ambitions" ADD COLUMN IF NOT EXISTS "habitsToQuit" TEXT[] DEFAULT '{}';
ALTER TABLE "performance_ambitions" ADD COLUMN IF NOT EXISTS "disciplineGoals" TEXT[] DEFAULT '{}';
ALTER TABLE "performance_ambitions" ADD COLUMN IF NOT EXISTS "dailyCalorieTarget" INTEGER;
ALTER TABLE "performance_ambitions" ADD COLUMN IF NOT EXISTS "bmi" DOUBLE PRECISION;

-- AlterTable: player_index_snapshot
ALTER TABLE "player_index_snapshot" RENAME COLUMN "battingIndex" TO "reliabilityIndex";
ALTER TABLE "player_index_snapshot" RENAME COLUMN "consistencyIndex" TO "powerIndex";
ALTER TABLE "player_index_snapshot" RENAME COLUMN "clutchIndex" TO "impactIndex";
-- physicalIndex removed in logic, but let's keep the column or just ignore it.
-- We'll just rename the ones we are using.

-- AlterTable: PlayerProfile circumferences
ALTER TABLE "PlayerProfile" ADD COLUMN IF NOT EXISTS "waistCircumferenceCm" DOUBLE PRECISION;
ALTER TABLE "PlayerProfile" ADD COLUMN IF NOT EXISTS "neckCircumferenceCm" DOUBLE PRECISION;
ALTER TABLE "PlayerProfile" ADD COLUMN IF NOT EXISTS "hipCircumferenceCm" DOUBLE PRECISION;

-- AlterTable: performance_ambitions circumferences
ALTER TABLE "performance_ambitions" ADD COLUMN IF NOT EXISTS "waistCircumferenceCm" DOUBLE PRECISION;
ALTER TABLE "performance_ambitions" ADD COLUMN IF NOT EXISTS "neckCircumferenceCm" DOUBLE PRECISION;
ALTER TABLE "performance_ambitions" ADD COLUMN IF NOT EXISTS "hipCircumferenceCm" DOUBLE PRECISION;
ALTER TABLE "performance_ambitions" ADD COLUMN IF NOT EXISTS "bodyFatPercent" DOUBLE PRECISION;

-- AlterTable: performance_day_logs
ALTER TABLE "performance_day_logs" ADD COLUMN IF NOT EXISTS "caloriesConsumed" INTEGER;
ALTER TABLE "performance_day_logs" ADD COLUMN IF NOT EXISTS "waistCircumferenceCm" DOUBLE PRECISION;
ALTER TABLE "performance_day_logs" ADD COLUMN IF NOT EXISTS "neckCircumferenceCm" DOUBLE PRECISION;
ALTER TABLE "performance_day_logs" ADD COLUMN IF NOT EXISTS "hipCircumferenceCm" DOUBLE PRECISION;
ALTER TABLE "performance_day_logs" ADD COLUMN IF NOT EXISTS "bodyFatPercent" DOUBLE PRECISION;

-- AlterTable: player_wellness_checkins
ALTER TABLE "player_wellness_checkins" ADD COLUMN IF NOT EXISTS "caloriesConsumed" INTEGER;
ALTER TABLE "player_wellness_checkins" ADD COLUMN IF NOT EXISTS "waistCircumferenceCm" DOUBLE PRECISION;
ALTER TABLE "player_wellness_checkins" ADD COLUMN IF NOT EXISTS "neckCircumferenceCm" DOUBLE PRECISION;
ALTER TABLE "player_wellness_checkins" ADD COLUMN IF NOT EXISTS "hipCircumferenceCm" DOUBLE PRECISION;
ALTER TABLE "player_wellness_checkins" ADD COLUMN IF NOT EXISTS "bodyFatPercent" DOUBLE PRECISION;
