import { prisma } from '@swing/db'
import { Errors, AppError } from '../../lib/errors'

type ArenaTimeBlockInput = {
  unitId: string
  date?: string
  weekdays: number[]
  startTime: string
  endTime: string
  reason?: string
}

type ArenaTimeBlockFilters = {
  date?: string
  unitId?: string
  recurringOnly?: 'true' | 'false'
}

export class ArenaService {
  async createArena(userId: string, data: any) {
    let owner = await prisma.arenaOwnerProfile.findUnique({ where: { userId } })
    if (!owner) {
      owner = await prisma.arenaOwnerProfile.create({
        data: {
          userId,
          businessName: data.businessName || null,
          gstNumber: data.gstNumber || null,
          panNumber: data.panNumber || null,
        },
      })
      const _user = await prisma.user.findUnique({ where: { id: userId }, select: { roles: true } })
      if (!_user?.roles.includes('ARENA_OWNER' as any)) {
        await prisma.user.update({
          where: { id: userId },
          data: { roles: { push: 'ARENA_OWNER' as any } },
        })
      }
    } else if (data.businessName || data.gstNumber || data.panNumber) {
      await prisma.arenaOwnerProfile.update({
        where: { userId },
        data: {
          ...(data.businessName && { businessName: data.businessName }),
          ...(data.gstNumber && { gstNumber: data.gstNumber }),
          ...(data.panNumber && { panNumber: data.panNumber }),
        },
      })
    }
    return prisma.arena.create({
      data: {
        ownerId: owner.id,
        name: data.name,
        description: data.description,
        address: data.address || data.addressLine1 || '',
        city: data.city,
        state: data.state,
        pincode: data.pincode || '',
        latitude: data.latitude || 0,
        longitude: data.longitude || 0,
        phone: data.phone || null,
        sports: data.sports || ['CRICKET'],
        photoUrls: data.photoUrls && data.photoUrls.length > 0 ? data.photoUrls : [],
        isActive: true,
      },
    })
  }

  async addManager(arenaId: string, ownerId: string, data: { name: string; phone: string }) {
    await this.verifyOwner(arenaId, ownerId)

    const { normalizePhone } = await import('@swing/utils')
    const phone = normalizePhone(data.phone)

    let managerUser = await prisma.user.findUnique({ where: { phone } })
    if (!managerUser) {
      managerUser = await prisma.user.create({
        data: {
          phone,
          name: data.name,
          roles: ['ARENA_MANAGER' as any],
          activeRole: 'ARENA_MANAGER' as any,
        },
      })
    } else if (!managerUser.roles.includes('ARENA_MANAGER' as any)) {
      await prisma.user.update({
        where: { id: managerUser.id },
        data: { roles: { push: 'ARENA_MANAGER' as any } },
      })
    }

    return prisma.arenaManager.upsert({
      where: { arenaId_userId: { arenaId, userId: managerUser.id } },
      update: { name: data.name, isActive: true },
      create: {
        arenaId,
        userId: managerUser.id,
        name: data.name,
        phone,
      },
    })
  }

