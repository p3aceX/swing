import { prisma } from '@swing/db'
import { Errors, AppError } from '../../lib/errors'
import crypto from 'crypto'
import Razorpay from 'razorpay'
import { StoreService } from '../store/store.service'

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

type EntityType = 'SLOT_BOOKING' | 'GIG_BOOKING' | 'ACADEMY_FEE' | 'STORE_ORDER' | 'MATCHMAKING_MATCH'

export class PaymentService {
  async createOrder(userId: string, data: { entityType: EntityType; entityId: string }) {
    const { amountPaise, description } = await this.resolveEntity(data.entityType, data.entityId, userId)

    const razorpayOrder = await getRazorpay().orders.create({
      amount: amountPaise,
      currency: 'INR',
      receipt: `swing_${data.entityType.toLowerCase()}_${data.entityId.slice(0, 12)}`,
      notes: { entityType: data.entityType, entityId: data.entityId, userId },
    })

    const payment = await prisma.payment.create({
      data: {
        userId,
        entityType: data.entityType,
        entityId: data.entityId,
        amountPaise,
        currency: 'INR',
        status: 'PENDING',
        gateway: 'RAZORPAY',
        gatewayOrderId: razorpayOrder.id,
        description,
      },
    })

    return {
      payment,
      razorpayOrder: {
        id: razorpayOrder.id,
        amount: razorpayOrder.amount,
        currency: razorpayOrder.currency,
        key: process.env.RAZORPAY_KEY_ID,
      },
    }
  }

  async verifyPayment(data: {
    razorpayOrderId: string
    razorpayPaymentId: string
    razorpaySignature: string
  }) {
    const expectedSignature = crypto
      .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET || '')
      .update(`${data.razorpayOrderId}|${data.razorpayPaymentId}`)
      .digest('hex')

    if (expectedSignature !== data.razorpaySignature) {
      throw new AppError('INVALID_SIGNATURE', 'Payment signature verification failed', 400)
    }

    const payment = await prisma.payment.findFirst({ where: { gatewayOrderId: data.razorpayOrderId } })
    if (!payment) throw Errors.notFound('Payment')
    if (payment.status === 'COMPLETED') return payment

    const updatedPayment = await prisma.payment.update({
      where: { id: payment.id },
      data: {
        status: 'COMPLETED',
        gatewayPaymentId: data.razorpayPaymentId,
        gatewaySignature: data.razorpaySignature,
        completedAt: new Date(),
      },
    })

    await this.fulfillPayment(payment.entityType as EntityType, payment.entityId!)

