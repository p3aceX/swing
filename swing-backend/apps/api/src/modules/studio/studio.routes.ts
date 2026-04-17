import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { AdSlotType, SceneType, TriggerEventType } from '@swing/db'
import { StudioService } from './studio.service'

const sceneTypes = Object.values(SceneType) as [SceneType, ...SceneType[]]
const triggerEventTypes = Object.values(TriggerEventType) as [
  TriggerEventType,
  ...TriggerEventType[],
]
const adSlotTypes = Object.values(AdSlotType) as [AdSlotType, ...AdSlotType[]]

const jsonObjectSchema = z.record(z.any()).default({})

export async function studioRoutes(app: FastifyInstance) {
  const svc = new StudioService()
  const auth = { onRequest: [(app as any).authenticate] }

  app.get('/templates', auth, async (_request, reply) => {
    return reply.send({ success: true, data: svc.listTemplates() })
  })

  app.post('/:matchId/init', auth, async (request, reply) => {
    const { matchId } = request.params as { matchId: string }
    return reply.code(201).send({ success: true, data: await svc.initStudio(matchId) })
  })

  app.get('/:matchId/current', async (request, reply) => {
    const { matchId } = request.params as { matchId: string }
    return reply.send({ success: true, data: await svc.getCurrent(matchId) })
  })

  app.get('/:matchId', auth, async (request, reply) => {
    const { matchId } = request.params as { matchId: string }
    return reply.send({ success: true, data: await svc.getStudio(matchId) })
  })

  app.patch('/:matchId/active-scene', auth, async (request, reply) => {
    const { matchId } = request.params as { matchId: string }
    const body = z
      .object({
        sceneId: z.string().nullable(),
      })
      .parse(request.body)

    return reply.send({
      success: true,
      data: await svc.setActiveScene(matchId, body.sceneId),
    })
  })

  app.post('/:matchId/scenes', auth, async (request, reply) => {
    const { matchId } = request.params as { matchId: string }
    const body = z
      .object({
        name: z.string().min(1),
        sceneType: z.enum(sceneTypes),
        templateId: z.string().min(1),
        dataOverrides: jsonObjectSchema.optional(),
        isAutomatic: z.boolean().optional(),
        displayOrder: z.number().int().min(0).optional(),
      })
      .parse(request.body)

    return reply.code(201).send({
      success: true,
      data: await svc.createScene(matchId, body),
    })
  })

  app.patch('/:matchId/scenes/:sceneId', auth, async (request, reply) => {
    const { matchId, sceneId } = request.params as { matchId: string; sceneId: string }
    const body = z
      .object({
        name: z.string().min(1).optional(),
        templateId: z.string().min(1).optional(),
        dataOverrides: jsonObjectSchema.optional(),
        displayOrder: z.number().int().min(0).optional(),
        isAutomatic: z.boolean().optional(),
      })
      .parse(request.body)

    return reply.send({
      success: true,
      data: await svc.updateScene(matchId, sceneId, body),
    })
  })

  app.delete('/:matchId/scenes/:sceneId', auth, async (request, reply) => {
    const { matchId, sceneId } = request.params as { matchId: string; sceneId: string }
    return reply.send({
      success: true,
      data: await svc.deleteScene(matchId, sceneId),
    })
  })

  app.post('/:matchId/triggers', auth, async (request, reply) => {
    const { matchId } = request.params as { matchId: string }
    const body = z
      .object({
        eventType: z.enum(triggerEventTypes),
        targetSceneId: z.string().min(1),
        delaySeconds: z.number().int().min(0).default(0),
        isEnabled: z.boolean().default(true),
      })
      .parse(request.body)

    return reply.code(201).send({
      success: true,
      data: await svc.createTrigger(matchId, body),
    })
  })

  app.patch('/:matchId/triggers/:triggerId', auth, async (request, reply) => {
    const { matchId, triggerId } = request.params as {
      matchId: string
      triggerId: string
    }
    const body = z
      .object({
        eventType: z.enum(triggerEventTypes).optional(),
        targetSceneId: z.string().min(1).optional(),
        delaySeconds: z.number().int().min(0).optional(),
        isEnabled: z.boolean().optional(),
      })
      .parse(request.body)

    return reply.send({
      success: true,
      data: await svc.updateTrigger(matchId, triggerId, body),
    })
  })

  app.delete('/:matchId/triggers/:triggerId', auth, async (request, reply) => {
    const { matchId, triggerId } = request.params as {
      matchId: string
      triggerId: string
    }
    return reply.send({
      success: true,
      data: await svc.deleteTrigger(matchId, triggerId),
    })
  })

  app.patch('/:matchId/ads/reorder', auth, async (request, reply) => {
    const { matchId } = request.params as { matchId: string }
    const body = z
      .object({
        orderedIds: z.array(z.string()).default([]),
      })
      .parse(request.body)

    return reply.send({
      success: true,
      data: await svc.reorderAds(matchId, body.orderedIds),
    })
  })

  app.post('/:matchId/ads', auth, async (request, reply) => {
    const { matchId } = request.params as { matchId: string }
    const body = z
      .object({
        type: z.enum(adSlotTypes),
        title: z.string().min(1),
        mediaUrl: z.string().url().nullable().optional(),
        brandName: z.string().nullable().optional(),
        brandLogoUrl: z.string().url().nullable().optional(),
        durationSeconds: z.number().int().min(1),
      })
      .parse(request.body)

    return reply.code(201).send({
      success: true,
      data: await svc.createAd(matchId, body),
    })
  })

  app.patch('/:matchId/ads/:adId', auth, async (request, reply) => {
    const { matchId, adId } = request.params as { matchId: string; adId: string }
    const body = z
      .object({
        type: z.enum(adSlotTypes).optional(),
        title: z.string().min(1).optional(),
        mediaUrl: z.string().url().nullable().optional(),
        brandName: z.string().nullable().optional(),
        brandLogoUrl: z.string().url().nullable().optional(),
        durationSeconds: z.number().int().min(1).optional(),
        adBreakEnabled: z.boolean().optional(),
      })
      .parse(request.body)

    return reply.send({
      success: true,
      data: await svc.updateAd(matchId, adId, body),
    })
  })

  app.delete('/:matchId/ads/:adId', auth, async (request, reply) => {
    const { matchId, adId } = request.params as { matchId: string; adId: string }
    return reply.send({
      success: true,
      data: await svc.deleteAd(matchId, adId),
    })
  })

  app.patch('/:matchId/settings', auth, async (request, reply) => {
    const { matchId } = request.params as { matchId: string }
    const body = z
      .object({
        adBreakEnabled: z.boolean().optional(),
        adBreakDurationSeconds: z.number().int().min(1).optional(),
      })
      .parse(request.body)

    return reply.send({
      success: true,
      data: await svc.updateStudioSettings(matchId, body),
    })
  })

  app.post('/:matchId/trigger-event', auth, async (request, reply) => {
    const { matchId } = request.params as { matchId: string }
    const body = z
      .object({
        eventType: z.enum(triggerEventTypes),
      })
      .parse(request.body)

    return reply.send({
      success: true,
      data: await svc.triggerEvent(matchId, body.eventType),
    })
  })
}
