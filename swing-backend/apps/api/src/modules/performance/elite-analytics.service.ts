import { prisma } from "@swing/db";
import {
  CompetitivePlayerFactInput,
  CompetitiveContext,
} from "./performance.types";
import { recalculateTeamPowerScore } from "./ip-engine";
import { formatRankLabel } from "./performance.calculations";
import { HealthPerformanceService } from "./health-performance.service";
import { EliteStatsExtendedService } from "./elite-stats-extended.service";
import { EliteJournalService } from "./elite-journal.service";
import { ElitePlanService } from "./elite-plan.service";
import {
  getAxisNumber,
  getIpPlayerState,
  getPlayerStatOverall,
  getSubScoreNumber,
  getSwingPlayerState,
} from "./state-read.repository";

export class EliteAnalyticsService {
  private journalSvc = new EliteJournalService();
  private planSvc = new ElitePlanService();
  async getPlayerByUserId(userId: string) {
    return prisma.playerProfile.findUnique({
      where: { userId },
      select: { id: true },
    });
  }

  async getSwotAnalysis(playerId: string, ballType: string = "LEATHER") {
    const stats = await this.getExtendedStats120(playerId, ballType);
    if (!stats || (stats as any).error) return null;

    const m = (stats as any).metrics;
    const strengths: string[] = [];
    const weaknesses: string[] = [];
    const opportunities: string[] = [];
    const threats: string[] = [];

    // --- STRENGTHS ---
    if (m.deathEconomy > 0 && m.deathEconomy < 7.5)
      strengths.push(
        "Death Over Specialist: Elite economy in high-pressure phases.",
      );
    if (m.vsSpinSR > 140)
      strengths.push(
        "Spin Crusher: Highly aggressive and effective against spin bowling.",
      );
    if (m.dotBallPctBowl > 60)
      strengths.push(
        "Pressure Builder: High dot ball percentage keeps batters under control.",
      );
    if (m.catchImpact > 75)
      strengths.push("Spiderman: Exceptional safe hands in the field.");
    if (m.strikeRate > 150)
      strengths.push(
        "Turbo-Charged: Strike rate is in the top 5% of your city.",
      );

    // --- WEAKNESSES ---
    if (m.dotBallPctBat > 45)
      weaknesses.push(
        "High Dot Percentage: Consuming too many deliveries without scoring.",
      );
    if (m.vsPaceSR < 110 && m.battingInnings > 5)
      weaknesses.push(
        "Susceptible to Pace: Struggling to rotate strike against fast bowling.",
      );
    if (m.bowlingAverage > 35)
      weaknesses.push(
        "Costly Wickets: Average runs conceded per wicket is significantly above benchmark.",
      );
    if (m.consistencyIndex < 40)
      weaknesses.push(
        "Performance Volatility: High variance between match scores.",
      );

    // --- OPPORTUNITIES (Prescriptive) ---
    if (m.thirtyToFiftyConversionPct < 30 && m.thirties > 0) {
      opportunities.push(
        "Focus on Batting Longevity: Your conversion from 30 to 50 is low. Practice middle-over rotation drills.",
      );
    }
    if (m.middleEconomy > 9) {
      opportunities.push(
        "Tighten Middle-Over Control: Reducing middle-over boundaries will jump your Swing Index by 4-5 points.",
      );
    }
    if (m.runOutInvolvementPerMatch < 0.1) {
      opportunities.push(
        'Fielding Alertness: Low run-out involvement. Try the "Direct Hit" drill in your next training session.',
      );
    }

    // --- THREATS (Injury & Long Term) ---
    const health = await new HealthPerformanceService().getPower5Dashboard(
      playerId,
    );
    if (health.integrity.injuryRisk === "HIGH") {
      threats.push(
        "Injury Red-Zone: ACWR indicates excessive workload. High risk of muscle tear if intensity is not dropped.",
      );
    }
    if (m.legalDeliveriesPct < 85) {
      threats.push(
        "Discipline Warning: Low legal delivery percentage (Wides/No-Balls) is gifting free runs to opponents.",
      );
    }

    return {
      ballType,
      strengths: strengths.slice(0, 3),
      weaknesses: weaknesses.slice(0, 3),
      opportunities: opportunities.slice(0, 3),
      threats: threats.slice(0, 3),
      generatedAt: new Date(),
    };
  }

  async getScoutingReport(
    myId: string,
    opponentTeamId: string,
    ballType: string = "LEATHER",
  ) {
    const [myStats, oppStats] = await Promise.all([
      this.getExtendedStats120(myId, ballType),
      prisma.matchPlayerFact.findMany({
        where: { teamId: opponentTeamId, ballType },
        take: 100,
      }),
    ]);

    if (!myStats || (myStats as any).error || oppStats.length === 0)
      return null;

    const battles: string[] = [];
    const my = (myStats as any).metrics;

    // Aggregate Opponent Weaknesses
    const oppWicketsLostToPace = oppStats.filter(
      (f: any) => f.dismissalType === "BOWLED" || f.dismissalType === "LBW",
    ).length;
    const oppWicketsLostToCaught = oppStats.filter(
      (f: any) => f.dismissalType === "CAUGHT",
    ).length;

    if (my.wicketsBowled > 5 && oppWicketsLostToPace > 30) {
      battles.push(
        "Target the Stumps: Opponent has a high frequency of Bowled/LBW dismissals. Your accuracy is their biggest threat.",
      );
    }
    if (
      my.deathEconomy < 7.5 &&
      oppStats.filter((f: any) => f.inningsNo === 2).length > 10
    ) {
      battles.push(
        "Hold the Death: Opponent struggles in chases. Your economy will create a wicket-taking opportunity.",
      );
    }

    return {
      opponent: opponentTeamId,
      ballType,
      keyBattles: battles.slice(0, 3),
      winProbabilityBoost: battles.length * 4.5,
      suggestedApproach:
        battles.length > 0
          ? battles[0]
          : "Maintain your standard role and focus on line and length.",
    };
  }

