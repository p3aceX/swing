import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { NutritionService } from './nutrition.service'
import {
  NUTRITION_CATEGORIES,
  DIGESTIBILITY_VALUES,
  LIBRARY_STATUSES,
} from './library.enums'

// ─── Validation Schemas ───────────────────────────────────────────────────────

const tagsField = z.array(z.string()).optional().default([])

const nutritionItemBodySchema = z.object({
  name: z.string().min(2).max(200),
  slug: z.string().optional(),
  description: z.string().optional(),
  category: z.enum(NUTRITION_CATEGORIES).optional(),
  subCategory: z.string().optional(),
  goalTags: tagsField,
  timingTags: tagsField,
  dietTags: tagsField,
  allergenTags: tagsField,
  cuisineTags: tagsField,
  recommendedFor: tagsField,
  avoidIfTags: tagsField,
  servingQty: z.number().positive().optional(),
  servingUnit: z.string().optional(),
  frequencyNote: z.string().optional(),
  prepTimeMins: z.number().int().min(0).optional(),
  bestWindowMinsBefore: z.number().int().min(0).optional(),
  bestWindowMinsAfter: z.number().int().min(0).optional(),
  calories: z.number().min(0).optional(),
  proteinG: z.number().min(0).optional(),
  carbsG: z.number().min(0).optional(),
  fatG: z.number().min(0).optional(),
  fiberG: z.number().min(0).optional(),
  sugarG: z.number().min(0).optional(),
  sodiumMg: z.number().min(0).optional(),
  potassiumMg: z.number().min(0).optional(),
  waterMl: z.number().min(0).optional(),
  hydrationScore: z.number().min(0).max(10).optional(),
  recoveryScore: z.number().min(0).max(10).optional(),
  energyScore: z.number().min(0).max(10).optional(),
  digestibility: z.enum(DIGESTIBILITY_VALUES).optional(),
  matchDaySafe: z.boolean().optional().default(false),
  heavyMeal: z.boolean().optional().default(false),
  suitabilityNotes: z.string().optional(),
  status: z.enum(LIBRARY_STATUSES).optional().default('DRAFT'),
  isPublic: z.boolean().optional().default(false),
  isActive: z.boolean().optional().default(true),
  sortOrder: z.number().int().min(0).optional().default(0),
})

const patchNutritionItemSchema = nutritionItemBodySchema.partial()

const recipeBodySchema = z.object({
  title: z.string().min(2).max(200),
  description: z.string().optional(),
  ingredients: z.any().optional(), // JSON: [{name, qty, unit}]
  instructions: z.any().optional(), // JSON: [{step, text}]
  prepTimeMins: z.number().int().min(0).optional(),
  cookTimeMins: z.number().int().min(0).optional(),
  totalTimeMins: z.number().int().min(0).optional(),
  serves: z.number().int().positive().optional(),
  videoUrl: z.string().url().optional(),
  thumbnailUrl: z.string().url().optional(),
  isPrimary: z.boolean().optional().default(false),
  status: z.enum(LIBRARY_STATUSES).optional().default('DRAFT'),
})

const patchRecipeSchema = recipeBodySchema.partial()

// ─── Routes ───────────────────────────────────────────────────────────────────

export async function nutritionRoutes(app: FastifyInstance) {
  const svc = new NutritionService()
  const auth = { onRequest: [(app as any).authenticate] }

  // ── NutritionItem ──────────────────────────────────────────────────────────

  // GET /library/nutrition-items
  app.get('/nutrition-items', async (request, reply) => {
    const q = request.query as Record<string, string | undefined>
    return reply.send({ success: true, data: await svc.list(q) })
  })

  // GET /library/nutrition-items/:id (includes recipes)
  app.get('/nutrition-items/:id', async (request, reply) => {
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getById(id) })
  })

  // POST /library/nutrition-items
  app.post('/nutrition-items', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = nutritionItemBodySchema.parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.create(user.userId, body) })
  })

  // PATCH /library/nutrition-items/:id
  app.patch('/nutrition-items/:id', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = patchNutritionItemSchema.parse(request.body)
    return reply.send({ success: true, data: await svc.update(id, user.userId, body) })
  })

  // DELETE /library/nutrition-items/:id
  app.delete('/nutrition-items/:id', auth, async (request, reply) => {
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.delete(id) })
  })

  // ── NutritionRecipe ────────────────────────────────────────────────────────

  // POST /library/nutrition-items/:nutritionItemId/recipes
  app.post('/nutrition-items/:nutritionItemId/recipes', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { nutritionItemId } = request.params as { nutritionItemId: string }
    const body = recipeBodySchema.parse(request.body)
    return reply.code(201).send({
      success: true,
      data: await svc.createRecipe(nutritionItemId, user.userId, body),
    })
  })

  // PATCH /library/nutrition-recipes/:id
  app.patch('/nutrition-recipes/:id', auth, async (request, reply) => {
    const { id } = request.params as { id: string }
    const body = patchRecipeSchema.parse(request.body)
    return reply.send({ success: true, data: await svc.updateRecipe(id, body) })
  })

  // DELETE /library/nutrition-recipes/:id
  app.delete('/nutrition-recipes/:id', auth, async (request, reply) => {
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.deleteRecipe(id) })
  })
}
