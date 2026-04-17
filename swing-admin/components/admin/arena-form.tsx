"use client";

import { useEffect, useState, type FormEvent, type ReactNode } from "react";
import { Plus, Trash2 } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { MultiImageUpload } from "@/components/ui/multi-image-upload";
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
import type { ArenaDetail, CreateArenaBody } from "@/lib/api";
import { formatCurrencyInr, formatDate, paiseToInr } from "@/lib/utils";

const DEFAULT_OPERATING_DAYS = [1, 2, 3, 4, 5, 6, 7];
const DAY_OPTIONS = [
  { value: 1, label: "Mon" },
  { value: 2, label: "Tue" },
  { value: 3, label: "Wed" },
  { value: 4, label: "Thu" },
  { value: 5, label: "Fri" },
  { value: 6, label: "Sat" },
  { value: 7, label: "Sun" },
] as const;
const COMMON_SPORTS = ["CRICKET", "BOX_CRICKET"];
const ARENA_GRADES = ["GULLY", "CLUB", "DISTRICT", "ELITE"] as const;
const PLAN_TIER_SUGGESTIONS = ["FREE", "STARTER", "PRO", "ELITE"] as const;
const ADDON_UNIT_SUGGESTIONS = ["per_session", "per_hour", "flat"] as const;
const UNIT_TYPE_SUGGESTIONS = ["GROUND", "BOX", "NET", "TURF", "COURT"] as const;

type ArenaAddonDraft = {
  id?: string;
  name: string;
  description: string;
  pricePaise: string;
  unit: string;
  isAvailable: boolean;
};

type ArenaUnitDraft = {
  id?: string;
  name: string;
  unitType: string;
  sport: string;
  capacity: string;
  description: string;
  photoUrls: string[];
  pricePerHourPaise: string;
  peakPricePaise: string;
  peakHoursStart: string;
  peakHoursEnd: string;
  weekendMultiplier: string;
  minSlotMins: string;
  maxSlotMins: string;
  slotIncrementMins: string;
  isActive: boolean;
};

type ArenaFormState = {
  ownerId: string;
  name: string;
  description: string;
  photoUrls: string[];
  city: string;
  state: string;
  address: string;
  pincode: string;
  latitude: string;
  longitude: string;
  phone: string;
  sports: string[];
  hasParking: boolean;
  hasLights: boolean;
  hasWashrooms: boolean;
  hasCanteen: boolean;
  hasCCTV: boolean;
  hasScorer: boolean;
  openTime: string;
  closeTime: string;
  operatingDays: number[];
  advanceBookingDays: string;
  bufferMins: string;
  cancellationHours: string;
  planTier: string;
  planExpiresAt: string;
  isVerified: boolean;
  isSwingArena: boolean;
  arenaGrade: string;
  rating: string;
  totalRatings: string;
  isActive: boolean;
  addons: ArenaAddonDraft[];
  units: ArenaUnitDraft[];
};

type ArenaFormProps = {
  initialArena?: ArenaDetail | null;
  mode: "create" | "view" | "edit";
  submitting?: boolean;
  submitLabel?: string;
  onSubmit?: (payload: CreateArenaBody) => void;
};

function emptyAddon(): ArenaAddonDraft {
  return {
    name: "",
    description: "",
    pricePaise: "",
    unit: "per_session",
    isAvailable: true,
  };
}

function emptyUnit(): ArenaUnitDraft {
  return {
    name: "",
    unitType: "",
    sport: "CRICKET",
    capacity: "22",
    description: "",
    photoUrls: [],
    pricePerHourPaise: "",
    peakPricePaise: "",
    peakHoursStart: "",
    peakHoursEnd: "",
    weekendMultiplier: "1",
    minSlotMins: "60",
    maxSlotMins: "240",
    slotIncrementMins: "60",
    isActive: true,
  };
}

function toDateTimeLocal(value?: string | null) {
  if (!value) return "";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return "";
  const pad = (part: number) => String(part).padStart(2, "0");
  return [
    date.getFullYear(),
    pad(date.getMonth() + 1),
    pad(date.getDate()),
  ].join("-") + `T${pad(date.getHours())}:${pad(date.getMinutes())}`;
}

