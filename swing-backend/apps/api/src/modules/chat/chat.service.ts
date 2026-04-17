import { prisma } from '@swing/db'
import { AppError, Errors } from '../../lib/errors'
import { buildPaginationMeta, getPaginationParams } from '@swing/utils'
import { NotificationService } from '../notifications/notification.service'

export class ChatService {
  private readonly notificationService = new NotificationService()

  private async getRequiredProfile(userId: string) {
    const existing = await prisma.playerProfile.findUnique({ where: { userId } })
    if (existing) return existing
    return prisma.playerProfile.create({ data: { userId } })
  }

  private buildDirectKey(leftPlayerId: string, rightPlayerId: string) {
    return [leftPlayerId, rightPlayerId].sort().join(':')
  }

  async findExistingDirectConversation(userId: string, otherPlayerId: string) {
    const me = await this.getRequiredProfile(userId)
    if (me.id === otherPlayerId) return null
    const directKey = this.buildDirectKey(me.id, otherPlayerId)
    const existing = await prisma.chatConversation.findUnique({
      where: { directKey },
      select: { id: true },
    })
    return existing?.id ?? null
  }

  private mapParticipant(participant: {
    player: {
      id: string
      username: string | null
      city: string | null
      state: string | null
      user: { name: string | null; avatarUrl: string | null }
    }
  }) {
    return {
      id: participant.player.id,
      fullName: participant.player.user.name ?? 'Swing Player',
      username: participant.player.username,
      avatarUrl: participant.player.user.avatarUrl,
      city: participant.player.city,
      state: participant.player.state,
    }
  }

  async getOrCreateDirectConversation(userId: string, otherPlayerId: string) {
    const me = await this.getRequiredProfile(userId)
    if (me.id === otherPlayerId) {
      throw new AppError('INVALID_CHAT_TARGET', 'You cannot start a chat with yourself', 400)
    }

    const target = await prisma.playerProfile.findUnique({
      where: { id: otherPlayerId },
      select: { id: true },
    })
    if (!target) throw Errors.notFound('Player profile')

    const directKey = this.buildDirectKey(me.id, otherPlayerId)
    const existing = await prisma.chatConversation.findUnique({
      where: { directKey },
      include: {
        participants: {
          include: {
            player: {
              include: {
                user: { select: { name: true, avatarUrl: true } },
              },
            },
          },
        },
      },
    })

    if (existing) {
      return {
        id: existing.id,
        type: existing.type,
        directKey: existing.directKey,
        participants: existing.participants.map((participant) =>
            this.mapParticipant(participant),
        ),
        lastMessageAt: existing.lastMessageAt,
      }
    }

    const created = await prisma.chatConversation.create({
      data: {
        type: 'DIRECT',
        directKey,
        createdByPlayerId: me.id,
        participants: {
          create: [
            { playerId: me.id, lastReadAt: new Date() },
            { playerId: otherPlayerId },
          ],
        },
      },
      include: {
        participants: {
          include: {
            player: {
              include: {
                user: { select: { name: true, avatarUrl: true } },
              },
            },
          },
        },
      },
    })

    return {
      id: created.id,
      type: created.type,
      directKey: created.directKey,
      participants: created.participants.map((participant) =>
          this.mapParticipant(participant),
      ),
      lastMessageAt: created.lastMessageAt,
    }
  }

