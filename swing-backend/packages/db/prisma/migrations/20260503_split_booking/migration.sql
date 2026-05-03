-- Split booking support: owner-created lobbies with optional team/player

-- Make teamId and playerId nullable on MatchmakingLobby
ALTER TABLE "MatchmakingLobby" ALTER COLUMN "teamId" DROP NOT NULL;
ALTER TABLE "MatchmakingLobby" ALTER COLUMN "playerId" DROP NOT NULL;

-- Add arenaId (set for owner-created lobbies) and splitBookingId link
ALTER TABLE "MatchmakingLobby" ADD COLUMN "arenaId" TEXT;
ALTER TABLE "MatchmakingLobby" ADD COLUMN "splitBookingId" TEXT;

CREATE UNIQUE INDEX "MatchmakingLobby_splitBookingId_key" ON "MatchmakingLobby"("splitBookingId");
CREATE INDEX "MatchmakingLobby_arenaId_status_idx" ON "MatchmakingLobby"("arenaId", "status");

ALTER TABLE "MatchmakingLobby"
  ADD CONSTRAINT "MatchmakingLobby_arenaId_fkey"
  FOREIGN KEY ("arenaId") REFERENCES "Arena"("id") ON DELETE SET NULL ON UPDATE CASCADE;
