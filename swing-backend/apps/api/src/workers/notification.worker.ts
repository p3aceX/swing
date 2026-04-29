import { Worker, Job } from 'bullmq'
import { buildRedisConnection } from '../lib/redis'
import { NotificationService } from '../modules/notifications/notification.service'

const connection = buildRedisConnection() ?? buildRedisConnection('redis://localhost:6379')!

const notificationSvc = new NotificationService()

export function createNotificationWorker() {
  const worker = new Worker(
    'notifications',
    async (job: Job) => {
      const payload = job.data?.data ?? job.data
      const { userId, title, body, data } = payload

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
