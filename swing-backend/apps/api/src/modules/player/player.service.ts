import { prisma, Prisma } from "@swing/db";
import { Errors, AppError } from "../../lib/errors";
import { resolveMatchRoleBatch } from "../../lib/match-role";
import {
  getPaginationParams,
  buildPaginationMeta,
  normalizePhone,
} from "@swing/utils";
import { type PlayerIndexAxis } from "@swing/types";
import { PerformanceService } from "../performance/performance.service";
import { ChatService } from "../chat/chat.service";
import { NotificationService } from "../notifications/notification.service";
import {
  countIpEvents,
  getIpEventsPage,
  getIpPlayerState,
} from "../performance/state-read.repository";

export class PlayerService {
  private static readonly dayLabels = [
    "SUN",
    "MON",
    "TUE",
    "WED",
    "THU",
    "FRI",
    "SAT",
  ];
  private readonly performanceService = new PerformanceService();
  private readonly chatService = new ChatService();
  private readonly notificationService = new NotificationService();

  private async getIpStateMap(playerIds: string[]) {
    const normalized = Array.from(new Set(playerIds.map((id) => id.trim()).filter(Boolean)));
    if (normalized.length === 0) return new Map<string, {
      currentRankKey: string;
      currentDivision: number;
      rankProgressPoints: number;
      lifetimeIp: number;
      mvpCount: number;
    }>();

    const rows = await prisma.$queryRaw<
      Array<{
        playerId: string;
        currentRankKey: string;
        currentDivision: number;
        rankProgressPoints: number;
        lifetimeIp: number;
        mvpCount: number;
      }>
    >`
      SELECT
        "playerId",
        "currentRankKey",
        "currentDivision",
        "rankProgressPoints",
        "lifetimeIp",
        "mvpCount"
      FROM public.ip_player_state
      WHERE "playerId" IN (${Prisma.join(normalized)})
    `;
    return new Map(rows.map((row) => [row.playerId, row]));
  }

  private async getSwingScoreMap(playerIds: string[]) {
    const normalized = Array.from(new Set(playerIds.map((id) => id.trim()).filter(Boolean)));
    if (normalized.length === 0) return new Map<string, number>();
    const rows = await prisma.$queryRaw<
      Array<{ playerId: string; overallScore: number }>
    >`
      SELECT "playerId", "overallScore"
      FROM public.swing_player_state
      WHERE "playerId" IN (${Prisma.join(normalized)})
    `;
    return new Map(rows.map((row) => [row.playerId, row.overallScore ?? 0]));
  }

  private async getActivePassState(userId: string) {
    const activeSubscription = await prisma.subscription.findFirst({
      where: {
        userId,
        status: "ACTIVE",
        expiresAt: { gte: new Date() },
        OR: [
          { entityType: { contains: "PASS", mode: "insensitive" } },
          { entityType: { contains: "PLAYER", mode: "insensitive" } },
        ],
      },
      orderBy: { expiresAt: "desc" },
      select: { expiresAt: true },
    });
    return {
      hasPremiumPass: Boolean(activeSubscription),
      premiumPassExpiresAt: activeSubscription?.expiresAt ?? null,
    };
  }

  private buildSwingId(profileId: string) {
    const clean = profileId.replace(/-/g, "");
    const prefix = clean
      .substring(0, clean.length < 6 ? clean.length : 6)
      .toUpperCase();
    return prefix ? `SW-${prefix}` : "";
  }

  private extractSwingLookupKey(value: string) {
    let cleaned = value
      .trim()
      .toLowerCase()
      .replace(/[^a-z0-9]/g, "");
    if (cleaned.startsWith("sw")) {
      cleaned = cleaned.substring(2);
    }
    return cleaned;
  }

  async getOrCreateProfile(userId: string) {
    const existing = await prisma.playerProfile.findUnique({
      where: { userId },
    });
    if (existing) return existing;
    return prisma.playerProfile.create({ data: { userId } });
  }

  async getOwnProfile(userId: string) {
    const profileQuery = {
      where: { userId },
      include: {
        user: {
          select: { name: true, phone: true, email: true, avatarUrl: true },
        },
        playerBadges: {
          include: {
            badge: {
              select: {
                id: true,
                name: true,
                description: true,
                iconUrl: true,
                category: true,
                triggerRule: true,
                createdAt: true,
              },
            },
          },
          where: { isDisplayed: true },
          take: 6,
        },
      },
    } as const;

    let resolvedProfile = await prisma.playerProfile.findUnique(profileQuery);
    if (!resolvedProfile) {
      await prisma.playerProfile.create({ data: { userId } });
      resolvedProfile = await prisma.playerProfile.findUnique(profileQuery);
    }
    if (!resolvedProfile) return this.getOrCreateProfile(userId);

    const [performance, ipState, passState] = await Promise.all([
      this.performanceService.getPublicProfileSummary(resolvedProfile.id),
      getIpPlayerState(resolvedProfile.id),
      this.getActivePassState(resolvedProfile.userId),
    ]);
    return {
      ...resolvedProfile,
      // Explicit identity fields surfaced at the top level for clarity
      username: resolvedProfile.username,
      followersCount: resolvedProfile.followersCount,
      followingCount: resolvedProfile.followingCount,
      competitive: {
        rank: performance.rank,
        rankKey: performance.rankKey,
        division: performance.division,
        lifetimeImpactPoints: performance.lifetimeImpactPoints,
        rankProgressPoints: ipState?.rankProgressPoints ?? 0,
        mvpCount: performance.mvpCount,
        hasPremiumPass: passState.hasPremiumPass,
        premiumPassExpiresAt: passState.premiumPassExpiresAt,
      },
      swingIndexSummary: {
        currentSwingIndex: performance.currentSwingIndex,
        selectedDisplayedMetrics: performance.selectedDisplayedMetrics,
      },
    };
  }

  async getPublicProfile(playerProfileId: string) {
    const profile = await prisma.playerProfile.findUnique({
      where: { id: playerProfileId },
      include: {
        user: { select: { name: true, avatarUrl: true } },
        playerBadges: {
          include: {
            badge: {
              select: {
                id: true,
                name: true,
                description: true,
                iconUrl: true,
                category: true,
                triggerRule: true,
                createdAt: true,
              },
            },
          },
          where: { isDisplayed: true },
          take: 6,
        },
      },
    });
    if (!profile) throw Errors.notFound("Player profile");
    if (!profile.isPublic) throw Errors.forbidden();
    const [performance, ipState] = await Promise.all([
      this.performanceService.getPublicProfileSummary(profile.id),
      getIpPlayerState(profile.id),
    ]);
    return {
      ...profile,
      username: profile.username,
      followersCount: profile.followersCount,
      followingCount: profile.followingCount,
      competitive: {
        rank: performance.rank,
        rankKey: performance.rankKey,
        division: performance.division,
        lifetimeImpactPoints: performance.lifetimeImpactPoints,
        rankProgressPoints: ipState?.rankProgressPoints ?? 0,
        mvpCount: performance.mvpCount,
      },
      swingIndexSummary: {
        currentSwingIndex: performance.currentSwingIndex,
        selectedDisplayedMetrics: performance.selectedDisplayedMetrics,
      },
    };
  }

  async updateProfile(userId: string, data: any) {
    const sanitized = this.sanitizeProfileData(data);
    if (data.avatarUrl !== undefined || data.name !== undefined) {
      const userData: any = {};
      if (data.avatarUrl !== undefined) userData.avatarUrl = data.avatarUrl;
      if (data.name !== undefined) userData.name = data.name;

      await prisma.user.update({
        where: { id: userId },
        data: userData,
      });
    }
    return prisma.playerProfile.upsert({
      where: { userId },
      create: { userId, ...sanitized },
      update: sanitized,
    });
  }

  async completeOnboarding(userId: string, data: any) {
    return this.updateProfile(userId, data);
  }

  private sanitizeProfileData(data: any) {
    const allowed = [
      "dateOfBirth",
      "gender",
      "heightCm",
      "weightKg",
      "waistCircumferenceCm",
      "neckCircumferenceCm",
      "hipCircumferenceCm",
      "city",
      "state",
      "playerRole",
      "battingStyle",
      "bowlingStyle",
      "level",
      "goals",
      "jerseyNumber",
      "bio",
      "availableDays",
      "preferredTimes",
      "locationRadius",
      "isPublic",
      "showStats",
      "showLocation",
      "scoutingOptIn",
      "username",
    ];
    const result: any = {};
    for (const key of allowed) {
      if (data[key] !== undefined) {
        if (key === "dateOfBirth") {
          result[key] = new Date(data[key]);
        } else if (key === "username") {
          // Normalise to lowercase alphanumeric + underscore, 3–20 chars
          const slug = String(data[key])
            .trim()
            .toLowerCase()
            .replace(/[^a-z0-9_]/g, "")
            .substring(0, 20);
          if (slug.length >= 3) result[key] = slug;
        } else {
          result[key] = data[key];
        }
      }
    }
    return result;
  }

  private async getRequiredProfile(userId: string) {
    return this.getOrCreateProfile(userId);
  }

  private buildSocialProfileSummary(profile: {
    id: string;
    username: string | null;
    city: string | null;
    state: string | null;
    playerRole: string | null;
    followersCount: number;
    followingCount: number;
    user: { name: string | null; avatarUrl: string | null };
  }, ipState?: {
    currentRankKey: string;
    currentDivision: number;
    rankProgressPoints: number;
    lifetimeIp: number;
  } | null) {
    return {
      id: profile.id,
      fullName: profile.user.name ?? "Swing Player",
      username: profile.username,
      avatarUrl: profile.user.avatarUrl,
      city: profile.city,
      state: profile.state,
      playerRole: profile.playerRole,
      followersCount: profile.followersCount,
      followingCount: profile.followingCount,
      competitive: ipState
        ? {
            rankKey: ipState.currentRankKey,
            division: ipState.currentDivision,
            rankProgressPoints: ipState.rankProgressPoints,
            lifetimeImpactPoints: ipState.lifetimeIp,
          }
        : null,
    };
  }

