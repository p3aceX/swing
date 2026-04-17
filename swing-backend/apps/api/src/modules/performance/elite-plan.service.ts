import { prisma } from '@swing/db'
import { PlanWeekday, PerformanceSessionType } from '@prisma/client'
import { AppError } from '../../lib/errors'

export interface WeeklyPlanDayDTO {
  weekday: PlanWeekday
  hasNets?: boolean
  hasSkillWork?: boolean
  hasGym?: boolean
  hasConditioning?: boolean
  hasMatch?: boolean
  hasRecovery?: boolean
  hasProperDiet?: boolean
  netsMinutes?: number
  drillsMinutes?: number
  fitnessMinutes?: number
  recoveryMinutes?: number
  sleepTargetHours?: number
  hydrationTargetLiters?: number
}

export interface WeeklyPlanDTO {
  name: string
  days: WeeklyPlanDayDTO[]
}

export interface WeeklyPlanPatchDTO {
  name?: string
  days?: Array<{
    weekday: PlanWeekday
    hasNets?: boolean
    hasSkillWork?: boolean
    hasGym?: boolean
    hasConditioning?: boolean
    hasMatch?: boolean
    hasRecovery?: boolean
    hasProperDiet?: boolean
    netsMinutes?: number
    drillsMinutes?: number
    fitnessMinutes?: number
    recoveryMinutes?: number
    sleepTargetHours?: number
    hydrationTargetLiters?: number
  }>
}

type WeeklyPlanResponseDay = {
  weekday: PlanWeekday
  hasNets: boolean
  hasSkillWork: boolean
  hasGym: boolean
  hasConditioning: boolean
  hasMatch: boolean
  hasRecovery: boolean
  hasProperDiet: boolean
  sleepTargetHours: number
  hydrationTargetLiters: number
  netsMinutes: number
  drillsMinutes: number
  fitnessMinutes: number
  recoveryMinutes: number
}

type PlanWithRelations = NonNullable<Awaited<ReturnType<ElitePlanService['getPlanWithRelations']>>>

const WEEKDAY_ORDER: PlanWeekday[] = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
const DEFAULT_SLEEP_TARGET = 8
const DEFAULT_HYDRATION_TARGET = 3.5

const LEGACY_ACTIVITY_DEFAULTS: Record<PerformanceSessionType, Partial<WeeklyPlanResponseDay>> = {
  NETS: { hasNets: true, netsMinutes: 90 },
  SKILL_WORK: { hasSkillWork: true, drillsMinutes: 45 },
  CONDITIONING: { hasConditioning: true, fitnessMinutes: 60 },
  GYM: { hasGym: true, fitnessMinutes: 60 },
  MATCH: { hasMatch: true },
  RECOVERY: { hasRecovery: true, recoveryMinutes: 30 },
}

export class ElitePlanService {
  async getMyPlan(playerId: string) {
    try {
      const plan = await this.getPlanWithRelations(playerId)
      if (!plan || !plan.isActive) return null

      return {
        plan: {
          id: plan.id,
          name: plan.name,
          isActive: plan.isActive,
          dailyCalorieTarget: plan.dailyCalorieTarget,
          isAlignedWithAmbition: plan.isAlignedWithAmbition,
          lastSyncedAt: plan.lastSyncedAt,
          days: this.resolvePlanDays(plan),
        },
      }
    } catch (error: any) {
      console.error(`[ElitePlanService] Error fetching plan for ${playerId}:`, error.message)
      throw error
    }
  }

