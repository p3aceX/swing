import { prisma } from '@swing/db'
import type { Prisma } from '@prisma/client'

type StreakDbClient = Pick<
  Prisma.TransactionClient,
  'playerWorkloadEvent' | 'playerWellnessCheckin' | 'playerJournalStreakDay'
>

type StreakSnapshot = {
  date: Date
  hasWorkload: boolean
  hasWellness: boolean
  isActive: boolean
  streakCount: number
  activeDaysInWindow: number
}

export class JournalStreakService {
  private static readonly WINDOW_DAYS = 30

  async refreshRollingWindow(playerId: string, db: StreakDbClient = prisma as unknown as StreakDbClient) {
    const today = this.startOfUtcDay(new Date())
    const windowStart = this.addUtcDays(today, -(JournalStreakService.WINDOW_DAYS - 1))

    const [workloadDays, wellnessDays] = await Promise.all([
      db.playerWorkloadEvent.findMany({
        where: {
          playerId,
          isCheatDay: false,
          date: { gte: windowStart, lte: today },
        },
        select: { date: true },
      }),
      db.playerWellnessCheckin.findMany({
        where: { playerId, date: { gte: windowStart, lte: today } },
        select: { date: true },
      }),
    ])

    const workloadSet = new Set(workloadDays.map((item) => this.toDateKey(item.date)))
    const wellnessSet = new Set(wellnessDays.map((item) => this.toDateKey(item.date)))
    const snapshots = this.buildWindowSnapshots(windowStart, today, workloadSet, wellnessSet)

    for (const snapshot of snapshots) {
      await db.playerJournalStreakDay.upsert({
        where: {
          playerId_date: {
            playerId,
            date: snapshot.date,
          },
        },
        create: {
          playerId,
          date: snapshot.date,
          hasWorkload: snapshot.hasWorkload,
          hasWellness: snapshot.hasWellness,
          isActive: snapshot.isActive,
          streakCount: snapshot.streakCount,
          activeDaysInWindow: snapshot.activeDaysInWindow,
        },
        update: {
          hasWorkload: snapshot.hasWorkload,
          hasWellness: snapshot.hasWellness,
          isActive: snapshot.isActive,
          streakCount: snapshot.streakCount,
          activeDaysInWindow: snapshot.activeDaysInWindow,
        },
      })
    }

    await db.playerJournalStreakDay.deleteMany({
      where: {
        playerId,
        date: { lt: windowStart },
      },
    })

    return snapshots[snapshots.length - 1] ?? this.emptySnapshot(today)
  }

  async getTodaySnapshot(playerId: string, db: StreakDbClient = prisma as unknown as StreakDbClient) {
    const today = this.startOfUtcDay(new Date())
    return db.playerJournalStreakDay.findUnique({
      where: {
        playerId_date: { playerId, date: today },
      },
    })
  }

  private buildWindowSnapshots(
    start: Date,
    end: Date,
    workloadSet: Set<string>,
    wellnessSet: Set<string>,
  ): StreakSnapshot[] {
    const snapshots: StreakSnapshot[] = []
    let runningStreak = 0
    let activeDaysInWindow = 0

    for (let cursor = new Date(start); cursor <= end; cursor = this.addUtcDays(cursor, 1)) {
      const date = this.startOfUtcDay(cursor)
      const dateKey = this.toDateKey(date)
      const hasWorkload = workloadSet.has(dateKey)
      const hasWellness = wellnessSet.has(dateKey)
      const isActive = hasWorkload || hasWellness

      runningStreak = isActive ? runningStreak + 1 : 0
      activeDaysInWindow += isActive ? 1 : 0

      snapshots.push({
        date,
        hasWorkload,
        hasWellness,
        isActive,
        streakCount: runningStreak,
        activeDaysInWindow,
      })
    }

    return snapshots
  }

  private emptySnapshot(date: Date): StreakSnapshot {
    return {
      date,
      hasWorkload: false,
      hasWellness: false,
      isActive: false,
      streakCount: 0,
      activeDaysInWindow: 0,
    }
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

  private toDateKey(date: Date) {
    return this.startOfUtcDay(date).toISOString().slice(0, 10)
  }
}
