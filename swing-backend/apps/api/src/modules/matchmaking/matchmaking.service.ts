import { prisma } from '@swing/db'
import { Errors, AppError } from '../../lib/errors'
import Razorpay from 'razorpay'

const MATCHMAKING_EXPIRY_HOURS = 24
const MAX_ACTIVE_REQUESTS = 3
const DEFAULT_MATCH_COST_PER_PLAYER_PAISE = 45000

let _razorpay: Razorpay | null = null
function getRazorpay() {
  if (!_razorpay) {
    _razorpay = new Razorpay({
      key_id: process.env.RAZORPAY_KEY_ID || '',
      key_secret: process.env.RAZORPAY_KEY_SECRET || '',
    })
  }
  return _razorpay
}

export class MatchmakingService {
  async joinQueue(userId: string, data: {
    sport: string
    format: string
    teamSize: number
    preferredFrom?: string
    preferredTo?: string
    radiusKm?: number
    latitude?: number
    longitude?: number
  }) {
    const player = await prisma.playerProfile.findUnique({
      where: { userId },
      include: { user: { select: { name: true } } },
    })
    if (!player) throw Errors.notFound('Player profile')

    const existing = await prisma.matchmakingQueue.findFirst({
      where: {
        playerProfileId: player.id,
        status: { in: ['WAITING', 'MATCHED', 'CONFIRMED'] },
        expiresAt: { gt: new Date() },
      },
      orderBy: { createdAt: 'desc' },
    })
    if (existing) {
      throw new AppError('ALREADY_IN_QUEUE', 'You already have an active matchmaking queue entry', 409)
    }

    const availableFrom = data.preferredFrom ? new Date(data.preferredFrom) : new Date()
    const availableUntil = data.preferredTo
      ? new Date(data.preferredTo)
      : new Date(availableFrom.getTime() + MATCHMAKING_EXPIRY_HOURS * 60 * 60 * 1000)
    const expiresAt = new Date(Date.now() + MATCHMAKING_EXPIRY_HOURS * 60 * 60 * 1000)

    const queue = await prisma.matchmakingQueue.create({
      data: {
        playerProfileId: player.id,
        sport: data.sport as any,
        format: data.format as any,
        teamSize: data.teamSize,
        preferredDate: data.preferredFrom ? new Date(data.preferredFrom) : undefined,
        availableFrom,
        availableUntil,
        maxDistanceKm: data.radiusKm ?? 20,
        latitude: data.latitude,
        longitude: data.longitude,
        ipAtQueue: 0,
        status: 'WAITING',
        expiresAt,
      },
    })

    const candidate = await this.findQueueCandidate(queue)
    let requestId: string | null = null
    let finalStatus = queue.status

    if (candidate) {
      const proposedArena = await this.findProposedArena(queue, candidate)
      const proposedDateTime = new Date(
        Math.max(queue.availableFrom.getTime(), candidate.availableFrom.getTime()),
      )
      const costPerPlayerPaise = proposedArena?.costPerPlayerPaise ?? DEFAULT_MATCH_COST_PER_PLAYER_PAISE

      const request = await prisma.matchmakingRequest.create({
        data: {
          playerProfileId: queue.playerProfileId,
          opponentPlayerProfileId: candidate.playerProfileId,
          initiatorQueueId: queue.id,
          opponentQueueId: candidate.id,
          format: queue.format,
          matchType: 'RANKED',
          preferredDate: queue.preferredDate ?? proposedDateTime,
          preferredVenueName: proposedArena?.name,
          proposedArenaId: proposedArena?.id,
          proposedDateTime,
          costPerPlayerPaise,
          latitude: queue.latitude ?? candidate.latitude,
          longitude: queue.longitude ?? candidate.longitude,
          radiusKm: Math.min(queue.maxDistanceKm, candidate.maxDistanceKm),
          ipAtRequest: queue.ipAtQueue,
          status: 'MATCHED',
          matchedAt: new Date(),
          expiresAt,
        },
      })

      requestId = request.id
      finalStatus = 'MATCHED'

      await prisma.matchmakingQueue.updateMany({
        where: { id: { in: [queue.id, candidate.id] } },
        data: { status: 'MATCHED', matchedWith: request.id },
      })
    }

    return this.buildQueueResponse(queue.id, player.id, finalStatus, requestId)
  }

