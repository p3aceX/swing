import crypto from 'crypto'
import { prisma, FacilityUnitType, Prisma } from '@swing/db'
import { Errors, AppError } from '../../lib/errors'
import { ArenaService } from '../arenas/arena.service'
import { NotificationService } from '../notifications/notification.service'
import { bumpDiscoverAllocation, getDiscoverAllocations } from '../../lib/redis'
import { CashfreeService } from '../payments/cashfree.service'
import { areAgeGroupsCompatible } from './matchmaking.utils'
import {
  matchInterval,
  intervalsOverlap,
  formatRange,
  bucketForSlotTime,
  bucketsForSlot,
  WINDOW_RANGES,
  TIME_WINDOWS,
  type TimeWindow,
} from './time-windows'

const notificationService = new NotificationService()

const MATCHMAKING_EXPIRY_HOURS = 24
const MAX_ACTIVE_REQUESTS = 3
const DEFAULT_MATCH_COST_PER_PLAYER_PAISE = 45000
const LOBBY_EXPIRY_HOURS = 24
const MATCH_PAYMENT_HOURS = 4
// TODO: set to 29900 (₹299) once we exit testing mode. While 0, the
// lock-and-pay flow bypasses Razorpay and finalizes the match immediately —
// see the zero-amount branch in acquireLockAndCreateOrder (bypasses Cashfree).
const CONFIRMATION_FEE_PAISE = 0
// V2 first-to-pay lock window. The team that taps Pay first holds the slot
// for this many seconds while their Cashfree order is alive.
const INTEREST_LOCK_SECONDS = 120

// 'ANY' = team is open to any format (Discover-flow "All formats" option).
// Treated as a wildcard during matching: a lobby with format='ANY' matches
// any other lobby's format, and vice versa.
export type MatchmakingFormat =
  | 'T10'
  | 'T20'
  | 'ODI'
  | 'Test'
  | 'Custom'
  | 'ANY'

