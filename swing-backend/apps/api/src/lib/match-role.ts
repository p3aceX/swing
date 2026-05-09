import { prisma } from '@swing/db'

/**
 * Effective role of a caller on a match.
 *
 *   'owner'    → full authority. Created the match (or was added explicitly
 *                as MatchRole(OWNER)). Can edit, delete, patch, assign or
 *                revoke a scorer, and record balls.
 *   'manager'  → owner-equivalent for management actions (edit, delete,
 *                assign scorer). Can also record balls.
 *   'scorer'   → assigned by an owner or manager. Can record balls. Cannot
 *                manage the match.
 *   null       → read-only.
 *
 * Captain seats on the match are pure metadata — they have no permission
 * implication. If the captain wants to score, the owner has to assign them
 * via assignScorer.
 */
export type MatchRoleValue = 'owner' | 'manager' | 'scorer' | null

/** Highest role the profile holds on the match. */
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
      select: { scorerId: true, activeScorerId: true },
    }),
  ])

  if (!match) return null

  const roleSet = new Set(roles.map((r) => r.role))
  if (roleSet.has('OWNER')) return 'owner'
  if (roleSet.has('MANAGER')) return 'manager'
  if (roleSet.has('SCORER')) return 'scorer'

  // Legacy fallback for matches that predate MatchRole — promote the
  // historical scorerId field to OWNER. Phase 5 backfill will eliminate
  // this path eventually.
  if (match.scorerId === profileId) return 'owner'

  // Active scorer assignment (post-create) doesn't auto-create a role row in
  // every flow, so honour it as a SCORER fallback.
  if (match.activeScorerId === profileId) return 'scorer'

  return null
}

/** Same as `resolveMatchRole` but batched across many matches. */
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
      select: { id: true, scorerId: true, activeScorerId: true },
    }),
  ])

  const rolesByMatch = new Map<string, Set<string>>()
  for (const r of roles) {
    if (!rolesByMatch.has(r.matchId)) rolesByMatch.set(r.matchId, new Set())
    rolesByMatch.get(r.matchId)!.add(r.role)
  }

  const matchMap = new Map(matches.map((m) => [m.id, m]))
  const result = new Map<string, MatchRoleValue>()

  for (const matchId of matchIds) {
    const roleSet = rolesByMatch.get(matchId) ?? new Set()
    const m = matchMap.get(matchId)

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
    if (m?.scorerId === profileId) {
      result.set(matchId, 'owner')
      continue
    }
    if (m?.activeScorerId === profileId) {
      result.set(matchId, 'scorer')
      continue
    }
    result.set(matchId, null)
  }

  return result
}
