/**
 * Backfill split bookings that were created with the hardcoded 120-min duration.
 * Now duration is derived from format: T10/T20 → 240, ODI → 480, Test → 720.
 *
 * Finds every MatchmakingLobby with a splitBookingId, checks if the linked
 * SlotBooking's durationMins is wrong, and patches durationMins + endTime +
 * totalAmountPaise + totalPricePaise.
 *
 * Run: npx tsx scripts/backfill-split-booking-duration.ts [--dry-run]
 */

import { prisma } from '@swing/db'

const FORMAT_DURATION: Record<string, number> = {
  T10: 240, T20: 240, ODI: 480, Test: 720, Custom: 240,
}

function timeToMinutes(t: string): number {
  const [h, m] = t.split(':').map(Number)
  return h * 60 + m
}

function minutesToTime(mins: number): string {
  const h = Math.floor(mins / 60) % 24
  const m = mins % 60
  return `${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}`
}

async function main() {
  const dryRun = process.argv.includes('--dry-run')
  console.log(`[backfill-split-duration] dry-run=${dryRun}`)

  const lobbies = await prisma.matchmakingLobby.findMany({
    where: { splitBookingId: { not: null } },
  })

  console.log(`Found ${lobbies.length} lobbies with splitBookingId`)

  let patched = 0
  let skipped = 0

  for (const lobby of lobbies) {
    if (!lobby.splitBookingId) { skipped++; continue }
    const booking = await prisma.slotBooking.findUnique({
      where: { id: lobby.splitBookingId },
      include: { unit: true },
    })
    if (!booking) { skipped++; continue }

    const correctDuration = FORMAT_DURATION[lobby.format] ?? 240
    if (booking.durationMins === correctDuration) { skipped++; continue }

    const newEndTime = minutesToTime(timeToMinutes(booking.startTime) + correctDuration)
    const unit = booking.unit
    const pricePerTeamPaise = Math.floor(unit.pricePerHourPaise * (correctDuration / 60) / 2)
    const newTotal = pricePerTeamPaise * 2

    console.log(
      `  Booking ${booking.id}  format=${lobby.format}  ` +
      `durationMins: ${booking.durationMins} → ${correctDuration}  ` +
      `endTime: ${booking.endTime} → ${newEndTime}  ` +
      `totalPaise: ${booking.totalAmountPaise} → ${newTotal}`
    )

    // Don't reprice already-confirmed bookings — the slot is settled even if
    // no money changed hands yet. HELD bookings haven't been agreed, so full update.
    const updatePrice = booking.status === 'HELD'

    if (!dryRun) {
      await prisma.slotBooking.update({
        where: { id: booking.id },
        data: {
          durationMins: correctDuration,
          endTime: newEndTime,
          ...(updatePrice ? { totalAmountPaise: newTotal, totalPricePaise: newTotal } : {}),
        },
      })
    }

    console.log(`  → price update: ${updatePrice ? 'YES' : 'SKIPPED (already confirmed)'}`)

    patched++
  }

  console.log(`Done — patched=${patched} skipped=${skipped}`)
}

main().catch((e) => { console.error(e); process.exit(1) }).finally(() => prisma.$disconnect())
