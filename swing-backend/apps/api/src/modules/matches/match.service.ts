import { prisma, TriggerEventType } from '@swing/db'
import { Errors, AppError } from '../../lib/errors'
import { PlayerService } from '../player/player.service'
import { PerformanceService } from '../performance/performance.service'
import { StudioService } from '../studio/studio.service'
import { NotificationService } from '../notifications/notification.service'

const notificationSvc = new NotificationService()
import { buildMatchPlayerStats, buildInningsPlayerStats } from './match-stats'
import {
  activeDismissedPlayerId,
  completedRunsForStrike,
  isInningsWicket,
  isLegalDelivery,
  isRetirementDismissal,
  nextBallIsFreeHit,
  normalizeWagonZone,
  resolveBallSelections,
  validateBallAgainstInningsState,
  validateBallShape,
  validateDismissalForDelivery,
} from './scoring-rules'

const studioService = new StudioService()
const performanceService = new PerformanceService()
type MutationAccess = 'SCORER' | 'ADMIN'
type MutationOptions = { access?: MutationAccess }

function fireStudioEvent(matchId: string, eventType: TriggerEventType) {
  void studioService.triggerEvent(matchId, eventType).catch((error) => {
    console.error('[studio] trigger event failed', { matchId, eventType, error })
  })
}

export class MatchService {
  private assertValidScoringBall(params: {
    currentLegalBalls: number
    maxLegalBalls: number
    currentWickets: number
    currentRuns: number
    targetRuns?: number | null
    ball: any
    isFreeHit: boolean
  }) {
    try {
      validateBallShape(params.ball)
      validateBallAgainstInningsState({
        currentLegalBalls: params.currentLegalBalls,
        maxLegalBalls: params.maxLegalBalls,
        currentWickets: params.currentWickets,
        currentRuns: params.currentRuns,
        targetRuns: params.targetRuns ?? null,
        ball: params.ball,
      })
      validateDismissalForDelivery({
        outcome: params.ball.outcome,
        dismissalType: params.ball.dismissalType,
        isFreeHit: params.isFreeHit,
      })
    } catch (error) {
      if (error instanceof AppError) throw error
      throw new AppError(
        'INVALID_SCORING_INPUT',
        error instanceof Error ? error.message : 'Invalid scoring input',
        400,
      )
    }
  }

  private resolveMaxOvers(match: { customOvers?: number | null; format: string }) {
    if (match.customOvers && match.customOvers > 0) return match.customOvers
    switch (match.format) {
      case 'T10':
        return 10
      case 'T20':
        return 20
      case 'ONE_DAY':
        return 50
      case 'BOX_CRICKET':
        return 6
      case 'TWO_INNINGS':
      case 'TEST':
        return 90
      default:
        return 20
    }
  }

  /**
   * Compute the chase target (total to beat, already +1) for the given innings,
   * or null if no target applies (e.g. first innings, declaration innings).
   *
   * Limited-overs: innings 2 chases innings 1 + 1.
   * Multi-innings (TEST / TWO_INNINGS): target exists only when the opponent
   * has completed more innings than the current batting team has — i.e. when
   * batting team is in their final innings.
   *   target = sum(opponent completed innings) − sum(own completed innings) + 1
   */
  private async resolveTargetRuns(
    matchId: string,
    battingTeam: string,
    inningsNum: number,
    isMultiInnings: boolean,
  ): Promise<number | null> {
    if (!isMultiInnings) {
      // Standard limited-overs: only innings 2 has a target
      if (inningsNum !== 2) return null
      const inn1 = await prisma.innings.findUnique({
        where: { matchId_inningsNumber: { matchId, inningsNumber: 1 } },
        select: { totalRuns: true, isCompleted: true },
      })
      if (!inn1?.isCompleted) return null
      return inn1.totalRuns + 1
    }

    // Multi-innings: target applies when opponent has completed more innings than us
    const allInnings = await prisma.innings.findMany({
      where: { matchId, isCompleted: true },
      select: { battingTeam: true, totalRuns: true },
    })
    const opponentInnings = allInnings.filter(i => i.battingTeam !== battingTeam)
    const ownPreviousInnings = allInnings.filter(i => i.battingTeam === battingTeam)

    if (opponentInnings.length === 0) return null
    if (ownPreviousInnings.length >= opponentInnings.length) return null

    const opponentTotal = opponentInnings.reduce((s, i) => s + i.totalRuns, 0)
    const ownTotal = ownPreviousInnings.reduce((s, i) => s + i.totalRuns, 0)
    return opponentTotal - ownTotal + 1
  }

  private normalizePlayingXI(playerIds: string[]) {
    return Array.from(
      new Set(
        (playerIds || [])
          .map((playerId) => `${playerId}`.trim())
          .filter(Boolean),
      ),
    )
  }

  private async resolvePlayingXIPlayerIds(playerIds: string[]) {
    const normalizedIds = this.normalizePlayingXI(playerIds)
    if (normalizedIds.length === 0) return []

    const players = await prisma.playerProfile.findMany({
      where: {
        OR: [
          { id: { in: normalizedIds } },
          { userId: { in: normalizedIds } },
        ],
      },
      select: { id: true, userId: true },
    })

    const playerIdMap = new Map<string, string>()
    for (const player of players) {
      playerIdMap.set(player.id, player.id)
      playerIdMap.set(player.userId, player.id)
    }

    const unresolvedIds = normalizedIds.filter((playerId) => !playerIdMap.has(playerId))
    if (unresolvedIds.length > 0) {
      throw new AppError(
        'INVALID_PLAYING_XI',
        `Unable to resolve player IDs: ${unresolvedIds.join(', ')}`,
        400,
      )
    }

    return normalizedIds.map((playerId) => playerIdMap.get(playerId) as string)
  }

  private validatePlayingXI(
    teamLabel: string,
    playerIds: string[],
    captainId?: string | null,
    viceCaptainId?: string | null,
    wicketKeeperId?: string | null,
  ) {
    const playerSet = new Set(playerIds)

    if (playerIds.length !== 11) {
      throw new AppError(
        'INVALID_PLAYING_XI',
        `${teamLabel} must have exactly 11 players in the playing XI`,
        400,
      )
    }
    if (!captainId || !playerSet.has(captainId)) {
      throw new AppError(
        'MISSING_CAPTAIN',
        `${teamLabel} captain must be part of the playing XI`,
        400,
      )
    }
    if (!viceCaptainId || !playerSet.has(viceCaptainId)) {
      throw new AppError(
        'MISSING_VICE_CAPTAIN',
        `${teamLabel} vice captain must be part of the playing XI`,
        400,
      )
    }
    if (!wicketKeeperId || !playerSet.has(wicketKeeperId)) {
      throw new AppError(
        'MISSING_WICKET_KEEPER',
        `${teamLabel} wicketkeeper must be part of the playing XI`,
        400,
      )
    }
    if (captainId === viceCaptainId) {
      throw new AppError(
        'INVALID_LEADERSHIP',
        `${teamLabel} captain and vice captain must be different players`,
        400,
      )
    }
  }

  private hasPlayingXiDetails(data: any) {
    return Boolean(
      (data.teamAPlayerIds?.length ?? 0) > 0 ||
      (data.teamBPlayerIds?.length ?? 0) > 0 ||
      data.teamACaptainId ||
      data.teamBCaptainId ||
      data.teamAViceCaptainId ||
      data.teamBViceCaptainId ||
      data.teamAWicketKeeperId ||
      data.teamBWicketKeeperId,
    )
  }

  private resolveDismissedPlayerId(ball: any, strikerId: string | null, nonStrikerId: string | null) {
    return activeDismissedPlayerId({
      ball,
      strikerId,
      nonStrikerId,
    })
  }

  private compareBallReplayOrder(a: any, b: any) {
    const scoredAtDiff =
      new Date(a.scoredAt ?? 0).getTime() - new Date(b.scoredAt ?? 0).getTime()
    if (scoredAtDiff !== 0) return scoredAtDiff
    const idDiff = `${a.id ?? ''}`.localeCompare(`${b.id ?? ''}`)
    if (idDiff !== 0) return idDiff
    const overDiff = (a.overNumber ?? 0) - (b.overNumber ?? 0)
    if (overDiff !== 0) return overDiff
    return (a.ballNumber ?? 0) - (b.ballNumber ?? 0)
  }

  private async resequenceInningsBalls(inningsId: string) {
    const balls = await prisma.ballEvent.findMany({
      where: { inningsId },
      orderBy: [{ scoredAt: 'asc' }, { id: 'asc' }],
    })

    let legalBalls = 0
    for (const ball of balls) {
      const overNumber = Math.floor(legalBalls / 6)
      const ballNumber = (legalBalls % 6) + 1
      if (ball.overNumber !== overNumber || ball.ballNumber !== ballNumber) {
        await prisma.ballEvent.update({
          where: { id: ball.id },
          data: { overNumber, ballNumber },
        })
      }
      if (isLegalDelivery(ball.outcome, ball.dismissalType)) {
        legalBalls += 1
      }
    }
  }

  private validateInningsSelections(params: {
    match: any
    innings: { battingTeam: string }
    batterId?: string | null
    nonBatterId?: string | null
    bowlerId?: string | null
    fielderId?: string | null
    dismissedPlayerId?: string | null
  }) {
    const battingIds = new Set<string>(
      ((params.innings.battingTeam === 'A'
        ? params.match.teamAPlayerIds
        : params.match.teamBPlayerIds) ?? []) as string[],
    )
    const bowlingIds = new Set<string>(
      ((params.innings.battingTeam === 'A'
        ? params.match.teamBPlayerIds
        : params.match.teamAPlayerIds) ?? []) as string[],
    )
    const requireFromSet = (
      label: string,
      playerId: string | undefined | null,
      allowedIds: Set<string>,
    ) => {
      if (!playerId || allowedIds.size === 0) return
      if (!allowedIds.has(playerId)) {
        throw new AppError(
          'INVALID_SCORING_SELECTION',
          `${label} does not belong to the current innings side`,
          400,
        )
      }
    }

    requireFromSet('Batter', params.batterId, battingIds)
    requireFromSet('Non-striker', params.nonBatterId, battingIds)
    requireFromSet('Bowler', params.bowlerId, bowlingIds)
    requireFromSet('Fielder', params.fielderId, bowlingIds)

    if (
      params.nonBatterId &&
      params.batterId &&
      params.nonBatterId === params.batterId
    ) {
      throw new AppError(
        'INVALID_SCORING_SELECTION',
        'Striker and non-striker must be different players',
        400,
      )
    }

    if (
      params.dismissedPlayerId &&
      params.dismissedPlayerId !== params.batterId &&
      params.dismissedPlayerId !== params.nonBatterId
    ) {
      throw new AppError(
        'INVALID_DISMISSAL',
        'Dismissed player must be one of the active batters',
        400,
      )
    }
  }

