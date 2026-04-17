import fs from 'fs'
import path from 'path'

type ServiceMode = 'api' | 'worker'

function hasFirebaseServiceAccount() {
  const filePath = path.resolve(__dirname, '..', '..', 'firebase-service-account.json')
  return fs.existsSync(filePath) || Boolean(process.env.FIREBASE_SERVICE_ACCOUNT)
}

export function validateRuntimeEnv(service: ServiceMode) {
  const required = new Set<string>(['DATABASE_URL', 'REDIS_URL'])

  if (service === 'api') {
    required.add('JWT_SECRET')
    required.add('JWT_REFRESH_SECRET')
  }

  const missing = Array.from(required).filter((key) => !process.env[key] || process.env[key]?.trim() === '')

  if (!hasFirebaseServiceAccount()) {
    missing.push('FIREBASE_SERVICE_ACCOUNT')
  }

  if (missing.length > 0) {
    throw new Error(`Missing required environment variables: ${missing.join(', ')}`)
  }
}
