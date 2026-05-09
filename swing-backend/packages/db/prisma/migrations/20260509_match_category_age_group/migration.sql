-- Add `category` (TeamType) and `ageGroup` to Match and Tournament so the
-- create-match / create-tournament flows can capture the squad-style category
-- (SCHOOL / CLUB_ACADEMY / CORPORATE / GULLY / ASSOCIATION) plus the age
-- bucket. matchType stays in place — matchmaking still uses it as request
-- intent (FRIENDLY vs RANKED).

-- 1. Match — add columns with safe defaults so existing rows backfill cleanly.
ALTER TABLE "Match"
  ADD COLUMN IF NOT EXISTS "category" "TeamType" NOT NULL DEFAULT 'CLUB_ACADEMY',
  ADD COLUMN IF NOT EXISTS "ageGroup" TEXT NOT NULL DEFAULT 'SENIOR';

-- 2. Tournament — same shape.
ALTER TABLE "Tournament"
  ADD COLUMN IF NOT EXISTS "category" "TeamType" NOT NULL DEFAULT 'CLUB_ACADEMY',
  ADD COLUMN IF NOT EXISTS "ageGroup" TEXT NOT NULL DEFAULT 'SENIOR';

-- 3. Backfill: map the legacy MatchType signal onto the new category column.
--    ACADEMY → CLUB_ACADEMY, CORPORATE → CORPORATE, everything else stays
--    on the CLUB_ACADEMY default set above.
UPDATE "Match"
   SET "category" = 'CORPORATE'
 WHERE "matchType" = 'CORPORATE';

UPDATE "Match"
   SET "category" = 'CLUB_ACADEMY'
 WHERE "matchType" IN ('ACADEMY', 'TOURNAMENT', 'RANKED', 'FRIENDLY');
