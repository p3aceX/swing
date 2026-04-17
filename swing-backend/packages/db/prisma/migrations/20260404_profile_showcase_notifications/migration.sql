-- ============================================================
-- Migration: profile_showcase_notifications
-- Adds profile showcase items and per-user notification
-- preferences for social profile and inbox surfaces.
-- ============================================================

CREATE TYPE "ProfileShowcaseItemType" AS ENUM (
  'INSTAGRAM_REEL',
  'YOUTUBE_SHORT',
  'VIDEO',
  'IMAGE',
  'MATCH_HIGHLIGHT',
  'LINK'
);

CREATE TABLE "profile_showcase_items" (
  "id" TEXT NOT NULL,
  "playerProfileId" TEXT NOT NULL,
  "type" "ProfileShowcaseItemType" NOT NULL,
  "title" TEXT,
  "caption" TEXT,
  "url" TEXT NOT NULL,
  "thumbnailUrl" TEXT,
  "matchId" TEXT,
  "isPinned" BOOLEAN NOT NULL DEFAULT false,
  "isActive" BOOLEAN NOT NULL DEFAULT true,
  "sortOrder" INTEGER NOT NULL DEFAULT 0,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,

  CONSTRAINT "profile_showcase_items_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "profile_showcase_items_playerProfileId_fkey"
    FOREIGN KEY ("playerProfileId") REFERENCES "PlayerProfile"("id")
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT "profile_showcase_items_matchId_fkey"
    FOREIGN KEY ("matchId") REFERENCES "Match"("id")
    ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE INDEX "profile_showcase_items_playerProfileId_isPinned_sortOrder_createdAt_idx"
  ON "profile_showcase_items"("playerProfileId", "isPinned", "sortOrder", "createdAt");

CREATE INDEX "profile_showcase_items_playerProfileId_isActive_createdAt_idx"
  ON "profile_showcase_items"("playerProfileId", "isActive", "createdAt");

CREATE TABLE "notification_preferences" (
  "userId" TEXT NOT NULL,
  "pushEnabled" BOOLEAN NOT NULL DEFAULT true,
  "chatMessages" BOOLEAN NOT NULL DEFAULT true,
  "newFollowers" BOOLEAN NOT NULL DEFAULT true,
  "rankUpdates" BOOLEAN NOT NULL DEFAULT true,
  "matchResults" BOOLEAN NOT NULL DEFAULT true,
  "productAnnouncements" BOOLEAN NOT NULL DEFAULT true,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,

  CONSTRAINT "notification_preferences_pkey" PRIMARY KEY ("userId"),
  CONSTRAINT "notification_preferences_userId_fkey"
    FOREIGN KEY ("userId") REFERENCES "User"("id")
    ON DELETE CASCADE ON UPDATE CASCADE
);
