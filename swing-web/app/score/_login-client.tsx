"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { readScorerSession, writeScorerSession } from "./_session";

export default function ScoreLoginClient() {
  const router = useRouter();
  const [matchNumber, setMatchNumber] = useState("");
  const [pin, setPin] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // If an existing session is still valid, jump straight to the scoring UI.
  useEffect(() => {
    const session = readScorerSession();
    if (session) router.replace(`/score/${session.matchId}`);
  }, [router]);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (submitting) return;
    setError(null);
    setSubmitting(true);
    try {
      const res = await fetch("/api/scorer/auth", {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({
          // UI shows a locked `swing#` prefix; the user only types the
          // numeric tail. Reassemble before sending.
          liveCode: `swing#${matchNumber.trim()}`,
          livePin: pin.trim(),
        }),
        cache: "no-store",
      });
      const body = await res.json().catch(() => ({}));
      if (!res.ok || !body?.success) {
        setError(body?.error?.message ?? "Match ID or PIN is incorrect");
        setSubmitting(false);
        return;
      }
      const data = body.data as { token: string; matchId: string; expiresIn: number };
      writeScorerSession({
        token: data.token,
        matchId: data.matchId,
        expiresAt: Date.now() + data.expiresIn * 1000,
      });
      router.replace(`/score/${data.matchId}`);
    } catch {
      setError("Network error. Please try again.");
      setSubmitting(false);
    }
  }

  return (
    <main className="min-h-screen bg-neutral-50 flex items-center justify-center px-4 py-10">
      <div className="w-full max-w-sm">
        <div className="text-center mb-8">
          <div className="text-2xl font-semibold tracking-tight text-neutral-900">
            Score a Match
          </div>
          <p className="mt-2 text-sm text-neutral-600">
            Enter the match ID and PIN shared by the match organiser.
          </p>
        </div>

        <form
          onSubmit={onSubmit}
          className="bg-white rounded-2xl border border-neutral-200 p-6 space-y-4"
        >
          <label className="block">
            <span className="text-xs font-medium text-neutral-700 uppercase tracking-wide">
              Match ID
            </span>
            <div className="mt-1 flex items-stretch rounded-lg border border-neutral-300 focus-within:border-neutral-900 focus-within:ring-2 focus-within:ring-neutral-900/10 overflow-hidden">
              <span className="bg-neutral-100 text-neutral-500 px-3 flex items-center text-base font-medium select-none">
                swing#
              </span>
              <input
                type="text"
                inputMode="numeric"
                pattern="[0-9]*"
                autoComplete="off"
                autoFocus
                value={matchNumber}
                onChange={(e) =>
                  setMatchNumber(e.target.value.replace(/\D+/g, ""))
                }
                placeholder="9212"
                className="flex-1 px-3 py-2.5 text-base tracking-wider bg-transparent focus:outline-none"
                required
              />
            </div>
          </label>

          <label className="block">
            <span className="text-xs font-medium text-neutral-700 uppercase tracking-wide">
              PIN
            </span>
            <input
              type="password"
              inputMode="numeric"
              autoComplete="off"
              value={pin}
              onChange={(e) => setPin(e.target.value)}
              placeholder="Match PIN"
              className="mt-1 w-full rounded-lg border border-neutral-300 px-3 py-2.5 text-base tracking-wider focus:border-neutral-900 focus:outline-none focus:ring-2 focus:ring-neutral-900/10"
              required
            />
          </label>

          {error && (
            <div className="text-sm text-red-600">{error}</div>
          )}

          <button
            type="submit"
            disabled={submitting || !matchNumber || !pin}
            className="w-full rounded-lg bg-neutral-900 text-white font-medium py-3 text-sm tracking-wide disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {submitting ? "Verifying…" : "Continue to Scoring"}
          </button>
        </form>

        <p className="mt-6 text-center text-xs text-neutral-500">
          Don&apos;t have a match ID? Ask the match organiser to share it from the Swing app.
        </p>
      </div>
    </main>
  );
}