  public buildInningsSnapshot(balls: any[]) {
    const orderedBalls = [...balls].sort((a, b) => this.compareBallReplayOrder(a, b))
    let totalRuns = 0
    let totalWickets = 0
    let extras = 0
    let legalBalls = 0
    let strikerId: string | null = null
    let nonStrikerId: string | null = null
    let bowlerId: string | null = null
    let isFreeHit = false
    let runningRuns = 0
    let runningWickets = 0
    const scoreAfterBall = new Map<string, string>()

    for (const ball of orderedBalls) {
      totalRuns += (ball.runs || 0) + (ball.extras || 0)
      extras += ball.extras || 0
      if (isInningsWicket(ball)) totalWickets++
      runningRuns += (ball.runs || 0) + (ball.extras || 0)
      if (isInningsWicket(ball)) runningWickets++
      scoreAfterBall.set(ball.id, `${runningRuns}/${runningWickets}`)

      if (!strikerId) strikerId = ball.batterId
      if (!nonStrikerId && ball.nonBatterId) nonStrikerId = ball.nonBatterId

      const isLegal = isLegalDelivery(ball.outcome, ball.dismissalType)
      const isEndOfOver = isLegal && (legalBalls + 1) % 6 === 0

      let nextStrikerId: string | null = strikerId
      let nextNonStrikerId: string | null = nonStrikerId

      const dismissedPlayerId = this.resolveDismissedPlayerId(ball, strikerId, nonStrikerId)
      if ((isInningsWicket(ball) || isRetirementDismissal(ball.dismissalType)) && dismissedPlayerId) {
        if (dismissedPlayerId === nextStrikerId) nextStrikerId = null
        else if (dismissedPlayerId === nextNonStrikerId) nextNonStrikerId = null
      }

      const runsForStrike = completedRunsForStrike(ball)
      const oddRuns = runsForStrike % 2 !== 0

      if (isLegal) {
        // Legal delivery: rotate if odd runs XOR end-of-over (both swap cancel out)
        const doSwap = oddRuns !== isEndOfOver
        if (doSwap) {
          const tmp: string | null = nextStrikerId
          nextStrikerId = nextNonStrikerId
          nextNonStrikerId = tmp
        }
        legalBalls += 1
      } else if (oddRuns) {
        // Wide / no-ball: rotate only on odd completed runs (no end-of-over swap)
        const tmp: string | null = nextStrikerId
        nextStrikerId = nextNonStrikerId
        nextNonStrikerId = tmp
      }

      if (ball.tags?.includes('transition:switch-ends')) {
        if (nextStrikerId == null && nextNonStrikerId != null) {
          nextStrikerId = nextNonStrikerId
          nextNonStrikerId = null
        } else if (nextNonStrikerId == null && nextStrikerId != null) {
          nextNonStrikerId = nextStrikerId
          nextStrikerId = null
        }
      }

      strikerId = nextStrikerId
      nonStrikerId = nextNonStrikerId
      bowlerId = isEndOfOver ? null : ball.bowlerId

      isFreeHit = nextBallIsFreeHit({
        previousBallWasFreeHit: isFreeHit,
        currentOutcome: ball.outcome,
        dismissalType: ball.dismissalType,
      })
    }

    return {
      totalRuns,
      totalWickets,
      extras,
      totalOvers: Math.floor(legalBalls / 6) + (legalBalls % 6) / 10,
      legalBalls,
      currentStrikerId: strikerId,
      currentNonStrikerId: nonStrikerId,
      currentBowlerId: bowlerId,
      isFreeHit,
      scoreAfterBall,
    }
  }

  private async rebuildInningsState(inningsId: string) {
    await this.resequenceInningsBalls(inningsId)
    const balls = await prisma.ballEvent.findMany({
      where: { inningsId },
      orderBy: [
        { overNumber: 'asc' },
        { ballNumber: 'asc' },
        { scoredAt: 'asc' },
        { id: 'asc' },
      ],
    })
    const snapshot = this.buildInningsSnapshot(balls)
    const updated = await prisma.innings.update({
      where: { id: inningsId },
      data: {
        totalRuns: snapshot.totalRuns,
        totalWickets: snapshot.totalWickets,
        extras: snapshot.extras,
        totalOvers: snapshot.totalOvers,
        currentStrikerId: snapshot.currentStrikerId,
        currentNonStrikerId: snapshot.currentNonStrikerId,
        currentBowlerId: snapshot.currentBowlerId,
      },
    })
    for (const ball of balls) {
      const score = snapshot.scoreAfterBall.get(ball.id)
      if (score && score !== ball.scoreAfterBall) {
        await prisma.ballEvent.update({
          where: { id: ball.id },
          data: { scoreAfterBall: score },
        })
      }
    }
    return {
      innings: updated,
      needNewBowler: snapshot.currentBowlerId == null && balls.length > 0,
      isFreeHit: snapshot.isFreeHit,
    }
  }

  private async verifyAdminUser(userId: string) {
    const adminUser = await prisma.adminUser.findUnique({ where: { id: userId } })
    if (adminUser && adminUser.isActive && ['SWING_ADMIN', 'SWING_SUPPORT'].includes(adminUser.role)) {
      return adminUser
    }
    const user = await prisma.user.findUnique({ where: { id: userId } })
    if (!user || (!user.roles.includes('SWING_ADMIN' as any) && !user.roles.includes('SWING_SUPPORT' as any))) {
      throw Errors.forbidden()
    }
    return user
  }

  private async authorizeMutation(matchId: string, userId: string, options: MutationOptions = {}) {
    const match = await prisma.match.findUnique({ where: { id: matchId } })
    if (!match) throw Errors.notFound('Match')
    if ((options.access ?? 'SCORER') === 'ADMIN') {
      await this.verifyAdminUser(userId)
      return match
    }
    const player = await prisma.playerProfile.findUnique({ where: { userId } })
    if (!player || match.scorerId !== player.id) {
      throw new AppError('NOT_SCORER', 'Only the scorer can update this match', 403)
    }
    return match
  }

  private async resolveEffectivePlayerCount(match: any, side: 'A' | 'B') {
    let effectiveCount = side === 'A'
      ? (match.teamAPlayerIds?.length ?? 0)
      : (match.teamBPlayerIds?.length ?? 0)
    if (match.tournamentId && !effectiveCount) {
      const tournamentTeam = await prisma.tournamentTeam.findFirst({
        where: { tournamentId: match.tournamentId, teamName: side === 'A' ? match.teamAName : match.teamBName },
        select: { playerIds: true, teamId: true },
      })
      if (tournamentTeam?.playerIds.length) effectiveCount = tournamentTeam.playerIds.length
      else if (tournamentTeam?.teamId) {
        const team = await prisma.team.findUnique({
          where: { id: tournamentTeam.teamId },
          select: { playerIds: true },
        })
        effectiveCount = team?.playerIds.length ?? 0
      }
    }
    return effectiveCount
  }

  private async ensureMatchCanStart(match: any) {
    const effectiveACount = await this.resolveEffectivePlayerCount(match, 'A')
    const effectiveBCount = await this.resolveEffectivePlayerCount(match, 'B')

    if (effectiveACount < 11) {
      throw new AppError('INVALID_PLAYING_XI', `Team A only has ${effectiveACount} players. Need at least 11 to start.`, 400)
    }
    if (effectiveBCount < 11) {
      throw new AppError('INVALID_PLAYING_XI', `Team B only has ${effectiveBCount} players. Need at least 11 to start.`, 400)
    }

    if ((match.teamAPlayerIds?.length ?? 0) >= 11 && (match.teamBPlayerIds?.length ?? 0) >= 11) {
      this.validatePlayingXI(
        'Team A',
        this.normalizePlayingXI(match.teamAPlayerIds || []),
        match.teamACaptainId,
        match.teamAViceCaptainId,
        match.teamAWicketKeeperId,
      )
      this.validatePlayingXI(
        'Team B',
        this.normalizePlayingXI(match.teamBPlayerIds || []),
        match.teamBCaptainId,
        match.teamBViceCaptainId,
        match.teamBWicketKeeperId,
      )
    }
  }

  private enrichMatchReadModel<T extends { innings?: any[] }>(match: T) {
    if (!match?.innings) return match
    return {
      ...match,
      innings: match.innings.map((inn) => {
        const snapshot = this.buildInningsSnapshot(inn.ballEvents ?? [])
        return {
          ...inn,
          // Always derive totals live from ball events so stale DB values never leak
          totalRuns: snapshot.totalRuns,
          totalWickets: snapshot.totalWickets,
          totalOvers: snapshot.totalOvers,
          extras: snapshot.extras,
          currentStrikerId: inn.currentStrikerId ?? snapshot.currentStrikerId,
          currentNonStrikerId: inn.currentNonStrikerId ?? snapshot.currentNonStrikerId,
          currentBowlerId: inn.currentBowlerId ?? snapshot.currentBowlerId,
          isFreeHit: snapshot.isFreeHit,
        }
      }),
    }
  }

  async createMatch(userId: string, data: any) {
    const player = await prisma.playerProfile.findUnique({ where: { userId } })
    let resolvedVenueName = data.venueName?.trim() || null
    let resolvedFacilityId = data.facilityId?.trim() || null
    const resolvedCustomOvers =
      data.format === 'CUSTOM' && Number.isFinite(data.customOvers)
        ? Number(data.customOvers)
        : null

    if (resolvedFacilityId) {
      const arena = await prisma.arena.findUnique({
        where: { id: resolvedFacilityId },
        select: { id: true, name: true },
      })
      if (!arena) {
        throw new AppError('INVALID_FACILITY', 'Selected arena was not found', 400)
      }
      resolvedVenueName = arena.name
      resolvedFacilityId = arena.id
    }

    if (data.format === 'CUSTOM' && !resolvedCustomOvers) {
      throw new AppError(
        'INVALID_CUSTOM_OVERS',
        'Custom format requires overs between 1 and 100',
        400,
      )
    }

    const teamAPlayerIds = await this.resolvePlayingXIPlayerIds(data.teamAPlayerIds || [])
    const teamBPlayerIds = await this.resolvePlayingXIPlayerIds(data.teamBPlayerIds || [])
    if (this.hasPlayingXiDetails(data)) {
      const overlappingPlayerIds = teamAPlayerIds.filter((playerId) => teamBPlayerIds.includes(playerId))
      if (overlappingPlayerIds.length > 0) {
        throw new AppError(
          'INVALID_PLAYING_XI',
          'A player cannot be listed in both teams',
          400,
        )
      }

      this.validatePlayingXI(
        'Team A',
        teamAPlayerIds,
        data.teamACaptainId,
        data.teamAViceCaptainId,
        data.teamAWicketKeeperId,
      )
      this.validatePlayingXI(
        'Team B',
        teamBPlayerIds,
        data.teamBCaptainId,
        data.teamBViceCaptainId,
        data.teamBWicketKeeperId,
      )
    }

    const liveCode = await this.generateUniqueMatchLiveCode()
    const livePin = this.generateMatchLivePin()

    return prisma.match.create({
      data: {
        matchType: data.matchType, format: data.format,
        teamAName: data.teamAName, teamBName: data.teamBName,
        teamAPlayerIds,
        teamBPlayerIds,
        teamACaptainId: data.teamACaptainId,
        teamBCaptainId: data.teamBCaptainId,
        teamAViceCaptainId: data.teamAViceCaptainId,
        teamBViceCaptainId: data.teamBViceCaptainId,
        teamAWicketKeeperId: data.teamAWicketKeeperId,
        teamBWicketKeeperId: data.teamBWicketKeeperId,
        hasImpactPlayer: data.hasImpactPlayer ?? false,
        customOvers: resolvedCustomOvers,
        ballType: data.ballType, scheduledAt: new Date(data.scheduledAt), venueName: resolvedVenueName,
        facilityId: resolvedFacilityId, academyId: data.academyId,
        tournamentId: data.tournamentId, scorerId: player?.id ?? null,
        isRanked: data.matchType === 'RANKED',
        liveCode,
        livePin,
      },
    })
  }

  async recordToss(matchId: string, userId: string, tossWonBy: string, tossDecision: string, options: MutationOptions = {}) {
    const match = await this.authorizeMutation(matchId, userId, options)
    if (match.status !== 'SCHEDULED') throw new AppError('INVALID_STATE', 'Match must be in SCHEDULED state', 400)
    const updated = await prisma.match.update({
      where: { id: matchId },
      data: { tossWonBy, tossDecision, status: 'TOSS_DONE' },
    })
    fireStudioEvent(matchId, TriggerEventType.TOSS_DONE)
    return updated
  }

