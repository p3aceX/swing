-- Competitive rank and diagnostic progression enums
CREATE TYPE "CompetitiveRankKey" AS ENUM (
  'ROOKIE',
  'STRIKER',
  'VANGUARD',
  'PHANTOM',
  'DOMINION',
  'ASCENDANT',
  'IMMORTAL',
  'APEX'
);

CREATE TYPE "PlayerIndexSnapshotType" AS ENUM (
  'MATCH',
  'LAST_5',
  'LAST_10',
  'SEASON',
  'LIFETIME',
  'DAILY'
);

CREATE TYPE "PhysicalSampleSourceType" AS ENUM (
  'MATCH_PROXY',
  'WEARABLE',
  'MANUAL',
  'TRAINING_DEVICE'
);

CREATE TYPE "CompetitiveResult" AS ENUM (
  'WIN',
  'LOSS',
  'TIE',
  'NO_RESULT'
);

-- Competitive seasons and cumulative player state
CREATE TABLE "competitive_seasons" (
  "id" TEXT NOT NULL,
  "name" TEXT NOT NULL,
  "startAt" TIMESTAMP(3) NOT NULL,
  "endAt" TIMESTAMP(3) NOT NULL,
  "isActive" BOOLEAN NOT NULL DEFAULT false,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "competitive_seasons_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "player_competitive_profile" (
  "playerId" TEXT NOT NULL,
  "lifetimeImpactPoints" INTEGER NOT NULL DEFAULT 0,
  "currentRankKey" "CompetitiveRankKey" NOT NULL DEFAULT 'ROOKIE',
  "currentDivision" INTEGER NOT NULL DEFAULT 3,
  "rankProgressPoints" INTEGER NOT NULL DEFAULT 0,
  "mvpCount" INTEGER NOT NULL DEFAULT 0,
  "currentSeasonId" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "player_competitive_profile_pkey" PRIMARY KEY ("playerId")
);

CREATE TABLE "player_season_progress" (
  "id" TEXT NOT NULL,
  "playerId" TEXT NOT NULL,
  "seasonId" TEXT NOT NULL,
  "seasonPoints" INTEGER NOT NULL DEFAULT 0,
  "mvpCount" INTEGER NOT NULL DEFAULT 0,
  "matchesPlayed" INTEGER NOT NULL DEFAULT 0,
  "currentLeaderboardPosition" INTEGER,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "player_season_progress_pkey" PRIMARY KEY ("id")
);

