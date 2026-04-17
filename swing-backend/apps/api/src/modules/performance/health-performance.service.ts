import { prisma } from '@swing/db'
import { 
  PlayerPhysicalSample, 
  PlayerWellnessCheckin, 
  PlayerWorkloadEvent 
} from '@prisma/client'
import { JournalStreakService } from './journal-streak.service'
import { getSwingPlayerState } from './state-read.repository'

export interface Power5Dashboard {
  readiness: { score: number; status: 'GREEN' | 'AMBER' | 'RED'; label: string }
  output: { score: number; activeMinutes: number; calories: number; label: string }
  vitality: { score: number; hydrationL: number; weightKg: number; steps: number; bodyFatPercent: number; waistCm: number }
  integrity: { score: number; injuryRisk: 'LOW' | 'MODERATE' | 'HIGH'; acwr: number }
  iq: { score: number; adviceRead: boolean; dailyTip: string; recommendations: string[] }
  dailyGrowth: { progressPct: number; isGoalReached: boolean; streak: number }
}

export class HealthPerformanceService {
  private journalStreak = new JournalStreakService()

  /**
   * THE POWER 5 ENGINE
   * Collapses all health, wearable, and manual data into 5 Elite Metrics.
   */
  async getPower5Dashboard(playerId: string): Promise<Power5Dashboard> {
    const now = new Date()
    const startOfDay = new Date(now)
    startOfDay.setHours(0, 0, 0, 0)

    const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000)
    const twentyEightDaysAgo = new Date(now.getTime() - 28 * 24 * 60 * 60 * 1000)

    const [
      wellness,
      physicalSamples,
      recentWorkloads,
      historicalWorkloads,
      profile,
      aggregate,
      todayStreakSnapshot,
    ] = await Promise.all([
      prisma.playerWellnessCheckin.findFirst({
        where: { playerId, date: { gte: startOfDay } },
        orderBy: { date: 'desc' }
      }),
      prisma.playerPhysicalSample.findMany({
        where: { playerId, sampleStartAt: { gte: startOfDay } },
        orderBy: { sampleStartAt: 'desc' }
      }),
      prisma.playerWorkloadEvent.findMany({
        where: { playerId, date: { gte: sevenDaysAgo } }
      }),
      prisma.playerWorkloadEvent.findMany({
        where: { playerId, date: { gte: twentyEightDaysAgo } }
      }),
      prisma.playerProfile.findUnique({
        where: { id: playerId },
        select: { playerRole: true, waistCircumferenceCm: true }
      }),
      getSwingPlayerState(playerId),
      this.journalStreak.getTodaySnapshot(playerId),
    ])

    // 1. READINESS (The Green Light)
    const readiness = this.calculateReadiness(wellness, physicalSamples)

    // 2. OUTPUT (Engine Usage)
    const output = this.calculateOutput(recentWorkloads.filter(w => w.date >= startOfDay), physicalSamples)

    // 3. VITALITY (The Fuel Tank)
    const vitality = this.calculateVitality(physicalSamples, wellness)

    // 4. INTEGRITY (Injury Shield)
    const integrity = this.calculateIntegrity(recentWorkloads, historicalWorkloads)

    // 5. IQ (Game Awareness + Recommendations)
    const iq = this.getDailyIQ(profile?.playerRole || 'ALLROUNDER', aggregate ? {
      currentBattingIndex: aggregate.batScore,
      currentBowlingIndex: aggregate.bowlScore,
    } : null)

    // DAILY GROWTH (The 1% Better Engine)
    const streakSnapshot = todayStreakSnapshot ?? await this.journalStreak.refreshRollingWindow(playerId)
    const streak = streakSnapshot.activeDaysInWindow
    const todayCalories = wellness?.caloriesConsumed || 0
    const dailyGrowth = this.calculateDailyGrowth(readiness.score, output.score, vitality.hydrationL, iq.adviceRead, streak, todayCalories)

