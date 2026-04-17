import { prisma } from '@swing/db'
import {
  PerformanceActivityDomain,
  PerformanceDayActivityType,
  PlanWeekday,
  Prisma,
} from '@prisma/client'
import { AppError } from '../../lib/errors'

const JS_DAY_TO_WEEKDAY: Record<number, PlanWeekday> = {
  0: 'SUN',
  1: 'MON',
  2: 'TUE',
  3: 'WED',
  4: 'THU',
  5: 'FRI',
  6: 'SAT',
}

const ACTIVITY_ORDER: PerformanceDayActivityType[] = [
  'NETS',
  'SKILL_WORK',
  'GYM',
  'CONDITIONING',
  'MATCH',
  'RECOVERY',
  'PROPER_DIET',
]

const DAY_LOG_INCLUDE = {
  activities: {
    include: {
      details: true,
    },
  },
} as const

type DayLogWithRelations = Prisma.PerformanceDayLogGetPayload<{ include: typeof DAY_LOG_INCLUDE }>

type DayPlanState = {
  activities: Record<PerformanceDayActivityType, boolean>
  sleepTargetHours: number
  hydrationTargetLiters: number
  legacyTargets: {
    netsMinutes: number
    drillsMinutes: number
    fitnessMinutes: number
    recoveryMinutes: number
  }
}

type ActivityDetailInput = {
  domain: PerformanceActivityDomain
  primaryFocus?: string | null
  secondaryFocuses?: string[]
  whatLearned?: string | null
  whatMissed?: string | null
  notes?: string | null
  metadata?: Record<string, unknown> | null
}

export type PatchDayPlanInput = {
  oneThingToday?: string | null
  cheatDay?: boolean
}

export type SubmitExecutionInput = {
  activities?: Array<{
    activityType: PerformanceDayActivityType
    wasCompleted: boolean
    details?: ActivityDetailInput | null
  }>
  sleepHours: number | null
  hydrationLiters: number | null
  tookProperDiet: boolean | null
  skippedMeal: boolean | null
  whatDidWell: string
  whatDidBadly: string
  note?: string | null
  cheatDay?: boolean
}

export type ExecuteSummaryRange = '7d' | '30d' | 'month' | 'all'

