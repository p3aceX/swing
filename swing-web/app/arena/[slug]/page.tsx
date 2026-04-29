import type { Metadata } from "next";
import { notFound } from "next/navigation";
import BookingFlow, { MobileBookBar } from "./_booking-flow";

type PageProps = { params: Promise<{ slug: string }> };

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
  customSlug?: string | null;
  arenaSlug?: string | null;
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

function rupeesPerHr(paise?: number) {
  if (!paise) return null;
  return `₹${Math.round(paise / 100)}/hr`;
}

// ── OG / WhatsApp metadata ───────────────────────────────────────────────────
export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { slug } = await params;
  const arena = await fetchArena(slug);
  if (!arena) return { title: "Arena not found" };

  const location = [arena.city, arena.state].filter(Boolean).join(", ");
  const sports = (arena.sports ?? []).map(sportLabel).join(", ");
  const units = arena.units ?? [];
  const prices = units.map((u) => u.pricePerHourPaise ?? 0).filter(Boolean);
  const fromPrice = prices.length ? `From ₹${Math.round(Math.min(...prices) / 100)}/hr · ` : "";
  const photo = arena.photoUrls?.find(Boolean);

  const description = `${fromPrice}${units.length} court${units.length === 1 ? "" : "s"}${sports ? ` · ${sports}` : ""}${location ? ` · ${location}` : ""}. Book your slot instantly.`;

  return {
    title: arena.name,
    description,
    openGraph: {
      title: arena.name,
      description,
      images: photo ? [{ url: photo, width: 1200, height: 630, alt: arena.name }] : [],
      type: "website",
    },
    twitter: {
      card: "summary_large_image",
      title: arena.name,
      description,
      images: photo ? [photo] : [],
    },
  };
}

