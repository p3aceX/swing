import Link from "next/link";
import { getTournamentMatches, getTournaments } from "@/lib/api";

export const dynamic = "force-dynamic";

type Tournament = {
  id: string;
  name: string;
  slug: string | null;
  status: string;
};
type PublicMatch = {
  id: string;
  status: string;
  scheduledAt: string;
  teamAName: string;
  teamBName: string;
};
type LiveMatch = PublicMatch & {
  tournamentName: string;
  tournamentSlug: string;
};

export default async function Home() {
  const raw: Tournament[] | null = await getTournaments();
  const live = (raw ?? []).filter((t) => t.status === "ONGOING");
  const liveMatchGroups = await Promise.all(
    live.map(async (tournament) => {
      const key = tournament.slug ?? tournament.id;
      const matches =
        ((await getTournamentMatches(key)) as PublicMatch[] | null) ?? [];
      return matches
        .filter((match) => match.status === "IN_PROGRESS")
        .map((match) => ({
          ...match,
          tournamentName: tournament.name,
          tournamentSlug: key,
        }));
    }),
  );
  const liveMatches = liveMatchGroups.flat().slice(0, 6) as LiveMatch[];

  return (
    <div className="bg-[#080A0E] text-white min-h-screen">
      {/* ── NAV ── */}
      <nav className="fixed top-0 inset-x-0 z-50 px-5 md:px-10 h-16 bg-[#080A0E]/75 backdrop-blur-2xl border-b border-white/[0.05]">
        <div className="max-w-6xl mx-auto h-full flex items-center justify-between">
          <Link href="/" className="font-black italic text-base tracking-tight">
            SWING<span className="text-[#CCFF00]">.</span>
          </Link>
          <div className="flex items-center gap-3">
            {live.length > 0 && (
              <Link
                href={`/t/${live[0].slug ?? live[0].id}`}
                className="flex items-center gap-2 text-[12px] font-bold bg-[#CCFF00] text-black px-4 py-2 rounded-full hover:bg-white transition-colors"
              >
                <span className="w-1.5 h-1.5 rounded-full bg-black animate-pulse" />
                Watch Live
              </Link>
            )}
            <Link
              href="/tournaments"
              className="text-[12px] font-bold bg-white text-black px-4 py-2 rounded-full hover:bg-[#CCFF00] transition-colors"
            >
              View Tournaments
            </Link>
          </div>
        </div>
      </nav>

      {/* ── HERO ── */}
      <section className="pt-16 min-h-screen flex flex-col justify-center relative overflow-hidden px-5 md:px-10">
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[700px] h-[500px] bg-[#CCFF00]/5 rounded-full blur-[120px] pointer-events-none" />

        <div className="max-w-6xl mx-auto w-full relative z-10">
          {live.length > 0 && (
            <Link
              href={`/t/${live[0].slug ?? live[0].id}`}
              className="inline-flex items-center gap-2 bg-[#CCFF00]/10 border border-[#CCFF00]/30 text-[#CCFF00] text-[11px] font-bold uppercase tracking-widest px-4 py-2 rounded-full mb-8 hover:bg-[#CCFF00]/20 transition-colors"
            >
              <span className="w-1.5 h-1.5 rounded-full bg-[#CCFF00] animate-pulse" />
              {live[0].name} is live right now
              <span className="ml-1 opacity-60">→</span>
            </Link>
          )}

          <h1 className="font-black italic text-[13vw] md:text-[10vw] lg:text-[8.5vw] leading-[0.88] tracking-tighter mb-6">
            <span className="block text-white">INDIA&apos;S</span>
            <span className="block text-white">CRICKET</span>
            <span className="block text-[#CCFF00]">
              ECOSYSTEM<span className="text-white">.</span>
            </span>
          </h1>

          <p className="text-white/40 text-base md:text-lg font-medium max-w-lg leading-relaxed mb-10">
            Live scores, tournaments, academies & arenas — everything cricket,
            one platform.
          </p>

          <div className="flex flex-wrap gap-8 md:gap-12">
            {[
              { val: "1M+", label: "Players" },
              { val: "500+", label: "Tournaments" },
              { val: "10K+", label: "Matches Scored" },
              { val: "200+", label: "Academies" },
            ].map(({ val, label }) => (
              <div key={label}>
                <p className="text-2xl md:text-3xl font-black text-white">
                  {val}
                </p>
                <p className="text-[11px] font-semibold uppercase tracking-widest text-white/25 mt-0.5">
                  {label}
                </p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {liveMatches.length > 0 && (
        <section className="px-5 pb-16 md:px-10">
          <div className="max-w-6xl mx-auto">
            <div className="flex flex-wrap items-end justify-between gap-4 mb-6">
              <div>
                <p className="text-[11px] font-bold uppercase tracking-widest text-white/25 mb-2">
                  Live Now
                </p>
                <h2 className="text-3xl md:text-4xl font-black italic tracking-tight text-white">
                  Live Matches
                </h2>
              </div>
              <Link
                href="/tournaments"
                className="text-[12px] font-bold text-white/50 hover:text-white transition-colors"
              >
                View all tournaments
              </Link>
            </div>

            <div className="grid gap-3 md:grid-cols-2 xl:grid-cols-3">
              {liveMatches.map((match) => (
                <Link
                  key={match.id}
                  href={`/m/${match.id}`}
                  className="rounded-[26px] border border-[#CCFF00]/15 bg-[#CCFF00]/[0.06] p-4 hover:bg-[#CCFF00]/10 transition-colors"
                >
                  <div className="flex items-center justify-between gap-3 mb-4">
                    <div className="text-[10px] font-bold uppercase tracking-[0.18em] text-white/35 truncate">
                      {match.tournamentName}
                    </div>
                    <span className="flex items-center gap-1.5 text-[10px] font-bold text-[#CCFF00]">
                      <span className="w-1.5 h-1.5 rounded-full bg-[#CCFF00] animate-pulse" />
                      LIVE
                    </span>
                  </div>

                  <div className="space-y-2">
                    <div className="rounded-2xl bg-white/[0.04] px-3 py-3">
                      <div className="text-sm font-semibold text-white truncate">
                        {match.teamAName}
                      </div>
                    </div>
                    <div className="flex items-center justify-center text-[10px] font-bold uppercase tracking-[0.24em] text-white/25">
                      vs
                    </div>
                    <div className="rounded-2xl bg-white/[0.04] px-3 py-3">
                      <div className="text-sm font-semibold text-white truncate">
                        {match.teamBName}
                      </div>
                    </div>
                  </div>

                  <div className="mt-4 flex items-center justify-between gap-3">
                    <span className="text-[11px] text-white/30">
                      {new Date(match.scheduledAt).toLocaleDateString("en-IN", {
                        day: "numeric",
                        month: "short",
                      })}{" "}
                      ·{" "}
                      {new Date(match.scheduledAt).toLocaleTimeString("en-IN", {
                        hour: "2-digit",
                        minute: "2-digit",
                        hour12: true,
                      })}
                    </span>
                    <span className="text-[11px] font-bold text-white/60">
                      Match Centre →
                    </span>
                  </div>
                </Link>
              ))}
            </div>
          </div>
        </section>
      )}

      {/* ── FOOTER ── */}
      <footer className="px-5 md:px-10 py-10 flex items-center justify-between max-w-6xl mx-auto border-t border-white/[0.05]">
        <span className="font-black italic text-sm text-white/20 tracking-tight">
          SWING<span className="text-[#CCFF00]">.</span>
        </span>
        <p className="text-[11px] text-white/15">© 2026 Swing Cricket</p>
      </footer>
    </div>
  );
}
