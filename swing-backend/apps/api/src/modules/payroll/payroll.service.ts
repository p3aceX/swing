import { prisma } from '@swing/db'
import { Errors } from '../../lib/errors'

export class PayrollService {
  private async verifyOwner(userId: string, academyId: string) {
    const owner = await prisma.academyOwnerProfile.findUnique({ where: { userId } })
    if (!owner) throw Errors.forbidden()
    const academy = await prisma.academy.findFirst({ where: { id: academyId, ownerId: owner.id } })
    if (!academy) throw Errors.forbidden()
    return { owner, academy }
  }

  // Set or update coach compensation for an academy
  async setCoachCompensation(
    ownerUserId: string,
    academyId: string,
    coachId: string, // CoachProfile.id
    data: {
      compensationType: string
      fixedAmountPaise?: number
      perSessionAmountPaise?: number
      perBatchAmountPaise?: number
      incentiveRules?: object
      revenueSharePercent?: number
      payoutCycle?: string
      payoutDay?: number
    },
  ) {
    await this.verifyOwner(ownerUserId, academyId)
    // Verify coach is in this academy
    const link = await prisma.academyCoach.findUnique({
      where: { academyId_coachId: { academyId, coachId } },
    })
    if (!link) throw Errors.notFound('Coach in this academy')

    return prisma.coachCompensation.upsert({
      where: { academyId_coachId: { academyId, coachId } },
      create: {
        academyId,
        coachId,
        compensationType: data.compensationType as any,
        fixedAmountPaise: data.fixedAmountPaise,
        perSessionAmountPaise: data.perSessionAmountPaise,
        perBatchAmountPaise: data.perBatchAmountPaise,
        incentiveRules: data.incentiveRules ?? undefined,
        revenueSharePercent: data.revenueSharePercent,
        payoutCycle: data.payoutCycle ?? 'MONTHLY',
        payoutDay: data.payoutDay ?? 1,
        isActive: true,
      },
      update: {
        compensationType: data.compensationType as any,
        fixedAmountPaise: data.fixedAmountPaise,
        perSessionAmountPaise: data.perSessionAmountPaise,
        perBatchAmountPaise: data.perBatchAmountPaise,
        incentiveRules: data.incentiveRules ?? undefined,
        revenueSharePercent: data.revenueSharePercent,
        payoutCycle: data.payoutCycle ?? 'MONTHLY',
        payoutDay: data.payoutDay ?? 1,
        updatedAt: new Date(),
      },
      include: {
        coach: { include: { user: { select: { name: true, phone: true } } } },
      },
    })
  }

  // List all coach compensations for an academy
  async listCompensations(ownerUserId: string, academyId: string) {
    await this.verifyOwner(ownerUserId, academyId)
    return prisma.coachCompensation.findMany({
      where: { academyId, isActive: true },
      include: {
        coach: { include: { user: { select: { name: true, phone: true, avatarUrl: true } } } },
        payouts: { orderBy: { createdAt: 'desc' }, take: 3 },
      },
    })
  }

