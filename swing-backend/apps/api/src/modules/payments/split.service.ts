import { prisma } from '@swing/db'
import { AppError } from '../../lib/errors'

const CASHFREE_PAYOUT_BASE = 'https://api.cashfree.com/payout/v1'
const PLATFORM_FEE_BASIS_POINTS = Number(process.env.PLATFORM_FEE_BASIS_POINTS ?? 200) // 2%
const PLATFORM_FEE_PAISE_ACADEMY = Number(process.env.PLATFORM_FEE_PAISE_ACADEMY ?? 5000) // ₹50

function payoutAuthHeaders(): Record<string, string> {
  return {
    'Content-Type': 'application/json',
    'x-client-id': process.env.CASHFREE_APP_ID || '',
    'x-client-secret': process.env.CASHFREE_SECRET_KEY || '',
  }
}

async function cfPayoutPost(path: string, body: unknown): Promise<any> {
  const res = await fetch(`${CASHFREE_PAYOUT_BASE}${path}`, {
    method: 'POST',
    headers: payoutAuthHeaders(),
    body: JSON.stringify(body),
  })
  const text = await res.text()
  if (!res.ok) {
    throw new AppError('CASHFREE_PAYOUT_ERROR', `Cashfree Payout API ${path} failed: ${text}`, 502)
  }
  return JSON.parse(text)
}

export class SplitService {
  async splitPayment(opts: {
    entityType: 'SLOT_BOOKING' | 'ACADEMY_FEE'
    entityId: string
    totalPaise: number
    cashfreeOrderId: string
  }) {
    const bankDetails = await this.resolveBankDetails(opts.entityType, opts.entityId)
    if (!bankDetails) {
      console.warn(`[Split] No bank details for ${opts.entityType} ${opts.entityId} — skipping split`)
      return null
    }

    if (!bankDetails.routeEnabled) {
      console.warn(`[Split] Route not enabled for ${opts.entityType} ${opts.entityId} — skipping split`)
      return null
    }

    const platformFeePaise =
      opts.entityType === 'ACADEMY_FEE'
        ? PLATFORM_FEE_PAISE_ACADEMY
        : Math.round((opts.totalPaise * PLATFORM_FEE_BASIS_POINTS) / 10000)
    const splitPaise = Math.max(0, opts.totalPaise - platformFeePaise)

    if (splitPaise === 0) {
      console.warn('[Split] Split amount is zero — skipping transfer')
      return null
    }

    const transferId = `split_${opts.entityType}_${opts.entityId}_${Date.now()}`
    const amountRupees = (splitPaise / 100).toFixed(2)
    const phone = (bankDetails.phone || '9000000000').replace(/\D/g, '').slice(-10)

    return cfPayoutPost('/requestTransfer', {
      beneDetails: {
        name: bankDetails.beneficiaryName || bankDetails.contactName || bankDetails.businessName,
        email: 'noreply@swing.in',
        phone,
        bankAccount: bankDetails.accountNumber,
        ifsc: bankDetails.ifscCode,
        address1: 'India',
      },
      amount: amountRupees,
      transferId,
      transferMode: 'banktransfer',
      remarks: `Platform payout - ${opts.entityType}`,
    })
  }

  private async resolveBankDetails(entityType: 'SLOT_BOOKING' | 'ACADEMY_FEE', entityId: string) {
    if (entityType === 'SLOT_BOOKING') {
      const booking = await prisma.slotBooking.findUnique({
        where: { id: entityId },
        include: { unit: { include: { arena: { include: { businessAccount: true } } } } },
      })
      const ba = booking?.unit?.arena?.businessAccount
      if (!ba?.accountNumber || !ba?.ifscCode) return null
      return ba
    }

    if (entityType === 'ACADEMY_FEE') {
      const enrollment = await prisma.academyEnrollment.findUnique({
        where: { id: entityId },
        include: { academy: { include: { businessAccount: true } } },
      })
      const ba = enrollment?.academy?.businessAccount
      if (!ba?.accountNumber || !ba?.ifscCode) return null
      return ba
    }

    return null
  }
}