  async startMatch(matchId: string, userId: string, options: MutationOptions = {}) {
    const match = await this.authorizeMutation(matchId, userId, options)
    if (!['SCHEDULED', 'TOSS_DONE'].includes(match.status)) {
      throw new AppError('INVALID_STATE', 'Cannot start match in current state', 400)
    }
    await this.ensureMatchCanStart(match)
    let battingTeam = 'A'
    if (match.tossWonBy && match.tossDecision === 'BAT') battingTeam = match.tossWonBy
    else if (match.tossWonBy && match.tossDecision === 'BOWL') battingTeam = match.tossWonBy === 'A' ? 'B' : 'A'

    const existingInnings = await prisma.innings.findUnique({
      where: { matchId_inningsNumber: { matchId, inningsNumber: 1 } },
    })
    await prisma.match.update({ where: { id: matchId }, data: { status: 'IN_PROGRESS', startedAt: new Date() } })
    if (!existingInnings) {
      await prisma.innings.create({ data: { matchId, inningsNumber: 1, battingTeam } })
    }
    fireStudioEvent(matchId, TriggerEventType.MATCH_STARTED)

    // Notify followers of all players in this match
    this.notifyMatchFollowers(matchId, match.teamAName ?? 'Team A', match.teamBName ?? 'Team B').catch(() => {})

    return prisma.match.findUnique({ where: { id: matchId }, include: { innings: true } })
  }

  async updateScorer(
    matchId: string,
    userId: string,
    scorerId: string,
    options: MutationOptions = {},
  ) {
    const match = await prisma.match.findUnique({ where: { id: matchId } })
    if (!match) throw Errors.notFound('Match')

    if (['COMPLETED', 'CANCELLED'].includes(match.status)) {
      throw new AppError('INVALID_STATE', 'Cannot change scorer for this match', 400)
    }

    const normalizedScorerId = `${scorerId}`.trim()
    if (!normalizedScorerId) {
      throw new AppError('INVALID_SCORER', 'scorerId is required', 400)
    }

    const access = options.access ?? 'SCORER'
    const participatingIds = new Set(
      [...(match.teamAPlayerIds ?? []), ...(match.teamBPlayerIds ?? [])]
        .map((id) => `${id}`.trim())
        .filter(Boolean),
    )

    if (access === 'ADMIN') {
      await this.verifyAdminUser(userId)
    } else {
      const requester = await prisma.playerProfile.findUnique({
        where: { userId },
        select: { id: true, userId: true },
      })
      if (!requester) throw Errors.forbidden()

      const requesterIsParticipant =
        participatingIds.size === 0 ||
        participatingIds.has(requester.id) ||
        participatingIds.has(requester.userId)

      if (match.scorerId && match.scorerId !== requester.id) {
        throw new AppError('NOT_SCORER', 'Only the scorer can update this match', 403)
      }
      if (!match.scorerId && !requesterIsParticipant) {
        throw new AppError(
          'NOT_SCORER',
          'Only players in this match can assign the scorer',
          403,
        )
      }
    }

    const scorerProfile = await prisma.playerProfile.findFirst({
      where: {
        OR: [
          { id: normalizedScorerId },
          { userId: normalizedScorerId },
        ],
      },
      select: { id: true, userId: true },
    })
    if (!scorerProfile) {
      throw new AppError('INVALID_SCORER', 'Selected scorer was not found', 400)
    }

    // Restriction removed: Scorer no longer needs to be a participant in the match
    // This allows non-playing members, admins, or external scorers.

    return prisma.match.update({
      where: { id: matchId },
      data: { scorerId: scorerProfile.id },
    })
  }

  async cancelMatch(matchId: string, userId: string, options: MutationOptions = {}) {
    const match = await this.authorizeMutation(matchId, userId, options)
    if (!['SCHEDULED', 'TOSS_DONE', 'CREATED'].includes(match.status)) {
      throw new AppError(
        'INVALID_STATE',
        'Only matches that have not started can be cancelled',
        400,
      )
    }

    return prisma.match.update({
      where: { id: matchId },
      data: {
        status: 'CANCELLED',
        completedAt: new Date(),
        winnerId: null,
        winMargin: 'Cancelled before start',
      },
    })
  }

  async deleteMatch(matchId: string, userId: string, options: MutationOptions = {}) {
    const match = await this.authorizeMutation(matchId, userId, options)
    const allPlayerIds = [...match.teamAPlayerIds, ...match.teamBPlayerIds]

    await prisma.$transaction(async (tx) => {
      await Promise.all([
        tx.matchView.deleteMany({ where: { matchId } }),
        tx.performanceMatchReview.updateMany({
          where: { matchId },
          data: { matchId: null },
        }),
        tx.profileShowcaseItem.updateMany({
          where: { matchId },
          data: { matchId: null },
        }),
        tx.slotBooking.updateMany({
          where: { matchId },
          data: { matchId: null },
        }),
        tx.matchmakingQueue.updateMany({
          where: { matchId },
          data: { matchId: null },
        }),
        tx.eliteInsight.updateMany({
          where: { matchId },
          data: { matchId: null },
        }),
        tx.playerBadge.updateMany({
          where: { matchId },
          data: { matchId: null },
        }),
        tx.playerMilestone.updateMany({
          where: { matchId },
          data: { matchId: null },
        }),
        tx.playerPhysicalSample.deleteMany({
          where: { sourceType: 'MATCH_PROXY', sourceRefId: matchId },
        }),
        tx.playerWorkloadEvent.deleteMany({
          where: { source: 'MATCH_PROXY', sourceRefId: matchId },
        }),
      ])

      await tx.overlayStudio.updateMany({
        where: { matchId },
        data: { activeSceneId: null },
      })
      await tx.studioAdQueue.deleteMany({ where: { studio: { matchId } } })
      await tx.studioScheduledSceneSwitch.deleteMany({ where: { studio: { matchId } } })
      await tx.overlayTrigger.deleteMany({ where: { studio: { matchId } } })
      await tx.adSlot.deleteMany({ where: { studio: { matchId } } })
      await tx.overlayScene.deleteMany({ where: { studio: { matchId } } })
      await tx.overlayStudio.deleteMany({ where: { matchId } })

      await tx.ballEvent.deleteMany({ where: { innings: { matchId } } })
      await tx.innings.deleteMany({ where: { matchId } })

      await tx.playerMatchStats.deleteMany({ where: { matchId } })
      await tx.matchPlayerFact.deleteMany({ where: { matchId } })
      await tx.matchPlayerMetric.deleteMany({ where: { matchId } })
      await tx.matchPlayerIndexScore.deleteMany({ where: { matchId } })
      await tx.playerLeadershipSample.deleteMany({ where: { matchId } })

      await tx.match.delete({ where: { id: matchId } })
    })

    // Rebuild IP + badges from remaining facts for all affected players.
    // We await this now to ensure consistency, though we catch errors to not block the response.
    if (allPlayerIds.length > 0) {
      const rebuildWithRetry = async (attempt = 0) => {
        try {
          await performanceService.rebuildPlayersFromCurrentFacts(allPlayerIds)
        } catch (err) {
          if (attempt < 2) {
            console.warn(`[deleteMatch] Post-delete rebuild failed (attempt ${attempt + 1}), retrying...`, { matchId, err })
            await new Promise(resolve => setTimeout(resolve, 1000 * (attempt + 1)))
            return rebuildWithRetry(attempt + 1)
          }
          console.error('[deleteMatch] Post-delete rebuild failed after all retries', { matchId, err })
        }
      }
      
      // We still don't block the main response for the rebuild, but we use a more robust background execution
      rebuildWithRetry()
    }

    return { deleted: matchId }
  }

  async recordBall(matchId: string, inningsNum: number, userId: string, data: any, options: MutationOptions = {}) {
    const match = await this.authorizeMutation(matchId, userId, options)
    const innings = await prisma.innings.findUnique({ where: { matchId_inningsNumber: { matchId, inningsNumber: inningsNum } } })
    if (!innings) throw Errors.notFound('Innings')
    if (innings.isCompleted) throw new AppError('INNINGS_COMPLETED', 'Innings is already completed', 400)
    const existingBalls = await prisma.ballEvent.findMany({
      where: { inningsId: innings.id },
      orderBy: [
        { overNumber: 'asc' },
        { ballNumber: 'asc' },
        { scoredAt: 'asc' },
        { id: 'asc' },
      ],
    })
    const snapshot = this.buildInningsSnapshot(existingBalls)
    const maxOvers = this.resolveMaxOvers(match)
    const isMultiInnings = ['TWO_INNINGS', 'TEST'].includes(match.format)
    const targetRuns = await this.resolveTargetRuns(matchId, innings.battingTeam, inningsNum, isMultiInnings)
    const effectiveState = {
      currentStrikerId: innings.currentStrikerId ?? snapshot.currentStrikerId,
      currentNonStrikerId: innings.currentNonStrikerId ?? snapshot.currentNonStrikerId,
      currentBowlerId: innings.currentBowlerId ?? snapshot.currentBowlerId,
    }
    const selections = resolveBallSelections({
      batterId: data.batterId,
      nonBatterId: data.nonBatterId,
      bowlerId: data.bowlerId,
      currentStrikerId: effectiveState.currentStrikerId,
      currentNonStrikerId: effectiveState.currentNonStrikerId,
      currentBowlerId: effectiveState.currentBowlerId,
    })
    const normalizedWagonZone = normalizeWagonZone(data.wagonZone)

    if (!selections.batterId || !selections.bowlerId) {
      throw new AppError(
        'INVALID_SCORING_SELECTION',
        'Striker and bowler are required before recording a ball',
        400,
      )
    }

    const candidateBall = {
      ...data,
      batterId: selections.batterId,
      nonBatterId: selections.nonBatterId,
      bowlerId: selections.bowlerId,
      wagonZone: normalizedWagonZone,
    }

    this.assertValidScoringBall({
      currentLegalBalls: snapshot.legalBalls,
      maxLegalBalls: maxOvers * 6,
      currentWickets: snapshot.totalWickets,
      currentRuns: snapshot.totalRuns,
      targetRuns,
      ball: candidateBall,
      isFreeHit: snapshot.isFreeHit,
    })

    this.validateInningsSelections({
      match,
      innings,
      batterId: candidateBall.batterId,
      nonBatterId: candidateBall.nonBatterId,
      bowlerId: candidateBall.bowlerId,
      fielderId: candidateBall.fielderId,
      dismissedPlayerId: candidateBall.dismissedPlayerId,
    })

    const derivedOverNumber = Math.floor(snapshot.legalBalls / 6)
    const derivedBallNumber = (snapshot.legalBalls % 6) + 1

    const ballEvent = await prisma.ballEvent.create({
      data: {
        inningsId: innings.id, overNumber: derivedOverNumber, ballNumber: derivedBallNumber,
        batterId: candidateBall.batterId,
        nonBatterId: candidateBall.nonBatterId,
        bowlerId: candidateBall.bowlerId,
        fielderId: candidateBall.fielderId,
        outcome: candidateBall.outcome,
        runs: candidateBall.runs || 0,
        extras: candidateBall.extras || 0,
        totalRuns: (candidateBall.runs || 0) + (candidateBall.extras || 0),
        isWicket: candidateBall.isWicket || false,
        isOverthrow: candidateBall.isOverthrow || false,
        overthrowRuns: candidateBall.overthrowRuns || 0,
        dismissalType: candidateBall.dismissalType,
        dismissedPlayerId: candidateBall.dismissedPlayerId,
        wagonZone: candidateBall.wagonZone,
        shotType: candidateBall.shotType,
        ballLine: candidateBall.ballLine,
        ballLength: candidateBall.ballLength,
        tags: [
          ...(candidateBall.tags || []),
          ...(candidateBall.switchEnds ? ['transition:switch-ends'] : []),
        ],
        isOfflineEntry: candidateBall.isOfflineEntry || false,
      },
    })
    const { innings: updatedInnings } = await this.rebuildInningsState(innings.id)
    const scoreAfter = `${updatedInnings.totalRuns}/${updatedInnings.totalWickets}`

    if (data.isWicket) fireStudioEvent(matchId, TriggerEventType.WICKET_FALLEN)
    if (updatedInnings.currentBowlerId == null) fireStudioEvent(matchId, TriggerEventType.OVER_COMPLETED)

    return { ballEvent, innings: updatedInnings, scoreAfter }
  }

