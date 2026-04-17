import { Worker, Job } from 'bullmq'
import { releaseSlot } from '../lib/redis'
import { prisma } from '@swing/db'

const redisUrl = new URL(process.env.REDIS_URL || 'redis://localhost:6379')
const connection = {
  host: redisUrl.hostname,
  port: Number(redisUrl.port) || 6379,
  password: redisUrl.password || undefined,
}

export function createSlotReleaseWorker() {
  const worker = new Worker(
    'slot-release',
    async (job: Job) => {
      const { arenaUnitId, bookingDate, startTime, bookingId } = job.data

      try {
        await releaseSlot(arenaUnitId, bookingDate, startTime)

        if (bookingId) {
          const booking = await prisma.slotBooking.findUnique({ where: { id: bookingId } })
          if (booking && booking.status === 'PENDING_PAYMENT') {
            await prisma.slotBooking.update({
              where: { id: bookingId },
              data: { status: 'CANCELLED', cancelledAt: new Date() },
            })
            console.log(`[SlotReleaseWorker] Cancelled expired booking ${bookingId}`)
          }
        }

        return { released: true, arenaUnitId, bookingDate, startTime }
      } catch (err) {
        console.error(`[SlotReleaseWorker] Failed to release slot:`, err)
        throw err
      }
    },
    {
      connection,
      concurrency: 5,
    },
  )

  worker.on('completed', job => {
    console.log(`[SlotReleaseWorker] Job ${job.id} completed`)
  })

  worker.on('failed', (job, err) => {
    console.error(`[SlotReleaseWorker] Job ${job?.id} failed:`, err.message)
  })

  return worker
}
