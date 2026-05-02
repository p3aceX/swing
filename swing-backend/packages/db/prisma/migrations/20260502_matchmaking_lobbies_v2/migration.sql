-- Matchmaking lobby flow (v2)

CREATE TABLE "MatchmakingLobby" (
  "id" TEXT NOT NULL,
  "teamId" TEXT NOT NULL,
  "playerId" TEXT NOT NULL,
  "format" TEXT NOT NULL,
  "date" DATE NOT NULL,
  "status" TEXT NOT NULL DEFAULT 'searching',
  "matchId" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "expiresAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "MatchmakingLobby_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "MatchmakingLobbyPick" (
  "id" TEXT NOT NULL,
  "lobbyId" TEXT NOT NULL,
  "groundId" TEXT NOT NULL,
  "slotTime" TEXT NOT NULL,
  "preferenceOrder" INTEGER NOT NULL DEFAULT 1,
  CONSTRAINT "MatchmakingLobbyPick_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "MatchmakingMatch" (
  "id" TEXT NOT NULL,
  "lobbyAId" TEXT NOT NULL,
  "lobbyBId" TEXT NOT NULL,
  "groundId" TEXT NOT NULL,
  "slotTime" TEXT NOT NULL,
  "date" DATE NOT NULL,
  "format" TEXT NOT NULL,
  "status" TEXT NOT NULL DEFAULT 'pending_confirm',
  "confirmDeadline" TIMESTAMP(3) NOT NULL,
  "teamAConfirmed" BOOLEAN NOT NULL DEFAULT false,
  "teamBConfirmed" BOOLEAN NOT NULL DEFAULT false,
  "paymentAmountPerTeam" INTEGER NOT NULL,
  "bookingId" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "MatchmakingMatch_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "MatchmakingMatch_lobbyAId_key" ON "MatchmakingMatch"("lobbyAId");
CREATE UNIQUE INDEX "MatchmakingMatch_lobbyBId_key" ON "MatchmakingMatch"("lobbyBId");

CREATE INDEX "MatchmakingLobby_status_date_format_idx" ON "MatchmakingLobby"("status", "date", "format");
CREATE INDEX "MatchmakingLobby_teamId_status_idx" ON "MatchmakingLobby"("teamId", "status");
CREATE INDEX "MatchmakingLobby_matchId_idx" ON "MatchmakingLobby"("matchId");

CREATE INDEX "MatchmakingLobbyPick_groundId_slotTime_idx" ON "MatchmakingLobbyPick"("groundId", "slotTime");
CREATE INDEX "MatchmakingLobbyPick_lobbyId_preferenceOrder_idx" ON "MatchmakingLobbyPick"("lobbyId", "preferenceOrder");

CREATE INDEX "MatchmakingMatch_status_confirmDeadline_idx" ON "MatchmakingMatch"("status", "confirmDeadline");
CREATE INDEX "MatchmakingMatch_date_format_groundId_slotTime_idx" ON "MatchmakingMatch"("date", "format", "groundId", "slotTime");

ALTER TABLE "MatchmakingLobby"
  ADD CONSTRAINT "MatchmakingLobby_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES "Team"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "MatchmakingLobby"
  ADD CONSTRAINT "MatchmakingLobby_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "PlayerProfile"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "MatchmakingLobbyPick"
  ADD CONSTRAINT "MatchmakingLobbyPick_lobbyId_fkey" FOREIGN KEY ("lobbyId") REFERENCES "MatchmakingLobby"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "MatchmakingLobbyPick"
  ADD CONSTRAINT "MatchmakingLobbyPick_groundId_fkey" FOREIGN KEY ("groundId") REFERENCES "ArenaUnit"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "MatchmakingMatch"
  ADD CONSTRAINT "MatchmakingMatch_groundId_fkey" FOREIGN KEY ("groundId") REFERENCES "ArenaUnit"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
