import crypto from 'crypto'
import { prisma, FacilityUnitType, Prisma } from '@swing/db'
import { Errors, AppError } from '../../lib/errors'
import { ArenaService } from '../arenas/arena.service'
import { NotificationService } from '../notifications/notification.service'
import Razorpay from 'razorpay'
import { areAgeGroupsCompatible } from './matchmaking.utils'

const notificationService = new NotificationService()

const MATCHMAKING_EXPIRY_HOURS = 24
const MAX_ACTIVE_REQUESTS = 3
const DEFAULT_MATCH_COST_PER_PLAYER_PAISE = 45000
const LOBBY_EXPIRY_HOURS = 24
const MATCH_PAYMENT_HOURS = 4
const CONFIRMATION_FEE_PAISE = 50000 // ₹500 flat per team
// V2 first-to-pay lock window. The team that taps Pay first holds the slot
// for this many seconds while their Razorpay order is alive.
const INTEREST_LOCK_SECONDS = 120

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
        sport: 'CRICKET',
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
        ? Promise.all(arenaIds.map((arenaId) => arenaService.getPlayerSlots(arenaId, input.date, duration, { onlyCricketUnits: true })))
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
          if (!areAgeGroupsCompatible(callerAge ?? null, age ?? null)) continue
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
      const groundFeePaise = Math.floor(unit.pricePerHourPaise * this.formatDurationMins(input.format) / 60 / 2)
      const remainingFeePaise = Math.max(0, groundFeePaise - CONFIRMATION_FEE_PAISE)
      // Clean up stale cancelled matches to avoid @unique constraint on lobbyAId/lobbyBId
      await tx.matchmakingMatch.deleteMany({
        where: {
          status: { in: ['cancelled', 'expired'] },
          OR: [{ lobbyAId: matchedLobby.id }, { lobbyBId: matchedLobby.id }],
        },
      })
      const match = await tx.matchmakingMatch.create({
        data: {
          lobbyAId: lobby.id,
          lobbyBId: matchedLobby.id,
          groundId: picked.groundId,
          slotTime: picked.slotTime,
          date,
          format: input.format,
          status: 'pending_payment',
          confirmDeadline: new Date(Date.now() + MATCH_PAYMENT_HOURS * 60 * 60 * 1000),
          teamAConfirmed: false,
          teamBConfirmed: false,
          paymentAmountPerTeam: CONFIRMATION_FEE_PAISE,
          groundFeePaise,
          remainingFeePaise,
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
    // Notify both captains that a matchup was found
    await this.notifyMatchFound(result.match.id).catch(() => undefined)
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
        status: { in: ['searching', 'matched', 'confirmed'] },
        expiresAt: { gt: new Date() },
      },
      include: { picks: { orderBy: { preferenceOrder: 'asc' } }, team: true },
      orderBy: { createdAt: 'desc' },
    })
    if (!lobby) return null

    // Expire the lobby lazily if its earliest pick slot has already passed
    const pickList0 = (lobby as any).picks as Array<{ groundId: string; slotTime: string }>
    const firstPick = pickList0[0]
    if (firstPick && this.isSlotPast(lobby.date, firstPick.slotTime)) {
      await prisma.matchmakingLobby.update({
        where: { id: lobby.id },
        data: { status: 'expired' },
      })
      return null
    }

    const pickList = pickList0
    const groundIds = pickList.map((p) => p.groundId)
    const units = groundIds.length
      ? await prisma.arenaUnit.findMany({
          where: { id: { in: groundIds } },
          select: { id: true, name: true, arena: { select: { name: true } } },
        })
      : []
    const unitById = new Map(units.map((u) => [u.id, u]))
    const out: any = {
      lobbyId: lobby.id,
      status: lobby.status,
      format: lobby.format,
      date: this.toDateOnly(lobby.date),
      teamId: lobby.teamId ?? null,
      teamName: (lobby as any).team?.name ?? null,
      picks: pickList.map((p) => ({
        groundId: p.groundId,
        groundName: unitById.get(p.groundId)?.arena?.name ?? unitById.get(p.groundId)?.name ?? null,
        slotTime: p.slotTime,
      })),
    }
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
    const today = this.startOfDay(new Date().toISOString().slice(0, 10))

    // Get all teams this user belongs to (captain, creator, or player member)
    const myTeams = await prisma.team.findMany({
      where: {
        OR: [
          { captainId: player.id },
          { createdByUserId: userId },
          { playerIds: { has: player.id } },
        ],
      },
      select: { id: true },
    })
    const myTeamIds = myTeams.map((t) => t.id)

    const lobbies = await prisma.matchmakingLobby.findMany({
      where: {
        status: 'searching',
        expiresAt: { gt: new Date() },
        // Exclude lobbies from any team the caller belongs to; arena lobbies (teamId=null) always show
        OR: [{ teamId: null }, { teamId: { notIn: myTeamIds } }],
        // if date given → exact match; otherwise show all upcoming lobbies from today
        ...(input.date ? { date: this.startOfDay(input.date) } : { date: { gte: today } }),
        ...(input.format ? { format: input.format } : {}),
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
        const pick = l.picks[0]
        if (this.isSlotPast(l.date, pick?.slotTime ?? null)) return false
        // Arena-owner lobbies are always visible
        if (l.arenaId != null || l.teamId == null) return true
        const lobbyAge = ages.get(l.teamId) ?? null
        return areAgeGroupsCompatible(callerAge ?? null, lobbyAge ?? null)
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
          pricePerTeam: unit ? Math.round(unit.pricePerHourPaise * this.formatDurationMins(l.format as MatchmakingFormat) / 60 / 2) : 90000,
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
        picks: { orderBy: { preferenceOrder: 'asc' } },
      },
      orderBy: { createdAt: 'asc' },
    })

    const teamIds: string[] = playerLobbies.flatMap((l) => l.teamId ? [l.teamId] : [])
    const ages = await this.getTeamAgeGroupsMap(teamIds)
    const groundIds = playerLobbies.flatMap((l) => l.picks.map((p: any) => p.groundId))
    const units = groundIds.length
      ? await prisma.arenaUnit.findMany({ where: { id: { in: groundIds } } })
      : []
    const unitsById = new Map(units.map((u) => [u.id, u]))

    // Fetch confirmed slot times for accepted lobbies (splitBookingId set)
    const acceptedBookingIds = playerLobbies
      .map((l) => (l as any).splitBookingId as string | null)
      .filter((id): id is string => !!id)
    const bookingStartTimes = acceptedBookingIds.length
      ? await prisma.slotBooking.findMany({
          where: { id: { in: acceptedBookingIds } },
          select: { id: true, startTime: true },
        })
      : []
    const startTimeByBookingId = new Map(bookingStartTimes.map((b) => [b.id, b.startTime]))

    // Plan B / V2 — count of teams who have actively expressed interest
    // (interested or locked) per lobby, so the Find Team tab can show
    // "5 interested" vs "no responses yet".
    const lobbyIds = playerLobbies.map((l) => l.id)
    const interestCounts = lobbyIds.length
      ? await prisma.matchmakingInterest.groupBy({
          by: ['lobbyId'],
          where: { lobbyId: { in: lobbyIds }, status: { in: ['interested', 'locked'] } },
          _count: { _all: true },
        })
      : []
    const interestCountByLobby = new Map(
      interestCounts.map((row) => [row.lobbyId, row._count._all] as const),
    )

    const out = playerLobbies
      .filter((l) => {
        const pick = l.picks[0]
        return !this.isSlotPast(l.date, pick?.slotTime ?? null)
      })
      .map((l) => {
        const firstPick = l.picks[0]
        const firstUnit = firstPick ? unitsById.get(firstPick.groundId) : null
        const splitBookingId = (l as any).splitBookingId as string | null
        return {
          lobbyId: l.id,
          teamName: l.team?.name ?? 'TBD',
          ageGroup: l.teamId ? (ages.get(l.teamId) ?? null) : null,
          format: l.format,
          ballType: (l as any).ballType ?? null,
          groundName: firstUnit?.name ?? null,
          unitId: firstPick?.groundId ?? null,
          pricePerTeam: firstUnit ? Math.round(firstUnit.pricePerHourPaise * this.formatDurationMins(l.format as MatchmakingFormat) / 60 / 2) : 90000,
          slotTime: firstPick?.slotTime ?? null,
          date: this.toDateOnly(l.date),
          daysFromNow: this.daysFromNow(l.date),
          accepted: !!splitBookingId,
          confirmedSlot: splitBookingId ? (startTimeByBookingId.get(splitBookingId) ?? null) : null,
          source: l.playerId ? 'player' : 'owner',
          interestCount: interestCountByLobby.get(l.id) ?? 0,
          picks: l.picks.map((p: any) => ({
            slotTime: p.slotTime,
            unitId: p.groundId,
            groundName: unitsById.get(p.groundId)?.name ?? null,
            preferenceOrder: p.preferenceOrder,
          })),
        }
      })
    return { lobbies: out }
  }

  async joinOpenLobby(userId: string, targetLobbyId: string, teamId: string) {
    const player = await this.getPlayerProfile(userId)
    const team = await this.resolveCallerTeam(userId, teamId)
    if (!team || team.id !== teamId) throw Errors.forbidden()

    const result = await prisma.$transaction(async (tx) => {
      const targetLobby = await tx.matchmakingLobby.findUnique({
        where: { id: targetLobbyId },
        include: { picks: { orderBy: { preferenceOrder: 'asc' }, take: 1 } },
      })
      if (!targetLobby) throw Errors.notFound('Lobby')
      if (targetLobby.status !== 'searching') throw new AppError('INVALID_STATE', 'Lobby is no longer open', 400)
      if (targetLobby.teamId === teamId) throw new AppError('SAME_TEAM', 'Cannot join your own lobby', 400)

      const pick = targetLobby.picks[0]
      if (!pick) throw new AppError('NO_PICKS', 'Lobby has no ground picks', 400)

      const unit = await tx.arenaUnit.findUnique({ where: { id: pick.groundId } })
      if (!unit) throw Errors.notFound('Arena unit')

      const groundFeePaise = Math.floor(unit.pricePerHourPaise * this.formatDurationMins(targetLobby.format as MatchmakingFormat) / 60 / 2)
      const remainingFeePaise = Math.max(0, groundFeePaise - CONFIRMATION_FEE_PAISE)
      const expiresAt = new Date(Date.now() + LOBBY_EXPIRY_HOURS * 60 * 60 * 1000)

      // Clean up any previously cancelled/expired matches for this lobby so the @unique
      // constraint on lobbyAId/lobbyBId doesn't block creating a fresh match.
      await tx.matchmakingMatch.deleteMany({
        where: {
          status: { in: ['cancelled', 'expired'] },
          OR: [{ lobbyAId: targetLobby.id }, { lobbyBId: targetLobby.id }],
        },
      })

      const joinerLobby = await tx.matchmakingLobby.create({
        data: {
          teamId: team.id,
          playerId: player.id,
          format: targetLobby.format,
          ballType: targetLobby.ballType,
          date: targetLobby.date,
          status: 'searching',
          expiresAt,
          picks: {
            create: [{ groundId: pick.groundId, slotTime: pick.slotTime, preferenceOrder: 1 }],
          },
        },
      })

      const match = await tx.matchmakingMatch.create({
        data: {
          lobbyAId: targetLobby.id,
          lobbyBId: joinerLobby.id,
          groundId: pick.groundId,
          slotTime: pick.slotTime,
          date: targetLobby.date,
          format: targetLobby.format,
          status: 'pending_payment',
          confirmDeadline: new Date(Date.now() + MATCH_PAYMENT_HOURS * 60 * 60 * 1000),
          teamAConfirmed: false,
          teamBConfirmed: false,
          paymentAmountPerTeam: CONFIRMATION_FEE_PAISE,
          groundFeePaise,
          remainingFeePaise,
        },
      })

      await tx.matchmakingLobby.updateMany({
        where: { id: { in: [targetLobby.id, joinerLobby.id] } },
        data: { status: 'matched', matchId: match.id },
      })

      return { joinerLobby, match }
    })

    await this.notifyMatchFound(result.match.id).catch(() => undefined)
    return {
      lobbyId: result.joinerLobby.id,
      status: 'matched' as const,
      match: await this.buildMatchSummary(result.match.id, result.joinerLobby.id),
    }
  }

  async acceptLobbyAsOwner(userId: string, lobbyId: string, arenaId: string, slotTime?: string) {
    const owner = await prisma.arenaOwnerProfile.findUnique({ where: { userId } })
    if (!owner) throw Errors.forbidden()
    const arena = await prisma.arena.findUnique({ where: { id: arenaId } })
    if (!arena || arena.ownerId !== owner.id) throw Errors.forbidden()

    const lobby = await prisma.matchmakingLobby.findUnique({
      where: { id: lobbyId },
      include: { picks: { orderBy: { preferenceOrder: 'asc' } } },
    })
    if (!lobby) throw Errors.notFound('Lobby')
    if (lobby.status !== 'searching') throw new AppError('INVALID_STATE', 'Lobby is no longer searching', 400)

    // Use the owner-chosen slot or fall back to first preference
    const pick = slotTime
      ? (lobby.picks.find((p: any) => p.slotTime === slotTime) ?? lobby.picks[0])
      : lobby.picks[0]
    if (!pick) throw new AppError('NO_PICKS', 'Lobby has no ground picks', 400)

    // Verify the pick's ground belongs to this arena
    const unit = await prisma.arenaUnit.findUnique({ where: { id: pick.groundId } })
    if (!unit || unit.arenaId !== arenaId) throw new AppError('GROUND_MISMATCH', 'Pick does not belong to this arena', 400)

    // Soft-block the slot
    const date = lobby.date
    const endMins = this.timeToMinutes(pick.slotTime) + 120
    const endTime = this.minutesToTime(endMins)

    const durationMins = this.formatDurationMins(lobby.format as MatchmakingFormat)
    const totalAmountPaise = Math.round(unit.pricePerHourPaise * durationMins / 60)

    const booking = await prisma.slotBooking.create({
      data: {
        arenaId,
        unitId: unit.id,
        bookedById: lobby.playerId,
        date,
        startTime: pick.slotTime,
        endTime,
        durationMins,
        format: lobby.format as any,
        totalAmountPaise,
        totalPricePaise: totalAmountPaise,
        baseAmountPaise: totalAmountPaise,
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


  async assignOpponentToLobby(userId: string, lobbyId: string, input: { teamId: string; teamName?: string }) {
    const owner = await prisma.arenaOwnerProfile.findUnique({ where: { userId } })
    if (!owner) throw Errors.forbidden()

    const lobby = await prisma.matchmakingLobby.findUnique({
      where: { id: lobbyId },
      include: { picks: { orderBy: { preferenceOrder: 'asc' }, take: 1 } },
    })
    if (!lobby) throw Errors.notFound('Lobby')
    if (lobby.status !== 'searching') throw new AppError('INVALID_STATE', 'Lobby is no longer searching', 400)

    // Verify the pick's ground belongs to an arena owned by this owner
    const pick = lobby.picks[0]
    if (!pick) throw new AppError('NO_PICKS', 'Lobby has no ground picks', 400)
    const unit = await prisma.arenaUnit.findUnique({ where: { id: pick.groundId }, include: { arena: true } })
    if (!unit || unit.arena.ownerId !== owner.id) throw new AppError('GROUND_MISMATCH', 'Pick does not belong to your arena', 400)

    // Resolve target team captain player profile id for the proxy lobby
    const targetTeam = await prisma.team.findUnique({
      where: { id: input.teamId },
      select: { id: true, captainId: true },
    })
    if (!targetTeam) throw Errors.notFound('Team')

    // captainId on Team is a playerProfile id; look up the userId via playerProfile
    let captainPlayerId = targetTeam.captainId ?? ''
    if (!captainPlayerId) {
      // fall back to lobby owner's player id — shouldn't happen for well-formed teams
      captainPlayerId = ''
    }

    const groundFeePaise = Math.floor(unit.pricePerHourPaise * this.formatDurationMins(lobby.format as MatchmakingFormat) / 60 / 2)
    const remainingFeePaise = Math.max(0, groundFeePaise - CONFIRMATION_FEE_PAISE)
    const expiresAt = new Date(Date.now() + LOBBY_EXPIRY_HOURS * 60 * 60 * 1000)

    const result = await prisma.$transaction(async (tx) => {
      // Clean stale matches on the existing lobby
      await tx.matchmakingMatch.deleteMany({
        where: {
          status: { in: ['cancelled', 'expired'] },
          OR: [{ lobbyAId: lobby.id }, { lobbyBId: lobby.id }],
        },
      })

      // Create a proxy lobby for the assigned team
      const proxyLobby = await tx.matchmakingLobby.create({
        data: {
          teamId: input.teamId,
          playerId: captainPlayerId,
          format: lobby.format,
          ballType: (lobby as any).ballType ?? null,
          date: lobby.date,
          status: 'searching',
          expiresAt,
          picks: {
            create: [{ groundId: pick.groundId, slotTime: pick.slotTime, preferenceOrder: 1 }],
          },
        },
      })

      const match = await tx.matchmakingMatch.create({
        data: {
          lobbyAId: lobby.id,
          lobbyBId: proxyLobby.id,
          groundId: pick.groundId,
          slotTime: pick.slotTime,
          date: lobby.date,
          format: lobby.format,
          status: 'pending_payment',
          confirmDeadline: new Date(Date.now() + MATCH_PAYMENT_HOURS * 60 * 60 * 1000),
          paymentAmountPerTeam: CONFIRMATION_FEE_PAISE,
          groundFeePaise,
          remainingFeePaise,
        },
      })

      await tx.matchmakingLobby.updateMany({
        where: { id: { in: [lobby.id, proxyLobby.id] } },
        data: {
          status: 'matched',
          matchId: match.id,
          // Clear any active payment lock — owner override outranks the
          // first-to-pay race.
          lockedByInterestId: null,
          lockExpiresAt: null,
        },
      })

      // V2 cleanup: any teams that had expressed interest in this lobby lose
      // out — the owner manually picked someone else. Mark them as 'lost' so
      // their player UI updates and we can fire notifications below.
      await tx.matchmakingInterest.updateMany({
        where: {
          lobbyId: lobby.id,
          status: { in: ['interested', 'locked'] },
        },
        data: { status: 'lost' },
      })

      return { match, proxyLobby }
    })

    // Notify both team captains + everyone who lost out due to the override.
    await this.notifyMatchFound(result.match.id).catch(() => undefined)
    this.notifyLosersOfSlotTaken(lobby.id, '__owner_override__')
        .catch(() => undefined)

    return { matchId: result.match.id, lobbyId: result.proxyLobby.id }
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
      if (!['pending_payment', 'pending_confirm'].includes(match.status)) throw new AppError('INVALID_STATE', 'Match is not pending confirmation', 400)

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

      const bookingId = await this.finalizeMatch(after, tx)
      return { status: 'confirmed' as const, bookingId }
    })
    if (result.status === 'confirmed') {
      this.notifyMatchConfirmed(matchId).catch(() => undefined)
    }
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
    if (match.status === 'confirmed') throw new AppError('INVALID_STATE', 'Cannot decline a confirmed match', 400)

    // Find the HELD booking on lobbyA (created by acceptLobbyAsOwner) to release the slot
    const lobbyA = await prisma.matchmakingLobby.findUnique({ where: { id: match.lobbyAId } })
    const heldBookingId = (lobbyA as any)?.splitBookingId as string | null

    await prisma.$transaction(async (tx) => {
      await tx.matchmakingMatch.update({ where: { id: matchId }, data: { status: 'cancelled' } })
      await tx.matchmakingLobby.updateMany({
        where: { id: { in: [match.lobbyAId, match.lobbyBId] } },
        data: { status: 'searching', matchId: null },
      })
      // Cancel the slot booking and clear splitBookingId so the slot is freed
      if (heldBookingId) {
        await tx.slotBooking.update({ where: { id: heldBookingId }, data: { status: 'CANCELLED' } })
        await tx.matchmakingLobby.update({
          where: { id: match.lobbyAId },
          data: { splitBookingId: null } as any,
        })
      }
      // Also cancel if match had a confirmed bookingId
      if ((match as any).bookingId && (match as any).bookingId !== heldBookingId) {
        await tx.slotBooking.update({
          where: { id: (match as any).bookingId },
          data: { status: 'CANCELLED' },
        })
      }
    })
    return { status: 'searching' as const, lobbyId }
  }

  async leaveLobby(userId: string, lobbyId: string) {
    const lobby = await prisma.matchmakingLobby.findUnique({
      where: { id: lobbyId },
      include: { picks: { include: { ground: true }, take: 1 } },
    })
    if (!lobby) throw Errors.notFound('Lobby')
    if (lobby.status !== 'searching') {
      throw new AppError('INVALID_STATE', 'Only searching lobbies can be left', 400)
    }

    // Authorisation: either the player who created the lobby OR the arena
    // owner whose ground the lobby's pick is on (covers owner-originated
    // listings where playerId is null).
    let authorised = false
    const player = await prisma.playerProfile.findUnique({ where: { userId } })
    if (player && lobby.playerId === player.id) authorised = true

    if (!authorised) {
      const owner = await prisma.arenaOwnerProfile.findUnique({ where: { userId } })
      if (owner) {
        const arenaIds = new Set<string>()
        if ((lobby as any).arenaId) arenaIds.add((lobby as any).arenaId)
        for (const p of lobby.picks) {
          if ((p as any).ground?.arenaId) arenaIds.add((p as any).ground.arenaId)
        }
        if (arenaIds.size > 0) {
          const arenas = await prisma.arena.findMany({
            where: { id: { in: Array.from(arenaIds) } },
            select: { ownerId: true },
          })
          if (arenas.some((a) => a.ownerId === owner.id)) authorised = true
        }
      }
    }
    if (!authorised) throw Errors.forbidden()

    await prisma.$transaction(async (tx) => {
      // V2 — mark all live interests as lost so the players' UI reflects
      // the cancellation. We don't refund here: lockAndPay only creates the
      // Razorpay order, no money has been captured unless the player
      // completed the Razorpay flow. If a verify-payment lands after this
      // cancel, it'll see lobby.status='cancelled' and refuse to create the
      // match — Razorpay refund is then handled by the webhook (out of scope
      // for this commit; webhook implementer should detect orphaned captures).
      await tx.matchmakingInterest.updateMany({
        where: {
          lobbyId,
          status: { in: ['interested', 'locked'] },
        },
        data: { status: 'lost' },
      })
      await tx.matchmakingLobby.update({
        where: { id: lobbyId },
        data: {
          status: 'cancelled',
          lockedByInterestId: null,
          lockExpiresAt: null,
        },
      })
    })

    // Notify out-of-band so the response is fast.
    this.notifyLosersOfSlotTaken(lobbyId, '__listing_cancelled__')
        .catch(() => undefined)
  }

  async expireStaleLobbies() {
    // Expire by expiresAt
    await prisma.matchmakingLobby.updateMany({
      where: { status: 'searching', expiresAt: { lt: new Date() } },
      data: { status: 'expired' },
    })

    // Expire lobbies whose first pick's slot time has passed (date = today, slotTime <= now IST)
    const today = new Date()
    const todayUTC = new Date(Date.UTC(today.getUTCFullYear(), today.getUTCMonth(), today.getUTCDate()))
    const nowIstMins = (today.getUTCHours() * 60 + today.getUTCMinutes() + 330) % 1440

    const todayLobbies = await prisma.matchmakingLobby.findMany({
      where: { status: 'searching', date: todayUTC },
      select: { id: true, picks: { orderBy: { preferenceOrder: 'asc' }, take: 1, select: { slotTime: true } } },
    })
    const pastIds = todayLobbies
      .filter((l) => {
        const slotTime = (l as any).picks[0]?.slotTime
        if (!slotTime) return false
        return this.timeToMinutes(slotTime) <= nowIstMins
      })
      .map((l) => l.id)

    if (pastIds.length > 0) {
      await prisma.matchmakingLobby.updateMany({
        where: { id: { in: pastIds } },
        data: { status: 'expired' },
      })
    }
  }

  async expireUnconfirmedMatches() {
    const stale = await prisma.matchmakingMatch.findMany({
      where: { status: 'pending_payment', confirmDeadline: { lt: new Date() } },
      select: { id: true, lobbyAId: true, lobbyBId: true, teamAPaymentId: true, teamBPaymentId: true },
    })
    if (stale.length === 0) return

    // Issue refunds for any teams that already paid
    for (const m of stale) {
      for (const paymentId of [m.teamAPaymentId, m.teamBPaymentId]) {
        if (!paymentId) continue
        try {
          const payment = await prisma.payment.findFirst({
            where: { id: paymentId, status: 'COMPLETED' },
            select: { id: true, gatewayPaymentId: true, amountPaise: true, userId: true },
          })
          if (payment?.gatewayPaymentId) {
            await getRazorpay().payments.refund(payment.gatewayPaymentId, {
              amount: payment.amountPaise,
              notes: { reason: 'Match expired — opponent did not pay in time' },
            })
            await prisma.payment.update({
              where: { id: payment.id },
              data: { status: 'REFUND_PENDING', refundReason: 'Match expired' },
            })
            // Notify the user about the refund
            await notificationService.createNotification(payment.userId, {
              type: 'mm_refund',
              title: 'Matchup expired — refund initiated',
              body: 'Your ₹500 deposit will be returned within 5-7 business days.',
              entityType: 'match',
              entityId: m.id,
              sendPush: true,
              audience: 'PLAYER',
            }).catch(() => undefined)
          }
        } catch (_) { /* best-effort */ }
      }
    }

    await prisma.$transaction([
      prisma.matchmakingMatch.updateMany({
        where: { id: { in: stale.map((m) => m.id) } },
        data: { status: 'expired' },
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

  // Returns true when a lobby's slot time is in the past for today (IST).
  private isSlotPast(lobbyDate: Date, slotTime: string | null): boolean {
    if (!slotTime) return false
    const now = new Date()
    const todayUTC = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()))
    const lobbyDayUTC = new Date(Date.UTC(lobbyDate.getUTCFullYear(), lobbyDate.getUTCMonth(), lobbyDate.getUTCDate()))
    if (lobbyDayUTC.getTime() !== todayUTC.getTime()) return false
    const nowIstMins = (now.getUTCHours() * 60 + now.getUTCMinutes() + 330) % 1440
    return this.timeToMinutes(slotTime) <= nowIstMins
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

  async listMyConfirmedMatches(userId: string) {
    const player = await this.getPlayerProfile(userId)

    // Find all lobbies belonging to this player (any status) that have a matchId
    const lobbies = await prisma.matchmakingLobby.findMany({
      where: { playerId: player.id, matchId: { not: null } },
      select: { id: true, matchId: true },
      orderBy: { createdAt: 'desc' },
    })

    // Find every active match where the player's team is on either side.
    // Includes pending_payment so owner-assigned matches show up immediately
    // (the player needs to see them to actually pay the advance), plus
    // confirmed/setup/started so the post-payment lifecycle stays visible.
    const directMatches = await prisma.matchmakingMatch.findMany({
      where: {
        status: { in: ['pending_payment', 'confirmed', 'setup', 'started'] },
        OR: [
          { lobbyAId: { in: lobbies.map((l) => l.id) } },
          { lobbyBId: { in: lobbies.map((l) => l.id) } },
        ],
      },
      orderBy: { date: 'asc' },
    })

    if (directMatches.length === 0) return { matches: [] }

    const matches = directMatches
    const matchIds = matches.map((m) => m.id)
    const lobbyByMatchId = new Map(
      lobbies
        .filter((l) => matchIds.includes(l.matchId as string))
        .map((l) => [l.matchId as string, l.id])
    )

    const groundIds = matches.map((m) => m.groundId)
    const lobbyIds = matches.flatMap((m) => [m.lobbyAId, m.lobbyBId])
    const [units, allLobbies] = await Promise.all([
      prisma.arenaUnit.findMany({
        where: { id: { in: groundIds } },
        include: { arena: { select: { name: true, address: true, city: true } } },
      }),
      prisma.matchmakingLobby.findMany({
        where: { id: { in: lobbyIds } },
        include: { team: { select: { id: true, name: true } } },
      }),
    ])

    const unitById = new Map(units.map((u) => [u.id, u]))
    const lobbyById = new Map(allLobbies.map((l) => [l.id, l]))

    const out = matches.map((m) => {
      const myLobbyId = lobbyByMatchId.get(m.id) ?? m.lobbyAId
      const isLobbyA = m.lobbyAId === myLobbyId
      const myLobby = lobbyById.get(myLobbyId)
      const opponentLobby = lobbyById.get(isLobbyA ? m.lobbyBId : m.lobbyAId)
      const unit = unitById.get(m.groundId)
      const n = new Date()
      const today = new Date(n.getFullYear(), n.getMonth(), n.getDate())
      const matchDate = new Date(m.date)
      const daysFromNow = Math.round((matchDate.getTime() - today.getTime()) / 86400000)
      // Per-side payment status so the UI can show "Pay ₹500" only when
      // *this* team still owes the advance.
      const myTeamPaid = isLobbyA ? m.teamAConfirmed : m.teamBConfirmed
      const opponentPaid = isLobbyA ? m.teamBConfirmed : m.teamAConfirmed
      return {
        matchId: m.id,
        myLobbyId,
        myTeamName: myLobby?.team?.name ?? 'Your Team',
        opponentTeamName: opponentLobby?.team?.name ?? 'Opponent',
        groundName: unit?.name ?? '',
        arenaName: (unit as any)?.arena?.name ?? '',
        groundArea: unit ? this.arenaArea((unit as any).arena?.address ?? '', (unit as any).arena?.city ?? '') : '',
        slotTime: m.slotTime,
        date: this.toDateOnly(m.date),
        daysFromNow,
        format: m.format,
        status: m.status,
        myTeamPaid,
        opponentPaid,
        confirmationFeePaise: m.paymentAmountPerTeam,
        groundFeePaise: m.groundFeePaise,
        remainingFeePaise: m.remainingFeePaise,
      }
    })
    return { matches: out }
  }

  async listArenaMatches(userId: string, arenaId: string) {
    const owner = await prisma.arenaOwnerProfile.findUnique({ where: { userId } })
    if (!owner) throw Errors.forbidden()
    const arena = await prisma.arena.findUnique({ where: { id: arenaId } })
    if (!arena || arena.ownerId !== owner.id) throw Errors.forbidden()

    const units = await prisma.arenaUnit.findMany({
      where: { arenaId },
      select: { id: true, name: true },
    })
    const unitIds = units.map((u) => u.id)
    if (unitIds.length === 0) return { matches: [] }

    const unitNameById = new Map(units.map((u) => [u.id, u.name]))

    const matches = await prisma.matchmakingMatch.findMany({
      where: {
        groundId: { in: unitIds },
        status: { in: ['pending_payment', 'confirmed', 'setup'] },
      },
      orderBy: { date: 'asc' },
    })

    if (matches.length === 0) return { matches: [] }

    // Batch-fetch all lobbies and teams
    const lobbyIds = matches.flatMap((m) => [m.lobbyAId, m.lobbyBId])
    const lobbies = await prisma.matchmakingLobby.findMany({
      where: { id: { in: lobbyIds } },
      include: { team: { select: { id: true, name: true } } },
    })
    const lobbyById = new Map(lobbies.map((l) => [l.id, l]))

    const out = matches.map((m) => {
      const lobbyA = lobbyById.get(m.lobbyAId)
      const lobbyB = lobbyById.get(m.lobbyBId)
      const n = new Date()
      const today = new Date(n.getFullYear(), n.getMonth(), n.getDate())
      const matchDate = new Date(m.date)
      const daysFromNow = Math.round((matchDate.getTime() - today.getTime()) / 86400000)
      return {
        matchId: m.id,
        teamAName: lobbyA?.team?.name ?? 'Team A',
        teamBName: lobbyB?.team?.name ?? 'Team B',
        teamALobbyId: m.lobbyAId,
        teamBLobbyId: m.lobbyBId,
        groundName: unitNameById.get(m.groundId) ?? '',
        slotTime: m.slotTime,
        date: this.toDateOnly(m.date),
        daysFromNow,
        format: m.format,
        status: m.status,
        teamAConfirmed: m.teamAConfirmed,
        teamBConfirmed: m.teamBConfirmed,
        confirmDeadline: m.confirmDeadline.toISOString(),
        confirmationFeePaise: m.paymentAmountPerTeam,
        groundFeePaise: (m as any).groundFeePaise ?? 0,
        remainingFeePaise: (m as any).remainingFeePaise ?? 0,
      }
    })
    return { matches: out }
  }

  private async finalizeMatch(match: any, tx: any): Promise<string> {
    const [lobbyA, lobbyB, unit] = await Promise.all([
      tx.matchmakingLobby.findUnique({ where: { id: match.lobbyAId }, include: { team: true } }),
      tx.matchmakingLobby.findUnique({ where: { id: match.lobbyBId }, include: { team: true } }),
      tx.arenaUnit.findUnique({ where: { id: match.groundId }, include: { arena: { include: { owner: true } } } }),
    ])
    const heldBookingId = (lobbyA as any)?.splitBookingId as string | null

    let bookingId: string
    if (heldBookingId) {
      await tx.slotBooking.update({
        where: { id: heldBookingId },
        data: { status: 'CONFIRMED', paidAt: new Date() },
      })
      bookingId = heldBookingId
    } else {
      bookingId = await this.createBookedSlotForMatch(match, tx)
    }

    // Resolve arena owner's player profile (if they have one) to grant scoring rights.
    const arenaOwnerUserId = (unit as any)?.arena?.owner?.userId as string | undefined
    let arenaOwnerProfileId: string | null = null
    if (arenaOwnerUserId) {
      const pp = await tx.playerProfile.findUnique({ where: { userId: arenaOwnerUserId }, select: { id: true } })
      arenaOwnerProfileId = pp?.id ?? null
    }

    // scorerId = arena owner's player profile (primary scorer for the venue).
    // teamACaptainId / teamBCaptainId = both team captains.
    // buildMatchHistoryForProfileId checks all three so all three get canScore=true.
    const formatMap: Record<string, string> = {
      T10: 'T10', T20: 'T20', ODI: 'ONE_DAY', Test: 'TWO_INNINGS', Custom: 'CUSTOM',
    }
    const matchFormat = formatMap[match.format] ?? 'T20'
    const [hh, mm] = match.slotTime.split(':').map(Number)
    const scheduledAt = new Date(match.date)
    scheduledAt.setUTCHours(hh, mm, 0, 0)
    const linkedMatch = await tx.match.create({
      data: {
        matchType: 'FRIENDLY' as any,
        format: matchFormat as any,
        status: 'SCHEDULED' as any,
        teamAName: (lobbyA as any)?.team?.name ?? 'Team A',
        teamBName: (lobbyB as any)?.team?.name ?? 'Team B',
        teamAId: (lobbyA as any)?.teamId ?? null,
        teamBId: (lobbyB as any)?.teamId ?? null,
        teamACaptainId: (lobbyA as any)?.playerId ?? null,
        teamBCaptainId: (lobbyB as any)?.playerId ?? null,
        scheduledAt,
        // For matchmaking matches we leave scorer unassigned at creation time:
        // the arena owner already has venue-level authority via the biz app and
        // pinning them here as scorerId leaks an "owner" match-role into the
        // player app via the legacy match-role fallback (scorerId === self → owner).
        scorerId: null,
        venueName: (unit as any)?.arena?.name ?? (unit as any)?.name ?? null,
        ballType: (lobbyA as any)?.ballType ?? null,
        matchmakingId: match.id,
      },
    })

    await tx.matchmakingMatch.update({
      where: { id: match.id },
      data: { status: 'confirmed', bookingId, linkedMatchId: linkedMatch.id },
    })
    await tx.matchmakingLobby.updateMany({
      where: { id: { in: [match.lobbyAId, match.lobbyBId] } },
      data: { status: 'confirmed' },
    })

    // Grant the arena owner OWNER role on the cricket Match. Without this row,
    // resolveMatchRole returns null for the arena owner (matchmaking matches
    // have scorerId=null and no slotBooking link), so they can't edit/start/
    // delete from the player Play tab.
    if (arenaOwnerProfileId) {
      await tx.matchRole.upsert({
        where: {
          matchId_profileId_role: {
            matchId: linkedMatch.id,
            profileId: arenaOwnerProfileId,
            role: 'OWNER',
          },
        },
        update: {},
        create: {
          matchId: linkedMatch.id,
          profileId: arenaOwnerProfileId,
          role: 'OWNER',
          grantedBy: arenaOwnerProfileId,
        },
      })
    }

    return bookingId
  }

  async markMatchPaidOffline(userId: string, matchId: string, lobbyId: string) {
    const owner = await prisma.arenaOwnerProfile.findUnique({ where: { userId } })
    if (!owner) throw Errors.forbidden()

    const match = await prisma.matchmakingMatch.findUnique({ where: { id: matchId } })
    if (!match) throw Errors.notFound('Match')

    // Verify the ground belongs to this owner's arena
    const unit = await prisma.arenaUnit.findUnique({
      where: { id: match.groundId },
      include: { arena: true },
    })
    if (!unit || unit.arena.ownerId !== owner.id) throw Errors.forbidden()

    if (lobbyId !== match.lobbyAId && lobbyId !== match.lobbyBId) {
      throw new AppError('INVALID_LOBBY', 'Lobby is not part of this match', 400)
    }

    // Already fully confirmed — nothing to finalize
    if (match.status === 'confirmed') {
      return { status: 'confirmed' as const, bookingId: (match as any).bookingId }
    }

    const updates: any = {}
    if (match.lobbyAId === lobbyId) updates.teamAConfirmed = true
    if (match.lobbyBId === lobbyId) updates.teamBConfirmed = true

    const result = await prisma.$transaction(async (tx) => {
      const after = await tx.matchmakingMatch.update({
        where: { id: matchId },
        data: updates,
      })

      if (after.teamAConfirmed && after.teamBConfirmed) {
        const bookingId = await this.finalizeMatch(after, tx)
        return { status: 'confirmed' as const, bookingId }
      }
      return { status: 'waiting_opponent' as const }
    })

    if (result.status === 'confirmed') {
      this.notifyMatchConfirmed(matchId).catch(() => undefined)
    }
    return result
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
    const isLobbyA = lobbyA?.id === lobbyId
    return {
      matchId: match.id,
      groundId: match.groundId,
      groundName: unit?.name ?? '',
      groundArea: unit ? this.arenaArea(unit.arena.address, unit.arena.city) : '',
      slotTime: match.slotTime,
      date: this.toDateOnly(match.date),
      format: match.format,
      status: match.status,
      opponentTeamName: opponent?.team?.name ?? '',
      pricePerTeam: match.paymentAmountPerTeam,
      confirmationFeePaise: match.paymentAmountPerTeam,
      groundFeePaise: (match as any).groundFeePaise ?? 0,
      remainingFeePaise: (match as any).remainingFeePaise ?? 0,
      myTeamPaid: isLobbyA ? (match as any).teamAPaid : (match as any).teamBPaid,
      opponentPaid: isLobbyA ? (match as any).teamBPaid : (match as any).teamAPaid,
      myTeamConfirmed: isLobbyA ? match.teamAConfirmed : match.teamBConfirmed,
      opponentConfirmed: isLobbyA ? match.teamBConfirmed : match.teamAConfirmed,
      confirmDeadline: match.confirmDeadline.toISOString(),
    }
  }

  private async notifyMatchFound(matchId: string) {
    const match = await prisma.matchmakingMatch.findUnique({ where: { id: matchId } })
    if (!match) return
    const [lobbyA, lobbyB] = await Promise.all([
      prisma.matchmakingLobby.findUnique({ where: { id: match.lobbyAId }, include: { team: true } }),
      prisma.matchmakingLobby.findUnique({ where: { id: match.lobbyBId }, include: { team: true } }),
    ])
    const captains = [
      { lobby: lobbyA, opponent: lobbyB },
      { lobby: lobbyB, opponent: lobbyA },
    ]
    for (const { lobby, opponent } of captains) {
      if (!lobby?.playerId) continue
      const profile = await prisma.playerProfile.findUnique({
        where: { id: lobby.playerId },
        select: { userId: true },
      })
      if (!profile?.userId) continue
      await notificationService.createNotification(profile.userId, {
        type: 'mm_match_found',
        title: 'Matchup found! Pay ₹500 to confirm',
        body: `${opponent?.team?.name ?? 'An opponent'} wants to play. Pay ₹500 to lock the slot.`,
        entityType: 'match',
        entityId: matchId,
        data: { lobbyId: lobby.id },
        sendPush: true,
        audience: 'PLAYER',
      }).catch(() => undefined)
    }
  }

  private async notifyMatchConfirmed(matchId: string) {
    const match = await prisma.matchmakingMatch.findUnique({ where: { id: matchId } })
    if (!match) return
    const [lobbyA, lobbyB, unit] = await Promise.all([
      prisma.matchmakingLobby.findUnique({ where: { id: match.lobbyAId }, include: { team: true } }),
      prisma.matchmakingLobby.findUnique({ where: { id: match.lobbyBId }, include: { team: true } }),
      prisma.arenaUnit.findUnique({ where: { id: match.groundId }, select: { name: true } }),
    ])
    const groundName = unit?.name ?? 'the ground'
    const [hh, mm] = match.slotTime.split(':').map(Number)
    const ampm = hh < 12 ? 'AM' : 'PM'
    const h = hh === 0 ? 12 : hh > 12 ? hh - 12 : hh
    const slotDisplay = `${h}:${String(mm).padStart(2, '0')} ${ampm}`
    const dateLabel = this.toDateOnly(match.date)

    const captains = [
      { lobby: lobbyA, opponent: lobbyB },
      { lobby: lobbyB, opponent: lobbyA },
    ]
    for (const { lobby, opponent } of captains) {
      if (!lobby?.playerId) continue
      const profile = await prisma.playerProfile.findUnique({
        where: { id: lobby.playerId },
        select: { userId: true },
      })
      if (!profile?.userId) continue
      await notificationService.createNotification(profile.userId, {
        type: 'mm_match_confirmed',
        title: 'Match confirmed!',
        body: `${opponent?.team?.name ?? 'Your opponent'} at ${groundName} — ${dateLabel} ${slotDisplay}`,
        entityType: 'match',
        entityId: matchId,
        data: { lobbyId: lobby.id },
        sendPush: true,
        audience: 'PLAYER',
      }).catch(() => undefined)
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
        advancePaise: 0,
        status: 'CONFIRMED',
        paymentMode: 'ONLINE',
        bookingSource: 'MATCHMAKING',
        notes: `matchmaking:${match.id};teamA:${aLobby.teamId};teamB:${bLobby.teamId}`,
        paidAt: null,
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

  async backfillLinkedMatches(): Promise<{ processed: number; skipped: number; errors: string[] }> {
    // Pull every MmMatch that *should* have a paired cricket Match:
    // status confirmed (advance in), setup (owner ran setup), or started (legacy).
    const candidates = await prisma.matchmakingMatch.findMany({
      where: { status: { in: ['confirmed', 'setup', 'started'] } },
    })

    // Group them by case:
    //   A. linkedMatchId is null          → create cricket Match (existing path)
    //   B. linkedMatchId points to nothing → cricket Match was deleted, recreate
    const linkedIds = candidates
      .map((m) => (m as any).linkedMatchId as string | null)
      .filter((id): id is string => !!id)
    const existing = linkedIds.length
      ? await prisma.match.findMany({
          where: { id: { in: linkedIds } },
          select: { id: true },
        })
      : []
    const existingIds = new Set(existing.map((m) => m.id))

    const unlinked = candidates.filter((m) => {
      const id = (m as any).linkedMatchId as string | null
      return !id || !existingIds.has(id)
    })

    let processed = 0
    let skipped = 0
    const errors: string[] = []

    for (const match of unlinked) {
      try {
        const [lobbyA, lobbyB, unit] = await Promise.all([
          prisma.matchmakingLobby.findUnique({ where: { id: match.lobbyAId }, include: { team: true } }),
          prisma.matchmakingLobby.findUnique({ where: { id: match.lobbyBId }, include: { team: true } }),
          prisma.arenaUnit.findUnique({ where: { id: match.groundId }, include: { arena: { include: { owner: true } } } }),
        ])

        const teamAName = (lobbyA as any)?.team?.name
        const teamBName = (lobbyB as any)?.team?.name
        if (!teamAName || !teamBName) {
          skipped++
          errors.push(`match ${match.id}: missing team name (lobbyA=${match.lobbyAId}, lobbyB=${match.lobbyBId})`)
          continue
        }

        const arenaOwnerUserId = (unit as any)?.arena?.owner?.userId as string | undefined
        let arenaOwnerProfileId: string | null = null
        if (arenaOwnerUserId) {
          const pp = await prisma.playerProfile.findUnique({ where: { userId: arenaOwnerUserId }, select: { id: true } })
          arenaOwnerProfileId = pp?.id ?? null
        }

        const formatMap: Record<string, string> = {
          T10: 'T10', T20: 'T20', ODI: 'ONE_DAY', Test: 'TWO_INNINGS', Custom: 'CUSTOM',
        }
        const matchFormat = formatMap[match.format] ?? 'T20'
        const [hh, mm] = match.slotTime.split(':').map(Number)
        const scheduledAt = new Date(match.date)
        scheduledAt.setUTCHours(hh, mm, 0, 0)

        const linkedMatch = await prisma.match.create({
          data: {
            matchType: 'FRIENDLY' as any,
            format: matchFormat as any,
            status: 'SCHEDULED' as any,
            teamAName,
            teamBName,
            teamAId: (lobbyA as any)?.teamId ?? null,
            teamBId: (lobbyB as any)?.teamId ?? null,
            teamACaptainId: (lobbyA as any)?.playerId ?? null,
            teamBCaptainId: (lobbyB as any)?.playerId ?? null,
            scheduledAt,
            // For matchmaking matches we leave scorer unassigned at creation time:
        // the arena owner already has venue-level authority via the biz app and
        // pinning them here as scorerId leaks an "owner" match-role into the
        // player app via the legacy match-role fallback (scorerId === self → owner).
        scorerId: null,
            venueName: (unit as any)?.arena?.name ?? (unit as any)?.name ?? null,
            ballType: (lobbyA as any)?.ballType ?? null,
            matchmakingId: match.id,
          },
        })

        await prisma.matchmakingMatch.update({
          where: { id: match.id },
          data: { linkedMatchId: linkedMatch.id },
        })

        // Grant arena owner OWNER role on the recreated cricket Match.
        if (arenaOwnerProfileId) {
          await prisma.matchRole.upsert({
            where: {
              matchId_profileId_role: {
                matchId: linkedMatch.id,
                profileId: arenaOwnerProfileId,
                role: 'OWNER',
              },
            },
            update: {},
            create: {
              matchId: linkedMatch.id,
              profileId: arenaOwnerProfileId,
              role: 'OWNER',
              grantedBy: arenaOwnerProfileId,
            },
          })
        }

        processed++
      } catch (err: any) {
        errors.push(`match ${match.id}: ${err.message}`)
      }
    }

    return { processed, skipped, errors }
  }

  /**
   * Arena owner taps "Setup Match" once both teams' advance has been received
   * (matchmakingMatch.status === 'confirmed'). Marks the matchmakingMatch as
   * 'setup' so the row stays visible in the owner's Match-Up tab under
   * TODAY/UPCOMING but is no longer asking for the setup action.
   *
   * Does NOT touch Match.status — the cricket Match stays SCHEDULED until
   * scoring actually begins from the match-day scoring screen.
   *
   * Returns { linkedMatchId, status } so the client can deep-link to the
   * match details / scoring setup screen if it wants to.
   */
  async startMatchAsArenaOwner(userId: string, matchId: string) {
    const owner = await prisma.arenaOwnerProfile.findUnique({ where: { userId } })
    if (!owner) throw Errors.forbidden()

    const match = await prisma.matchmakingMatch.findUnique({ where: { id: matchId } })
    if (!match) throw Errors.notFound('Match')

    const unit = await prisma.arenaUnit.findUnique({
      where: { id: match.groundId },
      include: { arena: true },
    })
    if (!unit || unit.arena.ownerId !== owner.id) throw Errors.forbidden()

    // Idempotent: if already setup, just return the linked match.
    if (match.status === 'setup') {
      return {
        status: 'setup',
        linkedMatchId: (match as any).linkedMatchId ?? null,
      }
    }

    if (match.status !== 'confirmed') {
      throw new AppError(
        'NOT_READY_FOR_SETUP',
        'Match can only be set up after both teams pay the advance.',
        400,
      )
    }

    const linkedMatchId = (match as any).linkedMatchId as string | null
    if (!linkedMatchId) {
      throw new AppError(
        'NO_LINKED_MATCH',
        'Cricket match record missing — please contact support.',
        400,
      )
    }

    await prisma.matchmakingMatch.update({
      where: { id: matchId },
      data: { status: 'setup' },
    })

    return { status: 'setup', linkedMatchId }
  }

  async cancelMatchAsArenaOwner(userId: string, matchId: string) {
    const owner = await prisma.arenaOwnerProfile.findUnique({ where: { userId } })
    if (!owner) throw Errors.forbidden()

    const match = await prisma.matchmakingMatch.findUnique({ where: { id: matchId } })
    if (!match) throw Errors.notFound('Match')

    const unit = await prisma.arenaUnit.findUnique({
      where: { id: match.groundId },
      include: { arena: true },
    })
    if (!unit || unit.arena.ownerId !== owner.id) throw Errors.forbidden()

    if (match.status === 'cancelled') {
      return { status: 'cancelled' }
    }

    await prisma.$transaction(async (tx) => {
      await tx.matchmakingMatch.update({
        where: { id: matchId },
        data: { status: 'cancelled' },
      })
      await tx.matchmakingLobby.updateMany({
        where: { id: { in: [match.lobbyAId, match.lobbyBId] } },
        data: { status: 'searching', matchId: null },
      })
      if ((match as any).bookingId) {
        await tx.slotBooking.update({
          where: { id: (match as any).bookingId },
          data: { status: 'CANCELLED' },
        })
      }
      if ((match as any).linkedMatchId) {
        await tx.match.update({
          where: { id: (match as any).linkedMatchId },
          data: { status: 'CANCELLED' as any },
        })
      }
    })

    this.notifyMatchCancelledByOwner(matchId, unit.arena.name).catch(() => undefined)
    return { status: 'cancelled' }
  }

  private async notifyMatchCancelledByOwner(matchId: string, arenaName: string) {
    const match = await prisma.matchmakingMatch.findUnique({ where: { id: matchId } })
    if (!match) return
    const [lobbyA, lobbyB] = await Promise.all([
      prisma.matchmakingLobby.findUnique({ where: { id: match.lobbyAId } }),
      prisma.matchmakingLobby.findUnique({ where: { id: match.lobbyBId } }),
    ])
    for (const lobby of [lobbyA, lobbyB]) {
      if (!lobby?.playerId) continue
      const profile = await prisma.playerProfile.findUnique({ where: { id: lobby.playerId }, select: { userId: true } })
      if (!profile?.userId) continue
      await notificationService.createNotification(profile.userId, {
        type: 'mm_match_cancelled',
        title: 'Match Cancelled',
        body: `Your match at ${arenaName} has been cancelled by the arena.`,
        entityType: 'match',
        entityId: matchId,
        data: { lobbyId: lobby.id },
        sendPush: true,
        audience: 'PLAYER',
      }).catch(() => undefined)
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Plan B / V2 — first-to-pay matchmaking
  // ══════════════════════════════════════════════════════════════════════════

  /**
   * Returns the chronological list of interests on a lobby, gated to the
   * lobby's arena owner. Used by the biz Find Team Manage sheet so the
   * owner can see which teams responded (and pick one to confirm
   * manually if needed).
   */
  async listLobbyInterestsAsArenaOwner(userId: string, lobbyId: string) {
    const owner = await prisma.arenaOwnerProfile.findUnique({ where: { userId } })
    if (!owner) throw Errors.forbidden()

    const lobby = await prisma.matchmakingLobby.findUnique({
      where: { id: lobbyId },
      include: { picks: { include: { ground: true }, take: 1 } },
    })
    if (!lobby) throw Errors.notFound('Lobby')

    // Authorise: lobby's arena (owner-originated) OR any pick's ground
    // belongs to an arena owned by this caller.
    const arenaIds = new Set<string>()
    if (lobby.arenaId) arenaIds.add(lobby.arenaId)
    for (const p of lobby.picks) {
      if ((p as any).ground?.arenaId) arenaIds.add((p as any).ground.arenaId)
    }
    if (arenaIds.size === 0) throw Errors.forbidden()
    const arenas = await prisma.arena.findMany({
      where: { id: { in: Array.from(arenaIds) } },
      select: { ownerId: true },
    })
    const ownsThisArena = arenas.some((a) => a.ownerId === owner.id)
    if (!ownsThisArena) throw Errors.forbidden()

    const interests = await prisma.matchmakingInterest.findMany({
      where: { lobbyId },
      include: {
        team: { select: { id: true, name: true, city: true } },
        player: { select: { id: true, userId: true } },
      },
      orderBy: { expressedAt: 'asc' },
    })

    return {
      lobbyId,
      lockedByInterestId: (lobby as any).lockedByInterestId ?? null,
      lockExpiresAt: (lobby as any).lockExpiresAt
        ? (lobby as any).lockExpiresAt.toISOString()
        : null,
      interests: interests.map((i) => ({
        interestId: i.id,
        teamId: i.teamId,
        teamName: i.team?.name ?? 'Unknown',
        teamCity: (i.team as any)?.city ?? null,
        status: i.status,
        expressedAt: i.expressedAt.toISOString(),
        paidAt: i.paidAt ? i.paidAt.toISOString() : null,
      })),
    }
  }

  /**
   * B1 — Player expresses interest in an open lobby.
   *
   * No payment, no match created. Just records that this team wants the slot.
   * Idempotent: if the same team already expressed interest on this lobby,
   * the existing row is returned. Owner sees the count of interested teams
   * in their Find Team tab.
   */
  async expressInterest(userId: string, lobbyId: string, teamId: string) {
    const player = await this.getPlayerProfile(userId)
    const team = await this.resolveCallerTeam(userId, teamId)
    if (!team || team.id !== teamId) throw Errors.forbidden()

    const lobby = await prisma.matchmakingLobby.findUnique({
      where: { id: lobbyId },
    })
    if (!lobby) throw Errors.notFound('Lobby')
    if (lobby.status !== 'searching') {
      throw new AppError('INVALID_STATE', 'Lobby is no longer open', 400)
    }
    if (lobby.expiresAt < new Date()) {
      throw new AppError('LOBBY_EXPIRED', 'Lobby has expired', 400)
    }
    if (lobby.teamId === teamId) {
      throw new AppError('SAME_TEAM', 'Cannot express interest on your own lobby', 400)
    }

    // Idempotent — upsert keyed on (lobbyId, teamId).
    const interest = await prisma.matchmakingInterest.upsert({
      where: { lobbyId_teamId: { lobbyId, teamId } },
      create: {
        lobbyId,
        teamId,
        playerId: player.id,
        status: 'interested',
      },
      update: {
        // If a previous interest was lost / lock_expired and the slot
        // is back to searching, allow them to re-express.
        status: 'interested',
        playerId: player.id,
      },
    })

    this.notifyOwnerOfInterest(lobbyId, teamId).catch(() => undefined)

    return {
      interestId: interest.id,
      lobbyId: interest.lobbyId,
      teamId: interest.teamId,
      status: interest.status,
      expressedAt: interest.expressedAt.toISOString(),
    }
  }

  /**
   * B2 — Player taps "Pay" on an interest. Acquire the lobby's payment lock
   * atomically and mint a Razorpay order. If another team already holds an
   * unexpired lock, return LOCK_TAKEN — the client surfaces "slot just taken".
   */
  async acquireLockAndCreateOrder(userId: string, interestId: string) {
    const player = await this.getPlayerProfile(userId)

    // Atomic lock acquisition. SELECT inside a transaction with serializable
    // isolation gives us SELECT…FOR UPDATE semantics on the lobby row.
    const result = await prisma.$transaction(
      async (tx) => {
        const interest = await tx.matchmakingInterest.findUnique({
          where: { id: interestId },
          include: { lobby: { include: { picks: { orderBy: { preferenceOrder: 'asc' }, take: 1 } } } },
        })
        if (!interest) throw Errors.notFound('Interest')
        if (interest.playerId !== player.id) throw Errors.forbidden()
        if (interest.status !== 'interested') {
          throw new AppError('INVALID_STATE', `Interest is ${interest.status}`, 400)
        }

        const lobby = interest.lobby
        if (lobby.status !== 'searching') {
          throw new AppError('LOCK_TAKEN', 'Slot was just taken by another team', 409)
        }

        const now = new Date()
        const heldByOther =
          lobby.lockedByInterestId &&
          lobby.lockedByInterestId !== interest.id &&
          (lobby.lockExpiresAt ?? now) > now
        if (heldByOther) {
          throw new AppError('LOCK_TAKEN', 'Another team is paying right now — try again in a moment', 409)
        }

        const expiresAt = new Date(Date.now() + INTEREST_LOCK_SECONDS * 1000)

        await tx.matchmakingLobby.update({
          where: { id: lobby.id },
          data: { lockedByInterestId: interest.id, lockExpiresAt: expiresAt },
        })
        await tx.matchmakingInterest.update({
          where: { id: interest.id },
          data: { status: 'locked' },
        })

        return {
          interest,
          lobby,
          pick: lobby.picks[0],
          lockExpiresAt: expiresAt,
        }
      },
      { isolationLevel: Prisma.TransactionIsolationLevel.Serializable },
    )

    if (!result.pick) {
      throw new AppError('NO_PICKS', 'Lobby has no ground picks', 400)
    }

    const unit = await prisma.arenaUnit.findUnique({ where: { id: result.pick.groundId } })
    if (!unit) throw Errors.notFound('Arena unit')

    // Half the slot's ground fee is the per-team confirmation amount,
    // floored to CONFIRMATION_FEE_PAISE so the math matches existing
    // matchmaking flows. Owner can change this later via admin tools.
    const groundFeePaise = Math.floor(
      unit.pricePerHourPaise *
        this.formatDurationMins(result.lobby.format as MatchmakingFormat) /
        60 /
        2,
    )
    const amountPaise = CONFIRMATION_FEE_PAISE

    const order = await getRazorpay().orders.create({
      amount: amountPaise,
      currency: 'INR',
      receipt: `mm_int_${result.interest.id.slice(0, 14)}`,
      notes: {
        interestId: result.interest.id,
        lobbyId: result.lobby.id,
        teamId: result.interest.teamId,
      },
    })

    await prisma.matchmakingInterest.update({
      where: { id: result.interest.id },
      data: { razorpayOrderId: order.id },
    })

    return {
      interestId: result.interest.id,
      razorpayOrderId: order.id,
      razorpayKey: process.env.RAZORPAY_KEY_ID ?? '',
      amountPaise,
      currency: 'INR',
      groundFeePaise,
      lockExpiresAt: result.lockExpiresAt.toISOString(),
      lockSeconds: INTEREST_LOCK_SECONDS,
    }
  }

  /**
   * B3 — Player's payment came back from Razorpay. Verify signature, promote
   * the locked interest to "won" and create the Match. Mark every other
   * interest on this lobby as "lost" and notify their teams.
   */
  async verifyInterestPayment(
    userId: string,
    interestId: string,
    razorpayOrderId: string,
    razorpayPaymentId: string,
    razorpaySignature: string,
  ) {
    const player = await this.getPlayerProfile(userId)

    // 1. Validate Razorpay signature out-of-band (no DB locks needed yet).
    const expected = crypto
      .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET ?? '')
      .update(`${razorpayOrderId}|${razorpayPaymentId}`)
      .digest('hex')
    if (expected !== razorpaySignature) {
      throw new AppError('INVALID_SIGNATURE', 'Payment signature verification failed', 400)
    }

    // 2. Promote interest, create match, mark losers — all in one transaction.
    const result = await prisma.$transaction(async (tx) => {
      const interest = await tx.matchmakingInterest.findUnique({
        where: { id: interestId },
        include: { lobby: { include: { picks: { orderBy: { preferenceOrder: 'asc' }, take: 1 } } } },
      })
      if (!interest) throw Errors.notFound('Interest')
      if (interest.playerId !== player.id) throw Errors.forbidden()
      if (interest.razorpayOrderId !== razorpayOrderId) {
        throw new AppError('ORDER_MISMATCH', 'Razorpay order does not match this interest', 400)
      }

      // Idempotency: payment may be re-verified by client/webhook.
      if (interest.status === 'won') {
        const existingMatch = await tx.matchmakingMatch.findUnique({
          where: { lobbyAId: interest.lobbyId },
        })
        return { interest, match: existingMatch, lobby: interest.lobby, pick: interest.lobby.picks[0] }
      }

      if (interest.status !== 'locked') {
        // Lock might have expired between Razorpay capture and verify-call.
        // Try to reclaim if the lobby is still searching and unlocked.
        if (interest.status !== 'interested') {
          throw new AppError('LOCK_LOST', 'Lock expired before payment confirmed', 409)
        }
      }

      const lobby = interest.lobby
      if (lobby.status === 'matched') {
        // Someone else won this slot meanwhile. Mark this interest lost
        // and signal the client (caller will need to refund Razorpay capture).
        await tx.matchmakingInterest.update({
          where: { id: interest.id },
          data: { status: 'lost', razorpayPaymentId, paidAt: new Date() },
        })
        throw new AppError('SLOT_TAKEN', 'Slot was taken by another team — payment will be refunded', 409)
      }

      const pick = lobby.picks[0]
      if (!pick) throw new AppError('NO_PICKS', 'Lobby has no ground picks', 400)

      const unit = await tx.arenaUnit.findUnique({ where: { id: pick.groundId } })
      if (!unit) throw Errors.notFound('Arena unit')

      // Build a "joiner" lobby for the winning team (mirrors joinOpenLobby).
      const joinerLobby = await tx.matchmakingLobby.create({
        data: {
          teamId: interest.teamId,
          playerId: interest.playerId,
          format: lobby.format,
          ballType: lobby.ballType,
          date: lobby.date,
          status: 'matched',
          expiresAt: new Date(Date.now() + LOBBY_EXPIRY_HOURS * 60 * 60 * 1000),
          picks: {
            create: [{ groundId: pick.groundId, slotTime: pick.slotTime, preferenceOrder: 1 }],
          },
        },
      })

      const groundFeePaise = Math.floor(
        unit.pricePerHourPaise * this.formatDurationMins(lobby.format as MatchmakingFormat) / 60 / 2,
      )
      const remainingFeePaise = Math.max(0, groundFeePaise - CONFIRMATION_FEE_PAISE)

      const match = await tx.matchmakingMatch.create({
        data: {
          lobbyAId: lobby.id,
          lobbyBId: joinerLobby.id,
          groundId: pick.groundId,
          slotTime: pick.slotTime,
          date: lobby.date,
          format: lobby.format,
          status: 'pending_payment',
          confirmDeadline: new Date(Date.now() + MATCH_PAYMENT_HOURS * 60 * 60 * 1000),
          // Winner already paid — mark their side confirmed.
          teamAConfirmed: false,
          teamBConfirmed: true,
          paymentAmountPerTeam: CONFIRMATION_FEE_PAISE,
          groundFeePaise,
          remainingFeePaise,
        },
      })

      // Promote winner.
      await tx.matchmakingInterest.update({
        where: { id: interest.id },
        data: {
          status: 'won',
          razorpayPaymentId,
          paidAt: new Date(),
        },
      })

      // Mark all other interests as lost.
      await tx.matchmakingInterest.updateMany({
        where: {
          lobbyId: lobby.id,
          id: { not: interest.id },
          status: { in: ['interested', 'locked'] },
        },
        data: { status: 'lost' },
      })

      // Original lobby flips to matched, lock cleared, link to match.
      await tx.matchmakingLobby.update({
        where: { id: lobby.id },
        data: {
          status: 'matched',
          matchId: match.id,
          lockedByInterestId: null,
          lockExpiresAt: null,
        },
      })

      return { interest, match, lobby, pick, joinerLobby }
    })

    // Async notifications outside the tx.
    if (result.match) {
      this.notifyMatchFound(result.match.id).catch(() => undefined)
      this.notifyLosersOfSlotTaken(result.lobby.id, result.interest.id).catch(() => undefined)
    }

    return {
      interestId: result.interest.id,
      lobbyId: result.lobby.id,
      matchId: result.match?.id ?? null,
      status: 'won' as const,
    }
  }

  /**
   * B3 — sweeper. Releases locks whose lockExpiresAt has passed without a
   * successful payment verification. Also marks the holder's interest as
   * lock_expired so the UI can reflect it. Safe to run idempotently every
   * minute or two via a cron / BullMQ delayed job.
   */
  async releaseExpiredInterestLocks() {
    const now = new Date()
    const expired = await prisma.matchmakingLobby.findMany({
      where: {
        status: 'searching',
        lockedByInterestId: { not: null },
        lockExpiresAt: { lt: now },
      },
      select: { id: true, lockedByInterestId: true },
    })

    if (expired.length === 0) return { released: 0 }

    const releasedDetails: { lobbyId: string; expiredInterestId: string }[] = []
    for (const lobby of expired) {
      try {
        const released = await prisma.$transaction(async (tx) => {
          const fresh = await tx.matchmakingLobby.findUnique({
            where: { id: lobby.id },
            select: { status: true, lockedByInterestId: true, lockExpiresAt: true },
          })
          if (!fresh) return null
          if (fresh.status !== 'searching') return null
          if (!fresh.lockedByInterestId) return null
          if ((fresh.lockExpiresAt ?? now) >= now) return null

          const expiredInterestId = fresh.lockedByInterestId
          await tx.matchmakingInterest.updateMany({
            where: { id: expiredInterestId, status: 'locked' },
            data: { status: 'lock_expired' },
          })
          await tx.matchmakingLobby.update({
            where: { id: lobby.id },
            data: { lockedByInterestId: null, lockExpiresAt: null },
          })
          return expiredInterestId
        })
        if (released) {
          releasedDetails.push({ lobbyId: lobby.id, expiredInterestId: released })
        }
      } catch (err: any) {
        console.error('[releaseExpiredInterestLocks] error', { lobbyId: lobby.id, err: err.message })
      }
    }

    // Fire notifications outside the per-lobby transactions.
    for (const { lobbyId, expiredInterestId } of releasedDetails) {
      this.notifyLockExpired(lobbyId, expiredInterestId)
          .catch(() => undefined)
    }

    return { released: releasedDetails.length }
  }

  // ── Internal helpers (interest notifications) ──────────────────────────────

  private async notifyOwnerOfInterest(lobbyId: string, teamId: string) {
    const [lobby, team] = await Promise.all([
      prisma.matchmakingLobby.findUnique({
        where: { id: lobbyId },
        include: { arena: { include: { owner: true } }, team: true },
      }),
      prisma.team.findUnique({ where: { id: teamId }, select: { name: true } }),
    ])
    const ownerUserId = (lobby as any)?.arena?.owner?.userId
    if (!ownerUserId || !team) return
    await notificationService.createNotification(ownerUserId, {
      type: 'mm_interest_expressed',
      title: 'A team is interested!',
      body: `${team.name} wants to play your ${lobby?.format ?? ''} slot.`,
      entityType: 'matchmaking_lobby',
      entityId: lobbyId,
      data: { lobbyId, teamId },
      sendPush: true,
      audience: 'BIZ_OWNER',
    }).catch(() => undefined)
  }

  /// Lock expired without payment. Notify:
  ///   • the team that held the lock ("you didn't pay in time")
  ///   • all other still-interested teams ("the slot is open again")
  private async notifyLockExpired(lobbyId: string, expiredInterestId: string) {
    const [holder, others, lobby] = await Promise.all([
      prisma.matchmakingInterest.findUnique({
        where: { id: expiredInterestId },
        include: {
          player: { select: { userId: true } },
          team: { select: { name: true } },
        },
      }),
      prisma.matchmakingInterest.findMany({
        where: {
          lobbyId,
          status: 'interested',
          id: { not: expiredInterestId },
        },
        include: { player: { select: { userId: true } } },
      }),
      prisma.matchmakingLobby.findUnique({
        where: { id: lobbyId },
        include: { team: { select: { name: true } } },
      }),
    ])

    const slotName =
      `${lobby?.team?.name ?? ''} ${lobby?.format ?? ''}`.trim()

    if (holder?.player?.userId) {
      await notificationService.createNotification(holder.player.userId, {
        type: 'mm_lock_expired',
        title: "Lock expired",
        body: slotName.length > 0
          ? `Your payment didn't go through in time for ${slotName}. The slot is open again — be quicker next time.`
          : "Your payment didn't go through in time. The slot is open again — be quicker next time.",
        entityType: 'matchmaking_lobby',
        entityId: lobbyId,
        data: { lobbyId, interestId: expiredInterestId },
        sendPush: true,
        audience: 'PLAYER',
      }).catch(() => undefined)
    }

    for (const o of others) {
      const userId = (o.player as any)?.userId
      if (!userId) continue
      await notificationService.createNotification(userId, {
        type: 'mm_slot_reopened',
        title: 'Slot reopened',
        body: 'The team that locked it didn\'t pay in time. You can try to lock it now.',
        entityType: 'matchmaking_lobby',
        entityId: lobbyId,
        data: { lobbyId },
        sendPush: true,
        audience: 'PLAYER',
      }).catch(() => undefined)
    }
  }

  private async notifyLosersOfSlotTaken(lobbyId: string, winnerInterestId: string) {
    const losers = await prisma.matchmakingInterest.findMany({
      where: { lobbyId, id: { not: winnerInterestId }, status: 'lost' },
      include: { player: { select: { userId: true } }, team: { select: { name: true } } },
    })
    for (const l of losers) {
      const userId = (l.player as any)?.userId
      if (!userId) continue
      await notificationService.createNotification(userId, {
        type: 'mm_slot_taken',
        title: 'Slot taken by another team',
        body: `Another team just paid for that slot first. We\'ll notify you of similar matches.`,
        entityType: 'matchmaking_lobby',
        entityId: lobbyId,
        data: { lobbyId, teamId: l.teamId },
        sendPush: true,
        audience: 'PLAYER',
      }).catch(() => undefined)
    }
  }
}
