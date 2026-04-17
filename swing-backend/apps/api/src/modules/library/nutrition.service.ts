import { prisma } from '@swing/db'
import { AppError } from '../../lib/errors'
import { toSlug, parseListQuery, buildListOrderBy } from './library.enums'

// ─── DTOs ────────────────────────────────────────────────────────────────────

export interface CreateNutritionItemDTO {
  name: string
  slug?: string
  description?: string
  category?: string
  subCategory?: string
  goalTags?: string[]
  timingTags?: string[]
  dietTags?: string[]
  allergenTags?: string[]
  cuisineTags?: string[]
  recommendedFor?: string[]
  avoidIfTags?: string[]
  servingQty?: number
  servingUnit?: string
  frequencyNote?: string
  prepTimeMins?: number
  bestWindowMinsBefore?: number
  bestWindowMinsAfter?: number
  calories?: number
  proteinG?: number
  carbsG?: number
  fatG?: number
  fiberG?: number
  sugarG?: number
  sodiumMg?: number
  potassiumMg?: number
  waterMl?: number
  hydrationScore?: number
  recoveryScore?: number
  energyScore?: number
  digestibility?: string
  matchDaySafe?: boolean
  heavyMeal?: boolean
  suitabilityNotes?: string
  status?: string
  isPublic?: boolean
  isActive?: boolean
  sortOrder?: number
}

export type UpdateNutritionItemDTO = Partial<CreateNutritionItemDTO> & { updatedById?: string }

export interface CreateRecipeDTO {
  title: string
  description?: string
  ingredients?: unknown
  instructions?: unknown
  prepTimeMins?: number
  cookTimeMins?: number
  totalTimeMins?: number
  serves?: number
  videoUrl?: string
  thumbnailUrl?: string
  isPrimary?: boolean
  status?: string
}

export type UpdateRecipeDTO = Partial<CreateRecipeDTO>

// ─── Helpers ─────────────────────────────────────────────────────────────────

function sanitize(arr?: string[]): string[] {
  if (!arr) return []
  return arr.map(s => s.trim()).filter(Boolean)
}

// ─── Service ─────────────────────────────────────────────────────────────────

export class NutritionService {
  // ── NutritionItem ──────────────────────────────────────────────────────────

  async list(rawQuery: Record<string, string | undefined>) {
    const q = parseListQuery(rawQuery)
    const where: any = {}

    if (q.search) where.name = { contains: q.search, mode: 'insensitive' }
    if (q.status) where.status = q.status
    if (q.category) where.category = q.category
    if (q.isActive !== undefined) where.isActive = q.isActive === 'true'

    const orderBy = buildListOrderBy(q.sortBy)
    const skip = (q.page - 1) * q.limit

    const [items, total] = await Promise.all([
      prisma.nutritionItem.findMany({
        where,
        orderBy,
        skip,
        take: q.limit,
        select: {
          id: true,
          name: true,
          slug: true,
          category: true,
          subCategory: true,
          timingTags: true,
          goalTags: true,
          calories: true,
          proteinG: true,
          carbsG: true,
          fatG: true,
          matchDaySafe: true,
          heavyMeal: true,
          digestibility: true,
          status: true,
          isActive: true,
          isPublic: true,
          sortOrder: true,
          usageCount: true,
          updatedAt: true,
          _count: { select: { recipes: true } },
        },
      }),
      prisma.nutritionItem.count({ where }),
    ])

    const mapped = items.map(({ _count, ...item }) => ({
      ...item,
      recipeCount: _count.recipes,
    }))

    return { items: mapped, page: q.page, limit: q.limit, total }
  }

  async getById(id: string) {
    const item = await prisma.nutritionItem.findUnique({
      where: { id },
      include: {
        recipes: {
          orderBy: [{ isPrimary: 'desc' }, { createdAt: 'asc' }],
        },
      },
    })
    if (!item) throw new AppError('NOT_FOUND', 'Nutrition item not found', 404)
    return item
  }

