"use client";

import { useMemo, useState } from "react";
import Link from "next/link";
import { useSearchParams } from "next/navigation";
import type { ColumnDef } from "@tanstack/react-table";
import { DataTable } from "@/components/admin/data-table";
import { PaginationBar } from "@/components/admin/pagination-bar";
import { PageHeader } from "@/components/admin/page-header";
import { FilterBar } from "@/components/admin/filter-bar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Switch } from "@/components/ui/switch";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  useTournamentsQuery,
  useCreateTournamentMutation,
  useUpdateTournamentMutation,
  useArenasQuery,
} from "@/lib/queries";
import type { ArenaRecord } from "@/lib/api";
import { formatDate } from "@/lib/utils";
import type { TournamentRecord, CreateTournamentBody } from "@/lib/api";

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
const STATUSES = ["UPCOMING", "ONGOING", "COMPLETED"] as const;

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

// ── Format Guide Diagrams ─────────────────────────────────────────────
const FORMAT_GUIDE = [
  {
    value: "LEAGUE",
    label: "League / Round Robin",
    color: "blue",
    tagline: "Everyone plays everyone",
    description:
      "Every team plays against every other team. Final standings are determined by points. Best for fair, comprehensive competition.",
    when: "4–12 teams · Weeks to months",
    visual: () => (
      <div className="space-y-1">
        <div className="grid grid-cols-5 gap-px text-center text-[10px]">
          <div />
          {["A", "B", "C", "D"].map((t) => (
            <div key={t} className="font-bold py-1">
              {t}
            </div>
          ))}
          {["A", "B", "C", "D"].map((t, i) => (
            <>
              <div key={`r${t}`} className="font-bold py-1 flex items-center">
                {t}
              </div>
              {["A", "B", "C", "D"].map((opp, j) => (
                <div
                  key={opp}
                  className={`py-1 rounded text-[10px] ${i === j ? "bg-muted text-muted-foreground" : "bg-primary/10 text-primary font-medium"}`}
                >
                  {i === j ? "—" : "vs"}
                </div>
              ))}
            </>
          ))}
        </div>
        <div className="text-center text-[10px] text-muted-foreground mt-1">
          Points table decides winner
        </div>
      </div>
    ),
  },
  {
    value: "SERIES",
    label: "Series",
    color: "indigo",
    tagline: "Bilateral, tri-series, and quad-series",
    description:
      "Use this for 2-team multi-match series, tri-series with 3 teams, or quad-series with 4 teams. Bilateral series generate repeated fixtures between the same two teams.",
    when: "2–4 teams · Short tours and featured series",
    visual: () => (
      <div className="space-y-2 text-[10px]">
        <div className="grid grid-cols-3 gap-2">
          <div className="rounded border p-2 text-center">
            <div className="font-semibold">Bilateral</div>
            <div className="mt-1 text-muted-foreground">A vs B</div>
            <div className="mt-1 rounded bg-primary/10 px-1 py-0.5 text-primary">
              3 or 5 matches
            </div>
          </div>
          <div className="rounded border p-2 text-center">
            <div className="font-semibold">Tri-Series</div>
            <div className="mt-1 text-muted-foreground">A, B, C</div>
            <div className="mt-1 rounded bg-primary/10 px-1 py-0.5 text-primary">
              Round robin
            </div>
          </div>
          <div className="rounded border p-2 text-center">
            <div className="font-semibold">Quad-Series</div>
            <div className="mt-1 text-muted-foreground">A, B, C, D</div>
            <div className="mt-1 rounded bg-primary/10 px-1 py-0.5 text-primary">
              Mini league
            </div>
          </div>
        </div>
        <div className="text-center text-[10px] text-muted-foreground">
          Best for tours, featured rivalries, and compact multi-team series
        </div>
      </div>
    ),
  },
  {
    value: "KNOCKOUT",
    label: "Knockout / Elimination",
    color: "red",
    tagline: "Lose once, you're out",
    description:
      "Single elimination bracket. Teams are seeded and paired. Lose one match and you're eliminated. Tension in every game.",
    when: "8–16 teams · Fast format",
    visual: () => (
      <div className="overflow-x-auto">
        <div className="flex items-center gap-1 text-[10px] min-w-[280px]">
          <div className="space-y-1 w-16 shrink-0">
            <div className="text-center text-muted-foreground mb-1 font-medium">
              QF
            </div>
            {[
              ["A", "B"],
              ["C", "D"],
              ["E", "F"],
              ["G", "H"],
            ].map(([a, b], i) => (
              <div key={i} className="space-y-px mb-2">
                <div className="bg-background border rounded px-1.5 py-0.5">
                  Tm {a}
                </div>
                <div className="bg-background border rounded px-1.5 py-0.5">
                  Tm {b}
                </div>
              </div>
            ))}
          </div>
          <div className="text-muted-foreground text-lg">›</div>
          <div className="space-y-1 w-16 shrink-0">
            <div className="text-center text-muted-foreground mb-1 font-medium">
              SF
            </div>
            {[
              ["W1", "W2"],
              ["W3", "W4"],
            ].map(([a, b], i) => (
              <div key={i} className="space-y-px mb-6">
                <div className="bg-amber-50 dark:bg-amber-950/30 border border-amber-200 dark:border-amber-800 rounded px-1.5 py-0.5">
                  {a}
                </div>
                <div className="bg-amber-50 dark:bg-amber-950/30 border border-amber-200 dark:border-amber-800 rounded px-1.5 py-0.5">
                  {b}
                </div>
              </div>
            ))}
          </div>
          <div className="text-muted-foreground text-lg">›</div>
          <div className="space-y-1 w-16 shrink-0">
            <div className="text-center text-muted-foreground mb-1 font-medium">
              Final
            </div>
            <div className="space-y-px mt-4">
              <div className="bg-orange-50 dark:bg-orange-950/30 border border-orange-300 dark:border-orange-700 rounded px-1.5 py-0.5">
                W5
              </div>
              <div className="bg-orange-50 dark:bg-orange-950/30 border border-orange-300 dark:border-orange-700 rounded px-1.5 py-0.5">
                W6
              </div>
            </div>
          </div>
          <div className="text-muted-foreground text-lg">›</div>
          <div className="text-center">
            <div className="text-muted-foreground mb-1 font-medium text-[10px]">
              Winner
            </div>
            <div className="bg-primary text-primary-foreground rounded px-2 py-1.5 font-bold text-sm mt-3">
              🏆
            </div>
          </div>
        </div>
      </div>
    ),
  },
  {
    value: "GROUP_STAGE_KNOCKOUT",
    label: "Group Stage + Knockout",
    color: "green",
    tagline: "Groups first, then elimination",
    description:
      "Teams split into groups. Each group plays round-robin. Top teams from each group advance to knockout rounds.",
    when: "8–16 teams · Balanced format",
    visual: () => (
      <div className="space-y-2 text-[10px]">
        <div className="grid grid-cols-2 gap-2">
          {["Group A", "Group B"].map((g) => (
            <div key={g} className="border rounded p-1.5">
              <div className="font-semibold mb-1 text-center">{g}</div>
              {["Team 1", "Team 2", "Team 3", "Team 4"].map((t) => (
                <div
                  key={t}
                  className="bg-muted/50 rounded px-1 py-0.5 mb-0.5 text-center"
                >
                  {t}
                </div>
              ))}
              <div className="text-primary font-medium text-center mt-1">
                Top 2 advance ↓
              </div>
            </div>
          ))}
        </div>
        <div className="flex items-center justify-center gap-2">
          <div className="border rounded p-1.5 text-center w-20">
            <div className="font-semibold">Semi Final</div>
            <div className="text-muted-foreground text-[9px]">
              A1 vs B2, B1 vs A2
            </div>
          </div>
          <span className="text-muted-foreground">›</span>
          <div className="border rounded p-1.5 text-center w-16 bg-primary/10">
            <div className="font-semibold">Final</div>
            <div className="text-lg">🏆</div>
          </div>
        </div>
      </div>
    ),
  },
  {
    value: "SUPER_LEAGUE",
    label: "Super League",
    color: "purple",
    tagline: "Groups + Finals round",
    description:
      "Similar to Group Stage + Knockout but with a dedicated finals round for top qualifiers from all groups. Used by major leagues.",
    when: "12–16 teams · Premier format",
    visual: () => (
      <div className="space-y-2 text-[10px]">
        <div className="grid grid-cols-4 gap-1">
          {["A", "B", "C", "D"].map((g) => (
            <div key={g} className="border rounded p-1 text-center">
              <div className="font-semibold mb-0.5">Grp {g}</div>
              {["1", "2", "3"].map((n) => (
                <div
                  key={n}
                  className="bg-muted/50 rounded mb-0.5 py-0.5 text-[9px]"
                >
                  Tm {g}
                  {n}
                </div>
              ))}
              <div className="text-primary text-[9px] mt-0.5">Top 1 ↓</div>
            </div>
          ))}
        </div>
        <div className="flex items-center justify-center gap-1">
          <div className="border rounded p-1 text-center w-20">
            <div className="font-semibold">Finals Group</div>
            <div className="text-muted-foreground text-[9px]">
              A1, B1, C1, D1
            </div>
          </div>
          <span>›</span>
          <div className="border rounded p-1 text-center w-12 bg-primary/10">
            <div className="font-semibold">Final</div>
            <div>🏆</div>
          </div>
        </div>
      </div>
    ),
  },
  {
    value: "DOUBLE_ELIMINATION",
    label: "Double Elimination",
    color: "orange",
    tagline: "Two lives — lose twice to exit",
    description:
      "Teams have two lives. After losing once they drop to the Losers Bracket for a second chance. Only eliminated after two losses.",
    when: "8–16 teams · Long format",
    visual: () => (
      <div className="space-y-2 text-[10px]">
        <div className="border border-green-300 dark:border-green-700 rounded p-2 bg-green-50/50 dark:bg-green-950/20">
          <div className="font-semibold text-green-700 dark:text-green-400 mb-1">
            Winners Bracket (0 losses)
          </div>
          <div className="flex gap-1">
            {["A", "B", "C", "D"].map((t) => (
              <div
                key={t}
                className="bg-background border rounded px-1.5 py-0.5"
              >
                Tm {t}
              </div>
            ))}
          </div>
          <div className="text-muted-foreground mt-1 text-[9px]">
            Losers drop to Losers Bracket ↓
          </div>
        </div>
        <div className="border border-orange-300 dark:border-orange-700 rounded p-2 bg-orange-50/50 dark:bg-orange-950/20">
          <div className="font-semibold text-orange-700 dark:text-orange-400 mb-1">
            Losers Bracket (1 loss)
          </div>
          <div className="flex gap-1">
            {["W-L", "X-L", "Y-L", "Z-L"].map((t) => (
              <div
                key={t}
                className="bg-background border rounded px-1.5 py-0.5"
              >
                {t}
              </div>
            ))}
          </div>
          <div className="text-muted-foreground mt-1 text-[9px]">
            2nd loss = eliminated
          </div>
        </div>
        <div className="text-center border rounded p-1 bg-primary/10">
          <span className="font-semibold">Grand Final</span>
          <span className="text-muted-foreground ml-1">
            WB Winner vs LB Winner
          </span>
        </div>
      </div>
    ),
  },
] as const;