  async undoLastBall(matchId: string, inningsNum: number, userId: string, options: MutationOptions = {}) {
    await this.authorizeMutation(matchId, userId, options)
    const innings = await prisma.innings.findUnique({ where: { matchId_inningsNumber: { matchId, inningsNumber: inningsNum } } })
    if (!innings) throw Errors.notFound('Innings')

    const lastBall = await prisma.ballEvent.findFirst({
      where: { inningsId: innings.id },
      orderBy: [{ scoredAt: 'desc' }, { id: 'desc' }],
    })
    if (!lastBall) throw new AppError('NO_BALLS', 'No balls to undo', 400)

    await prisma.ballEvent.delete({ where: { id: lastBall.id } })
    const { innings: updated, needNewBowler } = await this.rebuildInningsState(innings.id)
    return { innings: updated, removed: lastBall, needNewBowler }
  }

  async updateBall(matchId: string, ballId: string, userId: string, data: any, options: MutationOptions = {}) {
    const match = await this.authorizeMutation(matchId, userId, options)

    const ball = await prisma.ballEvent.findUnique({ where: { id: ballId }, include: { innings: true } })
    if (!ball) throw Errors.notFound('Ball event')
    if (ball.innings.matchId !== matchId) throw new AppError('FORBIDDEN', 'Ball does not belong to this match', 403)

    const inningsBalls = await prisma.ballEvent.findMany({
      where: { inningsId: ball.inningsId },
      orderBy: [{ scoredAt: 'asc' }, { id: 'asc' }],
    })
    const ballIndex = inningsBalls.findIndex((entry) => entry.id === ballId)
    if (ballIndex < 0) throw Errors.notFound('Ball event')

    const nextIsWicket = data.isWicket ?? ball.isWicket
    const requestedDismissal =
      data.dismissalType === undefined ? ball.dismissalType : data.dismissalType
    const nextDismissal =
      nextIsWicket
        ? requestedDismissal
        : (requestedDismissal === 'RETIRED_HURT' || requestedDismissal === 'RETIRED_OUT'
            ? requestedDismissal
            : null)
    const nextFielderIdBase =
      data.fielderId === undefined ? ball.fielderId : data.fielderId
    const nextFielderId =
      nextDismissal === 'CAUGHT_AND_BOWLED'
        ? ball.bowlerId
        : (nextIsWicket || nextDismissal === 'RETIRED_HURT' || nextDismissal === 'RETIRED_OUT'
            ? nextFielderIdBase
            : null)
    const nextDismissedPlayerId =
      nextIsWicket || nextDismissal === 'RETIRED_HURT' || nextDismissal === 'RETIRED_OUT'
        ? (data.dismissedPlayerId === undefined
            ? ball.dismissedPlayerId
            : data.dismissedPlayerId)
        : null

    const candidateBall = {
      outcome: data.outcome ?? ball.outcome,
      runs: data.runs ?? ball.runs,
      extras: data.extras ?? ball.extras,
      isWicket: nextIsWicket,
      dismissalType: nextDismissal,
      dismissedPlayerId: nextDismissedPlayerId,
      bowlerId: ball.bowlerId,
      fielderId: nextFielderId,
      tags: ball.tags,
    }
    const snapshot = this.buildInningsSnapshot(inningsBalls.slice(0, ballIndex))
    const isMultiInnings = ['TWO_INNINGS', 'TEST'].includes(match.format)
    const targetRuns = await this.resolveTargetRuns(
      matchId, ball.innings.battingTeam, ball.innings.inningsNumber, isMultiInnings,
    )

    this.assertValidScoringBall({
      currentLegalBalls: snapshot.legalBalls,
      maxLegalBalls: this.resolveMaxOvers(match) * 6,
      currentWickets: snapshot.totalWickets,
      currentRuns: snapshot.totalRuns,
      targetRuns,
      ball: candidateBall,
      isFreeHit: snapshot.isFreeHit,
    })
    this.validateInningsSelections({
      match,
      innings: ball.innings,
      batterId: ball.batterId,
      nonBatterId: ball.nonBatterId,
      bowlerId: ball.bowlerId,
      fielderId: nextFielderId,
      dismissedPlayerId: nextDismissedPlayerId,
    })

    await prisma.ballEvent.update({
      where: { id: ballId },
      data: {
        outcome: candidateBall.outcome,
        runs: candidateBall.runs,
        extras: candidateBall.extras,
        totalRuns: (candidateBall.runs ?? 0) + (candidateBall.extras ?? 0),
        isWicket: candidateBall.isWicket,
        dismissalType: candidateBall.dismissalType,
        dismissedPlayerId: candidateBall.dismissedPlayerId,
        fielderId: candidateBall.fielderId,
        wagonZone: data.wagonZone === undefined
          ? normalizeWagonZone(ball.wagonZone)
          : normalizeWagonZone(data.wagonZone),
        shotType: data.shotType === undefined ? ball.shotType : data.shotType,
        ballLine: data.ballLine === undefined ? ball.ballLine : data.ballLine,
        ballLength: data.ballLength === undefined ? ball.ballLength : data.ballLength,
      },
    })
    const { innings: updated } = await this.rebuildInningsState(ball.inningsId)
    return { innings: updated }
  }

  async setInningsState(matchId: string, inningsNum: number, userId: string, data: {
    strikerId?: string | null, nonStrikerId?: string | null, bowlerId?: string | null
  }, options: MutationOptions = {}) {
    const match = await this.authorizeMutation(matchId, userId, options)
    const innings = await prisma.innings.findUnique({ where: { matchId_inningsNumber: { matchId, inningsNumber: inningsNum } } })
    if (!innings) throw Errors.notFound('Innings')
    const battingIds = new Set(innings.battingTeam === 'A' ? match.teamAPlayerIds : match.teamBPlayerIds)
    const bowlingIds = new Set(innings.battingTeam === 'A' ? match.teamBPlayerIds : match.teamAPlayerIds)
    const validateSide = (label: string, playerId: string | null | undefined, allowedIds: Set<string>) => {
      if (!playerId || allowedIds.size === 0) return
      if (!allowedIds.has(playerId)) {
        throw new AppError('INVALID_SCORING_SELECTION', `${label} does not belong to the current innings side`, 400)
      }
    }
    validateSide('Striker', data.strikerId, battingIds)
    validateSide('Non-striker', data.nonStrikerId, battingIds)
    validateSide('Bowler', data.bowlerId, bowlingIds)
    if (data.strikerId && data.nonStrikerId && data.strikerId === data.nonStrikerId) {
      throw new AppError('INVALID_SCORING_SELECTION', 'Striker and non-striker must be different players', 400)
    }
    return prisma.innings.update({
      where: { id: innings.id },
      data: {
        currentStrikerId: data.strikerId !== undefined ? data.strikerId : undefined,
        currentNonStrikerId: data.nonStrikerId !== undefined ? data.nonStrikerId : undefined,
        currentBowlerId: data.bowlerId !== undefined ? data.bowlerId : undefined,
      },
    })
  }

  async completeInnings(matchId: string, inningsNum: number, userId: string, options: MutationOptions = {}) {
    console.log('[completeInnings] matchId=%s inningsNum=%d userId=%s', matchId, inningsNum, userId)
    await this.authorizeMutation(matchId, userId, options)
    const innings = await prisma.innings.findUnique({ where: { matchId_inningsNumber: { matchId, inningsNumber: inningsNum } } })
    console.log('[completeInnings] found innings=%o', innings ? { id: innings.id, isCompleted: innings.isCompleted, totalRuns: innings.totalRuns, totalWickets: innings.totalWickets } : null)
    if (!innings) throw Errors.notFound('Innings')
    await prisma.innings.update({ where: { id: innings.id }, data: { isCompleted: true } })

    const match = await prisma.match.findUnique({ where: { id: matchId }, include: { innings: { orderBy: { inningsNumber: 'asc' } } } })
    if (!match) return { message: 'Innings completed' }

    const isMultiInnings = ['TWO_INNINGS', 'TEST'].includes(match.format)

    if (!isMultiInnings) {
      // Limited overs: after innings 1, create innings 2 for the other team
      if (inningsNum === 1) {
        await prisma.innings.create({ data: { matchId, inningsNumber: 2, battingTeam: innings.battingTeam === 'A' ? 'B' : 'A' } })
      }
    } else {
      // Test / two-innings: up to 4 innings
      if (inningsNum === 1) {
        // Innings 2: other team bats
        await prisma.innings.create({ data: { matchId, inningsNumber: 2, battingTeam: innings.battingTeam === 'A' ? 'B' : 'A' } })
      } else if (inningsNum === 2) {
        // Check if follow-on applicable (team 2 trails by 200+ in a test)
        const inn1 = match.innings.find(i => i.inningsNumber === 1)
        const inn2 = match.innings.find(i => i.inningsNumber === 2)
        const followOnThreshold = match.format === 'TEST' ? 200 : 150

        if (inn1 && inn2) {
          const deficit = inn1.totalRuns - inn2.totalRuns
          if (deficit >= followOnThreshold) {
            return {
              message: 'Innings completed',
              followOnAvailable: true,
              followOnDeficit: deficit,
              suggestion: `Follow-on available (${deficit} run deficit). Call /followon to enforce or /continue-innings to continue normally.`,
            }
          }
        }
        // No follow-on or deficit below threshold: create innings 3 automatically
        // Team 1 bats again
        await prisma.innings.create({ data: { matchId, inningsNumber: 3, battingTeam: inn1?.battingTeam ?? 'A' } })
      } else if (inningsNum === 3) {
        // Innings 4: other team bats
        await prisma.innings.create({ data: { matchId, inningsNumber: 4, battingTeam: innings.battingTeam === 'A' ? 'B' : 'A' } })
      }
    }
    fireStudioEvent(matchId, TriggerEventType.INNINGS_COMPLETED)
    return { message: 'Innings completed' }
  }

  async continueInnings(matchId: string, userId: string, options: MutationOptions = {}) {
    await this.authorizeMutation(matchId, userId, options)
    const match = await prisma.match.findUnique({
      where: { id: matchId },
      include: { innings: { orderBy: { inningsNumber: 'asc' } } },
    })
    if (!match) throw Errors.notFound('Match')
    const completedInnings = match.innings.filter((innings) => innings.isCompleted)
    const nextNum = completedInnings.length + 1
    const existing = await prisma.innings.findUnique({
      where: { matchId_inningsNumber: { matchId, inningsNumber: nextNum } },
    })
    if (existing) throw new AppError('INVALID_STATE', 'Next innings already exists', 400)
    const lastCompleted = completedInnings[completedInnings.length - 1]
    if (!lastCompleted) throw new AppError('INVALID_STATE', 'No completed innings found', 400)
    const nextBattingTeam = lastCompleted.battingTeam === 'A' ? 'B' : 'A'
    await prisma.innings.create({ data: { matchId, inningsNumber: nextNum, battingTeam: nextBattingTeam } })
    return this.getMatch(matchId)
  }

