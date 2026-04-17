import {
  AdSlotType,
  prisma,
  Prisma,
  SceneType,
  TriggerEventType,
} from '@swing/db'
import { AppError, Errors } from '../../lib/errors'
import { redis } from '../../lib/redis'
import {
  DEFAULT_TEMPLATE_ID,
  getTemplate,
  listTemplates,
} from './studio.templates'

const DEFAULT_OVER_BREAK_SECONDS = 6
const STUDIO_SCENE_CHANNEL_PREFIX = 'studio'
const SCHEDULED_SWITCH_FLUSH_INTERVAL_MS = 10_000
const SCHEDULED_SWITCH_BATCH_SIZE = 50
let scheduledSwitchFlusher: NodeJS.Timeout | null = null

type JsonObject = Record<string, unknown>

type StudioScenePayload = {
  active: true
  sceneType: SceneType
  templateId: string
  data: JsonObject
  adSlot: JsonObject | null
}

export class StudioService {
  static startScheduledSceneSwitchFlusher(
    logger: Pick<Console, 'info' | 'error'> = console,
  ) {
    if (scheduledSwitchFlusher) return

    const service = new StudioService()
    scheduledSwitchFlusher = setInterval(() => {
      void service.flushScheduledSceneSwitches().catch((error) => {
        logger.error('[studio] scheduled scene switch flush failed', error)
      })
    }, SCHEDULED_SWITCH_FLUSH_INTERVAL_MS)
    scheduledSwitchFlusher.unref?.()
    logger.info(
      `[studio] scheduled scene switch flusher started (${SCHEDULED_SWITCH_FLUSH_INTERVAL_MS}ms)`,
    )
  }

  listTemplates() {
    return listTemplates()
  }

  async initStudio(matchId: string) {
    const existing = await prisma.overlayStudio.findUnique({
      where: { matchId },
    })
    if (existing) return this.getStudio(matchId)

    const match = await prisma.match.findUnique({
      where: { id: matchId },
      select: { id: true, status: true },
    })
    if (!match) throw Errors.notFound('Match')

    await prisma.$transaction(async (tx) => {
      const studio = await tx.overlayStudio.create({
        data: { matchId },
      })

      const defaults = [
        { name: 'Pre-Match', sceneType: SceneType.PRE_MATCH, displayOrder: 0 },
        { name: 'Live Score', sceneType: SceneType.LIVE_SCORE, displayOrder: 1 },
        { name: 'Over Break', sceneType: SceneType.OVER_BREAK, displayOrder: 2 },
        { name: 'Ad Break', sceneType: SceneType.AD_BREAK, displayOrder: 3 },
        {
          name: 'Innings Break',
          sceneType: SceneType.INNINGS_BREAK,
          displayOrder: 4,
        },
        { name: 'Post Match', sceneType: SceneType.POST_MATCH, displayOrder: 5 },
      ] as const

      const createdScenes = await Promise.all(
        defaults.map((scene) =>
          tx.overlayScene.create({
            data: {
              studioId: studio.id,
              name: scene.name,
              sceneType: scene.sceneType,
              templateId: DEFAULT_TEMPLATE_ID,
              isAutomatic: true,
              displayOrder: scene.displayOrder,
            },
          }),
        ),
      )

      const byType = new Map(createdScenes.map((scene) => [scene.sceneType, scene]))
      await tx.overlayTrigger.createMany({
        data: [
          {
            studioId: studio.id,
            eventType: TriggerEventType.MATCH_STARTED,
            targetSceneId: byType.get(SceneType.LIVE_SCORE)!.id,
            delaySeconds: 0,
            isEnabled: true,
          },
          {
            studioId: studio.id,
            eventType: TriggerEventType.TOSS_DONE,
            targetSceneId: byType.get(SceneType.PRE_MATCH)!.id,
            delaySeconds: 0,
            isEnabled: true,
          },
          {
            studioId: studio.id,
            eventType: TriggerEventType.OVER_COMPLETED,
            targetSceneId: byType.get(SceneType.OVER_BREAK)!.id,
            delaySeconds: 0,
            isEnabled: true,
          },
          {
            studioId: studio.id,
            eventType: TriggerEventType.INNINGS_COMPLETED,
            targetSceneId: byType.get(SceneType.INNINGS_BREAK)!.id,
            delaySeconds: 0,
            isEnabled: true,
          },
          {
            studioId: studio.id,
            eventType: TriggerEventType.MATCH_COMPLETED,
            targetSceneId: byType.get(SceneType.POST_MATCH)!.id,
            delaySeconds: 0,
            isEnabled: true,
          },
        ],
      })

      const initialSceneType =
        match.status === 'COMPLETED'
          ? SceneType.POST_MATCH
          : match.status === 'IN_PROGRESS'
            ? SceneType.LIVE_SCORE
            : SceneType.PRE_MATCH

      await tx.overlayStudio.update({
        where: { id: studio.id },
        data: { activeSceneId: byType.get(initialSceneType)?.id ?? null },
      })
    })

    return this.getStudio(matchId)
  }

