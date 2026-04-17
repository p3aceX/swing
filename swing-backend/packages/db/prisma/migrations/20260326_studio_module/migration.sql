-- CreateEnum
CREATE TYPE "SceneType" AS ENUM (
  'PRE_MATCH',
  'LIVE_SCORE',
  'OVER_BREAK',
  'INNINGS_BREAK',
  'AD_BREAK',
  'POST_MATCH',
  'CUSTOM'
);

-- CreateEnum
CREATE TYPE "TriggerEventType" AS ENUM (
  'MATCH_STARTED',
  'TOSS_DONE',
  'OVER_COMPLETED',
  'INNINGS_COMPLETED',
  'MATCH_COMPLETED',
  'WICKET_FALLEN'
);

-- CreateEnum
CREATE TYPE "AdSlotType" AS ENUM (
  'IMAGE',
  'VIDEO',
  'BRAND'
);

-- CreateTable
CREATE TABLE "OverlayStudio" (
  "id" TEXT NOT NULL,
  "matchId" TEXT NOT NULL,
  "activeSceneId" TEXT,
  "adBreakEnabled" BOOLEAN NOT NULL DEFAULT false,
  "adBreakDurationSeconds" INTEGER NOT NULL DEFAULT 30,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,

  CONSTRAINT "OverlayStudio_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "OverlayScene" (
  "id" TEXT NOT NULL,
  "studioId" TEXT NOT NULL,
  "name" TEXT NOT NULL,
  "sceneType" "SceneType" NOT NULL,
  "templateId" TEXT NOT NULL,
  "dataOverrides" JSONB NOT NULL DEFAULT '{}',
  "isAutomatic" BOOLEAN NOT NULL DEFAULT true,
  "displayOrder" INTEGER NOT NULL DEFAULT 0,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "OverlayScene_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "OverlayTrigger" (
  "id" TEXT NOT NULL,
  "studioId" TEXT NOT NULL,
  "eventType" "TriggerEventType" NOT NULL,
  "targetSceneId" TEXT NOT NULL,
  "delaySeconds" INTEGER NOT NULL DEFAULT 0,
  "isEnabled" BOOLEAN NOT NULL DEFAULT true,

  CONSTRAINT "OverlayTrigger_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AdSlot" (
  "id" TEXT NOT NULL,
  "studioId" TEXT NOT NULL,
  "type" "AdSlotType" NOT NULL,
  "title" TEXT NOT NULL,
  "mediaUrl" TEXT,
  "brandName" TEXT,
  "brandLogoUrl" TEXT,
  "durationSeconds" INTEGER NOT NULL,
  "displayOrder" INTEGER NOT NULL DEFAULT 0,

  CONSTRAINT "AdSlot_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "StudioAdQueue" (
  "id" TEXT NOT NULL,
  "studioId" TEXT NOT NULL,
  "adSlotId" TEXT NOT NULL,
  "displayOrder" INTEGER NOT NULL DEFAULT 0,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "StudioAdQueue_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "OverlayStudio_matchId_key" ON "OverlayStudio"("matchId");

-- CreateIndex
CREATE INDEX "OverlayStudio_matchId_idx" ON "OverlayStudio"("matchId");

-- CreateIndex
CREATE INDEX "OverlayScene_studioId_displayOrder_idx" ON "OverlayScene"("studioId", "displayOrder");

-- CreateIndex
CREATE INDEX "OverlayTrigger_studioId_eventType_idx" ON "OverlayTrigger"("studioId", "eventType");

-- CreateIndex
CREATE INDEX "AdSlot_studioId_displayOrder_idx" ON "AdSlot"("studioId", "displayOrder");

-- CreateIndex
CREATE UNIQUE INDEX "StudioAdQueue_studioId_adSlotId_key" ON "StudioAdQueue"("studioId", "adSlotId");

-- CreateIndex
CREATE INDEX "StudioAdQueue_studioId_displayOrder_idx" ON "StudioAdQueue"("studioId", "displayOrder");

-- AddForeignKey
ALTER TABLE "OverlayStudio"
ADD CONSTRAINT "OverlayStudio_matchId_fkey"
FOREIGN KEY ("matchId") REFERENCES "Match"("id")
ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OverlayStudio"
ADD CONSTRAINT "OverlayStudio_activeSceneId_fkey"
FOREIGN KEY ("activeSceneId") REFERENCES "OverlayScene"("id")
ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OverlayScene"
ADD CONSTRAINT "OverlayScene_studioId_fkey"
FOREIGN KEY ("studioId") REFERENCES "OverlayStudio"("id")
ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OverlayTrigger"
ADD CONSTRAINT "OverlayTrigger_studioId_fkey"
FOREIGN KEY ("studioId") REFERENCES "OverlayStudio"("id")
ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OverlayTrigger"
ADD CONSTRAINT "OverlayTrigger_targetSceneId_fkey"
FOREIGN KEY ("targetSceneId") REFERENCES "OverlayScene"("id")
ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AdSlot"
ADD CONSTRAINT "AdSlot_studioId_fkey"
FOREIGN KEY ("studioId") REFERENCES "OverlayStudio"("id")
ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StudioAdQueue"
ADD CONSTRAINT "StudioAdQueue_studioId_fkey"
FOREIGN KEY ("studioId") REFERENCES "OverlayStudio"("id")
ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StudioAdQueue"
ADD CONSTRAINT "StudioAdQueue_adSlotId_fkey"
FOREIGN KEY ("adSlotId") REFERENCES "AdSlot"("id")
ON DELETE CASCADE ON UPDATE CASCADE;
