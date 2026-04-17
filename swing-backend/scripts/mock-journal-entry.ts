import { PrismaClient } from '@prisma/client'
import { EliteJournalService } from '../apps/api/src/modules/performance/elite-journal.service'

const prisma = new PrismaClient()
const journalSvc = new EliteJournalService()
const playerId = 'cmn3z1ai60012q2vxoe1ehg02'

async function mockEliteEntry() {
  console.log(`\n🚀 LOGGING 5-STEP ELITE JOURNAL FOR: ${playerId}\n`)

  const entry = {
    date: new Date(),
    activity: {
      type: 'NETS',
      durationMinutes: 90,
      intensity: 8,
      drillIds: ['DRILL_LEG_SPIN_SWEEP', 'DRILL_STUMP_HITTING'],
      notes: 'Focused on sweeping leg spinners today. Felt good.'
    },
    mental: {
      confidence: 9,
      focus: 8,
      resilience: 7
    },
    context: {
      sleepQuality: 9,
      hydrationLiters: 3.5,
      soreness: 2,
      fatigue: 3,
      mood: 8,
      stress: 2
    }
  }

  const result = await journalSvc.logEntry(playerId, entry)
  
  console.log('✅ Entry Logged Successfully!')
  console.log('Workload ID:', result.workload.id)
  console.log('Wellness ID:', result.wellness.id)
  console.log('Confidence Logged:', result.wellness.confidence)
  console.log('Drills Logged:', result.workload.drillIds)
}

mockEliteEntry()
  .catch(console.error)
  .finally(() => prisma.$disconnect())
