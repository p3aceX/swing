"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import {
  clearScorerSession,
  readScorerSession,
  scorerFetch,
} from "../_session";
import { WagonWheel, ZONE_LABEL, type WagonZone } from "./_wagon-wheel";

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
  currentStrikerId: string | null;
  currentNonStrikerId: string | null;
  currentBowlerId: string | null;
  ballEvents: BallEvent[];
};
type MatchPayload = {
  id: string;
  status: string;
  format: string;
  teamAName: string;
  teamBName: string;
  customOvers?: number | null;
  innings: Innings[];
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
  type Modal =
    | { kind: "runs"; zone: WagonZone | null }
    | { kind: "wide" }
    | { kind: "noball" }
    | { kind: "bye" }
    | { kind: "legbye" }
    | { kind: "overthrow"; batsmanRuns: number }
    | { kind: "wicket" }
    | { kind: "new-batter" }
    | null;
  const [modal, setModal] = useState<Modal>(null);

  // ── Data ─────────────────────────────────────────────────────────────────
  const refresh = useCallback(async () => {
    const [mRes, pRes] = await Promise.all([
      scorerFetch(`/match/${matchId}`),
      scorerFetch(`/match/${matchId}/players`),
    ]);
    if (mRes.status === 401 || pRes.status === 401) {
      clearScorerSession();
      router.replace("/score");
      return;
    }
    const mBody = await mRes.json().catch(() => ({}));
    const pBody = await pRes.json().catch(() => ({}));
    if (!mRes.ok || !mBody?.success) {
      throw new Error(mBody?.error?.message ?? "Failed to load match");
    }
    if (!pRes.ok || !pBody?.success) {
      throw new Error(pBody?.error?.message ?? "Failed to load players");
    }
    setMatch(mBody.data as MatchPayload);
    setPlayers(pBody.data as PlayersPayload);
  }, [matchId, router]);

  useEffect(() => {
    const s = readScorerSession();
    if (!s || s.matchId !== matchId) {
      router.replace("/score");
      return;
    }
    (async () => {
      setLoading(true);
      setError(null);
      try {
        await refresh();
      } catch (e) {
        setError((e as Error).message);
      } finally {
        setLoading(false);
      }
    })();
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

  const endOfOver =
    !!activeInnings &&
    nextBall === 1 &&
    (activeInnings.ballEvents?.length ?? 0) > 0 &&
    !!activeInnings.currentStrikerId &&
    !!activeInnings.currentNonStrikerId;

  // After a wicket, the new-batter picker is mandatory before the next ball.
  // Backend clears currentStrikerId when the dismissed batter was striker.
  // Detect: previous ball was a wicket AND currentStrikerId/NonStrikerId is
  // null while balls are not zero.
  const needsNewBatter = useMemo(() => {
    if (!activeInnings) return false;
    if ((activeInnings.ballEvents ?? []).length === 0) return false;
    if (
      activeInnings.currentStrikerId === null ||
      activeInnings.currentNonStrikerId === null
    ) {
      return true;
    }
    return false;
  }, [activeInnings]);

  // ── Mutations ────────────────────────────────────────────────────────────
  async function call(
    path: string,
    init: { method: string; body?: unknown },
  ): Promise<void> {
    setBusy(true);
    setError(null);
    try {
      const body =
        init.body === undefined
          ? undefined
          : typeof init.body === "string"
            ? init.body
            : JSON.stringify(init.body);
      const res = await scorerFetch(path, { method: init.method, body });
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

  async function recordBall(extra: Record<string, unknown>) {
    if (!activeInnings) return;
    const payload = ballPayload(extra);
    if (!payload) return;
    await call(
      `/match/${matchId}/innings/${activeInnings.inningsNumber}/ball`,
      { method: "POST", body: payload },
    );
    setZone(null);
  }

  async function undo() {
    if (!activeInnings) return;
    await call(
      `/match/${matchId}/innings/${activeInnings.inningsNumber}/last-ball`,
      { method: "DELETE" },
    );
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
  const onOverthrowPick = (n: number) => {
    setModal(null);
    // Append overthrow to the last ball isn't a separate endpoint — we
    // record a brand new event flagged as an overthrow with overthrowRuns.
    // (matches the Flutter `_addOverthrowToLastBall` path.)
    if (!lastBall) return;
    void recordBall({
      outcome: lastBall.outcome,
      runs: lastBall.runs + n,
      isOverthrow: true,
      overthrowRuns: n,
    });
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
    return (
      <Shell match={match} onSignOut={onSignOut}>
        <InfoPanel>
          Innings {activeInnings.inningsNumber} completed. Open the host app
          to continue or end the match.
        </InfoPanel>
      </Shell>
    );
  }

  // Opening setup
  if (
    !activeInnings.currentStrikerId ||
    !activeInnings.currentNonStrikerId ||
    !activeInnings.currentBowlerId
  ) {
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
  if (endOfOver) {
    return (
      <Shell
        match={match}
        innings={activeInnings}
        maxOvers={maxOversOf(match)}
        nameOf={nameOf}
        nextOver={nextOver}
        nextBall={nextBall}
        onSignOut={onSignOut}
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

  return (
    <Shell
      match={match}
      innings={activeInnings}
      maxOvers={maxOversOf(match)}
      nameOf={nameOf}
      nextOver={nextOver}
      nextBall={nextBall}
      onSignOut={onSignOut}
    >
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
        onUndo={undo}
      />

      {error && <ErrorBanner message={error} />}

      {/* ── Modals ─────────────────────────────────────────────────────── */}
      {modal?.kind === "runs" && (
        <RunPickerModal
          zone={modal.zone}
          onCancel={() => setModal(null)}
          onPick={onRunPick}
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
          options={[1, 2, 3, 4]}
          onCancel={() => setModal(null)}
          onPick={onByePick}
        />
      )}
      {modal?.kind === "legbye" && (
        <ExtraPickerModal
          title="Leg Byes"
          subtitle="Runs scored off the pad"
          options={[1, 2, 3, 4]}
          onCancel={() => setModal(null)}
          onPick={onLegByePick}
        />
      )}
      {modal?.kind === "overthrow" && (
        <ExtraPickerModal
          title="Overthrow"
          subtitle={`Last ball batsman: ${modal.batsmanRuns} • extra runs from overthrow`}
          options={[1, 2, 3, 4]}
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
  children,
}: {
  match: MatchPayload;
  innings?: Innings;
  maxOvers?: number;
  nameOf?: (id: string | null | undefined) => string;
  nextOver?: number;
  nextBall?: number;
  onSignOut: () => void;
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
        <button
          onClick={onSignOut}
          className="text-[11px] text-neutral-600 underline shrink-0 ml-3"
        >
          Sign out
        </button>
      </header>

      {innings && (
        <ScoreStrip
          match={match}
          innings={innings}
          maxOvers={maxOvers ?? 20}
          nextOver={nextOver ?? 0}
          nextBall={nextBall ?? 1}
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
}: {
  match: MatchPayload;
  innings: Innings;
  maxOvers: number;
  nextOver: number;
  nextBall: number;
}) {
  const teamName =
    innings.battingTeam === "A" ? match.teamAName : match.teamBName;
  const oversFloat = nextOver + (nextBall - 1) / 6;
  const crr = oversFloat > 0 ? innings.totalRuns / oversFloat : null;
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
        <div className="text-base font-extrabold text-neutral-900 tabular-nums">
          {innings.totalRuns}
          <span className="text-neutral-400">/</span>
          {innings.totalWickets}
        </div>
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
  onUndo: () => void;
}) {
  return (
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

      <PadBtn label="Bye" busy={busy} onClick={onBye} />
      <PadBtn label="Leg Bye" busy={busy} onClick={onLegBye} />
      <PadBtn label="Wicket" danger busy={busy} onClick={onWicket} />
      <PadBtn
        label="Undo"
        muted
        busy={busy}
        disabled={!canUndo}
        onClick={onUndo}
      />
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
}: {
  zone: WagonZone | null;
  onCancel: () => void;
  onPick: (runs: number) => void;
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
      <div className="grid grid-cols-3 gap-2">
        {[0, 1, 2, 3, 4, 6].map((n) => (
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
