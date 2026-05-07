-- Lobby-as-persistent-supply-spec V2.
--
-- A lobby now holds RANKED arrays of preferences and tracks which time
-- windows have already been consumed by a confirmed match. The lobby
-- stays `searching` until every entry in windowsRanked has been matched,
-- at which point it flips to `matched`.
--
-- Backfill rules:
--   • windowsRanked: if the legacy `timeWindow` column was populated,
--     seed the new array with that single value. Otherwise empty.
--   • windowsMatched: always starts empty.
--
-- The legacy `timeWindow` column is intentionally NOT dropped — service
-- code now writes to the array, but the singular field stays for
-- back-compat reads on stale rows during rollout.
ALTER TABLE "MatchmakingLobby"
  ADD COLUMN "windowsRanked"  TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
  ADD COLUMN "windowsMatched" TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[];

UPDATE "MatchmakingLobby"
   SET "windowsRanked" = ARRAY["timeWindow"]::TEXT[]
 WHERE "timeWindow" IS NOT NULL
   AND ("windowsRanked" IS NULL OR cardinality("windowsRanked") = 0);
