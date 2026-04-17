import Link from "next/link";
import { getTournaments } from "@/lib/api";

export const dynamic = "force-dynamic";

type Tournament = {
  id: string;
  name: string;
  slug: string | null;
  status: string;
  tournamentFormat: string;
  startDate: string;
  endDate?: string | null;
  city?: string | null;
  venueName?: string | null;
  logoUrl?: string | null;
  _count: { teams: number };
};

const STATUS_LABEL: Record<string, string> = {
  ONGOING: "Live",
  UPCOMING: "Upcoming",
  COMPLETED: "Completed",
};

const FORMAT_LABEL: Record<string, string> = {
  T10: "T10",
  T20: "T20",
  ONE_DAY: "ODI",
  TWO_INNINGS: "Test",
  BOX_CRICKET: "Box",
  CUSTOM: "Custom",
};

const STATUSES = ["ALL", "ONGOING", "UPCOMING", "COMPLETED"];

const fmtDate = (d: string) =>
  new Date(d).toLocaleDateString("en-IN", {
    day: "numeric",
    month: "short",
    year: "numeric",
  });

function cbUrl(url: string): string {
  let h = 0;
  for (let i = 0; i < url.length; i++) h = (h * 31 + url.charCodeAt(i)) >>> 0;
  return `${url}${url.includes("?") ? "&" : "?"}_v=${h.toString(36)}`;
}

function initials(name: string) {
  return name
    .split(/\s+/)
    .map((w) => w[0])
    .join("")
    .toUpperCase()
    .slice(0, 2);
}

function getStatusClasses(status: string) {
  switch (status) {
    case "ONGOING":
      return "text-[#CCFF00] bg-[#CCFF00]/10 border border-[#CCFF00]/20";
    case "UPCOMING":
      return "text-sky-300 bg-sky-400/10 border border-sky-400/15";
    case "COMPLETED":
      return "text-white/55 bg-white/[0.05] border border-white/[0.08]";
    default:
      return "text-white/55 bg-white/[0.05] border border-white/[0.08]";
  }
}

function getFormatGlow(format: string) {
  switch (format) {
    case "T10":
      return "from-pink-500/20 to-orange-400/10";
    case "T20":
      return "from-sky-500/20 to-cyan-400/10";
    case "ONE_DAY":
      return "from-violet-500/20 to-fuchsia-400/10";
    case "TWO_INNINGS":
      return "from-amber-400/20 to-yellow-300/10";
    default:
      return "from-white/10 to-white/5";
  }
}

