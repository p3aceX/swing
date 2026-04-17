/**
 * Seed script: create a Firebase email/password user and matching DB record with SWING_ADMIN role.
 * Run from the repo root:
 *   cd apps/api && tsx --env-file=.env ../../scripts/create-admin.ts
 */

import admin from 'firebase-admin'
import fs from 'fs'
import path from 'path'
import { PrismaClient } from '@prisma/client'

const EMAIL = 'sangwan@swingcricketapp.com'
const PASSWORD = 'Usangwan#123'
const NAME = 'Sangwan'

async function main() {
  // ── Firebase Admin ─────────────────────────────────────────
  const filePath = path.resolve(__dirname, '..', 'apps', 'api', 'firebase-service-account.json')
  let serviceAccount: object

  if (fs.existsSync(filePath)) {
    serviceAccount = JSON.parse(fs.readFileSync(filePath, 'utf-8'))
  } else {
    const raw = process.env.FIREBASE_SERVICE_ACCOUNT
    if (!raw) throw new Error('FIREBASE_SERVICE_ACCOUNT env var not set and firebase-service-account.json not found')
    const parsed = JSON.parse(raw)
    if (parsed.private_key) parsed.private_key = parsed.private_key.replace(/\\n/g, '\n')
    serviceAccount = parsed
  }

  if (!admin.apps.length) {
    admin.initializeApp({ credential: admin.credential.cert(serviceAccount as admin.ServiceAccount) })
  }

  // ── Create or fetch Firebase user ──────────────────────────
  let firebaseUid: string
  try {
    const existing = await admin.auth().getUserByEmail(EMAIL)
    firebaseUid = existing.uid
    // Update password in case it changed
    await admin.auth().updateUser(firebaseUid, { password: PASSWORD })
    console.log(`Firebase user already exists — uid: ${firebaseUid}`)
  } catch (err: any) {
    if (err.code === 'auth/user-not-found') {
      const created = await admin.auth().createUser({ email: EMAIL, password: PASSWORD, displayName: NAME })
      firebaseUid = created.uid
      console.log(`Firebase user created — uid: ${firebaseUid}`)
    } else {
      throw err
    }
  }

  // ── Create or update DB record ─────────────────────────────
  const prisma = new PrismaClient()

  try {
    const existing = await prisma.user.findUnique({ where: { email: EMAIL } })

    if (existing) {
      const updated = await prisma.user.update({
        where: { email: EMAIL },
        data: {
          roles: { set: ['SWING_ADMIN'] as any[] },
          activeRole: 'SWING_ADMIN' as any,
          name: NAME,
        },
      })
      console.log(`DB user updated — id: ${updated.id}, roles: ${updated.roles}`)
    } else {
      // phone is required in the schema; use a placeholder derived from the Firebase UID
      const created = await prisma.user.create({
        data: {
          email: EMAIL,
          phone: `admin:${firebaseUid}`,
          name: NAME,
          roles: ['SWING_ADMIN'] as any[],
          activeRole: 'SWING_ADMIN' as any,
          language: 'en',
        },
      })
      console.log(`DB user created — id: ${created.id}, roles: ${created.roles}`)
    }
  } finally {
    await prisma.$disconnect()
  }

  console.log('\nDone! Admin account ready:')
  console.log(`  email:    ${EMAIL}`)
  console.log(`  password: ${PASSWORD}`)
}

main().catch(err => {
  console.error(err)
  process.exit(1)
})
