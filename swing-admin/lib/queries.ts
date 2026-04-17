"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";
import {
  adminApi,
  apiFetch,
  type BroadcastBody,
  type CoachProfileUpdate,
  type CreateUserBody,
  type CreateMatchBody,
  type CreateTournamentBody,
  type ManagedProfileType,
  type MatchesQuery,
  type PaginationQuery,
  type PaymentsQuery,
  type PlayerProfileUpdate,
  type UpdateUserBody,
  type UsersQuery,
  type VerificationLevel,
} from "@/lib/api";

export function useDashboardQuery() {
  return useQuery({
    queryKey: ["dashboard"],
    queryFn: adminApi.dashboard,
  });
}

export function useUsersQuery(params: UsersQuery) {
  return useQuery({
    queryKey: ["users", params],
    queryFn: () => adminApi.users(params),
  });
}

export function useUserDetailQuery(id: string | null) {
  return useQuery({
    queryKey: ["user", id],
    queryFn: () => adminApi.user(id!),
    enabled: Boolean(id),
  });
}

export function useAcademiesQuery(params: PaginationQuery) {
  return useQuery({
    queryKey: ["academies", params],
    queryFn: () => adminApi.academies(params),
  });
}

export function useMatchesQuery(params: MatchesQuery) {
  return useQuery({
    queryKey: ["matches", params],
    queryFn: () => adminApi.matches(params),
  });
}

export function useOverlayPacksQuery() {
  return useQuery({
    queryKey: ["overlay-packs"],
    queryFn: adminApi.overlayPacks,
  });
}

export function usePaymentsQuery(params: PaymentsQuery) {
  return useQuery({
    queryKey: ["payments", params],
    queryFn: () => adminApi.payments(params),
  });
}

export function useEventsQuery(
  params: Parameters<typeof adminApi.events>[0],
) {
  return useQuery({
    queryKey: ["events", params],
    queryFn: () => adminApi.events(params),
  });
}

function invalidateAdmin(queryClient: ReturnType<typeof useQueryClient>) {
  queryClient.invalidateQueries({ queryKey: ["dashboard"] });
  queryClient.invalidateQueries({ queryKey: ["users"] });
  queryClient.invalidateQueries({ queryKey: ["matches"] });
  queryClient.invalidateQueries({ queryKey: ["payments"] });
  queryClient.invalidateQueries({ queryKey: ["academies"] });
  queryClient.invalidateQueries({ queryKey: ["overlay-packs"] });
}

export function useBlockUserMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, reason }: { id: string; reason: string }) =>
      adminApi.blockUser(id, reason),
    onSuccess: () => {
      invalidateAdmin(queryClient);
      toast.success("User blocked");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}

export function useCreateUserMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (body: CreateUserBody) => adminApi.createUser(body),
    onSuccess: () => {
      invalidateAdmin(queryClient);
      toast.success("User created");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}

export function useUpdateUserMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: UpdateUserBody }) =>
      adminApi.updateUser(id, data),
    onSuccess: (_, variables) => {
      invalidateAdmin(queryClient);
      queryClient.invalidateQueries({ queryKey: ["user", variables.id] });
      toast.success("User updated");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}

export function useUpdateOverlayPackMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({
      id,
      data,
    }: {
      id: string;
      data: import("@/lib/api").UpdateOverlayPackBody;
    }) => adminApi.updateOverlayPack(id, data),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ["overlay-packs"] });
      queryClient.invalidateQueries({ queryKey: ["overlay-pack", variables.id] });
      toast.success("Overlay updated");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}

export function useCreateUserProfileMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, type }: { id: string; type: ManagedProfileType }) =>
      adminApi.createUserProfile(id, type),
    onSuccess: (_, variables) => {
      invalidateAdmin(queryClient);
      queryClient.invalidateQueries({ queryKey: ["user", variables.id] });
      toast.success("Profile created");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}

