ALTER TABLE "Announcement" ADD COLUMN IF NOT EXISTS "imageUrl"  TEXT;
ALTER TABLE "Announcement" ADD COLUMN IF NOT EXISTS "expiresAt" TIMESTAMP(3);
ALTER TABLE "Announcement" ADD COLUMN IF NOT EXISTS "batchId"   TEXT;

CREATE TABLE IF NOT EXISTS "AnnouncementRead" (
  "id"              TEXT NOT NULL,
  "announcementId"  TEXT NOT NULL,
  "playerProfileId" TEXT NOT NULL,
  "readAt"          TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "AnnouncementRead_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "AnnouncementRead_announcementId_playerProfileId_key"
  ON "AnnouncementRead"("announcementId", "playerProfileId");

ALTER TABLE "AnnouncementRead" DROP CONSTRAINT IF EXISTS "AnnouncementRead_announcementId_fkey";
ALTER TABLE "AnnouncementRead" ADD CONSTRAINT "AnnouncementRead_announcementId_fkey"
  FOREIGN KEY ("announcementId") REFERENCES "Announcement"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "AnnouncementRead" DROP CONSTRAINT IF EXISTS "AnnouncementRead_playerProfileId_fkey";
ALTER TABLE "AnnouncementRead" ADD CONSTRAINT "AnnouncementRead_playerProfileId_fkey"
  FOREIGN KEY ("playerProfileId") REFERENCES "PlayerProfile"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
