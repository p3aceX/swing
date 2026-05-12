import type { Metadata } from "next";
import { notFound } from "next/navigation";
import LinkCards from "./_link-cards";
import PhotoCarousel from "./_carousel";

type PageProps = { params: Promise<{ slug: string }> };

type NetVariant = { type: string; label: string; pricePaise?: number | null };
type ArenaAddon = { id: string; name: string; pricePaise: number; description?: string | null; unit?: string | null };
type ArenaUnit = {
  id: string;
  name: string;
  unitType?: string;
  pricePerHourPaise?: number;
  minSlotMins?: number;
  price4HrPaise?: number | null;
  price8HrPaise?: number | null;
  priceFullDayPaise?: number | null;
  photoUrls?: string[];
  description?: string | null;
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

type Arena = {
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
  hasParking?: boolean;
  hasLights?: boolean;
  hasWashrooms?: boolean;
  hasCanteen?: boolean;
  hasCCTV?: boolean;
  hasScorer?: boolean;
  customSlug?: string | null;
  arenaSlug?: string | null;
  latitude?: number | null;
  longitude?: number | null;
  // Microsite — owner-branded landing fields
  brandColor?: string | null;
  logoUrl?: string | null;
  tagline?: string | null;
  coverPhotoIndex?: number | null;
  micrositeLinks?: MicrositeLink[] | null;
};

const API = (
  process.env.NEXT_PUBLIC_API_BASE_URL ||
  process.env.API_BASE_URL ||
  "https://swing-backend-1007730655118.asia-south1.run.app"
).replace(/\/$/, "");

async function fetchArena(slug: string): Promise<Arena | null> {
  try {
    const res = await fetch(`${API}/public/arena/p/${encodeURIComponent(slug)}`, {
      next: { revalidate: 60 },
    });
    if (!res.ok) return null;
    const body = (await res.json()) as { data?: Arena };
    return body.data ?? null;
  } catch {
    return null;
  }
}

function sportLabel(s: string) {
  const t = s.trim();
  return t ? t.charAt(0).toUpperCase() + t.slice(1).toLowerCase() : "Other";
}

function fmt12Short(time?: string | null) {
  if (!time) return null;
  const [hourRaw, minuteRaw = "00"] = time.split(":");
  const hour = Number(hourRaw);
  if (Number.isNaN(hour)) return time;
  const suffix = hour >= 12 ? "PM" : "AM";
  const displayHour = hour % 12 || 12;
  const min = minuteRaw === "00" ? "" : `:${minuteRaw.padStart(2, "0")}`;
  return `${displayHour}${min} ${suffix}`;
}

// Pick a sensible foreground (black or white) for any brand color.
function readableInk(hex: string) {
  const m = /^#([0-9a-f]{6})$/i.exec(hex);
  if (!m) return "#FFFFFF";
  const n = parseInt(m[1], 16);
  const r = (n >> 16) & 255, g = (n >> 8) & 255, b = n & 255;
  return (r * 299 + g * 587 + b * 114) / 1000 > 160 ? "#0A0B0A" : "#FFFFFF";
}

function marketingDescription(arena: Arena) {
  const location = [arena.city, arena.state].filter(Boolean).join(", ");
  const sports = (arena.sports ?? []).map(sportLabel).join(", ");
  const units = arena.units ?? [];
  const unitLabel = units.length
    ? `${units.length} ${units.length === 1 ? "play area" : "play areas"}`
    : "sports venue";
  const details = ["Book instantly", unitLabel, sports, location].filter(Boolean);
  return `${details.join(" · ")}. Live availability, secure payments. Powered by Swing.`;
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { slug } = await params;
  const arena = await fetchArena(slug);

  if (!arena) return { title: "Arena not found" };

  const location = [arena.city, arena.state].filter(Boolean).join(", ");
  const sports = (arena.sports ?? []).map(sportLabel).join(", ");
  const photos = arena.photoUrls?.filter(Boolean) ?? [];
  const coverIdx = Math.min(Math.max(arena.coverPhotoIndex ?? 0, 0), Math.max(photos.length - 1, 0));
  const photo = photos[coverIdx] ?? photos[0];
  const canonicalSlug = arena.customSlug ?? arena.arenaSlug ?? slug;
  const title = `${arena.name}${location ? ` · ${location}` : ""}`;
  const description = arena.tagline || marketingDescription(arena);
  const image = photo
    ? [{ url: photo, width: 1200, height: 630, alt: `${arena.name} on Swing` }]
    : [{ url: "/assets/logo-light.png", width: 1200, height: 630, alt: "Swing" }];

  return {
    title,
    description,
    keywords: [
      arena.name,
      location && `${arena.name} ${location}`,
      location && `book sports arena in ${location}`,
      sports && `${sports} booking`,
      "sports venue booking",
    ].filter(Boolean) as string[],
    alternates: { canonical: `/arena/${canonicalSlug}` },
    robots: {
      index: true,
      follow: true,
      googleBot: { index: true, follow: true, "max-image-preview": "large", "max-snippet": -1 },
    },
    openGraph: { title, description, url: `/arena/${canonicalSlug}`, siteName: arena.name, images: image, type: "website" },
    twitter: { card: "summary_large_image", title, description, images: image.map((item) => item.url) },
  };
}

export default async function ArenaPage({ params }: PageProps) {
  const { slug } = await params;
  const arena = await fetchArena(slug);

  if (!arena) notFound();

  const units = arena.units ?? [];
  const photos = arena.photoUrls?.filter(Boolean) ?? [];
  const coverIdx = Math.min(Math.max(arena.coverPhotoIndex ?? 0, 0), Math.max(photos.length - 1, 0));
  const cover = photos[coverIdx] ?? null;
  const galleryPhotos = photos.filter((_, i) => i !== coverIdx);
  const sports = (arena.sports ?? []).filter(Boolean);
  const fullAddress = [arena.address, arena.city, arena.state].filter(Boolean).join(", ");
  const locationLine = [arena.city, arena.state].filter(Boolean).join(" · ") || null;

  const brand = arena.brandColor && /^#[0-9a-fA-F]{6}$/.test(arena.brandColor) ? arena.brandColor : "#16A34A";
  const brandInk = readableInk(brand);

  const sv = { width: 22, height: 22, viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", strokeWidth: 1.6, strokeLinecap: "round" as const, strokeLinejoin: "round" as const };
  const amenities = [
    arena.hasLights    && { label: "Floodlights", icon: <svg {...sv}><path d="M12 2v3M5 5l2 2M19 5l-2 2M3 12h3M18 12h3M9 18h6M10 21h4"/><circle cx="12" cy="12" r="4"/></svg> },
    arena.hasParking   && { label: "Parking",     icon: <svg {...sv}><rect x="4" y="4" width="16" height="16" rx="2"/><path d="M9 17V8h4a3 3 0 0 1 0 6H9"/></svg> },
    arena.hasWashrooms && { label: "Washrooms",   icon: <svg {...sv}><circle cx="8" cy="5" r="2"/><circle cx="16" cy="5" r="2"/><path d="M6 22V12l-2-3 4-2h0l2 3v6m6 6V12l2-3-4-2h0l-2 3v6"/></svg> },
    arena.hasCanteen   && { label: "Canteen",     icon: <svg {...sv}><path d="M3 2v9a2 2 0 0 0 4 0V2M5 12v10M17 2c-2 0-4 2-4 5v5h3v10"/></svg> },
    arena.hasCCTV      && { label: "CCTV",        icon: <svg {...sv}><rect x="2" y="6" width="14" height="12" rx="1"/><path d="M16 10l6-2v8l-6-2"/></svg> },
    arena.hasScorer    && { label: "Scorer",      icon: <svg {...sv}><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M9 8v8M15 8v8M3 12h18"/></svg> },
  ].filter(Boolean) as { label: string; icon: React.ReactElement }[];

  const toMins = (t: string) => { const [h, m] = t.split(":").map(Number); return h * 60 + (m || 0); };
  const unitOpenTimes = units.map((u) => u.openTime).filter(Boolean) as string[];
  const unitCloseTimes = units.map((u) => u.closeTime).filter(Boolean) as string[];
  const arenaOpenTime = unitOpenTimes.length
    ? unitOpenTimes.reduce((a, b) => toMins(a) <= toMins(b) ? a : b)
    : arena.openTime ?? null;
  const arenaCloseTime = unitCloseTimes.length
    ? unitCloseTimes.reduce((a, b) => toMins(a) >= toMins(b) ? a : b)
    : arena.closeTime ?? null;

  const hoursLine = arenaOpenTime && arenaCloseTime
    ? `${fmt12Short(arenaOpenTime)} – ${fmt12Short(arenaCloseTime)}`
    : arenaOpenTime
    ? `Opens ${fmt12Short(arenaOpenTime)}`
    : null;

  const canonicalSlug = arena.customSlug ?? arena.arenaSlug ?? slug;
  const publicUrl = `https://www.swingcricketapp.com/arena/${canonicalSlug}`;
  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "SportsActivityLocation",
    name: arena.name,
    description: arena.tagline || marketingDescription(arena),
    url: publicUrl,
    image: photos,
    logo: arena.logoUrl || undefined,
    telephone: arena.phone,
    address: fullAddress
      ? {
          "@type": "PostalAddress",
          streetAddress: arena.address || undefined,
          addressLocality: arena.city || undefined,
          addressRegion: arena.state || undefined,
        }
      : undefined,
    geo: arena.latitude && arena.longitude
      ? { "@type": "GeoCoordinates", latitude: arena.latitude, longitude: arena.longitude }
      : undefined,
    amenityFeature: amenities.map((a) => ({
      "@type": "LocationFeatureSpecification",
      name: a.label,
      value: true,
    })),
  };

  const brandStyle = { ["--ms-brand" as string]: brand, ["--ms-brand-ink" as string]: brandInk } as React.CSSProperties;

  return (
    <main className="ms" style={brandStyle}>
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }} />

      {/* HERO — full-bleed cover */}
      <section className="ms-hero">
        {cover ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img src={cover} alt={arena.name} className="ms-hero-img" />
        ) : (
          <div className="ms-hero-img ms-hero-fallback" />
        )}
        <div className="ms-hero-shade" aria-hidden="true" />
        <div className="ms-hero-overlay">
          <h1 className="ms-hero-name">{arena.name}</h1>
          {arena.tagline && <p className="ms-hero-tag">{arena.tagline}</p>}
          {locationLine && <p className="ms-hero-loc">{locationLine}</p>}
        </div>
      </section>

      <article className="ms-shell">
        {/* LEFT RAIL: identity + links */}
        <aside className="ms-rail">
          <header className="ms-id">
            {arena.logoUrl && (
              // eslint-disable-next-line @next/next/no-img-element
              <img src={arena.logoUrl} alt={`${arena.name} logo`} className="ms-logo" />
            )}
            <h2 className="ms-name">{arena.name}</h2>
            {arena.tagline && <p className="ms-tag">{arena.tagline}</p>}
            <div className="ms-meta">
              {locationLine && <span>{locationLine}</span>}
              {hoursLine && <span className="ms-meta-dot">{hoursLine}</span>}
            </div>
            {sports.length > 0 && (
              <div className="ms-sports">
                {sports.map((s) => (
                  <span key={s} className="ms-pill">{sportLabel(s)}</span>
                ))}
              </div>
            )}
          </header>

          <LinkCards
            units={units}
            arenaId={arena.id}
            arenaSlug={slug}
            apiBaseUrl={API}
            arenaName={arena.name}
            address={fullAddress || locationLine || undefined}
            latitude={arena.latitude}
            longitude={arena.longitude}
            phone={arena.phone}
            openTime={arenaOpenTime}
            closeTime={arenaCloseTime}
            micrositeLinks={arena.micrositeLinks ?? null}
          />

          {units.length === 0 && (
            <div className="ms-empty">
              Online booking not live yet.{arena.phone ? ` Call ${arena.phone} to reserve.` : ""}
            </div>
          )}
        </aside>

        {/* RIGHT BODY: gallery, about, amenities, map */}
        <section className="ms-body">
          {galleryPhotos.length > 0 && (
            <section className="ms-section">
              <h3 className="ms-h">Photos</h3>
              <div className="ms-gallery">
                <PhotoCarousel photos={galleryPhotos} alt={arena.name} />
              </div>
            </section>
          )}

          {arena.description && (
            <section className="ms-section">
              <h3 className="ms-h">About</h3>
              <p className="ms-prose">{arena.description}</p>
            </section>
          )}

          {amenities.length > 0 && (
            <section className="ms-section">
              <h3 className="ms-h">Amenities</h3>
              <div className="ms-amen">
                {amenities.map((a) => (
                  <div key={a.label} className="ms-amen-tile">
                    <span className="ms-amen-icon">{a.icon}</span>
                    <span className="ms-amen-label">{a.label}</span>
                  </div>
                ))}
              </div>
            </section>
          )}

          {(hoursLine || fullAddress) && (
            <section className="ms-section">
              <h3 className="ms-h">Visit</h3>
              <dl className="ms-facts">
                {hoursLine && (
                  <>
                    <dt>Hours</dt>
                    <dd>{hoursLine}</dd>
                  </>
                )}
                {fullAddress && (
                  <>
                    <dt>Address</dt>
                    <dd>{fullAddress}</dd>
                  </>
                )}
                {arena.phone && (
                  <>
                    <dt>Phone</dt>
                    <dd><a href={`tel:${arena.phone}`}>{arena.phone}</a></dd>
                  </>
                )}
              </dl>
            </section>
          )}

          {arena.latitude && arena.longitude && (
            <section className="ms-section">
              <h3 className="ms-h">Find us</h3>
              <a
                className="ms-map"
                href={`https://www.google.com/maps/dir/?api=1&destination=${arena.latitude},${arena.longitude}`}
                target="_blank"
                rel="noopener noreferrer"
              >
                <iframe
                  title={`${arena.name} on map`}
                  src={`https://www.google.com/maps?q=${arena.latitude},${arena.longitude}&hl=en&z=15&output=embed`}
                  loading="lazy"
                  referrerPolicy="no-referrer-when-downgrade"
                />
                <span className="ms-map-cta">Open in Maps →</span>
              </a>
            </section>
          )}
        </section>
      </article>

      <footer className="ms-foot">
        <span>Powered by <a href="https://www.swingcricketapp.com" target="_blank" rel="noopener noreferrer">Swing</a></span>
      </footer>

      <style>{`
        :root, [data-theme="light"] {
          --ms-bg:      #FAFAF7;
          --ms-surface: #FFFFFF;
          --ms-ink:     #0A0B0A;
          --ms-muted:   rgba(10,11,10,0.58);
          --ms-line:    rgba(10,11,10,0.12);
          --ms-line-2:  rgba(10,11,10,0.06);
        }
        [data-theme="dark"] {
          --ms-bg:      #0B0C0B;
          --ms-surface: #131413;
          --ms-ink:     #F4F4F1;
          --ms-muted:   rgba(244,244,241,0.58);
          --ms-line:    rgba(244,244,241,0.14);
          --ms-line-2:  rgba(244,244,241,0.07);
        }

        html, body { background: var(--ms-bg); }

        .ms {
          min-height: 100svh;
          background: var(--ms-bg);
          color: var(--ms-ink);
          font-family: var(--font-geist-sans, "Inter Tight", system-ui, sans-serif);
        }

        /* ─── HERO ────────────────────────────────────────────────────── */
        .ms-hero {
          position: relative;
          width: 100%;
          height: 56vh;
          min-height: 320px;
          max-height: 620px;
          overflow: hidden;
          background: var(--ms-line-2);
        }
        .ms-hero-img {
          position: absolute; inset: 0;
          width: 100%; height: 100%;
          object-fit: cover;
          display: block;
        }
        .ms-hero-fallback {
          background:
            radial-gradient(120% 90% at 20% 10%, var(--ms-brand) 0%, transparent 60%),
            radial-gradient(120% 90% at 80% 100%, var(--ms-ink) 0%, transparent 60%),
            var(--ms-bg);
          opacity: 0.85;
        }
        .ms-hero-shade {
          position: absolute; inset: 0;
          background: linear-gradient(to bottom, transparent 30%, rgba(0,0,0,0.65) 100%);
        }
        .ms-hero-overlay {
          position: absolute;
          left: 0; right: 0; bottom: 0;
          padding: 32px 22px;
          color: #fff;
          display: flex; flex-direction: column; gap: 8px;
        }
        .ms-hero-name {
          margin: 0;
          font-size: clamp(34px, 9vw, 64px);
          font-weight: 800;
          line-height: 1.0;
          letter-spacing: -0.035em;
        }
        .ms-hero-tag {
          margin: 0;
          font-size: clamp(14px, 2vw, 17px);
          font-weight: 500;
          opacity: 0.92;
          max-width: 540px;
          line-height: 1.35;
        }
        .ms-hero-loc {
          margin: 4px 0 0;
          font-size: 12px;
          font-weight: 600;
          letter-spacing: 0.14em;
          text-transform: uppercase;
          opacity: 0.85;
        }

        /* ─── SHELL (mobile = single column, desktop = 2-col magazine) ── */
        .ms-shell {
          display: grid;
          grid-template-columns: 1fr;
          max-width: 1240px;
          margin: -60px auto 0;
          padding: 0 18px 24px;
          gap: 28px;
          position: relative;
          z-index: 1;
        }
        @media (min-width: 960px) {
          .ms-shell {
            grid-template-columns: minmax(320px, 380px) minmax(0, 1fr);
            gap: 56px;
            margin-top: -90px;
            padding: 0 36px 36px;
          }
        }

        /* ─── LEFT RAIL ──────────────────────────────────────────────── */
        .ms-rail {
          display: flex;
          flex-direction: column;
          gap: 20px;
        }
        @media (min-width: 960px) {
          .ms-rail {
            position: sticky;
            top: 24px;
            align-self: start;
            max-height: calc(100vh - 48px);
            overflow-y: auto;
            padding-right: 4px;
            scrollbar-width: thin;
          }
          .ms-rail::-webkit-scrollbar { width: 4px; }
          .ms-rail::-webkit-scrollbar-thumb { background: var(--ms-line); border-radius: 4px; }
        }

        .ms-id {
          background: var(--ms-surface);
          padding: 22px;
          display: flex;
          flex-direction: column;
          gap: 8px;
          border: 1px solid var(--ms-line);
        }
        .ms-logo {
          width: 64px; height: 64px;
          object-fit: cover;
          margin-top: -52px;
          margin-bottom: 4px;
          background: var(--ms-surface);
          border: 3px solid var(--ms-surface);
          box-shadow: 0 2px 10px rgba(0,0,0,0.15);
        }
        .ms-name {
          margin: 0;
          font-size: clamp(22px, 4vw, 26px);
          font-weight: 800;
          letter-spacing: -0.02em;
          line-height: 1.1;
        }
        /* On desktop, name is already huge in hero — keep rail subdued */
        @media (min-width: 960px) {
          .ms-name { font-size: 22px; }
        }
        .ms-tag {
          margin: 0;
          font-size: 14px;
          line-height: 1.4;
          color: var(--ms-muted);
        }
        .ms-meta {
          display: flex;
          flex-wrap: wrap;
          gap: 6px 14px;
          margin-top: 2px;
          font-size: 12px;
          font-weight: 600;
          letter-spacing: 0.08em;
          text-transform: uppercase;
          color: var(--ms-muted);
        }
        .ms-meta-dot::before {
          content: "·";
          margin-right: 12px;
          color: var(--ms-line);
        }
        .ms-meta-dot:first-child::before { content: none; }
        .ms-sports {
          display: flex;
          flex-wrap: wrap;
          gap: 6px;
          margin-top: 8px;
        }
        .ms-pill {
          font-size: 11px;
          font-weight: 700;
          letter-spacing: 0.08em;
          text-transform: uppercase;
          padding: 4px 10px;
          background: var(--ms-line-2);
          color: var(--ms-ink);
        }

        /* ─── LINK CARDS (linktree-style) ────────────────────────────── */
        .ms-links {
          display: flex;
          flex-direction: column;
          gap: 10px;
        }
        .ms-card {
          all: unset;
          cursor: pointer;
          display: flex;
          align-items: center;
          gap: 14px;
          padding: 16px 18px;
          background: var(--ms-surface);
          border: 1px solid var(--ms-line);
          color: var(--ms-ink);
          transition: transform 0.12s ease, border-color 0.12s ease, background 0.12s ease;
          text-decoration: none;
        }
        .ms-card:hover {
          border-color: var(--ms-ink);
          transform: translateY(-1px);
        }
        .ms-card-icon {
          flex: 0 0 auto;
          width: 36px; height: 36px;
          display: inline-grid; place-items: center;
          border: 1px solid var(--ms-line);
          color: var(--ms-ink);
        }
        .ms-card-icon svg { width: 18px; height: 18px; }
        .ms-card-label {
          flex: 1;
          font-size: 15px;
          font-weight: 700;
          letter-spacing: -0.005em;
        }
        .ms-card-arrow {
          flex: 0 0 auto;
          font-size: 18px;
          color: var(--ms-muted);
          transition: transform 0.15s ease;
        }
        .ms-card:hover .ms-card-arrow {
          transform: translateX(3px);
          color: var(--ms-ink);
        }
        .ms-card-primary {
          background: var(--ms-brand);
          color: var(--ms-brand-ink);
          border-color: var(--ms-brand);
        }
        .ms-card-primary .ms-card-icon {
          border-color: rgba(255,255,255,0.35);
          color: var(--ms-brand-ink);
        }
        .ms-card-primary .ms-card-arrow {
          color: var(--ms-brand-ink);
          opacity: 0.85;
        }
        .ms-card-primary:hover {
          filter: brightness(0.94);
          border-color: var(--ms-brand);
        }

        .ms-empty {
          padding: 16px 18px;
          background: var(--ms-surface);
          border: 1px dashed var(--ms-line);
          color: var(--ms-muted);
          font-size: 14px;
          line-height: 1.45;
        }

        /* ─── BODY SECTIONS ──────────────────────────────────────────── */
        .ms-body {
          display: flex;
          flex-direction: column;
          gap: 28px;
        }
        .ms-section {
          background: var(--ms-surface);
          border: 1px solid var(--ms-line);
          padding: 22px 22px 26px;
        }
        .ms-h {
          margin: 0 0 14px;
          font-size: 11px;
          font-weight: 800;
          letter-spacing: 0.2em;
          text-transform: uppercase;
          color: var(--ms-muted);
        }
        .ms-prose {
          margin: 0;
          font-size: 15px;
          line-height: 1.55;
          color: var(--ms-ink);
          white-space: pre-wrap;
        }
        .ms-gallery {
          aspect-ratio: 16 / 10;
          width: 100%;
          overflow: hidden;
          background: var(--ms-line-2);
        }
        .ms-gallery > * { height: 100%; }

        .ms-amen {
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(118px, 1fr));
          gap: 8px;
        }
        .ms-amen-tile {
          display: flex;
          align-items: center;
          gap: 10px;
          padding: 12px 14px;
          border: 1px solid var(--ms-line);
        }
        .ms-amen-icon {
          width: 22px; height: 22px;
          display: inline-grid; place-items: center;
          color: var(--ms-brand);
        }
        .ms-amen-icon svg { width: 20px; height: 20px; }
        .ms-amen-label {
          font-size: 13px;
          font-weight: 600;
          letter-spacing: -0.005em;
        }

        .ms-facts {
          margin: 0;
          display: grid;
          grid-template-columns: 110px 1fr;
          gap: 10px 18px;
          font-size: 14px;
        }
        .ms-facts dt {
          font-size: 11px;
          font-weight: 700;
          letter-spacing: 0.16em;
          text-transform: uppercase;
          color: var(--ms-muted);
          align-self: center;
        }
        .ms-facts dd { margin: 0; color: var(--ms-ink); }
        .ms-facts a { color: var(--ms-ink); text-decoration: underline; text-underline-offset: 3px; }

        .ms-map {
          display: block;
          position: relative;
          aspect-ratio: 16 / 9;
          width: 100%;
          overflow: hidden;
          background: var(--ms-line-2);
          color: var(--ms-ink);
          text-decoration: none;
        }
        .ms-map iframe {
          width: 100%; height: 100%; border: 0; display: block;
          pointer-events: none;
        }
        .ms-map-cta {
          position: absolute;
          right: 14px; bottom: 14px;
          padding: 8px 12px;
          background: var(--ms-surface);
          border: 1px solid var(--ms-line);
          font-size: 12px;
          font-weight: 700;
          letter-spacing: 0.04em;
          color: var(--ms-ink);
        }

        /* ─── FOOTER ─────────────────────────────────────────────────── */
        .ms-foot {
          text-align: center;
          padding: 24px 18px 36px;
          font-size: 11px;
          font-weight: 600;
          letter-spacing: 0.18em;
          text-transform: uppercase;
          color: var(--ms-muted);
        }
        .ms-foot a {
          color: var(--ms-ink);
          text-decoration: underline;
          text-underline-offset: 3px;
        }

        /* ─── small screens — tighter hero overlay padding ───────────── */
        @media (max-width: 540px) {
          .ms-hero { height: 52vh; min-height: 280px; }
          .ms-hero-overlay { padding: 22px 18px; }
          .ms-id { padding: 18px; }
          .ms-section { padding: 18px 18px 22px; }
        }
      `}</style>
    </main>
  );
}