  private mapShowcaseItem(item: {
    id: string;
    type: string;
    title: string | null;
    caption: string | null;
    url: string;
    thumbnailUrl: string | null;
    matchId: string | null;
    isPinned: boolean;
    isActive: boolean;
    sortOrder: number;
    createdAt: Date;
    match?: {
      id: string;
      teamAName: string;
      teamBName: string;
      format: string;
      completedAt: Date | null;
    } | null;
  }) {
    return {
      id: item.id,
      type: item.type,
      title: item.title,
      caption: item.caption,
      url: item.url,
      thumbnailUrl: item.thumbnailUrl,
      matchId: item.matchId,
      isPinned: item.isPinned,
      isActive: item.isActive,
      sortOrder: item.sortOrder,
      createdAt: item.createdAt,
      match: item.match
        ? {
            id: item.match.id,
            label: `${item.match.teamAName} vs ${item.match.teamBName}`,
            format: item.match.format,
            completedAt: item.match.completedAt,
          }
        : null,
    };
  }

  private async getShowcaseItemsByProfileId(playerProfileId: string) {
    const items = await prisma.profileShowcaseItem.findMany({
      where: {
        playerProfileId,
        isActive: true,
      },
      include: {
        match: {
          select: {
            id: true,
            teamAName: true,
            teamBName: true,
            format: true,
            completedAt: true,
          },
        },
      },
      orderBy: [
        { isPinned: "desc" },
        { sortOrder: "asc" },
        { createdAt: "desc" },
      ],
    });

    return items.map((item) => this.mapShowcaseItem(item));
  }

  private async buildMatchHistoryForProfileId(
    profileId: string,
    page: number,
    limit: number,
  ) {
    // Fetch team names where the player is a member — needed to surface
    // admin-created matches that reference the player's team by name only.
    const playerTeams = await prisma.team.findMany({
      where: { playerIds: { has: profileId }, isActive: true },
      select: { name: true },
    });
    const myTeamNames = playerTeams.map((t) => t.name);

    // If this profile's user is also an arena owner, surface matches that
    // were created via the matchmaking flow at any of their arenas.
    //   1. Find arenas the user owns.
    //   2. Find arenaUnit ids in those arenas.
    //   3. Find MatchmakingMatch ids whose groundId is in those units.
    //   4. Include cricket Match where matchmakingId IN that list.
    // Also collect SlotBooking ids owned by these arenas for non-matchmaking
    // bookings (some flows do set Match.slotBookingId).
    const profileForUser = await prisma.playerProfile.findUnique({
      where: { id: profileId },
      select: { userId: true },
    });
    let ownedArenaSlotBookingIds: string[] = [];
    let ownedArenaMmMatchIds: string[] = [];
    let ownedArenaLinkedMatchIds: string[] = [];
    let ownedArenaIds: string[] = [];
    let ownedUnitIds: string[] = [];
    if (profileForUser?.userId) {
      const owner = await prisma.arenaOwnerProfile.findUnique({
        where: { userId: profileForUser.userId },
        select: { id: true },
      });
      if (owner) {
        const arenas = await prisma.arena.findMany({
          where: { ownerId: owner.id },
          select: { id: true },
        });
        ownedArenaIds = arenas.map((a) => a.id);
        if (ownedArenaIds.length > 0) {
          const [bookings, units] = await Promise.all([
            prisma.slotBooking.findMany({
              where: { arenaId: { in: ownedArenaIds } },
              select: { id: true },
            }),
            prisma.arenaUnit.findMany({
              where: { arenaId: { in: ownedArenaIds } },
              select: { id: true },
            }),
          ]);
          ownedArenaSlotBookingIds = bookings.map((b) => b.id);
          ownedUnitIds = units.map((u) => u.id);
          if (ownedUnitIds.length > 0) {
            const mmMatches = await prisma.matchmakingMatch.findMany({
              where: { groundId: { in: ownedUnitIds } },
              select: { id: true, status: true, linkedMatchId: true },
            });
            ownedArenaMmMatchIds = mmMatches.map((m) => m.id);
            ownedArenaLinkedMatchIds = mmMatches
              .map((m) => m.linkedMatchId)
              .filter((id): id is string => !!id);
            // DIAGNOSTIC: dump each MmMatch and check if cricket Matches exist.
            console.log(
              `[matchHistory] mmMatch detail: ${JSON.stringify(
                mmMatches.map((m) => ({
                  id: m.id,
                  status: m.status,
                  linkedMatchId: m.linkedMatchId,
                })),
              )}`,
            );
            if (ownedArenaLinkedMatchIds.length > 0) {
              const cricketMatches = await prisma.match.findMany({
                where: { id: { in: ownedArenaLinkedMatchIds } },
                select: { id: true, matchmakingId: true, scorerId: true, status: true },
              });
              console.log(
                `[matchHistory] cricket Match for linked ids: ${JSON.stringify(cricketMatches)}`,
              );
            }
          }
        }
      }
    }
    console.log(
      `[matchHistory] profileId=${profileId} userId=${profileForUser?.userId ?? 'none'} `
        + `ownedArenas=${ownedArenaIds.length} units=${ownedUnitIds.length} `
        + `slotBookings=${ownedArenaSlotBookingIds.length} mmMatches=${ownedArenaMmMatchIds.length} `
        + `linkedCricketMatches=${ownedArenaLinkedMatchIds.length} `
        + `myTeams=${myTeamNames.length}`,
    );

    const [statRows, directMatches] = await Promise.all([
      prisma.playerMatchStats.findMany({
        where: { playerProfileId: profileId },
        select: {
          id: true,
          matchId: true,
          playerProfileId: true,
          team: true,
          runs: true,
          balls: true,
          fours: true,
          sixes: true,
          wickets: true,
          catches: true,
          runOuts: true,
          stumpings: true,
          match: true,
        },
        orderBy: { match: { scheduledAt: "desc" } },
      }),
      prisma.match.findMany({
        where: {
          OR: [
            { teamAPlayerIds: { has: profileId } },
            { teamBPlayerIds: { has: profileId } },
            { scorerId: profileId },
            ...(myTeamNames.length > 0
              ? [
                  { teamAName: { in: myTeamNames } },
                  { teamBName: { in: myTeamNames } },
                ]
              : []),
            ...(ownedArenaSlotBookingIds.length > 0
              ? [{ slotBookingId: { in: ownedArenaSlotBookingIds } }]
              : []),
            ...(ownedArenaMmMatchIds.length > 0
              ? [{ matchmakingId: { in: ownedArenaMmMatchIds } }]
              : []),
            ...(ownedArenaLinkedMatchIds.length > 0
              ? [{ id: { in: ownedArenaLinkedMatchIds } }]
              : []),
          ],
        },
        orderBy: { scheduledAt: "desc" },
      }),
    ]);
    console.log(
      `[matchHistory] profileId=${profileId} statRows=${statRows.length} `
        + `directMatches=${directMatches.length} `
        + `direct.scheduled=${directMatches.filter((m) => m.status === 'SCHEDULED').length} `
        + `direct.inProgress=${directMatches.filter((m) => m.status === 'IN_PROGRESS').length}`,
    );
    if (directMatches.length > 0) {
      const sample = directMatches.slice(0, 3).map((m) => ({
        id: m.id,
        status: m.status,
        scorerId: m.scorerId,
        slotBookingId: m.slotBookingId,
        teamAName: m.teamAName,
        teamBName: m.teamBName,
      }));
      console.log(`[matchHistory] sample=${JSON.stringify(sample)}`);
    }

    const statMatchIds = new Set(statRows.map((row) => row.matchId));
    const statItems = statRows.map((row) => ({
      ...row,
      _source: "stat" as const,
    }));
    const directItems = directMatches
      .filter((match) => !statMatchIds.has(match.id))
      .map((match) => {
        // Determine which side the player is on:
        // 1. Explicit player ID in squad arrays (player-created matches)
        // 2. Team name match (admin-created matches)
        const onTeamA =
          match.teamAPlayerIds.includes(profileId) ||
          myTeamNames.includes(match.teamAName);
        return {
          id: `direct-${match.id}`,
          matchId: match.id,
          playerProfileId: profileId,
          team: onTeamA ? "A" : "B",
          runs: null,
          balls: null,
          fours: null,
          sixes: null,
          wickets: null,
          catches: null,
          runOuts: null,
          stumpings: null,
          ipAwarded: null,
          match,
          _source: "direct" as const,
        };
      });

    const all = [...statItems, ...directItems].sort(
      (left, right) =>
        new Date(right.match.scheduledAt).getTime() -
        new Date(left.match.scheduledAt).getTime(),
    );
    const total = all.length;
    const { skip } = getPaginationParams({ page, limit });
    const data = all.slice(skip, skip + limit);

    const teamNames = new Set<string>();
    for (const item of data) {
      if (item.match.teamAName) teamNames.add(item.match.teamAName);
      if (item.match.teamBName) teamNames.add(item.match.teamBName);
    }

    const teams = await prisma.team.findMany({
      where: { name: { in: [...teamNames] } },
      select: { name: true, logoUrl: true, shortName: true },
    });
    const teamByName = new Map(teams.map((team) => [team.name, team]));

    const matchIds = data.map((item) => item.matchId)
    const roleMap = await resolveMatchRoleBatch(profileId, matchIds)

    const enriched = data.map((item) => {
      const myRole = roleMap.get(item.matchId) ?? null
      return {
        ...item,
        myRole,
        // legacy field — kept for backwards compat, derived from myRole
        isHost:
          myRole === 'owner' ||
          myRole === 'manager' ||
          myRole === 'captain-A' ||
          myRole === 'captain-B',
        match: {
          ...item.match,
          teamALogoUrl: teamByName.get(item.match.teamAName)?.logoUrl ?? null,
          teamAShortName: teamByName.get(item.match.teamAName)?.shortName ?? null,
          teamBLogoUrl: teamByName.get(item.match.teamBName)?.logoUrl ?? null,
          teamBShortName: teamByName.get(item.match.teamBName)?.shortName ?? null,
        },
      }
    })

    return { data: enriched, meta: buildPaginationMeta(total, page, limit) };
  }

