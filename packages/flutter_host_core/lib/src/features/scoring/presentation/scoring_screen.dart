import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/host_colors.dart';
import '../controller/scoring_controller.dart';
import '../domain/scoring_models.dart';
import 'player_picker_sheet.dart';
import 'wicket_sheet.dart';

class ScoringScreen extends ConsumerStatefulWidget {
  const ScoringScreen({
    super.key,
    required this.matchId,
    this.currentPlayerId,
    this.onNavigateBack,
    this.onNavigateToPlaying11,
    this.teamAName = 'Team A',
    this.teamBName = 'Team B',
  });

  final String matchId;
  final String? currentPlayerId;
  final void Function(BuildContext context, String matchId)? onNavigateBack;
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

  Future<void> _pickPlayer({
    required String title,
    required List<ScoringMatchPlayer> players,
    required void Function(ScoringMatchPlayer player) onPicked,
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
        onPicked: (player) => _ctrl.setNewBatter(player.profileId),
      );
      return;
    }
    if (state.effectiveNonStrikerId.isEmpty) {
      await _pickPlayer(
        title: 'Select Non-Striker',
        players: batting
            .where((player) => !player.matchesId(state.effectiveStrikerId))
            .toList(),
        onPicked: (player) => _ctrl.setNonStriker(player.profileId),
      );
      return;
    }
    if (state.effectiveBowlerId.isEmpty) {
      await _pickPlayer(
        title: 'Select Bowler',
        players: bowling,
        onPicked: (player) => _ctrl.setBowler(player.profileId),
      );
    }
  }

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
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: options
                      .map(
                        (value) => FilledButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onConfirm(value);
                          },
                          child: Text('$value'),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hostScoringControllerProvider(widget.matchId));
    final match = state.match;

    return Scaffold(
      appBar: AppBar(
        title: Text(match == null
            ? 'Scoring'
            : '${match.teamAName} vs ${match.teamBName}'),
        actions: [
          IconButton(
            onPressed: state.isLoading ? null : _ctrl.refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: state.isLoading && match == null
          ? const Center(child: CircularProgressIndicator())
          : match == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.error ?? 'Could not load match.'),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _ctrl.refresh,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _ScoreHeader(state: state),
                    const SizedBox(height: 16),
                    if (state.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          state.error!,
                          style: TextStyle(color: context.danger),
                        ),
                      ),
                    if ((state.lastCommentaryText ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          state.lastCommentaryText!,
                          style: TextStyle(
                            color: context.fgSub,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (match.activeInnings == null) ...[
                      if ((match.tossWonBy ?? '').isEmpty)
                        _TossCard(
                          isSubmitting: state.isSubmitting,
                          teamAName: match.teamAName,
                          teamBName: match.teamBName,
                          onConfirm: (wonBy, decision) =>
                              _ctrl.recordToss(wonBy, decision),
                        )
                      else
                        _InactiveInningsCard(
                          match: match,
                          isSubmitting: state.isSubmitting,
                          onStart: _ctrl.startMatch,
                          onContinue: _ctrl.continueInnings,
                        ),
                    ] else ...[
                      _SelectionCard(
                        state: state,
                        onPick: () => _pickSetup(state),
                        onSwapBatters: state.canScore ? _ctrl.swapBatters : null,
                      ),
                      const SizedBox(height: 16),
                      _ActionGrid(
                        busy: state.isSubmitting,
                        onRun: _recordRun,
                        onWide: () => _showExtraSelector(
                          title: 'Select wides',
                          onConfirm: (value) => _ctrl.recordBall(
                            outcome: 'WIDE',
                            runs: 0,
                            extras: value,
                          ),
                        ),
                        onNoBall: () => _showExtraSelector(
                          title: 'Runs off the bat',
                          options: const [0, 1, 2, 3, 4, 5, 6],
                          onConfirm: (value) => _ctrl.recordBall(
                            outcome: 'NO_BALL',
                            runs: value,
                            extras: 1,
                          ),
                        ),
                        onWicket: () => _showWicketSheet(state),
                        onUndo: _ctrl.undoLastBall,
                        onEndInnings: _ctrl.completeInnings,
                      ),
                    ],
                  ],
                ),
    );
  }
}

class _ScoreHeader extends StatelessWidget {
  const _ScoreHeader({required this.state});

