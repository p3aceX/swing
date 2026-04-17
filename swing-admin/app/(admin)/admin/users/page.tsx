"use client";

import { useEffect, useMemo, useState } from "react";
import { useSearchParams } from "next/navigation";
import type { ColumnDef } from "@tanstack/react-table";
import { Avatar } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
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
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet";
import { Switch } from "@/components/ui/switch";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Textarea } from "@/components/ui/textarea";
import { DataTable } from "@/components/admin/data-table";
import { FilterBar } from "@/components/admin/filter-bar";
import { PageHeader } from "@/components/admin/page-header";
import { PaginationBar } from "@/components/admin/pagination-bar";
import type {
  CoachProfileUpdate,
  CreateUserBody,
  ManagedProfileType,
  PlayerProfileUpdate,
  UserDetail,
  UserRecord,
  UserRole,
} from "@/lib/api";
import {
  useBlockUserMutation,
  useCreateUserMutation,
  useCreateUserProfileMutation,
  useDeleteUserProfileMutation,
  useRoleMutation,
  useUnblockUserMutation,
  useUpdateArenaOwnerMutation,
  useUpdateCoachMutation,
  useUpdatePlayerMutation,
  useUpdateUserMutation,
  useUserDetailQuery,
  useUsersQuery,
} from "@/lib/queries";
import {
  formatCurrencyInr,
  formatDate,
  paiseToInr,
  timeAgo,
} from "@/lib/utils";

const ROLE_OPTIONS: UserRole[] = [
  "PLAYER",
  "COACH",
  "ACADEMY_OWNER",
  "ARENA_OWNER",
  "PARENT",
  "SWING_ADMIN",
  "SWING_SUPPORT",
];

const PROFILE_OPTIONS: ManagedProfileType[] = [
  "PLAYER",
  "COACH",
  "ACADEMY_OWNER",
  "ARENA_OWNER",
];

const PLAYER_LEVELS = [
  "BEGINNER",
  "CLUB",
  "CORPORATE",
  "ACADEMY",
  "DISTRICT",
  "STATE",
  "NATIONAL",
] as const;
const PLAYER_ROLES = [
  "BATSMAN",
  "BOWLER",
  "ALL_ROUNDER",
  "WICKET_KEEPER",
  "WICKET_KEEPER_BATSMAN",
] as const;
const BATTING_STYLES = [
  { value: "RIGHT_HAND", label: "Right Handed" },
  { value: "LEFT_HAND",  label: "Left Handed" },
] as const;
const BOWLING_STYLES = [
  { value: "RIGHT_ARM_FAST",     label: "Right Arm Fast" },
  { value: "RIGHT_ARM_MEDIUM",   label: "Right Arm Medium" },
  { value: "RIGHT_ARM_OFFBREAK", label: "Right Arm Off Break" },
  { value: "RIGHT_ARM_LEGBREAK", label: "Right Arm Leg Break" },
  { value: "LEFT_ARM_FAST",      label: "Left Arm Fast" },
  { value: "LEFT_ARM_MEDIUM",    label: "Left Arm Medium" },
  { value: "LEFT_ARM_ORTHODOX",  label: "Left Arm Orthodox" },
  { value: "LEFT_ARM_CHINAMAN",  label: "Left Arm Chinaman" },
  { value: "NOT_A_BOWLER",       label: "Not a Bowler" },
] as const;
const VERIFICATION_LEVELS = [
  "UNVERIFIED",
  "LEVEL_1",
  "LEVEL_2",
  "LEVEL_3",
] as const;

function sanitizePhone(value: string) {
  return value.replace(/\D/g, "").slice(0, 10);
}

function toggleValue<T extends string>(current: T[], value: T) {
  return current.includes(value)
    ? current.filter((item) => item !== value)
    : [...current, value];
}

function renderEmpty(message: string) {
  return <div className="text-sm text-muted-foreground">{message}</div>;
}

function formatPaise(amount?: number | null) {
  return formatCurrencyInr(paiseToInr(amount ?? 0));
}

