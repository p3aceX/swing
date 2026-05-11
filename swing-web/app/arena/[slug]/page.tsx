import type { Metadata } from "next";
import { notFound } from "next/navigation";
import BookingFlow from "./_booking-flow";
import PhotoCarousel from "./_carousel";
import DirectionsModal from "./_directions-modal";
import SiteNav from "@/app/components/SiteNav";

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

function marketingDescription(arena: Arena) {
  const location = [arena.city, arena.state].filter(Boolean).join(", ");
  const sports = (arena.sports ?? []).map(sportLabel).join(", ");
  const units = arena.units ?? [];
  const unitLabel = units.length
    ? `${units.length} ${units.length === 1 ? "play area" : "play areas"}`
    : "sports venue";
  const details = ["Best prices", "Book arena instantly", unitLabel, sports, location].filter(Boolean);
  return `${details.join(" · ")}. Reserve your slot instantly with live availability. Powered by Swing.`;
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

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { slug } = await params;
  const arena = await fetchArena(slug);

  if (!arena) return { title: "Arena not found" };

  const location = [arena.city, arena.state].filter(Boolean).join(", ");
  const sports = (arena.sports ?? []).map(sportLabel).join(", ");
  const photo = arena.photoUrls?.find(Boolean);
  const canonicalSlug = arena.customSlug ?? arena.arenaSlug ?? slug;
  const title = `Book ${arena.name}${location ? ` in ${location}` : ""} instantly`;
  const description = marketingDescription(arena);
  const image = photo
    ? [{ url: photo, width: 1200, height: 630, alt: `${arena.name} on Swing` }]
    : [{ url: "/assets/logo-light.png", width: 1200, height: 630, alt: "Swing" }];

  return {
    title,
    description,
    keywords: [
      arena.name,
      location && `${arena.name} ${location}`,
      location && `book cricket net in ${location}`,
      location && `book sports arena in ${location}`,
      sports && `${sports} booking`,
      "Swing arena booking",
      "sports venue booking",
    ].filter(Boolean) as string[],
    alternates: { canonical: `/arena/${canonicalSlug}` },
    robots: {
      index: true,
      follow: true,
      googleBot: { index: true, follow: true, "max-image-preview": "large", "max-snippet": -1 },
    },
    openGraph: { title, description, url: `/arena/${canonicalSlug}`, siteName: "Swing", images: image, type: "website" },
    twitter: { card: "summary_large_image", title, description, images: image.map((item) => item.url) },
  };
}