  async listArenas(filters: {
    city?: string
    search?: string
    lat?: number
    lng?: number
    radiusKm?: number
    sport?: string
    page: number
    limit: number
  }) {
    const conditions: any[] = [{ isActive: true }]

    // For now, allow unverified arenas to show up in public listing 
    // to accommodate new entries and testing. 
    // In strict production, we'd add conditions.push({ isVerified: true })
    // conditions.push({ isVerified: true }) 

    if (filters.search) {
      conditions.push({
        OR: [
          { name: { contains: filters.search, mode: 'insensitive' } },
          { city: { contains: filters.search, mode: 'insensitive' } },
          { address: { contains: filters.search, mode: 'insensitive' } },
        ],
      })
    } else if (filters.city) {
      conditions.push({ city: { contains: filters.city, mode: 'insensitive' } })
    }

    if (filters.sport) {
      // Treat null or empty sports array as "all sports" or matching if explicitly requested.
      // Note: We use 'as any' for null check because Prisma schema defines sports as non-nullable,
      // but the database might contain NULLs which cause mapping errors.
      conditions.push({
        OR: [
          { sports: { has: filters.sport as any } },
          { sports: { equals: [] } },
          { sports: { equals: null as any } },
        ],
      })
    }

    const where = { AND: conditions }

    // If radius filtering is requested, we can't easily paginate in DB because 
    // we don't have Haversine support in Prisma. We fetch more results and filter in memory.
    // For small sets (e.g. within a city), we can fetch all.
    const isRadiusSearch = !!(filters.lat && filters.lng && filters.radiusKm)

    const [arenas, total] = await prisma.$transaction([
      prisma.arena.findMany({
        where,
        include: { units: { where: { isActive: true } } },
        // Skip DB pagination if we need to filter/sort by distance in memory
        ...(isRadiusSearch ? {} : {
          skip: (filters.page - 1) * filters.limit,
          take: filters.limit,
        }),
        orderBy: { name: 'asc' },
      }),
      prisma.arena.count({ where }),
    ])

    let results = arenas
    let finalTotal = total
    if (isRadiusSearch) {
      results = arenas
        .filter(a => {
          const dist = this.haversineKm(filters.lat!, filters.lng!, a.latitude, a.longitude)
          return dist <= filters.radiusKm!
        })
        .sort((a, b) => {
          const dA = this.haversineKm(filters.lat!, filters.lng!, a.latitude, a.longitude)
          const dB = this.haversineKm(filters.lat!, filters.lng!, b.latitude, b.longitude)
          return dA - dB
        })
      
      finalTotal = results.length
      // Apply pagination manually after radius filtering
      results = results.slice((filters.page - 1) * filters.limit, filters.page * filters.limit)
    }

    return { arenas: results, total: finalTotal, page: filters.page, limit: filters.limit }
  }

  async listOwnedArenas(userId: string) {
    const [owner, businessAccount, managedArenaRows] = await Promise.all([
      prisma.arenaOwnerProfile.findUnique({ where: { userId }, select: { id: true } }),
      prisma.businessAccount.findUnique({ where: { userId }, select: { id: true } }),
      prisma.arenaManager.findMany({
        where: { userId, isActive: true },
        select: { arenaId: true },
      }),
    ])

    const managedArenaIds = managedArenaRows.map((row) => row.arenaId)
    if (!owner && !businessAccount && managedArenaIds.length === 0) return []

    return prisma.arena.findMany({
      where: {
        OR: [
          ...(owner ? [{ ownerId: owner.id }] : []),
          ...(businessAccount ? [{ businessAccountId: businessAccount.id }] : []),
          ...(managedArenaIds.length > 0 ? [{ id: { in: managedArenaIds } }] : []),
        ],
      },
      include: {
        units: {
          where: { isActive: true },
          orderBy: { name: 'asc' },
          include: { addons: { where: { isAvailable: true }, orderBy: { name: 'asc' } } },
        },
      },
      orderBy: { createdAt: 'desc' },
    })
  }

  async getArena(arenaId: string) {
    const arena = await prisma.arena.findUnique({
      where: { id: arenaId },
      include: {
        units: {
          where: { isActive: true },
          orderBy: { name: 'asc' },
          include: { addons: { where: { isAvailable: true }, orderBy: { name: 'asc' } } },
        },
        owner: { include: { user: { select: { name: true, phone: true } } } },
      },
    })
    if (!arena) throw Errors.notFound('Arena')
    return arena
  }

  async updateArena(arenaId: string, userId: string, data: any) {
    await this.verifyOwner(arenaId, userId)
    const allowed: any = {}
    const fields = [
      'name', 'description', 'phone', 'address', 'city', 'state', 'pincode',
      'latitude', 'longitude', 'photoUrls', 'sports',
      'hasParking', 'hasLights', 'hasWashrooms', 'hasCanteen', 'hasCCTV', 'hasScorer',
      'openTime', 'closeTime', 'operatingDays',
      'advanceBookingDays', 'bufferMins', 'cancellationHours', 'isActive',
    ]
    for (const f of fields) {
      if (f in data) allowed[f] = data[f]
    }
    return prisma.arena.update({ where: { id: arenaId }, data: allowed })
  }

