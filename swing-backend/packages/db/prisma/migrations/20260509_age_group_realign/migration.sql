-- ageGroup categories realign: U14, U16, U19, U23, SENIOR.
-- Old values (OPEN, U30, VETERANS) collapse into SENIOR. The U19/U23
-- buckets carry over unchanged. Corporate teams are always SENIOR
-- regardless of what the row currently holds — clamp them in the same
-- pass so we don't end up with a "U-14 Corporate" anywhere.
--
-- ageGroup is stored as a plain String column (not a Postgres enum), so
-- this is a straightforward UPDATE — no type swap, no DEFAULT dance
-- beyond pointing the new default at SENIOR for fresh rows that come in
-- without an explicit value.

UPDATE "Team"
SET "ageGroup" = 'SENIOR'
WHERE "ageGroup" IN ('OPEN', 'U30', 'VETERANS')
   OR "ageGroup" IS NULL
   OR "teamType" = 'CORPORATE';

ALTER TABLE "Team" ALTER COLUMN "ageGroup" SET DEFAULT 'SENIOR';
