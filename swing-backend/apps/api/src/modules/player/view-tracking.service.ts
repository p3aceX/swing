import { prisma } from '@swing/db'

export class ViewTrackingService {
  // Deduplicate: one view per viewer per profile per hour
  async trackProfileView(profileId: string, viewerUserId?: string | null) {
    const viewerId = viewerUserId
      ? (await prisma.playerProfile.findUnique({ where: { userId: viewerUserId }, select: { id: true } }))?.id ?? null
      : null

    // Skip self-views
    if (viewerId && viewerId === profileId) return

    // Deduplicate within 1 hour
    if (viewerId) {
      const recent = await prisma.profileView.findFirst({
        where: {
          profileId,
          viewerId,
          viewedAt: { gte: new Date(Date.now() - 60 * 60 * 1000) },
        },
      })
      if (recent) return
    }

    await prisma.profileView.create({ data: { profileId, viewerId } })
  }

  async trackMatchView(matchId: string, viewerUserId?: string | null) {
    const viewerId = viewerUserId
      ? (await prisma.playerProfile.findUnique({ where: { userId: viewerUserId }, select: { id: true } }))?.id ?? null
      : null

    // Deduplicate within 1 hour
    if (viewerId) {
      const recent = await prisma.matchView.findFirst({
        where: {
          matchId,
          viewerId,
          viewedAt: { gte: new Date(Date.now() - 60 * 60 * 1000) },
        },
      })
      if (recent) return
    }

    await prisma.matchView.create({ data: { matchId, viewerId } })
  }

  async trackTournamentView(tournamentId: string, viewerUserId?: string | null) {
    const viewerId = viewerUserId
      ? (await prisma.playerProfile.findUnique({ where: { userId: viewerUserId }, select: { id: true } }))?.id ?? null
      : null

    if (viewerId) {
      const recent = await prisma.tournamentView.findFirst({
        where: {
          tournamentId,
          viewerId,
          viewedAt: { gte: new Date(Date.now() - 60 * 60 * 1000) },
        },
      })
      if (recent) return
    }

    await prisma.tournamentView.create({ data: { tournamentId, viewerId } })
  }

  async getProfileViewStats(profileId: string) {
    const [total, last7days, last30days, uniqueViewers] = await Promise.all([
      prisma.profileView.count({ where: { profileId } }),
      prisma.profileView.count({ where: { profileId, viewedAt: { gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) } } }),
      prisma.profileView.count({ where: { profileId, viewedAt: { gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) } } }),
      prisma.profileView.groupBy({ by: ['viewerId'], where: { profileId, viewerId: { not: null } } }).then(r => r.length),
    ])
    return { total, last7days, last30days, uniqueViewers }
  }

  async getMatchViewStats(matchId: string) {
    const [total, uniqueViewers] = await Promise.all([
      prisma.matchView.count({ where: { matchId } }),
      prisma.matchView.groupBy({ by: ['viewerId'], where: { matchId, viewerId: { not: null } } }).then(r => r.length),
    ])
    return { total, uniqueViewers }
  }

  async getTournamentViewStats(tournamentId: string) {
    const [total, last7days, uniqueViewers] = await Promise.all([
      prisma.tournamentView.count({ where: { tournamentId } }),
      prisma.tournamentView.count({ where: { tournamentId, viewedAt: { gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) } } }),
      prisma.tournamentView.groupBy({ by: ['viewerId'], where: { tournamentId, viewerId: { not: null } } }).then(r => r.length),
    ])
    return { total, last7days, uniqueViewers }
  }
}