  async addUnit(arenaId: string, userId: string, data: any) {
    await this.verifyOwner(arenaId, userId)
    return prisma.arenaUnit.create({
      data: {
        arenaId,
        name: data.name,
        unitType: data.unitType,
        unitTypeLabel: data.unitTypeLabel || null,
        netType: data.netType || null,
        sport: data.sport || 'CRICKET',
        description: data.description || null,
        photoUrls: (data.photoUrls || []).slice(0, 3),
        pricePerHourPaise: data.pricePerHourPaise,
        peakPricePaise: data.peakPricePaise || null,
        peakHoursStart: data.peakHoursStart || null,
        peakHoursEnd: data.peakHoursEnd || null,
        price4HrPaise: data.price4HrPaise || null,
        price8HrPaise: data.price8HrPaise || null,
        priceFullDayPaise: data.priceFullDayPaise || null,
        weekendMultiplier: data.weekendMultiplier ?? 1.0,
        minSlotMins: data.minSlotMins ?? 60,
        maxSlotMins: data.maxSlotMins ?? 240,
        slotIncrementMins: data.slotIncrementMins ?? 60,
        boundarySize: data.boundarySize ? Number(data.boundarySize) : null,
        openTime: data.openTime || null,
        closeTime: data.closeTime || null,
        operatingDays: data.operatingDays || [],
        hasFloodlights: data.hasFloodlights ?? false,
        isActive: true,
      },
    })
  }

  async updateUnit(unitId: string, userId: string, data: any) {
    const unit = await prisma.arenaUnit.findUnique({ where: { id: unitId } })
    if (!unit) throw Errors.notFound('Unit')
    await this.verifyOwner(unit.arenaId, userId)

    const allowed: any = {}
    const fields = [
      'name', 'description', 'unitType', 'unitTypeLabel', 'netType', 'sport', 'photoUrls', 'pricePerHourPaise', 'peakPricePaise',
      'peakHoursStart', 'peakHoursEnd', 'price4HrPaise', 'price8HrPaise', 'priceFullDayPaise',
      'weekendMultiplier', 'minSlotMins', 'maxSlotMins', 'slotIncrementMins',
      'boundarySize', 'openTime', 'closeTime', 'operatingDays', 'hasFloodlights', 'isActive',
    ]
    for (const f of fields) {
      if (f in data) allowed[f] = data[f] === '' ? null : data[f]
    }
    if ('boundarySize' in allowed && allowed.boundarySize !== null) {
      allowed.boundarySize = Number(allowed.boundarySize)
    }
    if ('photoUrls' in allowed && Array.isArray(allowed.photoUrls)) {
      allowed.photoUrls = allowed.photoUrls.slice(0, 3)
    }
    return prisma.arenaUnit.update({ where: { id: unitId }, data: allowed })
  }

  async listAddons(arenaId: string, userId: string, unitId?: string) {
    await this.verifyOwner(arenaId, userId)
    return prisma.arenaAddon.findMany({
      where: {
        arenaId,
        ...(unitId ? { unitId } : {}),
        isAvailable: true,
      },
      orderBy: { name: 'asc' },
    })
  }

  async createAddon(arenaId: string, userId: string, data: any) {
    await this.verifyOwner(arenaId, userId)
    if (data.unitId) {
      const unit = await prisma.arenaUnit.findFirst({
        where: { id: data.unitId, arenaId, isActive: true },
      })
      if (!unit) throw Errors.notFound('Arena unit')
    }
    return prisma.arenaAddon.create({
      data: {
        arenaId,
        unitId: data.unitId || null,
        name: data.name,
        addonType: data.addonType || null,
        description: data.description || null,
        pricePaise: data.pricePaise,
        unit: data.unit || 'per_session',
        isAvailable: data.isAvailable ?? true,
      },
    })
  }

  async updateAddon(addonId: string, userId: string, data: any) {
    const addon = await prisma.arenaAddon.findUnique({ where: { id: addonId } })
    if (!addon) throw Errors.notFound('Addon')
    await this.verifyOwner(addon.arenaId, userId)
    if (data.unitId) {
      const unit = await prisma.arenaUnit.findFirst({
        where: { id: data.unitId, arenaId: addon.arenaId, isActive: true },
      })
      if (!unit) throw Errors.notFound('Arena unit')
    }
    const allowed: any = {}
    const fields = ['unitId', 'name', 'addonType', 'description', 'pricePaise', 'unit', 'isAvailable']
    for (const f of fields) {
      if (f in data) allowed[f] = data[f] === '' ? null : data[f]
    }
    return prisma.arenaAddon.update({ where: { id: addonId }, data: allowed })
  }

