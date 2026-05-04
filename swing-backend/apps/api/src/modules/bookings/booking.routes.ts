import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { BookingService } from './booking.service'

const svc = new BookingService()

const PAYMENT_MODES = ['CASH', 'UPI', 'CARD', 'BANK_TRANSFER', 'ONLINE'] as const

export async function bookingRoutes(app: FastifyInstance) {
  const auth = { onRequest: [(app as any).authenticate] }

  // ─── Player: hold a slot ────────────────────────────────────────────────
  app.post('/hold', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = z.object({
      arenaUnitId: z.string(),
      bookingDate: z.string(),
      startTime: z.string().regex(/^\d{2}:\d{2}$/),
      endTime: z.string().regex(/^\d{2}:\d{2}$/),
    }).parse(request.body)
    return reply.send({ success: true, data: await svc.holdSlot(user.userId, body) })
  })

  // ─── Player: create booking (after hold + payment) ──────────────────────
  app.post('/', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = z.object({
      // Unit ID — accept both field names the client may send
      arenaUnitId: z.string().optional(),
      unitId: z.string().optional(),
      // Date — accept both field names
      bookingDate: z.string().optional(),
      date: z.string().optional(),
      startTime: z.string().regex(/^\d{2}:\d{2}$/),
      endTime: z.string().regex(/^\d{2}:\d{2}$/),
      totalPricePaise: z.number().int().min(0).optional(),
      totalAmountPaise: z.number().int().min(0).optional(),
      advancePaise: z.number().int().min(0).optional(),
      notes: z.string().optional(),
      // PhonePe payment fields
      holdId: z.string().optional(),
      phonePeOrderId: z.string().optional(),
      merchantOrderId: z.string().optional(),
      paymentGateway: z.string().optional(),
    }).parse(request.body)

    const resolved = {
      arenaUnitId: (body.arenaUnitId ?? body.unitId ?? '') as string,
      bookingDate: (body.bookingDate ?? body.date ?? '') as string,
      startTime: body.startTime,
      endTime: body.endTime,
      totalPricePaise: body.totalPricePaise ?? body.totalAmountPaise ?? 0,
      advancePaise: body.advancePaise,
      notes: body.notes,
      holdId: body.holdId,
      phonePeOrderId: body.phonePeOrderId ?? body.merchantOrderId,
      paymentGateway: body.paymentGateway,
    }

    if (!resolved.arenaUnitId) {
      return reply.code(400).send({ success: false, error: { code: 'MISSING_UNIT', message: 'arenaUnitId is required' } })
    }
    if (!resolved.bookingDate) {
      return reply.code(400).send({ success: false, error: { code: 'MISSING_DATE', message: 'bookingDate is required' } })
    }

    return reply.code(201).send({ success: true, data: await svc.createBooking(user.userId, resolved) })
  })

  // ─── Player: create Razorpay order for a booking ────────────────────────
  app.post('/:id/payment-order', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.code(201).send({ success: true, data: await svc.createPaymentOrder(user.userId, id) })
  })

  // ─── Player: verify Razorpay payment ────────────────────────────────────
  app.post('/verify-payment', auth, async (request, reply) => {
    const body = z.object({
      razorpayOrderId: z.string(),
      razorpayPaymentId: z.string(),
      razorpaySignature: z.string(),
    }).parse(request.body)
    return reply.send({ success: true, data: await svc.verifyPayment(body) })
  })

  // ─── Razorpay webhook (no auth — Razorpay signs it) ─────────────────────
  app.post('/webhook/razorpay', async (request, reply) => {
    const signature = request.headers['x-razorpay-signature'] as string
    if (!signature) {
      return reply.code(400).send({ success: false, error: { code: 'MISSING_SIGNATURE', message: 'Webhook signature missing' } })
    }
    return reply.send(await svc.handleWebhook(request.body, signature))
  })

  // ─── Player: list own bookings ───────────────────────────────────────────
  app.get('/', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const q = request.query as { page?: string; limit?: string }
    return reply.send({ success: true, data: await svc.listUserBookings(user.userId, Number(q.page) || 1, Number(q.limit) || 20) })
  })

  // ─── Player: get single booking ──────────────────────────────────────────
  app.get('/:id', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getBooking(id, user.userId) })
  })

  // ─── Player: cancel own booking ──────────────────────────────────────────
  app.post('/:id/cancel', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.cancelBooking(id, user.userId) })
  })

  // ─── Player: self check-in ───────────────────────────────────────────────
  app.post('/:id/checkin', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.checkin(id, user.userId) })
  })

  // ─── Player: busy slots for an arena — no owner check, no sensitive data ─
  app.get('/arena/:arenaId/busy', auth, async (request, reply) => {
    const { arenaId } = request.params as { arenaId: string }
    const q = request.query as { date?: string }
    return reply.send({ success: true, data: await svc.listArenaBusySlots(arenaId, q.date) })
  })

  // ─── Owner: list arena bookings (optionally filtered by date) ────────────
  app.get('/arena/:arenaId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { arenaId } = request.params as { arenaId: string }
    const q = request.query as { date?: string }
    return reply.send({ success: true, data: await svc.listArenaBookings(arenaId, user.userId, q.date) })
  })

  // ─── Owner: payments list + pending balance ─────────────────────────────
  app.get('/arena/:arenaId/payments', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { arenaId } = request.params as { arenaId: string }
    const q = request.query as { month?: string; mode?: string }
    return reply.send({ success: true, data: await svc.listArenaPayments(user.userId, arenaId, q) })
  })

  // ─── Owner: CRM — list guests with booking stats ────────────────────────
  app.get('/arena/:arenaId/guests', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { arenaId } = request.params as { arenaId: string }
    const q = request.query as { search?: string }
    return reply.send({ success: true, data: await svc.listArenaGuests(user.userId, arenaId, q.search) })
  })

  app.get('/arena/:arenaId/customers/lookup', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { arenaId } = request.params as { arenaId: string }
    const q = z.object({ phone: z.string().min(1) }).parse(request.query)
    return reply.send({ success: true, data: await svc.lookupArenaCustomer(user.userId, arenaId, q.phone) })
  })

  // ─── Owner: monthly summary for calendar badges ──────────────────────────
  // GET /bookings/arena/:arenaId/summary?month=2026-04
  app.get('/arena/:arenaId/summary', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { arenaId } = request.params as { arenaId: string }
    const q = request.query as { month?: string }
    if (!q.month || !/^\d{4}-\d{2}$/.test(q.month)) {
      return reply.code(400).send({ success: false, error: { code: 'INVALID_MONTH', message: 'month must be YYYY-MM' } })
    }
    return reply.send({ success: true, data: await svc.getMonthlySummary(user.userId, arenaId, q.month) })
  })

  // ─── Owner: create manual / offline booking ──────────────────────────────
  app.post('/arena/:arenaId/manual', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { arenaId } = request.params as { arenaId: string }
    const body = z.object({
      unitId: z.string(),
      date: z.string(),
      startTime: z.string().regex(/^\d{2}:\d{2}$/),
      endTime: z.string().regex(/^\d{2}:\d{2}$/),
      guestName: z.string().min(1),
      guestPhone: z.string().min(1),
      paymentMode: z.enum(PAYMENT_MODES).default('CASH'),
      amountPaise: z.number().int().min(0),
      advancePaise: z.number().int().min(0).optional(),
      notes: z.string().optional(),
      netVariantType: z.string().optional(),
      guestUserId: z.string().optional(),
      guestPlayerProfileId: z.string().optional(),
      createGuestUser: z.boolean().optional(),
    }).parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.createManualBooking(user.userId, arenaId, body) })
  })

  // ─── Owner: create split booking (soft-block slot + create lobby) ─────────
  app.post('/arena/:arenaId/split', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { arenaId } = request.params as { arenaId: string }
    const body = z.object({
      unitId: z.string(),
      date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
      slotTime: z.string().regex(/^\d{2}:\d{2}$/),
      format: z.enum(['T10', 'T20', 'ODI', 'Test', 'Custom']),
      ballType: z.enum(['LEATHER', 'TENNIS', 'TAPE', 'RUBBER']).optional(),
      teamId: z.string().optional(),
      teamName: z.string().optional(),
    }).parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.createSplitBooking(user.userId, arenaId, body) })
  })

  // ─── Owner: mark booking as paid ────────────────────────────────────────
  app.post('/:id/mark-paid', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = z.object({
      paymentMode: z.enum(['CASH', 'UPI', 'CARD', 'BANK_TRANSFER']),
      amountPaise: z.number().int().min(0).optional(),
      reference: z.string().optional(),
    }).parse(request.body)
    return reply.send({ success: true, data: await svc.markPaid(user.userId, id, body) })
  })

  // ─── Owner: cancel any booking ──────────────────────────────────────────
  app.post('/:id/cancel-by-owner', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = z.object({ reason: z.string().optional() }).parse(request.body ?? {})
    return reply.send({ success: true, data: await svc.cancelByOwner(user.userId, id, body.reason) })
  })

  // ─── Owner: check-in any booking ────────────────────────────────────────
  app.post('/:id/checkin-by-owner', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.checkinByOwner(user.userId, id) })
  })
}
