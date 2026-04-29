"use client";

import { useState, useCallback, useTransition, useEffect, useRef } from "react";

type BookedSlot = { startTime: string; endTime: string };
type SlotUnit = {
  id: string;
  name: string;
  unitType?: string;
  pricePerHourPaise?: number;
  minSlotMins?: number;
  maxSlotMins?: number;
  slotIncrementMins?: number;
  openTime?: string;
  closeTime?: string;
  bookedSlots?: BookedSlot[];
};

type ArenaUnit = {
  id: string;
  name: string;
  unitType?: string;
  pricePerHourPaise?: number;
  minSlotMins?: number;
  price4HrPaise?: number | null;
  price8HrPaise?: number | null;
  priceFullDayPaise?: number | null;
};

type Props = {
  units: ArenaUnit[];
  arenaSlug: string;
  apiBaseUrl: string;
  phone?: string | null;
  arenaOpenTime?: string | null;
  arenaCloseTime?: string | null;
  startingPaise?: number;
};

const GROUND_TYPES = new Set(["FULL_GROUND", "HALF_GROUND", "TURF", "MULTI_SPORT"]);

function toMins(t: string) {
  const [h, m] = t.split(":").map(Number);
  return h * 60 + m;
}
function toTime(mins: number) {
  const h = Math.floor(mins / 60);
  const m = mins % 60;
  return `${String(h).padStart(2, "0")}:${String(m).padStart(2, "0")}`;
}
function formatTime(t: string) {
  const [h, m] = t.split(":").map(Number);
  const ampm = h >= 12 ? "PM" : "AM";
  const hr = h % 12 || 12;
  return m === 0 ? `${hr} ${ampm}` : `${hr}:${String(m).padStart(2, "0")} ${ampm}`;
}
function rupees(paise: number) {
  return `₹${Math.round(paise / 100)}`;
}
function durationLabel(mins: number) {
  if (mins < 60) return `${mins}m`;
  if (mins % 60 === 0) return `${mins / 60}h`;
  return `${Math.floor(mins / 60)}h ${mins % 60}m`;
}
function getToday() {
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
}
function addDays(dateStr: string, n: number) {
  const d = new Date(dateStr + "T00:00:00");
  d.setDate(d.getDate() + n);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
}
function formatDateFull(dateStr: string) {
  const d = new Date(dateStr + "T00:00:00");
  return d.toLocaleDateString("en-IN", { weekday: "short", day: "numeric", month: "short" });
}
function shortDate(dateStr: string) {
  const d = new Date(dateStr + "T00:00:00");
  return {
    day: String(d.getDate()),
    wd: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][d.getDay()],
  };
}

export function MobileBookBar({ startingPaise }: { startingPaise?: number }) {
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const bookEl = document.getElementById("book");
    if (!bookEl) return;
    const obs = new IntersectionObserver(
      ([e]) => setVisible(!e.isIntersecting),
      { threshold: 0.1 },
    );
    obs.observe(bookEl);
    return () => obs.disconnect();
  }, []);

  if (!visible) return null;

  return (
    <div className="fixed bottom-0 left-0 right-0 z-50 flex items-center gap-3 border-t border-white/10 bg-[#0d1210]/95 px-5 py-3 backdrop-blur-md lg:hidden">
      <div className="flex-1">
        <div className="text-[11px] font-semibold text-white/50">Starting from</div>
        <div className="text-base font-black text-white">
          {startingPaise ? `${rupees(startingPaise)}/hr` : "Book a slot"}
        </div>
      </div>
      <a
        href="#book"
        className="rounded-xl bg-[#16a34a] px-6 py-3 text-sm font-black text-white"
      >
        Book now →
      </a>
    </div>
  );
}

