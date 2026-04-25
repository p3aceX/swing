import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/host_colors.dart';
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
    this.onNavigateToScorecard,
    this.onNavigateToPlaying11,
    this.teamAName = 'Team A',
    this.teamBName = 'Team B',
  });

  final String matchId;
  final String? currentPlayerId;
  final void Function(BuildContext context, String matchId)? onNavigateBack;
  final void Function(BuildContext context, String matchId)?
      onNavigateToScorecard;
  final void Function(
    BuildContext context,
    String matchId,
    String teamAName,
    String teamBName,
  )? onNavigateToPlaying11;
  final String teamAName;
  final String teamBName;

  @override
  ConsumerState<ScoringScreen> createState() => _ScoringScreenState();
}

class _ScoringScreenState extends ConsumerState<ScoringScreen> {
  HostScoringController get _ctrl =>
      ref.read(hostScoringControllerProvider(widget.matchId).notifier);

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

  Future<void> _pickBowler(HostScoringState state) async {
    final match = state.match;
    final players = state.players;
    if (match == null || players == null) return;
    await _pickPlayer(
      title: 'Change Bowler',
      players: players.forSide(match.bowlingTeam ?? 'B'),
      onPicked: (p) => _ctrl.setBowler(p.profileId),
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
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WicketSheet(
        strikerName: state.striker(players)?.name ?? 'Striker',
        nonStrikerName: state.nonStriker(players)?.name ?? 'Non-Striker',
        fieldingTeam: players.forSide(match.bowlingTeam ?? 'B'),
        onConfirm: ({
          required String dismissalType,
          String? fielderId,
          required bool dismissedIsStriker,
          required int completedRuns,
          bool crossed = false,
        }) async {
          Navigator.pop(context);
          await _ctrl.recordBall(
            outcome: 'WICKET',
            runs: completedRuns,
            extras: 0,
            isWicket: dismissalType != 'RETIRED_HURT',
            dismissalType: dismissalType,
            dismissedPlayerId: dismissedIsStriker
                ? state.effectiveStrikerId
                : state.effectiveNonStrikerId,
            fielderId: dismissalType == 'CAUGHT_AND_BOWLED'
                ? state.effectiveBowlerId
                : fielderId,
          );
        },
      ),
    );
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
    await _ctrl.recordBall(
      outcome: outcomes[runs] ?? 'SINGLE',
      runs: runs,
      extras: 0,
    );
  }

  // ─── Current over balls ────────────────────────────────────────────────────

  List<ScoringBall> _currentOverBalls(HostScoringState state) {
    final balls = state.balls;
    final ballInOver = state.activeInnings?.ballInOver ?? 0;
    if (balls.isEmpty || ballInOver == 0) return const [];

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

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hostScoringControllerProvider(widget.matchId));
    final match = state.match;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.onNavigateBack != null) {
              widget.onNavigateBack!(context, widget.matchId);
            } else {
              Navigator.maybePop(context);
            }
          },
        ),
        title: Text(
          match == null
              ? 'Scoring'
              : '${match.teamAName} vs ${match.teamBName}',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.table_rows_rounded),
            onPressed: state.isLoading
                ? null
                : () {
                    if (widget.onNavigateToScorecard != null && match != null) {
                      widget.onNavigateToScorecard!(context, widget.matchId);
                    }
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
                  state: state,
                  currentOverBalls: _currentOverBalls(state),
                  onWheelZoneTap: (zone) {
                    final current = state.zone;
                    _ctrl.setZone(current == zone ? null : zone);
                  },
                  onRun: _recordRun,
                  onDotBall: () => _recordRun(0),
                  onWide: () => _showExtraSelector(
                    title: 'Wides',
                    onConfirm: (v) => _ctrl.recordBall(
                      outcome: 'WIDE',
                      runs: 0,
                      extras: v,
                    ),
                  ),
                  onNoBall: () => _showExtraSelector(
                    title: 'Runs off bat (No Ball)',
                    options: const [0, 1, 2, 3, 4, 5, 6],
                    onConfirm: (v) => _ctrl.recordBall(
                      outcome: 'NO_BALL',
                      runs: v,
                      extras: 1,
                    ),
                  ),
                  onBye: () => _showExtraSelector(
                    title: 'Bye runs',
                    onConfirm: (v) => _ctrl.recordBall(
                      outcome: 'BYE',
                      runs: 0,
                      extras: v,
                    ),
                  ),
                  onLegBye: () => _showExtraSelector(
                    title: 'Leg bye runs',
                    onConfirm: (v) => _ctrl.recordBall(
                      outcome: 'LEG_BYE',
                      runs: 0,
                      extras: v,
                    ),
                  ),
                  onWicket: () => _showWicketSheet(state),
                  onSwapBatters: state.canScore ? _ctrl.swapBatters : null,
                  onChangeBowler: () => _pickBowler(state),
                  onPickSetup: () => _pickSetup(state),
                  onUndo: _ctrl.undoLastBall,
                  onEndInnings: _ctrl.completeInnings,
                  onStartMatch: _ctrl.startMatch,
                  onContinueInnings: _ctrl.continueInnings,
                  onRecordToss: (wonBy, decision) =>
                      _ctrl.recordToss(wonBy, decision),
                ),
    );
  }
}

