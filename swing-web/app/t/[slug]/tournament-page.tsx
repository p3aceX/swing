"use client";

import { useState } from "react";
import Link from "next/link";
import type { Highlight } from "@/lib/api";
import { getYouTubeId } from "@/lib/api";

// ─────────────────────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────────────────────
interface Innings {
  inningsNumber: number;
  battingTeam: string;
  totalRuns: number;
  totalWickets: number;
  totalOvers?: number | null;
  isCompleted: boolean;
}
interface Match {
  id: string;
  round?: string;
  groupName?: string | null;
  status: string;
  scheduledAt: string;
  teamAName: string;
  teamBName: string;
  winnerId?: string | null;
  winMargin?: string | null;
  innings?: Innings[];
}
interface Standing {
  id: string;
  teamName: string;
  played: number;
  won: number;
  lost: number;
  tied: number;
  noResult: number;
  points: number;
  netRunRate?: number | null;
  groupId?: string | null;
  groupName?: string | null;
}
interface Team {
  id: string;
  teamName: string;
  isConfirmed: boolean;
  logoUrl?: string | null;
  team?: {
    name?: string | null;
    shortName?: string | null;
    logoUrl?: string | null;
  } | null;
}
interface Tournament {
  id: string;
  name: string;
  description?: string | null;
  format: string;
  tournamentFormat: string;
  status: string;
  startDate: string;
  endDate?: string | null;
  venueName?: string | null;
  city?: string | null;
  prizePool?: string | null;
  entryFee?: number | null;
  maxTeams?: number;
  logoUrl?: string | null;
  coverUrl?: string | null;
  slug?: string | null;
  highlights?: Highlight[];
  teams?: Team[];
}
interface Props {
  tournament: Tournament;
  matches: Match[];
  standings: Standing[];
}

// ─────────────────────────────────────────────────────────────
// Constants & helpers
// ─────────────────────────────────────────────────────────────
const KNOCKOUT_ORDER = [
  "Round of 32",
  "Round of 16",
  "Round of 8",
  "Quarter Final",
  "Semi Final",
  "Final",
  "Grand Final",
];
const KNOCKOUT_SET = new Set(KNOCKOUT_ORDER);
const LEAGUE_FMT = ["LEAGUE", "GROUP_STAGE_KNOCKOUT", "SUPER_LEAGUE"];
const KNOCKOUT_FMT = ["KNOCKOUT", "DOUBLE_ELIMINATION"];

const fmtDate = (d: string) =>
  new Date(d).toLocaleDateString("en-IN", {
    day: "numeric",
    month: "short",
    year: "numeric",
  });

const fmtShort = (d: string) =>
  new Date(d).toLocaleDateString("en-IN", {
    day: "numeric",
    month: "short",
  });

const fmtTime = (d: string) =>
  new Date(d).toLocaleTimeString("en-IN", {
    hour: "2-digit",
    minute: "2-digit",
    hour12: true,
  });

function isAWon(m: Match) {
  if (!m.winnerId) return false;
  return (
    m.winnerId === "A" || m.winnerId.toLowerCase() === m.teamAName.toLowerCase()
  );
}

function initials(name: string) {
  return name
    .split(/\s+/)
    .map((w) => w[0])
    .join("")
    .toUpperCase()
    .slice(0, 2);
}

function normalizeTeamName(name: string) {
  return name.trim().toLowerCase();
}

function cbUrl(url: string): string {
  let h = 0;
  for (let i = 0; i < url.length; i++) h = (h * 31 + url.charCodeAt(i)) >>> 0;
  return `${url}${url.includes("?") ? "&" : "?"}_v=${h.toString(36)}`;
}

function getTeamLogoUrl(team: Team) {
  return team.team?.logoUrl ?? team.logoUrl ?? null;
}

function getTeamShortName(team: Team) {
  return team.team?.shortName ?? null;
}

type TeamBrand = {
  logoUrl?: string | null;
  shortName?: string | null;
};

type TeamBrandMap = Map<string, TeamBrand>;

function buildTeamBrandMap(teams: Team[]): TeamBrandMap {
  const map = new Map<string, TeamBrand>();

  for (const team of teams) {
    const brand = {
      logoUrl: getTeamLogoUrl(team),
      shortName: getTeamShortName(team),
    };

    map.set(normalizeTeamName(team.teamName), brand);
    if (team.team?.name) {
      map.set(normalizeTeamName(team.team.name), brand);
    }
  }

  return map;
}

function getTeamBrand(teamBrandMap: TeamBrandMap, name: string) {
  return teamBrandMap.get(normalizeTeamName(name));
}

function cx(...classes: Array<string | false | null | undefined>) {
  return classes.filter(Boolean).join(" ");
}

// ─────────────────────────────────────────────────────────────
// Shared UI tokens
// ─────────────────────────────────────────────────────────────
const PANEL =
  "rounded-[26px] border border-white/10 bg-white/[0.04] backdrop-blur-xl shadow-[0_10px_40px_rgba(0,0,0,0.18)]";
const PANEL_SOFT =
  "rounded-[22px] border border-white/10 bg-white/[0.03] backdrop-blur-xl";
const TEXT_DIM = "text-white/35";
const TEXT_SOFT = "text-white/55";
const TEXT_MAIN = "text-white/85";

const AVATAR_SIZE = {
  sm: "h-6 w-6 rounded-lg text-[9px]",
  md: "h-9 w-9 rounded-xl text-[11px]",
  lg: "h-12 w-12 rounded-2xl text-sm",
} as const;

const AVATAR_TONE = {
  default: "border-white/10 bg-white/[0.05] text-white/40",
  winner: "border-[#CCFF00]/20 bg-[#CCFF00]/15 text-[#CCFF00]",
  qualifier: "border-[#CCFF00]/20 bg-[#CCFF00]/12 text-[#CCFF00]",
  leader: "border-amber-300/20 bg-amber-300/15 text-amber-200",
} as const;

