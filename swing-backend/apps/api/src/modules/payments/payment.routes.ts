import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { PaymentService } from './payment.service'
import { PhonePeService } from './phonepe.service'

export async function paymentRoutes(app: FastifyInstance) {
  const svc = new PaymentService()
  const phonepe = new PhonePeService()
  const auth = { onRequest: [(app as any).authenticate] }

  // PhonePe pre-booking order — called before the booking record exists.
  // Body: { amountPaise, currency?, entityType: 'ARENA_BOOKING' }
  // Legacy Razorpay path: { entityType: (SLOT_BOOKING|...), entityId }
  app.post('/orders', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const raw = request.body as Record<string, unknown>

    // PhonePe arena-booking path
    if (raw.entityType === 'ARENA_BOOKING' || (raw.amountPaise && !raw.entityId)) {
      const body = z.object({
        amountPaise: z.number().int().positive(),
        currency: z.string().optional(),
      }).parse(raw)
      const order = await phonepe.createOrder(body.amountPaise)
      return reply.code(201).send({
        success: true,
        data: {
          orderId: order.orderId,
          token: order.token,
          redirectUrl: order.redirectUrl,
          amountPaise: body.amountPaise,
        },
      })
    }

    // Legacy Razorpay path
    const body = z.object({
      entityType: z.enum(['SLOT_BOOKING', 'GIG_BOOKING', 'ACADEMY_FEE', 'STORE_ORDER', 'MATCHMAKING_MATCH']),
      entityId: z.string(),
    }).parse(raw)
    return reply.code(201).send({ success: true, data: await svc.createOrder(user.userId, body) })
  })

  app.post('/verify', auth, async (request, reply) => {
    const body = z.object({
      razorpayOrderId: z.string(),
      razorpayPaymentId: z.string(),
      razorpaySignature: z.string(),
    }).parse(request.body)
    return reply.send({ success: true, data: await svc.verifyPayment(body) })
  })

  app.post('/webhook', async (request, reply) => {
    const signature = request.headers['x-razorpay-signature'] as string
    if (!signature) return reply.code(400).send({ success: false, error: { code: 'MISSING_SIGNATURE', message: 'Webhook signature missing' } })
    return reply.send(await svc.handleWebhook(request.body, signature))
  })

  app.get('/', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const q = request.query as { page?: string; limit?: string }
    return reply.send({ success: true, data: await svc.getUserPayments(user.userId, Number(q.page) || 1, Number(q.limit) || 20) })
  })

  app.get('/:id', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getPayment(id, user.userId) })
  })

  app.post('/:id/refund', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = z.object({ reason: z.string().optional() }).parse(request.body)
    return reply.send({ success: true, data: await svc.initiateRefund(id, user.userId, body.reason) })
  })
}
