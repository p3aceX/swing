import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { GigService } from './gig.service'

const createGigSchema = z.object({
  title: z.string().min(5),
  description: z.string().min(10),
  sessionType: z.enum(['PACE_NETS','SPIN_NETS','THROWDOWN','POWER_HITTING','FITNESS','FIELDING','MATCH_PRACTICE','VIDEO_REVIEW','CUSTOM']),
  durationMins: z.number().int().min(30),
  pricePerSessionPaise: z.number().int().min(0),
  maxStudents: z.number().int().min(1).default(1),
  targetBattingStyle: z.array(z.string()).optional(),
  targetBowlingStyle: z.array(z.string()).optional(),
  targetAgeMin: z.number().int().optional(),
  targetAgeMax: z.number().int().optional(),
  isOnline: z.boolean().default(false),
  locationName: z.string().optional(),
  latitude: z.number().optional(),
  longitude: z.number().optional(),
  availableDates: z.array(z.string()).optional(),
  tags: z.array(z.string()).optional(),
})

export async function gigRoutes(app: FastifyInstance) {
  const svc = new GigService()
  const auth = { onRequest: [(app as any).authenticate] }

  app.post('/', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = createGigSchema.parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.createListing(user.userId, body) })
  })

  app.get('/', async (request, reply) => {
    const q = request.query as {
      sessionType?: string
      sport?: string
      isOnline?: string
      lat?: string
      lng?: string
      radiusKm?: string
      minPrice?: string
      maxPrice?: string
      page?: string
      limit?: string
    }
    return reply.send({
      success: true,
      data: await svc.listGigs({
        sessionType: q.sessionType,
        sport: q.sport,
        isOnline: q.isOnline !== undefined ? q.isOnline === 'true' : undefined,
        lat: q.lat ? Number(q.lat) : undefined,
        lng: q.lng ? Number(q.lng) : undefined,
        radiusKm: q.radiusKm ? Number(q.radiusKm) : undefined,
        minPrice: q.minPrice ? Number(q.minPrice) : undefined,
        maxPrice: q.maxPrice ? Number(q.maxPrice) : undefined,
        page: Number(q.page) || 1,
        limit: Number(q.limit) || 20,
      }),
    })
  })

  app.get('/my-bookings', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const q = request.query as { asCoach?: string }
    return reply.send({ success: true, data: await svc.getMyGigBookings(user.userId, q.asCoach === 'true') })
  })

  app.get('/:id', async (request, reply) => {
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getGig(id) })
  })

  app.put('/:id', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.updateListing(id, user.userId, request.body) })
  })

  app.post('/:id/book', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = z.object({ scheduledAt: z.string(), notes: z.string().optional() }).parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.bookGig(user.userId, id, body) })
  })

  app.post('/bookings/:id/cancel', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.cancelGigBooking(id, user.userId) })
  })

  app.post('/bookings/:id/complete', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.completeGigBooking(id, user.userId) })
  })
}
