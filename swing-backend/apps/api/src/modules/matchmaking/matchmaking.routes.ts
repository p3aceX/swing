import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { MatchmakingService, MatchmakingFormat } from './matchmaking.service'

export async function matchmakingRoutes(app: FastifyInstance) {
  const svc = new MatchmakingService()
  const auth = { onRequest: [(app as any).authenticate] }

  const formatSchema = z.enum(['T10', 'T20', 'ODI', 'Test', 'Custom'])

  app.get('/grounds', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const q = z.object({
      q: z.string().optional(),
      date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
      format: formatSchema,
      teamId: z.string().optional(),
      overs: z.coerce.number().int().min(1).max(100).optional(),
    }).parse(request.query)
    const data = await svc.searchGrounds(user.userId, {
      q: q.q,
      date: q.date,
      format: q.format as MatchmakingFormat,
      teamId: q.teamId,
      overs: q.overs,
    })
    return reply.send({ success: true, data })
  })

  app.post('/lobbies', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const ballTypeSchema = z.enum(['LEATHER', 'TENNIS', 'TAPE', 'RUBBER']).optional()
    const body = z.object({
      teamId: z.string(),
      format: formatSchema,
      ballType: ballTypeSchema,
      date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
      picks: z.array(z.object({
        groundId: z.string(),
        slotTime: z.string().regex(/^\d{2}:\d{2}$/),
      })).min(1).max(3),
    }).parse(request.body)
    const data = await svc.createLobby(user.userId, {
      teamId: body.teamId,
      format: body.format as MatchmakingFormat,
      ballType: body.ballType ?? null,
      date: body.date,
      picks: body.picks,
    })
    return reply.code(201).send({ success: true, data })
  })

  app.get('/lobbies/active', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const data = await svc.getMyActiveLobby(user.userId)
    return reply.send({ success: true, data })
  })

  app.get('/lobbies/:lobbyId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { lobbyId } = request.params as { lobbyId: string }
    const data = await svc.getLobbyStatus(user.userId, lobbyId)
    return reply.send({ success: true, data })
  })

  app.get('/lobbies/:lobbyId/stream', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { lobbyId } = request.params as { lobbyId: string }
    await svc.assertLobbyOwnership(user.userId, lobbyId)

    reply.raw.setHeader('Content-Type', 'text/event-stream')
    reply.raw.setHeader('Cache-Control', 'no-cache')
    reply.raw.setHeader('Connection', 'keep-alive')
    reply.raw.flushHeaders?.()

    const write = async () => {
      const payload = await svc.getLobbyStatus(user.userId, lobbyId)
      reply.raw.write(`data: ${JSON.stringify(payload)}\n\n`)
    }

    await write()
    const timer = setInterval(() => void write(), 5000)
    request.raw.on('close', () => {
      clearInterval(timer)
      reply.raw.end()
    })
  })

  app.get('/lobbies', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const q = z.object({
      date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
      format: formatSchema.optional(),
      ageGroup: z.string().optional(),
      arenaId: z.string().optional(),
    }).parse(request.query)
    const data = await svc.listOpenLobbies(user.userId, {
      date: q.date,
      format: q.format as MatchmakingFormat | undefined,
      ageGroup: q.ageGroup,
      arenaId: q.arenaId,
    })
    return reply.send({ success: true, data })
  })

  app.post('/lobbies/:lobbyId/accept', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { lobbyId } = request.params as { lobbyId: string }
    const body = z.object({ arenaId: z.string() }).parse(request.body)
    const data = await svc.acceptLobbyAsOwner(user.userId, lobbyId, body.arenaId)
    return reply.send({ success: true, data })
  })

  app.post('/matches/:matchId/confirm', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { matchId } = request.params as { matchId: string }
    const body = z.object({ lobbyId: z.string() }).parse(request.body)
    const data = await svc.confirmMatchLobby(user.userId, matchId, body.lobbyId)
    return reply.send({ success: true, data })
  })

  app.post('/matches/:matchId/decline', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { matchId } = request.params as { matchId: string }
    const body = z.object({ lobbyId: z.string() }).parse(request.body)
    const data = await svc.declineMatchLobby(user.userId, matchId, body.lobbyId)
    return reply.send({ success: true, data })
  })

  app.delete('/lobbies/:lobbyId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { lobbyId } = request.params as { lobbyId: string }
    await svc.leaveLobby(user.userId, lobbyId)
    return reply.code(204).send()
  })
}
