import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { PaymentService } from './payment.service'

export async function paymentRoutes(app: FastifyInstance) {
  const svc = new PaymentService()
  const auth = { onRequest: [(app as any).authenticate] }

  app.post('/orders', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = z.object({
      entityType: z.enum(['SLOT_BOOKING', 'GIG_BOOKING', 'ACADEMY_FEE', 'STORE_ORDER']),
      entityId: z.string(),
    }).parse(request.body)
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