  // Calculate payout for a coach for a period
  async calculatePayout(
    ownerUserId: string,
    academyId: string,
    coachId: string,
    periodStart: string,
    periodEnd: string,
  ) {
    await this.verifyOwner(ownerUserId, academyId)
    const compensation = await prisma.coachCompensation.findUnique({
      where: { academyId_coachId: { academyId, coachId } },
    })
    if (!compensation) throw Errors.notFound('Compensation record')

    const start = new Date(periodStart)
    const end = new Date(periodEnd)

    // Count sessions conducted by coach in this academy in this period
    const sessionsCount = await prisma.practiceSession.count({
      where: {
        coachId,
        academyId,
        scheduledAt: { gte: start, lte: end },
        isCancelled: false,
      },
    })

    // Count distinct batches
    const batchesResult = await prisma.practiceSession.findMany({
      where: { coachId, academyId, scheduledAt: { gte: start, lte: end }, isCancelled: false },
      select: { batchId: true },
      distinct: ['batchId'],
    })
    const batchesCount = batchesResult.filter((b) => b.batchId !== null).length

    // Coach check-in compliance
    const totalScheduled = await prisma.practiceSession.count({
      where: { coachId, academyId, scheduledAt: { gte: start, lte: end } },
    })
    const checkedIn = await prisma.practiceSession.count({
      where: { coachId, academyId, scheduledAt: { gte: start, lte: end }, coachCheckedInAt: { not: null } },
    })
    const attendanceCompliance = totalScheduled > 0 ? Math.round((checkedIn / totalScheduled) * 100) : 100

    // Calculate base amount
    let baseAmountPaise = 0
    switch (compensation.compensationType) {
      case 'FIXED_MONTHLY':
        baseAmountPaise = compensation.fixedAmountPaise ?? 0
        break
      case 'PER_SESSION':
        baseAmountPaise = (compensation.perSessionAmountPaise ?? 0) * sessionsCount
        break
      case 'PER_BATCH':
        baseAmountPaise = (compensation.perBatchAmountPaise ?? 0) * batchesCount
        break
      case 'FIXED_PLUS_INCENTIVE':
        baseAmountPaise = compensation.fixedAmountPaise ?? 0
        break
      case 'REVENUE_SHARE':
        baseAmountPaise = 0 // calculated separately from 1-on-1 bookings
        break
    }

    // Calculate 1-on-1 revenue share
    let oneOnOneSharePaise = 0
    if (compensation.revenueSharePercent && compensation.revenueSharePercent > 0) {
      const oneOnOneBookings = await prisma.oneOnOneBooking.findMany({
        where: {
          coachId,
          academyId,
          status: 'COMPLETED',
          completedAt: { gte: start, lte: end },
        },
        select: { priceAmountPaise: true, platformFeePaise: true, academyCutPaise: true },
      })
      const totalRevenue = oneOnOneBookings.reduce((sum, b) => sum + b.priceAmountPaise, 0)
      oneOnOneSharePaise = Math.round((totalRevenue * compensation.revenueSharePercent) / 100)
    }

    const totalAmountPaise = baseAmountPaise + oneOnOneSharePaise

    return {
      coachId,
      academyId,
      compensationType: compensation.compensationType,
      periodStart: start,
      periodEnd: end,
      sessionsCount,
      batchesCount,
      attendanceCompliance,
      baseAmountPaise,
      incentiveAmountPaise: 0, // manual bonuses added when creating payout record
      oneOnOneSharePaise,
      totalAmountPaise,
    }
  }

  // Create a payout record (finalize a payout)
  async createPayoutRecord(
    ownerUserId: string,
    academyId: string,
    data: {
      coachId: string
      periodStart: string
      periodEnd: string
      sessionsCount: number
      batchesCount: number
      attendanceCompliance: number
      baseAmountPaise: number
      incentiveAmountPaise?: number
      oneOnOneSharePaise?: number
      deductionPaise?: number
      notes?: string
    },
  ) {
    await this.verifyOwner(ownerUserId, academyId)
    const compensation = await prisma.coachCompensation.findUnique({
      where: { academyId_coachId: { academyId, coachId: data.coachId } },
    })
    if (!compensation) throw Errors.notFound('Compensation record')

    const totalAmountPaise =
      (data.baseAmountPaise ?? 0) +
      (data.incentiveAmountPaise ?? 0) +
      (data.oneOnOneSharePaise ?? 0) -
      (data.deductionPaise ?? 0)

    return prisma.coachPayoutRecord.create({
      data: {
        compensationId: compensation.id,
        academyId,
        coachId: data.coachId,
        periodStart: new Date(data.periodStart),
        periodEnd: new Date(data.periodEnd),
        sessionsCount: data.sessionsCount,
        batchesCount: data.batchesCount,
        attendanceCompliance: data.attendanceCompliance,
        baseAmountPaise: data.baseAmountPaise,
        incentiveAmountPaise: data.incentiveAmountPaise ?? 0,
        oneOnOneSharePaise: data.oneOnOneSharePaise ?? 0,
        deductionPaise: data.deductionPaise ?? 0,
        totalAmountPaise,
        notes: data.notes,
        status: 'PENDING',
      },
      include: {
        coach: { include: { user: { select: { name: true, phone: true } } } },
      },
    })
  }

  // Mark payout as paid
  async markPayoutPaid(ownerUserId: string, academyId: string, payoutId: string, paymentRef?: string) {
    await this.verifyOwner(ownerUserId, academyId)
    return prisma.coachPayoutRecord.update({
      where: { id: payoutId },
      data: { status: 'PAID', paidAt: new Date(), paymentRef },
    })
  }

