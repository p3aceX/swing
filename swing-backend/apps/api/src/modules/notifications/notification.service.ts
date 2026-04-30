import { prisma } from '@swing/db'
import { AppError } from '../../lib/errors'
import { Errors } from '../../lib/errors'
import { enqueueNotification, notificationQueue } from '../../lib/queue'
import { sendPushNotification } from '../../lib/firebase'
import { sendOneSignalPushNotification } from '../../lib/onesignal'

type NotificationPreferenceKey =
  | 'chatMessages'
  | 'newFollowers'
  | 'rankUpdates'
  | 'matchResults'
  | 'productAnnouncements'
  | 'arenaBookings'
  | 'bookingReminders'

type NotificationAudience = 'PLAYER' | 'BIZ_OWNER' | 'ALL'

export class NotificationService {
  private async getOrCreatePreferences(userId: string) {
    return prisma.notificationPreference.upsert({
      where: { userId },
      create: { userId },
      update: {},
    })
  }

  private async shouldSendPush(
    userId: string,
    preferenceKey?: NotificationPreferenceKey,
  ) {
    const preferences = await this.getOrCreatePreferences(userId)
    if (!preferences.pushEnabled) return false
    if (!preferenceKey) return true
    return preferences[preferenceKey]
  }

  async sendPush(
    userId: string,
    title: string,
    body: string,
    data?: Record<string, string>,
    audience: NotificationAudience = 'PLAYER',
  ) {
    const user = await prisma.user.findUnique({ where: { id: userId }, select: { fcmTokens: true } })
    if (!user) return

    if ((audience === 'PLAYER' || audience === 'ALL') && user.fcmTokens.length > 0) {
      try {
        const { invalidTokens } = await sendPushNotification(user.fcmTokens, title, body, data)
        if (invalidTokens.length > 0) {
          await prisma.user.update({
            where: { id: userId },
            data: { fcmTokens: { set: user.fcmTokens.filter(t => !invalidTokens.includes(t)) } },
          })
        }
      } catch (err) {
        console.error('[FCM] Send error:', err)
      }
    }

    if (audience === 'BIZ_OWNER' || audience === 'ALL') {
      try {
        await sendOneSignalPushNotification(userId, title, body, data, audience)
      } catch (err) {
        console.error('[OneSignal] Send error:', err)
      }
    }
  }

  async registerFcmToken(userId: string, token: string) {
    const user = await prisma.user.findUnique({ where: { id: userId }, select: { fcmTokens: true } })
    if (!user) throw Errors.notFound('User')
    if (user.fcmTokens.includes(token)) return { message: 'Token already registered' }

    await prisma.user.update({
      where: { id: userId },
      data: { fcmTokens: { push: token } },
    })
    return { message: 'FCM token registered' }
  }

  async removeFcmToken(userId: string, token: string) {
    const user = await prisma.user.findUnique({ where: { id: userId }, select: { fcmTokens: true } })
    if (!user) throw Errors.notFound('User')

    await prisma.user.update({
      where: { id: userId },
      data: { fcmTokens: { set: user.fcmTokens.filter(t => t !== token) } },
    })
    return { message: 'FCM token removed' }
  }

  async getPreferences(userId: string) {
    return this.getOrCreatePreferences(userId)
  }

  async updatePreferences(userId: string, data: {
    pushEnabled?: boolean
    chatMessages?: boolean
    newFollowers?: boolean
    rankUpdates?: boolean
    matchResults?: boolean
    productAnnouncements?: boolean
    arenaBookings?: boolean
    bookingReminders?: boolean
  }) {
    return prisma.notificationPreference.upsert({
      where: { userId },
      create: { userId, ...data },
      update: data,
    })
  }

