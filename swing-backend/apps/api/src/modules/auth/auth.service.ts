import { prisma } from '@swing/db'
import { normalizePhone } from '@swing/utils'
import { generateRefreshToken, hashToken, buildJwtPayload, signAccessToken } from '../../lib/jwt'
import { verifyFirebaseToken } from '../../lib/firebase'
import { Errors, AppError } from '../../lib/errors'
import { UserRole } from '@swing/db'

const REFRESH_TOKEN_DAYS = 30

export class AuthService {
  private async issueTokens(user: { id: string; activeRole: UserRole; roles: UserRole[] }) {
    const payload = buildJwtPayload(user.id, user.activeRole, user.roles)
    const accessToken = signAccessToken(payload)

    const rawRefresh = generateRefreshToken()
    const hashedRefresh = hashToken(rawRefresh)
    const expiresAt = new Date(Date.now() + REFRESH_TOKEN_DAYS * 24 * 60 * 60 * 1000)

    await prisma.refreshToken.create({
      data: { userId: user.id, token: hashedRefresh, expiresAt },
    })

    return { accessToken, refreshToken: rawRefresh, expiresIn: 900 }
  }

  private async getBusinessStatus(userId: string) {
    const [businessAccount, coachProfile, academyOwnerProfile, arenaOwnerProfile, managerProfile, storeOwnerProfile] =
      await Promise.all([
        prisma.businessAccount.findUnique({ where: { userId } }),
        prisma.coachProfile.findUnique({ where: { userId }, select: { id: true } }),
        prisma.academyOwnerProfile.findUnique({
          where: { userId },
          include: { academies: { where: { isActive: true }, select: { id: true }, take: 1 } },
        }),
        prisma.arenaOwnerProfile.findUnique({
          where: { userId },
          include: { arenas: { where: { isActive: true }, select: { id: true }, take: 1 } },
        }),
        prisma.arenaManager.findFirst({ where: { userId, isActive: true }, select: { arenaId: true } }),
        prisma.storeOwnerProfile.findUnique({
          where: { userId },
          include: { stores: { where: { isActive: true }, select: { id: true } } },
        }),
      ])

    const academyId = academyOwnerProfile?.academies[0]?.id ?? null
    const arenaId = arenaOwnerProfile?.arenas[0]?.id ?? null
    const managedArenaId = managerProfile?.arenaId ?? null
    const storeIds = storeOwnerProfile?.stores.map((store) => store.id) ?? []
    const availableProfiles = [
      ...(academyId ? ['ACADEMY'] : []),
      ...(coachProfile ? ['COACH'] : []),
      ...(arenaId ? ['ARENA'] : []),
      ...(managedArenaId ? ['ARENA_MANAGER'] : []),
      ...(storeIds.length > 0 ? ['STORE'] : []),
    ]

    return {
      businessAccount,
      businessStatus: {
        hasBusinessAccount: !!businessAccount,
        businessAccountId: businessAccount?.id ?? null,
        availableProfiles,
        academyId,
        coachProfileId: coachProfile?.id ?? null,
        arenaId,
        managedArenaId,
        storeIds,
        storeAvailable: storeIds.length > 0,
      },
    }
  }

  async checkPhone(phone: string) {
    const normalizedPhone = normalizePhone(phone)
    const user = await prisma.user.findUnique({
      where: { phone: normalizedPhone },
      select: { id: true, name: true },
    })

    return {
      exists: user != null,
      normalizedPhone,
      user: user == null
          ? null
          : {
              id: user.id,
              name: user.name,
            },
    }
  }

