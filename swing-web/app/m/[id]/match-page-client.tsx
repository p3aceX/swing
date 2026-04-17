"use client";

import Link from "next/link";
import {
  useEffect,
  useMemo,
  useState,
  useTransition,
} from "react";
import { useRouter } from "next/navigation";
import { generateCommentary } from "@/lib/commentary-templates";
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from "recharts";

// ── Types ──────────────────────────────────────────────────────────────────

type BallEvent = {
  id: string;
  overNumber: number;
  ballNumber: number;
  batterId: string;
  bowlerId: string;
  fielderId?: string | null;
  outcome: string;
  runs: number;
  extras: number;
  totalRuns: number;
  isWicket: boolean;
  dismissalType?: string | null;
  dismissedPlayerId?: string | null;
  scoreAfterBall?: string | null;
  wagonZone?: string | null;
};

type Innings = {
  id: string;
  inningsNumber: number;
  battingTeam: string;
  totalRuns: number;
  totalWickets: number;
  totalOvers: number;
  extras: number;
  isCompleted: boolean;
  ballEvents: BallEvent[];
};

type TeamMeta = {
  name: string;
  shortName?: string | null;
  logoUrl?: string | null;
};

type CompetitionMeta = {
  id: string;
  name: string;
  slug?: string | null;
  logoUrl?: string | null;
};

type PlayerOfTheMatch = {
  id: string;
  name: string;
  avatarUrl?: string | null;
  team: string;
  summary: string;
};

export type MatchPageData = {
  id: string;
  format: string;
  matchType: string;
  status: string;
  teamAName: string;
  teamBName: string;
  teamAPlayerIds: string[];
  teamBPlayerIds: string[];
  teamACaptainId?: string | null;
  teamBCaptainId?: string | null;
  teamAViceCaptainId?: string | null;
  teamBViceCaptainId?: string | null;
  teamAWicketKeeperId?: string | null;
  teamBWicketKeeperId?: string | null;
  venueName?: string | null;
  scheduledAt: string;
  startedAt?: string | null;
  tossWonBy?: string | null;
  tossDecision?: string | null;
  winnerId?: string | null;
  winMargin?: string | null;
  tournamentId?: string | null;
  customOvers?: number | null;
  round?: string | null;
  innings: Innings[];
  playerNames?: Record<string, string>;
  playerOfTheMatch?: PlayerOfTheMatch | null;
  competition?: CompetitionMeta | null;
  teamMeta?: {
    A?: TeamMeta | null;
    B?: TeamMeta | null;
  };
  highlights?: Array<{ id: string; title: string; url: string }> | null;
  youtubeUrl?: string | null;
};

type BatterStats = {
  id: string;
  name: string;
  runs: number;
  balls: number;
  fours: number;
  sixes: number;
  isOut: boolean;
  dismissal: string;
  lastSeenAt: number;
};

type BowlerStats = {
  id: string;
  name: string;
  runs: number;
  legalBalls: number;
  wickets: number;
  wides: number;
  noBalls: number;
};

type MatchTab = "live" | "scorecard" | "playing11" | "analysis" | "commentary" | "highlights";

// ── Helpers ────────────────────────────────────────────────────────────────

