import { prisma } from '@swing/db'
import { Errors, AppError } from '../../lib/errors'
import { sendOneSignalPushNotification } from '../../lib/onesignal'
import { StoreService } from '../store/store.service'
import { SplitService } from './split.service'
import { CashfreeService } from './cashfree.service'

const CONFIRMATION_FEE_PAISE = 50000 // ₹500
const cashfree = new CashfreeService()

type EntityType = 'SLOT_BOOKING' | 'GIG_BOOKING' | 'ACADEMY_FEE' | 'STORE_ORDER' | 'MATCHMAKING_MATCH' | 'SUBSCRIPTION'

const NOTIFY_URL = process.env.CASHFREE_NOTIFY_URL || 'https://api.swingcricket.in/payments/webhook'

export class PaymentService {
  async createOrder(userId: string, data: { entityType: EntityType; entityId: string }) {
    const { amountPaise, description } = await this.resolveEntity(data.entityType, data.entityId, userId)

    const user = await prisma.user.findUnique({ where: { id: userId }, select: { id: true, name: true, phone: true, email: true } })
    if (!user) throw Errors.notFound('User')

    const payment = await prisma.payment.create({
      data: {
        userId,
        entityType: data.entityType,
        entityId: data.entityId,
        amountPaise,
        currency: 'INR',
        status: 'PENDING',
        gateway: 'CASHFREE',
        description,
      },
    })

    const cfOrder = await cashfree.createOrder({
      orderId: payment.id,
      amountPaise,
      customerId: userId,
      customerPhone: user.phone || '9000000000',
      customerEmail: user.email ?? undefined,
      customerName: user.name || 'Customer',
      notifyUrl: NOTIFY_URL,
    })

    await prisma.payment.update({
      where: { id: payment.id },
      data: { gatewayOrderId: cfOrder.order_id },
    })

    return {
      orderId: payment.id,
      sessionId: cfOrder.payment_session_id,
    }
  }

  async verifyPayment(data: { orderId: string; paymentId: string }) {
    const payment = await prisma.payment.findUnique({ where: { id: data.orderId } })
    if (!payment) throw Errors.notFound('Payment')
    if (payment.status === 'COMPLETED') return payment

    const payments = await cashfree.verifyOrder(data.orderId)
    const paid = Array.isArray(payments) && payments.some((p: any) => p.payment_status === 'SUCCESS')

    if (!paid) {
      throw new AppError('PAYMENT_NOT_COMPLETED', 'Payment has not been completed', 400)
    }

    const updatedPayment = await prisma.payment.update({
      where: { id: payment.id },
      data: {
        status: 'COMPLETED',
        gatewayPaymentId: data.paymentId,
        completedAt: new Date(),
      },
    })

    await this.fulfillPayment(payment.entityType as EntityType, payment.entityId!, updatedPayment.id, payment.userId)
    await this.triggerSplit(payment.entityType as EntityType, payment.entityId!, payment.id, payment.amountPaise)

    return updatedPayment
  }

