import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/health_controller.dart';
import '../domain/health_models.dart';

class WellnessCheckInScreen extends ConsumerStatefulWidget {
  const WellnessCheckInScreen({super.key});

  @override
  ConsumerState<WellnessCheckInScreen> createState() => _WellnessCheckInScreenState();
}

class _WellnessCheckInScreenState extends ConsumerState<WellnessCheckInScreen> {
  int _sleepQuality = 3;
  int _muscleSoreness = 3;
  int _energyLevels = 3;
  int _stressLevels = 3;
  int _mood = 3;
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      final checkIn = WellnessCheckIn(
        sleepQuality: _sleepQuality,
        soreness: _muscleSoreness,
        fatigue: _energyLevels, // Mapping for backward compatibility in this screen
        mood: _mood,
        stress: _stressLevels,
        painTightness: 1, // Default for this screen
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );
      await ref.read(healthDashboardProvider.notifier).submitWellness(checkIn);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit wellness: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        title: const Text('Wellness Check-in'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RatingSection(
              title: 'Sleep Quality',
              subtitle: 'How well did you sleep last night?',
              value: _sleepQuality,
              onChanged: (v) => setState(() => _sleepQuality = v),
              icons: const [
                Icons.sentiment_very_dissatisfied_rounded,
                Icons.sentiment_dissatisfied_rounded,
                Icons.sentiment_neutral_rounded,
                Icons.sentiment_satisfied_rounded,
                Icons.sentiment_very_satisfied_rounded,
              ],
            ),
            const SizedBox(height: 24),
            _RatingSection(
              title: 'Muscle Soreness',
              subtitle: 'Any pain or stiffness today?',
              value: _muscleSoreness,
              onChanged: (v) => setState(() => _muscleSoreness = v),
              reverseColor: true,
            ),
            const SizedBox(height: 24),
            _RatingSection(
              title: 'Energy Levels',
              subtitle: 'How energized do you feel?',
              value: _energyLevels,
              onChanged: (v) => setState(() => _energyLevels = v),
            ),
            const SizedBox(height: 24),
            _RatingSection(
              title: 'Stress Levels',
              subtitle: 'How much pressure are you feeling?',
              value: _stressLevels,
              onChanged: (v) => setState(() => _stressLevels = v),
              reverseColor: true,
            ),
            const SizedBox(height: 24),
            _RatingSection(
              title: 'Mood',
              subtitle: 'General emotional well-being',
              value: _mood,
              onChanged: (v) => setState(() => _mood = v),
            ),
            const SizedBox(height: 24),
            Text(
              'Notes (Optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add any details about how you feel...',
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Submit Check-in'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _RatingSection extends StatelessWidget {
  const _RatingSection({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.icons,
    this.reverseColor = false,
  });

  final String title;
  final String subtitle;
  final int value;
  final ValueChanged<int> onChanged;
  final List<IconData>? icons;
  final bool reverseColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            final rating = index + 1;
            final isSelected = value == rating;
            
            Color color;
            if (reverseColor) {
              color = Color.lerp(context.accent, context.danger, index / 4)!;
            } else {
              color = Color.lerp(context.danger, context.accent, index / 4)!;
            }

            return GestureDetector(
              onTap: () => onChanged(rating),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected ? color : context.panel,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? color : context.stroke,
                    width: 2,
                  ),
                ),
                child: Icon(
                  icons != null ? icons![index] : _defaultIcon(rating),
                  color: isSelected ? Colors.white : context.fgSub,
                  size: 28,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  IconData _defaultIcon(int rating) {
    return switch (rating) {
      1 => Icons.filter_1_rounded,
      2 => Icons.filter_2_rounded,
      3 => Icons.filter_3_rounded,
      4 => Icons.filter_4_rounded,
      5 => Icons.filter_5_rounded,
      _ => Icons.star_rounded,
    };
  }
}