// ─── Scoring Body ─────────────────────────────────────────────────────────────

class _ScoringBody extends StatelessWidget {
  const _ScoringBody({
    required this.state,
    required this.currentOverBalls,
    required this.onWheelZoneTap,
    required this.onRun,
    required this.onDotBall,
    required this.onWide,
    required this.onNoBall,
    required this.onBye,
    required this.onLegBye,
    required this.onWicket,
    required this.onSwapBatters,
    required this.onChangeBowler,
    required this.onPickSetup,
    required this.onUndo,
    required this.onEndInnings,
    required this.onStartMatch,
    required this.onContinueInnings,
    required this.onRecordToss,
  });

  final HostScoringState state;
  final List<ScoringBall> currentOverBalls;
  final void Function(String zone) onWheelZoneTap;
  final Future<void> Function(int runs) onRun;
  final VoidCallback onDotBall;
  final VoidCallback onWide;
  final VoidCallback onNoBall;
  final VoidCallback onBye;
  final VoidCallback onLegBye;
  final VoidCallback onWicket;
  final VoidCallback? onSwapBatters;
  final VoidCallback onChangeBowler;
  final VoidCallback onPickSetup;
  final Future<bool> Function() onUndo;
  final Future<bool> Function() onEndInnings;
  final Future<bool> Function() onStartMatch;
  final Future<bool> Function() onContinueInnings;
  final Future<bool> Function(String wonBy, String decision) onRecordToss;