  async reopenInnings(matchId: string, inningsNum: number, userId: string, options: MutationOptions = {}) {
    await this.authorizeMutation(matchId, userId, options)
    const innings = await prisma.innings.findUnique({
      where: { matchId_inningsNumber: { matchId, inningsNumber: inningsNum } },
    })
    if (!innings) throw Errors.notFound('Innings')
    await prisma.innings.update({ where: { id: innings.id }, data: { isCompleted: false } })
    await prisma.match.update({
      where: { id: matchId },
      data: { status: 'IN_PROGRESS', completedAt: null, winnerId: null, winMargin: null },
    })
    return this.getMatch(matchId)
  }

  async enforceFollowOn(matchId: string, userId: string, options: MutationOptions = {}) {
    await this.authorizeMutation(matchId, userId, options)
    const match = await prisma.match.findUnique({ where: { id: matchId }, include: { innings: true } })
    if (!match) throw Errors.notFound('Match')
    const inn2 = match.innings.find(i => i.inningsNumber === 2)
    if (!inn2?.isCompleted) throw new AppError('INVALID_STATE', 'Innings 2 must be completed first', 400)
    const existingInnings3 = match.innings.find(i => i.inningsNumber === 3)
    if (existingInnings3) throw new AppError('INVALID_STATE', 'Innings 3 already exists', 400)
    // Follow-on: same team bats again (innings 2 batting team bats innings 3)
    await prisma.innings.create({ data: { matchId, inningsNumber: 3, battingTeam: inn2.battingTeam } })
    return { message: 'Follow-on enforced' }
  }

  async createSuperOver(matchId: string, userId: string, options: MutationOptions = {}) {
    await this.authorizeMutation(matchId, userId, options)
    const match = await prisma.match.findUnique({ where: { id: matchId }, include: { innings: { orderBy: { inningsNumber: 'asc' } } } })
    if (!match) throw Errors.notFound('Match')
    if (match.status !== 'IN_PROGRESS') throw new AppError('INVALID_STATE', 'Match must be in progress', 400)
    const regularInnings = match.innings.filter(i => !i.isSuperOver)
    const lastInn = regularInnings[regularInnings.length - 1]
    if (!lastInn?.isCompleted) throw new AppError('INVALID_STATE', 'All regular innings must be completed first', 400)
    const superOverInnings = match.innings.filter(i => i.isSuperOver)
    const nextSuperNum = match.innings.length + 1
    // Team that batted second in regular innings bats first in super over
    const soTeam1 = lastInn.battingTeam
    const soTeam2 = soTeam1 === 'A' ? 'B' : 'A'
    const [so1, so2] = await Promise.all([
      prisma.innings.create({ data: { matchId, inningsNumber: nextSuperNum, battingTeam: soTeam1, isSuperOver: true } }),
      prisma.innings.create({ data: { matchId, inningsNumber: nextSuperNum + 1, battingTeam: soTeam2, isSuperOver: true } }),
    ])
    return { message: 'Super over innings created', superOverInnings: [so1, so2] }
  }

  async changeWicketKeeper(matchId: string, userId: string, team: 'A' | 'B', wicketKeeperId: string, options: MutationOptions = {}) {
    await this.authorizeMutation(matchId, userId, options)
    const data = team === 'A'
      ? { teamAWicketKeeperId: wicketKeeperId }
      : { teamBWicketKeeperId: wicketKeeperId }
    return prisma.match.update({ where: { id: matchId }, data })
  }

  async completeMatch(matchId: string, userId: string, winnerId: string, winMargin?: string, options: MutationOptions = {}) {
    console.log('[completeMatch] matchId=%s userId=%s winnerId="%s" winMargin="%s"', matchId, userId, winnerId, winMargin)
    const match = await this.authorizeMutation(matchId, userId, options)
    console.log('[completeMatch] match status=%s innings count=%d', match.status, (match as any).innings?.length ?? 'N/A')
    if (match.status !== 'IN_PROGRESS') {
      console.error('[completeMatch] REJECT — match status is "%s", expected IN_PROGRESS', match.status)
      throw new AppError('MATCH_NOT_ACTIVE', 'Match is not in progress', 400)
    }
    await prisma.innings.updateMany({ where: { matchId }, data: { isCompleted: true } })
    console.log('[completeMatch] all innings marked completed, computing stats…')
    await this.computePlayerStats(matchId)
    await prisma.match.update({ where: { id: matchId }, data: { status: 'COMPLETED', completedAt: new Date(), winnerId, winMargin } })
    console.log('[completeMatch] match marked COMPLETED')
    const statsResult = await performanceService.processVerifiedMatch(matchId, { allowUnverified: true })
    if (!statsResult.processed) {
      console.error('[completeMatch] Stats generation failed', { matchId, reason: statsResult.reason })
    }
    fireStudioEvent(matchId, TriggerEventType.MATCH_COMPLETED)
    return prisma.match.findUnique({ where: { id: matchId }, include: { innings: true, playerMatchStats: true } })
  }

  async getMatch(matchId: string) {
    const match = await prisma.match.findUnique({
      where: { id: matchId },
      include: {
        innings: {
          include: {
            ballEvents: {
              orderBy: [
                { overNumber: 'asc' },
                { ballNumber: 'asc' },
                { scoredAt: 'asc' },
                { id: 'asc' },
              ],
            },
          },
        },
        playerMatchStats: true,
      },
    })
    if (!match) throw Errors.notFound('Match')

    if (!match.liveCode || !match.livePin) {
      const liveCode = match.liveCode ?? (await this.generateUniqueMatchLiveCode())
      const livePin = match.livePin ?? this.generateMatchLivePin()
      await prisma.match.update({
        where: { id: matchId },
        data: { liveCode, livePin },
      })
      match.liveCode = liveCode
      match.livePin = livePin
    }

    return this.enrichMatchReadModel(match)
  }

  async getPreview(matchId: string) {
    const match = await prisma.match.findUnique({
      where: { id: matchId },
      include: {
        innings: { where: { isSuperOver: false }, orderBy: { inningsNumber: 'asc' } },
      },
    })
    if (!match) throw Errors.notFound('Match')

    const [teams, tournament] = await Promise.all([
      prisma.team.findMany({
        where: { name: { in: [match.teamAName, match.teamBName] } },
        select: { name: true, logoUrl: true, shortName: true },
      }),
      match.tournamentId
        ? prisma.tournament.findUnique({
            where: { id: match.tournamentId },
            select: { name: true, format: true, tournamentFormat: true, logoUrl: true, slug: true, city: true },
          })
        : Promise.resolve(null),
    ])

    const logoByName = new Map(teams.map(t => [t.name, { logoUrl: t.logoUrl, shortName: t.shortName }]))

    let tossText: string | null = null
    if (match.tossWonBy && match.tossDecision) {
      const tossTeam = match.tossWonBy === 'A' ? match.teamAName : match.teamBName
      const decision = match.tossDecision === 'BAT' ? 'elected to bat' : 'elected to bowl'
      tossText = `${tossTeam} won the toss and ${decision}`
    }

    return {
      id: match.id,
      status: match.status,
      matchType: match.matchType,
      format: match.format,
      round: match.round,
      venueName: match.venueName,
      scheduledAt: match.scheduledAt,
      startedAt: match.startedAt,
      completedAt: match.completedAt,
      tossText,
      winner: match.winnerId,
      winMargin: match.winMargin,
      teamA: {
        name: match.teamAName,
        shortName: logoByName.get(match.teamAName)?.shortName ?? null,
        logoUrl: logoByName.get(match.teamAName)?.logoUrl ?? null,
        captainId: match.teamACaptainId,
      },
      teamB: {
        name: match.teamBName,
        shortName: logoByName.get(match.teamBName)?.shortName ?? null,
        logoUrl: logoByName.get(match.teamBName)?.logoUrl ?? null,
        captainId: match.teamBCaptainId,
      },
      innings: match.innings.map(inn => ({
        inningsNumber: inn.inningsNumber,
        battingTeam: inn.battingTeam,
        teamName: inn.battingTeam === 'A' ? match.teamAName : match.teamBName,
        runs: inn.totalRuns,
        wickets: inn.totalWickets,
        overs: inn.totalOvers.toFixed(1),
        isCompleted: inn.isCompleted,
      })),
      tournament,
    }
  }

  async getScorecard(matchId: string) {
    const match = await prisma.match.findUnique({
      where: { id: matchId },
      include: {
        innings: {
          include: {
            ballEvents: {
              orderBy: [
                { overNumber: 'asc' },
                { ballNumber: 'asc' },
                { scoredAt: 'asc' },
                { id: 'asc' },
              ],
            },
          },
          orderBy: { inningsNumber: 'asc' },
        },
      },
    })
    if (!match) throw Errors.notFound('Match')
    const competitive = await performanceService.getMatchCompetitiveSummary(matchId)

    // Collect all player IDs from ball events for name resolution
    const allIds = new Set<string>()
    for (const inn of match.innings) {
      for (const b of inn.ballEvents) {
        allIds.add(b.batterId)
        allIds.add(b.bowlerId)
        if (b.fielderId) allIds.add(b.fielderId)
        if (b.dismissedPlayerId) allIds.add(b.dismissedPlayerId)
      }
    }

    const [profiles, teams] = await Promise.all([
      prisma.playerProfile.findMany({
        where: { id: { in: [...allIds] } },
        include: { user: { select: { name: true } } },
      }),
      prisma.team.findMany({
        where: { name: { in: [match.teamAName, match.teamBName] } },
        select: { name: true, logoUrl: true, shortName: true },
      }),
    ])

    const nameById = new Map(profiles.map(p => [p.id, p.user.name]))
    const logoByName = new Map(teams.map(t => [t.name, { logoUrl: t.logoUrl, shortName: t.shortName }]))
    const name = (id: string | null | undefined) => (id ? (nameById.get(id) ?? 'Unknown') : 'Unknown')

    const innings = match.innings
      .filter(inn => !inn.isSuperOver)
      .map(inn => {
        // Compute stats live from ball events — works for both in-progress and completed matches
        const innsStats = buildInningsPlayerStats({
          balls: inn.ballEvents,
          battingTeam: inn.battingTeam,
          currentStrikerId: inn.currentStrikerId,
          currentNonStrikerId: inn.currentNonStrikerId,
          currentBowlerId: inn.currentBowlerId,
        })

        const batting = [...innsStats.batterStats.values()]
          .sort((a, b) => (a.battingPosition ?? 999) - (b.battingPosition ?? 999))
          .map(s => ({
            playerId: s.playerProfileId,
            player: name(s.playerProfileId),
            runs: s.runs, balls: s.balls, fours: s.fours, sixes: s.sixes,
            strikeRate: s.strikeRate,
            isOut: s.isOut,
            dismissalType: s.dismissalType,
            isStriker: s.playerProfileId === innsStats.strikerId,
            milestones: s.milestones,
          }))

        const bowling = [...innsStats.bowlerStats.values()]
          .sort((a, b) => b.wickets - a.wickets || a.runs - b.runs)
          .map(s => ({
            playerId: s.playerProfileId,
            player: name(s.playerProfileId),
            overs: s.overs.toFixed(1),
            wickets: s.wickets, runs: s.runs,
            economy: s.economy,
            wides: s.wides, noBalls: s.noBalls,
            isCurrentBowler: s.playerProfileId === innsStats.currentBowlerId,
          }))

        // Fall of wickets — derived from ordered ball events
        let fow_runs = 0
        let fow_wickets = 0
        const fallOfWickets: Array<{ wicket: number; score: string; player: string; over: string }> = []
        for (const ball of inn.ballEvents) {
          fow_runs += ball.totalRuns ?? 0
          if (isInningsWicket(ball) && ball.dismissedPlayerId) {
            fow_wickets++
            fallOfWickets.push({
              wicket: fow_wickets,
              score: `${fow_runs}/${fow_wickets}`,
              player: name(ball.dismissedPlayerId),
              over: `${ball.overNumber + 1}.${ball.ballNumber}`,
            })
          }
        }

        // Partnerships — runs scored between consecutive wickets
        const partnerships: Array<{ batter1: string; batter2: string; runs: number; balls: number }> = []
        {
          let pRuns = 0, pBalls = 0
          let activeBatter1: string | null = null, activeBatter2: string | null = null
          for (const ball of inn.ballEvents) {
            if (activeBatter1 === null) activeBatter1 = name(ball.batterId)
            if (activeBatter2 === null && ball.bowlerId) activeBatter2 = '—'
            pRuns += ball.totalRuns ?? 0
            if (isLegalDelivery(ball.outcome, ball.dismissalType)) pBalls++
            if (isInningsWicket(ball)) {
              partnerships.push({ batter1: activeBatter1 ?? '—', batter2: activeBatter2 ?? '—', runs: pRuns, balls: pBalls })
              pRuns = 0; pBalls = 0
              activeBatter1 = ball.dismissedPlayerId ? name(ball.batterId === ball.dismissedPlayerId ? (ball.fielderId ?? ball.batterId) : ball.batterId) : activeBatter1
              activeBatter2 = null
            }
          }
          if (pRuns > 0 || pBalls > 0) {
            partnerships.push({ batter1: activeBatter1 ?? '—', batter2: activeBatter2 ?? '—', runs: pRuns, balls: pBalls })
          }
        }

        const teamName = inn.battingTeam === 'A' ? match.teamAName : match.teamBName
        const liveSnapshot = this.buildInningsSnapshot(inn.ballEvents)
        return {
          inningsNumber: inn.inningsNumber,
          battingTeam: inn.battingTeam,
          teamName,
          score: `${liveSnapshot.totalRuns}/${liveSnapshot.totalWickets}`,
          overs: liveSnapshot.totalOvers.toFixed(1),
          totalOvers: liveSnapshot.totalOvers,
          totalRuns: liveSnapshot.totalRuns,
          totalWickets: liveSnapshot.totalWickets,
          extras: liveSnapshot.extras,
          currentStrikerId: innsStats.strikerId,
          currentNonStrikerId: innsStats.nonStrikerId,
          currentBowlerId: innsStats.currentBowlerId,
          ballEvents: inn.ballEvents,
          extras: inn.extras,
          isCompleted: inn.isCompleted,
          batting, bowling, fallOfWickets, partnerships,
        }
      })

    return {
      matchId: match.id,
      status: match.status,
      format: match.format,
      teamA: {
        name: match.teamAName,
        shortName: logoByName.get(match.teamAName)?.shortName ?? null,
        logoUrl: logoByName.get(match.teamAName)?.logoUrl ?? null,
      },
      teamB: {
        name: match.teamBName,
        shortName: logoByName.get(match.teamBName)?.shortName ?? null,
        logoUrl: logoByName.get(match.teamBName)?.logoUrl ?? null,
      },
      winner: match.winnerId,
      winMargin: match.winMargin,
      competitive,
      innings,
    }
  }

