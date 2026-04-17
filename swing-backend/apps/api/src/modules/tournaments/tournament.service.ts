import { prisma } from "@swing/db";
import { AppError, Errors } from "../../lib/errors";
import { NotificationService } from "../notifications/notification.service";

const notificationSvc = new NotificationService();

function cricketOversToBalls(overs: number | null | undefined) {
  if (!overs || overs <= 0) return 0
  const wholeOvers = Math.trunc(overs)
  const balls = Math.round((overs - wholeOvers) * 10)
  return wholeOvers * 6 + Math.min(Math.max(balls, 0), 5)
}

function inningsBallsForNrr(innings: { totalOvers: number; totalWickets: number }, quotaOvers?: number | null) {
  const actualBalls = cricketOversToBalls(innings.totalOvers)
  if (innings.totalWickets >= 10 && quotaOvers && quotaOvers > 0) return quotaOvers * 6
  return actualBalls
}

export type TournamentInput = {
  name: string
  format: string
  tournamentFormat?: string
  startDate: string
  endDate?: string
  city?: string
  venueName?: string
  maxTeams?: number
  entryFee?: number
  prizePool?: string
  description?: string
  isPublic?: boolean
  seriesMatchCount?: number | null
  ballType?: string
  earlyBirdDeadline?: string
  earlyBirdFee?: number
  organiserName?: string
  organiserPhone?: string
}

export class TournamentService {
  async getMyHostedTournaments(userId: string) {
    const tournaments = await prisma.tournament.findMany({
      where: { createdByUserId: userId },
      include: { teams: true },
      orderBy: { createdAt: "desc" },
    })
    return { tournaments }
  }

  async createHostedTournament(userId: string, input: TournamentInput) {
    const isSeries = input.tournamentFormat === 'SERIES'
    return prisma.tournament.create({
      data: {
        createdByUserId: userId,
        name: input.name.trim(),
        format: input.format as any,
        tournamentFormat: (input.tournamentFormat as any) || "LEAGUE",
        startDate: new Date(input.startDate),
        endDate: input.endDate ? new Date(input.endDate) : null,
        city: input.city?.trim() || null,
        venueName: input.venueName?.trim() || null,
        maxTeams: input.maxTeams ?? 128,
        entryFee: input.entryFee || null,
        prizePool: input.prizePool?.trim() || null,
        description: input.description?.trim() || null,
        isPublic: input.isPublic ?? true,
        status: "UPCOMING",
        ballType: input.ballType || 'LEATHER',
        earlyBirdDeadline: input.earlyBirdDeadline ? new Date(input.earlyBirdDeadline) : null,
        earlyBirdFee: input.earlyBirdFee || null,
        organiserName: input.organiserName?.trim() || null,
        organiserPhone: input.organiserPhone?.trim() || null,
        ...(isSeries ? { seriesMatchCount: input.seriesMatchCount ?? 3 } : {}),
      },
    })
  }

  // ── Ownership check ─────────────────────────────────────────────────────────

  private async verifyOwner(userId: string, tournamentId: string) {
    const t = await prisma.tournament.findUnique({ where: { id: tournamentId } })
    if (!t) throw Errors.notFound("Tournament")
    if (t.createdByUserId !== userId) throw Errors.forbidden()
    return t
  }

  // ── Management methods ──────────────────────────────────────────────────────

  async getTournament(userId: string, tournamentId: string) {
    const t = await this.verifyOwner(userId, tournamentId)
    const full = await prisma.tournament.findUnique({
      where: { id: tournamentId },
      include: {
        teams: { orderBy: { registeredAt: "asc" } },
        groups: { include: { teams: true }, orderBy: { groupOrder: "asc" } },
      },
    })
    return full ?? t
  }

  async updateTournament(userId: string, tournamentId: string, data: any) {
    await this.verifyOwner(userId, tournamentId)
    return prisma.tournament.update({ where: { id: tournamentId }, data })
  }

  async deleteTournament(userId: string, tournamentId: string) {
    await this.verifyOwner(userId, tournamentId)
    await prisma.tournamentStanding.deleteMany({ where: { tournamentId } })
    await prisma.tournamentTeam.deleteMany({ where: { tournamentId } })
    await prisma.tournamentGroup.deleteMany({ where: { tournamentId } })
    await prisma.match.deleteMany({ where: { tournamentId } })
    return prisma.tournament.delete({ where: { id: tournamentId } })
  }

  // ── Teams ───────────────────────────────────────────────────────────────────

  async listTournamentTeams(userId: string, tournamentId: string) {
    await this.verifyOwner(userId, tournamentId)
    return prisma.tournamentTeam.findMany({
      where: { tournamentId },
      orderBy: { registeredAt: "asc" },
    })
  }

