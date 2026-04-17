"use client";

import Link from "next/link";
import { useMemo, useEffect, useTransition } from "react";
import { useRouter } from "next/navigation";
import type { MatchPageData } from "../match-page-client";
import { generateCommentary } from "@/lib/commentary-templates";

type CommentaryTone = "wicket" | "boundary" | "extra" | "dot" | "run";

type CommentaryEntry = {
  id: string;
  inningsNumber: number;
  overLabel: string;
  matchupLabel: string;
  title: string;
  detail: string;
  score: string;
  tone: CommentaryTone;
  outcome: string;
  runs: number;
  isWicket: boolean;
};

function normalize(value: string) {
  return value.trim().toLowerCase();
}

function teamMetaFor(match: MatchPageData, side: "A" | "B") {
  return side === "A" ? (match.teamMeta?.A ?? null) : (match.teamMeta?.B ?? null);
}

function sideTeamName(match: MatchPageData, side: "A" | "B") {
  return side === "A" ? match.teamAName : match.teamBName;
}

function sideInnings(match: MatchPageData, side: "A" | "B") {
  return match.innings.filter((innings) => innings.battingTeam === side);
}

function scoreSummary(match: MatchPageData, side: "A" | "B") {
  const innings = sideInnings(match, side);
  if (innings.length === 0) return "Yet to bat";
  if (innings.length === 1) {
    return `${innings[0].totalRuns}/${innings[0].totalWickets}`;
  }
  return innings.map((i) => `${i.totalRuns}/${i.totalWickets}`).join(" & ");
}

function isWinner(match: MatchPageData, side: "A" | "B") {
  if (!match.winnerId) return false;
  const name = sideTeamName(match, side);
  return match.winnerId === side || normalize(match.winnerId) === normalize(name);
}

function initials(value: string) {
  return value.split(/\s+/).map((part) => part[0] ?? "").join("").slice(0, 2).toUpperCase();
}

function shortTeamName(match: MatchPageData, side: "A" | "B") {
  const meta = teamMetaFor(match, side);
  if (meta?.shortName?.trim()) return meta.shortName.trim().toUpperCase();
  const raw = sideTeamName(match, side);
  const segment = raw.split("-")[0]?.trim() ?? raw;
  if (/^[a-z0-9 ]+$/i.test(segment) && segment.replace(/\s+/g, "").length <= 6)
    return segment.replace(/\s+/g, "").toUpperCase();
  return initials(raw);
}

function getName(match: MatchPageData, playerId: string) {
  return match.playerNames?.[playerId] ?? "Player";
}

function fmtDateLong(value: string) {
  return new Date(value).toLocaleDateString("en-IN", {
    weekday: "long", day: "numeric", month: "long", year: "numeric",
  });
}

function fmtTime(value: string) {
  return new Date(value).toLocaleTimeString("en-IN", {
    hour: "2-digit", minute: "2-digit", hour12: true,
  });
}


function describeBall(
  match: MatchPageData,
  inningsNumber: number,
  ball: MatchPageData["innings"][number]["ballEvents"][number],
): CommentaryEntry {
  const batter = getName(match, ball.batterId);
  const bowler = getName(match, ball.bowlerId);
  const fielder = ball.fielderId ? getName(match, ball.fielderId) : null;
  const dismissed = getName(match, ball.dismissedPlayerId ?? ball.batterId);

  const { title, detail } = generateCommentary({
    ballId: ball.id,
    batter, bowler, fielder, dismissed,
    outcome: ball.outcome,
    runs: ball.totalRuns,
    isWicket: ball.isWicket,
    dismissalType: ball.dismissalType,
    wagonZone: ball.wagonZone,
  });

  const tone: CommentaryTone = ball.isWicket ? "wicket"
    : (ball.outcome === "SIX" || ball.outcome === "FOUR") ? "boundary"
    : (ball.outcome === "WIDE" || ball.outcome === "NO_BALL" || ball.outcome === "BYE" || ball.outcome === "LEG_BYE") ? "extra"
    : ball.totalRuns === 0 ? "dot" : "run";

  return {
    id: ball.id,
    inningsNumber,
    overLabel: `${ball.overNumber + 1}.${ball.ballNumber}`,
    matchupLabel: `${bowler} to ${batter}`,
    title,
    detail,
    score: ball.scoreAfterBall ?? `+${ball.totalRuns}`,
    tone,
    outcome: ball.outcome,
    runs: ball.totalRuns,
    isWicket: ball.isWicket,
  };
}

function buildCommentary(match: MatchPageData) {
  const items: CommentaryEntry[] = [];
  for (const innings of match.innings) {
    for (const ball of innings.ballEvents) {
      items.push(describeBall(match, innings.inningsNumber, ball));
    }
  }
  return items.reverse();
}

function BallBadge({ outcome, isWicket, runs }: { outcome: string; isWicket: boolean; runs: number }) {
  let label: string;
  let cls: string;

  if (isWicket) {
    label = "W"; cls = "bg-red-600 text-white";
  } else if (outcome === "SIX") {
    label = "6"; cls = "bg-[#166534] text-white";
  } else if (outcome === "FOUR") {
    label = "4"; cls = "bg-[#1d4ed8] text-white";
  } else if (outcome === "WIDE") {
    label = "Wd"; cls = "bg-amber-100 text-amber-700 border border-amber-200";
  } else if (outcome === "NO_BALL") {
    label = "NB"; cls = "bg-amber-100 text-amber-700 border border-amber-200";
  } else if (runs === 0) {
    label = "·"; cls = "bg-[#F3F4F6] text-[#9CA3AF] border border-[#E5E7EB]";
  } else {
    label = String(runs); cls = "bg-[#E5E7EB] text-[#374151]";
  }

  return (
    <span className={`inline-flex h-8 w-8 shrink-0 items-center justify-center rounded-full text-xs font-bold ${cls}`}>
      {label}
    </span>
  );
}

