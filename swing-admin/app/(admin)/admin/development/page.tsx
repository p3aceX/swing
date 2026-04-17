"use client";

import { useEffect, useMemo, useState, type ReactNode } from "react";
import { PageHeader } from "@/components/admin/page-header";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Switch } from "@/components/ui/switch";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Textarea } from "@/components/ui/textarea";
import {
  adminApi,
  ApiError,
  type CreateDrillLibraryBody,
  type CreateSessionTypeBody,
  type CreateSkillAreaBody,
  type CreateWatchFlagBody,
  type DrillCategory,
  type DrillLibraryRecord,
  type DrillTargetUnit,
  type RoleTag,
  type SessionTypeRecord,
  type SkillAreaRecord,
  type WatchFlagRecord,
  type WatchSeverity,
} from "@/lib/api";

const roleOptions: RoleTag[] = [
  "BATSMAN",
  "BOWLER",
  "ALL_ROUNDER",
  "FIELDER",
  "WICKET_KEEPER",
];

const categoryOptions: DrillCategory[] = [
  "TECHNIQUE",
  "FITNESS",
  "MENTAL",
  "MATCH_SIMULATION",
];

const targetUnitOptions: DrillTargetUnit[] = [
  "BALLS",
  "OVERS",
  "MINUTES",
  "REPS",
  "SESSIONS",
];

const severityOptions: WatchSeverity[] = ["MONITOR", "URGENT"];

function roleLabel(role: RoleTag) {
  return role.replaceAll("_", " ");
}

function formatApiError(error: unknown) {
  if (error instanceof ApiError) return error.message;
  if (error instanceof Error) return error.message;
  return "Request failed";
}

function CardShell({
  title,
  description,
  action,
  children,
}: {
  title: string;
  description: string;
  action?: ReactNode;
  children: ReactNode;
}) {
  return (
    <section className="rounded-2xl border bg-card">
      <div className="flex flex-col gap-3 border-b px-5 py-4 md:flex-row md:items-center md:justify-between">
        <div>
          <h2 className="text-lg font-semibold">{title}</h2>
          <p className="text-sm text-muted-foreground">{description}</p>
        </div>
        {action}
      </div>
      <div className="p-5">{children}</div>
    </section>
  );
}

function RowActions({
  onEdit,
  onDelete,
  deleting,
}: {
  onEdit: () => void;
  onDelete: () => void;
  deleting?: boolean;
}) {
  return (
    <div className="flex gap-2">
      <Button size="sm" variant="outline" onClick={onEdit}>
        Edit
      </Button>
      <Button size="sm" variant="destructive" onClick={onDelete} disabled={deleting}>
        Delete
      </Button>
    </div>
  );
}

function EmptyState({ label }: { label: string }) {
  return (
    <div className="rounded-xl border border-dashed p-8 text-center text-sm text-muted-foreground">
      No {label} yet.
    </div>
  );
}

type SessionTypeFormState = {
  id?: string;
  name: string;
  color: string;
  defaultDurationMinutes: string;
  isActive: boolean;
};

