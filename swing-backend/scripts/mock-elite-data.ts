import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function main() {
  const profileId = 'cmn3z1ai60012q2vxoe1ehg02' // Parineeti Profile
  const matchId = 'cmn1yc6v7000afu37fj3lhrkf'

  console.log(`🚀 Mocking Elite Data for Profile: ${profileId}`)

  // 1. Create a MatchPlayerFact
  await prisma.matchPlayerFact.upsert({
    where: { matchId_playerId: { matchId, playerId: profileId } },
    update: {},
    create: {
      matchId,
      playerId: profileId,
      teamId: 'Ankur Cricket Academy',
      opponentTeamId: 'Raisen Cricket Academy',
      inningsNo: 1,
      didBat: true,
      runs: 75,
      ballsFaced: 35,
      fours: 8,
      sixes: 3,
      wasNotOut: false,
      dismissalType: 'CAUGHT',
      didBowl: true,
      oversBowled: 4,
      ballsBowled: 24,
      wickets: 3,
      runsConceded: 22,
      dotBalls: 12,
      result: 'WIN',
      matchFormat: 'T20',
      matchDate: new Date()
    }
  })

  // 2. Create an Aggregate record
  await prisma.playerIndexAggregate.upsert({
    where: { playerId: profileId },
    update: {
      currentSwingIndex: 82.5,
      currentBattingIndex: 88,
      currentBowlingIndex: 75,
      currentFieldingIndex: 80,
      currentPhysicalIndex: 90,
      currentClutchIndex: 85,
      currentRankKey: 'VANGUARD',
      currentDivision: 2,
      lifetimeImpactPoints: 4500
    },
    create: {
      playerId: profileId,
      currentSwingIndex: 82.5,
      currentBattingIndex: 88,
      currentBowlingIndex: 75,
      currentFieldingIndex: 80,
      currentPhysicalIndex: 90,
      currentClutchIndex: 85,
      currentRankKey: 'VANGUARD',
      currentDivision: 2,
      lifetimeImpactPoints: 4500
    }
  })

  // 3. Create a Team link
  const team = await prisma.team.findFirst({ where: { name: 'Ankur Cricket Academy' } })
  if (team) {
    if (!team.playerIds.includes(profileId)) {
      await prisma.team.update({
        where: { id: team.id },
        data: { playerIds: { push: profileId } }
      })
    }
  }

  console.log('✅ Mock data ready.')
}

main().catch(console.error).finally(() => prisma.$disconnect())
