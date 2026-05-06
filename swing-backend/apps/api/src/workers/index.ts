import { createNotificationWorker } from './notification.worker'
import { createSlotReleaseWorker } from './slot-release.worker'
import { createInterestLockSweepWorker } from './interest-lock-sweep.worker'

let workers: { close: () => Promise<void> }[] = []

export async function startAllWorkers() {
  console.log('[Workers] Starting BullMQ workers...')

  const notificationWorker = createNotificationWorker()
  const slotReleaseWorker = createSlotReleaseWorker()
  const interestLockSweepWorker = createInterestLockSweepWorker()

  workers = [
    notificationWorker as any,
    slotReleaseWorker as any,
    interestLockSweepWorker,
  ]

  console.log(
    '[Workers] All workers started: notification, slot-release, interest-lock-sweep',
  )
}

export async function stopAllWorkers() {
  console.log('[Workers] Stopping all workers...')
  await Promise.all(workers.map(w => w.close()))
  console.log('[Workers] All workers stopped')
}

process.on('SIGTERM', async () => {
  await stopAllWorkers()
  process.exit(0)
})

process.on('SIGINT', async () => {
  await stopAllWorkers()
  process.exit(0)
})
