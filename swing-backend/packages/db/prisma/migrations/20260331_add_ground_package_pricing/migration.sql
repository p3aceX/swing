-- Add ground package pricing fields to ArenaUnit
ALTER TABLE "public"."ArenaUnit" ADD COLUMN IF NOT EXISTS "price4HrPaise" INTEGER;
ALTER TABLE "public"."ArenaUnit" ADD COLUMN IF NOT EXISTS "price8HrPaise" INTEGER;
ALTER TABLE "public"."ArenaUnit" ADD COLUMN IF NOT EXISTS "priceFullDayPaise" INTEGER;