function createFormState(arena?: ArenaDetail | null): ArenaFormState {
  if (!arena) {
    return {
      ownerId: "",
      name: "",
      description: "",
      photoUrls: [],
      city: "",
      state: "",
      address: "",
      pincode: "",
      latitude: "",
      longitude: "",
      phone: "",
      sports: [],
      hasParking: false,
      hasLights: false,
      hasWashrooms: false,
      hasCanteen: false,
      hasCCTV: false,
      hasScorer: false,
      openTime: "06:00",
      closeTime: "22:00",
      operatingDays: [...DEFAULT_OPERATING_DAYS],
      advanceBookingDays: "7",
      bufferMins: "15",
      cancellationHours: "24",
      planTier: "FREE",
      planExpiresAt: "",
      isVerified: false,
      isSwingArena: false,
      arenaGrade: "",
      rating: "0",
      totalRatings: "0",
      isActive: true,
      addons: [],
      units: [],
    };
  }

  return {
    ownerId: arena.ownerId ?? "",
    name: arena.name ?? "",
    description: String(arena.description ?? ""),
    photoUrls: Array.isArray(arena.photoUrls) ? [...arena.photoUrls] : [],
    city: arena.city ?? "",
    state: arena.state ?? "",
    address: arena.address ?? "",
    pincode: arena.pincode ?? "",
    latitude: String(arena.latitude ?? ""),
    longitude: String(arena.longitude ?? ""),
    phone: String(arena.phone ?? ""),
    sports: Array.isArray(arena.sports) ? [...arena.sports] : [],
    hasParking: Boolean(arena.hasParking),
    hasLights: Boolean(arena.hasLights),
    hasWashrooms: Boolean(arena.hasWashrooms),
    hasCanteen: Boolean(arena.hasCanteen),
    hasCCTV: Boolean(arena.hasCCTV),
    hasScorer: Boolean(arena.hasScorer),
    openTime: arena.openTime ?? "06:00",
    closeTime: arena.closeTime ?? "22:00",
    operatingDays:
      Array.isArray(arena.operatingDays) && arena.operatingDays.length > 0
        ? [...arena.operatingDays]
        : [...DEFAULT_OPERATING_DAYS],
    advanceBookingDays: String(arena.advanceBookingDays ?? 7),
    bufferMins: String(arena.bufferMins ?? 15),
    cancellationHours: String(arena.cancellationHours ?? 24),
    planTier: arena.planTier ?? "FREE",
    planExpiresAt: toDateTimeLocal(arena.planExpiresAt),
    isVerified: Boolean(arena.isVerified),
    isSwingArena: Boolean(arena.isSwingArena),
    arenaGrade: String(arena.arenaGrade ?? ""),
    rating: String(arena.rating ?? 0),
    totalRatings: String(arena.totalRatings ?? 0),
    isActive: Boolean(arena.isActive),
    addons: Array.isArray(arena.addons)
      ? arena.addons.map((addon) => ({
          id: addon.id,
          name: addon.name ?? "",
          description: String(addon.description ?? ""),
          pricePaise: String(addon.pricePaise ?? ""),
          unit: addon.unit ?? "per_session",
          isAvailable: Boolean(addon.isAvailable),
        }))
      : [],
    units: Array.isArray(arena.units)
      ? arena.units.map((unit) => ({
          id: unit.id,
          name: unit.name ?? "",
          unitType: unit.unitType ?? "",
          sport: unit.sport ?? "CRICKET",
          capacity: String(unit.capacity ?? 22),
          description: String(unit.description ?? ""),
          photoUrls: Array.isArray(unit.photoUrls) ? [...unit.photoUrls] : [],
          pricePerHourPaise: String(unit.pricePerHourPaise ?? ""),
          peakPricePaise: unit.peakPricePaise == null ? "" : String(unit.peakPricePaise),
          peakHoursStart: String(unit.peakHoursStart ?? ""),
          peakHoursEnd: String(unit.peakHoursEnd ?? ""),
          weekendMultiplier: String(unit.weekendMultiplier ?? 1),
          minSlotMins: String(unit.minSlotMins ?? 60),
          maxSlotMins: String(unit.maxSlotMins ?? 240),
          slotIncrementMins: String(unit.slotIncrementMins ?? 60),
          isActive: Boolean(unit.isActive),
        }))
      : [],
  };
}

function parseRequiredNumber(value: string) {
  return Number(value);
}

function parseOptionalNumber(value: string) {
  const trimmed = value.trim();
  return trimmed ? Number(trimmed) : undefined;
}

function buildPayload(form: ArenaFormState): CreateArenaBody {
  return {
    ownerId: form.ownerId.trim(),
    name: form.name.trim(),
    description: form.description.trim() || undefined,
    photoUrls: form.photoUrls.map((value) => value.trim()).filter(Boolean),
    city: form.city.trim(),
    state: form.state.trim(),
    address: form.address.trim(),
    pincode: form.pincode.trim(),
    latitude: parseRequiredNumber(form.latitude),
    longitude: parseRequiredNumber(form.longitude),
    phone: form.phone.trim() || undefined,
    sports: form.sports.map((value) => value.trim().toUpperCase()).filter(Boolean),
    hasParking: form.hasParking,
    hasLights: form.hasLights,
    hasWashrooms: form.hasWashrooms,
    hasCanteen: form.hasCanteen,
    hasCCTV: form.hasCCTV,
    hasScorer: form.hasScorer,
    openTime: form.openTime,
    closeTime: form.closeTime,
    operatingDays: [...form.operatingDays].sort((a, b) => a - b),
    advanceBookingDays: parseRequiredNumber(form.advanceBookingDays),
    bufferMins: parseRequiredNumber(form.bufferMins),
    cancellationHours: parseRequiredNumber(form.cancellationHours),
    planTier: form.planTier.trim() || undefined,
    planExpiresAt: form.planExpiresAt || undefined,
    isVerified: form.isVerified,
    isSwingArena: form.isSwingArena,
    arenaGrade: form.arenaGrade.trim() || undefined,
    rating: parseOptionalNumber(form.rating),
    totalRatings: parseOptionalNumber(form.totalRatings),
    isActive: form.isActive,
    addons: form.addons
      .filter((addon) => addon.name.trim() && addon.pricePaise.trim())
      .map((addon) => ({
        ...(addon.id ? { id: addon.id } : {}),
        name: addon.name.trim(),
        description: addon.description.trim() || undefined,
        pricePaise: parseRequiredNumber(addon.pricePaise),
        unit: addon.unit.trim() || "per_session",
        isAvailable: addon.isAvailable,
      })),
    units: form.units
      .filter(
        (unit) =>
          unit.name.trim() &&
          unit.unitType.trim() &&
          unit.sport.trim() &&
          unit.pricePerHourPaise.trim(),
      )
      .map((unit) => ({
        ...(unit.id ? { id: unit.id } : {}),
        name: unit.name.trim(),
        unitType: unit.unitType.trim(),
        sport: unit.sport.trim().toUpperCase(),
        capacity: parseOptionalNumber(unit.capacity),
        description: unit.description.trim() || undefined,
        photoUrls: unit.photoUrls.map((value) => value.trim()).filter(Boolean),
        pricePerHourPaise: parseRequiredNumber(unit.pricePerHourPaise),
        peakPricePaise: parseOptionalNumber(unit.peakPricePaise) ?? null,
        peakHoursStart: unit.peakHoursStart || undefined,
        peakHoursEnd: unit.peakHoursEnd || undefined,
        weekendMultiplier: parseOptionalNumber(unit.weekendMultiplier),
        minSlotMins: parseOptionalNumber(unit.minSlotMins),
        maxSlotMins: parseOptionalNumber(unit.maxSlotMins),
        slotIncrementMins: parseOptionalNumber(unit.slotIncrementMins),
        isActive: unit.isActive,
      })),
  };
}

