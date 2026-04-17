import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()
const playerId = 'cmn3z1ai60012q2vxoe1ehg02'

async function mockData() {
  console.log(`\n🧪 GENERATING MOCK DATA FOR FRONTEND: ${playerId}\n`)

  // 1. Create Mock Insights
  await prisma.eliteInsight.deleteMany({ where: { playerId } })
  await prisma.eliteInsight.createMany({
    data: [
      {
        playerId,
        category: 'TACTICAL',
        title: 'Leg Spin Struggle',
        message: 'Your SR vs Leg Spin is 60. Try the Sweep-Drill in your next session.',
        priority: 3
      },
      {
        playerId,
        category: 'PHYSICAL',
        title: 'Recovery Warning',
        message: 'Sleep quality was low for 2 days. Prioritize rest tonight to avoid injury.',
        priority: 2
      }
    ]
  })

  // 2. Create more Journal entries to fill "Streak" and "Load"
  // Create entries for the last 3 days
  for (let i = 0; i < 3; i++) {
    const date = new Date()
    date.setDate(date.getDate() - i)
    const startOfDay = new Date(date)
    startOfDay.setHours(0, 0, 0, 0)

    await prisma.playerWorkloadEvent.create({
      data: {
        playerId,
        date,
        type: 'NETS',
        durationMinutes: 60,
        intensity: 7,
        drillIds: ['DRILL_1'],
        source: 'ELITE_JOURNAL'
      }
    })

    await prisma.playerWellnessCheckin.upsert({
      where: { playerId_date: { playerId, date: startOfDay } },
      update: { soreness: 3, fatigue: 4, sleepQuality: 8, mood: 7, confidence: 8, focus: 8, resilience: 8, hydrationLiters: 3 },
      create: {
        playerId,
        date: startOfDay,
        soreness: 3,
        fatigue: 4,
        sleepQuality: 8,
        mood: 7,
        confidence: 8,
        focus: 8,
        resilience: 8,
        hydrationLiters: 3,
        stress: 3,
        painTightness: 0
      }
    })
  }

  console.log('✅ Mock data generated. Frontend should now see Insights, Streak, and Load.')
}

mockData()
  .catch(console.error)
  .finally(() => prisma.$disconnect())