export class PerformanceLogService {
  async getExecuteSummary(playerId: string, range: ExecuteSummaryRange = '30d') {
    const { startDate, endDate } = this.resolveSummaryRange(range)
    const where: Prisma.PerformanceDayLogWhereInput = { playerId }
    if (startDate) {
      where.date = { gte: startDate, lte: endDate }
    }

    const logs = await prisma.performanceDayLog.findMany({
      where,
      orderBy: { date: 'asc' },
      select: {
        id: true,
        date: true,
        isLocked: true,
        cheatDay: true,
        executionScore: true,
        skippedMeal: true,
        sleepHours: true,
        hydrationLiters: true,
        targetSleep: true,
        targetHydration: true,
        activities: {
          select: {
            activityType: true,
            wasPlanned: true,
            wasCompleted: true,
          },
        },
      },
    })

    const submitted = logs.filter((log) => log.isLocked)

    const avgScores = submitted
      .map((log) => log.executionScore)
      .filter((value): value is number => typeof value === 'number')
    const averageExecutionScore = avgScores.length > 0
      ? Number((avgScores.reduce((sum, score) => sum + score, 0) / avgScores.length).toFixed(1))
      : 0

    const doneCounts = new Map<PerformanceDayActivityType, number>()
    const skippedCounts = new Map<PerformanceDayActivityType, number>()
    for (const activityType of ACTIVITY_ORDER) {
      doneCounts.set(activityType, 0)
      skippedCounts.set(activityType, 0)
    }

    for (const log of submitted) {
      for (const activity of log.activities) {
        if (activity.wasCompleted) {
          doneCounts.set(activity.activityType, (doneCounts.get(activity.activityType) ?? 0) + 1)
        }
        if (activity.wasPlanned && !activity.wasCompleted) {
          skippedCounts.set(activity.activityType, (skippedCounts.get(activity.activityType) ?? 0) + 1)
        }
      }
    }

    const mostDoneActivity = this.findTopActivity(doneCounts)
    const mostSkippedActivity = this.findTopActivity(skippedCounts)
    const mealSkippedDays = submitted.filter((log) => log.skippedMeal === true).length

    const sleepMissRows = submitted
      .filter((log) => (log.targetSleep ?? 0) > 0)
      .map((log) => {
        const target = log.targetSleep ?? 0
        const actual = log.sleepHours ?? 0
        return {
          date: this.toDateKey(log.date),
          sleepHours: log.sleepHours ?? null,
          targetSleepHours: target,
          missByHours: Number(Math.max(0, target - actual).toFixed(2)),
          actualForSort: actual,
        }
      })

    const sleepMissDays = sleepMissRows.filter((row) => row.missByHours > 0).length
    const leastSleepDays = [...sleepMissRows]
      .sort((a, b) => a.actualForSort - b.actualForSort || a.date.localeCompare(b.date))
      .slice(0, 5)
      .map((row) => ({
        date: row.date,
        sleepHours: row.sleepHours,
        targetSleepHours: row.targetSleepHours,
        missByHours: row.missByHours,
      }))

    const hydrationMissRows = submitted
      .filter((log) => (log.targetHydration ?? 0) > 0)
      .map((log) => {
        const target = log.targetHydration ?? 0
        const actual = log.hydrationLiters ?? 0
        return {
          date: this.toDateKey(log.date),
          hydrationLiters: log.hydrationLiters ?? null,
          targetHydrationLiters: target,
          missByLiters: Number(Math.max(0, target - actual).toFixed(2)),
        }
      })

    const hydrationMissDays = hydrationMissRows.filter((row) => row.missByLiters > 0).length
    const worstHydrationDays = [...hydrationMissRows]
      .filter((row) => row.missByLiters > 0)
      .sort((a, b) => b.missByLiters - a.missByLiters || a.date.localeCompare(b.date))
      .slice(0, 5)

    const { currentStreak, bestStreak } = this.computeExecuteStreaks(submitted)

    return {
      range,
      averageExecutionScore,
      mostDoneActivity,
      mostSkippedActivity,
      mealSkippedDays,
      sleepMissDays,
      hydrationMissDays,
      worstHydrationDays,
      leastSleepDays,
      currentStreak,
      bestStreak,
    }
  }

  async getDayLog(playerId: string, dateInput: string) {
    const date = this.parseDateInput(dateInput)
    const log = await this.getOrCreateDayLog(playerId, date)
    return { dayLog: this.toResponse(log) }
  }

  async patchDayPlan(playerId: string, dateInput: string, input: PatchDayPlanInput) {
    const date = this.parseDateInput(dateInput)
    const log = await this.getOrCreateDayLog(playerId, date)
    if (log.isLocked) {
      throw new AppError('DAY_LOCKED', 'Day is locked and cannot be edited', 409)
    }

    const data: Prisma.PerformanceDayLogUpdateInput = {}
    if (input.oneThingToday !== undefined) {
      const value = input.oneThingToday?.trim() ?? null
      data.oneThingToday = value && value.length > 0 ? value : null
    }
    if (input.cheatDay !== undefined) {
      data.cheatDay = input.cheatDay
    }

    if (Object.keys(data).length === 0) {
      throw new AppError('VALIDATION_ERROR', 'At least one editable day field is required')
    }

    await prisma.performanceDayLog.update({
      where: { id: log.id },
      data,
    })

    const updated = await prisma.performanceDayLog.findUnique({
      where: { id: log.id },
      include: DAY_LOG_INCLUDE,
    })
    if (!updated) throw new AppError('NOT_FOUND', 'Day log not found', 404)
    return { dayLog: this.toResponse(updated) }
  }

