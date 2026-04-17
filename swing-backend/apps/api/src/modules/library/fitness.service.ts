import { prisma } from '@swing/db'
import { AppError } from '../../lib/errors'
import { toSlug, parseListQuery, buildListOrderBy } from './library.enums'

// ─── DTOs ────────────────────────────────────────────────────────────────────

export interface CreateFitnessExerciseDTO {
  name: string
  slug?: string
  description?: string
  category?: string
  subCategory?: string
  goalTags?: string[]
  bodyAreaTags?: string[]
  roleTags?: string[]
  levelTags?: string[]
  formatTags?: string[]
  equipmentTags?: string[]
  recommendedFor?: string[]
  avoidIfTags?: string[]
  durationMins?: number
  sets?: number
  reps?: number
  repsPerSide?: number
  holdSeconds?: number
  restSeconds?: number
  coolDownSeconds?: number
  targetUnit?: string
  targetValue?: number
  intensityLevel?: string
  readinessMin?: number
  readinessMax?: number
  fatigueImpact?: string
  recoveryLoad?: string
  instructions?: unknown
  coachingCues?: string[]
  commonMistakes?: string[]
  contraNotes?: string[]
  progressionNotes?: string
  regressionNotes?: string
  videoUrl?: string
  thumbnailUrl?: string
  status?: string
  isPublic?: boolean
  isActive?: boolean
  sortOrder?: number
}

export type UpdateFitnessExerciseDTO = Partial<CreateFitnessExerciseDTO> & { updatedById?: string }

// ─── Helpers ─────────────────────────────────────────────────────────────────

function sanitize(arr?: string[]): string[] {
  if (!arr) return []
  return arr.map(s => s.trim()).filter(Boolean)
}

// ─── Service ─────────────────────────────────────────────────────────────────

