import { prisma } from '@swing/db'
import { AppError } from '../../lib/errors'

const BASE = 'https://api.razorpay.com'
const PLATFORM_FEE_BASIS_POINTS = Number(process.env.PLATFORM_FEE_BASIS_POINTS ?? 200) // 2%
const PLATFORM_FEE_PAISE_ACADEMY = Number(process.env.PLATFORM_FEE_PAISE_ACADEMY ?? 5000) // ₹50

function authHeader() {
  const key = process.env.RAZORPAY_KEY_ID || ''
  const secret = process.env.RAZORPAY_KEY_SECRET || ''
  return 'Basic ' + Buffer.from(`${key}:${secret}`).toString('base64')
}

async function rzpPost(path: string, body: unknown) {
  const res = await fetch(`${BASE}${path}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Authorization: authHeader() },
    body: JSON.stringify(body),
  })
  const text = await res.text()
  if (!res.ok) throw new AppError('RAZORPAY_ROUTE_ERROR', `Route API ${path} failed: ${text}`, 502)
  return JSON.parse(text)
}

export class RouteService {
  async onboardBusinessAccount(businessAccountId: string): Promise<string | null> {
    const ba = await prisma.businessAccount.findUnique({ where: { id: businessAccountId } })
    if (!ba) return null
    if (ba.razorpayAccountId) return ba.razorpayAccountId
    if (!ba.panNumber || !ba.accountNumber || !ba.ifscCode) return null

    const email = ba.email || `noreply+${ba.id}@swingcricket.com`
    const phone = (ba.phone || '9000000000').replace(/\D/g, '').slice(-10)

    const account = await rzpPost('/v2/accounts', {
      email,
      profile: {
        category: 'sports',
        subcategory: 'fitness_and_wellness',
        addresses: {
          registered: {
            street1: ba.address || 'N/A',
            city: ba.city || 'Unknown',
            state: ba.state || 'MH',
            postal_code: ba.pincode || '000000',
            country: 'IN',
          },
        },
      },
      legal_business_name: ba.businessName,
      business_type: 'individual',
      legal_info: { pan: ba.panNumber },
      contact_name: ba.contactName || ba.businessName,
      contact_info: {
        email,
        phone: { primary: { country_code: '91', number: phone } },
      },
    }) as { id: string }

    await rzpPost(`/v2/accounts/${account.id}/stakeholders`, {
      name: ba.contactName || ba.businessName,
      email,
      relationship: { director: true },
      phone: { primary: { country_code: '91', number: phone } },
      addresses: {
        residential: {
          street: ba.address || 'N/A',
          city: ba.city || 'Unknown',
          state: ba.state || 'MH',
          postal_code: ba.pincode || '000000',
          country: 'IN',
        },
      },
      kyc: { pan: ba.panNumber },
    }).catch((err) => console.error('[Route] stakeholder error (non-fatal):', err))

    await rzpPost(`/v2/accounts/${account.id}/products`, {
      requested_product: 'route',
      tnc_accepted: true,
      settlements: {
        account_number: ba.accountNumber,
        ifsc_code: ba.ifscCode,
        beneficiary_name: ba.beneficiaryName || ba.contactName || ba.businessName,
      },
    }).catch((err) => console.error('[Route] product error (non-fatal):', err))

    await prisma.businessAccount.update({
      where: { id: businessAccountId },
      data: { razorpayAccountId: account.id, routeEnabled: true },
    })

    return account.id
  }

  async splitPayment(opts: {
    razorpayPaymentId: string
    entityType: 'SLOT_BOOKING' | 'ACADEMY_FEE'
    entityId: string
    totalPaise: number
  }) {
    const linkedAccountId = await this.resolveLinkedAccount(opts.entityType, opts.entityId)
    if (!linkedAccountId) {
      console.warn(`[Route] No linked account for ${opts.entityType} ${opts.entityId} — skipping split`)
      return null
    }

    const platformFeePaise =
      opts.entityType === 'ACADEMY_FEE'
        ? PLATFORM_FEE_PAISE_ACADEMY
        : Math.round((opts.totalPaise * PLATFORM_FEE_BASIS_POINTS) / 10000)
    const splitPaise = Math.max(0, opts.totalPaise - platformFeePaise)

    if (splitPaise === 0) {
      console.warn('[Route] Split amount is zero — skipping transfer')
      return null
    }

    return rzpPost(`/v1/payments/${opts.razorpayPaymentId}/transfers`, {
      transfers: [
        {
          account: linkedAccountId,
          amount: splitPaise,
          currency: 'INR',
          notes: { entityType: opts.entityType, entityId: opts.entityId },
          on_hold: false,
        },
      ],
    })
  }

  private async resolveLinkedAccount(entityType: 'SLOT_BOOKING' | 'ACADEMY_FEE', entityId: string) {
    if (entityType === 'SLOT_BOOKING') {
      const booking = await prisma.slotBooking.findUnique({
        where: { id: entityId },
        include: { unit: { include: { arena: { include: { businessAccount: true } } } } },
      })
      return booking?.unit?.arena?.businessAccount?.razorpayAccountId ?? null
    }

    if (entityType === 'ACADEMY_FEE') {
      const enrollment = await prisma.academyEnrollment.findUnique({
        where: { id: entityId },
        include: { academy: { include: { businessAccount: true } } },
      })
      return enrollment?.academy?.businessAccount?.razorpayAccountId ?? null
    }

    return null
  }
}
