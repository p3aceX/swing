-- Add ON DELETE CASCADE to Innings → Match
-- This ensures all innings are deleted when a match is deleted.
ALTER TABLE "Innings" DROP CONSTRAINT IF EXISTS "Innings_matchId_fkey";
ALTER TABLE "Innings" ADD CONSTRAINT "Innings_matchId_fkey"
  FOREIGN KEY ("matchId") REFERENCES "Match"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- Add ON DELETE CASCADE to BallEvent → Innings
-- This ensures all ball events are deleted when an innings (or match) is deleted.
ALTER TABLE "BallEvent" DROP CONSTRAINT IF EXISTS "BallEvent_inningsId_fkey";
ALTER TABLE "BallEvent" ADD CONSTRAINT "BallEvent_inningsId_fkey"
  FOREIGN KEY ("inningsId") REFERENCES "Innings"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- Add ON DELETE CASCADE to PlayerMatchStats → Match
-- This ensures all player stats are deleted when a match is deleted.
ALTER TABLE "PlayerMatchStats" DROP CONSTRAINT IF EXISTS "PlayerMatchStats_matchId_fkey";
ALTER TABLE "PlayerMatchStats" ADD CONSTRAINT "PlayerMatchStats_matchId_fkey"
  FOREIGN KEY ("matchId") REFERENCES "Match"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- Add ON DELETE CASCADE to PlayerMatchStats → PlayerProfile
-- This ensures stats are cleaned up if a player profile is deleted.
ALTER TABLE "PlayerMatchStats" DROP CONSTRAINT IF EXISTS "PlayerMatchStats_playerProfileId_fkey";
ALTER TABLE "PlayerMatchStats" ADD CONSTRAINT "PlayerMatchStats_playerProfileId_fkey"
  FOREIGN KEY ("playerProfileId") REFERENCES "PlayerProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;
