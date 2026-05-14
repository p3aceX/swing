-- Penalty runs awarded by an umpire to either team. Stored outside the
-- Innings / BallEvent pipeline so a penalty awarded to the bowling side
-- doesn't have to be deferred until they bat — the scorecard sums these
-- in at read time.

CREATE TABLE "PenaltyAward" (
  "id"             TEXT PRIMARY KEY,
  "matchId"        TEXT NOT NULL,
  "awardedTo"      TEXT NOT NULL,                -- 'A' or 'B'
  "runs"           INTEGER NOT NULL,
  "reason"         TEXT,
  "inningsNumber"  INTEGER,
  "scoredAt"       TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "scorerUserId"   TEXT,
  CONSTRAINT "PenaltyAward_matchId_fkey"
    FOREIGN KEY ("matchId") REFERENCES "Match"("id") ON DELETE CASCADE
);

CREATE INDEX "PenaltyAward_matchId_awardedTo_idx" ON "PenaltyAward" ("matchId", "awardedTo");
CREATE INDEX "PenaltyAward_matchId_scoredAt_idx"  ON "PenaltyAward" ("matchId", "scoredAt");
