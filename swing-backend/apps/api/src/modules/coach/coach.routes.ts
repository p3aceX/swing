import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { CoachService } from './coach.service'
import { DevelopmentService } from '../development/development.service'

export async function coachRoutes(app: FastifyInstance) {
  const svc = new CoachService()
  const developmentSvc = new DevelopmentService()
  const auth = { onRequest: [(app as any).authenticate] }

  app.get('/profile', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.getOrCreateProfile(user.userId) })
  })

  app.put('/profile', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.updateProfile(user.userId, request.body) })
  })

  app.get('/:id', async (request, reply) => {
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getPublicProfile(id) })
  })

  app.get('/students', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.getStudents(user.userId) })
  })

  app.post('/sessions', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = z.object({
      // Accept both enum and name/id from session type configs
      sessionType: z.enum(['PACE_NETS','SPIN_NETS','THROWDOWN','POWER_HITTING','FITNESS','FIELDING','MATCH_PRACTICE','VIDEO_REVIEW','CUSTOM']).optional(),
      sessionTypeId: z.string().optional(),
      sessionTypeName: z.string().optional(),
      scheduledAt: z.string(),
      durationMins: z.number().optional(),
      durationMinutes: z.number().optional(),
      academyId: z.string().optional(),
      batchId: z.string().optional(),
      locationName: z.string().optional(),
      latitude: z.number().optional(),
      longitude: z.number().optional(),
      notes: z.string().optional(),
      drillPlanId: z.string().optional(),
    }).parse(request.body)
    return reply.code(201).send({
      success: true,
      data: await developmentSvc.createSession(user.userId, {
        sessionTypeId: body.sessionTypeId,
        sessionTypeName: body.sessionTypeName ?? body.sessionType,
        scheduledAt: body.scheduledAt,
        durationMinutes: body.durationMinutes ?? body.durationMins,
        academyId: body.academyId,
        batchId: body.batchId,
        locationName: body.locationName,
        notes: body.notes,
      }),
    })
  })

  app.get('/sessions', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const q = request.query as { page?: string; limit?: string }
    return reply.send({ success: true, data: await svc.getSessions(user.userId, Number(q.page) || 1, Number(q.limit) || 20) })
  })

  app.post('/sessions/:id/cancel', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = z.object({
      reason: z.string().min(1).default('Cancelled by coach'),
    }).parse(request.body)
    return reply.send({ success: true, data: await svc.cancelSession(user.userId, id, body.reason) })
  })

  app.get('/batches', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.getCoachBatches(user.userId) })
  })

  app.get('/schedules', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.getSchedules(user.userId) })
  })

  app.post('/schedules', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = z.object({
      sessionType: z.enum(['PACE_NETS','SPIN_NETS','THROWDOWN','POWER_HITTING','FITNESS','FIELDING','MATCH_PRACTICE','VIDEO_REVIEW','CUSTOM']),
      daysOfWeek: z.array(z.number().min(0).max(6)).min(1),
      startTime: z.string().regex(/^\d{2}:\d{2}$/),
      durationMins: z.number().default(90),
      academyId: z.string().optional(),
      batchId: z.string().optional(),
    }).parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.createSchedule(user.userId, body) })
  })

  app.patch('/schedules/:id', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.updateSchedule(user.userId, id, request.body) })
  })

  app.post('/schedules/:id/generate', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = z.object({ weeksAhead: z.number().min(1).max(8).default(2) }).default({}).parse(request.body)
    return reply.send({ success: true, data: await svc.generateFromSchedule(user.userId, id, body.weeksAhead) })
  })

  app.post('/sessions/:id/generate-qr', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.generateQr(id, user.userId) })
  })

  app.post('/sessions/:id/close-qr', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.closeQr(id, user.userId) })
  })

  app.post('/sessions/:id/attendance', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = z.object({ playerProfileId: z.string(), status: z.enum(['PRESENT','LATE','ABSENT','EXCUSED','WALK_IN','EARLY_EXIT']), notes: z.string().optional() }).parse(request.body)
    return reply.send({ success: true, data: await svc.overrideAttendance(id, user.userId, body.playerProfileId, body.status, body.notes) })
  })

  app.post('/drills', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = z.object({
      name: z.string().min(2),
      description: z.string().optional(),
      roleTags: z.array(z.enum(['BATSMAN','BOWLER','ALL_ROUNDER','FIELDER','WICKET_KEEPER'])).min(1),
      category: z.enum(['TECHNIQUE','FITNESS','MENTAL','MATCH_SIMULATION']).optional(),
      targetUnit: z.enum(['BALLS','OVERS','MINUTES','REPS','SESSIONS']).optional(),
      skillArea: z.string().optional(),
      videoUrl: z.string().url().optional(),
      isActive: z.boolean().optional(),
    }).parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.createDrill(user.userId, body) })
  })

  app.post('/drill-plans', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.code(201).send({ success: true, data: await svc.createDrillPlan(user.userId, request.body) })
  })

  app.post('/feedback', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.code(201).send({ success: true, data: await svc.submitFeedback(user.userId, request.body) })
  })

  app.post('/report-cards', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.code(201).send({ success: true, data: await svc.createReportCard(user.userId, request.body) })
  })

  app.post('/report-cards/:id/publish', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.publishReportCard(id, user.userId) })
  })

  app.get('/earnings', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.getEarnings(user.userId) })
  })

  app.get('/drills', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.listDrills(user.userId) })
  })

  app.get('/drills/:id', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getDrillById(id, user.userId) })
  })

  app.get('/drill-plans', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.getDrillPlans(user.userId) })
  })

  app.get('/gig-bookings', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const q = request.query as { page?: string; limit?: string }
    return reply.send({ success: true, data: await svc.listGigBookings(user.userId, Number(q.page) || 1, Number(q.limit) || 20) })
  })

  app.get('/report-cards', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.listReportCards(user.userId) })
  })
}