  async getQueueStatus(queueId: string, userId: string) {
    const player = await prisma.playerProfile.findUnique({
      where: { userId },
      include: { user: { select: { name: true } } },
    })
    if (!player) throw Errors.notFound('Player profile')

    const queue = await prisma.matchmakingQueue.findUnique({ where: { id: queueId } })
    if (!queue) throw Errors.notFound('Queue entry')
    if (queue.playerProfileId !== player.id) throw Errors.forbidden()

    const response = await this.buildQueueResponse(queue.id, player.id, queue.status, queue.matchedWith)
    if (queue.status !== 'MATCHED' || !queue.matchedWith) return response

    const request = await prisma.matchmakingRequest.findUnique({ where: { id: queue.matchedWith } })
    if (!request) return response

    const opponentProfileId =
      request.playerProfileId === player.id ? request.opponentPlayerProfileId : request.playerProfileId
    const opponentQueueId =
      request.initiatorQueueId && request.opponentQueueId
        ? (request.playerProfileId === player.id ? request.opponentQueueId : request.initiatorQueueId)
        : null

    const [opponent, opponentQueue, proposedArena] = await Promise.all([
      opponentProfileId
        ? prisma.playerProfile.findUnique({
            where: { id: opponentProfileId },
            include: { user: { select: { name: true } } },
          })
        : Promise.resolve(null),
      opponentQueueId ? prisma.matchmakingQueue.findUnique({ where: { id: opponentQueueId } }) : Promise.resolve(null),
      request.proposedArenaId
        ? prisma.arena.findUnique({
            where: { id: request.proposedArenaId },
            select: { id: true, name: true, address: true },
          })
        : Promise.resolve(null),
    ])

    return {
      ...response,
      opponent: opponent
        ? {
            teamName: `${opponent.user.name} XI`,
            captainName: opponent.user.name,
            playerCount: opponentQueue?.preformedTeam.length || 1,
          }
        : null,
      proposedArena,
      proposedDateTime: request.proposedDateTime,
      costPerPlayer: request.costPerPlayerPaise ?? DEFAULT_MATCH_COST_PER_PLAYER_PAISE,
    }
  }

  async leaveQueue(queueId: string, userId: string) {
    const player = await prisma.playerProfile.findUnique({ where: { userId } })
    if (!player) throw Errors.notFound('Player profile')

    const queue = await prisma.matchmakingQueue.findUnique({ where: { id: queueId } })
    if (!queue) throw Errors.notFound('Queue entry')
    if (queue.playerProfileId !== player.id) throw Errors.forbidden()
    if (queue.status === 'CONFIRMED') {
      throw new AppError('QUEUE_LOCKED', 'Confirmed matchmaking entries cannot be cancelled', 400)
    }

    const requestId = queue.matchedWith
    await prisma.matchmakingQueue.update({
      where: { id: queue.id },
      data: { status: 'CANCELLED', matchedWith: null },
    })

    if (requestId) {
      const request = await prisma.matchmakingRequest.findUnique({ where: { id: requestId } })
      const otherQueueId =
        request?.initiatorQueueId === queue.id ? request.opponentQueueId : request?.initiatorQueueId
      if (otherQueueId) {
        await prisma.matchmakingQueue.update({
          where: { id: otherQueueId },
          data: { status: 'WAITING', matchedWith: null },
        })
      }
      await prisma.matchmakingRequest.update({
        where: { id: requestId },
        data: { status: 'CANCELLED' },
      }).catch(() => undefined)
    }

    return { success: true }
  }

