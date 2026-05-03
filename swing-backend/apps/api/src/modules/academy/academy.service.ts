import { prisma, UserRole } from '@swing/db'
import { Errors, AppError } from '../../lib/errors'
import { getPaginationParams, buildPaginationMeta, normalizePhone } from '@swing/utils'

const PLAN_STUDENT_LIMITS: Record<string, number> = {
  FREE: 10,
  CLUB_BASIC: 50,
  CLUB_PRO: 200,
  CLUB_ELITE: Infinity,
}

export class AcademyService {
  private static readonly dayLabels = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']

  private async attachFeeStructures<T extends { id: string }>(
    academyId: string,
    batches: T[],
  ) {
    if (batches.length === 0) {
      return batches.map(batch => ({ ...batch, feeStructures: [] }))
    }

    const batchIds = batches.map(batch => batch.id)
    const feeStructures = await prisma.feeStructure.findMany({
      where: {
        academyId,
        isActive: true,
        batchId: { in: batchIds },
      },
      select: {
        id: true,
        name: true,
        amountPaise: true,
        frequency: true,
        batchId: true,
      },
      orderBy: { createdAt: 'desc' },
    })

    return batches.map(batch => ({
      ...batch,
      feeStructures: feeStructures.filter(fee => fee.batchId === batch.id),
    }))
  }

  async createAcademy(userId: string, data: any) {
    let ownerProfile = await prisma.academyOwnerProfile.findUnique({ where: { userId } })
    if (!ownerProfile) {
      ownerProfile = await prisma.academyOwnerProfile.create({ data: { userId } })
    }
    // Add ACADEMY_OWNER role only if not already present
    const owner = await prisma.user.findUnique({ where: { id: userId }, select: { roles: true } })
    if (owner && !owner.roles.includes(UserRole.ACADEMY_OWNER)) {
      await prisma.user.update({ where: { id: userId }, data: { roles: { push: UserRole.ACADEMY_OWNER } } })
    }

    return prisma.academy.create({
      data: {
        ownerId: ownerProfile.id,
        name: data.name, description: data.description,
        city: data.city, state: data.state, address: data.address,
        pincode: data.pincode, latitude: data.latitude, longitude: data.longitude,
        phone: data.phone, email: data.email, websiteUrl: data.websiteUrl,
      },
    })
  }

  async getAcademy(id: string) {
    const academy = await prisma.academy.findUnique({
      where: { id },
      include: {
        coaches: { include: { coach: { include: { user: { select: { name: true, avatarUrl: true, phone: true } } } } } },
        batches: { where: { isActive: true } },
      },
    })
    if (!academy) throw Errors.notFound('Academy')
    return academy
  }

  async getMyAcademy(userId: string) {
    const ownerProfile = await prisma.academyOwnerProfile.findUnique({ where: { userId } })
    if (!ownerProfile) return null
    const academy = await prisma.academy.findFirst({
      where: { ownerId: ownerProfile.id, isActive: true },
      include: {
        coaches: { include: { coach: { include: { user: { select: { name: true, avatarUrl: true, phone: true } } } } } },
        batches: { where: { isActive: true } },
      },
      orderBy: { createdAt: 'desc' },
    })
    return academy
  }

  async updateAcademy(academyId: string, userId: string, data: any) {
    await this.verifyOwnership(academyId, userId)
    const allowed = ['name', 'description', 'address', 'city', 'state', 'pincode', 'phone', 'email', 'websiteUrl', 'latitude', 'longitude', 'logoUrl']
    const update: any = {}
    for (const key of allowed) { if (data[key] !== undefined) update[key] = data[key] }
    return prisma.academy.update({ where: { id: academyId }, data: update })
  }

