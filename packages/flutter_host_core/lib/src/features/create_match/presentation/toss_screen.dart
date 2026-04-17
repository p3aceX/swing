import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../scoring/controller/scoring_controller.dart';

class TossScreen extends ConsumerStatefulWidget {
  const TossScreen({
    super.key,
    required this.matchId,
    this.teamAName = 'Team A',
    this.teamBName = 'Team B',
  });

  final String matchId;
  final String teamAName;
  final String teamBName;

  @override
  ConsumerState<TossScreen> createState() => _TossScreenState();
}

class _TossScreenState extends ConsumerState<TossScreen> {
  String _wonBy = 'A';
  String _decision = 'BAT';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hostScoringControllerProvider(widget.matchId));
    return Scaffold(
      appBar: AppBar(title: const Text('Toss')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.teamAName} vs ${widget.teamBName}'),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'A', label: Text(widget.teamAName)),
                ButtonSegment(value: 'B', label: Text(widget.teamBName)),
              ],
              selected: {_wonBy},
              onSelectionChanged: (value) =>
                  setState(() => _wonBy = value.first),
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'BAT', label: Text('Bat')),
                ButtonSegment(value: 'BOWL', label: Text('Bowl')),
              ],
              selected: {_decision},
              onSelectionChanged: (value) =>
                  setState(() => _decision = value.first),
            ),
            const SizedBox(height: 16),
            if ((state.error ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  state.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            FilledButton(
              onPressed: state.isSubmitting
                  ? null
                  : () async {
                      final ok = await ref
                          .read(
                              hostScoringControllerProvider(widget.matchId).notifier)
                          .recordToss(_wonBy, _decision);
                      if (!mounted || !ok) return;
                      Navigator.of(context).pop();
                    },
              child: Text(state.isSubmitting ? 'Saving...' : 'Save toss'),
            ),
          ],
        ),
      ),
    );
  }
}
