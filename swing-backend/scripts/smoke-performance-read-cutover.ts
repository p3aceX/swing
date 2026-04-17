import { prisma } from '@swing/db'
import { PerformanceService } from '../apps/api/src/modules/performance/performance.service'
import { EliteAnalyticsService } from '../apps/api/src/modules/performance/elite-analytics.service'

type Args = {
  batchSize: number
  limit?: number
  playerIds?: string[]
  failOnError: boolean
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
    batchSize: toInt(getValue('--batch-size'), 50) ?? 50,
    limit: toInt(getValue('--limit'), undefined),
    playerIds: explicitPlayers.length > 0 ? explicitPlayers : undefined,
    failOnError: hasFlag('--fail-on-error'),
  }
}

function printHelp() {
  console.log(`
smoke-performance-read-cutover

Usage:
  npx tsx scripts/smoke-performance-read-cutover.ts [options]

Options:
  --batch-size=<n>      Batch size when scanning players (default: 50)
  --limit=<n>           Stop after processing n players
  --player-id=<id>      Process one or more explicit player IDs (repeatable, comma separated)
  --fail-on-error       Exit non-zero if any player fails
  --help                Show help
`)
}

async function main() {
  const argv = process.argv.slice(2)
  if (argv.includes('--help') || argv.includes('-h')) {
    printHelp()
    return
  }

  const args = parseArgs(argv)
  const performance = new PerformanceService()
  const analytics = new EliteAnalyticsService()

  console.log(
    JSON.stringify(
      {
        action: 'smoke-performance-read-cutover',
        batchSize: args.batchSize,
        limit: args.limit ?? null,
        explicitPlayers: args.playerIds?.length ?? 0,
      },
      null,
      2,
    ),
  )

  let scanned = 0
  let passed = 0
  let failed = 0
  const failures: Array<{ playerId: string; error: string }> = []

  const runChecks = async (playerId: string) => {
    scanned += 1
    try {
      await Promise.all([
        performance.getPlayerStatsSummary(playerId),
        performance.getPlayerIndex(playerId),
        performance.getPlayerSeason(playerId),
        analytics.getPlayerAnalytics(playerId),
      ])
      passed += 1
    } catch (error) {
      failed += 1
      failures.push({
        playerId,
        error: error instanceof Error ? error.message : 'Unknown error',
      })
    }
  }

  if (args.playerIds && args.playerIds.length > 0) {
    for (const playerId of args.playerIds) {
      if (args.limit && scanned >= args.limit) break
      await runChecks(playerId)
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
        await runChecks(player.id)
      }
      cursor = players[players.length - 1]?.id ?? null
    }
  }

  console.log(
    JSON.stringify(
      {
        scanned,
        passed,
        failed,
        failures: failures.slice(0, 50),
      },
      null,
      2,
    ),
  )

  if (args.failOnError && failed > 0) {
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
