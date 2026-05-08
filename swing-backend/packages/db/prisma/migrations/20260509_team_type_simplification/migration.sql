-- Migration: simplify TeamType from 10 enum values to 5 categories.
-- Mapping:
--   SCHOOL, COLLEGE                    → SCHOOL
--   CLUB, ACADEMY, FRIENDLY            → CLUB_ACADEMY
--   CORPORATE                          → CORPORATE
--   GULLY                              → GULLY
--   DISTRICT, STATE, NATIONAL          → ASSOCIATION
--
-- Postgres can't drop enum values that are still part of the type, so
-- we rename the old enum, create a fresh one with the 5 new values, and
-- ALTER the column with a USING clause that performs the remap inline.

BEGIN;

-- Drop the column default first so the ALTER TYPE doesn't fight it.
ALTER TABLE "Team" ALTER COLUMN "teamType" DROP DEFAULT;

-- Rename the old type out of the way.
ALTER TYPE "TeamType" RENAME TO "TeamType_old";

-- Create the new, simplified type.
CREATE TYPE "TeamType" AS ENUM (
  'SCHOOL',
  'CLUB_ACADEMY',
  'CORPORATE',
  'GULLY',
  'ASSOCIATION'
);

-- Convert the column. The CASE expression runs once per row, mapping
-- every old value to its new category.
ALTER TABLE "Team"
  ALTER COLUMN "teamType" TYPE "TeamType"
  USING (
    CASE "teamType"::text
      WHEN 'SCHOOL'    THEN 'SCHOOL'::"TeamType"
      WHEN 'COLLEGE'   THEN 'SCHOOL'::"TeamType"
      WHEN 'CLUB'      THEN 'CLUB_ACADEMY'::"TeamType"
      WHEN 'ACADEMY'   THEN 'CLUB_ACADEMY'::"TeamType"
      WHEN 'FRIENDLY'  THEN 'CLUB_ACADEMY'::"TeamType"
      WHEN 'CORPORATE' THEN 'CORPORATE'::"TeamType"
      WHEN 'GULLY'     THEN 'GULLY'::"TeamType"
      WHEN 'DISTRICT'  THEN 'ASSOCIATION'::"TeamType"
      WHEN 'STATE'     THEN 'ASSOCIATION'::"TeamType"
      WHEN 'NATIONAL'  THEN 'ASSOCIATION'::"TeamType"
      ELSE 'CLUB_ACADEMY'::"TeamType"
    END
  );

-- Restore the default — now pointing at a value the new type knows about.
ALTER TABLE "Team" ALTER COLUMN "teamType" SET DEFAULT 'CLUB_ACADEMY'::"TeamType";

-- Old type is unreferenced now; clean it up.
DROP TYPE "TeamType_old";

COMMIT;
