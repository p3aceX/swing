import { prisma, UserRole } from '@swing/db'
import { AppError, Errors } from '../../lib/errors'

const BIZ_PROFILE_ROLES: UserRole[] = [UserRole.COACH, UserRole.ACADEMY_OWNER, UserRole.ARENA_OWNER]

export class BizService {
  private async ensureBusinessOwnerRole(userId: string) {
    const user = await prisma.user.findUnique({ where: { id: userId } })
    if (!user) throw Errors.notFound('User')
    if (user.roles.includes(UserRole.BUSINESS_OWNER)) return user

    return prisma.user.update({
      where: { id: userId },
      data: { roles: { push: UserRole.BUSINESS_OWNER }, activeRole: UserRole.BUSINESS_OWNER },
    })
  }

  private async addRole(userId: string, role: UserRole) {
    const user = await prisma.user.findUnique({ where: { id: userId }, select: { roles: true } })
    if (!user) throw Errors.notFound('User')
    if (!BIZ_PROFILE_ROLES.includes(role)) throw new AppError('INVALID_BIZ_ROLE', 'Unsupported business role', 400)
    if (user.roles.includes(role)) return
    await prisma.user.update({ where: { id: userId }, data: { roles: { push: role } } })
  }

  async getMe(userId: string) {
    await this.ensureBusinessOwnerRole(userId)

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, name: true, phone: true, email: true, activeRole: true, roles: true },
    })
    if (!user) throw Errors.notFound('User')

    const [businessAccount, coachProfile, academyOwnerProfile, arenaOwnerProfile, managerProfile, storeOwnerProfile] =
      await Promise.all([
        prisma.businessAccount.findUnique({ where: { userId } }),
        prisma.coachProfile.findUnique({ where: { userId }, select: { id: true, businessAccountId: true } }),
        prisma.academyOwnerProfile.findUnique({
          where: { userId },
          include: { academies: { where: { isActive: true }, select: { id: true, name: true }, take: 1 } },
        }),
        prisma.arenaOwnerProfile.findUnique({
          where: { userId },
          include: { arenas: { where: { isActive: true }, select: { id: true, name: true } } },
        }),
        prisma.arenaManager.findFirst({ where: { userId, isActive: true }, select: { arenaId: true } }),
        prisma.storeOwnerProfile.findUnique({
          where: { userId },
          include: { stores: { where: { isActive: true }, select: { id: true, name: true } } },
        }),
      ])

    const academy = academyOwnerProfile?.academies[0] ?? null
    const arena = arenaOwnerProfile?.arenas[0] ?? null
    const arenas = arenaOwnerProfile?.arenas ?? []
    const stores = storeOwnerProfile?.stores ?? []

    return {
      user,
      businessAccount,
      businessStatus: {
        hasBusinessAccount: !!businessAccount,
        businessAccountId: businessAccount?.id ?? null,
        canCreateProfiles: ['ACADEMY', 'COACH', 'ARENA'],
        availableProfiles: [
          ...(academy ? ['ACADEMY'] : []),
          ...(coachProfile ? ['COACH'] : []),
          ...(arena ? ['ARENA'] : []),
          ...(managerProfile ? ['ARENA_MANAGER'] : []),
          ...(stores.length > 0 ? ['STORE'] : []),
        ],
        academyId: academy?.id ?? null,
        coachProfileId: coachProfile?.id ?? null,
        arenaId: arena?.id ?? null,
        arenaIds: arenas.map((item) => item.id),
        managedArenaId: managerProfile?.arenaId ?? null,
        storeIds: stores.map((store) => store.id),
        storeAvailable: stores.length > 0,
      },
      stores,
    }
  }

  async upsertBusinessDetails(userId: string, data: any) {
    await this.ensureBusinessOwnerRole(userId)
    return prisma.businessAccount.upsert({
      where: { userId },
      update: { ...data, onboardingComplete: true },
      create: { userId, ...data, onboardingComplete: true },
    })
  }

  async createAcademyProfile(userId: string, data: any) {
    const businessAccount = await prisma.businessAccount.findUnique({ where: { userId } })
    if (!businessAccount) throw new AppError('BUSINESS_DETAILS_REQUIRED', 'Complete common business details first', 400)

    let ownerProfile = await prisma.academyOwnerProfile.findUnique({ where: { userId } })
    if (!ownerProfile) {
      ownerProfile = await prisma.academyOwnerProfile.create({ data: { userId } })
    }
    await this.addRole(userId, UserRole.ACADEMY_OWNER)

    return prisma.academy.create({
      data: {
        ownerId: ownerProfile.id,
        businessAccountId: businessAccount.id,
        name: data.name,
        description: data.description,
        city: data.city,
        state: data.state,
        address: data.address,
        pincode: data.pincode,
        latitude: data.latitude,
        longitude: data.longitude,
        phone: data.phone,
        email: data.email,
        websiteUrl: data.websiteUrl,
        tagline: data.tagline,
        foundedYear: data.foundedYear,
      },
    })
  }

  async upsertCoachProfile(userId: string, data: any) {
    const businessAccount = await prisma.businessAccount.findUnique({ where: { userId } })
    if (!businessAccount) throw new AppError('BUSINESS_DETAILS_REQUIRED', 'Complete common business details first', 400)

    await this.addRole(userId, UserRole.COACH)
    const profile = await prisma.coachProfile.upsert({
      where: { userId },
      create: {
        userId,
        businessAccountId: businessAccount.id,
        ...data,
        city: data.city ?? businessAccount.city ?? undefined,
        state: data.state ?? businessAccount.state ?? undefined,
      },
      update: { businessAccountId: businessAccount.id, ...data },
      include: { user: { select: { name: true, avatarUrl: true, phone: true } } },
    })
    return {
      ...profile,
      name: profile.user?.name ?? '',
      phone: profile.user?.phone ?? '',
      avatarUrl: profile.user?.avatarUrl ?? null,
    }
  }

  async createArenaProfile(userId: string, data: any) {
    let businessAccount = await prisma.businessAccount.findUnique({ where: { userId } })
    if (!businessAccount) {
      const user = await prisma.user.findUnique({ where: { id: userId }, select: { name: true } })
      businessAccount = await prisma.businessAccount.create({
        data: { userId, businessName: user?.name ?? data.name },
      })
    }

    let ownerProfile = await prisma.arenaOwnerProfile.findUnique({ where: { userId } })
    if (!ownerProfile) {
      ownerProfile = await prisma.arenaOwnerProfile.create({
        data: {
          userId,
          businessName: businessAccount.businessName,
          gstNumber: businessAccount.gstNumber,
          panNumber: businessAccount.panNumber,
        },
      })
    }
    await this.addRole(userId, UserRole.ARENA_OWNER)

    const { toSlug, generateArenaSlug } = await import('../../lib/slug.js')
    const citySlug = toSlug(data.city || '')
    const baseArenaSlug = toSlug(data.name || '')
    const arenaSlug = await generateArenaSlug(citySlug, baseArenaSlug)

    return prisma.arena.create({
      data: {
        ownerId: ownerProfile.id,
        businessAccountId: businessAccount.id,
        name: data.name,
        description: data.description,
        address: data.address,
        city: data.city,
        state: data.state,
        pincode: data.pincode,
        latitude: data.latitude ?? 0,
        longitude: data.longitude ?? 0,
        phone: data.phone,
        sports: data.sports ?? ['CRICKET'],
        photoUrls: data.photoUrls ?? [],
        hasParking: data.hasParking ?? false,
        hasLights: data.hasLights ?? false,
        hasWashrooms: data.hasWashrooms ?? false,
        hasCanteen: data.hasCanteen ?? false,
        hasCCTV: data.hasCCTV ?? false,
        hasScorer: data.hasScorer ?? false,
        citySlug,
        arenaSlug,
        isPublicPage: true,
      },
    })
  }

  async listStores(userId: string) {
    const ownerProfile = await prisma.storeOwnerProfile.findUnique({
      where: { userId },
      include: {
        stores: {
          where: { isActive: true },
          include: { inventory: { where: { isActive: true }, take: 5 } },
          orderBy: { createdAt: 'desc' },
        },
      },
    })
    return ownerProfile?.stores ?? []
  }
}
