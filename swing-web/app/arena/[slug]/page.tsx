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
  const suffix = hour >= 12 ? "P" : "A";
  const displayHour = hour % 12 || 12;
  const min = minuteRaw === "00" ? "" : `:${minuteRaw.padStart(2, "0")}`;
  return `${displayHour}${min}${suffix}`;
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

  const amenities = [
    arena.hasLights    && "Floodlights",
    arena.hasParking   && "Parking",
    arena.hasWashrooms && "Washrooms",
    arena.hasCanteen   && "Canteen",
    arena.hasCCTV      && "CCTV",
    arena.hasScorer    && "Scorer",
  ].filter(Boolean) as string[];

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
            <span className="pass-meta-label">FACILITIES</span>
            <div className="pass-amen-row">
              {amenities.map((a) => <span key={a}>{a.toUpperCase()}</span>)}
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

        .pass-amen {
          margin-top: 16px;
        }
        .pass-amen-row {
          margin-top: 7px;
          display: flex;
          flex-wrap: wrap;
          gap: 6px 14px;
          font-family: var(--font-geist-mono, ui-monospace, Menlo, monospace);
          font-size: 10.5px;
          font-weight: 600;
          letter-spacing: 0.12em;
          text-transform: uppercase;
          color: var(--pass-ink);
        }
        .pass-amen-row span {
          position: relative;
        }
        .pass-amen-row span + span::before {
          content: "·";
          position: absolute;
          left: -10px;
          color: var(--pass-muted);
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
        }
        .pass .slot .s-price {
          font-family: var(--font-geist-mono);
          font-size: 12px;
          font-weight: 600;
          color: var(--pass-muted);
        }
        .pass .slot.selected .s-price { color: var(--pass-ink); }

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