  async getStudio(matchId: string) {
    const studio = await this.getStudioRecordOrThrow(matchId)

    return {
      id: studio.id,
      matchId: studio.matchId,
      activeSceneId: studio.activeSceneId,
      adBreakEnabled: studio.adBreakEnabled,
      adBreakDurationSeconds: studio.adBreakDurationSeconds,
      createdAt: studio.createdAt,
      updatedAt: studio.updatedAt,
      scenes: studio.scenes,
      triggers: studio.triggers,
      adSlots: this.sortAdSlots(studio),
      templates: this.listTemplates(),
      current: await this.resolveStudioCurrent(studio),
    }
  }

  async setActiveScene(matchId: string, sceneId: string | null) {
    const studio = await this.getStudioRecordOrThrow(matchId)
    if (sceneId) {
      const exists = studio.scenes.some((scene) => scene.id === sceneId)
      if (!exists) throw Errors.notFound('Studio scene')
    }

    await this.clearPendingSceneSwitches(studio.id)

    const updated = await prisma.overlayStudio.update({
      where: { id: studio.id },
      data: { activeSceneId: sceneId },
      include: this.studioInclude,
    })

    await this.publishSceneChanged(matchId, sceneId)

    return {
      activeSceneId: updated.activeSceneId,
      current: await this.resolveStudioCurrent(updated),
    }
  }

  async getCurrent(matchId: string) {
    const studio = await prisma.overlayStudio.findUnique({
      where: { matchId },
      include: this.studioInclude,
    })

    if (!studio || !studio.activeSceneId) {
      return { active: false as const }
    }

    return this.resolveStudioCurrent(studio)
  }

  async createScene(
    matchId: string,
    input: {
      name: string
      sceneType: SceneType
      templateId: string
      dataOverrides?: JsonObject
      isAutomatic?: boolean
      displayOrder?: number
    },
  ) {
    const studio = await this.getStudioRecordOrThrow(matchId)
    this.assertTemplate(input.templateId, input.sceneType)

    const maxOrder = studio.scenes.reduce((max, scene) => Math.max(max, scene.displayOrder), -1)
    const scene = await prisma.overlayScene.create({
      data: {
        studioId: studio.id,
        name: input.name,
        sceneType: input.sceneType,
        templateId: input.templateId,
        dataOverrides: this.toJsonObject(input.dataOverrides),
        isAutomatic: input.isAutomatic ?? false,
        displayOrder: input.displayOrder ?? maxOrder + 1,
      },
    })

    return scene
  }

  async updateScene(
    matchId: string,
    sceneId: string,
    input: {
      name?: string
      templateId?: string
      dataOverrides?: JsonObject
      displayOrder?: number
      isAutomatic?: boolean
    },
  ) {
    const studio = await this.getStudioRecordOrThrow(matchId)
    const scene = studio.scenes.find((item) => item.id === sceneId)
    if (!scene) throw Errors.notFound('Studio scene')

    const templateId = input.templateId ?? scene.templateId
    this.assertTemplate(templateId, scene.sceneType)

    return prisma.overlayScene.update({
      where: { id: sceneId },
      data: {
        name: input.name,
        templateId,
        dataOverrides:
          input.dataOverrides !== undefined
            ? this.toJsonObject(input.dataOverrides)
            : undefined,
        displayOrder: input.displayOrder,
        isAutomatic: input.isAutomatic,
      },
    })
  }