  /**
   * Client completes Firebase Phone Auth, sends the resulting ID token here.
   * We verify it with Firebase Admin SDK, then issue our own JWT + refresh token.
   */
  async loginWithFirebase(idToken: string, name?: string, language?: string, initialRole?: string) {
    // Verify the Firebase ID token — throws if invalid/expired
    const { phone: rawPhone, email, uid } = await verifyFirebaseToken(idToken)

    let user
    let isNewUser = false

    if (rawPhone) {
      // Phone-based auth (standard user flow)
      const phone = normalizePhone(rawPhone)
      console.log('[auth] login attempt — normalized phone:', phone)
      user = await prisma.user.findUnique({ where: { phone } })
      console.log('[auth] user found:', user ? `id=${user.id} name=${user.name}` : 'NOT FOUND')
      isNewUser = !user

      if (!user) {
        if (!name) throw new AppError('NAME_REQUIRED', 'Name is required for new users', 400)
        const role = (initialRole || 'PLAYER') as UserRole
        user = await prisma.user.create({
          data: {
            phone,
            name,
            language: language || 'en',
            roles: [role],
            activeRole: role,
          },
        })
        await prisma.playerProfile.create({ data: { userId: user.id } })
      } else {
        // If this is a pre-created stub account (name is placeholder), update with real name
        const updateData: any = {}
        if (name && user.name === 'Coach') updateData.name = name
        if (language && !user.language) updateData.language = language
        if (Object.keys(updateData).length > 0) {
          user = await prisma.user.update({ where: { id: user.id }, data: updateData })
        }
      }
    } else {
      // Email-based auth (admin/support accounts only)
      if (!email) throw new AppError('AUTH_ERROR', 'No phone or email in Firebase token', 400)
      console.log('[auth] email login attempt:', email)
      user = await prisma.user.findUnique({ where: { email } })
      if (!user) throw new AppError('USER_NOT_FOUND', 'No account found for this email', 404)
      if (!user.roles.includes('SWING_ADMIN' as any) && !user.roles.includes('SWING_SUPPORT' as any)) {
        throw new AppError('FORBIDDEN', 'Email login is only permitted for admin accounts', 403)
      }
    }

    if (user.isBanned) throw new AppError('ACCOUNT_BANNED', `Account banned: ${user.banReason}`, 403)
    if (user.isBlocked) throw new AppError('ACCOUNT_BLOCKED', `Account blocked: ${user.blockedReason}`, 403)

    await prisma.user.update({ where: { id: user.id }, data: { lastLoginAt: new Date() } })

    // Fetch all profile data needed for profile status
    const fullUser = await prisma.user.findUnique({
      where: { id: user.id },
      include: {
        arenaOwnerProfile: { include: { arenas: { select: { id: true }, take: 1 } } },
        academyOwnerProfile: { include: { academies: { select: { id: true }, take: 1 } } },
        coachProfile: { select: { id: true } },
        arenaManagerProfiles: { select: { arenaId: true }, take: 1 },
      },
    })

    const arenaId = fullUser?.arenaOwnerProfile?.arenas[0]?.id ?? null
    const academyId = fullUser?.academyOwnerProfile?.academies?.[0]?.id ?? null
    const managedArenaId = fullUser?.arenaManagerProfiles?.[0]?.arenaId ?? null

    const profileStatus = {
      hasArenaProfile: !!arenaId,
      hasAcademyProfile: !!academyId,
      hasCoachProfile: !!fullUser?.coachProfile,
      hasManagerProfile: !!managedArenaId,
    }

    const payload = buildJwtPayload(user.id, user.activeRole, user.roles)
    const accessToken = signAccessToken(payload)

    const rawRefresh = generateRefreshToken()
    const hashedRefresh = hashToken(rawRefresh)
    const expiresAt = new Date(Date.now() + REFRESH_TOKEN_DAYS * 24 * 60 * 60 * 1000)

    await prisma.refreshToken.create({
      data: { userId: user.id, token: hashedRefresh, expiresAt },
    })

    return {
      accessToken,
      refreshToken: rawRefresh,
      expiresIn: 900,
      isNewUser,
      user: {
        id: user.id,
        name: user.name,
        phone: user.phone,
        activeRole: user.activeRole,
        roles: user.roles,
        arenaId,
        academyId,
        managedArenaId,
        profileStatus,
      },
    }
  }

  async loginWithPhone(phone: string, sessionId: string, otp: string, name?: string, language?: string) {
    const apiKey = process.env.TWOFACTOR_API_KEY
    if (!apiKey) throw new AppError('CONFIG_ERROR', 'OTP service not configured', 500)

    const verifyUrl = `https://2factor.in/API/V1/${apiKey}/SMS/VERIFY/${sessionId}/${otp}`
    const resp = await fetch(verifyUrl)
    const verifyData = await resp.json() as any
    if (verifyData.Status !== 'Success' || verifyData.Details !== 'OTP Matched') {
      throw new AppError('OTP_INVALID', 'Invalid or expired OTP', 400)
    }

    const normalizedPhone = normalizePhone(phone)
    let user = await prisma.user.findUnique({ where: { phone: normalizedPhone } })
    const isNewUser = !user

    if (!user) {
      if (!name) throw new AppError('NAME_REQUIRED', 'Name is required for new business users', 400)
      user = await prisma.user.create({
        data: {
          phone: normalizedPhone,
          name,
          language: language || 'en',
          roles: [UserRole.BUSINESS_OWNER],
          activeRole: UserRole.BUSINESS_OWNER,
        },
      })
    } else {
      const updateData: any = { lastLoginAt: new Date(), activeRole: UserRole.BUSINESS_OWNER }
      if (!user.roles.includes(UserRole.BUSINESS_OWNER)) {
        updateData.roles = { push: UserRole.BUSINESS_OWNER }
      }
      if (name && user.name === 'Coach') updateData.name = name
      if (language && !user.language) updateData.language = language
      user = await prisma.user.update({ where: { id: user.id }, data: updateData })
    }

    if (user.isBanned) throw new AppError('ACCOUNT_BANNED', `Account banned: ${user.banReason}`, 403)
    if (user.isBlocked) throw new AppError('ACCOUNT_BLOCKED', `Account blocked: ${user.blockedReason}`, 403)

    if (isNewUser) {
      await prisma.user.update({ where: { id: user.id }, data: { lastLoginAt: new Date() } })
    }

    const { businessAccount, businessStatus } = await this.getBusinessStatus(user.id)
    const tokens = await this.issueTokens(user)

    return {
      ...tokens,
      isNewUser,
      user: {
        id: user.id,
        name: user.name,
        phone: user.phone,
        activeRole: user.activeRole,
        roles: user.roles,
      },
      businessAccount,
      businessStatus,
    }
  }

