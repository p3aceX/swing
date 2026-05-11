"use client";

import { useState, useCallback, useTransition, useRef, useEffect } from "react";

type BookedSlot = { startTime: string; endTime: string };
type SlotUnit = {
  id: string; name: string; unitType?: string;
  pricePerHourPaise?: number; minSlotMins?: number;
  maxSlotMins?: number; slotIncrementMins?: number;
  openTime?: string; closeTime?: string;
  bookedSlots?: BookedSlot[];
};
type NetVariant = { type: string; label: string; pricePaise?: number | null };
type ArenaAddon = { id: string; name: string; pricePaise: number; description?: string | null; unit?: string | null };
type ArenaUnit = {
  id: string; name: string; unitType?: string;
  pricePerHourPaise?: number; minSlotMins?: number; maxSlotMins?: number;
  price4HrPaise?: number | null; price8HrPaise?: number | null;
  priceFullDayPaise?: number | null;
  netVariants?: NetVariant[] | null;
  monthlyPassEnabled?: boolean; monthlyPassRatePaise?: number | null;
  minBulkDays?: number | null; bulkDayRatePaise?: number | null;
  addons?: ArenaAddon[] | null;
  minAdvancePaise?: number | null;
  cancellationHours?: number | null;
};
type Props = {
  units: ArenaUnit[];
  arenaId: string;
  arenaSlug: string;
  apiBaseUrl: string;
  arenaName?: string;
  address?: string | null;
  latitude?: number | null;
  longitude?: number | null;
  phone?: string | null;
  openTime?: string | null;
  closeTime?: string | null;
};

const GROUND_TYPES = new Set(["FULL_GROUND", "HALF_GROUND", "TURF", "MULTI_SPORT"]);
const PEAK_START = 17 * 60;
const PEAK_END = 22 * 60;

function toMins(t: string) { const [h, m] = t.split(":").map(Number); return h * 60 + m; }
function toTime(m: number) { return `${String(Math.floor(m / 60)).padStart(2, "0")}:${String(m % 60).padStart(2, "0")}`; }
function fmt12(t: string) {
  const [h, m] = t.split(":").map(Number);
  const ap = h >= 12 ? "PM" : "AM"; const hr = h % 12 || 12;
  return m === 0 ? `${hr} ${ap}` : `${hr}:${String(m).padStart(2, "0")} ${ap}`;
}
function fmtRange(start: string, end: string) {
  const [sh, sm] = start.split(":").map(Number);
  const [eh, em] = end.split(":").map(Number);
  const sap = sh >= 12 ? "PM" : "AM";
  const eap = eh >= 12 ? "PM" : "AM";
  const shr = sh % 12 || 12;
  const ehr = eh % 12 || 12;
  const sStr = sm === 0 ? `${shr}` : `${shr}:${String(sm).padStart(2, "0")}`;
  const eStr = em === 0 ? `${ehr}` : `${ehr}:${String(em).padStart(2, "0")}`;
  return sap === eap ? `${sStr}–${eStr} ${sap}` : `${sStr} ${sap}–${eStr} ${eap}`;
}
function rupeesInt(p: number) { return `₹${Math.round(p / 100)}`; }
function durLabel(m: number) {
  if (m < 60) return `${m}m`;
  if (m % 60 === 0) return `${m / 60}h`;
  return `${Math.floor(m / 60)}h ${m % 60}m`;
}
function getToday() {
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
}
function addDays(s: string, n: number) {
  const d = new Date(s + "T00:00:00"); d.setDate(d.getDate() + n);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
}
function fmtDateShort(s: string) {
  const d = new Date(s + "T00:00:00");
  return d.toLocaleDateString("en-IN", { weekday: "short", day: "numeric", month: "short" });
}
function shortDate(s: string) {
  const d = new Date(s + "T00:00:00");
  return { day: String(d.getDate()), wd: ["SUN","MON","TUE","WED","THU","FRI","SAT"][d.getDay()] };
}