export function useDeleteUserProfileMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, type }: { id: string; type: ManagedProfileType }) =>
      adminApi.deleteUserProfile(id, type),
    onSuccess: (_, variables) => {
      invalidateAdmin(queryClient);
      queryClient.invalidateQueries({ queryKey: ["user", variables.id] });
      toast.success("Profile deleted");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}

export function useUnblockUserMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => adminApi.unblockUser(id),
    onSuccess: () => {
      invalidateAdmin(queryClient);
      toast.success("User unblocked");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}

export function useRoleMutation(kind: "grant" | "revoke") {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, role }: { id: string; role: string }) =>
      kind === "grant"
        ? adminApi.grantRole(id, role)
        : adminApi.revokeRole(id, role),
    onSuccess: (_, variables) => {
      invalidateAdmin(queryClient);
      toast.success(
        `${kind === "grant" ? "Granted" : "Revoked"} ${variables.role}`,
      );
    },
    onError: (error: Error) => toast.error(error.message),
  });
}

export function useVerifyMatchMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, level }: { id: string; level: VerificationLevel }) =>
      adminApi.verifyMatch(id, level),
    onSuccess: () => {
      invalidateAdmin(queryClient);
      toast.success("Match verified");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}

export function useAddHighlightMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: { title: string; url: string } }) =>
      adminApi.addHighlight(id, data),
    onSuccess: (_, { id }) => {
      queryClient.invalidateQueries({ queryKey: ["match-detail", id] });
      toast.success("Highlight added");
    },
    onError: (e: Error) => toast.error(e.message),
  });
}

export function useDeleteHighlightMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, highlightId }: { id: string; highlightId: string }) =>
      adminApi.deleteHighlight(id, highlightId),
    onSuccess: (_, { id }) => {
      queryClient.invalidateQueries({ queryKey: ["match-detail", id] });
      toast.success("Highlight removed");
    },
    onError: (e: Error) => toast.error(e.message),
  });
}

export function useBroadcastMutation() {
  return useMutation({
    mutationFn: (body: BroadcastBody) => adminApi.broadcast(body),
    onSuccess: () => toast.success("Broadcast sent"),
    onError: (error: Error) => toast.error(error.message),
  });
}

// Academies - verify
export function useVerifyAcademyMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, verify }: { id: string; verify: boolean }) =>
      adminApi.verifyAcademy(id, verify),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["academies"] });
      toast.success("Academy verification updated");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}

// Arenas
export function useArenasQuery(params: Parameters<typeof adminApi.arenas>[0]) {
  return useQuery({
    queryKey: ["arenas", params],
    queryFn: () => adminApi.arenas(params),
  });
}
export function useArenaQuery(id: string | null) {
  return useQuery({
    queryKey: ["arena", id],
    queryFn: () => adminApi.arena(id!),
    enabled: Boolean(id),
  });
}
export function useCreateArenaMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (data: import("@/lib/api").CreateArenaBody) =>
      adminApi.createArena(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["arenas"] });
      toast.success("Arena created");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}
export function useUpdateArenaMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({
      id,
      data,
    }: {
      id: string;
      data: import("@/lib/api").UpdateArenaBody;
    }) => adminApi.updateArena(id, data),
    onSuccess: (_, v) => {
      queryClient.invalidateQueries({ queryKey: ["arenas"] });
      queryClient.invalidateQueries({ queryKey: ["arena", v.id] });
      toast.success("Arena updated");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}
export function useVerifyArenaMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, arenaGrade }: { id: string; arenaGrade: string }) =>
      adminApi.verifyArena(id, arenaGrade),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["arenas"] });
      toast.success("Arena verified");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}
export function useToggleSwingArenaMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => adminApi.toggleSwingArena(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["arenas"] });
      toast.success("Swing arena status toggled");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}

