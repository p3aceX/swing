"use client";

import { useState, useCallback, useTransition } from "react";

type BookedSlot = { startTime: string; endTime: string };
type SlotUnit = {
  id: string;
  name: string;
  unitType?: string;
  pricePerHourPaise?: number;
  minSlotMins?: number;
  maxSlotMins?: number;
  slotIncrementMins?: number;
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
  citySlug: string;
  arenaSlug: string;
  apiBaseUrl: string;
  phone?: string | null;
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

function formatDate(dateStr: string) {
  const d = new Date(dateStr + "T00:00:00");
  return d.toLocaleDateString("en-IN", { weekday: "short", day: "numeric", month: "short" });
}

function shortDate(dateStr: string) {
  const d = new Date(dateStr + "T00:00:00");
  const day = d.getDate();
  const wd = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][d.getDay()];
  return { day: String(day), wd };
}

export default function BookingFlow({ units, citySlug, arenaSlug, apiBaseUrl, phone }: Props) {
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
        const res = await fetch(
          `${apiBaseUrl}/public/arena/${citySlug}/${arenaSlug}/slots?date=${date}`,
        );
        if (!res.ok) throw new Error("Failed to load slots");
        const payload = (await res.json()) as { data?: { units?: SlotUnit[] } };
        const fetchedUnits = payload.data?.units ?? [];
        setSlotUnits(fetchedUnits);
        // set initial duration (ground bundles keep their selection; nets use minSlotMins)
        const u = fetchedUnits.find((x) => x.id === selectedUnitId);
        if (u && !GROUND_TYPES.has(selectedUnit?.unitType ?? "")) {
          setDurationMins(u.minSlotMins ?? 60);
        }
      } catch {
        setError("Could not load availability. Try again.");
      } finally {
        setLoadingSlots(false);
      }
    },
    [apiBaseUrl, citySlug, arenaSlug, selectedUnitId],
  );

  function handleDateSelect(date: string) {
    setSelectedDate(date);
    setStep("slot");
    fetchSlots(date);
  }

  function handleUnitChange(unitId: string) {
    setSelectedUnitId(unitId);
    const u = slotUnits.find((x) => x.id === unitId);
    if (u) setDurationMins(u.minSlotMins ?? 60);
    setSelectedStart("");
  }

  // Build available start times for selected duration
  function getAvailableSlots(): { start: string; end: string; available: boolean }[] {
    if (!durationMins) return [];
    const openStr = "06:00";
    const closeStr = "23:00";
    const open = toMins(openStr);
    const close = toMins(closeStr);
    const step = slotUnit?.slotIncrementMins ?? slotUnit?.minSlotMins ?? 60;
    const booked = slotUnit?.bookedSlots ?? [];

    const slots: { start: string; end: string; available: boolean }[] = [];
    for (let s = open; s + durationMins <= close; s += step) {
      const e = s + durationMins;
      const startT = toTime(s);
      const endT = toTime(e);
      const conflict = booked.some(
        (b) => b.startTime < endT && b.endTime > startT,
      );
      slots.push({ start: startT, end: endT, available: !conflict });
    }
    return slots;
  }

  // Ground bundle tiers
  function getGroundBundles() {
    const u = selectedUnit;
    if (!u) return [];
    const bundles: { mins: number; label: string; paise: number }[] = [];
    if (u.price4HrPaise) bundles.push({ mins: 240, label: "4 hrs", paise: u.price4HrPaise });
    if (u.price8HrPaise) bundles.push({ mins: 480, label: "8 hrs", paise: u.price8HrPaise });
    if (u.priceFullDayPaise) bundles.push({ mins: 720, label: "Full day", paise: u.priceFullDayPaise });
    return bundles;
  }

  const groundBundles = isGround ? getGroundBundles() : [];
  const useGroundBundles = isGround && groundBundles.length > 0;

  // Calculate price for current selection
  function calcPrice() {
    if (!durationMins) return 0;
    if (useGroundBundles) {
      const bundle = groundBundles.find((b) => b.mins === durationMins);
      return bundle?.paise ?? 0;
    }
    const pph = selectedUnit?.pricePerHourPaise ?? 0;
    return Math.round((pph * durationMins) / 60);
  }

  const totalPaise = calcPrice();

  function handleSlotSelect(start: string) {
    setSelectedStart(start);
  }

  function handleContinue() {
    if (!selectedStart) return;
    setStep("form");
  }

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
          setError(data.error ?? "Booking failed. The slot may have been taken.");
          return;
        }
        setBookingRef(data.data?.id?.slice(-6).toUpperCase() ?? "OK");
        setStep("done");
      } catch {
        setError("Network error. Please try again.");
      }
    });
  }

  if (step === "done") {
    return (
      <div className="flex flex-col items-center py-16 text-center">
        <div className="mb-4 grid h-16 w-16 place-items-center rounded-full bg-[#12b76a] text-3xl text-white">
          ✓
        </div>
        <h2 className="text-2xl font-black text-[#101828]">Booking confirmed!</h2>
        <p className="mt-2 text-sm font-semibold text-[#667085]">
          {formatDate(selectedDate)} &nbsp;·&nbsp; {formatTime(selectedStart)}–{formatTime(toTime(toMins(selectedStart) + durationMins))}
        </p>
        <p className="mt-1 text-sm font-semibold text-[#667085]">
          {selectedUnit?.name} &nbsp;·&nbsp; Ref: #{bookingRef}
        </p>
        {totalPaise > 0 && (
          <p className="mt-3 text-base font-black text-[#101828]">
            Amount: {rupees(totalPaise)} &nbsp;<span className="text-sm font-semibold text-[#667085]">(pay at venue)</span>
          </p>
        )}
        <p className="mt-6 max-w-xs text-sm font-medium text-[#667085]">
          Please arrive a few minutes early. Show this confirmation at the venue.
        </p>
        {phone && (
          <a href={`tel:${phone}`} className="mt-6 rounded-lg bg-[#101828] px-6 py-3 text-sm font-black text-white">
            Call arena
          </a>
        )}
      </div>
    );
  }

  const dates = Array.from({ length: 14 }, (_, i) => addDays(today, i));

  return (
    <div>
      {/* Unit selector */}
      {units.length > 1 && (
        <div className="mb-5">
          <div className="text-xs font-black uppercase tracking-wide text-[#98a2b3] mb-2">Select unit</div>
          <div className="flex flex-wrap gap-2">
            {units.map((u) => (
              <button
                key={u.id}
                onClick={() => handleUnitChange(u.id)}
                className={`rounded-lg px-4 py-2 text-sm font-bold transition-colors ${
                  selectedUnitId === u.id
                    ? "bg-[#101828] text-white"
                    : "bg-[#f3f4f6] text-[#475467] hover:bg-[#e5e7eb]"
                }`}
              >
                {u.name}
              </button>
            ))}
          </div>
        </div>
      )}

      {/* Date selector */}
      <div className="mb-5">
        <div className="text-xs font-black uppercase tracking-wide text-[#98a2b3] mb-2">Select date</div>
        <div className="flex gap-2 overflow-x-auto pb-1 scrollbar-none">
          {dates.map((d) => {
            const { day, wd } = shortDate(d);
            const isSelected = selectedDate === d;
            return (
              <button
                key={d}
                onClick={() => handleDateSelect(d)}
                className={`flex min-w-[52px] flex-col items-center rounded-xl px-3 py-2.5 text-sm transition-colors ${
                  isSelected
                    ? "bg-[#101828] text-white"
                    : "bg-[#f3f4f6] text-[#475467] hover:bg-[#e5e7eb]"
                }`}
              >
                <span className={`text-xs font-semibold ${isSelected ? "text-white/70" : "text-[#98a2b3]"}`}>{wd}</span>
                <span className="mt-0.5 text-base font-black">{day}</span>
              </button>
            );
          })}
        </div>
      </div>

      {/* Slot picker */}
      {step !== "date" && (
        <>
          {loadingSlots ? (
            <div className="py-8 text-center text-sm font-semibold text-[#98a2b3]">Loading availability…</div>
          ) : (
            <>
              {/* Duration / bundle selector */}
              <div className="mb-4">
                <div className="text-xs font-black uppercase tracking-wide text-[#98a2b3] mb-2">Duration</div>
                {useGroundBundles ? (
                  <div className="flex flex-wrap gap-2">
                    {groundBundles.map((b) => (
                      <button
                        key={b.mins}
                        onClick={() => { setDurationMins(b.mins); setSelectedStart(""); }}
                        className={`rounded-xl px-5 py-3 text-sm font-bold transition-colors ${
                          durationMins === b.mins
                            ? "bg-[#101828] text-white"
                            : "bg-[#f3f4f6] text-[#475467] hover:bg-[#e5e7eb]"
                        }`}
                      >
                        <span className="block text-base font-black">{b.label}</span>
                        <span className={`text-xs ${durationMins === b.mins ? "text-white/70" : "text-[#98a2b3]"}`}>
                          {rupees(b.paise)}
                        </span>
                      </button>
                    ))}
                  </div>
                ) : slotUnit ? (
                  <div className="flex items-center gap-3">
                    <button
                      onClick={() => {
                        const step = slotUnit.slotIncrementMins ?? slotUnit.minSlotMins ?? 60;
                        const min = slotUnit.minSlotMins ?? 60;
                        if (durationMins > min) { setDurationMins(durationMins - step); setSelectedStart(""); }
                      }}
                      disabled={durationMins <= (slotUnit.minSlotMins ?? 60)}
                      className="grid h-9 w-9 place-items-center rounded-lg bg-[#f3f4f6] text-lg font-black text-[#475467] disabled:opacity-30"
                    >
                      −
                    </button>
                    <span className="min-w-[60px] text-center text-base font-black text-[#101828]">
                      {durationLabel(durationMins)}
                    </span>
                    <button
                      onClick={() => {
                        const s = slotUnit.slotIncrementMins ?? slotUnit.minSlotMins ?? 60;
                        const max = slotUnit.maxSlotMins && slotUnit.maxSlotMins > (slotUnit.minSlotMins ?? 0)
                          ? slotUnit.maxSlotMins
                          : 480;
                        if (durationMins < max) { setDurationMins(durationMins + s); setSelectedStart(""); }
                      }}
                      disabled={
                        durationMins >=
                        (slotUnit.maxSlotMins && slotUnit.maxSlotMins > (slotUnit.minSlotMins ?? 0)
                          ? slotUnit.maxSlotMins
                          : 480)
                      }
                      className="grid h-9 w-9 place-items-center rounded-lg bg-[#f3f4f6] text-lg font-black text-[#475467] disabled:opacity-30"
                    >
                      +
                    </button>
                    {totalPaise > 0 && (
                      <span className="ml-2 text-sm font-black text-[#059669]">{rupees(totalPaise)}</span>
                    )}
                  </div>
                ) : null}
              </div>

              {/* Start time grid */}
              {durationMins > 0 && (
                <div className="mb-5">
                  <div className="text-xs font-black uppercase tracking-wide text-[#98a2b3] mb-2">Start time</div>
                  {
                    <div className="grid grid-cols-4 gap-1.5 sm:grid-cols-6">
                      {getAvailableSlots().map((s) => (
                        <button
                          key={s.start}
                          disabled={!s.available}
                          onClick={() => handleSlotSelect(s.start)}
                          className={`rounded-lg py-2 text-xs font-bold transition-colors ${
                            !s.available
                              ? "bg-[#f3f4f6] text-[#d0d5dd] line-through cursor-not-allowed"
                              : selectedStart === s.start
                              ? "bg-[#101828] text-white"
                              : "bg-[#f3f4f6] text-[#475467] hover:bg-[#e5e7eb]"
                          }`}
                        >
                          {formatTime(s.start)}
                        </button>
                      ))}
                    </div>
                  }
                </div>
              )}

              {/* Continue button */}
              {selectedStart && step === "slot" && (
                <div className="mb-2">
                  <div className="mb-3 rounded-lg bg-[#f9fafb] px-4 py-3 text-sm font-semibold text-[#475467]">
                    {formatDate(selectedDate)} &nbsp;·&nbsp; {formatTime(selectedStart)}–{formatTime(toTime(toMins(selectedStart) + durationMins))} &nbsp;·&nbsp; {durationLabel(durationMins)}
                    {totalPaise > 0 && <span className="ml-2 font-black text-[#059669]">{rupees(totalPaise)}</span>}
                  </div>
                  <button
                    onClick={handleContinue}
                    className="w-full rounded-xl bg-[#12b76a] py-3.5 text-sm font-black text-white"
                  >
                    Continue to book
                  </button>
                </div>
              )}
            </>
          )}
        </>
      )}

      {/* Guest info form */}
      {step === "form" && (
        <div className="mt-2">
          <div className="mb-3 rounded-lg bg-[#f9fafb] px-4 py-3 text-sm font-semibold text-[#475467]">
            {formatDate(selectedDate)} &nbsp;·&nbsp; {formatTime(selectedStart)}–{formatTime(toTime(toMins(selectedStart) + durationMins))}
            {totalPaise > 0 && <span className="ml-2 font-black text-[#059669]">{rupees(totalPaise)}</span>}
          </div>
          <div className="mb-3">
            <div className="text-xs font-black uppercase tracking-wide text-[#98a2b3] mb-1.5">Your name</div>
            <input
              type="text"
              value={guestName}
              onChange={(e) => setGuestName(e.target.value)}
              placeholder="Full name"
              className="w-full rounded-xl border border-[#e4e7ec] bg-white px-4 py-3 text-sm font-semibold text-[#101828] placeholder:text-[#d0d5dd] outline-none focus:border-[#101828]"
            />
          </div>
          <div className="mb-4">
            <div className="text-xs font-black uppercase tracking-wide text-[#98a2b3] mb-1.5">Phone number</div>
            <input
              type="tel"
              value={guestPhone}
              onChange={(e) => setGuestPhone(e.target.value)}
              placeholder="+91 99999 99999"
              className="w-full rounded-xl border border-[#e4e7ec] bg-white px-4 py-3 text-sm font-semibold text-[#101828] placeholder:text-[#d0d5dd] outline-none focus:border-[#101828]"
            />
          </div>
          {error && <p className="mb-3 text-sm font-semibold text-red-500">{error}</p>}
          <button
            onClick={handleSubmit}
            disabled={submitting}
            className="w-full rounded-xl bg-[#12b76a] py-3.5 text-sm font-black text-white disabled:opacity-60"
          >
            {submitting ? "Confirming…" : `Confirm booking${totalPaise > 0 ? ` · ${rupees(totalPaise)}` : ""}`}
          </button>
          <button
            onClick={() => setStep("slot")}
            className="mt-2 w-full py-2 text-sm font-semibold text-[#667085]"
          >
            ← Change slot
          </button>
        </div>
      )}

      {error && step !== "form" && (
        <p className="mt-3 text-sm font-semibold text-red-500">{error}</p>
      )}
    </div>
  );
}
