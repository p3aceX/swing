ALTER TABLE "ArenaUnit"
  ADD COLUMN "openTime" TEXT,
  ADD COLUMN "closeTime" TEXT,
  ADD COLUMN "operatingDays" INTEGER[] NOT NULL DEFAULT '{}',
  ADD COLUMN "hasFloodlights" BOOLEAN NOT NULL DEFAULT false;
