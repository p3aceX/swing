import { prisma } from '@swing/db'

export class EliteStatsExtendedService {
  async getStats120(playerId: string) {
    const profile = await prisma.playerProfile.findUnique({
      where: { id: playerId.trim() },
      select: { id: true, playerRole: true },
    })
    if (!profile) return null

    const playerMatches = await prisma.match.findMany({
      where: {
        status: 'COMPLETED',
        OR: [
          { teamAPlayerIds: { has: profile.id } },
          { teamBPlayerIds: { has: profile.id } },
        ],
      },
      select: {
        id: true,
        round: true,
        winnerId: true,
        teamAName: true,
        teamBName: true,
        completedAt: true,
        scheduledAt: true,
        teamAPlayerIds: true,
        teamBPlayerIds: true,
      },
      orderBy: [{ completedAt: 'asc' }, { scheduledAt: 'asc' }],
    })

    const completedMatchIds = playerMatches.map((match) => match.id)

    const [facts, indexScores, battingEvents, bowlingEvents] = completedMatchIds.length > 0
      ? await Promise.all([
          prisma.matchPlayerFact.findMany({
            where: {
              playerId: profile.id,
              matchId: { in: completedMatchIds },
            },
            orderBy: [{ matchDate: 'asc' }, { createdAt: 'asc' }],
          }),
          prisma.matchPlayerIndexScore.findMany({
            where: {
              playerId: profile.id,
              matchId: { in: completedMatchIds },
            },
            select: { matchId: true, impactPoints: true, isMvp: true },
          }),
          prisma.ballEvent.findMany({
            where: {
              batterId: profile.id,
              innings: {
                match: { id: { in: completedMatchIds } },
              },
            },
            include: { bowler: { select: { bowlingStyle: true } } },
          }),
          prisma.ballEvent.findMany({
            where: {
              bowlerId: profile.id,
              innings: {
                match: { id: { in: completedMatchIds } },
              },
            },
            select: {
              outcome: true,
              runs: true,
              totalRuns: true,
              overNumber: true,
              isWicket: true,
              dismissalType: true,
              batter: {
                select: {
                  battingStyle: true,
                },
              },
            },
          }),
        ])
      : [[], [], [], []]
    const inningsRecords = playerMatches.length > 0
      ? await prisma.innings.findMany({
          where: {
            matchId: { in: playerMatches.map((match) => match.id) },
            isSuperOver: false,
            inningsNumber: { lte: 2 },
          },
          select: { matchId: true, inningsNumber: true, battingTeam: true },
        })
      : []

    const battingFacts = facts.filter((fact) => this.isBattingAppearance(fact))
    const bowlingFacts = facts.filter((fact) => this.isBowlingAppearance(fact))
    const matchCount = playerMatches.length

    const totalRuns = this.sumBy(battingFacts, (fact) => fact.runs)
    const totalBallsFaced = this.sumBy(battingFacts, (fact) => fact.ballsFaced)
    const totalFours = this.sumBy(battingFacts, (fact) => fact.fours)
    const totalSixes = this.sumBy(battingFacts, (fact) => fact.sixes)
    const totalBoundaries = totalFours + totalSixes
    const boundaryRuns = totalFours * 4 + totalSixes * 6
    const highestScore = battingFacts.reduce((value, fact) => Math.max(value, fact.runs), 0)
    const battingDismissals = battingFacts.filter((fact) => !fact.wasNotOut).length

    const battingAverage = battingDismissals > 0 ? this.round2(totalRuns / battingDismissals) : totalRuns
    const strikeRate = totalBallsFaced > 0 ? this.round2((totalRuns / totalBallsFaced) * 100) : 0
    const runsPerInnings = battingFacts.length > 0 ? this.round2(totalRuns / battingFacts.length) : 0
    const ballsPerDismissal = battingDismissals > 0 ? this.round2(totalBallsFaced / battingDismissals) : 0
    const boundaryPerBall = totalBallsFaced > 0 ? this.round4(totalBoundaries / totalBallsFaced) : 0
    const ballsPerBoundary = totalBoundaries > 0 ? this.round2(totalBallsFaced / totalBoundaries) : 0
    const boundaryRunPct = totalRuns > 0 ? this.round2((boundaryRuns / totalRuns) * 100) : 0
    const totalDotBallsFaced = this.sumBy(battingFacts, (fact) => fact.dotBalls)
    const dotBallPctBat = totalBallsFaced > 0 ? this.round2((totalDotBallsFaced / totalBallsFaced) * 100) : 0

    const scoringBalls = battingEvents.filter((ball) => ball.outcome !== 'WIDE' && ball.runs > 0).length
    const singles = battingEvents.filter((ball) => ball.outcome !== 'WIDE' && ball.runs === 1).length
    const singlesPctBat = totalBallsFaced > 0 ? this.round2((singles / totalBallsFaced) * 100) : 0
    const scoringShotPct = totalBallsFaced > 0 ? this.round2((scoringBalls / totalBallsFaced) * 100) : 0

    const thirties = battingFacts.filter((fact) => fact.runs >= 30 && fact.runs < 50).length
    const forties = battingFacts.filter((fact) => fact.runs >= 40 && fact.runs < 50).length
    const fifties = battingFacts.filter((fact) => fact.runs >= 50 && fact.runs < 100).length
    const hundreds = battingFacts.filter((fact) => fact.runs >= 100).length
    const ducks = battingFacts.filter((fact) => fact.runs === 0 && !fact.wasNotOut).length
    const fiftyPlusInnings = fifties + hundreds
    const fiftyPlusInningsPct = battingFacts.length > 0 ? this.round2((fiftyPlusInnings / battingFacts.length) * 100) : 0
    const hundredConversionFromFiftyPct = fiftyPlusInnings > 0 ? this.round2((hundreds / fiftyPlusInnings) * 100) : 0
    const innings30Plus = battingFacts.filter((fact) => fact.runs >= 30).length
    const innings50Plus = battingFacts.filter((fact) => fact.runs >= 50).length
    const thirtyToFiftyConversionPct = innings30Plus > 0 ? this.round2((innings50Plus / innings30Plus) * 100) : 0
    const fiftyToHundredConversionPct = innings50Plus > 0 ? this.round2((hundreds / innings50Plus) * 100) : 0
    const maxBoundariesInInnings = battingFacts.reduce((value, fact) => Math.max(value, fact.fours + fact.sixes), 0)

    const battingPhase = {
      powerplay: { runs: 0, balls: 0, boundaries: 0 },
      middle: { runs: 0, balls: 0, boundaries: 0 },
      death: { runs: 0, balls: 0, boundaries: 0 },
    }
    const battingStyleBuckets = {
      pace: { runs: 0, balls: 0 },
      spin: { runs: 0, balls: 0 },
      leftArmPace: { runs: 0, balls: 0 },
      rightArmPace: { runs: 0, balls: 0 },
      offSpin: { runs: 0, balls: 0 },
      legSpin: { runs: 0, balls: 0 },
    }

    for (const event of battingEvents) {
      if (event.outcome !== 'WIDE') {
        const phase = event.overNumber < 6 ? 'powerplay' : event.overNumber < 15 ? 'middle' : 'death'
        battingPhase[phase].runs += event.runs
        battingPhase[phase].balls += 1
        if (event.runs === 4 || event.runs === 6) battingPhase[phase].boundaries += 1
      }

      const style = (event.bowler?.bowlingStyle || '').toUpperCase()
      if (event.outcome !== 'WIDE') {
        if (this.isPaceStyle(style)) {
          battingStyleBuckets.pace.runs += event.runs
          battingStyleBuckets.pace.balls += 1
        } else if (this.isSpinStyle(style)) {
          battingStyleBuckets.spin.runs += event.runs
          battingStyleBuckets.spin.balls += 1
        }
        if (style.includes('LEFT') && this.isPaceStyle(style)) {
          battingStyleBuckets.leftArmPace.runs += event.runs
          battingStyleBuckets.leftArmPace.balls += 1
        }
        if ((style.includes('RIGHT') || (!style.includes('LEFT') && !style.includes('RIGHT'))) && this.isPaceStyle(style)) {
          battingStyleBuckets.rightArmPace.runs += event.runs
          battingStyleBuckets.rightArmPace.balls += 1
        }
        if (style.includes('OFF')) {
          battingStyleBuckets.offSpin.runs += event.runs
          battingStyleBuckets.offSpin.balls += 1
        }
        if (style.includes('LEG')) {
          battingStyleBuckets.legSpin.runs += event.runs
          battingStyleBuckets.legSpin.balls += 1
        }
      }
    }

    const powerplayRuns = battingPhase.powerplay.runs
    const powerplayBalls = battingPhase.powerplay.balls
    const powerplaySR = this.strikeRate(powerplayRuns, powerplayBalls)
    const middleRuns = battingPhase.middle.runs
    const middleBalls = battingPhase.middle.balls
    const middleSR = this.strikeRate(middleRuns, middleBalls)
    const deathRuns = battingPhase.death.runs
    const deathBalls = battingPhase.death.balls
    const deathSR = this.strikeRate(deathRuns, deathBalls)
    const deathBoundaryPerBall = deathBalls > 0 ? this.round4(battingPhase.death.boundaries / deathBalls) : 0

    const vsPaceRuns = battingStyleBuckets.pace.runs
    const vsPaceBalls = battingStyleBuckets.pace.balls
    const vsPaceSR = this.strikeRate(vsPaceRuns, vsPaceBalls)
    const vsSpinRuns = battingStyleBuckets.spin.runs
    const vsSpinBalls = battingStyleBuckets.spin.balls
    const vsSpinSR = this.strikeRate(vsSpinRuns, vsSpinBalls)
    const vsLeftArmPaceSR = this.strikeRate(battingStyleBuckets.leftArmPace.runs, battingStyleBuckets.leftArmPace.balls)
    const vsRightArmPaceSR = this.strikeRate(battingStyleBuckets.rightArmPace.runs, battingStyleBuckets.rightArmPace.balls)
    const vsOffSpinSR = this.strikeRate(battingStyleBuckets.offSpin.runs, battingStyleBuckets.offSpin.balls)
    const vsLegSpinSR = this.strikeRate(battingStyleBuckets.legSpin.runs, battingStyleBuckets.legSpin.balls)

    const totalBallsBowledFromFacts = this.sumBy(bowlingFacts, (fact) => this.effectiveBallsBowled(fact))
    const totalBallsBowledFromEvents = bowlingEvents.filter((event) => this.isLegalBowlingEvent(event.outcome)).length
    const totalBallsBowled = totalBallsBowledFromFacts > 0 ? totalBallsBowledFromFacts : totalBallsBowledFromEvents
    const totalOvers = this.round2(totalBallsBowled / 6)
    const totalWickets = this.sumBy(bowlingFacts, (fact) => fact.wickets)
    const totalRunsConcededFromFacts = this.sumBy(bowlingFacts, (fact) => fact.runsConceded)
    const totalRunsConcededFromEvents = this.sumBy(bowlingEvents, (event) => event.totalRuns)
    const totalRunsConceded = totalRunsConcededFromFacts > 0 ? totalRunsConcededFromFacts : totalRunsConcededFromEvents
    const maidens = this.sumBy(bowlingFacts, (fact) => fact.maidens)
    const dotBallsBowledFromFacts = this.sumBy(bowlingFacts, (fact) => fact.dotBalls)
    const dotBallsBowledFromEvents = bowlingEvents.filter(
      (event) => this.isLegalBowlingEvent(event.outcome) && event.totalRuns === 0,
    ).length
    const dotBallsBowled = dotBallsBowledFromFacts > 0 ? dotBallsBowledFromFacts : dotBallsBowledFromEvents
    const widesFromFacts = this.sumBy(bowlingFacts, (fact) => fact.wides)
    const noBallsFromFacts = this.sumBy(bowlingFacts, (fact) => fact.noBalls)
    const widesFromEvents = bowlingEvents.filter((event) => event.outcome === 'WIDE').length
    const noBallsFromEvents = bowlingEvents.filter((event) => event.outcome === 'NO_BALL').length
    const wides = widesFromFacts > 0 ? widesFromFacts : widesFromEvents
    const noBalls = noBallsFromFacts > 0 ? noBallsFromFacts : noBallsFromEvents
    const legalDeliveriesPct = totalBallsBowled + wides + noBalls > 0
      ? this.round2((totalBallsBowled / (totalBallsBowled + wides + noBalls)) * 100)
      : 0

    const bowlingAverage = totalWickets > 0 ? this.round2(totalRunsConceded / totalWickets) : 0
    const economyRate = totalBallsBowled > 0 ? this.round2((totalRunsConceded / totalBallsBowled) * 6) : 0
    const bowlingStrikeRate = totalWickets > 0 ? this.round2(totalBallsBowled / totalWickets) : 0
    const wicketsPerMatch = matchCount > 0 ? this.round2(totalWickets / matchCount) : 0
    const wicketsPerInnings = bowlingFacts.length > 0 ? this.round2(totalWickets / bowlingFacts.length) : 0
    const dotBallPctBowl = totalBallsBowled > 0 ? this.round2((dotBallsBowled / totalBallsBowled) * 100) : 0

    let boundariesConceded = 0
    let wicketsBowled = 0
    let wicketsLBW = 0
    let wicketsCaught = 0
    const bowlingVsBatHand = {
      rightHand: { runs: 0, balls: 0, wickets: 0, dotBalls: 0 },
      leftHand: { runs: 0, balls: 0, wickets: 0, dotBalls: 0 },
    }
    const bowlingPhase = {
      powerplay: { runs: 0, balls: 0 },
      middle: { runs: 0, balls: 0 },
      death: { runs: 0, balls: 0, wickets: 0 },
    }

    for (const event of bowlingEvents) {
      if (event.runs === 4 || event.runs === 6) boundariesConceded += 1
      const legal = event.outcome !== 'WIDE' && event.outcome !== 'NO_BALL'
      const handBucket =
        event.batter?.battingStyle === 'LEFT_HAND'
          ? bowlingVsBatHand.leftHand
          : event.batter?.battingStyle === 'RIGHT_HAND'
            ? bowlingVsBatHand.rightHand
            : null

      if (legal) {
        const phase = event.overNumber < 6 ? 'powerplay' : event.overNumber < 15 ? 'middle' : 'death'
        bowlingPhase[phase].balls += 1
        bowlingPhase[phase].runs += event.totalRuns
        if (handBucket) {
          handBucket.balls += 1
          handBucket.runs += event.totalRuns
          if (event.totalRuns === 0) handBucket.dotBalls += 1
        }
      }
      if (event.isWicket) {
        if (event.dismissalType === 'BOWLED') wicketsBowled += 1
        else if (event.dismissalType === 'LBW') wicketsLBW += 1
        else if (event.dismissalType === 'CAUGHT') wicketsCaught += 1
        if (event.overNumber >= 15) bowlingPhase.death.wickets += 1
        if (handBucket) handBucket.wickets += 1
      }
    }

    const boundaryConcededPct = totalBallsBowled > 0 ? this.round2((boundariesConceded / totalBallsBowled) * 100) : 0
    const ballsPerBoundaryConceded = boundariesConceded > 0 ? this.round2(totalBallsBowled / boundariesConceded) : 0
    const controlBallPct = totalBallsBowled > 0 ? this.round2(((dotBallsBowled + totalWickets) / totalBallsBowled) * 100) : 0

    const bestFact = bowlingFacts
      .slice()
      .sort((left, right) => right.wickets - left.wickets || left.runsConceded - right.runsConceded)[0]
    const bestBowlingWickets = bestFact?.wickets ?? 0
    const bestBowlingRuns = bestFact?.runsConceded ?? 0
    const bestBowlingFigure = `${bestBowlingWickets}/${bestBowlingRuns}`
    const threeWicketHauls = bowlingFacts.filter((fact) => fact.wickets >= 3).length
    const fourWicketHauls = bowlingFacts.filter((fact) => fact.wickets >= 4).length
    const fiveWicketHauls = bowlingFacts.filter((fact) => fact.wickets >= 5).length
    const otherWickets = Math.max(0, totalWickets - (wicketsBowled + wicketsLBW + wicketsCaught))

    const ppBallsBowled = bowlingPhase.powerplay.balls
    const ppRunsConceded = bowlingPhase.powerplay.runs
    const ppEconomy = ppBallsBowled > 0 ? this.round2((ppRunsConceded / ppBallsBowled) * 6) : 0
    const middleBallsBowled = bowlingPhase.middle.balls
    const middleRunsConceded = bowlingPhase.middle.runs
    const middleEconomy = middleBallsBowled > 0 ? this.round2((middleRunsConceded / middleBallsBowled) * 6) : 0
    const deathBallsBowled = bowlingPhase.death.balls
    const deathRunsConceded = bowlingPhase.death.runs
    const deathEconomy = deathBallsBowled > 0 ? this.round2((deathRunsConceded / deathBallsBowled) * 6) : 0
    const deathWickets = bowlingPhase.death.wickets
    const vsRightHandBatRunsConceded = bowlingVsBatHand.rightHand.runs
    const vsRightHandBatBallsBowled = bowlingVsBatHand.rightHand.balls
    const vsRightHandBatWickets = bowlingVsBatHand.rightHand.wickets
    const vsRightHandBatEconomy = vsRightHandBatBallsBowled > 0
      ? this.round2((vsRightHandBatRunsConceded / vsRightHandBatBallsBowled) * 6)
      : 0
    const vsRightHandBatStrikeRate = vsRightHandBatWickets > 0
      ? this.round2(vsRightHandBatBallsBowled / vsRightHandBatWickets)
      : 0
    const vsRightHandBatDotBallPct = vsRightHandBatBallsBowled > 0
      ? this.round2((bowlingVsBatHand.rightHand.dotBalls / vsRightHandBatBallsBowled) * 100)
      : 0
    const vsLeftHandBatRunsConceded = bowlingVsBatHand.leftHand.runs
    const vsLeftHandBatBallsBowled = bowlingVsBatHand.leftHand.balls
    const vsLeftHandBatWickets = bowlingVsBatHand.leftHand.wickets
    const vsLeftHandBatEconomy = vsLeftHandBatBallsBowled > 0
      ? this.round2((vsLeftHandBatRunsConceded / vsLeftHandBatBallsBowled) * 6)
      : 0
    const vsLeftHandBatStrikeRate = vsLeftHandBatWickets > 0
      ? this.round2(vsLeftHandBatBallsBowled / vsLeftHandBatWickets)
      : 0
    const vsLeftHandBatDotBallPct = vsLeftHandBatBallsBowled > 0
      ? this.round2((bowlingVsBatHand.leftHand.dotBalls / vsLeftHandBatBallsBowled) * 100)
      : 0

    const catches = this.sumBy(facts, (fact) => fact.catches)
    const runOutDirect = this.sumBy(facts, (fact) => fact.runOuts)
    const runOutAssist = 0
    const stumpings = this.sumBy(facts, (fact) => fact.stumpings)
    const totalDismissalInvolvements = catches + runOutDirect + runOutAssist + stumpings
    const catchesPerMatch = matchCount > 0 ? this.round2(catches / matchCount) : 0
    const runOutInvolvementPerMatch = matchCount > 0 ? this.round2((runOutDirect + runOutAssist) / matchCount) : 0
    const keepingInnings = facts.filter((fact) => fact.stumpings > 0).length
    const stumpingsPerKeepingInnings = keepingInnings > 0 ? this.round2(stumpings / keepingInnings) : 0
    const missedChances = 0
    const dismissalInvolvementPerMatch = matchCount > 0 ? this.round2(totalDismissalInvolvements / matchCount) : 0

    const matchesPlayed = matchCount
    const matchesWon = playerMatches.filter((match) => this.isPlayerWinner(match, profile.id)).length
    const winPct = matchesPlayed > 0 ? this.round2((matchesWon / matchesPlayed) * 100) : 0
    const chaseDefend = this.computeChaseDefend(playerMatches, inningsRecords, profile.id)
    const chaseMatches = chaseDefend.chaseMatches
    const chaseWins = chaseDefend.chaseWins
    const defendMatches = chaseDefend.defendMatches
    const defendWins = chaseDefend.defendWins
    const knockoutMatchIds = new Set(
      playerMatches
        .filter((match) => /QF|SF|FINAL|SEMI|KNOCKOUT/i.test(match.round || ''))
        .map((match) => match.id),
    )
    const knockoutMatches = knockoutMatchIds.size
    const knockoutScores = indexScores.filter((score) => knockoutMatchIds.has(score.matchId))
    const knockoutImpactAvg = knockoutScores.length > 0
      ? this.round2(knockoutScores.reduce((sum, score) => sum + score.impactPoints, 0) / knockoutScores.length)
      : 0
    const mvpCount = indexScores.filter((score) => score.isMvp).length
    const captainMatchIds = new Set(
      facts
        .filter((fact) => fact.isCaptain)
        .map((fact) => fact.matchId),
    )
    const captainMatches = captainMatchIds.size
    const captainWins = playerMatches.filter(
      (match) => captainMatchIds.has(match.id) && this.isPlayerWinner(match, profile.id),
    ).length
    const captainWinPct = captainMatches > 0 ? this.round2((captainWins / captainMatches) * 100) : 0
    const captainSelectionRate = matchesPlayed > 0 ? this.round4(captainMatches / matchesPlayed) : 0
    const captainIndexScores = indexScores.filter((score) => captainMatchIds.has(score.matchId))
    const captainImpactAvg = captainIndexScores.length > 0
      ? this.round2(captainIndexScores.reduce((sum, score) => sum + score.impactPoints, 0) / captainIndexScores.length)
      : 0

    const last5BatFacts = battingFacts.slice().sort((left, right) => right.matchDate.getTime() - left.matchDate.getTime()).slice(0, 5)
    const last5BowlFacts = bowlingFacts.slice().sort((left, right) => right.matchDate.getTime() - left.matchDate.getTime()).slice(0, 5)
    const last10BatFacts = battingFacts.slice().sort((left, right) => right.matchDate.getTime() - left.matchDate.getTime()).slice(0, 10)
    const last10BowlFacts = bowlingFacts.slice().sort((left, right) => right.matchDate.getTime() - left.matchDate.getTime()).slice(0, 10)

    const last5Runs = this.sumBy(last5BatFacts, (fact) => fact.runs)
    const last5Wickets = this.sumBy(last5BowlFacts, (fact) => fact.wickets)
    const last5Dismissals = last5BatFacts.filter((fact) => !fact.wasNotOut).length
    const last5BatAvg = last5Dismissals > 0 ? this.round2(last5Runs / last5Dismissals) : last5Runs
    const last5Balls = this.sumBy(last5BatFacts, (fact) => fact.ballsFaced)
    const last5BatSR = this.strikeRate(last5Runs, last5Balls)
    const last5BowlRunsConceded = this.sumBy(last5BowlFacts, (fact) => fact.runsConceded)
    const last5BowlBalls = this.sumBy(last5BowlFacts, (fact) => this.effectiveBallsBowled(fact))
    const last5Economy = last5BowlBalls > 0 ? this.round2((last5BowlRunsConceded / last5BowlBalls) * 6) : 0
    const last10Runs = this.sumBy(last10BatFacts, (fact) => fact.runs)
    const last10Wickets = this.sumBy(last10BowlFacts, (fact) => fact.wickets)
    const runsStdDev = this.round2(this.standardDeviation(battingFacts.map((fact) => fact.runs)))
    const wicketsStdDev = this.round2(this.standardDeviation(bowlingFacts.map((fact) => fact.wickets)))
    const avgRunsPerInnings = battingFacts.length > 0 ? totalRuns / battingFacts.length : 0
    const avgWicketsPerInnings = bowlingFacts.length > 0 ? totalWickets / bowlingFacts.length : 0
    const runsCv = avgRunsPerInnings > 0 ? runsStdDev / avgRunsPerInnings : 1
    const wicketsCv = avgWicketsPerInnings > 0 ? wicketsStdDev / avgWicketsPerInnings : 1
    const weightedCv = 0.6 * runsCv + 0.4 * wicketsCv
    const consistencyIndex = this.round2(Math.max(0, Math.min(100, (1 - weightedCv) * 100)))

    const metrics = {
      battingInnings: battingFacts.length,
      notOuts: battingFacts.length - battingDismissals,
      totalRuns,
      totalBallsFaced,
      totalFours,
      totalSixes,
      totalBoundaries,
      boundaryRuns,
      highestScore,
      battingDismissals,
      battingAverage,
      strikeRate,
      runsPerInnings,
      ballsPerDismissal,
      boundaryPerBall,
      ballsPerBoundary,
      boundaryRunPct,
      dotBallPctBat,
      singlesPctBat,
      scoringShotPct,
      thirties,
      forties,
      fifties,
      hundreds,
      ducks,
      fiftyPlusInningsPct,
      hundredConversionFromFiftyPct,
      thirtyToFiftyConversionPct,
      fiftyToHundredConversionPct,
      maxBoundariesInInnings,
      powerplayRuns,
      powerplayBalls,
      powerplaySR,
      middleRuns,
      middleBalls,
      middleSR,
      deathRuns,
      deathBalls,
      deathSR,
      deathBoundaryPerBall,
      vsPaceRuns,
      vsPaceBalls,
      vsPaceSR,
      vsSpinRuns,
      vsSpinBalls,
      vsSpinSR,
      vsLeftArmPaceSR,
      vsRightArmPaceSR,
      vsOffSpinSR,
      vsLegSpinSR,
      bowlingInnings: bowlingFacts.length,
      totalBallsBowled,
      totalOvers,
      totalWickets,
      totalRunsConceded,
      maidens,
      dotBallsBowled,
      wides,
      noBalls,
      legalDeliveriesPct,
      bowlingAverage,
      economyRate,
      bowlingStrikeRate,
      wicketsPerMatch,
      wicketsPerInnings,
      dotBallPctBowl,
      boundariesConceded,
      boundaryConcededPct,
      ballsPerBoundaryConceded,
      controlBallPct,
      bestBowlingWickets,
      bestBowlingRuns,
      bestBowlingFigure,
      threeWicketHauls,
      fourWicketHauls,
      fiveWicketHauls,
      wicketsBowled,
      wicketsLBW,
      wicketsCaught,
      otherWickets,
      ppBallsBowled,
      ppRunsConceded,
      ppEconomy,
      middleBallsBowled,
      middleRunsConceded,
      middleEconomy,
      deathBallsBowled,
      deathRunsConceded,
      deathEconomy,
      deathWickets,
      vsRightHandBatRunsConceded,
      vsRightHandBatBallsBowled,
      vsRightHandBatWickets,
      vsRightHandBatEconomy,
      vsRightHandBatStrikeRate,
      vsRightHandBatDotBallPct,
      vsLeftHandBatRunsConceded,
      vsLeftHandBatBallsBowled,
      vsLeftHandBatWickets,
      vsLeftHandBatEconomy,
      vsLeftHandBatStrikeRate,
      vsLeftHandBatDotBallPct,
      catches,
      runOutDirect,
      runOutAssist,
      stumpings,
      totalDismissalInvolvements,
      catchesPerMatch,
      runOutInvolvementPerMatch,
      stumpingsPerKeepingInnings,
      missedChances,
      dismissalInvolvementPerMatch,
      matchesPlayed,
      matchesWon,
      winPct,
      chaseMatches,
      chaseWins,
      defendMatches,
      defendWins,
      knockoutMatches,
      knockoutImpactAvg,
      mvpCount,
      captainMatches,
      captainWins,
      captainWinPct,
      captainSelectionRate,
      captainImpactAvg,
      last5Runs,
      last5Wickets,
      last5BatAvg,
      last5BatSR,
      last5Economy,
      last10Runs,
      last10Wickets,
      runsStdDev,
      wicketsStdDev,
      consistencyIndex,
    }

    return {
      playerId: profile.id,
      metricCount: Object.keys(metrics).length,
      metrics,
      generatedAt: new Date().toISOString(),
      source: {
        facts: facts.length,
        battingEvents: battingEvents.length,
        bowlingEvents: bowlingEvents.length,
        completedMatches: playerMatches.length,
        playerRole: profile.playerRole,
      },
    }
  }

