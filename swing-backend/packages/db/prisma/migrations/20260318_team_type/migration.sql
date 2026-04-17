-- Add TeamType enum
DO $$ BEGIN
  CREATE TYPE "TeamType" AS ENUM (
    'CLUB', 'CORPORATE', 'ACADEMY', 'SCHOOL', 'COLLEGE',
    'DISTRICT', 'STATE', 'NATIONAL', 'FRIENDLY', 'GULLY'
  );
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- Add teamType column to Team table
ALTER TABLE "Team"
  ADD COLUMN IF NOT EXISTS "teamType" "TeamType" NOT NULL DEFAULT 'FRIENDLY';
