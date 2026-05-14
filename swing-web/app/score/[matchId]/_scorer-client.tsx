"use client";

import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import {
  clearScorerSession,
  readScorerSession,
  scorerFetch,
} from "../_session";
import { WagonWheel, ZONE_LABEL, type WagonZone } from "./_wagon-wheel";

// ── Cold-start retry helpers ──────────────────────────────────────────────
// Cloud Run cold starts surface as either a network error or a transient
// 5xx (502/503/504). Mutations get wrapped to retry through a delay schedule
// before bubbling failure. 4xx is always caller error → no retry.

function sleep(ms: number): Promise<void> {
  return new Promise((r) => setTimeout(r, ms));
}

function isTransient5xx(status: number): boolean {
  return status === 502 || status === 503 || status === 504;
}

async function withColdStartRetry(
  fn: () => Promise<Response>,
  delays: number[],
): Promise<Response> {
  let lastErr: unknown = null;
  for (let attempt = 0; attempt <= delays.length; attempt++) {
    try {
      const res = await fn();
      if (res.ok || !isTransient5xx(res.status)) return res;
      // Transient 5xx → retry if we have delays left, else return the
      // response so caller can read the body for its error message.
      if (attempt === delays.length) return res;
      await sleep(delays[attempt]);
      continue;
    } catch (e) {
      lastErr = e;
      if (attempt === delays.length) throw e;
      await sleep(delays[attempt]);
    }
  }
  // Unreachable — the loop either returns or throws.
  throw lastErr ?? new Error("retry exhausted");
}

const MUTATION_RETRY_DELAYS = [5000, 10000, 15000];
const INITIAL_LOAD_RETRY_DELAYS = [800, 1500, 2500, 4000];

// 401 is a fatal auth issue — distinguish from transient errors so the
// initial-load retry can bail out instead of retrying.
class AuthError extends Error {}

// React port of the Flutter scoring screen — same layout, same flows:
// score strip → over dots → batter rows → bowler row → wagon wheel →
// pad rows (Dot/Wide/NoBall/Overthrow + Bye/LegBye/Wicket/Undo). Tap a
// wheel zone to open the run picker (1–6 with that wagonZone set on
// the ball). All extras and wicket flows open modal pickers matching
// the Flutter sheets.

// ── Types (loose — we only project the fields we read) ────────────────────
type Player = { profileId: string; name: string; isOut?: boolean };
type Team = {
  id: string | null;
  name: string;
  players: Player[];
  shortName?: string | null;
};
type BallEvent = {
  id: string;
  overNumber: number;
  ballNumber: number;
  outcome: string;
  runs: number;
  extras: number;
  isWicket: boolean;
  batterId?: string | null;
  nonBatterId?: string | null;
  bowlerId?: string | null;
  dismissedPlayerId?: string | null;
  dismissalType?: string | null;
  fielderId?: string | null;
  wagonZone?: string | null;
  isOverthrow?: boolean;
  overthrowRuns?: number;
  tags?: string[];
};
type Innings = {
  id: string;
  inningsNumber: number;
  battingTeam: string;
  totalRuns: number;
  totalWickets: number;
  totalOvers: number;
  isCompleted: boolean;
  isFreeHit?: boolean;
  penaltyRuns?: number;
  effectiveTotalRuns?: number;
  currentStrikerId: string | null;
  currentNonStrikerId: string | null;
  currentBowlerId: string | null;
  ballEvents: BallEvent[];
};
type PenaltyAward = {
  id: string;
  awardedTo: string;
  runs: number;
  reason?: string | null;
  scoredAt: string;
};
type MatchPayload = {
  id: string;
  status: string;
  format: string;
  teamAName: string;
  teamBName: string;
  customOvers?: number | null;
  innings: Innings[];
  penaltyAwards?: PenaltyAward[];
  tossWonBy?: string | null;
  tossDecision?: string | null;
  teamAWicketKeeperId?: string | null;
  teamBWicketKeeperId?: string | null;
};
type PlayersPayload = { teamA: Team; teamB: Team };

const LEGAL_OUTCOMES = new Set([
  "DOT",
  "SINGLE",
  "DOUBLE",
  "TRIPLE",
  "FOUR",
  "FIVE",
  "SIX",
  "WICKET",
  "BYE",
  "LEG_BYE",
]);

function isLegal(outcome: string): boolean {
  return LEGAL_OUTCOMES.has(outcome);
}

function maxOversOf(match: MatchPayload): number {
  if (match.customOvers && match.customOvers > 0) return match.customOvers;
  switch (match.format) {
    case "T10":
      return 10;
    case "T20":
      return 20;
    case "ODI":
      return 50;
    case "TEST":
      return 90;
    default:
      return 20;
  }
}

// Per-batter aggregates computed from ball events. Mirrors how the
// Flutter scorer derives in-screen stats.
function batterStats(events: BallEvent[], profileId: string) {
  let runs = 0;
  let balls = 0;
  let fours = 0;
  let sixes = 0;
  for (const b of events) {
    if (b.batterId !== profileId) continue;
    if (isLegal(b.outcome) || b.outcome === "NO_BALL") {
      runs += b.runs;
      if (b.outcome !== "BYE" && b.outcome !== "LEG_BYE") {
        // BYE / LEG_BYE runs go to the team but not the batter
      }
    }
    if (b.outcome !== "WIDE") balls += 1; // wides don't count as faced
    if (b.outcome === "FOUR") fours += 1;
    if (b.outcome === "SIX") sixes += 1;
  }
  const sr = balls > 0 ? (runs * 100) / balls : 0;
  return { runs, balls, fours, sixes, sr };
}

function bowlerStats(events: BallEvent[], profileId: string) {
  let legalBalls = 0;
  let runs = 0;
  let wickets = 0;
  for (const b of events) {
    if (b.bowlerId !== profileId) continue;
    if (isLegal(b.outcome)) legalBalls += 1;
    // Runs conceded: bat runs + extras (incl. wides + no-balls)
    runs += b.runs + b.extras;
    if (b.isWicket && b.outcome === "WICKET") {
      // Run-outs aren't credited to bowler — Flutter rule
      if (b.dismissalType !== "RUN_OUT" && b.dismissalType !== "RETIRED_HURT" && b.dismissalType !== "RETIRED_OUT") {
        wickets += 1;
      }
    }
  }
  const oversWhole = Math.floor(legalBalls / 6);
  const oversFrac = legalBalls % 6;
  const overs = oversFrac === 0 ? `${oversWhole}` : `${oversWhole}.${oversFrac}`;
  const econOversBase = legalBalls / 6;
  const economy = econOversBase > 0 ? (runs / econOversBase).toFixed(2) : "—";
  return { legalBalls, runs, wickets, overs, economy };
}