  async inviteCoach(academyId: string, userId: string, phone: string, isHeadCoach: boolean, name?: string) {
    await this.verifyOwnership(academyId, userId)
    const normalizedPhone = normalizePhone(phone)
    let coachUser = await prisma.user.findUnique({ where: { phone: normalizedPhone } })
    const isNew = !coachUser
    if (!coachUser) {
      coachUser = await prisma.user.create({
        data: { phone: normalizedPhone, name: name ?? 'Coach', roles: ['COACH'], activeRole: 'COACH' },
      })
    } else if (name && coachUser.name === 'Coach') {
      coachUser = await prisma.user.update({ where: { id: coachUser.id }, data: { name } })
    }

    let coachProfile = await prisma.coachProfile.findUnique({ where: { userId: coachUser.id } })
    if (!coachProfile) {
      coachProfile = await prisma.coachProfile.create({ data: { userId: coachUser.id } })
      if (!coachUser.roles.includes('COACH' as any)) {
        await prisma.user.update({ where: { id: coachUser.id }, data: { roles: { push: 'COACH' } } })
      }
    }

    const existing = await prisma.academyCoach.findUnique({
      where: { academyId_coachId: { academyId, coachId: coachProfile.id } },
    })
    let link = existing
    if (existing) {
      if (!existing.isActive) {
        link = await prisma.academyCoach.update({ where: { id: existing.id }, data: { isActive: true, isHeadCoach } })
      }
      // already active — return existing link with profile info
    } else {
      link = await prisma.academyCoach.create({ data: { academyId, coachId: coachProfile.id, isHeadCoach } })
      await prisma.academy.update({ where: { id: academyId }, data: { totalCoaches: { increment: 1 } } })
    }
    return { ...link, coachProfileId: coachProfile.id, userName: coachUser.name, isNew }
  }

  async updateCoachLink(academyId: string, userId: string, coachLinkId: string, data: { isHeadCoach?: boolean; isActive?: boolean }) {
    await this.verifyOwnership(academyId, userId)
    const link = await prisma.academyCoach.findFirst({ where: { id: coachLinkId, academyId } })
    if (!link) throw new AppError('NOT_FOUND', 'Coach link not found', 404)
    const updated = await prisma.academyCoach.update({
      where: { id: coachLinkId },
      data: {
        ...(data.isHeadCoach !== undefined ? { isHeadCoach: data.isHeadCoach } : {}),
        ...(data.isActive !== undefined ? { isActive: data.isActive } : {}),
      },
      include: { coach: { include: { user: { select: { name: true, avatarUrl: true, phone: true } } } } },
    })
    if (data.isActive === false) {
      await prisma.academy.update({ where: { id: academyId }, data: { totalCoaches: { decrement: 1 } } })
    }
    return updated
  }

  async addCoachToBatch(academyId: string, userId: string, batchId: string, coachId: string) {
    await this.verifyOwnership(academyId, userId)
    const batch = await prisma.batch.findFirst({ where: { id: batchId, academyId } })
    if (!batch) throw new AppError('NOT_FOUND', 'Batch not found', 404)
    // Verify coach is in the academy
    const coachLink = await prisma.academyCoach.findFirst({ where: { coachId, academyId, isActive: true } })
    if (!coachLink) throw new AppError('FORBIDDEN', 'Coach is not in this academy', 403)
    // If batch has no primary coach, set as primary; otherwise just update
    if (!batch.primaryCoachId) {
      return prisma.batch.update({ where: { id: batchId }, data: { primaryCoachId: coachId } })
    }
    // Already has a primary coach — return current state
    return batch
  }

  async createBatch(academyId: string, userId: string, data: any) {
    await this.verifyOwnership(academyId, userId)
    const batch = await prisma.batch.create({
      data: {
        academyId, name: data.name, ageGroup: data.ageGroup,
        maxStudents: data.maxStudents || 20, sport: data.sport || 'CRICKET',
        description: data.description,
      },
    })
    await prisma.academy.update({ where: { id: academyId }, data: { totalBatches: { increment: 1 } } })
    return batch
  }

  async listBatches(academyId: string) {
    const batches = await prisma.batch.findMany({
      where: { academyId, isActive: true },
      include: {
        schedules: { where: { isActive: true } },
        _count: { select: { enrollments: true } },
      },
    })
    return this.attachFeeStructures(academyId, batches)
  }

  async updateBatch(academyId: string, userId: string, batchId: string, data: any) {
    await this.verifyOwnership(academyId, userId)
    const allowed = ['name', 'ageGroup', 'maxStudents', 'sport', 'description', 'isActive']
    const update: any = {}
    for (const key of allowed) { if (data[key] !== undefined) update[key] = data[key] }
    const batch = await prisma.batch.update({
      where: { id: batchId, academyId },
      data: update,
      include: {
        schedules: { where: { isActive: true } },
        _count: { select: { enrollments: true } },
      },
    })
    const [withFees] = await this.attachFeeStructures(academyId, [batch])
    return withFees
  }

