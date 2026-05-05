import { prisma, UserRole, Prisma } from "@swing/db";
import { Errors, AppError } from "../../lib/errors";
import { NotificationService } from "../notifications/notification.service";
import { normalizePhone } from "@swing/utils";
import { PerformanceService } from "../performance/performance.service";
import { countIpEvents, getIpPlayerState } from "../performance/state-read.repository";
import { upsertIpPlayerState } from "../performance/state-write.repository";

const notificationSvc = new NotificationService();
const performanceSvc = new PerformanceService();

function cricketOversToBalls(overs: number | null | undefined) {
  if (!overs || overs <= 0) return 0;
  const wholeOvers = Math.trunc(overs);
  const balls = Math.round((overs - wholeOvers) * 10);
  return wholeOvers * 6 + Math.min(Math.max(balls, 0), 5);
}

function inningsBallsForNrr(
  innings: { totalOvers: number; totalWickets: number },
  quotaOvers?: number | null,
) {
  const actualBalls = cricketOversToBalls(innings.totalOvers);
  if (innings.totalWickets >= 10 && quotaOvers && quotaOvers > 0) {
    return quotaOvers * 6;
  }
  return actualBalls;
}

const MANAGED_PROFILE_TYPES = [
  "PLAYER",
  "COACH",
  "ACADEMY_OWNER",
  "ARENA_OWNER",
] as const;
type ManagedProfileType = (typeof MANAGED_PROFILE_TYPES)[number];
type TeamCompatRecord = {
  id: string;
  name: string;
  shortName: string | null;
  logoUrl: string | null;
  city: string | null;
  teamType: string;
  captainId: string | null;
  viceCaptainId: string | null;
  wicketKeeperId: string | null;
  playerIds: string[];
  createdByUserId: string;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
  supportStaff: any;
};
type TournamentCompatRecord = {
  id: string;
  academyId: string | null;
  overlayPackId: string | null;
  name: string;
  description: string | null;
  format: string;
  sport: string;
  startDate: Date;
  endDate: Date | null;
  venueName: string | null;
  city: string | null;
  maxTeams: number;
  entryFee: number | null;
  prizePool: string | null;
  rules: string | null;
  logoUrl: string | null;
  coverUrl: string | null;
  slug: string | null;
  highlights: any;
  isPublic: boolean;
  isVerified: boolean;
  status: string;
  tournamentFormat: string;
  seriesMatchCount: number | null;
  groupCount: number;
  pointsForWin: number;
  pointsForLoss: number;
  pointsForTie: number;
  pointsForNoResult: number;
  createdAt: Date;
  overlayPack?: {
    id: string;
    code: string;
    name: string;
    kind: string;
    isDefault: boolean;
  } | null;
};

type DashboardPeriod = "today" | "week" | "month" | "ytd";

type DashboardRange = {
  end: Date;
  label: string;
  period: DashboardPeriod;
  previousEnd: Date;
  previousStart: Date;
  start: Date;
};

const BUSINESS_TZ_OFFSET_MS = 5.5 * 60 * 60 * 1000;
const MONTH_LABELS = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec",
] as const;

export class AdminService {
  private teamColumnSupportPromise?: Promise<{
    viceCaptainId: boolean;
    wicketKeeperId: boolean;
    supportStaff: boolean;
  }>;
  private tournamentColumnSupportPromise?: Promise<{
    seriesMatchCount: boolean;
  }>;

  private async verifyAdmin(userId: string) {
    const adminUser = await prisma.adminUser.findUnique({
      where: { id: userId },
    });
    if (
      adminUser &&
      adminUser.isActive &&
      ["SWING_ADMIN", "SWING_SUPPORT"].includes(adminUser.role)
    ) {
      return adminUser;
    }
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (
      !user ||
      (!user.roles.includes("SWING_ADMIN" as any) &&
        !user.roles.includes("SWING_SUPPORT" as any))
    ) {
      throw Errors.forbidden();
    }
    return user;
  }

  private async generateUniqueMatchLiveCode() {
    for (let i = 0; i < 50; i++) {
      const num = Math.floor(1000 + Math.random() * 9000);
      const candidate = `swing#${num}`;
      const exists = await prisma.match.findFirst({
        where: { liveCode: candidate },
        select: { id: true },
      });
      if (!exists) return candidate;
    }

    throw new AppError(
      "LIVE_ACCESS_GENERATION_FAILED",
      "Unable to generate a unique live access code for this match",
      500,
    );
  }

  private generateMatchLivePin() {
    return String(Math.floor(1000 + Math.random() * 9000));
  }

  private shiftToBusinessTime(date: Date) {
    return new Date(date.getTime() + BUSINESS_TZ_OFFSET_MS);
  }

  private businessDate(year: number, month: number, day: number) {
    return new Date(Date.UTC(year, month, day) - BUSINESS_TZ_OFFSET_MS);
  }

  private addDays(date: Date, days: number) {
    return new Date(date.getTime() + days * 24 * 60 * 60 * 1000);
  }

  private dateRange(field: string, start: Date, end: Date) {
    return {
      [field]: {
        gte: start,
        lt: end,
      },
    } as Record<string, { gte: Date; lt: Date }>;
  }

  private getDashboardRange(
    period: DashboardPeriod,
    now = new Date(),
  ): DashboardRange {
    const businessNow = this.shiftToBusinessTime(now);
    const year = businessNow.getUTCFullYear();
    const month = businessNow.getUTCMonth();
    const day = businessNow.getUTCDate();

    if (period === "today") {
      const start = this.businessDate(year, month, day);
      return {
        end: now,
        label: "Today",
        period,
        previousEnd: start,
        previousStart: this.addDays(start, -1),
        start,
      };
    }

    if (period === "week") {
      const weekday = businessNow.getUTCDay();
      const mondayOffset = (weekday + 6) % 7;
      const start = this.businessDate(year, month, day - mondayOffset);
      return {
        end: now,
        label: "Week",
        period,
        previousEnd: start,
        previousStart: this.addDays(start, -7),
        start,
      };
    }

    if (period === "month") {
      const start = this.businessDate(year, month, 1);
      return {
        end: now,
        label: "Month",
        period,
        previousEnd: start,
        previousStart: this.businessDate(year, month - 1, 1),
        start,
      };
    }

    const start = this.businessDate(year, 0, 1);
    const previousStart = this.businessDate(year - 1, 0, 1);
    const elapsedMs = Math.max(now.getTime() - start.getTime(), 0);

    return {
      end: now,
      label: "YTD",
      period,
      previousEnd: new Date(previousStart.getTime() + elapsedMs),
      previousStart,
      start,
    };
  }

  private getMonthlyUserBuckets(now = new Date(), count = 6) {
    const businessNow = this.shiftToBusinessTime(now);
    const currentYear = businessNow.getUTCFullYear();
    const currentMonth = businessNow.getUTCMonth();

    return Array.from({ length: count }, (_, index) => {
      const relativeMonth = currentMonth - (count - index - 1);
      const start = this.businessDate(currentYear, relativeMonth, 1);
      const end = this.businessDate(currentYear, relativeMonth + 1, 1);
      const bucketDate = this.shiftToBusinessTime(start);

      return {
        label: MONTH_LABELS[bucketDate.getUTCMonth()],
        start,
        end,
      };
    });
  }

  private percentageGrowth(current: number, previous: number) {
    if (previous <= 0) {
      return current > 0 ? 100 : 0;
    }

    return Number((((current - previous) / previous) * 100).toFixed(1));
  }

  async ensureMatchLiveAccess(adminId: string, matchId: string) {
    await this.verifyAdmin(adminId);

    const existing = await prisma.match.findUnique({
      where: { id: matchId },
      select: { id: true, liveCode: true, livePin: true },
    });

    if (!existing) throw Errors.notFound("Match");
    if (existing.liveCode && existing.livePin) {
      return { liveCode: existing.liveCode, livePin: existing.livePin };
    }

    const liveCode =
      existing.liveCode ?? (await this.generateUniqueMatchLiveCode());
    const livePin = existing.livePin ?? this.generateMatchLivePin();

    const updated = await prisma.match.updateMany({
      where: {
        id: matchId,
        ...(existing.liveCode ? {} : { liveCode: null }),
        ...(existing.livePin ? {} : { livePin: null }),
      },
      data: {
        ...(existing.liveCode ? {} : { liveCode }),
        ...(existing.livePin ? {} : { livePin }),
      },
    });

    if (updated.count > 0) {
      return { liveCode, livePin };
    }

    const current = await prisma.match.findUnique({
      where: { id: matchId },
      select: { liveCode: true, livePin: true },
    });

    if (!current?.liveCode || !current.livePin) {
      throw new AppError(
        "LIVE_ACCESS_GENERATION_FAILED",
        "Unable to persist live access credentials for this match",
        500,
      );
    }

    return { liveCode: current.liveCode, livePin: current.livePin };
  }

  async getDashboard(userId: string, period: DashboardPeriod = "month") {
    await this.verifyAdmin(userId);

    const range = this.getDashboardRange(period);
    const userRange = this.dateRange("createdAt", range.start, range.end);
    const coachRange = this.dateRange("createdAt", range.start, range.end);
    const academyRange = this.dateRange("createdAt", range.start, range.end);
    const arenaRange = this.dateRange("createdAt", range.start, range.end);
    const matchRange = this.dateRange("scheduledAt", range.start, range.end);
    const bookingRange = this.dateRange("date", range.start, range.end);
    const cancelledBookingRange: any = {
      OR: [
        {
          cancelledAt: {
            gte: range.start,
            lt: range.end,
          },
        },
        {
          cancelledAt: null,
          ...bookingRange,
        },
      ],
      status: "CANCELLED",
    };
    const revenueRange: any = {
      OR: [
        {
          completedAt: {
            gte: range.start,
            lt: range.end,
          },
        },
        {
          completedAt: null,
          ...this.dateRange("createdAt", range.start, range.end),
        },
      ],
      status: "COMPLETED",
    };
    const previousRevenueRange: any = {
      OR: [
        {
          completedAt: {
            gte: range.previousStart,
            lt: range.previousEnd,
          },
        },
        {
          completedAt: null,
          ...this.dateRange(
            "createdAt",
            range.previousStart,
            range.previousEnd,
          ),
        },
      ],
      status: "COMPLETED",
    };
    const userBuckets = this.getMonthlyUserBuckets();

    const [
      usersInRange,
      totalPlayers,
      coachesInRange,
      academiesInRange,
      totalArenas,
      matchesInRange,
      activeMatches,
      bookingsInRange,
      completedBookings,
      cancelledBookings,
      totalRevenuePaise,
      previousRevenuePaise,
      totalGigBookings,
      totalSubscriptions,
      usersMoM,
    ] = await Promise.all([
      prisma.user.count({ where: userRange }),
      prisma.playerProfile.count({ where: userRange }),
      prisma.coachProfile.count({ where: coachRange }),
      prisma.academy.count({ where: academyRange }),
      prisma.arena.count({ where: arenaRange }),
      prisma.match.count({ where: matchRange }),
      prisma.match.count({
        where: {
          status: "IN_PROGRESS",
          ...matchRange,
        },
      }),
      prisma.slotBooking.count({ where: bookingRange }),
      prisma.slotBooking.count({
        where: {
          status: "COMPLETED",
          ...bookingRange,
        },
      }),
      prisma.slotBooking.count({ where: cancelledBookingRange }),
      prisma.payment.aggregate({
        where: revenueRange,
        _sum: { amountPaise: true },
      }),
      prisma.payment.aggregate({
        where: previousRevenueRange,
        _sum: { amountPaise: true },
      }),
      prisma.gigBooking.count({
        where: {
          completedAt: {
            gte: range.start,
            lt: range.end,
          },
          status: "COMPLETED",
        },
      }),
      prisma.subscription.count({
        where: {
          status: "ACTIVE",
        },
      }),
      Promise.all(
        userBuckets.map(async (bucket) => ({
          label: bucket.label,
          value: await prisma.user.count({
            where: this.dateRange("createdAt", bucket.start, bucket.end),
          }),
        })),
      ),
    ]);

    const currentRevenue = totalRevenuePaise._sum?.amountPaise || 0;
    const previousRevenue = previousRevenuePaise._sum?.amountPaise || 0;

    return {
      filters: {
        endAt: range.end.toISOString(),
        label: range.label,
        period: range.period,
        startAt: range.start.toISOString(),
      },
      users: {
        monthOnMonth: usersMoM,
        total: usersInRange,
        players: totalPlayers,
        coaches: coachesInRange,
      },
      academies: { total: academiesInRange },
      arenas: { total: totalArenas },
      matches: { total: matchesInRange, active: activeMatches },
      bookings: {
        cancelled: cancelledBookings,
        completed: completedBookings,
        total: bookingsInRange,
      },
      gigs: { completed: totalGigBookings },
      revenue: {
        growthPct: this.percentageGrowth(currentRevenue, previousRevenue),
        totalPaise: currentRevenue,
      },
      subscriptions: { total: totalSubscriptions },
    };
  }

  async listUsers(
    userId: string,
    filters: {
      role?: string;
      search?: string;
      blocked?: boolean;
      page: number;
      limit: number;
    },
  ) {
    await this.verifyAdmin(userId);

    const where: any = {};
    if (filters.role) where.roles = { has: filters.role };
    if (typeof filters.blocked === "boolean") where.isBlocked = filters.blocked;
    if (filters.search) {
      where.OR = [
        { name: { contains: filters.search, mode: "insensitive" } },
        { phone: { contains: filters.search } },
      ];
    }

    const [users, total] = await prisma.$transaction([
      prisma.user.findMany({
        where,
        select: {
          id: true,
          name: true,
          phone: true,
          email: true,
          avatarUrl: true,
          roles: true,
          activeRole: true,
          isActive: true,
          isBlocked: true,
          isVerified: true,
          createdAt: true,
          playerProfile: {
            select: {
              id: true,
            },
          },
        },
        orderBy: { createdAt: "desc" },
        skip: (filters.page - 1) * filters.limit,
        take: filters.limit,
      }),
      prisma.user.count({ where }),
    ]);

    return { users, total, page: filters.page, limit: filters.limit };
  }

