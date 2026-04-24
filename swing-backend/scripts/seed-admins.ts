import { PrismaClient } from '@prisma/client'
import bcrypt from 'bcryptjs'

/**
 * Bootstraps the SWING_ADMIN accounts for the internal admin app.
 *
 * Run:
 *   DATABASE_URL="..." ADMIN_SEED_PASSWORD="..." npx tsx scripts/seed-admins.ts
 *
 * Idempotent — re-running updates existing admins with the provided password
 * and keeps their records active.
 */

const ADMINS = [
  { email: 'adi@swingcricketapp.com',     name: 'Adi' },
  { email: 'sangwan@swingcricketapp.com', name: 'Sangwan' },
  { email: 'parth@swingcricketapp.com',   name: 'Parth' },
  { email: 'anupam@swingcricketapp.com',  name: 'Anupam' },
  { email: 'vishwa@swingcricketapp.com',  name: 'Vishwa' },
]

async function main() {
  const password = process.env.ADMIN_SEED_PASSWORD
  if (!password || password.length < 8) {
    console.error('Set ADMIN_SEED_PASSWORD (min 8 chars) before running this script.')
    process.exit(1)
  }

  const prisma = new PrismaClient()
  try {
    const passwordHash = await bcrypt.hash(password, 12)
    for (const a of ADMINS) {
      const existing = await prisma.adminUser.findUnique({ where: { email: a.email } })
      if (existing) {
        await prisma.adminUser.update({
          where: { email: a.email },
          data: { passwordHash, name: a.name, role: 'SWING_ADMIN', isActive: true },
        })
        console.log('updated:', a.email)
      } else {
        const admin = await prisma.adminUser.create({
          data: { email: a.email, passwordHash, name: a.name, role: 'SWING_ADMIN' },
        })
        console.log('created:', admin.id, a.email)
      }
    }
  } finally {
    await prisma.$disconnect()
  }
}

main().catch((err) => { console.error(err); process.exit(1) })