  @override
  Widget build(BuildContext context) {
    final match = state.match!;
    final innings = state.activeInnings;
    final players = state.players;

    return ListView(
      children: [
        // ── Score strip ─────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(
            children: [
              _Pill(label: 'LIVE', color: const Color(0xFF374151)),
              const SizedBox(width: 8),
              if (innings != null)
                _Pill(
                  label: 'INN ${innings.inningsNumber}',
                  color: const Color(0xFF78350F),
                ),
              const SizedBox(width: 12),
              if (innings != null) ...[
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
              ],
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

        // ── This over ───────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: Row(
            children: [
              Text(
                'This over:',
                style:
                    TextStyle(color: context.fgSub, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OverDotsRow(overBalls: currentOverBalls),
              ),
            ],
          ),
        ),

        Divider(height: 1, color: context.stroke),

        // ── Error / commentary ──────────────────────────────────────────────
        if (state.error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              state.error!,
              style: TextStyle(color: context.danger, fontSize: 13),
            ),
          ),
        if ((state.lastCommentaryText ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Text(
              state.lastCommentaryText!,
              style: TextStyle(
                color: context.fgSub,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),

        // ── Setup flows ──────────────────────────────────────────────────────
        if (innings == null) ...[
          const SizedBox(height: 16),
          if ((match.tossWonBy ?? '').isEmpty)
            _TossSection(
              isSubmitting: state.isSubmitting,
              teamAName: match.teamAName,
              teamBName: match.teamBName,
              onConfirm: onRecordToss,
            )
          else
            _InactiveInningsSection(
              match: match,
              isSubmitting: state.isSubmitting,
              onStart: onStartMatch,
              onContinue: onContinueInnings,
            ),
          const SizedBox(height: 32),
        ] else ...[
          // ── Players ───────────────────────────────────────────────────────
          const SizedBox(height: 4),
          _buildBatterRow(context, state, players, isStriker: true),
          _buildBatterRow(context, state, players, isStriker: false),
          Divider(height: 1, thickness: 1, color: context.stroke),
          _buildBowlerRow(context, state, players),
          Divider(height: 1, thickness: 1, color: context.stroke),

          // ── Wagon wheel ───────────────────────────────────────────────────
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ScoringWagonWheel(
              selectedZone: state.zone,
              onZoneTap: state.canScore ? onWheelZoneTap : null,
            ),
          ),

          // ── Hint / selected zone ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Text(
                state.zone != null
                    ? 'Zone: ${_zoneLabel(state.zone!)}  (tap again to clear)'
                    : 'Tap the wheel to select a zone',
                style: TextStyle(color: context.fgSub, fontSize: 13),
              ),
            ),
          ),

          // ── Run buttons 1–6 ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Row(
              children: [1, 2, 3, 4, 5, 6]
                  .map(
                    (r) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: _RunBtn(
                          label: '$r',
                          busy: state.isSubmitting || !state.canScore,
                          onTap: () => onRun(r),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),

          // ── Dot Ball ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _WideBtn(
              label: '· Dot Ball',
              busy: state.isSubmitting || !state.canScore,
              onTap: onDotBall,
            ),
          ),
          const SizedBox(height: 8),

          // ── Swap / Change Bowler ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        state.isSubmitting ? null : onSwapBatters,
                    icon: const Icon(Icons.swap_horiz, size: 18),
                    label: const Text('Swap Batsman'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: state.isSubmitting ? null : onChangeBowler,
                    icon: const Icon(Icons.sports_baseball, size: 18),
                    label: const Text('Change Bowler'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Undo ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: state.isSubmitting ? null : () => onUndo(),
                icon: const Icon(Icons.undo, size: 18),
                label: const Text('Undo Last Ball'),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Extras row ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _ExtraChip(
                  label: 'Wide',
                  color: const Color(0xFF92400E),
                  busy: state.isSubmitting || !state.canScore,
                  onTap: onWide,
                ),
                const SizedBox(width: 6),
                _ExtraChip(
                  label: 'NB',
                  color: const Color(0xFF92400E),
                  busy: state.isSubmitting || !state.canScore,
                  onTap: onNoBall,
                ),
                const SizedBox(width: 6),
                _ExtraChip(
                  label: 'Bye',
                  color: const Color(0xFF1E3A5F),
                  busy: state.isSubmitting || !state.canScore,
                  onTap: onBye,
                ),
                const SizedBox(width: 6),
                _ExtraChip(
                  label: 'LB',
                  color: const Color(0xFF1E3A5F),
                  busy: state.isSubmitting || !state.canScore,
                  onTap: onLegBye,
                ),
                const SizedBox(width: 6),
                _ExtraChip(
                  label: 'Wkt',
                  color: const Color(0xFF7F1D1D),
                  busy: state.isSubmitting || !state.canScore,
                  onTap: onWicket,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── End Innings ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: state.isSubmitting ? null : () => onEndInnings(),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF7F1D1D),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.stop_circle_outlined, size: 18),
                label: const Text('End Innings'),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ],
    );
  }

  Widget _buildBatterRow(
    BuildContext context,
    HostScoringState state,
    ScoringPlayersData? players, {
    required bool isStriker,
  }) {
    final playerId =
        isStriker ? state.effectiveStrikerId : state.effectiveNonStrikerId;
    final player = state.striker(players) != null || state.nonStriker(players) != null
        ? (isStriker ? state.striker(players) : state.nonStriker(players))
        : null;
    final stats = playerId.isNotEmpty ? state.batterStats(playerId) : null;
    final sr = (stats != null && stats.balls > 0)
        ? (stats.runs / stats.balls * 100)
        : 0.0;

    return BatterRow(
      name: player?.name ?? (isStriker ? '— Select Striker' : '— Select Non-Striker'),
      runs: stats?.runs ?? 0,
      balls: stats?.balls ?? 0,
      strikeRate: sr,
      isStriker: isStriker,
      onTap: () {},
    );
  }

  Widget _buildBowlerRow(
    BuildContext context,
    HostScoringState state,
    ScoringPlayersData? players,
  ) {
    final bowler = state.bowler(players);
    final bid = state.effectiveBowlerId;
    final stats = bid.isNotEmpty ? state.bowlerStats(bid) : null;

    return BowlerRow(
      name: bowler?.name ?? '— Select Bowler',
      overs: stats?.overs ?? '0.0',
      runs: stats?.runs ?? 0,
      wickets: stats?.wickets ?? 0,
      economy: stats?.eco ?? '-',
    );
  }

  static String _zoneLabel(String zone) {
    const labels = {
      'FINE_LEG': 'Fine Leg',
      'SQUARE_LEG': 'Square Leg',
      'MID_WICKET': 'Mid Wicket',
      'MID_ON': 'Mid On',
      'MID_OFF': 'Mid Off',
      'STRAIGHT': 'Straight',
      'EXTRA_COVER': 'Extra Cover',
      'COVER': 'Cover',
      'POINT': 'Point',
      'THIRD_MAN': 'Third Man',
    };
    return labels[zone] ?? zone;
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

class _RunBtn extends StatelessWidget {
  const _RunBtn({
    required this.label,
    required this.busy,
    required this.onTap,
  });

  final String label;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: TextButton(
        onPressed: busy ? null : onTap,
        style: TextButton.styleFrom(
          foregroundColor: context.fg,
          padding: EdgeInsets.zero,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: busy ? context.fgSub : context.fg,
          ),
        ),
      ),
    );
  }
}

