"use client";

import { useEffect, useRef, useState } from "react";
import BookingSheet from "./_booking-sheet";

type MicrositeLink = {
  kind: "instagram" | "youtube" | "whatsapp" | "website" | "menu" | "custom";
  label: string;
  url: string;
  order?: number;
  enabled?: boolean;
};

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
  micrositeLinks?: MicrositeLink[] | null;
};

const KIND_ICON: Record<MicrositeLink["kind"], React.ReactNode> = {
  instagram: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="3" width="18" height="18" rx="5"/><circle cx="12" cy="12" r="4"/><circle cx="17.5" cy="6.5" r="1"/></svg>,
  youtube: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><rect x="2" y="5" width="20" height="14" rx="3"/><path d="M10 9l5 3-5 3z" fill="currentColor"/></svg>,
  whatsapp: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="M21 11.5a8.5 8.5 0 1 1-15.6 4.7L4 21l4.9-1.3A8.5 8.5 0 0 1 21 11.5z"/></svg>,
  website: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3a14 14 0 0 1 0 18M12 3a14 14 0 0 0 0 18"/></svg>,
  menu: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="M6 3h9l4 4v14H6z"/><path d="M15 3v4h4M9 11h6M9 15h6M9 19h4"/></svg>,
  custom: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="M10 14l-1.5 1.5a3 3 0 1 1-4-4L7 9.5M14 10l1.5-1.5a3 3 0 1 1 4 4L16 14.5M9 14l6-6"/></svg>,
};

export default function LinkCards(props: Props) {
  const [bookOpen, setBookOpen] = useState(false);
  const [stuck, setStuck] = useState(false);
  const sentinelRef = useRef<HTMLDivElement | null>(null);

  const canBook = props.units.length > 0;

  // Sticky bottom Book bar appears after the hero scrolls past.
  useEffect(() => {
    if (typeof window === "undefined" || !sentinelRef.current) return;
    const io = new IntersectionObserver(
      ([entry]) => setStuck(!entry.isIntersecting && entry.boundingClientRect.top < 0),
      { rootMargin: "0px 0px -85% 0px" },
    );
    io.observe(sentinelRef.current);
    return () => io.disconnect();
  }, []);

  // Listen for primary BOOK click from anywhere in the page.
  useEffect(() => {
    const open = () => setBookOpen(true);
    window.addEventListener("ms:open-booking", open);
    return () => window.removeEventListener("ms:open-booking", open);
  }, []);

  const mapHref = props.latitude && props.longitude
    ? `https://www.google.com/maps/dir/?api=1&destination=${props.latitude},${props.longitude}`
    : props.address
    ? `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(props.address)}`
    : null;

  const customLinks = (props.micrositeLinks ?? [])
    .filter((l) => l && l.enabled !== false && l.url)
    .sort((a, b) => (a.order ?? 0) - (b.order ?? 0));

  return (
    <>
      <div ref={sentinelRef} className="ms-sentinel" aria-hidden="true" />

      {/* Quick actions strip — sits right under the hero */}
      <div className="ms-actions">
        {canBook && (
          <button
            type="button"
            className="ms-act ms-act-primary"
            onClick={() => setBookOpen(true)}
          >
            <span className="ms-act-label">Book a slot</span>
            <span className="ms-act-arrow" aria-hidden="true">→</span>
          </button>
        )}
        {props.phone && (
          <a className="ms-act" href={`tel:${props.phone}`}>
            <span className="ms-act-icon" aria-hidden="true">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><path d="M22 16.9v3a2 2 0 0 1-2.2 2 19.8 19.8 0 0 1-8.6-3.1 19.5 19.5 0 0 1-6-6A19.8 19.8 0 0 1 2.1 4.2 2 2 0 0 1 4.1 2h3a2 2 0 0 1 2 1.7c.1.9.3 1.8.6 2.6a2 2 0 0 1-.5 2.1L8 9.6a16 16 0 0 0 6 6l1.2-1.2a2 2 0 0 1 2.1-.5c.8.3 1.7.5 2.6.6A2 2 0 0 1 22 16.9z"/></svg>
            </span>
            <span className="ms-act-label">Call</span>
          </a>
        )}
        {mapHref && (
          <a className="ms-act" href={mapHref} target="_blank" rel="noopener noreferrer">
            <span className="ms-act-icon" aria-hidden="true">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><path d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 1 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
            </span>
            <span className="ms-act-label">Directions</span>
          </a>
        )}
      </div>

      {/* Owner-curated links — only render if any */}
      {customLinks.length > 0 && (
        <ul className="ms-elsewhere">
          {customLinks.map((link, i) => (
            <li key={`${link.kind}-${i}`}>
              <a
                className="ms-else-row"
                href={link.url}
                target={link.url.startsWith("http") ? "_blank" : undefined}
                rel={link.url.startsWith("http") ? "noopener noreferrer" : undefined}
              >
                <span className="ms-else-icon" aria-hidden="true">{KIND_ICON[link.kind]}</span>
                <span className="ms-else-label">{link.label}</span>
                <span className="ms-else-arrow" aria-hidden="true">→</span>
              </a>
            </li>
          ))}
        </ul>
      )}

      {/* Sticky mobile book bar */}
      {canBook && stuck && (
        <div className="ms-stickybar">
          <button type="button" className="ms-stickybar-btn" onClick={() => setBookOpen(true)}>
            <span>Book a slot</span>
            <span className="ms-stickybar-meta">Live availability →</span>
          </button>
        </div>
      )}

      {canBook && (
        <BookingSheet
          open={bookOpen}
          onClose={() => setBookOpen(false)}
          units={props.units}
          arenaId={props.arenaId}
          arenaSlug={props.arenaSlug}
          apiBaseUrl={props.apiBaseUrl}
          arenaName={props.arenaName}
          address={props.address}
          latitude={props.latitude}
          longitude={props.longitude}
          phone={props.phone}
          openTime={props.openTime}
          closeTime={props.closeTime}
        />
      )}
    </>
  );
}
