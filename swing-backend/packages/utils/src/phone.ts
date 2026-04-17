export function normalizePhone(phone: string): string {
  const cleaned = phone.replace(/[\s\-\(\)]/g, '')
  if (cleaned.startsWith('+')) return cleaned
  if (cleaned.startsWith('91') && cleaned.length === 12) return `+${cleaned}`
  if (cleaned.length === 10) return `+91${cleaned}`
  return cleaned
}

export function generateOtp(): string {
  return Math.floor(100000 + Math.random() * 900000).toString()
}
