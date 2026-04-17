import { prisma } from '@swing/db'

export type IpPlayerStateRow = {
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
  createdAt: Date
  updatedAt: Date
}

export type IpSeasonStateRow = {
  id: bigint | number | string
  playerId: string
  seasonId: string
  seasonPoints: number
  mvpCount: number
  matchesPlayed: number
  leaderboardPosition: number | null
  createdAt: Date
  updatedAt: Date
}

export type IpEventRow = {
  id: bigint | number | string
  playerId: string
  matchId: string | null
  seasonId: string | null
  eventType: string | null
  source: string | null
  reason: string
  ipDelta: number
  ipBefore: number | null
  ipAfter: number | null
  rankBefore: string | null
  rankAfter: string | null
  divisionBefore: number | null
  divisionAfter: number | null
  externalRef: string | null
  meta: unknown
  createdAt: Date
}

export type SwingPlayerStateRow = {
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
  sourceStatsVersion: string | null
  sourceStatsComputedAt: Date | null
  computedAt: Date
  updatedAt: Date
}

export type PlayerStatOverallLite = {
  playerId: string
  matchesPlayed: number
  matchesWon: number
  mvpCount: number
  consistencyIndex: number
  computedAt: Date | null
}

function toObject(value: unknown): Record<string, unknown> {
  if (!value) return {}
  if (typeof value === 'object' && !Array.isArray(value)) {
    return value as Record<string, unknown>
  }
  if (typeof value === 'string') {
    try {
      const parsed = JSON.parse(value)
      if (parsed && typeof parsed === 'object' && !Array.isArray(parsed)) {
        return parsed as Record<string, unknown>
      }
    } catch {}
  }
  return {}
}

function toSafeNumber(value: unknown): number | null {
  if (typeof value === 'number' && Number.isFinite(value)) return value
  if (typeof value === 'string') {
    const parsed = Number(value)
    if (Number.isFinite(parsed)) return parsed
  }
  return null
}

export function getAxisNumber(axes: unknown, axisKey: string): number | null {
  const source = toObject(axes)
  return toSafeNumber(source[axisKey])
}

export function getSubScoreNumber(subScores: unknown, key: string): number | null {
  const source = toObject(subScores)
  return toSafeNumber(source[key])
}

export async function getIpPlayerState(playerId: string): Promise<IpPlayerStateRow | null> {
  const rows = await prisma.$queryRaw<IpPlayerStateRow[]>`
    SELECT
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
    FROM public.ip_player_state
    WHERE "playerId" = ${playerId}
    LIMIT 1
  `
  return rows[0] ?? null
}

export async function getIpSeasonState(
  playerId: string,
  seasonId?: string | null,
): Promise<IpSeasonStateRow | null> {
  if (seasonId) {
    const rows = await prisma.$queryRaw<IpSeasonStateRow[]>`
      SELECT
        id,
        "playerId",
        "seasonId",
        "seasonPoints",
        "mvpCount",
        "matchesPlayed",
        "leaderboardPosition",
        "createdAt",
        "updatedAt"
      FROM public.ip_season_state
      WHERE "playerId" = ${playerId}
        AND "seasonId" = ${seasonId}
      LIMIT 1
    `
    return rows[0] ?? null
  }

  const rows = await prisma.$queryRaw<IpSeasonStateRow[]>`
    SELECT
      id,
      "playerId",
      "seasonId",
      "seasonPoints",
      "mvpCount",
      "matchesPlayed",
      "leaderboardPosition",
      "createdAt",
      "updatedAt"
    FROM public.ip_season_state
    WHERE "playerId" = ${playerId}
    ORDER BY "updatedAt" DESC, id DESC
    LIMIT 1
  `
  return rows[0] ?? null
}

export async function getIpEventsPage(playerId: string, skip: number, take: number): Promise<IpEventRow[]> {
  const rows = await prisma.$queryRaw<IpEventRow[]>`
    SELECT
      id,
      "playerId",
      "matchId",
      "seasonId",
      "eventType"::text AS "eventType",
      "source"::text AS "source",
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
    FROM public.ip_event
    WHERE "playerId" = ${playerId}
    ORDER BY "createdAt" DESC, id DESC
    OFFSET ${Math.max(skip, 0)}
    LIMIT ${Math.max(1, take)}
  `
  return rows
}

export async function countIpEvents(playerId: string): Promise<number> {
  const rows = await prisma.$queryRaw<Array<{ count: bigint | number | string }>>`
    SELECT COUNT(*)::bigint AS count
    FROM public.ip_event
    WHERE "playerId" = ${playerId}
  `
  const raw = rows[0]?.count
  if (typeof raw === 'bigint') return Number(raw)
  if (typeof raw === 'number') return raw
  return Number.parseInt(String(raw ?? 0), 10) || 0
}

export async function getSwingPlayerState(playerId: string): Promise<SwingPlayerStateRow | null> {
  const rows = await prisma.$queryRaw<Array<Omit<SwingPlayerStateRow, 'axes' | 'subScores' | 'derivedMetrics' | 'weightingMeta'> & {
    axes: unknown
    subScores: unknown
    derivedMetrics: unknown
    weightingMeta: unknown
  }>>`
    SELECT
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
    FROM public.swing_player_state
    WHERE "playerId" = ${playerId}
    LIMIT 1
  `
  const row = rows[0]
  if (!row) return null
  return {
    ...row,
    axes: toObject(row.axes),
    subScores: toObject(row.subScores),
    derivedMetrics: toObject(row.derivedMetrics),
    weightingMeta: toObject(row.weightingMeta),
  }
}

export async function getPlayerStatOverall(playerId: string): Promise<PlayerStatOverallLite | null> {
  const rows = await prisma.$queryRaw<PlayerStatOverallLite[]>`
    SELECT
      "playerId",
      "matchesPlayed",
      "matchesWon",
      "mvpCount",
      "consistencyIndex",
      "computedAt"
    FROM public."PlayerStatOverall"
    WHERE "playerId" = ${playerId}
    ORDER BY "computedAt" DESC NULLS LAST, "updatedAt" DESC
    LIMIT 1
  `
  return rows[0] ?? null
}
