-- Impact Player feature: track named substitutes (up to 4 per team)
-- declared with the team sheet, plus a "used" flag per side so the
-- backend can enforce the once-per-team rule for the substitution.

ALTER TABLE "Match"
  ADD COLUMN IF NOT EXISTS "namedImpactSubsTeamA" TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
  ADD COLUMN IF NOT EXISTS "namedImpactSubsTeamB" TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
  ADD COLUMN IF NOT EXISTS "impactPlayerUsedTeamA" BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS "impactPlayerUsedTeamB" BOOLEAN NOT NULL DEFAULT false;
