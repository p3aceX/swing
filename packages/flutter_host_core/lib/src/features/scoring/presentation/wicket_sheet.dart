import 'package:flutter/material.dart';

import '../../../theme/host_colors.dart';
import '../domain/scoring_models.dart';

class WicketSheet extends StatefulWidget {
  const WicketSheet({
    super.key,
    required this.strikerName,
    required this.nonStrikerName,
    required this.fieldingTeam,
    required this.onConfirm,
  });

  final String strikerName;
  final String nonStrikerName;
  final List<ScoringMatchPlayer> fieldingTeam;
  final void Function({
    required String dismissalType,
    String? fielderId,
    required bool dismissedIsStriker,
    required int completedRuns,
    bool crossed,
  }) onConfirm;

  @override
  State<WicketSheet> createState() => _WicketSheetState();
}

class _WicketSheetState extends State<WicketSheet> {
  static const _dismissals = <String>[
    'BOWLED',
    'CAUGHT',
    'CAUGHT_BEHIND',
    'CAUGHT_AND_BOWLED',
    'LBW',
    'RUN_OUT',
    'STUMPED',
    'HIT_WICKET',
    'RETIRED_HURT',
  ];

  String _dismissalType = 'BOWLED';
  bool _dismissedIsStriker = true;
  String? _fielderId;
  int _completedRuns = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Record Wicket',
                style: TextStyle(
                  color: context.fg,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _dismissalType,
                decoration: const InputDecoration(labelText: 'Dismissal type'),
                items: _dismissals
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.replaceAll('_', ' ')),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _dismissalType = value ?? 'BOWLED'),
              ),
              const SizedBox(height: 12),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment<bool>(value: true, label: Text(widget.strikerName)),
                  ButtonSegment<bool>(value: false, label: Text(widget.nonStrikerName)),
                ],
                selected: {_dismissedIsStriker},
                onSelectionChanged: (value) =>
                    setState(() => _dismissedIsStriker = value.first),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _fielderId,
                decoration: const InputDecoration(labelText: 'Fielder'),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Not applicable'),
                  ),
                  ...widget.fieldingTeam.map(
                    (player) => DropdownMenuItem<String>(
                      value: player.profileId,
                      child: Text(player.name),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _fielderId = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: 0,
                decoration: const InputDecoration(labelText: 'Completed runs'),
                items: List.generate(
                  5,
                  (index) => DropdownMenuItem<int>(
                    value: index,
                    child: Text('$index'),
                  ),
                ),
                onChanged: (value) => setState(() => _completedRuns = value ?? 0),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    widget.onConfirm(
                      dismissalType: _dismissalType,
                      fielderId: _fielderId,
                      dismissedIsStriker: _dismissedIsStriker,
                      completedRuns: _completedRuns,
                      crossed: false,
                    );
                  },
                  child: const Text('Confirm wicket'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
