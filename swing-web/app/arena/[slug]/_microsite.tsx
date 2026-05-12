"use client";

import { useEffect, useMemo, useState } from "react";
import BookingSheet from "./_booking-sheet";
import ThemeToggle from "./_theme-toggle";

/* ─── Types (mirrored from page.tsx so client compiles standalone) ───── */
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
  openTime?: string | null;
  closeTime?: string | null;
  netVariants?: NetVariant[] | null;
  monthlyPassEnabled?: boolean;
  monthlyPassRatePaise?: number | null;
  minBulkDays?: number | null;
  bulkDayRatePaise?: number | null;
  addons?: ArenaAddon[] | null;
  minAdvancePaise?: number | null;
  cancellationHours?: number | null;
};
type MicrositeLink = {
  kind: "instagram" | "youtube" | "whatsapp" | "website" | "menu" | "custom";
  label: string;
  url: string;
  order?: number;
  enabled?: boolean;
};

export type ArenaForMicrosite = {
  id: string;
  name: string;
  description?: string | null;
  address?: string | null;
  city?: string | null;
  state?: string | null;
  openTime?: string | null;
  closeTime?: string | null;
  phone?: string | null;
  photoUrls?: string[];
  sports?: string[];
  units?: ArenaUnit[];
  customSlug?: string | null;
  arenaSlug?: string | null;
  latitude?: number | null;
  longitude?: number | null;
  rating?: number | null;
  totalRatings?: number | null;
  createdAt?: string | null;
  brandColor?: string | null;
  logoUrl?: string | null;
  tagline?: string | null;
  coverPhotoIndex?: number | null;
  micrositeLinks?: MicrositeLink[] | null;
};

type Props = {
  arena: ArenaForMicrosite;
  slug: string;
  apiBaseUrl: string;
};

/* ─── 8 brand palettes (matches the design reference) ────────────────── */
type Palette = { hex: string; bg: string; stripe: string };
const PALETTES: Record<string, Palette> = {
  forest:   { hex: "#2BA84A", bg: "linear-gradient(135deg, #0e2a16 0%, #050b07 100%)", stripe: "rgba(255,255,255,0.045)" },
  electric: { hex: "#C8FF3E", bg: "linear-gradient(135deg, #1d2305 0%, #060702 100%)", stripe: "rgba(255,255,255,0.050)" },
  royal:    { hex: "#3E63FF", bg: "linear-gradient(135deg, #0d1632 0%, #02040c 100%)", stripe: "rgba(255,255,255,0.045)" },
  crimson:  { hex: "#E11D48", bg: "linear-gradient(135deg, #2d0a12 0%, #0a0204 100%)", stripe: "rgba(255,255,255,0.050)" },
  amber:    { hex: "#F59E0B", bg: "linear-gradient(135deg, #2a1b03 0%, #090501 100%)", stripe: "rgba(255,255,255,0.050)" },
  violet:   { hex: "#7C3AED", bg: "linear-gradient(135deg, #170a35 0%, #050210 100%)", stripe: "rgba(255,255,255,0.045)" },
  teal:     { hex: "#14B8A6", bg: "linear-gradient(135deg, #0a2b27 0%, #020a09 100%)", stripe: "rgba(255,255,255,0.045)" },
  charcoal: { hex: "#1A1A1A", bg: "linear-gradient(135deg, #1a1a1a 0%, #050505 100%)", stripe: "rgba(255,255,255,0.050)" },
};
function resolvePalette(brand?: string | null): Palette {
  if (!brand) return PALETTES.forest;
  const hex = brand.toUpperCase();
  for (const k of Object.keys(PALETTES)) {
    if (PALETTES[k].hex.toUpperCase() === hex) return PALETTES[k];
  }
  // Unknown hex — synthesise a dark gradient using color-mix at runtime.
  return {
    hex: brand,
    bg: `linear-gradient(135deg, color-mix(in srgb, ${brand} 18%, #050505) 0%, #050505 100%)`,
    stripe: "rgba(255,255,255,0.045)",
  };
}

/* ─── Utilities ───────────────────────────────────────────────────────── */
function readableInk(hex: string) {
  const m = /^#([0-9a-f]{6})$/i.exec(hex);
  if (!m) return "#FFFFFF";
  const n = parseInt(m[1], 16);
  const r = (n >> 16) & 255, g = (n >> 8) & 255, b = n & 255;
  return (r * 299 + g * 587 + b * 114) / 1000 > 160 ? "#0A0B0A" : "#FFFFFF";
}
function fmt12Short(time?: string | null) {
  if (!time) return null;
  const [hourRaw, minuteRaw = "00"] = time.split(":");
  const hour = Number(hourRaw);
  if (Number.isNaN(hour)) return time;
  const suffix = hour >= 12 ? "PM" : "AM";
  const displayHour = hour % 12 || 12;
  const min = minuteRaw === "00" ? "" : `:${minuteRaw.padStart(2, "0")}`;
  return `${displayHour}${min}${suffix}`;
}
function fmt12Long(time?: string | null) {
  if (!time) return null;
  const [hourRaw, minuteRaw = "00"] = time.split(":");
  const hour = Number(hourRaw);
  if (Number.isNaN(hour)) return time;
  const suffix = hour >= 12 ? "PM" : "AM";
  const displayHour = hour % 12 || 12;
  const min = minuteRaw === "00" ? "" : `:${minuteRaw.padStart(2, "0")}`;
  return `${displayHour}${min} ${suffix}`;
}
function toMins(t: string) { const [h, m] = t.split(":").map(Number); return h * 60 + (m || 0); }
function initialsFrom(name: string) {
  const words = name.trim().split(/\s+/).slice(0, 2);
  return words.map((w) => w[0] || "").join("").toUpperCase() || "•";
}
function rupees(paise: number) {
  // Format in Indian style — ₹600, ₹1,200, ₹12,500
  const r = Math.round(paise / 100);
  return "₹" + r.toLocaleString("en-IN");
}

