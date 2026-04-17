import { prisma } from '@swing/db'
import { Errors, AppError } from '../../lib/errors'
import { getPaginationParams, buildPaginationMeta } from '@swing/utils'
import { v4 as uuidv4 } from 'uuid'

export class CoachService {
  async getOrCreateProfile(userId: string) {
    const existing = await prisma.coachProfile.findUnique({
      where: { userId },
      include: {
        user: { select: { name: true, avatarUrl: true, phone: true } },
        academies: {
          where: { isActive: true },
          include: {
            academy: {
              select: { id: true, name: true, city: true, state: true, logoUrl: true },
            },
          },
          orderBy: { joinedAt: 'desc' },
        },
      },
    })
    if (existing) {
      return {
        ...existing,
        name: existing.user?.name ?? '',
        phone: existing.user?.phone ?? '',
        avatarUrl: existing.user?.avatarUrl ?? null,
        specialization: existing.specializations[0] ?? '',
        academyCoaches: existing.academies,
      }
    }
    // Add COACH role to user
    await prisma.user.update({ where: { id: userId }, data: { roles: { push: 'COACH' } } })
    const created = await prisma.coachProfile.create({
      data: { userId },
      include: {
        user: { select: { name: true, avatarUrl: true, phone: true } },
        academies: {
          where: { isActive: true },
          include: {
            academy: {
              select: { id: true, name: true, city: true, state: true, logoUrl: true },
            },
          },
        },
      },
    })
    return {
      ...created,
      name: created.user?.name ?? '',
      phone: created.user?.phone ?? '',
      avatarUrl: created.user?.avatarUrl ?? null,
      specialization: created.specializations[0] ?? '',
      academyCoaches: created.academies,
    }
  }

  async updateProfile(userId: string, data: any) {
    const allowed = ['bio', 'specializations', 'certifications', 'experienceYears', 'city', 'state', 'gigEnabled', 'hourlyRate']
    const update: any = {}
    for (const key of allowed) { if (data[key] !== undefined) update[key] = data[key] }
    return prisma.coachProfile.upsert({
      where: { userId },
      create: { userId, ...update },
      update,
    })
  }

  async getPublicProfile(coachProfileId: string) {
    const profile = await prisma.coachProfile.findUnique({
      where: { id: coachProfileId },
      include: {
        user: { select: { name: true, avatarUrl: true } },
        gigListings: { where: { isActive: true }, take: 5 },
      },
    })
    if (!profile) throw Errors.notFound('Coach profile')
    return profile
  }

  async getStudents(userId: string) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    if (!coach) return []

    const enrollments = await prisma.academyEnrollment.findMany({
      where: {
        isActive: true,
        OR: [
          { primaryCoachId: coach.id },
          { batch: { primaryCoachId: coach.id } },
          { academy: { coaches: { some: { coachId: coach.id, isActive: true } } } },
        ],
      },
      include: {
        playerProfile: {
          include: { user: { select: { name: true, avatarUrl: true } } },
        },
        batch: { select: { id: true, name: true } },
      },
      orderBy: { enrolledAt: 'desc' },
    })

    if (enrollments.length === 0) return []

    const playerProfileIds = Array.from(new Set(enrollments.map(e => e.playerProfileId)))
    const attendanceStats = await prisma.sessionAttendance.groupBy({
      by: ['playerProfileId'],
      where: {
        playerProfileId: { in: playerProfileIds },
        session: { coachId: coach.id },
      },
      _count: { _all: true },
    })
    const presentStats = await prisma.sessionAttendance.groupBy({
      by: ['playerProfileId'],
      where: {
        playerProfileId: { in: playerProfileIds },
        session: { coachId: coach.id },
        status: { in: ['PRESENT', 'LATE', 'EARLY_EXIT', 'WALK_IN'] },
      },
      _count: { _all: true },
    })
    const lastAttendance = await prisma.sessionAttendance.findMany({
      where: {
        playerProfileId: { in: playerProfileIds },
        session: { coachId: coach.id },
      },
      select: {
        playerProfileId: true,
        session: { select: { scheduledAt: true } },
      },
      orderBy: { session: { scheduledAt: 'desc' } },
    })

    const totalsByPlayer = new Map(attendanceStats.map(item => [item.playerProfileId, item._count._all]))
    const presentsByPlayer = new Map(presentStats.map(item => [item.playerProfileId, item._count._all]))
    const lastSessionByPlayer = new Map<string, Date>()
    for (const item of lastAttendance) {
      if (!lastSessionByPlayer.has(item.playerProfileId)) {
        lastSessionByPlayer.set(item.playerProfileId, item.session.scheduledAt)
      }
    }