  async getUser(adminId: string, targetUserId: string) {
    await this.verifyAdmin(adminId);
    const buildUserInclude = () => ({
      playerProfile: {
        include: {
          playerBadges: {
            include: { badge: true },
            orderBy: { awardedAt: "desc" as const },
            take: 20,
          },
          academyEnrollments: {
            include: {
              academy: {
                select: {
                  id: true,
                  name: true,
                  city: true,
                  state: true,
                  isVerified: true,
                },
              },
              batch: {
                select: { id: true, name: true, sport: true, isActive: true },
              },
            },
            orderBy: { enrolledAt: "desc" as const },
            take: 20,
          },
          slotBookings: {
            include: {
              arena: {
                select: { id: true, name: true, city: true, state: true },
              },
              unit: {
                select: { id: true, name: true, sport: true, unitType: true },
              },
              payment: {
                select: {
                  id: true,
                  status: true,
                  amountPaise: true,
                  createdAt: true,
                },
              },
            },
            orderBy: { createdAt: "desc" as const },
            take: 20,
          },
          gigBookings: {
            include: {
              payment: {
                select: {
                  id: true,
                  status: true,
                  amountPaise: true,
                  createdAt: true,
                },
              },
              gigListing: {
                select: {
                  id: true,
                  title: true,
                  city: true,
                  coach: {
                    select: {
                      id: true,
                      user: { select: { id: true, name: true, phone: true } },
                    },
                  },
                },
              },
            },
            orderBy: { createdAt: "desc" as const },
            take: 20,
          },
          trainingPlans: {
            include: {
              milestones: {
                select: {
                  id: true,
                  isCompleted: true,
                },
              },
            },
            orderBy: { createdAt: "desc" as const },
            take: 10,
          },
          reportCards: {
            include: {
              coach: {
                select: {
                  id: true,
                  user: { select: { id: true, name: true, phone: true } },
                },
              },
            },
            orderBy: [
              { periodYear: "desc" as const },
              { periodMonth: "desc" as const },
            ],
            take: 12,
          },
          feedbackTimeline: {
            include: {
              coach: {
                select: {
                  id: true,
                  user: { select: { id: true, name: true, phone: true } },
                },
              },
            },
            orderBy: { createdAt: "desc" as const },
            take: 20,
          },
          drillAssignments: {
            include: {
              drill: {
                select: {
                  id: true,
                  name: true,
                  skillArea: true,
                  difficulty: true,
                  durationMins: true,
                },
              },
              coach: {
                select: {
                  id: true,
                  user: { select: { id: true, name: true, phone: true } },
                },
              },
            },
            orderBy: { createdAt: "desc" as const },
            take: 20,
          },
          sessionAttendances: {
            include: {
              session: {
                select: {
                  id: true,
                  sessionType: true,
                  scheduledAt: true,
                  locationName: true,
                },
              },
            },
            orderBy: { scannedAt: "desc" as const },
            take: 20,
          },
          wellnessCheckins: {
            orderBy: { date: "desc" as const },
            take: 10,
          },
          workloadEvents: {
            orderBy: [
              { date: "desc" as const },
              { createdAt: "desc" as const },
            ],
            take: 20,
          },
        },
      },
      coachProfile: {
        include: {
          academies: {
            include: {
              academy: {
                select: {
                  id: true,
                  name: true,
                  city: true,
                  state: true,
                  isVerified: true,
                },
              },
            },
            orderBy: { joinedAt: "desc" as const },
          },
          sessions: {
            select: {
              id: true,
              sessionType: true,
              scheduledAt: true,
              isCompleted: true,
              academyId: true,
              batchId: true,
            },
            orderBy: { scheduledAt: "desc" as const },
            take: 15,
          },
          gigListings: {
            select: {
              id: true,
              title: true,
              pricePaise: true,
              city: true,
              isFeatured: true,
              isActive: true,
              createdAt: true,
            },
            orderBy: { createdAt: "desc" as const },
            take: 15,
          },
          drillsCreated: {
            select: {
              id: true,
              name: true,
              skillArea: true,
              difficulty: true,
              createdAt: true,
            },
            orderBy: { createdAt: "desc" as const },
            take: 15,
          },
          reportCards: {
            select: {
              id: true,
              playerProfileId: true,
              periodMonth: true,
              periodYear: true,
              isPublished: true,
              createdAt: true,
            },
            orderBy: { createdAt: "desc" as const },
            take: 15,
          },
        },
      },
      academyOwnerProfile: {
        include: {
          academies: {
            include: {
              _count: {
                select: {
                  coaches: true,
                  batches: true,
                  enrollments: true,
                  sessions: true,
                },
              },
            },
            orderBy: { createdAt: "desc" as const },
          },
        },
      },
      arenaOwnerProfile: {
        include: {
          arenas: {
            include: {
              _count: {
                select: {
                  units: true,
                  bookings: true,
                  addons: true,
                  reviews: true,
                },
              },
            },
            orderBy: { createdAt: "desc" as const },
          },
        },
      },
      payments: {
        orderBy: { createdAt: "desc" as const },
        take: 20,
      },
      notifications: {
        orderBy: { createdAt: "desc" as const },
        take: 20,
      },
      supportTickets: {
        include: {
          messages: {
            orderBy: { createdAt: "asc" as const },
            take: 10,
          },
        },
        orderBy: { updatedAt: "desc" as const },
        take: 20,
      },
    });

    const user = await prisma.user.findUnique({
      where: { id: targetUserId },
      include: buildUserInclude(),
    });

    if (!user) throw Errors.notFound("User");

    const loadOptional = async <T>(task: () => Promise<T>, fallback: T) => {
      try {
        return await task();
      } catch (error) {
        const missingResource =
          error instanceof Prisma.PrismaClientKnownRequestError &&
          (error.code === "P2021" || error.code === "P2022");
        if (!missingResource) throw error;
        return fallback;
      }
    };

    const playerContext = user.playerProfile
      ? await prisma.$transaction(async (tx) => {
          const playerProfileId = user.playerProfile!.id;
          const [
            recentMatches,
            totalMatches,
            completedMatches,
            tournamentEntries,
          ] = await Promise.all([
            tx.match.findMany({
              where: {
                OR: [
                  { teamAPlayerIds: { has: playerProfileId } },
                  { teamBPlayerIds: { has: playerProfileId } },
                ],
              },
              include: {
                innings: {
                  select: {
                    inningsNumber: true,
                    totalRuns: true,
                    totalWickets: true,
                    isCompleted: true,
                  },
                },
              },
              orderBy: { createdAt: "desc" },
              take: 10,
            }),
            tx.match.count({
              where: {
                OR: [
                  { teamAPlayerIds: { has: playerProfileId } },
                  { teamBPlayerIds: { has: playerProfileId } },
                ],
              },
            }),
            tx.match.count({
              where: {
                status: "COMPLETED",
                OR: [
                  { teamAPlayerIds: { has: playerProfileId } },
                  { teamBPlayerIds: { has: playerProfileId } },
                ],
              },
            }),
            tx.tournamentTeam.findMany({
              where: {
                OR: [
                  { playerIds: { has: playerProfileId } },
                  { captainId: playerProfileId },
                ],
              },
              include: {
                tournament: {
                  select: {
                    id: true,
                    name: true,
                    status: true,
                    format: true,
                    startDate: true,
                    endDate: true,
                    city: true,
                    venueName: true,
                    academy: { select: { id: true, name: true } },
                  },
                },
                group: { select: { id: true, name: true } },
                standing: {
                  select: {
                    position: true,
                    played: true,
                    won: true,
                    lost: true,
                    tied: true,
                    noResult: true,
                    points: true,
                    nrr: true,
                  },
                },
              },
              orderBy: { registeredAt: "desc" },
              take: 20,
            }),
          ]);

          return {
            recentMatches,
            totalMatches,
            completedMatches,
            tournamentEntries,
          };
        })
      : {
          recentMatches: [],
          totalMatches: 0,
          completedMatches: 0,
          tournamentEntries: [],
        };

    const playerPerformance = user.playerProfile
      ? await Promise.all([
          loadOptional(
            () => performanceSvc.getPlayerStatsSummary(user.playerProfile!.id),
            null,
          ),
          loadOptional(
            () => performanceSvc.getPlayerSeason(user.playerProfile!.id),
            null,
          ),
          loadOptional(
            () => performanceSvc.getHealthDashboard(user.playerProfile!.id),
            null,
          ),
          loadOptional(
            () =>
              performanceSvc.getCompetitiveEvents(user.playerProfile!.id, 20),
            [],
          ),
        ]).then(([stats, season, health, competitiveEvents]) => ({
          stats,
          season,
          health,
          competitiveEvents,
        }))
      : null;

    const ipState = user.playerProfile
      ? await loadOptional(() => getIpPlayerState(user.playerProfile!.id), null)
      : null;
    const playerIpEventCount = user.playerProfile
      ? await loadOptional(() => countIpEvents(user.playerProfile!.id), 0)
      : 0;

    const playerSummary = user.playerProfile
      ? {
          swingIndex:
            playerPerformance?.stats?.swingIndex.currentSwingIndex ?? 0,
          reliabilityIndex:
            playerPerformance?.stats?.swingIndex.reliabilityIndex ??
            user.playerProfile.battingScore,
          powerIndex:
            playerPerformance?.stats?.swingIndex.powerIndex ?? 0,
          bowlingIndex:
            playerPerformance?.stats?.swingIndex.bowlingIndex ??
            user.playerProfile.bowlingScore,
          fieldingIndex:
            playerPerformance?.stats?.swingIndex.fieldingIndex ??
            user.playerProfile.fieldingScore,
          impactIndex: playerPerformance?.stats?.swingIndex.impactIndex ?? 0,
          captaincyIndex:
            playerPerformance?.stats?.swingIndex.captaincyIndex ?? null,
          rank:
            playerPerformance?.stats?.competitive.rank ??
            ipState?.currentRankKey ??
            "ROOKIE",
          rankKey:
            playerPerformance?.stats?.competitive.rankKey ??
            ipState?.currentRankKey ??
            "ROOKIE",
          division:
            playerPerformance?.stats?.competitive.division ??
            ipState?.currentDivision ??
            null,
          lifetimeImpactPoints:
            playerPerformance?.stats?.competitive.impactPoints ??
            ipState?.lifetimeIp ??
            0,
          rankProgressPoints:
            playerPerformance?.stats?.competitive.rankProgress ??
            ipState?.rankProgressPoints ??
            0,
          rankProgressMax:
            playerPerformance?.stats?.competitive.rankProgressMax ?? 0,
          seasonPoints: playerPerformance?.season?.seasonPoints ?? 0,
          seasonLeaderboardPosition:
            playerPerformance?.season?.leaderboardPosition ?? null,
          seasonName: playerPerformance?.season?.seasonName ?? null,
          passMultiplier: playerPerformance?.season?.passMultiplier ?? 1,
          mvpCount:
            playerPerformance?.stats?.competitive.mvpCount ??
            ipState?.mvpCount ??
            0,
          matchesPlayed: user.playerProfile.matchesPlayed,
          matchesWon: user.playerProfile.matchesWon,
          matchWinPct:
            user.playerProfile.matchesPlayed > 0
              ? Number(
                  (
                    (user.playerProfile.matchesWon /
                      user.playerProfile.matchesPlayed) *
                    100
                  ).toFixed(1),
                )
              : 0,
          totalRuns: user.playerProfile.totalRuns,
          battingAverage: user.playerProfile.battingAverage,
          strikeRate: user.playerProfile.strikeRate,
          highestScore: user.playerProfile.highestScore,
          fours: user.playerProfile.fours,
          sixes: user.playerProfile.sixes,
          totalWickets: user.playerProfile.totalWickets,
          economyRate: user.playerProfile.economyRate,
          bowlingAverage: user.playerProfile.bowlingAverage,
          bestBowling: user.playerProfile.bestBowling,
          catches: user.playerProfile.catches,
          stumpings: user.playerProfile.stumpings,
          runOuts: user.playerProfile.runOuts,
          academyCount:
            user.playerProfile.academyEnrollments?.filter(
              (item) => item.isActive,
            ).length || 0,
          tournamentCount: playerContext.tournamentEntries.length,
          matchCount: playerContext.totalMatches,
          completedMatchCount: playerContext.completedMatches,
        }
      : null;

    return {
      ...user,
      recentMatches: playerContext.recentMatches,
      playerSummary,
      playerPerformance,
      tournamentEntries: playerContext.tournamentEntries,
      counts: {
        payments: user.payments.length,
        notifications: user.notifications.length,
        supportTickets: user.supportTickets.length,
        playerBadges: user.playerProfile?.playerBadges.length || 0,
        ipTransactions: playerIpEventCount,
        academyEnrollments: user.playerProfile?.academyEnrollments.length || 0,
        activeAcademyEnrollments:
          user.playerProfile?.academyEnrollments.filter((item) => item.isActive)
            .length || 0,
        slotBookings: user.playerProfile?.slotBookings.length || 0,
        gigBookings: user.playerProfile?.gigBookings.length || 0,
        tournaments: playerContext.tournamentEntries.length,
        recentMatches: playerContext.recentMatches.length,
        totalMatches: playerContext.totalMatches,
        completedMatches: playerContext.completedMatches,
        academiesOwned: user.academyOwnerProfile?.academies.length || 0,
        arenasOwned: user.arenaOwnerProfile?.arenas.length || 0,
        coachSessions: user.coachProfile?.sessions.length || 0,
        coachGigs: user.coachProfile?.gigListings.length || 0,
      },
    };
  }

  async createUser(
    adminId: string,
    data: {
      name: string;
      phone: string;
      email?: string;
      roles: string[];
      activeRole?: string;
      isVerified?: boolean;
      isActive?: boolean;
      createProfiles?: string[];
      playerProfile?: {
        city?: string;
        state?: string;
        bio?: string;
        goals?: string;
        level?: string;
        playerRole?: string;
        battingStyle?: string;
        bowlingStyle?: string;
        dateOfBirth?: string;
        jerseyNumber?: number;
      };
      coachProfile?: {
        city?: string;
        state?: string;
        bio?: string;
        experienceYears?: number;
        specializations?: string[];
      };
      arenaOwnerProfile?: {
        businessName?: string;
        gstNumber?: string;
        panNumber?: string;
      };
    },
  ) {
    await this.verifyAdmin(adminId);
    const roles = Array.from(new Set((data.roles || []).filter(Boolean)));
    if (roles.length === 0) {
      throw new AppError("INVALID_ROLES", "At least one role is required", 400);
    }
    const activeRole = roles.includes(data.activeRole || "")
      ? data.activeRole!
      : roles[0];
    const createProfiles = Array.from(
      new Set(
        (data.createProfiles?.length ? data.createProfiles : roles).filter(
          Boolean,
        ),
      ),
    );

    const existingPhone = await prisma.user.findUnique({
      where: { phone: data.phone },
    });
    if (existingPhone)
      throw new AppError(
        "PHONE_EXISTS",
        "A user with this phone already exists",
        409,
      );
    if (data.email) {
      const existingEmail = await prisma.user.findUnique({
        where: { email: data.email },
      });
      if (existingEmail)
        throw new AppError(
          "EMAIL_EXISTS",
          "A user with this email already exists",
          409,
        );
    }

    return prisma.$transaction(async (tx) => {
      const user = await tx.user.create({
        data: {
          name: data.name,
          phone: data.phone,
          email: data.email || null,
          roles: roles as any[],
          activeRole: activeRole as any,
          isVerified: data.isVerified ?? false,
          isActive: data.isActive ?? true,
        },
      });

      if (createProfiles.includes("PLAYER")) {
        const pp = data.playerProfile;
        await tx.playerProfile.create({
          data: {
            userId: user.id,
            city: pp?.city,
            state: pp?.state,
            bio: pp?.bio,
            goals: pp?.goals,
            level: (pp?.level as any) || undefined,
            playerRole: (pp?.playerRole as any) || undefined,
            battingStyle: (pp?.battingStyle as any) || undefined,
            bowlingStyle: (pp?.bowlingStyle as any) || undefined,
            ...(pp?.dateOfBirth
              ? { dateOfBirth: new Date(pp.dateOfBirth) }
              : {}),
          },
        });
      }

      if (createProfiles.includes("COACH")) {
        await tx.coachProfile.create({
          data: {
            userId: user.id,
            city: data.coachProfile?.city,
            state: data.coachProfile?.state,
            bio: data.coachProfile?.bio,
            experienceYears: data.coachProfile?.experienceYears || 0,
            specializations: data.coachProfile?.specializations || [],
          },
        });
      }

      if (createProfiles.includes("ACADEMY_OWNER")) {
        await tx.academyOwnerProfile.create({ data: { userId: user.id } });
      }

      if (createProfiles.includes("ARENA_OWNER")) {
        await tx.arenaOwnerProfile.create({
          data: {
            userId: user.id,
            businessName: data.arenaOwnerProfile?.businessName,
            gstNumber: data.arenaOwnerProfile?.gstNumber,
            panNumber: data.arenaOwnerProfile?.panNumber,
          },
        });
      }

      return tx.user.findUnique({
        where: { id: user.id },
        include: {
          playerProfile: true,
          coachProfile: true,
          academyOwnerProfile: true,
          arenaOwnerProfile: true,
        },
      });
    });
  }

  async updateUser(
    adminId: string,
    targetUserId: string,
    data: {
      name?: string;
      phone?: string;
      email?: string | null;
      activeRole?: string;
      isVerified?: boolean;
      isActive?: boolean;
      avatarUrl?: string | null;
    },
  ) {
    await this.verifyAdmin(adminId);
    const user = await prisma.user.findUnique({ where: { id: targetUserId } });
    if (!user) throw Errors.notFound("User");

    if (data.phone && data.phone !== user.phone) {
      const existingPhone = await prisma.user.findUnique({
        where: { phone: data.phone },
      });
      if (existingPhone)
        throw new AppError(
          "PHONE_EXISTS",
          "A user with this phone already exists",
          409,
        );
    }

    if (data.email && data.email !== user.email) {
      const existingEmail = await prisma.user.findUnique({
        where: { email: data.email },
      });
      if (existingEmail)
        throw new AppError(
          "EMAIL_EXISTS",
          "A user with this email already exists",
          409,
        );
    }

    if (data.activeRole && !user.roles.includes(data.activeRole as any)) {
      throw new AppError(
        "INVALID_ACTIVE_ROLE",
        "Active role must be one of the user roles",
        400,
      );
    }

    return prisma.user.update({
      where: { id: targetUserId },
      data: {
        name: data.name,
        phone: data.phone,
        email: data.email === undefined ? undefined : data.email,
        activeRole: data.activeRole as any,
        isVerified: data.isVerified,
        isActive: data.isActive,
        avatarUrl: data.avatarUrl === undefined ? undefined : data.avatarUrl,
      },
      select: {
        id: true,
        name: true,
        phone: true,
        email: true,
        roles: true,
        activeRole: true,
        isVerified: true,
        isActive: true,
        avatarUrl: true,
        isBlocked: true,
        createdAt: true,
      },
    });
  }

  async deleteUser(adminId: string, targetUserId: string) {
    await this.verifyAdmin(adminId);
    if (adminId === targetUserId) {
      throw new AppError(
        "CANNOT_DELETE_SELF",
        "You cannot delete your own admin account from the users page",
        400,
      );
    }

    const user = await prisma.user.findUnique({
      where: { id: targetUserId },
      include: {
        playerProfile: { select: { id: true } },
        coachProfile: { select: { id: true } },
        academyOwnerProfile: {
          include: { academies: { select: { id: true }, take: 1 } },
        },
        arenaOwnerProfile: {
          include: { arenas: { select: { id: true }, take: 1 } },
        },
        arenaManagerProfiles: { select: { id: true }, take: 1 },
        parentProfile: { select: { id: true } },
        payments: { select: { id: true }, take: 1 },
        supportTickets: { select: { id: true }, take: 1 },
        reviews: { select: { id: true }, take: 1 },
        hostedTournaments: { select: { id: true }, take: 1 },
        hostedEvents: { select: { id: true }, take: 1 },
        notificationPreference: { select: { userId: true } },
      },
    });
    if (!user) throw Errors.notFound("User");

    const hasProtectedLinks =
      Boolean(user.playerProfile) ||
      Boolean(user.coachProfile) ||
      Boolean(user.parentProfile) ||
      Boolean(user.academyOwnerProfile?.academies.length) ||
      Boolean(user.arenaOwnerProfile?.arenas.length) ||
      Boolean(user.arenaManagerProfiles.length) ||
      Boolean(user.payments.length) ||
      Boolean(user.supportTickets.length) ||
      Boolean(user.reviews.length) ||
      Boolean(user.hostedTournaments.length) ||
      Boolean(user.hostedEvents.length);

    if (hasProtectedLinks) {
      throw new AppError(
        "USER_IN_USE",
        "This user has linked profiles or activity. Remove those links first, then delete the user.",
        409,
      );
    }

    await prisma.$transaction(async (tx) => {
      await tx.notification.deleteMany({ where: { userId: targetUserId } });
      await tx.refreshToken.deleteMany({ where: { userId: targetUserId } });
      await tx.otpVerification.deleteMany({ where: { userId: targetUserId } });
      if (user.notificationPreference) {
        await tx.notificationPreference.delete({
          where: { userId: targetUserId },
        });
      }
      await tx.user.delete({ where: { id: targetUserId } });
    });

    return { deleted: targetUserId };
  }

