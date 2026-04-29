import { redirect, notFound } from "next/navigation";

type PageProps = { params: Promise<{ slug?: string[] }> };

type Arena = {
  customSlug?: string | null;
  arenaSlug?: string | null;
  name?: string;
};

const API = (
  process.env.NEXT_PUBLIC_API_BASE_URL ||
  process.env.API_BASE_URL ||
  "https://swing-backend-1007730655118.asia-south1.run.app"
).replace(/\/$/, "");

export default async function LegacyArenaRedirect({ params }: PageProps) {
  const { slug = [] } = await params;

  let arenaData: Arena | null = null;

  try {
    // single custom slug
    if (slug.length === 1) {
      const res = await fetch(`${API}/public/arena/p/${encodeURIComponent(slug[0])}`, {
        next: { revalidate: 60 },
      });
      if (res.ok) {
        const body = (await res.json()) as { data?: Arena };
        arenaData = body.data ?? null;
        // if it resolved, redirect to canonical /arena/:slug
        const canonical = arenaData?.customSlug ?? arenaData?.arenaSlug ?? slug[0];
        redirect(`/arena/${canonical}`);
      }
    }

    // city/arena slug pair
    if (slug.length === 2) {
      const res = await fetch(
        `${API}/public/arena/${encodeURIComponent(slug[0])}/${encodeURIComponent(slug[1])}`,
        { next: { revalidate: 60 } },
      );
      if (res.ok) {
        const body = (await res.json()) as { data?: Arena };
        arenaData = body.data ?? null;
        const canonical = arenaData?.customSlug ?? arenaData?.arenaSlug ?? slug[1];
        redirect(`/arena/${canonical}`);
      }
    }
  } catch (e) {
    throw e;
  }

  notFound();
}