const cashfree = new CashfreeService()
const MM_NOTIFY_URL = process.env.CASHFREE_NOTIFY_URL || 'https://api.swingcricket.in/payments/webhook'

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

      // The Where step in Discover Setup just needs the catalog of
      // matchable arenas — slot scoping happens later (Dates → Windows).
      // Don't drop a ground here when its same-day slots are exhausted;
      // the user will pick a future date in the next step anyway.
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

  // Auto-derive the unified (windowsRanked, groundsRanked) ranked arrays
  // applied at every lobby-create / lobby-update path. Derivation precedence:
  //   1. explicit windowsRanked arg (if non-empty) — used as-is
  //   2. bucketForSlotTime(picks[0].slotTime) — when picks present
  //   3. legacy singular timeWindow — back-compat for in-flight callers
  //   4. throw INVALID_INPUT 400 — neither arg nor pick can supply a window
  //
  // groundsRanked precedence:
  //   1. explicit groundsRanked arg — used as-is
  //   2. legacy preferredArenaIds — back-compat for in-flight callers
  //   3. ArenaUnit(picks[0].groundId).arenaId — when picks present and the
  //      groundId resolves to an arena
  //   4. [] — preference-only / "any nearby" lobby
  private async deriveLobbyRankedFields(input: {
    windowsRanked?: string[] | null
    groundsRanked?: string[] | null
    picks?: Array<{ groundId: string; slotTime: string }>
    legacyTimeWindow?: string | null
    legacyPreferredArenaIds?: string[]
    tx?: any
  }): Promise<{ windowsRanked: string[]; groundsRanked: string[] }> {
    const client = input.tx ?? prisma
    const picks = input.picks ?? []

    let windowsRanked: string[] = []
    if (input.windowsRanked && input.windowsRanked.length > 0) {
      windowsRanked = [...input.windowsRanked]
    } else if (picks.length > 0) {
      const bucket = bucketForSlotTime(picks[0].slotTime)
      if (bucket) windowsRanked = [bucket]
    }
    if (windowsRanked.length === 0 && input.legacyTimeWindow) {
      windowsRanked = [input.legacyTimeWindow]
    }
    if (windowsRanked.length === 0) {
      throw new AppError(
        'INVALID_INPUT',
        'windowsRanked is required (or supply picks to derive it)',
        400,
      )
    }

    let groundsRanked: string[] = []
    if (input.groundsRanked && input.groundsRanked.length > 0) {
      groundsRanked = [...input.groundsRanked]
    } else if (input.legacyPreferredArenaIds && input.legacyPreferredArenaIds.length > 0) {
      groundsRanked = [...input.legacyPreferredArenaIds]
    } else if (picks.length > 0) {
      const unit = await client.arenaUnit.findUnique({
        where: { id: picks[0].groundId },
        select: { arenaId: true },
      })
      if (unit?.arenaId) groundsRanked = [unit.arenaId]
    }

    return { windowsRanked, groundsRanked }
  }

  async createLobby(userId: string, input: {
    teamId: string
    format: MatchmakingFormat
    ballType?: string | null
    date: string
    picks: Array<{ groundId: string; slotTime: string }>
    // Unified ranked time-window list (>=1 entry required when picks are
    // absent; auto-derived from picks otherwise).
    windowsRanked?: string[]
    // Unified ranked ground list (max 3). Empty = any nearby. Auto-derived
    // from picks[0].groundId when picks are present and arg omitted.
    groundsRanked?: string[]
  }) {
    if (input.picks.length > 3) {
      throw new AppError('INVALID_PICKS', 'picks must contain at most 3 items', 400)
    }
    {
      const seen = new Set<string>()
      for (const p of input.picks) {
        const key = `${p.groundId}:${p.slotTime}`
        if (seen.has(key)) throw new AppError('INVALID_PICKS', 'Duplicate picks are not allowed', 400)
        seen.add(key)
      }
    }

    // Auto-derive unified ranked arrays. After this call both arrays are in
    // their final shape; windowsRanked is guaranteed non-empty.
    const { windowsRanked, groundsRanked } = await this.deriveLobbyRankedFields({
      windowsRanked: input.windowsRanked,
      groundsRanked: input.groundsRanked,
      picks: input.picks,
    })

    const player = await this.getPlayerProfile(userId)
    const team = await this.resolveCallerTeam(userId, input.teamId)
    if (!team || team.id !== input.teamId) throw Errors.forbidden()
    const callerAge = await this.getTeamAgeGroup(team.id)
    const date = this.startOfDay(input.date)

    // Date horizon: lobby `date` must be in [today, today+14d].
    this.assertDateInHorizon(date)

    // Expiry: lobbies live until the latest window in windowsRanked elapses
    // on the chosen date. With windowsRanked always populated, this is
    // uniform across player and arena lobbies.
    const expiresAt = this.computeDiscoverExpiry(date, windowsRanked as TimeWindow[])

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
          windowsRanked,
          windowsMatched: [],
          preferredArenaIds: groundsRanked,
          picks: {
            create: input.picks.map((p, i) => ({
              groundId: p.groundId,
              slotTime: p.slotTime,
              preferenceOrder: i + 1,
            })),
          },
        } as any,
        include: { picks: { orderBy: { preferenceOrder: 'asc' } } },
      })

      // No picks → no immediate slot-precise matching at creation. Wait for
      // an interest expression via the first-to-pay flow.
      if (input.picks.length === 0) {
        return { lobby, match: null }
      }

      const candidateLobbies = await tx.matchmakingLobby.findMany({
        where: {
          id: { not: lobby.id },
          teamId: { not: team.id },
          // Format match: 'ANY' on either side acts as a wildcard. If the
          // caller is 'ANY', accept all formats; otherwise accept exact or
          // 'ANY' on the candidate side.
          ...(input.format === 'ANY'
              ? {}
              : { format: { in: [input.format, 'ANY'] } }),
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
      const fee = await this.resolveFeeBreakdown(unit.arenaId, groundFeePaise, tx)
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
          platformFeePaise: fee.platformFeePaise,
          arenaPayoutPaise: fee.arenaPayoutPaise,
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
          select: { id: true, name: true, arenaId: true, arena: { select: { name: true } } },
        })
      : []
    const unitById = new Map(units.map((u) => [u.id, u]))

    // Re-validate each stored pick against the live availability grid for
    // its arena. Picks that are off-grid under the unit's current config
    // (e.g. unit hours/turnaround changed since lobby was created) are
    // surfaced as `available: false` so the UI can hide or de-emphasize
    // them. The lobby itself stays alive — players keep their windowsRanked.
    const dateApi = this.toDateOnly(lobby.date)
    const lobbyDurationMins = this.formatDurationMins(lobby.format as MatchmakingFormat)
    const liveSlotsByUnit = new Map<string, Set<string>>()
    const arenaIds = Array.from(new Set(units.map((u) => u.arenaId).filter(Boolean) as string[]))
    for (const aid of arenaIds) {
      try {
        const live = await new ArenaService().getPlayerSlots(aid, dateApi, lobbyDurationMins)
        for (const g of (live.unitGroups as any[])) {
          const uid = g.unitId
          if (!uid) continue
          liveSlotsByUnit.set(uid, new Set((g.availableSlots ?? []).map((s: any) => s.startTime)))
        }
      } catch {
        // Arena unreachable — picks for this arena fall through to available=false
      }
    }

    // Unified contract: preferredArenaIds is the canonical "groundsRanked"
    // storage. Surface the rank-1 ground's display name so clients can
    // pre-fill the Setup form on Modify-search.
    const preferredArenaIds = ((lobby as any).preferredArenaIds ?? []) as string[]
    const rank1ArenaId = preferredArenaIds[0] ?? null
    const preferredArenaName = rank1ArenaId
      ? (await prisma.arena.findUnique({
          where: { id: rank1ArenaId },
          select: { name: true },
        }))?.name ?? null
      : null
    const windowsRanked = ((lobby as any).windowsRanked ?? []) as string[]
    const out: any = {
      lobbyId: lobby.id,
      status: lobby.status,
      format: lobby.format,
      ballType: (lobby as any).ballType ?? null,
      date: this.toDateOnly(lobby.date),
      teamId: lobby.teamId ?? null,
      teamName: (lobby as any).team?.name ?? null,
      picks: pickList.map((p) => ({
        groundId: p.groundId,
        groundName: unitById.get(p.groundId)?.arena?.name ?? unitById.get(p.groundId)?.name ?? null,
        slotTime: p.slotTime,
        available: liveSlotsByUnit.get(p.groundId)?.has(p.slotTime) ?? false,
      })),
      windowsRanked,
      windowsMatched: ((lobby as any).windowsMatched ?? []) as string[],
      groundsRanked: preferredArenaIds,
      preferredArenaName,
    }
    if (lobby.matchId) out.match = await this.buildMatchSummary(lobby.matchId, lobby.id)
    return out
  }

  // ── Discover (preference-based search with ranking + alternatives) ─────────

  // Returns one active (or recent) lobby per team the caller belongs to. Used
  // by the team-switcher chip so the user can see, at a glance, which of
  // their teams are currently searching.
  async listMyActiveLobbies(userId: string) {
    const player = await this.getPlayerProfile(userId)
    const myTeams = await prisma.team.findMany({
      where: {
        OR: [
          { captainId: player.id },
          { createdByUserId: userId },
          { playerIds: { has: player.id } },
        ],
      },
      select: { id: true, name: true, logoUrl: true },
    })
    if (myTeams.length === 0) return { teams: [], lobbies: [] }
    const lobbies = await prisma.matchmakingLobby.findMany({
      where: {
        teamId: { in: myTeams.map((t) => t.id) },
        status: { in: ['searching', 'matched', 'confirmed'] },
        expiresAt: { gt: new Date() },
      },
      include: { team: true },
      orderBy: { createdAt: 'desc' },
    })
    // De-dupe to one lobby per team (most recent wins). Used by the
    // team-switcher chip to show *which* of the user's teams are
    // currently searching — that view only needs one summary per team.
    const byTeam = new Map<string, any>()
    for (const l of lobbies) {
      if (!l.teamId) continue
      if (!byTeam.has(l.teamId)) byTeam.set(l.teamId, l)
    }
    const serialize = (l: any) => ({
      lobbyId: l.id,
      teamId: l.teamId,
      teamName: l.team?.name ?? null,
      status: l.status,
      date: this.toDateOnly(l.date),
      format: l.format,
      ballType: l.ballType ?? null,
      windowsRanked: (l.windowsRanked ?? []) as string[],
      windowsMatched: (l.windowsMatched ?? []) as string[],
      groundsRanked: (l.preferredArenaIds ?? []) as string[],
    })
    return {
      teams: myTeams.map((t) => ({
        id: t.id,
        name: t.name,
        logoUrl: t.logoUrl,
      })),
      // One per team, for the chip.
      lobbies: Array.from(byTeam.values()).map(serialize),
      // Every active lobby. Drives the date strip on Discover Results so
      // a multi-date submission's full set of dates restores after the
      // app restarts (not just the most recent one).
      allLobbies: lobbies.map(serialize),
    }
  }

  // Single-shot discovery: ensures a team-owned lobby (find/create/update),
  // then runs scored search across the open lobbies. Returns ranked closest +
  // alternatives in one round trip.
  async discoverLobbies(
    userId: string,
    input: {
      teamId: string
      filters: {
        date: string
        format: MatchmakingFormat
        ballType?: string | null
        // Unified ranked time windows the team prefers. Order = preference;
        // first element is strongest. At least 1 element required.
        windowsRanked: Array<TimeWindow | string>
        // Unified ranked grounds (max 3). Empty = any nearby.
        groundsRanked: string[]
      }
      context?: { lat?: number; lng?: number }
    },
  ) {
    const player = await this.getPlayerProfile(userId)
    const team = await prisma.team.findUnique({
      where: { id: input.teamId },
      select: {
        id: true,
        captainId: true,
        createdByUserId: true,
        playerIds: true,
        matchupBanUntil: true,
        // Compatibility-filter inputs — caller side
        teamType: true,
        ageGroup: true,
        gender: true,
        credibilityScore: true,
      },
    })
    if (!team) throw Errors.notFound('Team')
    const isMember =
      team.captainId === player.id ||
      team.createdByUserId === userId ||
      team.playerIds.includes(player.id)
    if (!isMember) throw Errors.forbidden()

    // Soft-ban from matchmaking after repeat cancellations. The check looks
    // forward — banUntil > now means the team is still in the cooldown
    // window. credibilityScore on Team also reflects this.
    if ((team as any).matchupBanUntil && (team as any).matchupBanUntil > new Date()) {
      throw new AppError(
        'TEAM_BANNED',
        'This team is paused from match-ups due to recent cancellations. Try again after the cooldown.',
        403,
        { banUntil: (team as any).matchupBanUntil.toISOString() },
      )
    }

    const date = this.startOfDay(input.filters.date)
    // Date horizon: caller can only search within [today, today+14d].
    this.assertDateInHorizon(date)
    const callerAge = await this.getTeamAgeGroup(team.id)

    // Auto-derive unified ranked arrays. Frontend sends them in the unified
    // shape now — the helper enforces non-empty windowsRanked and uses
    // groundsRanked verbatim (empty allowed = any nearby).
    const derived = await this.deriveLobbyRankedFields({
      windowsRanked: input.filters.windowsRanked as string[],
      groundsRanked: input.filters.groundsRanked,
    })
    const windowsRanked = derived.windowsRanked as TimeWindow[]
    const groundsRanked = derived.groundsRanked

    const expiresAt = this.computeDiscoverExpiry(date, windowsRanked)

    // Reject already-expired requests up front. Without this, lobbies were
    // being persisted with expiresAt in the past (e.g. searching for today's
    // MORNING after 12:00 IST), which then failed the "active" filter and
    // produced duplicate rows on every retry.
    if (expiresAt.getTime() <= Date.now()) {
      throw new AppError(
        'WINDOW_PASSED',
        'The selected time window has already passed. Pick a future window or date.',
        400,
      )
    }

    // Slot-conflict guard (multi-match-per-day aware). A team can hold
    // multiple match-ups across different windows on the same date, so the
    // guard only fires on EXPLICIT overlap: any requested window must not
    // already appear in an existing match's matched-window set for this
    // team on this date.
    //
    // We walk this team's lobbies tied to active matches on the same date,
    // intersect their `windowsMatched` with the caller's `windowsRanked`,
    // and reject when the intersection is non-empty.
    const lobbiesWithActiveMatch = await prisma.matchmakingLobby.findMany({
      where: {
        teamId: team.id,
        matchId: { not: null },
        status: { in: ['matched', 'confirmed'] },
        date,
      },
      select: {
        matchId: true,
        windowsMatched: true,
      },
    })
    const activeMatchIds = lobbiesWithActiveMatch
      .map((l) => l.matchId)
      .filter((id): id is string => !!id)
    if (activeMatchIds.length > 0) {
      const sameDateMatches = await prisma.matchmakingMatch.findMany({
        where: {
          id: { in: activeMatchIds },
          status: { in: ['pending_payment', 'confirmed', 'setup', 'started'] },
          date,
        },
        select: { id: true, slotTime: true, format: true, lobbyAId: true, lobbyBId: true },
      })
      if (sameDateMatches.length > 0) {
        const requestedSet = new Set(windowsRanked as string[])
        for (const m of sameDateMatches) {
          // Use the lobby's matched-windows set as the source of truth for
          // "already booked" — falls back to the slot-derived bucket on
          // legacy rows where windowsMatched is empty.
          const lobbyRow = lobbiesWithActiveMatch.find((l) => l.matchId === m.id)
          const consumed = ((lobbyRow?.windowsMatched ?? []) as string[]).filter(Boolean)
          const fallbackBucket = consumed.length === 0
            ? bucketForSlotTime(m.slotTime)
            : null
          const consumedSet = new Set<string>(
            consumed.length > 0 ? consumed : (fallbackBucket ? [fallbackBucket] : []),
          )
          const overlap = [...requestedSet].some((w) => consumedSet.has(w))
          if (!overlap) continue
          // Resolve opponent team name for a friendlier error.
          const lobbies = await prisma.matchmakingLobby.findMany({
            where: { id: { in: [m.lobbyAId, m.lobbyBId] } },
            include: { team: { select: { name: true } } },
          })
          const opponentLobby = lobbies.find((l) => l.teamId !== team.id)
          const opponentName = opponentLobby?.team?.name ?? 'another team'
          const existing = matchInterval(m.slotTime, m.format)
          throw new AppError(
            'SLOT_CONFLICT',
            existing
              ? `Your team is already booked ${formatRange(existing.startMin, existing.endMin)} on this date vs ${opponentName}. Pick another window or open the match-up.`
              : `Your team already has a match-up in this window vs ${opponentName}. Pick another window.`,
            409,
            {
              existingMatchId: m.id,
              opponentTeamName: opponentName,
              ...(existing
                ? {
                    conflictRange: formatRange(existing.startMin, existing.endMin),
                    conflictStartMin: existing.startMin,
                    conflictEndMin: existing.endMin,
                  }
                : {}),
            },
          )
        }
      }
    }

    // V2: lobby key is (teamId, date, format, ballType, status='searching').
    // Re-submitting the same key UPDATES the existing lobby with the new
    // ranked preferences. Different keys produce separate lobbies (a team
    // can advertise supply for multiple dates / formats simultaneously).
    const yourLobby = await prisma.$transaction(async (tx) => {
      const existing = await tx.matchmakingLobby.findFirst({
        where: {
          teamId: team.id,
          status: 'searching',
          date,
          format: input.filters.format,
          ballType: input.filters.ballType ?? null,
        },
        orderBy: { createdAt: 'desc' },
      })
      if (existing) {
        return await tx.matchmakingLobby.update({
          where: { id: existing.id },
          data: {
            playerId: player.id, // re-assign to current member
            expiresAt,
            windowsRanked,
            // Preserve any windows that were already consumed by partial matches.
            preferredArenaIds: groundsRanked,
          } as any,
        })
      }
      return await tx.matchmakingLobby.create({
        data: {
          teamId: team.id,
          playerId: player.id,
          format: input.filters.format,
          ballType: input.filters.ballType ?? null,
          date,
          status: 'searching',
          expiresAt,
          windowsRanked,
          windowsMatched: [],
          preferredArenaIds: groundsRanked,
        } as any,
      })
    })

    // Pull candidate universe — same calendar date as caller; the V2 model
    // is date-precise (lobbies with different dates are separate entities).
    const candidatesRaw: any[] = await prisma.matchmakingLobby.findMany({
      where: {
        id: { not: yourLobby.id },
        teamId: { not: team.id },
        status: 'searching',
        expiresAt: { gt: new Date() },
        date,
        ...(input.filters.format === 'ANY'
          ? {}
          : { format: { in: [input.filters.format, 'ANY'] } }),
      },
      include: { team: true, picks: { orderBy: { preferenceOrder: 'asc' } } },
    })

    // Hard-filter pair compatibility on teamType + ageGroup + credibility
    // before scoring. Drops any candidate that could never be a viable
    // opponent regardless of preference overlap (e.g. a CORPORATE team
    // listed against a SCHOOL search; a U16 listing against an OPEN one).
    const candidates: any[] = candidatesRaw.filter((c) =>
      this.teamsAreCompatible(team, c.team ?? {}),
    )

    const groundIds = candidates.flatMap((c) =>
      c.picks.map((p: any) => p.groundId),
    )
    const units = groundIds.length
      ? await prisma.arenaUnit.findMany({
          where: { id: { in: groundIds } },
          include: { arena: true },
        })
      : []
    const unitsById = new Map(units.map((u) => [u.id, u]))

    // Live re-validation for concrete-pick opponents: stored picks may be
    // off-grid under the unit's current config (turnaround/hours changed
    // since lobby creation). Build a per-unit set of currently-bookable
    // start times so concrete-pick candidates whose slotTime no longer
    // aligns fall through to the tentative-slot path like a pure-preference
    // lobby would.
    const candidateDateApi = this.toDateOnly(date)
    const candidateDur = this.formatDurationMins(input.filters.format)
    const candidatePickArenaIds = Array.from(new Set(
      units.map((u) => (u as any).arenaId).filter(Boolean) as string[],
    ))
    const liveSlotsByPickUnit = new Map<string, Set<string>>()
    for (const aid of candidatePickArenaIds) {
      try {
        const live = await new ArenaService().getPlayerSlots(aid, candidateDateApi, candidateDur)
        for (const g of (live.unitGroups as any[])) {
          const uid = g.unitId
          if (!uid) continue
          liveSlotsByPickUnit.set(uid, new Set((g.availableSlots ?? []).map((s: any) => s.startTime)))
        }
      } catch {
        // Arena unreachable — picks for this arena fall through to tentative
      }
    }

    const arenaIds = [
      ...new Set(
        candidates.flatMap((c) => [
          ...((c.preferredArenaIds ?? []) as string[]),
          ...(typeof c.arenaId === 'string' ? [c.arenaId] : []),
        ]),
      ),
    ]
    const arenas = arenaIds.length
      ? await prisma.arena.findMany({
          where: { id: { in: arenaIds } },
          select: {
            id: true,
            name: true,
            matchRatingAvg: true,
            matchRatingCount: true,
          },
        })
      : []
    const arenasById = new Map(arenas.map((a) => [a.id, a]))

    // Tentative-ground resolution. When a candidate lobby has no concrete
    // arena (player↔player no-pref pairing), the response would otherwise
    // ship the ₹900 default and a hollow ground name. We pre-compute the
    // top-N candidate arenas (smart allocation from the caller's home
    // perspective) and pull each one's bookable slot grid. The per-pair
    // picker below selects the best venue for each candidate, balancing
    // load × quality so demand spreads across the market instead of
    // piling onto whichever arena ranked first.
    type TentativeSlot = {
      unitId: string
      startTime: string
      endTime: string
      pricePerTeamPaise: number
      buckets: TimeWindow[]
    }
    type TentativeArena = {
      id: string
      name: string
      pricePerHourPaise: number
      latitude: number
      longitude: number
      matchRatingAvg: number
      matchRatingCount: number
      slots: TentativeSlot[]
    }
    const TENTATIVE_POOL_SIZE = 5
    const tentativeArenasById = new Map<string, TentativeArena>()
    let tentativeArena: TentativeArena | null = null  // first-of-pool — back-compat fallback
    {
      const allocIds = await this.smartAnyGroundAllocation(input.teamId, prisma)
      // Add every arena referenced by candidate prefs/picks so per-pair
      // allocation can pick from the union of (caller prefs ∪ candidate
      // prefs ∪ smart-allocated regional pool).
      const referencedArenaIds = new Set<string>([
        ...allocIds.slice(0, TENTATIVE_POOL_SIZE),
        ...(groundsRanked ?? []),
        ...candidates.flatMap((c) => [
          ...((c.preferredArenaIds ?? []) as string[]),
          ...(typeof c.arenaId === 'string' ? [c.arenaId] : []),
        ]),
      ])
      const poolIds = Array.from(referencedArenaIds)
      const dur = this.formatDurationMins(input.filters.format)
      const dateApi = this.toDateOnly(date)
      // Fetch arenas + their cheapest cricket unit price; one arena per row.
      const arenaRows = poolIds.length
        ? await prisma.arena.findMany({
            where: { id: { in: poolIds }, isActive: true, units: { some: { isActive: true } } },
            select: {
              id: true, name: true, latitude: true, longitude: true,
              matchRatingAvg: true, matchRatingCount: true,
              units: {
                where: { isActive: true, sport: 'CRICKET' },
                orderBy: { pricePerHourPaise: 'asc' },
                take: 1,
                select: { pricePerHourPaise: true },
              },
            },
          })
        : []
      // Live slot fetch in parallel — N arenas × one getPlayerSlots call each.
      // Bounded by TENTATIVE_POOL_SIZE plus referenced ids; in practice ≤ 8.
      const slotResults = await Promise.all(
        arenaRows.map(async (a) => {
          if (!a.units[0]) return null
          try {
            const slotData = await new ArenaService().getPlayerSlots(
              a.id, dateApi, dur, { onlyCricketUnits: true },
            )
            const slots: TentativeSlot[] = []
            for (const group of slotData.unitGroups) {
              const ga = group as any
              const unitId = (ga.unitId as string | undefined) ?? ''
              for (const s of (ga.availableSlots ?? []) as Array<{
                startTime: string; endTime: string; totalAmountPaise: number
              }>) {
                slots.push({
                  unitId,
                  startTime: s.startTime,
                  endTime: s.endTime,
                  pricePerTeamPaise: Math.round(s.totalAmountPaise / 2),
                  buckets: bucketsForSlot(s.startTime, dur),
                })
              }
            }
            slots.sort((x, y) => x.startTime.localeCompare(y.startTime))
            return {
              id: a.id,
              name: a.name,
              pricePerHourPaise: a.units[0].pricePerHourPaise,
              latitude: a.latitude,
              longitude: a.longitude,
              matchRatingAvg: (a as any).matchRatingAvg ?? 3.0,
              matchRatingCount: (a as any).matchRatingCount ?? 0,
              slots,
            } as TentativeArena
          } catch {
            return null
          }
        }),
      )
      for (const t of slotResults) {
        if (t) tentativeArenasById.set(t.id, t)
      }
      // First-of-pool = the smart-allocator's top pick when present, else
      // the first arena in the map. Used as a final fallback when a
      // candidate's window has no live slot anywhere in the pool.
      const firstId = allocIds.find((id) => tentativeArenasById.has(id))
        ?? Array.from(tentativeArenasById.keys())[0]
      tentativeArena = firstId ? (tentativeArenasById.get(firstId) ?? null) : null
    }

    // Demand signal — count of active searching lobbies per arena on this
    // date PLUS recent discover-allocations (a 5-min Redis counter that
    // ticks every time we surface a B-class tile at an arena). Without the
    // Redis half, every consecutive Discover sees the same load picture
    // and the highest-rated arena keeps winning until a real lobby lands;
    // with it, fairness emerges across many users searching the same date.
    const baseLoad = await this.computeArenaLoadByDate(date)
    const dateKey = this.toDateOnly(date)
    const redisAllocs = await getDiscoverAllocations(
      Array.from(tentativeArenasById.keys()), dateKey,
    ).catch(() => new Map<string, number>())
    const arenaLoadByDate = new Map<string, number>()
    for (const aid of new Set([...baseLoad.keys(), ...redisAllocs.keys()])) {
      arenaLoadByDate.set(aid, (baseLoad.get(aid) ?? 0) + (redisAllocs.get(aid) ?? 0))
    }

    // ageGroup is still resolved per candidate so the response payload
    // (used by the client for an age-group label on the tile) stays
    // populated. The age-group FILTER is intentionally OFF for V2 Discover —
    // most casual cricket happens across age groups (a U19 team can play
    // a SENIOR team in a friendly) and the exact-match rule (the only
    // thing areAgeGroupsCompatible currently knows how to do) was
    // dropping legitimate matches. If/when teams want age-restricted
    // play it belongs on Team as an opt-in flag, not a hard filter here.
    const teamIds: string[] = candidates.flatMap((c) =>
      c.teamId ? [c.teamId] : [],
    )
    const ages = await this.getTeamAgeGroupsMap(teamIds)
    const scored = candidates
      .map((c) => {
        const s = this.scoreRankedCandidate({
          callerWindowsRanked: windowsRanked,
          callerGroundsRanked: groundsRanked,
          callerFormat: input.filters.format,
          callerBallType: input.filters.ballType ?? null,
          candidate: c,
        })
        return { lobby: c, ...s }
      })
      // intersects: there exists at least one (window, ground) pair that
      // both lobbies share. No intersection = not even an alternative.
      .filter((s) => s.intersects)

    // Two-class slate. Owner-posted candidates have a real arena + slot
    // pre-booked, so the matcher only needs to find ONE compatible team —
    // half the work is done. They always rank above player-posted in the
    // primary slate, regardless of the preference-overlap score. Within
    // each class, sort by score (highest first).
    const ownerPostedScored = scored
      .filter((s) => this.isOwnerPosted(s.lobby))
      .sort((a, b) => b.value - a.value)
    const playerPostedScored = scored
      .filter((s) => !this.isOwnerPosted(s.lobby))
      .sort((a, b) => b.value - a.value)

    // primary slate:
    //   1. every compatible owner-posted lobby (concrete venue+slot)
    //   2. player-posted lobbies that align both teams' rank-1 window AND
    //      rank-1 ground (the existing "isPrimary" criterion)
    // alternatives slate: remaining player-posted candidates.
    const primary = [
      ...ownerPostedScored,
      ...playerPostedScored.filter((s) => s.isPrimary),
    ]
    const primaryIds = new Set(primary.map((s) => s.lobby.id))
    const alternatives = playerPostedScored
      .filter((s) => !primaryIds.has(s.lobby.id))
      .slice(0, 20)

    // Per-pair venue allocator. For pure-preference candidates (no concrete
    // pick after live re-validation), pick the proposed arena from the
    // multi-arena pool by maximizing
    //   quality(rating) × loadFactor(active-lobbies) × diversity(per-response cap)
    // restricted to arenas that have a live bookable slot in the candidate's
    // first active window. Falls back to the smart-allocator's top arena
    // when no pool member has a slot in that window.
    const DIVERSITY_CAP = 3
    const tentativeAllocCounter = new Map<string, number>()
    const ratingMultiplier = (avg: number | null | undefined): number => {
      const v = typeof avg === 'number' ? avg : 3.0
      // Tight linear map: 1.0 → 0.85, 3.0 → 1.025, 5.0 → 1.20.
      // The original [0.5, 1.5] swing meant a 4.7★ arena dominated cold-
      // start by 42.5% before any load could push it down — at load=0 (77%
      // of (arena, date) pairs in our test fixture), quality alone won.
      // The narrower [0.85, 1.20] band caps quality's advantage at ~14%, so
      // a single active lobby on the top arena lets a comparable lower-
      // rated venue take the next allocation. Low-rated arenas still get
      // priced into the score; they just can't be priced *out* of the
      // marketplace at zero load.
      return 0.85 + (Math.max(1, Math.min(5, v)) - 1) * 0.0875
    }
    const loadFactor = (arenaId: string): number => {
      const load = arenaLoadByDate.get(arenaId) ?? 0
      // Steeper decay (denominator 1.5 instead of 3) so a single owner-posted
      // lobby on an arena drops its draw to ~0.6×, not 0.75×. In sparse
      // markets a 4.7★ arena would otherwise dominate indefinitely because
      // no other quality signal can push it down.
      return 1 / (1 + load / 1.5)
    }
    const diversityFactor = (arenaId: string): number => {
      const used = tentativeAllocCounter.get(arenaId) ?? 0
      return used >= DIVERSITY_CAP ? 0.3 : 1.0
    }
    const pickProposedTentative = (
      cGrounds: string[],
      window: string | undefined,
    ): { arena: TentativeArena; slot: TentativeSlot } | null => {
      if (!window || tentativeArenasById.size === 0) return null
      // Pool: caller prefs ∪ candidate prefs ∪ entire smart-allocated pool.
      const poolIds = new Set<string>([
        ...((groundsRanked ?? []) as string[]),
        ...cGrounds,
        ...tentativeArenasById.keys(),
      ])
      const eligible: Array<{ arena: TentativeArena; slot: TentativeSlot; score: number }> = []
      for (const aid of poolIds) {
        const a = tentativeArenasById.get(aid)
        if (!a) continue
        const slot = a.slots.find((sl) => sl.buckets.includes(window as TimeWindow))
        if (!slot) continue
        const score =
          ratingMultiplier(a.matchRatingAvg) *
          loadFactor(a.id) *
          diversityFactor(a.id)
        eligible.push({ arena: a, slot, score })
      }
      if (eligible.length === 0) {
        // Last-resort fallback: any pool arena with any slot, ignoring window.
        if (tentativeArena) {
          const fallbackSlot = tentativeArena.slots[0]
          if (fallbackSlot) {
            tentativeAllocCounter.set(
              tentativeArena.id,
              (tentativeAllocCounter.get(tentativeArena.id) ?? 0) + 1,
            )
            return { arena: tentativeArena, slot: fallbackSlot }
          }
        }
        return null
      }
      eligible.sort((a, b) => b.score - a.score)
      const winner = eligible[0]
      tentativeAllocCounter.set(
        winner.arena.id,
        (tentativeAllocCounter.get(winner.arena.id) ?? 0) + 1,
      )
      // Cross-response signal: bump the Redis counter (5-min TTL) so the
      // next searcher on this date sees this arena as warmer load and
      // routes elsewhere. Fire-and-forget — a Redis miss should never
      // block discover from returning.
      bumpDiscoverAllocation(winner.arena.id, dateKey).catch(() => undefined)
      return { arena: winner.arena, slot: winner.slot }
    }

    const formatRanked = (s: {
      lobby: any
      value: number
      matchedOn: string[]
      differs: string[]
    }) => {
      const c = s.lobby
      const rawPick = c.picks[0]
      // Re-validate the candidate's concrete pick against the live grid.
      // If the unit's current config has shifted the pick off-grid, treat
      // the candidate as pure-preference so the tentative-slot path picks
      // a real bookable time instead of advertising a dead slot.
      const pickIsLive = rawPick
        ? (liveSlotsByPickUnit.get(rawPick.groundId)?.has(rawPick.slotTime) ?? false)
        : false
      const pick = pickIsLive ? rawPick : null
      const unit = pick ? unitsById.get(pick.groundId) : null
      const arena = c.arenaId ? arenasById.get(c.arenaId) : null
      const cGroundsRanked = (c.preferredArenaIds ?? []) as string[]
      const rank1Arena = cGroundsRanked[0]
        ? arenasById.get(cGroundsRanked[0])
        : null
      const cWindowsRanked = (c.windowsRanked ?? []) as string[]
      const cWindowsMatched = (c.windowsMatched ?? []) as string[]
      // Concrete arena, in priority order: explicit arenaId → unit's arena
      // → caller's groundsRanked rank-1 → candidate's groundsRanked rank-1.
      const concreteArena = arena ?? (unit as any)?.arena ?? rank1Arena ?? null
      // Per-pair tentative allocation for pure-preference candidates.
      // Spreads load across arenas via the load × quality × diversity score;
      // a pile-up on one popular arena drops its score for subsequent
      // candidates and rotates them to comparable underused venues.
      const w0 = cWindowsRanked.find((w) => !cWindowsMatched.includes(w))
      const proposedTentative = (!pick?.slotTime && !concreteArena)
        ? pickProposedTentative(cGroundsRanked, w0)
        : null
      const isTentative = !concreteArena && proposedTentative !== null
      const proposedArena = proposedTentative?.arena ?? null
      const arenaName = (concreteArena as any)?.name
        ?? (isTentative ? proposedArena!.name : null)
      // L3 — rating surfacing. Falls back to the per-pair tentative's
      // rating when the pairing has no concrete ground yet, so the UI
      // can still show a "★ 4.6 · 23" badge for the would-be venue.
      const matchRatingAvg = (concreteArena as any)?.matchRatingAvg
        ?? (isTentative ? proposedArena!.matchRatingAvg : null)
      const matchRatingCount = (concreteArena as any)?.matchRatingCount
        ?? (isTentative ? proposedArena!.matchRatingCount : null)
      const tentativeSlot: TentativeSlot | null = proposedTentative?.slot ?? null

      const fmtClock = (slotTime: string) => {
        const parts = slotTime.split(':')
        const h = parseInt(parts[0], 10)
        const m = parseInt(parts[1], 10)
        if (!Number.isFinite(h) || !Number.isFinite(m)) return slotTime
        const ampm = h < 12 ? 'AM' : 'PM'
        const h12 = h === 0 ? 12 : h > 12 ? h - 12 : h
        return `${h12}:${m.toString().padStart(2, '0')} ${ampm}`
      }

      // Effective slot times for response. Prefer concrete pick → tentative
      // slot from the API → bucket label as last fallback.
      const effectiveSlotTime: string | null = pick?.slotTime ?? tentativeSlot?.startTime ?? null
      const effectiveEndTime: string | null = tentativeSlot?.endTime ?? null

      const slotLabel = (() => {
        if (pick?.slotTime) {
          const dur = this.formatDurationMins(c.format as MatchmakingFormat)
          const parts = pick.slotTime.split(':')
          const h = parseInt(parts[0], 10)
          const m = parseInt(parts[1], 10)
          if (Number.isFinite(h) && Number.isFinite(m)) {
            const startMin = h * 60 + m
            const endMin = startMin + dur
            const fmtMin = (mins: number) => {
              const hh = Math.floor(mins / 60) % 24
              const mm = mins % 60
              const ampm = hh < 12 ? 'AM' : 'PM'
              const h12 = hh === 0 ? 12 : hh > 12 ? hh - 12 : hh
              return `${h12}:${mm.toString().padStart(2, '0')} ${ampm}`
            }
            const bucket = bucketForSlotTime(pick.slotTime)
            return bucket
              ? `${bucket} · ${fmtMin(startMin)} – ${fmtMin(endMin)}`
              : `${fmtMin(startMin)} – ${fmtMin(endMin)}`
          }
        }
        if (tentativeSlot) {
          // Display the bucket the player asked for when the slot covers
          // it (afternoon-search → "AFTERNOON · 10:00 AM – 2:00 PM" even
          // though the slot started in the morning), otherwise fall to
          // the slot's first bucket.
          const labelBucket = (w0 && tentativeSlot.buckets.includes(w0 as TimeWindow))
            ? w0
            : tentativeSlot.buckets[0] ?? null
          return labelBucket
            ? `${labelBucket} · ${fmtClock(tentativeSlot.startTime)} – ${fmtClock(tentativeSlot.endTime)}`
            : `${fmtClock(tentativeSlot.startTime)} – ${fmtClock(tentativeSlot.endTime)}`
        }
        if (w0) return `${w0} window`
        return null
      })()

      return {
        // Unified wire-contract Lobby JSON.
        lobby: {
          lobbyId: c.id,
          teamId: c.teamId ?? null,
          format: c.format,
          ballType: c.ballType ?? null,
          date: this.toDateOnly(c.date),
          windowsRanked: cWindowsRanked,
          windowsMatched: cWindowsMatched,
          groundsRanked: cGroundsRanked,
          status: c.status,
          // Helpful denormalised fields for the client.
          teamName: c.team?.name ?? (arena ? arena.name : 'TBD'),
          isArenaLobby: c.arenaId != null,
          arenaName,
          ageGroup: c.teamId ? ages.get(c.teamId) ?? null : null,
          groundName: unit?.name ?? null,
          unitId: pick?.groundId ?? null,
          // Pricing precedence:
          //   1. concrete unit (player picked + arena listing) → from unit.pricePerHourPaise
          //   2. tentative arena's actual slot (real /arenas/:id/slots data) → from slot.totalAmountPaise
          //   3. tentative arena cheapest-unit fallback (no slot in active window)
          //   4. 90000 fallback (no arenas usable)
          pricePerTeam: unit
            ? Math.round(
                (unit.pricePerHourPaise *
                  this.formatDurationMins(c.format as MatchmakingFormat)) /
                  60 /
                  2,
              )
            : tentativeSlot
              ? tentativeSlot.pricePerTeamPaise
              : isTentative
                ? Math.round(
                    (proposedArena!.pricePerHourPaise *
                      this.formatDurationMins(c.format as MatchmakingFormat)) /
                      60 /
                      2,
                  )
                : 90000,
          // Tile UI prefixes the price with "≈" only when there's no
          // real slot anchoring it. A tentative-but-slotted candidate
          // reads as 'concrete' to the player — they'll book that exact
          // slot. Only window-only fallbacks remain 'tentative'.
          pricingMode: unit
              ? 'concrete'
              : tentativeSlot
                ? 'concrete'
                : isTentative
                  ? 'tentative'
                  : 'unknown',
          slotTime: effectiveSlotTime,
          slotEndTime: effectiveEndTime,
          slotLabel,
          daysFromNow: this.daysFromNow(c.date),
          preferredArenaName: rank1Arena?.name ?? null,
          matchRatingAvg,
          matchRatingCount,
        },
        score: s.value,
        matchedOn: s.matchedOn,
        differs: s.differs,
      }
    }

    return {
      yourLobbyId: yourLobby.id,
      primary: primary.map(formatRanked),
      alternatives: alternatives.map(formatRanked),
    }
  }

  // Discover-flow expiry: lobby dies when the latest selected window passes.
  // No windows → fall back to legacy 24h.
  private computeDiscoverExpiry(
    date: Date,
    timeWindows: Array<TimeWindow>,
  ): Date {
    if (timeWindows.length === 0) {
      return new Date(Date.now() + LOBBY_EXPIRY_HOURS * 60 * 60 * 1000)
    }
    const latestEndMin = Math.max(
      ...timeWindows.map((w) => this.timeWindowEndMin(w)),
    )
    const offsetMs = latestEndMin * 60 * 1000 - (5 * 60 + 30) * 60 * 1000
    return new Date(date.getTime() + offsetMs)
  }

  // V2 ranked-pair scoring. For windows + grounds independently, compute the
  // best (myRank, theirRank) pair where both lists contain the same value.
  // Combine + tag matchedOn / differs / isPrimary / intersects.
  //
  // Lower rank index = stronger preference (rank 0 is rank-1 in spec parlance).
  // Score components:
  //   • windowScore — 1.0 when both rank-0 align, decays with rank index.
  //   • groundScore — 1.0 when both rank-0 align; 0.7 when no candidate ground
  //     pref (any nearby), decays with rank index when both have prefs.
  //   • formatScore + ballScore — same logic as legacy scorer.
  private scoreRankedCandidate(p: {
    callerWindowsRanked: string[]
    callerGroundsRanked: string[]
    callerFormat: string
    callerBallType: string | null
    candidate: any
  }): {
    value: number
    matchedOn: string[]
    differs: string[]
    isPrimary: boolean
    intersects: boolean
  } {
    const matchedOn: string[] = []
    const differs: string[] = []

    // Unified read: windowsRanked is the source of truth. For legacy/in-flight
    // rows where it might be empty, fall back to bucket(picks[0]).
    const picks = (p.candidate.picks ?? []) as Array<{ slotTime?: string; groundId?: string }>
    let candWindows: string[] = ((p.candidate.windowsRanked ?? []) as string[]).filter(Boolean)
    if (candWindows.length === 0 && picks.length > 0 && picks[0].slotTime) {
      const b = bucketForSlotTime(picks[0].slotTime)
      if (b) candWindows = [b]
    }
    const candWindowsMatched: string[] = (p.candidate.windowsMatched ?? []) as string[]
    const candWindowsActive = candWindows.filter((w) => !candWindowsMatched.includes(w))
    // Unified read: preferredArenaIds is the source of truth. Fallback to the
    // arenaId of picks[0] for legacy/in-flight rows.
    let candGrounds: string[] = ((p.candidate.preferredArenaIds ?? []) as string[]).filter(Boolean)
    if (candGrounds.length === 0 && picks.length > 0) {
      // Picks include `groundId` (an ArenaUnit id) — caller-side lookup may
      // have resolved a parent arenaId on the pick row. Trust the closest
      // signal we have without an extra DB call.
      const fromPick = (picks[0] as any).arenaId as string | undefined
      if (fromPick) candGrounds = [fromPick]
    }

    // Best (myRank, theirRank) for windows.
    let bestWindow: { myRank: number; theirRank: number } | null = null
    p.callerWindowsRanked.forEach((w, myRank) => {
      const theirRank = candWindowsActive.indexOf(w)
      if (theirRank < 0) return
      if (
        bestWindow === null ||
        myRank + theirRank < bestWindow.myRank + bestWindow.theirRank
      ) {
        bestWindow = { myRank, theirRank }
      }
    })

    // Best (myRank, theirRank) for grounds. Empty groundsRanked on either
    // side = "any nearby" — treated as a soft match (rank-1 by convention).
    let bestGround: { myRank: number; theirRank: number; soft: boolean } | null = null
    if (p.callerGroundsRanked.length === 0 && candGrounds.length === 0) {
      bestGround = { myRank: 0, theirRank: 0, soft: true }
    } else if (p.callerGroundsRanked.length === 0) {
      bestGround = { myRank: 0, theirRank: 0, soft: true }
    } else if (candGrounds.length === 0) {
      bestGround = { myRank: 0, theirRank: 0, soft: true }
    } else {
      p.callerGroundsRanked.forEach((g, myRank) => {
        const theirRank = candGrounds.indexOf(g)
        if (theirRank < 0) return
        if (
          bestGround === null ||
          myRank + theirRank < bestGround.myRank + bestGround.theirRank
        ) {
          bestGround = { myRank, theirRank, soft: false }
        }
      })
    }

    const intersects = bestWindow !== null && bestGround !== null
    if (!intersects) {
      // Non-intersecting candidates are filtered out upstream; we only
      // emit diagnostic tags here for completeness.
      if (bestWindow === null) differs.push('window_other')
      if (bestGround === null) differs.push('ground_other')
    } else {
      matchedOn.push('window')
      matchedOn.push('ground')
    }

    // Format match
    let formatScore = 0
    if (p.callerFormat === 'ANY' || p.candidate.format === 'ANY') {
      formatScore = 0.85
      matchedOn.push('format')
    } else if (p.callerFormat === p.candidate.format) {
      formatScore = 1.0
      matchedOn.push('format')
    } else {
      formatScore = 0.0
      differs.push('format')
    }

    // Ball compat — null on either side = compatible.
    let ballScore = 0
    if (
      p.callerBallType == null ||
      p.candidate.ballType == null ||
      p.callerBallType === p.candidate.ballType
    ) {
      ballScore = 1.0
      matchedOn.push('ball')
    } else {
      ballScore = 0.5
      differs.push('ball')
    }

    // Decay by combined rank distance. rank-0 + rank-0 = score 1.0; each
    // unit of distance trims 0.15 to a floor of 0.4.
    const rankDecay = (myRank: number, theirRank: number) =>
      Math.max(0.4, 1.0 - 0.15 * (myRank + theirRank))
    const windowScore = bestWindow
      ? rankDecay((bestWindow as { myRank: number; theirRank: number }).myRank, (bestWindow as { myRank: number; theirRank: number }).theirRank)
      : 0
    const groundScore = bestGround
      ? ((bestGround as { myRank: number; theirRank: number; soft: boolean }).soft
          ? 0.7
          : rankDecay((bestGround as { myRank: number; theirRank: number; soft: boolean }).myRank, (bestGround as { myRank: number; theirRank: number; soft: boolean }).theirRank))
      : 0

    // Recency boost (weight 5)
    const ageHours = (Date.now() - p.candidate.createdAt.getTime()) / 3600000
    const recencyScore = ageHours < 1 ? 1.0 : ageHours < 6 ? 0.9 : ageHours < 24 ? 0.7 : 0.5

    const total = windowScore * 30 + groundScore * 20 + formatScore * 15 + ballScore * 10 + recencyScore * 5
    const weight = 30 + 20 + 15 + 10 + 5
    const value = weight > 0 ? total / weight : 0

    // primary classification:
    //   • windowsPrimary = both sides' rank-0 mutually present in the other's list.
    //   • groundsPrimary = same rule, OR either side has empty groundsRanked
    //     ("any nearby" — the system will allocate, so it counts as primary).
    // When intersects but NOT primary, tag the deviation in differs[] so the
    // UI can render "different ground" / "different time horizon" precisely.
    const callerW0 = p.callerWindowsRanked[0]
    const candW0 = candWindowsActive[0]
    // Any window overlap = primary. Rank distinctions still drive the
    // score (rank-0 + rank-0 outscores rank-1 + rank-0 → ordering is
    // preserved) but they don't downgrade a candidate into the
    // "alternative" stripe lane or fire a caveat. The player explicitly
    // opted into MORNING and AFTERNOON; matching on either is honest.
    const windowsPrimary = bestWindow !== null
    // Caveat fires only on truly out-of-list windows — and the upstream
    // intersects-filter already drops those, so this is mostly belt &
    // braces.
    if (!intersects && bestWindow === null) {
      // unreachable in current code path (filtered earlier), kept for
      // future callers that surface non-intersecting candidates.
    }

    const callerG0 = p.callerGroundsRanked[0]
    const candG0 = candGrounds[0]
    const groundsPrimary =
      // "Any nearby" on either side is a soft-primary — the player who
      // chose no ground preference is happy with whatever the candidate
      // offers (or the system allocates).
      p.callerGroundsRanked.length === 0 || candGrounds.length === 0
        ? true
        : !!callerG0 && !!candG0 &&
          candGrounds.includes(callerG0) &&
          p.callerGroundsRanked.includes(candG0)
    if (intersects && !groundsPrimary && bestGround) {
      const bg = bestGround as { myRank: number; theirRank: number; soft: boolean }
      if (!bg.soft) {
        if (bg.myRank === 1) differs.push('ground_rank_2')
        else if (bg.myRank === 2) differs.push('ground_rank_3')
        else differs.push('ground_other')
      }
    }
    const isPrimary = windowsPrimary && groundsPrimary && intersects

    return {
      value,
      matchedOn: [...new Set(matchedOn)],
      differs: [...new Set(differs)],
      isPrimary,
      intersects,
    }
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
    // Discover-flow filters:
    timeWindow?: TimeWindow
    preferredArenaId?: string
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
        // Format filter: 'ANY' or unset → no filter (return all). Specific
        // format → also include lobbies tagged 'ANY' (open to any format).
        ...(input.format && input.format !== 'ANY'
          ? { format: { in: [input.format, 'ANY'] } }
          : {}),
      },
      include: {
        team: true,
        // Pull all picks so we can check if any pick falls inside the
        // requested time-window when bridging legacy slot-precise lobbies.
        picks: { orderBy: { preferenceOrder: 'asc' } },
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

    // Fetch arena names for owner-created and preference-arena lobbies
    const arenaIds = [
      ...new Set(
        lobbiesAny.flatMap((l) => [
          ...(typeof l.arenaId === 'string' ? [l.arenaId] : []),
          ...(((l.preferredArenaIds ?? []) as string[]).filter(Boolean)),
        ]),
      ),
    ]
    const arenas = arenaIds.length
      ? await prisma.arena.findMany({ where: { id: { in: arenaIds } }, select: { id: true, name: true } })
      : []
    const arenasById = new Map(arenas.map((a) => [a.id, a]))

    const out = lobbiesAny
      .filter((l) => {
        const pick = l.picks[0]
        if (this.isSlotPast(l.date, pick?.slotTime ?? null)) return false

        // ── Unified discover filters ─────────────────────────────────────
        // windowsRanked is always populated; match if the request's window
        // is one of the lobby's ranked windows OR any pick falls inside it.
        if (input.timeWindow) {
          const lobbyWindows: string[] = ((l as any).windowsRanked ?? []) as string[]
          const winMatches = lobbyWindows.includes(input.timeWindow)
          const pickInWindow = (l.picks as any[]).some(
            (p) => this.slotTimeWindow(p.slotTime) === input.timeWindow,
          )
          if (!winMatches && !pickInWindow) return false
        }
        // preferredArenaIds is the lobby's groundsRanked. Match when:
        //   (a) the lobby has no ground preference (any nearby), OR
        //   (b) the requested arena is in the lobby's ranked grounds, OR
        //   (c) any pick is hosted at that arena
        if (input.preferredArenaId) {
          const ranked: string[] = ((l as any).preferredArenaIds ?? []) as string[]
          const open = ranked.length === 0
          const inRanked = ranked.includes(input.preferredArenaId)
          const pickAtArena = (l.picks as any[]).some((p) => {
            const u = unitsById.get(p.groundId) as any
            return u?.arena?.id === input.preferredArenaId
          })
          if (!open && !inRanked && !pickAtArena) return false
        }

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
        // groundsRanked rank-1 → human-readable arena name for the result list.
        const ranked: string[] = ((l as any).preferredArenaIds ?? []) as string[]
        const rank1Arena = ranked[0] ? arenasById.get(ranked[0]) : null
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
          // Unified preference fields:
          windowsRanked: ((l as any).windowsRanked ?? []) as string[],
          windowsMatched: ((l as any).windowsMatched ?? []) as string[],
          groundsRanked: ranked,
          preferredArenaName: rank1Arena?.name ?? null,
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
      const joinFee = await this.resolveFeeBreakdown(unit.arenaId, groundFeePaise, tx)
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

      const joinerDerived = await this.deriveLobbyRankedFields({
        picks: [{ groundId: pick.groundId, slotTime: pick.slotTime }],
        tx,
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
          windowsRanked: joinerDerived.windowsRanked,
          windowsMatched: [],
          preferredArenaIds: joinerDerived.groundsRanked,
          picks: {
            create: [{ groundId: pick.groundId, slotTime: pick.slotTime, preferenceOrder: 1 }],
          },
        } as any,
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
          platformFeePaise: joinFee.platformFeePaise,
          arenaPayoutPaise: joinFee.arenaPayoutPaise,
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

  async acceptLobbyAsOwner(userId: string, lobbyId: string, arenaId: string, slotTime?: string, unitId?: string) {
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

    // Resolve target unit + slot. Prefer explicit client-supplied values
    // (live-availability UI); fall back to stored picks for back-compat.
    let targetUnitId = unitId
    let targetSlotTime = slotTime
    if (!targetUnitId || !targetSlotTime) {
      const fallbackPick = targetSlotTime
        ? lobby.picks.find((p: any) => p.slotTime === targetSlotTime) ?? lobby.picks[0]
        : lobby.picks[0]
      if (!fallbackPick) throw new AppError('NO_PICKS', 'Specify unitId and slotTime', 400)
      targetUnitId = targetUnitId ?? fallbackPick.groundId
      targetSlotTime = targetSlotTime ?? fallbackPick.slotTime
    }

    const unit = await prisma.arenaUnit.findUnique({ where: { id: targetUnitId! } })
    if (!unit || unit.arenaId !== arenaId) throw new AppError('GROUND_MISMATCH', 'Unit does not belong to this arena', 400)

    const durationMins = this.formatDurationMins(lobby.format as MatchmakingFormat)

    // Validate the chosen slot against the live availability grid — picks
    // captured under an older unit config (different turnaround/hours) may
    // be off-grid now; trust the live grid, not stored slotTime.
    const dateApi = this.toDateOnly(lobby.date)
    const liveSlots = await new ArenaService().getPlayerSlots(arenaId, dateApi, durationMins)
    const unitGroup = (liveSlots.unitGroups as any[]).find((g) => g.unitId === unit.id)
    const isOnGrid = (unitGroup?.availableSlots ?? []).some((s: any) => s.startTime === targetSlotTime)
    if (!isOnGrid) {
      throw new AppError(
        'SLOT_UNAVAILABLE',
        'This slot is no longer available under the unit\'s current configuration. Pick another time.',
        409,
      )
    }

    const date = lobby.date
    const endMins = this.timeToMinutes(targetSlotTime!) + durationMins
    const endTime = this.minutesToTime(endMins)
    const totalAmountPaise = Math.round(unit.pricePerHourPaise * durationMins / 60)

    const booking = await prisma.slotBooking.create({
      data: {
        arenaId,
        unitId: unit.id,
        bookedById: lobby.playerId,
        date,
        startTime: targetSlotTime!,
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
    const ownerFee = await this.resolveFeeBreakdown(unit.arenaId, groundFeePaise)
    const expiresAt = new Date(Date.now() + LOBBY_EXPIRY_HOURS * 60 * 60 * 1000)

    const result = await prisma.$transaction(async (tx) => {
      // Clean stale matches on the existing lobby
      await tx.matchmakingMatch.deleteMany({
        where: {
          status: { in: ['cancelled', 'expired'] },
          OR: [{ lobbyAId: lobby.id }, { lobbyBId: lobby.id }],
        },
      })

      // Create a proxy lobby for the assigned team. Derive the unified
      // ranked arrays from the pick so the new lobby satisfies the contract.
      const proxyDerived = await this.deriveLobbyRankedFields({
        picks: [{ groundId: pick.groundId, slotTime: pick.slotTime }],
        tx,
      })
      const proxyLobby = await tx.matchmakingLobby.create({
        data: {
          teamId: input.teamId,
          playerId: captainPlayerId,
          format: lobby.format,
          ballType: (lobby as any).ballType ?? null,
          date: lobby.date,
          status: 'searching',
          expiresAt,
          windowsRanked: proxyDerived.windowsRanked,
          windowsMatched: [],
          preferredArenaIds: proxyDerived.groundsRanked,
          picks: {
            create: [{ groundId: pick.groundId, slotTime: pick.slotTime, preferenceOrder: 1 }],
          },
        } as any,
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
          platformFeePaise: ownerFee.platformFeePaise,
          arenaPayoutPaise: ownerFee.arenaPayoutPaise,
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
      // Cashfree order, no money has been captured unless the player
      // completed the Cashfree flow. If a verify-payment lands after this
      // cancel, it'll see lobby.status='cancelled' and refuse to create the
      // match — Cashfree refund is then handled by the webhook.
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
            await cashfree.makeRequest('POST', `/pg/orders/${encodeURIComponent(payment.id)}/refunds`, {
              refund_amount: payment.amountPaise / 100,
              refund_id: `refund_${payment.id}_${Date.now()}`,
              refund_note: 'Match expired — opponent did not pay in time',
            }).catch((err) => console.error('[Cashfree] refund failed (non-fatal):', err))
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
        cashfreeOrderId: null,
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

    const cfOrder = await cashfree.createOrder({
      orderId: `mm_req_${request.id.slice(0, 20)}_${Date.now()}`,
      amountPaise,
      customerId: userId,
      customerPhone: (initiatorProfile?.user?.name ? '9000000000' : '9000000000'),
      customerName: initiatorProfile?.user?.name || 'Player',
      notifyUrl: MM_NOTIFY_URL,
    })

    return {
      matchId: match.id,
      status: 'BOTH_CONFIRMED',
      cashfreeOrderId: cfOrder.order_id,
      sessionId: cfOrder.payment_session_id,
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

  // Slot resolution for player-vs-player Discover lobbies that have no
  // explicit picks. Returns a (groundId, slotTime) chosen from the lobby's
  // preferredArenaIds (or any active arena if none preferred). The slot
  // starts at the lobby's first un-matched ranked window's bucket-start
  // (e.g. 06:30 for MORNING) — concrete enough that lockAndPay /
  // verifyInterestPayment can finalise a SlotBooking without crashing with
  // NO_PICKS.
  //
  // Returns null when no active arena unit can be found. Caller throws
  // NO_AVAILABLE_SLOT in that case.
  //
  // Allocation precedence (the user-pref-wins rule):
  //   1. groundsRanked / preferredArenaIds set on the lobby (player chose) →
  //      use that ranked list as-is. System never overrides.
  //   2. Empty groundsRanked ("any nearby") → smart allocation by
  //      utilizationGap + recency + proximity (see smartAnyGroundAllocation).
  //      The flywheel: quieter and closer arenas get first shot at no-pref
  //      matches, building load balance from day one.
  private async resolveSlotForPicklessLobby(
    lobby: {
      teamId?: string | null
      preferredArenaIds: string[]
      windowsRanked?: string[] | null
      windowsMatched?: string[] | null
      groundsRanked?: string[] | null
    },
    tx?: any,
  ): Promise<{ groundId: string; slotTime: string; window: TimeWindow } | null> {
    const client = tx ?? prisma
    const groundsRanked = (lobby.groundsRanked && lobby.groundsRanked.length > 0)
      ? lobby.groundsRanked
      : (lobby.preferredArenaIds ?? [])

    // 1. Pick the candidate arenas: groundsRanked (player pref) wins if set,
    //    otherwise fall through to smart allocation.
    let candidateArenaIds: string[] = [...groundsRanked]
    if (candidateArenaIds.length === 0) {
      candidateArenaIds = await this.smartAnyGroundAllocation(
        lobby.teamId ?? null,
        client,
      )
    }
    if (candidateArenaIds.length === 0) return null

    // 2. Pick the first available unit at the rank-1 ground (groundsRanked[0])
    //    if possible; falls back to cheapest within the candidate pool.
    let unit = await client.arenaUnit.findFirst({
      where: { arenaId: candidateArenaIds[0] },
      orderBy: { pricePerHourPaise: 'asc' },
      select: { id: true },
    })
    if (!unit) {
      unit = await client.arenaUnit.findFirst({
        where: { arenaId: { in: candidateArenaIds } },
        orderBy: { pricePerHourPaise: 'asc' },
        select: { id: true },
      })
    }
    if (!unit) return null

    // 3. Window choice = first member of windowsRanked NOT in windowsMatched.
    //    Falls back to MORNING as a last resort.
    const windowsRanked = (lobby.windowsRanked ?? []) as string[]
    const windowsMatched = (lobby.windowsMatched ?? []) as string[]
    const nextActive = windowsRanked.find((w) => !windowsMatched.includes(w))
    const w: TimeWindow =
      (nextActive as TimeWindow | undefined) ?? 'MORNING'
    const startMin =
      WINDOW_RANGES[w]?.startMin ?? WINDOW_RANGES.MORNING.startMin
    const hh = Math.floor(startMin / 60)
    const mm = startMin % 60
    const slotTime = `${String(hh).padStart(2, '0')}:${String(mm).padStart(2, '0')}`

    return { groundId: unit.id, slotTime, window: w }
  }

  // L1b/L3 — smart "any-ground" allocation. Fires only when the player did
  // NOT pin specific grounds. Returns a ranked list of candidate arenaIds,
  // top first. Caller picks rank-1, falls through to next on no-unit failure.
  //
  // L3 score = 0.3 * utilizationGap + 0.4 * ratingScore + 0.2 * proximity + 0.1 * recency
  //   utilizationGap : 1 - (bookings_28d / max). Quiet arenas win.
  //   ratingScore    : (matchRatingAvg - 1.0) / 4.0  →  1★=0.0, 5★=1.0.
  //                    Neutral 0.5 when matchRatingCount < 5 (gather data
  //                    on new arenas; the user's "5-match threshold").
  //   proximity      : 1/(km+1) from team's home arena. Neutral 0.5 when
  //                    location unknown.
  //   recency        : days_since_last_booking / 30, capped. Stale arenas win.
  //
  // Soft-ban: arenas with matchRatingCount >= 5 AND matchRatingAvg < 2.5
  // are excluded entirely from the any-ground pool. They still appear when
  // a player explicitly picks them (player pref always wins).
  private async smartAnyGroundAllocation(
    teamId: string | null,
    client: any,
  ): Promise<string[]> {
    const arenas = await client.arena.findMany({
      where: { isActive: true, units: { some: { isActive: true } } },
      select: {
        id: true,
        latitude: true,
        longitude: true,
        matchRatingAvg: true,
        matchRatingCount: true,
      },
    })
    if (arenas.length === 0) return []

    const since = new Date(Date.now() - 28 * 24 * 60 * 60 * 1000)
    const arenaIds = arenas.map((a: { id: string }) => a.id)
    // Use SlotBooking — the matchmaking match → slotBooking → arenaId chain
    // is the canonical source of "which arena hosted what". Match.venueId
    // points to a separate generic Venue table that matchmaking doesn't
    // populate.
    const counts: Array<{
      arenaId: string
      _count: { _all: number }
      _max: { date: Date | null }
    }> = await client.slotBooking.groupBy({
      by: ['arenaId'],
      where: {
        arenaId: { in: arenaIds },
        date: { gte: since },
        status: { in: ['CONFIRMED', 'CHECKED_IN', 'COMPLETED'] },
      },
      _count: { _all: true },
      _max: { date: true },
    })
    const stats = new Map<string, { count: number; lastAt: Date | null }>()
    for (const c of counts) {
      stats.set(c.arenaId, {
        count: c._count._all,
        lastAt: c._max.date,
      })
    }
    const maxCount = Math.max(
      1,
      ...Array.from(stats.values()).map((s) => s.count),
    )

    let homeLat: number | null = null
    let homeLng: number | null = null
    if (teamId) {
      const team = await client.team.findUnique({
        where: { id: teamId },
        select: { arenaId: true },
      })
      if (team?.arenaId) {
        const homeArena = await client.arena.findUnique({
          where: { id: team.arenaId },
          select: { latitude: true, longitude: true },
        })
        if (homeArena) {
          homeLat = homeArena.latitude
          homeLng = homeArena.longitude
        }
      }
    }

    const now = Date.now()
    type AnyArena = {
      id: string
      latitude: number
      longitude: number
      matchRatingAvg: number
      matchRatingCount: number
    }
    const scored = arenas
      .filter((a: AnyArena) => {
        // Soft-ban — exclude consistently low-rated arenas from the
        // no-pref pool. Player explicit picks bypass this entirely.
        return !(a.matchRatingCount >= 5 && a.matchRatingAvg < 2.5)
      })
      .map((a: AnyArena) => {
        const stat = stats.get(a.id) ?? { count: 0, lastAt: null }
        const utilizationGap = 1 - stat.count / maxCount
        const lastDays = stat.lastAt
          ? (now - stat.lastAt.getTime()) / (24 * 60 * 60 * 1000)
          : 30
        const recency = Math.min(1.0, lastDays / 30)
        let proximity = 0.5
        if (
          homeLat !== null &&
          homeLng !== null &&
          a.latitude != null &&
          a.longitude != null
        ) {
          const km = this.haversineKm(homeLat, homeLng, a.latitude, a.longitude)
          proximity = 1.0 / (km + 1.0)
        }
        // Rating component is neutral until the 5-match threshold is hit
        // (gives new arenas a fair shot to gather data).
        const ratingScore =
          a.matchRatingCount >= 5
            ? Math.max(0, Math.min(1, (a.matchRatingAvg - 1.0) / 4.0))
            : 0.5
        const score =
          0.3 * utilizationGap +
          0.4 * ratingScore +
          0.2 * proximity +
          0.1 * recency
        return { id: a.id, score }
      })
    scored.sort(
      (a: { score: number }, b: { score: number }) => b.score - a.score,
    )
    // Return top 5 — the resolver tries rank-1 first and falls back through
    // the rest if no unit is available at the top pick.
    return scored.slice(0, 5).map((s: { id: string }) => s.id)
  }

  // V2 lobby consumption: when a match is created, append the matched window
  // to each side's windowsMatched (idempotent), flip status to 'matched' if
  // every window in windowsRanked has been consumed, and auto-cancel sibling
  // lobbies whose remaining windows overlap the consumed slot.
  //
  // Auto-cancelled siblings use status 'auto_cancelled' (not 'cancelled') so
  // they don't ding reputation.
  private async consumeLobbyWindows(
    tx: any,
    args: {
      lobbyId: string
      window: string
      slotTime: string | null
      format: string
    },
  ): Promise<void> {
    const lobby = await tx.matchmakingLobby.findUnique({
      where: { id: args.lobbyId },
      select: {
        id: true,
        teamId: true,
        date: true,
        windowsRanked: true,
        windowsMatched: true,
        status: true,
      },
    })
    if (!lobby) return

    // windowsRanked is always populated post-unification. The fallback is
    // a defensive belt for any in-flight rows that slipped through.
    let ranked: string[] = (lobby.windowsRanked && lobby.windowsRanked.length > 0)
      ? [...lobby.windowsRanked]
      : []
    let matched: string[] = [...(lobby.windowsMatched ?? [])]
    if (ranked.length === 0) ranked = [args.window]
    // Idempotent append.
    if (!matched.includes(args.window)) matched = [...matched, args.window]

    // Status flips to 'matched' only when every ranked window has been
    // matched. Until then the lobby stays 'searching' and remains visible
    // in Discover for additional consumers.
    const allConsumed = ranked.every((w) => matched.includes(w))
    const nextStatus = allConsumed ? 'matched' : (lobby.status === 'searching' ? 'searching' : lobby.status)

    await tx.matchmakingLobby.update({
      where: { id: lobby.id },
      data: {
        windowsRanked: ranked,
        windowsMatched: matched,
        status: nextStatus,
      } as any,
    })

    // Auto-cancellation cascade for sibling lobbies of the same team. Cancel
    // *other* searching lobbies on the same date whose remaining windows
    // (windowsRanked − windowsMatched) overlap the consumed slot's interval.
    if (!lobby.teamId) return
    const slotTime = args.slotTime
    const formatStr = args.format
    const consumedRange = slotTime
      ? matchInterval(slotTime, formatStr)
      : (() => {
          const r = WINDOW_RANGES[args.window as TimeWindow]
          return r ? { startMin: r.startMin, endMin: r.endMin } : null
        })()
    if (!consumedRange) return

    const siblings = await tx.matchmakingLobby.findMany({
      where: {
        teamId: lobby.teamId,
        status: 'searching',
        date: lobby.date,
        id: { not: lobby.id },
      },
      select: {
        id: true,
        windowsRanked: true,
        windowsMatched: true,
      },
    })
    for (const sib of siblings) {
      const sibRanked: string[] = (sib.windowsRanked ?? []) as string[]
      const sibMatched: string[] = sib.windowsMatched ?? []
      const remaining = sibRanked.filter((w) => !sibMatched.includes(w))
      if (remaining.length === 0) continue
      // Sibling overlaps if any of its remaining windows shares an interval
      // with the consumed slot.
      const overlapsConsumed = remaining.some((w) => {
        const r = WINDOW_RANGES[w as TimeWindow]
        if (!r) return false
        return intervalsOverlap(
          consumedRange.startMin,
          consumedRange.endMin,
          r.startMin,
          r.endMin,
        )
      })
      if (!overlapsConsumed) continue
      await tx.matchmakingLobby.update({
        where: { id: sib.id },
        data: { status: 'auto_cancelled' },
      })
    }
  }

  // Smart-window scanner. For each of the 5 time buckets, count how many
  // active arenas have operating hours that overlap the bucket on the given
  // date. Player-side abstraction — arenas don't tag slots with buckets, we
  // derive overlap from openTime / closeTime.
  //
  // If arenaIds is non-empty, only those arenas are considered. Otherwise
  // all active arenas (used as a coarse "what's possible in your city" hint;
  // the arena set will be narrowed server-side by city in a future revision).
  async availableBuckets(
    _date: string,
    arenaIds: string[],
    format?: string,
  ) {
    // Query ArenaUnit (the actual playing surface) — it can have its own
    // openTime/closeTime that overrides the parent arena. A unit with a
    // 5 PM close can't host an EVENING (16:30–20:30) match even if the
    // parent arena says 10 PM close. Fall back to arena's hours when the
    // unit didn't override.
    const units = await prisma.arenaUnit.findMany({
      where: arenaIds.length > 0
        ? { arenaId: { in: arenaIds } }
        : { arena: { isActive: true } },
      select: {
        id: true,
        arenaId: true,
        openTime: true,
        closeTime: true,
        arena: { select: { openTime: true, closeTime: true, isActive: true } },
      },
      take: 200,
    })

    const parseMin = (t: string | null | undefined): number | null => {
      if (!t) return null
      const m = /^(\d{1,2}):(\d{2})$/.exec(t)
      if (!m) return null
      return Number(m[1]) * 60 + Number(m[2])
    }

    // Format-aware: a bucket is "available" iff there's at least one start
    // time within the bucket where a full match-duration slot fits inside
    // the unit's operating hours. Default to T20 (240 min) so a missing
    // format query param doesn't silently widen results.
    const durationMins = (() => {
      switch (format) {
        case 'ODI':
        case 'Test':
          return 480
        case 'T10':
        case 'T20':
        case 'Custom':
        case 'ANY':
        default:
          return 240
      }
    })()

    const buckets = TIME_WINDOWS.map((w) => {
      const r = WINDOW_RANGES[w]
      let arenaCount = 0
      for (const u of units) {
        if (!u.arena?.isActive) continue
        // Unit-level hours override the arena's when set.
        const open = parseMin(u.openTime ?? u.arena.openTime)
        const closeRaw = parseMin(u.closeTime ?? u.arena.closeTime)
        if (open === null || closeRaw === null) continue
        // Close < open → venue runs past midnight; extend close past 1440
        // so the math works without special-casing.
        const close = closeRaw <= open ? closeRaw + 24 * 60 : closeRaw
        // A viable start time t satisfies:
        //   t in [bucketStart, bucketEnd)  AND  t >= open  AND
        //   t + duration <= close
        // i.e. t in [max(open, bucketStart), min(bucketEnd, close - duration))
        const startMin = Math.max(open, r.startMin)
        const startMax = Math.min(r.endMin, close - durationMins)
        if (startMin < startMax) {
          arenaCount++
        }
      }
      return { window: w, arenaCount }
    })
    return { buckets }
  }

  // Resolves the commission rate that applies to a match-up at this arena.
  // Per-arena override (Arena.commissionRateBpsOverride) wins; otherwise
  // falls back to the platform-wide PlatformConfig 'mm_commission_rate_bps'.
  // Default 0 (test mode). Computes both sides of the ledger so every match
  // record has a complete payout snapshot — even when fee = 0 today.
  private async resolveFeeBreakdown(
    arenaId: string,
    groundFeePaise: number,
    tx?: any,
  ): Promise<{ platformFeePaise: number; arenaPayoutPaise: number; rateBps: number }> {
    const client = tx ?? prisma
    const [arena, cfg] = await Promise.all([
      client.arena.findUnique({
        where: { id: arenaId },
        select: { commissionRateBpsOverride: true },
      }),
      client.platformConfig.findUnique({
        where: { key: 'mm_commission_rate_bps' },
      }),
    ])
    const cfgVal = cfg?.value ?? '0'
    const platformDefault = Number.parseInt(cfgVal, 10)
    const rateBps =
      arena?.commissionRateBpsOverride ??
      (Number.isFinite(platformDefault) ? platformDefault : 0)
    const platformFeePaise = Math.floor((groundFeePaise * rateBps) / 10000)
    const arenaPayoutPaise = Math.max(0, groundFeePaise - platformFeePaise)
    return { platformFeePaise, arenaPayoutPaise, rateBps }
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

  // Owner-posted lobbies have both `arenaId` and `splitBookingId` populated
  // (the host pre-booked a real slot when listing the team). Player-posted
  // lobbies have both null. The concrete-vs-abstract split drives Discover
  // priority: owner-posted always ranks above player-posted.
  private isOwnerPosted(lobby: { arenaId: string | null; splitBookingId: string | null }): boolean {
    return !!lobby.arenaId && !!lobby.splitBookingId
  }

  // TeamType compatibility — strict same-category match against the
  // 5-value Prisma enum (SCHOOL, CLUB_ACADEMY, CORPORATE, GULLY,
  // ASSOCIATION). A nullish value on either side acts as a wildcard.
  private teamTypesCompatible(a: string | null | undefined, b: string | null | undefined): boolean {
    if (!a || !b) return true
    return a === b
  }

  // Age group compatibility. OPEN (or null/empty) on either side acts as a
  // wildcard; otherwise must match exactly. U13/U16/U19 sides only meet
  // their own age tier — protects youth cricket from senior pairings.
  private ageGroupsCompatible(a: string | null | undefined, b: string | null | undefined): boolean {
    if (!a || !b) return true
    if (a === 'OPEN' || b === 'OPEN') return true
    return a === b
  }

  // Gender compatibility. MIXED on either side meets anything (catch-all);
  // MALE only meets MALE, FEMALE only meets FEMALE. Mirrors the strict
  // same-tier philosophy of teamType — a men's side and a women's side
  // never get auto-paired.
  private gendersCompatible(a: string | null | undefined, b: string | null | undefined): boolean {
    if (!a || !b) return true
    if (a === 'MIXED' || b === 'MIXED') return true
    return a === b
  }

  // Demand signal for venue allocation: count of active searching lobbies
  // per arena on a given date. A `MatchmakingLobby.arenaId` set means it's
  // either owner-posted (split booking on that arena) or in mid-flight
  // (lock acquired). Both count as load — they reduce the room left for
  // new pairings to be steered onto that arena.
  private async computeArenaLoadByDate(date: Date): Promise<Map<string, number>> {
    const rows = await prisma.matchmakingLobby.groupBy({
      by: ['arenaId'],
      where: {
        date,
        status: 'searching',
        arenaId: { not: null },
      },
      _count: { _all: true },
    })
    const out = new Map<string, number>()
    for (const r of rows) {
      if (!r.arenaId) continue
      out.set(r.arenaId, (r as any)._count._all as number)
    }
    return out
  }

  // Hard-filter pair compatibility used to prune the Discover candidate pool
  // before scoring. Anything that fails this can never be a viable opponent
  // regardless of preference overlap.
  private teamsAreCompatible(
    caller: { teamType?: string | null; ageGroup?: string | null; gender?: string | null; credibilityScore?: number | null },
    candidate: { teamType?: string | null; ageGroup?: string | null; gender?: string | null; credibilityScore?: number | null },
  ): boolean {
    if (!this.teamTypesCompatible(caller.teamType, candidate.teamType)) return false
    if (!this.ageGroupsCompatible(caller.ageGroup, candidate.ageGroup)) return false
    if (!this.gendersCompatible(caller.gender, candidate.gender)) return false
    if ((caller.credibilityScore ?? 100) < 60) return false
    if ((candidate.credibilityScore ?? 100) < 60) return false
    return true
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

  // Date horizon enforcement: lobby's `date` (UTC start-of-day) must be in
  // [today, today+14d]. Throws DATE_OUT_OF_HORIZON 400 otherwise. Today is
  // computed in UTC since startOfDay uses Date.UTC for the input.
  private assertDateInHorizon(date: Date) {
    const now = new Date()
    const todayUTC = new Date(Date.UTC(
      now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate(),
    ))
    const horizonUTC = new Date(todayUTC.getTime() + 14 * 24 * 60 * 60 * 1000)
    if (date.getTime() < todayUTC.getTime() || date.getTime() > horizonUTC.getTime()) {
      throw new AppError(
        'DATE_OUT_OF_HORIZON',
        'Lobby date must be within the next 14 days',
        400,
      )
    }
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

  // ── Time-window helpers (Discover-flow preferences) ────────────────────────
  // Single source of truth for window ranges lives in time-windows.ts. The
  // wrappers here just glue those minute-level helpers into the date+UTC
  // expiry math that the lobby/sweeper code uses.
  //
  // 5-bucket model (IST-anchored):
  //   MORNING    06:30 – 11:30
  //   AFTERNOON  11:30 – 16:30
  //   EVENING    16:30 – 20:30
  //   NIGHT      20:30 – 23:30
  //   LATE_NIGHT 23:30 – next-day 04:00

  // End-of-window expressed as minutes-past-start-of-day in IST. LATE_NIGHT
  // is 28*60 = 1680 because it bleeds past midnight.
  private timeWindowEndMin(timeWindow: string): number {
    const w = timeWindow as TimeWindow
    return WINDOW_RANGES[w]?.endMin ?? WINDOW_RANGES.LATE_NIGHT.endMin
  }

  // Returns the UTC instant when a preference-lobby for `date` + `timeWindow`
  // should expire. Date is the lobby's startOfDay (UTC). IST is UTC+5:30 so
  // the window expressed in UTC is offset by -5:30.
  private timeWindowExpiry(date: Date, timeWindow: string): Date {
    const endMin = this.timeWindowEndMin(timeWindow)
    // ms since the UTC start-of-day of `date`, minus IST offset (5h30m).
    const offsetMs = endMin * 60 * 1000 - (5 * 60 + 30) * 60 * 1000
    return new Date(date.getTime() + offsetMs)
  }

  // Maps a slot start time ("HH:mm", IST) to the bucket that contains it.
  // Used when bridging legacy slot-precise lobbies into window-based filters.
  // Falls back to LATE_NIGHT for unparseable input (preserves prior behaviour
  // where late-night-ish slots ended up in the old EVENING bucket).
  private slotTimeWindow(slotTime: string): TimeWindow {
    return bucketForSlotTime(slotTime) ?? 'LATE_NIGHT'
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

    // Resolve every team the caller belongs to so we surface matches the team
    // is in even when the specific lobby was created by someone else (e.g.
    // an arena owner via the Biz app, or a different teammate). Filtering by
    // playerId would hide those.
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
    if (myTeams.length === 0) return { matches: [] }
    const myTeamIds = myTeams.map((t) => t.id)

    // Find all lobbies for any of the user's teams that are linked to a
    // match. Either the player- or the arena-created lobby will satisfy
    // this — the caller's matches surface from either side.
    const lobbies = await prisma.matchmakingLobby.findMany({
      where: { teamId: { in: myTeamIds }, matchId: { not: null } },
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
        include: { team: { select: { id: true, name: true, logoUrl: true } } },
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
        myTeamId: myLobby?.teamId ?? null,
        myTeamName: myLobby?.team?.name ?? 'Your Team',
        myTeamLogoUrl: (myLobby as any)?.team?.logoUrl ?? null,
        opponentTeamName: opponentLobby?.team?.name ?? 'Opponent',
        opponentTeamLogoUrl: (opponentLobby as any)?.team?.logoUrl ?? null,
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
        // Surfaced so the My Match-Up sheet can link out to the side-nav
        // booking page via /bookings/:id.
        bookingId: (m as any).bookingId ?? null,
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

  // Player-side confirmation when the match's per-team confirmation fee is
  // 0 (test mode). Mirrors the lock-and-pay zero-amount bypass so the
  // opponent's "Pay" button can finalize without going through Cashfree
  // (which can't process ₹0). Refuses if the match has a non-zero fee.
  async confirmMatchFree(userId: string, matchId: string, lobbyId: string) {
    const player = await this.getPlayerProfile(userId)

    const match = await prisma.matchmakingMatch.findUnique({ where: { id: matchId } })
    if (!match) throw Errors.notFound('Match')
    if (match.paymentAmountPerTeam > 0) {
      throw new AppError(
        'PAYMENT_REQUIRED',
        'This match has a non-zero confirmation fee — pay via Cashfree',
        400,
      )
    }
    if (lobbyId !== match.lobbyAId && lobbyId !== match.lobbyBId) {
      throw new AppError('INVALID_LOBBY', 'Lobby is not part of this match', 400)
    }

    const lobby = await prisma.matchmakingLobby.findUnique({
      where: { id: lobbyId },
      select: { teamId: true },
    })
    if (!lobby || !lobby.teamId) throw Errors.notFound('Lobby')

    const team = await prisma.team.findFirst({
      where: {
        id: lobby.teamId,
        OR: [
          { captainId: player.id },
          { createdByUserId: userId },
          { playerIds: { has: player.id } },
        ],
      },
    })
    if (!team) throw Errors.forbidden()

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

  // One-shot notification when the arena owner finishes match setup (i.e.
  // status flips from 'confirmed' → 'setup'). Both team captains get pinged
  // exactly once. Fires after notifyMatchConfirmed so the funnel reads:
  //   match found → match confirmed → match setup → (player at venue).
  private async notifyMatchSetup(matchId: string) {
    const match = await prisma.matchmakingMatch.findUnique({ where: { id: matchId } })
    if (!match) return
    const [lobbyA, lobbyB, unit] = await Promise.all([
      prisma.matchmakingLobby.findUnique({ where: { id: match.lobbyAId }, include: { team: true } }),
      prisma.matchmakingLobby.findUnique({ where: { id: match.lobbyBId }, include: { team: true } }),
      prisma.arenaUnit.findUnique({ where: { id: match.groundId }, select: { name: true } }),
    ])
    const groundName = unit?.name ?? 'the ground'
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
        type: 'mm_match_setup',
        title: 'Match is ready',
        body: `${groundName} has set up your match-up vs ${opponent?.team?.name ?? 'your opponent'}. Pick your XI on match day.`,
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
    this.notifyMatchSetup(matchId).catch(() => undefined)

    return { status: 'setup', linkedMatchId }
  }

  // Player-side cancellation. Either team's captain/member can cancel a
  // non-final match-up. For pending_payment that's a clean exit. For
  // confirmed/setup the match is locked and the team has already paid —
  // we still allow it but flag wasPostPayment so the client can show the
  // ban-warning copy. 'started' matches must be cancelled at the venue.
  async cancelMatchAsPlayer(userId: string, matchId: string, lobbyId: string) {
    const player = await this.getPlayerProfile(userId)

    const match = await prisma.matchmakingMatch.findUnique({ where: { id: matchId } })
    if (!match) throw Errors.notFound('Match')

    if (lobbyId !== match.lobbyAId && lobbyId !== match.lobbyBId) {
      throw new AppError('INVALID_LOBBY', 'Lobby is not part of this match', 400)
    }

    const lobby = await prisma.matchmakingLobby.findUnique({
      where: { id: lobbyId },
      select: { teamId: true },
    })
    if (!lobby || !lobby.teamId) throw Errors.notFound('Lobby')

    const team = await prisma.team.findFirst({
      where: {
        id: lobby.teamId,
        OR: [
          { captainId: player.id },
          { createdByUserId: userId },
          { playerIds: { has: player.id } },
        ],
      },
    })
    if (!team) throw Errors.forbidden()

    if (match.status === 'started') {
      throw new AppError(
        'MATCH_IN_PROGRESS',
        'Match is live — contact the venue to cancel.',
        400,
      )
    }
    if (match.status === 'cancelled') {
      return {
        status: 'cancelled' as const,
        wasPostPayment: false,
      }
    }

    // Pre-payment cancel = match is still 'pending_payment' (at least one
    // team hasn't paid the advance). The team is window-shopping; we keep
    // both lobbies discoverable so neither side loses the slot they were
    // chasing, and we don't ding reputation.
    //
    // Post-payment cancel = both teams have confirmed (status 'confirmed',
    // 'setup', etc). This is a real bail; lobbies stay cancelled and the
    // canceller's reputation counters bump (drives the soft-ban formula).
    const isPrePayment = match.status === 'pending_payment'
    const wasPostPayment = !isPrePayment

    await prisma.$transaction(async (tx) => {
      await tx.matchmakingMatch.update({
        where: { id: matchId },
        data: { status: 'cancelled' },
      })
      await tx.matchmakingLobby.updateMany({
        where: { id: { in: [match.lobbyAId, match.lobbyBId] } },
        data: isPrePayment
          ? {
              status: 'searching',
              matchId: null,
              windowsMatched: { set: [] as string[] },
            }
          : { status: 'cancelled' },
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
      // Reputation bump only on post-payment cancel — the team committed
      // money + blocked the slot. Pre-payment cancels are free.
      if (!isPrePayment) {
        await tx.team.update({
          where: { id: team.id },
          data: {
            cancellationCount: { increment: 1 },
            lateCancelCount: { increment: 1 },
          },
        })
      }
    })

    // Recompute credibility outside the tx so we use the freshly-updated
    // counters. Sets matchupBanUntil if score crosses threshold. Skipped
    // on pre-payment cancel since counters didn't change.
    if (!isPrePayment) {
      await this.recomputeTeamCredibility(team.id).catch(() => undefined)
    }

    this.notifyMatchCancelledByPlayer(matchId, team.id, team.name ?? 'a team')
      .catch(() => undefined)

    return {
      status: 'cancelled' as const,
      wasPostPayment,
    }
  }

  // Recomputes credibilityScore from cancellation counters and applies a
  // soft ban when the team has shown a clear pattern of bailing on
  // confirmed match-ups. Score formula:
  //   score = 100 - 5*cancellationCount - 20*lateCancelCount - 25*noShowCount
  // Floor at 0. matchupBanUntil = now + 14d when score < 40.
  // Called as a fire-and-forget after every counter bump.
  private async recomputeTeamCredibility(teamId: string): Promise<void> {
    const team = await prisma.team.findUnique({
      where: { id: teamId },
      select: {
        cancellationCount: true,
        lateCancelCount: true,
        noShowCount: true,
      },
    })
    if (!team) return
    const raw =
      100 -
      5 * (team.cancellationCount ?? 0) -
      20 * (team.lateCancelCount ?? 0) -
      25 * (team.noShowCount ?? 0)
    const score = Math.max(0, Math.min(100, raw))
    const banUntil =
      score < 40 ? new Date(Date.now() + 14 * 24 * 60 * 60 * 1000) : null
    await prisma.team.update({
      where: { id: teamId },
      data: {
        credibilityScore: score,
        ...(banUntil ? { matchupBanUntil: banUntil } : {}),
      },
    })
  }

  // Notify the OTHER team that this match-up was cancelled by the caller's
  // team. Mirrors notifyMatchCancelledByOwner shape but with a different copy.
  private async notifyMatchCancelledByPlayer(
    matchId: string,
    cancellingTeamId: string,
    cancellingTeamName: string,
  ) {
    const match = await prisma.matchmakingMatch.findUnique({ where: { id: matchId } })
    if (!match) return
    const [lobbyA, lobbyB] = await Promise.all([
      prisma.matchmakingLobby.findUnique({ where: { id: match.lobbyAId } }),
      prisma.matchmakingLobby.findUnique({ where: { id: match.lobbyBId } }),
    ])
    for (const lobby of [lobbyA, lobbyB]) {
      if (!lobby?.playerId) continue
      // Don't ping the team that cancelled — they already know.
      if (lobby.teamId === cancellingTeamId) continue
      const profile = await prisma.playerProfile.findUnique({
        where: { id: lobby.playerId },
        select: { userId: true },
      })
      if (!profile?.userId) continue
      await notificationService.createNotification(profile.userId, {
        type: 'mm_match_cancelled_by_team',
        title: 'Match-up cancelled',
        body: `${cancellingTeamName} cancelled your match-up. You can search for a new opponent now.`,
        entityType: 'match',
        entityId: matchId,
        data: { lobbyId: lobby.id },
        sendPush: true,
        audience: 'PLAYER',
      }).catch(() => undefined)
    }
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
      // Reputation: arena absorbs the cancellation. Counter is independent
      // of team-side cancellations.
      await tx.arena.update({
        where: { id: unit.arena.id },
        data: { cancellationCount: { increment: 1 } },
      })
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
   * atomically and mint a Cashfree order. If another team already holds an
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

    // Player-vs-player Discover lobbies have no explicit picks. Resolve one
    // from the lobby's preferredArenaIds + windowsRanked so finalize can
    // write a real SlotBooking. Persist as a pick row so subsequent reads
    // (and the bypass / verify paths below) find it normally.
    let resolvedPick = result.pick as { groundId: string; slotTime: string; window?: TimeWindow } | null
    if (!resolvedPick) {
      const r = await this.resolveSlotForPicklessLobby({
        teamId: (result.lobby as any).teamId ?? null,
        preferredArenaIds: (result.lobby as any).preferredArenaIds ?? [],
        windowsRanked: (result.lobby as any).windowsRanked ?? [],
        windowsMatched: (result.lobby as any).windowsMatched ?? [],
        groundsRanked: (result.lobby as any).preferredArenaIds ?? [],
      })
      if (!r) {
        throw new AppError(
          'NO_AVAILABLE_SLOT',
          'Could not find an available slot at the preferred grounds. Pick different grounds or relax the window.',
          400,
        )
      }
      await prisma.matchmakingLobbyPick.create({
        data: {
          lobbyId: result.lobby.id,
          groundId: r.groundId,
          slotTime: r.slotTime,
          preferenceOrder: 1,
        },
      })
      resolvedPick = r
    }

    const unit = await prisma.arenaUnit.findUnique({ where: { id: resolvedPick.groundId } })
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

    // ── TEST-MODE BYPASS ────────────────────────────────────────────────
    // When the confirmation fee is ₹0, skip the gateway entirely and
    // finalize the win in-line: promote the holder, create the match, mark losers.
    // This branch goes away the moment CONFIRMATION_FEE_PAISE returns to
    // a non-zero value — the regular Cashfree path takes over.
    if (amountPaise === 0) {
      const bypassFee = await this.resolveFeeBreakdown(unit.arenaId, groundFeePaise)
      const finalize = await prisma.$transaction(async (tx) => {
        const interest = await tx.matchmakingInterest.findUnique({
          where: { id: result.interest.id },
          include: { lobby: { include: { picks: { orderBy: { preferenceOrder: 'asc' }, take: 1 } } } },
        })
        if (!interest) throw Errors.notFound('Interest')
        const lobby = interest.lobby
        if (lobby.status === 'matched') {
          throw new AppError('SLOT_TAKEN', 'Slot was taken by another team', 409)
        }
        const pick = lobby.picks[0]
        if (!pick) throw new AppError('NO_PICKS', 'Lobby has no ground picks', 400)

        // Resolve the matched window from the picked slot time so we can
        // append it to both lobbies' windowsMatched.
        const matchedWindow = (this.slotTimeWindow(pick.slotTime) as string)
          ?? ((lobby as any).windowsRanked?.[0] as string | undefined)
          ?? 'MORNING'

        // The joiner side is a fresh "matched" lobby for this slot only.
        // Auto-derive its ranked arrays through the unified helper.
        const joinerDerived = await this.deriveLobbyRankedFields({
          windowsRanked: [matchedWindow],
          picks: [{ groundId: pick.groundId, slotTime: pick.slotTime }],
          tx,
        })
        const joinerLobby = await tx.matchmakingLobby.create({
          data: {
            teamId: interest.teamId,
            playerId: interest.playerId,
            format: lobby.format,
            ballType: lobby.ballType,
            date: lobby.date,
            status: 'matched',
            expiresAt: new Date(Date.now() + LOBBY_EXPIRY_HOURS * 60 * 60 * 1000),
            windowsRanked: joinerDerived.windowsRanked,
            windowsMatched: [matchedWindow],
            preferredArenaIds: joinerDerived.groundsRanked,
            picks: {
              create: [{ groundId: pick.groundId, slotTime: pick.slotTime, preferenceOrder: 1 }],
            },
          } as any,
        })

        const remainingFeePaise = Math.max(0, groundFeePaise - amountPaise)

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
            teamAConfirmed: false,
            teamBConfirmed: true,
            paymentAmountPerTeam: amountPaise,
            groundFeePaise,
            remainingFeePaise,
            platformFeePaise: bypassFee.platformFeePaise,
            arenaPayoutPaise: bypassFee.arenaPayoutPaise,
          },
        })

        await tx.matchmakingInterest.update({
          where: { id: interest.id },
          data: {
            status: 'won',
            razorpayPaymentId: 'free_test_mode',
            paidAt: new Date(),
          },
        })
        await tx.matchmakingInterest.updateMany({
          where: {
            lobbyId: lobby.id,
            id: { not: interest.id },
            status: { in: ['interested', 'locked'] },
          },
          data: { status: 'lost' },
        })
        // Clear lock + persist matchId on both sides. Status flip is delegated
        // to consumeLobbyWindows (which also handles partial-consumption).
        await tx.matchmakingLobby.update({
          where: { id: lobby.id },
          data: {
            matchId: match.id,
            lockedByInterestId: null,
            lockExpiresAt: null,
          },
        })
        await tx.matchmakingLobby.update({
          where: { id: joinerLobby.id },
          data: { matchId: match.id },
        })

        // V2 consumption: append the matched window to both sides'
        // windowsMatched and flip status only when fully consumed. Also
        // auto-cancels overlapping sibling lobbies of the same team.
        await this.consumeLobbyWindows(tx, {
          lobbyId: lobby.id,
          window: matchedWindow,
          slotTime: pick.slotTime,
          format: lobby.format,
        })
        await this.consumeLobbyWindows(tx, {
          lobbyId: joinerLobby.id,
          window: matchedWindow,
          slotTime: pick.slotTime,
          format: lobby.format,
        })

        return { match, lobby }
      })

      this.notifyMatchFound(finalize.match.id).catch(() => undefined)
      this.notifyLosersOfSlotTaken(finalize.lobby.id, result.interest.id)
        .catch(() => undefined)

      return {
        interestId: result.interest.id,
        cashfreeOrderId: '',
        sessionId: '',
        amountPaise: 0,
        currency: 'INR',
        groundFeePaise,
        lockExpiresAt: result.lockExpiresAt.toISOString(),
        lockSeconds: INTEREST_LOCK_SECONDS,
        freeMatchId: finalize.match.id,
      }
    }

    // Resolve user phone for Cashfree order
    const userRow = await prisma.user.findUnique({ where: { id: userId }, select: { name: true, phone: true, email: true } })
    const cfOrder = await cashfree.createOrder({
      orderId: `mm_int_${result.interest.id.slice(0, 20)}_${Date.now()}`,
      amountPaise,
      customerId: userId,
      customerPhone: (userRow?.phone || '9000000000').replace(/\D/g, '').slice(-10),
      customerEmail: userRow?.email ?? undefined,
      customerName: userRow?.name || 'Player',
      notifyUrl: MM_NOTIFY_URL,
    })

    await prisma.matchmakingInterest.update({
      where: { id: result.interest.id },
      data: { razorpayOrderId: cfOrder.order_id },
    })

    return {
      interestId: result.interest.id,
      cashfreeOrderId: cfOrder.order_id,
      sessionId: cfOrder.payment_session_id,
      amountPaise,
      currency: 'INR',
      groundFeePaise,
      lockExpiresAt: result.lockExpiresAt.toISOString(),
      lockSeconds: INTEREST_LOCK_SECONDS,
    }
  }

  /**
   * B3 — Player's payment came back from Cashfree. Verify payment, promote
   * the locked interest to "won" and create the Match. Mark every other
   * interest on this lobby as "lost" and notify their teams.
   */
  async verifyInterestPayment(
    userId: string,
    interestId: string,
    cashfreeOrderId: string,
    cashfreePaymentId: string,
    _unused?: string,
  ) {
    const player = await this.getPlayerProfile(userId)

    // 1. Validate payment via Cashfree API out-of-band (no DB locks needed yet).
    const payments = await cashfree.verifyOrder(cashfreeOrderId)
    const paid = Array.isArray(payments) && payments.some((p: any) => p.payment_status === 'SUCCESS')
    if (!paid) {
      throw new AppError('PAYMENT_NOT_COMPLETED', 'Payment has not been completed', 400)
    }

    // 2. Promote interest, create match, mark losers — all in one transaction.
    const result = await prisma.$transaction(async (tx) => {
      const interest = await tx.matchmakingInterest.findUnique({
        where: { id: interestId },
        include: { lobby: { include: { picks: { orderBy: { preferenceOrder: 'asc' }, take: 1 } } } },
      })
      if (!interest) throw Errors.notFound('Interest')
      if (interest.playerId !== player.id) throw Errors.forbidden()
      if (interest.razorpayOrderId !== cashfreeOrderId) {
        throw new AppError('ORDER_MISMATCH', 'Cashfree order does not match this interest', 400)
      }

      // Idempotency: payment may be re-verified by client/webhook.
      if (interest.status === 'won') {
        const existingMatch = await tx.matchmakingMatch.findUnique({
          where: { lobbyAId: interest.lobbyId },
        })
        return { interest, match: existingMatch, lobby: interest.lobby, pick: interest.lobby.picks[0] }
      }

      if (interest.status !== 'locked') {
        // Lock might have expired between Cashfree capture and verify-call.
        // Try to reclaim if the lobby is still searching and unlocked.
        if (interest.status !== 'interested') {
          throw new AppError('LOCK_LOST', 'Lock expired before payment confirmed', 409)
        }
      }

      const lobby = interest.lobby
      if (lobby.status === 'matched') {
        // Someone else won this slot meanwhile. Mark this interest lost
        // and signal the client (caller will need to refund Cashfree capture).
        await tx.matchmakingInterest.update({
          where: { id: interest.id },
          data: { status: 'lost', razorpayPaymentId: cashfreePaymentId, paidAt: new Date() },
        })
        throw new AppError('SLOT_TAKEN', 'Slot was taken by another team — payment will be refunded', 409)
      }

      const pick = lobby.picks[0]
      if (!pick) throw new AppError('NO_PICKS', 'Lobby has no ground picks', 400)

      const unit = await tx.arenaUnit.findUnique({ where: { id: pick.groundId } })
      if (!unit) throw Errors.notFound('Arena unit')

      // Resolve the matched window so we can stamp both lobbies' fields.
      const matchedWindow = (this.slotTimeWindow(pick.slotTime) as string)
        ?? ((lobby as any).windowsRanked?.[0] as string | undefined)
        ?? 'MORNING'

      // Build a "joiner" lobby for the winning team (mirrors joinOpenLobby).
      // Unified helper auto-fills both ranked arrays from the pick.
      const joinerDerived = await this.deriveLobbyRankedFields({
        windowsRanked: [matchedWindow],
        picks: [{ groundId: pick.groundId, slotTime: pick.slotTime }],
        tx,
      })
      const joinerLobby = await tx.matchmakingLobby.create({
        data: {
          teamId: interest.teamId,
          playerId: interest.playerId,
          format: lobby.format,
          ballType: lobby.ballType,
          date: lobby.date,
          status: 'matched',
          expiresAt: new Date(Date.now() + LOBBY_EXPIRY_HOURS * 60 * 60 * 1000),
          windowsRanked: joinerDerived.windowsRanked,
          windowsMatched: [matchedWindow],
          preferredArenaIds: joinerDerived.groundsRanked,
          picks: {
            create: [{ groundId: pick.groundId, slotTime: pick.slotTime, preferenceOrder: 1 }],
          },
        } as any,
      })

      const groundFeePaise = Math.floor(
        unit.pricePerHourPaise * this.formatDurationMins(lobby.format as MatchmakingFormat) / 60 / 2,
      )
      const remainingFeePaise = Math.max(0, groundFeePaise - CONFIRMATION_FEE_PAISE)
      const verifyFee = await this.resolveFeeBreakdown(unit.arenaId, groundFeePaise, tx)

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
          platformFeePaise: verifyFee.platformFeePaise,
          arenaPayoutPaise: verifyFee.arenaPayoutPaise,
        },
      })

      // Promote winner.
      await tx.matchmakingInterest.update({
        where: { id: interest.id },
        data: {
          status: 'won',
          razorpayPaymentId: cashfreePaymentId,
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

      // Clear lock + persist matchId on both sides. Status flip is delegated
      // to consumeLobbyWindows below (which handles partial-consumption).
      await tx.matchmakingLobby.update({
        where: { id: lobby.id },
        data: {
          matchId: match.id,
          lockedByInterestId: null,
          lockExpiresAt: null,
        },
      })
      // Joiner lobby (challenger's side) also needs matchId — without it
      // listMyConfirmedMatches filters the challenger out and the match
      // never appears on their My Match-Up tab.
      await tx.matchmakingLobby.update({
        where: { id: joinerLobby.id },
        data: { matchId: match.id },
      })

      // V2 consumption: append matched window, flip status only when fully
      // consumed, auto-cancel overlapping sibling lobbies of the same team
      // with status='auto_cancelled' (so reputation isn't impacted).
      await this.consumeLobbyWindows(tx, {
        lobbyId: lobby.id,
        window: matchedWindow,
        slotTime: pick.slotTime,
        format: lobby.format,
      })
      await this.consumeLobbyWindows(tx, {
        lobbyId: joinerLobby.id,
        window: matchedWindow,
        slotTime: pick.slotTime,
        format: lobby.format,
      })

      // Note: cross-key sibling lobbies (different date/format) stay open by
      // design. consumeLobbyWindows already auto-cancels same-date sibling
      // lobbies whose remaining windows overlap the consumed slot.

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

  // ── L2 — Captain arena review ─────────────────────────────────────────────
  // Captains submit a star+tags rating after the match is over. The review
  // updates the arena's match-context rating aggregates (Bayesian-smoothed,
  // k=5, prior=3.0) which feed L3's rating-weighted ground allocation.
  //
  // Auth: caller must be the team's captainId (or its createdByUserId, the
  // existing fallback used everywhere else in this service). One review per
  // (matchId, teamId).
  async submitMatchArenaReview(
    userId: string,
    args: {
      matchId: string
      teamId: string
      stars: number
      tags?: string[]
      comment?: string
    },
  ): Promise<{ reviewId: string; arenaId: string; matchRatingAvg: number; matchRatingCount: number }> {
    if (args.stars < 1 || args.stars > 5) {
      throw new AppError('INVALID_INPUT', 'Stars must be between 1 and 5.', 400)
    }

    // Captain auth + team membership in the match.
    const team = await this.resolveCallerTeam(userId, args.teamId)
    if (!team) throw Errors.forbidden()

    const match = await prisma.match.findUnique({
      where: { id: args.matchId },
      select: {
        id: true,
        teamAId: true,
        teamBId: true,
        status: true,
        slotBookingId: true,
        completedAt: true,
        startedAt: true,
      },
    })
    if (!match) throw Errors.notFound('Match')
    if (match.teamAId !== args.teamId && match.teamBId !== args.teamId) {
      throw new AppError(
        'NOT_IN_MATCH',
        'This team did not play in the match.',
        403,
      )
    }
    // Reviews only after the match has actually happened. We accept STARTED
    // (mid-match) and COMPLETED — and an unchecked startedAt as a soft
    // fallback for matches whose status flow lags behind real-world play.
    if (!match.startedAt && !match.completedAt && match.status !== 'IN_PROGRESS' && match.status !== 'COMPLETED') {
      throw new AppError(
        'MATCH_NOT_STARTED',
        'You can review the ground after the match starts.',
        400,
      )
    }

    // Match → SlotBooking → Arena. Matchmaking matches always have a
    // slotBookingId; non-matchmaking matches (Venue-only) can't be reviewed
    // here.
    if (!match.slotBookingId) {
      throw new AppError(
        'NO_ARENA',
        'This match has no Swing arena to review.',
        400,
      )
    }
    const slot = await prisma.slotBooking.findUnique({
      where: { id: match.slotBookingId },
      select: { arenaId: true, bookedById: true },
    })
    if (!slot) throw Errors.notFound('SlotBooking')

    // Idempotent: returning the existing review surfaces the same shape as
    // a fresh submit, so the client doesn't have to special-case "already
    // reviewed."
    const existing = await prisma.review.findFirst({
      where: { matchId: args.matchId, teamId: args.teamId },
      select: { id: true },
    })
    if (existing) {
      const arena = await prisma.arena.findUnique({
        where: { id: slot.arenaId },
        select: { matchRatingAvg: true, matchRatingCount: true },
      })
      return {
        reviewId: existing.id,
        arenaId: slot.arenaId,
        matchRatingAvg: arena?.matchRatingAvg ?? 3.0,
        matchRatingCount: arena?.matchRatingCount ?? 0,
      }
    }

    const reviewerUserId = userId
    const created = await prisma.review.create({
      data: {
        reviewerId: reviewerUserId,
        arenaId: slot.arenaId,
        matchId: args.matchId,
        teamId: args.teamId,
        rating: args.stars,
        tags: (args.tags ?? []).slice(0, 12),
        comment: args.comment ?? null,
      },
      select: { id: true },
    })

    const aggregates = await this.recomputeArenaMatchRating(slot.arenaId)
    return {
      reviewId: created.id,
      arenaId: slot.arenaId,
      matchRatingAvg: aggregates.matchRatingAvg,
      matchRatingCount: aggregates.matchRatingCount,
    }
  }

  // Bayesian-smoothed avg over match-context reviews only. k=5 prior=3.0 means
  // the first ~5 reviews can't drag a fresh arena to the extremes (1.0 or
  // 5.0). Updates Arena.matchRatingAvg + matchRatingCount in one write.
  private async recomputeArenaMatchRating(
    arenaId: string,
  ): Promise<{ matchRatingAvg: number; matchRatingCount: number }> {
    const stats = await prisma.review.aggregate({
      where: { arenaId, matchId: { not: null } },
      _sum: { rating: true },
      _count: { _all: true },
    })
    const count = stats._count._all
    const sum = stats._sum.rating ?? 0
    const k = 5
    const prior = 3.0
    const matchRatingAvg = (k * prior + sum) / (k + count)
    await prisma.arena.update({
      where: { id: arenaId },
      data: { matchRatingAvg, matchRatingCount: count } as any,
    })
    return { matchRatingAvg, matchRatingCount: count }
  }
}
