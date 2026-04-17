import { PrismaClient } from '@prisma/client'
import { PerformanceService } from '../apps/api/src/modules/performance/performance.service'

const prisma = new PrismaClient()
const performanceService = new PerformanceService()

async function main() {
  const dryRun = process.argv.includes('--dry-run')

  const matches = await prisma.match.findMany({
    where: {
      status: 'COMPLETED',
      matchFacts: { none: {} },
    },
    select: {
      id: true,
      scheduledAt: true,
      completedAt: true,
      teamAName: true,
      teamBName: true,
      verificationLevel: true,
    },
    orderBy: { scheduledAt: 'desc' },
  })

  console.log(`Found ${matches.length} completed matches without match_player_facts.`)

  if (matches.length > 0) {
    console.table(
      matches.map((match) => ({
        id: match.id,
        scheduledAt: match.scheduledAt.toISOString(),
        completedAt: match.completedAt?.toISOString() ?? null,
        fixture: `${match.teamAName} vs ${match.teamBName}`,
        verificationLevel: match.verificationLevel,
      })),
    )
  }

  if (dryRun || matches.length === 0) {
    return
  }

  let processed = 0
  let skipped = 0
  let failed = 0

  for (const match of matches) {
    try {
      const result = await performanceService.processVerifiedMatch(match.id, {
        allowUnverified: true,
      })

      if (result.processed) {
        processed += 1
        console.log(
          `Processed ${match.id}: players=${result.players}, mvp=${result.mvpPlayerId ?? 'n/a'}`,
        )
      } else {
        skipped += 1
        console.log(`Skipped ${match.id}: ${result.reason}`)
      }
    } catch (error) {
      failed += 1
      console.error(`Failed ${match.id}`, error)
    }
  }

  const remaining = await prisma.match.count({
    where: {
      status: 'COMPLETED',
      matchFacts: { none: {} },
    },
  })

  console.log(
    JSON.stringify(
      {
        processed,
        skipped,
        failed,
        remaining,
      },
      null,
      2,
    ),
  )
}

main()
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