// Coaches
export function useCoachesQuery(
  params: Parameters<typeof adminApi.coaches>[0],
) {
  return useQuery({
    queryKey: ["coaches", params],
    queryFn: () => adminApi.coaches(params),
  });
}
export function useVerifyCoachMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, isVerified }: { id: string; isVerified: boolean }) =>
      adminApi.verifyCoach(id, isVerified),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["coaches"] });
      toast.success("Coach verification updated");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}
export function useUpdateCoachMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: CoachProfileUpdate }) =>
      adminApi.updateCoach(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["users"] });
      queryClient.invalidateQueries({ queryKey: ["user"] });
      toast.success("Coach profile updated");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}

// Players
export function useUpdatePlayerMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: PlayerProfileUpdate }) =>
      adminApi.updatePlayer(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["users"] });
      queryClient.invalidateQueries({ queryKey: ["user"] });
      toast.success("Player profile updated");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}

export function useUpdateArenaOwnerMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({
      id,
      data,
    }: {
      id: string;
      data: { businessName?: string; gstNumber?: string; panNumber?: string };
    }) => adminApi.updateArenaOwner(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["users"] });
      queryClient.invalidateQueries({ queryKey: ["user"] });
      toast.success("Arena owner profile updated");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}

// Tournaments
export function useTournamentsQuery(
  params: Parameters<typeof adminApi.tournaments>[0],
) {
  return useQuery({
    queryKey: ["tournaments", params],
    queryFn: () => adminApi.tournaments(params),
  });
}
export function useTournamentQuery(id: string) {
  return useQuery({
    queryKey: ["tournament", id],
    queryFn: () => adminApi.tournament(id),
    enabled: Boolean(id),
  });
}
export function useCreateTournamentMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (data: CreateTournamentBody) => adminApi.createTournament(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["tournaments"] });
      toast.success("Tournament created");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}
export function useUpdateTournamentMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: any }) =>
      adminApi.updateTournament(id, data),
    onSuccess: (_, { id }) => {
      queryClient.invalidateQueries({ queryKey: ["tournaments"] });
      queryClient.invalidateQueries({ queryKey: ["tournament", id] });
      toast.success("Tournament updated");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}
export function useTournamentTeamsQuery(id: string) {
  return useQuery({
    queryKey: ["tournament-teams", id],
    queryFn: () => adminApi.tournamentTeams(id),
    enabled: Boolean(id),
  });
}
export function useAddTournamentTeamMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({
      tournamentId,
      data,
    }: {
      tournamentId: string;
      data: {
        teamId?: string;
        teamName?: string;
        captainId?: string;
        playerIds?: string[];
      };
    }) => adminApi.addTournamentTeam(tournamentId, data),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({
        queryKey: ["tournament-teams", variables.tournamentId],
      });
      queryClient.invalidateQueries({ queryKey: ["tournaments"] });
      queryClient.invalidateQueries({ queryKey: ["teams"] });
      toast.success("Team added");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}
export function useRemoveTournamentTeamMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({
      tournamentId,
      teamId,
    }: {
      tournamentId: string;
      teamId: string;
    }) => adminApi.removeTournamentTeam(tournamentId, teamId),
    onSuccess: (_, v) => {
      queryClient.invalidateQueries({
        queryKey: ["tournament-teams", v.tournamentId],
      });
      queryClient.invalidateQueries({ queryKey: ["tournaments"] });
      toast.success("Team removed");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}
export function useDeleteTournamentMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => adminApi.deleteTournament(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["tournaments"] });
      toast.success("Tournament deleted");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}

// Matches - create
export function useCreateMatchMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (data: CreateMatchBody) => adminApi.createMatch(data),
    onSuccess: (_, vars) => {
      queryClient.invalidateQueries({ queryKey: ["matches"] });
      if (vars.tournamentId) {
        queryClient.invalidateQueries({ queryKey: ["tournament-schedule", vars.tournamentId] });
      }
      toast.success("Match created");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}

