import { FastifyInstance } from 'fastify'
import { GrowthInsightsService } from './growth-insights.service'
import { EliteAnalyticsService } from './elite-analytics.service'
import { DevelopmentService } from '../development/development.service'
import { GigService } from '../gigs/gig.service'

export async function growthInsightsRoutes(app: FastifyInstance) {
  const svc = new GrowthInsightsService(
    new EliteAnalyticsService(),
    new DevelopmentService(),
    new GigService()
  )

  app.get('/growth-insights', { onRequest: [(app as any).authenticate] }, async (request, reply) => {
    const { userId } = request.user as { userId: string }
    const data = await svc.getInsights(userId)
    return reply.send({ success: true, data })
  })

  app.get('/nearby-coaches', { onRequest: [(app as any).authenticate] }, async (request, reply) => {
    const { userId } = request.user as { userId: string }
    const { weakness } = request.query as { weakness?: string }
    const data = await svc.getNearbyCoaches(userId, weakness)
    return reply.send({ success: true, data })
  })
}
