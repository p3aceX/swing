import { PrismaClient } from '@prisma/client'
import { ChallengeDetectorService } from '../apps/api/src/modules/performance/challenge-detector.service'

const prisma = new PrismaClient()
const detector = new ChallengeDetectorService()

async function main() {
  console.log('🚀 Starting Historical Badge Catch-up...')

  // 1. Fetch all verified matches
  const verifiedMatches = await prisma.match.findMany({
    where: {
      status: 'COMPLETED',
      verificationLevel: { not: 'UNVERIFIED' }
    },
    select: { id: true }
  })

  console.log(`Found ${verifiedMatches.length} verified matches to process.`)

  let processedCount = 0
  let badgeCount = 0

  for (const match of verifiedMatches) {
    // 2. Fetch all player facts for this match
    const facts = await prisma.matchPlayerFact.findMany({
      where: { matchId: match.id },
      select: { playerId: true }
    })

    for (const fact of facts) {
      const awards = await detector.detectAndAwardBadges(match.id, fact.playerId)
      if (awards && awards.length > 0) {
        badgeCount += awards.length
      }
    }

    processedCount++
    if (processedCount % 10 === 0) {
      console.log(`Progress: ${processedCount}/${verifiedMatches.length} matches processed...`)
    }
  }

  console.log('✅ Catch-up Complete!')
  console.log(`Matches Processed: ${processedCount}`)
  console.log(`New Badges Awarded: ${badgeCount}`)
}

main()
  .catch((e) => {
    console.error('❌ Migration Failed:', e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