  async savePlan(playerId: string, data: WeeklyPlanDTO) {
    if (!data.name?.trim()) {
      throw new AppError('VALIDATION_ERROR', 'Plan name is required')
    }
    if (!Array.isArray(data.days) || data.days.length === 0) {
      throw new AppError('VALIDATION_ERROR', 'At least one weekday entry is required')
    }

    const normalizedDays = this.normalizeDaysForReplace(data.days)
    const averages = this.computePlanLevelAverages(normalizedDays)

    try {
      await prisma.$transaction(async (tx) => {
        const plan = await tx.performancePlan.upsert({
          where: { playerId },
          update: {
            name: data.name.trim(),
            isActive: true,
            sleepTargetHours: averages.sleepTargetHours,
            hydrationTargetLiters: averages.hydrationTargetLiters,
          },
          create: {
            playerId,
            name: data.name.trim(),
            isActive: true,
            sleepTargetHours: averages.sleepTargetHours,
            hydrationTargetLiters: averages.hydrationTargetLiters,
          },
        })

        await tx.performancePlanDay.deleteMany({
          where: { planId: plan.id },
        })
        await tx.performancePlanDay.createMany({
          data: normalizedDays.map((day) => ({
            planId: plan.id,
            weekday: day.weekday,
            hasNets: day.hasNets,
            hasSkillWork: day.hasSkillWork,
            hasGym: day.hasGym,
            hasConditioning: day.hasConditioning,
            hasMatch: day.hasMatch,
            hasRecovery: day.hasRecovery,
            hasProperDiet: day.hasProperDiet,
            netsMinutes: day.netsMinutes,
            drillsMinutes: day.drillsMinutes,
            fitnessMinutes: day.fitnessMinutes,
            recoveryMinutes: day.recoveryMinutes,
            sleepTargetHours: day.sleepTargetHours,
            hydrationTargetLiters: day.hydrationTargetLiters,
          })),
        })

        await tx.performancePlanActivity.deleteMany({
          where: { planId: plan.id },
        })
      })

      return this.getMyPlan(playerId)
    } catch (error: any) {
      console.error(`[ElitePlanService] DB Error saving plan for ${playerId}:`, {
        code: error.code,
        message: error.message,
      })
      throw new AppError('INTERNAL_ERROR', `Failed to save plan: ${error.message}`)
    }
  }

  async patchPlan(playerId: string, data: WeeklyPlanPatchDTO) {
    if (!data.name && !data.days?.length) {
      throw new AppError('VALIDATION_ERROR', 'Provide at least one field to update')
    }

    const existingPlan = await this.getPlanWithRelations(playerId)
    if (!existingPlan) {
      throw new AppError('NOT_FOUND', 'No plan exists for this player', 404)
    }

    if (data.name !== undefined && !data.name.trim()) {
      throw new AppError('VALIDATION_ERROR', 'Plan name cannot be empty')
    }

    const currentDays = this.resolvePlanDays(existingPlan)
    const mergedDays = data.days?.length
      ? this.mergeDayUpdates(currentDays, data.days)
      : currentDays
    const averages = this.computePlanLevelAverages(mergedDays)

    try {
      await prisma.$transaction(async (tx) => {
        await tx.performancePlan.update({
          where: { id: existingPlan.id },
          data: {
            name: data.name?.trim() ?? existingPlan.name,
            isActive: true,
            sleepTargetHours: averages.sleepTargetHours,
            hydrationTargetLiters: averages.hydrationTargetLiters,
          },
        })

        await tx.performancePlanDay.deleteMany({
          where: { planId: existingPlan.id },
        })
        await tx.performancePlanDay.createMany({
          data: mergedDays.map((day) => ({
            planId: existingPlan.id,
            weekday: day.weekday,
            hasNets: day.hasNets,
            hasSkillWork: day.hasSkillWork,
            hasGym: day.hasGym,
            hasConditioning: day.hasConditioning,
            hasMatch: day.hasMatch,
            hasRecovery: day.hasRecovery,
            hasProperDiet: day.hasProperDiet,
            netsMinutes: day.netsMinutes,
            drillsMinutes: day.drillsMinutes,
            fitnessMinutes: day.fitnessMinutes,
            recoveryMinutes: day.recoveryMinutes,
            sleepTargetHours: day.sleepTargetHours,
            hydrationTargetLiters: day.hydrationTargetLiters,
          })),
        })

        await tx.performancePlanActivity.deleteMany({
          where: { planId: existingPlan.id },
        })
      })

      return this.getMyPlan(playerId)
    } catch (error: any) {
      console.error(`[ElitePlanService] DB Error patching plan for ${playerId}:`, {
        code: error.code,
        message: error.message,
      })
      throw new AppError('INTERNAL_ERROR', `Failed to patch plan: ${error.message}`)
    }
  }

