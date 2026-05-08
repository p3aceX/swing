-- Unify the matchmaking lobby model.
--
-- Player-created (preference-based) and arena-created (slot-precise) lobbies
-- now share a single shape. `windowsRanked` and `preferredArenaIds` are the
-- only persisted preference fields; the legacy singular columns
-- (`timeWindow`, `preferredArenaId`) are dropped after backfilling the new
-- arrays from existing rows + their picks.
--
-- Bucket math (mirror of bucketForSlotTime in time-windows.ts):
--   06:30–11:30 → MORNING
--   11:30–16:30 → AFTERNOON
--   16:30–20:30 → EVENING
--   20:30–23:30 → NIGHT
--   23:30–28:00 → LATE_NIGHT  (wraps past midnight; 24:00–04:00 next day)

-- 1. Drop dependent indexes that reference the columns being removed.
DROP INDEX IF EXISTS "MatchmakingLobby_status_date_format_timeWindow_idx";
DROP INDEX IF EXISTS "MatchmakingLobby_preferredArenaId_status_idx";

-- 2. Drop the FK from preferredArenaId so we can drop the column.
ALTER TABLE "MatchmakingLobby"
  DROP CONSTRAINT IF EXISTS "MatchmakingLobby_preferredArenaId_fkey";

-- 3. Backfill windowsRanked from legacy timeWindow OR earliest pick's slotTime.
--    First: rows that already have a singular timeWindow.
UPDATE "MatchmakingLobby"
   SET "windowsRanked" = ARRAY["timeWindow"]::TEXT[]
 WHERE "timeWindow" IS NOT NULL
   AND ("windowsRanked" IS NULL OR cardinality("windowsRanked") = 0);

-- Second: rows with no singular timeWindow but with at least one pick.
-- Derive the bucket from the rank-1 pick's slotTime (HH:MM).
WITH pick_seed AS (
  SELECT DISTINCT ON ("lobbyId")
    "lobbyId",
    "slotTime",
    "groundId"
  FROM "MatchmakingLobbyPick"
  ORDER BY "lobbyId", "preferenceOrder" ASC, "id" ASC
),
pick_bucket AS (
  SELECT
    p."lobbyId",
    p."slotTime",
    p."groundId",
    -- Convert HH:MM to minutes-from-midnight, then map to bucket.
    -- 06:30 = 390, 11:30 = 690, 16:30 = 990, 20:30 = 1230, 23:30 = 1410.
    CASE
      WHEN (split_part(p."slotTime", ':', 1)::int * 60
            + split_part(p."slotTime", ':', 2)::int) >= 390
       AND (split_part(p."slotTime", ':', 1)::int * 60
            + split_part(p."slotTime", ':', 2)::int) <  690 THEN 'MORNING'
      WHEN (split_part(p."slotTime", ':', 1)::int * 60
            + split_part(p."slotTime", ':', 2)::int) >= 690
       AND (split_part(p."slotTime", ':', 1)::int * 60
            + split_part(p."slotTime", ':', 2)::int) <  990 THEN 'AFTERNOON'
      WHEN (split_part(p."slotTime", ':', 1)::int * 60
            + split_part(p."slotTime", ':', 2)::int) >= 990
       AND (split_part(p."slotTime", ':', 1)::int * 60
            + split_part(p."slotTime", ':', 2)::int) < 1230 THEN 'EVENING'
      WHEN (split_part(p."slotTime", ':', 1)::int * 60
            + split_part(p."slotTime", ':', 2)::int) >= 1230
       AND (split_part(p."slotTime", ':', 1)::int * 60
            + split_part(p."slotTime", ':', 2)::int) < 1410 THEN 'NIGHT'
      ELSE 'LATE_NIGHT'
    END AS bucket
  FROM pick_seed p
)
UPDATE "MatchmakingLobby" l
   SET "windowsRanked" = ARRAY[pb.bucket]::TEXT[]
  FROM pick_bucket pb
 WHERE l."id" = pb."lobbyId"
   AND (l."windowsRanked" IS NULL OR cardinality(l."windowsRanked") = 0);

-- 4. Backfill preferredArenaIds from legacy preferredArenaId OR rank-1 pick's
--    parent arena.
UPDATE "MatchmakingLobby"
   SET "preferredArenaIds" = ARRAY["preferredArenaId"]::TEXT[]
 WHERE "preferredArenaId" IS NOT NULL
   AND ("preferredArenaIds" IS NULL OR cardinality("preferredArenaIds") = 0);

WITH pick_seed AS (
  SELECT DISTINCT ON (p."lobbyId")
    p."lobbyId",
    u."arenaId" AS arena_id
  FROM "MatchmakingLobbyPick" p
  JOIN "ArenaUnit" u ON u."id" = p."groundId"
  ORDER BY p."lobbyId", p."preferenceOrder" ASC, p."id" ASC
)
UPDATE "MatchmakingLobby" l
   SET "preferredArenaIds" = ARRAY[ps.arena_id]::TEXT[]
  FROM pick_seed ps
 WHERE l."id" = ps."lobbyId"
   AND ps.arena_id IS NOT NULL
   AND (l."preferredArenaIds" IS NULL OR cardinality(l."preferredArenaIds") = 0);

-- 5. Drop the legacy columns. Service code no longer reads them.
ALTER TABLE "MatchmakingLobby"
  DROP COLUMN IF EXISTS "timeWindow",
  DROP COLUMN IF EXISTS "preferredArenaId";
