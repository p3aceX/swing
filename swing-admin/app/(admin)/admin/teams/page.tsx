"use client";

import { useState } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import { LayoutList, Table2, Plus } from "lucide-react";
import { useCreateTeamMutation, useTeamsQuery } from "@/lib/queries";
import { ImageUpload } from "@/components/ui/image-upload";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import type { CreateTeamBody, TeamRecord, TeamType } from "@/lib/api";
import { formatDate } from "@/lib/utils";
import { PageHeader } from "@/components/admin/page-header";
import { PaginationBar } from "@/components/admin/pagination-bar";

// ─── Constants ───────────────────────────────────────────────────────────────

const TEAM_TYPES: { value: TeamType; label: string }[] = [
  { value: "CLUB", label: "Club" },
  { value: "CORPORATE", label: "Corporate" },
  { value: "ACADEMY", label: "Academy" },
  { value: "SCHOOL", label: "School" },
  { value: "COLLEGE", label: "College" },
  { value: "DISTRICT", label: "District" },
  { value: "STATE", label: "State" },
  { value: "NATIONAL", label: "National" },
  { value: "FRIENDLY", label: "Friendly" },
  { value: "GULLY", label: "Gully" },
];

function initials(name: string) {
  return name
    .split(/\s+/)
    .map((w) => w[0])
    .join("")
    .toUpperCase()
    .slice(0, 2);
}
function typeLabel(t: TeamType) {
  return TEAM_TYPES.find((x) => x.value === t)?.label ?? t;
}

function Field({
  label,
  children,
}: {
  label: string;
  children: React.ReactNode;
}) {
  return (
    <div className="space-y-1.5">
      <Label className="text-xs font-medium text-muted-foreground uppercase tracking-wide">
        {label}
      </Label>
      {children}
    </div>
  );
}

function Avatar({ logoUrl, name }: { logoUrl?: string | null; name: string }) {
  return (
    <div className="w-9 h-9 rounded-lg bg-muted flex items-center justify-center font-bold text-xs text-muted-foreground shrink-0 overflow-hidden border">
      {logoUrl ? (
        <img src={logoUrl} alt={name} className="w-full h-full object-cover" />
      ) : (
        initials(name)
      )}
    </div>
  );
}

// ─── Create Dialog ────────────────────────────────────────────────────────────

