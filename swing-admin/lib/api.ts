import { getSession } from "next-auth/react";
import type {
  AdminCreateMatchRequest,
  BallOutcome as ContractBallOutcome,
  CreateTournamentRequest,
  DismissalType as ContractDismissalType,
} from "./contracts";
import { qs } from "@/lib/utils";

const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:3000";

type RequestOptions = {
  method?: "GET" | "POST" | "PATCH" | "PUT" | "DELETE";
  body?: unknown;
  token?: string;
};

export class ApiError extends Error {
  status: number;
  code?: string;

  constructor(message: string, status: number, code?: string) {
    super(message);
    this.name = "ApiError";
    this.status = status;
    this.code = code;
  }
}

export async function apiFetch<T>(
  path: string,
  options: RequestOptions = {},
): Promise<T> {
  const session = options.token ? null : await getSession();
  const token = options.token ?? session?.backendAccessToken;

  const hasBody = options.body !== undefined;
  const response = await fetch(`${API_BASE_URL}${path}`, {
    method: options.method ?? "GET",
    headers: {
      Accept: "application/json",
      ...(hasBody ? { "Content-Type": "application/json" } : {}),
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: hasBody ? JSON.stringify(options.body) : undefined,
    cache: "no-store",
  });

  const payload = await response.json().catch(() => null);

  if (!response.ok) {
    // Log full response for debugging
    console.error(`[api] ${options.method ?? "GET"} ${path} → ${response.status}`, payload);

    const message =
      payload?.error?.message ??
      (typeof payload?.error === "string" ? payload.error : null) ??
      (Array.isArray(payload?.error) ? payload.error[0]?.message : null) ??
      payload?.message ??
      `Request failed (${response.status})`;
    const code = payload?.error?.code;
    throw new ApiError(message, response.status, code);
  }

  return payload.data as T;
}

export const adminApi = {
  dashboard: () => apiFetch<DashboardData>("/admin/dashboard"),
  users: (params: UsersQuery) =>
    apiFetch<UsersResponse>(`/admin/users${qs(params)}`),
  user: (id: string) => apiFetch<UserDetail>(`/admin/users/${id}`),
  createUser: (body: CreateUserBody) =>
    apiFetch<UserDetail>(`/admin/users`, { method: "POST", body }),
  updateUser: (id: string, body: UpdateUserBody) =>
    apiFetch<UserRecord>(`/admin/users/${id}`, { method: "PATCH", body }),
  createUserProfile: (id: string, type: ManagedProfileType) =>
    apiFetch<{ message: string }>(`/admin/users/${id}/profiles`, {
      method: "POST",
      body: { type },
    }),
  deleteUserProfile: (id: string, type: ManagedProfileType) =>
    apiFetch<{ message: string }>(`/admin/users/${id}/profiles/${type}`, {
      method: "DELETE",
    }),
  blockUser: (id: string, reason: string) =>
    apiFetch<{ message: string }>(`/admin/users/${id}/block`, {
      method: "POST",
      body: { reason },
    }),
  unblockUser: (id: string) =>
    apiFetch<{ message: string }>(`/admin/users/${id}/unblock`, {
      method: "POST",
    }),
  grantRole: (id: string, role: string) =>
    apiFetch<{ message: string }>(`/admin/users/${id}/grant-role`, {
      method: "POST",
      body: { role },
    }),
  revokeRole: (id: string, role: string) =>
    apiFetch<{ message: string }>(`/admin/users/${id}/revoke-role`, {
      method: "POST",
      body: { role },
    }),
  overlayPacks: () => apiFetch<OverlayPackRecord[]>(`/admin/overlay-packs`),
  updateOverlayPack: (id: string, body: UpdateOverlayPackBody) =>
    apiFetch<OverlayPackRecord>(`/admin/overlay-packs/${id}`, {
      method: "PATCH",
      body,
    }),
  matches: (params: MatchesQuery) =>
    apiFetch<MatchesResponse>(`/admin/matches${qs(params)}`),
  match: (id: string) => apiFetch<MatchDetail>(`/admin/matches/${id}`),
  matchPlayers: (id: string) =>
    apiFetch<MatchPlayersResponse>(`/admin/matches/${id}/players`),
  updatePlaying11: (id: string, data: Playing11Body) =>
    apiFetch<MatchDetail>(`/admin/matches/${id}/playing11`, {
      method: "PATCH",
      body: data,
    }),
  quickAddMatchPlayer: (
    id: string,
    data: { team: "A" | "B"; name: string; countryCode: string; mobileNumber: string },
  ) =>
    apiFetch<{ profileId: string; userId: string; name: string; teamId: string | null }>(
      `/admin/matches/${id}/quick-add-player`,
      { method: "POST", body: data },
    ),
  changeWicketKeeper: (
    id: string,
    data: { team: "A" | "B"; wicketKeeperId: string },
  ) =>
    apiFetch<MatchDetail>(`/admin/matches/${id}/wicketkeeper`, {
      method: "PATCH",
      body: data,
    }),
  recordToss: (
    id: string,
    data: { tossWonBy: "A" | "B"; tossDecision: "BAT" | "BOWL" },
  ) =>
    apiFetch<MatchDetail>(`/admin/matches/${id}/toss`, {
      method: "POST",
      body: data,
    }),
  recordBall: (id: string, inningsNum: number, data: BallInput) =>
    apiFetch<{ ball: BallRecord; innings: InningsRecord }>(
      `/admin/matches/${id}/innings/${inningsNum}/ball`,
      { method: "POST", body: data },
    ),
  undoLastBall: (id: string, inningsNum: number) =>
    apiFetch<{ innings: InningsRecord; removed: BallRecord; needNewBowler: boolean }>(
      `/admin/matches/${id}/innings/${inningsNum}/last-ball`,
      { method: "DELETE" },
    ),
  updateBall: (id: string, ballId: string, data: { outcome?: BallOutcome; runs?: number; extras?: number; isWicket?: boolean; dismissalType?: DismissalType | null; dismissedPlayerId?: string | null; fielderId?: string | null; wagonZone?: string | null }) =>
    apiFetch<{ innings: InningsRecord }>(
      `/admin/matches/${id}/balls/${ballId}`,
      { method: "PATCH", body: data },
    ),
  completeInnings: (id: string, inningsNum: number) =>
    apiFetch<MatchDetail & { followOnAvailable?: boolean; followOnDeficit?: number }>(
      `/admin/matches/${id}/innings/${inningsNum}/complete`,
      { method: "POST" },
    ),
  continueInnings: (id: string) =>
    apiFetch<MatchDetail>(`/admin/matches/${id}/continue-innings`, { method: "POST" }),
  reopenInnings: (id: string, inningsNum: number) =>
    apiFetch<MatchDetail>(
      `/admin/matches/${id}/innings/${inningsNum}/reopen`,
      { method: "POST" },
    ),
  deleteMatch: (id: string) =>
    apiFetch<{ deleted: string }>(`/admin/matches/${id}`, { method: "DELETE" }),
  setMatchStream: (id: string, youtubeUrl: string | null) =>
    apiFetch<{ youtubeUrl: string | null }>(`/admin/matches/${id}/stream`, { method: "PATCH", body: { youtubeUrl } }),
  getStudioScene: (id: string) =>
    apiFetch<{ scene: string; breakType: string | null; updatedAt: string }>(`/admin/matches/${id}/studio`),
  setStudioScene: (id: string, scene: string, breakType?: string | null) =>
    apiFetch<{ scene: string; breakType: string | null; updatedAt: string }>(`/admin/matches/${id}/studio`, { method: "PATCH", body: { scene, breakType: breakType ?? null } }),
  initStudio: (matchId: string) =>
    apiFetch<StudioRecord>(`/studio/${matchId}/init`, { method: "POST" }),
  studio: (matchId: string) => apiFetch<StudioRecord>(`/studio/${matchId}`),
  studioTemplates: () => apiFetch<StudioTemplate[]>(`/studio/templates`),
  setStudioActiveScene: (matchId: string, sceneId: string | null) =>
    apiFetch<{ activeSceneId: string | null; current: StudioCurrentResponse }>(
      `/studio/${matchId}/active-scene`,
      { method: "PATCH", body: { sceneId } },
    ),
  createStudioScene: (
    matchId: string,
    body: {
      name: string;
      sceneType: SceneType;
      templateId: string;
      dataOverrides?: Record<string, unknown>;
      isAutomatic?: boolean;
      displayOrder?: number;
    },
  ) => apiFetch<StudioSceneRecord>(`/studio/${matchId}/scenes`, { method: "POST", body }),
  updateStudioScene: (
    matchId: string,
    sceneId: string,
    body: {
      name?: string;
      templateId?: string;
      dataOverrides?: Record<string, unknown>;
      displayOrder?: number;
      isAutomatic?: boolean;
    },
  ) => apiFetch<StudioSceneRecord>(`/studio/${matchId}/scenes/${sceneId}`, { method: "PATCH", body }),
  deleteStudioScene: (matchId: string, sceneId: string) =>
    apiFetch<{ deleted: string }>(`/studio/${matchId}/scenes/${sceneId}`, { method: "DELETE" }),
  createStudioTrigger: (
    matchId: string,
    body: {
      eventType: TriggerEventType;
      targetSceneId: string;
      delaySeconds?: number;
      isEnabled?: boolean;
    },
  ) => apiFetch<StudioTriggerRecord>(`/studio/${matchId}/triggers`, { method: "POST", body }),
  updateStudioTrigger: (
    matchId: string,
    triggerId: string,
    body: {
      eventType?: TriggerEventType;
      targetSceneId?: string;
      delaySeconds?: number;
      isEnabled?: boolean;
    },
  ) => apiFetch<StudioTriggerRecord>(`/studio/${matchId}/triggers/${triggerId}`, { method: "PATCH", body }),
  deleteStudioTrigger: (matchId: string, triggerId: string) =>
    apiFetch<{ deleted: string }>(`/studio/${matchId}/triggers/${triggerId}`, { method: "DELETE" }),
  createStudioAd: (
    matchId: string,
    body: {
      type: AdSlotType;
      title: string;
      mediaUrl?: string | null;
      brandName?: string | null;
      brandLogoUrl?: string | null;
      durationSeconds: number;
    },
  ) => apiFetch<StudioAdRecord>(`/studio/${matchId}/ads`, { method: "POST", body }),
  updateStudioAd: (
    matchId: string,
    adId: string,
    body: {
      type?: AdSlotType;
      title?: string;
      mediaUrl?: string | null;
      brandName?: string | null;
      brandLogoUrl?: string | null;
      durationSeconds?: number;
      adBreakEnabled?: boolean;
    },
  ) => apiFetch<StudioAdRecord>(`/studio/${matchId}/ads/${adId}`, { method: "PATCH", body }),
  deleteStudioAd: (matchId: string, adId: string) =>
    apiFetch<{ deleted: string }>(`/studio/${matchId}/ads/${adId}`, { method: "DELETE" }),
  reorderStudioAds: (matchId: string, orderedIds: string[]) =>
    apiFetch<{ orderedIds: string[] }>(`/studio/${matchId}/ads/reorder`, {
      method: "PATCH",
      body: { orderedIds },
    }),
  updateStudioSettings: (
    matchId: string,
    body: { adBreakEnabled?: boolean; adBreakDurationSeconds?: number },
  ) => apiFetch<{ id: string; adBreakEnabled: boolean; adBreakDurationSeconds: number }>(
    `/studio/${matchId}/settings`,
    { method: "PATCH", body },
  ),
  getStudioCurrent: (matchId: string) =>
    apiFetch<StudioCurrentResponse>(`/studio/${matchId}/current`, { token: "" }),
  // Live stream management
  startLiveStream: (id: string, youtubeStreamKey?: string) =>
    apiFetch<{ matchId: string; status: string; cameraPageUrl: string; wsUrl: string; hlsUrl: string; startedAt: string }>(`/admin/matches/${id}/stream/start`, { method: "POST", body: { youtubeStreamKey } }),
  stopLiveStream: (id: string) =>
    apiFetch<{ message: string }>(`/admin/matches/${id}/stream/stop`, { method: "POST" }),
  getLiveStreamStatus: (id: string) =>
    apiFetch<{ matchId: string; status: string; cameraPageUrl: string; wsUrl: string; hlsUrl: string; startedAt: string; error?: string } | null>(`/admin/matches/${id}/stream`),
  getLiveSession: (matchId: string) =>
    apiFetch<{ matchId: string; bitrateKbps: number; fps: number; droppedFrames: number; networkQuality: string; quality: string; youtubeUrl?: string; startedAt: string } | null>(`/live/session/${matchId}`),
  setInningsState: (id: string, inningsNum: number, data: { strikerId?: string | null; nonStrikerId?: string | null; bowlerId?: string | null }) =>
    apiFetch(`/matches/${id}/innings/${inningsNum}/state`, { method: "PATCH", body: data }),
  startSuperOver: (id: string) =>
    apiFetch(`/admin/matches/${id}/superover`, { method: "POST" }),
  enforceFollowOn: (id: string) =>
    apiFetch(`/admin/matches/${id}/followon`, { method: "POST" }),
  verifyMatch: (id: string, level: VerificationLevel) =>
    apiFetch(`/admin/matches/${id}/verify`, {
      method: "POST",
      body: { level },
    }),
  addHighlight: (id: string, data: { title: string; url: string }) =>
    apiFetch<MatchDetail>(`/admin/matches/${id}/highlights`, { method: "POST", body: data }),
  deleteHighlight: (id: string, highlightId: string) =>
    apiFetch<MatchDetail>(`/admin/matches/${id}/highlights/${highlightId}`, { method: "DELETE" }),
  payments: (params: PaymentsQuery) =>
    apiFetch<PaymentsResponse>(`/admin/payments${qs(params)}`),
  events: (params: PaginationQuery & { search?: string; status?: string }) =>
    apiFetch<EventsResponse>(`/admin/events${qs(params)}`),
  broadcast: (body: BroadcastBody) =>
    apiFetch(`/admin/notifications/broadcast`, { method: "POST", body }),
  academies: (params: PaginationQuery) =>
    apiFetch<AcademiesResponse>(`/admin/academies${qs(params)}`),
  verifyAcademy: (id: string, verify: boolean) =>
    apiFetch(
      `/admin/academies/${id}/${verify ? "verify" : "revoke-verification"}`,
      { method: "PATCH" },
    ),

  // Arenas
  arenas: (params: PaginationQuery & { search?: string; city?: string }) =>
    apiFetch<ArenasResponse>(`/admin/arenas${qs(params)}`),
  arena: (id: string) => apiFetch<ArenaDetail>(`/admin/arenas/${id}`),
  createArena: (data: CreateArenaBody) =>
    apiFetch<ArenaDetail>(`/admin/arenas`, { method: "POST", body: data }),
  updateArena: (id: string, data: UpdateArenaBody) =>
    apiFetch<ArenaDetail>(`/admin/arenas/${id}`, { method: "PATCH", body: data }),
  verifyArena: (id: string, arenaGrade: string) =>
    apiFetch(`/admin/arenas/${id}/verify`, {
      method: "PATCH",
      body: { arenaGrade },
    }),
  toggleSwingArena: (id: string) =>
    apiFetch(`/admin/arenas/${id}/toggle-swing`, { method: "PATCH" }),

  // Coaches
  coaches: (params: PaginationQuery & { search?: string }) =>
    apiFetch<CoachesResponse>(`/admin/coaches${qs(params)}`),
  verifyCoach: (id: string, isVerified: boolean) =>
    apiFetch(`/admin/coaches/${id}/verify`, {
      method: "PATCH",
      body: { isVerified },
    }),
  updateCoach: (id: string, data: Partial<CoachProfileUpdate>) =>
    apiFetch(`/admin/coaches/${id}`, { method: "PATCH", body: data }),

  // Players
  updatePlayer: (id: string, data: Partial<PlayerProfileUpdate>) =>
    apiFetch(`/admin/players/${id}`, { method: "PATCH", body: data }),
  updateArenaOwner: (id: string, data: Partial<ArenaOwnerProfileUpdate>) =>
    apiFetch(`/admin/arena-owners/${id}`, { method: "PATCH", body: data }),

  // Tournaments
  tournaments: (
    params: PaginationQuery & { search?: string; status?: string },
  ) => apiFetch<TournamentsResponse>(`/admin/tournaments${qs(params)}`),
  tournament: (id: string) =>
    apiFetch<TournamentRecord>(`/admin/tournaments/${id}`),
  createTournament: (data: CreateTournamentBody) =>
    apiFetch<TournamentRecord>(`/admin/tournaments`, {
      method: "POST",
      body: data,
    }),
  updateTournament: (
    id: string,
    data: Partial<CreateTournamentBody & { status: string }>,
  ) => apiFetch(`/admin/tournaments/${id}`, { method: "PATCH", body: data }),
  tournamentTeams: (id: string) =>
    apiFetch<TournamentTeam[]>(`/admin/tournaments/${id}/teams`),
  addTournamentTeam: (
    id: string,
    data: {
      teamId?: string;
      teamName?: string;
      captainId?: string;
      playerIds?: string[];
    },
  ) =>
    apiFetch<TournamentTeam>(`/admin/tournaments/${id}/teams`, {
      method: "POST",
      body: data,
    }),
  removeTournamentTeam: (tournamentId: string, teamId: string) =>
    apiFetch(`/admin/tournaments/${tournamentId}/teams/${teamId}`, {
      method: "DELETE",
    }),
  deleteTournament: (id: string) =>
    apiFetch(`/admin/tournaments/${id}`, { method: "DELETE" }),

  // Admin match creation
  createMatch: (data: CreateMatchBody) =>
    apiFetch<{ id: string }>(`/admin/matches`, { method: "POST", body: data }),

  // Venues
  venues: (q?: string) =>
    apiFetch<VenueRecord[]>(
      `/admin/venues${q ? `?q=${encodeURIComponent(q)}` : ""}`,
    ),
  venuesFull: (q?: string) =>
    apiFetch<VenueFullRecord[]>(
      `/admin/venues?full=1${q ? `&q=${encodeURIComponent(q)}` : ""}`,
    ),

  // Teams
  teams: (params: PaginationQuery & { search?: string; city?: string }) =>
    apiFetch<TeamsResponse>(`/admin/teams${qs(params)}`),
  team: (id: string) => apiFetch<TeamDetail>(`/admin/teams/${id}`),
  createTeam: (data: CreateTeamBody) =>
    apiFetch<TeamRecord>(`/admin/teams`, { method: "POST", body: data }),
  updateTeam: (
    id: string,
    data: Partial<CreateTeamBody & { isActive: boolean }>,
  ) =>
    apiFetch<TeamRecord>(`/admin/teams/${id}`, { method: "PATCH", body: data }),
  deleteTeam: (id: string) =>
    apiFetch(`/admin/teams/${id}`, { method: "DELETE" }),
  addPlayerToTeam: (id: string, playerId: string) =>
    apiFetch(`/admin/teams/${id}/players`, {
      method: "POST",
      body: { playerId },
    }),
  quickAddPlayerToTeam: (
    id: string,
    data: { name: string; countryCode: string; mobileNumber: string },
  ) =>
    apiFetch(`/admin/teams/${id}/players/quick-add`, {
      method: "POST",
      body: data,
    }),
  removePlayerFromTeam: (id: string, playerId: string) =>
    apiFetch(`/admin/teams/${id}/players/${playerId}`, { method: "DELETE" }),
  // Tournament groups
  tournamentGroups: (id: string) =>
    apiFetch<TournamentGroupRecord[]>(`/admin/tournaments/${id}/groups`),
  createTournamentGroups: (
    id: string,
    groupNames: string[],
    autoAssign?: boolean,
  ) =>
    apiFetch<TournamentGroupRecord[]>(`/admin/tournaments/${id}/groups`, {
      method: "POST",
      body: { groupNames, autoAssign },
    }),
  assignTeamToGroup: (
    tournamentId: string,
    teamId: string,
    groupId: string | null,
  ) =>
    apiFetch(
      `/admin/tournaments/${tournamentId}/teams/${teamId}/assign-group`,
      { method: "PATCH", body: { groupId } },
    ),
  confirmTournamentTeam: (
    tournamentId: string,
    teamId: string,
    isConfirmed: boolean,
  ) =>
    apiFetch(`/admin/tournaments/${tournamentId}/teams/${teamId}/confirm`, {
      method: "PATCH",
      body: { isConfirmed },
    }),
  // Standings
  tournamentStandings: (id: string) =>
    apiFetch<StandingsResponse>(`/admin/tournaments/${id}/standings`),
  recalculateStandings: (id: string) =>
    apiFetch(`/admin/tournaments/${id}/recalculate-standings`, {
      method: "POST",
    }),
  // Schedule
  tournamentSchedule: (id: string) =>
    apiFetch<ScheduleMatch[]>(`/admin/tournaments/${id}/schedule`),
  generateSchedule: (
    id: string,
    data: { startDate: string; matchIntervalHours: number },
  ) =>
    apiFetch(`/admin/tournaments/${id}/generate-schedule`, {
      method: "POST",
      body: data,
    }),
  smartSchedule: (
    id: string,
    data: {
      startDate: string;
      matchStartTime: string;
      matchesPerDay: number;
      gapBetweenMatchesHours: number;
      validWeekdays: number[];
      excludeDates?: string[];
    },
  ) =>
    apiFetch(`/admin/tournaments/${id}/smart-schedule`, {
      method: "POST",
      body: data,
    }),
  deleteSchedule: (id: string) =>
    apiFetch(`/admin/tournaments/${id}/schedule`, { method: "DELETE" }),
  startMatch: (id: string) =>
    apiFetch(`/admin/matches/${id}/start`, { method: "PATCH" }),
  completeMatch: (
    id: string,
    data: { winner: "A" | "B" | "NO_RESULT"; isWalkover?: boolean },
  ) =>
    apiFetch(`/admin/matches/${id}/complete`, { method: "PATCH", body: data }),
  advanceKnockoutRound: (tournamentId: string) =>
    apiFetch<{
      advanced: boolean;
      round?: string;
      matches?: number;
      reason?: string;
    }>(`/admin/tournaments/${tournamentId}/advance-round`, { method: "POST" }),

  // Gigs
  gigs: (params: PaginationQuery & { search?: string }) =>
    apiFetch<GigsResponse>(`/admin/gigs${qs(params)}`),
  toggleGigFeatured: (id: string) =>
    apiFetch(`/admin/gigs/${id}/feature`, { method: "PATCH" }),

  // Support
  supportTickets: (
    params: PaginationQuery & {
      status?: string;
      priority?: string;
      category?: string;
    },
  ) => apiFetch<SupportTicketsResponse>(`/admin/support${qs(params)}`),
  supportTicket: (id: string) =>
    apiFetch<SupportTicketDetail>(`/admin/support/${id}`),
  addSupportMessage: (id: string, message: string) =>
    apiFetch(`/admin/support/${id}/message`, {
      method: "POST",
      body: { message },
    }),
  assignSupportTicket: (id: string, agentId: string) =>
    apiFetch(`/admin/support/${id}/assign`, {
      method: "POST",
      body: { agentId },
    }),
  resolveSupportTicket: (id: string, resolution: string) =>
    apiFetch(`/admin/support/${id}/resolve`, {
      method: "POST",
      body: { resolution },
    }),
  closeSupportTicket: (id: string) =>
    apiFetch(`/admin/support/${id}/close`, { method: "POST" }),

  // Config
  configs: () => apiFetch<ConfigRecord[]>(`/admin/config`),
  updateConfig: (key: string, value: string) =>
    apiFetch(`/admin/config/${key}`, { method: "PUT", body: { value } }),
  sessionTypes: () => apiFetch<SessionTypeRecord[]>(`/admin/session-types`),
  createSessionType: (body: CreateSessionTypeBody) =>
    apiFetch<SessionTypeRecord>(`/admin/session-types`, { method: "POST", body }),
  updateSessionType: (id: string, body: Partial<CreateSessionTypeBody>) =>
    apiFetch<SessionTypeRecord>(`/admin/session-types/${id}`, { method: "PATCH", body }),
  deleteSessionType: (id: string) =>
    apiFetch<{ deleted: string }>(`/admin/session-types/${id}`, { method: "DELETE" }),
  skillAreas: (roleTag?: RoleTag) =>
    apiFetch<SkillAreaRecord[]>(`/admin/skill-areas${roleTag ? qs({ roleTag }) : ""}`),
  createSkillArea: (body: CreateSkillAreaBody) =>
    apiFetch<SkillAreaRecord>(`/admin/skill-areas`, { method: "POST", body }),
  updateSkillArea: (id: string, body: Partial<CreateSkillAreaBody>) =>
    apiFetch<SkillAreaRecord>(`/admin/skill-areas/${id}`, { method: "PATCH", body }),
  deleteSkillArea: (id: string) =>
    apiFetch<{ deleted: string }>(`/admin/skill-areas/${id}`, { method: "DELETE" }),
  watchFlags: (roleTag?: RoleTag) =>
    apiFetch<WatchFlagRecord[]>(`/admin/watch-flags${roleTag ? qs({ roleTag }) : ""}`),
  createWatchFlag: (body: CreateWatchFlagBody) =>
    apiFetch<WatchFlagRecord>(`/admin/watch-flags`, { method: "POST", body }),
  updateWatchFlag: (id: string, body: Partial<CreateWatchFlagBody>) =>
    apiFetch<WatchFlagRecord>(`/admin/watch-flags/${id}`, { method: "PATCH", body }),
  deleteWatchFlag: (id: string) =>
    apiFetch<{ deleted: string }>(`/admin/watch-flags/${id}`, { method: "DELETE" }),
  drills: (params?: { role?: RoleTag; category?: DrillCategory; includeInactive?: boolean }) =>
    apiFetch<DrillLibraryRecord[]>(
      `/admin/drills${qs({
        role: params?.role,
        category: params?.category,
        includeInactive: params?.includeInactive ? 1 : undefined,
      })}`,
    ),
  createDrill: (body: CreateDrillLibraryBody) =>
    apiFetch<DrillLibraryRecord>(`/admin/drills`, { method: "POST", body }),
  updateDrill: (id: string, body: Partial<CreateDrillLibraryBody>) =>
    apiFetch<DrillLibraryRecord>(`/admin/drills/${id}`, { method: "PATCH", body }),
  deleteDrill: (id: string) =>
    apiFetch<{ deleted: string }>(`/admin/drills/${id}`, { method: "DELETE" }),
};

export type DashboardData = {
  users: { total: number; players: number; coaches: number };
  academies: { total: number };
  arenas: { total: number };
  matches: { total: number; active: number };
  bookings: { total: number; completed: number };
  gigs: { completed: number };
  revenue: { totalPaise: number };
};

export type PaginationQuery = { page?: number; limit?: number };
export type UsersQuery = PaginationQuery & { role?: string; search?: string };
export type MatchesQuery = PaginationQuery & {
  status?: string;
  matchType?: string;
  search?: string;
};
export type PaymentsQuery = PaginationQuery & { status?: string };
export type VerificationLevel = "LEVEL_1" | "LEVEL_2" | "LEVEL_3";
export type ManagedProfileType =
  | "PLAYER"
  | "COACH"
  | "ACADEMY_OWNER"
  | "ARENA_OWNER";
export type UserRole =
  | "PLAYER"
  | "COACH"
  | "ACADEMY_OWNER"
  | "ARENA_OWNER"
  | "PARENT"
  | "SWING_ADMIN"
  | "SWING_SUPPORT";

export type UserRecord = {
  id: string;
  name: string;
  phone: string;
  email?: string | null;
  roles: string[];
  activeRole: string | null;
  isBlocked: boolean;
  isVerified?: boolean;
  isActive?: boolean;
  avatarUrl?: string | null;
  createdAt: string;
};

export type UsersResponse = {
  users: UserRecord[];
  total: number;
  page: number;
  limit: number;
};

export type UserBadge = {
  id: string;
  awardedAt: string;
  awardedReason?: string | null;
  badge: {
    id: string;
    name: string;
    category: string;
    description: string;
    isRare: boolean;
    xpReward: number;
  };
};

export type UserXpTransaction = {
  id: string;
  xpDelta: number;
  reason: string;
  balanceAfter: number;
  createdAt: string;
};

export type UserEnrollment = {
  id: string;
  enrolledAt: string;
  feeStatus: string;
  feeAmountPaise?: number | null;
  academy: {
    id: string;
    name: string;
    city?: string | null;
    state?: string | null;
    isVerified: boolean;
  };
  batch?: { id: string; name: string; sport: string; isActive: boolean } | null;
};

export type UserSlotBooking = {
  id: string;
  date: string;
  startTime: string;
  endTime: string;
  status: string;
  totalAmountPaise: number;
  arena: { id: string; name: string; city: string; state: string };
  unit: { id: string; name: string; sport: string; unitType: string };
  payment?: {
    id: string;
    status: string;
    amountPaise: number;
    createdAt: string;
  } | null;
};

export type UserGigBooking = {
  id: string;
  scheduledAt: string;
  status: string;
  amountPaise: number;
  durationMins: number;
  gigListing: {
    id: string;
    title: string;
    city?: string | null;
    coach: { id: string; user: { id: string; name: string; phone: string } };
  };
  payment?: {
    id: string;
    status: string;
    amountPaise: number;
    createdAt: string;
  } | null;
};

export type UserSupportTicket = {
  id: string;
  category: string;
  subject: string;
  description: string;
  status: string;
  priority: string;
  createdAt: string;
  updatedAt: string;
  resolution?: string | null;
  messages: Array<{
    id: string;
    authorId: string;
    isFromSupport: boolean;
    message: string;
    createdAt: string;
  }>;
};

export type UserNotification = {
  id: string;
  type: string;
  title?: string | null;
  body: string;
  status: string;
  isRead: boolean;
  createdAt: string;
};

export type UserPayment = {
  id: string;
  amountPaise: number;
  status: string;
  entityType?: string | null;
  description?: string | null;
  createdAt: string;
};

export type UserRecentMatch = {
  id: string;
  matchType: string;
  format: string;
  status: string;
  teamAName: string;
  teamBName: string;
  createdAt: string;
  innings: Array<{
    inningsNumber: number;
    totalRuns: number;
    totalWickets: number;
    isCompleted: boolean;
  }>;
};

export type UserTournamentEntry = {
  id: string;
  teamName: string;
  isConfirmed: boolean;
  registeredAt: string;
  tournament: {
    id: string;
    name: string;
    status: string;
    format: string;
    startDate: string;
    endDate?: string | null;
    city?: string | null;
    venueName?: string | null;
    academy?: { id: string; name: string } | null;
  };
  group?: { id: string; name: string } | null;
  standing?: {
    position: number;
    played: number;
    won: number;
    lost: number;
    tied: number;
    noResult: number;
    points: number;
    nrr: number;
  } | null;
};

export type PlayerSummary = {
  swingIndex: number;
  swingRank: string;
  totalXp: number;
  rankXp: number;
  matchesPlayed: number;
  matchesWon: number;
  matchWinPct: number;
  totalRuns: number;
  battingAverage: number;
  strikeRate: number;
  highestScore: number;
  fours: number;
  sixes: number;
  totalWickets: number;
  economyRate: number;
  bowlingAverage: number;
  bestBowling?: string | null;
  catches: number;
  stumpings: number;
  runOuts: number;
  academyCount: number;
  tournamentCount: number;
  matchCount: number;
  completedMatchCount: number;
};

export type UserDetail = UserRecord & {
  counts?: Record<string, number>;
  playerSummary?: PlayerSummary | null;
  playerProfile?: Record<string, unknown> & {
    id: string;
    playerBadges?: UserBadge[];
    xpTransactions?: UserXpTransaction[];
    academyEnrollments?: UserEnrollment[];
    slotBookings?: UserSlotBooking[];
    gigBookings?: UserGigBooking[];
  };
  coachProfile?: Record<string, unknown>;
  academyOwnerProfile?: Record<string, unknown>;
  arenaOwnerProfile?: Record<string, unknown>;
  payments?: UserPayment[];
  notifications?: UserNotification[];
  supportTickets?: UserSupportTicket[];
  recentMatches?: UserRecentMatch[];
  tournamentEntries?: UserTournamentEntry[];
};

export type CreateUserBody = {
  name: string;
  phone: string;
  email?: string;
  roles: UserRole[];
  activeRole?: UserRole;
  isVerified?: boolean;
  isActive?: boolean;
  createProfiles?: ManagedProfileType[];
  playerProfile?: {
    city?: string;
    state?: string;
    bio?: string;
    goals?: string;
    level?: string;
    playerRole?: string;
    battingStyle?: string;
    bowlingStyle?: string;
    dateOfBirth?: string;
    jerseyNumber?: number;
  };
  coachProfile?: {
    city?: string;
    state?: string;
    bio?: string;
    experienceYears?: number;
    specializations?: string[];
  };
  arenaOwnerProfile?: {
    businessName?: string;
    gstNumber?: string;
    panNumber?: string;
  };
};

export type UpdateUserBody = {
  name?: string;
  phone?: string;
  email?: string | null;
  activeRole?: UserRole;
  isVerified?: boolean;
  isActive?: boolean;
  avatarUrl?: string | null;
};

export type MatchRecord = {
  id: string;
  overlayPackId?: string | null;
  status: string;
  matchType: string;
  teamAName: string;
  teamBName: string;
  scheduledAt: string;
  venueName?: string | null;
  round?: string | null;
  tournamentId?: string | null;
  format?: string;
  verificationLevel?: string | null;
  createdAt: string;
  customOvers?: number | null;
  testDays?: number | null;
  oversPerDay?: number | null;
  currentDay?: number | null;
  innings: Array<{
    inningsNumber: number;
    totalRuns: number;
    totalWickets: number;
    isCompleted: boolean;
  }>;
  overlayPack?: OverlayPackSummary | null;
};

export type MatchesResponse = {
  matches: MatchRecord[];
  total: number;
  page: number;
  limit: number;
};

export type PaymentRecord = {
  id: string;
  amountPaise: number;
  status: string;
  entityType: string;
  createdAt: string;
  user: { name: string | null; phone: string | null };
};

export type PaymentsResponse = {
  payments: PaymentRecord[];
  total: number;
  totalRevenuePaise: number;
  page: number;
  limit: number;
};

export type BroadcastBody = {
  title: string;
  body: string;
  userIds?: string[];
  roles?: string[];
};

export type AcademyRecord = {
  id: string;
  name: string;
  city?: string | null;
  createdAt: string;
  owner?: {
    user?: {
      name?: string | null;
      phone?: string | null;
    };
  } | null;
  [key: string]: unknown;
};

export type AcademiesResponse = {
  academies: AcademyRecord[];
  total: number;
  page: number;
  limit: number;
};

export type ArenaRecord = {
  id: string;
  ownerId?: string;
  name: string;
  description?: string | null;
  photoUrls?: string[] | null;
  city: string;
  state: string;
  address?: string | null;
  pincode?: string | null;
  latitude?: number;
  longitude?: number;
  phone?: string | null;
  sports?: string[] | null;
  hasParking?: boolean;
  hasLights?: boolean;
  hasWashrooms?: boolean;
  hasCanteen?: boolean;
  hasCCTV?: boolean;
  hasScorer?: boolean;
  openTime?: string;
  closeTime?: string;
  operatingDays?: number[] | null;
  advanceBookingDays?: number;
  bufferMins?: number;
  cancellationHours?: number;
  planTier?: string;
  planExpiresAt?: string | null;
  isVerified: boolean;
  isSwingArena: boolean;
  arenaGrade?: string | null;
  verifiedAt?: string | null;
  rating?: number;
  totalRatings?: number;
  isActive?: boolean;
  createdAt: string;
  updatedAt?: string;
  owner?: { user?: { name?: string | null; phone?: string | null } } | null;
  [key: string]: unknown;
};
export type ArenasResponse = {
  arenas: ArenaRecord[];
  total: number;
  page: number;
  limit: number;
};

export type EventRecord = {
  id: string;
  createdByUserId: string;
  name: string;
  eventType: string;
  description?: string | null;
  venueName?: string | null;
  city?: string | null;
  scheduledAt?: string | null;
  status: string;
  isPublic: boolean;
  createdAt: string;
  updatedAt: string;
  createdByUser?: {
    id?: string;
    name?: string | null;
    phone?: string | null;
  } | null;
  [key: string]: unknown;
};

export type EventsResponse = {
  events: EventRecord[];
  total: number;
  page: number;
  limit: number;
};

export type ArenaAddonRecord = {
  id: string;
  arenaId: string;
  name: string;
  description?: string | null;
  pricePaise: number;
  unit: string;
  isAvailable: boolean;
  [key: string]: unknown;
};

export type ArenaUnitRecord = {
  id: string;
  arenaId: string;
  name: string;
  unitType: string;
  sport: string;
  capacity: number;
  description?: string | null;
  photoUrls?: string[] | null;
  pricePerHourPaise: number;
  peakPricePaise?: number | null;
  peakHoursStart?: string | null;
  peakHoursEnd?: string | null;
  weekendMultiplier: number;
  minSlotMins: number;
  maxSlotMins: number;
  slotIncrementMins: number;
  isActive: boolean;
  createdAt?: string;
  [key: string]: unknown;
};

export type ArenaOwnerSummary = {
  id: string;
  businessName?: string | null;
  gstNumber?: string | null;
  panNumber?: string | null;
  user?: {
    id?: string;
    name?: string | null;
    phone?: string | null;
  } | null;
  [key: string]: unknown;
};

export type ArenaDetail = ArenaRecord & {
  ownerId: string;
  address: string;
  pincode: string;
  latitude: number;
  longitude: number;
  sports?: string[] | null;
  hasParking: boolean;
  hasLights: boolean;
  hasWashrooms: boolean;
  hasCanteen: boolean;
  hasCCTV: boolean;
  hasScorer: boolean;
  openTime: string;
  closeTime: string;
  operatingDays?: number[] | null;
  advanceBookingDays: number;
  bufferMins: number;
  cancellationHours: number;
  planTier: string;
  isActive: boolean;
  rating: number;
  totalRatings: number;
  updatedAt: string;
  owner?: ArenaOwnerSummary | null;
  addons?: ArenaAddonRecord[] | null;
  units?: ArenaUnitRecord[] | null;
};

export type ArenaAddonInput = {
  id?: string;
  name: string;
  description?: string;
  pricePaise: number;
  unit?: string;
  isAvailable?: boolean;
};

export type ArenaUnitInput = {
  id?: string;
  name: string;
  unitType: string;
  sport: string;
  capacity?: number;
  description?: string;
  photoUrls?: string[];
  pricePerHourPaise: number;
  peakPricePaise?: number | null;
  peakHoursStart?: string;
  peakHoursEnd?: string;
  weekendMultiplier?: number;
  minSlotMins?: number;
  maxSlotMins?: number;
  slotIncrementMins?: number;
  isActive?: boolean;
};

export type CreateArenaBody = {
  ownerId: string;
  name: string;
  description?: string;
  photoUrls?: string[];
  city: string;
  state: string;
  address: string;
  pincode: string;
  latitude: number;
  longitude: number;
  phone?: string;
  sports?: string[];
  hasParking?: boolean;
  hasLights?: boolean;
  hasWashrooms?: boolean;
  hasCanteen?: boolean;
  hasCCTV?: boolean;
  hasScorer?: boolean;
  openTime?: string;
  closeTime?: string;
  operatingDays?: number[];
  advanceBookingDays?: number;
  bufferMins?: number;
  cancellationHours?: number;
  planTier?: string;
  planExpiresAt?: string;
  isVerified?: boolean;
  isSwingArena?: boolean;
  arenaGrade?: string;
  rating?: number;
  totalRatings?: number;
  isActive?: boolean;
  addons?: ArenaAddonInput[];
  units?: ArenaUnitInput[];
};

export type UpdateArenaBody = Partial<CreateArenaBody>;

export type CoachRecord = {
  id: string;
  userId: string;
  city?: string | null;
  isVerified: boolean;
  verifiedAt?: string | null;
  rating: number;
  totalSessions: number;
  experienceYears: number;
  createdAt: string;
  user: { id: string; name: string; phone: string; avatarUrl?: string | null };
  [key: string]: unknown;
};
export type CoachesResponse = {
  coaches: CoachRecord[];
  total: number;
  page: number;
  limit: number;
};

export type PlayerProfileUpdate = {
  level?: string;
  playerRole?: string;
  battingStyle?: string;
  bowlingStyle?: string;
  city?: string;
  state?: string;
  bio?: string;
  goals?: string;
  dateOfBirth?: string;
  jerseyNumber?: number;
  verificationLevel?: string;
  swingIndex?: number;
};

export type CoachProfileUpdate = {
  bio?: string;
  specializations?: string[];
  certifications?: string[];
  experienceYears?: number;
  city?: string;
  state?: string;
  gigEnabled?: boolean;
  hourlyRate?: number | null;
  isVerified?: boolean;
};

export type ArenaOwnerProfileUpdate = {
  businessName?: string;
  gstNumber?: string;
  panNumber?: string;
};

export type TournamentRecord = {
  id: string;
  overlayPackId?: string | null;
  name: string;
  format: string;
  tournamentFormat: string;
  seriesMatchCount?: number | null;
  sport: string;
  status: string;
  startDate: string;
  endDate?: string | null;
  city?: string | null;
  venueName?: string | null;
  maxTeams: number;
  groupCount: number;
  pointsForWin: number;
  pointsForLoss: number;
  pointsForTie: number;
  pointsForNoResult: number;
  isVerified: boolean;
  logoUrl?: string | null;
  coverUrl?: string | null;
  slug?: string | null;
  highlights?: { title: string; youtubeUrl: string }[];
  createdAt: string;
  teams: TournamentTeam[];
  academy?: { name: string } | null;
  overlayPack?: OverlayPackSummary | null;
  [key: string]: unknown;
};
export type TournamentsResponse = {
  tournaments: TournamentRecord[];
  total: number;
  page: number;
  limit: number;
};

export type TournamentTeam = {
  id: string;
  tournamentId: string;
  teamId?: string | null;
  teamName: string;
  captainId?: string | null;
  playerIds: string[];
  isConfirmed: boolean;
  groupId?: string | null;
  seed?: number | null;
  registeredAt: string;
};

export type CreateTournamentBody = CreateTournamentRequest;

export type TeamType =
  | "CLUB"
  | "CORPORATE"
  | "ACADEMY"
  | "SCHOOL"
  | "COLLEGE"
  | "DISTRICT"
  | "STATE"
  | "NATIONAL"
  | "FRIENDLY"
  | "GULLY";

export type CreateTeamBody = {
  name: string;
  shortName?: string;
  logoUrl?: string;
  city?: string;
  teamType?: TeamType;
  captainId?: string;
  viceCaptainId?: string;
  wicketKeeperId?: string;
  playerIds?: string[];
  supportStaff?: TeamStaffAssignment[];
};

export type TeamStaffAssignment = {
  role: string;
  userId?: string;
  name?: string;
  phone?: string;
  user?: {
    id: string;
    name: string;
    phone?: string | null;
    avatarUrl?: string | null;
  } | null;
};

export type TeamRecord = {
  id: string;
  name: string;
  shortName?: string | null;
  logoUrl?: string | null;
  city?: string | null;
  teamType: TeamType;
  captainId?: string | null;
  viceCaptainId?: string | null;
  wicketKeeperId?: string | null;
  playerIds: string[];
  supportStaff?: TeamStaffAssignment[] | null;
  isActive: boolean;
  createdAt: string;
  [key: string]: unknown;
};

export type TeamDetail = TeamRecord & {
  players: Array<{
    id: string;
    userId: string;
    user: {
      id: string;
      name: string;
      avatarUrl?: string | null;
      phone?: string | null;
    };
  }>;
  roleAssignments?: {
    captain?: TeamDetail["players"][number] | null;
    viceCaptain?: TeamDetail["players"][number] | null;
    wicketKeeper?: TeamDetail["players"][number] | null;
  };
  supportStaffResolved?: TeamStaffAssignment[];
  tournamentEntries?: Array<{
    id: string;
    teamName: string;
    isConfirmed: boolean;
    registeredAt: string;
    tournament: {
      id: string;
      name: string;
      status: string;
      format: string;
      startDate: string;
      endDate?: string | null;
      city?: string | null;
      venueName?: string | null;
    };
    group?: { id: string; name: string } | null;
    standing?: {
      position: number;
      played: number;
      won: number;
      lost: number;
      points: number;
      nrr: number;
    } | null;
  }>;
  recentMatches?: Array<{
    id: string;
    teamAName: string;
    teamBName: string;
    format: string;
    status: string;
    createdAt: string;
  }>;
};

export type TeamsResponse = {
  teams: TeamRecord[];
  total: number;
  page: number;
  limit: number;
};

export type TournamentGroupRecord = {
  id: string;
  tournamentId: string;
  name: string;
  groupOrder: number;
  teams?: Array<{
    id: string;
    teamName: string;
    isConfirmed: boolean;
    seed?: number | null;
    teamId?: string | null;
  }>;
};

export type StandingRow = {
  id: string;
  tournamentId: string;
  groupId?: string | null;
  tournamentTeamId: string;
  position: number;
  played: number;
  won: number;
  lost: number;
  tied: number;
  noResult: number;
  points: number;
  nrr: number;
  team: { id: string; teamName: string; isConfirmed: boolean };
  group?: { id: string; name: string } | null;
};

export type StandingsResponse = Record<string, StandingRow[]>;

export type ScheduleMatch = {
  id: string;
  teamAName: string;
  teamBName: string;
  format: string;
  status: string;
  scheduledAt: string;
  venueName?: string | null;
  round?: string | null;
  winnerId?: string | null;
  winMargin?: string | null;
  innings: Array<{
    inningsNumber: number;
    totalRuns: number;
    totalWickets: number;
    totalOvers: number;
    isCompleted: boolean;
  }>;
};

export type CreateMatchBody = AdminCreateMatchRequest;

export type VenueRecord = {
  id: string;
  name: string;
  city?: string | null;
  aliases: string[];
};

export type VenueFullRecord = {
  id: string;
  name: string;
  city?: string | null;
  address?: string | null;
  aliases: string[];
  createdAt: string;
  _count: { matches: number };
};

export type GigRecord = {
  id: string;
  title: string;
  city?: string | null;
  pricePaise: number;
  isActive: boolean;
  isFeatured: boolean;
  totalBookings: number;
  rating: number;
  createdAt: string;
  coach: { user: { name: string; phone: string } };
  [key: string]: unknown;
};
export type GigsResponse = {
  gigs: GigRecord[];
  total: number;
  page: number;
  limit: number;
};

export type SupportTicketRecord = {
  id: string;
  category: string;
  subject: string;
  status: string;
  priority: string;
  assignedTo?: string | null;
  createdAt: string;
  user: { name: string | null; phone: string | null };
  [key: string]: unknown;
};
export type SupportTicketsResponse = {
  tickets: SupportTicketRecord[];
  total: number;
  page: number;
};
export type SupportTicketDetail = {
  ticket: SupportTicketRecord;
  messages: Array<{
    id: string;
    authorId: string;
    isFromSupport: boolean;
    message: string;
    createdAt: string;
  }>;
};

export type ConfigRecord = {
  id: string;
  key: string;
  value: string;
  description?: string | null;
  updatedAt: string;
};

export type RoleTag =
  | "BATSMAN"
  | "BOWLER"
  | "ALL_ROUNDER"
  | "FIELDER"
  | "WICKET_KEEPER";

export type WatchSeverity = "MONITOR" | "URGENT";

export type DrillCategory =
  | "TECHNIQUE"
  | "FITNESS"
  | "MENTAL"
  | "MATCH_SIMULATION";

export type DrillTargetUnit =
  | "BALLS"
  | "OVERS"
  | "MINUTES"
  | "REPS"
  | "SESSIONS";

export type SessionTypeRecord = {
  id: string;
  name: string;
  color: string;
  defaultDurationMinutes: number;
  isActive: boolean;
  createdAt?: string;
  updatedAt?: string;
};

export type SkillAreaRecord = {
  id: string;
  name: string;
  roleTag: RoleTag;
  isActive: boolean;
  createdAt?: string;
  updatedAt?: string;
};

export type WatchFlagRecord = {
  id: string;
  name: string;
  roleTag: RoleTag;
  severity: WatchSeverity;
  description?: string | null;
  isActive: boolean;
  createdAt?: string;
  updatedAt?: string;
};

export type DrillLibraryRecord = {
  id: string;
  name: string;
  description?: string | null;
  videoUrl?: string | null;
  roleTags: RoleTag[];
  category: DrillCategory;
  targetUnit: DrillTargetUnit;
  isActive: boolean;
  createdByCoachId?: string | null;
  createdAt?: string;
  updatedAt?: string;
};

export type CreateSessionTypeBody = {
  name: string;
  color: string;
  defaultDurationMinutes?: number;
  isActive?: boolean;
};

export type CreateSkillAreaBody = {
  name: string;
  roleTag: RoleTag;
  isActive?: boolean;
};

export type CreateWatchFlagBody = {
  name: string;
  roleTag: RoleTag;
  severity?: WatchSeverity;
  description?: string;
  isActive?: boolean;
};

export type CreateDrillLibraryBody = {
  name: string;
  description?: string;
  videoUrl?: string;
  roleTags: RoleTag[];
  category: DrillCategory;
  targetUnit: DrillTargetUnit;
  isActive?: boolean;
};

// ─── Match scoring types ──────────────────────────────────────────────────────

export type BallOutcome = ContractBallOutcome;
export type DismissalType = ContractDismissalType;

export type BallRecord = {
  id: string;
  inningsId: string;
  overNumber: number;
  ballNumber: number;
  batterId: string;
  bowlerId: string;
  fielderId?: string | null;
  outcome: BallOutcome;
  runs: number;
  extras: number;
  totalRuns: number;
  isWicket: boolean;
  dismissalType?: DismissalType | null;
  dismissedPlayerId?: string | null;
  tags: string[];
  wagonZone?: string | null;
  scoreAfterBall?: string | null;
  scoredAt: string;
};

export type InningsRecord = {
  id: string;
  matchId: string;
  inningsNumber: number;
  battingTeam: string;
  totalRuns: number;
  totalWickets: number;
  totalOvers: number;
  extras: number;
  isDeclared: boolean;
  isCompleted: boolean;
  isSuperOver?: boolean;
  currentStrikerId?: string | null;
  currentNonStrikerId?: string | null;
  currentBowlerId?: string | null;
  isFreeHit?: boolean;
  ballEvents?: BallRecord[];
};

export type MatchDetail = {
  id: string;
  matchType: string;
  format: string;
  status: string;
  teamAName: string;
  teamBName: string;
  teamAPlayerIds: string[];
  teamBPlayerIds: string[];
  teamACaptainId?: string | null;
  teamBCaptainId?: string | null;
  tossWonBy?: string | null;
  tossDecision?: string | null;
  scheduledAt: string;
  startedAt?: string | null;
  completedAt?: string | null;
  venueName?: string | null;
  round?: string | null;
  tournamentId?: string | null;
  winnerId?: string | null;
  winMargin?: string | null;
  verificationLevel?: string | null;
  createdAt: string;
  testDays?: number | null;
  oversPerDay?: number | null;
  currentDay?: number | null;
  customOvers?: number | null;
  innings: InningsRecord[];
  highlights?: Array<{ id: string; title: string; url: string }> | null;
  youtubeUrl?: string | null;
  liveCode?: string | null;
  livePin?: string | null;
  overlayPackId?: string | null;
  overlayPack?: OverlayPackSummary | null;
  effectiveOverlayPack?: {
    source: "MATCH" | "TOURNAMENT" | "DEFAULT";
    pack: OverlayPackRecord;
  } | null;
};

export type OverlayPackKind = "DEFAULT" | "TOURNAMENT" | "CUSTOM";

export type OverlayPackSummary = {
  id: string;
  code: string;
  name: string;
  kind: OverlayPackKind;
  isDefault: boolean;
};

export type OverlayPackRecord = OverlayPackSummary & {
  description?: string | null;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
  config?: Record<string, unknown>;
};

export type UpdateOverlayPackBody = {
  name?: string;
  code?: string;
  kind?: OverlayPackKind;
  description?: string | null;
  isActive?: boolean;
  isDefault?: boolean;
};

export type MatchPlayer = {
  profileId: string;
  userId: string;
  name: string;
  avatarUrl?: string | null;
};

export type MatchPlayersResponse = {
  teamA: {
    name: string;
    teamId?: string | null;
    captainId?: string | null;
    viceCaptainId?: string | null;
    wicketKeeperId?: string | null;
    players: MatchPlayer[];
  };
  teamB: {
    name: string;
    teamId?: string | null;
    captainId?: string | null;
    viceCaptainId?: string | null;
    wicketKeeperId?: string | null;
    players: MatchPlayer[];
  };
};

export type Playing11Body = {
  teamAPlayerIds: string[];
  teamBPlayerIds: string[];
  teamACaptainId?: string;
  teamBCaptainId?: string;
  teamAViceCaptainId?: string;
  teamBViceCaptainId?: string;
  teamAWicketKeeperId?: string;
  teamBWicketKeeperId?: string;
  customOvers?: number;
};

export type BallInput = {
  batterId: string;
  nonBatterId?: string;
  bowlerId: string;
  fielderId?: string;
  overNumber: number;
  ballNumber: number;
  outcome: BallOutcome;
  runs: number;
  extras: number;
  isWicket: boolean;
  dismissalType?: DismissalType;
  dismissedPlayerId?: string;
  switchEnds?: boolean;
  tags?: string[];
  wagonZone?: string;
};

export type SceneType =
  | "PRE_MATCH"
  | "LIVE_SCORE"
  | "OVER_BREAK"
  | "INNINGS_BREAK"
  | "AD_BREAK"
  | "POST_MATCH"
  | "CUSTOM";

export type TriggerEventType =
  | "MATCH_STARTED"
  | "TOSS_DONE"
  | "OVER_COMPLETED"
  | "INNINGS_COMPLETED"
  | "MATCH_COMPLETED"
  | "WICKET_FALLEN";

export type AdSlotType = "IMAGE" | "VIDEO" | "BRAND";

export type StudioTemplateSchema = {
  type?: string;
  title?: string;
  properties?: Record<string, StudioTemplateSchema>;
};

export type StudioTemplate = {
  id: string;
  name: string;
  supportedSceneTypes: SceneType[];
  defaultData: Record<string, unknown>;
  schema: StudioTemplateSchema;
};

export type StudioSceneRecord = {
  id: string;
  studioId: string;
  name: string;
  sceneType: SceneType;
  templateId: string;
  dataOverrides: Record<string, unknown>;
  isAutomatic: boolean;
  displayOrder: number;
  createdAt: string;
};

export type StudioTriggerRecord = {
  id: string;
  studioId: string;
  eventType: TriggerEventType;
  targetSceneId: string;
  delaySeconds: number;
  isEnabled: boolean;
};

export type StudioAdRecord = {
  id: string;
  studioId: string;
  type: AdSlotType;
  title: string;
  mediaUrl?: string | null;
  brandName?: string | null;
  brandLogoUrl?: string | null;
  durationSeconds: number;
  displayOrder: number;
};

export type StudioCurrentResponse =
  | {
      active: false;
    }
  | {
      active: true;
      sceneType: SceneType;
      templateId: string;
      data: Record<string, any>;
      adSlot: Record<string, any> | null;
    };

export type StudioRecord = {
  id: string;
  matchId: string;
  activeSceneId: string | null;
  adBreakEnabled: boolean;
  adBreakDurationSeconds: number;
  createdAt: string;
  updatedAt: string;
  scenes: StudioSceneRecord[];
  triggers: StudioTriggerRecord[];
  adSlots: StudioAdRecord[];
  templates: StudioTemplate[];
  current: StudioCurrentResponse;
};