  async calculateDisciplineScore(playerId: string) {
    try {
      const planData = await this.getMyPlan(playerId)
      const weeklyPlan = planData?.plan
      if (!weeklyPlan || weeklyPlan.days.length === 0) return { score: 0, adherence: {} }

      const now = new Date()
      const day = now.getDay()
      const diff = now.getDate() - day + (day === 0 ? -6 : 1)
      const monday = new Date(now.setDate(diff))
      monday.setHours(0, 0, 0, 0)

      const entries = await prisma.playerWorkloadEvent.findMany({
        where: {
          playerId,
          date: { gte: monday },
          isCheatDay: false,
          source: 'ELITE_JOURNAL',
        },
        select: { type: true },
      })

      const currentWeekday = this.toWeekday(new Date())
      const todayIndex = WEEKDAY_ORDER.indexOf(currentWeekday)
      const activeDays = weeklyPlan.days.filter((dayPlan) => WEEKDAY_ORDER.indexOf(dayPlan.weekday) <= todayIndex)

      const plannedByBucket = {
        NETS: activeDays.filter((dayPlan) => dayPlan.hasNets || dayPlan.netsMinutes > 0).length,
        SKILL_WORK: activeDays.filter((dayPlan) => dayPlan.hasSkillWork || dayPlan.drillsMinutes > 0).length,
        FITNESS: activeDays.filter((dayPlan) => dayPlan.hasGym || dayPlan.hasConditioning || dayPlan.fitnessMinutes > 0).length,
        RECOVERY: activeDays.filter((dayPlan) => dayPlan.hasRecovery || dayPlan.recoveryMinutes > 0).length,
      }

      const actualByBucket = {
        NETS: entries.filter((entry) => entry.type === 'NETS').length,
        SKILL_WORK: entries.filter((entry) => entry.type === 'SKILL_WORK').length,
        FITNESS: entries.filter((entry) => entry.type === 'GYM' || entry.type === 'CONDITIONING').length,
        RECOVERY: entries.filter((entry) => entry.type === 'RECOVERY').length,
      }

      const adherence: Record<string, { planned: number; actual: number }> = {}
      let plannedBucketCount = 0
      let totalAdherencePct = 0
      for (const bucket of Object.keys(plannedByBucket) as Array<keyof typeof plannedByBucket>) {
        const planned = plannedByBucket[bucket]
        if (planned <= 0) continue

        const actual = actualByBucket[bucket]
        const pct = Math.min(1, actual / planned)

        plannedBucketCount += 1
        totalAdherencePct += pct
        adherence[bucket] = { planned, actual }
      }

      return {
        score: plannedBucketCount > 0
          ? Number(((totalAdherencePct / plannedBucketCount) * 100).toFixed(1))
          : 0,
        adherence,
      }
    } catch (error: any) {
      console.error(`[ElitePlanService] Error calculating discipline for ${playerId}:`, error.message)
      return { score: 0, adherence: {} }
    }
  }