// Gigs
export function useGigsQuery(params: Parameters<typeof adminApi.gigs>[0]) {
  return useQuery({
    queryKey: ["gigs", params],
    queryFn: () => adminApi.gigs(params),
  });
}
export function useToggleGigFeaturedMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => adminApi.toggleGigFeatured(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["gigs"] });
      toast.success("Gig featured status toggled");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}

// Support
export function useSupportTicketsQuery(
  params: Parameters<typeof adminApi.supportTickets>[0],
) {
  return useQuery({
    queryKey: ["support-tickets", params],
    queryFn: () => adminApi.supportTickets(params),
  });
}
export function useSupportTicketQuery(id: string | null) {
  return useQuery({
    queryKey: ["support-ticket", id],
    queryFn: () => adminApi.supportTicket(id!),
    enabled: Boolean(id),
  });
}
export function useAddSupportMessageMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, message }: { id: string; message: string }) =>
      adminApi.addSupportMessage(id, message),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({
        queryKey: ["support-ticket", variables.id],
      });
      toast.success("Message sent");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}
export function useResolveSupportTicketMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, resolution }: { id: string; resolution: string }) =>
      adminApi.resolveSupportTicket(id, resolution),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["support-tickets"] });
      toast.success("Ticket resolved");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}
export function useCloseSupportTicketMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => adminApi.closeSupportTicket(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["support-tickets"] });
      toast.success("Ticket closed");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}

// Config
export function useConfigsQuery() {
  return useQuery({ queryKey: ["configs"], queryFn: adminApi.configs });
}
export function useUpdateConfigMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ key, value }: { key: string; value: string }) =>
      adminApi.updateConfig(key, value),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["configs"] });
      toast.success("Config updated");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}

// ── Teams ────────────────────────────────────────────────────────────
export function useVenuesQuery(q: string) {
  return useQuery({
    queryKey: ["venues", q],
    queryFn: () => adminApi.venues(q || undefined),
    staleTime: 30_000,
  });
}

export function useVenuesFullQuery(q?: string) {
  return useQuery({
    queryKey: ["venues-full", q],
    queryFn: () => adminApi.venuesFull(q || undefined),
    staleTime: 30_000,
  });
}

export function useTeamsQuery(params: Parameters<typeof adminApi.teams>[0]) {
  return useQuery({
    queryKey: ["teams", params],
    queryFn: () => adminApi.teams(params),
  });
}
export function useTeamQuery(id: string | null) {
  return useQuery({
    queryKey: ["team", id],
    queryFn: () => adminApi.team(id!),
    enabled: Boolean(id),
  });
}
export function useCreateTeamMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (data: import("@/lib/api").CreateTeamBody) =>
      adminApi.createTeam(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["teams"] });
      toast.success("Team created");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}
export function useUpdateTeamMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: any }) =>
      adminApi.updateTeam(id, data),
    onSuccess: (_, v) => {
      queryClient.invalidateQueries({ queryKey: ["teams"] });
      queryClient.invalidateQueries({ queryKey: ["team", v.id] });
      toast.success("Team updated");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}
export function useDeleteTeamMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => adminApi.deleteTeam(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["teams"] });
      toast.success("Team deleted");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}
export function useAddPlayerToTeamMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ teamId, playerId }: { teamId: string; playerId: string }) =>
      adminApi.addPlayerToTeam(teamId, playerId),
    onSuccess: (_, v) => {
      queryClient.invalidateQueries({ queryKey: ["team", v.teamId] });
      queryClient.invalidateQueries({ queryKey: ["teams"] });
      toast.success("Player added");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}
export function useQuickAddPlayerToTeamMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({
      teamId,
      data,
    }: {
      teamId: string;
      data: { name: string; countryCode: string; mobileNumber: string };
    }) => adminApi.quickAddPlayerToTeam(teamId, data),
    onSuccess: (_, v) => {
      queryClient.invalidateQueries({ queryKey: ["team", v.teamId] });
      queryClient.invalidateQueries({ queryKey: ["teams"] });
      toast.success("Player created and added");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}
export function useRemovePlayerFromTeamMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ teamId, playerId }: { teamId: string; playerId: string }) =>
      adminApi.removePlayerFromTeam(teamId, playerId),
    onSuccess: (_, v) => {
      queryClient.invalidateQueries({ queryKey: ["team", v.teamId] });
      queryClient.invalidateQueries({ queryKey: ["teams"] });
      toast.success("Player removed");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}

// ── Tournament Groups ─────────────────────────────────────────────────
export function useTournamentGroupsQuery(id: string) {
  return useQuery({
    queryKey: ["tournament-groups", id],
    queryFn: () => adminApi.tournamentGroups(id),
    enabled: Boolean(id),
  });
}
export function useCreateTournamentGroupsMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({
      id,
      groupNames,
      autoAssign,
    }: {
      id: string;
      groupNames: string[];
      autoAssign?: boolean;
    }) => adminApi.createTournamentGroups(id, groupNames, autoAssign),
    onSuccess: (_, v) => {
      queryClient.invalidateQueries({ queryKey: ["tournament-groups", v.id] });
      queryClient.invalidateQueries({ queryKey: ["tournament-teams", v.id] });
      toast.success(
        v.autoAssign
          ? "Groups created & teams auto-assigned"
          : "Groups created",
      );
    },
    onError: (error: Error) => toast.error(error.message),
  });
}
export function useAssignTeamToGroupMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({
      tournamentId,
      teamId,
      groupId,
    }: {
      tournamentId: string;
      teamId: string;
      groupId: string | null;
    }) => adminApi.assignTeamToGroup(tournamentId, teamId, groupId),
    onSuccess: (_, v) => {
      queryClient.invalidateQueries({
        queryKey: ["tournament-groups", v.tournamentId],
      });
      queryClient.invalidateQueries({
        queryKey: ["tournament-teams", v.tournamentId],
      });
      toast.success("Team assigned to group");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}
export function useConfirmTournamentTeamMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({
      tournamentId,
      teamId,
      isConfirmed,
    }: {
      tournamentId: string;
      teamId: string;
      isConfirmed: boolean;
    }) => adminApi.confirmTournamentTeam(tournamentId, teamId, isConfirmed),
    onSuccess: (_, v) => {
      queryClient.invalidateQueries({
        queryKey: ["tournament-teams", v.tournamentId],
      });
      queryClient.invalidateQueries({
        queryKey: ["tournament-groups", v.tournamentId],
      });
      toast.success(v.isConfirmed ? "Team confirmed" : "Team unconfirmed");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}

// ── Tournament Standings & Schedule ───────────────────────────────────
export function useTournamentStandingsQuery(id: string) {
  return useQuery({
    queryKey: ["tournament-standings", id],
    queryFn: () => adminApi.tournamentStandings(id),
    enabled: Boolean(id),
  });
}
export function useRecalculateStandingsMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => adminApi.recalculateStandings(id),
    onSuccess: (_, id) => {
      queryClient.invalidateQueries({ queryKey: ["tournament-standings", id] });
      toast.success("Standings recalculated");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}
export function useTournamentScheduleQuery(id: string) {
  return useQuery({
    queryKey: ["tournament-schedule", id],
    queryFn: () => adminApi.tournamentSchedule(id),
    enabled: Boolean(id),
  });
}
export function useGenerateScheduleMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({
      id,
      data,
    }: {
      id: string;
      data: { startDate: string; matchIntervalHours: number };
    }) => adminApi.generateSchedule(id, data),
    onSuccess: (_, v) => {
      queryClient.invalidateQueries({
        queryKey: ["tournament-schedule", v.id],
      });
      toast.success("Schedule generated");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}
