import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../repositories/host_match_repository.dart';
import '../../../theme/host_colors.dart';
import '../../match_detail/presentation/match_detail_screen.dart';
import '../../playing_eleven/presentation/playing_eleven_screen.dart';
import '../controller/scoring_controller.dart';
import '../domain/scoring_models.dart';
import '../domain/scoring_rules.dart';
import 'player_picker_sheet.dart';
import 'scoring_widgets.dart';
import 'wicket_sheet.dart';

class ScoringScreen extends ConsumerStatefulWidget {
  const ScoringScreen({
    super.key,
    required this.matchId,
    this.currentPlayerId,
    this.onNavigateBack,
    this.onNavigateToMatchDetail,
    this.onNavigateToPlaying11,
    this.onNavigateToToss,
    this.onMatchDeleted,
    this.onEditMatch,
    this.teamAName = 'Team A',
    this.teamBName = 'Team B',
  });

  final String matchId;
  final String? currentPlayerId;
  final void Function(BuildContext context, String matchId)? onNavigateBack;
  final void Function(BuildContext context, String matchId)?
      onNavigateToMatchDetail;
  final void Function(
    BuildContext context,
    String matchId,
    String teamAId,
    String teamAName,
    String teamBId,
    String teamBName,
  )? onNavigateToPlaying11;
  /// Called when the match has no toss recorded yet. Host supplies the
  /// animated TossScreen from the shared package.
  final void Function(
    BuildContext context,
    String matchId,
    String teamAName,
    String teamBName,
  )? onNavigateToToss;
  final String teamAName;
  final String teamBName;
  final void Function(BuildContext context, String matchId)? onMatchDeleted;
  /// Open the create-match form pre-populated with this match. Hosts use this
  /// to let the scorer fix overs / format / lineup / venue from the pre-toss
  /// review card. When null, no Edit button is rendered.
  final void Function(
    BuildContext context,
    String matchId,
    String teamAName,
    String teamBName,
  )? onEditMatch;

  @override
  ConsumerState<ScoringScreen> createState() => _ScoringScreenState();
}

class _ScoringScreenState extends ConsumerState<ScoringScreen> {
  HostScoringController get _ctrl =>
      ref.read(hostScoringControllerProvider(widget.matchId).notifier);

  // Snapshot the over number and current bowler before recording a ball so we
  // can detect a completed over and exclude the just-finished bowler correctly.
  int _prevOverNumber = -1;
  String _prevBowlerId = '';
  void _snapshotOver() {
    final s = ref.read(hostScoringControllerProvider(widget.matchId));
    _prevOverNumber = s.activeInnings?.overNumber ?? -1;
    _prevBowlerId = s.effectiveBowlerId;
  }

  // ─── Player pickers ────────────────────────────────────────────────────────

