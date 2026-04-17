import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { PayrollService } from './payroll.service'

export async function payrollRoutes(app: FastifyInstance) {
  const svc = new PayrollService()
  const auth = { onRequest: [(app as any).authenticate] }

  // GET /payroll/:academyId/dashboard
  app.get('/:academyId/dashboard', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { academyId } = request.params as { academyId: string }
    return reply.send({ success: true, data: await svc.getPayrollDashboard(user.userId, academyId) })
  })

  // GET /payroll/:academyId/compensations
  app.get('/:academyId/compensations', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { academyId } = request.params as { academyId: string }
    return reply.send({ success: true, data: await svc.listCompensations(user.userId, academyId) })
  })

  // POST /payroll/:academyId/compensations — set coach compensation
  app.post('/:academyId/compensations', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { academyId } = request.params as { academyId: string }
    const body = z.object({
      coachId: z.string(),
      compensationType: z.enum(['FIXED_MONTHLY', 'PER_SESSION', 'PER_BATCH', 'FIXED_PLUS_INCENTIVE', 'REVENUE_SHARE']),
      fixedAmountPaise: z.number().optional(),
      perSessionAmountPaise: z.number().optional(),
      perBatchAmountPaise: z.number().optional(),
      incentiveRules: z.object({}).passthrough().optional(),
      revenueSharePercent: z.number().min(0).max(100).optional(),
      payoutCycle: z.enum(['MONTHLY', 'FORTNIGHTLY']).optional(),
      payoutDay: z.number().min(1).max(28).optional(),
    }).parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.setCoachCompensation(user.userId, academyId, body.coachId, body) })
  })

  // GET /payroll/:academyId/calculate?coachId=&periodStart=&periodEnd=
  app.get('/:academyId/calculate', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { academyId } = request.params as { academyId: string }
    const q = z.object({
      coachId: z.string(),
      periodStart: z.string(),
      periodEnd: z.string(),
    }).parse(request.query)
    return reply.send({ success: true, data: await svc.calculatePayout(user.userId, academyId, q.coachId, q.periodStart, q.periodEnd) })
  })

  // GET /payroll/:academyId/payouts
  app.get('/:academyId/payouts', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { academyId } = request.params as { academyId: string }
    const q = request.query as { status?: string }
    return reply.send({ success: true, data: await svc.listPayouts(user.userId, academyId, q.status) })
  })

  // POST /payroll/:academyId/payouts — create payout record
  app.post('/:academyId/payouts', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { academyId } = request.params as { academyId: string }
    const body = z.object({
      coachId: z.string(),
      periodStart: z.string(),
      periodEnd: z.string(),
      sessionsCount: z.number(),
      batchesCount: z.number(),
      attendanceCompliance: z.number(),
      baseAmountPaise: z.number(),
      incentiveAmountPaise: z.number().optional(),
      oneOnOneSharePaise: z.number().optional(),
      deductionPaise: z.number().optional(),
      notes: z.string().optional(),
    }).parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.createPayoutRecord(user.userId, academyId, body) })
  })

  // PATCH /payroll/payouts/:payoutId/pay
  app.patch('/payouts/:payoutId/pay', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { payoutId } = request.params as { payoutId: string }
    const body = z.object({ academyId: z.string(), paymentRef: z.string().optional() }).parse(request.body)
    return reply.send({ success: true, data: await svc.markPayoutPaid(user.userId, body.academyId, payoutId, body.paymentRef) })
  })

  // GET /payroll/my — coach's own payout history
  app.get('/my', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.getCoachPayoutHistory(user.userId) })
  })

  // GET /payroll/my-summary — coach payroll summary
  app.get('/my-summary', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.getCoachPayrollSummary(user.userId) })
  })
}