  async createUserProfile(
    adminId: string,
    targetUserId: string,
    profileType: ManagedProfileType,
  ) {
    await this.verifyAdmin(adminId);
    const user = await prisma.user.findUnique({
      where: { id: targetUserId },
      include: {
        playerProfile: true,
        coachProfile: true,
        academyOwnerProfile: true,
        arenaOwnerProfile: true,
      },
    });
    if (!user) throw Errors.notFound("User");

    if (!MANAGED_PROFILE_TYPES.includes(profileType)) {
      throw new AppError(
        "INVALID_PROFILE_TYPE",
        "Unsupported profile type",
        400,
      );
    }

    return prisma.$transaction(async (tx) => {
      if (profileType === "PLAYER") {
        if (user.playerProfile)
          throw new AppError(
            "PROFILE_EXISTS",
            "Player profile already exists",
            409,
          );
        await tx.playerProfile.create({ data: { userId: user.id } });
      }
      if (profileType === "COACH") {
        if (user.coachProfile)
          throw new AppError(
            "PROFILE_EXISTS",
            "Coach profile already exists",
            409,
          );
        await tx.coachProfile.create({ data: { userId: user.id } });
      }
      if (profileType === "ACADEMY_OWNER") {
        if (user.academyOwnerProfile)
          throw new AppError(
            "PROFILE_EXISTS",
            "Academy owner profile already exists",
            409,
          );
        await tx.academyOwnerProfile.create({ data: { userId: user.id } });
      }
      if (profileType === "ARENA_OWNER") {
        if (user.arenaOwnerProfile)
          throw new AppError(
            "PROFILE_EXISTS",
            "Arena owner profile already exists",
            409,
          );
        await tx.arenaOwnerProfile.create({ data: { userId: user.id } });
      }

      if (!user.roles.includes(profileType as any)) {
        await tx.user.update({
          where: { id: user.id },
          data: { roles: { push: profileType as any } },
        });
      }

      return { message: `${profileType} profile created` };
    });
  }

  async deleteUserProfile(
    adminId: string,
    targetUserId: string,
    profileType: ManagedProfileType,
  ) {
    await this.verifyAdmin(adminId);
    const user = await prisma.user.findUnique({
      where: { id: targetUserId },
      include: {
        playerProfile: true,
        coachProfile: true,
        academyOwnerProfile: true,
        arenaOwnerProfile: true,
      },
    });
    if (!user) throw Errors.notFound("User");

    if (profileType === "PLAYER") {
      const profile = user.playerProfile;
      if (!profile) throw Errors.notFound("Player profile");
      const [
        matchStatsCount,
        enrollmentsCount,
        slotBookingsCount,
        gigBookingsCount,
        ipEventsCount,
        badgesCount,
      ] = await Promise.all([
        prisma.playerMatchStats.count({
          where: { playerProfileId: profile.id },
        }),
        prisma.academyEnrollment.count({
          where: { playerProfileId: profile.id },
        }),
        prisma.slotBooking.count({ where: { bookedById: profile.id } }),
        prisma.gigBooking.count({ where: { playerProfileId: profile.id } }),
        countIpEvents(profile.id),
        prisma.playerBadge.count({ where: { playerProfileId: profile.id } }),
      ]);
      const dependencyCount = [
        matchStatsCount,
        enrollmentsCount,
        slotBookingsCount,
        gigBookingsCount,
        ipEventsCount,
        badgesCount,
      ];
      if (dependencyCount.some((count) => count > 0)) {
        throw new AppError(
          "PROFILE_IN_USE",
          "Player profile has linked activity and cannot be deleted",
          409,
        );
      }
      await prisma.playerProfile.delete({ where: { id: profile.id } });
      return { message: "Player profile deleted" };
    }

    if (profileType === "COACH") {
      const profile = user.coachProfile;
      if (!profile) throw Errors.notFound("Coach profile");
      const dependencyCount = await prisma.$transaction([
        prisma.practiceSession.count({ where: { coachId: profile.id } }),
        prisma.academyCoach.count({ where: { coachId: profile.id } }),
        prisma.gigListing.count({ where: { coachId: profile.id } }),
        prisma.drill.count({ where: { createdById: profile.id } }),
      ]);
      if (dependencyCount.some((count) => count > 0)) {
        throw new AppError(
          "PROFILE_IN_USE",
          "Coach profile has linked activity and cannot be deleted",
          409,
        );
      }
      await prisma.coachProfile.delete({ where: { id: profile.id } });
      return { message: "Coach profile deleted" };
    }

    if (profileType === "ACADEMY_OWNER") {
      const profile = user.academyOwnerProfile;
      if (!profile) throw Errors.notFound("Academy owner profile");
      const academyCount = await prisma.academy.count({
        where: { ownerId: profile.id },
      });
      if (academyCount > 0) {
        throw new AppError(
          "PROFILE_IN_USE",
          "Academy owner profile has linked academies and cannot be deleted",
          409,
        );
      }
      await prisma.academyOwnerProfile.delete({ where: { id: profile.id } });
      return { message: "Academy owner profile deleted" };
    }

    const profile = user.arenaOwnerProfile;
    if (!profile) throw Errors.notFound("Arena owner profile");
    const arenaCount = await prisma.arena.count({
      where: { ownerId: profile.id },
    });
    if (arenaCount > 0) {
      throw new AppError(
        "PROFILE_IN_USE",
        "Arena owner profile has linked arenas and cannot be deleted",
        409,
      );
    }
    await prisma.arenaOwnerProfile.delete({ where: { id: profile.id } });
    return { message: "Arena owner profile deleted" };
  }

  async blockUser(adminId: string, targetUserId: string, reason: string) {
    await this.verifyAdmin(adminId);
    const user = await prisma.user.findUnique({ where: { id: targetUserId } });
    if (!user) throw Errors.notFound("User");

    await prisma.user.update({
      where: { id: targetUserId },
      data: { isBlocked: true, blockedReason: reason },
    });
    await notificationSvc.createNotification(targetUserId, {
      type: "SYSTEM",
      title: "Account Suspended",
      body: `Your account has been suspended. Reason: ${reason}`,
      sendPush: true,
    });
    return { message: "User blocked" };
  }

  async unblockUser(adminId: string, targetUserId: string) {
    await this.verifyAdmin(adminId);
    await prisma.user.update({
      where: { id: targetUserId },
      data: { isBlocked: false, blockedReason: null },
    });
    return { message: "User unblocked" };
  }

  async grantRole(adminId: string, targetUserId: string, role: string) {
    await this.verifyAdmin(adminId);
    const user = await prisma.user.findUnique({ where: { id: targetUserId } });
    if (!user) throw Errors.notFound("User");
    if (user.roles.includes(role as any))
      return { message: "Role already granted" };

    await prisma.user.update({
      where: { id: targetUserId },
      data: { roles: { push: role as any } },
    });
    return { message: `Role ${role} granted` };
  }

  async revokeRole(adminId: string, targetUserId: string, role: string) {
    await this.verifyAdmin(adminId);
    const user = await prisma.user.findUnique({ where: { id: targetUserId } });
    if (!user) throw Errors.notFound("User");

    await prisma.user.update({
      where: { id: targetUserId },
      data: { roles: { set: user.roles.filter((r) => r !== role) as any[] } },
    });
    return { message: `Role ${role} revoked` };
  }

  async listMatches(
    adminId: string,
    filters: {
      status?: string;
      matchType?: string;
      search?: string;
      page: number;
      limit: number;
    },
  ) {
    await this.verifyAdmin(adminId);
    const where: any = {};
    if (filters.status) where.status = filters.status;
    if (filters.matchType) where.matchType = filters.matchType;
    if (filters.search) {
      where.OR = [
        { teamAName: { contains: filters.search, mode: "insensitive" } },
        { teamBName: { contains: filters.search, mode: "insensitive" } },
        { venueName: { contains: filters.search, mode: "insensitive" } },
        { round: { contains: filters.search, mode: "insensitive" } },
        { id: { contains: filters.search, mode: "insensitive" } },
      ];
    }

    const [matches, total] = await prisma.$transaction([
      prisma.match.findMany({
        where,
        include: {
          overlayPack: {
            select: {
              id: true,
              code: true,
              name: true,
              kind: true,
              isDefault: true,
            },
          },
          innings: {
            select: {
              inningsNumber: true,
              totalRuns: true,
              totalWickets: true,
              isCompleted: true,
            },
          },
        },
        orderBy: [{ scheduledAt: "asc" }, { createdAt: "asc" }],
        skip: (filters.page - 1) * filters.limit,
        take: filters.limit,
      }),
      prisma.match.count({ where }),
    ]);

    return { matches, total, page: filters.page, limit: filters.limit };
  }

  async verifyMatch(adminId: string, matchId: string, level: string) {
    await this.verifyAdmin(adminId);
    const match = await prisma.match.findUnique({ where: { id: matchId } });
    if (!match) throw Errors.notFound("Match");
    const updated = await prisma.match.update({
      where: { id: matchId },
      data: { verificationLevel: level as any, verifiedAt: new Date() },
    });
    await performanceSvc.processVerifiedMatch(matchId);
    return updated;
  }

  async getPayments(
    adminId: string,
    filters: { status?: string; page: number; limit: number },
  ) {
    await this.verifyAdmin(adminId);
    const where: any = {};
    if (filters.status) where.status = filters.status;

    const [payments, total, totalRevenue] = await prisma.$transaction([
      prisma.payment.findMany({
        where,
        include: { user: { select: { name: true, phone: true } } },
        orderBy: { createdAt: "desc" },
        skip: (filters.page - 1) * filters.limit,
        take: filters.limit,
      }),
      prisma.payment.count({ where }),
      prisma.payment.aggregate({
        where: { status: "COMPLETED" },
        _sum: { amountPaise: true },
      }),
    ]);

    return {
      payments,
      total,
      totalRevenuePaise: totalRevenue._sum.amountPaise || 0,
      page: filters.page,
      limit: filters.limit,
    };
  }

  async broadcastNotification(
    adminId: string,
    data: { title: string; body: string; userIds?: string[]; roles?: string[] },
  ) {
    await this.verifyAdmin(adminId);

    let targetUserIds: string[] = [];
    if (data.userIds && data.userIds.length > 0) {
      targetUserIds = data.userIds;
    } else if (data.roles && data.roles.length > 0) {
      const users = await prisma.user.findMany({
        where: { roles: { hasSome: data.roles as any[] } },
        select: { id: true },
      });
      targetUserIds = users.map((u) => u.id);
    } else {
      const users = await prisma.user.findMany({
        select: { id: true },
        take: 10000,
      });
      targetUserIds = users.map((u) => u.id);
    }

    return notificationSvc.broadcastToUsers(targetUserIds, {
      type: "SYSTEM",
      title: data.title,
      body: data.body,
    });
  }

  async getAcademies(
    adminId: string,
    filters: {
      page: number;
      limit: number;
      search?: string;
      verified?: "VERIFIED" | "UNVERIFIED";
    },
  ) {
    await this.verifyAdmin(adminId);
    const where: any = {};
    if (filters.search) {
      where.OR = [
        { name: { contains: filters.search, mode: "insensitive" } },
        { city: { contains: filters.search, mode: "insensitive" } },
        {
          owner: {
            is: {
              user: {
                is: {
                  OR: [
                    { name: { contains: filters.search, mode: "insensitive" } },
                    { phone: { contains: filters.search } },
                  ],
                },
              },
            },
          },
        },
      ];
    }
    if (filters.verified === "VERIFIED") {
      where.isVerified = true;
    }
    if (filters.verified === "UNVERIFIED") {
      where.isVerified = false;
    }
    const [academies, total] = await prisma.$transaction([
      prisma.academy.findMany({
        where,
        include: {
          owner: {
            include: {
              user: { select: { id: true, name: true, phone: true } },
            },
          },
        },
        orderBy: { createdAt: "desc" },
        skip: (filters.page - 1) * filters.limit,
        take: filters.limit,
      }),
      prisma.academy.count({ where }),
    ]);
    return { academies, total, page: filters.page, limit: filters.limit };
  }

  async verifyAcademy(adminId: string, academyId: string, isVerified: boolean) {
    await this.verifyAdmin(adminId);
    const academy = await prisma.academy.findUnique({
      where: { id: academyId },
    });
    if (!academy) throw Errors.notFound("Academy");

    return prisma.academy.update({
      where: { id: academyId },
      data: {
        isVerified,
        verifiedAt: isVerified ? new Date() : null,
      },
    });
  }

  async verifyArena(adminId: string, arenaId: string, arenaGrade: string) {
    await this.verifyAdmin(adminId);
    const arena = await prisma.arena.findUnique({ where: { id: arenaId } });
    if (!arena) throw Errors.notFound("Arena");

    return prisma.arena.update({
      where: { id: arenaId },
      data: {
        isVerified: true,
        verifiedAt: new Date(),
        arenaGrade,
      },
    });
  }

  async updateArena(adminId: string, arenaId: string, data: Record<string, any>) {
    await this.verifyAdmin(adminId);
    const allowed: Record<string, any> = {};
    const fields = [
      "name",
      "description",
      "phone",
      "address",
      "city",
      "state",
      "pincode",
      "latitude",
      "longitude",
      "photoUrls",
      "sports",
      "hasParking",
      "hasLights",
      "hasWashrooms",
      "hasCanteen",
      "hasCCTV",
      "hasScorer",
      "openTime",
      "closeTime",
      "operatingDays",
      "advanceBookingDays",
      "bufferMins",
      "cancellationHours",
      "isActive",
    ];
    for (const field of fields) {
      if (field in data) allowed[field] = data[field];
    }
    return prisma.arena.update({ where: { id: arenaId }, data: allowed });
  }

  async toggleSwingArena(adminId: string, arenaId: string) {
    await this.verifyAdmin(adminId);
    const arena = await prisma.arena.findUnique({ where: { id: arenaId } });
    if (!arena) throw Errors.notFound("Arena");

    return prisma.arena.update({
      where: { id: arenaId },
      data: { isSwingArena: !arena.isSwingArena },
    });
  }

  async updateArenaUnit(adminId: string, unitId: string, data: Record<string, any>) {
    await this.verifyAdmin(adminId);
    const allowed: Record<string, any> = {};
    const fields = [
      "name",
      "description",
      "unitType",
      "photoUrls",
      "pricePerHourPaise",
      "peakPricePaise",
      "peakHoursStart",
      "peakHoursEnd",
      "price4HrPaise",
      "price8HrPaise",
      "priceFullDayPaise",
      "weekendMultiplier",
      "minSlotMins",
      "maxSlotMins",
      "slotIncrementMins",
      "boundarySize",
      "isActive",
    ];
    for (const field of fields) {
      if (field in data) allowed[field] = data[field];
    }
    if ("boundarySize" in allowed && allowed.boundarySize !== null) {
      allowed.boundarySize = Number(allowed.boundarySize);
    }
    return prisma.arenaUnit.update({ where: { id: unitId }, data: allowed });
  }

  async deleteArenaUnit(adminId: string, unitId: string) {
    await this.verifyAdmin(adminId);
    return prisma.arenaUnit.update({
      where: { id: unitId },
      data: { isActive: false },
    });
  }

  async hardDeleteArena(adminId: string, arenaId: string) {
    await this.verifyAdmin(adminId);
    const arena = await prisma.arena.findUnique({
      where: { id: arenaId },
      include: {
        bookings: {
          where: {
            status: { in: ["CONFIRMED", "CHECKED_IN", "PENDING_PAYMENT"] },
            date: { gte: new Date() },
          },
          take: 1,
        },
      },
    });

    if (!arena) throw Errors.notFound("Arena");

    if (arena.bookings.length > 0) {
      throw new AppError(
        "ACTIVE_BOOKINGS_EXIST",
        "Arena cannot be deleted as it has active or upcoming confirmed bookings",
        400,
      );
    }

    return prisma.$transaction(async (tx) => {
      // 1. Delete relations that might block deletion
      await tx.arenaTimeBlock.deleteMany({ where: { arenaId } });
      await tx.arenaManager.deleteMany({ where: { arenaId } });
      await tx.arenaAddon.deleteMany({ where: { arenaId } });
      await tx.slotBookingAddon.deleteMany({
        where: { booking: { arenaId } },
      });
      await tx.slotBooking.deleteMany({ where: { arenaId } });
      await tx.review.deleteMany({ where: { arenaId } });
      await tx.pricingRule.deleteMany({
        where: { unit: { arenaId } },
      });
      await tx.arenaUnit.deleteMany({ where: { arenaId } });

      // 2. Finally delete the Arena
      return tx.arena.delete({ where: { id: arenaId } });
    });
  }

