-- Discover redesign: preference-based lobbies.
--
-- Adds two NULLABLE columns to MatchmakingLobby so users can post a lobby
-- with a time-window preference and an optional preferred arena, instead of
-- exact slot picks. When NULL, the row is a legacy slot-precise lobby and
-- the existing matching logic still applies — fully backwards compatible.
--
-- timeWindow:        'MORNING' (06:00–12:00)
--                    'AFTERNOON' (12:00–18:00)
--                    'EVENING'   (18:00 → next-day 04:00)
-- preferredArenaId:  Arena.id when user wants to play only at that arena;
--                    NULL means user is open to any arena.

-- ── Columns ─────────────────────────────────────────────────────────────────
ALTER TABLE "MatchmakingLobby"
  ADD COLUMN "timeWindow"       TEXT,
  ADD COLUMN "preferredArenaId" TEXT;

-- ── FK on preferredArenaId (no cascade — arena removal shouldn't drop a
--    lobby; we just lose the constraint, which we hard-enforce at app level
--    too). ────────────────────────────────────────────────────────────────
ALTER TABLE "MatchmakingLobby"
  ADD CONSTRAINT "MatchmakingLobby_preferredArenaId_fkey"
  FOREIGN KEY ("preferredArenaId")
  REFERENCES "Arena"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;

-- ── Indexes for the new discovery query patterns ───────────────────────────
-- Composite for the "find compatible lobbies" filter:
--   WHERE status='searching' AND date=? AND format=? AND timeWindow=?
CREATE INDEX "MatchmakingLobby_status_date_format_timeWindow_idx"
  ON "MatchmakingLobby"("status", "date", "format", "timeWindow");

-- For the preferred-arena filter on the same query.
CREATE INDEX "MatchmakingLobby_preferredArenaId_status_idx"
  ON "MatchmakingLobby"("preferredArenaId", "status");