  async deleteScene(matchId: string, sceneId: string) {
    const studio = await this.getStudioRecordOrThrow(matchId)
    if (studio.activeSceneId === sceneId) {
      throw new AppError('ACTIVE_SCENE', 'Cannot delete the active scene', 400)
    }

    const scene = studio.scenes.find((item) => item.id === sceneId)
    if (!scene) throw Errors.notFound('Studio scene')

    await prisma.overlayScene.delete({ where: { id: sceneId } })
    return { deleted: sceneId }
  }

  async createTrigger(
    matchId: string,
    input: {
      eventType: TriggerEventType
      targetSceneId: string
      delaySeconds?: number
      isEnabled?: boolean
    },
  ) {
    const studio = await this.getStudioRecordOrThrow(matchId)
    this.assertSceneBelongsToStudio(studio, input.targetSceneId)

    return prisma.overlayTrigger.create({
      data: {
        studioId: studio.id,
        eventType: input.eventType,
        targetSceneId: input.targetSceneId,
        delaySeconds: input.delaySeconds ?? 0,
        isEnabled: input.isEnabled ?? true,
      },
    })
  }

  async updateTrigger(
    matchId: string,
    triggerId: string,
    input: {
      eventType?: TriggerEventType
      targetSceneId?: string
      delaySeconds?: number
      isEnabled?: boolean
    },
  ) {
    const studio = await this.getStudioRecordOrThrow(matchId)
    const trigger = studio.triggers.find((item) => item.id === triggerId)
    if (!trigger) throw Errors.notFound('Studio trigger')

    if (input.targetSceneId) this.assertSceneBelongsToStudio(studio, input.targetSceneId)

    return prisma.overlayTrigger.update({
      where: { id: triggerId },
      data: {
        eventType: input.eventType,
        targetSceneId: input.targetSceneId,
        delaySeconds: input.delaySeconds,
        isEnabled: input.isEnabled,
      },
    })
  }

  async deleteTrigger(matchId: string, triggerId: string) {
    const studio = await this.getStudioRecordOrThrow(matchId)
    const trigger = studio.triggers.find((item) => item.id === triggerId)
    if (!trigger) throw Errors.notFound('Studio trigger')

    await prisma.overlayTrigger.delete({ where: { id: triggerId } })
    return { deleted: triggerId }
  }

  async createAd(
    matchId: string,
    input: {
      type: AdSlotType
      title: string
      mediaUrl?: string | null
      brandName?: string | null
      brandLogoUrl?: string | null
      durationSeconds: number
    },
  ) {
    const studio = await this.getStudioRecordOrThrow(matchId)
    const maxOrder = studio.adQueue.reduce((max, item) => Math.max(max, item.displayOrder), -1)
    const nextOrder = maxOrder + 1

    const ad = await prisma.adSlot.create({
      data: {
        studioId: studio.id,
        type: input.type,
        title: input.title,
        mediaUrl: input.mediaUrl ?? null,
        brandName: input.brandName ?? null,
        brandLogoUrl: input.brandLogoUrl ?? null,
        durationSeconds: input.durationSeconds,
        displayOrder: nextOrder,
      },
    })

    await prisma.studioAdQueue.create({
      data: {
        studioId: studio.id,
        adSlotId: ad.id,
        displayOrder: nextOrder,
      },
    })

    return ad
  }

  async updateAd(
    matchId: string,
    adId: string,
    input: {
      type?: AdSlotType
      title?: string
      mediaUrl?: string | null
      brandName?: string | null
      brandLogoUrl?: string | null
      durationSeconds?: number
      adBreakEnabled?: boolean
    },
  ) {
    const studio = await this.getStudioRecordOrThrow(matchId)
    const ad = studio.adSlots.find((item) => item.id === adId)
    if (!ad) throw Errors.notFound('Ad slot')

    if (input.adBreakEnabled !== undefined) {
      await prisma.overlayStudio.update({
        where: { id: studio.id },
        data: { adBreakEnabled: input.adBreakEnabled },
      })
    }

    return prisma.adSlot.update({
      where: { id: adId },
      data: {
        type: input.type,
        title: input.title,
        mediaUrl: input.mediaUrl,
        brandName: input.brandName,
        brandLogoUrl: input.brandLogoUrl,
        durationSeconds: input.durationSeconds,
      },
    })
  }

