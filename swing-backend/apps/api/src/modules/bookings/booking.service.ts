import { prisma } from '@swing/db'
import { Errors, AppError } from '../../lib/errors'
import { holdSlot, releaseSlot, isSlotHeld } from '../../lib/redis'
import Razorpay from 'razorpay'
import crypto from 'crypto'

type PaymentMode = 'CASH' | 'UPI' | 'CARD' | 'BANK_TRANSFER' | 'ONLINE'

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

export class BookingService {
  // ─── Player: hold a slot (temp lock via Redis) ────────────────────────────

  async holdSlot(userId: string, data: {
    arenaUnitId: string
    bookingDate: string
    startTime: string
    endTime: string
  }) {
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

  // ─── Player: confirm booking (after payment initiated) ───────────────────

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
        paymentMode: 'ONLINE',
        notes: data.notes,
      },
      include: { unit: { include: { arena: true } } },
    })

    await releaseSlot(data.arenaUnitId, data.bookingDate, data.startTime)
    return booking
  }

  // ─── Player: create Razorpay order for a booking ─────────────────────────

  async createPaymentOrder(userId: string, bookingId: string) {
    const booking = await prisma.slotBooking.findUnique({
      where: { id: bookingId },
      include: { bookedBy: { include: { user: true } } },
    })
    if (!booking) throw Errors.notFound('Booking')

    const player = await prisma.playerProfile.findUnique({ where: { userId } })
    if (!player || booking.bookedById !== player.id) throw Errors.forbidden()
    if (booking.status !== 'PENDING_PAYMENT') {
      throw new AppError('INVALID_STATE', 'Booking is not awaiting payment', 400)
    }

    // reuse existing order if already created
    const existing = await prisma.payment.findFirst({ where: { slotBookingId: bookingId, status: 'PENDING' } })
    if (existing?.gatewayOrderId) {
      return {
        bookingId,
        orderId: existing.gatewayOrderId,
        amountPaise: existing.amountPaise,
        currency: 'INR',
        key: process.env.RAZORPAY_KEY_ID,
        prefill: {
          name: booking.bookedBy.user.name ?? '',
          contact: booking.bookedBy.user.phone,
          email: booking.bookedBy.user.email ?? '',
        },
      }
    }

    const rzpOrder = await getRazorpay().orders.create({
      amount: booking.totalAmountPaise,
      currency: 'INR',
      receipt: `swing_slot_${bookingId.slice(0, 12)}`,
      notes: { entityType: 'SLOT_BOOKING', entityId: bookingId, userId },
    })

    await prisma.payment.create({
      data: {
        userId,
        entityType: 'SLOT_BOOKING',
        entityId: bookingId,
        amountPaise: booking.totalAmountPaise,
        currency: 'INR',
        status: 'PENDING',
        gateway: 'RAZORPAY',
        gatewayOrderId: rzpOrder.id,
        slotBookingId: bookingId,
        description: `Arena slot ${booking.startTime}–${booking.endTime}`,
      },
    })

    return {
      bookingId,
      orderId: rzpOrder.id,
      amountPaise: booking.totalAmountPaise,
      currency: 'INR',
      key: process.env.RAZORPAY_KEY_ID,
      prefill: {
        name: booking.bookedBy.user.name ?? '',
        contact: booking.bookedBy.user.phone,
        email: booking.bookedBy.user.email ?? '',
      },
    }
  }

  // ─── Player: verify Razorpay payment signature ───────────────────────────

  async verifyPayment(data: {
    razorpayOrderId: string
    razorpayPaymentId: string
    razorpaySignature: string
  }) {
    const expected = crypto
      .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET || '')
      .update(`${data.razorpayOrderId}|${data.razorpayPaymentId}`)
      .digest('hex')

    if (expected !== data.razorpaySignature) {
      throw new AppError('INVALID_SIGNATURE', 'Payment signature verification failed', 400)
    }

    const payment = await prisma.payment.findFirst({ where: { gatewayOrderId: data.razorpayOrderId } })
    if (!payment) throw Errors.notFound('Payment')
    if (payment.status === 'COMPLETED') return { payment }

    const [updatedPayment] = await prisma.$transaction([
      prisma.payment.update({
        where: { id: payment.id },
        data: {
          status: 'COMPLETED',
          gatewayPaymentId: data.razorpayPaymentId,
          gatewaySignature: data.razorpaySignature,
          completedAt: new Date(),
          method: 'ONLINE',
        },
      }),
      ...(payment.slotBookingId
        ? [prisma.slotBooking.update({
            where: { id: payment.slotBookingId },
            data: { status: 'CONFIRMED', paidAt: new Date(), paymentMode: 'ONLINE' },
          })]
        : []),
    ])

    return { payment: updatedPayment }
  }

  // ─── Razorpay webhook ────────────────────────────────────────────────────

  async handleWebhook(body: any, signature: string) {
    const secret = process.env.RAZORPAY_WEBHOOK_SECRET || ''
    const expected = crypto.createHmac('sha256', secret).update(JSON.stringify(body)).digest('hex')
    if (expected !== signature) throw new AppError('INVALID_WEBHOOK', 'Webhook signature invalid', 400)

    const event = body.event
    const paymentEntity = body.payload?.payment?.entity

    if (event === 'payment.captured' && paymentEntity) {
      const payment = await prisma.payment.findFirst({ where: { gatewayOrderId: paymentEntity.order_id } })
      if (payment && payment.status !== 'COMPLETED') {
        await prisma.payment.update({
          where: { id: payment.id },
          data: { status: 'COMPLETED', gatewayPaymentId: paymentEntity.id, completedAt: new Date() },
        })
        if (payment.slotBookingId) {
          await prisma.slotBooking.update({
            where: { id: payment.slotBookingId },
            data: { status: 'CONFIRMED', paidAt: new Date(), paymentMode: 'ONLINE' },
          })
        }
      }
    } else if (event === 'payment.failed' && paymentEntity) {
      const payment = await prisma.payment.findFirst({ where: { gatewayOrderId: paymentEntity.order_id } })
      if (payment) {
        await prisma.payment.update({ where: { id: payment.id }, data: { status: 'FAILED', failureReason: paymentEntity.error_description } })
      }
    } else if (event === 'refund.created') {
      const refundEntity = body.payload?.refund?.entity
      if (refundEntity) {
        const payment = await prisma.payment.findFirst({ where: { gatewayPaymentId: refundEntity.payment_id } })
        if (payment) {
          await prisma.payment.update({ where: { id: payment.id }, data: { status: 'REFUNDED', refundedAt: new Date() } })
        }
      }
    }

    return { received: true }
  }

  // ─── Owner: create manual / offline booking ──────────────────────────────

  async createManualBooking(userId: string, arenaId: string, data: {
    unitId: string
    date: string
    startTime: string
    endTime: string
    guestName: string
    guestPhone: string
    paymentMode: PaymentMode
    amountPaise: number
    advancePaise?: number   // 0 = collect later, ==amountPaise = fully paid
    notes?: string
  }) {
    const owner = await prisma.arenaOwnerProfile.findUnique({ where: { userId } })
    if (!owner) throw Errors.forbidden()

    const arena = await prisma.arena.findUnique({ where: { id: arenaId } })
    if (!arena || arena.ownerId !== owner.id) throw Errors.forbidden()

    const unit = await prisma.arenaUnit.findUnique({ where: { id: data.unitId }, include: { arena: true } })
    if (!unit || unit.arenaId !== arenaId) throw Errors.notFound('Arena unit')

    const bookingDate = this.startOfDay(data.date)

    const conflict = await prisma.slotBooking.findFirst({
      where: {
        unitId: data.unitId,
        date: bookingDate,
        status: { in: ['CONFIRMED', 'CHECKED_IN'] },
        startTime: { lt: data.endTime },
        endTime: { gt: data.startTime },
      },
    })
    if (conflict) throw Errors.slotAlreadyBooked()

    await this.assertNoArenaBlock(arenaId, data.unitId, bookingDate, data.startTime, data.endTime)

    const walkinPlayer = await this.getOrCreateWalkInPlayer(arenaId)
    const durationMins = this.calcDurationMins(data.startTime, data.endTime)

    const advance = data.advancePaise ?? 0
    const fullyPaid = advance >= data.amountPaise && data.amountPaise > 0
    const hasAdvance = advance > 0

    const booking = await prisma.slotBooking.create({
      data: {
        arenaId,
        unitId: data.unitId,
        bookedById: walkinPlayer.id,
        date: bookingDate,
        startTime: data.startTime,
        endTime: data.endTime,
        durationMins,
        baseAmountPaise: data.amountPaise,
        totalAmountPaise: data.amountPaise,
        totalPricePaise: data.amountPaise,
        advancePaise: advance,
        status: 'CONFIRMED',
        isOfflineBooking: true,
        createdByOwnerId: owner.id,
        guestName: data.guestName,
        guestPhone: data.guestPhone,
        paymentMode: hasAdvance ? data.paymentMode : null,
        paidAt: fullyPaid ? new Date() : null,
        notes: data.notes,
      },
      include: { unit: true },
    })

    // Create payment record for whatever was collected upfront
    if (hasAdvance) {
      await prisma.payment.create({
        data: {
          userId: walkinPlayer.userId,
          entityType: 'SLOT_BOOKING',
          entityId: booking.id,
          amountPaise: advance,
          currency: 'INR',
          status: 'COMPLETED',
          gateway: 'OFFLINE',
          method: data.paymentMode,
          slotBookingId: booking.id,
          completedAt: new Date(),
          description: fullyPaid
            ? `Full payment ${data.paymentMode} — ${data.guestName}`
            : `Advance ${data.paymentMode} — ${data.guestName} (balance ₹${((data.amountPaise - advance) / 100).toFixed(0)})`,
        },
      })
    }

    return booking
  }

  // ─── Owner: mark an existing booking as paid ─────────────────────────────

  async markPaid(userId: string, bookingId: string, data: {
    paymentMode: PaymentMode
    amountPaise?: number
    reference?: string
  }) {
    const owner = await prisma.arenaOwnerProfile.findUnique({ where: { userId } })
    if (!owner) throw Errors.forbidden()

    const booking = await prisma.slotBooking.findUnique({
      where: { id: bookingId },
      include: { arena: true, bookedBy: true },
    })
    if (!booking) throw Errors.notFound('Booking')
    if (booking.arena.ownerId !== owner.id) throw Errors.forbidden()
    if (booking.status === 'CANCELLED') {
      throw new AppError('INVALID_STATE', 'Cannot mark a cancelled booking as paid', 400)
    }

    const amount = data.amountPaise ?? booking.totalAmountPaise

    await prisma.$transaction([
      prisma.slotBooking.update({
        where: { id: bookingId },
        data: { status: 'CONFIRMED', paymentMode: data.paymentMode, paidAt: new Date() },
      }),
      prisma.payment.upsert({
        where: { slotBookingId: bookingId },
        update: {
          status: 'COMPLETED',
          method: data.paymentMode,
          gateway: 'OFFLINE',
          amountPaise: amount,
          completedAt: new Date(),
          description: data.reference ? `Ref: ${data.reference}` : undefined,
        },
        create: {
          userId: booking.bookedBy?.userId ?? userId,
          entityType: 'SLOT_BOOKING',
          entityId: bookingId,
          amountPaise: amount,
          currency: 'INR',
          status: 'COMPLETED',
          gateway: 'OFFLINE',
          method: data.paymentMode,
          slotBookingId: bookingId,
          completedAt: new Date(),
          description: data.reference ? `Ref: ${data.reference}` : `${data.paymentMode} payment`,
        },
      }),
    ])

    return prisma.slotBooking.findUnique({
      where: { id: bookingId },
      include: { unit: true, payment: true },
    })
  }

  // ─── Owner: cancel any booking ───────────────────────────────────────────

  async cancelByOwner(userId: string, bookingId: string, reason?: string) {
    const owner = await prisma.arenaOwnerProfile.findUnique({ where: { userId } })
    if (!owner) throw Errors.forbidden()

    const booking = await prisma.slotBooking.findUnique({
      where: { id: bookingId },
      include: { arena: true, payment: true },
    })
    if (!booking) throw Errors.notFound('Booking')
    if (booking.arena.ownerId !== owner.id) throw Errors.forbidden()
    if (booking.status === 'CANCELLED') {
      throw new AppError('ALREADY_CANCELLED', 'Booking is already cancelled', 400)
    }

    const updated = await prisma.slotBooking.update({
      where: { id: bookingId },
      data: { status: 'CANCELLED', cancellationReason: reason, cancelledAt: new Date() },
    })

    // If paid online, initiate Razorpay refund automatically
    if (booking.payment?.status === 'COMPLETED' && booking.payment.gatewayPaymentId && booking.payment.gateway === 'RAZORPAY') {
      try {
        await getRazorpay().payments.refund(booking.payment.gatewayPaymentId, {
          amount: booking.payment.amountPaise,
          notes: { reason: reason || 'Cancelled by arena owner' },
        })
        await prisma.payment.update({
          where: { id: booking.payment.id },
          data: { status: 'REFUND_PENDING', refundReason: reason },
        })
      } catch {
        // refund failure shouldn't block cancellation; log in production
      }
    }

    return updated
  }

  // ─── Owner: monthly summary for calendar badges ──────────────────────────

  async getMonthlySummary(userId: string, arenaId: string, month: string) {
    const owner = await prisma.arenaOwnerProfile.findUnique({ where: { userId } })
    if (!owner) throw Errors.forbidden()

    const arena = await prisma.arena.findUnique({ where: { id: arenaId } })
    if (!arena || arena.ownerId !== owner.id) throw Errors.forbidden()

    // month = "YYYY-MM"
    const [year, mon] = month.split('-').map(Number)
    const from = new Date(Date.UTC(year, mon - 1, 1))
    const to   = new Date(Date.UTC(year, mon, 1))       // exclusive

    const bookings = await prisma.slotBooking.findMany({
      where: {
        arenaId,
        date: { gte: from, lt: to },
        status: { notIn: ['CANCELLED', 'HELD'] },
      },
      select: { date: true, totalAmountPaise: true, status: true },
    })

    const summary: Record<string, { count: number; revenuePaise: number }> = {}
    for (const b of bookings) {
      const key = b.date.toISOString().split('T')[0]
      if (!summary[key]) summary[key] = { count: 0, revenuePaise: 0 }
      summary[key].count++
      if (['CONFIRMED', 'CHECKED_IN', 'COMPLETED'].includes(b.status)) {
        summary[key].revenuePaise += b.totalAmountPaise
      }
    }

    return summary
  }

  // ─── Owner: CRM — list unique guests with aggregated stats ───────────────

  async listArenaGuests(userId: string, arenaId: string, search?: string) {
    console.log(`[customers] listArenaGuests arenaId=${arenaId} search=${search}`)
    const owner = await prisma.arenaOwnerProfile.findUnique({ where: { userId } })
    if (!owner) throw Errors.forbidden()
    const arena = await prisma.arena.findUnique({ where: { id: arenaId } })
    if (!arena || arena.ownerId !== owner.id) throw Errors.forbidden()

    const bookings = await prisma.slotBooking.findMany({
      where: {
        arenaId,
        isOfflineBooking: true,
        status: { notIn: ['HELD', 'CANCELLED'] },
        guestPhone: { not: null },
      },
      select: {
        id: true,
        guestName: true,
        guestPhone: true,
        date: true,
        startTime: true,
        endTime: true,
        totalAmountPaise: true,
        advancePaise: true,
        paidAt: true,
        checkedInAt: true,
        status: true,
        arenaId: true,
        unitId: true,
        isOfflineBooking: true,
        paymentMode: true,
        unit: { select: { name: true } },
        bookedBy: { include: { user: { select: { name: true, phone: true } } } },
      },
      orderBy: { date: 'desc' },
    })

    // Group by phone
    const map = new Map<string, {
      phone: string
      name: string
      totalBookings: number
      totalSpentPaise: number
      balanceDuePaise: number
      lastDate: Date | null
      bookings: typeof bookings
    }>()

    for (const b of bookings) {
      const phone = b.guestPhone!
      if (!map.has(phone)) {
        map.set(phone, {
          phone,
          name: b.guestName ?? 'Guest',
          totalBookings: 0,
          totalSpentPaise: 0,
          balanceDuePaise: 0,
          lastDate: null,
          bookings: [],
        })
      }
      const entry = map.get(phone)!
      entry.totalBookings++
      // collected = checked-in bookings; balance = confirmed but not yet checked in
      entry.totalSpentPaise += b.checkedInAt != null ? b.totalAmountPaise : 0
      entry.balanceDuePaise += b.checkedInAt == null ? b.totalAmountPaise : 0
      if (!entry.lastDate || (b.date && b.date > entry.lastDate)) entry.lastDate = b.date
      entry.bookings.push(b)
    }

    let guests = Array.from(map.values())

    if (search) {
      const q = search.toLowerCase()
      guests = guests.filter(g =>
        g.name.toLowerCase().includes(q) || g.phone.includes(q)
      )
    }

    // Sort: most recent first
    guests.sort((a, b) => (b.lastDate?.getTime() ?? 0) - (a.lastDate?.getTime() ?? 0))

    console.log(`[customers] returning ${guests.length} guests`)
    return guests
  }

  // ─── Player: get / list bookings ──────────────────────────────────────────

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

  // ─── Owner: list arena bookings ───────────────────────────────────────────

  async listArenaBookings(arenaId: string, userId: string, date?: string) {
    const owner = await prisma.arenaOwnerProfile.findUnique({ where: { userId } })
    if (!owner) throw Errors.forbidden()

    const arena = await prisma.arena.findUnique({ where: { id: arenaId } })
    if (!arena || arena.ownerId !== owner.id) throw Errors.forbidden()

    const where: any = { arenaId, status: { notIn: ['HELD'] } }
    if (date) where.date = this.startOfDay(date)

    return prisma.slotBooking.findMany({
      where,
      include: {
        unit: true,
        bookedBy: { include: { user: { select: { name: true, phone: true, email: true } } } },
        payment: true,
      },
      orderBy: [{ date: 'asc' }, { startTime: 'asc' }],
    })
  }

  // ─── Owner: list payments / collections for the arena ────────────────────

  async listArenaPayments(userId: string, arenaId: string, opts: {
    month?: string   // YYYY-MM
    mode?: string
  } = {}) {
    console.log(`[payments] listArenaPayments arenaId=${arenaId} opts=${JSON.stringify(opts)}`)
    const owner = await prisma.arenaOwnerProfile.findUnique({ where: { userId } })
    if (!owner) throw Errors.forbidden()
    const arena = await prisma.arena.findUnique({ where: { id: arenaId } })
    if (!arena || arena.ownerId !== owner.id) throw Errors.forbidden()

    // Date range
    let dateFrom: Date | undefined
    let dateTo: Date | undefined
    if (opts.month) {
      const [y, m] = opts.month.split('-').map(Number)
      dateFrom = new Date(Date.UTC(y, m - 1, 1))
      dateTo   = new Date(Date.UTC(y, m, 1))
    }
    console.log(`[payments] dateFrom=${dateFrom?.toISOString()} dateTo=${dateTo?.toISOString()}`)

    const bookingSelect = {
      id: true,
      date: true,
      startTime: true,
      endTime: true,
      guestName: true,
      guestPhone: true,
      totalAmountPaise: true,
      advancePaise: true,
      paidAt: true,
      checkedInAt: true,
      status: true,
      arenaId: true,
      unitId: true,
      isOfflineBooking: true,
      paymentMode: true,
      unit: { select: { name: true } },
      bookedBy: { include: { user: { select: { name: true, phone: true } } } },
    }

    // Checked-in = collection realized
    const checkedInBookings = await prisma.slotBooking.findMany({
      where: {
        arenaId,
        checkedInAt: { not: null },
        status: { notIn: ['CANCELLED'] },
        ...(dateFrom ? { date: { gte: dateFrom, lt: dateTo } } : {}),
      },
      select: bookingSelect,
      orderBy: { date: 'desc' },
    })

    // Confirmed but not yet checked in = balance pending
    const pendingBookings = await prisma.slotBooking.findMany({
      where: {
        arenaId,
        checkedInAt: null,
        status: 'CONFIRMED',
        ...(dateFrom ? { date: { gte: dateFrom, lt: dateTo } } : {}),
      },
      select: bookingSelect,
      orderBy: { date: 'asc' },
    })

    console.log(`[payments] returning ${checkedInBookings.length} checked-in, ${pendingBookings.length} pending`)
    if (checkedInBookings.length > 0) {
      const b = checkedInBookings[0]
      console.log(`[payments] first checked-in: id=${b.id} status=${b.status} checkedInAt=${b.checkedInAt} date=${b.date}`)
    }
    if (pendingBookings.length > 0) {
      const b = pendingBookings[0]
      console.log(`[payments] first pending: id=${b.id} status=${b.status} date=${b.date}`)
    }
    // Diagnostic: count all confirmed+checkedIn bookings for this arena regardless of date
    const allCheckedIn = await prisma.slotBooking.count({ where: { arenaId, checkedInAt: { not: null } } })
    const allConfirmed = await prisma.slotBooking.count({ where: { arenaId, status: 'CONFIRMED', checkedInAt: null } })
    console.log(`[payments] diagnostic — total checked-in (any date): ${allCheckedIn}, total confirmed no-checkin (any date): ${allConfirmed}`)
    return { checkedInBookings, pendingBookings }
  }

  // ─── Player: cancel booking ───────────────────────────────────────────────

  async cancelBooking(bookingId: string, userId: string) {
    const player = await prisma.playerProfile.findUnique({ where: { userId } })
    if (!player) throw Errors.forbidden()

    const booking = await prisma.slotBooking.findUnique({
      where: { id: bookingId },
      include: { payment: true },
    })
    if (!booking) throw Errors.notFound('Booking')
    if (booking.bookedById !== player.id) throw Errors.forbidden()
    if (!['PENDING_PAYMENT', 'CONFIRMED'].includes(booking.status)) {
      throw new AppError('CANNOT_CANCEL', 'Booking cannot be cancelled in its current state', 400)
    }

    const updated = await prisma.slotBooking.update({
      where: { id: bookingId },
      data: { status: 'CANCELLED', cancelledAt: new Date() },
    })

    // Auto-refund if paid online
    if (booking.payment?.status === 'COMPLETED' && booking.payment.gatewayPaymentId) {
      try {
        await getRazorpay().payments.refund(booking.payment.gatewayPaymentId, {
          amount: booking.payment.amountPaise,
          notes: { reason: 'Player cancelled booking' },
        })
        await prisma.payment.update({
          where: { id: booking.payment.id },
          data: { status: 'REFUND_PENDING', refundReason: 'Player cancelled' },
        })
      } catch { /* refund failure non-blocking */ }
    }

    return updated
  }

  // ─── Owner: check-in a booking ────────────────────────────────────────────

  async checkinByOwner(userId: string, bookingId: string) {
    const owner = await prisma.arenaOwnerProfile.findUnique({ where: { userId } })
    if (!owner) throw Errors.forbidden()

    const booking = await prisma.slotBooking.findUnique({
      where: { id: bookingId },
      include: { arena: true },
    })
    if (!booking) throw Errors.notFound('Booking')
    if (booking.arena.ownerId !== owner.id) throw Errors.forbidden()
    if (!['CONFIRMED', 'PENDING_PAYMENT'].includes(booking.status)) {
      throw new AppError('NOT_CONFIRMED', 'Booking cannot be checked in at this stage', 400)
    }

    return prisma.slotBooking.update({
      where: { id: bookingId },
      data: { status: 'CHECKED_IN', checkedInAt: new Date() },
    })
  }

  // ─── Player: check-in (self) ─────────────────────────────────────────────

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

  // ─── Helpers ──────────────────────────────────────────────────────────────

  private async getOrCreateWalkInPlayer(arenaId: string) {
    const walkinEmail = `walkin+${arenaId}@swing.internal`

    let user = await prisma.user.findUnique({ where: { email: walkinEmail } })
    if (!user) {
      user = await prisma.user.create({
        data: {
          phone: `000000000000_${arenaId.slice(0, 8)}`,
          email: walkinEmail,
          name: 'Walk-in Guest',
          roles: ['PLAYER'],
        },
      })
    }

    let player = await prisma.playerProfile.findUnique({ where: { userId: user.id } })
    if (!player) {
      player = await prisma.playerProfile.create({ data: { userId: user.id } })
    }

    return { id: player.id, userId: user.id }
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
      arena: { openTime: string; closeTime: string; operatingDays: number[] }
    },
    bookingDate: Date,
    startTime: string,
    endTime: string,
  ) {
    const durationMins = this.calcDurationMins(startTime, endTime)
    if (durationMins <= 0) throw new AppError('INVALID_DURATION', 'Booking duration must be positive', 400)

    const weekday = this.weekdayNumber(bookingDate)
    if (!unit.arena.operatingDays.includes(weekday)) {
      throw new AppError('ARENA_CLOSED', 'Arena is closed on the selected day', 400)
    }

    const openMinutes  = this.timeToMinutes(unit.arena.openTime  || '06:00')
    const closeMinutes = this.timeToMinutes(unit.arena.closeTime || '22:00')
    const startMinutes = this.timeToMinutes(startTime)
    const endMinutes   = this.timeToMinutes(endTime)

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

  private calcDurationMins(startTime: string, endTime: string) {
    const [sh, sm] = startTime.split(':').map(Number)
    const [eh, em] = endTime.split(':').map(Number)
    return eh * 60 + em - (sh * 60 + sm)
  }

  private timeToMinutes(value: string) {
    const [h, m] = value.split(':').map(Number)
    return h * 60 + m
  }

  private startOfDay(value: string): Date {
    const parsed = new Date(value)
    if (Number.isNaN(parsed.getTime())) throw new AppError('INVALID_DATE', 'Invalid date', 400)
    return new Date(Date.UTC(parsed.getUTCFullYear(), parsed.getUTCMonth(), parsed.getUTCDate()))
  }

  private weekdayNumber(value: Date) {
    const day = value.getUTCDay()
    return day === 0 ? 7 : day
  }
}
