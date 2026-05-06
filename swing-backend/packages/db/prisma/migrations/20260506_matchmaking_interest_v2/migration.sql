-- Plan B / V2: first-to-pay interest queue.
--
-- Multiple teams can express interest in an open MatchmakingLobby. When one
-- of them taps "Pay" we acquire a 120-second lock on the lobby so only that
-- team's Razorpay order is alive for the slot. If they pay → match created;
-- if they don't → lock expires and the slot returns to searching for the
-- other interested teams to retry.

-- ── Lobby gains lock fields ────────────────────────────────────────────────
ALTER TABLE "MatchmakingLobby"
  ADD COLUMN "lockedByInterestId" TEXT,
  ADD COLUMN "lockExpiresAt"      TIMESTAMP(3);

-- Postgres allows multiple NULLs under a UNIQUE; that's what we want — a
-- lobby is either unlocked (NULL) or locked by exactly one Interest.
CREATE UNIQUE INDEX "MatchmakingLobby_lockedByInterestId_key"
  ON "MatchmakingLobby"("lockedByInterestId");

CREATE INDEX "MatchmakingLobby_lockExpiresAt_idx"
  ON "MatchmakingLobby"("lockExpiresAt");

-- ── Interest table ─────────────────────────────────────────────────────────
CREATE TABLE "MatchmakingInterest" (
  "id"                TEXT NOT NULL,
  "lobbyId"           TEXT NOT NULL,
  "teamId"            TEXT NOT NULL,
  "playerId"          TEXT NOT NULL,
  "expressedAt"       TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "status"            TEXT NOT NULL DEFAULT 'interested',
  "razorpayOrderId"   TEXT,
  "razorpayPaymentId" TEXT,
  "paidAt"            TIMESTAMP(3),
  CONSTRAINT "MatchmakingInterest_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "MatchmakingInterest_lobbyId_teamId_key"
  ON "MatchmakingInterest"("lobbyId", "teamId");

CREATE INDEX "MatchmakingInterest_lobbyId_status_idx"
  ON "MatchmakingInterest"("lobbyId", "status");

CREATE INDEX "MatchmakingInterest_playerId_status_idx"
  ON "MatchmakingInterest"("playerId", "status");

CREATE INDEX "MatchmakingInterest_razorpayOrderId_idx"
  ON "MatchmakingInterest"("razorpayOrderId");

ALTER TABLE "MatchmakingInterest"
  ADD CONSTRAINT "MatchmakingInterest_lobbyId_fkey"
    FOREIGN KEY ("lobbyId") REFERENCES "MatchmakingLobby"("id")
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "MatchmakingInterest"
  ADD CONSTRAINT "MatchmakingInterest_teamId_fkey"
    FOREIGN KEY ("teamId") REFERENCES "Team"("id")
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "MatchmakingInterest"
  ADD CONSTRAINT "MatchmakingInterest_playerId_fkey"
    FOREIGN KEY ("playerId") REFERENCES "PlayerProfile"("id")
    ON DELETE RESTRICT ON UPDATE CASCADE;
