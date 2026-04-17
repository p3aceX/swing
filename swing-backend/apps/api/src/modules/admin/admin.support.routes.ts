import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { AdminService } from './admin.service'

export async function adminSupportRoutes(app: FastifyInstance) {
  const svc = new AdminService()
  const auth = { onRequest: [(app as any).authenticate] }

  app.get('/support', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const q = z.object({
      status: z.string().optional(),
      priority: z.string().optional(),
      category: z.string().optional(),
      page: z.coerce.number().int().min(1).optional(),
      limit: z.coerce.number().int().min(1).max(100).optional(),
    }).parse(request.query)

    return reply.send({
      success: true,
      data: await svc.listSupportTickets(user.userId, {
        status: q.status,
        priority: q.priority,
        category: q.category,
        page: q.page || 1,
        limit: q.limit || 50,
      }),
    })
  })

  app.get('/support/:id', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getSupportTicket(user.userId, id) })
  })

  app.post('/support/:id/message', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = z.object({ message: z.string().min(1) }).parse(request.body)
    return reply.send({ success: true, data: await svc.addSupportMessage(user.userId, id, body.message) })
  })

  app.post('/support/:id/assign', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = z.object({ agentId: z.string().min(1) }).parse(request.body)
    return reply.send({ success: true, data: await svc.assignSupportTicket(user.userId, id, body.agentId) })
  })

  app.post('/support/:id/resolve', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = z.object({ resolution: z.string().min(1) }).parse(request.body)
    return reply.send({ success: true, data: await svc.resolveSupportTicket(user.userId, id, body.resolution) })
  })

  app.post('/support/:id/close', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.closeSupportTicket(user.userId, id) })
  })
}