export default async function ArenaPage({ params }: PageProps) {
  const { slug } = await params;
  const arena = await fetchArena(slug);

  if (!arena) notFound();

  const units = arena.units ?? [];
  const photos = arena.photoUrls?.filter(Boolean) ?? [];
  const sports = (arena.sports ?? []).filter(Boolean);
  const fullAddress = [arena.address, arena.city, arena.state].filter(Boolean).join(", ");
  const locationLine = [arena.city, arena.state].filter(Boolean).join(" · ").toUpperCase() || "INDIA";

  const sv = { width: 22, height: 22, viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", strokeWidth: 1.6, strokeLinecap: "round" as const, strokeLinejoin: "round" as const };
  const amenities = [
    arena.hasLights    && { label: "LIGHTS",   icon: <svg {...sv}><path d="M12 2v3M5 5l2 2M19 5l-2 2M3 12h3M18 12h3M9 18h6M10 21h4"/><circle cx="12" cy="12" r="4"/></svg> },
    arena.hasParking   && { label: "PARKING",  icon: <svg {...sv}><rect x="4" y="4" width="16" height="16" rx="2"/><path d="M9 17V8h4a3 3 0 0 1 0 6H9"/></svg> },
    arena.hasWashrooms && { label: "WASHROOM", icon: <svg {...sv}><circle cx="8" cy="5" r="2"/><circle cx="16" cy="5" r="2"/><path d="M6 22V12l-2-3 4-2h0l2 3v6m6 6V12l2-3-4-2h0l-2 3v6"/></svg> },
    arena.hasCanteen   && { label: "CANTEEN",  icon: <svg {...sv}><path d="M3 2v9a2 2 0 0 0 4 0V2M5 12v10M17 2c-2 0-4 2-4 5v5h3v10"/></svg> },
    arena.hasCCTV      && { label: "CCTV",     icon: <svg {...sv}><rect x="2" y="6" width="14" height="12" rx="1"/><path d="M16 10l6-2v8l-6-2"/></svg> },
    arena.hasScorer    && { label: "SCORER",   icon: <svg {...sv}><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M9 8v8M15 8v8M3 12h18"/></svg> },
  ].filter(Boolean) as { label: string; icon: React.ReactElement }[];

  // Derive opening/closing from all units (earliest open, latest close)
  const toMins = (t: string) => { const [h, m] = t.split(":").map(Number); return h * 60 + (m || 0); };
  const unitOpenTimes = units.map((u) => u.openTime).filter(Boolean) as string[];
  const unitCloseTimes = units.map((u) => u.closeTime).filter(Boolean) as string[];
  const arenaOpenTime = unitOpenTimes.length
    ? unitOpenTimes.reduce((a, b) => toMins(a) <= toMins(b) ? a : b)
    : arena.openTime ?? null;
  const arenaCloseTime = unitCloseTimes.length
    ? unitCloseTimes.reduce((a, b) => toMins(a) >= toMins(b) ? a : b)
    : arena.closeTime ?? null;

  const hoursDisplay = arenaOpenTime && arenaCloseTime
    ? `${fmt12Short(arenaOpenTime)}–${fmt12Short(arenaCloseTime)}`
    : arenaOpenTime
    ? `OPENS ${fmt12Short(arenaOpenTime)}`
    : "OPEN";

  const sportTop = (sports[0] ?? "SPORTS").toUpperCase();
  const sportExtra = sports.length > 1 ? `+${sports.length - 1}` : "";

  const canonicalSlug = arena.customSlug ?? arena.arenaSlug ?? slug;
  const publicUrl = `https://www.swingcricketapp.com/arena/${canonicalSlug}`;
  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "SportsActivityLocation",
    name: arena.name,
    description: marketingDescription(arena),
    url: publicUrl,
    image: photos,
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
    amenityFeature: amenities.map((name) => ({
      "@type": "LocationFeatureSpecification",
      name,
      value: true,
    })),
  };

  return (
    <main className="pass">
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }} />
      <SiteNav />

      <article className="pass-shell">
        {/* Top barcode strip */}
        <div className="pass-strip">
          <span className="pass-brand">SWING / ARENA PASS</span>
          <span className="pass-live"><i />{hoursDisplay}</span>
        </div>

        {/* Venue photo panel */}
        {photos.length > 0 && (
          <div className="pass-photo">
            <div className="pass-photo-cap">
              <span>VENUE</span>
              <span>{String(photos.length).padStart(2, "0")} FRAME{photos.length !== 1 ? "S" : ""}</span>
            </div>
            <div className="pass-photo-frame">
              <PhotoCarousel photos={photos} alt={arena.name} />
            </div>
          </div>
        )}

        {/* Arena identity */}
        <header className="pass-id">
          <h1 className="pass-name">{arena.name}</h1>
          <div className="pass-rule" />
          <div className="pass-loc">
            <span>{locationLine}</span>
            {arena.latitude && arena.longitude && (
              <DirectionsModal
                name={arena.name}
                address={fullAddress || locationLine}
                latitude={arena.latitude}
                longitude={arena.longitude}
              />
            )}
          </div>
        </header>

        {/* Meta grid */}
        <div className="pass-meta">
          <div>
            <span className="pass-meta-label">UNITS</span>
            <span className="pass-meta-val">{String(units.length).padStart(2, "0")}</span>
          </div>
          <div>
            <span className="pass-meta-label">SPORT</span>
            <span className="pass-meta-val">{sportTop}{sportExtra && <em>{sportExtra}</em>}</span>
          </div>
          <div>
            <span className="pass-meta-label">HOURS</span>
            <span className="pass-meta-val">{hoursDisplay}</span>
          </div>
        </div>

        {amenities.length > 0 && (
          <div className="pass-amen">
            <div className="pass-amen-grid">
              {amenities.map((a) => (
                <div key={a.label} className="amen-tile">
                  <span className="amen-icon">{a.icon}</span>
                  <span className="amen-label">{a.label}</span>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Tear-line */}
        <div className="pass-tear" aria-hidden="true">
          <i className="pass-notch left" />
          <i className="pass-notch right" />
        </div>

        {/* Booking body */}
        <section className="pass-body">
          {units.length > 0 ? (
            <BookingFlow
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
            />
          ) : (
            <div className="pass-empty">
              <div className="pass-meta-label">STATUS</div>
              <div className="pass-empty-head">ONLINE BOOKING NOT LIVE</div>
              <div className="pass-empty-sub">Call the arena directly to reserve a slot.</div>
              {arena.phone && (
                <a href={`tel:${arena.phone}`} className="pass-empty-call">
                  CALL {arena.phone} ▸
                </a>
              )}
            </div>
          )}
        </section>

        {/* Bottom barcode strip */}
        <div className="pass-foot">
          <span>BOOK · PLAY · SWING</span>
          <span>{arena.phone ? `T ${arena.phone}` : "SWINGCRICKETAPP.COM"}</span>
        </div>
      </article>

      <style precedence="default">{`
        :root, [data-theme="light"] {
          --pass-paper:    #F4F2EB;
          --pass-ink:      #0A0B0A;
          --pass-muted:    rgba(10,11,10,0.42);
          --pass-line:     rgba(10,11,10,0.22);
          --pass-line-2:   rgba(10,11,10,0.10);
          --pass-accent:   #0A0B0A;
          --pass-live-dot: #C8FF3E;
        }
        [data-theme="dark"] {
          --pass-paper:    #0A0B0A;
          --pass-ink:      #F4F4F1;
          --pass-muted:    rgba(244,244,241,0.42);
          --pass-line:     rgba(244,244,241,0.22);
          --pass-line-2:   rgba(244,244,241,0.10);
          --pass-accent:   #F4F4F1;
          --pass-live-dot: #C8FF3E;
        }

        html, body { background: var(--pass-paper); }

        .pass {
          min-height: 100svh;
          background: var(--pass-paper);
          color: var(--pass-ink);
          font-family: var(--font-geist-sans, "Inter Tight", system-ui, sans-serif);
          padding-bottom: 24px;
        }

        .pass-shell {
          position: relative;
          max-width: 540px;
          margin: 8px auto 0;
          padding: 22px 24px 0;
          background: var(--pass-paper);
          isolation: isolate;
        }

        /* Desktop split: arena identity left, booking right */
        @media (min-width: 960px) {
          .pass-shell {
            max-width: 1120px;
            display: grid;
            grid-template-columns: minmax(0, 0.92fr) 1px minmax(0, 1.08fr);
            column-gap: 48px;
            padding: 32px 40px 24px;
            align-items: start;
          }
          .pass-shell > .pass-strip { grid-column: 1 / -1; grid-row: 1; }
          .pass-shell > .pass-photo  { grid-column: 1; grid-row: 2; }
          .pass-shell > .pass-id     { grid-column: 1; grid-row: 3; }
          .pass-shell > .pass-meta   { grid-column: 1; grid-row: 4; }
          .pass-shell > .pass-amen   { grid-column: 1; grid-row: 5; margin-bottom: 8px; }
          .pass-shell > .pass-tear {
            grid-column: 2;
            grid-row: 2 / span 4;
            width: 1px;
            height: auto;
            margin: 0;
            background: var(--pass-line-2);
            background-image: repeating-linear-gradient(to bottom, var(--pass-line) 0 6px, transparent 6px 12px);
          }
          .pass-shell > .pass-tear .pass-notch { display: none; }
          .pass-shell > .pass-body   { grid-column: 3; grid-row: 2 / span 4; min-height: 0; }
          .pass-shell > .pass-foot   { grid-column: 1 / -1; grid-row: 6; margin-top: 32px; }
          .pass-shell::before { left: 16px; }
          .pass-shell::after  { right: 16px; }
          .pass-photo-frame { aspect-ratio: 4 / 3; }
          .pass-amen-grid { grid-template-columns: repeat(3, 1fr); }
        }

        /* Side perforations */
        .pass-shell::before,
        .pass-shell::after {
          content: "";
          position: absolute;
          top: 12px;
          bottom: 12px;
          width: 0;
          border-left: 1px dashed var(--pass-line);
          pointer-events: none;
        }
        .pass-shell::before { left: 14px; }
        .pass-shell::after  { right: 14px; }

        /* Top barcode strip */
        .pass-strip {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding-bottom: 18px;
          font-family: var(--font-geist-mono, ui-monospace, Menlo, monospace);
          font-size: 10px;
          letter-spacing: 0.18em;
          text-transform: uppercase;
          color: var(--pass-muted);
        }
        .pass-brand {
          font-weight: 600;
          color: var(--pass-ink);
        }
        .pass-live {
          display: inline-flex;
          align-items: center;
          gap: 7px;
          color: var(--pass-ink);
          font-weight: 600;
        }
        .pass-live i {
          width: 6px;
          height: 6px;
          border-radius: 50%;
          background: var(--pass-live-dot);
          animation: passPulse 1.6s ease-in-out infinite;
        }
        @keyframes passPulse {
          0%, 100% { opacity: 1; transform: scale(1); }
          50%      { opacity: 0.5; transform: scale(0.86); }
        }

        /* Venue photo panel */
        .pass-photo {
          margin-bottom: 18px;
        }
        .pass-photo-cap {
          display: flex;
          justify-content: space-between;
          align-items: baseline;
          padding: 0 0 8px;
          font-family: var(--font-geist-mono, ui-monospace, Menlo, monospace);
          font-size: 9.5px;
          font-weight: 600;
          letter-spacing: 0.18em;
          text-transform: uppercase;
          color: var(--pass-muted);
        }
        .pass-photo-frame {
          position: relative;
          aspect-ratio: 16 / 9;
          width: 100%;
          overflow: hidden;
          border: 1px dashed var(--pass-line);
          background: var(--pass-line-2);
        }
        .pass-photo-frame > * { height: 100%; }
        /* Corner ticks — subtle "registration marks" on the photo frame */
        .pass-photo-frame::before,
        .pass-photo-frame::after {
          content: "";
          position: absolute;
          width: 10px;
          height: 10px;
          border: 1px solid var(--pass-ink);
          z-index: 4;
          pointer-events: none;
        }
        .pass-photo-frame::before {
          top: -1px; left: -1px;
          border-right: none; border-bottom: none;
        }
        .pass-photo-frame::after {
          bottom: -1px; right: -1px;
          border-left: none; border-top: none;
        }

        /* Arena identity */
        .pass-id {
          padding-top: 4px;
        }
        .pass-name {
          margin: 0;
          font-family: var(--font-geist-sans, system-ui, sans-serif);
          font-weight: 800;
          font-size: clamp(44px, 11vw, 78px);
          line-height: 0.86;
          letter-spacing: -0.05em;
          text-transform: uppercase;
          word-break: break-word;
          hyphens: auto;
        }
        .pass-rule {
          margin-top: 18px;
          height: 1px;
          background-image: repeating-linear-gradient(to right, var(--pass-line) 0 6px, transparent 6px 12px);
        }
        .pass-loc {
          margin-top: 14px;
          display: flex;
          align-items: center;
          justify-content: space-between;
          gap: 12px;
          font-family: var(--font-geist-mono, ui-monospace, Menlo, monospace);
          font-size: 11px;
          letter-spacing: 0.16em;
          text-transform: uppercase;
          color: var(--pass-muted);
        }

        /* Meta grid */
        .pass-meta {
          display: grid;
          grid-template-columns: repeat(3, 1fr);
          gap: 14px;
          margin-top: 22px;
        }
        .pass-meta > div {
          display: flex;
          flex-direction: column;
          gap: 5px;
          min-width: 0;
        }
        .pass-meta-label {
          font-family: var(--font-geist-mono, ui-monospace, Menlo, monospace);
          font-size: 9.5px;
          font-weight: 600;
          letter-spacing: 0.18em;
          text-transform: uppercase;
          color: var(--pass-muted);
        }
        .pass-meta-val {
          font-family: var(--font-geist-mono, ui-monospace, Menlo, monospace);
          font-size: 16px;
          font-weight: 700;
          letter-spacing: 0.02em;
          color: var(--pass-ink);
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
          display: inline-flex;
          align-items: baseline;
          gap: 6px;
        }
        .pass-meta-val em {
          font-style: normal;
          font-size: 11px;
          font-weight: 600;
          color: var(--pass-muted);
        }

        .pass-amen { margin-top: 18px; }
        .pass-amen-grid {
          display: grid;
          grid-template-columns: repeat(6, 1fr);
          gap: 8px;
        }
        .amen-tile {
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 6px;
          padding: 10px 4px;
          border: 1px dashed var(--pass-line-2);
        }
        .amen-icon {
          width: 24px;
          height: 24px;
          display: inline-grid;
          place-items: center;
          color: var(--pass-ink);
        }
        .amen-label {
          font-family: var(--font-geist-mono);
          font-size: 9px;
          font-weight: 600;
          letter-spacing: 0.12em;
          color: var(--pass-muted);
          white-space: nowrap;
        }
        @media (max-width: 540px) {
          .pass-amen-grid { grid-template-columns: repeat(3, 1fr); }
        }

        /* Tear-line */
        .pass-tear {
          position: relative;
          height: 1px;
          margin: 24px -10px 18px;
          background-image: repeating-linear-gradient(to right, var(--pass-line) 0 7px, transparent 7px 14px);
        }
        .pass-notch {
          position: absolute;
          top: 50%;
          width: 20px;
          height: 20px;
          background: var(--pass-paper);
          border: 1px dashed var(--pass-line);
          border-radius: 50%;
          transform: translateY(-50%);
        }
        .pass-notch.left  { left: -10px; }
        .pass-notch.right { right: -10px; }

        /* Body where BookingFlow mounts */
        .pass-body {
          min-height: 360px;
        }

        /* Empty state */
        .pass-empty {
          padding: 24px 0 0;
          display: flex;
          flex-direction: column;
          gap: 10px;
        }
        .pass-empty-head {
          font-family: var(--font-geist-sans);
          font-size: 22px;
          font-weight: 800;
          letter-spacing: -0.025em;
          line-height: 1.15;
          text-transform: uppercase;
        }
        .pass-empty-sub {
          font-family: var(--font-geist-mono);
          font-size: 12px;
          letter-spacing: 0.04em;
          color: var(--pass-muted);
          max-width: 320px;
        }
        .pass-empty-call {
          margin-top: 14px;
          align-self: flex-start;
          font-family: var(--font-geist-mono);
          font-size: 12px;
          font-weight: 700;
          letter-spacing: 0.14em;
          text-transform: uppercase;
          color: var(--pass-ink);
          text-decoration: none;
          border-bottom: 1px solid var(--pass-ink);
          padding-bottom: 4px;
        }

        /* Bottom strip */
        .pass-foot {
          margin-top: 28px;
          padding-top: 14px;
          display: flex;
          justify-content: space-between;
          align-items: center;
          font-family: var(--font-geist-mono);
          font-size: 9.5px;
          letter-spacing: 0.2em;
          text-transform: uppercase;
          color: var(--pass-muted);
          background-image: repeating-linear-gradient(to right, var(--pass-line) 0 6px, transparent 6px 12px);
          background-size: 100% 1px;
          background-repeat: no-repeat;
          background-position: top;
        }

        /* ──────────────────────────────────────────────────────────
           Re-skin the embedded BookingFlow to match boarding-pass
           ────────────────────────────────────────────────────────── */
        .pass .eyebrow {
          font-family: var(--font-geist-mono, ui-monospace, Menlo, monospace);
          font-size: 9.5px;
          font-weight: 600;
          letter-spacing: 0.18em;
          text-transform: uppercase;
          color: var(--pass-muted);
        }

        .pass .form-field { display: flex; flex-direction: column; gap: 6px; margin-bottom: 14px; }
        .pass .form-label {
          font-family: var(--font-geist-mono);
          font-size: 9.5px;
          font-weight: 600;
          letter-spacing: 0.18em;
          text-transform: uppercase;
          color: var(--pass-muted);
        }
        .pass .form-input {
          border-radius: 0;
          border: none;
          border-bottom: 1px dashed var(--pass-line);
          background: transparent;
          padding: 8px 0 10px;
          font-family: var(--font-geist-mono);
          font-size: 14px;
          letter-spacing: 0.02em;
          color: var(--pass-ink);
          width: 100%;
          appearance: none;
        }
        .pass .form-input::placeholder { color: var(--pass-muted); }
        .pass .form-input:focus { outline: none; border-bottom-color: var(--pass-ink); }

        .pass .cta-bar {
          position: static;
          background: transparent;
          padding: 16px 0 6px;
          margin-top: 18px;
          border-top: 1px dashed var(--pass-line);
          display: flex;
          align-items: flex-end;
          justify-content: space-between;
          gap: 14px;
        }
        .pass .cta-amt {
          font-family: var(--font-geist-mono);
          font-size: 20px;
          font-weight: 700;
          letter-spacing: 0.01em;
          color: var(--pass-ink);
          line-height: 1.1;
        }
        .pass .cta-sub {
          font-family: var(--font-geist-mono);
          font-size: 10px;
          font-weight: 600;
          letter-spacing: 0.15em;
          text-transform: uppercase;
          color: var(--pass-muted);
          margin-top: 3px;
        }
        .pass .cta-btn {
          all: unset;
          cursor: pointer;
          font-family: var(--font-geist-mono);
          font-size: 12px;
          font-weight: 700;
          letter-spacing: 0.16em;
          text-transform: uppercase;
          color: var(--pass-ink);
          padding: 6px 0;
          display: inline-flex;
          align-items: center;
          gap: 8px;
          white-space: nowrap;
        }
        .pass .cta-btn::after { content: "▸"; font-size: 14px; transition: transform 0.15s ease; }
        .pass .cta-btn:hover::after { transform: translateX(2px); }
        .pass .cta-btn:disabled { color: var(--pass-muted); cursor: not-allowed; }
        .pass .cta-btn:disabled::after { color: var(--pass-muted); }
        .pass .cta-btn svg { display: none; }

        /* Slot grid → vertical mono list */
        .pass .slot-grid {
          display: flex !important;
          flex-direction: column;
          padding: 0 !important;
          gap: 0 !important;
          margin-top: 10px;
        }
        .pass .slot {
          all: unset;
          display: flex !important;
          align-items: center;
          justify-content: space-between;
          padding: 13px 0 13px 22px !important;
          border: none !important;
          border-bottom: 1px dashed var(--pass-line-2) !important;
          border-radius: 0 !important;
          background: transparent !important;
          font-family: var(--font-geist-mono);
          font-size: 13px;
          color: var(--pass-ink);
          cursor: pointer;
          position: relative;
        }
        .pass .slot::before {
          content: "○";
          position: absolute;
          left: 0;
          top: 50%;
          transform: translateY(-50%);
          font-size: 11px;
          color: var(--pass-muted);
        }
        .pass .slot.selected::before { content: "●"; color: var(--pass-ink); }
        .pass .slot.unavailable {
          color: var(--pass-muted);
          cursor: not-allowed;
          text-decoration: line-through;
          text-decoration-color: var(--pass-muted);
        }
        .pass .slot.peak::after { content: "PEAK"; font-size: 9px; letter-spacing: 0.14em; color: var(--pass-muted); margin-left: 10px; }
        .pass .slot .badge { display: none; }
        .pass .slot .s-time {
          font-family: var(--font-geist-mono);
          font-size: 13px;
          letter-spacing: 0.04em;
          font-weight: 600;
          flex: 0 0 auto;
        }
        .pass .slot .s-meta {
          flex: 1;
          text-align: center;
          font-family: var(--font-geist-mono);
          font-size: 10.5px;
          font-weight: 600;
          letter-spacing: 0.14em;
          text-transform: uppercase;
          color: var(--pass-muted);
          padding: 0 12px;
        }
        .pass .slot .s-price {
          font-family: var(--font-geist-mono);
          font-size: 12px;
          font-weight: 600;
          color: var(--pass-muted);
          flex: 0 0 auto;
        }
        .pass .slot.selected .s-price { color: var(--pass-ink); }

        .pass-back {
          all: unset;
          cursor: pointer;
          font-family: var(--font-geist-mono);
          font-size: 11px;
          font-weight: 700;
          letter-spacing: 0.18em;
          text-transform: uppercase;
          color: var(--pass-ink);
          padding: 8px 14px;
          display: inline-flex;
          align-items: center;
          gap: 6px;
          border: 1px solid var(--pass-line);
          background: var(--pass-paper);
          margin: 10px 0 6px;
        }
        .pass-back:hover { background: var(--pass-line-2); }

        .pass-context {
          margin-top: 6px;
          font-family: var(--font-geist-mono);
          font-size: 13px;
          font-weight: 700;
          letter-spacing: 0.04em;
          color: var(--pass-ink);
        }

        /* ── Step-1 option rows ─────────────────────────────────────────── */
        .pass-h1 {
          font-family: var(--font-geist-sans);
          font-size: 22px;
          font-weight: 800;
          letter-spacing: -0.02em;
          line-height: 1.1;
          margin: 10px 0 4px;
          color: var(--pass-ink);
        }
        .pass-sub {
          font-family: var(--font-geist-sans);
          font-size: 13px;
          color: var(--pass-muted);
          margin-bottom: 16px;
          line-height: 1.4;
        }

        .opt-list {
          display: flex;
          flex-direction: column;
          gap: 8px;
          margin: 4px 0 0;
        }

        .opt {
          all: unset;
          cursor: pointer;
          display: flex;
          align-items: center;
          gap: 14px;
          padding: 14px 16px;
          border: 1px solid var(--pass-line);
          background: var(--pass-paper);
          color: var(--pass-ink);
          transition: background 0.12s ease, border-color 0.12s ease;
        }
        .opt:hover { background: var(--pass-line-2); }
        .opt.selected {
          background: var(--pass-ink);
          color: var(--pass-paper);
          border-color: var(--pass-ink);
        }
        .opt.selected .opt-sub { color: rgba(244,244,241,0.6); }
        .opt.selected .opt-price { color: var(--pass-paper); }

        .opt-icon {
          flex: 0 0 auto;
          width: 38px;
          height: 38px;
          display: inline-grid;
          place-items: center;
          border: 1px dashed var(--pass-line);
          color: var(--pass-ink);
        }
        .opt.selected .opt-icon {
          border-color: rgba(244,244,241,0.4);
          color: var(--pass-paper);
        }

        .opt-body {
          flex: 1;
          min-width: 0;
          display: flex;
          flex-direction: column;
          gap: 3px;
        }
        .opt-name {
          font-family: var(--font-geist-sans);
          font-size: 14px;
          font-weight: 700;
          letter-spacing: 0.02em;
          text-transform: uppercase;
          display: inline-flex;
          align-items: center;
          gap: 8px;
        }
        .opt-sub {
          font-family: var(--font-geist-sans);
          font-size: 12px;
          color: var(--pass-muted);
          line-height: 1.3;
        }
        .opt-price {
          flex: 0 0 auto;
          font-family: var(--font-geist-mono);
          font-size: 14px;
          font-weight: 700;
          letter-spacing: 0.02em;
          color: var(--pass-ink);
          white-space: nowrap;
        }
        .opt-badge {
          font-family: var(--font-geist-mono);
          font-size: 9px;
          font-weight: 700;
          letter-spacing: 0.14em;
          background: #C8FF3E;
          color: #0A0B0A;
          padding: 2px 6px;
          border-radius: 0;
        }
        .opt.opt-highlight {
          border-color: var(--pass-ink);
          border-style: dashed;
        }
        .opt.opt-highlight .opt-icon {
          background: #C8FF3E;
          color: #0A0B0A;
          border-color: #C8FF3E;
        }
        .opt.opt-highlight.selected .opt-icon {
          background: #C8FF3E;
          color: #0A0B0A;
        }

        /* ── Bulk booking screen ────────────────────────────────────────── */
        .bulk-modes {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 0;
          margin: 8px 0 14px;
          border: 1px solid var(--pass-line);
        }
        .bulk-mode {
          all: unset;
          cursor: pointer;
          text-align: center;
          padding: 12px 10px;
          font-family: var(--font-geist-mono);
          font-size: 11px;
          font-weight: 700;
          letter-spacing: 0.18em;
          text-transform: uppercase;
          color: var(--pass-muted);
          background: var(--pass-paper);
        }
        .bulk-mode + .bulk-mode { border-left: 1px solid var(--pass-line); }
        .bulk-mode.active {
          background: var(--pass-ink);
          color: var(--pass-paper);
        }

        .bulk-fields {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 14px;
          margin-bottom: 14px;
        }

        .bulk-cal {
          margin: 0 0 14px;
          padding: 12px 0 4px;
          border-top: 1px dashed var(--pass-line-2);
          border-bottom: 1px dashed var(--pass-line-2);
        }
        .bulk-cal-dow {
          display: grid;
          grid-template-columns: repeat(7, 1fr);
          font-family: var(--font-geist-mono);
          font-size: 9.5px;
          font-weight: 700;
          letter-spacing: 0.14em;
          color: var(--pass-muted);
          margin-bottom: 8px;
        }
        .bulk-cal-dow span { text-align: center; }
        .bulk-cal-grid {
          display: grid;
          grid-template-columns: repeat(7, 1fr);
          gap: 2px;
        }
        .bulk-cal-cell {
          all: unset;
          cursor: pointer;
          aspect-ratio: 1;
          display: grid;
          place-items: center;
          font-family: var(--font-geist-mono);
          font-size: 13px;
          font-weight: 600;
          color: var(--pass-ink);
          border: 1px solid transparent;
        }
        .bulk-cal-cell:hover:not(:disabled):not(.selected) {
          background: var(--pass-line-2);
        }
        .bulk-cal-cell.selected {
          background: #C8FF3E;
          color: #0A0B0A;
          font-weight: 800;
        }
        .bulk-cal-cell.past {
          color: var(--pass-line);
          cursor: not-allowed;
        }
        .bulk-cal-cell.dim { color: var(--pass-muted); }

        .bulk-guest {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 14px;
          margin-bottom: 8px;
        }
        @media (max-width: 540px) {
          .bulk-guest, .bulk-fields { grid-template-columns: 1fr; }
        }

        .opt-err {
          margin-top: 12px;
          padding: 10px 12px;
          font-family: var(--font-geist-mono);
          font-size: 11px;
          font-weight: 700;
          letter-spacing: 0.1em;
          text-transform: uppercase;
          color: #cc0000;
          border: 1px solid rgba(204,0,0,0.4);
        }

        /* ── Strong filled CTA button (next-step highlight) ─────────────── */
        .pass .cta-info { flex: 1; min-width: 0; }
        .pass .cta-btn.cta-primary,
        .pass .cta-btn[type="submit"] {
          background: #C8FF3E;
          color: #0A0B0A;
          padding: 16px 26px;
          font-size: 13px;
          letter-spacing: 0.22em;
          text-transform: uppercase;
          font-weight: 800;
          box-shadow: 3px 3px 0 0 var(--pass-ink);
        }
        .pass .cta-btn.cta-primary::after,
        .pass .cta-btn[type="submit"]::after { color: #0A0B0A; }
        .pass .cta-btn.cta-primary:disabled {
          background: var(--pass-line-2);
          color: var(--pass-muted);
          box-shadow: none;
        }
        .pass .cta-btn.cta-primary:hover:not(:disabled) {
          transform: translate(1px, 1px);
          box-shadow: 2px 2px 0 0 var(--pass-ink);
        }
        /* All other submit/CTA buttons (form, pass, bulk) get the same primary treatment */
        .pass .cta-bar > button.cta-btn:last-child:not(.cta-primary) {
          background: #C8FF3E;
          color: #0A0B0A;
          padding: 14px 22px;
          font-size: 12.5px;
          letter-spacing: 0.18em;
          font-weight: 800;
          box-shadow: 3px 3px 0 0 var(--pass-ink);
        }
        .pass .cta-bar > button.cta-btn:last-child:not(.cta-primary)::after { color: #0A0B0A; }
        .pass .cta-bar > button.cta-btn:last-child:not(.cta-primary):disabled {
          background: var(--pass-line-2);
          color: var(--pass-muted);
          box-shadow: none;
        }

        /* Calendar strip → mono pill-row */
        .pass .cal-strip {
          display: flex;
          gap: 0;
          overflow-x: auto;
          padding: 12px 0 4px;
          scrollbar-width: none;
          border-bottom: 1px dashed var(--pass-line-2);
        }
        .pass .cal-strip::-webkit-scrollbar { display: none; }
        .pass .cal-day {
          flex: 0 0 56px;
          padding: 8px 0 10px;
          text-align: center;
          background: transparent !important;
          border: none !important;
          border-right: 1px dashed var(--pass-line-2) !important;
          border-radius: 0 !important;
          cursor: pointer;
        }
        .pass .cal-day:last-child { border-right: none !important; }
        .pass .cal-day .dow {
          font-family: var(--font-geist-mono);
          font-size: 9px;
          letter-spacing: 0.16em;
          color: var(--pass-muted);
        }
        .pass .cal-day .dom {
          font-family: var(--font-geist-mono);
          font-size: 18px;
          font-weight: 700;
          letter-spacing: 0;
          margin-top: 3px;
          color: var(--pass-ink);
        }
        .pass .cal-day .avail { margin-top: 4px; }
        .pass .cal-day.selected {
          background: var(--pass-ink) !important;
        }
        .pass .cal-day.selected .dow,
        .pass .cal-day.selected .dom { color: var(--pass-paper) !important; }

        /* Duration stepper → mono ± */
        .pass .dur-stepper {
          display: inline-flex;
          align-items: center;
          gap: 16px;
          padding: 10px 0;
          font-family: var(--font-geist-mono);
        }
        .pass .dur-btn {
          all: unset;
          width: 28px;
          height: 28px;
          display: inline-grid;
          place-items: center;
          border: 1px dashed var(--pass-line);
          border-radius: 0;
          font-size: 16px;
          font-weight: 700;
          cursor: pointer;
          color: var(--pass-ink);
        }
        .pass .dur-btn:disabled { color: var(--pass-muted); cursor: not-allowed; }
        .pass .dur-val { font-family: var(--font-geist-mono); font-size: 18px; font-weight: 700; letter-spacing: 0.02em; color: var(--pass-ink); }
        .pass .dur-price { font-family: var(--font-geist-mono); font-size: 11px; letter-spacing: 0.12em; color: var(--pass-muted); margin-top: 2px; text-transform: uppercase; }

        .pass .pay-note {
          font-family: var(--font-geist-mono);
          font-size: 10px;
          letter-spacing: 0.16em;
          text-transform: uppercase;
          color: var(--pass-muted);
          padding: 14px 0 6px;
        }

        /* Mobile responsiveness */
        @media (max-width: 540px) {
          .pass-shell {
            padding: 18px 18px 0;
            margin-top: 4px;
          }
          .pass-shell::before { left: 9px; }
          .pass-shell::after  { right: 9px; }
          .pass-tear { margin: 22px -7px 16px; }
          .pass-notch.left  { left: -10px; }
          .pass-notch.right { right: -10px; }
          .pass-meta { gap: 8px; }
          .pass-meta-val { font-size: 14px; }
        }
      `}</style>
    </main>
  );
}
