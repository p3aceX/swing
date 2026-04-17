import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { DrillService } from './drill.service'
import {
  DRILL_CATEGORIES,
  DRILL_DIFFICULTIES,
  DRILL_TARGET_UNITS,
  DRILL_SOURCE_TYPES,
  HANDEDNESS_VALUES,
  INTENSITY_LEVELS,
  LOAD_LEVELS,
  LIBRARY_STATUSES,
} from './library.enums'

// ─── Validation Schemas ───────────────────────────────────────────────────────

const tagsField = z.array(z.string()).optional().default([])

const drillBodySchema = z.object({
  name: z.string().min(2).max(200),
  slug: z.string().optional(),
  description: z.string().optional(),
  category: z.enum(DRILL_CATEGORIES).optional(),
  skillArea: z.string().optional(),
  subSkill: z.string().optional(),
  roleTags: tagsField,
  goalTags: tagsField,
  formatTags: tagsField,
  equipmentTags: tagsField,
  bodyAreaTags: tagsField,
  levelTags: tagsField,
  roleSpecificity: z.string().optional(),
  recommendedFor: tagsField,
  difficulty: z.enum(DRILL_DIFFICULTIES).optional().default('BEGINNER'),
  durationMins: z.number().int().positive().optional(),
  targetUnit: z.enum(DRILL_TARGET_UNITS).optional(),
  targetValue: z.number().optional(),
  sets: z.number().int().positive().optional(),
  repsPerSet: z.number().int().positive().optional(),
  restSeconds: z.number().int().min(0).optional(),
  intensityLevel: z.enum(INTENSITY_LEVELS).optional(),
  recoveryLoad: z.enum(LOAD_LEVELS).optional(),
  fatigueImpact: z.enum(LOAD_LEVELS).optional(),
  handedness: z.enum(HANDEDNESS_VALUES).optional(),
  minAge: z.number().int().min(0).max(100).optional(),
  maxAge: z.number().int().min(0).max(100).optional(),
  instructions: z.any().optional(), // JSON steps array or object
  coachingCues: tagsField,
  commonMistakes: tagsField,
  successCriteria: tagsField,
  contraNotes: tagsField,
  videoUrl: z.string().url().optional(),
  thumbnailUrl: z.string().url().optional(),
  sourceType: z.enum(DRILL_SOURCE_TYPES).optional().default('SWING'),
  sourceRef: z.string().optional(),
  status: z.enum(LIBRARY_STATUSES).optional().default('DRAFT'),
  isPublic: z.boolean().optional().default(false),
  isActive: z.boolean().optional().default(true),
  sortOrder: z.number().int().min(0).optional().default(0),
})

const patchDrillSchema = drillBodySchema.partial()

// ─── Routes ───────────────────────────────────────────────────────────────────

export async function drillRoutes(app: FastifyInstance) {
  const svc = new DrillService()
  const auth = { onRequest: [(app as any).authenticate] }

  // GET /library/drills — list (public read)
  app.get('/', async (request, reply) => {
    const q = request.query as Record<string, string | undefined>
    return reply.send({ success: true, data: await svc.list(q) })
  })

  // GET /library/drills/:id — detail (public read)
  app.get('/:id', async (request, reply) => {
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getById(id) })
  })

  // POST /library/drills — create (auth required)
  app.post('/', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = drillBodySchema.parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.create(user.userId, body) })
  })

  // PATCH /library/drills/:id — partial update (auth required)
  app.patch('/:id', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = patchDrillSchema.parse(request.body)
    return reply.send({ success: true, data: await svc.update(id, user.userId, body) })
  })

  // DELETE /library/drills/:id — delete (auth required)
  app.delete('/:id', auth, async (request, reply) => {
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.delete(id) })
  })
}