  async addBatchSchedule(academyId: string, userId: string, batchId: string, data: any) {
    await this.verifyOwnership(academyId, userId)
    return prisma.batchSchedule.create({
      data: { batchId, dayOfWeek: data.dayOfWeek, startTime: data.startTime, endTime: data.endTime, groundNote: data.groundNote },
    })
  }

  async removeBatchSchedule(academyId: string, userId: string, scheduleId: string) {
    await this.verifyOwnership(academyId, userId)
    return prisma.batchSchedule.update({ where: { id: scheduleId }, data: { isActive: false } })
  }

  async enrollStudent(academyId: string, userId: string, phone: string, studentName: string, batchId?: string, isTrial?: boolean, extra?: any) {
    await this.verifyOwnership(academyId, userId)
    const academy = await prisma.academy.findUnique({ where: { id: academyId } })
    if (!academy) throw Errors.notFound('Academy')

    const planLimit = PLAN_STUDENT_LIMITS[academy.planTier] ?? 10
    if (academy.totalStudents >= planLimit) throw Errors.planLimitReached()

    const normalizedPhone = normalizePhone(phone)
    let studentUser = await prisma.user.findUnique({ where: { phone: normalizedPhone } })
    if (!studentUser) {
      studentUser = await prisma.user.create({
        data: { phone: normalizedPhone, name: studentName, roles: ['PLAYER'], activeRole: 'PLAYER' },
      })
    }
    let playerProfile = await prisma.playerProfile.findUnique({ where: { userId: studentUser.id } })
    if (!playerProfile) {
      playerProfile = await prisma.playerProfile.create({ data: { userId: studentUser.id } })
    }

    // Update profile fields if provided
    const profileUpdate: any = {}
    if (extra?.bloodGroup) profileUpdate.bloodGroup = extra.bloodGroup
    if (extra?.aadhaarLast4) profileUpdate.aadhaarLast4 = extra.aadhaarLast4
    if (extra?.emergencyContactName) profileUpdate.emergencyContactName = extra.emergencyContactName
    if (extra?.emergencyContactPhone) profileUpdate.emergencyContactPhone = extra.emergencyContactPhone
    if (extra?.city) profileUpdate.city = extra.city
    if (extra?.dateOfBirth) profileUpdate.dateOfBirth = new Date(extra.dateOfBirth)
    if (Object.keys(profileUpdate).length > 0) {
      await prisma.playerProfile.update({ where: { id: playerProfile.id }, data: profileUpdate })
    }

    const regNo = `SW${new Date().getFullYear()}${(academy.totalStudents + 1).toString().padStart(4, '0')}`
    const playerProfileId = playerProfile.id

    const enrollment = await prisma.academyEnrollment.upsert({
      where: { academyId_playerProfileId: { academyId, playerProfileId } },
      create: {
        academyId, playerProfileId, batchId,
        isTrial: isTrial || false,
        trialEndsAt: isTrial ? new Date(Date.now() + 7 * 24 * 60 * 60 * 1000) : undefined,
        feeAmountPaise: extra?.feeAmountPaise,
        feeFrequency: extra?.feeFrequency || 'MONTHLY',
        registrationNo: regNo,
      },
      update: { isActive: true, batchId, isTrial: isTrial || false },
    })
    await prisma.academy.update({ where: { id: academyId }, data: { totalStudents: { increment: 1 } } })
    // Record initial payment if provided
    if (extra?.initialPaymentPaise && extra.initialPaymentPaise > 0) {
      await prisma.feePayment.create({
        data: {
          academyId,
          playerProfileId: enrollment.playerProfileId,
          enrollmentId: enrollment.id,
          amountPaise: extra.initialPaymentPaise,
          dueDate: new Date(),
          paidAt: new Date(),
          status: 'COMPLETED',
          paymentMode: extra.initialPaymentMode,
          notes: 'Initial / registration fee',
        },
      })
      await prisma.academyEnrollment.update({
        where: { id: enrollment.id },
        data: { feeStatus: 'PAID', feePaidPaise: extra.initialPaymentPaise },
      })
    }
    return enrollment
  }