  final HostScoringState state;

  @override
  Widget build(BuildContext context) {
    final innings = state.activeInnings;
    final match = state.match!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${match.teamAName} vs ${match.teamBName}',
            style: TextStyle(
              color: context.fg,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            innings == null
                ? 'No active innings'
                : 'Innings ${innings.inningsNumber} • ${match.teamName(innings.battingTeam)} batting',
            style: TextStyle(color: context.fgSub),
          ),
          if (innings != null) ...[
            const SizedBox(height: 12),
            Text(
              innings.scoreDisplay,
              style: TextStyle(
                color: context.fg,
                fontSize: 34,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'Overs ${innings.overNumber}.${innings.ballInOver}',
              style: TextStyle(color: context.fgSub),
            ),
            if (state.toWin != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${state.toWin} to win',
                  style: TextStyle(
                    color: context.accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _TossCard extends StatefulWidget {
  const _TossCard({
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
  State<_TossCard> createState() => _TossCardState();
}

class _TossCardState extends State<_TossCard> {
  String _wonBy = 'A';
  String _decision = 'BAT';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Record Toss', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'A', label: Text(widget.teamAName)),
              ButtonSegment(value: 'B', label: Text(widget.teamBName)),
            ],
            selected: {_wonBy},
            onSelectionChanged: (value) => setState(() => _wonBy = value.first),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'BAT', label: Text('Bat')),
              ButtonSegment(value: 'BOWL', label: Text('Bowl')),
            ],
            selected: {_decision},
            onSelectionChanged: (value) =>
                setState(() => _decision = value.first),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: widget.isSubmitting
                ? null
                : () => widget.onConfirm(_wonBy, _decision),
            child: const Text('Save toss'),
          ),
        ],
      ),
    );
  }
}

class _InactiveInningsCard extends StatelessWidget {
  const _InactiveInningsCard({
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
        match.innings.every((innings) => innings.isCompleted) &&
        match.innings.length < 4;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            canContinue ? 'Ready for next innings' : 'Match not started',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: isSubmitting
                ? null
                : (canContinue ? onContinue : onStart),
            child: Text(canContinue ? 'Start next innings' : 'Start match'),
          ),
        ],
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.state,
    required this.onPick,
    this.onSwapBatters,
  });

  final HostScoringState state;
  final VoidCallback onPick;
  final VoidCallback? onSwapBatters;

  @override
  Widget build(BuildContext context) {
    final players = state.players;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PlayerLine(
            label: 'Striker',
            value: state.striker(players)?.name ?? 'Select striker',
          ),
          const SizedBox(height: 8),
          _PlayerLine(
            label: 'Non-Striker',
            value: state.nonStriker(players)?.name ?? 'Select non-striker',
          ),
          const SizedBox(height: 8),
          _PlayerLine(
            label: 'Bowler',
            value: state.bowler(players)?.name ?? 'Select bowler',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onPick,
                  child: const Text('Pick players'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: onSwapBatters,
                child: const Text('Swap'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlayerLine extends StatelessWidget {
  const _PlayerLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(color: context.fgSub, fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: context.fg, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({
    required this.busy,
    required this.onRun,
    required this.onWide,
    required this.onNoBall,
    required this.onWicket,
    required this.onUndo,
    required this.onEndInnings,
  });

  final bool busy;
  final Future<void> Function(int runs) onRun;
  final VoidCallback onWide;
  final VoidCallback onNoBall;
  final VoidCallback onWicket;
  final Future<bool> Function() onUndo;
  final Future<bool> Function() onEndInnings;

  @override
  Widget build(BuildContext context) {
    final buttons = [
      ('0', () => onRun(0)),
      ('1', () => onRun(1)),
      ('2', () => onRun(2)),
      ('3', () => onRun(3)),
      ('4', () => onRun(4)),
      ('6', () => onRun(6)),
      ('Wd', onWide),
      ('Nb', onNoBall),
      ('Wk', onWicket),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: buttons
              .map(
                (button) => SizedBox(
                  width: 72,
                  child: FilledButton(
                    onPressed: busy ? null : button.$2,
                    child: Text(button.$1),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: busy ? null : () => onUndo(),
                child: const Text('Undo'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: busy ? null : () => onEndInnings(),
                child: const Text('End innings'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