// ── Page ─────────────────────────────────────────────────────────────────────
export default async function ArenaPage({ params }: PageProps) {
  const { slug } = await params;
  const arena = await fetchArena(slug);
  if (!arena) notFound();

  const units = arena.units ?? [];
  const photos = arena.photoUrls?.filter(Boolean) ?? [];
  const heroPhoto = photos[0];
  const galleryPhotos = photos.slice(1, 5);
  const sports = (arena.sports ?? []).filter(Boolean);
  const location = [arena.address, arena.city, arena.state].filter(Boolean).join(", ");
  const prices = units.map((u) => u.pricePerHourPaise ?? 0).filter(Boolean);
  const startingPaise = prices.length ? Math.min(...prices) : undefined;
  const amenities = [
    arena.hasParking && "Parking",
    arena.hasLights && "Floodlights",
    arena.hasWashrooms && "Washrooms",
    arena.hasCanteen && "Canteen",
  ].filter(Boolean) as string[];

  return (
    <div className="min-h-screen bg-white text-[#0d1210]">
      {/* ── Hero ──────────────────────────────────────────────────────────────── */}
      <section className="relative flex min-h-[100svh] flex-col overflow-hidden bg-[#0d1210]">
        {heroPhoto ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img
            src={heroPhoto}
            alt={arena.name}
            className="absolute inset-0 h-full w-full object-cover opacity-60"
          />
        ) : (
          <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_top_left,#166534_0%,#0d1210_55%)]" />
        )}
        {/* gradient — strong at bottom so text always readable */}
        <div className="absolute inset-0 bg-gradient-to-b from-black/10 via-transparent to-black/90" />
        <div className="absolute inset-x-0 bottom-0 h-[55%] bg-gradient-to-t from-black/95 to-transparent" />

        {/* Nav bar */}
        <nav className="relative z-10 flex items-center justify-between px-5 py-5 sm:px-8">
          <div className="flex items-center gap-2.5">
            <div className="grid h-8 w-8 place-items-center rounded-lg bg-white text-xs font-black text-[#0d1210]">S</div>
            <span className="text-sm font-black text-white/80">Swing</span>
          </div>
          {arena.phone && (
            <a
              href={`tel:${arena.phone}`}
              className="flex items-center gap-2 rounded-xl bg-white/15 px-4 py-2 text-sm font-bold text-white backdrop-blur-sm"
            >
              <svg className="h-3.5 w-3.5" fill="currentColor" viewBox="0 0 20 20">
                <path d="M2 3a1 1 0 011-1h2.153a1 1 0 01.986.836l.74 4.435a1 1 0 01-.54 1.06l-1.548.773a11.037 11.037 0 006.105 6.105l.774-1.548a1 1 0 011.059-.54l4.435.74a1 1 0 01.836.986V17a1 1 0 01-1 1h-2C7.82 18 2 12.18 2 5V3z" />
              </svg>
              Call
            </a>
          )}
        </nav>

        {/* Arena identity — bottom of hero */}
        <div className="relative z-10 mt-auto px-5 pb-10 sm:px-8 sm:pb-14">
          {sports.length > 0 && (
            <div className="mb-4 flex flex-wrap gap-2">
              {sports.map((s) => (
                <span key={s} className="rounded-lg bg-white/15 px-3 py-1 text-xs font-bold text-white backdrop-blur-sm">
                  {sportLabel(s)}
                </span>
              ))}
            </div>
          )}

          <h1 className="max-w-2xl text-4xl font-black leading-[1.04] text-white sm:text-5xl md:text-6xl">
            {arena.name}
          </h1>

          {location && (
            <p className="mt-3 flex items-center gap-1.5 text-sm font-semibold text-white/70">
              <svg className="h-3.5 w-3.5 flex-none" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                <path strokeLinecap="round" strokeLinejoin="round" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
              </svg>
              {location}
            </p>
          )}

          <div className="mt-4 flex flex-wrap items-center gap-3">
            {arena.openTime && arena.closeTime && (
              <span className="rounded-lg bg-white/12 px-3 py-1.5 text-xs font-bold text-white/80 backdrop-blur-sm">
                {arena.openTime} – {arena.closeTime}
              </span>
            )}
            {units.length > 0 && (
              <span className="rounded-lg bg-white/12 px-3 py-1.5 text-xs font-bold text-white/80 backdrop-blur-sm">
                {units.length} {units.length === 1 ? "court" : "courts"}
              </span>
            )}
            {startingPaise && (
              <span className="rounded-lg bg-[#16a34a]/80 px-3 py-1.5 text-xs font-bold text-white backdrop-blur-sm">
                from ₹{Math.round(startingPaise / 100)}/hr
              </span>
            )}
          </div>

          {/* Book CTA — shown in hero on mobile */}
          <div className="mt-7 flex gap-3">
            <a
              href="#book"
              className="rounded-xl bg-[#16a34a] px-7 py-3.5 text-sm font-black text-white active:scale-[.97]"
            >
              Book a slot →
            </a>
            {arena.phone && (
              <a
                href={`tel:${arena.phone}`}
                className="rounded-xl bg-white/15 px-5 py-3.5 text-sm font-black text-white backdrop-blur-sm"
              >
                Call
              </a>
            )}
          </div>
        </div>
      </section>

      {/* Sticky bottom booking bar — appears once #book scrolls out of view */}
      <MobileBookBar startingPaise={startingPaise} />

      {/* ── Content ───────────────────────────────────────────────────────────── */}
      <div className="mx-auto max-w-5xl px-5 py-8 sm:px-8">

        {/* Gallery strip */}
        {galleryPhotos.length > 0 && (
          <div className="mb-10 flex gap-2.5 overflow-x-auto pb-1 scrollbar-none">
            {galleryPhotos.map((url, i) => (
              // eslint-disable-next-line @next/next/no-img-element
              <img
                key={url}
                src={url}
                alt={`${arena.name} ${i + 2}`}
                className="h-36 w-56 flex-none rounded-2xl object-cover sm:h-44 sm:w-72"
              />
            ))}
          </div>
        )}

        <div className="grid gap-10 lg:grid-cols-[1fr_360px]">
          {/* ── Left col ──────────────────────────────────────────────────────── */}
          <div className="space-y-10">
            {/* About */}
            {arena.description && (
              <div>
                <h2 className="mb-2 text-lg font-black">About</h2>
                <p className="text-sm font-medium leading-7 text-[#475569]">{arena.description}</p>
              </div>
            )}

            {/* Courts */}
            <div>
              <h2 className="mb-3 text-lg font-black">Courts & Facilities</h2>
              <div className="space-y-2.5">
                {units.map((u) => (
                  <div key={u.id} className="flex items-center gap-4 rounded-2xl bg-[#f8fafc] px-4 py-4">
                    <div className="h-14 w-14 flex-none overflow-hidden rounded-xl bg-[#e2e8f0]">
                      {u.photoUrls?.[0] ? (
                        // eslint-disable-next-line @next/next/no-img-element
                        <img src={u.photoUrls[0]} alt={u.name} className="h-full w-full object-cover" />
                      ) : (
                        <div className="grid h-full place-items-center text-[10px] font-black text-[#94a3b8]">
                          {u.unitType?.slice(0, 2) ?? "UN"}
                        </div>
                      )}
                    </div>
                    <div className="min-w-0 flex-1">
                      <div className="font-black text-[#0d1210]">{u.name}</div>
                      <div className="mt-0.5 text-xs font-semibold text-[#94a3b8]">{unitTypeLabel(u.unitType)}</div>
                      {u.description && (
                        <div className="mt-1 line-clamp-1 text-xs font-medium text-[#64748b]">{u.description}</div>
                      )}
                    </div>
                    {rupeesPerHr(u.pricePerHourPaise) && (
                      <div className="text-sm font-black text-[#16a34a]">{rupeesPerHr(u.pricePerHourPaise)}</div>
                    )}
                  </div>
                ))}
              </div>
            </div>

            {/* Amenities */}
            {amenities.length > 0 && (
              <div>
                <h2 className="mb-3 text-lg font-black">Amenities</h2>
                <div className="flex flex-wrap gap-2">
                  {amenities.map((a) => (
                    <span key={a} className="rounded-xl bg-[#f0fdf4] px-4 py-2 text-xs font-bold text-[#166534]">
                      {a}
                    </span>
                  ))}
                </div>
              </div>
            )}

            {/* Visit info — mobile only (below content) */}
            <div className="rounded-2xl bg-[#f8fafc] p-5 lg:hidden">
              <h3 className="mb-4 font-black">Visit info</h3>
              <div className="space-y-3 text-sm">
                {location && (
                  <div className="flex gap-3">
                    <svg className="mt-0.5 h-4 w-4 flex-none text-[#94a3b8]" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                    </svg>
                    <span className="font-medium text-[#475569]">{location}</span>
                  </div>
                )}
                {arena.openTime && arena.closeTime && (
                  <div className="flex gap-3">
                    <svg className="mt-0.5 h-4 w-4 flex-none text-[#94a3b8]" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                      <circle cx={12} cy={12} r={10} /><path strokeLinecap="round" d="M12 6v6l4 2" />
                    </svg>
                    <span className="font-medium text-[#475569]">{arena.openTime} – {arena.closeTime}</span>
                  </div>
                )}
                {arena.phone && (
                  <div className="flex gap-3">
                    <svg className="mt-0.5 h-4 w-4 flex-none text-[#94a3b8]" fill="currentColor" viewBox="0 0 20 20">
                      <path d="M2 3a1 1 0 011-1h2.153a1 1 0 01.986.836l.74 4.435a1 1 0 01-.54 1.06l-1.548.773a11.037 11.037 0 006.105 6.105l.774-1.548a1 1 0 011.059-.54l4.435.74a1 1 0 01.836.986V17a1 1 0 01-1 1h-2C7.82 18 2 12.18 2 5V3z" />
                    </svg>
                    <a href={`tel:${arena.phone}`} className="font-black text-[#0d1210]">{arena.phone}</a>
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* ── Right col: booking widget ──────────────────────────────────────── */}
          <div id="book" className="scroll-mt-4 lg:sticky lg:top-6 lg:self-start">
            <div className="rounded-3xl bg-white p-6 shadow-[0_4px_32px_rgba(0,0,0,0.08)] ring-1 ring-black/5">
              <div className="mb-1 text-[11px] font-black uppercase tracking-widest text-[#94a3b8]">
                Powered by Swing
              </div>
              <h2 className="mb-5 text-xl font-black text-[#0d1210]">Book a slot</h2>

              {units.length > 0 ? (
                <BookingFlow
                  units={units}
                  arenaSlug={slug}
                  apiBaseUrl={API}
                  phone={arena.phone}
                  arenaOpenTime={arena.openTime}
                  arenaCloseTime={arena.closeTime}
                  startingPaise={startingPaise}
                />
              ) : (
                <div>
                  <p className="mb-4 text-sm font-medium text-[#64748b]">
                    Online booking isn&apos;t set up yet. Call to reserve your slot.
                  </p>
                  {arena.phone && (
                    <a
                      href={`tel:${arena.phone}`}
                      className="block rounded-xl bg-[#16a34a] py-3.5 text-center text-sm font-black text-white"
                    >
                      Call {arena.phone}
                    </a>
                  )}
                </div>
              )}
            </div>

            {/* Visit info — desktop sidebar */}
            {(location || arena.openTime || arena.phone) && (
              <div className="mt-4 hidden rounded-3xl bg-[#f8fafc] p-5 lg:block">
                <h3 className="mb-4 text-sm font-black text-[#0d1210]">Visit info</h3>
                <div className="space-y-3 text-sm">
                  {location && (
                    <div className="flex gap-3">
                      <svg className="mt-0.5 h-4 w-4 flex-none text-[#94a3b8]" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                      </svg>
                      <span className="font-medium text-[#475569]">{location}</span>
                    </div>
                  )}
                  {arena.openTime && arena.closeTime && (
                    <div className="flex gap-3">
                      <svg className="mt-0.5 h-4 w-4 flex-none text-[#94a3b8]" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                        <circle cx={12} cy={12} r={10} /><path strokeLinecap="round" d="M12 6v6l4 2" />
                      </svg>
                      <span className="font-medium text-[#475569]">{arena.openTime} – {arena.closeTime}</span>
                    </div>
                  )}
                  {arena.phone && (
                    <div className="flex gap-3">
                      <svg className="mt-0.5 h-4 w-4 flex-none text-[#94a3b8]" fill="currentColor" viewBox="0 0 20 20">
                        <path d="M2 3a1 1 0 011-1h2.153a1 1 0 01.986.836l.74 4.435a1 1 0 01-.54 1.06l-1.548.773a11.037 11.037 0 006.105 6.105l.774-1.548a1 1 0 011.059-.54l4.435.74a1 1 0 01.836.986V17a1 1 0 01-1 1h-2C7.82 18 2 12.18 2 5V3z" />
                      </svg>
                      <a href={`tel:${arena.phone}`} className="font-black text-[#0d1210]">{arena.phone}</a>
                    </div>
                  )}
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Bottom padding for mobile booking bar */}
      <div className="h-20 lg:hidden" />
    </div>
  );
}
