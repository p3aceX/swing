import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { ArenaService } from './arena.service'

const timePattern = /^\d{2}:\d{2}$/

const createArenaSchema = z.object({
  // Owner profile
  businessName: z.string().optional(),
  gstNumber: z.string().optional(),
  panNumber: z.string().optional(),
  // Arena details
  name: z.string().min(2),
  description: z.string().optional().nullable(),
  address: z.string().optional(),
  city: z.string(),
  state: z.string(),
  pincode: z.string().optional(),
  latitude: z.number().optional().nullable(),
  longitude: z.number().optional().nullable(),
  phone: z.string().min(10).max(15).optional().nullable(),
  sports: z.array(z.enum(['CRICKET', 'FUTSAL', 'PICKLEBALL', 'BADMINTON', 'FOOTBALL', 'TENNIS', 'BASKETBALL', 'OTHER'])).default(['CRICKET']),
  photoUrls: z.array(z.string()).default([]),
  hasParking: z.boolean().default(false),
  hasLights: z.boolean().default(false),
  hasWashrooms: z.boolean().default(false),
  hasCanteen: z.boolean().default(false),
  hasCCTV: z.boolean().default(false),
  hasScorer: z.boolean().default(false),
})

const addManagerSchema = z.object({
  name: z.string().min(2),
  phone: z.string().min(10),
})

const addUnitSchema = z.object({
  name: z.string().trim().min(1),
  unitType: z.enum(['FULL_GROUND', 'HALF_GROUND', 'TURF', 'CRICKET_NET', 'INDOOR_NET', 'CENTER_WICKET', 'MULTI_SPORT', 'OTHER']),
  unitTypeLabel: z.string().trim().max(80).optional(),
  netType: z.string().trim().max(80).optional(),
  sport: z.enum(['CRICKET', 'FUTSAL', 'PICKLEBALL', 'BADMINTON', 'FOOTBALL', 'TENNIS', 'BASKETBALL', 'OTHER']).optional(),
  description: z.string().trim().max(500).optional(),
  pricePerHourPaise: z.number().int().min(0),
  peakPricePaise: z.number().int().min(0).optional(),
  peakHoursStart: z.string().regex(timePattern).optional(),
  peakHoursEnd: z.string().regex(timePattern).optional(),
  price4HrPaise: z.number().int().min(0).optional(),
  price8HrPaise: z.number().int().min(0).optional(),
  priceFullDayPaise: z.number().int().min(0).optional(),
  minBulkDays: z.number().int().min(2).optional().nullable(),
  bulkDayRatePaise: z.number().int().min(0).optional().nullable(),
  monthlyPassEnabled: z.boolean().default(false),
  monthlyPassRatePaise: z.number().int().min(0).optional().nullable(),
  weekendMultiplier: z.number().min(0).max(5).optional(),
  minSlotMins: z.number().int().default(60),
  maxSlotMins: z.number().int().default(240),
  slotIncrementMins: z.number().int().default(60),
  boundarySize: z.number().int().min(0).optional(),
  openTime: z.string().regex(timePattern).optional(),
  closeTime: z.string().regex(timePattern).optional(),
  operatingDays: z.array(z.number().int().min(1).max(7)).default([]),
  hasFloodlights: z.boolean().default(false),
  minAdvancePaise: z.number().int().min(0).optional(),
  advanceBookingDays: z.number().int().min(0).optional().nullable(),
  cancellationHours: z.number().int().min(0).optional().nullable(),
  parentUnitId: z.string().optional().nullable(),
  turnaroundMins: z.number().int().min(0).optional(),
  netVariants: z.array(z.object({
    type: z.string().trim().min(1),
    label: z.string().trim().min(1),
    count: z.number().int().min(1).default(1),
    pricePaise: z.number().int().min(0).optional(),
    monthlyPassRatePaise: z.number().int().min(0).optional().nullable(),
  })).optional().nullable(),
})

const updateUnitSchema = addUnitSchema.partial().extend({
  isActive: z.boolean().optional(),
})

const addonSchema = z.object({
  unitId: z.string().optional(),
  name: z.string().trim().min(1),
  addonType: z.string().trim().max(80).optional(),
  description: z.string().trim().max(300).optional(),
  pricePaise: z.number().int().min(0),
  unit: z.string().trim().min(1).default('per_session'),
  isAvailable: z.boolean().optional(),
})