  async deleteAd(matchId: string, adId: string) {
    const studio = await this.getStudioRecordOrThrow(matchId)
    const ad = studio.adSlots.find((item) => item.id === adId)
    if (!ad) throw Errors.notFound('Ad slot')

    await prisma.adSlot.delete({ where: { id: adId } })
    return { deleted: adId }
  }

  async reorderAds(matchId: string, orderedIds: string[]) {
    const studio = await this.getStudioRecordOrThrow(matchId)
    const currentIds = this.sortAdSlots(studio).map((item) => item.id)

    if (
      orderedIds.length !== currentIds.length ||
      orderedIds.some((id) => !currentIds.includes(id))
    ) {
      throw new AppError('INVALID_ORDER', 'Ordered IDs must match the current ad list', 400)
    }

    await prisma.$transaction(
      orderedIds.flatMap((adId, index) => {
        const queueItem = studio.adQueue.find((item) => item.adSlotId === adId)
        if (!queueItem) {
          throw new AppError('INVALID_ORDER', 'Missing queue entry for ad slot', 400)
        }

        return [
          prisma.adSlot.update({
            where: { id: adId },
            data: { displayOrder: index },
          }),
          prisma.studioAdQueue.update({
            where: { id: queueItem.id },
            data: { displayOrder: index },
          }),
        ]
      }),
    )

    return { orderedIds }
  }

  async updateStudioSettings(
    matchId: string,
    input: { adBreakEnabled?: boolean; adBreakDurationSeconds?: number },
  ) {
    const studio = await this.getStudioRecordOrThrow(matchId)
    return prisma.overlayStudio.update({
      where: { id: studio.id },
      data: {
        adBreakEnabled: input.adBreakEnabled,
        adBreakDurationSeconds: input.adBreakDurationSeconds,
      },
    })
  }

  async triggerEvent(matchId: string, eventType: TriggerEventType) {
    const studio = await prisma.overlayStudio.findUnique({
      where: { matchId },
      include: this.studioInclude,
    })

    if (!studio) return null

    await this.clearPendingSceneSwitches(studio.id)

    const matchingTriggers = studio.triggers
      .filter((trigger) => trigger.isEnabled && trigger.eventType === eventType)
      .sort((a, b) => a.delaySeconds - b.delaySeconds)

    await Promise.all(
      matchingTriggers.map((trigger) =>
        this.scheduleSceneSwitch(studio.id, studio.matchId, trigger.targetSceneId, trigger.delaySeconds),
      ),
    )

    if (eventType === TriggerEventType.OVER_COMPLETED) {
      await this.scheduleOverCompletionFlow(studio, matchingTriggers)
    }

    return { eventType, triggerCount: matchingTriggers.length }
  }

  private async scheduleOverCompletionFlow(
    studio: Awaited<ReturnType<StudioService['getStudioRecordOrThrow']>>,
    matchingTriggers: Array<{ delaySeconds: number }>,
  ) {
    const liveScoreScene = studio.scenes.find((scene) => scene.sceneType === SceneType.LIVE_SCORE)
    if (!liveScoreScene) return

    const triggerDelay = matchingTriggers.length
      ? Math.max(...matchingTriggers.map((trigger) => trigger.delaySeconds))
      : 0
    const overBreakEndsAt = triggerDelay + DEFAULT_OVER_BREAK_SECONDS
    const queue = this.getOrderedQueue(studio)
    const adBreakScene = studio.scenes.find((scene) => scene.sceneType === SceneType.AD_BREAK)

    if (studio.adBreakEnabled && adBreakScene && queue.length > 0) {
      await this.scheduleSceneSwitch(
        studio.id,
        studio.matchId,
        adBreakScene.id,
        overBreakEndsAt,
      )
      await this.scheduleSceneSwitch(
        studio.id,
        studio.matchId,
        liveScoreScene.id,
        overBreakEndsAt + studio.adBreakDurationSeconds,
      )
      return
    }

    await this.scheduleSceneSwitch(
      studio.id,
      studio.matchId,
      liveScoreScene.id,
      overBreakEndsAt,
    )
  }