  async getHighlights(matchId: string) {
    const match = await prisma.match.findUnique({
      where: { id: matchId },
      include: {
        innings: {
          where: { isSuperOver: false },
          include: {
            ballEvents: {
              orderBy: [
                { overNumber: 'asc' },
                { ballNumber: 'asc' },
                { scoredAt: 'asc' },
                { id: 'asc' },
              ],
            },
          },
          orderBy: { inningsNumber: 'asc' },
        },
      },
    })
    if (!match) throw Errors.notFound('Match')

    const allIds = new Set<string>()
    for (const inn of match.innings) {
      for (const b of inn.ballEvents) {
        allIds.add(b.batterId); allIds.add(b.bowlerId)
        if (b.fielderId) allIds.add(b.fielderId)
        if (b.dismissedPlayerId) allIds.add(b.dismissedPlayerId)
      }
    }

    const profiles = await prisma.playerProfile.findMany({
      where: { id: { in: [...allIds] } },
      include: { user: { select: { name: true } } },
    })
    const nameById = new Map(profiles.map(p => [p.id, p.user.name]))
    const name = (id: string | null | undefined) => (id ? (nameById.get(id) ?? 'Unknown') : 'Unknown')

    const highlights: { type: string; description: string; inningsNumber: number; over?: string }[] = []

    for (const inn of match.innings) {
      const battingTeamName = inn.battingTeam === 'A' ? match.teamAName : match.teamBName
      const bowlingTeamName = inn.battingTeam === 'A' ? match.teamBName : match.teamAName
      const innsStats = buildInningsPlayerStats({ balls: inn.ballEvents, battingTeam: inn.battingTeam })

      // Batting milestones
      for (const [id, stats] of innsStats.batterStats.entries()) {
        if (stats.milestones.includes('HUNDRED')) {
          highlights.push({ type: 'HUNDRED', description: `${name(id)} scores a century (${stats.runs} off ${stats.balls} balls) for ${battingTeamName}`, inningsNumber: inn.inningsNumber })
        } else if (stats.milestones.includes('FIFTY')) {
          highlights.push({ type: 'FIFTY', description: `${name(id)} scores a half-century (${stats.runs} off ${stats.balls} balls) for ${battingTeamName}`, inningsNumber: inn.inningsNumber })
        }
      }

      // Best bowling performance
      let bestBowler: { id: string; wickets: number; runs: number } | null = null
      for (const [id, stats] of innsStats.bowlerStats.entries()) {
        if (!bestBowler || stats.wickets > bestBowler.wickets || (stats.wickets === bestBowler.wickets && stats.runs < bestBowler.runs)) {
          bestBowler = { id, wickets: stats.wickets, runs: stats.runs }
        }
      }
      if (bestBowler && bestBowler.wickets >= 3) {
        highlights.push({ type: 'BOWLING_HAUL', description: `${name(bestBowler.id)} takes ${bestBowler.wickets}/${bestBowler.runs} for ${bowlingTeamName}`, inningsNumber: inn.inningsNumber })
      }

      // Key ball events
      for (const ball of inn.ballEvents) {
        const over = `${ball.overNumber + 1}.${ball.ballNumber}`
        if (ball.outcome === 'SIX') {
          highlights.push({ type: 'SIX', description: `${name(ball.batterId)} hits a SIX off ${name(ball.bowlerId)}`, inningsNumber: inn.inningsNumber, over })
        }
        if (isInningsWicket(ball)) {
          const dismissed = name(ball.dismissedPlayerId ?? ball.batterId)
          const fielder = ball.fielderId ? ` (${name(ball.fielderId)})` : ''
          highlights.push({ type: 'WICKET', description: `${dismissed} dismissed — ${ball.dismissalType?.replace(/_/g, ' ') ?? 'out'}${fielder}, bowled by ${name(ball.bowlerId)}`, inningsNumber: inn.inningsNumber, over })
        }
      }
    }

    // Top performers summary
    const topScorer = [...match.innings].flatMap(inn => {
      const stats = buildInningsPlayerStats({ balls: inn.ballEvents, battingTeam: inn.battingTeam })
      return [...stats.batterStats.entries()].map(([id, s]) => ({ id, runs: s.runs, balls: s.balls, team: inn.battingTeam }))
    }).sort((a, b) => b.runs - a.runs)[0]

    const topWicketTaker = [...match.innings].flatMap(inn => {
      const stats = buildInningsPlayerStats({ balls: inn.ballEvents, battingTeam: inn.battingTeam })
      return [...stats.bowlerStats.entries()].map(([id, s]) => ({ id, wickets: s.wickets, runs: s.runs }))
    }).sort((a, b) => b.wickets - a.wickets || a.runs - b.runs)[0]

    return {
      matchId: match.id,
      status: match.status,
      topScorer: topScorer ? { name: name(topScorer.id), runs: topScorer.runs, balls: topScorer.balls } : null,
      topWicketTaker: topWicketTaker ? { name: name(topWicketTaker.id), wickets: topWicketTaker.wickets, runs: topWicketTaker.runs } : null,
      highlights,
    }
  }

  async getCommentary(matchId: string, opts: { inningsNum?: number; overNum?: number; limit?: number; offset?: number }) {
    const match = await prisma.match.findUnique({
      where: { id: matchId },
      select: { id: true, teamAName: true, teamBName: true, status: true },
    })
    if (!match) throw Errors.notFound('Match')

    const innings = await prisma.innings.findMany({
      where: { matchId, ...(opts.inningsNum !== undefined ? { inningsNumber: opts.inningsNum } : {}) },
      orderBy: { inningsNumber: 'asc' },
    })

    if (innings.length === 0) return { matchId, commentary: [] }

    const balls = await prisma.ballEvent.findMany({
      where: {
        inningsId: { in: innings.map(i => i.id) },
        ...(opts.overNum !== undefined ? { overNumber: opts.overNum } : {}),
      },
      orderBy: [
        { overNumber: 'desc' },
        { ballNumber: 'desc' },
        { scoredAt: 'desc' },
        { id: 'desc' },
      ],
      take: opts.limit ?? 50,
      skip: opts.offset ?? 0,
    })

    const allIds = new Set<string>()
    for (const b of balls) {
      allIds.add(b.batterId); allIds.add(b.bowlerId)
      if (b.fielderId) allIds.add(b.fielderId)
      if (b.dismissedPlayerId) allIds.add(b.dismissedPlayerId)
    }

    const profiles = await prisma.playerProfile.findMany({
      where: { id: { in: [...allIds] } },
      include: { user: { select: { name: true } } },
    })
    const nameById = new Map(profiles.map(p => [p.id, p.user.name]))
    const inningsByIds = new Map(innings.map(i => [i.id, i]))

    return {
      matchId,
      total: await prisma.ballEvent.count({ where: { inningsId: { in: innings.map(i => i.id) } } }),
      commentary: balls.map(ball => {
        const inn = inningsByIds.get(ball.inningsId)!
        return {
          inningsNumber: inn.inningsNumber,
          over: `${ball.overNumber + 1}.${ball.ballNumber}`,
          overNumber: ball.overNumber,
          ballNumber: ball.ballNumber,
          batter: nameById.get(ball.batterId) ?? 'Unknown',
          bowler: nameById.get(ball.bowlerId) ?? 'Unknown',
          outcome: ball.outcome,
          runs: ball.runs,
          extras: ball.extras,
          totalRuns: ball.totalRuns,
          isWicket: isInningsWicket(ball),
          dismissalType: ball.dismissalType ?? null,
          dismissedPlayer: ball.dismissedPlayerId ? (nameById.get(ball.dismissedPlayerId) ?? 'Unknown') : null,
          fielder: ball.fielderId ? (nameById.get(ball.fielderId) ?? 'Unknown') : null,
          scoreAfterBall: ball.scoreAfterBall,
          teamName: inn.battingTeam === 'A' ? match.teamAName : match.teamBName,
          text: this.buildCommentaryText(ball, nameById),
          wagonZone: normalizeWagonZone((ball as any).wagonZone),
          tags: ball.tags,
          scoredAt: ball.scoredAt,
        }
      }),
    }
  }