function CreateTeamDialog({
  open,
  onClose,
}: {
  open: boolean;
  onClose: () => void;
}) {
  const [form, setForm] = useState<Partial<CreateTeamBody>>({
    name: "",
    shortName: "",
    logoUrl: "",
    city: "",
    teamType: "FRIENDLY",
  });
  const mutation = useCreateTeamMutation();

  function reset() {
    setForm({
      name: "",
      shortName: "",
      logoUrl: "",
      city: "",
      teamType: "FRIENDLY",
    });
  }
  function handleClose() {
    reset();
    onClose();
  }
  function buildPayload(): CreateTeamBody {
    return {
      name: form.name?.trim() ?? "",
      shortName: form.shortName?.trim() || undefined,
      logoUrl: form.logoUrl?.trim() || undefined,
      city: form.city?.trim() || undefined,
      teamType: form.teamType || "FRIENDLY",
    };
  }

  return (
    <Dialog open={open} onOpenChange={(o) => !o && handleClose()}>
      <DialogContent className="max-w-md">
        <DialogHeader>
          <DialogTitle>New Team</DialogTitle>
        </DialogHeader>
        <div className="py-2 space-y-5">
          <div className="flex justify-center">
            <ImageUpload
              folder="teams"
              id="new-team"
              filename="logo"
              currentUrl={form.logoUrl}
              onUpload={(url) => setForm((f) => ({ ...f, logoUrl: url }))}
              label="Team Logo"
              shape="circle"
              size="lg"
            />
          </div>
          <Field label="Team Name *">
            <Input
              value={form.name ?? ""}
              onChange={(e) => setForm((f) => ({ ...f, name: e.target.value }))}
              placeholder="Mumbai Warriors"
              autoFocus
            />
          </Field>
          <div className="grid grid-cols-2 gap-4">
            <Field label="Short Name">
              <Input
                value={form.shortName ?? ""}
                maxLength={5}
                onChange={(e) =>
                  setForm((f) => ({ ...f, shortName: e.target.value }))
                }
                placeholder="MUW"
              />
            </Field>
            <Field label="City">
              <Input
                value={form.city ?? ""}
                onChange={(e) =>
                  setForm((f) => ({ ...f, city: e.target.value }))
                }
                placeholder="Mumbai"
              />
            </Field>
          </div>
          <Field label="Team Type">
            <Select
              value={form.teamType}
              onValueChange={(v) =>
                setForm((f) => ({ ...f, teamType: v as TeamType }))
              }
            >
              <SelectTrigger>
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {TEAM_TYPES.map((t) => (
                  <SelectItem key={t.value} value={t.value}>
                    {t.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </Field>
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={handleClose}>
            Cancel
          </Button>
          <Button
            disabled={!form.name?.trim() || mutation.isPending}
            onClick={() =>
              mutation.mutate(buildPayload(), {
                onSuccess: () => {
                  reset();
                  onClose();
                },
              })
            }
          >
            {mutation.isPending ? "Creating…" : "Create Team"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

// ─── Table Row ────────────────────────────────────────────────────────────────

function TableRow({
  team,
  onClick,
}: {
  team: TeamRecord;
  onClick: () => void;
}) {
  return (
    <tr
      onClick={onClick}
      className="border-b last:border-0 hover:bg-muted/30 cursor-pointer transition-colors group"
    >
      <td className="px-4 py-3">
        <div className="flex items-center gap-3">
          <Avatar logoUrl={team.logoUrl} name={team.name} />
          <div className="min-w-0">
            <p className="text-sm font-semibold truncate">{team.name}</p>
            {team.shortName && (
              <p className="text-xs text-muted-foreground font-mono">
                {team.shortName}
              </p>
            )}
          </div>
        </div>
      </td>
      <td className="px-4 py-3 text-sm text-muted-foreground">
        {team.city ?? "—"}
      </td>
      <td className="px-4 py-3">
        <Badge variant="outline" className="text-xs">
          {typeLabel(team.teamType)}
        </Badge>
      </td>
      <td className="px-4 py-3 text-center">
        <span className="text-sm font-semibold">{team.playerIds.length}</span>
      </td>
      <td className="px-4 py-3">
        <span
          className={`text-xs font-semibold px-2 py-0.5 rounded-full ${
            team.isActive
              ? "bg-emerald-100 text-emerald-700"
              : "bg-muted text-muted-foreground"
          }`}
        >
          {team.isActive ? "Active" : "Inactive"}
        </span>
      </td>
      <td className="px-4 py-3 text-xs text-muted-foreground">
        {formatDate(team.createdAt)}
      </td>
      <td className="px-4 py-3">
        <span className="text-xs text-primary opacity-0 group-hover:opacity-100 font-medium transition-opacity">
          Edit →
        </span>
      </td>
    </tr>
  );
}

// ─── List Row ─────────────────────────────────────────────────────────────────

function ListRow({ team, onClick }: { team: TeamRecord; onClick: () => void }) {
  return (
    <div
      onClick={onClick}
      className="flex items-center gap-4 px-4 py-3 border-b last:border-0 hover:bg-muted/30 cursor-pointer transition-colors group"
    >
      <Avatar logoUrl={team.logoUrl} name={team.name} />
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2">
          <p className="text-sm font-semibold truncate">{team.name}</p>
          {team.shortName && (
            <span className="text-xs text-muted-foreground font-mono hidden sm:inline">
              {team.shortName}
            </span>
          )}
          <span
            className={`text-[10px] font-semibold px-1.5 py-0.5 rounded-full ml-1 ${
              team.isActive
                ? "bg-emerald-100 text-emerald-700"
                : "bg-muted text-muted-foreground"
            }`}
          >
            {team.isActive ? "Active" : "Inactive"}
          </span>
        </div>
        <p className="text-xs text-muted-foreground mt-0.5">
          {typeLabel(team.teamType)}
          {team.city ? ` · ${team.city}` : ""} · {team.playerIds.length} players
        </p>
      </div>
      <span className="text-xs text-primary opacity-0 group-hover:opacity-100 font-medium transition-opacity shrink-0">
        Edit →
      </span>
    </div>
  );
}

// ─── Page ─────────────────────────────────────────────────────────────────────

type ViewMode = "table" | "list";

export default function TeamsPage() {
  const searchParams = useSearchParams();
  const router = useRouter();
  const page = Number(searchParams.get("page") ?? "1");

  const [view, setView] = useState<ViewMode>("table");
  const [search, setSearch] = useState(searchParams.get("search") ?? "");
  const [typeFilter, setTypeFilter] = useState(
    searchParams.get("teamType") ?? "",
  );
  const [createOpen, setCreateOpen] = useState(false);

  const query = useTeamsQuery({
    page,
    limit: 25,
    search: search.trim() || undefined,
  });
  const teams = (query.data?.teams ?? []).filter(
    (t) => !typeFilter || t.teamType === typeFilter,
  );

  return (
    <div className="space-y-5">
      <PageHeader
        title="Teams"
        description={`${query.data?.total ?? 0} teams total`}
        action={
          <Button onClick={() => setCreateOpen(true)}>
            <Plus className="w-4 h-4 mr-1.5" />
            New Team
          </Button>
        }
      />

      {/* toolbar */}
      <div className="flex flex-wrap items-center gap-3">
        <Input
          className="max-w-xs"
          placeholder="Search teams…"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
        />
        <Select
          value={typeFilter || "ALL"}
          onValueChange={(v) => setTypeFilter(v === "ALL" ? "" : v)}
        >
          <SelectTrigger className="w-36">
            <SelectValue placeholder="All types" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="ALL">All types</SelectItem>
            {TEAM_TYPES.map((t) => (
              <SelectItem key={t.value} value={t.value}>
                {t.label}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>

        {/* view toggle */}
        <div className="ml-auto flex items-center rounded-lg border overflow-hidden">
          <button
            onClick={() => setView("table")}
            className={`flex items-center gap-1.5 px-3 py-2 text-xs font-medium transition-colors ${view === "table" ? "bg-primary text-primary-foreground" : "hover:bg-muted text-muted-foreground"}`}
          >
            <Table2 className="w-3.5 h-3.5" /> Table
          </button>
          <button
            onClick={() => setView("list")}
            className={`flex items-center gap-1.5 px-3 py-2 text-xs font-medium transition-colors ${view === "list" ? "bg-primary text-primary-foreground" : "hover:bg-muted text-muted-foreground"}`}
          >
            <LayoutList className="w-3.5 h-3.5" /> List
          </button>
        </div>
      </div>

      {/* content */}
      {query.isLoading ? (
        <div className="rounded-xl border divide-y">
          {Array.from({ length: 6 }).map((_, i) => (
            <div key={i} className="flex items-center gap-3 px-4 py-3">
              <div className="w-9 h-9 rounded-lg bg-muted animate-pulse shrink-0" />
              <div className="flex-1 space-y-1.5">
                <div className="h-3 bg-muted rounded animate-pulse w-40" />
                <div className="h-2.5 bg-muted/60 rounded animate-pulse w-24" />
              </div>
            </div>
          ))}
        </div>
      ) : teams.length === 0 ? (
        <div className="rounded-xl border border-dashed py-20 text-center">
          <p className="text-sm text-muted-foreground">No teams found.</p>
          <Button
            variant="outline"
            className="mt-4"
            onClick={() => setCreateOpen(true)}
          >
            Create your first team
          </Button>
        </div>
      ) : view === "table" ? (
        <div className="rounded-xl border overflow-x-auto">
          <table className="w-full min-w-[600px]">
            <thead>
              <tr className="bg-muted/40 border-b">
                {[
                  "Team",
                  "City",
                  "Type",
                  "Players",
                  "Status",
                  "Created",
                  "",
                ].map((h) => (
                  <th
                    key={h}
                    className="px-4 py-2.5 text-left text-[10px] font-bold uppercase tracking-wider text-muted-foreground"
                  >
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {teams.map((t) => (
                <TableRow
                  key={t.id}
                  team={t}
                  onClick={() => router.push(`/admin/teams/${t.id}`)}
                />
              ))}
            </tbody>
          </table>
        </div>
      ) : (
        <div className="rounded-xl border overflow-hidden">
          {teams.map((t) => (
            <ListRow
              key={t.id}
              team={t}
              onClick={() => router.push(`/admin/teams/${t.id}`)}
            />
          ))}
        </div>
      )}

      <PaginationBar page={page} limit={25} total={query.data?.total ?? 0} />

      <CreateTeamDialog
        open={createOpen}
        onClose={() => setCreateOpen(false)}
      />
    </div>
  );
}