// ── Inline icon glyphs (Lucide-ish, stroke=currentColor) ──────────────────
const sv = { width: 22, height: 22, viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", strokeWidth: 1.6, strokeLinecap: "round" as const, strokeLinejoin: "round" as const };
const IconNet     = (<svg {...sv}><path d="M4 4v16M9 4v16M14 4v16M19 4v16M4 9h16M4 14h16M4 19h16"/></svg>);
const IconGround  = (<svg {...sv}><ellipse cx="12" cy="12" rx="9" ry="6"/><circle cx="12" cy="12" r="2.2"/></svg>);
const IconTurf    = (<svg {...sv}><path d="M3 18l3-4M7 18l3-4M11 18l3-4M15 18l3-4M19 18l2-3"/><path d="M3 14l3-4M7 14l3-4M11 14l3-4M15 14l3-4M19 14l2-3"/></svg>);
const IconCement  = (<svg {...sv}><rect x="3" y="4" width="8" height="6"/><rect x="13" y="4" width="8" height="6"/><rect x="3" y="14" width="8" height="6"/><rect x="13" y="14" width="8" height="6"/></svg>);
const IconMat     = (<svg {...sv}><rect x="3" y="9" width="18" height="6" rx="1"/><path d="M6 12h12"/></svg>);
const IconClock4  = (<svg {...sv}><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3.5 2"/></svg>);
const IconClock8  = (<svg {...sv}><circle cx="12" cy="12" r="9"/><path d="M12 7v5l-3.5 4"/></svg>);
const IconSun     = (<svg {...sv}><circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M2 12h2M20 12h2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/></svg>);
const IconMonthly = (<svg {...sv}><rect x="3" y="5" width="18" height="16" rx="1.5"/><path d="M3 10h18M8 3v4M16 3v4"/></svg>);
const IconBulk    = (<svg {...sv}><rect x="3" y="3" width="14" height="6"/><rect x="5" y="9.5" width="14" height="6"/><rect x="7" y="16" width="14" height="6"/></svg>);

function variantIcon(type: string) {
  const t = type.toUpperCase();
  if (t === "TURF") return IconTurf;
  if (t === "CEMENT") return IconCement;
  if (t === "MAT") return IconMat;
  return IconNet;
}
function variantSub(type: string) {
  const t = type.toUpperCase();
  if (t === "TURF") return "Premium playing surface";
  if (t === "CEMENT") return "Standard practice surface";
  if (t === "MAT") return "Soft mat · spinner friendly";
  return "Standard surface";
}
function bundleIcon(mins: number) {
  if (mins <= 240) return IconClock4;
  if (mins <= 480) return IconClock8;
  return IconSun;
}
function bundleSub(mins: number) {
  if (mins <= 240) return "Half a session · perfect for friendlies";
  if (mins <= 480) return "Longer session · double-header";
  return "All-day rental · 12+ hours";
}

export default function BookingFlow({ units, arenaId, arenaSlug, apiBaseUrl, arenaName = "", address, latitude, longitude, phone, openTime, closeTime }: Props) {
  const today = getToday();
  const [unitId, setUnitId] = useState(units[0]?.id ?? "");
  const [selectedVariant, setSelectedVariant] = useState<string>(units[0]?.netVariants?.[0]?.type ?? "");
  const [date, setDate] = useState("");
  const [slotUnits, setSlotUnits] = useState<SlotUnit[]>([]);
  const [durMins, setDurMins] = useState(() => {
    const u = units[0];
    if (!u || GROUND_TYPES.has(u.unitType ?? "")) return 0;
    return u.minSlotMins ?? 60;
  });
  const [selectedStart, setSelectedStart] = useState("");
  const [guestName, setGuestName] = useState("");
  const [guestPhone, setGuestPhone] = useState("");
  const [step, setStep] = useState<"date" | "slot" | "form" | "done" | "pass" | "bulk">("date");
  const [selectedTypeCategory, setSelectedTypeCategory] = useState<string | null>(null);
  const [selectedAddons, setSelectedAddons] = useState<Set<string>>(new Set());
  // monthly pass state
  const [passDays] = useState<number[]>([1, 2, 3, 4, 5, 6, 7]);
  const [passStartTime, setPassStartTime] = useState("06:00");
  const [passEndTime, setPassEndTime] = useState("07:00");
  const [passStartDate, setPassStartDate] = useState(getToday());
  const [passMonths, setPassMonths] = useState(1);
  // bulk booking state
  const [bulkMode, setBulkMode] = useState<"range" | "custom">("range");
  const [bulkStartDate, setBulkStartDate] = useState(getToday());
  const [bulkEndDate, setBulkEndDate] = useState(getToday());
  const [bulkCustomDates, setBulkCustomDates] = useState<Set<string>>(new Set());
  const [loading, setLoading] = useState(false);
  const [submitting, startSubmit] = useTransition();
  const [error, setError] = useState("");
  const [bookingRef, setBookingRef] = useState("");
  const [dateAvail, setDateAvail] = useState<Record<string, { total: number; avail: number }>>({});
  const [showSaveModal, setShowSaveModal] = useState(false);
  const slotRef = useRef<HTMLDivElement>(null);

  // Prevent page scroll when user swipes horizontally on carousels (iOS fix)
  useEffect(() => {
    const els = document.querySelectorAll<HTMLElement>(".scrollbar-none");
    const cleanups: (() => void)[] = [];
    els.forEach((el) => {
      let startX = 0, startY = 0, isH = false, decided = false;
      const onStart = (e: TouchEvent) => {
        startX = e.touches[0].clientX;
        startY = e.touches[0].clientY;
        isH = false; decided = false;
      };
      const onMove = (e: TouchEvent) => {
        if (!decided) {
          const dx = Math.abs(e.touches[0].clientX - startX);
          const dy = Math.abs(e.touches[0].clientY - startY);
          if (dx > 4 || dy > 4) { isH = dx >= dy; decided = true; }
        }
        if (isH) e.preventDefault();
      };
      el.addEventListener("touchstart", onStart, { passive: true });
      el.addEventListener("touchmove", onMove, { passive: false });
      cleanups.push(() => {
        el.removeEventListener("touchstart", onStart);
        el.removeEventListener("touchmove", onMove);
      });
    });
    return () => cleanups.forEach((fn) => fn());
  }, [step]);

  // Helper: compute availability for one fetched unit, respecting past-slot cutoff for today
  const computeAvail = useCallback((su: SlotUnit, dm: number, d: string) => {
    const todayStr = getToday();
    const nowMins = d === todayStr ? (() => { const n = new Date(); return n.getHours() * 60 + n.getMinutes(); })() : -1;
    const openM = toMins(su.openTime ?? (openTime ?? "06:00"));
    const closeM = toMins(su.closeTime ?? (closeTime ?? "23:00"));
    const inc = su.slotIncrementMins ?? su.minSlotMins ?? 60;
    const booked = su.bookedSlots ?? [];
    let total = 0, avail = 0;
    for (let s = openM; s + dm <= closeM; s += inc) {
      if (nowMins >= 0 && s < nowMins) continue; // skip past slots for today
      const st = toTime(s); const et = toTime(s + dm);
      total++;
      if (!booked.some(b => b.startTime < et && b.endTime > st)) avail++;
    }
    return { total, avail };
  }, [openTime, closeTime]);

  // Batch-fetch slot availability for all 14 visible dates
  useEffect(() => {
    if (step !== "slot") return;
    setDateAvail({});
    let cancelled = false;
    const dm = durMins || 60;
    const dates14 = Array.from({ length: 14 }, (_, i) => addDays(getToday(), i));
    dates14.forEach(async (d) => {
      try {
        const res = await fetch(`/api/arena/${arenaId}/booking-context?date=${d}&durationMins=${dm}&includeAvailability=true`);
        if (!res.ok || cancelled) return;
        const body = await res.json() as { data?: { availability?: Array<{ unit?: SlotUnit; slots?: Array<{ start: string; end: string; available: boolean }> }> } };
        const su = (body.data?.availability ?? []).find((entry) => entry.unit?.id === unitId)?.unit;
        if (!su || cancelled) return;
        const result = computeAvail(su, dm, d);
        if (!cancelled) setDateAvail(prev => ({ ...prev, [d]: result }));
      } catch {}
    });
    return () => { cancelled = true; };
  }, [step, unitId, arenaId, durMins, computeAvail]);

  // Re-fetch a single date's availability (called after a booking is confirmed)
  const refreshDateAvail = useCallback(async (d: string) => {
    try {
      const res = await fetch(`/api/arena/${arenaId}/booking-context?date=${d}&durationMins=${durMins || 60}&includeAvailability=true`);
      if (!res.ok) return;
      const body = await res.json() as { data?: { availability?: Array<{ unit?: SlotUnit }> } };
      const su = (body.data?.availability ?? []).find((entry) => entry.unit?.id === unitId)?.unit;
      if (!su) return;
      const result = computeAvail(su, durMins || 60, d);
      setDateAvail(prev => ({ ...prev, [d]: result }));
    } catch {}
  }, [arenaId, unitId, durMins, computeAvail]);

  const unit = units.find((u) => u.id === unitId);
  const isGround = GROUND_TYPES.has(unit?.unitType ?? "");
  const slotUnit = slotUnits.find((u) => u.id === unitId);
  const open = openTime ?? "06:00";
  const close = closeTime ?? "23:00";

  const fetchSlots = useCallback(async (d: string) => {
    setLoading(true); setSlotUnits([]); setSelectedStart("");
    try {
      const effectiveDuration = durMins || 60;
      const res = await fetch(`/api/arena/${arenaId}/booking-context?date=${d}&durationMins=${effectiveDuration}&includeAvailability=true`);
      if (!res.ok) throw new Error();
      const body = (await res.json()) as { data?: { availability?: Array<{ unit?: SlotUnit; slots?: Array<{ start: string; end: string; available: boolean }> }> } };
      const fetched = (body.data?.availability ?? [])
        .map((entry) => {
          const unitData = entry.unit;
          if (!unitData) return null;
          const bookedSlots = (entry.slots ?? [])
            .filter((slot) => !slot.available)
            .map((slot) => ({ startTime: slot.start, endTime: slot.end }));
          return { ...unitData, bookedSlots } as SlotUnit;
        })
        .filter(Boolean) as SlotUnit[];
      setSlotUnits(fetched);
      // Only seed durMins from API if not already set by the user
      setDurMins((cur) => {
        if (cur > 0) return cur;
        const u = fetched.find((x) => x.id === unitId);
        if (u && !GROUND_TYPES.has(unit?.unitType ?? "")) return u.minSlotMins ?? 60;
        return cur;
      });
    } catch { setError("Couldn't load slots. Try again."); }
    finally { setLoading(false); }
  }, [arenaId, durMins, unitId, unit]);

  function handleDateSelect(d: string) {
    setDate(d); setStep("slot"); fetchSlots(d);
    setTimeout(() => slotRef.current?.scrollIntoView({ behavior: "smooth", block: "nearest" }), 120);
  }

  function handleUnitChange(id: string) {
    setUnitId(id); setSelectedStart("");
    const su = units.find((x) => x.id === id);
    setSelectedVariant(su?.netVariants?.[0]?.type ?? "");
    const fetched = slotUnits.find((x) => x.id === id);
    const staticU = units.find((x) => x.id === id);
    const isGr = GROUND_TYPES.has(staticU?.unitType ?? "");
    if (fetched) {
      setDurMins(fetched.minSlotMins ?? 60);
    } else if (!isGr) {
      setDurMins(staticU?.minSlotMins ?? 60);
    } else {
      setDurMins(0);
    }
  }

  function groundBundles() {
    if (!unit) return [];
    const b: { mins: number; label: string; paise: number }[] = [];
    if (unit.price4HrPaise) b.push({ mins: 240, label: "4 hrs", paise: unit.price4HrPaise });
    if (unit.price8HrPaise) b.push({ mins: 480, label: "8 hrs", paise: unit.price8HrPaise });
    if (unit.priceFullDayPaise) b.push({ mins: 720, label: "Full day", paise: unit.priceFullDayPaise });
    return b;
  }

  const bundles = isGround ? groundBundles() : [];
  const useGroundBundles = isGround && bundles.length > 0;
  const netVariants = (!isGround && unit?.netVariants?.length) ? unit.netVariants : [];
  const activeVariant = netVariants.find((v) => v.type === selectedVariant) ?? netVariants[0] ?? null;

  const unitAddons = (unit?.addons ?? []).filter(a => a.pricePaise > 0);
  const addonTotal = [...selectedAddons].reduce((sum, id) => {
    const a = unitAddons.find(a => a.id === id);
    return sum + (a?.pricePaise ?? 0);
  }, 0);

  function calcPrice() {
    if (!durMins) return 0;
    if (useGroundBundles) return bundles.find((b) => b.mins === durMins)?.paise ?? 0;
    const pricePerHr = activeVariant?.pricePaise ?? unit?.pricePerHourPaise ?? 0;
    return Math.round((pricePerHr * durMins) / 60);
  }
  const basePaise = calcPrice();
  const totalPaise = basePaise + addonTotal;

  function getAllSlots() {
    if (!durMins) return [];
    const openM = toMins(slotUnit?.openTime ?? open);
    const closeM = toMins(slotUnit?.closeTime ?? close);
    const inc = slotUnit?.slotIncrementMins ?? slotUnit?.minSlotMins ?? 60;
    const booked = slotUnit?.bookedSlots ?? [];
    const nowMins = date === today ? (() => { const n = new Date(); return n.getHours() * 60 + n.getMinutes(); })() : -1;
    const slots: { start: string; end: string; available: boolean; peak: boolean }[] = [];
    for (let s = openM; s + durMins <= closeM; s += inc) {
      if (nowMins >= 0 && s < nowMins) continue; // hide already-started slots for today
      const st = toTime(s); const et = toTime(s + durMins);
      const peak = s >= PEAK_START && s < PEAK_END;
      const busy = booked.some((b) => b.startTime < et && b.endTime > st);
      slots.push({ start: st, end: et, available: !busy, peak });
    }
    return slots;
  }

  const allSlots = (step === "slot" && !loading) ? getAllSlots() : [];
  const availableCount = allSlots.filter((s) => s.available).length;

  function handleSubmit() {
    if (!guestName.trim() || !guestPhone.trim()) { setError("Enter your name and phone number."); return; }
    setError("");
    const endTime = toTime(toMins(selectedStart) + durMins);
    startSubmit(async () => {
      try {
        const bookingPayload = {
          arenaUnitId: unitId,
          bookingDate: date,
          startTime: selectedStart,
          endTime,
          totalPricePaise: totalPaise,
          guestName: guestName.trim(),
          guestPhone: guestPhone.trim(),
        };

        const res = await fetch("/api/bookings", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(bookingPayload),
        });
        const data = (await res.json()) as { success?: boolean; error?: string; data?: { id?: string } };
        if (!res.ok || !data.success) { setError(data.error ?? "Booking failed. Slot may have been taken."); return; }
        setBookingRef(data.data?.id?.slice(-8).toUpperCase() ?? "OK");
        refreshDateAvail(date);
        setShowSaveModal(true);
        setStep("done");
      } catch { setError("Network error. Try again."); }
    });
  }

  function handlePassSubmit() {
    if (!guestName.trim() || !guestPhone.trim()) { setError("Enter your name and phone number."); return; }
    setError("");
    startSubmit(async () => {
      try {
        const res = await fetch("/api/monthly-passes", {
          method: "POST", headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ arenaUnitId: unitId, startTime: passStartTime, endTime: passEndTime, daysOfWeek: passDays, startDate: passStartDate, months: passMonths, guestName: guestName.trim(), guestPhone: guestPhone.trim() }),
        });
        const data = (await res.json()) as { success?: boolean; error?: string; data?: { id?: string } };
        if (!res.ok || !data.success) { setError(data.error ?? "Failed. Try again."); return; }
        setBookingRef(data.data?.id?.slice(-8).toUpperCase() ?? "OK");
        setShowSaveModal(true);
        setStep("done");
      } catch { setError("Network error. Try again."); }
    });
  }

  // Compute the dates the user has chosen for bulk booking
  function getBulkDates(): string[] {
    if (bulkMode === "custom") return Array.from(bulkCustomDates).sort();
    // range mode: every date between start and end (inclusive)
    const out: string[] = [];
    let d = bulkStartDate;
    while (d <= bulkEndDate) { out.push(d); d = addDays(d, 1); }
    return out;
  }

  function handleBulkSubmit() {
    if (!guestName.trim() || !guestPhone.trim()) { setError("Enter your name and phone number."); return; }
    const bulkSelectedDates = getBulkDates();
    if (bulkSelectedDates.length === 0) { setError("Pick at least one date."); return; }
    setError("");
    startSubmit(async () => {
      try {
        const res = await fetch("/api/bulk-bookings", {
          method: "POST", headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            arenaUnitId: unitId,
            startTime: openTime ?? "00:00",
            endTime: closeTime ?? "23:59",
            startDate: bulkSelectedDates[0],
            numDays: bulkSelectedDates.length,
            dates: bulkSelectedDates,
            isFullDay: true,
            guestName: guestName.trim(),
            guestPhone: guestPhone.trim(),
          }),
        });
        const data = (await res.json()) as { success?: boolean; error?: string; data?: { numDays?: number; totalAmountPaise?: number } };
        if (!res.ok || !data.success) { setError(data.error ?? "Failed. Try again."); return; }
        setBookingRef(`${data.data?.numDays ?? bulkSelectedDates.length}D`);
        setShowSaveModal(true);
        setStep("done");
      } catch { setError("Network error. Try again."); }
    });
  }

  const dates = Array.from({ length: 14 }, (_, i) => addDays(today, i));

  const savePass = async () => {
    const endTime = selectedStart ? toTime(toMins(selectedStart) + durMins) : "";
    const W = 720, H = 1060;
    const canvas = document.createElement("canvas");
    canvas.width = W; canvas.height = H;
    const ctx = canvas.getContext("2d")!;
    const accent = "#C8FF3E";

    // ── helpers
    const line = (x1: number, y1: number, x2: number, y2: number, color: string, dash: number[] = []) => {
      ctx.save(); ctx.strokeStyle = color; ctx.lineWidth = 1; ctx.setLineDash(dash);
      ctx.beginPath(); ctx.moveTo(x1, y1); ctx.lineTo(x2, y2); ctx.stroke(); ctx.restore();
    };
    const label = (text: string, x: number, y: number) => {
      ctx.fillStyle = "rgba(255,255,255,0.28)"; ctx.font = "600 9px system-ui,sans-serif";
      ctx.letterSpacing = "0.08em"; ctx.fillText(text, x, y); ctx.letterSpacing = "0px";
    };
    const wrapText = (text: string, x: number, y: number, maxW: number, lineH: number): number => {
      const words = text.split(" "); let cur = ""; let cy = y;
      for (const w of words) {
        const test = cur ? `${cur} ${w}` : w;
        if (ctx.measureText(test).width > maxW && cur) {
          ctx.fillText(cur, x, cy); cur = w; cy += lineH;
        } else cur = test;
      }
      if (cur) ctx.fillText(cur, x, cy);
      return cy;
    };

    // ── Background
    ctx.fillStyle = "#0A0B0A"; ctx.fillRect(0, 0, W, H);

    // ── Glows
    const g1 = ctx.createRadialGradient(W, 0, 0, W, 0, 420);
    g1.addColorStop(0, "rgba(200,255,62,0.18)"); g1.addColorStop(1, "rgba(200,255,62,0)");
    ctx.fillStyle = g1; ctx.fillRect(0, 0, W, H);
    const g2 = ctx.createRadialGradient(0, H, 0, 0, H, 320);
    g2.addColorStop(0, "rgba(200,255,62,0.07)"); g2.addColorStop(1, "rgba(200,255,62,0)");
    ctx.fillStyle = g2; ctx.fillRect(0, 0, W, H);

    // ── Left accent bar
    ctx.fillStyle = accent; ctx.fillRect(0, 0, 6, H);

    // ── CONFIRMED pill
    ctx.fillStyle = "rgba(200,255,62,0.13)";
    ctx.beginPath(); ctx.roundRect(W - 178, 22, 142, 26, 13); ctx.fill();
    ctx.fillStyle = accent; ctx.font = "600 10px system-ui,sans-serif";
    ctx.textAlign = "right"; ctx.fillText("✓  CONFIRMED", W - 36, 39); ctx.textAlign = "left";

    // ── Brand header
    ctx.fillStyle = accent; ctx.font = "800 15px system-ui,sans-serif"; ctx.fillText("SWING", 36, 44);
    ctx.fillStyle = "rgba(255,255,255,0.22)"; ctx.font = "500 10px system-ui,sans-serif"; ctx.fillText("BOOKING PASS", 36, 60);

    // ── Arena name (with wrap)
    ctx.fillStyle = "white"; ctx.font = "800 34px system-ui,sans-serif";
    const nameMaxW = W - 80;
    let nameEndY = 108;
    if (ctx.measureText(arenaName).width > nameMaxW) {
      const words = arenaName.split(" "); let l1 = "", l2 = "";
      for (const w of words) {
        if (ctx.measureText((l1 ? l1 + " " : "") + w).width < nameMaxW) l1 = l1 ? l1 + " " + w : w;
        else l2 = l2 ? l2 + " " + w : w;
      }
      ctx.fillText(l1, 36, 108); ctx.fillText(l2, 36, 148); nameEndY = 148;
    } else {
      ctx.fillText(arenaName, 36, 108);
    }

    // Unit chip
    ctx.fillStyle = "rgba(200,255,62,0.12)";
    ctx.beginPath(); ctx.roundRect(36, nameEndY + 14, (ctx.measureText(unit?.name ?? "").width + 24), 24, 12); ctx.fill();
    ctx.fillStyle = accent; ctx.font = "600 11px system-ui,sans-serif";
    ctx.fillText(unit?.name ?? "", 48, nameEndY + 31);

    // ── Divider 1
    const d1y = nameEndY + 52;
    line(36, d1y, W - 36, d1y, "rgba(255,255,255,0.08)");

    // ── 3-col info grid
    const infoY = d1y + 28;
    const colW = (W - 72) / 3;
    [
      { l: "DATE",     v: date ? fmtDateShort(date) : "—" },
      { l: "TIME",     v: selectedStart && endTime ? `${fmt12(selectedStart)} – ${fmt12(endTime)}` : "—" },
      { l: "DURATION", v: durMins ? durLabel(durMins) : "—" },
    ].forEach(({ l, v }, i) => {
      const x = 36 + i * colW;
      label(l, x, infoY);
      ctx.fillStyle = "white"; ctx.font = "700 19px system-ui,sans-serif"; ctx.fillText(v, x, infoY + 26);
    });

    // ── Booking ID panel
    const bidY = infoY + 58;
    ctx.fillStyle = "rgba(200,255,62,0.06)"; ctx.strokeStyle = "rgba(200,255,62,0.2)"; ctx.lineWidth = 1;
    ctx.beginPath(); ctx.roundRect(36, bidY, W - 72, 68, 12); ctx.fill(); ctx.stroke();
    label("BOOKING ID", 56, bidY + 20);
    ctx.fillStyle = accent; ctx.font = "700 28px system-ui,sans-serif"; ctx.fillText(`SW-${bookingRef}`, 56, bidY + 50);

    // ── Guest + Amount
    const gaY = bidY + 94;
    label("GUEST", 36, gaY);
    ctx.fillStyle = "white"; ctx.font = "600 15px system-ui,sans-serif"; ctx.fillText(guestName || "—", 36, gaY + 20);
    ctx.textAlign = "right";
    label("PAYMENT", W - 36, gaY);
    ctx.textAlign = "right";
    ctx.fillStyle = "white"; ctx.font = "700 15px system-ui,sans-serif"; ctx.fillText("At venue", W - 36, gaY + 20);
    ctx.textAlign = "left";

    // ── Location
    const locY = gaY + 58;
    if (address) {
      label("LOCATION", 36, locY);
      ctx.fillStyle = "rgba(255,255,255,0.65)"; ctx.font = "500 13px system-ui,sans-serif";
      wrapText(address, 36, locY + 18, W - 72, 18);
    }

    // ── Tear line
    const tearY = 560;
    ctx.fillStyle = "#0A0B0A";
    ctx.beginPath(); ctx.arc(-1, tearY, 18, 0, Math.PI * 2); ctx.fill();
    ctx.beginPath(); ctx.arc(W + 1, tearY, 18, 0, Math.PI * 2); ctx.fill();
    line(24, tearY, W - 24, tearY, "rgba(255,255,255,0.14)", [5, 5]);
    ctx.fillStyle = "rgba(255,255,255,0.18)"; ctx.font = "600 8px system-ui,sans-serif";
    ctx.textAlign = "center"; ctx.fillText("TERMS & CONDITIONS", W / 2, tearY - 10); ctx.textAlign = "left";

    // ── Terms section
    const cancHours = unit?.cancellationHours ?? 0;
    const terms = [
      cancHours > 0
        ? `Free cancellation up to ${cancHours}h before slot. Cancellations within ${cancHours}h are non-refundable.`
        : "Cancellation policy applies — contact the arena for details.",
      "Full payment is collected at the venue on the day of your booking.",
      "Arrive at least 10 minutes before your slot start time.",
      "Show this pass at the front desk upon entry.",
      "This pass is non-transferable and valid only for the date shown.",
      "The arena reserves the right to reschedule due to unforeseen circumstances.",
    ];
    const tTitleY = tearY + 28;
    ctx.fillStyle = "rgba(255,255,255,0.22)"; ctx.font = "700 9px system-ui,sans-serif";
    ctx.letterSpacing = "0.1em"; ctx.fillText("TERMS & CANCELLATION POLICY", 36, tTitleY); ctx.letterSpacing = "0px";
    ctx.fillStyle = "rgba(255,255,255,0.40)"; ctx.font = "400 11.5px system-ui,sans-serif";
    terms.forEach((t, i) => ctx.fillText(`${i + 1}.  ${t}`, 36, tTitleY + 22 + i * 22));

    // ── Divider 2
    const d2y = tTitleY + 22 + terms.length * 22 + 18;
    line(36, d2y, W - 36, d2y, "rgba(255,255,255,0.06)");

    // ── Barcode visual
    const bcY = d2y + 20; const bcH = 40;
    [3,1,2,1,3,2,1,1,3,1,2,3,1,2,1,3,1,1,2,1,3,1,2,1,3,2,1,1,2,3,1,2].forEach((w, i) => {
      if (i % 2 === 0) {
        ctx.fillStyle = `rgba(255,255,255,${0.45 + (i % 4) * 0.08})`;
        ctx.fillRect(36 + i * 6.5, bcY, w * 2, bcH);
      }
    });
    ctx.fillStyle = "rgba(255,255,255,0.35)"; ctx.font = "600 10px system-ui,sans-serif";
    ctx.textAlign = "right"; ctx.fillText("swing.app", W - 36, bcY + bcH / 2 + 4); ctx.textAlign = "left";

    // ── Footer strip
    ctx.fillStyle = accent; ctx.fillRect(0, H - 6, W, 6);
    ctx.fillStyle = "rgba(255,255,255,0.16)"; ctx.font = "500 9px system-ui,sans-serif";
    ctx.textAlign = "center";
    ctx.fillText("ARRIVE 10 MIN EARLY  ·  SHOW AT FRONT DESK  ·  VALID FOR DATE SHOWN ONLY", W / 2, H - 18);
    ctx.textAlign = "left";

    canvas.toBlob(async (blob) => {
      if (!blob) return;
      const file = new File([blob], `swing-pass-${bookingRef}.png`, { type: "image/png" });
      if (typeof navigator !== "undefined" && navigator.share && navigator.canShare?.({ files: [file] })) {
        await navigator.share({ files: [file], title: "Booking Pass" });
      } else {
        const url = URL.createObjectURL(blob);
        const a = document.createElement("a"); a.href = url; a.download = file.name; a.click();
        URL.revokeObjectURL(url);
      }
    }, "image/png");
  };

  // ── Confirmation screen ─────────────────────────────────────────────────
  if (step === "done") {
    const endTime = selectedStart ? toTime(toMins(selectedStart) + durMins) : "";
    const mapsUrl = latitude && longitude
      ? `https://www.google.com/maps/dir/?api=1&destination=${latitude},${longitude}`
      : address
        ? `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(address)}`
        : null;

    return (
      <>
        {/* Save Pass modal — bottom sheet, shown immediately on confirmation */}
        {showSaveModal && (
          <div
            style={{ position: "fixed", inset: 0, background: "rgba(0,0,0,0.82)", zIndex: 999, display: "flex", flexDirection: "column", justifyContent: "flex-end" }}
            onClick={() => setShowSaveModal(false)}
          >
            <div
              style={{ background: "#0D0E0D", borderRadius: "20px 20px 0 0", padding: "20px 24px 44px", position: "relative" }}
              onClick={(e) => e.stopPropagation()}
            >
              <div style={{ width: 36, height: 4, borderRadius: 999, background: "rgba(255,255,255,0.18)", margin: "0 auto 28px" }} />
              <div style={{ display: "flex", justifyContent: "center", marginBottom: 20 }}>
                <div style={{ width: 64, height: 64, borderRadius: "50%", background: "#C8FF3E", display: "grid", placeItems: "center" }}>
                  <svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="#0A0B0A" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                </div>
              </div>
              <div style={{ textAlign: "center", marginBottom: 28 }}>
                <div style={{ fontFamily: "var(--font-ui)", fontWeight: 800, fontSize: 24, color: "white", lineHeight: 1.15, marginBottom: 8 }}>Booking Confirmed!</div>
                <div style={{ font: "500 13px var(--font-ui)", color: "rgba(255,255,255,0.5)" }}>
                  {unit?.name} · <span style={{ color: "#C8FF3E" }}>SW-{bookingRef}</span>
                </div>
                {date && selectedStart && (
                  <div style={{ font: "500 12px var(--font-ui)", color: "rgba(255,255,255,0.38)", marginTop: 5 }}>
                    {fmtDateShort(date)} · {fmt12(selectedStart)} → {fmt12(endTime)}
                  </div>
                )}
              </div>
              <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
                <button onClick={savePass} style={{ width: "100%", padding: "15px", borderRadius: 999, font: "700 14px var(--font-ui)", background: "#C8FF3E", color: "#0A0B0A", border: "none", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 8 }}>
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                  Save Pass to Gallery
                </button>
                <button onClick={() => setShowSaveModal(false)} style={{ width: "100%", padding: "14px", borderRadius: 999, font: "600 13px var(--font-ui)", background: "transparent", color: "rgba(255,255,255,0.55)", border: "1px solid rgba(255,255,255,0.15)", cursor: "pointer" }}>
                  View Booking Details
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Confirmation page — visible after modal is dismissed */}
        <div style={{ background: "#0A0B0A", color: "white", padding: "0 20px 48px", position: "relative", overflowX: "hidden" }}>
        {/* glow */}
        <div style={{ position: "absolute", top: -80, right: -80, width: 300, height: 300, borderRadius: "50%", background: "#C8FF3E", filter: "blur(100px)", opacity: 0.25, pointerEvents: "none", zIndex: 0 }} />

        {/* nav */}
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "20px 0 0", position: "relative", zIndex: 1 }}>
          <button onClick={() => { setStep("date"); setDate(""); setSelectedStart(""); }} style={{ width: 36, height: 36, borderRadius: "50%", border: "1px solid rgba(255,255,255,0.15)", background: "transparent", color: "white", cursor: "pointer", display: "grid", placeItems: "center" }}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="M15 18l-6-6 6-6"/></svg>
          </button>
          <span style={{ font: "600 10px var(--font-ui)", color: "#C8FF3E", letterSpacing: "0.1em", textTransform: "uppercase" }}>Booking Confirmed</span>
          <div style={{ width: 36 }} />
        </div>

        <div style={{ position: "relative", zIndex: 1, paddingTop: 24 }}>
          {/* tick + headline */}
          <div style={{ display: "flex", alignItems: "center", gap: 14, marginBottom: 20 }}>
            <div style={{ width: 52, height: 52, borderRadius: "50%", background: "#C8FF3E", color: "#0A0B0A", display: "grid", placeItems: "center", flexShrink: 0 }}>
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
            </div>
            <div>
              <div style={{ fontFamily: "var(--font-ui)", fontWeight: 800, fontSize: 22, color: "white", lineHeight: 1.1 }}>{unit?.name} is yours.</div>
              <div style={{ font: "500 11px var(--font-ui)", color: "rgba(255,255,255,0.4)", marginTop: 3 }}>ID · SW-{bookingRef}</div>
            </div>
          </div>

          {/* booking details card */}
          <div style={{ borderRadius: "var(--r-lg)", background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.08)", overflow: "hidden", marginBottom: 12 }}>
            {([
              ["Date", fmtDateShort(date)],
              ["Time", `${fmt12(selectedStart)} → ${fmt12(endTime)}`],
              ["Duration", durLabel(durMins)],
              ["Payment", "Collected at venue"],
              ["Guest", guestName],
            ].filter(Boolean) as [string, string][]).map(([label, val], i, arr) => (
              <div key={label} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "11px 16px", borderBottom: i < arr.length - 1 ? "1px solid rgba(255,255,255,0.06)" : "none", font: "500 12px var(--font-ui)", color: "rgba(255,255,255,0.5)" }}>
                <span>{label}</span>
                <b style={{ color: "white", fontFamily: "var(--font-ui)", fontWeight: 600, fontSize: 12 }}>{val}</b>
              </div>
            ))}
          </div>

          {/* address / directions card */}
          {address && (
            <div style={{ borderRadius: "var(--r-lg)", background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.08)", padding: "14px 16px", marginBottom: 12, display: "flex", alignItems: "center", gap: 12 }}>
              <div style={{ flex: 1 }}>
                <div style={{ font: "600 10px var(--font-ui)", color: "rgba(255,255,255,0.35)", letterSpacing: "0.08em", textTransform: "uppercase", marginBottom: 4 }}>Location</div>
                <div style={{ font: "500 13px var(--font-ui)", color: "rgba(255,255,255,0.8)", lineHeight: 1.4 }}>{address}</div>
              </div>
              {mapsUrl && (
                <a href={mapsUrl} target="_blank" rel="noopener noreferrer" style={{ flexShrink: 0, padding: "9px 14px", borderRadius: 999, background: "#C8FF3E", color: "#0A0B0A", font: "700 12px var(--font-ui)", textDecoration: "none", whiteSpace: "nowrap" }}>
                  Directions
                </a>
              )}
            </div>
          )}

          {/* arrive notice */}
          <div style={{ padding: "12px 16px", borderRadius: "var(--r-md)", border: "1px dashed rgba(255,255,255,0.1)", font: "500 11px var(--font-ui)", color: "rgba(255,255,255,0.4)", letterSpacing: "0.04em", textTransform: "uppercase", marginBottom: 20 }}>
            Arrive 10 min early · Show this screen at front desk
          </div>

          {/* action buttons — inline, always visible */}
          <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
            <button onClick={savePass} style={{ width: "100%", padding: "14px", borderRadius: 999, font: "700 13px var(--font-ui)", background: "#C8FF3E", color: "#0A0B0A", border: "none", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 8 }}>
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
              Save Pass to Gallery
            </button>
            <div style={{ display: "flex", gap: 8 }}>
              {phone && (
                <a href={`tel:${phone}`} style={{ flex: 1, padding: 13, borderRadius: 999, font: "600 13px var(--font-ui)", border: "1px solid rgba(255,255,255,0.15)", background: "transparent", color: "white", textAlign: "center", textDecoration: "none", display: "block" }}>
                  Call Arena
                </a>
              )}
              <button onClick={() => { setStep("date"); setDate(""); setSelectedStart(""); setGuestName(""); setGuestPhone(""); }}
                style={{ flex: 1, padding: 13, borderRadius: 999, font: "600 13px var(--font-ui)", background: "rgba(255,255,255,0.08)", color: "white", border: "1px solid rgba(255,255,255,0.12)", cursor: "pointer" }}>
                Book Again
              </button>
            </div>
          </div>
        </div>
        </div>
      </>
    );
  }

  // ── Step indicator ──────────────────────────────────────────────────────
  const totalSteps = 3;
  const stepNum = step === "date" ? 1 : step === "slot" ? 2 : 3;
  const stepLabels: Record<number, string> = isGround
    ? { 1: "Court", 2: "Slot", 3: "Confirm" }
    : { 1: "Add-ons", 2: "Date & Time", 3: "Confirm" };
  const StepBar = () => (
    <div style={{ display: "flex", alignItems: "center", gap: 0, padding: "22px 20px 0" }}>
      {Array.from({ length: totalSteps }, (_, i) => i + 1).map((n) => {
        const done = stepNum > n;
        const active = stepNum === n;
        return (
          <div key={n} style={{ display: "flex", alignItems: "center", flex: n < totalSteps ? "1 1 auto" : "0 0 auto" }}>
            <div style={{
              width: 28, height: 28, borderRadius: "50%", flexShrink: 0,
              background: active ? "#0A0B0A" : done ? "#0A0B0A" : "var(--paper-2)",
              border: `1.5px solid ${active ? "#C8FF3E" : done ? "#0A0B0A" : "var(--hairline)"}`,
              display: "flex", alignItems: "center", justifyContent: "center",
              fontFamily: "var(--font-ui)", fontWeight: 700, fontSize: 11,
              color: active ? "#C8FF3E" : done ? "#C8FF3E" : "var(--ink-3)",
              transition: "all .2s",
            }}>
              {done ? "✓" : n}
            </div>
            {n < totalSteps && <div style={{ flex: 1, height: 1.5, background: done ? "#0A0B0A" : "var(--hairline)", margin: "0 8px", transition: "background .2s" }} />}
          </div>
        );
      })}
      <div style={{ marginLeft: 12, fontFamily: "var(--font-ui)", fontSize: 12, fontWeight: 600, color: "var(--ink-3)", whiteSpace: "nowrap" }}>
        {stepLabels[stepNum] ?? ""}
      </div>
    </div>
  );

  // ── Screen 1: Unit + Net type ───────────────────────────────────────────
  if (step === "date") {
    // Group units by unitType (treat identical units as one bookable category)
    const categories = (() => {
      const groups = new Map<string, typeof units>();
      for (const u of units) {
        const key = u.unitType ?? "OTHER";
        if (!groups.has(key)) groups.set(key, []);
        groups.get(key)!.push(u);
      }
      return Array.from(groups.entries()).map(([type, items]) => {
        const isNet = type === "CRICKET_NET" || type === "INDOOR_NET";
        const isGr = GROUND_TYPES.has(type);
        const first = items[0];
        // Aggregate variant counts across all units of this type
        const variantMap = new Map<string, { type: string; label: string; pricePaise: number; count: number }>();
        if (isNet) {
          for (const u of items) {
            for (const v of u.netVariants ?? []) {
              const ex = variantMap.get(v.type);
              if (ex) ex.count += 1;
              else variantMap.set(v.type, {
                type: v.type,
                label: v.label,
                pricePaise: v.pricePaise ?? 0,
                count: 1,
              });
            }
          }
        }
        const variants = Array.from(variantMap.values());
        const bundles: { mins: number; label: string; paise: number }[] = [];
        if (isGr) {
          if (first.price4HrPaise) bundles.push({ mins: 240, label: "4 HR", paise: first.price4HrPaise });
          if (first.price8HrPaise) bundles.push({ mins: 480, label: "8 HR", paise: first.price8HrPaise });
          if (first.priceFullDayPaise) bundles.push({ mins: 720, label: "FULL DAY", paise: first.priceFullDayPaise });
        }
        const displayName =
          type === "CRICKET_NET" ? (items.length > 1 ? "NETS" : "NET") :
          type === "INDOOR_NET"  ? "INDOOR NETS" :
          type === "FULL_GROUND" ? "FULL GROUND" :
          type === "HALF_GROUND" ? "HALF GROUND" :
          type === "TURF"        ? "TURF GROUND" :
          type === "MULTI_SPORT" ? "MULTI-SPORT" :
          type.replace(/_/g, " ");
        let priceLabel = "";
        if (isNet && variants.length) {
          const prices = variants.map(v => v.pricePaise).filter(p => p > 0);
          if (prices.length) {
            const lo = Math.round(Math.min(...prices) / 100);
            const hi = Math.round(Math.max(...prices) / 100);
            priceLabel = lo === hi ? `₹${lo}/HR` : `₹${lo}–${hi}/HR`;
          }
        } else if (isGr && bundles.length) {
          const lo = Math.round(bundles[0].paise / 100);
          const hi = Math.round(bundles[bundles.length - 1].paise / 100);
          priceLabel = lo === hi ? `₹${lo}` : `₹${lo}–${hi}`;
        } else if (first.pricePerHourPaise) {
          priceLabel = `₹${Math.round(first.pricePerHourPaise / 100)}/HR`;
        }
        const metaLabel = isNet
          ? `${variants.reduce((s, v) => s + v.count, 0)} SURFACES`
          : isGr
            ? (bundles.length ? `${bundles.length} BLOCK${bundles.length !== 1 ? "S" : ""}` : "1 GROUND")
            : items.length > 1 ? `${items.length} UNITS` : "";
        return { type, items, isNet, isGr, first, variants, bundles, displayName, priceLabel, metaLabel };
      });
    })();

    const selectedCat = selectedTypeCategory
      ? categories.find(c => c.type === selectedTypeCategory) ?? null
      : null;

    // ── Pane A: pick TYPE ────────────────────────────────────────────────
    if (!selectedCat) {
      return (
        <div className="pass-pane">
          <StepBar />
          <div className="pass-h1">Choose your court</div>
          <div className="pass-sub">Pick a type to see available surfaces and pricing.</div>
          <div className="opt-list">
            {categories.map(c => (
              <button key={c.type} className="opt" onClick={() => {
                setSelectedTypeCategory(c.type);
                handleUnitChange(c.first.id);
                if (c.isNet && c.variants.length) setSelectedVariant(c.variants[0].type);
                if (c.isGr && c.bundles.length) setDurMins(c.bundles[0].mins);
              }}>
                <span className="opt-icon">{c.isNet ? IconNet : c.isGr ? IconGround : IconNet}</span>
                <span className="opt-body">
                  <span className="opt-name">{c.displayName}</span>
                  <span className="opt-sub">
                    {c.isNet ? "Cricket nets · book by the hour" :
                     c.isGr  ? "Full ground · book by the block" :
                     "Court · book by the hour"}
                  </span>
                </span>
                <span className="opt-price">{c.priceLabel}</span>
              </button>
            ))}
          </div>
          {error && <div className="opt-err">{error}</div>}
        </div>
      );
    }

    // ── Pane B: pick SURFACE (nets) or BLOCK (grounds) ───────────────────
    const passEnabled = selectedCat.first.monthlyPassEnabled && (selectedCat.first.monthlyPassRatePaise ?? 0) > 0;
    const bulkEnabled = (selectedCat.first.minBulkDays ?? 0) > 0 && (selectedCat.first.bulkDayRatePaise ?? 0) > 0;

    return (
      <div className="pass-pane">
        <StepBar />
        <button className="pass-back" onClick={() => setSelectedTypeCategory(null)}>← BACK</button>
        <div className="pass-h1">{selectedCat.isNet ? "Pick surface" : "Pick duration"}</div>
        <div className="pass-sub">{selectedCat.displayName} · choose how you'd like to play.</div>

        <div className="opt-list">
          {/* Net variants */}
          {selectedCat.isNet && selectedCat.variants.map(v => (
            <button key={v.type} className={`opt ${selectedVariant === v.type ? "selected" : ""}`}
              onClick={() => setSelectedVariant(v.type)}>
              <span className="opt-icon">{variantIcon(v.type)}</span>
              <span className="opt-body">
                <span className="opt-name">{v.label.toUpperCase()}</span>
                <span className="opt-sub">{variantSub(v.type)}</span>
              </span>
              <span className="opt-price">{rupeesInt(v.pricePaise)}/HR</span>
            </button>
          ))}

          {/* Ground bundles */}
          {selectedCat.isGr && selectedCat.bundles.map(b => (
            <button key={b.mins} className={`opt ${durMins === b.mins ? "selected" : ""}`}
              onClick={() => setDurMins(b.mins)}>
              <span className="opt-icon">{bundleIcon(b.mins)}</span>
              <span className="opt-body">
                <span className="opt-name">{b.label}</span>
                <span className="opt-sub">{bundleSub(b.mins)}</span>
              </span>
              <span className="opt-price">{rupeesInt(b.paise)}</span>
            </button>
          ))}

          {/* Monthly Pass — for nets, inline as a row */}
          {selectedCat.isNet && passEnabled && (
            <button className="opt opt-highlight" onClick={() => {
              setStep("pass"); setGuestName(""); setGuestPhone(""); setError("");
            }}>
              <span className="opt-icon">{IconMonthly}</span>
              <span className="opt-body">
                <span className="opt-name">
                  MONTHLY PASS
                  <span className="opt-badge">SAVE</span>
                </span>
                <span className="opt-sub">Fixed daily slot · ideal for regulars</span>
              </span>
              <span className="opt-price">{rupeesInt(selectedCat.first.monthlyPassRatePaise!)}/MO</span>
            </button>
          )}

          {/* Bulk Booking — for grounds, inline as a row */}
          {selectedCat.isGr && bulkEnabled && (
            <button className="opt opt-highlight" onClick={() => {
              setStep("bulk");
              {
                const min = selectedCat.first.minBulkDays ?? 1;
                setBulkMode("range");
                setBulkStartDate(getToday());
                setBulkEndDate(addDays(getToday(), Math.max(0, min - 1)));
                setBulkCustomDates(new Set());
              }
              setGuestName(""); setGuestPhone(""); setError("");
            }}>
              <span className="opt-icon">{IconBulk}</span>
              <span className="opt-body">
                <span className="opt-name">
                  BULK BOOKING
                  <span className="opt-badge">TOURNAMENT</span>
                </span>
                <span className="opt-sub">{selectedCat.first.minBulkDays}+ days · best for camps & events</span>
              </span>
              <span className="opt-price">{rupeesInt(selectedCat.first.bulkDayRatePaise!)}/DAY</span>
            </button>
          )}
        </div>

        {error && <div className="opt-err">{error}</div>}

        <div className="cta-bar">
          <div className="cta-info">
            <div className="cta-amt">
              {selectedCat.isNet && activeVariant
                ? `${activeVariant.label.toUpperCase()}`
                : selectedCat.isGr && durMins
                  ? durLabel(durMins).toUpperCase()
                  : "—"}
            </div>
            <div className="cta-sub">
              {selectedCat.isNet && activeVariant && activeVariant.pricePaise
                ? `${rupeesInt(activeVariant.pricePaise)}/HR · payment at venue`
                : selectedCat.isGr && durMins && totalPaise
                  ? `${rupeesInt(totalPaise)} · payment at venue`
                  : selectedCat.displayName}
            </div>
          </div>
          <button className="cta-btn cta-primary"
            disabled={(selectedCat.isNet && !activeVariant) || (selectedCat.isGr && !durMins)}
            onClick={() => setStep("slot")}>
            CONTINUE
          </button>
        </div>
        <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
      </div>
    );
  }

  // ── Monthly Pass form ──────────────────────────────────────────────────
  const DAY_LABELS = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"];
  if (step === "pass") {
    const passRateMonth = unit?.monthlyPassRatePaise ?? 0;
    const total = passRateMonth * passMonths;
    return (
      <div style={{ background: "var(--paper)", minHeight: "100%", paddingBottom: 96 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 8, padding: "16px 14px 0" }}>
          <button onClick={() => setStep("date")} style={{ width: 28, height: 28, borderRadius: "50%", border: "1px solid var(--hairline)", background: "transparent", color: "var(--ink)", cursor: "pointer", display: "grid", placeItems: "center", flexShrink: 0 }}>
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="M15 18l-6-6 6-6"/></svg>
          </button>
          <div style={{ fontFamily: "var(--font-ui)", fontWeight: 700, fontSize: 14, color: "var(--ink)" }}>Monthly Pass · {unit?.name}</div>
        </div>
        <div style={{ padding: "20px 20px 0", display: "flex", flexDirection: "column", gap: 16 }}>
          <div style={{ display: "flex", gap: 8 }}>
            <div className="form-field" style={{ flex: 1 }}>
              <label className="form-label">Start time</label>
              <input className="form-input" type="time" value={passStartTime} onChange={e => {
                const t = e.target.value;
                setPassStartTime(t);
                const [h, m] = t.split(":").map(Number);
                const endH = (h + 1) % 24;
                setPassEndTime(`${String(endH).padStart(2, "0")}:${String(m).padStart(2, "0")}`);
              }} />
            </div>
            <div className="form-field" style={{ flex: 1 }}>
              <label className="form-label">End time</label>
              <input className="form-input" type="time" value={passEndTime} min={passStartTime} onChange={e => {
                if (e.target.value > passStartTime) setPassEndTime(e.target.value);
              }} />
            </div>
          </div>
          <div style={{ display: "flex", gap: 8 }}>
            <div className="form-field" style={{ flex: 1 }}>
              <label className="form-label">Start date</label>
              <input className="form-input" type="date" min={today} value={passStartDate} onChange={e => setPassStartDate(e.target.value)} />
            </div>
            <div className="form-field" style={{ flex: 1 }}>
              <label className="form-label">Months</label>
              <div className="form-input" style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "0 4px", gap: 4 }}>
                <button onClick={() => setPassMonths(m => Math.max(1, m - 1))} style={{ width: 32, height: 32, borderRadius: "var(--r-sm)", border: "none", background: "var(--paper-2)", color: "var(--ink)", cursor: "pointer", fontWeight: 700, fontSize: 18, flexShrink: 0 }}>−</button>
                <span style={{ fontFamily: "var(--font-ui)", fontWeight: 700, fontSize: 16, color: "var(--ink)", flex: 1, textAlign: "center" }}>{passMonths}</span>
                <button onClick={() => setPassMonths(m => Math.min(12, m + 1))} style={{ width: 32, height: 32, borderRadius: "var(--r-sm)", border: "none", background: "var(--paper-2)", color: "var(--ink)", cursor: "pointer", fontWeight: 700, fontSize: 18, flexShrink: 0 }}>+</button>
              </div>
            </div>
          </div>
          <div style={{ display: "flex", gap: 8 }}>
            <div className="form-field" style={{ flex: 1 }}>
              <label className="form-label">Your name</label>
              <input className="form-input" type="text" placeholder="Full name" value={guestName} onChange={e => setGuestName(e.target.value)} />
            </div>
            <div className="form-field" style={{ flex: 1 }}>
              <label className="form-label">Mobile number</label>
              <input className="form-input" type="tel" placeholder="+91 98765 43210" value={guestPhone} onChange={e => setGuestPhone(e.target.value)} />
            </div>
          </div>
          {error && <div style={{ font: "600 12px var(--font-ui)", color: "var(--bad)" }}>{error}</div>}
        </div>
        <div className="cta-bar">
          <div style={{ flex: 1 }}>
            <div className="cta-amt">{total > 0 ? rupeesInt(total) : "—"}</div>
            <div className="cta-sub">{passMonths} month{passMonths > 1 ? "s" : ""} · pay at venue</div>
          </div>
          <button className="cta-btn" disabled={submitting || !guestName.trim() || !guestPhone.trim()} onClick={handlePassSubmit}>
            {submitting ? "Confirming…" : "Confirm"}
            {!submitting && <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="M5 12h14M13 5l7 7-7 7"/></svg>}
          </button>
        </div>
      </div>
    );
  }

  // ── Bulk Booking form ───────────────────────────────────────────────────
  if (step === "bulk") {
    const minDays = unit?.minBulkDays ?? 1;
    const dayRate = unit?.bulkDayRatePaise ?? 0;
    const picked = getBulkDates();
    const total = dayRate * picked.length;
    const meetsMin = picked.length >= minDays;

    // Build a 6-week calendar grid starting from this Monday
    const gridStart = (() => {
      const d = new Date(today + "T00:00:00");
      const dow = (d.getDay() + 6) % 7; // 0 = Mon
      d.setDate(d.getDate() - dow);
      return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
    })();
    const gridDates = Array.from({ length: 42 }, (_, i) => addDays(gridStart, i));

    const toggleCustomDate = (d: string) => {
      if (d < today) return;
      setBulkCustomDates(prev => {
        const next = new Set(prev);
        if (next.has(d)) next.delete(d); else next.add(d);
        return next;
      });
    };

    return (
      <div className="pass-pane">
        <button className="pass-back" onClick={() => setStep("date")}>← BACK</button>
        <div className="pass-h1">Full day · multi-day</div>
        <div className="pass-sub">Book the ground for {minDays}+ full days. Pick a date range or hand-pick dates.</div>

        {/* Mode toggle */}
        <div className="bulk-modes">
          <button className={`bulk-mode ${bulkMode === "range" ? "active" : ""}`} onClick={() => setBulkMode("range")}>
            DATE RANGE
          </button>
          <button className={`bulk-mode ${bulkMode === "custom" ? "active" : ""}`} onClick={() => setBulkMode("custom")}>
            PICK DATES
          </button>
        </div>

        {/* Range mode */}
        {bulkMode === "range" && (
          <div className="bulk-fields">
            <div className="form-field">
              <label className="form-label">FROM</label>
              <input className="form-input" type="date" min={today} value={bulkStartDate}
                onChange={e => {
                  const v = e.target.value;
                  setBulkStartDate(v);
                  if (bulkEndDate < v) setBulkEndDate(v);
                }} />
            </div>
            <div className="form-field">
              <label className="form-label">TO</label>
              <input className="form-input" type="date" min={bulkStartDate} value={bulkEndDate}
                onChange={e => setBulkEndDate(e.target.value)} />
            </div>
          </div>
        )}

        {/* Custom dates mode */}
        {bulkMode === "custom" && (
          <div className="bulk-cal">
            <div className="bulk-cal-dow">
              {["M","T","W","T","F","S","S"].map((d, i) => <span key={i}>{d}</span>)}
            </div>
            <div className="bulk-cal-grid">
              {gridDates.map(d => {
                const inPast = d < today;
                const selected = bulkCustomDates.has(d);
                const monthNum = Number(d.split("-")[1]);
                const dayNum = Number(d.split("-")[2]);
                const todayMonth = Number(today.split("-")[1]);
                const dim = !inPast && monthNum !== todayMonth && monthNum !== (todayMonth % 12) + 1;
                return (
                  <button key={d}
                    className={`bulk-cal-cell ${selected ? "selected" : ""} ${inPast ? "past" : ""} ${dim ? "dim" : ""}`}
                    disabled={inPast}
                    onClick={() => toggleCustomDate(d)}>
                    {dayNum}
                  </button>
                );
              })}
            </div>
          </div>
        )}

        {/* Guest info */}
        <div className="bulk-guest">
          <div className="form-field">
            <label className="form-label">YOUR NAME</label>
            <input className="form-input" type="text" placeholder="Full name" value={guestName} onChange={e => setGuestName(e.target.value)} />
          </div>
          <div className="form-field">
            <label className="form-label">MOBILE</label>
            <input className="form-input" type="tel" placeholder="+91 98765 43210" value={guestPhone} onChange={e => setGuestPhone(e.target.value)} />
          </div>
        </div>

        {error && <div className="opt-err">{error}</div>}

        <div className="cta-bar">
          <div className="cta-info">
            <div className="cta-amt">{picked.length > 0 ? rupeesInt(total) : "—"}</div>
            <div className="cta-sub">
              {picked.length} day{picked.length !== 1 ? "s" : ""}
              {!meetsMin && minDays > 1 ? ` · min ${minDays}` : " · payment at venue"}
            </div>
          </div>
          <button className="cta-btn cta-primary"
            disabled={submitting || !guestName.trim() || !guestPhone.trim() || !meetsMin}
            onClick={handleBulkSubmit}>
            {submitting ? "BOOKING…" : "CONFIRM BOOKING"}
          </button>
        </div>
      </div>
    );
  }

  // ── Screen 2: Duration + Date + Slots ──────────────────────────────────
  // ── Screen 3: Confirm (addons + cancellation + summary + guest details) ─
  return (
    <div style={{ background: "var(--paper)", minHeight: "100%", paddingBottom: 96 }}>
      <StepBar />

      {/* Back row */}
      {(() => {
        const catLabel =
          selectedTypeCategory === "CRICKET_NET" || selectedTypeCategory === "INDOOR_NET" ? "NETS" :
          selectedTypeCategory === "FULL_GROUND" ? "FULL GROUND" :
          selectedTypeCategory === "HALF_GROUND" ? "HALF GROUND" :
          selectedTypeCategory === "TURF" ? "TURF GROUND" :
          selectedTypeCategory === "MULTI_SPORT" ? "MULTI-SPORT" :
          unit?.name?.toUpperCase() ?? "";
        const contextParts = [
          catLabel,
          activeVariant?.label?.toUpperCase(),
          isGround && durMins ? durLabel(durMins).toUpperCase() : null,
          step === "form" && date ? fmtDateShort(date).toUpperCase() : null,
          step === "form" && selectedStart ? `${fmt12(selectedStart)}–${fmt12(toTime(toMins(selectedStart) + durMins))}` : null,
        ].filter(Boolean) as string[];
        return (
          <div style={{ padding: "10px 0 6px" }}>
            <button className="pass-back" onClick={() => {
              if (step === "form") setStep("slot");
              else { setStep("date"); setDate(""); setSelectedStart(""); setSlotUnits([]); }
            }}>← BACK</button>
            {contextParts.length > 0 && (
              <div className="pass-context">{contextParts.join(" · ")}</div>
            )}
          </div>
        );
      })()}

      {/* ── DURATION (step 2, nets only — grounds already picked block in step 1) ── */}
      {step === "slot" && unit && !isGround && (() => {
        const minM = slotUnit?.minSlotMins || unit.minSlotMins || 60;
        const rawMax = slotUnit?.maxSlotMins || unit.maxSlotMins || 0;
        const maxM = rawMax > minM ? rawMax : 480;
        const inc = slotUnit?.slotIncrementMins || minM;
        if (maxM <= minM) return null; // single fixed duration — don't show stepper
        return (
          <div style={{ padding: "12px 0 0" }}>
            <div className="eyebrow" style={{ marginBottom: 8 }}>DURATION</div>
            <div className="dur-stepper">
              <button className="dur-btn"
                disabled={durMins <= minM}
                onClick={() => { setDurMins(d => d - inc); setSelectedStart(""); }}>−</button>
              <div>
                <div className="dur-val">{durLabel(durMins)}</div>
                {totalPaise > 0 && <div className="dur-price">{rupeesInt(totalPaise)}</div>}
              </div>
              <button className="dur-btn"
                disabled={durMins >= maxM}
                onClick={() => { setDurMins(d => d + inc); setSelectedStart(""); }}>+</button>
            </div>
          </div>
        );
      })()}

      {/* ── CONFIRM (add-ons + cancellation + summary + guest details) ─────── */}
      {step === "form" && (() => {
        const cancHours = unit?.cancellationHours ?? 0;
        return (
        <div style={{ padding: "14px 14px 0", display: "flex", flexDirection: "column", gap: 12 }}>
          <div style={{ padding: "12px 14px", background: "#0A0B0A", borderRadius: "var(--r-md)", color: "white" }}>
            <div style={{ font: "600 10px var(--font-ui)", color: "#C8FF3E", letterSpacing: "0.08em", textTransform: "uppercase", marginBottom: 4 }}>
              {fmtDateShort(date)} · {fmt12(selectedStart)} → {fmt12(toTime(toMins(selectedStart) + durMins))}
            </div>
            <div style={{ fontFamily: "var(--font-ui)", fontWeight: 700, fontSize: 15, letterSpacing: "-0.01em", lineHeight: 1.3 }}>
              {unit?.name}{activeVariant ? ` · ${activeVariant.label}` : ""} · {durLabel(durMins)}
              {totalPaise > 0 && <span style={{ color: "#C8FF3E" }}> · {rupeesInt(totalPaise)}</span>}
            </div>
          </div>

          {unitAddons.length > 0 && (
            <div>
              <div className="eyebrow" style={{ marginBottom: 10 }}>Add-ons</div>
              <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
                {unitAddons.map((a) => {
                  const on = selectedAddons.has(a.id);
                  return (
                    <button key={a.id} onClick={() => setSelectedAddons(prev => {
                      const next = new Set(prev);
                      on ? next.delete(a.id) : next.add(a.id);
                      return next;
                    })} style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "14px 16px", borderRadius: "var(--r-md)", border: `1.5px solid ${on ? "#C8FF3E" : "var(--hairline)"}`, background: on ? "#0A0B0A" : "var(--paper-2)", cursor: "pointer", textAlign: "left", transition: "all .15s" }}>
                      <div>
                        <div style={{ fontFamily: "var(--font-ui)", fontWeight: 700, fontSize: 13, color: on ? "#C8FF3E" : "var(--ink)" }}>{a.name}</div>
                        {a.description && <div style={{ font: "500 11px var(--font-ui)", color: on ? "rgba(255,255,255,0.5)" : "var(--ink-3)", marginTop: 2 }}>{a.description}</div>}
                      </div>
                      <div style={{ fontFamily: "var(--font-ui)", fontWeight: 700, fontSize: 13, color: on ? "#C8FF3E" : "var(--ink)", flexShrink: 0, marginLeft: 12 }}>
                        {on ? "✓ " : ""}{rupeesInt(a.pricePaise)}<span style={{ fontWeight: 500, fontSize: 11, opacity: 0.7 }}>/{(a.unit ?? "session").replace(/^per_/i, "")}</span>
                      </div>
                    </button>
                  );
                })}
              </div>
            </div>
          )}

          {cancHours > 0 && (
            <div style={{ padding: "14px 16px", borderRadius: "var(--r-md)", background: "var(--paper-2)", border: "1.5px solid var(--hairline)" }}>
              <div style={{ font: "600 10px var(--font-ui)", color: "var(--ink-3)", letterSpacing: "0.08em", textTransform: "uppercase", marginBottom: 6 }}>Cancellation Policy</div>
              <div style={{ fontFamily: "var(--font-ui)", fontWeight: 600, fontSize: 13, color: "var(--ink)", marginBottom: 4 }}>
                Free cancellation up to {cancHours}h before
              </div>
              <div style={{ font: "500 11px var(--font-ui)", color: "var(--ink-3)", lineHeight: 1.5 }}>
                Cancel before {cancHours} hours of your slot start time at no charge. Late cancellations may be non-refundable.
              </div>
            </div>
          )}

          {totalPaise > 0 && (
            <div style={{ padding: "14px 16px", borderRadius: "var(--r-md)", background: "var(--paper-2)", border: "1.5px solid var(--hairline)" }}>
              <div style={{ font: "600 10px var(--font-ui)", color: "var(--ink-3)", letterSpacing: "0.08em", textTransform: "uppercase", marginBottom: 10 }}>Summary</div>
              <div style={{ display: "flex", justifyContent: "space-between", font: "500 12px var(--font-ui)", color: "var(--ink-2)", marginBottom: 6 }}>
                <span>{unit?.name}{activeVariant ? ` · ${activeVariant.label}` : ""} · {durLabel(durMins)}</span>
                <span style={{ fontWeight: 700 }}>{rupeesInt(basePaise)}</span>
              </div>
              {[...selectedAddons].map(id => {
                const a = unitAddons.find(a => a.id === id);
                if (!a) return null;
                return (
                  <div key={id} style={{ display: "flex", justifyContent: "space-between", font: "500 12px var(--font-ui)", color: "var(--ink-2)", marginBottom: 6 }}>
                    <span>{a.name}</span>
                    <span style={{ fontWeight: 700 }}>{rupeesInt(a.pricePaise)}</span>
                  </div>
                );
              })}
              <div style={{ display: "flex", justifyContent: "space-between", fontFamily: "var(--font-ui)", fontWeight: 800, fontSize: 15, color: "var(--ink)", borderTop: "1.5px solid var(--hairline)", paddingTop: 10, marginTop: 4 }}>
                <span>Total</span>
                <span>{rupeesInt(totalPaise)}</span>
              </div>
            </div>
          )}

          <div className="form-field">
            <label className="form-label">Your name</label>
            <input className="form-input" type="text" placeholder="Full name" value={guestName} onChange={(e) => setGuestName(e.target.value)} autoFocus />
          </div>
          <div className="form-field">
            <label className="form-label">Mobile number</label>
            <input className="form-input" type="tel" placeholder="+91 98765 43210" value={guestPhone} onChange={(e) => setGuestPhone(e.target.value)} />
          </div>
          {error && <div style={{ font: "600 12px var(--font-ui)", color: "var(--bad)" }}>{error}</div>}
          <div className="pay-note" style={{ padding: "0 0 10px" }}>
            Payment collected at venue
          </div>
        </div>
        );
      })()}

      {/* ── DATE + SLOT ─────────────────────────────────────────────────────── */}
      {step === "slot" && (
        <>
          <div style={{ padding: "20px 20px 0" }}>
            <div className="eyebrow" style={{ marginBottom: 10 }}>Pick a date</div>
          </div>
          <div className="cal-strip">
            {dates.map((d) => {
              const { day, wd } = shortDate(d);
              const a = dateAvail[d];
              const isSelected = date === d;
              const dotColor = !a || a.total === 0 ? null
                : a.avail === 0 ? "#FF4444"
                : a.avail < a.total / 2 ? "#FF9500"
                : "#C8FF3E";
              const bgColor = !dotColor || isSelected ? undefined
                : a!.avail === 0 ? "rgba(255,68,68,0.12)"
                : a!.avail < a!.total / 2 ? "rgba(255,149,0,0.10)"
                : "rgba(200,255,62,0.08)";
              const borderColor = !dotColor || isSelected ? undefined
                : a!.avail === 0 ? "rgba(255,68,68,0.35)"
                : a!.avail < a!.total / 2 ? "rgba(255,149,0,0.30)"
                : "rgba(200,255,62,0.25)";
              return (
                <div
                  key={d}
                  className={`cal-day${isSelected ? " selected" : ""}`}
                  style={bgColor ? { background: bgColor, borderColor } : undefined}
                  onClick={() => handleDateSelect(d)}
                >
                  <div className="dow">{wd}</div>
                  <div className="dom">{day}</div>
                  <div className="avail" style={{ minHeight: 14, display: "flex", alignItems: "center", justifyContent: "center" }}>
                    {dotColor && <div style={{ width: 5, height: 5, borderRadius: "50%", background: dotColor }} />}
                  </div>
                </div>
              );
            })}
          </div>
          <div ref={slotRef}>
            {loading ? (
              <div style={{ padding: "32px 16px", textAlign: "center" }}>
                <div style={{ width: 24, height: 24, borderRadius: "50%", border: "2px solid var(--hairline)", borderTopColor: "var(--ink)", animation: "spin 0.7s linear infinite", margin: "0 auto" }} />
                <div className="eyebrow" style={{ marginTop: 10 }}>Loading slots…</div>
              </div>
            ) : date ? (
              <>
                {durMins > 0 && allSlots.length > 0 ? (
                  <>
                    <div style={{ height: 16 }} />
                    <div className="slot-grid">
                      {allSlots.map((s) => (
                        <div key={s.start}
                          className={`slot${selectedStart === s.start ? " selected" : ""}${!s.available ? " unavailable" : ""}${s.peak ? " peak" : ""}`}
                          onClick={() => s.available && setSelectedStart(s.start)}>
                          {s.peak && s.available && selectedStart !== s.start && <div className="badge">PEAK</div>}
                          <div className="s-time">{fmtRange(s.start, s.end)}</div>
                          {totalPaise > 0 && <div className="s-price">{rupeesInt(totalPaise)}</div>}
                        </div>
                      ))}
                    </div>
                    <div className="pay-note">{availableCount} slot{availableCount !== 1 ? "s" : ""} available · {durLabel(durMins)} each</div>
                  </>
                ) : (
                  <div className="pay-note" style={{ marginTop: 12 }}>No slots available for this date.</div>
                )}
              </>
            ) : null}
          </div>
        </>
      )}

      {error && step !== "form" && (
        <div style={{ padding: "8px 14px", font: "600 12px var(--font-ui)", color: "var(--bad)" }}>{error}</div>
      )}

      {/* ── STICKY CTA BAR ──────────────────────────────────────────────────── */}
      <div className="cta-bar">
        <div style={{ flex: 1 }}>
          {selectedStart && step === "slot" ? (
            <>
              <div className="cta-amt">{totalPaise > 0 ? rupeesInt(totalPaise) : durLabel(durMins)}</div>
              <div className="cta-sub">{fmtDateShort(date)} · {fmt12(selectedStart)} → {fmt12(toTime(toMins(selectedStart) + durMins))}</div>
            </>
          ) : step === "form" ? (
            <>
              <div className="cta-amt">{totalPaise > 0 ? rupeesInt(totalPaise) : "Book"}</div>
              <div className="cta-sub">Payment collected at venue</div>
            </>
          ) : (
            <>
              <div className="cta-amt">{date ? fmtDateShort(date) : "Pick a date"}</div>
              <div className="cta-sub">{durMins > 0 ? `${durLabel(durMins)} · Pick a time` : "Select duration above"}</div>
            </>
          )}
        </div>

        {step === "slot" && selectedStart && (
          <button className="cta-btn" onClick={() => setStep("form")}>
            Continue
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="M5 12h14M13 5l7 7-7 7"/></svg>
          </button>
        )}

        {step === "slot" && !selectedStart && (
          <button className="cta-btn" disabled>{date ? "Pick a slot" : "Pick a date"}</button>
        )}

        {step === "form" && (
          <>
            <button style={{ background: "transparent", border: "none", color: "var(--ink-3)", font: "600 13px var(--font-ui)", cursor: "pointer", padding: "0 4px" }}
              onClick={() => setStep("slot")}>← Back</button>
            <button className="cta-btn"
              disabled={submitting || !guestName.trim() || !guestPhone.trim()}
              onClick={handleSubmit}>
              {submitting ? "Processing…" : "Confirm Booking"}
              {!submitting && <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="M5 12h14M13 5l7 7-7 7"/></svg>}
            </button>
          </>
        )}
      </div>

      {/* spinner keyframes */}
      <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
    </div>
  );
}