/* ─── Icons ────────────────────────────────────────────────────────────── */
const Icon = {
  phone: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><path d="M22 16.9v3a2 2 0 0 1-2.2 2 19.8 19.8 0 0 1-8.6-3.1 19.5 19.5 0 0 1-6-6A19.8 19.8 0 0 1 2.1 4.2 2 2 0 0 1 4.1 2h3a2 2 0 0 1 2 1.7c.1.9.3 1.8.6 2.6a2 2 0 0 1-.5 2.1L8 9.6a16 16 0 0 0 6 6l1.2-1.2a2 2 0 0 1 2.1-.5c.8.3 1.7.5 2.6.6A2 2 0 0 1 22 16.9z"/></svg>,
  pin: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><path d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 1 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>,
  navigation: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><polygon points="3 11 22 2 13 21 11 13 3 11"/></svg>,
  clock: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg>,
  arrow: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M5 12h14M13 6l6 6-6 6"/></svg>,
  share: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/><path d="M8.6 13.5l6.8 4M15.4 6.5l-6.8 4"/></svg>,
  copy: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>,
  star: <svg viewBox="0 0 24 24" fill="currentColor"><path d="M12 17.3l-6.18 3.7 1.64-7.03L2 9.24l7.19-.62L12 2l2.81 6.62L22 9.24l-5.46 4.73 1.64 7.03z"/></svg>,
  globe: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3a14 14 0 0 1 0 18M12 3a14 14 0 0 0 0 18"/></svg>,
  instagram: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="3" width="18" height="18" rx="5"/><circle cx="12" cy="12" r="4"/><circle cx="17.5" cy="6.5" r="1"/></svg>,
  youtube: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><rect x="2" y="5" width="20" height="14" rx="3"/><path d="M10 9l5 3-5 3z" fill="currentColor"/></svg>,
  whatsapp: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="M21 11.5a8.5 8.5 0 1 1-15.6 4.7L4 21l4.9-1.3A8.5 8.5 0 0 1 21 11.5z"/></svg>,
  menu: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="M6 3h9l4 4v14H6z"/><path d="M15 3v4h4M9 11h6M9 15h6M9 19h4"/></svg>,
  custom: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="M10 14l-1.5 1.5a3 3 0 1 1-4-4L7 9.5M14 10l1.5-1.5a3 3 0 1 1 4 4L16 14.5M9 14l6-6"/></svg>,
  close: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round"><path d="M6 6l12 12M18 6l-12 12"/></svg>,
  photos: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="3" width="18" height="14" rx="2"/><path d="M3 14l5-5 5 5 3-3 5 5"/><circle cx="9" cy="8" r="1.4" fill="currentColor"/></svg>,
};
const KIND_ICON: Record<MicrositeLink["kind"], React.ReactNode> = {
  instagram: Icon.instagram,
  youtube:   Icon.youtube,
  whatsapp:  Icon.whatsapp,
  website:   Icon.globe,
  menu:      Icon.menu,
  custom:    Icon.custom,
};

