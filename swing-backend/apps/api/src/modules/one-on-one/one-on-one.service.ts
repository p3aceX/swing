import { prisma } from '@swing/db'
import { Errors } from '../../lib/errors'

export class OneOnOneService {
  private async getCoach(userId: string) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    if (!coach) throw Errors.forbidden()
    return coach
  }

  // Set up coach's 1-on-1 profile
  async setupProfile(coachUserId: string, data: {
    isEnabled: boolean
    expertiseTags?: string[]
    bio?: string
    pricePerSession?: object // { mins60, mins90, mins120 } in paise
    locationTypes?: string[]
    maxPerWeek?: number
  }) {
    const coach = await this.getCoach(coachUserId)
    const profile = await prisma.oneOnOneProfile.upsert({
      where: { coachId: coach.id },
      create: {
        coachId: coach.id,
        isEnabled: data.isEnabled,
        expertiseTags: data.expertiseTags ?? [],
        bio: data.bio,
        pricePerSession: (data.pricePerSession as any) ?? {},
        locationTypes: data.locationTypes ?? [],
        maxPerWeek: data.maxPerWeek,
      },
      update: {
        isEnabled: data.isEnabled,
        expertiseTags: data.expertiseTags,
        bio: data.bio,
        pricePerSession: (data.pricePerSession as any) ?? {},
        locationTypes: data.locationTypes,
        maxPerWeek: data.maxPerWeek,
        updatedAt: new Date(),
      },
    })
    // Also update coach profile flag
    await prisma.coachProfile.update({ where: { id: coach.id }, data: { oneOnOneEnabled: data.isEnabled } })
    return profile
  }

  async getMyProfile(coachUserId: string) {
    const coach = await this.getCoach(coachUserId)
    return prisma.oneOnOneProfile.findUnique({
      where: { coachId: coach.id },
      include: { slots: true },
    })
  }

  // Manage availability slots
  async setSlots(coachUserId: string, slots: Array<{ dayOfWeek: number; startTime: string; endTime: string }>) {
    const coach = await this.getCoach(coachUserId)
    const profile = await prisma.oneOnOneProfile.findUnique({ where: { coachId: coach.id } })
    if (!profile) throw Errors.notFound('1-on-1 profile — set up first')

    // Replace all slots
    await prisma.oneOnOneSlot.deleteMany({ where: { profileId: profile.id } })
    if (slots.length > 0) {
      await prisma.oneOnOneSlot.createMany({
        data: slots.map((s) => ({ profileId: profile.id, ...s, isActive: true })),
      })
    }
    return prisma.oneOnOneProfile.findUnique({ where: { id: profile.id }, include: { slots: true } })
  }

  // Student/player creates a booking request
  async requestBooking(playerUserId: string, data: {
    coachId: string // CoachProfile.id
    sessionDate: string
    startTime: string
    durationMins: number
    locationType: string
    locationDetails?: string
    studentNote?: string
    academyId?: string
  }) {
    const player = await prisma.playerProfile.findUnique({ where: { userId: playerUserId } })
    if (!player) throw Errors.forbidden()

    const profile = await prisma.oneOnOneProfile.findUnique({
      where: { coachId: data.coachId },
      include: { coach: { include: { user: { select: { name: true } } } } },
    })
    if (!profile || !profile.isEnabled) throw new (require('../../lib/errors').AppError)('COACH_NOT_AVAILABLE', 'Coach not available for 1-on-1', 400)

    // Get price from profile
    const prices = profile.pricePerSession as Record<string, number>
    const priceKey = `mins${data.durationMins}`
    const priceAmountPaise = prices[priceKey] ?? 0
    const platformFeePaise = Math.round(priceAmountPaise * 0.10)
    const coachPayoutPaise = priceAmountPaise - platformFeePaise

    return prisma.oneOnOneBooking.create({
      data: {
        profileId: profile.id,
        coachId: data.coachId,
        playerProfileId: player.id,
        academyId: data.academyId,
        sessionDate: new Date(data.sessionDate),
        startTime: data.startTime,
        durationMins: data.durationMins,
        locationType: data.locationType,
        locationDetails: data.locationDetails,
        priceAmountPaise,
        platformFeePaise,
        coachPayoutPaise,
        studentNote: data.studentNote,
        status: 'REQUESTED',
      },
      include: {
        playerProfile: { include: { user: { select: { name: true, phone: true, avatarUrl: true } } } },
      },
    })
  }

  // Coach accepts or rejects a booking
  async respondToBooking(coachUserId: string, bookingId: string, accept: boolean, rejectReason?: string) {
    const coach = await this.getCoach(coachUserId)
    const booking = await prisma.oneOnOneBooking.findFirst({ where: { id: bookingId, coachId: coach.id } })
    if (!booking) throw Errors.notFound('Booking')
    if (booking.status !== 'REQUESTED') throw new (require('../../lib/errors').AppError)('INVALID_STATUS', 'Booking already responded to', 400)

    return prisma.oneOnOneBooking.update({
      where: { id: bookingId },
      data: {
        status: accept ? 'ACCEPTED' : 'REJECTED',
        rejectReason: !accept ? rejectReason : null,
        updatedAt: new Date(),
      },
    })
  }

  // Mark booking as completed (coach)
  async completeBooking(coachUserId: string, bookingId: string, coachNote?: string) {
    const coach = await this.getCoach(coachUserId)
    const booking = await prisma.oneOnOneBooking.findFirst({ where: { id: bookingId, coachId: coach.id } })
    if (!booking) throw Errors.notFound('Booking')
    return prisma.oneOnOneBooking.update({
      where: { id: bookingId },
      data: { status: 'COMPLETED', completedAt: new Date(), coachNote },
    })
  }

  // List coach's 1-on-1 bookings
  async listCoachBookings(coachUserId: string, status?: string) {
    const coach = await this.getCoach(coachUserId)
    return prisma.oneOnOneBooking.findMany({
      where: {
        coachId: coach.id,
        ...(status ? { status } : {}),
      },
      include: {
        playerProfile: { include: { user: { select: { name: true, phone: true, avatarUrl: true } } } },
      },
      orderBy: { sessionDate: 'asc' },
    })
  }

  // Coach 1-on-1 earnings summary
  async getCoachOneOnOneEarnings(coachUserId: string) {
    const coach = await this.getCoach(coachUserId)
    const now = new Date()
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1)

    const [totalEarnings, thisMonthEarnings, completedCount, pendingBookings] = await Promise.all([
      prisma.oneOnOneBooking.aggregate({
        where: { coachId: coach.id, status: 'COMPLETED' },
        _sum: { coachPayoutPaise: true },
      }),
      prisma.oneOnOneBooking.aggregate({
        where: { coachId: coach.id, status: 'COMPLETED', completedAt: { gte: monthStart } },
        _sum: { coachPayoutPaise: true },
      }),
      prisma.oneOnOneBooking.count({ where: { coachId: coach.id, status: 'COMPLETED' } }),
      prisma.oneOnOneBooking.count({ where: { coachId: coach.id, status: { in: ['REQUESTED', 'ACCEPTED'] } } }),
    ])

    return {
      totalEarningsPaise: totalEarnings._sum.coachPayoutPaise ?? 0,
      thisMonthPaise: thisMonthEarnings._sum.coachPayoutPaise ?? 0,
      completedSessions: completedCount,
      pendingBookings,
    }
  }

  // Get public coach profile (for discovery)
  async getPublicCoachProfile(coachId: string) {
    const profile = await prisma.oneOnOneProfile.findUnique({
      where: { coachId },
      include: {
        slots: { where: { isActive: true } },
        coach: {
          include: {
            user: { select: { name: true, avatarUrl: true } },
            academies: {
              where: { isActive: true },
              include: { academy: { select: { name: true, city: true } } },
              take: 3,
            },
          },
        },
      },
    })
    if (!profile || !profile.isEnabled) throw Errors.notFound('Coach 1-on-1 profile')
    return profile
  }
}