  /**
   * Smart Sync: Reconciles the weekly plan with the long-term ambition.
   * Updates foundational targets (calories, sleep, hydration) and checks for schedule alignment.
   */
  async reconcilePlanWithAmbition(playerId: string) {
    const [ambition, plan] = await Promise.all([
      prisma.performanceAmbition.findUnique({ where: { playerId } }),
      prisma.performancePlan.findUnique({
        where: { playerId },
        include: { days: true },
      }),
    ])

    if (!ambition) return null

    // 1. If no plan exists, generate a basic default plan based on ambition
    if (!plan) {
      return this.generateDefaultPlanFromAmbition(playerId, ambition)
    }

    // 2. Update Foundational Sync fields (Name, Calories, Sleep, Hydration)
    const updateData: any = {
      name: `Strategic Plan: ${ambition.targetRole} (${ambition.targetLevel})`,
      dailyCalorieTarget: ambition.dailyCalorieTarget,
      sleepTargetHours: ambition.dailySleepHoursGoal ?? plan.sleepTargetHours,
      hydrationTargetLiters: ambition.dailyHydrationLitresGoal ?? plan.hydrationTargetLiters,
      lastSyncedAt: new Date(),
    }

    // 3. Check for Schedule Alignment (Drift Detection)
    // We check if the number of active training days in the plan matches trainingDaysPerWeek in ambition
    const activeDaysCount = plan.days.filter((d) =>
      d.hasNets || d.hasSkillWork || d.hasGym || d.hasConditioning || d.hasMatch,
    ).length

    const isAligned = activeDaysCount === ambition.trainingDaysPerWeek
    updateData.isAlignedWithAmbition = isAligned

    await prisma.performancePlan.update({
      where: { id: plan.id },
      data: updateData,
    })

    return { planId: plan.id, isAligned }
  }

  private async generateDefaultPlanFromAmbition(playerId: string, ambition: any) {
    const trainingDays = ambition.trainingDaysPerWeek || 3
    const sleepTarget = ambition.dailySleepHoursGoal || DEFAULT_SLEEP_TARGET
    const hydrationTarget = ambition.dailyHydrationLitresGoal || DEFAULT_HYDRATION_TARGET

    // Simple distribution: Start from Monday and pick N days
    const activeWeekdays = WEEKDAY_ORDER.slice(0, trainingDays)

    const daysData = WEEKDAY_ORDER.map((weekday) => {
      const isActive = activeWeekdays.includes(weekday)
      return {
        weekday,
        hasNets: isActive,
        netsMinutes: isActive ? 90 : 0,
        hasSkillWork: isActive,
        drillsMinutes: isActive ? 45 : 0,
        hasGym: isActive,
        fitnessMinutes: isActive ? 60 : 0,
        sleepTargetHours: sleepTarget,
        hydrationTargetLiters: hydrationTarget,
      }
    })

    return this.savePlan(playerId, {
      name: `Plan based on ${ambition.targetRole} Ambition`,
      days: daysData,
    })
  }

  private async getPlanWithRelations(playerId: string) {
    return prisma.performancePlan.findUnique({
      where: { playerId },
      include: {
        days: true,
        activities: true,
      },
    })
  }

