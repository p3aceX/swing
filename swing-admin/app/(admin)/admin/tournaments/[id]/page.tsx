"use client";

import { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import {
  useTournamentQuery,
  useUpdateTournamentMutation,
  useDeleteTournamentMutation,
  useTournamentTeamsQuery,
  useAddTournamentTeamMutation,
  useRemoveTournamentTeamMutation,
  useConfirmTournamentTeamMutation,
  useTournamentGroupsQuery,
  useCreateTournamentGroupsMutation,
  useAssignTeamToGroupMutation,
  useTournamentStandingsQuery,
  useRecalculateStandingsMutation,
  useTournamentScheduleQuery,
  useDeleteScheduleMutation,
  useCreateMatchMutation,
  useCompleteMatchMutation,
  useAdvanceKnockoutRoundMutation,
  useSmartScheduleMutation,
  useTeamsQuery,
} from "@/lib/queries";
import { formatDate } from "@/lib/utils";
import { ImageUpload } from "@/components/ui/image-upload";
import type {
  CreateMatchBody,
  TournamentRecord,
  TournamentTeam,
  StandingRow,
  ScheduleMatch,
  TournamentGroupRecord,
} from "@/lib/api";

const LEAGUE_FORMATS = ["LEAGUE", "GROUP_STAGE_KNOCKOUT", "SUPER_LEAGUE"];
const GROUP_FORMATS = ["GROUP_STAGE_KNOCKOUT", "SUPER_LEAGUE"];
const POINTS_TABLE_FORMATS = [
  "LEAGUE",
  "GROUP_STAGE_KNOCKOUT",
  "SUPER_LEAGUE",
  "SERIES",
];
const SERIES_PRESETS = [
  { label: "2-Match Series", maxTeams: 2, seriesMatchCount: 2 },
  { label: "3-Match Series", maxTeams: 2, seriesMatchCount: 3 },
  { label: "5-Match Series", maxTeams: 2, seriesMatchCount: 5 },
  { label: "Tri-Series", maxTeams: 3, seriesMatchCount: 1 },
  { label: "Quad-Series", maxTeams: 4, seriesMatchCount: 1 },
] as const;
const STATUSES = ["UPCOMING", "ONGOING", "COMPLETED"] as const;
const MATCH_FORMATS = [
  "T10",
  "T20",
  "ONE_DAY",
  "TWO_INNINGS",
  "BOX_CRICKET",
  "CUSTOM",
] as const;
const TOURNAMENT_FORMATS = [
  { value: "LEAGUE", label: "League / Round Robin" },
  { value: "SERIES", label: "Series" },
  { value: "KNOCKOUT", label: "Knockout / Elimination" },
  { value: "GROUP_STAGE_KNOCKOUT", label: "Group Stage + Knockout" },
  { value: "SUPER_LEAGUE", label: "Super League (Groups + Finals)" },
  { value: "DOUBLE_ELIMINATION", label: "Double Elimination" },
] as const;
const WEEKDAYS = [
  { label: "Sun", value: 0 },
  { label: "Mon", value: 1 },
  { label: "Tue", value: 2 },
  { label: "Wed", value: 3 },
  { label: "Thu", value: 4 },
  { label: "Fri", value: 5 },
  { label: "Sat", value: 6 },
];

function statusBadge(status: string) {
  const v =
    status === "ONGOING"
      ? "success"
      : status === "COMPLETED"
        ? "secondary"
        : "outline";
  return <Badge variant={v as any}>{status}</Badge>;
}

function getInitials(value: string) {
  return value
    .split(" ")
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0]?.toUpperCase() ?? "")
    .join("");
}

