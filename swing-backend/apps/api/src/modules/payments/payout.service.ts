import { prisma } from '@swing/db'
import { AppError } from '../../lib/errors'

const CASHFREE_PAYOUT_BASE = 'https://api.cashfree.com/payout/v1'

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

export class PayoutService {
  async disburse(opts: {
    businessAccountId: string
    amountPaise: number
    reference: string
    narration: string
  }): Promise<{ id: string; status: string }> {
    const ba = await prisma.businessAccount.findUnique({ where: { id: opts.businessAccountId } })
    if (!ba) throw new AppError('BIZ_NOT_FOUND', 'Business account not found', 404)
    if (!ba.accountNumber || !ba.ifscCode) {
      throw new AppError('BANK_DETAILS_MISSING', 'Bank account and IFSC are required for payouts', 400)
    }

    const amountRupees = (opts.amountPaise / 100).toFixed(2)
    const phone = (ba.phone || '9000000000').replace(/\D/g, '').slice(-10)

    const result = await cfPayoutPost('/requestTransfer', {
      beneDetails: {
        name: ba.beneficiaryName || ba.contactName || ba.businessName,
        email: ba.email || 'noreply@swing.in',
        phone,
        bankAccount: ba.accountNumber,
        ifsc: ba.ifscCode,
        address1: 'India',
      },
      amount: amountRupees,
      transferId: opts.reference,
      transferMode: 'banktransfer',
      remarks: opts.narration,
    })

    return { id: result.referenceId ?? opts.reference, status: result.status ?? 'PENDING' }
  }
}