  async deleteAddon(addonId: string, userId: string) {
    const addon = await prisma.arenaAddon.findUnique({ where: { id: addonId } })
    if (!addon) throw Errors.notFound('Addon')
    await this.verifyOwner(addon.arenaId, userId)
    return prisma.arenaAddon.update({
      where: { id: addonId },
      data: { isAvailable: false },
    })
  }

  async deleteUnit(unitId: string, userId: string) {
    const unit = await prisma.arenaUnit.findUnique({ where: { id: unitId } })
    if (!unit) throw Errors.notFound('Unit')
    await this.verifyOwner(unit.arenaId, userId)

    return prisma.arenaUnit.update({
      where: { id: unitId },
      data: { isActive: false },
    })
  }

  async listTimeBlocks(arenaId: string, userId: string, filters: ArenaTimeBlockFilters) {
    await this.verifyOwner(arenaId, userId)

    const where: any = { arenaId }
    if (filters.unitId) where.unitId = filters.unitId

    if (filters.date) {
      const targetDate = this.startOfDay(filters.date)
      const weekday = this.weekdayNumber(targetDate)
      if (filters.recurringOnly === 'true') {
        where.isRecurring = true
        where.weekdays = { has: weekday }
      } else {
        where.OR = [
          { date: targetDate },
          { isRecurring: true, weekdays: { has: weekday } },
        ]
      }
    } else if (filters.recurringOnly === 'true') {
      where.isRecurring = true
    }

    return prisma.arenaTimeBlock.findMany({
      where,
      include: {
        unit: { select: { id: true, name: true } },
      },
      orderBy: [
        { isRecurring: 'desc' },
        { date: 'asc' },
        { startTime: 'asc' },
      ],
    })
  }

  async createTimeBlock(arenaId: string, userId: string, data: ArenaTimeBlockInput) {
    const arena = await this.verifyOwner(arenaId, userId)
    const unit = await prisma.arenaUnit.findFirst({
      where: {
        id: data.unitId,
        arenaId,
        isActive: true,
      },
    })
    if (!unit) throw Errors.notFound('Arena unit')

    const effectiveOpen = (unit as any)?.openTime || arena.openTime
    const effectiveClose = (unit as any)?.closeTime || arena.closeTime
    if (!this.isRangeWithinArenaHours(effectiveOpen, effectiveClose, data.startTime, data.endTime)) {
      throw new AppError('INVALID_BLOCK_TIME', 'Block must be within arena operating hours', 400)
    }

    const weekdays = [...new Set(data.weekdays || [])].sort((a, b) => a - b)
    const isRecurring = weekdays.length > 0
    const blockDate = data.date ? this.startOfDay(data.date) : null

    if (!isRecurring && !blockDate) {
      throw new AppError('INVALID_BLOCK_DATE', 'A one-time block requires a date', 400)
    }

    if (!isRecurring && blockDate && !arena.operatingDays.includes(this.weekdayNumber(blockDate))) {
      throw new AppError('ARENA_CLOSED', 'Selected date is outside the arena operating days', 400)
    }

    if (!isRecurring && blockDate) {
      await this.assertNoConfirmedBookingConflict(arenaId, unit.id, blockDate, data.startTime, data.endTime)
    }
    await this.assertNoTimeBlockConflict(arenaId, unit.id, blockDate, weekdays, data.startTime, data.endTime)

    return prisma.arenaTimeBlock.create({
      data: {
        arenaId,
        unitId: unit.id,
        date: blockDate,
        startTime: data.startTime,
        endTime: data.endTime,
        reason: data.reason?.trim() || null,
        isRecurring,
        weekdays,
      },
      include: {
        unit: { select: { id: true, name: true } },
      },
    })
  }

  async deleteTimeBlock(blockId: string, userId: string) {
    const block = await prisma.arenaTimeBlock.findUnique({ where: { id: blockId } })
    if (!block) throw Errors.notFound('Arena time block')
    await this.verifyOwner(block.arenaId, userId)
    await prisma.arenaTimeBlock.delete({ where: { id: blockId } })
  }