  async submitExecution(playerId: string, dateInput: string, input: SubmitExecutionInput) {
    const date = this.parseDateInput(dateInput)
    const log = await this.getOrCreateDayLog(playerId, date)
    if (log.isLocked) {
      throw new AppError('DAY_LOCKED', 'Day is already locked', 409)
    }

    const submissionMap = this.toSubmissionMap(input.activities ?? [])
    const cheatDay = input.cheatDay ?? log.cheatDay

    const activitiesByType = new Map(log.activities.map((activity) => [activity.activityType, activity]))
    const completionByType = new Map<PerformanceDayActivityType, boolean>()

    for (const activityType of ACTIVITY_ORDER) {
      const activity = activitiesByType.get(activityType)
      if (!activity) continue

      const submitted = submissionMap.get(activityType)
      let wasCompleted = submitted?.wasCompleted ?? false

      if (activityType === 'PROPER_DIET' && activity.wasPlanned) {
        wasCompleted = input.tookProperDiet === true && input.skippedMeal !== true
      }
      if (cheatDay) {
        wasCompleted = false
      }

      completionByType.set(activityType, wasCompleted)
    }

    const executionScore = this.calculateExecutionScore(log, completionByType, {
      sleepHours: input.sleepHours,
      hydrationLiters: input.hydrationLiters,
      cheatDay,
    })

    await prisma.$transaction(async (tx) => {
      await tx.performanceDayLog.update({
        where: { id: log.id },
        data: {
          cheatDay,
          sleepHours: input.sleepHours,
          hydrationLiters: input.hydrationLiters,
          tookProperDiet: input.tookProperDiet,
          skippedMeal: input.skippedMeal,
          whatDidWell: input.whatDidWell.trim(),
          whatDidBadly: input.whatDidBadly.trim(),
          note: input.note?.trim() || null,
          dayTakeaway: input.note?.trim() || null,
          executionScore,
          isLocked: true,
        },
      })

      for (const activityType of ACTIVITY_ORDER) {
        const activity = activitiesByType.get(activityType)
        if (!activity) continue

        await tx.performanceDayActivity.update({
          where: { id: activity.id },
          data: { wasCompleted: completionByType.get(activityType) ?? false },
        })

        const submitted = submissionMap.get(activityType)
        if (!submitted) continue

        await tx.performanceDayActivityDetail.deleteMany({
          where: { activityId: activity.id },
        })

        if (!submitted.details || cheatDay) continue
        const metadata = submitted.details.metadata === null
          ? Prisma.JsonNull
          : (submitted.details.metadata as Prisma.InputJsonValue | undefined)
        await tx.performanceDayActivityDetail.create({
          data: {
            activityId: activity.id,
            domain: submitted.details.domain,
            primaryFocus: submitted.details.primaryFocus?.trim() || null,
            secondaryFocuses: submitted.details.secondaryFocuses ?? [],
            whatLearned: submitted.details.whatLearned?.trim() || null,
            whatMissed: submitted.details.whatMissed?.trim() || null,
            notes: submitted.details.notes?.trim() || null,
            metadata,
          },
        })
      }
    })

    const updated = await prisma.performanceDayLog.findUnique({
      where: { id: log.id },
      include: DAY_LOG_INCLUDE,
    })
    if (!updated) throw new AppError('NOT_FOUND', 'Day log not found', 404)
    return { dayLog: this.toResponse(updated) }
  }

  private async getOrCreateDayLog(playerId: string, date: Date) {
    let log = await prisma.performanceDayLog.findUnique({
      where: { playerId_date: { playerId, date } },
      include: DAY_LOG_INCLUDE,
    })

    if (!log) {
      const inherited = await this.resolveInheritedPlan(playerId, date)
      const created = await prisma.performanceDayLog.create({
        data: {
          playerId,
          date,
          type: 'TRAINING',
          targetNetsMinutes: inherited.legacyTargets.netsMinutes,
          targetDrillsMinutes: inherited.legacyTargets.drillsMinutes,
          targetGymMinutes: inherited.legacyTargets.fitnessMinutes,
          targetRecoveryMinutes: inherited.legacyTargets.recoveryMinutes,
          targetSleep: inherited.sleepTargetHours,
          targetHydration: inherited.hydrationTargetLiters,
        },
      })

      await this.ensureActivityRows(created.id, inherited.activities)
      log = await prisma.performanceDayLog.findUnique({
        where: { id: created.id },
        include: DAY_LOG_INCLUDE,
      })
      if (!log) throw new AppError('NOT_FOUND', 'Day log not found', 404)
      return log
    }

    if (log.activities.length < ACTIVITY_ORDER.length) {
      const plannedForBackfill = log.activities.length === 0
        ? this.derivePlanFromLegacyTargets(log)
        : this.currentPlanFromActivities(log.activities)
      await this.ensureActivityRows(log.id, plannedForBackfill)
      log = await prisma.performanceDayLog.findUnique({
        where: { id: log.id },
        include: DAY_LOG_INCLUDE,
      })
      if (!log) throw new AppError('NOT_FOUND', 'Day log not found', 404)
    }

    return log
  }