  // List payout records for academy
  async listPayouts(ownerUserId: string, academyId: string, status?: string) {
    await this.verifyOwner(ownerUserId, academyId)
    return prisma.coachPayoutRecord.findMany({
      where: {
        academyId,
        ...(status ? { status: status as any } : {}),
      },
      include: {
        coach: { include: { user: { select: { name: true, phone: true, avatarUrl: true } } } },
      },
      orderBy: { createdAt: 'desc' },
    })
  }

  // Coach views own payout history across all academies
  async getCoachPayoutHistory(coachUserId: string) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId: coachUserId } })
    if (!coach) throw Errors.forbidden()
    return prisma.coachPayoutRecord.findMany({
      where: { coachId: coach.id },
      include: {
        academy: { select: { name: true, logoUrl: true } },
      },
      orderBy: { periodStart: 'desc' },
      take: 24, // last 2 years
    })
  }

  // Coach views own payroll summary across active academy compensation records
  async getCoachPayrollSummary(coachUserId: string) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId: coachUserId } })
    if (!coach) throw Errors.forbidden()

    const now = new Date()
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1)
    const monthEnd = new Date(now.getFullYear(), now.getMonth() + 1, 0)

    const [compensations, paidThisMonth, pendingPayouts] = await Promise.all([
      prisma.coachCompensation.findMany({
        where: { coachId: coach.id, isActive: true },
        select: {
          academyId: true,
          compensationType: true,
          fixedAmountPaise: true,
          perSessionAmountPaise: true,
          perBatchAmountPaise: true,
        },
      }),
      prisma.coachPayoutRecord.aggregate({
        where: {
          coachId: coach.id,
          status: 'PAID',
          paidAt: { gte: monthStart, lte: monthEnd },
        },
        _sum: { totalAmountPaise: true },
        _count: { _all: true },
      }),
      prisma.coachPayoutRecord.aggregate({
        where: {
          coachId: coach.id,
          status: 'PENDING',
        },
        _sum: { totalAmountPaise: true },
        _count: { _all: true },
      }),
    ])

    const assignedMonthlyPaise = compensations.reduce((sum, compensation) => {
      if (
        compensation.compensationType === 'FIXED_MONTHLY' ||
        compensation.compensationType === 'FIXED_PLUS_INCENTIVE'
      ) {
        return sum + (compensation.fixedAmountPaise ?? 0)
      }
      return sum
    }, 0)

    return {
      assignedMonthlyPaise,
      activeCompensations: compensations.length,
      paidThisMonthPaise: paidThisMonth._sum.totalAmountPaise ?? 0,
      paidThisMonthCount: paidThisMonth._count._all ?? 0,
      pendingPayoutPaise: pendingPayouts._sum.totalAmountPaise ?? 0,
      pendingPayoutCount: pendingPayouts._count._all ?? 0,
    }
  }

  // Payroll dashboard summary for academy
  async getPayrollDashboard(ownerUserId: string, academyId: string) {
    await this.verifyOwner(ownerUserId, academyId)

    const now = new Date()
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1)
    const monthEnd = new Date(now.getFullYear(), now.getMonth() + 1, 0)

    const [totalCoaches, pendingPayouts, paidThisMonth, allCompensations] = await Promise.all([
      prisma.academyCoach.count({ where: { academyId, isActive: true } }),
      prisma.coachPayoutRecord.aggregate({
        where: { academyId, status: 'PENDING' },
        _sum: { totalAmountPaise: true },
        _count: true,
      }),
      prisma.coachPayoutRecord.aggregate({
        where: { academyId, status: 'PAID', paidAt: { gte: monthStart, lte: monthEnd } },
        _sum: { totalAmountPaise: true },
      }),
      prisma.coachCompensation.count({ where: { academyId, isActive: true } }),
    ])

    return {
      totalCoaches,
      coachesWithCompensation: allCompensations,
      pendingPayoutCount: pendingPayouts._count,
      pendingAmountPaise: pendingPayouts._sum.totalAmountPaise ?? 0,
      paidThisMonthPaise: paidThisMonth._sum.totalAmountPaise ?? 0,
    }
  }
}
