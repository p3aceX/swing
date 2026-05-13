-- Custom-overs setting at the tournament level. When a tournament's
-- format is CUSTOM, this column holds the overs-per-innings value that
-- gets propagated onto every Match auto-generated for the tournament.
-- Nullable: canonical formats (T10/T20/ONE_DAY/etc.) leave it unset.

ALTER TABLE "Tournament"
  ADD COLUMN IF NOT EXISTS "customOvers" INTEGER;