  private sumBy<T>(values: T[], selector: (value: T) => number) {
    return values.reduce((sum, value) => sum + (selector(value) || 0), 0)
  }

  private round2(value: number) {
    return Number(value.toFixed(2))
  }

  private round4(value: number) {
    return Number(value.toFixed(4))
  }

  private strikeRate(runs: number, balls: number) {
    return balls > 0 ? this.round2((runs / balls) * 100) : 0
  }

  private standardDeviation(values: number[]) {
    if (values.length === 0) return 0
    const mean = values.reduce((sum, value) => sum + value, 0) / values.length
    const variance = values.reduce((sum, value) => sum + (value - mean) ** 2, 0) / values.length
    return Math.sqrt(variance)
  }

  private isPaceStyle(style: string) {
    return style.includes('FAST') || style.includes('MEDIUM')
  }

  private isSpinStyle(style: string) {
    return style.includes('SPIN') || style.includes('OFF') || style.includes('LEG')
  }

  private isBattingAppearance(fact: {
    didBat: boolean
    runs: number
    ballsFaced: number
    fours: number
    sixes: number
    dismissalType: unknown
  }) {
    return Boolean(
      fact.didBat ||
      fact.runs > 0 ||
      fact.ballsFaced > 0 ||
      fact.fours > 0 ||
      fact.sixes > 0 ||
      fact.dismissalType,
    )
  }