export default async function TournamentsPage({
  searchParams,
}: {
  searchParams: Promise<{ status?: string; q?: string; format?: string }>;
}) {
  const params = await searchParams;
  const activeStatus = params.status?.toUpperCase() ?? "ALL";
  const q = params.q ?? "";
  const format = params.format ?? "";

  const raw: Tournament[] | null = await getTournaments({
    status: activeStatus === "ALL" ? undefined : activeStatus,
    q: q || undefined,
    format: format || undefined,
  });

  const tournaments: Tournament[] = raw ?? [];
  const liveCount = tournaments.filter((t) => t.status === "ONGOING").length;
  const upcomingCount = tournaments.filter((t) => t.status === "UPCOMING").length;
  const completedCount = tournaments.filter((t) => t.status === "COMPLETED").length;

  return (
    <div className="min-h-screen bg-[#06080D] text-white overflow-x-hidden">
      {/* background */}
      <div className="fixed inset-0 -z-10">
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_left,rgba(204,255,0,0.08),transparent_28%),radial-gradient(circle_at_top_right,rgba(70,130,255,0.12),transparent_25%),radial-gradient(circle_at_bottom_left,rgba(255,255,255,0.05),transparent_20%)]" />
        <div className="absolute inset-0 bg-[linear-gradient(to_bottom,rgba(255,255,255,0.03)_1px,transparent_1px),linear-gradient(to_right,rgba(255,255,255,0.03)_1px,transparent_1px)] bg-[size:44px_44px] opacity-[0.04]" />
        <div className="absolute inset-0 bg-[#06080D]/85" />
      </div>

      {/* nav */}
      <nav className="fixed top-0 inset-x-0 z-50 h-16 border-b border-white/[0.06] bg-[#06080D]/70 backdrop-blur-2xl">
        <div className="max-w-7xl mx-auto h-full px-5 md:px-8 flex items-center justify-between">
          <Link href="/" className="font-black italic tracking-tight text-lg">
            SWING<span className="text-[#CCFF00]">.</span>
          </Link>

          <div className="hidden md:flex items-center gap-2 text-[11px] font-semibold text-white/35">
            <span className="px-3 py-1 rounded-full border border-white/[0.08] bg-white/[0.03]">
              Cricket OS
            </span>
            <span className="px-3 py-1 rounded-full border border-[#CCFF00]/20 bg-[#CCFF00]/10 text-[#CCFF00]">
              Tournaments
            </span>
          </div>
        </div>
      </nav>

      <main className="pt-16">
        <div className="max-w-7xl mx-auto px-5 md:px-8">
          {/* hero */}
          <section className="relative pt-10 md:pt-14 pb-8 md:pb-10">
            <div className="rounded-[32px] border border-white/[0.08] bg-white/[0.03] backdrop-blur-xl overflow-hidden">
              <div className="absolute inset-0 bg-[radial-gradient(circle_at_15%_20%,rgba(204,255,0,0.12),transparent_20%),radial-gradient(circle_at_80%_10%,rgba(81,137,255,0.16),transparent_22%)] pointer-events-none" />
              <div className="relative p-6 md:p-10">
                <div className="flex flex-col xl:flex-row xl:items-end xl:justify-between gap-8">
                  <div className="max-w-3xl">
                    <p className="text-[11px] md:text-xs font-bold uppercase tracking-[0.3em] text-white/35 mb-4">
                      Swing Cricket Ecosystem
                    </p>

                    <h1 className="text-[2.4rem] md:text-6xl font-black italic tracking-[-0.04em] leading-[0.95]">
                      Discover the most
                      <span className="block text-transparent bg-clip-text bg-gradient-to-r from-white to-[#CCFF00]">
                        electric tournaments
                      </span>
                    </h1>

                    <p className="mt-5 max-w-2xl text-sm md:text-base text-white/45 leading-relaxed">
                      Track live competitions, explore upcoming events, and dive into every tournament with a sharper,
                      richer Swing experience.
                    </p>
                  </div>

                  <div className="grid grid-cols-3 gap-3 md:gap-4 w-full xl:w-auto xl:min-w-[360px]">
                    <div className="rounded-2xl border border-white/[0.08] bg-black/20 p-4">
                      <p className="text-[11px] uppercase tracking-[0.2em] text-white/30 font-bold">Total</p>
                      <p className="mt-2 text-2xl md:text-3xl font-black tracking-tight">{tournaments.length}</p>
                    </div>
                    <div className="rounded-2xl border border-[#CCFF00]/15 bg-[#CCFF00]/[0.05] p-4">
                      <p className="text-[11px] uppercase tracking-[0.2em] text-white/30 font-bold">Live</p>
                      <p className="mt-2 text-2xl md:text-3xl font-black tracking-tight text-[#CCFF00]">{liveCount}</p>
                    </div>
                    <div className="rounded-2xl border border-white/[0.08] bg-black/20 p-4">
                      <p className="text-[11px] uppercase tracking-[0.2em] text-white/30 font-bold">Upcoming</p>
                      <p className="mt-2 text-2xl md:text-3xl font-black tracking-tight">{upcomingCount}</p>
                    </div>
                  </div>
                </div>

                <div className="mt-8 flex flex-wrap items-center gap-3">
                  <div className="inline-flex items-center gap-2 rounded-full border border-[#CCFF00]/20 bg-[#CCFF00]/10 px-3 py-1.5 text-[11px] font-bold text-[#CCFF00]">
                    <span className="w-2 h-2 rounded-full bg-[#CCFF00] animate-pulse" />
                    {liveCount} live now
                  </div>
                  <div className="inline-flex items-center gap-2 rounded-full border border-white/[0.08] bg-white/[0.04] px-3 py-1.5 text-[11px] font-semibold text-white/50">
                    {upcomingCount} upcoming
                  </div>
                  <div className="inline-flex items-center gap-2 rounded-full border border-white/[0.08] bg-white/[0.04] px-3 py-1.5 text-[11px] font-semibold text-white/50">
                    {completedCount} completed
                  </div>
                </div>
              </div>
            </div>
          </section>

          {/* filters */}
          <section className="pb-6">
            <div className="rounded-[28px] border border-white/[0.08] bg-white/[0.025] backdrop-blur-xl p-4 md:p-5">
              <div className="flex flex-col xl:flex-row xl:items-center gap-4 xl:gap-5">
                <div className="flex items-center gap-1.5 bg-black/20 border border-white/[0.07] rounded-full p-1 overflow-x-auto">
                  {STATUSES.map((s) => {
                    const href = new URLSearchParams({
                      ...(s !== "ALL" ? { status: s } : {}),
                      ...(q ? { q } : {}),
                      ...(format ? { format } : {}),
                    }).toString();

                    const isActive = activeStatus === s;

                    return (
                      <Link
                        key={s}
                        href={`/tournaments${href ? "?" + href : ""}`}
                        className={`whitespace-nowrap text-[12px] font-bold px-4 py-2 rounded-full transition-all ${
                          isActive
                            ? s === "ONGOING"
                              ? "bg-[#CCFF00] text-black shadow-[0_0_30px_rgba(204,255,0,0.18)]"
                              : "bg-white text-black"
                            : "text-white/45 hover:text-white hover:bg-white/[0.05]"
                        }`}
                      >
                        {s === "ONGOING" ? (
                          <span className="flex items-center gap-1.5">
                            <span className="w-1.5 h-1.5 rounded-full bg-current animate-pulse" />
                            Live
                          </span>
                        ) : s === "ALL" ? (
                          "All"
                        ) : (
                          STATUS_LABEL[s]
                        )}
                      </Link>
                    );
                  })}
                </div>

                <form method="GET" action="/tournaments" className="flex-1 flex flex-col sm:flex-row gap-3">
                  <div className="relative flex-1">
                    <input
                      type="text"
                      name="q"
                      defaultValue={q}
                      placeholder="Search by tournament name..."
                      className="w-full rounded-2xl border border-white/[0.08] bg-black/20 px-4 py-3 text-sm text-white placeholder:text-white/20 outline-none focus:border-[#CCFF00]/35 focus:bg-white/[0.03] transition-all"
                    />
                  </div>

                  {activeStatus !== "ALL" && <input type="hidden" name="status" value={activeStatus} />}

                  <button
                    type="submit"
                    className="rounded-2xl px-5 py-3 text-sm font-bold bg-[#CCFF00] text-black hover:opacity-95 transition-opacity"
                  >
                    Search
                  </button>
                </form>
              </div>
            </div>
          </section>

          {/* content */}
          {tournaments.length === 0 ? (
            <section className="py-20">
              <div className="rounded-[28px] border border-dashed border-white/[0.1] bg-white/[0.02] text-center p-12">
                <div className="mx-auto mb-4 w-16 h-16 rounded-2xl border border-white/[0.08] bg-white/[0.04] flex items-center justify-center text-white/30 text-2xl">
                  🏏
                </div>
                <h3 className="text-xl font-black tracking-tight">No tournaments found</h3>
                <p className="mt-2 text-sm text-white/35">
                  Try changing the filters or searching with a different keyword.
                </p>
              </div>
            </section>
          ) : (
            <section className="pb-16">
              <div className="rounded-[30px] border border-white/[0.08] bg-white/[0.025] backdrop-blur-xl overflow-hidden">
                {/* header row */}
                <div className="flex items-center gap-4 px-4 sm:px-6 py-3 border-b border-white/[0.06] text-[11px] font-bold uppercase tracking-[0.22em] text-white/25">
                  <div className="flex-1 min-w-0">Tournament</div>
                  <div className="hidden sm:block w-16 shrink-0">Format</div>
                  <div className="hidden md:block w-28 shrink-0">Location</div>
                  <div className="hidden lg:block w-36 shrink-0">Dates</div>
                  <div className="w-24 shrink-0 text-right">Status</div>
                </div>

                <div className="divide-y divide-white/[0.05]">
                  {tournaments.map((t) => {
                    const href = `/t/${t.slug ?? t.id}`;
                    const isLive = t.status === "ONGOING";

                    return (
                      <Link
                        key={t.id}
                        href={href}
                        className="flex items-center gap-4 px-4 sm:px-6 py-4 hover:bg-white/[0.035] transition-colors group"
                      >
                        {/* logo + name */}
                        <div className="flex-1 min-w-0 flex items-center gap-3">
                          <div
                            className={`w-10 h-10 rounded-xl shrink-0 border border-white/[0.08] bg-gradient-to-br ${getFormatGlow(
                              t.tournamentFormat
                            )} overflow-hidden flex items-center justify-center`}
                          >
                            {t.logoUrl ? (
                              <img src={cbUrl(t.logoUrl)} alt="" className="w-full h-full object-cover" />
                            ) : (
                              <span className="text-xs font-black text-white/80">{initials(t.name)}</span>
                            )}
                          </div>

                          <div className="min-w-0">
                            <div className="flex items-center gap-2 flex-wrap">
                              <h3 className="text-sm font-bold text-white/90 group-hover:text-white transition-colors truncate">
                                {t.name}
                              </h3>
                              {isLive && (
                                <span className="inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[10px] font-bold text-[#CCFF00] bg-[#CCFF00]/10 border border-[#CCFF00]/15">
                                  <span className="w-1.5 h-1.5 rounded-full bg-[#CCFF00] animate-pulse" />
                                  LIVE
                                </span>
                              )}
                            </div>
                            <p className="text-[11px] text-white/30 mt-0.5">{t._count.teams} teams</p>
                          </div>
                        </div>

                        {/* format */}
                        <div className="hidden sm:block w-16 shrink-0">
                          <span className="inline-flex rounded-full px-2.5 py-1 text-[11px] font-bold border border-white/[0.08] bg-black/20 text-white/65">
                            {FORMAT_LABEL[t.tournamentFormat] ?? t.tournamentFormat}
                          </span>
                        </div>

                        {/* location */}
                        <div className="hidden md:block w-28 shrink-0 text-xs text-white/40 truncate">
                          {t.city ?? t.venueName ?? "—"}
                        </div>

                        {/* dates */}
                        <div className="hidden lg:block w-36 shrink-0 text-xs text-white/40">
                          <div>{fmtDate(t.startDate)}</div>
                          {t.endDate && <div className="text-white/20 mt-0.5">to {fmtDate(t.endDate)}</div>}
                        </div>

                        {/* status */}
                        <div className="w-24 shrink-0 flex justify-end">
                          <span className={`text-[11px] font-bold rounded-full px-2.5 py-1 ${getStatusClasses(t.status)}`}>
                            {STATUS_LABEL[t.status] ?? t.status}
                          </span>
                        </div>
                      </Link>
                    );
                  })}
                </div>
              </div>
            </section>
          )}
        </div>
      </main>

      {/* footer */}
      <footer className="border-t border-white/[0.06]">
        <div className="max-w-7xl mx-auto px-5 md:px-8 py-8 flex items-center justify-between gap-4 flex-wrap">
          <span className="font-black italic text-sm text-white/25 tracking-tight">
            SWING<span className="text-[#CCFF00]">.</span>
          </span>
          <p className="text-[11px] text-white/15">© 2026 Swing Cricket</p>
        </div>
      </footer>
    </div>
  );
}