  async handleWebhook(rawBody: string, headers: Record<string, string | string[] | undefined>) {
    const timestamp = headers['x-webhook-timestamp'] as string | undefined
    const signature = headers['x-webhook-signature'] as string | undefined
    const secretKey = process.env.CASHFREE_SECRET_KEY || ''

    if (secretKey && timestamp && signature) {
      const valid = cashfree.verifyWebhookSignature(rawBody, timestamp, signature)
      if (!valid) {
        throw new AppError('INVALID_WEBHOOK', 'Webhook signature invalid', 400)
      }
    }

    let body: any
    try {
      body = JSON.parse(rawBody)
    } catch {
      throw new AppError('INVALID_WEBHOOK_BODY', 'Could not parse webhook body', 400)
    }

    const event = body.type

    if (event === 'PAYMENT_SUCCESS_WEBHOOK') {
      const orderId = body.data?.order?.order_id
      const paymentId = body.data?.payment?.cf_payment_id?.toString()
      if (orderId) {
        const payment = await prisma.payment.findFirst({ where: { id: orderId } })
        if (payment && payment.status !== 'COMPLETED') {
          await prisma.payment.update({
            where: { id: payment.id },
            data: { status: 'COMPLETED', gatewayPaymentId: paymentId ?? null, completedAt: new Date() },
          })
          if (payment.entityType && payment.entityId) {
            await this.fulfillPayment(payment.entityType as EntityType, payment.entityId, payment.id, payment.userId)
            await this.triggerSplit(payment.entityType as EntityType, payment.entityId, payment.id, payment.amountPaise)
          }
        }
      }
    } else if (event === 'PAYMENT_FAILED_WEBHOOK') {
      const orderId = body.data?.order?.order_id
      if (orderId) {
        const payment = await prisma.payment.findFirst({ where: { id: orderId } })
        if (payment) {
          await prisma.payment.update({ where: { id: payment.id }, data: { status: 'FAILED' } })
        }
      }
    } else if (event === 'PAYMENT_LINK_EVENT') {
      const paymentStatus = body.data?.payment?.payment_status
      const linkId = body.data?.link?.link_id as string | undefined
      const paymentId = body.data?.payment?.cf_payment_id?.toString()

      if (paymentStatus === 'SUCCESS' && linkId?.startsWith('enroll_')) {
        // linkId format: enroll_{enrollmentId}_{6-digit-suffix}
        const enrollmentId = linkId.replace('enroll_', '').replace(/_\d+$/, '')
        const enrollment = await prisma.academyEnrollment.update({
          where: { id: enrollmentId },
          data: { feeStatus: 'PAID', feePaidPaise: Math.round((body.data?.payment?.payment_amount ?? 0) * 100) },
          include: { academy: { select: { businessAccountId: true } } },
        }).catch(() => undefined)

        if (enrollment && paymentId) {
          await this.triggerSplit('ACADEMY_FEE', enrollmentId, paymentId, enrollment.feePaidPaise ?? 0).catch(() => undefined)
        }
      }
    } else if (event === 'REFUND_STATUS_WEBHOOK') {
      const refundStatus = body.data?.refund?.refund_status
      const orderId = body.data?.order?.order_id
      if (refundStatus === 'SUCCESS' && orderId) {
        const payment = await prisma.payment.findFirst({ where: { id: orderId } })
        if (payment) {
          await prisma.payment.update({ where: { id: payment.id }, data: { status: 'REFUNDED', refundedAt: new Date() } })
        }
      }
    }

    return { received: true }
  }

  async createPaymentLink(opts: {
    amountPaise: number
    description: string
    customerName: string
    customerPhone: string
    referenceId: string
    studentName?: string
    studentPhone?: string
    parentName?: string | null
    parentPhone?: string | null
  }) {
    const linkId = `${opts.referenceId}_${String(Date.now() % 1000000).padStart(6, '0')}`
    const link = await cashfree.createPaymentLink({
      linkId,
      amountPaise: opts.amountPaise,
      purpose: opts.description,
      customerPhone: opts.customerPhone,
      customerName: opts.customerName,
      notifyUrl: NOTIFY_URL,
    })

    return {
      id: link.link_id,
      url: link.link_url,
      studentName: opts.studentName,
      studentPhone: opts.studentPhone,
      parentName: opts.parentName,
      parentPhone: opts.parentPhone,
      amountPaise: opts.amountPaise,
    }
  }