  async getRevenueAnalytics(
    adminId: string,
    filters: { from: string; to: string; groupBy: "day" | "week" | "month" },
  ) {
    await this.verifyAdmin(adminId);
    const groupBy = ["day", "week", "month"].includes(filters.groupBy)
      ? filters.groupBy
      : "day";
    const from = new Date(filters.from);
    const to = new Date(filters.to);

    const series = await prisma.$queryRawUnsafe<
      Array<{
        period: Date;
        revenueSlot: bigint | number | null;
        revenueGig: bigint | number | null;
        revenueFee: bigint | number | null;
        revenueTotal: bigint | number | null;
      }>
    >(
      `
        SELECT
          DATE_TRUNC('${groupBy}', "createdAt") AS period,
          SUM(CASE WHEN "entityType" = 'SLOT_BOOKING' THEN "amountPaise" ELSE 0 END) AS "revenueSlot",
          SUM(CASE WHEN "entityType" = 'GIG_BOOKING' THEN "amountPaise" ELSE 0 END) AS "revenueGig",
          SUM(CASE WHEN "entityType" = 'ACADEMY_FEE' THEN "amountPaise" ELSE 0 END) AS "revenueFee",
          SUM("amountPaise") AS "revenueTotal"
        FROM "Payment"
        WHERE status = 'COMPLETED'
          AND "createdAt" BETWEEN $1 AND $2
        GROUP BY period
        ORDER BY period ASC
      `,
      from,
      to,
    );

    const normalizedSeries = series.map((item) => ({
      period: item.period,
      revenueSlot: Number(item.revenueSlot || 0),
      revenueGig: Number(item.revenueGig || 0),
      revenueFee: Number(item.revenueFee || 0),
      revenueTotal: Number(item.revenueTotal || 0),
    }));

    const totals = normalizedSeries.reduce(
      (acc, item) => ({
        revenueSlot: acc.revenueSlot + item.revenueSlot,
        revenueGig: acc.revenueGig + item.revenueGig,
        revenueFee: acc.revenueFee + item.revenueFee,
        revenueTotal: acc.revenueTotal + item.revenueTotal,
      }),
      { revenueSlot: 0, revenueGig: 0, revenueFee: 0, revenueTotal: 0 },
    );

    return { series: normalizedSeries, totals };
  }

  async getConfigs(adminId: string) {
    await this.verifyAdmin(adminId);
    return prisma.platformConfig.findMany({ orderBy: { key: "asc" } });
  }

  async updateConfig(adminId: string, key: string, value: string) {
    await this.verifyAdmin(adminId);
    const config = await prisma.platformConfig.upsert({
      where: { key },
      update: { value, updatedBy: adminId },
      create: { key, value, updatedBy: adminId },
    });

    await prisma.auditLog.create({
      data: {
        actorId: adminId,
        actorRole: "SWING_ADMIN",
        action: "CONFIG_UPDATE",
        entityType: "PlatformConfig",
        entityId: key,
        after: { value },
      },
    });

    return config;
  }

  async getAuditLogs(
    adminId: string,
    filters: {
      actorId?: string;
      entityType?: string;
      page: number;
      limit: number;
    },
  ) {
    await this.verifyAdmin(adminId);
    const where: any = {};
    if (filters.actorId) where.actorId = filters.actorId;
    if (filters.entityType) where.entityType = filters.entityType;

    const [logs, total] = await Promise.all([
      prisma.auditLog.findMany({
        where,
        orderBy: { createdAt: "desc" },
        skip: (filters.page - 1) * filters.limit,
        take: filters.limit,
      }),
      prisma.auditLog.count({ where }),
    ]);

    return {
      logs,
      total,
      page: filters.page,
      pages: Math.ceil(total / filters.limit),
    };
  }

  async listSupportTickets(
    adminId: string,
    filters: {
      status?: string;
      priority?: string;
      category?: string;
      page: number;
      limit: number;
    },
  ) {
    await this.verifyAdmin(adminId);
    const where: any = {};
    if (filters.status) where.status = filters.status;
    if (filters.priority) where.priority = filters.priority;
    if (filters.category) where.category = filters.category;

    const [tickets, total] = await Promise.all([
      prisma.supportTicket.findMany({
        where,
        include: { user: { select: { name: true, phone: true } } },
        orderBy: { createdAt: "desc" },
        skip: (filters.page - 1) * filters.limit,
        take: filters.limit,
      }),
      prisma.supportTicket.count({ where }),
    ]);

    return { tickets, total, page: filters.page };
  }

  async getSupportTicket(adminId: string, ticketId: string) {
    await this.verifyAdmin(adminId);
    const ticket = await prisma.supportTicket.findUnique({
      where: { id: ticketId },
      include: {
        user: { select: { name: true, phone: true } },
        messages: { orderBy: { createdAt: "asc" } },
      },
    });
    if (!ticket) throw Errors.notFound("Support ticket");
    const { messages, ...ticketData } = ticket;
    return { ticket: ticketData, messages };
  }

  async addSupportMessage(adminId: string, ticketId: string, message: string) {
    await this.verifyAdmin(adminId);
    const ticket = await prisma.supportTicket.findUnique({
      where: { id: ticketId },
    });
    if (!ticket) throw Errors.notFound("Support ticket");

    return prisma.ticketMessage.create({
      data: {
        ticketId,
        authorId: adminId,
        isFromSupport: true,
        message,
      },
    });
  }

  async assignSupportTicket(
    adminId: string,
    ticketId: string,
    agentId: string,
  ) {
    await this.verifyAdmin(adminId);
    return prisma.supportTicket.update({
      where: { id: ticketId },
      data: {
        assignedTo: agentId,
        status: "IN_PROGRESS",
      },
    });
  }

  async resolveSupportTicket(
    adminId: string,
    ticketId: string,
    resolution: string,
  ) {
    await this.verifyAdmin(adminId);
    return prisma.supportTicket.update({
      where: { id: ticketId },
      data: {
        status: "RESOLVED",
        resolution,
        resolvedAt: new Date(),
      },
    });
  }

  async closeSupportTicket(adminId: string, ticketId: string) {
    await this.verifyAdmin(adminId);
    return prisma.supportTicket.update({
      where: { id: ticketId },
      data: { status: "CLOSED" },
    });
  }

  // ── Arenas ──────────────────────────────────────────────────────────
  async listArenas(
    adminId: string,
    filters: { search?: string; city?: string; page: number; limit: number },
  ) {
    await this.verifyAdmin(adminId);
    const where: any = {};
    if (filters.city)
      where.city = { contains: filters.city, mode: "insensitive" };
    if (filters.search)
      where.OR = [
        { name: { contains: filters.search, mode: "insensitive" } },
        { city: { contains: filters.search, mode: "insensitive" } },
      ];
    const [arenas, total] = await prisma.$transaction([
      prisma.arena.findMany({
        where,
        include: {
          owner: { include: { user: { select: { name: true, phone: true } } } },
        },
        orderBy: { createdAt: "desc" },
        skip: (filters.page - 1) * filters.limit,
        take: filters.limit,
      }),
      prisma.arena.count({ where }),
    ]);
    return { arenas, total, page: filters.page, limit: filters.limit };
  }

  // ── Coaches ──────────────────────────────────────────────────────────
  async listCoaches(
    adminId: string,
    filters: {
      search?: string;
      verified?: "VERIFIED" | "UNVERIFIED";
      page: number;
      limit: number;
    },
  ) {
    await this.verifyAdmin(adminId);
    const where: any = {};
    if (filters.search) {
      where.user = {
        is: {
          OR: [
            { name: { contains: filters.search, mode: "insensitive" } },
            { phone: { contains: filters.search } },
          ],
        },
      };
    }
    if (filters.verified === "VERIFIED") {
      where.isVerified = true;
    }
    if (filters.verified === "UNVERIFIED") {
      where.isVerified = false;
    }
    const [coaches, total] = await prisma.$transaction([
      prisma.coachProfile.findMany({
        where,
        include: {
          user: {
            select: { id: true, name: true, phone: true, avatarUrl: true },
          },
        },
        orderBy: { createdAt: "desc" },
        skip: (filters.page - 1) * filters.limit,
        take: filters.limit,
      }),
      prisma.coachProfile.count({ where }),
    ]);
    return { coaches, total, page: filters.page, limit: filters.limit };
  }

  async verifyCoach(adminId: string, coachId: string, isVerified: boolean) {
    await this.verifyAdmin(adminId);
    const coach = await prisma.coachProfile.findUnique({
      where: { id: coachId },
    });
    if (!coach) throw Errors.notFound("Coach");
    return prisma.coachProfile.update({
      where: { id: coachId },
      data: { isVerified, verifiedAt: isVerified ? new Date() : null },
    });
  }

  async updateCoachProfile(adminId: string, coachId: string, data: any) {
    await this.verifyAdmin(adminId);
    const coach = await prisma.coachProfile.findUnique({
      where: { id: coachId },
    });
    if (!coach) throw Errors.notFound("Coach");
    return prisma.coachProfile.update({ where: { id: coachId }, data });
  }

  async updateArenaOwnerProfile(
    adminId: string,
    arenaOwnerId: string,
    data: any,
  ) {
    await this.verifyAdmin(adminId);
    const owner = await prisma.arenaOwnerProfile.findUnique({
      where: { id: arenaOwnerId },
    });
    if (!owner) throw Errors.notFound("Arena owner profile");
    return prisma.arenaOwnerProfile.update({
      where: { id: arenaOwnerId },
      data,
    });
  }

  // ── Players ──────────────────────────────────────────────────────────
  async updatePlayerProfile(
    adminId: string,
    playerProfileId: string,
    data: any,
  ) {
    await this.verifyAdmin(adminId);
    const profile = await prisma.playerProfile.findUnique({
      where: { id: playerProfileId },
    });
    if (!profile) throw Errors.notFound("Player profile");
    const { dateOfBirth, ...rest } = data;
    return prisma.playerProfile.update({
      where: { id: playerProfileId },
      data: {
        ...rest,
        ...(dateOfBirth ? { dateOfBirth: new Date(dateOfBirth) } : {}),
      },
    });
  }

  async updatePlayerCompetitiveProfile(
    adminId: string,
    playerProfileId: string,
    data: {
      lifetimeImpactPoints?: number;
      currentRankKey?: string;
      currentDivision?: number;
      rankProgressPoints?: number;
      currentDivisionFloor?: number;
      winStreak?: number;
      mvpCount?: number;
      hasPremiumPass?: boolean;
      premiumPassExpiresAt?: string | null;
      lastRankedMatchAt?: string | null;
    },
  ) {
    await this.verifyAdmin(adminId);

    const profile = await prisma.playerProfile.findUnique({
      where: { id: playerProfileId },
      select: { id: true, user: { select: { name: true } } },
    });
    if (!profile) throw Errors.notFound("Player profile");

    const current = await getIpPlayerState(playerProfileId);
    const nextLifetimeIp = data.lifetimeImpactPoints ?? current?.lifetimeIp ?? 0;
    const nextRankKey = data.currentRankKey ?? current?.currentRankKey ?? "ROOKIE";
    const nextDivision = data.currentDivision ?? current?.currentDivision ?? 3;
    const nextRankProgress =
      data.rankProgressPoints ?? current?.rankProgressPoints ?? 0;
    const nextDivisionFloor =
      data.currentDivisionFloor ?? current?.currentDivisionFloor ?? 0;
    const nextWinStreak = data.winStreak ?? current?.winStreak ?? 0;
    const nextMvpCount = data.mvpCount ?? current?.mvpCount ?? 0;
    const nextLastRankedMatchAt =
      data.lastRankedMatchAt !== undefined
        ? data.lastRankedMatchAt
          ? new Date(data.lastRankedMatchAt)
          : null
        : current?.lastRankedMatchAt ?? null;

    await upsertIpPlayerState({
      playerId: playerProfileId,
      lifetimeIp: nextLifetimeIp,
      currentRankKey: nextRankKey,
      currentDivision: nextDivision,
      rankProgressPoints: nextRankProgress,
      currentDivisionFloor: nextDivisionFloor,
      winStreak: nextWinStreak,
      mvpCount: nextMvpCount,
      lastRankedMatchAt: nextLastRankedMatchAt,
      currentSeasonId: current?.currentSeasonId ?? null,
    });

    const updated = await getIpPlayerState(playerProfileId);
    return {
      playerId: playerProfileId,
      playerName: profile.user?.name ?? null,
      lifetimeImpactPoints: updated?.lifetimeIp ?? nextLifetimeIp,
      currentRankKey: updated?.currentRankKey ?? nextRankKey,
      currentDivision: updated?.currentDivision ?? nextDivision,
      rankProgressPoints: updated?.rankProgressPoints ?? nextRankProgress,
      currentDivisionFloor: updated?.currentDivisionFloor ?? nextDivisionFloor,
      winStreak: updated?.winStreak ?? nextWinStreak,
      mvpCount: updated?.mvpCount ?? nextMvpCount,
      // Premium pass is sourced from subscriptions now; no direct write in competitive state.
      hasPremiumPass: data.hasPremiumPass ?? null,
      premiumPassExpiresAt: data.premiumPassExpiresAt ?? null,
      lastRankedMatchAt: updated?.lastRankedMatchAt ?? nextLastRankedMatchAt,
    };
  }

  async rebuildPlayerIp(adminId: string, playerId: string) {
    await this.verifyAdmin(adminId);

    const player = await prisma.playerProfile.findUnique({
      where: { id: playerId },
      select: { id: true, user: { select: { name: true } } },
    });
    if (!player) throw Errors.notFound("Player profile");

    const matches = await prisma.match.findMany({
      where: {
        status: "COMPLETED",
        OR: [
          { teamAPlayerIds: { has: playerId } },
          { teamBPlayerIds: { has: playerId } },
        ],
      },
      select: { id: true },
      orderBy: [{ completedAt: "asc" }, { scheduledAt: "asc" }],
    });

    await performanceSvc.rebuildPlayersFromCurrentFacts([playerId]);
    const finalProfile = await getIpPlayerState(playerId);

    return {
      matchesProcessed: matches.length,
      finalIp: finalProfile?.lifetimeIp ?? 0,
      finalRank: finalProfile?.currentRankKey ?? "ROOKIE",
      finalDivision: finalProfile?.currentDivision ?? 3,
    };
  }

  // ── Tournaments ──────────────────────────────────────────────────────
  private async getTournamentColumnSupport() {
    if (!this.tournamentColumnSupportPromise) {
      this.tournamentColumnSupportPromise = prisma.$queryRaw<
        Array<{ column_name: string }>
      >`
          SELECT column_name
          FROM information_schema.columns
          WHERE table_schema = 'public'
            AND table_name = 'Tournament'
            AND column_name IN ('seriesMatchCount')
        `
        .then((rows) => {
          const columns = new Set(rows.map((row) => row.column_name));
          return { seriesMatchCount: columns.has("seriesMatchCount") };
        })
        .catch(() => ({ seriesMatchCount: false }));
    }

    return this.tournamentColumnSupportPromise;
  }

  private buildTournamentBaseSelect(columnSupport: {
    seriesMatchCount: boolean;
  }) {
    return {
      id: true,
      academyId: true,
      overlayPackId: true,
      name: true,
      description: true,
      format: true,
      sport: true,
      startDate: true,
      endDate: true,
      venueName: true,
      city: true,
      maxTeams: true,
      entryFee: true,
      prizePool: true,
      rules: true,
      logoUrl: true,
      coverUrl: true,
      slug: true,
      highlights: true,
      isPublic: true,
      isVerified: true,
      status: true,
      tournamentFormat: true,
      groupCount: true,
      pointsForWin: true,
      pointsForLoss: true,
      pointsForTie: true,
      pointsForNoResult: true,
      createdAt: true,
      overlayPack: {
        select: {
          id: true,
          code: true,
          name: true,
          kind: true,
          isDefault: true,
        },
      },
      ...(columnSupport.seriesMatchCount ? { seriesMatchCount: true } : {}),
    } as any;
  }

  private normalizeTournamentRecord(
    tournament: Record<string, any> | null,
    columnSupport: { seriesMatchCount: boolean },
  ): TournamentCompatRecord | null {
    if (!tournament) return null;
    const sanitizeImage = (value: unknown) => {
      if (typeof value !== "string") return null;
      const trimmed = value.trim();
      if (!trimmed) return null;
      return trimmed.startsWith("data:image/") ? null : trimmed;
    };

    return {
      ...tournament,
      logoUrl: sanitizeImage(tournament.logoUrl),
      coverUrl: sanitizeImage(tournament.coverUrl),
      seriesMatchCount: columnSupport.seriesMatchCount
        ? (tournament.seriesMatchCount ?? null)
        : null,
    } as TournamentCompatRecord;
  }

  async getTournament(adminId: string, tournamentId: string) {
    await this.verifyAdmin(adminId);
    const columnSupport = await this.getTournamentColumnSupport();
    const t = await prisma.tournament.findUnique({
      where: { id: tournamentId },
      select: {
        ...this.buildTournamentBaseSelect(columnSupport),
        teams: { orderBy: { registeredAt: "asc" } },
        groups: { include: { teams: true }, orderBy: { groupOrder: "asc" } },
        academy: { select: { name: true } },
      },
    });
    if (!t) throw Errors.notFound("Tournament");
    return this.normalizeTournamentRecord(
      t as Record<string, any>,
      columnSupport,
    );
  }

