import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { AcademyService } from './academy.service'

const createAcademySchema = z.object({
  name: z.string().min(2).max(100),
  description: z.string().optional(),
  city: z.string().min(2),
  state: z.string().min(2),
  address: z.string().optional(),
  pincode: z.string().optional(),
  latitude: z.number().optional(),
  longitude: z.number().optional(),
  phone: z.string().optional(),
  email: z.string().email().optional(),
  websiteUrl: z.string().url().optional(),
})

export async function academyRoutes(app: FastifyInstance) {
  const svc = new AcademyService()
  const auth = { onRequest: [(app as any).authenticate] }

  app.get('/my', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const academy = await svc.getMyAcademy(user.userId)
    return reply.send({ success: true, data: academy })
  })

  app.post('/', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = createAcademySchema.parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.createAcademy(user.userId, body) })
  })

  app.get('/:id', async (request, reply) => {
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getAcademy(id) })
  })

  app.put('/:id', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.updateAcademy(id, user.userId, request.body) })
  })

  app.post('/:id/coaches', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = z.object({ phone: z.string().min(10), isHeadCoach: z.boolean().default(false) }).parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.inviteCoach(id, user.userId, body.phone, body.isHeadCoach) })
  })

  app.patch('/:id/coaches/:coachLinkId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id, coachLinkId } = request.params as { id: string; coachLinkId: string }
    const body = z.object({
      isHeadCoach: z.boolean().optional(),
      isActive: z.boolean().optional(),
    }).parse(request.body)
    return reply.send({ success: true, data: await svc.updateCoachLink(id, user.userId, coachLinkId, body) })
  })

  app.post('/:id/batches/:batchId/coaches', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id, batchId } = request.params as { id: string; batchId: string }
    const body = z.object({ coachId: z.string() }).parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.addCoachToBatch(id, user.userId, batchId, body.coachId) })
  })

  app.post('/:id/batches', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = z.object({ name: z.string(), ageGroup: z.string().optional(), maxStudents: z.number().default(20), sport: z.string().default('CRICKET'), description: z.string().optional() }).parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.createBatch(id, user.userId, body) })
  })

  app.get('/:id/batches', auth, async (request, reply) => {
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.listBatches(id) })
  })

  app.post('/:id/batches/:batchId/students', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id, batchId } = request.params as { id: string; batchId: string }
    const body = z.object({
      phone: z.string().min(10),
      name: z.string().min(2),
      isTrial: z.boolean().default(false),
      feeAmountPaise: z.number().optional(),
      feeFrequency: z.enum(['MONTHLY', 'QUARTERLY', 'YEARLY', 'ONE_TIME']).optional(),
      initialPaymentPaise: z.number().optional(),
      initialPaymentMode: z.enum(['CASH', 'UPI', 'CARD', 'BANK_TRANSFER', 'CHEQUE']).optional(),
      bloodGroup: z.string().optional(),
      aadhaarLast4: z.string().length(4).optional(),
      emergencyContactName: z.string().optional(),
      emergencyContactPhone: z.string().optional(),
      dateOfBirth: z.string().optional(),
      city: z.string().optional(),
    }).parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.enrollStudent(id, user.userId, body.phone, body.name, batchId, body.isTrial, body) })
  })

  app.patch('/:id/students/:enrollmentId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id, enrollmentId } = request.params as { id: string; enrollmentId: string }
    const body = z.object({
      batchId: z.string().nullish(),
      feeAmountPaise: z.number().nullish(),
      feeFrequency: z.enum(['MONTHLY', 'QUARTERLY', 'YEARLY', 'ONE_TIME']).nullish(),
      feeStatus: z.enum(['UNPAID', 'PAID', 'OVERDUE']).optional(),
      notes: z.string().nullish(),
      bloodGroup: z.string().nullish(),
      aadhaarLast4: z.string().length(4).nullish(),
      emergencyContactName: z.string().nullish(),
      emergencyContactPhone: z.string().nullish(),
      dateOfBirth: z.string().nullish(),
      city: z.string().nullish(),
    }).parse(request.body)
    return reply.send({ success: true, data: await svc.updateStudent(id, user.userId, enrollmentId, body) })
  })

  app.get('/:id/students', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const q = request.query as { page?: string; limit?: string }
    return reply.send({ success: true, data: await svc.listStudents(id, user.userId, Number(q.page) || 1, Number(q.limit) || 20) })
  })

  app.get('/:id/sessions', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const q = z.object({
      from: z.string().datetime().optional(),
      to: z.string().datetime().optional(),
      batchId: z.string().optional(),
    }).parse(request.query)
    return reply.send({ success: true, data: await svc.getSessions(id, user.userId, q) })
  })

  app.get('/:id/attendance-report', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const q = z.object({
      from: z.string().datetime().optional(),
      to: z.string().datetime().optional(),
      batchId: z.string().optional(),
    }).parse(request.query)
    return reply.send({ success: true, data: await svc.getAttendanceReport(id, user.userId, q) })
  })

  app.post('/:id/fee-structures', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = z.object({ name: z.string(), amountPaise: z.number().positive(), frequency: z.enum(['MONTHLY', 'QUARTERLY', 'ANNUAL', 'ONE_TIME']), batchId: z.string().optional(), dueDayOfMonth: z.number().min(1).max(28).default(1) }).parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.createFeeStructure(id, user.userId, body) })
  })

  app.get('/:id/fee-payments', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const q = request.query as { page?: string; limit?: string }
    return reply.send({ success: true, data: await svc.getFeePayments(id, user.userId, Number(q.page) || 1, Number(q.limit) || 20) })
  })

  app.post('/:id/fee-payments/:paymentId/remind', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { paymentId } = request.params as { paymentId: string }
    return reply.send({ success: true, data: await svc.sendFeeReminder(paymentId, user.userId) })
  })

  app.post('/:id/fee-payments', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = z.object({
      enrollmentId: z.string(),
      amountPaise: z.number().positive(),
      paymentMode: z.enum(['CASH', 'UPI', 'CARD', 'BANK_TRANSFER', 'CHEQUE']).optional(),
      notes: z.string().optional(),
      paidAt: z.string().datetime().optional(),
    }).parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.recordFeePayment(id, user.userId, body) })
  })

  app.post('/:id/announcements', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = z.object({ title: z.string(), body: z.string(), targetGroup: z.string().default('ALL'), isPinned: z.boolean().default(false), sentVia: z.array(z.string()).default(['PUSH']) }).parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.createAnnouncement(id, user.userId, body) })
  })

  app.get('/:id/inventory', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getInventory(id, user.userId) })
  })

  app.post('/:id/inventory', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.code(201).send({ success: true, data: await svc.addInventoryItem(id, user.userId, request.body) })
  })

  app.patch('/:id/batches/:batchId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id, batchId } = request.params as { id: string; batchId: string }
    const body = z.object({
      name: z.string().optional(),
      ageGroup: z.string().nullish(),
      maxStudents: z.number().optional(),
      description: z.string().nullish(),
      isActive: z.boolean().optional(),
    }).parse(request.body)
    return reply.send({ success: true, data: await svc.updateBatch(id, user.userId, batchId, body) })
  })

  app.post('/:id/batches/:batchId/schedules', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id, batchId } = request.params as { id: string; batchId: string }
    const body = z.object({
      dayOfWeek: z.number().min(0).max(6),
      startTime: z.string(),
      endTime: z.string(),
      groundNote: z.string().optional(),
    }).parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.addBatchSchedule(id, user.userId, batchId, body) })
  })

  app.delete('/:id/batches/:batchId/schedules/:scheduleId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id, scheduleId } = request.params as { id: string; batchId: string; scheduleId: string }
    await svc.removeBatchSchedule(id, user.userId, scheduleId)
    return reply.send({ success: true, data: { message: 'Schedule removed' } })
  })
}
