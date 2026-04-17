-- Fix player_wellness_checkins columns
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='player_wellness_checkins' AND column_name='confidence') THEN
        ALTER TABLE "player_wellness_checkins" ADD COLUMN "confidence" INTEGER DEFAULT 5;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='player_wellness_checkins' AND column_name='focus') THEN
        ALTER TABLE "player_wellness_checkins" ADD COLUMN "focus" INTEGER DEFAULT 5;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='player_wellness_checkins' AND column_name='resilience') THEN
        ALTER TABLE "player_wellness_checkins" ADD COLUMN "resilience" INTEGER DEFAULT 5;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='player_wellness_checkins' AND column_name='hydrationLiters') THEN
        ALTER TABLE "player_wellness_checkins" ADD COLUMN "hydrationLiters" DOUBLE PRECISION DEFAULT 0;
    END IF;
END $$;

-- Fix player_workload_events columns
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='player_workload_events' AND column_name='drillIds') THEN
        ALTER TABLE "player_workload_events" ADD COLUMN "drillIds" TEXT[] DEFAULT ARRAY[]::TEXT[];
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='player_workload_events' AND column_name='isCheatDay') THEN
        ALTER TABLE "player_workload_events" ADD COLUMN "isCheatDay" BOOLEAN DEFAULT false;
    END IF;
END $$;

-- CreateTable: elite_insights (if not exists)
CREATE TABLE IF NOT EXISTS "elite_insights" (
    "id" TEXT NOT NULL,
    "playerId" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "priority" INTEGER NOT NULL DEFAULT 1,
    "isRead" BOOLEAN NOT NULL DEFAULT false,
    "matchId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "elite_insights_pkey" PRIMARY KEY ("id")
);

-- CreateIndex (if not exists)
-- Note: Postgres doesn't have CREATE INDEX IF NOT EXISTS in very old versions, but 9.5+ has it.
CREATE INDEX IF NOT EXISTS "elite_insights_playerId_createdAt_idx" ON "elite_insights"("playerId", "createdAt");

-- AddForeignKey (wrapped in DO block to avoid errors if exists)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'elite_insights_playerId_fkey') THEN
        ALTER TABLE "elite_insights" ADD CONSTRAINT "elite_insights_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "PlayerProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END $$;
