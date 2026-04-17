import { PrismaClient } from '@prisma/client'
import { EliteAnalyticsService } from '../apps/api/src/modules/performance/elite-analytics.service'
import { ChallengeDetectorService } from '../apps/api/src/modules/performance/challenge-detector.service'

const prisma = new PrismaClient()
const analyticsSvc = new EliteAnalyticsService()
const detector = new ChallengeDetectorService()

const userId = 'cmn32wpbn008h7a47xa8r5n0k'

async function runStressTest() {
  console.log(`\n🔍 --- STRESS TEST REPORT FOR USER: ${userId} ---\n`)

  // 1. Get Player Profile
  const profile = await prisma.playerProfile.findUnique({
    where: { userId },
    include: { user: true, indexAggregate: true }
  })

  if (!profile) {
    console.error(`❌ User Profile ${userId} not found!`)
    return
  }

  console.log(`👤 Player Name: ${profile.user.name}`)
  console.log(`📍 City: ${profile.city || 'Not Set'}`)
  console.log(`🎖️ Current Rank: ${profile.indexAggregate?.currentRankKey} (Division ${profile.indexAggregate?.currentDivision})`)
  console.log(`📊 Swing Index: ${profile.indexAggregate?.currentSwingIndex.toFixed(2)}`)
  console.log(`🔥 Lifetime IP: ${profile.indexAggregate?.lifetimeImpactPoints}`)

  // 2. Fetch Elite Analytics
  console.log('\n--- 📈 Elite Analytics (v1.1) ---')
  const analytics = await analyticsSvc.getPlayerAnalytics(profile.id)
  if (analytics) {
    console.log(`🏏 Highest Score: ${analytics.batting.summary.highestScore}`)
    console.log(`🏃 Batting Avg/SR: ${analytics.batting.summary.average} / ${analytics.batting.summary.strikeRate}`)
    console.log(`💨 Death SR: ${analytics.batting.precision.deathOversSR}`)
    console.log(`🌀 vs Spin SR: ${analytics.batting.matchups.spinSR}`)
    console.log(`⚡ vs Pace SR: ${analytics.batting.matchups.paceSR}`)
    console.log(`🛌 Recovery Score: ${analytics.wellness.recoveryScore}%`)
    console.log(`⚖️ Workload Past Month: ${analytics.wellness.oversBowledPastMonth} overs`)
  } else {
    console.log('No analytics data available.')
  }

  // 3. Benchmarks
  console.log('\n--- 📏 Benchmarking ---')
  const benchmark = await analyticsSvc.getBenchmarks(profile.id, 'CITY')
  if (benchmark) {
    console.log(`🏙️ City Average SR (${benchmark.benchmarks.label}): ${benchmark.benchmarks.averageSR}`)
    console.log(`🚀 Player Percentile: ${benchmark.benchmarks.percentile}%`)
  }

  // 4. Badges & Challenges
  console.log('\n--- 🏅 Badges & Challenges (Flex 100) ---')
  const badges = await prisma.playerBadge.findMany({
    where: { playerProfileId: profile.id },
    include: { 
      badge: {
        select: {
          name: true,
          category: true,
          description: true
        }
      }
    }
  })

  if (badges.length > 0) {
    badges.forEach((pb, i) => {
      console.log(`${i+1}. [${pb.badge.category}] ${pb.badge.name} - ${pb.badge.description}`)
    })
  } else {
    console.log('No badges awarded yet.')
  }

  // 5. Team Analysis
  console.log('\n--- 🛡️ Team Intelligence ---')
  const teams = await prisma.team.findMany({
    where: { playerIds: { has: profile.id } }
  })

  for (const team of teams) {
    console.log(`Team: ${team.name} | Power Score: ${team.powerScore.toFixed(2)}`)
    const tAnalytics = await analyticsSvc.getTeamAnalytics(team.id)
    if (tAnalytics) {
      console.log(`   Strategy: ${tAnalytics.strategies.preference} (Chasing: ${tAnalytics.strategies.chasingWinRate}%)`)
    }
  }

  console.log('\n--- ✅ TEST COMPLETE ---\n')
}

runStressTest()
  .catch(console.error)
  .finally(() => prisma.$disconnect())
