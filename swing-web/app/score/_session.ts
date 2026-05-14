// Tiny helper around the scorer session that lives in sessionStorage.
// sessionStorage (not localStorage) so the token is dropped when the tab
// closes — scorers tend to share devices, and pin-only auth deserves a
// short blast radius if the laptop walks away.

export type ScorerSession = {
  token: string;
  matchId: string;
  expiresAt: number; // epoch ms
};

const KEY = "swing.scorer.session";

export function readScorerSession(): ScorerSession | null {
  if (typeof window === "undefined") return null;
  try {
    const raw = window.sessionStorage.getItem(KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw) as ScorerSession;
    if (!parsed.token || !parsed.matchId || !parsed.expiresAt) return null;
    if (Date.now() >= parsed.expiresAt) {
      window.sessionStorage.removeItem(KEY);
      return null;
    }
    return parsed;
  } catch {
    return null;
  }
}

export function writeScorerSession(session: ScorerSession) {
  if (typeof window === "undefined") return;
  window.sessionStorage.setItem(KEY, JSON.stringify(session));
}

export function clearScorerSession() {
  if (typeof window === "undefined") return;
  window.sessionStorage.removeItem(KEY);
}

export async function scorerFetch(
  path: string,
  init: RequestInit = {},
): Promise<Response> {
  const session = readScorerSession();
  const headers = new Headers(init.headers ?? {});
  if (session?.token) headers.set("authorization", `Bearer ${session.token}`);
  if (init.body && !headers.has("content-type")) {
    headers.set("content-type", "application/json");
  }
  return fetch(`/api/scorer${path}`, { ...init, headers, cache: "no-store" });
}
