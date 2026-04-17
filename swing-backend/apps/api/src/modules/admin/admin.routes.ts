import { FastifyInstance } from "fastify";
import { z } from "zod";
import { OverlayPackKind, prisma, TriggerEventType } from "@swing/db";
import {
  adminCreateMatchRequestSchema,
  createTournamentRequestSchema,
  recordBallRequestSchema,
} from "@swing/contracts";
import { AdminService } from "./admin.service";
import { AdminAuthService } from "./admin.auth";
import { DevelopmentService } from "../development/development.service";
import { StudioService } from "../studio/studio.service";
import { OverlayPackService } from "../overlays/overlay-pack.service";
import { PerformanceService } from "../performance/performance.service";
import { getStudioScene, setStudioScene } from "../../lib/redis";
import { MatchService } from "../matches/match.service";
import { EventService } from "../events/event.service";
import { AppError } from "../../lib/errors";
import { applySeasonReset, applyRankDecay } from "../performance/ip-engine";
import axios from "axios";

const STUDIO_SERVICE_URL = process.env.STUDIO_SERVICE_URL || "http://localhost:4000";
const studioService = new StudioService();
const overlayPackService = new OverlayPackService();
const performanceSvc = new PerformanceService();

// The public WSS URL the camera page should connect to.
// Routes through this API (Cloud Run, already HTTPS) so no TLS is needed on the studio VM.
const publicBaseUrl = (process.env.PUBLIC_BASE_URL || "https://swing-backend-nbid5gga4q-el.a.run.app").replace(/\/$/, "");
const STUDIO_WS_URL = publicBaseUrl.replace(/^https:/, "wss:").replace(/^http:/, "ws:") + "/studio/ws";

const phoneSchema = z
  .string()
  .regex(/^\d{10}$/, "Phone number must be exactly 10 digits");

function fireStudioEvent(matchId: string, eventType: TriggerEventType) {
  void studioService.triggerEvent(matchId, eventType).catch((error) => {
    console.error("[studio] trigger event failed", { matchId, eventType, error });
  });
}

