import { prisma } from "@swing/db";
import { AppError, Errors } from "../../lib/errors";

const META_MARKER = "\n\n---SWING_EVENT_META---\n";

type EventInput = {
  name: string;
  eventType?: string;
  description?: string;
  venueName?: string;
  city?: string;
  scheduledAt?: string;
  isPublic?: boolean;
  maxParticipants?: number;
  rules?: string;
  prizePool?: string;
  status?: string;
};

function splitDescription(raw: string | null | undefined) {
  if (!raw) return { description: null as string | null, metadata: {} as Record<string, unknown> };
  const [descriptionPart, metadataPart] = raw.split(META_MARKER);
  if (!metadataPart) return { description: descriptionPart.trim() || null, metadata: {} };
  try {
    return {
      description: descriptionPart.trim() || null,
      metadata: JSON.parse(metadataPart) as Record<string, unknown>,
    };
  } catch {
    return { description: raw.trim() || null, metadata: {} };
  }
}

function buildDescription(description?: string, metadata?: Record<string, unknown>) {
  const cleanDescription = description?.trim() || "";
  const cleanMetadata = Object.fromEntries(
    Object.entries(metadata ?? {}).filter(([, value]) => value !== undefined && value !== null && value !== ""),
  );
  if (Object.keys(cleanMetadata).length === 0) return cleanDescription || null;
  return `${cleanDescription}${META_MARKER}${JSON.stringify(cleanMetadata)}`;
}

export class EventService {
  private normalizeEventRecord(event: any) {
    const { description, metadata } = splitDescription(event.description)
    return {
      ...event,
      description,
      maxParticipants: typeof metadata.maxParticipants === "number" ? metadata.maxParticipants : null,
      rules: typeof metadata.rules === "string" ? metadata.rules : null,
      prizePool: typeof metadata.prizePool === "string" ? metadata.prizePool : null,
    }
  }

  async listHostedEvents(userId: string) {
    const events = await prisma.event.findMany({
      where: { createdByUserId: userId },
      orderBy: { createdAt: "desc" },
    })
    return { events: events.map((event) => this.normalizeEventRecord(event)) }
  }

  async createHostedEvent(userId: string, input: EventInput) {
    const scheduledAt = input.scheduledAt ? new Date(input.scheduledAt) : null
    if (scheduledAt && Number.isNaN(scheduledAt.getTime())) {
      throw new AppError("INVALID_EVENT_DATE", "Invalid event schedule", 400)
    }

    const event = await prisma.event.create({
      data: {
        createdByUserId: userId,
        name: input.name.trim(),
        eventType: input.eventType || "CUSTOM",
        description: buildDescription(input.description, {
          maxParticipants: input.maxParticipants,
          rules: input.rules?.trim() || undefined,
          prizePool: input.prizePool?.trim() || undefined,
        }),
        venueName: input.venueName?.trim() || null,
        city: input.city?.trim() || null,
        scheduledAt,
        isPublic: input.isPublic ?? true,
        status: input.status ?? "UPCOMING",
      },
    })
    return this.normalizeEventRecord(event)
  }

  async updateHostedEvent(userId: string, eventId: string, input: EventInput) {
    const existing = await prisma.event.findUnique({ where: { id: eventId } })
    if (!existing) throw Errors.notFound("Event")
    if (existing.createdByUserId !== userId) throw Errors.forbidden()

    const parsedExisting = splitDescription(existing.description)
    const nextScheduledAt = input.scheduledAt === undefined
      ? existing.scheduledAt
      : input.scheduledAt
        ? new Date(input.scheduledAt)
        : null

    if (nextScheduledAt && Number.isNaN(nextScheduledAt.getTime())) {
      throw new AppError("INVALID_EVENT_DATE", "Invalid event schedule", 400)
    }

    const updated = await prisma.event.update({
      where: { id: eventId },
      data: {
        name: input.name?.trim() || existing.name,
        eventType: input.eventType || existing.eventType,
        description: buildDescription(
          input.description ?? parsedExisting.description ?? undefined,
          {
            maxParticipants: input.maxParticipants ?? parsedExisting.metadata.maxParticipants,
            rules: input.rules ?? parsedExisting.metadata.rules,
            prizePool: input.prizePool ?? parsedExisting.metadata.prizePool,
          },
        ),
        venueName: input.venueName === undefined ? existing.venueName : (input.venueName?.trim() || null),
        city: input.city === undefined ? existing.city : (input.city?.trim() || null),
        scheduledAt: nextScheduledAt,
        isPublic: input.isPublic ?? existing.isPublic,
        status: input.status ?? existing.status,
      },
    })
    return this.normalizeEventRecord(updated)
  }

  async listAdminEvents(params: { page: number; limit: number; search?: string; status?: string }) {
    const page = Math.max(1, params.page || 1)
    const limit = Math.min(100, Math.max(1, params.limit || 25))
    const where = {
      ...(params.status ? { status: params.status } : {}),
      ...(params.search
        ? {
            OR: [
              { name: { contains: params.search, mode: "insensitive" as const } },
              { venueName: { contains: params.search, mode: "insensitive" as const } },
              { city: { contains: params.search, mode: "insensitive" as const } },
            ],
          }
        : {}),
    }

    const [events, total] = await Promise.all([
      prisma.event.findMany({
        where,
        include: {
          createdBy: { select: { id: true, name: true } },
        },
        orderBy: { createdAt: "desc" },
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.event.count({ where }),
    ])

    return {
      events: events.map((event) => ({
        ...this.normalizeEventRecord(event),
        createdByUser: event.createdBy,
      })),
      total,
      page,
      limit,
    }
  }

  async searchEvents(query: string, limit: number) {
    return prisma.event.findMany({
      where: {
        OR: [
          { name:      { contains: query, mode: 'insensitive' } },
          { city:      { contains: query, mode: 'insensitive' } },
          { venueName: { contains: query, mode: 'insensitive' } },
        ],
        isPublic: true,
      },
      select: {
        id: true, name: true, eventType: true, city: true,
        venueName: true, scheduledAt: true, status: true,
      },
      orderBy: { scheduledAt: 'desc' },
      take: limit,
    })
  }
}
