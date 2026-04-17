"use client";

import { useEffect, useState } from "react";
import { useParams } from "next/navigation";

const API_BASE_URL = (
  process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:3000"
).replace(/\/$/, "");

type OverlayData = {
  matchId: string;
  status: string;
  format: string;
  teamA: { name: string; logoUrl: string | null };
  teamB: { name: string; logoUrl: string | null };
  youtubeUrl?: string | null;
  batting: {
    team: string;
    runs: number;
    wickets: number;
    overs: number;
    crr: number;
    target?: number | null;
    toWin?: number | null;
    rrr?: number | null;
    ballsRemaining?: number | null;
  } | null;
  currentInnings: number | null;
  striker: { name: string; runs: number; balls: number; fours: number; sixes: number } | null;
  nonStriker: { name: string; runs: number; balls: number } | null;
  bowler: { name: string; overs: number; wickets: number; runs: number; economy: number } | null;
  thisOver: { label: string; outcome: string }[];
  updatedAt: string;
};

function fmtOvers(o: number) {
  const w = Math.floor(o);
  const b = Math.round((o - w) * 10);
  return `${w}.${b}`;
}

function extractYoutubeId(url: string): string | null {
  try {
    const u = new URL(url);
    if (u.hostname.includes("youtu.be")) return u.pathname.slice(1).split("?")[0];
    return u.searchParams.get("v");
  } catch {
    return null;
  }
}

function BallDot({ ball }: { ball: { label: string; outcome: string } }) {
  const isW = ball.outcome === "WICKET";
  const isFour = ball.outcome === "FOUR";
  const isSix = ball.outcome === "SIX";
  const isDot = ball.outcome === "DOT";
  const isExtra = ball.outcome === "WIDE" || ball.outcome === "NO_BALL";

  const base =
    "w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold border";
  const cls = isW
    ? `${base} bg-red-600 border-red-500 text-white`
    : isFour
      ? `${base} bg-blue-600 border-blue-500 text-white`
      : isSix
        ? `${base} bg-purple-600 border-purple-500 text-white`
        : isDot
          ? `${base} bg-white/5 border-white/10 text-white/40`
          : isExtra
            ? `${base} bg-orange-600 border-orange-500 text-white`
            : `${base} bg-white/10 border-white/20 text-white`;

  return <div className={cls}>{ball.label}</div>;
}

function ScoreCard({ data }: { data: OverlayData }) {
  const { batting, teamA, teamB, currentInnings, thisOver, striker, nonStriker, bowler, status } = data;
  const battingTeam = currentInnings === 1 ? teamA : teamB;
  const logo = battingTeam.logoUrl;
  const initials = battingTeam.name.slice(0, 2).toUpperCase();
  const isLive = status === "IN_PROGRESS";
  const isCompleted = status === "COMPLETED";

  return (
    <div className="rounded-2xl border border-white/10 bg-white/5 backdrop-blur-xl p-5 space-y-4">
      {/* Badge */}
      <div className="flex items-center gap-2">
        {isLive && (
          <span className="flex items-center gap-1.5 bg-red-600 text-white text-[10px] font-bold tracking-widest px-2.5 py-1 rounded-full">
            <span className="w-1.5 h-1.5 rounded-full bg-white animate-pulse" />
            LIVE
          </span>
        )}
        {isCompleted && (
          <span className="bg-white/10 text-white/60 text-[10px] font-bold tracking-widest px-2.5 py-1 rounded-full">
            FINAL
          </span>
        )}
        <span className="text-white/40 text-xs">{data.format}</span>
      </div>

      {/* Team + Score */}
      <div className="flex items-center gap-4">
        {logo ? (
          <img src={logo} alt={battingTeam.name} className="w-14 h-14 rounded-full object-contain bg-white/5 border border-white/10" />
        ) : (
          <div className="w-14 h-14 rounded-full bg-white/10 border border-white/10 flex items-center justify-center text-lg font-black text-white/60">
            {initials}
          </div>
        )}
        <div>
          <div className="text-white/60 text-xs font-semibold tracking-widest uppercase">{battingTeam.name}</div>
          {batting ? (
            <>
              <div className="text-white text-4xl font-black leading-none">
                {batting.runs}/{batting.wickets}
              </div>
              <div className="flex items-center gap-2 mt-1 text-xs text-white/50">
                <span>{fmtOvers(batting.overs)} ov</span>
                <span className="text-emerald-400 font-semibold">CRR {batting.crr.toFixed(2)}</span>
              </div>
            </>
          ) : (
            <div className="text-white/40 text-sm mt-1">Match not started</div>
          )}
        </div>
      </div>

      {/* Chase info */}
      {batting?.toWin != null && batting.toWin > 0 && (
        <div className="rounded-xl bg-orange-500/10 border border-orange-500/20 px-4 py-2.5 text-sm">
          <span className="text-orange-300 font-semibold">Need {batting.toWin} off {batting.ballsRemaining} balls</span>
          {batting.rrr != null && (
            <span className="text-white/40 ml-2">· RRR {batting.rrr.toFixed(2)}</span>
          )}
        </div>
      )}

      {/* Batters */}
      {(striker || nonStriker) && (
        <div className="space-y-1">
          <div className="text-[10px] text-white/30 uppercase tracking-widest mb-2">Batting</div>
          {striker && (
            <div className="flex items-center justify-between text-sm">
              <span className="text-white font-semibold">{striker.name} <span className="text-yellow-400">*</span></span>
              <span className="text-white font-bold">{striker.runs} <span className="text-white/40 text-xs">({striker.balls})</span></span>
            </div>
          )}
          {nonStriker && (
            <div className="flex items-center justify-between text-sm">
              <span className="text-white/70">{nonStriker.name}</span>
              <span className="text-white/70">{nonStriker.runs} <span className="text-white/30 text-xs">({nonStriker.balls})</span></span>
            </div>
          )}
        </div>
      )}

      {/* Bowler */}
      {bowler && (
        <div className="text-xs text-white/50">
          🎳 <span className="text-white/80 font-semibold">{bowler.name}</span>
          {" "}· {fmtOvers(bowler.overs)} ov · {bowler.wickets}/{bowler.runs} · Econ {bowler.economy.toFixed(1)}
        </div>
      )}

      {/* This over */}
      {thisOver.length > 0 && (
        <div>
          <div className="text-[10px] text-white/30 uppercase tracking-widest mb-2">This Over</div>
          <div className="flex items-center gap-1.5 flex-wrap">
            {thisOver.map((b, i) => <BallDot key={i} ball={b} />)}
          </div>
        </div>
      )}
    </div>
  );
}

