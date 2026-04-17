import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../controller/fitness_controller.dart';
import '../../domain/fitness_models.dart';

class FitnessLogModal extends ConsumerStatefulWidget {
  const FitnessLogModal({super.key});

  @override
  ConsumerState<FitnessLogModal> createState() => _FitnessLogModalState();
}

class _FitnessLogModalState extends ConsumerState<FitnessLogModal> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logState = ref.watch(fitnessLogControllerProvider);
    final logController = ref.read(fitnessLogControllerProvider.notifier);

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        children: [
          const _ModalHandle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Build your workout',
                        style: TextStyle(
                          color: context.fg,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pick exercises, tune load, then save.',
                        style: TextStyle(
                          color: context.fgSub,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: context.fgSub)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                _WorkoutPlanCard(session: logState.session),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      'Find exercise',
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Tap + to add',
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _ExerciseSearchField(controller: _searchCtrl),
                const SizedBox(height: 12),
                _ExerciseSearchResults(
                  selectedExercises: logState.session.exercises,
                  onSelected: (exercise) {
                    logController.addExercise(exercise);
                    HapticFeedback.lightImpact();
                  },
                ),
                if (logState.session.exercises.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Selected exercises',
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...logState.session.exercises.asMap().entries.map(
                        (entry) => _SelectedExerciseCard(
                          key: ValueKey(entry.value.exercise.id),
                          index: entry.key,
                          entry: entry.value,
                        ),
                      ),
                ],
                const SizedBox(height: 16),
                _IntensitySelector(
                  selected: logState.session.intensity,
                  onSelected: logController.setIntensity,
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: _SaveWorkoutButton(
                state: logState,
                onSave: () async {
                  final success = await logController.submit();
                  if (success && context.mounted) Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutPlanCard extends StatelessWidget {
  const _WorkoutPlanCard({required this.session});
  final WorkoutSession session;

  @override
  Widget build(BuildContext context) {
    final hasExercises = session.exercises.isNotEmpty;
    final exerciseCount = session.exercises.length;
    final totalSets =
        session.exercises.fold<int>(0, (sum, entry) => sum + entry.sets);
    final totalMinutes = session.totalDuration;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasExercises
            ? context.accent.withValues(alpha: 0.08)
            : context.panel.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasExercises
              ? context.accent.withValues(alpha: 0.22)
              : context.stroke.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: context.bg.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  hasExercises
                      ? Icons.playlist_add_check_rounded
                      : Icons.fitness_center_rounded,
                  color: hasExercises ? context.accent : context.fgSub,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your workout',
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      hasExercises
                          ? '$exerciseCount exercise${exerciseCount == 1 ? '' : 's'} selected'
                          : 'Nothing selected yet',
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _IntensityBadge(intensity: session.intensity),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _PlanMetric(
                  label: 'Sets', value: '$totalSets', color: context.gold),
              const SizedBox(width: 8),
              _PlanMetric(
                  label: 'Minutes',
                  value: '${totalMinutes}m',
                  color: context.sky),
              const SizedBox(width: 8),
              _PlanMetric(
                label: 'Fatigue',
                value: session.estimatedFatigueImpact.toStringAsFixed(1),
                color: context.warn,
              ),
            ],
          ),
          if (hasExercises) ...[
            const SizedBox(height: 10),
            Text(
              session.exercises
                  .take(3)
                  .map((entry) => entry.exercise.name)
                  .join(' • '),
              style: TextStyle(
                color: context.fg,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class _PlanMetric extends StatelessWidget {
  const _PlanMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: TextStyle(
                color: context.fgSub,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseSearchField extends ConsumerWidget {
  const _ExerciseSearchField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      controller: controller,
      onChanged: (value) =>
          ref.read(fitnessSearchQueryProvider.notifier).state = value,
      style: TextStyle(color: context.fg, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search sprint, squat, mobility...',
        hintStyle: TextStyle(color: context.fgSub, fontSize: 14),
        prefixIcon: Icon(Icons.search_rounded, color: context.fgSub, size: 20),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.close_rounded, color: context.fgSub, size: 18),
                onPressed: () {
                  controller.clear();
                  ref.read(fitnessSearchQueryProvider.notifier).state = '';
                },
              )
            : null,
        filled: true,
        fillColor: context.cardBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: context.stroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: context.stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: context.accent, width: 1.5),
        ),
      ),
    );
  }
}

class _ExerciseSearchResults extends ConsumerWidget {
  const _ExerciseSearchResults({
    required this.selectedExercises,
    required this.onSelected,
  });

  final List<WorkoutExercise> selectedExercises;
  final ValueChanged<FitnessExercise> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(fitnessSearchQueryProvider);
    if (query.trim().length < 2) {
      return _SearchHint(hasQuery: query.trim().isNotEmpty);
    }

    final results = ref.watch(fitnessSearchProvider);
    return results.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Exercise search failed',
          style: TextStyle(color: context.fgSub),
        ),
      ),
      data: (exercises) {
        if (exercises.isEmpty) return const _SearchHint(hasQuery: true);
        return Column(
          children: exercises.map((exercise) {
            final selectedIndex = selectedExercises
                .indexWhere((entry) => entry.exercise.id == exercise.id);
            return _ExerciseResultCard(
              exercise: exercise,
              isSelected: selectedIndex >= 0,
              onAdd: () => onSelected(exercise),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ExerciseResultCard extends StatelessWidget {
  const _ExerciseResultCard({
    required this.exercise,
    required this.isSelected,
    required this.onAdd,
  });

  final FitnessExercise exercise;
  final bool isSelected;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(context, exercise.category);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected
            ? context.accent.withValues(alpha: 0.08)
            : context.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? context.accent.withValues(alpha: 0.38)
              : context.stroke,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.fitness_center_rounded, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_clean(exercise.category)} • ${exercise.level.name}',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: [
                    if (isSelected)
                      _Tag(label: 'Added to workout', color: context.accent),
                    if (exercise.durationMins != null)
                      _Tag(
                          label: '${exercise.durationMins} min',
                          color: context.sky),
                    if (exercise.defaultSets != null)
                      _Tag(
                          label: '${exercise.defaultSets} sets',
                          color: context.gold),
                    ...exercise.bodyAreaTags.take(2).map(
                          (tag) => _Tag(label: _clean(tag), color: color),
                        ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected ? context.success : context.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isSelected
                    ? Icons.add_circle_outline_rounded
                    : Icons.add_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _categoryColor(BuildContext context, String category) {
    final value = category.toLowerCase();
    if (value.contains('recovery') || value.contains('mobility')) {
      return context.sky;
    }
    if (value.contains('strength')) return context.gold;
    if (value.contains('conditioning') || value.contains('plyo')) {
      return context.danger;
    }
    return context.accent;
  }
}

class _SelectedExerciseCard extends ConsumerWidget {
  const _SelectedExerciseCard({
    super.key,
    required this.index,
    required this.entry,
  });

  final int index;
  final WorkoutExercise entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(fitnessLogControllerProvider.notifier);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.accent.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: context.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    Icon(Icons.check_rounded, color: context.accent, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.exercise.name,
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${_clean(entry.exercise.category)} • intensity ${entry.intensity}/10',
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => controller.removeExercise(entry.exercise.id),
                icon: Icon(Icons.delete_outline_rounded,
                    color: context.danger, size: 19),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _NumberStepper(
                label: 'Sets',
                value: entry.sets,
                min: 1,
                onChanged: (value) =>
                    controller.updateExercise(index, sets: value),
              ),
              const SizedBox(width: 8),
              _NumberStepper(
                label: 'Reps',
                value: entry.reps,
                min: 1,
                onChanged: (value) =>
                    controller.updateExercise(index, reps: value),
              ),
              const SizedBox(width: 8),
              _NumberStepper(
                label: 'Min',
                value: entry.durationMinutes ?? 0,
                min: 0,
                onChanged: (value) =>
                    controller.updateExercise(index, duration: value),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Intensity',
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(
                child: Slider(
                  value: entry.intensity.toDouble().clamp(1, 10),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: context.accent,
                  inactiveColor: context.stroke,
                  label: '${entry.intensity}/10',
                  onChanged: (value) => controller.updateExercise(
                    index,
                    intensity: value.round(),
                  ),
                ),
              ),
              Text(
                '${entry.intensity}/10',
                style: TextStyle(
                  color: context.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NumberStepper extends StatelessWidget {
  const _NumberStepper({
    required this.label,
    required this.value,
    required this.min,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.stroke),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: context.fgSub,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StepButton(
                  icon: Icons.remove_rounded,
                  onTap: () => onChanged((value - 1).clamp(min, 999)),
                ),
                SizedBox(
                  width: 32,
                  child: Text(
                    '$value',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _StepButton(
                  icon: Icons.add_rounded,
                  onTap: () => onChanged(value + 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, color: context.accent, size: 16),
      ),
    );
  }
}

class _IntensitySelector extends StatelessWidget {
  const _IntensitySelector({
    required this.selected,
    required this.onSelected,
  });

  final SessionIntensity selected;
  final ValueChanged<SessionIntensity> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session intensity',
            style: TextStyle(
              color: context.fg,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _IntensityOption(
                label: 'Light',
                intensity: SessionIntensity.low,
                selected: selected,
                onSelected: onSelected,
              ),
              const SizedBox(width: 8),
              _IntensityOption(
                label: 'Moderate',
                intensity: SessionIntensity.moderate,
                selected: selected,
                onSelected: onSelected,
              ),
              const SizedBox(width: 8),
              _IntensityOption(
                label: 'Intense',
                intensity: SessionIntensity.intense,
                selected: selected,
                onSelected: onSelected,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IntensityOption extends StatelessWidget {
  const _IntensityOption({
    required this.label,
    required this.intensity,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final SessionIntensity intensity;
  final SessionIntensity selected;
  final ValueChanged<SessionIntensity> onSelected;

  @override
  Widget build(BuildContext context) {
    final active = intensity == selected;
    final color = switch (intensity) {
      SessionIntensity.low => context.sky,
      SessionIntensity.moderate => context.gold,
      SessionIntensity.intense => context.danger,
    };

    return Expanded(
      child: InkWell(
        onTap: () => onSelected(intensity),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: active ? color.withValues(alpha: 0.14) : context.panel,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: active ? color : context.stroke),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? color : context.fgSub,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SaveWorkoutButton extends StatelessWidget {
  const _SaveWorkoutButton({
    required this.state,
    required this.onSave,
  });

  final FitnessLogState state;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final isEmpty = state.session.exercises.isEmpty;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isEmpty || state.isSubmitting ? null : onSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.accent,
          disabledBackgroundColor: context.accent.withValues(alpha: 0.4),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: state.isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                isEmpty ? 'Add exercises first' : 'Save Workout',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
      ),
    );
  }
}

class _IntensityBadge extends StatelessWidget {
  const _IntensityBadge({required this.intensity});
  final SessionIntensity intensity;

  @override
  Widget build(BuildContext context) {
    final color = switch (intensity) {
      SessionIntensity.low => context.sky,
      SessionIntensity.moderate => context.gold,
      SessionIntensity.intense => context.danger,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        intensity.name,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SearchHint extends StatelessWidget {
  const _SearchHint({required this.hasQuery});
  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.panel.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.stroke.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: context.fgSub, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hasQuery
                  ? 'No exercises found. Try another name or category.'
                  : 'Type at least 2 letters to search the exercise library.',
              style: TextStyle(
                color: context.fgSub,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModalHandle extends StatelessWidget {
  const _ModalHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: context.stroke,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

String _clean(String value) {
  final text = value.replaceAll('_', ' ').trim().toLowerCase();
  if (text.isEmpty) return 'General';
  return text
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
