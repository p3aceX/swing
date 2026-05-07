-- Add multi-arena preference support to MatchmakingLobby. Existing
-- lobbies get an empty array; the legacy preferredArenaId field stays
-- in place so old rows don't lose data.
ALTER TABLE "MatchmakingLobby"
  ADD COLUMN "preferredArenaIds" TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[];
