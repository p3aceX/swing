import { prisma } from '@swing/db'
import { PerformanceService } from '../apps/api/src/modules/performance/performance.service'

function parseArgs(argv: string[]) {
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
    batchSize: toInt(getValue('--batch-size'), 100),
    limit: toInt(getValue('--limit'), undefined),
    playerIds: rawPlayerIds.length > 0 ? rawPlayerIds : undefined,
  }
}

async function main() {
  const args = parseArgs(process.argv.slice(2))
  const performanceService = new PerformanceService()

  console.log(
    JSON.stringify(
      {
        action: 'backfill-swing-index-v2',
        batchSize: args.batchSize,
        limit: args.limit ?? null,
        explicitPlayers: args.playerIds?.length ?? 0,
      },
      null,
      2,
    ),
  )

  const startedAt = Date.now()
  const result = await performanceService.backfillSwingIndexV2({
    batchSize: args.batchSize,
    limit: args.limit,
    playerIds: args.playerIds,
  })
  const durationMs = Date.now() - startedAt

  console.log(
    JSON.stringify(
      {
        ...result,
        durationMs,
      },
      null,
      2,
    ),
  )

  if (result.failed > 0) {
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