  async loginWithFirebaseForBiz(idToken: string, name?: string, language?: string) {
    const { phone: rawPhone } = await verifyFirebaseToken(idToken)
    if (!rawPhone) throw new AppError('PHONE_REQUIRED', 'Swing-Biz login requires phone authentication', 400)

    const phone = normalizePhone(rawPhone)
    let user = await prisma.user.findUnique({ where: { phone } })
    const isNewUser = !user

    if (!user) {
      if (!name) throw new AppError('NAME_REQUIRED', 'Name is required for new business users', 400)
      user = await prisma.user.create({
        data: {
          phone,
          name,
          language: language || 'en',
          roles: [UserRole.BUSINESS_OWNER],
          activeRole: UserRole.BUSINESS_OWNER,
        },
      })
    } else {
      const updateData: any = { lastLoginAt: new Date(), activeRole: UserRole.BUSINESS_OWNER }
      if (!user.roles.includes(UserRole.BUSINESS_OWNER)) {
        updateData.roles = { push: UserRole.BUSINESS_OWNER }
      }
      if (name && user.name === 'Coach') updateData.name = name
      if (language && !user.language) updateData.language = language
      user = await prisma.user.update({ where: { id: user.id }, data: updateData })
    }

    if (user.isBanned) throw new AppError('ACCOUNT_BANNED', `Account banned: ${user.banReason}`, 403)
    if (user.isBlocked) throw new AppError('ACCOUNT_BLOCKED', `Account blocked: ${user.blockedReason}`, 403)

    if (isNewUser) {
      await prisma.user.update({ where: { id: user.id }, data: { lastLoginAt: new Date() } })
    }

    const { businessAccount, businessStatus } = await this.getBusinessStatus(user.id)
    const tokens = await this.issueTokens(user)

    return {
      ...tokens,
      isNewUser,
      user: {
        id: user.id,
        name: user.name,
        phone: user.phone,
        activeRole: user.activeRole,
        roles: user.roles,
      },
      businessAccount,
      businessStatus,
    }
  }

  async refreshTokens(rawRefreshToken: string) {
    const hashed = hashToken(rawRefreshToken)
    const tokenRecord = await prisma.refreshToken.findUnique({
      where: { token: hashed },
      include: { user: true },
    })

    if (!tokenRecord || tokenRecord.revokedAt || tokenRecord.expiresAt < new Date()) {
      throw new AppError('REFRESH_TOKEN_INVALID', 'Invalid or expired refresh token', 401)
    }

    const { user } = tokenRecord
    if (!user.isActive || user.isBanned) throw new AppError('ACCOUNT_SUSPENDED', 'Account is suspended', 403)

    // Rotate: revoke old, issue new
    await prisma.refreshToken.update({ where: { id: tokenRecord.id }, data: { revokedAt: new Date() } })

    const payload = buildJwtPayload(user.id, user.activeRole, user.roles)
    const accessToken = signAccessToken(payload)

    const rawRefresh = generateRefreshToken()
    const hashedRefresh = hashToken(rawRefresh)
    const expiresAt = new Date(Date.now() + REFRESH_TOKEN_DAYS * 24 * 60 * 60 * 1000)

    await prisma.refreshToken.create({ data: { userId: user.id, token: hashedRefresh, expiresAt } })

    return { accessToken, refreshToken: rawRefresh, expiresIn: 900 }
  }

  async logout(rawRefreshToken: string) {
    const hashed = hashToken(rawRefreshToken)
    await prisma.refreshToken.updateMany({ where: { token: hashed }, data: { revokedAt: new Date() } })
  }

  async switchRole(userId: string, newRole: string) {
    // B2B roles can be self-claimed — a player can also be a coach, academy owner, or arena manager
    const claimableRoles: UserRole[] = [UserRole.COACH, UserRole.ACADEMY_OWNER, UserRole.ARENA_OWNER]

    // Read fresh roles from DB (JWT may be stale)
    const freshUser = await prisma.user.findUnique({ where: { id: userId }, select: { roles: true } })
    if (!freshUser) throw new AppError('USER_NOT_FOUND', 'User not found', 404)

    const hasRole = freshUser.roles.includes(newRole as UserRole)

    if (!hasRole) {
      if (!claimableRoles.includes(newRole as UserRole)) {
        throw new AppError('ROLE_NOT_ASSIGNED', `You do not have the ${newRole} role`, 403)
      }
      // Add the claimable role if not already present
      await prisma.user.update({
        where: { id: userId },
        data: { roles: { push: newRole as UserRole } },
      })
    }

    const user = await prisma.user.update({
      where: { id: userId },
      data: { activeRole: newRole as UserRole },
    })

    const payload = buildJwtPayload(user.id, user.activeRole, user.roles)
    const accessToken = signAccessToken(payload)

    return { accessToken, expiresIn: 900, activeRole: user.activeRole }
  }
}
