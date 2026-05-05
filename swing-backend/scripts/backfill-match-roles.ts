import { prisma } from '@swing/db'

const BATCH = 100

async function main() {
  let cursor: string | undefined
  let processed = 0
  let skipped = 0
  let errors = 0

  console.log('[backfill-match-roles] starting...')

  for (;;) {
    const matches = await prisma.match.findMany({
      take: BATCH,
      ...(cursor ? { skip: 1, cursor: { id: cursor } } : {}),
      orderBy: { id: 'asc' },
      select: {
        id: true,
        scorerId: true,
        teamACaptainId: true,
        teamBCaptainId: true,
        tournamentId: true,
        activeScorerId: true,
      },
    })

    if (matches.length === 0) break
    cursor = matches[matches.length - 1].id

    for (const match of matches) {
      try {
        const existing = await prisma.matchRole.count({ where: { matchId: match.id } })
        if (existing > 0) {
          skipped++
          continue
        }

        const rolesToCreate: {
          id: string
          matchId: string
          profileId: string
          role: 'OWNER' | 'MANAGER' | 'SCORER'
          grantedBy: null
        }[] = []

        if (match.scorerId) {
          rolesToCreate.push({
            id: `backfill-${match.id}-${match.scorerId}-OWNER`,
            matchId: match.id,
            profileId: match.scorerId,
            role: 'OWNER',
            grantedBy: null,
          })
        }

        if (!match.tournamentId) {
          if (match.teamACaptainId && match.teamACaptainId !== match.scorerId) {
            rolesToCreate.push({
              id: `backfill-${match.id}-${match.teamACaptainId}-MANAGER`,
              matchId: match.id,
              profileId: match.teamACaptainId,
              role: 'MANAGER',
              grantedBy: null,
            })
          }
          if (
            match.teamBCaptainId &&
            match.teamBCaptainId !== match.scorerId &&
            match.teamBCaptainId !== match.teamACaptainId
          ) {
            rolesToCreate.push({
              id: `backfill-${match.id}-${match.teamBCaptainId}-MANAGER`,
              matchId: match.id,
              profileId: match.teamBCaptainId,
              role: 'MANAGER',
              grantedBy: null,
            })
          }
        }

        if (rolesToCreate.length === 0) {
          skipped++
          continue
        }

        await prisma.$transaction(async (tx) => {
          await tx.matchRole.createMany({ data: rolesToCreate, skipDuplicates: true })
          if (match.scorerId && !match.activeScorerId) {
            await tx.match.update({
              where: { id: match.id },
              data: { activeScorerId: match.scorerId },
            })
          }
        })

        processed++
        if (processed % 50 === 0) console.log(`  ...${processed} processed`)
      } catch (err) {
        console.error(`  ERROR matchId=${match.id}`, err)
        errors++
      }
    }
  }

  console.log(`[backfill-match-roles] done — processed=${processed} skipped=${skipped} errors=${errors}`)
  await prisma.$disconnect()
}

main().catch((err) => {
  console.error(err)
  process.exit(1)
})