  async listTournaments(
    adminId: string,
    filters: { search?: string; status?: string; page: number; limit: number },
  ) {
    await this.verifyAdmin(adminId);
    const columnSupport = await this.getTournamentColumnSupport();
    const where: any = {};
    if (filters.status) where.status = filters.status;
    if (filters.search)
      where.name = { contains: filters.search, mode: "insensitive" };
    const [tournaments, total] = await prisma.$transaction([
      prisma.tournament.findMany({
        where,
        select: {
          ...this.buildTournamentBaseSelect(columnSupport),
          teams: true,
          academy: { select: { name: true } },
        },
        orderBy: { createdAt: "desc" },
        skip: (filters.page - 1) * filters.limit,
        take: filters.limit,
      }),
      prisma.tournament.count({ where }),
    ]);
    return {
      tournaments: tournaments.map((tournament) =>
        this.normalizeTournamentRecord(
          tournament as Record<string, any>,
          columnSupport,
        ),
      ),
      total,
      page: filters.page,
      limit: filters.limit,
    };
  }

  private generateSlug(name: string): string {
    return name
      .toLowerCase()
      .replace(/[^a-z0-9\s-]/g, "")
      .trim()
      .replace(/\s+/g, "-")
      .replace(/-+/g, "-")
      .substring(0, 60);
  }

  private async uniqueSlug(base: string): Promise<string> {
    let slug = base;
    let attempt = 0;
    while (true) {
      const existing = await prisma.tournament.findUnique({ where: { slug } });
      if (!existing) return slug;
      attempt++;
      slug = `${base}-${attempt}`;
    }
  }

  async createTournament(adminId: string, data: any) {
    await this.verifyAdmin(adminId);
    const columnSupport = await this.getTournamentColumnSupport();
    const tournamentFormat = data.tournamentFormat || "LEAGUE";
    const maxTeams = data.maxTeams || 8;
    const isSeries = tournamentFormat === "SERIES";
    const baseSlug = data.slug?.trim()
      ? this.generateSlug(data.slug)
      : this.generateSlug(data.name);
    const slug = await this.uniqueSlug(baseSlug);
    return prisma.tournament.create({
      data: {
        name: data.name,
        description: data.description,
        format: data.format,
        tournamentFormat,
        sport: data.sport || "CRICKET",
        startDate: new Date(data.startDate),
        endDate: data.endDate ? new Date(data.endDate) : null,
        venueName: data.venueName,
        city: data.city,
        maxTeams,
        groupCount: isSeries ? 1 : data.groupCount || 1,
        pointsForWin: data.pointsForWin ?? 2,
        pointsForLoss: data.pointsForLoss ?? 0,
        pointsForTie: data.pointsForTie ?? 1,
        pointsForNoResult: data.pointsForNoResult ?? 1,
        entryFee: data.entryFee,
        prizePool: data.prizePool,
        rules: data.rules,
        logoUrl: data.logoUrl || null,
        coverUrl: data.coverUrl || null,
        highlights: data.highlights || [],
        isPublic: data.isPublic !== false,
        status: "UPCOMING",
        academyId: data.academyId || null,
        overlayPackId: data.overlayPackId || null,
        slug,
        ...(columnSupport.seriesMatchCount
          ? {
              seriesMatchCount: isSeries
                ? (data.seriesMatchCount ?? (maxTeams === 2 ? 3 : 1))
                : null,
            }
          : {}),
      },
    });
  }

  async updateTournament(adminId: string, tournamentId: string, data: any) {
    await this.verifyAdmin(adminId);
    const columnSupport = await this.getTournamentColumnSupport();
    const t = await prisma.tournament.findUnique({
      where: { id: tournamentId },
      select: {
        ...this.buildTournamentBaseSelect(columnSupport),
        teams: { where: { isConfirmed: true } },
      },
    });
    if (!t) throw Errors.notFound("Tournament");
    const currentTournament = t as any;

    const nextTournamentFormat =
      data.tournamentFormat ?? currentTournament.tournamentFormat;
    const nextMaxTeams = data.maxTeams ?? currentTournament.maxTeams;
    const normalizedData = {
      ...data,
      groupCount: nextTournamentFormat === "SERIES" ? 1 : data.groupCount,
      ...(data.overlayPackId !== undefined
        ? { overlayPackId: data.overlayPackId || null }
        : {}),
      ...(columnSupport.seriesMatchCount
        ? {
            seriesMatchCount:
              nextTournamentFormat === "SERIES"
                ? data.seriesMatchCount === null
                  ? null
                  : (data.seriesMatchCount ??
                    currentTournament.seriesMatchCount ??
                    (nextMaxTeams === 2 ? 3 : 1))
                : null,
          }
        : {}),
    };

    const updated = await prisma.tournament.update({
      where: { id: tournamentId },
      data: normalizedData,
    });

    // Auto-generate fixtures when status transitions to ONGOING and no matches exist yet
    if (data.status === "ONGOING" && currentTournament.status !== "ONGOING") {
      const existingMatches = await prisma.match.count({
        where: { tournamentId },
      });
      if (existingMatches === 0 && currentTournament.teams.length >= 2) {
        await this.autoGenerateFixtures(
          adminId,
          tournamentId,
          currentTournament.teams,
          updated,
        );
      }
    }

    return updated;
  }

  private async autoGenerateFixtures(
    adminId: string,
    tournamentId: string,
    teams: any[],
    tournament: any,
  ) {
    const isKnockout =
      tournament.tournamentFormat === "KNOCKOUT" ||
      tournament.tournamentFormat === "DOUBLE_ELIMINATION";
    const isSeries = tournament.tournamentFormat === "SERIES";

    // Calculate total number of fixtures
    const totalMatches = isKnockout
      ? Math.floor(teams.length / 2) // first round only
      : isSeries
        ? teams.length === 2
          ? tournament.seriesMatchCount || 3
          : ((teams.length * (teams.length - 1)) / 2) *
            (tournament.seriesMatchCount || 1)
        : (teams.length * (teams.length - 1)) / 2; // full round-robin

    // Auto-calculate interval: spread evenly between startDate and endDate (or 24h default)
    const startDate = new Date(tournament.startDate);
    const endDate = tournament.endDate ? new Date(tournament.endDate) : null;
    let intervalHours = 24;
    if (endDate && totalMatches > 1) {
      const totalHours =
        (endDate.getTime() - startDate.getTime()) / (1000 * 60 * 60);
      intervalHours = Math.max(2, Math.floor(totalHours / totalMatches));
    }

    if (isKnockout) {
      await this.generateKnockoutSchedule(
        adminId,
        tournamentId,
        startDate.toISOString(),
        intervalHours,
      );
    } else {
      await this.generateLeagueSchedule(
        adminId,
        tournamentId,
        startDate.toISOString(),
        intervalHours,
      );
    }
  }

  async listTournamentTeams(adminId: string, tournamentId: string) {
    await this.verifyAdmin(adminId);
    return prisma.tournamentTeam.findMany({
      where: { tournamentId },
      orderBy: { registeredAt: "asc" },
    });
  }

  async addTournamentTeam(
    adminId: string,
    tournamentId: string,
    data: {
      teamName?: string;
      teamId?: string;
      captainId?: string;
      playerIds: string[];
    },
  ) {
    await this.verifyAdmin(adminId);
    const t = await prisma.tournament.findUnique({
      where: { id: tournamentId },
    });
    if (!t) throw Errors.notFound("Tournament");
    const currentCount = await prisma.tournamentTeam.count({
      where: { tournamentId },
    });
    if (t.maxTeams && currentCount >= t.maxTeams) {
      throw new AppError(
        "TOURNAMENT_FULL",
        `Tournament is full. Maximum ${t.maxTeams} teams allowed.`,
        400,
      );
    }

    let resolvedName = data.teamName;
    let resolvedTeamId = data.teamId || null;

    if (data.teamId) {
      // Link to existing Team record
      const dbTeam = await prisma.team.findUnique({
        where: { id: data.teamId },
      });
      if (!dbTeam) throw Errors.notFound("Team");
      resolvedName = dbTeam.name;
      // Check not already registered
      const existing = await prisma.tournamentTeam.findFirst({
        where: { tournamentId, teamId: data.teamId },
      });
      if (existing)
        throw new AppError(
          "ALREADY_REGISTERED",
          "This team is already registered in the tournament.",
          400,
        );
    } else if (data.teamName) {
      // Create a new Team record in DB automatically
      const newTeam = await prisma.team.create({
        data: {
          name: data.teamName,
          teamType: "FRIENDLY",
          createdByUserId: adminId,
          playerIds: data.playerIds || [],
        },
      });
      resolvedTeamId = newTeam.id;
      resolvedName = newTeam.name;
    } else {
      throw new AppError(
        "MISSING_TEAM",
        "Either teamId or teamName is required.",
        400,
      );
    }

    return prisma.tournamentTeam.create({
      data: {
        tournamentId,
        teamId: resolvedTeamId,
        teamName: resolvedName!,
        captainId: data.captainId || null,
        playerIds: data.playerIds || [],
        isConfirmed: false,
      },
    });
  }

  async removeTournamentTeam(
    adminId: string,
    tournamentId: string,
    tournamentTeamId: string,
  ) {
    await this.verifyAdmin(adminId);
    const team = await prisma.tournamentTeam.findUnique({
      where: { id: tournamentTeamId },
    });
    if (!team || team.tournamentId !== tournamentId)
      throw Errors.notFound("Tournament team");
    await prisma.tournamentStanding.deleteMany({ where: { tournamentTeamId } });
    return prisma.tournamentTeam.delete({ where: { id: tournamentTeamId } });
  }

  async deleteTournament(adminId: string, tournamentId: string) {
    await this.verifyAdmin(adminId);
    const t = await prisma.tournament.findUnique({
      where: { id: tournamentId },
    });
    if (!t) throw Errors.notFound("Tournament");
    // Cascade: standings → teams → groups → matches → tournament
    await prisma.tournamentStanding.deleteMany({ where: { tournamentId } });
    await prisma.tournamentTeam.deleteMany({ where: { tournamentId } });
    await prisma.tournamentGroup.deleteMany({ where: { tournamentId } });
    await prisma.match.deleteMany({ where: { tournamentId } });
    return prisma.tournament.delete({ where: { id: tournamentId } });
  }

  // ── Admin Match Creation ─────────────────────────────────────────────
  async createAdminMatch(adminId: string, data: any) {
    await this.verifyAdmin(adminId);
    // Auto-enrich from tournament: group name → round, tournament venue → venueName
    let resolvedRound: string | null = data.round?.trim() || null;
    let resolvedVenueName: string | null = data.venueName?.trim() || null;
    let resolvedFacilityId: string | null = data.facilityId?.trim() || null;
    let venueId: string | null = null;

    if (resolvedFacilityId) {
      const arena = await prisma.arena.findUnique({
        where: { id: resolvedFacilityId },
        select: { id: true, name: true },
      });
      if (!arena) {
        throw new AppError(
          "INVALID_FACILITY",
          "Selected arena was not found",
          400,
        );
      }
      resolvedFacilityId = arena.id;
      resolvedVenueName = arena.name;
    }

    if (data.tournamentId) {
      const tournament = await prisma.tournament.findUnique({
        where: { id: data.tournamentId },
        select: { venueName: true },
      });

      // Fall back to tournament venue if none provided
      if (!resolvedVenueName && tournament?.venueName) {
        resolvedVenueName = tournament.venueName;
      }

      // Auto-infer group from team assignments
      if (!resolvedRound) {
        const [ttA, ttB] = await Promise.all([
          prisma.tournamentTeam.findFirst({
            where: {
              tournamentId: data.tournamentId,
              teamName: data.teamAName,
            },
            select: { groupId: true, group: { select: { name: true } } },
          }),
          prisma.tournamentTeam.findFirst({
            where: {
              tournamentId: data.tournamentId,
              teamName: data.teamBName,
            },
            select: { groupId: true, group: { select: { name: true } } },
          }),
        ]);

        if (
          ttA?.groupId &&
          ttB?.groupId &&
          ttA.groupId === ttB.groupId &&
          ttA.group?.name
        ) {
          resolvedRound = ttA.group.name;
        }
      }
    }

    const liveCode = await this.generateUniqueMatchLiveCode();
    const livePin = this.generateMatchLivePin();
    const teamAPlayerIds = await this.normalizeTeamPlayerIds(
      data.teamAPlayerIds,
    );
    const teamBPlayerIds = await this.normalizeTeamPlayerIds(
      data.teamBPlayerIds,
    );
    const overlappingPlayerIds = teamAPlayerIds.filter((playerId) =>
      teamBPlayerIds.includes(playerId),
    );

    if (overlappingPlayerIds.length > 0) {
      throw new AppError(
        "INVALID_PLAYING_XI",
        "A player cannot be listed in both teams",
        400,
      );
    }

    return prisma.match.create({
      data: {
        matchType: data.matchType,
        format: data.format,
        teamAName: data.teamAName,
        teamBName: data.teamBName,
        teamAPlayerIds,
        teamBPlayerIds,
        teamACaptainId: data.teamACaptainId
          ? await this.resolvePlayerProfileId(data.teamACaptainId)
          : null,
        teamBCaptainId: data.teamBCaptainId
          ? await this.resolvePlayerProfileId(data.teamBCaptainId)
          : null,
        scheduledAt: new Date(data.scheduledAt),
        venueName: resolvedVenueName,
        venueId,
        facilityId: resolvedFacilityId,
        customOvers: data.customOvers ? Number(data.customOvers) : null,
        testDays: data.testDays ? Number(data.testDays) : null,
        oversPerDay: data.oversPerDay ? Number(data.oversPerDay) : null,
        academyId: data.academyId || null,
        tournamentId: data.tournamentId || null,
        overlayPackId: data.overlayPackId || null,
        round: resolvedRound,
        isRanked: data.matchType === "RANKED",
        status: "SCHEDULED",
        liveCode,
        livePin,
      },
    });
  }

  async updateAdminMatch(
    adminId: string,
    matchId: string,
    data: { scheduledAt?: string; customOvers?: number; swapTeams?: boolean },
  ) {
    await this.verifyAdmin(adminId);

    const match = await prisma.match.findUnique({
      where: { id: matchId },
      select: {
        id: true,
        status: true,
        teamAName: true,
        teamBName: true,
        format: true,
        matchType: true,
        scheduledAt: true,
        customOvers: true,
        venueName: true,
        venueId: true,
        facilityId: true,
        academyId: true,
        tournamentId: true,
        round: true,
        ballType: true,
        startedAt: true,
        completedAt: true,
        testDays: true,
        oversPerDay: true,
        overlayPackId: true,
        liveCode: true,
        livePin: true,
        isRanked: true,
        teamAPlayerIds: true,
        teamBPlayerIds: true,
        teamACaptainId: true,
        teamBCaptainId: true,
        teamAViceCaptainId: true,
        teamBViceCaptainId: true,
        teamAWicketKeeperId: true,
        teamBWicketKeeperId: true,
      },
    });

    if (!match) {
      throw new AppError("MATCH_NOT_FOUND", "Match not found", 404);
    }

    if (!["SCHEDULED", "TOSS_DONE"].includes(match.status)) {
      throw new AppError(
        "INVALID_STATE",
        "Only scheduled matches can be edited",
        400,
      );
    }

    const patch: Prisma.MatchUpdateInput = {};

    if (data.scheduledAt !== undefined) {
      const scheduledAt = new Date(data.scheduledAt);
      if (Number.isNaN(scheduledAt.getTime())) {
        throw new AppError("INVALID_SCHEDULED_AT", "Invalid scheduledAt", 400);
      }
      patch.scheduledAt = scheduledAt;
    }

    if (data.customOvers !== undefined) {
      if (!Number.isInteger(data.customOvers) || data.customOvers <= 0) {
        throw new AppError(
          "INVALID_CUSTOM_OVERS",
          "customOvers must be a positive integer",
          400,
        );
      }
      patch.customOvers = data.customOvers;
    }

    if (data.swapTeams) {
      patch.teamAName = match.teamBName;
      patch.teamBName = match.teamAName;
      patch.teamAPlayerIds = match.teamBPlayerIds as string[];
      patch.teamBPlayerIds = match.teamAPlayerIds as string[];
      patch.teamACaptainId = match.teamBCaptainId;
      patch.teamBCaptainId = match.teamACaptainId;
      patch.teamAViceCaptainId = match.teamBViceCaptainId;
      patch.teamBViceCaptainId = match.teamAViceCaptainId;
      patch.teamAWicketKeeperId = match.teamBWicketKeeperId;
      patch.teamBWicketKeeperId = match.teamAWicketKeeperId;
    }

    if (Object.keys(patch).length === 0) {
      throw new AppError("NOTHING_TO_UPDATE", "Nothing to update", 400);
    }

    return prisma.match.update({
      where: { id: matchId },
      data: patch,
    });
  }

  async searchVenues(adminId: string, q: string) {
    await this.verifyAdmin(adminId);
    return prisma.venue.findMany({
      where: q ? { name: { contains: q, mode: "insensitive" } } : undefined,
      orderBy: { name: "asc" },
      take: 20,
      select: { id: true, name: true, city: true, aliases: true },
    });
  }

  // ── Gigs ──────────────────────────────────────────────────────────────
  async listGigs(
    adminId: string,
    filters: { search?: string; page: number; limit: number },
  ) {
    await this.verifyAdmin(adminId);
    const where: any = {};
    if (filters.search)
      where.title = { contains: filters.search, mode: "insensitive" };
    const [gigs, total] = await prisma.$transaction([
      prisma.gigListing.findMany({
        where,
        include: {
          coach: { include: { user: { select: { name: true, phone: true } } } },
        },
        orderBy: { createdAt: "desc" },
        skip: (filters.page - 1) * filters.limit,
        take: filters.limit,
      }),
      prisma.gigListing.count({ where }),
    ]);
    return { gigs, total, page: filters.page, limit: filters.limit };
  }