// ── Component ──────────────────────────────────────────────────────────────
export default function ScorerClient({ matchId }: { matchId: string }) {
  const router = useRouter();
  const [match, setMatch] = useState<MatchPayload | null>(null);
  const [players, setPlayers] = useState<PlayersPayload | null>(null);
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [zone, setZone] = useState<WagonZone | null>(null);

  // Modal state — only one open at a time.
  type PickRole = "striker" | "nonStriker" | "bowler" | "wk";
  type Modal =
    | { kind: "runs"; zone: WagonZone | null }
    | { kind: "wide" }
    | { kind: "noball" }
    | { kind: "bye" }
    | { kind: "legbye" }
    | { kind: "overthrow"; batsmanRuns: number }
    | { kind: "wicket" }
    | { kind: "new-batter" }
    | { kind: "penalty" }
    | { kind: "end-match" }
    | { kind: "pick"; role: PickRole }
    | { kind: "declare" }
    | null;
  const [modal, setModal] = useState<Modal>(null);
  const [menuOpen, setMenuOpen] = useState(false);

  // Score-change pulse: when effectiveTotalRuns increases after a ball
  // record, we briefly render a "+N" indicator floating up out of the
  // score and flash the score number green so the scorer gets visual
  // confirmation the server accepted the ball.
  const lastEffectiveRef = useRef<number | null>(null);
  const [scorePulse, setScorePulse] = useState<{
    delta: number;
    nonce: number;
  } | null>(null);

  // ── Data ─────────────────────────────────────────────────────────────────
  const refresh = useCallback(async () => {
    const [mRes, pRes] = await Promise.all([
      scorerFetch(`/match/${matchId}`),
      scorerFetch(`/match/${matchId}/players`),
    ]);
    if (mRes.status === 401 || pRes.status === 401) {
      throw new AuthError("unauthorized");
    }
    const mBody = await mRes.json().catch(() => ({}));
    const pBody = await pRes.json().catch(() => ({}));
    if (!mRes.ok || !mBody?.success) {
      const err = new Error(mBody?.error?.message ?? "Failed to load match");
      // Tag with status so caller can decide whether to retry.
      (err as Error & { status?: number }).status = mRes.status;
      throw err;
    }
    if (!pRes.ok || !pBody?.success) {
      const err = new Error(pBody?.error?.message ?? "Failed to load players");
      (err as Error & { status?: number }).status = pRes.status;
      throw err;
    }
    setMatch(mBody.data as MatchPayload);
    setPlayers(pBody.data as PlayersPayload);
  }, [matchId]);

  useEffect(() => {
    const s = readScorerSession();
    if (!s || s.matchId !== matchId) {
      router.replace("/score");
      return;
    }
    let cancelled = false;
    (async () => {
      setLoading(true);
      setError(null);
      const delays = INITIAL_LOAD_RETRY_DELAYS;
      let lastErr: Error | null = null;
      for (let attempt = 0; attempt <= delays.length; attempt++) {
        if (cancelled) return;
        try {
          await refresh();
          if (!cancelled) setLoading(false);
          return;
        } catch (e) {
          if (e instanceof AuthError) {
            clearScorerSession();
            router.replace("/score");
            return;
          }
          lastErr = e as Error;
          const status = (e as Error & { status?: number }).status;
          // Only retry on transient 5xx or network errors (no status).
          const retriable = status === undefined || isTransient5xx(status);
          if (!retriable || attempt === delays.length) break;
          await sleep(delays[attempt]);
        }
      }
      if (!cancelled) {
        setError(lastErr?.message ?? "Failed to load");
        setLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [matchId, refresh, router]);

  function onSignOut() {
    clearScorerSession();
    router.replace("/score");
  }

  // ── Derived state ────────────────────────────────────────────────────────
  const activeInnings = useMemo<Innings | null>(() => {
    if (!match) return null;
    return (
      match.innings.find((i) => !i.isCompleted) ??
      match.innings[match.innings.length - 1] ??
      null
    );
  }, [match]);

  const battingTeam = useMemo<Team | null>(() => {
    if (!players || !activeInnings) return null;
    return activeInnings.battingTeam === "A" ? players.teamA : players.teamB;
  }, [players, activeInnings]);

  const bowlingTeam = useMemo<Team | null>(() => {
    if (!players || !activeInnings) return null;
    return activeInnings.battingTeam === "A" ? players.teamB : players.teamA;
  }, [players, activeInnings]);

  const nameOf = useCallback(
    (id: string | null | undefined): string => {
      if (!id || !players) return "—";
      const all = [...players.teamA.players, ...players.teamB.players];
      return all.find((p) => p.profileId === id)?.name ?? "—";
    },
    [players],
  );

  const { nextOver, nextBall, currentOverBalls, lastBall } = useMemo(() => {
    if (!activeInnings)
      return { nextOver: 0, nextBall: 1, currentOverBalls: [] as BallEvent[], lastBall: null as BallEvent | null };
    const events = activeInnings.ballEvents ?? [];
    if (events.length === 0)
      return { nextOver: 0, nextBall: 1, currentOverBalls: [], lastBall: null };
    const last = events[events.length - 1];
    const lastOver = events.reduce((m, e) => Math.max(m, e.overNumber), 0);
    const inThisOver = events.filter((e) => e.overNumber === lastOver);
    const legalInThisOver = inThisOver.filter((e) => isLegal(e.outcome)).length;
    if (legalInThisOver >= 6) {
      // Over just completed — next ball belongs to a new over.
      return {
        nextOver: lastOver + 1,
        nextBall: 1,
        currentOverBalls: inThisOver,
        lastBall: last,
      };
    }
    return {
      nextOver: lastOver,
      nextBall: legalInThisOver + 1,
      currentOverBalls: inThisOver,
      lastBall: last,
    };
  }, [activeInnings]);

  // Keep lastBall reachable from inside async mutation flows (overthrow).
  useEffect(() => {
    lastBallRef.current = lastBall;
  }, [lastBall]);

  // Score pulse: fire whenever the batting team's effective total changes.
  // Skips the initial mount so we don't pulse just because the match
  // loaded. Negative delta still pulses — useful when a penalty subtract
  // or an undo lands.
  useEffect(() => {
    const current = activeInnings?.effectiveTotalRuns ?? activeInnings?.totalRuns ?? null;
    const prev = lastEffectiveRef.current;
    if (current !== null && prev !== null && current !== prev) {
      setScorePulse({ delta: current - prev, nonce: Date.now() });
    }
    if (current !== null) lastEffectiveRef.current = current;
  }, [activeInnings?.effectiveTotalRuns, activeInnings?.totalRuns]);

  // Auto-clear the pulse after the animation finishes.
  useEffect(() => {
    if (!scorePulse) return;
    const t = setTimeout(() => setScorePulse(null), 1400);
    return () => clearTimeout(t);
  }, [scorePulse]);

  // Three mutually-exclusive "needs input" states. Backend clears slots
  // at specific moments (end of over → bowler null; after wicket →
  // striker or non-striker null; brand-new innings → all three null).
  // Order matters: pick new batter before the bowler if both are
  // required, because the bowler will be facing them.
  const hasEvents = (activeInnings?.ballEvents?.length ?? 0) > 0;
  const sidMissing = !activeInnings?.currentStrikerId;
  const nsidMissing = !activeInnings?.currentNonStrikerId;
  const bidMissing = !activeInnings?.currentBowlerId;
  const isOpeningSetup =
    !!activeInnings && !hasEvents && (sidMissing || nsidMissing || bidMissing);
  const needsNewBatter =
    !!activeInnings && hasEvents && (sidMissing || nsidMissing);
  const needsNewBowler =
    !!activeInnings && hasEvents && !needsNewBatter && bidMissing;

  // ── Mutations ────────────────────────────────────────────────────────────
  // Track the latest lastBall in a ref so the overthrow handler can read it
  // mid-flow (between undo and re-record) without racing React state.
  const lastBallRef = useRef<BallEvent | null>(null);

  function doFetch(
    path: string,
    method: string,
    body?: unknown,
  ): Promise<Response> {
    const serialised =
      body === undefined
        ? undefined
        : typeof body === "string"
          ? body
          : JSON.stringify(body);
    return scorerFetch(path, { method, body: serialised });
  }

  async function readError(res: Response): Promise<{ message: string; code: string | null }> {
    const data = await res.json().catch(() => ({}));
    return {
      message: data?.error?.message ?? "Action failed",
      code: (data?.error?.code as string | undefined) ?? null,
    };
  }

  async function call(
    path: string,
    init: { method: string; body?: unknown },
  ): Promise<void> {
    setBusy(true);
    setError(null);
    try {
      const res = await withColdStartRetry(
        () => doFetch(path, init.method, init.body),
        MUTATION_RETRY_DELAYS,
      );
      const data = await res.json().catch(() => ({}));
      if (!res.ok || !data?.success) {
        throw new Error(data?.error?.message ?? "Action failed");
      }
      await refresh();
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setBusy(false);
    }
  }

  function ballPayload(extra: Record<string, unknown> = {}) {
    if (!activeInnings) return null;
    const sid = activeInnings.currentStrikerId;
    const bid = activeInnings.currentBowlerId;
    if (!sid || !bid) return null;
    return {
      overNumber: nextOver,
      ballNumber: nextBall,
      batterId: sid,
      bowlerId: bid,
      runs: 0,
      extras: 0,
      isWicket: false,
      ...(zone ? { wagonZone: zone } : {}),
      ...extra,
    };
  }

  // Low-level ball POST with retry + INNINGS_COMPLETED auto-recovery.
  // Returns the final response (which the caller should validate). On
  // INNINGS_COMPLETED 4xx, reopens the innings and retries once. Match
  // Flutter scoring_controller.dart:551-562.
  async function postBallWithRecover(
    inningsNumber: number,
    payload: unknown,
  ): Promise<Response> {
    const path = `/match/${matchId}/innings/${inningsNumber}/ball`;
    const first = await withColdStartRetry(
      () => doFetch(path, "POST", payload),
      MUTATION_RETRY_DELAYS,
    );
    if (first.ok) return first;
    // Clone before reading body so the caller can read it again if we don't
    // recover.
    const clone = first.clone();
    if (first.status < 500) {
      const { code } = await readError(clone);
      if (code === "INNINGS_COMPLETED") {
        try {
          await withColdStartRetry(
            () =>
              doFetch(
                `/match/${matchId}/innings/${inningsNumber}/reopen`,
                "POST",
              ),
            MUTATION_RETRY_DELAYS,
          );
        } catch {
          return first; // reopen failed → surface original error
        }
        const retry = await withColdStartRetry(
          () => doFetch(path, "POST", payload),
          MUTATION_RETRY_DELAYS,
        );
        // If retry still fails, surface the ORIGINAL error (per spec).
        return retry.ok ? retry : first;
      }
    }
    return first;
  }

  async function recordBall(extra: Record<string, unknown>) {
    if (!activeInnings) return;
    const payload = ballPayload(extra);
    if (!payload) return;
    setBusy(true);
    setError(null);
    try {
      const res = await postBallWithRecover(
        activeInnings.inningsNumber,
        payload,
      );
      const data = await res.json().catch(() => ({}));
      if (!res.ok || !data?.success) {
        throw new Error(data?.error?.message ?? "Action failed");
      }
      await refresh();
      setZone(null);
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setBusy(false);
    }
  }

  async function undo() {
    if (!activeInnings) return;
    setBusy(true);
    setError(null);
    try {
      const res = await withColdStartRetry(
        () =>
          doFetch(
            `/match/${matchId}/innings/${activeInnings.inningsNumber}/last-ball`,
            "DELETE",
          ),
        MUTATION_RETRY_DELAYS,
      );
      const data = await res.json().catch(() => ({}));
      if (!res.ok || !data?.success) {
        throw new Error(data?.error?.message ?? "Action failed");
      }
      // If the innings/match was marked complete and the user is backing out
      // of it, reopen so subsequent scoring isn't blocked by the backend's
      // isCompleted gate. Match Flutter scoring_controller.dart:686-723.
      const wasInningsCompleted = activeInnings.isCompleted === true;
      const hadEvents = (activeInnings.ballEvents?.length ?? 0) > 0;
      if (wasInningsCompleted && hadEvents) {
        try {
          await withColdStartRetry(
            () =>
              doFetch(
                `/match/${matchId}/innings/${activeInnings.inningsNumber}/reopen`,
                "POST",
              ),
            MUTATION_RETRY_DELAYS,
          );
        } catch {
          // Continue — refresh will surface state regardless.
        }
      }
      await refresh();
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setBusy(false);
    }
  }

  async function setInningsState(s: {
    strikerId?: string | null;
    nonStrikerId?: string | null;
    bowlerId?: string | null;
  }) {
    if (!activeInnings) return;
    await call(
      `/match/${matchId}/innings/${activeInnings.inningsNumber}/state`,
      { method: "PATCH", body: s },
    );
  }

  async function reopenInnings(inningsNumber: number) {
    await call(`/match/${matchId}/innings/${inningsNumber}/reopen`, {
      method: "POST",
    });
  }

  async function completeMatch(
    winnerId: "A" | "B" | "TIE" | "DRAW" | "ABANDONED",
    winMargin?: string,
  ) {
    await call(`/match/${matchId}/complete`, {
      method: "POST",
      body: { winnerId, ...(winMargin ? { winMargin } : {}) },
    });
  }

  async function completeInnings(inningsNumber: number) {
    await call(`/match/${matchId}/innings/${inningsNumber}/complete`, {
      method: "POST",
    });
  }

  async function changeWicketKeeper(team: "A" | "B", wkId: string) {
    await call(`/match/${matchId}/wicketkeeper`, {
      method: "PATCH",
      body: { team, wicketKeeperId: wkId },
    });
  }

  // ── Side-drawer menu actions ─────────────────────────────────────────────
  function onMenuChangeStriker() {
    setMenuOpen(false);
    setModal({ kind: "pick", role: "striker" });
  }
  function onMenuChangeNonStriker() {
    setMenuOpen(false);
    setModal({ kind: "pick", role: "nonStriker" });
  }
  function onMenuSwapBatters() {
    setMenuOpen(false);
    if (!activeInnings) return;
    const s = activeInnings.currentStrikerId;
    const ns = activeInnings.currentNonStrikerId;
    if (!s || !ns) return;
    void setInningsState({ strikerId: ns, nonStrikerId: s });
  }
  function onMenuChangeBowler() {
    setMenuOpen(false);
    setModal({ kind: "pick", role: "bowler" });
  }
  function onMenuChangeWicketKeeper() {
    setMenuOpen(false);
    setModal({ kind: "pick", role: "wk" });
  }
  function onMenuDeclareInnings() {
    setMenuOpen(false);
    setModal({ kind: "declare" });
  }
  async function onMenuRefresh() {
    setMenuOpen(false);
    setError(null);
    try {
      await refresh();
    } catch (e) {
      setError((e as Error).message);
    }
  }

  // Picker submit dispatcher — routes the selected player to the right
  // backend call based on which role we're picking for.
  async function onPickPlayer(role: PickRole, playerId: string) {
    setModal(null);
    if (role === "striker") {
      await setInningsState({ strikerId: playerId });
    } else if (role === "nonStriker") {
      await setInningsState({ nonStrikerId: playerId });
    } else if (role === "bowler") {
      await setInningsState({ bowlerId: playerId });
    } else if (role === "wk") {
      if (!activeInnings) return;
      // The wicket-keeper is on the BOWLING team. innings.battingTeam tells
      // us which is batting; the WK belongs to the other side.
      const team: "A" | "B" =
        activeInnings.battingTeam === "A" ? "B" : "A";
      await changeWicketKeeper(team, playerId);
    }
  }

  // ── Pad actions ──────────────────────────────────────────────────────────
  const onDot = () => recordBall({ outcome: "DOT", runs: 0 });
  const onWide = () => setModal({ kind: "wide" });
  const onNoBall = () => setModal({ kind: "noball" });
  const onBye = () => setModal({ kind: "bye" });
  const onLegBye = () => setModal({ kind: "legbye" });
  const onWicket = () => setModal({ kind: "wicket" });
  const onOverthrow = () => {
    if (!lastBall) return;
    setModal({ kind: "overthrow", batsmanRuns: lastBall.runs });
  };
  const onWheelZoneTap = (z: WagonZone) => {
    const next = zone === z ? null : z;
    setZone(next);
    if (next) setModal({ kind: "runs", zone: next });
  };
  const onRunPick = (runs: number) => {
    setModal(null);
    const map: Record<number, string> = {
      1: "SINGLE",
      2: "DOUBLE",
      3: "TRIPLE",
      4: "FOUR",
      5: "FIVE",
      6: "SIX",
    };
    void recordBall({ outcome: map[runs] ?? "DOT", runs });
  };
  const onWidePick = (extraRuns: number) => {
    setModal(null);
    void recordBall({ outcome: "WIDE", runs: 0, extras: 1 + extraRuns });
  };
  const onNoBallPick = (kind: "BAT" | "BYE" | "LEG_BYE", count: number) => {
    setModal(null);
    const runs = kind === "BAT" ? count : 0;
    const extras = kind === "BAT" ? 1 : 1 + count;
    const tags = kind === "BAT" ? [] : [`no_ball_extra:${kind.toLowerCase()}:${count}`];
    void recordBall({ outcome: "NO_BALL", runs, extras, tags });
  };
  const onByePick = (n: number) => {
    setModal(null);
    void recordBall({ outcome: "BYE", runs: 0, extras: n });
  };
  const onLegByePick = (n: number) => {
    setModal(null);
    void recordBall({ outcome: "LEG_BYE", runs: 0, extras: n });
  };
  const onWicketPick = async (data: {
    dismissalType: string;
    deliveryType: "LEGAL" | "WIDE" | "NO_BALL";
    dismissedPlayerId: string;
    fielderId?: string | null;
    substituteFielderName?: string | null;
    completedRuns: number;
  }) => {
    setModal(null);
    const outcome =
      data.deliveryType === "WIDE"
        ? "WIDE"
        : data.deliveryType === "NO_BALL"
          ? "NO_BALL"
          : "WICKET";
    const extras = data.deliveryType === "LEGAL" ? 0 : 1;
    const tags = data.substituteFielderName
      ? [`substitute_fielder:${data.substituteFielderName}`]
      : [];
    await recordBall({
      outcome,
      runs: data.completedRuns,
      extras,
      isWicket: data.dismissalType !== "RETIRED_HURT",
      dismissalType: data.dismissalType,
      dismissedPlayerId: data.dismissedPlayerId,
      ...(data.fielderId ? { fielderId: data.fielderId } : {}),
      ...(tags.length ? { tags } : {}),
    });
  };
  const onPenaltyPick = async (data: {
    awardedTo: "A" | "B";
    runs: number;
    direction: "ADD" | "SUBTRACT";
    reason?: string;
  }) => {
    setModal(null);
    await call(`/match/${matchId}/penalty`, {
      method: "POST",
      body: {
        awardedTo: data.awardedTo,
        runs: data.runs,
        direction: data.direction,
        reason: data.reason || undefined,
        inningsNumber: activeInnings?.inningsNumber,
      },
    });
  };

  // Separate from undo-last-ball: removes the most recent PenaltyAward.
  // Useful when the scorer mis-picked the side or amount.
  const onUndoLastPenalty = async () => {
    await call(`/match/${matchId}/penalty/last`, { method: "DELETE" });
  };

  // Overthrow flow: backend doesn't support "append to last ball" — to avoid
  // double-counting we have to (1) snapshot the original ball, (2) DELETE
  // last-ball, then (3) re-POST the SAME ball with total runs and
  // isOverthrow:true. We deliberately bypass the generic call() helper
  // because it refreshes between steps, which would wipe lastBall and corrupt
  // the snapshot. The user sees a brief busy state but no flash of the
  // intermediate "undone" score — refresh runs once at the end.
  // Matches Flutter `_addOverthrowToLastBall` (scoring_screen.dart:589-606).
  const onOverthrowPick = async (n: number) => {
    setModal(null);
    if (!activeInnings) return;
    const original = lastBallRef.current ?? lastBall;
    if (!original) return;

    // Snapshot BEFORE doing anything — undo would clear lastBall from state.
    const snapshot = {
      overNumber: original.overNumber,
      ballNumber: original.ballNumber,
      batterId: original.batterId ?? activeInnings.currentStrikerId,
      bowlerId: original.bowlerId ?? activeInnings.currentBowlerId,
      wagonZone: original.wagonZone ?? null,
      batsmanRuns: original.runs,
    };
    const total = snapshot.batsmanRuns + n;
    const outcomeMap: Record<number, string> = {
      0: "DOT",
      1: "SINGLE",
      2: "DOUBLE",
      3: "TRIPLE",
      4: "FOUR",
      5: "FIVE",
      6: "SIX",
    };
    const outcome = outcomeMap[Math.max(0, Math.min(6, total))] ?? "SINGLE";

    setBusy(true);
    setError(null);
    try {
      const undoRes = await withColdStartRetry(
        () =>
          doFetch(
            `/match/${matchId}/innings/${activeInnings.inningsNumber}/last-ball`,
            "DELETE",
          ),
        MUTATION_RETRY_DELAYS,
      );
      const undoData = await undoRes.json().catch(() => ({}));
      if (!undoRes.ok || !undoData?.success) {
        // Bail BEFORE re-recording — otherwise we'd add a fresh ball on top.
        throw new Error(undoData?.error?.message ?? "Undo failed");
      }

      const payload = {
        overNumber: snapshot.overNumber,
        ballNumber: snapshot.ballNumber,
        batterId: snapshot.batterId,
        bowlerId: snapshot.bowlerId,
        runs: total,
        extras: 0,
        isWicket: false,
        isOverthrow: true,
        overthrowRuns: n,
        outcome,
        ...(snapshot.wagonZone ? { wagonZone: snapshot.wagonZone } : {}),
      };
      const rec = await withColdStartRetry(
        () =>
          doFetch(
            `/match/${matchId}/innings/${activeInnings.inningsNumber}/ball`,
            "POST",
            payload,
          ),
        MUTATION_RETRY_DELAYS,
      );
      const recData = await rec.json().catch(() => ({}));
      if (!rec.ok || !recData?.success) {
        throw new Error(recData?.error?.message ?? "Re-record failed");
      }
      await refresh();
      setZone(null);
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setBusy(false);
    }
  };

  // ── Render ───────────────────────────────────────────────────────────────
  if (loading) return <Spinner />;
  if (error && !match)
    return (
      <ErrorState
        message={error}
        onRetry={() => window.location.reload()}
        onSignOut={onSignOut}
      />
    );
  if (!match || !players) return null;

  if (match.status === "SCHEDULED" || match.innings.length === 0) {
    return (
      <Shell match={match} onSignOut={onSignOut}>
        <InfoPanel>
          The match hasn&apos;t started yet. Start it from the host app, then
          come back here to score.
        </InfoPanel>
      </Shell>
    );
  }
  if (!activeInnings) {
    return (
      <Shell match={match} onSignOut={onSignOut}>
        <InfoPanel>Match completed.</InfoPanel>
      </Shell>
    );
  }
  if (activeInnings.isCompleted) {
    const teamName =
      activeInnings.battingTeam === "A" ? match.teamAName : match.teamBName;
    const effRuns = activeInnings.effectiveTotalRuns ?? activeInnings.totalRuns;
    return (
      <Shell match={match} onSignOut={onSignOut}>
        <InningsSummaryPanel
          teamName={teamName}
          runs={effRuns}
          wickets={activeInnings.totalWickets}
          overs={activeInnings.totalOvers}
          inningsNumber={activeInnings.inningsNumber}
          busy={busy}
          onEndMatch={() => setModal({ kind: "end-match" })}
          onContinue={() => void reopenInnings(activeInnings.inningsNumber)}
        />
        {error && <ErrorBanner message={error} />}
        {modal?.kind === "end-match" && (
          <EndMatchModal
            teamAName={match.teamAName}
            teamBName={match.teamBName}
            onCancel={() => setModal(null)}
            onConfirm={async (winnerId, winMargin) => {
              setModal(null);
              await completeMatch(winnerId, winMargin);
            }}
          />
        )}
      </Shell>
    );
  }

  // Opening setup — only when innings has no balls yet AND any slot is empty.
  // Mid-innings "missing slot" is handled by the dedicated pickers below
  // (so picking just the new bowler doesn't drop into the full setup view).
  if (isOpeningSetup) {
    return (
      <Shell match={match} onSignOut={onSignOut}>
        <SetupPanel
          batting={battingTeam}
          bowling={bowlingTeam}
          striker={activeInnings.currentStrikerId}
          nonStriker={activeInnings.currentNonStrikerId}
          bowler={activeInnings.currentBowlerId}
          busy={busy}
          onSubmit={(s) => setInningsState(s)}
        />
        {error && <ErrorBanner message={error} />}
      </Shell>
    );
  }

  // After-wicket new-batter picker
  if (needsNewBatter) {
    return (
      <Shell
        match={match}
        innings={activeInnings}
        maxOvers={maxOversOf(match)}
        nameOf={nameOf}
        nextOver={nextOver}
        nextBall={nextBall}
        onSignOut={onSignOut}
        onUndoLastPenalty={
          (match.penaltyAwards?.length ?? 0) > 0 ? onUndoLastPenalty : undefined
        }
      >
        <NewBatterPanel
          batting={battingTeam}
          excludeIds={[
            activeInnings.currentStrikerId,
            activeInnings.currentNonStrikerId,
            ...(activeInnings.ballEvents ?? [])
              .filter((b) => b.isWicket && b.dismissedPlayerId)
              .map((b) => b.dismissedPlayerId as string),
          ].filter(Boolean) as string[]}
          missing={
            !activeInnings.currentStrikerId
              ? "striker"
              : "nonStriker"
          }
          busy={busy}
          onPick={(id) =>
            setInningsState(
              !activeInnings.currentStrikerId
                ? { strikerId: id }
                : { nonStrikerId: id },
            )
          }
        />
        {error && <ErrorBanner message={error} />}
      </Shell>
    );
  }

  // End-of-over → pick next bowler
  if (needsNewBowler) {
    return (
      <Shell
        match={match}
        innings={activeInnings}
        maxOvers={maxOversOf(match)}
        nameOf={nameOf}
        nextOver={nextOver}
        nextBall={nextBall}
        onSignOut={onSignOut}
        onUndoLastPenalty={
          (match.penaltyAwards?.length ?? 0) > 0 ? onUndoLastPenalty : undefined
        }
      >
        <BowlerPicker
          bowling={bowlingTeam}
          excludeId={activeInnings.currentBowlerId}
          busy={busy}
          onPick={(b) => setInningsState({ bowlerId: b })}
        />
        {error && <ErrorBanner message={error} />}
      </Shell>
    );
  }

  // Main scoring view
  const events = activeInnings.ballEvents ?? [];
  const sid = activeInnings.currentStrikerId;
  const nsid = activeInnings.currentNonStrikerId;
  const bid = activeInnings.currentBowlerId;
  const sStats = batterStats(events, sid!);
  const nsStats = batterStats(events, nsid!);
  const bStats = bowlerStats(events, bid!);

  const maxOvers = maxOversOf(match);
  const firstInnings = match.innings.find((i) => i.inningsNumber === 1);
  const chase = (() => {
    if (
      activeInnings.inningsNumber !== 2 ||
      match.format === "TEST" ||
      !firstInnings
    ) {
      return null;
    }
    const firstEff =
      firstInnings.effectiveTotalRuns ?? firstInnings.totalRuns;
    const target = firstEff + 1;
    const currentEff =
      activeInnings.effectiveTotalRuns ?? activeInnings.totalRuns;
    const runsNeeded = target - currentEff;
    // totalOvers can be a float like 4.3 (4 overs and 3 legal balls). Convert
    // back to legal-ball count carefully: floor part × 6 + frac × 10 (rounded
    // to handle FP error from server math).
    const whole = Math.floor(activeInnings.totalOvers);
    const fracBalls = Math.round((activeInnings.totalOvers - whole) * 10);
    const legalBallsBowled = whole * 6 + fracBalls;
    const ballsLeft = maxOvers * 6 - legalBallsBowled;
    const rrr =
      ballsLeft > 0 && runsNeeded > 0 ? (runsNeeded / ballsLeft) * 6 : null;
    return { target, runsNeeded, ballsLeft, rrr };
  })();

  return (
    <Shell
      match={match}
      innings={activeInnings}
      maxOvers={maxOvers}
      nameOf={nameOf}
      nextOver={nextOver}
      nextBall={nextBall}
      onSignOut={onSignOut}
      onUndoLastPenalty={
        (match.penaltyAwards?.length ?? 0) > 0 ? onUndoLastPenalty : undefined
      }
      onOpenMenu={() => setMenuOpen(true)}
      scorePulse={scorePulse}
    >
      {chase &&
        (chase.runsNeeded <= 0 ? (
          <ChaseStrip text="Target reached — innings complete" />
        ) : (
          <ChaseStrip
            text={`Need ${chase.runsNeeded} from ${chase.ballsLeft} balls${
              chase.rrr !== null ? ` · RRR ${chase.rrr.toFixed(2)}` : ""
            }`}
          />
        ))}

      <OverDots balls={currentOverBalls} />

      <div className="bg-white rounded-xl border border-neutral-200 overflow-hidden">
        <BatterRow
          name={nameOf(sid)}
          stats={sStats}
          isStriker
        />
        <Divider />
        <BatterRow name={nameOf(nsid)} stats={nsStats} />
        <Divider />
        <BowlerRowView name={nameOf(bid)} stats={bStats} />
      </div>

      {activeInnings.isFreeHit === true && <FreeHitBanner />}

      <WagonWheel selectedZone={zone} onZoneTap={onWheelZoneTap} />
      <div className="text-center text-[11px] text-neutral-500 -mt-1">
        {zone ? ZONE_LABEL[zone] : "Tap wheel to score · स्कोरिंग के लिए टैप करें"}
      </div>

      <PadRows
        busy={busy}
        canUndo={events.length > 0}
        canOverthrow={!!lastBall}
        onDot={onDot}
        onWide={onWide}
        onNoBall={onNoBall}
        onOverthrow={onOverthrow}
        onBye={onBye}
        onLegBye={onLegBye}
        onWicket={onWicket}
        onPenalty={() => setModal({ kind: "penalty" })}
        onUndo={undo}
      />

      {error && <ErrorBanner message={error} />}

      {/* ── Modals ─────────────────────────────────────────────────────── */}
      {modal?.kind === "runs" && (
        <RunPickerModal
          zone={modal.zone}
          onCancel={() => setModal(null)}
          onPick={onRunPick}
          onPenalty={() => setModal({ kind: "penalty" })}
        />
      )}
      {modal?.kind === "penalty" && (
        <PenaltyModal
          teamAName={match.teamAName}
          teamBName={match.teamBName}
          battingTeamSide={activeInnings.battingTeam as "A" | "B"}
          onCancel={() => setModal(null)}
          onPick={onPenaltyPick}
        />
      )}
      {modal?.kind === "wide" && (
        <ExtraPickerModal
          title="Wide"
          subtitle="Extra runs off the wide (byes / boundary)"
          options={[0, 1, 2, 3, 4]}
          onCancel={() => setModal(null)}
          onPick={onWidePick}
        />
      )}
      {modal?.kind === "noball" && (
        <NoBallModal
          onCancel={() => setModal(null)}
          onPick={onNoBallPick}
        />
      )}
      {modal?.kind === "bye" && (
        <ExtraPickerModal
          title="Byes"
          subtitle="Runs scored as byes"
          options={[1, 2, 3, 4, 5]}
          onCancel={() => setModal(null)}
          onPick={onByePick}
        />
      )}
      {modal?.kind === "legbye" && (
        <ExtraPickerModal
          title="Leg Byes"
          subtitle="Runs scored off the pad"
          options={[1, 2, 3, 4, 5]}
          onCancel={() => setModal(null)}
          onPick={onLegByePick}
        />
      )}
      {modal?.kind === "overthrow" && (
        <ExtraPickerModal
          title="Overthrow"
          subtitle={`Last ball batsman: ${modal.batsmanRuns} • extra runs from overthrow`}
          options={[1, 2, 3, 4, 5]}
          onCancel={() => setModal(null)}
          onPick={onOverthrowPick}
        />
      )}
      {modal?.kind === "wicket" && (
        <WicketModal
          striker={{ id: sid!, name: nameOf(sid) }}
          nonStriker={{ id: nsid!, name: nameOf(nsid) }}
          fielders={bowlingTeam?.players ?? []}
          bowlerId={bid!}
          keeperId={
            activeInnings.battingTeam === "A"
              ? match.teamBWicketKeeperId ?? null
              : match.teamAWicketKeeperId ?? null
          }
          isFreeHit={activeInnings.isFreeHit ?? false}
          onCancel={() => setModal(null)}
          onPick={onWicketPick}
        />
      )}
      {modal?.kind === "pick" && (
        <PlayerPickerModal
          role={modal.role}
          battingTeam={battingTeam}
          bowlingTeam={bowlingTeam}
          activeInnings={activeInnings}
          currentKeeperId={
            activeInnings.battingTeam === "A"
              ? match.teamBWicketKeeperId ?? null
              : match.teamAWicketKeeperId ?? null
          }
          onCancel={() => setModal(null)}
          onPick={(id) => onPickPlayer(modal.role, id)}
        />
      )}
      {modal?.kind === "declare" && (
        <ConfirmModal
          title="Declare innings"
          body={
            activeInnings.inningsNumber === 1
              ? "End the current innings now (declared). Team will move to the chase / next innings."
              : "End the current innings now (declared)."
          }
          confirmLabel="Declare"
          danger
          onCancel={() => setModal(null)}
          onConfirm={async () => {
            setModal(null);
            await completeInnings(activeInnings.inningsNumber);
          }}
        />
      )}
      <MenuDrawer
        open={menuOpen}
        onClose={() => setMenuOpen(false)}
        actions={[
          { label: "Change striker", onClick: onMenuChangeStriker },
          { label: "Change non-striker", onClick: onMenuChangeNonStriker },
          { label: "Swap batters", onClick: onMenuSwapBatters },
          { label: "Change bowler", onClick: onMenuChangeBowler },
          {
            label: "Change wicket-keeper",
            onClick: onMenuChangeWicketKeeper,
          },
          { divider: true },
          {
            label: "Declare innings",
            onClick: onMenuDeclareInnings,
            danger: true,
          },
          { label: "Refresh", onClick: onMenuRefresh },
          { divider: true },
          { label: "Sign out", onClick: onSignOut },
        ]}
      />
    </Shell>
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-components
// ─────────────────────────────────────────────────────────────────────────────

function Spinner() {
  return (
    <main className="min-h-screen bg-neutral-50 flex items-center justify-center">
      <div className="text-sm text-neutral-600">Loading match…</div>
    </main>
  );
}

function Shell({
  match,
  innings,
  maxOvers,
  nameOf: _nameOf,
  nextOver,
  nextBall,
  onSignOut,
  onUndoLastPenalty,
  onOpenMenu,
  scorePulse,
  children,
}: {
  match: MatchPayload;
  innings?: Innings;
  maxOvers?: number;
  nameOf?: (id: string | null | undefined) => string;
  nextOver?: number;
  nextBall?: number;
  onSignOut: () => void;
  onUndoLastPenalty?: () => void;
  onOpenMenu?: () => void;
  scorePulse?: { delta: number; nonce: number } | null;
  children: React.ReactNode;
}) {
  return (
    <main className="min-h-screen bg-neutral-50 pb-12">
      <header className="bg-white border-b border-neutral-200 px-4 py-2 flex items-center justify-between sticky top-0 z-20">
        <div className="min-w-0">
          <div className="text-[10px] uppercase tracking-wide text-neutral-500 truncate">
            {match.format} · {match.status}
          </div>
          <div className="text-xs font-medium text-neutral-700 truncate">
            {match.teamAName} <span className="text-neutral-400">vs</span>{" "}
            {match.teamBName}
          </div>
        </div>
        <div className="flex items-center gap-3 shrink-0 ml-3">
          {onOpenMenu && (
            <button
              type="button"
              aria-label="Open scorer menu"
              onClick={onOpenMenu}
              className="w-9 h-9 flex items-center justify-center rounded-md border border-neutral-300 active:bg-neutral-100"
            >
              <svg
                width="18"
                height="18"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="2.4"
                strokeLinecap="round"
                aria-hidden
              >
                <path d="M3 6h18M3 12h18M3 18h18" />
              </svg>
            </button>
          )}
          <button
            onClick={onSignOut}
            className="text-[11px] text-neutral-600 underline"
          >
            Sign out
          </button>
        </div>
      </header>

      {innings && (
        <ScoreStrip
          match={match}
          innings={innings}
          maxOvers={maxOvers ?? 20}
          nextOver={nextOver ?? 0}
          nextBall={nextBall ?? 1}
          onUndoLastPenalty={onUndoLastPenalty}
          scorePulse={scorePulse ?? null}
        />
      )}

      <div className="px-3 pt-3 space-y-3">{children}</div>
    </main>
  );
}

function ScoreStrip({
  match,
  innings,
  maxOvers,
  nextOver,
  nextBall,
  onUndoLastPenalty,
  scorePulse,
}: {
  match: MatchPayload;
  innings: Innings;
  maxOvers: number;
  nextOver: number;
  nextBall: number;
  onUndoLastPenalty?: () => void;
  scorePulse?: { delta: number; nonce: number } | null;
}) {
  const teamName =
    innings.battingTeam === "A" ? match.teamAName : match.teamBName;
  const effectiveRuns = innings.effectiveTotalRuns ?? innings.totalRuns;
  const penaltyRuns = innings.penaltyRuns ?? 0;
  const oversFloat = nextOver + (nextBall - 1) / 6;
  const crr = oversFloat > 0 ? effectiveRuns / oversFloat : null;
  const proj =
    innings.inningsNumber === 1 && match.format !== "TEST" && crr !== null
      ? Math.round(crr * maxOvers)
      : null;
  const tossLine = match.tossWonBy && match.tossDecision
    ? `${match.tossWonBy === "A" ? match.teamAName : match.teamBName} won toss · chose to ${
        match.tossDecision.toUpperCase() === "BAT" ? "bat" : "bowl"
      }`
    : null;
  return (
    <section className="bg-white border-b border-neutral-200 px-4 py-2">
      <div className="flex items-baseline gap-2">
        <div className="text-[13px] font-extrabold tracking-wider text-neutral-900 truncate">
          {teamName.toUpperCase()}
        </div>
        <div
          key={scorePulse?.nonce ?? 0}
          className={
            "relative text-base font-extrabold tabular-nums transition-colors duration-700 " +
            (scorePulse ? "text-emerald-700" : "text-neutral-900")
          }
        >
          {effectiveRuns}
          <span className="text-neutral-400">/</span>
          {innings.totalWickets}
          {scorePulse && (
            <span
              className={
                "pointer-events-none absolute -top-3 left-1/2 -translate-x-1/2 " +
                "text-xs font-extrabold animate-[score-rise_1.2s_ease-out_forwards] " +
                (scorePulse.delta > 0 ? "text-emerald-600" : "text-red-600")
              }
            >
              {scorePulse.delta > 0 ? `+${scorePulse.delta}` : scorePulse.delta}
            </span>
          )}
        </div>
        {penaltyRuns !== 0 && (
          <button
            type="button"
            onClick={() => {
              if (!onUndoLastPenalty) return;
              if (window.confirm("Undo the last penalty award?")) {
                onUndoLastPenalty();
              }
            }}
            disabled={!onUndoLastPenalty}
            title="Tap to undo last penalty"
            className={
              "text-[10px] font-bold px-1.5 py-0.5 rounded " +
              (penaltyRuns > 0
                ? "text-amber-700 bg-amber-100 active:bg-amber-200"
                : "text-red-700 bg-red-50 active:bg-red-100")
            }
          >
            {penaltyRuns > 0 ? `+${penaltyRuns}` : `${penaltyRuns}`} pen
          </button>
        )}
        <div className="text-xs font-bold text-neutral-500 tabular-nums">
          {nextOver}.{nextBall - 1}
        </div>
        <div className="ml-auto flex items-baseline gap-3 text-[11px]">
          <span>
            <span className="text-neutral-500">CRR </span>
            <span className="font-semibold text-neutral-900 tabular-nums">
              {crr !== null ? crr.toFixed(2) : "—"}
            </span>
          </span>
          {proj !== null && (
            <span>
              <span className="text-neutral-500">PROJ </span>
              <span className="font-semibold text-neutral-900 tabular-nums">
                {proj}
              </span>
            </span>
          )}
        </div>
      </div>
      {tossLine && (
        <div className="text-[10px] text-neutral-500 mt-0.5 truncate">
          {tossLine}
        </div>
      )}
    </section>
  );
}

function OverDots({ balls }: { balls: BallEvent[] }) {
  const legalCount = balls.filter((b) => isLegal(b.outcome)).length;
  const placeholders = Math.max(0, 6 - legalCount);
  return (
    <div className="bg-white rounded-xl border border-neutral-200 p-3 flex gap-1.5 overflow-x-auto">
      {balls.map((b) => (
        <Dot key={b.id} ball={b} />
      ))}
      {Array.from({ length: placeholders }).map((_, i) => (
        <Dot.Placeholder key={`p-${i}`} />
      ))}
    </div>
  );
}

function Dot({ ball }: { ball: BallEvent }) {
  const { bg, label } = dotStyle(ball);
  return (
    <div
      className={`w-8 h-8 rounded-full flex items-center justify-center text-white font-extrabold shrink-0 ${
        label.length > 2 ? "text-[9px]" : "text-xs"
      }`}
      style={{ backgroundColor: bg }}
    >
      {label}
    </div>
  );
}
Dot.Placeholder = function Placeholder() {
  return (
    <div className="w-8 h-8 rounded-full border border-neutral-300/70 shrink-0" />
  );
};
function dotStyle(b: BallEvent): { bg: string; label: string } {
  if (b.isWicket) return { bg: "#DC2626", label: "W" };
  switch (b.outcome) {
    case "WIDE":
      return { bg: "#92400E", label: b.extras > 1 ? `Wd+${b.extras - 1}` : "Wd" };
    case "NO_BALL":
      return { bg: "#92400E", label: b.runs > 0 ? `Nb+${b.runs}` : "Nb" };
    case "BYE":
      return { bg: "#374151", label: `B${b.extras}` };
    case "LEG_BYE":
      return { bg: "#374151", label: `Lb${b.extras}` };
    case "DOT":
      return { bg: "#374151", label: "·" };
    case "FOUR":
      return { bg: "#1D4ED8", label: "4" };
    case "SIX":
      return { bg: "#7C3AED", label: "6" };
    default:
      return { bg: "#374151", label: `${b.runs + b.extras}` };
  }
}

function BatterRow({
  name,
  stats,
  isStriker,
}: {
  name: string;
  stats: ReturnType<typeof batterStats>;
  isStriker?: boolean;
}) {
  return (
    <div className="px-4 py-2.5 flex items-center gap-2">
      <div className="w-5 text-center">
        {isStriker && <span className="text-amber-600 text-xs">●</span>}
      </div>
      <div className="flex-1 text-sm font-semibold text-neutral-900 truncate">
        {name}
      </div>
      <div className="text-right tabular-nums">
        <span className="text-base font-extrabold text-neutral-900">
          {stats.runs}
        </span>
        <span className="text-[11px] text-neutral-500"> ({stats.balls})</span>
        <span className="text-[11px] text-neutral-500">
          {" "}
          SR {stats.sr.toFixed(1)}
        </span>
      </div>
    </div>
  );
}

function BowlerRowView({
  name,
  stats,
}: {
  name: string;
  stats: ReturnType<typeof bowlerStats>;
}) {
  return (
    <div className="px-4 py-2.5 flex items-center gap-2 bg-neutral-50/50">
      <div className="w-5" />
      <div className="flex-1 text-sm font-semibold text-neutral-900 truncate">
        {name}
      </div>
      <div className="text-right">
        <div className="text-[9px] text-neutral-500 uppercase tracking-wide">
          O · R · W · Eco
        </div>
        <div className="text-xs font-bold text-neutral-900 tabular-nums">
          {stats.overs} · {stats.runs} · {stats.wickets} · {stats.economy}
        </div>
      </div>
    </div>
  );
}

function Divider() {
  return <div className="h-px bg-neutral-100" />;
}

function PadRows({
  busy,
  canUndo,
  canOverthrow,
  onDot,
  onWide,
  onNoBall,
  onOverthrow,
  onBye,
  onLegBye,
  onWicket,
  onPenalty,
  onUndo,
}: {
  busy: boolean;
  canUndo: boolean;
  canOverthrow: boolean;
  onDot: () => void;
  onWide: () => void;
  onNoBall: () => void;
  onOverthrow: () => void;
  onBye: () => void;
  onLegBye: () => void;
  onWicket: () => void;
  onPenalty: () => void;
  onUndo: () => void;
}) {
  return (
    <div className="space-y-1.5">
      <div className="grid grid-cols-4 gap-1.5">
        <PadBtn label="Dot" filled busy={busy} onClick={onDot} />
        <PadBtn label="Wide" busy={busy} onClick={onWide} />
        <PadBtn label="No Ball" busy={busy} onClick={onNoBall} />
        <PadBtn
          label="Overthrow"
          busy={busy}
          disabled={!canOverthrow}
          onClick={onOverthrow}
        />
      </div>
      <div className="grid grid-cols-4 gap-1.5">
        <PadBtn label="Bye" busy={busy} onClick={onBye} />
        <PadBtn label="Leg Bye" busy={busy} onClick={onLegBye} />
        <PadBtn label="Wicket" danger busy={busy} onClick={onWicket} />
        <PadBtn label="Penalty" busy={busy} onClick={onPenalty} />
      </div>
      <button
        disabled={!canUndo || busy}
        onClick={onUndo}
        className="w-full h-10 text-xs font-medium text-neutral-600 border border-neutral-300 bg-white disabled:opacity-40"
      >
        Undo last ball
      </button>
    </div>
  );
}

function PadBtn({
  label,
  filled,
  danger,
  muted,
  busy,
  disabled,
  onClick,
}: {
  label: string;
  filled?: boolean;
  danger?: boolean;
  muted?: boolean;
  busy: boolean;
  disabled?: boolean;
  onClick: () => void;
}) {
  const dim = busy || disabled;
  let cls =
    "h-14 text-xs font-semibold tracking-wide flex items-center justify-center border";
  if (danger) {
    cls += " bg-red-700 text-white border-red-800";
    if (dim) cls += " opacity-50";
  } else if (filled) {
    cls += " bg-neutral-900 text-white border-neutral-900";
    if (dim) cls += " opacity-50";
  } else if (muted) {
    cls += " bg-neutral-700 text-white border-neutral-700";
    if (dim) cls += " opacity-40";
  } else {
    cls += " bg-white text-neutral-900 border-neutral-300";
    if (dim) cls += " text-neutral-400";
  }
  return (
    <button onClick={onClick} disabled={dim} className={cls}>
      {label}
    </button>
  );
}

// ── Modals ─────────────────────────────────────────────────────────────────
function ModalShell({
  title,
  subtitle,
  onCancel,
  children,
}: {
  title: string;
  subtitle?: string;
  onCancel: () => void;
  children: React.ReactNode;
}) {
  return (
    <div
      className="fixed inset-0 z-30 flex items-end justify-center bg-black/40"
      onClick={onCancel}
    >
      <div
        className="w-full max-w-md bg-white rounded-t-2xl px-4 pt-3 pb-6"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="mx-auto w-9 h-1 rounded bg-neutral-300 mb-3" />
        <div className="flex items-baseline justify-between mb-3">
          <div>
            <div className="text-base font-semibold text-neutral-900">
              {title}
            </div>
            {subtitle && (
              <div className="text-[11px] text-neutral-500">{subtitle}</div>
            )}
          </div>
          <button
            onClick={onCancel}
            className="text-xs text-neutral-500 underline"
          >
            Cancel
          </button>
        </div>
        {children}
      </div>
    </div>
  );
}

function RunPickerModal({
  zone,
  onCancel,
  onPick,
  onPenalty,
}: {
  zone: WagonZone | null;
  onCancel: () => void;
  onPick: (runs: number) => void;
  onPenalty: () => void;
}) {
  return (
    <ModalShell
      title={zone ? ZONE_LABEL[zone] : "Runs"}
      onCancel={onCancel}
    >
      <div className="grid grid-cols-3 gap-2">
        {[1, 2, 3, 4, 5, 6].map((n) => (
          <button
            key={n}
            onClick={() => onPick(n)}
            className="h-16 bg-neutral-100 border border-neutral-200 text-2xl font-extrabold text-neutral-900"
          >
            {n}
          </button>
        ))}
      </div>
      <button
        onClick={onPenalty}
        className="mt-3 w-full h-11 border border-amber-300 bg-amber-50 text-amber-800 text-xs font-semibold tracking-wide"
      >
        + Umpire penalty (separate from this ball)
      </button>
    </ModalShell>
  );
}

function PenaltyModal({
  teamAName,
  teamBName,
  battingTeamSide,
  onCancel,
  onPick,
}: {
  teamAName: string;
  teamBName: string;
  battingTeamSide: "A" | "B";
  onCancel: () => void;
  onPick: (data: {
    awardedTo: "A" | "B";
    runs: number;
    direction: "ADD" | "SUBTRACT";
    reason?: string;
  }) => void;
}) {
  // `offender` is the team the umpire is penalising. The batting team's
  // visible score always moves — minus if the batting team was at fault
  // (their visible score reduces), plus if the bowling team was at fault
  // (batting side benefits). This matches the user's expected UX: penalty
  // against batting reduces, penalty against bowling adds.
  const [offender, setOffender] = useState<"A" | "B">(battingTeamSide);
  const [runs, setRuns] = useState(5);
  const [reason, setReason] = useState("");

  const direction: "ADD" | "SUBTRACT" =
    offender === battingTeamSide ? "SUBTRACT" : "ADD";

  const previewLine = (() => {
    const battingName = battingTeamSide === "A" ? teamAName : teamBName;
    if (direction === "SUBTRACT") return `${battingName} score: −${runs}`;
    return `${battingName} score: +${runs}`;
  })();

  return (
    <ModalShell
      title="Umpire penalty"
      subtitle="Penalty against the offending team"
      onCancel={onCancel}
    >
      <div className="space-y-4">
        <div>
          <div className="text-[10px] uppercase tracking-wide text-neutral-500 mb-1.5">
            Penalty against
          </div>
          <div className="grid grid-cols-2 gap-2">
            <button
              onClick={() => setOffender("A")}
              className={
                "h-14 rounded-md border text-sm font-semibold flex flex-col justify-center " +
                (offender === "A"
                  ? "bg-red-700 border-red-700 text-white"
                  : "bg-white border-neutral-300 text-neutral-900")
              }
            >
              <span>{teamAName}</span>
              <span
                className={
                  "text-[10px] " +
                  (offender === "A" ? "text-red-100" : "text-neutral-500")
                }
              >
                {battingTeamSide === "A" ? "batting" : "bowling"}
              </span>
            </button>
            <button
              onClick={() => setOffender("B")}
              className={
                "h-14 rounded-md border text-sm font-semibold flex flex-col justify-center " +
                (offender === "B"
                  ? "bg-red-700 border-red-700 text-white"
                  : "bg-white border-neutral-300 text-neutral-900")
              }
            >
              <span>{teamBName}</span>
              <span
                className={
                  "text-[10px] " +
                  (offender === "B" ? "text-red-100" : "text-neutral-500")
                }
              >
                {battingTeamSide === "B" ? "batting" : "bowling"}
              </span>
            </button>
          </div>
        </div>

        <div>
          <div className="text-[10px] uppercase tracking-wide text-neutral-500 mb-1.5">
            Runs
          </div>
          <div className="grid grid-cols-5 gap-1.5">
            {[1, 2, 3, 4, 5].map((n) => (
              <button
                key={n}
                onClick={() => setRuns(n)}
                className={
                  "h-12 rounded-md border font-bold " +
                  (runs === n
                    ? "bg-amber-600 border-amber-700 text-white"
                    : "bg-white border-neutral-300 text-neutral-900")
                }
              >
                {n}
              </button>
            ))}
          </div>
        </div>

        <div className="text-[12px] font-medium text-neutral-700 bg-neutral-100 rounded px-3 py-2">
          {previewLine}
        </div>

        <div>
          <div className="text-[10px] uppercase tracking-wide text-neutral-500 mb-1.5">
            Reason (optional)
          </div>
          <input
            value={reason}
            onChange={(e) => setReason(e.target.value)}
            placeholder="e.g. slow over rate"
            className="w-full rounded-lg border border-neutral-300 px-3 py-2 text-sm"
            maxLength={200}
          />
        </div>

        <button
          onClick={() =>
            onPick({
              // Batting team's visible total always moves — sign is the choice.
              awardedTo: battingTeamSide,
              runs,
              direction,
              reason: reason.trim() || undefined,
            })
          }
          className={
            "w-full h-12 text-white font-semibold " +
            (direction === "SUBTRACT" ? "bg-red-700" : "bg-amber-600")
          }
        >
          Confirm penalty
        </button>
      </div>
    </ModalShell>
  );
}

function ExtraPickerModal({
  title,
  subtitle,
  options,
  onCancel,
  onPick,
}: {
  title: string;
  subtitle?: string;
  options: number[];
  onCancel: () => void;
  onPick: (n: number) => void;
}) {
  return (
    <ModalShell title={title} subtitle={subtitle} onCancel={onCancel}>
      <div className="grid grid-cols-3 gap-2">
        {options.map((n) => (
          <button
            key={n}
            onClick={() => onPick(n)}
            className="h-14 bg-neutral-100 border border-neutral-200 text-xl font-extrabold text-neutral-900"
          >
            {n}
          </button>
        ))}
      </div>
    </ModalShell>
  );
}

function NoBallModal({
  onCancel,
  onPick,
}: {
  onCancel: () => void;
  onPick: (kind: "BAT" | "BYE" | "LEG_BYE", count: number) => void;
}) {
  const [tab, setTab] = useState<"BAT" | "BYE" | "LEG_BYE">("BAT");
  return (
    <ModalShell
      title="No Ball"
      subtitle="Pick how the runs were scored"
      onCancel={onCancel}
    >
      <div className="flex bg-neutral-100 rounded-lg p-1 mb-3 text-xs font-medium">
        {([
          ["BAT", "Off the bat"],
          ["BYE", "Bye"],
          ["LEG_BYE", "Leg Bye"],
        ] as const).map(([k, label]) => (
          <button
            key={k}
            onClick={() => setTab(k)}
            className={`flex-1 py-1.5 rounded-md ${
              tab === k ? "bg-white text-neutral-900" : "text-neutral-600"
            }`}
          >
            {label}
          </button>
        ))}
      </div>
      <div className="grid grid-cols-4 gap-2">
        {[0, 1, 2, 3, 4, 5, 6].map((n) => (
          <button
            key={n}
            onClick={() => onPick(tab, n)}
            className="h-14 bg-neutral-100 border border-neutral-200 text-xl font-extrabold text-neutral-900"
          >
            {tab === "BAT" && n === 0 ? "Nb only" : `+${n}`}
          </button>
        ))}
      </div>
    </ModalShell>
  );
}

// Dismissal → cricket rules, 1:1 with Flutter `wicket_sheet.dart`.
const DISMISSALS: Array<{ key: string; label: string }> = [
  { key: "BOWLED", label: "Bowled" },
  { key: "CAUGHT", label: "Caught" },
  { key: "CAUGHT_BEHIND", label: "Ct Behind" },
  { key: "CAUGHT_AND_BOWLED", label: "C & B" },
  { key: "LBW", label: "LBW" },
  { key: "RUN_OUT", label: "Run Out" },
  { key: "STUMPED", label: "Stumped" },
  { key: "HIT_WICKET", label: "Hit Wkt" },
  { key: "RETIRED_HURT", label: "Ret Hurt" },
  { key: "RETIRED_OUT", label: "Ret Out" },
];

const VALID_ON: Record<string, Set<string>> = {
  LEGAL: new Set([
    "BOWLED",
    "CAUGHT",
    "CAUGHT_BEHIND",
    "CAUGHT_AND_BOWLED",
    "LBW",
    "RUN_OUT",
    "STUMPED",
    "HIT_WICKET",
    "RETIRED_HURT",
    "RETIRED_OUT",
  ]),
  WIDE: new Set(["RUN_OUT", "STUMPED", "RETIRED_HURT", "RETIRED_OUT"]),
  NO_BALL: new Set(["RUN_OUT", "RETIRED_HURT", "RETIRED_OUT"]),
};

const FREE_HIT_VALID = new Set([
  "RUN_OUT",
  "HIT_WICKET",
  "RETIRED_HURT",
  "RETIRED_OUT",
]);

// Dismissals where no separate fielder is recorded (bowler/umpire-only).
const NO_FIELDER = new Set([
  "BOWLED",
  "LBW",
  "HIT_WICKET",
  "RETIRED_HURT",
  "RETIRED_OUT",
]);

function autoFielderFor(
  type: string,
  keeperId: string | null,
  bowlerId: string,
): string | null {
  if (type === "CAUGHT_BEHIND" || type === "STUMPED") return keeperId ?? null;
  if (type === "CAUGHT_AND_BOWLED" || type === "LBW") return bowlerId;
  return null;
}

function WicketModal({
  striker,
  nonStriker,
  fielders,
  bowlerId,
  keeperId,
  isFreeHit,
  onCancel,
  onPick,
}: {
  striker: { id: string; name: string };
  nonStriker: { id: string; name: string };
  fielders: Player[];
  bowlerId: string;
  keeperId: string | null;
  isFreeHit: boolean;
  onCancel: () => void;
  onPick: (data: {
    dismissalType: string;
    deliveryType: "LEGAL" | "WIDE" | "NO_BALL";
    dismissedPlayerId: string;
    fielderId?: string | null;
    substituteFielderName?: string | null;
    completedRuns: number;
  }) => void;
}) {
  const [delivery, setDelivery] = useState<"LEGAL" | "WIDE" | "NO_BALL">("LEGAL");
  const [type, setType] = useState<string>("BOWLED");
  const [dismissedIsStriker, setDismissedIsStriker] = useState(true);
  const [manualFielder, setManualFielder] = useState<string | null>(null);
  const [substitute, setSubstitute] = useState(false);
  const [substituteName, setSubstituteName] = useState("");
  const [completedRuns, setCompletedRuns] = useState(0);

  function isValid(key: string) {
    if (isFreeHit && delivery === "LEGAL") return FREE_HIT_VALID.has(key);
    return VALID_ON[delivery]?.has(key) ?? false;
  }

  // Coerce dismissal whenever delivery changes so it stays valid.
  function changeDelivery(d: "LEGAL" | "WIDE" | "NO_BALL") {
    setDelivery(d);
    const valid = (() => {
      if (isFreeHit && d === "LEGAL") return FREE_HIT_VALID;
      return VALID_ON[d];
    })();
    if (!valid?.has(type)) {
      const first = DISMISSALS.find((m) => valid?.has(m.key));
      if (first) {
        setType(first.key);
        if (first.key !== "RUN_OUT") setDismissedIsStriker(true);
      }
    }
  }

  function changeType(key: string) {
    if (!isValid(key)) return;
    setType(key);
    if (key !== "RUN_OUT") setDismissedIsStriker(true);
    if (key !== "CAUGHT") {
      setSubstitute(false);
      setSubstituteName("");
    }
  }

  const auto = autoFielderFor(type, keeperId, bowlerId);
  const needsFielder = !NO_FIELDER.has(type);
  const allowsSubstitute = type === "CAUGHT";

  const effectiveFielderId = (() => {
    if (!needsFielder) return null;
    if (substitute) return null;
    return auto ?? manualFielder;
  })();

  const canConfirm = (() => {
    if (!isValid(type)) return false;
    if (needsFielder && !auto) {
      if (substitute) {
        if (substituteName.trim() === "") return false;
      } else if (!manualFielder) {
        return false;
      }
    }
    return true;
  })();

  return (
    <ModalShell title="Record wicket" subtitle={isFreeHit ? "FREE HIT" : undefined} onCancel={onCancel}>
      <div className="space-y-4">
        {/* Delivery type chips */}
        <div>
          <div className="text-[10px] uppercase tracking-wide text-neutral-500 mb-1.5">
            Delivery type
          </div>
          <div className="grid grid-cols-3 gap-2">
            <DeliveryChip
              label="Legal"
              selected={delivery === "LEGAL"}
              color="#10B981"
              onClick={() => changeDelivery("LEGAL")}
            />
            <DeliveryChip
              label="Wide"
              selected={delivery === "WIDE"}
              color="#F59E0B"
              onClick={() => changeDelivery("WIDE")}
            />
            <DeliveryChip
              label="No Ball"
              selected={delivery === "NO_BALL"}
              color="#EF4444"
              onClick={() => changeDelivery("NO_BALL")}
            />
          </div>
        </div>

        {/* Dismissal grid */}
        <div>
          <div className="text-[10px] uppercase tracking-wide text-neutral-500 mb-1.5">
            How out
          </div>
          <div className="grid grid-cols-4 gap-1.5">
            {DISMISSALS.map((m) => {
              const valid = isValid(m.key);
              const selected = type === m.key;
              return (
                <button
                  key={m.key}
                  disabled={!valid}
                  onClick={() => changeType(m.key)}
                  className={
                    "h-12 text-[11px] font-semibold border rounded-md " +
                    (selected
                      ? "bg-red-700 text-white border-red-700"
                      : valid
                        ? "bg-white text-neutral-900 border-neutral-300"
                        : "bg-neutral-50 text-neutral-300 border-neutral-200")
                  }
                >
                  {m.label}
                </button>
              );
            })}
          </div>
        </div>

        {/* Run out: striker / non-striker */}
        {type === "RUN_OUT" && (
          <div>
            <div className="text-[10px] uppercase tracking-wide text-neutral-500 mb-1.5">
              Who is out
            </div>
            <div className="grid grid-cols-2 gap-2">
              <BatterToggle
                label={striker.name}
                sublabel="Striker"
                selected={dismissedIsStriker}
                onClick={() => setDismissedIsStriker(true)}
              />
              <BatterToggle
                label={nonStriker.name}
                sublabel="Non-Striker"
                selected={!dismissedIsStriker}
                onClick={() => setDismissedIsStriker(false)}
              />
            </div>
          </div>
        )}

        {/* Fielder */}
        {needsFielder && (
          <div>
            <div className="text-[10px] uppercase tracking-wide text-neutral-500 mb-1.5">
              Fielder
            </div>
            {auto ? (
              <div className="px-3 py-2 rounded-lg border border-neutral-200 bg-neutral-50 text-sm text-neutral-700">
                {fielders.find((p) => p.profileId === auto)?.name ?? "—"}
                <span className="text-[10px] text-neutral-500 ml-2">
                  (auto)
                </span>
              </div>
            ) : substitute ? (
              <input
                value={substituteName}
                onChange={(e) => setSubstituteName(e.target.value)}
                placeholder="Substitute fielder name"
                className="w-full rounded-lg border border-neutral-300 px-3 py-2 text-sm"
              />
            ) : (
              <select
                value={manualFielder ?? ""}
                onChange={(e) => setManualFielder(e.target.value || null)}
                className="w-full rounded-lg border border-neutral-300 px-3 py-2 text-sm bg-white"
              >
                <option value="">Select fielder…</option>
                {fielders.map((p) => (
                  <option key={p.profileId} value={p.profileId}>
                    {p.name}
                  </option>
                ))}
              </select>
            )}
            {allowsSubstitute && (
              <label className="mt-2 flex items-center gap-2 text-xs text-neutral-700">
                <input
                  type="checkbox"
                  checked={substitute}
                  onChange={(e) => {
                    const v = e.target.checked;
                    setSubstitute(v);
                    if (v) setManualFielder(null);
                    else setSubstituteName("");
                  }}
                />
                Caught by a substitute fielder
              </label>
            )}
          </div>
        )}

        {/* Completed runs */}
        <div>
          <div className="text-[10px] uppercase tracking-wide text-neutral-500 mb-1.5">
            Completed runs
          </div>
          <div className="grid grid-cols-5 gap-1.5">
            {[0, 1, 2, 3, 4].map((n) => (
              <button
                key={n}
                onClick={() => setCompletedRuns(n)}
                className={
                  "h-10 rounded-md font-bold text-sm border " +
                  (completedRuns === n
                    ? "bg-red-700 text-white border-red-700"
                    : "bg-white text-neutral-900 border-neutral-300")
                }
              >
                {n}
              </button>
            ))}
          </div>
        </div>

        <button
          disabled={!canConfirm}
          onClick={() =>
            onPick({
              dismissalType: type,
              deliveryType: delivery,
              dismissedPlayerId: dismissedIsStriker ? striker.id : nonStriker.id,
              fielderId: effectiveFielderId,
              substituteFielderName: substitute ? substituteName.trim() : null,
              completedRuns,
            })
          }
          className="w-full h-12 bg-red-700 text-white font-semibold disabled:opacity-50"
        >
          Confirm wicket
        </button>
      </div>
    </ModalShell>
  );
}

function DeliveryChip({
  label,
  selected,
  color,
  onClick,
}: {
  label: string;
  selected: boolean;
  color: string;
  onClick: () => void;
}) {
  return (
    <button
      onClick={onClick}
      className={
        "h-10 rounded-md text-xs font-semibold border " +
        (selected ? "text-white" : "text-neutral-700 bg-white border-neutral-300")
      }
      style={
        selected ? { backgroundColor: color, borderColor: color } : undefined
      }
    >
      {label}
    </button>
  );
}

function BatterToggle({
  label,
  sublabel,
  selected,
  onClick,
}: {
  label: string;
  sublabel: string;
  selected: boolean;
  onClick: () => void;
}) {
  return (
    <button
      onClick={onClick}
      className={
        "h-14 rounded-lg border text-left px-3 " +
        (selected
          ? "bg-red-700 border-red-700 text-white"
          : "bg-white border-neutral-300 text-neutral-900")
      }
    >
      <div className="text-sm font-semibold truncate">{label}</div>
      <div
        className={
          "text-[10px] uppercase tracking-wide " +
          (selected ? "text-red-100" : "text-neutral-500")
        }
      >
        {sublabel}
      </div>
    </button>
  );
}

// ── Setup / pickers ────────────────────────────────────────────────────────
function SetupPanel({
  batting,
  bowling,
  striker,
  nonStriker,
  bowler,
  busy,
  onSubmit,
}: {
  batting: Team | null;
  bowling: Team | null;
  striker: string | null;
  nonStriker: string | null;
  bowler: string | null;
  busy: boolean;
  onSubmit: (s: {
    strikerId: string | null;
    nonStrikerId: string | null;
    bowlerId: string | null;
  }) => void;
}) {
  const [s, setS] = useState(striker);
  const [ns, setNs] = useState(nonStriker);
  const [b, setB] = useState(bowler);
  const valid = s && ns && b && s !== ns;
  return (
    <div className="bg-white rounded-xl border border-neutral-200 p-5 space-y-4">
      <div>
        <div className="text-sm font-semibold text-neutral-900 mb-1">
          Innings setup
        </div>
        <p className="text-xs text-neutral-600">
          Pick opening batters and the first bowler to start scoring.
        </p>
      </div>
      <PlayerSelect label="Striker" team={batting} value={s} exclude={ns} onChange={setS} />
      <PlayerSelect label="Non-striker" team={batting} value={ns} exclude={s} onChange={setNs} />
      <PlayerSelect label="Bowler" team={bowling} value={b} exclude={null} onChange={setB} />
      <button
        disabled={!valid || busy}
        onClick={() => valid && onSubmit({ strikerId: s, nonStrikerId: ns, bowlerId: b })}
        className="w-full rounded-lg bg-neutral-900 text-white font-medium py-3 text-sm disabled:opacity-50"
      >
        {busy ? "Saving…" : "Start innings"}
      </button>
    </div>
  );
}

function NewBatterPanel({
  batting,
  excludeIds,
  missing,
  busy,
  onPick,
}: {
  batting: Team | null;
  excludeIds: string[];
  missing: "striker" | "nonStriker";
  busy: boolean;
  onPick: (id: string) => void;
}) {
  const [pick, setPick] = useState<string | null>(null);
  return (
    <div className="bg-white rounded-xl border border-neutral-200 p-5 space-y-4">
      <div>
        <div className="text-sm font-semibold text-neutral-900 mb-1">
          New batter
        </div>
        <p className="text-xs text-neutral-600">
          Pick the incoming batter ({missing === "striker" ? "striker" : "non-striker"}).
        </p>
      </div>
      <PlayerSelect
        label="Batter"
        team={batting}
        value={pick}
        excludeMany={excludeIds}
        exclude={null}
        onChange={setPick}
      />
      <button
        disabled={!pick || busy}
        onClick={() => pick && onPick(pick)}
        className="w-full rounded-lg bg-neutral-900 text-white font-medium py-3 text-sm disabled:opacity-50"
      >
        {busy ? "Saving…" : "Continue"}
      </button>
    </div>
  );
}

function BowlerPicker({
  bowling,
  excludeId,
  busy,
  onPick,
}: {
  bowling: Team | null;
  excludeId: string | null;
  busy: boolean;
  onPick: (id: string) => void;
}) {
  const [b, setB] = useState<string | null>(null);
  return (
    <div className="bg-white rounded-xl border border-neutral-200 p-5 space-y-4">
      <div>
        <div className="text-sm font-semibold text-neutral-900 mb-1">
          End of over
        </div>
        <p className="text-xs text-neutral-600">Pick the next bowler.</p>
      </div>
      <PlayerSelect label="Bowler" team={bowling} value={b} exclude={excludeId} onChange={setB} />
      <button
        disabled={!b || busy}
        onClick={() => b && onPick(b)}
        className="w-full rounded-lg bg-neutral-900 text-white font-medium py-3 text-sm disabled:opacity-50"
      >
        {busy ? "Saving…" : "Continue"}
      </button>
    </div>
  );
}

function PlayerSelect({
  label,
  team,
  value,
  exclude,
  excludeMany,
  onChange,
}: {
  label: string;
  team: Team | null;
  value: string | null;
  exclude: string | null;
  excludeMany?: string[];
  onChange: (id: string) => void;
}) {
  const banned = new Set([exclude, ...(excludeMany ?? [])].filter(Boolean) as string[]);
  const options = (team?.players ?? []).filter((p) => !banned.has(p.profileId));
  return (
    <label className="block">
      <span className="text-[11px] font-medium text-neutral-700 uppercase tracking-wide">
        {label}
      </span>
      <select
        value={value ?? ""}
        onChange={(e) => onChange(e.target.value)}
        className="mt-1 w-full rounded-lg border border-neutral-300 px-3 py-2.5 text-sm bg-white"
      >
        <option value="">Select {label.toLowerCase()}…</option>
        {options.map((p) => (
          <option key={p.profileId} value={p.profileId}>
            {p.name}
            {p.isOut ? " (out)" : ""}
          </option>
        ))}
      </select>
    </label>
  );
}

function InfoPanel({ children }: { children: React.ReactNode }) {
  return (
    <div className="bg-white rounded-xl border border-neutral-200 p-6 text-center">
      <p className="text-sm text-neutral-700">{children}</p>
    </div>
  );
}

function ErrorBanner({ message }: { message: string }) {
  return (
    <div className="rounded-lg border border-red-200 bg-red-50 text-red-700 text-sm px-3 py-2">
      {message}
    </div>
  );
}

function FreeHitBanner() {
  return (
    <div
      className="flex items-center justify-center w-full h-9 -mx-3 px-3 text-white text-xs font-extrabold tracking-wider"
      style={{ backgroundColor: "#14532D" }}
    >
      ⚡ FREE HIT — batter can only be run out
    </div>
  );
}

function ChaseStrip({ text }: { text: string }) {
  return (
    <div className="-mx-3 px-4 py-1.5 bg-neutral-900 text-white text-xs font-semibold tracking-wide tabular-nums">
      {text}
    </div>
  );
}

function InningsSummaryPanel({
  teamName,
  runs,
  wickets,
  overs,
  inningsNumber,
  busy,
  onEndMatch,
  onContinue,
}: {
  teamName: string;
  runs: number;
  wickets: number;
  overs: number;
  inningsNumber: number;
  busy: boolean;
  onEndMatch: () => void;
  onContinue: () => void;
}) {
  return (
    <div className="space-y-3">
      <div className="bg-white rounded-xl border border-neutral-200 p-5">
        <div className="text-[10px] uppercase tracking-wide text-neutral-500 mb-1">
          Innings {inningsNumber} complete
        </div>
        <div className="text-lg font-extrabold text-neutral-900 truncate">
          {teamName}
        </div>
        <div className="mt-2 flex items-baseline gap-3">
          <div className="text-4xl font-extrabold text-neutral-900 tabular-nums">
            {runs}
            <span className="text-neutral-400">/</span>
            {wickets}
          </div>
          <div className="text-sm text-neutral-600 tabular-nums">
            ({overs} ov)
          </div>
        </div>
      </div>
      <button
        disabled={busy}
        onClick={onEndMatch}
        className="w-full h-12 bg-neutral-900 text-white font-semibold disabled:opacity-50 rounded-lg"
      >
        End match
      </button>
      <button
        disabled={busy}
        onClick={onContinue}
        className="w-full h-12 bg-white border border-neutral-300 text-neutral-900 font-semibold disabled:opacity-50 rounded-lg"
      >
        Continue scoring
      </button>
    </div>
  );
}

function EndMatchModal({
  teamAName,
  teamBName,
  onCancel,
  onConfirm,
}: {
  teamAName: string;
  teamBName: string;
  onCancel: () => void;
  onConfirm: (
    winnerId: "A" | "B" | "TIE" | "ABANDONED",
    winMargin?: string,
  ) => void;
}) {
  const [winner, setWinner] = useState<"A" | "B" | "TIE" | "ABANDONED" | null>(
    null,
  );
  const [margin, setMargin] = useState("");
  const options: Array<{ key: "A" | "B" | "TIE" | "ABANDONED"; label: string }> = [
    { key: "A", label: teamAName },
    { key: "B", label: teamBName },
    { key: "TIE", label: "Tie" },
    { key: "ABANDONED", label: "Abandoned" },
  ];
  return (
    <ModalShell
      title="End match"
      subtitle="Confirm the result"
      onCancel={onCancel}
    >
      <div className="space-y-4">
        <div>
          <div className="text-[10px] uppercase tracking-wide text-neutral-500 mb-1.5">
            Winner
          </div>
          <div className="grid grid-cols-2 gap-2">
            {options.map((o) => (
              <button
                key={o.key}
                onClick={() => setWinner(o.key)}
                className={
                  "h-12 rounded-md border text-sm font-semibold truncate px-2 " +
                  (winner === o.key
                    ? "bg-neutral-900 border-neutral-900 text-white"
                    : "bg-white border-neutral-300 text-neutral-900")
                }
              >
                {o.label}
              </button>
            ))}
          </div>
        </div>

        <div>
          <div className="text-[10px] uppercase tracking-wide text-neutral-500 mb-1.5">
            Win margin (optional)
          </div>
          <input
            value={margin}
            onChange={(e) => setMargin(e.target.value)}
            placeholder="e.g. by 7 runs / by 4 wickets"
            className="w-full rounded-lg border border-neutral-300 px-3 py-2 text-sm"
            maxLength={80}
          />
        </div>

        <button
          disabled={!winner}
          onClick={() => winner && onConfirm(winner, margin.trim() || undefined)}
          className="w-full h-12 bg-neutral-900 text-white font-semibold disabled:opacity-50"
        >
          Confirm result
        </button>
      </div>
    </ModalShell>
  );
}

function ErrorState({
  message,
  onRetry,
  onSignOut,
}: {
  message: string;
  onRetry: () => void;
  onSignOut: () => void;
}) {
  return (
    <main className="min-h-screen bg-neutral-50 flex items-center justify-center px-4">
      <div className="w-full max-w-sm text-center">
        <div className="text-base font-medium text-neutral-900 mb-2">
          Could not load match
        </div>
        <p className="text-sm text-neutral-600 mb-6">{message}</p>
        <div className="flex gap-2 justify-center">
          <button
            onClick={onRetry}
            className="rounded-lg border border-neutral-300 text-sm font-medium px-4 py-2"
          >
            Retry
          </button>
          <button
            onClick={onSignOut}
            className="rounded-lg bg-neutral-900 text-white text-sm font-medium px-4 py-2"
          >
            Sign out
          </button>
        </div>
      </div>
    </main>
  );
}

// ── Side drawer + pickers ──────────────────────────────────────────────────
type DrawerAction =
  | { divider: true }
  | { label: string; onClick: () => void; danger?: boolean };

function MenuDrawer({
  open,
  onClose,
  actions,
}: {
  open: boolean;
  onClose: () => void;
  actions: DrawerAction[];
}) {
  return (
    <div
      className={
        "fixed inset-0 z-40 transition-opacity " +
        (open
          ? "opacity-100 pointer-events-auto"
          : "opacity-0 pointer-events-none")
      }
      aria-hidden={!open}
    >
      <div
        className="absolute inset-0 bg-black/40"
        onClick={onClose}
      />
      <aside
        className={
          "absolute top-0 right-0 h-full w-72 max-w-[80vw] bg-white shadow-xl " +
          "transition-transform duration-200 " +
          (open ? "translate-x-0" : "translate-x-full")
        }
        role="dialog"
        aria-label="Scorer menu"
      >
        <div className="px-4 py-3 border-b border-neutral-200 flex items-center justify-between">
          <div className="text-sm font-semibold text-neutral-900">
            Scorer menu
          </div>
          <button
            onClick={onClose}
            className="text-xs text-neutral-500 underline"
          >
            Close
          </button>
        </div>
        <nav className="py-1">
          {actions.map((a, i) =>
            "divider" in a ? (
              <div key={`d-${i}`} className="h-px bg-neutral-100 my-1" />
            ) : (
              <button
                key={a.label}
                onClick={a.onClick}
                className={
                  "block w-full text-left px-4 py-3 text-sm active:bg-neutral-100 " +
                  (a.danger
                    ? "text-red-700 font-medium"
                    : "text-neutral-900")
                }
              >
                {a.label}
              </button>
            ),
          )}
        </nav>
      </aside>
    </div>
  );
}

function PlayerPickerModal({
  role,
  battingTeam,
  bowlingTeam,
  activeInnings,
  currentKeeperId,
  onCancel,
  onPick,
}: {
  role: "striker" | "nonStriker" | "bowler" | "wk";
  battingTeam: Team | null;
  bowlingTeam: Team | null;
  activeInnings: Innings;
  currentKeeperId: string | null;
  onCancel: () => void;
  onPick: (id: string) => void;
}) {
  // Which team's players to show + who to exclude depends on the role.
  const { team, exclude, title, subtitle, currentId } = (() => {
    switch (role) {
      case "striker":
        return {
          team: battingTeam,
          exclude: [activeInnings.currentNonStrikerId].filter(
            Boolean,
          ) as string[],
          title: "Change striker",
          subtitle: "Pick the new on-strike batter",
          currentId: activeInnings.currentStrikerId,
        };
      case "nonStriker":
        return {
          team: battingTeam,
          exclude: [activeInnings.currentStrikerId].filter(
            Boolean,
          ) as string[],
          title: "Change non-striker",
          subtitle: "Pick the new non-striker",
          currentId: activeInnings.currentNonStrikerId,
        };
      case "bowler":
        return {
          team: bowlingTeam,
          // Exclude the currently bowling player so you can't reselect them.
          exclude: [],
          title: "Change bowler",
          subtitle: "Pick the bowler for the next ball",
          currentId: activeInnings.currentBowlerId,
        };
      case "wk":
        return {
          team: bowlingTeam,
          exclude: [],
          title: "Change wicket-keeper",
          subtitle: "Pick the new wicket-keeper",
          currentId: currentKeeperId,
        };
    }
  })();

  const players = (team?.players ?? []).filter(
    (p) => !exclude.includes(p.profileId),
  );

  return (
    <ModalShell title={title} subtitle={subtitle} onCancel={onCancel}>
      <div className="space-y-1 max-h-[60vh] overflow-y-auto">
        {players.length === 0 && (
          <div className="text-sm text-neutral-500 px-2 py-3">
            No players available.
          </div>
        )}
        {players.map((p) => {
          const isCurrent = p.profileId === currentId;
          return (
            <button
              key={p.profileId}
              onClick={() => onPick(p.profileId)}
              disabled={isCurrent}
              className={
                "w-full text-left px-3 py-3 rounded-md border " +
                (isCurrent
                  ? "border-neutral-200 bg-neutral-50 text-neutral-400"
                  : "border-neutral-200 bg-white text-neutral-900 active:bg-neutral-100")
              }
            >
              <div className="text-sm font-medium flex items-center justify-between">
                <span>{p.name}</span>
                {isCurrent && (
                  <span className="text-[10px] uppercase tracking-wide text-neutral-500">
                    current
                  </span>
                )}
                {p.isOut && !isCurrent && (
                  <span className="text-[10px] uppercase tracking-wide text-red-500">
                    out
                  </span>
                )}
              </div>
            </button>
          );
        })}
      </div>
    </ModalShell>
  );
}

function ConfirmModal({
  title,
  body,
  confirmLabel,
  danger,
  onCancel,
  onConfirm,
}: {
  title: string;
  body: string;
  confirmLabel: string;
  danger?: boolean;
  onCancel: () => void;
  onConfirm: () => void | Promise<void>;
}) {
  return (
    <ModalShell title={title} onCancel={onCancel}>
      <p className="text-sm text-neutral-700 mb-4">{body}</p>
      <div className="grid grid-cols-2 gap-2">
        <button
          onClick={onCancel}
          className="h-11 border border-neutral-300 bg-white text-sm font-medium text-neutral-900"
        >
          Cancel
        </button>
        <button
          onClick={() => void onConfirm()}
          className={
            "h-11 text-white font-semibold " +
            (danger ? "bg-red-700" : "bg-neutral-900")
          }
        >
          {confirmLabel}
        </button>
      </div>
    </ModalShell>
  );
}
