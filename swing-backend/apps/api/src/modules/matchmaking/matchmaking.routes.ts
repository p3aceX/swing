import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { MatchmakingService } from './matchmaking.service'

const createRequestSchema = z.object({
  format: z.enum(['T10', 'T20', 'ONE_DAY', 'TWO_INNINGS', 'BOX_CRICKET', 'CUSTOM']),
  matchType: z.enum(['RANKED', 'FRIENDLY']),
  preferredDate: z.string().optional(),
  preferredVenueName: z.string().optional(),
  latitude: z.number().optional(),
  longitude: z.number().optional(),
  radiusKm: z.number().default(25),
  notes: z.string().optional(),
})

export async function matchmakingRoutes(app: FastifyInstance) {
  const svc = new MatchmakingService()
  const auth = { onRequest: [(app as any).authenticate] }

  app.post('/requests', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = createRequestSchema.parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.createRequest(user.userId, body) })
  })

  app.get('/requests', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const q = request.query as { format?: string; status?: string; page?: string; limit?: string }
    return reply.send({
      success: true,
      data: await svc.listRequests(user.userId, {
        format: q.format,
        status: q.status,
        page: Number(q.page) || 1,
        limit: Number(q.limit) || 20,
      }),
    })
  })

  app.get('/requests/mine', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.getMyRequests(user.userId) })
  })

  app.post('/requests/:id/respond', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = z.object({ accept: z.boolean() }).parse(request.body)
    return reply.send({ success: true, data: await svc.respondToRequest(id, user.userId, body.accept) })
  })

  app.post('/requests/:id/cancel', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.cancelRequest(id, user.userId) })
  })
}
