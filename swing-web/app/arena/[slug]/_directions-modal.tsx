"use client";

import { useState, useEffect } from "react";
import { createPortal } from "react-dom";

type Props = {
  name: string;
  address: string;
  latitude: number;
  longitude: number;
};

export default function DirectionsModal({ name, address, latitude, longitude }: Props) {
  const [open, setOpen] = useState(false);
  const [mounted, setMounted] = useState(false);
  const mapsUrl = `https://www.google.com/maps/dir/?api=1&destination=${latitude},${longitude}`;

  useEffect(() => { setMounted(true); }, []);

  const modal = open && (
    <div className="dir-backdrop" onClick={() => setOpen(false)}>
      <div className="dir-modal" onClick={(e) => e.stopPropagation()}>
        <div className="dir-header">
          <div>
            <p className="dir-eyebrow">Location</p>
            <h3 className="dir-name">{name}</h3>
          </div>
          <button className="dir-close" onClick={() => setOpen(false)} aria-label="Close">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round">
              <path d="M18 6L6 18M6 6l12 12"/>
            </svg>
          </button>
        </div>

        <div className="dir-address">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z"/>
            <circle cx="12" cy="9" r="2.5"/>
          </svg>
          <span>{address}</span>
        </div>

        <div className="dir-coords">
          <div>
            <small>Latitude</small>
            <strong>{latitude.toFixed(6)}</strong>
          </div>
          <div>
            <small>Longitude</small>
            <strong>{longitude.toFixed(6)}</strong>
          </div>
        </div>

        <a href={mapsUrl} target="_blank" rel="noopener noreferrer" className="dir-btn">
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
            <polygon points="3 11 22 2 13 21 11 13 3 11"/>
          </svg>
          Open in Google Maps
        </a>
      </div>
    </div>
  );

  return (
    <>
      <button className="arena-city-pill" onClick={() => setOpen(true)} aria-label="Get directions">
        <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
          <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z"/>
          <circle cx="12" cy="9" r="2.5"/>
        </svg>
        Directions
      </button>

      {mounted && createPortal(modal, document.body)}

      <style>{`
        .arena-city-pill {
          cursor: pointer;
          display: inline-flex; align-items: center; gap: 6px;
          min-height: 34px; border-radius: 999px;
          backdrop-filter: blur(18px);
          border: 1px solid rgba(255,255,255,0.16);
          font-size: 11px; font-weight: 900;
          letter-spacing: 0.12em; text-transform: uppercase;
          padding: 0 13px;
          color: rgba(255,255,255,0.86);
          background: rgba(255,255,255,0.09);
          transition: background .15s;
        }
        .arena-city-pill:hover { background: rgba(255,255,255,0.16); }

        .dir-backdrop {
          position: fixed; inset: 0; z-index: 9999;
          background: rgba(0,0,0,0.55);
          backdrop-filter: blur(6px);
          -webkit-backdrop-filter: blur(6px);
          display: flex; align-items: center; justify-content: center;
          padding: 20px;
          animation: dirFadeIn .18s ease;
        }
        .dir-modal {
          width: 100%; max-width: 400px;
          background: var(--arena-booking-bg, #fff);
          border-radius: 28px;
          padding: 24px;
          display: flex; flex-direction: column; gap: 18px;
          box-shadow: 0 32px 80px rgba(0,0,0,0.28);
          animation: dirSlideUp .22s cubic-bezier(.34,1.56,.64,1);
        }
        .dir-header {
          display: flex; align-items: flex-start; justify-content: space-between; gap: 12px;
        }
        .dir-eyebrow {
          margin: 0 0 5px;
          font-size: 10px; font-weight: 900; letter-spacing: 0.16em;
          text-transform: uppercase; color: var(--arena-muted, rgba(10,11,10,0.55));
        }
        .dir-name {
          margin: 0;
          font-family: var(--font-display, ui-sans-serif);
          font-size: 22px; font-weight: 700;
          letter-spacing: -0.04em; line-height: 1.1;
          color: var(--arena-ink, #0A0B0A);
        }
        .dir-close {
          flex-shrink: 0; width: 34px; height: 34px;
          border-radius: 50%; border: 1px solid var(--arena-line, rgba(10,11,10,0.10));
          background: transparent; cursor: pointer;
          display: flex; align-items: center; justify-content: center;
          color: var(--arena-ink, #0A0B0A);
          transition: background .15s;
        }
        .dir-close:hover { background: var(--arena-price-bg, rgba(10,11,10,0.05)); }
        .dir-address {
          display: flex; align-items: flex-start; gap: 9px;
          padding: 14px; border-radius: 16px;
          background: var(--arena-price-bg, rgba(10,11,10,0.045));
          border: 1px solid var(--arena-price-border, rgba(10,11,10,0.06));
          color: var(--arena-ink, #0A0B0A);
          font-size: 13px; line-height: 1.5; font-weight: 500;
        }
        .dir-address svg { flex-shrink: 0; margin-top: 2px; opacity: 0.55; }
        .dir-coords {
          display: grid; grid-template-columns: 1fr 1fr; gap: 10px;
        }
        .dir-coords > div {
          padding: 12px 14px; border-radius: 14px;
          background: var(--arena-price-bg, rgba(10,11,10,0.045));
          border: 1px solid var(--arena-price-border, rgba(10,11,10,0.06));
        }
        .dir-coords small {
          display: block; font-size: 9px; font-weight: 900;
          letter-spacing: 0.12em; text-transform: uppercase;
          color: var(--arena-muted, rgba(10,11,10,0.55));
          margin-bottom: 4px;
        }
        .dir-coords strong {
          display: block; font-size: 13px; font-weight: 600;
          font-family: var(--font-mono, monospace);
          color: var(--arena-ink, #0A0B0A);
          letter-spacing: -0.01em;
        }
        .dir-btn {
          display: flex; align-items: center; justify-content: center; gap: 8px;
          padding: 14px 20px; border-radius: 999px;
          background: #0A0B0A;
          color: #C8FF3E;
          font-size: 13px; font-weight: 700;
          text-decoration: none; letter-spacing: -0.01em;
          transition: opacity .15s;
        }
        .dir-btn:hover { opacity: 0.85; }
        @keyframes dirFadeIn { from { opacity: 0 } to { opacity: 1 } }
        @keyframes dirSlideUp { from { opacity: 0; transform: translateY(16px) scale(0.97) } to { opacity: 1; transform: none } }
      `}</style>
    </>
  );
}