  async confirmMatch(requestId: string, userId: string) {
    const player = await prisma.playerProfile.findUnique({
      where: { userId },
      include: { user: { select: { name: true } } },
    })
    if (!player) throw Errors.notFound('Player profile')

    const request = await prisma.matchmakingRequest.findUnique({ where: { id: requestId } })
    if (!request) throw Errors.notFound('Matchmaking request')
    if (![request.playerProfileId, request.opponentPlayerProfileId].includes(player.id)) {
      throw Errors.forbidden()
    }

    const confirmedBy = Array.from(
      new Set([...(request.confirmedByPlayerProfileIds || []), player.id]),
    )

    if (confirmedBy.length < 2) {
      await prisma.matchmakingRequest.update({
        where: { id: requestId },
        data: { confirmedByPlayerProfileIds: confirmedBy },
      })

      return {
        matchId: null,
        status: 'WAITING_FOR_OTHER_CAPTAIN',
        razorpayOrderId: null,
        amountPaise: request.costPerPlayerPaise ?? DEFAULT_MATCH_COST_PER_PLAYER_PAISE,
      }
    }

    const [initiatorQueue, opponentQueue, initiatorProfile, opponentProfile, proposedArena] = await Promise.all([
      request.initiatorQueueId ? prisma.matchmakingQueue.findUnique({ where: { id: request.initiatorQueueId } }) : Promise.resolve(null),
      request.opponentQueueId ? prisma.matchmakingQueue.findUnique({ where: { id: request.opponentQueueId } }) : Promise.resolve(null),
      prisma.playerProfile.findUnique({
        where: { id: request.playerProfileId },
        include: { user: { select: { name: true } } },
      }),
      request.opponentPlayerProfileId
        ? prisma.playerProfile.findUnique({
            where: { id: request.opponentPlayerProfileId },
            include: { user: { select: { name: true } } },
          })
        : Promise.resolve(null),
      request.proposedArenaId ? prisma.arena.findUnique({ where: { id: request.proposedArenaId } }) : Promise.resolve(null),
    ])

    if (!initiatorQueue || !opponentQueue || !initiatorProfile || !opponentProfile) {
      throw new AppError('MATCHMAKING_INCOMPLETE', 'Matched queue details are incomplete', 400)
    }

    const teamAPlayerIds = initiatorQueue.preformedTeam.length > 0
      ? initiatorQueue.preformedTeam
      : [initiatorQueue.playerProfileId]
    const teamBPlayerIds = opponentQueue.preformedTeam.length > 0
      ? opponentQueue.preformedTeam
      : [opponentQueue.playerProfileId]

    const match = await prisma.match.create({
      data: {
        matchType: request.matchType as any,
        format: request.format,
        teamAName: `${initiatorProfile.user.name} XI`,
        teamBName: `${opponentProfile.user.name} XI`,
        teamAPlayerIds,
        teamBPlayerIds,
        teamACaptainId: initiatorQueue.playerProfileId,
        teamBCaptainId: opponentQueue.playerProfileId,
        scheduledAt: request.proposedDateTime ?? request.preferredDate ?? new Date(),
        venueName: proposedArena?.name ?? request.preferredVenueName ?? 'Swing Matchmaking Venue',
        facilityId: proposedArena?.id,
        scorerId: initiatorQueue.playerProfileId,
        isRanked: request.matchType === 'RANKED',
        status: 'SCHEDULED',
        matchmakingId: request.id,
      },
    })

    await prisma.matchmakingRequest.update({
      where: { id: request.id },
      data: {
        status: 'CONFIRMED',
        confirmedByPlayerProfileIds: confirmedBy,
      },
    })
    await prisma.matchmakingQueue.updateMany({
      where: { id: { in: [initiatorQueue.id, opponentQueue.id] } },
      data: { status: 'CONFIRMED', matchId: match.id, matchedWith: request.id },
    })

    const amountPaise = (request.costPerPlayerPaise ?? DEFAULT_MATCH_COST_PER_PLAYER_PAISE) *
      (initiatorQueue.teamSize + opponentQueue.teamSize)
    const razorpayOrder = await getRazorpay().orders.create({
      amount: amountPaise,
      currency: 'INR',
      receipt: `swing_matchmaking_${request.id.slice(0, 12)}`,
      notes: { matchId: match.id, matchmakingRequestId: request.id },
    })

    return {
      matchId: match.id,
      status: 'BOTH_CONFIRMED',
      razorpayOrderId: razorpayOrder.id,
      amountPaise,
    }
  }

  async createRequest(userId: string, data: {
    format: string
    matchType: string
    preferredDate?: string
    preferredVenueName?: string
    latitude?: number
    longitude?: number
    radiusKm?: number
    notes?: string
  }) {
    const player = await prisma.playerProfile.findUnique({ where: { userId } })
    if (!player) throw Errors.notFound('Player profile')

    // Check for existing active requests
    const activeCount = await prisma.matchmakingRequest.count({
      where: { playerProfileId: player.id, status: 'OPEN' },
    })
    if (activeCount >= MAX_ACTIVE_REQUESTS) {
      throw new AppError('TOO_MANY_REQUESTS', 'You already have too many open matchmaking requests', 400)
    }

    const expiresAt = new Date()
    expiresAt.setHours(expiresAt.getHours() + MATCHMAKING_EXPIRY_HOURS)

    const request = await prisma.matchmakingRequest.create({
      data: {
        playerProfileId: player.id,
        format: data.format as any,
        matchType: data.matchType as any,
        preferredDate: data.preferredDate ? new Date(data.preferredDate) : undefined,
        preferredVenueName: data.preferredVenueName,
        latitude: data.latitude,
        longitude: data.longitude,
        radiusKm: data.radiusKm || 25,
        ipAtRequest: 0,
        notes: data.notes,
        expiresAt,
        status: 'OPEN',
      },
    })

    // Attempt auto-matching
    const match = await this.findMatch(request.id, player)
    if (match) return { request, potentialMatch: match }
    return { request, potentialMatch: null }
  }