  private async ensureActivityRows(dayLogId: string, planned: Record<PerformanceDayActivityType, boolean>) {
    await prisma.$transaction(
      ACTIVITY_ORDER.map((activityType) =>
        prisma.performanceDayActivity.upsert({
          where: { dayLogId_activityType: { dayLogId, activityType } },
          update: {},
          create: {
            dayLogId,
            activityType,
            wasPlanned: planned[activityType] ?? false,
          },
        }),
      ),
    )
  }

  private async resolveInheritedPlan(playerId: string, date: Date): Promise<DayPlanState> {
    const weekday = this.toWeekday(date)
    const plan = await prisma.performancePlan.findUnique({
      where: { playerId },
      include: { days: true },
    })

    if (!plan || !plan.isActive) {
      return this.emptyPlanState()
    }

    const day = plan.days.find((entry) => entry.weekday === weekday)
    if (!day) {
      return {
        ...this.emptyPlanState(),
        sleepTargetHours: Number(plan.sleepTargetHours),
        hydrationTargetLiters: Number(plan.hydrationTargetLiters),
      }
    }

    return {
      activities: {
        NETS: day.hasNets || day.netsMinutes > 0,
        SKILL_WORK: day.hasSkillWork || day.drillsMinutes > 0,
        GYM: day.hasGym || day.fitnessMinutes > 0,
        CONDITIONING: day.hasConditioning,
        MATCH: day.hasMatch,
        RECOVERY: day.hasRecovery || day.recoveryMinutes > 0,
        PROPER_DIET: day.hasProperDiet,
      },
      sleepTargetHours: Number(day.sleepTargetHours),
      hydrationTargetLiters: Number(day.hydrationTargetLiters),
      legacyTargets: {
        netsMinutes: day.netsMinutes,
        drillsMinutes: day.drillsMinutes,
        fitnessMinutes: day.fitnessMinutes,
        recoveryMinutes: day.recoveryMinutes,
      },
    }
  }

  private derivePlanFromLegacyTargets(log: Pick<
    DayLogWithRelations,
    'targetNetsMinutes' | 'targetDrillsMinutes' | 'targetGymMinutes' | 'targetRecoveryMinutes' | 'type'
  >): Record<PerformanceDayActivityType, boolean> {
    return {
      NETS: (log.targetNetsMinutes ?? 0) > 0,
      SKILL_WORK: (log.targetDrillsMinutes ?? 0) > 0,
      GYM: (log.targetGymMinutes ?? 0) > 0,
      CONDITIONING: false,
      MATCH: log.type === 'MATCH',
      RECOVERY: (log.targetRecoveryMinutes ?? 0) > 0,
      PROPER_DIET: false,
    }
  }

  private currentPlanFromActivities(
    activities: Array<{ activityType: PerformanceDayActivityType; wasPlanned: boolean }>,
  ): Record<PerformanceDayActivityType, boolean> {
    const byType = new Map(activities.map((activity) => [activity.activityType, activity.wasPlanned]))
    return {
      NETS: byType.get('NETS') ?? false,
      SKILL_WORK: byType.get('SKILL_WORK') ?? false,
      GYM: byType.get('GYM') ?? false,
      CONDITIONING: byType.get('CONDITIONING') ?? false,
      MATCH: byType.get('MATCH') ?? false,
      RECOVERY: byType.get('RECOVERY') ?? false,
      PROPER_DIET: byType.get('PROPER_DIET') ?? false,
    }
  }

  private calculateExecutionScore(
    log: Pick<DayLogWithRelations, 'activities' | 'targetSleep' | 'targetHydration'>,
    completionByType: Map<PerformanceDayActivityType, boolean>,
    input: { sleepHours: number | null; hydrationLiters: number | null; cheatDay: boolean },
  ) {
    if (input.cheatDay) return 0

    let plannedItems = 0
    let completedItems = 0

    for (const activity of log.activities) {
      if (!activity.wasPlanned) continue
      plannedItems += 1
      if (completionByType.get(activity.activityType) === true) {
        completedItems += 1
      }
    }

    const sleepTarget = log.targetSleep ?? 0
    if (sleepTarget > 0) {
      plannedItems += 1
      if ((input.sleepHours ?? 0) >= sleepTarget) completedItems += 1
    }

    const hydrationTarget = log.targetHydration ?? 0
    if (hydrationTarget > 0) {
      plannedItems += 1
      if ((input.hydrationLiters ?? 0) >= hydrationTarget) completedItems += 1
    }

    if (plannedItems === 0) return 100
    return Number(((completedItems / plannedItems) * 100).toFixed(1))
  }