    const latestEnrollmentByPlayer = new Map<string, (typeof enrollments)[number]>()
    for (const enrollment of enrollments) {
      if (!latestEnrollmentByPlayer.has(enrollment.playerProfileId)) {
        latestEnrollmentByPlayer.set(enrollment.playerProfileId, enrollment)
      }
    }

    return Array.from(latestEnrollmentByPlayer.values()).map(enrollment => {
      const total = totalsByPlayer.get(enrollment.playerProfileId) ?? 0
      const present = presentsByPlayer.get(enrollment.playerProfileId) ?? 0
      const attendancePercent = total > 0 ? Math.round((present / total) * 100) : 0
      return {
        ...enrollment.playerProfile,
        batchName: enrollment.batch?.name ?? '',
        attendancePercent,
        lastSessionDate: lastSessionByPlayer.get(enrollment.playerProfileId)?.toISOString() ?? null,
        status: enrollment.enrollmentStatus,
      }
    })
  }

  async createSession(userId: string, data: any) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    if (!coach) throw Errors.notFound('Coach profile')
    return prisma.practiceSession.create({
      data: {
        coachId: coach.id, academyId: data.academyId, batchId: data.batchId,
        sessionType: data.sessionType, scheduledAt: new Date(data.scheduledAt),
        durationMins: data.durationMins || 90, locationName: data.locationName,
        latitude: data.latitude, longitude: data.longitude,
        notes: data.notes, drillPlanId: data.drillPlanId,
      },
    })
  }

  async getSessions(userId: string, page: number, limit: number) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    if (!coach) return { data: [], meta: buildPaginationMeta(0, page, limit) }
    const { skip } = getPaginationParams({ page, limit })
    const [data, total] = await Promise.all([
      prisma.practiceSession.findMany({
        where: { coachId: coach.id, isCancelled: false },
        include: { batch: { select: { name: true } }, academy: { select: { name: true } }, sessionTypeConfig: { select: { name: true, color: true } } },
        orderBy: { scheduledAt: 'desc' },
        skip, take: limit,
      }),
      prisma.practiceSession.count({ where: { coachId: coach.id, isCancelled: false } }),
    ])
    return { data, meta: buildPaginationMeta(total, page, limit) }
  }

  async generateQr(sessionId: string, userId: string) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    if (!coach) throw Errors.forbidden()
    const session = await prisma.practiceSession.findFirst({ where: { id: sessionId, coachId: coach.id } })
    if (!session) throw Errors.notFound('Session')
    const token = uuidv4()
    return prisma.practiceSession.update({
      where: { id: sessionId },
      data: { sessionQrCode: token, qrGeneratedAt: new Date(), qrExpiresAt: new Date(Date.now() + 30 * 60 * 1000) },
    })
  }

  async closeQr(sessionId: string, userId: string) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    if (!coach) throw Errors.forbidden()
    const session = await prisma.practiceSession.findFirst({ where: { id: sessionId, coachId: coach.id } })
    if (!session) throw Errors.notFound('Session')
    return prisma.practiceSession.update({ where: { id: sessionId }, data: { qrClosedAt: new Date() } })
  }

  async overrideAttendance(sessionId: string, userId: string, playerProfileId: string, status: string, notes?: string) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    if (!coach) throw Errors.forbidden()
    const session = await prisma.practiceSession.findFirst({ where: { id: sessionId, coachId: coach.id } })
    if (!session) throw Errors.notFound('Session')
    return prisma.sessionAttendance.upsert({
      where: { sessionId_playerProfileId: { sessionId, playerProfileId } },
      create: { sessionId, playerProfileId, status: status as any, scanMethod: 'MANUAL_OVERRIDE', notes },
      update: { status: status as any, notes, scanMethod: 'MANUAL_OVERRIDE' },
    })
  }

  async createDrill(userId: string, data: any) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    if (!coach) throw Errors.notFound('Coach profile')
    return prisma.drill.create({
      data: {
        createdById: coach.id, name: data.name, description: data.description,
        skillArea: data.skillArea, subSkill: data.subSkill,
        difficulty: data.difficulty || 'BEGINNER', durationMins: data.durationMins || 20,
        videoUrl: data.videoUrl, thumbnailUrl: data.thumbnailUrl,
        tags: data.tags || [], isPublic: data.isPublic || false,
      },
    })
  }

  async createDrillPlan(userId: string, data: any) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    if (!coach) throw Errors.notFound('Coach profile')
    return prisma.drillPlan.create({
      data: {
        name: data.name, description: data.description, coachId: coach.id,
        items: {
          create: (data.items || []).map((item: any, idx: number) => ({
            drillId: item.drillId, order: idx, reps: item.reps, sets: item.sets, notes: item.notes,
          })),
        },
      },
      include: { items: { include: { drill: true } } },
    })
  }

  async submitFeedback(userId: string, data: any) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    if (!coach) throw Errors.notFound('Coach profile')
    return prisma.coachFeedback.create({
      data: {
        coachId: coach.id, playerProfileId: data.playerProfileId,
        sessionId: data.sessionId, feedbackText: data.feedbackText,
        voiceNoteUrl: data.voiceNoteUrl, videoClipUrl: data.videoClipUrl,
        videoTimestamp: data.videoTimestamp, tags: data.tags || [],
        isVisibleToParent: data.isVisibleToParent !== false,
      },
    })
  }

  async createReportCard(userId: string, data: any) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    if (!coach) throw Errors.notFound('Coach profile')
    return prisma.reportCard.create({
      data: {
        coachId: coach.id, playerProfileId: data.playerProfileId,
        periodMonth: data.periodMonth, periodYear: data.periodYear,
        swingIndexStart: data.swingIndexStart, swingIndexEnd: data.swingIndexEnd,
        attendanceRate: data.attendanceRate, drillCompletion: data.drillCompletion,
        coachNarrative: data.coachNarrative, strengthsNote: data.strengthsNote,
        focusAreasNote: data.focusAreasNote, goalsNextMonth: data.goalsNextMonth,
      },
    })
  }

  async publishReportCard(reportCardId: string, userId: string) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    if (!coach) throw Errors.forbidden()
    const card = await prisma.reportCard.findFirst({ where: { id: reportCardId, coachId: coach.id } })
    if (!card) throw Errors.notFound('Report card')
    if (card.isPublished) throw new AppError('ALREADY_PUBLISHED', 'Report card already published', 409)
    return prisma.reportCard.update({
      where: { id: reportCardId },
      data: { isPublished: true, publishedAt: new Date() },
    })
  }

  async listDrills(userId: string) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    if (!coach) return []
    return prisma.drill.findMany({
      where: { createdById: coach.id },
      orderBy: { createdAt: 'desc' },
    })
  }

  async getDrillById(drillId: string, userId: string) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    const drill = await prisma.drill.findUnique({
      where: { id: drillId },
      include: {
        planItems: {
          include: {
            plan: { select: { name: true } },
          },
        },
        _count: {
          select: { assignments: true },
        },
      },
    })
    if (!drill) throw Errors.notFound('Drill')
    if (!drill.isPublic && (!coach || drill.createdById !== coach.id)) {
      throw Errors.forbidden()
    }

    return {
      id: drill.id,
      title: drill.name,
      description: drill.description,
      skillArea: drill.skillArea,
      difficulty: drill.difficulty,
      durationMinutes: drill.durationMins,
      videoUrl: drill.videoUrl,
      tags: drill.tags,
      assignmentCount: drill._count.assignments,
      usedInPlans: Array.from(new Set(drill.planItems.map(item => item.plan.name))),
      createdAt: drill.createdAt,
    }
  }

  async getDrillPlans(userId: string) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    if (!coach) return []

    const plans = await prisma.drillPlan.findMany({
      where: { coachId: coach.id },
      include: {
        items: {
          include: { drill: { select: { name: true } } },
          orderBy: { order: 'asc' },
        },
        _count: {
          select: { items: true },
        },
      },
      orderBy: { createdAt: 'desc' },
    })

    return plans.map(plan => ({
      id: plan.id,
      name: plan.name,
      description: plan.description,
      itemCount: plan._count.items,
      drillPreview: plan.items.slice(0, 3).map(item => item.drill.name),
      createdAt: plan.createdAt,
    }))
  }

  async listGigBookings(userId: string, page: number, limit: number) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    if (!coach) return { data: [], meta: buildPaginationMeta(0, page, limit) }
    const { skip } = getPaginationParams({ page, limit })
    const [data, total] = await Promise.all([
      prisma.gigBooking.findMany({
        where: { coachId: coach.id },
        orderBy: { scheduledAt: 'desc' },
        skip, take: limit,
      }),
      prisma.gigBooking.count({ where: { coachId: coach.id } }),
    ])
    return { data, meta: buildPaginationMeta(total, page, limit) }
  }

  async listReportCards(userId: string) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    if (!coach) return []
    return prisma.reportCard.findMany({
      where: { coachId: coach.id },
      include: { playerProfile: { include: { user: { select: { name: true } } } } },
      orderBy: { createdAt: 'desc' },
    })
  }

  async getEarnings(userId: string) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    if (!coach) return { totalPaise: 0, thisMonthPaise: 0 }
    const startOfMonth = new Date(new Date().getFullYear(), new Date().getMonth(), 1)
    const [total, thisMonth] = await Promise.all([
      prisma.gigBooking.aggregate({ where: { coachId: coach.id, status: 'COMPLETED' }, _sum: { coachPayoutPaise: true } }),
      prisma.gigBooking.aggregate({ where: { coachId: coach.id, status: 'COMPLETED', completedAt: { gte: startOfMonth } }, _sum: { coachPayoutPaise: true } }),
    ])
    return { totalPaise: total._sum.coachPayoutPaise || 0, thisMonthPaise: thisMonth._sum.coachPayoutPaise || 0 }
  }

  // ─── Session Cancellation ────────────────────────────────────────────────────

  async cancelSession(userId: string, sessionId: string, reason: string) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    if (!coach) throw Errors.forbidden()
    const session = await prisma.practiceSession.findFirst({ where: { id: sessionId, coachId: coach.id } })
    if (!session) throw Errors.notFound('Session')
    if (session.isCompleted) throw new AppError('SESSION_COMPLETED', 'Cannot cancel a completed session', 400)
    return prisma.practiceSession.update({
      where: { id: sessionId },
      data: { isCancelled: true, cancelReason: reason },
    })
  }

  // ─── Recurring Schedules ─────────────────────────────────────────────────────

  async getSchedules(userId: string) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    if (!coach) return []
    return prisma.sessionSchedule.findMany({
      where: { coachId: coach.id },
      include: {
        academy: { select: { name: true } },
        batch: { select: { name: true } },
      },
      orderBy: { createdAt: 'desc' },
    })
  }

  async createSchedule(userId: string, data: any) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    if (!coach) throw Errors.notFound('Coach profile')
    const schedule = await prisma.sessionSchedule.create({
      data: {
        coachId: coach.id,
        academyId: data.academyId || null,
        batchId: data.batchId || null,
        sessionType: data.sessionType,
        daysOfWeek: data.daysOfWeek,
        startTime: data.startTime,
        durationMins: data.durationMins || 90,
      },
      include: {
        academy: { select: { name: true } },
        batch: { select: { name: true } },
      },
    })
    // Auto-generate sessions for next 4 weeks
    await this._generateSessionsFromSchedule(coach.id, schedule, 4)
    return schedule
  }

  async updateSchedule(userId: string, scheduleId: string, data: any) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    if (!coach) throw Errors.forbidden()
    const schedule = await prisma.sessionSchedule.findFirst({ where: { id: scheduleId, coachId: coach.id } })
    if (!schedule) throw Errors.notFound('Schedule')
    const allowed = ['sessionType', 'daysOfWeek', 'startTime', 'durationMins', 'isActive']
    const update: any = {}
    for (const key of allowed) { if (data[key] !== undefined) update[key] = data[key] }
    return prisma.sessionSchedule.update({ where: { id: scheduleId }, data: update })
  }

  async generateFromSchedule(userId: string, scheduleId: string, weeksAhead = 2) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    if (!coach) throw Errors.forbidden()
    const schedule = await prisma.sessionSchedule.findFirst({
      where: { id: scheduleId, coachId: coach.id },
      include: { academy: { select: { name: true } } },
    })
    if (!schedule) throw Errors.notFound('Schedule')
    return this._generateSessionsFromSchedule(coach.id, schedule, weeksAhead)
  }

  private async _generateSessionsFromSchedule(coachId: string, schedule: any, weeksAhead: number) {
    const [hours, minutes] = schedule.startTime.split(':').map(Number)
    const now = new Date()
    const created = []

    for (let week = 0; week < weeksAhead; week++) {
      for (const dayOfWeek of schedule.daysOfWeek) {
        const date = new Date(now)
        const currentDay = date.getDay()
        let daysToAdd = dayOfWeek - currentDay + week * 7
        if (daysToAdd <= 0 && week === 0) daysToAdd += 7
        date.setDate(date.getDate() + daysToAdd)
        date.setHours(hours, minutes, 0, 0)
        if (date <= now) continue

        const exists = await prisma.practiceSession.findFirst({
          where: { scheduleId: schedule.id, scheduledAt: date },
        })
        if (exists) continue

        const session = await prisma.practiceSession.create({
          data: {
            coachId,
            academyId: schedule.academyId,
            batchId: schedule.batchId,
            sessionType: schedule.sessionType,
            scheduledAt: date,
            durationMins: schedule.durationMins,
            locationName: schedule.academy?.name ?? null,
            scheduleId: schedule.id,
          },
        })
        created.push(session)
      }
    }
    return created
  }

  // ─── Coach Batches ───────────────────────────────────────────────────────────

  async getCoachBatches(userId: string) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    if (!coach) return []
    const links = await prisma.academyCoach.findMany({
      where: { coachId: coach.id, isActive: true },
      select: { academyId: true },
    })
    const academyIds = links.map(l => l.academyId)
    if (academyIds.length === 0) return []
    return prisma.batch.findMany({
      where: { academyId: { in: academyIds }, isActive: true },
      select: { id: true, name: true, academyId: true, academy: { select: { id: true, name: true } } },
      orderBy: { name: 'asc' },
    })
  }
}