  async getSummary(userId: string, types?: string[]) {
    const typeFilter = types && types.length > 0 ? { in: types } : undefined
    const [notificationUnreadCount, profile, preferences] = await Promise.all([
      prisma.notification.count({
        where: {
          userId,
          isRead: false,
          ...(typeFilter ? { type: typeFilter } : {}),
        },
      }),
      prisma.playerProfile.findUnique({
        where: { userId },
        select: { id: true },
      }),
      this.getOrCreatePreferences(userId),
    ])

    if (!profile) {
      return {
        unreadNotificationCount: notificationUnreadCount,
        unreadConversationCount: 0,
        unreadMessageCount: 0,
        preferences,
      }
    }

    const memberships = await prisma.chatConversationParticipant.findMany({
      where: { playerId: profile.id },
      select: {
        conversationId: true,
        lastReadAt: true,
        conversation: {
          select: {
            lastMessageAt: true,
            lastMessageSenderId: true,
          },
        },
      },
    })

    const unreadMemberships = memberships.filter((membership) => {
      const lastMessageAt = membership.conversation.lastMessageAt
      if (!lastMessageAt) return false
      if (membership.conversation.lastMessageSenderId === profile.id) return false
      return membership.lastReadAt == null || lastMessageAt > membership.lastReadAt
    })

    const unreadMessageCount = unreadMemberships.length === 0
      ? 0
      : (
          await Promise.all(
            unreadMemberships.map((membership) =>
              prisma.chatMessage.count({
                where: {
                  conversationId: membership.conversationId,
                  senderPlayerId: { not: profile.id },
                  createdAt: membership.lastReadAt
                    ? { gt: membership.lastReadAt }
                    : undefined,
                },
              }),
            ),
          )
        ).reduce((sum, count) => sum + count, 0)

    return {
      unreadNotificationCount: notificationUnreadCount,
      unreadConversationCount: unreadMemberships.length,
      unreadMessageCount,
      preferences,
    }
  }

  async getNotifications(
    userId: string,
    page: number,
    limit: number,
    types?: string[],
  ) {
    const typeFilter = types && types.length > 0 ? { in: types } : undefined
    const where = {
      userId,
      ...(typeFilter ? { type: typeFilter } : {}),
    }
    const [notifications, total, unreadCount] = await prisma.$transaction([
      prisma.notification.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.notification.count({ where }),
      prisma.notification.count({ where: { ...where, isRead: false } }),
    ])
    return { notifications, total, unreadCount, page, limit }
  }

  async markRead(notificationId: string, userId: string) {
    const notif = await prisma.notification.findUnique({ where: { id: notificationId } })
    if (!notif) throw Errors.notFound('Notification')
    if (notif.userId !== userId) throw Errors.forbidden()
    return prisma.notification.update({ where: { id: notificationId }, data: { isRead: true, readAt: new Date(), status: 'READ' } })
  }

  async markAllRead(userId: string, types?: string[]) {
    const typeFilter = types && types.length > 0 ? { in: types } : undefined
    await prisma.notification.updateMany({
      where: {
        userId,
        isRead: false,
        ...(typeFilter ? { type: typeFilter } : {}),
      },
      data: { isRead: true, readAt: new Date(), status: 'READ' },
    })
    return { message: 'All notifications marked as read' }
  }

  async createNotification(userId: string, data: {
    type: string
    title: string
    body: string
    entityType?: string
    entityId?: string
    data?: any
    sendPush?: boolean
    preferenceKey?: NotificationPreferenceKey
    audience?: NotificationAudience
  }) {
    const audience = data.audience ?? 'PLAYER'
    const notif = await prisma.notification.create({
      data: {
        userId,
        type: data.type,
        channel: 'PUSH',
        title: data.title,
        body: data.body,
        entityType: data.entityType,
        entityId: data.entityId,
        data: {
          ...(data.data && typeof data.data === 'object' ? data.data : {}),
          source: 'backend',
          audience,
        },
      },
    })

    if (
      data.sendPush !== false
      && await this.shouldSendPush(userId, data.preferenceKey)
    ) {
      const pushPayload = {
        userId,
        title: data.title,
        body: data.body,
        data: { type: data.type, entityId: data.entityId || '', audience },
        audience,
      }
      if (notificationQueue) {
        await enqueueNotification('push', pushPayload)
      } else {
        // Queue not available — send directly (fire-and-forget)
        this.sendPush(userId, data.title, data.body, { type: data.type, entityId: data.entityId || '', audience }, audience)
          .catch(err => console.error('[notify] direct push failed:', err))
      }
    }

    return notif
  }

  async syncOneSignalNotification(userId: string, data: {
    notificationId: string
    type?: string
    title?: string
    body: string
    entityType?: string
    entityId?: string
    data?: any
  }) {
    if (!data.notificationId) throw new AppError('VALIDATION_ERROR', 'notificationId is required', 400)

    const existing = await prisma.notification.findFirst({
      where: {
        userId,
        provider: 'ONESIGNAL',
        providerId: data.notificationId,
      },
    })
    if (existing) return existing

    return prisma.notification.create({
      data: {
        userId,
        type: data.type || 'SYSTEM',
        channel: 'PUSH',
        status: 'SENT',
        title: data.title || null,
        body: data.body,
        entityType: data.entityType,
        entityId: data.entityId,
        data: {
          ...(data.data && typeof data.data === 'object' ? data.data : {}),
          source: 'onesignal',
        },
        provider: 'ONESIGNAL',
        providerId: data.notificationId,
        sentAt: new Date(),
        deliveredAt: new Date(),
      },
    })
  }