function Field({
  label,
  hint,
  children,
}: {
  label: string;
  hint?: string;
  children: ReactNode;
}) {
  return (
    <div className="space-y-1.5">
      <Label className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
        {label}
      </Label>
      {children}
      {hint ? <p className="text-xs text-muted-foreground">{hint}</p> : null}
    </div>
  );
}

function SuggestionInput({
  listId,
  options,
  value,
  disabled,
  placeholder,
  onChange,
}: {
  listId: string;
  options: readonly string[];
  value: string;
  disabled?: boolean;
  placeholder?: string;
  onChange: (value: string) => void;
}) {
  return (
    <>
      <Input
        list={listId}
        value={value}
        disabled={disabled}
        placeholder={placeholder}
        onChange={(event) => onChange(event.target.value)}
      />
      <datalist id={listId}>
        {options.map((option) => (
          <option key={option} value={option} />
        ))}
      </datalist>
    </>
  );
}

function ToggleField({
  label,
  description,
  checked,
  disabled,
  onCheckedChange,
}: {
  label: string;
  description: string;
  checked: boolean;
  disabled?: boolean;
  onCheckedChange: (checked: boolean) => void;
}) {
  return (
    <div className="flex items-start justify-between gap-4 rounded-lg border p-3">
      <div className="space-y-1">
        <p className="text-sm font-medium">{label}</p>
        <p className="text-xs text-muted-foreground">{description}</p>
      </div>
      <Switch
        checked={checked}
        disabled={disabled}
        onCheckedChange={onCheckedChange}
      />
    </div>
  );
}

function StringListEditor({
  label,
  description,
  placeholder,
  values,
  disabled,
  onChange,
  transform,
}: {
  label: string;
  description?: string;
  placeholder: string;
  values: string[];
  disabled?: boolean;
  onChange: (values: string[]) => void;
  transform?: (value: string) => string;
}) {
  const [draft, setDraft] = useState("");

  function addValue() {
    const normalized = transform ? transform(draft) : draft.trim();
    if (!normalized || values.includes(normalized)) {
      setDraft("");
      return;
    }
    onChange([...values, normalized]);
    setDraft("");
  }

  return (
    <Field label={label} hint={description}>
      {!disabled ? (
        <div className="flex gap-2">
          <Input
            value={draft}
            placeholder={placeholder}
            onChange={(event) => setDraft(event.target.value)}
            onKeyDown={(event) => {
              if (event.key === "Enter") {
                event.preventDefault();
                addValue();
              }
            }}
          />
          <Button type="button" variant="outline" onClick={addValue}>
            Add
          </Button>
        </div>
      ) : null}
      <div className="flex flex-wrap gap-2">
        {values.length === 0 ? (
          <span className="text-sm text-muted-foreground">None added.</span>
        ) : (
          values.map((value) => (
            <Badge key={value} variant="outline" className="gap-2 px-3 py-1">
              <span>{value}</span>
              {!disabled ? (
                <button
                  type="button"
                  className="text-muted-foreground transition-colors hover:text-foreground"
                  onClick={() =>
                    onChange(values.filter((current) => current !== value))
                  }
                >
                  ×
                </button>
              ) : null}
            </Badge>
          ))
        )}
      </div>
    </Field>
  );
}

