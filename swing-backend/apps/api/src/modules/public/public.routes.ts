import type { FastifyInstance } from "fastify";
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { prisma, Prisma } from "@swing/db";
import { z } from "zod";
import { getStudioScene } from "../../lib/redis";
import { buildInningsPlayerStats } from "../matches/match-stats";
import { OverlayPackService } from "../overlays/overlay-pack.service";
import { NotificationService } from "../notifications/notification.service";
import { PhonePeService } from "../payments/phonepe.service";

const notificationSvc = new NotificationService();

type IndianCityRecord = {
  id?: string;
  name: string;
  state: string;
};

type PublicCitySuggestion = {
  city: string;
  state: string;
};

const cityDatasetPath = (() => {
  const candidates = [
    join(process.cwd(), "src/modules/public/data/indian-cities.json"),
    join(process.cwd(), "apps/api/src/modules/public/data/indian-cities.json"),
    join(__dirname, "data", "indian-cities.json"),
  ];

  for (const filePath of candidates) {
    if (existsSync(filePath)) return filePath;
  }

  return null;
})();

const indianCities: PublicCitySuggestion[] = (() => {
  if (!cityDatasetPath) return [];

  const parsed = JSON.parse(
    readFileSync(cityDatasetPath, "utf-8"),
  ) as IndianCityRecord[];
  const seen = new Set<string>();
  const suggestions: PublicCitySuggestion[] = [];

  for (const item of parsed) {
    const city = item.name?.trim();
    const state = item.state?.trim();
    if (!city || !state) continue;

    const dedupeKey = `${city.toLowerCase()}|${state.toLowerCase()}`;
    if (seen.has(dedupeKey)) continue;

    seen.add(dedupeKey);
    suggestions.push({ city, state });
  }

  return suggestions.sort((a, b) =>
    a.city.localeCompare(b.city, "en", { sensitivity: "base" }) ||
    a.state.localeCompare(b.state, "en", { sensitivity: "base" }),
  );
})();

const overlayPackService = new OverlayPackService();
const phonePeService = new PhonePeService();

const overlayLogoAsset = (() => {
  const candidates = [
    join(process.cwd(), "src/modules/public/assets/swing-overlay-logo.svg"),
    join(process.cwd(), "src/modules/public/assets/swing-overlay-logo.png"),
    join(
      process.cwd(),
      "apps/api/src/modules/public/assets/swing-overlay-logo.svg",
    ),
    join(
      process.cwd(),
      "apps/api/src/modules/public/assets/swing-overlay-logo.png",
    ),
    join(__dirname, "assets", "swing-overlay-logo.svg"),
    join(__dirname, "assets", "swing-overlay-logo.png"),
  ];

  for (const filePath of candidates) {
    if (existsSync(filePath)) {
      return {
        filePath,
        mimeType: filePath.endsWith(".svg") ? "image/svg+xml" : "image/png",
      };
    }
  }

  return null;
})();