/* ─── Component ───────────────────────────────────────────────────────── */
export default function Microsite({ arena, slug, apiBaseUrl }: Props) {
  const [bookOpen, setBookOpen] = useState(false);
  const [shareOpen, setShareOpen] = useState(false);
  const [photosOpen, setPhotosOpen] = useState(false);
  const [copied, setCopied] = useState(false);

  // Lock body scroll while any sheet is open
  useEffect(() => {
    const open = bookOpen || shareOpen || photosOpen;
    const prev = document.body.style.overflow;
    if (open) document.body.style.overflow = "hidden";
    return () => { document.body.style.overflow = prev; };
  }, [bookOpen, shareOpen, photosOpen]);

  /* ─ Derived data ──────────────────────────────────────────────────── */
  const palette = resolvePalette(arena.brandColor);
  const brand = palette.hex;
  const brandInk = readableInk(brand);

  const units = arena.units ?? [];
  const photos = (arena.photoUrls ?? []).filter(Boolean);
  const sports = (arena.sports ?? []).filter(Boolean);
  const sportLabel = sports.length
    ? sports[0].charAt(0).toUpperCase() + sports[0].slice(1).toLowerCase()
    : null;
  const fullAddress = [arena.address, arena.city, arena.state].filter(Boolean).join(", ");
  const locationLine = [arena.city, arena.state].filter(Boolean).join(", ");

  // Operating hours derived from units (earliest open, latest close).
  const unitOpenTimes  = units.map((u) => u.openTime).filter(Boolean) as string[];
  const unitCloseTimes = units.map((u) => u.closeTime).filter(Boolean) as string[];
  const arenaOpen  = unitOpenTimes.length  ? unitOpenTimes.reduce ((a, b) => toMins(a) <= toMins(b) ? a : b) : arena.openTime  ?? null;
  const arenaClose = unitCloseTimes.length ? unitCloseTimes.reduce((a, b) => toMins(a) >= toMins(b) ? a : b) : arena.closeTime ?? null;
  const hoursLine = arenaOpen && arenaClose ? `${fmt12Short(arenaOpen)} – ${fmt12Short(arenaClose)}` : null;

  // "Open now" — best-effort, uses viewer's local time. Server-renders as null;
  // client effect populates after mount to avoid hydration mismatch.
  const [openNow, setOpenNow] = useState<boolean | null>(null);
  useEffect(() => {
    if (!arenaOpen || !arenaClose) { setOpenNow(false); return; }
    const d = new Date();
    const m = d.getHours() * 60 + d.getMinutes();
    setOpenNow(m >= toMins(arenaOpen) && m <= toMins(arenaClose));
  }, [arenaOpen, arenaClose]);

  const statusText = openNow == null
    ? (hoursLine ?? "Hours unlisted")
    : openNow
      ? "OPEN NOW"
      : arenaOpen ? `OPENS ${fmt12Short(arenaOpen)?.toUpperCase()}` : "CLOSED";

  // "From ₹X/hr" — minimum hourly rate across units.
  const minHourly = units.reduce<number | null>((acc, u) => {
    const p = u.pricePerHourPaise;
    if (typeof p !== "number" || p <= 0) return acc;
    return acc == null || p < acc ? p : acc;
  }, null);

  const rating = arena.rating && arena.rating > 0 ? Math.round(arena.rating * 10) / 10 : null;
  const ratingCount = arena.totalRatings ?? null;

  // Years established — best-effort from createdAt.
  const estYear = arena.createdAt ? new Date(arena.createdAt).getFullYear() : null;
  const yearsOld = estYear ? Math.max(0, new Date().getFullYear() - estYear) : null;

  // Hours per day (rough — for the desktop stats strip).
  const hoursPerDay = arenaOpen && arenaClose ? Math.max(0, Math.round((toMins(arenaClose) - toMins(arenaOpen)) / 60)) : null;

  const canonicalSlug = arena.customSlug ?? arena.arenaSlug ?? slug;
  const publicUrl = typeof window !== "undefined" ? window.location.href : `https://www.swingcricketapp.com/arena/${canonicalSlug}`;

  const mapHref = arena.latitude && arena.longitude
    ? `https://www.google.com/maps/dir/?api=1&destination=${arena.latitude},${arena.longitude}`
    : fullAddress ? `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(fullAddress)}` : null;

  /* ─ Action chips: dynamic, prioritised ────────────────────────────── */
  type Chip = { key: string; label: string; icon: React.ReactNode; href?: string; onClick?: () => void };
  const customLinks = (arena.micrositeLinks ?? [])
    .filter((l) => l && l.enabled !== false && l.url)
    .sort((a, b) => (a.order ?? 0) - (b.order ?? 0));
  const chips: Chip[] = [];
  if (arena.phone)   chips.push({ key: "call", label: "Call", icon: Icon.phone, href: `tel:${arena.phone}` });
  if (mapHref)       chips.push({ key: "dir",  label: "Directions", icon: Icon.navigation, href: mapHref });
  for (const l of customLinks) {
    chips.push({ key: `${l.kind}-${chips.length}`, label: l.label, icon: KIND_ICON[l.kind], href: l.url });
  }
  if (photos.length) chips.push({ key: "photos", label: "Photos", icon: Icon.photos, onClick: () => setPhotosOpen(true) });

  /* ─ Web Share API + copy ─────────────────────────────────────────── */
  async function shareUrl() {
    try {
      if (navigator.share) {
        await navigator.share({ title: arena.name, text: arena.tagline || `Book ${arena.name} on Swing`, url: publicUrl });
        return;
      }
    } catch { /* user cancelled */ }
    setShareOpen(true);
  }
  async function copyUrl() {
    try {
      await navigator.clipboard.writeText(publicUrl);
      setCopied(true);
      setTimeout(() => setCopied(false), 1500);
    } catch { /* clipboard denied */ }
  }

  const canBook = units.length > 0;

  /* ─ Render ────────────────────────────────────────────────────────── */
  const heroStyle = useMemo(() => ({
    ["--ms-brand" as string]: brand,
    ["--ms-brand-ink" as string]: brandInk,
    ["--hero-bg" as string]: palette.bg,
    ["--hero-stripe" as string]: palette.stripe,
  } as React.CSSProperties), [brand, brandInk, palette]);

  return (
    <main className="ms" style={heroStyle}>
      {/* ─── TOP BAR ────────────────────────────────────────────────── */}
      <header className="ms-top">
        <div className="ms-top-left">
          <span className="ms-avatar" aria-hidden="true">
            {arena.logoUrl
              // eslint-disable-next-line @next/next/no-img-element
              ? <img src={arena.logoUrl} alt="" />
              : <span>{initialsFrom(arena.name)}</span>}
          </span>
          <span className="ms-top-name">{arena.name}</span>
        </div>
        <div className="ms-top-right">
          <ThemeToggle />
          <button type="button" className="ms-icon-btn" onClick={shareUrl} aria-label="Share this page" title="Share">
            {Icon.share}
          </button>
          {canBook && (
            <button type="button" className="ms-book-pill" onClick={() => setBookOpen(true)}>
              <span>Book</span>
              <span className="ms-book-pill-arrow" aria-hidden="true">{Icon.arrow}</span>
            </button>
          )}
        </div>
      </header>

      {/* ─── HERO + CHIPS + BOTTOM BAR ──────────────────────────────── */}
      <section className="ms-stage">
        {/* HERO card */}
        <article className="ms-hero">
          <div className="ms-hero-bg" aria-hidden="true" />
          <div className="ms-hero-stripes" aria-hidden="true" />

          <div className="ms-hero-top">
            <span className="ms-status-chip">
              <span className={`ms-status-dot ${openNow ? "is-on" : ""}`} aria-hidden="true" />
              <span className="ms-status-text">{statusText}</span>
            </span>
          </div>

          <div className="ms-hero-body">
            {sportLabel && (
              <span className="ms-sport-chip">
                <span className="ms-sport-dot" aria-hidden="true" />
                <span>{sportLabel.toUpperCase()}</span>
              </span>
            )}
            <h1 className="ms-hero-name">{arena.name}</h1>
            {arena.tagline && <p className="ms-hero-tag">{arena.tagline}</p>}

            <ul className="ms-hero-meta">
              {locationLine && (
                <li>
                  <span className="ms-meta-icon" aria-hidden="true">{Icon.pin}</span>
                  <span>{locationLine}</span>
                </li>
              )}
              {hoursLine && (
                <li>
                  <span className="ms-meta-icon" aria-hidden="true">{Icon.clock}</span>
                  <span>{hoursLine}</span>
                </li>
              )}
              {rating != null && (
                <li>
                  <span className="ms-meta-icon ms-meta-icon-star" aria-hidden="true">{Icon.star}</span>
                  <span>{rating.toFixed(1)}{ratingCount ? ` · ${ratingCount} ${ratingCount === 1 ? "review" : "reviews"}` : ""}</span>
                </li>
              )}
            </ul>

            <div className="ms-hero-ctas">
              {canBook && (
                <button type="button" className="ms-cta ms-cta-primary" onClick={() => setBookOpen(true)}>
                  <span>Book a slot</span>
                  <span className="ms-cta-arrow" aria-hidden="true">{Icon.arrow}</span>
                </button>
              )}
              {arena.phone && (
                <a className="ms-cta ms-cta-ghost" href={`tel:${arena.phone}`}>
                  <span className="ms-cta-icon" aria-hidden="true">{Icon.phone}</span>
                  <span>Call</span>
                </a>
              )}
            </div>
          </div>
        </article>

        {/* CHIPS row — secondary actions */}
        {chips.length > 0 && (
          <nav className="ms-chips" aria-label="More from this arena">
            {chips.slice(0, 6).map((c) => (
              c.href ? (
                <a
                  key={c.key}
                  className="ms-chip"
                  href={c.href}
                  target={c.href.startsWith("http") ? "_blank" : undefined}
                  rel={c.href.startsWith("http") ? "noopener noreferrer" : undefined}
                >
                  <span className="ms-chip-icon" aria-hidden="true">{c.icon}</span>
                  <span className="ms-chip-label">{c.label}</span>
                </a>
              ) : (
                <button key={c.key} type="button" className="ms-chip" onClick={c.onClick}>
                  <span className="ms-chip-icon" aria-hidden="true">{c.icon}</span>
                  <span className="ms-chip-label">{c.label}</span>
                </button>
              )
            ))}
          </nav>
        )}

        {/* DESKTOP stats strip (hidden on mobile) */}
        <div className="ms-stats">
          {rating != null && (
            <div className="ms-stat">
              <div className="ms-stat-val">{rating.toFixed(1)}</div>
              <div className="ms-stat-lbl">Rating</div>
            </div>
          )}
          {units.length > 0 && (
            <div className="ms-stat">
              <div className="ms-stat-val">{units.length}</div>
              <div className="ms-stat-lbl">{units.length === 1 ? "Court" : "Courts"}</div>
            </div>
          )}
          {hoursPerDay && (
            <div className="ms-stat">
              <div className="ms-stat-val">{hoursPerDay}h</div>
              <div className="ms-stat-lbl">Open daily</div>
            </div>
          )}
          {estYear && yearsOld != null && yearsOld > 0 && (
            <div className="ms-stat">
              <div className="ms-stat-val">{yearsOld}yr</div>
              <div className="ms-stat-lbl">Est. {estYear}</div>
            </div>
          )}
          {minHourly != null && (
            <div className="ms-stat">
              <div className="ms-stat-val">{rupees(minHourly)}</div>
              <div className="ms-stat-lbl">From /hr</div>
            </div>
          )}
        </div>
      </section>

      {/* ─── STICKY BOTTOM BAR (mobile only) ────────────────────────── */}
      {canBook && (
        <div className="ms-bottombar">
          <div className="ms-bottombar-left">
            <span className="ms-bottombar-price">{minHourly != null ? `From ${rupees(minHourly)}/hr` : "Book your slot"}</span>
            <span className="ms-bottombar-sub">LIVE AVAILABILITY</span>
          </div>
          <button type="button" className="ms-bottombar-btn" onClick={() => setBookOpen(true)}>
            <span>Book a slot</span>
            <span aria-hidden="true">{Icon.arrow}</span>
          </button>
        </div>
      )}

      {/* ─── SHARE SHEET (fallback when navigator.share unavailable) ── */}
      {shareOpen && (
        <div className="ms-sheet" role="dialog" aria-modal="true" aria-label="Share">
          <button className="ms-sheet-scrim" aria-label="Close" onClick={() => setShareOpen(false)} />
          <div className="ms-sheet-panel ms-sheet-small">
            <header className="ms-sheet-head">
              <div className="ms-sheet-title">
                <span className="ms-sheet-eyebrow">SHARE</span>
                <span className="ms-sheet-venue">{arena.name}</span>
              </div>
              <button className="ms-icon-btn" onClick={() => setShareOpen(false)} aria-label="Close">{Icon.close}</button>
            </header>
            <div className="ms-sheet-body ms-sheet-share">
              <button type="button" className="ms-share-row" onClick={copyUrl}>
                <span className="ms-share-icon" aria-hidden="true">{Icon.copy}</span>
                <span className="ms-share-label">{copied ? "Copied!" : "Copy link"}</span>
                <span className="ms-share-url">{publicUrl.replace(/^https?:\/\//, "")}</span>
              </button>
              <a className="ms-share-row" href={`https://wa.me/?text=${encodeURIComponent(arena.name + " — " + publicUrl)}`} target="_blank" rel="noopener noreferrer">
                <span className="ms-share-icon" aria-hidden="true">{Icon.whatsapp}</span>
                <span className="ms-share-label">Share on WhatsApp</span>
              </a>
              <a className="ms-share-row" href={`https://twitter.com/intent/tweet?url=${encodeURIComponent(publicUrl)}&text=${encodeURIComponent(arena.name)}`} target="_blank" rel="noopener noreferrer">
                <span className="ms-share-icon" aria-hidden="true">{Icon.share}</span>
                <span className="ms-share-label">Share on X</span>
              </a>
            </div>
          </div>
        </div>
      )}

      {/* ─── PHOTOS SHEET ───────────────────────────────────────────── */}
      {photosOpen && photos.length > 0 && (
        <div className="ms-sheet ms-sheet-photos" role="dialog" aria-modal="true" aria-label="Photos">
          <button className="ms-sheet-scrim" aria-label="Close" onClick={() => setPhotosOpen(false)} />
          <div className="ms-sheet-panel">
            <header className="ms-sheet-head">
              <div className="ms-sheet-title">
                <span className="ms-sheet-eyebrow">PHOTOS</span>
                <span className="ms-sheet-venue">{arena.name}</span>
              </div>
              <button className="ms-icon-btn" onClick={() => setPhotosOpen(false)} aria-label="Close">{Icon.close}</button>
            </header>
            <div className="ms-sheet-body ms-photos-body">
              <div className="ms-photos-grid">
                {photos.map((src, i) => (
                  // eslint-disable-next-line @next/next/no-img-element
                  <a key={src + i} className="ms-photo" href={src} target="_blank" rel="noopener noreferrer">
                    <img src={src} alt={`${arena.name} photo ${i + 1}`} />
                  </a>
                ))}
              </div>
            </div>
          </div>
        </div>
      )}

      {/* ─── BOOKING SHEET ──────────────────────────────────────────── */}
      {canBook && (
        <BookingSheet
          open={bookOpen}
          onClose={() => setBookOpen(false)}
          units={units}
          arenaId={arena.id}
          arenaSlug={slug}
          apiBaseUrl={apiBaseUrl}
          arenaName={arena.name}
          address={fullAddress || locationLine || undefined}
          latitude={arena.latitude}
          longitude={arena.longitude}
          phone={arena.phone}
          openTime={arenaOpen}
          closeTime={arenaClose}
        />
      )}

      {/* ─── STYLES ─────────────────────────────────────────────────── */}
      <style>{`
        /* ─── TOKENS ────────────────────────────────────────────── */
        :root {
          --ms-bg:           #FAFAF7;
          --ms-surface:      #FFFFFF;
          --ms-ink:          #0A0B0A;
          --ms-muted:        rgba(10, 11, 10, 0.58);
          --ms-soft:         rgba(10, 11, 10, 0.32);
          --ms-line:         rgba(10, 11, 10, 0.10);
          --ms-line-strong:  rgba(10, 11, 10, 0.20);
          --ms-muted-inv:    rgba(244, 244, 241, 0.62);
          --ms-line-inv:     rgba(244, 244, 241, 0.30);
        }
        [data-theme="dark"] {
          --ms-bg:           #0A0B0A;
          --ms-surface:      #141414;
          --ms-ink:          #F4F4F1;
          --ms-muted:        rgba(244, 244, 241, 0.58);
          --ms-soft:         rgba(244, 244, 241, 0.32);
          --ms-line:         rgba(244, 244, 241, 0.10);
          --ms-line-strong:  rgba(244, 244, 241, 0.22);
          --ms-muted-inv:    rgba(10, 11, 10, 0.62);
          --ms-line-inv:     rgba(10, 11, 10, 0.30);
        }
        html, body { background: var(--ms-bg); color: var(--ms-ink); }
        html { color-scheme: light; }
        [data-theme="dark"] { color-scheme: dark; }

        /* ─── SHELL — no-scroll, single viewport ────────────────── */
        .ms {
          height: 100svh;
          background: var(--ms-bg);
          color: var(--ms-ink);
          font-family: var(--font-geist-sans, "Inter Tight", system-ui, sans-serif);
          display: flex;
          flex-direction: column;
          overflow: hidden;
          -webkit-font-smoothing: antialiased;
        }

        /* ─── TOP BAR ───────────────────────────────────────────── */
        .ms-top {
          flex: 0 0 auto;
          display: flex;
          align-items: center;
          justify-content: space-between;
          gap: 12px;
          padding: 14px 16px;
          border-bottom: 1px solid var(--ms-line);
          background: var(--ms-bg);
        }
        @media (min-width: 720px) { .ms-top { padding: 18px 32px; } }
        .ms-top-left { display: flex; align-items: center; gap: 12px; min-width: 0; }
        .ms-top-right { display: flex; align-items: center; gap: 8px; flex: 0 0 auto; }

        .ms-avatar {
          width: 30px; height: 30px;
          display: inline-grid; place-items: center;
          background: var(--ms-brand);
          color: var(--ms-brand-ink);
          border-radius: 7px;
          font-family: var(--font-geist-sans);
          font-weight: 700;
          font-size: 11px;
          letter-spacing: 0.03em;
          overflow: hidden;
          flex: 0 0 auto;
        }
        .ms-avatar img { width: 100%; height: 100%; object-fit: cover; }
        @media (min-width: 720px) {
          .ms-avatar { width: 34px; height: 34px; font-size: 12px; }
        }
        .ms-top-name {
          font-size: 14px;
          font-weight: 600;
          letter-spacing: -0.005em;
          color: var(--ms-ink);
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
          min-width: 0;
        }
        @media (min-width: 720px) { .ms-top-name { font-size: 16px; } }

        .ms-icon-btn {
          all: unset;
          cursor: pointer;
          width: 36px; height: 36px;
          display: inline-grid; place-items: center;
          color: var(--ms-ink);
          border: 1px solid var(--ms-line-strong);
          border-radius: 999px;
          background: var(--ms-bg);
          transition: background 0.12s ease;
        }
        .ms-icon-btn:hover { background: var(--ms-line); }
        .ms-icon-btn svg { width: 15px; height: 15px; }

        /* Theme toggle inherits .ms-icon-btn-ish — restyle the existing
           class to match circular pill design. */
        .ms-theme {
          width: 36px !important;
          height: 36px !important;
          border-radius: 999px !important;
          border: 1px solid var(--ms-line-strong) !important;
        }
        .ms-theme:hover { background: var(--ms-line) !important; }

        .ms-book-pill {
          all: unset;
          cursor: pointer;
          display: inline-flex;
          align-items: center;
          gap: 6px;
          padding: 9px 16px 9px 18px;
          background: var(--ms-brand);
          color: var(--ms-brand-ink);
          border-radius: 999px;
          font-weight: 700;
          font-size: 14px;
          letter-spacing: -0.005em;
          transition: filter 0.12s ease, transform 0.12s ease;
        }
        .ms-book-pill:hover { filter: brightness(0.94); }
        .ms-book-pill-arrow svg { width: 14px; height: 14px; }

        /* ─── STAGE (fills remaining height) ─────────────────────── */
        .ms-stage {
          flex: 1 1 auto;
          min-height: 0;
          padding: 14px 14px 100px;
          display: flex;
          flex-direction: column;
          gap: 14px;
        }
        @media (min-width: 720px) {
          .ms-stage { padding: 22px 32px 32px; gap: 18px; }
        }

        /* ─── HERO CARD ──────────────────────────────────────────── */
        .ms-hero {
          position: relative;
          flex: 1 1 auto;
          min-height: 0;
          overflow: hidden;
          border-radius: 22px;
          padding: 20px 22px 22px;
          display: flex;
          flex-direction: column;
          justify-content: space-between;
          gap: 18px;
          color: #FFFFFF;
        }
        @media (min-width: 720px) {
          .ms-hero { padding: 28px 36px 30px; border-radius: 26px; }
        }
        .ms-hero-bg {
          position: absolute; inset: 0;
          background: var(--hero-bg);
          z-index: 0;
        }
        .ms-hero-stripes {
          position: absolute; inset: 0;
          background-image: repeating-linear-gradient(
            135deg,
            transparent 0,
            transparent 14px,
            var(--hero-stripe) 14px,
            var(--hero-stripe) 15px
          );
          z-index: 1;
          pointer-events: none;
        }
        .ms-hero > * { position: relative; z-index: 2; }

        .ms-hero-top {
          display: flex;
          align-items: flex-start;
          justify-content: space-between;
        }
        .ms-status-chip {
          display: inline-flex;
          align-items: center;
          gap: 8px;
          padding: 7px 13px 7px 11px;
          background: rgba(0,0,0,0.42);
          backdrop-filter: blur(6px);
          color: rgba(255,255,255,0.92);
          border-radius: 999px;
          font-family: var(--font-geist-mono, ui-monospace, Menlo, monospace);
          font-size: 10.5px;
          font-weight: 700;
          letter-spacing: 0.16em;
          border: 1px solid rgba(255,255,255,0.08);
        }
        .ms-status-dot {
          width: 7px; height: 7px;
          border-radius: 50%;
          background: rgba(255,255,255,0.4);
        }
        .ms-status-dot.is-on {
          background: var(--ms-brand);
          box-shadow: 0 0 0 4px color-mix(in srgb, var(--ms-brand) 28%, transparent);
          animation: ms-pulse 1.8s ease-in-out infinite;
        }
        @keyframes ms-pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.55; } }

        .ms-hero-body {
          display: flex;
          flex-direction: column;
          gap: 12px;
        }
        .ms-sport-chip {
          display: inline-flex;
          align-items: center;
          gap: 8px;
          align-self: flex-start;
          padding: 6px 12px 6px 10px;
          background: var(--ms-brand);
          color: var(--ms-brand-ink);
          border-radius: 999px;
          font-family: var(--font-geist-mono);
          font-size: 10.5px;
          font-weight: 800;
          letter-spacing: 0.14em;
        }
        .ms-sport-dot {
          width: 8px; height: 8px;
          border-radius: 50%;
          background: var(--ms-brand-ink);
          opacity: 0.4;
        }

        .ms-hero-name {
          margin: 0;
          font-size: clamp(36px, 9.5vw, 96px);
          font-weight: 800;
          line-height: 0.96;
          letter-spacing: -0.04em;
          text-wrap: balance;
          color: #FFFFFF;
        }
        @media (min-width: 720px) {
          .ms-hero-name { font-size: clamp(56px, 7vw, 96px); }
        }
        .ms-hero-tag {
          margin: 0;
          font-size: clamp(14px, 1.4vw, 17px);
          line-height: 1.36;
          color: rgba(255,255,255,0.78);
          max-width: 56ch;
        }

        .ms-hero-meta {
          list-style: none;
          margin: 4px 0 0;
          padding: 0;
          display: flex;
          flex-wrap: wrap;
          gap: 6px 18px;
          color: rgba(255,255,255,0.84);
          font-size: 13px;
          font-weight: 500;
        }
        @media (min-width: 720px) { .ms-hero-meta { font-size: 14px; gap: 6px 22px; } }
        .ms-hero-meta li {
          display: inline-flex;
          align-items: center;
          gap: 6px;
        }
        .ms-meta-icon {
          width: 14px; height: 14px;
          display: inline-flex;
          color: rgba(255,255,255,0.55);
        }
        .ms-meta-icon svg { width: 14px; height: 14px; }
        .ms-meta-icon-star { color: var(--ms-brand); }

        .ms-hero-ctas {
          display: flex;
          align-items: center;
          gap: 10px;
          margin-top: 4px;
          flex-wrap: wrap;
        }
        .ms-cta {
          all: unset;
          cursor: pointer;
          display: inline-flex;
          align-items: center;
          gap: 8px;
          padding: 12px 18px 12px 20px;
          border-radius: 999px;
          font-weight: 700;
          font-size: 14.5px;
          letter-spacing: -0.005em;
          transition: filter 0.12s ease, transform 0.12s ease, background 0.12s ease;
        }
        .ms-cta-arrow svg { width: 16px; height: 16px; }
        .ms-cta-icon { display: inline-flex; }
        .ms-cta-icon svg { width: 16px; height: 16px; }
        .ms-cta-primary {
          background: var(--ms-brand);
          color: var(--ms-brand-ink);
        }
        .ms-cta-primary:hover { filter: brightness(0.94); }
        .ms-cta-ghost {
          background: rgba(0,0,0,0.42);
          color: #FFFFFF;
          border: 1px solid rgba(255,255,255,0.16);
          backdrop-filter: blur(6px);
        }
        .ms-cta-ghost:hover { background: rgba(0,0,0,0.55); }

        /* ─── CHIPS ROW ──────────────────────────────────────────── */
        .ms-chips {
          display: grid;
          grid-template-columns: repeat(3, minmax(0, 1fr));
          gap: 10px;
          flex: 0 0 auto;
        }
        @media (min-width: 540px) { .ms-chips { grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); } }
        @media (min-width: 720px) { .ms-chips { gap: 14px; } }
        .ms-chip {
          all: unset;
          cursor: pointer;
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          gap: 6px;
          padding: 14px 8px;
          background: var(--ms-surface);
          border: 1px solid var(--ms-line);
          border-radius: 14px;
          color: var(--ms-ink);
          text-decoration: none;
          transition: border-color 0.12s ease, transform 0.12s ease, background 0.12s ease;
          min-height: 76px;
          text-align: center;
        }
        .ms-chip:hover {
          border-color: var(--ms-line-strong);
          background: color-mix(in srgb, var(--ms-line) 60%, var(--ms-surface));
        }
        .ms-chip-icon {
          width: 22px; height: 22px;
          display: inline-flex;
          color: var(--ms-ink);
        }
        .ms-chip-icon svg { width: 22px; height: 22px; }
        .ms-chip-label {
          font-size: 12.5px;
          font-weight: 600;
          letter-spacing: -0.005em;
        }

        /* ─── STATS (desktop only) ───────────────────────────────── */
        .ms-stats { display: none; }
        @media (min-width: 720px) {
          .ms-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
            gap: 0;
            border: 1px solid var(--ms-line);
            border-radius: 14px;
            overflow: hidden;
            background: var(--ms-surface);
            flex: 0 0 auto;
          }
          .ms-stat {
            padding: 16px 20px;
            border-right: 1px solid var(--ms-line);
            display: flex;
            flex-direction: column;
            gap: 4px;
          }
          .ms-stat:last-child { border-right: 0; }
          .ms-stat-val {
            font-size: 26px;
            font-weight: 800;
            letter-spacing: -0.025em;
            line-height: 1;
            color: var(--ms-ink);
          }
          .ms-stat-lbl {
            font-family: var(--font-geist-mono);
            font-size: 10.5px;
            font-weight: 600;
            letter-spacing: 0.16em;
            text-transform: uppercase;
            color: var(--ms-muted);
          }
        }

        /* ─── STICKY BOTTOM BAR (mobile only) ────────────────────── */
        .ms-bottombar {
          position: fixed;
          left: 0; right: 0; bottom: 0;
          padding: 12px 14px calc(12px + env(safe-area-inset-bottom, 0));
          background: var(--ms-bg);
          border-top: 1px solid var(--ms-line);
          display: flex;
          align-items: center;
          justify-content: space-between;
          gap: 12px;
          z-index: 800;
        }
        @media (min-width: 720px) { .ms-bottombar { display: none; } }
        .ms-bottombar-left { display: flex; flex-direction: column; gap: 2px; min-width: 0; }
        .ms-bottombar-price {
          font-size: 17px;
          font-weight: 700;
          letter-spacing: -0.01em;
          color: var(--ms-ink);
          white-space: nowrap;
        }
        .ms-bottombar-sub {
          font-family: var(--font-geist-mono);
          font-size: 9.5px;
          font-weight: 700;
          letter-spacing: 0.18em;
          color: var(--ms-muted);
        }
        .ms-bottombar-btn {
          all: unset;
          cursor: pointer;
          display: inline-flex;
          align-items: center;
          gap: 8px;
          padding: 12px 18px;
          background: var(--ms-brand);
          color: var(--ms-brand-ink);
          border-radius: 999px;
          font-weight: 700;
          font-size: 14.5px;
          flex: 0 0 auto;
        }
        .ms-bottombar-btn svg { width: 14px; height: 14px; }

        /* ─── SHEET (share / photos) ─────────────────────────────── */
        .ms-sheet {
          position: fixed; inset: 0; z-index: 9000;
          display: flex; align-items: flex-end; justify-content: center;
          animation: ms-fade 0.18s ease;
        }
        @keyframes ms-fade { from { opacity: 0; } to { opacity: 1; } }
        .ms-sheet-scrim {
          position: absolute; inset: 0;
          background: rgba(0,0,0,0.5);
          backdrop-filter: blur(3px);
          border: 0; cursor: pointer;
        }
        .ms-sheet-panel {
          position: relative;
          width: 100%;
          max-width: 560px;
          max-height: 88vh;
          background: var(--ms-bg);
          color: var(--ms-ink);
          display: flex;
          flex-direction: column;
          overflow: hidden;
          border-radius: 22px 22px 0 0;
          animation: ms-slide 0.22s cubic-bezier(0.2,0.7,0.2,1);
        }
        @keyframes ms-slide { from { transform: translateY(28px); } to { transform: translateY(0); } }
        @media (min-width: 720px) {
          .ms-sheet { align-items: center; padding: 24px; }
          .ms-sheet-panel { border-radius: 18px; }
        }
        .ms-sheet-small { max-width: 460px; }
        .ms-sheet-head {
          flex: 0 0 auto;
          display: flex;
          align-items: center;
          justify-content: space-between;
          padding: 16px 20px;
          border-bottom: 1px solid var(--ms-line);
        }
        .ms-sheet-title { display: flex; flex-direction: column; gap: 2px; min-width: 0; }
        .ms-sheet-eyebrow {
          font-family: var(--font-geist-mono);
          font-size: 10px;
          font-weight: 600;
          letter-spacing: 0.22em;
          color: var(--ms-muted);
        }
        .ms-sheet-venue {
          font-size: 15px;
          font-weight: 700;
          letter-spacing: -0.01em;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }
        .ms-sheet-body {
          flex: 1 1 auto;
          overflow-y: auto;
          padding: 14px 20px 22px;
        }
        .ms-sheet-share {
          display: flex;
          flex-direction: column;
          gap: 0;
          padding: 0;
        }
        .ms-share-row {
          all: unset;
          cursor: pointer;
          display: flex;
          align-items: center;
          gap: 14px;
          padding: 16px 22px;
          color: var(--ms-ink);
          border-bottom: 1px solid var(--ms-line);
          text-decoration: none;
        }
        .ms-share-row:last-child { border-bottom: 0; }
        .ms-share-row:hover { background: var(--ms-line); }
        .ms-share-icon { width: 22px; height: 22px; display: inline-grid; place-items: center; }
        .ms-share-icon svg { width: 20px; height: 20px; }
        .ms-share-label { font-size: 15px; font-weight: 600; flex: 1; }
        .ms-share-url {
          font-family: var(--font-geist-mono);
          font-size: 11.5px;
          color: var(--ms-muted);
          max-width: 180px;
          overflow: hidden;
          text-overflow: ellipsis;
          white-space: nowrap;
        }

        .ms-photos-body { padding: 14px; }
        .ms-photos-grid {
          display: grid;
          gap: 8px;
          grid-template-columns: 1fr;
        }
        @media (min-width: 540px) { .ms-photos-grid { grid-template-columns: 1fr 1fr; } }
        .ms-photo {
          display: block;
          aspect-ratio: 4 / 3;
          overflow: hidden;
          border-radius: 10px;
          background: var(--ms-line);
        }
        .ms-photo img { width: 100%; height: 100%; object-fit: cover; }
      `}</style>
    </main>
  );
}
