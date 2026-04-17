import { prisma } from '@swing/db'
import { AppError, Errors } from '../../lib/errors'
import { PerformanceService } from '../performance/performance.service'

const ACTIVE_ATTENDANCE_STATUSES = ['PRESENT', 'LATE', 'WALK_IN', 'EARLY_EXIT'] as const
const DEFAULT_RADAR_SKILLS = ['Footwork', 'Defence', 'Mental composure', 'Line & length consistency', 'Fielding']

function normalizeSessionType(value?: string | null) {
  const normalized = (value ?? '').trim().toUpperCase().replace(/[\s-]+/g, '_')
  switch (normalized) {
    case 'BATTING_NETS':
      return 'PACE_NETS'
    case 'BOWLING_NETS':
      return 'SPIN_NETS'
    case 'MATCH_SIMULATION':
      return 'MATCH_PRACTICE'
    case 'STRENGTH_&_CONDITIONING':
    case 'STRENGTH_AND_CONDITIONING':
      return 'FITNESS'
    case 'VIDEO_REVIEW':
    case 'FITNESS':
    case 'FIELDING':
      return normalized
    case 'PACE_NETS':
    case 'SPIN_NETS':
    case 'THROWDOWN':
    case 'POWER_HITTING':
    case 'MATCH_PRACTICE':
    case 'CUSTOM':
      return normalized
    default:
      return 'CUSTOM'
  }
}

function startOfDay(date: Date) {
  return new Date(date.getFullYear(), date.getMonth(), date.getDate())
}

export class DevelopmentService {
  private readonly performanceService = new PerformanceService()

  async listSessionTypes() {
    return prisma.sessionTypeConfig.findMany({
      where: { isActive: true },
      orderBy: { name: 'asc' },
    })
  }

  async listSkillAreas(roleTag?: string) {
    return prisma.skillArea.findMany({
      where: {
        isActive: true,
        ...(roleTag ? { roleTag: roleTag as any } : {}),
      },
      orderBy: { name: 'asc' },
    })
  }

  async listWatchFlags(roleTag?: string) {
    return prisma.watchFlag.findMany({
      where: {
        isActive: true,
        ...(roleTag ? { roleTag: roleTag as any } : {}),
      },
      orderBy: [{ severity: 'desc' }, { name: 'asc' }],
    })
  }

  async createSessionType(data: { name: string; color: string; defaultDurationMinutes?: number; isActive?: boolean }) {
    return prisma.sessionTypeConfig.create({
      data: {
        name: data.name,
        color: data.color,
        defaultDurationMinutes: data.defaultDurationMinutes ?? 90,
        isActive: data.isActive ?? true,
      },
    })
  }

  async updateSessionType(id: string, data: { name?: string; color?: string; defaultDurationMinutes?: number; isActive?: boolean }) {
    return prisma.sessionTypeConfig.update({ where: { id }, data })
  }

  async deleteSessionType(id: string) {
    return prisma.sessionTypeConfig.delete({ where: { id } })
  }

  async createSkillArea(data: { name: string; roleTag: 'BATSMAN' | 'BOWLER' | 'ALL_ROUNDER' | 'FIELDER' | 'WICKET_KEEPER'; isActive?: boolean }) {
    return prisma.skillArea.create({ data: { name: data.name, roleTag: data.roleTag, isActive: data.isActive ?? true } })
  }

  async updateSkillArea(id: string, data: { name?: string; roleTag?: 'BATSMAN' | 'BOWLER' | 'ALL_ROUNDER' | 'FIELDER' | 'WICKET_KEEPER'; isActive?: boolean }) {
    return prisma.skillArea.update({ where: { id }, data })
  }

  async deleteSkillArea(id: string) {
    return prisma.skillArea.delete({ where: { id } })
  }

