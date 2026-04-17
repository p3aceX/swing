import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

const toKey = (name: string) => name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '')

const badges: { name: string; description: string; category: string }[] = [
  // ─── BATTING — STANDARD ───
  { name: 'Ten Runs',           category: 'BATTING', description: 'Scored 10+ runs in an innings' },
  { name: 'Quarter Century',    category: 'BATTING', description: 'Scored 25+ runs in an innings' },
  { name: 'Half Century',       category: 'BATTING', description: 'Scored 50+ runs in an innings' },
  { name: 'Seventy Five',       category: 'BATTING', description: 'Scored 75+ runs in an innings' },
  { name: 'Centurion',          category: 'BATTING', description: 'Scored 100+ runs in an innings' },
  { name: 'Ton and a Half',     category: 'BATTING', description: 'Scored 150+ runs in an innings' },
  { name: 'Double Ton',         category: 'BATTING', description: 'Scored 200+ runs in an innings' },
  { name: 'Run-a-Ball Plus',    category: 'BATTING', description: 'Strike rate above 100 (min 10 balls)' },
  { name: 'Express Batter',     category: 'BATTING', description: 'Strike rate above 150 (min 10 balls)' },
  { name: 'Turbo Mode',         category: 'BATTING', description: 'Strike rate above 200 (min 10 balls)' },
  { name: 'Boundary Beginner',  category: 'BATTING', description: 'Hit at least 1 four' },
  { name: 'Boundary Hunter',    category: 'BATTING', description: 'Hit 5+ fours in an innings' },
  { name: 'Boundary King',      category: 'BATTING', description: 'Hit 10+ fours in an innings' },
  { name: 'Boundary Blitz',     category: 'BATTING', description: 'Hit 15+ fours in an innings' },
  { name: 'Sixer Starter',      category: 'BATTING', description: 'Hit at least 1 six' },
  { name: 'Over the Fence',     category: 'BATTING', description: 'Hit 3+ sixes in an innings' },
  { name: 'Hitman Show',        category: 'BATTING', description: 'Hit 5+ sixes in an innings' },
  { name: 'Six Machine',        category: 'BATTING', description: 'Hit 10+ sixes in an innings' },
  { name: 'Ball Watcher',       category: 'BATTING', description: 'Faced 20+ balls in an innings' },
  { name: 'Anchor',             category: 'BATTING', description: 'Faced 50+ balls in an innings' },
  { name: 'Wall',               category: 'BATTING', description: 'Faced 100+ balls in an innings' },
  { name: 'Dot Ball Survivor',  category: 'BATTING', description: 'Survived 30+ dot balls and still scored 30+' },
  { name: 'Not Out Hero',       category: 'BATTING', description: 'Remained not out with 20+ runs' },
  { name: 'Golden Duck',        category: 'BATTING', description: 'Out for a golden duck (0 off 1 ball)' },
  { name: 'Silver Duck',        category: 'BATTING', description: 'Out for 0 runs' },
  { name: 'Opening Dominator',  category: 'BATTING', description: 'Opener scored 40+ runs' },
  { name: 'Chase Starter',      category: 'BATTING', description: 'Scored 30+ runs while chasing, team won' },
  { name: 'Chase Master',       category: 'BATTING', description: 'Scored 50+ runs while chasing, team won' },
  { name: 'Chase Commander',    category: 'BATTING', description: 'Scored 75+ runs while chasing, team won' },
  { name: 'Finisher',           category: 'BATTING', description: 'Remained not out while chasing, team won' },
  { name: 'Match Setter',       category: 'BATTING', description: 'Scored 50+ runs while setting, team won' },

  // ─── BATTING — ELITE ───
  { name: 'Lightning Fifty',    category: 'BATTING', description: 'Scored 50+ runs in 25 balls or fewer' },
  { name: 'Carnage',            category: 'BATTING', description: 'Scored 50+ runs with a strike rate above 250' },
  { name: 'Lone Wolf',          category: 'BATTING', description: 'Scored 60%+ of the team total (team 80+)' },
  { name: 'Pressure Cooker',    category: 'BATTING', description: 'Scored 75+ chasing 150+, team won' },

  // ─── BOWLING — STANDARD ───
  { name: 'First Scalp',        category: 'BOWLING', description: 'Took 1 wicket' },
  { name: 'Brace',              category: 'BOWLING', description: 'Took 2 wickets' },
  { name: 'Three-fer',          category: 'BOWLING', description: 'Took 3 wickets' },
  { name: 'Four-fer',           category: 'BOWLING', description: 'Took 4 wickets' },
  { name: 'Five-fer',           category: 'BOWLING', description: 'Took 5 wickets' },
  { name: 'Grand Slam Bowler',  category: 'BOWLING', description: 'Took 6 wickets in an innings' },
  { name: 'Destruction Mode',   category: 'BOWLING', description: 'Took 7 wickets in an innings' },
  { name: 'Economical',         category: 'BOWLING', description: 'Economy below 6.0 (min 2 overs)' },
  { name: 'Economy Class',      category: 'BOWLING', description: 'Economy below 5.0 (min 2 overs)' },
  { name: 'Miser',              category: 'BOWLING', description: 'Economy below 4.0 (min 2 overs)' },
  { name: 'Untouchable Bowler', category: 'BOWLING', description: 'Economy below 3.0 (min 4 overs)' },
  { name: 'Dot Ball Merchant',  category: 'BOWLING', description: 'Bowled 10+ dot balls' },
  { name: 'Dot Ball Demon',     category: 'BOWLING', description: 'Bowled 18+ dot balls' },
  { name: 'Dot Ball God',       category: 'BOWLING', description: 'Bowled 24+ dot balls' },
  { name: 'Maiden Over',        category: 'BOWLING', description: 'Bowled 1 maiden over' },
  { name: 'Double Maiden',      category: 'BOWLING', description: 'Bowled 2 maiden overs' },
  { name: 'Maiden Master',      category: 'BOWLING', description: 'Bowled 3+ maiden overs' },
  { name: 'Stump Shatterer',    category: 'BOWLING', description: '3W with bowled dismissals' },
  { name: 'Death Dealer',       category: 'BOWLING', description: '2W+ with economy below 8.0 in death overs' },

  // ─── BOWLING — ELITE ───
  { name: 'Perfect Spell',      category: 'BOWLING', description: '4W+ with economy below 4.0 (min 2 overs)' },
  { name: 'Wicket Storm',       category: 'BOWLING', description: 'Took 5+ wickets in an innings' },
  { name: 'All Bowled Out',     category: 'BOWLING', description: '3W+ all bowled dismissals' },

  // ─── FIELDING ───
  { name: 'Catch Collector',    category: 'FIELDING', description: 'Took 1 catch' },
  { name: 'Safe Pair',          category: 'FIELDING', description: 'Took 2 catches' },
  { name: 'Safe Hands',         category: 'FIELDING', description: 'Took 3 catches' },
  { name: 'Spiderman',          category: 'FIELDING', description: 'Took 4+ catches in a match' },
  { name: 'Sharp Shooter',      category: 'FIELDING', description: 'Effected 1 run out' },
  { name: 'Laser Arm',          category: 'FIELDING', description: 'Effected 2 run outs' },
  { name: 'Run Out Machine',    category: 'FIELDING', description: 'Effected 3 run outs' },
  { name: 'Keeper Core',        category: 'FIELDING', description: 'Took 1 stumping' },
  { name: 'Keeper Elite',       category: 'FIELDING', description: 'Took 2 stumpings' },
  { name: 'Gloves of Fire',     category: 'FIELDING', description: 'Took 3+ stumpings' },

  // ─── ALL-ROUNDER ───
  { name: 'Contributer',        category: 'ALL_ROUNDER', description: '20+ runs and 1W in the same match' },
  { name: 'Double Impact',      category: 'ALL_ROUNDER', description: '30+ runs and 2W in the same match' },
  { name: 'Triple Threat',      category: 'ALL_ROUNDER', description: '30+ runs, 2W, and 1 catch in the same match' },
  { name: 'Dominant Force',     category: 'ALL_ROUNDER', description: '50+ runs and 3W in the same match' },
  { name: 'Match Winner',       category: 'ALL_ROUNDER', description: '50+ runs, 4W, team won' },
  { name: 'War Machine',        category: 'ALL_ROUNDER', description: '75+ runs and 3W, team won' },
  { name: 'God Mode',           category: 'ALL_ROUNDER', description: '100+ runs and 5W in the same match' },

  // ─── MATCH SITUATION ───
  { name: 'Winning Feeling',    category: 'GENERAL', description: 'Won a match' },
  { name: 'Defend and Conquer', category: 'GENERAL', description: 'Took 2W+ while defending, team won' },
  { name: 'Captain Fantastic',  category: 'GENERAL', description: 'Won a match as captain' },
  { name: 'Cliff Hanger',       category: 'GENERAL', description: 'Won by 1 run or 1 wicket' },

  // ─── CAREER — RUNS ───
  { name: '100 Career Runs',    category: 'BATTING', description: 'Scored 100+ career runs' },
  { name: '250 Career Runs',    category: 'BATTING', description: 'Scored 250+ career runs' },
  { name: '500 Career Runs',    category: 'BATTING', description: 'Scored 500+ career runs' },
  { name: '1000 Career Runs',   category: 'BATTING', description: 'Scored 1,000+ career runs' },
  { name: '2500 Career Runs',   category: 'BATTING', description: 'Scored 2,500+ career runs' },
  { name: '5000 Career Runs',   category: 'BATTING', description: 'Scored 5,000+ career runs' },
  { name: '10000 Career Runs',  category: 'BATTING', description: 'Scored 10,000+ career runs — the 10K Club' },

  // ─── CAREER — WICKETS ───
  { name: '10 Career Wickets',  category: 'BOWLING', description: 'Took 10+ career wickets' },
  { name: '25 Career Wickets',  category: 'BOWLING', description: 'Took 25+ career wickets' },
  { name: '50 Career Wickets',  category: 'BOWLING', description: 'Took 50+ career wickets' },
  { name: '100 Career Wickets', category: 'BOWLING', description: 'Took 100+ career wickets' },
  { name: '200 Career Wickets', category: 'BOWLING', description: 'Took 200+ career wickets' },
  { name: '500 Career Wickets', category: 'BOWLING', description: 'Took 500+ career wickets' },

  // ─── CAREER — MATCHES ───
  { name: '5 Matches Veteran',   category: 'GENERAL', description: 'Played 5+ matches' },
  { name: '10 Matches Veteran',  category: 'GENERAL', description: 'Played 10+ matches' },
  { name: '25 Matches Veteran',  category: 'GENERAL', description: 'Played 25+ matches' },
  { name: '50 Matches Veteran',  category: 'GENERAL', description: 'Played 50+ matches' },
  { name: '100 Matches Veteran', category: 'GENERAL', description: 'Played 100+ matches' },
  { name: '200 Matches Veteran', category: 'GENERAL', description: 'Played 200+ matches — Iron Man' },

  // ─── CAREER — SIXES ───
  { name: '10 Career Sixes',    category: 'BATTING', description: 'Hit 10+ career sixes' },
  { name: '25 Career Sixes',    category: 'BATTING', description: 'Hit 25+ career sixes' },
  { name: '50 Career Sixes',    category: 'BATTING', description: 'Hit 50+ career sixes' },
  { name: '100 Career Sixes',   category: 'BATTING', description: 'Hit 100+ career sixes' },

  // ─── CAREER — FOURS ───
  { name: '25 Career Fours',    category: 'BATTING', description: 'Hit 25+ career fours' },
  { name: '50 Career Fours',    category: 'BATTING', description: 'Hit 50+ career fours' },
  { name: '100 Career Fours',   category: 'BATTING', description: 'Hit 100+ career fours' },
  { name: '250 Career Fours',   category: 'BATTING', description: 'Hit 250+ career fours' },

  // ─── CAREER — CATCHES ───
  { name: '10 Career Catches',  category: 'FIELDING', description: 'Taken 10+ career catches' },
  { name: '25 Career Catches',  category: 'FIELDING', description: 'Taken 25+ career catches' },
  { name: '50 Career Catches',  category: 'FIELDING', description: 'Taken 50+ career catches' },

  // ─── CAREER — WINS ───
  { name: '5 Wins',             category: 'GENERAL', description: 'Won 5+ matches' },
  { name: '10 Wins',            category: 'GENERAL', description: 'Won 10+ matches' },
  { name: '25 Wins',            category: 'GENERAL', description: 'Won 25+ matches' },
  { name: '50 Wins',            category: 'GENERAL', description: 'Won 50+ matches' },

  // ─── STREAKS ───
  { name: 'Win Streak 3',       category: 'GENERAL', description: 'Won 3 matches in a row' },
  { name: 'Win Streak 5',       category: 'GENERAL', description: 'Won 5 matches in a row' },
  { name: 'Win Streak 10',      category: 'GENERAL', description: 'Won 10 matches in a row' },
  { name: 'On a Roll',          category: 'BATTING',  description: 'Scored 30+ in 4 consecutive innings' },
  { name: 'Bowling Machine',    category: 'BOWLING',  description: 'Took 2W+ in 4 consecutive bowling appearances' },
  { name: 'Duck Free Streak',   category: 'BATTING',  description: '5 consecutive innings without a duck' },
]

async function main() {
  console.log(`Seeding ${badges.length} badges...`)
  let created = 0
  let skipped = 0

  for (const badge of badges) {
    const existing = await prisma.$queryRaw<{ id: string }[]>`
      SELECT id FROM "Badge" WHERE name = ${badge.name} LIMIT 1
    `
    if (existing.length > 0) {
      skipped++
      continue
    }
    const id = `badge_${Math.random().toString(36).slice(2, 18)}`
    await prisma.$executeRaw`
      INSERT INTO "Badge" (id, name, description, category, "triggerRule", "isRare", "createdAt")
      VALUES (${id}, ${badge.name}, ${badge.description}, ${badge.category}, ${toKey(badge.name)}, false, NOW())
    `
    created++
    console.log(`  + ${badge.name}`)
  }

  console.log(`\nDone. Created: ${created}, Skipped (already exist): ${skipped}`)
  await prisma.$disconnect()
}

main().catch((e) => { console.error(e); process.exit(1) })
