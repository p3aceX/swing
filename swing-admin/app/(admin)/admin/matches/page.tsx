"use client";

import { useEffect, useState } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import { Copy, ExternalLink, Search } from "lucide-react";
import { toast } from "sonner";
import { PageHeader } from "@/components/admin/page-header";
import { PaginationBar } from "@/components/admin/pagination-bar";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import {
  Dialog,
  DialogContent,
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
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  useMatchesQuery,
  useCreateMatchMutation,
  useTeamsQuery,
  useDeleteMatchMutation,
  useVenuesQuery,
} from "@/lib/queries";
import { cn, formatDate } from "@/lib/utils";
import type { CreateMatchBody, TeamRecord, VenueRecord } from "@/lib/api";

const MATCH_TYPES = [
  "ACADEMY",
  "TOURNAMENT",
  "CORPORATE",
  "RANKED",
  "FRIENDLY",
] as const;
const FORMATS = [
  "T10",
  "T20",
  "ONE_DAY",
  "TWO_INNINGS",
  "BOX_CRICKET",
  "CUSTOM",
  "TEST",
] as const;
const STATUS_OPTIONS = [
  "CREATED",
  "SCHEDULED",
  "TOSS_DONE",
  "IN_PROGRESS",
  "COMPLETED",
  "ABANDONED",
] as const;
const PUBLIC_WEB_BASE_URL = (
  process.env.NEXT_PUBLIC_WEB_BASE_URL ?? "https://swingcricketapp.com"
).replace(/\/$/, "");

function initials(name: string) {
  return name
    .split(/\s+/)
    .map((w) => w[0])
    .join("")
    .toUpperCase()
    .slice(0, 2);
}

function compactTeamName(name: string) {
  const cleaned = name.replace(/\s*-\s*/g, " ").trim();
  if (cleaned.length <= 28) return cleaned;

  const words = cleaned.split(/\s+/).filter(Boolean);
  const acronym = words
    .filter((word) => !["the", "of", "and"].includes(word.toLowerCase()))
    .map((word) => word[0])
    .join("")
    .toUpperCase();

  if (acronym.length >= 2 && acronym.length <= 6) return acronym;
  return cleaned.slice(0, 28);
}

function matchTypeTone(type: string) {
  switch (type) {
    case "TOURNAMENT":
      return "border-amber-500/20 bg-amber-500/10 text-amber-700";
    case "FRIENDLY":
      return "border-sky-500/20 bg-sky-500/10 text-sky-700";
    case "RANKED":
      return "border-violet-500/20 bg-violet-500/10 text-violet-700";
    case "ACADEMY":
      return "border-emerald-500/20 bg-emerald-500/10 text-emerald-700";
    case "CORPORATE":
      return "border-slate-500/20 bg-slate-500/10 text-slate-700";
    default:
      return "";
  }
}

function statusTone(
  status: string,
): "default" | "outline" | "success" | "warning" | "destructive" {
  switch (status) {
    case "IN_PROGRESS":
      return "success";
    case "COMPLETED":
      return "default";
    case "ABANDONED":
      return "destructive";
    case "TOSS_DONE":
      return "warning";
    default:
      return "outline";
  }
}

function TeamPickerButton({
  label,
  team,
  onClear,
  onClick,
}: {
  label: string;
  team: TeamRecord | null;
  onClear: () => void;
  onClick: () => void;
}) {
  return (
    <div className="space-y-1">
      <label className="text-sm font-medium">{label} *</label>
      {team ? (
        <div className="flex items-center gap-2 rounded-lg border px-3 py-2 bg-muted/20">
          <div className="w-7 h-7 rounded-md bg-muted overflow-hidden flex items-center justify-center text-[10px] font-bold shrink-0 border">
            {team.logoUrl ? (
              <img
                src={team.logoUrl}
                alt=""
                className="w-full h-full object-cover"
              />
            ) : (
              initials(team.name)
            )}
          </div>
          <p className="text-sm font-medium flex-1 truncate">{team.name}</p>
          <button
            onClick={onClear}
            className="text-muted-foreground hover:text-foreground text-xs"
          >
            ✕
          </button>
        </div>
      ) : (
        <button
          onClick={onClick}
          className="w-full rounded-lg border px-3 py-2 text-left text-sm text-muted-foreground hover:bg-muted/20 transition-colors"
        >
          Search & pick team…
        </button>
      )}
    </div>
  );
}