  async create(userId: string, dto: CreateNutritionItemDTO) {
    const rawSlug = dto.slug ? toSlug(dto.slug) : toSlug(dto.name)
    const slug = await this.resolveUniqueSlug(rawSlug)

    const status = (dto.status ?? 'DRAFT') as any
    const publishedAt = status === 'PUBLISHED' ? new Date() : null

    return prisma.nutritionItem.create({
      data: {
        createdById: userId,
        updatedById: userId,
        name: dto.name.trim(),
        slug,
        description: dto.description,
        category: dto.category,
        subCategory: dto.subCategory,
        goalTags: sanitize(dto.goalTags),
        timingTags: sanitize(dto.timingTags),
        dietTags: sanitize(dto.dietTags),
        allergenTags: sanitize(dto.allergenTags),
        cuisineTags: sanitize(dto.cuisineTags),
        recommendedFor: sanitize(dto.recommendedFor),
        avoidIfTags: sanitize(dto.avoidIfTags),
        servingQty: dto.servingQty,
        servingUnit: dto.servingUnit,
        frequencyNote: dto.frequencyNote,
        prepTimeMins: dto.prepTimeMins,
        bestWindowMinsBefore: dto.bestWindowMinsBefore,
        bestWindowMinsAfter: dto.bestWindowMinsAfter,
        calories: dto.calories,
        proteinG: dto.proteinG,
        carbsG: dto.carbsG,
        fatG: dto.fatG,
        fiberG: dto.fiberG,
        sugarG: dto.sugarG,
        sodiumMg: dto.sodiumMg,
        potassiumMg: dto.potassiumMg,
        waterMl: dto.waterMl,
        hydrationScore: dto.hydrationScore,
        recoveryScore: dto.recoveryScore,
        energyScore: dto.energyScore,
        digestibility: dto.digestibility,
        matchDaySafe: dto.matchDaySafe ?? false,
        heavyMeal: dto.heavyMeal ?? false,
        suitabilityNotes: dto.suitabilityNotes,
        status,
        isPublic: dto.isPublic ?? false,
        isActive: dto.isActive ?? true,
        sortOrder: dto.sortOrder ?? 0,
        publishedAt,
      },
    })
  }

  async update(id: string, userId: string, dto: UpdateNutritionItemDTO) {
    const existing = await prisma.nutritionItem.findUnique({ where: { id } })
    if (!existing) throw new AppError('NOT_FOUND', 'Nutrition item not found', 404)

    const update: any = { updatedById: userId }

    if (dto.name !== undefined) update.name = dto.name.trim()
    if (dto.description !== undefined) update.description = dto.description
    if (dto.category !== undefined) update.category = dto.category
    if (dto.subCategory !== undefined) update.subCategory = dto.subCategory
    if (dto.goalTags !== undefined) update.goalTags = sanitize(dto.goalTags)
    if (dto.timingTags !== undefined) update.timingTags = sanitize(dto.timingTags)
    if (dto.dietTags !== undefined) update.dietTags = sanitize(dto.dietTags)
    if (dto.allergenTags !== undefined) update.allergenTags = sanitize(dto.allergenTags)
    if (dto.cuisineTags !== undefined) update.cuisineTags = sanitize(dto.cuisineTags)
    if (dto.recommendedFor !== undefined) update.recommendedFor = sanitize(dto.recommendedFor)
    if (dto.avoidIfTags !== undefined) update.avoidIfTags = sanitize(dto.avoidIfTags)
    if (dto.servingQty !== undefined) update.servingQty = dto.servingQty
    if (dto.servingUnit !== undefined) update.servingUnit = dto.servingUnit
    if (dto.frequencyNote !== undefined) update.frequencyNote = dto.frequencyNote
    if (dto.prepTimeMins !== undefined) update.prepTimeMins = dto.prepTimeMins
    if (dto.bestWindowMinsBefore !== undefined) update.bestWindowMinsBefore = dto.bestWindowMinsBefore
    if (dto.bestWindowMinsAfter !== undefined) update.bestWindowMinsAfter = dto.bestWindowMinsAfter
    if (dto.calories !== undefined) update.calories = dto.calories
    if (dto.proteinG !== undefined) update.proteinG = dto.proteinG
    if (dto.carbsG !== undefined) update.carbsG = dto.carbsG
    if (dto.fatG !== undefined) update.fatG = dto.fatG
    if (dto.fiberG !== undefined) update.fiberG = dto.fiberG
    if (dto.sugarG !== undefined) update.sugarG = dto.sugarG
    if (dto.sodiumMg !== undefined) update.sodiumMg = dto.sodiumMg
    if (dto.potassiumMg !== undefined) update.potassiumMg = dto.potassiumMg
    if (dto.waterMl !== undefined) update.waterMl = dto.waterMl
    if (dto.hydrationScore !== undefined) update.hydrationScore = dto.hydrationScore
    if (dto.recoveryScore !== undefined) update.recoveryScore = dto.recoveryScore
    if (dto.energyScore !== undefined) update.energyScore = dto.energyScore
    if (dto.digestibility !== undefined) update.digestibility = dto.digestibility
    if (dto.matchDaySafe !== undefined) update.matchDaySafe = dto.matchDaySafe
    if (dto.heavyMeal !== undefined) update.heavyMeal = dto.heavyMeal
    if (dto.suitabilityNotes !== undefined) update.suitabilityNotes = dto.suitabilityNotes
    if (dto.isPublic !== undefined) update.isPublic = dto.isPublic
    if (dto.isActive !== undefined) update.isActive = dto.isActive
    if (dto.sortOrder !== undefined) update.sortOrder = dto.sortOrder

    if (dto.slug !== undefined) {
      const newSlug = toSlug(dto.slug)
      if (newSlug !== existing.slug) {
        update.slug = await this.resolveUniqueSlug(newSlug, id)
      }
    }

    if (dto.status !== undefined) {
      update.status = dto.status as any
      if (dto.status === 'PUBLISHED' && !existing.publishedAt) {
        update.publishedAt = new Date()
      }
    }

    return prisma.nutritionItem.update({ where: { id }, data: update })
  }