  async toggleGigFeatured(adminId: string, gigId: string) {
    await this.verifyAdmin(adminId);
    const gig = await prisma.gigListing.findUnique({ where: { id: gigId } });
    if (!gig) throw Errors.notFound("Gig");
    return prisma.gigListing.update({
      where: { id: gigId },
      data: { isFeatured: !gig.isFeatured },
    });
  }

  // ── Team Management ──────────────────────────────────────────────────
  private async getTeamColumnSupport() {
    if (!this.teamColumnSupportPromise) {
      this.teamColumnSupportPromise = prisma.$queryRaw<
        Array<{ column_name: string }>
      >`
          SELECT column_name
          FROM information_schema.columns
          WHERE table_schema = 'public'
            AND table_name = 'Team'
            AND column_name IN ('viceCaptainId', 'wicketKeeperId', 'supportStaff')
        `
        .then((rows) => {
          const columns = new Set(rows.map((row) => row.column_name));
          return {
            viceCaptainId: columns.has("viceCaptainId"),
            wicketKeeperId: columns.has("wicketKeeperId"),
            supportStaff: columns.has("supportStaff"),
          };
        })
        .catch(() => ({
          viceCaptainId: false,
          wicketKeeperId: false,
          supportStaff: false,
        }));
    }

    return this.teamColumnSupportPromise;
  }

  private buildTeamSelect(columnSupport: {
    viceCaptainId: boolean;
    wicketKeeperId: boolean;
    supportStaff: boolean;
  }) {
    return {
      id: true,
      name: true,
      shortName: true,
      logoUrl: true,
      city: true,
      teamType: true,
      captainId: true,
      playerIds: true,
      createdByUserId: true,
      isActive: true,
      createdAt: true,
      updatedAt: true,
      ...(columnSupport.viceCaptainId ? { viceCaptainId: true } : {}),
      ...(columnSupport.wicketKeeperId ? { wicketKeeperId: true } : {}),
      ...(columnSupport.supportStaff ? { supportStaff: true } : {}),
    } as any;
  }

  private normalizeTeamRecord(
    team: Record<string, any> | null,
    columnSupport: {
      viceCaptainId: boolean;
      wicketKeeperId: boolean;
      supportStaff: boolean;
    },
  ): TeamCompatRecord | null {
    if (!team) return null;
    return {
      ...team,
      viceCaptainId: columnSupport.viceCaptainId
        ? (team.viceCaptainId ?? null)
        : null,
      wicketKeeperId: columnSupport.wicketKeeperId
        ? (team.wicketKeeperId ?? null)
        : null,
      supportStaff: columnSupport.supportStaff
        ? (team.supportStaff ?? null)
        : null,
    } as TeamCompatRecord;
  }

  private async findTeamById(teamId: string) {
    const columnSupport = await this.getTeamColumnSupport();
    const team = await prisma.team.findUnique({
      where: { id: teamId },
      select: this.buildTeamSelect(columnSupport),
    });
    return this.normalizeTeamRecord(
      team as Record<string, any> | null,
      columnSupport,
    );
  }

  private async resolvePlayerProfileId(playerIdOrUserId: string) {
    const profile = await prisma.playerProfile.findFirst({
      where: {
        OR: [{ id: playerIdOrUserId }, { userId: playerIdOrUserId }],
      },
      select: { id: true, userId: true },
    });
    if (!profile) throw Errors.notFound("Player");
    return profile.id;
  }

  private async normalizeTeamPlayerIds(playerIds?: string[]) {
    if (!playerIds?.length) return [];
    const resolved = await Promise.all(
      playerIds.map((playerId) => this.resolvePlayerProfileId(playerId)),
    );
    return Array.from(new Set(resolved));
  }

  private async assertUniqueTeamPlayerPhones(playerIds: string[]) {
    if (playerIds.length <= 1) return;

    const players = await prisma.playerProfile.findMany({
      where: { id: { in: playerIds } },
      select: {
        id: true,
        user: {
          select: {
            id: true,
            name: true,
            phone: true,
          },
        },
      },
    });

    const seen = new Map<string, { playerId: string; name: string }>();
    for (const player of players) {
      const phone = player.user.phone?.trim();
      if (!phone) continue;

      const playerName = player.user.name || "Player";
      const existing = seen.get(phone);
      if (existing && existing.playerId !== player.id) {
        throw new AppError(
          "TEAM_DUPLICATE_PLAYER_PHONE",
          `Two players in the same team cannot use the same mobile number (${phone}).`,
          409,
        );
      }

      seen.set(phone, { playerId: player.id, name: playerName });
    }
  }

  async listTeams(
    adminId: string,
    filters: { search?: string; city?: string; page: number; limit: number },
  ) {
    await this.verifyAdmin(adminId);
    const columnSupport = await this.getTeamColumnSupport();
    const where: any = {};
    if (filters.city)
      where.city = { contains: filters.city, mode: "insensitive" };
    if (filters.search)
      where.name = { contains: filters.search, mode: "insensitive" };
    const [teams, total] = await prisma.$transaction([
      prisma.team.findMany({
        where,
        select: this.buildTeamSelect(columnSupport),
        orderBy: { createdAt: "desc" },
        skip: (filters.page - 1) * filters.limit,
        take: filters.limit,
      }),
      prisma.team.count({ where }),
    ]);
    return {
      teams: teams.map((team) =>
        this.normalizeTeamRecord(team as Record<string, any>, columnSupport),
      ),
      total,
      page: filters.page,
      limit: filters.limit,
    };
  }

  async getTeam(adminId: string, teamId: string) {
    await this.verifyAdmin(adminId);
    const team = await this.findTeamById(teamId);
    if (!team) throw Errors.notFound("Team");

    const supportStaff = Array.isArray(team.supportStaff)
      ? (team.supportStaff as any[])
      : [];
    const linkedUserIds = Array.from(
      new Set(
        supportStaff
          .map((item) =>
            item && typeof item.userId === "string" ? item.userId : null,
          )
          .filter(Boolean),
      ),
    ) as string[];

    const [players, linkedUsers, tournamentEntries, recentMatches] =
      await Promise.all([
        team.playerIds.length > 0
          ? prisma.playerProfile.findMany({
              where: { id: { in: team.playerIds } },
              include: {
                user: {
                  select: {
                    id: true,
                    name: true,
                    avatarUrl: true,
                    phone: true,
                  },
                },
              },
            })
          : [],
        linkedUserIds.length
          ? prisma.user.findMany({
              where: { id: { in: linkedUserIds } },
              select: { id: true, name: true, phone: true, avatarUrl: true },
            })
          : [],
        prisma.tournamentTeam.findMany({
          where: { teamId: team.id },
          include: {
            tournament: {
              select: {
                id: true,
                name: true,
                status: true,
                format: true,
                startDate: true,
                endDate: true,
                city: true,
                venueName: true,
              },
            },
            group: { select: { id: true, name: true } },
            standing: {
              select: {
                position: true,
                played: true,
                won: true,
                lost: true,
                points: true,
                nrr: true,
              },
            },
          },
          orderBy: { registeredAt: "desc" },
        }),
        prisma.match.findMany({
          where: {
            OR: [{ teamAName: team.name }, { teamBName: team.name }],
          },
          include: {
            innings: {
              select: {
                inningsNumber: true,
                totalRuns: true,
                totalWickets: true,
                isCompleted: true,
              },
            },
          },
          orderBy: { createdAt: "desc" },
          take: 20,
        }),
      ]);

    const playerMap = new Map(players.map((player) => [player.id, player]));
    const userMap = new Map(linkedUsers.map((user) => [user.id, user]));

    return {
      ...team,
      players,
      roleAssignments: {
        captain: team.captainId ? playerMap.get(team.captainId) || null : null,
        viceCaptain: team.viceCaptainId
          ? playerMap.get(team.viceCaptainId) || null
          : null,
        wicketKeeper: team.wicketKeeperId
          ? playerMap.get(team.wicketKeeperId) || null
          : null,
      },
      supportStaffResolved: supportStaff.map((item) => ({
        ...item,
        user: item?.userId ? userMap.get(item.userId) || null : null,
      })),
      tournamentEntries,
      recentMatches,
    };
  }

  async createTeam(adminId: string, data: any) {
    await this.verifyAdmin(adminId);
    const columnSupport = await this.getTeamColumnSupport();
    const playerIds = await this.normalizeTeamPlayerIds(data.playerIds);
    const captainId = data.captainId
      ? await this.resolvePlayerProfileId(data.captainId)
      : null;
    const viceCaptainId =
      columnSupport.viceCaptainId && data.viceCaptainId
        ? await this.resolvePlayerProfileId(data.viceCaptainId)
        : null;
    const wicketKeeperId =
      columnSupport.wicketKeeperId && data.wicketKeeperId
        ? await this.resolvePlayerProfileId(data.wicketKeeperId)
        : null;

    const finalPlayerIds = Array.from(
      new Set(
        [captainId, viceCaptainId, wicketKeeperId, ...playerIds].filter(
          Boolean,
        ),
      ),
    ) as string[];
    await this.assertUniqueTeamPlayerPhones(finalPlayerIds);

    const created = (await prisma.team.create({
      data: {
        name: data.name,
        shortName: data.shortName || null,
        logoUrl: data.logoUrl || null,
        city: data.city || null,
        teamType: data.teamType || "FRIENDLY",
        captainId,
        playerIds: finalPlayerIds,
        createdByUserId: adminId,
        academyId: data.academyId || null,
        coachId: data.coachId || null,
        arenaId: data.arenaId || null,
        motto: data.motto?.trim() || null,
        homeGroundName: data.homeGroundName?.trim() || null,
        foundedYear: data.foundedYear ? Number(data.foundedYear) : null,
        ageGroup: data.ageGroup || null,
        format: data.format || null,
        skillLevel: data.skillLevel || null,
        isPublic: data.isPublic !== false,
        ...(columnSupport.viceCaptainId ? { viceCaptainId } : {}),
        ...(columnSupport.wicketKeeperId ? { wicketKeeperId } : {}),
        ...(columnSupport.supportStaff
          ? {
              supportStaff: Array.isArray(data.supportStaff)
                ? data.supportStaff
                : null,
            }
          : {}),
      },
      select: this.buildTeamSelect(columnSupport),
    })) as any;
    await performanceSvc.eliteAnalytics.recalculateTeamPowerScore(created.id);
    return created;
  }

  async updateTeam(adminId: string, teamId: string, data: any) {
    await this.verifyAdmin(adminId);
    const columnSupport = await this.getTeamColumnSupport();
    const team = await this.findTeamById(teamId);
    if (!team) throw Errors.notFound("Team");
    const playerIds =
      data.playerIds !== undefined
        ? await this.normalizeTeamPlayerIds(data.playerIds)
        : team.playerIds;
    const captainId =
      data.captainId !== undefined
        ? data.captainId
          ? await this.resolvePlayerProfileId(data.captainId)
          : null
        : team.captainId;
    const viceCaptainId =
      columnSupport.viceCaptainId && data.viceCaptainId !== undefined
        ? data.viceCaptainId
          ? await this.resolvePlayerProfileId(data.viceCaptainId)
          : null
        : team.viceCaptainId;
    const wicketKeeperId =
      columnSupport.wicketKeeperId && data.wicketKeeperId !== undefined
        ? data.wicketKeeperId
          ? await this.resolvePlayerProfileId(data.wicketKeeperId)
          : null
        : team.wicketKeeperId;

    const finalPlayerIds = Array.from(
      new Set(
        [captainId, viceCaptainId, wicketKeeperId, ...playerIds].filter(
          Boolean,
        ),
      ),
    ) as string[];
    await this.assertUniqueTeamPlayerPhones(finalPlayerIds);

    const updated = await prisma.team.update({
      where: { id: teamId },
      data: {
        name: data.name,
        shortName: data.shortName,
        logoUrl: data.logoUrl,
        city: data.city,
        teamType: data.teamType,
        isActive: data.isActive,
        captainId,
        playerIds: finalPlayerIds,
        ...(columnSupport.viceCaptainId ? { viceCaptainId } : {}),
        ...(columnSupport.wicketKeeperId ? { wicketKeeperId } : {}),
        ...(columnSupport.supportStaff
          ? {
              supportStaff:
                data.supportStaff !== undefined
                  ? Array.isArray(data.supportStaff)
                    ? data.supportStaff
                    : null
                  : undefined,
            }
          : {}),
      },
      select: this.buildTeamSelect(columnSupport),
    });

    // Cascade name change to all Match records referencing this team
    if (data.name && data.name !== team.name) {
      await Promise.all([
        prisma.match.updateMany({
          where: { teamAName: team.name },
          data: { teamAName: data.name },
        }),
        prisma.match.updateMany({
          where: { teamBName: team.name },
          data: { teamBName: data.name },
        }),
      ]);
    }

    await performanceSvc.eliteAnalytics.recalculateTeamPowerScore(teamId);
    return updated;
  }

  async deleteTeam(adminId: string, teamId: string) {
    await this.verifyAdmin(adminId);
    const columnSupport = await this.getTeamColumnSupport();
    const team = await this.findTeamById(teamId);
    if (!team) throw Errors.notFound("Team");
    const tournamentLinks = await prisma.tournamentTeam.count({
      where: { teamId },
    });
    if (tournamentLinks > 0) {
      throw new AppError(
        "TEAM_IN_USE",
        "This team is linked to tournaments and cannot be deleted",
        409,
      );
    }
    return prisma.team.delete({
      where: { id: teamId },
      select: this.buildTeamSelect(columnSupport),
    });
  }

  async addPlayerToTeam(
    adminId: string,
    teamId: string,
    playerIdOrUserId: string,
  ) {
    await this.verifyAdmin(adminId);
    const columnSupport = await this.getTeamColumnSupport();
    const team = await this.findTeamById(teamId);
    if (!team) throw Errors.notFound("Team");
    const resolvedPlayerId =
      await this.resolvePlayerProfileId(playerIdOrUserId);
    if (team.playerIds.includes(resolvedPlayerId))
      return { message: "Player already in team" };
    await this.assertUniqueTeamPlayerPhones([
      ...team.playerIds,
      resolvedPlayerId,
    ]);
    const updated = await prisma.team.update({
      where: { id: teamId },
      data: { playerIds: { push: resolvedPlayerId } },
      select: this.buildTeamSelect(columnSupport),
    });
    await performanceSvc.eliteAnalytics.recalculateTeamPowerScore(teamId);
    return updated;
  }

  async quickAddPlayerToTeam(
    adminId: string,
    teamId: string,
    data: { name: string; countryCode: string; mobileNumber: string },
  ) {
    await this.verifyAdmin(adminId);
    const columnSupport = await this.getTeamColumnSupport();
    const team = await this.findTeamById(teamId);
    if (!team) throw Errors.notFound("Team");

    const phone = normalizePhone(`${data.countryCode}${data.mobileNumber}`);
    let user = await prisma.user.findUnique({ where: { phone } });

    if (!user) {
      user = await prisma.user.create({
        data: {
          phone,
          name: data.name,
          roles: [UserRole.PLAYER],
          activeRole: UserRole.PLAYER,
        },
      });
    } else if (!user.roles.includes(UserRole.PLAYER)) {
      user = await prisma.user.update({
        where: { id: user.id },
        data: { roles: { push: UserRole.PLAYER } },
      });
    }

    let profile = await prisma.playerProfile.findUnique({
      where: { userId: user.id },
    });
    if (!profile) {
      profile = await prisma.playerProfile.create({
        data: { userId: user.id },
      });
    }

    if (team.playerIds.includes(profile.id)) {
      return { message: "Player already in team", player: profile, user };
    }

    await this.assertUniqueTeamPlayerPhones([...team.playerIds, profile.id]);

    await prisma.team.update({
      where: { id: teamId },
      data: { playerIds: { push: profile.id } },
      select: this.buildTeamSelect(columnSupport),
    });
    await performanceSvc.eliteAnalytics.recalculateTeamPowerScore(teamId);

    return { message: "Player added", player: profile, user };
  }

  async removePlayerFromTeam(
    adminId: string,
    teamId: string,
    playerId: string,
  ) {
    await this.verifyAdmin(adminId);
    const columnSupport = await this.getTeamColumnSupport();
    const team = await this.findTeamById(teamId);
    if (!team) throw Errors.notFound("Team");
    const resolvedPlayerId = await this.resolvePlayerProfileId(playerId);
    const updated = await prisma.team.update({
      where: { id: teamId },
      data: {
        playerIds: team.playerIds.filter((id) => id !== resolvedPlayerId),
        captainId: team.captainId === resolvedPlayerId ? null : team.captainId,
        ...(columnSupport.viceCaptainId
          ? {
              viceCaptainId:
                team.viceCaptainId === resolvedPlayerId
                  ? null
                  : team.viceCaptainId,
            }
          : {}),
        ...(columnSupport.wicketKeeperId
          ? {
              wicketKeeperId:
                team.wicketKeeperId === resolvedPlayerId
                  ? null
                  : team.wicketKeeperId,
            }
          : {}),
      },
      select: this.buildTeamSelect(columnSupport),
    });
    await performanceSvc.eliteAnalytics.recalculateTeamPowerScore(teamId);
    return updated;
  }

