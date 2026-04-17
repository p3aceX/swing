import { prisma } from '@swing/db'
import bcrypt from 'bcryptjs'
import { AppError } from '../../lib/errors'
import { signAdminToken, buildJwtPayload } from '../../lib/jwt'

export class AdminAuthService {
  async login(email: string, password: string) {
    const admin = await prisma.adminUser.findUnique({ where: { email } })
    if (!admin || !admin.isActive) throw new AppError('INVALID_CREDENTIALS', 'Invalid email or password', 401)

    const valid = await bcrypt.compare(password, admin.passwordHash)
    if (!valid) throw new AppError('INVALID_CREDENTIALS', 'Invalid email or password', 401)

    const payload = buildJwtPayload(admin.id, admin.role, [admin.role])
    const accessToken = signAdminToken(payload)

    return {
      accessToken,
      user: { id: admin.id, name: admin.name, email: admin.email, role: admin.role },
    }
  }

  async listAdmins() {
    return prisma.adminUser.findMany({
      select: { id: true, email: true, name: true, role: true, isActive: true, createdAt: true },
      orderBy: { createdAt: 'asc' },
    })
  }

  async createAdmin(email: string, password: string, name: string, role: string = 'SWING_ADMIN') {
    const existing = await prisma.adminUser.findUnique({ where: { email } })
    if (existing) throw new AppError('ALREADY_EXISTS', 'Admin with this email already exists', 409)

    const passwordHash = await bcrypt.hash(password, 12)
    return prisma.adminUser.create({
      data: { email, passwordHash, name, role },
      select: { id: true, email: true, name: true, role: true, isActive: true, createdAt: true },
    })
  }

  async updateAdmin(id: string, data: { name?: string; role?: string; password?: string; isActive?: boolean }) {
    const admin = await prisma.adminUser.findUnique({ where: { id } })
    if (!admin) throw new AppError('NOT_FOUND', 'Admin not found', 404)

    const update: any = {}
    if (data.name) update.name = data.name
    if (data.role) update.role = data.role
    if (data.isActive !== undefined) update.isActive = data.isActive
    if (data.password) update.passwordHash = await bcrypt.hash(data.password, 12)

    return prisma.adminUser.update({
      where: { id },
      data: update,
      select: { id: true, email: true, name: true, role: true, isActive: true, createdAt: true },
    })
  }

  async deleteAdmin(id: string) {
    const admin = await prisma.adminUser.findUnique({ where: { id } })
    if (!admin) throw new AppError('NOT_FOUND', 'Admin not found', 404)
    await prisma.adminUser.delete({ where: { id } })
    return { message: 'Admin deleted' }
  }
}