  private toSubmissionMap(
    activities: NonNullable<SubmitExecutionInput['activities']> = [],
  ): Map<PerformanceDayActivityType, NonNullable<SubmitExecutionInput['activities']>[number]> {
    const map = new Map<PerformanceDayActivityType, NonNullable<SubmitExecutionInput['activities']>[number]>()
    for (const activity of activities) {
      if (map.has(activity.activityType)) {
        throw new AppError('VALIDATION_ERROR', `Duplicate activity in execution payload: ${activity.activityType}`)
      }
      map.set(activity.activityType, activity)
    }
    return map
  }

  private toResponse(log: DayLogWithRelations) {
    const weekday = this.toWeekday(log.date)
    const activitiesByType = new Map(log.activities.map((activity) => [activity.activityType, activity]))

    const planActivities = ACTIVITY_ORDER.map((activityType) => ({
      activityType,
      wasPlanned: activitiesByType.get(activityType)?.wasPlanned ?? false,
    }))

    const executionActivities = ACTIVITY_ORDER.map((activityType) => {
      const activity = activitiesByType.get(activityType)
      const detail = activity?.details[0]
      return {
        activityType,
        wasCompleted: activity?.wasCompleted ?? false,
        details: detail
          ? {
            domain: detail.domain,
            primaryFocus: detail.primaryFocus ?? null,
            secondaryFocuses: detail.secondaryFocuses ?? [],
            whatLearned: detail.whatLearned ?? null,
            whatMissed: detail.whatMissed ?? null,
            notes: detail.notes ?? null,
            metadata: detail.metadata ?? null,
          }
          : null,
      }
    })

    const executionHasSignal = Boolean(
      log.isLocked ||
      log.cheatDay ||
      log.executionScore !== null ||
      log.actualNetsMinutes > 0 ||
      log.actualDrillsMinutes > 0 ||
      log.actualFitnessMinutes > 0 ||
      log.actualRecoveryMinutes > 0 ||
      log.sleepHours !== null ||
      log.hydrationLiters !== null ||
      executionActivities.some((activity) => activity.wasCompleted || activity.details !== null),
    )

    const execution = executionHasSignal
      ? {
        activities: executionActivities,
        netsMinutes: log.actualNetsMinutes ?? 0,
        drillsMinutes: log.actualDrillsMinutes ?? 0,
        fitnessMinutes: log.actualFitnessMinutes ?? 0,
        recoveryMinutes: log.actualRecoveryMinutes ?? 0,
        sleepHours: log.sleepHours ?? null,
        hydrationLiters: log.hydrationLiters ?? null,
        tookProperDiet: log.tookProperDiet ?? null,
        skippedMeal: log.skippedMeal ?? null,
        whatDidWell: log.whatDidWell ?? null,
        whatDidBadly: log.whatDidBadly ?? null,
        note: log.note ?? log.dayTakeaway ?? null,
      }
      : null

    return {
      id: log.id,
      playerId: log.playerId,
      date: this.toDateKey(log.date),
      weekday,
      isLocked: log.isLocked,
      cheatDay: log.cheatDay,
      oneThingToday: log.oneThingToday ?? null,
      plan: {
        netsMinutes: log.targetNetsMinutes ?? 0,
        drillsMinutes: log.targetDrillsMinutes ?? 0,
        fitnessMinutes: log.targetGymMinutes ?? 0,
        recoveryMinutes: log.targetRecoveryMinutes ?? 0,
        gymMinutes: log.targetGymMinutes ?? 0,
        activities: planActivities,
        sleepTargetHours: log.targetSleep ?? 0,
        hydrationTargetLiters: log.targetHydration ?? 0,
      },
      execution,
      executionScore: log.executionScore ?? null,
      createdAt: log.createdAt,
      updatedAt: log.updatedAt,
    }
  }

