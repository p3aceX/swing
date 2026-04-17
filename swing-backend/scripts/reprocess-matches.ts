import { PerformanceService } from '../apps/api/src/modules/performance/performance.service'

const performanceService = new PerformanceService()

async function main() {
  const matchIds = process.argv.slice(2)
  if (matchIds.length === 0) {
    throw new Error('Pass at least one match ID')
  }

  let processed = 0
  let skipped = 0
  let failed = 0

  for (const matchId of matchIds) {
    try {
      const result = await performanceService.processVerifiedMatch(matchId, {
        allowUnverified: true,
      })

      if (result.processed) {
        processed += 1
        console.log(
          `Processed ${matchId}: players=${result.players}, mvp=${result.mvpPlayerId ?? 'n/a'}`,
        )
      } else {
        skipped += 1
        console.log(`Skipped ${matchId}: ${result.reason}`)
      }
    } catch (error) {
      failed += 1
      console.error(`Failed ${matchId}`, error)
    }
  }

  console.log(JSON.stringify({ processed, skipped, failed }, null, 2))
}

main().catch((error) => {
  console.error(error)
  process.exit(1)
})