  private async getIpLedgerPreviewSafe(playerProfileId: string) {
    try {
      const events = await getIpEventsPage(playerProfileId, 0, 5);
      return events.map((event) => {
        const rankBefore =
          event.rankBefore && event.divisionBefore !== null
            ? `${event.rankBefore}:${event.divisionBefore}`
            : event.rankBefore;
        const rankAfter =
          event.rankAfter && event.divisionAfter !== null
            ? `${event.rankAfter}:${event.divisionAfter}`
            : event.rankAfter;
        return {
          id: String(event.id),
          playerProfileId: event.playerId,
          ipDelta: event.ipDelta,
          reason: event.reason,
          matchId: event.matchId,
          referenceId: event.externalRef,
          rankBefore,
          rankAfter,
          createdAt: event.createdAt,
        };
      });
    } catch {
      return [];
    }
  }

  private async buildFullProfile(
    viewerUserId: string | null,
    targetProfile: {
      id: string;
      userId: string;
      username: string | null;
      gender: string | null;
      dateOfBirth: Date | null;
      city: string | null;
      state: string | null;
      playerRole: string;
      battingStyle: string;
      bowlingStyle: string;
      level: string;
      goals: string | null;
      jerseyNumber: number | null;
      bio: string | null;
      isPublic: boolean;
      showStats: boolean;
      showLocation: boolean;
      scoutingOptIn: boolean;
      followersCount: number;
      followingCount: number;
      totalRuns: number;
      totalWickets: number;
      catches: number;
      matchesPlayed: number;
      matchesWon: number;
      user: {
        id: string;
        name: string | null;
        avatarUrl: string | null;
        phone?: string | null;
        email?: string | null;
      };
      playerBadges: Array<{
        id: string;
        awardedAt: Date;
        awardedReason: string | null;
        isDisplayed: boolean;
        badge: {
          id: string;
          name: string;
          description: string;
          iconUrl: string | null;
          category: string;
          ipBonus: number;
          isRare: boolean;
        };
      }>;
    },
    options?: {
      isSelf?: boolean;
    },
  ) {
    const isSelf = options?.isSelf ?? false;
    if (!isSelf && !targetProfile.isPublic) throw Errors.forbidden();

    const [
      performance,
      season,
      showcase,
      recentMatches,
      badges,
      ipLedgerPreview,
      activityPreview,
      ipState,
      passState,
    ] = await Promise.all([
      this.performanceService.getPlayerStatsSummary(targetProfile.id),
      this.performanceService.getPlayerSeason(targetProfile.id),
      this.getShowcaseItemsByProfileId(targetProfile.id),
      this.buildMatchHistoryForProfileId(targetProfile.id, 1, 3),
      prisma.playerBadge.findMany({
        where: { playerProfileId: targetProfile.id },
        include: {
          badge: {
            select: {
              id: true,
              name: true,
              description: true,
              iconUrl: true,
              category: true,
              triggerRule: true,
              createdAt: true,
            },
          },
        },
        orderBy: [{ isDisplayed: "desc" }, { awardedAt: "desc" }],
        take: 12,
      }),
      this.getIpLedgerPreviewSafe(targetProfile.id),
      this.performanceService.getCompetitiveEvents(targetProfile.id, 5),
      getIpPlayerState(targetProfile.id),
      this.getActivePassState(targetProfile.userId),
    ]);

    let viewerContext: {
      isSelf: boolean;
      following: boolean;
      directConversationId: string | null;
    } | null = null;

    let notificationSummary: unknown = null;

    if (viewerUserId) {
      const viewerProfile = await this.getRequiredProfile(viewerUserId);
      const following =
        viewerProfile.id === targetProfile.id
          ? false
          : Boolean(
              await prisma.playerFollow.findUnique({
                where: {
                  followerPlayerId_followingPlayerId: {
                    followerPlayerId: viewerProfile.id,
                    followingPlayerId: targetProfile.id,
                  },
                },
              }),
            );

      viewerContext = {
        isSelf: viewerProfile.id === targetProfile.id,
        following,
        directConversationId:
          viewerProfile.id === targetProfile.id
            ? null
            : await this.chatService.findExistingDirectConversation(
                viewerUserId,
                targetProfile.id,
              ),
      };

      if (isSelf) {
        notificationSummary =
          await this.notificationService.getSummary(viewerUserId);
      }
    }

    return {
      identity: {
        id: targetProfile.id,
        userId: targetProfile.userId,
        fullName: targetProfile.user.name ?? "Swing Player",
        username: targetProfile.username,
        avatarUrl: targetProfile.user.avatarUrl,
        gender: targetProfile.gender,
        phone: isSelf ? (targetProfile.user.phone ?? null) : null,
        email: isSelf ? (targetProfile.user.email ?? null) : null,
        city: targetProfile.city,
        state: targetProfile.state,
        playerRole: targetProfile.playerRole,
        battingStyle: targetProfile.battingStyle,
        bowlingStyle: targetProfile.bowlingStyle,
        level: targetProfile.level,
        jerseyNumber: targetProfile.jerseyNumber,
        bio: targetProfile.bio,
        goals: targetProfile.goals,
        dateOfBirth: isSelf ? targetProfile.dateOfBirth : null,
      },
      social: {
        followersCount: targetProfile.followersCount,
        followingCount: targetProfile.followingCount,
        viewerContext,
      },
      competitive: {
        rank: performance.competitive.rank,
        rankKey: performance.competitive.rankKey,
        division: performance.competitive.division,
        lifetimeImpactPoints: performance.competitive.impactPoints,
        rankProgressPoints: ipState?.rankProgressPoints ?? 0,
        rankProgressMax: performance.competitive.rankProgressMax,
        mvpCount: performance.competitive.mvpCount,
        matchesPlayed: performance.competitive.matchesPlayed,
        winRate:
          targetProfile.matchesPlayed > 0
            ? Math.round(
                (targetProfile.matchesWon / targetProfile.matchesPlayed) * 1000,
              ) / 10
            : 0,
        hasPremiumPass: passState.hasPremiumPass,
        premiumPassExpiresAt: passState.premiumPassExpiresAt,
      },
      legacy: {
        lifetimeImpactPoints: performance.competitive.impactPoints,
        badgesDisplayedCount: targetProfile.playerBadges.filter(
          (item) => item.isDisplayed,
        ).length,
        totalBadgesCount: badges.length,
      },
      season,
      stats: {
        swingIndex: performance.swingIndex,
        batting: {
          runs: targetProfile.totalRuns,
          wickets: targetProfile.totalWickets,
          catches: targetProfile.catches,
          matchesPlayed: targetProfile.matchesPlayed,
          matchesWon: targetProfile.matchesWon,
        },
      },
      badges: badges.map((item) => ({
        id: item.id,
        awardedAt: item.awardedAt,
        awardedReason: item.awardedReason,
        isDisplayed: item.isDisplayed,
        badge: item.badge,
      })),
      showcase,
      recentMatches: recentMatches.data,
      ipLedgerPreview,
      activityPreview,
      notificationSummary,
      settings: isSelf
        ? {
            isPublic: targetProfile.isPublic,
            showStats: targetProfile.showStats,
            showLocation: targetProfile.showLocation,
            scoutingOptIn: targetProfile.scoutingOptIn,
          }
        : null,
    };
  }

  async getStats(userId: string) {
    const profile = await this.getRequiredProfile(userId);
    const performance = await this.performanceService.getPlayerStatsSummary(
      profile.id,
    );
    return {
      batting: {
        runs: profile.totalRuns,
        balls: profile.totalBallsFaced,
        average: profile.battingAverage,
        strikeRate: profile.strikeRate,
        highestScore: profile.highestScore,
        fifties: profile.fifties,
        hundreds: profile.hundreds,
        fours: profile.fours,
        sixes: profile.sixes,
      },
      bowling: {
        wickets: profile.totalWickets,
        oversBowled: profile.totalOversBowled,
        average: profile.bowlingAverage,
        economy: profile.economyRate,
        strikeRate: profile.bowlingStrikeRate,
        bestBowling: profile.bestBowling,
        fiveWicketHauls: profile.fiveWicketHauls,
      },
      fielding: {
        catches: profile.catches,
        stumpings: profile.stumpings,
        runOuts: profile.runOuts,
      },
      swingIndex: {
        overall: performance.swingIndex.currentSwingIndex,
        batting: profile.battingScore,
        bowling: profile.bowlingScore,
        fielding: profile.fieldingScore,
        fitness: profile.fitnessScore,
        gameIntelligence: profile.gameIntelligence,
        coachability: profile.coachability,
        currentSwingIndex: performance.swingIndex.currentSwingIndex,
        reliabilityIndex: performance.swingIndex.reliabilityIndex,
        powerIndex: performance.swingIndex.powerIndex,
        bowlingIndex: performance.swingIndex.bowlingIndex,
        fieldingIndex: performance.swingIndex.fieldingIndex,
        impactIndex: performance.swingIndex.impactIndex,
        captaincyIndex: performance.swingIndex.captaincyIndex,
      },
      ranking: {
        matchesPlayed: profile.matchesPlayed,
        matchesWon: profile.matchesWon,
      },
      competitive: performance.competitive,
      season: performance.season,
    };
  }

  async getIndexTrend(userId: string, days: number) {
    const profile = await this.getRequiredProfile(userId);
    const since = new Date(Date.now() - days * 24 * 60 * 60 * 1000);
    const [legacySnapshots, performanceTrend] = await Promise.all([
      prisma.metricSnapshot.findMany({
        where: { playerProfileId: profile.id, date: { gte: since } },
        orderBy: { date: "asc" },
      }),
      this.performanceService.getPlayerIndexTrend(profile.id, days),
    ]);

    return {
      days,
      trend: performanceTrend,
      series: {
        swingIndex: performanceTrend.map((item) => ({
          date: item.snapshotDate,
          value: item.swingIndex,
        })),
        reliabilityIndex: performanceTrend.map((item) => ({
          date: item.snapshotDate,
          value: item.reliabilityIndex,
        })),
        powerIndex: performanceTrend.map((item) => ({
          date: item.snapshotDate,
          value: item.powerIndex,
        })),
        bowlingIndex: performanceTrend.map((item) => ({
          date: item.snapshotDate,
          value: item.bowlingIndex,
        })),
        fieldingIndex: performanceTrend.map((item) => ({
          date: item.snapshotDate,
          value: item.fieldingIndex,
        })),
        impactIndex: performanceTrend.map((item) => ({
          date: item.snapshotDate,
          value: item.impactIndex,
        })),
        captaincyIndex: performanceTrend.map((item) => ({
          date: item.snapshotDate,
          value: item.captaincyIndex,
        })),
        impactPoints: performanceTrend.map((item) => ({
          date: item.snapshotDate,
          value: item.impactPoints,
        })),
        seasonPoints: performanceTrend.map((item) => ({
          date: item.snapshotDate,
          value: item.seasonPoints,
        })),
        rankProgression: performanceTrend.map((item) => ({
          date: item.snapshotDate,
          rankKey: item.rankKey,
          division: item.division,
          rankLabel: item.rankLabel,
        })),
      },
      legacyMetricSnapshots: legacySnapshots,
    };
  }

