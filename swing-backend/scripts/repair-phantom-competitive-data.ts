import { PrismaClient } from '@prisma/client'
import { PerformanceService } from '../apps/api/src/modules/performance/performance.service'

type PhantomRow = {
  id: string
  playerId: string
  matchId: string
}

type OverlapRow = {
  id: string
  teamAPlayerIds: string[]
  teamBPlayerIds: string[]
}

const prisma = new PrismaClient()
const performanceService = new PerformanceService()

function unique(values: string[]) {
  return Array.from(new Set(values.filter(Boolean)))
}

async function resolveProfileIds(rawIds: string[]) {
  const normalizedIds = unique(rawIds.map((value) => value.trim()))
  if (normalizedIds.length === 0) return []

  const profiles = await prisma.playerProfile.findMany({
    where: {
      OR: [
        { id: { in: normalizedIds } },
        { userId: { in: normalizedIds } },
      ],
    },
    select: { id: true, userId: true },
  })

  const profileIdByRawId = new Map<string, string>()
  for (const profile of profiles) {
    profileIdByRawId.set(profile.id, profile.id)
    profileIdByRawId.set(profile.userId, profile.id)
  }

  return unique(
    normalizedIds
      .map((value) => profileIdByRawId.get(value))
      .filter((value): value is string => Boolean(value)),
  )
}

async function fetchAudit() {
  const [phantomFacts, phantomMetrics, phantomScores, overlaps] = await Promise.all([
    prisma.$queryRaw<PhantomRow[]>`
      SELECT mpf.id, mpf."playerId", mpf."matchId"
      FROM match_player_facts mpf
      JOIN "Match" m ON m.id = mpf."matchId"
      WHERE NOT (mpf."playerId" = ANY(m."teamAPlayerIds"))
        AND NOT (mpf."playerId" = ANY(m."teamBPlayerIds"))
      ORDER BY mpf."matchId", mpf."playerId"
    `,
    prisma.$queryRaw<PhantomRow[]>`
      SELECT mpm.id, mpm."playerId", mpm."matchId"
      FROM match_player_metrics mpm
      JOIN "Match" m ON m.id = mpm."matchId"
      WHERE NOT (mpm."playerId" = ANY(m."teamAPlayerIds"))
        AND NOT (mpm."playerId" = ANY(m."teamBPlayerIds"))
      ORDER BY mpm."matchId", mpm."playerId"
    `,
    prisma.$queryRaw<PhantomRow[]>`
      SELECT mpis.id, mpis."playerId", mpis."matchId"
      FROM match_player_index_scores mpis
      JOIN "Match" m ON m.id = mpis."matchId"
      WHERE NOT (mpis."playerId" = ANY(m."teamAPlayerIds"))
        AND NOT (mpis."playerId" = ANY(m."teamBPlayerIds"))
      ORDER BY mpis."matchId", mpis."playerId"
    `,
    prisma.$queryRaw<OverlapRow[]>`
      SELECT id, "teamAPlayerIds", "teamBPlayerIds"
      FROM "Match"
      WHERE "teamAPlayerIds" && "teamBPlayerIds" = true
      ORDER BY "scheduledAt" DESC
    `,
  ])

  return { phantomFacts, phantomMetrics, phantomScores, overlaps }
}