  async createWatchFlag(data: { name: string; roleTag: 'BATSMAN' | 'BOWLER' | 'ALL_ROUNDER' | 'FIELDER' | 'WICKET_KEEPER'; severity?: 'MONITOR' | 'URGENT'; description?: string; isActive?: boolean }) {
    return prisma.watchFlag.create({
      data: {
        name: data.name,
        roleTag: data.roleTag,
        severity: data.severity ?? 'MONITOR',
        description: data.description,
        isActive: data.isActive ?? true,
      },
    })
  }

  async updateWatchFlag(id: string, data: { name?: string; roleTag?: 'BATSMAN' | 'BOWLER' | 'ALL_ROUNDER' | 'FIELDER' | 'WICKET_KEEPER'; severity?: 'MONITOR' | 'URGENT'; description?: string; isActive?: boolean }) {
    return prisma.watchFlag.update({ where: { id }, data })
  }

  async deleteWatchFlag(id: string) {
    return prisma.watchFlag.delete({ where: { id } })
  }

  async updateDrill(id: string, data: {
    name?: string
    description?: string
    videoUrl?: string | null
    roleTags?: Array<'BATSMAN' | 'BOWLER' | 'ALL_ROUNDER' | 'FIELDER' | 'WICKET_KEEPER'>
    category?: 'TECHNIQUE' | 'FITNESS' | 'MENTAL' | 'MATCH_SIMULATION'
    targetUnit?: 'BALLS' | 'OVERS' | 'MINUTES' | 'REPS' | 'SESSIONS'
    isActive?: boolean
  }) {
    const payload: typeof data & { videoUrl?: string | null } = { ...data }
    if (payload.videoUrl !== undefined) {
      payload.videoUrl = payload.videoUrl?.trim() || null
    }
    return prisma.drill.update({ where: { id }, data: payload as any })
  }

  async deleteDrill(id: string) {
    return prisma.drill.delete({ where: { id } })
  }

