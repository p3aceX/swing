import { prisma } from '@swing/db'
import { Errors } from '../../lib/errors'
import { enqueueNotification } from '../../lib/queue'
import { sendPushNotification } from '../../lib/firebase'

type NotificationPreferenceKey =
  | 'chatMessages'
  | 'newFollowers'
  | 'rankUpdates'
  | 'matchResults'
  | 'productAnnouncements'

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

  async sendPush(userId: string, title: string, body: string, data?: Record<string, string>) {
    const user = await prisma.user.findUnique({ where: { id: userId }, select: { fcmTokens: true } })
    if (!user || user.fcmTokens.length === 0) return

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
  }) {
    return prisma.notificationPreference.upsert({
      where: { userId },
      create: { userId, ...data },
      update: data,
    })
  }

  async getSummary(userId: string) {
    const [notificationUnreadCount, profile, preferences] = await Promise.all([
      prisma.notification.count({
        where: { userId, isRead: false },
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

  async getNotifications(userId: string, page: number, limit: number) {
    const [notifications, total, unreadCount] = await prisma.$transaction([
      prisma.notification.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.notification.count({ where: { userId } }),
      prisma.notification.count({ where: { userId, isRead: false } }),
    ])
    return { notifications, total, unreadCount, page, limit }
  }

  async markRead(notificationId: string, userId: string) {
    const notif = await prisma.notification.findUnique({ where: { id: notificationId } })
    if (!notif) throw Errors.notFound('Notification')
    if (notif.userId !== userId) throw Errors.forbidden()
    return prisma.notification.update({ where: { id: notificationId }, data: { isRead: true, readAt: new Date(), status: 'READ' } })
  }

  async markAllRead(userId: string) {
    await prisma.notification.updateMany({
      where: { userId, isRead: false },
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
  }) {
    const notif = await prisma.notification.create({
      data: {
        userId,
        type: data.type,
        channel: 'PUSH',
        title: data.title,
        body: data.body,
        entityType: data.entityType,
        entityId: data.entityId,
        data: data.data,
      },
    })

    if (
      data.sendPush !== false
      && await this.shouldSendPush(userId, data.preferenceKey)
    ) {
      await enqueueNotification('push', { userId, title: data.title, body: data.body, data: { type: data.type, entityId: data.entityId || '' } })
    }

    return notif
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
}