  async updateStudent(academyId: string, userId: string, enrollmentId: string, data: any) {
    await this.verifyOwnership(academyId, userId)
    const enrollment = await prisma.academyEnrollment.findUnique({
      where: { id: enrollmentId },
      include: { playerProfile: true },
    })
    if (!enrollment) throw Errors.notFound('Enrollment')

    // Update enrollment fields
    const enrollUpdate: any = {}
    if (data.batchId !== undefined) enrollUpdate.batchId = data.batchId
    if (data.feeAmountPaise !== undefined) enrollUpdate.feeAmountPaise = data.feeAmountPaise
    if (data.feeFrequency !== undefined) enrollUpdate.feeFrequency = data.feeFrequency
    if (data.feeStatus !== undefined) enrollUpdate.feeStatus = data.feeStatus
    if (data.notes !== undefined) enrollUpdate.notes = data.notes
    if (Object.keys(enrollUpdate).length > 0) {
      await prisma.academyEnrollment.update({ where: { id: enrollmentId }, data: enrollUpdate })
    }

    // Update player profile fields
    const profileUpdate: any = {}
    if (data.bloodGroup !== undefined) profileUpdate.bloodGroup = data.bloodGroup
    if (data.aadhaarLast4 !== undefined) profileUpdate.aadhaarLast4 = data.aadhaarLast4
    if (data.emergencyContactName !== undefined) profileUpdate.emergencyContactName = data.emergencyContactName
    if (data.emergencyContactPhone !== undefined) profileUpdate.emergencyContactPhone = data.emergencyContactPhone
    if (data.city !== undefined) profileUpdate.city = data.city
    if (data.dateOfBirth !== undefined) profileUpdate.dateOfBirth = data.dateOfBirth ? new Date(data.dateOfBirth) : null
    if (Object.keys(profileUpdate).length > 0) {
      await prisma.playerProfile.update({ where: { id: enrollment.playerProfileId }, data: profileUpdate })
    }

    return prisma.academyEnrollment.findUnique({
      where: { id: enrollmentId },
      include: {
        playerProfile: { include: { user: { select: { name: true, phone: true, avatarUrl: true } } } },
        batch: { select: { name: true } },
      },
    })
  }

  async listStudents(academyId: string, userId: string, page: number, limit: number) {
    await this.verifyOwnership(academyId, userId)
    const { skip } = getPaginationParams({ page, limit })
    const [data, total] = await Promise.all([
      prisma.academyEnrollment.findMany({
        where: { academyId, isActive: true },
        include: {
          playerProfile: {
            include: { user: { select: { name: true, avatarUrl: true, phone: true } } },
          },
          batch: { select: { name: true } },
        },
        skip, take: limit,
      }),
      prisma.academyEnrollment.count({ where: { academyId, isActive: true } }),
    ])
    return { data, meta: buildPaginationMeta(total, page, limit) }
  }

  async getSessions(
    academyId: string,
    userId: string,
    filters: { from?: string; to?: string; batchId?: string },
  ) {
    await this.verifyAcademyAccess(academyId, userId)
    const from = filters.from ? new Date(filters.from) : new Date()
    const to = filters.to
      ? new Date(filters.to)
      : new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)

    const sessions = await prisma.practiceSession.findMany({
      where: {
        academyId,
        scheduledAt: { gte: from, lte: to },
        ...(filters.batchId ? { batchId: filters.batchId } : {}),
      },
      include: {
        batch: { select: { id: true, name: true } },
        coach: {
          include: {
            user: { select: { name: true, avatarUrl: true } },
          },
        },
        attendances: {
          select: { status: true },
        },
      },
      orderBy: { scheduledAt: 'asc' },
    })

