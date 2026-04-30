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
      cache: "no-store",
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

function unitTypeLabel(type?: string) {
  const map: Record<string, string> = {
    FULL_GROUND: "Full ground",
    HALF_GROUND: "Half ground",
    CRICKET_NET: "Cricket net",
    INDOOR_NET: "Indoor net",
    TURF: "Turf",
    MULTI_SPORT: "Multi-sport",
  };
  return map[type ?? ""] ?? "Unit";
}

function unitSurface(type?: string) {
  const map: Record<string, string> = {
    FULL_GROUND:
      "repeating-linear-gradient(135deg, oklch(0.42 0.12 145) 0 10px, oklch(0.36 0.12 145) 10px 20px)",
    HALF_GROUND:
      "repeating-linear-gradient(135deg, oklch(0.42 0.12 145) 0 10px, oklch(0.36 0.12 145) 10px 20px)",
    CRICKET_NET:
      "repeating-linear-gradient(90deg, oklch(0.55 0.10 130) 0 6px, oklch(0.47 0.10 130) 6px 12px)",
    INDOOR_NET:
      "repeating-linear-gradient(90deg, oklch(0.48 0.08 230) 0 6px, oklch(0.40 0.08 230) 6px 12px)",
    TURF:
      "repeating-linear-gradient(90deg, oklch(0.62 0.14 30) 0 6px, oklch(0.53 0.14 30) 6px 12px)",
    MULTI_SPORT:
      "repeating-linear-gradient(90deg, oklch(0.55 0.10 260) 0 6px, oklch(0.47 0.10 260) 6px 12px)",
  };

  return (
    map[type ?? ""] ??
    "repeating-linear-gradient(90deg, oklch(0.55 0.10 130) 0 6px, oklch(0.48 0.10 130) 6px 12px)"
  );
}

function rupeesPerHr(paise?: number) {
  if (!paise) return null;
  return `₹${Math.round(paise / 100)}/hr`;
}

function unitPriceCandidates(unit: ArenaUnit) {
  const variants = (unit.netVariants ?? [])
    .map((variant) => variant.pricePaise)
    .filter((price): price is number => Boolean(price && price > 0));
  if (variants.length) return variants;

  const packagePrices = [
    unit.price4HrPaise,
    unit.price8HrPaise,
    unit.priceFullDayPaise,
  ].filter((price): price is number => Boolean(price && price > 0));

  return [
    unit.pricePerHourPaise,
    ...packagePrices,
  ].filter((price): price is number => Boolean(price && price > 0));
}

function startingPricePaise(units: ArenaUnit[]) {
  const prices = units.flatMap(unitPriceCandidates);
  return prices.length ? Math.min(...prices) : undefined;
}

function priceRangeLabel(units: ArenaUnit[]) {
  const prices = units.flatMap(unitPriceCandidates);
  if (!prices.length) return null;
  const min = Math.round(Math.min(...prices) / 100);
  const max = Math.round(Math.max(...prices) / 100);
  return min === max ? `₹${min}` : `₹${min}–₹${max}`;
}

function marketingDescription(arena: Arena) {
  const location = [arena.city, arena.state].filter(Boolean).join(", ");
  const sports = (arena.sports ?? []).map(sportLabel).join(", ");
  const units = arena.units ?? [];
  const fromPrice = startingPricePaise(units);
  const price = fromPrice ? `Book from ₹${Math.round(fromPrice / 100)}` : "Book slots online";
  const unitLabel = units.length
    ? `${units.length} ${units.length === 1 ? "play area" : "play areas"}`
    : "sports venue";
  const details = [
    price,
    unitLabel,
    sports,
    location,
  ].filter(Boolean);

  return `${details.join(" · ")}. Reserve your slot instantly with live availability. Powered by Swing.`;
}

