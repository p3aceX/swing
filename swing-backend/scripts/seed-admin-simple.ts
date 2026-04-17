import { PrismaClient } from '@prisma/client'
import bcrypt from 'bcryptjs'

const EMAIL = 'sangwan@swingcricketapp.com'
const PASSWORD = 'Usangwan#123'
const NAME = 'Sangwan'

async function main() {
  const prisma = new PrismaClient()
  try {
    const existing = await prisma.adminUser.findUnique({ where: { email: EMAIL } })
    const passwordHash = await bcrypt.hash(PASSWORD, 12)

    if (existing) {
      await prisma.adminUser.update({ where: { email: EMAIL }, data: { passwordHash, name: NAME, role: 'SWING_ADMIN', isActive: true } })
      console.log('Admin updated:', EMAIL)
    } else {
      const admin = await prisma.adminUser.create({ data: { email: EMAIL, passwordHash, name: NAME, role: 'SWING_ADMIN' } })
      console.log('Admin created:', admin.id, EMAIL)
    }
  } finally {
    await prisma.$disconnect()
  }
}

main().catch(err => { console.error(err); process.exit(1) })
