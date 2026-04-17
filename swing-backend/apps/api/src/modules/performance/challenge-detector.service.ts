import { prisma } from '@swing/db'

export class ChallengeDetectorService {
  async detectAndAwardBadges(matchId: string, playerId: string) {
    const fact = await prisma.matchPlayerFact.findUnique({
      where: { matchId_playerId: { matchId, playerId } },
      include: { match: { include: { innings: true } } },
    })
    if (!fact) return []

    const profile = await prisma.playerProfile.findUnique({
      where: { id: playerId },
      select: {
        totalRuns: true,
        totalWickets: true,
        matchesPlayed: true,
        matchesWon: true,
        sixes: true,
        fours: true,
        catches: true,
      },
    })

    // Innings totals for team context
    const myInnings = fact.match.innings.find((inn) => inn.inningsNumber === fact.inningsNo)
    const oppInnings = fact.match.innings.find((inn) => inn.inningsNumber !== fact.inningsNo)
    const teamTotal = myInnings?.totalRuns ?? 0
    const targetRuns = oppInnings?.totalRuns ?? 0

    // Recent match results for streak challenges
    const recentFacts = await prisma.matchPlayerFact.findMany({
      where: { playerId, matchDate: { lt: fact.matchDate } },
      orderBy: { matchDate: 'desc' },
      take: 10,
      select: { result: true, runs: true, wickets: true, didBat: true, didBowl: true },
    })

    const oversBowled = fact.oversBowled ?? (fact.ballsBowled > 0 ? fact.ballsBowled / 6 : 0)
    const strikeRate = fact.didBat && fact.ballsFaced > 0 ? (fact.runs / fact.ballsFaced) * 100 : 0
    const economy = fact.didBowl && oversBowled > 0 ? fact.runsConceded / oversBowled : 999
    const isChasing = fact.inningsNo === 2
    const isSetting = fact.inningsNo === 1
    const teamWon = fact.result === 'WIN'
    const isOpener = (fact.battingPosition ?? 99) <= 2

    const awards: string[] = []

    // ─────────────────────────────────────────────
    // BATTING — STANDARD
    // ─────────────────────────────────────────────

    if (fact.didBat) {
      // Run milestones per innings
      if (fact.runs >= 10) awards.push('Ten Runs')
      if (fact.runs >= 25) awards.push('Quarter Century')
      if (fact.runs >= 50) awards.push('Half Century')
      if (fact.runs >= 75) awards.push('Seventy Five')
      if (fact.runs >= 100) awards.push('Centurion')
      if (fact.runs >= 150) awards.push('Ton and a Half')
      if (fact.runs >= 200) awards.push('Double Ton')

      // Strike rate tiers (min 10 balls)
      if (fact.ballsFaced >= 10 && strikeRate > 100) awards.push('Run-a-Ball Plus')
      if (fact.ballsFaced >= 10 && strikeRate > 150) awards.push('Express Batter')
      if (fact.ballsFaced >= 10 && strikeRate > 200) awards.push('Turbo Mode')

      // Boundary milestones
      if (fact.fours >= 1)  awards.push('Boundary Beginner')
      if (fact.fours >= 5)  awards.push('Boundary Hunter')
      if (fact.fours >= 10) awards.push('Boundary King')
      if (fact.fours >= 15) awards.push('Boundary Blitz')
      if (fact.sixes >= 1)  awards.push('Sixer Starter')
      if (fact.sixes >= 3)  awards.push('Over the Fence')
      if (fact.sixes >= 5)  awards.push('Hitman Show')
      if (fact.sixes >= 10) awards.push('Six Machine')

      // Patience / survival
      if (fact.ballsFaced >= 20)  awards.push('Ball Watcher')
      if (fact.ballsFaced >= 50)  awards.push('Anchor')
      if (fact.ballsFaced >= 100) awards.push('Wall')
      if (fact.dotBalls >= 30 && fact.runs >= 30) awards.push('Dot Ball Survivor')

      // Dismissal type achievements
      if (fact.wasNotOut && fact.runs >= 20) awards.push('Not Out Hero')
      if (fact.runs === 0 && fact.ballsFaced === 1 && fact.dismissalType) awards.push('Golden Duck')
      if (fact.runs === 0 && fact.dismissalType) awards.push('Silver Duck')

      // Opener
      if (isOpener && fact.runs >= 40) awards.push('Opening Dominator')

      // Chase related
      if (isChasing && fact.runs >= 30 && teamWon) awards.push('Chase Starter')
      if (isChasing && fact.runs >= 50 && teamWon) awards.push('Chase Master')
      if (isChasing && fact.runs >= 75 && teamWon) awards.push('Chase Commander')
      if (isChasing && fact.wasNotOut && teamWon) awards.push('Finisher')

      // Setting related
      if (isSetting && fact.runs >= 50 && teamWon) awards.push('Match Setter')

      // General
      if (teamWon) awards.push('Winning Feeling')
    }

    // ─────────────────────────────────────────────
    // BATTING — ELITE
    // ─────────────────────────────────────────────

    if (fact.didBat) {
      if (fact.runs >= 50 && fact.ballsFaced <= 25) awards.push('Lightning Fifty')
      if (fact.runs >= 50 && strikeRate > 250) awards.push('Carnage')

      // Lone wolf — 60%+ of team total (min team 80)
      if (teamTotal >= 80 && fact.runs > 0 && fact.runs / teamTotal >= 0.6) {
        awards.push('Lone Wolf')
      }

      // Pressure cooker — 75+ chasing 150+, win
      if (isChasing && targetRuns >= 150 && fact.runs >= 75 && teamWon) {
        awards.push('Pressure Cooker')
      }
    }

    // ─────────────────────────────────────────────
    // BOWLING — STANDARD
    // ─────────────────────────────────────────────

    if (fact.didBowl) {
      // Wicket milestones
      if (fact.wickets >= 1) awards.push('First Scalp')
      if (fact.wickets >= 2) awards.push('Brace')
      if (fact.wickets >= 3) awards.push('Three-fer')
      if (fact.wickets >= 4) awards.push('Four-fer')
      if (fact.wickets >= 5) awards.push('Five-fer')
      if (fact.wickets >= 6) awards.push('Grand Slam Bowler')
      if (fact.wickets >= 7) awards.push('Destruction Mode')

      // Economy tiers (min 2 overs)
      if (oversBowled >= 2 && economy < 6.0) awards.push('Economical')
      if (oversBowled >= 2 && economy < 5.0) awards.push('Economy Class')
      if (oversBowled >= 2 && economy < 4.0) awards.push('Miser')
      if (oversBowled >= 4 && economy < 3.0) awards.push('Untouchable Bowler')

      // Dot ball achievements
      if (fact.dotBalls >= 10) awards.push('Dot Ball Merchant')
      if (fact.dotBalls >= 18) awards.push('Dot Ball Demon')
      if (fact.dotBalls >= 24) awards.push('Dot Ball God')

      // Maiden overs
      if (fact.maidens >= 1) awards.push('Maiden Over')
      if (fact.maidens >= 2) awards.push('Double Maiden')
      if (fact.maidens >= 3) awards.push('Maiden Master')

      // Specific dismissal
      if (fact.wickets >= 3 && fact.dismissalType === 'BOWLED') awards.push('Stump Shatterer')

      // Death bowling
      if (oversBowled >= 2 && economy < 8.0 && fact.wickets >= 2) awards.push('Death Dealer')
    }

    // ─────────────────────────────────────────────
    // BOWLING — ELITE
    // ─────────────────────────────────────────────

    if (fact.didBowl) {
      if (fact.wickets >= 4 && oversBowled >= 2 && economy < 4.0) awards.push('Perfect Spell')
      if (fact.wickets >= 5) awards.push('Wicket Storm')
      if (fact.wickets >= 3 && fact.dismissalType === 'BOWLED') awards.push('All Bowled Out')
    }

    // ─────────────────────────────────────────────
    // FIELDING — STANDARD & ELITE
    // ─────────────────────────────────────────────

    if (fact.catches >= 1) awards.push('Catch Collector')
    if (fact.catches >= 2) awards.push('Safe Pair')
    if (fact.catches >= 3) awards.push('Safe Hands')
    if (fact.catches >= 4) awards.push('Spiderman')
    if (fact.runOuts >= 1) awards.push('Sharp Shooter')
    if (fact.runOuts >= 2) awards.push('Laser Arm')
    if (fact.runOuts >= 3) awards.push('Run Out Machine')
    if (fact.stumpings >= 1) awards.push('Keeper Core')
    if (fact.stumpings >= 2) awards.push('Keeper Elite')
    if (fact.stumpings >= 3) awards.push('Gloves of Fire')

    // ─────────────────────────────────────────────
    // ALL-ROUNDER
    // ─────────────────────────────────────────────

    if (fact.didBat && fact.didBowl) {
      if (fact.runs >= 20 && fact.wickets >= 1) awards.push('Contributer')
      if (fact.runs >= 30 && fact.wickets >= 2) awards.push('Double Impact')
      if (fact.runs >= 30 && fact.wickets >= 2 && fact.catches >= 1) awards.push('Triple Threat')
      if (fact.runs >= 50 && fact.wickets >= 3) awards.push('Dominant Force')
      if (fact.runs >= 50 && fact.wickets >= 4 && teamWon) awards.push('Match Winner')
      if (fact.runs >= 75 && fact.wickets >= 3 && teamWon) awards.push('War Machine')
      if (fact.runs >= 100 && fact.wickets >= 5) awards.push('God Mode')
    }

    // ─────────────────────────────────────────────
    // MATCH SITUATION
    // ─────────────────────────────────────────────

    if (isSetting && teamWon && fact.didBowl && fact.wickets >= 2) awards.push('Defend and Conquer')
    if (fact.isCaptain && teamWon) awards.push('Captain Fantastic')

    if (teamWon && fact.match.winMargin) {
      const margin = fact.match.winMargin.toLowerCase()
      if (margin.includes('1 run') || margin.includes('1 wicket')) awards.push('Cliff Hanger')
    }

    // ─────────────────────────────────────────────
    // CAREER MILESTONES
    // ─────────────────────────────────────────────

    if (profile) {
      for (const m of [100, 250, 500, 1000, 2500, 5000, 10000]) {
        if (profile.totalRuns >= m) awards.push(`${m} Career Runs`)
      }
      for (const m of [10, 25, 50, 100, 200, 500]) {
        if (profile.totalWickets >= m) awards.push(`${m} Career Wickets`)
      }
      for (const m of [5, 10, 25, 50, 100, 200]) {
        if (profile.matchesPlayed >= m) awards.push(`${m} Matches Veteran`)
      }
      for (const m of [10, 25, 50, 100]) {
        if (profile.sixes >= m) awards.push(`${m} Career Sixes`)
      }
      for (const m of [25, 50, 100, 250]) {
        if (profile.fours >= m) awards.push(`${m} Career Fours`)
      }
      for (const m of [10, 25, 50]) {
        if (profile.catches >= m) awards.push(`${m} Career Catches`)
      }
      for (const m of [5, 10, 25, 50]) {
        if (profile.matchesWon >= m) awards.push(`${m} Wins`)
      }
    }

    // ─────────────────────────────────────────────
    // CONSISTENCY / STREAKS
    // ─────────────────────────────────────────────

    if (recentFacts.length >= 3) {
      const last3Won = recentFacts.slice(0, 3).every((f) => f.result === 'WIN')
      const last5Won = recentFacts.length >= 5 && recentFacts.slice(0, 5).every((f) => f.result === 'WIN')
      const last10Won = recentFacts.length >= 10 && recentFacts.slice(0, 10).every((f) => f.result === 'WIN')
      if (last3Won && teamWon) awards.push('Win Streak 3')
      if (last5Won && teamWon) awards.push('Win Streak 5')
      if (last10Won && teamWon) awards.push('Win Streak 10')

      const last3Bat = recentFacts.slice(0, 3).filter((f) => f.didBat)
      if (last3Bat.length === 3 && last3Bat.every((f) => f.runs >= 30) && fact.runs >= 30) {
        awards.push('On a Roll')
      }

      const last3Bowl = recentFacts.slice(0, 3).filter((f) => f.didBowl)
      if (last3Bowl.length === 3 && last3Bowl.every((f) => f.wickets >= 2) && fact.wickets >= 2) {
        awards.push('Bowling Machine')
      }

      const last5Bat = recentFacts.slice(0, 5).filter((f) => f.didBat)
      if (last5Bat.length >= 5 && last5Bat.every((f) => f.runs > 0) && fact.runs > 0) {
        awards.push('Duck Free Streak')
      }
    }

    if (awards.length > 0) {
      await this.saveAwards(playerId, awards, matchId)
    }

    return awards
  }