  Future<void> _pickPlayer({
    required String title,
    required List<ScoringMatchPlayer> players,
    required void Function(ScoringMatchPlayer) onPicked,
  }) async {
    if (players.isEmpty) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlayerPickerSheet(
        title: title,
        players: players,
        onSearchExternal: _ctrl.searchPlayers,
        onSelected: (player) {
          Navigator.pop(context);
          onPicked(player);
        },
      ),
    );
  }

  Future<void> _pickSetup(HostScoringState state) async {
    final match = state.match;
    final players = state.players;
    final innings = state.activeInnings;
    if (match == null || players == null || innings == null) return;
    final batting = players.forSide(innings.battingTeam);
    final bowling = players.forSide(match.bowlingTeam ?? 'B');

    if (state.effectiveStrikerId.isEmpty) {
      await _pickPlayer(
        title: 'Select Striker',
        players: batting,
        onPicked: (p) => _ctrl.setNewBatter(p.profileId),
      );
      return;
    }
    if (state.effectiveNonStrikerId.isEmpty) {
      await _pickPlayer(
        title: 'Select Non-Striker',
        players: batting
            .where((p) => !p.matchesId(state.effectiveStrikerId))
            .toList(),
        onPicked: (p) => _ctrl.setNonStriker(p.profileId),
      );
      return;
    }
    if (state.effectiveBowlerId.isEmpty) {
      await _pickPlayer(
        title: 'Select Bowler',
        players: bowling,
        onPicked: (p) => _ctrl.setBowler(p.profileId),
      );
    }
  }

  Set<String> _dismissedIds(HostScoringState state) {
    final players = state.players;
    return state.balls
        .where((b) => b.isWicket && b.dismissalType != 'RETIRED_HURT')
        .map((b) {
          // Use dismissedPlayerId if present (catches non-striker run-outs),
          // fall back to batterId (the batter facing the ball).
          final id = b.dismissedPlayerId ?? b.batterId;
          return players?.normalizeId(id) ?? id ?? '';
        })
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  Future<void> _pickStriker(HostScoringState state) async {
    final players = state.players;
    final innings = state.activeInnings;
    if (players == null || innings == null) return;
    final dismissed = _dismissedIds(state);
    final nonStrikerId = state.effectiveNonStrikerId;
    final eligible = players
        .forSide(innings.battingTeam)
        .where((p) =>
            !dismissed.contains(p.profileId) &&
            !p.matchesId(nonStrikerId))
        .toList();
    await _pickPlayer(
      title: 'Select New Batter',
      players: eligible,
      onPicked: (p) => _ctrl.setNewBatter(p.profileId),
    );
  }

  Future<void> _pickNonStriker(HostScoringState state) async {
    final players = state.players;
    final innings = state.activeInnings;
    if (players == null || innings == null) return;
    final dismissed = _dismissedIds(state);
    final eligible = players
        .forSide(innings.battingTeam)
        .where((p) =>
            !dismissed.contains(p.profileId) &&
            !p.matchesId(state.effectiveStrikerId))
        .toList();
    await _pickPlayer(
      title: 'Select Non-Striker',
      players: eligible,
      onPicked: (p) => _ctrl.setNonStriker(p.profileId),
    );
  }

  Future<void> _pickBowler(
    HostScoringState state, {
    bool excludeLastBowler = false,
  }) async {
    final match = state.match;
    final players = state.players;
    if (match == null || players == null) return;
    final bowlingSide = match.bowlingTeam ?? 'B';
    final keeperId = bowlingSide == 'A'
        ? players.teamAWicketKeeperId
        : players.teamBWicketKeeperId;
    final lastBowlerId = excludeLastBowler ? _prevBowlerId : '';
    final eligible = players
        .forSide(bowlingSide)
        .where((p) => lastBowlerId.isEmpty || !p.matchesId(lastBowlerId))
        .toList();
    await _pickPlayer(
      title: 'Select Bowler',
      players: eligible,
      onPicked: (p) async {
        _ctrl.setBowler(p.profileId);
        // A player can either be the wicket-keeper OR be bowling, never both
        // simultaneously. If the picked bowler is the current WK, force a
        // fresh WK pick (excluding the bowler) before scoring resumes.
        if (keeperId != null && p.matchesId(keeperId) && mounted) {
          await _pickReplacementKeeper(
            bowlingSide: bowlingSide,
            excludePlayerId: p.profileId,
          );
        }
      },
    );
  }

  Future<void> _pickReplacementKeeper({
    required String bowlingSide,
    required String excludePlayerId,
  }) async {
    final state = ref.read(hostScoringControllerProvider(widget.matchId));
    final players = state.players;
    if (players == null) return;
    final candidates = players
        .forSide(bowlingSide)
        .where((p) => !p.matchesId(excludePlayerId))
        .toList();
    if (candidates.isEmpty) return;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bowler can\'t also be wicket-keeper — pick a new WK'),
          duration: Duration(seconds: 3),
        ),
      );
    }
    await _pickPlayer(
      title: 'Select Wicket-Keeper',
      players: candidates,
      onPicked: (wk) =>
          _ctrl.changeWicketKeeper(bowlingSide, wk.profileId),
    );
  }

  // ─── Wicket-keeper change ──────────────────────────────────────────────────

  Future<void> _changeWicketKeeper(HostScoringState state) async {
    final match = state.match;
    final players = state.players;
    final innings = state.activeInnings;
    if (match == null || players == null || innings == null) return;
    final bowlingSide = match.bowlingTeam ?? 'B';
    final eligible = players.forSide(bowlingSide);
    await _pickPlayer(
      title: 'Change Wicket-Keeper',
      players: eligible,
      onPicked: (p) => _ctrl.changeWicketKeeper(bowlingSide, p.profileId),
    );
  }

  // ─── Post-ball auto-prompts ─────────────────────────────────────────────────

  bool _overTurned(HostScoringState s) {
    final cur = s.activeInnings?.overNumber ?? -1;
    return _prevOverNumber >= 0 && cur > _prevOverNumber;
  }

  Future<void> _afterBall() async {
    if (!mounted) return;
    final s = ref.read(hostScoringControllerProvider(widget.matchId));
    if (s.isLoading || s.isSubmitting) return;
    if (s.match?.isComplete ?? true) return;
    if (s.activeInnings == null) return;
    if (s.inningsOver) {
      await _showEndOfInningsSheet(s);
      return;
    }
    if (_overTurned(s)) await _pickBowler(s, excludeLastBowler: true);
  }

  Future<void> _afterWicket() async {
    if (!mounted) return;
    final s = ref.read(hostScoringControllerProvider(widget.matchId));
    if (s.isLoading || s.isSubmitting) return;
    if (s.match?.isComplete ?? true) return;
    final inn = s.activeInnings;
    if (inn == null || inn.isCompleted) return;
    if (s.inningsOver) {
      await _showEndOfInningsSheet(s);
      return;
    }
    // Pick the player that was actually dismissed.
    // After _init(), the dismissed player's slot will be empty in server state.
    if (inn.totalWickets < 10) {
      if (s.effectiveStrikerId.isEmpty) {
        await _pickStriker(s);
      } else if (s.effectiveNonStrikerId.isEmpty) {
        await _pickNonStriker(s);
      }
    }
    if (!mounted) return;
    final s2 = ref.read(hostScoringControllerProvider(widget.matchId));
    if (_overTurned(s2)) await _pickBowler(s2, excludeLastBowler: true);
  }

  // ─── End of innings ────────────────────────────────────────────────────────

  Future<void> _autoSetupNewInnings() async {
    if (!mounted) return;
    final s = ref.read(hostScoringControllerProvider(widget.matchId));
    debugPrint('[autoSetup] innings=${s.activeInnings?.inningsNumber} players=${s.players != null}');
    if (s.activeInnings == null || s.players == null) {
      debugPrint('[autoSetup] skipped — no innings or players');
      return;
    }
    debugPrint('[autoSetup] picking striker…');
    await _pickStriker(s);
    if (!mounted) return;
    final s2 = ref.read(hostScoringControllerProvider(widget.matchId));
    debugPrint('[autoSetup] picking non-striker… striker=${s2.effectiveStrikerId}');
    await _pickNonStriker(s2);
    if (!mounted) return;
    final s3 = ref.read(hostScoringControllerProvider(widget.matchId));
    debugPrint('[autoSetup] picking bowler… nonStriker=${s3.effectiveNonStrikerId}');
    await _pickBowler(s3);
    debugPrint('[autoSetup] done');
  }

  // Returns (winnerSide, winMargin). winnerSide is 'A', 'B', or '' for a tie.
  (String, String?) _calcWinner(ScoringMatch match) {
    final sorted = [...match.innings]..sort((a, b) => a.inningsNumber.compareTo(b.inningsNumber));
    if (sorted.length < 2) return ('', null);
    final inn1 = sorted[0];
    final inn2 = sorted[1];
    final diff = inn2.totalRuns - inn1.totalRuns;
    if (diff > 0) {
      final wickets = 10 - inn2.totalWickets;
      return (inn2.battingTeam, '$wickets wicket${wickets != 1 ? "s" : ""}');
    } else if (diff < 0) {
      final runs = inn1.totalRuns - inn2.totalRuns;
      return (inn1.battingTeam, '$runs run${runs != 1 ? "s" : ""}');
    }
    return ('', null); // tie
  }

  String _resolveWinnerId(ScoringMatch match, String winnerSide) {
    if (winnerSide == 'A') {
      final id = (match.teamAId ?? '').trim();
      return id.isNotEmpty ? id : 'A';
    }
    if (winnerSide == 'B') {
      final id = (match.teamBId ?? '').trim();
      return id.isNotEmpty ? id : 'B';
    }
    return winnerSide;
  }

  bool _canStartNextInnings(ScoringMatch match, ScoringInnings inn) {
    if (match.isMultiInnings) return match.innings.length < 4;
    return inn.inningsNumber < 2;
  }

  Future<void> _showEndOfInningsSheet(HostScoringState state) async {
    if (!mounted) return;
    final match = state.match;
    final inn = state.activeInnings;
    if (match == null || inn == null) return;

    final canStartNext = _canStartNextInnings(match, inn);

    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EndOfInningsSheet(
        match: match,
        innings: inn,
        canStartNextInnings: canStartNext,
        onManageScorer: () {
          Navigator.pop(ctx);
          final s = ref.read(hostScoringControllerProvider(widget.matchId));
          _openScorerSheetFromScreen(s);
        },
        onEndMatch: () async {
          Navigator.pop(ctx);
          final before = ref.read(hostScoringControllerProvider(widget.matchId));
          final activeInn = before.activeInnings;
          print('[onEndMatch] matchId=${widget.matchId} activeInn=${activeInn?.inningsNumber} isCompleted=${activeInn?.isCompleted} matchComplete=${before.match?.isComplete}');
          print('[onEndMatch] innings count=${before.match?.innings.length} innings=${before.match?.innings.map((i) => "inn${i.inningsNumber}:${i.totalRuns}/${i.totalWickets}(completed=${i.isCompleted})").join(", ")}');
          if (activeInn?.isCompleted == false) {
            print('[onEndMatch] calling completeInnings first');
            final ok = await _ctrl.completeInnings();
            if (!ok || !mounted) {
              print('[onEndMatch] completeInnings failed, aborting');
              return;
            }
          }
          // Re-read state after completeInnings so _calcWinner sees updated totals
          final after = ref.read(hostScoringControllerProvider(widget.matchId));
          final freshMatch = after.match ?? match;
          print('[onEndMatch] freshMatch innings=${freshMatch.innings.map((i) => "inn${i.inningsNumber}:${i.totalRuns}/${i.totalWickets}").join(", ")}');
          final (winnerSide, winMargin) = _calcWinner(freshMatch);
          final winnerId = _resolveWinnerId(freshMatch, winnerSide);
          print(
            '[onEndMatch] calling completeMatch winnerSide="$winnerSide" '
            'winnerId="$winnerId" teamAId="${freshMatch.teamAId}" '
            'teamBId="${freshMatch.teamBId}" winMargin="$winMargin"',
          );
          final ok = await _ctrl.completeMatch(winnerId, winMargin);
          if (!mounted || !ok) return;
          if (widget.onNavigateBack != null) {
            widget.onNavigateBack!(context, widget.matchId);
          } else {
            Navigator.of(context).maybePop();
          }
        },
        onStartNextInnings: () async {
          Navigator.pop(ctx);
          final currentInningsNumber = inn.inningsNumber;

          // Complete the innings if the server hasn't done it yet
          final before = ref.read(hostScoringControllerProvider(widget.matchId));
          if (before.activeInnings?.isCompleted == false) {
            final ok = await _ctrl.completeInnings();
            if (!ok || !mounted) return;
          }

          // After completeInnings(), _init() runs and refreshes state.
          // If the server auto-created the next innings, it's already active —
          // calling continueInnings() again would throw "already exists".
          final after = ref.read(hostScoringControllerProvider(widget.matchId));
          final nextAlreadyExists =
              (after.activeInnings?.inningsNumber ?? 0) > currentInningsNumber;
          if (!nextAlreadyExists) {
            final ok = await _ctrl.continueInnings();
            if (!ok || !mounted) return;
          }

          await _autoSetupNewInnings();
        },
        onUndo: () async {
          Navigator.pop(ctx);
          final ok = await _ctrl.undoLastBall();
          if (!ok && mounted) {
            // Server rejected the undo (e.g. 503) — re-show so user can retry
            final s = ref.read(hostScoringControllerProvider(widget.matchId));
            if (s.inningsOver) await _showEndOfInningsSheet(s);
          }
        },
      ),
    );
  }

  // ─── Scoring pad modal ─────────────────────────────────────────────────────

  // ─── Overthrow sheet ───────────────────────────────────────────────────────

  Future<void> _addOverthrowToLastBall(int batsmanRuns, int overthrowRuns) async {
    final undone = await _ctrl.undoLastBall();
    if (!undone || !mounted) return;
    final total = batsmanRuns + overthrowRuns;
    const outcomes = {
      0: 'DOT', 1: 'SINGLE', 2: 'DOUBLE', 3: 'TRIPLE',
      4: 'FOUR', 5: 'FIVE', 6: 'SIX',
    };
    _snapshotOver();
    final ok = await _ctrl.recordBall(
      outcome: outcomes[total.clamp(0, 6)] ?? 'SINGLE',
      runs: total,
      extras: 0,
      isOverthrow: true,
      overthrowRuns: overthrowRuns,
    );
    if (ok && mounted) await _afterBall();
  }

  void _showOverthrowSheet() {
    if (!mounted) return;
    final s = ref.read(hostScoringControllerProvider(widget.matchId));
    if (s.balls.isEmpty) return;
    final batsmanRuns = s.balls.last.runs;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _OverthrowPicker(
        batsmanRuns: batsmanRuns,
        onConfirm: (overthrowRuns) {
          Navigator.pop(ctx);
          _addOverthrowToLastBall(batsmanRuns, overthrowRuns);
        },
      ),
    );
  }

  void _showScoringPad() {
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _ScoringPadSheet(
        matchId: widget.matchId,
        onRun: _recordRun,
      ),
    );
  }

  // ─── Extra selector ────────────────────────────────────────────────────────

  Future<void> _showExtraSelector({
    required String title,
    required void Function(int value) onConfirm,
    List<int> options = const [1, 2, 3, 4, 5],
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SafeArea(
        child: Container(
          color: context.cardBg,
          padding: const EdgeInsets.all(20),
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  title,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: options
                    .map(
                      (v) => FilledButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onConfirm(v);
                        },
                        child: Text('$v'),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Wicket sheet ──────────────────────────────────────────────────────────

  Future<void> _showWicketSheet(HostScoringState state) async {
    final players = state.players;
    final match = state.match;
    if (players == null || match == null) return;
    final bowlingSide = match.bowlingTeam ?? 'B';
    final keeperId = bowlingSide == 'A'
        ? players.teamAWicketKeeperId
        : players.teamBWicketKeeperId;

    // Capture result synchronously — recordBall runs after sheet closes so
    // isSubmitting is false when _afterWicket checks state.
    ({
      String dismissalType,
      String deliveryType,
      String? fielderId,
      bool dismissedIsStriker,
      int completedRuns,
    })? result;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WicketSheet(
        strikerName: state.striker(players)?.name ?? 'Striker',
        nonStrikerName: state.nonStriker(players)?.name ?? 'Non-Striker',
        fieldingTeam: players.forSide(bowlingSide),
        isFreeHit: state.isFreeHit,
        keeperId: keeperId,
        bowlerId: state.effectiveBowlerId.isNotEmpty
            ? state.effectiveBowlerId
            : null,
        onConfirm: ({
          required String dismissalType,
          required String deliveryType,
          String? fielderId,
          required bool dismissedIsStriker,
          required int completedRuns,
          bool crossed = false,
        }) {
          // Capture, then close — no async work here
          result = (
            dismissalType: dismissalType,
            deliveryType: deliveryType,
            fielderId: fielderId,
            dismissedIsStriker: dismissedIsStriker,
            completedRuns: completedRuns,
          );
          Navigator.pop(context);
        },
      ),
    );

    if (result == null || !mounted) return;

    final r = result!;
    final (outcome, extras) = switch (r.deliveryType) {
      'WIDE'    => ('WIDE',    1),
      'NO_BALL' => ('NO_BALL', 1),
      _         => ('WICKET',  0),
    };

    _snapshotOver();
    final ok = await _ctrl.recordBall(
      outcome: outcome,
      runs: r.completedRuns,
      extras: extras,
      isWicket: r.dismissalType != 'RETIRED_HURT',
      dismissalType: r.dismissalType,
      dismissedPlayerId: r.dismissedIsStriker
          ? state.effectiveStrikerId
          : state.effectiveNonStrikerId,
      fielderId: r.fielderId,
    );

    if (ok && mounted) await _afterWicket();
  }

  // ─── Ball recording ────────────────────────────────────────────────────────

  Future<void> _recordRun(int runs) async {
    const outcomes = {
      0: 'DOT',
      1: 'SINGLE',
      2: 'DOUBLE',
      3: 'TRIPLE',
      4: 'FOUR',
      5: 'FIVE',
      6: 'SIX',
    };
    _snapshotOver();
    final ok = await _ctrl.recordBall(
      outcome: outcomes[runs] ?? 'SINGLE',
      runs: runs,
      extras: 0,
    );
    if (ok && mounted) await _afterBall();
  }

  // ─── Current over balls ────────────────────────────────────────────────────

  List<ScoringBall> _currentOverBalls(HostScoringState state) {
    final balls = state.balls;
    final inn = state.activeInnings;
    if (balls.isEmpty) return const [];
    final ballInOver = inn?.ballInOver ?? 0;
    final overNumber = inn?.overNumber ?? 0;

    if (ballInOver == 0) {
      if (overNumber == 0) {
        // Match just started, no balls yet
        return const [];
      }
      // Over just completed — show the last completed over's balls (6 legal + extras)
      final result = <ScoringBall>[];
      int legal = 0;
      for (final ball in balls.reversed) {
        result.insert(0, ball);
        if (scoringDeliveryIsLegal(ball.outcome)) legal++;
        if (legal >= 6) break;
        if (result.length > 12) break;
      }
      return result;
    }

    // Mid-over: collect balls for current ballInOver legal deliveries
    final result = <ScoringBall>[];
    int legal = 0;
    for (final ball in balls.reversed) {
      result.insert(0, ball);
      if (scoringDeliveryIsLegal(ball.outcome)) legal++;
      if (legal >= ballInOver) break;
      if (result.length > 12) break;
    }
    return result;
  }

  /// Opens the Manage Scorer bottom sheet — same one used by the
  /// in-card "Manage scorer" entry. Hosts the Take over / Assign / Release
  /// actions. Available from the live scoring page header and the
  /// end-of-innings sheet so the owner can change scorer at any time.
  Future<void> _openScorerSheetFromScreen(HostScoringState state) async {
    final match = state.match;
    final players = state.players;
    if (match == null || players == null) return;
    final repo = ref.read(hostMatchRepositoryProvider);
    final me = (widget.currentPlayerId ?? '').trim();

    Future<void> assignById(String profileId, String label) async {
      if (profileId.trim().isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not identify profile')),
          );
        }
        return;
      }
      try {
        await repo.assignScorer(match.id, profileId.trim());
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label — done')),
        );
        await _ctrl.refresh();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not assign: $e')),
        );
      }
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Manage scorer',
                  style: TextStyle(
                    color: sheetCtx.fg,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Owner / manager only. Pick someone to record balls. '
                  'They\'ll keep the gloves until you change them again.',
                  style: TextStyle(
                    color: sheetCtx.fgSub,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () async {
                    Navigator.pop(sheetCtx);
                    await assignById(me, 'Take over');
                  },
                  icon: const Icon(Icons.person_pin_circle_rounded, size: 18),
                  label: const Text('Take over scoring'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(sheetCtx);
                    if (players.teamA.isEmpty && players.teamB.isEmpty) return;
                    final picked =
                        await Navigator.of(context).push<ScoringMatchPlayer>(
                      MaterialPageRoute(
                        builder: (_) => ScorerPickerScreen(
                          teamAName: match.teamAName,
                          teamBName: match.teamBName,
                          teamA: players.teamA,
                          teamB: players.teamB,
                          captainAId: players.teamACaptainId,
                          viceCaptainAId: players.teamAViceCaptainId,
                          wicketKeeperAId: players.teamAWicketKeeperId,
                          captainBId: players.teamBCaptainId,
                          viceCaptainBId: players.teamBViceCaptainId,
                          wicketKeeperBId: players.teamBWicketKeeperId,
                          currentScorerId: match.activeScorerId,
                        ),
                      ),
                    );
                    if (picked == null) return;
                    await assignById(picked.profileId,
                        'Assigned ${picked.name}');
                  },
                  icon: const Icon(Icons.person_add_alt_rounded, size: 18),
                  label: const Text('Assign someone else'),
                ),
                if ((match.activeScorerId ?? '').isNotEmpty) ...[
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () async {
                      Navigator.pop(sheetCtx);
                      try {
                        await repo.revokeScorer(match.id);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Scorer assignment cleared'),
                          ),
                        );
                        await _ctrl.refresh();
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not clear: $e')),
                        );
                      }
                    },
                    icon: const Icon(Icons.lock_open_rounded, size: 16),
                    label: const Text('Release control'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Mirrors the backend's authorizeMutation SCORER tier. The match owner,
  /// the assigned scorer, or a manager can record balls. Captains have no
  /// inherent rights — assignScorer is the only way to grant them write
  /// access. We default to true when we can't decide locally so the UI
  /// stays out of the way; the server is the authoritative gate.
  bool _userCanScore(HostScoringState state) {
    final me = (widget.currentPlayerId ?? '').trim();
    final match = state.match;
    if (me.isEmpty || match == null) return true;

    // Active assigned scorer.
    if ((match.activeScorerId ?? '').trim() == me) return true;
    // Legacy single-field scorer pointer (creator on older matches).
    if ((match.scorerId ?? '').trim() == me) return true;

    // We don't have role info on the scoring state, so we trust the
    // server. Render the buttons; if the API rejects the write, we
    // surface the error.
    return true;
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  void _handleBack() {
    debugPrint(
      '[ScoringScreen] back invoked — '
      'hasCallback=${widget.onNavigateBack != null} '
      'canPop=${Navigator.of(context).canPop()}',
    );
    if (widget.onNavigateBack != null) {
      widget.onNavigateBack!(context, widget.matchId);
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hostScoringControllerProvider(widget.matchId));
    final match = state.match;

    return PopScope(
      // Always intercept the system back so we can call _handleBack ourselves —
      // GoRouter `go`-routed pages have no Navigator stack to pop, so the
      // default system-back ends up doing nothing on this screen.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: _handleBack,
        ),
        title: Text(
          match == null
              ? 'Scoring'
              : '${match.teamAName} vs ${match.teamBName}',
        ),
        actions: [
          if (match != null)
            IconButton(
              icon: const Icon(Icons.manage_accounts_rounded),
              tooltip: 'Manage scorer',
              onPressed: state.isLoading
                  ? null
                  : () => _openScorerSheetFromScreen(state),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: state.isLoading ? null : _ctrl.refresh,
          ),
          IconButton(
            icon: const Icon(Icons.table_rows_rounded),
            onPressed: state.isLoading
                ? null
                : () {
                    if (match == null) return;
                    if (widget.onNavigateToMatchDetail != null) {
                      widget.onNavigateToMatchDetail!(context, widget.matchId);
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => HostMatchDetailScreen(
                          matchId: widget.matchId,
                        ),
                      ),
                    );
                  },
          ),
        ],
      ),
      body: state.isLoading && match == null
          ? const Center(child: CircularProgressIndicator())
          : match == null
              ? _ErrorBody(
                  error: state.error ?? 'Could not load match.',
                  onRetry: _ctrl.refresh,
                )
              : _ScoringBody(
                  matchId: widget.matchId,
                  state: state,
                  userCanScore: _userCanScore(state),
                  currentPlayerId: widget.currentPlayerId,
                  scorerRepo: ref.read(hostMatchRepositoryProvider),
                  onScorerChanged: () => _ctrl.refresh(),
                  currentOverBalls: _currentOverBalls(state),
                  onWheelZoneTap: (zone) {
                    final current = state.zone;
                    final next = current == zone ? null : zone;
                    _ctrl.setZone(next);
                    if (next != null) _showScoringPad();
                  },
                  onPickStriker: () => _pickStriker(state),
                  onPickNonStriker: () => _pickNonStriker(state),
                  onPickBowler: () => _pickBowler(state),
                  onPickSetup: () => _pickSetup(state),
                  onSwapBatters: state.canScore ? _ctrl.swapBatters : null,
                  onChangeBowler: () {
                    final s = ref.read(hostScoringControllerProvider(widget.matchId));
                    _pickBowler(s);
                  },
                  onChangeWicketKeeper: () {
                    final s = ref.read(hostScoringControllerProvider(widget.matchId));
                    _changeWicketKeeper(s);
                  },
                  onUndo: _ctrl.undoLastBall,
                  onStartMatch: () async {
                    final ok = await _ctrl.startMatch();
                    if (ok && mounted) await _autoSetupNewInnings();
                    return ok;
                  },
                  onUpdateMatchOvers: _ctrl.updateMatchOvers,
                  onUpdateMatchSchedule: _ctrl.updateMatchSchedule,
                  onContinueInnings: _ctrl.continueInnings,
                  onNavigateToToss: widget.onNavigateToToss != null
                      ? () {
                          print('[ScoringScreen] onNavigateToToss matchId=${widget.matchId} status=${match.status} tossWonBy=${match.tossWonBy} isComplete=${match.isComplete}');
                          widget.onNavigateToToss!(
                            context,
                            widget.matchId,
                            match.teamAName,
                            match.teamBName,
                          );
                        }
                      : null,
                  onNavigateToPlaying11: widget.onNavigateToPlaying11 != null
                      ? () => widget.onNavigateToPlaying11!(
                            context,
                            widget.matchId,
                            match.teamAId ?? '',
                            match.teamAName,
                            match.teamBId ?? '',
                            match.teamBName,
                          )
                      : null,
                  onEditMatch: widget.onEditMatch != null
                      ? () => widget.onEditMatch!(
                            context,
                            widget.matchId,
                            match.teamAName,
                            match.teamBName,
                          )
                      : null,
                  onDeleteMatch: widget.onMatchDeleted != null
                      ? () async {
                          await ref
                              .read(hostMatchRepositoryProvider)
                              .deleteMatch(widget.matchId);
                          if (mounted) {
                            widget.onMatchDeleted!(context, widget.matchId);
                          }
                        }
                      : null,
                  onDot: () => _recordRun(0),
                  onOverthrow: _showOverthrowSheet,
                  onWicket: () {
                    final s = ref.read(hostScoringControllerProvider(widget.matchId));
                    _showWicketSheet(s);
                  },
                  onWide: () => _showExtraSelector(
                    title: 'Wides',
                    onConfirm: (v) async {
                      _snapshotOver();
                      final ok = await _ctrl.recordBall(outcome: 'WIDE', runs: 0, extras: v);
                      if (ok && mounted) await _afterBall();
                    },
                  ),
                  onNoBall: () => _showExtraSelector(
                    title: 'Runs off bat (No Ball)',
                    options: const [0, 1, 2, 3, 4, 5, 6],
                    onConfirm: (v) async {
                      _snapshotOver();
                      final ok = await _ctrl.recordBall(outcome: 'NO_BALL', runs: v, extras: 1);
                      if (ok && mounted) await _afterBall();
                    },
                  ),
                  onBye: () => _showExtraSelector(
                    title: 'Bye runs',
                    onConfirm: (v) async {
                      _snapshotOver();
                      final ok = await _ctrl.recordBall(outcome: 'BYE', runs: 0, extras: v);
                      if (ok && mounted) await _afterBall();
                    },
                  ),
                  onLegBye: () => _showExtraSelector(
                    title: 'Leg bye runs',
                    onConfirm: (v) async {
                      _snapshotOver();
                      final ok = await _ctrl.recordBall(outcome: 'LEG_BYE', runs: 0, extras: v);
                      if (ok && mounted) await _afterBall();
                    },
                  ),
                  onEndInnings: () async {
                    final ok = await _ctrl.completeInnings();
                    if (!mounted || !ok) return false;
                    if (widget.onNavigateBack != null) {
                      widget.onNavigateBack!(context, widget.matchId);
                    } else {
                      Navigator.of(context).maybePop();
                    }
                    return true;
                  },
                ),
      ),
    );
  }
}

