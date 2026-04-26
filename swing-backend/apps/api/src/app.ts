import Fastify from 'fastify'
import axios from 'axios'
import websocket from '@fastify/websocket'
import { WebSocket } from 'ws'
import cors from '@fastify/cors'
import helmet from '@fastify/helmet'
import jwt from '@fastify/jwt'
import rateLimit from '@fastify/rate-limit'
import multipart from '@fastify/multipart'
import swagger from '@fastify/swagger'
import swaggerUi from '@fastify/swagger-ui'

import { redis } from './lib/redis'
import { errorHandler } from './lib/errors'
import { authRoutes } from './modules/auth/auth.routes'
import { playerRoutes } from './modules/player/player.routes'
import { chatRoutes } from './modules/chat/chat.routes'
import { academyRoutes } from './modules/academy/academy.routes'
import { coachRoutes } from './modules/coach/coach.routes'
import { sessionRoutes } from './modules/sessions/session.routes'
import { matchRoutes } from './modules/matches/match.routes'
import { arenaRoutes } from './modules/arenas/arena.routes'
import { bookingRoutes } from './modules/bookings/booking.routes'
import { matchmakingRoutes } from './modules/matchmaking/matchmaking.routes'
import { matchmakingQueueRoutes } from './modules/matchmaking/matchmaking-queue.routes'
import { gigRoutes } from './modules/gigs/gig.routes'
import { paymentRoutes } from './modules/payments/payment.routes'
import { adminRoutes } from './modules/admin/admin.routes'
import { notificationRoutes } from './modules/notifications/notification.routes'
import { adminSupportRoutes } from './modules/admin/admin.support.routes'
import { publicRoutes } from './modules/public/public.routes'
import { sessionLogRoutes } from './modules/session-logs/session-log.routes'
import { curriculumRoutes } from './modules/curriculum/curriculum.routes'
import { payrollRoutes } from './modules/payroll/payroll.routes'
import { oneOnOneRoutes } from './modules/one-on-one/one-on-one.routes'
import { developmentRoutes } from './modules/development/development.routes'
import { liveRoutes } from './modules/live/live.routes'
import { studioRoutes } from './modules/studio/studio.routes'
import { storeRoutes } from './modules/store/store.routes'
import { StudioService } from './modules/studio/studio.service'
import { wearablesRoutes } from './modules/wearables/wearables.routes'
import { eliteRoutes } from './modules/performance/elite.routes'
import { growthInsightsRoutes } from './modules/performance/growth-insights.routes'
import { libraryRoutes } from './modules/library/library.routes'
import { startSeasonScheduler } from './modules/performance/ip-engine'
import { bizRoutes } from './modules/biz/biz.routes'
import { mediaRoutes } from './modules/media/media.routes'

