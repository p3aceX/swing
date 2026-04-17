import axios from 'axios'

export async function sendOtpSms(phone: string, otp: string): Promise<void> {
  if (process.env.NODE_ENV === 'development') {
    console.log(`[DEV OTP] ${phone}: ${otp}`)
    return
  }
  try {
    await axios.post(
      'https://api.msg91.com/api/v5/otp',
      {
        template_id: process.env.MSG91_OTP_TEMPLATE_ID,
        mobile: phone.replace('+', ''),
        authkey: process.env.MSG91_AUTH_KEY,
        otp,
      },
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (err) {
    console.error('SMS OTP send failed:', err)
    throw new Error('Failed to send OTP')
  }
}

export async function sendWhatsApp(phone: string, templateName: string, params: Record<string, string>): Promise<void> {
  if (process.env.NODE_ENV === 'development') {
    console.log(`[DEV WhatsApp] ${phone}: ${templateName}`, params)
    return
  }
  try {
    await axios.post(
      process.env.WHATSAPP_API_URL!,
      { mobile: phone.replace('+', ''), template: templateName, params },
      { headers: { authkey: process.env.MSG91_AUTH_KEY, 'Content-Type': 'application/json' } }
    )
  } catch (err) {
    console.error('WhatsApp send failed:', err)
  }
}