  async getMyTournaments(userId: string) {
    const profile = await prisma.playerProfile.findUnique({
      where: { userId },
    });

    const tournamentSelect = {
      id: true,
      name: true,
      slug: true,
      status: true,
      format: true,
      tournamentFormat: true,
      startDate: true,
      endDate: true,
      logoUrl: true,
      city: true,
      venueName: true,
      entryFee: true,
      maxTeams: true,
      createdByUserId: true,
      _count: { select: { teams: { where: { isConfirmed: true } } } },
    } as const;

    // Hosted tournaments (created by user)
    const hosted = await prisma.tournament.findMany({
      where: { createdByUserId: userId },
      select: tournamentSelect,
      orderBy: { startDate: "desc" },
    });

    // Tournaments where user is a participant via TournamentTeam.playerIds
    const participatedTeams = profile
      ? await prisma.tournamentTeam.findMany({
          where: { playerIds: { has: profile.id } },
          select: { tournamentId: true },
        })
      : [];
    const hostedIds = new Set(hosted.map((t) => t.id));
    const participatedIds = participatedTeams
      .map((tt) => tt.tournamentId)
      .filter((id) => !hostedIds.has(id));

    const participated =
      participatedIds.length > 0
        ? await prisma.tournament.findMany({
            where: { id: { in: participatedIds } },
            select: tournamentSelect,
            orderBy: { startDate: "desc" },
          })
        : [];

    const toItem = (t: (typeof hosted)[number], isHost: boolean) => ({
      ...t,
      isHost,
      teamCount: t._count.teams,
    });

    return {
      tournaments: [
        ...hosted.map((t) => toItem(t, true)),
        ...participated.map((t) => toItem(t, false)),
      ].sort(
        (a, b) =>
          new Date(b.startDate).getTime() - new Date(a.startDate).getTime(),
      ),
    };
  }

  async getMatchHistory(userId: string, page: number, limit: number) {
    const profile = await prisma.playerProfile.findUnique({
      where: { userId },
    });
    if (!profile)
      return { data: [], meta: buildPaginationMeta(0, page, limit) };
    return this.buildMatchHistoryForProfileId(profile.id, page, limit);
  }

  async getPublicMatchHistory(profileId: string, limit: number, offset: number) {
    const profile = await prisma.playerProfile.findUnique({
      where: { id: profileId },
      select: { id: true },
    });

    if (!profile) return null;

    const facts = await prisma.matchPlayerFact.findMany({
      where: { playerId: profileId },
      orderBy: { matchDate: "desc" },
      skip: offset,
      take: limit,
      select: {
        teamId: true,
        opponentTeamId: true,
        runs: true,
        ballsFaced: true,
        wickets: true,
        catches: true,
        match: {
          select: {
            id: true,
            format: true,
            scheduledAt: true,
            teamAName: true,
            teamBName: true,
            teamAPlayerIds: true,
            teamBPlayerIds: true,
            winnerId: true,
            tournamentId: true,
            venueName: true,
            venue: {
              select: {
                id: true,
                name: true,
              },
            },
          },
        },
      },
    });

    if (facts.length === 0) return { data: [] };

    const teamNames = Array.from(
      new Set(
        facts.flatMap((fact) => [fact.match.teamAName, fact.match.teamBName]).filter(Boolean),
      ),
    );
    const tournamentIds = Array.from(
      new Set(facts.map((fact) => fact.match.tournamentId).filter((id): id is string => Boolean(id))),
    );

    const [teams, tournaments] = await Promise.all([
      teamNames.length > 0
        ? prisma.team.findMany({
            where: { name: { in: teamNames } },
            select: { id: true, name: true },
          })
        : Promise.resolve([]),
      tournamentIds.length > 0
        ? prisma.tournament.findMany({
            where: { id: { in: tournamentIds } },
            select: { id: true, name: true },
          })
        : Promise.resolve([]),
    ]);

    const teamByName = new Map(teams.map((team) => [team.name, team]));
    const tournamentById = new Map(tournaments.map((tournament) => [tournament.id, tournament]));
    const normalize = (value: string | null | undefined) => value?.trim().toLowerCase() ?? "";

    return {
      data: facts.map((fact) => {
        const teamA = teamByName.get(fact.match.teamAName);
        const teamB = teamByName.get(fact.match.teamBName);
        const playerTeam =
          normalize(fact.teamId) === normalize(fact.match.teamAName)
            ? "A"
            : normalize(fact.teamId) === normalize(fact.match.teamBName)
              ? "B"
              : fact.match.teamAPlayerIds.includes(profileId)
                ? "A"
                : "B";
        const tournament = fact.match.tournamentId
          ? tournamentById.get(fact.match.tournamentId) ?? null
          : null;

        return {
          match: {
            id: fact.match.id,
            title: `${fact.match.teamAName} vs ${fact.match.teamBName}`,
            format: fact.match.format,
            scheduledAt: fact.match.scheduledAt,
            teamA: {
              id: teamA?.id ?? null,
              name: fact.match.teamAName,
            },
            teamB: {
              id: teamB?.id ?? null,
              name: fact.match.teamBName,
            },
            winnerId: fact.match.winnerId,
            tournament: tournament
              ? {
                  id: tournament.id,
                  name: tournament.name,
                }
              : null,
            arena: fact.match.venue
              ? {
                  id: fact.match.venue.id,
                  name: fact.match.venue.name,
                }
              : fact.match.venueName
                ? {
                    id: null,
                    name: fact.match.venueName,
                  }
                : null,
          },
          team: playerTeam,
          runs: fact.runs,
          balls: fact.ballsFaced,
          wickets: fact.wickets,
          catches: fact.catches,
          isParticipant: true,
        };
      }),
    };
  }

  async searchPlayers(
    userId: string,
    query: string,
    limit: number,
    filters?: {
      city?: string;
      playerRole?:
        | "BATSMAN"
        | "BOWLER"
        | "ALL_ROUNDER"
        | "WICKET_KEEPER"
        | "WICKET_KEEPER_BATSMAN";
      playerLevel?:
        | "CLUB"
        | "CORPORATE"
        | "STATE"
        | "DIVISION"
        | "IPL"
        | "INTERNATIONAL";
    },
  ) {
    const trimmedQuery = query.trim();
    const swingLookupKey = this.extractSwingLookupKey(trimmedQuery);
    const where: any = {
      id: { not: userId },
      playerProfile: { isNot: null },
    };
    const andFilters: any[] = [];

    if (trimmedQuery) {
      andFilters.push({
        OR: [
          { phone: { contains: trimmedQuery } },
          { name: { contains: trimmedQuery, mode: "insensitive" } },
          ...(swingLookupKey.length >= 3
            ? [
                {
                  playerProfile: {
                    is: {
                      id: { startsWith: swingLookupKey },
                    },
                  },
                },
              ]
            : []),
        ],
      });
    }

    if (filters?.city) {
      andFilters.push({
        playerProfile: {
          is: {
            city: { contains: filters.city, mode: "insensitive" },
          },
        },
      });
    }

    if (filters?.playerRole) {
      andFilters.push({
        playerProfile: {
          is: {
            playerRole: filters.playerRole as any,
          },
        },
      });
    }

    if (filters?.playerLevel) {
      andFilters.push({
        playerProfile: {
          is: {
            level: filters.playerLevel as any,
          },
        },
      });
    }

    if (andFilters.length > 0) {
      where.AND = andFilters;
    }

    const users = await prisma.user.findMany({
      where,
      select: {
        id: true,
        name: true,
        phone: true,
        avatarUrl: true,
        playerProfile: {
          select: {
            id: true,
            playerRole: true,
            level: true,
            city: true,
          },
        },
      },
      take: limit,
      orderBy: { name: "asc" },
    });

    const swingScores = await this.getSwingScoreMap(
      users
        .map((user) => user.playerProfile?.id ?? null)
        .filter((id): id is string => Boolean(id)),
    );

    return users.map((user) => ({
      userId: user.id,
      profileId: user.playerProfile?.id ?? null,
      swingId: user.playerProfile?.id
        ? this.buildSwingId(user.playerProfile.id)
        : null,
      name: user.name,
      avatarUrl: user.avatarUrl,
      phone: user.phone,
      playerRole: user.playerProfile?.playerRole,
      playerLevel: user.playerProfile?.level,
      city: user.playerProfile?.city ?? null,
      swingIndex: user.playerProfile?.id
        ? (swingScores.get(user.playerProfile.id) ?? 0)
        : 0,
    }));
  }

  async getEnrollments(userId: string) {
    const profile = await prisma.playerProfile.findUnique({
      where: { userId },
    });
    if (!profile) return [];

    const enrollments = await prisma.academyEnrollment.findMany({
      where: { playerProfileId: profile.id, isActive: true },
      include: {
        academy: {
          select: {
            id: true,
            name: true,
            city: true,
            logoUrl: true,
            coaches: {
              where: { isActive: true },
              include: {
                coach: {
                  include: {
                    user: { select: { id: true, name: true, avatarUrl: true } },
                  },
                },
              },
              orderBy: [{ isHeadCoach: "desc" }, { joinedAt: "asc" }],
            },
          },
        },
        batch: {
          include: {
            schedules: {
              where: { isActive: true },
              orderBy: [{ dayOfWeek: "asc" }, { startTime: "asc" }],
            },
          },
        },
      },
      orderBy: { enrolledAt: "desc" },
    });

    return enrollments.map((enrollment) => {
      const scheduleDays =
        enrollment.batch?.schedules.map(
          (schedule) =>
            PlayerService.dayLabels[schedule.dayOfWeek] ??
            `DAY_${schedule.dayOfWeek}`,
        ) ?? [];
      const firstSchedule = enrollment.batch?.schedules[0];
      const primaryCoach = enrollment.academy.coaches[0]?.coach;

      return {
        enrollmentId: enrollment.id,
        academy: enrollment.academy,
        batch: enrollment.batch
          ? {
              id: enrollment.batch.id,
              name: enrollment.batch.name,
              schedule: scheduleDays,
              time: firstSchedule?.startTime ?? null,
            }
          : null,
        coach: primaryCoach
          ? {
              id: primaryCoach.id,
              userId: primaryCoach.user.id,
              name: primaryCoach.user.name,
              avatarUrl: primaryCoach.user.avatarUrl,
            }
          : null,
        enrolledAt: enrollment.enrolledAt,
        feeStatus: enrollment.feeStatus,
      };
    });
  }