  async flushScheduledSceneSwitches() {
    const dueSwitches = await prisma.studioScheduledSceneSwitch.findMany({
      where: {
        executedAt: null,
        scheduledAt: { lte: new Date() },
      },
      orderBy: { scheduledAt: 'asc' },
      take: SCHEDULED_SWITCH_BATCH_SIZE,
      include: {
        studio: { select: { matchId: true } },
      },
    })

    for (const scheduledSwitch of dueSwitches) {
      const claimed = await prisma.studioScheduledSceneSwitch.updateMany({
        where: {
          id: scheduledSwitch.id,
          executedAt: null,
        },
        data: {
          executedAt: new Date(),
        },
      })

      if (claimed.count === 0) continue

      await this.applySceneSwitch(
        scheduledSwitch.studio.matchId,
        scheduledSwitch.targetSceneId,
      )
    }
  }

  private async scheduleSceneSwitch(
    studioId: string,
    matchId: string,
    sceneId: string,
    delaySeconds: number,
  ) {
    if (delaySeconds <= 0) {
      await this.applySceneSwitch(matchId, sceneId)
      return
    }

    await prisma.studioScheduledSceneSwitch.create({
      data: {
        studioId,
        targetSceneId: sceneId,
        scheduledAt: new Date(Date.now() + delaySeconds * 1000),
      },
    })
  }

  private async clearPendingSceneSwitches(studioId: string) {
    await prisma.studioScheduledSceneSwitch.deleteMany({
      where: {
        studioId,
        executedAt: null,
      },
    })
  }

  private async applySceneSwitch(matchId: string, sceneId: string) {
    const studio = await prisma.overlayStudio.findUnique({
      where: { matchId },
      include: {
        scenes: { select: { id: true } },
      },
    })
    if (!studio) return
    if (!studio.scenes.some((scene) => scene.id === sceneId)) return

    await prisma.overlayStudio.update({
      where: { id: studio.id },
      data: { activeSceneId: sceneId },
    })

    await this.publishSceneChanged(matchId, sceneId)
  }

  private async publishSceneChanged(matchId: string, sceneId: string | null) {
    const channel = `${STUDIO_SCENE_CHANNEL_PREFIX}:${matchId}:scene-changed`
    await redis.publish(
      channel,
      JSON.stringify({
        matchId,
        sceneId,
        changedAt: new Date().toISOString(),
      }),
    )
  }

  private async resolveStudioCurrent(
    studio: Awaited<ReturnType<StudioService['getStudioRecordOrThrow']>>,
  ): Promise<StudioScenePayload | { active: false }> {
    const activeScene = studio.scenes.find((scene) => scene.id === studio.activeSceneId)
    if (!activeScene) return { active: false }

    const template = getTemplate(activeScene.templateId)
    if (!template) return { active: false }

    const liveData = await this.buildLiveMatchData(studio.matchId, activeScene.sceneType, studio)
    const mergedData = this.deepMerge(
      this.deepMerge(template.defaultData, liveData),
      this.fromPrismaJsonObject(activeScene.dataOverrides),
    )

    return {
      active: true,
      sceneType: activeScene.sceneType,
      templateId: activeScene.templateId,
      data: mergedData,
      adSlot: (mergedData.adSlot as JsonObject | null | undefined) ?? null,
    }
  }

