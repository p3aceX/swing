import { prisma } from '@swing/db'

export type MatchRoleValue = 'owner' | 'manager' | 'scorer' | null

/**
 * Resolves the highest role a profile holds on a match.
 *
 * Priority: OWNER > MANAGER > SCORER > null
 *
 * Falls back to legacy scorerId / teamACaptainId / teamBCaptainId for matches
 * that predate the MatchRole table (Phase 5 backfill will eliminate this path).
 */
export async function resolveMatchRole(
  profileId: string,
  matchId: string,
): Promise<MatchRoleValue> {
  const [roles, match] = await Promise.all([
    prisma.matchRole.findMany({
      where: { matchId, profileId },
      select: { role: true },
    }),
    prisma.match.findUnique({
      where: { id: matchId },
      select: {
        scorerId: true,
        teamACaptainId: true,
        teamBCaptainId: true,
        activeScorerId: true,
        tournamentId: true,
      },
    }),
  ])

  if (!match) return null

  const roleSet = new Set(roles.map((r) => r.role))

  if (roleSet.has('OWNER')) return 'owner'
  if (roleSet.has('MANAGER')) return 'manager'
  if (roleSet.has('SCORER')) return 'scorer'

  // Legacy fallback — matches without MatchRole rows yet
  if (match.scorerId === profileId) return 'owner'

  // For non-tournament matches, captains are managers
  if (!match.tournamentId) {
    if (
      match.teamACaptainId === profileId ||
      match.teamBCaptainId === profileId
    ) {
      return 'manager'
    }
  }

  return null
}

/**
 * Batch-resolves roles for multiple matches at once (used in list endpoints).
 * Returns a Map of matchId → role.
 */
export async function resolveMatchRoleBatch(
  profileId: string,
  matchIds: string[],
): Promise<Map<string, MatchRoleValue>> {
  if (matchIds.length === 0) return new Map()

  const [roles, matches] = await Promise.all([
    prisma.matchRole.findMany({
      where: { matchId: { in: matchIds }, profileId },
      select: { matchId: true, role: true },
    }),
    prisma.match.findMany({
      where: { id: { in: matchIds } },
      select: {
        id: true,
        scorerId: true,
        teamACaptainId: true,
        teamBCaptainId: true,
        tournamentId: true,
      },
    }),
  ])

  // Group MatchRole rows by matchId
  const rolesByMatch = new Map<string, Set<string>>()
  for (const r of roles) {
    if (!rolesByMatch.has(r.matchId)) rolesByMatch.set(r.matchId, new Set())
    rolesByMatch.get(r.matchId)!.add(r.role)
  }

  const matchMap = new Map(matches.map((m) => [m.id, m]))
  const result = new Map<string, MatchRoleValue>()

  for (const matchId of matchIds) {
    const roleSet = rolesByMatch.get(matchId) ?? new Set()
    const match = matchMap.get(matchId)

    if (roleSet.has('OWNER')) {
      result.set(matchId, 'owner')
      continue
    }
    if (roleSet.has('MANAGER')) {
      result.set(matchId, 'manager')
      continue
    }
    if (roleSet.has('SCORER')) {
      result.set(matchId, 'scorer')
      continue
    }

    // Legacy fallback
    if (match?.scorerId === profileId) {
      result.set(matchId, 'owner')
      continue
    }
    if (
      !match?.tournamentId &&
      (match?.teamACaptainId === profileId ||
        match?.teamBCaptainId === profileId)
    ) {
      result.set(matchId, 'manager')
      continue
    }

    result.set(matchId, null)
  }

  return result
}