// ─── Scoring Body ─────────────────────────────────────────────────────────────

class _ScoringBody extends StatelessWidget {
  const _ScoringBody({
    required this.matchId,
    required this.state,
    required this.userCanScore,
    required this.currentPlayerId,
    required this.scorerRepo,
    required this.onScorerChanged,
    required this.currentOverBalls,
    required this.onWheelZoneTap,
    required this.onPickStriker,
    required this.onPickNonStriker,
    required this.onPickBowler,
    required this.onPickSetup,
    this.onSwapBatters,
    required this.onChangeBowler,
    this.onChangeWicketKeeper,
    required this.onUndo,
    required this.onStartMatch,
    required this.onUpdateMatchOvers,
    required this.onUpdateMatchSchedule,
    required this.onContinueInnings,
    this.onNavigateToToss,
    this.onNavigateToPlaying11,
    this.onEditMatch,
    this.onDeleteMatch,
    required this.onDot,
    required this.onOverthrow,
    required this.onWicket,
    required this.onWide,
    required this.onNoBall,
    required this.onBye,
    required this.onLegBye,
    required this.onEndInnings,
  });

  final String matchId;
  final HostScoringState state;
  final bool userCanScore;
  final String? currentPlayerId;
  final HostMatchRepository? scorerRepo;
  final VoidCallback? onScorerChanged;
  final List<ScoringBall> currentOverBalls;
  final void Function(String zone) onWheelZoneTap;
  final VoidCallback onPickStriker;
  final VoidCallback onPickNonStriker;
  final VoidCallback onPickBowler;
  final VoidCallback onPickSetup;
  final VoidCallback? onSwapBatters;
  final VoidCallback onChangeBowler;
  final VoidCallback? onChangeWicketKeeper;
  final Future<bool> Function() onUndo;
  final Future<bool> Function() onStartMatch;
  final Future<bool> Function(int overs) onUpdateMatchOvers;
  final Future<bool> Function(DateTime scheduledAt) onUpdateMatchSchedule;
  final Future<bool> Function() onContinueInnings;
  final VoidCallback? onNavigateToToss;
  final VoidCallback? onNavigateToPlaying11;
  final VoidCallback? onEditMatch;
  final Future<void> Function()? onDeleteMatch;
  final VoidCallback onDot;
  final VoidCallback onOverthrow;
  final VoidCallback onWicket;
  final VoidCallback onWide;
  final VoidCallback onNoBall;
  final VoidCallback onBye;
  final VoidCallback onLegBye;
  final Future<bool> Function() onEndInnings;

