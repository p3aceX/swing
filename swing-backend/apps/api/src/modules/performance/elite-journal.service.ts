import { prisma } from '@swing/db'
import { AppError } from '../../lib/errors'
import { JournalStreakService } from './journal-streak.service'
import { PlanWeekday, Prisma, PerformanceDayActivityType } from '@prisma/client'

const DAY_LOG_ACTIVITY_TYPES: PerformanceDayActivityType[] = [
  'NETS',
  'SKILL_WORK',
  'GYM',
  'CONDITIONING',
  'MATCH',
  'RECOVERY',
  'PROPER_DIET',
]

export interface EliteJournalEntry {
  date: string | Date
  isCheatDay?: boolean
  // Step 1, 2, 3: The Work
  activity: {
    type: string
    durationMinutes: number
    intensity: number // 1-10
    drillIds: string[]
    notes?: string | null
  }
  // Step 4: The Mental Pillar
  mental: {
    confidence: number // 1-10
    focus: number // 1-10
    resilience: number // 1-10
  }
  // Step 5: The Physical Context
  context: {
    sleepQuality: number // 1-10
    hydrationLiters: number
    caloriesConsumed?: number
    waistCircumferenceCm?: number
    neckCircumferenceCm?: number
    hipCircumferenceCm?: number
    soreness: number // 1-10
    fatigue: number // 1-10
    mood: number // 1-10
    stress: number // 1-10
  }
}

export class EliteJournalService {
  private journalStreak = new JournalStreakService()

