import { prisma } from '@swing/db'
import { Errors, AppError } from '../../lib/errors'
import { holdSlot, releaseSlot, isSlotHeld } from '../../lib/redis'
import { NotificationService } from '../notifications/notification.service'
import { PhonePeService } from '../payments/phonepe.service'
import Razorpay from 'razorpay'
import crypto from 'crypto'

type PaymentMode = 'CASH' | 'UPI' | 'CARD' | 'BANK_TRANSFER' | 'ONLINE'
type LinkedArenaGuest = {
  userId: string
  playerProfileId: string
  name: string
  phone: string
  created: boolean
} | null

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

    // Enforce lead time: booking start must be at least bufferMins from now (IST)
    const istOffsetMs = (5 * 60 + 30) * 60 * 1000
    const nowUtcPlusIST = new Date(Date.now() + istOffsetMs)
    const todayIST = new Date(Date.UTC(nowUtcPlusIST.getUTCFullYear(), nowUtcPlusIST.getUTCMonth(), nowUtcPlusIST.getUTCDate()))
    const isToday = bookingDate.getTime() === todayIST.getTime()
    if (isToday) {
      const nowISTMins = nowUtcPlusIST.getUTCHours() * 60 + nowUtcPlusIST.getUTCMinutes()
      const leadTimeMins = (unit.arena as any).bufferMins ?? 30
      const startMins = this.timeToMinutes(data.startTime)
      if (startMins < nowISTMins + leadTimeMins) {
        throw new AppError('SLOT_TOO_SOON', `Booking must be at least ${leadTimeMins} minutes in advance`, 400)
      }
    }

    const conflictUnitIds = await this.getConflictUnitIds(data.arenaUnitId)
    const turnaroundMins: number = (unit as any).turnaroundMins ?? 0
    const effectiveHoldStart = turnaroundMins > 0
      ? this.minutesToTime(Math.max(0, this.timeToMinutes(data.startTime) - turnaroundMins))
      : data.startTime
    const conflict = await prisma.slotBooking.findFirst({
      where: {
        unitId: { in: conflictUnitIds },
        date: bookingDate,
        status: { in: ['CONFIRMED', 'CHECKED_IN', 'PENDING_PAYMENT'] },
        startTime: { lt: data.endTime },
        endTime: { gt: effectiveHoldStart },
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

  // ─── Player: confirm booking (after payment) ─────────────────────────────

  async createBooking(userId: string, data: {
    arenaUnitId: string
    bookingDate: string
    startTime: string
    endTime: string
    totalPricePaise: number
    advancePaise?: number
    notes?: string
    holdId?: string
    phonePeOrderId?: string
    paymentGateway?: string
    endDate?: string
    isBulkBooking?: boolean
    bulkDayRatePaise?: number
    bookingSource?: string
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

    const conflictUnitIds2 = await this.getConflictUnitIds(data.arenaUnitId)
    const turnaroundMins2: number = (unit as any).turnaroundMins ?? 0
    const effectiveBookStart = turnaroundMins2 > 0
      ? this.minutesToTime(Math.max(0, this.timeToMinutes(data.startTime) - turnaroundMins2))
      : data.startTime
    const conflict = await prisma.slotBooking.findFirst({
      where: {
        unitId: { in: conflictUnitIds2 },
        date: bookingDate,
        status: { in: ['CONFIRMED', 'CHECKED_IN', 'PENDING_PAYMENT'] },
        startTime: { lt: data.endTime },
        endTime: { gt: effectiveBookStart },
      },
    })
    if (conflict) throw Errors.slotAlreadyBooked()

    const durationMins = this.calcDurationMins(data.startTime, data.endTime)
    const isPhonePe = data.paymentGateway === 'PHONEPE' && !!data.phonePeOrderId

    // ── PhonePe: verify payment before creating booking ───────────────────
    if (isPhonePe) {
      const ppSvc = new PhonePeService()
      const status = await ppSvc.checkOrderStatus(data.phonePeOrderId!)
      if (status.state !== 'COMPLETED') {
        throw new AppError(
          'PAYMENT_NOT_COMPLETED',
          `PhonePe payment is not completed (state: ${status.state})`,
          400,
        )
      }

      const paidPaise = data.advancePaise ?? data.totalPricePaise
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
          advancePaise: paidPaise,
          status: 'CONFIRMED',
          paymentMode: 'ONLINE',
          paidAt: new Date(),
          notes: data.notes,
          bookingSource: data.bookingSource ?? 'ONLINE',
          ...(data.endDate ? { endDate: this.startOfDay(data.endDate) } : {}),
          ...(data.isBulkBooking !== undefined ? { isBulkBooking: data.isBulkBooking } : {}),
          ...(data.bulkDayRatePaise !== undefined ? { bulkDayRatePaise: data.bulkDayRatePaise } : {}),
        } as any,
        include: { unit: { include: { arena: true } } },
      })

      await prisma.payment.create({
        data: {
          userId,
          entityType: 'SLOT_BOOKING',
          entityId: booking.id,
          amountPaise: paidPaise,
          currency: 'INR',
          status: 'COMPLETED',
          gateway: 'PHONEPE',
          gatewayOrderId: data.phonePeOrderId,
          slotBookingId: booking.id,
          completedAt: new Date(),
          description: `Arena slot ${data.startTime}–${data.endTime}`,
        },
      })

      await releaseSlot(data.arenaUnitId, data.bookingDate, data.startTime)

      try {
        const notifSvc = new NotificationService()
        await notifSvc.notifyBookingConfirmed({
          id: booking.id,
          arenaId: booking.arenaId,
          unitId: booking.unitId,
          date: booking.date,
          startTime: booking.startTime,
          endTime: booking.endTime,
          bookedById: booking.bookedById,
        })
      } catch (e) {
        console.error('[Notification] bookingConfirmed error:', e)
      }

      return booking
    }

    // ── Legacy: create as PENDING_PAYMENT (Razorpay flow) ─────────────────
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
        ...(data.endDate ? { endDate: this.startOfDay(data.endDate) } : {}),
        ...(data.isBulkBooking !== undefined ? { isBulkBooking: data.isBulkBooking } : {}),
        ...(data.bulkDayRatePaise !== undefined ? { bulkDayRatePaise: data.bulkDayRatePaise } : {}),
        ...(data.bookingSource ? { bookingSource: data.bookingSource } : {}),
      } as any,
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

    if (payment.slotBookingId) {
      const confirmedBooking = await prisma.slotBooking.findUnique({ where: { id: payment.slotBookingId } })
      if (confirmedBooking) {
        try {
          const notifSvc = new NotificationService()
          await notifSvc.notifyBookingConfirmed({
            id: confirmedBooking.id,
            arenaId: confirmedBooking.arenaId,
            unitId: confirmedBooking.unitId,
            date: confirmedBooking.date,
            startTime: confirmedBooking.startTime,
            endTime: confirmedBooking.endTime,
            bookedById: confirmedBooking.bookedById,
          })
        } catch (e) {
          console.error('[Notification] bookingConfirmed error:', e)
        }
      }
    }

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
    endDate?: string
    isBulkBooking?: boolean
    bulkDayRatePaise?: number
    bookingSource?: string
    netVariantType?: string
    guestUserId?: string
    guestPlayerProfileId?: string
    createGuestUser?: boolean
  }) {
    const owner = await prisma.arenaOwnerProfile.findUnique({ where: { userId } })
    if (!owner) throw Errors.forbidden()

    const arena = await prisma.arena.findUnique({ where: { id: arenaId } })
    if (!arena || arena.ownerId !== owner.id) throw Errors.forbidden()

    const unit = await prisma.arenaUnit.findUnique({ where: { id: data.unitId }, include: { arena: true } })
    if (!unit || unit.arenaId !== arenaId) throw Errors.notFound('Arena unit')

    const bookingDate = this.startOfDay(data.date)

    const conflictUnitIds3 = await this.getConflictUnitIds(data.unitId)
    const turnaroundMins3: number = (unit as any).turnaroundMins ?? 0
    const effectiveManualStart = turnaroundMins3 > 0
      ? this.minutesToTime(Math.max(0, this.timeToMinutes(data.startTime) - turnaroundMins3))
      : data.startTime

    const variantType = data.netVariantType ?? null
    const unitNetVariants = (unit as any).netVariants as Array<{ type: string; count: number }> | null
    const matchingVariant = variantType && unitNetVariants
      ? unitNetVariants.find((v) => v.type === variantType) ?? null
      : null

    if (matchingVariant && matchingVariant.count > 1) {
      // For multi-count variants, allow up to variant.count simultaneous bookings
      const variantBookingCount = await prisma.slotBooking.count({
        where: {
          unitId: data.unitId,
          date: bookingDate,
          status: { in: ['CONFIRMED', 'CHECKED_IN', 'PENDING_PAYMENT'] },
          startTime: { lt: data.endTime },
          endTime: { gt: effectiveManualStart },
          netVariantType: variantType,
        } as any,
      })
      if (variantBookingCount >= matchingVariant.count) throw Errors.slotAlreadyBooked()
    } else {
      const conflict = await prisma.slotBooking.findFirst({
        where: {
          unitId: { in: conflictUnitIds3 },
          date: bookingDate,
          status: { in: ['CONFIRMED', 'CHECKED_IN', 'PENDING_PAYMENT'] },
          startTime: { lt: data.endTime },
          endTime: { gt: effectiveManualStart },
          ...(variantType ? { netVariantType: variantType } as any : {}),
        },
      })
      if (conflict) throw Errors.slotAlreadyBooked()
    }

    await this.assertNoArenaBlock(arenaId, data.unitId, bookingDate, data.startTime, data.endTime)

    const linkedGuest = await this.resolveArenaGuest(data.guestPhone, data.guestName, {
      guestUserId: data.guestUserId,
      guestPlayerProfileId: data.guestPlayerProfileId,
      createGuestUser: data.createGuestUser,
    })
    const walkinPlayer = linkedGuest ? null : await this.getOrCreateWalkInPlayer(arenaId)
    const bookedById = linkedGuest?.playerProfileId ?? walkinPlayer!.id
    const durationMins = this.calcDurationMins(data.startTime, data.endTime)

    const advance = data.advancePaise ?? 0
    const fullyPaid = advance >= data.amountPaise && data.amountPaise > 0
    const hasAdvance = advance > 0

    const booking = await prisma.slotBooking.create({
      data: {
        arenaId,
        unitId: data.unitId,
        bookedById,
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
        guestUserId: linkedGuest?.userId ?? null,
        guestPlayerProfileId: linkedGuest?.playerProfileId ?? null,
        guestSource: linkedGuest ? 'ARENA_BOOKING' : 'MANUAL',
        paymentMode: hasAdvance ? data.paymentMode : null,
        paidAt: fullyPaid ? new Date() : null,
        notes: data.notes,
        bookingSource: data.bookingSource ?? 'OFFLINE',
        ...(data.endDate ? { endDate: this.startOfDay(data.endDate) } : {}),
        ...(data.isBulkBooking !== undefined ? { isBulkBooking: data.isBulkBooking } : {}),
        ...(data.bulkDayRatePaise !== undefined ? { bulkDayRatePaise: data.bulkDayRatePaise } : {}),
        ...(variantType ? { netVariantType: variantType } : {}),
      } as any,
      include: { unit: true },
    })

    // Create payment record for whatever was collected upfront
    if (hasAdvance) {
      await prisma.payment.create({
        data: {
          userId: linkedGuest?.userId ?? walkinPlayer!.userId,
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
    const shouldNotifyBookingConfirmed = booking.status !== 'CONFIRMED' && booking.status !== 'CHECKED_IN'

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

    const confirmedManualBooking = await prisma.slotBooking.findUnique({
      where: { id: bookingId },
      include: { unit: true, payment: true },
    })

    if (confirmedManualBooking && shouldNotifyBookingConfirmed) {
      try {
        const notifSvc = new NotificationService()
        await notifSvc.notifyBookingConfirmed({
          id: confirmedManualBooking.id,
          arenaId: confirmedManualBooking.arenaId,
          unitId: confirmedManualBooking.unitId,
          date: confirmedManualBooking.date,
          startTime: confirmedManualBooking.startTime,
          endTime: confirmedManualBooking.endTime,
          bookedById: confirmedManualBooking.bookedById,
        })
      } catch (e) {
        console.error('[Notification] bookingConfirmed error:', e)
      }
    }

    return confirmedManualBooking
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

    try {
      const notifSvc = new NotificationService()
      await notifSvc.notifyBookingCancelled({
        id: booking.id,
        arenaId: booking.arenaId,
        unitId: booking.unitId,
        date: booking.date,
        startTime: booking.startTime,
        endTime: booking.endTime,
        bookedById: booking.bookedById,
      })
    } catch (e) {
      console.error('[Notification] bookingCancelled error:', e)
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
        guestUserId: true,
        guestPlayerProfileId: true,
        guestSource: true,
        guestUser: { select: { id: true, name: true, phone: true, avatarUrl: true, sourceLabels: true, createdVia: true } },
        guestPlayerProfile: { select: { id: true, username: true } },
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
      userId: string | null
      playerProfileId: string | null
      isLinkedUser: boolean
      lastDate: Date | null
      bookings: typeof bookings
    }>()

    for (const b of bookings) {
      const phone = b.guestUser?.phone ?? b.guestPhone!
      const key = b.guestUserId ?? phone
      if (!map.has(key)) {
        map.set(key, {
          phone,
          name: b.guestUser?.name ?? b.guestName ?? 'Guest',
          totalBookings: 0,
          totalSpentPaise: 0,
          balanceDuePaise: 0,
          userId: b.guestUserId ?? null,
          playerProfileId: b.guestPlayerProfileId ?? null,
          isLinkedUser: b.guestUserId != null,
          lastDate: null,
          bookings: [],
        })
      }
      const entry = map.get(key)!
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
    const where = {
      OR: [
        { bookedById: player.id },
        { guestPlayerProfileId: player.id } as any,
        { guestUserId: userId } as any,
      ],
    }

    const [bookings, total] = await prisma.$transaction([
      prisma.slotBooking.findMany({
        where: where as any,
        include: { unit: { include: { arena: { select: { name: true, city: true } } } } },
        orderBy: { date: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.slotBooking.count({ where: where as any }),
    ])

    return { bookings, total, page, limit }
  }

  async lookupArenaCustomer(userId: string, arenaId: string, phone: string) {
    const owner = await prisma.arenaOwnerProfile.findUnique({ where: { userId } })
    if (!owner) throw Errors.forbidden()
    const arena = await prisma.arena.findUnique({ where: { id: arenaId } })
    if (!arena || arena.ownerId !== owner.id) throw Errors.forbidden()

    const normalizedPhone = this.normalizePhone(phone)
    const user = await this.findUserByPhone(normalizedPhone, {
      playerProfile: { select: { id: true, username: true } },
    })
    if (user) {
      const playerProfileId = user.playerProfile?.id ?? null
      const username = user.playerProfile?.username ?? null
      return {
        exists: true,
        user: {
          id: user.id,
          name: user.name,
          phone: user.phone,
          avatarUrl: user.avatarUrl,
          playerProfileId,
          username,
          sourceLabels: user.sourceLabels ?? [],
          createdVia: user.createdVia ?? null,
        },
      }
    }

    const guest = await this.latestArenaGuestByPhone(arenaId, normalizedPhone)
    return {
      exists: false,
      user: null,
      guest,
    }
  }

  private async findUserByPhone(normalizedPhone: string, include: object) {
    return prisma.user.findFirst({
      where: {
        OR: [
          { phone: normalizedPhone },
          { phone: `91${normalizedPhone}` },
          { phone: `+91${normalizedPhone}` },
          { phone: { endsWith: normalizedPhone } },
        ],
      },
      include,
    } as any) as Promise<any>
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

  // ─── Player: busy slots for an arena (no sensitive data) ────────────────
  async listArenaBusySlots(arenaId: string, date?: string) {
    const where: any = { arenaId, status: { notIn: ['HELD', 'CANCELLED'] } }
    if (date) where.date = this.startOfDay(date)
    const rows = await prisma.slotBooking.findMany({
      where,
      select: { unitId: true, startTime: true, endTime: true, netVariantType: true, status: true },
    })
    return rows
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

    // Checked-in = collection realized — filter by paidAt so a future booking
    // checked-in today shows up in today's/this month's collected total.
    const checkedInBookings = await prisma.slotBooking.findMany({
      where: {
        arenaId,
        checkedInAt: { not: null },
        status: { notIn: ['CANCELLED'] },
        ...(dateFrom ? { paidAt: { gte: dateFrom, lt: dateTo } } : {}),
      },
      select: bookingSelect,
      orderBy: { paidAt: 'desc' },
    })

    // Unpaid = balance still due. Includes CONFIRMED (not yet shown up) and CHECKED_IN
    // (customer arrived but payment not recorded yet). No month filter — outstanding
    // dues are all-time, not month-scoped.
    const pendingBookings = await prisma.slotBooking.findMany({
      where: {
        arenaId,
        paidAt: null,
        status: { in: ['CONFIRMED', 'CHECKED_IN'] },
      },
      select: bookingSelect,
      orderBy: { date: 'desc' },
    })
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

    try {
      const notifSvc = new NotificationService()
      await notifSvc.notifyBookingCancelled({
        id: booking.id,
        arenaId: booking.arenaId,
        unitId: booking.unitId,
        date: booking.date,
        startTime: booking.startTime,
        endTime: booking.endTime,
        bookedById: booking.bookedById,
      })
    } catch (e) {
      console.error('[Notification] bookingCancelled error:', e)
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

  private normalizePhone(phone: string) {
    const digits = `${phone}`.replace(/\D/g, '')
    if (digits.length > 10 && digits.startsWith('91')) return digits.slice(-10)
    return digits
  }

  private async latestArenaGuestByPhone(arenaId: string, phone: string) {
    const booking = await prisma.slotBooking.findFirst({
      where: {
        arenaId,
        isOfflineBooking: true,
        guestPhone: phone,
      },
      select: {
        guestName: true,
        guestPhone: true,
        date: true,
      },
      orderBy: { date: 'desc' },
    })
    if (!booking) return null
    return {
      name: booking.guestName ?? 'Guest',
      phone: booking.guestPhone ?? phone,
      lastDate: booking.date,
    }
  }

  private async resolveArenaGuest(phone: string, name: string, options: {
    guestUserId?: string
    guestPlayerProfileId?: string
    createGuestUser?: boolean
  }): Promise<LinkedArenaGuest> {
    const normalizedPhone = this.normalizePhone(phone)
    if (!normalizedPhone || normalizedPhone.length < 10) return null

    let user = options.guestUserId
      ? await prisma.user.findUnique({
          where: { id: options.guestUserId },
          include: { playerProfile: true },
        })
      : await this.findUserByPhone(normalizedPhone, { playerProfile: true })

    if (user && this.normalizePhone(user.phone) !== normalizedPhone) {
      throw new AppError('PHONE_USER_MISMATCH', 'Selected user does not match guest phone', 400)
    }

    if (!user && options.createGuestUser) {
      user = await prisma.user.create({
        data: {
          phone: normalizedPhone,
          name: name.trim() || `Player ${normalizedPhone.slice(-4)}`,
          roles: ['PLAYER'],
          activeRole: 'PLAYER',
          createdVia: 'ARENA_BOOKING',
          sourceLabels: ['VIA_ARENA_BOOKING'],
        } as any,
        include: { playerProfile: true },
      })
    }

    if (!user) return null

    let player = user.playerProfile
    if (options.guestPlayerProfileId && player?.id !== options.guestPlayerProfileId) {
      player = await prisma.playerProfile.findUnique({ where: { id: options.guestPlayerProfileId } })
      if (!player || player.userId !== user.id) {
        throw new AppError('PLAYER_USER_MISMATCH', 'Selected player profile does not match guest user', 400)
      }
    }
    if (!player) {
      player = await prisma.playerProfile.create({ data: { userId: user.id } })
    }

    const labels = new Set([...(user.sourceLabels ?? []), 'VIA_ARENA_BOOKING'])
    if (!user.sourceLabels?.includes('VIA_ARENA_BOOKING') || !user.createdVia) {
      await prisma.user.update({
        where: { id: user.id },
        data: {
          sourceLabels: [...labels],
          createdVia: user.createdVia ?? 'ARENA_BOOKING',
        } as any,
      })
    }

    return {
      userId: user.id,
      playerProfileId: player.id,
      name: user.name,
      phone: user.phone,
      created: !options.guestUserId,
    }
  }

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

  private async getConflictUnitIds(unitId: string): Promise<string[]> {
    const unit: { id: string; parentUnitId: string | null } | null =
      await (prisma.arenaUnit as any).findUnique({
        where: { id: unitId },
        select: { id: true, parentUnitId: true },
      })
    if (!unit) return [unitId]
    const ids = [unitId]
    if (unit.parentUnitId) ids.push(unit.parentUnitId)
    const children: { id: string }[] = await (prisma.arenaUnit as any).findMany({
      where: { parentUnitId: unitId },
      select: { id: true },
    })
    ids.push(...children.map(c => c.id))
    return ids
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

    const openMinutes  = this.timeToMinutes((unit as any).openTime  || unit.arena.openTime  || '06:00')
    const closeMinutes = this.timeToMinutes((unit as any).closeTime || unit.arena.closeTime || '22:00')
    const startMinutes = this.timeToMinutes(startTime)
    const endMinutes   = this.timeToMinutes(endTime)

    if (startMinutes < openMinutes || endMinutes > closeMinutes) {
      throw new AppError('OUTSIDE_ARENA_HOURS', 'Booking must be within arena operating hours', 400)
    }

    const slotIncrement = unit.slotIncrementMins > 0 ? unit.slotIncrementMins : 60
    // Duration is validated against minSlotMins (the actual booking quantum), not slotIncrementMins
    // (slotIncrementMins = minSlotMins + turnaroundMins and must not be used to validate duration length)
    const durationUnit = unit.minSlotMins > 0 ? unit.minSlotMins : 60
    if ((startMinutes - openMinutes) % slotIncrement !== 0 || durationMins % durationUnit !== 0) {
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

  private minutesToTime(value: number): string {
    const h = Math.floor(value / 60) % 24
    const m = value % 60
    return `${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}`
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

  async createSplitBooking(userId: string, arenaId: string, data: {
    unitId: string
    date: string
    slotTime: string
    format: string
    teamId?: string
    teamName?: string
  }) {
    const owner = await prisma.arenaOwnerProfile.findUnique({ where: { userId } })
    if (!owner) throw Errors.forbidden()

    const arena = await prisma.arena.findUnique({ where: { id: arenaId } })
    if (!arena || arena.ownerId !== owner.id) throw Errors.forbidden()

    const unit = await prisma.arenaUnit.findUnique({ where: { id: data.unitId } })
    if (!unit || unit.arenaId !== arenaId) throw Errors.notFound('Arena unit')

    const bookingDate = this.startOfDay(data.date)
    const durationMins = 120
    const endMins = this.timeToMinutes(data.slotTime) + durationMins
    const endTime = this.minutesToTime(endMins)
    const pricePerTeamPaise = Math.floor(unit.pricePerHourPaise * (durationMins / 60) / 2)

    // Verify team if provided
    const team = data.teamId
      ? await prisma.team.findUnique({ where: { id: data.teamId } })
      : null

    const expiresAt = new Date(Date.now() + 48 * 60 * 60 * 1000)

    const result = await prisma.$transaction(async (tx) => {
      // Soft-block the slot
      const booking = await tx.slotBooking.create({
        data: {
          arenaId,
          unitId: unit.id,
          bookedById: owner.id,
          date: bookingDate,
          startTime: data.slotTime,
          endTime,
          durationMins,
          format: data.format as any,
          totalAmountPaise: pricePerTeamPaise * 2,
          totalPricePaise: pricePerTeamPaise * 2,
          status: 'HELD',
          isOfflineBooking: true,
          createdByOwnerId: owner.id,
          bookingSource: 'SPLIT',
        } as any,
      })

      // Create matchmaking lobby visible to players
      const lobby = await tx.matchmakingLobby.create({
        data: {
          arenaId,
          teamId: team?.id ?? null,
          playerId: null,
          format: data.format,
          date: bookingDate,
          status: 'searching',
          splitBookingId: booking.id,
          expiresAt,
        } as any,
      })

      // Attach the specific ground pick
      await tx.matchmakingLobbyPick.create({
        data: {
          lobbyId: lobby.id,
          groundId: unit.id,
          slotTime: data.slotTime,
          preferenceOrder: 1,
        },
      })

      return { booking, lobby }
    })

    return {
      bookingId: result.booking.id,
      lobbyId: result.lobby.id,
      pricePerTeamPaise,
      teamName: team?.name ?? data.teamName ?? null,
    }
  }

}
