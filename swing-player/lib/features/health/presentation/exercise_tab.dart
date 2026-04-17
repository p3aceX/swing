import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../controller/health_integration_controller.dart';
import '../domain/health_integration_models.dart';
import '../domain/health_models.dart';
import '../../matches/controller/matches_controller.dart';
import '../../matches/domain/match_models.dart';
import 'widgets/exercise_widgets.dart';
import 'widgets/metric_widgets.dart';
import 'widgets/workload_log_sheet.dart';

class ExerciseTab extends ConsumerWidget {
  const ExerciseTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthData = ref.watch(recentHealthDataProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        const _TrainingCommandDeck(),
        const SizedBox(height: 24),
        _SmartLogPrompts(
          matchesState: ref.watch(matchesControllerProvider),
          healthData: healthData,
        ),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Training Shortcuts'),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.42,
          children: const [
            _ShortcutCard(
              label: 'Bowling Nets',
              icon: Icons.sports_baseball_rounded,
              type: WorkloadType.BOWLING_NETS,
            ),
            _ShortcutCard(
              label: 'Batting Nets',
              icon: Icons.sports_cricket_rounded,
              type: WorkloadType.BATTING_NETS,
            ),
            _ShortcutCard(
              label: 'Power Gym',
              icon: Icons.fitness_center_rounded,
              type: WorkloadType.STRENGTH,
            ),
            _ShortcutCard(
              label: 'Speed Session',
              icon: Icons.directions_run_rounded,
              type: WorkloadType.RUNNING,
            ),
          ],
        ),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Digital Training Packs'),
        SizedBox(
          height: 214,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              _TrainingPackCard(
                title: 'Boundary Forge',
                subtitle:
                    'Explosive strength plan for cleaner six-hitting power.',
                accent: Color(0xFFD7A94B),
                badge: 'Power Pack',
                meta: '6 weeks · Gym + Bat Speed',
                icon: Icons.bolt_rounded,
              ),
              SizedBox(width: 12),
              _TrainingPackCard(
                title: 'Pace Builder Lab',
                subtitle:
                    'Build run-up speed, force transfer, and repeatable pace.',
                accent: Color(0xFF6D8FB5),
                badge: 'Fast Bowling',
                meta: '4 weeks · Speed + Mobility',
                icon: Icons.air_rounded,
              ),
              SizedBox(width: 12),
              _TrainingPackCard(
                title: 'Second-Spell Engine',
                subtitle:
                    'Conditioning blocks designed for late-session sharpness.',
                accent: Color(0xFF3FA66A),
                badge: 'Endurance',
                meta: '3 phases · Conditioning',
                icon: Icons.timelapse_rounded,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Health Passes', actionLabel: 'Locked'),
        const _LockedHealthPassesSection(),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Recent Activity'),
        healthData.when(
          data: (payload) {
            if (payload.workouts.isEmpty) {
              return const _RecentActivityEmptyState();
            }
            return Column(
              children: payload.workouts
                  .take(5)
                  .map(
                    (w) => RecentWorkoutCard(
                      type: _prettifyWorkoutType(w.type),
                      duration: '${w.durationMinutes} min',
                      date: _timeLabel(w.timestamp),
                      intensity: 'Synced',
                    ),
                  )
                  .toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, __) => const _RecentActivityEmptyState(),
        ),
      ],
    );
  }

  static String _prettifyWorkoutType(String raw) {
    final cleaned = raw.replaceAll('_', ' ').trim();
    if (cleaned.isEmpty) return 'Workout';
    return cleaned
        .split(RegExp(r'\s+'))
        .map((part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}')
        .join(' ');
  }

  static String _timeLabel(DateTime timestamp) {
    final hour = timestamp.hour % 12 == 0 ? 12 : timestamp.hour % 12;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final suffix = timestamp.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}

class _SmartLogPrompts extends StatelessWidget {
  const _SmartLogPrompts({
    required this.matchesState,
    required this.healthData,
  });

  final MatchesState matchesState;
  final AsyncValue<HealthDataPayload> healthData;

  @override
  Widget build(BuildContext context) {
    final latestMatch = _latestPromptMatch(matchesState.matches);
    final latestWorkout = healthData.valueOrNull?.workouts.isEmpty == false
        ? (healthData.valueOrNull!.workouts.toList()
              ..sort((a, b) => b.timestamp.compareTo(a.timestamp)))
            .first
        : null;

    if (latestMatch == null && latestWorkout == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Smart Prompts'),
        if (latestMatch != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SmartPromptCard(
              title: 'Confirm post-match load',
              subtitle:
                  '${latestMatch.title} is complete. Add your RPE and save the session load.',
              eyebrow: 'Auto prompt',
              icon: Icons.scoreboard_rounded,
              accent: context.gold,
              cta: 'Log Match',
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => WorkloadLogSheet(
                    initialType: WorkloadType.MATCH,
                    initialDurationMinutes: 150,
                    initialIntensity: 6,
                    initialOccurredAt:
                        latestMatch.scheduledAt ?? DateTime.now(),
                    initialNotes: 'Post-match load for ${latestMatch.title}',
                    initialSource: 'MATCH_AUTO_PROMPT',
                    initialSourceRefId: latestMatch.id,
                  ),
                );
              },
            ),
          ),
        if (latestWorkout != null)
          _SmartPromptCard(
            title: 'Convert synced workout to training load',
            subtitle:
                '${ExerciseTab._prettifyWorkoutType(latestWorkout.type)} was synced from your device. Confirm it as a workload event.',
            eyebrow: 'Health sync',
            icon: Icons.watch_rounded,
            accent: context.sky,
            cta: 'Use Workout',
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => WorkloadLogSheet(
                  initialType: _typeForWorkout(latestWorkout.type),
                  initialDurationMinutes: latestWorkout.durationMinutes,
                  initialIntensity: 5,
                  initialOccurredAt: latestWorkout.timestamp,
                  initialNotes:
                      'Imported from health sync: ${ExerciseTab._prettifyWorkoutType(latestWorkout.type)}',
                  initialSource: 'HEALTH_SYNC',
                  initialSourceRefId:
                      '${latestWorkout.type}:${latestWorkout.timestamp.toIso8601String()}',
                ),
              );
            },
          ),
      ],
    );
  }

  PlayerMatch? _latestPromptMatch(List<PlayerMatch> matches) {
    final now = DateTime.now();
    final candidates = matches
        .where((m) => m.lifecycle == MatchLifecycle.past)
        .where((m) => m.scheduledAt != null)
        .where((m) => now.difference(m.scheduledAt!).inHours <= 48)
        .toList()
      ..sort((a, b) => b.scheduledAt!.compareTo(a.scheduledAt!));
    return candidates.isEmpty ? null : candidates.first;
  }

  WorkloadType _typeForWorkout(String workoutType) {
    final normalized = workoutType.toLowerCase();
    if (normalized.contains('run') || normalized.contains('cardio')) {
      return WorkloadType.RUNNING;
    }
    if (normalized.contains('strength') ||
        normalized.contains('gym') ||
        normalized.contains('lift')) {
      return WorkloadType.STRENGTH;
    }
    if (normalized.contains('mobility') ||
        normalized.contains('yoga') ||
        normalized.contains('stretch')) {
      return WorkloadType.MOBILITY;
    }
    return WorkloadType.FIELDING;
  }
}