  async findMatch(requestId: string, player: any) {
    const request = await prisma.matchmakingRequest.findUnique({ where: { id: requestId } })
    if (!request) return null

    const ipTolerance = request.ipAtRequest * 0.15
    const minIp = request.ipAtRequest - ipTolerance
    const maxIp = request.ipAtRequest + ipTolerance

    const candidates = await prisma.matchmakingRequest.findMany({
      where: {
        id: { not: requestId },
        status: 'OPEN',
        format: request.format,
        matchType: request.matchType,
        ipAtRequest: { gte: minIp, lte: maxIp },
        expiresAt: { gt: new Date() },
      },
      include: { playerProfile: { include: { user: { select: { name: true, avatarUrl: true } } } } },
      orderBy: { createdAt: 'asc' },
    })

    if (candidates.length === 0) return null

    // Score candidates by proximity if geo available
    let best = candidates[0]
    if (request.latitude && request.longitude) {
      const scored = candidates.map(c => {
        let score = 0
        if (c.latitude && c.longitude) {
          const dist = this.haversineKm(request.latitude!, request.longitude!, c.latitude, c.longitude)
          if (dist <= (request.radiusKm || 25)) score += 100 - dist
        }
        return { candidate: c, score }
      }).filter(s => s.score > 0).sort((a, b) => b.score - a.score)
      if (scored.length > 0) best = scored[0].candidate
    }

    return best
  }

  async listRequests(userId: string, filters: { format?: string; status?: string; page: number; limit: number }) {
    const player = await prisma.playerProfile.findUnique({ where: { userId } })
    if (!player) throw Errors.notFound('Player profile')

    const where: any = {
      status: filters.status || 'OPEN',
      expiresAt: { gt: new Date() },
      playerProfileId: { not: player.id },
    }
    if (filters.format) where.format = filters.format

    const [requests, total] = await prisma.$transaction([
      prisma.matchmakingRequest.findMany({
        where,
        include: { playerProfile: { include: { user: { select: { name: true, avatarUrl: true } } } } },
        orderBy: { createdAt: 'desc' },
        skip: (filters.page - 1) * filters.limit,
        take: filters.limit,
      }),
      prisma.matchmakingRequest.count({ where }),
    ])

    return { requests, total, page: filters.page, limit: filters.limit }
  }

  async respondToRequest(requestId: string, userId: string, accept: boolean) {
    const player = await prisma.playerProfile.findUnique({ where: { userId } })
    if (!player) throw Errors.notFound('Player profile')

    const request = await prisma.matchmakingRequest.findUnique({
      where: { id: requestId },
      include: { playerProfile: true },
    })
    if (!request) throw Errors.notFound('Matchmaking request')
    if (request.status !== 'OPEN') throw new AppError('REQUEST_CLOSED', 'Request is no longer open', 400)
    if (request.playerProfileId === player.id) throw new AppError('OWN_REQUEST', 'Cannot respond to your own request', 400)

    if (!accept) return { message: 'Request declined' }

    // Create a match between the two players
    const match = await prisma.match.create({
      data: {
        matchType: request.matchType,
        format: request.format,
        teamAName: request.playerProfile.userId,
        teamBName: userId,
        teamAPlayerIds: [request.playerProfileId],
        teamBPlayerIds: [player.id],
        scheduledAt: request.preferredDate || new Date(),
        venueName: request.preferredVenueName,
        scorerId: request.playerProfileId,
        isRanked: request.matchType === 'RANKED',
        status: 'SCHEDULED',
      },
    })

    await prisma.matchmakingRequest.update({ where: { id: requestId }, data: { status: 'MATCHED', matchedAt: new Date() } })

    return { match, message: 'Match created successfully' }
  }

