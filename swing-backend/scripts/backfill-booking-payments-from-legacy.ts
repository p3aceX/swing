/**
 * Backfill BookingPayment rows for bookings that were settled via the legacy
 * markPaid / checkinByOwner flow (which only wrote to the Payment table, not
 * the new BookingPayment ledger).
 *
 * Targets SlotBookings where:
 *   • status IN (CONFIRMED, CHECKED_IN)
 *   • linked Payment.status = COMPLETED   (old flow's record)
 *   • bookingPayments count = 0           (not yet in new ledger)
 *
 * Also catches bookings with advancePaise > 0 and no BookingPayment rows,
 * even if there's no Payment record (e.g. partial walk-in advances recorded
 * directly on the SlotBooking at creation time).
 *
 * Run: npx tsx scripts/backfill-booking-payments-from-legacy.ts [--dry-run]
 */

import { prisma } from '@swing/db'

async function main() {
  const dryRun = process.argv.includes('--dry-run')
  console.log(`[backfill-legacy-payments] dry-run=${dryRun}`)

  // ── Case 1: has a completed Payment record but no BookingPayment rows ──────
  const bookingsWithPayment = await prisma.slotBooking.findMany({
    where: {
      status: { in: ['CONFIRMED', 'CHECKED_IN'] },
      payment: { status: 'COMPLETED' },
      bookingPayments: { none: {} },
    },
    include: {
      payment: true,
      bookedBy: { include: { user: { select: { name: true, phone: true } } } },
      arena: { include: { owner: true } },
    },
  })

  // ── Case 2: advancePaise > 0 but no BookingPayment rows (no Payment record) ─
  const bookingsWithAdvance = await prisma.slotBooking.findMany({
    where: {
      status: { in: ['CONFIRMED', 'CHECKED_IN'] },
      advancePaise: { gt: 0 },
      payment: null,
      bookingPayments: { none: {} },
    },
    include: {
      bookedBy: { include: { user: { select: { name: true, phone: true } } } },
      arena: { include: { owner: true } },
    },
  })

  console.log(`Case 1 (completed Payment, no BookingPayment): ${bookingsWithPayment.length}`)
  console.log(`Case 2 (advancePaise > 0, no Payment, no BookingPayment): ${bookingsWithAdvance.length}`)

  let created = 0

  for (const b of bookingsWithPayment) {
    const payment = (b as any).payment
    if (!payment) continue

    const amountPaise: number = payment.amountPaise
    const paymentMode: string = payment.method ?? (b as any).paymentMode ?? 'CASH'
    const payerName: string = b.bookedBy?.user?.name ?? 'Guest'
    const ownerProfile = (b.arena as any).owner
    const recordedByOwnerId: string = ownerProfile?.id ?? 'unknown'
    const recordedAt: Date = payment.completedAt ?? payment.createdAt ?? new Date()

    console.log(
      `  [Payment] Booking ${b.id}  ₹${amountPaise / 100}  mode=${paymentMode}  payer="${payerName}"  status=${b.status}`
    )

    if (!dryRun) {
      await prisma.bookingPayment.create({
        data: {
          bookingId: b.id,
          amountPaise,
          paymentMode,
          payerName,
          recordedByOwnerId,
          recordedAt,
          notes: 'Migrated from legacy payment',
        },
      })
    }
    created++
  }

  for (const b of bookingsWithAdvance) {
    const amountPaise: number = (b as any).advancePaise
    const paymentMode: string = (b as any).paymentMode ?? 'CASH'
    const payerName: string = b.bookedBy?.user?.name ?? 'Guest'
    const ownerProfile = (b.arena as any).owner
    const recordedByOwnerId: string = ownerProfile?.id ?? 'unknown'

    console.log(
      `  [Advance] Booking ${b.id}  ₹${amountPaise / 100}  mode=${paymentMode}  payer="${payerName}"  status=${b.status}`
    )

    if (!dryRun) {
      await prisma.bookingPayment.create({
        data: {
          bookingId: b.id,
          amountPaise,
          paymentMode,
          payerName,
          recordedByOwnerId,
          notes: 'Migrated from legacy advance',
        },
      })
    }
    created++
  }

  console.log(`Done — ${dryRun ? 'would create' : 'created'} ${created} BookingPayment rows`)
}

main().catch((e) => { console.error(e); process.exit(1) }).finally(() => prisma.$disconnect())
