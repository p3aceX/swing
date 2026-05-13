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
  operatingDays?: number[];
  advanceBookingDays?: number | null;
  cancellationHours?: number | null;
  hasParking?: boolean;
  hasLights?: boolean;
  hasWashrooms?: boolean;
  hasCanteen?: boolean;
  hasCCTV?: boolean;
  hasScorer?: boolean;
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
  lights:    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><path d="M12 2v3M5 5l2 2M19 5l-2 2M3 12h3M18 12h3M9 18h6M10 21h4"/><circle cx="12" cy="12" r="4"/></svg>,
  parking:   <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><rect x="4" y="4" width="16" height="16" rx="2"/><path d="M9 17V8h4a3 3 0 0 1 0 6H9"/></svg>,
  washroom:  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><circle cx="8" cy="5" r="2"/><circle cx="16" cy="5" r="2"/><path d="M6 22V12l-2-3 4-2h0l2 3v6m6 6V12l2-3-4-2h0l-2 3v6"/></svg>,
  canteen:   <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><path d="M3 2v9a2 2 0 0 0 4 0V2M5 12v10M17 2c-2 0-4 2-4 5v5h3v10"/></svg>,
  cctv:      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><rect x="2" y="6" width="14" height="12" rx="1"/><path d="M16 10l6-2v8l-6-2"/></svg>,
  scorer:    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M9 8v8M15 8v8M3 12h18"/></svg>,
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
  const [copied, setCopied] = useState(false);

  // Lock body scroll while any sheet is open. One source of truth —
  // BookingSheet does NOT lock independently (its prop `onClose` ref
  // changes every render, which caused the lock to ping-pong and
  // sometimes leave the page un-scrollable).
  useEffect(() => {
    if (!bookOpen && !shareOpen) return;
    document.body.style.overflow = "hidden";
    return () => { document.body.style.overflow = ""; };
  }, [bookOpen, shareOpen]);

  /* ─ Derived data ──────────────────────────────────────────────────── */
  const palette = resolvePalette(arena.brandColor);
  const brand = palette.hex;
  const brandInk = readableInk(brand);

  const units = arena.units ?? [];
  const photos = (arena.photoUrls ?? []).filter(Boolean);
  // Hero slideshow — rotates through up to 3 photos, starting at coverPhotoIndex.
  const startingPhotoIdx = Math.min(Math.max(arena.coverPhotoIndex ?? 0, 0), Math.max(photos.length - 1, 0));
  const [heroPhotoIdx, setHeroPhotoIdx] = useState(startingPhotoIdx);
  useEffect(() => {
    if (photos.length <= 1) return;
    const id = setInterval(() => {
      setHeroPhotoIdx((i) => (i + 1) % photos.length);
    }, 5500);
    return () => clearInterval(id);
  }, [photos.length]);

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

  // Status chip text — always include the full open–close range when we
  // know it, prefixed with OPEN / CLOSED so visitors see both times.
  const statusText = openNow == null
    ? (hoursLine ?? "Hours unlisted")
    : hoursLine
      ? `${openNow ? "OPEN" : "CLOSED"} · ${hoursLine.toUpperCase()}`
      : openNow
        ? "OPEN NOW"
        : "CLOSED";

  const rating = arena.rating && arena.rating > 0 ? Math.round(arena.rating * 10) / 10 : null;
  const ratingCount = arena.totalRatings ?? null;

  const canonicalSlug = arena.customSlug ?? arena.arenaSlug ?? slug;
  // SSR-stable URL. After mount, useEffect upgrades it to the actual
  // window.location.href so share/copy reflect previews / custom domains.
  const [publicUrl, setPublicUrl] = useState(`https://www.swingcricketapp.com/arena/${canonicalSlug}`);
  useEffect(() => { setPublicUrl(window.location.href); }, []);

  const mapHref = arena.latitude && arena.longitude
    ? `https://www.google.com/maps/dir/?api=1&destination=${arena.latitude},${arena.longitude}`
    : fullAddress ? `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(fullAddress)}` : null;

  /* ─ Owner-curated links (Instagram, WhatsApp, etc.) ──────────────── */
  const customLinks = (arena.micrositeLinks ?? [])
    .filter((l) => l && l.enabled !== false && l.url)
    .sort((a, b) => (a.order ?? 0) - (b.order ?? 0));
  // Always render this fixed set of social slots so the area is never empty.
  // Owner-set ones become full-brand and clickable; the rest stay as dim
  // outlined placeholders to show the design intent.
  const SOCIAL_SLOTS: MicrositeLink["kind"][] = ["instagram", "whatsapp", "youtube", "website", "menu"];
  const setLinksByKind = new Map<MicrositeLink["kind"], MicrositeLink>(customLinks.map((l) => [l.kind, l]));
  const socials = SOCIAL_SLOTS.map((kind) => ({ kind, link: setLinksByKind.get(kind) ?? null }));

  /* ─ Tagline with sensible fallback so the slot is never blank ─────── */
  const cityShort = arena.city || (locationLine ? locationLine.split(",")[0].trim() : "");
  const fallbackTag = sportLabel
    ? (cityShort ? `Premium ${sportLabel.toLowerCase()} arena in ${cityShort}.` : `Premium ${sportLabel.toLowerCase()} arena.`)
    : `Book ${arena.name} instantly.`;
  const heroTagline = arena.tagline?.trim() || fallbackTag;

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
  // Brand color goes through a CSS variable so child elements (chips,
  // buttons, etc.) can reference it. Gradient/stripes are applied
  // *directly* via inline style on the hero — CSS-var-held gradients
  // are brittle across browsers + build pipelines.
  const rootStyle = useMemo(() => ({
    ["--ms-brand" as string]: brand,
    ["--ms-brand-ink" as string]: brandInk,
  } as React.CSSProperties), [brand, brandInk]);
  const heroStyle = useMemo<React.CSSProperties>(() => ({
    backgroundColor: "#0A1410",
    backgroundImage: palette.bg,
  }), [palette]);
  const stripeStyle = useMemo<React.CSSProperties>(() => ({
    backgroundImage: `repeating-linear-gradient(135deg, transparent 0, transparent 14px, ${palette.stripe} 14px, ${palette.stripe} 15px)`,
  }), [palette]);

  return (
    <main className="ms" style={rootStyle}>
      {/* ─── TOP BAR ────────────────────────────────────────────────── */}
      <header className="ms-top">
        <div className="ms-top-brand">
          <span className="ms-avatar" aria-hidden="true">
            {arena.logoUrl
              // eslint-disable-next-line @next/next/no-img-element
              ? <img src={arena.logoUrl} alt="" />
              : <span>{initialsFrom(arena.name)}</span>}
          </span>
          <span className="ms-top-name">{arena.name}</span>
        </div>
        <div className="ms-top-actions">
          <ThemeToggle />
          {canBook && (
            <button type="button" className="ms-book-pill" onClick={() => setBookOpen(true)}>
              Book
            </button>
          )}
        </div>
      </header>

      {/* ─── HERO + CHIPS + BOTTOM BAR ──────────────────────────────── */}
      <section className="ms-stage">
        {/* HERO card */}
        <article className="ms-hero" style={heroStyle}>
          {photos.length > 0 ? (
            <>
              {photos.map((src, i) => (
                // eslint-disable-next-line @next/next/no-img-element
                <img
                  key={src + i}
                  src={src}
                  alt=""
                  aria-hidden="true"
                  className={`ms-hero-photo${i === heroPhotoIdx ? " is-active" : ""}`}
                />
              ))}
              <div className="ms-hero-veil" aria-hidden="true" />
            </>
          ) : (
            <div className="ms-hero-stripes" style={stripeStyle} aria-hidden="true" />
          )}

          <div className="ms-hero-top">
            <span className="ms-status-chip">
              <span className={`ms-status-dot ${openNow ? "is-on" : ""}`} aria-hidden="true" />
              <span className="ms-status-text">{statusText}</span>
            </span>
          </div>

          <div className="ms-hero-body">
            <h1 className="ms-hero-name">{arena.name}</h1>
            <p className="ms-hero-tag">&ldquo;{heroTagline}&rdquo;</p>

            <ul className="ms-hero-meta">
              {locationLine && (
                <li>
                  <span className="ms-meta-icon" aria-hidden="true">{Icon.pin}</span>
                  <span>{locationLine}</span>
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

        {/* ABOUT — description + amenities (as icons) + operating days */}
        <section className="ms-about" aria-label="About">
          <span className="ms-rblock-eyebrow">ABOUT</span>
          {arena.description && <p className="ms-about-prose">{arena.description}</p>}

          {(arena.hasLights || arena.hasParking || arena.hasWashrooms || arena.hasCanteen || arena.hasCCTV || arena.hasScorer) && (
            <ul className="ms-about-amen" aria-label="Amenities">
              {arena.hasLights    && <li className="ms-amen-cell"><span className="ms-amen-glyph" aria-hidden="true">{Icon.lights}</span><span className="ms-amen-label">Lights</span></li>}
              {arena.hasParking   && <li className="ms-amen-cell"><span className="ms-amen-glyph" aria-hidden="true">{Icon.parking}</span><span className="ms-amen-label">Parking</span></li>}
              {arena.hasWashrooms && <li className="ms-amen-cell"><span className="ms-amen-glyph" aria-hidden="true">{Icon.washroom}</span><span className="ms-amen-label">Washroom</span></li>}
              {arena.hasCanteen   && <li className="ms-amen-cell"><span className="ms-amen-glyph" aria-hidden="true">{Icon.canteen}</span><span className="ms-amen-label">Canteen</span></li>}
              {arena.hasCCTV      && <li className="ms-amen-cell"><span className="ms-amen-glyph" aria-hidden="true">{Icon.cctv}</span><span className="ms-amen-label">CCTV</span></li>}
              {arena.hasScorer    && <li className="ms-amen-cell"><span className="ms-amen-glyph" aria-hidden="true">{Icon.scorer}</span><span className="ms-amen-label">Scorer</span></li>}
            </ul>
          )}

          {/* Operating days — Mon-Sun row; brand-filled = open, dim = closed */}
          <div className="ms-about-days">
            <span className="ms-rblock-eyebrow ms-rblock-eyebrow-soft">OPEN ON</span>
            <ul className="ms-days-row">
              {[
                { d: 1, label: "Mon" },
                { d: 2, label: "Tue" },
                { d: 3, label: "Wed" },
                { d: 4, label: "Thu" },
                { d: 5, label: "Fri" },
                { d: 6, label: "Sat" },
                { d: 7, label: "Sun" },
              ].map(({ d, label }) => {
                const open = (arena.operatingDays ?? [1, 2, 3, 4, 5, 6, 7]).includes(d);
                return (
                  <li key={d} className={`ms-day ${open ? "is-open" : ""}`} aria-label={`${label} ${open ? "open" : "closed"}`}>
                    {label}
                  </li>
                );
              })}
            </ul>
          </div>
        </section>

        {/* RATING + FOLLOW — combined */}
        <section className="ms-rating-follow" aria-label="Rating and social links">
          <div className="ms-rf-rating">
            <span className="ms-rblock-eyebrow ms-rblock-eyebrow-soft">RATING</span>
            {rating != null ? (
              <div className="ms-rf-rating-body">
                <span className="ms-rf-star" aria-hidden="true">{Icon.star}</span>
                <span className="ms-rf-rating-val">{rating.toFixed(1)}</span>
                {ratingCount != null && (
                  <span className="ms-rf-rating-meta">
                    {ratingCount} {ratingCount === 1 ? "review" : "reviews"}
                  </span>
                )}
              </div>
            ) : (
              <div className="ms-rf-rating-body">
                <span className="ms-rf-star ms-rf-star-empty" aria-hidden="true">{Icon.star}</span>
                <span className="ms-rf-rating-meta">No reviews yet</span>
              </div>
            )}
          </div>

          <div className="ms-rf-divider" aria-hidden="true" />

          <div className="ms-rf-follow">
            <span className="ms-rblock-eyebrow ms-rblock-eyebrow-soft">FOLLOW</span>
            <ul className="ms-socials" aria-label="Social media">
              {socials.map(({ kind, link }) => (
                <li key={kind}>
                  {link ? (
                    <a
                      className="ms-social is-active"
                      href={link.url}
                      target={link.url.startsWith("http") ? "_blank" : undefined}
                      rel={link.url.startsWith("http") ? "noopener noreferrer" : undefined}
                      aria-label={link.label || kind}
                      title={link.label || kind}
                    >
                      {KIND_ICON[kind]}
                    </a>
                  ) : (
                    <span className="ms-social" aria-hidden="true" title={kind}>
                      {KIND_ICON[kind]}
                    </span>
                  )}
                </li>
              ))}
            </ul>
          </div>
        </section>

        {/* DIRECTIONS / MAP */}
        {(arena.latitude && arena.longitude) || mapHref ? (
          <a
            className="ms-mapcard"
            href={mapHref ?? "#"}
            target="_blank"
            rel="noopener noreferrer"
            aria-label="Get directions"
          >
            {arena.latitude && arena.longitude ? (
              <iframe
                className="ms-mapcard-frame"
                title={`${arena.name} location`}
                src={`https://www.google.com/maps?q=${arena.latitude},${arena.longitude}&hl=en&z=15&output=embed`}
                loading="lazy"
                referrerPolicy="no-referrer-when-downgrade"
                aria-hidden="true"
              />
            ) : (
              <div className="ms-mapcard-frame ms-mapcard-fallback" aria-hidden="true" />
            )}
            <div className="ms-mapcard-overlay">
              <span className="ms-mapcard-pin" aria-hidden="true">{Icon.pin}</span>
              <div className="ms-mapcard-text">
                <span className="ms-mapcard-line1">{locationLine || "Find us"}</span>
                <span className="ms-mapcard-line2">Get directions  →</span>
              </div>
            </div>
          </a>
        ) : null}
      </section>

      {/* ─── FOOTER — small Swing credit ─────────────────────────────── */}
      <footer className="ms-footer">
        <span>Powered by</span>
        <a href="https://www.swingcricketapp.com" target="_blank" rel="noopener noreferrer">Swing</a>
      </footer>

      {/* ─── STICKY BOTTOM BAR (mobile only) ────────────────────────── */}
      {canBook && (
        <div className="ms-bottombar">
          <div className="ms-bottombar-left">
            <span className="ms-bottombar-status">Live availability</span>
            <span className="ms-bottombar-sub">Real-time slots</span>
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
          advanceBookingDays={arena.advanceBookingDays ?? null}
          cancellationHours={arena.cancellationHours ?? null}
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

        /* ─── SHELL ─────────────────────────────────────────────── */
        .ms {
          min-height: 100svh;
          background: var(--ms-bg);
          color: var(--ms-ink);
          font-family: var(--font-geist-sans, "Inter Tight", system-ui, sans-serif);
          display: flex;
          flex-direction: column;
          padding-bottom: 96px; /* room for the fixed bottom Book bar */
          -webkit-font-smoothing: antialiased;
        }

        /* ─── TOP BAR — minimal ──────────────────────────────────── */
        .ms-top {
          position: sticky;
          top: 0;
          z-index: 50;
          display: flex;
          align-items: center;
          justify-content: space-between;
          gap: 14px;
          padding: 12px 18px;
          background: var(--ms-bg);
          border-bottom: 1px solid var(--ms-line);
        }
        @media (min-width: 720px) { .ms-top { padding: 14px 36px; } }

        .ms-top-brand {
          display: flex;
          align-items: center;
          gap: 10px;
          min-width: 0;
        }
        .ms-avatar {
          width: 30px;
          height: 30px;
          flex: 0 0 auto;
          display: inline-grid;
          place-items: center;
          background: var(--ms-brand);
          color: var(--ms-brand-ink);
          border-radius: 6px;
          font-family: var(--font-geist-sans);
          font-weight: 700;
          font-size: 11px;
          letter-spacing: 0.02em;
          overflow: hidden;
        }
        .ms-avatar img { width: 100%; height: 100%; object-fit: cover; }
        @media (min-width: 720px) {
          .ms-avatar { width: 34px; height: 34px; font-size: 12px; }
        }

        .ms-top-name {
          font-size: 14.5px;
          font-weight: 600;
          letter-spacing: -0.005em;
          color: var(--ms-ink);
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
          min-width: 0;
        }
        @media (min-width: 720px) { .ms-top-name { font-size: 16px; } }

        .ms-top-actions {
          display: flex;
          align-items: center;
          gap: 10px;
          flex: 0 0 auto;
        }

        /* Theme toggle — pill with a sliding thumb between sun + moon */
        .ms-theme {
          all: unset;
          position: relative;
          display: inline-flex;
          align-items: center;
          width: 52px;
          height: 28px;
          border-radius: 6px;
          background: transparent;
          border: 1px solid var(--ms-line-strong);
          cursor: pointer;
          box-sizing: border-box;
        }
        .ms-theme:hover { border-color: var(--ms-ink); }
        .ms-theme:focus-visible {
          outline: 2px solid var(--ms-brand);
          outline-offset: 2px;
        }

        .ms-theme-thumb {
          position: absolute;
          top: 2px;
          left: 2px;
          width: 22px;
          height: 22px;
          border-radius: 4px;
          background: var(--ms-ink);
          transition: transform 0.22s cubic-bezier(0.2, 0.7, 0.2, 1);
          z-index: 1;
        }
        .ms-theme[data-mode="dark"] .ms-theme-thumb {
          transform: translateX(24px);
        }

        .ms-theme-icons {
          position: relative;
          display: flex;
          align-items: center;
          justify-content: space-between;
          width: 100%;
          padding: 0 8px;
          z-index: 2;
          pointer-events: none;
        }
        .ms-theme-sun,
        .ms-theme-moon {
          display: inline-flex;
          width: 12px;
          height: 12px;
          color: var(--ms-soft);
          transition: color 0.2s ease;
        }
        .ms-theme-sun  svg,
        .ms-theme-moon svg { width: 12px; height: 12px; }
        /* Active icon sits ON the ink thumb — invert to bg color for contrast */
        .ms-theme[data-mode="light"] .ms-theme-sun  { color: var(--ms-bg); }
        .ms-theme[data-mode="dark"]  .ms-theme-moon { color: var(--ms-bg); }

        .ms-book-pill {
          all: unset;
          cursor: pointer;
          padding: 8px 16px;
          background: var(--ms-ink);
          color: var(--ms-bg);
          border-radius: 6px;
          font-weight: 600;
          font-size: 13.5px;
          letter-spacing: -0.005em;
          transition: opacity 0.14s ease;
        }
        .ms-book-pill:hover { opacity: 0.86; }

        /* ─── STAGE ──────────────────────────────────────────────── */
        .ms-stage {
          padding: 14px 14px 24px;
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
          overflow: hidden;
          border-radius: 6px;
          min-height: 380px;
          padding: 20px 22px 22px;
          display: flex;
          flex-direction: column;
          justify-content: space-between;
          gap: 18px;
          color: #FFFFFF;
        }
        @media (min-width: 720px) {
          .ms-hero { padding: 28px 36px 30px; min-height: 460px; }
        }
        .ms-hero-stripes,
        .ms-hero-photo {
          position: absolute; inset: 0;
          width: 100%; height: 100%;
          z-index: 0;
          pointer-events: none;
        }
        .ms-hero-photo {
          object-fit: cover;
          opacity: 0;
          transition: opacity 0.9s ease;
        }
        .ms-hero-photo.is-active { opacity: 1; }
        /* Dark overlay — strong at the bottom, light at top, so the
           hero photo reads cinematically and the name/CTA stay legible. */
        .ms-hero-veil {
          position: absolute; inset: 0;
          z-index: 1;
          pointer-events: none;
          background:
            linear-gradient(180deg, rgba(0,0,0,0.18) 0%, rgba(0,0,0,0.42) 38%, rgba(0,0,0,0.78) 78%, rgba(0,0,0,0.92) 100%);
        }
        .ms-hero-top,
        .ms-hero-body { position: relative; z-index: 2; }

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
          border-radius: 6px;
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

        .ms-hero-name {
          margin: 0;
          font-family: var(--font-bricolage), "Bricolage Grotesque", var(--font-geist-sans), "Inter Tight", system-ui, sans-serif;
          font-size: clamp(38px, 9.4vw, 92px);
          font-weight: 700;
          line-height: 0.94;
          letter-spacing: -0.04em;
          text-wrap: balance;
          color: #FFFFFF;
        }
        @media (min-width: 720px) {
          .ms-hero-name { font-size: clamp(54px, 6.6vw, 92px); }
        }
        .ms-hero-tag {
          margin: 4px 0 0;
          font-family: var(--font-bricolage), "Bricolage Grotesque", var(--font-geist-sans), "Inter Tight", system-ui, sans-serif;
          font-style: normal;
          font-weight: 400;
          font-size: clamp(15px, 1.8vw, 18px);
          line-height: 1.36;
          letter-spacing: -0.01em;
          color: rgba(255, 255, 255, 0.86);
          max-width: 44ch;
          text-wrap: balance;
        }
        @media (min-width: 720px) {
          .ms-hero-tag { font-size: clamp(17px, 1.6vw, 20px); }
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
          border-radius: 6px;
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

        /* ─── ABOUT SECTION (description + amenities + days) ─────── */
        .ms-about {
          background: var(--ms-surface);
          border: 1px solid var(--ms-line);
          border-radius: 6px;
          padding: 18px 20px;
          display: flex;
          flex-direction: column;
          gap: 16px;
        }
        @media (min-width: 720px) { .ms-about { padding: 22px 26px; gap: 20px; } }

        .ms-about-prose {
          margin: 0;
          font-size: 15px;
          line-height: 1.55;
          color: var(--ms-ink);
          white-space: pre-wrap;
          letter-spacing: -0.005em;
        }
        @media (min-width: 720px) { .ms-about-prose { font-size: 16px; line-height: 1.6; max-width: 64ch; } }

        /* Amenities — brand-color icon + small caption underneath */
        .ms-about-amen {
          list-style: none;
          margin: 0;
          padding: 12px 0 6px;
          display: grid;
          grid-template-columns: repeat(3, minmax(0, 1fr));
          gap: 16px 10px;
          border-top: 1px solid var(--ms-line);
        }
        @media (min-width: 540px) { .ms-about-amen { grid-template-columns: repeat(6, minmax(0, 1fr)); gap: 14px; } }
        .ms-amen-cell {
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 6px;
          text-align: center;
          min-width: 0;
        }
        .ms-amen-glyph {
          width: 28px; height: 28px;
          display: inline-grid; place-items: center;
          color: var(--ms-brand);
        }
        .ms-amen-glyph svg { width: 26px; height: 26px; }
        .ms-amen-label {
          font-size: 11.5px;
          font-weight: 600;
          letter-spacing: -0.005em;
          color: var(--ms-muted);
          line-height: 1.1;
        }

        /* Operating days — Mon–Sun chip row */
        .ms-about-days {
          display: flex;
          flex-direction: column;
          gap: 8px;
          border-top: 1px solid var(--ms-line);
          padding-top: 14px;
        }
        .ms-rblock-eyebrow-soft { color: var(--ms-muted); }
        .ms-days-row {
          list-style: none;
          margin: 0;
          padding: 0;
          display: grid;
          grid-template-columns: repeat(7, minmax(0, 1fr));
          gap: 5px;
        }
        @media (min-width: 540px) { .ms-days-row { gap: 8px; } }
        .ms-day {
          padding: 8px 4px;
          text-align: center;
          border: 1px solid var(--ms-line);
          border-radius: 4px;
          font-family: var(--font-geist-mono, ui-monospace, Menlo, monospace);
          font-size: 10.5px;
          font-weight: 700;
          letter-spacing: 0.1em;
          color: var(--ms-soft);
          background: transparent;
          text-transform: uppercase;
        }
        .ms-day.is-open {
          color: var(--ms-brand-ink);
          background: var(--ms-brand);
          border-color: var(--ms-brand);
        }

        /* ─── RATING + FOLLOW (combined section) ─────────────────── */
        .ms-rating-follow {
          background: var(--ms-surface);
          border: 1px solid var(--ms-line);
          border-radius: 6px;
          padding: 14px 18px;
          display: flex;
          align-items: stretch;
          gap: 14px;
        }
        @media (min-width: 720px) { .ms-rating-follow { padding: 18px 24px; gap: 22px; } }

        .ms-rf-rating,
        .ms-rf-follow {
          display: flex;
          flex-direction: column;
          gap: 8px;
          flex: 1 1 auto;
          min-width: 0;
        }
        .ms-rf-rating { flex: 0 0 auto; }

        .ms-rf-rating-body {
          display: inline-flex;
          align-items: baseline;
          gap: 8px;
        }
        .ms-rf-star {
          display: inline-flex;
          color: var(--ms-brand);
          align-self: center;
        }
        .ms-rf-star svg { width: 18px; height: 18px; }
        .ms-rf-star-empty { color: var(--ms-soft); }
        .ms-rf-rating-val {
          font-size: 22px;
          font-weight: 800;
          letter-spacing: -0.025em;
          line-height: 1;
          color: var(--ms-ink);
        }
        @media (min-width: 720px) { .ms-rf-rating-val { font-size: 26px; } }
        .ms-rf-rating-meta {
          font-family: var(--font-geist-mono, ui-monospace, Menlo, monospace);
          font-size: 10.5px;
          font-weight: 700;
          letter-spacing: 0.14em;
          text-transform: uppercase;
          color: var(--ms-muted);
        }

        .ms-rf-divider {
          width: 1px;
          align-self: stretch;
          background: var(--ms-line);
          flex: 0 0 auto;
        }

        /* Map card */
        .ms-mapcard {
          position: relative;
          display: block;
          overflow: hidden;
          height: 180px;
          border-radius: 6px;
          border: 1px solid var(--ms-line);
          background: var(--ms-surface);
          color: #FFFFFF;
          text-decoration: none;
        }
        @media (min-width: 720px) { .ms-mapcard { height: 220px; } }
        .ms-mapcard-frame {
          position: absolute; inset: 0;
          width: 100%; height: 100%;
          border: 0;
          display: block;
          pointer-events: none;
          filter: contrast(0.92) saturate(0.84);
        }
        [data-theme="dark"] .ms-mapcard-frame {
          filter: invert(0.92) hue-rotate(180deg) contrast(0.86) saturate(0.55) brightness(1.05);
        }
        .ms-mapcard-fallback {
          background:
            radial-gradient(120% 90% at 30% 30%, var(--ms-brand) 0%, transparent 55%),
            #1a1a1a;
          opacity: 0.85;
        }
        .ms-mapcard-overlay {
          position: absolute; inset: 0;
          background: linear-gradient(180deg, rgba(0,0,0,0.05) 0%, rgba(0,0,0,0.55) 65%, rgba(0,0,0,0.88) 100%);
          display: flex;
          align-items: flex-end;
          gap: 10px;
          padding: 12px 14px;
        }
        .ms-mapcard-pin {
          width: 32px; height: 32px;
          display: inline-grid; place-items: center;
          border-radius: 6px;
          background: var(--ms-brand);
          color: var(--ms-brand-ink);
          flex: 0 0 auto;
        }
        .ms-mapcard-pin svg { width: 16px; height: 16px; }
        .ms-mapcard-text { display: flex; flex-direction: column; gap: 1px; min-width: 0; }
        .ms-mapcard-line1 {
          font-size: 13px;
          font-weight: 700;
          letter-spacing: -0.005em;
          color: #FFFFFF;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }
        .ms-mapcard-line2 {
          font-family: var(--font-geist-mono);
          font-size: 10.5px;
          font-weight: 600;
          letter-spacing: 0.12em;
          color: rgba(255,255,255,0.78);
          text-transform: uppercase;
        }

        .ms-rblock-eyebrow {
          font-family: var(--font-geist-mono);
          font-size: 9.5px;
          font-weight: 700;
          letter-spacing: 0.22em;
          color: var(--ms-muted);
        }

        .ms-socials {
          list-style: none;
          margin: 0;
          padding: 0;
          display: flex;
          flex-wrap: wrap;
          gap: 8px;
        }
        .ms-social {
          width: 36px; height: 36px;
          display: inline-grid;
          place-items: center;
          border-radius: 6px;
          border: 1px solid var(--ms-line-strong);
          background: transparent;
          color: var(--ms-soft);
          text-decoration: none;
          transition: background 0.12s ease, color 0.12s ease, border-color 0.12s ease, transform 0.12s ease;
        }
        .ms-social svg { width: 16px; height: 16px; }
        .ms-social.is-active {
          background: var(--ms-brand);
          color: var(--ms-brand-ink);
          border-color: var(--ms-brand);
        }
        .ms-social.is-active:hover { filter: brightness(0.94); transform: translateY(-1px); }
        .ms-social:not(.is-active) {
          opacity: 0.55;
        }

        /* ─── FOOTER — Powered by Swing credit ─────────────────── */
        .ms-footer {
          padding: 24px 18px 12px;
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 6px;
          font-family: var(--font-geist-mono, ui-monospace, Menlo, monospace);
          font-size: 10.5px;
          font-weight: 700;
          letter-spacing: 0.22em;
          text-transform: uppercase;
          color: var(--ms-muted);
        }
        .ms-footer a {
          color: var(--ms-ink);
          text-decoration: underline;
          text-underline-offset: 3px;
          text-decoration-color: var(--ms-soft);
          transition: text-decoration-color 0.12s ease;
        }
        .ms-footer a:hover { text-decoration-color: var(--ms-brand); }

        /* ─── STICKY BOTTOM BAR — always visible ──────────────── */
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
        @media (min-width: 720px) {
          .ms-bottombar {
            padding: 14px 36px;
          }
        }
        .ms-bottombar-left { display: flex; flex-direction: column; gap: 3px; min-width: 0; }
        .ms-bottombar-status {
          font-size: 13.5px;
          font-weight: 700;
          letter-spacing: -0.005em;
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
          border-radius: 6px;
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
          background: rgba(0,0,0,0.86);
          backdrop-filter: blur(8px) saturate(0.85);
          -webkit-backdrop-filter: blur(8px) saturate(0.85);
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
          border-radius: 6px 6px 0 0;
          animation: ms-slide 0.22s cubic-bezier(0.2,0.7,0.2,1);
        }
        @keyframes ms-slide { from { transform: translateY(100%); } to { transform: translateY(0); } }
        /* Always anchor to the bottom — no centered-modal override. */
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

      `}</style>
    </main>
  );
}
