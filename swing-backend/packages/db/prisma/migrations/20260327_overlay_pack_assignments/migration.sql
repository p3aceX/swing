-- CreateEnum
CREATE TYPE "OverlayPackKind" AS ENUM ('DEFAULT', 'TOURNAMENT', 'CUSTOM');

-- CreateTable
CREATE TABLE "OverlayPack" (
  "id" TEXT NOT NULL,
  "code" TEXT NOT NULL,
  "name" TEXT NOT NULL,
  "kind" "OverlayPackKind" NOT NULL DEFAULT 'CUSTOM',
  "description" TEXT,
  "isActive" BOOLEAN NOT NULL DEFAULT true,
  "isDefault" BOOLEAN NOT NULL DEFAULT false,
  "config" JSONB NOT NULL DEFAULT '{}',
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,

  CONSTRAINT "OverlayPack_pkey" PRIMARY KEY ("id")
);

-- AlterTable
ALTER TABLE "Match"
ADD COLUMN "overlayPackId" TEXT;

-- AlterTable
ALTER TABLE "Tournament"
ADD COLUMN "overlayPackId" TEXT;

-- CreateIndex
CREATE UNIQUE INDEX "OverlayPack_code_key" ON "OverlayPack"("code");

-- CreateIndex
CREATE INDEX "OverlayPack_isDefault_idx" ON "OverlayPack"("isDefault");

-- CreateIndex
CREATE INDEX "OverlayPack_kind_idx" ON "OverlayPack"("kind");

-- CreateIndex
CREATE INDEX "Match_overlayPackId_idx" ON "Match"("overlayPackId");

-- CreateIndex
CREATE INDEX "Tournament_overlayPackId_idx" ON "Tournament"("overlayPackId");

-- AddForeignKey
ALTER TABLE "Match"
ADD CONSTRAINT "Match_overlayPackId_fkey"
FOREIGN KEY ("overlayPackId") REFERENCES "OverlayPack"("id")
ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Tournament"
ADD CONSTRAINT "Tournament_overlayPackId_fkey"
FOREIGN KEY ("overlayPackId") REFERENCES "OverlayPack"("id")
ON DELETE SET NULL ON UPDATE CASCADE;

-- Seed default overlay pack
INSERT INTO "OverlayPack" (
  "id",
  "code",
  "name",
  "kind",
  "description",
  "isActive",
  "isDefault",
  "config",
  "createdAt",
  "updatedAt"
) VALUES (
  'default-overlay-pack',
  'default-overlay',
  'Default Overlay',
  'DEFAULT',
  'Base overlay pack used across all Swing Live matches.',
  true,
  true,
  '{}',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
);