function statusBadge(status: string) {
  const v =
    status === "ONGOING"
      ? "success"
      : status === "COMPLETED"
        ? "secondary"
        : "outline";
  return <Badge variant={v as any}>{status}</Badge>;
}

// ── Create Tournament Dialog ───────────────────────────────────────────
function CreateTournamentDialog() {
  const [open, setOpen] = useState(false);
  const [tab, setTab] = useState("basics");
  const [form, setForm] = useState<Partial<CreateTournamentBody>>({
    name: "",
    format: "T20",
    tournamentFormat: "LEAGUE",
    isPublic: true,
    maxTeams: 8,
    groupCount: 2,
    pointsForWin: 2,
    pointsForLoss: 0,
    pointsForTie: 1,
    pointsForNoResult: 1,
  });
  const [venueMode, setVenueMode] = useState<"existing" | "manual">("existing");
  const [arenaSearch, setArenaSearch] = useState("");
  const [selectedArena, setSelectedArena] = useState<ArenaRecord | null>(null);
  const arenasQuery = useArenasQuery({
    page: 1,
    limit: 50,
    search: arenaSearch || undefined,
  });
  const arenas = (arenasQuery.data as any)?.arenas ?? [];
  const mutation = useCreateTournamentMutation();

  const isLeague = LEAGUE_FORMATS.includes(form.tournamentFormat ?? "LEAGUE");
  const hasGroups = GROUP_FORMATS.includes(form.tournamentFormat ?? "");
  const isSeries = form.tournamentFormat === "SERIES";
  const hasPointsTable = POINTS_TABLE_FORMATS.includes(
    form.tournamentFormat ?? "LEAGUE",
  );

  function f(key: keyof CreateTournamentBody, value: unknown) {
    setForm((prev: Partial<CreateTournamentBody>) => ({ ...prev, [key]: value }));
  }

  function applyTournamentFormat(
    value: NonNullable<CreateTournamentBody["tournamentFormat"]>,
  ) {
    setForm((prev: Partial<CreateTournamentBody>) => ({
      ...prev,
      tournamentFormat: value,
      groupCount: value === "SERIES" ? 1 : prev.groupCount,
      maxTeams:
        value === "SERIES"
          ? prev.maxTeams && prev.maxTeams <= 4
            ? prev.maxTeams
            : 2
          : prev.maxTeams,
      seriesMatchCount:
        value === "SERIES"
          ? (prev.seriesMatchCount ?? ((prev.maxTeams ?? 2) === 2 ? 3 : 1))
          : undefined,
    }));
  }

  function applySeriesPreset(preset: (typeof SERIES_PRESETS)[number]) {
    setForm((prev: Partial<CreateTournamentBody>) => ({
      ...prev,
      tournamentFormat: "SERIES",
      maxTeams: preset.maxTeams,
      groupCount: 1,
      seriesMatchCount: preset.seriesMatchCount,
    }));
  }

  return (
    <Dialog
      open={open}
      onOpenChange={(v) => {
        setOpen(v);
        if (!v) {
          setTab("basics");
          setVenueMode("existing");
          setSelectedArena(null);
          setArenaSearch("");
        }
      }}
    >
      <DialogTrigger asChild>
        <Button>Create Tournament</Button>
      </DialogTrigger>
      <DialogContent className="max-w-2xl">
        <DialogHeader>
          <DialogTitle>Create Tournament</DialogTitle>
          <DialogDescription>
            Configure the tournament format, rules, venue, and schedule basics.
          </DialogDescription>
        </DialogHeader>

        <Tabs value={tab} onValueChange={setTab} className="mt-1">
          <TabsList className="grid w-full grid-cols-4">
            <TabsTrigger value="basics">Basics</TabsTrigger>
            <TabsTrigger value="guide">Format Guide</TabsTrigger>
            <TabsTrigger value="format">Format &amp; Rules</TabsTrigger>
            <TabsTrigger value="logistics">Logistics</TabsTrigger>
          </TabsList>

          {/* ── Tab: Format Guide ── */}
          <TabsContent value="guide" className="pt-4">
            <p className="text-xs text-muted-foreground mb-3">
              Choose the right format for your tournament. Click a card to
              select it.
            </p>
            <div className="space-y-3 max-h-[380px] overflow-y-auto pr-1">
              {FORMAT_GUIDE.map((fmt) => {
                const selected = form.tournamentFormat === fmt.value;
                return (
                  <div
                    key={fmt.value}
                    onClick={() => applyTournamentFormat(fmt.value)}
                    className={`rounded-lg border p-3 cursor-pointer transition-colors ${selected ? "border-primary bg-primary/5 ring-1 ring-primary" : "hover:border-primary/50 hover:bg-muted/30"}`}
                  >
                    <div className="flex items-start justify-between gap-2 mb-2">
                      <div>
                        <div className="flex items-center gap-2">
                          <span className="font-semibold text-sm">
                            {fmt.label}
                          </span>
                          {selected && (
                            <Badge variant="default" className="text-xs">
                              Selected
                            </Badge>
                          )}
                        </div>
                        <div className="text-xs text-muted-foreground mt-0.5">
                          {fmt.tagline} · {fmt.when}
                        </div>
                      </div>
                    </div>
                    <p className="text-xs text-muted-foreground mb-2">
                      {fmt.description}
                    </p>
                    <div className="rounded-md bg-muted/20 p-2">
                      <fmt.visual />
                    </div>
                  </div>
                );
              })}
            </div>
          </TabsContent>

          {/* ── Tab 1: Basics ── */}
          <TabsContent value="basics" className="space-y-4 pt-4">
            <div className="space-y-1">
              <label className="text-sm font-medium">Tournament Name *</label>
              <Input
                value={form.name ?? ""}
                onChange={(e) => f("name", e.target.value)}
                placeholder="Cricket Premier League 2026"
              />
            </div>
            <div className="space-y-1">
              <label className="text-sm font-medium">Description</label>
              <Input
                value={form.description ?? ""}
                onChange={(e) => f("description", e.target.value)}
                placeholder="Annual city championship"
              />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-1">
                <label className="text-sm font-medium">Start Date *</label>
                <Input
                  type="datetime-local"
                  onChange={(e) =>
                    f("startDate", new Date(e.target.value).toISOString())
                  }
                />
              </div>
              <div className="space-y-1">
                <label className="text-sm font-medium">End Date</label>
                <Input
                  type="datetime-local"
                  onChange={(e) =>
                    f("endDate", new Date(e.target.value).toISOString())
                  }
                />
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-1">
                <label className="text-sm font-medium">Max Teams</label>
                <Input
                  type="number"
                  min={2}
                  value={form.maxTeams ?? 8}
                  onChange={(e) => f("maxTeams", Number(e.target.value))}
                />
              </div>
              <div className="flex items-center justify-between rounded-lg border p-3">
                <label className="text-sm font-medium">Public</label>
                <Switch
                  checked={form.isPublic !== false}
                  onCheckedChange={(v) => f("isPublic", v)}
                />
              </div>
            </div>
          </TabsContent>

          {/* ── Tab 2: Format & Rules ── */}
          <TabsContent value="format" className="space-y-4 pt-4">
            <div className="space-y-1">
              <label className="text-sm font-medium">Tournament Format *</label>
              <Select
                value={form.tournamentFormat}
                onValueChange={applyTournamentFormat}
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
              <p className="text-xs text-muted-foreground">
                {form.tournamentFormat === "LEAGUE" &&
                  "Every team plays every other team. Final standings by points."}
                {form.tournamentFormat === "SERIES" &&
                  "Supports bilateral 2/3/5-match series, tri-series, and quad-series."}
                {form.tournamentFormat === "KNOCKOUT" &&
                  "Single elimination. Lose once and you're out."}
                {form.tournamentFormat === "GROUP_STAGE_KNOCKOUT" &&
                  "Group stage then knockout rounds. Top teams advance."}
                {form.tournamentFormat === "SUPER_LEAGUE" &&
                  "Groups + finals round for top qualifiers."}
                {form.tournamentFormat === "DOUBLE_ELIMINATION" &&
                  "Two lives — teams eliminated only after two losses."}
              </p>
            </div>
            {isSeries && (
              <div className="rounded-lg border p-4 space-y-3">
                <div className="text-sm font-semibold">Series Setup</div>
                <div className="flex flex-wrap gap-2">
                  {SERIES_PRESETS.map((preset) => (
                    <Button
                      key={preset.label}
                      type="button"
                      size="sm"
                      variant={
                        form.maxTeams === preset.maxTeams &&
                        (form.seriesMatchCount ??
                          (preset.maxTeams === 2 ? 3 : 1)) ===
                          preset.seriesMatchCount
                          ? "default"
                          : "outline"
                      }
                      onClick={() => applySeriesPreset(preset)}
                    >
                      {preset.label}
                    </Button>
                  ))}
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-1">
                    <label className="text-sm font-medium">
                      Teams in Series
                    </label>
                    <Input
                      type="number"
                      min={2}
                      max={4}
                      value={form.maxTeams ?? 2}
                      onChange={(e) => f("maxTeams", Number(e.target.value))}
                    />
                  </div>
                  <div className="space-y-1">
                    <label className="text-sm font-medium">
                      {(form.maxTeams ?? 2) === 2
                        ? "Matches in Series"
                        : "Meetings Per Pair"}
                    </label>
                    <Input
                      type="number"
                      min={1}
                      max={15}
                      value={
                        form.seriesMatchCount ??
                        ((form.maxTeams ?? 2) === 2 ? 3 : 1)
                      }
                      onChange={(e) =>
                        f("seriesMatchCount", Number(e.target.value))
                      }
                    />
                  </div>
                </div>
                <p className="text-xs text-muted-foreground">
                  For 2 teams, Swing creates repeated fixtures between the same
                  teams. For 3 or 4 teams, each pair plays the chosen number of
                  times.
                </p>
              </div>
            )}
            <div className="space-y-1">
              <label className="text-sm font-medium">Match Format *</label>
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
            {hasGroups && (
              <div className="space-y-1">
                <label className="text-sm font-medium">Number of Groups</label>
                <Input
                  type="number"
                  min={2}
                  max={8}
                  value={form.groupCount ?? 2}
                  onChange={(e) => f("groupCount", Number(e.target.value))}
                />
              </div>
            )}
            {hasPointsTable && (
              <div className="rounded-lg border p-4 space-y-3">
                <div className="text-sm font-semibold">Points System</div>
                <div className="grid grid-cols-2 gap-3">
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
                        value={(form as any)[key] ?? 0}
                        onChange={(e) =>
                          setForm((prev: Partial<CreateTournamentBody>) => ({
                            ...prev,
                            [key]: Number(e.target.value),
                          }))
                        }
                      />
                    </div>
                  ))}
                </div>
              </div>
            )}
            <div className="space-y-1">
              <label className="text-sm font-medium">Rules / Notes</label>
              <Input
                value={form.rules ?? ""}
                onChange={(e) => f("rules", e.target.value)}
                placeholder="DRS, powerplay rules..."
              />
            </div>
          </TabsContent>

          {/* ── Tab 3: Logistics ── */}
          <TabsContent value="logistics" className="space-y-4 pt-4">
            {/* Venue / Arena picker */}
            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <label className="text-sm font-medium">Venue / Arena</label>
                <div className="flex rounded-md border text-xs overflow-hidden">
                  <button
                    type="button"
                    onClick={() => {
                      setVenueMode("existing");
                      setSelectedArena(null);
                      f("venueName", "");
                      f("city", "");
                    }}
                    className={`px-3 py-1.5 transition-colors ${venueMode === "existing" ? "bg-primary text-primary-foreground" : "bg-background text-muted-foreground hover:text-foreground"}`}
                  >
                    Existing Arena
                  </button>
                  <button
                    type="button"
                    onClick={() => {
                      setVenueMode("manual");
                      setSelectedArena(null);
                    }}
                    className={`px-3 py-1.5 transition-colors ${venueMode === "manual" ? "bg-primary text-primary-foreground" : "bg-background text-muted-foreground hover:text-foreground"}`}
                  >
                    Manual Entry
                  </button>
                </div>
              </div>

              {venueMode === "existing" && (
                <div className="space-y-2">
                  <Input
                    placeholder="Search arenas by name or city..."
                    value={arenaSearch}
                    onChange={(e) => setArenaSearch(e.target.value)}
                  />
                  {selectedArena ? (
                    <div className="flex items-center justify-between rounded-lg border border-primary bg-primary/5 px-3 py-2.5">
                      <div>
                        <div className="text-sm font-semibold">
                          {selectedArena.name}
                        </div>
                        <div className="text-xs text-muted-foreground">
                          {selectedArena.city}
                          {selectedArena.state
                            ? `, ${selectedArena.state}`
                            : ""}
                          {selectedArena.arenaGrade
                            ? ` · ${selectedArena.arenaGrade}`
                            : ""}
                        </div>
                      </div>
                      <button
                        type="button"
                        onClick={() => {
                          setSelectedArena(null);
                          f("venueName", "");
                          f("city", "");
                        }}
                        className="text-xs text-muted-foreground hover:text-destructive ml-3"
                      >
                        ✕ Clear
                      </button>
                    </div>
                  ) : (
                    <div className="rounded-lg border max-h-48 overflow-y-auto divide-y">
                      {arenasQuery.isLoading && (
                        <div className="py-4 text-center text-xs text-muted-foreground">
                          Loading arenas...
                        </div>
                      )}
                      {!arenasQuery.isLoading && arenas.length === 0 && (
                        <div className="py-4 text-center text-xs text-muted-foreground">
                          No arenas found
                          {arenaSearch ? ` for "${arenaSearch}"` : ""}.
                        </div>
                      )}
                      {arenas.map((a: ArenaRecord) => (
                        <button
                          key={a.id}
                          type="button"
                          onClick={() => {
                            setSelectedArena(a);
                            f("venueName", a.name);
                            f("city", a.city);
                          }}
                          className="w-full text-left px-3 py-2.5 hover:bg-muted/50 transition-colors"
                        >
                          <div className="text-sm font-medium">{a.name}</div>
                          <div className="text-xs text-muted-foreground">
                            {a.city}
                            {a.state ? `, ${a.state}` : ""}
                            {a.arenaGrade ? ` · ${a.arenaGrade}` : ""}
                            {a.isVerified ? " · ✓ Verified" : ""}
                          </div>
                        </button>
                      ))}
                    </div>
                  )}
                </div>
              )}

              {venueMode === "manual" && (
                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-1">
                    <label className="text-xs font-medium text-muted-foreground">
                      Venue Name
                    </label>
                    <Input
                      value={form.venueName ?? ""}
                      onChange={(e) => f("venueName", e.target.value)}
                      placeholder="DY Patil Stadium"
                    />
                  </div>
                  <div className="space-y-1">
                    <label className="text-xs font-medium text-muted-foreground">
                      City
                    </label>
                    <Input
                      value={form.city ?? ""}
                      onChange={(e) => f("city", e.target.value)}
                      placeholder="Mumbai"
                    />
                  </div>
                </div>
              )}
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-1">
                <label className="text-sm font-medium">Entry Fee (₹)</label>
                <Input
                  type="number"
                  min={0}
                  value={form.entryFee ?? ""}
                  onChange={(e) => f("entryFee", Number(e.target.value))}
                  placeholder="0"
                />
              </div>
              <div className="space-y-1">
                <label className="text-sm font-medium">Prize Pool</label>
                <Input
                  value={form.prizePool ?? ""}
                  onChange={(e) => f("prizePool", e.target.value)}
                  placeholder="₹50,000"
                />
              </div>
            </div>
          </TabsContent>
        </Tabs>

        <DialogFooter className="mt-4">
          <div className="flex gap-2 justify-between w-full items-center">
            <div className="flex gap-1">
              {["basics", "guide", "format", "logistics"].map((t) => (
                <button
                  key={t}
                  onClick={() => setTab(t)}
                  className={`h-2 w-6 rounded-full transition-colors ${tab === t ? "bg-primary" : "bg-muted"}`}
                />
              ))}
            </div>
            <div className="flex gap-2">
              <Button variant="outline" onClick={() => setOpen(false)}>
                Cancel
              </Button>
              {tab !== "logistics" ? (
                <Button
                  onClick={() => {
                    const order = ["basics", "guide", "format", "logistics"];
                    const next = order[order.indexOf(tab) + 1];
                    if (next) setTab(next);
                  }}
                >
                  Next
                </Button>
              ) : (
                <Button
                  disabled={!form.name || !form.startDate || mutation.isPending}
                  onClick={() =>
                    mutation.mutate(form as CreateTournamentBody, {
                      onSuccess: () => {
                        setOpen(false);
                        setTab("basics");
                        setVenueMode("existing");
                        setSelectedArena(null);
                        setArenaSearch("");
                      },
                    })
                  }
                >
                  {mutation.isPending ? "Creating..." : "Create Tournament"}
                </Button>
              )}
            </div>
          </div>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

