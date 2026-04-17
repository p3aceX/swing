import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { AuthService } from './auth.service'

export async function authRoutes(app: FastifyInstance) {
  const svc = new AuthService()

  app.post('/check-phone', {
    schema: { tags: ['auth'], summary: 'Check if a phone number already has an account' },
  }, async (request, reply) => {
    const body = z.object({
      phone: z.string().min(10),
    }).parse(request.body)

    const data = await svc.checkPhone(body.phone)
    return reply.send({ success: true, data })
  })

  // Client completes Firebase Phone Auth, sends the Firebase ID token
  app.post('/login', {
    schema: { tags: ['auth'], summary: 'Login with Firebase Phone Auth ID token' },
  }, async (request, reply) => {
    const body = z.object({
      idToken: z.string().min(10),
      name: z.string().min(2).max(100).optional(),
      language: z.enum(['en', 'hi', 'ta', 'te']).optional(),
      initialRole: z.enum(['PLAYER', 'COACH', 'ACADEMY_OWNER', 'ARENA_OWNER', 'PARENT']).optional(),
    }).parse(request.body)

    const data = await svc.loginWithFirebase(body.idToken, body.name, body.language, body.initialRole)
    return reply.send({ success: true, data })
  })

  app.post('/player/login', {
    schema: { tags: ['auth'], summary: 'Player app login with Firebase Phone Auth ID token' },
  }, async (request, reply) => {
    const body = z.object({
      idToken: z.string().min(10),
      name: z.string().min(2).max(100).optional(),
      language: z.enum(['en', 'hi', 'ta', 'te']).optional(),
    }).parse(request.body)

    const data = await svc.loginWithFirebase(body.idToken, body.name, body.language, 'PLAYER')
    return reply.send({ success: true, data })
  })

  app.post('/biz/login', {
    schema: { tags: ['auth'], summary: 'Swing-Biz login with Firebase Phone Auth ID token' },
  }, async (request, reply) => {
    const body = z.object({
      idToken: z.string().min(10),
      name: z.string().min(2).max(100).optional(),
      language: z.enum(['en', 'hi', 'ta', 'te']).optional(),
    }).parse(request.body)

    const data = await svc.loginWithFirebaseForBiz(body.idToken, body.name, body.language)
    return reply.send({ success: true, data })
  })

  app.post('/refresh', {
    schema: { tags: ['auth'], summary: 'Refresh access token using refresh token' },
  }, async (request, reply) => {
    const body = z.object({ refreshToken: z.string().min(10) }).parse(request.body)
    const data = await svc.refreshTokens(body.refreshToken)
    return reply.send({ success: true, data })
  })

  app.post('/logout', {
    onRequest: [(app as any).authenticate],
    schema: { tags: ['auth'], summary: 'Logout and revoke refresh token' },
  }, async (request, reply) => {
    const body = z.object({ refreshToken: z.string().min(10) }).parse(request.body)
    await svc.logout(body.refreshToken)
    return reply.send({ success: true, data: { message: 'Logged out successfully' } })
  })

  app.post('/switch-role', {
    onRequest: [(app as any).authenticate],
    schema: { tags: ['auth'], summary: 'Switch active role (e.g. PLAYER → COACH)' },
  }, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = z.object({
      role: z.enum(['PLAYER', 'COACH', 'ACADEMY_OWNER', 'ARENA_OWNER', 'PARENT']),
    }).parse(request.body)
    const data = await svc.switchRole(user.userId, body.role)
    return reply.send({ success: true, data })
  })
}
