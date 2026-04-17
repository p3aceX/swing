// ─── Library Enums & Allowed Values ──────────────────────────────────────────
// Used for validation across Drill, Fitness, and Nutrition routes.
// These are string-based (not Prisma enums) to keep the taxonomy flexible.

export const LIBRARY_STATUSES = ['DRAFT', 'REVIEW', 'PUBLISHED', 'ARCHIVED'] as const
export type LibraryStatus = typeof LIBRARY_STATUSES[number]

// Drill
export const DRILL_CATEGORIES = ['TECHNIQUE', 'FITNESS', 'MENTAL', 'MATCH_SIMULATION'] as const
export const DRILL_DIFFICULTIES = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'ELITE'] as const
export const DRILL_TARGET_UNITS = ['BALLS', 'OVERS', 'MINUTES', 'REPS', 'SESSIONS'] as const
export const DRILL_SOURCE_TYPES = ['SWING', 'COACH', 'EXTERNAL'] as const
export const HANDEDNESS_VALUES = ['BOTH', 'RIGHT', 'LEFT'] as const

// Fitness
export const FITNESS_CATEGORIES = [
  'WARMUP', 'MOBILITY', 'STRENGTH', 'CONDITIONING',
  'RECOVERY', 'COOLDOWN', 'PLYOMETRICS', 'YOGA', 'BREATHWORK',
] as const

// Nutrition
export const NUTRITION_CATEGORIES = [
  'PRE_MATCH', 'POST_MATCH', 'RECOVERY', 'DAILY',
  'HYDRATION', 'SUPPLEMENT', 'SNACK', 'MEAL',
] as const
export const DIGESTIBILITY_VALUES = ['LIGHT', 'MODERATE', 'HEAVY'] as const

// Shared
export const INTENSITY_LEVELS = ['LOW', 'MODERATE', 'HIGH', 'MAXIMAL'] as const
export const LOAD_LEVELS = ['LOW', 'MODERATE', 'HIGH'] as const

// ─── Slug utility ────────────────────────────────────────────────────────────

export function toSlug(name: string): string {
  return name
    .toLowerCase()
    .trim()
    .replace(/[^\w\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-|-$/g, '')
}

export function toUniqueSlug(name: string, suffix?: string): string {
  const base = toSlug(name)
  return suffix ? `${base}-${suffix}` : base
}

// ─── List query parser ───────────────────────────────────────────────────────

export interface LibraryListQuery {
  search?: string
  status?: string
  category?: string
  isActive?: string
  sortBy?: string
  sortDir?: 'asc' | 'desc'
  page: number
  limit: number
}

export function parseListQuery(q: Record<string, string | undefined>): LibraryListQuery {
  const page = Math.max(1, Number(q.page) || 1)
  const limit = Math.min(100, Math.max(1, Number(q.limit) || 20))
  const sortDir = q.sortDir === 'asc' ? 'asc' : 'desc'
  return { search: q.search, status: q.status, category: q.category, isActive: q.isActive, sortBy: q.sortBy, sortDir, page, limit }
}

export function buildListOrderBy(sortBy?: string): Record<string, 'asc' | 'desc'> {
  const validSorts = ['createdAt', 'updatedAt', 'sortOrder', 'name', 'usageCount']
  const field = validSorts.includes(sortBy ?? '') ? sortBy! : 'createdAt'
  return { [field]: 'desc' }
}
