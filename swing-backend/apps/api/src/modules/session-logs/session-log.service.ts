import { prisma } from '@swing/db'
import { Errors } from '../../lib/errors'

// Pre-defined skill chips by role — these are the building blocks of the skill matrix
export const STRENGTH_CHIPS = {
  BATTING: ['front_foot', 'back_foot', 'off_drive', 'on_drive', 'pull_shot', 'cut_shot', 'sweep', 'defense', 'running_bwwickets', 'shot_selection', 'temperament', 'footwork'],
  BOWLING: ['line_length', 'swing', 'seam', 'pace', 'spin', 'variation', 'yorker', 'bouncer', 'stamina', 'discipline', 'rhythm', 'control'],
  FIELDING: ['catching', 'ground_fielding', 'throwing', 'reflexes', 'positioning'],
  FITNESS: ['stamina', 'speed', 'agility', 'strength', 'flexibility'],
  MENTAL: ['concentration', 'pressure_handling', 'coachability', 'effort', 'attitude'],
}

export class SessionLogService {
  // Verify coach has access to this academy
  private async verifyCoachAccess(coachUserId: string, academyId: string) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId: coachUserId } })
    if (!coach) throw Errors.forbidden()
    const link = await prisma.academyCoach.findUnique({
      where: { academyId_coachId: { academyId, coachId: coach.id } },
    })
    if (!link || !link.isActive) throw Errors.forbidden()
    return coach
  }

  // Upsert a session log for a batch+date, then upsert all student logs
  async logSession(
    coachUserId: string,
    academyId: string,
    batchId: string,
    sessionDate: string,
    overallNote: string | undefined,
    studentLogs: Array<{
      enrollmentId: string
      playerProfileId: string
      strengthChips: string[]
      weaknessChips: string[]
      currentFocusArea?: string
      effortRating?: number
      coachNote?: string
      drillRecommended?: string
      followUpNeeded?: boolean
      oneOnOneRecommended?: boolean
    }>,
    sessionId?: string,
  ) {
    const coach = await this.verifyCoachAccess(coachUserId, academyId)
    const date = new Date(sessionDate)

    // Upsert the session log header
    const sessionLog = await prisma.sessionLog.upsert({
      where: sessionId ? { sessionId } : { id: 'nonexistent' },
      create: {
        academyId,
        batchId,
        coachId: coach.id,
        sessionId: sessionId ?? null,
        sessionDate: date,
        overallNote,
      },
      update: {
        overallNote,
        updatedAt: new Date(),
      },
    })

    // Upsert all student observations
    for (const sl of studentLogs) {
      await prisma.studentSessionLog.upsert({
        where: { sessionLogId_enrollmentId: { sessionLogId: sessionLog.id, enrollmentId: sl.enrollmentId } },
        create: {
          sessionLogId: sessionLog.id,
          enrollmentId: sl.enrollmentId,
          playerProfileId: sl.playerProfileId,
          coachId: coach.id,
          academyId,
          batchId,
          sessionDate: date,
          strengthChips: sl.strengthChips ?? [],
          weaknessChips: sl.weaknessChips ?? [],
          currentFocusArea: sl.currentFocusArea,
          effortRating: sl.effortRating,
          coachNote: sl.coachNote,
          drillRecommended: sl.drillRecommended,
          followUpNeeded: sl.followUpNeeded ?? false,
          oneOnOneRecommended: sl.oneOnOneRecommended ?? false,
        },
        update: {
          strengthChips: sl.strengthChips ?? [],
          weaknessChips: sl.weaknessChips ?? [],
          currentFocusArea: sl.currentFocusArea,
          effortRating: sl.effortRating,
          coachNote: sl.coachNote,
          drillRecommended: sl.drillRecommended,
          followUpNeeded: sl.followUpNeeded ?? false,
          oneOnOneRecommended: sl.oneOnOneRecommended ?? false,
          updatedAt: new Date(),
        },
      })
    }

    // Update lastInsightDate and coachEngagementScore on each enrollment
    for (const sl of studentLogs) {
      const allLogsForEnrollment = await prisma.studentSessionLog.count({
        where: { enrollmentId: sl.enrollmentId },
      })
      const attendanceCount = await prisma.sessionAttendance.count({
        where: { playerProfileId: sl.playerProfileId, status: { in: ['PRESENT', 'LATE'] } },
      })
      const engagementScore = attendanceCount > 0
        ? Math.min(100, Math.round((allLogsForEnrollment / attendanceCount) * 100))
        : 0

      await prisma.academyEnrollment.update({
        where: { id: sl.enrollmentId },
        data: {
          lastInsightDate: date,
          coachEngagementScore: engagementScore,
          oneOnOneFlagged: sl.oneOnOneRecommended || false,
        },
      })
    }

    // Recompute skill matrices for all students in this log
    for (const sl of studentLogs) {
      await this.recomputeSkillMatrix(sl.playerProfileId, academyId)
    }

    return prisma.sessionLog.findUnique({
      where: { id: sessionLog.id },
      include: { studentLogs: true },
    })
  }

  // Get a single session log (by session log id)
  async getSessionLog(sessionLogId: string, coachUserId: string) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId: coachUserId } })
    if (!coach) throw Errors.forbidden()
    const log = await prisma.sessionLog.findFirst({
      where: { id: sessionLogId, coachId: coach.id },
      include: {
        studentLogs: {
          include: {
            enrollment: {
              include: {
                playerProfile: { include: { user: { select: { name: true, avatarUrl: true } } } },
              },
            },
          },
        },
      },
    })
    if (!log) throw Errors.notFound('Session log')
    return log
  }

  // Get all session logs for a batch (coach view)
  async getBatchSessionLogs(coachUserId: string, academyId: string, batchId: string, limit = 20) {
    const coach = await this.verifyCoachAccess(coachUserId, academyId)
    return prisma.sessionLog.findMany({
      where: { coachId: coach.id, batchId, academyId },
      include: {
        studentLogs: { select: { enrollmentId: true, strengthChips: true, weaknessChips: true, effortRating: true, followUpNeeded: true, oneOnOneRecommended: true } },
      },
      orderBy: { sessionDate: 'desc' },
      take: limit,
    })
  }

  // Get student insights — last N session logs + computed patterns
  async getStudentInsights(coachUserId: string, enrollmentId: string, limit = 10) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId: coachUserId } })
    if (!coach) throw Errors.forbidden()

    const logs = await prisma.studentSessionLog.findMany({
      where: { enrollmentId, coachId: coach.id },
      orderBy: { sessionDate: 'desc' },
      take: limit,
    })

    if (logs.length === 0) return { logs: [], insights: null }

    // Count chip occurrences
    const weaknessCounts: Record<string, number> = {}
    const strengthCounts: Record<string, number> = {}
    for (const log of logs) {
      for (const w of log.weaknessChips) weaknessCounts[w] = (weaknessCounts[w] ?? 0) + 1
      for (const s of log.strengthChips) strengthCounts[s] = (strengthCounts[s] ?? 0) + 1
    }

    const topWeaknesses = Object.entries(weaknessCounts)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 3)
      .map(([chip, count]) => ({ chip, count }))

    const topStrengths = Object.entries(strengthCounts)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 3)
      .map(([chip, count]) => ({ chip, count }))

    // Detect stagnation: same weakness 5+ times in last 10 logs
    const stagnating = topWeaknesses.filter((w) => w.count >= 5).map((w) => w.chip)

    // Detect improvement: weakness was in first half but not second half
    const half = Math.ceil(logs.length / 2)
    const recentLogs = logs.slice(0, half)
    const olderLogs = logs.slice(half)
    const recentWeaknesses = new Set(recentLogs.flatMap((l) => l.weaknessChips))
    const olderWeaknesses = new Set(olderLogs.flatMap((l) => l.weaknessChips))
    const improved = [...olderWeaknesses].filter((w) => !recentWeaknesses.has(w))

    const currentFocusArea = logs[0]?.currentFocusArea ?? null
    const lastLogDate = logs[0]?.sessionDate ?? null
    const daysSinceLastLog = lastLogDate
      ? Math.floor((Date.now() - new Date(lastLogDate).getTime()) / 86400000)
      : null

    const needsIntervention =
      stagnating.length >= 2 ||
      (daysSinceLastLog !== null && daysSinceLastLog > 14)

    return {
      logs,
      insights: {
        topWeaknesses,
        topStrengths,
        currentFocusArea,
        stagnating,
        improved,
        needsIntervention,
        daysSinceLastLog,
        totalLogsCount: await prisma.studentSessionLog.count({ where: { enrollmentId } }),
        oneOnOneRecommended: logs.some((l) => l.oneOnOneRecommended),
      },
    }
  }

  // Get batch insights — aggregate across all students
  async getBatchInsights(coachUserId: string, academyId: string, batchId: string) {
    const coach = await this.verifyCoachAccess(coachUserId, academyId)

    // Last 30 days of logs
    const since = new Date()
    since.setDate(since.getDate() - 30)

    const logs = await prisma.studentSessionLog.findMany({
      where: { coachId: coach.id, batchId, academyId, sessionDate: { gte: since } },
      include: {
        enrollment: {
          include: {
            playerProfile: { include: { user: { select: { name: true, avatarUrl: true } } } },
          },
        },
      },
    })

    // Common weaknesses across batch
    const weaknessCounts: Record<string, number> = {}
    const strengthCounts: Record<string, number> = {}
    const studentWeaknessMap: Record<string, Set<string>> = {}
    const followUpStudents: Array<{ enrollmentId: string; name: string }> = []
    const oneOnOneStudents: Array<{ enrollmentId: string; name: string }> = []

    for (const log of logs) {
      const name = log.enrollment.playerProfile?.user?.name ?? 'Student'
      for (const w of log.weaknessChips) {
        weaknessCounts[w] = (weaknessCounts[w] ?? 0) + 1
        if (!studentWeaknessMap[log.enrollmentId]) studentWeaknessMap[log.enrollmentId] = new Set()
        studentWeaknessMap[log.enrollmentId].add(w)
      }
      for (const s of log.strengthChips) strengthCounts[s] = (strengthCounts[s] ?? 0) + 1
      if (log.followUpNeeded) followUpStudents.push({ enrollmentId: log.enrollmentId, name })
      if (log.oneOnOneRecommended) oneOnOneStudents.push({ enrollmentId: log.enrollmentId, name })
    }

    const commonWeaknesses = Object.entries(weaknessCounts)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5)
      .map(([chip, count]) => ({ chip, count, studentsAffected: Object.values(studentWeaknessMap).filter((s) => s.has(chip)).length }))

    const commonStrengths = Object.entries(strengthCounts)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 3)
      .map(([chip, count]) => ({ chip, count }))

    // Low attendance students (using enrollments)
    const enrollments = await prisma.academyEnrollment.findMany({
      where: { batchId, isActive: true },
      include: { playerProfile: { include: { user: { select: { name: true } } } } },
    })

    // For each enrollment calculate attendance in last 30 days
    const lowAttendanceStudents = []
    for (const e of enrollments) {
      const totalSessions = await prisma.practiceSession.count({
        where: { batchId, scheduledAt: { gte: since } },
      })
      if (totalSessions === 0) continue
      const present = await prisma.sessionAttendance.count({
        where: {
          playerProfileId: e.playerProfileId,
          status: { in: ['PRESENT', 'LATE'] },
          session: { batchId, scheduledAt: { gte: since } },
        },
      })
      const pct = Math.round((present / totalSessions) * 100)
      if (pct < 60) {
        lowAttendanceStudents.push({
          enrollmentId: e.id,
          name: e.playerProfile?.user?.name ?? 'Student',
          attendancePct: pct,
        })
      }
    }

    // Students with no recent logs
    const noRecentLogStudents = []
    for (const e of enrollments) {
      const lastLog = await prisma.studentSessionLog.findFirst({
        where: { enrollmentId: e.id },
        orderBy: { sessionDate: 'desc' },
      })
      const daysSince = lastLog
        ? Math.floor((Date.now() - new Date(lastLog.sessionDate).getTime()) / 86400000)
        : 999
      if (daysSince > 7) {
        noRecentLogStudents.push({
          enrollmentId: e.id,
          name: e.playerProfile?.user?.name ?? 'Student',
          daysSinceLastLog: daysSince,
        })
      }
    }

    return {
      commonWeaknesses,
      commonStrengths,
      followUpStudents: [...new Map(followUpStudents.map((s) => [s.enrollmentId, s])).values()],
      oneOnOneStudents: [...new Map(oneOnOneStudents.map((s) => [s.enrollmentId, s])).values()],
      lowAttendanceStudents,
      noRecentLogStudents,
      totalLogsThisMonth: logs.length,
    }
  }

  // Get student development overview for club (academy owner view)
  async getAcademyDevelopmentOverview(ownerUserId: string, academyId: string) {
    // Verify ownership
    const owner = await prisma.academyOwnerProfile.findUnique({ where: { userId: ownerUserId } })
    if (!owner) throw Errors.forbidden()
    const academy = await prisma.academy.findFirst({ where: { id: academyId, ownerId: owner.id } })
    if (!academy) throw Errors.forbidden()

    const enrollments = await prisma.academyEnrollment.findMany({
      where: { academyId, isActive: true },
      include: {
        playerProfile: { include: { user: { select: { name: true, phone: true, avatarUrl: true } } } },
        batch: { select: { name: true } },
      },
    })

    const sevenDaysAgo = new Date()
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7)

    const needsAttention = enrollments.filter((e) => {
      const noRecentInsight = !e.lastInsightDate || new Date(e.lastInsightDate) < sevenDaysAgo
      const lowEngagement = e.coachEngagementScore < 70
      const lowAttendance = false // attendance % not stored on enrollment directly
      return noRecentInsight || lowEngagement || e.oneOnOneFlagged
    })

    return {
      totalStudents: enrollments.length,
      studentsNeedingAttention: needsAttention.map((e) => ({
        enrollmentId: e.id,
        name: e.playerProfile?.user?.name ?? 'Student',
        phone: e.playerProfile?.user?.phone,
        batchName: e.batch?.name,
        lastInsightDate: e.lastInsightDate,
        coachEngagementScore: e.coachEngagementScore,
        oneOnOneFlagged: e.oneOnOneFlagged,
        enrollmentStatus: e.enrollmentStatus,
      })),
    }
  }

  // Recompute skill matrix for a student (called after each session log)
  async recomputeSkillMatrix(playerProfileId: string, academyId: string) {
    const logs = await prisma.studentSessionLog.findMany({
      where: { playerProfileId, academyId },
      orderBy: { sessionDate: 'desc' },
      take: 20,
    })

    if (logs.length === 0) return

    const dimensions: Record<string, { score: number; trend: string; count: number; lastUpdated: string }> = {}

    // Count all chips
    const allChips: Record<string, { strengths: number; weaknesses: number }> = {}
    for (const log of logs) {
      for (const chip of log.strengthChips) {
        if (!allChips[chip]) allChips[chip] = { strengths: 0, weaknesses: 0 }
        allChips[chip].strengths++
      }
      for (const chip of log.weaknessChips) {
        if (!allChips[chip]) allChips[chip] = { strengths: 0, weaknesses: 0 }
        allChips[chip].weaknesses++
      }
    }

    for (const [chip, counts] of Object.entries(allChips)) {
      const total = counts.strengths + counts.weaknesses
      const score = Math.round((counts.strengths / total) * 100)

      // Trend: compare first half vs second half
      const half = Math.ceil(logs.length / 2)
      const recentStrengths = logs.slice(0, half).filter((l) => l.strengthChips.includes(chip)).length
      const olderStrengths = logs.slice(half).filter((l) => l.strengthChips.includes(chip)).length
      let trend = 'STABLE'
      if (half > 0 && recentStrengths > olderStrengths) trend = 'IMPROVING'
      else if (half > 0 && recentStrengths < olderStrengths) trend = 'DECLINING'

      dimensions[chip] = { score, trend, count: total, lastUpdated: new Date().toISOString() }
    }

    await prisma.skillMatrixSnapshot.upsert({
      where: { playerProfileId_academyId: { playerProfileId, academyId } },
      create: { playerProfileId, academyId, dimensions, dataPoints: logs.length },
      update: { dimensions, dataPoints: logs.length, computedAt: new Date() },
    })
  }

  // Get skill matrix for a student
  async getSkillMatrix(playerProfileId: string, academyId: string) {
    return prisma.skillMatrixSnapshot.findUnique({
      where: { playerProfileId_academyId: { playerProfileId, academyId } },
    })
  }
}
