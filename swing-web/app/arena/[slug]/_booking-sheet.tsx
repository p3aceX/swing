"use client";

import { useEffect } from "react";
import BookingFlow from "./_booking-flow";

type NetVariant = { type: string; label: string; pricePaise?: number | null };
type ArenaAddon = { id: string; name: string; pricePaise: number; description?: string | null; unit?: string | null };
type ArenaUnit = {
  id: string;
  name: string;
  unitType?: string;
  pricePerHourPaise?: number;
  minSlotMins?: number;
  maxSlotMins?: number;
  price4HrPaise?: number | null;
  price8HrPaise?: number | null;
  priceFullDayPaise?: number | null;
  netVariants?: NetVariant[] | null;
  monthlyPassEnabled?: boolean;
  monthlyPassRatePaise?: number | null;
  minBulkDays?: number | null;
  bulkDayRatePaise?: number | null;
  addons?: ArenaAddon[] | null;
  minAdvancePaise?: number | null;
  cancellationHours?: number | null;
};

type Props = {
  open: boolean;
  onClose: () => void;
  units: ArenaUnit[];
  arenaId: string;
  arenaSlug: string;
  apiBaseUrl: string;
  arenaName: string;
  address?: string | null;
  latitude?: number | null;
  longitude?: number | null;
  phone?: string | null;
  openTime?: string | null;
  closeTime?: string | null;
  advanceBookingDays?: number | null;
  cancellationHours?: number | null;
};