const FORMAT_OVERS: Record<string, number> = {
  T10: 10,
  T20: 20,
  ONE_DAY: 50,
  BOX_CRICKET: 6,
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

function isWinner(match: MatchPageData, side: "A" | "B") {
  if (!match.winnerId) return false;
  const name = sideTeamName(match, side);
  return match.winnerId === side || normalize(match.winnerId) === normalize(name);
}

function initials(value: string) {
  return value.split(/\s+/).map((p) => p[0] ?? "").join("").slice(0, 2).toUpperCase();
}

function shortTeamName(match: MatchPageData, side: "A" | "B") {
  const meta = teamMetaFor(match, side);
  if (meta?.shortName?.trim()) return meta.shortName.trim().toUpperCase();
  const raw = sideTeamName(match, side);
  const seg = raw.split("-")[0]?.trim() ?? raw;
  if (/^[a-z0-9 ]+$/i.test(seg) && seg.replace(/\s+/g, "").length <= 6)
    return seg.replace(/\s+/g, "").toUpperCase();
  return initials(raw);
}

function getName(match: MatchPageData, id: string) {
  return match.playerNames?.[id] ?? "Player";
}

function fmtDateLong(v: string) {
  return new Date(v).toLocaleDateString("en-IN", {
    weekday: "long", day: "numeric", month: "long", year: "numeric",
  });
}

function fmtTime(v: string) {
  return new Date(v).toLocaleTimeString("en-IN", {
    hour: "2-digit", minute: "2-digit", hour12: true,
  });
}

function fmtOvers(overs: number) {
  const w = Math.floor(overs);
  const b = Math.round((overs - w) * 10);
  return `${w}.${b}`;
}

/** Convert raw legal-ball count to cricket overs notation (e.g. 7 → "1.1") */
function ballsToOvers(legalBalls: number) {
  return `${Math.floor(legalBalls / 6)}.${legalBalls % 6}`;
}

function limitedOvers(match: MatchPageData) {
  if (match.format === "CUSTOM") return match.customOvers ?? null;
  return FORMAT_OVERS[match.format] ?? null;
}

function formatLabel(format: string, customOvers?: number | null) {
  const labels: Record<string, string> = {
    T20: "T20", T10: "T10", ONE_DAY: "ODI", BOX_CRICKET: "Box Cricket",
    TEST: "Test", TWO_INNINGS: "2-Innings", CUSTOM: customOvers ? `${customOvers}-over` : "Custom",
  };
  return labels[format] ?? format;
}

function sideInnings(match: MatchPageData, side: "A" | "B") {
  return match.innings.filter((i) => i.battingTeam === side);
}

function scoreSummary(match: MatchPageData, side: "A" | "B") {
  const innings = sideInnings(match, side);
  if (innings.length === 0) return { main: "Yet to bat", sub: "" };
  if (innings.length === 1) {
    const i = innings[0];
    return { main: `${i.totalRuns}/${i.totalWickets}`, sub: `(${fmtOvers(i.totalOvers)} ov)` };
  }
  return {
    main: innings.map((i) => `${i.totalRuns}/${i.totalWickets}`).join(" & "),
    sub: `${innings.length} innings`,
  };
}

function legalBall(b: BallEvent) {
  return !["WIDE", "NO_BALL"].includes(b.outcome);
}

function dismissalSummary(ball: BallEvent, match: MatchPageData) {
  const bowler = getName(match, ball.bowlerId);
  const fielder = ball.fielderId ? getName(match, ball.fielderId) : null;
  switch (ball.dismissalType) {
    case "BOWLED": return `b ${bowler}`;
    case "LBW": return `lbw b ${bowler}`;
    case "CAUGHT": return fielder ? `c ${fielder} b ${bowler}` : `c & b ${bowler}`;
    case "STUMPED": return fielder ? `st ${fielder} b ${bowler}` : `st b ${bowler}`;
    case "RUN_OUT": return fielder ? `run out (${fielder})` : "run out";
    case "HIT_WICKET": return `hit wkt b ${bowler}`;
    case "RETIRED_HURT": return "retired hurt";
    default: return ball.dismissalType?.replace(/_/g, " ").toLowerCase() ?? "out";
  }
}

function battingStats(innings: Innings, match: MatchPageData): BatterStats[] {
  const dismissalMap = new Map<string, string>();
  for (const ball of innings.ballEvents) {
    if (!ball.isWicket) continue;
    const id = ball.dismissedPlayerId ?? ball.batterId;
    dismissalMap.set(id, dismissalSummary(ball, match));
  }
  const stats = new Map<string, BatterStats>();
  innings.ballEvents.forEach((ball, index) => {
    const cur = stats.get(ball.batterId) ?? {
      id: ball.batterId,
      name: getName(match, ball.batterId),
      runs: 0, balls: 0, fours: 0, sixes: 0,
      isOut: false, dismissal: "not out", lastSeenAt: index,
    };
    cur.lastSeenAt = index;
    if (legalBall(ball)) cur.balls++;
    cur.runs += ball.runs;
    if (ball.outcome === "FOUR") cur.fours++;
    if (ball.outcome === "SIX") cur.sixes++;
    stats.set(ball.batterId, cur);
  });
  for (const [id, dis] of dismissalMap) {
    const s = stats.get(id);
    if (s) { s.isOut = true; s.dismissal = dis; }
  }
  return [...stats.values()]; // preserve batting order (Map insertion order = first ball faced)
}

function bowlingStats(innings: Innings, match: MatchPageData): BowlerStats[] {
  const stats = new Map<string, BowlerStats>();
  for (const ball of innings.ballEvents) {
    const cur = stats.get(ball.bowlerId) ?? {
      id: ball.bowlerId, name: getName(match, ball.bowlerId),
      runs: 0, legalBalls: 0, wickets: 0, wides: 0, noBalls: 0,
    };
    const bowlerRuns = (ball.outcome === "BYE" || ball.outcome === "LEG_BYE") ? ball.runs : ball.runs + ball.extras;
    cur.runs += bowlerRuns;
    if (legalBall(ball)) cur.legalBalls++;
    if (ball.outcome === "WIDE") cur.wides++;
    if (ball.outcome === "NO_BALL") cur.noBalls++;
    if (ball.isWicket && !["RUN_OUT", "RETIRED_HURT", "RETIRED_OUT"].includes(ball.dismissalType ?? ""))
      cur.wickets++;
    stats.set(ball.bowlerId, cur);
  }
  return [...stats.values()]; // preserve bowling order (Map insertion order = first over bowled)
}

function matchResult(match: MatchPageData) {
  if (match.status !== "COMPLETED") return null;
  if (!match.winnerId) return "Match ended — No Result";
  const margin = match.winMargin ? ` by ${match.winMargin}` : "";
  const winnerName =
    match.winnerId === "A" ? match.teamAName
    : match.winnerId === "B" ? match.teamBName
    : match.winnerId;
  return `${winnerName} won${margin}`;
}

function tossSummary(match: MatchPageData) {
  if (!match.tossWonBy) return null;
  const tossTeam = match.tossWonBy === "A" ? match.teamAName : match.tossWonBy === "B" ? match.teamBName : match.tossWonBy;
  const dec = match.tossDecision === "BAT" ? "elected to bat" : match.tossDecision === "BOWL" ? "elected to bowl" : match.tossDecision?.toLowerCase() ?? "";
  return `${tossTeam} won the toss and ${dec}`;
}

// ── Chart accordion card ───────────────────────────────────────────────────

function ChartCard({
  title,
  subtitle,
  defaultOpen = false,
  children,
}: {
  title: string;
  subtitle?: string;
  defaultOpen?: boolean;
  children: React.ReactNode;
}) {
  const [open, setOpen] = useState(defaultOpen);
  return (
    <div className="rounded-xl border border-[#E5E7EB] bg-white overflow-hidden">
      <button
        type="button"
        onClick={() => setOpen((v) => !v)}
        className="w-full flex items-center justify-between gap-3 px-4 py-3.5 text-left"
      >
        <div>
          <p className="text-sm font-semibold text-[#374151]">{title}</p>
          {subtitle && <p className="text-xs text-[#9CA3AF] mt-0.5">{subtitle}</p>}
        </div>
        <svg
          width="16" height="16" viewBox="0 0 16 16" fill="none"
          className={`shrink-0 text-[#9CA3AF] transition-transform duration-200 ${open ? "rotate-180" : ""}`}
        >
          <path d="M3 6l5 5 5-5" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
        </svg>
      </button>
      {open && <div className="px-4 pb-4 border-t border-[#F3F4F6]">{children}</div>}
    </div>
  );
}

// ── Run Progression Chart ──────────────────────────────────────────────────

function RunProgressionChart({
  innings,
  maxOvers,
  teamNames,
}: {
  innings: Innings[];
  maxOvers: number;
  teamNames: [string, string];
}) {
  const totalOvers = maxOvers || Math.max(...innings.map((i) => Math.ceil(i.totalOvers)), 6);
  const COLORS = ["#3b82f6", "#f472b6"];

  function buildProgression(inn: Innings) {
    const overMap = new Map<number, number>();
    for (const b of inn.ballEvents) {
      overMap.set(b.overNumber, (overMap.get(b.overNumber) ?? 0) + b.runs + b.extras);
    }
    let cum = 0;
    const result: Record<number, number> = { 0: 0 };
    for (const [ov, runs] of Array.from(overMap.entries()).sort(([a], [b]) => a - b)) {
      cum += runs;
      result[ov + 1] = cum;
    }
    return result;
  }

  const progressions = innings.map(buildProgression);
  const data: Record<string, number | string>[] = [];
  for (let ov = 0; ov <= totalOvers; ov++) {
    const row: Record<string, number | string> = { over: ov };
    progressions.forEach((prog, idx) => {
      if (prog[ov] !== undefined) row[`inn${idx}`] = prog[ov];
    });
    data.push(row);
  }

  return (
    <ResponsiveContainer width="100%" height={200}>
      <AreaChart data={data} margin={{ top: 8, right: 4, left: -16, bottom: 0 }}>
        <defs>
          {innings.map((_, idx) => (
            <linearGradient key={idx} id={`rp-grad${idx}`} x1="0" y1="0" x2="0" y2="1">
              <stop offset="5%" stopColor={COLORS[idx]} stopOpacity={0.12} />
              <stop offset="95%" stopColor={COLORS[idx]} stopOpacity={0} />
            </linearGradient>
          ))}
        </defs>
        <CartesianGrid strokeDasharray="3 3" stroke="#F3F4F6" vertical={false} />
        <XAxis dataKey="over" tick={{ fill: "#9CA3AF", fontSize: 10 }} axisLine={{ stroke: "#E5E7EB" }} tickLine={false} />
        <YAxis tick={{ fill: "#9CA3AF", fontSize: 10 }} axisLine={false} tickLine={false} />
        <Tooltip
          contentStyle={{ border: "1px solid #E5E7EB", borderRadius: 8, fontSize: 12 }}
          labelFormatter={(l) => `Over ${l}`}
          formatter={(value, name) => [value, name]}
        />
        <Legend wrapperStyle={{ fontSize: 11, paddingTop: 8 }} />
        {innings.map((_, idx) => (
          <Area key={idx} type="monotone" dataKey={`inn${idx}`}
            name={teamNames[idx] ?? `Inn ${idx + 1}`}
            stroke={COLORS[idx]} strokeWidth={2}
            fill={`url(#rp-grad${idx})`}
            dot={false} activeDot={{ r: 3, strokeWidth: 0 }} connectNulls
          />
        ))}
      </AreaChart>
    </ResponsiveContainer>
  );
}

// ── Run Rate Chart ─────────────────────────────────────────────────────────

function RunRateChart({
  innings,
  teamNames,
}: {
  innings: Innings[];
  teamNames: [string, string];
}) {
  const COLORS = ["#3b82f6", "#f472b6"];

  function buildRunRate(inn: Innings) {
    const overMap = new Map<number, number>();
    for (const b of inn.ballEvents) {
      overMap.set(b.overNumber, (overMap.get(b.overNumber) ?? 0) + b.runs + b.extras);
    }
    let cum = 0;
    const result: Record<number, number> = {};
    for (const [ov, runs] of Array.from(overMap.entries()).sort(([a], [b]) => a - b)) {
      cum += runs;
      const completedOvers = ov + 1;
      result[completedOvers] = parseFloat((cum / completedOvers).toFixed(2));
    }
    return result;
  }

  const rates = innings.map(buildRunRate);
  const maxOv = Math.max(...rates.flatMap((r) => Object.keys(r).map(Number)), 1);
  const data: Record<string, number | string>[] = [];
  for (let ov = 1; ov <= maxOv; ov++) {
    const row: Record<string, number | string> = { over: ov };
    rates.forEach((r, idx) => { if (r[ov] !== undefined) row[`rr${idx}`] = r[ov]; });
    data.push(row);
  }

  return (
    <ResponsiveContainer width="100%" height={180}>
      <AreaChart data={data} margin={{ top: 8, right: 4, left: -16, bottom: 0 }}>
        <defs>
          {innings.map((_, idx) => (
            <linearGradient key={idx} id={`rr-grad${idx}`} x1="0" y1="0" x2="0" y2="1">
              <stop offset="5%" stopColor={COLORS[idx]} stopOpacity={0.1} />
              <stop offset="95%" stopColor={COLORS[idx]} stopOpacity={0} />
            </linearGradient>
          ))}
        </defs>
        <CartesianGrid strokeDasharray="3 3" stroke="#F3F4F6" vertical={false} />
        <XAxis dataKey="over" tick={{ fill: "#9CA3AF", fontSize: 10 }} axisLine={{ stroke: "#E5E7EB" }} tickLine={false} />
        <YAxis tick={{ fill: "#9CA3AF", fontSize: 10 }} axisLine={false} tickLine={false} />
        <Tooltip
          contentStyle={{ border: "1px solid #E5E7EB", borderRadius: 8, fontSize: 12 }}
          labelFormatter={(l) => `After over ${l}`}
          formatter={(value, name) => [`${value} rpo`, name]}
        />
        <Legend wrapperStyle={{ fontSize: 11, paddingTop: 8 }} />
        {innings.map((_, idx) => (
          <Area key={idx} type="monotone" dataKey={`rr${idx}`}
            name={teamNames[idx] ?? `Inn ${idx + 1}`}
            stroke={COLORS[idx]} strokeWidth={2}
            fill={`url(#rr-grad${idx})`}
            dot={false} activeDot={{ r: 3, strokeWidth: 0 }} connectNulls
          />
        ))}
      </AreaChart>
    </ResponsiveContainer>
  );
}

// ── Runs Per Over Chart ────────────────────────────────────────────────────

import {
  BarChart,
  Bar,
  Cell,
  ReferenceLine,
} from "recharts";

function RunsPerOverChart({
  inn,
  teamName,
}: {
  inn: Innings;
  teamName: string;
}) {
  const overMap = new Map<number, { runs: number; wickets: number }>();
  for (const b of inn.ballEvents) {
    const cur = overMap.get(b.overNumber) ?? { runs: 0, wickets: 0 };
    cur.runs += b.runs + b.extras;
    if (b.isWicket) cur.wickets++;
    overMap.set(b.overNumber, cur);
  }

  const data = Array.from(overMap.entries())
    .sort(([a], [b]) => a - b)
    .map(([ov, { runs, wickets }]) => ({ over: ov + 1, runs, wickets }));

  if (data.length === 0) return <p className="py-4 text-center text-xs text-[#9CA3AF]">No data</p>;

  const avg = parseFloat((data.reduce((s, d) => s + d.runs, 0) / data.length).toFixed(1));

  return (
    <ResponsiveContainer width="100%" height={180}>
      <BarChart data={data} margin={{ top: 8, right: 4, left: -16, bottom: 0 }}>
        <CartesianGrid strokeDasharray="3 3" stroke="#F3F4F6" vertical={false} />
        <XAxis dataKey="over" tick={{ fill: "#9CA3AF", fontSize: 10 }} axisLine={{ stroke: "#E5E7EB" }} tickLine={false} />
        <YAxis tick={{ fill: "#9CA3AF", fontSize: 10 }} axisLine={false} tickLine={false} />
        <Tooltip
          contentStyle={{ border: "1px solid #E5E7EB", borderRadius: 8, fontSize: 12 }}
          labelFormatter={(l) => `Over ${l}`}
          formatter={(value, name) => [value, name === "runs" ? "Runs" : name]}
        />
        <ReferenceLine y={avg} stroke="#9CA3AF" strokeDasharray="4 2"
          label={{ value: `avg ${avg}`, position: "right", fill: "#9CA3AF", fontSize: 10 }} />
        <Bar dataKey="runs" name="Runs" radius={[3, 3, 0, 0]}>
          {data.map((entry, i) => (
            <Cell
              key={i}
              fill={entry.runs >= 15 ? "#f59e0b" : entry.runs >= 10 ? "#22c55e" : entry.runs >= 6 ? "#3b82f6" : "#94a3b8"}
              opacity={0.85}
            />
          ))}
        </Bar>
      </BarChart>
    </ResponsiveContainer>
  );
}

// ── Partnership Chart ──────────────────────────────────────────────────────

import { BarChart as HBarChart } from "recharts";

function PartnershipChart({
  inn,
  match,
}: {
  inn: Innings;
  match: MatchPageData;
}) {
  const partnerships: { label: string; runs: number; balls: number }[] = [];
  let currentPair = new Set<string>();
  let pRuns = 0, pBalls = 0;

  for (const ball of inn.ballEvents) {
    if (currentPair.size < 2 && !currentPair.has(ball.batterId)) currentPair.add(ball.batterId);
    pRuns += ball.runs + (["BYE", "LEG_BYE"].includes(ball.outcome) ? ball.extras : 0);
    if (legalBall(ball)) pBalls++;
    if (ball.isWicket && currentPair.size === 2) {
      const [b1, b2] = [...currentPair];
      const n1 = getName(match, b1!).split(" ").pop() ?? getName(match, b1!);
      const n2 = getName(match, b2!).split(" ").pop() ?? getName(match, b2!);
      partnerships.push({ label: `${n1} & ${n2}`, runs: pRuns, balls: pBalls });
      currentPair.delete(ball.dismissedPlayerId ?? ball.batterId);
      pRuns = 0; pBalls = 0;
    }
  }
  if (pRuns > 0 && currentPair.size === 2) {
    const [b1, b2] = [...currentPair];
    const n1 = getName(match, b1!).split(" ").pop() ?? getName(match, b1!);
    const n2 = getName(match, b2!).split(" ").pop() ?? getName(match, b2!);
    partnerships.push({ label: `${n1} & ${n2}`, runs: pRuns, balls: pBalls });
  }

  if (partnerships.length === 0) return <p className="py-4 text-center text-xs text-[#9CA3AF]">No partnership data</p>;

  return (
    <ResponsiveContainer width="100%" height={Math.max(partnerships.length * 40, 120)}>
      <HBarChart data={partnerships} layout="vertical" margin={{ top: 4, right: 40, left: 8, bottom: 0 }}>
        <CartesianGrid strokeDasharray="3 3" stroke="#F3F4F6" horizontal={false} />
        <XAxis type="number" tick={{ fill: "#9CA3AF", fontSize: 10 }} axisLine={{ stroke: "#E5E7EB" }} tickLine={false} />
        <YAxis type="category" dataKey="label" tick={{ fill: "#6B7280", fontSize: 11 }} axisLine={false} tickLine={false} width={80} />
        <Tooltip
          contentStyle={{ border: "1px solid #E5E7EB", borderRadius: 8, fontSize: 12 }}
          formatter={(value, name, props) => [`${value} (${props.payload.balls}b)`, "Runs"]}
        />
        <Bar dataKey="runs" fill="#3b82f6" radius={[0, 3, 3, 0]} opacity={0.8} />
      </HBarChart>
    </ResponsiveContainer>
  );
}

// ── Scoring Breakdown ──────────────────────────────────────────────────────

function ScoringBreakdown({ inn }: { inn: Innings }) {
  const balls = inn.ballEvents;
  const legal = balls.filter(legalBall);
  const total = legal.length;
  if (total === 0) return null;

  const dots = legal.filter((b) => !b.isWicket && b.runs === 0 && b.extras === 0).length;
  const fours = balls.filter((b) => b.outcome === "FOUR").length;
  const sixes = balls.filter((b) => b.outcome === "SIX").length;
  const wides = balls.filter((b) => b.outcome === "WIDE").length;
  const noBalls = balls.filter((b) => b.outcome === "NO_BALL").length;
  const boundaryRuns = fours * 4 + sixes * 6;
  const dotPct = total > 0 ? Math.round((dots / total) * 100) : 0;
  const boundaryPct = inn.totalRuns > 0 ? Math.round((boundaryRuns / inn.totalRuns) * 100) : 0;

  const stats = [
    { label: "Dot %", value: `${dotPct}%`, sub: `${dots} dots`, color: "#6B7280" },
    { label: "Boundary %", value: `${boundaryPct}%`, sub: `${boundaryRuns} runs`, color: "#3b82f6" },
    { label: "4s / 6s", value: `${fours} / ${sixes}`, sub: "boundaries", color: "#f59e0b" },
    { label: "Extras", value: `${wides + noBalls}`, sub: `${wides}wd ${noBalls}nb`, color: "#a855f7" },
  ];

  return (
    <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
      {stats.map((s) => (
        <div key={s.label} className="rounded-xl bg-[#F9FAFB] border border-[#E5E7EB] p-3 text-center">
          <div className="text-xl font-black" style={{ color: s.color }}>{s.value}</div>
          <div className="mt-0.5 text-[10px] font-semibold uppercase tracking-widest text-[#6B7280]">{s.label}</div>
          <div className="mt-0.5 text-[10px] text-[#9CA3AF]">{s.sub}</div>
        </div>
      ))}
    </div>
  );
}


// ── Live State ─────────────────────────────────────────────────────────────

function currentLiveState(match: MatchPageData) {
  const activeInnings = match.innings.find((i) => !i.isCompleted);
  if (!activeInnings) return null;
  const balls = activeInnings.ballEvents;
  if (balls.length === 0) return { innings: activeInnings, striker: null, nonStriker: null, bowler: null, lastBalls: [] };

  const lastBall = balls[balls.length - 1];
  const legalCount = balls.filter(legalBall).length;
  const overNum = Math.floor(legalCount / 6);
  const thisOverBalls = balls.filter((b) => b.overNumber === overNum);
  const dismissed = new Set(balls.filter((b) => b.isWicket).map((b) => b.dismissedPlayerId ?? b.batterId));
  const seen = new Map<string, number>();
  balls.forEach((b, i) => { seen.set(b.batterId, i); });
  const activeBatters = [...seen.entries()].filter(([id]) => !dismissed.has(id)).sort((a, b) => b[1] - a[1]);
  const striker = activeBatters[0]?.[0] ?? null;
  const nonStriker = activeBatters[1]?.[0] ?? null;
  const bowler = lastBall!.bowlerId;

  return { innings: activeInnings, striker, nonStriker, bowler, lastBalls: thisOverBalls };
}

// ── helpers ─────────────────────────────────────────────────────────────────

/** Appends a short hash of the URL so browsers re-fetch when the URL changes */
function cbUrl(url: string): string {
  let h = 0;
  for (let i = 0; i < url.length; i++) h = (h * 31 + url.charCodeAt(i)) >>> 0;
  return `${url}${url.includes("?") ? "&" : "?"}_v=${h.toString(36)}`;
}

// ── TeamLogo ───────────────────────────────────────────────────────────────

function TeamLogo({ meta, name, size = 48, dark = false }: { meta: TeamMeta | null; name: string; size?: number; dark?: boolean }) {
  if (meta?.logoUrl) {
    return (
      <img src={cbUrl(meta.logoUrl)} alt={name} width={size} height={size}
        className="rounded-full object-cover flex-shrink-0" style={{ width: size, height: size }} />
    );
  }
  return (
    <div className={`flex items-center justify-center rounded-full font-black flex-shrink-0 ${dark ? "bg-white/15 text-white" : "bg-[#F3F4F6] text-[#374151]"}`}
      style={{ width: size, height: size, fontSize: size * 0.32 }}>
      {initials(name)}
    </div>
  );
}

// ── Ball Badge ─────────────────────────────────────────────────────────────

function BallBadge({ outcome, isWicket, runs }: { outcome: string; isWicket: boolean; runs: number }) {
  let label: string;
  let cls: string;

  if (isWicket) {
    label = "W";
    cls = "bg-red-600 text-white";
  } else if (outcome === "SIX") {
    label = "6";
    cls = "bg-[#166534] text-white";
  } else if (outcome === "FOUR") {
    label = "4";
    cls = "bg-[#1d4ed8] text-white";
  } else if (outcome === "WIDE") {
    label = "Wd";
    cls = "bg-amber-100 text-amber-700 border border-amber-200";
  } else if (outcome === "NO_BALL") {
    label = "NB";
    cls = "bg-amber-100 text-amber-700 border border-amber-200";
  } else if (runs === 0) {
    label = "·";
    cls = "bg-[#F3F4F6] text-[#9CA3AF] border border-[#E5E7EB]";
  } else {
    label = String(runs);
    cls = "bg-[#E5E7EB] text-[#374151]";
  }

  return (
    <span className={`inline-flex h-8 w-8 shrink-0 items-center justify-center rounded-full text-xs font-bold ${cls}`}>
      {label}
    </span>
  );
}

// ── LiveTab ────────────────────────────────────────────────────────────────

function LiveTab({ match }: { match: MatchPageData }) {
  const live = currentLiveState(match);
  const maxOvers = limitedOvers(match);

  if (!live) {
    return (
      <div className="py-16 text-center text-[#9CA3AF]">
        {match.status === "COMPLETED" ? "Match completed." : "Match hasn't started yet."}
      </div>
    );
  }

  const { innings, striker, nonStriker, bowler, lastBalls } = live;
  const balls = innings.ballEvents;
  const legalCount = balls.filter(legalBall).length;
  const overNum = Math.floor(legalCount / 6);

  function batterRunsBalls(id: string | null) {
    if (!id) return { runs: 0, balls: 0 };
    const mine = balls.filter((b) => b.batterId === id);
    return { runs: mine.reduce((s, b) => s + b.runs, 0), balls: mine.filter(legalBall).length };
  }

  function bowlerFigures(id: string | null) {
    if (!id) return { runs: 0, balls: 0, wickets: 0 };
    const mine = balls.filter((b) => b.bowlerId === id);
    return {
      runs: mine.reduce((s, b) => s + b.runs + b.extras, 0),
      balls: mine.filter(legalBall).length,
      wickets: mine.filter((b) => b.isWicket && !["RUN_OUT", "RETIRED_HURT"].includes(b.dismissalType ?? "")).length,
    };
  }

  const inn1 = match.innings.find((i) => i.inningsNumber === 1);
  const isSecondInnings = innings.inningsNumber === 2 && inn1;
  const target = isSecondInnings ? inn1!.totalRuns + 1 : null;
  const needed = target ? target - innings.totalRuns : null;
  const ballsLeft = maxOvers ? maxOvers * 6 - legalCount : null;
  const rrr = needed && ballsLeft && ballsLeft > 0 ? (needed / (ballsLeft / 6)).toFixed(2) : null;
  const crr = legalCount > 0 ? (innings.totalRuns / (legalCount / 6)).toFixed(2) : "0.00";

  const strikerStats = batterRunsBalls(striker);
  const nonStrikerStats = batterRunsBalls(nonStriker);
  const bowlerFig = bowlerFigures(bowler);

  function overBallLabel(b: BallEvent) {
    if (b.isWicket) return { t: "W", cls: "bg-red-600 text-white" };
    if (b.outcome === "SIX") return { t: "6", cls: "bg-[#166534] text-white" };
    if (b.outcome === "FOUR") return { t: "4", cls: "bg-[#1d4ed8] text-white" };
    if (b.outcome === "WIDE") return { t: "Wd", cls: "bg-amber-100 text-amber-700 border border-amber-200" };
    if (b.outcome === "NO_BALL") return { t: "NB", cls: "bg-amber-100 text-amber-700 border border-amber-200" };
    if (b.runs === 0) return { t: "·", cls: "bg-[#F3F4F6] text-[#9CA3AF] border border-[#E5E7EB]" };
    return { t: String(b.runs), cls: "bg-[#E5E7EB] text-[#374151]" };
  }

  return (
    <div className="space-y-4">
      {/* Score */}
      <div className="rounded-2xl border border-[#E5E7EB] bg-white p-5">
        <div className="flex items-start justify-between">
          <div>
            <p className="text-xs font-semibold uppercase tracking-widest text-[#9CA3AF]">
              {innings.battingTeam === "A" ? match.teamAName : match.teamBName}
            </p>
            <div className="mt-1 flex items-baseline gap-2">
              <span className="text-5xl font-black text-[#111827]">{innings.totalRuns}</span>
              <span className="text-2xl text-[#9CA3AF]">/{innings.totalWickets}</span>
              <span className="text-sm text-[#6B7280]">({fmtOvers(innings.totalOvers)} ov)</span>
            </div>
          </div>
          <div className="text-right text-xs space-y-1">
            <div><span className="text-[#9CA3AF]">CRR </span><span className="font-bold text-[#111827]">{crr}</span></div>
            {rrr && <div><span className="text-[#9CA3AF]">RRR </span><span className="font-bold text-amber-600">{rrr}</span></div>}
          </div>
        </div>
        {target && needed !== null && needed > 0 && (
          <div className="mt-3 rounded-xl bg-amber-50 border border-amber-200 px-3 py-2 text-sm">
            <span className="text-amber-700 font-semibold">Need {needed} off {ballsLeft} balls</span>
            <span className="text-amber-500 ml-2">· Target {target}</span>
          </div>
        )}
        {target && needed !== null && needed <= 0 && (
          <div className="mt-3 rounded-xl bg-emerald-50 border border-emerald-200 px-3 py-2 text-sm text-emerald-700 font-semibold">
            Match won!
          </div>
        )}
      </div>

      {/* Current Over */}
      <div className="rounded-2xl border border-[#E5E7EB] bg-white p-4">
        <p className="text-[10px] font-bold uppercase tracking-widest text-[#9CA3AF] mb-3">
          Over {overNum + 1}
        </p>
        <div className="flex gap-2 flex-wrap">
          {lastBalls.length === 0 ? (
            <span className="text-xs text-[#9CA3AF]">No balls yet</span>
          ) : (
            lastBalls.map((b, i) => {
              const { t, cls } = overBallLabel(b);
              return (
                <span key={i} className={`inline-flex h-9 min-w-9 items-center justify-center rounded-full text-xs font-bold ${cls}`}>
                  {t}
                </span>
              );
            })
          )}
        </div>
      </div>

      {/* Batters */}
      <div className="grid grid-cols-2 gap-3">
        {[
          { id: striker, stats: strikerStats, isStriker: true },
          { id: nonStriker, stats: nonStrikerStats, isStriker: false },
        ].map(({ id, stats, isStriker }) => (
          <div key={isStriker ? "s" : "ns"} className={`rounded-2xl border p-4 ${isStriker ? "bg-blue-50 border-blue-200" : "bg-white border-[#E5E7EB]"}`}>
            <div className="flex items-center gap-1 mb-1">
              {isStriker && <span className="text-amber-500 text-xs font-black">★</span>}
              <p className="text-xs font-semibold text-[#374151] truncate">{id ? getName(match, id) : "—"}</p>
            </div>
            <div className="text-2xl font-black text-[#111827]">
              {stats.runs}<span className="text-sm text-[#9CA3AF] ml-1">({stats.balls})</span>
            </div>
          </div>
        ))}
      </div>

      {/* Bowler */}
      {bowler && (
        <div className="rounded-2xl border border-[#E5E7EB] bg-white p-4 flex items-center justify-between">
          <div>
            <p className="text-[10px] uppercase tracking-widest text-[#9CA3AF] font-semibold">Bowling</p>
            <p className="text-sm font-semibold text-[#374151] mt-0.5">{getName(match, bowler)}</p>
          </div>
          <div className="text-right text-sm font-bold text-[#111827]">
            {Math.floor(bowlerFig.balls / 6)}-{bowlerFig.runs}-{bowlerFig.wickets}
            <span className="text-xs text-[#9CA3AF] font-normal ml-1">({ballsToOvers(bowlerFig.balls)})</span>
          </div>
        </div>
      )}
    </div>
  );
}

// ── Fall of Wickets ────────────────────────────────────────────────────────

function FallOfWickets({ inn, match }: { inn: Innings; match: MatchPageData }) {
  const wickets: { wicketNum: number; runs: number; overs: string; playerName: string }[] = [];
  let cumRuns = 0;
  let wicketCount = 0;

  for (const ball of inn.ballEvents) {
    cumRuns += ball.runs + ball.extras;
    if (ball.isWicket) {
      wicketCount++;
      wickets.push({
        wicketNum: wicketCount,
        runs: cumRuns,
        overs: `${ball.overNumber + 1}.${ball.ballNumber}`,
        playerName: getName(match, ball.dismissedPlayerId ?? ball.batterId),
      });
    }
  }

  if (wickets.length === 0) return null;

  return (
    <div className="rounded-xl border border-[#E5E7EB] bg-white overflow-hidden">
      <div className="bg-[#F9FAFB] border-b border-[#E5E7EB] px-4 py-2">
        <span className="text-[10px] font-semibold uppercase tracking-widest text-[#9CA3AF]">Fall of Wickets</span>
      </div>
      <div className="flex flex-wrap gap-x-4 gap-y-2 px-4 py-3">
        {wickets.map((w) => (
          <div key={w.wicketNum} className="flex items-baseline gap-1.5">
            <span className="text-sm font-black text-[#111827]">{w.runs}</span>
            <span className="text-xs text-[#9CA3AF]">
              ({w.wicketNum}-{w.playerName.split(" ").pop()}, {w.overs})
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}

// ── ScorecardTab ───────────────────────────────────────────────────────────

function InningsCard({ inn, match }: { inn: Innings; match: MatchPageData }) {
  const batters = battingStats(inn, match);
  const bowlers = bowlingStats(inn, match);

  return (
    <div className="space-y-4">
      {/* Batting table */}
      <div className="overflow-hidden rounded-xl border border-[#E5E7EB] bg-white">
        <div className="bg-[#F9FAFB] border-b border-[#E5E7EB] px-4 py-2">
          <div className="grid text-[10px] font-semibold uppercase tracking-widest text-[#9CA3AF]"
            style={{ gridTemplateColumns: "1fr 40px 40px 40px 40px 50px" }}>
            <span>Batter</span>
            <span className="text-right">R</span>
            <span className="text-right">B</span>
            <span className="text-right">4s</span>
            <span className="text-right">6s</span>
            <span className="text-right">SR</span>
          </div>
        </div>
        {batters.map((b) => (
          <div key={b.id} className="border-b border-[#F3F4F6] last:border-0 px-4 py-3">
            <div className="grid items-start" style={{ gridTemplateColumns: "1fr 40px 40px 40px 40px 50px" }}>
              <div className="min-w-0">
                <p className={`text-sm font-semibold truncate ${b.isOut ? "text-[#111827]" : "text-emerald-600"}`}>
                  {b.name}
                </p>
                <p className="text-[10px] text-[#9CA3AF] truncate mt-0.5">{b.dismissal}</p>
              </div>
              <span className="text-sm font-black text-[#111827] text-right">{b.runs}</span>
              <span className="text-xs text-[#6B7280] text-right">{b.balls}</span>
              <span className="text-xs text-blue-600 text-right font-medium">{b.fours}</span>
              <span className="text-xs text-amber-600 text-right font-medium">{b.sixes}</span>
              <span className="text-xs text-[#6B7280] text-right">
                {b.balls > 0 ? ((b.runs / b.balls) * 100).toFixed(0) : "—"}
              </span>
            </div>
          </div>
        ))}
        <div className="bg-[#F9FAFB] px-4 py-2.5 flex justify-between text-xs font-semibold">
          <span className="text-[#6B7280]">Total</span>
          <span className="text-[#111827]">
            {inn.totalRuns}/{inn.totalWickets}
            <span className="text-[#9CA3AF] font-normal ml-2">({fmtOvers(inn.totalOvers)} ov · {inn.extras} extras)</span>
          </span>
        </div>
      </div>

      {/* Fall of Wickets */}
      <FallOfWickets inn={inn} match={match} />

      {/* Bowling table */}
      <div className="overflow-hidden rounded-xl border border-[#E5E7EB] bg-white">
        <div className="bg-[#F9FAFB] border-b border-[#E5E7EB] px-4 py-2">
          <div className="grid text-[10px] font-semibold uppercase tracking-widest text-[#9CA3AF]"
            style={{ gridTemplateColumns: "1fr 40px 40px 40px 40px 44px" }}>
            <span>Bowler</span>
            <span className="text-right">O</span>
            <span className="text-right">M</span>
            <span className="text-right">R</span>
            <span className="text-right">W</span>
            <span className="text-right">Eco</span>
          </div>
        </div>
        {bowlers.map((b) => {
          const overs = ballsToOvers(b.legalBalls);
          const eco = b.legalBalls > 0 ? ((b.runs / b.legalBalls) * 6).toFixed(1) : "—";
          return (
            <div key={b.id} className="border-b border-[#F3F4F6] last:border-0 px-4 py-3">
              <div className="grid items-center" style={{ gridTemplateColumns: "1fr 40px 40px 40px 40px 44px" }}>
                <span className="text-sm font-semibold text-[#374151] truncate">{b.name}</span>
                <span className="text-xs text-[#6B7280] text-right">{overs}</span>
                <span className="text-xs text-[#6B7280] text-right">—</span>
                <span className="text-xs text-[#6B7280] text-right">{b.runs}</span>
                <span className={`text-sm font-bold text-right ${b.wickets >= 3 ? "text-red-600" : "text-[#111827]"}`}>{b.wickets}</span>
                <span className="text-xs text-[#6B7280] text-right">{eco}</span>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

function ScorecardTab({ match }: { match: MatchPageData }) {
  const [selectedSide, setSelectedSide] = useState<"A" | "B">("A");
  const [activeInningsIdx, setActiveInningsIdx] = useState(0);

  const inningsA = match.innings.filter((i) => i.battingTeam === "A");
  const inningsB = match.innings.filter((i) => i.battingTeam === "B");

  if (match.innings.length === 0) {
    return <div className="py-16 text-center text-[#9CA3AF]">No innings data yet</div>;
  }

  const selectedInnings = selectedSide === "A" ? inningsA : inningsB;
  const currentInnings = selectedInnings[activeInningsIdx] ?? null;

  return (
    <div className="space-y-4">
      {/* Team selector */}
      <div className="grid grid-cols-2 gap-1 rounded-xl border border-[#E5E7EB] p-1 bg-white">
        {(["A", "B"] as const).map((side) => {
          const sideInns = side === "A" ? inningsA : inningsB;
          const score = sideInns.length > 0
            ? sideInns.map((i) => `${i.totalRuns}/${i.totalWickets}`).join(" & ")
            : "Yet to bat";
          const meta = teamMetaFor(match, side);
          const tName = sideTeamName(match, side);
          return (
            <button
              key={side}
              onClick={() => { setSelectedSide(side); setActiveInningsIdx(0); }}
              className={`rounded-lg px-3 py-2.5 text-left transition-colors flex items-center gap-2.5 ${
                selectedSide === side
                  ? "bg-[#EFF6FF] border border-blue-100"
                  : "hover:bg-[#F9FAFB]"
              }`}
            >
              <TeamLogo meta={meta} name={tName} size={32} />
              <div className="min-w-0">
                <p className={`text-xs font-bold truncate ${selectedSide === side ? "text-blue-700" : "text-[#374151]"}`}>
                  {shortTeamName(match, side)}
                </p>
                <p className={`text-[10px] mt-0.5 font-semibold ${selectedSide === side ? "text-blue-500" : "text-[#9CA3AF]"}`}>
                  {score}
                </p>
              </div>
            </button>
          );
        })}
      </div>

      {/* Innings selector (only for multi-innings) */}
      {selectedInnings.length > 1 && (
        <div className="flex gap-1">
          {selectedInnings.map((inn, idx) => (
            <button
              key={inn.id}
              onClick={() => setActiveInningsIdx(idx)}
              className={`rounded-lg px-3 py-1.5 text-xs font-semibold transition-colors ${
                activeInningsIdx === idx
                  ? "bg-[#111827] text-white"
                  : "bg-[#F3F4F6] text-[#6B7280] hover:bg-[#E5E7EB]"
              }`}
            >
              Innings {inn.inningsNumber}
            </button>
          ))}
        </div>
      )}

      {/* Scorecard content */}
      {currentInnings ? (
        <InningsCard inn={currentInnings} match={match} />
      ) : (
        <div className="py-12 text-center text-sm text-[#9CA3AF]">
          {sideTeamName(match, selectedSide)} haven&apos;t batted yet
        </div>
      )}
    </div>
  );
}

// ── AnalysisTab ────────────────────────────────────────────────────────────

function AnalysisTab({ match }: { match: MatchPageData }) {
  const [selectedSide, setSelectedSide] = useState<"A" | "B">("A");
  const maxOvers = limitedOvers(match) ?? 20;
  const inningsWithBalls = match.innings.filter((i) => i.ballEvents.length > 0);

  if (inningsWithBalls.length === 0) {
    return <div className="py-16 text-center text-[#9CA3AF]">No match data yet</div>;
  }

  const teamName = (inn: Innings) => inn.battingTeam === "A" ? match.teamAName : match.teamBName;
  const teamNames: [string, string] = [
    inningsWithBalls[0] ? teamName(inningsWithBalls[0]) : "",
    inningsWithBalls[1] ? teamName(inningsWithBalls[1]) : "",
  ];

  const selectedInnings = inningsWithBalls.filter((i) => i.battingTeam === selectedSide);

  return (
    <div className="space-y-3">
      {/* Comparison charts — always shown */}
      {inningsWithBalls.length > 1 && (
        <>
          <ChartCard
            title="Run Progression"
            subtitle="Cumulative runs — both teams"
            defaultOpen
          >
            <div className="pt-3">
              <RunProgressionChart innings={inningsWithBalls} maxOvers={maxOvers} teamNames={teamNames} />
            </div>
          </ChartCard>

          <ChartCard title="Run Rate" subtitle="Run rate by over — both teams">
            <div className="pt-3">
              <RunRateChart innings={inningsWithBalls} teamNames={teamNames} />
            </div>
          </ChartCard>

          <div className="h-px bg-[#F3F4F6]" />
        </>
      )}

      {/* Team selector */}
      <div className="grid grid-cols-2 gap-1 rounded-xl border border-[#E5E7EB] p-1 bg-white">
        {(["A", "B"] as const).map((side) => {
          const sideInns = inningsWithBalls.filter((i) => i.battingTeam === side);
          const meta = teamMetaFor(match, side);
          const tName = sideTeamName(match, side);
          return (
            <button
              key={side}
              onClick={() => setSelectedSide(side)}
              className={`rounded-lg px-3 py-2.5 text-left transition-colors flex items-center gap-2.5 ${
                selectedSide === side
                  ? "bg-[#EFF6FF] border border-blue-100"
                  : "hover:bg-[#F9FAFB]"
              }`}
            >
              <TeamLogo meta={meta} name={tName} size={32} />
              <div className="min-w-0">
                <p className={`text-xs font-bold truncate ${selectedSide === side ? "text-blue-700" : "text-[#374151]"}`}>
                  {shortTeamName(match, side)}
                </p>
                <p className={`text-[10px] mt-0.5 font-semibold ${selectedSide === side ? "text-blue-500" : "text-[#9CA3AF]"}`}>
                  {sideInns.length > 0 ? sideInns.map((i) => `${i.totalRuns}/${i.totalWickets}`).join(" & ") : "Yet to bat"}
                </p>
              </div>
            </button>
          );
        })}
      </div>

      {/* Team-specific charts */}
      {selectedInnings.length === 0 ? (
        <div className="py-10 text-center text-sm text-[#9CA3AF]">
          {sideTeamName(match, selectedSide)} haven&apos;t batted yet
        </div>
      ) : (
        selectedInnings.map((inn) => (
          <div key={inn.id} className="space-y-3">
            {selectedInnings.length > 1 && (
              <div className="text-[10px] font-bold uppercase tracking-widest text-[#9CA3AF] px-1">
                Innings {inn.inningsNumber}
              </div>
            )}

            <ChartCard
              title="Runs per Over"
              subtitle="Over-by-over scoring · avg line shown"
              defaultOpen={selectedInnings.length === 1}
            >
              <div className="pt-3">
                <RunsPerOverChart inn={inn} teamName={teamName(inn)} />
              </div>
            </ChartCard>

            <ChartCard title="Partnerships" subtitle="Runs per partnership">
              <div className="pt-3">
                <PartnershipChart inn={inn} match={match} />
              </div>
            </ChartCard>

            <ChartCard title="Scoring Breakdown" subtitle="Dot %, boundary %, extras">
              <div className="pt-3">
                <ScoringBreakdown inn={inn} />
              </div>
            </ChartCard>
          </div>
        ))
      )}
    </div>
  );
}

// ── CommentaryTab ──────────────────────────────────────────────────────────

function CommentaryTab({ match }: { match: MatchPageData }) {
  const items: {
    overLabel: string;
    matchupLabel: string;
    title: string;
    detail: string;
    tone: string;
    score: string;
    outcome: string;
    runs: number;
    isWicket: boolean;
  }[] = [];
  let cumRuns = 0, cumWickets = 0;

  for (const inn of match.innings) {
    const teamName = inn.battingTeam === "A" ? match.teamAName : match.teamBName;
    cumRuns = 0; cumWickets = 0;
    for (const ball of inn.ballEvents) {
      cumRuns += ball.runs + ball.extras;
      if (ball.isWicket) cumWickets++;
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
      const tone = ball.isWicket ? "wicket"
        : (ball.outcome === "SIX" || ball.outcome === "FOUR") ? "boundary"
        : (ball.outcome === "WIDE" || ball.outcome === "NO_BALL" || ball.outcome === "BYE" || ball.outcome === "LEG_BYE") ? "extra"
        : ball.totalRuns === 0 ? "dot" : "run";
      items.push({
        overLabel: `${ball.overNumber + 1}.${ball.ballNumber}`,
        matchupLabel: `${bowler} to ${batter}`,
        title, detail, tone,
        score: `${cumRuns}/${cumWickets}`,
        outcome: ball.outcome,
        runs: ball.runs,
        isWicket: ball.isWicket,
      });
    }
  }
  items.reverse();

  if (items.length === 0) {
    return <div className="py-16 text-center text-[#9CA3AF]">No balls recorded yet</div>;
  }

  return (
    <div className="divide-y divide-[#F3F4F6]">
      {items.map((item, i) => (
        <div key={i} className="py-4">
          <div className="text-xs text-[#9CA3AF] mb-1.5">{item.overLabel} · {item.matchupLabel}</div>
          <div className="flex items-start gap-3">
            <BallBadge outcome={item.outcome} isWicket={item.isWicket} runs={item.runs} />
            <div className="flex-1 min-w-0">
              <span className={`text-sm font-bold mr-2 ${item.tone === "wicket" ? "text-red-600" : item.tone === "boundary" ? "text-[#1d4ed8]" : "text-[#111827]"}`}>
                {item.title}
              </span>
              <span className="text-sm text-[#374151] leading-relaxed">{item.detail}</span>
            </div>
            <span className="text-xs font-semibold text-[#9CA3AF] shrink-0 pt-0.5">{item.score}</span>
          </div>
        </div>
      ))}
    </div>
  );
}

// ── HighlightsTab ──────────────────────────────────────────────────────────

type Highlight = { id: string; title: string; url: string };

function extractVideoId(url: string): string | null {
  const watchMatch = url.match(/[?&]v=([^&]+)/);
  if (watchMatch) return watchMatch[1];
  const shortMatch = url.match(/youtu\.be\/([^?/]+)/);
  if (shortMatch) return shortMatch[1];
  const pathMatch = url.match(/\/(?:shorts|live|embed)\/([a-zA-Z0-9_-]{11})/);
  if (pathMatch) return pathMatch[1];
  return null;
}

function isShorts(url: string) {
  return /\/shorts\//.test(url);
}

function embedUrl(videoId: string, shorts: boolean) {
  return `https://www.youtube.com/embed/${videoId}?autoplay=1&rel=0${shorts ? "&loop=1&playlist=" + videoId : ""}`;
}

function VideoCard({ h, isShort }: { h: Highlight; isShort: boolean }) {
  const [playing, setPlaying] = useState(false);
  const videoId = extractVideoId(h.url);
  const thumb = videoId
    ? `https://img.youtube.com/vi/${videoId}/hqdefault.jpg`
    : null;

  if (isShort) {
    return (
      <div className="flex flex-col gap-2">
        <div
          className="relative overflow-hidden rounded-2xl bg-[#0a0f1a] cursor-pointer group"
          style={{ aspectRatio: "9/16" }}
          onClick={() => setPlaying(true)}
        >
          {playing && videoId ? (
            <iframe
              src={embedUrl(videoId, true)}
              title={h.title}
              allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
              allowFullScreen
              className="absolute inset-0 w-full h-full"
            />
          ) : (
            <>
              {thumb && (
                <img
                  src={thumb}
                  alt={h.title}
                  className="absolute inset-0 w-full h-full object-cover transition-transform duration-500 group-hover:scale-105"
                />
              )}
              {/* dark gradient */}
              <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent" />
              {/* Shorts pill */}
              <div className="absolute top-3 left-3 flex items-center gap-1 bg-white/10 backdrop-blur-md border border-white/20 rounded-full px-2 py-0.5">
                <span className="text-white text-[9px] font-bold tracking-widest uppercase">Shorts</span>
              </div>
              {/* Play button */}
              <div className="absolute inset-0 flex items-center justify-center">
                <div className="w-12 h-12 rounded-full bg-[#CCFF00] flex items-center justify-center shadow-lg shadow-[#CCFF00]/30 group-hover:scale-110 transition-transform">
                  <svg viewBox="0 0 24 24" fill="#0a0f1a" className="w-5 h-5 ml-0.5">
                    <path d="M8 5v14l11-7z" />
                  </svg>
                </div>
              </div>
            </>
          )}
        </div>
        <p className="text-xs font-semibold text-[#374151] leading-snug line-clamp-2 px-0.5">{h.title}</p>
      </div>
    );
  }

  return (
    <div
      className="relative overflow-hidden rounded-2xl bg-[#0a0f1a] cursor-pointer group"
      style={{ aspectRatio: "16/9" }}
      onClick={() => setPlaying(true)}
    >
      {playing && videoId ? (
        <iframe
          src={embedUrl(videoId, false)}
          title={h.title}
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
          allowFullScreen
          className="absolute inset-0 w-full h-full"
        />
      ) : (
        <>
          {thumb && (
            <img
              src={thumb}
              alt={h.title}
              className="absolute inset-0 w-full h-full object-cover transition-transform duration-500 group-hover:scale-105"
            />
          )}
          {/* gradient overlay */}
          <div className="absolute inset-0 bg-gradient-to-t from-black/90 via-black/30 to-black/10" />
          {/* Play button — center */}
          <div className="absolute inset-0 flex items-center justify-center">
            <div className="w-16 h-16 rounded-full bg-[#CCFF00] flex items-center justify-center shadow-xl shadow-[#CCFF00]/40 group-hover:scale-110 transition-transform">
              <svg viewBox="0 0 24 24" fill="#0a0f1a" className="w-7 h-7 ml-1">
                <path d="M8 5v14l11-7z" />
              </svg>
            </div>
          </div>
          {/* Title at bottom */}
          <div className="absolute bottom-0 left-0 right-0 px-5 py-4">
            <p className="text-white font-bold text-sm leading-snug drop-shadow-lg line-clamp-2">{h.title}</p>
          </div>
        </>
      )}
    </div>
  );
}

function HighlightsTab({ match }: { match: MatchPageData }) {
  const highlights = match.highlights ?? [];
  if (!highlights.length) {
    return (
      <div className="py-20 text-center">
        <div className="w-14 h-14 rounded-full bg-[#F3F4F6] flex items-center justify-center mx-auto mb-3">
          <svg viewBox="0 0 24 24" fill="none" stroke="#9CA3AF" strokeWidth="1.5" className="w-6 h-6">
            <path strokeLinecap="round" strokeLinejoin="round" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            <path strokeLinecap="round" strokeLinejoin="round" d="M15.91 11.672a.375.375 0 010 .656l-5.603 3.113a.375.375 0 01-.557-.328V8.887c0-.286.307-.466.557-.327l5.603 3.112z" />
          </svg>
        </div>
        <p className="text-sm text-[#9CA3AF]">No highlights yet</p>
      </div>
    );
  }

  const videos = highlights.filter((h) => !isShorts(h.url));
  const shorts = highlights.filter((h) => isShorts(h.url));
  const hasBoth = videos.length > 0 && shorts.length > 0;

  return (
    <div className="space-y-8">
      {/* Full videos */}
      {videos.length > 0 && (
        <section>
          {hasBoth && (
            <div className="flex items-center gap-3 mb-4">
              <span className="text-[11px] font-bold uppercase tracking-[0.15em] text-[#9CA3AF]">Videos</span>
              <div className="flex-1 h-px bg-[#F3F4F6]" />
            </div>
          )}
          <div className="space-y-4">
            {videos.map((h) => <VideoCard key={h.id} h={h} isShort={false} />)}
          </div>
        </section>
      )}

      {/* Shorts — 2-column grid */}
      {shorts.length > 0 && (
        <section>
          {hasBoth && (
            <div className="flex items-center gap-3 mb-4">
              <span className="text-[11px] font-bold uppercase tracking-[0.15em] text-[#9CA3AF]">Shorts</span>
              <div className="flex-1 h-px bg-[#F3F4F6]" />
            </div>
          )}
          <div className="grid grid-cols-2 gap-3">
            {shorts.map((h) => <VideoCard key={h.id} h={h} isShort={true} />)}
          </div>
        </section>
      )}
    </div>
  );
}

// ── Playing11Tab ───────────────────────────────────────────────────────────

function Playing11Tab({ match }: { match: MatchPageData }) {
  const [selectedSide, setSelectedSide] = useState<"A" | "B">("A");

  const hasAny = match.teamAPlayerIds.length > 0 || match.teamBPlayerIds.length > 0;
  if (!hasAny) {
    return <div className="py-16 text-center text-[#9CA3AF] text-sm">Playing 11 not announced yet</div>;
  }

  const ids = selectedSide === "A" ? match.teamAPlayerIds : match.teamBPlayerIds;
  const capId = selectedSide === "A" ? match.teamACaptainId : match.teamBCaptainId;
  const vcId = selectedSide === "A" ? match.teamAViceCaptainId : match.teamBViceCaptainId;
  const wkId = selectedSide === "A" ? match.teamAWicketKeeperId : match.teamBWicketKeeperId;

  return (
    <div className="space-y-4">
      {/* Team selector */}
      <div className="grid grid-cols-2 gap-1 rounded-xl border border-[#E5E7EB] p-1 bg-white">
        {(["A", "B"] as const).map((side) => (
          <button
            key={side}
            onClick={() => setSelectedSide(side)}
            className={`rounded-lg py-2.5 text-sm font-semibold transition-colors ${
              selectedSide === side
                ? "bg-[#EFF6FF] text-blue-700"
                : "text-[#6B7280] hover:text-[#374151]"
            }`}
          >
            {shortTeamName(match, side)}
          </button>
        ))}
      </div>

      {/* Player grid */}
      {ids.length > 0 ? (
        <div className="grid grid-cols-2 gap-x-4 gap-y-5">
          {ids.map((pid) => {
            const name = getName(match, pid);
            const isCap = pid === capId;
            const isVc = pid === vcId;
            const isWk = pid === wkId;
            return (
              <div key={pid} className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-[#F3F4F6] shrink-0 flex items-center justify-center text-xs font-bold text-[#6B7280] border border-[#E5E7EB]">
                  {initials(name)}
                </div>
                <div className="min-w-0">
                  <p className={`text-sm truncate leading-snug ${isCap ? "font-bold text-amber-600" : "font-medium text-[#374151]"}`}>
                    {name}
                    {isCap && <span className="text-amber-500"> (C)</span>}
                    {isVc && !isCap && <span className="text-blue-500"> (VC)</span>}
                  </p>
                  <p className="text-xs text-[#9CA3AF]">
                    {isWk ? "Wicket-Keeper" : "Player"}
                  </p>
                </div>
              </div>
            );
          })}
        </div>
      ) : (
        <p className="py-8 text-center text-sm text-[#9CA3AF]">No players listed for this team</p>
      )}
    </div>
  );
}

// ── Page ───────────────────────────────────────────────────────────────────

export default function MatchPageClient({ match: initialMatch }: { match: MatchPageData }) {
  const router = useRouter();
  const [isRefreshing, startRefresh] = useTransition();
  const [liveMatch, setLiveMatch] = useState(initialMatch);
  const match = liveMatch;

  const [activeTab, setActiveTab] = useState<MatchTab>(() => {
    if (initialMatch.status === "COMPLETED") return "scorecard";
    if (initialMatch.status === "IN_PROGRESS") return "live";
    if (initialMatch.innings.length > 0) return "scorecard";
    return "live";
  });

  const resultLine = useMemo(() => matchResult(match), [match]);
  const tossLine = useMemo(() => tossSummary(match), [match]);

  function refreshMatch() {
    startRefresh(() => { router.refresh(); });
  }

  const isLive = match.status === "IN_PROGRESS";

  const API = process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:3000";

  useEffect(() => {
    if (!isLive) return;
    let active = true;
    const poll = async () => {
      try {
        const res = await fetch(`${API}/public/match/${liveMatch.id}`, { cache: "no-store" });
        if (res.ok) {
          const json = await res.json();
          if (active && json.data) setLiveMatch(json.data as MatchPageData);
        }
      } catch {}
    };
    const iv = setInterval(poll, 5000);
    return () => { active = false; clearInterval(iv); };
  }, [isLive, liveMatch.id, API]);

  return (
    <div className="min-h-screen bg-white text-[#111827]">
      {/* Nav */}
      <nav className="sticky top-0 z-40 border-b border-white/5 bg-[#0a0f1a]/95 backdrop-blur-md">
        <div className="mx-auto flex h-14 max-w-3xl items-center justify-between px-4">
          <Link href="/" className="text-lg font-black tracking-tight text-white">
            SWING<span className="text-[#CCFF00]">.</span>
          </Link>
          <div className="flex items-center gap-2">
            {isLive && (
              <span className="flex items-center gap-1.5 rounded-full bg-[#CCFF00]/10 px-3 py-1 text-[10px] font-bold uppercase tracking-widest text-[#CCFF00]">
                <span className="w-1.5 h-1.5 rounded-full bg-[#CCFF00] animate-pulse" />
                Live
              </span>
            )}
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

      {/* Match Hero */}
      <div className="bg-[#0a0f1a]">
        <div className="mx-auto max-w-3xl px-4 pt-6 pb-0">
          {/* Competition + format */}
          <div className="flex items-center gap-2 flex-wrap mb-3">
            <span className="text-[10px] font-bold uppercase tracking-[0.2em] text-white/40">
              {match.competition?.name ?? formatLabel(match.format, match.customOvers)}
            </span>
            {match.competition && (
              <span className="text-[10px] font-semibold uppercase tracking-wider text-white/25 bg-white/5 px-2 py-0.5 rounded">
                {formatLabel(match.format, match.customOvers)}
              </span>
            )}
            {match.round && (
              <span className="text-[10px] text-white/30 bg-white/5 px-2 py-0.5 rounded">{match.round}</span>
            )}
          </div>

          {/* Date / venue */}
          <div className="flex items-center gap-3 flex-wrap mb-6">
            <div className="flex items-center gap-1.5 text-[11px] text-white/50">
              <svg width="11" height="11" viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="1.5"><rect x="1" y="3" width="14" height="12" rx="2"/><path d="M5 1v4M11 1v4M1 7h14"/></svg>
              {fmtDateLong(match.scheduledAt)}
            </div>
            <div className="flex items-center gap-1.5 text-[11px] font-semibold text-white/70">
              <svg width="11" height="11" viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="1.5"><circle cx="8" cy="8" r="7"/><path d="M8 4v4l3 2"/></svg>
              {match.startedAt ? fmtTime(match.startedAt) : fmtTime(match.scheduledAt)}
              {!match.startedAt && match.status === "SCHEDULED" && (
                <span className="text-white/30 font-normal">(scheduled)</span>
              )}
            </div>
            {match.venueName && (
              <div className="flex items-center gap-1.5 text-[11px] text-white/40">
                <svg width="11" height="11" viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="1.5"><path d="M8 1a5 5 0 0 1 5 5c0 3.5-5 9-5 9S3 9.5 3 6a5 5 0 0 1 5-5z"/><circle cx="8" cy="6" r="1.5"/></svg>
                {match.venueName}
              </div>
            )}
          </div>

          {/* Teams + scores */}
          {(() => {
            const inn1BattingTeam = match.innings[0]?.battingTeam as "A" | "B" | undefined;
            const leftSide: "A" | "B" = inn1BattingTeam ?? "A";
            const rightSide: "A" | "B" = leftSide === "A" ? "B" : "A";
            const leftName = leftSide === "A" ? match.teamAName : match.teamBName;
            const rightName = rightSide === "A" ? match.teamAName : match.teamBName;
            return (
          <div className="grid grid-cols-[1fr_auto_1fr] items-center gap-4 pb-5">
            {/* Left team (batted first) */}
            <div className="space-y-2">
              <div className="flex items-center gap-3">
                <TeamLogo meta={teamMetaFor(match, leftSide)} name={leftName} size={44} dark />
                <div className="min-w-0">
                  <p className="text-xs font-semibold uppercase tracking-widest text-white/40">{shortTeamName(match, leftSide)}</p>
                  <p className="text-sm font-semibold text-white truncate leading-tight">{leftName}</p>
                </div>
              </div>
              {(() => {
                const s = scoreSummary(match, leftSide);
                const won = isWinner(match, leftSide);
                return (
                  <div>
                    <div className={`text-3xl font-black leading-none ${won ? "text-[#CCFF00]" : "text-white"}`}>{s.main}</div>
                    <div className="text-xs text-white/35 mt-0.5">{s.sub}</div>
                  </div>
                );
              })()}
            </div>

            {/* VS */}
            <div className="text-center px-2">
              <div className="text-xs font-bold text-white/20 uppercase tracking-widest">vs</div>
              {isLive && <div className="mt-1 w-1.5 h-1.5 bg-[#CCFF00] rounded-full mx-auto animate-pulse" />}
            </div>

            {/* Right team */}
            <div className="space-y-2 text-right">
              <div className="flex items-center gap-3 justify-end">
                <div className="min-w-0">
                  <p className="text-xs font-semibold uppercase tracking-widest text-white/40">{shortTeamName(match, rightSide)}</p>
                  <p className="text-sm font-semibold text-white truncate leading-tight">{rightName}</p>
                </div>
                <TeamLogo meta={teamMetaFor(match, rightSide)} name={rightName} size={44} dark />
              </div>
              {(() => {
                const s = scoreSummary(match, rightSide);
                const won = isWinner(match, rightSide);
                return (
                  <div>
                    <div className={`text-3xl font-black leading-none ${won ? "text-[#CCFF00]" : "text-white"}`}>{s.main}</div>
                    <div className="text-xs text-white/35 mt-0.5">{s.sub}</div>
                  </div>
                );
              })()}
            </div>
          </div>
            );
          })()}

          {/* Result / toss */}
          {resultLine && (
            <div className="mb-4 rounded-2xl bg-[#CCFF00]/10 border border-[#CCFF00]/20 px-4 py-3 text-sm font-semibold text-[#CCFF00]">
              {resultLine}
            </div>
          )}
          {tossLine && !resultLine && (
            <div className="mb-3 text-[11px] text-white/30">{tossLine}</div>
          )}

          {/* YouTube Live Stream */}
          {match.youtubeUrl && (() => {
            const ytMatch = match.youtubeUrl.match(/(?:youtube\.com\/(?:watch\?v=|embed\/|live\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})/);
            const ytId = ytMatch?.[1];
            if (!ytId) return null;
            return (
              <div className="mb-4 rounded-2xl overflow-hidden border border-white/10 bg-black aspect-video">
                <iframe
                  src={`https://www.youtube.com/embed/${ytId}?autoplay=1`}
                  className="w-full h-full"
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                  allowFullScreen
                />
              </div>
            );
          })()}

          {/* Tabs */}
          <div className="flex gap-0 overflow-x-auto scrollbar-none border-t border-white/5">
            {([
              ...(match.status !== "COMPLETED" ? [{ id: "live" as const, label: isLive ? "🔴 Live" : "Live" }] : []),
              { id: "scorecard", label: "Scorecard" },
              { id: "playing11", label: "Playing 11" },
              { id: "analysis", label: "Analysis" },
              { id: "commentary", label: "Commentary" },
              ...(match.highlights?.length ? [{ id: "highlights" as const, label: "Highlights" }] : []),
            ] as const).map(({ id, label }) => (
              <button
                key={id}
                onClick={() => setActiveTab(id)}
                className={`px-4 py-3 text-xs font-semibold uppercase tracking-widest border-b-2 transition-colors whitespace-nowrap ${
                  activeTab === id
                    ? "border-[#CCFF00] text-[#CCFF00]"
                    : "border-transparent text-white/40 hover:text-white/70"
                }`}
              >
                {label}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Tab Content — white area */}
      <div className="mx-auto max-w-3xl px-4 py-6">
        {activeTab === "live" && <LiveTab match={match} />}
        {activeTab === "scorecard" && <ScorecardTab match={match} />}
        {activeTab === "playing11" && <Playing11Tab match={match} />}
        {activeTab === "analysis" && <AnalysisTab match={match} />}
        {activeTab === "commentary" && <CommentaryTab match={match} />}
        {activeTab === "highlights" && <HighlightsTab match={match} />}
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