  /**
   * THE 5-STEP ELITE JOURNAL ENGINE
   * Converts subjective practice experiences into structured performance data.
   */
  async logEntry(playerId: string, entry: EliteJournalEntry) {
    const date = this.parseEntryDate(entry.date)
    const startOfDay = this.startOfUtcDay(date)
    const nextDay = this.addUtcDays(startOfDay, 1)
    const isCheatDay = entry.isCheatDay === true
    const normalizedDuration = isCheatDay ? 0 : Math.max(0, Math.floor(entry.activity.durationMinutes))
    const normalizedIntensity = isCheatDay ? null : entry.activity.intensity
    const normalizedDrillIds = isCheatDay ? [] : entry.activity.drillIds

    return prisma.$transaction(async (tx) => {
      // 0. Calculate Body Fat % if metrics are provided
      let bodyFatPercent: number | undefined
      if (entry.context.waistCircumferenceCm && entry.context.neckCircumferenceCm) {
        const profile = await tx.playerProfile.findUnique({
          where: { id: playerId },
          select: { heightCm: true, gender: true },
        })
        const h = profile?.heightCm
        const w = entry.context.waistCircumferenceCm
        const n = entry.context.neckCircumferenceCm
        const hip = entry.context.hipCircumferenceCm
        const isMale = profile?.gender?.toLowerCase() === 'male'

        if (h && w && n) {
          if (isMale) {
            bodyFatPercent = 495 / (1.0324 - 0.19077 * Math.log10(w - n) + 0.15456 * Math.log10(h)) - 450
          } else if (hip) {
            bodyFatPercent = 495 / (1.29579 - 0.35004 * Math.log10(w + hip - n) + 0.22100 * Math.log10(h)) - 450
          }
          if (bodyFatPercent) bodyFatPercent = Math.round(bodyFatPercent * 10) / 10
        }
      }

      // Upsert by (playerId, UTC-date, activity.type) so resubmits overwrite instead of duplicating.
      const existingWorkload = await tx.playerWorkloadEvent.findFirst({
        where: {
          playerId,
          type: entry.activity.type,
          source: 'ELITE_JOURNAL',
          date: { gte: startOfDay, lt: nextDay },
        },
        orderBy: { createdAt: 'desc' },
        select: { id: true },
      })
      const workloadPayload = {
        playerId,
        date: startOfDay,
        type: entry.activity.type,
        durationMinutes: normalizedDuration,
        intensity: normalizedIntensity,
        drillIds: normalizedDrillIds,
        isCheatDay,
        notes: entry.activity.notes || null,
        source: 'ELITE_JOURNAL',
      }
      const workload = existingWorkload
        ? await tx.playerWorkloadEvent.update({
          where: { id: existingWorkload.id },
          data: workloadPayload,
        })
        : await tx.playerWorkloadEvent.create({
          data: workloadPayload,
        })

      await tx.playerWorkloadEvent.deleteMany({
        where: {
          playerId,
          type: entry.activity.type,
          source: 'ELITE_JOURNAL',
          date: { gte: startOfDay, lt: nextDay },
          id: { not: workload.id },
        },
      })

      // Cheat day should behave like a no-activity day for adherence/discipline math.
      if (isCheatDay) {
        await tx.playerWorkloadEvent.updateMany({
          where: {
            playerId,
            source: 'ELITE_JOURNAL',
            date: { gte: startOfDay, lt: nextDay },
            id: { not: workload.id },
          },
          data: {
            isCheatDay: true,
            durationMinutes: 0,
            intensity: null,
            drillIds: [],
          },
        })
      }

      // 2. Log/Update the Wellness & Mental Check-in (The Daily State)
      // We use upsert because wellness is usually 1 record per day
      const wellness = await tx.playerWellnessCheckin.upsert({
        where: {
          playerId_date: { playerId, date: startOfDay }
        },
        update: {
          soreness: entry.context.soreness,
          fatigue: entry.context.fatigue,
          mood: entry.context.mood,
          stress: entry.context.stress,
          sleepQuality: entry.context.sleepQuality,
          confidence: entry.mental.confidence,
          focus: entry.mental.focus,
          resilience: entry.mental.resilience,
          hydrationLiters: entry.context.hydrationLiters,
          caloriesConsumed: entry.context.caloriesConsumed,
          waistCircumferenceCm: entry.context.waistCircumferenceCm,
          neckCircumferenceCm: entry.context.neckCircumferenceCm,
          hipCircumferenceCm: entry.context.hipCircumferenceCm,
          bodyFatPercent,
          notes: entry.activity.notes || null,
          painTightness: entry.context.soreness > 7 ? 3 : 0, // Heuristic: high soreness implies tightness
        },
        create: {
          playerId,
          date: startOfDay,
          soreness: entry.context.soreness,
          fatigue: entry.context.fatigue,
          mood: entry.context.mood,
          stress: entry.context.stress,
          sleepQuality: entry.context.sleepQuality,
          confidence: entry.mental.confidence,
          focus: entry.mental.focus,
          resilience: entry.mental.resilience,
          hydrationLiters: entry.context.hydrationLiters,
          caloriesConsumed: entry.context.caloriesConsumed,
          waistCircumferenceCm: entry.context.waistCircumferenceCm,
          neckCircumferenceCm: entry.context.neckCircumferenceCm,
          hipCircumferenceCm: entry.context.hipCircumferenceCm,
          bodyFatPercent,
          notes: entry.activity.notes || null,
          painTightness: entry.context.soreness > 7 ? 3 : 0,
        }
      })

      await this.syncDayLogFromJournal(tx, playerId, startOfDay, entry, isCheatDay, bodyFatPercent)
      await this.journalStreak.refreshRollingWindow(playerId, tx)

      return { workload, wellness }
    })
  }

  async getJournalHistory(playerId: string, limit = 14) {
    const [workloads, wellness] = await Promise.all([
      prisma.playerWorkloadEvent.findMany({
        where: { playerId, source: 'ELITE_JOURNAL' },
        orderBy: { date: 'desc' },
        take: limit
      }),
      prisma.playerWellnessCheckin.findMany({
        where: { playerId },
        orderBy: { date: 'desc' },
        take: limit
      })
    ])

    return { workloads, wellness }
  }

  /**
   * Generates a "Preparation Score" based on Journal consistency
   * This is separate from the match-based Swing Index.
   */
  async getPreparationScore(playerId: string) {
    const sevenDaysAgo = new Date()
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7)

    const [entries, checkins] = await Promise.all([
      prisma.playerWorkloadEvent.count({
        where: { playerId, date: { gte: sevenDaysAgo } }
      }),
      prisma.playerWellnessCheckin.findMany({
        where: { playerId, date: { gte: sevenDaysAgo } },
        select: { confidence: true, focus: true }
      })
    ])