export default function BookingFlow({
  units,
  arenaSlug,
  apiBaseUrl,
  phone,
  arenaOpenTime,
  arenaCloseTime,
}: Props) {
  const today = getToday();
  const [selectedUnitId, setSelectedUnitId] = useState<string>(units[0]?.id ?? "");
  const [selectedDate, setSelectedDate] = useState<string>("");
  const [slotUnits, setSlotUnits] = useState<SlotUnit[]>([]);
  const [durationMins, setDurationMins] = useState<number>(0);
  const [selectedStart, setSelectedStart] = useState<string>("");
  const [guestName, setGuestName] = useState("");
  const [guestPhone, setGuestPhone] = useState("");
  const [step, setStep] = useState<"date" | "slot" | "form" | "done">("date");
  const [loadingSlots, setLoadingSlots] = useState(false);
  const [submitting, startSubmit] = useTransition();
  const [error, setError] = useState("");
  const [bookingRef, setBookingRef] = useState("");
  const slotRef = useRef<HTMLDivElement>(null);

  const selectedUnit = units.find((u) => u.id === selectedUnitId);
  const isGround = GROUND_TYPES.has(selectedUnit?.unitType ?? "");
  const slotUnit = slotUnits.find((u) => u.id === selectedUnitId);

  const fetchSlots = useCallback(
    async (date: string) => {
      setLoadingSlots(true);
      setSlotUnits([]);
      setSelectedStart("");
      setDurationMins(0);
      try {
        const res = await fetch(`${apiBaseUrl}/public/arena/p/${arenaSlug}/slots?date=${date}`);
        if (!res.ok) throw new Error();
        const payload = (await res.json()) as { data?: { units?: SlotUnit[] } };
        const fetched = payload.data?.units ?? [];
        setSlotUnits(fetched);
        const u = fetched.find((x) => x.id === selectedUnitId);
        if (u && !GROUND_TYPES.has(selectedUnit?.unitType ?? "")) {
          setDurationMins(u.minSlotMins ?? 60);
        }
      } catch {
        setError("Couldn't load availability. Try again.");
      } finally {
        setLoadingSlots(false);
      }
    },
    [apiBaseUrl, arenaSlug, selectedUnitId, selectedUnit],
  );

  function handleDateSelect(date: string) {
    setSelectedDate(date);
    setStep("slot");
    fetchSlots(date);
    setTimeout(() => slotRef.current?.scrollIntoView({ behavior: "smooth", block: "start" }), 100);
  }

  function handleUnitChange(unitId: string) {
    setSelectedUnitId(unitId);
    const u = slotUnits.find((x) => x.id === unitId);
    if (u) setDurationMins(u.minSlotMins ?? 60);
    setSelectedStart("");
  }

  function getEffectiveOpen() {
    return slotUnit?.openTime ?? arenaOpenTime ?? "06:00";
  }
  function getEffectiveClose() {
    return slotUnit?.closeTime ?? arenaCloseTime ?? "23:00";
  }

  function getAvailableSlots() {
    if (!durationMins) return [];
    const open = toMins(getEffectiveOpen());
    const close = toMins(getEffectiveClose());
    const inc = slotUnit?.slotIncrementMins ?? slotUnit?.minSlotMins ?? 60;
    const booked = slotUnit?.bookedSlots ?? [];
    const slots: { start: string; end: string; available: boolean }[] = [];
    for (let s = open; s + durationMins <= close; s += inc) {
      const startT = toTime(s);
      const endT = toTime(s + durationMins);
      slots.push({
        start: startT,
        end: endT,
        available: !booked.some((b) => b.startTime < endT && b.endTime > startT),
      });
    }
    return slots;
  }

  function getGroundBundles() {
    const u = selectedUnit;
    if (!u) return [];
    const out: { mins: number; label: string; paise: number }[] = [];
    if (u.price4HrPaise) out.push({ mins: 240, label: "4 hrs", paise: u.price4HrPaise });
    if (u.price8HrPaise) out.push({ mins: 480, label: "8 hrs", paise: u.price8HrPaise });
    if (u.priceFullDayPaise) out.push({ mins: 720, label: "Full day", paise: u.priceFullDayPaise });
    return out;
  }

  const groundBundles = isGround ? getGroundBundles() : [];
  const useGroundBundles = isGround && groundBundles.length > 0;

  function calcPrice() {
    if (!durationMins) return 0;
    if (useGroundBundles) return groundBundles.find((b) => b.mins === durationMins)?.paise ?? 0;
    return Math.round(((selectedUnit?.pricePerHourPaise ?? 0) * durationMins) / 60);
  }

  const totalPaise = calcPrice();
  const dates = Array.from({ length: 14 }, (_, i) => addDays(today, i));

  function handleSubmit() {
    if (!guestName.trim() || !guestPhone.trim()) {
      setError("Please enter your name and phone number.");
      return;
    }
    setError("");
    const endTime = toTime(toMins(selectedStart) + durationMins);
    startSubmit(async () => {
      try {
        const res = await fetch(`${apiBaseUrl}/public/bookings`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            arenaUnitId: selectedUnitId,
            bookingDate: selectedDate,
            startTime: selectedStart,
            endTime,
            totalPricePaise: totalPaise,
            guestName: guestName.trim(),
            guestPhone: guestPhone.trim(),
          }),
        });
        const data = (await res.json()) as { success?: boolean; error?: string; data?: { id?: string } };
        if (!res.ok || !data.success) {
          setError(data.error ?? "Booking failed. Slot may have been taken.");
          return;
        }
        setBookingRef(data.data?.id?.slice(-6).toUpperCase() ?? "OK");
        setStep("done");
      } catch {
        setError("Network error. Please try again.");
      }
    });
  }

  // ── Done state ───────────────────────────────────────────────────────────────
  if (step === "done") {
    return (
      <div className="py-10 text-center">
        <div className="mx-auto mb-5 grid h-16 w-16 place-items-center rounded-full bg-[#16a34a] text-3xl text-white">✓</div>
        <h3 className="text-xl font-black text-[#0d1210]">Booking confirmed!</h3>
        <p className="mt-2 text-sm font-semibold text-[#64748b]">
          {formatDateFull(selectedDate)} · {formatTime(selectedStart)}–{formatTime(toTime(toMins(selectedStart) + durationMins))}
        </p>
        <p className="mt-1 text-sm font-semibold text-[#64748b]">{selectedUnit?.name} · Ref #{bookingRef}</p>
        {totalPaise > 0 && (
          <div className="mt-4 inline-block rounded-2xl bg-[#f0fdf4] px-5 py-3">
            <span className="text-lg font-black text-[#16a34a]">{rupees(totalPaise)}</span>
            <span className="ml-2 text-sm font-medium text-[#166534]">pay at venue</span>
          </div>
        )}
        <p className="mx-auto mt-5 max-w-xs text-sm font-medium text-[#64748b]">
          Arrive a few minutes early and show this screen at the front desk.
        </p>
        {phone && (
          <a href={`tel:${phone}`} className="mt-5 inline-block rounded-xl border border-[#e2e8f0] px-6 py-3 text-sm font-black text-[#0d1210]">
            Call arena
          </a>
        )}
      </div>
    );
  }

  // ── Main flow ────────────────────────────────────────────────────────────────
  return (
    <div className="space-y-6">
      {/* Unit tabs */}
      {units.length > 1 && (
        <div>
          <p className="mb-2 text-[11px] font-black uppercase tracking-widest text-[#94a3b8]">Court / Unit</p>
          <div className="flex flex-wrap gap-2">
            {units.map((u) => (
              <button
                key={u.id}
                onClick={() => handleUnitChange(u.id)}
                className={`rounded-xl px-4 py-2 text-sm font-bold transition-all ${
                  selectedUnitId === u.id
                    ? "bg-[#0d1210] text-white"
                    : "bg-[#f1f5f9] text-[#475569] hover:bg-[#e2e8f0]"
                }`}
              >
                {u.name}
              </button>
            ))}
          </div>
        </div>
      )}

      {/* Date strip */}
      <div>
        <p className="mb-2 text-[11px] font-black uppercase tracking-widest text-[#94a3b8]">Pick a date</p>
        <div className="flex gap-2 overflow-x-auto pb-1 scrollbar-none">
          {dates.map((d) => {
            const { day, wd } = shortDate(d);
            const sel = selectedDate === d;
            return (
              <button
                key={d}
                onClick={() => handleDateSelect(d)}
                className={`flex min-w-[54px] flex-col items-center rounded-2xl px-3 py-3 transition-all active:scale-95 ${
                  sel ? "bg-[#0d1210] text-white shadow-lg" : "bg-[#f1f5f9] text-[#334155]"
                }`}
              >
                <span className={`text-[10px] font-bold ${sel ? "text-white/60" : "text-[#94a3b8]"}`}>{wd}</span>
                <span className="mt-0.5 text-lg font-black leading-none">{day}</span>
              </button>
            );
          })}
        </div>
      </div>

      {/* Slot section */}
      {step !== "date" && (
        <div ref={slotRef} className="space-y-5">
          {loadingSlots ? (
            <div className="py-10 text-center">
              <div className="mx-auto h-6 w-6 animate-spin rounded-full border-2 border-[#16a34a] border-t-transparent" />
              <p className="mt-3 text-sm font-medium text-[#94a3b8]">Checking availability…</p>
            </div>
          ) : (
            <>
              {/* Duration */}
              <div>
                <p className="mb-2 text-[11px] font-black uppercase tracking-widest text-[#94a3b8]">Duration</p>
                {useGroundBundles ? (
                  <div className="flex flex-wrap gap-2">
                    {groundBundles.map((b) => (
                      <button
                        key={b.mins}
                        onClick={() => { setDurationMins(b.mins); setSelectedStart(""); }}
                        className={`rounded-2xl px-5 py-3 text-left transition-all active:scale-95 ${
                          durationMins === b.mins
                            ? "bg-[#0d1210] text-white shadow-md"
                            : "bg-[#f1f5f9] text-[#334155]"
                        }`}
                      >
                        <div className="text-base font-black">{b.label}</div>
                        <div className={`text-xs font-semibold ${durationMins === b.mins ? "text-white/60" : "text-[#94a3b8]"}`}>
                          {rupees(b.paise)}
                        </div>
                      </button>
                    ))}
                  </div>
                ) : slotUnit ? (
                  <div className="flex items-center gap-4">
                    <button
                      onClick={() => {
                        const inc = slotUnit.slotIncrementMins ?? slotUnit.minSlotMins ?? 60;
                        const min = slotUnit.minSlotMins ?? 60;
                        if (durationMins > min) { setDurationMins(durationMins - inc); setSelectedStart(""); }
                      }}
                      disabled={durationMins <= (slotUnit.minSlotMins ?? 60)}
                      className="grid h-10 w-10 place-items-center rounded-xl bg-[#f1f5f9] text-xl font-black text-[#334155] disabled:opacity-25 active:scale-95"
                    >−</button>
                    <div className="min-w-[72px] text-center">
                      <div className="text-xl font-black text-[#0d1210]">{durationLabel(durationMins)}</div>
                      {totalPaise > 0 && <div className="text-xs font-bold text-[#16a34a]">{rupees(totalPaise)}</div>}
                    </div>
                    <button
                      onClick={() => {
                        const inc = slotUnit.slotIncrementMins ?? slotUnit.minSlotMins ?? 60;
                        const max = slotUnit.maxSlotMins && slotUnit.maxSlotMins > (slotUnit.minSlotMins ?? 0) ? slotUnit.maxSlotMins : 480;
                        if (durationMins < max) { setDurationMins(durationMins + inc); setSelectedStart(""); }
                      }}
                      disabled={durationMins >= (slotUnit.maxSlotMins && slotUnit.maxSlotMins > (slotUnit.minSlotMins ?? 0) ? slotUnit.maxSlotMins : 480)}
                      className="grid h-10 w-10 place-items-center rounded-xl bg-[#f1f5f9] text-xl font-black text-[#334155] disabled:opacity-25 active:scale-95"
                    >+</button>
                  </div>
                ) : null}
              </div>

              {/* Time grid */}
              {durationMins > 0 && (
                <div>
                  <p className="mb-2 text-[11px] font-black uppercase tracking-widest text-[#94a3b8]">Start time</p>
                  <div className="grid grid-cols-4 gap-1.5">
                    {getAvailableSlots().map((s) => (
                      <button
                        key={s.start}
                        disabled={!s.available}
                        onClick={() => setSelectedStart(s.start)}
                        className={`rounded-xl py-2.5 text-xs font-bold transition-all active:scale-95 ${
                          !s.available
                            ? "cursor-not-allowed bg-[#f8fafc] text-[#cbd5e1] line-through"
                            : selectedStart === s.start
                            ? "bg-[#0d1210] text-white shadow-md"
                            : "bg-[#f1f5f9] text-[#475569] hover:bg-[#e2e8f0]"
                        }`}
                      >
                        {formatTime(s.start)}
                      </button>
                    ))}
                  </div>
                </div>
              )}

              {/* Selection summary + CTA */}
              {selectedStart && step === "slot" && (
                <div className="rounded-2xl bg-[#f8fafc] p-4">
                  <div className="mb-3 flex items-center justify-between text-sm">
                    <div>
                      <div className="font-black text-[#0d1210]">{formatDateFull(selectedDate)}</div>
                      <div className="mt-0.5 font-semibold text-[#64748b]">
                        {formatTime(selectedStart)} – {formatTime(toTime(toMins(selectedStart) + durationMins))} · {durationLabel(durationMins)}
                      </div>
                    </div>
                    {totalPaise > 0 && <div className="text-lg font-black text-[#16a34a]">{rupees(totalPaise)}</div>}
                  </div>
                  <button
                    onClick={() => setStep("form")}
                    className="w-full rounded-xl bg-[#16a34a] py-3.5 text-sm font-black text-white active:scale-[.98]"
                  >
                    Continue →
                  </button>
                </div>
              )}
            </>
          )}
        </div>
      )}

      {/* Contact form */}
      {step === "form" && (
        <div className="space-y-4">
          <div className="rounded-2xl bg-[#f0fdf4] px-4 py-3 text-sm">
            <div className="font-black text-[#166534]">{selectedUnit?.name} · {formatDateFull(selectedDate)}</div>
            <div className="mt-0.5 font-semibold text-[#16a34a]">
              {formatTime(selectedStart)} – {formatTime(toTime(toMins(selectedStart) + durationMins))}
              {totalPaise > 0 && <span className="ml-2 font-black">· {rupees(totalPaise)}</span>}
            </div>
          </div>

          <div>
            <label className="mb-1.5 block text-[11px] font-black uppercase tracking-widest text-[#94a3b8]">Your name</label>
            <input
              type="text"
              value={guestName}
              onChange={(e) => setGuestName(e.target.value)}
              placeholder="Full name"
              autoFocus
              className="w-full rounded-xl border border-[#e2e8f0] bg-white px-4 py-3.5 text-sm font-semibold text-[#0d1210] placeholder:text-[#cbd5e1] outline-none focus:border-[#0d1210]"
            />
          </div>
          <div>
            <label className="mb-1.5 block text-[11px] font-black uppercase tracking-widest text-[#94a3b8]">Phone number</label>
            <input
              type="tel"
              value={guestPhone}
              onChange={(e) => setGuestPhone(e.target.value)}
              placeholder="+91 98765 43210"
              className="w-full rounded-xl border border-[#e2e8f0] bg-white px-4 py-3.5 text-sm font-semibold text-[#0d1210] placeholder:text-[#cbd5e1] outline-none focus:border-[#0d1210]"
            />
          </div>

          {error && <p className="text-sm font-semibold text-red-500">{error}</p>}

          <button
            onClick={handleSubmit}
            disabled={submitting}
            className="w-full rounded-xl bg-[#16a34a] py-4 text-sm font-black text-white disabled:opacity-60 active:scale-[.98]"
          >
            {submitting ? "Confirming…" : `Confirm booking${totalPaise > 0 ? ` · ${rupees(totalPaise)}` : ""}`}
          </button>
          <button onClick={() => setStep("slot")} className="w-full py-2 text-sm font-semibold text-[#94a3b8]">
            ← Change slot
          </button>
        </div>
      )}

      {error && step !== "form" && (
        <p className="text-sm font-semibold text-red-500">{error}</p>
      )}
    </div>
  );
}
