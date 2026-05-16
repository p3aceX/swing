import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'ball_event.dart';
import 'match_feed.dart';
import 'match_state.dart';

/// Drives an exciting T20 chase using scripted weights — looks like a real
/// match. Plays one ball every [tickInterval] and emits events. Implements
/// [MatchFeed] so the overlay widgets are agnostic to whether they're
/// looking at demo data or backend SSE data.
class DummyMatchRunner implements MatchFeed {
  DummyMatchRunner({this.tickInterval = const Duration(milliseconds: 3500)});

  final Duration tickInterval;
  final _rng = Random();
  Timer? _timer;

  // ── Initial state ─────────────────────────────────────────────────────
  static const _teamIndia = TeamMeta(
    shortCode: 'IND',
    fullName: 'INDIA',
    accentColor: 0xFF0B6FF0,
  );
  static const _teamAus = TeamMeta(
    shortCode: 'AUS',
    fullName: 'AUSTRALIA',
    accentColor: 0xFFFFD60A,
  );

  static MatchState initialState() {
    // Demo starts at 10.0 overs (mid-innings) so there's enough runway for
    // a believable mix of fours, sixes, dots, and AT LEAST a wicket or
    // two before the match ends. Earlier in the chase = longer demo loop.
    return const MatchState(
      teamA: _teamIndia,
      teamB: _teamAus,
      groundName: 'WANKHEDE STADIUM, MUMBAI',
      matchLabel: '1st T20I',
      battingSide: InningsSide.teamA,
      score: 75,
      wickets: 1,
      balls: 60, // 10.0 overs
      target: 187,
      striker: BatterSnapshot(
        name: 'R. SHARMA',
        runs: 42,
        ballsFaced: 28,
        fours: 4,
        sixes: 1,
      ),
      nonStriker: BatterSnapshot(
        name: 'V. KOHLI',
        runs: 18,
        ballsFaced: 14,
        fours: 1,
        sixes: 0,
      ),
      bowler: BowlerSnapshot(
        name: 'M. STARC',
        legalBallsBowled: 12, // 2 overs
        maidens: 0,
        runsConceded: 18,
        wickets: 1,
      ),
      currentOver: [
        BallOutcome(
          runsFromBat: 1,
          extras: 0,
          extraKind: null,
          isWicket: false,
          isBoundary: false,
          isSix: false,
          wasLegal: true,
        ),
        BallOutcome(
          runsFromBat: 4,
          extras: 0,
          extraKind: null,
          isWicket: false,
          isBoundary: true,
          isSix: false,
          wasLegal: true,
        ),
        BallOutcome(
          runsFromBat: 0,
          extras: 0,
          extraKind: null,
          isWicket: false,
          isBoundary: false,
          isSix: false,
          wasLegal: true,
        ),
      ],
      phase: MatchPhase.death,
      winner: null,
    );
  }

  @override
  final ValueNotifier<MatchState> state =
      ValueNotifier<MatchState>(initialState());

  // Broadcast so multiple widgets (scorebar today, event flashes tomorrow)
  // can subscribe independently.
  final _eventsCtrl = StreamController<OverlayEvent>.broadcast();
  @override
  Stream<OverlayEvent> get events => _eventsCtrl.stream;

  @override
  final ValueNotifier<MatchFeedStatus> status =
      ValueNotifier<MatchFeedStatus>(MatchFeedStatus.demo);

  @override
  void start() {
    _timer ??=
        Timer.periodic(tickInterval, (_) => _stepOneBall());
  }

