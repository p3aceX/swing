/**
 * Null out paidAt on CONFIRMED bookings that have no payment records at all.
 * These were erroneously marked paidAt at creation time (old split booking bug).
 *
 * Safe criteria:
 *   - status = CONFIRMED (not CHECKED_IN — we don't touch check-ins)
 *   - paidAt IS set
 *   - no BookingPayment records
 *   - no linked Payment record
 *   - advancePaise = 0
 *
 * Run: npx tsx scripts/fix_falsely_paid_bookings.ts [--dry-run]
 */
import { prisma } from '@swing/db'

async function main() {
  const dryRun = process.argv.includes('--dry-run')
  console.log(`[fix-falsely-paid] dry-run=${dryRun}`)

  const bookings = await prisma.slotBooking.findMany({
    where: {
      status: 'CONFIRMED',
      paidAt: { not: null },
      advancePaise: 0,
      bookingPayments: { none: {} },
      payment: null,
    },
    select: { id: true, totalAmountPaise: true, paidAt: true, bookingSource: true },
  })

  console.log(`Found ${bookings.length} bookings with false paidAt`)
  for (const b of bookings) {
    console.log(`  ${b.id}  ₹${b.totalAmountPaise / 100}  source=${b.bookingSource}  paidAt=${b.paidAt}`)
    if (!dryRun) {
      await prisma.slotBooking.update({
        where: { id: b.id },
        data: { paidAt: null },
      })
    }
  }
  console.log(`Done — ${dryRun ? 'would clear' : 'cleared'} paidAt on ${bookings.length} bookings`)
}

main().catch(e => { console.error(e); process.exit(1) }).finally(() => prisma.$disconnect())