  private resolvePlanDays(plan: PlanWithRelations): WeeklyPlanResponseDay[] {
    const baseMap = new Map<PlanWeekday, WeeklyPlanResponseDay>(
      WEEKDAY_ORDER.map((weekday) => [weekday, this.emptyDay(weekday, plan.sleepTargetHours, plan.hydrationTargetLiters)]),
    )

    if (plan.days.length > 0) {
      for (const day of plan.days) {
        baseMap.set(day.weekday, {
          weekday: day.weekday,
          hasNets: day.hasNets || day.netsMinutes > 0,
          hasSkillWork: day.hasSkillWork || day.drillsMinutes > 0,
          hasGym: day.hasGym || day.fitnessMinutes > 0,
          hasConditioning: day.hasConditioning,
          hasMatch: day.hasMatch,
          hasRecovery: day.hasRecovery || day.recoveryMinutes > 0,
          hasProperDiet: day.hasProperDiet,
          netsMinutes: day.netsMinutes,
          drillsMinutes: day.drillsMinutes,
          fitnessMinutes: day.fitnessMinutes,
          recoveryMinutes: day.recoveryMinutes,
          sleepTargetHours: Number(day.sleepTargetHours),
          hydrationTargetLiters: Number(day.hydrationTargetLiters),
        })
      }

      const hasAnyExplicitTargets = WEEKDAY_ORDER
        .map((weekday) => baseMap.get(weekday)!)
        .some((day) =>
          day.hasNets ||
          day.hasSkillWork ||
          day.hasGym ||
          day.hasConditioning ||
          day.hasMatch ||
          day.hasRecovery ||
          day.hasProperDiet ||
          day.netsMinutes > 0 ||
          day.drillsMinutes > 0 ||
          day.fitnessMinutes > 0 ||
          day.recoveryMinutes > 0,
        )

      if (hasAnyExplicitTargets || plan.activities.length === 0) {
        return WEEKDAY_ORDER.map((weekday) => baseMap.get(weekday)!)
      }
    }

    for (const activity of plan.activities) {
      const times = Math.max(0, Math.min(7, activity.timesPerWeek))
      const template = LEGACY_ACTIVITY_DEFAULTS[activity.category]
      for (let idx = 0; idx < times; idx += 1) {
        const weekday = WEEKDAY_ORDER[idx]
        const day = baseMap.get(weekday)!
        day.hasNets = day.hasNets || Boolean(template.hasNets)
        day.hasSkillWork = day.hasSkillWork || Boolean(template.hasSkillWork)
        day.hasGym = day.hasGym || Boolean(template.hasGym)
        day.hasConditioning = day.hasConditioning || Boolean(template.hasConditioning)
        day.hasMatch = day.hasMatch || Boolean(template.hasMatch)
        day.hasRecovery = day.hasRecovery || Boolean(template.hasRecovery)
        day.netsMinutes += template.netsMinutes ?? 0
        day.drillsMinutes += template.drillsMinutes ?? 0
        day.fitnessMinutes += template.fitnessMinutes ?? 0
        day.recoveryMinutes += template.recoveryMinutes ?? 0
      }
    }

    return WEEKDAY_ORDER.map((weekday) => baseMap.get(weekday)!)
  }

  private normalizeDaysForReplace(days: WeeklyPlanDayDTO[]) {
    this.assertUniqueWeekdays(days.map((day) => day.weekday))

    const map = new Map<PlanWeekday, WeeklyPlanResponseDay>(
      WEEKDAY_ORDER.map((weekday) => [weekday, this.emptyDay(weekday)]),
    )

    for (const day of days) {
      const normalized = this.normalizeDay(day)
      map.set(day.weekday, normalized)
    }

    return WEEKDAY_ORDER.map((weekday) => map.get(weekday)!)
  }

  private mergeDayUpdates(existingDays: WeeklyPlanResponseDay[], updates: NonNullable<WeeklyPlanPatchDTO['days']>) {
    this.assertUniqueWeekdays(updates.map((day) => day.weekday))

    const map = new Map<PlanWeekday, WeeklyPlanResponseDay>(
      existingDays.map((day) => [day.weekday, { ...day }]),
    )

    for (const update of updates) {
      const current = map.get(update.weekday) ?? this.emptyDay(update.weekday)
      const merged = this.normalizeDay({
        ...current,
        ...update,
        weekday: update.weekday,
      })
      map.set(update.weekday, merged)
    }

    return WEEKDAY_ORDER.map((weekday) => map.get(weekday) ?? this.emptyDay(weekday))
  }

