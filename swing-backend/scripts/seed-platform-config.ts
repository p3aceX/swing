import { PrismaClient } from '@prisma/client'

const defaults = [
  ['matchmaking_enabled', 'true', 'Enable/disable matchmaking queue'],
  ['store_enabled', 'false', 'Enable/disable equipment store'],
  ['gig_marketplace_enabled', 'true', 'Enable/disable gig marketplace'],
  ['ranked_matches_enabled', 'true', 'Enable or disable ranked match Impact Points'],
  ['ip_match_win_ranked', '100', 'Impact Points for winning a ranked match'],
  ['ip_match_win_friendly', '50', 'Impact Points for winning a friendly match'],
  ['ip_match_loss', '25', 'Impact Points for losing any match'],
  ['ip_session_present', '50', 'Impact Points for attending session on time'],
  ['ip_session_late', '25', 'Impact Points for attending session late'],
  ['ip_drill_complete', '25', 'Impact Points for completing assigned drill'],
  ['ip_batting_50', '30', 'Impact Points for scoring 50+ runs'],
  ['ip_batting_100', '75', 'Impact Points for scoring century'],
  ['ip_bowling_5wkt', '75', 'Impact Points for 5-wicket haul'],
  ['ip_no_show_penalty', '-50', 'Impact Points deducted for no-show'],
] as const

async function main() {
  const prisma = new PrismaClient()

  try {
    for (const [key, value, description] of defaults) {
      await prisma.platformConfig.upsert({
        where: { key },
        update: { value, description },
        create: { key, value, description },
      })
    }
    console.log(`Seeded ${defaults.length} platform config values`)
  } finally {
    await prisma.$disconnect()
  }
}

main().catch(error => {
  console.error(error)
  process.exit(1)
})