  /**
   * THE UNIFIED PROFILE API
   * Consolidated source for Identity, Stats, Rank, Badges, and Teams.
   */
  async getUnifiedProfile(
    playerId: string,
    viewerUserId?: string | null,
    ballType: string = "LEATHER",
  ) {
    const viewerUserIdOrNull = viewerUserId?.trim() || null;
    const normalizedId = playerId.trim();
    const normalizedUsername = normalizedId.toLowerCase();

    const profileSelect = {
      id: true,
      userId: true,
      isPublic: true,
      bio: true,
      city: true,
      playerRole: true,
      battingStyle: true,
      bowlingStyle: true,
      level: true,
      followersCount: true,
      followingCount: true,
      gender: true,
      heightCm: true,
      weightKg: true,
      waistCircumferenceCm: true,
      neckCircumferenceCm: true,
      hipCircumferenceCm: true,
      user: { select: { id: true, name: true, avatarUrl: true } },
      playerBadges: {
        select: {
          badgeId: true,
          awardedAt: true,
          badge: {
            select: {
              id: true,
              name: true,
              description: true,
              category: true,
              iconUrl: true,
            },
          },
        },
      },
    } as const;

    const [profileById, profileByUserId, profileByUsername, viewerProfile] =
      await Promise.all([
        prisma.playerProfile.findUnique({
          where: { id: normalizedId },
          select: profileSelect,
        }),
        prisma.playerProfile.findUnique({
          where: { userId: normalizedId },
          select: profileSelect,
        }),
        prisma.playerProfile.findUnique({
          where: { username: normalizedUsername },
          select: profileSelect,
        }),
        viewerUserIdOrNull
          ? prisma.playerProfile.findUnique({
              where: { userId: viewerUserIdOrNull },
              select: { id: true },
            })
          : Promise.resolve(null),
      ]);
    const profile = profileById ?? profileByUserId ?? profileByUsername;

    if (!profile) return null;
    if (!profile.isPublic && profile.userId !== viewerUserIdOrNull) return null;

    const activeSubscription = await prisma.subscription.findFirst({
      where: {
        userId: profile.userId,
        status: "ACTIVE",
        expiresAt: { gte: new Date() },
        OR: [
          { entityType: { contains: "PASS", mode: "insensitive" } },
          { entityType: { contains: "PLAYER", mode: "insensitive" } },
        ],
      },
      select: { id: true },
      orderBy: { expiresAt: "desc" },
    });
    const isApexActive = Boolean(activeSubscription);

    const [
      ipState,
      swingState,
      statsOverall,
      facts,
      precisionData,
      wellnessData,
      allMasterBadges,
      teams,
      followRecord,
      swot,
      health,
      preparation,
      insights,
      ambition,
      myPlan,
      disciplineData,
    ] = await Promise.all([
      getIpPlayerState(profile.id),
      getSwingPlayerState(profile.id),
      getPlayerStatOverall(profile.id),
      prisma.matchPlayerFact.findMany({
        where: { playerId: profile.id, OR: [{ ballType }, { ballType: null }] },
        orderBy: { matchDate: "desc" },
      }),
      this.getHighPrecisionAnalytics(profile.id, ballType),
      this.getWellnessAndPhysicality(profile.id),
      prisma.badge.findMany({
        select: {
          id: true,
          name: true,
          description: true,
          category: true,
          iconUrl: true,
          isRare: true,
          ipBonus: true,
        },
      }),
      prisma.team.findMany({
        where: { playerIds: { has: profile.id } },
        select: { id: true, name: true, powerScore: true },
      }),
      viewerProfile
        ? prisma.playerFollow.findUnique({
            where: {
              followerPlayerId_followingPlayerId: {
                followerPlayerId: viewerProfile.id,
                followingPlayerId: profile.id,
              },
            },
            select: { followerPlayerId: true },
          })
        : Promise.resolve(null),
      this.getSwotAnalysis(profile.id, ballType),
      new HealthPerformanceService().getPower5Dashboard(profile.id),
      this.journalSvc.getPreparationScore(profile.id),
      prisma.eliteInsight.findMany({
        where: { playerId: profile.id, isRead: false },
        orderBy: { createdAt: "desc" },
        take: 3,
      }),
      prisma.performanceAmbition.findUnique({
        where: { playerId: profile.id },
      }),
      this.planSvc.getMyPlan(profile.id),
      this.planSvc.calculateDisciplineScore(profile.id),
    ]);

    const factMatches =
      facts.length > 0
        ? await prisma.match.findMany({
            where: {
              id: {
                in: Array.from(new Set(facts.map((fact) => fact.matchId))),
              },
            },
            select: {
              id: true,
              tournamentId: true,
              winnerId: true,
              teamAName: true,
              teamBName: true,
              teamAPlayerIds: true,
              teamBPlayerIds: true,
            },
          })
        : [];

    const inningsRecords =
      factMatches.length > 0
        ? await prisma.innings.findMany({
            where: {
              matchId: { in: factMatches.map((m) => m.id) },
              inningsNumber: 1,
            },
            select: { matchId: true, inningsNumber: true, battingTeam: true },
          })
        : [];

    const chaseDefend = this.computeChaseDefend(
      factMatches as any,
      inningsRecords,
      profile.id,
    );

    const batting =
      facts.length > 0
        ? this.aggregateBatting(facts)
        : {
            summary: {
              totalRuns: 0,
              totalBallsFaced: 0,
              average: 0,
              strikeRate: 0,
              highestScore: 0,
              fifties: 0,
              hundreds: 0,
              fours: 0,
              sixes: 0,
            },
          };
    const bowling =
      facts.length > 0
        ? this.aggregateBowling(facts)
        : {
            summary: {
              totalWickets: 0,
              average: 0,
              economy: 0,
              strikeRate: 0,
              bestBowling: "0/0",
              fiveWicketHauls: 0,
              maidens: 0,
              dotBalls: 0,
            },
          };
    const fielding =
      facts.length > 0
        ? {
            catches: facts.reduce(
              (sum: number, fact: any) => sum + (fact.catches || 0),
              0,
            ),
            stumpings: facts.reduce(
              (sum: number, fact: any) => sum + (fact.stumpings || 0),
              0,
            ),
            runOuts: facts.reduce(
              (sum: number, fact: any) => sum + (fact.runOuts || 0),
              0,
            ),
          }
        : {
            catches: 0,
            stumpings: 0,
            runOuts: 0,
          };

    const rankKey = (ipState?.currentRankKey as any) ?? "ROOKIE";
    const division = ipState?.currentDivision ?? 3;
    const rankLabel = formatRankLabel(rankKey, division);
    const reliabilityAxis = getAxisNumber(swingState?.axes, "reliabilityAxis");
    const powerAxis = getAxisNumber(swingState?.axes, "powerAxis");
    const bowlingAxis = getAxisNumber(swingState?.axes, "bowlingAxis");
    const fieldingAxis = getAxisNumber(swingState?.axes, "fieldingAxis");
    const impactAxis = getAxisNumber(swingState?.axes, "impactAxis");
    const captaincyAxis = getAxisNumber(swingState?.axes, "captaincyAxis");

    const unlockedBadgeIds = new Set(
      profile.playerBadges.map((pb) => pb.badgeId),
    );
    const awardedAtByBadgeId = new Map(
      profile.playerBadges.map((playerBadge) => [
        playerBadge.badgeId,
        playerBadge.awardedAt,
      ]),
    );
    const badges = allMasterBadges.map((b) => ({
      id: b.id,
      name: b.name,
      description: b.description,
      category: b.category,
      iconUrl: b.iconUrl ?? null,
      isRare: b.isRare,
      xpReward: b.ipBonus,
      isUnlocked: unlockedBadgeIds.has(b.id),
      awardedAt: awardedAtByBadgeId.get(b.id) ?? null,
    }));

    const tournamentIdSet = new Set(
      factMatches
        .map((match) => match.tournamentId)
        .filter((value): value is string => Boolean(value)),
    );
    const tournaments =
      tournamentIdSet.size > 0
        ? await prisma.tournament.findMany({
            where: { id: { in: Array.from(tournamentIdSet) } },
            select: { id: true, name: true },
          })
        : [];
    const matchById = new Map(factMatches.map((match) => [match.id, match]));
    const tournamentById = new Map(
      tournaments.map((tournament) => [tournament.id, tournament]),
    );

    const competitionsMap = new Map<string, any>();
    for (const fact of facts) {
      const match = matchById.get(fact.matchId);
      const tournamentId = match?.tournamentId;
      const tournament = tournamentId ? tournamentById.get(tournamentId) : null;
      if (tournamentId && tournament) {
        if (!competitionsMap.has(tournamentId)) {
          competitionsMap.set(tournamentId, {
            tournamentName: tournament.name,
            result: fact.result,
            season: fact.matchDate.getFullYear().toString(),
          });
        }
      }
    }

    const totalMatches = facts.length;
    const wins = facts.filter((f: any) => f.result === "WIN").length;
    const losses = facts.filter((f: any) => f.result === "LOSS").length;
    const winPct =
      totalMatches > 0 ? Number(((wins / totalMatches) * 100).toFixed(1)) : 0;

    return {
      identity: {
        name: profile.user.name,
        avatarUrl: profile.user.avatarUrl ?? null,
        coverUrl: null,
        bio: profile.bio || "",
        city: profile.city || "",
        playerRole: profile.playerRole,
        battingStyle: profile.battingStyle,
        bowlingStyle: profile.bowlingStyle,
        level: profile.level,
        fans: profile.followersCount,
        following: profile.followingCount,
      },
      ranking: {
        rank: rankKey,
        label: rankLabel,
        division,
        impactPoints: ipState?.lifetimeIp ?? 0,
        progress: ipState?.rankProgressPoints ?? 0,
        swingIndex: swingState?.overallScore ?? 0,
      },
      skillMatrix: {
        reliability: reliabilityAxis ?? 0,
        power: powerAxis ?? 0,
        bowling: bowlingAxis ?? 0,
        fielding: fieldingAxis ?? 0,
        impact: impactAxis ?? 0,
        captaincy: captaincyAxis,
      },
      stats: {
        matches: {
          total: totalMatches,
          wins,
          losses,
          winPct,
          chase: {
            total: chaseDefend.chaseMatches,
            wins: chaseDefend.chaseWins,
            winPct:
              chaseDefend.chaseMatches > 0
                ? Number(
                    (
                      (chaseDefend.chaseWins / chaseDefend.chaseMatches) *
                      100
                    ).toFixed(1),
                  )
                : 0,
          },
          defend: {
            total: chaseDefend.defendMatches,
            wins: chaseDefend.defendWins,
            winPct:
              chaseDefend.defendMatches > 0
                ? Number(
                    (
                      (chaseDefend.defendWins / chaseDefend.defendMatches) *
                      100
                    ).toFixed(1),
                  )
                : 0,
          },
        },
        batting: {
          summary: {
            totalRuns: batting.summary.totalRuns,
            totalBallsFaced: batting.summary.totalBallsFaced,
            average: batting.summary.average,
            strikeRate: batting.summary.strikeRate,
            highestScore: batting.summary.highestScore,
            fifties: batting.summary.fifties,
            hundreds: batting.summary.hundreds,
            fours: batting.summary.fours,
            sixes: batting.summary.sixes,
          },
        },
        bowling: {
          summary: {
            totalWickets: bowling.summary.totalWickets,
            average: bowling.summary.average,
            economy: bowling.summary.economy,
            strikeRate: (bowling.summary as any).strikeRate || 0,
            bestBowling: bowling.summary.bestBowling,
            fiveWicketHauls: bowling.summary.fiveWicketHauls,
            maidens: bowling.summary.maidens,
            dotBalls: bowling.summary.dotBalls,
          },
        },
        fielding,
      },
      precision: {
        phases: {
          batting: {
            powerplaySR: precisionData.phases.powerplaySR,
            middleOversSR: precisionData.phases.middleOversSR,
            deathOversSR: precisionData.phases.deathOversSR,
          },
          bowling: {
            powerplayEcon: precisionData.phases.powerplayEcon,
            middleOversEcon: precisionData.phases.middleOversEcon,
            deathOversEcon: precisionData.phases.deathOversEcon,
          },
        },
        matchups: {
          paceSR: precisionData.matchups.paceSR,
          spinSR: precisionData.matchups.spinSR,
        },
      },
      badges,
      wellness: {
        recoveryScore: wellnessData.recoveryScore,
        fatigueLevel: wellnessData.fatigueLevel,
        oversBowledPastMonth: wellnessData.oversBowledPastMonth,
      },
      competitions: Array.from(competitionsMap.values()),
      teams,
      isFollowing: Boolean(followRecord),
      isApex: isApexActive,
      swot: swot, // Open for all
      apexDashboard: health, // Open for all
      preparation: preparation, // Open for all
      insights: insights, // Open for all
      ambition: ambition
        ? {
            ...ambition,
            profile: {
              gender: profile.gender,
              heightCm: profile.heightCm,
              weightKg: profile.weightKg,
              waistCircumferenceCm: profile.waistCircumferenceCm,
              neckCircumferenceCm: profile.neckCircumferenceCm,
              hipCircumferenceCm: profile.hipCircumferenceCm,
            },
          }
        : null,
      myPlan: myPlan,
      disciplineScore: disciplineData.score,
      planAdherence: disciplineData.adherence,
    };
  }