export function useSmartScheduleMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({
      id,
      data,
    }: {
      id: string;
      data: Parameters<typeof adminApi.smartSchedule>[1];
    }) => adminApi.smartSchedule(id, data),
    onSuccess: (_, v) => {
      queryClient.invalidateQueries({
        queryKey: ["tournament-schedule", v.id],
      });
      toast.success("Schedule generated!");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}
export function useDeleteScheduleMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => adminApi.deleteSchedule(id),
    onSuccess: (_, id) => {
      queryClient.invalidateQueries({ queryKey: ["tournament-schedule", id] });
      toast.success("Schedule deleted");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}
export function useStartMatchMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({
      matchId,
      tournamentId,
    }: {
      matchId: string;
      tournamentId: string;
    }) => adminApi.startMatch(matchId),
    onSuccess: (_, v) => {
      queryClient.invalidateQueries({
        queryKey: ["tournament-schedule", v.tournamentId],
      });
      toast.success("Match started!");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}

export function useAdvanceKnockoutRoundMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (tournamentId: string) =>
      adminApi.advanceKnockoutRound(tournamentId),
    onSuccess: (data, tournamentId) => {
      queryClient.invalidateQueries({
        queryKey: ["tournament-schedule", tournamentId],
      });
      queryClient.invalidateQueries({
        queryKey: ["tournament-standings", tournamentId],
      });
      if (data.advanced) {
        toast.success(`${data.round} created with ${data.matches} match(es)!`);
      } else {
        const detail = (data as any).debug ? ` — ${(data as any).debug}` : "";
        toast.error((data.reason ?? "Could not advance round") + detail);
      }
    },
    onError: (error: Error) => toast.error(error.message),
  });
}

export function useCompleteMatchMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({
      matchId,
      tournamentId,
      winner,
      isWalkover,
    }: {
      matchId: string;
      tournamentId: string;
      winner: "A" | "B" | "NO_RESULT";
      isWalkover?: boolean;
    }) => adminApi.completeMatch(matchId, { winner, isWalkover }),
    onSuccess: (_, v) => {
      // Refresh schedule (may have new knockout round created), standings, brackets
      queryClient.invalidateQueries({
        queryKey: ["tournament-schedule", v.tournamentId],
      });
      queryClient.invalidateQueries({
        queryKey: ["tournament-standings", v.tournamentId],
      });
      toast.success(v.isWalkover ? "Walkover recorded!" : "Result saved!");
    },
    onError: (error: Error) => toast.error(error.message),
  });
}

// ─── Match scoring hooks ──────────────────────────────────────────────────────

export function useMatchDetailQuery(id: string | null) {
  return useQuery({
    queryKey: ["match-detail", id],
    queryFn: () => adminApi.match(id!),
    enabled: !!id,
    refetchInterval: 5000, // poll every 5s during live match
  });
}

export function useMatchPlayersQuery(id: string | null) {
  return useQuery({
    queryKey: ["match-players", id],
    queryFn: () => adminApi.matchPlayers(id!),
    enabled: !!id,
  });
}

export function useUpdatePlaying11Mutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: import("@/lib/api").Playing11Body }) =>
      adminApi.updatePlaying11(id, data),
    onSuccess: (_, v) => {
      queryClient.invalidateQueries({ queryKey: ["match-detail", v.id] });
      queryClient.invalidateQueries({ queryKey: ["match-players", v.id] });
      toast.success("Playing 11 saved!");
    },
    onError: (e: Error) => toast.error(e.message),
  });
}

export function useQuickAddMatchPlayerMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({
      id,
      data,
    }: {
      id: string;
      data: { team: "A" | "B"; name: string; countryCode: string; mobileNumber: string };
    }) => adminApi.quickAddMatchPlayer(id, data),
    onSuccess: (data, v) => {
      queryClient.invalidateQueries({ queryKey: ["match-players", v.id] });
      if (data.teamId) {
        queryClient.invalidateQueries({ queryKey: ["team", data.teamId] });
        queryClient.invalidateQueries({ queryKey: ["teams"] });
      }
      toast.success("Player added to squad");
    },
    onError: (e: Error) => toast.error(e.message),
  });
}