  async getAvailability(arenaId: string, date: string, unitId?: string) {
    const arena = await prisma.arena.findUnique({ where: { id: arenaId } })
    if (!arena) throw Errors.notFound('Arena')

    const bookingDate = this.startOfDay(date)
    const nextDay = this.addDays(bookingDate, 1)
    const weekday = this.weekdayNumber(bookingDate)
    const isOperatingDay = arena.operatingDays.includes(weekday)

    const unitWhere: any = { arenaId, isActive: true }
    if (unitId) unitWhere.id = unitId

    const units = await prisma.arenaUnit.findMany({ where: unitWhere })
    const unitIds = units.map(unit => unit.id)

    const [bookings, blocks] = await Promise.all([
      prisma.slotBooking.findMany({
        where: {
          unitId: { in: unitIds },
          date: { gte: bookingDate, lt: nextDay },
          status: { in: ['CONFIRMED', 'CHECKED_IN'] },
        },
        include: {
          bookedBy: {
            include: {
              user: { select: { name: true } },
            },
          },
        },
      }),
      prisma.arenaTimeBlock.findMany({
        where: {
          arenaId,
          unitId: { in: unitIds },
          OR: [
            { date: bookingDate },
            { isRecurring: true, weekdays: { has: weekday } },
          ],
        },
      }),
    ])

    return units.map(unit => {
      const unitOpDays = (unit as any).operatingDays
      const unitIsOperatingDay = unitOpDays?.length > 0 ? unitOpDays.includes(weekday) : isOperatingDay
      const unitOpen = (unit as any).openTime || arena.openTime || '06:00'
      const unitClose = (unit as any).closeTime || arena.closeTime || '22:00'
      const slots = this.generateDaySlots(unitOpen, unitClose, unit.slotIncrementMins || 60)
      const unitBookings = bookings.filter(booking => booking.unitId === unit.id)
      const unitBlocks = blocks.filter(block => block.unitId === unit.id)

      return {
        unit,
        slots: slots.map(slot => {
          if (!unitIsOperatingDay) {
            return {
              start: slot.start,
              end: slot.end,
              available: false,
              status: 'BLOCKED',
              reason: 'Arena closed',
              pricePerHourPaise: unit.pricePerHourPaise,
            }
          }

          const booking = unitBookings.find(item => this.timesOverlap(item.startTime, item.endTime, slot.start, slot.end))
          if (booking) {
            return {
              start: slot.start,
              end: slot.end,
              available: false,
              status: 'BOOKED',
              bookingId: booking.id,
              customerName: booking.bookedBy?.user?.name || null,
              pricePerHourPaise: unit.pricePerHourPaise,
            }
          }

          const block = unitBlocks.find(item => this.timesOverlap(item.startTime, item.endTime, slot.start, slot.end))
          if (block) {
            return {
              id: block.id,
              start: slot.start,
              end: slot.end,
              available: false,
              status: 'BLOCKED',
              reason: block.reason || 'Blocked',
              pricePerHourPaise: unit.pricePerHourPaise,
            }
          }

          return {
            start: slot.start,
            end: slot.end,
            available: true,
            status: 'AVAILABLE',
            pricePerHourPaise: unit.pricePerHourPaise,
          }
        }),
      }
    })
  }

  async getArenaStats(arenaId: string, userId: string) {
    await this.verifyOwner(arenaId, userId)
    const [totalBookings, completedBookings, revenue] = await Promise.all([
      prisma.slotBooking.count({ where: { arenaId } }),
      prisma.slotBooking.count({ where: { arenaId, status: 'COMPLETED' } }),
      prisma.slotBooking.aggregate({
        where: { arenaId, status: { in: ['CONFIRMED', 'COMPLETED', 'CHECKED_IN'] } },
        _sum: { totalAmountPaise: true },
      }),
    ])
    return {
      totalBookings,
      completedBookings,
      totalRevenuePaise: revenue._sum.totalAmountPaise || 0,
    }
  }

  private generateDaySlots(openTime: string, closeTime: string, stepMins: number) {
    const slots: Array<{ start: string; end: string }> = []
    const openMinutes = this.timeToMinutes(openTime)
    const closeMinutes = this.timeToMinutes(closeTime)
    const step = stepMins > 0 ? stepMins : 60

    for (let current = openMinutes; current + step <= closeMinutes; current += step) {
      slots.push({
        start: this.minutesToTime(current),
        end: this.minutesToTime(current + step),
      })
    }
    return slots
  }

