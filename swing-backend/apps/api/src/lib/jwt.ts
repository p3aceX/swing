import { createHmac, randomBytes } from 'crypto'
import jwt from 'jsonwebtoken'
import { JwtPayload } from '@swing/types'

export function generateRefreshToken(): string {
  return randomBytes(48).toString('hex')
}

export function hashToken(token: string): string {
  return createHmac('sha256', process.env.JWT_REFRESH_SECRET!).update(token).digest('hex')
}

export function buildJwtPayload(userId: string, activeRole: string, roles: string[]): JwtPayload {
  return { userId, activeRole, roles: [...new Set(roles)] }
}

export function signAccessToken(payload: JwtPayload): string {
  return jwt.sign(payload, process.env.JWT_SECRET!, { expiresIn: '15m' })
}

export function signAdminToken(payload: JwtPayload): string {
  return jwt.sign(payload, process.env.JWT_SECRET!, { expiresIn: '8h' })
}
