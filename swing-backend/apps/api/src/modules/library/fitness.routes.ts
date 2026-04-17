import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { FitnessService } from './fitness.service'
import {
  FITNESS_CATEGORIES,
  INTENSITY_LEVELS,
  LOAD_LEVELS,
  LIBRARY_STATUSES,
} from './library.enums'

// ─── Validation Schemas ───────────────────────────────────────────────────────

const tagsField = z.array(z.string()).optional().default([])

const fitnessBodySchema = z.object({
  name: z.string().min(2).max(200),
  slug: z.string().optional(),
  description: z.string().optional(),
  category: z.enum(FITNESS_CATEGORIES).optional(),
  subCategory: z.string().optional(),
  goalTags: tagsField,
  bodyAreaTags: tagsField,
  roleTags: tagsField,
  levelTags: tagsField,
  formatTags: tagsField,
  equipmentTags: tagsField,
  recommendedFor: tagsField,
  avoidIfTags: tagsField,
  durationMins: z.number().int().positive().optional(),
  sets: z.number().int().positive().optional(),
  reps: z.number().int().positive().optional(),
  repsPerSide: z.number().int().positive().optional(),
  holdSeconds: z.number().int().min(0).optional(),
  restSeconds: z.number().int().min(0).optional(),
  coolDownSeconds: z.number().int().min(0).optional(),
  targetUnit: z.string().optional(),
  targetValue: z.number().optional(),
  intensityLevel: z.enum(INTENSITY_LEVELS).optional(),
  readinessMin: z.number().int().min(0).max(10).optional(),
  readinessMax: z.number().int().min(0).max(10).optional(),
  fatigueImpact: z.enum(LOAD_LEVELS).optional(),
  recoveryLoad: z.enum(LOAD_LEVELS).optional(),
  instructions: z.any().optional(),
  coachingCues: tagsField,
  commonMistakes: tagsField,
  contraNotes: tagsField,
  progressionNotes: z.string().optional(),
  regressionNotes: z.string().optional(),
  videoUrl: z.string().url().optional(),
  thumbnailUrl: z.string().url().optional(),
  status: z.enum(LIBRARY_STATUSES).optional().default('DRAFT'),
  isPublic: z.boolean().optional().default(false),
  isActive: z.boolean().optional().default(true),
  sortOrder: z.number().int().min(0).optional().default(0),
})

const patchFitnessSchema = fitnessBodySchema.partial()

// ─── Routes ───────────────────────────────────────────────────────────────────

export async function fitnessRoutes(app: FastifyInstance) {
  const svc = new FitnessService()
  const auth = { onRequest: [(app as any).authenticate] }

  // GET /library/fitness-exercises
  app.get('/', async (request, reply) => {
    const q = request.query as Record<string, string | undefined>
    return reply.send({ success: true, data: await svc.list(q) })
  })

  // GET /library/fitness-exercises/:id
  app.get('/:id', async (request, reply) => {
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getById(id) })
  })

  // POST /library/fitness-exercises
  app.post('/', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = fitnessBodySchema.parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.create(user.userId, body) })
  })

  // PATCH /library/fitness-exercises/:id
  app.patch('/:id', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = patchFitnessSchema.parse(request.body)
    return reply.send({ success: true, data: await svc.update(id, user.userId, body) })
  })

  // DELETE /library/fitness-exercises/:id
  app.delete('/:id', auth, async (request, reply) => {
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.delete(id) })
  })
}
