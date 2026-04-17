import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { BookingService } from './booking.service'

const holdSchema = z.object({
  arenaUnitId: z.string(),
  bookingDate: z.string(),
  startTime: z.string().regex(/^\d{2}:\d{2}$/),
  endTime: z.string().regex(/^\d{2}:\d{2}$/),
})

const createBookingSchema = holdSchema.extend({
  totalPricePaise: z.number().int().min(0),
  notes: z.string().optional(),
})

export async function bookingRoutes(app: FastifyInstance) {
  const svc = new BookingService()
  const auth = { onRequest: [(app as any).authenticate] }

  app.post('/hold', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = holdSchema.parse(request.body)
    return reply.send({ success: true, data: await svc.holdSlot(user.userId, body) })
  })

  app.post('/', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = createBookingSchema.parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.createBooking(user.userId, body) })
  })

  app.get('/', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const q = request.query as { page?: string; limit?: string }
    return reply.send({ success: true, data: await svc.listUserBookings(user.userId, Number(q.page) || 1, Number(q.limit) || 20) })
  })

  app.get('/:id', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getBooking(id, user.userId) })
  })

  app.post('/:id/cancel', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.cancelBooking(id, user.userId) })
  })

  app.post('/:id/checkin', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.checkin(id, user.userId) })
  })

  app.get('/arena/:arenaId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { arenaId } = request.params as { arenaId: string }
    const q = request.query as { date?: string }
    return reply.send({ success: true, data: await svc.listArenaBookings(arenaId, user.userId, q.date) })
  })
}