  async listConversations(userId: string, page: number, limit: number) {
    const me = await this.getRequiredProfile(userId)
    const { skip } = getPaginationParams({ page, limit })

    const [total, rows] = await Promise.all([
      prisma.chatConversation.count({
        where: {
          participants: {
            some: { playerId: me.id },
          },
        },
      }),
      prisma.chatConversation.findMany({
        where: {
          participants: {
            some: { playerId: me.id },
          },
        },
        orderBy: [{ lastMessageAt: 'desc' }, { updatedAt: 'desc' }],
        skip,
        take: limit,
        include: {
          participants: {
            include: {
              player: {
                include: {
                  user: { select: { name: true, avatarUrl: true } },
                },
              },
            },
          },
        },
      }),
    ])

    const unreadCounts = await Promise.all(
      rows.map((conversation) => {
        const membership = conversation.participants.find(
          (participant) => participant.playerId === me.id,
        )
        return prisma.chatMessage.count({
          where: {
            conversationId: conversation.id,
            senderPlayerId: { not: me.id },
            createdAt: membership?.lastReadAt
              ? { gt: membership.lastReadAt }
              : undefined,
          },
        })
      }),
    )

    return {
      data: rows.map((conversation, index) => {
        const counterparty = conversation.participants.find(
          (participant) => participant.playerId !== me.id,
        )
        return {
          id: conversation.id,
          type: conversation.type,
          title:
            conversation.title ??
            counterparty?.player.user.name ??
            'Direct chat',
          directKey: conversation.directKey,
          lastMessageAt: conversation.lastMessageAt,
          lastMessagePreview: conversation.lastMessagePreview,
          lastMessageSenderId: conversation.lastMessageSenderId,
          unreadCount: unreadCounts[index] ?? 0,
          participantCount: conversation.participants.length,
          counterparty: counterparty
              ? this.mapParticipant(counterparty)
              : null,
        }
      }),
      meta: buildPaginationMeta(total, page, limit),
    }
  }

  async listMessages(
    userId: string,
    conversationId: string,
    page: number,
    limit: number,
  ) {
    const me = await this.getRequiredProfile(userId)
    const membership = await prisma.chatConversationParticipant.findUnique({
      where: {
        conversationId_playerId: {
          conversationId,
          playerId: me.id,
        },
      },
    })
    if (!membership) throw Errors.notFound('Conversation')

    const { skip } = getPaginationParams({ page, limit })
    const [total, rows] = await Promise.all([
      prisma.chatMessage.count({
        where: { conversationId },
      }),
      prisma.chatMessage.findMany({
        where: { conversationId },
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
        include: {
          sender: {
            include: {
              user: { select: { name: true, avatarUrl: true } },
            },
          },
        },
      }),
    ])

    await prisma.chatConversationParticipant.update({
      where: {
        conversationId_playerId: {
          conversationId,
          playerId: me.id,
        },
      },
      data: { lastReadAt: new Date() },
    })

    return {
      data: rows
          .reverse()
          .map((message) => ({
            id: message.id,
            kind: message.kind,
            body: message.body,
            attachmentUrl: message.attachmentUrl,
            createdAt: message.createdAt,
            editedAt: message.editedAt,
            deletedAt: message.deletedAt,
            sender: {
              id: message.sender.id,
              fullName: message.sender.user.name ?? 'Swing Player',
              username: message.sender.username,
              avatarUrl: message.sender.user.avatarUrl,
            },
          })),
      meta: buildPaginationMeta(total, page, limit),
    }
  }

  async sendMessage(userId: string, conversationId: string, body: string) {
    const me = await this.getRequiredProfile(userId)
    const trimmed = body.trim()
    if (!trimmed) {
      throw new AppError('EMPTY_MESSAGE', 'Message cannot be empty', 400)
    }

    const membership = await prisma.chatConversationParticipant.findUnique({
      where: {
        conversationId_playerId: {
          conversationId,
          playerId: me.id,
        },
      },
    })
    if (!membership) throw Errors.notFound('Conversation')

    const conversation = await prisma.chatConversation.findUnique({
      where: { id: conversationId },
      include: {
        participants: {
          include: {
            player: {
              select: {
                id: true,
                userId: true,
              },
            },
          },
        },
      },
    })
    if (!conversation) throw Errors.notFound('Conversation')

    const message = await prisma.$transaction(async (tx) => {
      const created = await tx.chatMessage.create({
        data: {
          conversationId,
          senderPlayerId: me.id,
          kind: 'TEXT',
          body: trimmed,
        },
        include: {
          sender: {
            include: {
              user: { select: { name: true, avatarUrl: true } },
            },
          },
        },
      })

      await Promise.all([
        tx.chatConversation.update({
          where: { id: conversationId },
          data: {
            lastMessageAt: created.createdAt,
            lastMessagePreview: trimmed.slice(0, 160),
            lastMessageSenderId: me.id,
          },
        }),
        tx.chatConversationParticipant.update({
          where: {
            conversationId_playerId: {
              conversationId,
              playerId: me.id,
            },
          },
          data: { lastReadAt: created.createdAt },
        }),
      ])

      return created
    })

    await Promise.all(
      conversation.participants
        .filter((participant) => participant.playerId !== me.id)
        .map((participant) =>
          this.notificationService.createNotification(participant.player.userId, {
            type: 'CHAT_MESSAGE',
            title: message.sender.user.name ?? 'New message',
            body: trimmed.slice(0, 140),
            entityType: 'CHAT_CONVERSATION',
            entityId: conversationId,
            data: {
              conversationId,
              senderPlayerId: me.id,
            },
            preferenceKey: 'chatMessages',
          }),
        ),
    )

    return {
      id: message.id,
      kind: message.kind,
      body: message.body,
      attachmentUrl: message.attachmentUrl,
      createdAt: message.createdAt,
      sender: {
        id: message.sender.id,
        fullName: message.sender.user.name ?? 'Swing Player',
        username: message.sender.username,
        avatarUrl: message.sender.user.avatarUrl,
      },
    }
  }

