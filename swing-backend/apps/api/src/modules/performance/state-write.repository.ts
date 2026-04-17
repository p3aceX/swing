import { prisma } from '@swing/db'
import type { EliteStatsExtendedService } from './elite-stats-extended.service'

type UpsertIpPlayerStateInput = {
  playerId: string
  lifetimeIp: number
  currentRankKey: string
  currentDivision: number
  rankProgressPoints: number
  currentDivisionFloor: number
  winStreak: number
  mvpCount: number
  lastRankedMatchAt: Date | null
  currentSeasonId: string | null
}

type UpsertIpSeasonStateInput = {
  playerId: string
  seasonId: string
  seasonPoints: number
  mvpCount: number
  matchesPlayed: number
}

type UpsertSwingPlayerStateInput = {
  playerId: string
  formulaVersion: string
  overallScore: number
  batScore: number
  bowlScore: number
  fieldingImpact: number
  powerScore: number
  impactScore: number
  axes: Record<string, unknown>
  subScores: Record<string, unknown>
  derivedMetrics: Record<string, unknown>
  weightingMeta: Record<string, unknown>
  sourceStatsVersion?: string | null
  sourceStatsComputedAt?: Date | null
  computedAt: Date
}

type MatchEngineIpEventInput = {
  playerId: string
  seasonId: string | null
  matchId: string | null
  reason: string
  ipDelta: number
  ipBefore: number
  ipAfter: number
  rankBefore: string
  rankAfter: string
  divisionBefore: number
  divisionAfter: number
  createdAt: Date
}

let playerStatOverallColumnsPromise: Promise<Set<string>> | null = null

function quoteIdentifier(input: string) {
  if (!/^[A-Za-z_][A-Za-z0-9_]*$/.test(input)) {
    throw new Error(`Unsafe SQL identifier: ${input}`)
  }
  return `"${input}"`
}

async function getPlayerStatOverallColumns() {
  if (!playerStatOverallColumnsPromise) {
    playerStatOverallColumnsPromise = prisma
      .$queryRaw<Array<{ column_name: string }>>`
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'PlayerStatOverall'
      `
      .then((rows) => new Set(rows.map((row) => row.column_name)))
  }
  return playerStatOverallColumnsPromise
}

function buildPlayerStatOverallPayload(
  playerId: string,
  stats: NonNullable<Awaited<ReturnType<EliteStatsExtendedService['getStats120']>>>,
) {
  return {
    playerId,
    statsVersion: 'stats-120-v1',
    computedAt: new Date(stats.generatedAt),
    updatedAt: new Date(),
    sourceCompletedMatches: stats.source.completedMatches,
    sourceFactsCount: stats.source.facts,
    sourceBattingEventsCount: stats.source.battingEvents,
    sourceBowlingEventsCount: stats.source.bowlingEvents,
    sourceMatchCount: stats.source.completedMatches,
    ...stats.metrics,
  } satisfies Record<string, unknown>
}

async function upsertPlayerStatOverallRow(row: Record<string, unknown>) {
  const columns = Object.keys(row)
  const values = columns.map((column) => row[column])
  const quotedColumns = columns.map(quoteIdentifier)
  const placeholders = columns.map((_, index) => `$${index + 1}`)
  const updates = columns
    .filter((column) => column !== 'playerId')
    .map((column) => `${quoteIdentifier(column)} = EXCLUDED.${quoteIdentifier(column)}`)

  const sql = `
    INSERT INTO public."PlayerStatOverall" (${quotedColumns.join(', ')})
    VALUES (${placeholders.join(', ')})
    ON CONFLICT ("playerId")
    DO UPDATE SET ${updates.join(', ')}
  `

  await prisma.$executeRawUnsafe(sql, ...values)
}

export async function upsertIpPlayerState(input: UpsertIpPlayerStateInput) {
  await prisma.$executeRaw`
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
    VALUES (
      ${input.playerId},
      ${input.lifetimeIp},
      ${input.currentRankKey},
      ${input.currentDivision},
      ${input.rankProgressPoints},
      ${input.currentDivisionFloor},
      ${input.winStreak},
      ${input.mvpCount},
      ${input.lastRankedMatchAt},
      ${input.currentSeasonId},
      NOW(),
      NOW()
    )
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
      "updatedAt" = NOW()
  `
}

