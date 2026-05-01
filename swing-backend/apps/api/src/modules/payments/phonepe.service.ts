import { AppError } from '../../lib/errors'
import crypto from 'crypto'

const PHONEPE_BASE = 'https://api.phonepe.com/apis/pg/v2'
const PHONEPE_CHECKOUT_BASE = 'https://api.phonepe.com/apis/pg/checkout/v2'

// In-process token cache — cleared on process restart
let _cachedToken: { value: string; expiresAt: number } | null = null

export class PhonePeService {
  // ── Auth token ─────────────────────────────────────────────────────────────

  private async getAuthToken(): Promise<string> {
    const now = Date.now()
    // Reuse token if it has >60s left
    if (_cachedToken && _cachedToken.expiresAt > now + 60_000) {
      return _cachedToken.value
    }

    const clientId = process.env.PHONEPE_CLIENT_ID
    const clientSecret = process.env.PHONEPE_CLIENT_SECRET
    if (!clientId || !clientSecret) {
      throw new AppError('PHONEPE_NOT_CONFIGURED', 'PhonePe credentials are not set', 500)
    }

    const body = new URLSearchParams({
      client_id: clientId,
      client_secret: clientSecret,
      client_version: '1',
      grant_type: 'client_credentials',
    })

    const res = await fetch(`${PHONEPE_BASE}/auth/token`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: body.toString(),
    })

    if (!res.ok) {
      const text = await res.text()
      throw new AppError('PHONEPE_AUTH_FAILED', `PhonePe auth failed (${res.status}): ${text}`, 502)
    }

    const data = (await res.json()) as { access_token: string; expires_in: number }
    _cachedToken = {
      value: data.access_token,
      expiresAt: now + data.expires_in * 1000,
    }
    return _cachedToken.value
  }

  // ── Create order ───────────────────────────────────────────────────────────

  async createOrder(
    amountPaise: number,
    opts?: {
      redirectUrl?: string
      message?: string
      prefillPhone?: string
      metaInfo?: Record<string, string>
    },
  ): Promise<{
    orderId: string
    phonePeOrderId?: string
    token?: string
    redirectUrl?: string
    state?: string
  }> {
    const accessToken = await this.getAuthToken()
    const merchantOrderId = `SWING_${Date.now()}_${crypto.randomBytes(4).toString('hex').toUpperCase()}`
    const redirectUrl = opts?.redirectUrl ?? process.env.PHONEPE_WEB_REDIRECT_URL ?? 'https://www.swingcricketapp.com'

    const res = await fetch(`${PHONEPE_CHECKOUT_BASE}/pay`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `O-Bearer ${accessToken}`,
      },
      body: JSON.stringify({
        merchantOrderId,
        amount: amountPaise,
        expireAfter: 1200,
        paymentFlow: {
          type: 'PG_CHECKOUT',
          message: opts?.message ?? 'Payment for arena booking',
          merchantUrls: {
            redirectUrl,
          },
        },
        ...(opts?.prefillPhone
          ? { prefillUserLoginDetails: { phoneNumber: opts.prefillPhone } }
          : {}),
        ...(opts?.metaInfo ? { metaInfo: opts.metaInfo } : {}),
      }),
    })

    if (!res.ok) {
      const text = await res.text()
      throw new AppError('PHONEPE_ORDER_FAILED', `PhonePe create order failed (${res.status}): ${text}`, 502)
    }

    const data = (await res.json()) as {
      orderId?: string
      state?: string
      redirectUrl?: string
      token?: string | { value?: string }
    }

    // Extract token — PhonePe may return it as a string or as { value }
    const rawToken = data.token
    const tokenValue =
      typeof rawToken === 'string'
        ? rawToken
        : (rawToken as any)?.value ?? ''

    if (!data.redirectUrl && !tokenValue) {
      throw new AppError('PHONEPE_NO_CHECKOUT_URL', 'PhonePe did not return a checkout URL', 502)
    }

    return {
      orderId: merchantOrderId,
      phonePeOrderId: data.orderId,
      token: tokenValue || undefined,
      redirectUrl: data.redirectUrl,
      state: data.state,
    }
  }

  // ── Check order status ─────────────────────────────────────────────────────

  async checkOrderStatus(merchantOrderId: string): Promise<{ state: string; amount: number }> {
    const accessToken = await this.getAuthToken()

    const res = await fetch(`${PHONEPE_BASE}/orders/${merchantOrderId}/status`, {
      method: 'GET',
      headers: { Authorization: `O-Bearer ${accessToken}` },
    })

    if (!res.ok) {
      const text = await res.text()
      throw new AppError('PHONEPE_STATUS_FAILED', `PhonePe order status failed (${res.status}): ${text}`, 502)
    }

    const data = (await res.json()) as { state: string; amount: number }
    return { state: data.state, amount: data.amount }
  }
}