class _SmartPromptCard extends StatelessWidget {
  const _SmartPromptCard({
    required this.title,
    required this.subtitle,
    required this.eyebrow,
    required this.icon,
    required this.accent,
    required this.cta,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String eyebrow;
  final IconData icon;
  final Color accent;
  final String cta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.stroke),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: TextStyle(
                    color: accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: onTap,
                  style: TextButton.styleFrom(
                    foregroundColor: accent,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: Text(
                    cta,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrainingCommandDeck extends StatelessWidget {
  const _TrainingCommandDeck();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.panel,
            Color.alphaBlend(
                context.accent.withValues(alpha: 0.18), context.cardBg),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: context.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.fitness_center_rounded,
                        color: context.accent, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'PLAYER-LED TRAINING',
                      style: TextStyle(
                        color: context.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Train seriously. Log lightly.',
            style: TextStyle(
              color: context.fg,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your workload, power blocks, and future coaching packs all live here. Sessions can be logged in seconds and converted into readiness signals automatically.',
            style: TextStyle(
              color: context.fgSub,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _CommandChip(label: 'Post-match load'),
              _CommandChip(label: 'Nets + gym shortcuts'),
              _CommandChip(label: 'Premium packs ready'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommandChip extends StatelessWidget {
  const _CommandChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.stroke),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: context.fg,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.label,
    required this.icon,
    required this.type,
  });

  final String label;
  final IconData icon;
  final WorkloadType type;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => WorkloadLogSheet(initialType: type),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.stroke),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: context.accent, size: 18),
            ),
            const Spacer(),
            Text(
              label,
              style: TextStyle(
                color: context.fg,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Quick add',
              style: TextStyle(
                color: context.fgSub,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrainingPackCard extends StatelessWidget {
  const _TrainingPackCard({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.badge,
    required this.meta,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final String badge;
  final String meta;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.alphaBlend(accent.withValues(alpha: 0.18), context.panel),
            Color.alphaBlend(accent.withValues(alpha: 0.06), context.cardBg),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              color: context.fg,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  meta,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(Icons.lock_outline_rounded, color: context.fgSub, size: 16),
            ],
          ),
        ],
      ),
    );
  }
}

class _LockedHealthPassesSection extends StatelessWidget {
  const _LockedHealthPassesSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _LockedHealthPassCard(
          title: 'Athlete Recovery Pass',
          subtitle:
              'Gym entry, recovery zone access, and monthly mobility scans.',
          detail: 'Locked · Premium pass coming soon',
          icon: Icons.spa_rounded,
        ),
        SizedBox(height: 12),
        _LockedHealthPassCard(
          title: 'Strength Lab Pass',
          subtitle: 'Partner gym access for force, jump, and lifting blocks.',
          detail: 'Locked · Requires active fitness membership',
          icon: Icons.fitness_center_rounded,
        ),
      ],
    );
  }
}

class _LockedHealthPassCard extends StatelessWidget {
  const _LockedHealthPassCard({
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.stroke),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.panel,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: context.gold, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  detail,
                  style: TextStyle(
                    color: context.gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: context.panel,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lock_rounded, color: context.fgSub, size: 18),
          ),
        ],
      ),
    );
  }
}

class _RecentActivityEmptyState extends StatelessWidget {
  const _RecentActivityEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        children: [
          Icon(Icons.history_rounded,
              color: context.fgSub.withValues(alpha: 0.5), size: 30),
          const SizedBox(height: 10),
          Text(
            'Connect your health device or log a session to start building your activity timeline.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
