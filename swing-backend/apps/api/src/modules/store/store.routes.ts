import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { StoreService } from './store.service'

const createStoreSchema = z.object({
  name: z.string().min(2),
  description: z.string().optional(),
  address: z.string().min(5),
  city: z.string().min(2),
  state: z.string().min(2),
  pincode: z.string().length(6),
  latitude: z.number().optional(),
  longitude: z.number().optional(),
  academyId: z.string().optional(),
})

const updateInventorySchema = z.object({
  productVariantId: z.string(),
  quantity: z.number().int().min(0),
  pricePaise: z.number().int().positive(),
  discountPricePaise: z.number().int().positive().optional(),
  isActive: z.boolean().optional(),
})

const createOrderSchema = z.object({
  storeId: z.string(),
  items: z.array(z.object({
    productVariantId: z.string(),
    quantity: z.number().int().positive(),
  })).min(1),
  deliveryAddress: z.string().min(5),
  deliveryLat: z.number().optional(),
  deliveryLng: z.number().optional(),
  notes: z.string().optional(),
})

export async function storeRoutes(app: FastifyInstance) {
  const svc = new StoreService()
  const auth = { onRequest: [(app as any).authenticate] }

  // --- STORE ADMIN ---
  app.post('/', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = createStoreSchema.parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.createStore(user.userId, body) })
  })

  app.put('/:id/inventory', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = updateInventorySchema.parse(request.body)
    return reply.send({ success: true, data: await svc.updateInventory(id, user.userId, body) })
  })

  app.get('/:id/inventory', auth, async (request, reply) => {
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getStoreInventory(id) })
  })

  // --- CONSUMER ---
  app.get('/search', async (request, reply) => {
    const { city, lat, lng } = request.query as any
    return reply.send({ success: true, data: await svc.searchStores(city, Number(lat), Number(lng)) })
  })

  app.get('/:id', async (request, reply) => {
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getStore(id) })
  })

  app.post('/orders', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = createOrderSchema.parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.createOrder(user.userId, body) })
  })

  app.get('/orders/:id', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getOrder(id, user.userId) })
  })

  app.patch('/orders/:id/status', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const { status } = z.object({ status: z.string() }).parse(request.body)
    return reply.send({ success: true, data: await svc.updateOrderStatus(id, user.userId, status) })
  })

  // --- MASTER DATA ---
  app.get('/categories', async (_request, reply) => {
    return reply.send({ success: true, data: await svc.listCategories() })
  })

  app.post('/categories', auth, async (request, reply) => {
    // Ideally restricted to SWING_ADMIN
    return reply.code(201).send({ success: true, data: await svc.createCategory(request.body as any) })
  })

  app.post('/products', auth, async (request, reply) => {
    // Ideally restricted to SWING_ADMIN
    return reply.code(201).send({ success: true, data: await svc.createProduct(request.body as any) })
  })
}