export default function BookingSheet({ open, onClose, advanceBookingDays, cancellationHours, ...flowProps }: Props) {
  // Body-scroll lock is owned by the parent microsite (single source of
  // truth). This effect only handles the Escape key. Keep deps lean so
  // we don't re-register on every render.
  useEffect(() => {
    if (!open) return;
    const onKey = (e: KeyboardEvent) => { if (e.key === "Escape") onClose(); };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [open, onClose]);

  if (!open) return null;

  return (
    <div className="ms-sheet" role="dialog" aria-modal="true" aria-label="Book a slot">
      <button className="ms-sheet-scrim" aria-label="Close" onClick={onClose} />
      <div className="ms-sheet-panel pass">
        <header className="ms-sheet-head">
          <div className="ms-sheet-title">
            <span className="ms-sheet-eyebrow">01 — BOOK A SLOT</span>
            <span className="ms-sheet-venue">{flowProps.arenaName}</span>
          </div>
          <button className="ms-sheet-close" onClick={onClose} aria-label="Close booking sheet">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round"><path d="M6 6l12 12M18 6l-12 12"/></svg>
          </button>
        </header>
        <div className="ms-sheet-body">
          {(advanceBookingDays != null || cancellationHours != null) && (
            <ul className="ms-sheet-policy" aria-label="Booking policy">
              {advanceBookingDays != null && advanceBookingDays > 0 && (
                <li>
                  <span className="ms-sheet-policy-lbl">Book ahead</span>
                  <span className="ms-sheet-policy-val">Up to {advanceBookingDays} {advanceBookingDays === 1 ? "day" : "days"}</span>
                </li>
              )}
              {cancellationHours != null && cancellationHours > 0 && (
                <li>
                  <span className="ms-sheet-policy-lbl">Cancellation</span>
                  <span className="ms-sheet-policy-val">{cancellationHours}h before slot</span>
                </li>
              )}
            </ul>
          )}
          <BookingFlow
            units={flowProps.units}
            arenaId={flowProps.arenaId}
            arenaSlug={flowProps.arenaSlug}
            apiBaseUrl={flowProps.apiBaseUrl}
            arenaName={flowProps.arenaName}
            address={flowProps.address || undefined}
            latitude={flowProps.latitude}
            longitude={flowProps.longitude}
            phone={flowProps.phone}
            openTime={flowProps.openTime}
            closeTime={flowProps.closeTime}
          />
        </div>
      </div>

      <style>{`
        .ms-sheet {
          position: fixed; inset: 0; z-index: 9000;
          display: flex; align-items: flex-end; justify-content: center;
          animation: ms-fade 0.2s ease;
        }
        @keyframes ms-fade { from { opacity: 0; } to { opacity: 1; } }
        .ms-sheet-scrim {
          position: absolute; inset: 0;
          background: rgba(0, 0, 0, 0.55);
          backdrop-filter: blur(3px);
          border: 0;
          cursor: pointer;
        }
        .ms-sheet-panel {
          position: relative;
          width: 100%;
          max-width: 760px;
          max-height: 92vh;
          background: var(--ms-bg);
          color: var(--ms-ink);
          display: flex;
          flex-direction: column;
          overflow: hidden;
          border-radius: 6px 6px 0 0;
          animation: ms-slide 0.26s cubic-bezier(0.2, 0.7, 0.2, 1);
          /* Inherit microsite tokens so the pass re-skin uses theme colors */
          --pass-paper:   var(--ms-bg);
          --pass-ink:     var(--ms-ink);
          --pass-muted:   var(--ms-muted);
          --pass-line:    var(--ms-line-strong);
          --pass-line-2:  var(--ms-line);
          --pass-accent:  var(--ms-ink);
          --pass-live-dot: var(--ms-brand);
          --pass-muted-inv: var(--ms-muted-inv);
          --pass-line-inv:  var(--ms-line-inv);
          --accent:        var(--ms-brand);
          --accent-ink:    var(--ms-brand-ink);
        }
        @keyframes ms-slide { from { transform: translateY(100%); } to { transform: translateY(0); } }
        /* No desktop "centered modal" — always anchor to the bottom. */
        .ms-sheet-head {
          flex: 0 0 auto;
          display: flex;
          align-items: center;
          justify-content: space-between;
          padding: 18px 22px;
          border-bottom: 1px solid var(--ms-line);
          background: var(--ms-bg);
        }
        .ms-sheet-title { display: flex; flex-direction: column; gap: 4px; min-width: 0; }
        .ms-sheet-eyebrow {
          font-family: var(--font-geist-mono, ui-monospace, Menlo, monospace);
          font-size: 10px;
          font-weight: 600;
          letter-spacing: 0.22em;
          color: var(--ms-muted);
        }
        .ms-sheet-venue {
          font-family: var(--font-bricolage), "Bricolage Grotesque", var(--font-geist-sans), system-ui, sans-serif;
          font-size: 18px;
          font-weight: 700;
          letter-spacing: -0.02em;
          color: var(--ms-ink);
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }
        .ms-sheet-close {
          all: unset; cursor: pointer;
          width: 36px; height: 36px;
          display: inline-grid; place-items: center;
          color: var(--ms-ink);
          border: 1px solid var(--ms-line-strong);
          transition: background 0.12s ease;
        }
        .ms-sheet-close:hover { background: var(--ms-line); }
        .ms-sheet-body {
          flex: 1 1 auto;
          overflow-y: auto;
          padding: 22px 24px 40px;
          -webkit-overflow-scrolling: touch;
        }
        /* Every step pane gets breathing room before the sticky CTA bar */
        .pass .pass-pane { padding-bottom: 36px; }
        .pass .opt-list,
        .pass .slot-grid,
        .pass .cal-strip,
        .pass .bulk-cal,
        .pass .bulk-fields,
        .pass .bulk-guest { margin-bottom: 12px; }

        /* ── Step indicator ── */
        .pass .pass-stepbar {
          display: flex;
          align-items: center;
          gap: 0;
          margin: 6px 0 22px;
        }
        .pass .pass-step {
          display: flex;
          align-items: center;
        }
        .pass .pass-step-dot {
          width: 26px; height: 26px;
          flex-shrink: 0;
          border-radius: 4px;
          border: 1px solid var(--ms-line-strong);
          background: var(--ms-bg);
          color: var(--ms-soft);
          display: inline-grid;
          place-items: center;
          font-family: var(--font-geist-mono, ui-monospace, Menlo, monospace);
          font-weight: 700;
          font-size: 11px;
          transition: background 0.18s ease, color 0.18s ease, border-color 0.18s ease;
        }
        .pass .pass-step-dot.is-done {
          background: var(--ms-ink);
          color: var(--ms-bg);
          border-color: var(--ms-ink);
        }
        .pass .pass-step-dot.is-active {
          background: var(--ms-brand);
          color: var(--ms-brand-ink);
          border-color: var(--ms-brand);
        }
        .pass .pass-step-rail {
          flex: 1;
          height: 1px;
          background: var(--ms-line);
          margin: 0 8px;
          transition: background 0.18s ease;
        }
        .pass .pass-step-rail.is-done { background: var(--ms-ink); }
        .pass .pass-step-label {
          margin-left: 12px;
          font-family: var(--font-geist-mono, ui-monospace, Menlo, monospace);
          font-size: 10.5px;
          font-weight: 700;
          letter-spacing: 0.18em;
          text-transform: uppercase;
          color: var(--ms-muted);
          white-space: nowrap;
        }

        /* BACK button — keep it inline-sized, not stretched */
        .pass .pass-back {
          align-self: flex-start;
        }

        /* Arena policy line shown at the top of the booking sheet */
        .ms-sheet-policy {
          list-style: none;
          margin: 0 0 18px;
          padding: 12px 14px;
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
          gap: 10px 18px;
          background: color-mix(in srgb, var(--ms-brand) 6%, transparent);
          border: 1px solid color-mix(in srgb, var(--ms-brand) 22%, transparent);
          border-radius: 4px;
        }
        .ms-sheet-policy li {
          display: flex;
          flex-direction: column;
          gap: 2px;
          min-width: 0;
        }
        .ms-sheet-policy-lbl {
          font-family: var(--font-geist-mono, ui-monospace, Menlo, monospace);
          font-size: 9.5px;
          font-weight: 700;
          letter-spacing: 0.18em;
          text-transform: uppercase;
          color: var(--ms-muted);
        }
        .ms-sheet-policy-val {
          font-size: 13.5px;
          font-weight: 600;
          letter-spacing: -0.005em;
          color: var(--ms-ink);
        }

        /* ───────────────────────────────────────────────────────────
           BOOKING FLOW — scoped to the sheet panel (.pass).
           Maps the legacy class names from _booking-flow.tsx onto the
           microsite design tokens so the form/options/slot grid/CTA
           all read consistently in light + dark.
           ─────────────────────────────────────────────────────────── */

        /* Legacy-token aliases — the booking flow has dozens of inline
           styles referencing --paper / --hairline / --ink / --font-ui /
           --r-md / --bad / --paper-2. Map them to microsite tokens so
           every inline-styled element picks up the theme + brand color. */
        .pass {
          --paper:      var(--ms-bg);
          --paper-2:    var(--ms-surface);
          --ink:        var(--ms-ink);
          --ink-2:      var(--ms-ink);
          --ink-3:      var(--ms-muted);
          --hairline:   var(--ms-line);
          --bad:        #DC2626;
          --font-ui:    var(--font-bricolage), var(--font-geist-sans), system-ui, sans-serif;
          --r-sm:       4px;
          --r-md:       6px;
          --r-lg:       6px;
          --accent:     var(--ms-brand);
          --accent-ink: var(--ms-brand-ink);
        }
        .pass .pass-h1 {
          margin: 4px 0 8px;
          font-family: var(--font-bricolage), "Bricolage Grotesque", var(--font-geist-sans), system-ui, sans-serif;
          font-size: 26px;
          font-weight: 700;
          letter-spacing: -0.028em;
          line-height: 1.08;
          color: var(--ms-ink);
        }
        @media (min-width: 540px) { .pass .pass-h1 { font-size: 30px; } }
        .pass .pass-sub {
          margin: 0 0 22px;
          font-size: 14px;
          line-height: 1.5;
          color: var(--ms-muted);
          max-width: 56ch;
        }
        .pass .pass-pane { display: flex; flex-direction: column; }
        .pass .eyebrow {
          font-family: var(--font-geist-mono, ui-monospace, Menlo, monospace);
          font-size: 10.5px;
          font-weight: 700;
          letter-spacing: 0.2em;
          color: var(--ms-muted);
          text-transform: uppercase;
        }
        .pass .pass-back {
          all: unset; cursor: pointer;
          display: inline-flex; align-items: center; gap: 6px;
          padding: 7px 12px;
          border: 1px solid var(--ms-line-strong);
          border-radius: 6px;
          font-family: var(--font-geist-mono);
          font-size: 11px;
          font-weight: 700;
          letter-spacing: 0.14em;
          text-transform: uppercase;
          color: var(--ms-ink);
          margin: 0 0 14px;
          transition: background 0.12s ease;
        }
        .pass .pass-back:hover { background: var(--ms-line); }
        .pass .pass-context {
          margin: 6px 0 12px;
          font-family: var(--font-geist-mono);
          font-size: 12.5px;
          font-weight: 700;
          letter-spacing: 0.02em;
          color: var(--ms-ink);
        }

        /* ── Form fields ── */
        .pass .form-field { display: flex; flex-direction: column; gap: 6px; margin-bottom: 14px; }
        .pass .form-label {
          font-family: var(--font-geist-mono);
          font-size: 10px;
          font-weight: 700;
          letter-spacing: 0.18em;
          text-transform: uppercase;
          color: var(--ms-muted);
        }
        .pass .form-input {
          appearance: none;
          width: 100%;
          padding: 12px 14px;
          font: inherit;
          font-size: 15px;
          color: var(--ms-ink);
          background: var(--ms-bg);
          border: 1px solid var(--ms-line-strong);
          border-radius: 4px;
          outline: none;
          transition: border-color 0.12s ease, background 0.12s ease;
        }
        .pass .form-input:focus {
          border-color: var(--ms-ink);
          background: var(--ms-surface);
        }
        .pass .form-input::placeholder { color: var(--ms-soft); }
        .pass select.form-input { padding-right: 36px; background-position: right 10px center; background-repeat: no-repeat; background-size: 12px; }

        /* ── Option rows (sport/unit/etc selectors) ── */
        .pass .opt-list { display: flex; flex-direction: column; gap: 10px; margin: 8px 0 0; }
        .pass .opt {
          all: unset; cursor: pointer;
          display: flex; align-items: center; gap: 14px;
          padding: 14px 16px;
          background: var(--ms-bg);
          border: 1px solid var(--ms-line);
          border-radius: 6px;
          color: var(--ms-ink);
          transition: border-color 0.14s ease, background 0.14s ease;
        }
        .pass .opt:hover {
          border-color: var(--ms-line-strong);
          background: color-mix(in srgb, var(--ms-line) 50%, var(--ms-bg));
        }
        .pass .opt.selected {
          background: var(--ms-brand);
          color: var(--ms-brand-ink);
          border-color: var(--ms-brand);
        }
        .pass .opt.opt-highlight {
          border-color: var(--ms-brand);
          background: color-mix(in srgb, var(--ms-brand) 6%, var(--ms-bg));
        }
        .pass .opt-icon {
          flex: 0 0 auto;
          width: 36px; height: 36px;
          display: inline-grid; place-items: center;
          border-radius: 4px;
          background: color-mix(in srgb, var(--ms-brand) 14%, transparent);
          color: var(--ms-brand);
        }
        .pass .opt.selected .opt-icon {
          background: color-mix(in srgb, var(--ms-brand-ink) 18%, transparent);
          color: var(--ms-brand-ink);
        }
        .pass .opt-body { flex: 1; min-width: 0; display: flex; flex-direction: column; gap: 3px; }
        .pass .opt-name {
          font-size: 14.5px;
          font-weight: 700;
          letter-spacing: -0.005em;
          display: inline-flex; align-items: center; gap: 8px;
        }
        .pass .opt-sub { font-size: 12.5px; color: var(--ms-muted); line-height: 1.35; }
        .pass .opt.selected .opt-sub { color: color-mix(in srgb, var(--ms-brand-ink) 78%, transparent); }
        .pass .opt-price {
          flex: 0 0 auto;
          font-family: var(--font-geist-mono);
          font-size: 14px;
          font-weight: 700;
          color: var(--ms-ink);
          white-space: nowrap;
        }
        .pass .opt.selected .opt-price { color: var(--ms-brand-ink); }
        .pass .opt-badge {
          font-family: var(--font-geist-mono);
          font-size: 9.5px;
          font-weight: 700;
          letter-spacing: 0.14em;
          background: var(--ms-brand);
          color: var(--ms-brand-ink);
          padding: 3px 7px;
          border-radius: 6px;
        }
        .pass .opt-err {
          margin: 6px 2px 0;
          font-size: 12px;
          color: #DC2626;
          font-weight: 600;
        }

        /* ── Calendar / date strip (cal-day buttons) ── */
        .pass .cal-strip {
          display: flex;
          gap: 8px;
          overflow-x: auto;
          margin: 4px 0 18px;
          padding: 2px 0 10px;
          scroll-snap-type: x mandatory;
          -webkit-overflow-scrolling: touch;
        }
        .pass .cal-strip::-webkit-scrollbar { display: none; }
        .pass .cal-day {
          all: unset;
          cursor: pointer;
          flex: 0 0 auto;
          min-width: 64px;
          padding: 10px 10px 12px;
          background: var(--ms-bg);
          border: 1px solid var(--ms-line);
          border-radius: 6px;
          color: var(--ms-ink);
          text-align: center;
          scroll-snap-align: start;
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 4px;
          transition: border-color 0.14s ease, background 0.14s ease, color 0.14s ease;
          position: relative;
        }
        .pass .cal-day:hover { border-color: var(--ms-line-strong); }
        .pass .cal-day.selected {
          background: var(--ms-brand);
          color: var(--ms-brand-ink);
          border-color: var(--ms-brand);
        }
        .pass .cal-day[disabled],
        .pass .cal-day.cal-full {
          cursor: not-allowed;
          color: var(--ms-soft);
          background: transparent;
          border-style: dashed;
        }
        .pass .cal-day.cal-full .dom { text-decoration: line-through; }

        .pass .dow {
          font-family: var(--font-geist-mono, ui-monospace, Menlo, monospace);
          font-size: 9.5px;
          font-weight: 700;
          letter-spacing: 0.16em;
          color: var(--ms-muted);
          text-transform: uppercase;
        }
        .pass .cal-day.selected .dow { color: color-mix(in srgb, var(--ms-brand-ink) 78%, transparent); }
        .pass .dom {
          font-family: var(--font-bricolage), var(--font-geist-sans), system-ui, sans-serif;
          font-size: 18px;
          font-weight: 700;
          letter-spacing: -0.02em;
          line-height: 1;
        }
        /* Inner availability indicator inside each cal-day */
        .pass .cal-day .avail {
          display: inline-flex;
          align-items: center;
          min-height: 8px;
        }
        .pass .dot {
          display: inline-block;
          width: 6px; height: 6px;
          border-radius: 50%;
        }
        .pass .dot-green { background: var(--ms-brand); }
        .pass .dot-amber { background: #F59E0B; }
        .pass .cal-day.selected .dot-green,
        .pass .cal-day.selected .dot-amber { background: var(--ms-brand-ink); opacity: 0.85; }
        .pass .dot-label {
          font-family: var(--font-geist-mono);
          font-size: 9px;
          font-weight: 700;
          letter-spacing: 0.14em;
          color: var(--ms-soft);
          text-transform: uppercase;
        }

        /* ── Time slots ── */
        .pass .slot-grid {
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(108px, 1fr));
          gap: 8px;
          margin: 10px 0 6px;
        }
        .pass .slot {
          all: unset; cursor: pointer;
          padding: 10px 12px;
          background: var(--ms-bg);
          border: 1px solid var(--ms-line-strong);
          border-radius: 4px;
          color: var(--ms-ink);
          font-family: var(--font-geist-mono);
          font-size: 12.5px;
          font-weight: 600;
          letter-spacing: 0.02em;
          display: flex;
          flex-direction: column;
          gap: 3px;
          align-items: flex-start;
          transition: background 0.12s ease, border-color 0.12s ease;
        }
        .pass .slot:hover { background: var(--ms-line); }
        .pass .slot.selected {
          background: var(--ms-brand);
          color: var(--ms-brand-ink);
          border-color: var(--ms-brand);
        }
        .pass .slot.unavailable {
          color: var(--ms-soft);
          background: transparent;
          border-style: dashed;
          cursor: not-allowed;
          text-decoration: line-through;
        }
        .pass .slot.peak::after {
          content: " · PEAK";
          font-size: 9.5px;
          font-weight: 700;
          letter-spacing: 0.12em;
          color: var(--ms-muted);
        }
        .pass .slot.selected.peak::after { color: var(--ms-brand-ink); opacity: 0.7; }
        .pass .s-time { font-size: 13.5px; font-weight: 700; }
        .pass .s-price { font-size: 11.5px; color: var(--ms-muted); }
        .pass .slot.selected .s-price { color: var(--ms-brand-ink); opacity: 0.88; }
        .pass .slot .badge {
          font-family: var(--font-geist-mono);
          font-size: 9px;
          font-weight: 700;
          letter-spacing: 0.14em;
          color: var(--ms-brand);
        }
        .pass .slot.selected .badge { color: var(--ms-brand-ink); }

        /* ── Duration stepper ── */
        .pass .dur-stepper {
          display: inline-flex;
          align-items: stretch;
          border: 1px solid var(--ms-line-strong);
          border-radius: 6px;
          overflow: hidden;
          background: var(--ms-bg);
        }
        .pass .dur-btn {
          all: unset; cursor: pointer;
          width: 38px; height: 38px;
          display: inline-grid; place-items: center;
          font-size: 16px;
          color: var(--ms-ink);
          transition: background 0.12s ease;
        }
        .pass .dur-btn:hover { background: var(--ms-line); }
        .pass .dur-btn[disabled] { color: var(--ms-soft); cursor: not-allowed; }
        .pass .dur-val {
          padding: 0 14px;
          align-self: center;
          font-family: var(--font-geist-mono);
          font-size: 13px;
          font-weight: 700;
          letter-spacing: 0.04em;
          color: var(--ms-ink);
          border-left: 1px solid var(--ms-line);
          border-right: 1px solid var(--ms-line);
        }
        .pass .dur-price {
          font-family: var(--font-geist-mono);
          font-size: 12.5px;
          font-weight: 700;
          color: var(--ms-muted);
          margin-left: 10px;
        }

        /* ── Bulk booking ── */
        .pass .bulk-modes {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 0;
          margin: 6px 0 14px;
          border: 1px solid var(--ms-line-strong);
          border-radius: 6px;
          overflow: hidden;
        }
        .pass .bulk-modes .opt {
          border: 0;
          border-radius: 0;
          border-right: 1px solid var(--ms-line-strong);
          justify-content: center;
        }
        .pass .bulk-modes .opt:last-child { border-right: 0; }
        .pass .bulk-cal {
          background: var(--ms-bg);
          border: 1px solid var(--ms-line-strong);
          border-radius: 6px;
          padding: 12px;
          margin: 8px 0 14px;
        }
        .pass .bulk-cal-dow,
        .pass .bulk-cal-grid {
          display: grid;
          grid-template-columns: repeat(7, 1fr);
          gap: 4px;
        }
        .pass .bulk-cal-dow > * {
          font-family: var(--font-geist-mono);
          font-size: 9.5px;
          font-weight: 700;
          letter-spacing: 0.14em;
          color: var(--ms-muted);
          text-align: center;
          padding: 4px 0;
        }
        .pass .bulk-cal-grid button {
          all: unset; cursor: pointer;
          aspect-ratio: 1 / 1;
          display: grid; place-items: center;
          border-radius: 6px;
          font-size: 12px;
          font-weight: 600;
          color: var(--ms-ink);
          transition: background 0.12s ease;
        }
        .pass .bulk-cal-grid button:hover { background: var(--ms-line); }
        .pass .bulk-cal-grid button.selected { background: var(--ms-brand); color: var(--ms-brand-ink); }
        .pass .bulk-cal-grid button:disabled { color: var(--ms-soft); cursor: not-allowed; }
        .pass .bulk-fields,
        .pass .bulk-guest {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 10px;
        }
        @media (max-width: 480px) {
          .pass .bulk-fields, .pass .bulk-guest { grid-template-columns: 1fr; }
        }

        /* ── Bottom CTA bar inside the booking flow ── */
        .pass .cta-bar {
          position: sticky;
          bottom: 0;
          margin: 22px -24px -28px;
          padding: 16px 24px calc(16px + env(safe-area-inset-bottom, 0));
          background: var(--ms-bg);
          border-top: 1px solid var(--ms-line);
          display: flex;
          align-items: center;
          justify-content: space-between;
          gap: 16px;
        }
        .pass .cta-info { display: flex; flex-direction: column; gap: 3px; min-width: 0; }
        .pass .cta-amt {
          font-family: var(--font-bricolage), "Bricolage Grotesque", var(--font-geist-sans), system-ui, sans-serif;
          font-size: 22px;
          font-weight: 700;
          letter-spacing: -0.025em;
          color: var(--ms-ink);
          line-height: 1;
        }
        .pass .cta-sub {
          font-family: var(--font-geist-mono);
          font-size: 10px;
          font-weight: 700;
          letter-spacing: 0.18em;
          color: var(--ms-muted);
          text-transform: uppercase;
        }
        .pass .cta-btn {
          all: unset; cursor: pointer;
          display: inline-flex;
          align-items: center;
          gap: 8px;
          padding: 14px 22px;
          font-weight: 700;
          font-size: 15px;
          letter-spacing: -0.005em;
          border-radius: 6px;
          border: 1px solid var(--ms-line-strong);
          color: var(--ms-ink);
          background: var(--ms-bg);
          white-space: nowrap;
          transition: background 0.14s ease, filter 0.14s ease;
        }
        .pass .cta-btn:hover { background: var(--ms-line); }
        .pass .cta-btn.cta-primary {
          background: var(--ms-brand);
          color: var(--ms-brand-ink);
          border-color: var(--ms-brand);
        }
        .pass .cta-btn.cta-primary:hover { filter: brightness(0.94); }
        .pass .cta-btn:disabled { opacity: 0.5; cursor: not-allowed; }
        .pass .cta-btn svg { width: 14px; height: 14px; }

        .pass .pay-note {
          margin: 14px 0 0;
          padding: 10px 12px;
          background: color-mix(in srgb, var(--ms-brand) 8%, transparent);
          border: 1px solid color-mix(in srgb, var(--ms-brand) 24%, transparent);
          border-radius: 4px;
          font-size: 12.5px;
          line-height: 1.4;
          color: var(--ms-ink);
        }
      `}</style>
    </div>
  );
}