  async cancelRequest(requestId: string, userId: string) {
    const player = await prisma.playerProfile.findUnique({ where: { userId } })
    if (!player) throw Errors.notFound('Player profile')

    const request = await prisma.matchmakingRequest.findUnique({ where: { id: requestId } })
    if (!request) throw Errors.notFound('Matchmaking request')
    if (request.playerProfileId !== player.id) throw Errors.forbidden()
    if (request.status !== 'OPEN') throw new AppError('REQUEST_CLOSED', 'Request is not open', 400)

    return prisma.matchmakingRequest.update({ where: { id: requestId }, data: { status: 'CANCELLED' } })
  }

  async getMyRequests(userId: string) {
    const player = await prisma.playerProfile.findUnique({ where: { userId } })
    if (!player) return []
    return prisma.matchmakingRequest.findMany({
      where: { playerProfileId: player.id },
      orderBy: { createdAt: 'desc' },
    })
  }

  private haversineKm(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371
    const dLat = ((lat2 - lat1) * Math.PI) / 180
    const dLon = ((lon2 - lon1) * Math.PI) / 180
    const a =
      Math.sin(dLat / 2) ** 2 +
      Math.cos((lat1 * Math.PI) / 180) * Math.cos((lat2 * Math.PI) / 180) * Math.sin(dLon / 2) ** 2
    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  }

  private async findQueueCandidate(queue: any) {
    const candidates = await prisma.matchmakingQueue.findMany({
      where: {
        id: { not: queue.id },
        status: 'WAITING',
        sport: queue.sport,
        format: queue.format,
        teamSize: queue.teamSize,
        expiresAt: { gt: new Date() },
      },
      orderBy: { createdAt: 'asc' },
      take: 20,
    })

    return candidates.find(candidate => {
      const hasTimeOverlap =
        candidate.availableFrom <= queue.availableUntil &&
        candidate.availableUntil >= queue.availableFrom
      if (!hasTimeOverlap) return false

      if (
        queue.latitude == null ||
        queue.longitude == null ||
        candidate.latitude == null ||
        candidate.longitude == null
      ) {
        return true
      }

      const distance = this.haversineKm(
        queue.latitude,
        queue.longitude,
        candidate.latitude,
        candidate.longitude,
      )
      return distance <= Math.min(queue.maxDistanceKm, candidate.maxDistanceKm)
    }) ?? null
  }

  private async findProposedArena(queue: any, candidate: any) {
    const arenas = await prisma.arena.findMany({
      where: {
        isActive: true,
        isVerified: true,
        isSwingArena: true,
      },
      include: {
        units: {
          where: { isActive: true },
          orderBy: { pricePerHourPaise: 'asc' },
          take: 1,
        },
      },
      take: 20,
    })

    if (arenas.length === 0) return null

    const midpointLat =
      queue.latitude != null && candidate.latitude != null
        ? (queue.latitude + candidate.latitude) / 2
        : null
    const midpointLng =
      queue.longitude != null && candidate.longitude != null
        ? (queue.longitude + candidate.longitude) / 2
        : null

    const sorted = arenas
      .map(arena => ({
        arena,
        distance:
          midpointLat != null && midpointLng != null
            ? this.haversineKm(midpointLat, midpointLng, arena.latitude, arena.longitude)
            : 0,
      }))
      .sort((a, b) => a.distance - b.distance)

    const selected = sorted[0]?.arena
    if (!selected) return null

    return {
      id: selected.id,
      name: selected.name,
      address: selected.address,
      costPerPlayerPaise: selected.units[0]
        ? Math.ceil(selected.units[0].pricePerHourPaise / Math.max(queue.teamSize * 2, 1))
        : DEFAULT_MATCH_COST_PER_PLAYER_PAISE,
    }
  }

  private async buildQueueResponse(
    queueId: string,
    playerProfileId: string,
    status: string,
    matchedId: string | null,
  ) {
    const queue = await prisma.matchmakingQueue.findUnique({ where: { id: queueId } })
    if (!queue) throw Errors.notFound('Queue entry')

    const [queuePosition, playersInQueue] = await Promise.all([
      prisma.matchmakingQueue.count({
        where: {
          status: 'WAITING',
          sport: queue.sport,
          format: queue.format,
          teamSize: queue.teamSize,
          createdAt: { lte: queue.createdAt },
          id: { not: queue.id },
        },
      }),
      prisma.matchmakingQueue.count({ where: { status: 'WAITING' } }),
    ])

    return {
      queueId,
      status,
      matchedId,
      queuePosition: status === 'WAITING' ? queuePosition + 1 : 0,
      playersInQueue,
      createdAt: queue.createdAt,
    }
  }
}