  private async assertNoTimeBlockConflict(
    arenaId: string,
    unitId: string,
    blockDate: Date | null,
    weekdays: number[],
    startTime: string,
    endTime: string,
  ) {
    if (blockDate) {
      const weekday = this.weekdayNumber(blockDate)
      const conflict = await prisma.arenaTimeBlock.findFirst({
        where: {
          arenaId,
          unitId,
          startTime: { lt: endTime },
          endTime: { gt: startTime },
          OR: [
            { date: blockDate },
            { isRecurring: true, weekdays: { has: weekday } },
          ],
        },
      })
      if (conflict) {
        throw new AppError('BLOCK_CONFLICT', 'This block overlaps an existing blocked window', 409)
      }
      return
    }

    if (weekdays.length === 0) return
    const recurringConflicts = await prisma.arenaTimeBlock.findMany({
      where: {
        arenaId,
        unitId,
        isRecurring: true,
        startTime: { lt: endTime },
        endTime: { gt: startTime },
      },
      select: { id: true, weekdays: true },
    })
    const overlappingRecurring = recurringConflicts.find(block => block.weekdays.some(day => weekdays.includes(day)))
    if (overlappingRecurring) {
      throw new AppError('BLOCK_CONFLICT', 'This recurring block overlaps an existing recurring block', 409)
    }
  }

  private async assertNoConfirmedBookingConflict(
    arenaId: string,
    unitId: string,
    date: Date,
    startTime: string,
    endTime: string,
  ) {
    const nextDay = this.addDays(date, 1)
    const conflict = await prisma.slotBooking.findFirst({
      where: {
        arenaId,
        unitId,
        date: { gte: date, lt: nextDay },
        status: { in: ['CONFIRMED', 'CHECKED_IN'] },
        startTime: { lt: endTime },
        endTime: { gt: startTime },
      },
    })
    if (conflict) {
      throw new AppError('BLOCK_CONFLICT', 'A confirmed booking already exists in this window', 409)
    }
  }

  private isRangeWithinArenaHours(openTime: string, closeTime: string, startTime: string, endTime: string) {
    const openMinutes = this.timeToMinutes(openTime || '06:00')
    const closeMinutes = this.timeToMinutes(closeTime || '22:00')
    const startMinutes = this.timeToMinutes(startTime)
    const endMinutes = this.timeToMinutes(endTime)
    return startMinutes >= openMinutes && endMinutes <= closeMinutes && endMinutes > startMinutes
  }

  private timesOverlap(s1: string, e1: string, s2: string, e2: string): boolean {
    return s1 < e2 && e1 > s2
  }

  private timeToMinutes(value: string): number {
    const [hours, minutes] = value.split(':').map(Number)
    return hours * 60 + minutes
  }

  private minutesToTime(value: number): string {
    const safeValue = Math.max(0, value)
    const hours = Math.floor(safeValue / 60)
    const minutes = safeValue % 60
    return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}`
  }

  private startOfDay(value: string): Date {
    const parsed = new Date(value)
    if (Number.isNaN(parsed.getTime())) {
      throw new AppError('INVALID_DATE', 'Invalid date', 400)
    }
    return new Date(Date.UTC(parsed.getUTCFullYear(), parsed.getUTCMonth(), parsed.getUTCDate()))
  }

  private addDays(value: Date, days: number): Date {
    const next = new Date(value)
    next.setUTCDate(next.getUTCDate() + days)
    return next
  }

  private weekdayNumber(value: Date): number {
    const day = value.getUTCDay()
    return day === 0 ? 7 : day
  }

  private haversineKm(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371
    const dLat = ((lat2 - lat1) * Math.PI) / 180
    const dLon = ((lon2 - lon1) * Math.PI) / 180
    const a =
      Math.sin(dLat / 2) ** 2 +
      Math.cos((lat1 * Math.PI) / 180) * Math.cos((lat2 * Math.PI) / 180) * Math.sin(dLon / 2) ** 2
    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  }

  private async verifyOwner(arenaId: string, userId: string) {
    const owner = await prisma.arenaOwnerProfile.findUnique({ where: { userId } })
    if (!owner) throw Errors.forbidden()
    const arena = await prisma.arena.findUnique({ where: { id: arenaId } })
    if (!arena || arena.ownerId !== owner.id) throw Errors.forbidden()
    return arena
  }
}
