import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { SessionLogService, STRENGTH_CHIPS } from './session-log.service'

const studentLogSchema = z.object({
  enrollmentId: z.string(),
  playerProfileId: z.string(),
  strengthChips: z.array(z.string()).default([]),
  weaknessChips: z.array(z.string()).default([]),
  currentFocusArea: z.string().optional(),
  effortRating: z.number().min(1).max(5).optional(),
  coachNote: z.string().optional(),
  drillRecommended: z.string().optional(),
  followUpNeeded: z.boolean().default(false),
  oneOnOneRecommended: z.boolean().default(false),
})

export async function sessionLogRoutes(app: FastifyInstance) {
  const svc = new SessionLogService()
  const auth = { onRequest: [(app as any).authenticate] }

  // POST /session-logs — coach logs a session (create or update)
  app.post('/', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = z.object({
      academyId: z.string(),
      batchId: z.string(),
      sessionDate: z.string(),
      overallNote: z.string().optional(),
      sessionId: z.string().optional(),
      studentLogs: z.array(studentLogSchema).min(1),
    }).parse(request.body)

    return reply.code(201).send({
      success: true,
      data: await svc.logSession(
        user.userId,
        body.academyId,
        body.batchId,
        body.sessionDate,
        body.overallNote,
        body.studentLogs,
        body.sessionId,
      ),
    })
  })

  // GET /session-logs/:id — get a specific session log
  app.get('/:id', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getSessionLog(id, user.userId) })
  })

  // GET /session-logs/batch/:academyId/:batchId — batch session log history
  app.get('/batch/:academyId/:batchId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { academyId, batchId } = request.params as { academyId: string; batchId: string }
    const q = request.query as { limit?: string }
    return reply.send({
      success: true,
      data: await svc.getBatchSessionLogs(user.userId, academyId, batchId, Number(q.limit) || 20),
    })
  })

  // GET /session-logs/student/:enrollmentId/insights — student development insights
  app.get('/student/:enrollmentId/insights', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { enrollmentId } = request.params as { enrollmentId: string }
    const q = request.query as { limit?: string }
    return reply.send({
      success: true,
      data: await svc.getStudentInsights(user.userId, enrollmentId, Number(q.limit) || 10),
    })
  })

  // GET /session-logs/batch/:academyId/:batchId/insights — batch-level insights
  app.get('/batch/:academyId/:batchId/insights', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { academyId, batchId } = request.params as { academyId: string; batchId: string }
    return reply.send({
      success: true,
      data: await svc.getBatchInsights(user.userId, academyId, batchId),
    })
  })

  // GET /session-logs/academy/:academyId/development — club oversight: all students overview
  app.get('/academy/:academyId/development', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { academyId } = request.params as { academyId: string }
    return reply.send({
      success: true,
      data: await svc.getAcademyDevelopmentOverview(user.userId, academyId),
    })
  })

  // GET /session-logs/student/:playerProfileId/:academyId/skill-matrix
  app.get('/student/:playerProfileId/:academyId/skill-matrix', auth, async (request, reply) => {
    const { playerProfileId, academyId } = request.params as { playerProfileId: string; academyId: string }
    return reply.send({
      success: true,
      data: await svc.getSkillMatrix(playerProfileId, academyId),
    })
  })

  // GET /session-logs/chips — return all available chips
  app.get('/chips', async (_request, reply) => {
    return reply.send({ success: true, data: STRENGTH_CHIPS })
  })
}
