import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()
const playerId = 'cmn3z1ai60012q2vxoe1ehg02'

async function inspectJournal() {
  console.log(`\n📖 --- JOURNAL INSPECTION FOR PLAYER: ${playerId} ---\n`)

  const [workloads, wellness] = await Promise.all([
    prisma.playerWorkloadEvent.findMany({
      where: { playerId },
      orderBy: { date: 'desc' },
      take: 5
    }),
    prisma.playerWellnessCheckin.findMany({
      where: { playerId },
      orderBy: { date: 'desc' },
      take: 5
    })
  ])

  console.log('🏋️ Recent Training Logs (The Work):')
  if (workloads.length === 0) console.log('   No training logs found.')
  workloads.forEach(w => {
    console.log(`   - [${w.date.toISOString().split('T')[0]}] ${w.type}: ${w.durationMinutes} mins | Intensity: ${w.intensity}/10 | Drills: ${w.drillIds.join(', ') || 'None'} | Source: ${w.source}`)
  })

  console.log('\n🧠 Recent Wellness & Mental (The State):')
  if (wellness.length === 0) console.log('   No wellness check-ins found.')
  wellness.forEach(w => {
    console.log(`   - [${w.date.toISOString().split('T')[0]}] Confidence: ${w.confidence}/10 | Focus: ${w.focus}/10 | Resilience: ${w.resilience}/10 | Hydration: ${w.hydrationLiters}L | Sleep Quality: ${w.sleepQuality}/10`)
  })

  console.log('\n--- END OF LOG ---\n')
}

inspectJournal()
  .catch(console.error)
  .finally(() => prisma.$disconnect())
