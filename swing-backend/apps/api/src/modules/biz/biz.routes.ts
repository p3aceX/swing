import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { BizService } from './biz.service'

const businessDetailsSchema = z.object({
  businessName: z.string().min(2).max(120),
  contactName: z.string().min(2).max(100).optional(),
  phone: z.string().min(10).optional(),
  email: z.string().email().optional(),
  city: z.string().min(2).optional(),
  state: z.string().min(2).optional(),
  address: z.string().min(5).optional(),
  pincode: z.string().min(4).max(10).optional(),
  gstNumber: z.string().optional(),
  panNumber: z.string().optional(),
  beneficiaryName: z.string().max(120).optional(),
  accountNumber: z.string().max(30).optional(),
  ifscCode: z.string().max(20).optional(),
  upiId: z.string().max(100).optional(),
})

const academyProfileSchema = z.object({
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
  tagline: z.string().optional(),
  foundedYear: z.number().int().min(1800).max(2100).optional(),
})

const coachProfileSchema = z.object({
  bio: z.string().optional(),
  specializations: z.array(z.string()).default([]),
  certifications: z.array(z.string()).default([]),
  experienceYears: z.number().int().min(0).default(0),
  city: z.string().optional(),
  state: z.string().optional(),
  gigEnabled: z.boolean().default(false),
  hourlyRate: z.number().int().min(0).optional(),
  oneOnOneEnabled: z.boolean().optional(),
  publicProfileVisible: z.boolean().optional(),
})

const arenaProfileSchema = z.object({
  name: z.string().min(2),
  description: z.string().optional(),
  address: z.string().min(1).optional().default(''),
  city: z.string().min(1),
  state: z.string().min(1),
  pincode: z.string().min(1).optional().default(''),
  latitude: z.number().optional(),
  longitude: z.number().optional(),
  phone: z.string().optional(),
  sports: z.array(z.enum(['CRICKET', 'FUTSAL', 'PICKLEBALL', 'BADMINTON', 'FOOTBALL', 'BASKETBALL', 'TENNIS', 'OTHER'])).default(['CRICKET']),
  photoUrls: z.array(z.string()).default([]),
  hasParking: z.boolean().default(false),
  hasLights: z.boolean().default(false),
  hasWashrooms: z.boolean().default(false),
  hasCanteen: z.boolean().default(false),
  hasCCTV: z.boolean().default(false),
  hasScorer: z.boolean().default(false),
})

export async function bizRoutes(app: FastifyInstance) {
  const svc = new BizService()
  const auth = { onRequest: [(app as any).authenticate] }

  app.get('/me', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.getMe(user.userId) })
  })

  app.put('/business-details', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = businessDetailsSchema.parse(request.body)
    return reply.send({ success: true, data: await svc.upsertBusinessDetails(user.userId, body) })
  })

  app.post('/academy', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = academyProfileSchema.parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.createAcademyProfile(user.userId, body) })
  })

  app.post('/coach', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = coachProfileSchema.parse(request.body)
    return reply.send({ success: true, data: await svc.upsertCoachProfile(user.userId, body) })
  })

  app.post('/arena', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = arenaProfileSchema.parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.createArenaProfile(user.userId, body) })
  })

  app.get('/stores', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    return reply.send({ success: true, data: await svc.listStores(user.userId) })
  })
}
