import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function main() {
  const profileId = 'cmn32wpcr008j7a47h7qgs4be' // Parth Gupta Profile
  const userId = 'cmn32wpbn008h7a47xa8r5n0k'

  console.log(`🚀 Mocking Elite Data for Parth Gupta (${profileId})`)

  // 1. Create multiple MatchPlayerFacts to generate badges and milestones
  const matches = [
    {
      id: 'mock-match-1',
      runs: 100, balls: 45, fours: 12, sixes: 4, wickets: 3, overs: 4, conceded: 18, result: 'WIN', innings: 1, 
      desc: 'Nervous 90s Survivor + Three-fer + Double Threat'
    },
    {
      id: 'mock-match-2',
      runs: 55, balls: 22, fours: 6, sixes: 2, wickets: 1, overs: 4, conceded: 12, result: 'WIN', innings: 2, 
      desc: 'Lightning Fifty + Chase Master + Economy Class'
    },
    {
      id: 'mock-match-3',
      runs: 15, balls: 10, fours: 2, sixes: 6, wickets: 0, overs: 2, conceded: 35, result: 'LOSS', innings: 1, 
      desc: 'Hitman Show (6 sixes)'
    }
  ]

  for (const m of matches) {
    // Ensure match exists
    await prisma.match.upsert({
      where: { id: m.id },
      update: { status: 'COMPLETED', verificationLevel: 'LEVEL_3' },
      create: {
        id: m.id,
        matchType: 'FRIENDLY',
        format: 'T20',
        status: 'COMPLETED',
        verificationLevel: 'LEVEL_3',
        teamAName: 'Parth XI',
        teamBName: 'Opponent XI',
        teamAPlayerIds: [profileId],
        teamBPlayerIds: [],
        scheduledAt: new Date(),
        completedAt: new Date(),
        winnerId: m.result === 'WIN' ? 'A' : 'B'
      }
    })

    await prisma.matchPlayerFact.upsert({
      where: { matchId_playerId: { matchId: m.id, playerId: profileId } },
      update: {},
      create: {
        matchId: m.id,
        playerId: profileId,
        teamId: 'Parth XI',
        opponentTeamId: 'Opponent XI',
        inningsNo: m.innings,
        didBat: true,
        runs: m.runs,
        ballsFaced: m.balls,
        fours: m.fours,
        sixes: m.sixes,
        wasNotOut: m.innings === 2 && m.result === 'WIN',
        didBowl: true,
        oversBowled: m.overs,
        ballsBowled: m.overs * 6,
        wickets: m.wickets,
        runsConceded: m.conceded,
        dotBalls: 15,
        result: m.result as any,
        matchFormat: 'T20',
        matchDate: new Date()
      }
    })
  }

  // 2. Create Aggregate record
  await prisma.playerIndexAggregate.upsert({
    where: { playerId: profileId },
    update: {
      currentSwingIndex: 88.4,
      currentBattingIndex: 92,
      currentBowlingIndex: 81,
      currentFieldingIndex: 85,
      currentPhysicalIndex: 78,
      currentClutchIndex: 95,
      currentRankKey: 'PHANTOM',
      currentDivision: 1,
      lifetimeImpactPoints: 12500
    },
    create: {
      playerId: profileId,
      currentSwingIndex: 88.4,
      currentBattingIndex: 92,
      currentBowlingIndex: 81,
      currentFieldingIndex: 85,
      currentPhysicalIndex: 78,
      currentClutchIndex: 95,
      currentRankKey: 'PHANTOM',
      currentDivision: 1,
      lifetimeImpactPoints: 12500
    }
  })

  // 3. Wellness Check-ins
  await prisma.playerWellnessCheckin.upsert({
    where: { playerId_date: { playerId: profileId, date: new Date() } },
    update: { soreness: 2, fatigue: 3, sleepQuality: 9, mood: 8, stress: 2 },
    create: {
      playerId: profileId,
      date: new Date(),
      soreness: 2,
      fatigue: 3,
      sleepQuality: 9,
      mood: 8,
      stress: 2,
      energyLevel: 8,
      stressLevel: 2,
      wellnessScore: 85
    }
  })

  console.log('✅ Parth Gupta mock data populated.')
}

main().catch(console.error).finally(() => prisma.$disconnect())
