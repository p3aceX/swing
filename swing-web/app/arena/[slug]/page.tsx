import type { Metadata } from "next";
import { notFound } from "next/navigation";
import Microsite, { type ArenaForMicrosite } from "./_microsite";

type PageProps = { params: Promise<{ slug: string }> };

const API = (
  process.env.NEXT_PUBLIC_API_BASE_URL ||
  process.env.API_BASE_URL ||
  "https://swing-backend-1007730655118.asia-south1.run.app"
).replace(/\/$/, "");

async function fetchArena(slug: string): Promise<ArenaForMicrosite | null> {
  try {
    const res = await fetch(`${API}/public/arena/p/${encodeURIComponent(slug)}`, {
      next: { revalidate: 60 },
    });
    if (!res.ok) return null;
    const body = (await res.json()) as { data?: ArenaForMicrosite };
    return body.data ?? null;
  } catch {
    return null;
  }
}

function sportLabel(s: string) {
  const t = s.trim();
  return t ? t.charAt(0).toUpperCase() + t.slice(1).toLowerCase() : "Other";
}

function marketingDescription(arena: ArenaForMicrosite) {
  const location = [arena.city, arena.state].filter(Boolean).join(", ");
  const sports = (arena.sports ?? []).map(sportLabel).join(", ");
  const units = arena.units ?? [];
  const unitLabel = units.length
    ? `${units.length} ${units.length === 1 ? "play area" : "play areas"}`
    : "sports venue";
  return ["Book instantly", unitLabel, sports, location].filter(Boolean).join(" · ") + ". Live availability, secure payments.";
}

// Inline boot script — runs synchronously to apply the saved theme before
// first paint, preventing the light/dark flash on cold load.
const THEME_BOOT = `(function(){try{var t=localStorage.getItem('arena-theme');if(t!=='light'&&t!=='dark'){t=window.matchMedia&&window.matchMedia('(prefers-color-scheme: dark)').matches?'dark':'light';}document.documentElement.setAttribute('data-theme',t);}catch(e){}})();`;

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
    ? [{ url: photo, width: 1200, height: 630, alt: arena.name }]
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

export default async function ArenaPage({ params }: PageProps) {
  const { slug } = await params;
  const arena = await fetchArena(slug);
  if (!arena) notFound();

  const canonicalSlug = arena.customSlug ?? arena.arenaSlug ?? slug;
  const publicUrl = `https://www.swingcricketapp.com/arena/${canonicalSlug}`;
  const fullAddress = [arena.address, arena.city, arena.state].filter(Boolean).join(", ");
  const photos = arena.photoUrls?.filter(Boolean) ?? [];

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
  };

  return (
    <>
      <script dangerouslySetInnerHTML={{ __html: THEME_BOOT }} />
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }} />
      <Microsite arena={arena} slug={slug} apiBaseUrl={API} />
    </>
  );
}
