import IORedis from 'ioredis'

export function buildRedisConnection(redisUrl = process.env.REDIS_URL) {
  if (!redisUrl) return null

  const parsed = new URL(redisUrl)
  const usesTls =
    parsed.protocol === 'rediss:' ||
    process.env.REDIS_TLS === 'true' ||
    process.env.UPSTASH_REDIS_REST_URL != null

  return {
    host: parsed.hostname,
    port: Number(parsed.port) || 6379,
    username: parsed.username ? decodeURIComponent(parsed.username) : undefined,
    password: parsed.password ? decodeURIComponent(parsed.password) : undefined,
    db: parsed.pathname.length > 1 ? Number(parsed.pathname.slice(1)) || 0 : 0,
    maxRetriesPerRequest: null,
    enableReadyCheck: false,
    ...(usesTls ? { tls: {} } : {}),
  }
}

export const redis = new IORedis(
  buildRedisConnection(process.env.REDIS_URL || 'redis://localhost:6379')!,
)

redis.on('connect', () => console.log('Redis connected'))
redis.on('error', (err) => console.error('Redis error:', err))

// OTP helpers
export const OTP_TTL_SECONDS = 600 // 10 minutes

export async function setOtp(phone: string, code: string): Promise<void> {
  await redis.setex(`otp:${phone}`, OTP_TTL_SECONDS, code)
}

export async function getOtp(phone: string): Promise<string | null> {
  return redis.get(`otp:${phone}`)
}

export async function deleteOtp(phone: string): Promise<void> {
  await redis.del(`otp:${phone}`)
}

export async function incrementOtpAttempts(phone: string): Promise<number> {
  const key = `otp:attempts:${phone}`
  const count = await redis.incr(key)
  if (count === 1) await redis.expire(key, OTP_TTL_SECONDS)
  return count
}

export async function getOtpAttempts(phone: string): Promise<number> {
  const val = await redis.get(`otp:attempts:${phone}`)
  return Number(val) || 0
}

export async function checkOtpRateLimit(phone: string): Promise<boolean> {
  // 1 OTP per minute
  const minuteKey = `otp:rate:min:${phone}`
  const count = await redis.incr(minuteKey)
  if (count === 1) await redis.expire(minuteKey, 60)
  if (count > 1) return false
  // 5 OTPs per hour
  const hourKey = `otp:rate:hour:${phone}`
  const hourCount = await redis.incr(hourKey)
  if (hourCount === 1) await redis.expire(hourKey, 3600)
  if (hourCount > 5) return false
  return true
}

// Slot hold helpers (10-min TTL)
export async function holdSlot(unitId: string, date: string, startTime: string, bookingId: string): Promise<boolean> {
  const key = `hold:${unitId}:${date}:${startTime}`
  const result = await redis.set(key, bookingId, 'EX', 600, 'NX')
  return result === 'OK'
}

export async function releaseSlot(unitId: string, date: string, startTime: string): Promise<void> {
  await redis.del(`hold:${unitId}:${date}:${startTime}`)
}

export async function isSlotHeld(unitId: string, date: string, startTime: string): Promise<string | null> {
  return redis.get(`hold:${unitId}:${date}:${startTime}`)
}

export async function blacklistToken(token: string, ttlSeconds: number): Promise<void> {
  await redis.setex(`blacklist:${token}`, ttlSeconds, '1')
}

export async function isTokenBlacklisted(token: string): Promise<boolean> {
  const val = await redis.get(`blacklist:${token}`)
  return val === '1'
}

// Studio scene helpers (6-hour TTL)
const STUDIO_TTL = 21600

export interface StudioScene {
  scene: 'standard' | 'stats' | 'break' | 'clean'
  breakType?: 'drinks' | 'innings' | 'powerplay' | null
  updatedAt: string
}

export async function setStudioScene(matchId: string, scene: StudioScene): Promise<void> {
  await redis.setex(`studio:${matchId}:scene`, STUDIO_TTL, JSON.stringify(scene))
}

export async function getStudioScene(matchId: string): Promise<StudioScene | null> {
  const val = await redis.get(`studio:${matchId}:scene`)
  if (!val) return null
  try { return JSON.parse(val) } catch { return null }
}

// Batch-check Redis holds for a set of slots. Returns a Set of "unitId:date:startTime" strings that are currently held.
export async function getHeldSlotsSet(
  entries: Array<{ unitId: string; date: string; startTime: string }>
): Promise<Set<string>> {
  if (entries.length === 0) return new Set()
  const keys = entries.map(e => `hold:${e.unitId}:${e.date}:${e.startTime}`)
  const values = await redis.mget(...keys)
  const held = new Set<string>()
  values.forEach((v, i) => {
    if (v !== null) held.add(`${entries[i].unitId}:${entries[i].date}:${entries[i].startTime}`)
  })
  return held
}