  async getPlayers(matchId: string) {
    const match = await prisma.match.findUnique({
      where: { id: matchId },
      include: {
        playerMatchStats: {
          select: { playerProfileId: true, isOut: true },
        },
      },
    })
    if (!match) throw Errors.notFound('Match')

    const statsByProfileId = new Map(
      match.playerMatchStats.map(stat => [stat.playerProfileId, stat.isOut]),
    )

    const [teamAPlayers, teamBPlayers, teams] = await Promise.all([
      this.resolveMatchPlayers(match.teamAPlayerIds, statsByProfileId),
      this.resolveMatchPlayers(match.teamBPlayerIds, statsByProfileId),
      prisma.team.findMany({
        where: { name: { in: [match.teamAName, match.teamBName] } },
        select: { id: true, name: true, logoUrl: true, shortName: true },
      }),
    ])

    const teamMetaByName = new Map(teams.map(t => [t.name, { id: t.id, logoUrl: t.logoUrl, shortName: t.shortName }]))

    // For SCHEDULED matches, return a simplified format as requested by frontend
    if (match.status === 'SCHEDULED') {
      return {
        teamA: {
          id: teamMetaByName.get(match.teamAName)?.id ?? null,
          name: match.teamAName,
          players: teamAPlayers.map(p => ({ profileId: p.profileId, name: p.name })),
          captainId: match.teamACaptainId,
          viceCaptainId: match.teamAViceCaptainId ?? null,
          wicketKeeperId: match.teamAWicketKeeperId ?? null,
        },
        teamB: {
          id: teamMetaByName.get(match.teamBName)?.id ?? null,
          name: match.teamBName,
          players: teamBPlayers.map(p => ({ profileId: p.profileId, name: p.name })),
          captainId: match.teamBCaptainId,
          viceCaptainId: match.teamBViceCaptainId ?? null,
          wicketKeeperId: match.teamBWicketKeeperId ?? null,
        },
      }
    }

    return {
      teamA: {
        id: teamMetaByName.get(match.teamAName)?.id ?? null,
        name: match.teamAName,
        shortName: teamMetaByName.get(match.teamAName)?.shortName ?? null,
        logoUrl: teamMetaByName.get(match.teamAName)?.logoUrl ?? null,
        captainId: match.teamACaptainId,
        viceCaptainId: match.teamAViceCaptainId ?? null,
        wicketKeeperId: match.teamAWicketKeeperId ?? null,
        players: teamAPlayers,
      },
      teamB: {
        id: teamMetaByName.get(match.teamBName)?.id ?? null,
        name: match.teamBName,
        shortName: teamMetaByName.get(match.teamBName)?.shortName ?? null,
        logoUrl: teamMetaByName.get(match.teamBName)?.logoUrl ?? null,
        captainId: match.teamBCaptainId,
        viceCaptainId: match.teamBViceCaptainId ?? null,
        wicketKeeperId: match.teamBWicketKeeperId ?? null,
        players: teamBPlayers,
      },
    }
  }

  async getOverSummary(matchId: string, inningsNum: number, overNum: number) {
    const innings = await prisma.innings.findUnique({ where: { matchId_inningsNumber: { matchId, inningsNumber: inningsNum } } })
    if (!innings) throw Errors.notFound('Innings')
    const balls = await prisma.ballEvent.findMany({
      where: { inningsId: innings.id, overNumber: overNum },
      orderBy: [{ ballNumber: 'asc' }, { scoredAt: 'asc' }, { id: 'asc' }],
    })
    return {
      overNumber: overNum,
      balls,
      runs: balls.reduce((s, b) => s + b.totalRuns, 0),
      wickets: balls.filter(b => isInningsWicket(b)).length,
      extras: balls.reduce((s, b) => s + b.extras, 0),
    }
  }

  async getAnalysis(matchId: string) {
    const match = await prisma.match.findUnique({
      where: { id: matchId },
      include: {
        innings: {
          include: { ballEvents: { orderBy: [{ overNumber: 'asc' }, { ballNumber: 'asc' }, { scoredAt: 'asc' }, { id: 'asc' }] } },
          orderBy: { inningsNumber: 'asc' },
        },
      },
    })
    if (!match) throw Errors.notFound('Match')

    const allIds = new Set<string>()
    for (const inn of match.innings) {
      for (const b of inn.ballEvents) {
        allIds.add(b.batterId)
        allIds.add(b.bowlerId)
      }
    }
    const profiles = await prisma.playerProfile.findMany({
      where: { id: { in: [...allIds] } },
      include: { user: { select: { name: true } } },
    })
    const nameById = new Map(profiles.map(p => [p.id, p.user.name]))

    const analysisInnings = match.innings.map(inn => {
      const overMap = new Map<number, { runs: number; wickets: number; balls: number }>()
      const wagonWheel: Array<{ over: string; runs: number; isWicket: boolean; zone: string | null; batter: string }> = []

      for (const ball of inn.ballEvents) {
        const ov = overMap.get(ball.overNumber) ?? { runs: 0, wickets: 0, balls: 0 }
        ov.runs += ball.totalRuns ?? 0
        if (isLegalDelivery(ball.outcome, ball.dismissalType)) ov.balls++
        if (isInningsWicket(ball)) ov.wickets++
        overMap.set(ball.overNumber, ov)

        // Use dedicated wagonZone field; fall back to legacy tags format "zone:cover"
        const zoneRaw = (ball as any).wagonZone
          ?? (ball.tags as string[] | null)?.find((t: string) => t.startsWith('zone:'))?.replace('zone:', '')
          ?? null
        const zone = normalizeWagonZone(zoneRaw)
        wagonWheel.push({
          over: `${ball.overNumber + 1}.${ball.ballNumber}`,
          runs: ball.runs ?? 0,
          isWicket: isInningsWicket(ball),
          zone,
          batter: nameById.get(ball.batterId) ?? 'Unknown',
        })
      }

      let cumRuns = 0
      const overStats = Array.from(overMap.entries())
        .sort(([a], [b]) => a - b)
        .map(([overNum, stats]) => {
          cumRuns += stats.runs
          const rr = stats.balls > 0 ? Math.round((stats.runs / stats.balls) * 600) / 100 : 0
          return { over: overNum + 1, runs: stats.runs, wickets: stats.wickets, runRate: rr, cumulativeRuns: cumRuns }
        })

      return {
        inningsNumber: inn.inningsNumber,
        battingTeam: inn.battingTeam === 'A' ? match.teamAName : match.teamBName,
        overStats,
        wagonWheel,
      }
    })

    return { matchId, innings: analysisInnings }
  }

  async verifyMatch(matchId: string) {
    const updated = await prisma.match.update({ where: { id: matchId }, data: { verificationLevel: 'LEVEL_1', verifiedAt: new Date() } })
    await performanceService.processVerifiedMatch(matchId)
    return updated
  }

  private buildCommentaryText(ball: any, nameById: Map<string, string>): string {
    const n = (id: string | null | undefined) => (id ? (nameById.get(id) ?? 'Unknown') : 'Unknown')
    const batter = n(ball.batterId)
    const bowler = n(ball.bowlerId)
    const over = `${ball.overNumber + 1}.${ball.ballNumber}`

    if (isInningsWicket(ball)) {
      const dismissed = n(ball.dismissedPlayerId ?? ball.batterId)
      const fielder = ball.fielderId ? n(ball.fielderId) : null
      switch (ball.dismissalType) {
        case 'BOWLED': return `${over} — ${bowler} bowls ${dismissed}! Stumps shattered.`
        case 'CAUGHT': return `${over} — ${dismissed} is caught${fielder ? ` by ${fielder}` : ''} off ${bowler}!`
        case 'CAUGHT_BEHIND': return `${over} — ${dismissed} feathers behind and is taken${fielder ? ` by ${fielder}` : ' by the keeper'} off ${bowler}!`
        case 'CAUGHT_AND_BOWLED': return `${over} — ${dismissed} is caught and bowled by ${bowler}!`
        case 'LBW': return `${over} — ${dismissed} is out LBW! ${bowler} gets the wicket.`
        case 'RUN_OUT': return `${over} — ${dismissed} is run out${fielder ? ` (${fielder})` : ''}! Brilliant fielding.`
        case 'STUMPED': return `${over} — ${dismissed} is stumped${fielder ? ` by ${fielder}` : ''} off ${bowler}!`
        case 'HIT_WICKET': return `${over} — ${dismissed} is out hit wicket off ${bowler}! Unfortunate.`
        default: return `${over} — ${dismissed} is dismissed (${ball.dismissalType?.replace(/_/g, ' ') ?? 'out'}) off ${bowler}.`
      }
    }

    switch (ball.outcome) {
      case 'SIX': return `${over} — SIX! ${batter} clears the boundary off ${bowler}!`
      case 'FOUR': return `${over} — FOUR! ${batter} finds the gap off ${bowler}.`
      case 'FIVE': return `${over} — 5 runs! ${batter} and the non-striker sprint back for a rare five.`
      case 'WIDE': return `${over} — Wide by ${bowler}. Extra run added.`
      case 'NO_BALL': return `${over} — No ball from ${bowler}! Free hit on the next delivery.`
      case 'DOT': return `${over} — Dot ball. ${bowler} beats ${batter}.`
      case 'SINGLE': return `${over} — 1 run. ${batter} rotates strike off ${bowler}.`
      case 'DOUBLE': return `${over} — 2 runs. Good running by ${batter}.`
      case 'TRIPLE': return `${over} — 3 runs! Excellent running between the wickets.`
      case 'BYE': return `${over} — Bye! ${ball.extras} extra${ball.extras !== 1 ? 's' : ''}.`
      case 'LEG_BYE': return `${over} — Leg bye! ${ball.extras} extra${ball.extras !== 1 ? 's' : ''}.`
      default: return `${over} — ${ball.runs} run${ball.runs !== 1 ? 's' : ''} off ${bowler} to ${batter}.`
    }
  }

  private async computePlayerStats(matchId: string) {
    const match = await prisma.match.findUnique({ where: { id: matchId }, include: { innings: { include: { ballEvents: true } } } })
    if (!match) return

    const statsMap = buildMatchPlayerStats(
      match.innings.map((innings) => ({
        battingTeam: innings.battingTeam,
        balls: innings.ballEvents,
      })),
    )

    for (const [, stats] of statsMap) {
      const { legalBallsBowled, milestones, ...persistedStats } = stats
      await prisma.playerMatchStats.upsert({
        where: { matchId_playerProfileId: { matchId, playerProfileId: stats.playerProfileId } },
        create: { matchId, ...persistedStats },
        update: persistedStats,
      })
    }
  }

  // IP/Swing/state updates are driven by PerformanceService.processVerifiedMatch().
  // Legacy IP-engine awarding path has been retired.

  private async generateUniqueMatchLiveCode() {
    for (let i = 0; i < 50; i++) {
      const num = Math.floor(1000 + Math.random() * 9000)
      const candidate = `swing#${num}`
      const exists = await prisma.match.findFirst({
        where: { liveCode: candidate },
        select: { id: true },
      })
      if (!exists) return candidate
    }

    throw new AppError(
      'LIVE_ACCESS_GENERATION_FAILED',
      'Unable to generate a unique live access code for this match',
      500,
    )
  }

  private generateMatchLivePin() {
    return String(Math.floor(1000 + Math.random() * 9000))
  }

  private async resolveMatchPlayers(ids: string[], statsByProfileId: Map<string, boolean>) {
    if (ids.length === 0) return []

    const profiles = await prisma.playerProfile.findMany({
      where: {
        OR: [
          { id: { in: ids } },
          { userId: { in: ids } },
        ],
      },
      include: {
        user: { select: { id: true, name: true, avatarUrl: true } },
      },
    })

    const byRequestedId = new Map<string, { userId: string; profileId: string; name: string; avatarUrl: string | null; isOut: boolean }>()
    for (const profile of profiles) {
      const payload = {
        userId: profile.user.id,
        profileId: profile.id,
        name: profile.user.name,
        avatarUrl: profile.user.avatarUrl,
        isOut: statsByProfileId.get(profile.id) ?? false,
      }
      byRequestedId.set(profile.id, payload)
      byRequestedId.set(profile.user.id, payload)
    }

    return ids
      .map(id => byRequestedId.get(id))
      .filter((player): player is NonNullable<typeof player> => Boolean(player))
  }

