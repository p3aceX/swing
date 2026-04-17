import { prisma } from '@swing/db'
import { Errors, AppError } from '../../lib/errors'

const LATE_THRESHOLD_MINUTES = 15
const COACH_MAX_DISTANCE_METERS = 500

function haversineDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const R = 6371000
  const dLat = ((lat2 - lat1) * Math.PI) / 180
  const dLon = ((lon2 - lon1) * Math.PI) / 180
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos((lat1 * Math.PI) / 180) * Math.cos((lat2 * Math.PI) / 180) * Math.sin(dLon / 2) ** 2
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
}

export class SessionService {
  async coachCheckin(sessionId: string, userId: string, latitude: number, longitude: number) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    if (!coach) throw Errors.forbidden()
    const session = await prisma.practiceSession.findFirst({ where: { id: sessionId, coachId: coach.id } })
    if (!session) throw Errors.notFound('Session')

    if (session.latitude && session.longitude) {
      const dist = haversineDistance(latitude, longitude, session.latitude, session.longitude)
      if (dist > COACH_MAX_DISTANCE_METERS) {
        throw new AppError('TOO_FAR', `Must be within 500m of session location. Distance: ${Math.round(dist)}m`, 400)
      }
    }

    const isLate = (Date.now() - new Date(session.scheduledAt).getTime()) > LATE_THRESHOLD_MINUTES * 60 * 1000

    return prisma.practiceSession.update({
      where: { id: sessionId },
      data: { coachCheckedInAt: new Date(), coachLatitude: latitude, coachLongitude: longitude, isCoachLate: isLate },
    })
  }

  async playerScanSession(qrToken: string, userId: string, latitude?: number, longitude?: number) {
    const session = await prisma.practiceSession.findFirst({ where: { sessionQrCode: qrToken } })
    if (!session) throw new AppError('QR_INVALID', 'Invalid QR code', 400)
    if (session.qrClosedAt) throw new AppError('QR_CLOSED', 'Session QR is closed', 400)
    if (session.qrExpiresAt && new Date() > session.qrExpiresAt) {
      throw new AppError('QR_EXPIRED', 'QR code has expired', 400)
    }

    const player = await prisma.playerProfile.findUnique({ where: { userId } })
    if (!player) throw Errors.notFound('Player profile')

    const existing = await prisma.sessionAttendance.findUnique({
      where: { sessionId_playerProfileId: { sessionId: session.id, playerProfileId: player.id } },
    })
    if (existing && existing.status !== 'ABSENT') {
      throw new AppError('ALREADY_MARKED', 'Attendance already marked for this session', 409)
    }

    if (session.batchId) {
      const enrollment = await prisma.academyEnrollment.findFirst({
        where: { playerProfileId: player.id, batchId: session.batchId, isActive: true },
      })
      if (!enrollment) throw new AppError('NOT_ENROLLED', 'You are not enrolled in this batch', 403)
    }

    const now = new Date()
    const lateMinutes = Math.max(0, Math.floor((now.getTime() - new Date(session.scheduledAt).getTime()) / 60000))
    const isLate = lateMinutes > LATE_THRESHOLD_MINUTES
    const status = isLate ? 'LATE' : 'PRESENT'

    const attendance = await prisma.sessionAttendance.upsert({
      where: { sessionId_playerProfileId: { sessionId: session.id, playerProfileId: player.id } },
      create: { sessionId: session.id, playerProfileId: player.id, status: status as any, scannedAt: now, scanMethod: 'PLAYER_SCANS_SESSION', lateMinutes },
      update: { status: status as any, scannedAt: now, lateMinutes },
    })

    return { attendance, status }
  }

  async getAttendance(sessionId: string, userId: string) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    if (!coach) throw Errors.forbidden()
    const session = await prisma.practiceSession.findFirst({ where: { id: sessionId, coachId: coach.id } })
    if (!session) throw Errors.notFound('Session')

    return prisma.sessionAttendance.findMany({
      where: { sessionId },
      include: { playerProfile: { include: { user: { select: { name: true, avatarUrl: true } } } } },
      orderBy: { scannedAt: 'asc' },
    })
  }
}