  async getActivity(userId: string, limit: number) {
    const profile = await this.getRequiredProfile(userId);

    const [matches, sessions, badges, drills, competitiveEvents] =
      await Promise.all([
        prisma.playerMatchStats.findMany({
          where: {
            playerProfileId: profile.id,
            match: { status: "COMPLETED" },
          },
          include: { match: true },
          orderBy: { match: { completedAt: "desc" } },
          take: 5,
        }),
        prisma.sessionAttendance.findMany({
          where: { playerProfileId: profile.id },
          include: {
            session: {
              include: {
                coach: { include: { user: { select: { name: true } } } },
              },
            },
          },
          orderBy: { scannedAt: "desc" },
          take: 5,
        }),
        prisma.playerBadge.findMany({
          where: { playerProfileId: profile.id },
          include: {
            badge: {
              select: {
                id: true,
                name: true,
                description: true,
                iconUrl: true,
                category: true,
                triggerRule: true,
                createdAt: true,
              },
            },
          },
          orderBy: { awardedAt: "desc" },
          take: 5,
        }),
        prisma.drillAssignment.findMany({
          where: {
            playerProfileId: profile.id,
            OR: [{ status: "COMPLETED" }, { completedAt: { not: null } }],
          },
          include: { drill: true },
          orderBy: { completedAt: "desc" },
          take: 5,
        }),
        this.performanceService.getCompetitiveEvents(profile.id, limit),
      ]);

    const items = [
      ...matches.map((stat) => ({
        id: stat.id,
        type: "MATCH",
        title: `vs ${stat.team === "A" ? stat.match.teamBName : stat.match.teamAName}`,
        subtitle: `${stat.team === stat.match.winnerId ? "Won" : "Played"} · ${stat.match.format}`,
        iconType: "trophy",
        ipEarned: (stat as any).ipAwarded ?? 0,
        createdAt: stat.match.completedAt ?? stat.match.updatedAt,
      })),
      ...sessions.map((attendance) => ({
        id: attendance.id,
        type: "SESSION",
        title:
          attendance.session.locationName ??
          attendance.session.sessionType.replaceAll("_", " "),
        subtitle: attendance.session.coach.user.name,
        iconType: "calendar",
        ipEarned: 0,
        createdAt: attendance.scannedAt ?? attendance.session.scheduledAt,
      })),
      ...badges.map((playerBadge) => ({
        id: playerBadge.id,
        type: "BADGE",
        title: playerBadge.badge.name,
        subtitle: playerBadge.awardedReason ?? "Badge earned",
        iconType: "star",
        ipEarned: 0,
        createdAt: playerBadge.awardedAt,
      })),
      ...drills.map((assignment) => ({
        id: assignment.id,
        type: "DRILL",
        title: assignment.drill.name,
        subtitle: assignment.completionNote ?? "Drill completed",
        iconType: "check",
        ipEarned: 0,
        createdAt: assignment.completedAt ?? assignment.createdAt,
      })),
      ...competitiveEvents.map((event) => ({
        id: event.id,
        type: event.type,
        title: event.title,
        subtitle: event.subtitle,
        iconType: event.iconType,
        ipEarned: null,
        impactPoints: event.impactPoints,
        seasonPoints: event.seasonPoints,
        label:
          event.type.includes("IMPACT") ||
          event.type === "MVP_AWARD" ||
          event.type === "RANK_PROMOTION"
            ? "Impact Points"
            : "Season Points",
        createdAt: event.createdAt,
      })),
    ];

    return items
      .sort(
        (a, b) =>
          new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime(),
      )
      .slice(0, limit);
  }

  async getBadges(userId: string) {
    const profile = await prisma.playerProfile.findUnique({
      where: { userId },
    });
    if (!profile) return [];
    return prisma.playerBadge.findMany({
      where: { playerProfileId: profile.id },
      include: {
        badge: {
          select: {
            id: true,
            name: true,
            description: true,
            iconUrl: true,
            category: true,
            triggerRule: true,
            createdAt: true,
          },
        },
      },
      orderBy: { awardedAt: "desc" },
    });
  }

  async getIpLog(userId: string, page: number, limit: number) {
    const profile = await this.getRequiredProfile(userId);
    const { skip } = getPaginationParams({ page, limit });
    const [data, total] = await Promise.all([
      getIpEventsPage(profile.id, skip, limit),
      countIpEvents(profile.id),
    ]);
    const normalized = data.map((event) => {
      const rankBefore =
        event.rankBefore && event.divisionBefore !== null
          ? `${event.rankBefore}:${event.divisionBefore}`
          : event.rankBefore;
      const rankAfter =
        event.rankAfter && event.divisionAfter !== null
          ? `${event.rankAfter}:${event.divisionAfter}`
          : event.rankAfter;
      return {
        id: String(event.id),
        playerProfileId: event.playerId,
        ipDelta: event.ipDelta,
        reason: event.reason,
        matchId: event.matchId,
        referenceId: event.externalRef,
        rankBefore,
        rankAfter,
        createdAt: event.createdAt,
      };
    });
    return { data: normalized, meta: buildPaginationMeta(total, page, limit) };
  }

  async getCompetitiveProfile(userId: string) {
    const profile = await this.getRequiredProfile(userId);
    const [competitive, activeSubscription] = await Promise.all([
      getIpPlayerState(profile.id),
      prisma.subscription.findFirst({
        where: {
          userId: profile.userId,
          status: "ACTIVE",
          expiresAt: { gte: new Date() },
          OR: [
            { entityType: { contains: "PASS", mode: "insensitive" } },
            { entityType: { contains: "PLAYER", mode: "insensitive" } },
          ],
        },
        orderBy: { expiresAt: "desc" },
        select: { expiresAt: true },
      }),
    ]);
    if (!competitive) return null;
    return {
      lifetimeImpactPoints: competitive.lifetimeIp,
      rankProgressPoints: competitive.rankProgressPoints,
      currentRankKey: competitive.currentRankKey,
      currentDivision: competitive.currentDivision,
      winStreak: competitive.winStreak,
      mvpCount: competitive.mvpCount,
      lastRankedMatchAt: competitive.lastRankedMatchAt,
      hasPremiumPass: Boolean(activeSubscription),
      premiumPassExpiresAt: activeSubscription?.expiresAt ?? null,
    };
  }