  @override
  Widget build(BuildContext context) {
    final match = state.match!;
    final innings = state.activeInnings;

    return ListView(
      children: [
        // ── Score strip + This over (only when innings active) ───────────────
        if (innings != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                _Pill(label: 'LIVE', color: const Color(0xFF374151)),
                const SizedBox(width: 8),
                _Pill(
                  label: 'INN ${innings.inningsNumber}',
                  color: const Color(0xFF78350F),
                ),
                const SizedBox(width: 12),
                Text(
                  innings.scoreDisplay,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${innings.overNumber}.${innings.ballInOver} / ${match.maxOvers} ov',
                  style: TextStyle(color: context.fgSub, fontSize: 13),
                ),
                if (state.toWin != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '• ${state.toWin} to win',
                    style: TextStyle(
                      color: context.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                Text(
                  'This over:',
                  style: TextStyle(
                      color: context.fgSub, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OverDotsRow(overBalls: currentOverBalls),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: context.stroke),
        ],

        if (state.error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              state.error!,
              style: TextStyle(color: context.danger, fontSize: 13),
            ),
          ),

        // ── Setup flows ──────────────────────────────────────────────────────
        if (innings == null) ...[
          const SizedBox(height: 16),
          _InactiveInningsSection(
            match: match,
            players: state.players,
            scorerRepo: scorerRepo,
            currentPlayerId: currentPlayerId,
            onScorerChanged: onScorerChanged,
            isSubmitting: state.isSubmitting,
            onStart: onStartMatch,
            onUpdateMatchOvers: onUpdateMatchOvers,
            onUpdateMatchSchedule: onUpdateMatchSchedule,
            onContinue: onContinueInnings,
            onNavigateToToss: onNavigateToToss,
            onNavigateToPlaying11: onNavigateToPlaying11,
            onEditMatch: onEditMatch,
            onDelete: onDeleteMatch,
          ),
          const SizedBox(height: 32),
        ] else if (!userCanScore) ...[
          // Live innings, but the caller isn't allowed to record balls
          // (e.g. captain of the bowling team). Show a read-only banner so
          // they understand why the score buttons are gone.
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.surf,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.stroke),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lock_outline_rounded,
                          size: 18, color: context.fgSub),
                      const SizedBox(width: 8),
                      Text(
                        'Scoring locked',
                        style: TextStyle(
                          color: context.fg,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Only the match owner or the assigned scorer can record '
                    'balls. Ask the owner to assign you via Manage Scorer if '
                    'you need to score.',
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ] else ...[
          // ── 3. Striker row ────────────────────────────────────────────────
          _BatterRow(matchId: matchId, isStriker: true, onTap: onPickStriker),
          // ── 4. Non-striker row ────────────────────────────────────────────
          _BatterRow(matchId: matchId, isStriker: false, onTap: onPickNonStriker),
          // ── 5. Bowler row ─────────────────────────────────────────────────
          Divider(height: 1, thickness: 1, color: context.stroke),
          _BowlerRow(matchId: matchId, onTap: onPickBowler),
          Divider(height: 1, thickness: 1, color: context.stroke),
          // ── 5b. Wicket-keeper row ────────────────────────────────────────
          if (onChangeWicketKeeper != null)
            _WicketKeeperRow(matchId: matchId, onTap: onChangeWicketKeeper!),
          if (onChangeWicketKeeper != null)
            Divider(height: 1, thickness: 1, color: context.stroke),

          // ── Free-hit banner ───────────────────────────────────────────────
          if (state.isFreeHit)
            Container(
              margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF14532D),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flash_on_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'FREE HIT',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),

          if (state.error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
              child: Text(
                state.error!,
                style: TextStyle(color: context.danger, fontSize: 12),
              ),
            ),

          // ── 6. Wagon wheel ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: RepaintBoundary(
              child: ScoringWagonWheel(
                selectedZone: state.zone,
                onZoneTap: onWheelZoneTap,
              ),
            ),
          ),
          if (state.zone != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Center(
                child: Text(
                  _zoneLabel(state.zone!),
                  style: TextStyle(
                    color: context.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          // ── Extras ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Row(
              children: [
                _ExtraChip(
                  label: 'Wide',
                  color: const Color(0xFF1E3A5F),
                  busy: state.isSubmitting,
                  onTap: onWide,
                ),
                const SizedBox(width: 6),
                _ExtraChip(
                  label: 'No Ball',
                  color: const Color(0xFF3B1F5E),
                  busy: state.isSubmitting,
                  onTap: onNoBall,
                ),
                const SizedBox(width: 6),
                _ExtraChip(
                  label: 'Bye',
                  color: const Color(0xFF1A3A2A),
                  busy: state.isSubmitting,
                  onTap: onBye,
                ),
                const SizedBox(width: 6),
                _ExtraChip(
                  label: 'Leg Bye',
                  color: const Color(0xFF1A3A2A),
                  busy: state.isSubmitting,
                  onTap: onLegBye,
                ),
              ],
            ),
          ),

          // ── Dot · Overthrow · Wicket ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _DotBtn(
                    busy: state.isSubmitting,
                    onTap: onDot,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 2,
                  child: _OverthrowBtn(
                    busy: state.isSubmitting,
                    onTap: onOverthrow,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 3,
                  child: _WicketBtn(
                    busy: state.isSubmitting,
                    onTap: onWicket,
                  ),
                ),
              ],
            ),
          ),

          // ── Actions: Swap · Change Bowler · Undo ─────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: _ActionBtn(
                    icon: Icons.swap_horiz_rounded,
                    label: 'Swap',
                    busy: state.isSubmitting,
                    onTap: onSwapBatters,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionBtn(
                    icon: Icons.sports_cricket_rounded,
                    label: 'Bowler',
                    busy: state.isSubmitting,
                    onTap: onChangeBowler,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionBtn(
                    icon: Icons.undo_rounded,
                    label: 'Undo',
                    busy: state.isSubmitting,
                    onTap: () => onUndo(),
                  ),
                ),
              ],
            ),
          ),

          // ── End Innings ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            child: SizedBox(
              height: 46,
              child: OutlinedButton.icon(
                onPressed: state.isSubmitting ? null : () => onEndInnings(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.danger,
                  side: BorderSide(color: context.danger.withValues(alpha: 0.5)),
                ),
                icon: Icon(Icons.stop_circle_outlined, size: 18, color: context.danger),
                label: Text(
                  'End Innings',
                  style: TextStyle(fontWeight: FontWeight.w700, color: context.danger),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

}

String _zoneLabel(String zone) => const {
  'FINE_LEG': 'Fine Leg',
  'SQUARE_LEG': 'Square Leg',
  'MID_WICKET': 'Mid Wicket',
  'LONG_ON': 'Long On',
  'LONG_OFF': 'Long Off',
  'COVER': 'Cover',
  'POINT': 'Point',
  'THIRD_MAN': 'Third Man',
}[zone] ?? zone;

// ─── Granular Consumer rows (avoid rebuilds on isSubmitting / zone changes) ───

class _BatterRow extends ConsumerWidget {
  const _BatterRow({
    required this.matchId,
    required this.isStriker,
    required this.onTap,
  });

  final String matchId;
  final bool isStriker;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = ref.watch(
      hostScoringControllerProvider(matchId).select((s) {
        final playerId = isStriker ? s.effectiveStrikerId : s.effectiveNonStrikerId;
        final player = isStriker ? s.striker(s.players) : s.nonStriker(s.players);
        final stats = playerId.isNotEmpty ? s.batterStats(playerId) : null;
        final sr = (stats != null && stats.balls > 0)
            ? (stats.runs / stats.balls * 100)
            : 0.0;
        return (
          name: player?.name ?? (isStriker ? '— Select Striker' : '— Select Non-Striker'),
          runs: stats?.runs ?? 0,
          balls: stats?.balls ?? 0,
          sr: sr,
        );
      }),
    );
    return BatterRow(
      name: d.name,
      runs: d.runs,
      balls: d.balls,
      strikeRate: d.sr,
      isStriker: isStriker,
      onTap: onTap,
    );
  }
}