  async markConversationRead(userId: string, conversationId: string) {
    const me = await this.getRequiredProfile(userId)
    await prisma.chatConversationParticipant.update({
      where: {
        conversationId_playerId: {
          conversationId,
          playerId: me.id,
        },
      },
      data: { lastReadAt: new Date() },
    }).catch(() => {
      throw Errors.notFound('Conversation')
    })

    return { read: true }
  }

  // ── Team chat ────────────────────────────────────────────────────────────────

  async getOrCreateTeamChat(userId: string, teamId: string) {
    const me = await this.getRequiredProfile(userId)

    const team = await prisma.team.findUnique({ where: { id: teamId } })
    if (!team) throw Errors.notFound('Team')

    // Only team members can access team chat
    if (!team.playerIds.includes(me.id) && team.captainId !== me.id) {
      throw new AppError('FORBIDDEN', 'You are not a member of this team', 403)
    }

    const existing = await prisma.chatConversation.findUnique({
      where: { teamId },
      include: { participants: { include: { player: { include: { user: { select: { name: true, avatarUrl: true } } } } } } },
    })

    if (existing) {
      // Auto-add new team members who aren't participants yet
      const participantIds = new Set(existing.participants.map(p => p.playerId))
      const allMemberIds = [...new Set([...team.playerIds, team.captainId].filter(Boolean))] as string[]
      const newMembers = allMemberIds.filter(id => !participantIds.has(id))
      if (newMembers.length > 0) {
        await prisma.chatConversationParticipant.createMany({
          data: newMembers.map(playerId => ({ conversationId: existing.id, playerId })),
          skipDuplicates: true,
        })
      }
      return { id: existing.id, type: existing.type, teamId, title: team.name, avatarUrl: team.logoUrl }
    }

    // Create team chat and add all members
    const allMemberIds = [...new Set([...team.playerIds, team.captainId].filter(Boolean))] as string[]
    const created = await prisma.chatConversation.create({
      data: {
        type: 'TEAM_CHAT',
        teamId,
        title: team.name,
        avatarUrl: team.logoUrl,
        createdByPlayerId: me.id,
        participants: {
          create: allMemberIds.map(playerId => ({ playerId, lastReadAt: playerId === me.id ? new Date() : undefined })),
        },
      },
    })

    return { id: created.id, type: created.type, teamId, title: team.name, avatarUrl: team.logoUrl }
  }

  async leaveTeamChat(userId: string, teamId: string) {
    const me = await this.getRequiredProfile(userId)
    const convo = await prisma.chatConversation.findUnique({ where: { teamId }, select: { id: true } })
    if (!convo) throw Errors.notFound('Team chat')

    await prisma.chatConversationParticipant.deleteMany({
      where: { conversationId: convo.id, playerId: me.id },
    })
    return { left: true }
  }
}