  async addTournamentTeam(
    userId: string,
    tournamentId: string,
    data: { teamName?: string; teamId?: string; captainId?: string; playerIds: string[] },
  ) {
    const t = await this.verifyOwner(userId, tournamentId)
    const currentCount = await prisma.tournamentTeam.count({ where: { tournamentId } })
    if (t.maxTeams && currentCount >= t.maxTeams) {
      throw new AppError("TOURNAMENT_FULL", `Tournament is full. Maximum ${t.maxTeams} teams allowed.`, 400)
    }

    let resolvedName = data.teamName
    let resolvedTeamId = data.teamId || null

    if (data.teamId) {
      const dbTeam = await prisma.team.findUnique({ where: { id: data.teamId } })
      if (!dbTeam) throw Errors.notFound("Team")
      resolvedName = dbTeam.name
      const existing = await prisma.tournamentTeam.findFirst({
        where: { tournamentId, teamId: data.teamId },
      })
      if (existing)
        throw new AppError("ALREADY_REGISTERED", "This team is already registered in the tournament.", 400)
    } else if (data.teamName) {
      const newTeam = await prisma.team.create({
        data: {
          name: data.teamName,
          teamType: "FRIENDLY",
          createdByUserId: userId,
          playerIds: data.playerIds || [],
        },
      })
      resolvedTeamId = newTeam.id
      resolvedName = newTeam.name
    } else {
      throw new AppError("MISSING_TEAM", "Either teamId or teamName is required.", 400)
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
    })
  }

  async removeTournamentTeam(userId: string, tournamentId: string, tournamentTeamId: string) {
    await this.verifyOwner(userId, tournamentId)
    const team = await prisma.tournamentTeam.findUnique({ where: { id: tournamentTeamId } })
    if (!team || team.tournamentId !== tournamentId) throw Errors.notFound("Tournament team")
    await prisma.tournamentStanding.deleteMany({ where: { tournamentTeamId } })
    return prisma.tournamentTeam.delete({ where: { id: tournamentTeamId } })
  }

  async confirmTournamentTeam(userId: string, tournamentTeamId: string, isConfirmed: boolean) {
    const team = await prisma.tournamentTeam.findUnique({ where: { id: tournamentTeamId } })
    if (!team) throw Errors.notFound("Tournament team")
    await this.verifyOwner(userId, team.tournamentId)
    if (isConfirmed) {
      await prisma.tournamentStanding.upsert({
        where: {
          tournamentId_tournamentTeamId: {
            tournamentId: team.tournamentId,
            tournamentTeamId: team.id,
          },
        },
        create: { tournamentId: team.tournamentId, tournamentTeamId: team.id, groupId: team.groupId },
        update: {},
      })
    }
    return prisma.tournamentTeam.update({ where: { id: tournamentTeamId }, data: { isConfirmed } })
  }

  // ── Groups ──────────────────────────────────────────────────────────────────

  async getTournamentGroups(userId: string, tournamentId: string) {
    await this.verifyOwner(userId, tournamentId)
    return prisma.tournamentGroup.findMany({
      where: { tournamentId },
      include: {
        teams: {
          select: { id: true, teamName: true, isConfirmed: true, seed: true, teamId: true },
        },
      },
      orderBy: { groupOrder: "asc" },
    })
  }

  async createTournamentGroups(
    userId: string,
    tournamentId: string,
    groupNames: string[],
    autoAssign?: boolean,
  ) {
    await this.verifyOwner(userId, tournamentId)
    await prisma.tournamentTeam.updateMany({ where: { tournamentId }, data: { groupId: null } })
    await prisma.tournamentStanding.updateMany({ where: { tournamentId }, data: { groupId: null } })
    await prisma.tournamentGroup.deleteMany({ where: { tournamentId } })
    const groups = await prisma.$transaction(
      groupNames.map((name, i) =>
        prisma.tournamentGroup.create({ data: { tournamentId, name, groupOrder: i } }),
      ),
    )
    if (autoAssign) {
      const confirmedTeams = await prisma.tournamentTeam.findMany({
        where: { tournamentId, isConfirmed: true },
      })
      for (let i = confirmedTeams.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [confirmedTeams[i], confirmedTeams[j]] = [confirmedTeams[j], confirmedTeams[i]]
      }
      const assignments = confirmedTeams.map((team, i) => ({
        teamId: team.id,
        groupId: groups[i % groups.length].id,
      }))
      await prisma.$transaction([
        ...assignments.map(({ teamId, groupId }) =>
          prisma.tournamentTeam.update({ where: { id: teamId }, data: { groupId } }),
        ),
        ...assignments.map(({ teamId, groupId }) =>
          prisma.tournamentStanding.updateMany({
            where: { tournamentId, tournamentTeamId: teamId },
            data: { groupId },
          }),
        ),
      ])
    }
    return groups
  }

  async assignTeamToGroup(
    userId: string,
    tournamentId: string,
    tournamentTeamId: string,
    groupId: string | null,
  ) {
    await this.verifyOwner(userId, tournamentId)
    const team = await prisma.tournamentTeam.findUnique({ where: { id: tournamentTeamId } })
    if (!team || team.tournamentId !== tournamentId) throw Errors.notFound("Tournament team")
    await prisma.tournamentStanding.updateMany({
      where: { tournamentId, tournamentTeamId },
      data: { groupId },
    })
    return prisma.tournamentTeam.update({ where: { id: tournamentTeamId }, data: { groupId } })
  }

  // ── Standings ───────────────────────────────────────────────────────────────

  async getTournamentStandings(userId: string, tournamentId: string) {
    await this.verifyOwner(userId, tournamentId)
    const standings = await prisma.tournamentStanding.findMany({
      where: { tournamentId },
      include: {
        team: { select: { id: true, teamName: true, isConfirmed: true } },
        group: { select: { id: true, name: true } },
      },
      orderBy: [{ groupId: "asc" }, { points: "desc" }, { nrr: "desc" }],
    })
    const grouped: Record<string, typeof standings> = {}
    for (const s of standings) {
      const key = s.groupId ?? "overall"
      if (!grouped[key]) grouped[key] = []
      grouped[key].push(s)
    }
    return grouped
  }

  async recalculateStandings(userId: string, tournamentId: string) {
    await this.verifyOwner(userId, tournamentId)
    return this.recalculateStandingsInternal(tournamentId)
  }

  private async recalculateStandingsInternal(tournamentId: string) {
    const tournament = await prisma.tournament.findUnique({
      where: { id: tournamentId },
      include: { teams: { where: { isConfirmed: true } } },
    })
    if (!tournament) throw Errors.notFound("Tournament")

    const matches = await prisma.match.findMany({
      where: { tournamentId, status: "COMPLETED" },
      include: { innings: true },
    })

    const confirmedIds = tournament.teams.map((t) => t.id)
    await prisma.tournamentStanding.deleteMany({
      where: { tournamentId, tournamentTeamId: { notIn: confirmedIds } },
    })

    const zeroData = {
      played: 0, won: 0, lost: 0, tied: 0, noResult: 0, points: 0,
      runsScored: 0, ballsFaced: 0, runsConceded: 0, ballsBowled: 0, nrr: 0,
    }
    for (const t of tournament.teams) {
      await prisma.tournamentStanding.upsert({
        where: {
          tournamentId_tournamentTeamId: { tournamentId, tournamentTeamId: t.id },
        },
        create: { tournamentId, tournamentTeamId: t.id, groupId: t.groupId, ...zeroData },
        update: { groupId: t.groupId, ...zeroData },
      })
    }

    const teamMap = new Map<string, string>()
    for (const t of tournament.teams) {
      teamMap.set(t.teamName.toLowerCase(), t.id)
    }

    const updates = new Map<string, {
      played: number; won: number; lost: number; tied: number; noResult: number; points: number;
      runsScored: number; ballsFaced: number; runsConceded: number; ballsBowled: number;
    }>()

    const pointsForWin = (tournament as any).pointsForWin ?? 2
    const pointsForLoss = (tournament as any).pointsForLoss ?? 0
    const pointsForTie = (tournament as any).pointsForTie ?? 1
    const pointsForNoResult = (tournament as any).pointsForNoResult ?? 1

    for (const match of matches) {
      const ttAId = teamMap.get(match.teamAName.toLowerCase())
      const ttBId = teamMap.get(match.teamBName.toLowerCase())
      if (!ttAId || !ttBId) continue

      if (!updates.has(ttAId))
        updates.set(ttAId, { played: 0, won: 0, lost: 0, tied: 0, noResult: 0, points: 0, runsScored: 0, ballsFaced: 0, runsConceded: 0, ballsBowled: 0 })
      if (!updates.has(ttBId))
        updates.set(ttBId, { played: 0, won: 0, lost: 0, tied: 0, noResult: 0, points: 0, runsScored: 0, ballsFaced: 0, runsConceded: 0, ballsBowled: 0 })

      const a = updates.get(ttAId)!
      const b = updates.get(ttBId)!

      a.played++; b.played++

      const winnerId = (match as any).winnerId as string | null
      const aWon = winnerId === "A" || winnerId?.toLowerCase() === match.teamAName.toLowerCase()
      const bWon = winnerId === "B" || winnerId?.toLowerCase() === match.teamBName.toLowerCase()
      const noResult = winnerId === "NO_RESULT" || (winnerId && !aWon && !bWon)

      if (aWon) {
        a.won++; a.points += pointsForWin; b.lost++; b.points += pointsForLoss
      } else if (bWon) {
        b.won++; b.points += pointsForWin; a.lost++; a.points += pointsForLoss
      } else if (noResult) {
        a.noResult++; a.points += pointsForNoResult; b.noResult++; b.points += pointsForNoResult
      } else {
        a.tied++; a.points += pointsForTie; b.tied++; b.points += pointsForTie
      }

      const inn1 = match.innings.find((i: any) => i.inningsNumber === 1)
      const inn2 = match.innings.find((i: any) => i.inningsNumber === 2)
      if (inn1) {
        const balls1 = inningsBallsForNrr(inn1, match.customOvers)
        if (inn1.battingTeam === "A") {
          a.runsScored += inn1.totalRuns ?? 0; a.ballsFaced += balls1
          b.runsConceded += inn1.totalRuns ?? 0; b.ballsBowled += balls1
        } else {
          b.runsScored += inn1.totalRuns ?? 0; b.ballsFaced += balls1
          a.runsConceded += inn1.totalRuns ?? 0; a.ballsBowled += balls1
        }
      }
      if (inn2) {
        const balls2 = inningsBallsForNrr(inn2, match.customOvers)
        if (inn2.battingTeam === "A") {
          a.runsScored += inn2.totalRuns ?? 0; a.ballsFaced += balls2
          b.runsConceded += inn2.totalRuns ?? 0; b.ballsBowled += balls2
        } else {
          b.runsScored += inn2.totalRuns ?? 0; b.ballsFaced += balls2
          a.runsConceded += inn2.totalRuns ?? 0; a.ballsBowled += balls2
        }
      }
    }

    for (const [tournamentTeamId, stats] of updates) {
      const oversFor = stats.ballsFaced / 6
      const oversAgainst = stats.ballsBowled / 6
      const nrr = stats.played === 0 ? 0 :
        (oversFor > 0 ? stats.runsScored / oversFor : 0) -
        (oversAgainst > 0 ? stats.runsConceded / oversAgainst : 0)
      await prisma.tournamentStanding.update({
        where: { tournamentId_tournamentTeamId: { tournamentId, tournamentTeamId } },
        data: { ...stats, nrr: Math.round(nrr * 1000) / 1000 },
      })
    }

    return prisma.tournamentStanding.findMany({ where: { tournamentId } })
  }

  // ── Schedule ────────────────────────────────────────────────────────────────

  async getTournamentSchedule(userId: string, tournamentId: string) {
    await this.verifyOwner(userId, tournamentId)
    return prisma.match.findMany({
      where: { tournamentId },
      include: {
        innings: {
          select: {
            inningsNumber: true, totalRuns: true, totalWickets: true,
            totalOvers: true, isCompleted: true,
          },
        },
      },
      orderBy: { scheduledAt: "asc" },
    })
  }

  async autoGenerateSchedule(userId: string, tournamentId: string, matchesPerDay: number = 1) {
    const t = await this.verifyOwner(userId, tournamentId)
    const confirmedTeams = await prisma.tournamentTeam.findMany({
      where: { tournamentId, isConfirmed: true },
      orderBy: { seed: "asc" },
    })
    if (confirmedTeams.length < 2)
      throw new AppError("NOT_ENOUGH_TEAMS", "Need at least 2 confirmed teams", 400)

    const existing = await prisma.match.count({ where: { tournamentId } })
    if (existing > 0)
      throw new AppError("SCHEDULE_EXISTS", `${existing} fixtures already exist. Delete them first.`, 400)

    const pairs = this.buildMatchPairs({
      ...t,
      teams: confirmedTeams,
      groups: await prisma.tournamentGroup.findMany({
        where: { tournamentId },
        include: { teams: { where: { isConfirmed: true } } },
        orderBy: { groupOrder: "asc" },
      }),
      seriesMatchCount: (t as any).seriesMatchCount
    })

    if (pairs.length === 0)
      throw new AppError("NO_PAIRS", "No matches could be built — check teams/groups", 400)

    const startDate = new Date(t.startDate)
    const endDate = t.endDate ? new Date(t.endDate) : null
    let intervalHours = 24
    if (endDate && pairs.length > 1) {
      const totalHours = (endDate.getTime() - startDate.getTime()) / (1000 * 60 * 60)
      intervalHours = Math.max(2, Math.floor(totalHours / pairs.length))
    }

    // Use smart scheduling logic to avoid teams playing twice a day if possible
    const dateOnly = startDate.toISOString().split("T")[0]
    const hour = startDate.getHours()
    const minute = startDate.getMinutes()

    return this.generateSmartSchedule(userId, tournamentId, {
      startDate: dateOnly,
      matchStartTime: `${String(hour).padStart(2, "0")}:${String(minute).padStart(2, "0")}`,
      matchesPerDay: matchesPerDay,
      gapBetweenMatchesHours: intervalHours,
      validWeekdays: [0, 1, 2, 3, 4, 5, 6],
    })
  }

  async generateSchedule(
    userId: string,
    tournamentId: string,
    startDate: string,
    matchIntervalHours: number,
    matchesPerDay: number = 1,
  ) {
    const dateOnly = new Date(startDate).toISOString().split("T")[0]
    const hour = new Date(startDate).getHours()
    const minute = new Date(startDate).getMinutes()
    return this.generateSmartSchedule(userId, tournamentId, {
      startDate: dateOnly,
      matchStartTime: `${String(hour).padStart(2, "0")}:${String(minute).padStart(2, "0")}`,
      matchesPerDay: matchesPerDay,
      gapBetweenMatchesHours: matchIntervalHours,
      validWeekdays: [0, 1, 2, 3, 4, 5, 6],
    })
  }

  async generateSmartSchedule(
    userId: string,
    tournamentId: string,
    options: {
      startDate: string
      matchStartTime: string
      matchesPerDay: number
      gapBetweenMatchesHours: number
      validWeekdays: number[]
      excludeDates?: string[]
    },
  ) {
    const tournament = await prisma.tournament.findUnique({
      where: { id: tournamentId },
      include: {
        teams: { where: { isConfirmed: true }, orderBy: { seed: "asc" } },
        groups: {
          include: { teams: { where: { isConfirmed: true } } },
          orderBy: { groupOrder: "asc" },
        },
      },
    })
    if (!tournament) throw Errors.notFound("Tournament")
    await this.verifyOwner(userId, tournamentId)
    if (tournament.teams.length < 2) {
      throw new AppError(
        "NOT_ENOUGH_TEAMS",
        "Need at least 2 confirmed teams",
        400,
      )
    }

    const format = tournament.tournamentFormat ?? "LEAGUE"
    if (
      (format === "GROUP_STAGE_KNOCKOUT" || format === "SUPER_LEAGUE") &&
      (!tournament.groups || tournament.groups.length === 0)
    ) {
      throw new AppError(
        "NO_GROUPS",
        "Create groups and assign teams before generating schedule",
        400,
      )
    }

    const pairs = this.buildMatchPairs({
      ...tournament,
      seriesMatchCount: (tournament as any).seriesMatchCount,
    })
    if (pairs.length === 0) {
      throw new AppError(
        "NO_PAIRS",
        "No matches could be built — check teams/groups",
        400,
      )
    }

    const existing = await prisma.match.count({ where: { tournamentId } })
    if (existing > 0) {
      throw new AppError(
        "SCHEDULE_EXISTS",
        `${existing} fixtures already exist. Delete them first.`,
        400,
      )
    }

    const [startHour, startMinute] = options.matchStartTime
      .split(":")
      .map(Number)
    const excludedDates = new Set(options.excludeDates ?? [])
    const validWeekdays = new Set(options.validWeekdays)

    const scheduledMatches: any[] = []
    let remaining = [...pairs]
    let cursor = new Date(`${options.startDate}T00:00:00`)
    let totalDaysUsed = 0

    while (remaining.length > 0 && totalDaysUsed < 730) {
      const dayKey = cursor.toISOString().split("T")[0]
      if (validWeekdays.has(cursor.getDay()) && !excludedDates.has(dayKey)) {
        const busyTeamsToday = new Set<string>()
        const deferred: typeof pairs = []
        let slotsUsed = 0

        for (const finalPair of remaining) {
          if (
            slotsUsed < options.matchesPerDay &&
            !busyTeamsToday.has(finalPair.teamAName) &&
            !busyTeamsToday.has(finalPair.teamBName)
          ) {
            const matchTime = new Date(cursor)
            matchTime.setHours(
              startHour,
              startMinute + slotsUsed * options.gapBetweenMatchesHours * 60,
              0,
              0,
            )
            scheduledMatches.push({
              ...finalPair,
              scheduledAt: matchTime,
              venueName: tournament.venueName ?? null,
              tournamentId,
              status: "SCHEDULED",
              isRanked: false,
            })
            busyTeamsToday.add(finalPair.teamAName)
            busyTeamsToday.add(finalPair.teamBName)
            slotsUsed++
          } else {
            deferred.push(finalPair)
          }
        }

        remaining = deferred
      }
      cursor.setDate(cursor.getDate() + 1)
      totalDaysUsed++
    }

    if (remaining.length > 0) {
      throw new AppError(
        "SCHEDULE_TOO_LONG",
        `Could not fit all ${pairs.length} matches within 2 years with the given constraints`,
        400,
      )
    }

    const created = await prisma.$transaction(
      scheduledMatches.map((match) => prisma.match.create({ data: match })),
    )
    return { matchesCreated: created.length, totalDaysUsed }
  }

  async advanceKnockoutRound(userId: string, tournamentId: string) {
    await this.verifyOwner(userId, tournamentId)

    const knockoutRoundOrder = [
      "Round of 32",
      "Round of 16",
      "Quarter Final",
      "Semi Final",
      "Final",
      "Grand Final",
    ]

    const allMatches = await prisma.match.findMany({
      where: { tournamentId },
      orderBy: { scheduledAt: "asc" },
    })

    if (allMatches.length === 0) {
      return { advanced: false, reason: "No fixtures found" }
    }

    const tournament = await prisma.tournament.findUnique({
      where: { id: tournamentId },
      include: { teams: { where: { isConfirmed: true } } },
    })
    if (!tournament) return { advanced: false, reason: "Tournament not found" }

    const format = tournament.tournamentFormat ?? "KNOCKOUT"
    const matchFormat = allMatches[0].format as string
    const roundGroups = new Map<string, typeof allMatches>()

    for (const match of allMatches) {
      const round = match.round ?? "Unknown"
      if (!roundGroups.has(round)) roundGroups.set(round, [])
      roundGroups.get(round)!.push(match)
    }

    const roundsPresent = [...roundGroups.keys()]
    const knockoutRoundsPresent = roundsPresent.filter((round) =>
      knockoutRoundOrder.includes(round),
    )
    const groupRoundsPresent = roundsPresent.filter(
      (round) =>
        !knockoutRoundOrder.includes(round) &&
        round !== "League Stage" &&
        round !== "Unknown",
    )

    const sortedKnockoutRounds = knockoutRoundsPresent.sort(
      (a, b) => knockoutRoundOrder.indexOf(b) - knockoutRoundOrder.indexOf(a),
    )

    for (const round of sortedKnockoutRounds) {
      if (round === "Final" || round === "Grand Final") continue
      const matches = roundGroups.get(round) ?? []
      const completed = matches.filter(
        (match) => match.status === "COMPLETED" || match.status === "ABANDONED",
      )
      if (completed.length < matches.length) {
        return {
          advanced: false,
          reason: `${round}: ${completed.length}/${matches.length} matches completed — finish all matches first`,
        }
      }

      const orderedMatches = [...matches].sort(
        (a, b) =>
          new Date(a.scheduledAt).getTime() - new Date(b.scheduledAt).getTime(),
      )
      const winners = orderedMatches
        .map((match) => match.winnerId)
        .filter((winner): winner is string => !!winner)

      if (winners.length < 2) {
        return {
          advanced: false,
          reason: `${round}: only ${winners.length} match(es) have a winner — declare all results first`,
        }
      }

      const nextRoundName = this.getKnockoutRoundName(winners.length)
      const existing = await prisma.match.count({
        where: { tournamentId, round: nextRoundName },
      })
      if (existing > 0) {
        return {
          advanced: false,
          reason: `${nextRoundName} already exists (${existing} match(es)) — check the schedule`,
        }
      }

      return this.createNextRoundMatches(
        tournamentId,
        nextRoundName,
        winners,
        orderedMatches,
        matchFormat,
      )
    }

    if (
      (format === "GROUP_STAGE_KNOCKOUT" || format === "SUPER_LEAGUE") &&
      groupRoundsPresent.length > 0 &&
      knockoutRoundsPresent.length == 0
    ) {
      for (const groupRound of groupRoundsPresent) {
        const matches = roundGroups.get(groupRound) ?? []
        const completed = matches.filter(
          (match) => match.status === "COMPLETED" || match.status === "ABANDONED",
        )
        if (completed.length < matches.length) {
          return {
            advanced: false,
            reason: `${groupRound}: ${completed.length}/${matches.length} matches completed — finish all group stage matches first`,
          }
        }
      }

      await this.recalculateStandingsInternal(tournamentId)

      const standings = await prisma.tournamentStanding.findMany({
        where: { tournamentId },
        include: { group: true, team: true },
        orderBy: [{ groupId: "asc" }, { points: "desc" }, { nrr: "desc" }],
      })

      const standingsByGroup = new Map<string, typeof standings>()
      for (const standing of standings) {
        const groupName = standing.group?.name ?? "Ungrouped"
        if (!standingsByGroup.has(groupName)) standingsByGroup.set(groupName, [])
        standingsByGroup.get(groupName)!.push(standing)
      }

      const qualifiers: string[] = []
      for (const [, rows] of standingsByGroup) {
        qualifiers.push(...rows.slice(0, 2).map((row) => row.team.teamName))
      }

      if (qualifiers.length < 2) {
        return {
          advanced: false,
          reason: `Not enough group qualifiers (${qualifiers.length}) to create knockout fixtures`,
        }
      }

      const nextRoundName = this.getKnockoutRoundName(qualifiers.length)
      const existing = await prisma.match.count({
        where: { tournamentId, round: nextRoundName },
      })
      if (existing > 0) {
        return {
          advanced: false,
          reason: `${nextRoundName} already exists — check the schedule`,
        }
      }

      const groupKeys = [...standingsByGroup.keys()]
      const seededQualifiers: string[] = []
      if (groupKeys.length === 2) {
        const [groupA, groupB] = groupKeys
        const aTeams = standingsByGroup.get(groupA) ?? []
        const bTeams = standingsByGroup.get(groupB) ?? []
        seededQualifiers.push(
          aTeams[0]?.team.teamName,
          bTeams[1]?.team.teamName,
          bTeams[0]?.team.teamName,
          aTeams[1]?.team.teamName,
        )
      } else {
        seededQualifiers.push(...qualifiers)
      }

      const lastGroupMatch = allMatches[allMatches.length - 1]
      return this.createNextRoundMatches(
        tournamentId,
        nextRoundName,
        seededQualifiers.filter(Boolean) as string[],
        [lastGroupMatch],
        matchFormat,
      )
    }

    return {
      advanced: false,
      reason: "Nothing to advance — ensure all current round matches are completed",
      debug: `Rounds found: [${roundsPresent.join(", ")}]. Knockout rounds: [${knockoutRoundsPresent.join(", ")}].`,
    }
  }

  async deleteSchedule(userId: string, tournamentId: string) {
    await this.verifyOwner(userId, tournamentId)
    const { count } = await prisma.match.deleteMany({ where: { tournamentId } })
    return { deleted: count }
  }

  private buildMatchPairs(tournament: any): any[] {
    const fmt = tournament.tournamentFormat ?? "LEAGUE"
    const confirmedTeams: any[] = tournament.teams
    const pairs: any[] = []

    if (fmt === "LEAGUE") {
      for (let i = 0; i < confirmedTeams.length; i++) {
        for (let j = i + 1; j < confirmedTeams.length; j++) {
          pairs.push({
            matchType: "TOURNAMENT", format: tournament.format, round: "League Stage",
            teamAName: confirmedTeams[i].teamName, teamBName: confirmedTeams[j].teamName,
            teamAPlayerIds: confirmedTeams[i].playerIds, teamBPlayerIds: confirmedTeams[j].playerIds,
          })
        }
      }
    } else if (fmt === "SERIES") {
      if (confirmedTeams.length === 2) {
        const [teamA, teamB] = confirmedTeams
        const totalMatches = tournament.seriesMatchCount || 3
        for (let i = 0; i < totalMatches; i++) {
          pairs.push({
            matchType: "TOURNAMENT", format: tournament.format, round: `Series Match ${i + 1}`,
            teamAName: teamA.teamName, teamBName: teamB.teamName,
            teamAPlayerIds: teamA.playerIds, teamBPlayerIds: teamB.playerIds,
          })
        }
      } else {
        const meetingsPerPair = tournament.seriesMatchCount || 1
        for (let round = 0; round < meetingsPerPair; round++) {
          for (let i = 0; i < confirmedTeams.length; i++) {
            for (let j = i + 1; j < confirmedTeams.length; j++) {
              pairs.push({
                matchType: "TOURNAMENT", format: tournament.format,
                round: meetingsPerPair > 1 ? `Series Round ${round + 1}` : "Series Stage",
                teamAName: confirmedTeams[i].teamName, teamBName: confirmedTeams[j].teamName,
                teamAPlayerIds: confirmedTeams[i].playerIds, teamBPlayerIds: confirmedTeams[j].playerIds,
              })
            }
          }
        }
      }
    } else if (fmt === "KNOCKOUT" || fmt === "DOUBLE_ELIMINATION") {
      let currentTeams = [...confirmedTeams]
      let roundTeamCount = currentTeams.length

      while (roundTeamCount >= 2) {
        const roundName = this.getKnockoutRoundName(roundTeamCount)
        const paired = Math.floor(roundTeamCount / 2)

        for (let i = 0; i < paired; i++) {
          // In the first round, we use real teams. In subsequent rounds, we use placeholders.
          const isFirstRound = roundTeamCount === confirmedTeams.length

          if (isFirstRound) {
            const a = currentTeams[i]
            const b = currentTeams[currentTeams.length - 1 - i]
            pairs.push({
              matchType: "TOURNAMENT", format: tournament.format, round: roundName,
              teamAName: a.teamName, teamBName: b.teamName,
              teamAPlayerIds: a.playerIds, teamBPlayerIds: b.playerIds,
            })
          } else {
            pairs.push({
              matchType: "TOURNAMENT", format: tournament.format, round: roundName,
              teamAName: `Winner of ${this.getKnockoutRoundName(roundTeamCount * 2)} Match ${i * 2 + 1}`,
              teamBName: `Winner of ${this.getKnockoutRoundName(roundTeamCount * 2)} Match ${i * 2 + 2}`,
              teamAPlayerIds: [], teamBPlayerIds: [],
            })
          }
        }

        // Prepare for next round
        roundTeamCount = Math.ceil(roundTeamCount / 2)
        if (roundTeamCount < 2 && roundName !== "Final") {
          // Ensure we have a final if we haven't reached it yet
          roundTeamCount = 2
        }
        if (roundName === "Final") break
      }
    } else if (fmt === "GROUP_STAGE_KNOCKOUT" || fmt === "SUPER_LEAGUE") {
      for (const group of tournament.groups ?? []) {
        if (group.teams.length < 2) continue
        for (let i = 0; i < group.teams.length; i++) {
          for (let j = i + 1; j < group.teams.length; j++) {
            pairs.push({
              matchType: "TOURNAMENT", format: tournament.format, round: group.name,
              teamAName: group.teams[i].teamName, teamBName: group.teams[j].teamName,
              teamAPlayerIds: group.teams[i].playerIds, teamBPlayerIds: group.teams[j].playerIds,
            })
          }
        }
      }
    }
    return pairs
  }

  private getKnockoutRoundName(teamCount: number) {
    if (teamCount >= 32) return "Round of 32"
    if (teamCount >= 16) return "Round of 16"
    if (teamCount >= 8) return "Quarter Final"
    if (teamCount >= 4) return "Semi Final"
    return "Final"
  }

  private async createNextRoundMatches(
    tournamentId: string,
    roundName: string,
    teams: string[],
    referenceMatches: Array<{ scheduledAt: Date } & { format?: any }>,
    matchFormat: string,
  ) {
    const baseTime = new Date(
      referenceMatches[referenceMatches.length - 1].scheduledAt,
    )
    baseTime.setDate(baseTime.getDate() + 1)
    baseTime.setHours(
      new Date(referenceMatches[0].scheduledAt).getHours(),
      new Date(referenceMatches[0].scheduledAt).getMinutes(),
      0,
      0,
    )

    const nextMatches = []
    for (let i = 0; i + 1 < teams.length; i += 2) {
      const scheduledAt = new Date(baseTime)
      scheduledAt.setHours(scheduledAt.getHours() + Math.floor(i / 2) * 3)
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
      })
    }

    await prisma.match.createMany({ data: nextMatches })

    // Notify tournament followers
    this.notifyTournamentFollowers(tournamentId, `New matches scheduled for ${roundName}`).catch(() => {})

    return { advanced: true, round: roundName, matches: nextMatches.length }
  }

  private async notifyTournamentFollowers(tournamentId: string, message: string) {
    const tournament = await prisma.tournament.findUnique({ where: { id: tournamentId }, select: { name: true } })
    if (!tournament) return

    const follows = await prisma.follow.findMany({
      where: { targetId: tournamentId, targetType: 'TOURNAMENT' },
      include: { follower: { select: { userId: true } } },
    })

    for (const follow of follows) {
      notificationSvc.createNotification(follow.follower.userId, {
        type: 'TOURNAMENT_UPDATE',
        title: tournament.name,
        body: message,
        entityType: 'TOURNAMENT',
        entityId: tournamentId,
        sendPush: true,
      }).catch(() => {})
    }
  }

  async searchTournaments(
    query: string,
    limit: number,
    filters?: {
      city?: string
      format?: "T10" | "T20" | "ONE_DAY" | "TWO_INNINGS" | "BOX_CRICKET" | "CUSTOM" | "TEST"
      tournamentStatus?: string
      sport?: "CRICKET" | "FUTSAL" | "PICKLEBALL" | "BADMINTON" | "FOOTBALL" | "BASKETBALL" | "TENNIS" | "OTHER"
    },
  ) {
    const trimmedQuery = query.trim()
    const where: any = {
      isPublic: true,
    }
    const andFilters: any[] = []

    if (trimmedQuery) {
      andFilters.push({
        OR: [
          { name: { contains: trimmedQuery, mode: 'insensitive' } },
          { city: { contains: trimmedQuery, mode: 'insensitive' } },
          { venueName: { contains: trimmedQuery, mode: 'insensitive' } },
        ],
      })
    }

    if (filters?.city) {
      andFilters.push({ city: { contains: filters.city, mode: 'insensitive' } })
    }
    if (filters?.format) {
      andFilters.push({ format: filters.format as any })
    }
    if (filters?.tournamentStatus) {
      andFilters.push({ status: filters.tournamentStatus })
    }
    if (filters?.sport) {
      andFilters.push({ sport: filters.sport as any })
    }

    if (andFilters.length > 0) {
      where.AND = andFilters
    }

    return prisma.tournament.findMany({
      where,
      select: {
        id: true, name: true, city: true, venueName: true,
        format: true, sport: true, status: true, startDate: true, endDate: true,
        maxTeams: true, entryFee: true, prizePool: true,
      },
      orderBy: { startDate: 'desc' },
      take: limit,
    })
  }
}