// ── Status Editor ─────────────────────────────────────────────────────
function StatusEditor({ tournament }: { tournament: TournamentRecord }) {
  const [val, setVal] = useState(tournament.status);
  const mutation = useUpdateTournamentMutation();
  return (
    <div className="flex gap-2 items-center">
      <Select value={val} onValueChange={setVal}>
        <SelectTrigger className="w-[130px]">
          <SelectValue />
        </SelectTrigger>
        <SelectContent>
          {STATUSES.map((s) => (
            <SelectItem key={s} value={s}>
              {s}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>
      {val !== tournament.status && (
        <Button
          size="sm"
          disabled={mutation.isPending}
          onClick={() =>
            mutation.mutate({ id: tournament.id, data: { status: val } })
          }
        >
          Save
        </Button>
      )}
    </div>
  );
}

// ── Main Page ─────────────────────────────────────────────────────────
export default function TournamentsPage() {
  const searchParams = useSearchParams();
  const page = Number(searchParams.get("page") ?? "1");
  const search = searchParams.get("search") ?? "";
  const status = searchParams.get("status") ?? "";
  const query = useTournamentsQuery({
    page,
    limit: 25,
    search: search || undefined,
    status: status || undefined,
  });

  const columns = useMemo<ColumnDef<TournamentRecord>[]>(
    () => [
      {
        header: "Tournament",
        cell: ({ row }) => (
          <div>
            <div className="font-medium">{row.original.name}</div>
            {row.original.city && (
              <div className="text-xs text-muted-foreground">
                {row.original.city}
              </div>
            )}
          </div>
        ),
      },
      {
        header: "Format",
        cell: ({ row }) => (
          <div className="space-y-1">
            <Badge variant="outline" className="text-xs">
              {(row.original.tournamentFormat ?? "LEAGUE").replace(/_/g, " ")}
            </Badge>
            <div className="text-xs text-muted-foreground">
              {row.original.format}
            </div>
          </div>
        ),
      },
      {
        header: "Starts",
        cell: ({ row }) => formatDate(row.original.startDate),
      },
      {
        header: "Teams",
        cell: ({ row }) => (
          <Badge variant="outline">
            {row.original.teams?.filter((t) => t.isConfirmed).length ?? 0} /{" "}
            {row.original.maxTeams}
          </Badge>
        ),
      },
      {
        header: "Status",
        cell: ({ row }) => <StatusEditor tournament={row.original} />,
      },
      {
        header: "Actions",
        cell: ({ row }) => (
          <Button asChild size="sm" variant="outline">
            <Link href={`/admin/tournaments/${row.original.id}`}>Manage</Link>
          </Button>
        ),
      },
    ],
    [],
  );

  return (
    <div className="space-y-6">
      <PageHeader
        title="Tournaments"
        description="Create and manage cricket tournaments with full league, knockout, and group stage support."
        action={<CreateTournamentDialog />}
      />
      <FilterBar
        searchPlaceholder="Search by tournament name"
        selects={[
          {
            key: "status",
            value: status,
            placeholder: "Filter by status",
            options: STATUSES.map((s) => ({ value: s, label: s })),
          },
        ]}
      />
      {query.isError && (
        <div className="rounded-xl border border-destructive bg-destructive/10 p-4 text-sm text-destructive">
          Failed: {(query.error as Error)?.message}
        </div>
      )}
      <div className="rounded-xl border bg-card overflow-x-auto">
        <DataTable
          columns={columns}
          data={query.isLoading ? [] : (query.data?.tournaments ?? [])}
        />
        {query.isLoading && (
          <div className="p-8 text-center text-sm text-muted-foreground">
            Loading...
          </div>
        )}
      </div>
      <PaginationBar page={page} limit={25} total={query.data?.total ?? 0} />
    </div>
  );
}