export async function upsertIpSeasonState(input: UpsertIpSeasonStateInput) {
  await prisma.$executeRaw`
    INSERT INTO public.ip_season_state (
      "playerId",
      "seasonId",
      "seasonPoints",
      "mvpCount",
      "matchesPlayed",
      "createdAt",
      "updatedAt"
    )
    VALUES (
      ${input.playerId},
      ${input.seasonId},
      ${input.seasonPoints},
      ${input.mvpCount},
      ${input.matchesPlayed},
      NOW(),
      NOW()
    )
    ON CONFLICT ("playerId", "seasonId")
    DO UPDATE SET
      "seasonPoints" = EXCLUDED."seasonPoints",
      "mvpCount" = EXCLUDED."mvpCount",
      "matchesPlayed" = EXCLUDED."matchesPlayed",
      "updatedAt" = NOW()
  `
}

export async function updateIpSeasonLeaderboard(seasonId: string) {
  const rows = await prisma.$queryRaw<Array<{ playerId: string; seasonId: string }>>`
    SELECT "playerId", "seasonId"
    FROM public.ip_season_state
    WHERE "seasonId" = ${seasonId}
    ORDER BY "seasonPoints" DESC, "mvpCount" DESC, "matchesPlayed" ASC, id ASC
  `

  for (let index = 0; index < rows.length; index += 1) {
    const row = rows[index]
    await prisma.$executeRaw`
      UPDATE public.ip_season_state
      SET "leaderboardPosition" = ${index + 1},
          "updatedAt" = NOW()
      WHERE "playerId" = ${row.playerId}
        AND "seasonId" = ${row.seasonId}
    `
  }
}

export async function upsertSwingPlayerState(input: UpsertSwingPlayerStateInput) {
  const sql = `
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
      "sourceStatsVersion",
      "sourceStatsComputedAt",
      "computedAt",
      "updatedAt"
    )
    VALUES (
      $1, $2, $3, $4, $5, $6, $7, $8,
      $9::jsonb, $10::jsonb, $11::jsonb, $12::jsonb,
      $13, $14, $15, NOW()
    )
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
      "sourceStatsVersion" = EXCLUDED."sourceStatsVersion",
      "sourceStatsComputedAt" = EXCLUDED."sourceStatsComputedAt",
      "computedAt" = EXCLUDED."computedAt",
      "updatedAt" = NOW()
  `

  await prisma.$executeRawUnsafe(
    sql,
    input.playerId,
    input.formulaVersion,
    input.overallScore,
    input.batScore,
    input.bowlScore,
    input.fieldingImpact,
    input.powerScore,
    input.impactScore,
    JSON.stringify(input.axes ?? {}),
    JSON.stringify(input.subScores ?? {}),
    JSON.stringify(input.derivedMetrics ?? {}),
    JSON.stringify(input.weightingMeta ?? {}),
    input.sourceStatsVersion ?? null,
    input.sourceStatsComputedAt ?? null,
    input.computedAt,
  )
}

export async function replaceMatchEngineIpEvents(playerId: string, events: MatchEngineIpEventInput[]) {
  await prisma.$transaction(async (tx) => {
    await tx.$executeRaw`
      DELETE FROM public.ip_event
      WHERE "playerId" = ${playerId}
        AND "source" = 'MATCH_ENGINE'::ip_event_source
    `

    for (const event of events) {
      const eventType = event.ipDelta > 0 ? 'EARN' : event.ipDelta < 0 ? 'PENALTY' : 'ADJUSTMENT'
      await tx.$executeRaw`
        INSERT INTO public.ip_event (
          "playerId",
          "matchId",
          "seasonId",
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
        VALUES (
          ${event.playerId},
          ${event.matchId},
          ${event.seasonId},
          ${eventType}::ip_event_type,
          'MATCH_ENGINE'::ip_event_source,
          ${event.reason},
          ${event.ipDelta},
          ${event.ipBefore},
          ${event.ipAfter},
          ${event.rankBefore},
          ${event.rankAfter},
          ${event.divisionBefore},
          ${event.divisionAfter},
          ${event.matchId ? `match:${event.matchId}:player:${event.playerId}` : null},
          ${JSON.stringify({ rebuilt: true })}::jsonb,
          ${event.createdAt}
        )
      `
    }
  })
}

export async function upsertPlayerStatOverallFromStats120(
  playerId: string,
  stats120: NonNullable<Awaited<ReturnType<EliteStatsExtendedService['getStats120']>>>,
) {
  const tableColumns = await getPlayerStatOverallColumns()
  if (!tableColumns.has('playerId')) {
    throw new Error('public."PlayerStatOverall" is missing primary key "playerId"')
  }

  const payload = buildPlayerStatOverallPayload(playerId, stats120)
  const writable = Object.fromEntries(
    Object.entries(payload).filter(([key]) => tableColumns.has(key)),
  )

  await upsertPlayerStatOverallRow(writable)
}
