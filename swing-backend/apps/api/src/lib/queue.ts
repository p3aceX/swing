import { Queue } from 'bullmq'
import { buildRedisConnection } from './redis'

const redisUrl = process.env.REDIS_URL
const queuesEnabled = process.env.ENABLE_QUEUES === 'true' && !!redisUrl
const connection = queuesEnabled ? buildRedisConnection(redisUrl) : null

function buildQueue(name: string) {
  if (!connection) {
    console.warn(`[queue] queues disabled; skipping queue ${name}`)
    return null
  }
  return new Queue(name, { connection })
}

export const notificationQueue = buildQueue('notifications')
export const slotReleaseQueue = buildQueue('slot-release')

export async function enqueueNotification(type: string, data: Record<string, unknown>, opts?: { delay?: number }) {
  if (!notificationQueue) return null
  try {
    return await notificationQueue.add(type, { type, data }, {
      attempts: 3,
      backoff: { type: 'exponential', delay: 2000 },
      ...opts,
    })
  } catch (err) {
    console.warn('[queue] notification enqueue failed, skipping', err)
    return null
  }
}