  private isBowlingAppearance(fact: {
    didBowl: boolean
    wickets: number
    ballsBowled: number
    oversBowled: number | null
    runsConceded: number
    dotBalls: number
    wides: number
    noBalls: number
  }) {
    return Boolean(
      fact.didBowl ||
      fact.wickets > 0 ||
      fact.ballsBowled > 0 ||
      (fact.oversBowled ?? 0) > 0 ||
      fact.runsConceded > 0 ||
      fact.dotBalls > 0 ||
      fact.wides > 0 ||
      fact.noBalls > 0,
    )
  }

  private effectiveBallsBowled(fact: { ballsBowled: number; oversBowled: number | null }) {
    if (fact.ballsBowled > 0) return fact.ballsBowled
    if ((fact.oversBowled ?? 0) > 0) return Math.round((fact.oversBowled ?? 0) * 6)
    return 0
  }

  private isLegalBowlingEvent(outcome: string) {
    return outcome !== 'WIDE' && outcome !== 'NO_BALL'
  }

  private isPlayerWinner(
    match: {
      winnerId: string | null
      teamAName: string | null
      teamBName: string | null
      teamAPlayerIds: string[]
      teamBPlayerIds: string[]
    },
    playerId: string,
  ) {
    const playerSide = this.getPlayerTeamSide(match, playerId)
    if (!match.winnerId || !playerSide) return false

    if (match.winnerId === 'A') return playerSide === 'A'
    if (match.winnerId === 'B') return playerSide === 'B'

    const winnerNorm = this.normalize(match.winnerId)
    if (winnerNorm === this.normalize(match.teamAName)) return playerSide === 'A'
    if (winnerNorm === this.normalize(match.teamBName)) return playerSide === 'B'

    return false
  }