function formatTime(time?: string | null) {
  if (!time) return null;
  const [hourRaw, minuteRaw = "00"] = time.split(":");
  const hour = Number(hourRaw);
  if (Number.isNaN(hour)) return time;
  const suffix = hour >= 12 ? "PM" : "AM";
  const displayHour = hour % 12 || 12;
  return `${displayHour}:${minuteRaw.padStart(2, "0")} ${suffix}`;
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { slug } = await params;
  const arena = await fetchArena(slug);

  if (!arena) return { title: "Arena not found" };

  const location = [arena.city, arena.state].filter(Boolean).join(", ");
  const sports = (arena.sports ?? []).map(sportLabel).join(", ");
  const units = arena.units ?? [];
  const photo = arena.photoUrls?.find(Boolean);
  const canonicalSlug = arena.customSlug ?? arena.arenaSlug ?? slug;
  const price = startingPricePaise(units);
  const priceText = price ? ` from ₹${Math.round(price / 100)}` : "";
  const title = `Book ${arena.name}${location ? ` in ${location}` : ""}${priceText}`;
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
    alternates: {
      canonical: `/arena/${canonicalSlug}`,
    },
    robots: {
      index: true,
      follow: true,
      googleBot: {
        index: true,
        follow: true,
        "max-image-preview": "large",
        "max-snippet": -1,
      },
    },
    openGraph: {
      title,
      description,
      url: `/arena/${canonicalSlug}`,
      siteName: "Swing",
      images: image,
      type: "website",
    },
    twitter: {
      card: "summary_large_image",
      title,
      description,
      images: image.map((item) => item.url),
    },
  };
}

