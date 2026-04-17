import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { prisma } from '@swing/db'
import { EliteAnalyticsService } from './elite-analytics.service'
import { ChallengeDetectorService } from './challenge-detector.service'
import { EliteStatsExtendedService } from './elite-stats-extended.service'
import { PerformanceService } from './performance.service'
import { HealthPerformanceService } from './health-performance.service'
import { EliteJournalService } from './elite-journal.service'
import { ElitePlanService } from './elite-plan.service'
import { PerformanceLogService } from './performance-log.service'
import { ApexStateService } from './apex-state.service'

export async function eliteRoutes(app: FastifyInstance) {
  const analyticsSvc = new EliteAnalyticsService()
  const challengesSvc = new ChallengeDetectorService()
  const extendedStatsSvc = new EliteStatsExtendedService()
  const performanceSvc = new PerformanceService()
  const healthSvc = new HealthPerformanceService()
  const journalSvc = new EliteJournalService()
  const planSvc = new ElitePlanService()
  const executeSvc = new PerformanceLogService()
  const apexStateSvc = new ApexStateService()
  const auth = { onRequest: [(app as any).authenticate] }

  const weekdayEnum = z.enum(['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'])
  const activityTypeEnum = z.enum(['NETS', 'SKILL_WORK', 'GYM', 'CONDITIONING', 'MATCH', 'RECOVERY', 'PROPER_DIET'])
  const activityDomainEnum = z.enum(['BATTING', 'BOWLING', 'FIELDING', 'FITNESS', 'RECOVERY', 'NUTRITION', 'MATCH'])
  const planDayCreateSchema = z.object({
    weekday: weekdayEnum,
    hasNets: z.boolean().optional(),
    hasSkillWork: z.boolean().optional(),
    hasGym: z.boolean().optional(),
    hasConditioning: z.boolean().optional(),
    hasMatch: z.boolean().optional(),
    hasRecovery: z.boolean().optional(),
    hasProperDiet: z.boolean().optional(),
    sleepTargetHours: z.number().min(0).max(24).optional(),
    hydrationTargetLiters: z.number().min(0).max(15).optional(),
    // Legacy optional fields retained for backward compatibility.
    netsMinutes: z.number().int().min(0).max(1440).optional(),
    drillsMinutes: z.number().int().min(0).max(1440).optional(),
    fitnessMinutes: z.number().int().min(0).max(1440).optional(),
    recoveryMinutes: z.number().int().min(0).max(1440).optional(),
  })
  const planDayPatchSchema = z.object({
    weekday: weekdayEnum,
    hasNets: z.boolean().optional(),
    hasSkillWork: z.boolean().optional(),
    hasGym: z.boolean().optional(),
    hasConditioning: z.boolean().optional(),
    hasMatch: z.boolean().optional(),
    hasRecovery: z.boolean().optional(),
    hasProperDiet: z.boolean().optional(),
    netsMinutes: z.number().int().min(0).max(1440).optional(),
    drillsMinutes: z.number().int().min(0).max(1440).optional(),
    fitnessMinutes: z.number().int().min(0).max(1440).optional(),
    recoveryMinutes: z.number().int().min(0).max(1440).optional(),
    sleepTargetHours: z.number().min(0).max(24).optional(),
    hydrationTargetLiters: z.number().min(0).max(15).optional(),
  }).refine(
    (day) =>
      day.netsMinutes !== undefined ||
      day.drillsMinutes !== undefined ||
      day.fitnessMinutes !== undefined ||
      day.recoveryMinutes !== undefined ||
      day.hasNets !== undefined ||
      day.hasSkillWork !== undefined ||
      day.hasGym !== undefined ||
      day.hasConditioning !== undefined ||
      day.hasMatch !== undefined ||
      day.hasRecovery !== undefined ||
      day.hasProperDiet !== undefined ||
      day.sleepTargetHours !== undefined ||
      day.hydrationTargetLiters !== undefined,
    { message: 'At least one day field is required for patch updates' },
  )
  const uniqueWeekdayRefine = (days: Array<{ weekday: string }>, ctx: z.RefinementCtx) => {
    const seen = new Set<string>()
    for (const [index, day] of days.entries()) {
      if (seen.has(day.weekday)) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          path: [index, 'weekday'],
          message: `Duplicate weekday: ${day.weekday}`,
        })
      }
      seen.add(day.weekday)
    }
  }

  const dayLogDateParamsSchema = z.object({
    date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Date must be in YYYY-MM-DD format'),
  })
  const executeSummaryQuerySchema = z.object({
    range: z.enum(['7d', '30d', 'month', 'all']).optional().default('30d'),
  })
  const dayLogPlanPatchSchema = z.object({
    oneThingToday: z.string().trim().max(500).nullable().optional(),
    cheatDay: z.boolean().optional(),
  }).superRefine((value, ctx) => {
    if (value.oneThingToday === undefined && value.cheatDay === undefined) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: 'At least one editable day field is required',
      })
    }
  })
  const dayLogExecuteSchema = z.object({
    execution: z.object({
      cheatDay: z.boolean().optional(),
      activities: z.array(z.object({
        activityType: activityTypeEnum,
        wasCompleted: z.boolean(),
        details: z.object({
          domain: activityDomainEnum,
          primaryFocus: z.string().trim().max(200).nullable().optional(),
          secondaryFocuses: z.array(z.string().trim().min(1).max(100)).max(20).optional(),
          whatLearned: z.string().trim().max(5000).nullable().optional(),
          whatMissed: z.string().trim().max(5000).nullable().optional(),
          notes: z.string().trim().max(5000).nullable().optional(),
          metadata: z.record(z.any()).nullable().optional(),
        }).nullable().optional(),
      })).max(7).optional(),
      sleepHours: z.number().min(0).max(24).nullable(),
      hydrationLiters: z.number().min(0).max(15).nullable(),
      tookProperDiet: z.boolean().nullable(),
      skippedMeal: z.boolean().nullable(),
      whatDidWell: z.string().trim().min(1).max(5000),
      whatDidBadly: z.string().trim().min(1).max(5000),
      note: z.string().trim().max(5000).nullable().optional(),
    }),
  }).superRefine((value, ctx) => {
    const activities = value.execution.activities ?? []
    const seen = new Set<string>()
    for (const [index, activity] of activities.entries()) {
      if (seen.has(activity.activityType)) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          path: ['execution', 'activities', index, 'activityType'],
          message: `Duplicate activityType: ${activity.activityType}`,
        })
      }
      seen.add(activity.activityType)
    }
  })

  /**
   * GET /my-plan
   * Returns the player's active plan.
   */
  app.get('/my-plan', auth, async (request, reply) => {
    const userId = (request as any).user.userId
    const player = await prisma.playerProfile.findUnique({ where: { userId }, select: { id: true } })
    if (!player) return reply.code(404).send({ success: false, error: 'Player not found' })

    const data = await planSvc.getMyPlan(player.id)
    if (!data) return reply.code(404).send({ success: true, data: null })
    return reply.send({ success: true, data })
  })

  /**
   * POST /my-plan
   * Creates or replaces the player's active plan.
   */
  app.post('/my-plan', auth, async (request, reply) => {
    const userId = (request as any).user.userId
    const player = await prisma.playerProfile.findUnique({ where: { userId }, select: { id: true } })
    if (!player) return reply.code(404).send({ success: false, error: 'Player not found' })

    const bodySchema = z.object({
      name: z.string().trim().min(1, 'Plan name is required'),
      days: z.array(planDayCreateSchema).min(1, 'At least one day entry is required'),
    }).superRefine((value, ctx) => uniqueWeekdayRefine(value.days, ctx))

    try {
      const validated = bodySchema.parse(request.body)
      const data = await planSvc.savePlan(player.id, validated as any)
      return reply.send({ success: true, data })
    } catch (err: any) {
      if (err instanceof z.ZodError) {
        return reply.code(422).send({ success: false, error: { code: 'VALIDATION_ERROR', details: err.errors } })
      }
      const statusCode = (err as any).statusCode || 500
      return reply.code(statusCode).send({ success: false, error: { message: err.message } })
    }
  })

  /**
   * PATCH /my-plan
   * Partially updates the player's active weekly plan.
   */
  app.patch('/my-plan', auth, async (request, reply) => {
    const userId = (request as any).user.userId
    const player = await prisma.playerProfile.findUnique({ where: { userId }, select: { id: true } })
    if (!player) return reply.code(404).send({ success: false, error: 'Player not found' })

    const bodySchema = z.object({
      name: z.string().trim().min(1, 'Plan name cannot be empty').optional(),
      days: z.array(planDayPatchSchema).min(1).optional(),
    }).superRefine((value, ctx) => {
      if (value.name === undefined && value.days === undefined) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          message: 'At least one field is required',
        })
      }
      if (value.days) uniqueWeekdayRefine(value.days, ctx)
    })

    try {
      const validated = bodySchema.parse(request.body)
      const data = await planSvc.patchPlan(player.id, validated as any)
      return reply.send({ success: true, data })
    } catch (err: any) {
      if (err instanceof z.ZodError) {
        return reply.code(422).send({ success: false, error: { code: 'VALIDATION_ERROR', details: err.errors } })
      }
      const statusCode = (err as any).statusCode || 500
      return reply.code(statusCode).send({ success: false, error: { message: err.message } })
    }
  })

  /**
   * GET /day-log/:date
   * Returns a daily execution record for the date. If none exists yet, creates it from weekly plan inheritance.
   */
  app.get('/day-log/:date', auth, async (request, reply) => {
    const userId = (request as any).user.userId
    const player = await prisma.playerProfile.findUnique({ where: { userId }, select: { id: true } })
    if (!player) return reply.code(404).send({ success: false, error: 'Player not found' })

    try {
      const { date } = dayLogDateParamsSchema.parse(request.params)
      const data = await executeSvc.getDayLog(player.id, date)
      return reply.send({ success: true, data })
    } catch (err: any) {
      if (err instanceof z.ZodError) {
        return reply.code(422).send({ success: false, error: { code: 'VALIDATION_ERROR', details: err.errors } })
      }
      const statusCode = (err as any).statusCode || 500
      return reply.code(statusCode).send({ success: false, error: { message: err.message } })
    }
  })

  /**
   * PATCH /day-log/:date/plan
   * Updates editable daily fields before final execution submit.
   */
  app.patch('/day-log/:date/plan', auth, async (request, reply) => {
    const userId = (request as any).user.userId
    const player = await prisma.playerProfile.findUnique({ where: { userId }, select: { id: true } })
    if (!player) return reply.code(404).send({ success: false, error: 'Player not found' })

    try {
      const { date } = dayLogDateParamsSchema.parse(request.params)
      const body = dayLogPlanPatchSchema.parse(request.body)
      const data = await executeSvc.patchDayPlan(player.id, date, body)
      return reply.send({ success: true, data })
    } catch (err: any) {
      if (err instanceof z.ZodError) {
        return reply.code(422).send({ success: false, error: { code: 'VALIDATION_ERROR', details: err.errors } })
      }
      const statusCode = (err as any).statusCode || 500
      return reply.code(statusCode).send({ success: false, error: { message: err.message } })
    }
  })

  /**
   * POST /day-log/:date/execute
   * Final daily execution submit: stores actuals/reflection, computes execution score, and locks the day.
   */
  app.post('/day-log/:date/execute', auth, async (request, reply) => {
    const userId = (request as any).user.userId
    const player = await prisma.playerProfile.findUnique({ where: { userId }, select: { id: true } })
    if (!player) return reply.code(404).send({ success: false, error: 'Player not found' })

    try {
      const { date } = dayLogDateParamsSchema.parse(request.params)
      const body = dayLogExecuteSchema.parse(request.body)
      const data = await executeSvc.submitExecution(player.id, date, body.execution)
      return reply.send({ success: true, data })
    } catch (err: any) {
      if (err instanceof z.ZodError) {
        return reply.code(422).send({ success: false, error: { code: 'VALIDATION_ERROR', details: err.errors } })
      }
      const statusCode = (err as any).statusCode || 500
      return reply.code(statusCode).send({ success: false, error: { message: err.message } })
    }
  })

  /**
   * GET /execute-summary
   * Returns execute KPIs for a time range (7d | 30d | month | all).
   */
  app.get('/execute-summary', auth, async (request, reply) => {
    const userId = (request as any).user.userId
    const player = await prisma.playerProfile.findUnique({ where: { userId }, select: { id: true } })
    if (!player) return reply.code(404).send({ success: false, error: 'Player not found' })

    try {
      const query = executeSummaryQuerySchema.parse(request.query)
      const data = await executeSvc.getExecuteSummary(player.id, query.range)
      return reply.send({ success: true, data })
    } catch (err: any) {
      if (err instanceof z.ZodError) {
        return reply.code(422).send({ success: false, error: { code: 'VALIDATION_ERROR', details: err.errors } })
      }
      const statusCode = (err as any).statusCode || 500
      return reply.code(statusCode).send({ success: false, error: { message: err.message } })
    }
  })

  /**
   * POST /player/:playerId/journal
   * THE 5-STEP ELITE JOURNAL: Logs training, mental, and recovery context.
   */
  app.post('/player/:playerId/journal', auth, async (request, reply) => {
    const { playerId } = request.params as { playerId: string }
    const bodySchema = z.object({
      date: z.string().refine((value) => !Number.isNaN(new Date(value).getTime()), 'Invalid date').optional().default(new Date().toISOString()),
      isCheatDay: z.boolean().optional().default(false),
      activity: z.object({
        type: z.enum(['NETS', 'SKILL_WORK', 'CONDITIONING', 'GYM', 'MATCH', 'RECOVERY']),
        durationMinutes: z.number().int().nonnegative(),
        intensity: z.number().int().min(1).max(10),
        drillIds: z.array(z.string()).default([]),
        notes: z.string().optional().nullable()
      }),
      mental: z.object({
        confidence: z.number().int().min(1).max(10),
        focus: z.number().int().min(1).max(10),
        resilience: z.number().int().min(1).max(10)
      }),
      context: z.object({
        sleepQuality: z.number().int().min(1).max(10),
        hydrationLiters: z.number().nonnegative(),
        soreness: z.number().int().min(1).max(10),
        fatigue: z.number().int().min(1).max(10),
        mood: z.number().int().min(1).max(10),
        stress: z.number().int().min(1).max(10)
      })
    })

    const validated = bodySchema.parse(request.body)
    const data = await journalSvc.logEntry(playerId, validated)
    return reply.send({ success: true, data })
  })

  /**
   * GET /player/:playerId/journal-streak
   * Returns day-wise streak + plan vs execution timeline for the last N days (max 30).
   */
  app.get('/player/:playerId/journal-streak', auth, async (request, reply) => {
    const { playerId } = request.params as { playerId: string }
    const query = z.object({
      days: z.coerce.number().int().min(1).max(30).optional(),
    }).parse(request.query)

    const [timeline, discipline] = await Promise.all([
      journalSvc.getJournalStreakTimeline(playerId, query.days ?? 30),
      planSvc.calculateDisciplineScore(playerId),
    ])

    return reply.send({
      success: true,
      data: {
        ...timeline,
        weekly: {
          disciplineScore: discipline.score,
          adherence: discipline.adherence,
        },
      },
    })
  })

  app.get('/player/:id/apex-state', auth, async (request, reply) => {
    const { id } = request.params as { id: string }
    const data = await apexStateSvc.getPlayerApexState(id)

    if (!data) {
      return reply.code(404).send({ status: 'error', message: 'Player not found' })
    }

    return reply.send(data)
  })

  /**
   * POST /player/:id/goal (or /players/:id/apex-goal)
   * THE PERFORMANCE AMBITION: Logs long-term cricket goals and health objectives.
   */
  const performanceGoalSchema = z.object({
    targetRole: z.string(),
    targetFormat: z.string(),
    styleIdentity: z.string(),
    targetLevel: z.string(),
    timeline: z.string(),
    focusAreas: z.array(z.string()).default([]),
    commitmentStatement: z.string().optional().nullable(),

    // Health & Fitness Extensions (validated per requirements)
    gender: z.enum(['male', 'female', 'other']).optional(),
    heightCm: z.number().min(100).max(250).optional(),
    weightKg: z.number().min(30).max(200).optional(),
    targetWeight: z.number().min(30).max(200).optional(),
    bodyTransformDirection: z.enum(['CUT', 'BULK', 'RECOMPOSE', 'MAINTAIN']).optional(),
    targetBodyFatPercent: z.number().min(3).max(50).optional(),
    waistCircumferenceCm: z.number().min(40).max(200).optional(),
    neckCircumferenceCm: z.number().min(20).max(80).optional(),
    hipCircumferenceCm: z.number().min(40).max(200).optional(),
    trainingDaysPerWeek: z.number().int().min(1).max(7).optional(),
    fitnessFocuses: z.array(z.string()).default([]),
    nutritionObjective: z.enum(['FAT_LOSS', 'MAINTENANCE', 'MUSCLE_GAIN', 'PERFORMANCE_FUELING']).optional(),
    dailySleepHoursGoal: z.number().min(4).max(12).optional(),
    dailyHydrationLitresGoal: z.number().min(1).max(6).optional(),
    morningWakeUpTime: z.string().regex(/^\d{2}:\d{2}$/, 'Format must be HH:MM').optional(),
    habitsToQuit: z.array(z.string()).default([]),
    disciplineGoals: z.array(z.string()).default([]),
  })

  app.post('/player/:id/goal', auth, async (request, reply) => {
    const { id: playerId } = request.params as { id: string }
    const payload = performanceGoalSchema.parse(request.body)

    // 1. Sync Profile Fields (gender, height, weight)
    const profileUpdate: any = {}
    if (payload.gender) profileUpdate.gender = payload.gender
    if (payload.heightCm) profileUpdate.heightCm = payload.heightCm
    if (payload.weightKg) profileUpdate.weightKg = payload.weightKg
    if (payload.waistCircumferenceCm) profileUpdate.waistCircumferenceCm = payload.waistCircumferenceCm
    if (payload.neckCircumferenceCm) profileUpdate.neckCircumferenceCm = payload.neckCircumferenceCm
    if (payload.hipCircumferenceCm) profileUpdate.hipCircumferenceCm = payload.hipCircumferenceCm

    const profile = await prisma.playerProfile.update({
      where: { id: playerId },
      data: profileUpdate,
    })

    // 2. Compute BMI
    let bmi: number | undefined
    if (profile.heightCm && profile.weightKg) {
      bmi = profile.weightKg / Math.pow(profile.heightCm / 100, 2)
    }

    // 2b. Compute Body Fat % (US Navy Method)
    let bodyFatPercent: number | undefined
    const h = profile.heightCm
    const w = profile.waistCircumferenceCm
    const n = profile.neckCircumferenceCm
    const hip = profile.hipCircumferenceCm
    const isMale = profile.gender?.toLowerCase() === 'male'

    if (h && w && n) {
      if (isMale) {
        // Men: 495 / (1.0324 - 0.19077 * log10(waist - neck) + 0.15456 * log10(height)) - 450
        bodyFatPercent = 495 / (1.0324 - 0.19077 * Math.log10(w - n) + 0.15456 * Math.log10(h)) - 450
      } else if (hip) {
        // Women: 495 / (1.29579 - 0.35004 * log10(waist + hip - neck) + 0.22100 * log10(height)) - 450
        bodyFatPercent = 495 / (1.29579 - 0.35004 * Math.log10(w + hip - n) + 0.22100 * Math.log10(h)) - 450
      }
      if (bodyFatPercent) bodyFatPercent = Math.round(bodyFatPercent * 10) / 10
    }

    // 3. Compute Daily Calorie Target (Mifflin-St Jeor)
    let dailyCalorieTarget: number | undefined
    if (profile.heightCm && profile.weightKg && profile.dateOfBirth && profile.gender && payload.trainingDaysPerWeek) {
      const age = new Date().getFullYear() - new Date(profile.dateOfBirth).getFullYear()
      let bmr = (10 * profile.weightKg) + (6.25 * profile.heightCm) - (5 * age)
      bmr = profile.gender.toLowerCase() === 'male' ? bmr + 5 : bmr - 161

      const multipliers: Record<number, number> = {
        1: 1.375, 2: 1.375,
        3: 1.55, 4: 1.55,
        5: 1.725, 6: 1.725,
        7: 1.9
      }
      const multiplier = multipliers[payload.trainingDaysPerWeek] || 1.2
      let tdee = bmr * multiplier

      if (payload.bodyTransformDirection === 'CUT') tdee -= 400
      else if (payload.bodyTransformDirection === 'BULK') tdee += 300

      dailyCalorieTarget = Math.round(tdee)
    }

    const data = await prisma.performanceAmbition.upsert({
      where: { playerId },
      update: { ...payload, bmi, bodyFatPercent, dailyCalorieTarget },
      create: { ...payload, playerId, bmi, bodyFatPercent, dailyCalorieTarget }
    })

    // 4. Trigger Smart Sync with Weekly Plan
    try {
      const planSvc = new ElitePlanService()
      await planSvc.reconcilePlanWithAmbition(playerId)
    } catch (err: any) {
      console.error(`[EliteRoutes] Failed to sync plan for ${playerId}:`, err.message)
    }

    return reply.send({ success: true, data })
  })

  /**
   * GET /player/:id/health-dashboard
   * Returns the Power 5 Elite Health Dashboard.
   */
  app.get('/player/:id/health-dashboard', auth, async (request, reply) => {
    const { id } = request.params as { id: string }
    const data = await healthSvc.getPower5Dashboard(id)
    return reply.send({ success: true, data })
  })

  /**
   * POST /performance/health/log
   * Unified logger for manual health and training activities.
   */
  app.post('/performance/health/log', auth, async (request, reply) => {
    const { userId } = request.user as { userId: string }
    const bodySchema = z.object({
      type: z.enum(['HYDRATION', 'GYM', 'NETS', 'SPRINTS', 'WEIGHT']),
      value: z.number().positive(),
      notes: z.string().optional(),
      date: z.string().datetime().optional(),
    })

    const validated = bodySchema.parse(request.body)
    const player = await performanceSvc.eliteAnalytics.getPlayerByUserId(userId)
    if (!player) {
      return reply.code(404).send({ success: false, error: 'Player profile not found' })
    }

    const data = await performanceSvc.logHealthActivity(player.id, validated)
    return reply.send({ success: true, data })
  })

  /**
   * GET /player/:id/profile
   * THE UNIFIED API: Returns everything for the elite profile page.
   */
  app.get('/player/:id/profile', async (request, reply) => {
    const { id } = request.params as { id: string }
    const { ballType = 'LEATHER' } = request.query as { ballType?: string }
    let viewerUserId: string | null = null

    if (request.headers.authorization) {
      try {
        await (request as any).jwtVerify()
        const user = (request as any).user as { userId?: string } | undefined
        viewerUserId = user?.userId ?? null
      } catch {
        viewerUserId = null
      }
    }

    const data = await analyticsSvc.getUnifiedProfile(id, viewerUserId, ballType)
    if (!data) {
      return reply.code(404).send({ error: 'Profile not found' })
    }

    return reply.send(data)
  })

  /**
   * GET /player/:id/analytics
   * Returns KPIs, skill matrix, highest score, win-first-bat context.
   */
  app.get('/player/:id/analytics', auth, async (request, reply) => {
    const { id } = request.params as { id: string }
    const { format, timeframe, ballType = 'LEATHER' } = request.query as any

    const data = await analyticsSvc.getPlayerAnalytics(id, { format, timeframe })
    if (!data) {
      return reply.code(404).send({ success: false, error: 'Player analytics not found' })
    }

    return reply.send({ success: true, data })
  })

  /**
   * GET /player/:id/stats-extended
   * Returns the complete 120-metric stats payload for the player.
   */
  app.get('/player/:id/stats-extended', async (request, reply) => {
    const { id } = request.params as { id: string }
    const { ballType = 'LEATHER' } = request.query as { ballType?: string }
    const data = await analyticsSvc.getExtendedStats120(id, ballType)
    if (!data) {
      return reply.code(404).send({ success: false, error: 'Player not found' })
    }
    return reply.send({ success: true, data })
  })

  /**
   * GET /player/:id/arena-performance
   * Returns performance breakdown across all arenas/facilities.
   */
  app.get('/player/:id/arena-performance', auth, async (request, reply) => {
    const { id } = request.params as { id: string }
    const data = await analyticsSvc.getArenaPerformance(id)
    return reply.send({ success: true, data })
  })

  /**
   * GET /player/:id/benchmarks
   * Returns comparison data against Peer/City averages.
   */
  app.get('/player/:id/benchmarks', auth, async (request, reply) => {
    const { id } = request.params as { id: string }
    const { scope } = request.query as any
    const data = await analyticsSvc.getBenchmarks(id, scope)
    return reply.send({ success: true, data })
  })

  /**
   * GET /player/:id/precision
   * Returns high-precision ball-level analytics (Death SR, Pace vs Spin).
   */
  app.get('/player/:id/precision', auth, async (request, reply) => {
    const { id } = request.params as { id: string }
    const data = await analyticsSvc.getHighPrecisionAnalytics(id)
    return reply.send({ success: true, data })
  })

  /**
   * GET /analytics/compare
   * Returns side-by-side comparison between two players.
   */
  app.get('/analytics/compare', auth, async (request, reply) => {
    const { player1, player2, format } = request.query as any
    if (!player1 || !player2) {
      return reply.code(400).send({ success: false, error: 'Missing player1 or player2 query parameters' })
    }
    const data = await analyticsSvc.comparePlayers(player1, player2, format)
    return reply.send({ success: true, data })
  })

  /**
   * GET /team/compare
   * Returns Projected Win Probability between two teams.
   */
  app.get('/team/compare', auth, async (request, reply) => {
    const { team1, team2 } = request.query as any
    if (!team1 || !team2) {
      return reply.code(400).send({ success: false, error: 'Missing team1 or team2 query parameters' })
    }
    const data = await analyticsSvc.getProjectedWinProbability(team1, team2)
    return reply.send({ success: true, data })
  })

  /**
   * GET /team/:id/analytics
   * Returns Team-level performance (Win Rate, Chasing Success, Fortresses).
   */
  app.get('/team/:id/analytics', auth, async (request, reply) => {
    const { id } = request.params as { id: string }
    try {
      const data = await analyticsSvc.getTeamAnalytics(id)
      if (!data) {
        return reply.code(404).send({ success: false, error: 'Team analytics not found' })
      }
      return reply.send({ success: true, data })
    } catch (err) {
      request.log.error({ err, teamId: id }, '[TeamAnalytics] getTeamAnalytics threw')
      // Return an empty-but-valid analytics shape so the app can render gracefully
      return reply.code(200).send({
        success: true,
        data: {
          teamId: id,
          teamName: '',
          summary: { matchesPlayed: 0, totalWins: 0, totalLosses: 0, totalTies: 0, winRate: 0, winStreak: 0, recentForm: [] },
          batting: { averageScore: 0, highestScore: 0, lowestScore: 0, teamBattingAverage: 0, totalRuns: 0, totalFours: 0, totalSixes: 0, dotBallPercentage: 0, scoringRate: 0 },
          bowling: { averageEconomy: 0, totalWickets: 0, averageWicketsPerMatch: 0, bowlingAverage: 0, bestBowling: null, dotBallPercentage: 0, extrasConcededAverage: 0 },
          topPerformers: { batsmen: [], bowlers: [] },
          matchContext: { tossImpact: { winRateWhenWonToss: 0, winRateWhenLostToss: 0 }, battingFirstWinRate: 0, chasingWinRate: 0, venuePerformance: [] },
          nrr: 0,
          headToHead: [],
          playerContribution: { runsPercentage: [], wicketsPercentage: [] },
          powerScore: { current: 0, basis: 'avgIP', eligiblePlayers: 0 },
          teamSI: 0,
        },
      })
    }
  })

  /**
   * POST /admin/trigger-challenge-check
   * Manually trigger badge detection for a specific match (Admin only)
   */
  app.post('/admin/trigger-challenge-check', auth, async (request, reply) => {
    const { matchId, playerId } = request.body as { matchId: string, playerId: string }
    const awards = await challengesSvc.detectAndAwardBadges(matchId, playerId)
    return reply.send({ success: true, awards })
  })

  /**
   * POST /admin/generate-snapshots
   * Generate daily performance snapshots for caching (Admin only).
   */
  app.post('/admin/generate-snapshots', auth, async (request, reply) => {
    const data = await analyticsSvc.generateDailySnapshots()
    return reply.send({ success: true, data })
  })

  /**
   * GET /player/:id/swot
   * Returns a detailed SWOT analysis for the player.
   */
  app.get('/player/:id/swot', auth, async (request, reply) => {
    const { id } = request.params as { id: string }
    const { ballType = 'LEATHER' } = request.query as { ballType?: string }
    const data = await analyticsSvc.getSwotAnalysis(id, ballType)
    return reply.send({ success: true, data })
  })

  /**
   * GET /player/:id/scouting/:opponentId
   * Returns a pre-match scouting report against a specific opponent team.
   */
  app.get('/player/:id/scouting/:opponentId', auth, async (request, reply) => {
    const { id, opponentId } = request.params as { id: string, opponentId: string }
    const { ballType = 'LEATHER' } = request.query as { ballType?: string }
    const data = await analyticsSvc.getScoutingReport(id, opponentId, ballType)
    return reply.send({ success: true, data })
  })
}
