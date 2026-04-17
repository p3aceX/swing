import { prisma } from '@swing/db'
import { AppError } from '../../lib/errors'
import {
  toSlug,
  toUniqueSlug,
  parseListQuery,
  buildListOrderBy,
  LibraryListQuery,
} from './library.enums'

// ─── DTOs ────────────────────────────────────────────────────────────────────

export interface CreateDrillDTO {
  createdById?: string
  name: string
  slug?: string
  description?: string
  category?: string
  skillArea?: string
  subSkill?: string
  roleTags?: string[]
  goalTags?: string[]
  formatTags?: string[]
  equipmentTags?: string[]
  bodyAreaTags?: string[]
  levelTags?: string[]
  roleSpecificity?: string
  recommendedFor?: string[]
  difficulty?: string
  durationMins?: number
  targetUnit?: string
  targetValue?: number
  sets?: number
  repsPerSet?: number
  restSeconds?: number
  intensityLevel?: string
  recoveryLoad?: string
  fatigueImpact?: string
  handedness?: string
  minAge?: number
  maxAge?: number
  instructions?: unknown
  coachingCues?: string[]
  commonMistakes?: string[]
  successCriteria?: string[]
  contraNotes?: string[]
  videoUrl?: string
  thumbnailUrl?: string
  sourceType?: string
  sourceRef?: string
  status?: string
  isPublic?: boolean
  isActive?: boolean
  sortOrder?: number
}

export type UpdateDrillDTO = Partial<CreateDrillDTO> & { updatedById?: string }

// ─── Helpers ─────────────────────────────────────────────────────────────────

function sanitizeArrayField(arr?: string[]): string[] {
  if (!arr) return []
  return arr.map(s => s.trim()).filter(Boolean)
}

function buildPublishedAt(status?: string, existingPublishedAt?: Date | null): Date | null | undefined {
  if (status === 'PUBLISHED') return existingPublishedAt ?? new Date()
  return undefined // don't touch it
}

// ─── Service ─────────────────────────────────────────────────────────────────

