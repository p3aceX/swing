import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../controller/health_controller.dart';
import '../../domain/health_models.dart';

class WorkloadLogSheet extends StatefulWidget {
  final WorkloadType? initialType;
  final int? initialDurationMinutes;
  final int? initialIntensity;
  final double? initialOversBowled;
  final int? initialBallsFaced;
  final int? initialSpellCount;
  final String? initialNotes;
  final DateTime? initialOccurredAt;
  final String? initialSource;
  final String? initialSourceRefId;

  const WorkloadLogSheet({
    super.key,
    this.initialType,
    this.initialDurationMinutes,
    this.initialIntensity,
    this.initialOversBowled,
    this.initialBallsFaced,
    this.initialSpellCount,
    this.initialNotes,
    this.initialOccurredAt,
    this.initialSource,
    this.initialSourceRefId,
  });

  @override
  State<WorkloadLogSheet> createState() => _WorkloadLogSheetState();
}

class _WorkloadLogSheetState extends State<WorkloadLogSheet> {
  late WorkloadType _type;
  int _duration = 60;
  int _intensity = 5;
  double _overs = 0;
  int _ballsFaced = 0;
  int _spells = 1;
  bool _isSubmitting = false;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? WorkloadType.BOWLING_NETS;
    _duration = widget.initialDurationMinutes ?? 60;
    _intensity = widget.initialIntensity ?? 5;
    _overs = widget.initialOversBowled ?? 0;
    _ballsFaced = widget.initialBallsFaced ?? 0;
    _spells = widget.initialSpellCount ?? 1;
    _notesController.text = widget.initialNotes ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 32,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Consumer(
        builder: (context, ref, child) => SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Log Session',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Type Selector
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: WorkloadType.values.map((t) {
                    final isSelected = _type == t;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(t.name.replaceAll('_', ' ')),
                        selected: isSelected,
                        onSelected: (v) {
                          if (v) setState(() => _type = t);
                        },
                        selectedColor: context.accent,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : context.fgSub,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 32),

              // Common Fields
              _NumericField(
                label: 'Duration (minutes)',
                value: _duration,
                onChanged: (v) => setState(() => _duration = v.toInt()),
                min: 5,
                max: 300,
              ),
              const SizedBox(height: 20),
              _NumericField(
                label: 'Intensity (1-10)',
                value: _intensity,
                onChanged: (v) => setState(() => _intensity = v.toInt()),
                min: 1,
                max: 10,
              ),

              const SizedBox(height: 20),

              // Dynamic Fields
              if (_type == WorkloadType.BOWLING_NETS ||
                  _type == WorkloadType.MATCH) ...[
                Row(
                  children: [
                    Expanded(
                      child: _NumericField(
                        label: 'Overs',
                        value: _overs.toInt(),
                        onChanged: (v) => setState(() => _overs = v),
                        min: 0,
                        max: 50,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _NumericField(
                        label: 'Spells',
                        value: _spells,
                        onChanged: (v) => setState(() => _spells = v.toInt()),
                        min: 1,
                        max: 10,
                      ),
                    ),
                  ],
                ),
              ],

              if (_type == WorkloadType.BATTING_NETS ||
                  _type == WorkloadType.MATCH) ...[
                const SizedBox(height: 20),
                _NumericField(
                  label: 'Balls Faced',
                  value: _ballsFaced,
                  onChanged: (v) => setState(() => _ballsFaced = v.toInt()),
                  min: 0,
                  max: 500,
                ),
              ],

              const SizedBox(height: 32),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  hintText: 'Notes (Optional)',
                  filled: true,
                  fillColor: context.panel,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                ),
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);
                          setState(() => _isSubmitting = true);
                          try {
                            final event = WorkloadEvent(
                              type: _type,
                              durationMinutes: _duration,
                              intensity: _intensity,
                              oversBowled:
                                  (_type == WorkloadType.BOWLING_NETS ||
                                          _type == WorkloadType.MATCH)
                                      ? _overs
                                      : null,
                              ballsFaced: (_type == WorkloadType.BATTING_NETS ||
                                      _type == WorkloadType.MATCH)
                                  ? _ballsFaced
                                  : null,
                              spellCount: (_type == WorkloadType.BOWLING_NETS ||
                                      _type == WorkloadType.MATCH)
                                  ? _spells
                                  : null,
                              source: widget.initialSource,
                              sourceRefId: widget.initialSourceRefId,
                              notes: _notesController.text.trim().isEmpty
                                  ? null
                                  : _notesController.text.trim(),
                              occurredAt:
                                  widget.initialOccurredAt ?? DateTime.now(),
                            );
                            await ref
                                .read(healthDashboardProvider.notifier)
                                .submitWorkload(event);
                            if (mounted) navigator.pop();
                          } catch (e) {
                            if (!mounted) return;
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Failed to save session: ${_messageFor(e)}'),
                              ),
                            );
                          } finally {
                            if (mounted) {
                              setState(() => _isSubmitting = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Session',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumericField extends StatelessWidget {
  final String label;
  final num value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _NumericField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    color: context.fgSub,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
            Text('${value.toInt()}',
                style: TextStyle(
                    color: context.accent,
                    fontWeight: FontWeight.w900,
                    fontSize: 16)),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: min,
          max: max,
          onChanged: onChanged,
          activeColor: context.accent,
          inactiveColor: context.stroke,
        ),
      ],
    );
  }
}

String _messageFor(Object error) {
  final message = error.toString().trim();
  if (message.isEmpty) {
    return 'Please try again.';
  }
  return message;
}