function TeamAvatar({
  name,
  logoUrl,
  shortName,
  size = "md",
  tone = "default",
}: {
  name: string;
  logoUrl?: string | null;
  shortName?: string | null;
  size?: keyof typeof AVATAR_SIZE;
  tone?: keyof typeof AVATAR_TONE;
}) {
  const label = shortName?.trim()
    ? shortName.trim().slice(0, 3).toUpperCase()
    : initials(name);

  return logoUrl ? (
    <img
      src={cbUrl(logoUrl)}
      alt={name}
      className={cx(
        "shrink-0 object-cover border",
        AVATAR_SIZE[size],
        AVATAR_TONE[tone],
      )}
    />
  ) : (
    <div
      className={cx(
        "flex items-center justify-center border font-black shrink-0",
        AVATAR_SIZE[size],
        AVATAR_TONE[tone],
      )}
    >
      {label}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Match Card
// ─────────────────────────────────────────────────────────────
function MatchCard({
  match,
  teamBrandMap,
}: {
  match: Match;
  teamBrandMap: TeamBrandMap;
}) {
  const done = match.status === "COMPLETED" || match.status === "ABANDONED";
  const live = match.status === "IN_PROGRESS";
  const aWon = done && isAWon(match);
  const bWon = done && !!match.winnerId && !aWon;
  const wo = match.winMargin === "W/O";
  const inn1 = match.innings?.find((i) => i.inningsNumber === 1);
  const inn2 = match.innings?.find((i) => i.inningsNumber === 2);

  function Score({ inn }: { inn?: Innings }) {
    if (!inn) return <span className="text-white/30 font-mono text-sm">—</span>;
    return (
      <span className="font-mono text-sm font-bold text-white tabular-nums">
        {inn.totalRuns}/{inn.totalWickets}
        {inn.totalOvers != null && inn.totalOvers > 0 && (
          <span className="text-xs font-normal text-white/30">
            {" "}
            ({inn.totalOvers})
          </span>
        )}
      </span>
    );
  }

  return (
    <Link
      href={`/m/${match.id}`}
      className={cx(
        "block rounded-[26px] overflow-hidden border transition-all duration-300",
        live
          ? "border-[#CCFF00]/20 bg-[#CCFF00]/[0.06] shadow-[0_10px_40px_rgba(204,255,0,0.07)]"
          : "border-white/10 bg-white/[0.04] hover:bg-white/[0.06] hover:translate-y-[-1px]",
      )}
    >
      <div className="flex flex-col gap-2 border-b border-white/6 px-4 pb-3 pt-4 sm:flex-row sm:items-center sm:justify-between">
        <div className="flex items-center gap-2 flex-wrap min-w-0">
          {match.round && (
            <span className="text-[10px] font-bold uppercase tracking-[0.18em] text-white/28">
              {match.round}
            </span>
          )}
          {wo && (
            <span className="text-[10px] font-bold text-amber-300 bg-amber-400/10 border border-amber-300/15 px-2 py-0.5 rounded-full">
              Walkover
            </span>
          )}
        </div>

        <div className="flex items-center gap-2 flex-wrap sm:justify-end">
          <span className="text-[10px] text-white/28">
            {fmtShort(match.scheduledAt)} · {fmtTime(match.scheduledAt)}
          </span>

          {live && (
            <span className="flex items-center gap-1 text-[10px] font-bold text-[#CCFF00] bg-[#CCFF00]/10 border border-[#CCFF00]/15 px-2 py-0.5 rounded-full">
              <span className="w-1.5 h-1.5 bg-[#CCFF00] rounded-full animate-pulse" />
              LIVE
            </span>
          )}

          {done && !match.winnerId && (
            <span className="text-[10px] text-white/25">No Result</span>
          )}
        </div>
      </div>

      <div className="px-3 py-3 space-y-2">
        {(
          [
            { name: match.teamAName, won: aWon, inn: inn1 },
            { name: match.teamBName, won: bWon, inn: inn2 },
          ] as { name: string; won: boolean; inn?: Innings }[]
        ).map(({ name, won, inn }) => {
          const brand = getTeamBrand(teamBrandMap, name);

          return (
            <div
              key={name}
              className={cx(
                "flex items-center gap-3 rounded-2xl px-2.5 py-3 transition-colors sm:px-3",
                won
                  ? "bg-[#CCFF00]/10"
                  : done
                    ? "opacity-45"
                    : "hover:bg-white/[0.04]",
              )}
            >
              <TeamAvatar
                name={name}
                logoUrl={brand?.logoUrl}
                shortName={brand?.shortName}
                tone={won ? "winner" : "default"}
              />

              <span
                className={cx(
                  "flex-1 text-sm font-semibold truncate",
                  won ? "text-white" : done ? "text-white/35" : "text-white/80",
                )}
              >
                {name}
              </span>

              <div className="flex items-center gap-1.5 shrink-0 text-right">
                <Score inn={inn} />
                {won && <span className="text-[#CCFF00] text-xs">✓</span>}
              </div>
            </div>
          );
        })}
      </div>
    </Link>
  );
}

// ─────────────────────────────────────────────────────────────
// Bracket
// ─────────────────────────────────────────────────────────────
function BracketCard({
  m,
  teamBrandMap,
}: {
  m: Match;
  teamBrandMap: TeamBrandMap;
}) {
  const done = m.status === "COMPLETED";
  const aWon = done && isAWon(m);
  const bWon = done && !!m.winnerId && !aWon;

  return (
    <div className="w-[176px] shrink-0 overflow-hidden rounded-[20px] border border-white/10 bg-white/[0.04] sm:w-[190px]">
      {(
        [
          { name: m.teamAName, won: aWon },
          { name: m.teamBName, won: bWon },
        ] as { name: string; won: boolean }[]
      ).map(({ name, won }, idx) => {
        const brand = getTeamBrand(teamBrandMap, name);

        return (
          <div
            key={name}
            className={cx(
              "flex items-center gap-2 px-3 py-3 text-xs",
              idx === 0 ? "border-b border-white/6" : "",
              won ? "bg-[#CCFF00]/10" : done ? "opacity-45" : "",
            )}
          >
            <TeamAvatar
              name={name}
              logoUrl={brand?.logoUrl}
              shortName={brand?.shortName}
              size="sm"
              tone={won ? "winner" : "default"}
            />
            <span
              className={cx(
                "flex-1 truncate font-semibold",
                won ? "text-white" : "text-white/55",
              )}
            >
              {name}
            </span>
            {won && <span className="text-[#CCFF00] text-[10px]">✓</span>}
          </div>
        );
      })}
    </div>
  );
}

function Bracket({
  matches,
  teamBrandMap,
}: {
  matches: Match[];
  teamBrandMap: TeamBrandMap;
}) {
  const byRound = matches.reduce(
    (acc, m) => {
      const r = m.round ?? "Round";
      if (!acc[r]) acc[r] = [];
      acc[r].push(m);
      return acc;
    },
    {} as Record<string, Match[]>,
  );

  const rounds = Object.keys(byRound).sort((a, b) => {
    const ai = KNOCKOUT_ORDER.indexOf(a);
    const bi = KNOCKOUT_ORDER.indexOf(b);
    if (ai === -1 && bi === -1) return 0;
    if (ai === -1) return 1;
    if (bi === -1) return -1;
    return ai - bi;
  });

  if (!rounds.length)
    return <EmptyState icon="🏏" msg="No bracket matches yet" />;

  const lastRound = rounds[rounds.length - 1];
  const fm =
    lastRound && byRound[lastRound]?.length === 1
      ? byRound[lastRound][0]
      : null;
  const champion = fm?.winnerId
    ? isAWon(fm)
      ? fm.teamAName
      : fm.teamBName
    : null;

  return (
    <div className="overflow-x-auto">
      <div className="flex min-w-fit items-center gap-0 px-2 py-4">
        {rounds.map((round, ri) => {
          const rMatches = byRound[round];
          const isFinal = round === "Final" || round === "Grand Final";

          return (
            <div key={round} className="flex items-stretch">
              <div className="flex min-w-[190px] flex-col sm:min-w-[220px]">
                <div
                  className={cx(
                    "text-[10px] font-bold text-center mb-5 py-2 px-4 mx-2 rounded-full tracking-[0.18em] uppercase border",
                    isFinal
                      ? "bg-amber-400/10 text-amber-300 border-amber-300/20"
                      : "bg-white/[0.04] text-white/35 border-white/8",
                  )}
                >
                  {round}
                </div>

                <div className="flex flex-col flex-1 justify-around gap-4">
                  {rMatches.map((m) => (
                    <div key={m.id} className="px-2">
                      <BracketCard m={m} teamBrandMap={teamBrandMap} />
                    </div>
                  ))}
                </div>
              </div>

              {ri < rounds.length - 1 && (
                <div className="flex flex-col justify-around w-8 shrink-0 mt-10">
                  {Array.from({ length: Math.ceil(rMatches.length / 2) }).map(
                    (_, i) => (
                      <div key={i} className="flex flex-col h-24">
                        <div className="border-r border-t border-white/15 h-1/2" />
                        <div className="border-r border-b border-white/15 h-1/2" />
                      </div>
                    ),
                  )}
                </div>
              )}
            </div>
          );
        })}

        <div className="flex flex-col items-center justify-center ml-6 px-6">
          <div className="text-4xl mb-2">🏆</div>
          <p className="text-[10px] font-bold text-amber-300 uppercase tracking-[0.2em] mb-2">
            Champion
          </p>
          {champion ? (
            <div className="rounded-2xl bg-gradient-to-b from-amber-300/12 to-orange-300/10 border border-amber-300/20 px-6 py-3 text-center">
              <p className="text-sm font-bold text-amber-100">{champion}</p>
            </div>
          ) : (
            <div className="rounded-2xl bg-white/[0.04] border border-white/10 px-6 py-3 text-white/30 text-sm">
              TBD
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Standings
// ─────────────────────────────────────────────────────────────
function StandingsTable({
  standings,
  teamBrandMap,
  mini,
}: {
  standings: Standing[];
  teamBrandMap: TeamBrandMap;
  mini?: boolean;
}) {
  if (!standings.length)
    return (
      <EmptyState
        icon="📊"
        msg="Standings will appear after matches are played"
      />
    );

  const rows = mini ? standings.slice(0, 5) : standings;
  const anyPlayed = standings.some((s) => s.played > 0);
  const qualifyCount = anyPlayed ? (standings.length >= 4 ? 2 : 1) : 0;
  const qualifyPts =
    qualifyCount > 0 ? (standings[qualifyCount - 1]?.points ?? 0) : 0;
  const borderPts =
    qualifyCount < standings.length
      ? (standings[qualifyCount]?.points ?? -1)
      : -1;
  const clearCutoff = qualifyPts > borderPts;

  return (
    <div className="rounded-[26px] overflow-hidden border border-white/10 bg-white/[0.04]">
      <div className="overflow-x-auto">
        <table className="min-w-[500px] w-full text-sm sm:min-w-[560px]">
          <thead>
            <tr className="bg-white/[0.03] border-b border-white/8">
              <th className="px-3 py-3 text-left text-[10px] font-bold uppercase tracking-[0.18em] text-white/25 w-8">
                #
              </th>
              <th className="px-3 py-3 text-left text-[10px] font-bold uppercase tracking-[0.18em] text-white/25">
                Team
              </th>
              <th className="px-3 py-3 text-center text-[10px] font-bold uppercase tracking-[0.18em] text-white/25 w-10">
                P
              </th>
              <th className="px-3 py-3 text-center text-[10px] font-bold uppercase tracking-[0.18em] text-white/25 w-10">
                W
              </th>
              <th className="px-3 py-3 text-center text-[10px] font-bold uppercase tracking-[0.18em] text-white/25 w-10">
                L
              </th>
              <th className="px-3 py-3 text-center text-[10px] font-bold uppercase tracking-[0.18em] text-white/25 w-10">
                T
              </th>
              <th className="px-3 py-3 text-center text-[10px] font-bold uppercase tracking-[0.18em] text-white/25 w-10">
                NR
              </th>
              <th className="px-3 py-3 text-center text-[10px] font-bold uppercase tracking-[0.18em] text-white/40 w-12">
                Pts
              </th>
              <th className="px-3 py-3 text-center text-[10px] font-bold uppercase tracking-[0.18em] text-white/25 w-20">
                NRR
              </th>
            </tr>
          </thead>

          <tbody className="divide-y divide-white/6">
            {rows.map((s, i) => {
              const isFirst = i === 0 && clearCutoff && s.played > 0;
              const qualifies = clearCutoff && i < qualifyCount && s.played > 0;
              const brand = getTeamBrand(teamBrandMap, s.teamName);

              return (
                <tr
                  key={s.id}
                  className={cx(
                    "transition-colors hover:bg-white/[0.03]",
                    qualifies ? "bg-[#CCFF00]/[0.03]" : "",
                  )}
                >
                  <td className="px-3 py-3">
                    {isFirst ? (
                      <span className="flex items-center justify-center w-6 h-6 rounded-full bg-amber-300/15 text-amber-200 text-[11px] font-bold">
                        1
                      </span>
                    ) : qualifies ? (
                      <span className="flex items-center justify-center w-6 h-6 rounded-full bg-[#CCFF00]/15 text-[#CCFF00] text-[11px] font-bold">
                        {i + 1}
                      </span>
                    ) : (
                      <span className="text-xs font-medium text-white/25 pl-1.5">
                        {i + 1}
                      </span>
                    )}
                  </td>

                  <td className="px-3 py-3">
                    <div className="flex items-center gap-2.5">
                      <TeamAvatar
                        name={s.teamName}
                        logoUrl={brand?.logoUrl}
                        shortName={brand?.shortName}
                        tone={
                          isFirst
                            ? "leader"
                            : qualifies
                              ? "qualifier"
                              : "default"
                        }
                      />

                      <div className="min-w-0">
                        <p
                          className={cx(
                            "font-semibold text-sm leading-tight truncate",
                            qualifies ? "text-white" : "text-white/70",
                          )}
                        >
                          {s.teamName}
                        </p>
                        {qualifies && (
                          <p
                            className={cx(
                              "text-[10px] font-medium mt-0.5",
                              isFirst ? "text-amber-300" : "text-[#CCFF00]",
                            )}
                          >
                            {isFirst && standings.length > 1
                              ? "Top seed"
                              : "Qualifies"}
                          </p>
                        )}
                      </div>
                    </div>
                  </td>

                  <td className="px-3 py-3 text-center text-white/45 tabular-nums text-xs">
                    {s.played}
                  </td>
                  <td className="px-3 py-3 text-center tabular-nums text-xs font-semibold text-[#CCFF00]">
                    {s.won}
                  </td>
                  <td className="px-3 py-3 text-center tabular-nums text-xs font-semibold text-red-300">
                    {s.lost}
                  </td>
                  <td className="px-3 py-3 text-center tabular-nums text-xs text-white/45">
                    {s.tied}
                  </td>
                  <td className="px-3 py-3 text-center tabular-nums text-xs text-white/45">
                    {s.noResult}
                  </td>

                  <td className="px-3 py-3 text-center">
                    <span
                      className={cx(
                        "inline-flex items-center justify-center min-w-[2rem] px-2 h-7 rounded-lg text-sm font-bold",
                        isFirst
                          ? "bg-amber-300/15 text-amber-200"
                          : qualifies
                            ? "bg-[#CCFF00]/15 text-[#CCFF00]"
                            : "bg-white/[0.05] text-white/80",
                      )}
                    >
                      {s.points}
                    </span>
                  </td>

                  <td className="px-3 py-3 text-center">
                    {s.netRunRate != null ? (
                      <span
                        className={cx(
                          "font-mono text-xs font-medium",
                          s.netRunRate >= 0 ? "text-[#CCFF00]" : "text-red-300",
                        )}
                      >
                        {s.netRunRate >= 0 ? "+" : ""}
                        {Number(s.netRunRate).toFixed(3)}
                      </span>
                    ) : (
                      <span className="text-white/25 text-xs">—</span>
                    )}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      {mini && clearCutoff && standings.length > qualifyCount && (
        <div className="px-4 py-3 border-t border-white/6 flex items-center gap-2">
          <div className="w-2.5 h-2.5 rounded-sm bg-[#CCFF00]/20 border border-[#CCFF00]/30" />
          <span className="text-[10px] text-white/35">
            Qualifies for next round
          </span>
        </div>
      )}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Grouped standings
// ─────────────────────────────────────────────────────────────
function GroupedStandingsTables({
  standings,
  teamBrandMap,
  mini,
}: {
  standings: Standing[];
  teamBrandMap: TeamBrandMap;
  mini?: boolean;
}) {
  if (!standings.length)
    return (
      <EmptyState
        icon="📊"
        msg="Standings will appear after matches are played"
      />
    );

  const groupMap = new Map<string, { name: string; rows: Standing[] }>();
  for (const s of standings) {
    const key = s.groupId ?? "overall";
    if (!groupMap.has(key))
      groupMap.set(key, { name: s.groupName ?? "Group", rows: [] });
    groupMap.get(key)!.rows.push(s);
  }

  const groups = Array.from(groupMap.entries());

  return (
    <div className="space-y-6">
      {groups.map(([key, g]) => (
        <div key={key}>
          <div className="flex items-center gap-3 mb-3">
            <span className="text-xs font-bold uppercase tracking-[0.18em] text-[#CCFF00] bg-[#CCFF00]/10 px-3 py-1 rounded-full border border-[#CCFF00]/15">
              {g.name}
            </span>
            <div className="flex-1 h-px bg-white/8" />
          </div>
          <StandingsTable
            standings={g.rows}
            teamBrandMap={teamBrandMap}
            mini={mini}
          />
        </div>
      ))}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Highlights
// ─────────────────────────────────────────────────────────────
function HighlightsGrid({ highlights }: { highlights: Highlight[] }) {
  if (!highlights.length)
    return (
      <EmptyState
        icon="🎬"
        msg="No highlights yet — check back after matches"
      />
    );

  return (
    <div className="grid gap-5 md:grid-cols-2">
      {highlights.map((h, i) => {
        const vid = getYouTubeId(h.youtubeUrl);

        return (
          <div
            key={i}
            className="rounded-[24px] overflow-hidden border border-white/10 bg-white/[0.04]"
          >
            {vid ? (
              <div className="aspect-video">
                <iframe
                  src={`https://www.youtube.com/embed/${vid}`}
                  title={h.title}
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                  allowFullScreen
                  className="w-full h-full"
                />
              </div>
            ) : (
              <a
                href={h.youtubeUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center gap-4 p-5 hover:bg-white/[0.03] transition-colors"
              >
                <div className="w-12 h-12 rounded-xl bg-red-500/10 border border-red-400/15 flex items-center justify-center text-xl shrink-0 text-red-300">
                  ▶
                </div>
                <span className="font-semibold text-white/85">{h.title}</span>
              </a>
            )}

            <div className="px-4 py-3 border-t border-white/6">
              <p className="text-sm font-semibold text-white/80">{h.title}</p>
            </div>
          </div>
        );
      })}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Full bracket: group columns → knockout
// ─────────────────────────────────────────────────────────────
function FullBracketView({
  matches,
  teamBrandMap,
}: {
  matches: Match[];
  teamBrandMap: TeamBrandMap;
}) {
  const groupMatches = matches.filter((m) => !KNOCKOUT_SET.has(m.round ?? ""));
  const knockoutMatches = matches.filter((m) =>
    KNOCKOUT_SET.has(m.round ?? ""),
  );

  if (!groupMatches.length && !knockoutMatches.length) {
    return <EmptyState icon="🏏" msg="No matches scheduled yet" />;
  }

  const groupMap = new Map<string, Match[]>();
  for (const m of groupMatches) {
    // use groupName from API, then round, then fallback
    const key = m.groupName ?? m.round ?? "Group Stage";
    if (!groupMap.has(key)) groupMap.set(key, []);
    groupMap.get(key)!.push(m);
  }
  const groups = Array.from(groupMap.entries());

  const koByRound = knockoutMatches.reduce(
    (acc, m) => {
      const r = m.round ?? "KO";
      if (!acc[r]) acc[r] = [];
      acc[r].push(m);
      return acc;
    },
    {} as Record<string, Match[]>,
  );

  const koRounds = Object.keys(koByRound).sort((a, b) => {
    const ai = KNOCKOUT_ORDER.indexOf(a);
    const bi = KNOCKOUT_ORDER.indexOf(b);
    if (ai === -1 && bi === -1) return 0;
    if (ai === -1) return 1;
    if (bi === -1) return -1;
    return ai - bi;
  });

  const lastRound = koRounds[koRounds.length - 1];
  const finalMatch =
    lastRound && koByRound[lastRound]?.length === 1
      ? koByRound[lastRound][0]
      : null;
  const champion = finalMatch?.winnerId
    ? isAWon(finalMatch)
      ? finalMatch.teamAName
      : finalMatch.teamBName
    : null;

  return (
    <div className="overflow-x-auto">
      <div className="flex min-w-fit items-start gap-0 px-2 py-4">
        {groups.map(([groupName, gMatches], gi) => (
          <div key={groupName} className="flex items-stretch">
            <div className="flex min-w-[190px] flex-col sm:min-w-[220px]">
              <div className="text-[10px] font-bold text-center mb-5 py-2 px-4 mx-2 rounded-full tracking-[0.18em] uppercase border bg-[#CCFF00]/10 text-[#CCFF00] border-[#CCFF00]/15">
                {groupName}
              </div>

              <div className="flex flex-col gap-4">
                {gMatches.map((m) => (
                  <div key={m.id} className="px-2">
                    <BracketCard m={m} teamBrandMap={teamBrandMap} />
                  </div>
                ))}
              </div>
            </div>

            {(gi < groups.length - 1 || koRounds.length > 0) && (
              <div className="flex flex-col justify-around w-8 shrink-0 mt-10">
                {Array.from({ length: Math.ceil(gMatches.length / 2) }).map(
                  (_, i) => (
                    <div key={i} className="flex flex-col h-24">
                      <div className="border-r border-t border-white/15 h-1/2" />
                      <div className="border-r border-b border-white/15 h-1/2" />
                    </div>
                  ),
                )}
              </div>
            )}
          </div>
        ))}

        {groups.length > 0 && koRounds.length > 0 && (
          <div className="flex flex-col items-center justify-center mx-3 self-stretch">
            <div className="h-full w-px border-l border-dashed border-white/12" />
          </div>
        )}

        {koRounds.map((round, ri) => {
          const rMatches = koByRound[round];
          const isFinal = round === "Final" || round === "Grand Final";

          return (
            <div key={round} className="flex items-stretch">
              <div className="flex min-w-[190px] flex-col sm:min-w-[220px]">
                <div
                  className={cx(
                    "text-[10px] font-bold text-center mb-5 py-2 px-4 mx-2 rounded-full tracking-[0.18em] uppercase border",
                    isFinal
                      ? "bg-amber-400/10 text-amber-300 border-amber-300/20"
                      : "bg-white/[0.04] text-white/35 border-white/8",
                  )}
                >
                  {round}
                </div>

                <div className="flex flex-col flex-1 justify-around gap-4">
                  {rMatches.map((m) => (
                    <div key={m.id} className="px-2">
                      <BracketCard m={m} teamBrandMap={teamBrandMap} />
                    </div>
                  ))}
                </div>
              </div>

              {ri < koRounds.length - 1 && (
                <div className="flex flex-col justify-around w-8 shrink-0 mt-10">
                  {Array.from({ length: Math.ceil(rMatches.length / 2) }).map(
                    (_, i) => (
                      <div key={i} className="flex flex-col h-24">
                        <div className="border-r border-t border-white/15 h-1/2" />
                        <div className="border-r border-b border-white/15 h-1/2" />
                      </div>
                    ),
                  )}
                </div>
              )}
            </div>
          );
        })}

        {koRounds.length > 0 && (
          <div className="flex flex-col items-center justify-center ml-6 px-6">
            <div className="text-4xl mb-2">🏆</div>
            <p className="text-[10px] font-bold text-amber-300 uppercase tracking-[0.2em] mb-2">
              Champion
            </p>
            {champion ? (
              <div className="rounded-2xl bg-gradient-to-b from-amber-300/12 to-orange-300/10 border border-amber-300/20 px-6 py-3 text-center">
                <p className="text-sm font-bold text-amber-100">{champion}</p>
              </div>
            ) : (
              <div className="rounded-2xl bg-white/[0.04] border border-white/10 px-6 py-3 text-white/30 text-sm">
                TBD
              </div>
            )}
          </div>
        )}

        {koRounds.length === 0 && groups.length > 0 && (
          <div className="flex flex-col items-center justify-center ml-8 px-6 gap-3">
            <div className="text-3xl opacity-20">🏆</div>
            <p className="text-[10px] text-white/25 font-medium text-center max-w-[100px]">
              Knockout stage after groups
            </p>
          </div>
        )}
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Fixtures table
// ─────────────────────────────────────────────────────────────
function FixturesTable({
  matches,
  teamBrandMap,
}: {
  matches: Match[];
  teamBrandMap: TeamBrandMap;
}) {
  const hasRound = matches.some((m) => m.round);

  return (
    <div className="rounded-[26px] overflow-hidden border border-white/10 bg-white/[0.04]">
      <div className="overflow-x-auto">
        <table className="min-w-[460px] w-full text-sm sm:min-w-[540px]">
          <thead>
            <tr className="bg-white/[0.03] border-b border-white/8">
              <th className="px-4 py-3 text-left text-[10px] font-bold uppercase tracking-[0.18em] text-white/25 w-28">
                Date & Time
              </th>
              <th className="px-4 py-3 text-left text-[10px] font-bold uppercase tracking-[0.18em] text-white/25">
                Teams
              </th>
              {hasRound && (
                <th className="px-4 py-3 text-left text-[10px] font-bold uppercase tracking-[0.18em] text-white/25 hidden sm:table-cell">
                  Round
                </th>
              )}
              <th className="px-4 py-3 text-right text-[10px] font-bold uppercase tracking-[0.18em] text-white/25 w-36"></th>
            </tr>
          </thead>

          <tbody className="divide-y divide-white/6">
            {matches.map((m) => {
              const isLive = m.status === "IN_PROGRESS";
              const teamABrand = getTeamBrand(teamBrandMap, m.teamAName);
              const teamBBrand = getTeamBrand(teamBrandMap, m.teamBName);

              return (
                <tr
                  key={m.id}
                  className="hover:bg-white/[0.03] transition-colors group"
                >
                  <td className="px-4 py-3.5 whitespace-nowrap">
                    <div className="text-xs text-white/50">
                      {fmtShort(m.scheduledAt)}
                    </div>
                    <div className="text-[11px] text-white/25 mt-0.5">
                      {fmtTime(m.scheduledAt)}
                    </div>
                  </td>

                  <td className="px-4 py-3.5">
                    <div className="flex flex-col gap-1.5">
                      <div className="flex items-center gap-2">
                        <TeamAvatar
                          name={m.teamAName}
                          logoUrl={teamABrand?.logoUrl}
                          shortName={teamABrand?.shortName}
                          size="sm"
                        />
                        <span className="text-xs font-semibold text-white/70">
                          {m.teamAName}
                        </span>
                      </div>
                      <div className="flex items-center gap-2">
                        <TeamAvatar
                          name={m.teamBName}
                          logoUrl={teamBBrand?.logoUrl}
                          shortName={teamBBrand?.shortName}
                          size="sm"
                        />
                        <span className="text-xs font-semibold text-white/70">
                          {m.teamBName}
                        </span>
                      </div>
                    </div>
                  </td>

                  {hasRound && (
                    <td className="px-4 py-3.5 hidden sm:table-cell">
                      {m.round && (
                        <span className="text-[10px] font-medium text-white/40 bg-white/[0.04] border border-white/8 px-2 py-0.5 rounded-full">
                          {m.round}
                        </span>
                      )}
                    </td>
                  )}

                  <td className="px-4 py-3.5 text-right">
                    {isLive ? (
                      <Link
                        href={`/m/${m.id}`}
                        className="inline-flex items-center gap-1.5 rounded-full px-3 py-1.5 text-[11px] font-bold text-black bg-[#CCFF00] hover:opacity-90 transition-opacity"
                      >
                        <span className="w-1.5 h-1.5 rounded-full bg-black animate-pulse" />
                        Live
                      </Link>
                    ) : (
                      <Link
                        href={`/m/${m.id}`}
                        className="inline-flex items-center gap-1 rounded-full px-3 py-1.5 text-[11px] font-bold text-white/60 border border-white/10 bg-white/[0.04] hover:text-white hover:border-white/20 hover:bg-white/[0.07] transition-all"
                      >
                        Match Centre
                        <span className="text-white/30">→</span>
                      </Link>
                    )}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Results table
// ─────────────────────────────────────────────────────────────
function ResultsTable({
  matches,
  teamBrandMap,
}: {
  matches: Match[];
  teamBrandMap: TeamBrandMap;
}) {
  const hasRound = matches.some((m) => m.round);

  return (
    <div className="rounded-[26px] overflow-hidden border border-white/10 bg-white/[0.04]">
      <div className="overflow-x-auto">
        <table className="min-w-[500px] w-full text-sm sm:min-w-[620px]">
          <thead>
            <tr className="bg-white/[0.03] border-b border-white/8">
              <th className="px-4 py-3 text-left text-[10px] font-bold uppercase tracking-[0.18em] text-white/25 w-24">
                Date
              </th>
              <th className="px-4 py-3 text-left text-[10px] font-bold uppercase tracking-[0.18em] text-white/25">
                Match
              </th>
              <th className="px-4 py-3 text-left text-[10px] font-bold uppercase tracking-[0.18em] text-white/25 hidden sm:table-cell">
                Score
              </th>
              <th className="px-4 py-3 text-left text-[10px] font-bold uppercase tracking-[0.18em] text-white/25">
                Result
              </th>
              {hasRound && (
                <th className="px-4 py-3 text-left text-[10px] font-bold uppercase tracking-[0.18em] text-white/25 hidden md:table-cell">
                  Round
                </th>
              )}
              <th className="px-4 py-3 w-32" />
            </tr>
          </thead>

          <tbody className="divide-y divide-white/6">
            {matches.map((m) => {
              const aWon = isAWon(m);
              const bWon = !!m.winnerId && !aWon;
              const abandoned = m.status === "ABANDONED";
              const wo = m.winMargin === "W/O";
              const inn1 = m.innings?.find((i) => i.inningsNumber === 1);
              const inn2 = m.innings?.find((i) => i.inningsNumber === 2);
              const winner = aWon ? m.teamAName : bWon ? m.teamBName : null;
              const teamABrand = getTeamBrand(teamBrandMap, m.teamAName);
              const teamBBrand = getTeamBrand(teamBrandMap, m.teamBName);

              return (
                <tr
                  key={m.id}
                  className="hover:bg-white/[0.03] transition-colors"
                >
                  <td className="px-4 py-3.5 text-xs text-white/35 whitespace-nowrap">
                    {fmtShort(m.scheduledAt)}
                  </td>

                  <td className="px-4 py-3.5">
                    <div className="flex flex-col gap-1.5">
                      <div className="flex items-center gap-2">
                        <TeamAvatar
                          name={m.teamAName}
                          logoUrl={teamABrand?.logoUrl}
                          shortName={teamABrand?.shortName}
                          size="sm"
                          tone={aWon ? "winner" : "default"}
                        />
                        <span
                          className={cx(
                            "text-xs font-semibold",
                            aWon ? "text-white" : "text-white/40",
                          )}
                        >
                          {m.teamAName}
                        </span>
                        {aWon && (
                          <span className="text-[#CCFF00] text-[10px]">✓</span>
                        )}
                      </div>

                      <div className="flex items-center gap-2">
                        <TeamAvatar
                          name={m.teamBName}
                          logoUrl={teamBBrand?.logoUrl}
                          shortName={teamBBrand?.shortName}
                          size="sm"
                          tone={bWon ? "winner" : "default"}
                        />
                        <span
                          className={cx(
                            "text-xs font-semibold",
                            bWon ? "text-white" : "text-white/40",
                          )}
                        >
                          {m.teamBName}
                        </span>
                        {bWon && (
                          <span className="text-[#CCFF00] text-[10px]">✓</span>
                        )}
                      </div>
                    </div>
                  </td>

                  <td className="px-4 py-3.5 hidden sm:table-cell">
                    <div className="flex flex-col gap-1">
                      {[inn1, inn2].map((inn, idx) =>
                        inn ? (
                          <span
                            key={idx}
                            className="font-mono text-xs text-white/70 tabular-nums"
                          >
                            {inn.totalRuns}/{inn.totalWickets}
                            {(inn.totalOvers ?? 0) > 0 && (
                              <span className="text-white/30">
                                {" "}
                                ({inn.totalOvers}ov)
                              </span>
                            )}
                          </span>
                        ) : (
                          <span key={idx} className="text-white/20 text-xs">
                            —
                          </span>
                        ),
                      )}
                    </div>
                  </td>

                  <td className="px-4 py-3.5">
                    {abandoned ? (
                      <span className="text-[11px] font-semibold text-white/40">
                        Abandoned
                      </span>
                    ) : wo ? (
                      <span className="text-[11px] font-semibold text-amber-300">
                        Walkover · {winner}
                      </span>
                    ) : winner ? (
                      <div>
                        <span className="text-[11px] font-bold text-[#CCFF00]">
                          {winner}
                        </span>
                        {m.winMargin && (
                          <span className="text-[10px] text-white/35 block">
                            by {m.winMargin}
                          </span>
                        )}
                      </div>
                    ) : (
                      <span className="text-[11px] text-white/40">
                        No result
                      </span>
                    )}
                  </td>

                  {hasRound && (
                    <td className="px-4 py-3.5 hidden md:table-cell">
                      {m.round && (
                        <span className="text-[10px] font-medium text-white/40 bg-white/[0.04] border border-white/8 px-2 py-0.5 rounded-full">
                          {m.round}
                        </span>
                      )}
                    </td>
                  )}
                  <td className="px-4 py-3.5 text-right">
                    <Link
                      href={`/m/${m.id}`}
                      className="inline-flex items-center gap-1 rounded-full px-3 py-1.5 text-[11px] font-bold text-white/60 border border-white/10 bg-white/[0.04] hover:text-white hover:border-white/20 hover:bg-white/[0.07] transition-all"
                    >
                      Match Centre
                      <span className="text-white/30">→</span>
                    </Link>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Teams
// ─────────────────────────────────────────────────────────────
function TeamsGrid({ teams }: { teams: Team[] }) {
  if (!teams.length)
    return <EmptyState icon="👥" msg="No teams registered yet" />;

  return (
    <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 xl:grid-cols-3">
      {teams.map((t) => (
        <div
          key={t.id}
          className="group flex items-center gap-4 rounded-[22px] border border-white/10 bg-white/[0.04] p-3.5 transition-all hover:bg-white/[0.05] sm:p-4"
        >
          <TeamAvatar
            name={t.teamName}
            logoUrl={getTeamLogoUrl(t)}
            shortName={getTeamShortName(t)}
            size="lg"
          />

          <div className="min-w-0">
            <p className="text-sm font-semibold text-white truncate">
              {t.teamName}
            </p>
            {t.isConfirmed && (
              <p className="text-[10px] text-[#CCFF00] font-medium mt-0.5">
                Confirmed
              </p>
            )}
          </div>
        </div>
      ))}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Shared
// ─────────────────────────────────────────────────────────────
function SectionLabel({
  title,
  subtitle,
}: {
  title: string;
  subtitle?: string;
}) {
  return (
    <div className="mb-4 flex flex-wrap items-end justify-between gap-3 sm:gap-4">
      <div>
        <p className="text-[10px] font-bold uppercase tracking-[0.25em] text-white/25 mb-1">
          Swing Cricket
        </p>
        <h3 className="text-xl md:text-2xl font-black italic tracking-tight text-white">
          {title}
        </h3>
      </div>
      {subtitle && (
        <span className="text-xs text-white/30 font-medium">{subtitle}</span>
      )}
    </div>
  );
}

function EmptyState({ icon, msg }: { icon: string; msg: string }) {
  return (
    <div className="rounded-[26px] border border-dashed border-white/10 bg-white/[0.03] py-16 text-center">
      <div className="text-4xl mb-3 opacity-40">{icon}</div>
      <p className="text-sm text-white/35">{msg}</p>
    </div>
  );
}

function ViewMore({ label, onClick }: { label: string; onClick: () => void }) {
  return (
    <button
      onClick={onClick}
      className="mt-4 text-xs font-bold text-[#CCFF00] hover:text-white transition-colors flex items-center gap-1"
    >
      {label} <span>→</span>
    </button>
  );
}

// ─────────────────────────────────────────────────────────────
// Main
// ─────────────────────────────────────────────────────────────
type TabId =
  | "overview"
  | "fixtures"
  | "results"
  | "standings"
  | "bracket"
  | "highlights"
  | "teams";

export default function TournamentPage({
  tournament,
  matches,
  standings,
}: Props) {
  const fmt = tournament.tournamentFormat ?? "LEAGUE";
  const isLeague = LEAGUE_FMT.includes(fmt);
  const isKnockout = KNOCKOUT_FMT.includes(fmt);
  const isGroupKO = ["GROUP_STAGE_KNOCKOUT", "SUPER_LEAGUE"].includes(fmt);

  const live = matches.filter((m) => m.status === "IN_PROGRESS");
  const upcoming = matches.filter((m) => m.status === "SCHEDULED");
  const completed = matches.filter(
    (m) => m.status === "COMPLETED" || m.status === "ABANDONED",
  );
  const koMatches = matches.filter((m) => KNOCKOUT_SET.has(m.round ?? ""));
  const groupStageMatches = matches.filter(
    (m) => !KNOCKOUT_SET.has(m.round ?? ""),
  );
  const showBracket =
    isKnockout ||
    (isGroupKO && (groupStageMatches.length > 0 || koMatches.length > 0));
  const highlights = tournament.highlights ?? [];
  const teamBrandMap = buildTeamBrandMap(tournament.teams ?? []);

  const tabs: { id: TabId; label: string; count?: number }[] = [
    { id: "overview", label: "Overview" },
    { id: "fixtures", label: "Fixtures", count: upcoming.length },
    { id: "results", label: "Results", count: completed.length },
    ...(isLeague ? [{ id: "standings" as TabId, label: "Standings" }] : []),
    ...(showBracket ? [{ id: "bracket" as TabId, label: "Bracket" }] : []),
    { id: "highlights", label: "Highlights", count: highlights.length },
    { id: "teams", label: "Teams", count: tournament.teams?.length },
  ];

  const [active, setActive] = useState<TabId>("overview");

  const isLive = tournament.status === "ONGOING";
  const isCompleted = tournament.status === "COMPLETED";

  return (
    <div className="min-h-screen bg-[#06080D] text-white overflow-x-hidden">
      {/* Background */}
      <div className="fixed inset-0 -z-10 overflow-hidden">
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_left,rgba(204,255,0,0.08),transparent_25%),radial-gradient(circle_at_top_right,rgba(59,130,246,0.10),transparent_25%),radial-gradient(circle_at_bottom_left,rgba(255,255,255,0.04),transparent_20%)]" />
        <div className="absolute inset-0 bg-[linear-gradient(to_bottom,rgba(255,255,255,0.03)_1px,transparent_1px),linear-gradient(to_right,rgba(255,255,255,0.03)_1px,transparent_1px)] bg-[size:42px_42px] opacity-[0.03]" />
        <div className="absolute inset-0 bg-[#06080D]/88" />
      </div>

      {/* Nav */}
      <nav className="sticky top-0 z-40 border-b border-white/8 bg-[#06080D]/90 backdrop-blur-2xl">
        <div className="mx-auto flex h-14 max-w-6xl items-center justify-between px-4 md:px-8">
          <Link href="/" className="text-lg font-black tracking-tight text-white">
            SWING<span className="text-[#CCFF00]">.</span>
          </Link>
          <div className="flex items-center gap-3">
            {isLive && (
              <span className="flex items-center gap-1.5 rounded-full bg-[#CCFF00]/10 px-3 py-1 text-[10px] font-bold uppercase tracking-widest text-[#CCFF00]">
                <span className="w-1.5 h-1.5 rounded-full bg-[#CCFF00] animate-pulse" />
                Live
              </span>
            )}
            <span className="text-xs text-white/40 hidden sm:block truncate max-w-[200px]">{tournament.name}</span>
          </div>
        </div>
      </nav>

      {/* HERO */}
      <div className="relative">
        {tournament.coverUrl ? (
          <div className="relative h-[160px] w-full overflow-hidden sm:h-[300px] md:h-[420px]">
            <img
              src={tournament.coverUrl}
              alt=""
              className="w-full h-full object-cover object-center"
            />
            <div
              className="absolute inset-0"
              style={{
                background:
                  "linear-gradient(to bottom, rgba(0,0,0,0.08) 0%, rgba(0,0,0,0.18) 38%, rgba(0,0,0,0.72) 78%, rgba(6,8,13,0.97) 100%)",
              }}
            />
          </div>
        ) : (
          <div
            className="relative h-[100px] overflow-hidden sm:h-[220px] md:h-[320px]"
            style={{
              background:
                "linear-gradient(135deg, #07131a 0%, #0d1d16 38%, #0c2114 68%, #101621 100%)",
            }}
          >
            <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_65%_20%,rgba(204,255,0,0.10)_0%,transparent_60%)]" />
            <div className="absolute -right-4 -top-4 text-[200px] opacity-[0.04] select-none">
              🏏
            </div>
          </div>
        )}

        {/* Title card — normal flow on mobile, absolute overlap on sm+ */}
        <div className="sm:absolute sm:bottom-0 sm:left-0 sm:right-0 px-3 py-3 sm:px-4 sm:pb-5 md:px-8 md:pb-8 bg-[#06080D] sm:bg-transparent">
          <div className="max-w-6xl mx-auto">
            <div className="rounded-[20px] border border-white/10 bg-[#06080D]/80 p-4 shadow-[0_20px_80px_rgba(0,0,0,0.35)] sm:backdrop-blur-2xl sm:bg-black/35 sm:p-5 md:rounded-[30px] md:p-8">
              <div className="flex items-start gap-4 md:items-end md:gap-5">
                {tournament.logoUrl && (
                  <div className="relative shrink-0">
                    <div className="absolute inset-0 rounded-2xl bg-white/20 blur-2xl scale-110" />
                    <img
                      src={cbUrl(tournament.logoUrl)}
                      alt="logo"
                      className="relative h-14 w-14 rounded-2xl object-cover shadow-2xl ring-2 ring-white/30 sm:h-20 sm:w-20 sm:rounded-3xl sm:ring-[3px] md:h-28 md:w-28"
                    />
                  </div>
                )}

                <div className="min-w-0 flex-1">
                  <div className="flex flex-wrap items-center gap-2 mb-2 sm:mb-3">
                    {isLive && (
                      <span className="inline-flex items-center gap-1.5 text-[11px] font-black bg-[#CCFF00] text-black px-2.5 py-0.5 rounded-full shadow-lg">
                        <span className="w-1.5 h-1.5 bg-black rounded-full animate-pulse" />
                        LIVE
                      </span>
                    )}
                    {isCompleted && (
                      <span className="text-[11px] font-semibold bg-white/15 text-white px-2.5 py-0.5 rounded-full border border-white/10">
                        Completed
                      </span>
                    )}
                    {!isLive && !isCompleted && (
                      <span className="text-[11px] font-semibold bg-white/15 text-white px-2.5 py-0.5 rounded-full border border-white/10">
                        Upcoming
                      </span>
                    )}
                    <span className="text-[11px] text-white/60 bg-white/10 px-2.5 py-0.5 rounded-full border border-white/10">
                      {fmt.replace(/_/g, " ")}
                    </span>
                  </div>

                  <h1 className="text-xl font-black italic leading-tight tracking-[-0.03em] text-white sm:text-[2rem] md:text-4xl lg:text-5xl">
                    {tournament.name}
                  </h1>

                  <div className="mt-3 flex flex-wrap gap-1.5 sm:gap-2">
                    {(tournament.venueName || tournament.city) && (
                      <span className="inline-flex items-center rounded-full border border-white/10 bg-white/5 px-2.5 py-1 text-[11px] text-white/70">
                        📍{" "}
                        {[tournament.venueName, tournament.city]
                          .filter(Boolean)
                          .join(", ")}
                      </span>
                    )}
                    <span className="inline-flex items-center rounded-full border border-white/10 bg-white/5 px-2.5 py-1 text-[11px] text-white/70">
                      📅 {fmtDate(tournament.startDate)}
                      {tournament.endDate
                        ? ` – ${fmtDate(tournament.endDate)}`
                        : ""}
                    </span>
                    {tournament.prizePool && (
                      <span className="inline-flex items-center rounded-full border border-[#CCFF00]/15 bg-[#CCFF00]/10 px-2.5 py-1 text-[11px] text-[#CCFF00]">
                        🏆 {tournament.prizePool}
                      </span>
                    )}
                  </div>

                  {tournament.description && (
                    <p className="mt-3 max-w-3xl text-sm leading-relaxed text-white/55 line-clamp-2 sm:line-clamp-none md:text-base">
                      {tournament.description}
                    </p>
                  )}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Stats */}
      <div className="relative z-10 mx-auto mt-3 max-w-6xl px-3 sm:mt-6 sm:px-4 md:px-8">
        <div className="grid grid-cols-2 gap-2.5 md:grid-cols-4 md:gap-3">
          {[
            { label: "Teams", val: tournament.teams?.length ?? 0 },
            { label: "Matches", val: matches.length },
            { label: "Played", val: completed.length },
            live.length > 0
              ? { label: "Live", val: live.length, live: true }
              : { label: "Upcoming", val: upcoming.length },
          ].map(({ label, val, ...rest }) => (
            <div
              key={label}
              className={cx(
                "rounded-2xl border p-4 md:p-5",
                "live" in rest && rest.live
                  ? "border-[#CCFF00]/20 bg-[#CCFF00]/10"
                  : "border-white/10 bg-white/[0.04]",
              )}
            >
              <p
                className={cx(
                  "text-2xl md:text-3xl font-black tracking-tight",
                  "live" in rest && rest.live ? "text-[#CCFF00]" : "text-white",
                )}
              >
                {val}
              </p>
              <p className="mt-1 text-[10px] font-bold uppercase tracking-[0.2em] text-white/35">
                {label}
              </p>
            </div>
          ))}
        </div>
      </div>

      {/* Tabs */}
      <div className="sticky top-0 z-30 mt-4 border-b border-white/8 bg-[#06080D]/90 shadow-[0_12px_30px_rgba(0,0,0,0.28)] backdrop-blur-2xl sm:mt-6">
        <div className="mx-auto max-w-6xl px-3 py-3 sm:px-4 md:px-8">
          <div className="flex gap-2 overflow-x-auto rounded-full border border-white/10 bg-white/[0.04] p-1 scrollbar-none">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActive(tab.id)}
                className={cx(
                  "flex items-center gap-1.5 whitespace-nowrap rounded-full px-3 py-2 text-xs font-bold transition-all sm:px-4 sm:py-2.5 sm:text-sm",
                  active === tab.id
                    ? "bg-[#CCFF00] text-black shadow-[0_0_30px_rgba(204,255,0,0.2)]"
                    : "text-white/45 hover:text-white hover:bg-white/[0.05]",
                )}
              >
                {tab.label}
                {tab.count != null && tab.count > 0 && (
                  <span
                    className={cx(
                      "rounded-full px-1.5 py-0.5 text-[10px] font-black",
                      active === tab.id
                        ? "bg-black/10 text-black"
                        : "bg-white/[0.06] text-white/45",
                    )}
                  >
                    {tab.count}
                  </span>
                )}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* CONTENT */}
      <div
        className={cx(
          active === "bracket"
            ? "w-full px-3 sm:px-4 md:px-8"
            : "mx-auto max-w-6xl px-3 sm:px-4 md:px-8",
          "py-5 md:py-8",
        )}
      >
        {active === "overview" && (
          <div className="space-y-10">
            {live.length > 0 && (
              <div>
                <SectionLabel
                  title="Live Now"
                  subtitle={`${live.length} matches in progress`}
                />
                <div className="grid gap-3 lg:grid-cols-2">
                  {live.map((m) => (
                    <MatchCard
                      key={m.id}
                      match={m}
                      teamBrandMap={teamBrandMap}
                    />
                  ))}
                </div>
              </div>
            )}

            {completed.length > 0 && (
              <div>
                <SectionLabel
                  title="Recent Results"
                  subtitle={`${completed.length} played`}
                />
                <div className="grid gap-3 lg:grid-cols-2">
                  {[...completed]
                    .reverse()
                    .slice(0, 4)
                    .map((m) => (
                      <MatchCard
                        key={m.id}
                        match={m}
                        teamBrandMap={teamBrandMap}
                      />
                    ))}
                </div>
                {completed.length > 4 && (
                  <ViewMore
                    label={`All ${completed.length} results`}
                    onClick={() => setActive("results")}
                  />
                )}
              </div>
            )}

            {upcoming.length > 0 && (
              <div>
                <SectionLabel
                  title="Next Up"
                  subtitle={`${upcoming.length} scheduled`}
                />
                <div className="grid gap-3 lg:grid-cols-2">
                  {upcoming.slice(0, 4).map((m) => (
                    <MatchCard
                      key={m.id}
                      match={m}
                      teamBrandMap={teamBrandMap}
                    />
                  ))}
                </div>
                {upcoming.length > 4 && (
                  <ViewMore
                    label={`All ${upcoming.length} fixtures`}
                    onClick={() => setActive("fixtures")}
                  />
                )}
              </div>
            )}

            {isLeague && standings.length > 0 && (
              <div>
                <SectionLabel
                  title="Points Table"
                  subtitle="Updated after each result"
                />
                {isGroupKO ? (
                  <GroupedStandingsTables
                    standings={standings}
                    teamBrandMap={teamBrandMap}
                    mini
                  />
                ) : (
                  <StandingsTable
                    standings={standings}
                    teamBrandMap={teamBrandMap}
                    mini
                  />
                )}
                {standings.length > 5 && (
                  <ViewMore
                    label="Full table"
                    onClick={() => setActive("standings")}
                  />
                )}
              </div>
            )}

            {showBracket && (
              <div>
                <SectionLabel
                  title={isGroupKO ? "Group Stage & Bracket" : "Bracket"}
                />
                <div className={cx(PANEL, "p-4 overflow-x-auto")}>
                  {isGroupKO ? (
                    <FullBracketView
                      matches={matches}
                      teamBrandMap={teamBrandMap}
                    />
                  ) : (
                    <Bracket matches={matches} teamBrandMap={teamBrandMap} />
                  )}
                </div>
                <ViewMore
                  label="Full bracket view"
                  onClick={() => setActive("bracket")}
                />
              </div>
            )}

            {!live.length && !completed.length && !upcoming.length && (
              <EmptyState
                icon="🏏"
                msg="Tournament hasn't started yet. Check back soon."
              />
            )}
          </div>
        )}

        {active === "fixtures" && (
          <div className="space-y-6">
            <SectionLabel
              title="Upcoming Fixtures"
              subtitle={`${upcoming.length} matches`}
            />
            {upcoming.length === 0 ? (
              <EmptyState icon="📅" msg="No upcoming fixtures yet" />
            ) : (
              (() => {
                // Group by round; matches with no round go under "Fixtures"
                const groups = new Map<string, Match[]>();
                for (const m of upcoming) {
                  const key = m.groupName ?? m.round ?? "Fixtures";
                  if (!groups.has(key)) groups.set(key, []);
                  groups.get(key)!.push(m);
                }
                const hasMultipleGroups = groups.size > 1;
                return (
                  <div className="space-y-6">
                    {Array.from(groups.entries()).map(
                      ([groupName, gMatches]) => (
                        <div key={groupName}>
                          {hasMultipleGroups && (
                            <div className="flex items-center gap-3 mb-3">
                              <span className="text-[10px] font-bold uppercase tracking-[0.18em] text-[#CCFF00] bg-[#CCFF00]/10 px-3 py-1 rounded-full border border-[#CCFF00]/15">
                                {groupName}
                              </span>
                              <span className="text-xs text-white/25">
                                {gMatches.length} match
                                {gMatches.length !== 1 ? "es" : ""}
                              </span>
                            </div>
                          )}
                          <FixturesTable
                            matches={gMatches}
                            teamBrandMap={teamBrandMap}
                          />
                        </div>
                      ),
                    )}
                  </div>
                );
              })()
            )}
          </div>
        )}

        {active === "results" && (
          <div className="space-y-6">
            <SectionLabel
              title="Match Results"
              subtitle={`${completed.length} completed`}
            />
            {completed.length === 0 ? (
              <EmptyState icon="🏏" msg="No completed matches yet" />
            ) : (
              (() => {
                const groups = new Map<string, Match[]>();
                for (const m of [...completed].reverse()) {
                  const key = m.groupName ?? m.round ?? "Results";
                  if (!groups.has(key)) groups.set(key, []);
                  groups.get(key)!.push(m);
                }
                const hasMultipleGroups = groups.size > 1;
                return (
                  <div className="space-y-6">
                    {Array.from(groups.entries()).map(
                      ([groupName, gMatches]) => (
                        <div key={groupName}>
                          {hasMultipleGroups && (
                            <div className="flex items-center gap-3 mb-3">
                              <span className="text-[10px] font-bold uppercase tracking-[0.18em] text-[#CCFF00] bg-[#CCFF00]/10 px-3 py-1 rounded-full border border-[#CCFF00]/15">
                                {groupName}
                              </span>
                              <span className="text-xs text-white/25">
                                {gMatches.length} match
                                {gMatches.length !== 1 ? "es" : ""}
                              </span>
                            </div>
                          )}
                          <ResultsTable
                            matches={gMatches}
                            teamBrandMap={teamBrandMap}
                          />
                        </div>
                      ),
                    )}
                  </div>
                );
              })()
            )}
          </div>
        )}

        {active === "standings" && (
          <div>
            <SectionLabel
              title="Points Table"
              subtitle="Updated after each match"
            />
            {isGroupKO ? (
              <GroupedStandingsTables
                standings={standings}
                teamBrandMap={teamBrandMap}
              />
            ) : (
              <StandingsTable
                standings={standings}
                teamBrandMap={teamBrandMap}
              />
            )}
            {standings.length > 0 && (
              <div className="mt-4 flex flex-wrap gap-4 px-1">
                <div className="flex items-center gap-1.5">
                  <div className="w-2.5 h-2.5 rounded-sm bg-amber-300/15 border border-amber-300/25" />
                  <span className="text-[10px] text-white/35">Top seed</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <div className="w-2.5 h-2.5 rounded-sm bg-[#CCFF00]/15 border border-[#CCFF00]/25" />
                  <span className="text-[10px] text-white/35">Qualifies</span>
                </div>
                <span className="text-[10px] text-white/25">
                  P=Played · W=Won · L=Lost · T=Tied · NR=No Result · NRR=Net
                  Run Rate
                </span>
              </div>
            )}
          </div>
        )}

        {active === "bracket" && (
          <div>
            <div className="flex items-center justify-between mb-4 gap-3 flex-wrap">
              <h3 className="text-xs font-bold uppercase tracking-[0.2em] text-white/30">
                Tournament Bracket
              </h3>

              <button
                onClick={() => {
                  const el = document.getElementById("bracket-print-area");
                  if (!el) return;
                  const win = window.open(
                    "",
                    "_blank",
                    "width=1200,height=800",
                  );
                  if (!win) return;
                  win.document.write(`<!DOCTYPE html><html><head>
                    <title>${tournament.name} — Bracket</title>
                    <meta charset="utf-8"/>
                    <style>
                      *{box-sizing:border-box;margin:0;padding:0}
                      body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;background:#0b1016;padding:24px;color:#fff}
                      @page{size:landscape;margin:10mm}
                      h1{font-size:16px;font-weight:700;margin-bottom:4px;color:#fff}
                      p.sub{font-size:11px;color:rgba(255,255,255,0.55);margin-bottom:20px}
                      .flex{display:flex}.flex-col{flex-direction:column}.flex-1{flex:1}
                      .items-center{align-items:center}.items-start{align-items:flex-start}
                      .items-stretch{align-items:stretch}.justify-around{justify-content:space-around}
                      .justify-center{justify-content:center}.gap-4{gap:16px}.gap-3{gap:12px}.gap-2{gap:8px}
                      .shrink-0{flex-shrink:0}.min-w-0{min-width:0}.overflow-x-auto{overflow-x:auto}
                      .min-w-fit{min-width:fit-content}.space-y-6>*+*{margin-top:24px}
                      .w-full{width:100%}.h-full{height:100%}.h-1\\/2{height:50%}
                      .min-w-\\[220px\\]{min-width:220px}.w-8{width:32px}.w-6{width:24px}.h-6{height:24px}
                      .h-24{height:96px}.w-\\[190px\\]{width:190px}
                      .px-2{padding-left:8px;padding-right:8px}.px-3{padding-left:12px;padding-right:12px}
                      .px-4{padding-left:16px;padding-right:16px}.px-6{padding-left:24px;padding-right:24px}
                      .py-2{padding-top:8px;padding-bottom:8px}.py-3{padding-top:12px;padding-bottom:12px}
                      .py-4{padding-top:16px;padding-bottom:16px}.py-1{padding-top:4px;padding-bottom:4px}
                      .ml-6{margin-left:24px}.ml-8{margin-left:32px}.mx-2{margin-left:8px;margin-right:8px}
                      .mx-3{margin-left:12px;margin-right:12px}.mb-2{margin-bottom:8px}.mb-5{margin-bottom:20px}
                      .mt-10{margin-top:40px}
                      .text-xs{font-size:12px}.text-sm{font-size:14px}.text-3xl{font-size:30px}.text-4xl{font-size:36px}
                      .text-\\[10px\\]{font-size:10px}.text-\\[9px\\]{font-size:9px}
                      .font-bold{font-weight:700}.font-semibold{font-weight:600}.font-medium{font-weight:500}.font-black{font-weight:800}
                      .uppercase{text-transform:uppercase}.tracking-\\[0\\.18em\\]{letter-spacing:.18em}.tracking-\\[0\\.2em\\]{letter-spacing:.2em}
                      .truncate{overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
                      .text-center{text-align:center}.leading-tight{line-height:1.25}
                      .text-white{color:#fff}.text-white\\/55{color:rgba(255,255,255,.55)}.text-white\\/35{color:rgba(255,255,255,.35)}
                      .text-\\[\\#CCFF00\\]{color:#CCFF00}.text-amber-100{color:#fef3c7}.text-amber-300{color:#fcd34d}
                      .bg-white\\/\\[0\\.04\\]{background:rgba(255,255,255,.04)}.bg-white\\/\\[0\\.05\\]{background:rgba(255,255,255,.05)}
                      .bg-\\[\\#CCFF00\\]\\/10{background:rgba(204,255,0,.10)}.bg-\\[\\#CCFF00\\]\\/15{background:rgba(204,255,0,.15)}
                      .bg-amber-300\\/10{background:rgba(252,211,77,.10)}
                      .border{border-width:1px;border-style:solid}.border-b{border-bottom-width:1px;border-bottom-style:solid}
                      .border-t{border-top-width:1px;border-top-style:solid}.border-r{border-right-width:1px;border-right-style:solid}.border-l{border-left-width:1px;border-left-style:solid}
                      .border-white\\/10{border-color:rgba(255,255,255,.10)}.border-white\\/8{border-color:rgba(255,255,255,.08)}.border-white\\/15{border-color:rgba(255,255,255,.15)}.border-white\\/12{border-color:rgba(255,255,255,.12)}
                      .border-\\[\\#CCFF00\\]\\/15{border-color:rgba(204,255,0,.15)}.border-\\[\\#CCFF00\\]\\/20{border-color:rgba(204,255,0,.20)}
                      .border-amber-300\\/20{border-color:rgba(252,211,77,.20)}
                      .border-dashed{border-style:dashed}
                      .rounded-lg{border-radius:12px}.rounded-2xl{border-radius:16px}.rounded-\\[20px\\]{border-radius:20px}
                      .rounded-full{border-radius:9999px}
                      .overflow-hidden{overflow:hidden}.relative{position:relative}
                      .max-w-\\[100px\\]{max-width:100px}
                      .bg-gradient-to-b{background-image:linear-gradient(to bottom, rgba(252,211,77,.12), rgba(253,186,116,.10))}
                    </style>
                  </head><body>
                    <h1>${tournament.name}</h1>
                    <p class="sub">Tournament Bracket · Swing Cricket</p>
                    ${el.innerHTML}
                  </body></html>`);
                  win.document.close();
                  win.onload = () => {
                    win.focus();
                    win.print();
                  };
                }}
                className="flex items-center gap-2 text-xs font-semibold text-white/60 hover:text-white bg-white/[0.04] border border-white/10 hover:bg-white/[0.06] px-3 py-2 rounded-xl transition-all"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  className="w-3.5 h-3.5"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                >
                  <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
                  <polyline points="7 10 12 15 17 10" />
                  <line x1="12" y1="15" x2="12" y2="3" />
                </svg>
                Download PDF
              </button>
            </div>

            <div id="bracket-print-area" className={cx(PANEL, "p-4 md:p-6")}>
              {isGroupKO ? (
                <FullBracketView
                  matches={matches}
                  teamBrandMap={teamBrandMap}
                />
              ) : (
                <Bracket matches={matches} teamBrandMap={teamBrandMap} />
              )}
            </div>
          </div>
        )}

        {active === "highlights" && (
          <div>
            <SectionLabel
              title="Highlights"
              subtitle={
                highlights.length > 0
                  ? `${highlights.length} videos`
                  : undefined
              }
            />
            <HighlightsGrid highlights={highlights} />
          </div>
        )}

        {active === "teams" && (
          <div>
            <SectionLabel
              title="Participating Teams"
              subtitle={`${tournament.teams?.length ?? 0} registered`}
            />
            <TeamsGrid teams={tournament.teams ?? []} />
          </div>
        )}
      </div>

      {/* FOOTER */}
      <div className="border-t border-white/8 py-10 mt-8">
        <div className="max-w-6xl mx-auto px-4 md:px-8 text-center">
          <p className="text-xs text-white/20">
            Powered by{" "}
            <span className="text-white/50 font-semibold">Swing Cricket</span>
          </p>
        </div>
      </div>
    </div>
  );
}
