import { prisma } from '@swing/db'
async function main() {
  const rows = await prisma.slotBooking.findMany({
    where: { status: { in: ['CONFIRMED', 'CHECKED_IN'] } },
    include: {
      bookingPayments: true,
      payment: true,
    },
  })
  for (const b of rows) {
    const totalPaid = b.bookingPayments.reduce((s, p) => s + p.amountPaise, 0)
    const effective = totalPaid > 0 ? totalPaid : b.advancePaise
    const balance = Math.max(0, b.totalAmountPaise - effective)
    console.log({
      id: b.id,
      status: b.status,
      totalAmountPaise: b.totalAmountPaise,
      advancePaise: b.advancePaise,
      paidAt: b.paidAt,
      bookingPaymentsCount: b.bookingPayments.length,
      totalPaidViaBP: totalPaid,
      effectivePaid: effective,
      balancePaise: balance,
      legacyPaymentStatus: b.payment?.status,
      legacyPaymentAmount: b.payment?.amountPaise,
    })
  }
}
main().catch(console.error).finally(() => prisma.$disconnect())
