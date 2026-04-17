import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { MatchmakingService } from './matchmaking.service'

export async function matchmakingQueueRoutes(app: FastifyInstance) {
  const svc = new MatchmakingService()
  const auth = { onRequest: [(app as any).authenticate] }

  app.post('/queue', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = z.object({
      sport: z.enum(['CRICKET', 'FUTSAL', 'PICKLEBALL', 'BADMINTON', 'FOOTBALL', 'BASKETBALL', 'TENNIS', 'OTHER']),
      format: z.enum(['T10', 'T20', 'ONE_DAY', 'TWO_INNINGS', 'BOX_CRICKET', 'CUSTOM']),
      teamSize: z.number().int().min(2).max(11),
      preferredFrom: z.string().datetime().optional(),
      preferredTo: z.string().datetime().optional(),
      radiusKm: z.number().int().min(1).max(100).optional(),
      latitude: z.number().optional(),
      longitude: z.number().optional(),
    }).parse(request.body)

    const data = await svc.joinQueue(user.userId, body)
    return reply.code(201).send({ success: true, data })
  })

  app.get('/queue/:id', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getQueueStatus(id, user.userId) })
  })

  app.delete('/queue/:id', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    await svc.leaveQueue(id, user.userId)
    return reply.send({ success: true })
  })

  app.post('/confirm/:requestId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { requestId } = request.params as { requestId: string }
    return reply.code(201).send({ success: true, data: await svc.confirmMatch(requestId, user.userId) })
  })
}
