import { prisma } from '@swing/db'

async function main() {
  console.log('🛠 Starting repair of Arena data...')
  
  // 1. Set NULL sports to empty array
  const sportsFix = await prisma.$executeRawUnsafe(
    'UPDATE "Arena" SET sports = \'{}\' WHERE sports IS NULL;'
  )
  console.log(`✅ Fixed NULL sports for ${sportsFix} arenas`)

  // 2. Set NULL photoUrls to empty array
  const photosFix = await prisma.$executeRawUnsafe(
    'UPDATE "Arena" SET "photoUrls" = \'{}\' WHERE "photoUrls" IS NULL;'
  )
  console.log(`✅ Fixed NULL photoUrls for ${photosFix} arenas`)

  // 3. Set verified status for the test arena
  const arenaId = 'c00tx3798x9qctp8g5xvp34i2'
  const bhopalFix = await prisma.arena.updateMany({
    where: { id: arenaId },
    data: {
      isVerified: true,
      verifiedAt: new Date(),
      arenaGrade: 'CLUB',
      isActive: true,
    }
  })
  if (bhopalFix.count > 0) {
    console.log(`✅ Verified Bhopal Arena: ${arenaId}`)
  } else {
    console.warn(`⚠️ Bhopal Arena not found by ID: ${arenaId}`)
  }

  console.log('🎉 Repair complete')
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect())
