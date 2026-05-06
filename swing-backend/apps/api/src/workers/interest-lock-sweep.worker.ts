import { MatchmakingService } from '../modules/matchmaking/matchmaking.service'

const SWEEP_INTERVAL_MS = 60_000 // 60s — interest locks live for 120s

/**
 * Periodic sweep of expired MatchmakingInterest locks. Plan B / V2 needs
 * any orphaned 120-second payment lock to be released so other interested
 * teams can retry. Each sweep is idempotent (per-row transactions inside
 * `releaseExpiredInterestLocks`) so running this on every Cloud Run instance
 * is safe.
 *
 * Modelled to match the BullMQ Worker shape (close() returning a Promise) so
 * `workers/index.ts` can manage it identically.
 */
export function createInterestLockSweepWorker() {
  const svc = new MatchmakingService()
  let stopped = false

  async function tick() {
    if (stopped) return
    try {
      const result = await svc.releaseExpiredInterestLocks()
      if (result.released > 0) {
        console.log(`[InterestLockSweep] released=${result.released}`)
      }
    } catch (err: any) {
      console.error('[InterestLockSweep] error', err?.message ?? err)
    }
  }

  // Fire once on startup so a fresh deploy picks up any locks that expired
  // during the rollout window, then settle into the steady cadence.
  void tick()
  const handle = setInterval(tick, SWEEP_INTERVAL_MS)

  return {
    close: async () => {
      stopped = true
      clearInterval(handle)
    },
  }
}