  async broadcastToUsers(userIds: string[], notification: {
    type: string
    title: string
    body: string
    entityType?: string
    entityId?: string
  }) {
    const notifs = await prisma.notification.createMany({
      data: userIds.map(userId => ({
        userId,
        type: notification.type,
        channel: 'PUSH' as any,
        title: notification.title,
        body: notification.body,
        entityType: notification.entityType,
        entityId: notification.entityId,
      })),
    })

    for (const userId of userIds) {
      await enqueueNotification('push', { userId, title: notification.title, body: notification.body })
    }

    return { sent: notifs.count }
  }

  async notifyBookingConfirmed(booking: {
    id: string
    arenaId: string
    unitId: string
    date: Date
    startTime: string
    endTime: string
    bookedById: string
  }) {
    const [arena, unit, bookedBy] = await Promise.all([
      prisma.arena.findUnique({ where: { id: booking.arenaId }, select: { name: true, ownerId: true } }),
      prisma.arenaUnit.findUnique({ where: { id: booking.unitId }, select: { name: true } }),
      prisma.playerProfile.findUnique({ where: { id: booking.bookedById }, select: { userId: true, user: { select: { name: true } } } }),
    ])
    if (!arena || !unit || !bookedBy) return

    const dateStr = booking.date.toLocaleDateString('en-IN', { day: 'numeric', month: 'short' })
    const slotStr = `${booking.startTime} – ${booking.endTime}`

    // Notify player
    await this.createNotification(bookedBy.userId, {
      type: 'BOOKING_CONFIRMED',
      title: 'Booking Confirmed!',
      body: `${unit.name} at ${arena.name} · ${dateStr} · ${slotStr}`,
      entityType: 'booking',
      entityId: booking.id,
      sendPush: true,
      preferenceKey: 'arenaBookings',
      audience: 'PLAYER',
    })

    // Notify arena owner
    const owner = await prisma.arenaOwnerProfile.findUnique({
      where: { id: arena.ownerId },
      select: { userId: true },
    })
    if (owner) {
      await this.createNotification(owner.userId, {
        type: 'NEW_BOOKING',
        title: 'New Booking',
        body: `${bookedBy.user?.name ?? 'Someone'} booked ${unit.name} · ${dateStr} · ${slotStr}`,
        entityType: 'booking',
        entityId: booking.id,
        sendPush: true,
        preferenceKey: 'arenaBookings',
        audience: 'BIZ_OWNER',
      })
    }
  }

  async notifyBookingCancelled(booking: {
    id: string
    arenaId: string
    unitId: string
    date: Date
    startTime: string
    endTime: string
    bookedById: string
  }) {
    const [arena, unit, bookedBy] = await Promise.all([
      prisma.arena.findUnique({ where: { id: booking.arenaId }, select: { name: true, ownerId: true } }),
      prisma.arenaUnit.findUnique({ where: { id: booking.unitId }, select: { name: true } }),
      prisma.playerProfile.findUnique({ where: { id: booking.bookedById }, select: { userId: true, user: { select: { name: true } } } }),
    ])
    if (!arena || !unit || !bookedBy) return

    const dateStr = booking.date.toLocaleDateString('en-IN', { day: 'numeric', month: 'short' })

    await this.createNotification(bookedBy.userId, {
      type: 'BOOKING_CANCELLED',
      title: 'Booking Cancelled',
      body: `${unit.name} at ${arena.name} on ${dateStr} has been cancelled`,
      entityType: 'booking',
      entityId: booking.id,
      sendPush: true,
      preferenceKey: 'arenaBookings',
      audience: 'PLAYER',
    })

    const owner = await prisma.arenaOwnerProfile.findUnique({
      where: { id: arena.ownerId },
      select: { userId: true },
    })
    if (owner) {
      await this.createNotification(owner.userId, {
        type: 'BOOKING_CANCELLED',
        title: 'Booking Cancelled',
        body: `${bookedBy.user?.name ?? 'A player'} cancelled ${unit.name} on ${dateStr}`,
        entityType: 'booking',
        entityId: booking.id,
        sendPush: true,
        preferenceKey: 'arenaBookings',
        audience: 'BIZ_OWNER',
      })
    }
  }
}