function TeamScorePill({ match, side }: { match: MatchPageData; side: "A" | "B" }) {
  const meta = teamMetaFor(match, side);
  const winner = isWinner(match, side);
  const teamName = sideTeamName(match, side);

  return (
    <div className={`flex items-center gap-3 rounded-xl border px-3 py-2.5 ${winner ? "border-[#CCFF00]/30 bg-[#CCFF00]/5" : "border-white/10 bg-white/5"}`}>
      {meta?.logoUrl ? (
        <img src={meta.logoUrl} alt={teamName} className="h-8 w-8 rounded-full object-cover" />
      ) : (
        <div className="flex h-8 w-8 items-center justify-center rounded-full bg-white/10 text-[10px] font-black text-white">
          {shortTeamName(match, side)}
        </div>
      )}
      <div className="min-w-0">
        <div className="text-xs font-semibold text-white truncate">{teamName}</div>
        <div className="text-xs text-white/50">{scoreSummary(match, side)}</div>
      </div>
    </div>
  );
}

export default function CommentaryPageClient({ match }: { match: MatchPageData }) {
  const router = useRouter();
  const [isRefreshing, startRefresh] = useTransition();
  const commentary = useMemo(() => buildCommentary(match), [match]);
  const isLive = match.status === "IN_PROGRESS";

  useEffect(() => {
    if (!isLive) return;
    const id = setInterval(() => { router.refresh(); }, 8000);
    return () => clearInterval(id);
  }, [isLive, router]);

  function refreshMatch() {
    startRefresh(() => { router.refresh(); });
  }

  return (
    <div className="min-h-screen bg-white text-[#111827]">
      {/* Nav — dark */}
      <nav className="sticky top-0 z-40 border-b border-white/5 bg-[#0a0f1a]/95 backdrop-blur-md">
        <div className="mx-auto flex h-14 max-w-3xl items-center justify-between px-4">
          <Link href={`/m/${match.id}`} className="text-sm font-semibold text-white/70 hover:text-white transition-colors">
            ← Back to match
          </Link>
          <div className="flex items-center gap-2">
            <span className="text-[10px] font-bold uppercase tracking-[0.2em] text-white/30">Commentary</span>
            <button
              type="button"
              onClick={refreshMatch}
              className="rounded-full border border-white/10 px-3 py-1.5 text-[10px] font-semibold uppercase tracking-widest text-white/50 hover:text-white/80 transition-colors"
            >
              {isRefreshing ? "↻" : "Refresh"}
            </button>
          </div>
        </div>
      </nav>

      {/* Match header — dark */}
      <div className="bg-[#0a0f1a]">
        <div className="mx-auto max-w-3xl px-4 py-5">
          <div className="text-[10px] font-bold uppercase tracking-[0.2em] text-white/30 mb-1">
            {match.competition?.name ?? match.matchType.replace(/_/g, " ")}
          </div>
          <div className="text-xs text-white/50 mb-4">
            {fmtDateLong(match.scheduledAt)} · {fmtTime(match.scheduledAt)}
          </div>
          <div className="grid gap-2 sm:grid-cols-2">
            <TeamScorePill match={match} side="A" />
            <TeamScorePill match={match} side="B" />
          </div>
        </div>
      </div>

      {/* Commentary feed — white */}
      <div className="mx-auto max-w-3xl px-4 py-6">
        <div className="flex items-center justify-between mb-4">
          <h1 className="text-base font-bold text-[#111827]">Ball-by-ball commentary</h1>
          <span className="text-xs text-[#9CA3AF]">{commentary.length} deliveries</span>
        </div>

        {commentary.length === 0 ? (
          <div className="rounded-xl border border-[#E5E7EB] bg-[#F9FAFB] px-5 py-12 text-center text-sm text-[#9CA3AF]">
            Commentary will appear once the first delivery is recorded.
          </div>
        ) : (
          <div className="divide-y divide-[#F3F4F6]">
            {commentary.map((item) => (
              <div key={item.id} className="py-4">
                <div className="text-xs text-[#9CA3AF] mb-1.5">
                  {item.overLabel} · {item.matchupLabel}
                </div>
                <div className="flex items-start gap-3">
                  <BallBadge outcome={item.outcome} isWicket={item.isWicket} runs={item.runs} />
                  <div className="flex-1 min-w-0">
                    <span className={`text-sm font-bold mr-2 ${
                      item.tone === "wicket" ? "text-red-600"
                      : item.tone === "boundary" ? "text-[#1d4ed8]"
                      : "text-[#111827]"
                    }`}>
                      {item.title}
                    </span>
                    <span className="text-sm text-[#374151] leading-relaxed">{item.detail}</span>
                  </div>
                  <span className="text-xs font-semibold text-[#9CA3AF] shrink-0 pt-0.5">{item.score}</span>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Footer */}
      <div className="mx-auto max-w-3xl px-4 py-8 text-center border-t border-[#F3F4F6]">
        <Link href="/" className="text-sm font-black tracking-tight text-[#9CA3AF] hover:text-[#374151] transition-colors">
          SWING<span className="text-[#CCFF00]/60">.</span>
        </Link>
      </div>
    </div>
  );
}