    return {
      readiness,
      output,
      vitality: {
        ...vitality,
        bodyFatPercent: wellness?.bodyFatPercent || 0,
        waistCm: wellness?.waistCircumferenceCm || profile?.waistCircumferenceCm || 0,
      },
      integrity,
      iq,
      dailyGrowth
    }
  }

  private calculateReadiness(wellness: PlayerWellnessCheckin | null, samples: PlayerPhysicalSample[]): { score: number; status: 'GREEN' | 'AMBER' | 'RED'; label: string } {
    // Weighted components
    let score = 70 // Baseline
    const latestSample = samples.find(s => s.hrv !== null || s.averageHeartRate !== null)

    // Wearable Input (Highest Priority)
    if (latestSample?.hrv) {
      score = (latestSample.hrv / 100) * 100 // Simplified HRV normalization
    } else if (latestSample?.averageHeartRate) {
        // Resting HR proxy: Lower is usually better readiness for athletes
        const rhr = latestSample.averageHeartRate
        score = rhr < 60 ? 90 : rhr < 75 ? 75 : 50
    }

    // Wellness Input (Manual Override/Modifier)
    if (wellness) {
      const manualScore = (
        (10 - wellness.soreness) * 0.4 + 
        (wellness.sleepQuality) * 0.4 + 
        (10 - wellness.fatigue) * 0.2
      ) * 10
      score = latestSample ? (score * 0.6 + manualScore * 0.4) : manualScore
    }

    const status: 'GREEN' | 'AMBER' | 'RED' = score > 80 ? 'GREEN' : score > 50 ? 'AMBER' : 'RED'
    const label = status === 'GREEN' ? 'Elite Readiness' : status === 'AMBER' ? 'Moderate Recovery' : 'Rest Required'

    return { score: Math.round(score), status, label }
  }

  private calculateOutput(todayWorkloads: PlayerWorkloadEvent[], samples: PlayerPhysicalSample[]) {
    let activeMinutes = todayWorkloads.reduce((sum, w) => sum + w.durationMinutes, 0)
    let calories = samples.reduce((sum, s) => sum + (s.caloriesBurned || 0), 0)
    
    // Convert match/nets intensity to a score
    const score = Math.min(100, (activeMinutes / 120) * 100) 
    
    return { 
      score: Math.round(score), 
      activeMinutes, 
      calories: Math.round(calories),
      label: activeMinutes > 90 ? 'High Intensity' : activeMinutes > 30 ? 'Active' : 'Low Output'
    }
  }

  private calculateVitality(samples: PlayerPhysicalSample[], wellness: PlayerWellnessCheckin | null) {
    let hydrationL = samples.reduce((sum, s) => sum + (s.hydrationMetric || 0), 0)
    // Add manual hydration from journal if it's higher than wearable/proxy
    if (wellness?.hydrationLiters && wellness.hydrationLiters > hydrationL) {
      hydrationL = wellness.hydrationLiters
    }

    const weightKg = samples.find(s => s.weightKg !== null)?.weightKg || 0
    const steps = samples.reduce((sum, s) => sum + (s.steps || 0), 0)
    
    // Goal: 3.5L hydration, 10k steps
    const score = (
      Math.min(100, (hydrationL / 3.5) * 100) * 0.6 +
      Math.min(100, (steps / 10000) * 100) * 0.4
    )

    return { score: Math.round(score), hydrationL: Number(hydrationL.toFixed(1)), weightKg, steps }
  }

  private calculateIntegrity(recent: PlayerWorkloadEvent[], historical: PlayerWorkloadEvent[]) {
    const calculateLoad = (events: PlayerWorkloadEvent[]) => 
      events.reduce((sum, e) => sum + (e.durationMinutes * (e.intensity || 5)), 0)

    const acuteLoad = calculateLoad(recent)
    const chronicLoad = (calculateLoad(historical) || 1) / 4
    const acwr = Number((acuteLoad / chronicLoad).toFixed(2))

    let score = 100
    let risk: 'LOW' | 'MODERATE' | 'HIGH' = 'LOW'

    if (acwr > 1.5 || acwr < 0.5) {
      score = 40
      risk = 'HIGH'
    } else if (acwr > 1.3 || acwr < 0.8) {
      score = 70
      risk = 'MODERATE'
    }

    return { score, injuryRisk: risk, acwr }
  }

  private getDailyIQ(role: string, aggregate: { currentBattingIndex: number | null, currentBowlingIndex: number | null } | null) {
    const adviceLibrary: Record<string, string[]> = {
      'BATTER': [
        "Facing a left-arm seamer? Open your stance 5 degrees to see the ball better coming across.",
        "The first 6 balls are for your eyes, the next 60 are for your bat. Focus on the 'V' early on.",
        "Watch the bowler's hand, not the ball. The release point tells the story of the length."
      ],
      'BOWLER': [
        "Third over of your spell? Check your follow-through; if you're stopping short, your pace drops 5%.",
        "Target the 'corridor of uncertainty'. 4th stump line is harder to leave than the 5th.",
        "Use the crease. Going wide of the crease creates an angle that confuses the batter's judgment."
      ],
      'ALLROUNDER': [
        "Hydration is key for dual-role players. 4L water before 4 PM is the Kohli standard.",
        "Transitioning from bowling to batting? Slow your heart rate down with 2 minutes of box breathing.",
        "Manage your intensity. You don't need to bowl 100% in nets if you're batting for an hour today."
      ]
    }

    const recommendations: string[] = []
    if (aggregate) {
        if ((aggregate.currentBattingIndex ?? 100) < 60) {
            recommendations.push("Your batting index is dipping. Book a 1-on-1 session with a technical coach.")
        }
        if ((aggregate.currentBowlingIndex ?? 100) < 60) {
            recommendations.push("Bowling control issues detected. Try the 'Spot Bowling' drill in our Drills section.")
        }
    }

    const tips = adviceLibrary[role] || adviceLibrary['ALLROUNDER']
    const dayOfYear = Math.floor((new Date().getTime() - new Date(new Date().getFullYear(), 0, 0).getTime()) / 86400000)
    const dailyTip = tips[dayOfYear % tips.length]

    return { score: 100, adviceRead: false, dailyTip, recommendations }
  }

  private calculateDailyGrowth(readiness: number, output: number, hydration: number, iqRead: boolean, streak: number, calories: number) {
    // The "1% Better" Engine
    // Goals: Readiness synced, Output > 0, Hydration > 2L, IQ Read, Calories logged
    let progress = 0
    if (readiness > 0) progress += 0.2
    if (output > 0) progress += 0.2
    if (hydration >= 2) progress += 0.2
    if (iqRead) progress += 0.2
    if (calories > 0) progress += 0.2

    return {
      progressPct: progress,
      isGoalReached: progress >= 1.0,
      streak: streak
    }
  }
}