export class DrillService {
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
      prisma.drillLibraryItem.findMany({
        where,
        orderBy,
        skip,
        take: q.limit,
        select: {
          id: true,
          name: true,
          slug: true,
          category: true,
          skillArea: true,
          difficulty: true,
          durationMins: true,
          roleTags: true,
          targetUnit: true,
          targetValue: true,
          intensityLevel: true,
          status: true,
          isActive: true,
          isPublic: true,
          sortOrder: true,
          usageCount: true,
          updatedAt: true,
        },
      }),
      prisma.drillLibraryItem.count({ where }),
    ])

    return { items, page: q.page, limit: q.limit, total }
  }

  async getById(id: string) {
    const drill = await prisma.drillLibraryItem.findUnique({ where: { id } })
    if (!drill) throw new AppError('NOT_FOUND', 'Drill not found', 404)
    return drill
  }

  async getBySlug(slug: string) {
    const drill = await prisma.drillLibraryItem.findUnique({ where: { slug } })
    if (!drill) throw new AppError('NOT_FOUND', 'Drill not found', 404)
    return drill
  }

  async create(userId: string, dto: CreateDrillDTO) {
    const rawSlug = dto.slug ? toSlug(dto.slug) : toSlug(dto.name)
    const slug = await this.resolveUniqueSlug(rawSlug)

    const status = (dto.status ?? 'DRAFT') as any
    const publishedAt = status === 'PUBLISHED' ? new Date() : null

    return prisma.drillLibraryItem.create({
      data: {
        createdById: userId,
        updatedById: userId,
        name: dto.name.trim(),
        slug,
        description: dto.description,
        category: dto.category,
        skillArea: dto.skillArea,
        subSkill: dto.subSkill,
        roleTags: sanitizeArrayField(dto.roleTags),
        goalTags: sanitizeArrayField(dto.goalTags),
        formatTags: sanitizeArrayField(dto.formatTags),
        equipmentTags: sanitizeArrayField(dto.equipmentTags),
        bodyAreaTags: sanitizeArrayField(dto.bodyAreaTags),
        levelTags: sanitizeArrayField(dto.levelTags),
        roleSpecificity: dto.roleSpecificity,
        recommendedFor: sanitizeArrayField(dto.recommendedFor),
        difficulty: dto.difficulty ?? 'BEGINNER',
        durationMins: dto.durationMins,
        targetUnit: dto.targetUnit,
        targetValue: dto.targetValue,
        sets: dto.sets,
        repsPerSet: dto.repsPerSet,
        restSeconds: dto.restSeconds,
        intensityLevel: dto.intensityLevel,
        recoveryLoad: dto.recoveryLoad,
        fatigueImpact: dto.fatigueImpact,
        handedness: dto.handedness,
        minAge: dto.minAge,
        maxAge: dto.maxAge,
        instructions: dto.instructions as any,
        coachingCues: sanitizeArrayField(dto.coachingCues),
        commonMistakes: sanitizeArrayField(dto.commonMistakes),
        successCriteria: sanitizeArrayField(dto.successCriteria),
        contraNotes: sanitizeArrayField(dto.contraNotes),
        videoUrl: dto.videoUrl,
        thumbnailUrl: dto.thumbnailUrl,
        sourceType: dto.sourceType ?? 'SWING',
        sourceRef: dto.sourceRef,
        status,
        isPublic: dto.isPublic ?? false,
        isActive: dto.isActive ?? true,
        sortOrder: dto.sortOrder ?? 0,
        publishedAt,
      },
    })
  }

  async update(id: string, userId: string, dto: UpdateDrillDTO) {
    const existing = await prisma.drillLibraryItem.findUnique({ where: { id } })
    if (!existing) throw new AppError('NOT_FOUND', 'Drill not found', 404)

    const update: any = { updatedById: userId }

    // Only set fields that were explicitly passed
    if (dto.name !== undefined) update.name = dto.name.trim()
    if (dto.description !== undefined) update.description = dto.description
    if (dto.category !== undefined) update.category = dto.category
    if (dto.skillArea !== undefined) update.skillArea = dto.skillArea
    if (dto.subSkill !== undefined) update.subSkill = dto.subSkill
    if (dto.roleTags !== undefined) update.roleTags = sanitizeArrayField(dto.roleTags)
    if (dto.goalTags !== undefined) update.goalTags = sanitizeArrayField(dto.goalTags)
    if (dto.formatTags !== undefined) update.formatTags = sanitizeArrayField(dto.formatTags)
    if (dto.equipmentTags !== undefined) update.equipmentTags = sanitizeArrayField(dto.equipmentTags)
    if (dto.bodyAreaTags !== undefined) update.bodyAreaTags = sanitizeArrayField(dto.bodyAreaTags)
    if (dto.levelTags !== undefined) update.levelTags = sanitizeArrayField(dto.levelTags)
    if (dto.roleSpecificity !== undefined) update.roleSpecificity = dto.roleSpecificity
    if (dto.recommendedFor !== undefined) update.recommendedFor = sanitizeArrayField(dto.recommendedFor)
    if (dto.difficulty !== undefined) update.difficulty = dto.difficulty
    if (dto.durationMins !== undefined) update.durationMins = dto.durationMins
    if (dto.targetUnit !== undefined) update.targetUnit = dto.targetUnit
    if (dto.targetValue !== undefined) update.targetValue = dto.targetValue
    if (dto.sets !== undefined) update.sets = dto.sets
    if (dto.repsPerSet !== undefined) update.repsPerSet = dto.repsPerSet
    if (dto.restSeconds !== undefined) update.restSeconds = dto.restSeconds
    if (dto.intensityLevel !== undefined) update.intensityLevel = dto.intensityLevel
    if (dto.recoveryLoad !== undefined) update.recoveryLoad = dto.recoveryLoad
    if (dto.fatigueImpact !== undefined) update.fatigueImpact = dto.fatigueImpact
    if (dto.handedness !== undefined) update.handedness = dto.handedness
    if (dto.minAge !== undefined) update.minAge = dto.minAge
    if (dto.maxAge !== undefined) update.maxAge = dto.maxAge
    if (dto.instructions !== undefined) update.instructions = dto.instructions as any
    if (dto.coachingCues !== undefined) update.coachingCues = sanitizeArrayField(dto.coachingCues)
    if (dto.commonMistakes !== undefined) update.commonMistakes = sanitizeArrayField(dto.commonMistakes)
    if (dto.successCriteria !== undefined) update.successCriteria = sanitizeArrayField(dto.successCriteria)
    if (dto.contraNotes !== undefined) update.contraNotes = sanitizeArrayField(dto.contraNotes)
    if (dto.videoUrl !== undefined) update.videoUrl = dto.videoUrl
    if (dto.thumbnailUrl !== undefined) update.thumbnailUrl = dto.thumbnailUrl
    if (dto.sourceType !== undefined) update.sourceType = dto.sourceType
    if (dto.sourceRef !== undefined) update.sourceRef = dto.sourceRef
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

    return prisma.drillLibraryItem.update({ where: { id }, data: update })
  }

  async delete(id: string) {
    const existing = await prisma.drillLibraryItem.findUnique({ where: { id } })
    if (!existing) throw new AppError('NOT_FOUND', 'Drill not found', 404)

    await prisma.drillLibraryItem.delete({ where: { id } })
    return { deleted: id }
  }

  private async resolveUniqueSlug(base: string, excludeId?: string): Promise<string> {
    let slug = base
    let attempt = 0
    while (true) {
      const existing = await prisma.drillLibraryItem.findUnique({ where: { slug } })
      if (!existing || existing.id === excludeId) return slug
      attempt++
      slug = `${base}-${attempt}`
    }
  }
}
