import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { CurriculumService } from './curriculum.service'

export async function curriculumRoutes(app: FastifyInstance) {
  const svc = new CurriculumService()
  const auth = { onRequest: [(app as any).authenticate] }

  // POST /curriculum — create curriculum
  app.post('/', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = z.object({
      academyId: z.string(),
      name: z.string().min(2),
      targetAgeGroup: z.string().optional(),
      targetSkillLevel: z.string().optional(),
      sportFocus: z.string().optional(),
      description: z.string().optional(),
      totalWeeks: z.number().optional(),
    }).parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.createCurriculum(user.userId, body.academyId, body) })
  })

  // GET /curriculum?academyId=xxx — list curriculums
  app.get('/', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const q = z.object({ academyId: z.string() }).parse(request.query)
    return reply.send({ success: true, data: await svc.listCurriculums(user.userId, q.academyId) })
  })

  // GET /curriculum/:id
  app.get('/:id', auth, async (request, reply) => {
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getCurriculum(id) })
  })

  // POST /curriculum/:id/phases
  app.post('/:id/phases', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = z.object({
      phaseNumber: z.number(),
      name: z.string(),
      durationWeeks: z.number().optional(),
      description: z.string().optional(),
    }).parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.addPhase(user.userId, id, body) })
  })

  // POST /curriculum/phases/:phaseId/topics
  app.post('/phases/:phaseId/topics', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { phaseId } = request.params as { phaseId: string }
    const body = z.object({
      name: z.string(),
      sequence: z.number(),
      skillArea: z.string().optional(),
      subSkill: z.string().optional(),
      description: z.string().optional(),
      suggestedDrills: z.array(z.string()).optional(),
    }).parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.addTopic(user.userId, phaseId, body) })
  })

  // POST /curriculum/assign — assign curriculum to batch
  app.post('/assign', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = z.object({
      batchId: z.string(),
      curriculumId: z.string(),
      startDate: z.string(),
    }).parse(request.body)
    return reply.send({ success: true, data: await svc.assignToBatch(user.userId, body.batchId, body.curriculumId, body.startDate) })
  })

  // GET /curriculum/batch/:batchId — batch curriculum with progress
  app.get('/batch/:batchId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { batchId } = request.params as { batchId: string }
    return reply.send({ success: true, data: await svc.getBatchCurriculum(user.userId, batchId) })
  })

  // POST /curriculum/assignments/:id/complete/:topicId — mark topic complete
  app.post('/assignments/:id/complete/:topicId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id, topicId } = request.params as { id: string; topicId: string }
    const body = z.object({ coachNote: z.string().optional() }).parse(request.body)
    return reply.send({ success: true, data: await svc.markTopicComplete(user.userId, id, topicId, body.coachNote) })
  })

  // DELETE /curriculum/assignments/:id/complete/:topicId — unmark
  app.delete('/assignments/:id/complete/:topicId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id, topicId } = request.params as { id: string; topicId: string }
    return reply.send({ success: true, data: await svc.unmarkTopicComplete(user.userId, id, topicId) })
  })
}
