"use client";

import { useEffect, useRef, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { ArrowLeft, Plus, Trash2, Users, X } from "lucide-react";
import {
  useTeamQuery,
  useUpdateTeamMutation,
  useDeleteTeamMutation,
  useAddPlayerToTeamMutation,
  useQuickAddPlayerToTeamMutation,
  useRemovePlayerFromTeamMutation,
} from "@/lib/queries";
import { ImageUpload } from "@/components/ui/image-upload";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import {
  Dialog, DialogContent, DialogFooter, DialogHeader, DialogTitle,
} from "@/components/ui/dialog";
import {
  Select, SelectContent, SelectItem, SelectTrigger, SelectValue,
} from "@/components/ui/select";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import type { TeamType } from "@/lib/api";
import { formatDate } from "@/lib/utils";

// ─── Constants ────────────────────────────────────────────────────────────────

const TEAM_TYPES: { value: TeamType; label: string }[] = [
  { value: "CLUB",      label: "Club" },
  { value: "CORPORATE", label: "Corporate" },
  { value: "ACADEMY",   label: "Academy" },
  { value: "SCHOOL",    label: "School" },
  { value: "COLLEGE",   label: "College" },
  { value: "DISTRICT",  label: "District" },
  { value: "STATE",     label: "State" },
  { value: "NATIONAL",  label: "National" },
  { value: "FRIENDLY",  label: "Friendly" },
  { value: "GULLY",     label: "Gully" },
];

function sanitizeMobile(v: string) { return v.replace(/\D/g, "").slice(0, 10); }
function initials(name: string) { return name.split(/\s+/).map(w => w[0]).join("").toUpperCase().slice(0, 2); }
function typeLabel(t: TeamType) { return TEAM_TYPES.find(x => x.value === t)?.label ?? t; }

function PlayerAvatar({ avatarUrl, name }: { avatarUrl?: string | null; name: string }) {
  return (
    <div className="w-8 h-8 rounded-lg bg-muted flex items-center justify-center text-[11px] font-bold text-muted-foreground shrink-0 overflow-hidden border">
      {avatarUrl ? <img src={avatarUrl} alt={name} className="w-full h-full object-cover" /> : initials(name)}
    </div>
  );
}

// ─── Delete Confirm Dialog ────────────────────────────────────────────────────

function DeleteDialog({ name, open, onClose, onConfirm, isPending }: {
  name: string; open: boolean; onClose: () => void; onConfirm: () => void; isPending: boolean;
}) {
  return (
    <Dialog open={open} onOpenChange={o => !o && onClose()}>
      <DialogContent className="max-w-sm">
        <DialogHeader><DialogTitle>Delete {name}?</DialogTitle></DialogHeader>
        <p className="text-sm text-muted-foreground">This is permanent and cannot be undone. Teams linked to active tournaments cannot be deleted.</p>
        <DialogFooter>
          <Button variant="outline" onClick={onClose}>Cancel</Button>
          <Button variant="destructive" disabled={isPending} onClick={onConfirm}>
            {isPending ? "Deleting…" : "Delete Team"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

// ─── Players Tab ──────────────────────────────────────────────────────────────

type Player = {
  id: string;
  userId: string;
  user: { id: string; name: string; avatarUrl?: string | null; phone?: string | null };
};

function PlayersTab({ teamId, players, captainId, viceCaptainId, wicketKeeperId }: {
  teamId: string;
  players: Player[];
  captainId: string;
  viceCaptainId: string;
  wicketKeeperId: string;
}) {
  const quickAddMutation = useQuickAddPlayerToTeamMutation();
  const addMutation      = useAddPlayerToTeamMutation();
  const removeMutation   = useRemovePlayerFromTeamMutation();

  const nameRef = useRef<HTMLInputElement>(null);
  const phoneRef = useRef<HTMLInputElement>(null);

  const [name, setName]       = useState("");
  const [phone, setPhone]     = useState("");
  const [nameErr, setNameErr] = useState("");
  const [byId, setById]       = useState(false);
  const [existingId, setExistingId] = useState("");

  // Auto-focus name field on mount
  useEffect(() => { nameRef.current?.focus(); }, []);

  const canAdd = name.trim().length >= 2 && phone.length === 10;

  function handleAdd() {
    if (name.trim().length < 2) { setNameErr("Min 2 characters"); nameRef.current?.focus(); return; }
    if (phone.length !== 10) { phoneRef.current?.focus(); return; }
    setNameErr("");
    quickAddMutation.mutate(
      { teamId, data: { name: name.trim(), countryCode: "+91", mobileNumber: phone } },
      {
        onSuccess: () => {
          setName(""); setPhone("");
          // Re-focus name for next player
          setTimeout(() => nameRef.current?.focus(), 50);
        },
      },
    );
  }

  function handleAddById() {
    if (!existingId.trim()) return;
    addMutation.mutate({ teamId, playerId: existingId.trim() }, {
      onSuccess: () => setExistingId(""),
    });
  }

  // Build role labels per player
  const roleLabel: Record<string, string[]> = {};
  if (captainId)      (roleLabel[captainId]      ??= []).push("C");
  if (viceCaptainId)  (roleLabel[viceCaptainId]  ??= []).push("VC");
  if (wicketKeeperId) (roleLabel[wicketKeeperId] ??= []).push("WK");

  const count    = players.length;
  const needed   = Math.max(0, 11 - count);
  const complete = count >= 11;

  return (
    <div className="space-y-4">
      {/* ── Quick-add bar ── */}
      <div className="rounded-xl border bg-card overflow-hidden">
        {/* Tab: By Phone / By ID */}
        <div className="flex border-b text-xs font-medium">
          <button
            onClick={() => setById(false)}
            className={`flex-1 py-2 transition-colors ${!byId ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:bg-muted"}`}
          >
            Add by Phone
          </button>
          <button
            onClick={() => setById(true)}
            className={`flex-1 py-2 transition-colors ${byId ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:bg-muted"}`}
          >
            Add by ID
          </button>
        </div>

        <div className="p-3">
          {!byId ? (
            <div className="flex gap-2 items-start">
              {/* Name */}
              <div className="flex-1 min-w-0">
                <Input
                  ref={nameRef}
                  placeholder="Player name"
                  value={name}
                  onChange={e => { setName(e.target.value); setNameErr(""); }}
                  onKeyDown={e => {
                    if (e.key === "Enter") canAdd ? handleAdd() : phoneRef.current?.focus();
                    if (e.key === "Tab") { e.preventDefault(); phoneRef.current?.focus(); }
                  }}
                  className={nameErr ? "border-destructive" : ""}
                />
                {nameErr && <p className="text-[11px] text-destructive mt-0.5 pl-0.5">{nameErr}</p>}
              </div>
              {/* Phone */}
              <div className="flex items-center gap-1 shrink-0">
                <span className="text-xs text-muted-foreground border rounded-md px-2 h-9 flex items-center bg-muted/50">+91</span>
                <Input
                  ref={phoneRef}
                  className="w-36"
                  placeholder="10-digit mobile"
                  value={phone}
                  onChange={e => setPhone(sanitizeMobile(e.target.value))}
                  inputMode="numeric"
                  maxLength={10}
                  onKeyDown={e => e.key === "Enter" && handleAdd()}
                />
              </div>
              <Button
                className="shrink-0"
                disabled={!canAdd || quickAddMutation.isPending}
                onClick={handleAdd}
              >
                {quickAddMutation.isPending ? "…" : <><Plus className="w-4 h-4 mr-1" />Add</>}
              </Button>
            </div>
          ) : (
            <div className="flex gap-2">
              <Input
                className="flex-1"
                placeholder="Player Profile ID or User ID"
                value={existingId}
                onChange={e => setExistingId(e.target.value)}
                onKeyDown={e => e.key === "Enter" && handleAddById()}
                autoFocus
              />
              <Button disabled={!existingId.trim() || addMutation.isPending} onClick={handleAddById}>
                {addMutation.isPending ? "…" : <><Plus className="w-4 h-4 mr-1" />Add</>}
              </Button>
            </div>
          )}
        </div>
      </div>

      {/* ── Roster ── */}
      <div className="rounded-xl border overflow-hidden">
        {/* Header */}
        <div className="px-4 py-2.5 border-b bg-muted/30 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Users className="w-3.5 h-3.5 text-muted-foreground" />
            <span className="text-xs font-semibold text-muted-foreground uppercase tracking-wide">
              Squad
            </span>
          </div>
          <div className="flex items-center gap-2">
            {!complete && (
              <span className="text-[11px] text-amber-600 font-medium">
                {needed} more to complete XI
              </span>
            )}
            <span className={`text-xs font-bold px-2 py-0.5 rounded-full ${
              complete ? "bg-emerald-100 text-emerald-700" : "bg-muted text-muted-foreground"
            }`}>
              {count} / 11
            </span>
          </div>
        </div>

        {count === 0 ? (
          <div className="py-12 text-center text-sm text-muted-foreground">
            <Users className="w-8 h-8 mx-auto mb-2 opacity-20" />
            No players yet — start adding above
          </div>
        ) : (
          <div className="divide-y">
            {players.map((p, i) => (
              <div
                key={p.id}
                className="flex items-center gap-3 px-4 py-2.5 hover:bg-muted/20 transition-colors group"
              >
                <span className="w-5 text-right text-xs text-muted-foreground shrink-0">{i + 1}</span>
                <PlayerAvatar avatarUrl={p.user.avatarUrl} name={p.user.name} />
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium leading-tight truncate">{p.user.name}</p>
                  <p className="text-[11px] text-muted-foreground">{p.user.phone ?? "—"}</p>
                </div>
                <div className="flex items-center gap-1">
                  {(roleLabel[p.id] ?? []).map(r => (
                    <span key={r} className={`text-[10px] font-bold px-1.5 py-0.5 rounded leading-none ${
                      r === "C"  ? "bg-amber-100 text-amber-700" :
                      r === "VC" ? "bg-blue-100 text-blue-700" :
                                   "bg-emerald-100 text-emerald-700"
                    }`}>{r}</span>
                  ))}
                </div>
                <button
                  onClick={() => removeMutation.mutate({ teamId, playerId: p.id })}
                  disabled={removeMutation.isPending}
                  className="w-6 h-6 rounded flex items-center justify-center text-muted-foreground/40 hover:text-destructive hover:bg-destructive/10 transition-colors"
                >
                  <X className="w-3 h-3" />
                </button>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

// ─── Settings Tab ─────────────────────────────────────────────────────────────

function SettingsTab({
  teamId, data, form, players, onFieldChange, onSave, isSaving,
}: {
  teamId: string;
  data: any;
  form: any;
  players: Player[];
  onFieldChange: (key: string, value: any) => void;
  onSave: () => void;
  isSaving: boolean;
}) {
  return (
    <div className="space-y-5">
      {/* Team details */}
      <div className="rounded-xl border bg-card p-5 space-y-5">
        <p className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">Team Info</p>
        <div className="flex items-start gap-5">
          <ImageUpload
            folder="teams" id={teamId} filename="logo"
            currentUrl={form.logoUrl}
            onUpload={url => onFieldChange("logoUrl", url)}
            label="Logo" shape="circle" size="lg"
          />
          <div className="flex-1 space-y-3">
            <div className="space-y-1">
              <Label className="text-xs text-muted-foreground">Team Name *</Label>
              <Input value={form.name} onChange={e => onFieldChange("name", e.target.value)} />
            </div>
            <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
              <div className="space-y-1">
                <Label className="text-xs text-muted-foreground">Short Name</Label>
                <Input value={form.shortName} maxLength={5} placeholder="e.g. RCB"
                  onChange={e => onFieldChange("shortName", e.target.value)} />
              </div>
              <div className="space-y-1">
                <Label className="text-xs text-muted-foreground">City</Label>
                <Input value={form.city} onChange={e => onFieldChange("city", e.target.value)} />
              </div>
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
          <div className="space-y-1">
            <Label className="text-xs text-muted-foreground">Team Type</Label>
            <Select value={form.teamType} onValueChange={v => onFieldChange("teamType", v)}>
              <SelectTrigger><SelectValue /></SelectTrigger>
              <SelectContent>
                {TEAM_TYPES.map(t => <SelectItem key={t.value} value={t.value}>{t.label}</SelectItem>)}
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-1">
            <Label className="text-xs text-muted-foreground">Status</Label>
            <div className="flex items-center justify-between rounded-lg border px-3 py-2">
              <span className="text-sm">{form.isActive ? "Active" : "Inactive"}</span>
              <Switch checked={form.isActive} onCheckedChange={v => onFieldChange("isActive", v)} />
            </div>
          </div>
        </div>
      </div>

      {/* Roles */}
      {players.length > 0 && (
        <div className="rounded-xl border bg-card p-5 space-y-4">
          <p className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">Roles</p>
          <div className="grid grid-cols-1 gap-3 sm:grid-cols-3">
            {([
              { key: "captainId",      label: "Captain",       badge: "C",  color: "amber" },
              { key: "viceCaptainId",  label: "Vice Captain",  badge: "VC", color: "blue"  },
              { key: "wicketKeeperId", label: "Wicket Keeper", badge: "WK", color: "emerald" },
            ] as const).map(({ key, label, badge, color }) => (
              <div key={key} className="space-y-1">
                <div className="flex items-center gap-1.5">
                  <span className={`text-[10px] font-bold px-1.5 py-0.5 rounded bg-${color}-100 text-${color}-700`}>{badge}</span>
                  <Label className="text-xs text-muted-foreground">{label}</Label>
                </div>
                <Select
                  value={form[key] || "NONE"}
                  onValueChange={v => onFieldChange(key, v === "NONE" ? "" : v)}
                >
                  <SelectTrigger className="h-8 text-xs"><SelectValue placeholder="None" /></SelectTrigger>
                  <SelectContent>
                    <SelectItem value="NONE">— None —</SelectItem>
                    {players.map(p => (
                      <SelectItem key={p.id} value={p.id} className="text-xs">{p.user.name}</SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            ))}
          </div>
        </div>
      )}

      <div className="flex items-center justify-between">
        <p className="text-xs text-muted-foreground">Created {formatDate(data.createdAt)}</p>
        <Button disabled={!form.name.trim() || isSaving} onClick={onSave}>
          {isSaving ? "Saving…" : "Save Changes"}
        </Button>
      </div>
    </div>
  );
}

// ─── Page ─────────────────────────────────────────────────────────────────────

export default function TeamDetailPage() {
  const { id } = useParams<{ id: string }>();
  const router  = useRouter();

  const { data, isLoading } = useTeamQuery(id);
  const updateMutation  = useUpdateTeamMutation();
  const deleteMutation  = useDeleteTeamMutation();

  const [deleteOpen, setDeleteOpen] = useState(false);
  const [form, setForm] = useState({
    name: "", shortName: "", logoUrl: "", city: "",
    teamType: "FRIENDLY" as TeamType, isActive: true,
    captainId: "", viceCaptainId: "", wicketKeeperId: "",
  });

  useEffect(() => {
    if (!data) return;
    setForm({
      name:           data.name,
      shortName:      data.shortName ?? "",
      logoUrl:        data.logoUrl ?? "",
      city:           data.city ?? "",
      teamType:       data.teamType,
      isActive:       data.isActive,
      captainId:      data.captainId ?? "",
      viceCaptainId:  (data as any).viceCaptainId ?? "",
      wicketKeeperId: (data as any).wicketKeeperId ?? "",
    });
  }, [data]);

  function handleFieldChange(key: string, value: any) {
    setForm(f => ({ ...f, [key]: value }));
  }

  function handleSave() {
    updateMutation.mutate({
      id,
      data: {
        name:           form.name.trim(),
        shortName:      form.shortName.trim() || undefined,
        logoUrl:        form.logoUrl.trim() || undefined,
        city:           form.city.trim() || undefined,
        teamType:       form.teamType,
        isActive:       form.isActive,
        captainId:      form.captainId || undefined,
        viceCaptainId:  form.viceCaptainId || undefined,
        wicketKeeperId: form.wicketKeeperId || undefined,
      },
    });
  }

  const players: Player[] = (data as any)?.players ?? [];

  if (isLoading) {
    return (
      <div className="max-w-2xl mx-auto px-4 py-8 space-y-4">
        {[24, 48, 400].map(h => (
          <div key={h} className={`h-${h === 24 ? 6 : h === 48 ? 12 : 96} bg-muted rounded-xl animate-pulse`} />
        ))}
      </div>
    );
  }

  if (!data) {
    return (
      <div className="max-w-2xl mx-auto px-4 py-20 text-center space-y-3">
        <p className="text-muted-foreground">Team not found.</p>
        <Button variant="outline" onClick={() => router.push("/admin/teams")}>← Back to Teams</Button>
      </div>
    );
  }

  return (
    <div className="max-w-2xl mx-auto px-4 py-6 space-y-4">
      {/* Top bar */}
      <div className="flex items-center justify-between">
        <Button variant="ghost" size="sm" onClick={() => router.push("/admin/teams")} className="gap-1.5 -ml-2">
          <ArrowLeft className="w-4 h-4" /> Teams
        </Button>
        <Button
          variant="ghost" size="sm"
          className="text-destructive hover:text-destructive hover:bg-destructive/10 gap-1.5"
          onClick={() => setDeleteOpen(true)}
        >
          <Trash2 className="w-3.5 h-3.5" /> Delete
        </Button>
      </div>

      {/* Team identity header */}
      <div className="flex items-center gap-3 px-1">
        <div className="w-10 h-10 rounded-xl bg-muted flex items-center justify-center text-sm font-bold text-muted-foreground shrink-0 overflow-hidden border">
          {form.logoUrl
            ? <img src={form.logoUrl} alt={data.name} className="w-full h-full object-cover" />
            : initials(data.name)
          }
        </div>
        <div className="flex-1 min-w-0">
          <h1 className="text-lg font-bold leading-tight truncate">{data.name}</h1>
          <p className="text-xs text-muted-foreground">
            {typeLabel(data.teamType)}{data.city ? ` · ${data.city}` : ""}
            {" · "}
            <span className={data.isActive ? "text-emerald-600" : "text-muted-foreground"}>
              {data.isActive ? "Active" : "Inactive"}
            </span>
          </p>
        </div>
        <span className={`text-xs font-bold px-2.5 py-1 rounded-full ${
          players.length >= 11
            ? "bg-emerald-100 text-emerald-700"
            : "bg-amber-100 text-amber-700"
        }`}>
          {players.length} / 11
        </span>
      </div>

      {/* Tabs */}
      <Tabs defaultValue="players">
        <TabsList className="w-full">
          <TabsTrigger value="players" className="flex-1">
            Players
            {players.length > 0 && (
              <span className="ml-1.5 text-[10px] font-bold bg-primary/10 text-primary px-1.5 py-0.5 rounded-full">
                {players.length}
              </span>
            )}
          </TabsTrigger>
          <TabsTrigger value="settings" className="flex-1">Settings</TabsTrigger>
        </TabsList>

        <TabsContent value="players" className="mt-4">
          <PlayersTab
            teamId={id}
            players={players}
            captainId={form.captainId}
            viceCaptainId={form.viceCaptainId}
            wicketKeeperId={form.wicketKeeperId}
          />
        </TabsContent>

        <TabsContent value="settings" className="mt-4">
          <SettingsTab
            teamId={id}
            data={data}
            form={form}
            players={players}
            onFieldChange={handleFieldChange}
            onSave={handleSave}
            isSaving={updateMutation.isPending}
          />
        </TabsContent>
      </Tabs>

      <DeleteDialog
        name={data.name}
        open={deleteOpen}
        onClose={() => setDeleteOpen(false)}
        isPending={deleteMutation.isPending}
        onConfirm={() => deleteMutation.mutate(id, { onSuccess: () => router.push("/admin/teams") })}
      />
    </div>
  );
}