  @override
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    stop();
    _eventsCtrl.close();
    state.dispose();
    status.dispose();
  }

  // ── Simulation loop ───────────────────────────────────────────────────
  void _stepOneBall() {
    final s = state.value;
    if (s.phase == MatchPhase.ended || s.phase == MatchPhase.inningsBreak) {
      // Demo loop: reset to opening state after 6 seconds idle.
      Future.delayed(const Duration(seconds: 6), () {
        state.value = initialState();
      });
      return;
    }

    final outcome = _rollBall(s);
    final isLegal = outcome.wasLegal;

    // Score & wickets.
    final newScore = s.score + outcome.totalRuns;
    final newWickets = s.wickets + (outcome.isWicket ? 1 : 0);
    final newBalls = s.balls + (isLegal ? 1 : 0);

    // Striker / non-striker update.
    var striker = s.striker;
    var nonStriker = s.nonStriker;
    BatterSnapshot? dismissed; // captured before replacement for the flash
    if (!outcome.isWicket) {
      striker = BatterSnapshot(
        name: striker.name,
        runs: striker.runs + outcome.runsFromBat,
        ballsFaced: striker.ballsFaced + (isLegal ? 1 : 0),
        fours: striker.fours + (outcome.isBoundary ? 1 : 0),
        sixes: striker.sixes + (outcome.isSix ? 1 : 0),
      );
    } else {
      // Capture for the event before swapping in the next batter.
      dismissed = striker;
      striker = _nextBatter(newWickets);
    }

    // Strike rotation: odd runs (off the bat, on a legal ball) → swap.
    final shouldRotate =
        isLegal && !outcome.isWicket && (outcome.runsFromBat % 2 == 1);
    if (shouldRotate) {
      final tmp = striker;
      striker = nonStriker;
      nonStriker = tmp;
    }

    // Bowler update.
    final newBowler = BowlerSnapshot(
      name: s.bowler.name,
      legalBallsBowled: s.bowler.legalBallsBowled + (isLegal ? 1 : 0),
      maidens: s.bowler.maidens,
      runsConceded: s.bowler.runsConceded + outcome.totalRuns,
      wickets: s.bowler.wickets + (outcome.isWicket ? 1 : 0),
    );

    // Over rollover.
    final isOverEnd = isLegal && (newBalls % 6 == 0);
    final newCurrentOver = isOverEnd
        ? <BallOutcome>[]
        : (List<BallOutcome>.from(s.currentOver)..add(outcome));
    if (isOverEnd) {
      // At over end, swap strike again and rotate bowler.
      final tmp = striker;
      striker = nonStriker;
      nonStriker = tmp;
    }

    final newPhase = _decidePhase(s, newBalls, newWickets, newScore);

    // Match end check (chasing innings only — we don't simulate 1st innings).
    WinnerCard? winner;
    var endedNow = false;
    final target = s.target;
    if (target != null) {
      if (newScore >= target) {
        winner = WinnerCard(
          winner: s.battingTeam,
          marginText:
              'WON BY ${10 - newWickets} WICKETS · ${s.ballsRemaining - (isLegal ? 1 : 0)} BALLS LEFT',
          potm: striker.name,
        );
        endedNow = true;
      } else if (newWickets >= 10 || newBalls >= s.matchTotalBalls) {
        final margin = target - 1 - newScore;
        winner = WinnerCard(
          winner: s.bowlingTeam,
          marginText: 'WON BY $margin RUNS',
          potm: s.bowler.name,
        );
        endedNow = true;
      }
    }

    state.value = s.copyWith(
      score: newScore,
      wickets: newWickets,
      balls: newBalls,
      striker: striker,
      nonStriker: nonStriker,
      bowler: isOverEnd ? _nextBowler(s.bowler) : newBowler,
      currentOver: newCurrentOver,
      phase: endedNow ? MatchPhase.ended : newPhase,
      winner: winner,
    );

    _eventsCtrl.add(BallLanded(outcome));
    if (dismissed != null) {
      _eventsCtrl.add(WicketTaken(
        dismissed: dismissed,
        dismissalMethod: _randomDismissalMethod(s.bowler.name),
        bowlerName: s.bowler.name,
      ));
    }
    if (shouldRotate) _eventsCtrl.add(const StrikeRotated());
    if (isOverEnd) {
      final overNumber = newBalls ~/ 6;
      final overBalls = List<BallOutcome>.from(s.currentOver)..add(outcome);
      _eventsCtrl.add(OverEnded(
        balls: overBalls,
        runs: overBalls.fold<int>(0, (a, b) => a + b.totalRuns),
        wickets: overBalls.where((b) => b.isWicket).length,
        bowlerName: s.bowler.name,
        overNumber: overNumber,
      ));
    }
    if (endedNow && winner != null) _eventsCtrl.add(MatchEnded(winner));
  }

  // ── Outcome distribution ──────────────────────────────────────────────
  // Weighting tuned for review demos — more boundaries and wickets than a
  // realistic match so the producer sees each flash within a minute.
  // Switch back to the realistic 0.05–0.08 wicket rate before shipping.
  BallOutcome _rollBall(MatchState s) {
    final r = _rng.nextDouble();
    final isDeath = (s.balls ~/ 6) >= 16;

    // wicket — bumped for demo visibility
    if (r < (isDeath ? 0.15 : 0.12)) {
      return const BallOutcome(
        runsFromBat: 0,
        extras: 0,
        extraKind: null,
        isWicket: true,
        isBoundary: false,
        isSix: false,
        wasLegal: true,
      );
    }
    // six
    if (r < (isDeath ? 0.20 : 0.10)) {
      return const BallOutcome(
        runsFromBat: 6,
        extras: 0,
        extraKind: null,
        isWicket: false,
        isBoundary: false,
        isSix: true,
        wasLegal: true,
      );
    }
    // four
    if (r < (isDeath ? 0.36 : 0.22)) {
      return const BallOutcome(
        runsFromBat: 4,
        extras: 0,
        extraKind: null,
        isWicket: false,
        isBoundary: true,
        isSix: false,
        wasLegal: true,
      );
    }
    // wide
    if (r < (isDeath ? 0.40 : 0.27)) {
      return const BallOutcome(
        runsFromBat: 0,
        extras: 1,
        extraKind: ExtraKind.wide,
        isWicket: false,
        isBoundary: false,
        isSix: false,
        wasLegal: false,
      );
    }
    // dot
    if (r < (isDeath ? 0.55 : 0.50)) {
      return const BallOutcome(
        runsFromBat: 0,
        extras: 0,
        extraKind: null,
        isWicket: false,
        isBoundary: false,
        isSix: false,
        wasLegal: true,
      );
    }
    // 2 runs
    if (r < (isDeath ? 0.70 : 0.65)) {
      return const BallOutcome(
        runsFromBat: 2,
        extras: 0,
        extraKind: null,
        isWicket: false,
        isBoundary: false,
        isSix: false,
        wasLegal: true,
      );
    }
    // 1 run — most common
    return const BallOutcome(
      runsFromBat: 1,
      extras: 0,
      extraKind: null,
      isWicket: false,
      isBoundary: false,
      isSix: false,
      wasLegal: true,
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────
  static const _nextBatters = [
    BatterSnapshot(name: 'S. YADAV', runs: 0, ballsFaced: 0, fours: 0, sixes: 0),
    BatterSnapshot(name: 'H. PANDYA', runs: 0, ballsFaced: 0, fours: 0, sixes: 0),
    BatterSnapshot(name: 'R. JADEJA', runs: 0, ballsFaced: 0, fours: 0, sixes: 0),
    BatterSnapshot(name: 'A. PATEL',  runs: 0, ballsFaced: 0, fours: 0, sixes: 0),
    BatterSnapshot(name: 'M. SHAMI',  runs: 0, ballsFaced: 0, fours: 0, sixes: 0),
    BatterSnapshot(name: 'K. YADAV',  runs: 0, ballsFaced: 0, fours: 0, sixes: 0),
    BatterSnapshot(name: 'J. BUMRAH', runs: 0, ballsFaced: 0, fours: 0, sixes: 0),
  ];

  BatterSnapshot _nextBatter(int wicketsFallen) {
    // 0 and 1 are the openers (already on the field). After the 2nd wicket
    // we draw from the queue. Bounds-safe.
    final idx = (wicketsFallen - 2).clamp(0, _nextBatters.length - 1);
    return _nextBatters[idx];
  }

  static const _nextBowlers = [
    BowlerSnapshot(name: 'P. CUMMINS', legalBallsBowled: 0, maidens: 0, runsConceded: 0, wickets: 0),
    BowlerSnapshot(name: 'A. ZAMPA',   legalBallsBowled: 0, maidens: 0, runsConceded: 0, wickets: 0),
    BowlerSnapshot(name: 'J. HAZLEWOOD', legalBallsBowled: 0, maidens: 0, runsConceded: 0, wickets: 0),
    BowlerSnapshot(name: 'G. MAXWELL', legalBallsBowled: 0, maidens: 0, runsConceded: 0, wickets: 0),
  ];

  String _randomDismissalMethod(String bowler) {
    final pick = _rng.nextInt(4);
    switch (pick) {
      case 0: return 'B ${_short(bowler)}';
      case 1: return 'C STARC B ${_short(bowler)}';
      case 2: return 'LBW B ${_short(bowler)}';
      default: return 'C & B ${_short(bowler)}';
    }
  }

  static String _short(String name) {
    // "M. STARC" → "STARC"
    final parts = name.split(' ');
    return parts.last;
  }

  BowlerSnapshot _nextBowler(BowlerSnapshot current) {
    final i = _nextBowlers.indexWhere((b) => b.name == current.name);
    final next = i < 0 ? 0 : (i + 1) % _nextBowlers.length;
    return _nextBowlers[next];
  }

  MatchPhase _decidePhase(MatchState s, int newBalls, int newWickets, int newScore) {
    if (newBalls < 36) return MatchPhase.powerplay;
    if (newBalls < 96) return MatchPhase.middle;
    return MatchPhase.death;
  }
}
