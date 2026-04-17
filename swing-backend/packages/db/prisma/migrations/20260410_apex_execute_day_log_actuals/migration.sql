-- Phase 3 (Apex Execute): store day-level actual execution values on performance_day_logs

ALTER TABLE "performance_day_logs"
  ADD COLUMN IF NOT EXISTS "actualNetsMinutes" INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS "actualDrillsMinutes" INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS "actualFitnessMinutes" INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS "actualRecoveryMinutes" INTEGER NOT NULL DEFAULT 0;