class _BowlerRow extends ConsumerWidget {
  const _BowlerRow({required this.matchId, required this.onTap});

  final String matchId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = ref.watch(
      hostScoringControllerProvider(matchId).select((s) {
        final bid = s.effectiveBowlerId;
        final bowler = s.bowler(s.players);
        final stats = bid.isNotEmpty ? s.bowlerStats(bid) : null;
        return (
          name: bowler?.name ?? '— Select Bowler',
          overs: stats?.overs ?? '0.0',
          runs: stats?.runs ?? 0,
          wickets: stats?.wickets ?? 0,
          eco: stats?.eco ?? '-',
        );
      }),
    );
    return BowlerRow(
      name: d.name,
      overs: d.overs,
      runs: d.runs,
      wickets: d.wickets,
      economy: d.eco,
      onTap: onTap,
    );
  }
}

class _WicketKeeperRow extends ConsumerWidget {
  const _WicketKeeperRow({required this.matchId, required this.onTap});

  final String matchId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = ref.watch(
      hostScoringControllerProvider(matchId).select((s) {
        final match = s.match;
        final players = s.players;
        final innings = s.activeInnings;
        if (match == null || players == null || innings == null) {
          return (name: '— Select Wicket-Keeper');
        }
        final bowlingSide = match.bowlingTeam ?? 'B';
        final keeperId = bowlingSide == 'A'
            ? players.teamAWicketKeeperId
            : players.teamBWicketKeeperId;
        final keeper = keeperId != null ? players.findById(keeperId) : null;
        return (name: keeper?.name ?? '— Select Wicket-Keeper');
      }),
    );
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              'WK',
              style: TextStyle(
                color: context.fgSub,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                d.name,
                style: TextStyle(
                  color: context.fg,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 16, color: context.fgSub),
          ],
        ),
      ),
    );
  }
}

// ─── Scoring pad modal sheet ──────────────────────────────────────────────────

class _ScoringPadSheet extends ConsumerStatefulWidget {
  const _ScoringPadSheet({
    required this.matchId,
    required this.onRun,
  });

  final String matchId;
  final Future<void> Function(int runs) onRun;

  @override
  ConsumerState<_ScoringPadSheet> createState() => _ScoringPadSheetState();
}

