import { prisma } from '@swing/db'
import { Errors, AppError } from '../../lib/errors'

const PLATFORM_FEE_PERCENT = 15
const COACH_PAYOUT_PERCENT = 85

export class GigService {
  async createListing(userId: string, data: {
    title: string
    description: string
    sessionType: string
    durationMins: number
    pricePerSessionPaise: number
    maxStudents: number
    targetBattingStyle?: string[]
    targetBowlingStyle?: string[]
    targetAgeMin?: number
    targetAgeMax?: number
    isOnline: boolean
    locationName?: string
    latitude?: number
    longitude?: number
    availableDates?: string[]
    tags?: string[]
  }) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    if (!coach) throw new AppError('NOT_COACH', 'Must have a coach profile to create gig listings', 403)

    const platformFeePaise = Math.round(data.pricePerSessionPaise * PLATFORM_FEE_PERCENT / 100)
    const coachPayoutPaise = data.pricePerSessionPaise - platformFeePaise
    const sessionType = data.isOnline ? 'ONLINE' : 'IN_PERSON'

    return prisma.gigListing.create({
      data: {
        coachId: coach.id,
        title: data.title,
        description: data.description,
        gigType: data.sessionType,
        sessionType: sessionType as any,
        durationMins: data.durationMins,
        pricePaise: data.pricePerSessionPaise,
        pricePerSessionPaise: data.pricePerSessionPaise,
        platformFeePaise,
        coachPayoutPaise,
        maxStudents: data.maxStudents,
        targetBattingStyle: data.targetBattingStyle || [],
        targetBowlingStyle: data.targetBowlingStyle || [],
        targetAgeMin: data.targetAgeMin,
        targetAgeMax: data.targetAgeMax,
        isOnline: data.isOnline,
        locationName: data.locationName,
        latitude: data.latitude,
        longitude: data.longitude,
        availableDates: data.availableDates ? data.availableDates.map(d => new Date(d)) : [],
        tags: data.tags || [],
        isActive: true,
      },
      include: { coach: { include: { user: { select: { name: true, avatarUrl: true } } } } },
    })
  }

  async listGigs(filters: {
    sessionType?: string
    sport?: string
    isOnline?: boolean
    lat?: number
    lng?: number
    radiusKm?: number
    minPrice?: number
    maxPrice?: number
    page: number
    limit: number
  }) {
    const where: any = { isActive: true }
    if (filters.sessionType) where.gigType = filters.sessionType
    if (filters.sport) where.sport = filters.sport as any
    if (filters.isOnline !== undefined) where.isOnline = filters.isOnline
    if (filters.minPrice) where.pricePerSessionPaise = { gte: filters.minPrice }
    if (filters.maxPrice) {
      where.pricePerSessionPaise = { ...where.pricePerSessionPaise, lte: filters.maxPrice }
    }

    const [gigs, total] = await prisma.$transaction([
      prisma.gigListing.findMany({
        where,
        include: { coach: { include: { user: { select: { name: true, avatarUrl: true } } } } },
        orderBy: { createdAt: 'desc' },
        skip: (filters.page - 1) * filters.limit,
        take: filters.limit,
      }),
      prisma.gigListing.count({ where }),
    ])

    let results = gigs
    if (filters.lat && filters.lng && filters.radiusKm) {
      results = gigs.filter(g => {
        if (g.isOnline) return true
        if (!g.latitude || !g.longitude) return false
        return this.haversineKm(filters.lat!, filters.lng!, g.latitude, g.longitude) <= filters.radiusKm!
      })
    }

    return { gigs: results, total, page: filters.page, limit: filters.limit }
  }

  async getGig(gigId: string) {
    const gig = await prisma.gigListing.findUnique({
      where: { id: gigId },
      include: {
        coach: { include: { user: { select: { name: true, avatarUrl: true, phone: true } } } },
        bookings: { where: { status: { in: ['CONFIRMED', 'COMPLETED'] } }, select: { id: true } },
      },
    })
    if (!gig) throw Errors.notFound('Gig listing')
    return { ...gig, bookedCount: gig.bookings.length }
  }

  async bookGig(userId: string, gigId: string, data: { scheduledAt: string; notes?: string }) {
    const player = await prisma.playerProfile.findUnique({ where: { userId } })
    if (!player) throw Errors.notFound('Player profile')

    const gig = await prisma.gigListing.findUnique({ where: { id: gigId } })
    if (!gig || !gig.isActive) throw Errors.notFound('Gig listing')

    // Check if already booked
    const existing = await prisma.gigBooking.findFirst({
      where: {
        gigListingId: gigId,
        playerProfileId: player.id,
        status: { in: ['PENDING_PAYMENT', 'CONFIRMED'] },
      },
    })
    if (existing) throw new AppError('ALREADY_BOOKED', 'You already have an active booking for this gig', 409)

    // Check capacity
    const confirmedCount = await prisma.gigBooking.count({
      where: { gigListingId: gigId, status: { in: ['CONFIRMED', 'COMPLETED'] } },
    })
    if (confirmedCount >= gig.maxStudents) {
      throw new AppError('GIG_FULL', 'This gig session is fully booked', 400)
    }

    return prisma.gigBooking.create({
      data: {
        gigListingId: gigId,
        coachId: gig.coachId,
        playerProfileId: player.id,
        sessionType: gig.sessionType,
        scheduledAt: new Date(data.scheduledAt),
        durationMins: gig.durationMins,
        locationName: gig.locationName,
        amountPaise: gig.pricePerSessionPaise,
        platformFeePaise: gig.platformFeePaise,
        coachPayoutPaise: gig.coachPayoutPaise,
        status: 'PENDING_PAYMENT',
        playerGoals: data.notes,
      },
      include: { gigListing: { include: { coach: { include: { user: { select: { name: true } } } } } } },
    })
  }

  async cancelGigBooking(bookingId: string, userId: string) {
    const player = await prisma.playerProfile.findUnique({ where: { userId } })
    if (!player) throw Errors.forbidden()

    const booking = await prisma.gigBooking.findUnique({ where: { id: bookingId } })
    if (!booking) throw Errors.notFound('Gig booking')
    if (booking.playerProfileId !== player.id) throw Errors.forbidden()
    if (!['PENDING_PAYMENT', 'CONFIRMED'].includes(booking.status)) {
      throw new AppError('CANNOT_CANCEL', 'Booking cannot be cancelled', 400)
    }

    return prisma.gigBooking.update({ where: { id: bookingId }, data: { status: 'CANCELLED', cancelledAt: new Date() } })
  }

  async completeGigBooking(bookingId: string, userId: string) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    if (!coach) throw Errors.forbidden()

    const booking = await prisma.gigBooking.findUnique({
      where: { id: bookingId },
      include: { gigListing: true },
    })
    if (!booking) throw Errors.notFound('Gig booking')
    if (booking.gigListing.coachId !== coach.id) throw Errors.forbidden()
    if (booking.status !== 'CONFIRMED') {
      throw new AppError('NOT_CONFIRMED', 'Booking must be confirmed to complete', 400)
    }

    return prisma.gigBooking.update({ where: { id: bookingId }, data: { status: 'COMPLETED', completedAt: new Date() } })
  }

  async getMyGigBookings(userId: string, asCoach: boolean) {
    if (asCoach) {
      const coach = await prisma.coachProfile.findUnique({ where: { userId } })
      if (!coach) return []
      return prisma.gigBooking.findMany({
        where: { gigListing: { coachId: coach.id } },
        include: { playerProfile: { include: { user: { select: { name: true, avatarUrl: true } } } }, gigListing: true },
        orderBy: { scheduledAt: 'desc' },
      })
    } else {
      const player = await prisma.playerProfile.findUnique({ where: { userId } })
      if (!player) return []
      return prisma.gigBooking.findMany({
        where: { playerProfileId: player.id },
        include: { gigListing: { include: { coach: { include: { user: { select: { name: true } } } } } } },
        orderBy: { scheduledAt: 'desc' },
      })
    }
  }

  async updateListing(gigId: string, userId: string, data: any) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    if (!coach) throw Errors.forbidden()
    const gig = await prisma.gigListing.findUnique({ where: { id: gigId } })
    if (!gig || gig.coachId !== coach.id) throw Errors.forbidden()

    const updateData: any = { ...data }
    if (data.pricePerSessionPaise) {
      updateData.pricePaise = data.pricePerSessionPaise
      updateData.platformFeePaise = Math.round(data.pricePerSessionPaise * PLATFORM_FEE_PERCENT / 100)
      updateData.coachPayoutPaise = data.pricePerSessionPaise - updateData.platformFeePaise
    }
    return prisma.gigListing.update({ where: { id: gigId }, data: updateData })
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
}