-- Match-scoped raw facts, metrics, and normalized scores
CREATE TABLE "match_player_facts" (
  "id" TEXT NOT NULL,
  "matchId" TEXT NOT NULL,
  "playerId" TEXT NOT NULL,
  "teamId" TEXT NOT NULL,
  "opponentTeamId" TEXT NOT NULL,
  "inningsNo" INTEGER,
  "battingPosition" INTEGER,
  "didBat" BOOLEAN NOT NULL DEFAULT false,
  "runs" INTEGER NOT NULL DEFAULT 0,
  "ballsFaced" INTEGER NOT NULL DEFAULT 0,
  "fours" INTEGER NOT NULL DEFAULT 0,
  "sixes" INTEGER NOT NULL DEFAULT 0,
  "dismissalType" "DismissalType",
  "wasNotOut" BOOLEAN NOT NULL DEFAULT false,
  "didBowl" BOOLEAN NOT NULL DEFAULT false,
  "ballsBowled" INTEGER NOT NULL DEFAULT 0,
  "oversBowled" DOUBLE PRECISION,
  "maidens" INTEGER NOT NULL DEFAULT 0,
  "wickets" INTEGER NOT NULL DEFAULT 0,
  "runsConceded" INTEGER NOT NULL DEFAULT 0,
  "dotBalls" INTEGER NOT NULL DEFAULT 0,
  "wides" INTEGER NOT NULL DEFAULT 0,
  "noBalls" INTEGER NOT NULL DEFAULT 0,
  "catches" INTEGER NOT NULL DEFAULT 0,
  "runOuts" INTEGER NOT NULL DEFAULT 0,
  "stumpings" INTEGER NOT NULL DEFAULT 0,
  "fieldTimeSeconds" INTEGER,
  "oversFielded" DOUBLE PRECISION,
  "isCaptain" BOOLEAN NOT NULL DEFAULT false,
  "result" "CompetitiveResult" NOT NULL,
  "matchFormat" "MatchFormat",
  "matchDate" TIMESTAMP(3) NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "match_player_facts_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "match_player_metrics" (
  "id" TEXT NOT NULL,
  "matchId" TEXT NOT NULL,
  "playerId" TEXT NOT NULL,
  "strikeRate" DOUBLE PRECISION,
  "boundaryRatePerBall" DOUBLE PRECISION,
  "boundaryRunsPct" DOUBLE PRECISION,
  "scoringContributionPct" DOUBLE PRECISION,
  "dismissalStabilityMetric" DOUBLE PRECISION,
  "pressureBattingMetric" DOUBLE PRECISION,
  "economyRate" DOUBLE PRECISION,
  "ballsPerWicket" DOUBLE PRECISION,
  "dotBallPct" DOUBLE PRECISION,
  "wicketContributionPct" DOUBLE PRECISION,
  "spellQualityMetric" DOUBLE PRECISION,
  "phaseDifficultyMetric" DOUBLE PRECISION,
  "fieldingInvolvementMetric" DOUBLE PRECISION,
  "physicalWorkloadMetric" DOUBLE PRECISION,
  "captaincyInfluenceMetric" DOUBLE PRECISION,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "match_player_metrics_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "match_player_index_scores" (
  "id" TEXT NOT NULL,
  "matchId" TEXT NOT NULL,
  "playerId" TEXT NOT NULL,
  "battingIndex" DOUBLE PRECISION,
  "bowlingIndex" DOUBLE PRECISION,
  "fieldingIndex" DOUBLE PRECISION,
  "consistencyContribution" DOUBLE PRECISION,
  "clutchIndex" DOUBLE PRECISION,
  "physicalIndex" DOUBLE PRECISION,
  "captaincyIndex" DOUBLE PRECISION,
  "gameInfluenceIndex" DOUBLE PRECISION,
  "performanceScore" DOUBLE PRECISION NOT NULL,
  "impactPoints" INTEGER NOT NULL,
  "seasonPoints" INTEGER NOT NULL,
  "passMultiplierApplied" DOUBLE PRECISION NOT NULL DEFAULT 1,
  "isMvp" BOOLEAN NOT NULL DEFAULT false,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "match_player_index_scores_pkey" PRIMARY KEY ("id")
);

-- Fast-read aggregates and snapshots
CREATE TABLE "player_index_aggregate" (
  "playerId" TEXT NOT NULL,
  "currentBattingIndex" DOUBLE PRECISION NOT NULL DEFAULT 0,
  "currentBowlingIndex" DOUBLE PRECISION NOT NULL DEFAULT 0,
  "currentFieldingIndex" DOUBLE PRECISION NOT NULL DEFAULT 0,
  "currentConsistencyIndex" DOUBLE PRECISION NOT NULL DEFAULT 0,
  "currentClutchIndex" DOUBLE PRECISION NOT NULL DEFAULT 0,
  "currentPhysicalIndex" DOUBLE PRECISION NOT NULL DEFAULT 0,
  "currentCaptaincyIndex" DOUBLE PRECISION,
  "currentSwingIndex" DOUBLE PRECISION NOT NULL DEFAULT 0,
  "lifetimeImpactPoints" INTEGER NOT NULL DEFAULT 0,
  "currentRankKey" "CompetitiveRankKey" NOT NULL DEFAULT 'ROOKIE',
  "currentDivision" INTEGER NOT NULL DEFAULT 3,
  "rankProgressPoints" INTEGER NOT NULL DEFAULT 0,
  "mvpCount" INTEGER NOT NULL DEFAULT 0,
  "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "player_index_aggregate_pkey" PRIMARY KEY ("playerId")
);