    return sessions.map(session => ({
      id: session.id,
      scheduledAt: session.scheduledAt,
      sessionType: session.sessionType,
      status: session.isCancelled
        ? 'CANCELLED'
        : session.isCompleted
          ? 'COMPLETED'
          : 'SCHEDULED',
      durationMins: session.durationMins,
      batchName: session.batch?.name ?? null,
      coachName: session.coach.user.name,
      coachAvatar: session.coach.user.avatarUrl,
      presentCount: session.attendances.filter(att => att.status === 'PRESENT').length,
      absentCount: session.attendances.filter(att => att.status === 'ABSENT').length,
      totalStudents: session.attendances.length,
    }))
  }

  async getAttendanceReport(
    academyId: string,
    userId: string,
    filters: { from?: string; to?: string; batchId?: string },
  ) {
    await this.verifyAcademyAccess(academyId, userId)
    const from = filters.from ? new Date(filters.from) : new Date(new Date().setDate(1))
    const to = filters.to ? new Date(filters.to) : new Date()

    const attendances = await prisma.sessionAttendance.findMany({
      where: {
        session: {
          academyId,
          scheduledAt: { gte: from, lte: to },
          ...(filters.batchId ? { batchId: filters.batchId } : {}),
        },
      },
      include: {
        playerProfile: {
          include: {
            user: { select: { id: true, name: true, avatarUrl: true } },
            academyEnrollments: {
              where: { academyId, isActive: true },
              include: { batch: { select: { name: true } } },
              take: 1,
            },
          },
        },
        session: {
          include: {
            batch: { select: { name: true } },
            coach: {
              include: { user: { select: { name: true } } },
            },
          },
        },
      },
      orderBy: { session: { scheduledAt: 'asc' } },
    })

    const byStudentMap = new Map<string, any>()
    const bySessionMap = new Map<string, any>()

    for (const attendance of attendances) {
      const playerId = attendance.playerProfile.user.id
      const batchName =
        attendance.playerProfile.academyEnrollments[0]?.batch?.name ??
        attendance.session.batch?.name ??
        null

      const studentEntry = byStudentMap.get(playerId) ?? {
        playerId,
        name: attendance.playerProfile.user.name,
        avatarUrl: attendance.playerProfile.user.avatarUrl,
        batchName,
        totalSessions: 0,
        present: 0,
        late: 0,
        absent: 0,
      }
      studentEntry.totalSessions += 1
      if (attendance.status === 'PRESENT') studentEntry.present += 1
      if (attendance.status === 'LATE') studentEntry.late += 1
      if (attendance.status === 'ABSENT') studentEntry.absent += 1
      byStudentMap.set(playerId, studentEntry)

      const sessionEntry = bySessionMap.get(attendance.sessionId) ?? {
        sessionId: attendance.sessionId,
        scheduledAt: attendance.session.scheduledAt,
        batchName: attendance.session.batch?.name ?? null,
        coachName: attendance.session.coach.user.name,
        present: 0,
        late: 0,
        absent: 0,
        total: 0,
      }
      sessionEntry.total += 1
      if (attendance.status === 'PRESENT') sessionEntry.present += 1
      if (attendance.status === 'LATE') sessionEntry.late += 1
      if (attendance.status === 'ABSENT') sessionEntry.absent += 1
      bySessionMap.set(attendance.sessionId, sessionEntry)
    }

    const byStudent = Array.from(byStudentMap.values())
      .map(entry => ({
        ...entry,
        attendancePct: entry.totalSessions > 0
          ? Math.round(((entry.present + entry.late) / entry.totalSessions) * 100)
          : 0,
      }))
      .sort((a, b) => a.name.localeCompare(b.name))

    const bySession = Array.from(bySessionMap.values())
      .sort((a, b) => new Date(a.scheduledAt).getTime() - new Date(b.scheduledAt).getTime())

    return { byStudent, bySession }
  }

  async createFeeStructure(academyId: string, userId: string, data: any) {
    await this.verifyOwnership(academyId, userId)
    return prisma.feeStructure.create({
      data: {
        academyId, batchId: data.batchId, name: data.name,
        amountPaise: data.amountPaise, frequency: data.frequency,
        dueDayOfMonth: data.dueDayOfMonth || 1,
      },
    })
  }

  async getFeePayments(academyId: string, userId: string, page: number, limit: number) {
    await this.verifyOwnership(academyId, userId)
    const { skip } = getPaginationParams({ page, limit })
    const [enrollments, total] = await Promise.all([
      prisma.academyEnrollment.findMany({
        where: { academyId, isActive: true },
        include: {
          playerProfile: { include: { user: { select: { name: true, phone: true } } } },
          batch: { select: { name: true } },
          feePayments: { orderBy: { createdAt: 'desc' }, take: 5 },
        },
        orderBy: { enrolledAt: 'desc' },
        skip, take: limit,
      }),
      prisma.academyEnrollment.count({ where: { academyId, isActive: true } }),
    ])
    const data = enrollments.map(e => ({
      id: e.id,
      enrollmentId: e.id,
      latestPaymentId: e.feePayments[0]?.id ?? null,
      studentName: e.playerProfile.user.name ?? 'Unknown',
      studentPhone: e.playerProfile.user.phone,
      batchName: e.batch?.name ?? 'No batch',
      status: e.feeStatus,
      amount: e.feeAmountPaise ?? 0,
      feePaid: e.feePaidPaise ?? 0,
      frequency: e.feeFrequency,
      history: e.feePayments.map(p => ({
        id: p.id,
        amount: p.amountPaise,
        date: (p.paidAt ?? p.createdAt).toISOString(),
        status: p.status === 'COMPLETED' ? 'PAID' : p.status,
        mode: p.paymentMode,
        notes: p.notes,
      })),
    }))
    return { data, meta: buildPaginationMeta(total, page, limit) }
  }

  async recordFeePayment(academyId: string, userId: string, data: {
    enrollmentId: string
    amountPaise: number
    paymentMode?: string
    notes?: string
    paidAt?: string
  }) {
    await this.verifyOwnership(academyId, userId)
    const enrollment = await prisma.academyEnrollment.findUnique({
      where: { id: data.enrollmentId },
      select: { id: true, academyId: true, playerProfileId: true },
    })
    if (!enrollment || enrollment.academyId !== academyId) throw Errors.notFound('Enrollment')
    const paidAt = data.paidAt ? new Date(data.paidAt) : new Date()
    const [payment] = await prisma.$transaction([
      prisma.feePayment.create({
        data: {
          academyId,
          playerProfileId: enrollment.playerProfileId,
          enrollmentId: data.enrollmentId,
          amountPaise: data.amountPaise,
          dueDate: paidAt,
          paidAt,
          status: 'COMPLETED',
          paymentMode: data.paymentMode,
          notes: data.notes,
        },
      }),
      prisma.academyEnrollment.update({
        where: { id: data.enrollmentId },
        data: { feeStatus: 'PAID', feePaidPaise: { increment: data.amountPaise } },
      }),
    ])
    return payment
  }

  async sendFeeReminder(feePaymentId: string, userId: string) {
    const payment = await prisma.feePayment.findUnique({ where: { id: feePaymentId } })
    if (!payment) throw Errors.notFound('Fee payment')
    await this.verifyOwnership(payment.academyId, userId)
    await prisma.feePayment.update({
      where: { id: feePaymentId },
      data: { remindersSent: { increment: 1 }, lastReminderAt: new Date() },
    })
    return { message: 'Reminder sent' }
  }

  async createAnnouncement(academyId: string, userId: string, data: any) {
    const ownerProfile = await prisma.academyOwnerProfile.findUnique({ where: { userId } })
    await this.verifyOwnership(academyId, userId)
    return prisma.announcement.create({
      data: {
        academyId, authorId: ownerProfile!.id,
        title: data.title, body: data.body,
        targetGroup: data.targetGroup || 'ALL',
        isPinned: data.isPinned || false,
        sentVia: data.sentVia || ['PUSH'],
      },
    })
  }

  async getInventory(academyId: string, userId: string) {
    await this.verifyOwnership(academyId, userId)
    return prisma.inventoryItem.findMany({ where: { academyId }, orderBy: { name: 'asc' } })
  }

  async addInventoryItem(academyId: string, userId: string, data: any) {
    await this.verifyOwnership(academyId, userId)
    return prisma.inventoryItem.create({
      data: {
        academyId, name: data.name, category: data.category,
        quantity: data.quantity || 1, condition: data.condition || 'GOOD',
        purchasedAt: data.purchasedAt ? new Date(data.purchasedAt) : undefined,
        cost: data.cost, notes: data.notes,
      },
    })
  }

  private async verifyOwnership(academyId: string, userId: string) {
    const ownerProfile = await prisma.academyOwnerProfile.findUnique({ where: { userId } })
    if (!ownerProfile) throw Errors.forbidden()
    const academy = await prisma.academy.findFirst({ where: { id: academyId, ownerId: ownerProfile.id } })
    if (!academy) throw Errors.forbidden()
    return academy
  }

  private async verifyAcademyAccess(academyId: string, userId: string) {
    const ownerProfile = await prisma.academyOwnerProfile.findUnique({ where: { userId } })
    if (ownerProfile) {
      const ownedAcademy = await prisma.academy.findFirst({
        where: { id: academyId, ownerId: ownerProfile.id },
      })
      if (ownedAcademy) return ownedAcademy
    }

    const coachProfile = await prisma.coachProfile.findUnique({ where: { userId } })
    if (coachProfile) {
      const academyCoach = await prisma.academyCoach.findFirst({
        where: { academyId, coachId: coachProfile.id, isActive: true },
      })
      if (academyCoach) {
        return prisma.academy.findUnique({ where: { id: academyId } })
      }
    }

    throw Errors.forbidden()
  }
}
