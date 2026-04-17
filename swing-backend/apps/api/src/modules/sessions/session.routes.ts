import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { SessionService } from './session.service'
import { DevelopmentService } from '../development/development.service'

export async function sessionRoutes(app: FastifyInstance) {
  const svc = new SessionService()
  const developmentSvc = new DevelopmentService()
  const auth = { onRequest: [(app as any).authenticate] }

  app.post('/', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = z.object({
      academyId: z.string().optional(),
      batchId: z.string().optional(),
      sessionTypeId: z.string().optional(),
      sessionTypeName: z.string().optional(),
      scheduledAt: z.string().optional(),
      durationMinutes: z.number().int().positive().optional(),
      locationName: z.string().optional(),
      notes: z.string().optional(),
    }).parse(request.body)
    return reply.code(201).send({ success: true, data: await developmentSvc.createSession(user.userId, body) })
  })

  app.get('/:id', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await developmentSvc.getSessionDetail(id, user.userId) })
  })

  app.patch('/:id/close', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await developmentSvc.closeSession(id, user.userId) })
  })

  app.post('/:id/join-qr', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await developmentSvc.joinSessionViaQr(id, user.userId) })
  })

  app.post('/:id/join-app', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await developmentSvc.joinSessionViaApp(id, user.userId) })
  })

  app.post('/:id/checkin-coach', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = z.object({ latitude: z.number(), longitude: z.number() }).parse(request.body)
    return reply.send({ success: true, data: await svc.coachCheckin(id, user.userId, body.latitude, body.longitude) })
  })

  app.post('/scan', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = z.object({ qrToken: z.string(), latitude: z.number().optional(), longitude: z.number().optional() }).parse(request.body)
    return reply.send({ success: true, data: await svc.playerScanSession(body.qrToken, user.userId, body.latitude, body.longitude) })
  })

  app.get('/:id/attendance', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await developmentSvc.getAttendance(id, user.userId) })
  })

  app.patch('/:id/attendance/:playerId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id, playerId } = request.params as { id: string; playerId: string }
    const body = z.object({
      status: z.enum(['PRESENT', 'ABSENT', 'UNSET']),
    }).parse(request.body)
    return reply.send({ success: true, data: await developmentSvc.updateAttendance(id, playerId, user.userId, body.status) })
  })
}