CREATE TABLE "player_index_snapshot" (
  "id" TEXT NOT NULL,
  "playerId" TEXT NOT NULL,
  "snapshotType" "PlayerIndexSnapshotType" NOT NULL,
  "snapshotDate" TIMESTAMP(3) NOT NULL,
  "battingIndex" DOUBLE PRECISION,
  "bowlingIndex" DOUBLE PRECISION,
  "fieldingIndex" DOUBLE PRECISION,
  "consistencyIndex" DOUBLE PRECISION,
  "clutchIndex" DOUBLE PRECISION,
  "physicalIndex" DOUBLE PRECISION,
  "captaincyIndex" DOUBLE PRECISION,
  "swingIndex" DOUBLE PRECISION,
  "impactPoints" INTEGER,
  "seasonPoints" INTEGER,
  "rankKey" "CompetitiveRankKey",
  "division" INTEGER,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "player_index_snapshot_pkey" PRIMARY KEY ("id")
);

-- Physical and leadership hooks ready for future integrations
CREATE TABLE "player_physical_samples" (
  "id" TEXT NOT NULL,
  "playerId" TEXT NOT NULL,
  "sourceType" "PhysicalSampleSourceType" NOT NULL,
  "sourceRefId" TEXT,
  "sampleStartAt" TIMESTAMP(3) NOT NULL,
  "sampleEndAt" TIMESTAMP(3) NOT NULL,
  "caloriesBurned" DOUBLE PRECISION,
  "averageHeartRate" DOUBLE PRECISION,
  "maxHeartRate" DOUBLE PRECISION,
  "distanceMeters" DOUBLE PRECISION,
  "sprintCount" INTEGER,
  "activeMinutes" DOUBLE PRECISION,
  "workloadScore" DOUBLE PRECISION,
  "recoveryScore" DOUBLE PRECISION,
  "sleepHours" DOUBLE PRECISION,
  "hydrationMetric" DOUBLE PRECISION,
  "rawPayload" JSONB,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "player_physical_samples_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "player_leadership_samples" (
  "id" TEXT NOT NULL,
  "playerId" TEXT NOT NULL,
  "matchId" TEXT NOT NULL,
  "wasCaptain" BOOLEAN NOT NULL DEFAULT false,
  "teamWin" BOOLEAN NOT NULL DEFAULT false,
  "closeMatch" BOOLEAN NOT NULL DEFAULT false,
  "chaseMatch" BOOLEAN NOT NULL DEFAULT false,
  "captaincyInfluenceScore" DOUBLE PRECISION,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "player_leadership_samples_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "player_season_progress_playerId_seasonId_key" ON "player_season_progress"("playerId", "seasonId");
CREATE UNIQUE INDEX "match_player_facts_matchId_playerId_key" ON "match_player_facts"("matchId", "playerId");
CREATE UNIQUE INDEX "match_player_metrics_matchId_playerId_key" ON "match_player_metrics"("matchId", "playerId");
CREATE UNIQUE INDEX "match_player_index_scores_matchId_playerId_key" ON "match_player_index_scores"("matchId", "playerId");
CREATE UNIQUE INDEX "player_leadership_samples_matchId_playerId_key" ON "player_leadership_samples"("matchId", "playerId");

CREATE INDEX "competitive_seasons_isActive_startAt_endAt_idx" ON "competitive_seasons"("isActive", "startAt", "endAt");
CREATE INDEX "player_competitive_profile_currentRankKey_currentDivision_idx" ON "player_competitive_profile"("currentRankKey", "currentDivision");
CREATE INDEX "player_competitive_profile_currentSeasonId_idx" ON "player_competitive_profile"("currentSeasonId");
CREATE INDEX "player_season_progress_seasonId_seasonPoints_idx" ON "player_season_progress"("seasonId", "seasonPoints");
CREATE INDEX "match_player_facts_playerId_matchDate_idx" ON "match_player_facts"("playerId", "matchDate");
CREATE INDEX "match_player_metrics_playerId_createdAt_idx" ON "match_player_metrics"("playerId", "createdAt");
CREATE INDEX "match_player_index_scores_playerId_createdAt_idx" ON "match_player_index_scores"("playerId", "createdAt");
CREATE INDEX "match_player_index_scores_matchId_impactPoints_idx" ON "match_player_index_scores"("matchId", "impactPoints");
CREATE INDEX "player_index_snapshot_playerId_snapshotType_snapshotDate_idx" ON "player_index_snapshot"("playerId", "snapshotType", "snapshotDate");
CREATE INDEX "player_physical_samples_playerId_sourceType_sampleStartAt_idx" ON "player_physical_samples"("playerId", "sourceType", "sampleStartAt");
CREATE INDEX "player_physical_samples_sourceRefId_idx" ON "player_physical_samples"("sourceRefId");
CREATE INDEX "player_leadership_samples_playerId_createdAt_idx" ON "player_leadership_samples"("playerId", "createdAt");

ALTER TABLE "player_competitive_profile"
ADD CONSTRAINT "player_competitive_profile_playerId_fkey"
FOREIGN KEY ("playerId") REFERENCES "PlayerProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "player_competitive_profile"
ADD CONSTRAINT "player_competitive_profile_currentSeasonId_fkey"
FOREIGN KEY ("currentSeasonId") REFERENCES "competitive_seasons"("id") ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "player_season_progress"
ADD CONSTRAINT "player_season_progress_playerId_fkey"
FOREIGN KEY ("playerId") REFERENCES "PlayerProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "player_season_progress"
ADD CONSTRAINT "player_season_progress_seasonId_fkey"
FOREIGN KEY ("seasonId") REFERENCES "competitive_seasons"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "match_player_facts"
ADD CONSTRAINT "match_player_facts_matchId_fkey"
FOREIGN KEY ("matchId") REFERENCES "Match"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "match_player_facts"
ADD CONSTRAINT "match_player_facts_playerId_fkey"
FOREIGN KEY ("playerId") REFERENCES "PlayerProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "match_player_metrics"
ADD CONSTRAINT "match_player_metrics_matchId_fkey"
FOREIGN KEY ("matchId") REFERENCES "Match"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "match_player_metrics"
ADD CONSTRAINT "match_player_metrics_playerId_fkey"
FOREIGN KEY ("playerId") REFERENCES "PlayerProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "match_player_index_scores"
ADD CONSTRAINT "match_player_index_scores_matchId_fkey"
FOREIGN KEY ("matchId") REFERENCES "Match"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "match_player_index_scores"
ADD CONSTRAINT "match_player_index_scores_playerId_fkey"
FOREIGN KEY ("playerId") REFERENCES "PlayerProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "player_index_aggregate"
ADD CONSTRAINT "player_index_aggregate_playerId_fkey"
FOREIGN KEY ("playerId") REFERENCES "PlayerProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "player_index_snapshot"
ADD CONSTRAINT "player_index_snapshot_playerId_fkey"
FOREIGN KEY ("playerId") REFERENCES "PlayerProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "player_physical_samples"
ADD CONSTRAINT "player_physical_samples_playerId_fkey"
FOREIGN KEY ("playerId") REFERENCES "PlayerProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "player_leadership_samples"
ADD CONSTRAINT "player_leadership_samples_playerId_fkey"
FOREIGN KEY ("playerId") REFERENCES "PlayerProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "player_leadership_samples"
ADD CONSTRAINT "player_leadership_samples_matchId_fkey"
FOREIGN KEY ("matchId") REFERENCES "Match"("id") ON DELETE CASCADE ON UPDATE CASCADE;
