-- Team gender + mandatory ageGroup. Existing rows backfill to MIXED / OPEN
-- so we can safely flip ageGroup to NOT NULL without losing any teams.

CREATE TYPE "Gender" AS ENUM ('MALE', 'FEMALE', 'MIXED');

ALTER TABLE "Team"
  ADD COLUMN "gender" "Gender" NOT NULL DEFAULT 'MIXED';

UPDATE "Team" SET "ageGroup" = 'OPEN' WHERE "ageGroup" IS NULL;

ALTER TABLE "Team"
  ALTER COLUMN "ageGroup" SET NOT NULL,
  ALTER COLUMN "ageGroup" SET DEFAULT 'OPEN';
