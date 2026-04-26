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
  description: z.string().optional(),
  address: z.string().optional(),
  city: z.string(),
  state: z.string(),
  pincode: z.string().optional(),
  latitude: z.number().optional(),
  longitude: z.number().optional(),
  phone: z.string().optional(),
  sports: z.array(z.enum(['CRICKET', 'FUTSAL', 'PICKLEBALL', 'BADMINTON', 'FOOTBALL', 'OTHER'])).default(['CRICKET']),
  photoUrls: z.array(z.string()).default([]),
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
  sport: z.enum(['CRICKET', 'FUTSAL', 'PICKLEBALL', 'BADMINTON', 'FOOTBALL', 'OTHER']).optional(),
  description: z.string().trim().max(500).optional(),
  photoUrls: z.array(z.string().url()).max(3).default([]),
  pricePerHourPaise: z.number().int().min(0),
  peakPricePaise: z.number().int().min(0).optional(),
  peakHoursStart: z.string().regex(timePattern).optional(),
  peakHoursEnd: z.string().regex(timePattern).optional(),
  price4HrPaise: z.number().int().min(0).optional(),
  price8HrPaise: z.number().int().min(0).optional(),
  priceFullDayPaise: z.number().int().min(0).optional(),
  weekendMultiplier: z.number().min(0).max(5).optional(),
  minSlotMins: z.number().int().default(60),
  maxSlotMins: z.number().int().default(240),
  slotIncrementMins: z.number().int().default(60),
  boundarySize: z.number().int().min(0).optional(),
  openTime: z.string().regex(timePattern).optional(),
  closeTime: z.string().regex(timePattern).optional(),
  operatingDays: z.array(z.number().int().min(1).max(7)).default([]),
  hasFloodlights: z.boolean().default(false),
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
  if (value.startTime >= value.endTime) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      path: ['endTime'],
      message: 'endTime must be after startTime',
    })
  }
})

const arenaTimeBlockQuerySchema = z.object({
  date: z.string().optional(),
  unitId: z.string().optional(),
  recurringOnly: z.enum(['true', 'false']).optional(),
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
    return reply.send({ success: true, data: await svc.updateArena(id, user.userId, request.body) })
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
}