export default function PublicMatchPage() {
  const { id } = useParams<{ id: string }>();
  const [data, setData] = useState<OverlayData | null>(null);
  const [error, setError] = useState(false);

  useEffect(() => {
    let active = true;
    async function poll() {
      try {
        const res = await fetch(`${API_BASE_URL}/public/overlay/${id}`);
        if (!res.ok) { setError(true); return; }
        const json = await res.json();
        if (active) setData(json.data);
      } catch { setError(true); }
    }
    poll();
    const iv = setInterval(poll, 5000);
    return () => { active = false; clearInterval(iv); };
  }, [id]);

  const youtubeId = data?.youtubeUrl ? extractYoutubeId(data.youtubeUrl) : null;

  if (error) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#0a0a14] text-white/40 text-sm">
        Match not found.
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#0a0a14] text-white">
      {/* Header */}
      <div className="border-b border-white/5 px-4 py-3 flex items-center gap-3">
        <span className="text-white font-black tracking-tight text-lg">Swing</span>
        <span className="text-white/20 text-sm">·</span>
        {data ? (
          <span className="text-white/60 text-sm truncate">
            {data.teamA.name} vs {data.teamB.name}
          </span>
        ) : (
          <span className="h-4 w-40 bg-white/5 rounded animate-pulse" />
        )}
      </div>

      <div className="max-w-5xl mx-auto px-4 py-6 space-y-6">
        {/* YouTube embed */}
        {youtubeId ? (
          <div className="rounded-2xl overflow-hidden border border-white/10 bg-black aspect-video">
            <iframe
              src={`https://www.youtube.com/embed/${youtubeId}?autoplay=1&mute=0`}
              className="w-full h-full"
              allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
              allowFullScreen
            />
          </div>
        ) : (
          /* Placeholder when no stream is set */
          <div className="rounded-2xl border border-white/10 bg-white/[0.03] aspect-video flex flex-col items-center justify-center gap-3 text-white/20">
            <svg className="w-12 h-12" viewBox="0 0 24 24" fill="currentColor">
              <path d="M23.495 6.205a3.007 3.007 0 00-2.088-2.088C19.54 3.617 12 3.617 12 3.617s-7.524 0-9.407.5A3.007 3.007 0 00.505 6.205 31.247 31.247 0 000 12a31.247 31.247 0 00.522 5.783 3.007 3.007 0 002.088 2.088C4.476 20.383 12 20.383 12 20.383s7.506 0 9.395-.5a3.007 3.007 0 002.088-2.088A31.247 31.247 0 0024 12a31.247 31.247 0 00-.505-5.795zM9.609 15.601V8.408l6.264 3.602z"/>
            </svg>
            <p className="text-sm">Live stream not available</p>
          </div>
        )}

        {/* Score card */}
        {data ? (
          <ScoreCard data={data} />
        ) : (
          <div className="rounded-2xl border border-white/10 bg-white/5 h-64 animate-pulse" />
        )}

        {/* Footer */}
        <div className="text-center text-white/20 text-xs pb-4">
          Powered by <span className="font-semibold">Swing Cricket</span>
        </div>
      </div>
    </div>
  );
}