  // ── Tournament Groups ─────────────────────────────────────────────────
  async createTournamentGroups(
    adminId: string,
    tournamentId: string,
    groupNames: string[],
    autoAssign?: boolean,
  ) {
    await this.verifyAdmin(adminId);
    const t = await prisma.tournament.findUnique({
      where: { id: tournamentId },
    });
    if (!t) throw Errors.notFound("Tournament");
    // First: null out groupId on all teams so FK constraint doesn't block delete
    await prisma.tournamentTeam.updateMany({
      where: { tournamentId },
      data: { groupId: null },
    });
    await prisma.tournamentStanding.updateMany({
      where: { tournamentId },
      data: { groupId: null },
    });
    await prisma.tournamentGroup.deleteMany({ where: { tournamentId } });
    const groups = await prisma.$transaction(
      groupNames.map((name, i) =>
        prisma.tournamentGroup.create({
          data: { tournamentId, name, groupOrder: i },
        }),
      ),
    );
    if (autoAssign) {
      const confirmedTeams = await prisma.tournamentTeam.findMany({
        where: { tournamentId, isConfirmed: true },
      });
      // Fisher-Yates shuffle for random assignment
      for (let i = confirmedTeams.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [confirmedTeams[i], confirmedTeams[j]] = [
          confirmedTeams[j],
          confirmedTeams[i],
        ];
      }
      // Distribute in round-robin across groups
      const assignments = confirmedTeams.map((team, i) => ({
        teamId: team.id,
        groupId: groups[i % groups.length].id,
      }));
      await prisma.$transaction([
        ...assignments.map(({ teamId, groupId }) =>
          prisma.tournamentTeam.update({
            where: { id: teamId },
            data: { groupId },
          }),
        ),
        ...assignments.map(({ teamId, groupId }) =>
          prisma.tournamentStanding.updateMany({
            where: { tournamentId, tournamentTeamId: teamId },
            data: { groupId },
          }),
        ),
      ]);
    }
    return groups;
  }

  async getTournamentGroups(adminId: string, tournamentId: string) {
    await this.verifyAdmin(adminId);
    return prisma.tournamentGroup.findMany({
      where: { tournamentId },
      include: {
        teams: {
          select: {
            id: true,
            teamName: true,
            isConfirmed: true,
            seed: true,
            teamId: true,
          },
        },
      },
      orderBy: { groupOrder: "asc" },
    });
  }

  async discardTournamentGroups(adminId: string, tournamentId: string) {
    await this.verifyAdmin(adminId);
    const t = await prisma.tournament.findUnique({ where: { id: tournamentId } });
    if (!t) throw Errors.notFound("Tournament");
    await prisma.tournamentTeam.updateMany({ where: { tournamentId }, data: { groupId: null } });
    await prisma.tournamentStanding.updateMany({ where: { tournamentId }, data: { groupId: null } });
    await prisma.tournamentGroup.deleteMany({ where: { tournamentId } });
  }

  async assignTeamToGroup(
    adminId: string,
    tournamentId: string,
    tournamentTeamId: string,
    groupId: string | null,
  ) {
    await this.verifyAdmin(adminId);
    const team = await prisma.tournamentTeam.findUnique({
      where: { id: tournamentTeamId },
    });
    if (!team || team.tournamentId !== tournamentId)
      throw Errors.notFound("Tournament team");
    // Sync groupId on standing too so standings are properly grouped
    await prisma.tournamentStanding.updateMany({
      where: { tournamentId, tournamentTeamId },
      data: { groupId },
    });
    return prisma.tournamentTeam.update({
      where: { id: tournamentTeamId },
      data: { groupId },
    });
  }

  async confirmTournamentTeam(
    adminId: string,
    tournamentTeamId: string,
    isConfirmed: boolean,
  ) {
    await this.verifyAdmin(adminId);
    const team = await prisma.tournamentTeam.findUnique({
      where: { id: tournamentTeamId },
    });
    if (!team) throw Errors.notFound("Tournament team");
    // Create or delete standing
    if (isConfirmed) {
      await prisma.tournamentStanding.upsert({
        where: {
          tournamentId_tournamentTeamId: {
            tournamentId: team.tournamentId,
            tournamentTeamId: team.id,
          },
        },
        create: {
          tournamentId: team.tournamentId,
          tournamentTeamId: team.id,
          groupId: team.groupId,
        },
        update: {},
      });
    }
    return prisma.tournamentTeam.update({
      where: { id: tournamentTeamId },
      data: { isConfirmed },
    });
  }

  // ── Tournament Standings ──────────────────────────────────────────────
  async getTournamentStandings(adminId: string, tournamentId: string) {
    await this.verifyAdmin(adminId);
    const standings = await prisma.tournamentStanding.findMany({
      where: { tournamentId },
      include: {
        team: { select: { id: true, teamName: true, isConfirmed: true } },
        group: { select: { id: true, name: true } },
      },
      orderBy: [{ groupId: "asc" }, { points: "desc" }, { nrr: "desc" }],
    });
    // Group by group
    const grouped: Record<string, typeof standings> = {};
    for (const s of standings) {
      const key = s.groupId ?? "overall";
      if (!grouped[key]) grouped[key] = [];
      grouped[key].push(s);
    }
    return grouped;
  }

  async recalculateStandings(adminId: string, tournamentId: string) {
    await this.verifyAdmin(adminId);
    return this.recalculateStandingsInternal(tournamentId);
  }

  private async recalculateStandingsInternal(tournamentId: string) {
    const tournament = await prisma.tournament.findUnique({
      where: { id: tournamentId },
      include: { teams: { where: { isConfirmed: true } } },
    });
    if (!tournament) throw Errors.notFound("Tournament");

    // Get all completed matches in this tournament
    const matches = await prisma.match.findMany({
      where: { tournamentId, status: "COMPLETED" },
      include: { innings: true },
    });

    // Remove standing rows for teams that are no longer confirmed
    const confirmedIds = tournament.teams.map((t) => t.id);
    await prisma.tournamentStanding.deleteMany({
      where: { tournamentId, tournamentTeamId: { notIn: confirmedIds } },
    });

    // Ensure standing rows exist for every confirmed team, then reset to zero
    const zeroData = {
      played: 0,
      won: 0,
      lost: 0,
      tied: 0,
      noResult: 0,
      points: 0,
      runsScored: 0,
      ballsFaced: 0,
      runsConceded: 0,
      ballsBowled: 0,
      nrr: 0,
    };
    for (const t of tournament.teams) {
      await prisma.tournamentStanding.upsert({
        where: {
          tournamentId_tournamentTeamId: {
            tournamentId,
            tournamentTeamId: t.id,
          },
        },
        create: {
          tournamentId,
          tournamentTeamId: t.id,
          groupId: t.groupId,
          ...zeroData,
        },
        update: { groupId: t.groupId, ...zeroData },
      });
    }

    // Map team names to tournamentTeamId, and teamId to groupId
    const teamMap = new Map<string, string>(); // teamName.lower -> tournamentTeamId
    const groupMap = new Map<string, string | null>(); // tournamentTeamId -> groupId
    for (const t of tournament.teams) {
      teamMap.set(t.teamName.toLowerCase(), t.id);
      groupMap.set(t.id, t.groupId ?? null);
    }

    const updates = new Map<
      string,
      {
        played: number;
        won: number;
        lost: number;
        tied: number;
        noResult: number;
        points: number;
        runsScored: number;
        ballsFaced: number;
        runsConceded: number;
        ballsBowled: number;
      }
    >();

    const getOrInit = (teamId: string) => {
      if (!updates.has(teamId)) {
        updates.set(teamId, {
          played: 0,
          won: 0,
          lost: 0,
          tied: 0,
          noResult: 0,
          points: 0,
          runsScored: 0,
          ballsFaced: 0,
          runsConceded: 0,
          ballsBowled: 0,
        });
      }
      return updates.get(teamId)!;
    };

    for (const match of matches) {
      const teamAId = teamMap.get(match.teamAName.toLowerCase());
      const teamBId = teamMap.get(match.teamBName.toLowerCase());
      if (!teamAId || !teamBId) continue;

      const a = getOrInit(teamAId);
      const b = getOrInit(teamBId);
      a.played++;
      b.played++;

      // Runs and balls from innings
      const inn1 = match.innings.find((i) => i.inningsNumber === 1);
      const inn2 = match.innings.find((i) => i.inningsNumber === 2);

      const teamABatted1 = inn1?.battingTeam === "A";
      if (inn1) {
        const balls = inningsBallsForNrr(inn1, match.customOvers);
        if (teamABatted1) {
          a.runsScored += inn1.totalRuns;
          a.ballsFaced += balls;
          b.runsConceded += inn1.totalRuns;
          b.ballsBowled += balls;
        } else {
          b.runsScored += inn1.totalRuns;
          b.ballsFaced += balls;
          a.runsConceded += inn1.totalRuns;
          a.ballsBowled += balls;
        }
      }
      if (inn2) {
        const balls = inningsBallsForNrr(inn2, match.customOvers);
        if (inn2.battingTeam === "A") {
          a.runsScored += inn2.totalRuns;
          a.ballsFaced += balls;
          b.runsConceded += inn2.totalRuns;
          b.ballsBowled += balls;
        } else {
          b.runsScored += inn2.totalRuns;
          b.ballsFaced += balls;
          a.runsConceded += inn2.totalRuns;
          a.ballsBowled += balls;
        }
      }

      // Winner
      if (!match.winnerId) {
        // No result / tie
        if (match.status === "ABANDONED") {
          a.noResult++;
          b.noResult++;
          a.points += tournament.pointsForNoResult;
          b.points += tournament.pointsForNoResult;
        } else {
          a.tied++;
          b.tied++;
          a.points += tournament.pointsForTie;
          b.points += tournament.pointsForTie;
        }
      } else {
        const aWon =
          match.winnerId === "A" ||
          match.teamAName.toLowerCase() === match.winnerId.toLowerCase();
        if (aWon) {
          a.won++;
          a.points += tournament.pointsForWin;
          b.lost++;
          b.points += tournament.pointsForLoss;
        } else {
          b.won++;
          b.points += tournament.pointsForWin;
          a.lost++;
          a.points += tournament.pointsForLoss;
        }
      }
    }

    // Compute NRR and save
    for (const [teamId, stats] of updates) {
      const nrr =
        stats.ballsFaced > 0 && stats.ballsBowled > 0
          ? stats.runsScored / (stats.ballsFaced / 6) -
            stats.runsConceded / (stats.ballsBowled / 6)
          : 0;
      const roundedNrr = Math.round(nrr * 1000) / 1000;
      const gId = groupMap.get(teamId) ?? null;
      await prisma.tournamentStanding.upsert({
        where: {
          tournamentId_tournamentTeamId: {
            tournamentId,
            tournamentTeamId: teamId,
          },
        },
        create: {
          tournamentId,
          tournamentTeamId: teamId,
          groupId: gId,
          ...stats,
          nrr: roundedNrr,
        },
        update: { groupId: gId, ...stats, nrr: roundedNrr },
      });
    }

    // Update position numbers based on sorted standings
    const sorted = await prisma.tournamentStanding.findMany({
      where: { tournamentId },
      orderBy: [{ points: "desc" }, { nrr: "desc" }],
    });
    for (let i = 0; i < sorted.length; i++) {
      await prisma.tournamentStanding.update({
        where: { id: sorted[i].id },
        data: { position: i + 1 },
      });
    }

    return {
      message: "Standings recalculated",
      matchesProcessed: matches.length,
    };
  }

  // ── Tournament Schedule ───────────────────────────────────────────────
  async getTournamentSchedule(adminId: string, tournamentId: string) {
    await this.verifyAdmin(adminId);
    return prisma.match.findMany({
      where: { tournamentId },
      include: {
        innings: {
          select: {
            inningsNumber: true,
            totalRuns: true,
            totalWickets: true,
            totalOvers: true,
            isCompleted: true,
          },
        },
      },
      orderBy: { scheduledAt: "asc" },
    });
  }

  async deleteSchedule(adminId: string, tournamentId: string) {
    await this.verifyAdmin(adminId);
    const t = await prisma.tournament.findUnique({
      where: { id: tournamentId },
    });
    if (!t) throw Errors.notFound("Tournament");
    const { count } = await prisma.match.deleteMany({
      where: { tournamentId },
    });
    return { deleted: count };
  }

  // Build all match pairs based on tournament format
  private buildMatchPairs(tournament: any): Array<{
    matchType: string;
    format: string;
    round: string;
    teamAName: string;
    teamBName: string;
    teamAPlayerIds: string[];
    teamBPlayerIds: string[];
  }> {
    const fmt = tournament.tournamentFormat ?? "LEAGUE";
    const confirmedTeams: any[] = tournament.teams;
    const pairs: any[] = [];

    if (fmt === "LEAGUE") {
      for (let i = 0; i < confirmedTeams.length; i++) {
        for (let j = i + 1; j < confirmedTeams.length; j++) {
          pairs.push({
            matchType: "TOURNAMENT",
            format: tournament.format,
            round: "League Stage",
            teamAName: confirmedTeams[i].teamName,
            teamBName: confirmedTeams[j].teamName,
            teamAPlayerIds: confirmedTeams[i].playerIds,
            teamBPlayerIds: confirmedTeams[j].playerIds,
          });
        }
      }
    } else if (fmt === "SERIES") {
      if (confirmedTeams.length === 2) {
        const [teamA, teamB] = confirmedTeams;
        const totalMatches = tournament.seriesMatchCount || 3;
        for (let i = 0; i < totalMatches; i++) {
          pairs.push({
            matchType: "TOURNAMENT",
            format: tournament.format,
            round: `Series Match ${i + 1}`,
            teamAName: teamA.teamName,
            teamBName: teamB.teamName,
            teamAPlayerIds: teamA.playerIds,
            teamBPlayerIds: teamB.playerIds,
          });
        }
      } else {
        const meetingsPerPair = tournament.seriesMatchCount || 1;
        for (let round = 0; round < meetingsPerPair; round++) {
          for (let i = 0; i < confirmedTeams.length; i++) {
            for (let j = i + 1; j < confirmedTeams.length; j++) {
              pairs.push({
                matchType: "TOURNAMENT",
                format: tournament.format,
                round:
                  meetingsPerPair > 1
                    ? `Series Round ${round + 1}`
                    : "Series Stage",
                teamAName: confirmedTeams[i].teamName,
                teamBName: confirmedTeams[j].teamName,
                teamAPlayerIds: confirmedTeams[i].playerIds,
                teamBPlayerIds: confirmedTeams[j].playerIds,
              });
            }
          }
        }
      }
    } else if (fmt === "KNOCKOUT" || fmt === "DOUBLE_ELIMINATION") {
      let currentTeams = [...confirmedTeams];
      let roundTeamCount = currentTeams.length;
      
      while (roundTeamCount >= 2) {
        const roundName = this.getKnockoutRoundName(roundTeamCount);
        const paired = Math.floor(roundTeamCount / 2);
        
        for (let i = 0; i < paired; i++) {
          // In the first round, we use real teams. In subsequent rounds, we use placeholders.
          const isFirstRound = roundTeamCount === confirmedTeams.length;
          
          if (isFirstRound) {
            const a = currentTeams[i];
            const b = currentTeams[currentTeams.length - 1 - i];
            pairs.push({
              matchType: "TOURNAMENT",
              format: tournament.format,
              round: roundName,
              teamAName: a.teamName,
              teamBName: b.teamName,
              teamAPlayerIds: a.playerIds,
              teamBPlayerIds: b.playerIds,
            });
          } else {
            pairs.push({
              matchType: "TOURNAMENT",
              format: tournament.format,
              round: roundName,
              teamAName: `Winner of ${this.getKnockoutRoundName(roundTeamCount * 2)} Match ${i * 2 + 1}`,
              teamBName: `Winner of ${this.getKnockoutRoundName(roundTeamCount * 2)} Match ${i * 2 + 2}`,
              teamAPlayerIds: [],
              teamBPlayerIds: [],
            });
          }
        }
        
        // Prepare for next round
        roundTeamCount = Math.ceil(roundTeamCount / 2);
        if (roundTeamCount < 2 && roundName !== "Final") {
           // Ensure we have a final if we haven't reached it yet
           roundTeamCount = 2; 
        }
        if (roundName === "Final") break;
      }
    } else if (fmt === "GROUP_STAGE_KNOCKOUT" || fmt === "SUPER_LEAGUE") {
      for (const group of tournament.groups ?? []) {
        if (group.teams.length < 2) continue;
        for (let i = 0; i < group.teams.length; i++) {
          for (let j = i + 1; j < group.teams.length; j++) {
            pairs.push({
              matchType: "TOURNAMENT",
              format: tournament.format,
              round: group.name,
              teamAName: group.teams[i].teamName,
              teamBName: group.teams[j].teamName,
              teamAPlayerIds: group.teams[i].playerIds,
              teamBPlayerIds: group.teams[j].playerIds,
            });
          }
        }
      }
    }
    return pairs;
  }

  private getKnockoutRoundName(teamCount: number): string {
    if (teamCount >= 16) return "Round of 16";
    if (teamCount >= 8) return "Quarter Final";
    if (teamCount >= 4) return "Semi Final";
    return "Final";
  }

  // ── Complete Match & Auto-advance Knockout ─────────────────────────
  async completeMatch(
    adminId: string,
    matchId: string,
    opts: { winner: "A" | "B" | "NO_RESULT"; isWalkover?: boolean },
  ) {
    await this.verifyAdmin(adminId);
    const match = await prisma.match.findUnique({ where: { id: matchId } });
    if (!match) throw Errors.notFound("Match");

    const winnerId =
      opts.winner === "A"
        ? match.teamAName
        : opts.winner === "B"
          ? match.teamBName
          : null;

    const updated = await prisma.match.update({
      where: { id: matchId },
      data: {
        status: "COMPLETED",
        completedAt: new Date(),
        winnerId,
        ...(opts.isWalkover ? { winMargin: "W/O" } : {}),
      },
    });

    // Auto-recalculate standings and advance knockout bracket
    if (match.tournamentId) {
      try {
        await this.recalculateStandingsInternal(match.tournamentId);
      } catch (_) {}
      await this.tryAdvanceKnockoutRound(match.tournamentId);
    }

    await performanceSvc.processVerifiedMatch(matchId, {
      allowUnverified: true,
    });

    return updated;
  }