  async initiateRefund(paymentId: string, userId: string, reason?: string) {
    const payment = await prisma.payment.findUnique({ where: { id: paymentId } })
    if (!payment) throw Errors.notFound('Payment')
    if (payment.userId !== userId) throw Errors.forbidden()
    if (payment.status !== 'COMPLETED') {
      throw new AppError('NOT_REFUNDABLE', 'Payment is not eligible for refund', 400)
    }
    if (!payment.gatewayPaymentId) throw new AppError('NO_PAYMENT_ID', 'Gateway payment ID missing', 400)

    // Initiate Cashfree refund via API
    await cashfree.makeRequest('POST', `/pg/orders/${encodeURIComponent(payment.id)}/refunds`, {
      refund_amount: payment.amountPaise / 100,
      refund_id: `refund_${payment.id}_${Date.now()}`,
      refund_note: reason || 'Customer requested refund',
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
        if (match.status !== 'pending_payment') {
          throw new AppError('INVALID_STATE', 'Match is not awaiting payment', 400)
        }
        return { amountPaise: CONFIRMATION_FEE_PAISE, description: `Match confirmation deposit ${entityId}` }
      }
      case 'SUBSCRIPTION': {
        const sub = await prisma.subscription.findUnique({ where: { id: entityId } })
        if (!sub) throw Errors.notFound('Subscription')
        if (sub.status === 'ACTIVE') throw new AppError('ALREADY_ACTIVE', 'Subscription is already active', 400)
        const planPrices: Record<string, number> = { BASIC: 129900, PRO: 249900, ENTERPRISE: 499900 }
        const amountPaise = planPrices[sub.planTier] ?? 129900
        return { amountPaise, description: `Swing Club subscription — ${sub.planTier}` }
      }
      default:
        throw new AppError('INVALID_ENTITY', 'Unknown entity type', 400)
    }
  }

  private async triggerSplit(entityType: EntityType, entityId: string, cashfreeOrderId: string, totalPaise: number) {
    if (entityType !== 'SLOT_BOOKING' && entityType !== 'ACADEMY_FEE') return
    try {
      const splitSvc = new SplitService()
      await splitSvc.splitPayment({ entityType, entityId, totalPaise, cashfreeOrderId })
    } catch (err) {
      console.error('[Split] payment split failed (non-fatal):', err)
    }
  }

