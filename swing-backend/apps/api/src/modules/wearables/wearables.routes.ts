import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { PerformanceService } from '../performance/performance.service'

const wearableIngestSchema = z.object({
  sourceRefId: z.string().max(120).optional(),
  sampleStartAt: z.string(),
  sampleEndAt: z.string(),
  caloriesBurned: z.number().nonnegative().optional(),
  averageHeartRate: z.number().nonnegative().optional(),
  maxHeartRate: z.number().nonnegative().optional(),
  distanceMeters: z.number().nonnegative().optional(),
  sprintCount: z.number().int().nonnegative().optional(),
  activeMinutes: z.number().nonnegative().optional(),
  workloadScore: z.number().nonnegative().optional(),
  recoveryScore: z.number().nonnegative().optional(),
  sleepHours: z.number().nonnegative().optional(),
  hydrationMetric: z.number().nonnegative().optional(),
  steps: z.number().int().nonnegative().optional(),
  hrv: z.number().nonnegative().optional(),
  sleepStartAt: z.string().optional(),
  sleepEndAt: z.string().optional(),
  weightKg: z.number().nonnegative().optional(),
  source: z.string().max(50).optional(),
  rawPayload: z.record(z.unknown()).optional(),
})

export async function wearablesRoutes(app: FastifyInstance) {
  const svc = new PerformanceService()
  const auth = { onRequest: [(app as any).authenticate] }

  app.post('/ingest', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = wearableIngestSchema.parse(request.body)
    return reply.code(201).send({
      success: true,
      data: await svc.ingestWearableSample(user.userId, body),
    })
  })
}
