/**
 * Rebuild IP for ALL players from scratch using the new IP engine logic.
 * Run: DATABASE_URL=... npx ts-node --esm scripts/rebuild-all-ip.ts
 */

import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

// ─── Config (mirrors performance.config.ts IP_RULES) ─────────────────────────

const FORMAT_MULTIPLIER: Record<string, number> = {
  T10: 0.7, BOX_CRICKET: 0.8, T20: 1.0, CUSTOM: 1.0,
  ONE_DAY: 1.3, TWO_INNINGS: 1.6, TEST: 1.8,
}

const FORMAT_BASELINE: Record<string, { strongSR: number; baseSR: number; strongEcon: number; baseEcon: number }> = {
  T10:         { strongSR: 165, baseSR: 125, strongEcon: 6.6,  baseEcon: 9.4  },
  T20:         { strongSR: 150, baseSR: 120, strongEcon: 6.2,  baseEcon: 8.1  },
  ONE_DAY:     { strongSR: 110, baseSR: 88,  strongEcon: 4.2,  baseEcon: 5.8  },
  TWO_INNINGS: { strongSR: 72,  baseSR: 56,  strongEcon: 2.9,  baseEcon: 3.9  },
  TEST:        { strongSR: 72,  baseSR: 56,  strongEcon: 2.9,  baseEcon: 3.9  },
  BOX_CRICKET: { strongSR: 170, baseSR: 130, strongEcon: 7.5,  baseEcon: 10.5 },
  CUSTOM:      { strongSR: 145, baseSR: 115, strongEcon: 6.0,  baseEcon: 8.0  },
}

const MIN_BALLS_SR   = 8
const MIN_BALLS_ECON = 12
const MAX_IP = 200
const MIN_IP = -60

function sr(runs: number, balls: number) { return balls > 0 ? (runs / balls) * 100 : 0 }
function econ(runs: number, balls: number) { return balls > 0 ? (runs / balls) * 6 : 0 }
function linScale(v: number, fLow: number, fHigh: number, tLow: number, tHigh: number) {
  if (fHigh === fLow) return tLow
  return tLow + ((v - fLow) / (fHigh - fLow)) * (tHigh - tLow)
}
function clamp(v: number, lo: number, hi: number) { return Math.max(lo, Math.min(hi, v)) }

