-- Create table for persisted daily journal streak snapshots (rolling 30-day window).
CREATE TABLE "player_journal_streak_days" (
  "id" TEXT NOT NULL,
  "playerId" TEXT NOT NULL,
  "date" DATE NOT NULL,
  "hasWorkload" BOOLEAN NOT NULL DEFAULT false,
  "hasWellness" BOOLEAN NOT NULL DEFAULT false,
  "isActive" BOOLEAN NOT NULL DEFAULT false,
  "streakCount" INTEGER NOT NULL DEFAULT 0,
  "activeDaysInWindow" INTEGER NOT NULL DEFAULT 0,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "player_journal_streak_days_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "player_journal_streak_days_playerId_date_key"
ON "player_journal_streak_days"("playerId", "date");

CREATE INDEX "player_journal_streak_days_playerId_date_idx"
ON "player_journal_streak_days"("playerId", "date");

ALTER TABLE "player_journal_streak_days"
ADD CONSTRAINT "player_journal_streak_days_playerId_fkey"
FOREIGN KEY ("playerId") REFERENCES "PlayerProfile"("id")
ON DELETE CASCADE ON UPDATE CASCADE;
