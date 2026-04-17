import admin from 'firebase-admin'
import fs from 'fs'
import path from 'path'

let initialized = false

export function getFirebaseAdmin(): admin.app.App {
  if (!initialized) {
    // Try file first (more reliable than env var for JSON with PEM keys)
    const filePath = path.resolve(__dirname, '..', '..', 'firebase-service-account.json')
    let parsed: { private_key?: string; client_email?: string; project_id?: string }

    if (fs.existsSync(filePath)) {
      parsed = JSON.parse(fs.readFileSync(filePath, 'utf-8'))
    } else {
      const serviceAccount = process.env.FIREBASE_SERVICE_ACCOUNT
      if (!serviceAccount) throw new Error('FIREBASE_SERVICE_ACCOUNT env var not set and firebase-service-account.json not found')
      parsed = JSON.parse(serviceAccount)
      if (parsed.private_key) {
        parsed.private_key = parsed.private_key.replace(/\\n/g, '\n')
      }
    }

    admin.initializeApp({ credential: admin.credential.cert(parsed as admin.ServiceAccount) })
    initialized = true
  }
  return admin.app()
}

export async function verifyFirebaseToken(idToken: string): Promise<{ phone?: string; email?: string; uid: string }> {
  const app = getFirebaseAdmin()
  const decoded = await app.auth().verifyIdToken(idToken)
  if (!decoded.phone_number && !decoded.email) {
    throw new Error('Firebase token has no phone number or email')
  }
  return { phone: decoded.phone_number, email: decoded.email, uid: decoded.uid }
}

export async function sendPushNotification(
  tokens: string[],
  title: string,
  body: string,
  data?: Record<string, string>,
): Promise<{ successCount: number; invalidTokens: string[] }> {
  if (tokens.length === 0) return { successCount: 0, invalidTokens: [] }
  const app = getFirebaseAdmin()
  const messages = tokens.map(token => ({ token, notification: { title, body }, data: data || {} }))
  const response = await app.messaging().sendEach(messages)

  const invalidTokens: string[] = []
  response.responses.forEach((resp, idx) => {
    if (!resp.success && resp.error?.code === 'messaging/registration-token-not-registered') {
      invalidTokens.push(tokens[idx])
    }
  })

  return { successCount: response.successCount, invalidTokens }
}