function calculateIp(stat: {
  team: string; runs: number; balls: number; fours: number; sixes: number
  isOut: boolean; wickets: number; legalBallsBowled: number; runsConceded: number
  catches: number; stumpings: number; runOuts: number; isManOfMatch: boolean
}, format: string, winnerTeam: string | null): number {
  const baseline   = FORMAT_BASELINE[format] ?? FORMAT_BASELINE['T20']
  const multiplier = FORMAT_MULTIPLIER[format] ?? 1.0

  let playing    = 10
  let batting    = 0
  let srAdjust   = 0
  let milestones = 0
  let bowling    = 0
  let econAdjust = 0
  let hauls      = 0
  let fielding   = 0
  let result     = 0
  let mvp        = 0

  // ── Batting ────────────────────────────────────────────────
  batting += stat.runs  * 1
  batting += stat.fours * 1
  batting += stat.sixes * 2

  // Duck / golden duck
  if (stat.isOut && stat.runs === 0) {
    milestones += stat.balls <= 1 ? -20 : -12
  }

  // Milestones
  if      (stat.runs >= 150) milestones += 60
  else if (stat.runs >= 100) milestones += 35
  else if (stat.runs >= 50)  milestones += 15

  // SR adjustment
  if (stat.balls >= MIN_BALLS_SR) {
    const strike = sr(stat.runs, stat.balls)
    const { strongSR, baseSR } = baseline

    if (strike >= strongSR) {
      srAdjust = 25
    } else if (strike >= baseSR) {
      srAdjust = Math.round(linScale(strike, baseSR, strongSR, 0, 25))
    } else if (strike < 50) {
      srAdjust = -35
    } else if (strike < 70) {
      srAdjust = -22
    } else if (strike < baseSR * 0.70) {
      srAdjust = -14
    } else if (strike < baseSR * 0.85) {
      srAdjust = -7
    } else {
      srAdjust = 0
    }
  }

  // ── Bowling ────────────────────────────────────────────────
  bowling += stat.wickets * 18

  if      (stat.wickets >= 10) hauls += 50
  else if (stat.wickets >= 5)  hauls += 30
  else if (stat.wickets >= 3)  hauls += 15

  if (stat.legalBallsBowled >= MIN_BALLS_ECON) {
    const economy = econ(stat.runsConceded, stat.legalBallsBowled)
    const { strongEcon, baseEcon } = baseline

    if (economy <= strongEcon) {
      econAdjust = 25
    } else if (economy <= baseEcon) {
      econAdjust = Math.round(linScale(economy, strongEcon, baseEcon, 25, 0))
    } else if (economy > 12) {
      econAdjust = -35
    } else if (economy > 10) {
      econAdjust = -22
    } else if (economy > 8) {
      econAdjust = -12
    } else {
      econAdjust = Math.round(linScale(economy, baseEcon, baseEcon * 1.1, 0, -6))
    }
  }

  // ── Fielding ───────────────────────────────────────────────
  fielding += stat.catches   * 8
  fielding += stat.stumpings * 10
  fielding += stat.runOuts   * 10

  // ── Result ─────────────────────────────────────────────────
  if (winnerTeam === null) {
    result = 0
  } else if (stat.team === winnerTeam) {
    result = 15
  } else {
    result = -15
  }

  // ── MVP ────────────────────────────────────────────────────
  if (stat.isManOfMatch) mvp = 50

  const subtotal = playing + batting + srAdjust + milestones + bowling + econAdjust + hauls + fielding + result + mvp
  return clamp(Math.round(subtotal * multiplier), MIN_IP, MAX_IP)
}

// ─── Rank Config ──────────────────────────────────────────────────────────────

type RankKey = 'ROOKIE' | 'STRIKER' | 'VANGUARD' | 'PHANTOM' | 'DOMINION' | 'ASCENDANT' | 'IMMORTAL' | 'APEX'

const RANK_CONFIG: { key: RankKey; divisions: { division: number; threshold: number }[] }[] = [
  { key: 'ROOKIE',    divisions: [{ division: 3, threshold: 0 }, { division: 2, threshold: 100 }, { division: 1, threshold: 250 }] },
  { key: 'STRIKER',   divisions: [{ division: 3, threshold: 450 }, { division: 2, threshold: 700 }, { division: 1, threshold: 1000 }] },
  { key: 'VANGUARD',  divisions: [{ division: 3, threshold: 1350 }, { division: 2, threshold: 1750 }, { division: 1, threshold: 2200 }] },
  { key: 'PHANTOM',   divisions: [{ division: 3, threshold: 2750 }, { division: 2, threshold: 3350 }, { division: 1, threshold: 4000 }] },
  { key: 'DOMINION',  divisions: [{ division: 3, threshold: 4750 }, { division: 2, threshold: 5600 }, { division: 1, threshold: 6500 }] },
  { key: 'ASCENDANT', divisions: [{ division: 3, threshold: 7500 }, { division: 2, threshold: 8600 }, { division: 1, threshold: 9800 }] },
  { key: 'IMMORTAL',  divisions: [{ division: 3, threshold: 11100 }, { division: 2, threshold: 12500 }, { division: 1, threshold: 14000 }] },
  { key: 'APEX',      divisions: [{ division: 1, threshold: 16000 }] },
]