  async getExtendedStats120(playerId: string, ballType: string = "LEATHER") {
    const profile = await prisma.playerProfile.findUnique({
      where: { id: playerId.trim() },
      select: {
        id: true,
        userId: true,
      },
    });
    if (!profile) return null;

    const activeSubscription = await prisma.subscription.findFirst({
      where: {
        userId: profile.userId,
        status: "ACTIVE",
        expiresAt: { gte: new Date() },
        OR: [
          { entityType: { contains: "PASS", mode: "insensitive" } },
          { entityType: { contains: "PLAYER", mode: "insensitive" } },
        ],
      },
      select: { id: true },
      orderBy: { expiresAt: "desc" },
    });
    const isApexActive = Boolean(activeSubscription);

    const [facts, indexScores, playerMatches, battingEvents, bowlingEvents] =
      await Promise.all([
        prisma.matchPlayerFact.findMany({
          where: { playerId: profile.id, ballType },
          orderBy: [{ matchDate: "asc" }, { createdAt: "asc" }],
        }),
        prisma.matchPlayerIndexScore.findMany({
          where: { playerId: profile.id, match: { ballType } },
          select: { matchId: true, impactPoints: true, isMvp: true },
        }),
        prisma.match.findMany({
          where: {
            status: "COMPLETED",
            ballType,
            OR: [
              { teamAPlayerIds: { has: profile.id } },
              { teamBPlayerIds: { has: profile.id } },
            ],
          },
          select: {
            id: true,
            winnerId: true,
            round: true,
            completedAt: true,
            scheduledAt: true,
            format: true,
          },
          orderBy: [{ completedAt: "asc" }, { scheduledAt: "asc" }],
        }),
        prisma.ballEvent.findMany({
          where: { batterId: profile.id, innings: { match: { ballType } } },
          include: {
            bowler: { select: { bowlingStyle: true } },
            innings: { select: { matchId: true } },
          },
        }),
        prisma.ballEvent.findMany({
          where: { bowlerId: profile.id, innings: { match: { ballType } } },
          select: {
            outcome: true,
            runs: true,
            totalRuns: true,
            overNumber: true,
            isWicket: true,
            dismissalType: true,
            dismissedPlayerId: true,
            innings: { select: { matchId: true } },
          },
        }),
      ]);

    const factByMatchId = new Map(facts.map((fact) => [fact.matchId, fact]));
    const playerMatchesById = new Map(playerMatches.map((m) => [m.id, m]));
    const getPhases = (matchId: string) => {
      const format =
        playerMatchesById.get(matchId)?.format ||
        factByMatchId.get(matchId)?.matchFormat ||
        "T20";
      if (format === "T10" || format === "BOX_CRICKET")
        return { pp: 3, middle: 8 };
      if (format === "ONE_DAY") return { pp: 10, middle: 40 };
      if (format === "TEST" || format === "TWO_INNINGS")
        return { pp: 10, middle: 80 };
      return { pp: 6, middle: 15 };
    };

    const battingFacts = facts.filter((fact) => fact.didBat);
    const bowlingFacts = facts.filter((fact) => fact.didBowl);
    const matchCount = facts.length;

    const totalRuns = this.sumBy(battingFacts, (fact: any) => fact.runs);
    const totalBallsFaced = this.sumBy(
      battingFacts,
      (fact: any) => fact.ballsFaced,
    );
    const totalFours = this.sumBy(battingFacts, (fact: any) => fact.fours);
    const totalSixes = this.sumBy(battingFacts, (fact: any) => fact.sixes);
    const totalBoundaries = totalFours + totalSixes;
    const boundaryRuns = totalFours * 4 + totalSixes * 6;
    const highestScore = battingFacts.reduce(
      (value: number, fact: any) => Math.max(value, fact.runs),
      0,
    );
    const battingDismissals = battingFacts.filter(
      (fact: any) => !fact.wasNotOut,
    ).length;

    const battingAverage =
      battingDismissals > 0
        ? this.round2(totalRuns / battingDismissals)
        : totalRuns;
    const strikeRate =
      totalBallsFaced > 0
        ? this.round2((totalRuns / totalBallsFaced) * 100)
        : 0;
    const runsPerInnings =
      battingFacts.length > 0
        ? this.round2(totalRuns / battingFacts.length)
        : 0;
    const ballsPerDismissal =
      battingDismissals > 0
        ? this.round2(totalBallsFaced / battingDismissals)
        : 0;
    const boundaryPerBall =
      totalBallsFaced > 0 ? this.round4(totalBoundaries / totalBallsFaced) : 0;
    const ballsPerBoundary =
      totalBoundaries > 0 ? this.round2(totalBallsFaced / totalBoundaries) : 0;
    const boundaryRunPct =
      totalRuns > 0 ? this.round2((boundaryRuns / totalRuns) * 100) : 0;
    const totalDotBallsFaced = this.sumBy(
      battingFacts,
      (fact: any) => fact.dotBalls,
    );
    const dotBallPctBat =
      totalBallsFaced > 0
        ? this.round2((totalDotBallsFaced / totalBallsFaced) * 100)
        : 0;

    const scoringBalls = battingEvents.filter(
      (ball: any) => ball.outcome !== "WIDE" && ball.runs > 0,
    ).length;
    const singles = battingEvents.filter(
      (ball: any) => ball.outcome !== "WIDE" && ball.runs === 1,
    ).length;
    const singlesPctBat =
      totalBallsFaced > 0 ? this.round2((singles / totalBallsFaced) * 100) : 0;
    const scoringShotPct =
      totalBallsFaced > 0
        ? this.round2((scoringBalls / totalBallsFaced) * 100)
        : 0;

    const thirties = battingFacts.filter(
      (fact: any) => fact.runs >= 30 && fact.runs < 50,
    ).length;
    const forties = battingFacts.filter(
      (fact: any) => fact.runs >= 40 && fact.runs < 50,
    ).length;
    const fifties = battingFacts.filter(
      (fact: any) => fact.runs >= 50 && fact.runs < 100,
    ).length;
    const hundreds = battingFacts.filter(
      (fact: any) => fact.runs >= 100,
    ).length;
    const ducks = battingFacts.filter(
      (fact: any) => fact.runs === 0 && !fact.wasNotOut,
    ).length;
    const fiftyPlusInnings = fifties + hundreds;
    const fiftyPlusInningsPct =
      battingFacts.length > 0
        ? this.round2((fiftyPlusInnings / battingFacts.length) * 100)
        : 0;
    const hundredConversionFromFiftyPct =
      fiftyPlusInnings > 0
        ? this.round2((hundreds / fiftyPlusInnings) * 100)
        : 0;
    const innings30Plus = battingFacts.filter(
      (fact: any) => fact.runs >= 30,
    ).length;
    const innings50Plus = battingFacts.filter(
      (fact: any) => fact.runs >= 50,
    ).length;
    const thirtyToFiftyConversionPct =
      innings30Plus > 0
        ? this.round2((innings50Plus / innings30Plus) * 100)
        : 0;
    const fiftyToHundredConversionPct =
      innings50Plus > 0 ? this.round2((hundreds / innings50Plus) * 100) : 0;
    const maxBoundariesInInnings = battingFacts.reduce(
      (value: number, fact: any) => Math.max(value, fact.fours + fact.sixes),
      0,
    );

    const battingPhase = {
      powerplay: { runs: 0, balls: 0, boundaries: 0 },
      middle: { runs: 0, balls: 0, boundaries: 0 },
      death: { runs: 0, balls: 0, boundaries: 0 },
    };
    const battingStyleBuckets = {
      pace: { runs: 0, balls: 0 },
      spin: { runs: 0, balls: 0 },
      leftArmPace: { runs: 0, balls: 0 },
      rightArmPace: { runs: 0, balls: 0 },
      offSpin: { runs: 0, balls: 0 },
      legSpin: { runs: 0, balls: 0 },
    };

    for (const event of battingEvents) {
      const matchId = (event as any).innings?.matchId || "";
      const phases = getPhases(matchId);
      if (event.outcome !== "WIDE") {
        const phase =
          event.overNumber < phases.pp
            ? "powerplay"
            : event.overNumber < phases.middle
              ? "middle"
              : "death";
        battingPhase[phase].runs += event.runs;
        battingPhase[phase].balls += 1;
        if (event.runs === 4 || event.runs === 6)
          battingPhase[phase].boundaries += 1;
      }

      const style = ((event.bowler as any)?.bowlingStyle || "").toUpperCase();
      if (event.outcome !== "WIDE") {
        if (this.isPaceStyle(style)) {
          battingStyleBuckets.pace.runs += event.runs;
          battingStyleBuckets.pace.balls += 1;
        } else if (this.isSpinStyle(style)) {
          battingStyleBuckets.spin.runs += event.runs;
          battingStyleBuckets.spin.balls += 1;
        }
        if (style.includes("LEFT") && this.isPaceStyle(style)) {
          battingStyleBuckets.leftArmPace.runs += event.runs;
          battingStyleBuckets.leftArmPace.balls += 1;
        }
        if (
          (style.includes("RIGHT") ||
            (!style.includes("LEFT") && !style.includes("RIGHT"))) &&
          this.isPaceStyle(style)
        ) {
          battingStyleBuckets.rightArmPace.runs += event.runs;
          battingStyleBuckets.rightArmPace.balls += 1;
        }
        if (style.includes("OFF")) {
          battingStyleBuckets.offSpin.runs += event.runs;
          battingStyleBuckets.offSpin.balls += 1;
        }
        if (style.includes("LEG")) {
          battingStyleBuckets.legSpin.runs += event.runs;
          battingStyleBuckets.legSpin.balls += 1;
        }
      }
    }

    const powerplayRuns = battingPhase.powerplay.runs;
    const powerplayBalls = battingPhase.powerplay.balls;
    const powerplaySR = this.strikeRate(powerplayRuns, powerplayBalls);
    const middleRuns = battingPhase.middle.runs;
    const middleBalls = battingPhase.middle.balls;
    const middleSR = this.strikeRate(middleRuns, middleBalls);
    const deathRuns = battingPhase.death.runs;
    const deathBalls = battingPhase.death.balls;
    const deathSR = this.strikeRate(deathRuns, deathBalls);
    const deathBoundaryPerBall =
      deathBalls > 0
        ? this.round4(battingPhase.death.boundaries / deathBalls)
        : 0;

    const vsPaceRuns = battingStyleBuckets.pace.runs;
    const vsPaceBalls = battingStyleBuckets.pace.balls;
    const vsPaceSR = this.strikeRate(vsPaceRuns, vsPaceBalls);
    const vsSpinRuns = battingStyleBuckets.spin.runs;
    const vsSpinBalls = battingStyleBuckets.spin.balls;
    const vsSpinSR = this.strikeRate(vsSpinRuns, vsSpinBalls);
    const vsLeftArmPaceSR = this.strikeRate(
      battingStyleBuckets.leftArmPace.runs,
      battingStyleBuckets.leftArmPace.balls,
    );
    const vsRightArmPaceSR = this.strikeRate(
      battingStyleBuckets.rightArmPace.runs,
      battingStyleBuckets.rightArmPace.balls,
    );
    const vsOffSpinSR = this.strikeRate(
      battingStyleBuckets.offSpin.runs,
      battingStyleBuckets.offSpin.balls,
    );
    const vsLegSpinSR = this.strikeRate(
      battingStyleBuckets.legSpin.runs,
      battingStyleBuckets.legSpin.balls,
    );

    const totalBallsBowled = this.sumBy(
      bowlingFacts,
      (fact: any) => fact.ballsBowled,
    );
    const totalOvers = this.round2(
      Math.floor(totalBallsBowled / 6) + (totalBallsBowled % 6) / 10,
    );
    const totalWickets = this.sumBy(bowlingFacts, (fact: any) => fact.wickets);
    const totalRunsConceded = this.sumBy(
      bowlingFacts,
      (fact: any) => fact.runsConceded,
    );
    const maidens = this.sumBy(bowlingFacts, (fact: any) => fact.maidens);
    const dotBallsBowled = this.sumBy(
      bowlingFacts,
      (fact: any) => fact.dotBalls,
    );
    const wides = this.sumBy(bowlingFacts, (fact: any) => fact.wides);
    const noBalls = this.sumBy(bowlingFacts, (fact: any) => fact.noBalls);
    const legalDeliveriesPct =
      totalBallsBowled + wides + noBalls > 0
        ? this.round2(
            (totalBallsBowled / (totalBallsBowled + wides + noBalls)) * 100,
          )
        : 0;

    const bowlingAverage =
      totalWickets > 0 ? this.round2(totalRunsConceded / totalWickets) : 0;
    const economyRate =
      totalBallsBowled > 0
        ? this.round2((totalRunsConceded / totalBallsBowled) * 6)
        : 0;
    const bowlingStrikeRate =
      totalWickets > 0 ? this.round2(totalBallsBowled / totalWickets) : 0;
    const wicketsPerMatch =
      matchCount > 0 ? this.round2(totalWickets / matchCount) : 0;
    const wicketsPerInnings =
      bowlingFacts.length > 0
        ? this.round2(totalWickets / bowlingFacts.length)
        : 0;
    const dotBallPctBowl =
      totalBallsBowled > 0
        ? this.round2((dotBallsBowled / totalBallsBowled) * 100)
        : 0;

    let boundariesConceded = 0;
    let wicketsBowled = 0;
    let wicketsLBW = 0;
    let wicketsCaught = 0;
    const bowlingPhase = {
      powerplay: { runs: 0, balls: 0 },
      middle: { runs: 0, balls: 0 },
      death: { runs: 0, balls: 0, wickets: 0 },
    };

    for (const event of bowlingEvents) {
      const matchId = (event as any).innings?.matchId || "";
      const phases = getPhases(matchId);
      if (event.runs === 4 || event.runs === 6) boundariesConceded += 1;
      const legal = event.outcome !== "WIDE" && event.outcome !== "NO_BALL";
      if (legal) {
        const phase =
          event.overNumber < phases.pp
            ? "powerplay"
            : event.overNumber < phases.middle
              ? "middle"
              : "death";
        bowlingPhase[phase].balls += 1;
        bowlingPhase[phase].runs += event.totalRuns;
      }
      if (event.isWicket) {
        if (event.dismissalType === "BOWLED") wicketsBowled += 1;
        else if (event.dismissalType === "LBW") wicketsLBW += 1;
        else if (event.dismissalType === "CAUGHT") wicketsCaught += 1;
        if (event.overNumber >= phases.middle) bowlingPhase.death.wickets += 1;
      }
    }

    const boundaryConcededPct =
      totalBallsBowled > 0
        ? this.round2((boundariesConceded / totalBallsBowled) * 100)
        : 0;
    const ballsPerBoundaryConceded =
      boundariesConceded > 0
        ? this.round2(totalBallsBowled / boundariesConceded)
        : 0;
    const controlBallPct =
      totalBallsBowled > 0
        ? this.round2(
            ((dotBallsBowled + totalWickets) / totalBallsBowled) * 100,
          )
        : 0;

    const bestFact = bowlingFacts
      .slice()
      .sort(
        (left: any, right: any) =>
          right.wickets - left.wickets ||
          left.runsConceded - right.runsConceded,
      )[0];
    const bestBowlingWickets = (bestFact as any)?.wickets ?? 0;
    const bestBowlingRuns = (bestFact as any)?.runsConceded ?? 0;
    const bestBowlingFigure = `${bestBowlingWickets}/${bestBowlingRuns}`;
    const threeWicketHauls = bowlingFacts.filter(
      (fact: any) => fact.wickets >= 3,
    ).length;
    const fourWicketHauls = bowlingFacts.filter(
      (fact: any) => fact.wickets >= 4,
    ).length;
    const fiveWicketHauls = bowlingFacts.filter(
      (fact: any) => fact.wickets >= 5,
    ).length;
    const otherWickets = Math.max(
      0,
      totalWickets - (wicketsBowled + wicketsLBW + wicketsCaught),
    );

    const ppBallsBowled = bowlingPhase.powerplay.balls;
    const ppRunsConceded = bowlingPhase.powerplay.runs;
    const ppEconomy =
      ppBallsBowled > 0 ? this.round2((ppRunsConceded / ppBallsBowled) * 6) : 0;
    const middleBallsBowled = bowlingPhase.middle.balls;
    const middleRunsConceded = bowlingPhase.middle.runs;
    const middleEconomy =
      middleBallsBowled > 0
        ? this.round2((middleRunsConceded / middleBallsBowled) * 6)
        : 0;
    const deathBallsBowled = bowlingPhase.death.balls;
    const deathRunsConceded = bowlingPhase.death.runs;
    const deathEconomy =
      deathBallsBowled > 0
        ? this.round2((deathRunsConceded / deathBallsBowled) * 6)
        : 0;
    const deathWickets = bowlingPhase.death.wickets;

    const catches = this.sumBy(facts, (fact: any) => fact.catches);
    const runOutDirect = this.sumBy(facts, (fact: any) => fact.runOuts);
    const runOutAssist = 0;
    const stumpings = this.sumBy(facts, (fact: any) => fact.stumpings);
    const totalDismissalInvolvements =
      catches + runOutDirect + runOutAssist + stumpings;
    const catchesPerMatch =
      matchCount > 0 ? this.round2(catches / matchCount) : 0;
    const runOutInvolvementPerMatch =
      matchCount > 0
        ? this.round2((runOutDirect + runOutAssist) / matchCount)
        : 0;
    const keepingInnings = facts.filter(
      (fact: any) => fact.stumpings > 0,
    ).length;
    const stumpingsPerKeepingInnings =
      keepingInnings > 0 ? this.round2(stumpings / keepingInnings) : 0;
    const missedChances = 0;
    const dismissalInvolvementPerMatch =
      matchCount > 0 ? this.round2(totalDismissalInvolvements / matchCount) : 0;

    const matchesPlayed = matchCount;
    const matchesWon = facts.filter(
      (fact: any) => fact.result === "WIN",
    ).length;
    const winPct =
      matchesPlayed > 0 ? this.round2((matchesWon / matchesPlayed) * 100) : 0;
    const chaseMatches = facts.filter(
      (fact: any) => fact.inningsNo === 2,
    ).length;
    const chaseWins = facts.filter(
      (fact: any) => fact.inningsNo === 2 && fact.result === "WIN",
    ).length;
    const defendMatches = facts.filter(
      (fact: any) => fact.inningsNo === 1,
    ).length;
    const defendWins = facts.filter(
      (fact: any) => fact.inningsNo === 1 && fact.result === "WIN",
    ).length;
    const knockoutMatchIds = new Set(
      playerMatches
        .filter((match: any) =>
          /QF|SF|FINAL|SEMI|KNOCKOUT/i.test(match.round || ""),
        )
        .map((match: any) => match.id),
    );
    const knockoutMatches = knockoutMatchIds.size;
    const knockoutScores = indexScores.filter((score: any) =>
      knockoutMatchIds.has(score.matchId),
    );
    const knockoutImpactAvg =
      knockoutScores.length > 0
        ? this.round2(
            knockoutScores.reduce(
              (sum: number, score: any) => sum + score.impactPoints,
              0,
            ) / knockoutScores.length,
          )
        : 0;
    const mvpCount = indexScores.filter((score: any) => score.isMvp).length;

    const last5BatFacts = battingFacts
      .slice()
      .sort(
        (left: any, right: any) =>
          right.matchDate.getTime() - left.matchDate.getTime(),
      )
      .slice(0, 5);
    const last5BowlFacts = bowlingFacts
      .slice()
      .sort(
        (left: any, right: any) =>
          right.matchDate.getTime() - left.matchDate.getTime(),
      )
      .slice(0, 5);
    const last10BatFacts = battingFacts
      .slice()
      .sort(
        (left: any, right: any) =>
          right.matchDate.getTime() - left.matchDate.getTime(),
      )
      .slice(0, 10);
    const last10BowlFacts = bowlingFacts
      .slice()
      .sort(
        (left: any, right: any) =>
          right.matchDate.getTime() - left.matchDate.getTime(),
      )
      .slice(0, 10);

    const last5Runs = this.sumBy(last5BatFacts, (fact: any) => fact.runs);
    const last5Wickets = this.sumBy(
      last5BowlFacts,
      (fact: any) => fact.wickets,
    );
    const last5Dismissals = last5BatFacts.filter(
      (fact: any) => !fact.wasNotOut,
    ).length;
    const last5BatAvg =
      last5Dismissals > 0
        ? this.round2(last5Runs / last5Dismissals)
        : last5Runs;
    const last5Balls = this.sumBy(
      last5BatFacts,
      (fact: any) => fact.ballsFaced,
    );
    const last5BatSR = this.strikeRate(last5Runs, last5Balls);
    const last5BowlRunsConceded = this.sumBy(
      last5BowlFacts,
      (fact: any) => fact.runsConceded,
    );
    const last5BowlBalls = this.sumBy(
      last5BowlFacts,
      (fact: any) => fact.ballsBowled,
    );
    const last5Economy =
      last5BowlBalls > 0
        ? this.round2((last5BowlRunsConceded / last5BowlBalls) * 6)
        : 0;
    const last10Runs = this.sumBy(last10BatFacts, (fact: any) => fact.runs);
    const last10Wickets = this.sumBy(
      last10BowlFacts,
      (fact: any) => fact.wickets,
    );
    const runsStdDev = this.round2(
      this.standardDeviation(battingFacts.map((fact: any) => fact.runs)),
    );
    const wicketsStdDev = this.round2(
      this.standardDeviation(bowlingFacts.map((fact: any) => fact.wickets)),
    );
    const avgRunsPerInnings =
      battingFacts.length > 0 ? totalRuns / battingFacts.length : 0;
    const avgWicketsPerInnings =
      bowlingFacts.length > 0 ? totalWickets / bowlingFacts.length : 0;
    const runsCv =
      avgRunsPerInnings > 0
        ? runsStdDev / avgRunsPerInnings
        : battingFacts.length > 0
          ? 0
          : null;
    const wicketsCv =
      avgWicketsPerInnings > 0
        ? wicketsStdDev / avgWicketsPerInnings
        : bowlingFacts.length > 0
          ? 0
          : null;

    let weightedCv = 0;
    if (runsCv !== null && wicketsCv !== null) {
      weightedCv = 0.6 * runsCv + 0.4 * wicketsCv;
    } else if (runsCv !== null) {
      weightedCv = runsCv;
    } else if (wicketsCv !== null) {
      weightedCv = wicketsCv;
    } else {
      weightedCv = 1; // No data
    }

    const consistencyIndex = this.round2(
      Math.max(0, Math.min(100, (1 - weightedCv) * 100)),
    );

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
    };

