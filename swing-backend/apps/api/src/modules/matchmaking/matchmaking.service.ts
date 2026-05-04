import { prisma, FacilityUnitType, Prisma } from '@swing/db'
import { Errors, AppError } from '../../lib/errors'
import { ArenaService } from '../arenas/arena.service'
import Razorpay from 'razorpay'

const MATCHMAKING_EXPIRY_HOURS = 24
const MAX_ACTIVE_REQUESTS = 3
const DEFAULT_MATCH_COST_PER_PLAYER_PAISE = 45000
const LOBBY_EXPIRY_HOURS = 24
const MATCH_CONFIRM_MINUTES = 15

export type MatchmakingFormat = 'T10' | 'T20' | 'ODI' | 'Test' | 'Custom'

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
  static startLobbySchedulers() {
    const runLobbyExpiry = async () => {
      try {
        const svc = new MatchmakingService()
        await svc.expireStaleLobbies()
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error('[matchmaking] lobby expiry error:', error)
      }
    }
    const runMatchExpiry = async () => {
      try {
        const svc = new MatchmakingService()
        await svc.expireUnconfirmedMatches()
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error('[matchmaking] match expiry error:', error)
      }
    }
    setInterval(runMatchExpiry, 60 * 1000).unref?.()
    setInterval(runLobbyExpiry, 5 * 60 * 1000).unref?.()
  }

  async searchGrounds(userId: string, input: {
    q?: string
    date: string
    format: MatchmakingFormat
    teamId?: string
    overs?: number
  }) {
    const [callerTeam] = await Promise.all([
      this.resolveCallerTeam(userId, input.teamId),
    ])
    const date = this.startOfDay(input.date)
    const duration = this.formatDurationMins(input.format, input.overs)
    const query = (input.q ?? '').trim()

    const GROUND_UNIT_TYPES: FacilityUnitType[] = ['FULL_GROUND', 'HALF_GROUND', 'TURF', 'MULTI_SPORT', 'OTHER']
    type UnitWithArena = Prisma.ArenaUnitGetPayload<{ include: { arena: true } }>

    const units: UnitWithArena[] = await prisma.arenaUnit.findMany({
      where: {
        isActive: true,
        unitType: { in: GROUND_UNIT_TYPES },
        arena: {
          isActive: true,
          ...(query
            ? {
                OR: [
                  { name: { contains: query, mode: 'insensitive' } },
                  { arenaSlug: { contains: query, mode: 'insensitive' } },
                  { city: { contains: query, mode: 'insensitive' } },
                  { address: { contains: query, mode: 'insensitive' } },
                ],
              }
            : {}),
        },
      },
      include: { arena: true },
      orderBy: [{ arena: { name: 'asc' } }, { name: 'asc' }],
    })

    const unitIds = units.map((u) => u.id)

    // Fetch opponent lobby picks and booking-context slots in parallel
    // booking-context/getPlayerSlots returns correct non-overlapping slots sized to match duration
    const arenaIds = [...new Set(units.map((u) => u.arenaId))]
    const arenaService = new ArenaService()
    const [opponentPicks, playerSlotsResults] = await Promise.all([
      unitIds.length
        ? prisma.matchmakingLobbyPick.findMany({
            where: {
              groundId: { in: unitIds },
              lobby: {
                date,
                format: input.format,
                status: 'searching',
                expiresAt: { gt: new Date() },
                ...(callerTeam ? { teamId: { not: callerTeam.id } } : {}),
              },
            },
            select: { groundId: true, slotTime: true },
          })
        : Promise.resolve([]),
      arenaIds.length
        ? Promise.all(arenaIds.map((arenaId) => arenaService.getPlayerSlots(arenaId, input.date, duration)))
        : Promise.resolve([]),
    ])
    const opponentSet = new Set(opponentPicks.map((p) => `${p.groundId}:${p.slotTime}`))

    // Build per-unit available-slot map — slots are already non-overlapping and sized to duration
    const availableSlotsByUnit = new Map<string, Array<{ startTime: string; endTime: string; totalAmountPaise: number }>>()
    for (const result of playerSlotsResults) {
      for (const group of result.unitGroups) {
        if (group.unitId) {
          availableSlotsByUnit.set(group.unitId, group.availableSlots)
        }
      }
    }

    const grounds = [] as any[]
    for (const unit of units) {
      const freeSlots = availableSlotsByUnit.get(unit.id) ?? []
      const slots: Array<{ time: string; endTime: string; unitId: string; pricePerTeam: number; hasOpponent: boolean }> = []

      for (const s of freeSlots) {
        slots.push({
          time: s.startTime,
          endTime: s.endTime,
          unitId: unit.id,
          pricePerTeam: Math.floor(s.totalAmountPaise / 2),
          hasOpponent: opponentSet.has(`${unit.id}:${s.startTime}`),
        })
      }

      if (slots.length === 0) continue
      grounds.push({
        id: unit.arenaId,
        unitId: unit.id,
        name: unit.arena.name,
        area: this.arenaArea(unit.arena.address, unit.arena.city),
        photoUrl: (unit.arena.photoUrls ?? [])[0] ?? null,
        slots,
      })
    }

    return { grounds }
  }

  async createLobby(userId: string, input: {
    teamId: string
    format: MatchmakingFormat
    ballType?: string | null
    date: string
    picks: Array<{ groundId: string; slotTime: string }>
  }) {
    if (input.picks.length < 1 || input.picks.length > 3) {
      throw new AppError('INVALID_PICKS', 'picks must contain 1 to 3 items', 400)
    }
    const seen = new Set<string>()
    for (const p of input.picks) {
      const key = `${p.groundId}:${p.slotTime}`
      if (seen.has(key)) throw new AppError('INVALID_PICKS', 'Duplicate picks are not allowed', 400)
      seen.add(key)
    }

    const player = await this.getPlayerProfile(userId)
    const team = await this.resolveCallerTeam(userId, input.teamId)
    if (!team || team.id !== input.teamId) throw Errors.forbidden()
    const callerAge = await this.getTeamAgeGroup(team.id)
    const date = this.startOfDay(input.date)
    const expiresAt = new Date(Date.now() + LOBBY_EXPIRY_HOURS * 60 * 60 * 1000)

    const result = await prisma.$transaction(async (tx) => {
      const lobby = await tx.matchmakingLobby.create({
        data: {
          teamId: team.id,
          playerId: player.id,
          format: input.format,
          ballType: input.ballType ?? null,
          date,
          status: 'searching',
          expiresAt,
          picks: {
            create: input.picks.map((p, i) => ({
              groundId: p.groundId,
              slotTime: p.slotTime,
              preferenceOrder: i + 1,
            })),
          },
        },
        include: { picks: { orderBy: { preferenceOrder: 'asc' } } },
      })

      const candidateLobbies = await tx.matchmakingLobby.findMany({
        where: {
          id: { not: lobby.id },
          teamId: { not: team.id },
          format: input.format,
          date,
          status: 'searching',
          expiresAt: { gt: new Date() },
          // Match ball type: null = any; only filter when both sides specify
          ...(input.ballType ? { OR: [{ ballType: null }, { ballType: input.ballType }] } : {}),
        } as any,
        include: { picks: true },
        orderBy: { createdAt: 'asc' },
      })

      let matchedLobby: any = null
      let picked: { groundId: string; slotTime: string } | null = null
      if (candidateLobbies.length > 0) {
        const teamIds: string[] = candidateLobbies.flatMap((c) => c.teamId ? [c.teamId] : [])
        const ages = await this.getTeamAgeGroupsMap(teamIds, tx)
        for (const c of candidateLobbies) {
          const age = c.teamId ? (ages.get(c.teamId) ?? null) : null
          if ((callerAge ?? null) !== (age ?? null)) continue
          for (const p of input.picks) {
            if (c.picks.some((cp: any) => cp.groundId === p.groundId && cp.slotTime === p.slotTime)) {
              matchedLobby = c
              picked = { groundId: p.groundId, slotTime: p.slotTime }
              break
            }
          }
          if (matchedLobby) break
        }
      }

      if (!matchedLobby || !picked) {
        return { lobby, match: null }
      }

      const unit = await tx.arenaUnit.findUnique({ where: { id: picked.groundId } })
      if (!unit) throw Errors.notFound('Arena unit')
      const perTeam = Math.floor(
        Math.round((unit.pricePerHourPaise * this.formatDurationMins(input.format)) / 60) / 2,
      )
      const match = await tx.matchmakingMatch.create({
        data: {
          lobbyAId: lobby.id,
          lobbyBId: matchedLobby.id,
          groundId: picked.groundId,
          slotTime: picked.slotTime,
          date,
          format: input.format,
          status: 'pending_confirm',
          confirmDeadline: new Date(Date.now() + MATCH_CONFIRM_MINUTES * 60 * 1000),
          teamAConfirmed: false,
          teamBConfirmed: false,
          paymentAmountPerTeam: perTeam,
        },
      })
      await tx.matchmakingLobby.updateMany({
        where: { id: { in: [lobby.id, matchedLobby.id] } },
        data: { status: 'matched', matchId: match.id },
      })
      return { lobby, match }
    })

    if (!result.match) {
      return { lobbyId: result.lobby.id, status: 'searching' as const }
    }
    return {
      lobbyId: result.lobby.id,
      status: 'matched' as const,
      match: await this.buildMatchSummary(result.match.id, result.lobby.id),
    }
  }

  async getMyActiveLobby(userId: string) {
    const player = await this.getPlayerProfile(userId)
    const lobby = await prisma.matchmakingLobby.findFirst({
      where: {
        playerId: player.id,
        status: { in: ['searching', 'matched'] },
        expiresAt: { gt: new Date() },
      },
      orderBy: { createdAt: 'desc' },
    })
    if (!lobby) return null
    const out: any = { lobbyId: lobby.id, status: lobby.status }
    if (lobby.matchId) out.match = await this.buildMatchSummary(lobby.matchId, lobby.id)
    return out
  }

  async assertLobbyOwnership(userId: string, lobbyId: string) {
    const player = await this.getPlayerProfile(userId)
    const lobby = await prisma.matchmakingLobby.findUnique({ where: { id: lobbyId } })
    if (!lobby) throw Errors.notFound('Lobby')
    if (lobby.playerId !== player.id) throw Errors.forbidden()
  }

  async getLobbyStatus(userId: string, lobbyId: string) {
    const player = await this.getPlayerProfile(userId)
    const lobby = await prisma.matchmakingLobby.findUnique({ where: { id: lobbyId } })
    if (!lobby) throw Errors.notFound('Lobby')
    if (lobby.playerId !== player.id) throw Errors.forbidden()
    const out: any = { lobbyId, status: lobby.status }
    if (lobby.matchId) out.match = await this.buildMatchSummary(lobby.matchId, lobby.id)
    return out
  }

  async listOpenLobbies(userId: string, input: {
    date?: string
    format?: MatchmakingFormat
    ageGroup?: string
    arenaId?: string
  }) {
    // Arena owner path: return lobbies for this arena without player-specific filters
    if (input.arenaId) {
      return this.listLobbiesForArena(userId, input.arenaId, input)
    }

    const player = await this.getPlayerProfile(userId)
    const myTeamIds = await prisma.team.findMany({
      where: { OR: [{ captainId: player.id }, { createdByUserId: userId }] },
      select: { id: true },
    })
    const mySet = new Set(myTeamIds.map((t) => t.id))
    const today = this.startOfDay(new Date().toISOString().slice(0, 10))
    const lobbies = await prisma.matchmakingLobby.findMany({
      where: {
        status: 'searching',
        expiresAt: { gt: new Date() },
        // if date given → exact match; otherwise show all upcoming lobbies from today
        ...(input.date ? { date: this.startOfDay(input.date) } : { date: { gte: today } }),
        ...(input.format ? { format: input.format } : {}),
        ...(mySet.size > 0 ? { OR: [{ arenaId: { not: null } }, { teamId: null }, { teamId: { notIn: Array.from(mySet) } }] } as any : {}),
      },
      include: {
        team: true,
        picks: { orderBy: { preferenceOrder: 'asc' }, take: 1 },
      },
      orderBy: { createdAt: 'asc' },
    })

    const lobbiesAny = lobbies as any[]
    const teamIds: string[] = lobbiesAny.flatMap((l) => l.teamId ? [l.teamId] : [])
    const ages = await this.getTeamAgeGroupsMap(teamIds)
    const callerAge = input.ageGroup ?? this.deriveAgeGroup(player.dateOfBirth)

    const groundIds = lobbiesAny.flatMap((l) => l.picks.map((p: any) => p.groundId))
    const units = groundIds.length
      ? await prisma.arenaUnit.findMany({
          where: { id: { in: groundIds } },
          include: { arena: true },
        })
      : []
    const unitsById = new Map(units.map((u) => [u.id, u]))

    // Fetch arena names for owner-created lobbies
    const arenaIds = [...new Set(lobbiesAny.flatMap((l) => l.arenaId ? [l.arenaId] : [] as string[]))]
    const arenas = arenaIds.length
      ? await prisma.arena.findMany({ where: { id: { in: arenaIds } }, select: { id: true, name: true } })
      : []
    const arenasById = new Map(arenas.map((a) => [a.id, a]))

    const out = lobbiesAny
      .filter((l) => {
        // Arena-owner lobbies are always visible
        if (l.arenaId != null || l.teamId == null) return true
        const lobbyAge = ages.get(l.teamId) ?? null
        // Only filter by age group when both sides have an explicit group
        if (callerAge == null || lobbyAge == null) return true
        const pass = callerAge === lobbyAge
        return pass
      })
      .map((l) => {
        const pick = l.picks[0]
        const unit = pick ? unitsById.get(pick.groundId) : null
        const arena = l.arenaId ? arenasById.get(l.arenaId) : null
        // For player lobbies (no arenaId), derive arena name from the pick's unit
        const arenaName = arena?.name ?? (unit as any)?.arena?.name ?? null
        return {
          lobbyId: l.id,
          teamName: l.team?.name ?? (arena ? arena.name : 'TBD'),
          isArenaLobby: l.arenaId != null,
          arenaName,
          ageGroup: l.teamId ? (ages.get(l.teamId) ?? null) : null,
          format: l.format,
          ballType: (l as any).ballType ?? null,
          groundName: unit?.name ?? null,
          unitId: pick?.groundId ?? null,
          pricePerTeam: unit ? Math.floor(unit.pricePerHourPaise * 2 / 2) : 90000,
          slotTime: pick?.slotTime ?? null,
          date: this.toDateOnly(l.date),
          daysFromNow: this.daysFromNow(l.date),
        }
      })
    return { lobbies: out }
  }

  private async listLobbiesForArena(userId: string, arenaId: string, input: {
    date?: string
    format?: MatchmakingFormat
  }) {
    const owner = await prisma.arenaOwnerProfile.findUnique({ where: { userId } })
    if (!owner) throw Errors.forbidden()
    const arena = await prisma.arena.findUnique({ where: { id: arenaId } })
    if (!arena || arena.ownerId !== owner.id) throw Errors.forbidden()

    // Filter lobbies that belong to THIS arena:
    // - owner-created: arenaId field is set directly
    // - player-created: at least one pick's ground belongs to this arena
    const playerLobbies: any[] = await prisma.matchmakingLobby.findMany({
      where: {
        status: 'searching',
        expiresAt: { gt: new Date() },
        ...(input.date ? { date: this.startOfDay(input.date) } : {}),
        ...(input.format ? { format: input.format } : {}),
        OR: [
          { arenaId } as any,
          { picks: { some: { ground: { arenaId } } } },
        ],
      } as any,
      include: {
        team: true,
        picks: { orderBy: { preferenceOrder: 'asc' }, take: 1 },
      },
      orderBy: { createdAt: 'asc' },
    })

    // eslint-disable-next-line no-console

    const teamIds: string[] = playerLobbies.flatMap((l) => l.teamId ? [l.teamId] : [])
    const ages = await this.getTeamAgeGroupsMap(teamIds)
    const groundIds = playerLobbies.flatMap((l) => l.picks.map((p: any) => p.groundId))
    const units = groundIds.length
      ? await prisma.arenaUnit.findMany({ where: { id: { in: groundIds } } })
      : []
    const unitsById = new Map(units.map((u) => [u.id, u]))

    const out = playerLobbies.map((l) => {
      const pick = l.picks[0]
      const unit = pick ? unitsById.get(pick.groundId) : null
      return {
        lobbyId: l.id,
        teamName: l.team?.name ?? 'TBD',
        ageGroup: l.teamId ? (ages.get(l.teamId) ?? null) : null,
        format: l.format,
        ballType: (l as any).ballType ?? null,
        groundName: unit?.name ?? null,
        unitId: pick?.groundId ?? null,
        pricePerTeam: unit ? Math.floor(unit.pricePerHourPaise * 2 / 2) : 90000,
        slotTime: pick?.slotTime ?? null,
        date: this.toDateOnly(l.date),
        daysFromNow: this.daysFromNow(l.date),
      }
    })
    return { lobbies: out }
  }

  async acceptLobbyAsOwner(userId: string, lobbyId: string, arenaId: string) {
    const owner = await prisma.arenaOwnerProfile.findUnique({ where: { userId } })
    if (!owner) throw Errors.forbidden()
    const arena = await prisma.arena.findUnique({ where: { id: arenaId } })
    if (!arena || arena.ownerId !== owner.id) throw Errors.forbidden()

    const lobby = await prisma.matchmakingLobby.findUnique({
      where: { id: lobbyId },
      include: { picks: { orderBy: { preferenceOrder: 'asc' }, take: 1 } },
    })
    if (!lobby) throw Errors.notFound('Lobby')
    if (lobby.status !== 'searching') throw new AppError('INVALID_STATE', 'Lobby is no longer searching', 400)

    const pick = lobby.picks[0]
    if (!pick) throw new AppError('NO_PICKS', 'Lobby has no ground picks', 400)

    // Verify the pick's ground belongs to this arena
    const unit = await prisma.arenaUnit.findUnique({ where: { id: pick.groundId } })
    if (!unit || unit.arenaId !== arenaId) throw new AppError('GROUND_MISMATCH', 'Pick does not belong to this arena', 400)

    // Soft-block the slot
    const date = lobby.date
    const endMins = this.timeToMinutes(pick.slotTime) + 120
    const endTime = this.minutesToTime(endMins)

    const booking = await prisma.slotBooking.create({
      data: {
        arenaId,
        unitId: unit.id,
        bookedById: owner.id,
        date,
        startTime: pick.slotTime,
        endTime,
        durationMins: 120,
        format: lobby.format as any,
        totalAmountPaise: Math.floor(unit.pricePerHourPaise * 2 / 2),
        totalPricePaise: Math.floor(unit.pricePerHourPaise * 2 / 2),
        status: 'HELD',
        isOfflineBooking: true,
        createdByOwnerId: owner.id,
        bookingSource: 'SPLIT',
        matchmakingId: lobbyId,
      } as any,
    })

    await prisma.matchmakingLobby.update({
      where: { id: lobbyId },
      data: {
        arenaId,
        splitBookingId: booking.id,
      } as any,
    })

    return { bookingId: booking.id, lobbyId }
  }


  async confirmMatchLobby(userId: string, matchId: string, lobbyId: string) {
    const player = await this.getPlayerProfile(userId)
    const result = await prisma.$transaction(async (tx) => {
      const lobby = await tx.matchmakingLobby.findUnique({ where: { id: lobbyId } })
      if (!lobby) throw Errors.notFound('Lobby')
      if (lobby.playerId !== player.id) throw Errors.forbidden()
      if (lobby.matchId !== matchId) throw new AppError('INVALID_MATCH', 'Lobby is not part of this match', 400)

      const match = await tx.matchmakingMatch.findUnique({ where: { id: matchId } })
      if (!match) throw Errors.notFound('Match')
      if (match.status !== 'pending_confirm') throw new AppError('INVALID_STATE', 'Match is not pending confirmation', 400)

      if (new Date() > match.confirmDeadline) {
        await tx.matchmakingMatch.update({ where: { id: match.id }, data: { status: 'cancelled' } })
        await tx.matchmakingLobby.updateMany({
          where: { id: { in: [match.lobbyAId, match.lobbyBId] } },
          data: { status: 'searching', matchId: null },
        })
        throw new AppError('MATCH_EXPIRED', 'Match confirmation deadline passed', 410)
      }

      const updates: any = {}
      if (match.lobbyAId === lobby.id) updates.teamAConfirmed = true
      if (match.lobbyBId === lobby.id) updates.teamBConfirmed = true
      const after = await tx.matchmakingMatch.update({
        where: { id: match.id },
        data: updates,
      })

      if (!(after.teamAConfirmed && after.teamBConfirmed)) {
        return { status: 'waiting_opponent' as const }
      }

      const bookingId = await this.createBookedSlotForMatch(after, tx)
      await tx.matchmakingMatch.update({
        where: { id: after.id },
        data: { status: 'confirmed', bookingId },
      })
      await tx.matchmakingLobby.updateMany({
        where: { id: { in: [after.lobbyAId, after.lobbyBId] } },
        data: { status: 'confirmed' },
      })

      return { status: 'confirmed' as const, bookingId }
    })
    return result
  }

  async declineMatchLobby(userId: string, matchId: string, lobbyId: string) {
    const player = await this.getPlayerProfile(userId)
    const lobby = await prisma.matchmakingLobby.findUnique({ where: { id: lobbyId } })
    if (!lobby) throw Errors.notFound('Lobby')
    if (lobby.playerId !== player.id) throw Errors.forbidden()
    if (lobby.matchId !== matchId) throw new AppError('INVALID_MATCH', 'Lobby is not part of this match', 400)

    const match = await prisma.matchmakingMatch.findUnique({ where: { id: matchId } })
    if (!match) throw Errors.notFound('Match')
    await prisma.$transaction([
      prisma.matchmakingMatch.update({ where: { id: matchId }, data: { status: 'cancelled' } }),
      prisma.matchmakingLobby.updateMany({
        where: { id: { in: [match.lobbyAId, match.lobbyBId] } },
        data: { status: 'searching', matchId: null },
      }),
    ])
    return { status: 'searching' as const, lobbyId }
  }

  async leaveLobby(userId: string, lobbyId: string) {
    const player = await this.getPlayerProfile(userId)
    const lobby = await prisma.matchmakingLobby.findUnique({ where: { id: lobbyId } })
    if (!lobby) throw Errors.notFound('Lobby')
    if (lobby.playerId !== player.id) throw Errors.forbidden()
    if (lobby.status !== 'searching') {
      throw new AppError('INVALID_STATE', 'Only searching lobbies can be left', 400)
    }
    await prisma.matchmakingLobby.update({
      where: { id: lobbyId },
      data: { status: 'cancelled' },
    })
  }

  async expireStaleLobbies() {
    await prisma.matchmakingLobby.updateMany({
      where: { status: 'searching', expiresAt: { lt: new Date() } },
      data: { status: 'expired' },
    })
  }

  async expireUnconfirmedMatches() {
    const stale = await prisma.matchmakingMatch.findMany({
      where: { status: 'pending_confirm', confirmDeadline: { lt: new Date() } },
      select: { id: true, lobbyAId: true, lobbyBId: true },
    })
    if (stale.length === 0) return
    await prisma.$transaction([
      prisma.matchmakingMatch.updateMany({
        where: { id: { in: stale.map((m) => m.id) } },
        data: { status: 'cancelled' },
      }),
      prisma.matchmakingLobby.updateMany({
        where: { id: { in: stale.flatMap((m) => [m.lobbyAId, m.lobbyBId]) } },
        data: { status: 'searching', matchId: null },
      }),
    ])
  }

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

  private async getPlayerProfile(userId: string) {
    const player = await prisma.playerProfile.findUnique({ where: { userId } })
    if (!player) throw Errors.notFound('Player profile')
    return player
  }

  private async resolveCallerTeam(userId: string, teamId?: string) {
    const player = await this.getPlayerProfile(userId)
    if (teamId) {
      const team = await prisma.team.findUnique({ where: { id: teamId } })
      if (!team) throw Errors.notFound('Team')
      if (team.captainId !== player.id && team.createdByUserId !== userId) throw Errors.forbidden()
      return team
    }
    return prisma.team.findFirst({
      where: { OR: [{ captainId: player.id }, { createdByUserId: userId }] },
      orderBy: { createdAt: 'desc' },
    })
  }

  private async getTeamAgeGroup(teamId: string) {
    const team = await prisma.team.findUnique({
      where: { id: teamId },
      select: { captainId: true },
    })
    if (!team?.captainId) return null
    const p = await prisma.playerProfile.findUnique({
      where: { id: team.captainId },
      select: { dateOfBirth: true },
    })
    return this.deriveAgeGroup(p?.dateOfBirth ?? null)
  }

  private async getTeamAgeGroupsMap(teamIds: string[], tx: any = prisma) {
    if (teamIds.length === 0) return new Map<string, string | null>()
    const teams = await tx.team.findMany({
      where: { id: { in: teamIds } },
      select: { id: true, captainId: true },
    })
    const captainIds = teams
      .map((t: any) => (typeof t.captainId === 'string' ? t.captainId : null))
      .filter((v: string | null): v is string => !!v)
    const captains = captainIds.length
      ? await tx.playerProfile.findMany({
          where: { id: { in: captainIds } },
          select: { id: true, dateOfBirth: true },
        })
      : []
    const capMap = new Map<string, string | null>(
      captains.map((c: any) => [String(c.id), this.deriveAgeGroup(c.dateOfBirth)]),
    )
    const out = new Map<string, string | null>()
    for (const t of teams as any[]) {
      const teamId = typeof t.id === 'string' ? t.id : String(t.id)
      const captainId = typeof t.captainId === 'string' ? t.captainId : null
      out.set(teamId, captainId ? (capMap.get(captainId) ?? null) : null)
    }
    return out
  }

  private deriveAgeGroup(dob: Date | null | undefined): string | null {
    if (!dob) return null
    const now = new Date()
    let age = now.getUTCFullYear() - dob.getUTCFullYear()
    const m = now.getUTCMonth() - dob.getUTCMonth()
    if (m < 0 || (m === 0 && now.getUTCDate() < dob.getUTCDate())) age -= 1
    if (age < 16) return 'U16'
    if (age < 19) return 'U19'
    return 'SENIOR'
  }

  private formatDurationMins(format: MatchmakingFormat, overs?: number) {
    if (format === 'T10') return 240
    if (format === 'T20') return 240
    if (format === 'ODI') return 480
    if (format === 'Test') return 480
    if (format === 'Custom') return (overs ?? 20) > 20 ? 480 : 240
    return 240
  }

  private generateDaySlots(openTime: string, closeTime: string, stepMins: number) {
    const slots: Array<{ start: string; end: string }> = []
    const open  = this.timeToMinutes(openTime)
    const close = this.timeToMinutes(closeTime)
    const step  = stepMins > 0 ? stepMins : 60
    for (let t = open; t + step <= close; t += step) {
      slots.push({ start: this.minutesToTime(t), end: this.minutesToTime(t + step) })
    }
    return slots
  }

  private startOfDay(dateStr: string) {
    const [y, m, d] = dateStr.split('-').map(Number)
    return new Date(Date.UTC(y, (m || 1) - 1, d || 1))
  }

  private toDateOnly(d: Date) {
    return d.toISOString().slice(0, 10)
  }

  private daysFromNow(d: Date) {
    const now = new Date()
    const today = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()))
    return Math.round((new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate())).getTime() - today.getTime()) / 86400000)
  }

  private timeToMinutes(time: string) {
    const [h, m] = time.split(':').map(Number)
    return (h || 0) * 60 + (m || 0)
  }

  private minutesToTime(total: number) {
    const h = Math.floor(total / 60).toString().padStart(2, '0')
    const m = (total % 60).toString().padStart(2, '0')
    return `${h}:${m}`
  }

  private isOverlap(aStart: string, aEnd: string, bStart: string, bEnd: string) {
    return this.timeToMinutes(aStart) < this.timeToMinutes(bEnd) &&
      this.timeToMinutes(aEnd) > this.timeToMinutes(bStart)
  }

  private generateStartSlots(
    openTime: string,
    closeTime: string,
    stepMins: number,
    durationMins: number,
    filterPastSlotsForToday = false,
  ) {
    const out: string[] = []
    const open = this.timeToMinutes(openTime)
    const close = this.timeToMinutes(closeTime)

    // Current time in IST (UTC+5:30), with a 60-min booking buffer
    const IST_OFFSET = 5.5 * 60
    const nowUtcMins = new Date().getUTCHours() * 60 + new Date().getUTCMinutes()
    const nowIstMins = (nowUtcMins + IST_OFFSET) % (24 * 60)
    const cutoffMins = filterPastSlotsForToday ? nowIstMins + 60 : -1

    for (let t = open; t + durationMins <= close; t += stepMins) {
      if (filterPastSlotsForToday && t < cutoffMins) continue
      out.push(this.minutesToTime(t))
    }
    return out
  }

  private isToday(dateStr: string) {
    const IST_OFFSET_MS = 5.5 * 60 * 60 * 1000
    const istNow = new Date(Date.now() + IST_OFFSET_MS)
    const todayIst = istNow.toISOString().slice(0, 10)
    return dateStr === todayIst
  }

  private arenaArea(address: string, city: string | null) {
    const parts = (address || '').split(',').map((s) => s.trim()).filter(Boolean)
    const meaningful = parts.find((p) => !/^\d+$/.test(p))
    return meaningful || city || 'Unknown'
  }

  private async hasOpponentLobby(input: {
    groundId: string
    slotTime: string
    date: Date
    format: MatchmakingFormat
    callerTeamId?: string
  }) {
    const count = await prisma.matchmakingLobbyPick.count({
      where: {
        groundId: input.groundId,
        slotTime: input.slotTime,
        lobby: {
          date: input.date,
          format: input.format,
          status: 'searching',
          expiresAt: { gt: new Date() },
          ...(input.callerTeamId ? { teamId: { not: input.callerTeamId } } : {}),
        },
      },
    })
    return count > 0
  }

  private async buildMatchSummary(matchId: string, lobbyId: string) {
    const match = await prisma.matchmakingMatch.findUnique({ where: { id: matchId } })
    if (!match) return null
    const [lobbyA, lobbyB, unit] = await Promise.all([
      prisma.matchmakingLobby.findUnique({ where: { id: match.lobbyAId }, include: { team: true } }),
      prisma.matchmakingLobby.findUnique({ where: { id: match.lobbyBId }, include: { team: true } }),
      prisma.arenaUnit.findUnique({ where: { id: match.groundId }, include: { arena: true } }),
    ])
    const opponent = lobbyA?.id === lobbyId ? lobbyB : lobbyA
    return {
      matchId: match.id,
      groundId: match.groundId,
      groundName: unit?.name ?? '',
      groundArea: unit ? this.arenaArea(unit.arena.address, unit.arena.city) : '',
      slotTime: match.slotTime,
      date: this.toDateOnly(match.date),
      format: match.format,
      opponentTeamName: opponent?.team?.name ?? '',
      pricePerTeam: match.paymentAmountPerTeam,
      confirmDeadline: match.confirmDeadline.toISOString(),
    }
  }

  private async createBookedSlotForMatch(match: any, tx: any) {
    const unit = await tx.arenaUnit.findUnique({ where: { id: match.groundId } })
    if (!unit) throw Errors.notFound('Arena unit')
    const aLobby = await tx.matchmakingLobby.findUnique({ where: { id: match.lobbyAId } })
    const bLobby = await tx.matchmakingLobby.findUnique({ where: { id: match.lobbyBId } })
    if (!aLobby || !bLobby) throw new AppError('INVALID_MATCH', 'Lobby missing for match', 400)

    const durationMins = this.formatDurationMins(match.format as MatchmakingFormat)
    const endTime = this.minutesToTime(this.timeToMinutes(match.slotTime) + durationMins)
    const totalAmount = match.paymentAmountPerTeam * 2

    const conflict = await tx.slotBooking.findFirst({
      where: {
        unitId: unit.id,
        date: match.date,
        status: { in: ['CONFIRMED', 'CHECKED_IN', 'PENDING_PAYMENT'] },
        startTime: { lt: endTime },
        endTime: { gt: match.slotTime },
      },
      select: { id: true },
    })
    if (conflict) throw new AppError('SLOT_ALREADY_BOOKED', 'Matched slot is no longer available', 409)

    const booking = await tx.slotBooking.create({
      data: {
        arenaId: unit.arenaId,
        unitId: unit.id,
        bookedById: aLobby.playerId,
        date: match.date,
        startTime: match.slotTime,
        endTime,
        durationMins,
        baseAmountPaise: totalAmount,
        totalAmountPaise: totalAmount,
        totalPricePaise: totalAmount,
        advancePaise: totalAmount,
        status: 'CONFIRMED',
        paymentMode: 'ONLINE',
        bookingSource: 'MATCHMAKING',
        notes: `matchmaking:${match.id};teamA:${aLobby.teamId};teamB:${bLobby.teamId}`,
        paidAt: new Date(),
      } as any,
    })
    return booking.id
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