export default async function ArenaPage({ params }: PageProps) {
  const { slug } = await params;
  const arena = await fetchArena(slug);

  if (!arena) notFound();

  const units = arena.units ?? [];
  const photos = arena.photoUrls?.filter(Boolean) ?? [];
  const sports = (arena.sports ?? []).filter(Boolean);
  const city = [arena.city, arena.state].filter(Boolean).join(", ");
  const fullAddress = [arena.address, arena.city, arena.state]
    .filter(Boolean)
    .join(", ");
  const startingPaise = startingPricePaise(units);
  const priceRange = priceRangeLabel(units);
  const nets = units.filter(
    (u) => u.unitType === "CRICKET_NET" || u.unitType === "INDOOR_NET"
  ).length;
  const grounds = units.filter(
    (u) => u.unitType !== "CRICKET_NET" && u.unitType !== "INDOOR_NET"
  ).length;

  const amenities = [
    arena.hasLights    && "Floodlights",
    arena.hasParking   && "Parking",
    arena.hasWashrooms && "Washrooms",
    arena.hasCanteen   && "Canteen",
    arena.hasCCTV      && "CCTV",
    arena.hasScorer    && "Scorer",
  ].filter(Boolean) as string[];

  const chips = [...sports.map(sportLabel), ...amenities];

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
  const openText = arenaCloseTime ? `Open till ${formatTime(arenaCloseTime)}` : "Open today";
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
    geo:
      arena.latitude && arena.longitude
        ? {
            "@type": "GeoCoordinates",
            latitude: arena.latitude,
            longitude: arena.longitude,
          }
        : undefined,
    amenityFeature: amenities.map((name) => ({
      "@type": "LocationFeatureSpecification",
      name,
      value: true,
    })),
    offers: startingPaise
      ? {
          "@type": "Offer",
          priceCurrency: "INR",
          price: Math.round(startingPaise / 100),
          availability: "https://schema.org/InStock",
          url: publicUrl,
        }
      : undefined,
  };

  const visibleUnits = units.slice(0, 4);
  const extraUnits = Math.max(units.length - visibleUnits.length, 0);

  return (
    <main className="arena-page">
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
      />
      <SiteNav />

      <section className="arena-stage">
        <aside className="arena-hero-card">
          <div className="arena-photo-wrap">
            <PhotoCarousel photos={photos} alt={arena.name} />
          </div>
          <div className="arena-photo-vignette" />
          <div className="arena-photo-glow" />

          <div className="arena-top-row">
            {(arenaOpenTime || arenaCloseTime) && (
              <div className="arena-live-pill">
                <span />
                {arenaOpenTime && arenaCloseTime
                  ? `${formatTime(arenaOpenTime)} – ${formatTime(arenaCloseTime)}`
                  : arenaOpenTime
                  ? `Opens ${formatTime(arenaOpenTime)}`
                  : `Closes ${formatTime(arenaCloseTime)}`}
              </div>
            )}
            {arena.latitude && arena.longitude && (
              <DirectionsModal
                name={arena.name}
                address={fullAddress || city}
                latitude={arena.latitude}
                longitude={arena.longitude}
              />
            )}
          </div>

          <div className="arena-hero-content">
            <div className="arena-title-block">
              <h1>{arena.name}</h1>
              {arena.description && (
                <p className="arena-description">{arena.description}</p>
              )}
            </div>

            <div className="arena-info-rows">
              {sports.length > 0 && (
                <div className="arena-info-row">
                  <span className="arena-info-label">Sports Available</span>
                  <div className="arena-chip-row">
                    {sports.map(sportLabel).map((s) => <span key={s}>{s}</span>)}
                  </div>
                </div>
              )}
              {amenities.length > 0 && (
                <div className="arena-info-row">
                  <span className="arena-info-label">Facilities</span>
                  <div className="arena-chip-row">
                    {amenities.map((a) => <span key={a}>{a}</span>)}
                  </div>
                </div>
              )}
            </div>

            <div className="arena-bottom-grid">
              {visibleUnits.length > 0 && (
                <div className="arena-unit-strip">
                  {visibleUnits.map((unit) => (
                    <div key={unit.id} className="arena-unit-card">
                      <i style={{ background: unitSurface(unit.unitType) }} />
                      <span>
                        <b>{unit.name}</b>
                        <small>
                          {unitTypeLabel(unit.unitType)}
                          {(() => {
                            const vs = (unit.netVariants ?? []).map(v => v.pricePaise).filter((p): p is number => !!p);
                            if (vs.length) {
                              const lo = Math.round(Math.min(...vs) / 100);
                              const hi = Math.round(Math.max(...vs) / 100);
                              return ` · ₹${lo === hi ? lo : `${lo}–${hi}`}/hr`;
                            }
                            const isGr = ["FULL_GROUND","HALF_GROUND"].includes(unit.unitType ?? "");
                            if (isGr) {
                              const bulk = [unit.price4HrPaise, unit.price8HrPaise, unit.priceFullDayPaise].filter(Boolean) as number[];
                              return bulk.length ? ` · from ₹${Math.round(Math.min(...bulk) / 100)}` : "";
                            }
                            return rupeesPerHr(unit.pricePerHourPaise) ? ` · ${rupeesPerHr(unit.pricePerHourPaise)}` : "";
                          })()}
                        </small>
                      </span>
                    </div>
                  ))}
                  {extraUnits > 0 && (
                    <div className="arena-more-units">+{extraUnits} more</div>
                  )}
                </div>
              )}
            </div>
          </div>
        </aside>

        <aside className="arena-booking-card" id="book">
          <div className="arena-booking-head">
            <div>
              <p>Powered by Swing</p>
              <h2>{units.length > 0 ? "Pick your slot" : "Reserve your slot"}</h2>
            </div>
            <span>{openText}</span>
          </div>
          <div className="arena-share-copy">
            {priceRange ? `${priceRange} starting options` : "Live slot booking"} · Powered by Swing
          </div>

          <div className="arena-booking-body">
            {units.length > 0 ? (
              <BookingFlow
                units={units}
                arenaSlug={slug}
                apiBaseUrl={API}
                arenaName={arena.name}
                address={fullAddress || city || undefined}
                latitude={arena.latitude}
                longitude={arena.longitude}
                phone={arena.phone}
                openTime={arenaOpenTime}
                closeTime={arenaCloseTime}
              />
            ) : (
              <div className="arena-empty-booking">
                <h3>Online booking is not live yet</h3>
                <p>Call the arena directly to reserve your preferred slot.</p>
                {arena.phone && (
                  <a href={`tel:${arena.phone}`} className="arena-empty-call">
                    Call {arena.phone}
                  </a>
                )}
              </div>
            )}
          </div>
        </aside>
      </section>

      <style>{`
        /* Light */
        :root, [data-theme="light"] {
          --arena-bg:              #F4F2EB;
          --arena-ink:             #0A0B0A;
          --arena-muted:           rgba(10,11,10,0.55);
          --arena-line:            rgba(10,11,10,0.10);
          --arena-accent:          #C8FF3E;
          --arena-card:            rgba(255,255,255,0.70);
          --arena-shadow:          0 24px 90px rgba(10,11,10,0.16);
          --arena-booking-bg:      #FFFFFF;
          --arena-booking-border:  rgba(10,11,10,0.12);
          --arena-price-bg:        rgba(10,11,10,0.045);
          --arena-price-border:    rgba(10,11,10,0.06);
          --arena-empty-bg:        rgba(255,255,255,0.55);
          --arena-empty-border:    rgba(10,11,10,0.15);
          --arena-mobile-nav-bg:   rgba(244,242,235,0.85);
        }
        /* Dark */
        [data-theme="dark"] {
          --arena-bg:              #0A0B0A;
          --arena-ink:             #F4F4F1;
          --arena-muted:           rgba(244,244,241,0.55);
          --arena-line:            rgba(244,244,241,0.10);
          --arena-accent:          #C8FF3E;
          --arena-card:            rgba(255,255,255,0.06);
          --arena-shadow:          0 24px 90px rgba(0,0,0,0.55);
          --arena-booking-bg:      #111211;
          --arena-booking-border:  rgba(255,255,255,0.10);
          --arena-price-bg:        rgba(255,255,255,0.05);
          --arena-price-border:    rgba(255,255,255,0.07);
          --arena-empty-bg:        rgba(255,255,255,0.04);
          --arena-empty-border:    rgba(255,255,255,0.12);
          --arena-mobile-nav-bg:   rgba(10,11,10,0.88);
        }

        :root {
          --arena-radius-lg: 34px;
          --arena-radius-md: 22px;
        }

        html, body {
          overflow: hidden;
          background: var(--arena-bg);
          transition: background 0.35s ease, color 0.35s ease;
        }

        .arena-page {
          height: 100svh;
          overflow: hidden;
          color: var(--arena-ink);
          background:
            radial-gradient(circle at 12% 0%, rgba(200,255,62,0.12), transparent 26rem),
            radial-gradient(circle at 90% 10%, rgba(200,255,62,0.06), transparent 24rem),
            var(--arena-bg);
          font-family: var(--font-ui, Inter, ui-sans-serif, system-ui, -apple-system, sans-serif);
          transition: background 0.35s ease, color 0.35s ease;
        }


        .arena-stage {
          height: calc(100svh - 52px);
          min-height: 0;
          display: grid;
          grid-template-columns: minmax(0, 1.18fr) minmax(390px, 0.82fr);
          gap: 14px;
          padding: 10px clamp(12px, 1.6vw, 24px) clamp(12px, 1.6vw, 24px);
        }

        .arena-hero-card,
        .arena-booking-card {
          position: relative;
          min-height: 0;
          overflow: hidden;
          border-radius: var(--arena-radius-lg);
          box-shadow: var(--arena-shadow);
        }

        .arena-hero-card {
          isolation: isolate;
          background: #09110a;
        }

        .arena-photo-wrap,
        .arena-photo-vignette,
        .arena-photo-glow {
          position: absolute;
          inset: 0;
        }

        .arena-photo-wrap > * {
          height: 100%;
        }

        .arena-photo-vignette {
          pointer-events: none;
          background:
            linear-gradient(180deg, rgba(0, 0, 0, 0.16) 0%, transparent 26%, rgba(0, 0, 0, 0.58) 64%, rgba(0, 0, 0, 0.92) 100%),
            linear-gradient(90deg, rgba(0, 0, 0, 0.38) 0%, transparent 62%);
          z-index: 1;
        }

        .arena-photo-glow {
          pointer-events: none;
          z-index: 2;
          background: radial-gradient(circle at 20% 80%, rgba(182, 255, 69, 0.24), transparent 22rem);
          mix-blend-mode: screen;
        }

        .arena-top-row {
          position: absolute;
          top: 22px;
          left: 22px;
          right: 22px;
          z-index: 3;
          display: flex;
          align-items: center;
          justify-content: space-between;
          gap: 12px;
        }

        .arena-live-pill,
        .arena-city-pill {
          display: inline-flex;
          align-items: center;
          min-height: 34px;
          border-radius: 999px;
          backdrop-filter: blur(18px);
          border: 1px solid rgba(255, 255, 255, 0.16);
          font-size: 11px;
          font-weight: 900;
          letter-spacing: 0.12em;
          text-transform: uppercase;
        }

        .arena-live-pill {
          gap: 8px;
          padding: 0 13px;
          color: #10210f;
          background: var(--arena-accent);
        }

        .arena-live-pill span {
          width: 7px;
          height: 7px;
          border-radius: 50%;
          background: #10210f;
          box-shadow: 0 0 0 0 rgba(16, 33, 15, 0.42);
          animation: arenaPulse 1.35s ease-in-out infinite;
        }

        .arena-hero-content {
          position: absolute;
          left: 0;
          right: 0;
          bottom: 0;
          z-index: 3;
          padding: 22px;
          display: grid;
          gap: 16px;
        }

        .arena-metrics {
          display: grid;
          grid-template-columns: repeat(4, 1fr);
          gap: 1px;
          overflow: hidden;
          border: 1px solid rgba(255, 255, 255, 0.13);
          border-radius: 22px;
          background: rgba(255, 255, 255, 0.09);
          backdrop-filter: blur(20px);
        }

        .arena-metrics div {
          min-width: 0;
          padding: 13px 14px;
          background: rgba(255, 255, 255, 0.045);
        }

        .arena-metrics strong,
        .arena-metrics span {
          display: block;
          overflow: hidden;
          text-overflow: ellipsis;
          white-space: nowrap;
        }

        .arena-metrics strong {
          color: white;
          font-family: var(--font-display, ui-sans-serif);
          font-size: clamp(18px, 2vw, 26px);
          line-height: 0.95;
          letter-spacing: -0.04em;
        }

        .arena-metrics span {
          margin-top: 5px;
          color: rgba(255, 255, 255, 0.55);
          font-size: 9px;
          font-weight: 800;
          letter-spacing: 0.12em;
          text-transform: uppercase;
        }

        .arena-title-block p {
          margin: 0 0 7px;
          color: var(--arena-accent);
          font-size: 11px;
          font-weight: 900;
          letter-spacing: 0.15em;
          text-transform: uppercase;
        }

        .arena-title-block {
          display: flex;
          flex-direction: column;
          gap: 14px;
        }

        .arena-title-block h1 {
          max-width: 900px;
          margin: 0;
          color: white;
          font-family: var(--font-display, ui-sans-serif);
          font-size: clamp(44px, 6vw, 86px);
          line-height: 0.86;
          letter-spacing: -0.065em;
        }

        .arena-location {
          width: min(100%, 880px);
          display: flex;
          align-items: center;
          gap: 8px;
          margin-top: 13px;
          color: rgba(255, 255, 255, 0.68);
          font-size: 13px;
          font-weight: 650;
          line-height: 1.35;
        }

        .arena-location span {
          overflow: hidden;
          text-overflow: ellipsis;
          white-space: nowrap;
        }

        .arena-info-rows {
          display: flex;
          flex-direction: column;
          gap: 10px;
        }

        .arena-info-row {
          display: flex;
          align-items: center;
          gap: 10px;
          flex-wrap: wrap;
        }

        .arena-info-label {
          font-size: 9px;
          font-weight: 900;
          letter-spacing: 0.14em;
          text-transform: uppercase;
          color: rgba(255, 255, 255, 0.45);
          white-space: nowrap;
          flex-shrink: 0;
        }

        .arena-chip-row {
          display: flex;
          flex-wrap: wrap;
          gap: 6px;
        }

        .arena-chip-row span {
          padding: 5px 11px;
          border-radius: 999px;
          color: rgba(255, 255, 255, 0.84);
          background: rgba(255, 255, 255, 0.11);
          border: 1px solid rgba(255, 255, 255, 0.14);
          backdrop-filter: blur(14px);
          font-size: 11px;
          font-weight: 700;
        }

        .arena-bottom-grid {
          display: grid;
          grid-template-columns: 0.76fr 1fr;
          align-items: end;
          gap: 16px;
        }

        .arena-description {
          display: -webkit-box;
          -webkit-line-clamp: 2;
          -webkit-box-orient: vertical;
          overflow: hidden;
          margin: 0;
          color: rgba(255, 255, 255, 0.66);
          font-size: 13px;
          line-height: 1.55;
          font-weight: 500;
        }

        .arena-unit-strip {
          display: grid;
          grid-template-columns: repeat(2, minmax(0, 1fr));
          gap: 8px;
        }

        .arena-unit-card,
        .arena-more-units {
          min-width: 0;
          min-height: 54px;
          display: flex;
          align-items: center;
          border-radius: 18px;
          border: 1px solid rgba(255, 255, 255, 0.13);
          background: rgba(255, 255, 255, 0.09);
          backdrop-filter: blur(18px);
        }

        .arena-unit-card {
          gap: 10px;
          padding: 9px;
        }

        .arena-unit-card i {
          width: 38px;
          height: 30px;
          flex: 0 0 auto;
          border-radius: 10px;
          box-shadow: inset 0 0 0 1px rgba(255, 255, 255, 0.16);
        }

        .arena-unit-card span {
          min-width: 0;
          display: block;
        }

        .arena-unit-card b,
        .arena-unit-card small {
          display: block;
          overflow: hidden;
          text-overflow: ellipsis;
          white-space: nowrap;
        }

        .arena-unit-card b {
          color: white;
          font-size: 12px;
          line-height: 1.15;
        }

        .arena-unit-card small {
          margin-top: 3px;
          color: rgba(255, 255, 255, 0.58);
          font-size: 10px;
          font-weight: 700;
        }

        .arena-more-units {
          justify-content: center;
          padding: 0 12px;
          color: var(--arena-accent);
          font-size: 12px;
          font-weight: 900;
        }

        .arena-booking-card {
          display: flex;
          flex-direction: column;
          border: 1px solid var(--arena-booking-border);
          background: var(--arena-booking-bg);
        }

        .arena-booking-head {
          flex: 0 0 auto;
          display: flex;
          align-items: center;
          justify-content: space-between;
          gap: 12px;
          padding: 14px 16px 12px;
          border-bottom: 1px solid var(--arena-line);
        }

        .arena-booking-head p {
          display: none;
        }

        .arena-booking-head h2 {
          margin: 0;
          color: var(--arena-ink);
          font-family: var(--font-ui, ui-sans-serif);
          font-size: 16px;
          font-weight: 700;
          line-height: 1;
          letter-spacing: -0.02em;
        }

        .arena-booking-head > span {
          flex: 0 0 auto;
          padding: 5px 10px;
          border-radius: 999px;
          color: #14310e;
          background: rgba(182, 255, 69, 0.64);
          font-size: 10px;
          font-weight: 700;
          font-family: var(--font-ui, ui-sans-serif);
          white-space: nowrap;
        }

        .arena-share-copy {
          margin: 12px 16px 0;
          padding: 10px 12px;
          border-radius: 14px;
          color: var(--arena-muted);
          background: var(--arena-price-bg);
          border: 1px solid var(--arena-price-border);
          font: 800 10px/1.35 var(--font-ui, ui-sans-serif);
          letter-spacing: 0.08em;
          text-transform: uppercase;
        }

        .arena-booking-body {
          flex: 1 1 auto;
          min-height: 0;
          overflow: hidden;
          padding: 0;
        }

        .arena-booking-body > * {
          height: 100%;
          min-height: 0;
        }

        .arena-booking-body :global(.cta-btn),
        .arena-booking-body :global(button) {
          border-radius: 12px;
        }

        .arena-empty-booking {
          height: 100%;
          display: grid;
          place-content: center;
          text-align: center;
          padding: 28px;
          border-radius: 24px;
          border: 1px dashed var(--arena-empty-border);
          background: var(--arena-empty-bg);
        }

        .arena-empty-booking h3 {
          margin: 0;
          color: var(--arena-ink);
          font-size: 22px;
          letter-spacing: -0.04em;
        }

        .arena-empty-booking p {
          max-width: 280px;
          margin: 9px auto 18px;
          color: var(--arena-muted);
          font-size: 14px;
          line-height: 1.45;
        }

        .arena-empty-call {
          display: inline-flex;
          justify-content: center;
          align-items: center;
          min-height: 46px;
          padding: 0 18px;
          border-radius: 999px;
          color: #10210f;
          background: var(--arena-accent);
          text-decoration: none;
          font-weight: 900;
        }

        @keyframes arenaPulse {
          0% { box-shadow: 0 0 0 0 rgba(16, 33, 15, 0.42); }
          70% { box-shadow: 0 0 0 9px rgba(16, 33, 15, 0); }
          100% { box-shadow: 0 0 0 0 rgba(16, 33, 15, 0); }
        }

        @media (max-width: 1120px) {
          .arena-stage {
            grid-template-columns: minmax(0, 1fr) minmax(360px, 0.8fr);
          }

          .arena-bottom-grid {
            grid-template-columns: 1fr;
          }

          .arena-description {
            -webkit-line-clamp: 2;
          }
        }

        @media (max-width: 900px) {
          html,
          body,
          .arena-page {
            overflow: auto;
          }

          .arena-page {
            height: auto;
            min-height: 100svh;
          }

          .arena-nav {
            position: sticky;
            top: 0;
            z-index: 10;
            height: 64px;
            background: var(--arena-mobile-nav-bg);
            backdrop-filter: blur(18px);
          }

          .arena-nav-links {
            display: none;
          }

          .arena-stage {
            height: auto;
            display: grid;
            grid-template-columns: 1fr;
            padding: 0 12px 12px;
          }

          .arena-hero-card {
            min-height: 590px;
          }

          .arena-booking-card {
            min-height: 650px;
          }

          .arena-booking-body {
            overflow: auto;
          }
        }

        @media (max-width: 560px) {
          .arena-brand span,
          .arena-call-btn {
            display: none;
          }

          .arena-nav {
            padding-inline: 12px;
          }

          .arena-book-btn {
            height: 38px;
            padding: 0 15px;
          }

          .arena-hero-card {
            min-height: 600px;
            border-radius: 26px;
          }

          .arena-top-row {
            top: 16px;
            left: 16px;
            right: 16px;
          }

          .arena-hero-content {
            padding: 16px;
            gap: 13px;
          }

          .arena-metrics {
            grid-template-columns: repeat(2, 1fr);
            border-radius: 18px;
          }

          .arena-title-block h1 {
            font-size: 42px;
          }

          .arena-location span {
            white-space: normal;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
          }

          .arena-chip-row span:nth-child(n + 6) {
            display: none;
          }

          .arena-unit-strip {
            grid-template-columns: 1fr;
          }

          .arena-booking-card {
            border-radius: 26px;
          }

          .arena-booking-head,
          .arena-booking-price-row {
            padding-inline: 16px;
          }

          .arena-share-copy {
            margin-inline: 16px;
          }

          .arena-booking-head {
            display: block;
          }

          .arena-booking-head > span {
            display: inline-flex;
            margin-top: 12px;
          }

          .arena-booking-body {
            padding: 12px;
          }
        }
      `}</style>
    </main>
  );
}