class _WideBtn extends StatelessWidget {
  const _WideBtn({
    required this.label,
    required this.busy,
    required this.onTap,
  });

  final String label;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: busy ? null : onTap,
        child: Text(label),
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

// ─── Toss section ──────────────────────────────────────────────────────────────

class _TossSection extends StatefulWidget {
  const _TossSection({
    required this.isSubmitting,
    required this.teamAName,
    required this.teamBName,
    required this.onConfirm,
  });

  final bool isSubmitting;
  final String teamAName;
  final String teamBName;
  final Future<bool> Function(String wonBy, String decision) onConfirm;

  @override
  State<_TossSection> createState() => _TossSectionState();
}

class _TossSectionState extends State<_TossSection> {
  String _wonBy = 'A';
  String _decision = 'BAT';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Record Toss',
            style: TextStyle(
              color: context.fg,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'A', label: Text(widget.teamAName)),
              ButtonSegment(value: 'B', label: Text(widget.teamBName)),
            ],
            selected: {_wonBy},
            onSelectionChanged: (v) => setState(() => _wonBy = v.first),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'BAT', label: Text('Bat')),
              ButtonSegment(value: 'BOWL', label: Text('Bowl')),
            ],
            selected: {_decision},
            onSelectionChanged: (v) => setState(() => _decision = v.first),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: widget.isSubmitting
                  ? null
                  : () => widget.onConfirm(_wonBy, _decision),
              child: const Text('Save Toss'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Inactive innings section ──────────────────────────────────────────────────

class _InactiveInningsSection extends StatelessWidget {
  const _InactiveInningsSection({
    required this.match,
    required this.isSubmitting,
    required this.onStart,
    required this.onContinue,
  });

  final ScoringMatch match;
  final bool isSubmitting;
  final Future<bool> Function() onStart;
  final Future<bool> Function() onContinue;

  @override
  Widget build(BuildContext context) {
    final canContinue = match.isMultiInnings &&
        match.innings.isNotEmpty &&
        match.innings.every((i) => i.isCompleted) &&
        match.innings.length < 4;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            canContinue ? 'Ready for next innings' : 'Match not started',
            style: TextStyle(
              color: context.fg,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed:
                  isSubmitting ? null : (canContinue ? onContinue : onStart),
              child: Text(
                  canContinue ? 'Start Next Innings' : 'Start Match'),
            ),
          ),
        ],
      ),
    );
  }
}
