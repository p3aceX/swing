import { PrismaClient } from '@prisma/client'
import { EliteAnalyticsService } from '../apps/api/src/modules/performance/elite-analytics.service'

const prisma = new PrismaClient()
const analyticsSvc = new EliteAnalyticsService()

// Parth Gupta Profile from populate-parth-data.ts
const profileId = 'cmn32wpcr008j7a47h7qgs4be'

async function testApexProfile() {
  console.log(`\n🔍 --- APEX ELITE PROFILE TEST: ${profileId} ---\n`)

  // 1. Ensure user is Apex
  await prisma.playerCompetitiveProfile.upsert({
    where: { playerId: profileId },
    update: { hasPremiumPass: true },
    create: {
      playerId: profileId,
      hasPremiumPass: true,
      currentRankKey: 'PHANTOM',
      currentDivision: 1,
      lifetimeImpactPoints: 12500
    }
  })

  // 2. Fetch Unified Profile
  console.log('Fetching Unified Profile...')
  const profile = await analyticsSvc.getUnifiedProfile(profileId)

  if (!profile) {
    console.error('❌ Profile not found!')
    return
  }

  console.log('✅ Profile Fetched Successfully')
  console.log(`👤 Name: ${profile.identity.name}`)
  console.log(`🏆 Rank: ${profile.ranking.label}`)
  
  console.log('\n--- 📊 Match Statistics (New: Chase/Defend) ---')
  console.log(`Total Matches: ${profile.stats.matches.total}`)
  console.log(`Wins: ${profile.stats.matches.wins} (${profile.stats.matches.winPct}%)`)
  console.log(`Chasing: ${profile.stats.matches.chase.wins}/${profile.stats.matches.chase.total} (${profile.stats.matches.chase.winPct}%)`)
  console.log(`Defending: ${profile.stats.matches.defend.wins}/${profile.stats.matches.defend.total} (${profile.stats.matches.defend.winPct}%)`)

  console.log('\n--- 🎯 Precision Analytics (New: Bowling Phases) ---')
  console.log('Batting Strike Rates:')
  console.log(`  Powerplay: ${profile.precision.phases.batting.powerplaySR}`)
  console.log(`  Middle:    ${profile.precision.phases.batting.middleOversSR}`)
  console.log(`  Death:     ${profile.precision.phases.batting.deathOversSR}`)
  
  console.log('Bowling Economy Rates:')
  console.log(`  Powerplay: ${profile.precision.phases.bowling.powerplayEcon}`)
  console.log(`  Middle:    ${profile.precision.phases.bowling.middleOversEcon}`)
  console.log(`  Death:     ${profile.precision.phases.bowling.deathOversEcon}`)

  if (profile.isApex) {
    console.log('\n--- 🧠 APEX Insights (SWOT) ---')
    if (profile.swot) {
      console.log('Strengths:', profile.swot.strengths.join(', '))
      console.log('Weaknesses:', profile.swot.weaknesses.join(', '))
    } else {
      console.log('SWOT not generated.')
    }

    console.log('\n--- 🏥 APEX Health Dashboard ---')
    if (profile.apexDashboard) {
      console.log(`Readiness: ${profile.apexDashboard.readiness.score} (${profile.apexDashboard.readiness.label})`)
      console.log(`Injury Risk: ${profile.apexDashboard.integrity.injuryRisk}`)
    } else {
      console.log('Health Dashboard not available.')
    }
  } else {
    console.log('\n⚠️ Profile is NOT marked as APEX.')
  }

  console.log('\n--- ✅ TEST COMPLETE ---\n')
}

testApexProfile()
  .catch(console.error)
  .finally(() => prisma.$disconnect())
