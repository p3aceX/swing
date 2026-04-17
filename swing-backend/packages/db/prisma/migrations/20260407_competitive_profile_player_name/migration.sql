-- Add playerName to player_competitive_profile for denormalised display in leaderboards / ranked lists.
ALTER TABLE "player_competitive_profile"
  ADD COLUMN IF NOT EXISTS "playerName" TEXT;

-- Back-fill from the joined user name so existing rows are not empty.
UPDATE "player_competitive_profile" pcp
SET    "playerName" = u.name
FROM   "PlayerProfile" pp
JOIN   "User" u ON u.id = pp."userId"
WHERE  pp.id = pcp."playerId"
  AND  pcp."playerName" IS NULL;