    const trainingConsistency = Math.min(100, (entries / 5) * 100) // Goal: 5 sessions/week
    const avgConfidence = checkins.length > 0 
      ? (checkins.reduce((sum, c) => sum + (c.confidence || 5), 0) / checkins.length) * 10
      : 50
    
    return {
      score: Math.round((trainingConsistency * 0.6) + (avgConfidence * 0.4)),
      trainingConsistency,
      mentalStrength: avgConfidence,
      daysLogged: checkins.length
    }
  }

  async getJournalStreakTimeline(playerId: string, daysInput = 30) {
    const days = Math.max(1, Math.min(30, Number.isFinite(daysInput) ? Math.floor(daysInput) : 30))
    const today = this.startOfUtcDay(new Date())
    const startDate = this.addUtcDays(today, -(days - 1))

    await this.journalStreak.refreshRollingWindow(playerId)

    const [streakRows, dayLogs] = await Promise.all([
      prisma.playerJournalStreakDay.findMany({
        where: { playerId, date: { gte: startDate, lte: today } },
        orderBy: { date: 'asc' },
      }),
      prisma.performanceDayLog.findMany({
        where: { playerId, date: { gte: startDate, lte: today } },
        include: {
          sessions: {
            select: { type: true, actualDuration: true },
          },
        },
        orderBy: { date: 'asc' },
      }),
    ])

    const streakByDate = new Map(streakRows.map((row) => [this.toDateKey(row.date), row]))
    const logsByDate = new Map(dayLogs.map((log) => [this.toDateKey(log.date), log]))

    const dayTimeline: Array<{
      date: string
      streak: {
        isActive: boolean
        hasWorkload: boolean
        hasWellness: boolean
        streakCount: number
        activeDaysInWindow: number
      }
      plan: {
        isPlannedDay: boolean
        isLocked: boolean
        targets: {
          netsMinutes: number
          drillsMinutes: number
          gymMinutes: number
          recoveryMinutes: number
          sleepHours: number
          hydrationLiters: number
        }
      }
      execution: {
        isExecutedDay: boolean
        executionScore: number | null
        actuals: {
          netsMinutes: number
          drillsMinutes: number
          gymMinutes: number
          recoveryMinutes: number
          sleepHours: number
          hydrationLiters: number
        }
      }
    }> = []

    let plannedDays = 0
    let executedDays = 0

    for (let cursor = new Date(startDate); cursor <= today; cursor = this.addUtcDays(cursor, 1)) {
      const key = this.toDateKey(cursor)
      const streak = streakByDate.get(key)
      const log = logsByDate.get(key)

      const targets = {
        netsMinutes: log?.targetNetsMinutes ?? 0,
        drillsMinutes: log?.targetDrillsMinutes ?? 0,
        gymMinutes: log?.targetGymMinutes ?? 0,
        recoveryMinutes: log?.targetRecoveryMinutes ?? 0,
        sleepHours: log?.targetSleep ?? 0,
        hydrationLiters: log?.targetHydration ?? 0,
      }

      let actualNetsMinutes = 0
      let actualDrillsMinutes = 0
      let actualGymMinutes = 0
      let actualRecoveryMinutes = 0
      for (const session of log?.sessions ?? []) {
        const duration = session.actualDuration ?? 0
        if (session.type === 'NETS') actualNetsMinutes += duration
        if (session.type === 'SKILL_WORK') actualDrillsMinutes += duration
        if (session.type === 'GYM' || session.type === 'CONDITIONING') actualGymMinutes += duration
        if (session.type === 'RECOVERY') actualRecoveryMinutes += duration
      }

      const actuals = {
        netsMinutes: Math.max(log?.actualNetsMinutes ?? 0, actualNetsMinutes),
        drillsMinutes: Math.max(log?.actualDrillsMinutes ?? 0, actualDrillsMinutes),
        gymMinutes: Math.max(log?.actualFitnessMinutes ?? 0, actualGymMinutes),
        recoveryMinutes: Math.max(log?.actualRecoveryMinutes ?? 0, actualRecoveryMinutes),
        sleepHours: log?.sleepHours ?? 0,
        hydrationLiters: log?.hydrationLiters ?? 0,
      }

      const isPlannedDay = (
        targets.netsMinutes > 0 ||
        targets.drillsMinutes > 0 ||
        targets.gymMinutes > 0 ||
        targets.recoveryMinutes > 0 ||
        targets.sleepHours > 0 ||
        targets.hydrationLiters > 0
      )
      const isExecutedDay = Boolean(
        streak?.isActive ||
        actuals.netsMinutes > 0 ||
        actuals.drillsMinutes > 0 ||
        actuals.gymMinutes > 0 ||
        actuals.recoveryMinutes > 0 ||
        actuals.sleepHours > 0 ||
        actuals.hydrationLiters > 0,
      )

      if (isPlannedDay) plannedDays += 1
      if (isExecutedDay) executedDays += 1

      dayTimeline.push({
        date: key,
        streak: {
          isActive: Boolean(streak?.isActive),
          hasWorkload: Boolean(streak?.hasWorkload),
          hasWellness: Boolean(streak?.hasWellness),
          streakCount: streak?.streakCount ?? 0,
          activeDaysInWindow: streak?.activeDaysInWindow ?? 0,
        },
        plan: {
          isPlannedDay,
          isLocked: Boolean(log?.isLocked),
          targets,
        },
        execution: {
          isExecutedDay,
          executionScore: log?.executionScore ?? null,
          actuals,
        },
      })
    }

    const latest = dayTimeline[dayTimeline.length - 1]
    const currentStreak = latest?.streak.streakCount ?? 0
    const activeDaysInWindow = latest?.streak.activeDaysInWindow ?? 0
    const planVsExecutionPct = plannedDays > 0
      ? Number(((executedDays / plannedDays) * 100).toFixed(1))
      : 0

    return {
      playerId,
      windowDays: days,
      summary: {
        currentStreak,
        activeDaysInWindow,
        plannedDays,
        executedDays,
        planVsExecutionPct,
      },
      days: dayTimeline,
    }
  }

  private startOfUtcDay(value: Date) {
    const date = new Date(value)
    date.setUTCHours(0, 0, 0, 0)
    return date
  }

  private parseEntryDate(value: string | Date) {
    const parsed = value instanceof Date ? new Date(value) : new Date(value)
    if (Number.isNaN(parsed.getTime())) {
      throw new AppError('VALIDATION_ERROR', 'Invalid journal date')
    }
    return parsed
  }

  private addUtcDays(value: Date, days: number) {
    const date = this.startOfUtcDay(value)
    date.setUTCDate(date.getUTCDate() + days)
    return date
  }

  private toDateKey(value: Date) {
    return this.startOfUtcDay(value).toISOString().slice(0, 10)
  }

  private toWeekday(value: Date): PlanWeekday {
    const day = this.startOfUtcDay(value).getUTCDay()
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

  private async syncDayLogFromJournal(
    tx: Prisma.TransactionClient,
    playerId: string,
    dayStart: Date,
    entry: EliteJournalEntry,
    isCheatDay: boolean,
    bodyFatPercent?: number,
  ) {
    const existing = await tx.performanceDayLog.findUnique({
      where: { playerId_date: { playerId, date: dayStart } },
      select: { id: true, isLocked: true },
    })

    let dayLogId = existing?.id
    if (!existing) {
      const plan = await tx.performancePlan.findUnique({
        where: { playerId },
        include: { days: true },
      })
      const weekday = this.toWeekday(dayStart)
      const dayPlan = plan?.isActive ? plan.days.find((day) => day.weekday === weekday) : null
      const created = await tx.performanceDayLog.create({
        data: {
          playerId,
          date: dayStart,
          type: 'TRAINING',
          targetNetsMinutes: dayPlan?.netsMinutes ?? 0,
          targetDrillsMinutes: dayPlan?.drillsMinutes ?? 0,
          targetGymMinutes: dayPlan?.fitnessMinutes ?? 0,
          targetRecoveryMinutes: dayPlan?.recoveryMinutes ?? 0,
          targetSleep: dayPlan ? Number(dayPlan.sleepTargetHours) : (plan?.isActive ? Number(plan.sleepTargetHours) : 0),
          targetHydration: dayPlan ? Number(dayPlan.hydrationTargetLiters) : (plan?.isActive ? Number(plan.hydrationTargetLiters) : 0),
        },
        select: { id: true },
      })
      dayLogId = created.id
    }

    if (!dayLogId || existing?.isLocked) {
      return
    }

    const nextDay = this.addUtcDays(dayStart, 1)
    const dayEvents = await tx.playerWorkloadEvent.findMany({
      where: {
        playerId,
        source: 'ELITE_JOURNAL',
        isCheatDay: false,
        date: { gte: dayStart, lt: nextDay },
      },
      select: { type: true, durationMinutes: true },
    })

    let netsMinutes = 0
    let drillsMinutes = 0
    let fitnessMinutes = 0
    let recoveryMinutes = 0
    const completionByType: Record<PerformanceDayActivityType, boolean> = {
      NETS: false,
      SKILL_WORK: false,
      GYM: false,
      CONDITIONING: false,
      MATCH: false,
      RECOVERY: false,
      PROPER_DIET: false,
    }

    for (const event of dayEvents) {
      const duration = Math.max(0, event.durationMinutes)
      if (event.type === 'NETS') {
        netsMinutes += duration
        completionByType.NETS = completionByType.NETS || duration > 0
      }
      if (event.type === 'SKILL_WORK') {
        drillsMinutes += duration
        completionByType.SKILL_WORK = completionByType.SKILL_WORK || duration > 0
      }
      if (event.type === 'GYM') {
        fitnessMinutes += duration
        completionByType.GYM = completionByType.GYM || duration > 0
      }
      if (event.type === 'CONDITIONING') {
        fitnessMinutes += duration
        completionByType.CONDITIONING = completionByType.CONDITIONING || duration > 0
      }
      if (event.type === 'MATCH') {
        completionByType.MATCH = completionByType.MATCH || duration > 0
      }
      if (event.type === 'RECOVERY') {
        recoveryMinutes += duration
        completionByType.RECOVERY = completionByType.RECOVERY || duration > 0
      }
    }

    await tx.performanceDayLog.update({
      where: { id: dayLogId },
      data: {
        cheatDay: isCheatDay,
        actualNetsMinutes: netsMinutes,
        actualDrillsMinutes: drillsMinutes,
        actualFitnessMinutes: fitnessMinutes,
        actualRecoveryMinutes: recoveryMinutes,
        sleepQuality: entry.context.sleepQuality,
        soreness: entry.context.soreness,
        fatigue: entry.context.fatigue,
        stress: entry.context.stress,
        hydrationLiters: entry.context.hydrationLiters,
        caloriesConsumed: entry.context.caloriesConsumed,
        waistCircumferenceCm: entry.context.waistCircumferenceCm,
        neckCircumferenceCm: entry.context.neckCircumferenceCm,
        hipCircumferenceCm: entry.context.hipCircumferenceCm,
        bodyFatPercent,
      },
    })

    // Also sync to the main profile if provided
    if (entry.context.waistCircumferenceCm || entry.context.caloriesConsumed) {
      await tx.playerProfile.update({
        where: { id: playerId },
        data: {
          waistCircumferenceCm: entry.context.waistCircumferenceCm,
          neckCircumferenceCm: entry.context.neckCircumferenceCm,
          hipCircumferenceCm: entry.context.hipCircumferenceCm,
        }
      })
    }

    await Promise.all(
      DAY_LOG_ACTIVITY_TYPES.map((activityType) =>
        tx.performanceDayActivity.upsert({
          where: {
            dayLogId_activityType: {
              dayLogId,
              activityType,
            },
          },
          update: {
            wasCompleted: isCheatDay ? false : completionByType[activityType],
          },
          create: {
            dayLogId,
            activityType,
            wasPlanned: false,
            wasCompleted: isCheatDay ? false : completionByType[activityType],
          },
        }),
      ),
    )
  }
}
