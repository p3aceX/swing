import { prisma } from '@swing/db'
import { Errors, AppError } from '../../lib/errors'
import { nanoid } from 'nanoid'

export class StoreService {
  // --- STORE MANAGEMENT ---
  async createStore(userId: string, data: {
    name: string
    description?: string
    address: string
    city: string
    state: string
    pincode: string
    latitude?: number
    longitude?: number
    academyId?: string
  }) {
    let owner = await prisma.storeOwnerProfile.findUnique({ where: { userId } })
    if (!owner) {
      owner = await prisma.storeOwnerProfile.create({ data: { userId } })
    }

    return prisma.store.create({
      data: {
        ownerId: owner.id,
        ...data,
      },
    })
  }

  async getStore(storeId: string) {
    const store = await prisma.store.findUnique({
      where: { id: storeId },
      include: { owner: { include: { user: true } } },
    })
    if (!store) throw Errors.notFound('Store')
    return store
  }

  // --- CATEGORY & PRODUCT MANAGEMENT ---
  async createCategory(data: { name: string; description?: string; parentId?: string; displayOrder?: number }) {
    return prisma.productCategory.create({ data })
  }

  async listCategories() {
    return prisma.productCategory.findMany({
      where: { isActive: true },
      orderBy: { displayOrder: 'asc' },
    })
  }

  async createProduct(data: {
    categoryId: string
    name: string
    description?: string
    brand?: string
    imageUrl?: string
    variants: Array<{ name: string; sku?: string; attributes?: any; imageUrl?: string }>
  }) {
    return prisma.product.create({
      data: {
        categoryId: data.categoryId,
        name: data.name,
        description: data.description,
        brand: data.brand,
        imageUrl: data.imageUrl,
        variants: {
          create: data.variants,
        },
      },
      include: { variants: true },
    })
  }

  // --- INVENTORY MANAGEMENT ---
  async updateInventory(storeId: string, userId: string, data: {
    productVariantId: string
    quantity: number
    pricePaise: number
    discountPricePaise?: number
    isActive?: boolean
  }) {
    const store = await prisma.store.findFirst({
      where: { id: storeId, owner: { userId } },
    })
    if (!store) throw Errors.forbidden()

    return prisma.storeInventory.upsert({
      where: { storeId_productVariantId: { storeId, productVariantId: data.productVariantId } },
      update: data,
      create: { storeId, ...data },
    })
  }

  async getStoreInventory(storeId: string) {
    return prisma.storeInventory.findMany({
      where: { storeId, isActive: true },
      include: {
        productVariant: {
          include: { product: true },
        },
      },
    })
  }

  // --- CONSUMER SEARCH & DISCOVERY ---
  async searchStores(city: string, lat?: number, lng?: number) {
    // Simple city-based search for now; geo-spatial can be added via raw query if needed
    return prisma.store.findMany({
      where: { city, isActive: true },
    })
  }

