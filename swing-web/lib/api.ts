const API = process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:3000";

async function get(path: string) {
  try {
    const res = await fetch(`${API}${path}`, { cache: "no-store" });
    if (!res.ok) return null;
    const json = await res.json();
    return json.data ?? json;
  } catch {
    return null;
  }
}

export async function getTournaments(params?: { status?: string; q?: string; format?: string }) {
  const qs = params
    ? "?" + Object.entries(params).filter(([, v]) => v).map(([k, v]) => `${k}=${encodeURIComponent(v!)}`).join("&")
    : "";
  return get(`/public/tournaments${qs}`);
}

export async function getTournament(slug: string) {
  return get(`/public/tournament/${slug}`);
}

export async function getTournamentMatches(slug: string) {
  return get(`/public/tournament/${slug}/matches`);
}

export async function getTournamentStandings(slug: string) {
  return get(`/public/tournament/${slug}/standings`);
}

export async function getMatch(id: string) {
  return get(`/public/match/${id}`);
}

export type Highlight = { title: string; youtubeUrl: string };

export function getYouTubeId(url: string): string | null {
  const match = url.match(
    /(?:youtube\.com\/(?:watch\?v=|embed\/|shorts\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})/
  );
  return match?.[1] ?? null;
}
