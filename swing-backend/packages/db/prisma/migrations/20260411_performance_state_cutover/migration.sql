-- Performance state cutover:
-- 1) Ensure new state tables exist.
-- 2) Backfill from legacy tables (if present).
-- 3) Drop legacy derived tables.

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'ip_event_type') THEN
    CREATE TYPE ip_event_type AS ENUM ('EARN', 'PENALTY', 'ADJUSTMENT');
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'ip_event_source') THEN
    CREATE TYPE ip_event_source AS ENUM ('MATCH_ENGINE', 'MANUAL', 'SYSTEM');
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS public.ip_player_state (
  "playerId" TEXT PRIMARY KEY,
  "lifetimeIp" INTEGER NOT NULL DEFAULT 0,
  "currentRankKey" TEXT NOT NULL DEFAULT 'ROOKIE',
  "currentDivision" INTEGER NOT NULL DEFAULT 3,
  "rankProgressPoints" INTEGER NOT NULL DEFAULT 0,
  "currentDivisionFloor" INTEGER NOT NULL DEFAULT 0,
  "winStreak" INTEGER NOT NULL DEFAULT 0,
  "mvpCount" INTEGER NOT NULL DEFAULT 0,
  "lastRankedMatchAt" TIMESTAMPTZ,
  "currentSeasonId" TEXT,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS ip_player_state_rank_idx
  ON public.ip_player_state ("currentRankKey", "currentDivision");

CREATE INDEX IF NOT EXISTS ip_player_state_season_idx
  ON public.ip_player_state ("currentSeasonId");

CREATE TABLE IF NOT EXISTS public.ip_season_state (
  id BIGSERIAL PRIMARY KEY,
  "playerId" TEXT NOT NULL,
  "seasonId" TEXT NOT NULL,
  "seasonPoints" INTEGER NOT NULL DEFAULT 0,
  "mvpCount" INTEGER NOT NULL DEFAULT 0,
  "matchesPlayed" INTEGER NOT NULL DEFAULT 0,
  "leaderboardPosition" INTEGER,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT ip_season_state_player_season_unique UNIQUE ("playerId", "seasonId")
);

CREATE INDEX IF NOT EXISTS ip_season_state_order_idx
  ON public.ip_season_state ("seasonId", "seasonPoints" DESC, "mvpCount" DESC, "matchesPlayed" ASC);

CREATE TABLE IF NOT EXISTS public.ip_event (
  id BIGSERIAL PRIMARY KEY,
  "playerId" TEXT NOT NULL,
  "matchId" TEXT,
  "seasonId" TEXT,
  "eventType" ip_event_type,
  "source" ip_event_source NOT NULL DEFAULT 'MATCH_ENGINE',
  reason TEXT NOT NULL,
  "ipDelta" INTEGER NOT NULL DEFAULT 0,
  "ipBefore" INTEGER,
  "ipAfter" INTEGER,
  "rankBefore" TEXT,
  "rankAfter" TEXT,
  "divisionBefore" INTEGER,
  "divisionAfter" INTEGER,
  "externalRef" TEXT,
  meta JSONB NOT NULL DEFAULT '{}'::jsonb,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS ip_event_external_ref_unique
  ON public.ip_event ("externalRef")
  WHERE "externalRef" IS NOT NULL;

CREATE INDEX IF NOT EXISTS ip_event_player_created_idx
  ON public.ip_event ("playerId", "createdAt" DESC, id DESC);

CREATE INDEX IF NOT EXISTS ip_event_match_idx
  ON public.ip_event ("matchId");

CREATE TABLE IF NOT EXISTS public.swing_player_state (
  "playerId" TEXT PRIMARY KEY,
  "formulaVersion" TEXT NOT NULL DEFAULT 'swing-index-v2',
  "overallScore" DOUBLE PRECISION NOT NULL DEFAULT 0,
  "batScore" DOUBLE PRECISION NOT NULL DEFAULT 0,
  "bowlScore" DOUBLE PRECISION NOT NULL DEFAULT 0,
  "fieldingImpact" DOUBLE PRECISION NOT NULL DEFAULT 0,
  "powerScore" DOUBLE PRECISION NOT NULL DEFAULT 0,
  "impactScore" DOUBLE PRECISION NOT NULL DEFAULT 0,
  axes JSONB NOT NULL DEFAULT '{}'::jsonb,
  "subScores" JSONB NOT NULL DEFAULT '{}'::jsonb,
  "derivedMetrics" JSONB NOT NULL DEFAULT '{}'::jsonb,
  "weightingMeta" JSONB NOT NULL DEFAULT '{}'::jsonb,
  "sourceStatsVersion" TEXT,
  "sourceStatsComputedAt" TIMESTAMPTZ,
  "computedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public."PlayerStatOverall" (
  "playerId" TEXT PRIMARY KEY,
  "statsVersion" TEXT,
  "computedAt" TIMESTAMPTZ,
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "sourceCompletedMatches" INTEGER,
  "sourceFactsCount" INTEGER,
  "sourceBattingEventsCount" INTEGER,
  "sourceBowlingEventsCount" INTEGER,
  "sourceMatchCount" INTEGER,
  "matchesPlayed" INTEGER NOT NULL DEFAULT 0,
  "matchesWon" INTEGER NOT NULL DEFAULT 0,
  "mvpCount" INTEGER NOT NULL DEFAULT 0,
  "consistencyIndex" DOUBLE PRECISION NOT NULL DEFAULT 0
);

DO $$
BEGIN
  IF to_regclass('public.player_competitive_profile') IS NOT NULL THEN
    INSERT INTO public.ip_player_state (
      "playerId",
      "lifetimeIp",
      "currentRankKey",
      "currentDivision",
      "rankProgressPoints",
      "currentDivisionFloor",
      "winStreak",
      "mvpCount",
      "lastRankedMatchAt",
      "currentSeasonId",
      "createdAt",
      "updatedAt"
    )
    SELECT
      "playerId",
      "lifetimeImpactPoints",
      "currentRankKey"::text,
      "currentDivision",
      "rankProgressPoints",
      "currentDivisionFloor",
      "winStreak",
      "mvpCount",
      "lastRankedMatchAt",
      "currentSeasonId",
      "createdAt",
      "updatedAt"
    FROM public.player_competitive_profile
    ON CONFLICT ("playerId")
    DO UPDATE SET
      "lifetimeIp" = EXCLUDED."lifetimeIp",
      "currentRankKey" = EXCLUDED."currentRankKey",
      "currentDivision" = EXCLUDED."currentDivision",
      "rankProgressPoints" = EXCLUDED."rankProgressPoints",
      "currentDivisionFloor" = EXCLUDED."currentDivisionFloor",
      "winStreak" = EXCLUDED."winStreak",
      "mvpCount" = EXCLUDED."mvpCount",
      "lastRankedMatchAt" = EXCLUDED."lastRankedMatchAt",
      "currentSeasonId" = EXCLUDED."currentSeasonId",
      "updatedAt" = NOW();
  END IF;
END $$;

DO $$
BEGIN
  IF to_regclass('public.player_season_progress') IS NOT NULL THEN
    INSERT INTO public.ip_season_state (
      "playerId",
      "seasonId",
      "seasonPoints",
      "mvpCount",
      "matchesPlayed",
      "leaderboardPosition",
      "createdAt",
      "updatedAt"
    )
    SELECT
      "playerId",
      "seasonId",
      "seasonPoints",
      "mvpCount",
      "matchesPlayed",
      "currentLeaderboardPosition",
      "createdAt",
      "updatedAt"
    FROM public.player_season_progress
    ON CONFLICT ("playerId", "seasonId")
    DO UPDATE SET
      "seasonPoints" = EXCLUDED."seasonPoints",
      "mvpCount" = EXCLUDED."mvpCount",
      "matchesPlayed" = EXCLUDED."matchesPlayed",
      "leaderboardPosition" = EXCLUDED."leaderboardPosition",
      "updatedAt" = NOW();
  END IF;
END $$;

DO $$
BEGIN
  IF to_regclass('public.player_index_aggregate') IS NOT NULL THEN
    INSERT INTO public.swing_player_state (
      "playerId",
      "formulaVersion",
      "overallScore",
      "batScore",
      "bowlScore",
      "fieldingImpact",
      "powerScore",
      "impactScore",
      axes,
      "subScores",
      "derivedMetrics",
      "weightingMeta",
      "computedAt",
      "updatedAt"
    )
    SELECT
      "playerId",
      COALESCE("swingFormulaVersion", 'swing-index-v2'),
      COALESCE("currentSwingIndexScore", "currentSwingIndex", 0),
      COALESCE("swingBatScore", 0),
      COALESCE("swingBowlScore", 0),
      COALESCE("swingFieldingImpact", 0),
      COALESCE("swingPowerScore", 0),
      COALESCE("swingImpactScore", 0),
      COALESCE("swingAxes", '{}'::jsonb),
      COALESCE("swingSubScores", '{}'::jsonb),
      COALESCE("swingDerivedMetrics", '{}'::jsonb),
      COALESCE("swingWeightingMeta", '{}'::jsonb),
      NOW(),
      NOW()
    FROM public.player_index_aggregate
    ON CONFLICT ("playerId")
    DO UPDATE SET
      "formulaVersion" = EXCLUDED."formulaVersion",
      "overallScore" = EXCLUDED."overallScore",
      "batScore" = EXCLUDED."batScore",
      "bowlScore" = EXCLUDED."bowlScore",
      "fieldingImpact" = EXCLUDED."fieldingImpact",
      "powerScore" = EXCLUDED."powerScore",
      "impactScore" = EXCLUDED."impactScore",
      axes = EXCLUDED.axes,
      "subScores" = EXCLUDED."subScores",
      "derivedMetrics" = EXCLUDED."derivedMetrics",
      "weightingMeta" = EXCLUDED."weightingMeta",
      "computedAt" = EXCLUDED."computedAt",
      "updatedAt" = NOW();
  END IF;
END $$;

DO $$
BEGIN
  IF to_regclass('public."IpTransaction"') IS NOT NULL THEN
    WITH legacy_tx AS (
      SELECT
        t.id,
        t."playerProfileId",
        t."matchId",
        t.reason,
        t."ipDelta",
        t."rankBefore",
        t."rankAfter",
        t."createdAt",
        COALESCE(
          SUM(t."ipDelta") OVER (
            PARTITION BY t."playerProfileId"
            ORDER BY t."createdAt", t.id
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
          ),
          0
        )::integer AS "ipBeforeCalc",
        COALESCE(
          SUM(t."ipDelta") OVER (
            PARTITION BY t."playerProfileId"
            ORDER BY t."createdAt", t.id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
          ),
          0
        )::integer AS "ipAfterCalc",
        CASE
          WHEN t."rankBefore" ~ '^[^:]+:[0-9]+$'
            THEN split_part(t."rankBefore", ':', 2)::integer
          ELSE NULL
        END AS "divisionBeforeCalc",
        CASE
          WHEN t."rankAfter" ~ '^[^:]+:[0-9]+$'
            THEN split_part(t."rankAfter", ':', 2)::integer
          ELSE NULL
        END AS "divisionAfterCalc"
      FROM public."IpTransaction" t
    )
    INSERT INTO public.ip_event (
      "playerId",
      "matchId",
      "eventType",
      "source",
      reason,
      "ipDelta",
      "ipBefore",
      "ipAfter",
      "rankBefore",
      "rankAfter",
      "divisionBefore",
      "divisionAfter",
      "externalRef",
      meta,
      "createdAt"
    )
    SELECT
      "playerProfileId",
      CASE
        WHEN "matchId" IS NOT NULL
          AND EXISTS (
            SELECT 1
            FROM public."Match" m
            WHERE m.id = legacy_tx."matchId"
          )
          THEN "matchId"
        ELSE NULL
      END,
      CASE
        WHEN "ipDelta" > 0 THEN 'EARN'::ip_event_type
        WHEN "ipDelta" < 0 THEN 'PENALTY'::ip_event_type
        ELSE 'ADJUSTMENT'::ip_event_type
      END,
      'MATCH_ENGINE'::ip_event_source,
      reason,
      "ipDelta",
      "ipBeforeCalc",
      "ipAfterCalc",
      "rankBefore",
      "rankAfter",
      "divisionBeforeCalc",
      "divisionAfterCalc",
      CONCAT('legacy-ip-transaction:', id),
      '{}'::jsonb,
      "createdAt"
    FROM legacy_tx
    WHERE NOT EXISTS (
      SELECT 1
      FROM public.ip_event ie
      WHERE ie."externalRef" = CONCAT('legacy-ip-transaction:', legacy_tx.id)
    );
  END IF;
END $$;

DROP TABLE IF EXISTS public.player_index_aggregate CASCADE;
DROP TABLE IF EXISTS public.player_season_progress CASCADE;
DROP TABLE IF EXISTS public.player_competitive_profile CASCADE;
DROP TABLE IF EXISTS public."IpTransaction" CASCADE;
