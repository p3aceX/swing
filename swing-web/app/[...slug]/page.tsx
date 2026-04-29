import { notFound } from "next/navigation";
import BookingFlow from "./_booking-flow";

type PageProps = {
  params: Promise<{ slug?: string[] }>;
};

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
  citySlug?: string | null;
  arenaSlug?: string | null;
  customSlug?: string | null;
};

const apiBaseUrl = (
  process.env.NEXT_PUBLIC_API_BASE_URL ||
  process.env.API_BASE_URL ||
  "https://swing-backend-1007730655118.asia-south1.run.app"
).replace(/\/$/, "");

function sportLabel(sport: string) {
  const safe = sport.trim();
  if (!safe) return "Other";
  return safe.charAt(0).toUpperCase() + safe.slice(1).toLowerCase();
}

function unitTypeLabel(type?: string) {
  switch (type) {
    case "FULL_GROUND": return "Full ground";
    case "HALF_GROUND": return "Half ground";
    case "CRICKET_NET": return "Cricket net";
    case "INDOOR_NET": return "Indoor net";
    case "TURF": return "Turf";
    case "MULTI_SPORT": return "Multi sport";
    default: return "Unit";
  }
}

function rupees(paise?: number) {
  if (!paise) return "Price on request";
  return `₹${Math.round(paise / 100)}/hr`;
}

async function fetchArena(slugs: string[]) {
  if (slugs.length === 1) {
    return fetch(
      `${apiBaseUrl}/public/arena/slug/${encodeURIComponent(slugs[0])}`,
      { next: { revalidate: 60 } },
    );
  }
  if (slugs.length === 2) {
    return fetch(
      `${apiBaseUrl}/public/arena/${encodeURIComponent(slugs[0])}/${encodeURIComponent(slugs[1])}`,
      { next: { revalidate: 60 } },
    );
  }
  return null;
}