export function useChangeWicketKeeperMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({
      id,
      data,
    }: {
      id: string;
      data: { team: "A" | "B"; wicketKeeperId: string };
    }) => adminApi.changeWicketKeeper(id, data),
    onSuccess: (_, v) => {
      queryClient.invalidateQueries({ queryKey: ["match-detail", v.id] });
      queryClient.invalidateQueries({ queryKey: ["match-players", v.id] });
      toast.success("Wicket keeper updated");
    },
    onError: (e: Error) => toast.error(e.message),
  });
}

export function useRecordTossMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: { tossWonBy: "A" | "B"; tossDecision: "BAT" | "BOWL" } }) =>
      adminApi.recordToss(id, data),
    onSuccess: (_, v) => {
      queryClient.invalidateQueries({ queryKey: ["match-detail", v.id] });
      toast.success("Toss recorded!");
    },
    onError: (e: Error) => toast.error(e.message),
  });
}

export function useRecordBallMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ matchId, inningsNum, data }: { matchId: string; inningsNum: number; data: import("@/lib/api").BallInput }) =>
      adminApi.recordBall(matchId, inningsNum, data),
    onSuccess: (_, v) => {
      queryClient.invalidateQueries({ queryKey: ["match-detail", v.matchId] });
    },
    onError: (e: Error) => toast.error(e.message),
  });
}

export function useUndoLastBallMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ matchId, inningsNum }: { matchId: string; inningsNum: number }) =>
      adminApi.undoLastBall(matchId, inningsNum),
    onSuccess: (_, v) => {
      queryClient.invalidateQueries({ queryKey: ["match-detail", v.matchId] });
      toast.success("Last ball undone");
    },
    onError: (e: Error) => toast.error(e.message),
  });
}

export function useUpdateBallMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ matchId, ballId, data }: { matchId: string; ballId: string; data: Parameters<typeof adminApi.updateBall>[2] }) =>
      adminApi.updateBall(matchId, ballId, data),
    onSuccess: (_, v) => {
      queryClient.invalidateQueries({ queryKey: ["match-detail", v.matchId] });
      toast.success("Ball updated");
    },
    onError: (e: Error) => toast.error(e.message),
  });
}

export function useCompleteInningsMutation(
  onFollowOn?: (deficit: number) => void,
) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ matchId, inningsNum }: { matchId: string; inningsNum: number }) =>
      adminApi.completeInnings(matchId, inningsNum),
    onSuccess: (data, v) => {
      queryClient.invalidateQueries({ queryKey: ["match-detail", v.matchId] });
      if (data.followOnAvailable && onFollowOn) {
        onFollowOn(data.followOnDeficit ?? 0);
      } else {
        toast.success("Innings completed");
      }
    },
    onError: (e: Error) => toast.error(e.message),
  });
}

export function useContinueInningsMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (matchId: string) => adminApi.continueInnings(matchId),
    onSuccess: (_, matchId) => {
      queryClient.invalidateQueries({ queryKey: ["match-detail", matchId] });
      toast.success("Innings continued");
    },
    onError: (e: Error) => toast.error(e.message),
  });
}

export function useReopenInningsMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ matchId, inningsNum }: { matchId: string; inningsNum: number }) =>
      adminApi.reopenInnings(matchId, inningsNum),
    onSuccess: (_, v) => {
      queryClient.invalidateQueries({ queryKey: ["match-detail", v.matchId] });
      toast.success("Innings reopened — match back to IN_PROGRESS");
    },
    onError: (e: Error) => toast.error(e.message),
  });
}

