import { prisma } from '@swing/db'

async function main() {
  const user = await prisma.user.findUnique({
    where: { phone: '+917977690545' },
    select: { id: true, name: true }
  })
  if (!user) { console.log('User not found'); return }
  console.log('User:', user)

  const profile = await prisma.playerProfile.findUnique({
    where: { userId: user.id },
    select: { id: true, matchesPlayed: true, matchesWon: true }
  })
  if (!profile) { console.log('No player profile'); return }
  console.log('Profile:', profile)

  const competitive = await prisma.playerCompetitiveProfile.findUnique({
    where: { playerId: profile.id },
    select: { rankProgressPoints: true, lifetimeImpactPoints: true, currentRankKey: true }
  })
  console.log('Competitive:', competitive)

  const txns = await prisma.ipTransaction.findMany({
    where: { playerProfileId: profile.id },
    orderBy: { createdAt: 'desc' },
    take: 20
  })
  console.log('IP Transactions:', JSON.stringify(txns, null, 2))
}
main().catch(console.error).finally(() => prisma.$disconnect())
