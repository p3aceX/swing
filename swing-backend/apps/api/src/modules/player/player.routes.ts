import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { createEventRequestSchema, createHostedTournamentRequestSchema } from '@swing/contracts'
import { prisma } from '@swing/db'
import { PlayerService } from './player.service'
import { DevelopmentService } from '../development/development.service'
import { PerformanceService } from '../performance/performance.service'
import { EventService } from '../events/event.service'
import { TournamentService } from '../tournaments/tournament.service'
import { FollowService } from './follow.service'
import { ViewTrackingService } from './view-tracking.service'

const updateProfileSchema = z.object({
  name: z.string().min(2).max(100).optional(),
  username: z.string().min(3).max(20).regex(/^[a-zA-Z0-9._]+$/).optional(),
  dateOfBirth: z.string().optional(),
  gender: z.string().optional(),
  heightCm: z.coerce.number().optional(),
  weightKg: z.coerce.number().optional(),
  waistCircumferenceCm: z.coerce.number().optional(),
  neckCircumferenceCm: z.coerce.number().optional(),
  hipCircumferenceCm: z.coerce.number().optional(),
  city: z.string().optional(),
  state: z.string().optional(),
  playerRole: z.enum(['BATSMAN', 'BOWLER', 'ALL_ROUNDER', 'WICKET_KEEPER', 'WICKET_KEEPER_BATSMAN']).optional(),
  battingStyle: z.enum(['RIGHT_HAND', 'LEFT_HAND']).optional(),
  bowlingStyle: z.enum(['RIGHT_ARM_FAST', 'RIGHT_ARM_MEDIUM', 'RIGHT_ARM_OFFBREAK', 'RIGHT_ARM_LEGBREAK', 'LEFT_ARM_FAST', 'LEFT_ARM_MEDIUM', 'LEFT_ARM_ORTHODOX', 'LEFT_ARM_CHINAMAN', 'NOT_A_BOWLER']).optional(),
  level: z.enum(['CLUB', 'CORPORATE', 'DIVISION', 'STATE', 'IPL', 'INTERNATIONAL']).optional(),
  goals: z.string().optional(),
  jerseyNumber: z.coerce.number().int().min(0).max(999).nullable().optional(),
  bio: z.string().max(500).optional(),
  availableDays: z.array(z.string()).optional(),
  preferredTimes: z.array(z.string()).optional(),
  locationRadius: z.number().min(1).max(100).optional(),
  isPublic: z.boolean().optional(),
  showStats: z.boolean().optional(),
  showLocation: z.boolean().optional(),
  scoutingOptIn: z.boolean().optional(),
  avatarUrl: z.string().url().nullable().optional(),
})

const wellnessCheckinSchema = z.object({
  playerId: z.string().optional(),
  date: z.string(),
  soreness: z.number().int().min(1).max(10),
  fatigue: z.number().int().min(1).max(10),
  mood: z.number().int().min(1).max(10),
  stress: z.number().int().min(1).max(10),
  painTightness: z.number().int().min(1).max(10),
  sleepQuality: z.number().int().min(1).max(10),
  notes: z.string().max(500).optional(),
})

const workloadEventSchema = z.object({
  playerId: z.string().optional(),
  type: z.enum(['MATCH', 'BATTING_NETS', 'BOWLING_NETS', 'FIELDING', 'STRENGTH', 'RUNNING', 'MOBILITY', 'REHAB']),
  date: z.string(),
  durationMinutes: z.number().int().min(1).max(1440),
  intensity: z.number().int().min(1).max(10).optional(),
  oversBowled: z.number().nonnegative().optional(),
  ballsBowled: z.number().int().nonnegative().optional(),
  battingMinutes: z.number().int().nonnegative().optional(),
  ballsFaced: z.number().int().nonnegative().optional(),
  spellCount: z.number().int().nonnegative().optional(),
  source: z.string().max(50).optional(),
  sourceRefId: z.string().max(120).optional(),
  notes: z.string().max(500).optional(),
})

const showcaseItemSchema = z.object({
  type: z.enum(['INSTAGRAM_REEL', 'YOUTUBE_SHORT', 'VIDEO', 'IMAGE', 'MATCH_HIGHLIGHT', 'LINK']),
  title: z.string().max(120).optional(),
  caption: z.string().max(500).optional(),
  url: z.string().url(),
  thumbnailUrl: z.string().url().optional(),
  matchId: z.string().optional(),
  isPinned: z.boolean().optional(),
  sortOrder: z.number().int().min(0).max(999).optional(),
})