class _ScoringPadSheetState extends ConsumerState<_ScoringPadSheet> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hostScoringControllerProvider(widget.matchId));
    final busy = state.isSubmitting;

    void pop() => Navigator.pop(context);
    void record(int runs) { pop(); widget.onRun(runs); }

    return Container(
      color: context.bg,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: context.stroke,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (state.isFreeHit)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFF14532D),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flash_on_rounded, color: Colors.white, size: 15),
                    SizedBox(width: 6),
                    Text(
                      'FREE HIT — batter can only be run out',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              )
            else if (state.zone != null)
              Text(
                _zoneLabel(state.zone!),
                style: TextStyle(
                  color: context.accent,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            const SizedBox(height: 12),
            Row(children: [
              _ScorePadBtn(label: '1', busy: busy, onTap: () => record(1)),
              const SizedBox(width: 6),
              _ScorePadBtn(label: '2', busy: busy, onTap: () => record(2)),
              const SizedBox(width: 6),
              _ScorePadBtn(label: '3', busy: busy, onTap: () => record(3)),
              const SizedBox(width: 6),
              _ScorePadBtn(label: '4', sublabel: 'Four',
                accent: const Color(0xFF065F46), busy: busy,
                onTap: () => record(4)),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              _ScorePadBtn(label: '5', busy: busy, onTap: () => record(5)),
              const SizedBox(width: 6),
              _ScorePadBtn(label: '6', sublabel: 'Six',
                accent: const Color(0xFF14532D), busy: busy,
                onTap: () => record(6)),
            ]),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ─── Small private widgets ─────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ScorePadBtn extends StatelessWidget {
  const _ScorePadBtn({
    required this.label,
    required this.busy,
    required this.onTap,
    this.sublabel,
    this.accent,
  });

  final String label;
  final String? sublabel;
  final Color? accent;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = accent ?? context.cardBg;
    final fg = accent != null ? Colors.white : context.fg;
    return Expanded(
      child: SizedBox(
        height: 68,
        child: Material(
          color: busy ? bg.withValues(alpha: 0.4) : bg,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: busy ? null : onTap,
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: busy ? fg.withValues(alpha: 0.35) : fg,
                    height: 1.0,
                  ),
                ),
                if (sublabel != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    sublabel!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: (busy ? fg.withValues(alpha: 0.35) : fg).withValues(alpha: 0.6),
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WicketBtn extends StatelessWidget {
  const _WicketBtn({required this.busy, required this.onTap});

  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFB91C1C);
    final fg = busy ? Colors.white.withValues(alpha: 0.35) : Colors.white;
    return SizedBox(
      height: 52,
      child: Material(
        color: busy ? bg.withValues(alpha: 0.35) : bg,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: busy ? null : onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.sports_cricket_rounded, size: 18, color: fg),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'WICKET',
                    style: TextStyle(
                      color: fg,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
                Text(
                  'W',
                  style: TextStyle(
                    color: fg,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DotBtn extends StatelessWidget {
  const _DotBtn({required this.busy, required this.onTap});

  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF374151);
    final color = busy ? Colors.white.withValues(alpha: 0.35) : Colors.white;
    return SizedBox(
      height: 52,
      child: Material(
        color: busy ? bg.withValues(alpha: 0.35) : bg,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: busy ? null : onTap,
          borderRadius: BorderRadius.circular(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '·',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: color,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Dot',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color.withValues(alpha: busy ? 0.35 : 0.65),
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.busy,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool busy;
  final dynamic onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: OutlinedButton(
        onPressed: busy || onTap == null ? null : () {
          if (onTap is Future<bool> Function()) {
            (onTap as Future<bool> Function())();
          } else if (onTap is VoidCallback) {
            (onTap as VoidCallback)();
          }
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          side: BorderSide(color: context.stroke),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: context.fgSub),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: context.fgSub,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExtraChip extends StatelessWidget {
  const _ExtraChip({
    required this.label,
    required this.color,
    required this.busy,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 44,
        child: TextButton(
          onPressed: busy ? null : onTap,
          style: TextButton.styleFrom(
            backgroundColor: color.withValues(alpha: busy ? 0.4 : 1.0),
            foregroundColor: Colors.white,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
      ),
    );
  }
}

// ─── Overthrow button ─────────────────────────────────────────────────────────

class _OverthrowBtn extends StatelessWidget {
  const _OverthrowBtn({required this.busy, required this.onTap});

  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = busy
        ? const Color(0xFFF97316).withValues(alpha: 0.35)
        : const Color(0xFFF97316);
    return SizedBox(
      height: 52,
      child: Material(
        color: const Color(0xFF78350F).withValues(alpha: busy ? 0.1 : 0.18),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: busy ? null : onTap,
          borderRadius: BorderRadius.circular(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sync_rounded, size: 16, color: color),
              const SizedBox(height: 3),
              Text(
                'Over\nthrow',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                  height: 1.2,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Overthrow picker sheet ───────────────────────────────────────────────────

class _OverthrowPicker extends StatelessWidget {
  const _OverthrowPicker({
    required this.batsmanRuns,
    required this.onConfirm,
  });

  final int batsmanRuns;
  final void Function(int overthrowRuns) onConfirm;

  @override
  Widget build(BuildContext context) {
    final runLabel = batsmanRuns == 1 ? '1 run' : '$batsmanRuns runs';
    return Container(
      color: context.bg,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: context.stroke,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Overthrow  ·  $runLabel + ?',
              style: TextStyle(
                color: context.fg,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Extra runs from the overthrow (added to last ball)',
              style: TextStyle(color: context.fgSub, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Row(children: [
              _ScorePadBtn(
                label: '4', sublabel: 'Boundary',
                accent: const Color(0xFF065F46), busy: false,
                onTap: () => onConfirm(4),
              ),
              const SizedBox(width: 6),
              _ScorePadBtn(label: '1', busy: false, onTap: () => onConfirm(1)),
              const SizedBox(width: 6),
              _ScorePadBtn(label: '2', busy: false, onTap: () => onConfirm(2)),
              const SizedBox(width: 6),
              _ScorePadBtn(label: '3', busy: false, onTap: () => onConfirm(3)),
            ]),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ─── End of innings sheet ─────────────────────────────────────────────────────

class _EndOfInningsSheet extends StatelessWidget {
  const _EndOfInningsSheet({
    required this.match,
    required this.innings,
    required this.canStartNextInnings,
    required this.onStartNextInnings,
    required this.onEndMatch,
    required this.onUndo,
    this.onManageScorer,
  });

  final ScoringMatch match;
  final ScoringInnings innings;
  final bool canStartNextInnings;
  final VoidCallback onStartNextInnings;
  final VoidCallback onEndMatch;
  final VoidCallback onUndo;
  /// When set, renders a "Manage scorer" entry. Used so the owner can hand
  /// the gloves over (or take them back) before starting the next innings
  /// or ending the match.
  final VoidCallback? onManageScorer;

  @override
  Widget build(BuildContext context) {
    final teamName = innings.battingTeam == 'A' ? match.teamAName : match.teamBName;
    final score = '${innings.totalRuns}/${innings.totalWickets}';
    final overs = '${innings.overNumber}.${innings.ballInOver} ovs';

    return Container(
      color: context.bg,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: context.stroke,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              canStartNextInnings ? 'Innings Complete' : 'Match Complete',
              style: TextStyle(
                color: context.fg,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$teamName  $score  ·  $overs',
              style: TextStyle(
                color: context.fgSub,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 28),
            if (canStartNextInnings) ...[
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: onStartNextInnings,
                  child: const Text(
                    'Start 2nd Innings',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ] else ...[
              Text(
                'You cannot change the score once you end the match.',
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: onEndMatch,
                  style: FilledButton.styleFrom(
                    backgroundColor: context.danger,
                  ),
                  child: const Text(
                    'End Match',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: onUndo,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: context.stroke),
                ),
                icon: Icon(Icons.undo_rounded, size: 16, color: context.fgSub),
                label: Text(
                  'Undo Last Ball',
                  style: TextStyle(
                    color: context.fgSub,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (onManageScorer != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 48,
                child: TextButton.icon(
                  onPressed: onManageScorer,
                  icon: const Icon(Icons.manage_accounts_rounded, size: 18),
                  label: const Text(
                    'Manage scorer',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ─── Error body ────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(error,
                style: TextStyle(color: context.fgSub),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

// ─── Inactive innings section ──────────────────────────────────────────────────

class _InactiveInningsSection extends StatefulWidget {
  const _InactiveInningsSection({
    required this.match,
    required this.isSubmitting,
    required this.onStart,
    required this.onUpdateMatchOvers,
    required this.onUpdateMatchSchedule,
    required this.onContinue,
    this.players,
    this.scorerRepo,
    this.currentPlayerId,
    this.onScorerChanged,
    this.onNavigateToToss,
    this.onNavigateToPlaying11,
    this.onEditMatch,
    this.onDelete,
  });

  final ScoringMatch match;
  final ScoringPlayersData? players;
  final HostMatchRepository? scorerRepo;
  final String? currentPlayerId;
  final VoidCallback? onScorerChanged;
  final bool isSubmitting;
  final Future<bool> Function() onStart;
  final Future<bool> Function(int overs) onUpdateMatchOvers;
  final Future<bool> Function(DateTime scheduledAt) onUpdateMatchSchedule;
  final Future<bool> Function() onContinue;
  final VoidCallback? onNavigateToToss;
  final VoidCallback? onNavigateToPlaying11;
  final VoidCallback? onEditMatch;
  final Future<void> Function()? onDelete;

  @override
  State<_InactiveInningsSection> createState() =>
      _InactiveInningsSectionState();
}

class _InactiveInningsSectionState extends State<_InactiveInningsSection> {
  bool _deleting = false;

  bool get _needsPlayingXI =>
      widget.match.teamAPlayerIds.length < 11 ||
      widget.match.teamBPlayerIds.length < 11;

  bool get _needsToss => (widget.match.tossWonBy ?? '').isEmpty;

  bool get _canContinue =>
      !_needsToss &&
      widget.match.isMultiInnings &&
      widget.match.innings.isNotEmpty &&
      widget.match.innings.every((i) => i.isCompleted) &&
      widget.match.innings.length < 4;

  bool get _canChangeOvers {
    final f = widget.match.format.toUpperCase();
    return f == 'CUSTOM' || widget.match.customOvers != null;
  }

  String _formatLabel() {
    final m = widget.match;
    if (m.customOvers != null && m.customOvers! > 0) {
      return 'Custom · ${m.customOvers} overs';
    }
    switch (m.format) {
      case 'T10':
        return 'T10 · 10 overs';
      case 'ONE_DAY':
        return 'One Day · 50 overs';
      case 'BOX_CRICKET':
        return 'Box Cricket · 6 overs';
      case 'TEST':
        return 'Test Match';
      case 'TWO_INNINGS':
        return 'Two Innings';
      default:
        return 'T20 · 20 overs';
    }
  }

  String _tossLabel() {
    final m = widget.match;
    final winner = m.tossWonBy == 'A' ? m.teamAName : m.teamBName;
    final decision = m.tossDecision == 'BAT' ? 'chose to bat' : 'chose to bowl';
    return '$winner won the toss and $decision';
  }

  String? _ballTypeLabel() {
    final t = widget.match.ballType?.toUpperCase();
    if (t == null || t.isEmpty) return null;
    return switch (t) {
      'LEATHER' => 'Leather ball',
      'TENNIS' => 'Tennis ball',
      'RUBBER' => 'Rubber ball',
      'TAPE' => 'Tape ball',
      'CORK' => 'Cork ball',
      _ => t[0] + t.substring(1).toLowerCase(),
    };
  }

  String _playersLabel() {
    final m = widget.match;
    final a = m.teamAPlayerIds.length;
    final b = m.teamBPlayerIds.length;
    if (a == 0 && b == 0) return 'No players added yet';
    if (a == b) return '$a players per team';
    return '${m.teamAName}: $a  ·  ${m.teamBName}: $b';
  }

  String _scorerLabel() {
    final m = widget.match;
    final name = (m.activeScorerName ?? '').trim();
    if (name.isNotEmpty) return name;
    final id = (m.activeScorerId ?? '').trim();
    if (id.isNotEmpty) return 'Assigned';
    return 'Owner only';
  }

  Future<void> _openScorerSheet() async {
    final ctx = context;
    final repo = widget.scorerRepo;
    final players = widget.players;
    if (repo == null || players == null) return;

    await showModalBottomSheet<void>(
      context: ctx,
      backgroundColor: Theme.of(ctx).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Manage scorer',
                  style: TextStyle(
                    color: sheetCtx.fg,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Owner / manager only. Pick someone to record balls. '
                  'They\'ll keep the gloves until you change them again.',
                  style: TextStyle(
                    color: sheetCtx.fgSub,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () async {
                    Navigator.pop(sheetCtx);
                    await _assignScorerById(
                      repo,
                      widget.currentPlayerId ?? '',
                      'Take over',
                    );
                  },
                  icon: const Icon(Icons.person_pin_circle_rounded, size: 18),
                  label: const Text('Take over scoring'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(sheetCtx);
                    await _pickAndAssignScorer(repo, players);
                  },
                  icon: const Icon(Icons.person_add_alt_rounded, size: 18),
                  label: const Text('Assign someone else'),
                ),
                if ((widget.match.activeScorerId ?? '').isNotEmpty) ...[
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () async {
                      Navigator.pop(sheetCtx);
                      try {
                        await repo.revokeScorer(widget.match.id);
                        if (mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                              content: Text('Scorer assignment cleared'),
                            ),
                          );
                          widget.onScorerChanged?.call();
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text('Could not clear: $e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.lock_open_rounded, size: 16),
                    label: const Text('Release control'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _assignScorerById(
    HostMatchRepository repo,
    String profileId,
    String label,
  ) async {
    final id = profileId.trim();
    if (id.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not identify your profile')),
        );
      }
      return;
    }
    try {
      await repo.assignScorer(widget.match.id, id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label — done')),
        );
        widget.onScorerChanged?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not assign: $e')),
        );
      }
    }
  }

  Future<void> _pickAndAssignScorer(
    HostMatchRepository repo,
    ScoringPlayersData players,
  ) async {
    if (players.teamA.isEmpty && players.teamB.isEmpty) return;
    final picked = await Navigator.of(context).push<ScoringMatchPlayer>(
      MaterialPageRoute(
        builder: (_) => ScorerPickerScreen(
          teamAName: widget.match.teamAName,
          teamBName: widget.match.teamBName,
          teamA: players.teamA,
          teamB: players.teamB,
          captainAId: players.teamACaptainId,
          viceCaptainAId: players.teamAViceCaptainId,
          wicketKeeperAId: players.teamAWicketKeeperId,
          captainBId: players.teamBCaptainId,
          viceCaptainBId: players.teamBViceCaptainId,
          wicketKeeperBId: players.teamBWicketKeeperId,
          currentScorerId: widget.match.activeScorerId,
        ),
      ),
    );
    if (picked == null) return;
    await _assignScorerById(repo, picked.profileId, 'Assigned ${picked.name}');
  }

  String? _venueLabel() {
    final m = widget.match;
    final parts = [m.venueName, m.venueCity].whereType<String>().where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return null;
    return parts.join(', ');
  }

  String? _dateLabel() {
    final at = widget.match.scheduledAt;
    if (at == null) return null;
    return DateFormat('EEE, d MMM yyyy · h:mm a').format(at);
  }

  String _inningsSummary(ScoringInnings inn) {
    final m = widget.match;
    final teamName = inn.battingTeam == 'A' ? m.teamAName : m.teamBName;
    final overs = _oversDisplay(inn.legalCount, m.maxOvers);
    return '$teamName  ${inn.totalRuns}/${inn.totalWickets}  ($overs)';
  }

  String _oversDisplay(int legalBalls, int maxOvers) {
    final completedOvers = legalBalls ~/ 6;
    final balls = legalBalls % 6;
    if (balls == 0) return '$completedOvers ovs';
    return '$completedOvers.$balls ovs';
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete match?'),
        content: const Text(
          'This will permanently delete the match and all its data. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _deleting = true);
    try {
      await widget.onDelete!();
    } catch (_) {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _changeOvers() async {
    final current = widget.match.customOvers ?? widget.match.maxOvers;
    final controller = TextEditingController(text: '$current');
    final next = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change overs'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Overs per innings',
            hintText: 'e.g. 16',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final v = int.tryParse(controller.text.trim());
              if (v == null || v <= 0 || v > 90) return;
              Navigator.pop(ctx, v);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
    if (next == null || !mounted) return;
    final ok = await widget.onUpdateMatchOvers(next);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Overs updated to $next' : 'Could not update overs'),
      ),
    );
  }

  Future<void> _changeDateTime() async {
    final now = DateTime.now();
    final initial = widget.match.scheduledAt ?? now;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) return;
    final next = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    final ok = await widget.onUpdateMatchSchedule(next);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Match date/time updated' : 'Could not update date/time'),
      ),
    );
  }

  VoidCallback? _resolvePlaying11Nav() {
    if (widget.onNavigateToPlaying11 != null) return widget.onNavigateToPlaying11;
    final m = widget.match;
    final aId = (m.teamAId ?? '').trim();
    final bId = (m.teamBId ?? '').trim();
    if (aId.isEmpty || bId.isEmpty) return null;
    return () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PlayingElevenScreen(
            matchId: m.id,
            teamAId: aId,
            teamAName: m.teamAName,
            teamBId: bId,
            teamBName: m.teamBName,
          ),
        ),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    final match = widget.match;
    final busy = widget.isSubmitting || _deleting;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Match review header ──────────────────────────────────────────
          Text(
            _needsToss
                ? 'Match Setup'
                : _canContinue
                    ? 'Ready for next innings'
                    : 'Match Review',
            style: TextStyle(
              color: context.fg,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 20),

          // Teams row removed — the AppBar title already shows
          // "${teamA} vs ${teamB}" so duplicating it here was redundant.

          // ── Detail rows ──────────────────────────────────────────────────
          _DetailRow(
            icon: Icons.sports_cricket_rounded,
            label: 'Format',
            value: _formatLabel(),
          ),
          if (_canChangeOvers) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: busy ? null : _changeOvers,
                icon: const Icon(Icons.tune_rounded, size: 16),
                label: const Text('Change overs'),
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (_ballTypeLabel() != null) ...[
            _DetailRow(
              icon: Icons.lens_rounded,
              label: 'Ball Type',
              value: _ballTypeLabel()!,
            ),
            const SizedBox(height: 12),
          ],
          if (_dateLabel() != null) ...[
            _DetailRow(
              icon: Icons.calendar_today_rounded,
              label: 'Scheduled',
              value: _dateLabel()!,
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: busy ? null : _changeDateTime,
                icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                label: const Text('Change date & time'),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_venueLabel() != null) ...[
            _DetailRow(
              icon: Icons.location_on_rounded,
              label: 'Venue',
              value: _venueLabel()!,
            ),
            const SizedBox(height: 12),
          ],
          _DetailRow(
            icon: Icons.group_rounded,
            label: 'Players',
            value: _playersLabel(),
          ),
          const SizedBox(height: 12),
          // Scorer row — visible always; warning style when no scorer is
          // assigned and captains can't auto-score (host-app match).
          _DetailRow(
            icon: Icons.edit_note_rounded,
            label: 'Scorer',
            value: _scorerLabel(),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: busy ? null : _openScorerSheet,
              icon: const Icon(Icons.manage_accounts_rounded, size: 16),
              label: const Text('Manage scorer'),
            ),
          ),
          const SizedBox(height: 12),
          if ((match.tossWonBy ?? '').isNotEmpty) ...[
            _DetailRow(
              icon: Icons.monetization_on_outlined,
              label: 'Toss',
              value: _tossLabel(),
            ),
            const SizedBox(height: 12),
          ],
          if (match.hasImpactPlayer) ...[
            _DetailRow(
              icon: Icons.bolt_rounded,
              label: 'Impact Player',
              value: 'Enabled',
            ),
            const SizedBox(height: 12),
          ],
          for (final inn in match.innings.where((i) => i.isCompleted)) ...[
            _DetailRow(
              icon: Icons.scoreboard_rounded,
              label: 'Innings ${inn.inningsNumber}',
              value: _inningsSummary(inn),
            ),
            const SizedBox(height: 12),
          ],

          const SizedBox(height: 8),

          // ── Edit row ─────────────────────────────────────────────────────
          // Two equal-width outlined buttons side-by-side: lineup edits on
          // the left, full match-settings edits on the right. Hidden when
          // there's no Playing 11 yet (the primary CTA below covers that).
          if (!_needsPlayingXI &&
              (_resolvePlaying11Nav() != null ||
                  widget.onEditMatch != null)) ...[
            Row(
              children: [
                if (_resolvePlaying11Nav() != null)
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: busy ? null : _resolvePlaying11Nav(),
                        icon: const Icon(Icons.groups_rounded, size: 18),
                        label: const Text(
                          'Edit Playing 11',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.fg,
                          side: BorderSide(color: context.stroke),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_resolvePlaying11Nav() != null &&
                    widget.onEditMatch != null)
                  const SizedBox(width: 10),
                if (widget.onEditMatch != null)
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: busy ? null : widget.onEditMatch,
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        label: const Text(
                          'Edit Match Details',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.fg,
                          side: BorderSide(color: context.stroke),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
          ],

          // ── Primary CTA — one big block ──────────────────────────────────
          if (_needsPlayingXI) ...[
            SizedBox(
              width: double.infinity,
              height: 60,
              child: FilledButton.icon(
                onPressed: busy ? null : _resolvePlaying11Nav(),
                icon: const Icon(Icons.groups_rounded, size: 22),
                label: const Text(
                  'Select Playing 11',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            if (_resolvePlaying11Nav() == null) ...[
              const SizedBox(height: 8),
              Text(
                'Playing 11 navigation is not configured for this route.',
                style: TextStyle(color: context.warn, fontSize: 12),
              ),
            ],
          ] else if (_needsToss) ...[
            SizedBox(
              width: double.infinity,
              height: 60,
              child: FilledButton.icon(
                onPressed: busy ? null : widget.onNavigateToToss,
                icon: const Icon(Icons.monetization_on_rounded, size: 22),
                label: const Text(
                  'Record Toss',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              height: 60,
              child: FilledButton(
                onPressed: busy
                    ? null
                    : (_canContinue ? widget.onContinue : widget.onStart),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _canContinue ? 'Start Next Innings' : 'Start Match',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ],

          // ── Delete option ────────────────────────────────────────────────
          if (widget.onDelete != null && !_canContinue) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: busy ? null : _confirmDelete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.danger,
                  side: BorderSide(
                    color: context.danger.withValues(alpha: 0.4),
                  ),
                ),
                child: _deleting
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.danger,
                        ),
                      )
                    : const Text(
                        'Delete Match',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: context.fgSub),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: context.fgSub.withValues(alpha: 0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: context.fg,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Scorer picker page ──────────────────────────────────────────────────────

class ScorerPickerScreen extends StatelessWidget {
  const ScorerPickerScreen({
    super.key,
    required this.teamAName,
    required this.teamBName,
    required this.teamA,
    required this.teamB,
    required this.captainAId,
    required this.viceCaptainAId,
    required this.wicketKeeperAId,
    required this.captainBId,
    required this.viceCaptainBId,
    required this.wicketKeeperBId,
    required this.currentScorerId,
  });

  final String teamAName;
  final String teamBName;
  final List<ScoringMatchPlayer> teamA;
  final List<ScoringMatchPlayer> teamB;
  final String? captainAId;
  final String? viceCaptainAId;
  final String? wicketKeeperAId;
  final String? captainBId;
  final String? viceCaptainBId;
  final String? wicketKeeperBId;
  final String? currentScorerId;

  /// Default to whichever tab the current scorer is on (if any), otherwise
  /// team A.
  int _initialTabIndex() {
    if (currentScorerId == null || currentScorerId!.isEmpty) return 0;
    final onB = teamB.any((p) => p.matchesId(currentScorerId!));
    return onB ? 1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: _initialTabIndex(),
      child: Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          backgroundColor: context.bg,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: context.fg, size: 18),
          ),
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pick a scorer',
                style: TextStyle(
                  color: context.fg,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'They record balls until you change them',
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(46),
            child: TabBar(
              labelColor: context.fg,
              unselectedLabelColor: context.fgSub,
              indicatorColor: context.accent,
              indicatorWeight: 2,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.1,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                Tab(text: '$teamAName  (${teamA.length})'),
                Tab(text: '$teamBName  (${teamB.length})'),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _TeamPlayerList(
              players: teamA,
              captainId: captainAId,
              viceCaptainId: viceCaptainAId,
              wicketKeeperId: wicketKeeperAId,
              currentScorerId: currentScorerId,
            ),
            _TeamPlayerList(
              players: teamB,
              captainId: captainBId,
              viceCaptainId: viceCaptainBId,
              wicketKeeperId: wicketKeeperBId,
              currentScorerId: currentScorerId,
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamPlayerList extends StatelessWidget {
  const _TeamPlayerList({
    required this.players,
    required this.captainId,
    required this.viceCaptainId,
    required this.wicketKeeperId,
    required this.currentScorerId,
  });

  final List<ScoringMatchPlayer> players;
  final String? captainId;
  final String? viceCaptainId;
  final String? wicketKeeperId;
  final String? currentScorerId;

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No players on this side yet.',
            style: TextStyle(color: context.fgSub, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: players.length,
      itemBuilder: (_, i) {
        final p = players[i];
        return _ScorerPickerRow(
          player: p,
          isCaptain: captainId != null && p.matchesId(captainId!),
          isViceCaptain:
              viceCaptainId != null && p.matchesId(viceCaptainId!),
          isWicketKeeper:
              wicketKeeperId != null && p.matchesId(wicketKeeperId!),
          isCurrentScorer:
              currentScorerId != null && p.matchesId(currentScorerId!),
        );
      },
    );
  }
}

class _ScorerPickerRow extends StatelessWidget {
  const _ScorerPickerRow({
    required this.player,
    required this.isCaptain,
    required this.isViceCaptain,
    required this.isWicketKeeper,
    required this.isCurrentScorer,
  });

  final ScoringMatchPlayer player;
  final bool isCaptain;
  final bool isViceCaptain;
  final bool isWicketKeeper;
  final bool isCurrentScorer;

  String get _initials {
    final parts = player.name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(player),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.surf,
                  border: Border.all(color: context.stroke),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name + role chips
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        player.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.fg,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isCaptain) ...[
                      const SizedBox(width: 6),
                      _RoleChip(label: 'C', tone: context.accent),
                    ],
                    if (isViceCaptain) ...[
                      const SizedBox(width: 6),
                      _RoleChip(label: 'VC', tone: context.fgSub),
                    ],
                    if (isWicketKeeper) ...[
                      const SizedBox(width: 6),
                      _RoleChip(label: 'WK', tone: context.fgSub),
                    ],
                  ],
                ),
              ),
              // Current scorer marker
              if (isCurrentScorer)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: context.success,
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.label, required this.tone});

  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: tone,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
