import { prisma } from '@swing/db'
import { EliteJournalService } from './elite-journal.service'
import { ElitePlanService } from './elite-plan.service'
import { PerformanceLogService } from './performance-log.service'

type ExecutionStatus = 'NOT_STARTED' | 'ON_TRACK' | 'PARTIAL' | 'MISSED'
type ConsistencyStatus = 'COMPLETED' | 'PARTIAL' | 'MISSED'

export class ApexStateService {
  private readonly planSvc = new ElitePlanService()
  private readonly executeSvc = new PerformanceLogService()
  private readonly journalSvc = new EliteJournalService()

  async getPlayerApexState(playerId: string) {
    const player = await prisma.playerProfile.findUnique({
      where: { id: playerId },
      select: { id: true },
    })

    if (!player) return null

    const today = this.toDateKey(new Date())

    const [goal, weeklyPlan, todayLog, consistency] = await Promise.all([
      prisma.performanceAmbition.findUnique({
        where: { playerId },
      }),
      this.planSvc.getMyPlan(playerId),
      this.executeSvc.getDayLog(playerId, today),
      this.journalSvc.getJournalStreakTimeline(playerId, 30),
    ])

    const dayLog = todayLog.dayLog
    const rawTodayLog = await prisma.performanceDayLog.findUnique({
      where: {
        playerId_date: {
          playerId,
          date: new Date(`${today}T00:00:00.000Z`),
        },
      },
      select: { caloriesConsumed: true },
    })

    const actualCalories = rawTodayLog?.caloriesConsumed ?? 0
    const actualNetsMinutes = dayLog.execution?.netsMinutes ?? 0
    const actualGymMinutes = dayLog.execution?.fitnessMinutes ?? 0
    const todayStatus = this.getExecutionStatus({
      isLocked: dayLog.isLocked,
      executionScore: dayLog.executionScore,
      actualCalories,
      actualNetsMinutes,
      actualGymMinutes,
    })

    return {
      status: 'success',
      data: {
        goal: goal ? {
          ...goal,
          waistCm: goal.waistCircumferenceCm,
          neckCm: goal.neckCircumferenceCm,
          hipCm: goal.hipCircumferenceCm,
          bodyFatPercent: goal.bodyFatPercent,
        } : null,
        today: {
          date: today,
          isLocked: dayLog.isLocked,
          plan: {
            oneThing: dayLog.oneThingToday ?? null,
            targetCalories: goal?.dailyCalorieTarget ?? weeklyPlan?.plan.dailyCalorieTarget ?? 0,
            targetNetsMinutes: dayLog.plan.netsMinutes ?? 0,
            targetGymMinutes: dayLog.plan.fitnessMinutes ?? 0,
            targetDrillsMinutes: dayLog.plan.drillsMinutes ?? 0,
            targetRecoveryMinutes: dayLog.plan.recoveryMinutes ?? 0,
          },
          execution: {
            actualCalories,
            actualNetsMinutes,
            actualGymMinutes,
            actualDrillsMinutes: dayLog.execution?.drillsMinutes ?? 0,
            actualRecoveryMinutes: dayLog.execution?.recoveryMinutes ?? 0,
            status: todayStatus,
          },
        },
        weeklyPlan: {
          name: weeklyPlan?.plan.name ?? null,
          days: (weeklyPlan?.plan.days ?? []).map((day) => ({
            day: day.weekday,
            nets: day.netsMinutes ?? 0,
            gym: day.fitnessMinutes ?? 0,
            recovery: day.recoveryMinutes ?? 0,
            drills: day.drillsMinutes ?? 0,
            conditioning: day.hasConditioning ? 60 : 0, // Fallback if no minutes
            match: day.hasMatch ? 1 : 0,
          })),
        },
        consistency: {
          currentStreak: consistency.summary.currentStreak,
          adherencePercentage: consistency.summary.planVsExecutionPct,
          history: consistency.days.map((day) => ({
            date: day.date,
            score: day.execution.executionScore ?? 0,
            status: this.getConsistencyStatus(day.execution.executionScore),
          })),
        },
      },
    }
  }

  private getExecutionStatus(input: {
    isLocked: boolean
    executionScore: number | null
    actualCalories: number
    actualNetsMinutes: number
    actualGymMinutes: number
  }): ExecutionStatus {
    const hasActuals =
      input.actualCalories > 0 ||
      input.actualNetsMinutes > 0 ||
      input.actualGymMinutes > 0

    if (!hasActuals) {
      return input.isLocked ? 'MISSED' : 'NOT_STARTED'
    }

    if ((input.executionScore ?? 0) >= 80) return 'ON_TRACK'
    if ((input.executionScore ?? 0) > 0) return 'PARTIAL'
    return input.isLocked ? 'PARTIAL' : 'ON_TRACK'
  }

  private getConsistencyStatus(score: number | null): ConsistencyStatus {
    if ((score ?? 0) >= 80) return 'COMPLETED'
    if ((score ?? 0) > 0) return 'PARTIAL'
    return 'MISSED'
  }

  private toDateKey(date: Date) {
    const copy = new Date(date)
    copy.setUTCHours(0, 0, 0, 0)
    return copy.toISOString().slice(0, 10)
  }
}