function SessionTypeDialog({
  open,
  onOpenChange,
  initial,
  onSubmit,
  saving,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  initial?: SessionTypeRecord | null;
  onSubmit: (body: CreateSessionTypeBody, id?: string) => Promise<void>;
  saving: boolean;
}) {
  const [form, setForm] = useState<SessionTypeFormState>({
    name: "",
    color: "#0EA5E9",
    defaultDurationMinutes: "90",
    isActive: true,
  });
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!open) return;
    setError(null);
    setForm(
      initial
        ? {
            id: initial.id,
            name: initial.name,
            color: initial.color,
            defaultDurationMinutes: String(initial.defaultDurationMinutes ?? 90),
            isActive: initial.isActive,
          }
        : {
            name: "",
            color: "#0EA5E9",
            defaultDurationMinutes: "90",
            isActive: true,
          },
    );
  }, [initial, open]);

  async function handleSubmit() {
    if (!form.name.trim()) {
      setError("Name is required");
      return;
    }
    const duration = Number(form.defaultDurationMinutes);
    if (!Number.isFinite(duration) || duration <= 0) {
      setError("Default duration must be a positive number");
      return;
    }
    setError(null);
    await onSubmit(
      {
        name: form.name.trim(),
        color: form.color.trim(),
        defaultDurationMinutes: duration,
        isActive: form.isActive,
      },
      form.id,
    );
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>{initial ? "Edit session type" : "New session type"}</DialogTitle>
          <DialogDescription>These options appear in the coach app start session flow.</DialogDescription>
        </DialogHeader>
        <div className="grid gap-4">
          <div className="grid gap-2">
            <Label htmlFor="session-type-name">Name</Label>
            <Input
              id="session-type-name"
              value={form.name}
              onChange={(e) => setForm((current) => ({ ...current, name: e.target.value }))}
              placeholder="Batting nets"
            />
          </div>
          <div className="grid gap-2 sm:grid-cols-2">
            <div className="grid gap-2">
              <Label htmlFor="session-type-color">Color</Label>
              <Input
                id="session-type-color"
                value={form.color}
                onChange={(e) => setForm((current) => ({ ...current, color: e.target.value }))}
                placeholder="#0EA5E9"
              />
            </div>
            <div className="grid gap-2">
              <Label htmlFor="session-type-duration">Default duration</Label>
              <Input
                id="session-type-duration"
                type="number"
                min={1}
                value={form.defaultDurationMinutes}
                onChange={(e) =>
                  setForm((current) => ({
                    ...current,
                    defaultDurationMinutes: e.target.value,
                  }))
                }
              />
            </div>
          </div>
          <div className="flex items-center justify-between rounded-xl border px-3 py-2">
            <div>
              <div className="font-medium">Active</div>
              <div className="text-sm text-muted-foreground">Hide inactive options from coaches.</div>
            </div>
            <Switch
              checked={form.isActive}
              onCheckedChange={(checked) => setForm((current) => ({ ...current, isActive: checked }))}
            />
          </div>
          {error && <div className="rounded-lg border border-destructive bg-destructive/10 p-3 text-sm text-destructive">{error}</div>}
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={() => onOpenChange(false)} disabled={saving}>
            Cancel
          </Button>
          <Button onClick={handleSubmit} disabled={saving}>
            {saving ? "Saving..." : initial ? "Save changes" : "Create"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

type SkillAreaFormState = {
  id?: string;
  name: string;
  roleTag: RoleTag;
  isActive: boolean;
};

function SkillAreaDialog({
  open,
  onOpenChange,
  initial,
  onSubmit,
  saving,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  initial?: SkillAreaRecord | null;
  onSubmit: (body: CreateSkillAreaBody, id?: string) => Promise<void>;
  saving: boolean;
}) {
  const [form, setForm] = useState<SkillAreaFormState>({
    name: "",
    roleTag: "BATSMAN",
    isActive: true,
  });
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!open) return;
    setError(null);
    setForm(
      initial
        ? {
            id: initial.id,
            name: initial.name,
            roleTag: initial.roleTag,
            isActive: initial.isActive,
          }
        : {
            name: "",
            roleTag: "BATSMAN",
            isActive: true,
          },
    );
  }, [initial, open]);

  async function handleSubmit() {
    if (!form.name.trim()) {
      setError("Skill area name is required");
      return;
    }
    setError(null);
    await onSubmit(
      {
        name: form.name.trim(),
        roleTag: form.roleTag,
        isActive: form.isActive,
      },
      form.id,
    );
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>{initial ? "Edit skill area" : "New skill area"}</DialogTitle>
          <DialogDescription>These drive the strength and work-on chips in the coach session flow.</DialogDescription>
        </DialogHeader>
        <div className="grid gap-4">
          <div className="grid gap-2">
            <Label htmlFor="skill-area-name">Name</Label>
            <Input
              id="skill-area-name"
              value={form.name}
              onChange={(e) => setForm((current) => ({ ...current, name: e.target.value }))}
              placeholder="Cover drive"
            />
          </div>
          <div className="grid gap-2">
            <Label>Role</Label>
            <Select
              value={form.roleTag}
              onValueChange={(value) =>
                setForm((current) => ({ ...current, roleTag: value as RoleTag }))
              }
            >
              <SelectTrigger>
                <SelectValue placeholder="Select role" />
              </SelectTrigger>
              <SelectContent>
                {roleOptions.map((role) => (
                  <SelectItem key={role} value={role}>
                    {roleLabel(role)}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div className="flex items-center justify-between rounded-xl border px-3 py-2">
            <div>
              <div className="font-medium">Active</div>
              <div className="text-sm text-muted-foreground">Inactive skills are hidden from new coach inputs.</div>
            </div>
            <Switch
              checked={form.isActive}
              onCheckedChange={(checked) => setForm((current) => ({ ...current, isActive: checked }))}
            />
          </div>
          {error && <div className="rounded-lg border border-destructive bg-destructive/10 p-3 text-sm text-destructive">{error}</div>}
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={() => onOpenChange(false)} disabled={saving}>
            Cancel
          </Button>
          <Button onClick={handleSubmit} disabled={saving}>
            {saving ? "Saving..." : initial ? "Save changes" : "Create"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

type WatchFlagFormState = {
  id?: string;
  name: string;
  roleTag: RoleTag;
  severity: WatchSeverity;
  description: string;
  isActive: boolean;
};

function WatchFlagDialog({
  open,
  onOpenChange,
  initial,
  onSubmit,
  saving,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  initial?: WatchFlagRecord | null;
  onSubmit: (body: CreateWatchFlagBody, id?: string) => Promise<void>;
  saving: boolean;
}) {
  const [form, setForm] = useState<WatchFlagFormState>({
    name: "",
    roleTag: "BATSMAN",
    severity: "MONITOR",
    description: "",
    isActive: true,
  });
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!open) return;
    setError(null);
    setForm(
      initial
        ? {
            id: initial.id,
            name: initial.name,
            roleTag: initial.roleTag,
            severity: initial.severity,
            description: initial.description ?? "",
            isActive: initial.isActive,
          }
        : {
            name: "",
            roleTag: "BATSMAN",
            severity: "MONITOR",
            description: "",
            isActive: true,
          },
    );
  }, [initial, open]);

  async function handleSubmit() {
    if (!form.name.trim()) {
      setError("Flag name is required");
      return;
    }
    setError(null);
    await onSubmit(
      {
        name: form.name.trim(),
        roleTag: form.roleTag,
        severity: form.severity,
        description: form.description.trim(),
        isActive: form.isActive,
      },
      form.id,
    );
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>{initial ? "Edit watch flag" : "New watch flag"}</DialogTitle>
          <DialogDescription>Coaches tap these chips instead of typing observations on the ground.</DialogDescription>
        </DialogHeader>
        <div className="grid gap-4">
          <div className="grid gap-2">
            <Label htmlFor="watch-flag-name">Name</Label>
            <Input
              id="watch-flag-name"
              value={form.name}
              onChange={(e) => setForm((current) => ({ ...current, name: e.target.value }))}
              placeholder="Open stance creeping"
            />
          </div>
          <div className="grid gap-4 sm:grid-cols-2">
            <div className="grid gap-2">
              <Label>Role</Label>
              <Select
                value={form.roleTag}
                onValueChange={(value) =>
                  setForm((current) => ({ ...current, roleTag: value as RoleTag }))
                }
              >
                <SelectTrigger>
                  <SelectValue placeholder="Select role" />
                </SelectTrigger>
                <SelectContent>
                  {roleOptions.map((role) => (
                    <SelectItem key={role} value={role}>
                      {roleLabel(role)}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="grid gap-2">
              <Label>Severity</Label>
              <Select
                value={form.severity}
                onValueChange={(value) =>
                  setForm((current) => ({ ...current, severity: value as WatchSeverity }))
                }
              >
                <SelectTrigger>
                  <SelectValue placeholder="Select severity" />
                </SelectTrigger>
                <SelectContent>
                  {severityOptions.map((severity) => (
                    <SelectItem key={severity} value={severity}>
                      {severity}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>
          <div className="grid gap-2">
            <Label htmlFor="watch-flag-description">Description</Label>
            <Textarea
              id="watch-flag-description"
              value={form.description}
              onChange={(e) => setForm((current) => ({ ...current, description: e.target.value }))}
              placeholder="Short guidance for the coach using this flag."
            />
          </div>
          <div className="flex items-center justify-between rounded-xl border px-3 py-2">
            <div>
              <div className="font-medium">Active</div>
              <div className="text-sm text-muted-foreground">Inactive flags stay in history but disappear from new sessions.</div>
            </div>
            <Switch
              checked={form.isActive}
              onCheckedChange={(checked) => setForm((current) => ({ ...current, isActive: checked }))}
            />
          </div>
          {error && <div className="rounded-lg border border-destructive bg-destructive/10 p-3 text-sm text-destructive">{error}</div>}
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={() => onOpenChange(false)} disabled={saving}>
            Cancel
          </Button>
          <Button onClick={handleSubmit} disabled={saving}>
            {saving ? "Saving..." : initial ? "Save changes" : "Create"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

type DrillFormState = {
  id?: string;
  name: string;
  description: string;
  videoUrl: string;
  roleTags: RoleTag[];
  category: DrillCategory;
  targetUnit: DrillTargetUnit;
  isActive: boolean;
};

function DrillDialog({
  open,
  onOpenChange,
  initial,
  onSubmit,
  saving,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  initial?: DrillLibraryRecord | null;
  onSubmit: (body: CreateDrillLibraryBody, id?: string) => Promise<void>;
  saving: boolean;
}) {
  const [form, setForm] = useState<DrillFormState>({
    name: "",
    description: "",
    videoUrl: "",
    roleTags: ["BATSMAN"],
    category: "TECHNIQUE",
    targetUnit: "BALLS",
    isActive: true,
  });
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!open) return;
    setError(null);
    setForm(
      initial
        ? {
            id: initial.id,
            name: initial.name,
            description: initial.description ?? "",
            videoUrl: initial.videoUrl ?? "",
            roleTags: initial.roleTags.length > 0 ? initial.roleTags : ["BATSMAN"],
            category: initial.category,
            targetUnit: initial.targetUnit,
            isActive: initial.isActive,
          }
        : {
            name: "",
            description: "",
            videoUrl: "",
            roleTags: ["BATSMAN"],
            category: "TECHNIQUE",
            targetUnit: "BALLS",
            isActive: true,
          },
    );
  }, [initial, open]);

  async function handleSubmit() {
    if (!form.name.trim()) {
      setError("Drill name is required");
      return;
    }
    if (form.roleTags.length === 0) {
      setError("Select at least one role");
      return;
    }
    if (form.videoUrl.trim()) {
      try {
        // Validate URL format
        new URL(form.videoUrl.trim());
      } catch {
        setError("Video link must be a valid URL");
        return;
      }
    }
    setError(null);
    await onSubmit(
      {
        name: form.name.trim(),
        description: form.description.trim(),
        videoUrl: form.videoUrl.trim() || undefined,
        roleTags: form.roleTags,
        category: form.category,
        targetUnit: form.targetUnit,
        isActive: form.isActive,
      },
      form.id,
    );
  }

  function toggleRole(role: RoleTag) {
    setForm((current) => ({
      ...current,
      roleTags: current.roleTags.includes(role)
        ? current.roleTags.filter((value) => value !== role)
        : [...current.roleTags, role],
    }));
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-2xl">
        <DialogHeader>
          <DialogTitle>{initial ? "Edit drill" : "New drill"}</DialogTitle>
          <DialogDescription>Admin-created drills are available to coaches during live sessions.</DialogDescription>
        </DialogHeader>
        <div className="grid gap-4">
          <div className="grid gap-2">
            <Label htmlFor="drill-name">Name</Label>
            <Input
              id="drill-name"
              value={form.name}
              onChange={(e) => setForm((current) => ({ ...current, name: e.target.value }))}
              placeholder="Front foot defence"
            />
          </div>
          <div className="grid gap-2">
            <Label htmlFor="drill-description">Description</Label>
            <Textarea
              id="drill-description"
              value={form.description}
              onChange={(e) => setForm((current) => ({ ...current, description: e.target.value }))}
              placeholder="Optional notes for coaches and players."
            />
          </div>
          <div className="grid gap-2">
            <Label htmlFor="drill-video-url">Video / YouTube link</Label>
            <Input
              id="drill-video-url"
              value={form.videoUrl}
              onChange={(e) => setForm((current) => ({ ...current, videoUrl: e.target.value }))}
              placeholder="https://youtu.be/..."
              type="url"
              inputMode="url"
            />
            <p className="text-xs text-muted-foreground">
              Optional. Add a reference clip players can watch for this drill.
            </p>
          </div>
          <div className="grid gap-2">
            <Label>Role tags</Label>
            <div className="flex flex-wrap gap-2">
              {roleOptions.map((role) => {
                const active = form.roleTags.includes(role);
                return (
                  <button
                    key={role}
                    type="button"
                    onClick={() => toggleRole(role)}
                    className={`rounded-full border px-3 py-1.5 text-sm ${
                      active
                        ? "border-primary bg-primary text-primary-foreground"
                        : "border-border bg-card text-foreground"
                    }`}
                  >
                    {roleLabel(role)}
                  </button>
                );
              })}
            </div>
          </div>
          <div className="grid gap-4 sm:grid-cols-2">
            <div className="grid gap-2">
              <Label>Category</Label>
              <Select
                value={form.category}
                onValueChange={(value) =>
                  setForm((current) => ({ ...current, category: value as DrillCategory }))
                }
              >
                <SelectTrigger>
                  <SelectValue placeholder="Select category" />
                </SelectTrigger>
                <SelectContent>
                  {categoryOptions.map((category) => (
                    <SelectItem key={category} value={category}>
                      {category.replaceAll("_", " ")}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="grid gap-2">
              <Label>Default target unit</Label>
              <Select
                value={form.targetUnit}
                onValueChange={(value) =>
                  setForm((current) => ({ ...current, targetUnit: value as DrillTargetUnit }))
                }
              >
                <SelectTrigger>
                  <SelectValue placeholder="Select unit" />
                </SelectTrigger>
                <SelectContent>
                  {targetUnitOptions.map((unit) => (
                    <SelectItem key={unit} value={unit}>
                      {unit}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>
          <div className="flex items-center justify-between rounded-xl border px-3 py-2">
            <div>
              <div className="font-medium">Active</div>
              <div className="text-sm text-muted-foreground">Inactive drills stay in history but cannot be newly assigned.</div>
            </div>
            <Switch
              checked={form.isActive}
              onCheckedChange={(checked) => setForm((current) => ({ ...current, isActive: checked }))}
            />
          </div>
          {error && <div className="rounded-lg border border-destructive bg-destructive/10 p-3 text-sm text-destructive">{error}</div>}
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={() => onOpenChange(false)} disabled={saving}>
            Cancel
          </Button>
          <Button onClick={handleSubmit} disabled={saving}>
            {saving ? "Saving..." : initial ? "Save changes" : "Create"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

export default function DevelopmentPage() {
  const [sessionTypes, setSessionTypes] = useState<SessionTypeRecord[]>([]);
  const [skillAreas, setSkillAreas] = useState<SkillAreaRecord[]>([]);
  const [watchFlags, setWatchFlags] = useState<WatchFlagRecord[]>([]);
  const [drills, setDrills] = useState<DrillLibraryRecord[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [busyKey, setBusyKey] = useState<string | null>(null);
  const [sessionTypeDialogOpen, setSessionTypeDialogOpen] = useState(false);
  const [skillAreaDialogOpen, setSkillAreaDialogOpen] = useState(false);
  const [watchFlagDialogOpen, setWatchFlagDialogOpen] = useState(false);
  const [drillDialogOpen, setDrillDialogOpen] = useState(false);
  const [editingSessionType, setEditingSessionType] = useState<SessionTypeRecord | null>(null);
  const [editingSkillArea, setEditingSkillArea] = useState<SkillAreaRecord | null>(null);
  const [editingWatchFlag, setEditingWatchFlag] = useState<WatchFlagRecord | null>(null);
  const [editingDrill, setEditingDrill] = useState<DrillLibraryRecord | null>(null);
  const [skillRoleFilter, setSkillRoleFilter] = useState<"ALL" | RoleTag>("ALL");
  const [flagRoleFilter, setFlagRoleFilter] = useState<"ALL" | RoleTag>("ALL");
  const [drillRoleFilter, setDrillRoleFilter] = useState<"ALL" | RoleTag>("ALL");
  const [drillCategoryFilter, setDrillCategoryFilter] = useState<"ALL" | DrillCategory>("ALL");

  async function loadAll() {
    setLoading(true);
    setError(null);
    try {
      const [sessionTypeData, skillAreaData, watchFlagData, drillData] = await Promise.all([
        adminApi.sessionTypes(),
        adminApi.skillAreas(),
        adminApi.watchFlags(),
        adminApi.drills({ includeInactive: true }),
      ]);
      setSessionTypes(sessionTypeData);
      setSkillAreas(skillAreaData);
      setWatchFlags(watchFlagData);
      setDrills(drillData);
    } catch (requestError) {
      setError(formatApiError(requestError));
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    void loadAll();
  }, []);

  const filteredSkillAreas = useMemo(
    () =>
      skillRoleFilter === "ALL"
        ? skillAreas
        : skillAreas.filter((item) => item.roleTag === skillRoleFilter),
    [skillAreas, skillRoleFilter],
  );

  const filteredWatchFlags = useMemo(
    () =>
      flagRoleFilter === "ALL"
        ? watchFlags
        : watchFlags.filter((item) => item.roleTag === flagRoleFilter),
    [watchFlags, flagRoleFilter],
  );

  const filteredDrills = useMemo(
    () =>
      drills.filter((drill) => {
        if (drillRoleFilter !== "ALL" && !drill.roleTags.includes(drillRoleFilter)) return false;
        if (drillCategoryFilter !== "ALL" && drill.category !== drillCategoryFilter) return false;
        return true;
      }),
    [drills, drillCategoryFilter, drillRoleFilter],
  );

  async function withBusy(key: string, action: () => Promise<void>) {
    setBusyKey(key);
    setError(null);
    try {
      await action();
    } catch (requestError) {
      setError(formatApiError(requestError));
    } finally {
      setBusyKey(null);
    }
  }

  async function saveSessionType(body: CreateSessionTypeBody, id?: string) {
    await withBusy(id ? `session-type-save-${id}` : "session-type-create", async () => {
      if (id) {
        await adminApi.updateSessionType(id, body);
      } else {
        await adminApi.createSessionType(body);
      }
      setSessionTypeDialogOpen(false);
      setEditingSessionType(null);
      await loadAll();
    });
  }

  async function saveSkillArea(body: CreateSkillAreaBody, id?: string) {
    await withBusy(id ? `skill-area-save-${id}` : "skill-area-create", async () => {
      if (id) {
        await adminApi.updateSkillArea(id, body);
      } else {
        await adminApi.createSkillArea(body);
      }
      setSkillAreaDialogOpen(false);
      setEditingSkillArea(null);
      await loadAll();
    });
  }

  async function saveWatchFlag(body: CreateWatchFlagBody, id?: string) {
    await withBusy(id ? `watch-flag-save-${id}` : "watch-flag-create", async () => {
      if (id) {
        await adminApi.updateWatchFlag(id, body);
      } else {
        await adminApi.createWatchFlag(body);
      }
      setWatchFlagDialogOpen(false);
      setEditingWatchFlag(null);
      await loadAll();
    });
  }

  async function saveDrill(body: CreateDrillLibraryBody, id?: string) {
    await withBusy(id ? `drill-save-${id}` : "drill-create", async () => {
      if (id) {
        await adminApi.updateDrill(id, body);
      } else {
        await adminApi.createDrill(body);
      }
      setDrillDialogOpen(false);
      setEditingDrill(null);
      await loadAll();
    });
  }

  return (
    <div className="space-y-6">
      <PageHeader
        title="Player Development"
        description="Manage the session types, skill chips, watch flags, and drill library used across coach and player flows."
        action={
          <Button variant="outline" onClick={() => void loadAll()} disabled={loading}>
            Refresh
          </Button>
        }
      />

      {error && (
        <div className="rounded-xl border border-destructive bg-destructive/10 p-4 text-sm text-destructive">
          {error}
        </div>
      )}

      <div className="grid gap-4 md:grid-cols-4">
        <div className="rounded-2xl border bg-card p-5">
          <div className="text-sm text-muted-foreground">Session types</div>
          <div className="mt-2 text-3xl font-semibold">{sessionTypes.length}</div>
        </div>
        <div className="rounded-2xl border bg-card p-5">
          <div className="text-sm text-muted-foreground">Skill areas</div>
          <div className="mt-2 text-3xl font-semibold">{skillAreas.length}</div>
        </div>
        <div className="rounded-2xl border bg-card p-5">
          <div className="text-sm text-muted-foreground">Watch flags</div>
          <div className="mt-2 text-3xl font-semibold">{watchFlags.length}</div>
        </div>
        <div className="rounded-2xl border bg-card p-5">
          <div className="text-sm text-muted-foreground">Drills</div>
          <div className="mt-2 text-3xl font-semibold">{drills.length}</div>
        </div>
      </div>

      <Tabs defaultValue="session-types" className="space-y-4">
        <TabsList>
          <TabsTrigger value="session-types">Session Types</TabsTrigger>
          <TabsTrigger value="skill-areas">Skill Areas</TabsTrigger>
          <TabsTrigger value="watch-flags">Watch Flags</TabsTrigger>
          <TabsTrigger value="drills">Drills</TabsTrigger>
        </TabsList>

        <TabsContent value="session-types">
          <CardShell
            title="Session types"
            description="Coach app chips for starting a session, with color and default duration."
            action={
              <Button
                onClick={() => {
                  setEditingSessionType(null);
                  setSessionTypeDialogOpen(true);
                }}
              >
                Add session type
              </Button>
            }
          >
            {loading ? (
              <div className="text-sm text-muted-foreground">Loading session types...</div>
            ) : sessionTypes.length === 0 ? (
              <EmptyState label="session types" />
            ) : (
              <div className="grid gap-3">
                {sessionTypes.map((item) => (
                  <div key={item.id} className="flex flex-col gap-3 rounded-xl border p-4 md:flex-row md:items-center md:justify-between">
                    <div className="space-y-2">
                      <div className="flex items-center gap-3">
                        <div className="h-4 w-4 rounded-full border" style={{ backgroundColor: item.color }} />
                        <div className="font-medium">{item.name}</div>
                        <Badge variant={item.isActive ? "success" : "outline"}>
                          {item.isActive ? "Active" : "Inactive"}
                        </Badge>
                      </div>
                      <div className="text-sm text-muted-foreground">{item.defaultDurationMinutes} min default</div>
                    </div>
                    <RowActions
                      onEdit={() => {
                        setEditingSessionType(item);
                        setSessionTypeDialogOpen(true);
                      }}
                      onDelete={() =>
                        void withBusy(`session-type-delete-${item.id}`, async () => {
                          await adminApi.deleteSessionType(item.id);
                          await loadAll();
                        })
                      }
                      deleting={busyKey === `session-type-delete-${item.id}`}
                    />
                  </div>
                ))}
              </div>
            )}
          </CardShell>
        </TabsContent>

        <TabsContent value="skill-areas">
          <CardShell
            title="Role skill areas"
            description="Strength and work-on chips are filtered by these role profiles."
            action={
              <div className="flex gap-2">
                <Select value={skillRoleFilter} onValueChange={(value) => setSkillRoleFilter(value as "ALL" | RoleTag)}>
                  <SelectTrigger className="w-[180px]">
                    <SelectValue placeholder="Filter role" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="ALL">All roles</SelectItem>
                    {roleOptions.map((role) => (
                      <SelectItem key={role} value={role}>
                        {roleLabel(role)}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
                <Button
                  onClick={() => {
                    setEditingSkillArea(null);
                    setSkillAreaDialogOpen(true);
                  }}
                >
                  Add skill area
                </Button>
              </div>
            }
          >
            {loading ? (
              <div className="text-sm text-muted-foreground">Loading skill areas...</div>
            ) : filteredSkillAreas.length === 0 ? (
              <EmptyState label="skill areas" />
            ) : (
              <div className="grid gap-3">
                {filteredSkillAreas.map((item) => (
                  <div key={item.id} className="flex flex-col gap-3 rounded-xl border p-4 md:flex-row md:items-center md:justify-between">
                    <div className="space-y-2">
                      <div className="flex flex-wrap items-center gap-2">
                        <div className="font-medium">{item.name}</div>
                        <Badge variant="outline">{roleLabel(item.roleTag)}</Badge>
                        <Badge variant={item.isActive ? "success" : "outline"}>
                          {item.isActive ? "Active" : "Inactive"}
                        </Badge>
                      </div>
                    </div>
                    <RowActions
                      onEdit={() => {
                        setEditingSkillArea(item);
                        setSkillAreaDialogOpen(true);
                      }}
                      onDelete={() =>
                        void withBusy(`skill-area-delete-${item.id}`, async () => {
                          await adminApi.deleteSkillArea(item.id);
                          await loadAll();
                        })
                      }
                      deleting={busyKey === `skill-area-delete-${item.id}`}
                    />
                  </div>
                ))}
              </div>
            )}
          </CardShell>
        </TabsContent>

        <TabsContent value="watch-flags">
          <CardShell
            title="Watch flags"
            description="Selectable observation chips with severity. Coaches tap these instead of typing."
            action={
              <div className="flex gap-2">
                <Select value={flagRoleFilter} onValueChange={(value) => setFlagRoleFilter(value as "ALL" | RoleTag)}>
                  <SelectTrigger className="w-[180px]">
                    <SelectValue placeholder="Filter role" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="ALL">All roles</SelectItem>
                    {roleOptions.map((role) => (
                      <SelectItem key={role} value={role}>
                        {roleLabel(role)}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
                <Button
                  onClick={() => {
                    setEditingWatchFlag(null);
                    setWatchFlagDialogOpen(true);
                  }}
                >
                  Add watch flag
                </Button>
              </div>
            }
          >
            {loading ? (
              <div className="text-sm text-muted-foreground">Loading watch flags...</div>
            ) : filteredWatchFlags.length === 0 ? (
              <EmptyState label="watch flags" />
            ) : (
              <div className="grid gap-3">
                {filteredWatchFlags.map((item) => (
                  <div key={item.id} className="flex flex-col gap-3 rounded-xl border p-4 md:flex-row md:items-start md:justify-between">
                    <div className="space-y-2">
                      <div className="flex flex-wrap items-center gap-2">
                        <div className="font-medium">{item.name}</div>
                        <Badge variant="outline">{roleLabel(item.roleTag)}</Badge>
                        <Badge variant={item.severity === "URGENT" ? "destructive" : "warning"}>
                          {item.severity}
                        </Badge>
                        <Badge variant={item.isActive ? "success" : "outline"}>
                          {item.isActive ? "Active" : "Inactive"}
                        </Badge>
                      </div>
                      {item.description && (
                        <div className="max-w-3xl text-sm text-muted-foreground">{item.description}</div>
                      )}
                    </div>
                    <RowActions
                      onEdit={() => {
                        setEditingWatchFlag(item);
                        setWatchFlagDialogOpen(true);
                      }}
                      onDelete={() =>
                        void withBusy(`watch-flag-delete-${item.id}`, async () => {
                          await adminApi.deleteWatchFlag(item.id);
                          await loadAll();
                        })
                      }
                      deleting={busyKey === `watch-flag-delete-${item.id}`}
                    />
                  </div>
                ))}
              </div>
            )}
          </CardShell>
        </TabsContent>

        <TabsContent value="drills">
          <CardShell
            title="Drill library"
            description="Admin drills and coach-created drills share one library. Coaches can assign these in live sessions and players log progress against them."
            action={
              <div className="flex flex-wrap gap-2">
                <Select value={drillRoleFilter} onValueChange={(value) => setDrillRoleFilter(value as "ALL" | RoleTag)}>
                  <SelectTrigger className="w-[180px]">
                    <SelectValue placeholder="Filter role" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="ALL">All roles</SelectItem>
                    {roleOptions.map((role) => (
                      <SelectItem key={role} value={role}>
                        {roleLabel(role)}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
                <Select
                  value={drillCategoryFilter}
                  onValueChange={(value) => setDrillCategoryFilter(value as "ALL" | DrillCategory)}
                >
                  <SelectTrigger className="w-[210px]">
                    <SelectValue placeholder="Filter category" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="ALL">All categories</SelectItem>
                    {categoryOptions.map((category) => (
                      <SelectItem key={category} value={category}>
                        {category.replaceAll("_", " ")}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
                <Button
                  onClick={() => {
                    setEditingDrill(null);
                    setDrillDialogOpen(true);
                  }}
                >
                  Add drill
                </Button>
              </div>
            }
          >
            {loading ? (
              <div className="text-sm text-muted-foreground">Loading drills...</div>
            ) : filteredDrills.length === 0 ? (
              <EmptyState label="drills" />
            ) : (
              <div className="grid gap-3">
                {filteredDrills.map((item) => (
                  <div key={item.id} className="flex flex-col gap-3 rounded-xl border p-4 md:flex-row md:items-start md:justify-between">
                    <div className="space-y-2">
                      <div className="flex flex-wrap items-center gap-2">
                        <div className="font-medium">{item.name}</div>
                        <Badge variant="outline">{item.category.replaceAll("_", " ")}</Badge>
                        <Badge variant="outline">{item.targetUnit}</Badge>
                        <Badge variant={item.createdByCoachId ? "warning" : "success"}>
                          {item.createdByCoachId ? "Coach created" : "Admin created"}
                        </Badge>
                        <Badge variant={item.isActive ? "success" : "outline"}>
                          {item.isActive ? "Active" : "Inactive"}
                        </Badge>
                      </div>
                      <div className="flex flex-wrap gap-2">
                        {item.roleTags.map((role) => (
                          <Badge key={role} variant="outline">
                            {roleLabel(role)}
                          </Badge>
                        ))}
                      </div>
                      {item.description && (
                        <div className="max-w-3xl text-sm text-muted-foreground">{item.description}</div>
                      )}
                      {item.videoUrl && (
                        <a
                          href={item.videoUrl}
                          target="_blank"
                          rel="noreferrer"
                          className="inline-flex items-center gap-2 text-sm font-medium text-primary hover:underline"
                        >
                          Watch clip
                          <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13.5 4.5H19.5V10.5M10.5 13.5L19.5 4.5M5.25 5.25H9.75M5.25 9.75H9.75M5.25 14.25H12.75" />
                          </svg>
                        </a>
                      )}
                    </div>
                    <RowActions
                      onEdit={() => {
                        setEditingDrill(item);
                        setDrillDialogOpen(true);
                      }}
                      onDelete={() =>
                        void withBusy(`drill-delete-${item.id}`, async () => {
                          await adminApi.deleteDrill(item.id);
                          await loadAll();
                        })
                      }
                      deleting={busyKey === `drill-delete-${item.id}`}
                    />
                  </div>
                ))}
              </div>
            )}
          </CardShell>
        </TabsContent>
      </Tabs>

      <SessionTypeDialog
        open={sessionTypeDialogOpen}
        onOpenChange={(open) => {
          setSessionTypeDialogOpen(open);
          if (!open) setEditingSessionType(null);
        }}
        initial={editingSessionType}
        onSubmit={saveSessionType}
        saving={busyKey?.startsWith("session-type") ?? false}
      />
      <SkillAreaDialog
        open={skillAreaDialogOpen}
        onOpenChange={(open) => {
          setSkillAreaDialogOpen(open);
          if (!open) setEditingSkillArea(null);
        }}
        initial={editingSkillArea}
        onSubmit={saveSkillArea}
        saving={busyKey?.startsWith("skill-area") ?? false}
      />
      <WatchFlagDialog
        open={watchFlagDialogOpen}
        onOpenChange={(open) => {
          setWatchFlagDialogOpen(open);
          if (!open) setEditingWatchFlag(null);
        }}
        initial={editingWatchFlag}
        onSubmit={saveWatchFlag}
        saving={busyKey?.startsWith("watch-flag") ?? false}
      />
      <DrillDialog
        open={drillDialogOpen}
        onOpenChange={(open) => {
          setDrillDialogOpen(open);
          if (!open) setEditingDrill(null);
        }}
        initial={editingDrill}
        onSubmit={saveDrill}
        saving={busyKey?.startsWith("drill") ?? false}
      />
    </div>
  );
}