// ── Teams Tab ─────────────────────────────────────────────────────────
function TeamsTab({ tournament }: { tournament: TournamentRecord }) {
  const [search, setSearch] = useState("");
  const [selectedTeamId, setSelectedTeamId] = useState("__new__");
  const [newTeamName, setNewTeamName] = useState("");

  const teamsQuery = useTournamentTeamsQuery(tournament.id);
  const groupsQuery = useTournamentGroupsQuery(tournament.id);
  const dbTeamsQuery = useTeamsQuery({
    page: 1,
    limit: 100,
    search: search || undefined,
  });
  const addTeam = useAddTournamentTeamMutation();
  const removeTeam = useRemoveTournamentTeamMutation();
  const confirmTeam = useConfirmTournamentTeamMutation();
  const assignGroup = useAssignTeamToGroupMutation();

  const groups =
    (groupsQuery.data as TournamentGroupRecord[] | undefined) ?? [];
  const teams = (teamsQuery.data as TournamentTeam[] | undefined) ?? [];
  const dbTeams = (dbTeamsQuery.data as any)?.teams ?? [];
  const registeredTeamIds = new Set(teams.map((t) => t.teamId).filter(Boolean));
  const isFull =
    tournament.maxTeams != null && teams.length >= tournament.maxTeams;

  function buildRegisterPayload() {
    if (selectedTeamId === "__new__") {
      const teamName = newTeamName.trim();
      return teamName ? { teamName } : null;
    }

    const teamId = selectedTeamId.trim();
    return teamId && teamId !== "__new__" ? { teamId } : null;
  }

  function handleRegister() {
    const payload = buildRegisterPayload();
    if (!payload) return;

    addTeam.mutate(
      {
        tournamentId: tournament.id,
        data: payload,
      },
      {
        onSuccess: () => {
          if ("teamName" in payload) setNewTeamName("");
          if ("teamId" in payload) setSelectedTeamId("__new__");
        },
      },
    );
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between text-sm text-muted-foreground">
        <span>
          {teams.length} / {tournament.maxTeams ?? "∞"} teams registered
        </span>
        {isFull && <Badge variant="destructive">Full</Badge>}
      </div>

      {!isFull && (
        <div className="rounded-lg border p-4 space-y-3 bg-muted/20">
          <div className="text-sm font-semibold">Register Team</div>
          <Select value={selectedTeamId} onValueChange={setSelectedTeamId}>
            <SelectTrigger>
              <SelectValue placeholder="Pick from DB or create new" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="__new__">+ Create new team</SelectItem>
              {dbTeams
                .filter((t: any) => !registeredTeamIds.has(t.id))
                .map((t: any) => (
                  <SelectItem key={t.id} value={t.id}>
                    {t.name}
                    {t.city ? ` · ${t.city}` : ""}
                    {t.shortName ? ` (${t.shortName})` : ""}
                  </SelectItem>
                ))}
            </SelectContent>
          </Select>
          {selectedTeamId === "__new__" && (
            <Input
              value={newTeamName}
              onChange={(e) => setNewTeamName(e.target.value)}
              placeholder="Team name — also created in Team DB"
            />
          )}
          <Button
            size="sm"
            disabled={
              (selectedTeamId === "__new__" ? !newTeamName.trim() : false) ||
              addTeam.isPending
            }
            onClick={handleRegister}
            className="w-full"
          >
            {addTeam.isPending ? "Adding..." : "Register Team"}
          </Button>
        </div>
      )}

      <div className="space-y-2">
        {teams.map((team) => (
          <div key={team.id} className="rounded-lg border p-3 space-y-2">
            <div className="flex items-center justify-between">
              <div>
                <div className="font-medium text-sm">{team.teamName}</div>
                {team.teamId && (
                  <div className="text-xs text-muted-foreground">
                    Linked from Team DB
                  </div>
                )}
              </div>
              <div className="flex gap-2">
                <Button
                  size="sm"
                  variant={team.isConfirmed ? "outline" : "default"}
                  onClick={() =>
                    confirmTeam.mutate({
                      tournamentId: tournament.id,
                      teamId: team.id,
                      isConfirmed: !team.isConfirmed,
                    })
                  }
                  disabled={confirmTeam.isPending}
                >
                  {team.isConfirmed ? "Unconfirm" : "Confirm"}
                </Button>
                <Button
                  size="sm"
                  variant="destructive"
                  onClick={() =>
                    removeTeam.mutate({
                      tournamentId: tournament.id,
                      teamId: team.id,
                    })
                  }
                  disabled={removeTeam.isPending}
                >
                  Remove
                </Button>
              </div>
            </div>
            {groups.length > 0 && (
              <div className="flex items-center gap-2 text-xs">
                <span className="text-muted-foreground">Group:</span>
                <Select
                  value={team.groupId ?? "none"}
                  onValueChange={(v) =>
                    assignGroup.mutate({
                      tournamentId: tournament.id,
                      teamId: team.id,
                      groupId: v === "none" ? null : v,
                    })
                  }
                >
                  <SelectTrigger className="h-7 text-xs w-[130px]">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="none">— None —</SelectItem>
                    {groups.map((g) => (
                      <SelectItem key={g.id} value={g.id}>
                        {g.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            )}
          </div>
        ))}
        {!teamsQuery.isLoading && teams.length === 0 && (
          <div className="text-sm text-muted-foreground">
            No teams registered yet.
          </div>
        )}
      </div>
    </div>
  );
}

// ── Groups Tab ────────────────────────────────────────────────────────
function GroupsTab({ tournament }: { tournament: TournamentRecord }) {
  const [groupInput, setGroupInput] = useState("");
  const [autoAssignOnCreate, setAutoAssignOnCreate] = useState(true);
  const groupsQuery = useTournamentGroupsQuery(tournament.id);
  const createGroups = useCreateTournamentGroupsMutation();
  const groups =
    (groupsQuery.data as TournamentGroupRecord[] | undefined) ?? [];

  function handleCreate(names: string[]) {
    createGroups.mutate({
      id: tournament.id,
      groupNames: names,
      autoAssign: autoAssignOnCreate,
    });
  }

  return (
    <div className="space-y-4">
      <div className="rounded-lg border p-4 space-y-3 bg-muted/20">
        <div className="flex items-center justify-between">
          <div className="text-sm font-semibold">Create Groups</div>
          <label className="flex items-center gap-2 text-xs text-muted-foreground cursor-pointer">
            <input
              type="checkbox"
              className="rounded"
              checked={autoAssignOnCreate}
              onChange={(e) => setAutoAssignOnCreate(e.target.checked)}
            />
            Auto-assign confirmed teams randomly
          </label>
        </div>
        <div className="flex gap-2 flex-wrap">
          {[2, 3, 4, 6, 8].map((n) => (
            <Button
              key={n}
              size="sm"
              variant="outline"
              disabled={createGroups.isPending}
              onClick={() =>
                handleCreate(
                  Array.from(
                    { length: n },
                    (_, i) => `Group ${String.fromCharCode(65 + i)}`,
                  ),
                )
              }
            >
              {n} Groups
            </Button>
          ))}
        </div>
        <div className="flex gap-2">
          <Input
            className="h-8 text-sm flex-1"
            value={groupInput}
            onChange={(e) => setGroupInput(e.target.value)}
            placeholder="Group A, Group B, ..."
          />
          <Button
            size="sm"
            disabled={!groupInput.trim() || createGroups.isPending}
            onClick={() => {
              const names = groupInput
                .split(",")
                .map((s) => s.trim())
                .filter(Boolean);
              if (names.length) handleCreate(names);
              setGroupInput("");
            }}
          >
            Set
          </Button>
        </div>
        <p className="text-xs text-muted-foreground">
          Creating groups resets all existing group assignments.
        </p>
      </div>
      <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
        {groups.map((group) => (
          <Card key={group.id}>
            <CardHeader className="pb-2 pt-4 px-4">
              <CardTitle className="text-sm">{group.name}</CardTitle>
            </CardHeader>
            <CardContent className="px-4 pb-4 space-y-1">
              {(group.teams ?? []).map((t) => (
                <div
                  key={t.id}
                  className="flex items-center justify-between text-xs"
                >
                  <span>{t.teamName}</span>
                  <Badge
                    variant={t.isConfirmed ? "success" : "outline"}
                    className="text-xs"
                  >
                    {t.isConfirmed ? "Confirmed" : "Pending"}
                  </Badge>
                </div>
              ))}
              {(group.teams ?? []).length === 0 && (
                <div className="text-xs text-muted-foreground">
                  No teams assigned
                </div>
              )}
            </CardContent>
          </Card>
        ))}
        {!groupsQuery.isLoading && groups.length === 0 && (
          <div className="col-span-3 text-sm text-muted-foreground">
            No groups yet. Click above to create.
          </div>
        )}
      </div>
    </div>
  );
}

// ── Standings Tab ─────────────────────────────────────────────────────
function StandingsTab({ tournament }: { tournament: TournamentRecord }) {
  const standingsQuery = useTournamentStandingsQuery(tournament.id);
  const recalculate = useRecalculateStandingsMutation();
  const grouped = standingsQuery.data as
    | Record<string, StandingRow[]>
    | undefined;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <p className="text-xs text-muted-foreground">
          Auto-updated after each match result.
        </p>
        <Button
          size="sm"
          variant="outline"
          onClick={() => recalculate.mutate(tournament.id)}
          disabled={recalculate.isPending}
        >
          {recalculate.isPending ? "Recalculating..." : "Sync Manually"}
        </Button>
      </div>
      {grouped &&
        Object.entries(grouped).map(([groupKey, rows]) => (
          <div key={groupKey}>
            <div className="text-sm font-semibold mb-2">
              {rows[0]?.group?.name ?? "Overall Standings"}
            </div>
            <div className="rounded-lg border overflow-hidden">
              <table className="w-full text-xs">
                <thead className="bg-muted/50">
                  <tr>
                    {["#", "Team", "P", "W", "L", "T", "NR", "Pts", "NRR"].map(
                      (h) => (
                        <th
                          key={h}
                          className={`p-2 font-medium ${h === "#" || h === "Team" ? "text-left" : "text-center"}`}
                        >
                          {h}
                        </th>
                      ),
                    )}
                  </tr>
                </thead>
                <tbody>
                  {rows.map((row, i) => (
                    <tr
                      key={row.id}
                      className={i % 2 === 0 ? "" : "bg-muted/20"}
                    >
                      <td className="p-2 text-muted-foreground">{i + 1}</td>
                      <td className="p-2 font-medium">{row.team.teamName}</td>
                      <td className="p-2 text-center">{row.played}</td>
                      <td className="p-2 text-center text-green-600 font-medium">
                        {row.won}
                      </td>
                      <td className="p-2 text-center text-red-500">
                        {row.lost}
                      </td>
                      <td className="p-2 text-center">{row.tied}</td>
                      <td className="p-2 text-center text-muted-foreground">
                        {row.noResult}
                      </td>
                      <td className="p-2 text-center font-bold">
                        {row.points}
                      </td>
                      <td className="p-2 text-center font-mono">
                        {row.nrr >= 0 ? "+" : ""}
                        {row.nrr.toFixed(3)}
                      </td>
                    </tr>
                  ))}
                  {rows.length === 0 && (
                    <tr>
                      <td
                        colSpan={9}
                        className="p-4 text-center text-muted-foreground"
                      >
                        No standings yet.
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>
        ))}
      {!standingsQuery.isLoading &&
        (!grouped || Object.keys(grouped).length === 0) && (
          <div className="text-sm text-muted-foreground">
            No standings yet. Confirm teams first, then recalculate after
            matches.
          </div>
        )}
    </div>
  );
}

// ── Match Card ────────────────────────────────────────────────────────
function MatchCard({
  match,
  tournamentId,
}: {
  match: ScheduleMatch;
  tournamentId: string;
}) {
  const router = useRouter();
  const completeMatch = useCompleteMatchMutation();
  const [showResult, setShowResult] = useState(false);

  const isLive = match.status === "IN_PROGRESS";
  const isDone = match.status === "COMPLETED" || match.status === "ABANDONED";
  const canSetResult = !isDone;

  const winnerName = isDone && match.winnerId ? match.winnerId : null;
  const isWalkover = isDone && match.winMargin === "W/O";

  function doComplete(winner: "A" | "B" | "NO_RESULT", isWalkover?: boolean) {
    completeMatch.mutate(
      { matchId: match.id, tournamentId, winner, isWalkover },
      {
        onSuccess: () => setShowResult(false),
      },
    );
  }

  return (
    <div
      className={`rounded-lg border p-3 text-sm space-y-2 ${isLive ? "border-green-500/40 bg-green-50/30 dark:bg-green-950/20" : ""}`}
    >
      <div className="flex items-start justify-between gap-2">
        <div className="min-w-0 flex-1">
          <div className="font-semibold flex items-center gap-2 flex-wrap">
            <span
              className={winnerName === match.teamAName ? "text-green-600" : ""}
            >
              {match.teamAName}
            </span>
            <span className="font-normal text-muted-foreground text-xs">
              vs
            </span>
            <span
              className={winnerName === match.teamBName ? "text-green-600" : ""}
            >
              {match.teamBName}
            </span>
            {winnerName && (
              <span className="text-xs font-medium text-green-600">
                · {winnerName} won{isWalkover ? " (W/O)" : ""}
              </span>
            )}
            {isDone && !winnerName && (
              <span className="text-xs text-muted-foreground">· No Result</span>
            )}
          </div>
          <div className="text-xs text-muted-foreground mt-0.5">
            {formatDate(match.scheduledAt)}
            {match.venueName ? ` · ${match.venueName}` : ""}
            {match.round ? ` · ${match.round}` : ""}
          </div>
        </div>
        <div className="shrink-0 flex items-center gap-1.5">
          {match.status === "SCHEDULED" && !showResult && (
            <>
              <Button
                size="sm"
                className="h-7 text-xs"
                variant="outline"
                onClick={() => router.push(`/admin/matches/${match.id}`)}
              >
                Setup
              </Button>
              <Button
                size="sm"
                className="h-7 text-xs"
                variant="outline"
                onClick={() => setShowResult(true)}
              >
                Result
              </Button>
            </>
          )}
          {isLive && !showResult && (
            <>
              <Badge variant="success" className="animate-pulse">
                ● LIVE
              </Badge>
              <Button
                size="sm"
                className="h-7 text-xs"
                variant="outline"
                onClick={() => setShowResult(true)}
              >
                Result
              </Button>
            </>
          )}
          {isDone && (
            <Badge variant={winnerName ? "outline" : "default"}>
              {winnerName ? "Done" : "No Result"}
            </Badge>
          )}
        </div>
      </div>

      {/* Result picker */}
      {showResult && canSetResult && (
        <div className="border-t pt-2 space-y-2">
          <div className="text-xs font-medium text-muted-foreground">
            Declare Result
          </div>
          <div className="flex flex-wrap gap-1.5">
            <Button
              size="sm"
              className="h-7 text-xs bg-green-600 hover:bg-green-700 text-white"
              disabled={completeMatch.isPending}
              onClick={() => doComplete("A")}
            >
              {match.teamAName} Won
            </Button>
            <Button
              size="sm"
              className="h-7 text-xs bg-green-600 hover:bg-green-700 text-white"
              disabled={completeMatch.isPending}
              onClick={() => doComplete("B")}
            >
              {match.teamBName} Won
            </Button>
            <Button
              size="sm"
              variant="outline"
              className="h-7 text-xs"
              disabled={completeMatch.isPending}
              onClick={() => doComplete("NO_RESULT")}
            >
              No Result
            </Button>
          </div>
          <div className="flex flex-wrap gap-1.5 border-t pt-1.5">
            <span className="text-xs text-muted-foreground self-center">
              Walkover:
            </span>
            <Button
              size="sm"
              variant="outline"
              className="h-7 text-xs border-amber-400 text-amber-700 hover:bg-amber-50"
              disabled={completeMatch.isPending}
              onClick={() => doComplete("A", true)}
            >
              {match.teamAName} W/O
            </Button>
            <Button
              size="sm"
              variant="outline"
              className="h-7 text-xs border-amber-400 text-amber-700 hover:bg-amber-50"
              disabled={completeMatch.isPending}
              onClick={() => doComplete("B", true)}
            >
              {match.teamBName} W/O
            </Button>
            <Button
              size="sm"
              variant="ghost"
              className="h-7 text-xs ml-auto"
              onClick={() => setShowResult(false)}
            >
              Cancel
            </Button>
          </div>
        </div>
      )}

      {match.innings.length > 0 && (
        <div className="grid grid-cols-2 gap-2 text-xs border-t pt-2">
          {match.innings.map((inn) => (
            <div
              key={inn.inningsNumber}
              className="rounded bg-muted/50 px-2 py-1 font-mono"
            >
              Inn {inn.inningsNumber}:{" "}
              <span className="font-bold">
                {inn.totalRuns}/{inn.totalWickets}
              </span>{" "}
              ({inn.totalOvers}ov)
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

// ── Add Fixture Dialog ─────────────────────────────────────────────────
function useGroupMap(tournamentId: string) {
  const groupsQuery = useTournamentGroupsQuery(tournamentId);
  const groups = (groupsQuery.data ?? []) as TournamentGroupRecord[];
  return new Map(groups.map((g) => [g.id, g.name]));
}

function inferRound(teamAName: string, teamBName: string, teams: TournamentTeam[], groupMap: Map<string, string>): string {
  if (!groupMap.size) return "";
  const tA = teams.find((t) => t.teamName === teamAName);
  const tB = teams.find((t) => t.teamName === teamBName);
  if (tA?.groupId && tB?.groupId && tA.groupId === tB.groupId) {
    return groupMap.get(tA.groupId) ?? "";
  }
  return "";
}

function AddFixtureDialog({ tournament }: { tournament: TournamentRecord }) {
  const createMatch = useCreateMatchMutation();
  const groupMap = useGroupMap(tournament.id);
  const [open, setOpen] = useState(false);
  const teams = tournament.teams ?? [];

  const today = new Date().toISOString().split("T")[0];
  const [teamA, setTeamA] = useState("");
  const [teamB, setTeamB] = useState("");
  const [date, setDate] = useState(tournament.startDate ? new Date(tournament.startDate).toISOString().split("T")[0] : today);
  const [time, setTime] = useState("10:00");
  const [round, setRound] = useState("");
  const [venue, setVenue] = useState(tournament.venueName ?? "");

  function handleTeamAChange(v: string) {
    setTeamA(v);
    setRound(inferRound(v, teamB, teams, groupMap));
  }

  function handleTeamBChange(v: string) {
    setTeamB(v);
    setRound(inferRound(teamA, v, teams, groupMap));
  }

  function reset() {
    setTeamA(""); setTeamB(""); setDate(today); setTime("10:00"); setRound(""); setVenue(tournament.venueName ?? "");
  }

  const canSubmit = teamA && teamB && teamA !== teamB && date && time && !createMatch.isPending;

  function handleSubmit() {
    const scheduledAt = new Date(`${date}T${time}:00`).toISOString();
    createMatch.mutate(
      {
        matchType: "TOURNAMENT",
        format: tournament.format as CreateMatchBody["format"],
        teamAName: teamA,
        teamBName: teamB,
        scheduledAt,
        tournamentId: tournament.id,
        ...(round.trim() ? { round: round.trim() } : {}),
        ...(venue.trim() ? { venueName: venue.trim() } : {}),
      },
      {
        onSuccess: () => { setOpen(false); reset(); },
      },
    );
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button size="sm" variant="outline">+ Add Fixture</Button>
      </DialogTrigger>
      <DialogContent className="max-w-md">
        <DialogHeader>
          <DialogTitle>Add Manual Fixture</DialogTitle>
        </DialogHeader>
        <div className="grid gap-4 py-2">
          <div className="grid grid-cols-2 gap-3">
            <div className="space-y-1">
              <label className="text-xs font-medium">Team A *</label>
              <Select value={teamA} onValueChange={handleTeamAChange}>
                <SelectTrigger><SelectValue placeholder="Select team" /></SelectTrigger>
                <SelectContent>
                  {teams.map((t) => (
                    <SelectItem key={t.id} value={t.teamName} disabled={t.teamName === teamB}>
                      {t.teamName}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-1">
              <label className="text-xs font-medium">Team B *</label>
              <Select value={teamB} onValueChange={handleTeamBChange}>
                <SelectTrigger><SelectValue placeholder="Select team" /></SelectTrigger>
                <SelectContent>
                  {teams.map((t) => (
                    <SelectItem key={t.id} value={t.teamName} disabled={t.teamName === teamA}>
                      {t.teamName}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div className="space-y-1">
              <label className="text-xs font-medium">Date *</label>
              <Input type="date" value={date} onChange={(e) => setDate(e.target.value)} />
            </div>
            <div className="space-y-1">
              <label className="text-xs font-medium">Time *</label>
              <Input type="time" value={time} onChange={(e) => setTime(e.target.value)} />
            </div>
          </div>
          <div className="space-y-1">
            <label className="text-xs font-medium">Round <span className="text-muted-foreground">(optional)</span></label>
            <Input placeholder="e.g. Quarter Final, Group A" value={round} onChange={(e) => setRound(e.target.value)} />
          </div>
          <div className="space-y-1">
            <label className="text-xs font-medium">Venue <span className="text-muted-foreground">(optional)</span></label>
            <Input placeholder="Venue name" value={venue} onChange={(e) => setVenue(e.target.value)} />
          </div>
          <div className="rounded-lg bg-muted px-3 py-2 text-xs text-muted-foreground">
            Format: <span className="font-medium text-foreground">{tournament.format}</span>
          </div>
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={() => { setOpen(false); reset(); }}>Cancel</Button>
          <Button disabled={!canSubmit} onClick={handleSubmit}>
            {createMatch.isPending ? "Creating..." : "Create Fixture"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

// ── Bulk Fixture Dialog ────────────────────────────────────────────────
interface FixtureRow {
  id: string;
  teamA: string;
  teamB: string;
  date: string;
  time: string;
  round: string;
  venue: string;
}

function emptyRow(prev?: FixtureRow): FixtureRow {
  return {
    id: Math.random().toString(36).slice(2),
    teamA: "",
    teamB: "",
    date: prev?.date ?? "",
    time: prev?.time ?? "10:00",
    round: prev?.round ?? "",
    venue: prev?.venue ?? "",
  };
}

function parseDate(raw: string): string {
  const s = raw.trim();
  // YYYY-MM-DD
  if (/^\d{4}-\d{2}-\d{2}$/.test(s)) return s;
  // DD/MM/YYYY or DD-MM-YYYY
  const dmy = s.match(/^(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{4})$/);
  if (dmy) return `${dmy[3]}-${dmy[2].padStart(2, "0")}-${dmy[1].padStart(2, "0")}`;
  // MM/DD/YYYY (ambiguous, treat as DD/MM if day > 12, else MM/DD)
  return "";
}

function parseTime(raw: string): string {
  const s = raw.trim();
  // HH:MM 24h
  if (/^\d{1,2}:\d{2}$/.test(s)) {
    const [h, m] = s.split(":").map(Number);
    return `${String(h).padStart(2, "0")}:${String(m).padStart(2, "0")}`;
  }
  // H:MM AM/PM
  const ampm = s.match(/^(\d{1,2}):(\d{2})\s*(am|pm)$/i);
  if (ampm) {
    let h = parseInt(ampm[1]);
    const m = ampm[2];
    const period = ampm[3].toLowerCase();
    if (period === "pm" && h < 12) h += 12;
    if (period === "am" && h === 12) h = 0;
    return `${String(h).padStart(2, "0")}:${m}`;
  }
  return "";
}

function parsePastedData(text: string, teams: TournamentTeam[]): FixtureRow[] {
  const teamNames = teams.map((t) => t.teamName.toLowerCase());

  const lines = text
    .split(/\r?\n/)
    .map((l) => l.trim())
    .filter(Boolean);

  return lines.flatMap((line) => {
    // detect separator: tab or comma
    const sep = line.includes("\t") ? "\t" : ",";
    const cols = line.split(sep).map((c) => c.trim().replace(/^["']|["']$/g, ""));
    if (cols.length < 2) return [];

    // try to identify which cols are teams, date, time, round, venue
    let teamA = "";
    let teamB = "";
    let date = "";
    let time = "";
    let round = "";
    let venue = "";
    const used = new Set<number>();

    // first pass: find teams
    cols.forEach((c, i) => {
      if (used.has(i)) return;
      const match = teams.find((t) => t.teamName.toLowerCase() === c.toLowerCase());
      if (match) {
        if (!teamA) { teamA = match.teamName; used.add(i); }
        else if (!teamB) { teamB = match.teamName; used.add(i); }
      }
    });

    // if not matched by name, take first two cols as team names
    if (!teamA && cols[0]) { teamA = cols[0]; used.add(0); }
    if (!teamB && cols[1] && !used.has(1)) { teamB = cols[1]; used.add(1); }

    // second pass: date, time, round, venue
    cols.forEach((c, i) => {
      if (used.has(i)) return;
      const d = parseDate(c);
      if (d && !date) { date = d; used.add(i); return; }
      const t = parseTime(c);
      if (t && !time) { time = t; used.add(i); return; }
      // anything with "round", "group", "quarter", "semi", "final" → round
      if (!round && /round|group|quarter|semi|final|match/i.test(c)) { round = c; used.add(i); return; }
    });

    // remaining unused cols → venue (first one that looks like a place)
    cols.forEach((c, i) => {
      if (used.has(i) || !c) return;
      if (!venue) { venue = c; used.add(i); }
    });

    return [{
      id: Math.random().toString(36).slice(2),
      teamA,
      teamB,
      date,
      time: time || "10:00",
      round,
      venue,
    }];
  });
}

function isRowValid(row: FixtureRow) {
  return row.teamA && row.teamB && row.teamA !== row.teamB && row.date && row.time;
}

function BulkFixtureDialog({ tournament }: { tournament: TournamentRecord }) {
  const createMatch = useCreateMatchMutation();
  const groupMap = useGroupMap(tournament.id);
  const [open, setOpen] = useState(false);
  const [rows, setRows] = useState<FixtureRow[]>([emptyRow()]);
  const [pasteText, setPasteText] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [results, setResults] = useState<{ ok: number; fail: number } | null>(null);
  const teams = tournament.teams ?? [];

  function reset() {
    setRows([emptyRow()]);
    setPasteText("");
    setResults(null);
  }

  function handleParse() {
    if (!pasteText.trim()) return;
    const parsed = parsePastedData(pasteText, teams);
    // auto-fill round from group for each parsed row
    const enriched = parsed.map((r) => ({
      ...r,
      round: r.round || inferRound(r.teamA, r.teamB, teams, groupMap),
    }));
    if (enriched.length > 0) setRows(enriched);
    setPasteText("");
  }

  function updateRow(id: string, field: keyof FixtureRow, value: string) {
    setRows((prev) =>
      prev.map((r) => {
        if (r.id !== id) return r;
        const updated = { ...r, [field]: value };
        // auto-fill round from group when either team changes
        if ((field === "teamA" || field === "teamB") && !r.round) {
          const newA = field === "teamA" ? value : r.teamA;
          const newB = field === "teamB" ? value : r.teamB;
          updated.round = inferRound(newA, newB, teams, groupMap);
        }
        return updated;
      }),
    );
  }

  function addRow() {
    setRows((prev) => [...prev, emptyRow(prev[prev.length - 1])]);
  }

  function removeRow(id: string) {
    setRows((prev) => prev.length > 1 ? prev.filter((r) => r.id !== id) : prev);
  }

  const validRows = rows.filter(isRowValid);

  async function handleSubmit() {
    if (validRows.length === 0) return;
    setSubmitting(true);
    setResults(null);
    const settled = await Promise.allSettled(
      validRows.map((row) =>
        new Promise<void>((resolve, reject) => {
          const scheduledAt = new Date(`${row.date}T${row.time}:00`).toISOString();
          createMatch.mutate(
            {
              matchType: "TOURNAMENT",
              format: tournament.format as CreateMatchBody["format"],
              teamAName: row.teamA,
              teamBName: row.teamB,
              scheduledAt,
              tournamentId: tournament.id,
              ...(row.round.trim() ? { round: row.round.trim() } : {}),
              ...(row.venue.trim() ? { venueName: row.venue.trim() } : {}),
            },
            { onSuccess: () => resolve(), onError: (e) => reject(e) },
          );
        }),
      ),
    );
    const ok = settled.filter((s) => s.status === "fulfilled").length;
    const fail = settled.filter((s) => s.status === "rejected").length;
    setResults({ ok, fail });
    setSubmitting(false);
    if (fail === 0) { setOpen(false); reset(); }
  }

  return (
    <Dialog open={open} onOpenChange={(v) => { setOpen(v); if (!v) reset(); }}>
      <DialogTrigger asChild>
        <Button size="sm" variant="outline">⚡ Bulk Create</Button>
      </DialogTrigger>
      <DialogContent className="w-[calc(100%-2rem)] max-w-5xl max-h-[90vh] flex flex-col">
        <DialogHeader>
          <DialogTitle>Bulk Create Fixtures</DialogTitle>
        </DialogHeader>

        {/* Paste zone */}
        <div className="space-y-2 shrink-0">
          <label className="text-xs font-medium text-muted-foreground">
            Paste from Excel / CSV (Team A, Team B, Date, Time, Round, Venue)
          </label>
          <div className="flex gap-2">
            <textarea
              className="flex-1 min-h-[72px] rounded-md border bg-background px-3 py-2 text-sm font-mono resize-none focus:outline-none focus:ring-2 focus:ring-ring"
              placeholder={"Mumbai Indians\tChennai Super Kings\t15/04/2025\t14:00\tGroup A\tWankhede\nKolkata Knight Riders\tRoyal Challengers\t16/04/2025\t10:00\t\tEden Gardens"}
              value={pasteText}
              onChange={(e) => setPasteText(e.target.value)}
            />
            <Button
              size="sm"
              variant="secondary"
              className="self-start mt-1 shrink-0"
              disabled={!pasteText.trim()}
              onClick={handleParse}
            >
              Parse →
            </Button>
          </div>
        </div>

        {/* Table */}
        <div className="flex-1 overflow-auto min-h-0">
          <table className="w-full text-sm border-collapse">
            <thead className="sticky top-0 bg-muted/80 backdrop-blur-sm z-10">
              <tr>
                <th className="text-left px-2 py-1.5 text-xs font-medium text-muted-foreground w-[18%]">Team A *</th>
                <th className="text-left px-2 py-1.5 text-xs font-medium text-muted-foreground w-[18%]">Team B *</th>
                <th className="text-left px-2 py-1.5 text-xs font-medium text-muted-foreground w-[13%]">Date *</th>
                <th className="text-left px-2 py-1.5 text-xs font-medium text-muted-foreground w-[10%]">Time *</th>
                <th className="text-left px-2 py-1.5 text-xs font-medium text-muted-foreground w-[17%]">Round</th>
                <th className="text-left px-2 py-1.5 text-xs font-medium text-muted-foreground w-[18%]">Venue</th>
                <th className="w-8" />
              </tr>
            </thead>
            <tbody>
              {rows.map((row, idx) => {
                const invalid = !isRowValid(row) && (row.teamA || row.teamB || row.date);
                return (
                  <tr
                    key={row.id}
                    className={`border-b transition-colors ${invalid ? "bg-red-50" : idx % 2 === 0 ? "bg-background" : "bg-muted/20"}`}
                  >
                    <td className="px-1 py-1">
                      {teams.length > 0 ? (
                        <Select value={row.teamA} onValueChange={(v) => updateRow(row.id, "teamA", v)}>
                          <SelectTrigger className={`h-8 text-xs ${!row.teamA && invalid ? "border-red-400" : ""}`}>
                            <SelectValue placeholder="Team A" />
                          </SelectTrigger>
                          <SelectContent>
                            {teams.map((t) => (
                              <SelectItem key={t.id} value={t.teamName} disabled={t.teamName === row.teamB}>
                                {t.teamName}
                              </SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                      ) : (
                        <Input className="h-8 text-xs" value={row.teamA} onChange={(e) => updateRow(row.id, "teamA", e.target.value)} placeholder="Team A" />
                      )}
                    </td>
                    <td className="px-1 py-1">
                      {teams.length > 0 ? (
                        <Select value={row.teamB} onValueChange={(v) => updateRow(row.id, "teamB", v)}>
                          <SelectTrigger className={`h-8 text-xs ${!row.teamB && invalid ? "border-red-400" : ""}`}>
                            <SelectValue placeholder="Team B" />
                          </SelectTrigger>
                          <SelectContent>
                            {teams.map((t) => (
                              <SelectItem key={t.id} value={t.teamName} disabled={t.teamName === row.teamA}>
                                {t.teamName}
                              </SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                      ) : (
                        <Input className="h-8 text-xs" value={row.teamB} onChange={(e) => updateRow(row.id, "teamB", e.target.value)} placeholder="Team B" />
                      )}
                    </td>
                    <td className="px-1 py-1">
                      <Input
                        type="date"
                        className={`h-8 text-xs ${!row.date && invalid ? "border-red-400" : ""}`}
                        value={row.date}
                        onChange={(e) => updateRow(row.id, "date", e.target.value)}
                      />
                    </td>
                    <td className="px-1 py-1">
                      <Input
                        type="time"
                        className="h-8 text-xs"
                        value={row.time}
                        onChange={(e) => updateRow(row.id, "time", e.target.value)}
                      />
                    </td>
                    <td className="px-1 py-1">
                      <Input
                        className="h-8 text-xs"
                        placeholder="e.g. Group A"
                        value={row.round}
                        onChange={(e) => updateRow(row.id, "round", e.target.value)}
                      />
                    </td>
                    <td className="px-1 py-1">
                      <Input
                        className="h-8 text-xs"
                        placeholder="Venue"
                        value={row.venue}
                        onChange={(e) => updateRow(row.id, "venue", e.target.value)}
                      />
                    </td>
                    <td className="px-1 py-1 text-center">
                      <button
                        className="text-muted-foreground hover:text-destructive text-base leading-none"
                        onClick={() => removeRow(row.id)}
                        title="Remove row"
                      >
                        ×
                      </button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>

        {/* Add Row + status */}
        <div className="flex items-center gap-3 pt-1 shrink-0">
          <Button size="sm" variant="ghost" className="text-xs" onClick={addRow}>
            + Add Row
          </Button>
          <span className="text-xs text-muted-foreground ml-auto">
            {validRows.length} of {rows.length} fixture{rows.length !== 1 ? "s" : ""} ready
          </span>
          {results && (
            <span className={`text-xs font-medium ${results.fail > 0 ? "text-red-600" : "text-green-600"}`}>
              {results.ok} created{results.fail > 0 ? `, ${results.fail} failed` : ""}
            </span>
          )}
        </div>

        <DialogFooter className="shrink-0">
          <Button variant="outline" onClick={() => { setOpen(false); reset(); }}>Cancel</Button>
          <Button
            disabled={validRows.length === 0 || submitting}
            onClick={handleSubmit}
          >
            {submitting ? "Creating..." : `Create ${validRows.length} Fixture${validRows.length !== 1 ? "s" : ""}`}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

// ── Schedule Tab ──────────────────────────────────────────────────────
function ScheduleTab({ tournament }: { tournament: TournamentRecord }) {
  const scheduleQuery = useTournamentScheduleQuery(tournament.id);
  const smartSchedule = useSmartScheduleMutation();
  const deleteSchedule = useDeleteScheduleMutation();
  const advanceRound = useAdvanceKnockoutRoundMutation();

  // Default to tournament's own start date
  const defaultStartDate = tournament.startDate
    ? new Date(tournament.startDate).toISOString().split("T")[0]
    : "";
  const [startDate, setStartDate] = useState(defaultStartDate);
  const [matchStartTime, setMatchStartTime] = useState("09:00");
  const [matchesPerDay, setMatchesPerDay] = useState(2);
  const [gapHours, setGapHours] = useState(3);
  const [selectedDays, setSelectedDays] = useState<number[]>([6, 0]); // Sat, Sun default
  const [excludeDates, setExcludeDates] = useState<string[]>([]);
  const [excludeInput, setExcludeInput] = useState("");
  const [confirmDelete, setConfirmDelete] = useState(false);

  const matches = (scheduleQuery.data as ScheduleMatch[] | undefined) ?? [];
  const live = matches.filter((m) => m.status === "IN_PROGRESS");
  const upcoming = matches.filter((m) => m.status === "SCHEDULED");
  const completed = matches.filter(
    (m) => m.status === "COMPLETED" || m.status === "ABANDONED",
  );

  function toggleDay(d: number) {
    setSelectedDays((prev) =>
      prev.includes(d) ? prev.filter((x) => x !== d) : [...prev, d],
    );
  }

  function groupByRound(list: ScheduleMatch[]) {
    return list.reduce(
      (acc, m) => {
        const key = m.round ?? "Fixtures";
        if (!acc[key]) acc[key] = [];
        acc[key].push(m);
        return acc;
      },
      {} as Record<string, ScheduleMatch[]>,
    );
  }

  return (
    <div className="space-y-6">
      {/* Smart Schedule Form */}
      {matches.length === 0 && (
        <div className="rounded-xl border p-5 space-y-5">
          <div>
            <div className="text-base font-semibold">Generate Schedule</div>
            <div className="text-xs text-muted-foreground mt-0.5">
              Configure how fixtures should be spread across dates.
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4 sm:grid-cols-4">
            <div className="space-y-1 col-span-2">
              <label className="text-xs font-medium">Start Date *</label>
              <Input
                type="date"
                value={startDate}
                onChange={(e) => setStartDate(e.target.value)}
              />
            </div>
            <div className="space-y-1">
              <label className="text-xs font-medium">First Match Time</label>
              <Input
                type="time"
                value={matchStartTime}
                onChange={(e) => setMatchStartTime(e.target.value)}
              />
            </div>
            <div className="space-y-1">
              <label className="text-xs font-medium">Matches Per Day</label>
              <Input
                type="number"
                min={1}
                max={8}
                value={matchesPerDay}
                onChange={(e) => setMatchesPerDay(Number(e.target.value))}
              />
            </div>
            <div className="space-y-1 col-span-2">
              <label className="text-xs font-medium">
                Gap Between Matches (hours)
              </label>
              <Input
                type="number"
                min={1}
                max={12}
                value={gapHours}
                onChange={(e) => setGapHours(Number(e.target.value))}
              />
            </div>
          </div>

          <div className="space-y-2">
            <label className="text-xs font-medium">Play on Days</label>
            <div className="flex gap-2 flex-wrap">
              {WEEKDAYS.map((day) => (
                <button
                  key={day.value}
                  onClick={() => toggleDay(day.value)}
                  className={`px-3 py-1.5 rounded-lg text-xs font-medium border transition-colors ${
                    selectedDays.includes(day.value)
                      ? "bg-primary text-primary-foreground border-primary"
                      : "bg-background text-muted-foreground border-border hover:border-primary/50"
                  }`}
                >
                  {day.label}
                </button>
              ))}
            </div>
          </div>

          <div className="space-y-2">
            <label className="text-xs font-medium">
              Exclude Dates (holidays, rest days)
            </label>
            <div className="flex gap-2">
              <Input
                type="date"
                value={excludeInput}
                onChange={(e) => setExcludeInput(e.target.value)}
                className="flex-1"
              />
              <Button
                size="sm"
                variant="outline"
                onClick={() => {
                  if (excludeInput && !excludeDates.includes(excludeInput)) {
                    setExcludeDates((p) => [...p, excludeInput]);
                    setExcludeInput("");
                  }
                }}
              >
                Add
              </Button>
            </div>
            {excludeDates.length > 0 && (
              <div className="flex gap-2 flex-wrap">
                {excludeDates.map((d) => (
                  <span
                    key={d}
                    className="inline-flex items-center gap-1 text-xs bg-muted px-2 py-1 rounded-md"
                  >
                    {d}
                    <button
                      className="text-muted-foreground hover:text-destructive"
                      onClick={() =>
                        setExcludeDates((p) => p.filter((x) => x !== d))
                      }
                    >
                      ×
                    </button>
                  </span>
                ))}
              </div>
            )}
          </div>

          <div className="flex items-center gap-3 flex-wrap">
            <Button
              disabled={
                !startDate || selectedDays.length === 0 || smartSchedule.isPending
              }
              onClick={() =>
                smartSchedule.mutate({
                  id: tournament.id,
                  data: {
                    startDate,
                    matchStartTime,
                    matchesPerDay,
                    gapBetweenMatchesHours: gapHours,
                    validWeekdays: selectedDays,
                    excludeDates,
                  },
                })
              }
            >
              {smartSchedule.isPending ? "Generating..." : "Generate Fixtures"}
            </Button>
            <AddFixtureDialog tournament={tournament} />
            <BulkFixtureDialog tournament={tournament} />
          </div>
        </div>
      )}

      {/* Schedule controls when fixtures exist */}
      {matches.length > 0 && (
        <div className="flex items-center justify-between flex-wrap gap-2">
          <div className="text-sm text-muted-foreground">
            {matches.length} fixtures ·{" "}
            <span className="text-green-600">{live.length} live</span> ·{" "}
            {upcoming.length} upcoming · {completed.length} done
          </div>
          <div className="flex items-center gap-2 flex-wrap">
            <AddFixtureDialog tournament={tournament} />
            <BulkFixtureDialog tournament={tournament} />
            {[
              "KNOCKOUT",
              "DOUBLE_ELIMINATION",
              "GROUP_STAGE_KNOCKOUT",
              "SUPER_LEAGUE",
            ].includes(tournament.tournamentFormat ?? "") && (
              <Button
                size="sm"
                variant="outline"
                disabled={advanceRound.isPending}
                onClick={() => advanceRound.mutate(tournament.id)}
              >
                {advanceRound.isPending
                  ? "Advancing..."
                  : "Advance to Next Round"}
              </Button>
            )}
            {!confirmDelete ? (
              <Button
                size="sm"
                variant="destructive"
                onClick={() => setConfirmDelete(true)}
              >
                Delete Schedule
              </Button>
            ) : (
              <div className="flex gap-1.5 items-center">
                <span className="text-xs text-destructive font-medium">
                  Delete all fixtures?
                </span>
                <Button
                  size="sm"
                  variant="destructive"
                  disabled={deleteSchedule.isPending}
                  onClick={() =>
                    deleteSchedule.mutate(tournament.id, {
                      onSuccess: () => setConfirmDelete(false),
                    })
                  }
                >
                  {deleteSchedule.isPending ? "Deleting..." : "Yes, Delete"}
                </Button>
                <Button
                  size="sm"
                  variant="ghost"
                  onClick={() => setConfirmDelete(false)}
                >
                  Cancel
                </Button>
              </div>
            )}
          </div>
        </div>
      )}

      {scheduleQuery.isLoading && (
        <div className="py-8 text-center text-sm text-muted-foreground">
          Loading...
        </div>
      )}

      {live.length > 0 && (
        <div className="space-y-2">
          <div className="text-xs font-semibold text-green-600 uppercase tracking-wider">
            ● Live Now
          </div>
          {live.map((m) => (
            <MatchCard key={m.id} match={m} tournamentId={tournament.id} />
          ))}
        </div>
      )}

      {upcoming.length > 0 && (
        <div className="space-y-4">
          <div className="text-xs font-semibold text-foreground uppercase tracking-wider">
            Upcoming ({upcoming.length})
          </div>
          {Object.entries(groupByRound(upcoming)).map(([round, ms]) => (
            <div key={round} className="space-y-2">
              <div className="text-xs font-medium text-muted-foreground border-b pb-1">
                {round}
              </div>
              {ms.map((m) => (
                <MatchCard key={m.id} match={m} tournamentId={tournament.id} />
              ))}
            </div>
          ))}
        </div>
      )}

      {completed.length > 0 && (
        <div className="space-y-4">
          <div className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">
            Completed ({completed.length})
          </div>
          {Object.entries(groupByRound(completed)).map(([round, ms]) => (
            <div key={round} className="space-y-2">
              <div className="text-xs font-medium text-muted-foreground border-b pb-1">
                {round}
              </div>
              {ms.map((m) => (
                <MatchCard key={m.id} match={m} tournamentId={tournament.id} />
              ))}
            </div>
          ))}
        </div>
      )}

      {!scheduleQuery.isLoading &&
        matches.length === 0 &&
        !smartSchedule.isPending && (
          <div className="text-center py-4 text-sm text-muted-foreground">
            Configure the schedule above and click Generate Fixtures.
          </div>
        )}
    </div>
  );
}

// ── Bracket Match Card ────────────────────────────────────────────────
const KNOCKOUT_ROUND_ORDER = [
  "Round of 32",
  "Round of 16",
  "Round of 8",
  "Quarter Final",
  "Semi Final",
  "Final",
  "Grand Final",
];

function bmcWon(match: ScheduleMatch, side: "A" | "B") {
  if (!match.winnerId) return false;
  const w = match.winnerId;
  return side === "A"
    ? w === "A" || w.toLowerCase() === match.teamAName.toLowerCase()
    : w !== "A" && w.toLowerCase() !== match.teamAName.toLowerCase();
}

function BracketMatchCard({
  match,
  isFinal,
}: {
  match: ScheduleMatch;
  isFinal?: boolean;
}) {
  const isLive = match.status === "IN_PROGRESS";
  const isDone = match.status === "COMPLETED" || match.status === "ABANDONED";
  const isWalkover = match.winMargin === "W/O";
  const aWon = isDone && bmcWon(match, "A");
  const bWon = isDone && bmcWon(match, "B");
  const inn1 = match.innings.find((i) => i.inningsNumber === 1);
  const inn2 = match.innings.find((i) => i.inningsNumber === 2);
  const aScore = inn1 ? `${inn1.totalRuns}/${inn1.totalWickets}` : null;
  const bScore = inn2 ? `${inn2.totalRuns}/${inn2.totalWickets}` : null;
  const dateStr = new Date(match.scheduledAt).toLocaleDateString("en-IN", {
    day: "numeric",
    month: "short",
  });

  const cardBase = `rounded-xl overflow-hidden shadow-md border ${isFinal ? "w-60" : "w-52"} text-xs`;
  const cardBorder = isLive
    ? "border-green-400 ring-2 ring-green-300/40"
    : isDone
      ? "border-border"
      : "border-border/50";

  const rowBase = "flex items-center gap-2 px-3 py-2";
  const aRowCls = aWon
    ? "bg-emerald-50 dark:bg-emerald-950/40 border-b border-emerald-200/60 dark:border-emerald-700/30"
    : isDone
      ? "bg-muted/20 border-b border-border/40"
      : "border-b border-border/40";
  const bRowCls = bWon
    ? "bg-emerald-50 dark:bg-emerald-950/40"
    : isDone
      ? "bg-muted/20"
      : "";

  return (
    <div className={`${cardBase} ${cardBorder}`}>
      {/* Team A row */}
      <div className={`${rowBase} ${aRowCls}`}>
        {aWon && <span className="text-emerald-500 shrink-0">▶</span>}
        {!aWon && isDone && (
          <span className="text-muted-foreground/40 shrink-0 text-[10px]">
            ◀
          </span>
        )}
        {!isDone && <span className="w-3 shrink-0" />}
        <span
          className={`flex-1 truncate font-semibold ${aWon ? "text-emerald-700 dark:text-emerald-300" : isDone ? "text-muted-foreground" : "text-foreground"}`}
        >
          {match.teamAName}
        </span>
        {aScore && (
          <span
            className={`font-mono text-[11px] shrink-0 ${aWon ? "font-bold text-emerald-700 dark:text-emerald-300" : "text-muted-foreground"}`}
          >
            {aScore}
          </span>
        )}
        {aWon && (
          <span className="text-emerald-500 shrink-0 text-base leading-none">
            ✓
          </span>
        )}
      </div>

      {/* Team B row */}
      <div className={`${rowBase} ${bRowCls}`}>
        {bWon && <span className="text-emerald-500 shrink-0">▶</span>}
        {!bWon && isDone && (
          <span className="text-muted-foreground/40 shrink-0 text-[10px]">
            ◀
          </span>
        )}
        {!isDone && <span className="w-3 shrink-0" />}
        <span
          className={`flex-1 truncate font-semibold ${bWon ? "text-emerald-700 dark:text-emerald-300" : isDone ? "text-muted-foreground" : "text-foreground"}`}
        >
          {match.teamBName}
        </span>
        {bScore && (
          <span
            className={`font-mono text-[11px] shrink-0 ${bWon ? "font-bold text-emerald-700 dark:text-emerald-300" : "text-muted-foreground"}`}
          >
            {bScore}
          </span>
        )}
        {bWon && (
          <span className="text-emerald-500 shrink-0 text-base leading-none">
            ✓
          </span>
        )}
      </div>

      {/* Footer */}
      <div className="flex items-center justify-between px-3 py-1 bg-muted/30">
        <span className="text-[10px] text-muted-foreground">
          {dateStr}
          {isWalkover ? " · W/O" : ""}
        </span>
        {isLive && (
          <span className="text-[10px] font-semibold text-green-600 animate-pulse">
            ● LIVE
          </span>
        )}
        {isDone && !match.winnerId && (
          <span className="text-[10px] text-muted-foreground">No Result</span>
        )}
        {match.status === "SCHEDULED" && (
          <span className="text-[10px] text-muted-foreground/60">Upcoming</span>
        )}
      </div>
    </div>
  );
}

// ── Knockout Bracket ──────────────────────────────────────────────────
function KnockoutBracket({ matches }: { matches: ScheduleMatch[] }) {
  const byRound = matches.reduce(
    (acc, m) => {
      const r = m.round ?? "Round";
      if (!acc[r]) acc[r] = [];
      acc[r].push(m);
      return acc;
    },
    {} as Record<string, ScheduleMatch[]>,
  );

  const rounds = Object.keys(byRound).sort((a, b) => {
    const ai = KNOCKOUT_ROUND_ORDER.indexOf(a);
    const bi = KNOCKOUT_ROUND_ORDER.indexOf(b);
    if (ai === -1 && bi === -1) return 0;
    if (ai === -1) return 1;
    if (bi === -1) return -1;
    return ai - bi;
  });

  // Find tournament winner (winner of the last round's only match)
  const lastRound = rounds[rounds.length - 1];
  const finalMatches = lastRound ? byRound[lastRound] : [];
  const champion =
    finalMatches.length === 1 && finalMatches[0].winnerId
      ? finalMatches[0].winnerId === "A"
        ? finalMatches[0].teamAName
        : finalMatches[0].winnerId.toLowerCase() ===
            finalMatches[0].teamAName.toLowerCase()
          ? finalMatches[0].teamAName
          : finalMatches[0].teamBName
      : null;

  return (
    <div className="overflow-x-auto pb-4">
      <div className="flex items-center gap-0 min-w-fit">
        {rounds.map((round, roundIdx) => {
          const roundMatches = byRound[round];
          const isFinal = round === "Final" || round === "Grand Final";
          // Vertical spacing: more gap for later (fewer-match) rounds
          const gapRem = Math.max(0.5, (rounds.length - roundIdx) * 1.5);

          return (
            <div key={round} className="flex items-stretch">
              {/* Round column */}
              <div className="flex flex-col min-w-[220px]">
                {/* Round label */}
                <div
                  className={`text-[11px] font-bold text-center mb-3 py-1 px-3 mx-2 rounded-full ${isFinal ? "bg-amber-100 dark:bg-amber-900/30 text-amber-700 dark:text-amber-300" : "bg-muted text-muted-foreground"}`}
                >
                  {round.toUpperCase()}
                </div>
                {/* Matches in this round */}
                <div
                  className="flex flex-col flex-1 justify-around"
                  style={{ gap: `${gapRem}rem` }}
                >
                  {roundMatches.map((m) => (
                    <div key={m.id} className="px-2">
                      <BracketMatchCard match={m} isFinal={isFinal} />
                    </div>
                  ))}
                </div>
              </div>

              {/* Connector lines between rounds */}
              {roundIdx < rounds.length - 1 && (
                <div
                  className="flex flex-col justify-around w-8 shrink-0"
                  style={{ gap: `${gapRem * 2}rem` }}
                >
                  {Array.from({
                    length: Math.ceil(roundMatches.length / 2),
                  }).map((_, i) => (
                    <div
                      key={i}
                      className="flex flex-col justify-center"
                      style={{ height: `${gapRem * 2 + 7}rem` }}
                    >
                      <div className="border-r border-t border-border/50 h-1/2" />
                      <div className="border-r border-b border-border/50 h-1/2" />
                    </div>
                  ))}
                </div>
              )}
            </div>
          );
        })}

        {/* Champion display */}
        {rounds.length > 0 && (
          <div className="flex flex-col items-center justify-center ml-2 px-4 py-6 min-w-[120px]">
            <div className="text-4xl mb-2">🏆</div>
            {champion ? (
              <>
                <div className="text-xs font-bold text-amber-600 dark:text-amber-400 text-center uppercase tracking-wide">
                  Champion
                </div>
                <div className="mt-1 rounded-xl bg-amber-50 dark:bg-amber-900/30 border border-amber-300 dark:border-amber-600 px-4 py-2 text-center">
                  <div className="text-sm font-bold text-amber-700 dark:text-amber-300">
                    {champion}
                  </div>
                </div>
              </>
            ) : (
              <div className="text-xs text-muted-foreground text-center">
                Winner
                <br />
                TBD
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}

// ── League Round-Robin Grid ────────────────────────────────────────────
function LeagueBracket({
  matches,
  tournament,
}: {
  matches: ScheduleMatch[];
  tournament: TournamentRecord;
}) {
  // Build team list from matches
  const teamSet = new Set<string>();
  matches.forEach((m) => {
    teamSet.add(m.teamAName);
    teamSet.add(m.teamBName);
  });
  const teams = Array.from(teamSet);

  // Build lookup: "TeamA|TeamB" -> match
  const matchLookup = new Map<string, ScheduleMatch>();
  matches.forEach((m) => {
    matchLookup.set(`${m.teamAName}|${m.teamBName}`, m);
    matchLookup.set(`${m.teamBName}|${m.teamAName}`, m);
  });

  function getResult(a: string, b: string) {
    const m = matchLookup.get(`${a}|${b}`);
    if (!m) return null;
    const isDone = m.status === "COMPLETED" || m.status === "ABANDONED";
    const isLive = m.status === "IN_PROGRESS";
    const aWon =
      isDone &&
      m.winnerId &&
      (m.winnerId === a ||
        (m.winnerId === "A" && m.teamAName === a) ||
        (m.winnerId !== "A" && m.teamBName === a));
    return { isDone, isLive, aWon };
  }

  if (teams.length > 12) {
    return (
      <div className="text-sm text-muted-foreground">
        Too many teams for grid view. Check the Schedule tab for fixtures.
      </div>
    );
  }

  return (
    <div className="overflow-x-auto">
      <table className="text-xs border-collapse">
        <thead>
          <tr>
            <th className="p-2 text-left font-medium text-muted-foreground w-28">
              Team
            </th>
            {teams.map((t) => (
              <th key={t} className="p-2 text-center font-medium max-w-[60px]">
                <div className="truncate w-14">{t}</div>
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {teams.map((rowTeam) => (
            <tr key={rowTeam} className="border-t">
              <td className="p-2 font-medium truncate max-w-[7rem]">
                {rowTeam}
              </td>
              {teams.map((colTeam) => {
                if (rowTeam === colTeam)
                  return (
                    <td key={colTeam} className="p-2 text-center bg-muted/30">
                      <div className="w-10 h-6 mx-auto bg-muted rounded" />
                    </td>
                  );
                const result = getResult(rowTeam, colTeam);
                if (!result)
                  return (
                    <td
                      key={colTeam}
                      className="p-2 text-center text-muted-foreground"
                    >
                      —
                    </td>
                  );
                const { isDone, isLive, aWon } = result;
                return (
                  <td key={colTeam} className="p-2 text-center">
                    <div
                      className={`w-10 h-6 mx-auto rounded flex items-center justify-center font-bold text-[10px] ${
                        isLive
                          ? "bg-green-100 dark:bg-green-950/50 text-green-700 dark:text-green-300 animate-pulse"
                          : isDone
                            ? aWon
                              ? "bg-green-100 dark:bg-green-950/50 text-green-700 dark:text-green-400"
                              : "bg-red-100 dark:bg-red-950/50 text-red-600 dark:text-red-400"
                            : "bg-muted/50 text-muted-foreground"
                      }`}
                    >
                      {isLive ? "●" : isDone ? (aWon ? "W" : "L") : "·"}
                    </div>
                  </td>
                );
              })}
            </tr>
          ))}
        </tbody>
      </table>
      <div className="flex gap-4 mt-3 text-xs text-muted-foreground">
        <span className="flex items-center gap-1">
          <span className="inline-block w-4 h-3 rounded bg-green-100 dark:bg-green-950/50" />{" "}
          W = Win
        </span>
        <span className="flex items-center gap-1">
          <span className="inline-block w-4 h-3 rounded bg-red-100 dark:bg-red-950/50" />{" "}
          L = Loss
        </span>
        <span className="flex items-center gap-1">
          <span className="inline-block w-4 h-3 rounded bg-green-100 dark:bg-green-950/50 animate-pulse" />{" "}
          ● = Live
        </span>
        <span className="flex items-center gap-1">
          <span className="inline-block w-4 h-3 rounded bg-muted/50" /> · =
          Upcoming
        </span>
      </div>
    </div>
  );
}

// ── Group + Knockout Bracket ───────────────────────────────────────────
function GroupKnockoutBracket({
  matches,
  tournament,
}: {
  matches: ScheduleMatch[];
  tournament: TournamentRecord;
}) {
  const knockoutRounds = new Set(KNOCKOUT_ROUND_ORDER);
  const groupMatches = matches.filter(
    (m) => !knockoutRounds.has(m.round ?? ""),
  );
  const knockoutMatches = matches.filter((m) =>
    knockoutRounds.has(m.round ?? ""),
  );

  // Group stage: group by round (group name)
  const byGroup = groupMatches.reduce(
    (acc, m) => {
      const g = m.round ?? "Group Stage";
      if (!acc[g]) acc[g] = [];
      acc[g].push(m);
      return acc;
    },
    {} as Record<string, ScheduleMatch[]>,
  );

  return (
    <div className="space-y-6">
      {/* Group stage */}
      {Object.keys(byGroup).length > 0 && (
        <div>
          <div className="text-sm font-semibold mb-3">Group Stage</div>
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {Object.entries(byGroup).map(([groupName, gMatches]) => (
              <div key={groupName} className="rounded-lg border p-3 space-y-2">
                <div className="text-xs font-semibold text-muted-foreground uppercase tracking-wide">
                  {groupName}
                </div>
                {gMatches.map((m) => (
                  <BracketMatchCard key={m.id} match={m} />
                ))}
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Knockout stage */}
      {knockoutMatches.length > 0 && (
        <div>
          <div className="text-sm font-semibold mb-3">Knockout Stage</div>
          <KnockoutBracket matches={knockoutMatches} />
        </div>
      )}

      {groupMatches.length === 0 && knockoutMatches.length === 0 && (
        <div className="text-sm text-muted-foreground">No fixtures yet.</div>
      )}
    </div>
  );
}

// ── Brackets Tab ──────────────────────────────────────────────────────
function BracketsTab({ tournament }: { tournament: TournamentRecord }) {
  const scheduleQuery = useTournamentScheduleQuery(tournament.id);
  const standingsQuery = useTournamentStandingsQuery(tournament.id);
  const matches = (scheduleQuery.data as ScheduleMatch[] | undefined) ?? [];
  const standings = standingsQuery.data as
    | Record<string, StandingRow[]>
    | undefined;
  const fmt = tournament.tournamentFormat ?? "LEAGUE";

  function handleDownload() {
    const printWin = window.open("", "_blank", "width=1100,height=800");
    if (!printWin) return;

    const completed = matches.filter(
      (m) => m.status === "COMPLETED" || m.status === "ABANDONED",
    );
    const upcoming = matches.filter((m) => m.status === "SCHEDULED");

    // Build standings table HTML
    let standingsHtml = "";
    if (standings && Object.keys(standings).length > 0) {
      standingsHtml = `<h2 style="margin:28px 0 10px;font-size:15px;font-weight:700;color:#374151;border-bottom:2px solid #e5e7eb;padding-bottom:6px;">Points Table</h2>`;
      for (const [, rows] of Object.entries(standings)) {
        const groupName = rows[0]?.group?.name;
        if (groupName)
          standingsHtml += `<div style="font-size:12px;font-weight:600;color:#6b7280;margin:10px 0 4px;">${groupName}</div>`;
        standingsHtml += `<table style="width:100%;border-collapse:collapse;font-size:12px;margin-bottom:12px;">
          <thead><tr style="background:#f9fafb;">${["#", "Team", "P", "W", "L", "T", "NR", "Pts", "NRR"].map((h) => `<th style="padding:6px 8px;text-align:${h == "#" || h === "Team" ? "left" : "center"};border:1px solid #e5e7eb;font-weight:600;color:#374151;">${h}</th>`).join("")}</tr></thead>
          <tbody>${rows
            .map(
              (
                r,
                i,
              ) => `<tr style="background:${i % 2 === 0 ? "#fff" : "#f9fafb"}">
            <td style="padding:5px 8px;border:1px solid #e5e7eb;color:#6b7280;">${i + 1}</td>
            <td style="padding:5px 8px;border:1px solid #e5e7eb;font-weight:600;${i === 0 ? "color:#059669;" : ""}">${r.team.teamName}</td>
            <td style="padding:5px 8px;border:1px solid #e5e7eb;text-align:center;">${r.played}</td>
            <td style="padding:5px 8px;border:1px solid #e5e7eb;text-align:center;color:#059669;font-weight:600;">${r.won}</td>
            <td style="padding:5px 8px;border:1px solid #e5e7eb;text-align:center;color:#dc2626;">${r.lost}</td>
            <td style="padding:5px 8px;border:1px solid #e5e7eb;text-align:center;">${r.tied}</td>
            <td style="padding:5px 8px;border:1px solid #e5e7eb;text-align:center;color:#6b7280;">${r.noResult}</td>
            <td style="padding:5px 8px;border:1px solid #e5e7eb;text-align:center;font-weight:700;">${r.points}</td>
            <td style="padding:5px 8px;border:1px solid #e5e7eb;text-align:center;font-family:monospace;">${r.nrr >= 0 ? "+" : ""}${r.nrr.toFixed(3)}</td>
          </tr>`,
            )
            .join("")}</tbody>
        </table>`;
      }
    }

    // Build results HTML
    const resultRows = completed
      .map((m) => {
        const winner =
          m.winnerId === "A" ||
          m.winnerId?.toLowerCase() === m.teamAName.toLowerCase()
            ? m.teamAName
            : m.teamBName;
        const isWO = m.winMargin === "W/O";
        return `<tr>
        <td style="padding:5px 8px;border:1px solid #e5e7eb;color:#6b7280;font-size:11px;">${m.round ?? ""}</td>
        <td style="padding:5px 8px;border:1px solid #e5e7eb;font-weight:600;">${m.teamAName}</td>
        <td style="padding:5px 8px;border:1px solid #e5e7eb;text-align:center;color:#6b7280;">vs</td>
        <td style="padding:5px 8px;border:1px solid #e5e7eb;font-weight:600;">${m.teamBName}</td>
        <td style="padding:5px 8px;border:1px solid #e5e7eb;font-weight:700;color:#059669;">${m.winnerId ? winner + (isWO ? " (W/O)" : "") : "No Result"}</td>
        <td style="padding:5px 8px;border:1px solid #e5e7eb;color:#6b7280;font-size:11px;">${new Date(m.scheduledAt).toLocaleDateString("en-IN", { day: "numeric", month: "short", year: "numeric" })}</td>
      </tr>`;
      })
      .join("");

    const upcomingRows = upcoming
      .map(
        (m) => `<tr>
      <td style="padding:5px 8px;border:1px solid #e5e7eb;color:#6b7280;font-size:11px;">${m.round ?? ""}</td>
      <td style="padding:5px 8px;border:1px solid #e5e7eb;font-weight:600;">${m.teamAName}</td>
      <td style="padding:5px 8px;border:1px solid #e5e7eb;text-align:center;color:#6b7280;">vs</td>
      <td style="padding:5px 8px;border:1px solid #e5e7eb;font-weight:600;">${m.teamBName}</td>
      <td style="padding:5px 8px;border:1px solid #e5e7eb;color:#9ca3af;">Upcoming</td>
      <td style="padding:5px 8px;border:1px solid #e5e7eb;color:#6b7280;font-size:11px;">${new Date(m.scheduledAt).toLocaleDateString("en-IN", { day: "numeric", month: "short", year: "numeric" })}</td>
    </tr>`,
      )
      .join("");

    const t = tournament as any;
    const html = `<!DOCTYPE html><html><head><meta charset="utf-8"><title>${tournament.name} — Results</title>
    <style>
      * { box-sizing: border-box; margin: 0; padding: 0; }
      body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; color: #111827; background: #fff; padding: 36px 44px; }
      @media print { body { padding: 20px; } .no-print { display: none; } }
    </style></head><body>
    <button class="no-print" onclick="window.print()" style="position:fixed;top:16px;right:16px;background:#111;color:#fff;border:none;padding:8px 20px;border-radius:8px;font-size:13px;cursor:pointer;font-weight:600;">⬇ Save as PDF</button>

    <!-- Header -->
    <div style="border-bottom:3px solid #111827;padding-bottom:16px;margin-bottom:20px;">
      <div style="font-size:22px;font-weight:800;letter-spacing:-0.5px;">${tournament.name}</div>
      <div style="display:flex;gap:20px;margin-top:8px;flex-wrap:wrap;">
        <span style="font-size:12px;color:#6b7280;">📋 ${fmt.replace(/_/g, " ")} · ${tournament.format}</span>
        ${tournament.status ? `<span style="font-size:12px;color:#6b7280;">● ${tournament.status}</span>` : ""}
        ${tournament.startDate ? `<span style="font-size:12px;color:#6b7280;">📅 ${new Date(tournament.startDate).toLocaleDateString("en-IN", { day: "numeric", month: "long", year: "numeric" })}${t.endDate ? " → " + new Date(t.endDate).toLocaleDateString("en-IN", { day: "numeric", month: "long", year: "numeric" }) : ""}` : ""}
        ${tournament.venueName ? `<span style="font-size:12px;color:#6b7280;">📍 ${tournament.venueName}${tournament.city ? ", " + tournament.city : ""}</span>` : tournament.city ? `<span style="font-size:12px;color:#6b7280;">📍 ${tournament.city}</span>` : ""}
        ${t.prizePool ? `<span style="font-size:12px;color:#6b7280;">🏅 ${t.prizePool}</span>` : ""}
      </div>
    </div>

    <!-- Stats row -->
    <div style="display:flex;gap:16px;margin-bottom:24px;">
      ${[
        ["Total Matches", matches.length],
        ["Completed", completed.length],
        ["Upcoming", upcoming.length],
        [
          "Teams",
          [...new Set(matches.flatMap((m) => [m.teamAName, m.teamBName]))]
            .length,
        ],
      ]
        .map(
          ([
            k,
            v,
          ]) => `<div style="flex:1;background:#f9fafb;border:1px solid #e5e7eb;border-radius:10px;padding:12px 16px;text-align:center;">
        <div style="font-size:22px;font-weight:800;color:#111827;">${v}</div>
        <div style="font-size:11px;color:#6b7280;margin-top:2px;">${k}</div>
      </div>`,
        )
        .join("")}
    </div>

    ${standingsHtml}

    <!-- Results -->
    ${
      completed.length > 0
        ? `
    <h2 style="margin:24px 0 10px;font-size:15px;font-weight:700;color:#374151;border-bottom:2px solid #e5e7eb;padding-bottom:6px;">Match Results (${completed.length})</h2>
    <table style="width:100%;border-collapse:collapse;font-size:12px;">
      <thead><tr style="background:#f9fafb;">${["Round", "Team A", "", "Team B", "Result", "Date"].map((h) => `<th style="padding:6px 8px;text-align:left;border:1px solid #e5e7eb;font-weight:600;color:#374151;">${h}</th>`).join("")}</tr></thead>
      <tbody>${resultRows}</tbody>
    </table>`
        : ""
    }

    ${
      upcoming.length > 0
        ? `
    <h2 style="margin:24px 0 10px;font-size:15px;font-weight:700;color:#374151;border-bottom:2px solid #e5e7eb;padding-bottom:6px;">Upcoming Fixtures (${upcoming.length})</h2>
    <table style="width:100%;border-collapse:collapse;font-size:12px;">
      <thead><tr style="background:#f9fafb;">${["Round", "Team A", "", "Team B", "Status", "Date"].map((h) => `<th style="padding:6px 8px;text-align:left;border:1px solid #e5e7eb;font-weight:600;color:#374151;">${h}</th>`).join("")}</tr></thead>
      <tbody>${upcomingRows}</tbody>
    </table>`
        : ""
    }

    <div style="margin-top:36px;border-top:1px solid #e5e7eb;padding-top:12px;font-size:11px;color:#9ca3af;">
      Generated ${new Date().toLocaleString("en-IN")} · Swing Cricket Platform
    </div>
    </body></html>`;

    printWin.document.write(html);
    printWin.document.close();
    setTimeout(() => printWin.focus(), 300);
  }

  if (scheduleQuery.isLoading) {
    return (
      <div className="py-12 text-center text-sm text-muted-foreground">
        Loading bracket...
      </div>
    );
  }

  if (matches.length === 0) {
    return (
      <div className="py-12 text-center">
        <div className="text-4xl mb-3">📋</div>
        <div className="text-sm font-medium">No fixtures yet</div>
        <div className="text-xs text-muted-foreground mt-1">
          Go to the Schedule tab to generate fixtures first.
        </div>
      </div>
    );
  }

  const completed = matches.filter(
    (m) => m.status === "COMPLETED" || m.status === "ABANDONED",
  );

  return (
    <div className="space-y-6">
      {/* Header bar */}
      <div className="flex items-center justify-between gap-3 flex-wrap">
        <div className="flex items-center gap-2">
          <Badge variant="outline">{fmt.replace(/_/g, " ")}</Badge>
          <span className="text-xs text-muted-foreground">
            {completed.length}/{matches.length} matches done
          </span>
        </div>
        <Button size="sm" variant="outline" onClick={handleDownload}>
          ⬇ Download Report
        </Button>
      </div>

      {(fmt === "KNOCKOUT" || fmt === "DOUBLE_ELIMINATION") && (
        <KnockoutBracket matches={matches} />
      )}
      {(fmt === "LEAGUE" || fmt === "SERIES") && (
        <LeagueBracket matches={matches} tournament={tournament} />
      )}
      {(fmt === "GROUP_STAGE_KNOCKOUT" || fmt === "SUPER_LEAGUE") && (
        <GroupKnockoutBracket matches={matches} tournament={tournament} />
      )}
    </div>
  );
}

// ── Edit Tab ──────────────────────────────────────────────────────────
function EditTab({ tournament }: { tournament: TournamentRecord }) {
  const update = useUpdateTournamentMutation();
  const [form, setForm] = useState({
    name: tournament.name ?? "",
    description: (tournament as any).description ?? "",
    format: tournament.format ?? "T20",
    tournamentFormat: tournament.tournamentFormat ?? "LEAGUE",
    venueName: tournament.venueName ?? "",
    city: tournament.city ?? "",
    startDate: tournament.startDate
      ? new Date(tournament.startDate).toISOString().slice(0, 16)
      : "",
    endDate: (tournament as any).endDate
      ? new Date((tournament as any).endDate).toISOString().slice(0, 16)
      : "",
    maxTeams: tournament.maxTeams ?? 8,
    seriesMatchCount: (tournament as any).seriesMatchCount ?? "",
    entryFee: (tournament as any).entryFee ?? "",
    prizePool: (tournament as any).prizePool ?? "",
    rules: (tournament as any).rules ?? "",
    pointsForWin: (tournament as any).pointsForWin ?? 2,
    pointsForLoss: (tournament as any).pointsForLoss ?? 0,
    pointsForTie: (tournament as any).pointsForTie ?? 1,
    pointsForNoResult: (tournament as any).pointsForNoResult ?? 1,
    isPublic: (tournament as any).isPublic !== false,
    logoUrl: (tournament as any).logoUrl ?? "",
    coverUrl: (tournament as any).coverUrl ?? "",
    slug: (tournament as any).slug ?? "",
    highlights: ((tournament as any).highlights ?? []) as {
      title: string;
      youtubeUrl: string;
    }[],
  });
  const [newHighlight, setNewHighlight] = useState({
    title: "",
    youtubeUrl: "",
  });

  const isLeague = LEAGUE_FORMATS.includes(form.tournamentFormat ?? "LEAGUE");
  const isSeries = form.tournamentFormat === "SERIES";
  const hasPointsTable = POINTS_TABLE_FORMATS.includes(
    form.tournamentFormat ?? "LEAGUE",
  );

  function f(key: string, value: unknown) {
    setForm((prev: typeof form) => ({ ...prev, [key]: value }));
  }

  function handleSave() {
    const payload: any = {
      name: form.name || undefined,
      description: form.description || null,
      format: form.format || undefined,
      tournamentFormat: form.tournamentFormat || undefined,
      venueName: form.venueName || undefined,
      city: form.city || undefined,
      startDate: form.startDate
        ? new Date(form.startDate).toISOString()
        : undefined,
      endDate: form.endDate ? new Date(form.endDate).toISOString() : null,
      maxTeams: form.maxTeams ? Number(form.maxTeams) : undefined,
      seriesMatchCount:
        isSeries && form.seriesMatchCount !== ""
          ? Number(form.seriesMatchCount)
          : null,
      entryFee: form.entryFee !== "" ? Number(form.entryFee) : undefined,
      prizePool: form.prizePool || undefined,
      rules: form.rules || undefined,
      isPublic: form.isPublic,
    };
    if (hasPointsTable) {
      payload.pointsForWin = Number(form.pointsForWin);
      payload.pointsForLoss = Number(form.pointsForLoss);
      payload.pointsForTie = Number(form.pointsForTie);
      payload.pointsForNoResult = Number(form.pointsForNoResult);
    }
    payload.logoUrl = form.logoUrl || null;
    payload.coverUrl = form.coverUrl || null;
    if (form.slug) payload.slug = form.slug;
    payload.highlights = form.highlights;
    update.mutate({ id: tournament.id, data: payload });
  }

  return (
    <div className="space-y-6 max-w-2xl">
      {/* Media Section */}
      <div className="rounded-lg border p-4 space-y-4">
        <div className="text-sm font-semibold">Media &amp; Branding</div>
        <div className="flex gap-6 flex-wrap">
          <div className="space-y-1">
            <label className="text-xs font-medium text-muted-foreground">
              Tournament Logo
            </label>
            <ImageUpload
              folder="tournaments"
              id={tournament.id}
              filename="logo"
              currentUrl={form.logoUrl || null}
              onUpload={(url) => f("logoUrl", url)}
              label="Logo"
              shape="square"
              size="md"
            />
          </div>
          <div className="space-y-1">
            <label className="text-xs font-medium text-muted-foreground">
              Cover Image
            </label>
            <ImageUpload
              folder="tournaments"
              id={tournament.id}
              filename="cover"
              currentUrl={form.coverUrl || null}
              onUpload={(url) => f("coverUrl", url)}
              label="Cover"
              shape="square"
              size="lg"
            />
          </div>
        </div>
        <div className="space-y-1">
          <label className="text-xs font-medium">Public URL Slug</label>
          <div className="flex items-center gap-2">
            <span className="text-xs text-muted-foreground shrink-0">
              swingcricketapp.com/t/
            </span>
            <Input
              value={form.slug}
              onChange={(e) =>
                f(
                  "slug",
                  e.target.value.toLowerCase().replace(/[^a-z0-9-]/g, ""),
                )
              }
              placeholder="ipl-summer-2026"
              className="max-w-xs"
            />
          </div>
          {form.slug && (
            <p className="text-xs text-muted-foreground">
              swingcricketapp.com/t/{form.slug}
            </p>
          )}
        </div>
      </div>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
        <div className="space-y-1 sm:col-span-2">
          <label className="text-xs font-medium">Tournament Name</label>
          <Input
            value={form.name}
            onChange={(e) => f("name", e.target.value)}
          />
        </div>
        <div className="space-y-1 sm:col-span-2">
          <label className="text-xs font-medium">Description</label>
          <Input
            value={form.description}
            onChange={(e) => f("description", e.target.value)}
            placeholder="Optional"
          />
        </div>
        <div className="space-y-1">
          <label className="text-xs font-medium">Tournament Format</label>
          <Select
            value={form.tournamentFormat}
            onValueChange={(value) => {
              f("tournamentFormat", value);
              if (value === "SERIES") {
                if ((form.maxTeams ?? 8) > 4) f("maxTeams", 2);
                if (form.seriesMatchCount === "") f("seriesMatchCount", 3);
              } else {
                f("seriesMatchCount", "");
              }
            }}
          >
            <SelectTrigger>
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              {TOURNAMENT_FORMATS.map((tf) => (
                <SelectItem key={tf.value} value={tf.value}>
                  {tf.label}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
        <div className="space-y-1">
          <label className="text-xs font-medium">Match Format</label>
          <Select value={form.format} onValueChange={(v) => f("format", v)}>
            <SelectTrigger>
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              {MATCH_FORMATS.map((mf) => (
                <SelectItem key={mf} value={mf}>
                  {mf.replace(/_/g, " ")}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
        <div className="space-y-1">
          <label className="text-xs font-medium">Max Teams</label>
          <Input
            type="number"
            min={2}
            max={isSeries ? 4 : undefined}
            value={form.maxTeams}
            onChange={(e) => f("maxTeams", e.target.value)}
          />
        </div>
        {isSeries && (
          <div className="space-y-1">
            <label className="text-xs font-medium">
              {Number(form.maxTeams ?? 2) === 2
                ? "Matches in Series"
                : "Meetings Per Pair"}
            </label>
            <Input
              type="number"
              min={1}
              max={15}
              value={form.seriesMatchCount}
              onChange={(e) => f("seriesMatchCount", e.target.value)}
            />
          </div>
        )}
        {isSeries && (
          <div className="space-y-1 sm:col-span-2">
            <label className="text-xs font-medium">Quick Presets</label>
            <div className="flex flex-wrap gap-2">
              {SERIES_PRESETS.map((preset) => (
                <Button
                  key={preset.label}
                  type="button"
                  size="sm"
                  variant={
                    Number(form.maxTeams ?? 0) === preset.maxTeams &&
                    Number(
                      form.seriesMatchCount || (preset.maxTeams === 2 ? 3 : 1),
                    ) === preset.seriesMatchCount
                      ? "default"
                      : "outline"
                  }
                  onClick={() => {
                    f("tournamentFormat", "SERIES");
                    f("maxTeams", preset.maxTeams);
                    f("seriesMatchCount", preset.seriesMatchCount);
                  }}
                >
                  {preset.label}
                </Button>
              ))}
            </div>
          </div>
        )}
        <div className="space-y-1">
          <label className="text-xs font-medium">Start Date</label>
          <Input
            type="datetime-local"
            value={form.startDate}
            onChange={(e) => f("startDate", e.target.value)}
          />
        </div>
        <div className="space-y-1">
          <label className="text-xs font-medium">End Date</label>
          <Input
            type="datetime-local"
            value={form.endDate}
            onChange={(e) => f("endDate", e.target.value)}
          />
        </div>
        <div className="space-y-1">
          <label className="text-xs font-medium">Venue</label>
          <Input
            value={form.venueName}
            onChange={(e) => f("venueName", e.target.value)}
            placeholder="DY Patil Stadium"
          />
        </div>
        <div className="space-y-1">
          <label className="text-xs font-medium">City</label>
          <Input
            value={form.city}
            onChange={(e) => f("city", e.target.value)}
            placeholder="Mumbai"
          />
        </div>
        <div className="space-y-1">
          <label className="text-xs font-medium">Entry Fee (₹)</label>
          <Input
            type="number"
            min={0}
            value={form.entryFee}
            onChange={(e) => f("entryFee", e.target.value)}
            placeholder="0"
          />
        </div>
        <div className="space-y-1">
          <label className="text-xs font-medium">Prize Pool</label>
          <Input
            value={form.prizePool}
            onChange={(e) => f("prizePool", e.target.value)}
            placeholder="₹50,000"
          />
        </div>
        <div className="space-y-1 sm:col-span-2">
          <label className="text-xs font-medium">Rules / Notes</label>
          <Input
            value={form.rules}
            onChange={(e) => f("rules", e.target.value)}
            placeholder="DRS, powerplay rules..."
          />
        </div>
        <div className="flex items-center justify-between rounded-lg border p-3 sm:col-span-2">
          <label className="text-sm font-medium">Public Tournament</label>
          <input
            type="checkbox"
            checked={form.isPublic}
            onChange={(e) => f("isPublic", e.target.checked)}
            className="h-4 w-4"
          />
        </div>
      </div>

      {hasPointsTable && (
        <div className="rounded-lg border p-4 space-y-3">
          <div className="text-sm font-semibold">Points System</div>
          <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
            {[
              { label: "Win", key: "pointsForWin" },
              { label: "Loss", key: "pointsForLoss" },
              { label: "Tie / Draw", key: "pointsForTie" },
              { label: "No Result", key: "pointsForNoResult" },
            ].map(({ label, key }) => (
              <div key={key} className="space-y-1">
                <label className="text-xs font-medium text-muted-foreground">
                  {label}
                </label>
                <Input
                  type="number"
                  min={0}
                  max={10}
                  value={(form as any)[key]}
                  onChange={(e) => f(key, e.target.value)}
                />
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Highlights */}
      <div className="rounded-lg border p-4 space-y-3">
        <div className="text-sm font-semibold">YouTube Highlights</div>
        {form.highlights.length > 0 && (
          <div className="space-y-2">
            {form.highlights.map((h, i) => (
              <div
                key={i}
                className="flex items-center gap-2 rounded-lg bg-muted/30 px-3 py-2"
              >
                <span className="text-sm flex-1 truncate">{h.title}</span>
                <span className="text-xs text-muted-foreground truncate max-w-[200px]">
                  {h.youtubeUrl}
                </span>
                <Button
                  size="sm"
                  variant="ghost"
                  className="h-6 px-2 text-destructive"
                  onClick={() =>
                    f(
                      "highlights",
                      form.highlights.filter((_, idx) => idx !== i),
                    )
                  }
                >
                  ✕
                </Button>
              </div>
            ))}
          </div>
        )}
        <div className="flex gap-2 flex-wrap">
          <Input
            placeholder="Video title (e.g. Finals Highlights)"
            value={newHighlight.title}
            onChange={(e) =>
              setNewHighlight((p) => ({ ...p, title: e.target.value }))
            }
            className="flex-1 min-w-[160px]"
          />
          <Input
            placeholder="YouTube URL"
            value={newHighlight.youtubeUrl}
            onChange={(e) =>
              setNewHighlight((p) => ({ ...p, youtubeUrl: e.target.value }))
            }
            className="flex-1 min-w-[200px]"
          />
          <Button
            size="sm"
            variant="outline"
            disabled={!newHighlight.title || !newHighlight.youtubeUrl}
            onClick={() => {
              f("highlights", [...form.highlights, newHighlight]);
              setNewHighlight({ title: "", youtubeUrl: "" });
            }}
          >
            Add
          </Button>
        </div>
      </div>

      <Button disabled={update.isPending} onClick={handleSave}>
        {update.isPending ? "Saving..." : "Save Changes"}
      </Button>
    </div>
  );
}

// ── Main Tournament Detail Page ────────────────────────────────────────
export default function TournamentDetailPage() {
  const params = useParams();
  const router = useRouter();
  const id = params.id as string;

  const query = useTournamentQuery(id);
  const updateMutation = useUpdateTournamentMutation();
  const deleteMutation = useDeleteTournamentMutation();

  const [activeTab, setActiveTab] = useState("");
  const [statusVal, setStatusVal] = useState<string>("");
  const [confirmDelete, setConfirmDelete] = useState(false);

  const tournament = query.data as TournamentRecord | undefined;
  const isLeague = LEAGUE_FORMATS.includes(
    tournament?.tournamentFormat ?? "LEAGUE",
  );
  const hasPointsTable = POINTS_TABLE_FORMATS.includes(
    tournament?.tournamentFormat ?? "LEAGUE",
  );
  const hasGroups = GROUP_FORMATS.includes(tournament?.tournamentFormat ?? "");

  const tabs = [
    { value: "teams", label: "Teams" },
    ...(hasGroups ? [{ value: "groups", label: "Groups" }] : []),
    ...(hasPointsTable ? [{ value: "standings", label: "Points Table" }] : []),
    { value: "schedule", label: "Schedule" },
    { value: "brackets", label: "Brackets" },
    { value: "edit", label: "Edit" },
  ];

  useEffect(() => {
    if (!tournament) return;
    const availableTabs = new Set(tabs.map((tab) => tab.value));
    setActiveTab((current) => {
      if (current && availableTabs.has(current)) return current;
      return hasPointsTable ? "standings" : "teams";
    });
  }, [tournament, hasPointsTable, tabs]);

  if (query.isLoading) {
    return (
      <div className="p-8 text-center text-muted-foreground">
        Loading tournament...
      </div>
    );
  }

  if (!tournament) {
    return (
      <div className="p-8 text-center text-destructive">
        Tournament not found.
      </div>
    );
  }

  const currentStatus = statusVal || tournament.status;
  const registeredTeams = tournament.teams?.length ?? 0;
  const heroStats = [
    {
      label: "Registered Teams",
      value: `${registeredTeams}/${tournament.maxTeams ?? "∞"}`,
    },
    {
      label: "Format",
      value: (tournament.tournamentFormat ?? "LEAGUE").replace(/_/g, " "),
    },
    { label: "Match Type", value: tournament.format },
    {
      label: "Location",
      value: tournament.venueName
        ? `${tournament.venueName}${tournament.city ? `, ${tournament.city}` : ""}`
        : tournament.city || "Not set",
    },
  ];
  const tabContentClassName =
    "mt-0 rounded-2xl border bg-card/95 p-5 shadow-sm sm:p-6";
  const coverStyle = tournament.coverUrl
    ? {
        backgroundImage: `linear-gradient(135deg, rgba(15, 23, 42, 0.86), rgba(15, 23, 42, 0.55)), url(${tournament.coverUrl})`,
        backgroundSize: "cover",
        backgroundPosition: "center",
      }
    : undefined;

  return (
    <div className="min-h-screen bg-[radial-gradient(circle_at_top,_rgba(59,130,246,0.08),_transparent_38%),linear-gradient(180deg,_rgba(15,23,42,0.02),_transparent_26%)]">
      <div className="mx-auto flex w-full max-w-7xl flex-col gap-6 px-4 py-6 sm:px-6 lg:px-8">
        <Card className="overflow-hidden border-border/70 shadow-sm">
          <div
            className="relative border-b bg-slate-950 text-white"
            style={coverStyle}
          >
            <div className="absolute inset-0 bg-[linear-gradient(135deg,rgba(15,23,42,0.88),rgba(15,23,42,0.58),rgba(37,99,235,0.42))]" />
            <div className="relative px-5 py-5 sm:px-7 sm:py-7">
              <div className="flex flex-wrap items-center justify-between gap-3">
                <Button
                  variant="ghost"
                  className="h-9 px-3 text-white/80 hover:bg-white/10 hover:text-white"
                  onClick={() => router.push("/admin/tournaments")}
                >
                  ← Back to tournaments
                </Button>
                <div className="flex items-center gap-2">
                  <Badge
                    variant="outline"
                    className="border-white/20 bg-white/10 text-white"
                  >
                    {(tournament.tournamentFormat ?? "LEAGUE").replace(
                      /_/g,
                      " ",
                    )}
                  </Badge>
                  <Badge
                    variant="outline"
                    className="border-white/20 bg-white/10 text-white"
                  >
                    {tournament.format}
                  </Badge>
                  <div className="rounded-full border border-white/15 bg-white/10 px-2.5 py-1">
                    {statusBadge(tournament.status)}
                  </div>
                </div>
              </div>

              <div className="mt-6 flex flex-col gap-6 xl:flex-row xl:items-end xl:justify-between">
                <div className="flex min-w-0 flex-1 items-start gap-4 sm:gap-5">
                  <div className="flex h-16 w-16 shrink-0 items-center justify-center overflow-hidden rounded-2xl border border-white/15 bg-white/10 text-lg font-semibold text-white shadow-lg sm:h-20 sm:w-20 sm:text-2xl">
                    {tournament.logoUrl ? (
                      // eslint-disable-next-line @next/next/no-img-element
                      <img
                        src={tournament.logoUrl}
                        alt={tournament.name}
                        className="h-full w-full object-cover"
                      />
                    ) : (
                      getInitials(tournament.name)
                    )}
                  </div>

                  <div className="min-w-0 space-y-3">
                    <div>
                      <div className="text-xs font-medium uppercase tracking-[0.24em] text-white/55">
                        Tournament Control Room
                      </div>
                      <h1 className="mt-2 text-2xl font-semibold tracking-tight text-white sm:text-3xl">
                        {tournament.name}
                      </h1>
                    </div>

                    <div className="flex flex-wrap items-center gap-x-4 gap-y-2 text-sm text-white/75">
                      {tournament.city && <span>{tournament.city}</span>}
                      {tournament.startDate && (
                        <span>
                          {formatDate(tournament.startDate)}
                          {tournament.endDate
                            ? ` → ${formatDate(tournament.endDate)}`
                            : ""}
                        </span>
                      )}
                      {tournament.academy?.name && (
                        <span>{tournament.academy.name}</span>
                      )}
                      <span>
                        {tournament.isVerified
                          ? "Verified tournament"
                          : "Pending verification"}
                      </span>
                    </div>

                    <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
                      {heroStats.map((item) => (
                        <div
                          key={item.label}
                          className="rounded-2xl border border-white/10 bg-white/10 px-4 py-3 backdrop-blur"
                        >
                          <div className="text-[11px] font-medium uppercase tracking-[0.18em] text-white/45">
                            {item.label}
                          </div>
                          <div className="mt-1 text-sm font-semibold text-white">
                            {item.value}
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>

                <div className="w-full max-w-sm rounded-2xl border border-white/10 bg-white/10 p-4 backdrop-blur">
                  <div className="text-xs font-medium uppercase tracking-[0.18em] text-white/45">
                    Quick Actions
                  </div>
                  <div className="mt-3 space-y-3">
                    <div className="space-y-1.5">
                      <label className="text-xs font-medium text-white/75">
                        Tournament status
                      </label>
                      <Select
                        value={currentStatus}
                        onValueChange={setStatusVal}
                      >
                        <SelectTrigger className="border-white/10 bg-white/10 text-white">
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          {STATUSES.map((status) => (
                            <SelectItem key={status} value={status}>
                              {status}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>

                    <div className="flex flex-wrap gap-2">
                      {statusVal && statusVal !== tournament.status && (
                        <Button
                          size="sm"
                          disabled={updateMutation.isPending}
                          onClick={() =>
                            updateMutation.mutate(
                              {
                                id: tournament.id,
                                data: { status: statusVal },
                              },
                              { onSuccess: () => setStatusVal("") },
                            )
                          }
                        >
                          {updateMutation.isPending
                            ? "Saving..."
                            : "Save Status"}
                        </Button>
                      )}

                      {!confirmDelete ? (
                        <Button
                          size="sm"
                          variant="destructive"
                          onClick={() => setConfirmDelete(true)}
                        >
                          Delete Tournament
                        </Button>
                      ) : (
                        <div className="flex flex-wrap items-center gap-2">
                          <span className="text-xs font-medium text-rose-200">
                            Delete permanently?
                          </span>
                          <Button
                            size="sm"
                            variant="destructive"
                            disabled={deleteMutation.isPending}
                            onClick={() =>
                              deleteMutation.mutate(tournament.id, {
                                onSuccess: () =>
                                  router.push("/admin/tournaments"),
                              })
                            }
                          >
                            {deleteMutation.isPending
                              ? "Deleting..."
                              : "Confirm"}
                          </Button>
                          <Button
                            size="sm"
                            variant="secondary"
                            onClick={() => setConfirmDelete(false)}
                          >
                            Cancel
                          </Button>
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <CardContent className="p-5 sm:p-6">
            <Tabs
              value={activeTab}
              onValueChange={setActiveTab}
              className="space-y-5"
            >
              <TabsList className="flex h-auto w-full flex-wrap gap-2 rounded-2xl bg-muted/60 p-2">
                {tabs.map((tab) => (
                  <TabsTrigger
                    key={tab.value}
                    value={tab.value}
                    className="rounded-xl px-4 py-2.5 data-[state=active]:shadow-sm"
                  >
                    {tab.label}
                  </TabsTrigger>
                ))}
              </TabsList>

              <TabsContent value="teams" className={tabContentClassName}>
                <TeamsTab tournament={tournament} />
              </TabsContent>

              {hasGroups && (
                <TabsContent value="groups" className={tabContentClassName}>
                  <GroupsTab tournament={tournament} />
                </TabsContent>
              )}

              {hasPointsTable && (
                <TabsContent value="standings" className={tabContentClassName}>
                  <StandingsTab tournament={tournament} />
                </TabsContent>
              )}

              <TabsContent value="schedule" className={tabContentClassName}>
                <ScheduleTab tournament={tournament} />
              </TabsContent>

              <TabsContent value="brackets" className={tabContentClassName}>
                <BracketsTab tournament={tournament} />
              </TabsContent>

              <TabsContent value="edit" className={tabContentClassName}>
                <EditTab tournament={tournament} />
              </TabsContent>
            </Tabs>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
