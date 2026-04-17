import { prisma } from '@swing/db'
import { Errors } from '../../lib/errors'

export class CurriculumService {
  private async verifyAcademyOwner(userId: string, academyId: string) {
    const owner = await prisma.academyOwnerProfile.findUnique({ where: { userId } })
    if (!owner) throw Errors.forbidden()
    const academy = await prisma.academy.findFirst({ where: { id: academyId, ownerId: owner.id } })
    if (!academy) throw Errors.forbidden()
    return { owner, academy }
  }

  private async verifyCoachAccess(userId: string, academyId: string) {
    const coach = await prisma.coachProfile.findUnique({ where: { userId } })
    if (!coach) throw Errors.forbidden()
    const link = await prisma.academyCoach.findUnique({
      where: { academyId_coachId: { academyId, coachId: coach.id } },
    })
    if (!link || !link.isActive) throw Errors.forbidden()
    return coach
  }

  // Create a curriculum (academy owner only)
  async createCurriculum(userId: string, academyId: string, data: {
    name: string
    targetAgeGroup?: string
    targetSkillLevel?: string
    sportFocus?: string
    description?: string
    totalWeeks?: number
  }) {
    await this.verifyAcademyOwner(userId, academyId)
    return prisma.curriculum.create({
      data: { ...data, academyId },
      include: { phases: { include: { topics: true } } },
    })
  }

  // List all curriculums for an academy (plus platform templates)
  async listCurriculums(userId: string, academyId: string) {
    // Both coaches and owners can view
    const coachProfile = await prisma.coachProfile.findUnique({ where: { userId } })
    const ownerProfile = await prisma.academyOwnerProfile.findUnique({ where: { userId } })
    if (!coachProfile && !ownerProfile) throw Errors.forbidden()

    return prisma.curriculum.findMany({
      where: {
        OR: [
          { academyId, isActive: true },
          { isTemplate: true, isActive: true },
        ],
      },
      include: {
        phases: {
          include: { topics: { orderBy: { sequence: 'asc' } } },
          orderBy: { phaseNumber: 'asc' },
        },
        _count: { select: { batchAssignments: true } },
      },
      orderBy: { createdAt: 'desc' },
    })
  }

  // Get a single curriculum with full detail
  async getCurriculum(curriculumId: string) {
    const c = await prisma.curriculum.findUnique({
      where: { id: curriculumId },
      include: {
        phases: {
          include: { topics: { orderBy: { sequence: 'asc' } } },
          orderBy: { phaseNumber: 'asc' },
        },
      },
    })
    if (!c) throw Errors.notFound('Curriculum')
    return c
  }

  // Add a phase to a curriculum
  async addPhase(userId: string, curriculumId: string, data: {
    phaseNumber: number
    name: string
    durationWeeks?: number
    description?: string
  }) {
    const curriculum = await prisma.curriculum.findUnique({ where: { id: curriculumId } })
    if (!curriculum || !curriculum.academyId) throw Errors.notFound('Curriculum')
    await this.verifyAcademyOwner(userId, curriculum.academyId)
    return prisma.curriculumPhase.create({
      data: { curriculumId, ...data, durationWeeks: data.durationWeeks ?? 4 },
      include: { topics: true },
    })
  }

  // Add a topic to a phase
  async addTopic(userId: string, phaseId: string, data: {
    name: string
    sequence: number
    skillArea?: string
    subSkill?: string
    description?: string
    suggestedDrills?: string[]
  }) {
    const phase = await prisma.curriculumPhase.findUnique({
      where: { id: phaseId },
      include: { curriculum: true },
    })
    if (!phase || !phase.curriculum.academyId) throw Errors.notFound('Phase')
    await this.verifyAcademyOwner(userId, phase.curriculum.academyId)
    return prisma.curriculumTopic.create({ data: { phaseId, ...data } })
  }

  // Assign a curriculum to a batch
  async assignToBatch(userId: string, batchId: string, curriculumId: string, startDate: string) {
    const batch = await prisma.batch.findUnique({ where: { id: batchId } })
    if (!batch) throw Errors.notFound('Batch')
    await this.verifyAcademyOwner(userId, batch.academyId)

    return prisma.batchCurriculumAssignment.upsert({
      where: { batchId },
      create: {
        batchId,
        curriculumId,
        startDate: new Date(startDate),
        currentPhase: 1,
        currentTopic: 1,
        isActive: true,
      },
      update: {
        curriculumId,
        startDate: new Date(startDate),
        isActive: true,
        updatedAt: new Date(),
      },
      include: {
        curriculum: { include: { phases: { orderBy: { phaseNumber: 'asc' as const }, include: { topics: { orderBy: { sequence: 'asc' as const } } } } } },
        completions: true,
      },
    })
  }

  // Get curriculum assignment for a batch (with progress)
  async getBatchCurriculum(userId: string, batchId: string) {
    // coaches and owners can view
    const batch = await prisma.batch.findUnique({ where: { id: batchId } })
    if (!batch) throw Errors.notFound('Batch')

    const assignment = await prisma.batchCurriculumAssignment.findUnique({
      where: { batchId },
      include: {
        curriculum: {
          include: {
            phases: {
              include: { topics: { orderBy: { sequence: 'asc' } } },
              orderBy: { phaseNumber: 'asc' },
            },
          },
        },
        completions: {
          include: { topic: true },
          orderBy: { completedAt: 'desc' },
        },
      },
    })

    if (!assignment) return null

    // Calculate completion stats
    const allTopics = assignment.curriculum.phases.flatMap((p) => p.topics)
    const completedTopicIds = new Set(assignment.completions.map((c) => c.topicId))
    const completionPercent = allTopics.length > 0
      ? Math.round((completedTopicIds.size / allTopics.length) * 100)
      : 0

    const laggingTopics = allTopics.filter((t) => {
      const phase = assignment.curriculum.phases.find((p) => p.id === t.phaseId)!
      const expectedCompleteByWeek = (phase.phaseNumber - 1) * (phase.durationWeeks || 4) + t.sequence
      const weeksSinceStart = Math.floor(
        (Date.now() - new Date(assignment.startDate).getTime()) / (7 * 86400000),
      )
      return weeksSinceStart >= expectedCompleteByWeek && !completedTopicIds.has(t.id)
    })

    return {
      ...assignment,
      completionPercent,
      completedCount: completedTopicIds.size,
      totalTopics: allTopics.length,
      laggingTopics,
    }
  }

  // Mark a topic as complete (coach only)
  async markTopicComplete(userId: string, assignmentId: string, topicId: string, coachNote?: string) {
    const assignment = await prisma.batchCurriculumAssignment.findUnique({
      where: { id: assignmentId },
      include: { batch: true },
    })
    if (!assignment) throw Errors.notFound('Assignment')
    const coach = await this.verifyCoachAccess(userId, assignment.batch.academyId)

    return prisma.topicCompletion.upsert({
      where: { assignmentId_topicId: { assignmentId, topicId } },
      create: { assignmentId, topicId, coachId: coach.id, coachNote },
      update: { completedAt: new Date(), coachNote },
    })
  }

  // Unmark a topic (coach can undo)
  async unmarkTopicComplete(userId: string, assignmentId: string, topicId: string) {
    const assignment = await prisma.batchCurriculumAssignment.findUnique({
      where: { id: assignmentId },
      include: { batch: true },
    })
    if (!assignment) throw Errors.notFound('Assignment')
    await this.verifyCoachAccess(userId, assignment.batch.academyId)

    return prisma.topicCompletion.deleteMany({ where: { assignmentId, topicId } })
  }
}