    return {
      playerId: profile.id,
      isApex: isApexActive,
      metricCount: Object.keys(metrics).length,
      metrics,
      generatedAt: new Date().toISOString(),
      source: {
        facts: facts.length,
        battingEvents: battingEvents.length,
        bowlingEvents: bowlingEvents.length,
        completedMatches: playerMatches.length,
      },
    };
  }

  async getPlayerAnalytics(
    playerId: string,
    options: {
      format?: string;
      timeframe?: "CAREER" | "SEASON" | "LAST_10" | "LAST_5";
    } = {},
  ) {
    const { format, timeframe } = options;

    const facts = await prisma.matchPlayerFact.findMany({
      where: {
        playerId,
        ...(format && format !== "ALL" ? { matchFormat: format as any } : {}),
      },
      orderBy: { matchDate: "desc" },
      ...(timeframe === "LAST_10"
        ? { take: 10 }
        : timeframe === "LAST_5"
          ? { take: 5 }
          : {}),
    });

    if (facts.length === 0) return null;

    const batting = this.aggregateBatting(facts);
    const bowling = this.aggregateBowling(facts);
    const [precision, wellness, swingState, statsOverall] = await Promise.all([
      this.getHighPrecisionAnalytics(playerId),
      this.getWellnessAndPhysicality(playerId),
      getSwingPlayerState(playerId),
      getPlayerStatOverall(playerId),
    ]);
    const reliabilityAxis = getAxisNumber(swingState?.axes, "reliabilityAxis");
    const impactAxis = getAxisNumber(swingState?.axes, "impactAxis");
    const fieldingAxis = getAxisNumber(swingState?.axes, "fieldingAxis");
    const captaincyAxis = getSubScoreNumber(swingState?.subScores, "Captaincy");

    return {
      playerId,
      swingIndex: swingState?.overallScore ?? 0,
      skillMatrix: {
        batting: swingState?.batScore ?? 0,
        bowling: swingState?.bowlScore ?? 0,
        fielding: swingState?.fieldingImpact ?? fieldingAxis ?? 0,
        fitness: 0,
        clutch: swingState?.impactScore ?? impactAxis ?? 0,
        consistency: statsOverall?.consistencyIndex ?? reliabilityAxis ?? 0,
        captaincy: captaincyAxis,
      },
      wellness,
      batting: {
        ...batting,
        precision: precision.phases,
        matchups: precision.matchups,
      },
      bowling,
    };
  }

  async comparePlayers(player1Id: string, player2Id: string, format?: string) {
    const [p1, p2] = await Promise.all([
      this.getPlayerAnalytics(player1Id, { format }),
      this.getPlayerAnalytics(player2Id, { format }),
    ]);
    return { player1: p1, player2: p2 };
  }

  async recalculateTeamPowerScore(teamId: string) {
    return recalculateTeamPowerScore(teamId);
  }

  private aggregateBatting(facts: any[]) {
    let totalRuns = 0,
      totalBalls = 0,
      dismissals = 0,
      highestScore = 0,
      totalFours = 0,
      totalSixes = 0,
      dotBalls = 0,
      thirties = 0,
      fifties = 0,
      hundreds = 0,
      ducks = 0;
    let innings1Runs = 0,
      innings1Balls = 0,
      innings1Matches = 0,
      innings1Wins = 0;
    let innings2Runs = 0,
      innings2Balls = 0,
      innings2Matches = 0,
      innings2Wins = 0;

    for (const fact of facts) {
      if (!fact.didBat) continue;
      totalRuns += fact.runs;
      totalBalls += fact.ballsFaced;
      totalFours += fact.fours;
      totalSixes += fact.sixes;
      dotBalls += fact.dotBalls;
      if (fact.runs > highestScore) highestScore = fact.runs;
      if (fact.runs >= 100) hundreds++;
      else if (fact.runs >= 50) fifties++;
      else if (fact.runs >= 30) thirties++;
      if (fact.runs === 0 && fact.wasNotOut === false) ducks++;
      if (fact.dismissalType && fact.dismissalType !== "NOT_OUT") dismissals++;

      if (fact.inningsNo === 1) {
        innings1Runs += fact.runs;
        innings1Balls += fact.ballsFaced;
        innings1Matches++;
        if (fact.result === "WIN") innings1Wins++;
      } else {
        innings2Runs += fact.runs;
        innings2Balls += fact.ballsFaced;
        innings2Matches++;
        if (fact.result === "WIN") innings2Wins++;
      }
    }

    const calcPct = (n: number, t: number) =>
      t > 0 ? Number(((n / t) * 100).toFixed(2)) : 0;

    return {
      summary: {
        totalMatches: facts.length,
        totalRuns,
        totalBallsFaced: totalBalls,
        average: Number((totalRuns / Math.max(1, dismissals)).toFixed(2)),
        strikeRate: calcPct(totalRuns, totalBalls),
        highestScore,
        fours: totalFours,
        sixes: totalSixes,
        thirties,
        fifties,
        hundreds,
        ducks,
      },
      kpis: {
        boundaryPercentage:
          totalRuns > 0
            ? calcPct(totalFours * 4 + totalSixes * 6, totalRuns)
            : 0,
        dotBallPercentage: calcPct(dotBalls, totalBalls),
        innings1Success: {
          average: Number(
            (innings1Runs / Math.max(1, innings1Matches)).toFixed(2),
          ),
          winRate: calcPct(innings1Wins, innings1Matches),
        },
        innings2Success: {
          average: Number(
            (innings2Runs / Math.max(1, innings2Matches)).toFixed(2),
          ),
          winRate: calcPct(innings2Wins, innings2Matches),
        },
      },
    };
  }

  private aggregateBowling(facts: any[]) {
    let totalWickets = 0,
      totalRunsConceded = 0,
      totalBallsBowled = 0,
      dotBalls = 0,
      maidens = 0,
      bestWickets = 0,
      bestRuns = 999,
      threeWicketHauls = 0,
      fiveWicketHauls = 0;

    for (const fact of facts) {
      if (!fact.didBowl) continue;
      totalWickets += fact.wickets;
      totalRunsConceded += fact.runsConceded;
      totalBallsBowled += fact.ballsBowled;
      dotBalls += fact.dotBalls;
      maidens += fact.maidens || 0;
      if (fact.wickets >= 5) fiveWicketHauls++;
      else if (fact.wickets >= 3) threeWicketHauls++;
      if (
        fact.wickets > bestWickets ||
        (fact.wickets === bestWickets && fact.runsConceded < bestRuns)
      ) {
        bestWickets = fact.wickets;
        bestRuns = fact.runsConceded;
      }
    }

    const overs = totalBallsBowled / 6;
    const calcPct = (n: number, t: number) =>
      t > 0 ? Number(((n / t) * 100).toFixed(2)) : 0;

    return {
      summary: {
        totalWickets,
        economy: Number((totalRunsConceded / Math.max(0.1, overs)).toFixed(2)),
        average: Number(
          (totalRunsConceded / Math.max(1, totalWickets)).toFixed(2),
        ),
        strikeRate:
          totalWickets > 0
            ? Number((totalBallsBowled / totalWickets).toFixed(2))
            : 0,
        bestBowling: `${bestWickets}/${bestRuns === 999 ? 0 : bestRuns}`,
        threeWicketHauls,
        fiveWicketHauls,
        maidens,
        dotBalls,
      },
      kpis: { dotBallPercentage: calcPct(dotBalls, totalBallsBowled) },
    };
  }

  async getArenaPerformance(playerId: string) {
    const facts = await prisma.matchPlayerFact.findMany({
      where: { playerId },
      include: { match: { select: { facilityId: true, venueName: true } } },
    });
    const arenaMap = new Map<string, any>();
    for (const fact of facts) {
      const fId = (fact.match as any).facilityId || "UNKNOWN",
        vName = (fact.match as any).venueName || "Unknown";
      const stats = arenaMap.get(fId) || {
        venueName: vName,
        matches: 0,
        runs: 0,
        balls: 0,
        wickets: 0,
        runsConceded: 0,
        ballsBowled: 0,
      };
      stats.matches++;
      if (fact.didBat) {
        stats.runs += fact.runs;
        stats.balls += fact.ballsFaced;
      }
      if (fact.didBowl) {
        stats.wickets += fact.wickets;
        stats.runsConceded += fact.runsConceded;
        stats.ballsBowled += fact.ballsBowled;
      }
      arenaMap.set(fId, stats);
    }
    return Array.from(arenaMap.values()).map((s) => ({
      ...s,
      battingAvg: Number((s.runs / Math.max(1, s.matches)).toFixed(2)),
      bowlingEcon: Number(
        (s.runsConceded / Math.max(0.1, s.ballsBowled / 6)).toFixed(2),
      ),
    }));
  }

  async getBenchmarks(playerId: string, scope: string = "CITY") {
    const playerStats = await this.getPlayerAnalytics(playerId);
    if (!playerStats) return null;
    const profile = await prisma.playerProfile.findUnique({
      where: { id: playerId },
      select: { city: true },
    });
    const averages = await prisma.matchPlayerFact.aggregate({
      where: { player: { city: profile?.city || "Bhopal" }, didBat: true },
      _avg: { runs: true, ballsFaced: true },
    });
    return {
      playerId,
      playerStats: {
        sr: playerStats.batting.summary.strikeRate,
        avg: playerStats.batting.summary.average,
      },
      benchmarks: {
        label: `City (${profile?.city || "Bhopal"})`,
        averageSR: Number(
          (
            ((averages._avg.runs || 0) / (averages._avg.ballsFaced || 1)) *
            100
          ).toFixed(2),
        ),
        percentile: 85,
      },
    };
  }

  async getTeamAnalytics(teamId: string) {
    // 1. Fetch Team
    const team = await prisma.team.findUnique({
      where: { id: teamId },
      select: { id: true, name: true, powerScore: true },
    });
    if (!team) return null;

    // 2. Fetch MatchPlayerFact for the team name (case-insensitive to handle
    //    any casing differences between stored name and current team.name)
    const facts = await prisma.matchPlayerFact.findMany({
      where: { teamId: { equals: team.name, mode: 'insensitive' } },
      include: {
        player: {
          include: { user: { select: { name: true, avatarUrl: true } } },
        },
      },
    });

    if (facts.length === 0)
      return {
        teamId,
        teamName: team.name,
        message: "No match data available for this team.",
      };

    // 3. Fetch Matches and Innings
    const matchIds = Array.from(new Set(facts.map((f) => f.matchId)));
    const matches = await prisma.match.findMany({
      where: { id: { in: matchIds }, status: "COMPLETED" },
      include: { innings: true },
    });

    // Sort matches by date using fact data (matchDate may be null for old records)
    const matchDateMap = new Map(
      facts.map((f) => [f.matchId, f.matchDate?.getTime() ?? 0]),
    );
    matches.sort(
      (a, b) => (matchDateMap.get(b.id) || 0) - (matchDateMap.get(a.id) || 0),
    );

    // 4. Aggregation variables
    const summary = {
      matchesPlayed: matches.length,
      totalWins: 0,
      totalLosses: 0,
      totalTies: 0,
      recentForm: [] as string[],
      winStreak: 0,
    };

    const batting = {
      totalRuns: 0,
      totalBallsFaced: 0,
      totalFours: 0,
      totalSixes: 0,
      dotBalls: 0,
      highestScore: 0,
      lowestScore: Infinity,
      inningsCount: 0,
      dismissals: 0,
    };

    const bowling = {
      totalRunsConceded: 0,
      totalBallsBowled: 0,
      totalWicketsTaken: 0,
      dotBallsBowled: 0,
      extrasConceded: 0,
      bestBowlingInMatch: { wickets: 0, runs: 0, playerName: "" },
    };

    const matchContext = {
      tossWon: 0,
      tossLost: 0,
      winAfterTossWin: 0,
      winAfterTossLoss: 0,
      battingFirstWins: 0,
      battingFirstTotal: 0,
      chasingWins: 0,
      chasingTotal: 0,
    };

    const venueStats = new Map<string, { matches: number; wins: number }>();
    const headToHead = new Map<string, { matches: number; wins: number }>();
    const playerStats = new Map<
      string,
      {
        name: string;
        avatarUrl: string | null;
        runs: number;
        balls: number;
        dismissals: number;
        wickets: number;
        runsConceded: number;
        ballsBowled: number;
        matches: number;
      }
    >();

    // Overs tracking for NRR
    let totalTeamOversFaced = 0;
    let totalTeamOversBowled = 0;
    let totalTeamRunsScored = 0;
    let totalTeamRunsConceded = 0;

    // 5. Loop through matches
    let currentStreak = 0;
    let streakActive = true;

    for (const m of matches) {
      const teamFacts = facts.filter((f) => f.matchId === m.id);
      if (teamFacts.length === 0) continue;

      const opponentName = teamFacts[0].opponentTeamId; // teamId/opponentTeamId in fact are names
      const result = teamFacts[0].result;
      const inningsNo = teamFacts[0].inningsNo;

      // Summary & Form
      if (result === "WIN") {
        summary.totalWins++;
        if (summary.recentForm.length < 5) summary.recentForm.push("W");
        if (streakActive) currentStreak++;
      } else if (result === "LOSS") {
        summary.totalLosses++;
        if (summary.recentForm.length < 5) summary.recentForm.push("L");
        streakActive = false;
      } else {
        summary.totalTies++;
        if (summary.recentForm.length < 5) summary.recentForm.push("T");
        streakActive = false;
      }

      // Venue
      const venue = m.venueName || "Unknown Venue";
      const vs = venueStats.get(venue) || { matches: 0, wins: 0 };
      vs.matches++;
      if (result === "WIN") vs.wins++;
      venueStats.set(venue, vs);

      // Head to Head
      const h2h = headToHead.get(opponentName) || { matches: 0, wins: 0 };
      h2h.matches++;
      if (result === "WIN") h2h.wins++;
      headToHead.set(opponentName, h2h);

      // Toss
      const ourSide =
        this.normalize(m.teamAName) === this.normalize(team.name) ? "A" : "B";
      const tossWon =
        this.normalize(m.tossWonBy) === "a"
          ? ourSide === "A"
          : this.normalize(m.tossWonBy) === "b"
            ? ourSide === "B"
            : this.normalize(m.tossWonBy) === this.normalize(team.name);

      if (tossWon) {
        matchContext.tossWon++;
        if (result === "WIN") matchContext.winAfterTossWin++;
      } else {
        matchContext.tossLost++;
        if (result === "WIN") matchContext.winAfterTossLoss++;
      }

      // Batting First/Chasing
      if (inningsNo === 1) {
        matchContext.battingFirstTotal++;
        if (result === "WIN") matchContext.battingFirstWins++;
      } else {
        matchContext.chasingTotal++;
        if (result === "WIN") matchContext.chasingWins++;
      }

      // Team Scores & NRR
      const ourInnings = m.innings.find((i) => i.inningsNumber === inningsNo);
      const oppInnings = m.innings.find(
        (i) => i.inningsNumber === (inningsNo === 1 ? 2 : 1),
      );

      if (ourInnings) {
        totalTeamRunsScored += ourInnings.totalRuns;
        batting.inningsCount++;
        if (ourInnings.totalRuns > batting.highestScore)
          batting.highestScore = ourInnings.totalRuns;
        if (ourInnings.totalRuns < batting.lowestScore)
          batting.lowestScore = ourInnings.totalRuns;

        // Overs faced for NRR
        const maxOvers = this.resolveMaxOvers(m);
        const oversFaced =
          ourInnings.totalWickets === 10 ? maxOvers : ourInnings.totalOvers;
        totalTeamOversFaced += this.toFractionalOvers(oversFaced);
      }

      if (oppInnings) {
        totalTeamRunsConceded += oppInnings.totalRuns;
        // Overs bowled for NRR
        const maxOvers = this.resolveMaxOvers(m);
        const oversBowled =
          oppInnings.totalWickets === 10 ? maxOvers : oppInnings.totalOvers;
        totalTeamOversBowled += this.toFractionalOvers(oversBowled);
      }

      // Individual Player Aggregation
      for (const f of teamFacts) {
        const ps = playerStats.get(f.playerId) || {
          name: f.player.user?.name ?? 'Unknown',
          avatarUrl: f.player.user?.avatarUrl ?? null,
          runs: 0,
          balls: 0,
          dismissals: 0,
          wickets: 0,
          runsConceded: 0,
          ballsBowled: 0,
          matches: 0,
        };
        ps.matches++;
        if (f.didBat) {
          ps.runs += f.runs;
          ps.balls += f.ballsFaced;
          if (f.dismissalType && f.dismissalType !== "NOT_OUT") ps.dismissals++;

          batting.totalRuns += f.runs;
          batting.totalBallsFaced += f.ballsFaced;
          batting.totalFours += f.fours;
          batting.totalSixes += f.sixes;
          batting.dotBalls += f.dotBalls;
          if (f.dismissalType && f.dismissalType !== "NOT_OUT")
            batting.dismissals++;
        }
        if (f.didBowl) {
          ps.wickets += f.wickets;
          ps.runsConceded += f.runsConceded;
          ps.ballsBowled += f.ballsBowled;

          bowling.totalRunsConceded += f.runsConceded;
          bowling.totalBallsBowled += f.ballsBowled;
          bowling.totalWicketsTaken += f.wickets;
          bowling.dotBallsBowled += f.dotBalls;
          bowling.extrasConceded += f.wides + f.noBalls;

          if (
            f.wickets > bowling.bestBowlingInMatch.wickets ||
            (f.wickets === bowling.bestBowlingInMatch.wickets &&
              f.runsConceded < bowling.bestBowlingInMatch.runs)
          ) {
            bowling.bestBowlingInMatch = {
              wickets: f.wickets,
              runs: f.runsConceded,
              playerName: ps.name,
            };
          }
        }
        playerStats.set(f.playerId, ps);
      }
    }

    summary.winStreak = currentStreak;

    // 6. Dynamic Power Score & Team SI Calculation
    // Only include players who have played at least 1 match for this team (based on facts)
    const activePlayerIds = Array.from(new Set(facts.map((f) => f.playerId)));
    const activePlayers = await prisma.playerProfile.findMany({
      where: { id: { in: activePlayerIds } },
      select: { id: true, swingIndex: true },
    });

    // Fetch lifetime IP from ip_player_state (player_competitive_profile was dropped in migration)
    const ipRows = activePlayerIds.length > 0
      ? await prisma.$queryRawUnsafe<Array<{ playerId: string; lifetimeIp: number }>>(
          `SELECT "playerId", "lifetimeIp" FROM public.ip_player_state WHERE "playerId" = ANY($1::text[])`,
          activePlayerIds,
        )
      : [];
    const ipByPlayerId = new Map(ipRows.map((r) => [r.playerId, r.lifetimeIp]));

    const eligibleCount = activePlayers.length;
    let totalIP = 0;
    let totalSI = 0;
    let siCount = 0;

    for (const p of activePlayers) {
      totalIP += ipByPlayerId.get(p.id) || 0;
      if (p.swingIndex !== null && p.swingIndex !== undefined) {
        totalSI += p.swingIndex;
        siCount++;
      }
    }

    const avgIP = eligibleCount > 0 ? totalIP / eligibleCount : 0;
    const avgSI = siCount > 0 ? Number((totalSI / siCount).toFixed(2)) : 0;

    // Power Score Calculation: avgIP / CEILING (e.g., 5000)
    const POWER_SCORE_CEILING = 5000;
    let calculatedPowerScore = Math.min(
      100,
      Math.round((avgIP / POWER_SCORE_CEILING) * 100),
    );

    // Adjust based on Win Rate (Performance Boost/Penalty)
    const winRate =
      summary.matchesPlayed > 0
        ? (summary.totalWins / summary.matchesPlayed) * 100
        : 0;
    if (winRate > 60) calculatedPowerScore = Math.min(100, calculatedPowerScore + 5);
    else if (winRate < 30 && calculatedPowerScore > 10)
      calculatedPowerScore -= 5;

    // 7. Final Calculations
    const calcPct = (n: number, t: number) =>
      t > 0 ? Number(((n / t) * 100).toFixed(2)) : 0;
    const calcAvg = (n: number, t: number) =>
      t > 0 ? Number((n / t).toFixed(2)) : 0;

    const nrr =
      totalTeamOversFaced > 0 && totalTeamOversBowled > 0
        ? Number(
            (
              totalTeamRunsScored / totalTeamOversFaced -
              totalTeamRunsConceded / totalTeamOversBowled
            ).toFixed(3),
          )
        : 0;

    const topBatsmen = Array.from(playerStats.entries())
      .map(([playerId, s]) => ({
        playerId,
        name: s.name,
        avatarUrl: s.avatarUrl,
        runs: s.runs,
        average: calcAvg(s.runs, s.dismissals),
        strikeRate: this.strikeRate(s.runs, s.balls),
      }))
      .sort((a, b) => b.runs - a.runs)
      .slice(0, 5);

    const topBowlers = Array.from(playerStats.entries())
      .map(([playerId, s]) => ({
        playerId,
        name: s.name,
        avatarUrl: s.avatarUrl,
        wickets: s.wickets,
        economy:
          s.ballsBowled > 0
            ? Number(((s.runsConceded / s.ballsBowled) * 6).toFixed(2))
            : 0,
        average: calcAvg(s.runsConceded, s.wickets),
      }))
      .sort((a, b) => b.wickets - a.wickets)
      .slice(0, 5);

    const playerContribution = {
      runsPercentage: topBatsmen.map((b) => ({
        name: b.name,
        percentage: calcPct(b.runs, batting.totalRuns),
      })),
      wicketsPercentage: topBowlers.map((b) => ({
        name: b.name,
        percentage: calcPct(b.wickets, bowling.totalWicketsTaken),
      })),
    };

    return {
      teamId,
      teamName: team.name,
      summary: {
        ...summary,
        winRate: calcPct(summary.totalWins, summary.matchesPlayed),
      },
      batting: {
        averageScore: calcAvg(totalTeamRunsScored, batting.inningsCount),
        highestScore: batting.highestScore,
        lowestScore: batting.lowestScore === Infinity ? 0 : batting.lowestScore,
        teamBattingAverage: calcAvg(batting.totalRuns, batting.dismissals),
        totalRuns: batting.totalRuns,
        totalFours: batting.totalFours,
        totalSixes: batting.totalSixes,
        dotBallPercentage: calcPct(batting.dotBalls, batting.totalBallsFaced),
        scoringRate:
          totalTeamOversFaced > 0
            ? Number((totalTeamRunsScored / totalTeamOversFaced).toFixed(2))
            : 0,
      },
      bowling: {
        averageEconomy:
          bowling.totalBallsBowled > 0
            ? Number(
                (bowling.totalRunsConceded / (bowling.totalBallsBowled / 6)).toFixed(
                  2,
                ),
              )
            : 0,
        totalWickets: bowling.totalWicketsTaken,
        averageWicketsPerMatch: calcAvg(
          bowling.totalWicketsTaken,
          summary.matchesPlayed,
        ),
        bowlingAverage: calcAvg(
          bowling.totalRunsConceded,
          bowling.totalWicketsTaken,
        ),
        bestBowling: bowling.bestBowlingInMatch,
        dotBallPercentage: calcPct(
          bowling.dotBallsBowled,
          bowling.totalBallsBowled,
        ),
        extrasConcededAverage: calcAvg(
          bowling.extrasConceded,
          summary.matchesPlayed,
        ),
      },
      topPerformers: {
        batsmen: topBatsmen,
        bowlers: topBowlers,
      },
      matchContext: {
        tossImpact: {
          winRateWhenWonToss: calcPct(
            matchContext.winAfterTossWin,
            matchContext.tossWon,
          ),
          winRateWhenLostToss: calcPct(
            matchContext.winAfterTossLoss,
            matchContext.tossLost,
          ),
        },
        battingFirstWinRate: calcPct(
          matchContext.battingFirstWins,
          matchContext.battingFirstTotal,
        ),
        chasingWinRate: calcPct(
          matchContext.chasingWins,
          matchContext.chasingTotal,
        ),
        venuePerformance: Array.from(venueStats.entries())
          .map(([name, s]) => ({
            venueName: name,
            matches: s.matches,
            wins: s.wins,
            winRate: calcPct(s.wins, s.matches),
          }))
          .sort((a, b) => b.matches - a.matches),
      },
      nrr,
      headToHead: Array.from(headToHead.entries())
        .map(([name, s]) => ({
          opponentTeamName: name,
          matches: s.matches,
          wins: s.wins,
          winRate: calcPct(s.wins, s.matches),
        }))
        .sort((a, b) => b.matches - a.matches),
      playerContribution,
      powerScore: {
        current: calculatedPowerScore,
        basis: "avgIP",
        eligiblePlayers: eligibleCount,
      },
      teamSI: avgSI,
    };
  }


  async getProjectedWinProbability(team1Id: string, team2Id: string) {
    const [t1, t2] = await Promise.all([
      prisma.team.findUnique({
        where: { id: team1Id },
        select: { powerScore: true, name: true },
      }),
      prisma.team.findUnique({
        where: { id: team2Id },
        select: { powerScore: true, name: true },
      }),
    ]);
    if (!t1 || !t2) return null;
    const totalPower = (t1.powerScore || 0) + (t2.powerScore || 0);
    if (totalPower === 0) return { [t1.name]: 50, [t2.name]: 50 };
    return {
      team1: {
        name: t1.name,
        winProbability: Number(
          (((t1.powerScore || 0) / totalPower) * 100).toFixed(1),
        ),
      },
      team2: {
        name: t2.name,
        winProbability: Number(
          (((t2.powerScore || 0) / totalPower) * 100).toFixed(1),
        ),
      },
    };
  }

  async generateDailySnapshots() {
    const players = await prisma.playerProfile.findMany({
      select: { id: true },
    });
    for (const p of players) {
      await this.getPlayerAnalytics(p.id);
    }
    return { generated: players.length };
  }

  async getHighPrecisionAnalytics(
    playerId: string,
    ballType: string = "LEATHER",
  ) {
    const [battingEvents, bowlingEvents] = await Promise.all([
      prisma.ballEvent.findMany({
        where: { batterId: playerId, innings: { match: { ballType } } },
        include: { bowler: { select: { bowlingStyle: true } } },
      }),
      prisma.ballEvent.findMany({
        where: { bowlerId: playerId, innings: { match: { ballType } } },
      }),
    ]);

    const phaseStats = {
      powerplay: { r: 0, b: 0 },
      middle: { r: 0, b: 0 },
      death: { r: 0, b: 0 },
    };
    const matchups = { pace: { r: 0, b: 0 }, spin: { r: 0, b: 0 } };

    for (const ball of battingEvents) {
      if (ball.outcome === "WIDE") continue;
      const over = ball.overNumber;
      if (over < 6) {
        phaseStats.powerplay.r += ball.runs;
        phaseStats.powerplay.b++;
      } else if (over < 15) {
        phaseStats.middle.r += ball.runs;
        phaseStats.middle.b++;
      } else {
        phaseStats.death.r += ball.runs;
        phaseStats.death.b++;
      }
      const style = (ball.bowler as any)?.bowlingStyle as string | undefined;
      if (style && (style.includes("FAST") || style.includes("MEDIUM"))) {
        matchups.pace.r += ball.runs;
        matchups.pace.b++;
      } else if (style && style !== "NOT_A_BOWLER") {
        matchups.spin.r += ball.runs;
        matchups.spin.b++;
      }
    }

    const bowlingPhaseStats = {
      powerplay: { r: 0, b: 0 },
      middle: { r: 0, b: 0 },
      death: { r: 0, b: 0 },
    };
    for (const ball of bowlingEvents) {
      const isLegal = ball.outcome !== "WIDE" && ball.outcome !== "NO_BALL";
      const over = ball.overNumber;
      const phase = over < 6 ? "powerplay" : over < 15 ? "middle" : "death";

      if (isLegal) bowlingPhaseStats[phase].b++;
      bowlingPhaseStats[phase].r += ball.totalRuns;
    }

    const calcSR = (r: number, b: number) =>
      b > 0 ? Number(((r / b) * 100).toFixed(2)) : 0;
    const calcEcon = (r: number, b: number) =>
      b > 0 ? Number(((r / b) * 6).toFixed(2)) : 0;

    return {
      playerId,
      ballType,
      phases: {
        powerplaySR: calcSR(phaseStats.powerplay.r, phaseStats.powerplay.b),
        middleOversSR: calcSR(phaseStats.middle.r, phaseStats.middle.b),
        deathOversSR: calcSR(phaseStats.death.r, phaseStats.death.b),
        // Bowling Phases
        powerplayEcon: calcEcon(
          bowlingPhaseStats.powerplay.r,
          bowlingPhaseStats.powerplay.b,
        ),
        middleOversEcon: calcEcon(
          bowlingPhaseStats.middle.r,
          bowlingPhaseStats.middle.b,
        ),
        deathOversEcon: calcEcon(
          bowlingPhaseStats.death.r,
          bowlingPhaseStats.death.b,
        ),
      },
      matchups: {
        paceSR: calcSR(matchups.pace.r, matchups.pace.b),
        spinSR: calcSR(matchups.spin.r, matchups.spin.b),
        paceBalls: matchups.pace.b,
        spinBalls: matchups.spin.b,
      },
    };
  }

  async getWellnessAndPhysicality(playerId: string) {
    const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    const [checkins, workloads, facts] = await Promise.all([
      prisma.playerWellnessCheckin.findMany({
        where: { playerId, date: { gte: thirtyDaysAgo } },
        orderBy: { date: "desc" },
        take: 7,
      }),
      prisma.playerWorkloadEvent.findMany({
        where: { playerId, date: { gte: thirtyDaysAgo } },
      }),
      prisma.matchPlayerFact.findMany({
        where: { playerId, matchDate: { gte: thirtyDaysAgo } },
      }),
    ]);
    let recoveryScore = 80;
    if (checkins.length > 0) {
      const r = checkins[0];
      recoveryScore = Number(
        (
          (10 - r.soreness) * 3.33 +
          (10 - r.fatigue) * 3.33 +
          r.sleepQuality * 3.33
        ).toFixed(1),
      );
    }
    const sumOvers = (s: number, v: any) => s + (Number(v) || 0);
    let overs =
      workloads.reduce((s, w) => sumOvers(s, w.oversBowled), 0) +
      facts.reduce((s, f) => sumOvers(s, f.oversBowled), 0);
    return {
      playerId,
      recoveryScore,
      totalTrainingHoursWeekly: Number(
        (
          workloads.reduce((s, w) => s + w.durationMinutes, 0) /
          60 /
          4.28
        ).toFixed(1),
      ),
      oversBowledPastMonth: Number(overs.toFixed(1)),
      fatigueLevel: checkins[0]?.fatigue || 5,
    };
  }

  private sumBy<T>(values: T[], selector: (value: T) => number) {
    return values.reduce((sum, value) => sum + (selector(value) || 0), 0);
  }

  private round2(value: number) {
    return Number(value.toFixed(2));
  }

  private round4(value: number) {
    return Number(value.toFixed(4));
  }

  private strikeRate(runs: number, balls: number) {
    return balls > 0 ? this.round2((runs / balls) * 100) : 0;
  }

  private standardDeviation(values: number[]) {
    if (values.length === 0) return 0;
    const mean = values.reduce((sum, value) => sum + value, 0) / values.length;
    const variance =
      values.reduce((sum, value) => sum + (value - mean) ** 2, 0) /
      values.length;
    return Math.sqrt(variance);
  }

  private isPaceStyle(style: string) {
    return style.includes("FAST") || style.includes("MEDIUM");
  }

  private isSpinStyle(style: string) {
    return (
      style.includes("SPIN") || style.includes("OFF") || style.includes("LEG")
    );
  }

  private isPlayerWinner(
    match: {
      winnerId: string | null;
      teamAName: string | null;
      teamBName: string | null;
      teamAPlayerIds: string[];
      teamBPlayerIds: string[];
    },
    playerId: string,
  ) {
    const playerSide = this.getPlayerTeamSide(match, playerId);
    if (!match.winnerId || !playerSide) return false;

    if (match.winnerId === "A") return playerSide === "A";
    if (match.winnerId === "B") return playerSide === "B";

    const winnerNorm = this.normalize(match.winnerId);
    if (winnerNorm === this.normalize(match.teamAName))
      return playerSide === "A";
    if (winnerNorm === this.normalize(match.teamBName))
      return playerSide === "B";

    return false;
  }

  private getPlayerTeamSide(
    match: { teamAPlayerIds: string[]; teamBPlayerIds: string[] },
    playerId: string,
  ): "A" | "B" | null {
    const onA = (match.teamAPlayerIds || []).includes(playerId);
    const onB = (match.teamBPlayerIds || []).includes(playerId);
    if (onA && !onB) return "A";
    if (onB && !onA) return "B";
    return null;
  }

  private computeChaseDefend(
    matches: Array<{
      id: string;
      winnerId: string | null;
      teamAName: string | null;
      teamBName: string | null;
      teamAPlayerIds: string[];
      teamBPlayerIds: string[];
    }>,
    inningsRecords: Array<{
      matchId: string;
      inningsNumber: number;
      battingTeam: string | null;
    }>,
    playerId: string,
  ) {
    const firstInningsTeamByMatch = new Map<string, string | null>();
    for (const innings of inningsRecords) {
      if (innings.inningsNumber !== 1) continue;
      if (!firstInningsTeamByMatch.has(innings.matchId)) {
        firstInningsTeamByMatch.set(innings.matchId, innings.battingTeam);
      }
    }

    let chaseMatches = 0;
    let chaseWins = 0;
    let defendMatches = 0;
    let defendWins = 0;

    for (const match of matches) {
      const playerSide = this.getPlayerTeamSide(match, playerId);
      if (!playerSide) continue;

      const firstBattingTeam = firstInningsTeamByMatch.get(match.id);
      if (!firstBattingTeam) continue;

      const firstNorm = this.normalize(firstBattingTeam);
      let firstBattingSide: "A" | "B" | null = null;
      if (firstNorm === "a" || firstNorm === this.normalize(match.teamAName))
        firstBattingSide = "A";
      if (firstNorm === "b" || firstNorm === this.normalize(match.teamBName))
        firstBattingSide = "B";
      if (!firstBattingSide) continue;

      const isChasing = playerSide !== firstBattingSide;
      const isWinner = this.isPlayerWinner(match, playerId);
      if (isChasing) {
        chaseMatches += 1;
        if (isWinner) chaseWins += 1;
      } else {
        defendMatches += 1;
        if (isWinner) defendWins += 1;
      }
    }

    return { chaseMatches, chaseWins, defendMatches, defendWins };
  }

  private normalize(value: string | null | undefined) {
    return (value || "").trim().toLowerCase();
  }

  private resolveMaxOvers(match: {
    customOvers?: number | null;
    format: string;
  }) {
    if (match.customOvers && match.customOvers > 0) return match.customOvers;
    switch (match.format) {
      case "T10":
        return 10;
      case "T20":
        return 20;
      case "ONE_DAY":
        return 50;
      case "BOX_CRICKET":
        return 6;
      case "TWO_INNINGS":
      case "TEST":
        return 90;
      default:
        return 20;
    }
  }

  private toFractionalOvers(overs: number) {
    const fullOvers = Math.floor(overs);
    const balls = Math.round((overs - fullOvers) * 10);
    return fullOvers + balls / 6;
  }
}
