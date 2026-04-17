import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../controller/health_controller.dart';
import '../../domain/health_models.dart';

class WellnessCheckInSheet extends StatefulWidget {
  const WellnessCheckInSheet({super.key});

  @override
  State<WellnessCheckInSheet> createState() => _WellnessCheckInSheetState();
}

class _WellnessCheckInSheetState extends State<WellnessCheckInSheet> {
  double _soreness = 5;
  double _fatigue = 5;
  double _mood = 5;
  double _stress = 5;
  double _painTightness = 1;
  double _sleepQuality = 5;
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

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
                    'Wellness Check-in',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _WellnessSlider(
                label: 'Muscle Soreness',
                value: _soreness,
                onChanged: (v) => setState(() => _soreness = v),
                minLabel: 'Fresh',
                maxLabel: 'Very Sore',
              ),
              const SizedBox(height: 20),
              _WellnessSlider(
                label: 'Fatigue',
                value: _fatigue,
                onChanged: (v) => setState(() => _fatigue = v),
                minLabel: 'Energized',
                maxLabel: 'Exhausted',
              ),
              const SizedBox(height: 20),
              _WellnessSlider(
                label: 'Sleep Quality',
                value: _sleepQuality,
                onChanged: (v) => setState(() => _sleepQuality = v),
                minLabel: 'Poor',
                maxLabel: 'Excellent',
              ),
              const SizedBox(height: 20),
              _WellnessSlider(
                label: 'Mood',
                value: _mood,
                onChanged: (v) => setState(() => _mood = v),
                minLabel: 'Low',
                maxLabel: 'Great',
              ),
              const SizedBox(height: 20),
              _WellnessSlider(
                label: 'Stress',
                value: _stress,
                onChanged: (v) => setState(() => _stress = v),
                minLabel: 'Relaxed',
                maxLabel: 'Stressed',
              ),
              const SizedBox(height: 20),
              _WellnessSlider(
                label: 'Pain / Tightness',
                value: _painTightness,
                onChanged: (v) => setState(() => _painTightness = v),
                minLabel: 'None',
                maxLabel: 'Severe',
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Any specific pain or notes?',
                  filled: true,
                  fillColor: context.panel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);
                          setState(() => _isSubmitting = true);
                          try {
                            final checkIn = WellnessCheckIn(
                              soreness: _soreness.toInt(),
                              fatigue: _fatigue.toInt(),
                              mood: _mood.toInt(),
                              stress: _stress.toInt(),
                              painTightness: _painTightness.toInt(),
                              sleepQuality: _sleepQuality.toInt(),
                              notes: _notesController.text.trim().isEmpty
                                  ? null
                                  : _notesController.text.trim(),
                            );
                            await ref
                                .read(healthDashboardProvider.notifier)
                                .submitWellness(checkIn);
                            if (mounted) navigator.pop();
                          } catch (e) {
                            if (!mounted) return;
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Failed to submit wellness: ${_messageFor(e)}'),
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
                      : const Text('Submit Check-in',
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

String _messageFor(Object error) {
  final message = error.toString().trim();
  if (message.isEmpty) return 'Please try again.';
  return message;
}

class _WellnessSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final String minLabel;
  final String maxLabel;

  const _WellnessSlider({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.minLabel,
    required this.maxLabel,
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
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text('${value.toInt()}',
                style: TextStyle(
                    color: context.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ],
        ),
        Slider(
          value: value,
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: context.accent,
          inactiveColor: context.stroke,
          onChanged: onChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(minLabel,
                style: TextStyle(color: context.fgSub, fontSize: 11)),
            Text(maxLabel,
                style: TextStyle(color: context.fgSub, fontSize: 11)),
          ],
        ),
      ],
    );
  }
}