  private normalizeDay(day: WeeklyPlanDayDTO): WeeklyPlanResponseDay {
    const netsMinutes = this.toNonNegativeInt(day.netsMinutes ?? 0, 'netsMinutes')
    const drillsMinutes = this.toNonNegativeInt(day.drillsMinutes ?? 0, 'drillsMinutes')
    const fitnessMinutes = this.toNonNegativeInt(day.fitnessMinutes ?? 0, 'fitnessMinutes')
    const recoveryMinutes = this.toNonNegativeInt(day.recoveryMinutes ?? 0, 'recoveryMinutes')

    return {
      weekday: day.weekday,
      hasNets: day.hasNets ?? netsMinutes > 0,
      hasSkillWork: day.hasSkillWork ?? drillsMinutes > 0,
      hasGym: day.hasGym ?? fitnessMinutes > 0,
      hasConditioning: day.hasConditioning ?? false,
      hasMatch: day.hasMatch ?? false,
      hasRecovery: day.hasRecovery ?? recoveryMinutes > 0,
      hasProperDiet: day.hasProperDiet ?? false,
      netsMinutes,
      drillsMinutes,
      fitnessMinutes,
      recoveryMinutes,
      sleepTargetHours: this.toBoundedFloat(day.sleepTargetHours ?? DEFAULT_SLEEP_TARGET, 0, 24, 'sleepTargetHours'),
      hydrationTargetLiters: this.toBoundedFloat(day.hydrationTargetLiters ?? DEFAULT_HYDRATION_TARGET, 0, 15, 'hydrationTargetLiters'),
    }
  }

  private emptyDay(
    weekday: PlanWeekday,
    sleepTargetHours = DEFAULT_SLEEP_TARGET,
    hydrationTargetLiters = DEFAULT_HYDRATION_TARGET,
  ): WeeklyPlanResponseDay {
    return {
      weekday,
      hasNets: false,
      hasSkillWork: false,
      hasGym: false,
      hasConditioning: false,
      hasMatch: false,
      hasRecovery: false,
      hasProperDiet: false,
      netsMinutes: 0,
      drillsMinutes: 0,
      fitnessMinutes: 0,
      recoveryMinutes: 0,
      sleepTargetHours: Number(sleepTargetHours),
      hydrationTargetLiters: Number(hydrationTargetLiters),
    }
  }

  private assertUniqueWeekdays(weekdays: PlanWeekday[]) {
    const seen = new Set<PlanWeekday>()
    for (const weekday of weekdays) {
      if (seen.has(weekday)) {
        throw new AppError('VALIDATION_ERROR', `Duplicate weekday entry: ${weekday}`)
      }
      seen.add(weekday)
    }
  }

  private toNonNegativeInt(value: number, field: string) {
    if (!Number.isFinite(value)) {
      throw new AppError('VALIDATION_ERROR', `${field} must be a valid number`)
    }
    if (value < 0) {
      throw new AppError('VALIDATION_ERROR', `${field} must be non-negative`)
    }
    return Math.floor(value)
  }

  private toBoundedFloat(value: number, min: number, max: number, field: string) {
    if (!Number.isFinite(value)) {
      throw new AppError('VALIDATION_ERROR', `${field} must be a valid number`)
    }
    if (value < min || value > max) {
      throw new AppError('VALIDATION_ERROR', `${field} must be between ${min} and ${max}`)
    }
    return Number(value.toFixed(2))
  }

  private computePlanLevelAverages(days: WeeklyPlanResponseDay[]) {
    if (days.length === 0) {
      return { sleepTargetHours: DEFAULT_SLEEP_TARGET, hydrationTargetLiters: DEFAULT_HYDRATION_TARGET }
    }

    const sumSleep = days.reduce((sum, day) => sum + day.sleepTargetHours, 0)
    const sumHydration = days.reduce((sum, day) => sum + day.hydrationTargetLiters, 0)

    return {
      sleepTargetHours: Number((sumSleep / days.length).toFixed(2)),
      hydrationTargetLiters: Number((sumHydration / days.length).toFixed(2)),
    }
  }

  private toWeekday(date: Date): PlanWeekday {
    const day = date.getDay()
    const byJsDay: Record<number, PlanWeekday> = {
      0: 'SUN',
      1: 'MON',
      2: 'TUE',
      3: 'WED',
      4: 'THU',
      5: 'FRI',
      6: 'SAT',
    }
    return byJsDay[day]
  }
}