export async function publicRoutes(app: FastifyInstance) {
  const normalizeName = (value: string) => value.trim().toLowerCase();
  const canonicalName = (value: string) =>
    normalizeName(value).replace(/[^a-z0-9]/g, "");
  const scoreCityMatch = (query: string, entry: PublicCitySuggestion) => {
    const target = canonicalName(query);
    const city = canonicalName(entry.city);
    const state = canonicalName(entry.state);
    const combined = canonicalName(`${entry.city} ${entry.state}`);

    if (!target) return 0;
    if (city === target) return 100;
    if (combined === target) return 95;
    if (city.startsWith(target)) return 80;
    if (combined.startsWith(target)) return 75;
    if (city.includes(target)) return 60;
    if (state.startsWith(target)) return 45;
    if (state.includes(target) || combined.includes(target)) return 30;
    return -1;
  };
  const teamAliases = (value: string) => {
    const cleaned = value.trim();
    const strippedNumbers = cleaned.replace(/\b\d+\b/g, "").trim();
    const firstSegment = cleaned.split("-")[0]?.trim() ?? cleaned;
    const firstWord = cleaned.split(/\s+/)[0] ?? cleaned;

    return [...new Set([cleaned, strippedNumbers, firstSegment, firstWord])]
      .map((item) => item.trim())
      .filter(Boolean);
  };
  const scoreTeamMatch = (
    target: string,
    candidate: { name: string; shortName?: string | null },
  ) => {
    const targetCanonical = canonicalName(target);
    const candidateNameCanonical = canonicalName(candidate.name);
    const candidateShortCanonical = canonicalName(candidate.shortName ?? "");

    if (!targetCanonical) return -1;
    if (
      targetCanonical === candidateNameCanonical ||
      (candidateShortCanonical && targetCanonical === candidateShortCanonical)
    ) {
      return 100;
    }
    if (
      candidateNameCanonical.startsWith(targetCanonical) ||
      targetCanonical.startsWith(candidateNameCanonical)
    ) {
      return 80;
    }
    if (
      candidateShortCanonical &&
      (candidateShortCanonical.startsWith(targetCanonical) ||
        targetCanonical.startsWith(candidateShortCanonical))
    ) {
      return 75;
    }
    if (
      candidateNameCanonical.includes(targetCanonical) ||
      targetCanonical.includes(candidateNameCanonical)
    ) {
      return 60;
    }
    if (
      candidateShortCanonical &&
      (candidateShortCanonical.includes(targetCanonical) ||
        targetCanonical.includes(candidateShortCanonical))
    ) {
      return 55;
    }
    return -1;
  };
  const formatPlayerMatchSummary = (stats: {
    runs: number;
    balls: number;
    wickets: number;
    runsConceded: number;
    oversBowled: number;
    catches: number;
    stumpings: number;
    runOuts: number;
  }) => {
    const parts: string[] = [];
    if (stats.runs > 0) {
      parts.push(`${stats.runs}${stats.balls > 0 ? ` (${stats.balls})` : ""}`);
    }
    if (stats.wickets > 0 || stats.oversBowled > 0) {
      const overs =
        stats.oversBowled > 0 ? ` in ${stats.oversBowled.toFixed(1)} ov` : "";
      parts.push(`${stats.wickets}/${stats.runsConceded}${overs}`);
    }
    if (stats.catches > 0) {
      parts.push(`${stats.catches} catch${stats.catches === 1 ? "" : "es"}`);
    }
    if (stats.stumpings > 0) {
      parts.push(
        `${stats.stumpings} stumping${stats.stumpings === 1 ? "" : "s"}`,
      );
    }
    if (stats.runOuts > 0) {
      parts.push(`${stats.runOuts} run out${stats.runOuts === 1 ? "" : "s"}`);
    }
    return parts.join(" · ");
  };

  app.get("/cities", async (request, reply) => {
    const query = z
      .object({
        q: z.string().trim().max(100).optional(),
        limit: z.coerce.number().int().min(1).max(50).optional(),
      })
      .parse(request.query);

    const q = query.q?.trim() ?? "";
    const limit = query.limit ?? 20;

    const results = (q
      ? indianCities
          .map((entry) => ({ entry, score: scoreCityMatch(q, entry) }))
          .filter((item) => item.score >= 0)
          .sort(
            (a, b) =>
              b.score - a.score ||
              a.entry.city.localeCompare(b.entry.city, "en", {
                sensitivity: "base",
              }) ||
              a.entry.state.localeCompare(b.entry.state, "en", {
                sensitivity: "base",
              }),
          )
          .map((item) => item.entry)
      : indianCities
    ).slice(0, limit);

    return reply.send({
      success: true,
      data: {
        items: results,
        total: results.length,
        query: q,
      },
    });
  });

  // GET /public/tournaments?status=ONGOING|UPCOMING|COMPLETED&q=search&format=T20&city=Mumbai
  app.get("/tournaments", async (request, reply) => {
    const { status, q, format, city } = request.query as {
      status?: string;
      q?: string;
      format?: string;
      city?: string;
    };

    const where: Record<string, unknown> = { isPublic: true };
    if (status) where.status = status.toUpperCase();
    if (format) where.format = format.toUpperCase();
    if (city) where.city = { contains: city.trim(), mode: "insensitive" };
    if (q) where.name = { contains: q, mode: "insensitive" };

    const tournaments = await prisma.tournament.findMany({
      where,
      select: {
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
        ballType: true,
        earlyBirdDeadline: true,
        earlyBirdFee: true,
        _count: { select: { teams: { where: { isConfirmed: true } } } },
      },
      orderBy: [
        { status: "asc" },
        { startDate: "asc" },
      ],
    });
    return reply.send({ data: tournaments });
  });

  // GET /public/tournament/:slug
  app.get("/tournament/:slug", async (request, reply) => {
    const { slug } = request.params as { slug: string };
    const t = await prisma.tournament.findFirst({
      where: { OR: [{ slug }, { id: slug }], isPublic: true },
      include: {
        teams: {
          orderBy: { registeredAt: "asc" },
          include: {
            team: {
              select: {
                name: true,
                shortName: true,
                logoUrl: true,
              },
            },
          },
        },
        groups: { include: { teams: true }, orderBy: { groupOrder: "asc" } },
        standings: { orderBy: { points: "desc" } },
        academy: { select: { name: true } },
        createdBy: { select: { name: true } },
      },
    });
    if (!t) return reply.status(404).send({ error: "Tournament not found" });
    return reply.send({ data: t });
  });

  // GET /public/tournament/:slug/matches
  app.get("/tournament/:slug/matches", async (request, reply) => {
    const { slug } = request.params as { slug: string };
    const t = await prisma.tournament.findFirst({
      where: { OR: [{ slug }, { id: slug }], isPublic: true },
      select: { id: true },
    });
    if (!t) return reply.status(404).send({ error: "Tournament not found" });

    const [matches, tournamentTeams] = await Promise.all([
      prisma.match.findMany({
        where: { tournamentId: t.id },
        include: {
          innings: {
            select: {
              inningsNumber: true,
              battingTeam: true,
              totalRuns: true,
              totalWickets: true,
              totalOvers: true,
              isCompleted: true,
            },
          },
        },
        orderBy: { scheduledAt: "asc" },
      }),
      prisma.tournamentTeam.findMany({
        where: { tournamentId: t.id },
        select: {
          teamName: true,
          groupId: true,
          group: { select: { name: true } },
        },
      }),
    ]);

    // build teamName → groupName map
    const teamGroupMap = new Map<string, string>();
    for (const tt of tournamentTeams) {
      if (tt.groupId && tt.group?.name) {
        teamGroupMap.set(tt.teamName, tt.group.name);
      }
    }

    const enriched = matches.map((m) => ({
      ...m,
      groupName:
        teamGroupMap.get(m.teamAName) ?? teamGroupMap.get(m.teamBName) ?? null,
    }));

    return reply.send({ data: enriched });
  });

  // GET /public/match/:id — live/public match scorecard
  app.get("/match/:id", async (request, reply) => {
    const { id } = request.params as { id: string };
    const match = await prisma.match.findUnique({
      where: { id },
      include: {
        innings: {
          orderBy: { inningsNumber: "asc" },
          include: {
            ballEvents: {
              orderBy: [{ overNumber: "asc" }, { ballNumber: "asc" }],
            },
          },
        },
      },
    });
    if (!match) return reply.status(404).send({ error: "Match not found" });

    const ballEventPlayerIds: string[] = [];
    for (const innings of match.innings) {
      for (const ball of innings.ballEvents) {
        ballEventPlayerIds.push(ball.batterId, ball.bowlerId);
        if (ball.fielderId) ballEventPlayerIds.push(ball.fielderId);
        if (ball.dismissedPlayerId)
          ballEventPlayerIds.push(ball.dismissedPlayerId);
      }
    }
    const allPlayerIds = [
      ...new Set([
        ...match.teamAPlayerIds,
        ...match.teamBPlayerIds,
        ...ballEventPlayerIds,
      ]),
    ];
    const searchTerms = [
      ...new Set([
        ...teamAliases(match.teamAName),
        ...teamAliases(match.teamBName),
      ]),
    ];
    const [profiles, teams, playerMatchStats, tournament] = await Promise.all([
      allPlayerIds.length
        ? prisma.playerProfile.findMany({
            where: {
              OR: [
                { id: { in: allPlayerIds } },
                { userId: { in: allPlayerIds } },
              ],
            },
            include: { user: { select: { name: true } } },
          })
        : Promise.resolve([]),
      searchTerms.length > 0
        ? prisma.team.findMany({
            where: {
              OR: searchTerms.flatMap((term) => [
                { name: { contains: term, mode: "insensitive" as const } },
                { shortName: { contains: term, mode: "insensitive" as const } },
              ]),
            },
            select: {
              name: true,
              shortName: true,
              logoUrl: true,
            },
            take: 20,
          })
        : Promise.resolve([]),
      prisma.playerMatchStats.findMany({
        where: { matchId: id },
        include: {
          playerProfile: {
            include: {
              user: {
                select: {
                  name: true,
                  avatarUrl: true,
                },
              },
            },
          },
        },
      }),
      match.tournamentId
        ? prisma.tournament.findUnique({
            where: { id: match.tournamentId },
            select: {
              id: true,
              name: true,
              slug: true,
              logoUrl: true,
            },
          })
        : Promise.resolve(null),
    ]);

    const nameMap = new Map<string, string>();
    for (const p of profiles) {
      nameMap.set(p.id, p.user.name);
      nameMap.set(p.userId, p.user.name);
    }

    const resolveTeam = (target: string) =>
      teams
        .map((team) => ({ team, score: scoreTeamMatch(target, team) }))
        .filter((entry) => entry.score >= 0)
        .sort((a, b) => b.score - a.score)[0]?.team ?? null;

    const topStat =
      playerMatchStats.find((stats) => stats.isManOfMatch) ??
      [...playerMatchStats].sort((a, b) => {
        const aScore =
          a.runs +
          a.wickets * 25 +
          a.catches * 8 +
          a.stumpings * 10 +
          a.runOuts * 8;
        const bScore =
          b.runs +
          b.wickets * 25 +
          b.catches * 8 +
          b.stumpings * 10 +
          b.runOuts * 8;
        return bScore - aScore;
      })[0];
    const playerOfTheMatch = topStat
      ? {
          id: topStat.playerProfileId,
          name: topStat.playerProfile.user.name,
          avatarUrl: topStat.playerProfile.user.avatarUrl,
          team:
            topStat.team === "A"
              ? match.teamAName
              : topStat.team === "B"
                ? match.teamBName
                : topStat.team,
          summary:
            formatPlayerMatchSummary(topStat) ||
            `${topStat.playerProfile.user.name} influenced the game.`,
        }
      : null;

    return reply.send({
      data: {
        ...match,
        playerNames: Object.fromEntries(nameMap),
        competition: tournament,
        playerOfTheMatch,
        teamMeta: {
          A: resolveTeam(match.teamAName),
          B: resolveTeam(match.teamBName),
        },
      },
    });
  });

  // ---------------------------------------------------------------------------
  // OBS / Streaming overlay endpoints
  // ---------------------------------------------------------------------------

  const overlayFormatOvers: Record<string, number> = {
    T10: 10,
    T20: 20,
    ONE_DAY: 50,
    BOX_CRICKET: 6,
    CUSTOM: 20,
    TWO_INNINGS: 90,
    TEST: 90,
  };

  const buildOverlayState = async (matchId: string) => {
    const match = await prisma.match.findUnique({
      where: { id: matchId },
      include: {
        innings: {
          orderBy: { inningsNumber: "asc" },
          include: {
            ballEvents: {
              orderBy: [{ overNumber: "asc" }, { ballNumber: "asc" }],
            },
          },
        },
      },
    });

    if (!match) return null;

    // Try exact name match first for each team (most reliable), then fuzzy fallback
    const [teamAExact, teamBExact] = await Promise.all([
      prisma.team.findFirst({
        where: { name: { equals: match.teamAName, mode: "insensitive" } },
        select: { name: true, shortName: true, logoUrl: true },
      }),
      prisma.team.findFirst({
        where: { name: { equals: match.teamBName, mode: "insensitive" } },
        select: { name: true, shortName: true, logoUrl: true },
      }),
    ]);

    let teamAMeta = teamAExact ?? null;
    let teamBMeta = teamBExact ?? null;

    // Fuzzy fallback for any team without an exact match
    if (!teamAMeta || !teamBMeta) {
      const missingNames = [
        ...(!teamAMeta ? teamAliases(match.teamAName) : []),
        ...(!teamBMeta ? teamAliases(match.teamBName) : []),
      ];
      const logoSearchTerms = [...new Set(missingNames)];

      const logoTeams = logoSearchTerms.length
        ? await prisma.team.findMany({
            where: {
              OR: logoSearchTerms.flatMap((term) => [
                { name: { contains: term, mode: "insensitive" as const } },
                { shortName: { contains: term, mode: "insensitive" as const } },
              ]),
            },
            select: { name: true, shortName: true, logoUrl: true },
            take: 30,
          })
        : [];

      const resolveLogoTeam = (target: string) =>
        logoTeams
          .map((team) => ({ team, score: scoreTeamMatch(target, team) }))
          .filter((entry) => entry.score >= 0)
          .sort((a, b) => b.score - a.score)[0]?.team ?? null;

      if (!teamAMeta) teamAMeta = resolveLogoTeam(match.teamAName);
      if (!teamBMeta) teamBMeta = resolveLogoTeam(match.teamBName);
    }

    const makeShortName = (name: string, fallback?: string | null) => {
      if (fallback?.trim()) return fallback.trim().toUpperCase();

      const aliases = teamAliases(name);
      const cleanAlias =
        aliases.find((item) => /^[a-z0-9 ]+$/i.test(item.trim())) ??
        aliases[2] ??
        aliases[1] ??
        aliases[0] ??
        name;

      const compact = cleanAlias.replace(/[^a-z0-9]/gi, "").toUpperCase();
      if (compact && compact.length <= 6) return compact;

      const initials = cleanAlias
        .split(/\s+/)
        .map((part) => part[0] ?? "")
        .join("")
        .toUpperCase();

      return (initials || compact || cleanAlias.slice(0, 4)).slice(0, 4);
    };

    const teamAShortName = makeShortName(match.teamAName, teamAMeta?.shortName);
    const teamBShortName = makeShortName(match.teamBName, teamBMeta?.shortName);
    const teamALogoUrl = teamAMeta?.logoUrl ?? null;
    const teamBLogoUrl = teamBMeta?.logoUrl ?? null;

    const inningsSummary = match.innings.map((innings) => ({
      inningsNumber: innings.inningsNumber,
      teamKey: innings.battingTeam,
      team: innings.battingTeam === "A" ? match.teamAName : match.teamBName,
      shortName:
        innings.battingTeam === "A"
          ? teamAShortName
          : teamBShortName,
      score: `${innings.totalRuns}/${innings.totalWickets}`,
      overs: Number(innings.totalOvers.toFixed(1)),
      isCompleted: innings.isCompleted,
    }));

    const tossSummary =
      match.tossWonBy && match.tossDecision
        ? `${
            match.tossWonBy === "A" ? match.teamAName : match.teamBName
          } won the toss and chose to ${String(match.tossDecision).toLowerCase()}`
        : null;

    const resultText = (() => {
      if (match.status !== "COMPLETED") return null;

      const winnerToken = String(match.winnerId ?? "")
        .trim()
        .toUpperCase();
      if (
        winnerToken === "A" ||
        normalizeName(match.winnerId ?? "") === normalizeName(match.teamAName)
      ) {
        return `${match.teamAName} won${match.winMargin ? ` by ${match.winMargin}` : ""}`;
      }
      if (
        winnerToken === "B" ||
        normalizeName(match.winnerId ?? "") === normalizeName(match.teamBName)
      ) {
        return `${match.teamBName} won${match.winMargin ? ` by ${match.winMargin}` : ""}`;
      }
      if (winnerToken === "TIE") return "Match tied";
      if (winnerToken === "DRAW") return "Match drawn";
      if (winnerToken === "ABANDONED" || winnerToken === "NO_RESULT") {
        return "No result";
      }
      return match.winMargin
        ? `Match complete · ${match.winMargin}`
        : "Match complete";
    })();

    const finalScoresText = inningsSummary
      .map((innings) => `${innings.shortName} ${innings.score}`)
      .join(" | ");

    const currentInnings =
      match.innings.find((innings) => !innings.isCompleted) ??
      match.innings[match.innings.length - 1] ??
      null;

    // Read studio scene from Redis (null = no active studio session)
    let studioScene = null as { scene: string; breakType?: string | null } | null
    try { studioScene = await getStudioScene(match.id) } catch {}
    const effectiveOverlayPack = await overlayPackService
      .resolveEffectivePackForMatch(match.id)
      .catch(() => null);

    const basePayload = {
      matchId: match.id,
      status: match.status,
      format: match.format,
      venueName: match.venueName ?? null,
      scheduledAt: match.scheduledAt?.toISOString() ?? null,
      tossSummary,
      teamAName: match.teamAName,
      teamAShortName,
      teamALogoUrl,
      teamBName: match.teamBName,
      teamBShortName,
      teamBLogoUrl,
      teamA: {
        name: match.teamAName,
        shortName: teamAShortName,
        logoUrl: teamALogoUrl,
      },
      teamB: {
        name: match.teamBName,
        shortName: teamBShortName,
        logoUrl: teamBLogoUrl,
      },
      inningsSummary,
      youtubeUrl: match.youtubeUrl ?? null,
      updatedAt: new Date().toISOString(),
      resultText,
      finalScoresText,
      scene: studioScene?.scene ?? null,
      breakType: studioScene?.breakType ?? null,
      overlayPack: effectiveOverlayPack
        ? {
            source: effectiveOverlayPack.source,
            id: effectiveOverlayPack.pack.id,
            code: effectiveOverlayPack.pack.code,
            name: effectiveOverlayPack.pack.name,
            kind: effectiveOverlayPack.pack.kind,
            config: effectiveOverlayPack.pack.config,
          }
        : null,
    };

    if (!currentInnings) {
      return {
        ...basePayload,
        currentInnings: null,
        batting: null,
        thisOver: [],
        thisOverNumber: null,
        striker: null,
        nonStriker: null,
        bowler: null,
        lastBallText: "Waiting for the first ball.",
        isPowerplay: false,
      };
    }

    const balls = currentInnings.ballEvents;
    const firstInnings = match.innings.find(
      (innings) => innings.inningsNumber === 1,
    );
    const isChasing = currentInnings.inningsNumber > 1 && firstInnings;

    const legalDeliveries = balls.filter(
      (ball) => ball.outcome !== "WIDE" && ball.outcome !== "NO_BALL",
    ).length;
    const scheduledOvers =
      match.format === "CUSTOM"
        ? (match.customOvers ?? 20)
        : (overlayFormatOvers[match.format] ?? 20);
    const maxDeliveries = scheduledOvers * 6;

    const target = isChasing ? firstInnings.totalRuns + 1 : null;
    const toWin = target !== null ? target - currentInnings.totalRuns : null;
    const ballsRemaining =
      target !== null ? maxDeliveries - legalDeliveries : null;

    const crr =
      legalDeliveries > 0
        ? parseFloat(
            ((currentInnings.totalRuns / legalDeliveries) * 6).toFixed(2),
          )
        : 0;

    const rrr =
      toWin !== null && ballsRemaining && ballsRemaining > 0
        ? parseFloat(((toWin / ballsRemaining) * 6).toFixed(2))
        : null;

    const lastBall = balls[balls.length - 1] ?? null;
    const currentOverNumber = lastBall?.overNumber ?? null;
    const thisOverBalls =
      currentOverNumber === null
        ? []
        : balls.filter((ball) => ball.overNumber === currentOverNumber);

    const ballDisplay = (ball: (typeof balls)[number]) => {
      if (ball.isWicket) return "W";
      if (ball.outcome === "WIDE") return "Wd";
      if (ball.outcome === "NO_BALL") return "Nb";
      if (ball.outcome === "FOUR") return "4";
      if (ball.outcome === "SIX") return "6";
      const total = ball.runs + ball.extras;
      return total === 0 ? "•" : String(total);
    };

    const thisOver = thisOverBalls.map((ball) => ({
      ball: ball.ballNumber,
      outcome: ball.outcome,
      runs: ball.runs,
      extras: ball.extras,
      isWicket: ball.isWicket,
      display: ballDisplay(ball),
    }));

    const livePlayerStats = buildInningsPlayerStats({
      balls,
      battingTeam: currentInnings.battingTeam,
      currentStrikerId: currentInnings.currentStrikerId,
      currentNonStrikerId: currentInnings.currentNonStrikerId,
      currentBowlerId: currentInnings.currentBowlerId,
    });
    const strikerIdResolved = livePlayerStats.strikerId;
    const nonStrikerIdResolved = livePlayerStats.nonStrikerId;
    const strikerEntry = strikerIdResolved
      ? livePlayerStats.batterStats.get(strikerIdResolved)
      : null;
    const nonStrikerEntry = nonStrikerIdResolved
      ? livePlayerStats.batterStats.get(nonStrikerIdResolved)
      : null;
    const currentBowlerId = livePlayerStats.currentBowlerId;
    let bowlerStats: {
      id: string;
      overs: number;
      wickets: number;
      runs: number;
      economy: number;
    } | null = null;

    if (currentBowlerId) {
      const currentBowlerStats = livePlayerStats.bowlerStats.get(currentBowlerId);
      if (currentBowlerStats) {
        bowlerStats = {
          id: currentBowlerId,
          overs: currentBowlerStats.overs,
          wickets: currentBowlerStats.wickets,
          runs: currentBowlerStats.runs,
          economy: currentBowlerStats.economy,
        };
      }
    }

    const rawIds = [
      strikerIdResolved,
      nonStrikerIdResolved,
      currentBowlerId,
      lastBall?.batterId,
      lastBall?.dismissedPlayerId,
    ].filter(Boolean) as string[];
    const uniqueIds = [...new Set(rawIds)];

    const profiles = uniqueIds.length
      ? await prisma.playerProfile.findMany({
          where: {
            OR: [{ id: { in: uniqueIds } }, { userId: { in: uniqueIds } }],
          },
          include: { user: { select: { name: true } } },
        })
      : [];

    const nameMap = new Map<string, string>();
    for (const profile of profiles) {
      nameMap.set(profile.id, profile.user.name);
      nameMap.set(profile.userId, profile.user.name);
    }
    const getName = (id: string) => nameMap.get(id) ?? "Unknown";

    const battingTeamName =
      currentInnings.battingTeam === "A" ? match.teamAName : match.teamBName;
    const bowlingTeamName =
      currentInnings.battingTeam === "A" ? match.teamBName : match.teamAName;
    const battingTeamShortName =
      currentInnings.battingTeam === "A" ? teamAShortName : teamBShortName;
    const bowlingTeamShortName =
      currentInnings.battingTeam === "A" ? teamBShortName : teamAShortName;
    const battingTeamLogoUrl =
      currentInnings.battingTeam === "A" ? teamALogoUrl : teamBLogoUrl;
    const bowlingTeamLogoUrl =
      currentInnings.battingTeam === "A" ? teamBLogoUrl : teamALogoUrl;

    const lastBallText = (() => {
      if (!lastBall) return "Waiting for the first ball.";
      const batterName = lastBall.batterId ? getName(lastBall.batterId) : null;
      const bowlerName = lastBall.bowlerId ? getName(lastBall.bowlerId) : null;
      const dismissedName = lastBall.dismissedPlayerId
        ? getName(lastBall.dismissedPlayerId)
        : batterName;
      const totalRuns = lastBall.runs + lastBall.extras;

      if (lastBall.isWicket) {
        const dismissal = lastBall.dismissalType
          ? String(lastBall.dismissalType).toLowerCase().replace(/_/g, " ")
          : "out";
        return `${dismissedName ?? "Batter"} is ${dismissal}.`;
      }
      if (lastBall.outcome === "SIX")
        return `${batterName ?? "Batter"} hits six.`;
      if (lastBall.outcome === "FOUR")
        return `${batterName ?? "Batter"} finds the boundary.`;
      if (lastBall.outcome === "FIVE")
        return `${batterName ?? "Batter"} races back for five.`;
      if (lastBall.outcome === "WIDE") return "Wide called.";
      if (lastBall.outcome === "NO_BALL") return "No-ball. Free hit coming up.";
      if (lastBall.outcome === "BYE")
        return `${totalRuns} bye${totalRuns === 1 ? "" : "s"} taken.`;
      if (lastBall.outcome === "LEG_BYE")
        return `${totalRuns} leg-bye${totalRuns === 1 ? "" : "s"} taken.`;
      if (totalRuns === 0)
        return `Dot ball${bowlerName ? ` from ${bowlerName}` : ""}.`;
      return `${batterName ?? "Batter"} takes ${totalRuns} run${
        totalRuns === 1 ? "" : "s"
      }.`;
    })();

    const powerplayOvers: Record<string, number> = {
      T10: 4,
      T20: 6,
      ONE_DAY: 10,
      TWO_INNINGS: 15,
      BOX_CRICKET: 2,
      CUSTOM: 6,
    };
    const ppCutoff = powerplayOvers[match.format] ?? 6;
    const isPowerplay =
      currentOverNumber !== null && currentOverNumber < ppCutoff;

    return {
      ...basePayload,
      currentInnings: currentInnings.inningsNumber,
      batting: {
        teamKey: currentInnings.battingTeam,
        team: battingTeamName,
        teamName: battingTeamName,
        teamShortName: battingTeamShortName,
        teamLogoUrl: battingTeamLogoUrl,
        bowlingTeamKey: currentInnings.battingTeam === "A" ? "B" : "A",
        bowling: bowlingTeamName,
        bowlingTeamName: bowlingTeamName,
        bowlingTeamShortName: bowlingTeamShortName,
        bowlingTeamLogoUrl: bowlingTeamLogoUrl,
        runs: currentInnings.totalRuns,
        wickets: currentInnings.totalWickets,
        overs: Number(currentInnings.totalOvers.toFixed(1)),
        score: `${currentInnings.totalRuns}/${currentInnings.totalWickets}`,
        crr,
        target,
        toWin,
        rrr,
        ballsRemaining,
      },
      thisOver,
      thisOverNumber: currentOverNumber,
      striker:
        strikerEntry && strikerIdResolved
          ? {
              id: strikerIdResolved,
              name: getName(strikerIdResolved),
              runs: strikerEntry.runs,
              balls: strikerEntry.balls,
              fours: strikerEntry.fours,
              sixes: strikerEntry.sixes,
              strikeRate: strikerEntry.strikeRate,
            }
          : null,
      nonStriker: nonStrikerEntry && nonStrikerIdResolved
        ? {
            id: nonStrikerIdResolved,
            name: getName(nonStrikerIdResolved),
            runs: nonStrikerEntry.runs,
            balls: nonStrikerEntry.balls,
            fours: nonStrikerEntry.fours,
            sixes: nonStrikerEntry.sixes,
            strikeRate: nonStrikerEntry.strikeRate,
          }
        : null,
      bowler: bowlerStats
        ? { ...bowlerStats, name: getName(bowlerStats.id) }
        : null,
      lastBallText,
      isPowerplay,
    };
  };

  // GET /public/overlay/:matchId — machine-readable live score state
  app.get("/overlay/:matchId", async (request, reply) => {
    const { matchId } = request.params as { matchId: string };
    const data = await buildOverlayState(matchId);

    if (!data) return reply.status(404).send({ error: "Match not found" });
    return reply.send({ data });
  });

  // GET /public/overlay/:matchId/stream — live push stream for overlays
  app.get("/overlay/:matchId/stream", async (request, reply) => {
    const { matchId } = request.params as { matchId: string };

    reply.hijack();
    reply.raw.writeHead(200, {
      "Content-Type": "text/event-stream; charset=utf-8",
      "Cache-Control": "no-cache, no-transform",
      Connection: "keep-alive",
      "X-Accel-Buffering": "no",
    });
    reply.raw.write("retry: 1000\n\n");
    reply.raw.flushHeaders?.();

    let closed = false;
    let interval: NodeJS.Timeout | null = null;

    const sendState = async () => {
      if (closed) return;
      try {
        const data = await buildOverlayState(matchId);
        if (!data) {
          reply.raw.write(
            `event: error\ndata: ${JSON.stringify({
              error: "Match not found",
            })}\n\n`,
          );
          if (interval) clearInterval(interval);
          reply.raw.end();
          closed = true;
          return;
        }

        reply.raw.write(`event: overlay\ndata: ${JSON.stringify(data)}\n\n`);
      } catch {
        reply.raw.write(
          `event: error\ndata: ${JSON.stringify({
            error: "Overlay stream failed",
          })}\n\n`,
        );
      }
    };

    interval = setInterval(() => {
      void sendState();
    }, 1000);

    void sendState();

    request.raw.on("close", () => {
      closed = true;
      if (interval) clearInterval(interval);
      reply.raw.end();
    });
  });

  app.get("/overlay-assets/logo", async (_request, reply) => {
    if (!overlayLogoAsset) {
      return reply.status(404).send({
        success: false,
        error: { code: "NOT_FOUND", message: "Overlay logo not found" },
      });
    }

    return reply
      .header("Content-Type", overlayLogoAsset.mimeType)
      .header("Cache-Control", "public, max-age=86400")
      .send(readFileSync(overlayLogoAsset.filePath));
  });

  app.get("/overlay/:matchId/widget", async (request, reply) => {
    const { matchId } = request.params as { matchId: string };
    const {
      poll = "1000",
      view = "standard",
      type = "drinks",
    } = request.query as {
      poll?: string;
      view?: string;
      type?: string;
    };

    const safeView = ["standard", "stats", "break"].includes(view)
      ? view
      : "standard";
    const safeBreakType = ["drinks", "innings", "powerplay"].includes(type)
      ? type
      : "drinks";

    const initialData = await buildOverlayState(matchId);
    if (!initialData) {
      return reply
        .status(404)
        .header("Content-Type", "text/html; charset=utf-8")
        .send(
          `<!DOCTYPE html><html><body style="margin:0;display:grid;place-items:center;height:100vh;background:#09140f;color:#f5efe3;font-family:Segoe UI,Arial,sans-serif">Match not found</body></html>`,
        );
    }

    const serializedInitialData = JSON.stringify(initialData).replace(
      /</g,
      "\\u003c",
    );
    const defaultPoll = Math.max(750, parseInt(poll, 10) || 1000);

    type OverlayTeam = typeof initialData.teamA;
    type OverlayBall = (typeof initialData.thisOver)[number];
    type OverlayPlayer = NonNullable<typeof initialData.striker>;

    const escapeHtml = (value: unknown) =>
      String(value ?? "")
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#39;");

    const shortTeamName = (team?: OverlayTeam | null) => {
      if (!team) return "SW";
      if (team.shortName?.trim()) {
        return team.shortName.trim().toUpperCase();
      }
      const base =
        team.name.split("-")[0]?.trim() ||
        team.name.replace(/\b\d+\b/g, "").trim() ||
        team.name.trim();
      const compact = base.replace(/[^a-z0-9]/gi, "");
      if (compact && compact.length <= 6) return compact.toUpperCase();
      const initials = base
        .split(/\s+/)
        .map((part) => part[0] ?? "")
        .join("");
      return (initials || compact || "SW").slice(0, 4).toUpperCase();
    };

    const shortPlayerName = (name?: string | null) => {
      if (!name) return "—";
      const parts = name.trim().split(/\s+/);
      if (parts.length === 1) return parts[0];
      return `${parts[0][0]}. ${parts.slice(1).join(" ")}`;
    };

    const formatOvers = (value?: number | null) =>
      typeof value === "number" && Number.isFinite(value)
        ? value.toFixed(1)
        : "0.0";

    const formatRate = (value?: number | null) =>
      typeof value === "number" && Number.isFinite(value)
        ? value.toFixed(2)
        : "—";

    const ballTone = (ball?: OverlayBall | null) => {
      if (!ball) return "dot";
      if (ball.isWicket) return "wicket";
      if (ball.outcome === "SIX") return "six";
      if (ball.outcome === "FOUR") return "boundary";
      if (ball.outcome === "WIDE" || ball.outcome === "NO_BALL") return "extra";
      if (ball.display === "•") return "dot";
      return "run";
    };

    const ballMarkup = (
      ball: OverlayBall | null,
      variant: "standard" | "stats",
    ) => {
      const className = variant === "standard" ? "ball-chip" : "ball-pill";
      return `<span class="${className} ${ballTone(ball)}">${escapeHtml(
        ball?.display ?? "•",
      )}</span>`;
    };

    const renderLogo = (
      team: OverlayTeam | null | undefined,
      variant: "standard" | "stats" | "break" = "standard",
    ) => {
      const short = escapeHtml(shortTeamName(team));
      const teamName = escapeHtml(team?.name ?? short);
      const variantClass =
        variant === "break"
          ? "team-mark break-mark"
          : variant === "stats"
            ? "team-mark stats-mark"
            : "team-mark";

      if (team?.logoUrl) {
        return `<div class="${variantClass}"><span class="team-mark-fallback" style="display:none">${short}</span><img src="${escapeHtml(
          team.logoUrl,
        )}" alt="${teamName}" onerror="this.previousElementSibling.style.display='grid';this.remove()"></div>`;
      }

      return `<div class="${variantClass}"><span class="team-mark-fallback">${short}</span></div>`;
    };

    const activeBatting = initialData.batting;
    const battingIsTeamA = activeBatting
      ? activeBatting.team === initialData.teamA.name
      : true;
    const battingTeam =
      activeBatting && !battingIsTeamA ? initialData.teamB : initialData.teamA;
    const bowlingTeam =
      activeBatting && !battingIsTeamA ? initialData.teamA : initialData.teamB;
    const statusLabel =
      initialData.status === "IN_PROGRESS"
        ? "LIVE"
        : String(initialData.status).replace(/_/g, " ");
    const scoreText = activeBatting
      ? `${activeBatting.runs}/${activeBatting.wickets}`
      : "—";
    const oversText = activeBatting
      ? `${formatOvers(activeBatting.overs)} ov`
      : "Awaiting start";
    const rateText = activeBatting
      ? activeBatting.rrr !== null
        ? `RRR ${formatRate(activeBatting.rrr)}`
        : `CRR ${formatRate(activeBatting.crr)}`
      : "First ball pending";
    const chaseText =
      activeBatting &&
      activeBatting.target &&
      activeBatting.toWin !== null &&
      activeBatting.ballsRemaining !== null
        ? `Need ${activeBatting.toWin} from ${activeBatting.ballsRemaining}`
        : initialData.lastBallText;
    const matchupText = `${shortTeamName(initialData.teamA)} v ${shortTeamName(
      initialData.teamB,
    )}`;
    const currentOverText =
      initialData.thisOverNumber !== null
        ? `Over ${Number(initialData.thisOverNumber) + 1}`
        : "Over —";
    const standardBallsHtml = (
      initialData.thisOver.length
        ? initialData.thisOver.slice(-6)
        : Array.from({ length: 6 }, () => null)
    )
      .map((ball) => ballMarkup(ball, "standard"))
      .join("");
    const statsBallsHtml = initialData.thisOver.length
      ? initialData.thisOver.map((ball) => ballMarkup(ball, "stats")).join("")
      : `<span class="empty-copy">No balls yet.</span>`;
    const inningsPillsHtml = initialData.inningsSummary
      .map((innings) => {
        const active =
          Number(initialData.currentInnings) === Number(innings.inningsNumber);
        return `<div class="innings-pill${
          active ? " active" : ""
        }"><span class="innings-team">${escapeHtml(
          innings.shortName,
        )}</span><span class="innings-score">${escapeHtml(
          innings.score,
        )}</span><span class="innings-overs">${escapeHtml(
          formatOvers(innings.overs),
        )} ov</span></div>`;
      })
      .join("");
    const currentBatters = [initialData.striker, initialData.nonStriker].filter(
      (player): player is OverlayPlayer => Boolean(player),
    );
    const statsBattersHtml = currentBatters.length
      ? currentBatters
          .map(
            (player, index) => `<tr>
              <td>
                <div class="player-line">
                  <span class="player-name">${escapeHtml(player.name)}${
                    index === 0 ? " *" : ""
                  }</span>
                  <span class="player-sub">${
                    index === 0 ? "On strike" : "Non-striker"
                  }</span>
                </div>
              </td>
              <td>${player.runs}</td>
              <td>${player.balls}</td>
              <td>${player.fours}</td>
              <td>${player.sixes}</td>
              <td>${formatRate(player.strikeRate)}</td>
            </tr>`,
          )
          .join("")
      : `<tr><td colspan="6" class="empty-copy table-empty">Waiting for batting data.</td></tr>`;
    const statsBowlerHtml = initialData.bowler
      ? `<tr>
          <td>
            <div class="player-line">
              <span class="player-name">${escapeHtml(
                initialData.bowler.name,
              )}</span>
              <span class="player-sub">Current bowler</span>
            </div>
          </td>
          <td>${formatOvers(initialData.bowler.overs)}</td>
          <td>${initialData.bowler.wickets}</td>
          <td>${initialData.bowler.runs}</td>
          <td>${formatRate(initialData.bowler.economy)}</td>
        </tr>`
      : `<tr><td colspan="5" class="empty-copy table-empty">Bowler yet to begin.</td></tr>`;
    const noteItems = [
      initialData.lastBallText,
      activeBatting && activeBatting.target
        ? `Target ${activeBatting.target} · Need ${activeBatting.toWin} from ${activeBatting.ballsRemaining}`
        : null,
      initialData.tossSummary,
      initialData.venueName ? `Venue · ${initialData.venueName}` : null,
    ].filter((item): item is string => Boolean(item));
    const statsNotesHtml = noteItems.length
      ? noteItems
          .map(
            (note) =>
              `<div class="note-card"><span class="note-accent"></span><span>${escapeHtml(
                note,
              )}</span></div>`,
          )
          .join("")
      : `<div class="empty-copy">No live notes yet.</div>`;
    const breakWordMap: Record<string, string> = {
      drinks: "DRINKS",
      innings: "INNINGS",
      powerplay: "POWERPLAY",
    };
    const breakBadgeMap: Record<string, string> = {
      drinks: "Drinks Break",
      innings: "Innings Break",
      powerplay: "Powerplay Break",
    };
    const breakCardsHtml = [initialData.teamA, initialData.teamB]
      .map((team) => {
        const innings = initialData.inningsSummary.find(
          (entry) => entry.team === team.name,
        );
        return `<div class="break-card">
          ${renderLogo(team, "break")}
          <div class="break-team-copy">
            <div class="break-team-short">${escapeHtml(
              shortTeamName(team),
            )}</div>
            <div class="break-team-name">${escapeHtml(team.name)}</div>
          </div>
          <div class="break-team-score">${escapeHtml(
            innings?.score ?? "—",
          )}</div>
          <div class="break-team-overs">${escapeHtml(
            innings ? `${formatOvers(innings.overs)} ov` : "Yet to bat",
          )}</div>
        </div>`;
      })
      .join("");
    const breakHooks = [
      initialData.striker
        ? {
            label: "Set batter",
            value: `${initialData.striker.name} ${initialData.striker.runs}* (${initialData.striker.balls})`,
          }
        : null,
      initialData.nonStriker
        ? {
            label: "Supporting batter",
            value: `${initialData.nonStriker.name} ${initialData.nonStriker.runs} (${initialData.nonStriker.balls})`,
          }
        : null,
      initialData.bowler
        ? {
            label: "Bowling impact",
            value: `${initialData.bowler.name} ${initialData.bowler.wickets}/${initialData.bowler.runs} in ${formatOvers(initialData.bowler.overs)} ov`,
          }
        : null,
    ].filter(
      (
        hook,
      ): hook is {
        label: string;
        value: string;
      } => Boolean(hook),
    );
    const breakHooksHtml = breakHooks.length
      ? breakHooks
          .map(
            (hook) => `<div class="break-hook">
              <div class="break-hook-label">${escapeHtml(hook.label)}</div>
              <div class="break-hook-value">${escapeHtml(hook.value)}</div>
            </div>`,
          )
          .join("")
      : `<div class="break-hook">
          <div class="break-hook-label">Match pulse</div>
          <div class="break-hook-value">${escapeHtml(initialData.lastBallText)}</div>
        </div>`;
    const overlayLogoSrc = overlayLogoAsset
      ? "/public/overlay-assets/logo"
      : null;

    const html = `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<title>Swing Live Overlay</title>
<meta name="viewport" content="width=device-width, initial-scale=1"/>
<style>
:root{
  --bg:#250204;
  --bg-deep:#0d0001;
  --panel:#43060a;
  --panel-strong:#5c0910;
  --line:rgba(255,255,255,0.12);
  --accent:#ff2e39;
  --accent-soft:#ff6f79;
  --cream:#fff7f8;
  --silver:#d7dde2;
  --gold:#ffd7c2;
  --muted:rgba(255,247,248,0.68);
  --muted-soft:rgba(255,247,248,0.44);
  --live:#ff2e39;
  --shadow:0 22px 60px rgba(0,0,0,0.42);
}
html,body{margin:0;width:1920px;height:1080px;overflow:hidden;background:transparent}
*{box-sizing:border-box}
body{font-family:"Segoe UI",Inter,Arial,sans-serif;color:var(--cream);-webkit-font-smoothing:antialiased}
.empty-copy{color:var(--muted-soft);font-size:18px}
.table-empty{text-align:left !important;padding:24px 0}
#view-standard{position:fixed;left:0;right:0;bottom:0;display:${safeView === "standard" ? "flex" : "none"};justify-content:center;padding:0 28px 18px}
.standard-shell{position:relative;width:100%;max-width:1864px;border-top:3px solid var(--accent);border-radius:30px 30px 0 0;background:linear-gradient(180deg, rgba(67,6,10,0.985), rgba(13,0,1,0.995));box-shadow:var(--shadow);overflow:hidden}
.standard-brand-corner{position:absolute;top:14px;right:18px;display:flex;align-items:center;gap:12px;padding:10px 14px 10px 10px;border-radius:999px;border:1px solid rgba(255,255,255,0.12);background:rgba(8,0,1,0.76);box-shadow:0 10px 24px rgba(0,0,0,0.26);z-index:2}
.standard-brand-corner img{width:42px;height:42px;object-fit:contain;display:block}
.standard-brand-copy{display:flex;flex-direction:column;gap:3px;align-items:flex-start}
.standard-brand-name{font-size:11px;line-height:1;text-transform:uppercase;letter-spacing:3px;font-weight:900;color:var(--cream)}
.standard-brand-tag{font-size:10px;line-height:1.2;color:var(--accent-soft);text-transform:uppercase;letter-spacing:1.5px;font-weight:700}
.standard-main{display:grid;grid-template-columns:1.15fr 1fr 1.15fr;min-height:160px}
.overlay-column{display:flex;align-items:center;gap:18px;padding:20px 24px}
.overlay-column + .overlay-column{border-left:1px solid var(--line)}
.team-mark{width:78px;height:78px;border-radius:999px;border:2px solid rgba(255,255,255,0.16);background:radial-gradient(circle at 30% 30%, rgba(255,255,255,0.14), rgba(255,255,255,0.04));overflow:hidden;display:grid;place-items:center;flex-shrink:0;box-shadow:inset 0 0 0 1px rgba(255,46,57,0.18)}
.team-mark img{width:100%;height:100%;object-fit:cover}
.team-mark-fallback{width:100%;height:100%;display:grid;place-items:center;color:var(--cream);font-size:24px;font-weight:900;letter-spacing:1px}
.column-copy{min-width:0;display:flex;flex-direction:column;gap:10px}
.eyebrow{font-size:11px;text-transform:uppercase;letter-spacing:2.8px;color:var(--accent-soft)}
.team-line{display:flex;align-items:center;gap:10px}
.team-short{font-size:28px;font-weight:800;letter-spacing:1px}
.team-name{font-size:14px;color:var(--muted);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.player-stack{display:flex;flex-direction:column;gap:8px}
.player-row{display:grid;grid-template-columns:minmax(0,1fr) auto auto;gap:10px;align-items:baseline}
.player-name{font-size:15px;font-weight:700;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.player-name.secondary{color:var(--muted)}
.player-runs{font-size:28px;font-weight:800;line-height:1}
.player-balls{font-size:14px;color:var(--muted-soft)}
.standard-center{display:flex;flex-direction:column;align-items:center;justify-content:center;gap:6px;padding:18px 24px;text-align:center}
.status-row{display:flex;align-items:center;gap:10px;font-size:11px;text-transform:uppercase;letter-spacing:3px;color:var(--silver)}
.live-dot{width:8px;height:8px;border-radius:999px;background:var(--live);box-shadow:0 0 0 0 rgba(255,46,57,0.42);animation:livePulse 1.4s infinite}
.matchup{font-size:15px;font-weight:700;letter-spacing:1.6px;color:var(--silver)}
.score-line{display:flex;align-items:center;gap:12px}
.hero-score{font-size:66px;line-height:0.92;font-weight:900;letter-spacing:-2px}
.hero-meta{display:flex;flex-direction:column;align-items:flex-start;gap:4px}
.overs-pill{padding:8px 12px;border-radius:999px;border:1px solid rgba(255,255,255,0.14);background:rgba(255,255,255,0.05);font-size:13px;font-weight:800;letter-spacing:1.2px;text-transform:uppercase}
.pp-pill{display:none;padding:6px 10px;border-radius:999px;background:rgba(255,46,57,0.14);color:var(--cream);font-size:11px;font-weight:800;letter-spacing:2px;text-transform:uppercase}
.support-line{font-size:14px;color:var(--muted);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:100%}
.rate-line{font-size:15px;font-weight:800;color:var(--accent-soft)}
.right-stack{display:flex;flex-direction:column;gap:10px;min-width:0;width:100%}
.bowler-name{font-size:18px;font-weight:800;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.bowler-figures{font-size:30px;font-weight:900;line-height:1}
.bowler-overs{font-size:14px;color:var(--muted)}
.balls-row{display:flex;flex-wrap:wrap;gap:8px}
.ball-chip,.ball-pill{display:grid;place-items:center;font-weight:800;border-radius:999px;border:1px solid rgba(245,239,227,0.12);color:var(--cream);background:rgba(255,255,255,0.06)}
.ball-chip{width:34px;height:34px;font-size:13px}
.ball-pill{min-width:40px;height:40px;padding:0 14px;font-size:14px}
.ball-chip.dot,.ball-pill.dot{color:var(--muted-soft)}
.ball-chip.run,.ball-pill.run{background:rgba(255,255,255,0.1)}
.ball-chip.boundary,.ball-pill.boundary{background:rgba(255,111,121,0.18);border-color:rgba(255,111,121,0.4);color:var(--cream)}
.ball-chip.six,.ball-pill.six{background:rgba(255,46,57,0.24);border-color:rgba(255,46,57,0.52);color:var(--cream)}
.ball-chip.extra,.ball-pill.extra{background:rgba(207,135,89,0.18);border-color:rgba(207,135,89,0.45);color:#f3c29c}
.ball-chip.wicket,.ball-pill.wicket{background:rgba(200,93,86,0.2);border-color:rgba(200,93,86,0.45);color:#f2b2ad}
.ticker{display:flex;align-items:center;justify-content:space-between;gap:18px;min-height:46px;padding:0 22px;border-top:1px solid var(--line);background:rgba(8,0,1,0.88)}
.ticker-brand{display:inline-flex;align-items:center;gap:10px;font-size:12px;text-transform:uppercase;letter-spacing:3px;font-weight:900;color:var(--cream);flex-shrink:0}
.ticker-brand::before{content:"";width:10px;height:10px;border-radius:999px;background:var(--accent);box-shadow:0 0 16px rgba(255,46,57,0.7)}
.ticker-text{font-size:13px;color:var(--silver);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;text-align:center;flex:1}
.ticker-meta{font-size:12px;color:var(--accent-soft);text-transform:uppercase;letter-spacing:1.8px;font-weight:700;flex-shrink:0}
#view-stats{position:fixed;inset:0;display:${safeView === "stats" ? "block" : "none"};background:linear-gradient(180deg, #250204 0%, #0d0001 100%)}
.stats-shell{height:100%;padding:28px 30px 30px;display:flex;flex-direction:column;gap:18px}
.stats-rail{display:grid;grid-template-columns:280px 1fr 400px;gap:18px}
.team-score-card,.scoreboard-core,.stats-panel,.side-panel,.summary-card{border-radius:24px;border:1px solid var(--line);background:linear-gradient(180deg, rgba(92,9,16,0.34), rgba(20,0,2,0.48));box-shadow:var(--shadow)}
.team-score-card{display:flex;align-items:center;gap:16px;padding:18px 20px}
.stats-mark{width:72px;height:72px}
.team-score-copy{min-width:0;display:flex;flex-direction:column;gap:6px}
.team-score-copy .team-short{font-size:24px}
.team-score-value{font-size:34px;font-weight:900;letter-spacing:-1px}
.team-score-sub{font-size:14px;color:var(--muted)}
.scoreboard-core{padding:22px 26px;display:flex;flex-direction:column;justify-content:center;text-align:center;gap:8px}
.core-kicker{font-size:12px;text-transform:uppercase;letter-spacing:3px;color:var(--muted-soft)}
.core-score{font-size:88px;line-height:0.9;font-weight:900;letter-spacing:-3px}
.core-matchup{font-size:18px;font-weight:800;letter-spacing:1.6px;color:var(--silver)}
.core-meta{font-size:16px;color:var(--muted)}
.core-notes{display:flex;justify-content:center;gap:10px;flex-wrap:wrap;margin-top:4px}
.meta-pill{padding:9px 13px;border-radius:999px;background:rgba(255,255,255,0.04);border:1px solid var(--line);font-size:13px;color:var(--cream)}
.summary-card{padding:18px 20px;display:flex;flex-direction:column;gap:12px}
.summary-title{font-size:12px;text-transform:uppercase;letter-spacing:3px;color:var(--muted-soft)}
.summary-value{font-size:18px;font-weight:800}
.summary-copy{font-size:15px;color:var(--muted);line-height:1.45}
.innings-switch{display:flex;gap:10px;flex-wrap:wrap}
.innings-pill{display:flex;align-items:center;gap:10px;padding:10px 14px;border-radius:999px;border:1px solid var(--line);background:rgba(255,255,255,0.03)}
.innings-pill.active{border-color:rgba(216,181,106,0.35);background:rgba(216,181,106,0.12)}
.innings-team{font-size:12px;text-transform:uppercase;letter-spacing:2px;color:var(--gold)}
.innings-score{font-size:16px;font-weight:800}
.innings-overs{font-size:13px;color:var(--muted)}
.stats-body{flex:1;display:grid;grid-template-columns:1.2fr 0.95fr;gap:18px;min-height:0}
.stats-panel,.side-panel{padding:22px 24px}
.panel-head{display:flex;justify-content:space-between;align-items:flex-start;gap:18px;margin-bottom:20px}
.panel-title{font-size:15px;text-transform:uppercase;letter-spacing:3px;color:var(--accent-soft);margin:0 0 6px}
.panel-subtitle{font-size:14px;color:var(--muted)}
.score-table{width:100%;border-collapse:collapse}
.score-table th,.score-table td{padding:14px 0;border-bottom:1px solid var(--line);text-align:right}
.score-table th:first-child,.score-table td:first-child{text-align:left}
.score-table th{font-size:12px;text-transform:uppercase;letter-spacing:2px;color:var(--muted-soft);font-weight:700}
.score-table td{font-size:16px;color:var(--cream)}
.player-line{display:flex;flex-direction:column;gap:4px}
.player-line .player-name{font-size:17px}
.player-sub{font-size:13px;color:var(--muted)}
.side-stack{display:flex;flex-direction:column;gap:18px}
.stack-card{border-radius:20px;border:1px solid var(--line);background:rgba(255,255,255,0.03);padding:18px}
.stack-title{font-size:12px;text-transform:uppercase;letter-spacing:2.6px;color:var(--muted-soft);margin-bottom:12px}
.note-list{display:flex;flex-direction:column;gap:10px}
.note-card{display:flex;align-items:flex-start;gap:10px;padding:12px 14px;border-radius:16px;border:1px solid var(--line);background:rgba(255,255,255,0.03);font-size:15px;line-height:1.45;color:var(--cream)}
.note-accent{width:8px;height:8px;border-radius:999px;margin-top:6px;background:var(--accent);flex-shrink:0}
#view-break{position:fixed;inset:0;display:${safeView === "break" ? "grid" : "none"};place-items:center;background:radial-gradient(circle at top, rgba(255,46,57,0.16), transparent 36%), linear-gradient(180deg, #250204 0%, #0d0001 100%)}
.break-shell{width:min(1360px, calc(100vw - 80px));display:flex;flex-direction:column;align-items:center;gap:24px;text-align:center}
.break-badge{padding:9px 16px;border-radius:999px;border:1px solid rgba(255,255,255,0.18);background:rgba(255,46,57,0.14);color:var(--cream);font-size:13px;letter-spacing:3px;text-transform:uppercase;font-weight:800}
.break-word{font-size:108px;font-weight:900;line-height:0.92;letter-spacing:-3px}
.break-subtitle{font-size:20px;color:var(--silver);max-width:760px;line-height:1.55}
.break-grid{width:100%;display:grid;grid-template-columns:repeat(2, minmax(0, 1fr));gap:20px;margin-top:10px}
.break-card{display:grid;grid-template-columns:92px minmax(0,1fr) auto;gap:18px;align-items:center;padding:22px 24px;border-radius:26px;border:1px solid var(--line);background:linear-gradient(180deg, rgba(92,9,16,0.36), rgba(20,0,2,0.54));box-shadow:var(--shadow);text-align:left}
.break-mark{width:92px;height:92px}
.break-team-copy{min-width:0}
.break-team-short{font-size:16px;letter-spacing:3px;text-transform:uppercase;color:var(--accent-soft);margin-bottom:8px}
.break-team-name{font-size:26px;font-weight:800;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.break-team-score{font-size:60px;font-weight:900;line-height:0.92;letter-spacing:-2px}
.break-team-overs{grid-column:2 / 4;font-size:15px;color:var(--muted)}
.break-brand{display:flex;flex-direction:column;gap:8px;max-width:920px}
.break-logo{display:inline-flex;align-items:center;justify-content:center;gap:14px;font-size:18px;font-weight:900;letter-spacing:4px;text-transform:uppercase;color:var(--cream)}
.break-logo img{width:52px;height:52px;object-fit:contain;display:block;filter:drop-shadow(0 6px 16px rgba(0,0,0,0.24))}
.break-tagline{font-size:28px;font-weight:800;line-height:1.15}
.break-copy{font-size:15px;color:var(--silver);letter-spacing:0.4px}
.break-hooks{width:100%;display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:16px}
.break-hook{padding:18px 20px;border-radius:20px;border:1px solid var(--line);background:rgba(255,255,255,0.04);text-align:left}
.break-hook-label{font-size:12px;text-transform:uppercase;letter-spacing:2.5px;color:var(--accent-soft);margin-bottom:8px}
.break-hook-value{font-size:20px;font-weight:700;line-height:1.35}
#ev-layer{position:fixed;inset:0;display:none;align-items:center;justify-content:center;pointer-events:none;z-index:200}
.ev-container{min-width:620px;max-width:980px;padding:42px 64px 34px;border-radius:32px;border:1px solid rgba(255,255,255,0.12);background:linear-gradient(180deg, rgba(92,9,16,0.94), rgba(13,0,1,0.96));box-shadow:0 30px 80px rgba(0,0,0,0.45);display:flex;flex-direction:column;align-items:center;position:relative;overflow:hidden}
.ev-container::before,.ev-container::after{content:"";position:absolute;border-radius:999px;filter:blur(2px);opacity:0.45}
.ev-container::before{width:220px;height:220px;background:radial-gradient(circle, rgba(255,46,57,0.3), transparent 70%);top:-80px;left:-40px}
.ev-container::after{width:180px;height:180px;background:radial-gradient(circle, rgba(255,255,255,0.18), transparent 70%);bottom:-60px;right:-30px}
.event-chip{padding:7px 14px;border-radius:999px;border:1px solid rgba(255,255,255,0.18);background:rgba(255,255,255,0.08);font-size:12px;letter-spacing:2.5px;text-transform:uppercase;font-weight:800;color:var(--silver)}
.event-word{font-size:116px;line-height:0.9;font-weight:900;letter-spacing:-4px;margin-top:14px}
.event-sub{margin-top:12px;font-size:26px;font-weight:800;line-height:1.2;color:var(--cream);text-align:center}
.event-line{margin-top:10px;font-size:16px;line-height:1.5;color:var(--silver);text-align:center;max-width:720px}
.ev-container.ev-four .event-word{color:var(--accent-soft)}
.ev-container.ev-six .event-word{color:var(--cream)}
.ev-container.ev-wicket .event-word{color:#f2b2ad}
.ev-container.ev-freehit .event-word{color:#f3c29c}
@keyframes livePulse{0%,100%{box-shadow:0 0 0 0 rgba(255,46,57,0.42)}50%{box-shadow:0 0 0 8px rgba(255,46,57,0)}}
@keyframes evSlideUp{0%{opacity:0;transform:translateY(36px) scale(0.92)}14%{opacity:1;transform:translateY(0) scale(1)}84%{opacity:1;transform:translateY(0) scale(1)}100%{opacity:0;transform:translateY(-18px) scale(0.98)}}
@keyframes evScale{0%{opacity:0;transform:scale(1.2)}14%{opacity:1;transform:scale(1)}84%{opacity:1;transform:scale(1)}100%{opacity:0;transform:scale(0.96)}}
@keyframes evShake{0%{opacity:0;transform:translateX(0) scale(0.9)}8%{opacity:1;transform:translateX(-10px) scale(1.02)}16%{transform:translateX(10px)}24%{transform:translateX(-6px)}32%{transform:translateX(0)}84%{opacity:1}100%{opacity:0;transform:scale(0.98)}}
@keyframes evPulse{0%{opacity:0;transform:scale(0.94)}12%{opacity:1;transform:scale(1.04)}28%{transform:scale(1)}84%{opacity:1;transform:scale(1)}100%{opacity:0;transform:scale(0.98)}}
</style>
</head>
<body>
<div id="view-standard">
  <div class="standard-shell">
    ${
      overlayLogoSrc
        ? `<div class="standard-brand-corner">
      <img src="${overlayLogoSrc}" alt="Swing Cricket" />
      <div class="standard-brand-copy">
        <div class="standard-brand-name">Swing Cricket</div>
        <div class="standard-brand-tag">Every run matters</div>
      </div>
    </div>`
        : ""
    }
    <div class="standard-main">
      <section class="overlay-column">
        <div id="s-batting-logo">${renderLogo(battingTeam)}</div>
        <div class="column-copy">
          <div class="eyebrow">Batting now</div>
          <div class="team-line">
            <span class="team-short" id="s-batting-short">${escapeHtml(
              shortTeamName(battingTeam),
            )}</span>
            <span class="team-name" id="s-batting-name">${escapeHtml(
              battingTeam.name,
            )}</span>
          </div>
          <div class="player-stack">
            <div class="player-row">
              <span class="player-name" id="s-b1">${escapeHtml(
                initialData.striker
                  ? shortPlayerName(initialData.striker.name)
                  : "—",
              )}</span>
              <span class="player-runs" id="s-b1r">${
                initialData.striker?.runs ?? "—"
              }</span>
              <span class="player-balls" id="s-b1b">${
                initialData.striker ? `(${initialData.striker.balls})` : ""
              }</span>
            </div>
            <div class="player-row">
              <span class="player-name secondary" id="s-b2">${escapeHtml(
                initialData.nonStriker
                  ? shortPlayerName(initialData.nonStriker.name)
                  : "—",
              )}</span>
              <span class="player-runs" id="s-b2r">${
                initialData.nonStriker?.runs ?? "—"
              }</span>
              <span class="player-balls" id="s-b2b">${
                initialData.nonStriker
                  ? `(${initialData.nonStriker.balls})`
                  : ""
              }</span>
            </div>
          </div>
        </div>
      </section>
      <section class="standard-center">
        <div class="status-row">
          ${
            initialData.status === "IN_PROGRESS"
              ? `<span class="live-dot" id="s-live-dot"></span>`
              : `<span id="s-live-dot" style="display:none"></span>`
          }
          <span id="s-status-txt">${escapeHtml(statusLabel)}</span>
        </div>
        <div class="matchup" id="s-matchup">${escapeHtml(matchupText)}</div>
        <div class="score-line">
          <div class="hero-score" id="s-score">${escapeHtml(scoreText)}</div>
          <div class="hero-meta">
            <div class="overs-pill" id="s-overs-txt">${escapeHtml(
              oversText,
            )}</div>
            <div class="pp-pill" id="s-pp-badge"${
              initialData.isPowerplay ? "" : ' style="display:none"'
            }>Powerplay</div>
          </div>
        </div>
        <div class="rate-line" id="s-crr">${escapeHtml(rateText)}</div>
        <div class="support-line" id="s-chase">${escapeHtml(chaseText)}</div>
        <div class="support-line" id="s-toss-txt">${escapeHtml(
          initialData.tossSummary ?? "Toss awaiting",
        )}</div>
      </section>
      <section class="overlay-column">
        <div id="s-bowling-logo">${renderLogo(bowlingTeam)}</div>
        <div class="right-stack">
          <div class="eyebrow">Bowling</div>
          <div class="team-line">
            <span class="team-short" id="s-bowling-short">${escapeHtml(
              shortTeamName(bowlingTeam),
            )}</span>
            <span class="team-name" id="s-bowling-name">${escapeHtml(
              bowlingTeam.name,
            )}</span>
          </div>
          <div class="bowler-name" id="s-bwl">${escapeHtml(
            initialData.bowler?.name ?? "—",
          )}</div>
          <div class="team-line">
            <span class="bowler-figures" id="s-bwl-f">${escapeHtml(
              initialData.bowler
                ? `${initialData.bowler.wickets}/${initialData.bowler.runs}`
                : "—",
            )}</span>
            <span class="bowler-overs" id="s-bwl-ov">${escapeHtml(
              initialData.bowler
                ? `${formatOvers(initialData.bowler.overs)} ov`
                : "",
            )}</span>
          </div>
          <div class="balls-row" id="s-balls">${standardBallsHtml}</div>
        </div>
      </section>
    </div>
    <div class="ticker">
      <span class="ticker-brand">Swing Cricket</span>
      <span class="ticker-text">Every Ball. Every Run. Every Player Matters.</span>
      <span class="ticker-meta">Live Scoring | Player Stats | Match Highlights</span>
    </div>
  </div>
</div>

<div id="view-stats">
  <div class="stats-shell">
    <div class="stats-rail">
      <section class="team-score-card">
        ${renderLogo(initialData.teamA, "stats")}
        <div class="team-score-copy">
          <div class="team-short">${escapeHtml(
            shortTeamName(initialData.teamA),
          )}</div>
          <div class="team-score-value" id="st-team-a-score">${escapeHtml(
            initialData.inningsSummary.find(
              (entry) => entry.team === initialData.teamA.name,
            )?.score ?? "—",
          )}</div>
          <div class="team-score-sub">${escapeHtml(
            initialData.teamA.name,
          )}</div>
        </div>
      </section>
      <section class="scoreboard-core">
        <div class="core-kicker">${escapeHtml(statusLabel)} scorecard</div>
        <div class="core-score" id="st-score">${escapeHtml(scoreText)}</div>
        <div class="core-matchup" id="st-title">${escapeHtml(matchupText)}</div>
        <div class="core-meta" id="st-meta">${escapeHtml(
          activeBatting
            ? `${activeBatting.team} batting · ${formatOvers(
                activeBatting.overs,
              )} ov`
            : "Awaiting the start",
        )}</div>
        <div class="core-notes">
          <span class="meta-pill" id="st-over">${escapeHtml(
            currentOverText,
          )}</span>
          <span class="meta-pill" id="st-target">${escapeHtml(
            activeBatting && activeBatting.target
              ? `Need ${activeBatting.toWin} from ${activeBatting.ballsRemaining}`
              : "First innings",
          )}</span>
          <span class="meta-pill" id="st-venue">${escapeHtml(
            initialData.venueName ?? "Venue tbc",
          )}</span>
        </div>
      </section>
      <section class="summary-card">
        <div style="display:flex;align-items:center;gap:14px;padding-bottom:6px;border-bottom:1px solid var(--line)">
          ${renderLogo(initialData.teamB, "stats")}
          <div class="team-score-copy">
            <div class="team-short">${escapeHtml(
              shortTeamName(initialData.teamB),
            )}</div>
            <div class="team-score-value" id="st-team-b-score">${escapeHtml(
              initialData.inningsSummary.find(
                (entry) => entry.team === initialData.teamB.name,
              )?.score ?? "—",
            )}</div>
            <div class="team-score-sub">${escapeHtml(
              initialData.teamB.name,
            )}</div>
          </div>
        </div>
        <div class="summary-title">Latest</div>
        <div class="summary-value" id="st-last-ball">${escapeHtml(
          initialData.lastBallText,
        )}</div>
        <div class="summary-copy" id="st-toss">${escapeHtml(
          initialData.tossSummary ?? "Toss not recorded yet.",
        )}</div>
        <div class="summary-title">Innings</div>
        <div class="innings-switch" id="st-innings">${inningsPillsHtml}</div>
      </section>
    </div>
    <div class="stats-body">
      <section class="stats-panel">
        <div class="panel-head">
          <div>
            <h2 class="panel-title">Batters at crease</h2>
            <div class="panel-subtitle">Live batter card for the active innings.</div>
          </div>
        </div>
        <table class="score-table">
          <thead>
            <tr><th>Batter</th><th>R</th><th>B</th><th>4s</th><th>6s</th><th>SR</th></tr>
          </thead>
          <tbody id="st-batters">${statsBattersHtml}</tbody>
        </table>
      </section>
      <aside class="side-panel">
        <div class="side-stack">
          <section class="stack-card">
            <div class="stack-title">This over</div>
            <div class="balls-row" id="st-balls">${statsBallsHtml}</div>
          </section>
          <section class="stack-card">
            <div class="stack-title">Current bowler</div>
            <table class="score-table">
              <thead>
                <tr><th>Bowler</th><th>Ov</th><th>W</th><th>R</th><th>Econ</th></tr>
              </thead>
              <tbody id="st-bowler">${statsBowlerHtml}</tbody>
            </table>
          </section>
          <section class="stack-card">
            <div class="stack-title">Match notes</div>
            <div class="note-list" id="st-notes">${statsNotesHtml}</div>
          </section>
        </div>
      </aside>
    </div>
  </div>
</div>

<div id="view-break">
  <div class="break-shell">
    <div class="break-badge" id="br-badge">${escapeHtml(
      breakBadgeMap[safeBreakType] ?? "Break",
    )}</div>
    <div class="break-word" id="br-word">${escapeHtml(
      breakWordMap[safeBreakType] ?? "BREAK",
    )}</div>
    <div class="break-subtitle" id="br-subtitle">${escapeHtml(
      initialData.lastBallText,
    )}</div>
    <div class="break-brand">
      <div class="break-logo">
        ${
          overlayLogoSrc
            ? `<img src="${overlayLogoSrc}" alt="Swing Cricket" />`
            : ""
        }
        <span>SWING CRICKET</span>
      </div>
      <div class="break-tagline">Every Ball. Every Run. Every Player Matters.</div>
      <div class="break-copy">Live Scoring | Player Stats | Match Highlights</div>
      <div class="break-copy">This match is powered by Swing.</div>
    </div>
    <div class="break-grid" id="br-score">${breakCardsHtml}</div>
    <div class="break-hooks" id="br-hooks">${breakHooksHtml}</div>
  </div>
</div>

<div id="ev-layer"></div>
<script>
var INITIAL_DATA=${serializedInitialData};
var API=window.location.href.replace('/widget','').split('?')[0];
var STREAM=API+'/stream';
var VIEW='${safeView}';
var BREAK_TYPE='${safeBreakType}';
var POLL=${defaultPoll};
var prev=null;
var freeHitNext=false;
var eventTimer=null;
var fallbackTimer=null;
function g(id){return document.getElementById(id);}
function esc(v){return String(v||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#39;');}
function teamShort(team){if(!team)return'SW';if(team.shortName)return String(team.shortName).trim().toUpperCase();var base=(String(team.name||'SW').split('-')[0]||String(team.name||'SW')).trim();var compact=base.replace(/[^A-Za-z0-9]/g,'');if(compact&&compact.length<=6)return compact.toUpperCase();var initials=base.split(/\\s+/).map(function(part){return part[0]||'';}).join('');return(initials||compact||'SW').slice(0,4).toUpperCase();}
function playerShort(name){if(!name)return'—';var parts=String(name).trim().split(/\\s+/);if(parts.length===1)return parts[0];return parts[0][0]+'. '+parts.slice(1).join(' ');}
function oversText(value){return typeof value==='number'&&isFinite(value)?value.toFixed(1):'0.0';}
function rateText(value){return typeof value==='number'&&isFinite(value)?value.toFixed(2):'—';}
function tone(ball){if(!ball)return'dot';if(ball.isWicket)return'wicket';if(ball.outcome==='SIX')return'six';if(ball.outcome==='FOUR')return'boundary';if(ball.outcome==='WIDE'||ball.outcome==='NO_BALL')return'extra';if(ball.display==='•')return'dot';return'run';}
function ballMarkup(ball,variant){var cls=variant==='stats'?'ball-pill':'ball-chip';return '<span class="'+cls+' '+tone(ball)+'">'+esc(ball?ball.display:'•')+'</span>';}
function logoMarkup(team,variant){var cls='team-mark';if(variant==='stats')cls+=' stats-mark';if(variant==='break')cls+=' break-mark';var short=esc(teamShort(team));var name=esc(team&&team.name?team.name:short);if(team&&team.logoUrl){return '<div class="'+cls+'"><span class="team-mark-fallback" style="display:none">'+short+'</span><img src="'+esc(team.logoUrl)+'" alt="'+name+'" onerror="this.previousElementSibling.style.display=\\'grid\\';this.remove()"></div>';}return '<div class="'+cls+'"><span class="team-mark-fallback">'+short+'</span></div>';}
function battingTeams(data){var batting=data&&data.batting?data.batting:null;if(!batting)return{bat:data.teamA,bowl:data.teamB};var batIsA=batting.team===data.teamA.name;return{bat:batIsA?data.teamA:data.teamB,bowl:batIsA?data.teamB:data.teamA};}
function inningsCardHtml(data){return(data.inningsSummary||[]).map(function(inn){var active=Number(data.currentInnings)===Number(inn.inningsNumber)?' active':'';return '<div class="innings-pill'+active+'"><span class="innings-team">'+esc(inn.shortName)+'</span><span class="innings-score">'+esc(inn.score)+'</span><span class="innings-overs">'+esc(oversText(inn.overs))+' ov</span></div>';}).join('');}
function standardBallsHtml(data){var balls=(data.thisOver&&data.thisOver.length)?data.thisOver.slice(-6):new Array(6).fill(null);return balls.map(function(ball){return ballMarkup(ball,'standard');}).join('');}
function statsBallsHtml(data){return data.thisOver&&data.thisOver.length?data.thisOver.map(function(ball){return ballMarkup(ball,'stats');}).join(''):'<span class="empty-copy">No balls yet.</span>';}
function breakHooksHtml(data){var hooks=[];if(data&&data.striker){hooks.push({label:'Set batter',value:data.striker.name+' '+data.striker.runs+'* ('+data.striker.balls+')'});}if(data&&data.nonStriker){hooks.push({label:'Supporting batter',value:data.nonStriker.name+' '+data.nonStriker.runs+' ('+data.nonStriker.balls+')'});}if(data&&data.bowler){hooks.push({label:'Bowling impact',value:data.bowler.name+' '+data.bowler.wickets+'/'+data.bowler.runs+' in '+oversText(data.bowler.overs)+' ov'});}if(!hooks.length){hooks.push({label:'Match pulse',value:data&&data.lastBallText?data.lastBallText:'Score update coming through.'});}return hooks.slice(0,3).map(function(hook){return '<div class="break-hook"><div class="break-hook-label">'+esc(hook.label)+'</div><div class="break-hook-value">'+esc(hook.value)+'</div></div>';}).join('');}
function boundaryRun(data){var balls=(data&&data.thisOver?data.thisOver:[]).slice().reverse();var count=0;for(var i=0;i<balls.length;i+=1){var ball=balls[i];if(ball&&(ball.outcome==='FOUR'||ball.outcome==='SIX')){count+=1;continue;}break;}return count;}
function wicketRun(data){var balls=(data&&data.thisOver?data.thisOver:[]).slice().reverse();var count=0;for(var i=0;i<balls.length;i+=1){var ball=balls[i];if(ball&&ball.isWicket){count+=1;continue;}break;}return count;}
function eventPayload(kind,data){var batter=data&&data.striker?playerShort(data.striker.name):'The batter';var bowler=data&&data.bowler?playerShort(data.bowler.name):'The bowler';var line=data&&data.lastBallText?data.lastBallText:'Swing keeps you closer to the game.';var boundaries=boundaryRun(data);var wickets=wicketRun(data);if(kind==='four'){return{chip:'Boundary',word:'FOUR',sub:boundaries>=2?batter+' is on a spree':batter+' finds the rope',line:line,duration:2200,anim:'evSlideUp'};}if(kind==='six'){return{chip:'Maximum',word:'SIX',sub:boundaries>=2?batter+' goes back to back':batter+' launches it into the crowd',line:line,duration:2600,anim:'evScale'};}if(kind==='wicket'){if(wickets===2){return{chip:'Pressure',word:'HAT-TRICK BALL',sub:bowler+' is now on a hat-trick',line:line,duration:3000,anim:'evShake'};}return{chip:'Breakthrough',word:'WICKET',sub:bowler+' strikes for a big breakthrough',line:line,duration:3000,anim:'evShake'};}return{chip:'Advantage',word:'FREE HIT',sub:'Next ball is free for the striker',line:line,duration:2200,anim:'evPulse'};}
function renderStandard(data){var teams=battingTeams(data);var inningsA=(data.inningsSummary||[]).find(function(entry){return entry.team===data.teamA.name;});var inningsB=(data.inningsSummary||[]).find(function(entry){return entry.team===data.teamB.name;});var isComplete=data.status==='COMPLETED';g('s-batting-logo').innerHTML=logoMarkup(teams.bat,'standard');g('s-bowling-logo').innerHTML=logoMarkup(teams.bowl,'standard');g('s-batting-short').textContent=teamShort(teams.bat);g('s-batting-name').textContent=teams.bat&&teams.bat.name?teams.bat.name:'—';g('s-bowling-short').textContent=teamShort(teams.bowl);g('s-bowling-name').textContent=teams.bowl&&teams.bowl.name?teams.bowl.name:'—';g('s-status-txt').textContent=isComplete?'FINAL':data.status==='IN_PROGRESS'?'LIVE':String(data.status||'SCHEDULED').replace(/_/g,' ');var dot=g('s-live-dot');if(dot)dot.style.display=data.status==='IN_PROGRESS'?'inline-block':'none';g('s-matchup').textContent=teamShort(data.teamA)+' v '+teamShort(data.teamB);if(!data.batting){g('s-score').textContent='—';g('s-overs-txt').textContent=isComplete?'Final':'Awaiting start';g('s-crr').textContent=data.resultText||'First ball pending';g('s-chase').textContent=data.finalScoresText||data.lastBallText||'';g('s-toss-txt').textContent=data.tossSummary||'Toss awaiting';g('s-b1').textContent=inningsA?teamShort(data.teamA):'—';g('s-b1r').textContent=inningsA?inningsA.score:'—';g('s-b1b').textContent='';g('s-b2').textContent=inningsB?teamShort(data.teamB):'—';g('s-b2r').textContent=inningsB?inningsB.score:'—';g('s-b2b').textContent='';g('s-bwl').textContent=data.resultText||'—';g('s-bwl-f').textContent='';g('s-bwl-ov').textContent='';g('s-balls').innerHTML='';g('s-pp-badge').style.display='none';return;}g('s-score').textContent=data.batting.runs+'/'+data.batting.wickets;g('s-overs-txt').textContent=isComplete?'Final':oversText(data.batting.overs)+' ov';g('s-crr').textContent=isComplete?(data.resultText||'Match complete'):(data.batting.rrr!==null?'RRR '+rateText(data.batting.rrr):'CRR '+rateText(data.batting.crr));g('s-chase').textContent=isComplete?(data.finalScoresText||data.lastBallText||''):(data.batting.target&&data.batting.toWin!==null&&data.batting.ballsRemaining!==null?'Need '+data.batting.toWin+' from '+data.batting.ballsRemaining:(data.lastBallText||''));g('s-toss-txt').textContent=isComplete?(data.tossSummary||'Match complete'):(data.tossSummary||'Toss awaiting');g('s-b1').textContent=data.striker?playerShort(data.striker.name):'—';g('s-b1r').textContent=data.striker?String(data.striker.runs):'—';g('s-b1b').textContent=data.striker?'('+data.striker.balls+')':'';g('s-b2').textContent=data.nonStriker?playerShort(data.nonStriker.name):'—';g('s-b2r').textContent=data.nonStriker?String(data.nonStriker.runs):'—';g('s-b2b').textContent=data.nonStriker?'('+data.nonStriker.balls+')':'';g('s-bwl').textContent=data.bowler?data.bowler.name:'—';g('s-bwl-f').textContent=data.bowler?data.bowler.wickets+'/'+data.bowler.runs:'—';g('s-bwl-ov').textContent=data.bowler?oversText(data.bowler.overs)+' ov':'';g('s-balls').innerHTML=standardBallsHtml(data);g('s-pp-badge').style.display=!isComplete&&data.isPowerplay?'inline-flex':'none';}
function renderStats(data){var inningsA=(data.inningsSummary||[]).find(function(entry){return entry.team===data.teamA.name;});var inningsB=(data.inningsSummary||[]).find(function(entry){return entry.team===data.teamB.name;});var batting=data.batting;g('st-team-a-score').textContent=inningsA?inningsA.score:'—';g('st-team-b-score').textContent=inningsB?inningsB.score:'—';g('st-score').textContent=batting?batting.score:'—';g('st-title').textContent=teamShort(data.teamA)+' v '+teamShort(data.teamB);g('st-meta').textContent=batting?batting.team+' batting · '+oversText(batting.overs)+' ov':'Awaiting the start';g('st-over').textContent=data.thisOverNumber!==null?'Over '+(Number(data.thisOverNumber)+1):'Over —';g('st-target').textContent=batting&&batting.target?'Need '+batting.toWin+' from '+batting.ballsRemaining:'First innings';g('st-venue').textContent=data.venueName||'Venue tbc';g('st-last-ball').textContent=data.resultText||data.lastBallText||'—';g('st-toss').textContent=data.tossSummary||'Toss not recorded yet.';g('st-innings').innerHTML=inningsCardHtml(data);g('st-balls').innerHTML=statsBallsHtml(data);var batters=[data.striker,data.nonStriker].filter(Boolean);g('st-batters').innerHTML=batters.length?batters.map(function(player,index){return '<tr><td><div class="player-line"><span class="player-name">'+esc(player.name)+(index===0?' *':'')+'</span><span class="player-sub">'+(index===0?'On strike':'Non-striker')+'</span></div></td><td>'+player.runs+'</td><td>'+player.balls+'</td><td>'+player.fours+'</td><td>'+player.sixes+'</td><td>'+rateText(player.strikeRate)+'</td></tr>';}).join(''):'<tr><td colspan="6" class="empty-copy table-empty">Waiting for batting data.</td></tr>';g('st-bowler').innerHTML=data.bowler?'<tr><td><div class="player-line"><span class="player-name">'+esc(data.bowler.name)+'</span><span class="player-sub">Current bowler</span></div></td><td>'+oversText(data.bowler.overs)+'</td><td>'+data.bowler.wickets+'</td><td>'+data.bowler.runs+'</td><td>'+rateText(data.bowler.economy)+'</td></tr>':'<tr><td colspan="5" class="empty-copy table-empty">Bowler yet to begin.</td></tr>';var notes=[data.resultText,data.lastBallText,batting&&batting.target?'Target '+batting.target+' · Need '+batting.toWin+' from '+batting.ballsRemaining:null,data.tossSummary,data.venueName?'Venue · '+data.venueName:null].filter(Boolean);g('st-notes').innerHTML=notes.length?notes.map(function(note){return '<div class="note-card"><span class="note-accent"></span><span>'+esc(note)+'</span></div>';}).join(''):'<div class="empty-copy">No live notes yet.</div>';}
function renderBreak(data){var titleMap={drinks:'DRINKS',innings:'INNINGS',powerplay:'POWERPLAY'};var badgeMap={drinks:'Drinks Break',innings:'Innings Break',powerplay:'Powerplay Break'};g('br-word').textContent=titleMap[BREAK_TYPE]||'BREAK';g('br-badge').textContent=badgeMap[BREAK_TYPE]||'Break';g('br-subtitle').textContent=data.resultText||data.lastBallText||'Score update coming through.';g('br-score').innerHTML=[data.teamA,data.teamB].map(function(team){var inn=(data.inningsSummary||[]).find(function(entry){return entry.team===team.name;});return '<div class="break-card">'+logoMarkup(team,'break')+'<div class="break-team-copy"><div class="break-team-short">'+esc(teamShort(team))+'</div><div class="break-team-name">'+esc(team.name)+'</div></div><div class="break-team-score">'+esc(inn?inn.score:'—')+'</div><div class="break-team-overs">'+esc(inn?oversText(inn.overs)+' ov':'Yet to bat')+'</div></div>';}).join('');g('br-hooks').innerHTML=breakHooksHtml(data);}
function detectEvent(data){if(!prev||!data||!data.thisOver)return;var prevLen=prev.thisOver?prev.thisOver.length:0;var currLen=data.thisOver?data.thisOver.length:0;var inningsChanged=prev.currentInnings!==data.currentInnings;if(currLen<=prevLen&&!inningsChanged)return;var last=data.thisOver[data.thisOver.length-1];if(!last)return;var wasFreeHit=freeHitNext;freeHitNext=last.outcome==='NO_BALL';if(last.isWicket&&!wasFreeHit)fireEvent('wicket',data);else if(last.outcome==='SIX')fireEvent('six',data);else if(last.outcome==='FOUR')fireEvent('four',data);else if(wasFreeHit&&!last.isWicket)fireEvent('freehit',data);}
function fireEvent(kind,data){if(eventTimer)clearTimeout(eventTimer);var payload=eventPayload(kind,data);var el=g('ev-layer');el.style.display='flex';el.innerHTML='<div class="ev-container ev-'+kind+'" style="animation:'+payload.anim+' '+payload.duration+'ms ease forwards"><div class="event-chip">'+payload.chip+'</div><div class="event-word">'+payload.word+'</div><div class="event-sub">'+payload.sub+'</div><div class="event-line">'+payload.line+'</div></div>';eventTimer=setTimeout(function(){el.style.display='none';el.innerHTML='';},payload.duration);}
function applyData(data){if(!data)return;detectEvent(data);var active=data.scene||VIEW;if(data.scene&&data.breakType)BREAK_TYPE=data.breakType;var std=g('view-standard');var sts=g('view-stats');var brk=g('view-break');if(active==='clean'){if(std)std.style.display='none';if(sts)sts.style.display='none';if(brk)brk.style.display='none';}else if(active==='stats'){if(std)std.style.display='none';if(sts)sts.style.display='block';if(brk)brk.style.display='none';renderStats(data);}else if(active==='break'){if(std)std.style.display='none';if(sts)sts.style.display='none';if(brk)brk.style.display='grid';renderBreak(data);}else{if(std)std.style.display='flex';if(sts)sts.style.display='none';if(brk)brk.style.display='none';renderStandard(data);}prev=data;}
async function pollOnce(){try{var response=await fetch(API,{cache:'no-store'});if(!response.ok)return;var payload=await response.json();applyData(payload.data);}catch(_e){}}
function startPolling(){if(fallbackTimer)return;fallbackTimer=setInterval(function(){void pollOnce();},POLL);}
function startRealtime(){if(!window.EventSource){startPolling();return;}try{var stream=new EventSource(STREAM);stream.addEventListener('overlay',function(evt){var payload=JSON.parse(evt.data);applyData(payload);});stream.onerror=function(){stream.close();startPolling();};window.addEventListener('beforeunload',function(){stream.close();});}catch(_e){startPolling();}}
applyData(INITIAL_DATA);
startRealtime();
</script>
</body>
</html>`;

    return reply
      .header("Content-Type", "text/html; charset=utf-8")
      .header("Cache-Control", "no-store")
      .send(html);
  });

  // GET /public/overlay/:matchId/widget — OBS/browser-source overlay
  // ?view=standard | stats | break
  // ?type=drinks | innings | powerplay
  // ?poll=1000 (fallback polling interval)
  app.get("/overlay/:matchId/widget-legacy", async (request, reply) => {
    const { matchId } = request.params as { matchId: string };
    const {
      poll = "1000",
      view = "standard",
      type = "drinks",
    } = request.query as {
      poll?: string;
      view?: string;
      type?: string;
    };

    const safeView = ["standard", "stats", "break"].includes(view)
      ? view
      : "standard";
    const safeBreakType = ["drinks", "innings", "powerplay"].includes(type)
      ? type
      : "drinks";

    const initialData = await buildOverlayState(matchId);
    if (!initialData) {
      return reply
        .status(404)
        .header("Content-Type", "text/html; charset=utf-8")
        .send(
          `<!DOCTYPE html><html><body style="margin:0;display:grid;place-items:center;height:100vh;background:#050814;color:#fff;font-family:system-ui,sans-serif">Match not found</body></html>`,
        );
    }

    const serializedInitialData = JSON.stringify(initialData).replace(
      /</g,
      "\\u003c",
    );
    const defaultPoll = Math.max(750, parseInt(poll, 10) || 1000);

    const html = `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<title>Swing Live Overlay</title>
<meta name="viewport" content="width=device-width, initial-scale=1"/>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Oswald:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
/* ── reset ── */
html,body{margin:0;padding:0;width:1920px;height:1080px;overflow:hidden;background:transparent}
*{box-sizing:border-box}
body{font-family:'Inter',system-ui,sans-serif;color:#fff;-webkit-font-smoothing:antialiased}
.muted{color:rgba(255,255,255,.62)}
.tiny{font-size:10px;letter-spacing:1.5px;text-transform:uppercase}

/* ── STANDARD: broadcast bar at bottom ── */
#view-standard{
  display:${safeView === "standard" ? "flex" : "none"};
  flex-direction:column;
  position:fixed;
  bottom:0;left:0;right:0;width:100%;height:148px;
}
#s-commentary-strip{
  height:26px;background:rgba(2,14,6,0.98);
  border-top:1px solid rgba(230,180,0,0.12);
  display:flex;align-items:center;padding:0 20px;gap:10px;overflow:hidden;flex-shrink:0;
}
.s-live-badge{
  display:flex;align-items:center;gap:5px;
  font-family:'Oswald',sans-serif;font-size:9px;font-weight:700;
  letter-spacing:2px;text-transform:uppercase;color:#22c55e;flex-shrink:0;
}
.s-live-badge-dot{width:6px;height:6px;border-radius:50%;background:#22c55e;animation:livePulse 1.4s infinite;}
#s-commentary-text{font-size:11px;color:rgba(255,255,255,.65);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;flex:1;}
@keyframes livePulse{0%,100%{box-shadow:0 0 0 0 rgba(34,197,94,.55)}50%{box-shadow:0 0 0 7px rgba(34,197,94,0)}}
/* Main bar */
#s-bar{
  flex:1;
  background:linear-gradient(to bottom,rgba(5,26,13,0.97),rgba(3,18,9,0.99));
  border-top:2px solid rgba(230,180,0,0.5);
  box-shadow:0 -4px 28px rgba(0,0,0,.55);
  display:flex;align-items:stretch;
}
/* Outer team logos */
.s-outer-logo{width:120px;flex-shrink:0;display:flex;align-items:center;justify-content:center;padding:10px 14px;}
.s-logo-circle{
  width:88px;height:88px;border-radius:50%;
  border:3px solid rgba(230,180,0,0.5);
  background:rgba(255,255,255,0.07);
  overflow:hidden;display:grid;place-items:center;
  font-family:'Oswald',sans-serif;font-size:19px;font-weight:700;color:#FFD700;
}
.s-logo-circle img{width:100%;height:100%;object-fit:cover}
/* Batters panel */
.s-batters-panel{
  width:300px;flex-shrink:0;
  display:flex;flex-direction:column;justify-content:center;gap:10px;
  padding:0 14px;border-right:1px solid rgba(255,255,255,0.09);
}
.s-batter-row{display:flex;align-items:center;gap:7px}
.s-bat-icon{font-size:11px;flex-shrink:0;opacity:0.7}
.s-batter-name{font-size:13px;font-weight:600;color:#fff;flex:1;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.s-batter-name.ns{color:rgba(255,255,255,0.58)}
.s-batter-runs{font-family:'Oswald',sans-serif;font-size:21px;line-height:1;color:#fff;flex-shrink:0;}
.s-batter-balls{font-size:11px;color:rgba(255,255,255,0.38);margin-left:3px;flex-shrink:0;}
/* Center score box */
#s-center-box{
  flex:1;min-width:0;
  display:flex;flex-direction:column;align-items:center;justify-content:center;
  background:rgba(8,42,20,0.88);
  border-left:1px solid rgba(255,255,255,0.07);
  border-right:1px solid rgba(255,255,255,0.07);
  padding:6px 20px;text-align:center;position:relative;
}
#s-matchup{font-size:11px;letter-spacing:2.5px;text-transform:uppercase;color:rgba(255,255,255,0.45);margin-bottom:2px;}
.s-score-row{display:flex;align-items:center;gap:10px;}
#s-score{font-family:'Oswald',sans-serif;font-size:58px;font-weight:700;line-height:1;color:#fff;letter-spacing:-1px;}
#s-pp-badge{background:#15803d;color:#fff;font-family:'Oswald',sans-serif;font-size:12px;font-weight:700;padding:3px 9px;border-radius:4px;letter-spacing:1px;display:none;}
#s-overs-txt{font-family:'Oswald',sans-serif;font-size:18px;font-weight:600;color:rgba(255,255,255,0.55);letter-spacing:1px;}
#s-toss-txt{font-size:10px;letter-spacing:1.5px;text-transform:uppercase;color:rgba(255,215,0,0.52);margin-top:4px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:100%;}
#s-crr{font-size:11px;color:#4ade80;margin-top:2px;font-weight:700;}
#s-chase{font-size:10px;color:#fb923c;font-weight:600;display:none;white-space:nowrap;margin-top:1px;}
#s-dot{position:absolute;top:8px;right:10px;width:8px;height:8px;border-radius:50%;background:#22c55e;animation:livePulse 1.4s infinite;display:none;box-shadow:0 0 8px rgba(34,197,94,.8);}
#s-status-txt{position:absolute;top:8px;left:10px;font-size:8px;letter-spacing:2px;text-transform:uppercase;color:rgba(255,255,255,0.28);}
/* Bowler panel */
.s-bowler-panel{
  width:320px;flex-shrink:0;
  display:flex;flex-direction:column;justify-content:center;
  padding:0 16px;border-left:1px solid rgba(255,255,255,0.09);
}
.s-bowler-lbl{font-size:9px;letter-spacing:2px;text-transform:uppercase;color:rgba(255,255,255,0.28);margin-bottom:4px;}
#s-bwl{font-size:15px;font-weight:700;color:#fff;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.s-bowler-stats-row{display:flex;align-items:baseline;gap:8px;margin-top:3px;}
#s-bwl-f{font-family:'Oswald',sans-serif;font-size:22px;line-height:1;color:#fff;}
#s-bwl-ov{font-size:13px;color:rgba(255,255,255,0.42);}
.s-balls-row{display:flex;align-items:center;gap:5px;margin-top:7px;flex-wrap:wrap;}
.sb-ball{
  width:28px;height:28px;border-radius:50%;
  display:grid;place-items:center;
  font-family:'Oswald',sans-serif;font-size:11px;font-weight:700;
  border:1px solid rgba(255,255,255,0.1);background:rgba(255,255,255,0.08);flex-shrink:0;
}
.sb-ball.dot{color:rgba(255,255,255,0.38);background:rgba(255,255,255,0.06)}
.sb-ball.run1{background:rgba(255,255,255,0.18)}
.sb-ball.boundary{background:#1d4ed8;border-color:#3b82f6;color:#fff}
.sb-ball.six{background:#7c3aed;border-color:#a855f7;color:#fff}
.sb-ball.wicket{background:#b91c1c;border-color:#ef4444;color:#fff}
.sb-ball.extra{background:#c2410c;border-color:#f97316;color:#fff}

/* ── stats/break shared ── */
.overlay-shell{pointer-events:none}
.balls{display:flex;align-items:center;gap:6px;flex-wrap:wrap}
.ball{
  width:32px;height:32px;border-radius:999px;
  display:grid;place-items:center;
  font-family:'Oswald',sans-serif;font-size:12px;font-weight:700;
  border:1px solid rgba(255,255,255,.1);background:rgba(255,255,255,.06);
}
.ball.dot{color:rgba(255,255,255,.42)}
.ball.run{background:rgba(255,255,255,.15)}
.ball.boundary{background:#1d4ed8}
.ball.six{background:#7c3aed}
.ball.wicket{background:#b91c1c}
.ball.extra{background:#c2410c}
.player-score{font-family:'Oswald',sans-serif;font-size:24px;line-height:1;white-space:nowrap}
.player-score small{font-size:14px;color:rgba(255,255,255,.62)}
.last-ball{padding:12px 16px;border-top:1px solid rgba(255,255,255,.08);color:rgba(255,255,255,.86);font-size:13px}

/* ── Stats view ── */
#view-stats{
  position:fixed;inset:0;
  display:${safeView === "stats" ? "flex" : "none"};
  flex-direction:column;padding:24px;gap:18px;
  background:linear-gradient(180deg,rgba(5,14,38,0.97) 0%,rgba(2,8,24,1) 100%);
}
.stats-header{display:grid;grid-template-columns:1.1fr 1fr;gap:18px}
.stats-hero{
  padding:18px 22px;border-radius:22px;
  background:rgba(255,255,255,.03);
  border:1px solid rgba(230,180,0,0.18);
}
.stats-title{font-family:'Oswald',sans-serif;font-size:18px;letter-spacing:.6px;text-transform:uppercase;color:#FFD700}
.stats-score{font-family:'Oswald',sans-serif;font-size:54px;line-height:1;margin-top:8px}
.innings-switch{display:flex;gap:10px;flex-wrap:wrap;margin-top:16px}
.innings-pill{
  padding:10px 14px;border-radius:14px;
  border:1px solid rgba(255,255,255,.08);background:rgba(255,255,255,.03);min-width:150px;
}
.innings-pill.active{background:rgba(5,14,38,0.7);border-color:rgba(230,180,0,.35)}
.stats-side{
  padding:18px 22px;border-radius:22px;
  background:rgba(255,255,255,.03);
  border:1px solid rgba(255,255,255,.08);
  display:flex;flex-direction:column;justify-content:space-between;
}
.stats-body{flex:1;display:grid;grid-template-columns:1.35fr .95fr;gap:18px}
.table-panel,.side-panel{
  border-radius:22px;
  background:rgba(255,255,255,.03);
  border:1px solid rgba(255,255,255,.08);padding:18px 20px;
}
.section-title{
  font-family:'Oswald',sans-serif;font-size:13px;letter-spacing:1.6px;
  text-transform:uppercase;color:rgba(255,215,0,.54);margin-bottom:14px;
}
.score-table{width:100%;border-collapse:collapse}
.score-table th,.score-table td{padding:12px 0;border-bottom:1px solid rgba(255,255,255,.06);text-align:right}
.score-table th:first-child,.score-table td:first-child{text-align:left}
.score-table th{font-size:11px;color:rgba(255,255,255,.45);font-weight:600}
.score-table td{font-size:14px;color:rgba(255,255,255,.78)}
.score-table td:first-child{font-weight:600;color:#fff}
.recent-list{display:flex;flex-direction:column;gap:10px}
.recent-card{border-radius:14px;border:1px solid rgba(255,255,255,.07);background:rgba(255,255,255,.03);padding:12px 14px}
.side-metric{display:flex;justify-content:space-between;gap:12px;padding:8px 0;border-bottom:1px solid rgba(255,255,255,.06)}
.side-metric:last-child{border-bottom:none}

/* ── Break view ── */
#view-break{
  position:fixed;inset:0;
  display:${safeView === "break" ? "flex" : "none"};
  align-items:center;justify-content:center;
  background:linear-gradient(160deg,rgba(3,10,28,0.98) 0%,rgba(5,14,38,0.97) 60%,rgba(1,5,18,1) 100%);
}
.break-shell{
  width:min(1200px,calc(100vw - 60px));
  text-align:center;position:relative;padding:0 32px;
}
.swing-brand{margin-bottom:28px;}
.swing-brand-logo{
  font-family:'Oswald',sans-serif;font-size:20px;letter-spacing:7px;
  color:#FFD700;text-transform:uppercase;opacity:0.95;
  text-shadow:0 0 20px rgba(255,215,0,0.35);
}
.swing-tagline{
  font-size:10px;letter-spacing:4.5px;text-transform:uppercase;
  color:rgba(255,215,0,0.55);margin-top:7px;
  animation:taglineFade 3.5s ease-in-out infinite alternate;
}
@keyframes taglineFade{
  0%{opacity:0.4;letter-spacing:3.5px}
  100%{opacity:0.85;letter-spacing:5.5px}
}
.break-badge{
  display:inline-block;padding:5px 20px;border-radius:40px;
  border:1px solid rgba(230,180,0,0.3);background:rgba(230,180,0,0.07);
  font-size:10px;letter-spacing:4px;text-transform:uppercase;
  color:rgba(255,255,255,0.55);margin-bottom:18px;
}
.break-word{
  font-family:'Oswald',sans-serif;font-size:86px;line-height:1;
  letter-spacing:3px;text-transform:uppercase;color:#FFD700;
  text-shadow:0 0 50px rgba(255,215,0,0.25);margin-bottom:4px;
}
.break-score{display:flex;justify-content:center;gap:18px;margin-top:32px;flex-wrap:wrap}
.break-team{
  min-width:190px;flex:1;max-width:270px;
  padding:20px 22px;border-radius:20px;
  border:1px solid rgba(230,180,0,0.16);
  background:rgba(255,255,255,.04);backdrop-filter:blur(8px);
}
.break-team-logo{
  width:54px;height:54px;border-radius:50%;
  background:rgba(255,255,255,0.08);border:2px solid rgba(230,180,0,0.2);
  display:flex;align-items:center;justify-content:center;
  margin:0 auto 10px;overflow:hidden;
  font-family:'Oswald',sans-serif;font-size:13px;color:#FFD700;font-weight:700;
}
.break-team-logo img{width:100%;height:100%;object-fit:contain}
.break-team-name{font-size:10px;letter-spacing:2.5px;text-transform:uppercase;color:rgba(255,255,255,.5);margin-bottom:8px}
.break-team-score{font-family:'Oswald',sans-serif;font-size:46px;line-height:1;color:#fff}
.break-team-overs{font-size:11px;color:rgba(255,255,255,.38);margin-top:7px;letter-spacing:1px}
.br-marquee-wrap{
  margin-top:36px;overflow:hidden;padding:13px 0;
  border-top:1px solid rgba(230,180,0,0.1);
}
.br-marquee{
  display:inline-block;white-space:nowrap;
  font-size:10px;letter-spacing:3.5px;text-transform:uppercase;
  color:rgba(255,215,0,0.5);
  animation:marqueeScroll 22s linear infinite;
}
@keyframes marqueeScroll{
  0%{transform:translateX(100vw)}
  100%{transform:translateX(-100%)}
}

/* ── Event animations (center screen, transparent bg) ── */
#ev-layer{
  position:fixed;inset:0;display:none;
  align-items:center;justify-content:center;
  pointer-events:none;z-index:200;
}
.ev-container{
  display:flex;flex-direction:column;align-items:center;justify-content:center;
  padding:60px 80px;border-radius:32px;
}
.ev-container.ev-four{background:radial-gradient(ellipse at center,rgba(29,78,216,0.18) 0%,transparent 70%)}
.ev-container.ev-six{background:radial-gradient(ellipse at center,rgba(124,58,237,0.18) 0%,transparent 70%)}
.ev-container.ev-wicket{background:radial-gradient(ellipse at center,rgba(185,28,28,0.18) 0%,transparent 70%)}
.ev-container.ev-freehit{background:radial-gradient(ellipse at center,rgba(245,158,11,0.18) 0%,transparent 70%)}

.event-word{
  font-family:'Oswald',sans-serif;font-size:112px;line-height:1;
  letter-spacing:-2px;text-align:center;font-weight:700;
}
.event-sub{
  margin-top:12px;text-align:center;font-size:18px;
  letter-spacing:5px;text-transform:uppercase;color:rgba(255,255,255,.7);
}
.ev-container.ev-four .event-word{
  color:#3b82f6;
  text-shadow:0 0 40px rgba(59,130,246,0.9),0 0 80px rgba(59,130,246,0.5);
}
.ev-container.ev-six .event-word{
  color:#a855f7;
  text-shadow:0 0 40px rgba(168,85,247,0.9),0 0 80px rgba(168,85,247,0.5);
}
.ev-container.ev-wicket .event-word{
  color:#ef4444;
  text-shadow:0 0 40px rgba(239,68,68,0.9),0 0 80px rgba(239,68,68,0.5);
}
.ev-container.ev-freehit .event-word{
  color:#f59e0b;
  text-shadow:0 0 40px rgba(245,158,11,0.9),0 0 80px rgba(245,158,11,0.5);
}

@keyframes evSlideUp{0%{opacity:0;transform:translateY(50px) scale(.9)}14%{opacity:1;transform:translateY(0) scale(1)}80%{opacity:1;transform:translateY(0) scale(1)}100%{opacity:0;transform:translateY(-30px) scale(.95)}}
@keyframes evScale{0%{opacity:0;transform:scale(1.5)}14%{opacity:1;transform:scale(1)}80%{opacity:1;transform:scale(1)}100%{opacity:0;transform:scale(.9)}}
@keyframes evShake{0%{opacity:0;transform:translateX(0) scale(.8)}6%{opacity:1;transform:translateX(-12px) scale(1.05)}12%{transform:translateX(12px)}18%{transform:translateX(-8px)}24%{opacity:1;transform:translateX(0) scale(1)}80%{opacity:1;transform:translateX(0)}100%{opacity:0;transform:translateX(0) scale(.95)}}
@keyframes evPulse{0%{opacity:0;transform:scale(.95)}10%{opacity:1;transform:scale(1.05)}20%{transform:scale(1)}55%{transform:scale(1.03)}70%{opacity:1;transform:scale(1)}100%{opacity:0;transform:scale(.97)}}

.hidden{display:none !important}
</style>
</head>
<body>

<!-- STANDARD VIEW: broadcast bar at bottom, transparent above -->
<div id="view-standard">
  <div id="s-bar">
    <!-- Batting team logo -->
    <div class="s-outer-logo"><div class="s-logo-circle" id="s-logo-bat">—</div></div>
    <!-- Batters -->
    <div class="s-batters-panel">
      <div class="s-batter-row">
        <span class="s-bat-icon">&#x1F3CF;</span>
        <span class="s-batter-name" id="s-b1">—</span>
        <span class="s-batter-runs" id="s-b1r">—</span>
        <span class="s-batter-balls" id="s-b1b"></span>
      </div>
      <div class="s-batter-row">
        <span class="s-bat-icon" style="opacity:0">&#x1F3CF;</span>
        <span class="s-batter-name ns" id="s-b2">—</span>
        <span class="s-batter-runs" style="font-size:16px;opacity:0.6" id="s-b2r">—</span>
        <span class="s-batter-balls" id="s-b2b"></span>
      </div>
    </div>
    <!-- Center score box -->
    <div id="s-center-box">
      <div id="s-status-txt">SCHEDULED</div>
      <div id="s-dot"></div>
      <div id="s-matchup">— vs —</div>
      <div class="s-score-row">
        <div id="s-score">—</div>
        <div id="s-pp-badge">PP</div>
        <div id="s-overs-txt"></div>
      </div>
      <div id="s-toss-txt"></div>
      <div id="s-crr"></div>
      <div id="s-chase"></div>
    </div>
    <!-- Bowler panel -->
    <div class="s-bowler-panel">
      <div class="s-bowler-lbl">Bowling</div>
      <div id="s-bwl">—</div>
      <div class="s-bowler-stats-row">
        <span id="s-bwl-f">—</span>
        <span id="s-bwl-ov"></span>
      </div>
      <div class="s-balls-row" id="s-balls"></div>
    </div>
    <!-- Bowling team logo -->
    <div class="s-outer-logo"><div class="s-logo-circle" id="s-logo-bowl">—</div></div>
  </div>
  <div id="s-commentary-strip">
    <div class="s-live-badge"><div class="s-live-badge-dot"></div>LIVE</div>
    <div id="s-commentary-text">Awaiting commentary…</div>
  </div>
</div>

<div id="view-stats" class="overlay-shell">
  <div class="stats-header">
    <div class="stats-hero">
      <div class="tiny muted">Live scoreboard</div>
      <div class="stats-title" id="st-title">Match Centre</div>
      <div class="stats-score" id="st-score">—</div>
      <div class="muted" id="st-meta">Awaiting live data</div>
      <div class="innings-switch" id="st-innings"></div>
    </div>
    <div class="stats-side">
      <div>
        <div class="section-title">Situation</div>
        <div class="side-metric"><span class="muted">Venue</span><span id="st-venue">—</span></div>
        <div class="side-metric"><span class="muted">Last ball</span><span id="st-last-ball">—</span></div>
        <div class="side-metric"><span class="muted">Current over</span><span id="st-over">—</span></div>
        <div class="side-metric"><span class="muted">Target</span><span id="st-target">—</span></div>
        <div class="side-metric"><span class="muted">Toss</span><span id="st-toss">—</span></div>
      </div>
      <div class="recent-card">
        <div class="tiny muted">This over</div>
        <div class="balls" id="st-balls" style="margin-top:10px"></div>
      </div>
    </div>
  </div>
  <div class="stats-body">
    <div class="table-panel">
      <div class="section-title">Batters</div>
      <table class="score-table">
        <thead>
          <tr><th>Batter</th><th>R</th><th>B</th><th>4s</th><th>6s</th><th>SR</th></tr>
        </thead>
        <tbody id="st-batters"></tbody>
      </table>
    </div>
    <div class="side-panel">
      <div class="section-title">Bowling + feed</div>
      <table class="score-table">
        <thead>
          <tr><th>Bowler</th><th>Ov</th><th>W</th><th>R</th><th>Econ</th></tr>
        </thead>
        <tbody id="st-bowler"></tbody>
      </table>
      <div class="section-title" style="margin-top:18px">Recent notes</div>
      <div class="recent-list" id="st-notes"></div>
    </div>
  </div>
</div>

<div id="view-break" class="overlay-shell">
  <div class="break-shell">
    <div class="swing-brand">
      <div class="swing-brand-logo">&#x26A1; SWING CRICKET</div>
      <div class="swing-tagline">INDIA&#x27;S CRICKET ECOSYSTEM</div>
    </div>
    <div class="break-badge" id="br-badge">Break</div>
    <div class="break-word" id="br-word">BREAK</div>
    <div class="break-score" id="br-score"></div>
    <div class="br-marquee-wrap">
      <div class="br-marquee">&#x26A1; SWING &mdash; Live Scores &middot; Tournaments &middot; Academies &middot; Arenas &mdash; Everything Cricket, One Platform &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&#x26A1; SWING &mdash; Live Scores &middot; Tournaments &middot; Academies &middot; Arenas &mdash; Everything Cricket, One Platform</div>
    </div>
  </div>
</div>

<!-- Event animation layer — sits center screen on top of everything -->
<div id="ev-layer"></div>

<script>
var INITIAL_DATA=${serializedInitialData};
var API=window.location.href.replace('/widget','').split('?')[0];
var STREAM=API+'/stream';
var VIEW='${safeView}';
var BREAK_TYPE='${safeBreakType}';
var POLL=${defaultPoll};
var prev=null;
var freeHitNext=false;
var eventTimer=null;
var fallbackTimer=null;

function g(id){return document.getElementById(id);}
function esc(v){return String(v||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');}
function shortName(team){
  if(!team) return 'SW';
  if(team.shortName) return String(team.shortName).toUpperCase();
  return String(team.name||'SW').split(/\s+/).map(function(p){return p[0]||'';}).join('').slice(0,4).toUpperCase();
}
function shortPlayer(name){
  if(!name) return '\u2014';
  var parts=String(name).trim().split(/\s+/);
  if(parts.length===1) return parts[0];
  return parts[0][0]+'. '+parts.slice(1).join(' ');
}
function ballCls(ball){
  if(!ball) return 'ball dot';
  if(ball.isWicket) return 'ball wicket';
  if(ball.outcome==='SIX') return 'ball six';
  if(ball.outcome==='FOUR') return 'ball boundary';
  if(ball.outcome==='WIDE'||ball.outcome==='NO_BALL') return 'ball extra';
  if(ball.display==='\u2022') return 'ball dot';
  return 'ball run';
}
function sbBallCls(ball){
  if(!ball) return 'sb-ball dot';
  if(ball.isWicket) return 'sb-ball wicket';
  if(ball.outcome==='SIX') return 'sb-ball six';
  if(ball.outcome==='FOUR') return 'sb-ball boundary';
  if(ball.outcome==='WIDE'||ball.outcome==='NO_BALL') return 'sb-ball extra';
  if(ball.display==='\u2022') return 'sb-ball dot';
  return 'sb-ball run1';
}
function showLogo(el,team){
  if(!el||!team) return;
  if(team.logoUrl){
    var sn=esc(shortName(team));
    el.innerHTML='<img src="'+esc(team.logoUrl)+'" alt="'+esc(team.name)+'" onerror="this.parentNode.textContent=\''+sn+'\'">';
    return;
  }
  el.textContent=shortName(team);
}
function renderStandard(data){
  var batting=data.batting;
  var isLive=data.status==='IN_PROGRESS';
  // Matchup label always shown
  g('s-matchup').textContent=(data.teamA?data.teamA.shortName:'?')+' vs '+(data.teamB?data.teamB.shortName:'?');
  // Toss always shown
  g('s-toss-txt').textContent=data.tossSummary||'';
  // Status dot
  g('s-dot').style.display=isLive?'block':'none';
  g('s-status-txt').textContent=isLive?'LIVE':String(data.status||'SCHEDULED').replace(/_/g,' ');
  if(!batting){
    g('s-score').textContent='\u2014';
    g('s-overs-txt').textContent='';
    g('s-crr').textContent='';
    g('s-chase').style.display='none';
    g('s-pp-badge').style.display='none';
    showLogo(g('s-logo-bat'),data.teamA);
    showLogo(g('s-logo-bowl'),data.teamB);
    return;
  }
  // Determine batting vs bowling team by name match
  var batIsA=batting.team===data.teamA.name;
  var batTeam=batIsA?data.teamA:data.teamB;
  var bowlTeam=batIsA?data.teamB:data.teamA;
  showLogo(g('s-logo-bat'),batTeam);
  showLogo(g('s-logo-bowl'),bowlTeam);
  // Score
  g('s-score').textContent=batting.runs+'/'+batting.wickets;
  var ov=batting.overs;
  g('s-overs-txt').textContent=(ov!==null&&ov!==undefined?(typeof ov.toFixed==='function'?ov.toFixed(1):ov):'')+' OV';
  // Powerplay badge
  var pp=data.isPowerplay;
  g('s-pp-badge').style.display=pp?'inline-block':'none';
  // CRR/RRR/chase
  var crr=batting.target&&batting.rrr?'RRR '+Number(batting.rrr).toFixed(2):(batting.crr?'CRR '+Number(batting.crr).toFixed(2):'');
  g('s-crr').textContent=crr;
  if(batting.target&&batting.toWin!==null&&batting.toWin!==undefined&&batting.ballsRemaining!==null){
    g('s-chase').style.display='block';
    g('s-chase').textContent='Need '+batting.toWin+' off '+batting.ballsRemaining+' balls';
  }else{
    g('s-chase').style.display='none';
  }
  // Batters
  g('s-b1').textContent=data.striker?shortPlayer(data.striker.name):'\u2014';
  g('s-b1r').textContent=data.striker?String(data.striker.runs):'\u2014';
  g('s-b1b').textContent=data.striker?'('+data.striker.balls+')':'';
  g('s-b2').textContent=data.nonStriker?shortPlayer(data.nonStriker.name):'\u2014';
  g('s-b2r').textContent=data.nonStriker?String(data.nonStriker.runs):'\u2014';
  g('s-b2b').textContent=data.nonStriker?'('+data.nonStriker.balls+')':'';
  // Bowler
  g('s-bwl').textContent=data.bowler?shortPlayer(data.bowler.name):'\u2014';
  g('s-bwl-f').textContent=data.bowler?data.bowler.wickets+'/'+data.bowler.runs:'\u2014';
  g('s-bwl-ov').textContent=data.bowler?(typeof data.bowler.overs.toFixed==='function'?data.bowler.overs.toFixed(1):data.bowler.overs):'';
  // Balls this over
  var balls=(data.thisOver||[]).slice(-6);
  g('s-balls').innerHTML=(balls.length?balls:new Array(6).fill(null)).map(function(ball){
    if(!ball) return '<div class="sb-ball dot">\u2022</div>';
    return '<div class="'+sbBallCls(ball)+'">'+esc(ball.display)+'</div>';
  }).join('');
  if(data.lastBallText) g('s-commentary-text').textContent=data.lastBallText;
}
function renderStats(data){
  var batting=data.batting;
  g('st-title').textContent=(data.teamA?data.teamA.shortName:'?')+' vs '+(data.teamB?data.teamB.shortName:'?');
  g('st-score').textContent=batting?batting.score:'\u2014';
  g('st-meta').textContent=batting?batting.team+' batting \u00b7 '+(typeof batting.overs.toFixed==='function'?batting.overs.toFixed(1):batting.overs)+' ov':'Awaiting live data';
  g('st-venue').textContent=data.venueName||'\u2014';
  g('st-last-ball').textContent=data.lastBallText||'\u2014';
  g('st-over').textContent=data.thisOverNumber!==null&&data.thisOverNumber!==undefined?'Over '+(Number(data.thisOverNumber)+1):'\u2014';
  g('st-target').textContent=batting&&batting.target?('Need '+batting.toWin+' off '+batting.ballsRemaining):'First innings';
  g('st-toss').textContent=data.tossSummary||'\u2014';
  g('st-innings').innerHTML=(data.inningsSummary||[]).map(function(inn){
    var active=Number(data.currentInnings)===Number(inn.inningsNumber)?' active':'';
    return '<div class="innings-pill'+active+'"><div class="tiny muted">Innings '+inn.inningsNumber+'</div><div style="font-weight:700;margin-top:4px">'+esc(inn.shortName)+' '+esc(inn.score)+'</div><div class="muted" style="margin-top:4px;font-size:12px">'+esc(String(inn.overs))+' ov</div></div>';
  }).join('');
  g('st-balls').innerHTML=(data.thisOver||[]).map(function(ball){
    return '<div class="'+ballCls(ball)+'">'+esc(ball.display)+'</div>';
  }).join('')||'<div class="muted">No balls yet.</div>';
  var batters=[data.striker,data.nonStriker].filter(Boolean);
  g('st-batters').innerHTML=batters.map(function(player,idx){
    var sr=player.strikeRate;
    return '<tr><td>'+esc(player.name)+(idx===0?' *':'')+'</td><td>'+player.runs+'</td><td>'+player.balls+'</td><td>'+player.fours+'</td><td>'+player.sixes+'</td><td>'+(typeof sr.toFixed==='function'?sr.toFixed(1):sr)+'</td></tr>';
  }).join('')||'<tr><td colspan="6" class="muted" style="text-align:left">Waiting for batting data.</td></tr>';
  g('st-bowler').innerHTML=data.bowler?'<tr><td>'+esc(data.bowler.name)+'</td><td>'+(typeof data.bowler.overs.toFixed==='function'?data.bowler.overs.toFixed(1):data.bowler.overs)+'</td><td>'+data.bowler.wickets+'</td><td>'+data.bowler.runs+'</td><td>'+(typeof data.bowler.economy.toFixed==='function'?data.bowler.economy.toFixed(2):data.bowler.economy)+'</td></tr>':'<tr><td colspan="5" class="muted" style="text-align:left">Bowler yet to begin.</td></tr>';
  var notes=[
    data.lastBallText,
    batting&&batting.target&&batting.toWin!==null?'Chase: '+batting.toWin+' needed off '+batting.ballsRemaining+' balls.':null,
    data.tossSummary,
    data.venueName?'Venue: '+data.venueName:null
  ].filter(Boolean);
  g('st-notes').innerHTML=notes.map(function(note){return '<div class="recent-card">'+esc(note)+'</div>';}).join('');
}
function renderBreak(data){
  var titleMap={drinks:'DRINKS',innings:'INNINGS',powerplay:'POWERPLAY'};
  var badgeMap={drinks:'Drinks Break',innings:'Innings Break',powerplay:'End of Powerplay'};
  g('br-word').textContent=titleMap[BREAK_TYPE]||'BREAK';
  var bb=g('br-badge'); if(bb) bb.textContent=badgeMap[BREAK_TYPE]||'Break';
  if(!data){g('br-score').innerHTML='';return;}
  var innings=(data.inningsSummary||[]);
  g('br-score').innerHTML=[data.teamA,data.teamB].map(function(team){
    if(!team) return '';
    var inn=innings.find(function(item){return item.team===team.name;});
    var logoHtml='';
    if(team.logoUrl){
      var sn=esc(shortName(team));
      logoHtml='<div class="break-team-logo"><img src="'+esc(team.logoUrl)+'" alt="'+sn+'" onerror="this.style.display=\'none\'"></div>';
    } else {
      logoHtml='<div class="break-team-logo">'+esc(shortName(team))+'</div>';
    }
    return '<div class="break-team">'+logoHtml+'<div class="break-team-name">'+esc(team.name)+'</div><div class="break-team-score">'+esc(inn?inn.score:'\u2014')+'</div><div class="break-team-overs">'+esc(inn?String(inn.overs)+' ov':'Yet to bat')+'</div></div>';
  }).join('');
}
function detectEvent(data){
  if(!prev||!data||!data.thisOver) return;
  var prevLen=prev.thisOver?prev.thisOver.length:0;
  var currLen=data.thisOver?data.thisOver.length:0;
  var inningsChanged=prev.currentInnings!==data.currentInnings;
  if(currLen<=prevLen&&!inningsChanged) return;
  var last=data.thisOver[data.thisOver.length-1];
  if(!last) return;
  var wasFreeHit=freeHitNext;
  freeHitNext=last.outcome==='NO_BALL';
  if(last.isWicket&&!wasFreeHit) fireEvent('wicket');
  else if(last.outcome==='SIX') fireEvent('six');
  else if(last.outcome==='FOUR') fireEvent('four');
  else if(wasFreeHit&&!last.isWicket) fireEvent('freehit');
}
function fireEvent(kind){
  if(eventTimer) clearTimeout(eventTimer);
  var word=''; var sub=''; var duration=2800; var anim='evSlideUp';
  if(kind==='four'){word='FOUR';sub='Boundary';duration=2200;anim='evSlideUp';}
  if(kind==='six'){word='SIX';sub='Maximum';duration=2800;anim='evScale';}
  if(kind==='wicket'){word='WICKET';sub='Big moment';duration=3200;anim='evShake';}
  if(kind==='freehit'){word='FREE HIT';sub='Next ball is free';duration=2200;anim='evPulse';}
  var el=g('ev-layer');
  el.style.display='flex';
  el.innerHTML='<div class="ev-container ev-'+kind+'" style="animation:'+anim+' '+duration+'ms ease forwards"><div class="event-word">'+word+'</div><div class="event-sub">'+sub+'</div></div>';
  eventTimer=setTimeout(function(){
    el.style.display='none';
    el.innerHTML='';
  },duration);
}
function applyData(data){
  if(!data) return;
  detectEvent(data);
  var active=data.scene||VIEW;
  if(data.scene&&data.breakType)BREAK_TYPE=data.breakType;
  var std=g('view-standard');var sts=g('view-stats');var brk=g('view-break');
  if(active==='clean'){if(std)std.style.display='none';if(sts)sts.style.display='none';if(brk)brk.style.display='none';}
  else if(active==='stats'){if(std)std.style.display='none';if(sts)sts.style.display='flex';if(brk)brk.style.display='none';renderStats(data);}
  else if(active==='break'){if(std)std.style.display='none';if(sts)sts.style.display='none';if(brk)brk.style.display='flex';renderBreak(data);}
  else{if(std)std.style.display='flex';if(sts)sts.style.display='none';if(brk)brk.style.display='none';renderStandard(data);}
  prev=data;
}
async function pollOnce(){
  try{
    var response=await fetch(API,{cache:'no-store'});
    if(!response.ok) return;
    var payload=await response.json();
    applyData(payload.data);
  }catch(_e){}
}
function startPolling(){
  if(fallbackTimer) return;
  fallbackTimer=setInterval(function(){void pollOnce();},POLL);
}
function startRealtime(){
  if(!window.EventSource){startPolling();return;}
  try{
    var stream=new EventSource(STREAM);
    stream.addEventListener('overlay',function(evt){
      var payload=JSON.parse(evt.data);
      applyData(payload);
    });
    stream.onerror=function(){stream.close();startPolling();};
    window.addEventListener('beforeunload',function(){stream.close();});
  }catch(_e){startPolling();}
}
applyData(INITIAL_DATA);
startRealtime();
</script>
</body>
</html>`;

    return reply
      .header("Content-Type", "text/html; charset=utf-8")
      .header("Cache-Control", "no-store")
      .send(html);
  });

  // GET /public/tournament/:slug/standings
  app.get("/tournament/:slug/standings", async (request, reply) => {
    const { slug } = request.params as { slug: string };
    const t = await prisma.tournament.findFirst({
      where: { OR: [{ slug }, { id: slug }], isPublic: true },
      select: { id: true },
    });
    if (!t) return reply.status(404).send({ error: "Tournament not found" });

    const raw = await prisma.tournamentStanding.findMany({
      where: { tournamentId: t.id, team: { isConfirmed: true } },
      include: {
        team: { select: { teamName: true } },
        group: { select: { name: true } },
      },
      orderBy: [{ groupId: "asc" }, { points: "desc" }, { nrr: "desc" }],
    });
    const standings = raw.map((s) => ({
      id: s.id,
      teamName: s.team.teamName,
      played: s.played,
      won: s.won,
      lost: s.lost,
      tied: s.tied,
      noResult: s.noResult,
      points: s.points,
      netRunRate: s.nrr,
      groupId: s.groupId,
      groupName: s.group?.name ?? null,
      position: s.position,
    }));
    return reply.send({ data: standings });
  });

  // GET /public/tournament/:slug/leaderboard
  // IP is the single source of truth — Player of Tournament = most IP earned across all tournament matches.
  app.get("/tournament/:slug/leaderboard", async (request, reply) => {
    const { slug } = request.params as { slug: string };
    const t = await prisma.tournament.findFirst({
      where: { OR: [{ slug }, { id: slug }], isPublic: true },
      select: { id: true },
    });
    if (!t) return reply.status(404).send({ error: "Tournament not found" });

    const matches = await prisma.match.findMany({
      where: { tournamentId: t.id },
      select: { id: true },
    });
    const matchIds = matches.map((m) => m.id);

    if (matchIds.length === 0) {
      return reply.send({
        data: {
          topBatsmen: [],
          topBowlers: [],
          topFielders: [],
          playerOfTournament: null,
          tournamentTotals: {
            totalRuns: 0, totalFours: 0, totalSixes: 0,
            totalWickets: 0, matchesPlayed: 0, totalIpAwarded: 0,
          },
        },
      });
    }

    // Aggregate per-player match stats and IP earned in parallel
    const [statsRaw, ipRaw, totalsRaw] = await Promise.all([
      prisma.playerMatchStats.groupBy({
        by: ["playerProfileId"],
        where: { matchId: { in: matchIds } },
        _sum: {
          runs: true, balls: true, fours: true, sixes: true,
          wickets: true, oversBowled: true, runsConceded: true,
          catches: true, stumpings: true, runOuts: true,
        },
        _max: { runs: true },
        _count: { matchId: true },
      }),
      prisma.$queryRaw<Array<{ playerId: string; totalIp: number }>>`
        SELECT "playerId", COALESCE(SUM("ipDelta"), 0)::int AS "totalIp"
        FROM public.ip_event
        WHERE "matchId" IN (${Prisma.join(matchIds)})
        GROUP BY "playerId"
      `,
      prisma.playerMatchStats.aggregate({
        where: { matchId: { in: matchIds } },
        _sum: { runs: true, fours: true, sixes: true, wickets: true },
      }),
    ]);

    const playerIds = [...new Set(statsRaw.map((s) => s.playerProfileId))];
    const [profiles, competitiveProfiles] = await Promise.all([
      prisma.playerProfile.findMany({
        where: { id: { in: playerIds } },
        select: {
          id: true,
          username: true,
          user: { select: { name: true, avatarUrl: true } },
        },
      }),
      playerIds.length === 0
        ? Promise.resolve([])
        : prisma.$queryRaw<
            Array<{
              playerId: string;
              currentRankKey: string;
              currentDivision: number;
              lifetimeIp: number;
            }>
          >`
            SELECT
              "playerId",
              "currentRankKey",
              "currentDivision",
              "lifetimeIp"
            FROM public.ip_player_state
            WHERE "playerId" IN (${Prisma.join(playerIds)})
          `,
    ]);

    const profileMap = new Map(profiles.map((p) => [p.id, p]));
    const competitiveMap = new Map(competitiveProfiles.map((p) => [p.playerId, p]));
    const ipMap = new Map(ipRaw.map((r) => [r.playerId, r.totalIp ?? 0]));

    const playerStats = statsRaw.map((s) => {
      const profile = profileMap.get(s.playerProfileId);
      const comp = competitiveMap.get(s.playerProfileId);
      const totalIp = ipMap.get(s.playerProfileId) ?? 0;
      const runs = s._sum.runs ?? 0;
      const balls = s._sum.balls ?? 0;
      const overs = s._sum.oversBowled ?? 0;
      const conceded = s._sum.runsConceded ?? 0;
      return {
        player: {
          id: s.playerProfileId,
          name: profile?.user?.name ?? "Unknown",
          avatarUrl: profile?.user?.avatarUrl ?? null,
          username: profile?.username ?? null,
          rankKey: comp?.currentRankKey ?? "ROOKIE",
          rankDivision: comp?.currentDivision ?? 3,
          lifetimeIp: comp?.lifetimeIp ?? 0,
        },
        runs,
        balls,
        fours: s._sum.fours ?? 0,
        sixes: s._sum.sixes ?? 0,
        strikeRate: balls > 0 ? Math.round((runs / balls) * 1000) / 10 : 0,
        highestScore: s._max.runs ?? 0,
        innings: s._count.matchId,
        wickets: s._sum.wickets ?? 0,
        oversBowled: overs,
        runsConceded: conceded,
        economy: overs > 0 ? Math.round((conceded / overs) * 10) / 10 : 0,
        catches: s._sum.catches ?? 0,
        stumpings: s._sum.stumpings ?? 0,
        runOuts: s._sum.runOuts ?? 0,
        totalDismissals:
          (s._sum.catches ?? 0) + (s._sum.stumpings ?? 0) + (s._sum.runOuts ?? 0),
        totalIp,
      };
    });

    const topBatsmen = [...playerStats]
      .filter((p) => p.runs > 0)
      .sort((a, b) => b.runs - a.runs)
      .slice(0, 10);

    const topBowlers = [...playerStats]
      .filter((p) => p.wickets > 0)
      .sort((a, b) => b.wickets - a.wickets || a.economy - b.economy)
      .slice(0, 10);

    const topFielders = [...playerStats]
      .filter((p) => p.totalDismissals > 0)
      .sort((a, b) => b.totalDismissals - a.totalDismissals)
      .slice(0, 10);

    // Player of Tournament = highest IP earned across all tournament matches
    const playerOfTournament =
      playerStats.length > 0
        ? [...playerStats].sort((a, b) => b.totalIp - a.totalIp)[0]
        : null;

    const totalIpAwarded = ipRaw.reduce(
      (sum, r) => sum + Math.max(0, r.totalIp ?? 0),
      0,
    );

    return reply.send({
      data: {
        topBatsmen,
        topBowlers,
        topFielders,
        playerOfTournament: playerOfTournament
          ? { ...playerOfTournament, reason: "Most IP earned in tournament" }
          : null,
        tournamentTotals: {
          totalRuns: totalsRaw._sum.runs ?? 0,
          totalFours: totalsRaw._sum.fours ?? 0,
          totalSixes: totalsRaw._sum.sixes ?? 0,
          totalWickets: totalsRaw._sum.wickets ?? 0,
          matchesPlayed: matchIds.length,
          totalIpAwarded,
        },
      },
    });
  });

  // ── Public Arena Page ─────────────────────────────────────────────────────

  // GET /public/arena/id/:arenaId
  app.get('/arena/id/:arenaId', async (request, reply) => {
    const { arenaId } = request.params as { arenaId: string }
    const arena = await prisma.arena.findFirst({
      where: { id: arenaId, isPublicPage: true, isActive: true },
      include: {
        units: {
          where: { isActive: true },
          orderBy: { createdAt: 'asc' },
        },
      },
    })
    if (!arena) return reply.code(404).send({ success: false, error: 'Arena not found' })
    return reply.send({ success: true, data: arena })
  })


  // GET /public/arena/p/:slug — canonical single-slug lookup (customSlug OR arenaSlug)
  app.get('/arena/p/:slug', async (request, reply) => {
    const { slug } = request.params as { slug: string }
    const arena = await prisma.arena.findFirst({
      where: {
        OR: [
          { customSlug: slug, isPublicPage: true, isActive: true },
          { arenaSlug: slug, isPublicPage: true, isActive: true },
        ],
      },
      include: {
        units: {
          where: { isActive: true },
          orderBy: { createdAt: 'asc' },
          include: { addons: { where: { isAvailable: true } } },
        },
      },
    })
    if (!arena) return reply.code(404).send({ success: false, error: 'Arena not found' })
    return reply.send({ success: true, data: arena })
  })

  // GET /public/arena/p/:slug/slots?date=YYYY-MM-DD
  app.get('/arena/p/:slug/slots', async (request, reply) => {
    const { slug } = request.params as { slug: string }
    const { date, unitType } = request.query as { date?: string; unitType?: string }

    const arena = await prisma.arena.findFirst({
      where: {
        OR: [
          { customSlug: slug, isPublicPage: true, isActive: true },
          { arenaSlug: slug, isPublicPage: true, isActive: true },
        ],
      },
      include: {
        units: { where: { isActive: true, ...(unitType ? { unitType: unitType as any } : {}) } },
      },
    })
    if (!arena) return reply.code(404).send({ success: false, error: 'Arena not found' })

    const bookingDate = date ? new Date(date) : new Date()
    // Match service convention: Mon=1 … Sat=6, Sun=7
    const rawDay = bookingDate.getUTCDay()
    const weekday = rawDay === 0 ? 7 : rawDay

    const [existingBookings, timeBlocks, monthlyPasses] = await Promise.all([
      prisma.slotBooking.findMany({
        where: {
          arenaId: arena.id,
          date: bookingDate,
          status: { in: ['HELD', 'PENDING_PAYMENT', 'CONFIRMED', 'CHECKED_IN'] },
        },
        select: { unitId: true, startTime: true, endTime: true },
      }),
      prisma.arenaTimeBlock.findMany({
        where: {
          arenaId: arena.id,
          OR: [
            { date: bookingDate },
            { isRecurring: true, weekdays: { has: weekday } },
          ],
        },
        select: { unitId: true, startTime: true, endTime: true, isHoliday: true },
      }),
      prisma.monthlyPass.findMany({
        where: {
          arenaId: arena.id,
          status: 'ACTIVE',
          startDate: { lte: bookingDate },
          endDate: { gte: bookingDate },
          daysOfWeek: { has: weekday },
        },
        select: { unitId: true, startTime: true, endTime: true },
      }),
    ])

    const bookedByUnit: Record<string, { startTime: string; endTime: string }[]> = {}
    const push = (unitId: string, startTime: string, endTime: string) => {
      if (!bookedByUnit[unitId]) bookedByUnit[unitId] = []
      bookedByUnit[unitId].push({ startTime, endTime })
    }

    for (const b of existingBookings) push(b.unitId, b.startTime, b.endTime)

    for (const b of timeBlocks) {
      if (b.isHoliday) {
        const u = arena.units.find(u => u.id === b.unitId)
        push(b.unitId, u?.openTime ?? arena.openTime ?? '00:00', u?.closeTime ?? arena.closeTime ?? '23:59')
      } else {
        push(b.unitId, b.startTime, b.endTime)
      }
    }

    for (const p of monthlyPasses) push(p.unitId, p.startTime, p.endTime)

    return reply.send({
      success: true,
      data: {
        arena: { id: arena.id, name: arena.name, openTime: arena.openTime, closeTime: arena.closeTime },
        units: arena.units.map(u => ({
          id: u.id,
          name: u.name,
          unitType: u.unitType,
          pricePerHourPaise: u.pricePerHourPaise,
          minSlotMins: u.minSlotMins,
          maxSlotMins: u.maxSlotMins,
          slotIncrementMins: u.slotIncrementMins,
          openTime: u.openTime ?? null,
          closeTime: u.closeTime ?? null,
          bookedSlots: bookedByUnit[u.id] ?? [],
        })),
      },
    })
  })

  // GET /public/arena/:citySlug/:arenaSlug  OR  /public/arena/slug/:customSlug
  app.get('/arena/:citySlug/:arenaSlug', async (request, reply) => {
    const { citySlug, arenaSlug } = request.params as { citySlug: string; arenaSlug: string }
    const arena = await prisma.arena.findFirst({
      where: {
        OR: [
          { citySlug, arenaSlug, isPublicPage: true, isActive: true },
          { customSlug: arenaSlug, isPublicPage: true, isActive: true },
        ],
      },
      include: {
        units: {
          where: { isActive: true },
          orderBy: { createdAt: 'asc' },
        },
      },
    })
    if (!arena) return reply.code(404).send({ success: false, error: 'Arena not found' })
    return reply.send({ success: true, data: arena })
  })

  // GET /public/arena/:citySlug/:arenaSlug/slots?date=YYYY-MM-DD&unitType=CRICKET_NET
  app.get('/arena/:citySlug/:arenaSlug/slots', async (request, reply) => {
    const { citySlug, arenaSlug } = request.params as { citySlug: string; arenaSlug: string }
    const { date, unitType } = request.query as { date?: string; unitType?: string }

    const arena = await prisma.arena.findFirst({
      where: {
        OR: [
          { citySlug, arenaSlug, isPublicPage: true, isActive: true },
          { customSlug: arenaSlug, isPublicPage: true, isActive: true },
        ],
      },
      include: {
        units: {
          where: {
            isActive: true,
            ...(unitType ? { unitType: unitType as any } : {}),
          },
        },
      },
    })
    if (!arena) return reply.code(404).send({ success: false, error: 'Arena not found' })

    const bookingDate = date ? new Date(date) : new Date()
    const existingBookings = await prisma.slotBooking.findMany({
      where: {
        arenaId: arena.id,
        date: bookingDate,
        status: { in: ['HELD', 'PENDING_PAYMENT', 'CONFIRMED', 'CHECKED_IN'] },
      },
      select: { unitId: true, startTime: true, endTime: true },
    })

    const bookedByUnit: Record<string, { startTime: string; endTime: string }[]> = {}
    for (const b of existingBookings) {
      if (!bookedByUnit[b.unitId]) bookedByUnit[b.unitId] = []
      bookedByUnit[b.unitId].push({ startTime: b.startTime, endTime: b.endTime })
    }

    return reply.send({
      success: true,
      data: {
        arena: { id: arena.id, name: arena.name, openTime: arena.openTime, closeTime: arena.closeTime },
        units: arena.units.map(u => ({
          id: u.id,
          name: u.name,
          unitType: u.unitType,
          netType: u.netType,
          pricePerHourPaise: u.pricePerHourPaise,
          minSlotMins: u.minSlotMins,
          maxSlotMins: u.maxSlotMins,
          slotIncrementMins: u.slotIncrementMins,
          minBulkDays: (u as any).minBulkDays ?? null,
          bulkDayRatePaise: (u as any).bulkDayRatePaise ?? null,
          bookedSlots: bookedByUnit[u.id] ?? [],
        })),
      },
    })
  })

  // POST /public/bookings — guest booking (no auth)
  app.post('/bookings/phonepe/initiate', async (request, reply) => {
    const bodySchema = z.object({
      amountPaise: z.number().int().min(100),
      guestPhone: z.string().min(5).max(20).optional(),
      guestName: z.string().min(1).max(100).optional(),
      arenaUnitId: z.string().optional(),
      bookingDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
      startTime: z.string().regex(/^\d{2}:\d{2}$/).optional(),
      endTime: z.string().regex(/^\d{2}:\d{2}$/).optional(),
    })

    const parsed = bodySchema.safeParse(request.body)
    if (!parsed.success) {
      return reply.code(400).send({ success: false, error: 'Invalid request', details: parsed.error.flatten() })
    }

    const body = parsed.data
    const order = await phonePeService.createOrder(body.amountPaise, {
      message: 'Swing arena booking advance',
      prefillPhone: body.guestPhone,
      redirectUrl: process.env.PHONEPE_WEB_REDIRECT_URL ?? 'https://www.swingcricketapp.com',
      metaInfo: {
        udf1: body.arenaUnitId ?? '',
        udf2: body.bookingDate ?? '',
        udf3: body.startTime ?? '',
        udf4: body.endTime ?? '',
        udf5: body.guestName ?? '',
      },
    })

    return reply.code(201).send({
      success: true,
      data: {
        merchantOrderId: order.orderId,
        phonePeOrderId: order.phonePeOrderId,
        redirectUrl: order.redirectUrl,
        token: order.token,
        state: order.state,
      },
    })
  })

  // POST /public/bookings — guest booking (no auth)
  app.post('/bookings', async (request, reply) => {
    const bodySchema = z.object({
      arenaUnitId: z.string(),
      bookingDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
      startTime: z.string().regex(/^\d{2}:\d{2}$/),
      endTime: z.string().regex(/^\d{2}:\d{2}$/),
      totalPricePaise: z.number().int().min(0),
      guestName: z.string().min(1).max(100),
      guestPhone: z.string().min(5).max(20),
      paymentGateway: z.string().optional(),
      phonePeOrderId: z.string().optional(),
    })

    const parsed = bodySchema.safeParse(request.body)
    if (!parsed.success) {
      return reply.code(400).send({ success: false, error: 'Invalid request', details: parsed.error.flatten() })
    }

    const { arenaUnitId, bookingDate, startTime, endTime, totalPricePaise, guestName, guestPhone, paymentGateway, phonePeOrderId } = parsed.data

    const unit = await prisma.arenaUnit.findUnique({
      where: { id: arenaUnitId },
      include: { arena: true },
    })
    if (!unit || !unit.isActive) return reply.code(404).send({ success: false, error: 'Unit not found' })
    if (!(unit.arena as any).isPublicPage || !(unit.arena as any).isActive) {
      return reply.code(404).send({ success: false, error: 'Arena not found' })
    }

    const dateObj = new Date(bookingDate)
    const rawDay = dateObj.getUTCDay()
    const weekday = rawDay === 0 ? 7 : rawDay

    // conflict: existing booking
    const conflict = await prisma.slotBooking.findFirst({
      where: {
        unitId: arenaUnitId,
        date: dateObj,
        status: { in: ['CONFIRMED', 'CHECKED_IN', 'PENDING_PAYMENT'] },
        startTime: { lt: endTime },
        endTime: { gt: startTime },
      },
    })
    if (conflict) return reply.code(409).send({ success: false, error: 'Slot already booked' })

    // conflict: time block (one-time or recurring or holiday)
    const blocked = await prisma.arenaTimeBlock.findFirst({
      where: {
        unitId: arenaUnitId,
        startTime: { lt: endTime },
        endTime: { gt: startTime },
        OR: [
          { date: dateObj },
          { isRecurring: true, weekdays: { has: weekday } },
        ],
      },
    })
    if (blocked) return reply.code(409).send({ success: false, error: 'This slot is blocked' })

    // conflict: active monthly pass
    const passConflict = await prisma.monthlyPass.findFirst({
      where: {
        unitId: arenaUnitId,
        status: 'ACTIVE',
        startDate: { lte: dateObj },
        endDate: { gte: dateObj },
        daysOfWeek: { has: weekday },
        startTime: { lt: endTime },
        endTime: { gt: startTime },
      },
    })
    if (passConflict) return reply.code(409).send({ success: false, error: 'This slot is reserved by a monthly pass' })

    const isPhonePe = paymentGateway === 'PHONEPE'
    if (isPhonePe) {
      if (!phonePeOrderId) {
        return reply.code(400).send({ success: false, error: 'phonePeOrderId is required for PhonePe payment' })
      }
      const status = await phonePeService.checkOrderStatus(phonePeOrderId)
      if (status.state !== 'COMPLETED') {
        return reply.code(400).send({ success: false, error: `PhonePe payment not completed (state: ${status.state})` })
      }
    }

    // resolve or create walk-in player for this arena
    const arenaId = unit.arenaId
    const walkinEmail = `walkin+${arenaId}@swing.internal`
    let walkinUser = await prisma.user.findUnique({ where: { email: walkinEmail } })
    if (!walkinUser) {
      walkinUser = await prisma.user.create({
        data: {
          phone: `000000000000_${arenaId.slice(0, 8)}`,
          email: walkinEmail,
          name: 'Walk-in Guest',
          roles: ['PLAYER'],
        },
      })
    }
    let walkinPlayer = await prisma.playerProfile.findUnique({ where: { userId: walkinUser.id } })
    if (!walkinPlayer) {
      walkinPlayer = await prisma.playerProfile.create({ data: { userId: walkinUser.id } })
    }

    const startMins = parseInt(startTime.split(':')[0]) * 60 + parseInt(startTime.split(':')[1])
    const endMins = parseInt(endTime.split(':')[0]) * 60 + parseInt(endTime.split(':')[1])
    const durationMins = endMins - startMins

    const booking = await prisma.slotBooking.create({
      data: {
        arenaId,
        unitId: arenaUnitId,
        bookedById: walkinPlayer.id,
        date: dateObj,
        startTime,
        endTime,
        durationMins,
        baseAmountPaise: totalPricePaise,
        totalAmountPaise: totalPricePaise,
        totalPricePaise,
        status: 'CONFIRMED',
        isOfflineBooking: !isPhonePe,
        guestName,
        guestPhone,
        guestSource: 'PUBLIC_WEB',
        paymentMode: isPhonePe ? 'ONLINE' : 'CASH',
        ...(isPhonePe ? { paidAt: new Date(), advancePaise: totalPricePaise } : {}),
      } as any,
    })

    if (isPhonePe && phonePeOrderId) {
      await prisma.payment.create({
        data: {
          userId: walkinUser.id,
          entityType: 'SLOT_BOOKING',
          entityId: booking.id,
          amountPaise: totalPricePaise,
          currency: 'INR',
          status: 'COMPLETED',
          gateway: 'PHONEPE',
          gatewayOrderId: phonePeOrderId,
          slotBookingId: booking.id,
          completedAt: new Date(),
          description: `Arena slot ${startTime}–${endTime}`,
        },
      })
    }

    // Notify arena owner (fire-and-forget)
    notificationSvc.notifyBookingConfirmed({
      id: booking.id,
      arenaId,
      unitId: arenaUnitId,
      date: dateObj,
      startTime,
      endTime,
      bookedById: walkinPlayer.id,
      notifyPlayer: false,
      customerName: guestName,
    }).catch((err) => console.error('[notify] booking confirmed failed:', err))

    return reply.code(201).send({
      success: true,
      data: {
        id: booking.id,
        bookingDate,
        startTime: booking.startTime,
        endTime: booking.endTime,
        guestName: booking.guestName,
        status: booking.status,
      },
    })
  })

  // POST /public/monthly-passes
  app.post('/monthly-passes', async (request, reply) => {
    const bodySchema = z.object({
      arenaUnitId: z.string(),
      startTime: z.string().regex(/^\d{2}:\d{2}$/),
      endTime: z.string().regex(/^\d{2}:\d{2}$/),
      daysOfWeek: z.array(z.number().int().min(1).max(7)).min(1).default([1,2,3,4,5,6,7]),
      startDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
      months: z.number().int().min(1).max(12).default(1),
      guestName: z.string().min(1).max(100).optional(),
      guestPhone: z.string().min(5).max(20).optional(),
      variantType: z.string().optional(),
      phonePeOrderId: z.string().optional(),
      paymentGateway: z.string().optional(),
    })
    const parsed = bodySchema.safeParse(request.body)
    if (!parsed.success) return reply.code(400).send({ success: false, error: 'Invalid request' })

    const { arenaUnitId, startTime, endTime, daysOfWeek, startDate, months, variantType, phonePeOrderId, paymentGateway } = parsed.data

    // Resolve identity — prefer authenticated player, fall back to body params
    let authUserId: string | null = null
    try { await request.jwtVerify(); authUserId = ((request as any).user as { userId: string })?.userId ?? null } catch {}

    let guestName: string
    let guestPhone: string
    let bookedByPlayerId: string | null = null

    if (authUserId) {
      const user = await prisma.user.findUnique({ where: { id: authUserId }, select: { name: true, phone: true } })
      guestName = user?.name ?? 'Player'
      guestPhone = user?.phone ?? ''
      const player = await prisma.playerProfile.findUnique({ where: { userId: authUserId }, select: { id: true } })
      bookedByPlayerId = player?.id ?? null
    } else {
      if (!parsed.data.guestName || !parsed.data.guestPhone) {
        return reply.code(400).send({ success: false, error: 'guestName and guestPhone are required' })
      }
      guestName = parsed.data.guestName
      guestPhone = parsed.data.guestPhone
    }

    const isPhonePe = paymentGateway === 'PHONEPE'
    if (isPhonePe) {
      if (!phonePeOrderId) return reply.code(400).send({ success: false, error: 'phonePeOrderId is required for PhonePe payment' })
      const status = await phonePeService.checkOrderStatus(phonePeOrderId)
      if (status.state !== 'COMPLETED') return reply.code(400).send({ success: false, error: `Payment not completed (state: ${status.state})` })
    }

    const unit = await prisma.arenaUnit.findUnique({ where: { id: arenaUnitId }, include: { arena: true } })
    if (!unit || !unit.isActive) return reply.code(404).send({ success: false, error: 'Unit not found' })
    if (!(unit.arena as any).isPublicPage || !(unit.arena as any).isActive) return reply.code(404).send({ success: false, error: 'Arena not found' })

    // Support both unit-level and per-variant monthly pass rates
    const netVariants: any[] = Array.isArray((unit as any).netVariants) ? (unit as any).netVariants : []
    const variantRates = netVariants
      .filter(v => v.monthlyPassRatePaise && Number(v.monthlyPassRatePaise) > 0)
      .map(v => Number(v.monthlyPassRatePaise))
    const isEnabled = (unit as any).monthlyPassEnabled || variantRates.length > 0
    if (!isEnabled) return reply.code(400).send({ success: false, error: 'Monthly pass not available for this unit' })

    // Pick rate: specific variant > unit-level > min variant rate
    let ratePaise = Number((unit as any).monthlyPassRatePaise ?? 0)
    if (!ratePaise && variantType) {
      const variant = netVariants.find(v => v.type === variantType)
      if (variant?.monthlyPassRatePaise) ratePaise = Number(variant.monthlyPassRatePaise)
    }
    if (!ratePaise && variantRates.length > 0) ratePaise = Math.min(...variantRates)

    const start = new Date(startDate)
    const end = new Date(start)
    end.setUTCMonth(end.getUTCMonth() + months)
    end.setUTCDate(end.getUTCDate() - 1)

    const totalPaise = ratePaise * months

    const pass = await prisma.monthlyPass.create({
      data: {
        arenaId: unit.arenaId,
        unitId: arenaUnitId,
        guestName,
        guestPhone,
        startTime,
        endTime,
        daysOfWeek,
        startDate: start,
        endDate: end,
        totalAmountPaise: totalPaise,
        status: 'ACTIVE',
        bookingSource: authUserId ? 'PLAYER_APP' : 'PUBLIC_WEB',
        paymentMode: isPhonePe ? 'ONLINE' : 'CASH',
        ...(isPhonePe ? { advancePaise: totalPaise } : {}),
        ...(bookedByPlayerId ? { bookedById: bookedByPlayerId } : {}),
      } as any,
    })

    if (isPhonePe && phonePeOrderId && authUserId) {
      await prisma.payment.create({
        data: {
          userId: authUserId,
          entityType: 'MONTHLY_PASS',
          entityId: pass.id,
          amountPaise: totalPaise,
          currency: 'INR',
          status: 'COMPLETED',
          gateway: 'PHONEPE',
          gatewayOrderId: phonePeOrderId,
          completedAt: new Date(),
          description: `Monthly pass ${startTime}–${endTime}`,
        } as any,
      })
    }

    return reply.code(201).send({ success: true, data: { id: pass.id, startDate, endDate: end.toISOString().slice(0, 10), totalAmountPaise: totalPaise } })
  })

  // POST /public/bulk-bookings
  app.post('/bulk-bookings', async (request, reply) => {
    const bodySchema = z.object({
      arenaUnitId: z.string(),
      startTime: z.string().regex(/^\d{2}:\d{2}$/),
      endTime: z.string().regex(/^\d{2}:\d{2}$/),
      dates: z.array(z.string().regex(/^\d{4}-\d{2}-\d{2}$/)).min(1),
      guestName: z.string().min(1).max(100).optional(),
      guestPhone: z.string().min(5).max(20).optional(),
      phonePeOrderId: z.string().optional(),
      paymentGateway: z.string().optional(),
    })
    const parsed = bodySchema.safeParse(request.body)
    if (!parsed.success) return reply.code(400).send({ success: false, error: 'Invalid request' })

    const { arenaUnitId, startTime, endTime, dates, phonePeOrderId, paymentGateway } = parsed.data

    // Resolve identity
    let authUserId: string | null = null
    try { await request.jwtVerify(); authUserId = ((request as any).user as { userId: string })?.userId ?? null } catch {}

    let guestName: string
    let guestPhone: string
    let bookedByPlayerId: string | null = null

    if (authUserId) {
      const user = await prisma.user.findUnique({ where: { id: authUserId }, select: { name: true, phone: true } })
      guestName = user?.name ?? 'Player'
      guestPhone = user?.phone ?? ''
      const player = await prisma.playerProfile.findUnique({ where: { userId: authUserId }, select: { id: true } })
      bookedByPlayerId = player?.id ?? null
    } else {
      if (!parsed.data.guestName || !parsed.data.guestPhone) {
        return reply.code(400).send({ success: false, error: 'guestName and guestPhone are required' })
      }
      guestName = parsed.data.guestName
      guestPhone = parsed.data.guestPhone
    }

    const isPhonePe = paymentGateway === 'PHONEPE'
    if (isPhonePe) {
      if (!phonePeOrderId) return reply.code(400).send({ success: false, error: 'phonePeOrderId is required for PhonePe payment' })
      const status = await phonePeService.checkOrderStatus(phonePeOrderId)
      if (status.state !== 'COMPLETED') return reply.code(400).send({ success: false, error: `Payment not completed (state: ${status.state})` })
    }

    const unit = await prisma.arenaUnit.findUnique({ where: { id: arenaUnitId }, include: { arena: true } })
    if (!unit || !unit.isActive) return reply.code(404).send({ success: false, error: 'Unit not found' })
    if (!(unit.arena as any).isPublicPage || !(unit.arena as any).isActive) return reply.code(404).send({ success: false, error: 'Arena not found' })

    const minDays = (unit as any).minBulkDays ?? 1
    if (dates.length < minDays) return reply.code(400).send({ success: false, error: `Minimum ${minDays} days required for bulk booking` })

    const dayRatePaise = (unit as any).bulkDayRatePaise ?? 0
    const startMins = parseInt(startTime.split(':')[0]) * 60 + parseInt(startTime.split(':')[1])
    const endMins = parseInt(endTime.split(':')[0]) * 60 + parseInt(endTime.split(':')[1])
    const durationMins = endMins - startMins

    const arenaId = unit.arenaId

    // For unauthenticated, use/create a walk-in profile; for authenticated, use actual player
    let playerProfileId: string
    if (bookedByPlayerId) {
      playerProfileId = bookedByPlayerId
    } else {
      const walkinEmail = `walkin+${arenaId}@swing.internal`
      let walkinUser = await prisma.user.findUnique({ where: { email: walkinEmail } })
      if (!walkinUser) {
        walkinUser = await prisma.user.create({ data: { phone: `000000000000_${arenaId.slice(0, 8)}`, email: walkinEmail, name: 'Walk-in Guest', roles: ['PLAYER'] } })
      }
      let walkinPlayer = await prisma.playerProfile.findUnique({ where: { userId: walkinUser.id } })
      if (!walkinPlayer) walkinPlayer = await prisma.playerProfile.create({ data: { userId: walkinUser.id } })
      playerProfileId = walkinPlayer.id
    }

    const bookings = dates.map(dateStr => {
      const d = new Date(dateStr + 'T00:00:00Z')
      return prisma.slotBooking.create({
        data: {
          arenaId,
          unitId: arenaUnitId,
          bookedById: playerProfileId,
          date: d,
          startTime,
          endTime,
          durationMins,
          baseAmountPaise: dayRatePaise,
          totalAmountPaise: dayRatePaise,
          totalPricePaise: dayRatePaise,
          status: 'CONFIRMED',
          isOfflineBooking: !authUserId,
          isBulkBooking: true,
          bulkDayRatePaise: dayRatePaise,
          guestName,
          guestPhone,
          guestSource: authUserId ? 'PLAYER_APP' : 'PUBLIC_WEB',
          paymentMode: isPhonePe ? 'ONLINE' : 'CASH',
          ...(isPhonePe ? { isOfflineBooking: false, advancePaise: dayRatePaise, paidAt: new Date() } : {}),
        } as any,
      })
    })

    const created = await prisma.$transaction(bookings)

    if (isPhonePe && phonePeOrderId && authUserId && created[0]) {
      await prisma.payment.create({
        data: {
          userId: authUserId,
          entityType: 'BULK_BOOKING',
          entityId: created[0].id,
          amountPaise: dayRatePaise * dates.length,
          currency: 'INR',
          status: 'COMPLETED',
          gateway: 'PHONEPE',
          gatewayOrderId: phonePeOrderId,
          completedAt: new Date(),
          description: `Bulk booking ${dates.length} days ${startTime}–${endTime}`,
        } as any,
      })
    }

    // Notify arena owner (fire-and-forget)
    if (created[0]) {
      notificationSvc.notifyBookingConfirmed({
        id: created[0].id,
        arenaId: (unit.arena as any).id,
        unitId: arenaUnitId,
        date: created[0].date,
        startTime,
        endTime,
        bookedById: playerProfileId,
        notifyPlayer: false,
        customerName: guestName,
      }).catch((err) => console.error('[notify] bulk booking confirmed failed:', err))
    }

    return reply.code(201).send({
      success: true,
      data: { numDays: dates.length, dates, startTime, endTime, totalAmountPaise: dayRatePaise * dates.length },
    })
  })
}