export async function buildApp() {
  const app = Fastify({
    logger: {
      level: process.env.NODE_ENV === 'production' ? 'info' : 'debug',
      transport:
        process.env.NODE_ENV !== 'production'
          ? { target: 'pino-pretty', options: { colorize: true } }
          : undefined,
    },
  })

  await app.register(helmet, { contentSecurityPolicy: false })
  await app.register(cors, {
    origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
    credentials: true,
  })
  await app.register(rateLimit, {
    max: 500,
    timeWindow: '1 minute',
    redis,
  })
  await app.register(multipart, {
    limits: {
      fileSize: 15 * 1024 * 1024,
    },
  })
  await app.register(jwt, {
    secret: process.env.JWT_SECRET!,
    sign: { expiresIn: '15m' },
  })

  await app.register(swagger, {
    openapi: {
      info: { title: 'Swing API', description: 'Cricket OS for India', version: '1.0.0' },
      tags: [
        { name: 'auth' }, { name: 'player' }, { name: 'chat' }, { name: 'academy' },
        { name: 'coach' }, { name: 'sessions' }, { name: 'matches' },
        { name: 'arenas' }, { name: 'bookings' }, { name: 'matchmaking' },
        { name: 'gigs' }, { name: 'payments' }, { name: 'admin' }, { name: 'notifications' },
        { name: 'session-logs' }, { name: 'curriculum' }, { name: 'payroll' }, { name: '1on1' },
        { name: 'development' }, { name: 'live' }, { name: 'wearables' },
      ],
    },
  })
  await app.register(swaggerUi, { routePrefix: '/docs' })

  // Allow POST requests with Content-Type: application/json but empty body
  app.addContentTypeParser('application/json', { parseAs: 'string' }, (req, body, done) => {
    try {
      const str = (body as string).trim()
      done(null, str ? JSON.parse(str) : undefined)
    } catch (err: any) {
      done(err, undefined)
    }
  })

  app.setErrorHandler(errorHandler)

  // Authenticate decorator
  app.decorate('authenticate', async function (request: any, reply: any) {
    try {
      await request.jwtVerify()
    } catch {
      reply.code(401).send({
        success: false,
        error: { code: 'UNAUTHORIZED', message: 'Invalid or missing token' },
      })
    }
  })

  // Routes
  await app.register(authRoutes, { prefix: '/auth' })
  await app.register(playerRoutes, { prefix: '/player' })
  await app.register(chatRoutes, { prefix: '/chat' })
  await app.register(academyRoutes, { prefix: '/academy' })
  await app.register(coachRoutes, { prefix: '/coach' })
  await app.register(sessionRoutes, { prefix: '/sessions' })
  await app.register(matchRoutes, { prefix: '/matches' })
  await app.register(arenaRoutes, { prefix: '/arenas' })
  await app.register(bookingRoutes, { prefix: '/bookings' })
  await app.register(matchmakingRoutes, { prefix: '/matchmaking' })
  await app.register(matchmakingQueueRoutes, { prefix: '/matchmaking' })
  await app.register(gigRoutes, { prefix: '/gigs' })
  await app.register(paymentRoutes, { prefix: '/payments' })
  await app.register(notificationRoutes, { prefix: '/notifications' })
  await app.register(adminRoutes, { prefix: '/admin' })
  await app.register(mediaRoutes)
  await app.register(mediaRoutes, { prefix: '/admin' })
  await app.register(adminSupportRoutes, { prefix: '/admin' })
  await app.register(publicRoutes, { prefix: '/public' })
  await app.register(sessionLogRoutes, { prefix: '/session-logs' })
  await app.register(curriculumRoutes, { prefix: '/curriculum' })
  await app.register(payrollRoutes, { prefix: '/payroll' })
  await app.register(oneOnOneRoutes, { prefix: '/1on1' })
  await app.register(developmentRoutes)
  await app.register(liveRoutes, { prefix: '/live' })
  await app.register(studioRoutes, { prefix: '/studio' })
  await app.register(storeRoutes, { prefix: '/store' })
  await app.register(wearablesRoutes, { prefix: '/wearables' })
  await app.register(eliteRoutes, { prefix: '/v1/elite' })
  await app.register(growthInsightsRoutes, { prefix: '/v1/player' })
  await app.register(libraryRoutes, { prefix: '/library' })
  await app.register(bizRoutes, { prefix: '/biz' })
  StudioService.startScheduledSceneSwitchFlusher(app.log)

  app.get('/health', async () => ({ status: 'ok', timestamp: new Date().toISOString(), version: '1.0.0' }))

  // ─── HLS proxy: /studio/hls/:matchId/* → NGINX on VM ────────────────────────
  // NGINX-RTMP writes HLS to /tmp/streams/{matchId}/, served on port 8080
  // No auth — video segments fetched directly by hls.js player
  const hlsServiceUrl = process.env.HLS_SERVICE_URL || 'http://34.47.234.51:8080'
  app.get('/studio/hls/:matchId/*', async (request, reply) => {
    const { matchId } = request.params as { matchId: string }
    const segment = (request.params as any)['*'] as string
    try {
      const resp = await axios.get(`${hlsServiceUrl}/hls/${matchId}/${segment}`, {
        responseType: 'arraybuffer',
      })
      reply.header('Access-Control-Allow-Origin', '*')
      reply.header('Cache-Control', 'no-cache')
      if (resp.headers['content-type']) reply.header('Content-Type', resp.headers['content-type'])
      return reply.send(resp.data)
    } catch {
      return reply.status(404).send()
    }
  })

  // ─── WebSocket proxy: /studio/ws → studio VM ─────────────────────────────
  // Allows the camera page (served over HTTPS/WSS) to connect without TLS
  // on the studio VM. Cloud Run terminates TLS; this proxies to plain WS.
  const studioWsUrl = (process.env.STUDIO_SERVICE_URL || 'http://localhost:4000')
    .replace(/^http:/, 'ws:')
    .replace(/^https:/, 'wss:')

  await app.register(websocket)

  // In @fastify/websocket v8, the handler receives a SocketStream;
  // the actual WebSocket instance is at connection.socket
  app.get('/studio/ws', { websocket: true }, (connection) => {
    const client = connection.socket
    const upstream = new WebSocket(studioWsUrl)

    // Browser → studio VM
    client.on('message', (data, isBinary) => {
      if (upstream.readyState === WebSocket.OPEN) {
        upstream.send(data, { binary: isBinary })
      }
    })

    // Studio VM → browser
    upstream.on('message', (data, isBinary) => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(data, { binary: isBinary })
      }
    })

    upstream.on('close', (code, reason) => client.close(code, reason.toString()))
    upstream.on('error', () => client.close(1011, 'upstream error'))
    client.on('close', () => upstream.close())
    client.on('error', () => upstream.close())
  })

  // Start 90-day season reset scheduler (checks once per day)
  startSeasonScheduler()

  return app
}
