"use client";

import { useState } from "react";
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
  instagram: (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="3" width="18" height="18" rx="5"/><circle cx="12" cy="12" r="4"/><circle cx="17.5" cy="6.5" r="1"/></svg>
  ),
  youtube: (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><rect x="2" y="5" width="20" height="14" rx="3"/><path d="M10 9l5 3-5 3z" fill="currentColor"/></svg>
  ),
  whatsapp: (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><path d="M21 11.5a8.5 8.5 0 1 1-15.6 4.7L4 21l4.9-1.3A8.5 8.5 0 0 1 21 11.5z"/><path d="M9 9.5c.4 1.6 1.4 3 2.8 4.1 1.2 1 2.6 1.7 4 1.9.5 0 1-.3 1.2-.8l.2-.6c.1-.4-.1-.8-.5-1l-1.2-.5c-.3-.1-.6 0-.8.2l-.3.3c-.6-.2-1.2-.6-1.7-1.1-.5-.5-.9-1-1.1-1.7l.3-.3c.2-.2.3-.5.2-.8l-.5-1.2c-.1-.4-.5-.6-1-.5l-.6.2c-.5.2-.8.7-.7 1.2l-.3.6z" fill="currentColor"/></svg>
  ),
  website: (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3a14 14 0 0 1 0 18M12 3a14 14 0 0 0 0 18"/></svg>
  ),
  menu: (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><path d="M6 3h9l4 4v14H6z"/><path d="M15 3v4h4M9 11h6M9 15h6M9 19h4"/></svg>
  ),
  custom: (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><path d="M10 14l-1.5 1.5a3 3 0 1 1-4-4L7 9.5M14 10l1.5-1.5a3 3 0 1 1 4 4L16 14.5M9 14l6-6"/></svg>
  ),
};

const ICONS = {
  book: (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 9h18M8 3v4M16 3v4M8 14h4"/></svg>
  ),
  call: (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><path d="M22 16.9v3a2 2 0 0 1-2.2 2 19.8 19.8 0 0 1-8.6-3.1 19.5 19.5 0 0 1-6-6A19.8 19.8 0 0 1 2.1 4.2 2 2 0 0 1 4.1 2h3a2 2 0 0 1 2 1.7c.1.9.3 1.8.6 2.6a2 2 0 0 1-.5 2.1L8 9.6a16 16 0 0 0 6 6l1.2-1.2a2 2 0 0 1 2.1-.5c.8.3 1.7.5 2.6.6A2 2 0 0 1 22 16.9z"/></svg>
  ),
  directions: (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><path d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 1 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
  ),
} as const;

export default function LinkCards(props: Props) {
  const [bookOpen, setBookOpen] = useState(false);
  const {
    units, arenaName, phone, latitude, longitude, address, micrositeLinks,
  } = props;

  const canBook = units.length > 0;
  const mapHref = latitude && longitude
    ? `https://www.google.com/maps/dir/?api=1&destination=${latitude},${longitude}`
    : address
    ? `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(address)}`
    : null;

  const customLinks = (micrositeLinks ?? [])
    .filter((l) => l && l.enabled !== false && l.url)
    .sort((a, b) => (a.order ?? 0) - (b.order ?? 0));

  return (
    <>
      <div className="ms-links">
        {canBook && (
          <button
            type="button"
            className="ms-card ms-card-primary"
            onClick={() => setBookOpen(true)}
          >
            <span className="ms-card-icon">{ICONS.book}</span>
            <span className="ms-card-label">Book a slot</span>
            <span className="ms-card-arrow" aria-hidden="true">→</span>
          </button>
        )}

        {phone && (
          <a className="ms-card" href={`tel:${phone}`}>
            <span className="ms-card-icon">{ICONS.call}</span>
            <span className="ms-card-label">Call {arenaName}</span>
            <span className="ms-card-arrow" aria-hidden="true">→</span>
          </a>
        )}

        {mapHref && (
          <a className="ms-card" href={mapHref} target="_blank" rel="noopener noreferrer">
            <span className="ms-card-icon">{ICONS.directions}</span>
            <span className="ms-card-label">Get directions</span>
            <span className="ms-card-arrow" aria-hidden="true">→</span>
          </a>
        )}

        {customLinks.map((link, i) => (
          <a
            key={`${link.kind}-${i}`}
            className="ms-card"
            href={link.url}
            target={link.url.startsWith("http") ? "_blank" : undefined}
            rel={link.url.startsWith("http") ? "noopener noreferrer" : undefined}
          >
            <span className="ms-card-icon">{KIND_ICON[link.kind]}</span>
            <span className="ms-card-label">{link.label}</span>
            <span className="ms-card-arrow" aria-hidden="true">→</span>
          </a>
        ))}
      </div>

      {canBook && (
        <BookingSheet
          open={bookOpen}
          onClose={() => setBookOpen(false)}
          units={units}
          arenaId={props.arenaId}
          arenaSlug={props.arenaSlug}
          apiBaseUrl={props.apiBaseUrl}
          arenaName={arenaName}
          address={address}
          latitude={latitude}
          longitude={longitude}
          phone={phone}
          openTime={props.openTime}
          closeTime={props.closeTime}
        />
      )}
    </>
  );
}