function TeamSearchDropdown({
  open,
  onClose,
  onSelect,
}: {
  open: boolean;
  onClose: () => void;
  onSelect: (t: TeamRecord) => void;
}) {
  const [q, setQ] = useState("");
  const { data, isLoading } = useTeamsQuery({
    page: 1,
    limit: 20,
    search: q || undefined,
  });
  const teams = data?.teams ?? [];

  if (!open) return null;
  return (
    <Dialog open={open} onOpenChange={(o) => !o && onClose()}>
      <DialogContent className="max-w-sm">
        <DialogHeader>
          <DialogTitle>Select Team</DialogTitle>
        </DialogHeader>
        <div className="space-y-3 py-1">
          <Input
            autoFocus
            placeholder="Search by name…"
            value={q}
            onChange={(e) => setQ(e.target.value)}
          />
          <div className="max-h-64 overflow-y-auto divide-y rounded-lg border">
            {isLoading ? (
              <div className="py-8 text-center text-sm text-muted-foreground">
                Loading…
              </div>
            ) : teams.length === 0 ? (
              <div className="py-8 text-center text-sm text-muted-foreground">
                No teams found
              </div>
            ) : (
              teams.map((t) => (
                <button
                  key={t.id}
                  onClick={() => {
                    onSelect(t);
                    onClose();
                  }}
                  className="w-full flex items-center gap-3 px-4 py-2.5 hover:bg-muted/30 transition-colors text-left"
                >
                  <div className="w-8 h-8 rounded-md bg-muted overflow-hidden flex items-center justify-center text-xs font-bold shrink-0 border">
                    {t.logoUrl ? (
                      <img
                        src={t.logoUrl}
                        alt=""
                        className="w-full h-full object-cover"
                      />
                    ) : (
                      initials(t.name)
                    )}
                  </div>
                  <div className="min-w-0">
                    <p className="text-sm font-medium truncate">{t.name}</p>
                    <p className="text-xs text-muted-foreground">
                      {t.teamType}
                      {t.city ? ` · ${t.city}` : ""} · {t.playerIds.length}{" "}
                      players
                    </p>
                  </div>
                </button>
              ))
            )}
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
}

function VenueAutocomplete({
  name,
  city,
  onChangeName,
  onChangeCity,
  onPickCity,
}: {
  name: string;
  city: string;
  onChangeName: (v: string) => void;
  onChangeCity: (v: string) => void;
  onPickCity: (v: string) => void;
}) {
  const [q, setQ] = useState(name);
  const [showSuggestions, setShowSuggestions] = useState(false);
  const { data: venues } = useVenuesQuery(q);

  function pick(v: VenueRecord) {
    setQ(v.name);
    onChangeName(v.name);
    onPickCity(v.city ?? "");
    setShowSuggestions(false);
  }

  return (
    <div className="space-y-3">
      <div className="space-y-1">
        <label className="text-sm font-medium">Venue Name *</label>
        <div className="relative">
          <Input
            value={q}
            placeholder="e.g. DY Patil Stadium"
            onChange={(e) => {
              setQ(e.target.value);
              onChangeName(e.target.value);
              setShowSuggestions(true);
            }}
            onFocus={() => setShowSuggestions(true)}
            onBlur={() => setTimeout(() => setShowSuggestions(false), 150)}
          />
          {showSuggestions && venues && venues.length > 0 && (
            <div className="absolute z-50 mt-1 w-full rounded-lg border bg-popover shadow-md max-h-44 overflow-y-auto">
              {venues.map((v) => (
                <button
                  key={v.id}
                  type="button"
                  onMouseDown={() => pick(v)}
                  className="w-full px-3 py-2 text-left text-sm hover:bg-muted flex items-center gap-2"
                >
                  <span className="font-medium">{v.name}</span>
                  {v.city && (
                    <span className="text-xs text-muted-foreground">
                      · {v.city}
                    </span>
                  )}
                </button>
              ))}
            </div>
          )}
        </div>
      </div>
      <div className="space-y-1">
        <label className="text-sm font-medium">City *</label>
        <Input
          value={city}
          placeholder="e.g. Mumbai"
          onChange={(e) => onChangeCity(e.target.value)}
        />
      </div>
      <p className="text-[11px] text-muted-foreground">
        Venues are saved to DB and auto-matched next time by name.
      </p>
    </div>
  );
}

function CreateMatchDialog() {
  const [open, setOpen] = useState(false);
  const [tab, setTab] = useState("teams");
  const [teamAPicker, setTeamAPicker] = useState(false);
  const [teamBPicker, setTeamBPicker] = useState(false);
  const [teamA, setTeamA] = useState<TeamRecord | null>(null);
  const [teamB, setTeamB] = useState<TeamRecord | null>(null);
  const [matchType, setMatchType] = useState<CreateMatchBody["matchType"]>("FRIENDLY");
  const [format, setFormat] = useState<CreateMatchBody["format"]>("T20");
  const [customOvers, setCustomOvers] = useState("10");
  const [testDays, setTestDays] = useState("5");
  const [oversPerDay, setOversPerDay] = useState("90");
  const [scheduledAt, setScheduledAt] = useState("");
  const [venueName, setVenueName] = useState("");
  const [venueCity, setVenueCity] = useState("");
  const [hasImpactPlayer, setHasImpactPlayer] = useState(false);
  const createMutation = useCreateMatchMutation();

  // Impact player not allowed in Test matches
  const impactAllowed = format !== "TEST";

  function reset() {
    setTab("teams");
    setTeamA(null);
    setTeamB(null);
    setMatchType("FRIENDLY");
    setFormat("T20");
    setCustomOvers("10");
    setTestDays("5");
    setOversPerDay("90");
    setScheduledAt("");
    setVenueName("");
    setVenueCity("");
    setHasImpactPlayer(false);
  }

  function handleSubmit() {
    if (!teamA || !teamB || !scheduledAt) return;
    const body: CreateMatchBody = {
      matchType,
      format,
      teamAName: teamA.name,
      teamBName: teamB.name,
      teamAPlayerIds: teamA.playerIds,
      teamBPlayerIds: teamB.playerIds,
      teamACaptainId: teamA.captainId ?? undefined,
      teamBCaptainId: teamB.captainId ?? undefined,
      scheduledAt: new Date(scheduledAt).toISOString(),
      venueName: venueName.trim() || undefined,
      venueCity: venueCity.trim() || undefined,
      customOvers: format === "CUSTOM" ? Number(customOvers) : undefined,
      testDays: format === "TEST" ? Number(testDays) : undefined,
      oversPerDay: format === "TEST" ? Number(oversPerDay) : undefined,
      hasImpactPlayer: impactAllowed ? hasImpactPlayer : false,
    };
    createMutation.mutate(body, {
      onSuccess: () => {
        reset();
        setOpen(false);
      },
    });
  }

  const isCustom = format === "CUSTOM";
  const isTest = format === "TEST";
  const tab1Done = !!(teamA && teamB);
  const tab2Done = !!(
    scheduledAt &&
    (!isCustom || Number(customOvers) > 0) &&
    (!isTest || (Number(testDays) > 0 && Number(oversPerDay) > 0))
  );
  const tab3Done = !!(venueName.trim() && venueCity.trim());
  const canSubmit =
    tab1Done && tab2Done && tab3Done && !createMutation.isPending;

  return (
    <>
      <Dialog
        open={open}
        onOpenChange={(o) => {
          if (!o) reset();
          setOpen(o);
        }}
      >
        <DialogTrigger asChild>
          <Button>Create Match</Button>
        </DialogTrigger>
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle>Create Match</DialogTitle>
          </DialogHeader>

          <Tabs value={tab} onValueChange={setTab} className="mt-1">
            <TabsList className="grid w-full grid-cols-3">
              <TabsTrigger value="teams" className="gap-1.5">
                Teams{" "}
                {tab1Done && (
                  <span className="text-[10px] text-green-600 font-black">
                    ✓
                  </span>
                )}
              </TabsTrigger>
              <TabsTrigger value="format">
                Format{" "}
                {tab2Done && (
                  <span className="text-[10px] text-green-600 font-black">
                    ✓
                  </span>
                )}
              </TabsTrigger>
              <TabsTrigger value="venue" className="gap-1.5">
                Venue{" "}
                {tab3Done && (
                  <span className="text-[10px] text-green-600 font-black">
                    ✓
                  </span>
                )}
              </TabsTrigger>
            </TabsList>

            {/* Tab 1: Teams */}
            <TabsContent value="teams" className="space-y-4 pt-4">
              <div className="grid grid-cols-2 gap-4">
                <TeamPickerButton
                  label="Team A"
                  team={teamA}
                  onClear={() => setTeamA(null)}
                  onClick={() => setTeamAPicker(true)}
                />
                <TeamPickerButton
                  label="Team B"
                  team={teamB}
                  onClear={() => setTeamB(null)}
                  onClick={() => setTeamBPicker(true)}
                />
              </div>
              <Button
                className="w-full"
                disabled={!tab1Done}
                onClick={() => setTab("format")}
              >
                Next: Format →
              </Button>
            </TabsContent>

            {/* Tab 2: Format & Schedule */}
            <TabsContent value="format" className="space-y-4 pt-4">
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1">
                  <label className="text-sm font-medium">Match Type *</label>
                  <Select
                    value={matchType}
                    onValueChange={(value) =>
                      setMatchType(value as CreateMatchBody["matchType"])
                    }
                  >
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      {MATCH_TYPES.map((t) => (
                        <SelectItem key={t} value={t}>
                          {t}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
                <div className="space-y-1">
                  <label className="text-sm font-medium">Format *</label>
                  <Select
                    value={format}
                    onValueChange={(value) =>
                      setFormat(value as CreateMatchBody["format"])
                    }
                  >
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      {FORMATS.map((fmt) => (
                        <SelectItem key={fmt} value={fmt}>
                          {fmt.replace(/_/g, " ")}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
              </div>
              {isCustom && (
                <div className="space-y-1">
                  <label className="text-sm font-medium">
                    Overs per Innings *
                  </label>
                  <Input
                    type="number"
                    min={1}
                    max={100}
                    value={customOvers}
                    onChange={(e) => setCustomOvers(e.target.value)}
                    placeholder="e.g. 15"
                  />
                </div>
              )}
              {isTest && (
                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-1">
                    <label className="text-sm font-medium">
                      Number of Days *
                    </label>
                    <Input
                      type="number"
                      min={1}
                      max={10}
                      value={testDays}
                      onChange={(e) => setTestDays(e.target.value)}
                      placeholder="e.g. 5"
                    />
                  </div>
                  <div className="space-y-1">
                    <label className="text-sm font-medium">
                      Overs per Day *
                    </label>
                    <Input
                      type="number"
                      min={1}
                      max={200}
                      value={oversPerDay}
                      onChange={(e) => setOversPerDay(e.target.value)}
                      placeholder="e.g. 90"
                    />
                  </div>
                </div>
              )}
              <div className="space-y-1">
                <label className="text-sm font-medium">Scheduled At *</label>
                <Input
                  type="datetime-local"
                  value={scheduledAt}
                  onChange={(e) => setScheduledAt(e.target.value)}
                />
              </div>

              {/* Impact Player rule */}
              <label
                className={`flex items-start gap-3 rounded-lg border px-3 py-3 cursor-pointer transition-colors ${
                  impactAllowed
                    ? hasImpactPlayer
                      ? "border-amber-400 bg-amber-50"
                      : "hover:bg-muted/20"
                    : "opacity-40 cursor-not-allowed"
                }`}
              >
                <input
                  type="checkbox"
                  className="mt-0.5 accent-amber-500"
                  checked={hasImpactPlayer && impactAllowed}
                  disabled={!impactAllowed}
                  onChange={(e) => setHasImpactPlayer(e.target.checked)}
                />
                <div className="space-y-0.5">
                  <p className="text-sm font-medium flex items-center gap-1.5">
                    ⚡ Impact Player Rule
                  </p>
                  <p className="text-xs text-muted-foreground">
                    {impactAllowed
                      ? "Each team may substitute one player mid-match (IPL style)."
                      : "Not available for Test matches."}
                  </p>
                </div>
              </label>

              <Button
                className="w-full"
                disabled={!tab2Done}
                onClick={() => setTab("venue")}
              >
                Next: Venue →
              </Button>
            </TabsContent>

            {/* Tab 3: Venue */}
            <TabsContent value="venue" className="pt-4">
              <VenueAutocomplete
                name={venueName}
                city={venueCity}
                onChangeName={setVenueName}
                onChangeCity={setVenueCity}
                onPickCity={setVenueCity}
              />
            </TabsContent>
          </Tabs>

          <DialogFooter className="mt-2">
            <Button
              variant="outline"
              onClick={() => {
                reset();
                setOpen(false);
              }}
            >
              Cancel
            </Button>
            <Button disabled={!canSubmit} onClick={handleSubmit}>
              {createMutation.isPending ? "Creating…" : "Create Match"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <TeamSearchDropdown
        open={teamAPicker}
        onClose={() => setTeamAPicker(false)}
        onSelect={(t) => {
          setTeamA(t);
          if (t.id === teamB?.id) setTeamB(null);
        }}
      />
      <TeamSearchDropdown
        open={teamBPicker}
        onClose={() => setTeamBPicker(false)}
        onSelect={(t) => {
          setTeamB(t);
          if (t.id === teamA?.id) setTeamA(null);
        }}
      />
    </>
  );
}

function MatchRowActions({
  matchId,
  status,
}: {
  matchId: string;
  status: string;
}) {
  const router = useRouter();
  const deleteMut = useDeleteMatchMutation();
  const [open, setOpen] = useState(false);

  return (
    <div className="flex items-center gap-1.5">
      <Button
        size="sm"
        variant={status === "IN_PROGRESS" ? "default" : "outline"}
        onClick={() => router.push(`/admin/matches/${matchId}`)}
      >
        {status === "SCHEDULED" || status === "TOSS_DONE"
          ? "Setup →"
          : status === "IN_PROGRESS"
            ? "▶ Score"
            : "Open →"}
      </Button>
      <Button
        size="sm"
        variant="ghost"
        className="text-destructive hover:bg-destructive/10 hover:text-destructive px-2"
        onClick={() => setOpen(true)}
      >
        ✕
      </Button>
      <Dialog open={open} onOpenChange={(o) => !o && setOpen(false)}>
        <DialogContent className="max-w-sm">
          <DialogHeader>
            <DialogTitle>Delete Match?</DialogTitle>
          </DialogHeader>
          <p className="text-sm text-muted-foreground">
            Permanently deletes the match and all ball events. Cannot be undone.
          </p>
          <DialogFooter>
            <Button variant="outline" onClick={() => setOpen(false)}>
              Cancel
            </Button>
            <Button
              variant="destructive"
              disabled={deleteMut.isPending}
              onClick={() =>
                deleteMut.mutate(matchId, { onSuccess: () => setOpen(false) })
              }
            >
              {deleteMut.isPending ? "Deleting…" : "Delete"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}

function PublicMatchLink({ matchId }: { matchId: string }) {
  const publicMatchUrl = `${PUBLIC_WEB_BASE_URL}/m/${matchId}`;
  const publicMatchLabel = `${PUBLIC_WEB_BASE_URL.replace(/^https?:\/\//, "")}/m/${matchId.slice(0, 8)}...`;

  async function copyPublicMatchUrl() {
    try {
      await navigator.clipboard.writeText(publicMatchUrl);
      toast.success("Match link copied");
    } catch {
      toast.error("Could not copy match link");
    }
  }

  return (
    <div className="flex items-center gap-2 text-[11px] text-muted-foreground">
      <a
        href={publicMatchUrl}
        target="_blank"
        rel="noopener noreferrer"
        className="inline-flex max-w-[180px] items-center gap-1 truncate underline underline-offset-2 hover:text-foreground"
        title={publicMatchUrl}
      >
        <ExternalLink className="h-3 w-3 shrink-0" />
        <span className="truncate">{publicMatchLabel}</span>
      </a>
      <button
        type="button"
        onClick={copyPublicMatchUrl}
        className="inline-flex items-center gap-1 hover:text-foreground"
        title="Copy public link"
      >
        <Copy className="h-3 w-3" />
        Copy
      </button>
    </div>
  );
}

const PAGE_SIZE = 10;

export default function MatchesPage() {
  const searchParams = useSearchParams();
  const router = useRouter();
  const page = Number(searchParams.get("page") ?? "1");
  const status = searchParams.get("status") ?? "";
  const matchType = searchParams.get("matchType") ?? "";
  const search = searchParams.get("search") ?? "";
  const [searchInput, setSearchInput] = useState(search);

  useEffect(() => {
    setSearchInput(search);
  }, [search]);

  const query = useMatchesQuery({
    page,
    limit: PAGE_SIZE,
    status: status || undefined,
    matchType: matchType || undefined,
    search: search || undefined,
  });

  function updateFilters(next: Record<string, string | null>) {
    const params = new URLSearchParams(searchParams.toString());
    Object.entries(next).forEach(([key, value]) => {
      if (!value || value === "ALL") params.delete(key);
      else params.set(key, value);
    });
    params.set("page", "1");
    router.push(`?${params.toString()}`);
  }

  function clearFilters() {
    setSearchInput("");
    router.push("?page=1");
  }

  const matches = [...(query.data?.matches ?? [])].sort(
    (a, b) =>
      new Date(a.scheduledAt).getTime() - new Date(b.scheduledAt).getTime(),
  );
  const total = query.data?.total ?? 0;
  const hasFilters = !!(search || status || matchType);

  return (
    <div className="space-y-5">
      <PageHeader
        title="Matches"
        description={`${total} total`}
        action={<CreateMatchDialog />}
      />

      {/* Status tab strip */}
      <div className="overflow-x-auto -mx-1 px-1 pb-0.5">
        <div className="flex gap-1.5 min-w-max">
          {[
            { value: "", label: "All" },
            { value: "IN_PROGRESS", label: "● Live" },
            { value: "CREATED", label: "Created" },
            { value: "SCHEDULED", label: "Scheduled" },
            { value: "TOSS_DONE", label: "Toss Done" },
            { value: "COMPLETED", label: "Completed" },
            { value: "ABANDONED", label: "Abandoned" },
          ].map((tab) => {
            const active = status === tab.value;
            return (
              <button
                key={tab.value}
                onClick={() => updateFilters({ status: tab.value || null })}
                className={cn(
                  "h-8 rounded-full px-3.5 text-xs font-medium whitespace-nowrap transition-colors border",
                  active
                    ? tab.value === "IN_PROGRESS"
                      ? "bg-green-500 text-white border-green-500"
                      : tab.value === "COMPLETED"
                        ? "bg-foreground text-background border-foreground"
                        : tab.value === "ABANDONED"
                          ? "bg-destructive text-destructive-foreground border-destructive"
                          : "bg-primary text-primary-foreground border-primary"
                    : "bg-transparent text-muted-foreground hover:bg-muted hover:text-foreground border-border",
                )}
              >
                {tab.label}
              </button>
            );
          })}
        </div>
      </div>

      {/* Filter bar */}
      <div className="flex flex-wrap items-center gap-2">
        <div className="relative w-full min-w-0 flex-1 sm:max-w-xs">
          <Search className="absolute left-3 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
          <Input
            value={searchInput}
            className="pl-8 h-8 text-sm"
            placeholder="Search teams, venue…"
            onChange={(e) => setSearchInput(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === "Enter")
                updateFilters({ search: searchInput || null });
            }}
          />
        </div>

        <Select
          value={matchType || "ALL"}
          onValueChange={(v) => updateFilters({ matchType: v })}
        >
          <SelectTrigger className="h-8 w-full sm:w-[120px] text-sm">
            <SelectValue placeholder="Type" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="ALL">All types</SelectItem>
            {MATCH_TYPES.map((t) => (
              <SelectItem key={t} value={t}>
                {t.replace(/_/g, " ")}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>

        {hasFilters && (
          <Button
            variant="ghost"
            size="sm"
            className="h-8 px-2 text-xs text-muted-foreground"
            onClick={clearFilters}
          >
            Clear ✕
          </Button>
        )}
      </div>

      {/* Match list */}
      <div className="rounded-xl border bg-card divide-y">
        {query.isLoading ? (
          <div className="py-12 text-center text-sm text-muted-foreground">
            Loading…
          </div>
        ) : matches.length === 0 ? (
          <div className="py-12 text-center">
            <p className="text-sm font-medium">No matches found</p>
            <p className="mt-1 text-xs text-muted-foreground">
              Try adjusting your filters.
            </p>
          </div>
        ) : (
          matches.map((m) => (
            <div
              key={m.id}
              className="grid gap-3 px-3 py-3 transition-colors hover:bg-muted/20 sm:px-4 sm:py-4 md:grid-cols-[88px_minmax(260px,1.8fr)_170px_auto] md:items-center"
            >
              <div className="flex h-16 w-16 flex-col items-center justify-center rounded-xl border bg-muted/20 text-center md:h-[84px] md:w-[84px] md:rounded-2xl">
                <div className="text-[10px] font-semibold uppercase tracking-[0.22em] text-muted-foreground">
                  {formatDate(m.scheduledAt, "MMM")}
                </div>
                <div className="text-3xl font-semibold leading-none">
                  {formatDate(m.scheduledAt, "dd")}
                </div>
                <div className="mt-1 text-[11px] text-muted-foreground">
                  {formatDate(m.scheduledAt, "hh:mm a")}
                </div>
              </div>

              <button
                onClick={() => router.push(`/admin/matches/${m.id}`)}
                className="min-w-0 text-left"
              >
                <div className="space-y-2">
                  <div className="space-y-1">
                    <div className="flex items-center gap-2">
                      <span className="inline-flex min-w-[42px] items-center justify-center rounded-full border px-2 py-0.5 text-[11px] font-semibold text-muted-foreground">
                        {compactTeamName(m.teamAName)}
                      </span>
                    </div>
                    <div className="text-[10px] font-medium uppercase tracking-[0.24em] text-muted-foreground">
                      vs
                    </div>
                    <div className="flex items-center gap-2">
                      <span className="inline-flex min-w-[42px] items-center justify-center rounded-full border px-2 py-0.5 text-[11px] font-semibold text-muted-foreground">
                        {compactTeamName(m.teamBName)}
                      </span>
                    </div>
                  </div>
                  <div className="flex flex-wrap items-center gap-x-2 gap-y-1 text-xs text-muted-foreground">
                    {m.venueName ? (
                      <span>{m.venueName}</span>
                    ) : (
                      <span>Venue TBD</span>
                    )}
                    {m.round ? (
                      <>
                        <span>·</span>
                        <span>{m.round}</span>
                      </>
                    ) : null}
                  </div>
                </div>
              </button>

              <div className="space-y-2">
                <Badge
                  className={cn(
                    "border text-[10px] px-2 py-0",
                    matchTypeTone(m.matchType),
                  )}
                >
                  {m.matchType.replace(/_/g, " ")}
                </Badge>
                <div className="text-xs text-muted-foreground">
                  {m.format?.replace(/_/g, " ")}
                </div>
                <div className="text-xs text-muted-foreground">
                  {formatDate(m.scheduledAt, "yyyy")}
                </div>
              </div>

              <div className="flex flex-col items-start gap-2 md:items-end">
                <div className="flex items-center justify-between gap-3 md:justify-end">
                  <Badge
                    variant={statusTone(m.status)}
                    className="text-[10px] px-2 py-0 shrink-0"
                  >
                    {m.status === "IN_PROGRESS"
                      ? "● LIVE"
                      : m.status.replace(/_/g, " ")}
                  </Badge>
                  <MatchRowActions matchId={m.id} status={m.status} />
                </div>
                <PublicMatchLink matchId={m.id} />
              </div>
            </div>
          ))
        )}
      </div>

      <PaginationBar page={page} limit={PAGE_SIZE} total={total} />
    </div>
  );
}
