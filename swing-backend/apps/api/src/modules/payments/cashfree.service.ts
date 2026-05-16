import crypto from 'crypto'
import { AppError } from '../../lib/errors'

const isProd = !(process.env.CASHFREE_APP_ID || '').startsWith('TEST')
const BASE = isProd ? 'https://api.cashfree.com' : 'https://sandbox.cashfree.com'
const API_VERSION = '2023-08-01'

function authHeaders(): Record<string, string> {
  return {
    'Content-Type': 'application/json',
    'x-api-version': API_VERSION,
    'x-client-id': process.env.CASHFREE_APP_ID || '',
    'x-client-secret': process.env.CASHFREE_SECRET_KEY || '',
  }
}

export class CashfreeService {
  async makeRequest(method: string, path: string, body?: unknown): Promise<any> {
    const res = await fetch(`${BASE}${path}`, {
      method,
      headers: authHeaders(),
      body: body !== undefined ? JSON.stringify(body) : undefined,
    })
    const text = await res.text()
    if (!res.ok) {
      throw new AppError('CASHFREE_API_ERROR', `Cashfree API ${method} ${path} failed: ${text}`, 502)
    }
    return JSON.parse(text)
  }

  async createOrder(opts: {
    orderId: string
    amountPaise: number
    customerId: string
    customerPhone: string
    customerEmail?: string
    customerName: string
    notifyUrl: string
  }): Promise<{ payment_session_id: string; order_id: string; order_status: string }> {
    return this.makeRequest('POST', '/pg/orders', {
      order_id: opts.orderId,
      order_amount: opts.amountPaise / 100,
      order_currency: 'INR',
      customer_details: {
        customer_id: opts.customerId,
        customer_phone: opts.customerPhone,
        customer_name: opts.customerName,
        ...(opts.customerEmail ? { customer_email: opts.customerEmail } : {}),
      },
      order_meta: {
        notify_url: opts.notifyUrl,
      },
    })
  }

  async verifyOrder(orderId: string): Promise<any[]> {
    return this.makeRequest('GET', `/pg/orders/${encodeURIComponent(orderId)}/payments`)
  }

  async createPaymentLink(opts: {
    linkId: string
    amountPaise: number
    purpose: string
    customerPhone: string
    customerName: string
    notifyUrl: string
  }): Promise<{ link_url: string; link_id: string }> {
    return this.makeRequest('POST', '/pg/links', {
      link_id: opts.linkId,
      link_amount: opts.amountPaise / 100,
      link_currency: 'INR',
      link_purpose: opts.purpose,
      customer_details: {
        customer_phone: opts.customerPhone,
        customer_name: opts.customerName,
      },
      link_notify: {
        send_sms: false,
        send_email: false,
      },
      link_auto_reminders: false,
      link_meta: {
        notify_url: opts.notifyUrl,
      },
    })
  }

  verifyWebhookSignature(rawBody: string, timestamp: string, signature: string): boolean {
    const secret = process.env.CASHFREE_WEBHOOK_SECRET || ''
    if (!secret) return true // skip if not configured
    const expectedSignature = crypto
      .createHmac('sha256', secret)
      .update(timestamp + rawBody)
      .digest('base64')
    return expectedSignature === signature
  }

  async validateBankAccount(opts: {
    name: string
    phone: string
    bankAccount: string
    ifsc: string
  }): Promise<{ account_status: 'VALID' | 'INVALID'; name_at_bank?: string }> {
    return this.makeRequest('POST', '/verification/bank-account/sync', {
      bank_account: opts.bankAccount,
      ifsc: opts.ifsc,
      name: opts.name,
      phone: opts.phone,
    })
  }
}
