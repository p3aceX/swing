import { prisma } from '@swing/db'
import { getHeldSlotsSet } from '../../lib/redis'
import { Errors, AppError } from '../../lib/errors'

type ArenaTimeBlockInput = {
  unitId: string
  date?: string
  weekdays: number[]
  startTime: string
  endTime: string
  reason?: string
  isHoliday?: boolean
}

type ArenaTimeBlockFilters = {
  date?: string
  unitId?: string
  recurringOnly?: 'true' | 'false'
}

type LinkedArenaGuest = {
  userId: string
  playerProfileId: string
} | null

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
    const { toSlug, generateArenaSlug } = await import('../../lib/slug.js')
    const citySlug = toSlug(data.city || '')
    const baseArenaSlug = toSlug(data.name || '')
    const arenaSlug = await generateArenaSlug(citySlug, baseArenaSlug)

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
        hasParking: data.hasParking ?? false,
        hasLights: data.hasLights ?? false,
        hasWashrooms: data.hasWashrooms ?? false,
        hasCanteen: data.hasCanteen ?? false,
        hasCCTV: data.hasCCTV ?? false,
        hasScorer: data.hasScorer ?? false,
        isActive: true,
        citySlug,
        arenaSlug,
        isPublicPage: true,
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
      if (f in data && data[f] !== null && data[f] !== undefined) allowed[f] = data[f]
    }
    if (data.customSlug !== undefined) allowed.customSlug = data.customSlug || null
    if (data.isPublicPage !== undefined) allowed.isPublicPage = data.isPublicPage
    return prisma.arena.update({ where: { id: arenaId }, data: allowed })
  }

  async deleteArena(arenaId: string, userId: string) {
    await this.verifyOwner(arenaId, userId)
    await prisma.$transaction([
      prisma.monthlyPass.deleteMany({ where: { arenaId } }),
      prisma.arenaManager.deleteMany({ where: { arenaId } }),
      (prisma as any).review.deleteMany({ where: { arenaId } }),
      prisma.arenaTimeBlock.deleteMany({ where: { arenaId } }),
      prisma.slotBooking.deleteMany({ where: { arenaId } }),
      prisma.arenaAddon.deleteMany({ where: { arenaId } }),
      (prisma.arenaUnit as any).deleteMany({ where: { arenaId } }),
      prisma.arena.delete({ where: { id: arenaId } }),
    ])
  }

  async addUnit(arenaId: string, userId: string, data: any) {
    await this.verifyOwner(arenaId, userId)
    return (prisma.arenaUnit as any).create({
      data: {
        arenaId,
        name: data.name,
        unitType: data.unitType,
        unitTypeLabel: data.unitTypeLabel || null,
        netType: data.netType || null,
        netVariants: data.netVariants ?? null,
        sport: data.sport || 'CRICKET',
        description: data.description || null,
        pricePerHourPaise: data.pricePerHourPaise,
        peakPricePaise: data.peakPricePaise || null,
        peakHoursStart: data.peakHoursStart || null,
        peakHoursEnd: data.peakHoursEnd || null,
        price4HrPaise: data.price4HrPaise || null,
        price8HrPaise: data.price8HrPaise || null,
        priceFullDayPaise: data.priceFullDayPaise || null,
        minBulkDays: data.minBulkDays ?? null,
        bulkDayRatePaise: data.bulkDayRatePaise ?? null,
        monthlyPassEnabled: data.monthlyPassEnabled ?? false,
        monthlyPassRatePaise: data.monthlyPassRatePaise ?? null,
        weekendMultiplier: data.weekendMultiplier ?? 1.0,
        minSlotMins: data.minSlotMins ?? 60,
        maxSlotMins: data.maxSlotMins ?? 240,
        slotIncrementMins: data.slotIncrementMins ?? 60,
        turnaroundMins: data.turnaroundMins ?? 0,
        minAdvancePaise: data.minAdvancePaise ?? 0,
        boundarySize: data.boundarySize ? Number(data.boundarySize) : null,
        parentUnitId: data.parentUnitId || null,
        openTime: data.openTime || null,
        closeTime: data.closeTime || null,
        operatingDays: data.operatingDays || [],
        hasFloodlights: data.hasFloodlights ?? false,
        advanceBookingDays: data.advanceBookingDays ?? null,
        cancellationHours: data.cancellationHours ?? null,
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
      'name', 'description', 'unitType', 'unitTypeLabel', 'netType', 'netVariants', 'sport', 'pricePerHourPaise', 'peakPricePaise',
      'peakHoursStart', 'peakHoursEnd', 'price4HrPaise', 'price8HrPaise', 'priceFullDayPaise',
      'minBulkDays', 'bulkDayRatePaise', 'monthlyPassEnabled', 'monthlyPassRatePaise',
      'weekendMultiplier', 'minSlotMins', 'maxSlotMins', 'slotIncrementMins', 'turnaroundMins', 'minAdvancePaise',
      'boundarySize', 'parentUnitId', 'openTime', 'closeTime', 'operatingDays', 'hasFloodlights',
      'advanceBookingDays', 'cancellationHours', 'isActive',
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

    const isHoliday = data.isHoliday ?? false

    const weekdays = [...new Set(data.weekdays || [])].sort((a, b) => a - b)
    const isRecurring = weekdays.length > 0
    const blockDate = data.date ? this.startOfDay(data.date) : null

    if (!isRecurring && !blockDate) {
      throw new AppError('INVALID_BLOCK_DATE', 'A one-time block requires a date', 400)
    }

    if (!isHoliday && !isRecurring && blockDate && !arena.operatingDays.includes(this.weekdayNumber(blockDate))) {
      throw new AppError('ARENA_CLOSED', 'Selected date is outside the arena operating days', 400)
    }

    if (!isRecurring && blockDate) {
      await this.assertNoConfirmedBookingConflict(arenaId, unit.id, blockDate, data.startTime, data.endTime)
    }
    await this.assertNoTimeBlockConflict(arenaId, unit.id, blockDate, weekdays, data.startTime, data.endTime, isHoliday)

    return prisma.arenaTimeBlock.create({
      data: {
        arenaId,
        unitId: unit.id,
        date: blockDate,
        startTime: data.startTime,
        endTime: data.endTime,
        reason: data.reason?.trim() || null,
        isRecurring,
        isHoliday,
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

    // Also fetch all child unit IDs so we can block parent slots when a child is booked and vice versa
    const allArenaUnits: { id: string; parentUnitId: string | null }[] =
      await (prisma.arenaUnit as any).findMany({ where: { arenaId, isActive: true }, select: { id: true, parentUnitId: true } })

    const [bookings, blocks] = await Promise.all([
      prisma.slotBooking.findMany({
        where: {
          arenaId,
          date: { gte: bookingDate, lt: nextDay },
          status: { in: ['CONFIRMED', 'CHECKED_IN', 'PENDING_PAYMENT'] },
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

    const getRelatedIds = (unit: { id: string; parentUnitId: string | null }): string[] => {
      const ids: string[] = []
      if (unit.parentUnitId) ids.push(unit.parentUnitId)
      allArenaUnits.filter(u => u.parentUnitId === unit.id).forEach(u => ids.push(u.id))
      return ids
    }

    // Build Redis hold entries for every unit+slot combination so we can batch-check in one mget
    const dateStr = `${bookingDate.getUTCFullYear()}-${String(bookingDate.getUTCMonth() + 1).padStart(2, '0')}-${String(bookingDate.getUTCDate()).padStart(2, '0')}`
    const holdEntries: Array<{ unitId: string; date: string; startTime: string }> = []
    for (const unit of units) {
      const uOpen = (unit as any).openTime || arena.openTime || '06:00'
      const uClose = (unit as any).closeTime || arena.closeTime || '22:00'
      const uSlots = this.generateDaySlots(uOpen, uClose, unit.slotIncrementMins || 60)
      uSlots.forEach(s => holdEntries.push({ unitId: unit.id, date: dateStr, startTime: s.start }))
    }
    const heldSet = await getHeldSlotsSet(holdEntries)

    return units.map(unit => {
      const unitOpDays = (unit as any).operatingDays
      const unitIsOperatingDay = unitOpDays?.length > 0 ? unitOpDays.includes(weekday) : isOperatingDay
      const unitOpen = (unit as any).openTime || arena.openTime || '06:00'
      const unitClose = (unit as any).closeTime || arena.closeTime || '22:00'
      const slots = this.generateDaySlots(unitOpen, unitClose, unit.slotIncrementMins || 60)
      const relatedIds = getRelatedIds(unit as any)
      const unitBookings = bookings.filter(booking => booking.unitId === unit.id)
      const relatedBookings = bookings.filter(booking => relatedIds.includes(booking.unitId))
      const unitBlocks = blocks.filter(block => block.unitId === unit.id)

      const unitTurnaround: number = (unit as any).turnaroundMins ?? 0

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

          // Extend booking effective end by turnaround so the gap after a session shows as unavailable
          const booking = unitBookings.find(item => {
            const effectiveEnd = unitTurnaround > 0
              ? this.minutesToTime(this.timeToMinutes(item.endTime) + unitTurnaround)
              : item.endTime
            return this.timesOverlap(item.startTime, effectiveEnd, slot.start, slot.end)
          })
          if (booking) {
            const isTurnaround = unitTurnaround > 0
              && slot.start >= booking.endTime
              && slot.start < this.minutesToTime(this.timeToMinutes(booking.endTime) + unitTurnaround)
            return {
              start: slot.start,
              end: slot.end,
              available: false,
              status: isTurnaround ? 'TURNAROUND' : 'BOOKED',
              bookingId: booking.id,
              customerName: isTurnaround ? null : (booking.bookedBy?.user?.name || null),
              reason: isTurnaround ? 'Turnaround gap' : undefined,
              pricePerHourPaise: unit.pricePerHourPaise,
            }
          }

          const relatedBooking = relatedBookings.find(item => this.timesOverlap(item.startTime, item.endTime, slot.start, slot.end))
          if (relatedBooking) {
            return {
              start: slot.start,
              end: slot.end,
              available: false,
              status: 'BOOKED',
              reason: 'Linked unit booked',
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

          const isHeld = heldSet.has(`${unit.id}:${dateStr}:${slot.start}`)
          if (isHeld) {
            return {
              start: slot.start,
              end: slot.end,
              available: false,
              status: 'HELD',
              reason: 'Slot temporarily reserved',
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

  async getPlayerSlots(arenaId: string, date: string, durationMins: number) {
    const arena = await prisma.arena.findUnique({ where: { id: arenaId } })
    if (!arena) throw Errors.notFound('Arena')

    const bookingDate = this.startOfDay(date)
    const nextDay = this.addDays(bookingDate, 1)
    const weekday = this.weekdayNumber(bookingDate)
    const isWeekend = weekday === 6 || weekday === 7
    const isOperatingDay = arena.operatingDays.includes(weekday)

    if (!isOperatingDay) {
      return { arena: this.formatArenaInfo(arena), unitGroups: [] }
    }

    // Current IST time — used to filter out past/too-soon slots when date is today
    const istOffsetMs = (5 * 60 + 30) * 60 * 1000
    const nowUtcPlusIST = new Date(Date.now() + istOffsetMs)
    const todayIST = new Date(Date.UTC(nowUtcPlusIST.getUTCFullYear(), nowUtcPlusIST.getUTCMonth(), nowUtcPlusIST.getUTCDate()))
    const isToday = bookingDate.getTime() === todayIST.getTime()
    const nowISTMins = nowUtcPlusIST.getUTCHours() * 60 + nowUtcPlusIST.getUTCMinutes()
    const leadTimeMins = (arena as any).bufferMins ?? 30

    const allUnits: any[] = await (prisma.arenaUnit as any).findMany({
      where: { arenaId },
    })
    const allUnitIds = allUnits.map((u: any) => u.id)

    const [bookings, timeBlocks] = await Promise.all([
      prisma.slotBooking.findMany({
        where: {
          arenaId,
          date: { gte: bookingDate, lt: nextDay },
          status: { in: ['CONFIRMED', 'CHECKED_IN', 'PENDING_PAYMENT'] },
          unitId: { in: allUnitIds },
        },
      }),
      prisma.arenaTimeBlock.findMany({
        where: {
          arenaId,
          unitId: { in: allUnitIds },
          OR: [{ date: bookingDate }, { isRecurring: true, weekdays: { has: weekday } }],
        },
      }),
    ])

    // Build Redis hold set for all unit+start combinations in one batch call
    const slotsDateStr = `${bookingDate.getUTCFullYear()}-${String(bookingDate.getUTCMonth() + 1).padStart(2, '0')}-${String(bookingDate.getUTCDate()).padStart(2, '0')}`
    const netUnitTypesSet = new Set(['CRICKET_NET', 'INDOOR_NET'])
    const playerHoldEntries: Array<{ unitId: string; date: string; startTime: string }> = []
    for (const u of allUnits) {
      const uOpen: string = (u as any).openTime || arena.openTime || '06:00'
      const uClose: string = (u as any).closeTime || arena.closeTime || '22:00'
      // Net units use slotIncrementMins (multiple nets can overlap); single-capacity units step
      // by durationMins so held-slot keys align with the non-overlapping slots we generate below
      const isNet = netUnitTypesSet.has((u as any).unitType)
      const uStep: number = isNet ? ((u as any).slotIncrementMins || 60) : durationMins
      const uOpenMins = this.timeToMinutes(uOpen)
      const uCloseMins = this.timeToMinutes(uClose)
      for (let cur = uOpenMins; cur < uCloseMins; cur += uStep) {
        playerHoldEntries.push({ unitId: u.id, date: slotsDateStr, startTime: this.minutesToTime(cur) })
      }
    }
    const playerHeldSet = await getHeldSlotsSet(playerHoldEntries)
    const unitTurnaroundMap = new Map<string, number>(allUnits.map((u: any) => [u.id, u.turnaroundMins ?? 0]))

    const isWindowBusy = (unitId: string, startTime: string, endTime: string): boolean => {
      if (playerHeldSet.has(`${unitId}:${slotsDateStr}:${startTime}`)) return true
      const turnaround = unitTurnaroundMap.get(unitId) ?? 0
      // Shift start back by turnaround so existing bookings whose end falls in the gap are treated as conflicts
      const effectiveStart = turnaround > 0
        ? this.minutesToTime(Math.max(0, this.timeToMinutes(startTime) - turnaround))
        : startTime
      return (
        bookings.some(b => b.unitId === unitId && this.timesOverlap(b.startTime, b.endTime, effectiveStart, endTime)) ||
        timeBlocks.some(b => b.unitId === unitId && this.timesOverlap(b.startTime, b.endTime, startTime, endTime))
      )
    }

    const getRelatedIds = (unit: any): string[] => {
      const ids: string[] = []
      if (unit.parentUnitId) ids.push(unit.parentUnitId)
      allUnits.filter((u: any) => u.parentUnitId === unit.id).forEach((u: any) => ids.push(u.id))
      return ids
    }

    const isUnitAvailable = (unit: any, startTime: string, endTime: string): boolean => {
      if (isWindowBusy(unit.id, startTime, endTime)) return false
      return !getRelatedIds(unit).some(rid => isWindowBusy(rid, startTime, endTime))
    }

    const getPossibleStarts = (unit: any, stepOverride?: number): string[] => {
      const openTime = unit.openTime || arena.openTime || '06:00'
      const closeTime = unit.closeTime || arena.closeTime || '22:00'
      const step = stepOverride ?? unit.slotIncrementMins ?? 60
      const openMins = this.timeToMinutes(openTime)
      const closeMins = this.timeToMinutes(closeTime)
      const unitLeadMins = unit.bufferMins ?? leadTimeMins
      const starts: string[] = []
      for (let cur = openMins; cur + durationMins <= closeMins; cur += step) {
        if (isToday && cur < nowISTMins + unitLeadMins) continue
        starts.push(this.minutesToTime(cur))
      }
      return starts
    }

    const computePricePaise = (unit: any): number => {
      let base: number
      if (durationMins >= 720 && unit.priceFullDayPaise) base = unit.priceFullDayPaise
      else if (durationMins === 480 && unit.price8HrPaise) base = unit.price8HrPaise
      else if (durationMins === 240 && unit.price4HrPaise) base = unit.price4HrPaise
      else base = Math.round((unit.pricePerHourPaise * durationMins) / 60)
      const mult = isWeekend ? (unit.weekendMultiplier || 1.0) : 1.0
      return Math.round(base * mult)
    }

    const netUnits = allUnits.filter((u: any) => netUnitTypesSet.has(u.unitType))
    const nonNetUnits = allUnits.filter((u: any) => !netUnitTypesSet.has(u.unitType))

    const unitGroups: any[] = []

    // All nets merged into one group — per-slot breakdown by net type for sub-picker
    const activeNetUnits = netUnits.filter((u: any) => {
      const unitOpDays: number[] = u.operatingDays
      return unitOpDays?.length > 0 ? unitOpDays.includes(weekday) : isOperatingDay
    })

    if (activeNetUnits.length > 0) {
      // Union of possible start times across all active net units (each uses its own open/close)
      const startTimeSet = new Set<string>()
      for (const unit of activeNetUnits) {
        for (const t of getPossibleStarts(unit)) startTimeSet.add(t)
      }
      const possibleStarts = [...startTimeSet].sort()

      // Extract per-type variants from a unit (supports netVariants JSON array or legacy netType string)
      const getUnitVariants = (u: any): Array<{ type: string; count: number; pricePaise: number }> => {
        const nv = u.netVariants
        if (Array.isArray(nv) && nv.length > 0) {
          return nv.map((v: any) => ({
            type: String(v.type || 'Standard'),
            count: Number(v.count) || 1,
            pricePaise: Number(v.pricePaise) || u.pricePerHourPaise,
          }))
        }
        return [{ type: String(u.netType || 'Standard'), count: 1, pricePaise: u.pricePerHourPaise }]
      }

      // Distinct net types across all active net units
      const netTypeKeys = [...new Set(activeNetUnits.flatMap((u: any) => getUnitVariants(u).map((v: any) => v.type)))]

      const rep = activeNetUnits[0]
      const availableSlots: any[] = []

      for (const startTime of possibleStarts) {
        const endTime = this.minutesToTime(this.timeToMinutes(startTime) + durationMins)

        // For multi-count variant units, availability is per-variant capacity, not unit-level
        const available = activeNetUnits.filter((u: any) => {
          const variants = getUnitVariants(u)
          const hasMultiCount = variants.some((v: any) => v.count > 1)
          if (!hasMultiCount) return isUnitAvailable(u, startTime, endTime)
          // Time blocks still fully block the unit
          if (timeBlocks.some((b: any) => b.unitId === u.id && this.timesOverlap(b.startTime, b.endTime, startTime, endTime))) return false
          // Available if any variant type still has remaining capacity
          return variants.some((variant: any) => {
            const booked = bookings.filter((b: any) =>
              b.unitId === u.id &&
              b.netVariantType === variant.type &&
              this.timesOverlap(b.startTime, b.endTime, startTime, endTime)
            ).length
            return booked < variant.count
          })
        })
        if (available.length === 0) continue

        // Per-type breakdown so the frontend can offer a sub-picker
        const netTypeOptions = netTypeKeys.map((nt: string) => {
          let totalAvailable = 0
          let assignedUnitId: string | null = null
          let variantPricePaise = 0

          for (const u of available) {
            const variant = getUnitVariants(u).find((v: any) => v.type === nt)
            if (!variant) continue
            const existingForType = bookings.filter((b: any) =>
              b.unitId === u.id &&
              b.netVariantType === nt &&
              this.timesOverlap(b.startTime, b.endTime, startTime, endTime)
            ).length
            const slotAvail = Math.max(0, variant.count - existingForType)
            if (slotAvail > 0) {
              totalAvailable += slotAvail
              if (!assignedUnitId) {
                assignedUnitId = u.id
                variantPricePaise = variant.pricePaise
              }
            }
          }

          if (!assignedUnitId) return null
          return {
            netType: nt,
            availableCount: totalAvailable,
            assignedUnitId,
            totalAmountPaise: Math.round((variantPricePaise * durationMins) / 60),
          }
        }).filter(Boolean)

        const assigned = available[0]
        availableSlots.push({
          startTime,
          endTime,
          availableCount: available.length,
          assignedUnitId: assigned.id,
          totalAmountPaise: computePricePaise(assigned),
          isWeekendRate: isWeekend && (assigned.weekendMultiplier || 1.0) > 1.0,
          netTypeOptions,
        })
      }

      console.log(`[slots] NETS group: activeUnits=${activeNetUnits.length} netTypeKeys=${JSON.stringify(netTypeKeys)} slots=${availableSlots.length} firstSlotOpts=${JSON.stringify(availableSlots[0]?.netTypeOptions ?? [])}`)
      console.log(`[slots] NETS monthly: unitMonthlyPassEnabled=${netUnits.map((u:any)=>u.monthlyPassEnabled)} unitMonthlyPassRatePaise=${netUnits.map((u:any)=>u.monthlyPassRatePaise)} netVariants=${JSON.stringify(netUnits.map((u:any)=>u.netVariants))}`)
      unitGroups.push({
        groupKey: 'NETS',
        displayName: 'Cricket Nets',
        unitType: rep.unitType,
        netType: null,
        netTypes: netTypeKeys,
        totalCount: activeNetUnits.length,
        description: rep.description,
        photoUrls: rep.photoUrls,
        minAdvancePaise: Math.min(...activeNetUnits.map((u: any) => u.minAdvancePaise || 0)),
        minSlotMins: rep.minSlotMins,
        maxSlotMins: rep.maxSlotMins,
        pricePerHourPaise: Math.min(...activeNetUnits.flatMap((u: any) => getUnitVariants(u).map((v: any) => v.pricePaise))),
        price4HrPaise: rep.price4HrPaise ?? null,
        price8HrPaise: rep.price8HrPaise ?? null,
        weekendMultiplier: rep.weekendMultiplier,
        hasFloodlights: activeNetUnits.some((u: any) => u.hasFloodlights),
        monthlyPassEnabled: netUnits.some((u: any) => {
          if (u.monthlyPassEnabled) return true
          const nv = u.netVariants
          return Array.isArray(nv) && nv.some((v: any) => v.monthlyPassRatePaise && Number(v.monthlyPassRatePaise) > 0)
        }),
        monthlyPassRatePaise: (() => {
          const rates: number[] = []
          for (const u of netUnits) {
            if (u.monthlyPassRatePaise && Number(u.monthlyPassRatePaise) > 0) rates.push(Number(u.monthlyPassRatePaise))
            const nv = u.netVariants
            if (Array.isArray(nv)) {
              for (const v of nv) {
                if (v.monthlyPassRatePaise && Number(v.monthlyPassRatePaise) > 0) rates.push(Number(v.monthlyPassRatePaise))
              }
            }
          }
          return rates.length > 0 ? Math.min(...rates) : null
        })(),
        availableSlots,
      })
    }

    // Non-net units individually
    for (const unit of nonNetUnits) {
      const unitOpDays: number[] = unit.operatingDays
      const isUnitOperatingDay = unitOpDays?.length > 0 ? unitOpDays.includes(weekday) : isOperatingDay
      if (!isUnitOperatingDay) continue

      // Duration is valid if >= minSlotMins, is a multiple of minSlotMins,
      // and fits within the unit's operating window — no maxSlotMins cap needed
      const unitOpenStr: string = (unit as any).openTime || arena.openTime || '06:00'
      const unitCloseStr: string = (unit as any).closeTime || arena.closeTime || '22:00'
      const windowMins = this.timeToMinutes(unitCloseStr) - this.timeToMinutes(unitOpenStr)
      const minSlot = unit.minSlotMins || 30
      const durationValid =
        durationMins >= minSlot &&
        durationMins % minSlot === 0 &&
        durationMins <= windowMins

      // Single-capacity unit: step by durationMins so slots are sequential and non-overlapping
      const possibleStarts = durationValid ? getPossibleStarts(unit, durationMins) : []
      const availableSlots: any[] = []

      for (const startTime of possibleStarts) {
        const endTime = this.minutesToTime(this.timeToMinutes(startTime) + durationMins)
        if (!isUnitAvailable(unit, startTime, endTime)) continue
        availableSlots.push({
          startTime,
          endTime,
          totalAmountPaise: computePricePaise(unit),
          isWeekendRate: isWeekend && (unit.weekendMultiplier || 1.0) > 1.0,
        })
      }

      unitGroups.push({
        groupKey: unit.id,
        displayName: unit.unitTypeLabel || unit.name,
        unitType: unit.unitType,
        unitId: unit.id,
        description: unit.description,
        photoUrls: unit.photoUrls,
        minAdvancePaise: unit.minAdvancePaise || 0,
        minSlotMins: unit.minSlotMins,
        maxSlotMins: unit.maxSlotMins,
        pricePerHourPaise: unit.pricePerHourPaise,
        price4HrPaise: unit.price4HrPaise ?? null,
        price8HrPaise: unit.price8HrPaise ?? null,
        weekendMultiplier: unit.weekendMultiplier,
        hasFloodlights: unit.hasFloodlights,
        minBulkDays: unit.minBulkDays ?? null,
        bulkDayRatePaise: unit.bulkDayRatePaise ?? null,
        availableSlots,
      })
    }

    return { arena: this.formatArenaInfo(arena), unitGroups }
  }

  async getBookingContext(arenaId: string, date: string, durationMins: number, includeAvailability = false) {
    const [playerSlots, availability] = await Promise.all([
      this.getPlayerSlots(arenaId, date, durationMins),
      includeAvailability ? this.getAvailability(arenaId, date) : Promise.resolve(null),
    ])

    const payload: any = {
      arena: playerSlots.arena,
      unitGroups: playerSlots.unitGroups,
      date,
      durationMins,
    }

    if (availability !== null) {
      payload.availability = availability
    }

    return payload
  }

  private formatArenaInfo(arena: any) {
    return {
      id: arena.id,
      name: arena.name,
      description: arena.description,
      address: arena.address,
      city: arena.city,
      state: arena.state,
      pincode: arena.pincode,
      latitude: arena.latitude,
      longitude: arena.longitude,
      photoUrls: arena.photoUrls,
      phone: arena.phone,
      sports: arena.sports,
      openTime: arena.openTime,
      closeTime: arena.closeTime,
      operatingDays: arena.operatingDays,
      bufferMins: arena.bufferMins ?? 30,
      hasParking: arena.hasParking,
      hasLights: arena.hasLights,
      hasWashrooms: arena.hasWashrooms,
      hasCanteen: arena.hasCanteen,
      hasCCTV: arena.hasCCTV,
      hasScorer: arena.hasScorer,
      advanceBookingDays: Math.max(arena.advanceBookingDays ?? 14, 14),
      cancellationHours: arena.cancellationHours ?? 24,
    }
  }

  // ─── Monthly Passes ─────────────────────────────────────────────────────────

  async createMonthlyPass(arenaId: string, userId: string, data: {
    unitId: string
    guestName: string
    guestPhone: string
    startTime: string
    endTime: string
    daysOfWeek: number[]
    startDate: string
    endDate: string
    totalAmountPaise: number
    advancePaise: number
    paymentMode: string
    notes?: string
  }) {
    await this.verifyOwner(arenaId, userId)

    const unit = await (prisma.arenaUnit as any).findUnique({ where: { id: data.unitId } })
    if (!unit || unit.arenaId !== arenaId) throw Errors.notFound('Unit')

    const owner = await prisma.arenaOwnerProfile.findUnique({ where: { userId } })
    if (!owner) throw Errors.forbidden()

    // Compute all matching dates in range
    const start = new Date(data.startDate + 'T00:00:00Z')
    const end = new Date(data.endDate + 'T00:00:00Z')
    const matchingDates: Date[] = []
    for (let d = new Date(start); d <= end; d = this.addDays(d, 1)) {
      if (data.daysOfWeek.includes(this.weekdayNumber(d))) {
        matchingDates.push(new Date(d))
      }
    }

    // Check conflicts for each date — skip conflicted ones
    const conflictUnitIds = await this.getConflictUnitIds(data.unitId)
    const skippedDates: string[] = []
    const bookedDates: Date[] = []

    for (const date of matchingDates) {
      const existing = await prisma.slotBooking.findFirst({
        where: {
          unitId: { in: conflictUnitIds },
          date,
          status: { in: ['CONFIRMED', 'CHECKED_IN', 'PENDING_PAYMENT'] },
          startTime: { lt: data.endTime },
          endTime: { gt: data.startTime },
        },
      })
      if (existing) {
        skippedDates.push(this.formatDate(date))
      } else {
        bookedDates.push(date)
      }
    }

    const linkedGuest = await this.resolveArenaGuest(data.guestPhone, data.guestName)
    const walkinPlayer = linkedGuest ? null : await this.getOrCreateWalkInPlayer(arenaId)
    const bookedById = linkedGuest?.playerProfileId ?? walkinPlayer!.id

    // Create the pass record
    const pass = await (prisma as any).monthlyPass.create({
      data: {
        arenaId,
        unitId: data.unitId,
        guestName: data.guestName,
        guestPhone: data.guestPhone,
        startTime: data.startTime,
        endTime: data.endTime,
        daysOfWeek: data.daysOfWeek,
        startDate: start,
        endDate: end,
        totalAmountPaise: data.totalAmountPaise,
        advancePaise: data.advancePaise,
        paymentMode: data.paymentMode,
        notes: data.notes || null,
        status: 'ACTIVE',
        bookingSource: 'BIZ',
      },
    })

    const durationMins = this.timeToMinutes(data.endTime) - this.timeToMinutes(data.startTime)
    const fullyPaid = data.advancePaise >= data.totalAmountPaise && data.totalAmountPaise > 0

    // Batch-create SlotBookings
    await Promise.all(bookedDates.map(date =>
      prisma.slotBooking.create({
        data: {
          arenaId,
          unitId: data.unitId,
          bookedById,
          date,
          startTime: data.startTime,
          endTime: data.endTime,
          durationMins,
          baseAmountPaise: 0,
          totalAmountPaise: 0,
          totalPricePaise: 0,
          advancePaise: 0,
          status: 'CONFIRMED',
          isOfflineBooking: true,
          createdByOwnerId: owner.id,
          guestName: data.guestName,
          guestPhone: data.guestPhone,
          guestUserId: linkedGuest?.userId ?? null,
          guestPlayerProfileId: linkedGuest?.playerProfileId ?? null,
          guestSource: linkedGuest ? 'ARENA_BOOKING' : 'MANUAL',
          paymentMode: data.paymentMode as any,
          paidAt: fullyPaid ? new Date() : null,
          bookingSource: 'BIZ',
          monthlyPassId: pass.id,
        } as any,
      })
    ))

    return { ...pass, sessionCount: bookedDates.length, skippedDates }
  }

  async listMonthlyPasses(arenaId: string, userId: string, filters: { month?: string; status?: string }) {
    await this.verifyOwner(arenaId, userId)
    const where: any = { arenaId }
    if (filters.status) where.status = filters.status
    if (filters.month) {
      const [year, month] = filters.month.split('-').map(Number)
      where.startDate = { lte: new Date(Date.UTC(year, month - 1, 31)) }
      where.endDate = { gte: new Date(Date.UTC(year, month - 1, 1)) }
    }
    const passes = await (prisma as any).monthlyPass.findMany({
      where,
      orderBy: { createdAt: 'desc' },
    })
    // Attach session counts
    return Promise.all(passes.map(async (p: any) => {
      const sessionCount = await prisma.slotBooking.count({ where: { monthlyPassId: p.id } as any })
      return { ...p, sessionCount }
    }))
  }

  async getMonthlyPass(passId: string, userId: string) {
    const pass = await (prisma as any).monthlyPass.findUnique({ where: { id: passId } })
    if (!pass) throw Errors.notFound('Monthly pass')
    await this.verifyOwner(pass.arenaId, userId)
    const bookings = await prisma.slotBooking.findMany({
      where: { monthlyPassId: passId } as any,
      orderBy: { date: 'asc' },
    })
    return { ...pass, bookings, sessionCount: bookings.length }
  }

  async cancelMonthlyPass(passId: string, userId: string) {
    const pass = await (prisma as any).monthlyPass.findUnique({ where: { id: passId } })
    if (!pass) throw Errors.notFound('Monthly pass')
    await this.verifyOwner(pass.arenaId, userId)

    const today = new Date()
    today.setUTCHours(0, 0, 0, 0)

    // Cancel all future sessions
    await prisma.slotBooking.updateMany({
      where: {
        monthlyPassId: passId,
        date: { gte: today },
        status: { in: ['CONFIRMED', 'PENDING_PAYMENT'] },
      } as any,
      data: { status: 'CANCELLED_BY_OWNER' as any },
    })

    return (prisma as any).monthlyPass.update({
      where: { id: passId },
      data: { status: 'CANCELLED' },
    })
  }

  private async getOrCreateWalkInPlayer(arenaId: string) {
    const walkinEmail = `walkin+${arenaId}@swing.internal`
    let user = await prisma.user.findUnique({ where: { email: walkinEmail } })
    if (!user) {
      user = await prisma.user.create({
        data: {
          phone: `000000000000_${arenaId.slice(0, 8)}`,
          email: walkinEmail,
          name: 'Walk-in Guest',
          roles: ['PLAYER'],
        },
      })
    }
    let player = await prisma.playerProfile.findUnique({ where: { userId: user.id } })
    if (!player) {
      player = await prisma.playerProfile.create({ data: { userId: user.id } })
    }
    return { id: player.id, userId: user.id }
  }

  private normalizePhone(phone: string) {
    const digits = `${phone}`.replace(/\D/g, '')
    if (digits.length > 10 && digits.startsWith('91')) return digits.slice(-10)
    return digits
  }

  private async resolveArenaGuest(phone: string, name: string): Promise<LinkedArenaGuest> {
    const normalizedPhone = this.normalizePhone(phone)
    if (!normalizedPhone || normalizedPhone.length < 10) return null

    let user = await prisma.user.findFirst({
      where: { phone: normalizedPhone },
      include: { playerProfile: true },
    })

    if (!user) {
      user = await prisma.user.create({
        data: {
          phone: normalizedPhone,
          name: name.trim() || `Player ${normalizedPhone.slice(-4)}`,
          roles: ['PLAYER'],
          activeRole: 'PLAYER',
          createdVia: 'ARENA_BOOKING',
          sourceLabels: ['VIA_ARENA_BOOKING'],
        },
        include: { playerProfile: true },
      })
    }

    let player = user.playerProfile
    if (!player) {
      player = await prisma.playerProfile.create({ data: { userId: user.id } })
    }

    const labels = new Set([...(user.sourceLabels ?? []), 'VIA_ARENA_BOOKING'])
    if (!user.sourceLabels?.includes('VIA_ARENA_BOOKING') || !user.createdVia) {
      await prisma.user.update({
        where: { id: user.id },
        data: {
          sourceLabels: [...labels],
          createdVia: user.createdVia ?? 'ARENA_BOOKING',
        },
      })
    }

    return { userId: user.id, playerProfileId: player.id }
  }

  private async getConflictUnitIds(unitId: string): Promise<string[]> {
    const unit: { id: string; parentUnitId: string | null } | null =
      await (prisma.arenaUnit as any).findUnique({
        where: { id: unitId },
        select: { id: true, parentUnitId: true },
      })
    if (!unit) return [unitId]
    const ids = [unitId]
    if (unit.parentUnitId) ids.push(unit.parentUnitId)
    const children: { id: string }[] = await (prisma.arenaUnit as any).findMany({
      where: { parentUnitId: unitId },
      select: { id: true },
    })
    ids.push(...children.map(c => c.id))
    return ids
  }

  private formatDate(d: Date): string {
    return `${d.getUTCFullYear()}-${String(d.getUTCMonth() + 1).padStart(2, '0')}-${String(d.getUTCDate()).padStart(2, '0')}`
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
    isHoliday = false,
  ) {
    if (blockDate) {
      const weekday = this.weekdayNumber(blockDate)
      const conflict = await prisma.arenaTimeBlock.findFirst({
        where: {
          arenaId,
          unitId,
          ...(isHoliday ? { isHoliday: true } : {}),
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
