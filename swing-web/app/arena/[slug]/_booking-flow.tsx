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

export default function BookingFlow({ units, arenaSlug, apiBaseUrl, arenaName = "", address, latitude, longitude, phone, openTime, closeTime }: Props) {
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
  const [step, setStep] = useState<"date" | "slot" | "extras" | "form" | "done" | "pass" | "bulk">("date");
  const [selectedAddons, setSelectedAddons] = useState<Set<string>>(new Set());
  // monthly pass state
  const [passDays, setPassDays] = useState<number[]>([]);
  const [passStartTime, setPassStartTime] = useState("06:00");
  const [passEndTime, setPassEndTime] = useState("07:00");
  const [passStartDate, setPassStartDate] = useState(getToday());
  const [passMonths, setPassMonths] = useState(1);
  // bulk booking state
  const [bulkDays, setBulkDays] = useState(1);
  const [bulkStartTime, setBulkStartTime] = useState("06:00");
  const [bulkEndTime, setBulkEndTime] = useState("07:00");
  const [bulkStartDate, setBulkStartDate] = useState(getToday());
  const [loading, setLoading] = useState(false);
  const [submitting, startSubmit] = useTransition();
  const [error, setError] = useState("");
  const [bookingRef, setBookingRef] = useState("");
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

  const unit = units.find((u) => u.id === unitId);
  const isGround = GROUND_TYPES.has(unit?.unitType ?? "");
  const slotUnit = slotUnits.find((u) => u.id === unitId);
  const open = openTime ?? "06:00";
  const close = closeTime ?? "23:00";

  const fetchSlots = useCallback(async (d: string) => {
    setLoading(true); setSlotUnits([]); setSelectedStart("");
    try {
      const res = await fetch(`/api/arena/${arenaSlug}/slots?date=${d}`);
      if (!res.ok) throw new Error();
      const body = (await res.json()) as { data?: { units?: SlotUnit[] } };
      const fetched = body.data?.units ?? [];
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
  }, [apiBaseUrl, arenaSlug, unitId, unit]);

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
    const slots: { start: string; end: string; available: boolean; peak: boolean }[] = [];
    for (let s = openM; s + durMins <= closeM; s += inc) {
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
        const res = await fetch(`/api/bookings`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            arenaUnitId: unitId, bookingDate: date,
            startTime: selectedStart, endTime,
            totalPricePaise: totalPaise,
            guestName: guestName.trim(), guestPhone: guestPhone.trim(),
          }),
        });
        const data = (await res.json()) as { success?: boolean; error?: string; data?: { id?: string } };
        if (!res.ok || !data.success) { setError(data.error ?? "Booking failed. Slot may have been taken."); return; }
        setBookingRef(data.data?.id?.slice(-8).toUpperCase() ?? "OK");
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
        setStep("done");
      } catch { setError("Network error. Try again."); }
    });
  }

  function handleBulkSubmit() {
    if (!guestName.trim() || !guestPhone.trim()) { setError("Enter your name and phone number."); return; }
    setError("");
    startSubmit(async () => {
      try {
        const res = await fetch("/api/bulk-bookings", {
          method: "POST", headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ arenaUnitId: unitId, startTime: bulkStartTime, endTime: bulkEndTime, startDate: bulkStartDate, numDays: bulkDays, guestName: guestName.trim(), guestPhone: guestPhone.trim() }),
        });
        const data = (await res.json()) as { success?: boolean; error?: string; data?: { numDays?: number; totalAmountPaise?: number } };
        if (!res.ok || !data.success) { setError(data.error ?? "Failed. Try again."); return; }
        setBookingRef(`${data.data?.numDays ?? bulkDays}D`);
        setStep("done");
      } catch { setError("Network error. Try again."); }
    });
  }

  const dates = Array.from({ length: 14 }, (_, i) => addDays(today, i));

  // ── Confirmation screen ─────────────────────────────────────────────────
  if (step === "done") {
    const endTime = toTime(toMins(selectedStart) + durMins);
    const mapsUrl = latitude && longitude
      ? `https://www.google.com/maps/dir/?api=1&destination=${latitude},${longitude}`
      : address
        ? `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(address)}`
        : null;

    const savePass = async () => {
      const canvas = document.createElement("canvas");
      canvas.width = 900; canvas.height = 480;
      const ctx = canvas.getContext("2d")!;

      // Background
      ctx.fillStyle = "#0A0B0A";
      ctx.fillRect(0, 0, 900, 480);

      // Glow
      const g = ctx.createRadialGradient(820, 40, 0, 820, 40, 260);
      g.addColorStop(0, "rgba(200,255,62,0.28)"); g.addColorStop(1, "rgba(200,255,62,0)");
      ctx.fillStyle = g; ctx.fillRect(0, 0, 900, 480);

      // Left accent bar
      ctx.fillStyle = "#C8FF3E"; ctx.fillRect(0, 0, 5, 480);

      // Branding
      ctx.fillStyle = "#C8FF3E"; ctx.font = "bold 14px system-ui, sans-serif";
      ctx.fillText("SWING", 32, 48);

      // CONFIRMED badge
      ctx.fillStyle = "rgba(200,255,62,0.15)";
      ctx.beginPath(); ctx.roundRect(720, 24, 130, 30, 15); ctx.fill();
      ctx.fillStyle = "#C8FF3E"; ctx.font = "600 11px system-ui, sans-serif";
      ctx.fillText("CONFIRMED ✓", 738, 44);

      // Arena name
      ctx.fillStyle = "white"; ctx.font = "bold 34px system-ui, sans-serif";
      ctx.fillText(arenaName, 32, 110);

      // Unit name
      ctx.fillStyle = "rgba(255,255,255,0.55)"; ctx.font = "500 16px system-ui, sans-serif";
      ctx.fillText(unit?.name ?? "", 32, 142);

      // Divider
      ctx.strokeStyle = "rgba(255,255,255,0.1)"; ctx.lineWidth = 1;
      ctx.beginPath(); ctx.moveTo(32, 168); ctx.lineTo(868, 168); ctx.stroke();

      // Fields row
      const fields = [
        { label: "DATE", value: fmtDateShort(date) },
        { label: "TIME", value: `${fmt12(selectedStart)} – ${fmt12(endTime)}` },
        { label: "DURATION", value: durLabel(durMins) },
      ];
      fields.forEach((f, i) => {
        const x = 32 + i * 270;
        ctx.fillStyle = "rgba(255,255,255,0.38)"; ctx.font = "500 10px system-ui, sans-serif";
        ctx.fillText(f.label, x, 202);
        ctx.fillStyle = "white"; ctx.font = "bold 20px system-ui, sans-serif";
        ctx.fillText(f.value, x, 230);
      });

      // Booking ref box
      ctx.fillStyle = "rgba(255,255,255,0.07)";
      ctx.beginPath(); ctx.roundRect(32, 258, 310, 58, 8); ctx.fill();
      ctx.fillStyle = "rgba(255,255,255,0.38)"; ctx.font = "500 10px system-ui, sans-serif";
      ctx.fillText("BOOKING ID", 50, 280);
      ctx.fillStyle = "white"; ctx.font = "bold 22px system-ui, sans-serif";
      ctx.fillText(`SW-${bookingRef}`, 50, 306);

      // Address
      if (address) {
        ctx.fillStyle = "rgba(255,255,255,0.38)"; ctx.font = "500 10px system-ui, sans-serif";
        ctx.fillText("LOCATION", 370, 280);
        ctx.fillStyle = "rgba(255,255,255,0.75)"; ctx.font = "500 13px system-ui, sans-serif";
        ctx.fillText(address.length > 50 ? address.slice(0, 50) + "…" : address, 370, 306);
      }

      // Guest name
      ctx.fillStyle = "rgba(255,255,255,0.45)"; ctx.font = "500 13px system-ui, sans-serif";
      ctx.fillText(guestName, 32, 370);

      // Footer
      ctx.fillStyle = "rgba(255,255,255,0.2)"; ctx.font = "500 10px system-ui, sans-serif";
      ctx.fillText("ARRIVE 10 MIN EARLY  ·  SHOW THIS AT FRONT DESK  ·  swing.app", 32, 450);

      canvas.toBlob(async (blob) => {
        if (!blob) return;
        const file = new File([blob], `swing-pass-${bookingRef}.png`, { type: "image/png" });
        if (typeof navigator !== "undefined" && navigator.share && navigator.canShare?.({ files: [file] })) {
          await navigator.share({ files: [file], title: "Booking Pass" });
        } else {
          const url = URL.createObjectURL(blob);
          const a = document.createElement("a");
          a.href = url; a.download = file.name; a.click();
          URL.revokeObjectURL(url);
        }
      }, "image/png");
    };

    return (
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
              totalPaise > 0 ? ["Amount", `${rupeesInt(totalPaise)} · Pay at venue`] : null,
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
    );
  }

  // ── Step indicator ──────────────────────────────────────────────────────
  const hasExtrasStep = unitAddons.length > 0 || (unit?.minAdvancePaise ?? 0) > 0 || (unit?.cancellationHours ?? 0) > 0;
  const totalSteps = hasExtrasStep ? 4 : 3;
  const stepNum = step === "date" ? 1 : step === "slot" ? 2 : step === "extras" ? 3 : step === "form" ? (hasExtrasStep ? 4 : 3) : (hasExtrasStep ? 4 : 3);
  const stepLabels: Record<number, string> = { 1: "Choose unit", 2: "Pick time", 3: hasExtrasStep ? "Add-ons" : "Your details", 4: "Your details" };
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
    return (
      <div style={{ background: "var(--paper)", minHeight: "100%", paddingBottom: 140 }}>
        <StepBar />

        {/* Unit blocks */}
        <div style={{ padding: "32px 20px 0" }}>
          <div className="eyebrow" style={{ marginBottom: 14 }}>Available Units</div>
          <div style={{ display: "flex", gap: 10, overflowX: "auto", padding: "4px 0 16px 0" }} className="scrollbar-none">
            {units.map((u) => {
              const sel = unitId === u.id;
              const isGr = GROUND_TYPES.has(u.unitType ?? "");
              const ubs = [
                u.price4HrPaise     && { label: "4 hr",     paise: u.price4HrPaise },
                u.price8HrPaise     && { label: "8 hr",     paise: u.price8HrPaise },
                u.priceFullDayPaise && { label: "Full day", paise: u.priceFullDayPaise },
              ].filter(Boolean) as { label: string; paise: number }[];
              const vp = (u.netVariants ?? []).map(v => v.pricePaise).filter((p): p is number => !!p);
              const pLabel = isGr
                ? ubs.length ? `₹${Math.round(ubs[0].paise / 100)} / ${ubs[0].label}` : null
                : vp.length
                  ? (() => { const lo = Math.round(Math.min(...vp)/100); const hi = Math.round(Math.max(...vp)/100); return `₹${lo===hi?lo:`${lo}–${hi}`}/hr`; })()
                  : u.pricePerHourPaise ? `₹${Math.round(u.pricePerHourPaise/100)}/hr` : null;
              return (
                <button key={u.id} onClick={() => handleUnitChange(u.id)} style={{
                  flex: "0 0 auto", display: "flex", flexDirection: "column", alignItems: "flex-start",
                  gap: 6, padding: "14px 16px", minWidth: 140, borderRadius: "var(--r-md)",
                  border: `1.5px solid ${sel ? "#C8FF3E" : "var(--hairline)"}`,
                  background: sel ? "#0A0B0A" : "var(--paper-2)",
                  cursor: "pointer", textAlign: "left", transition: "all .15s",
                }}>
                  <div style={{ fontFamily: "var(--font-ui)", fontWeight: 700, fontSize: 14, color: sel ? "#C8FF3E" : "var(--ink)", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", maxWidth: 160 }}>{u.name}</div>
                  {u.unitType && <div style={{ font: "500 10px var(--font-ui)", color: sel ? "rgba(255,255,255,0.5)" : "var(--ink-3)", textTransform: "uppercase", letterSpacing: "0.07em", marginTop: 4 }}>{u.unitType.replace(/_/g, " ")}</div>}
                  {pLabel && <div style={{ fontFamily: "var(--font-ui)", fontWeight: 700, fontSize: 13, color: sel ? "rgba(255,255,255,0.85)" : "var(--ink)", marginTop: 2 }}>{pLabel}</div>}
                </button>
              );
            })}
          </div>
        </div>

        {/* Booking mode + net type */}
        {unit && (
          <div style={{ padding: "32px 20px 0" }}>
            <div className="eyebrow" style={{ marginBottom: 14 }}>How to book</div>
            <div style={{ display: "flex", gap: 10, overflowX: "auto", padding: "4px 0 4px 0" }} className="scrollbar-none">
              {/* Book Once — always shown */}
              {(() => {
                const active = step === "date";
                return (
                  <button onClick={() => setStep("date")} style={{
                    flex: "0 0 auto", display: "flex", flexDirection: "column", gap: 2,
                    padding: "11px 20px", borderRadius: 999,
                    border: `1.5px solid ${active ? "#C8FF3E" : "var(--hairline)"}`,
                    background: active ? "#0A0B0A" : "var(--paper-2)",
                    cursor: "pointer", transition: "all .15s",
                  }}>
                    <div style={{ fontFamily: "var(--font-ui)", fontWeight: 700, fontSize: 13, color: active ? "#C8FF3E" : "var(--ink)", whiteSpace: "nowrap" }}>Book Once</div>
                    {(() => {
                      if (isGround) {
                        const ubs = [unit.price4HrPaise, unit.price8HrPaise, unit.priceFullDayPaise].filter(Boolean) as number[];
                        if (!ubs.length) return null;
                        return <div style={{ font: "500 10px var(--font-ui)", color: active ? "rgba(255,255,255,0.5)" : "var(--ink-3)", whiteSpace: "nowrap" }}>from {rupeesInt(Math.min(...ubs))}</div>;
                      }
                      const vp = (unit.netVariants ?? []).map(v => v.pricePaise).filter((p): p is number => !!p);
                      const base = vp.length ? Math.min(...vp) : unit.pricePerHourPaise;
                      return base ? <div style={{ font: "500 10px var(--font-ui)", color: active ? "rgba(255,255,255,0.5)" : "var(--ink-3)", whiteSpace: "nowrap" }}>{rupeesInt(base)}/hr</div> : null;
                    })()}
                  </button>
                );
              })()}

              {/* Monthly Pass */}
              {unit.monthlyPassEnabled && unit.monthlyPassRatePaise && (() => {
                const active = false;
                return (
                  <button onClick={() => { setStep("pass"); setGuestName(""); setGuestPhone(""); setError(""); }} style={{
                    flex: "0 0 auto", display: "flex", flexDirection: "column", gap: 2,
                    padding: "11px 20px", borderRadius: 999,
                    border: `1.5px solid ${active ? "#C8FF3E" : "var(--hairline)"}`,
                    background: active ? "#0A0B0A" : "var(--paper-2)",
                    cursor: "pointer", transition: "all .15s",
                  }}>
                    <div style={{ fontFamily: "var(--font-ui)", fontWeight: 700, fontSize: 13, color: active ? "#C8FF3E" : "var(--ink)", whiteSpace: "nowrap" }}>Monthly Pass</div>
                    <div style={{ font: "500 10px var(--font-ui)", color: active ? "rgba(255,255,255,0.5)" : "var(--ink-3)" }}>{rupeesInt(unit.monthlyPassRatePaise)}/month</div>
                  </button>
                );
              })()}

              {/* Bulk Booking */}
              {unit.minBulkDays && unit.bulkDayRatePaise && (() => {
                const active = false;
                return (
                  <button onClick={() => { setStep("bulk"); setBulkDays(unit.minBulkDays ?? 1); setGuestName(""); setGuestPhone(""); setError(""); }} style={{
                    flex: "0 0 auto", display: "flex", flexDirection: "column", gap: 2,
                    padding: "11px 20px", borderRadius: 999,
                    border: `1.5px solid ${active ? "#C8FF3E" : "var(--hairline)"}`,
                    background: active ? "#0A0B0A" : "var(--paper-2)",
                    cursor: "pointer", transition: "all .15s",
                  }}>
                    <div style={{ fontFamily: "var(--font-ui)", fontWeight: 700, fontSize: 13, color: active ? "#C8FF3E" : "var(--ink)", whiteSpace: "nowrap" }}>Bulk Booking</div>
                    <div style={{ font: "500 10px var(--font-ui)", color: active ? "rgba(255,255,255,0.5)" : "var(--ink-3)" }}>{unit.minBulkDays}+ days · {rupeesInt(unit.bulkDayRatePaise)}/day</div>
                  </button>
                );
              })()}
            </div>

            {/* Net variants — no label */}
            {netVariants.length > 0 && step === "date" && (
              <div style={{ display: "flex", gap: 10, overflowX: "auto", padding: "20px 2px 8px" }} className="scrollbar-none">
                {netVariants.map((v) => {
                  const active = activeVariant?.type === v.type;
                  return (
                    <button key={v.type} onClick={() => setSelectedVariant(v.type)} style={{
                      flex: "0 0 auto", display: "flex", flexDirection: "column", gap: 4,
                      padding: "10px 16px", borderRadius: "var(--r-md)",
                      border: `1.5px solid ${active ? "#C8FF3E" : "var(--hairline)"}`,
                      background: active ? "#0A0B0A" : "var(--paper-2)",
                      cursor: "pointer", transition: "all .15s",
                    }}>
                      <div style={{ fontFamily: "var(--font-ui)", fontWeight: 700, fontSize: 12, color: active ? "#C8FF3E" : "var(--ink)", whiteSpace: "nowrap" }}>{v.label}</div>
                      {v.pricePaise && <div style={{ font: "500 10px var(--font-ui)", color: active ? "rgba(255,255,255,0.5)" : "var(--ink-3)" }}>{rupeesInt(v.pricePaise)}/hr</div>}
                    </button>
                  );
                })}
              </div>
            )}
          </div>
        )}

        {/* CTA */}
        <div className="cta-bar">
          <div style={{ flex: 1 }}>
            <div className="cta-amt">{unit?.name ?? "Select a unit"}</div>
            {activeVariant && <div className="cta-sub">{activeVariant.label}{activeVariant.pricePaise ? ` · ${rupeesInt(activeVariant.pricePaise)}/hr` : ""}</div>}
          </div>
          <button className="cta-btn" onClick={() => setStep("slot")}>
            Next
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="M5 12h14M13 5l7 7-7 7"/></svg>
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
              <div style={{ display: "flex", alignItems: "center", gap: 8, marginTop: 4 }}>
                <button onClick={() => setPassMonths(m => Math.max(1, m - 1))} style={{ width: 30, height: 30, borderRadius: "var(--r-sm)", border: "1.5px solid var(--hairline)", background: "var(--paper-2)", color: "var(--ink)", cursor: "pointer", fontWeight: 700, fontSize: 15 }}>−</button>
                <span style={{ fontFamily: "var(--font-ui)", fontWeight: 700, fontSize: 15, color: "var(--ink)", minWidth: 20, textAlign: "center" }}>{passMonths}</span>
                <button onClick={() => setPassMonths(m => Math.min(12, m + 1))} style={{ width: 30, height: 30, borderRadius: "var(--r-sm)", border: "1.5px solid var(--hairline)", background: "var(--paper-2)", color: "var(--ink)", cursor: "pointer", fontWeight: 700, fontSize: 15 }}>+</button>
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
    const total = dayRate * bulkDays;
    return (
      <div style={{ background: "var(--paper)", minHeight: "100%", paddingBottom: 96 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 8, padding: "16px 14px 0" }}>
          <button onClick={() => setStep("date")} style={{ width: 28, height: 28, borderRadius: "50%", border: "1px solid var(--hairline)", background: "transparent", color: "var(--ink)", cursor: "pointer", display: "grid", placeItems: "center", flexShrink: 0 }}>
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="M15 18l-6-6 6-6"/></svg>
          </button>
          <div style={{ fontFamily: "var(--font-ui)", fontWeight: 700, fontSize: 14, color: "var(--ink)" }}>Bulk Booking · {unit?.name}</div>
        </div>
        <div style={{ padding: "20px 14px 0", display: "flex", flexDirection: "column", gap: 16 }}>
          <div>
            <div className="eyebrow" style={{ marginBottom: 8 }}>Number of days <span style={{ color: "var(--ink-3)", fontWeight: 500 }}>· min {minDays}</span></div>
            <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
              <button onClick={() => setBulkDays(d => Math.max(minDays, d - 1))} style={{ width: 36, height: 36, borderRadius: "var(--r-sm)", border: "1.5px solid var(--hairline)", background: "var(--paper-2)", color: "var(--ink)", cursor: "pointer", fontWeight: 700, fontSize: 18 }}>−</button>
              <span style={{ fontFamily: "var(--font-ui)", fontWeight: 700, fontSize: 22, color: "var(--ink)", minWidth: 32, textAlign: "center" }}>{bulkDays}</span>
              <button onClick={() => setBulkDays(d => d + 1)} style={{ width: 36, height: 36, borderRadius: "var(--r-sm)", border: "1.5px solid var(--hairline)", background: "var(--paper-2)", color: "var(--ink)", cursor: "pointer", fontWeight: 700, fontSize: 18 }}>+</button>
              {dayRate > 0 && <span style={{ font: "600 12px var(--font-ui)", color: "var(--ink-3)" }}>{rupeesInt(dayRate)}/day</span>}
            </div>
          </div>
          <div style={{ display: "flex", gap: 10 }}>
            <div className="form-field" style={{ flex: 1 }}>
              <label className="form-label">Daily start time</label>
              <input className="form-input" type="time" value={bulkStartTime} onChange={e => {
                const t = e.target.value;
                setBulkStartTime(t);
                const [h, m] = t.split(":").map(Number);
                const endH = (h + 1) % 24;
                setBulkEndTime(`${String(endH).padStart(2, "0")}:${String(m).padStart(2, "0")}`);
              }} />
            </div>
            <div className="form-field" style={{ flex: 1 }}>
              <label className="form-label">Daily end time</label>
              <input className="form-input" type="time" value={bulkEndTime} min={bulkStartTime} onChange={e => {
                if (e.target.value > bulkStartTime) setBulkEndTime(e.target.value);
              }} />
            </div>
          </div>
          <div className="form-field">
            <label className="form-label">Start date</label>
            <input className="form-input" type="date" min={today} value={bulkStartDate} onChange={e => setBulkStartDate(e.target.value)} />
          </div>
          <div className="form-field">
            <label className="form-label">Your name</label>
            <input className="form-input" type="text" placeholder="Full name" value={guestName} onChange={e => setGuestName(e.target.value)} />
          </div>
          <div className="form-field">
            <label className="form-label">Mobile number</label>
            <input className="form-input" type="tel" placeholder="+91 98765 43210" value={guestPhone} onChange={e => setGuestPhone(e.target.value)} />
          </div>
          {error && <div style={{ font: "600 12px var(--font-ui)", color: "var(--bad)" }}>{error}</div>}
        </div>
        <div className="cta-bar">
          <div style={{ flex: 1 }}>
            <div className="cta-amt">{total > 0 ? rupeesInt(total) : `${bulkDays} days`}</div>
            <div className="cta-sub">{bulkDays} day{bulkDays > 1 ? "s" : ""} · pay at venue</div>
          </div>
          <button className="cta-btn" disabled={submitting || !guestName.trim() || !guestPhone.trim()} onClick={handleBulkSubmit}>
            {submitting ? "Confirming…" : "Confirm"}
            {!submitting && <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="M5 12h14M13 5l7 7-7 7"/></svg>}
          </button>
        </div>
      </div>
    );
  }

  // ── Screen 3: Extras (addons + advance + cancellation) ────────────────
  if (step === "extras") {
    const advance = unit?.minAdvancePaise ?? 0;
    const cancHours = unit?.cancellationHours ?? 0;
    return (
      <div style={{ background: "var(--paper)", minHeight: "100%", paddingBottom: 96 }}>
        <StepBar />
        <div style={{ display: "flex", alignItems: "center", gap: 8, padding: "10px 14px 0" }}>
          <button onClick={() => setStep("slot")} style={{ width: 28, height: 28, borderRadius: "50%", border: "1px solid var(--hairline)", background: "transparent", color: "var(--ink)", cursor: "pointer", display: "grid", placeItems: "center", flexShrink: 0 }}>
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="M15 18l-6-6 6-6"/></svg>
          </button>
          <div style={{ fontFamily: "var(--font-ui)", fontWeight: 600, fontSize: 13, color: "var(--ink-2)" }}>
            {fmtDateShort(date)} · {fmt12(selectedStart)} · {durLabel(durMins)}
          </div>
        </div>

        <div style={{ padding: "20px 14px 0", display: "flex", flexDirection: "column", gap: 16 }}>

          {/* Addons */}
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
                        {on ? "✓ " : ""}{rupeesInt(a.pricePaise)}<span style={{ fontWeight: 500, fontSize: 11, opacity: 0.7 }}>/{a.unit ?? "session"}</span>
                      </div>
                    </button>
                  );
                })}
              </div>
            </div>
          )}

          {/* Advance payment — marketing card */}
          {advance > 0 && (
            <div style={{ borderRadius: "var(--r-lg)", background: "#0A0B0A", padding: "18px 18px 16px", position: "relative", overflow: "hidden" }}>
              <div style={{ position: "absolute", top: -30, right: -30, width: 120, height: 120, borderRadius: "50%", background: "#C8FF3E", filter: "blur(60px)", opacity: 0.25, pointerEvents: "none" }} />
              <div style={{ position: "relative" }}>
                <div style={{ font: "600 10px var(--font-ui)", color: "#C8FF3E", letterSpacing: "0.1em", textTransform: "uppercase", marginBottom: 6 }}>Advance Required</div>
                <div style={{ fontFamily: "var(--font-ui)", fontWeight: 800, fontSize: 18, color: "white", lineHeight: 1.3, marginBottom: 6 }}>
                  Pay {rupeesInt(advance)} now,<br />secure your slot instantly.
                </div>
                <div style={{ font: "500 12px var(--font-ui)", color: "rgba(255,255,255,0.5)", lineHeight: 1.5 }}>
                  Advance is collected at the venue. Remaining {rupeesInt(totalPaise - advance)} due on the day.
                </div>
              </div>
            </div>
          )}

          {/* Cancellation policy */}
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

          {/* Price summary */}
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
            {advance > 0 && (
              <div style={{ display: "flex", justifyContent: "space-between", font: "600 11px var(--font-ui)", color: "var(--ink-3)", marginTop: 6 }}>
                <span>Pay at venue today</span>
                <span>{rupeesInt(advance)}</span>
              </div>
            )}
          </div>
        </div>

        <div className="cta-bar">
          <div style={{ flex: 1 }}>
            <div className="cta-amt">{rupeesInt(totalPaise)}</div>
            <div className="cta-sub">{advance > 0 ? `₹${Math.round(advance / 100)} advance · rest at venue` : "Pay at venue"}</div>
          </div>
          <button className="cta-btn" onClick={() => setStep("form")}>
            Continue
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="M5 12h14M13 5l7 7-7 7"/></svg>
          </button>
        </div>
      </div>
    );
  }

  // ── Screen 2: Duration + Date + Slots ──────────────────────────────────
  // ── Screen 3/4: Form ───────────────────────────────────────────────────
  return (
    <div style={{ background: "var(--paper)", minHeight: "100%", paddingBottom: 96 }}>
      <StepBar />

      {/* Back row */}
      <div style={{ display: "flex", alignItems: "center", gap: 8, padding: "10px 14px 0" }}>
        <button onClick={() => {
          if (step === "form") setStep(hasExtrasStep ? "extras" : "slot");
          else { setStep("date"); setDate(""); setSelectedStart(""); setSlotUnits([]); }
        }}
          style={{ width: 28, height: 28, borderRadius: "50%", border: "1px solid var(--hairline)", background: "transparent", color: "var(--ink)", cursor: "pointer", display: "grid", placeItems: "center", flexShrink: 0 }}>
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="M15 18l-6-6 6-6"/></svg>
        </button>
        <div style={{ fontFamily: "var(--font-ui)", fontWeight: 600, fontSize: 13, color: "var(--ink-2)", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
          {unit?.name}{activeVariant ? ` · ${activeVariant.label}` : ""}
        </div>
      </div>

      {/* ── DURATION (step 2 only) ───────────────────────────────────────────── */}
      {step === "slot" && unit && (
        <div style={{ padding: "14px 14px 0" }}>
          <div className="eyebrow" style={{ marginBottom: 8 }}>Duration</div>
          {useGroundBundles ? (
            <div style={{ display: "flex", gap: 8 }}>
              {bundles.map((b) => (
                <button key={b.mins} onClick={() => { setDurMins(b.mins); setSelectedStart(""); }} style={{
                  padding: "10px 16px", borderRadius: "var(--r-md)",
                  border: `1.5px solid ${durMins === b.mins ? "#C8FF3E" : "var(--hairline)"}`,
                  background: durMins === b.mins ? "#0A0B0A" : "var(--paper-2)",
                  color: durMins === b.mins ? "#C8FF3E" : "var(--ink)",
                  cursor: "pointer", textAlign: "left", transition: "all .15s",
                }}>
                  <div style={{ fontFamily: "var(--font-ui)", fontWeight: 700, fontSize: 13 }}>{b.label}</div>
                  <div style={{ font: "500 11px var(--font-ui)", marginTop: 2, opacity: 0.65 }}>{rupeesInt(b.paise)}</div>
                </button>
              ))}
            </div>
          ) : (
            (() => {
              const minM = slotUnit?.minSlotMins || unit.minSlotMins || 60;
              const rawMax = slotUnit?.maxSlotMins || unit.maxSlotMins || 0;
              const maxM = rawMax > minM ? rawMax : 480;
              const inc = slotUnit?.slotIncrementMins || minM;
              return (
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
              );
            })()
          )}
        </div>
      )}

      {/* ── FORM ────────────────────────────────────────────────────────────── */}
      {step === "form" && (
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
          <div className="form-field">
            <label className="form-label">Your name</label>
            <input className="form-input" type="text" placeholder="Full name" value={guestName} onChange={(e) => setGuestName(e.target.value)} autoFocus />
          </div>
          <div className="form-field">
            <label className="form-label">Mobile number</label>
            <input className="form-input" type="tel" placeholder="+91 98765 43210" value={guestPhone} onChange={(e) => setGuestPhone(e.target.value)} />
          </div>
          {error && <div style={{ font: "600 12px var(--font-ui)", color: "var(--bad)" }}>{error}</div>}
          <div className="pay-note" style={{ padding: 0 }}>Payment at the venue · booking is free to reserve</div>
        </div>
      )}

      {/* ── DATE + SLOT ─────────────────────────────────────────────────────── */}
      {step === "slot" && (
        <>
          <div style={{ padding: "14px 14px 0" }}>
            <div className="eyebrow" style={{ marginBottom: 8 }}>Pick a date</div>
          </div>
          <div className="cal-strip">
            {dates.map((d) => {
              const { day, wd } = shortDate(d);
              return (
                <div key={d} className={`cal-day${date === d ? " selected" : ""}`} onClick={() => handleDateSelect(d)}>
                  <div className="dow">{wd}</div>
                  <div className="dom">{day}</div>
                  <div className="avail" style={{ minHeight: 14 }}></div>
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
                    <div style={{ height: 12 }} />
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
              <div className="cta-sub">Pay at venue</div>
            </>
          ) : (
            <>
              <div className="cta-amt">{date ? fmtDateShort(date) : "Pick a date"}</div>
              <div className="cta-sub">{durMins > 0 ? `${durLabel(durMins)} · Pick a time` : "Select duration above"}</div>
            </>
          )}
        </div>

        {step === "slot" && selectedStart && (
          <button className="cta-btn" onClick={() => setStep(hasExtrasStep ? "extras" : "form")}>
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
              onClick={() => setStep(hasExtrasStep ? "extras" : "slot")}>← Back</button>
            <button className="cta-btn"
              disabled={submitting || !guestName.trim() || !guestPhone.trim()}
              onClick={handleSubmit}>
              {submitting ? "Confirming…" : "Confirm"}
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