export class FitnessService {
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
      prisma.fitnessExercise.findMany({
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
          bodyAreaTags: true,
          goalTags: true,
          durationMins: true,
          sets: true,
          reps: true,
          holdSeconds: true,
          restSeconds: true,
          coolDownSeconds: true,
          intensityLevel: true,
          status: true,
          isActive: true,
          isPublic: true,
          sortOrder: true,
          usageCount: true,
          updatedAt: true,
        },
      }),
      prisma.fitnessExercise.count({ where }),
    ])

    return { items, page: q.page, limit: q.limit, total }
  }

  async getById(id: string) {
    const item = await prisma.fitnessExercise.findUnique({ where: { id } })
    if (!item) throw new AppError('NOT_FOUND', 'Fitness exercise not found', 404)
    return item
  }

  async create(userId: string, dto: CreateFitnessExerciseDTO) {
    const rawSlug = dto.slug ? toSlug(dto.slug) : toSlug(dto.name)
    const slug = await this.resolveUniqueSlug(rawSlug)

    const status = (dto.status ?? 'DRAFT') as any
    const publishedAt = status === 'PUBLISHED' ? new Date() : null

    return prisma.fitnessExercise.create({
      data: {
        createdById: userId,
        updatedById: userId,
        name: dto.name.trim(),
        slug,
        description: dto.description,
        category: dto.category,
        subCategory: dto.subCategory,
        goalTags: sanitize(dto.goalTags),
        bodyAreaTags: sanitize(dto.bodyAreaTags),
        roleTags: sanitize(dto.roleTags),
        levelTags: sanitize(dto.levelTags),
        formatTags: sanitize(dto.formatTags),
        equipmentTags: sanitize(dto.equipmentTags),
        recommendedFor: sanitize(dto.recommendedFor),
        avoidIfTags: sanitize(dto.avoidIfTags),
        durationMins: dto.durationMins,
        sets: dto.sets,
        reps: dto.reps,
        repsPerSide: dto.repsPerSide,
        holdSeconds: dto.holdSeconds,
        restSeconds: dto.restSeconds,
        coolDownSeconds: dto.coolDownSeconds,
        targetUnit: dto.targetUnit,
        targetValue: dto.targetValue,
        intensityLevel: dto.intensityLevel,
        readinessMin: dto.readinessMin,
        readinessMax: dto.readinessMax,
        fatigueImpact: dto.fatigueImpact,
        recoveryLoad: dto.recoveryLoad,
        instructions: dto.instructions as any,
        coachingCues: sanitize(dto.coachingCues),
        commonMistakes: sanitize(dto.commonMistakes),
        contraNotes: sanitize(dto.contraNotes),
        progressionNotes: dto.progressionNotes,
        regressionNotes: dto.regressionNotes,
        videoUrl: dto.videoUrl,
        thumbnailUrl: dto.thumbnailUrl,
        status,
        isPublic: dto.isPublic ?? false,
        isActive: dto.isActive ?? true,
        sortOrder: dto.sortOrder ?? 0,
        publishedAt,
      },
    })
  }

  async update(id: string, userId: string, dto: UpdateFitnessExerciseDTO) {
    const existing = await prisma.fitnessExercise.findUnique({ where: { id } })
    if (!existing) throw new AppError('NOT_FOUND', 'Fitness exercise not found', 404)

    const update: any = { updatedById: userId }

    if (dto.name !== undefined) update.name = dto.name.trim()
    if (dto.description !== undefined) update.description = dto.description
    if (dto.category !== undefined) update.category = dto.category
    if (dto.subCategory !== undefined) update.subCategory = dto.subCategory
    if (dto.goalTags !== undefined) update.goalTags = sanitize(dto.goalTags)
    if (dto.bodyAreaTags !== undefined) update.bodyAreaTags = sanitize(dto.bodyAreaTags)
    if (dto.roleTags !== undefined) update.roleTags = sanitize(dto.roleTags)
    if (dto.levelTags !== undefined) update.levelTags = sanitize(dto.levelTags)
    if (dto.formatTags !== undefined) update.formatTags = sanitize(dto.formatTags)
    if (dto.equipmentTags !== undefined) update.equipmentTags = sanitize(dto.equipmentTags)
    if (dto.recommendedFor !== undefined) update.recommendedFor = sanitize(dto.recommendedFor)
    if (dto.avoidIfTags !== undefined) update.avoidIfTags = sanitize(dto.avoidIfTags)
    if (dto.durationMins !== undefined) update.durationMins = dto.durationMins
    if (dto.sets !== undefined) update.sets = dto.sets
    if (dto.reps !== undefined) update.reps = dto.reps
    if (dto.repsPerSide !== undefined) update.repsPerSide = dto.repsPerSide
    if (dto.holdSeconds !== undefined) update.holdSeconds = dto.holdSeconds
    if (dto.restSeconds !== undefined) update.restSeconds = dto.restSeconds
    if (dto.coolDownSeconds !== undefined) update.coolDownSeconds = dto.coolDownSeconds
    if (dto.targetUnit !== undefined) update.targetUnit = dto.targetUnit
    if (dto.targetValue !== undefined) update.targetValue = dto.targetValue
    if (dto.intensityLevel !== undefined) update.intensityLevel = dto.intensityLevel
    if (dto.readinessMin !== undefined) update.readinessMin = dto.readinessMin
    if (dto.readinessMax !== undefined) update.readinessMax = dto.readinessMax
    if (dto.fatigueImpact !== undefined) update.fatigueImpact = dto.fatigueImpact
    if (dto.recoveryLoad !== undefined) update.recoveryLoad = dto.recoveryLoad
    if (dto.instructions !== undefined) update.instructions = dto.instructions as any
    if (dto.coachingCues !== undefined) update.coachingCues = sanitize(dto.coachingCues)
    if (dto.commonMistakes !== undefined) update.commonMistakes = sanitize(dto.commonMistakes)
    if (dto.contraNotes !== undefined) update.contraNotes = sanitize(dto.contraNotes)
    if (dto.progressionNotes !== undefined) update.progressionNotes = dto.progressionNotes
    if (dto.regressionNotes !== undefined) update.regressionNotes = dto.regressionNotes
    if (dto.videoUrl !== undefined) update.videoUrl = dto.videoUrl
    if (dto.thumbnailUrl !== undefined) update.thumbnailUrl = dto.thumbnailUrl
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

    return prisma.fitnessExercise.update({ where: { id }, data: update })
  }

  async delete(id: string) {
    const existing = await prisma.fitnessExercise.findUnique({ where: { id } })
    if (!existing) throw new AppError('NOT_FOUND', 'Fitness exercise not found', 404)

    await prisma.fitnessExercise.delete({ where: { id } })
    return { deleted: id }
  }

  private async resolveUniqueSlug(base: string, excludeId?: string): Promise<string> {
    let slug = base
    let attempt = 0
    while (true) {
      const existing = await prisma.fitnessExercise.findUnique({ where: { slug } })
      if (!existing || existing.id === excludeId) return slug
      attempt++
      slug = `${base}-${attempt}`
    }
  }
}