  // Notify followers of all players in a match when it goes live
  private async notifyMatchFollowers(matchId: string, teamAName: string, teamBName: string) {
    const match = await prisma.match.findUnique({ where: { id: matchId }, select: { teamAPlayerIds: true, teamBPlayerIds: true } })
    if (!match) return

    const allPlayerProfileIds = [...match.teamAPlayerIds, ...match.teamBPlayerIds]
    if (allPlayerProfileIds.length === 0) return

    // Get all followers of all players in the match
    const follows = await prisma.playerFollow.findMany({
      where: { followingPlayerId: { in: allPlayerProfileIds } },
      include: { follower: { select: { userId: true } } },
    })

    // Deduplicate by userId so one follower doesn't get multiple notifications
    const notifiedUserIds = new Set<string>()
    for (const follow of follows) {
      if (notifiedUserIds.has(follow.follower.userId)) continue
      notifiedUserIds.add(follow.follower.userId)
      notificationSvc.createNotification(follow.follower.userId, {
        type: 'MATCH_LIVE',
        title: 'Match is live 🏏',
        body: `${teamAName} vs ${teamBName} has started`,
        entityType: 'MATCH',
        entityId: matchId,
        sendPush: true,
        preferenceKey: 'matchResults',
      }).catch(() => {})
    }
  }

  async getRecommendedMatches(userId: string, limit = 10) {
    const profile = await prisma.playerProfile.findUnique({
      where: { userId },
      select: { id: true },
    })

    if (!profile) return []

    // 1. People the user follows
    const followingPlayerIds = (
      await prisma.playerFollow.findMany({
        where: { followerPlayerId: profile.id },
        select: { followingPlayerId: true },
      })
    ).map((f) => f.followingPlayerId)

    // 2. Teams the user follows
    const followingTeamIds = (
      await prisma.follow.findMany({
        where: { followerId: profile.id, targetType: 'TEAM' },
        select: { targetId: true },
      })
    ).map((f) => f.targetId)

    // 3. People they may know (played with/against in last 5 matches)
    const recentMatchIds = (
      await prisma.matchPlayerFact.findMany({
        where: { playerId: profile.id },
        select: { matchId: true },
        orderBy: { matchDate: 'desc' },
        take: 5,
      })
    ).map((m) => m.matchId)

    let mayKnowPlayerIds: string[] = []
    if (recentMatchIds.length > 0) {
      mayKnowPlayerIds = (
        await prisma.matchPlayerFact.findMany({
          where: {
            matchId: { in: recentMatchIds },
            playerId: { not: profile.id },
          },
          select: { playerId: true },
        })
      ).map((m) => m.playerId)
    }

    const allRelevantPlayerIds = Array.from(new Set([...followingPlayerIds, ...mayKnowPlayerIds]))

    // Find upcoming or live matches involving these players or teams
    // Excluding matches where the user themselves is playing
    const matches = await prisma.match.findMany({
      where: {
        status: { in: ['SCHEDULED', 'TOSS_DONE', 'IN_PROGRESS'] },
        AND: [
          {
            OR: [
              { teamAPlayerIds: { hasSome: allRelevantPlayerIds } },
              { teamBPlayerIds: { hasSome: allRelevantPlayerIds } },
              // Since we don't have teamId directly on Match, we'll need to match by team name if we had it,
              // but followingTeamIds are IDs. Let's check if we can resolve team names for these IDs.
            ],
          },
          {
            NOT: {
              OR: [{ teamAPlayerIds: { has: profile.id } }, { teamBPlayerIds: { has: profile.id } }],
            },
          },
        ],
      },
      orderBy: { scheduledAt: 'asc' },
      take: limit * 2, // Take extra to filter/sort
    })

    // If we have followed teams, we should also try to find matches by teamId.
    // However, Match model doesn't have teamAId/teamBId, it has teamAName/teamBName.
    // This is a limitation of the current schema unless we find where teamId is stored.
    // Actually, looking at Match model in schema.prisma, it doesn't have team IDs.
    // But PlayerMatchStats and MatchPlayerFact HAVE matchId and playerId.

    // Let's refine the "matches involving followed teams" part.
    // We can find matches from MatchPlayerFact where teamId is in the followingTeamIds list.
    let teamMatchIds: string[] = []
    if (followingTeamIds.length > 0) {
      // Note: teamId in match_player_facts seems to be a NAME (string) based on my query earlier.
      // Wait, let me check the Team model again.
      // In Team model: id is cuid, name is string.
      // In MatchPlayerFact: teamId is string.
      
      // Let's find the names of the teams the user follows.
      const teamNames = (await prisma.team.findMany({
        where: { id: { in: followingTeamIds } },
        select: { name: true }
      })).map(t => t.name)

      if (teamNames.length > 0) {
        const teamMatches = await prisma.match.findMany({
          where: {
            status: { in: ['SCHEDULED', 'TOSS_DONE', 'IN_PROGRESS'] },
            OR: [
              { teamAName: { in: teamNames } },
              { teamBName: { in: teamNames } }
            ],
            NOT: {
              OR: [
                { teamAPlayerIds: { has: profile.id } },
                { teamBPlayerIds: { has: profile.id } }
              ]
            }
          },
          select: { id: true }
        })
        teamMatchIds = teamMatches.map(m => m.id)
      }
    }

    const allMatchIds = Array.from(new Set([...matches.map(m => m.id), ...teamMatchIds]))
    
    // Fetch full match details for all identified IDs
    const recommendedMatches = await prisma.match.findMany({
      where: { id: { in: allMatchIds } },
      orderBy: [
        { status: 'desc' }, // IN_PROGRESS first
        { scheduledAt: 'asc' }
      ],
      take: limit
    })

    return recommendedMatches
  }

  async scheduleMatch(userId: string, data: any) {
    const player = await prisma.playerProfile.findUnique({ where: { userId } })
    const scheduledAt = new Date(data.scheduledAt)
    if (scheduledAt <= new Date()) {
      throw new AppError('INVALID_DATE', 'Schedule time must be in the future', 400)
    }

    let resolvedVenueName = data.venueName?.trim() || null
    let resolvedFacilityId = data.facilityId?.trim() || null
    const resolvedCustomOvers =
      data.format === 'CUSTOM' && Number.isFinite(data.customOvers)
        ? Number(data.customOvers)
        : null

    if (resolvedFacilityId) {
      const arena = await prisma.arena.findUnique({
        where: { id: resolvedFacilityId },
        select: { id: true, name: true },
      })
      if (!arena) {
        throw new AppError('INVALID_FACILITY', 'Selected arena was not found', 400)
      }
      resolvedVenueName = arena.name
      resolvedFacilityId = arena.id
    }

    const teamAPlayerIds = await this.resolvePlayingXIPlayerIds(data.teamA?.playerIds || [])
    const teamBPlayerIds = await this.resolvePlayingXIPlayerIds(data.teamB?.playerIds || [])

    if (teamAPlayerIds.length > 0 && teamBPlayerIds.length > 0) {
      const overlappingPlayerIds = teamAPlayerIds.filter((playerId) => teamBPlayerIds.includes(playerId))
      if (overlappingPlayerIds.length > 0) {
        throw new AppError('INVALID_PLAYING_XI', 'A player cannot be listed in both teams', 400)
      }
    }

    if (teamAPlayerIds.length === 11) {
      this.validatePlayingXI(
        'Team A',
        teamAPlayerIds,
        data.teamA.captainId,
        data.teamA.viceCaptainId,
        data.teamA.wicketKeeperId,
      )
    }

    if (teamBPlayerIds.length === 11) {
      this.validatePlayingXI(
        'Team B',
        teamBPlayerIds,
        data.teamB.captainId,
        data.teamB.viceCaptainId,
        data.teamB.wicketKeeperId,
      )
    }

    const liveCode = await this.generateUniqueMatchLiveCode()
    const livePin = this.generateMatchLivePin()

    const match = await prisma.match.create({
      data: {
        matchType: data.matchType === 'COMPETITIVE' ? 'RANKED' : data.matchType,
        format: data.format,
        status: 'SCHEDULED',
        teamAName: data.teamAName,
        teamBName: data.teamBName,
        teamAPlayerIds,
        teamBPlayerIds,
        teamACaptainId: data.teamA?.captainId || null,
        teamBCaptainId: data.teamB?.captainId || null,
        teamAViceCaptainId: data.teamA?.viceCaptainId || null,
        teamBViceCaptainId: data.teamB?.viceCaptainId || null,
        teamAWicketKeeperId: data.teamA?.wicketKeeperId || null,
        teamBWicketKeeperId: data.teamB?.wicketKeeperId || null,
        hasImpactPlayer: data.hasImpactPlayer ?? false,
        customOvers: resolvedCustomOvers,
        ballType: data.ballType,
        scheduledAt,
        venueName: resolvedVenueName,
        facilityId: resolvedFacilityId,
        tournamentId: data.tournamentId || null,
        scorerId: player?.id ?? null,
        isRanked: data.matchType === 'COMPETITIVE' || data.matchType === 'RANKED',
        liveCode,
        livePin,
      },
    })

    return match
  }

  async updateMatchPlayers(matchId: string, userId: string, data: any) {
    const match = await this.authorizeMutation(matchId, userId)
    if (match.status !== 'SCHEDULED') {
      throw new AppError('INVALID_STATE', 'Only scheduled matches can have their playing XI updated', 400)
    }

    const teamAPlayerIds = await this.resolvePlayingXIPlayerIds(data.teamA?.playerIds || [])
    const teamBPlayerIds = await this.resolvePlayingXIPlayerIds(data.teamB?.playerIds || [])

    if (teamAPlayerIds.length > 0 && teamBPlayerIds.length > 0) {
      const overlappingPlayerIds = teamAPlayerIds.filter((playerId) => teamBPlayerIds.includes(playerId))
      if (overlappingPlayerIds.length > 0) {
        throw new AppError('INVALID_PLAYING_XI', 'A player cannot be listed in both teams', 400)
      }
    }

    if (teamAPlayerIds.length === 11) {
      this.validatePlayingXI(
        'Team A',
        teamAPlayerIds,
        data.teamA.captainId,
        data.teamA.viceCaptainId,
        data.teamA.wicketKeeperId,
      )
    }

    if (teamBPlayerIds.length === 11) {
      this.validatePlayingXI(
        'Team B',
        teamBPlayerIds,
        data.teamB.captainId,
        data.teamB.viceCaptainId,
        data.teamB.wicketKeeperId,
      )
    }

    const updated = await prisma.match.update({
      where: { id: matchId },
      data: {
        teamAPlayerIds,
        teamBPlayerIds,
        teamACaptainId: data.teamA?.captainId || null,
        teamBCaptainId: data.teamB?.captainId || null,
        teamAViceCaptainId: data.teamA?.viceCaptainId || null,
        teamBViceCaptainId: data.teamB?.viceCaptainId || null,
        teamAWicketKeeperId: data.teamA?.wicketKeeperId || null,
        teamBWicketKeeperId: data.teamB?.wicketKeeperId || null,
      },
    })

    return {
      matchId: updated.id,
      teamA: {
        playerIds: updated.teamAPlayerIds,
        captainId: updated.teamACaptainId,
        viceCaptainId: updated.teamAViceCaptainId,
        wicketKeeperId: updated.teamAWicketKeeperId,
      },
      teamB: {
        playerIds: updated.teamBPlayerIds,
        captainId: updated.teamBCaptainId,
        viceCaptainId: updated.teamBViceCaptainId,
        wicketKeeperId: updated.teamBWicketKeeperId,
      },
    }
  }
}
