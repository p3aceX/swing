import { prisma } from '@swing/db'
import { EliteStatsExtendedService } from '../apps/api/src/modules/performance/elite-stats-extended.service'

type Args = {
  batchSize: number
  limit?: number
  playerIds?: string[]
  dryRun: boolean
  strict: boolean
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

  const rawPlayerIds = argv
    .filter((arg) => arg.startsWith('--player-id='))
    .map((arg) => arg.slice('--player-id='.length))
    .flatMap((value) => value.split(','))
    .map((value) => value.trim())
    .filter(Boolean)

  return {
    batchSize: toInt(getValue('--batch-size'), 100) ?? 100,
    limit: toInt(getValue('--limit'), undefined),
    playerIds: rawPlayerIds.length > 0 ? rawPlayerIds : undefined,
    dryRun: hasFlag('--dry-run'),
    strict: !hasFlag('--no-strict'),
  }
}

function printHelp() {
  console.log(`
backfill-player-stat-overall

Usage:
  npx tsx scripts/backfill-player-stat-overall.ts [options]

Options:
  --batch-size=<n>      Batch size when scanning players (default: 100)
  --limit=<n>           Stop after processing n players
  --player-id=<id>      Process one or more explicit player IDs (repeatable, comma separated)
  --dry-run             Compute + validate only, do not write
  --no-strict           Skip strict checks (default is strict)
  --help                Show help
`)
}

function quoteIdentifier(input: string) {
  if (!/^[A-Za-z_][A-Za-z0-9_]*$/.test(input)) {
    throw new Error(`Unsafe SQL identifier: ${input}`)
  }
  return `"${input}"`
}

async function getTableColumns(tableName: string) {
  const rows = await prisma.$queryRaw<Array<{ column_name: string }>>`
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = ${tableName}
  `
  return new Set(rows.map((row) => row.column_name))
}

function buildWritablePayload(
  playerId: string,
  stats: Awaited<ReturnType<EliteStatsExtendedService['getStats120']>>,
) {
  if (!stats) return null
  const now = new Date()

  return {
    playerId,
    statsVersion: 'stats-120-v1',
    computedAt: new Date(stats.generatedAt),
    updatedAt: now,
    sourceCompletedMatches: stats.source.completedMatches,
    sourceFactsCount: stats.source.facts,
    sourceBattingEventsCount: stats.source.battingEvents,
    sourceBowlingEventsCount: stats.source.bowlingEvents,
    sourceMatchCount: stats.source.completedMatches,
    ...stats.metrics,
  } satisfies Record<string, unknown>
}

async function upsertRow(tableName: string, row: Record<string, unknown>) {
  const columns = Object.keys(row)
  const values = columns.map((column) => row[column])

  const quotedColumns = columns.map(quoteIdentifier)
  const placeholders = columns.map((_, index) => `$${index + 1}`)
  const updates = columns
    .filter((column) => column !== 'playerId')
    .map((column) => `${quoteIdentifier(column)} = EXCLUDED.${quoteIdentifier(column)}`)

  const sql = `
    INSERT INTO public.${quoteIdentifier(tableName)} (${quotedColumns.join(', ')})
    VALUES (${placeholders.join(', ')})
    ON CONFLICT ("playerId")
    DO UPDATE SET ${updates.join(', ')}
  `

  await prisma.$executeRawUnsafe(sql, ...values)
}

async function main() {
  const argv = process.argv.slice(2)
  if (argv.includes('--help') || argv.includes('-h')) {
    printHelp()
    return
  }

  const args = parseArgs(argv)
  const statsService = new EliteStatsExtendedService()
  const tableName = 'PlayerStatOverall'

  const tableColumns = await getTableColumns(tableName)
  if (tableColumns.size === 0) {
    throw new Error(
      `Table public."${tableName}" not found. Create table first, then run backfill.`,
    )
  }
  if (!tableColumns.has('playerId')) {
    throw new Error(`Table public."${tableName}" must contain "playerId" primary key.`)
  }

  console.log(
    JSON.stringify(
      {
        action: 'backfill-player-stat-overall',
        table: `public.${tableName}`,
        strict: args.strict,
        dryRun: args.dryRun,
        batchSize: args.batchSize,
        limit: args.limit ?? null,
        explicitPlayers: args.playerIds?.length ?? 0,
      },
      null,
      2,
    ),
  )

  let processed = 0
  let written = 0
  let skipped = 0
  let failed = 0
  const failures: Array<{ playerId: string; error: string }> = []

  const processPlayer = async (playerId: string) => {
    processed += 1

    try {
      const stats = await statsService.getStats120(playerId)
      if (!stats) {
        skipped += 1
        return
      }

      const metricKeys = Object.keys(stats.metrics)
      if (args.strict && metricKeys.length < 120) {
        throw new Error(`Expected at least 120 metrics, got ${metricKeys.length}`)
      }

      const missingColumns = metricKeys.filter((key) => !tableColumns.has(key))
      if (args.strict && missingColumns.length > 0) {
        throw new Error(
          `Missing ${missingColumns.length} metric columns in ${tableName}. First missing: ${missingColumns[0]}`,
        )
      }

      const payload = buildWritablePayload(playerId, stats)
      if (!payload) {
        skipped += 1
        return
      }

      const writable = Object.fromEntries(
        Object.entries(payload).filter(([key]) => tableColumns.has(key)),
      )

      if (args.strict && Object.keys(writable).length < metricKeys.length + 1) {
        throw new Error('Strict mode refused partial payload write')
      }

      if (!args.dryRun) {
        await upsertRow(tableName, writable)
      }
      written += 1
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
      if (args.limit && processed >= args.limit) break
      await processPlayer(playerId)
    }
  } else {
    let cursor: string | null = null

    while (true) {
      if (args.limit && processed >= args.limit) break
      const remaining = args.limit ? Math.max(args.limit - processed, 0) : args.batchSize
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
        processed,
        written,
        skipped,
        failed,
        failures: failures.slice(0, 50),
      },
      null,
      2,
    ),
  )

  if (failed > 0) {
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
