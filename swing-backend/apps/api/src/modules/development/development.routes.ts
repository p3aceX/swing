import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { prisma } from '@swing/db'
import { DevelopmentService } from './development.service'
import { ElitePlanService } from '../performance/elite-plan.service'

const signalSchema = z.object({
  overallSignal: z.enum(['LOOKING_GOOD', 'NEEDS_WORK', 'WATCH_CLOSELY']).nullable().optional(),
  strengthSkillIds: z.array(z.string()).optional(),
  workOnSkillIds: z.array(z.string()).optional(),
  watchFlagIds: z.array(z.string()).optional(),
  followUpInDays: z.union([z.literal(2), z.literal(3), z.literal(5), z.literal(7), z.literal(14)]).nullable().optional(),
  coachNote: z.string().max(140).optional(),
})

export async function developmentRoutes(app: FastifyInstance) {
  const svc = new DevelopmentService()
  const auth = { onRequest: [(app as any).authenticate] }

  app.get('/session-types', auth, async (_request, reply) => {
    return reply.send({ success: true, data: await svc.listSessionTypes() })
  })

  app.get('/skill-areas', auth, async (request, reply) => {
    const q = z.object({ roleTag: z.string().optional() }).parse(request.query)
    return reply.send({ success: true, data: await svc.listSkillAreas(q.roleTag) })
  })

  app.get('/watch-flags', auth, async (request, reply) => {
    const q = z.object({ roleTag: z.string().optional() }).parse(request.query)
    return reply.send({ success: true, data: await svc.listWatchFlags(q.roleTag) })
  })

  app.get('/players/:id/signals', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getPlayerSignals(id, user.userId) })
  })

  app.get('/players/:id/drill-assignments', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getPlayerDrillAssignments(id, user.userId) })
  })

  app.get('/players/:id/card', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getPlayerCard(id, user.userId) })
  })

  app.get('/players/:id/weekly-review', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getWeeklyReview(id, user.userId) })
  })

  app.get('/drills', auth, async (request, reply) => {
    const q = z.object({
      role: z.string().optional(),
      category: z.string().optional(),
      includeInactive: z.coerce.boolean().optional(),
    }).parse(request.query)
    return reply.send({ success: true, data: await svc.listDrills(q) })
  })

  app.post('/drills', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = z.object({
      name: z.string().min(2),
      description: z.string().optional(),
      roleTags: z.array(z.enum(['BATSMAN', 'BOWLER', 'ALL_ROUNDER', 'FIELDER', 'WICKET_KEEPER'])).min(1),
      category: z.enum(['TECHNIQUE', 'FITNESS', 'MENTAL', 'MATCH_SIMULATION']),
      targetUnit: z.enum(['BALLS', 'OVERS', 'MINUTES', 'REPS', 'SESSIONS']),
      skillArea: z.string().optional(),
      isActive: z.boolean().optional(),
    }).parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.createDrill(user.userId, body) })
  })

  app.post('/drill-assignments', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = z.object({
      sessionId: z.string().optional(),
      playerId: z.string(),
      drillId: z.string(),
      targetQuantity: z.number().int().positive(),
      targetUnit: z.enum(['BALLS', 'OVERS', 'MINUTES', 'REPS', 'SESSIONS']),
    }).parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.assignDrill(user.userId, body) })
  })

  app.post('/drill-assignments/:id/log', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = z.object({ quantityDone: z.number().int().positive() }).parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.logDrillProgress(id, user.userId, body.quantityDone) })
  })

  app.get('/drill-assignments/:id/progress', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getDrillProgress(id, user.userId) })
  })

  app.post('/sessions/:id/signals/:playerId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id, playerId } = request.params as { id: string; playerId: string }
    const body = signalSchema.parse(request.body)
    return reply.send({ success: true, data: await svc.saveSignal(id, playerId, user.userId, body) })
  })

  /**
   * THE PERFORMANCE AMBITION / APEX GOAL: Logs long-term cricket goals and health objectives.
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

  app.post('/players/:id/apex-goal', auth, async (request, reply) => {
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
      console.error(`[DevRoutes] Failed to sync plan for ${playerId}:`, err.message)
    }

    return reply.send({ success: true, data })
  })
}
