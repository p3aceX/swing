import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { ChatService } from './chat.service'

export async function chatRoutes(app: FastifyInstance) {
  const svc = new ChatService()
  const auth = { onRequest: [(app as any).authenticate] }

  app.get('/conversations', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const query = z.object({
      page: z.coerce.number().int().min(1).optional(),
      limit: z.coerce.number().int().min(1).max(50).optional(),
    }).parse(request.query)

    return reply.send({
      success: true,
      data: await svc.listConversations(
        user.userId,
        query.page ?? 1,
        query.limit ?? 20,
      ),
    })
  })

  app.post('/direct/:playerId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { playerId } = request.params as { playerId: string }
    return reply.code(201).send({
      success: true,
      data: await svc.getOrCreateDirectConversation(user.userId, playerId),
    })
  })

  app.get('/conversations/:conversationId/messages', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { conversationId } = request.params as { conversationId: string }
    const query = z.object({
      page: z.coerce.number().int().min(1).optional(),
      limit: z.coerce.number().int().min(1).max(100).optional(),
    }).parse(request.query)

    return reply.send({
      success: true,
      data: await svc.listMessages(
        user.userId,
        conversationId,
        query.page ?? 1,
        query.limit ?? 30,
      ),
    })
  })

  app.post('/conversations/:conversationId/messages', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { conversationId } = request.params as { conversationId: string }
    const body = z.object({
      body: z.string().min(1).max(4000),
    }).parse(request.body)

    return reply.code(201).send({
      success: true,
      data: await svc.sendMessage(user.userId, conversationId, body.body),
    })
  })

  app.post('/conversations/:conversationId/read', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { conversationId } = request.params as { conversationId: string }
    return reply.send({
      success: true,
      data: await svc.markConversationRead(user.userId, conversationId),
    })
  })

  // ── Team chat ───────────────────────────────────────────────────────────────

  // Get or create team chat (auto-populates all team members)
  app.post('/team/:teamId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { teamId } = request.params as { teamId: string }
    return reply.code(201).send({
      success: true,
      data: await svc.getOrCreateTeamChat(user.userId, teamId),
    })
  })

  // Leave a team chat
  app.delete('/team/:teamId/leave', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { teamId } = request.params as { teamId: string }
    return reply.send({
      success: true,
      data: await svc.leaveTeamChat(user.userId, teamId),
    })
  })
}