function CreateUserDialog() {
  const mutation = useCreateUserMutation();
  const [open, setOpen] = useState(false);
  const [form, setForm] = useState<CreateUserBody>({
    name: "",
    phone: "",
    email: "",
    roles: ["PLAYER"],
    activeRole: "PLAYER",
    isVerified: false,
    isActive: true,
    createProfiles: ["PLAYER"],
    playerProfile: {},
    coachProfile: { specializations: [] },
    arenaOwnerProfile: {},
  });

  useEffect(() => {
    if (!form.roles.includes(form.activeRole ?? "PLAYER")) {
      setForm((current) => ({
        ...current,
        activeRole: current.roles[0] ?? "PLAYER",
      }));
    }
  }, [form.roles, form.activeRole]);

  const toggleRole = (role: UserRole) => {
    setForm((current) => {
      const roles = toggleValue(current.roles, role);
      const createProfiles = PROFILE_OPTIONS.includes(
        role as ManagedProfileType,
      )
        ? current.createProfiles
          ? toggleValue(current.createProfiles, role as ManagedProfileType)
          : [role as ManagedProfileType]
        : current.createProfiles;
      return {
        ...current,
        roles: roles.length ? roles : ["PLAYER"],
        activeRole: roles.includes(current.activeRole ?? "PLAYER")
          ? current.activeRole
          : (roles[0] ?? "PLAYER"),
        createProfiles,
      };
    });
  };

  const toggleProfile = (type: ManagedProfileType) => {
    setForm((current) => ({
      ...current,
      createProfiles: current.createProfiles?.includes(type)
        ? current.createProfiles.filter((item) => item !== type)
        : [...(current.createProfiles ?? []), type],
    }));
  };

  const reset = () =>
    setForm({
      name: "",
      phone: "",
      email: "",
      roles: ["PLAYER"],
      activeRole: "PLAYER",
      isVerified: false,
      isActive: true,
      createProfiles: ["PLAYER"],
      playerProfile: {},
      coachProfile: { specializations: [] },
      arenaOwnerProfile: {},
    });

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button>Add User</Button>
      </DialogTrigger>
      <DialogContent className="max-h-[90vh] w-[calc(100%-2rem)] max-w-3xl overflow-y-auto">
        <DialogHeader>
          <DialogTitle>Add User</DialogTitle>
          <DialogDescription>
            Create a platform user and optionally create role-specific profiles
            immediately.
          </DialogDescription>
        </DialogHeader>

        <div className="grid gap-6 py-2">
          <Card>
            <CardHeader>
              <CardTitle className="text-base">Core Details</CardTitle>
            </CardHeader>
            <CardContent className="grid gap-4 md:grid-cols-2">
              <Field label="Name">
                <Input
                  value={form.name}
                  onChange={(e) =>
                    setForm((c) => ({ ...c, name: e.target.value }))
                  }
                  placeholder="Player name"
                />
              </Field>
              <Field label="Phone">
                <Input
                  value={form.phone}
                  onChange={(e) =>
                    setForm((c) => ({
                      ...c,
                      phone: sanitizePhone(e.target.value),
                    }))
                  }
                  placeholder="10 digit mobile number"
                  inputMode="numeric"
                  maxLength={10}
                />
              </Field>
              <Field label="Email">
                <Input
                  value={form.email ?? ""}
                  onChange={(e) =>
                    setForm((c) => ({ ...c, email: e.target.value }))
                  }
                  placeholder="Optional"
                />
              </Field>
              <Field label="Active Role">
                <Select
                  value={form.activeRole}
                  onValueChange={(value) =>
                    setForm((c) => ({ ...c, activeRole: value as UserRole }))
                  }
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Select active role" />
                  </SelectTrigger>
                  <SelectContent>
                    {form.roles.map((role) => (
                      <SelectItem key={role} value={role}>
                        {role}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </Field>
              <ToggleRow
                label="Verified"
                description="Mark this user as verified"
                checked={Boolean(form.isVerified)}
                onCheckedChange={(checked) =>
                  setForm((c) => ({ ...c, isVerified: checked }))
                }
              />
              <ToggleRow
                label="Active"
                description="Inactive users remain in DB but should not be treated as live"
                checked={Boolean(form.isActive)}
                onCheckedChange={(checked) =>
                  setForm((c) => ({ ...c, isActive: checked }))
                }
              />
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle className="text-base">Roles</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <RolePicker values={form.roles} onToggle={toggleRole} />
              <div className="space-y-2">
                <Label>Create Profiles</Label>
                <div className="flex flex-wrap gap-2">
                  {PROFILE_OPTIONS.map((profile) => (
                    <Button
                      key={profile}
                      type="button"
                      variant={
                        form.createProfiles?.includes(profile)
                          ? "default"
                          : "outline"
                      }
                      onClick={() => toggleProfile(profile)}
                    >
                      {profile.replaceAll("_", " ")}
                    </Button>
                  ))}
                </div>
              </div>
            </CardContent>
          </Card>

          {form.createProfiles?.includes("PLAYER") && (
            <Card>
              <CardHeader>
                <CardTitle className="text-base">Player Profile Seed</CardTitle>
              </CardHeader>
              <CardContent className="grid gap-4 md:grid-cols-2">
                <Field label="City">
                  <Input
                    value={form.playerProfile?.city ?? ""}
                    onChange={(e) =>
                      setForm((c) => ({
                        ...c,
                        playerProfile: {
                          ...c.playerProfile,
                          city: e.target.value,
                        },
                      }))
                    }
                  />
                </Field>
                <Field label="State">
                  <Input
                    value={form.playerProfile?.state ?? ""}
                    onChange={(e) =>
                      setForm((c) => ({
                        ...c,
                        playerProfile: {
                          ...c.playerProfile,
                          state: e.target.value,
                        },
                      }))
                    }
                  />
                </Field>
                <Field label="Level">
                  <Select
                    value={form.playerProfile?.level ?? ""}
                    onValueChange={(value) =>
                      setForm((c) => ({
                        ...c,
                        playerProfile: { ...c.playerProfile, level: value },
                      }))
                    }
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Select level" />
                    </SelectTrigger>
                    <SelectContent>
                      {PLAYER_LEVELS.map((level) => (
                        <SelectItem key={level} value={level}>
                          {level}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </Field>
                <Field label="Player Role">
                  <Select
                    value={form.playerProfile?.playerRole ?? ""}
                    onValueChange={(value) =>
                      setForm((c) => ({
                        ...c,
                        playerProfile: { ...c.playerProfile, playerRole: value },
                      }))
                    }
                  >
                    <SelectTrigger><SelectValue placeholder="Select role" /></SelectTrigger>
                    <SelectContent>
                      {PLAYER_ROLES.map((role) => (
                        <SelectItem key={role} value={role}>{role.replaceAll("_", " ")}</SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </Field>
                <Field label="Batting Hand">
                  <Select
                    value={form.playerProfile?.battingStyle ?? ""}
                    onValueChange={(value) =>
                      setForm((c) => ({
                        ...c,
                        playerProfile: { ...c.playerProfile, battingStyle: value },
                      }))
                    }
                  >
                    <SelectTrigger><SelectValue placeholder="Select" /></SelectTrigger>
                    <SelectContent>
                      {BATTING_STYLES.map((s) => (
                        <SelectItem key={s.value} value={s.value}>{s.label}</SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </Field>
                <Field label="Bowling Type">
                  <Select
                    value={form.playerProfile?.bowlingStyle ?? ""}
                    onValueChange={(value) =>
                      setForm((c) => ({
                        ...c,
                        playerProfile: { ...c.playerProfile, bowlingStyle: value },
                      }))
                    }
                  >
                    <SelectTrigger><SelectValue placeholder="Select" /></SelectTrigger>
                    <SelectContent>
                      {BOWLING_STYLES.map((s) => (
                        <SelectItem key={s.value} value={s.value}>{s.label}</SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </Field>
                <Field label="Date of Birth">
                  <Input
                    type="date"
                    value={form.playerProfile?.dateOfBirth ?? ""}
                    onChange={(e) =>
                      setForm((c) => ({
                        ...c,
                        playerProfile: { ...c.playerProfile, dateOfBirth: e.target.value },
                      }))
                    }
                  />
                </Field>
                <Field label="Jersey Number">
                  <Input
                    type="number"
                    placeholder="e.g. 18"
                    value={form.playerProfile?.jerseyNumber ?? ""}
                    onChange={(e) =>
                      setForm((c) => ({
                        ...c,
                        playerProfile: { ...c.playerProfile, jerseyNumber: Number(e.target.value) || undefined },
                      }))
                    }
                  />
                </Field>
                <Field label="Bio" className="md:col-span-2">
                  <Textarea
                    value={form.playerProfile?.bio ?? ""}
                    onChange={(e) =>
                      setForm((c) => ({
                        ...c,
                        playerProfile: { ...c.playerProfile, bio: e.target.value },
                      }))
                    }
                    className="min-h-[90px]"
                  />
                </Field>
              </CardContent>
            </Card>
          )}

          {form.createProfiles?.includes("COACH") && (
            <Card>
              <CardHeader>
                <CardTitle className="text-base">Coach Profile Seed</CardTitle>
              </CardHeader>
              <CardContent className="grid gap-4 md:grid-cols-2">
                <Field label="City">
                  <Input
                    value={form.coachProfile?.city ?? ""}
                    onChange={(e) =>
                      setForm((c) => ({
                        ...c,
                        coachProfile: {
                          ...c.coachProfile,
                          city: e.target.value,
                        },
                      }))
                    }
                  />
                </Field>
                <Field label="State">
                  <Input
                    value={form.coachProfile?.state ?? ""}
                    onChange={(e) =>
                      setForm((c) => ({
                        ...c,
                        coachProfile: {
                          ...c.coachProfile,
                          state: e.target.value,
                        },
                      }))
                    }
                  />
                </Field>
                <Field label="Experience (years)">
                  <Input
                    type="number"
                    value={form.coachProfile?.experienceYears ?? 0}
                    onChange={(e) =>
                      setForm((c) => ({
                        ...c,
                        coachProfile: {
                          ...c.coachProfile,
                          experienceYears: Number(e.target.value || 0),
                        },
                      }))
                    }
                  />
                </Field>
                <Field label="Specializations">
                  <Input
                    value={(form.coachProfile?.specializations ?? []).join(
                      ", ",
                    )}
                    onChange={(e) =>
                      setForm((c) => ({
                        ...c,
                        coachProfile: {
                          ...c.coachProfile,
                          specializations: e.target.value
                            .split(",")
                            .map((item) => item.trim())
                            .filter(Boolean),
                        },
                      }))
                    }
                    placeholder="Batting, Bowling"
                  />
                </Field>
                <Field label="Bio" className="md:col-span-2">
                  <Textarea
                    value={form.coachProfile?.bio ?? ""}
                    onChange={(e) =>
                      setForm((c) => ({
                        ...c,
                        coachProfile: {
                          ...c.coachProfile,
                          bio: e.target.value,
                        },
                      }))
                    }
                    className="min-h-[90px]"
                  />
                </Field>
              </CardContent>
            </Card>
          )}

          {form.createProfiles?.includes("ARENA_OWNER") && (
            <Card>
              <CardHeader>
                <CardTitle className="text-base">
                  Arena Owner Profile Seed
                </CardTitle>
              </CardHeader>
              <CardContent className="grid gap-4 md:grid-cols-2">
                <Field label="Business Name">
                  <Input
                    value={form.arenaOwnerProfile?.businessName ?? ""}
                    onChange={(e) =>
                      setForm((c) => ({
                        ...c,
                        arenaOwnerProfile: {
                          ...c.arenaOwnerProfile,
                          businessName: e.target.value,
                        },
                      }))
                    }
                  />
                </Field>
                <Field label="GST Number">
                  <Input
                    value={form.arenaOwnerProfile?.gstNumber ?? ""}
                    onChange={(e) =>
                      setForm((c) => ({
                        ...c,
                        arenaOwnerProfile: {
                          ...c.arenaOwnerProfile,
                          gstNumber: e.target.value,
                        },
                      }))
                    }
                  />
                </Field>
                <Field label="PAN Number">
                  <Input
                    value={form.arenaOwnerProfile?.panNumber ?? ""}
                    onChange={(e) =>
                      setForm((c) => ({
                        ...c,
                        arenaOwnerProfile: {
                          ...c.arenaOwnerProfile,
                          panNumber: e.target.value,
                        },
                      }))
                    }
                  />
                </Field>
              </CardContent>
            </Card>
          )}
        </div>

        <DialogFooter>
          <Button
            variant="outline"
            onClick={() => {
              setOpen(false);
              reset();
            }}
          >
            Cancel
          </Button>
          <Button
            disabled={
              !form.name.trim() ||
              form.phone.trim().length !== 10 ||
              mutation.isPending
            }
            onClick={() =>
              mutation.mutate(form, {
                onSuccess: () => {
                  setOpen(false);
                  reset();
                },
              })
            }
          >
            {mutation.isPending ? "Creating..." : "Create User"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

function UsersPageHeader() {
  return (
    <PageHeader
      title="Users"
      description="Create users, manage role profiles, and inspect all user-linked platform activity from one admin surface."
      action={<CreateUserDialog />}
    />
  );
}

function UserActions({ user }: { user: UserRecord }) {
  const [open, setOpen] = useState(false);
  const detail = useUserDetailQuery(open ? user.id : null);
  const unblockMutation = useUnblockUserMutation();
  const blockMutation = useBlockUserMutation();

  return (
    <div className="flex gap-2">
      <Sheet open={open} onOpenChange={setOpen}>
        <SheetTrigger asChild>
          <Button variant="outline" size="sm">
            View
          </Button>
        </SheetTrigger>
        <SheetContent className="max-h-[92vh] max-w-6xl overflow-y-auto">
          <SheetHeader>
            <SheetTitle>User Detail</SheetTitle>
          </SheetHeader>
          <div className="mt-6">
            {detail.isLoading && (
              <div className="text-sm text-muted-foreground">
                Loading user detail...
              </div>
            )}
            {detail.isError && (
              <div className="rounded-xl border border-destructive bg-destructive/10 p-4 text-sm text-destructive">
                Failed to load user detail: {(detail.error as Error).message}
              </div>
            )}
            {detail.data && <UserDetailPanel data={detail.data} />}
          </div>
        </SheetContent>
      </Sheet>
      {user.isBlocked ? (
        <Button
          size="sm"
          variant="success"
          onClick={() => unblockMutation.mutate(user.id)}
        >
          Unban
        </Button>
      ) : (
        <BlockUserDialog
          onConfirm={(reason) => blockMutation.mutate({ id: user.id, reason })}
          loading={blockMutation.isPending}
        />
      )}
    </div>
  );
}

function UserDetailPanel({ data }: { data: UserDetail }) {
  const roleMutation = useRoleMutation("grant");
  const revokeMutation = useRoleMutation("revoke");
  const createProfileMutation = useCreateUserProfileMutation();
  const deleteProfileMutation = useDeleteUserProfileMutation();

  const playerProfile = data.playerProfile as
    | (Record<string, unknown> & { id: string })
    | undefined;
  const coachProfile = data.coachProfile as
    | (Record<string, unknown> & { id: string })
    | undefined;
  const arenaOwnerProfile = data.arenaOwnerProfile as
    | (Record<string, unknown> & { id: string })
    | undefined;
  const academyOwnerProfile = data.academyOwnerProfile as
    | (Record<string, unknown> & { id: string })
    | undefined;

  const profileState: Array<{ type: ManagedProfileType; present: boolean }> = [
    { type: "PLAYER", present: Boolean(playerProfile) },
    { type: "COACH", present: Boolean(coachProfile) },
    { type: "ACADEMY_OWNER", present: Boolean(academyOwnerProfile) },
    { type: "ARENA_OWNER", present: Boolean(arenaOwnerProfile) },
  ];
  const playerSummary = data.playerSummary;
  const academyEnrollments =
    playerProfile &&
    Array.isArray(playerProfile.academyEnrollments) &&
    playerProfile.academyEnrollments.length
      ? playerProfile.academyEnrollments
      : [];

  return (
    <div className="space-y-6">
      <div className="grid gap-4 xl:grid-cols-[1.2fr_1fr]">
        <CoreUserEditor data={data} />
        <Card>
          <CardHeader>
            <CardTitle className="text-base">Role Controls</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex flex-wrap gap-2">
              {data.roles.map((role) => (
                <Badge
                  key={role}
                  variant={role === data.activeRole ? "success" : "outline"}
                >
                  {role}
                </Badge>
              ))}
            </div>
            <div className="grid gap-3 md:grid-cols-2">
              <Field label="Grant Role">
                <Select
                  onValueChange={(value) =>
                    roleMutation.mutate({ id: data.id, role: value })
                  }
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Grant role" />
                  </SelectTrigger>
                  <SelectContent>
                    {ROLE_OPTIONS.map((role) => (
                      <SelectItem key={role} value={role}>
                        {role}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </Field>
              <Field label="Revoke Role">
                <Select
                  onValueChange={(value) =>
                    revokeMutation.mutate({ id: data.id, role: value })
                  }
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Revoke role" />
                  </SelectTrigger>
                  <SelectContent>
                    {data.roles.map((role) => (
                      <SelectItem key={role} value={role}>
                        {role}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </Field>
            </div>
          </CardContent>
        </Card>
      </div>

      <Tabs defaultValue="overview" className="w-full">
        <TabsList className="grid w-full grid-cols-4">
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="profiles">Profiles</TabsTrigger>
          <TabsTrigger value="activity">Activity</TabsTrigger>
          <TabsTrigger value="support">Support</TabsTrigger>
        </TabsList>

        <TabsContent value="overview" className="space-y-4">
          <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-5">
            <MetricCard
              label="Player Matches"
              value={String(
                playerSummary?.matchCount ?? data.counts?.totalMatches ?? 0,
              )}
            />
            <MetricCard
              label="Tournaments"
              value={String(
                playerSummary?.tournamentCount ?? data.counts?.tournaments ?? 0,
              )}
            />
            <MetricCard
              label="Academies"
              value={String(
                playerSummary?.academyCount ??
                  data.counts?.activeAcademyEnrollments ??
                  0,
              )}
            />
            <MetricCard
              label="Payments"
              value={String(data.counts?.payments ?? 0)}
            />
            <MetricCard
              label="Tickets"
              value={String(data.counts?.supportTickets ?? 0)}
            />
          </div>
          {playerSummary ? (
            <Card>
              <CardHeader>
                <CardTitle className="text-base">Player Summary</CardTitle>
              </CardHeader>
              <CardContent className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
                <StatCell
                  label="Swing"
                  value={`${playerSummary.swingIndex.toFixed(1)} • ${playerSummary.swingRank}`}
                />
                <StatCell
                  label="XP"
                  value={`${playerSummary.totalXp} total • ${playerSummary.rankXp} rank XP`}
                />
                <StatCell
                  label="Wins"
                  value={`${playerSummary.matchesWon}/${playerSummary.matchesPlayed} • ${playerSummary.matchWinPct}%`}
                />
                <StatCell
                  label="Runs"
                  value={`${playerSummary.totalRuns} • HS ${playerSummary.highestScore}`}
                />
                <StatCell
                  label="Bat Avg / SR"
                  value={`${playerSummary.battingAverage.toFixed(1)} / ${playerSummary.strikeRate.toFixed(1)}`}
                />
                <StatCell
                  label="Boundaries"
                  value={`4s ${playerSummary.fours} • 6s ${playerSummary.sixes}`}
                />
                <StatCell
                  label="Wickets"
                  value={`${playerSummary.totalWickets} • Econ ${playerSummary.economyRate.toFixed(1)}`}
                />
                <StatCell
                  label="Fielding"
                  value={`C ${playerSummary.catches} • St ${playerSummary.stumpings} • RO ${playerSummary.runOuts}`}
                />
              </CardContent>
            </Card>
          ) : null}
          <div className="grid gap-4 xl:grid-cols-2">
            <Card>
              <CardHeader>
                <CardTitle className="text-base">Recent Payments</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3 text-sm">
                {data.payments?.length
                  ? data.payments.map((payment) => (
                      <ItemRow
                        key={payment.id}
                        title={`${payment.entityType ?? "PAYMENT"} • ${formatPaise(payment.amountPaise)}`}
                        description={`${payment.status} • ${formatDate(payment.createdAt, "dd MMM yyyy, hh:mm a")}`}
                        meta={payment.description ?? payment.id}
                      />
                    ))
                  : renderEmpty("No payments linked to this user yet.")}
              </CardContent>
            </Card>
            <Card>
              <CardHeader>
                <CardTitle className="text-base">
                  Recent Notifications
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-3 text-sm">
                {data.notifications?.length
                  ? data.notifications.map((notification) => (
                      <ItemRow
                        key={notification.id}
                        title={notification.title || notification.type}
                        description={notification.body}
                        meta={`${notification.status} • ${timeAgo(notification.createdAt)}`}
                      />
                    ))
                  : renderEmpty("No notifications found.")}
              </CardContent>
            </Card>
          </div>
          <div className="grid gap-4 xl:grid-cols-2">
            <Card>
              <CardHeader>
                <CardTitle className="text-base">
                  Academy Associations
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-3 text-sm">
                {academyEnrollments.length
                  ? academyEnrollments.map((enrollment) => {
                      const item = enrollment as {
                        id: string;
                        isActive?: boolean;
                        feeStatus?: string;
                        enrolledAt: string;
                        academy?: {
                          name?: string;
                          city?: string | null;
                          state?: string | null;
                          isVerified?: boolean;
                        };
                        batch?: { name?: string } | null;
                      };
                      return (
                        <ItemRow
                          key={item.id}
                          title={`${item.academy?.name ?? "Academy"}${item.isActive ? " • Active" : ""}`}
                          description={`${item.batch?.name ?? "No batch"} • ${item.feeStatus ?? "NA"} • ${item.academy?.city ?? "-"}, ${item.academy?.state ?? "-"}`}
                          meta={`${item.academy?.isVerified ? "Verified" : "Unverified"} • Enrolled ${formatDate(item.enrolledAt)}`}
                        />
                      );
                    })
                  : renderEmpty("No academy associations found.")}
              </CardContent>
            </Card>
            <Card>
              <CardHeader>
                <CardTitle className="text-base">
                  Tournament Participation
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-3 text-sm">
                {data.tournamentEntries?.length
                  ? data.tournamentEntries.map((entry) => (
                      <ItemRow
                        key={entry.id}
                        title={`${entry.tournament.name} • ${entry.teamName}`}
                        description={`${entry.tournament.status} • ${entry.tournament.format}${entry.group?.name ? ` • ${entry.group.name}` : ""}`}
                        meta={`${entry.standing ? `P${entry.standing.position} • ${entry.standing.points} pts • ${entry.standing.played} played` : "Standing not available"}${entry.tournament.academy?.name ? ` • ${entry.tournament.academy.name}` : ""}`}
                      />
                    ))
                  : renderEmpty("No tournaments found for this player.")}
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="profiles" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle className="text-base">Profile Lifecycle</CardTitle>
            </CardHeader>
            <CardContent className="grid gap-3 md:grid-cols-2 xl:grid-cols-4">
              {profileState.map((profile) => (
                <Card key={profile.type} className="border-dashed">
                  <CardContent className="space-y-3 p-4">
                    <div className="flex items-center justify-between">
                      <div className="font-medium">
                        {profile.type.replaceAll("_", " ")}
                      </div>
                      <Badge variant={profile.present ? "success" : "outline"}>
                        {profile.present ? "Present" : "Missing"}
                      </Badge>
                    </div>
                    <div className="text-xs text-muted-foreground">
                      {profile.present
                        ? "Profile exists and can be edited below."
                        : "Create the missing profile and attach it to this user."}
                    </div>
                    {profile.present ? (
                      <Button
                        size="sm"
                        variant="destructive"
                        disabled={deleteProfileMutation.isPending}
                        onClick={() =>
                          deleteProfileMutation.mutate({
                            id: data.id,
                            type: profile.type,
                          })
                        }
                      >
                        Delete Profile
                      </Button>
                    ) : (
                      <Button
                        size="sm"
                        disabled={createProfileMutation.isPending}
                        onClick={() =>
                          createProfileMutation.mutate({
                            id: data.id,
                            type: profile.type,
                          })
                        }
                      >
                        Create Profile
                      </Button>
                    )}
                  </CardContent>
                </Card>
              ))}
            </CardContent>
          </Card>

          <div className="grid gap-4">
            {playerProfile && <PlayerProfileEditor profile={playerProfile} />}
            {coachProfile && <CoachProfileEditor profile={coachProfile} />}
            {arenaOwnerProfile && (
              <ArenaOwnerProfileEditor profile={arenaOwnerProfile} />
            )}

            {academyOwnerProfile && (
              <Card>
                <CardHeader>
                  <CardTitle className="text-base">
                    Academy Owner Profile
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-3 text-sm">
                  {Array.isArray(
                    (academyOwnerProfile as { academies?: unknown[] })
                      .academies,
                  ) &&
                  (
                    academyOwnerProfile as {
                      academies?: Array<Record<string, unknown>>;
                    }
                  ).academies?.length
                    ? (
                        academyOwnerProfile as {
                          academies?: Array<Record<string, unknown>>;
                        }
                      ).academies!.map((academy) => (
                        <ItemRow
                          key={String(academy.id)}
                          title={String(academy.name ?? "Academy")}
                          description={`${academy.city ?? "-"}, ${academy.state ?? "-"} • ${academy.planTier ?? "FREE"}`}
                          meta={`Students ${String((academy._count as { enrollments?: number } | undefined)?.enrollments ?? 0)} • Batches ${String((academy._count as { batches?: number } | undefined)?.batches ?? 0)}`}
                        />
                      ))
                    : renderEmpty("No academies owned yet.")}
                </CardContent>
              </Card>
            )}
          </div>
        </TabsContent>

        <TabsContent value="activity" className="space-y-4">
          <div className="grid gap-4 xl:grid-cols-2">
            <Card>
              <CardHeader>
                <CardTitle className="text-base">Player Badges</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3 text-sm">
                {playerProfile &&
                Array.isArray(playerProfile.playerBadges) &&
                playerProfile.playerBadges.length
                  ? playerProfile.playerBadges.map((badge) => (
                      <ItemRow
                        key={String((badge as { id: string }).id)}
                        title={String(
                          (badge as { badge?: { name?: string } }).badge
                            ?.name ?? "Badge",
                        )}
                        description={`${(badge as { badge?: { category?: string } }).badge?.category ?? "Badge"} • ${(badge as { awardedReason?: string | null }).awardedReason ?? "Awarded"}`}
                        meta={formatDate(
                          String((badge as { awardedAt: string }).awardedAt),
                        )}
                      />
                    ))
                  : renderEmpty("No badges awarded.")}
              </CardContent>
            </Card>
            <Card>
              <CardHeader>
                <CardTitle className="text-base">XP Transactions</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3 text-sm">
                {playerProfile &&
                Array.isArray(playerProfile.xpTransactions) &&
                playerProfile.xpTransactions.length
                  ? playerProfile.xpTransactions.map((txn) => (
                      <ItemRow
                        key={String((txn as { id: string }).id)}
                        title={`${Number((txn as { xpDelta: number }).xpDelta) >= 0 ? "+" : ""}${String((txn as { xpDelta: number }).xpDelta)} XP`}
                        description={String((txn as { reason: string }).reason)}
                        meta={`${formatDate(String((txn as { createdAt: string }).createdAt), "dd MMM yyyy, hh:mm a")} • Balance ${String((txn as { balanceAfter: number }).balanceAfter)}`}
                      />
                    ))
                  : renderEmpty("No XP transactions found.")}
              </CardContent>
            </Card>
          </div>

          <div className="grid gap-4 xl:grid-cols-2">
            <Card>
              <CardHeader>
                <CardTitle className="text-base">Bookings</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3 text-sm">
                {playerProfile &&
                Array.isArray(playerProfile.slotBookings) &&
                playerProfile.slotBookings.length
                  ? playerProfile.slotBookings.map((booking) => (
                      <ItemRow
                        key={String((booking as { id: string }).id)}
                        title={`${(booking as { arena?: { name?: string } }).arena?.name ?? "Arena"} • ${formatPaise(Number((booking as { totalAmountPaise: number }).totalAmountPaise ?? 0))}`}
                        description={`${(booking as { status: string }).status} • ${formatDate(String((booking as { date: string }).date))} • ${String((booking as { startTime: string }).startTime)}-${String((booking as { endTime: string }).endTime)}`}
                        meta={String(
                          (booking as { unit?: { name?: string } }).unit
                            ?.name ?? "",
                        )}
                      />
                    ))
                  : playerProfile &&
                      Array.isArray(playerProfile.gigBookings) &&
                      playerProfile.gigBookings.length
                    ? playerProfile.gigBookings.map((booking) => (
                        <ItemRow
                          key={String((booking as { id: string }).id)}
                          title={String(
                            (booking as { gigListing?: { title?: string } })
                              .gigListing?.title ?? "Gig",
                          )}
                          description={`${(booking as { status: string }).status} • ${formatPaise(Number((booking as { amountPaise: number }).amountPaise ?? 0))}`}
                          meta={formatDate(
                            String(
                              (booking as { scheduledAt: string }).scheduledAt,
                            ),
                            "dd MMM yyyy, hh:mm a",
                          )}
                        />
                      ))
                    : renderEmpty("No slot or gig bookings found.")}
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="text-base">Recent Matches</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3 text-sm">
                {data.recentMatches?.length
                  ? data.recentMatches.map((match) => (
                      <ItemRow
                        key={match.id}
                        title={`${match.teamAName} vs ${match.teamBName}`}
                        description={`${match.matchType} • ${match.format} • ${match.status}`}
                        meta={formatDate(
                          match.createdAt,
                          "dd MMM yyyy, hh:mm a",
                        )}
                      />
                    ))
                  : renderEmpty("No recent matches tied to this user.")}
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="support" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle className="text-base">Support Tickets</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4 text-sm">
              {data.supportTickets?.length
                ? data.supportTickets.map((ticket) => (
                    <div key={ticket.id} className="rounded-lg border p-4">
                      <div className="flex flex-wrap items-center justify-between gap-2">
                        <div className="font-medium">{ticket.subject}</div>
                        <div className="flex gap-2">
                          <Badge variant="outline">{ticket.category}</Badge>
                          <Badge
                            variant={
                              ticket.status === "RESOLVED" ||
                              ticket.status === "CLOSED"
                                ? "success"
                                : "outline"
                            }
                          >
                            {ticket.status}
                          </Badge>
                        </div>
                      </div>
                      <div className="mt-2 text-muted-foreground">
                        {ticket.description}
                      </div>
                      <div className="mt-2 text-xs text-muted-foreground">
                        {ticket.priority} priority • Updated{" "}
                        {timeAgo(ticket.updatedAt)}
                      </div>
                      {ticket.messages.length ? (
                        <div className="mt-3 space-y-2 border-t pt-3">
                          {ticket.messages.map((message) => (
                            <div
                              key={message.id}
                              className="rounded-md bg-muted/40 p-2"
                            >
                              <div className="text-xs text-muted-foreground">
                                {message.isFromSupport ? "Support" : "User"} •{" "}
                                {formatDate(
                                  message.createdAt,
                                  "dd MMM yyyy, hh:mm a",
                                )}
                              </div>
                              <div>{message.message}</div>
                            </div>
                          ))}
                        </div>
                      ) : null}
                    </div>
                  ))
                : renderEmpty("No support tickets found for this user.")}
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}

function CoreUserEditor({ data }: { data: UserDetail }) {
  const mutation = useUpdateUserMutation();
  const [form, setForm] = useState({
    name: data.name ?? "",
    phone: data.phone ?? "",
    email: data.email ?? "",
    activeRole: (data.activeRole ?? data.roles[0] ?? "PLAYER") as UserRole,
    isVerified: Boolean(data.isVerified),
    isActive: data.isActive !== false,
    avatarUrl: data.avatarUrl ?? "",
  });

  useEffect(() => {
    setForm({
      name: data.name ?? "",
      phone: data.phone ?? "",
      email: data.email ?? "",
      activeRole: (data.activeRole ?? data.roles[0] ?? "PLAYER") as UserRole,
      isVerified: Boolean(data.isVerified),
      isActive: data.isActive !== false,
      avatarUrl: data.avatarUrl ?? "",
    });
  }, [data]);

  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-base">User Core</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="flex items-center gap-3">
          <Avatar name={data.name} />
          <div>
            <div className="font-medium">{data.name || "Unnamed user"}</div>
            <div className="text-xs text-muted-foreground">
              Joined {formatDate(data.createdAt)} • {data.id}
            </div>
          </div>
        </div>

        <div className="grid gap-4 md:grid-cols-2">
          <Field label="Name">
            <Input
              value={form.name}
              onChange={(e) => setForm((c) => ({ ...c, name: e.target.value }))}
            />
          </Field>
          <Field label="Phone">
            <Input
              value={form.phone}
              onChange={(e) =>
                setForm((c) => ({
                  ...c,
                  phone: sanitizePhone(e.target.value),
                }))
              }
              inputMode="numeric"
              maxLength={10}
            />
          </Field>
          <Field label="Email">
            <Input
              value={form.email}
              onChange={(e) =>
                setForm((c) => ({ ...c, email: e.target.value }))
              }
              placeholder="Optional"
            />
          </Field>
          <Field label="Active Role">
            <Select
              value={form.activeRole}
              onValueChange={(value) =>
                setForm((c) => ({ ...c, activeRole: value as UserRole }))
              }
            >
              <SelectTrigger>
                <SelectValue placeholder="Select role" />
              </SelectTrigger>
              <SelectContent>
                {data.roles.map((role) => (
                  <SelectItem key={role} value={role}>
                    {role}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </Field>
          <Field label="Avatar URL" className="md:col-span-2">
            <Input
              value={form.avatarUrl}
              onChange={(e) =>
                setForm((c) => ({ ...c, avatarUrl: e.target.value }))
              }
              placeholder="Optional image URL"
            />
          </Field>
          <ToggleRow
            label="Verified"
            description="Controls top-level user verification"
            checked={form.isVerified}
            onCheckedChange={(checked) =>
              setForm((c) => ({ ...c, isVerified: checked }))
            }
          />
          <ToggleRow
            label="Active"
            description="Disable to mark the user inactive"
            checked={form.isActive}
            onCheckedChange={(checked) =>
              setForm((c) => ({ ...c, isActive: checked }))
            }
          />
        </div>

        <Button
          disabled={
            mutation.isPending ||
            !form.name.trim() ||
            form.phone.trim().length !== 10
          }
          onClick={() =>
            mutation.mutate({
              id: data.id,
              data: {
                name: form.name.trim(),
                phone: form.phone.trim(),
                email: form.email.trim() || null,
                activeRole: form.activeRole,
                isVerified: form.isVerified,
                isActive: form.isActive,
                avatarUrl: form.avatarUrl.trim() || null,
              },
            })
          }
        >
          {mutation.isPending ? "Saving..." : "Save User"}
        </Button>
      </CardContent>
    </Card>
  );
}

function PlayerProfileEditor({
  profile,
}: {
  profile: Record<string, unknown> & { id: string };
}) {
  const mutation = useUpdatePlayerMutation();
  const [form, setForm] = useState<PlayerProfileUpdate>({
    level: String(profile.level ?? ""),
    playerRole: String(profile.playerRole ?? ""),
    battingStyle: String(profile.battingStyle ?? ""),
    bowlingStyle: String(profile.bowlingStyle ?? ""),
    city: String(profile.city ?? ""),
    state: String(profile.state ?? ""),
    bio: String(profile.bio ?? ""),
    goals: String(profile.goals ?? ""),
    dateOfBirth: profile.dateOfBirth ? String(profile.dateOfBirth).slice(0, 10) : "",
    jerseyNumber: profile.jerseyNumber ? Number(profile.jerseyNumber) : undefined,
    verificationLevel: String(profile.verificationLevel ?? "UNVERIFIED"),
    swingIndex: Number(profile.swingIndex ?? 0),
  });

  useEffect(() => {
    setForm({
      level: String(profile.level ?? ""),
      playerRole: String(profile.playerRole ?? ""),
      battingStyle: String(profile.battingStyle ?? ""),
      bowlingStyle: String(profile.bowlingStyle ?? ""),
      city: String(profile.city ?? ""),
      state: String(profile.state ?? ""),
      bio: String(profile.bio ?? ""),
      goals: String(profile.goals ?? ""),
      dateOfBirth: profile.dateOfBirth ? String(profile.dateOfBirth).slice(0, 10) : "",
      jerseyNumber: profile.jerseyNumber ? Number(profile.jerseyNumber) : undefined,
      verificationLevel: String(profile.verificationLevel ?? "UNVERIFIED"),
      swingIndex: Number(profile.swingIndex ?? 0),
    });
  }, [profile]);

  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-base">Player Profile</CardTitle>
      </CardHeader>
      <CardContent className="grid gap-4 md:grid-cols-2">
        <Field label="Level">
          <Select
            value={form.level}
            onValueChange={(value) => setForm((c) => ({ ...c, level: value }))}
          >
            <SelectTrigger>
              <SelectValue placeholder="Select level" />
            </SelectTrigger>
            <SelectContent>
              {PLAYER_LEVELS.map((level) => (
                <SelectItem key={level} value={level}>
                  {level}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </Field>
        <Field label="Player Role">
          <Select
            value={form.playerRole}
            onValueChange={(value) =>
              setForm((c) => ({ ...c, playerRole: value }))
            }
          >
            <SelectTrigger>
              <SelectValue placeholder="Select role" />
            </SelectTrigger>
            <SelectContent>
              {PLAYER_ROLES.map((role) => (
                <SelectItem key={role} value={role}>
                  {role}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </Field>
        <Field label="Batting Hand">
          <Select
            value={form.battingStyle}
            onValueChange={(value) => setForm((c) => ({ ...c, battingStyle: value }))}
          >
            <SelectTrigger><SelectValue placeholder="Select" /></SelectTrigger>
            <SelectContent>
              {BATTING_STYLES.map((s) => (
                <SelectItem key={s.value} value={s.value}>{s.label}</SelectItem>
              ))}
            </SelectContent>
          </Select>
        </Field>
        <Field label="Bowling Type">
          <Select
            value={form.bowlingStyle}
            onValueChange={(value) => setForm((c) => ({ ...c, bowlingStyle: value }))}
          >
            <SelectTrigger><SelectValue placeholder="Select" /></SelectTrigger>
            <SelectContent>
              {BOWLING_STYLES.map((s) => (
                <SelectItem key={s.value} value={s.value}>{s.label}</SelectItem>
              ))}
            </SelectContent>
          </Select>
        </Field>
        <Field label="Date of Birth">
          <Input
            type="date"
            value={form.dateOfBirth ?? ""}
            onChange={(e) => setForm((c) => ({ ...c, dateOfBirth: e.target.value }))}
          />
        </Field>
        <Field label="Jersey Number">
          <Input
            type="number"
            placeholder="e.g. 18"
            value={form.jerseyNumber ?? ""}
            onChange={(e) => setForm((c) => ({ ...c, jerseyNumber: Number(e.target.value) || undefined }))}
          />
        </Field>
        <Field label="City">
          <Input
            value={form.city ?? ""}
            onChange={(e) => setForm((c) => ({ ...c, city: e.target.value }))}
          />
        </Field>
        <Field label="State">
          <Input
            value={form.state ?? ""}
            onChange={(e) => setForm((c) => ({ ...c, state: e.target.value }))}
          />
        </Field>
        <Field label="Verification Level">
          <Select
            value={form.verificationLevel}
            onValueChange={(value) =>
              setForm((c) => ({ ...c, verificationLevel: value }))
            }
          >
            <SelectTrigger>
              <SelectValue placeholder="Select level" />
            </SelectTrigger>
            <SelectContent>
              {VERIFICATION_LEVELS.map((level) => (
                <SelectItem key={level} value={level}>
                  {level}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </Field>
        <Field label="Swing Index">
          <Input
            type="number"
            value={form.swingIndex ?? 0}
            onChange={(e) =>
              setForm((c) => ({
                ...c,
                swingIndex: Number(e.target.value || 0),
              }))
            }
          />
        </Field>
        <Field label="Goals" className="md:col-span-2">
          <Input
            placeholder="e.g. Play district level cricket"
            value={form.goals ?? ""}
            onChange={(e) => setForm((c) => ({ ...c, goals: e.target.value }))}
          />
        </Field>
        <Field label="Bio" className="md:col-span-2">
          <Textarea
            value={form.bio ?? ""}
            onChange={(e) => setForm((c) => ({ ...c, bio: e.target.value }))}
            className="min-h-[90px]"
          />
        </Field>
        <div className="md:col-span-2">
          <Button
            disabled={mutation.isPending}
            onClick={() => mutation.mutate({ id: profile.id, data: form })}
          >
            {mutation.isPending ? "Saving..." : "Save Player Profile"}
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}

function CoachProfileEditor({
  profile,
}: {
  profile: Record<string, unknown> & { id: string };
}) {
  const mutation = useUpdateCoachMutation();
  const [form, setForm] = useState<CoachProfileUpdate>({
    bio: String(profile.bio ?? ""),
    city: String(profile.city ?? ""),
    state: String(profile.state ?? ""),
    specializations: Array.isArray(profile.specializations)
      ? (profile.specializations as string[])
      : [],
    certifications: Array.isArray(profile.certifications)
      ? (profile.certifications as string[])
      : [],
    experienceYears: Number(profile.experienceYears ?? 0),
    hourlyRate: profile.hourlyRate ? Number(profile.hourlyRate) : null,
    gigEnabled: Boolean(profile.gigEnabled),
    isVerified: Boolean(profile.isVerified),
  });

  useEffect(() => {
    setForm({
      bio: String(profile.bio ?? ""),
      city: String(profile.city ?? ""),
      state: String(profile.state ?? ""),
      specializations: Array.isArray(profile.specializations)
        ? (profile.specializations as string[])
        : [],
      certifications: Array.isArray(profile.certifications)
        ? (profile.certifications as string[])
        : [],
      experienceYears: Number(profile.experienceYears ?? 0),
      hourlyRate: profile.hourlyRate ? Number(profile.hourlyRate) : null,
      gigEnabled: Boolean(profile.gigEnabled),
      isVerified: Boolean(profile.isVerified),
    });
  }, [profile]);

  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-base">Coach Profile</CardTitle>
      </CardHeader>
      <CardContent className="grid gap-4 md:grid-cols-2">
        <Field label="City">
          <Input
            value={form.city ?? ""}
            onChange={(e) => setForm((c) => ({ ...c, city: e.target.value }))}
          />
        </Field>
        <Field label="State">
          <Input
            value={form.state ?? ""}
            onChange={(e) => setForm((c) => ({ ...c, state: e.target.value }))}
          />
        </Field>
        <Field label="Experience Years">
          <Input
            type="number"
            value={form.experienceYears ?? 0}
            onChange={(e) =>
              setForm((c) => ({
                ...c,
                experienceYears: Number(e.target.value || 0),
              }))
            }
          />
        </Field>
        <Field label="Hourly Rate (paise)">
          <Input
            type="number"
            value={form.hourlyRate ?? ""}
            onChange={(e) =>
              setForm((c) => ({
                ...c,
                hourlyRate: e.target.value ? Number(e.target.value) : null,
              }))
            }
          />
        </Field>
        <Field label="Specializations">
          <Input
            value={(form.specializations ?? []).join(", ")}
            onChange={(e) =>
              setForm((c) => ({
                ...c,
                specializations: e.target.value
                  .split(",")
                  .map((item) => item.trim())
                  .filter(Boolean),
              }))
            }
            placeholder="Batting, Bowling"
          />
        </Field>
        <Field label="Certifications">
          <Input
            value={(form.certifications ?? []).join(", ")}
            onChange={(e) =>
              setForm((c) => ({
                ...c,
                certifications: e.target.value
                  .split(",")
                  .map((item) => item.trim())
                  .filter(Boolean),
              }))
            }
            placeholder="ICC Level 1"
          />
        </Field>
        <ToggleRow
          label="Gig Enabled"
          description="Can this coach take marketplace gigs?"
          checked={Boolean(form.gigEnabled)}
          onCheckedChange={(checked) =>
            setForm((c) => ({ ...c, gigEnabled: checked }))
          }
        />
        <ToggleRow
          label="Verified"
          description="Admin coach verification"
          checked={Boolean(form.isVerified)}
          onCheckedChange={(checked) =>
            setForm((c) => ({ ...c, isVerified: checked }))
          }
        />
        <Field label="Bio" className="md:col-span-2">
          <Textarea
            value={form.bio ?? ""}
            onChange={(e) => setForm((c) => ({ ...c, bio: e.target.value }))}
            className="min-h-[90px]"
          />
        </Field>
        <div className="md:col-span-2">
          <Button
            disabled={mutation.isPending}
            onClick={() => mutation.mutate({ id: profile.id, data: form })}
          >
            {mutation.isPending ? "Saving..." : "Save Coach Profile"}
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}

function ArenaOwnerProfileEditor({
  profile,
}: {
  profile: Record<string, unknown> & { id: string };
}) {
  const mutation = useUpdateArenaOwnerMutation();
  const [form, setForm] = useState({
    businessName: String(profile.businessName ?? ""),
    gstNumber: String(profile.gstNumber ?? ""),
    panNumber: String(profile.panNumber ?? ""),
  });

  useEffect(() => {
    setForm({
      businessName: String(profile.businessName ?? ""),
      gstNumber: String(profile.gstNumber ?? ""),
      panNumber: String(profile.panNumber ?? ""),
    });
  }, [profile]);

  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-base">Arena Owner Profile</CardTitle>
      </CardHeader>
      <CardContent className="grid gap-4 md:grid-cols-2">
        <Field label="Business Name">
          <Input
            value={form.businessName}
            onChange={(e) =>
              setForm((c) => ({ ...c, businessName: e.target.value }))
            }
          />
        </Field>
        <Field label="GST Number">
          <Input
            value={form.gstNumber}
            onChange={(e) =>
              setForm((c) => ({ ...c, gstNumber: e.target.value }))
            }
          />
        </Field>
        <Field label="PAN Number">
          <Input
            value={form.panNumber}
            onChange={(e) =>
              setForm((c) => ({ ...c, panNumber: e.target.value }))
            }
          />
        </Field>
        <div className="md:col-span-2">
          <Button
            disabled={mutation.isPending}
            onClick={() => mutation.mutate({ id: profile.id, data: form })}
          >
            {mutation.isPending ? "Saving..." : "Save Arena Owner Profile"}
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}

function Field({
  label,
  children,
  className,
}: {
  label: string;
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <div className={className}>
      <Label className="mb-1.5 block text-xs font-medium">{label}</Label>
      {children}
    </div>
  );
}

function ToggleRow({
  label,
  description,
  checked,
  onCheckedChange,
}: {
  label: string;
  description: string;
  checked: boolean;
  onCheckedChange: (checked: boolean) => void;
}) {
  return (
    <div className="flex items-center justify-between rounded-lg border p-3">
      <div>
        <div className="text-sm font-medium">{label}</div>
        <div className="text-xs text-muted-foreground">{description}</div>
      </div>
      <Switch checked={checked} onCheckedChange={onCheckedChange} />
    </div>
  );
}

function RolePicker({
  values,
  onToggle,
}: {
  values: UserRole[];
  onToggle: (role: UserRole) => void;
}) {
  return (
    <div className="flex flex-wrap gap-2">
      {ROLE_OPTIONS.map((role) => (
        <Button
          key={role}
          type="button"
          variant={values.includes(role) ? "default" : "outline"}
          onClick={() => onToggle(role)}
        >
          {role}
        </Button>
      ))}
    </div>
  );
}

function MetricCard({ label, value }: { label: string; value: string }) {
  return (
    <Card>
      <CardContent className="space-y-1 p-4">
        <div className="text-xs uppercase tracking-wide text-muted-foreground">
          {label}
        </div>
        <div className="text-2xl font-semibold">{value}</div>
      </CardContent>
    </Card>
  );
}

function StatCell({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-lg border p-3">
      <div className="text-xs uppercase tracking-wide text-muted-foreground">
        {label}
      </div>
      <div className="mt-1 text-sm font-medium">{value}</div>
    </div>
  );
}

function ItemRow({
  title,
  description,
  meta,
}: {
  title: string;
  description: string;
  meta?: string;
}) {
  return (
    <div className="rounded-lg border p-3">
      <div className="font-medium">{title}</div>
      <div className="text-muted-foreground">{description}</div>
      {meta ? (
        <div className="mt-1 text-xs text-muted-foreground">{meta}</div>
      ) : null}
    </div>
  );
}

function BlockUserDialog({
  onConfirm,
  loading,
}: {
  onConfirm: (reason: string) => void;
  loading: boolean;
}) {
  const [reason, setReason] = useState("");

  return (
    <Dialog>
      <DialogTrigger asChild>
        <Button size="sm" variant="destructive">
          Ban
        </Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Ban user</DialogTitle>
          <DialogDescription>
            Reason is required and must be at least 5 characters.
          </DialogDescription>
        </DialogHeader>
        <Textarea
          value={reason}
          onChange={(e) => setReason(e.target.value)}
          placeholder="Spamming other players"
        />
        <DialogFooter>
          <Button
            variant="destructive"
            disabled={reason.trim().length < 5 || loading}
            onClick={() => onConfirm(reason.trim())}
          >
            {loading ? "Blocking..." : "Confirm Ban"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

export default function UsersPage() {
  const searchParams = useSearchParams();
  const page = Number(searchParams.get("page") ?? "1");
  const role = searchParams.get("role") ?? "";
  const search = searchParams.get("search") ?? "";
  const status = searchParams.get("status") ?? "";

  const query = useUsersQuery({
    page,
    limit: 25,
    role: role || undefined,
    search: search || undefined,
  });

  const filteredUsers = useMemo(() => {
    const users = query.data?.users ?? [];
    if (status === "ACTIVE") return users.filter((user) => !user.isBlocked);
    if (status === "BANNED") return users.filter((user) => user.isBlocked);
    return users;
  }, [query.data, status]);

  const columns = useMemo<ColumnDef<UserRecord>[]>(
    () => [
      {
        header: "User",
        cell: ({ row }) => (
          <div className="flex items-center gap-3">
            <Avatar name={row.original.name} />
            <div>
              <div className="font-medium">
                {row.original.name || "Unnamed user"}
              </div>
              <div className="text-xs text-muted-foreground">
                {row.original.id}
              </div>
            </div>
          </div>
        ),
      },
      { header: "Phone", accessorKey: "phone" },
      {
        header: "Roles",
        cell: ({ row }) => (
          <div className="flex flex-wrap gap-1">
            {row.original.roles.map((item) => (
              <Badge
                key={item}
                variant={
                  item === row.original.activeRole ? "success" : "outline"
                }
              >
                {item}
              </Badge>
            ))}
          </div>
        ),
      },
      {
        header: "Joined",
        cell: ({ row }) => formatDate(row.original.createdAt),
      },
      {
        header: "Status",
        cell: ({ row }) => (
          <Badge variant={row.original.isBlocked ? "destructive" : "success"}>
            {row.original.isBlocked ? "Banned" : "Active"}
          </Badge>
        ),
      },
      {
        header: "Actions",
        cell: ({ row }) => <UserActions user={row.original} />,
      },
    ],
    [],
  );

  return (
    <div className="space-y-6">
      <UsersPageHeader />
      <FilterBar
        searchPlaceholder="Search by name or phone"
        selects={[
          {
            key: "role",
            value: role,
            placeholder: "Filter by role",
            options: ROLE_OPTIONS.map((item) => ({ value: item, label: item })),
          },
          {
            key: "status",
            value: status,
            placeholder: "Filter by status",
            options: [
              { value: "ACTIVE", label: "Active" },
              { value: "BANNED", label: "Banned" },
            ],
          },
        ]}
      />
      {query.isError && (
        <div className="rounded-xl border border-destructive bg-destructive/10 p-4 text-sm text-destructive">
          Failed to load users:{" "}
          {(query.error as Error)?.message ?? "Unknown error"}
        </div>
      )}
      <div className="rounded-xl border bg-card overflow-x-auto">
        <DataTable
          columns={columns}
          data={query.isLoading ? [] : filteredUsers}
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