export async function adminRoutes(app: FastifyInstance) {
  const svc = new AdminService();
  const matchSvc = new MatchService();
  const eventSvc = new EventService();
  const authSvc = new AdminAuthService();
  const developmentSvc = new DevelopmentService();
  const auth = { onRequest: [(app as any).authenticate] };

  app.get("/dashboard", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const query = z
      .object({
        period: z.enum(["today", "week", "month", "ytd"]).optional(),
      })
      .parse(request.query ?? {});
    return reply.send({
      success: true,
      data: await svc.getDashboard(user.userId, query.period ?? "month"),
    });
  });

  app.get("/users", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const q = request.query as {
      role?: string;
      search?: string;
      blocked?: string;
      page?: string;
      limit?: string;
    };
    return reply.send({
      success: true,
      data: await svc.listUsers(user.userId, {
        role: q.role,
        search: q.search,
        blocked:
          q.blocked === "true" ? true : q.blocked === "false" ? false : undefined,
        page: Number(q.page) || 1,
        limit: Number(q.limit) || 20,
      }),
    });
  });

  app.get("/users/:id", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    return reply.send({
      success: true,
      data: await svc.getUser(user.userId, id),
    });
  });

  app.post("/users", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const body = z
      .object({
        name: z.string().min(2),
        phone: phoneSchema,
        email: z.string().email().optional().or(z.literal("")),
        roles: z
          .array(
            z.enum([
              "PLAYER",
              "COACH",
              "ACADEMY_OWNER",
              "ARENA_OWNER",
              "PARENT",
              "SWING_ADMIN",
              "SWING_SUPPORT",
            ]),
          )
          .min(1),
        activeRole: z
          .enum([
            "PLAYER",
            "COACH",
            "ACADEMY_OWNER",
            "ARENA_OWNER",
            "PARENT",
            "SWING_ADMIN",
            "SWING_SUPPORT",
          ])
          .optional(),
        isVerified: z.boolean().optional(),
        isActive: z.boolean().optional(),
        createProfiles: z
          .array(z.enum(["PLAYER", "COACH", "ACADEMY_OWNER", "ARENA_OWNER"]))
          .optional(),
        playerProfile: z
          .object({
            city: z.string().optional(),
            state: z.string().optional(),
            bio: z.string().optional(),
            goals: z.string().optional(),
            level: z.string().optional(),
            playerRole: z.string().optional(),
            battingStyle: z.string().optional(),
            bowlingStyle: z.string().optional(),
            dateOfBirth: z.string().optional(),
            jerseyNumber: z.number().int().optional(),
          })
          .optional(),
        coachProfile: z
          .object({
            city: z.string().optional(),
            state: z.string().optional(),
            bio: z.string().optional(),
            experienceYears: z.number().int().min(0).optional(),
            specializations: z.array(z.string()).optional(),
          })
          .optional(),
        arenaOwnerProfile: z
          .object({
            businessName: z.string().optional(),
            gstNumber: z.string().optional(),
            panNumber: z.string().optional(),
          })
          .optional(),
      })
      .parse(request.body);
    return reply.code(201).send({
      success: true,
      data: await svc.createUser(user.userId, {
        ...body,
        email: body.email || undefined,
      }),
    });
  });

  app.patch("/users/:id", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    const body = z
      .object({
        name: z.string().min(2).optional(),
        phone: phoneSchema.optional(),
        email: z.string().email().nullable().optional().or(z.literal("")),
        activeRole: z
          .enum([
            "PLAYER",
            "COACH",
            "ACADEMY_OWNER",
            "ARENA_OWNER",
            "PARENT",
            "SWING_ADMIN",
            "SWING_SUPPORT",
          ])
          .optional(),
        isVerified: z.boolean().optional(),
        isActive: z.boolean().optional(),
        avatarUrl: z.string().url().nullable().optional().or(z.literal("")),
      })
      .parse(request.body);
    return reply.send({
      success: true,
      data: await svc.updateUser(user.userId, id, {
        ...body,
        email: body.email === "" ? null : body.email,
        avatarUrl: body.avatarUrl === "" ? null : body.avatarUrl,
      }),
    });
  });

  app.delete("/users/:id", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    return reply.send({
      success: true,
      data: await svc.deleteUser(user.userId, id),
    });
  });

  app.post("/users/:id/profiles", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    const body = z
      .object({
        type: z.enum(["PLAYER", "COACH", "ACADEMY_OWNER", "ARENA_OWNER"]),
      })
      .parse(request.body);
    return reply.code(201).send({
      success: true,
      data: await svc.createUserProfile(user.userId, id, body.type),
    });
  });

  app.delete("/users/:id/profiles/:type", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id, type } = request.params as {
      id: string;
      type: "PLAYER" | "COACH" | "ACADEMY_OWNER" | "ARENA_OWNER";
    };
    return reply.send({
      success: true,
      data: await svc.deleteUserProfile(user.userId, id, type),
    });
  });

  app.post("/users/:id/block", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    const body = z.object({ reason: z.string().min(5) }).parse(request.body);
    return reply.send({
      success: true,
      data: await svc.blockUser(user.userId, id, body.reason),
    });
  });

  app.post("/users/:id/unblock", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    return reply.send({
      success: true,
      data: await svc.unblockUser(user.userId, id),
    });
  });

  app.post("/users/:id/grant-role", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    const body = z.object({ role: z.string() }).parse(request.body);
    return reply.send({
      success: true,
      data: await svc.grantRole(user.userId, id, body.role),
    });
  });

  app.post("/users/:id/revoke-role", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    const body = z.object({ role: z.string() }).parse(request.body);
    return reply.send({
      success: true,
      data: await svc.revokeRole(user.userId, id, body.role),
    });
  });

  app.get("/session-types", auth, async (_request, reply) => {
    return reply.send({ success: true, data: await developmentSvc.listSessionTypes() });
  });

  app.post("/session-types", auth, async (request, reply) => {
    const body = z.object({
      name: z.string().min(2),
      color: z.string().min(3),
      defaultDurationMinutes: z.number().int().positive().optional(),
      isActive: z.boolean().optional(),
    }).parse(request.body);
    return reply.code(201).send({ success: true, data: await developmentSvc.createSessionType(body) });
  });

  app.patch("/session-types/:id", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const body = z.object({
      name: z.string().min(2).optional(),
      color: z.string().min(3).optional(),
      defaultDurationMinutes: z.number().int().positive().optional(),
      isActive: z.boolean().optional(),
    }).parse(request.body);
    return reply.send({ success: true, data: await developmentSvc.updateSessionType(id, body) });
  });

  app.delete("/session-types/:id", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    return reply.send({ success: true, data: await developmentSvc.deleteSessionType(id) });
  });

  app.get("/skill-areas", auth, async (request, reply) => {
    const q = z.object({ roleTag: z.string().optional() }).parse(request.query);
    return reply.send({ success: true, data: await developmentSvc.listSkillAreas(q.roleTag) });
  });

  app.post("/skill-areas", auth, async (request, reply) => {
    const body = z.object({
      name: z.string().min(2),
      roleTag: z.enum(["BATSMAN", "BOWLER", "ALL_ROUNDER", "FIELDER", "WICKET_KEEPER"]),
      isActive: z.boolean().optional(),
    }).parse(request.body);
    return reply.code(201).send({ success: true, data: await developmentSvc.createSkillArea(body) });
  });

  app.patch("/skill-areas/:id", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const body = z.object({
      name: z.string().min(2).optional(),
      roleTag: z.enum(["BATSMAN", "BOWLER", "ALL_ROUNDER", "FIELDER", "WICKET_KEEPER"]).optional(),
      isActive: z.boolean().optional(),
    }).parse(request.body);
    return reply.send({ success: true, data: await developmentSvc.updateSkillArea(id, body) });
  });

  app.delete("/skill-areas/:id", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    return reply.send({ success: true, data: await developmentSvc.deleteSkillArea(id) });
  });

  app.get("/watch-flags", auth, async (request, reply) => {
    const q = z.object({ roleTag: z.string().optional() }).parse(request.query);
    return reply.send({ success: true, data: await developmentSvc.listWatchFlags(q.roleTag) });
  });

  app.post("/watch-flags", auth, async (request, reply) => {
    const body = z.object({
      name: z.string().min(2),
      roleTag: z.enum(["BATSMAN", "BOWLER", "ALL_ROUNDER", "FIELDER", "WICKET_KEEPER"]),
      severity: z.enum(["MONITOR", "URGENT"]).optional(),
      description: z.string().optional(),
      isActive: z.boolean().optional(),
    }).parse(request.body);
    return reply.code(201).send({ success: true, data: await developmentSvc.createWatchFlag(body) });
  });

  app.patch("/watch-flags/:id", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const body = z.object({
      name: z.string().min(2).optional(),
      roleTag: z.enum(["BATSMAN", "BOWLER", "ALL_ROUNDER", "FIELDER", "WICKET_KEEPER"]).optional(),
      severity: z.enum(["MONITOR", "URGENT"]).optional(),
      description: z.string().optional(),
      isActive: z.boolean().optional(),
    }).parse(request.body);
    return reply.send({ success: true, data: await developmentSvc.updateWatchFlag(id, body) });
  });

  app.delete("/watch-flags/:id", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    return reply.send({ success: true, data: await developmentSvc.deleteWatchFlag(id) });
  });

  app.get("/drills", auth, async (request, reply) => {
    const q = z.object({
      role: z.string().optional(),
      category: z.string().optional(),
      includeInactive: z.coerce.boolean().optional(),
    }).parse(request.query);
    return reply.send({ success: true, data: await developmentSvc.listDrills(q) });
  });

  app.post("/drills", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const body = z.object({
      name: z.string().min(2),
      description: z.string().optional(),
      roleTags: z.array(z.enum(["BATSMAN", "BOWLER", "ALL_ROUNDER", "FIELDER", "WICKET_KEEPER"])).min(1),
      category: z.enum(["TECHNIQUE", "FITNESS", "MENTAL", "MATCH_SIMULATION"]),
      targetUnit: z.enum(["BALLS", "OVERS", "MINUTES", "REPS", "SESSIONS"]),
      skillArea: z.string().optional(),
      isActive: z.boolean().optional(),
      videoUrl: z.string().url().optional(),
    }).parse(request.body);
    return reply.code(201).send({ success: true, data: await developmentSvc.createDrill(user.userId, body) });
  });

  app.patch("/drills/:id", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const body = z.object({
      name: z.string().optional(),
      description: z.string().optional(),
      roleTags: z.array(z.enum(["BATSMAN", "BOWLER", "ALL_ROUNDER", "FIELDER", "WICKET_KEEPER"])).optional(),
      category: z.enum(["TECHNIQUE", "FITNESS", "MENTAL", "MATCH_SIMULATION"]).optional(),
      targetUnit: z.enum(["BALLS", "OVERS", "MINUTES", "REPS", "SESSIONS"]).optional(),
      isActive: z.boolean().optional(),
      videoUrl: z.string().url().optional().or(z.literal("")),
    }).parse(request.body);
    return reply.send({ success: true, data: await developmentSvc.updateDrill(id, body) });
  });

  app.delete("/drills/:id", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    return reply.send({ success: true, data: await developmentSvc.deleteDrill(id) });
  });

  app.get("/matches", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const q = request.query as {
      status?: string;
      matchType?: string;
      search?: string;
      page?: string;
      limit?: string;
    };
    return reply.send({
      success: true,
      data: await svc.listMatches(user.userId, {
        status: q.status,
        matchType: q.matchType,
        search: q.search,
        page: Number(q.page) || 1,
        limit: Number(q.limit) || 20,
      }),
    });
  });

  app.post("/matches/:id/verify", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    const body = z
      .object({ level: z.enum(["LEVEL_1", "LEVEL_2", "LEVEL_3"]) })
      .parse(request.body);
    return reply.send({
      success: true,
      data: await svc.verifyMatch(user.userId, id, body.level),
    });
  });

  app.get("/payments", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const q = request.query as {
      status?: string;
      page?: string;
      limit?: string;
    };
    return reply.send({
      success: true,
      data: await svc.getPayments(user.userId, {
        status: q.status,
        page: Number(q.page) || 1,
        limit: Number(q.limit) || 20,
      }),
    });
  });

  app.get("/events", auth, async (request, reply) => {
    const q = request.query as {
      search?: string;
      status?: string;
      page?: string;
      limit?: string;
    };
    return reply.send({
      success: true,
      data: await eventSvc.listAdminEvents({
        search: q.search,
        status: q.status,
        page: Number(q.page) || 1,
        limit: Number(q.limit) || 25,
      }),
    });
  });

  app.post("/events", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const body = z.object({
      name: z.string().min(1),
      eventType: z.string().optional().default("CUSTOM"),
      scheduledAt: z.string().optional(),
      venueName: z.string().optional(),
      city: z.string().optional(),
      description: z.string().optional(),
      maxParticipants: z.number().int().positive().optional(),
      prizePool: z.string().optional(),
      rules: z.string().optional(),
      isPublic: z.boolean().optional().default(true),
    }).parse(request.body);
    return reply.code(201).send({
      success: true,
      data: await eventSvc.createHostedEvent(user.userId, body),
    });
  });

  app.post("/notifications/broadcast", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const body = z
      .object({
        title: z.string(),
        body: z.string(),
        userIds: z.array(z.string()).optional(),
        roles: z.array(z.string()).optional(),
      })
      .parse(request.body);
    return reply.send({
      success: true,
      data: await svc.broadcastNotification(user.userId, body),
    });
  });

  app.get("/academies", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const q = request.query as {
      page?: string;
      limit?: string;
      search?: string;
      verified?: "VERIFIED" | "UNVERIFIED";
    };
    return reply.send({
      success: true,
      data: await svc.getAcademies(user.userId, {
        page: Number(q.page) || 1,
        limit: Number(q.limit) || 20,
        search: q.search,
        verified: q.verified,
      }),
    });
  });

  app.patch("/academies/:id/verify", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    await svc.verifyAcademy(user.userId, id, true);
    return reply.send({ success: true });
  });

  app.patch(
    "/academies/:id/revoke-verification",
    auth,
    async (request, reply) => {
      const user = (request as any).user as { userId: string };
      const { id } = request.params as { id: string };
      await svc.verifyAcademy(user.userId, id, false);
      return reply.send({ success: true });
    },
  );

  app.patch("/arenas/:id/verify", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    const body = z
      .object({
        arenaGrade: z.enum(["GULLY", "CLUB", "DISTRICT", "ELITE"]),
      })
      .parse(request.body);
    await svc.verifyArena(user.userId, id, body.arenaGrade);
    return reply.send({ success: true });
  });

  app.patch("/arenas/:id/toggle-swing", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    await svc.toggleSwingArena(user.userId, id);
    return reply.send({ success: true });
  });

  app.delete("/arenas/:id", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    await svc.hardDeleteArena(user.userId, id);
    return reply.send({ success: true });
  });

  app.get("/analytics/revenue", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const q = z
      .object({
        from: z.string().datetime(),
        to: z.string().datetime(),
        groupBy: z.enum(["day", "week", "month"]),
      })
      .parse(request.query);
    return reply.send({
      success: true,
      data: await svc.getRevenueAnalytics(user.userId, q),
    });
  });

  app.get("/config", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    return reply.send({
      success: true,
      data: await svc.getConfigs(user.userId),
    });
  });

  app.put("/config/:key", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { key } = request.params as { key: string };
    const body = z.object({ value: z.string() }).parse(request.body);
    await svc.updateConfig(user.userId, key, body.value);
    return reply.send({ success: true });
  });

  app.get("/audit", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const q = z
      .object({
        actorId: z.string().optional(),
        entityType: z.string().optional(),
        page: z.coerce.number().int().min(1).optional(),
        limit: z.coerce.number().int().min(1).max(100).optional(),
      })
      .parse(request.query);
    return reply.send({
      success: true,
      data: await svc.getAuditLogs(user.userId, {
        actorId: q.actorId,
        entityType: q.entityType,
        page: q.page || 1,
        limit: q.limit || 50,
      }),
    });
  });

  // ── Admin Auth ──────────────────────────────────────────────────────────
  app.post(
    "/auth/login",
    {
      config: { skipAuth: true },
      schema: { tags: ["admin"], summary: "Admin login with email/password" },
    },
    async (request, reply) => {
      const body = z
        .object({
          email: z.string().email(),
          password: z.string().min(6),
        })
        .parse(request.body);
      const data = await authSvc.login(body.email, body.password);
      return reply.send({ success: true, data });
    },
  );

  app.get(
    "/auth/admins",
    {
      onRequest: [(app as any).authenticate],
      schema: { tags: ["admin"], summary: "List all admin users" },
    },
    async (request, reply) => {
      const data = await authSvc.listAdmins();
      return reply.send({ success: true, data });
    },
  );

  app.post(
    "/auth/admins",
    {
      onRequest: [(app as any).authenticate],
      schema: { tags: ["admin"], summary: "Create admin user" },
    },
    async (request, reply) => {
      const body = z
        .object({
          email: z.string().email(),
          password: z.string().min(8),
          name: z.string().min(2),
          role: z.enum(["SWING_ADMIN", "SWING_SUPPORT"]).optional(),
        })
        .parse(request.body);
      const data = await authSvc.createAdmin(
        body.email,
        body.password,
        body.name,
        body.role,
      );
      return reply.send({ success: true, data });
    },
  );

  app.patch(
    "/auth/admins/:id",
    {
      onRequest: [(app as any).authenticate],
      schema: { tags: ["admin"], summary: "Update admin user" },
    },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const body = z
        .object({
          name: z.string().min(2).optional(),
          role: z.enum(["SWING_ADMIN", "SWING_SUPPORT"]).optional(),
          password: z.string().min(8).optional(),
          isActive: z.boolean().optional(),
        })
        .parse(request.body);
      const data = await authSvc.updateAdmin(id, body);
      return reply.send({ success: true, data });
    },
  );

  app.delete(
    "/auth/admins/:id",
    {
      onRequest: [(app as any).authenticate],
      schema: { tags: ["admin"], summary: "Delete admin user" },
    },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const data = await authSvc.deleteAdmin(id);
      return reply.send({ success: true, data });
    },
  );

  // ── Arenas ──────────────────────────────────────────────────────────
  app.get("/arenas", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const q = request.query as {
      search?: string;
      city?: string;
      page?: string;
      limit?: string;
    };
    return reply.send({
      success: true,
      data: await svc.listArenas(user.userId, {
        search: q.search,
        city: q.city,
        page: Number(q.page) || 1,
        limit: Number(q.limit) || 20,
      }),
    });
  });

  // ── Coaches ──────────────────────────────────────────────────────────
  app.get("/coaches", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const q = request.query as {
      search?: string;
      verified?: "VERIFIED" | "UNVERIFIED";
      page?: string;
      limit?: string;
    };
    return reply.send({
      success: true,
      data: await svc.listCoaches(user.userId, {
        search: q.search,
        verified: q.verified,
        page: Number(q.page) || 1,
        limit: Number(q.limit) || 20,
      }),
    });
  });

  app.patch("/coaches/:id/verify", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    const body = z.object({ isVerified: z.boolean() }).parse(request.body);
    return reply.send({
      success: true,
      data: await svc.verifyCoach(user.userId, id, body.isVerified),
    });
  });

  app.patch("/coaches/:id", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    const body = z
      .object({
        bio: z.string().optional(),
        specializations: z.array(z.string()).optional(),
        certifications: z.array(z.string()).optional(),
        experienceYears: z.number().int().min(0).optional(),
        city: z.string().optional(),
        state: z.string().optional(),
        gigEnabled: z.boolean().optional(),
        hourlyRate: z.number().int().min(0).nullable().optional(),
        isVerified: z.boolean().optional(),
      })
      .parse(request.body);
    return reply.send({
      success: true,
      data: await svc.updateCoachProfile(user.userId, id, body),
    });
  });

  // ── Players ──────────────────────────────────────────────────────────
  app.patch("/players/:id", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    const body = z
      .object({
        level: z.string().optional(),
        playerRole: z.string().optional(),
        battingStyle: z.string().optional(),
        bowlingStyle: z.string().optional(),
        city: z.string().optional(),
        state: z.string().optional(),
        bio: z.string().optional(),
        goals: z.string().optional(),
        dateOfBirth: z.string().optional(),
        jerseyNumber: z.number().int().optional(),
        verificationLevel: z.string().optional(),
        swingIndex: z.number().optional(),
      })
      .parse(request.body);
    return reply.send({
      success: true,
      data: await svc.updatePlayerProfile(user.userId, id, body),
    });
  });

  app.patch("/players/:id/competitive", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    const body = z
      .object({
        lifetimeImpactPoints: z.number().int().min(0).optional(),
        currentRankKey: z
          .enum([
            "ROOKIE",
            "STRIKER",
            "VANGUARD",
            "PHANTOM",
            "DOMINION",
            "ASCENDANT",
            "IMMORTAL",
            "APEX",
          ])
          .optional(),
        currentDivision: z.number().int().min(1).max(3).optional(),
        rankProgressPoints: z.number().int().min(0).optional(),
        currentDivisionFloor: z.number().int().min(0).optional(),
        winStreak: z.number().int().min(0).optional(),
        mvpCount: z.number().int().min(0).optional(),
        hasPremiumPass: z.boolean().optional(),
        premiumPassExpiresAt: z.string().datetime().nullable().optional(),
        lastRankedMatchAt: z.string().datetime().nullable().optional(),
      })
      .parse(request.body);
    return reply.send({
      success: true,
      data: await svc.updatePlayerCompetitiveProfile(user.userId, id, body),
    });
  });

  app.post("/players/:playerId/rebuild-ip", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { playerId } = request.params as { playerId: string };

    return reply.send({
      success: true,
      data: await svc.rebuildPlayerIp(user.userId, playerId),
    });
  });

  app.patch("/arena-owners/:id", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    const body = z
      .object({
        businessName: z.string().optional(),
        gstNumber: z.string().optional(),
        panNumber: z.string().optional(),
      })
      .parse(request.body);
    return reply.send({
      success: true,
      data: await svc.updateArenaOwnerProfile(user.userId, id, body),
    });
  });

  // ── Tournaments ──────────────────────────────────────────────────────
  app.get("/tournaments", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const q = request.query as {
      search?: string;
      status?: string;
      page?: string;
      limit?: string;
    };
    return reply.send({
      success: true,
      data: await svc.listTournaments(user.userId, {
        search: q.search,
        status: q.status,
        page: Number(q.page) || 1,
        limit: Number(q.limit) || 20,
      }),
    });
  });

  app.get("/overlay-packs", auth, async (_request, reply) => {
    return reply.send({
      success: true,
      data: await overlayPackService.listPacks(),
    });
  });

  app.post("/overlay-packs", auth, async (request, reply) => {
    const body = z
      .object({
        name: z.string().min(2),
        code: z.string().min(2).max(80).optional(),
        kind: z.nativeEnum(OverlayPackKind).optional(),
        description: z.string().nullable().optional(),
        isActive: z.boolean().optional(),
        isDefault: z.boolean().optional(),
        config: z.record(z.string(), z.any()).optional(),
      })
      .parse(request.body);

    return reply.code(201).send({
      success: true,
      data: await overlayPackService.createPack(body),
    });
  });

  app.patch("/overlay-packs/:id", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const body = z
      .object({
        name: z.string().min(2).optional(),
        code: z.string().min(2).max(80).optional(),
        kind: z.nativeEnum(OverlayPackKind).optional(),
        description: z.string().nullable().optional(),
        isActive: z.boolean().optional(),
        isDefault: z.boolean().optional(),
        config: z.record(z.string(), z.any()).optional(),
      })
      .parse(request.body);

    return reply.send({
      success: true,
      data: await overlayPackService.updatePack(id, body),
    });
  });

  app.post("/tournaments", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const body = createTournamentRequestSchema.parse(request.body);
    return reply.send({
      success: true,
      data: await svc.createTournament(user.userId, body),
    });
  });

  app.get("/tournaments/:id", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    return reply.send({
      success: true,
      data: await svc.getTournament(user.userId, id),
    });
  });

  app.patch("/tournaments/:id", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    const OPTIONAL_IMAGE = z
      .string()
      .trim()
      .refine(
        (value) =>
          value.length === 0 ||
          value.startsWith("data:image/") ||
          z.string().url().safeParse(value).success,
        "Invalid image value",
      )
      .nullable()
      .optional()
      .transform((value) => (value ? value : undefined));
    const body = z
      .object({
        name: z.string().min(2).optional(),
        description: z.string().nullable().optional(),
        status: z.string().optional(),
        isVerified: z.boolean().optional(),
        isPublic: z.boolean().optional(),
        venueName: z.string().optional(),
        city: z.string().optional(),
        startDate: z.string().datetime().optional(),
        endDate: z.string().datetime().nullable().optional(),
        format: z
          .enum([
            "T10",
            "T20",
            "ONE_DAY",
            "TWO_INNINGS",
            "BOX_CRICKET",
            "CUSTOM",
          ])
          .optional(),
        tournamentFormat: z
          .enum([
            "LEAGUE",
            "KNOCKOUT",
            "GROUP_STAGE_KNOCKOUT",
            "DOUBLE_ELIMINATION",
            "SUPER_LEAGUE",
            "SERIES",
          ])
          .optional(),
        maxTeams: z.number().int().min(2).optional(),
        seriesMatchCount: z.number().int().min(1).max(15).nullable().optional(),
        groupCount: z.number().int().min(1).optional(),
        entryFee: z.number().int().optional(),
        prizePool: z.string().optional(),
        rules: z.string().optional(),
        pointsForWin: z.number().int().min(0).optional(),
        pointsForLoss: z.number().int().min(0).optional(),
        pointsForTie: z.number().int().min(0).optional(),
        pointsForNoResult: z.number().int().min(0).optional(),
        overlayPackId: z.string().nullable().optional(),
        logoUrl: OPTIONAL_IMAGE,
        coverUrl: OPTIONAL_IMAGE,
        slug: z
          .string()
          .min(2)
          .max(80)
          .regex(
            /^[a-z0-9-]+$/,
            "Slug must be lowercase letters, numbers, and hyphens only",
          )
          .optional(),
        highlights: z
          .array(z.object({ title: z.string(), youtubeUrl: z.string().url() }))
          .optional(),
      })
      .parse(request.body);
    return reply.send({
      success: true,
      data: await svc.updateTournament(user.userId, id, body),
    });
  });

  app.patch("/tournaments/:id/overlay-pack", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const body = z
      .object({
        overlayPackId: z.string().nullable(),
      })
      .parse(request.body);

    return reply.send({
      success: true,
      data: await overlayPackService.assignToTournament(id, body.overlayPackId),
    });
  });

  app.get("/tournaments/:id/teams", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    return reply.send({
      success: true,
      data: await svc.listTournamentTeams(user.userId, id),
    });
  });

  app.post("/tournaments/:id/teams", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    const optionalId = z.preprocess((value) => {
      if (typeof value !== "string") return value;
      const normalized = value.trim();
      if (!normalized || normalized === "__new__") return undefined;
      return normalized;
    }, z.string().optional());
    const optionalName = z.preprocess((value) => {
      if (typeof value !== "string") return value;
      const normalized = value.trim();
      return normalized || undefined;
    }, z.string().min(1).optional());
    const body = z
      .object({
        teamId: optionalId,
        teamName: optionalName,
        captainId: optionalId,
        playerIds: z.array(z.string()).optional(),
      })
      .refine((value) => value.teamId || value.teamName, {
        message: "Either teamId or teamName is required.",
        path: ["teamId"],
      })
      .parse(request.body);
    return reply.send({
      success: true,
      data: await svc.addTournamentTeam(user.userId, id, {
        ...body,
        playerIds: body.playerIds || [],
      }),
    });
  });

  app.delete("/tournaments/:id/teams/:teamId", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id, teamId } = request.params as { id: string; teamId: string };
    return reply.send({
      success: true,
      data: await svc.removeTournamentTeam(user.userId, id, teamId),
    });
  });

  app.delete("/tournaments/:id", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    return reply.send({
      success: true,
      data: await svc.deleteTournament(user.userId, id),
    });
  });

  // DELETE /admin/matches/:id — hard delete match + all related data
  app.delete("/matches/:id", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    await svc["verifyAdmin"](user.userId);
    const { id } = request.params as { id: string };
    const result = await matchSvc.deleteMatch(id, user.userId, { access: "ADMIN" });
    return reply.send({ success: true, data: result });
  });

  // ── Venues ───────────────────────────────────────────────────────────
  app.get("/venues", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { q, full } = request.query as { q?: string; full?: string };

    if (full === "1") {
      // Full venue list with match counts for the Arenas/Venues admin page
      await svc["verifyAdmin"]((user as any).userId);
      const venues = await prisma.venue.findMany({
        where: q ? { name: { contains: q, mode: "insensitive" } } : undefined,
        orderBy: { name: "asc" },
        include: { _count: { select: { matches: true } } },
      });
      return reply.send({ success: true, data: venues });
    }

    return reply.send({
      success: true,
      data: await svc.searchVenues(user.userId, q || ""),
    });
  });

  // ── Admin Match Creation ─────────────────────────────────────────────
  app.post("/matches", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const body = adminCreateMatchRequestSchema.parse(request.body);
    return reply.send({
      success: true,
      data: await svc.createAdminMatch(user.userId, body),
    });
  });

  // ── Match detail & scoring (admin, no scorer check) ─────────────────

  // PATCH /admin/matches/:id — edit scheduledAt/customOvers before start
  app.patch("/matches/:id", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    const body = z
      .object({
        scheduledAt: z.string().min(1).optional(),
        customOvers: z.number().int().positive().optional(),
      })
      .refine(
        (value) => value.scheduledAt !== undefined || value.customOvers !== undefined,
        {
          message: "At least one field must be provided",
        },
      )
      .parse(request.body);

    const updated = await svc.updateAdminMatch(user.userId, id, body);
    return reply.send({ success: true, data: updated });
  });

  // GET /admin/matches/:id — full match with innings + ball events
  app.get("/matches/:id", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    let match = await prisma.match.findUnique({
      where: { id },
      include: {
        overlayPack: true,
        innings: {
          orderBy: { inningsNumber: "asc" },
          include: {
            ballEvents: {
              orderBy: [{ overNumber: "asc" }, { ballNumber: "asc" }],
            },
          },
        },
      },
    });
    if (!match)
      return reply
        .status(404)
        .send({ success: false, error: { message: "Match not found" } });

    if (!match.liveCode || !match.livePin) {
      try {
        const liveAccess = await svc.ensureMatchLiveAccess(user.userId, id);
        match = {
          ...match,
          liveCode: liveAccess.liveCode,
          livePin: liveAccess.livePin,
        };
      } catch (error) {
        request.log.error({ id, error }, "Failed to ensure match live access");
      }
    }

    const effectiveOverlayPack = await overlayPackService
      .resolveEffectivePackForMatch(id)
      .catch(() => null);
    const inningsWithDerivedState = match.innings.map((innings) => ({
      ...innings,
      isFreeHit: matchSvc.buildInningsSnapshot(innings.ballEvents || []).isFreeHit,
    }));
    return reply.send({
      success: true,
      data: {
        ...match,
        innings: inningsWithDerivedState,
        effectiveOverlayPack,
      },
    });
  });

  app.patch("/matches/:id/overlay-pack", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const body = z
      .object({
        overlayPackId: z.string().nullable(),
      })
      .parse(request.body);

    return reply.send({
      success: true,
      data: await overlayPackService.assignToMatch(id, body.overlayPackId),
    });
  });

  app.get("/matches/:id/overlay-pack/effective", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    return reply.send({
      success: true,
      data: await overlayPackService.resolveEffectivePackForMatch(id),
    });
  });

  // GET /admin/matches/:id/players — resolved player list for both teams
  app.get("/matches/:id/players", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const match = await prisma.match.findUnique({ where: { id } });
    if (!match)
      return reply
        .status(404)
        .send({ success: false, error: { message: "Match not found" } });

    async function resolvePlayers(ids: string[]) {
      if (!ids.length) return [];
      const profiles = await prisma.playerProfile.findMany({
        where: { OR: [{ id: { in: ids } }, { userId: { in: ids } }] },
        include: {
          user: { select: { id: true, name: true, avatarUrl: true } },
        },
      });
      const map = new Map<
        string,
        {
          profileId: string;
          userId: string;
          name: string;
          avatarUrl: string | null;
        }
      >();
      for (const p of profiles) {
        const payload = {
          profileId: p.id,
          userId: p.userId,
          name: p.user.name,
          avatarUrl: p.user.avatarUrl ?? null,
        };
        map.set(p.id, payload);
        map.set(p.userId, payload);
      }
      return ids.map((id) => map.get(id)).filter(Boolean);
    }

    // For tournament matches with empty playerIds, resolve via TournamentTeam → Team
    let teamAIds = match.teamAPlayerIds;
    let teamBIds = match.teamBPlayerIds;
    if (match.tournamentId && (!teamAIds.length || !teamBIds.length)) {
      const [ttA, ttB] = await Promise.all([
        prisma.tournamentTeam.findFirst({
          where: { tournamentId: match.tournamentId, teamName: match.teamAName },
          select: { playerIds: true, teamId: true },
        }),
        prisma.tournamentTeam.findFirst({
          where: { tournamentId: match.tournamentId, teamName: match.teamBName },
          select: { playerIds: true, teamId: true },
        }),
      ]);
      // Prefer TournamentTeam.playerIds, fall back to Team.playerIds via teamId
      if (!teamAIds.length) {
        if (ttA?.playerIds.length) {
          teamAIds = ttA.playerIds;
        } else if (ttA?.teamId) {
          const team = await prisma.team.findUnique({ where: { id: ttA.teamId }, select: { playerIds: true } });
          if (team?.playerIds.length) teamAIds = team.playerIds;
        }
      }
      if (!teamBIds.length) {
        if (ttB?.playerIds.length) {
          teamBIds = ttB.playerIds;
        } else if (ttB?.teamId) {
          const team = await prisma.team.findUnique({ where: { id: ttB.teamId }, select: { playerIds: true } });
          if (team?.playerIds.length) teamBIds = team.playerIds;
        }
      }
    }

    // Find team records by name for reliable lookup (name-based is more accurate than player overlap)
    const [teamARecord, teamBRecord] = await Promise.all([
      prisma.team.findFirst({
        where: { name: { equals: match.teamAName, mode: "insensitive" } },
        select: { id: true, playerIds: true, captainId: true, viceCaptainId: true, wicketKeeperId: true },
      }),
      prisma.team.findFirst({
        where: { name: { equals: match.teamBName, mode: "insensitive" } },
        select: { id: true, playerIds: true, captainId: true, viceCaptainId: true, wicketKeeperId: true },
      }),
    ]);

    // Merge match player IDs with full team roster so all squad members appear in the XI selector
    const mergedAIds = Array.from(new Set([...teamAIds, ...(teamARecord?.playerIds ?? [])]));
    const mergedBIds = Array.from(new Set([...teamBIds, ...(teamBRecord?.playerIds ?? [])]));

    const [teamAPlayers, teamBPlayers] = await Promise.all([
      resolvePlayers(mergedAIds),
      resolvePlayers(mergedBIds),
    ]);

    return reply.send({
      success: true,
      data: {
        teamA: {
          name: match.teamAName,
          teamId: teamARecord?.id ?? null,
          captainId: match.teamACaptainId ?? teamARecord?.captainId ?? null,
          viceCaptainId: match.teamAViceCaptainId ?? teamARecord?.viceCaptainId ?? null,
          wicketKeeperId: match.teamAWicketKeeperId ?? teamARecord?.wicketKeeperId ?? null,
          players: teamAPlayers,
        },
        teamB: {
          name: match.teamBName,
          teamId: teamBRecord?.id ?? null,
          captainId: match.teamBCaptainId ?? teamBRecord?.captainId ?? null,
          viceCaptainId: match.teamBViceCaptainId ?? teamBRecord?.viceCaptainId ?? null,
          wicketKeeperId: match.teamBWicketKeeperId ?? teamBRecord?.wicketKeeperId ?? null,
          players: teamBPlayers,
        },
      },
    });
  });

  // POST /admin/matches/:id/quick-add-player — add a new player to the team squad inline
  app.post("/matches/:id/quick-add-player", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const body = z
      .object({
        team: z.enum(["A", "B"]),
        name: z.string().min(2),
        countryCode: z.string().regex(/^\+\d{1,4}$/).default("+91"),
        mobileNumber: z.string().regex(/^\d{10}$/),
      })
      .parse(request.body);

    const match = await prisma.match.findUnique({ where: { id } });
    if (!match) return reply.status(404).send({ success: false, error: { message: "Match not found" } });

    const teamIds = body.team === "A" ? match.teamAPlayerIds : match.teamBPlayerIds;
    const teamRecord = teamIds.length
      ? await prisma.team.findFirst({
          where: { playerIds: { hasSome: teamIds } },
          select: { id: true },
        })
      : null;

    // Create or find existing user by mobile
    const phoneE164 = `${body.countryCode}${body.mobileNumber}`;
    let user = await prisma.user.findFirst({ where: { phone: phoneE164 } });
    if (!user) {
      user = await prisma.user.create({
        data: {
          phone: phoneE164,
          name: body.name,
        },
      });
    }

    // Create or find player profile
    let profile = await prisma.playerProfile.findFirst({ where: { userId: user.id } });
    if (!profile) {
      profile = await prisma.playerProfile.create({ data: { userId: user.id } });
    }

    // Add to team DB record if found
    if (teamRecord) {
      await prisma.team.update({
        where: { id: teamRecord.id },
        data: { playerIds: { push: profile.id } },
      });
    }

    // Always add to match player IDs so they appear immediately in the admin
    const matchField = body.team === "A" ? "teamAPlayerIds" : "teamBPlayerIds";
    const currentIds = body.team === "A" ? match.teamAPlayerIds : match.teamBPlayerIds;
    if (!currentIds.includes(profile.id)) {
      await prisma.match.update({
        where: { id },
        data: { [matchField]: { push: profile.id } },
      });
    }

    return reply.send({
      success: true,
      data: { profileId: profile.id, userId: user.id, name: user.name, teamId: teamRecord?.id ?? null },
    });
  });

  // PATCH /admin/matches/:id/playing11 — set playing 11, captains, VC, WK
  app.patch("/matches/:id/playing11", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const body = z
      .object({
        teamAPlayerIds: z.array(z.string()),
        teamBPlayerIds: z.array(z.string()),
        teamACaptainId: z.string().optional(),
        teamBCaptainId: z.string().optional(),
        teamAViceCaptainId: z.string().optional(),
        teamBViceCaptainId: z.string().optional(),
        teamAWicketKeeperId: z.string().optional(),
        teamBWicketKeeperId: z.string().optional(),
        customOvers: z.number().int().positive().optional(),
      })
      .parse(request.body);
    const normalizeIds = (playerIds: string[]) =>
      Array.from(
        new Set(playerIds.map((playerId) => `${playerId}`.trim()).filter(Boolean)),
      );
    const resolvePlayerProfileIds = async (playerIds: string[]) => {
      const normalizedIds = normalizeIds(playerIds);
      if (normalizedIds.length === 0) return [];

      const profiles = await prisma.playerProfile.findMany({
        where: {
          OR: [
            { id: { in: normalizedIds } },
            { userId: { in: normalizedIds } },
          ],
        },
        select: { id: true, userId: true },
      });

      const profileIdByInput = new Map<string, string>();
      for (const profile of profiles) {
        profileIdByInput.set(profile.id, profile.id);
        profileIdByInput.set(profile.userId, profile.id);
      }

      const unresolvedIds = normalizedIds.filter((playerId) => !profileIdByInput.has(playerId));
      if (unresolvedIds.length > 0) {
        throw new AppError(
          "INVALID_PLAYING_XI",
          `Unable to resolve player IDs: ${unresolvedIds.join(", ")}`,
          400,
        );
      }

      return normalizedIds.map((playerId) => profileIdByInput.get(playerId) as string);
    };
    const resolveOptionalPlayerProfileId = async (playerId: string | undefined) => {
      if (!playerId) return undefined;
      const resolvedIds = await resolvePlayerProfileIds([playerId]);
      return resolvedIds[0];
    };
    const ensureRoleBelongsToTeam = (
      roleLabel: string,
      playerId: string | undefined,
      teamIds: string[],
      teamLabel: string,
    ) => {
      if (!playerId) return;
      if (!teamIds.includes(playerId)) {
        throw new AppError(
          "INVALID_PLAYING_XI",
          `${teamLabel} ${roleLabel} must be part of the selected 11`,
          400,
        );
      }
    };

    const teamAPlayerIds = await resolvePlayerProfileIds(body.teamAPlayerIds);
    const teamBPlayerIds = await resolvePlayerProfileIds(body.teamBPlayerIds);

    if (teamAPlayerIds.length !== 11 || teamBPlayerIds.length !== 11) {
      throw new AppError(
        "INVALID_PLAYING_XI",
        "Each team must have exactly 11 unique players in the playing 11",
        400,
      );
    }

    const overlappingIds = teamAPlayerIds.filter((playerId) =>
      teamBPlayerIds.includes(playerId),
    );
    if (overlappingIds.length > 0) {
      throw new AppError(
        "INVALID_PLAYING_XI",
        "A player cannot be selected in both teams",
        400,
      );
    }

    const teamACaptainId = await resolveOptionalPlayerProfileId(body.teamACaptainId);
    const teamAViceCaptainId = await resolveOptionalPlayerProfileId(body.teamAViceCaptainId);
    const teamAWicketKeeperId = await resolveOptionalPlayerProfileId(body.teamAWicketKeeperId);
    const teamBCaptainId = await resolveOptionalPlayerProfileId(body.teamBCaptainId);
    const teamBViceCaptainId = await resolveOptionalPlayerProfileId(body.teamBViceCaptainId);
    const teamBWicketKeeperId = await resolveOptionalPlayerProfileId(body.teamBWicketKeeperId);

    ensureRoleBelongsToTeam("captain", teamACaptainId, teamAPlayerIds, "Team A");
    ensureRoleBelongsToTeam(
      "vice captain",
      teamAViceCaptainId,
      teamAPlayerIds,
      "Team A",
    );
    ensureRoleBelongsToTeam(
      "wicket keeper",
      teamAWicketKeeperId,
      teamAPlayerIds,
      "Team A",
    );
    ensureRoleBelongsToTeam("captain", teamBCaptainId, teamBPlayerIds, "Team B");
    ensureRoleBelongsToTeam(
      "vice captain",
      teamBViceCaptainId,
      teamBPlayerIds,
      "Team B",
    );
    ensureRoleBelongsToTeam(
      "wicket keeper",
      teamBWicketKeeperId,
      teamBPlayerIds,
      "Team B",
    );

    const updated = await prisma.match.update({
      where: { id },
      data: {
        ...body,
        teamAPlayerIds,
        teamBPlayerIds,
        teamACaptainId,
        teamAViceCaptainId,
        teamAWicketKeeperId,
        teamBCaptainId,
        teamBViceCaptainId,
        teamBWicketKeeperId,
      },
    });
    return reply.send({ success: true, data: updated });
  });

  // POST /admin/matches/:id/highlights — add a YouTube highlight
  app.post("/matches/:id/highlights", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const body = z.object({
      title: z.string().min(1).max(200),
      url: z.string().url().refine(
        (u) => /youtube\.com\/watch\?v=/.test(u) || /youtu\.be\//.test(u) || /youtube\.com\/shorts\//.test(u),
        { message: "Must be a YouTube URL" },
      ),
    }).parse(request.body);

    const match = await prisma.match.findUnique({ where: { id } });
    if (!match) return reply.status(404).send({ success: false, error: { message: "Match not found" } });

    const current = Array.isArray(match.highlights) ? (match.highlights as any[]) : [];
    const newHighlight = { id: crypto.randomUUID(), title: body.title, url: body.url };
    const updated = await prisma.match.update({
      where: { id },
      data: { highlights: [...current, newHighlight] },
    });
    return reply.send({ success: true, data: updated });
  });

  // DELETE /admin/matches/:id/highlights/:highlightId — remove a highlight
  app.delete("/matches/:id/highlights/:highlightId", auth, async (request, reply) => {
    const { id, highlightId } = request.params as { id: string; highlightId: string };
    const match = await prisma.match.findUnique({ where: { id } });
    if (!match) return reply.status(404).send({ success: false, error: { message: "Match not found" } });

    const current = Array.isArray(match.highlights) ? (match.highlights as any[]) : [];
    const updated = await prisma.match.update({
      where: { id },
      data: { highlights: current.filter((h) => h.id !== highlightId) },
    });
    return reply.send({ success: true, data: updated });
  });

  // PATCH /admin/matches/:id/stream — set / clear YouTube live stream URL
  app.patch("/matches/:id/stream", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const { youtubeUrl } = z.object({ youtubeUrl: z.string().url().nullable() }).parse(request.body);
    const match = await prisma.match.update({ where: { id }, data: { youtubeUrl } });
    return reply.send({ success: true, data: { youtubeUrl: match.youtubeUrl } });
  });

  // GET /admin/matches/:id/studio — get current studio scene
  app.get("/matches/:id/studio", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const scene = await getStudioScene(id);
    return reply.send({ success: true, data: scene ?? { scene: "standard", breakType: null, updatedAt: new Date().toISOString() } });
  });

  // PATCH /admin/matches/:id/studio — set studio scene
  app.patch("/matches/:id/studio", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const body = z.object({
      scene: z.enum(["standard", "stats", "break", "clean"]),
      breakType: z.enum(["drinks", "innings", "powerplay"]).nullable().optional(),
    }).parse(request.body);
    const data = { scene: body.scene, breakType: body.breakType ?? null, updatedAt: new Date().toISOString() };
    await setStudioScene(id, data as any);
    return reply.send({ success: true, data });
  });

  // ─── Stream management (proxied to Studio service) ─────────

  // POST /admin/matches/:id/stream/start — start live stream
  // youtubeStreamKey is optional — if provided, stream is pushed to YouTube RTMP simultaneously.
  app.post("/matches/:id/stream/start", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const body = z.object({
      youtubeStreamKey: z.string().min(1).optional(),
    }).parse(request.body);

    const key = body.youtubeStreamKey?.trim();
    // Accept both a raw stream key ("xxxx-xxxx-...") and a full RTMP URL ("rtmp://...")
    const youtubeRtmpUrl = key
      ? key.startsWith("rtmp://")
        ? key
        : `rtmp://a.rtmp.youtube.com/live2/${key}`
      : undefined;

    const hlsUrl = `${publicBaseUrl}/studio/hls/${id}/index.m3u8`;

    try {
      const res = await axios.post(`${STUDIO_SERVICE_URL}/streams/start`, {
        matchId: id,
        youtubeRtmpUrl,
      });
      return reply.send({ success: true, data: { ...res.data.data, wsUrl: STUDIO_WS_URL, hlsUrl } });
    } catch (err: any) {
      const status = err.response?.status || 500;
      const msg = err.response?.data?.error || err.message;
      return reply.status(status).send({ success: false, error: msg });
    }
  });

  // POST /admin/matches/:id/stream/stop — stop live stream
  app.post("/matches/:id/stream/stop", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    try {
      await axios.post(`${STUDIO_SERVICE_URL}/streams/stop`, { matchId: id });
      return reply.send({ success: true, message: "Stream stopped" });
    } catch (err: any) {
      const msg = err.response?.data?.error || err.message;
      return reply.status(500).send({ success: false, error: msg });
    }
  });

  // GET /admin/matches/:id/stream — get stream status
  app.get("/matches/:id/stream", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const hlsUrl = `${publicBaseUrl}/studio/hls/${id}/index.m3u8`;
    try {
      const res = await axios.get(`${STUDIO_SERVICE_URL}/streams/${id}`);
      const data = res.data.data ? { ...res.data.data, wsUrl: STUDIO_WS_URL, hlsUrl } : null;
      return reply.send({ success: true, data });
    } catch (err: any) {
      if (err.response?.status === 404) {
        return reply.send({ success: true, data: null });
      }
      const msg = err.response?.data?.error || err.message;
      return reply.status(500).send({ success: false, error: msg });
    }
  });

  // GET /admin/streams — list all active streams
  app.get("/streams", auth, async (request, reply) => {
    try {
      const res = await axios.get(`${STUDIO_SERVICE_URL}/streams`);
      return reply.send({ success: true, data: res.data.data });
    } catch (err: any) {
      const msg = err.response?.data?.error || err.message;
      return reply.status(500).send({ success: false, error: msg });
    }
  });

  // PATCH /admin/matches/:id/wicketkeeper — change WK mid-innings
  app.patch("/matches/:id/wicketkeeper", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    const body = z
      .object({
        team: z.enum(["A", "B"]),
        wicketKeeperId: z.string(),
      })
      .parse(request.body);
    const updated = await matchSvc.changeWicketKeeper(
      id,
      user.userId,
      body.team,
      body.wicketKeeperId,
      { access: "ADMIN" },
    );
    return reply.send({ success: true, data: updated });
  });

  // POST /admin/matches/:id/toss — record toss, move to TOSS_DONE
  app.post("/matches/:id/toss", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    const body = z
      .object({
        tossWonBy: z.enum(["A", "B"]),
        tossDecision: z.enum(["BAT", "BOWL"]),
      })
      .parse(request.body);
    const updated = await matchSvc.recordToss(
      id,
      user.userId,
      body.tossWonBy,
      body.tossDecision,
      { access: "ADMIN" },
    );
    return reply.send({ success: true, data: updated });
  });

  // Start a match (set status to IN_PROGRESS, create first innings)
  app.patch("/matches/:id/start", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    const updated = await matchSvc.startMatch(id, user.userId, { access: "ADMIN" });
    return reply.send({ success: true, data: updated });
  });

  // ── shared winner-determination helper ──────────────────────────────────────
  async function resolveMatchResult(
    matchId: string,
    inn1: { battingTeam: string; totalRuns: number },
    inn2: { battingTeam: string; totalRuns: number; totalWickets: number },
  ) {
    const match = await prisma.match.findUnique({ where: { id: matchId } });
    if (!match) return;

    let winner: "A" | "B" | null;
    let winMargin: string;

    if (inn2.totalRuns > inn1.totalRuns) {
      winner = inn2.battingTeam as "A" | "B";
      const wkLeft = 10 - inn2.totalWickets;
      winMargin = `${wkLeft} wicket${wkLeft !== 1 ? "s" : ""}`;
    } else if (inn2.totalRuns < inn1.totalRuns) {
      winner = inn1.battingTeam as "A" | "B";
      const runs = inn1.totalRuns - inn2.totalRuns;
      winMargin = `${runs} run${runs !== 1 ? "s" : ""}`;
    } else {
      winner = null;
      winMargin = "Tied";
    }

    const winnerId =
      winner === "A"
        ? match.teamAName
        : winner === "B"
          ? match.teamBName
          : null;

    await prisma.match.update({
      where: { id: matchId },
      data: {
        status: "COMPLETED",
        completedAt: new Date(),
        winnerId,
        winMargin,
      },
    });
    await performanceSvc.processVerifiedMatch(matchId, {
      allowUnverified: true,
    });
    fireStudioEvent(matchId, TriggerEventType.MATCH_COMPLETED);

    if (match.tournamentId) {
      try {
        await svc["recalculateStandingsInternal"](match.tournamentId);
      } catch (_) {}
      try {
        await svc["tryAdvanceKnockoutRound"](match.tournamentId);
      } catch (_) {}
    }
  }

  // POST /admin/matches/:id/innings/:num/ball — record a ball (admin bypass)
  app.post("/matches/:id/innings/:num/ball", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id, num } = request.params as { id: string; num: string };
    const body = recordBallRequestSchema.parse(request.body);

    // Auto-create PlayerProfile for any user who doesn't have one
    async function ensureProfile(playerId: string): Promise<string> {
      const byProfile = await prisma.playerProfile.findUnique({
        where: { id: playerId },
      });
      if (byProfile) return byProfile.id;
      const byUser = await prisma.playerProfile.findUnique({
        where: { userId: playerId },
      });
      if (byUser) return byUser.id;
      const user = await prisma.user.findUnique({ where: { id: playerId } });
      if (!user) throw new Error(`Player ${playerId} not found`);
      const created = await prisma.playerProfile.create({
        data: { userId: playerId },
      });
      return created.id;
    }

    const batterId = await ensureProfile(body.batterId);
    const bowlerId = await ensureProfile(body.bowlerId);
    const nonBatterId = body.nonBatterId
      ? await ensureProfile(body.nonBatterId).catch(() => undefined)
      : undefined;
    const fielderId = body.fielderId
      ? await ensureProfile(body.fielderId).catch(() => undefined)
      : undefined;
    const dismissedPlayerId = body.dismissedPlayerId
      ? await ensureProfile(body.dismissedPlayerId).catch(() => undefined)
      : undefined;
    const result = await matchSvc.recordBall(
      id,
      Number(num),
      user.userId,
      {
        ...body,
        batterId,
        nonBatterId,
        bowlerId,
        fielderId,
        dismissedPlayerId,
      },
      { access: "ADMIN" },
    );
    return reply.send({
      success: true,
      data: {
        ball: result.ballEvent,
        innings: result.innings,
        matchCompleted: false,
      },
    });
  });

  // DELETE /admin/matches/:id/innings/:num/last-ball — undo last delivery
  app.delete(
    "/matches/:id/innings/:num/last-ball",
    auth,
    async (request, reply) => {
      const user = (request as any).user as { userId: string };
      const { id, num } = request.params as { id: string; num: string };
      const updated = await matchSvc.undoLastBall(id, Number(num), user.userId, {
        access: "ADMIN",
      });
      return reply.send({
        success: true,
        data: updated,
      });
    },
  );

  // POST /admin/matches/:id/innings/:num/complete — close an innings
  app.post(
    "/matches/:id/innings/:num/complete",
    auth,
    async (request, reply) => {
      const user = (request as any).user as { userId: string };
      const { id, num } = request.params as { id: string; num: string };
      const updated = await matchSvc.completeInnings(
        id,
        Number(num),
        user.userId,
        { access: "ADMIN" },
      );
      return reply.send({ success: true, data: updated });
    },
  );

  // POST /admin/matches/:id/continue-innings — create next innings without follow-on (TWO_INNINGS/TEST only)
  app.post("/matches/:id/continue-innings", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    const updated = await matchSvc.continueInnings(id, user.userId, {
      access: "ADMIN",
    });
    return reply.send({ success: true, data: updated });
  });

  // POST /admin/matches/:id/innings/:num/reopen — undo accidental innings completion
  app.post(
    "/matches/:id/innings/:num/reopen",
    auth,
    async (request, reply) => {
      const user = (request as any).user as { userId: string };
      const { id, num } = request.params as { id: string; num: string };
      const updated = await matchSvc.reopenInnings(
        id,
        Number(num),
        user.userId,
        { access: "ADMIN" },
      );
      return reply.send({ success: true, data: updated });
    },
  );

  app.post("/matches/:id/followon", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    const data = await matchSvc.enforceFollowOn(id, user.userId, {
      access: "ADMIN",
    });
    return reply.send({ success: true, data });
  });

  app.post("/matches/:id/superover", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    const data = await matchSvc.createSuperOver(id, user.userId, {
      access: "ADMIN",
    });
    return reply.send({ success: true, data });
  });

  // POST /admin/matches/:id/end-of-day — advance day counter for test matches
  app.post("/matches/:id/end-of-day", auth, async (request, reply) => {
    await svc["verifyAdmin"]((request as any).user.userId);
    const { id } = request.params as { id: string };
    const match = await prisma.match.findUnique({ where: { id } });
    if (!match)
      return reply
        .status(404)
        .send({ success: false, error: { message: "Match not found" } });
    if (match.format !== "TEST")
      return reply
        .status(400)
        .send({
          success: false,
          error: { message: "Only TEST matches support end of day" },
        });
    const nextDay = (match.currentDay ?? 1) + 1;
    const updated = await prisma.match.update({
      where: { id },
      data: { currentDay: nextDay },
      include: {
        innings: {
          orderBy: { inningsNumber: "asc" },
          include: {
            ballEvents: {
              orderBy: [{ overNumber: "asc" }, { ballNumber: "asc" }],
            },
          },
        },
      },
    });
    return reply.send({ success: true, data: updated });
  });

  // Manually advance knockout bracket to next round
  app.post("/tournaments/:id/advance-round", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    const result = await svc.advanceKnockoutRound(user.userId, id);
    return reply.send({ success: true, data: result });
  });

  // Complete a match — declare winner or walkover, auto-advance knockout
  app.patch("/matches/:id/complete", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    await svc["verifyAdmin"](user.userId);
    const { id } = request.params as { id: string };
    const body = z
      .object({
        winner: z.enum(["A", "B", "NO_RESULT"]),
        isWalkover: z.boolean().optional(),
      })
      .parse(request.body);
    const data = await svc.completeMatch(user.userId, id, body);
    fireStudioEvent(id, TriggerEventType.MATCH_COMPLETED);
    return reply.send({ success: true, data });
  });

  // ── Gigs ──────────────────────────────────────────────────────────────
  app.get("/gigs", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const q = request.query as {
      search?: string;
      page?: string;
      limit?: string;
    };
    return reply.send({
      success: true,
      data: await svc.listGigs(user.userId, {
        search: q.search,
        page: Number(q.page) || 1,
        limit: Number(q.limit) || 20,
      }),
    });
  });

  app.patch("/gigs/:id/feature", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    return reply.send({
      success: true,
      data: await svc.toggleGigFeatured(user.userId, id),
    });
  });

  // ── Stores ────────────────────────────────────────────────────────────
  app.get("/stores", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const q = request.query as { search?: string; page?: string; limit?: string };
    return reply.send({
      success: true,
      data: await svc.listStores(user.userId, {
        search: q.search,
        page: Number(q.page) || 1,
        limit: Number(q.limit) || 20,
      }),
    });
  });

  app.post("/stores", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    return reply.status(201).send({
      success: true,
      data: await svc.createAdminStore(user.userId, request.body),
    });
  });

  // ── Teams ─────────────────────────────────────────────────────────────
  app.get("/teams", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const q = request.query as {
      search?: string;
      city?: string;
      page?: string;
      limit?: string;
    };
    return reply.send({
      success: true,
      data: await svc.listTeams(user.userId, {
        search: q.search,
        city: q.city,
        page: Number(q.page) || 1,
        limit: Number(q.limit) || 20,
      }),
    });
  });

  app.get("/teams/:id", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    return reply.send({
      success: true,
      data: await svc.getTeam(user.userId, id),
    });
  });

  app.post("/teams", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const TEAM_TYPES = [
      "CLUB",
      "CORPORATE",
      "ACADEMY",
      "SCHOOL",
      "COLLEGE",
      "DISTRICT",
      "STATE",
      "NATIONAL",
      "FRIENDLY",
      "GULLY",
    ] as const;
    const OPTIONAL_LOGO = z
      .string()
      .trim()
      .refine(
        (value) =>
          value.length === 0 ||
          value.startsWith("data:image/") ||
          z.string().url().safeParse(value).success,
        "Invalid logo value",
      )
      .optional()
      .transform((value) => (value ? value : undefined));
    const STAFF_ASSIGNMENT_SCHEMA = z.object({
      role: z.string().min(2),
      userId: z.string().optional(),
      name: z.string().optional(),
      phone: z.string().optional(),
    });
    const body = z
      .object({
        name: z.string().min(1),
        shortName: z.string().max(5).optional(),
        logoUrl: OPTIONAL_LOGO,
        city: z.string().optional(),
        teamType: z.enum(TEAM_TYPES).optional(),
        captainId: z.string().optional(),
        viceCaptainId: z.string().optional(),
        wicketKeeperId: z.string().optional(),
        playerIds: z.array(z.string()).optional(),
        supportStaff: z.array(STAFF_ASSIGNMENT_SCHEMA).optional(),
      })
      .parse(request.body);
    return reply.send({
      success: true,
      data: await svc.createTeam(user.userId, body),
    });
  });

  app.patch("/teams/:id", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    const TEAM_TYPES = [
      "CLUB",
      "CORPORATE",
      "ACADEMY",
      "SCHOOL",
      "COLLEGE",
      "DISTRICT",
      "STATE",
      "NATIONAL",
      "FRIENDLY",
      "GULLY",
    ] as const;
    const OPTIONAL_LOGO = z
      .string()
      .trim()
      .refine(
        (value) =>
          value.length === 0 ||
          value.startsWith("data:image/") ||
          z.string().url().safeParse(value).success,
        "Invalid logo value",
      )
      .optional()
      .nullable()
      .transform((value) => (value ? value : undefined));
    const STAFF_ASSIGNMENT_SCHEMA = z.object({
      role: z.string().min(2),
      userId: z.string().optional(),
      name: z.string().optional(),
      phone: z.string().optional(),
    });
    const body = z
      .object({
        name: z.string().min(1).optional(),
        shortName: z.string().max(5).optional(),
        logoUrl: OPTIONAL_LOGO,
        city: z.string().optional(),
        teamType: z.enum(TEAM_TYPES).optional(),
        captainId: z.string().optional(),
        viceCaptainId: z.string().optional(),
        wicketKeeperId: z.string().optional(),
        playerIds: z.array(z.string()).optional(),
        supportStaff: z.array(STAFF_ASSIGNMENT_SCHEMA).optional(),
        isActive: z.boolean().optional(),
      })
      .parse(request.body);
    return reply.send({
      success: true,
      data: await svc.updateTeam(user.userId, id, body),
    });
  });

  app.delete("/teams/:id", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    return reply.send({
      success: true,
      data: await svc.deleteTeam(user.userId, id),
    });
  });

  app.post("/teams/:id/players", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    const body = z.object({ playerId: z.string().min(1) }).parse(request.body);
    return reply.send({
      success: true,
      data: await svc.addPlayerToTeam(user.userId, id, body.playerId),
    });
  });

  app.post("/teams/:id/players/quick-add", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    const body = z
      .object({
        name: z.string().min(2),
        countryCode: z.string().regex(/^\+\d{1,4}$/),
        mobileNumber: z.string().regex(/^\d{10}$/),
      })
      .parse(request.body);
    return reply.send({
      success: true,
      data: await svc.quickAddPlayerToTeam(user.userId, id, body),
    });
  });

  app.delete("/teams/:id/players/:playerId", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id, playerId } = request.params as { id: string; playerId: string };
    return reply.send({
      success: true,
      data: await svc.removePlayerFromTeam(user.userId, id, playerId),
    });
  });

  // ── Tournament Groups ─────────────────────────────────────────────────
  app.get("/tournaments/:id/groups", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    return reply.send({
      success: true,
      data: await svc.getTournamentGroups(user.userId, id),
    });
  });

  app.post("/tournaments/:id/groups", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    const body = z
      .object({
        groupNames: z.array(z.string().min(1)).min(1),
        autoAssign: z.boolean().optional(),
      })
      .parse(request.body);
    return reply.send({
      success: true,
      data: await svc.createTournamentGroups(
        user.userId,
        id,
        body.groupNames,
        body.autoAssign,
      ),
    });
  });

  app.patch(
    "/tournaments/:id/teams/:teamId/assign-group",
    auth,
    async (request, reply) => {
      const user = (request as any).user as { userId: string };
      const { id, teamId } = request.params as { id: string; teamId: string };
      const body = z
        .object({ groupId: z.string().nullable() })
        .parse(request.body);
      return reply.send({
        success: true,
        data: await svc.assignTeamToGroup(
          user.userId,
          id,
          teamId,
          body.groupId,
        ),
      });
    },
  );

  app.patch(
    "/tournaments/:id/teams/:teamId/confirm",
    auth,
    async (request, reply) => {
      const user = (request as any).user as { userId: string };
      const { teamId } = request.params as { id: string; teamId: string };
      const body = z.object({ isConfirmed: z.boolean() }).parse(request.body);
      return reply.send({
        success: true,
        data: await svc.confirmTournamentTeam(
          user.userId,
          teamId,
          body.isConfirmed,
        ),
      });
    },
  );

  // ── Tournament Standings & Schedule ───────────────────────────────────
  app.get("/tournaments/:id/standings", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    return reply.send({
      success: true,
      data: await svc.getTournamentStandings(user.userId, id),
    });
  });

  app.post(
    "/tournaments/:id/recalculate-standings",
    auth,
    async (request, reply) => {
      const user = (request as any).user as { userId: string };
      const { id } = request.params as { id: string };
      return reply.send({
        success: true,
        data: await svc.recalculateStandings(user.userId, id),
      });
    },
  );

  app.get("/tournaments/:id/schedule", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    return reply.send({
      success: true,
      data: await svc.getTournamentSchedule(user.userId, id),
    });
  });

  app.post(
    "/tournaments/:id/generate-schedule",
    auth,
    async (request, reply) => {
      const user = (request as any).user as { userId: string };
      const { id } = request.params as { id: string };
      const body = z
        .object({
          startDate: z.string().datetime(),
          matchIntervalHours: z.number().min(1).max(72).default(24),
        })
        .parse(request.body);
      return reply.send({
        success: true,
        data: await svc.generateSchedule(
          user.userId,
          id,
          body.startDate,
          body.matchIntervalHours,
        ),
      });
    },
  );

  app.post("/tournaments/:id/smart-schedule", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    const body = z
      .object({
        startDate: z.string(),
        matchStartTime: z.string().regex(/^\d{2}:\d{2}$/),
        matchesPerDay: z.number().int().min(1).max(10).default(2),
        gapBetweenMatchesHours: z.number().min(1).max(12).default(3),
        validWeekdays: z.array(z.number().int().min(0).max(6)).min(1),
        excludeDates: z.array(z.string()).optional(),
      })
      .parse(request.body);
    return reply.send({
      success: true,
      data: await svc.generateSmartSchedule(user.userId, id, body),
    });
  });

  app.delete("/tournaments/:id/schedule", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    return reply.send({
      success: true,
      data: await svc.deleteSchedule(user.userId, id),
    });
  });

  // One-click auto-generate: uses tournament's own dates + format, no params needed
  app.post("/tournaments/:id/auto-generate", auth, async (request, reply) => {
    const user = (request as any).user as { userId: string };
    const { id } = request.params as { id: string };
    const body = request.body as { matchesPerDay?: number } | undefined;

    const tournament = await prisma.tournament.findUnique({
      where: { id },
      include: { teams: { where: { isConfirmed: true } } },
    });
    if (!tournament)
      return reply
        .status(404)
        .send({ success: false, error: { message: "Tournament not found" } });
    if (tournament.teams.length < 2)
      return reply.status(400).send({
        success: false,
        error: { message: "Need at least 2 confirmed teams" },
      });

    const existingCount = await prisma.match.count({
      where: { tournamentId: id },
    });
    if (existingCount > 0)
      return reply.status(400).send({
        success: false,
        error: {
          message: `${existingCount} fixtures already exist. Delete them first to regenerate.`,
        },
      });

    const isKnockout =
      tournament.tournamentFormat === "KNOCKOUT" ||
      tournament.tournamentFormat === "DOUBLE_ELIMINATION";
    const totalMatches = isKnockout
      ? Math.floor(tournament.teams.length / 2)
      : (tournament.teams.length * (tournament.teams.length - 1)) / 2;

    const startDate = new Date(tournament.startDate);
    const endDate = tournament.endDate ? new Date(tournament.endDate) : null;
    let intervalHours = 24;
    if (endDate && totalMatches > 1) {
      const totalHours =
        (endDate.getTime() - startDate.getTime()) / (1000 * 60 * 60);
      intervalHours = Math.max(2, Math.floor(totalHours / totalMatches));
    }

    const now = new Date();
    // If tournament start date is in the past, use tomorrow at 9 AM
    const effectiveStartDate = startDate < now 
      ? new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1, 9, 0, 0)
      : startDate;

    const result = await svc.generateSmartSchedule(user.userId, id, {
      startDate: effectiveStartDate.toISOString().split("T")[0],
      matchStartTime: `${String(effectiveStartDate.getHours()).padStart(2, "0")}:${String(effectiveStartDate.getMinutes()).padStart(2, "0")}`,
      matchesPerDay: body?.matchesPerDay ?? 1,
      gapBetweenMatchesHours: intervalHours,
      validWeekdays: [0, 1, 2, 3, 4, 5, 6],
    });

    return reply.send({
      success: true,
      data: { ...result, intervalHours, autoCalculated: true },
    });
  });

  // POST /admin/matches/:id/reprocess — recompute index scores, MVP, facts for a completed match
  app.post('/matches/:id/reprocess', { onRequest: [(app as any).authenticate] }, async (request, reply) => {
    const { id } = request.params as { id: string }
    await performanceSvc.processVerifiedMatch(id, { allowUnverified: true })
    return reply.send({ success: true, data: { matchId: id, message: 'Reprocessed' } })
  })

  // ── Season Management ────────────────────────────────────────────────────────

  // GET /admin/season/current — active season info
  app.get('/season/current', { onRequest: [(app as any).authenticate] }, async (_request, reply) => {
    const season = await prisma.competitiveSeason.findFirst({
      where: { isActive: true },
      orderBy: { startAt: 'desc' },
    })
    const countRows = await prisma.$queryRaw<Array<{ count: bigint | number | string }>>`
      SELECT COUNT(*)::bigint AS count
      FROM public.ip_player_state
    `
    const countRaw = countRows[0]?.count ?? 0
    const totalPlayers =
      typeof countRaw === 'bigint'
        ? Number(countRaw)
        : typeof countRaw === 'number'
          ? countRaw
          : Number.parseInt(String(countRaw), 10) || 0
    return reply.send({ success: true, data: { season, totalPlayers } })
  })

  // POST /admin/season/reset — trigger 90-day season reset
  // ?dry_run=true previews what would happen without writing
  app.post('/season/reset', { onRequest: [(app as any).authenticate] }, async (request, reply) => {
    const { dry_run } = request.query as { dry_run?: string }
    const dryRun = dry_run === 'true'
    const result = await applySeasonReset(dryRun)
    return reply.send({ success: true, data: result })
  })

  // POST /admin/season/decay — trigger weekly inactivity rank decay manually
  app.post('/season/decay', { onRequest: [(app as any).authenticate] }, async (_request, reply) => {
    await applyRankDecay()
    return reply.send({ success: true, data: { message: 'Rank decay applied' } })
  })

}