    return updatedPayment
  }

  async handleWebhook(body: any, signature: string) {
    const webhookSecret = process.env.RAZORPAY_WEBHOOK_SECRET || ''
    const expectedSignature = crypto
      .createHmac('sha256', webhookSecret)
      .update(JSON.stringify(body))
      .digest('hex')

    if (expectedSignature !== signature) {
      throw new AppError('INVALID_WEBHOOK', 'Webhook signature invalid', 400)
    }

    const event = body.event
    const paymentEntity = body.payload?.payment?.entity

    if (event === 'payment.captured' && paymentEntity) {
      const payment = await prisma.payment.findFirst({ where: { gatewayOrderId: paymentEntity.order_id } })
      if (payment && payment.status !== 'COMPLETED') {
        await prisma.payment.update({
          where: { id: payment.id },
          data: { status: 'COMPLETED', gatewayPaymentId: paymentEntity.id, completedAt: new Date() },
        })
        if (payment.entityType && payment.entityId) {
          await this.fulfillPayment(payment.entityType as EntityType, payment.entityId)
        }
      }
    } else if (event === 'payment.failed' && paymentEntity) {
      const payment = await prisma.payment.findFirst({ where: { gatewayOrderId: paymentEntity.order_id } })
      if (payment) {
        await prisma.payment.update({ where: { id: payment.id }, data: { status: 'FAILED' } })
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

  async initiateRefund(paymentId: string, userId: string, reason?: string) {
    const payment = await prisma.payment.findUnique({ where: { id: paymentId } })
    if (!payment) throw Errors.notFound('Payment')
    if (payment.userId !== userId) throw Errors.forbidden()
    if (payment.status !== 'COMPLETED') {
      throw new AppError('NOT_REFUNDABLE', 'Payment is not eligible for refund', 400)
    }
    if (!payment.gatewayPaymentId) throw new AppError('NO_PAYMENT_ID', 'Gateway payment ID missing', 400)

    await getRazorpay().payments.refund(payment.gatewayPaymentId, {
      amount: payment.amountPaise,
      notes: { reason: reason || 'Customer requested refund' },
    })

    return prisma.payment.update({ where: { id: paymentId }, data: { status: 'REFUND_PENDING', refundReason: reason } })
  }

  async getPayment(paymentId: string, userId: string) {
    const payment = await prisma.payment.findUnique({ where: { id: paymentId } })
    if (!payment) throw Errors.notFound('Payment')
    if (payment.userId !== userId) throw Errors.forbidden()
    return payment
  }

  async getUserPayments(userId: string, page: number, limit: number) {
    const [payments, total] = await prisma.$transaction([
      prisma.payment.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.payment.count({ where: { userId } }),
    ])
    return { payments, total, page, limit }
  }

  private async resolveEntity(entityType: EntityType, entityId: string, userId: string) {
    switch (entityType) {
      case 'SLOT_BOOKING': {
        const booking = await prisma.slotBooking.findUnique({ where: { id: entityId } })
        if (!booking) throw Errors.notFound('Slot booking')
        return { amountPaise: booking.totalAmountPaise, description: `Arena slot booking ${entityId}` }
      }
      case 'GIG_BOOKING': {
        const booking = await prisma.gigBooking.findUnique({ where: { id: entityId } })
        if (!booking) throw Errors.notFound('Gig booking')
        return { amountPaise: booking.amountPaise, description: `Coaching gig booking ${entityId}` }
      }
      case 'ACADEMY_FEE': {
        const enrollment = await prisma.academyEnrollment.findUnique({ where: { id: entityId } })
        if (!enrollment) throw Errors.notFound('Enrollment')
        return { amountPaise: enrollment.feePaidPaise || 0, description: `Academy fee ${entityId}` }
      }
      case 'STORE_ORDER': {
        const order = await prisma.storeOrder.findUnique({ where: { id: entityId } })
        if (!order) throw Errors.notFound('Store order')
        return { amountPaise: order.finalAmountPaise, description: `Store order ${entityId}` }
      }
      case 'MATCHMAKING_MATCH': {
        const match = await prisma.matchmakingMatch.findUnique({ where: { id: entityId } })
        if (!match) throw Errors.notFound('Match')
        return { amountPaise: match.paymentAmountPerTeam, description: `Matchup slot booking ${entityId}` }
      }
      default:
        throw new AppError('INVALID_ENTITY', 'Unknown entity type', 400)
    }
  }

  private async fulfillPayment(entityType: EntityType, entityId: string) {
    switch (entityType) {
      case 'SLOT_BOOKING':
        await prisma.slotBooking.update({ where: { id: entityId }, data: { status: 'CONFIRMED', paidAt: new Date() } })
        break
      case 'GIG_BOOKING':
        await prisma.gigBooking.update({ where: { id: entityId }, data: { status: 'CONFIRMED', paidAt: new Date() } })
        break
      case 'ACADEMY_FEE':
        await prisma.academyEnrollment.update({ where: { id: entityId }, data: { feeStatus: 'PAID' } })
        break
      case 'STORE_ORDER': {
        await prisma.storeOrder.update({
          where: { id: entityId },
          data: { status: 'PAID', updatedAt: new Date() },
        })
        const storeSvc = new StoreService()
        await storeSvc.generateInvoice(entityId)
        break
      }
      case 'MATCHMAKING_MATCH': {
        await prisma.$transaction(async (tx) => {
          const match = await tx.matchmakingMatch.findUnique({ where: { id: entityId } })
          if (!match || match.status === 'confirmed') return

          const unit = await tx.arenaUnit.findUnique({ where: { id: match.groundId } })
          if (!unit) throw Errors.notFound('Arena unit')

          const [aLobby, bLobby] = await Promise.all([
            tx.matchmakingLobby.findUnique({ where: { id: match.lobbyAId } }),
            tx.matchmakingLobby.findUnique({ where: { id: match.lobbyBId } }),
          ])
          if (!aLobby || !bLobby) throw new AppError('INVALID_MATCH', 'Lobby not found', 400)

          const durations: Record<string, number> = { T10: 90, T20: 240, ODI: 480, Test: 2400, Custom: 240 }
          const durationMins = durations[match.format as string] ?? 240
          const [sh, sm] = match.slotTime.split(':').map(Number)
          const endMins = sh * 60 + sm + durationMins
          const endTime = `${String(Math.floor(endMins / 60)).padStart(2, '0')}:${String(endMins % 60).padStart(2, '0')}`
          const totalAmount = match.paymentAmountPerTeam * 2

          await tx.slotBooking.create({
            data: {
              arenaId: unit.arenaId,
              unitId: unit.id,
              bookedById: aLobby.playerId,
              date: match.date,
              startTime: match.slotTime,
              endTime,
              durationMins,
              baseAmountPaise: totalAmount,
              totalAmountPaise: totalAmount,
              totalPricePaise: totalAmount,
              advancePaise: totalAmount,
              status: 'CONFIRMED',
              paymentMode: 'ONLINE',
              bookingSource: 'MATCHMAKING',
              notes: `matchmaking:${match.id};teamA:${aLobby.teamId};teamB:${bLobby.teamId}`,
              paidAt: new Date(),
            } as any,
          })

          await tx.matchmakingMatch.update({
            where: { id: entityId },
            data: { status: 'confirmed', teamAConfirmed: true, teamBConfirmed: true },
          })
          await tx.matchmakingLobby.updateMany({
            where: { id: { in: [match.lobbyAId, match.lobbyBId] } },
            data: { status: 'confirmed' },
          })
        })
        break
      }
    }
  }
}
