import { PrismaClient } from '@prisma/client'
import { PerformanceService } from '../apps/api/src/modules/performance/performance.service'

const prisma = new PrismaClient()
const perf = new PerformanceService()

async function main() {
  const matchId = 'cmn1yc6v7000afu37fj3lhrkf'
  console.log(`🚀 Force Verifying Match: ${matchId}`)

  // 1. Mark match as verified
  await prisma.match.update({
    where: { id: matchId },
    data: {
      verificationLevel: 'LEVEL_3',
      verifiedAt: new Date(),
      status: 'COMPLETED'
    }
  })

  // 2. Trigger Performance Processing
  console.log('📊 Triggering processVerifiedMatch...')
  const result = await perf.processVerifiedMatch(matchId)
  console.log('Result:', result)

  // 3. Check if facts were created
  const factCount = await prisma.matchPlayerFact.count({ where: { matchId } })
  console.log(`✅ MatchPlayerFact records created: ${factCount}`)
}

main().catch(console.error).finally(() => prisma.$disconnect())
