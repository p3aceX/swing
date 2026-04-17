import { prisma } from '@swing/db'
import { AppError, Errors } from '../../lib/errors'
import { NotificationService } from '../notifications/notification.service'

const notificationSvc = new NotificationService()

export class FollowService {
  private async getProfile(userId: string) {
    const profile = await prisma.playerProfile.findUnique({ where: { userId } })
    if (!profile) throw Errors.notFound('Player profile')
    return profile
  }

  // ── Player follow ──────────────────────────────────────────────

  async followPlayer(userId: string, targetPlayerId: string) {
    const me = await this.getProfile(userId)
    if (me.id === targetPlayerId) {
      throw new AppError('INVALID_ACTION', 'You cannot follow yourself', 400)
    }

    const target = await prisma.playerProfile.findUnique({
      where: { id: targetPlayerId },
      include: { user: { select: { id: true, name: true } } },
    })
    if (!target) throw Errors.notFound('Player')

    const existing = await prisma.playerFollow.findUnique({
      where: { followerPlayerId_followingPlayerId: { followerPlayerId: me.id, followingPlayerId: targetPlayerId } },
    })
    if (existing) return { alreadyFollowing: true }

    await prisma.playerFollow.create({
      data: { followerPlayerId: me.id, followingPlayerId: targetPlayerId },
    })

    // Notify the target player
    const myUser = await prisma.user.findUnique({ where: { id: userId }, select: { name: true } })
    await notificationSvc.createNotification(target.user.id, {
      type: 'NEW_FOLLOWER',
      title: 'New follower',
      body: `${myUser?.name ?? 'Someone'} started following you`,
      entityType: 'PLAYER',
      entityId: me.id,
      sendPush: true,
      preferenceKey: 'newFollowers',
    })

    return { following: true }
  }

  async unfollowPlayer(userId: string, targetPlayerId: string) {
    const me = await this.getProfile(userId)
    await prisma.playerFollow.deleteMany({
      where: { followerPlayerId: me.id, followingPlayerId: targetPlayerId },
    })
    return { following: false }
  }

  async getFollowers(playerId: string, page = 1, limit = 20) {
    const skip = (page - 1) * limit
    const [followers, total] = await Promise.all([
      prisma.playerFollow.findMany({
        where: { followingPlayerId: playerId },
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          follower: {
            include: { user: { select: { name: true, avatarUrl: true } } },
          },
        },
      }),
      prisma.playerFollow.count({ where: { followingPlayerId: playerId } }),
    ])

    return {
      followers: followers.map(f => ({
        playerId: f.follower.id,
        username: f.follower.username,
        name: f.follower.user.name,
        avatarUrl: f.follower.user.avatarUrl,
        followedAt: f.createdAt,
      })),
      total,
      page,
      limit,
    }
  }

  async getFollowing(userId: string, page = 1, limit = 20) {
    const me = await this.getProfile(userId)
    const skip = (page - 1) * limit
    const [following, total] = await Promise.all([
      prisma.playerFollow.findMany({
        where: { followerPlayerId: me.id },
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          following: {
            include: { user: { select: { name: true, avatarUrl: true } } },
          },
        },
      }),
      prisma.playerFollow.count({ where: { followerPlayerId: me.id } }),
    ])

    return {
      following: following.map(f => ({
        playerId: f.following.id,
        username: f.following.username,
        name: f.following.user.name,
        avatarUrl: f.following.user.avatarUrl,
        followedAt: f.createdAt,
      })),
      total,
      page,
      limit,
    }
  }

  // ── Team follow ────────────────────────────────────────────────

  async followTeam(userId: string, teamId: string) {
    const me = await this.getProfile(userId)
    const team = await prisma.team.findUnique({ where: { id: teamId } })
    if (!team) throw Errors.notFound('Team')

    await prisma.follow.upsert({
      where: { followerId_targetId_targetType: { followerId: me.id, targetId: teamId, targetType: 'TEAM' } },
      create: { followerId: me.id, targetId: teamId, targetType: 'TEAM' },
      update: {},
    })
    return { following: true }
  }

  async unfollowTeam(userId: string, teamId: string) {
    const me = await this.getProfile(userId)
    await prisma.follow.deleteMany({
      where: { followerId: me.id, targetId: teamId, targetType: 'TEAM' },
    })
    return { following: false }
  }

  async getTeamFollowerCount(teamId: string) {
    return prisma.follow.count({ where: { targetId: teamId, targetType: 'TEAM' } })
  }

  // ── Tournament follow ──────────────────────────────────────────

  async followTournament(userId: string, tournamentId: string) {
    const me = await this.getProfile(userId)
    const tournament = await prisma.tournament.findUnique({ where: { id: tournamentId } })
    if (!tournament) throw Errors.notFound('Tournament')

    await prisma.follow.upsert({
      where: { followerId_targetId_targetType: { followerId: me.id, targetId: tournamentId, targetType: 'TOURNAMENT' } },
      create: { followerId: me.id, targetId: tournamentId, targetType: 'TOURNAMENT' },
      update: {},
    })
    return { following: true }
  }

  async unfollowTournament(userId: string, tournamentId: string) {
    const me = await this.getProfile(userId)
    await prisma.follow.deleteMany({
      where: { followerId: me.id, targetId: tournamentId, targetType: 'TOURNAMENT' },
    })
    return { following: false }
  }

  async getTournamentFollowerCount(tournamentId: string) {
    return prisma.follow.count({ where: { targetId: tournamentId, targetType: 'TOURNAMENT' } })
  }

  // ── Check if following ─────────────────────────────────────────

  async isFollowingPlayer(userId: string, targetPlayerId: string) {
    const me = await prisma.playerProfile.findUnique({ where: { userId }, select: { id: true } })
    if (!me) return false
    const row = await prisma.playerFollow.findUnique({
      where: { followerPlayerId_followingPlayerId: { followerPlayerId: me.id, followingPlayerId: targetPlayerId } },
    })
    return !!row
  }

  async isFollowingEntity(userId: string, targetId: string, targetType: 'TEAM' | 'TOURNAMENT') {
    const me = await prisma.playerProfile.findUnique({ where: { userId }, select: { id: true } })
    if (!me) return false
    const row = await prisma.follow.findUnique({
      where: { followerId_targetId_targetType: { followerId: me.id, targetId, targetType } },
    })
    return !!row
  }
}
