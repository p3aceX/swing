import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { OneOnOneService } from './one-on-one.service'

export async function oneOnOneRoutes(app: FastifyInstance) {
  const svc = new OneOnOneService()
  const auth = { onRequest: [(app as any).authenticate] }

  // GET /1on1/my-profile — coach's own 1-on-1 profile
  app.get('/my-profile', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.getMyProfile(user.userId) })
  })

  // PUT /1on1/my-profile — set up or update 1-on-1 profile
  app.put('/my-profile', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = z.object({
      isEnabled: z.boolean(),
      expertiseTags: z.array(z.string()).optional(),
      bio: z.string().optional(),
      pricePerSession: z.object({
        mins60: z.number().optional(),
        mins90: z.number().optional(),
        mins120: z.number().optional(),
      }).optional(),
      locationTypes: z.array(z.string()).optional(),
      maxPerWeek: z.number().optional(),
    }).parse(request.body)
    return reply.send({ success: true, data: await svc.setupProfile(user.userId, body) })
  })

  // PUT /1on1/my-slots — set availability slots
  app.put('/my-slots', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = z.object({
      slots: z.array(z.object({
        dayOfWeek: z.number().min(0).max(6),
        startTime: z.string(),
        endTime: z.string(),
      })),
    }).parse(request.body)
    return reply.send({ success: true, data: await svc.setSlots(user.userId, body.slots) })
  })

  // GET /1on1/bookings — list coach bookings
  app.get('/bookings', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const q = request.query as { status?: string }
    return reply.send({ success: true, data: await svc.listCoachBookings(user.userId, q.status) })
  })

  // POST /1on1/bookings/:id/accept
  app.post('/bookings/:id/accept', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.respondToBooking(user.userId, id, true) })
  })

  // POST /1on1/bookings/:id/reject
  app.post('/bookings/:id/reject', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = z.object({ reason: z.string().optional() }).parse(request.body)
    return reply.send({ success: true, data: await svc.respondToBooking(user.userId, id, false, body.reason) })
  })

  // POST /1on1/bookings/:id/complete
  app.post('/bookings/:id/complete', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = z.object({ coachNote: z.string().optional() }).parse(request.body)
    return reply.send({ success: true, data: await svc.completeBooking(user.userId, id, body.coachNote) })
  })

  // GET /1on1/earnings — coach earnings summary
  app.get('/earnings', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.getCoachOneOnOneEarnings(user.userId) })
  })

  // GET /1on1/coach/:coachId — public coach profile (for players to discover)
  app.get('/coach/:coachId', async (request, reply) => {
    const { coachId } = request.params as { coachId: string }
    return reply.send({ success: true, data: await svc.getPublicCoachProfile(coachId) })
  })

  // POST /1on1/request — player requests a 1-on-1 booking
  app.post('/request', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = z.object({
      coachId: z.string(),
      sessionDate: z.string(),
      startTime: z.string(),
      durationMins: z.number().refine((n) => [60, 90, 120].includes(n), 'Must be 60, 90, or 120'),
      locationType: z.enum(['COACH_GROUND', 'STUDENT_GROUND', 'ONLINE']),
      locationDetails: z.string().optional(),
      studentNote: z.string().optional(),
      academyId: z.string().optional(),
    }).parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.requestBooking(user.userId, body) })
  })
}