  // Called both automatically after completeMatch and manually via API
  async advanceKnockoutRound(
    adminId: string,
    tournamentId: string,
  ): Promise<{
    advanced: boolean;
    round?: string;
    matches?: number;
    reason?: string;
    debug?: string;
  }> {
    await this.verifyAdmin(adminId);

    const KNOCKOUT_ROUNDS = [
      "Round of 32",
      "Round of 16",
      "Quarter Final",
      "Semi Final",
      "Final",
      "Grand Final",
    ];

    const allMatches = await prisma.match.findMany({
      where: { tournamentId },
      orderBy: { scheduledAt: "asc" },
    });

    if (allMatches.length === 0) {
      return { advanced: false, reason: "No fixtures found" };
    }

    const tournament = await prisma.tournament.findUnique({
      where: { id: tournamentId },
      include: { teams: { where: { isConfirmed: true } } },
    });
    if (!tournament) return { advanced: false, reason: "Tournament not found" };

    const fmt = tournament.tournamentFormat ?? "KNOCKOUT";
    const matchFormat = allMatches[0].format as string;

    // Group matches by round
    const roundGroups = new Map<string, typeof allMatches>();
    for (const m of allMatches) {
      const r = m.round ?? "Unknown";
      if (!roundGroups.has(r)) roundGroups.set(r, []);
      roundGroups.get(r)!.push(m);
    }

    const roundsPresent = [...roundGroups.keys()];
    const knockoutRoundsPresent = roundsPresent.filter((r) =>
      KNOCKOUT_ROUNDS.includes(r),
    );
    const groupRoundsPresent = roundsPresent.filter(
      (r) =>
        !KNOCKOUT_ROUNDS.includes(r) && r !== "League Stage" && r !== "Unknown",
    );

    // ── Case 1: Knockout round → next knockout round ──────────────────
    // Sort by KNOCKOUT_ROUNDS order (latest/deepest first)
    const sortedKnockout = knockoutRoundsPresent.sort(
      (a, b) => KNOCKOUT_ROUNDS.indexOf(b) - KNOCKOUT_ROUNDS.indexOf(a),
    );

    for (const round of sortedKnockout) {
      if (round === "Final" || round === "Grand Final") continue;
      const matches = roundGroups.get(round)!;
      const done = matches.filter(
        (m) => m.status === "COMPLETED" || m.status === "ABANDONED",
      );
      if (done.length < matches.length) {
        return {
          advanced: false,
          reason: `${round}: ${done.length}/${matches.length} matches completed — finish all matches first`,
        };
      }
      const sorted = matches.sort(
        (a, b) =>
          new Date(a.scheduledAt).getTime() - new Date(b.scheduledAt).getTime(),
      );
      const winners = sorted
        .map((m) => m.winnerId)
        .filter((w): w is string => !!w);
      if (winners.length < 2) {
        return {
          advanced: false,
          reason: `${round}: only ${winners.length} match(es) have a winner — declare all results first`,
        };
      }
      const nextRoundName = this.getKnockoutRoundName(winners.length);
      const existing = await prisma.match.count({
        where: { tournamentId, round: nextRoundName },
      });
      if (existing > 0) {
        return {
          advanced: false,
          reason: `${nextRoundName} already exists (${existing} match(es)) — check the schedule`,
        };
      }
      return await this.createNextRoundMatches(
        tournamentId,
        nextRoundName,
        winners,
        sorted,
        matchFormat,
      );
    }

    // ── Case 2: Group stage → knockout (GROUP_STAGE_KNOCKOUT / SUPER_LEAGUE) ──
    if (
      (fmt === "GROUP_STAGE_KNOCKOUT" || fmt === "SUPER_LEAGUE") &&
      groupRoundsPresent.length > 0 &&
      knockoutRoundsPresent.length === 0
    ) {
      // Check all group stage matches are done
      for (const grp of groupRoundsPresent) {
        const matches = roundGroups.get(grp)!;
        const done = matches.filter(
          (m) => m.status === "COMPLETED" || m.status === "ABANDONED",
        );
        if (done.length < matches.length) {
          return {
            advanced: false,
            reason: `${grp}: ${done.length}/${matches.length} matches completed — finish all group stage matches first`,
          };
        }
      }

      // Recalculate standings to get current group rankings
      await this.recalculateStandingsInternal(tournamentId);

      // Fetch standings grouped by group
      const standings = await prisma.tournamentStanding.findMany({
        where: { tournamentId },
        include: { group: true, team: true },
        orderBy: [{ groupId: "asc" }, { points: "desc" }, { nrr: "desc" }],
      });

      // Group standings by group
      const standingsByGroup = new Map<string, typeof standings>();
      for (const s of standings) {
        const key = s.group?.name ?? "Ungrouped";
        if (!standingsByGroup.has(key)) standingsByGroup.set(key, []);
        standingsByGroup.get(key)!.push(s);
      }

      // Take top 2 from each group
      const qualifiers: string[] = [];
      for (const [, rows] of standingsByGroup) {
        qualifiers.push(...rows.slice(0, 2).map((r) => r.team.teamName));
      }

      if (qualifiers.length < 2) {
        return {
          advanced: false,
          reason: `Not enough group qualifiers (${qualifiers.length}) to create knockout fixtures`,
        };
      }

      const nextRoundName = this.getKnockoutRoundName(qualifiers.length);
      const existing = await prisma.match.count({
        where: { tournamentId, round: nextRoundName },
      });
      if (existing > 0) {
        return {
          advanced: false,
          reason: `${nextRoundName} already exists — check the schedule`,
        };
      }

      // Cross-group seeding: 1A vs 2B, 1B vs 2A
      const groupKeys = [...standingsByGroup.keys()];
      const seededQualifiers: string[] = [];
      if (groupKeys.length === 2) {
        const [g1, g2] = groupKeys;
        const g1teams = standingsByGroup.get(g1)!;
        const g2teams = standingsByGroup.get(g2)!;
        seededQualifiers.push(
          g1teams[0]?.team.teamName,
          g2teams[1]?.team.teamName,
          g2teams[0]?.team.teamName,
          g1teams[1]?.team.teamName,
        );
      } else {
        seededQualifiers.push(...qualifiers);
      }

      const lastGroupMatch = allMatches[allMatches.length - 1];
      return await this.createNextRoundMatches(
        tournamentId,
        nextRoundName,
        seededQualifiers.filter(Boolean) as string[],
        [lastGroupMatch],
        matchFormat,
      );
    }

    // Nothing to advance
    const debug = `Rounds found: [${roundsPresent.join(", ")}]. Knockout rounds: [${knockoutRoundsPresent.join(", ")}].`;
    return {
      advanced: false,
      reason:
        "Nothing to advance — ensure all current round matches are completed",
      debug,
    };
  }

  private async createNextRoundMatches(
    tournamentId: string,
    roundName: string,
    teams: string[],
    referenceMatches: any[],
    matchFormat: string,
  ) {
    const baseTime = new Date(
      referenceMatches[referenceMatches.length - 1].scheduledAt,
    );
    baseTime.setDate(baseTime.getDate() + 1);
    baseTime.setHours(
      new Date(referenceMatches[0].scheduledAt).getHours(),
      new Date(referenceMatches[0].scheduledAt).getMinutes(),
      0,
      0,
    );

    const nextMatches = [];
    for (let i = 0; i + 1 < teams.length; i += 2) {
      const scheduledAt = new Date(baseTime);
      scheduledAt.setHours(scheduledAt.getHours() + Math.floor(i / 2) * 3);
      nextMatches.push({
        matchType: "TOURNAMENT" as const,
        format: matchFormat as any,
        round: roundName,
        teamAName: teams[i],
        teamBName: teams[i + 1],
        teamAPlayerIds: [] as string[],
        teamBPlayerIds: [] as string[],
        tournamentId,
        scheduledAt,
        status: "SCHEDULED" as const,
      });
    }

    await prisma.match.createMany({ data: nextMatches });
    return { advanced: true, round: roundName, matches: nextMatches.length };
  }

  private async tryAdvanceKnockoutRound(tournamentId: string) {
    // Silently attempt auto-advance — errors are non-fatal
    try {
      // Use a dummy adminId bypass — already verified in completeMatch
      const KNOCKOUT_ROUNDS = [
        "Round of 32",
        "Round of 16",
        "Quarter Final",
        "Semi Final",
        "Final",
        "Grand Final",
      ];

      const allMatches = await prisma.match.findMany({
        where: { tournamentId },
      });
      const roundGroups = new Map<string, typeof allMatches>();
      for (const m of allMatches) {
        const r = m.round ?? "Unknown";
        if (!roundGroups.has(r)) roundGroups.set(r, []);
        roundGroups.get(r)!.push(m);
      }

      const knockoutRoundsPresent = [...roundGroups.keys()]
        .filter((r) => KNOCKOUT_ROUNDS.includes(r))
        .sort(
          (a, b) => KNOCKOUT_ROUNDS.indexOf(b) - KNOCKOUT_ROUNDS.indexOf(a),
        );

      for (const round of knockoutRoundsPresent) {
        if (round === "Final" || round === "Grand Final") continue;
        const matches = roundGroups.get(round)!;
        const allDone = matches.every(
          (m) => m.status === "COMPLETED" || m.status === "ABANDONED",
        );
        if (!allDone) continue;

        const sorted = matches.sort(
          (a, b) =>
            new Date(a.scheduledAt).getTime() -
            new Date(b.scheduledAt).getTime(),
        );
        const winners = sorted
          .map((m) => m.winnerId)
          .filter((w): w is string => !!w);
        if (winners.length < 2) continue;

        const nextRoundName = this.getKnockoutRoundName(winners.length);
        if (nextRoundName === round) continue;

        const existing = await prisma.match.count({
          where: { tournamentId, round: nextRoundName },
        });
        if (existing > 0) continue;

        const baseTime = new Date(sorted[sorted.length - 1].scheduledAt);
        baseTime.setDate(baseTime.getDate() + 1);
        baseTime.setHours(
          new Date(sorted[0].scheduledAt).getHours(),
          new Date(sorted[0].scheduledAt).getMinutes(),
          0,
          0,
        );

        const nextMatches = [];
        for (let i = 0; i + 1 < winners.length; i += 2) {
          const scheduledAt = new Date(baseTime);
          scheduledAt.setHours(scheduledAt.getHours() + Math.floor(i / 2) * 3);
          nextMatches.push({
            matchType: "TOURNAMENT" as const,
            format: matches[0].format,
            round: nextRoundName,
            teamAName: winners[i],
            teamBName: winners[i + 1],
            teamAPlayerIds: [] as string[],
            teamBPlayerIds: [] as string[],
            tournamentId,
            scheduledAt,
            status: "SCHEDULED" as const,
          });
        }
        await prisma.match.createMany({ data: nextMatches });
        break; // only advance one round at a time
      }
    } catch (err) {
      console.error("[tryAdvanceKnockoutRound] failed:", err);
    }
  }

  async generateSmartSchedule(
    adminId: string,
    tournamentId: string,
    options: {
      startDate: string; // "YYYY-MM-DD"
      matchStartTime: string; // "HH:MM"
      matchesPerDay: number;
      gapBetweenMatchesHours: number;
      validWeekdays: number[]; // 0=Sun 1=Mon ... 6=Sat
      excludeDates?: string[]; // ["YYYY-MM-DD"]
    },
  ) {
    await this.verifyAdmin(adminId);

    const tournament = await prisma.tournament.findUnique({
      where: { id: tournamentId },
      include: {
        teams: { where: { isConfirmed: true }, orderBy: { seed: "asc" } },
        groups: {
          include: { teams: { where: { isConfirmed: true } } },
          orderBy: { groupOrder: "asc" },
        },
      },
    });
    if (!tournament) throw Errors.notFound("Tournament");
    if (tournament.teams.length < 2)
      throw new AppError(
        "NOT_ENOUGH_TEAMS",
        "Need at least 2 confirmed teams",
        400,
      );

    const fmt = tournament.tournamentFormat ?? "LEAGUE";
    if (
      (fmt === "GROUP_STAGE_KNOCKOUT" || fmt === "SUPER_LEAGUE") &&
      (!tournament.groups || tournament.groups.length === 0)
    ) {
      throw new AppError(
        "NO_GROUPS",
        "Create groups and assign teams before generating schedule",
        400,
      );
    }

    const pairs = this.buildMatchPairs(tournament);
    if (pairs.length === 0)
      throw new AppError(
        "NO_PAIRS",
        "No matches could be built — check teams/groups",
        400,
      );

    const [startH, startM] = options.matchStartTime.split(":").map(Number);
    const excludeSet = new Set(options.excludeDates ?? []);
    const validDays = new Set(options.validWeekdays);

    const scheduledMatches: any[] = [];
    // Work with a mutable queue — greedy day-by-day assignment
    let remaining = [...pairs];
    let cursor = new Date(`${options.startDate}T00:00:00`);
    let safetyDays = 0;

    while (remaining.length > 0 && safetyDays < 730) {
      const dayStr = cursor.toISOString().split("T")[0];
      if (validDays.has(cursor.getDay()) && !excludeSet.has(dayStr)) {
        // Greedy: pick up to matchesPerDay pairs where neither team plays twice today
        const busyTeamsToday = new Set<string>();
        const deferred: typeof pairs = [];
        let slotCount = 0;

        for (const pair of remaining) {
          if (
            slotCount < options.matchesPerDay &&
            !busyTeamsToday.has(pair.teamAName) &&
            !busyTeamsToday.has(pair.teamBName)
          ) {
            const matchTime = new Date(cursor);
            matchTime.setHours(
              startH,
              startM + slotCount * options.gapBetweenMatchesHours * 60,
              0,
              0,
            );
            scheduledMatches.push({
              ...pair,
              scheduledAt: matchTime,
              venueName: tournament.venueName ?? null,
              tournamentId,
              status: "SCHEDULED",
              isRanked: false,
            });
            busyTeamsToday.add(pair.teamAName);
            busyTeamsToday.add(pair.teamBName);
            slotCount++;
          } else {
            deferred.push(pair);
          }
        }
        remaining = deferred;
      }
      cursor.setDate(cursor.getDate() + 1);
      safetyDays++;
    }

    if (remaining.length > 0) {
      throw new AppError(
        "SCHEDULE_TOO_LONG",
        `Could not fit all ${pairs.length} matches within 2 years with the given constraints`,
        400,
      );
    }

    const created = await prisma.$transaction(
      scheduledMatches.map((m) => prisma.match.create({ data: m })),
    );
    return { matchesCreated: created.length, totalDaysUsed: safetyDays };
  }

  // Kept for backward compat (auto-generate route uses this)
  async generateSchedule(
    adminId: string,
    tournamentId: string,
    startDate: string,
    matchIntervalHours: number,
    matchesPerDay: number = 1,
  ) {
    // Convert to smart schedule: all 7 days
    const dateOnly = new Date(startDate).toISOString().split("T")[0];
    const hour = new Date(startDate).getHours();
    const min = new Date(startDate).getMinutes();
    return this.generateSmartSchedule(adminId, tournamentId, {
      startDate: dateOnly,
      matchStartTime: `${String(hour).padStart(2, "0")}:${String(min).padStart(2, "0")}`,
      matchesPerDay: matchesPerDay,
      gapBetweenMatchesHours: matchIntervalHours,
      validWeekdays: [0, 1, 2, 3, 4, 5, 6],
    });
  }

  async generateLeagueSchedule(
    adminId: string,
    tournamentId: string,
    startDate: string,
    matchIntervalHours: number,
  ) {
    return this.generateSchedule(
      adminId,
      tournamentId,
      startDate,
      matchIntervalHours,
    );
  }

  async generateKnockoutSchedule(
    adminId: string,
    tournamentId: string,
    startDate: string,
    matchIntervalHours: number,
  ) {
    return this.generateSchedule(
      adminId,
      tournamentId,
      startDate,
      matchIntervalHours,
    );
  }

  async listStores(adminId: string, filters: { search?: string; page: number; limit: number }) {
    const where: any = {};
    if (filters.search) {
      where.OR = [
        { name: { contains: filters.search, mode: "insensitive" } },
        { city: { contains: filters.search, mode: "insensitive" } },
      ];
    }
    const [items, total] = await prisma.$transaction([
      prisma.store.findMany({
        where,
        include: { owner: { include: { user: { select: { name: true } } } } },
        orderBy: { createdAt: "desc" },
        skip: (filters.page - 1) * filters.limit,
        take: filters.limit,
      }),
      prisma.store.count({ where }),
    ]);
    return { items, total, page: filters.page, limit: filters.limit };
  }

  async createAdminStore(adminId: string, data: any) {
    const { ownerUserId, ...storeData } = data;
    let owner = await prisma.storeOwnerProfile.findUnique({ where: { userId: ownerUserId } });
    if (!owner) {
      owner = await prisma.storeOwnerProfile.create({ data: { userId: ownerUserId } });
    }
    return prisma.store.create({
      data: {
        ownerId: owner.id,
        ...storeData,
      },
    });
  }
}