export default async function ArenaPublicPage({ params }: PageProps) {
  const { slug = [] } = await params;
  const response = await fetchArena(slug);
  if (!response || response.status === 404 || !response.ok) notFound();

  const payload = (await response.json()) as { data?: Arena };
  const arena = payload.data;
  if (!arena) notFound();

  const citySlug = slug.length === 2 ? slug[0] : (arena.citySlug ?? slug[0] ?? "");
  const arenaSlug = slug.length === 2 ? slug[1] : (arena.customSlug ?? arena.arenaSlug ?? slug[0] ?? "");

  const photo = arena.photoUrls?.find(Boolean);
  const gallery = arena.photoUrls?.filter(Boolean).slice(1, 4) ?? [];
  const location = [arena.address, arena.city, arena.state].filter(Boolean).join(", ");
  const sports = arena.sports?.filter(Boolean) ?? [];
  const units = arena.units ?? [];
  const amenities = [
    arena.hasParking ? "Parking" : null,
    arena.hasLights ? "Floodlights" : null,
    arena.hasWashrooms ? "Washrooms" : null,
    arena.hasCanteen ? "Canteen" : null,
  ].filter(Boolean) as string[];

  return (
    <main className="min-h-screen bg-[#f6f7f2] text-[#101828]">
      {/* ── Hero ─────────────────────────────────────────────────── */}
      <section className="relative min-h-[60vh] overflow-hidden bg-[#101828]">
        {photo ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img src={photo} alt={arena.name} className="absolute inset-0 h-full w-full object-cover" />
        ) : (
          <div className="absolute inset-0 bg-[radial-gradient(circle_at_20%_20%,#178756_0,#101828_35%,#05070b_100%)]" />
        )}
        <div className="absolute inset-0 bg-gradient-to-b from-black/40 via-black/25 to-black/80" />

        <div className="relative mx-auto flex min-h-[60vh] max-w-6xl flex-col justify-between px-5 py-6 sm:px-8">
          {/* Nav */}
          <header className="flex items-center justify-between">
            <div className="flex items-center gap-2.5">
              <div className="grid h-9 w-9 place-items-center rounded-lg bg-white text-sm font-black text-[#101828]">
                S
              </div>
              <div>
                <div className="text-sm font-black text-white">Swing</div>
                <div className="text-xs font-semibold text-white/55">Arena booking</div>
              </div>
            </div>
            {arena.phone && (
              <a href={`tel:${arena.phone}`} className="rounded-lg bg-white px-4 py-2 text-sm font-black text-[#101828]">
                Call
              </a>
            )}
          </header>

          {/* Arena info */}
          <div className="pb-3">
            {sports.length > 0 && (
              <div className="mb-3 flex flex-wrap gap-2">
                {sports.map((sport) => (
                  <span key={sport} className="rounded-md bg-white/15 px-3 py-1 text-xs font-bold backdrop-blur text-white">
                    {sportLabel(sport)}
                  </span>
                ))}
              </div>
            )}
            <h1 className="max-w-3xl text-4xl font-black leading-[1.05] text-white sm:text-5xl">{arena.name}</h1>
            {location && <p className="mt-3 max-w-xl text-sm font-semibold text-white/70">{location}</p>}
            <div className="mt-4 flex flex-wrap gap-2">
              {arena.openTime && arena.closeTime && (
                <span className="rounded-md bg-white/12 px-3 py-1.5 text-xs font-bold text-white/80">
                  {arena.openTime} – {arena.closeTime}
                </span>
              )}
              {units.length > 0 && (
                <span className="rounded-md bg-white/12 px-3 py-1.5 text-xs font-bold text-white/80">
                  {units.length} unit{units.length === 1 ? "" : "s"}
                </span>
              )}
              {amenities.map((a) => (
                <span key={a} className="rounded-md bg-white/12 px-3 py-1.5 text-xs font-bold text-white/80">{a}</span>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* ── Body ─────────────────────────────────────────────────── */}
      <section className="mx-auto max-w-6xl px-5 py-8 sm:px-8">
        {/* Gallery strip */}
        {gallery.length > 0 && (
          <div className="mb-8 flex gap-2 overflow-x-auto scrollbar-none">
            {gallery.map((url, i) => (
              // eslint-disable-next-line @next/next/no-img-element
              <img
                key={url}
                src={url}
                alt={`${arena.name} photo ${i + 2}`}
                className="h-32 w-48 flex-none rounded-xl object-cover sm:h-40 sm:w-64"
              />
            ))}
          </div>
        )}

        <div className="grid gap-10 lg:grid-cols-[1fr_380px]">
          {/* Left col */}
          <div>
            {arena.description && (
              <div className="mb-8">
                <h2 className="mb-2 text-xl font-black">About</h2>
                <p className="max-w-2xl text-sm font-medium leading-7 text-[#475467]">{arena.description}</p>
              </div>
            )}

            <h2 className="mb-3 text-xl font-black">Units</h2>
            <div className="space-y-2">
              {units.length > 0 ? (
                units.map((unit) => (
                  <div key={unit.id} className="flex items-center gap-4 rounded-xl bg-white px-4 py-4">
                    <div className="h-14 w-14 flex-none overflow-hidden rounded-lg bg-[#f3f4f6]">
                      {unit.photoUrls?.[0] ? (
                        // eslint-disable-next-line @next/next/no-img-element
                        <img src={unit.photoUrls[0]} alt={unit.name} className="h-full w-full object-cover" />
                      ) : (
                        <div className="grid h-full place-items-center text-[10px] font-black text-[#d0d5dd]">UNIT</div>
                      )}
                    </div>
                    <div className="min-w-0 flex-1">
                      <div className="text-sm font-black">{unit.name}</div>
                      <div className="text-xs font-semibold text-[#98a2b3]">{unitTypeLabel(unit.unitType)}</div>
                      {unit.description && (
                        <div className="mt-1 line-clamp-1 text-xs font-medium text-[#667085]">{unit.description}</div>
                      )}
                    </div>
                    <div className="text-right text-sm font-black text-[#059669]">{rupees(unit.pricePerHourPaise)}</div>
                  </div>
                ))
              ) : (
                <p className="text-sm font-semibold text-[#98a2b3]">No units listed yet.</p>
              )}
            </div>
          </div>

          {/* Right col — booking widget */}
          <div className="lg:sticky lg:top-6">
            <div className="rounded-2xl bg-white px-5 py-5">
              <h2 className="mb-5 text-lg font-black">Book a slot</h2>
              {units.length > 0 ? (
                <BookingFlow
                  units={units}
                  citySlug={citySlug}
                  arenaSlug={arenaSlug}
                  apiBaseUrl={apiBaseUrl}
                  phone={arena.phone}
                />
              ) : (
                <div>
                  <p className="mb-4 text-sm font-semibold text-[#667085]">
                    Online booking is not available yet. Call us to reserve your slot.
                  </p>
                  {arena.phone && (
                    <a
                      href={`tel:${arena.phone}`}
                      className="block rounded-xl bg-[#12b76a] py-3 text-center text-sm font-black text-white"
                    >
                      Call to book · {arena.phone}
                    </a>
                  )}
                </div>
              )}
            </div>

            {/* Contact/visit card */}
            {(location || arena.openTime || arena.phone) && (
              <div className="mt-4 rounded-2xl bg-white px-5 py-5">
                <h3 className="mb-4 text-sm font-black">Visit info</h3>
                <div className="space-y-3">
                  {location && (
                    <div>
                      <div className="text-xs font-black uppercase tracking-wide text-[#98a2b3]">Location</div>
                      <p className="mt-1 text-sm font-semibold text-[#475467]">{location}</p>
                    </div>
                  )}
                  {arena.openTime && arena.closeTime && (
                    <div>
                      <div className="text-xs font-black uppercase tracking-wide text-[#98a2b3]">Hours</div>
                      <p className="mt-1 text-sm font-semibold text-[#475467]">{arena.openTime} – {arena.closeTime}</p>
                    </div>
                  )}
                  {arena.phone && (
                    <div>
                      <div className="text-xs font-black uppercase tracking-wide text-[#98a2b3]">Phone</div>
                      <a href={`tel:${arena.phone}`} className="mt-1 block text-sm font-black text-[#101828]">
                        {arena.phone}
                      </a>
                    </div>
                  )}
                </div>
              </div>
            )}
          </div>
        </div>
      </section>
    </main>
  );
}
