-- CreateTable
CREATE TABLE "StudioScheduledSceneSwitch" (
  "id" TEXT NOT NULL,
  "studioId" TEXT NOT NULL,
  "targetSceneId" TEXT NOT NULL,
  "scheduledAt" TIMESTAMP(3) NOT NULL,
  "executedAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "StudioScheduledSceneSwitch_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "StudioScheduledSceneSwitch_scheduledAt_executedAt_idx" ON "StudioScheduledSceneSwitch"("scheduledAt", "executedAt");

-- CreateIndex
CREATE INDEX "StudioScheduledSceneSwitch_studioId_scheduledAt_idx" ON "StudioScheduledSceneSwitch"("studioId", "scheduledAt");

-- AddForeignKey
ALTER TABLE "StudioScheduledSceneSwitch"
ADD CONSTRAINT "StudioScheduledSceneSwitch_studioId_fkey"
FOREIGN KEY ("studioId") REFERENCES "OverlayStudio"("id")
ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StudioScheduledSceneSwitch"
ADD CONSTRAINT "StudioScheduledSceneSwitch_targetSceneId_fkey"
FOREIGN KEY ("targetSceneId") REFERENCES "OverlayScene"("id")
ON DELETE CASCADE ON UPDATE CASCADE;
