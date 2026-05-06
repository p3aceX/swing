/**
 * Backfill OWNER MatchRole rows for arena owners on every matchmaking-flow
 * cricket Match. Without this row, resolveMatchRole returns null for the
 * arena owner — they can't edit/start/delete the match from the Play tab.
 *
 * Walks every MatchmakingMatch that has linkedMatchId, resolves the ground's
 * arena owner profile, and upserts the OWNER role.
 *
 * Run: npx tsx scripts/backfill-arena-owner-match-roles.ts [--dry-run]
 */

import { prisma } from '@swing/db'

async function main() {
  const dryRun = process.argv.includes('--dry-run')
  console.log(`[backfill-arena-owner-roles] dry-run=${dryRun}`)

  const mmMatches = await prisma.matchmakingMatch.findMany({
    where: { linkedMatchId: { not: null } },
    select: { id: true, linkedMatchId: true, groundId: true },
  })
  console.log(`Found ${mmMatches.length} matchmaking matches with linkedMatchId`)

  let granted = 0
  let alreadyOk = 0
  let skipped = 0
  const issues: string[] = []

  for (const mm of mmMatches) {
    const linkedMatchId = mm.linkedMatchId!
    const unit = await prisma.arenaUnit.findUnique({
      where: { id: mm.groundId },
      include: { arena: { include: { owner: true } } },
    })
    const ownerUserId = unit?.arena?.owner?.userId
    if (!ownerUserId) {
      skipped++
      issues.push(`mm ${mm.id}: no arena owner (groundId=${mm.groundId})`)
      continue
    }
    const ownerProfile = await prisma.playerProfile.findUnique({
      where: { userId: ownerUserId },
      select: { id: true },
    })
    if (!ownerProfile) {
      skipped++
      issues.push(`mm ${mm.id}: arena owner has no PlayerProfile (userId=${ownerUserId})`)
      continue
    }

    const existing = await prisma.matchRole.findUnique({
      where: {
        matchId_profileId_role: {
          matchId: linkedMatchId,
          profileId: ownerProfile.id,
          role: 'OWNER',
        },
      },
    })
    if (existing) {
      alreadyOk++
      continue
    }

    console.log(
      `  Granting OWNER on match ${linkedMatchId} → profile ${ownerProfile.id}` +
      ` (mm=${mm.id})`
    )
    if (!dryRun) {
      await prisma.matchRole.create({
        data: {
          matchId: linkedMatchId,
          profileId: ownerProfile.id,
          role: 'OWNER',
          grantedBy: ownerProfile.id,
        },
      })
    }
    granted++
  }

  console.log(`Done — granted=${granted} alreadyOk=${alreadyOk} skipped=${skipped}`)
  if (issues.length) {
    console.log(`Issues:`)
    for (const i of issues) console.log(`  ${i}`)
  }
}

main().catch((e) => { console.error(e); process.exit(1) }).finally(() => prisma.$disconnect())