  async rebuildPlayerBadges(playerId: string) {
    const facts = await prisma.matchPlayerFact.findMany({
      where: { playerId },
      orderBy: [{ matchDate: 'asc' }, { createdAt: 'asc' }],
      select: { matchId: true },
    })

    const existingCount = await prisma.playerBadge.count({
      where: { playerProfileId: playerId },
    })

    await prisma.playerBadge.deleteMany({
      where: { playerProfileId: playerId },
    })

    for (const fact of facts) {
      await this.detectAndAwardBadges(fact.matchId, playerId)
    }

    const created = await prisma.playerBadge.count({
      where: { playerProfileId: playerId },
    })

    return {
      deleted: existingCount,
      created,
    }
  }

  private async saveAwards(playerId: string, badgeKeys: string[], matchId: string) {
    for (const name of badgeKeys) {
      const badge = await prisma.badge.findUnique({
        where: { name },
        select: { id: true },
      })
      if (!badge) continue

      const existing = await prisma.playerBadge.findFirst({
        where: { playerProfileId: playerId, badgeId: badge.id },
      })
      if (!existing) {
        await prisma.playerBadge.create({
          data: {
            playerProfileId: playerId,
            badgeId: badge.id,
            matchId,
            awardedAt: new Date(),
            awardedReason: `Achieved in Match #${matchId}`,
          },
        })
      }
    }
  }
}
