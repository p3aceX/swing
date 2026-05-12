import type { Metadata } from "next";
import { notFound } from "next/navigation";
import LinkCards from "./_link-cards";
import ThemeToggle from "./_theme-toggle";

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
  return ["Book instantly", unitLabel, sports, location].filter(Boolean).join(" · ") + ". Live availability, secure payments.";
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
    ? [{ url: photo, width: 1200, height: 630, alt: `${arena.name}` }]
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
    robots: { index: true, follow: true, googleBot: { index: true, follow: true, "max-image-preview": "large", "max-snippet": -1 } },
    openGraph: { title, description, url: `/arena/${canonicalSlug}`, siteName: arena.name, images: image, type: "website" },
    twitter: { card: "summary_large_image", title, description, images: image.map((i) => i.url) },
  };
}

// Inline theme boot — runs before paint to avoid light/dark flash.
const THEME_BOOT = `(function(){try{var t=localStorage.getItem('arena-theme');if(t!=='light'&&t!=='dark'){t=window.matchMedia&&window.matchMedia('(prefers-color-scheme: dark)').matches?'dark':'light';}document.documentElement.setAttribute('data-theme',t);}catch(e){}})();`;

export default async function ArenaPage({ params }: PageProps) {
  const { slug } = await params;
  const arena = await fetchArena(slug);
  if (!arena) notFound();

  const units = arena.units ?? [];
  const photos = arena.photoUrls?.filter(Boolean) ?? [];
  const coverIdx = Math.min(Math.max(arena.coverPhotoIndex ?? 0, 0), Math.max(photos.length - 1, 0));
  const cover = photos[coverIdx] ?? null;
  const insidePhotos = photos.filter((_, i) => i !== coverIdx);
  const sports = (arena.sports ?? []).filter(Boolean);
  const fullAddress = [arena.address, arena.city, arena.state].filter(Boolean).join(", ");
  const locationLine = [arena.city, arena.state].filter(Boolean).join(", ");

  const brand = arena.brandColor && /^#[0-9a-fA-F]{6}$/.test(arena.brandColor) ? arena.brandColor : "#16A34A";
  const brandInk = readableInk(brand);

  const sv = { width: 24, height: 24, viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", strokeWidth: 1.5, strokeLinecap: "round" as const, strokeLinejoin: "round" as const };
  const amenities = [
    arena.hasLights    && { label: "Floodlights", icon: <svg {...sv}><path d="M12 2v3M5 5l2 2M19 5l-2 2M3 12h3M18 12h3M9 18h6M10 21h4"/><circle cx="12" cy="12" r="4"/></svg> },
    arena.hasParking   && { label: "Parking",     icon: <svg {...sv}><rect x="4" y="4" width="16" height="16" rx="2"/><path d="M9 17V8h4a3 3 0 0 1 0 6H9"/></svg> },
    arena.hasWashrooms && { label: "Washrooms",   icon: <svg {...sv}><circle cx="8" cy="5" r="2"/><circle cx="16" cy="5" r="2"/><path d="M6 22V12l-2-3 4-2h0l2 3v6m6 6V12l2-3-4-2h0l-2 3v6"/></svg> },
    arena.hasCanteen   && { label: "Canteen",     icon: <svg {...sv}><path d="M3 2v9a2 2 0 0 0 4 0V2M5 12v10M17 2c-2 0-4 2-4 5v5h3v10"/></svg> },
    arena.hasCCTV      && { label: "CCTV",        icon: <svg {...sv}><rect x="2" y="6" width="14" height="12" rx="1"/><path d="M16 10l6-2v8l-6-2"/></svg> },
    arena.hasScorer    && { label: "Live scoring",icon: <svg {...sv}><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M9 8v8M15 8v8M3 12h18"/></svg> },
  ].filter(Boolean) as { label: string; icon: React.ReactElement }[];

  const toMins = (t: string) => { const [h, m] = t.split(":").map(Number); return h * 60 + (m || 0); };
  const unitOpenTimes  = units.map((u) => u.openTime).filter(Boolean) as string[];
  const unitCloseTimes = units.map((u) => u.closeTime).filter(Boolean) as string[];
  const arenaOpenTime  = unitOpenTimes.length  ? unitOpenTimes.reduce ((a, b) => toMins(a) <= toMins(b) ? a : b) : arena.openTime  ?? null;
  const arenaCloseTime = unitCloseTimes.length ? unitCloseTimes.reduce((a, b) => toMins(a) >= toMins(b) ? a : b) : arena.closeTime ?? null;

  const hoursLine = arenaOpenTime && arenaCloseTime
    ? `${fmt12Short(arenaOpenTime)} – ${fmt12Short(arenaCloseTime)}`
    : arenaOpenTime ? `Opens ${fmt12Short(arenaOpenTime)}` : null;

  // "Open now" check (best-effort, based on IST-ish local time)
  const nowMin = (() => { const d = new Date(); return d.getHours() * 60 + d.getMinutes(); })();
  const openNow = !!(arenaOpenTime && arenaCloseTime && nowMin >= toMins(arenaOpenTime) && nowMin <= toMins(arenaCloseTime));

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
    amenityFeature: amenities.map((a) => ({ "@type": "LocationFeatureSpecification", name: a.label, value: true })),
  };

  const brandStyle = { ["--ms-brand" as string]: brand, ["--ms-brand-ink" as string]: brandInk } as React.CSSProperties;
  const year = new Date().getFullYear();

  // Sections that will actually render — used for the eyebrow numbering.
  const sectionList: string[] = [];
  if (insidePhotos.length > 0) sectionList.push("inside");
  if (arena.description) sectionList.push("about");
  if (amenities.length > 0) sectionList.push("amenities");
  if (hoursLine || fullAddress || arena.phone) sectionList.push("visit");
  const num = (key: string) => {
    const idx = sectionList.indexOf(key);
    return idx < 0 ? "00" : String(idx + 1).padStart(2, "0");
  };

  return (
    <main className="ms" style={brandStyle}>
      {/* No-FOUC theme boot — runs as soon as it parses. */}
      <script dangerouslySetInnerHTML={{ __html: THEME_BOOT }} />
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }} />

      {/* ─── TOP BAR ────────────────────────────────────────────────── */}
      <header className="ms-top">
        <span className="ms-top-mark">
          {locationLine ? <>{locationLine.toUpperCase()}</> : "INDIA"}
          {sports.length > 0 && <em> · {sports.map(sportLabel).join(" · ")}</em>}
        </span>
        <ThemeToggle />
      </header>

      {/* ─── HERO ───────────────────────────────────────────────────── */}
      <section className="ms-hero" aria-label={`${arena.name} cover`}>
        {cover ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img src={cover} alt={arena.name} className="ms-hero-img" />
        ) : (
          <div className="ms-hero-img ms-hero-fallback" aria-hidden="true" />
        )}
        <div className="ms-hero-shade" aria-hidden="true" />
        <div className="ms-hero-overlay">
          <div className="ms-hero-status">
            <span className={`ms-dot ${openNow ? "is-open" : ""}`} aria-hidden="true" />
            <span>{openNow ? "Open now" : hoursLine ? "Closed" : "Hours unlisted"}</span>
            {hoursLine && <span className="ms-hero-status-sep">·</span>}
            {hoursLine && <span>{hoursLine}</span>}
          </div>
          <h1 className="ms-hero-name">{arena.name}</h1>
          {arena.tagline && <p className="ms-hero-tag">{arena.tagline}</p>}
        </div>
      </section>

      {/* ─── BOOK & CONTACT (under hero) ─────────────────────────────── */}
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
        <div className="ms-emptywrap">
          <p className="ms-empty">
            Online booking isn&apos;t live yet at {arena.name}.
            {arena.phone ? <> Call <a href={`tel:${arena.phone}`}>{arena.phone}</a> to reserve a slot.</> : null}
          </p>
        </div>
      )}

      {/* ─── INSIDE (photos 2 & 3 — cover already shown above) ───────── */}
      {insidePhotos.length > 0 && (
        <section className="ms-sec" id="inside">
          <header className="ms-h">
            <span className="ms-h-num">{num("inside")}</span>
            <span className="ms-h-title">Inside</span>
            <span className="ms-h-rule" aria-hidden="true" />
            <span className="ms-h-count">{photos.length} {photos.length === 1 ? "photo" : "photos"}</span>
          </header>
          <div className={`ms-spread spread-${insidePhotos.length}`}>
            {insidePhotos.map((src, i) => (
              // eslint-disable-next-line @next/next/no-img-element
              <a key={src + i} className="ms-spread-cell" href={src} target="_blank" rel="noopener noreferrer">
                <img src={src} alt={`${arena.name} photo ${i + 2}`} />
              </a>
            ))}
          </div>
        </section>
      )}

      {/* ─── ABOUT ──────────────────────────────────────────────────── */}
      {arena.description && (
        <section className="ms-sec" id="about">
          <header className="ms-h">
            <span className="ms-h-num">{num("about")}</span>
            <span className="ms-h-title">About</span>
            <span className="ms-h-rule" aria-hidden="true" />
          </header>
          <div className="ms-prose-wrap">
            <p className="ms-prose">{arena.description}</p>
          </div>
        </section>
      )}

      {/* ─── AMENITIES ──────────────────────────────────────────────── */}
      {amenities.length > 0 && (
        <section className="ms-sec" id="amenities">
          <header className="ms-h">
            <span className="ms-h-num">{num("amenities")}</span>
            <span className="ms-h-title">Amenities</span>
            <span className="ms-h-rule" aria-hidden="true" />
          </header>
          <ul className="ms-amen">
            {amenities.map((a) => (
              <li key={a.label} className="ms-amen-row">
                <span className="ms-amen-icon" aria-hidden="true">{a.icon}</span>
                <span className="ms-amen-label">{a.label}</span>
              </li>
            ))}
          </ul>
        </section>
      )}

      {/* ─── VISIT (hours + address + map) ──────────────────────────── */}
      {(hoursLine || fullAddress || arena.phone) && (
        <section className="ms-sec" id="visit">
          <header className="ms-h">
            <span className="ms-h-num">{num("visit")}</span>
            <span className="ms-h-title">Visit</span>
            <span className="ms-h-rule" aria-hidden="true" />
          </header>
          <dl className="ms-facts">
            {hoursLine && (<><dt>Hours</dt><dd>{hoursLine}</dd></>)}
            {fullAddress && (<><dt>Address</dt><dd>{fullAddress}</dd></>)}
            {arena.phone && (<><dt>Phone</dt><dd><a href={`tel:${arena.phone}`}>{arena.phone}</a></dd></>)}
          </dl>

          {arena.latitude && arena.longitude && (
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
              <span className="ms-map-cta">Open in Maps  →</span>
            </a>
          )}
        </section>
      )}

      {/* ─── FOOTER ─────────────────────────────────────────────────── */}
      <footer className="ms-foot">
        <div className="ms-foot-line">
          <span className="ms-foot-name">{arena.name.toUpperCase()}</span>
          <span className="ms-foot-rule" aria-hidden="true" />
          <span className="ms-foot-year">© {year}</span>
        </div>
        <div className="ms-foot-credit">
          Powered by <a href="https://www.swingcricketapp.com" target="_blank" rel="noopener noreferrer">Swing</a>
        </div>
      </footer>

      {/* ─── STYLES ─────────────────────────────────────────────────── */}
      <style>{`
        /* ─── THEME TOKENS ────────────────────────────────────────── */
        :root {
          --ms-bg:           #FAFAF7;
          --ms-bg-soft:      #F2EFE8;
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
          --ms-bg-soft:      #131413;
          --ms-surface:      #131413;
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

        .ms {
          min-height: 100svh;
          background: var(--ms-bg);
          color: var(--ms-ink);
          font-family: var(--font-geist-sans, "Inter Tight", system-ui, sans-serif);
          padding-bottom: env(safe-area-inset-bottom, 0);
          -webkit-font-smoothing: antialiased;
        }

        /* ─── TOP BAR ─────────────────────────────────────────────── */
        .ms-top {
          position: relative;
          z-index: 5;
          display: flex;
          align-items: center;
          justify-content: space-between;
          gap: 12px;
          padding: 14px 22px;
          border-bottom: 1px solid var(--ms-line);
          font-family: var(--font-geist-mono, ui-monospace, Menlo, monospace);
          font-size: 11px;
          font-weight: 600;
          letter-spacing: 0.18em;
          color: var(--ms-muted);
          background: var(--ms-bg);
        }
        .ms-top-mark { min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .ms-top-mark em { font-style: normal; color: var(--ms-soft); }

        .ms-theme {
          all: unset;
          flex: 0 0 auto;
          width: 36px; height: 36px;
          display: inline-grid; place-items: center;
          cursor: pointer;
          color: var(--ms-ink);
          border: 1px solid var(--ms-line-strong);
          transition: background 0.12s ease, border-color 0.12s ease;
        }
        .ms-theme:hover { background: var(--ms-line); }
        .ms-theme-icon { display: inline-flex; }

        /* ─── HERO ────────────────────────────────────────────────── */
        .ms-hero {
          position: relative;
          width: 100%;
          height: clamp(560px, 86vh, 880px);
          overflow: hidden;
          background: var(--ms-bg-soft);
          isolation: isolate;
        }
        .ms-hero-img {
          position: absolute; inset: 0;
          width: 100%; height: 100%;
          object-fit: cover;
          display: block;
          animation: ms-ken 1.6s ease-out both;
        }
        @keyframes ms-ken {
          from { transform: scale(1.06); }
          to   { transform: scale(1.00); }
        }
        .ms-hero-fallback {
          background:
            radial-gradient(120% 90% at 18% 8%, var(--ms-brand) 0%, transparent 55%),
            radial-gradient(140% 100% at 90% 100%, color-mix(in srgb, var(--ms-ink) 88%, transparent) 0%, transparent 60%),
            var(--ms-bg-soft);
          opacity: 0.92;
        }
        .ms-hero-shade {
          position: absolute; inset: 0;
          background: linear-gradient(180deg, rgba(0,0,0,0.05) 0%, rgba(0,0,0,0.0) 40%, rgba(0,0,0,0.78) 100%);
        }
        .ms-hero-overlay {
          position: absolute;
          left: 0; right: 0; bottom: 0;
          padding: 28px 22px 36px;
          color: #fff;
          display: flex;
          flex-direction: column;
          gap: 14px;
        }
        @media (min-width: 720px) {
          .ms-hero-overlay { padding: 36px 40px 44px; gap: 18px; }
        }
        .ms-hero-status {
          display: inline-flex;
          align-items: center;
          gap: 8px;
          font-family: var(--font-geist-mono, ui-monospace, Menlo, monospace);
          font-size: 11px;
          font-weight: 600;
          letter-spacing: 0.18em;
          text-transform: uppercase;
          opacity: 0.94;
        }
        .ms-hero-status-sep { opacity: 0.55; margin: 0 2px; }
        .ms-dot {
          width: 8px; height: 8px; border-radius: 50%;
          background: var(--ms-soft);
        }
        .ms-dot.is-open {
          background: var(--ms-brand);
          box-shadow: 0 0 0 4px color-mix(in srgb, var(--ms-brand) 30%, transparent);
          animation: ms-pulse 1.8s ease-in-out infinite;
        }
        @keyframes ms-pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.55; } }

        .ms-hero-name {
          margin: 0;
          font-size: clamp(44px, 11vw, 124px);
          font-weight: 800;
          line-height: 0.94;
          letter-spacing: -0.045em;
          text-wrap: balance;
        }
        .ms-hero-tag {
          margin: 0;
          font-size: clamp(16px, 2.2vw, 22px);
          line-height: 1.32;
          font-weight: 400;
          max-width: 640px;
          opacity: 0.94;
          text-wrap: balance;
        }

        /* ─── SENTINEL (sticky bar trigger) ───────────────────────── */
        .ms-sentinel { width: 100%; height: 1px; }

        /* ─── ACTIONS (under hero) ────────────────────────────────── */
        .ms-actions {
          display: grid;
          grid-template-columns: 1fr;
          gap: 0;
          border-bottom: 1px solid var(--ms-line);
        }
        @media (min-width: 720px) {
          .ms-actions {
            grid-template-columns: 2fr 1fr 1fr;
          }
        }
        .ms-act {
          all: unset;
          cursor: pointer;
          display: flex;
          align-items: center;
          justify-content: space-between;
          gap: 14px;
          padding: 22px 26px;
          color: var(--ms-ink);
          background: var(--ms-bg);
          border-top: 1px solid var(--ms-line);
          transition: background 0.14s ease, color 0.14s ease;
        }
        @media (min-width: 720px) {
          .ms-act { border-top: 0; border-right: 1px solid var(--ms-line); padding: 26px 30px; }
          .ms-act:last-child { border-right: 0; }
        }
        .ms-act:hover { background: var(--ms-line); }
        .ms-act-label {
          font-size: 17px;
          font-weight: 600;
          letter-spacing: -0.005em;
        }
        .ms-act-arrow {
          font-size: 22px;
          opacity: 0.9;
          transition: transform 0.18s ease;
        }
        .ms-act:hover .ms-act-arrow { transform: translateX(4px); }
        .ms-act-icon {
          width: 22px; height: 22px;
          display: inline-flex; align-items: center;
          color: var(--ms-muted);
        }
        .ms-act-icon svg { width: 20px; height: 20px; }

        .ms-act-primary {
          background: var(--ms-brand);
          color: var(--ms-brand-ink);
        }
        .ms-act-primary:hover { background: var(--ms-brand); filter: brightness(0.94); }
        .ms-act-primary .ms-act-icon { color: inherit; }
        .ms-act-primary .ms-act-label { font-size: 19px; font-weight: 700; }

        /* ─── ELSEWHERE (owner custom links) ──────────────────────── */
        .ms-elsewhere {
          list-style: none;
          margin: 0;
          padding: 0;
          border-bottom: 1px solid var(--ms-line);
        }
        .ms-else-row {
          display: flex;
          align-items: center;
          gap: 16px;
          padding: 18px 26px;
          color: var(--ms-ink);
          text-decoration: none;
          border-top: 1px solid var(--ms-line);
          transition: background 0.12s ease;
        }
        .ms-else-row:hover { background: var(--ms-line); }
        .ms-else-icon {
          width: 22px; height: 22px;
          display: inline-grid; place-items: center;
          color: var(--ms-muted);
        }
        .ms-else-icon svg { width: 20px; height: 20px; }
        .ms-else-label {
          flex: 1;
          font-size: 15px;
          font-weight: 600;
        }
        .ms-else-arrow {
          font-size: 18px;
          color: var(--ms-soft);
          transition: transform 0.18s ease, color 0.18s ease;
        }
        .ms-else-row:hover .ms-else-arrow { transform: translateX(3px); color: var(--ms-ink); }

        /* ─── EMPTY (no units) ────────────────────────────────────── */
        .ms-emptywrap {
          padding: 24px 26px;
          border-bottom: 1px solid var(--ms-line);
        }
        .ms-empty {
          margin: 0;
          font-size: 15px;
          line-height: 1.5;
          color: var(--ms-muted);
        }
        .ms-empty a { color: var(--ms-ink); }

        /* ─── SECTION (editorial header + body) ───────────────────── */
        .ms-sec {
          padding: 48px 22px 24px;
          border-bottom: 1px solid var(--ms-line);
        }
        @media (min-width: 720px) {
          .ms-sec { padding: 60px 40px 36px; }
        }
        .ms-h {
          display: flex;
          align-items: center;
          gap: 16px;
          margin: 0 0 28px;
        }
        .ms-h-num {
          font-family: var(--font-geist-mono, ui-monospace, Menlo, monospace);
          font-size: 11px;
          font-weight: 600;
          letter-spacing: 0.18em;
          color: var(--ms-muted);
        }
        .ms-h-title {
          font-size: 14px;
          font-weight: 700;
          letter-spacing: 0.16em;
          text-transform: uppercase;
          color: var(--ms-ink);
        }
        .ms-h-rule {
          flex: 1;
          height: 1px;
          background: var(--ms-line);
        }
        .ms-h-count {
          font-family: var(--font-geist-mono, ui-monospace, Menlo, monospace);
          font-size: 11px;
          font-weight: 600;
          letter-spacing: 0.18em;
          color: var(--ms-muted);
        }

        /* ─── INSIDE (photo spread) ───────────────────────────────── */
        .ms-spread {
          display: grid;
          gap: 14px;
        }
        .spread-1 { grid-template-columns: 1fr; }
        .spread-2 {
          grid-template-columns: 1fr;
        }
        @media (min-width: 720px) {
          .spread-2 { grid-template-columns: 1fr 1fr; }
        }
        .ms-spread-cell {
          display: block;
          aspect-ratio: 4 / 3;
          overflow: hidden;
          background: var(--ms-bg-soft);
        }
        .spread-1 .ms-spread-cell { aspect-ratio: 16 / 9; }
        .ms-spread-cell img {
          width: 100%; height: 100%;
          object-fit: cover;
          display: block;
          transition: transform 0.6s cubic-bezier(0.2, 0.7, 0.2, 1);
        }
        .ms-spread-cell:hover img { transform: scale(1.04); }

        /* ─── ABOUT ───────────────────────────────────────────────── */
        .ms-prose-wrap { max-width: 720px; }
        .ms-prose {
          margin: 0;
          font-size: 17px;
          line-height: 1.62;
          letter-spacing: -0.003em;
          color: var(--ms-ink);
          white-space: pre-wrap;
        }

        /* ─── AMENITIES ───────────────────────────────────────────── */
        .ms-amen {
          list-style: none;
          margin: 0;
          padding: 0;
          display: grid;
          grid-template-columns: 1fr;
        }
        @media (min-width: 540px) { .ms-amen { grid-template-columns: 1fr 1fr; } }
        @media (min-width: 960px) { .ms-amen { grid-template-columns: 1fr 1fr 1fr; } }
        .ms-amen-row {
          display: flex;
          align-items: center;
          gap: 14px;
          padding: 16px 0;
          border-bottom: 1px dashed var(--ms-line);
        }
        .ms-amen-row:last-child { border-bottom: 0; }
        @media (min-width: 540px) {
          .ms-amen-row {
            padding: 18px 22px 18px 0;
          }
          .ms-amen-row + .ms-amen-row { /* keep dashed line on every row */ }
        }
        .ms-amen-icon {
          width: 26px; height: 26px;
          display: inline-grid; place-items: center;
          color: var(--ms-brand);
        }
        .ms-amen-icon svg { width: 24px; height: 24px; }
        .ms-amen-label {
          font-size: 16px;
          font-weight: 500;
          letter-spacing: -0.005em;
        }

        /* ─── VISIT ───────────────────────────────────────────────── */
        .ms-facts {
          margin: 0 0 28px;
          display: grid;
          grid-template-columns: 110px 1fr;
          gap: 18px 28px;
          max-width: 720px;
        }
        @media (min-width: 720px) { .ms-facts { grid-template-columns: 140px 1fr; } }
        .ms-facts dt {
          font-family: var(--font-geist-mono, ui-monospace, Menlo, monospace);
          font-size: 11px;
          font-weight: 600;
          letter-spacing: 0.18em;
          text-transform: uppercase;
          color: var(--ms-muted);
          align-self: start;
          padding-top: 2px;
        }
        .ms-facts dd {
          margin: 0;
          font-size: 17px;
          line-height: 1.45;
          color: var(--ms-ink);
        }
        .ms-facts dd a {
          color: var(--ms-ink);
          text-decoration: underline;
          text-decoration-color: var(--ms-soft);
          text-underline-offset: 4px;
          text-decoration-thickness: 1px;
        }
        .ms-facts dd a:hover { text-decoration-color: var(--ms-brand); }

        .ms-map {
          display: block;
          position: relative;
          aspect-ratio: 21 / 9;
          width: 100%;
          overflow: hidden;
          background: var(--ms-bg-soft);
          color: var(--ms-ink);
          text-decoration: none;
        }
        @media (max-width: 720px) { .ms-map { aspect-ratio: 4 / 3; } }
        .ms-map iframe {
          width: 100%; height: 100%; border: 0; display: block;
          pointer-events: none;
          filter: contrast(0.92) saturate(0.86);
        }
        [data-theme="dark"] .ms-map iframe {
          filter: invert(0.92) hue-rotate(180deg) contrast(0.86) saturate(0.6) brightness(1.05);
        }
        .ms-map-cta {
          position: absolute;
          right: 14px; bottom: 14px;
          padding: 10px 14px;
          background: var(--ms-bg);
          border: 1px solid var(--ms-line-strong);
          font-family: var(--font-geist-mono, ui-monospace, Menlo, monospace);
          font-size: 11px;
          font-weight: 600;
          letter-spacing: 0.16em;
          text-transform: uppercase;
          color: var(--ms-ink);
        }

        /* ─── FOOTER ─────────────────────────────────────────────── */
        .ms-foot {
          padding: 60px 22px 100px;
          display: flex;
          flex-direction: column;
          gap: 22px;
        }
        @media (min-width: 720px) {
          .ms-foot {
            padding: 80px 40px 40px;
            flex-direction: row;
            align-items: center;
            justify-content: space-between;
            gap: 32px;
          }
        }
        .ms-foot-line {
          display: flex;
          align-items: center;
          gap: 16px;
          font-family: var(--font-geist-mono, ui-monospace, Menlo, monospace);
          font-size: 11px;
          font-weight: 600;
          letter-spacing: 0.2em;
          color: var(--ms-muted);
        }
        .ms-foot-name { color: var(--ms-ink); }
        .ms-foot-rule { flex: 1; height: 1px; background: var(--ms-line); min-width: 40px; }
        .ms-foot-credit {
          font-family: var(--font-geist-mono, ui-monospace, Menlo, monospace);
          font-size: 11px;
          font-weight: 600;
          letter-spacing: 0.2em;
          text-transform: uppercase;
          color: var(--ms-muted);
        }
        .ms-foot-credit a {
          color: var(--ms-ink);
          text-decoration: underline;
          text-underline-offset: 3px;
          text-decoration-color: var(--ms-soft);
        }
        .ms-foot-credit a:hover { text-decoration-color: var(--ms-brand); }

        /* ─── STICKY BOOK BAR (mobile only) ──────────────────────── */
        .ms-stickybar {
          position: fixed;
          left: 0; right: 0; bottom: 0;
          padding: 12px 14px calc(12px + env(safe-area-inset-bottom, 0));
          background: var(--ms-bg);
          border-top: 1px solid var(--ms-line-strong);
          z-index: 800;
          animation: ms-rise 0.22s ease;
        }
        @keyframes ms-rise { from { transform: translateY(100%); } to { transform: translateY(0); } }
        @media (min-width: 720px) { .ms-stickybar { display: none; } }
        .ms-stickybar-btn {
          all: unset;
          cursor: pointer;
          width: 100%;
          display: flex;
          align-items: center;
          justify-content: space-between;
          padding: 16px 18px;
          background: var(--ms-brand);
          color: var(--ms-brand-ink);
          font-weight: 700;
          font-size: 16px;
          box-sizing: border-box;
        }
        .ms-stickybar-meta {
          font-family: var(--font-geist-mono, ui-monospace, Menlo, monospace);
          font-size: 11px;
          font-weight: 600;
          letter-spacing: 0.14em;
          text-transform: uppercase;
          opacity: 0.88;
        }
      `}</style>
    </main>
  );
}