const arenaTimeBlockSchema = z.object({
  unitId: z.string(),
  date: z.string().optional(),
  weekdays: z.array(z.number().int().min(1).max(7)).default([]),
  startTime: z.string().regex(timePattern),
  endTime: z.string().regex(timePattern),
  reason: z.string().trim().min(1).max(120).optional(),
  isHoliday: z.boolean().default(false),
}).superRefine((value, ctx) => {
  if (!value.date && value.weekdays.length === 0) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      path: ['date'],
      message: 'Either date or weekdays is required',
    })
  }
  if (value.date && value.weekdays.length > 0) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      path: ['weekdays'],
      message: 'Use either date or weekdays, not both',
    })
  }
  // skip time-order check for holidays (00:00–23:59 is always valid)
  if (!value.isHoliday && value.startTime >= value.endTime) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      path: ['endTime'],
      message: 'endTime must be after startTime',
    })
  }
})

const updateArenaSchema = createArenaSchema.partial().extend({
  customSlug: z.string().min(3).max(60).optional().nullable(),
  isPublicPage: z.boolean().optional(),
  openTime: z.string().regex(timePattern).optional().nullable(),
  closeTime: z.string().regex(timePattern).optional().nullable(),
  operatingDays: z.array(z.number().int().min(1).max(7)).optional(),
  advanceBookingDays: z.number().int().optional().nullable(),
  bufferMins: z.number().int().optional().nullable(),
  cancellationHours: z.number().int().optional().nullable(),
})

const arenaTimeBlockQuerySchema = z.object({
  date: z.string().optional(),
  unitId: z.string().optional(),
  recurringOnly: z.enum(['true', 'false']).optional(),
})

const monthlyPassSchema = z.object({
  unitId: z.string(),
  guestName: z.string().trim().min(1),
  guestPhone: z.string().trim().min(10),
  startTime: z.string().regex(timePattern),
  endTime: z.string().regex(timePattern),
  daysOfWeek: z.array(z.number().int().min(1).max(7)).min(1),
  startDate: z.string(), // YYYY-MM-DD
  endDate: z.string(),   // YYYY-MM-DD
  totalAmountPaise: z.number().int().min(0),
  advancePaise: z.number().int().min(0).default(0),
  paymentMode: z.enum(['CASH', 'UPI', 'ONLINE']).default('CASH'),
  notes: z.string().trim().max(300).optional(),
})