export function ArenaForm({
  initialArena,
  mode,
  submitting = false,
  submitLabel,
  onSubmit,
}: ArenaFormProps) {
  const [form, setForm] = useState<ArenaFormState>(() => createFormState(initialArena));
  const [uploadId] = useState(
    () => initialArena?.id ?? `arena-draft-${Math.random().toString(36).slice(2, 10)}`,
  );
  const readOnly = mode === "view";
  const editable = mode !== "view";
  const ownerName =
    initialArena?.owner?.user?.name ??
    initialArena?.owner?.businessName ??
    "Unknown owner";

  useEffect(() => {
    setForm(createFormState(initialArena));
  }, [initialArena]);

  const canSubmit =
    editable &&
    Boolean(
      form.ownerId.trim() &&
        form.name.trim() &&
        form.city.trim() &&
        form.state.trim() &&
        form.address.trim() &&
        form.pincode.trim() &&
        form.latitude.trim() &&
        form.longitude.trim(),
    );

  function updateField<K extends keyof ArenaFormState>(
    key: K,
    value: ArenaFormState[K],
  ) {
    setForm((current) => ({ ...current, [key]: value }));
  }

  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!editable || !onSubmit) return;
    onSubmit(buildPayload(form));
  }

  return (
    <form className="space-y-6" onSubmit={submit}>
      {initialArena ? (
        <Card>
          <CardHeader>
            <CardTitle className="text-base">Arena Snapshot</CardTitle>
            <CardDescription>
              Owner, timestamps, and operational state for this record.
            </CardDescription>
          </CardHeader>
          <CardContent className="grid gap-3 md:grid-cols-2 xl:grid-cols-4">
            <div className="rounded-lg border p-3">
              <div className="text-xs uppercase tracking-wide text-muted-foreground">
                Owner
              </div>
              <div className="mt-1 font-medium">{ownerName}</div>
              <div className="mt-1 text-sm text-muted-foreground">
                {initialArena.owner?.user?.phone ?? initialArena.ownerId}
              </div>
            </div>
            <div className="rounded-lg border p-3">
              <div className="text-xs uppercase tracking-wide text-muted-foreground">
                Created
              </div>
              <div className="mt-1 font-medium">
                {formatDate(initialArena.createdAt, "dd MMM yyyy, hh:mm a")}
              </div>
            </div>
            <div className="rounded-lg border p-3">
              <div className="text-xs uppercase tracking-wide text-muted-foreground">
                Updated
              </div>
              <div className="mt-1 font-medium">
                {formatDate(initialArena.updatedAt, "dd MMM yyyy, hh:mm a")}
              </div>
            </div>
            <div className="rounded-lg border p-3">
              <div className="text-xs uppercase tracking-wide text-muted-foreground">
                Ratings
              </div>
              <div className="mt-1 font-medium">
                {initialArena.rating.toFixed(1)} from {initialArena.totalRatings} ratings
              </div>
            </div>
          </CardContent>
        </Card>
      ) : null}

      <Tabs defaultValue="basics">
        <TabsList className="h-auto w-full flex-wrap justify-start gap-2 rounded-xl border bg-card p-2">
          <TabsTrigger value="basics">Basics</TabsTrigger>
          <TabsTrigger value="operations">Operations</TabsTrigger>
          <TabsTrigger value="addons">Addons</TabsTrigger>
          <TabsTrigger value="units">Units</TabsTrigger>
        </TabsList>

        <TabsContent value="basics" className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle>Core Details</CardTitle>
          <CardDescription>
            Matches the primary Arena table fields used for registration and discovery.
          </CardDescription>
        </CardHeader>
        <CardContent className="grid gap-4 md:grid-cols-2">
          <Field label="Arena Name">
            <Input
              value={form.name}
              disabled={readOnly}
              onChange={(event) => updateField("name", event.target.value)}
              placeholder="Old Campion"
            />
          </Field>
          <Field label="Owner Profile ID" hint="Maps to Arena.ownerId">
            <Input
              value={form.ownerId}
              disabled={readOnly}
              onChange={(event) => updateField("ownerId", event.target.value)}
              placeholder="ArenaOwnerProfile id"
            />
          </Field>
          <div className="md:col-span-2">
            <Field label="Description">
              <Textarea
                value={form.description}
                disabled={readOnly}
                onChange={(event) => updateField("description", event.target.value)}
                placeholder="Indoor box cricket arena with floodlights and scorer support."
                rows={4}
              />
            </Field>
          </div>
          <Field label="Arena Grade">
            <Select
              value={form.arenaGrade || undefined}
              disabled={readOnly}
              onValueChange={(value) => updateField("arenaGrade", value)}
            >
              <SelectTrigger>
                <SelectValue placeholder="Select arena grade" />
              </SelectTrigger>
              <SelectContent>
                {ARENA_GRADES.map((grade) => (
                  <SelectItem key={grade} value={grade}>
                    {grade}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </Field>
          <Field label="Plan Tier">
            <SuggestionInput
              listId="arena-plan-tier"
              options={PLAN_TIER_SUGGESTIONS}
              value={form.planTier}
              disabled={readOnly}
              onChange={(value) => updateField("planTier", value.toUpperCase())}
              placeholder="FREE"
            />
          </Field>
          <Field label="Plan Expires At">
            <Input
              type="datetime-local"
              value={form.planExpiresAt}
              disabled={readOnly}
              onChange={(event) => updateField("planExpiresAt", event.target.value)}
            />
          </Field>
          <Field label="Phone">
            <Input
              value={form.phone}
              disabled={readOnly}
              onChange={(event) => updateField("phone", event.target.value)}
              placeholder="+91 9876543210"
            />
          </Field>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Location</CardTitle>
          <CardDescription>
            Stored address, pincode, and geolocation for search and booking.
          </CardDescription>
        </CardHeader>
        <CardContent className="grid gap-4 md:grid-cols-2">
          <Field label="City">
            <Input
              value={form.city}
              disabled={readOnly}
              onChange={(event) => updateField("city", event.target.value)}
              placeholder="Bhopal"
            />
          </Field>
          <Field label="State">
            <Input
              value={form.state}
              disabled={readOnly}
              onChange={(event) => updateField("state", event.target.value)}
              placeholder="Madhya Pradesh"
            />
          </Field>
          <div className="md:col-span-2">
            <Field label="Address">
              <Textarea
                value={form.address}
                disabled={readOnly}
                onChange={(event) => updateField("address", event.target.value)}
                placeholder="Full street address"
                rows={3}
              />
            </Field>
          </div>
          <Field label="Pincode">
            <Input
              value={form.pincode}
              disabled={readOnly}
              onChange={(event) => updateField("pincode", event.target.value)}
              placeholder="462001"
            />
          </Field>
          <Field label="Latitude">
            <Input
              type="number"
              step="any"
              value={form.latitude}
              disabled={readOnly}
              onChange={(event) => updateField("latitude", event.target.value)}
              placeholder="23.2599"
            />
          </Field>
          <Field label="Longitude">
            <Input
              type="number"
              step="any"
              value={form.longitude}
              disabled={readOnly}
              onChange={(event) => updateField("longitude", event.target.value)}
              placeholder="77.4126"
            />
          </Field>
        </CardContent>
      </Card>

        </TabsContent>

        <TabsContent value="operations" className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle>Operations</CardTitle>
          <CardDescription>
            Booking timings, advance windows, buffers, and allowed operating days.
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-5">
            <Field label="Open Time">
              <Input
                type="time"
                value={form.openTime}
                disabled={readOnly}
                onChange={(event) => updateField("openTime", event.target.value)}
              />
            </Field>
            <Field label="Close Time">
              <Input
                type="time"
                value={form.closeTime}
                disabled={readOnly}
                onChange={(event) => updateField("closeTime", event.target.value)}
              />
            </Field>
            <Field label="Advance Booking Days">
              <Input
                type="number"
                min="0"
                value={form.advanceBookingDays}
                disabled={readOnly}
                onChange={(event) => updateField("advanceBookingDays", event.target.value)}
              />
            </Field>
            <Field label="Buffer Minutes">
              <Input
                type="number"
                min="0"
                value={form.bufferMins}
                disabled={readOnly}
                onChange={(event) => updateField("bufferMins", event.target.value)}
              />
            </Field>
            <Field label="Cancellation Hours">
              <Input
                type="number"
                min="0"
                value={form.cancellationHours}
                disabled={readOnly}
                onChange={(event) => updateField("cancellationHours", event.target.value)}
              />
            </Field>
          </div>
          <Field label="Operating Days">
            <div className="flex flex-wrap gap-2">
              {DAY_OPTIONS.map((day) => {
                const selected = form.operatingDays.includes(day.value);
                return (
                  <Button
                    key={day.value}
                    type="button"
                    variant={selected ? "default" : "outline"}
                    disabled={readOnly}
                    onClick={() => {
                      if (readOnly) return;
                      updateField(
                        "operatingDays",
                        selected
                          ? form.operatingDays.filter((value) => value !== day.value)
                          : [...form.operatingDays, day.value].sort((a, b) => a - b),
                      );
                    }}
                  >
                    {day.label}
                  </Button>
                );
              })}
            </div>
          </Field>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Classification</CardTitle>
          <CardDescription>
            Sports, photo URLs, and status flags surfaced through the admin and consumer apps.
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid gap-4 lg:grid-cols-2">
            <Field label="Sports" hint="Select the sports supported by this arena.">
              {!readOnly ? (
                <div className="flex flex-wrap gap-2">
                  {COMMON_SPORTS.map((sport) => {
                    const selected = form.sports.includes(sport);
                    return (
                      <Button
                        key={sport}
                        type="button"
                        size="sm"
                        variant={selected ? "default" : "outline"}
                        onClick={() =>
                          updateField(
                            "sports",
                            selected
                              ? form.sports.filter((value) => value !== sport)
                              : [...form.sports, sport],
                          )
                        }
                      >
                        {sport}
                      </Button>
                    );
                  })}
                </div>
              ) : null}
              <div className="flex flex-wrap gap-2">
                {form.sports.length === 0 ? (
                  <span className="text-sm text-muted-foreground">No sports selected.</span>
                ) : (
                  form.sports.map((sport) => (
                    <Badge key={sport} variant="outline" className="px-3 py-1">
                      {sport}
                    </Badge>
                  ))
                )}
              </div>
            </Field>
            <MultiImageUpload
              folder="arenas"
              id={uploadId}
              values={form.photoUrls}
              disabled={readOnly}
              label="Arena Photos"
              hint="Upload multiple arena photos. Uploaded URLs are saved into Arena.photoUrls."
              onChange={(values) => updateField("photoUrls", values)}
            />
          </div>
          <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
            <Field label="Rating">
              <Input
                type="number"
                step="0.1"
                value={form.rating}
                disabled={readOnly}
                onChange={(event) => updateField("rating", event.target.value)}
              />
            </Field>
            <Field label="Total Ratings">
              <Input
                type="number"
                min="0"
                value={form.totalRatings}
                disabled={readOnly}
                onChange={(event) => updateField("totalRatings", event.target.value)}
              />
            </Field>
          </div>
          <div className="grid gap-3 md:grid-cols-2 xl:grid-cols-3">
            <ToggleField
              label="Has Parking"
              description="On-site vehicle parking is available."
              checked={form.hasParking}
              disabled={readOnly}
              onCheckedChange={(value) => updateField("hasParking", value)}
            />
            <ToggleField
              label="Has Lights"
              description="Floodlights or evening lighting is available."
              checked={form.hasLights}
              disabled={readOnly}
              onCheckedChange={(value) => updateField("hasLights", value)}
            />
            <ToggleField
              label="Has Washrooms"
              description="Washrooms are available for players and guests."
              checked={form.hasWashrooms}
              disabled={readOnly}
              onCheckedChange={(value) => updateField("hasWashrooms", value)}
            />
            <ToggleField
              label="Has Canteen"
              description="Food or refreshment service is available."
              checked={form.hasCanteen}
              disabled={readOnly}
              onCheckedChange={(value) => updateField("hasCanteen", value)}
            />
            <ToggleField
              label="Has CCTV"
              description="CCTV surveillance is installed."
              checked={form.hasCCTV}
              disabled={readOnly}
              onCheckedChange={(value) => updateField("hasCCTV", value)}
            />
            <ToggleField
              label="Has Scorer"
              description="A dedicated scorer can be provided."
              checked={form.hasScorer}
              disabled={readOnly}
              onCheckedChange={(value) => updateField("hasScorer", value)}
            />
            <ToggleField
              label="Verified"
              description="Admin verification flag."
              checked={form.isVerified}
              disabled={readOnly}
              onCheckedChange={(value) => updateField("isVerified", value)}
            />
            <ToggleField
              label="Swing Arena"
              description="Included in the Swing Arena program."
              checked={form.isSwingArena}
              disabled={readOnly}
              onCheckedChange={(value) => updateField("isSwingArena", value)}
            />
            <ToggleField
              label="Active"
              description="Arena is available in the platform."
              checked={form.isActive}
              disabled={readOnly}
              onCheckedChange={(value) => updateField("isActive", value)}
            />
          </div>
        </CardContent>
      </Card>

        </TabsContent>

        <TabsContent value="addons" className="space-y-6">
      <Card>
        <CardHeader className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
          <div>
            <CardTitle>Arena Addons</CardTitle>
            <CardDescription>
              Optional paid extras stored in the ArenaAddon table.
            </CardDescription>
          </div>
          {!readOnly ? (
            <Button
              type="button"
              variant="outline"
              onClick={() => updateField("addons", [...form.addons, emptyAddon()])}
            >
              <Plus className="mr-2 h-4 w-4" />
              Add addon
            </Button>
          ) : null}
        </CardHeader>
        <CardContent className="space-y-4">
          {form.addons.length === 0 ? (
            <div className="rounded-lg border border-dashed p-6 text-sm text-muted-foreground">
              No addons configured.
            </div>
          ) : (
            form.addons.map((addon, index) => (
              <div key={addon.id ?? index} className="rounded-xl border p-4">
                <div className="mb-4 flex items-center justify-between">
                  <div>
                    <div className="font-medium">
                      {addon.name.trim() || `Addon ${index + 1}`}
                    </div>
                    {addon.pricePaise ? (
                      <div className="text-sm text-muted-foreground">
                        {formatCurrencyInr(paiseToInr(Number(addon.pricePaise)))}
                      </div>
                    ) : null}
                  </div>
                  {!readOnly ? (
                    <Button
                      type="button"
                      size="icon"
                      variant="ghost"
                      onClick={() =>
                        updateField(
                          "addons",
                          form.addons.filter((_, addonIndex) => addonIndex !== index),
                        )
                      }
                    >
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  ) : null}
                </div>
                <div className="grid gap-4 md:grid-cols-2">
                  <Field label="Name">
                    <Input
                      value={addon.name}
                      disabled={readOnly}
                      onChange={(event) =>
                        updateField(
                          "addons",
                          form.addons.map((current, addonIndex) =>
                            addonIndex === index
                              ? { ...current, name: event.target.value }
                              : current,
                          ),
                        )
                      }
                      placeholder="Ball machine"
                    />
                  </Field>
                  <Field label="Price Paise">
                    <Input
                      type="number"
                      min="0"
                      value={addon.pricePaise}
                      disabled={readOnly}
                      onChange={(event) =>
                        updateField(
                          "addons",
                          form.addons.map((current, addonIndex) =>
                            addonIndex === index
                              ? { ...current, pricePaise: event.target.value }
                              : current,
                          ),
                        )
                      }
                      placeholder="5000"
                    />
                  </Field>
                  <Field label="Unit">
                    <SuggestionInput
                      listId={`arena-addon-unit-${index}`}
                      options={ADDON_UNIT_SUGGESTIONS}
                      value={addon.unit}
                      disabled={readOnly}
                      onChange={(value) =>
                        updateField(
                          "addons",
                          form.addons.map((current, addonIndex) =>
                            addonIndex === index
                              ? { ...current, unit: value }
                              : current,
                          ),
                        )
                      }
                      placeholder="per_session"
                    />
                  </Field>
                  <ToggleField
                    label="Available"
                    description="Controls ArenaAddon.isAvailable."
                    checked={addon.isAvailable}
                    disabled={readOnly}
                    onCheckedChange={(value) =>
                      updateField(
                        "addons",
                        form.addons.map((current, addonIndex) =>
                          addonIndex === index
                            ? { ...current, isAvailable: value }
                            : current,
                        ),
                      )
                    }
                  />
                  <div className="md:col-span-2">
                    <Field label="Description">
                      <Textarea
                        value={addon.description}
                        disabled={readOnly}
                        onChange={(event) =>
                          updateField(
                            "addons",
                            form.addons.map((current, addonIndex) =>
                              addonIndex === index
                                ? { ...current, description: event.target.value }
                                : current,
                            ),
                          )
                        }
                        rows={3}
                        placeholder="Optional details for the addon"
                      />
                    </Field>
                  </div>
                </div>
              </div>
            ))
          )}
        </CardContent>
      </Card>

        </TabsContent>

        <TabsContent value="units" className="space-y-6">
      <Card>
        <CardHeader className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
          <div>
            <CardTitle>Arena Units</CardTitle>
            <CardDescription>
              Booking units stored in the ArenaUnit table.
            </CardDescription>
          </div>
          {!readOnly ? (
            <Button
              type="button"
              variant="outline"
              onClick={() => updateField("units", [...form.units, emptyUnit()])}
            >
              <Plus className="mr-2 h-4 w-4" />
              Add unit
            </Button>
          ) : null}
        </CardHeader>
        <CardContent className="space-y-4">
          {form.units.length === 0 ? (
            <div className="rounded-lg border border-dashed p-6 text-sm text-muted-foreground">
              No arena units configured.
            </div>
          ) : (
            form.units.map((unit, index) => (
              <div key={unit.id ?? index} className="rounded-xl border p-4">
                <div className="mb-4 flex items-center justify-between">
                  <div>
                    <div className="font-medium">
                      {unit.name.trim() || `Unit ${index + 1}`}
                    </div>
                    {unit.pricePerHourPaise ? (
                      <div className="text-sm text-muted-foreground">
                        {formatCurrencyInr(paiseToInr(Number(unit.pricePerHourPaise)))} / hour
                      </div>
                    ) : null}
                  </div>
                  {!readOnly ? (
                    <Button
                      type="button"
                      size="icon"
                      variant="ghost"
                      onClick={() =>
                        updateField(
                          "units",
                          form.units.filter((_, unitIndex) => unitIndex !== index),
                        )
                      }
                    >
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  ) : null}
                </div>
                <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
                  <Field label="Name">
                    <Input
                      value={unit.name}
                      disabled={readOnly}
                      onChange={(event) =>
                        updateField(
                          "units",
                          form.units.map((current, unitIndex) =>
                            unitIndex === index
                              ? { ...current, name: event.target.value }
                              : current,
                          ),
                        )
                      }
                      placeholder="Main Turf"
                    />
                  </Field>
                  <Field label="Unit Type">
                    <SuggestionInput
                      listId={`arena-unit-type-${index}`}
                      options={UNIT_TYPE_SUGGESTIONS}
                      value={unit.unitType}
                      disabled={readOnly}
                      onChange={(value) =>
                        updateField(
                          "units",
                          form.units.map((current, unitIndex) =>
                            unitIndex === index
                              ? { ...current, unitType: value.toUpperCase() }
                              : current,
                          ),
                        )
                      }
                      placeholder="GROUND"
                    />
                  </Field>
                  <Field label="Sport">
                    <Select
                      value={unit.sport}
                      disabled={readOnly}
                      onValueChange={(value) =>
                        updateField(
                          "units",
                          form.units.map((current, unitIndex) =>
                            unitIndex === index
                              ? { ...current, sport: value }
                              : current,
                          ),
                        )
                      }
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Select sport" />
                      </SelectTrigger>
                      <SelectContent>
                        {COMMON_SPORTS.map((sport) => (
                          <SelectItem key={sport} value={sport}>
                            {sport}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </Field>
                  <Field label="Capacity">
                    <Input
                      type="number"
                      min="1"
                      value={unit.capacity}
                      disabled={readOnly}
                      onChange={(event) =>
                        updateField(
                          "units",
                          form.units.map((current, unitIndex) =>
                            unitIndex === index
                              ? { ...current, capacity: event.target.value }
                              : current,
                          ),
                        )
                      }
                    />
                  </Field>
                  <Field label="Price Per Hour Paise">
                    <Input
                      type="number"
                      min="0"
                      value={unit.pricePerHourPaise}
                      disabled={readOnly}
                      onChange={(event) =>
                        updateField(
                          "units",
                          form.units.map((current, unitIndex) =>
                            unitIndex === index
                              ? { ...current, pricePerHourPaise: event.target.value }
                              : current,
                          ),
                        )
                      }
                      placeholder="250000"
                    />
                  </Field>
                  <Field label="Peak Price Paise">
                    <Input
                      type="number"
                      min="0"
                      value={unit.peakPricePaise}
                      disabled={readOnly}
                      onChange={(event) =>
                        updateField(
                          "units",
                          form.units.map((current, unitIndex) =>
                            unitIndex === index
                              ? { ...current, peakPricePaise: event.target.value }
                              : current,
                          ),
                        )
                      }
                      placeholder="Optional"
                    />
                  </Field>
                  <Field label="Peak Hours Start">
                    <Input
                      type="time"
                      value={unit.peakHoursStart}
                      disabled={readOnly}
                      onChange={(event) =>
                        updateField(
                          "units",
                          form.units.map((current, unitIndex) =>
                            unitIndex === index
                              ? { ...current, peakHoursStart: event.target.value }
                              : current,
                          ),
                        )
                      }
                    />
                  </Field>
                  <Field label="Peak Hours End">
                    <Input
                      type="time"
                      value={unit.peakHoursEnd}
                      disabled={readOnly}
                      onChange={(event) =>
                        updateField(
                          "units",
                          form.units.map((current, unitIndex) =>
                            unitIndex === index
                              ? { ...current, peakHoursEnd: event.target.value }
                              : current,
                          ),
                        )
                      }
                    />
                  </Field>
                  <Field label="Weekend Multiplier">
                    <Input
                      type="number"
                      step="0.1"
                      min="0"
                      value={unit.weekendMultiplier}
                      disabled={readOnly}
                      onChange={(event) =>
                        updateField(
                          "units",
                          form.units.map((current, unitIndex) =>
                            unitIndex === index
                              ? { ...current, weekendMultiplier: event.target.value }
                              : current,
                          ),
                        )
                      }
                    />
                  </Field>
                  <Field label="Min Slot Minutes">
                    <Input
                      type="number"
                      min="0"
                      value={unit.minSlotMins}
                      disabled={readOnly}
                      onChange={(event) =>
                        updateField(
                          "units",
                          form.units.map((current, unitIndex) =>
                            unitIndex === index
                              ? { ...current, minSlotMins: event.target.value }
                              : current,
                          ),
                        )
                      }
                    />
                  </Field>
                  <Field label="Max Slot Minutes">
                    <Input
                      type="number"
                      min="0"
                      value={unit.maxSlotMins}
                      disabled={readOnly}
                      onChange={(event) =>
                        updateField(
                          "units",
                          form.units.map((current, unitIndex) =>
                            unitIndex === index
                              ? { ...current, maxSlotMins: event.target.value }
                              : current,
                          ),
                        )
                      }
                    />
                  </Field>
                  <Field label="Slot Increment Minutes">
                    <Input
                      type="number"
                      min="0"
                      value={unit.slotIncrementMins}
                      disabled={readOnly}
                      onChange={(event) =>
                        updateField(
                          "units",
                          form.units.map((current, unitIndex) =>
                            unitIndex === index
                              ? { ...current, slotIncrementMins: event.target.value }
                              : current,
                          ),
                        )
                      }
                    />
                  </Field>
                  <ToggleField
                    label="Unit Active"
                    description="Controls ArenaUnit.isActive."
                    checked={unit.isActive}
                    disabled={readOnly}
                    onCheckedChange={(value) =>
                      updateField(
                        "units",
                        form.units.map((current, unitIndex) =>
                          unitIndex === index
                            ? { ...current, isActive: value }
                            : current,
                        ),
                      )
                    }
                  />
                  <div className="md:col-span-2 xl:col-span-3">
                    <Field label="Description">
                      <Textarea
                        value={unit.description}
                        disabled={readOnly}
                        onChange={(event) =>
                          updateField(
                            "units",
                            form.units.map((current, unitIndex) =>
                              unitIndex === index
                                ? { ...current, description: event.target.value }
                                : current,
                            ),
                          )
                        }
                        rows={3}
                        placeholder="Indoor box cricket strip with rebound nets."
                      />
                    </Field>
                  </div>
                  <div className="md:col-span-2 xl:col-span-3">
                    <StringListEditor
                      label="Unit Photo URLs"
                      placeholder="https://..."
                      values={unit.photoUrls}
                      disabled={readOnly}
                      onChange={(values) =>
                        updateField(
                          "units",
                          form.units.map((current, unitIndex) =>
                            unitIndex === index
                              ? { ...current, photoUrls: values }
                              : current,
                          ),
                        )
                      }
                    />
                  </div>
                </div>
              </div>
            ))
          )}
        </CardContent>
      </Card>

        </TabsContent>
      </Tabs>

      {editable ? (
        <div className="flex justify-end">
          <Button type="submit" disabled={!canSubmit || submitting}>
            {submitting
              ? "Saving..."
              : submitLabel ?? (mode === "create" ? "Create Arena" : "Save Changes")}
          </Button>
        </div>
      ) : null}
    </form>
  );
}
