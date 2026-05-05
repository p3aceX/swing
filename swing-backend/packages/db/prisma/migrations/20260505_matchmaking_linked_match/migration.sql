-- Add linkedMatchId to MatchmakingMatch so confirmed matchmaking matches
-- are linked to a real Match record (enabling scoring via the Play tab).
ALTER TABLE "MatchmakingMatch" ADD COLUMN "linkedMatchId" TEXT;
CREATE UNIQUE INDEX "MatchmakingMatch_linkedMatchId_key" ON "MatchmakingMatch"("linkedMatchId");
