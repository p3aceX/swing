import { prisma } from '@swing/db'
import { Errors, AppError } from '../../lib/errors'
import { holdSlot, releaseSlot, isSlotHeld } from '../../lib/redis'

export class BookingService {
  async holdSlot(userId: string, data: { arenaUnitId: string; bookingDate: string; startTime: string; endTime: string }) {
    const unit = await prisma.arenaUnit.findUnique({
      where: { id: data.arenaUnitId },
      include: { arena: true },
    })
    if (!unit || !unit.isActive) throw Errors.notFound('Arena unit')

    const bookingDate = this.startOfDay(data.bookingDate)
    await this.assertBookableWindow(unit, bookingDate, data.startTime, data.endTime)
    await this.assertNoArenaBlock(unit.arenaId, unit.id, bookingDate, data.startTime, data.endTime)

    const conflict = await prisma.slotBooking.findFirst({
      where: {
        unitId: data.arenaUnitId,
        date: bookingDate,
        status: { in: ['CONFIRMED', 'CHECKED_IN'] },
        startTime: { lt: data.endTime },
        endTime: { gt: data.startTime },
      },
    })
    if (conflict) throw Errors.slotAlreadyBooked()

    const held = await isSlotHeld(data.arenaUnitId, data.bookingDate, data.startTime)
    if (held) throw Errors.slotAlreadyBooked()

    await holdSlot(data.arenaUnitId, data.bookingDate, data.startTime, 'hold')
    const durationMins = this.calcDurationMins(data.startTime, data.endTime)
    const totalPricePaise = Math.round((unit.pricePerHourPaise * durationMins) / 60)

    return { unit, totalPricePaise, durationMins, expiresIn: 600 }
  }

  async createBooking(userId: string, data: {
    arenaUnitId: string
    bookingDate: string
    startTime: string
    endTime: string
    totalPricePaise: number
    notes?: string
  }) {
    const player = await prisma.playerProfile.findUnique({ where: { userId } })
    if (!player) throw Errors.notFound('Player profile')

    const unit = await prisma.arenaUnit.findUnique({
      where: { id: data.arenaUnitId },
      include: { arena: true },
    })
    if (!unit || !unit.isActive) throw Errors.notFound('Arena unit')

    const bookingDate = this.startOfDay(data.bookingDate)
    await this.assertBookableWindow(unit, bookingDate, data.startTime, data.endTime)
    await this.assertNoArenaBlock(unit.arenaId, unit.id, bookingDate, data.startTime, data.endTime)

    const conflict = await prisma.slotBooking.findFirst({
      where: {
        unitId: data.arenaUnitId,
        date: bookingDate,
        status: { in: ['CONFIRMED', 'CHECKED_IN'] },
        startTime: { lt: data.endTime },
        endTime: { gt: data.startTime },
      },
    })
    if (conflict) throw Errors.slotAlreadyBooked()

    const durationMins = this.calcDurationMins(data.startTime, data.endTime)

    const booking = await prisma.slotBooking.create({
      data: {
        arenaId: unit.arenaId,
        unitId: data.arenaUnitId,
        bookedById: player.id,
        date: bookingDate,
        startTime: data.startTime,
        endTime: data.endTime,
        durationMins,
        baseAmountPaise: data.totalPricePaise,
        totalAmountPaise: data.totalPricePaise,
        totalPricePaise: data.totalPricePaise,
        status: 'PENDING_PAYMENT',
        notes: data.notes,
      },
      include: { unit: { include: { arena: true } } },
    })

    await releaseSlot(data.arenaUnitId, data.bookingDate, data.startTime)

    return booking
  }

  async getBooking(bookingId: string, userId: string) {
    const player = await prisma.playerProfile.findUnique({ where: { userId } })
    const booking = await prisma.slotBooking.findUnique({
      where: { id: bookingId },
      include: { unit: { include: { arena: true } }, payment: true },
    })
    if (!booking) throw Errors.notFound('Booking')
    if (player && booking.bookedById !== player.id) throw Errors.forbidden()
    return booking
  }

