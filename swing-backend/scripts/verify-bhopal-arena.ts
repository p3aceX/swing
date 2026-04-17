import { prisma } from '@swing/db'

async function main() {
  const arenaId = 'c00tx3798x9qctp8g5xvp34i2'
  console.log(`🚀 Verifying Arena: ${arenaId}`)

  const arena = await prisma.arena.findUnique({ where: { id: arenaId } })
  if (!arena) {
    console.error('❌ Arena not found')
    process.exit(1)
  }

  console.log('Current status:', {
    name: arena.name,
    city: arena.city,
    isVerified: arena.isVerified,
    sports: arena.sports,
    isActive: arena.isActive
  })

  const updated = await prisma.arena.update({
    where: { id: arenaId },
    data: {
      isVerified: true,
      verifiedAt: new Date(),
      arenaGrade: 'CLUB',
      // If sports is null, let's also fix it to be [CRICKET] if that's what's missing
      ...(arena.sports === null || arena.sports.length === 0 ? { sports: ['CRICKET'] } : {})
    }
  })

  console.log('✅ Arena updated successfully:', {
    id: updated.id,
    isVerified: updated.isVerified,
    verifiedAt: updated.verifiedAt,
    arenaGrade: updated.arenaGrade,
    sports: updated.sports
  })
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect())