export function useEnforceFollowOnMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (matchId: string) => adminApi.enforceFollowOn(matchId),
    onSuccess: (_, matchId) => {
      queryClient.invalidateQueries({ queryKey: ["match-detail", matchId] });
      toast.success("Follow-on enforced — innings 3 started");
    },
    onError: (e: Error) => toast.error(e.message),
  });
}

export function useStartSuperOverMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (matchId: string) => adminApi.startSuperOver(matchId),
    onSuccess: (_, matchId) => {
      queryClient.invalidateQueries({ queryKey: ["match-detail", matchId] });
      toast.success("Super over started");
    },
    onError: (e: Error) => toast.error(e.message),
  });
}

export function useEndOfDayMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (matchId: string) =>
      apiFetch(`/admin/matches/${matchId}/end-of-day`, { method: "POST" }),
    onSuccess: (_, matchId) => {
      queryClient.invalidateQueries({ queryKey: ["match-detail", matchId] });
      toast.success("Day ended — Day counter advanced");
    },
    onError: (e: Error) => toast.error(e.message),
  });
}

export function useDeleteMatchMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => adminApi.deleteMatch(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["matches"] });
      toast.success("Match deleted");
    },
    onError: (e: Error) => toast.error(e.message),
  });
}

export function useSetMatchStreamMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, youtubeUrl }: { id: string; youtubeUrl: string | null }) =>
      adminApi.setMatchStream(id, youtubeUrl),
    onSuccess: (_, v) => {
      queryClient.invalidateQueries({ queryKey: ["match", v.id] });
      toast.success(v.youtubeUrl ? "Stream URL saved" : "Stream URL removed");
    },
    onError: (e: Error) => toast.error(e.message),
  });
}

export function useStudioSceneQuery(matchId: string | null) {
  return useQuery({
    queryKey: ["studio-scene", matchId],
    queryFn: () => adminApi.getStudioScene(matchId!),
    enabled: !!matchId,
    refetchInterval: 3000,
  });
}

export function useSetStudioSceneMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, scene, breakType }: { id: string; scene: string; breakType?: string | null }) =>
      adminApi.setStudioScene(id, scene, breakType),
    onSuccess: (_, v) => {
      queryClient.invalidateQueries({ queryKey: ["studio-scene", v.id] });
    },
    onError: (e: Error) => toast.error(e.message),
  });
}

// Live session (Swing Live app heartbeat)
export function useLiveSessionQuery(matchId: string) {
  return useQuery({
    queryKey: ["live-session", matchId],
    queryFn: () => adminApi.getLiveSession(matchId),
    enabled: !!matchId,
    refetchInterval: 5000,
  });
}

// Live stream management
export function useLiveStreamQuery(matchId: string | null) {
  return useQuery({
    queryKey: ["live-stream", matchId],
    queryFn: () => adminApi.getLiveStreamStatus(matchId!),
    enabled: !!matchId,
    refetchInterval: (query) => (query.state.error ? false : 5000),
  });
}

export function useStartLiveStreamMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, youtubeStreamKey }: { id: string; youtubeStreamKey?: string }) =>
      adminApi.startLiveStream(id, youtubeStreamKey),
    onSuccess: (_, v) => {
      queryClient.invalidateQueries({ queryKey: ["live-stream", v.id] });
      toast.success("Stream started! Open the camera link on your phone.");
    },
    onError: (e: Error) => toast.error(e.message),
  });
}

// Kept for import compatibility — no longer used
export function useStartLiveStreamWithYouTubeMutation() {
  return { mutate: () => {}, isPending: false };
}

export function useStopLiveStreamMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id }: { id: string }) => adminApi.stopLiveStream(id),
    onSuccess: (_, v) => {
      queryClient.invalidateQueries({ queryKey: ["live-stream", v.id] });
      toast.success("Stream stopped.");
    },
    onError: (e: Error) => toast.error(e.message),
  });
}
