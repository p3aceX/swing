import { Prisma, prisma } from '@swing/db'

type Args = {
  batchSize: number
  limit?: number
  playerIds?: string[]
  failOnMismatch: boolean
  includeLeaderboard: boolean
}

type Mismatch = {
  playerId: string
  fields: string[]
  details: Record<string, { old: unknown; next: unknown }>
}

function parseArgs(argv: string[]): Args {
  const hasFlag = (flag: string) => argv.includes(flag)
  const getValue = (flag: string) => {
    const direct = argv.find((arg) => arg.startsWith(`${flag}=`))
    if (direct) return direct.slice(flag.length + 1)
    const index = argv.indexOf(flag)
    if (index === -1) return undefined
    return argv[index + 1]
  }
  const toInt = (value: string | undefined, fallback: number | undefined) => {
    if (!value) return fallback
    const parsed = Number.parseInt(value, 10)
    return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback
  }

  const explicitPlayers = argv
    .filter((arg) => arg.startsWith('--player-id='))
    .map((arg) => arg.slice('--player-id='.length))
    .flatMap((value) => value.split(','))
    .map((value) => value.trim())
    .filter(Boolean)

  return {
    batchSize: toInt(getValue('--batch-size'), 100) ?? 100,
    limit: toInt(getValue('--limit'), undefined),
    playerIds: explicitPlayers.length > 0 ? explicitPlayers : undefined,
    failOnMismatch: hasFlag('--fail-on-mismatch'),
    includeLeaderboard: hasFlag('--include-leaderboard'),
  }
}

function printHelp() {
  console.log(`
reconcile-performance-state

Usage:
  npx tsx scripts/reconcile-performance-state.ts [options]

Options:
  --batch-size=<n>         Batch size when scanning players (default: 100)
  --limit=<n>              Stop after processing n players
  --player-id=<id>         Process one or more explicit player IDs (repeatable, comma separated)
  --fail-on-mismatch       Exit non-zero if mismatches are found
  --include-leaderboard    Compare season leaderboard positions as well
  --help                   Show help
`)
}

function toNumber(value: unknown): number | null {
  if (typeof value === 'number' && Number.isFinite(value)) return value
  if (typeof value === 'bigint') return Number(value)
  if (typeof value === 'string') {
    const parsed = Number(value)
    return Number.isFinite(parsed) ? parsed : null
  }
  return null
}

function almostEqual(a: unknown, b: unknown, epsilon = 0.05): boolean {
  const left = toNumber(a)
  const right = toNumber(b)
  if (left !== null && right !== null) {
    return Math.abs(left - right) <= epsilon
  }
  return a === b
}

async function tableExists(tableName: string): Promise<boolean> {
  const rows = await prisma.$queryRaw<Array<{ exists: boolean }>>`
    SELECT EXISTS (
      SELECT 1
      FROM information_schema.tables
      WHERE table_schema = 'public'
        AND table_name = ${tableName}
    ) AS exists
  `
  return Boolean(rows[0]?.exists)
}

async function queryOne<T extends Record<string, unknown>>(
  sql: Prisma.Sql,
): Promise<T | null> {
  const rows = await prisma.$queryRaw<T[]>(sql)
  return rows[0] ?? null
}

