import { OverlayPackKind, Prisma, prisma } from "@swing/db";
import { AppError, Errors } from "../../lib/errors";

const DEFAULT_OVERLAY_PACK_CODE = "default-overlay";

function makeCode(value: string) {
  return value
    .toLowerCase()
    .replace(/[^a-z0-9\s-]/g, "")
    .trim()
    .replace(/\s+/g, "-")
    .replace(/-+/g, "-")
    .slice(0, 60);
}

function toJsonConfig(config?: Record<string, unknown>) {
  if (config === undefined) return undefined;
  return config as Prisma.InputJsonValue;
}

export class OverlayPackService {
  async ensureDefaultPack() {
    return prisma.overlayPack.upsert({
      where: { code: DEFAULT_OVERLAY_PACK_CODE },
      create: {
        code: DEFAULT_OVERLAY_PACK_CODE,
        name: "Default Overlay",
        kind: OverlayPackKind.DEFAULT,
        description: "Base overlay pack used across all Swing Live matches.",
        isActive: true,
        isDefault: true,
      },
      update: {
        name: "Default Overlay",
        kind: OverlayPackKind.DEFAULT,
        isActive: true,
        isDefault: true,
      },
    });
  }

  async listPacks() {
    await this.ensureDefaultPack();
    return prisma.overlayPack.findMany({
      orderBy: [{ isDefault: "desc" }, { createdAt: "asc" }],
    });
  }

  async createPack(input: {
    name: string;
    kind?: OverlayPackKind;
    description?: string | null;
    code?: string | null;
    isActive?: boolean;
    isDefault?: boolean;
    config?: Record<string, unknown>;
  }) {
    const code = makeCode(input.code?.trim() || input.name);
    if (!code) {
      throw new AppError(
        "INVALID_OVERLAY_PACK_CODE",
        "Overlay pack code is required",
        400,
      );
    }

    return prisma.$transaction(async (tx) => {
      if (input.isDefault) {
        await tx.overlayPack.updateMany({
          where: { isDefault: true },
          data: { isDefault: false },
        });
      }

      return tx.overlayPack.create({
        data: {
          code,
          name: input.name.trim(),
          kind: input.kind ?? OverlayPackKind.CUSTOM,
          description: input.description?.trim() || null,
          isActive: input.isActive ?? true,
          isDefault: input.isDefault ?? false,
          config: toJsonConfig(input.config) ?? {},
        },
      });
    });
  }

  async updatePack(
    overlayPackId: string,
    input: {
      name?: string;
      kind?: OverlayPackKind;
      description?: string | null;
      code?: string | null;
      isActive?: boolean;
      isDefault?: boolean;
      config?: Record<string, unknown>;
    },
  ) {
    const existing = await prisma.overlayPack.findUnique({
      where: { id: overlayPackId },
    });
    if (!existing) throw Errors.notFound("Overlay pack");

    const nextCode =
      input.code !== undefined
        ? makeCode(input.code ?? existing.code)
        : undefined;

    return prisma.$transaction(async (tx) => {
      if (input.isDefault) {
        await tx.overlayPack.updateMany({
          where: { isDefault: true, id: { not: overlayPackId } },
          data: { isDefault: false },
        });
      }

      return tx.overlayPack.update({
        where: { id: overlayPackId },
        data: {
          ...(nextCode ? { code: nextCode } : {}),
          ...(input.name !== undefined ? { name: input.name.trim() } : {}),
          ...(input.kind !== undefined ? { kind: input.kind } : {}),
          ...(input.description !== undefined
            ? { description: input.description?.trim() || null }
            : {}),
          ...(input.isActive !== undefined ? { isActive: input.isActive } : {}),
          ...(input.isDefault !== undefined
            ? { isDefault: input.isDefault }
            : {}),
          ...(input.config !== undefined
            ? { config: toJsonConfig(input.config) }
            : {}),
        },
      });
    });
  }

  async assignToMatch(matchId: string, overlayPackId: string | null) {
    await this.assertPackExistsIfProvided(overlayPackId);
    return prisma.match.update({
      where: { id: matchId },
      data: { overlayPackId },
      include: {
        overlayPack: true,
      },
    });
  }

  async assignToTournament(tournamentId: string, overlayPackId: string | null) {
    await this.assertPackExistsIfProvided(overlayPackId);
    return prisma.tournament.update({
      where: { id: tournamentId },
      data: { overlayPackId },
      include: {
        overlayPack: true,
      },
    });
  }

  async resolveEffectivePackForMatch(matchId: string) {
    await this.ensureDefaultPack();

    const match = await prisma.match.findUnique({
      where: { id: matchId },
      select: {
        id: true,
        tournamentId: true,
        overlayPack: true,
      },
    });
    if (!match) throw Errors.notFound("Match");

    if (match.overlayPack?.isActive) {
      return { source: "MATCH" as const, pack: match.overlayPack };
    }

    if (match.tournamentId) {
      const tournament = await prisma.tournament.findUnique({
        where: { id: match.tournamentId },
        include: { overlayPack: true },
      });
      if (tournament?.overlayPack?.isActive) {
        return { source: "TOURNAMENT" as const, pack: tournament.overlayPack };
      }
    }

    const defaultPack = await prisma.overlayPack.findFirst({
      where: { isDefault: true, isActive: true },
      orderBy: { createdAt: "asc" },
    });
    if (!defaultPack) throw Errors.notFound("Default overlay pack");

    return { source: "DEFAULT" as const, pack: defaultPack };
  }

  private async assertPackExistsIfProvided(overlayPackId: string | null) {
    if (!overlayPackId) return;
    const pack = await prisma.overlayPack.findUnique({
      where: { id: overlayPackId },
      select: { id: true },
    });
    if (!pack) throw Errors.notFound("Overlay pack");
  }
}
