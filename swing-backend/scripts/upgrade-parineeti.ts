import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()
const playerId = 'cmn3z1ai60012q2vxoe1ehg02'

async function upgradePlayer() {
  console.log(`\n⬆️ UPGRADING PLAYER TO APEX: ${playerId}\n`)

  await prisma.playerCompetitiveProfile.upsert({
    where: { playerId },
    update: { hasPremiumPass: true },
    create: {
      playerId,
      hasPremiumPass: true,
      currentRankKey: 'ROOKIE',
      currentDivision: 1
    }
  })

  console.log('✅ Player is now APEX ELITE. Preparation data will now be visible.')
}

upgradePlayer()
  .catch(console.error)
  .finally(() => prisma.$disconnect())
