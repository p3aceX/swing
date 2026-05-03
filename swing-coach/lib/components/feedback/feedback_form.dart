import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swing_coach/configs/session_feedback_config.dart';
import 'package:swing_coach/services/feedback_service.dart';

@immutable
class FeedbackPlayer {
  const FeedbackPlayer({required this.playerId, required this.playerName});

  final String playerId;
  final String playerName;
}

typedef FeedbackSubmit = Future<void> Function(List<PlayerFeedbackPayload> players);
typedef FeedbackSkip = Future<void> Function();

class FeedbackForm extends StatefulWidget {
  const FeedbackForm({
    required this.sessionType,
    required this.players,
    required this.onSubmit,
    this.onSkip,
    this.draftKey,
    super.key,
  });

  final String sessionType;
  final List<FeedbackPlayer> players;
  final FeedbackSubmit onSubmit;
  final FeedbackSkip? onSkip;
  final String? draftKey;

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  static final Map<String, List<PlayerFeedbackPayload>> _drafts = {};
  static const _freqStorageKey = 'feedback_option_frequency_v1';

  final _customMistakeCtrl = TextEditingController();
  final _customStrengthCtrl = TextEditingController();
  final Map<String, PlayerFeedbackPayload> _state = {};
  Map<String, int> _frequency = {};
  String? _expandedPlayerId;
  bool _submitting = false;

  SessionFeedbackTemplate get _template => resolveSessionFeedbackTemplate(widget.sessionType);

  @override
  void initState() {
    super.initState();
    _seedInitialState();
    _loadFrequency();
  }

  @override
  void dispose() {
    _customMistakeCtrl.dispose();
    _customStrengthCtrl.dispose();
    super.dispose();
  }

  void _seedInitialState() {
    final draft = widget.draftKey == null ? null : _drafts[widget.draftKey!];
    final draftById = {for (final row in (draft ?? [])) row.playerId: row};
    for (final player in widget.players) {
      _state[player.playerId] = draftById[player.playerId] ??
          PlayerFeedbackPayload(
            playerId: player.playerId,
            mistakes: <String>[],
            strengths: <String>[],
            performance: '',
          );
    }
    if (widget.players.isNotEmpty) {
      _expandedPlayerId = widget.players.first.playerId;
    }
  }

  Future<void> _loadFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_freqStorageKey);
    if (raw == null || raw.isEmpty) return;
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return;
    setState(() {
      _frequency = decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
    });
  }

  Future<void> _saveFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_freqStorageKey, jsonEncode(_frequency));
  }

  List<String> _ordered(List<String> options, String kind) {
    final enriched = [...options];
    enriched.sort((a, b) => _freqFor(kind, b).compareTo(_freqFor(kind, a)));
    return enriched.take(6).toList(growable: false);
  }

  int _freqFor(String kind, String value) {
    return _frequency['${widget.sessionType}|$kind|$value'] ?? 0;
  }

  void _markUsed(String kind, String value) {
    final key = '${widget.sessionType}|$kind|$value';
    _frequency[key] = (_frequency[key] ?? 0) + 1;
  }

  void _toggleMulti(String playerId, String kind, String value) {
    final current = _state[playerId]!;
    final nextMistakes = [...current.mistakes];
    final nextStrengths = [...current.strengths];
    final target = kind == 'mistakes' ? nextMistakes : nextStrengths;
    if (target.contains(value)) {
      target.remove(value);
    } else {
      target.add(value);
      _markUsed(kind, value);
    }
    setState(() {
      _state[playerId] = PlayerFeedbackPayload(
        playerId: current.playerId,
        mistakes: nextMistakes,
        strengths: nextStrengths,
        performance: current.performance,
      );
      _cacheDraft();
    });
    _saveFrequency();
  }

  void _setPerformance(String playerId, String value) {
    final current = _state[playerId]!;
    _markUsed('performance', value);
    setState(() {
      _state[playerId] = PlayerFeedbackPayload(
        playerId: current.playerId,
        mistakes: current.mistakes,
        strengths: current.strengths,
        performance: value,
      );
      _cacheDraft();
    });
    _saveFrequency();
  }

  void _addCustomOption(String playerId, String kind) {
    final controller = kind == 'mistakes' ? _customMistakeCtrl : _customStrengthCtrl;
    final value = controller.text.trim().toLowerCase().replaceAll(' ', '_');
    if (value.isEmpty) return;
    controller.clear();
    _toggleMulti(playerId, kind, value);
  }

  void _cacheDraft() {
    final key = widget.draftKey;
    if (key == null) return;
    _drafts[key] = _state.values.toList(growable: false);
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await widget.onSubmit(_state.values.toList(growable: false));
      if (widget.draftKey != null) _drafts.remove(widget.draftKey!);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _skip() async {
    await widget.onSkip?.call();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final mistakes = _ordered(_template.mistakes, 'mistakes');
    final strengths = _ordered(_template.strengths, 'strengths');
    final performance = _ordered(_template.performance, 'performance');

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            children: [
              Text('Session: ${widget.sessionType}', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              ...widget.players.map((player) {
                final model = _state[player.playerId]!;
                final expanded = _expandedPlayerId == player.playerId;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: expanded ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
                    ),
                  ),
                  child: ExpansionTile(
                    key: ValueKey(player.playerId),
                    initiallyExpanded: expanded,
                    onExpansionChanged: (value) {
                      setState(() => _expandedPlayerId = value ? player.playerId : null);
                    },
                    title: Text(player.playerName),
                    subtitle: Text(model.performance.isEmpty ? 'Tap to add feedback' : 'Performance: ${_pretty(model.performance)}'),
                    childrenPadding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
                    children: [
                      _sectionLabel('Mistakes'),
                      _chips(mistakes, model.mistakes, (value) => _toggleMulti(player.playerId, 'mistakes', value)),
                      _customInput(
                        controller: _customMistakeCtrl,
                        onAdd: () => _addCustomOption(player.playerId, 'mistakes'),
                      ),
                      _sectionLabel('Strengths'),
                      _chips(strengths, model.strengths, (value) => _toggleMulti(player.playerId, 'strengths', value)),
                      _customInput(
                        controller: _customStrengthCtrl,
                        onAdd: () => _addCustomOption(player.playerId, 'strengths'),
                      ),
                      _sectionLabel('Performance'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: performance.map((option) {
                          final selected = model.performance == option;
                          return ChoiceChip(
                            label: Text(_pretty(option)),
                            selected: selected,
                            onSelected: (_) => _setPerformance(player.playerId, option),
                          );
                        }).toList(growable: false),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _submitting ? null : _skip,
                    child: const Text('Skip Feedback'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: Text(_submitting ? 'Submitting...' : 'Submit Feedback'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 8),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
    );
  }

  Widget _chips(List<String> options, List<String> selected, ValueChanged<String> onTap) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        return FilterChip(
          label: Text(_pretty(option)),
          selected: selected.contains(option),
          onSelected: (_) => onTap(option),
        );
      }).toList(growable: false),
    );
  }

  Widget _customInput({required TextEditingController controller, required VoidCallback onAdd}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Custom option',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(onPressed: onAdd, child: const Text('+ Custom')),
        ],
      ),
    );
  }

  String _pretty(String input) {
    return input
        .split('_')
        .map((part) => part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