  async getOwnFullProfile(userId: string): Promise<any> {
    const profile = (await prisma.playerProfile.findUnique({
      where: { userId },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            phone: true,
            email: true,
            avatarUrl: true,
          },
        },
        playerBadges: {
          include: {
            badge: {
              select: {
                id: true,
                name: true,
                description: true,
                iconUrl: true,
                category: true,
                triggerRule: true,
                createdAt: true,
              },
            },
          },
          where: { isDisplayed: true },
          take: 6,
        },
      },
    })) as any;

    if (!profile) {
      await this.getOrCreateProfile(userId);
      return this.getOwnFullProfile(userId);
    }

    return this.buildFullProfile(userId, profile, { isSelf: true });
  }

  async getPublicFullProfile(
    viewerUserId: string | null,
    playerProfileId: string,
  ) {
    const profile = (await prisma.playerProfile.findUnique({
      where: { id: playerProfileId },
      include: {
        user: { select: { id: true, name: true, avatarUrl: true } },
        playerBadges: {
          include: {
            badge: {
              select: {
                id: true,
                name: true,
                description: true,
                iconUrl: true,
                category: true,
                triggerRule: true,
                createdAt: true,
              },
            },
          },
          where: { isDisplayed: true },
          take: 6,
        },
      },
    })) as any;
    if (!profile) throw Errors.notFound("Player profile");
    return this.buildFullProfile(viewerUserId, profile);
  }

  async getMyShowcase(userId: string) {
    const profile = await this.getRequiredProfile(userId);
    return this.getShowcaseItemsByProfileId(profile.id);
  }

  async createShowcaseItem(
    userId: string,
    data: {
      type:
        | "INSTAGRAM_REEL"
        | "YOUTUBE_SHORT"
        | "VIDEO"
        | "IMAGE"
        | "MATCH_HIGHLIGHT"
        | "LINK";
      title?: string;
      caption?: string;
      url: string;
      thumbnailUrl?: string;
      matchId?: string;
      isPinned?: boolean;
      sortOrder?: number;
    },
  ) {
    const profile = await this.getRequiredProfile(userId);
    if (data.matchId) {
      const match = await prisma.match.findUnique({
        where: { id: data.matchId },
        select: { id: true },
      });
      if (!match) throw Errors.notFound("Match");
    }

    const created = await prisma.profileShowcaseItem.create({
      data: {
        playerProfileId: profile.id,
        type: data.type,
        title: data.title?.trim() || null,
        caption: data.caption?.trim() || null,
        url: data.url.trim(),
        thumbnailUrl: data.thumbnailUrl?.trim() || null,
        matchId: data.matchId ?? null,
        isPinned: data.isPinned ?? false,
        sortOrder: data.sortOrder ?? 0,
      },
      include: {
        match: {
          select: {
            id: true,
            teamAName: true,
            teamBName: true,
            format: true,
            completedAt: true,
          },
        },
      },
    });

    return this.mapShowcaseItem(created);
  }

  async updateShowcaseItem(
    userId: string,
    itemId: string,
    data: {
      title?: string;
      caption?: string;
      url?: string;
      thumbnailUrl?: string | null;
      matchId?: string | null;
      isPinned?: boolean;
      isActive?: boolean;
      sortOrder?: number;
    },
  ) {
    const profile = await this.getRequiredProfile(userId);
    const existing = await prisma.profileShowcaseItem.findUnique({
      where: { id: itemId },
      select: { id: true, playerProfileId: true },
    });
    if (!existing || existing.playerProfileId !== profile.id)
      throw Errors.notFound("Showcase item");

    if (data.matchId) {
      const match = await prisma.match.findUnique({
        where: { id: data.matchId },
        select: { id: true },
      });
      if (!match) throw Errors.notFound("Match");
    }

    const updated = await prisma.profileShowcaseItem.update({
      where: { id: itemId },
      data: {
        title: data.title === undefined ? undefined : data.title.trim() || null,
        caption:
          data.caption === undefined ? undefined : data.caption.trim() || null,
        url: data.url === undefined ? undefined : data.url.trim(),
        thumbnailUrl:
          data.thumbnailUrl === undefined
            ? undefined
            : data.thumbnailUrl?.trim() || null,
        matchId: data.matchId === undefined ? undefined : data.matchId,
        isPinned: data.isPinned,
        isActive: data.isActive,
        sortOrder: data.sortOrder,
      },
      include: {
        match: {
          select: {
            id: true,
            teamAName: true,
            teamBName: true,
            format: true,
            completedAt: true,
          },
        },
      },
    });

    return this.mapShowcaseItem(updated);
  }

  async deleteShowcaseItem(userId: string, itemId: string) {
    const profile = await this.getRequiredProfile(userId);
    const existing = await prisma.profileShowcaseItem.findUnique({
      where: { id: itemId },
      select: { id: true, playerProfileId: true },
    });
    if (!existing || existing.playerProfileId !== profile.id)
      throw Errors.notFound("Showcase item");
    await prisma.profileShowcaseItem.delete({ where: { id: itemId } });
    return { deleted: true };
  }

  async followPlayer(userId: string, targetPlayerId: string) {
    const profile = await this.getRequiredProfile(userId);
    if (profile.id === targetPlayerId) {
      throw new AppError("INVALID_FOLLOW", "You cannot follow yourself", 400);
    }

    const target = await prisma.playerProfile.findUnique({
      where: { id: targetPlayerId },
      select: {
        id: true,
        userId: true,
        user: {
          select: { name: true },
        },
      },
    });
    if (!target) throw Errors.notFound("Player profile");

    await prisma.$transaction(async (tx) => {
      const existing = await tx.playerFollow.findUnique({
        where: {
          followerPlayerId_followingPlayerId: {
            followerPlayerId: profile.id,
            followingPlayerId: targetPlayerId,
          },
        },
      });

      if (!existing) {
        await tx.playerFollow.create({
          data: {
            followerPlayerId: profile.id,
            followingPlayerId: targetPlayerId,
          },
        });
      }

      const [myFollowingCount, targetFollowersCount] = await Promise.all([
        tx.playerFollow.count({
          where: { followerPlayerId: profile.id },
        }),
        tx.playerFollow.count({
          where: { followingPlayerId: targetPlayerId },
        }),
      ]);

      await Promise.all([
        tx.playerProfile.update({
          where: { id: profile.id },
          data: { followingCount: myFollowingCount },
        }),
        tx.playerProfile.update({
          where: { id: targetPlayerId },
          data: { followersCount: targetFollowersCount },
        }),
      ]);
    });

    await this.notificationService.createNotification(target.userId, {
      type: "NEW_FOLLOWER",
      title: "New follower",
      body: "Someone started following you",
      entityType: "PLAYER_PROFILE",
      entityId: profile.id,
      data: {
        followerPlayerId: profile.id,
      },
      preferenceKey: "newFollowers",
    });

    return { following: true };
  }

  async unfollowPlayer(userId: string, targetPlayerId: string) {
    const profile = await this.getRequiredProfile(userId);
    if (profile.id === targetPlayerId) {
      throw new AppError("INVALID_FOLLOW", "You cannot unfollow yourself", 400);
    }

    await prisma.$transaction(async (tx) => {
      await tx.playerFollow.deleteMany({
        where: {
          followerPlayerId: profile.id,
          followingPlayerId: targetPlayerId,
        },
      });

      const [myFollowingCount, targetFollowersCount] = await Promise.all([
        tx.playerFollow.count({
          where: { followerPlayerId: profile.id },
        }),
        tx.playerFollow.count({
          where: { followingPlayerId: targetPlayerId },
        }),
      ]);

      await Promise.all([
        tx.playerProfile.update({
          where: { id: profile.id },
          data: { followingCount: myFollowingCount },
        }),
        tx.playerProfile.updateMany({
          where: { id: targetPlayerId },
          data: { followersCount: targetFollowersCount },
        }),
      ]);
    });

    return { following: false };
  }

  async getFollowStatus(userId: string, targetPlayerId: string) {
    const profile = await this.getRequiredProfile(userId);
    if (profile.id === targetPlayerId) {
      return { following: false, isSelf: true };
    }

    const existing = await prisma.playerFollow.findUnique({
      where: {
        followerPlayerId_followingPlayerId: {
          followerPlayerId: profile.id,
          followingPlayerId: targetPlayerId,
        },
      },
    });

    return { following: Boolean(existing), isSelf: false };
  }

  async listFollowers(
    userId: string,
    playerProfileId: string | undefined,
    page: number,
    limit: number,
  ) {
    const profile = await this.getRequiredProfile(userId);
    const targetPlayerId = playerProfileId ?? profile.id;
    const { skip } = getPaginationParams({ page, limit });

    const [total, rows] = await Promise.all([
      prisma.playerFollow.count({
        where: { followingPlayerId: targetPlayerId },
      }),
      prisma.playerFollow.findMany({
        where: { followingPlayerId: targetPlayerId },
        orderBy: { createdAt: "desc" },
        skip,
        take: limit,
        include: {
          follower: {
            include: {
              user: { select: { name: true, avatarUrl: true } },
            },
          },
        },
      }),
    ]);

    const followerIpStateMap = await this.getIpStateMap(
      rows.map((row) => row.follower.id),
    );

    return {
      data: rows.map((row) =>
        this.buildSocialProfileSummary(
          row.follower,
          followerIpStateMap.get(row.follower.id) ?? null,
        ),
      ),
      meta: buildPaginationMeta(total, page, limit),
    };
  }

  async listFollowing(
    userId: string,
    playerProfileId: string | undefined,
    page: number,
    limit: number,
  ) {
    const profile = await this.getRequiredProfile(userId);
    const targetPlayerId = playerProfileId ?? profile.id;
    const { skip } = getPaginationParams({ page, limit });

    const [total, rows] = await Promise.all([
      prisma.playerFollow.count({
        where: { followerPlayerId: targetPlayerId },
      }),
      prisma.playerFollow.findMany({
        where: { followerPlayerId: targetPlayerId },
        orderBy: { createdAt: "desc" },
        skip,
        take: limit,
        include: {
          following: {
            include: {
              user: { select: { name: true, avatarUrl: true } },
            },
          },
        },
      }),
    ]);

    const followingIpStateMap = await this.getIpStateMap(
      rows.map((row) => row.following.id),
    );

    return {
      data: rows.map((row) =>
        this.buildSocialProfileSummary(
          row.following,
          followingIpStateMap.get(row.following.id) ?? null,
        ),
      ),
      meta: buildPaginationMeta(total, page, limit),
    };
  }

  async getIndex(userId: string) {
    const profile = await this.getRequiredProfile(userId);
    return this.performanceService.getPlayerIndex(profile.id);
  }

  async getIndexBreakdown(
    userId: string,
    axis: PlayerIndexAxis,
    window?: "MATCH" | "LAST_5" | "LAST_10" | "SEASON" | "LIFETIME",
  ) {
    const profile = await this.getRequiredProfile(userId);
    return this.performanceService.getPlayerIndexBreakdown(
      profile.id,
      axis,
      window ?? "LAST_10",
    );
  }

  async getPhysical(userId: string) {
    const profile = await this.getRequiredProfile(userId);
    return this.performanceService.getPlayerPhysical(profile.id);
  }

  async getRankConfig() {
    return this.performanceService.getRankConfigPayload();
  }

  async getSeason(userId: string) {
    const profile = await this.getRequiredProfile(userId);
    return this.performanceService.getPlayerSeason(profile.id);
  }

  async getTrainingPlans(userId: string) {
    const profile = await prisma.playerProfile.findUnique({
      where: { userId },
    });
    if (!profile) return { plans: [] };
    const plans = await prisma.trainingPlan.findMany({
      where: { playerProfileId: profile.id, isActive: true },
      include: { milestones: true },
      orderBy: { startDate: "desc" },
    });
    return {
      plans: plans.map((p) => ({
        id: p.id,
        name: p.title,
        description: p.description ?? "",
        totalDrills: p.milestones.length,
        completedDrills: p.milestones.filter((m) => m.isCompleted).length,
        drills: [],
        startDate: p.startDate.toISOString(),
        endDate: p.endDate?.toISOString() ?? null,
      })),
    };
  }

  async getFeedback(userId: string, page: number, limit: number) {
    const profile = await prisma.playerProfile.findUnique({
      where: { userId },
    });
    if (!profile)
      return { feedback: [], meta: buildPaginationMeta(0, page, limit) };
    const { skip } = getPaginationParams({ page, limit });
    const [items, total] = await Promise.all([
      prisma.coachFeedback.findMany({
        where: { playerProfileId: profile.id },
        include: {
          coach: {
            include: { user: { select: { name: true, avatarUrl: true } } },
          },
        },
        orderBy: { createdAt: "desc" },
        skip,
        take: limit,
      }),
      prisma.coachFeedback.count({ where: { playerProfileId: profile.id } }),
    ]);
    return {
      feedback: items.map((f) => ({
        id: f.id,
        coachName: f.coach.user.name ?? "Coach",
        coachAvatarUrl: f.coach.user.avatarUrl,
        content: f.feedbackText ?? "",
        timestamp: f.createdAt.toISOString(),
        type: f.tags[0] ?? "GENERAL",
      })),
      meta: buildPaginationMeta(total, page, limit),
    };
  }

  private async getTeamById(teamId: string, userId: string) {
    const team = await prisma.team.findUnique({ where: { id: teamId } });
    if (!team) throw Errors.notFound("Team");
    if (team.createdByUserId === userId) return team;

    // Also allow if user owns the academy / coach profile / arena linked to the team
    if ((team as any).academyId || (team as any).coachId || (team as any).arenaId) {
      const [academy, coach, arena] = await Promise.all([
        (team as any).academyId
          ? prisma.academy.findFirst({
              where: { id: (team as any).academyId, owner: { userId } },
              select: { id: true },
            })
          : null,
        (team as any).coachId
          ? prisma.coachProfile.findFirst({
              where: { id: (team as any).coachId, userId },
              select: { id: true },
            })
          : null,
        (team as any).arenaId
          ? prisma.arena.findFirst({
              where: { id: (team as any).arenaId, owner: { userId } },
              select: { id: true },
            })
          : null,
      ]);
      if (academy || coach || arena) return team;
    }

    throw Errors.forbidden();
  }

  private async resolvePlayerProfileId(idOrUserId: string): Promise<string> {
    const profile = await prisma.playerProfile.findFirst({
      where: { OR: [{ id: idOrUserId }, { userId: idOrUserId }] },
      select: { id: true },
    });
    if (!profile) throw Errors.notFound("Player profile not found");
    return profile.id;
  }

  async updateTeam(
    userId: string,
    teamId: string,
    data: {
      name?: string;
      shortName?: string;
      city?: string;
      teamType?: string;
      logoUrl?: string;
      captainId?: string;
      viceCaptainId?: string;
      wicketKeeperId?: string;
      isActive?: boolean;
    },
  ) {
    const team = await this.getTeamById(teamId, userId);

    const captainId =
      data.captainId !== undefined
        ? data.captainId
          ? await this.resolvePlayerProfileId(data.captainId)
          : null
        : team.captainId;

    const viceCaptainId =
      data.viceCaptainId !== undefined
        ? data.viceCaptainId
          ? await this.resolvePlayerProfileId(data.viceCaptainId)
          : null
        : (team as any).viceCaptainId;

    const wicketKeeperId =
      data.wicketKeeperId !== undefined
        ? data.wicketKeeperId
          ? await this.resolvePlayerProfileId(data.wicketKeeperId)
          : null
        : (team as any).wicketKeeperId;

    const updated = await prisma.team.update({
      where: { id: teamId },
      data: {
        name: data.name?.trim(),
        shortName: data.shortName?.trim(),
        city: data.city?.trim(),
        teamType: (data.teamType as any) || undefined,
        logoUrl: data.logoUrl,
        isActive: data.isActive,
        captainId,
        viceCaptainId,
        wicketKeeperId,
      },
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

    await this.performanceService.eliteAnalytics.recalculateTeamPowerScore(
      teamId,
    );
    return updated;
  }

  async deleteTeam(userId: string, teamId: string) {
    await this.getTeamById(teamId, userId);

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
    });
  }

  async removePlayerFromTeam(userId: string, teamId: string, playerId: string) {
    const team = await this.getTeamById(teamId, userId);
    const resolvedPlayerId = await this.resolvePlayerProfileId(playerId);

    const updated = await prisma.team.update({
      where: { id: teamId },
      data: {
        playerIds: team.playerIds.filter((id) => id !== resolvedPlayerId),
        captainId: team.captainId === resolvedPlayerId ? null : team.captainId,
        viceCaptainId:
          (team as any).viceCaptainId === resolvedPlayerId
            ? null
            : (team as any).viceCaptainId,
        wicketKeeperId:
          (team as any).wicketKeeperId === resolvedPlayerId
            ? null
            : (team as any).wicketKeeperId,
      },
    });

    await this.performanceService.eliteAnalytics.recalculateTeamPowerScore(
      teamId,
    );
    return updated;
  }

  async getReportCards(userId: string) {    const profile = await prisma.playerProfile.findUnique({
      where: { userId },
    });
    if (!profile) return { reportCards: [] };
    const cards = await prisma.reportCard.findMany({
      where: { playerProfileId: profile.id, isPublished: true },
      orderBy: [{ periodYear: "desc" }, { periodMonth: "desc" }],
    });
    const monthNames = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return {
      reportCards: cards.map((c) => ({
        id: c.id,
        month: `${monthNames[(c.periodMonth - 1) % 12]} ${c.periodYear}`,
        overallScore: c.swingIndexEnd,
        categoryScores: {
          attendance: c.attendanceRate,
          drillCompletion: c.drillCompletion,
        },
        summary: c.coachNarrative ?? "",
        highlights: c.strengthsNote ? [c.strengthsNote] : [],
        improvements: c.focusAreasNote ? [c.focusAreasNote] : [],
      })),
    };
  }

  async createTeam(
    userId: string,
    data: {
      name: string;
      shortName?: string;
      city?: string;
      teamType?: string;
      iAmCaptain?: boolean;
      academyId?: string;
      coachId?: string;
      arenaId?: string;
      motto?: string;
      homeGroundName?: string;
      foundedYear?: number;
      ageGroup?: string;
      format?: string;
      skillLevel?: string;
      isPublic?: boolean;
    },
  ) {
    const profile = await this.getOrCreateProfile(userId);
    const captainId = data.iAmCaptain ? profile.id : null;
    const team = await prisma.team.create({
      data: {
        name: data.name.trim(),
        shortName: data.shortName?.trim() || null,
        city: data.city?.trim() || null,
        teamType: (data.teamType as any) || "FRIENDLY",
        captainId,
        playerIds: [profile.id],
        createdByUserId: userId,
        academyId: data.academyId || null,
        coachId: data.coachId || null,
        arenaId: data.arenaId || null,
        motto: data.motto?.trim() || null,
        homeGroundName: data.homeGroundName?.trim() || null,
        foundedYear: data.foundedYear ?? null,
        ageGroup: data.ageGroup || null,
        format: data.format || null,
        skillLevel: data.skillLevel || null,
        isPublic: data.isPublic !== false,
      },
    });
    await this.performanceService.eliteAnalytics.recalculateTeamPowerScore(
      team.id,
    );
    return team;
  }

  async getMyTeams(userId: string) {
    const profile = await prisma.playerProfile.findUnique({ where: { userId } });

    // Collect IDs of entities this user owns
    const [academies, coachProfile, arenas] = await Promise.all([
      prisma.academy.findMany({
        where: { owner: { userId }, isActive: true },
        select: { id: true },
      }),
      prisma.coachProfile.findUnique({ where: { userId }, select: { id: true } }),
      prisma.arena.findMany({
        where: { owner: { userId }, isActive: true },
        select: { id: true },
      }),
    ]);

    const academyIds = academies.map((a) => a.id);
    const arenaIds   = arenas.map((a) => a.id);

    const orClauses: any[] = [
      { createdByUserId: userId },
      ...(academyIds.length ? [{ academyId: { in: academyIds } }] : []),
      ...(coachProfile     ? [{ coachId: coachProfile.id }]        : []),
      ...(arenaIds.length  ? [{ arenaId: { in: arenaIds } }]       : []),
      ...(profile          ? [{ playerIds: { has: profile.id } }]  : []),
    ];

    const teams = await prisma.team.findMany({
      where: { OR: orClauses, isActive: true },
      orderBy: { createdAt: "desc" },
    });

    if (teams.length === 0) return { teams: [] };

    const allPlayerIds = Array.from(new Set(teams.flatMap((t) => t.playerIds as string[])));
    const players = await prisma.playerProfile.findMany({
      where: { id: { in: allPlayerIds } },
      include: {
        user: {
          select: { id: true, name: true, avatarUrl: true, phone: true },
        },
      },
    });
    const playerMap = new Map(players.map((p) => [p.id, p]));

    return {
      teams: teams.map((team) => {
        const teamPlayers = team.playerIds
          .map((id) => playerMap.get(id))
          .filter(Boolean);
        return {
          ...team,
          players: teamPlayers,
          roleAssignments: {
            captain: team.captainId
              ? (playerMap.get(team.captainId) ?? null)
              : null,
            viceCaptain: (team as any).viceCaptainId
              ? (playerMap.get((team as any).viceCaptainId) ?? null)
              : null,
            wicketKeeper: (team as any).wicketKeeperId
              ? (playerMap.get((team as any).wicketKeeperId) ?? null)
              : null,
          },
        };
      }),
    };
  }

  async getTeamPlayers(teamId: string) {
    const team = await prisma.team.findUnique({
      where: { id: teamId },
      select: {
        playerIds: true,
        name: true,
        captainId: true,
        viceCaptainId: true,
        wicketKeeperId: true,
      },
    });

    // Fallback: check if this is a TournamentTeam id
    if (!team) {
      const tournamentTeam = await prisma.tournamentTeam.findUnique({
        where: { id: teamId },
        select: { playerIds: true, captainId: true, teamName: true },
      });
      if (!tournamentTeam) return { players: [] };
      const profiles = await prisma.playerProfile.findMany({
        where: { id: { in: tournamentTeam.playerIds } },
        include: { user: { select: { id: true, name: true, avatarUrl: true } } },
      });
      return {
        players: profiles.map((p) => ({
          profileId: p.id,
          userId: p.userId,
          name: p.user?.name ?? p.id,
          avatarUrl: p.user?.avatarUrl ?? null,
          swingId: this.buildSwingId(p.id),
        })),
        roleAssignments: {
          captainId: tournamentTeam.captainId ?? null,
          viceCaptainId: null,
          wicketKeeperId: null,
        },
      };
    }

    const profiles = await prisma.playerProfile.findMany({
      where: { id: { in: team.playerIds } },
      include: { user: { select: { id: true, name: true, avatarUrl: true } } },
    });
    return {
      players: profiles.map((p) => ({
        profileId: p.id,
        userId: p.userId,
        name: p.user?.name ?? p.id,
        avatarUrl: p.user?.avatarUrl ?? null,
        swingId: this.buildSwingId(p.id),
      })),
      roleAssignments: {
        captainId: team.captainId ?? null,
        viceCaptainId: team.viceCaptainId ?? null,
        wicketKeeperId: team.wicketKeeperId ?? null,
      },
    };
  }

  async quickAddToTeam(
    teamId: string,
    data: {
      profileId?: string;
      name?: string;
      phone?: string;
      swingId?: string;
    },
  ) {
    const team = await prisma.team.findUnique({ where: { id: teamId } });
    if (!team) throw new Error("Team not found");

    const addProfileToTeam = async (
      profile: {
        id: string;
        userId: string;
        user: {
          name: string;
          avatarUrl: string | null;
        } | null;
      },
      matchedBy: "profileId" | "phone" | "swingId",
      extra: Record<string, unknown> = {},
    ) => {
      const alreadyInTeam = team.playerIds.includes(profile.id);
      if (!alreadyInTeam) {
        await prisma.team.update({
          where: { id: teamId },
          data: { playerIds: { push: profile.id } },
        });
        await this.performanceService.eliteAnalytics.recalculateTeamPowerScore(
          teamId,
        );
      }

      return {
        added: !alreadyInTeam,
        alreadyInTeam,
        matchedBy,
        profileId: profile.id,
        userId: profile.userId,
        name: profile.user?.name ?? profile.id,
        avatarUrl: profile.user?.avatarUrl ?? null,
        swingId: this.buildSwingId(profile.id),
        ...extra,
      };
    };

    if (data.profileId) {
      const profile = await prisma.playerProfile.findUnique({
        where: { id: data.profileId },
        include: { user: { select: { name: true, avatarUrl: true } } },
      });
      if (!profile) throw new Error("Player profile not found");
      return addProfileToTeam(profile, "profileId");
    }

    if (data.swingId) {
      const swingLookupKey = this.extractSwingLookupKey(data.swingId);
      if (!swingLookupKey || swingLookupKey.length < 3) {
        throw new Error("Invalid Swing ID");
      }

      const profile = await prisma.playerProfile.findFirst({
        where: { id: { startsWith: swingLookupKey } },
        include: { user: { select: { name: true, avatarUrl: true } } },
      });
      if (!profile) throw new Error("Player not found for this Swing ID");
      return addProfileToTeam(profile, "swingId");
    }

    if (data.phone) {
      const normalizedPhone = normalizePhone(data.phone);
      let user = await prisma.user.findUnique({
        where: { phone: normalizedPhone },
      });
      const matchedExistingUser = !!user;
      let createdUser = false;

      if (!user) {
        createdUser = true;
        user = await prisma.user.create({
          data: {
            phone: normalizedPhone,
            name: data.name?.trim() || normalizedPhone,
            roles: ["PLAYER"],
            activeRole: "PLAYER",
          },
        });
      } else if (
        data.name?.trim() &&
        (user.name.trim() === user.phone ||
          user.name.trim() === normalizedPhone)
      ) {
        user = await prisma.user.update({
          where: { id: user.id },
          data: { name: data.name.trim() },
        });
      }

      let profile = await prisma.playerProfile.findUnique({
        where: { userId: user.id },
        include: { user: { select: { name: true, avatarUrl: true } } },
      });
      if (!profile) {
        const createdProfile = await prisma.playerProfile.create({
          data: { userId: user.id },
        });
        profile = await prisma.playerProfile.findUnique({
          where: { id: createdProfile.id },
          include: { user: { select: { name: true, avatarUrl: true } } },
        });
      }
      if (!profile) throw new Error("Player profile not found");

      return addProfileToTeam(profile, "phone", {
        normalizedPhone,
        matchedExistingUser,
        createdUser,
      });
    }

    // Name-only placeholder (unlinked)
    if (data.name) {
      return {
        added: true,
        name: data.name,
        profileId: null,
        matchedBy: "name",
      };
    }

    throw new Error("Either profileId, phone, swingId, or name is required");
  }

  async searchTeamsWithFilters(
    query: string,
    limit = 20,
    filters?: {
      city?: string;
      teamType?:
        | "CLUB"
        | "CORPORATE"
        | "ACADEMY"
        | "SCHOOL"
        | "COLLEGE"
        | "DISTRICT"
        | "STATE"
        | "NATIONAL"
        | "FRIENDLY"
        | "GULLY";
    },
  ) {
    const trimmedQuery = query.trim();
    const where: any = { isActive: true };
    const andFilters: any[] = [];

    if (trimmedQuery) {
      andFilters.push({
        OR: [
          { name: { contains: trimmedQuery, mode: "insensitive" } },
          { shortName: { contains: trimmedQuery, mode: "insensitive" } },
          { city: { contains: trimmedQuery, mode: "insensitive" } },
        ],
      });
    }

    if (filters?.city) {
      andFilters.push({
        city: { contains: filters.city, mode: "insensitive" },
      });
    }

    if (filters?.teamType) {
      andFilters.push({ teamType: filters.teamType as any });
    }

    if (andFilters.length > 0) {
      where.AND = andFilters;
    }

    const teams = await prisma.team.findMany({
      where,
      orderBy: { createdAt: "desc" },
      take: limit,
      select: {
        id: true,
        name: true,
        shortName: true,
        city: true,
        playerIds: true,
        teamType: true,
        logoUrl: true,
        powerScore: true,
      },
    });
    return teams.map((t) => ({
      id: t.id,
      name: t.name,
      shortName: t.shortName ?? null,
      city: t.city ?? null,
      teamType: t.teamType,
      logoUrl: t.logoUrl ?? null,
      memberCount: t.playerIds.length,
      powerScore: t.powerScore,
    }));
  }

  async searchTeams(query: string, limit = 20) {
    const teams = await this.searchTeamsWithFilters(query, limit);
    return { teams };
  }

  async searchVenues(
    query: string,
    limit = 20,
    filters?: {
      city?: string;
    },
  ) {
    const trimmedQuery = query.trim();
    const andFilters: any[] = [];

    if (trimmedQuery) {
      andFilters.push({
        OR: [
          { name: { contains: trimmedQuery, mode: "insensitive" } },
          { city: { contains: trimmedQuery, mode: "insensitive" } },
          { address: { contains: trimmedQuery, mode: "insensitive" } },
        ],
      });
    }

    if (filters?.city) {
      andFilters.push({
        city: { contains: filters.city, mode: "insensitive" },
      });
    }

    const venues = await prisma.venue.findMany({
      where: andFilters.length > 0 ? { AND: andFilters } : undefined,
      orderBy: { name: "asc" },
      take: limit,
      select: {
        id: true,
        name: true,
        city: true,
        address: true,
        aliases: true,
      },
    });

    return venues.map((venue) => ({
      id: venue.id,
      name: venue.name,
      city: venue.city ?? null,
      address: venue.address ?? null,
      aliases: venue.aliases,
    }));
  }

  async getGigBookings(userId: string, page: number, limit: number) {
    const profile = await prisma.playerProfile.findUnique({
      where: { userId },
    });
    if (!profile)
      return { data: [], meta: buildPaginationMeta(0, page, limit) };
    const { skip } = getPaginationParams({ page, limit });
    const [data, total] = await Promise.all([
      prisma.gigBooking.findMany({
        where: { playerProfileId: profile.id },
        include: { gigListing: { select: { title: true, sport: true } } },
        orderBy: { scheduledAt: "desc" },
        skip,
        take: limit,
      }),
      prisma.gigBooking.count({ where: { playerProfileId: profile.id } }),
    ]);
    return { data, meta: buildPaginationMeta(total, page, limit) };
  }

  async getGlobalLeaderboard(page = 1, limit = 20) {
    const { skip } = getPaginationParams({ page, limit });
    const take = limit;

    const rows = await prisma.$queryRaw<
      Array<{
        playerId: string;
        name: string;
        avatarUrl: string | null;
        lifetimeIp: number;
        currentRankKey: string;
      }>
    >`
      SELECT
        ips."playerId",
        u."name",
        u."avatarUrl",
        ips."lifetimeIp" as "lifetimeIp",
        ips."currentRankKey" as "currentRankKey"
      FROM public.ip_player_state ips
      JOIN public."PlayerProfile" pp ON pp.id = ips."playerId"
      JOIN public."User" u ON u.id = pp."userId"
      ORDER BY ips."lifetimeIp" DESC, ips."playerId" ASC
      LIMIT ${take} OFFSET ${skip}
    `;

    const totalCount = await prisma.playerProfile.count();

    const data = rows.map((row) => ({
      playerId: row.playerId,
      name: row.name,
      avatarUrl: row.avatarUrl,
      impactPoints: row.lifetimeIp,
      rank: row.currentRankKey,
      profileUrl: `https://swing-cricket.com/player/${row.playerId}`,
    }));

    return {
      data,
      meta: buildPaginationMeta(Number(totalCount), page, limit),
    };
  }

  async getRecommendedFollows(userId: string, limit = 10) {
    const profile = await prisma.playerProfile.findUnique({
      where: { userId },
      select: { id: true },
    });

    if (!profile) return [];

    // Find all players from the last 5 matches this user participated in
    const recentMatchIds = await prisma.matchPlayerFact.findMany({
      where: { playerId: profile.id },
      select: { matchId: true },
      orderBy: { matchDate: "desc" },
      take: 5,
    });

    if (recentMatchIds.length === 0) return [];

    const matchIds = recentMatchIds.map((m) => m.matchId);

    const rows = await prisma.$queryRaw<
      Array<{
        playerId: string;
        name: string;
        avatarUrl: string | null;
        lifetimeIp: number;
        currentRankKey: string;
      }>
    >`
      SELECT DISTINCT ON (pp.id)
        pp.id as "playerId",
        u."name",
        u."avatarUrl",
        COALESCE(ips."lifetimeIp", 0) as "lifetimeIp",
        COALESCE(ips."currentRankKey", 'ROOKIE') as "currentRankKey"
      FROM public.match_player_facts mpf
      JOIN public."PlayerProfile" pp ON pp.id = mpf."playerId"
      JOIN public."User" u ON u.id = pp."userId"
      LEFT JOIN public.ip_player_state ips ON ips."playerId" = pp.id
      WHERE mpf."matchId" IN (${Prisma.join(matchIds)})
        AND pp.id != ${profile.id}
        AND pp.id NOT IN (
          SELECT "followingPlayerId"
          FROM public.player_follows
          WHERE "followerPlayerId" = ${profile.id}
        )
      ORDER BY pp.id, ips."lifetimeIp" DESC
      LIMIT ${limit}
    `;

    return rows.map((row) => ({
      playerId: row.playerId,
      name: row.name,
      avatarUrl: row.avatarUrl,
      impactPoints: row.lifetimeIp,
      rank: row.currentRankKey,
      profileUrl: `https://swing-cricket.com/player/${row.playerId}`,
    }));
  }
}