  async delete(id: string) {
    const existing = await prisma.nutritionItem.findUnique({ where: { id } })
    if (!existing) throw new AppError('NOT_FOUND', 'Nutrition item not found', 404)

    await prisma.nutritionItem.delete({ where: { id } })
    return { deleted: id }
  }

  // ── NutritionRecipe ────────────────────────────────────────────────────────

  async createRecipe(nutritionItemId: string, userId: string, dto: CreateRecipeDTO) {
    // Verify parent exists
    const parent = await prisma.nutritionItem.findUnique({ where: { id: nutritionItemId } })
    if (!parent) throw new AppError('NOT_FOUND', 'Nutrition item not found', 404)

    const status = (dto.status ?? 'DRAFT') as any

    // If isPrimary, unset existing primary for this item
    if (dto.isPrimary) {
      await prisma.nutritionRecipe.updateMany({
        where: { nutritionItemId, isPrimary: true },
        data: { isPrimary: false },
      })
    }

    return prisma.nutritionRecipe.create({
      data: {
        nutritionItemId,
        title: dto.title.trim(),
        description: dto.description,
        ingredients: dto.ingredients as any,
        instructions: dto.instructions as any,
        prepTimeMins: dto.prepTimeMins,
        cookTimeMins: dto.cookTimeMins,
        totalTimeMins: dto.totalTimeMins,
        serves: dto.serves,
        videoUrl: dto.videoUrl,
        thumbnailUrl: dto.thumbnailUrl,
        isPrimary: dto.isPrimary ?? false,
        status,
      },
    })
  }

  async updateRecipe(id: string, dto: UpdateRecipeDTO) {
    const existing = await prisma.nutritionRecipe.findUnique({ where: { id } })
    if (!existing) throw new AppError('NOT_FOUND', 'Recipe not found', 404)

    const update: any = {}

    if (dto.title !== undefined) update.title = dto.title.trim()
    if (dto.description !== undefined) update.description = dto.description
    if (dto.ingredients !== undefined) update.ingredients = dto.ingredients as any
    if (dto.instructions !== undefined) update.instructions = dto.instructions as any
    if (dto.prepTimeMins !== undefined) update.prepTimeMins = dto.prepTimeMins
    if (dto.cookTimeMins !== undefined) update.cookTimeMins = dto.cookTimeMins
    if (dto.totalTimeMins !== undefined) update.totalTimeMins = dto.totalTimeMins
    if (dto.serves !== undefined) update.serves = dto.serves
    if (dto.videoUrl !== undefined) update.videoUrl = dto.videoUrl
    if (dto.thumbnailUrl !== undefined) update.thumbnailUrl = dto.thumbnailUrl
    if (dto.status !== undefined) update.status = dto.status as any

    // Handle primary promotion
    if (dto.isPrimary === true && !existing.isPrimary) {
      await prisma.nutritionRecipe.updateMany({
        where: { nutritionItemId: existing.nutritionItemId, isPrimary: true, id: { not: id } },
        data: { isPrimary: false },
      })
      update.isPrimary = true
    } else if (dto.isPrimary === false) {
      update.isPrimary = false
    }

    return prisma.nutritionRecipe.update({ where: { id }, data: update })
  }

  async deleteRecipe(id: string) {
    const existing = await prisma.nutritionRecipe.findUnique({ where: { id } })
    if (!existing) throw new AppError('NOT_FOUND', 'Recipe not found', 404)
    await prisma.nutritionRecipe.delete({ where: { id } })
    return { deleted: id }
  }

  // ── Private ────────────────────────────────────────────────────────────────

  private async resolveUniqueSlug(base: string, excludeId?: string): Promise<string> {
    let slug = base
    let attempt = 0
    while (true) {
      const existing = await prisma.nutritionItem.findUnique({ where: { slug } })
      if (!existing || existing.id === excludeId) return slug
      attempt++
      slug = `${base}-${attempt}`
    }
  }
}
