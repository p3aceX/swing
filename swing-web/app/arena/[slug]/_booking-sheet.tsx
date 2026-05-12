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
};

export default function BookingSheet({ open, onClose, ...flowProps }: Props) {
  useEffect(() => {
    if (!open) return;
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    const onKey = (e: KeyboardEvent) => { if (e.key === "Escape") onClose(); };
    window.addEventListener("keydown", onKey);
    return () => {
      document.body.style.overflow = prev;
      window.removeEventListener("keydown", onKey);
    };
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
        @keyframes ms-slide { from { transform: translateY(28px); } to { transform: translateY(0); } }
        @media (min-width: 720px) {
          .ms-sheet { align-items: center; padding: 24px; }
        }
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
          font-family: var(--font-geist-sans, system-ui, sans-serif);
          font-size: 17px;
          font-weight: 700;
          letter-spacing: -0.015em;
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
          padding: 22px 24px 28px;
          -webkit-overflow-scrolling: touch;
        }
      `}</style>
    </div>
  );
}