  private async fulfillPayment(entityType: EntityType, entityId: string, paymentId?: string, payingUserId?: string) {
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
      case 'SUBSCRIPTION':
        await prisma.subscription.update({ where: { id: entityId }, data: { status: 'ACTIVE', startedAt: new Date() } })
        break
      case 'MATCHMAKING_MATCH': {
        await prisma.$transaction(async (tx) => {
          const match = await tx.matchmakingMatch.findUnique({ where: { id: entityId } })
          if (!match || match.status === 'confirmed') return

          const [aLobby, bLobby] = await Promise.all([
            tx.matchmakingLobby.findUnique({ where: { id: match.lobbyAId } }),
            tx.matchmakingLobby.findUnique({ where: { id: match.lobbyBId } }),
          ])
          if (!aLobby || !bLobby) throw new AppError('INVALID_MATCH', 'Lobby not found', 400)

          let payerProfileId: string | null = null
          if (payingUserId) {
            const profile = await tx.playerProfile.findUnique({
              where: { userId: payingUserId },
              select: { id: true },
            })
            payerProfileId = profile?.id ?? null
          }

          const isTeamA = payerProfileId != null && aLobby.playerId === payerProfileId
          const isTeamB = payerProfileId != null && bLobby.playerId === payerProfileId

          const updateData: Record<string, any> = {}
          if (isTeamA && !(match as any).teamAPaid) {
            updateData.teamAPaid = true
            updateData.teamAPaymentId = paymentId ?? null
          } else if (isTeamB && !(match as any).teamBPaid) {
            updateData.teamBPaid = true
            updateData.teamBPaymentId = paymentId ?? null
          }

          if (Object.keys(updateData).length === 0) return // duplicate webhook

          const updated = await tx.matchmakingMatch.update({
            where: { id: entityId },
            data: updateData,
          })

          const bothPaid = (updated as any).teamAPaid && (updated as any).teamBPaid

          if (!bothPaid) {
            if (payingUserId) {
              await sendOneSignalPushNotification(
                payingUserId,
                'Payment received — waiting for opponent',
                'Your ₹500 deposit is confirmed. Waiting for the opponent team to pay.',
                { type: 'mm_waiting_opponent', matchId: entityId },
                'PLAYER',
              ).catch(() => undefined)
            }
            const otherLobby = isTeamA ? bLobby : aLobby
            if (otherLobby?.playerId) {
              const otherProfile = await tx.playerProfile.findUnique({
                where: { id: otherLobby.playerId },
                select: { userId: true },
              })
              if (otherProfile?.userId) {
                await sendOneSignalPushNotification(
                  otherProfile.userId,
                  'Opponent paid — your turn!',
                  'The other team has paid ₹500. Pay now to confirm the match.',
                  { type: 'mm_opponent_paid', matchId: entityId, lobbyId: otherLobby.id },
                  'PLAYER',
                ).catch(() => undefined)
              }
            }
            return
          }

          // Both paid — create booking and confirm
          const unit = await tx.arenaUnit.findUnique({ where: { id: match.groundId } })
          if (!unit) throw Errors.notFound('Arena unit')

          const durations: Record<string, number> = { T10: 240, T20: 240, ODI: 480, Test: 480, Custom: 240 }
          const durationMins = durations[match.format as string] ?? 240
          const [sh, sm] = match.slotTime.split(':').map(Number)
          const endMins = sh * 60 + sm + durationMins
          const endTime = `${String(Math.floor(endMins / 60)).padStart(2, '0')}:${String(endMins % 60).padStart(2, '0')}`
          const totalDepositPaise = CONFIRMATION_FEE_PAISE * 2

          const conflict = await tx.slotBooking.findFirst({
            where: {
              unitId: unit.id,
              date: match.date,
              status: { in: ['CONFIRMED', 'CHECKED_IN', 'PENDING_PAYMENT'] },
              startTime: { lt: endTime },
              endTime: { gt: match.slotTime },
            },
            select: { id: true },
          })
          if (conflict) throw new AppError('SLOT_ALREADY_BOOKED', 'Matched slot is no longer available', 409)

          const booking = await tx.slotBooking.create({
            data: {
              arenaId: unit.arenaId,
              unitId: unit.id,
              bookedById: aLobby.playerId,
              date: match.date,
              startTime: match.slotTime,
              endTime,
              durationMins,
              baseAmountPaise: totalDepositPaise,
              totalAmountPaise: totalDepositPaise,
              totalPricePaise: totalDepositPaise,
              advancePaise: totalDepositPaise,
              status: 'CONFIRMED',
              paymentMode: 'ONLINE',
              bookingSource: 'MATCHMAKING',
              notes: `matchmaking:${match.id};teamA:${aLobby.teamId};teamB:${bLobby.teamId}`,
              paidAt: new Date(),
            } as any,
          })

          await tx.matchmakingMatch.update({
            where: { id: entityId },
            data: { status: 'confirmed', teamAConfirmed: true, teamBConfirmed: true, bookingId: booking.id },
          })
          await tx.matchmakingLobby.updateMany({
            where: { id: { in: [match.lobbyAId, match.lobbyBId] } },
            data: { status: 'confirmed' },
          })

          const remainingFeePaise = (match as any).remainingFeePaise ?? 0
          for (const lobby of [aLobby, bLobby]) {
            if (!lobby?.playerId) continue
            const profile = await tx.playerProfile.findUnique({
              where: { id: lobby.playerId },
              select: { userId: true },
            })
            if (!profile?.userId) continue
            await sendOneSignalPushNotification(
              profile.userId,
              'Match confirmed!',
              remainingFeePaise > 0
                ? `Your match is locked. Pay ₹${Math.round(remainingFeePaise / 100)} remaining at the ground.`
                : 'Your match is locked. See you on the field!',
              { type: 'mm_confirmed', matchId: entityId },
              'PLAYER',
            ).catch(() => undefined)
          }
        })
        break
      }
    }
  }
}