function resolveRank(ip: number): { rankKey: RankKey; division: number; floor: number } {
  for (let ti = RANK_CONFIG.length - 1; ti >= 0; ti--) {
    const tier = RANK_CONFIG[ti]
    for (let di = tier.divisions.length - 1; di >= 0; di--) {
      if (ip >= tier.divisions[di].threshold) {
        return { rankKey: tier.key, division: tier.divisions[di].division, floor: tier.divisions[di].threshold }
      }
    }
  }
  return { rankKey: 'ROOKIE', division: 3, floor: 0 }
}

function txId() { return `tx_${Date.now().toString(36)}${Math.random().toString(36).slice(2, 9)}` }

// ─── Main ─────────────────────────────────────────────────────────────────────

async function main() {
  console.log('=== IP Rebuild — All Players ===\n')

  // 1. Wipe ledger
  const deleted = await prisma.$executeRaw`DELETE FROM "IpTransaction"`
  console.log(`Cleared ${deleted} existing IpTransaction rows`)

  // 2. Reset all competitive profiles
  await prisma.$executeRaw`
    UPDATE player_competitive_profile
    SET "lifetimeImpactPoints" = 0,
        "rankProgressPoints"   = 0,
        "currentRankKey"       = 'ROOKIE',
        "currentDivision"      = 3,
        "currentDivisionFloor" = 0,
        "winStreak"            = 0,
        "mvpCount"             = 0,
        "lastRankedMatchAt"    = NULL
  `
  console.log('Reset all profiles to ROOKIE III (0 IP)\n')

  // 3. Fetch completed matches chronologically
  const matches = await prisma.match.findMany({
    where:   { status: 'COMPLETED' },
    orderBy: { completedAt: 'asc' },
    select: {
      id: true, winnerId: true, format: true, completedAt: true,
      teamAName: true, teamBName: true, teamAPlayerIds: true, teamBPlayerIds: true,
    },
  })

  console.log(`Replaying ${matches.length} completed matches...\n`)

  // Cache profiles in memory to avoid N+1 DB reads for profile per stat
  const profileCache = new Map<string, { lifetime: number; progress: number; streak: number; mvpCount: number; rankKey: RankKey; division: number; floor: number }>()

  async function getProfile(playerId: string) {
    if (!profileCache.has(playerId)) {
      const p = await prisma.playerCompetitiveProfile.findUnique({ where: { playerId } })
      profileCache.set(playerId, {
        lifetime: p?.lifetimeImpactPoints ?? 0,
        progress: p?.rankProgressPoints ?? 0,
        streak:   p?.winStreak ?? 0,
        mvpCount: p?.mvpCount ?? 0,
        rankKey:  (p?.currentRankKey ?? 'ROOKIE') as RankKey,
        division: p?.currentDivision ?? 3,
        floor:    p?.currentDivisionFloor ?? 0,
      })
    }
    return profileCache.get(playerId)!
  }

  let totalMatches = 0
  let errors       = 0
  const txBatch: {
    id: string; playerProfileId: string; ipDelta: number; reason: string
    matchId: string; rankBefore: string; rankAfter: string; createdAt: Date
  }[] = []

  for (const match of matches) {
    try {
      const stats = await prisma.playerMatchStats.findMany({ where: { matchId: match.id } })
      if (stats.length === 0) continue

      // Resolve winner team letter
      let winnerTeam: string | null = null
      if (match.winnerId === 'A' || match.winnerId === 'B') {
        winnerTeam = match.winnerId
      } else if (match.winnerId) {
        if (match.teamAName === match.winnerId || match.teamAPlayerIds.includes(match.winnerId)) winnerTeam = 'A'
        else if (match.teamBName === match.winnerId || match.teamBPlayerIds.includes(match.winnerId)) winnerTeam = 'B'
      }

      for (const stat of stats) {
        const ipDelta   = calculateIp({ ...stat, legalBallsBowled: Math.round(stat.oversBowled * 6) }, match.format, winnerTeam)
        const profile   = await getProfile(stat.playerProfileId)
        const rankBefore = `${profile.rankKey}:${profile.division}`

        profile.lifetime = profile.lifetime + Math.max(0, ipDelta)
        profile.progress = Math.max(0, profile.progress + ipDelta)
        const newRank    = resolveRank(profile.progress)
        profile.rankKey  = newRank.rankKey
        profile.division = newRank.division
        profile.floor    = newRank.floor
        profile.streak   = stat.team === winnerTeam ? profile.streak + 1 : 0
        if (stat.isManOfMatch) profile.mvpCount++

        txBatch.push({
          id: txId(), playerProfileId: stat.playerProfileId, ipDelta,
          reason: stat.team === winnerTeam ? 'MATCH_PERFORMANCE_WIN' : 'MATCH_PERFORMANCE_LOSS',
          matchId: match.id, rankBefore, rankAfter: `${newRank.rankKey}:${newRank.division}`,
          createdAt: match.completedAt ?? new Date(),
        })
      }

      totalMatches++
      process.stdout.write(`\r  Processed ${totalMatches}/${matches.length} matches...`)
    } catch (err) {
      errors++
      console.error(`\n  [ERROR] Match ${match.id}:`, err)
    }
  }

  // 4. Flush profile cache to DB
  console.log('\n\nFlushing profiles to DB...')
  await Promise.all(
    Array.from(profileCache.entries()).map(([playerId, p]) =>
      prisma.playerCompetitiveProfile.upsert({
        where:  { playerId },
        create: {
          playerId,
          lifetimeImpactPoints: p.lifetime,
          rankProgressPoints:   p.progress,
          currentRankKey:       p.rankKey,
          currentDivision:      p.division,
          currentDivisionFloor: p.floor,
          winStreak:            p.streak,
          mvpCount:             p.mvpCount,
        },
        update: {
          lifetimeImpactPoints: p.lifetime,
          rankProgressPoints:   p.progress,
          currentRankKey:       p.rankKey,
          currentDivision:      p.division,
          currentDivisionFloor: p.floor,
          winStreak:            p.streak,
          mvpCount:             p.mvpCount,
        },
      })
    )
  )

  // 5. Bulk insert transactions (batches of 500)
  console.log(`Inserting ${txBatch.length} IP transactions...`)
  const BATCH = 500
  for (let i = 0; i < txBatch.length; i += BATCH) {
    const chunk = txBatch.slice(i, i + BATCH)
    await Promise.all(
      chunk.map(tx =>
        prisma.$executeRaw`
          INSERT INTO "IpTransaction" (id, "playerProfileId", "ipDelta", reason, "matchId", "rankBefore", "rankAfter", "createdAt")
          VALUES (${tx.id}, ${tx.playerProfileId}, ${tx.ipDelta}, ${tx.reason}, ${tx.matchId}, ${tx.rankBefore}, ${tx.rankAfter}, ${tx.createdAt})
          ON CONFLICT (id) DO NOTHING
        `
      )
    )
  }

  console.log('\nDone!\n')
  console.log(`  Matches processed : ${totalMatches}`)
  console.log(`  Errors            : ${errors}`)
  console.log(`  Transactions      : ${txBatch.length}`)

  // Top 10 by IP
  const top = await prisma.$queryRaw<{ name: string; ip: number; rank: string; div: number }[]>`
    SELECT u.name, p."lifetimeImpactPoints" AS ip, p."currentRankKey" AS rank, p."currentDivision" AS div
    FROM player_competitive_profile p
    JOIN "PlayerProfile" pp ON pp.id = p."playerId"
    JOIN "User" u ON u.id = pp."userId"
    ORDER BY p."lifetimeImpactPoints" DESC
    LIMIT 10
  `

  console.log('\n=== Top 10 Players by IP ===')
  top.forEach((r, i) => {
    console.log(`  ${String(i + 1).padStart(2)}. ${r.name.padEnd(22)} ${String(r.ip).padStart(5)} IP  →  ${r.rank} ${r.div}`)
  })

  await prisma.$disconnect()
}

main().catch(e => { console.error(e); process.exit(1) })