  private getPlayerTeamSide(
    match: { teamAPlayerIds: string[]; teamBPlayerIds: string[] },
    playerId: string,
  ): 'A' | 'B' | null {
    const onA = match.teamAPlayerIds.includes(playerId)
    const onB = match.teamBPlayerIds.includes(playerId)
    if (onA && !onB) return 'A'
    if (onB && !onA) return 'B'
    return null
  }

  private computeChaseDefend(
    matches: Array<{
      id: string
      winnerId: string | null
      teamAName: string | null
      teamBName: string | null
      teamAPlayerIds: string[]
      teamBPlayerIds: string[]
    }>,
    inningsRecords: Array<{ matchId: string; inningsNumber: number; battingTeam: string | null }>,
    playerId: string,
  ) {
    const firstInningsTeamByMatch = new Map<string, string | null>()
    for (const innings of inningsRecords) {
      if (innings.inningsNumber !== 1) continue
      if (!firstInningsTeamByMatch.has(innings.matchId)) {
        firstInningsTeamByMatch.set(innings.matchId, innings.battingTeam)
      }
    }

    let chaseMatches = 0
    let chaseWins = 0
    let defendMatches = 0
    let defendWins = 0

    for (const match of matches) {
      const playerSide = this.getPlayerTeamSide(match, playerId)
      if (!playerSide) continue

      const firstBattingTeam = firstInningsTeamByMatch.get(match.id)
      if (!firstBattingTeam) continue

      const firstNorm = this.normalize(firstBattingTeam)
      let firstBattingSide: 'A' | 'B' | null = null
      if (firstNorm === 'a' || firstNorm === this.normalize(match.teamAName)) firstBattingSide = 'A'
      if (firstNorm === 'b' || firstNorm === this.normalize(match.teamBName)) firstBattingSide = 'B'
      if (!firstBattingSide) continue

      const isChasing = playerSide !== firstBattingSide
      const isWinner = this.isPlayerWinner(match, playerId)
      if (isChasing) {
        chaseMatches += 1
        if (isWinner) chaseWins += 1
      } else {
        defendMatches += 1
        if (isWinner) defendWins += 1
      }
    }

    return { chaseMatches, chaseWins, defendMatches, defendWins }
  }

  private normalize(value: string | null | undefined) {
    return (value || '').trim().toLowerCase()
  }
}
