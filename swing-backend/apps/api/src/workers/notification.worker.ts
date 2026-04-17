import { Worker, Job } from 'bullmq'
import { NotificationService } from '../modules/notifications/notification.service'

const redisUrl = new URL(process.env.REDIS_URL || 'redis://localhost:6379')
const connection = {
  host: redisUrl.hostname,
  port: Number(redisUrl.port) || 6379,
  password: redisUrl.password || undefined,
}

const notificationSvc = new NotificationService()

export function createNotificationWorker() {
  const worker = new Worker(
    'notifications',
    async (job: Job) => {
      const { userId, title, body, data } = job.data

      try {
        await notificationSvc.sendPush(userId, title, body, data)
        return { sent: true, userId }
      } catch (err) {
        console.error(`[NotificationWorker] Failed to send push to ${userId}:`, err)
        throw err
      }
    },
    {
      connection,
      concurrency: 20,
      limiter: { max: 100, duration: 1000 },
    },
  )

  worker.on('completed', job => {
    console.log(`[NotificationWorker] Job ${job.id} completed`)
  })

  worker.on('failed', (job, err) => {
    console.error(`[NotificationWorker] Job ${job?.id} failed:`, err.message)
  })

  return worker
}