  private parseDateInput(dateInput: string): Date {
    if (!/^\d{4}-\d{2}-\d{2}$/.test(dateInput)) {
      throw new AppError('VALIDATION_ERROR', 'Date must be in YYYY-MM-DD format')
    }

    const [yearRaw, monthRaw, dayRaw] = dateInput.split('-')
    const year = Number(yearRaw)
    const month = Number(monthRaw)
    const day = Number(dayRaw)
    const parsed = new Date(Date.UTC(year, month - 1, day))

    if (
      parsed.getUTCFullYear() !== year ||
      parsed.getUTCMonth() !== month - 1 ||
      parsed.getUTCDate() !== day
    ) {
      throw new AppError('VALIDATION_ERROR', 'Invalid calendar date')
    }

    return parsed
  }

  private toWeekday(date: Date): PlanWeekday {
    return JS_DAY_TO_WEEKDAY[date.getUTCDay()]
  }

  private toDateKey(date: Date) {
    const copy = new Date(date)
    copy.setUTCHours(0, 0, 0, 0)
    return copy.toISOString().slice(0, 10)
  }

  private emptyPlanState(): DayPlanState {
    return {
      activities: {
        NETS: false,
        SKILL_WORK: false,
        GYM: false,
        CONDITIONING: false,
        MATCH: false,
        RECOVERY: false,
        PROPER_DIET: false,
      },
      sleepTargetHours: 0,
      hydrationTargetLiters: 0,
      legacyTargets: {
        netsMinutes: 0,
        drillsMinutes: 0,
        fitnessMinutes: 0,
        recoveryMinutes: 0,
      },
    }
  }

  private resolveSummaryRange(range: ExecuteSummaryRange) {
    const today = this.startOfUtcDay(new Date())
    if (range === 'all') return { startDate: null as Date | null, endDate: today }
    if (range === 'month') {
      const monthStart = new Date(Date.UTC(today.getUTCFullYear(), today.getUTCMonth(), 1))
      return { startDate: monthStart, endDate: today }
    }
    if (range === '7d') {
      return { startDate: this.addUtcDays(today, -6), endDate: today }
    }
    return { startDate: this.addUtcDays(today, -29), endDate: today }
  }

  private findTopActivity(counter: Map<PerformanceDayActivityType, number>) {
    let top: { activityType: PerformanceDayActivityType; count: number } | null = null
    for (const activityType of ACTIVITY_ORDER) {
      const count = counter.get(activityType) ?? 0
      if (count <= 0) continue
      if (!top || count > top.count) {
        top = { activityType, count }
      }
    }
    return top
  }

  private computeExecuteStreaks(
    logs: Array<{ date: Date; cheatDay: boolean; executionScore: number | null }>,
  ) {
    const isSuccess = (log: { cheatDay: boolean; executionScore: number | null }) =>
      !log.cheatDay && (log.executionScore ?? 0) > 0

    let bestStreak = 0
    let runningBest = 0
    let prevSuccessDate: Date | null = null
    for (const log of logs) {
      if (!isSuccess(log)) {
        runningBest = 0
        prevSuccessDate = null
        continue
      }

      const currentDate = this.startOfUtcDay(log.date)
      if (!prevSuccessDate) {
        runningBest = 1
      } else {
        const diffDays = Math.round((currentDate.getTime() - prevSuccessDate.getTime()) / 86400000)
        runningBest = diffDays === 1 ? runningBest + 1 : 1
      }
      prevSuccessDate = currentDate
      if (runningBest > bestStreak) bestStreak = runningBest
    }

    let currentStreak = 0
    const descending = [...logs].sort((a, b) => b.date.getTime() - a.date.getTime())
    let cursorDate: Date | null = null
    for (const log of descending) {
      const success = isSuccess(log)
      const date = this.startOfUtcDay(log.date)
      if (currentStreak === 0) {
        if (!success) break
        currentStreak = 1
        cursorDate = date
        continue
      }

      const expectedPrev = this.addUtcDays(cursorDate!, -1)
      if (date.getTime() !== expectedPrev.getTime()) break
      if (!success) break

      currentStreak += 1
      cursorDate = date
    }

    return { currentStreak, bestStreak }
  }

  private startOfUtcDay(date: Date) {
    const value = new Date(date)
    value.setUTCHours(0, 0, 0, 0)
    return value
  }

  private addUtcDays(date: Date, days: number) {
    const value = this.startOfUtcDay(date)
    value.setUTCDate(value.getUTCDate() + days)
    return value
  }
}