  async listUserBookings(userId: string, page: number, limit: number) {
    const player = await prisma.playerProfile.findUnique({ where: { userId } })
    if (!player) return { bookings: [], total: 0 }

    const [bookings, total] = await prisma.$transaction([
      prisma.slotBooking.findMany({
        where: { bookedById: player.id },
        include: { unit: { include: { arena: { select: { name: true, city: true } } } } },
        orderBy: { date: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.slotBooking.count({ where: { bookedById: player.id } }),
    ])

    return { bookings, total, page, limit }
  }

  async cancelBooking(bookingId: string, userId: string) {
    const player = await prisma.playerProfile.findUnique({ where: { userId } })
    if (!player) throw Errors.forbidden()

    const booking = await prisma.slotBooking.findUnique({ where: { id: bookingId } })
    if (!booking) throw Errors.notFound('Booking')
    if (booking.bookedById !== player.id) throw Errors.forbidden()
    if (!['PENDING_PAYMENT', 'CONFIRMED'].includes(booking.status)) {
      throw new AppError('CANNOT_CANCEL', 'Booking cannot be cancelled in its current state', 400)
    }

    return prisma.slotBooking.update({
      where: { id: bookingId },
      data: { status: 'CANCELLED', cancelledAt: new Date() },
    })
  }

  async checkin(bookingId: string, userId: string) {
    const booking = await prisma.slotBooking.findUnique({
      where: { id: bookingId },
      include: { unit: { include: { arena: true } } },
    })
    if (!booking) throw Errors.notFound('Booking')
    if (booking.status !== 'CONFIRMED') {
      throw new AppError('NOT_CONFIRMED', 'Booking is not confirmed', 400)
    }
    return prisma.slotBooking.update({ where: { id: bookingId }, data: { status: 'CHECKED_IN', checkedInAt: new Date() } })
  }

  async listArenaBookings(arenaId: string, userId: string, date?: string) {
    const owner = await prisma.arenaOwnerProfile.findUnique({ where: { userId } })
    if (!owner) throw Errors.forbidden()
    const arena = await prisma.arena.findUnique({ where: { id: arenaId } })
    if (!arena || arena.ownerId !== owner.id) throw Errors.forbidden()

    const where: any = { arenaId }
    if (date) where.date = this.startOfDay(date)

    return prisma.slotBooking.findMany({
      where,
      include: {
        unit: true,
        bookedBy: { include: { user: { select: { name: true, phone: true } } } },
        payment: true,
      },
      orderBy: [{ date: 'asc' }, { startTime: 'asc' }],
    })
  }

  private async assertNoArenaBlock(
    arenaId: string,
    unitId: string,
    bookingDate: Date,
    startTime: string,
    endTime: string,
  ) {
    const weekday = this.weekdayNumber(bookingDate)
    const conflict = await prisma.arenaTimeBlock.findFirst({
      where: {
        arenaId,
        unitId,
        startTime: { lt: endTime },
        endTime: { gt: startTime },
        OR: [
          { date: bookingDate },
          { isRecurring: true, weekdays: { has: weekday } },
        ],
      },
    })
    if (conflict) {
      throw new AppError('SLOT_BLOCKED', conflict.reason || 'This slot is blocked by the arena', 409)
    }
  }

  private async assertBookableWindow(
    unit: {
      unitType: string
      minSlotMins: number
      maxSlotMins: number
      slotIncrementMins: number
      price4HrPaise: number | null
      price8HrPaise: number | null
      priceFullDayPaise: number | null
      arena: {
        openTime: string
        closeTime: string
        operatingDays: number[]
      }
    },
    bookingDate: Date,
    startTime: string,
    endTime: string,
  ) {
    const durationMins = this.calcDurationMins(startTime, endTime)
    if (durationMins <= 0) {
      throw new AppError('INVALID_DURATION', 'Booking duration must be positive', 400)
    }

    const weekday = this.weekdayNumber(bookingDate)
    if (!unit.arena.operatingDays.includes(weekday)) {
      throw new AppError('ARENA_CLOSED', 'Arena is closed on the selected day', 400)
    }

    const openMinutes = this.timeToMinutes(unit.arena.openTime || '06:00')
    const closeMinutes = this.timeToMinutes(unit.arena.closeTime || '22:00')
    const startMinutes = this.timeToMinutes(startTime)
    const endMinutes = this.timeToMinutes(endTime)
    if (startMinutes < openMinutes || endMinutes > closeMinutes) {
      throw new AppError('OUTSIDE_ARENA_HOURS', 'Booking must be within arena operating hours', 400)
    }

    const slotIncrement = unit.slotIncrementMins > 0 ? unit.slotIncrementMins : 60
    if ((startMinutes - openMinutes) % slotIncrement !== 0 || durationMins % slotIncrement !== 0) {
      throw new AppError('INVALID_SLOT_ALIGNMENT', 'Booking must match the unit slot timing', 400)
    }

    const isGround = unit.unitType === 'FULL_GROUND' || unit.unitType === 'HALF_GROUND'
    if (isGround) {
      const allowedDurations = [
        60,
        ...(unit.price4HrPaise ? [240] : []),
        ...(unit.price8HrPaise ? [480] : []),
        ...(unit.priceFullDayPaise ? [720] : []),
      ]
      if (!allowedDurations.includes(durationMins)) {
        throw new AppError('INVALID_DURATION', 'Ground booking duration is not supported for this unit', 400)
      }
      return
    }

    if (durationMins < unit.minSlotMins || durationMins > unit.maxSlotMins) {
      throw new AppError('INVALID_DURATION', 'Booking duration is outside the unit limits', 400)
    }
  }

  private calcDurationMins(startTime: string, endTime: string): number {
    const [sh, sm] = startTime.split(':').map(Number)
    const [eh, em] = endTime.split(':').map(Number)
    return eh * 60 + em - (sh * 60 + sm)
  }

  private timeToMinutes(value: string): number {
    const [hours, minutes] = value.split(':').map(Number)
    return hours * 60 + minutes
  }

  private startOfDay(value: string): Date {
    const parsed = new Date(value)
    if (Number.isNaN(parsed.getTime())) {
      throw new AppError('INVALID_DATE', 'Invalid date', 400)
    }
    return new Date(Date.UTC(parsed.getUTCFullYear(), parsed.getUTCMonth(), parsed.getUTCDate()))
  }

  private weekdayNumber(value: Date): number {
    const day = value.getUTCDay()
    return day === 0 ? 7 : day
  }
}
