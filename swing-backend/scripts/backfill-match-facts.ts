import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function main() {
  console.log('🚀 Backfilling MatchPlayerFact from PlayerMatchStats...')

  const allStats = await prisma.playerMatchStats.findMany({
    select: {
      matchId: true,
      playerProfileId: true,
      team: true,
      runs: true,
      balls: true,
      fours: true,
      sixes: true,
      isOut: true,
      oversBowled: true,
      wickets: true,
      runsConceded: true,
      catches: true,
      runOuts: true,
      stumpings: true,
      match: true
    }
  })

  console.log(`Found ${allStats.length} stat records to convert.`)

  let count = 0
  for (const s of allStats) {
    await prisma.matchPlayerFact.upsert({
      where: {
        matchId_playerId: {
          matchId: s.matchId,
          playerId: s.playerProfileId
        }
      },
      update: {},
      create: {
        matchId: s.matchId,
        playerId: s.playerProfileId,
        teamId: s.team === 'A' ? s.match.teamAName : s.match.teamBName, // Approximation
        opponentTeamId: s.team === 'A' ? s.match.teamBName : s.match.teamAName,
        inningsNo: s.team === 'A' ? 1 : 2, // Approximation
        didBat: s.runs > 0 || s.balls > 0,
        runs: s.runs,
        ballsFaced: s.balls,
        fours: s.fours,
        sixes: s.sixes,
        wasNotOut: !s.isOut,
        didBowl: s.oversBowled > 0,
        ballsBowled: Math.floor(s.oversBowled * 6),
        oversBowled: s.oversBowled,
        wickets: s.wickets,
        runsConceded: s.runsConceded,
        catches: s.catches,
        runOuts: s.runOuts,
        stumpings: s.stumpings,
        result: s.match.winnerId === s.team ? 'WIN' : 'LOSS',
        matchFormat: s.match.format as any,
        matchDate: s.match.completedAt || s.match.scheduledAt
      }
    })
    count++
  }

  console.log(`✅ Backfilled ${count} records.`)
}

main().catch(console.error).finally(() => prisma.$disconnect())