  private async getCoach(userId: string) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    if (!coach) throw Errors.forbidden()
    return coach
  }

  private async getPlayerByUser(userId: string) {
    const player = await prisma.playerProfile.findUnique({ where: { userId } })
    if (!player) throw Errors.notFound('Player profile')
    return player
  }

  private async getPlayer(playerProfileId: string) {
    const player = await prisma.playerProfile.findUnique({
      where: { id: playerProfileId },
      include: { user: { select: { name: true, avatarUrl: true } } },
    })
    if (!player) throw Errors.notFound('Player profile')
    return player
  }

  private async assertCoachAccessToPlayer(coachId: string, playerProfileId: string) {
    const enrollment = await prisma.academyEnrollment.findFirst({
      where: {
        playerProfileId,
        isActive: true,
        OR: [
          { primaryCoachId: coachId },
          { batch: { primaryCoachId: coachId } },
          { academy: { coaches: { some: { coachId, isActive: true } } } },
        ],
      },
    })
    if (!enrollment) throw Errors.forbidden()
    return enrollment
  }

  private async assertCanViewPlayer(userId: string, playerProfileId: string) {
    const player = await prisma.playerProfile.findUnique({ where: { userId } })
    if (player?.id === playerProfileId) return
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    if (coach) {
      await this.assertCoachAccessToPlayer(coach.id, playerProfileId)
      return
    }
    throw Errors.forbidden()
  }

  private async buildAttendanceRoster(sessionId: string) {
    const session = await prisma.practiceSession.findUnique({
      where: { id: sessionId },
      include: {
        batch: true,
        academy: true,
        sessionTypeConfig: true,
        attendances: {
          include: { playerProfile: { include: { user: { select: { name: true, avatarUrl: true } } } } },
        },
      },
    })
    if (!session) throw Errors.notFound('Session')

    const roster = await prisma.academyEnrollment.findMany({
      where: {
        isActive: true,
        ...(session.batchId
          ? { batchId: session.batchId }
          : session.academyId
            ? { academyId: session.academyId }
            : { id: '__none__' }),
      },
      include: {
        playerProfile: {
          include: { user: { select: { name: true, avatarUrl: true } } },
        },
      },
      orderBy: { playerProfile: { user: { name: 'asc' } } },
    })

    const attendanceByPlayer = new Map(
      session.attendances.map(attendance => [attendance.playerProfileId, attendance]),
    )

    return {
      session,
      attendance: roster.map(enrollment => {
        const attendance = attendanceByPlayer.get(enrollment.playerProfileId)
        return {
          playerId: enrollment.playerProfileId,
          playerName: enrollment.playerProfile.user.name,
          avatarUrl: enrollment.playerProfile.user.avatarUrl,
          role: enrollment.playerProfile.playerRole,
          status: attendance?.status ?? 'UNSET',
          joinMethod: attendance?.joinMethod ?? null,
          markedAt: attendance?.markedAt ?? attendance?.scannedAt ?? null,
          selfJoined: attendance?.joinMethod === 'QR' || attendance?.joinMethod === 'SELF_APP',
        }
      }),
    }
  }

  async createSession(userId: string, data: {
    academyId?: string
    batchId?: string
    sessionTypeId?: string
    sessionTypeName?: string
    scheduledAt?: string
    durationMinutes?: number
    locationName?: string
    notes?: string
  }) {
    const coach = await this.getCoach(userId)
    let batch = null as null | { id: string; academyId: string; name: string }
    if (data.batchId) {
      batch = await prisma.batch.findUnique({
        where: { id: data.batchId },
        select: { id: true, academyId: true, name: true },
      })
      if (!batch) throw Errors.notFound('Batch')
      const academyCoach = await prisma.academyCoach.findFirst({
        where: { academyId: batch.academyId, coachId: coach.id, isActive: true },
      })
      if (!academyCoach) throw Errors.forbidden()
    }

    const sessionTypeConfig = data.sessionTypeId
      ? await prisma.sessionTypeConfig.findUnique({ where: { id: data.sessionTypeId } })
      : null
    const locationName = data.locationName
      ?? (batch
        ? (await prisma.academy.findUnique({ where: { id: batch.academyId }, select: { name: true } }))?.name
        : undefined)

    const session = await prisma.practiceSession.create({
      data: {
        academyId: data.academyId ?? batch?.academyId,
        batchId: batch?.id ?? data.batchId,
        coachId: coach.id,
        status: 'LIVE',
        sessionType: normalizeSessionType(sessionTypeConfig?.name ?? data.sessionTypeName),
        sessionTypeConfigId: sessionTypeConfig?.id,
        scheduledAt: data.scheduledAt ? new Date(data.scheduledAt) : new Date(),
        durationMins: data.durationMinutes ?? sessionTypeConfig?.defaultDurationMinutes ?? 90,
        locationName,
        notes: data.notes,
      },
      include: {
        batch: { select: { id: true, name: true } },
        sessionTypeConfig: true,
      },
    })

    return {
      ...session,
      sessionTypeName: session.sessionTypeConfig?.name ?? session.sessionType,
    }
  }

  async getSessionDetail(sessionId: string, userId: string) {
    const coach = await this.getCoach(userId)
    const { session, attendance } = await this.buildAttendanceRoster(sessionId)
    if (session.coachId !== coach.id) throw Errors.forbidden()
    return {
      id: session.id,
      status: session.status,
      batchId: session.batchId,
      academyId: session.academyId,
      scheduledAt: session.scheduledAt,
      durationMinutes: session.durationMins,
      locationName: session.locationName,
      sessionType: session.sessionType,
      sessionTypeName: session.sessionTypeConfig?.name ?? session.sessionType,
      qrToken: session.sessionQrCode,
      attendanceCounts: {
        present: attendance.filter(item => item.status === 'PRESENT').length,
        absent: attendance.filter(item => item.status === 'ABSENT').length,
        unset: attendance.filter(item => item.status === 'UNSET').length,
      },
      reviewedCount: await prisma.playerSessionSignal.count({ where: { sessionId } }),
      rosterSize: attendance.length,
    }
  }

  async closeSession(sessionId: string, userId: string) {
    const coach = await this.getCoach(userId)
    const session = await prisma.practiceSession.findFirst({
      where: { id: sessionId, coachId: coach.id },
    })
    if (!session) throw Errors.notFound('Session')
    return prisma.practiceSession.update({
      where: { id: sessionId },
      data: {
        status: 'COMPLETED',
        isCompleted: true,
        sessionQrCode: null,
        qrClosedAt: new Date(),
      },
    })
  }

  private async markPlayerPresent(sessionId: string, userId: string, joinMethod: 'QR' | 'SELF_APP') {
    const session = await prisma.practiceSession.findUnique({
      where: { id: sessionId },
      select: {
        id: true,
        batchId: true,
        status: true,
        scheduledAt: true,
        sessionQrCode: true,
        qrClosedAt: true,
        qrExpiresAt: true,
      },
    })
    if (!session) throw Errors.notFound('Session')
    if (session.status !== 'LIVE') {
      throw new AppError('SESSION_NOT_LIVE', 'This session is no longer live', 409)
    }
    if (joinMethod === 'QR') {
      if (!session.sessionQrCode) throw new AppError('QR_NOT_GENERATED', 'QR is not active for this session', 409)
      if (session.qrClosedAt) throw new AppError('QR_CLOSED', 'QR is closed for this session', 409)
      if (session.qrExpiresAt && session.qrExpiresAt.getTime() < Date.now()) {
        throw new AppError('QR_EXPIRED', 'QR is expired for this session', 409)
      }
    }

    const player = await this.getPlayerByUser(userId)
    if (session.batchId) {
      const enrollment = await prisma.academyEnrollment.findFirst({
        where: { batchId: session.batchId, playerProfileId: player.id, isActive: true },
      })
      if (!enrollment) throw new AppError('NOT_ENROLLED', 'Player is not enrolled in this batch', 403)
    }

    return prisma.sessionAttendance.upsert({
      where: { sessionId_playerProfileId: { sessionId, playerProfileId: player.id } },
      create: {
        sessionId,
        playerProfileId: player.id,
        status: 'PRESENT',
        joinMethod,
        markedAt: new Date(),
        scannedAt: new Date(),
        scanMethod: joinMethod,
      },
      update: {
        status: 'PRESENT',
        joinMethod,
        markedAt: new Date(),
        scannedAt: new Date(),
        scanMethod: joinMethod,
      },
    })
  }

  async joinSessionViaQr(sessionId: string, userId: string) {
    return this.markPlayerPresent(sessionId, userId, 'QR')
  }

  async joinSessionViaApp(sessionId: string, userId: string) {
    return this.markPlayerPresent(sessionId, userId, 'SELF_APP')
  }

  async getAttendance(sessionId: string, userId: string) {
    const coach = await this.getCoach(userId)
    const { session, attendance } = await this.buildAttendanceRoster(sessionId)
    if (session.coachId !== coach.id) throw Errors.forbidden()
    return attendance
  }

  async updateAttendance(sessionId: string, playerProfileId: string, userId: string, status: 'PRESENT' | 'ABSENT' | 'UNSET') {
    const coach = await this.getCoach(userId)
    const session = await prisma.practiceSession.findFirst({
      where: { id: sessionId, coachId: coach.id },
    })
    if (!session) throw Errors.notFound('Session')

    if (status === 'UNSET') {
      await prisma.sessionAttendance.deleteMany({
        where: { sessionId, playerProfileId },
      })
      return { playerId: playerProfileId, status: 'UNSET' }
    }

    return prisma.sessionAttendance.upsert({
      where: { sessionId_playerProfileId: { sessionId, playerProfileId } },
      create: {
        sessionId,
        playerProfileId,
        status,
        joinMethod: 'COACH_MARKED',
        markedAt: new Date(),
        scanMethod: 'COACH_MARKED',
      },
      update: {
        status,
        joinMethod: 'COACH_MARKED',
        markedAt: new Date(),
        scanMethod: 'COACH_MARKED',
      },
    })
  }

  async saveSignal(sessionId: string, playerProfileId: string, userId: string, data: {
    overallSignal?: 'LOOKING_GOOD' | 'NEEDS_WORK' | 'WATCH_CLOSELY' | null
    strengthSkillIds?: string[]
    workOnSkillIds?: string[]
    watchFlagIds?: string[]
    followUpInDays?: number | null
    coachNote?: string
  }) {
    const coach = await this.getCoach(userId)
    const session = await prisma.practiceSession.findFirst({
      where: { id: sessionId, coachId: coach.id },
    })
    if (!session) throw Errors.notFound('Session')
    await this.assertCoachAccessToPlayer(coach.id, playerProfileId)

    return prisma.playerSessionSignal.upsert({
      where: { sessionId_playerProfileId: { sessionId, playerProfileId } },
      create: {
        sessionId,
        playerProfileId,
        coachId: coach.id,
        overallSignal: data.overallSignal ?? null,
        strengthSkillIds: data.strengthSkillIds ?? [],
        workOnSkillIds: data.workOnSkillIds ?? [],
        watchFlagIds: data.watchFlagIds ?? [],
        followUpInDays: data.followUpInDays ?? null,
        coachNote: data.coachNote,
      },
      update: {
        overallSignal: data.overallSignal ?? null,
        strengthSkillIds: data.strengthSkillIds ?? [],
        workOnSkillIds: data.workOnSkillIds ?? [],
        watchFlagIds: data.watchFlagIds ?? [],
        followUpInDays: data.followUpInDays ?? null,
        coachNote: data.coachNote,
      },
    })
  }

  async getPlayerSignals(playerProfileId: string, userId: string) {
    await this.assertCanViewPlayer(userId, playerProfileId)
    return prisma.playerSessionSignal.findMany({
      where: { playerProfileId },
      include: {
        session: {
          select: {
            id: true,
            scheduledAt: true,
            status: true,
            locationName: true,
            batch: { select: { name: true } },
            sessionTypeConfig: { select: { name: true } },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    })
  }

  async listDrills(filters: { role?: string; category?: string; includeInactive?: boolean }) {
    return prisma.drill.findMany({
      where: {
        ...(filters.includeInactive ? {} : { isActive: true }),
        ...(filters.role ? { roleTags: { has: filters.role as any } } : {}),
        ...(filters.category ? { category: filters.category as any } : {}),
      },
      orderBy: [{ isPublic: 'desc' }, { name: 'asc' }],
    })
  }

  async createDrill(userId: string, data: {
    name: string
    description?: string
    videoUrl?: string
    roleTags: Array<'BATSMAN' | 'BOWLER' | 'ALL_ROUNDER' | 'FIELDER' | 'WICKET_KEEPER'>
    category: 'TECHNIQUE' | 'FITNESS' | 'MENTAL' | 'MATCH_SIMULATION'
    targetUnit: 'BALLS' | 'OVERS' | 'MINUTES' | 'REPS' | 'SESSIONS'
    skillArea?: string
    isActive?: boolean
  }) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    return prisma.drill.create({
      data: {
        createdById: coach?.id ?? null,
        name: data.name,
        description: data.description,
        videoUrl: data.videoUrl?.trim() || null,
        roleTags: data.roleTags as any,
        category: data.category,
        targetUnit: data.targetUnit,
        skillArea: data.skillArea ?? data.category,
        isActive: data.isActive ?? true,
        tags: data.roleTags,
        isPublic: true,
      },
    })
  }

  async assignDrill(userId: string, data: {
    sessionId?: string
    playerId: string
    drillId: string
    targetQuantity: number
    targetUnit: 'BALLS' | 'OVERS' | 'MINUTES' | 'REPS' | 'SESSIONS'
  }) {
    const coach = await this.getCoach(userId)
    await this.assertCoachAccessToPlayer(coach.id, data.playerId)
    const assignment = await prisma.drillAssignment.create({
      data: {
        sessionId: data.sessionId,
        drillId: data.drillId,
        playerProfileId: data.playerId,
        assignedById: coach.id,
        coachId: coach.id,
        targetQuantity: data.targetQuantity,
        targetUnit: data.targetUnit,
        status: 'ACTIVE',
        assignedAt: new Date(),
      },
      include: { drill: true },
    })
    await prisma.drill.update({
      where: { id: data.drillId },
      data: { usageCount: { increment: 1 } },
    })
    return assignment
  }

  async getPlayerDrillAssignments(playerProfileId: string, userId: string) {
    await this.assertCanViewPlayer(userId, playerProfileId)
    const assignments = await prisma.drillAssignment.findMany({
      where: { playerProfileId, status: { in: ['ACTIVE', 'COMPLETED'] } },
      include: {
        drill: true,
        progressLogs: { orderBy: { loggedAt: 'desc' } },
      },
      orderBy: [{ completedAt: 'asc' }, { assignedAt: 'desc' }],
    })
    return assignments.map(assignment => {
      const totalDone = assignment.progressLogs.reduce((sum, log) => sum + log.quantityDone, 0)
      const target = assignment.targetQuantity ?? 0
      return {
        ...assignment,
        totalDone,
        progressPercent: target > 0 ? Math.min(100, Math.round((totalDone / target) * 100)) : 0,
      }
    })
  }

  async logDrillProgress(assignmentId: string, userId: string, quantityDone: number) {
    const assignment = await prisma.drillAssignment.findUnique({
      where: { id: assignmentId },
      include: { progressLogs: true },
    })
    if (!assignment) throw Errors.notFound('Drill assignment')

    const self = await prisma.playerProfile.findUnique({ where: { userId } })
    if (!self || self.id !== assignment.playerProfileId) {
      await this.assertCanViewPlayer(userId, assignment.playerProfileId)
    }

    const log = await prisma.drillProgressLog.create({
      data: {
        drillAssignmentId: assignmentId,
        playerProfileId: assignment.playerProfileId,
        quantityDone,
      },
    })

    const totalDone = assignment.progressLogs.reduce((sum, item) => sum + item.quantityDone, quantityDone)
    if (assignment.targetQuantity && totalDone >= assignment.targetQuantity && assignment.status !== 'COMPLETED') {
      await prisma.drillAssignment.update({
        where: { id: assignmentId },
        data: { status: 'COMPLETED', completedAt: new Date() },
      })
    }

    return log
  }

  async getDrillProgress(assignmentId: string, userId: string) {
    const assignment = await prisma.drillAssignment.findUnique({
      where: { id: assignmentId },
      include: {
        drill: true,
        progressLogs: { orderBy: { loggedAt: 'desc' } },
      },
    })
    if (!assignment) throw Errors.notFound('Drill assignment')
    await this.assertCanViewPlayer(userId, assignment.playerProfileId)
    const totalDone = assignment.progressLogs.reduce((sum, log) => sum + log.quantityDone, 0)
    return {
      ...assignment,
      totalDone,
      remaining: Math.max(0, (assignment.targetQuantity ?? 0) - totalDone),
      progressPercent: assignment.targetQuantity
        ? Math.min(100, Math.round((totalDone / assignment.targetQuantity) * 100))
        : 0,
    }
  }

  private async getSignalTaxonomy(skillIds: string[], flagIds: string[]) {
    const [skills, flags] = await Promise.all([
      skillIds.length
        ? prisma.skillArea.findMany({ where: { id: { in: skillIds } } })
        : Promise.resolve([]),
      flagIds.length
        ? prisma.watchFlag.findMany({ where: { id: { in: flagIds } } })
        : Promise.resolve([]),
    ])
    return {
      skillsById: new Map(skills.map(skill => [skill.id, skill])),
      flagsById: new Map(flags.map(flag => [flag.id, flag])),
    }
  }

  async getWeeklyReview(playerProfileId: string, userId: string) {
    await this.assertCanViewPlayer(userId, playerProfileId)
    const since = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
    const signals = await prisma.playerSessionSignal.findMany({
      where: { playerProfileId, createdAt: { gte: since } },
      include: {
        session: { select: { scheduledAt: true, batch: { select: { name: true } } } },
      },
      orderBy: { createdAt: 'desc' },
    })
    const skillIds = Array.from(new Set(signals.flatMap(signal => [...signal.strengthSkillIds, ...signal.workOnSkillIds])))
    const flagIds = Array.from(new Set(signals.flatMap(signal => signal.watchFlagIds)))
    const { skillsById, flagsById } = await this.getSignalTaxonomy(skillIds, flagIds)

    const counts = { LOOKING_GOOD: 0, NEEDS_WORK: 0, WATCH_CLOSELY: 0 }
    for (const signal of signals) {
      if (signal.overallSignal) counts[signal.overallSignal] += 1
    }

    return {
      windowStart: since,
      sessionsSeen: signals.length,
      strengths: Array.from(new Set(signals.flatMap(signal => signal.strengthSkillIds.map(id => skillsById.get(id)?.name).filter(Boolean)))),
      workOns: Array.from(new Set(signals.flatMap(signal => signal.workOnSkillIds.map(id => skillsById.get(id)?.name).filter(Boolean)))),
      watchFlags: Array.from(new Set(signals.flatMap(signal => signal.watchFlagIds.map(id => flagsById.get(id)?.name).filter(Boolean)))),
      overallSummary: counts,
      latestCoachNote: signals.find(signal => signal.coachNote)?.coachNote ?? null,
      nextFollowUpDate: signals
        .filter(signal => signal.followUpInDays != null)
        .map(signal => new Date(signal.createdAt.getTime() + (signal.followUpInDays ?? 0) * 24 * 60 * 60 * 1000))
        .sort((a, b) => a.getTime() - b.getTime())[0] ?? null,
    }
  }

  async getPlayerCard(playerProfileId: string, userId: string) {
    await this.assertCanViewPlayer(userId, playerProfileId)
    const player = await this.getPlayer(playerProfileId)
    const [goal, weeklyReview, assignments, recentSignals, attendance, enrollments, recentAttendances, performanceSummary] = await Promise.all([
      prisma.playerGoal.findUnique({ where: { playerProfileId } }),
      this.getWeeklyReview(playerProfileId, userId),
      this.getPlayerDrillAssignments(playerProfileId, userId),
      prisma.playerSessionSignal.findMany({
        where: { playerProfileId },
        orderBy: { createdAt: 'desc' },
        take: 5,
        include: { session: { select: { id: true, scheduledAt: true } } },
      }),
      prisma.sessionAttendance.findMany({
        where: { playerProfileId },
        orderBy: { markedAt: 'desc' },
        take: 30,
      }),
      prisma.academyEnrollment.findMany({
        where: { playerProfileId, isActive: true },
        include: { batch: { select: { name: true } }, academy: { select: { name: true } } },
        orderBy: { enrolledAt: 'desc' },
        take: 1,
      }),
      prisma.sessionAttendance.findMany({
        where: { playerProfileId },
        include: { session: { select: { scheduledAt: true, locationName: true } } },
        orderBy: { markedAt: 'desc' },
        take: 10,
      }),
      this.performanceService.getCardPerformanceSummary(playerProfileId),
    ])

    const recentSkillIds = Array.from(new Set(recentSignals.flatMap(signal => [...signal.strengthSkillIds, ...signal.workOnSkillIds])))
    const recentFlagIds = Array.from(new Set(recentSignals.flatMap(signal => signal.watchFlagIds)))
    const { skillsById, flagsById } = await this.getSignalTaxonomy(recentSkillIds, recentFlagIds)

    const radarSkills = await prisma.skillArea.findMany({
      where: { isActive: true },
      orderBy: { name: 'asc' },
      take: 12,
    })
    const radarLabels = (radarSkills.length ? radarSkills.map(item => item.name) : DEFAULT_RADAR_SKILLS).slice(0, 8)
    const radarData = radarLabels.map(label => {
      let score = 50
      for (const signal of recentSignals) {
        const strong = signal.strengthSkillIds.some(id => skillsById.get(id)?.name === label)
        const weak = signal.workOnSkillIds.some(id => skillsById.get(id)?.name === label)
        if (strong) score += 12
        if (weak) score -= 10
      }
      return { label, score: Math.max(0, Math.min(100, score)) }
    })

    const presentCount = attendance.filter(item => ACTIVE_ATTENDANCE_STATUSES.includes(item.status as any)).length
    const latestEnrollment = enrollments[0] ?? null

    return {
      player: {
        id: player.id,
        name: player.user.name,
        avatarUrl: player.user.avatarUrl,
        role: player.playerRole,
        goal: goal?.goalText ?? player.goals ?? '',
        batch: latestEnrollment?.batch?.name ?? null,
        academy: latestEnrollment?.academy?.name ?? null,
      },
      goal: goal ?? null,
      weeklyReview,
      thisWeek: {
        strengths: weeklyReview.strengths,
        workOns: weeklyReview.workOns,
        watchFlags: weeklyReview.watchFlags,
      },
      activeDrills: assignments,
      sessionTimeline: recentSignals.map(signal => ({
        sessionId: signal.sessionId,
        date: signal.session.scheduledAt,
        signal: signal.overallSignal,
        note: signal.coachNote,
      })),
      attendanceDots: recentAttendances.map(item => ({
        sessionDate: item.session.scheduledAt,
        status: item.status,
      })),
      attendancePercent: attendance.length ? Math.round((presentCount / attendance.length) * 100) : 0,
      nextFollowUpDate: weeklyReview.nextFollowUpDate,
      radarData,
      compactRadar: performanceSummary.radar,
      performanceStrengths: performanceSummary.strengths,
      performanceWorkOns: performanceSummary.workOns,
      trendDelta: performanceSummary.trendDelta,
      performanceInsights: performanceSummary.insights,
    }
  }

  async getOwnPlayerCard(userId: string) {
    const player = await this.getPlayerByUser(userId)
    return this.getPlayerCard(player.id, userId)
  }

  async getOwnWeeklyReview(userId: string) {
    const player = await this.getPlayerByUser(userId)
    return this.getWeeklyReview(player.id, userId)
  }

  async getOwnDrillAssignments(userId: string) {
    const player = await this.getPlayerByUser(userId)
    return this.getPlayerDrillAssignments(player.id, userId)
  }

  async getOwnActiveSession(userId: string) {
    const player = await this.getPlayerByUser(userId)
    const enrollment = await prisma.academyEnrollment.findFirst({
      where: { playerProfileId: player.id, isActive: true, batchId: { not: null } },
      orderBy: { enrolledAt: 'desc' },
    })
    if (!enrollment?.batchId) return null

    const today = startOfDay(new Date())
    const tomorrow = new Date(today.getTime() + 24 * 60 * 60 * 1000)
    const session = await prisma.practiceSession.findFirst({
      where: {
        batchId: enrollment.batchId,
        status: 'LIVE',
        scheduledAt: { gte: today, lt: tomorrow },
      },
      include: {
        sessionTypeConfig: true,
        attendances: {
          where: { playerProfileId: player.id },
          take: 1,
        },
      },
      orderBy: { scheduledAt: 'desc' },
    })
    if (!session) return null
    return {
      id: session.id,
      sessionTypeName: session.sessionTypeConfig?.name ?? session.sessionType,
      scheduledAt: session.scheduledAt,
      locationName: session.locationName,
      joined: session.attendances.length > 0,
    }
  }
}