async function main() {
  const args = new Set(process.argv.slice(2))
  const apply = args.has('--apply')
  const fullRebuild = args.has('--full-rebuild')

  const audit = await fetchAudit()
  const affectedMatchIds = unique([
    ...audit.phantomFacts.map((row) => row.matchId),
    ...audit.phantomMetrics.map((row) => row.matchId),
    ...audit.phantomScores.map((row) => row.matchId),
  ])
  const directlyAffectedPlayerIds = unique([
    ...audit.phantomFacts.map((row) => row.playerId),
    ...audit.phantomMetrics.map((row) => row.playerId),
    ...audit.phantomScores.map((row) => row.playerId),
  ])

  const affectedMatches = affectedMatchIds.length > 0
    ? await prisma.match.findMany({
        where: { id: { in: affectedMatchIds } },
        select: {
          id: true,
          scheduledAt: true,
          teamAName: true,
          teamBName: true,
          teamAPlayerIds: true,
          teamBPlayerIds: true,
          status: true,
          verificationLevel: true,
        },
        orderBy: { scheduledAt: 'asc' },
      })
    : []
  const rosterPlayerIds = await resolveProfileIds(
    affectedMatches.flatMap((match) => [...match.teamAPlayerIds, ...match.teamBPlayerIds]),
  )
  const rebuildPlayerIds = fullRebuild
    ? (await prisma.playerProfile.findMany({ select: { id: true } })).map((player) => player.id)
    : unique([...directlyAffectedPlayerIds, ...rosterPlayerIds])

  console.log(JSON.stringify({
    apply,
    fullRebuild,
    phantomFacts: audit.phantomFacts.length,
    phantomMetrics: audit.phantomMetrics.length,
    phantomScores: audit.phantomScores.length,
    overlaps: audit.overlaps.length,
    affectedMatches: affectedMatchIds.length,
    directlyAffectedPlayers: directlyAffectedPlayerIds.length,
    rebuildPlayers: rebuildPlayerIds.length,
  }, null, 2))

  if (audit.phantomFacts.length > 0) {
    console.table(audit.phantomFacts)
  }
  if (audit.phantomScores.length > 0) {
    console.table(audit.phantomScores)
  }
  if (audit.overlaps.length > 0) {
    console.table(audit.overlaps.map((row) => ({ matchId: row.id })))
  }
  if (!apply) {
    return
  }

  if (audit.overlaps.length > 0) {
    throw new Error('Aborting repair because at least one match has overlapping playing XI player IDs. Resolve those matches manually first.')
  }

  const [deletedFacts, deletedMetrics, deletedScores] = await prisma.$transaction([
    prisma.$executeRawUnsafe(`
      DELETE FROM match_player_facts mpf
      USING "Match" m
      WHERE m.id = mpf."matchId"
        AND NOT (mpf."playerId" = ANY(m."teamAPlayerIds"))
        AND NOT (mpf."playerId" = ANY(m."teamBPlayerIds"))
    `),
    prisma.$executeRawUnsafe(`
      DELETE FROM match_player_metrics mpm
      USING "Match" m
      WHERE m.id = mpm."matchId"
        AND NOT (mpm."playerId" = ANY(m."teamAPlayerIds"))
        AND NOT (mpm."playerId" = ANY(m."teamBPlayerIds"))
    `),
    prisma.$executeRawUnsafe(`
      DELETE FROM match_player_index_scores mpis
      USING "Match" m
      WHERE m.id = mpis."matchId"
        AND NOT (mpis."playerId" = ANY(m."teamAPlayerIds"))
        AND NOT (mpis."playerId" = ANY(m."teamBPlayerIds"))
    `),
  ])

  let processedMatches = 0
  let skippedMatches = 0
  let failedMatches = 0

  for (const match of affectedMatches) {
    try {
      const result = await performanceService.processVerifiedMatch(match.id, {
        allowUnverified: true,
      })

      if (result.processed) {
        processedMatches += 1
        console.log(`Reprocessed ${match.id}: players=${result.players}, mvp=${result.mvpPlayerId ?? 'n/a'}`)
      } else {
        skippedMatches += 1
        console.log(`Skipped ${match.id}: ${result.reason}`)
      }
    } catch (error) {
      failedMatches += 1
      console.error(`Failed ${match.id}`, error)
    }
  }

  const rebuilt = await performanceService.rebuildPlayersFromCurrentFacts(rebuildPlayerIds)
  const finalAudit = await fetchAudit()

  console.log(JSON.stringify({
    deletedFacts,
    deletedMetrics,
    deletedScores,
    processedMatches,
    skippedMatches,
    failedMatches,
    rebuiltPlayers: rebuilt.rebuiltPlayers,
    seasonId: rebuilt.seasonId,
    remainingPhantomFacts: finalAudit.phantomFacts.length,
    remainingPhantomMetrics: finalAudit.phantomMetrics.length,
    remainingPhantomScores: finalAudit.phantomScores.length,
    remainingOverlaps: finalAudit.overlaps.length,
  }, null, 2))
}

main()
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