  private async buildLiveMatchData(
    matchId: string,
    sceneType: SceneType,
    studio: Awaited<ReturnType<StudioService['getStudioRecordOrThrow']>>,
  ): Promise<JsonObject> {
    const match = await prisma.match.findUnique({
      where: { id: matchId },
      include: {
        innings: {
          orderBy: { inningsNumber: 'asc' },
          include: {
            ballEvents: {
              orderBy: [{ overNumber: 'asc' }, { ballNumber: 'asc' }],
            },
          },
        },
      },
    })
    if (!match) throw Errors.notFound('Match')

    const [teamA, teamB] = await Promise.all([
      this.findTeamMeta(match.teamAName),
      this.findTeamMeta(match.teamBName),
    ])

    const innings = match.innings
    const currentInnings =
      innings.find((item) => !item.isCompleted) ?? innings[innings.length - 1] ?? null
    const lastCompletedInnings =
      [...innings].reverse().find((item) => item.isCompleted) ?? currentInnings
    const inningsForScene =
      sceneType === SceneType.INNINGS_BREAK || sceneType === SceneType.POST_MATCH
        ? lastCompletedInnings
        : currentInnings

    const firstInnings = innings.find((item) => item.inningsNumber === 1) ?? null
    const tossWinner =
      match.tossWonBy === 'A'
        ? match.teamAName
        : match.tossWonBy === 'B'
          ? match.teamBName
          : null

    const overSource = inningsForScene?.ballEvents ?? []
    const overNumber =
      sceneType === SceneType.OVER_BREAK
        ? this.getLastCompletedOverNumber(inningsForScene?.totalOvers ?? 0)
        : overSource[overSource.length - 1]?.overNumber ??
          this.getLastCompletedOverNumber(inningsForScene?.totalOvers ?? 0)

    const lastOverBalls = overNumber
      ? overSource
          .filter((ball) => ball.overNumber === overNumber)
          .map((ball) => ({
            id: ball.id,
            overNumber: ball.overNumber,
            ballNumber: ball.ballNumber,
            outcome: ball.outcome,
            runs: ball.runs,
            extras: ball.extras,
            totalRuns: ball.totalRuns,
            isWicket: ball.isWicket,
            label: this.ballLabel(ball),
          }))
      : []

    const completedOvers = innings.reduce(
      (sum, item) => sum + Math.floor(item.totalOvers),
      0,
    )
    const currentAdSlot =
      sceneType === SceneType.AD_BREAK
        ? this.getCurrentAdSlot(studio, completedOvers)
        : null

    return {
      teamAName: match.teamAName,
      teamALogo: teamA?.logoUrl ?? null,
      teamBName: match.teamBName,
      teamBLogo: teamB?.logoUrl ?? null,
      score: {
        runs: inningsForScene?.totalRuns ?? 0,
        wickets: inningsForScene?.totalWickets ?? 0,
        overs: Number((inningsForScene?.totalOvers ?? 0).toFixed(1)),
      },
      target:
        currentInnings && currentInnings.inningsNumber > 1 && firstInnings
          ? firstInnings.totalRuns + 1
          : null,
      tossWinner,
      tossChoice: match.tossDecision ?? null,
      lastOver: { balls: lastOverBalls },
      overNumber: overNumber ?? 0,
      inningsNumber: inningsForScene?.inningsNumber ?? 1,
      result: this.buildResultText(match),
      adSlot: currentAdSlot,
      status: match.status,
    }
  }

  private buildResultText(match: {
    status: string
    teamAName: string
    teamBName: string
    winnerId: string | null
    winMargin: string | null
  }) {
    if (match.status !== 'COMPLETED') return null

    const winner = String(match.winnerId ?? '').trim().toUpperCase()
    if (winner === 'A') {
      return `${match.teamAName} won${match.winMargin ? ` by ${match.winMargin}` : ''}`
    }
    if (winner === 'B') {
      return `${match.teamBName} won${match.winMargin ? ` by ${match.winMargin}` : ''}`
    }
    if (winner === 'DRAW') return 'Match drawn'
    if (winner === 'TIE') return 'Match tied'
    if (winner === 'ABANDONED' || winner === 'NO_RESULT') return 'No result'
    return match.winMargin ? `Match complete · ${match.winMargin}` : 'Match complete'
  }

  private getCurrentAdSlot(
    studio: Awaited<ReturnType<StudioService['getStudioRecordOrThrow']>>,
    completedOvers: number,
  ) {
    const queue = this.getOrderedQueue(studio)
    if (queue.length === 0) return null

    const index = Math.max(completedOvers - 1, 0) % queue.length
    const ad = queue[index].adSlot
    return {
      id: ad.id,
      type: ad.type,
      title: ad.title,
      mediaUrl: ad.mediaUrl,
      brandName: ad.brandName,
      brandLogoUrl: ad.brandLogoUrl,
      durationSeconds: ad.durationSeconds,
    }
  }

  private getOrderedQueue(studio: Awaited<ReturnType<StudioService['getStudioRecordOrThrow']>>) {
    return [...studio.adQueue].sort((a, b) => a.displayOrder - b.displayOrder)
  }

