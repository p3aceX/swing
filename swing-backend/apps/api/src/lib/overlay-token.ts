import jwt from 'jsonwebtoken'
import type { FastifyReply, FastifyRequest } from 'fastify'

const OVERLAY_TOKEN_TTL = '12h'
const OVERLAY_TOKEN_AUD = 'overlay-feed'

export interface OverlayTokenPayload {
  matchId: string
  aud: typeof OVERLAY_TOKEN_AUD
}

export function signOverlayToken(matchId: string): string {
  return jwt.sign({ matchId, aud: OVERLAY_TOKEN_AUD }, process.env.JWT_SECRET!, {
    expiresIn: OVERLAY_TOKEN_TTL,
  })
}

function extractToken(request: FastifyRequest): string | null {
  const authHeader = request.headers.authorization
  if (authHeader?.startsWith('Bearer ')) return authHeader.slice(7).trim()
  const q = request.query as Record<string, unknown> | null
  const token = q?.token
  if (typeof token === 'string' && token.length > 0) return token
  return null
}

export function verifyOverlayToken(token: string): OverlayTokenPayload | null {
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as OverlayTokenPayload
    if (decoded.aud !== OVERLAY_TOKEN_AUD) return null
    if (!decoded.matchId) return null
    return decoded
  } catch {
    return null
  }
}

// Fastify preHandler: validates that the request carries an overlay token
// scoped to the matchId in the route param.
export async function requireOverlayToken(request: FastifyRequest, reply: FastifyReply) {
  const token = extractToken(request)
  if (!token) {
    return reply.code(401).send({
      success: false,
      error: { code: 'OVERLAY_TOKEN_MISSING', message: 'Overlay token required' },
    })
  }
  const payload = verifyOverlayToken(token)
  if (!payload) {
    return reply.code(401).send({
      success: false,
      error: { code: 'OVERLAY_TOKEN_INVALID', message: 'Invalid or expired overlay token' },
    })
  }
  const { matchId } = (request.params as { matchId?: string }) ?? {}
  if (!matchId || matchId !== payload.matchId) {
    return reply.code(403).send({
      success: false,
      error: {
        code: 'OVERLAY_TOKEN_SCOPE_MISMATCH',
        message: 'Token is not valid for this match',
      },
    })
  }
}