  // --- ORDER WORKFLOW ---
  async createOrder(userId: string, data: {
    storeId: string
    items: Array<{ productVariantId: string; quantity: number }>
    deliveryAddress: string
    deliveryLat?: number
    deliveryLng?: number
    notes?: string
  }) {
    const store = await prisma.store.findUnique({ where: { id: data.storeId } })
    if (!store) throw Errors.notFound('Store')

    // 1. Fetch inventory and validate stock
    const variantIds = data.items.map(i => i.productVariantId)
    const inventory = await prisma.storeInventory.findMany({
      where: {
        storeId: data.storeId,
        productVariantId: { in: variantIds },
        isActive: true,
      },
    })

    const orderItemsData: any[] = []
    let totalAmountPaise = 0

    for (const item of data.items) {
      const stock = inventory.find(inv => inv.productVariantId === item.productVariantId)
      if (!stock || stock.quantity < item.quantity) {
        throw new AppError('OUT_OF_STOCK', `Item ${item.productVariantId} is out of stock or insufficient quantity`, 400)
      }

      const price = stock.discountPricePaise ?? stock.pricePaise
      const itemTotal = price * item.quantity
      totalAmountPaise += itemTotal

      orderItemsData.push({
        productVariantId: item.productVariantId,
        quantity: item.quantity,
        pricePaise: price,
        totalPricePaise: itemTotal,
      })
    }

    // 2. Create Order in transaction to ensure atomic stock deduction (basic approach)
    // In a real high-load scenario, we would use a Redis-based lock or more complex PG transaction.
    return prisma.$transaction(async (tx) => {
      // Re-verify and deduct stock
      for (const item of data.items) {
        const update = await tx.storeInventory.updateMany({
          where: {
            storeId: data.storeId,
            productVariantId: item.productVariantId,
            quantity: { gte: item.quantity },
          },
          data: { quantity: { decrement: item.quantity } },
        })
        if (update.count === 0) throw new AppError('STOCK_RACE', 'Stock changed, please try again', 409)
      }

      return tx.storeOrder.create({
        data: {
          userId,
          storeId: data.storeId,
          totalAmountPaise,
          finalAmountPaise: totalAmountPaise, // simplified
          deliveryAddress: data.deliveryAddress,
          deliveryLat: data.deliveryLat,
          deliveryLng: data.deliveryLng,
          notes: data.notes,
          items: {
            create: orderItemsData,
          },
        },
        include: { items: true },
      })
    })
  }

  async updateOrderStatus(orderId: string, userId: string, status: string) {
    const order = await prisma.storeOrder.findUnique({
      where: { id: orderId },
      include: { store: true },
    })
    if (!order) throw Errors.notFound('Order')

    // Auth check: User is either the buyer or the store owner
    const store = await prisma.store.findFirst({
      where: { id: order.storeId, owner: { userId } },
    })
    if (order.userId !== userId && !store) throw Errors.forbidden()

    const updatedOrder = await prisma.storeOrder.update({
      where: { id: orderId },
      data: { status },
    })

    // If order is completed, ensure delivery job status is updated too
    if (status === 'DELIVERED') {
      await prisma.deliveryJob.updateMany({
        where: { orderId },
        data: { status: 'DELIVERED', deliveredAt: new Date() },
      })
    }

    return updatedOrder
  }

  async getOrder(orderId: string, userId: string) {
    const order = await prisma.storeOrder.findUnique({
      where: { id: orderId },
      include: {
        items: { include: { productVariant: { include: { product: true } } } },
        store: true,
        delivery: true,
        invoice: true,
      },
    })
    if (!order) throw Errors.notFound('Order')
    if (order.userId !== userId) {
      const store = await prisma.store.findFirst({ where: { id: order.storeId, owner: { userId } } })
      if (!store) throw Errors.forbidden()
    }
    return order
  }

  // --- DELIVERY MANAGEMENT ---
  async assignDeliveryPartner(orderId: string, partnerId: string) {
    return prisma.deliveryJob.upsert({
      where: { orderId },
      update: { partnerId, status: 'ASSIGNED', assignedAt: new Date() },
      create: { orderId, partnerId, status: 'ASSIGNED', assignedAt: new Date() },
    })
  }

  // --- BILLING & INVOICE ---
  async generateInvoice(orderId: string) {
    const order = await prisma.storeOrder.findUnique({
      where: { id: orderId },
      include: { items: true, store: true },
    })
    if (!order) throw Errors.notFound('Order')

    const invoiceNumber = `INV-${new Date().getFullYear()}-${nanoid(6).toUpperCase()}`
    return prisma.storeInvoice.create({
      data: {
        orderId,
        invoiceNumber,
        // In reality, this would trigger a PDF generation and upload to S3
        invoiceUrl: `https://swing-cdn.com/invoices/${invoiceNumber}.pdf`,
      },
    })
  }
}