  private sortAdSlots(studio: Awaited<ReturnType<StudioService['getStudioRecordOrThrow']>>) {
    const orderMap = new Map(
      studio.adQueue.map((item) => [item.adSlotId, item.displayOrder]),
    )

    return [...studio.adSlots].sort(
      (a, b) =>
        (orderMap.get(a.id) ?? a.displayOrder) - (orderMap.get(b.id) ?? b.displayOrder),
    )
  }

  private getLastCompletedOverNumber(totalOvers: number) {
    const rounded = Number(totalOvers.toFixed(1))
    const wholeOvers = Math.floor(rounded)
    const ballsInCurrentOver = Math.round((rounded - wholeOvers) * 10)
    if (ballsInCurrentOver === 0 && wholeOvers > 0) return wholeOvers
    return wholeOvers > 0 ? wholeOvers : null
  }

  private ballLabel(ball: {
    outcome: string
    isWicket: boolean
    runs: number
    extras: number
  }) {
    if (ball.isWicket) return 'W'
    if (ball.outcome === 'WIDE') return 'Wd'
    if (ball.outcome === 'NO_BALL') return 'Nb'
    if (ball.outcome === 'FOUR') return '4'
    if (ball.outcome === 'SIX') return '6'
    const total = ball.runs + ball.extras
    return total === 0 ? '•' : String(total)
  }

  private async findTeamMeta(name: string) {
    const exact = await prisma.team.findFirst({
      where: { name: { equals: name, mode: 'insensitive' } },
      select: { logoUrl: true },
    })
    if (exact) return exact

    return prisma.team.findFirst({
      where: {
        OR: [
          { name: { contains: name, mode: 'insensitive' } },
          { shortName: { contains: name, mode: 'insensitive' } },
        ],
      },
      select: { logoUrl: true },
    })
  }

  private assertTemplate(templateId: string, sceneType: SceneType) {
    const template = getTemplate(templateId)
    if (!template) {
      throw new AppError('INVALID_TEMPLATE', `Unknown template "${templateId}"`, 400)
    }

    if (!template.supportedSceneTypes.includes(sceneType)) {
      throw new AppError(
        'UNSUPPORTED_TEMPLATE_SCENE',
        `Template "${templateId}" does not support ${sceneType}`,
        400,
      )
    }
  }

  private assertSceneBelongsToStudio(
    studio: Awaited<ReturnType<StudioService['getStudioRecordOrThrow']>>,
    sceneId: string,
  ) {
    const exists = studio.scenes.some((scene) => scene.id === sceneId)
    if (!exists) throw Errors.notFound('Studio scene')
  }

  private async getStudioRecordOrThrow(matchId: string) {
    const studio = await prisma.overlayStudio.findUnique({
      where: { matchId },
      include: this.studioInclude,
    })
    if (!studio) throw Errors.notFound('Overlay studio')
    return studio
  }

  private readonly studioInclude = {
    scenes: {
      orderBy: { displayOrder: 'asc' as const },
    },
    triggers: {
      orderBy: [{ eventType: 'asc' as const }, { delaySeconds: 'asc' as const }],
    },
    adSlots: {
      orderBy: { displayOrder: 'asc' as const },
    },
    adQueue: {
      orderBy: { displayOrder: 'asc' as const },
      include: {
        adSlot: true,
      },
    },
  } satisfies Prisma.OverlayStudioInclude

  private toJsonObject(value: JsonObject | undefined): Prisma.InputJsonObject {
    const source = value ?? {}
    return JSON.parse(JSON.stringify(source)) as Prisma.InputJsonObject
  }

  private fromPrismaJsonObject(value: Prisma.JsonValue): JsonObject {
    if (value && typeof value === 'object' && !Array.isArray(value)) {
      return value as JsonObject
    }
    return {}
  }

  private deepMerge(base: Record<string, unknown>, override: Record<string, unknown>): JsonObject {
    const output: JsonObject = { ...base }

    for (const [key, value] of Object.entries(override)) {
      const baseValue = output[key]
      if (
        value &&
        typeof value === 'object' &&
        !Array.isArray(value) &&
        baseValue &&
        typeof baseValue === 'object' &&
        !Array.isArray(baseValue)
      ) {
        output[key] = this.deepMerge(
          baseValue as Record<string, unknown>,
          value as Record<string, unknown>,
        )
        continue
      }

      output[key] = value
    }

    return output
  }
}