export async function arenaRoutes(app: FastifyInstance) {
  const svc = new ArenaService()
  const auth = { onRequest: [(app as any).authenticate] }

  // ─── Unit Management (Unique paths to avoid :id collisions) ──────────────

  app.patch('/u/:unitId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { unitId } = request.params as { unitId: string }
    const body = updateUnitSchema.parse(request.body)
    return reply.send({ success: true, data: await svc.updateUnit(unitId, user.userId, body) })
  })

  app.delete('/u/:unitId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { unitId } = request.params as { unitId: string }
    await svc.deleteUnit(unitId, user.userId)
    return reply.send({ success: true })
  })

  app.delete('/blocks/:blockId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { blockId } = request.params as { blockId: string }
    await svc.deleteTimeBlock(blockId, user.userId)
    return reply.send({ success: true })
  })

  // ─── Arena Management ─────────────────────────────────────────────────────

  app.post('/', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = createArenaSchema.parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.createArena(user.userId, body) })
  })

  app.get('/', async (request, reply) => {
    const q = request.query as {
      city?: string
      search?: string
      lat?: string
      lng?: string
      radius?: string
      radiusKm?: string
      sport?: string
      page?: string
      limit?: string
    }
    return reply.send({
      success: true,
      data: await svc.listArenas({
        city: q.city,
        search: q.search,
        lat: q.lat ? Number(q.lat) : undefined,
        lng: q.lng ? Number(q.lng) : undefined,
        radiusKm: q.radiusKm ? Number(q.radiusKm) : q.radius ? Number(q.radius) : undefined,
        sport: q.sport,
        page: Number(q.page) || 1,
        limit: Number(q.limit) || 20,
      }),
    })
  })

  app.get('/mine', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.listOwnedArenas(user.userId) })
  })

  app.post('/:id/units', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = addUnitSchema.parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.addUnit(id, user.userId, body) })
  })

  app.get('/:id/addons', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const query = request.query as { unitId?: string }
    return reply.send({ success: true, data: await svc.listAddons(id, user.userId, query.unitId) })
  })

  app.post('/:id/addons', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = addonSchema.parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.createAddon(id, user.userId, body) })
  })

  app.patch('/addons/:addonId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { addonId } = request.params as { addonId: string }
    const body = addonSchema.partial().parse(request.body)
    return reply.send({ success: true, data: await svc.updateAddon(addonId, user.userId, body) })
  })

  app.delete('/addons/:addonId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { addonId } = request.params as { addonId: string }
    await svc.deleteAddon(addonId, user.userId)
    return reply.send({ success: true })
  })

  app.get('/:id/blocks', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const query = arenaTimeBlockQuerySchema.parse(request.query)
    return reply.send({
      success: true,
      data: await svc.listTimeBlocks(id, user.userId, query),
    })
  })

  app.post('/:id/blocks', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = arenaTimeBlockSchema.parse(request.body)
    return reply.code(201).send({
      success: true,
      data: await svc.createTimeBlock(id, user.userId, body),
    })
  })

  app.get('/:id', async (request, reply) => {
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getArena(id) })
  })

  app.put('/:id', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = updateArenaSchema.parse(request.body)
    return reply.send({ success: true, data: await svc.updateArena(id, user.userId, body) })
  })

  app.delete('/:id', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    await svc.deleteArena(id, user.userId)
    return reply.send({ success: true })
  })

  app.get('/:id/slots', async (request, reply) => {
    const { id } = request.params as { id: string }
    const q = request.query as { date: string; durationMins?: string }
    if (!q.date) return reply.code(400).send({ success: false, error: { code: 'MISSING_DATE', message: 'date query param required' } })
    const durationMins = q.durationMins ? parseInt(q.durationMins, 10) : 60
    if (Number.isNaN(durationMins) || durationMins < 30) {
      return reply.code(400).send({ success: false, error: { code: 'INVALID_DURATION', message: 'durationMins must be >= 30' } })
    }
    return reply.send({ success: true, data: await svc.getPlayerSlots(id, q.date, durationMins) })
  })

  app.get('/:id/booking-context', async (request, reply) => {
    const { id } = request.params as { id: string }
    const q = request.query as { date: string; durationMins?: string; includeAvailability?: string }
    if (!q.date) {
      return reply
        .code(400)
        .send({ success: false, error: { code: 'MISSING_DATE', message: 'date query param required' } })
    }
    const durationMins = q.durationMins ? parseInt(q.durationMins, 10) : 60
    if (Number.isNaN(durationMins) || durationMins < 30) {
      return reply
        .code(400)
        .send({ success: false, error: { code: 'INVALID_DURATION', message: 'durationMins must be >= 30' } })
    }
    const includeAvailability =
      q.includeAvailability === '1' || q.includeAvailability?.toLowerCase() === 'true'
    return reply.send({
      success: true,
      data: await svc.getBookingContext(id, q.date, durationMins, includeAvailability),
    })
  })

  app.get('/:id/availability', async (request, reply) => {
    const { id } = request.params as { id: string }
    const q = request.query as { date: string; unitId?: string }
    if (!q.date) return reply.code(400).send({ success: false, error: { code: 'MISSING_DATE', message: 'date query param required' } })
    return reply.send({ success: true, data: await svc.getAvailability(id, q.date, q.unitId) })
  })

  app.get('/:id/stats', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getArenaStats(id, user.userId) })
  })

  app.post('/:id/managers', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = addManagerSchema.parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.addManager(id, user.userId, body) })
  })

  // ─── Monthly Passes ───────────────────────────────────────────────────────

  app.post('/:id/monthly-passes', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = monthlyPassSchema.parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.createMonthlyPass(id, user.userId, body) })
  })

  app.get('/:id/monthly-passes', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const q = request.query as { month?: string; status?: string }
    return reply.send({ success: true, data: await svc.listMonthlyPasses(id, user.userId, q) })
  })

  app.get('/monthly-passes/:passId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { passId } = request.params as { passId: string }
    return reply.send({ success: true, data: await svc.getMonthlyPass(passId, user.userId) })
  })

  app.post('/monthly-passes/:passId/cancel', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { passId } = request.params as { passId: string }
    return reply.send({ success: true, data: await svc.cancelMonthlyPass(passId, user.userId) })
  })
}