const showcaseItemUpdateSchema = z.object({
  title: z.string().max(120).optional(),
  caption: z.string().max(500).optional(),
  url: z.string().url().optional(),
  thumbnailUrl: z.string().url().nullable().optional(),
  matchId: z.string().nullable().optional(),
  isPinned: z.boolean().optional(),
  isActive: z.boolean().optional(),
  sortOrder: z.number().int().min(0).max(999).optional(),
})

export async function playerRoutes(app: FastifyInstance) {
  const svc = new PlayerService()
  const eventSvc = new EventService()
  const tournamentSvc = new TournamentService()
  const developmentSvc = new DevelopmentService()
  const performanceSvc = new PerformanceService()
  const viewTrackingSvc = new ViewTrackingService()
  const auth = { onRequest: [(app as any).authenticate] }

  const resolvePlayerId = async (userId: string, requestedPlayerId?: string) => {
    if (requestedPlayerId) return requestedPlayerId
    const profile = await svc.getOrCreateProfile(userId)
    return profile.id
  }

  app.get('/profile', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.getOwnProfile(user.userId) })
  })

  app.put('/profile', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = updateProfileSchema.parse(request.body)
    return reply.send({ success: true, data: await svc.updateProfile(user.userId, body) })
  })

  // PUT /player/profile/avatar — save avatar URL after frontend uploads to Supabase
  // Body: { avatarUrl: string }  →  saves to User.avatarUrl, returns the URL
  app.put('/profile/avatar', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { avatarUrl } = z.object({ avatarUrl: z.string().url() }).parse(request.body)
    await prisma.user.update({ where: { id: user.userId }, data: { avatarUrl } })
    return reply.send({ success: true, data: { avatarUrl } })
  })

  app.get('/profile/full', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.getOwnFullProfile(user.userId) })
  })

  app.post('/follows/:playerId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { playerId } = request.params as { playerId: string }
    return reply.code(201).send({
      success: true,
      data: await svc.followPlayer(user.userId, playerId),
    })
  })

  app.delete('/follows/:playerId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { playerId } = request.params as { playerId: string }
    return reply.send({
      success: true,
      data: await svc.unfollowPlayer(user.userId, playerId),
    })
  })

  app.get('/follows/:playerId/status', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { playerId } = request.params as { playerId: string }
    return reply.send({
      success: true,
      data: await svc.getFollowStatus(user.userId, playerId),
    })
  })

  app.get('/followers', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const query = z.object({
      playerId: z.string().optional(),
      page: z.coerce.number().int().min(1).optional(),
      limit: z.coerce.number().int().min(1).max(50).optional(),
    }).parse(request.query)
    return reply.send({
      success: true,
      data: await svc.listFollowers(
        user.userId,
        query.playerId,
        query.page ?? 1,
        query.limit ?? 20,
      ),
    })
  })

  app.get('/following', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const query = z.object({
      playerId: z.string().optional(),
      page: z.coerce.number().int().min(1).optional(),
      limit: z.coerce.number().int().min(1).max(50).optional(),
    }).parse(request.query)
    return reply.send({
      success: true,
      data: await svc.listFollowing(
        user.userId,
        query.playerId,
        query.page ?? 1,
        query.limit ?? 20,
      ),
    })
  })

  app.get('/showcase', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({
      success: true,
      data: await svc.getMyShowcase(user.userId),
    })
  })

  app.post('/showcase', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = showcaseItemSchema.parse(request.body)
    return reply.code(201).send({
      success: true,
      data: await svc.createShowcaseItem(user.userId, body),
    })
  })

  app.patch('/showcase/:itemId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { itemId } = request.params as { itemId: string }
    const body = showcaseItemUpdateSchema.parse(request.body)
    return reply.send({
      success: true,
      data: await svc.updateShowcaseItem(user.userId, itemId, body),
    })
  })

  app.delete('/showcase/:itemId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { itemId } = request.params as { itemId: string }
    return reply.send({
      success: true,
      data: await svc.deleteShowcaseItem(user.userId, itemId),
    })
  })

  app.get('/profile/:id/matches', auth, async (request, reply) => {
    const { id } = request.params as { id: string }
    const query = z.object({
      limit: z.coerce.number().int().min(1).max(100).default(30),
      offset: z.coerce.number().int().min(0).default(0),
    }).parse(request.query)

    const data = await svc.getPublicMatchHistory(id, query.limit, query.offset)
    if (!data) {
      return reply.code(404).send({ message: 'Player not found' })
    }

    return reply.send(data)
  })

  app.get('/profile/:id', async (request, reply) => {
    const { id } = request.params as { id: string }
    const user = (request as any).user as { userId: string } | undefined
    const data = await svc.getPublicProfile(id)
    // Fire-and-forget view tracking
    viewTrackingSvc.trackProfileView(id, user?.userId ?? null).catch(() => {})
    return reply.send({ success: true, data })
  })

  app.get('/profile/:id/full', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const data = await svc.getPublicFullProfile(user.userId, id)
    viewTrackingSvc.trackProfileView(id, user.userId).catch(() => {})
    return reply.send({ success: true, data })
  })

  app.get('/stats', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.getStats(user.userId) })
  })

  app.get('/stats/trend', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { days } = request.query as { days?: string }
    return reply.send({ success: true, data: await svc.getIndexTrend(user.userId, Number(days) || 30) })
  })

  app.get('/index', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.getIndex(user.userId) })
  })

  app.get('/index/trend', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { days } = request.query as { days?: string }
    return reply.send({ success: true, data: await svc.getIndexTrend(user.userId, Number(days) || 30) })
  })

  app.get('/index/breakdown', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const query = z.object({
      axis: z.enum(['reliability', 'power', 'bowling', 'fielding', 'impact', 'captaincy']),
      window: z.enum(['MATCH', 'LAST_5', 'LAST_10', 'SEASON', 'LIFETIME']).optional(),
    }).parse(request.query)
    return reply.send({ success: true, data: await svc.getIndexBreakdown(user.userId, query.axis, query.window) })
  })

  app.get('/:playerId/swing-index', auth, async (request, reply) => {
    const { playerId } = z.object({ playerId: z.string().trim().min(1) }).parse(request.params)
    return reply.send({
      success: true,
      data: await performanceSvc.getPlayerSwingIndexDetailed(playerId),
    })
  })

  app.get('/:playerId/swing-index/summary', auth, async (request, reply) => {
    const { playerId } = z.object({ playerId: z.string().trim().min(1) }).parse(request.params)
    return reply.send({
      success: true,
      data: await performanceSvc.getPlayerSwingIndexSummary(playerId),
    })
  })

  app.get('/physical', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.getPhysical(user.userId) })
  })

  app.get('/rank-config', auth, async (_request, reply) => {
    return reply.send({ success: true, data: await svc.getRankConfig() })
  })

  app.get('/season', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.getSeason(user.userId) })
  })

  app.get('/teams/search', auth, async (request, reply) => {
    const q = z.object({
      q: z.string().min(1).max(60),
      limit: z.coerce.number().int().min(1).max(30).optional(),
    }).parse(request.query)
    return reply.send({ success: true, data: await svc.searchTeams(q.q, q.limit || 20) })
  })

  app.get('/teams/:teamId/players', auth, async (request, reply) => {
    const { teamId } = request.params as { teamId: string }
    return reply.send({ success: true, data: await svc.getTeamPlayers(teamId) })
  })

  app.post('/teams/:teamId/players/quick-add', auth, async (request, reply) => {
    const { teamId } = request.params as { teamId: string }
    const body = z.object({
      profileId: z.string().optional(),
      name: z.string().min(1).max(80).optional(),
      phone: z.string().min(10).max(20).optional(),
      swingId: z.string().min(4).max(20).optional(),
    }).parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.quickAddToTeam(teamId, body) })
  })

  app.get('/teams', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.getMyTeams(user.userId) })
  })

  app.post('/teams', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = z.object({
      name: z.string().min(1).max(80),
      shortName: z.string().max(6).optional(),
      city: z.string().max(60).optional(),
      teamType: z.enum(['FRIENDLY', 'CLUB', 'ACADEMY', 'CORPORATE']).optional(),
      iAmCaptain: z.boolean().optional(),
      academyId: z.string().optional(),
      coachId: z.string().optional(),
      arenaId: z.string().optional(),
    }).parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.createTeam(user.userId, body) })
  })

  app.patch('/teams/:id', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = z.object({
      name: z.string().min(1).max(80).optional(),
      shortName: z.string().max(6).optional(),
      city: z.string().max(60).optional(),
      teamType: z.enum(['FRIENDLY', 'CLUB', 'ACADEMY', 'CORPORATE']).optional(),
      logoUrl: z.string().url().optional(),
      captainId: z.string().optional(),
      viceCaptainId: z.string().optional(),
      wicketKeeperId: z.string().optional(),
      isActive: z.boolean().optional(),
    }).parse(request.body)
    return reply.send({ success: true, data: await svc.updateTeam(user.userId, id, body) })
  })

  app.delete('/teams/:id', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.deleteTeam(user.userId, id) })
  })

  app.delete('/teams/:id/players/:playerId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id, playerId } = request.params as { id: string; playerId: string }
    return reply.send({ success: true, data: await svc.removePlayerFromTeam(user.userId, id, playerId) })
  })

  app.get('/matches', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const q = request.query as { page?: string; limit?: string }
    return reply.send({ success: true, data: await svc.getMatchHistory(user.userId, Number(q.page) || 1, Number(q.limit) || 20) })
  })

  app.get('/search', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const q = z.object({
      q: z.string().trim().min(1).max(80),
      limit: z.coerce.number().int().min(1).max(30).optional(),
      type: z.enum(['all', 'players', 'teams', 'venues', 'tournaments', 'events']).optional(),
      city: z.string().trim().min(1).max(80).optional(),
      playerRole: z.enum(['BATSMAN', 'BOWLER', 'ALL_ROUNDER', 'WICKET_KEEPER', 'WICKET_KEEPER_BATSMAN']).optional(),
      playerLevel: z.enum(['CLUB', 'CORPORATE', 'DIVISION', 'STATE', 'IPL', 'INTERNATIONAL']).optional(),
      teamType: z.enum(['CLUB', 'CORPORATE', 'ACADEMY', 'SCHOOL', 'COLLEGE', 'DISTRICT', 'STATE', 'NATIONAL', 'FRIENDLY', 'GULLY']).optional(),
      sport: z.enum(['CRICKET', 'FUTSAL', 'PICKLEBALL', 'BADMINTON', 'FOOTBALL', 'BASKETBALL', 'TENNIS', 'OTHER']).optional(),
      format: z.enum(['T10', 'T20', 'ONE_DAY', 'TWO_INNINGS', 'BOX_CRICKET', 'CUSTOM', 'TEST']).optional(),
      tournamentStatus: z.string().trim().min(1).max(40).optional(),
    }).parse(request.query)
    const limit = q.limit || 12
    const searchType = q.type || 'all'

    const [players, teams, venues, tournaments, events] = await Promise.all([
      searchType === 'all' || searchType === 'players'
        ? svc.searchPlayers(user.userId, q.q, limit, {
            city: q.city,
            playerRole: q.playerRole,
            playerLevel: q.playerLevel,
          })
        : [],
      searchType === 'all' || searchType === 'teams'
        ? svc.searchTeamsWithFilters(q.q, limit, {
            city: q.city,
            teamType: q.teamType,
          })
        : [],
      searchType === 'all' || searchType === 'venues'
        ? svc.searchVenues(q.q, limit, {
            city: q.city,
          })
        : [],
      searchType === 'all' || searchType === 'tournaments'
        ? tournamentSvc.searchTournaments(q.q, limit, {
            city: q.city,
            format: q.format,
            tournamentStatus: q.tournamentStatus,
            sport: q.sport,
          })
        : [],
      searchType === 'all' || searchType === 'events'
        ? eventSvc.searchEvents(q.q, limit)
        : [],
    ])

    return reply.send({
      success: true,
      data: {
        players:     (players     as any[]).map((p) => ({ ...p, _type: 'player'     })),
        teams:       (teams       as any[]).map((t) => ({ ...t, _type: 'team'       })),
        venues:      (venues      as any[]).map((v) => ({ ...v, _type: 'venue'      })),
        tournaments: (tournaments as any[]).map((t) => ({ ...t, _type: 'tournament' })),
        events:      (events      as any[]).map((e) => ({ ...e, _type: 'event'      })),
        counts: {
          players: (players as any[]).length,
          teams: (teams as any[]).length,
          venues: (venues as any[]).length,
          tournaments: (tournaments as any[]).length,
          events: (events as any[]).length,
        },
      },
    })
  })

  app.get('/enrollments', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.getEnrollments(user.userId) })
  })

  app.get('/activity', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const q = z.object({
      limit: z.coerce.number().int().min(1).max(50).optional(),
    }).parse(request.query)
    return reply.send({ success: true, data: await svc.getActivity(user.userId, q.limit || 20) })
  })

  app.get('/badges', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.getBadges(user.userId) })
  })

  app.get('/ip-log', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const q = request.query as { page?: string; limit?: string }
    return reply.send({ success: true, data: await svc.getIpLog(user.userId, Number(q.page) || 1, Number(q.limit) || 20) })
  })

  app.get('/competitive', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.getCompetitiveProfile(user.userId) })
  })

  app.post('/profile/complete-onboarding', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = updateProfileSchema.parse(request.body)
    return reply.send({ success: true, data: await svc.completeOnboarding(user.userId, body) })
  })

  app.get('/gig-bookings', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const q = request.query as { page?: string; limit?: string }
    return reply.send({ success: true, data: await svc.getGigBookings(user.userId, Number(q.page) || 1, Number(q.limit) || 20) })
  })

  app.get('/card', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await developmentSvc.getOwnPlayerCard(user.userId) })
  })

  app.get('/weekly-review', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await developmentSvc.getOwnWeeklyReview(user.userId) })
  })

  app.get('/drill-assignments', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await developmentSvc.getOwnDrillAssignments(user.userId) })
  })

  app.get('/drills', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: { drills: await developmentSvc.getOwnDrillAssignments(user.userId) } })
  })

  app.get('/sessions/live', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await developmentSvc.getOwnActiveSession(user.userId) })
  })

  app.get('/training-plans', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.getTrainingPlans(user.userId) })
  })

  app.get('/feedback', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const q = request.query as { page?: string; limit?: string }
    return reply.send({ success: true, data: await svc.getFeedback(user.userId, Number(q.page) || 1, Number(q.limit) || 20) })
  })

  app.get('/report-cards', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.getReportCards(user.userId) })
  })

  app.post('/drills/:id/log', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = z.object({ quantityDone: z.number().int().positive() }).parse(request.body)
    return reply.code(201).send({ success: true, data: await developmentSvc.logDrillProgress(id, user.userId, body.quantityDone) })
  })

  // ── Hosted tournaments ────────────────────────────────────────────────────

  app.get('/tournaments', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.getMyTournaments(user.userId) })
  })

  app.post('/tournaments', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = createHostedTournamentRequestSchema.parse(request.body)
    return reply.code(201).send({ success: true, data: await tournamentSvc.createHostedTournament(user.userId, body) })
  })

  app.get('/tournaments/:id', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const data = await tournamentSvc.getTournament(user.userId, id)
    viewTrackingSvc.trackTournamentView(id, user.userId).catch(() => {})
    return reply.send({ success: true, data })
  })

  app.patch('/tournaments/:id', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = z.object({
      name: z.string().min(2).optional(),
      status: z.enum(['UPCOMING', 'ONGOING', 'COMPLETED', 'CANCELLED']).optional(),
      description: z.string().nullable().optional(),
      venueName: z.string().optional(),
      city: z.string().optional(),
      startDate: z.string().optional(),
      endDate: z.string().nullable().optional(),
      format: z.enum(['T10', 'T20', 'ONE_DAY', 'TWO_INNINGS', 'BOX_CRICKET', 'CUSTOM']).optional(),
      tournamentFormat: z.enum(['LEAGUE', 'KNOCKOUT', 'GROUP_STAGE_KNOCKOUT', 'DOUBLE_ELIMINATION', 'SUPER_LEAGUE', 'SERIES']).optional(),
      maxTeams: z.number().int().min(2).optional(),
      seriesMatchCount: z.number().int().min(1).max(15).nullable().optional(),
      entryFee: z.number().int().optional(),
      prizePool: z.string().optional(),
      isPublic: z.boolean().optional(),
      logoUrl: z.string().url().nullable().optional(),
      coverUrl: z.string().url().nullable().optional(),
    }).parse(request.body)
    return reply.send({ success: true, data: await tournamentSvc.updateTournament(user.userId, id, body) })
  })

  app.delete('/tournaments/:id', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await tournamentSvc.deleteTournament(user.userId, id) })
  })

  // ── Tournament Teams ──────────────────────────────────────────────────────

  app.get('/tournaments/:id/teams', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await tournamentSvc.listTournamentTeams(user.userId, id) })
  })

  app.post('/tournaments/:id/teams', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = z.object({
      teamId: z.string().optional(),
      teamName: z.string().min(1).optional(),
      captainId: z.string().optional(),
      playerIds: z.array(z.string()).optional(),
    }).refine((v) => v.teamId || v.teamName, { message: 'Either teamId or teamName is required.' })
     .parse(request.body)
    return reply.code(201).send({ success: true, data: await tournamentSvc.addTournamentTeam(user.userId, id, { ...body, playerIds: body.playerIds || [] }) })
  })

  app.delete('/tournaments/:id/teams/:teamId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id, teamId } = request.params as { id: string; teamId: string }
    return reply.send({ success: true, data: await tournamentSvc.removeTournamentTeam(user.userId, id, teamId) })
  })

  app.patch('/tournaments/:id/teams/:teamId/confirm', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { teamId } = request.params as { id: string; teamId: string }
    const body = z.object({ isConfirmed: z.boolean() }).parse(request.body)
    return reply.send({ success: true, data: await tournamentSvc.confirmTournamentTeam(user.userId, teamId, body.isConfirmed) })
  })

  // ── Tournament Groups ──────────────────────────────────────────────────────

  app.get('/tournaments/:id/groups', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await tournamentSvc.getTournamentGroups(user.userId, id) })
  })

  app.post('/tournaments/:id/groups', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = z.object({
      groupNames: z.array(z.string().min(1)).min(1),
      autoAssign: z.boolean().optional(),
    }).parse(request.body)
    return reply.send({ success: true, data: await tournamentSvc.createTournamentGroups(user.userId, id, body.groupNames, body.autoAssign) })
  })

  app.patch('/tournaments/:id/teams/:teamId/assign-group', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id, teamId } = request.params as { id: string; teamId: string }
    const body = z.object({ groupId: z.string().nullable() }).parse(request.body)
    return reply.send({ success: true, data: await tournamentSvc.assignTeamToGroup(user.userId, id, teamId, body.groupId) })
  })

  // ── Tournament Standings ──────────────────────────────────────────────────

  app.get('/tournaments/:id/standings', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await tournamentSvc.getTournamentStandings(user.userId, id) })
  })

  app.post('/tournaments/:id/recalculate-standings', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await tournamentSvc.recalculateStandings(user.userId, id) })
  })

  // ── Tournament Schedule ───────────────────────────────────────────────────

  app.get('/tournaments/:id/schedule', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await tournamentSvc.getTournamentSchedule(user.userId, id) })
  })

  app.post('/tournaments/:id/auto-generate', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = request.body as { matchesPerDay?: number } | undefined
    return reply.send({ success: true, data: await tournamentSvc.autoGenerateSchedule(user.userId, id, body?.matchesPerDay) })
  })

  app.post('/tournaments/:id/generate-schedule', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = z.object({
      startDate: z.string().datetime(),
      matchIntervalHours: z.number().min(1).max(72).default(24),
    }).parse(request.body)
    return reply.send({
      success: true,
      data: await tournamentSvc.generateSchedule(
        user.userId,
        id,
        body.startDate,
        body.matchIntervalHours,
      ),
    })
  })

  app.post('/tournaments/:id/smart-schedule', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = z.object({
      startDate: z.string(),
      matchStartTime: z.string().regex(/^\d{2}:\d{2}$/),
      matchesPerDay: z.number().int().min(1).max(10).default(2),
      gapBetweenMatchesHours: z.number().min(1).max(12).default(3),
      validWeekdays: z.array(z.number().int().min(0).max(6)).min(1),
      excludeDates: z.array(z.string()).optional(),
    }).parse(request.body)
    return reply.send({
      success: true,
      data: await tournamentSvc.generateSmartSchedule(user.userId, id, body),
    })
  })

  app.delete('/tournaments/:id/schedule', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await tournamentSvc.deleteSchedule(user.userId, id) })
  })

  app.post('/tournaments/:id/advance-round', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({
      success: true,
      data: await tournamentSvc.advanceKnockoutRound(user.userId, id),
    })
  })

  // ── Hosted events ─────────────────────────────────────────────────────────

  app.get('/events', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await eventSvc.listHostedEvents(user.userId) })
  })

  app.post('/events', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = createEventRequestSchema.parse(request.body)
    return reply.code(201).send({ success: true, data: await eventSvc.createHostedEvent(user.userId, body) })
  })

  // --- HEALTH & WELLNESS ---

  app.post('/wellness', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = wellnessCheckinSchema.parse(request.body)
    const playerId = await resolvePlayerId(user.userId, body.playerId)

    return reply.code(201).send({
      success: true,
      data: await performanceSvc.ingestWellnessCheckin({ ...body, playerId }),
    })
  })

  app.get('/wellness/latest', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { playerId: queryPlayerId } = request.query as { playerId?: string }
    const playerId = await resolvePlayerId(user.userId, queryPlayerId)

    return reply.send({
      success: true,
      data: await performanceSvc.getLatestWellnessCheckin(playerId),
    })
  })

  app.get('/wellness/history', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { playerId: queryPlayerId, days } = request.query as { playerId?: string; days?: string }
    const playerId = await resolvePlayerId(user.userId, queryPlayerId)

    return reply.send({
      success: true,
      data: await performanceSvc.getWellnessHistory(playerId, Number(days) || 7),
    })
  })

  app.post('/workload', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = workloadEventSchema.parse(request.body)
    const playerId = await resolvePlayerId(user.userId, body.playerId)

    return reply.code(201).send({
      success: true,
      data: await performanceSvc.ingestWorkloadEvent({ ...body, playerId }),
    })
  })

  app.get('/workload/recent', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { playerId: queryPlayerId, limit } = request.query as { playerId?: string; limit?: string }
    const playerId = await resolvePlayerId(user.userId, queryPlayerId)

    return reply.send({
      success: true,
      data: await performanceSvc.getRecentWorkloadEvents(playerId, Number(limit) || 10),
    })
  })

  app.get('/workload/history', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { playerId: queryPlayerId, type, days } = request.query as { playerId?: string; type?: string; days?: string }
    const playerId = await resolvePlayerId(user.userId, queryPlayerId)

    return reply.send({
      success: true,
      data: await performanceSvc.getWorkloadHistory(playerId, type, Number(days) || 7),
    })
  })

  app.get('/workload/summary', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { playerId: queryPlayerId, days } = request.query as { playerId?: string; days?: string }
    const playerId = await resolvePlayerId(user.userId, queryPlayerId)

    return reply.send({
      success: true,
      data: await performanceSvc.getWorkloadSummary(playerId, Number(days) || 7),
    })
  })

  app.get('/health/dashboard', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { playerId: queryPlayerId } = request.query as { playerId?: string }
    const playerId = await resolvePlayerId(user.userId, queryPlayerId)

    return reply.send({
      success: true,
      data: await performanceSvc.getHealthDashboard(playerId),
    })
  })

  // ── Public team profile ────────────────────────────────────────────────────────

  // GET /player/teams/:teamId — public team profile (squad, roles, follower count)
  app.get('/teams/:teamId/public', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { teamId } = request.params as { teamId: string }

    const team = await prisma.team.findUnique({
      where: { id: teamId },
      select: {
        id: true,
        name: true,
        shortName: true,
        logoUrl: true,
        city: true,
        teamType: true,
        captainId: true,
        viceCaptainId: true,
        wicketKeeperId: true,
        playerIds: true,
        createdByUserId: true,
        createdAt: true,
      },
    })
    if (!team) return reply.status(404).send({ success: false, error: { code: 'NOT_FOUND', message: 'Team not found' } })

    const [players, followerCount, myProfile] = await Promise.all([
      prisma.playerProfile.findMany({
        where: { id: { in: team.playerIds } },
        select: {
          id: true,
          username: true,
          battingStyle: true,
          bowlingStyle: true,
          user: { select: { name: true, avatarUrl: true } },
        },
      }),
      prisma.follow.count({ where: { targetId: teamId, targetType: 'TEAM' } }),
      prisma.playerProfile.findUnique({ where: { userId: user.userId }, select: { id: true } }),
    ])

    const isFollowing = myProfile
      ? !!(await prisma.follow.findUnique({
          where: { followerId_targetId_targetType: { followerId: myProfile.id, targetId: teamId, targetType: 'TEAM' } },
        }))
      : false

    const playerMap = new Map(players.map(p => [p.id, p]))

    return reply.send({
      success: true,
      data: {
        id: team.id,
        name: team.name,
        shortName: team.shortName,
        logoUrl: team.logoUrl,
        city: team.city,
        teamType: team.teamType,
        followerCount,
        isFollowing,
        isOwner: team.createdByUserId === user.userId,
        memberCount: team.playerIds.length,
        members: players.map(p => ({
          profileId: p.id,
          username: p.username,
          name: p.user?.name ?? null,
          avatarUrl: p.user?.avatarUrl ?? null,
          battingStyle: p.battingStyle,
          bowlingStyle: p.bowlingStyle,
          isCaptain: p.id === team.captainId,
          isViceCaptain: p.id === (team as any).viceCaptainId,
          isWicketKeeper: p.id === (team as any).wicketKeeperId,
        })),
        roleAssignments: {
          captain: team.captainId ? (playerMap.get(team.captainId) ?? null) : null,
          viceCaptain: (team as any).viceCaptainId ? (playerMap.get((team as any).viceCaptainId) ?? null) : null,
          wicketKeeper: (team as any).wicketKeeperId ? (playerMap.get((team as any).wicketKeeperId) ?? null) : null,
        },
      },
    })
  })

  // GET /player/teams/:teamId/matches — all matches (live, upcoming, completed)
  app.get('/teams/:teamId/matches', auth, async (request, reply) => {
    const { teamId } = request.params as { teamId: string }
    const q = request.query as { page?: string; limit?: string }
    const page = Number(q.page) || 1
    const limit = Math.min(Number(q.limit) || 20, 50)
    const skip = (page - 1) * limit

    const team = await prisma.team.findUnique({ where: { id: teamId }, select: { id: true, name: true } })
    if (!team) return reply.status(404).send({ success: false, error: { code: 'NOT_FOUND', message: 'Team not found' } })

    const teamFilter = { OR: [{ teamAName: team.name }, { teamBName: team.name }] }

    const [matches, total] = await Promise.all([
      prisma.match.findMany({
        where: teamFilter,
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
        select: {
          id: true,
          status: true,
          teamAName: true,
          teamBName: true,
          winnerId: true,
          format: true,
          venueName: true,
          venueId: true,
          scheduledAt: true,
          completedAt: true,
          createdAt: true,
        },
      }),
      prisma.match.count({ where: teamFilter }),
    ])

    return reply.send({
      success: true,
      data: {
        matches: matches.map(m => ({
          ...m,
          teamSide: m.teamAName === team.name ? 'A' : 'B',
          won: m.winnerId === (m.teamAName === team.name ? 'A' : 'B'),
        })),
        total,
        page,
        limit,
      },
    })
  })

  // ── Follow routes ─────────────────────────────────────────────────────────────

  const followSvc = new FollowService()

  // Follow a player
  app.post('/follow/player/:playerId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { playerId } = request.params as { playerId: string }
    return reply.send({ success: true, data: await followSvc.followPlayer(user.userId, playerId) })
  })

  // Unfollow a player
  app.delete('/follow/player/:playerId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { playerId } = request.params as { playerId: string }
    return reply.send({ success: true, data: await followSvc.unfollowPlayer(user.userId, playerId) })
  })

  // Check if following a player
  app.get('/follow/player/:playerId/status', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { playerId } = request.params as { playerId: string }
    return reply.send({ success: true, data: { following: await followSvc.isFollowingPlayer(user.userId, playerId) } })
  })

  // Get followers of a player
  app.get('/follow/player/:playerId/followers', auth, async (request, reply) => {
    const { playerId } = request.params as { playerId: string }
    const q = request.query as { page?: string; limit?: string }
    return reply.send({ success: true, data: await followSvc.getFollowers(playerId, Number(q.page) || 1, Number(q.limit) || 20) })
  })

  // Get who I am following
  app.get('/follow/following', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const q = request.query as { page?: string; limit?: string }
    return reply.send({ success: true, data: await followSvc.getFollowing(user.userId, Number(q.page) || 1, Number(q.limit) || 20) })
  })

  // Follow a team
  app.post('/follow/team/:teamId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { teamId } = request.params as { teamId: string }
    return reply.send({ success: true, data: await followSvc.followTeam(user.userId, teamId) })
  })

  // Unfollow a team
  app.delete('/follow/team/:teamId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { teamId } = request.params as { teamId: string }
    return reply.send({ success: true, data: await followSvc.unfollowTeam(user.userId, teamId) })
  })

  // Follow a tournament
  app.post('/follow/tournament/:tournamentId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { tournamentId } = request.params as { tournamentId: string }
    return reply.send({ success: true, data: await followSvc.followTournament(user.userId, tournamentId) })
  })

  // Unfollow a tournament
  app.delete('/follow/tournament/:tournamentId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { tournamentId } = request.params as { tournamentId: string }
    return reply.send({ success: true, data: await followSvc.unfollowTournament(user.userId, tournamentId) })
  })

  // Check follow status for team or tournament
  app.get('/follow/:type/:id/status', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { type, id } = request.params as { type: string; id: string }
    if (type !== 'team' && type !== 'tournament') {
      return reply.status(400).send({ success: false, error: { code: 'INVALID_TYPE', message: 'type must be team or tournament' } })
    }
    const targetType = type === 'team' ? 'TEAM' : 'TOURNAMENT'
    return reply.send({ success: true, data: { following: await followSvc.isFollowingEntity(user.userId, id, targetType) } })
  })

  app.get('/leaderboard', auth, async (request, reply) => {
    const { page, limit } = z.object({
      page: z.coerce.number().int().min(1).default(1),
      limit: z.coerce.number().int().min(1).max(100).default(20),
    }).parse(request.query)

    const leaderboard = await svc.getGlobalLeaderboard(page, limit)
    return reply.send({ success: true, ...leaderboard })
  })

  app.get('/recommendations', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { limit } = z.object({
      limit: z.coerce.number().int().min(1).max(50).default(10),
    }).parse(request.query)

    const recommendations = await svc.getRecommendedFollows(user.userId, limit)
    return reply.send({ success: true, data: recommendations })
  })
}
