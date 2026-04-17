import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { NotificationService } from './notification.service'

export async function notificationRoutes(app: FastifyInstance) {
  const svc = new NotificationService()
  const auth = { onRequest: [(app as any).authenticate] }

  app.post('/fcm-token', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = z.object({ token: z.string().min(10) }).parse(request.body)
    return reply.send({ success: true, data: await svc.registerFcmToken(user.userId, body.token) })
  })

  app.delete('/fcm-token', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = z.object({ token: z.string() }).parse(request.body)
    return reply.send({ success: true, data: await svc.removeFcmToken(user.userId, body.token) })
  })

  app.get('/', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const q = request.query as { page?: string; limit?: string }
    return reply.send({ success: true, data: await svc.getNotifications(user.userId, Number(q.page) || 1, Number(q.limit) || 20) })
  })

  app.get('/summary', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.getSummary(user.userId) })
  })

  app.get('/preferences', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.getPreferences(user.userId) })
  })

  app.put('/preferences', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = z.object({
      pushEnabled: z.boolean().optional(),
      chatMessages: z.boolean().optional(),
      newFollowers: z.boolean().optional(),
      rankUpdates: z.boolean().optional(),
      matchResults: z.boolean().optional(),
      productAnnouncements: z.boolean().optional(),
    }).parse(request.body)
    return reply.send({ success: true, data: await svc.updatePreferences(user.userId, body) })
  })

  app.post('/:id/read', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.markRead(id, user.userId) })
  })

  app.post('/read-all', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.markAllRead(user.userId) })
  })
}