async function main() {
  const argv = process.argv.slice(2)
  if (argv.includes('--help') || argv.includes('-h')) {
    printHelp()
    return
  }

  const args = parseArgs(argv)
  const [
    hasOldCompetitive,
    hasOldSeason,
    hasOldAggregate,
    hasNewIpState,
    hasNewSeasonState,
    hasNewSwingState,
  ] = await Promise.all([
    tableExists('player_competitive_profile'),
    tableExists('player_season_progress'),
    tableExists('player_index_aggregate'),
    tableExists('ip_player_state'),
    tableExists('ip_season_state'),
    tableExists('swing_player_state'),
  ])

  const activeSeason = await prisma.competitiveSeason.findFirst({
    where: { isActive: true },
    select: { id: true },
    orderBy: { startAt: 'desc' },
  })

  console.log(
    JSON.stringify(
      {
        action: 'reconcile-performance-state',
        batchSize: args.batchSize,
        limit: args.limit ?? null,
        explicitPlayers: args.playerIds?.length ?? 0,
        includeLeaderboard: args.includeLeaderboard,
        activeSeasonId: activeSeason?.id ?? null,
        tables: {
          oldCompetitive: hasOldCompetitive,
          oldSeasonProgress: hasOldSeason,
          oldIndexAggregate: hasOldAggregate,
          newIpPlayerState: hasNewIpState,
          newIpSeasonState: hasNewSeasonState,
          newSwingPlayerState: hasNewSwingState,
        },
      },
      null,
      2,
    ),
  )

  let scanned = 0
  let matched = 0
  let mismatched = 0
  let missingNewState = 0
  const mismatchRows: Mismatch[] = []
  const mismatchFieldCounts = new Map<string, number>()

  const processPlayer = async (playerId: string) => {
    scanned += 1

    const [
      oldCompetitive,
      oldSeasonProgress,
      oldAggregate,
      newIpState,
      newSeasonState,
      newSwingState,
    ] = await Promise.all([
      hasOldCompetitive
        ? queryOne<Record<string, unknown>>(Prisma.sql`
            SELECT
              "lifetimeImpactPoints",
              "currentRankKey",
              "currentDivision",
              "rankProgressPoints",
              "mvpCount"
            FROM public.player_competitive_profile
            WHERE "playerId" = ${playerId}
            LIMIT 1
          `)
        : Promise.resolve(null),
      hasOldSeason
        ? queryOne<Record<string, unknown>>(Prisma.sql`
            SELECT
              "seasonPoints",
              "mvpCount",
              "matchesPlayed",
              "currentLeaderboardPosition"
            FROM public.player_season_progress
            WHERE "playerId" = ${playerId}
              ${activeSeason?.id
                ? Prisma.sql`AND "seasonId" = ${activeSeason.id}`
                : Prisma.sql``}
            ORDER BY "updatedAt" DESC, id DESC
            LIMIT 1
          `)
        : Promise.resolve(null),
      hasOldAggregate
        ? queryOne<Record<string, unknown>>(Prisma.sql`
            SELECT
              "currentSwingIndexScore",
              "swingBatScore",
              "swingBowlScore",
              "swingFieldingImpact",
              "swingPowerScore",
              "swingImpactScore"
            FROM public.player_index_aggregate
            WHERE "playerId" = ${playerId}
            LIMIT 1
          `)
        : Promise.resolve(null),
      hasNewIpState
        ? queryOne<Record<string, unknown>>(Prisma.sql`
            SELECT
              "lifetimeIp",
              "currentRankKey",
              "currentDivision",
              "rankProgressPoints",
              "mvpCount"
            FROM public.ip_player_state
            WHERE "playerId" = ${playerId}
            LIMIT 1
          `)
        : Promise.resolve(null),
      hasNewSeasonState
        ? queryOne<Record<string, unknown>>(Prisma.sql`
            SELECT
              "seasonPoints",
              "mvpCount",
              "matchesPlayed",
              "leaderboardPosition"
            FROM public.ip_season_state
            WHERE "playerId" = ${playerId}
              ${activeSeason?.id
                ? Prisma.sql`AND "seasonId" = ${activeSeason.id}`
                : Prisma.sql``}
            ORDER BY "updatedAt" DESC, id DESC
            LIMIT 1
          `)
        : Promise.resolve(null),
      hasNewSwingState
        ? queryOne<Record<string, unknown>>(Prisma.sql`
            SELECT
              "overallScore",
              "batScore",
              "bowlScore",
              "fieldingImpact",
              "powerScore",
              "impactScore"
            FROM public.swing_player_state
            WHERE "playerId" = ${playerId}
            LIMIT 1
          `)
        : Promise.resolve(null),
    ])

    if (!newIpState || !newSwingState) {
      missingNewState += 1
    }

    const checks: Array<[string, unknown, unknown]> = [
      ['ip.lifetime', oldCompetitive?.lifetimeImpactPoints, newIpState?.lifetimeIp],
      ['ip.rankKey', oldCompetitive?.currentRankKey, newIpState?.currentRankKey],
      ['ip.division', oldCompetitive?.currentDivision, newIpState?.currentDivision],
      ['ip.rankProgress', oldCompetitive?.rankProgressPoints, newIpState?.rankProgressPoints],
      ['ip.mvpCount', oldCompetitive?.mvpCount, newIpState?.mvpCount],
      ['season.points', oldSeasonProgress?.seasonPoints, newSeasonState?.seasonPoints],
      ['season.mvpCount', oldSeasonProgress?.mvpCount, newSeasonState?.mvpCount],
      ['season.matchesPlayed', oldSeasonProgress?.matchesPlayed, newSeasonState?.matchesPlayed],
      ...(args.includeLeaderboard
        ? [[
            'season.leaderboard',
            oldSeasonProgress?.currentLeaderboardPosition,
            newSeasonState?.leaderboardPosition,
          ] as [string, unknown, unknown]]
        : []),
      ['swing.overall', oldAggregate?.currentSwingIndexScore, newSwingState?.overallScore],
      ['swing.bat', oldAggregate?.swingBatScore, newSwingState?.batScore],
      ['swing.bowl', oldAggregate?.swingBowlScore, newSwingState?.bowlScore],
      ['swing.fielding', oldAggregate?.swingFieldingImpact, newSwingState?.fieldingImpact],
      ['swing.power', oldAggregate?.swingPowerScore, newSwingState?.powerScore],
      ['swing.impact', oldAggregate?.swingImpactScore, newSwingState?.impactScore],
    ]

    const fields: string[] = []
    const details: Record<string, { old: unknown; next: unknown }> = {}
    for (const [field, oldValue, nextValue] of checks) {
      if (oldValue === undefined || oldValue === null) continue
      if (nextValue === undefined || nextValue === null) {
        fields.push(field)
        details[field] = { old: oldValue, next: nextValue }
        mismatchFieldCounts.set(field, (mismatchFieldCounts.get(field) ?? 0) + 1)
        continue
      }
      if (!almostEqual(oldValue, nextValue)) {
        fields.push(field)
        details[field] = { old: oldValue, next: nextValue }
        mismatchFieldCounts.set(field, (mismatchFieldCounts.get(field) ?? 0) + 1)
      }
    }

    if (fields.length === 0) {
      matched += 1
      return
    }

    mismatched += 1
    mismatchRows.push({
      playerId,
      fields,
      details,
    })
  }

  if (args.playerIds && args.playerIds.length > 0) {
    for (const playerId of args.playerIds) {
      if (args.limit && scanned >= args.limit) break
      await processPlayer(playerId)
    }
  } else {
    let cursor: string | null = null
    while (true) {
      if (args.limit && scanned >= args.limit) break
      const remaining = args.limit
        ? Math.max(args.limit - scanned, 0)
        : args.batchSize
      if (remaining <= 0) break

      const players = await prisma.playerProfile.findMany({
        where: cursor ? { id: { gt: cursor } } : undefined,
        select: { id: true },
        orderBy: { id: 'asc' },
        take: Math.min(args.batchSize, remaining),
      })
      if (players.length === 0) break

      for (const player of players) {
        await processPlayer(player.id)
      }
      cursor = players[players.length - 1]?.id ?? null
    }
  }

  console.log(
    JSON.stringify(
      {
        scanned,
        matched,
        mismatched,
        missingNewState,
        topFieldMismatches: Array.from(mismatchFieldCounts.entries())
          .sort((a, b) => b[1] - a[1])
          .slice(0, 20)
          .map(([field, count]) => ({ field, count })),
        sampleMismatches: mismatchRows.slice(0, 30),
      },
      null,
      2,
    ),
  )

  if (args.failOnMismatch && mismatched > 0) {
    process.exitCode = 1
  }
}

main()
  .catch((error) => {
    console.error(error)
    process.exitCode = 1
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
