-- Owner-branded microsite fields for the public arena page.
-- Drives /arena/:slug on swing-web. Owner edits these from the
-- "Microsite" section of the swing-arena app's arena profile.

ALTER TABLE "Arena"
  ADD COLUMN IF NOT EXISTS "brandColor" TEXT,
  ADD COLUMN IF NOT EXISTS "logoUrl" TEXT,
  ADD COLUMN IF NOT EXISTS "tagline" TEXT,
  ADD COLUMN IF NOT EXISTS "coverPhotoIndex" INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS "micrositeLinks" JSONB;
