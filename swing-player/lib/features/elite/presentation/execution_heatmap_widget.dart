import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/elite_controller.dart';
import '../domain/elite_models.dart';

class ExecutionHeatmapWidget extends ConsumerWidget {
  const ExecutionHeatmapWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(executionStreakProvider);

    return streakAsync.when(
      loading: () => _HeatmapSkeleton(),
      error: (_, __) => const _HeatmapError(),
      data: (entries) => _HeatmapContent(entries: entries),
    );
  }
}

class _HeatmapContent extends StatelessWidget {
  final List<ExecutionStreakEntry> entries;

  const _HeatmapContent({required this.entries});

  @override
  Widget build(BuildContext context) {
    final stats = _computeStats(entries);
    final grid = _buildGrid(entries);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatsRow(stats: stats),
        const SizedBox(height: 12),
        _Grid(grid: grid),
        const SizedBox(height: 8),
        _Legend(),
      ],
    );
  }

  /// Builds a 52-week × 7-day grid starting from Monday 52 weeks ago.
  List<List<ExecutionStreakEntry?>> _buildGrid(
      List<ExecutionStreakEntry> entries) {
    final byDate = <String, ExecutionStreakEntry>{};
    for (final e in entries) {
      final key =
          '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}';
      byDate[key] = e;
    }

    final today = DateTime.now();
    // Find the most recent Sunday (end of grid)
    final daysFromSunday = today.weekday % 7; // Sun=0, Mon=1, ..., Sat=6
    final gridEnd = today.subtract(Duration(days: daysFromSunday));
    final gridStart = gridEnd.subtract(const Duration(days: 364));

    // Build 53 columns (weeks), 7 rows (Mon-Sun)
    final weeks = <List<ExecutionStreakEntry?>>[];
    var weekStart = gridStart;
    while (!weekStart.isAfter(gridEnd)) {
      final week = <ExecutionStreakEntry?>[];
      for (var d = 0; d < 7; d++) {
        final day = weekStart.add(Duration(days: d));
        if (day.isAfter(today)) {
          week.add(null);
        } else {
          final key =
              '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
          week.add(byDate[key]);
        }
      }
      weeks.add(week);
      weekStart = weekStart.add(const Duration(days: 7));
    }
    return weeks;
  }

  _HeatmapStats _computeStats(List<ExecutionStreakEntry> entries) {
    if (entries.isEmpty) {
      return const _HeatmapStats(
          currentStreak: 0, bestStreak: 0, avgScore: 0);
    }

    final sorted = [...entries]..sort((a, b) => b.date.compareTo(a.date));
    final today = DateTime.now();
    final todayNorm =
        DateTime(today.year, today.month, today.day);

    // Current streak
    int current = 0;
    var expected = todayNorm;
    for (final e in sorted) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      if (d == expected && e.score > 0) {
        current++;
        expected = expected.subtract(const Duration(days: 1));
      } else if (d.isBefore(expected)) {
        break;
      }
    }

    // Best streak (scan ascending)
    final asc = [...entries]..sort((a, b) => a.date.compareTo(b.date));
    int best = 0;
    int run = 0;
    DateTime? prev;
    for (final e in asc) {
      if (e.score <= 0) {
        run = 0;
        prev = null;
        continue;
      }
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      if (prev == null ||
          d.difference(prev).inDays == 1) {
        run++;
        if (run > best) best = run;
      } else {
        run = 1;
      }
      prev = d;
    }

    // Include all days up to today in average to reflect Plan vs Execution %
    // This treats Missing Logs and Cheat Days (0%) as Indiscipline.
    final byDate = {
      for (var e in entries)
        DateTime(e.date.year, e.date.month, e.date.day): e.score
    };

    double totalScore = 0;
    int dayCount = 0;
    
    // Scan available history up to today
    final earliest = entries.map((e) => e.date).reduce((a, b) => a.isBefore(b) ? a : b);
    var cursor = DateTime(earliest.year, earliest.month, earliest.day);
    while (!cursor.isAfter(todayNorm)) {
      totalScore += byDate[cursor] ?? 0.0;
      dayCount++;
      cursor = cursor.add(const Duration(days: 1));
    }

    final avg = dayCount == 0 ? 0.0 : totalScore / dayCount;

    return _HeatmapStats(
        currentStreak: current, bestStreak: best, avgScore: avg);
  }
}

class _HeatmapStats {
  final int currentStreak;
  final int bestStreak;
  final double avgScore;

  const _HeatmapStats({
    required this.currentStreak,
    required this.bestStreak,
    required this.avgScore,
  });
}

class _StatsRow extends StatelessWidget {
  final _HeatmapStats stats;

  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(
          label: 'Current',
          value: '${stats.currentStreak}d',
          icon: Icons.local_fire_department_rounded,
          color: context.warn,
        ),
        const SizedBox(width: 8),
        _StatChip(
          label: 'Best',
          value: '${stats.bestStreak}d',
          icon: Icons.emoji_events_rounded,
          color: context.gold,
        ),
        const SizedBox(width: 8),
        _StatChip(
          label: 'Avg EE%',
          value: '${stats.avgScore.toStringAsFixed(0)}%',
          icon: Icons.show_chart_rounded,
          color: context.accent,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.stroke),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        color: context.fg,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
                Text(label,
                    style:
                        TextStyle(color: context.fgSub, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  final List<List<ExecutionStreakEntry?>> grid;
  static const _gap = 2.0;

  const _Grid({required this.grid});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true, // show most recent on the right
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: grid.reversed.map((week) {
          return Padding(
            padding: const EdgeInsets.only(right: _gap),
            child: Column(
              children: week.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: _gap),
                  child: _Cell(entry: entry),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final ExecutionStreakEntry? entry;
  static const _size = 10.0;

  const _Cell({this.entry});

  @override
  Widget build(BuildContext context) {
    final color = _cellColor(context, entry);
    return Tooltip(
      message: entry != null
          ? '${entry!.date.day}/${entry!.date.month}: ${entry!.score.toStringAsFixed(0)}% EE'
          : '',
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Color _cellColor(BuildContext context, ExecutionStreakEntry? entry) {
    if (entry == null) return context.danger.withValues(alpha: 0.25);
    return switch (entry.intensity) {
      ExecutionIntensity.indiscipline => context.danger,
      ExecutionIntensity.low => const Color(0xFF1A4830),
      ExecutionIntensity.medium => const Color(0xFF2E7A50),
      ExecutionIntensity.high => const Color(0xFF3FA66A),
    };
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('Less', style: TextStyle(color: context.fgSub, fontSize: 10)),
        const SizedBox(width: 4),
        ...[
          context.danger,
          const Color(0xFF1A4830),
          const Color(0xFF2E7A50),
          const Color(0xFF3FA66A),
        ].map((c) => Padding(
              padding: const EdgeInsets.only(left: 3),
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            )),
        const SizedBox(width: 4),
        Text('More', style: TextStyle(color: context.fgSub, fontSize: 10)),
      ],
    );
  }
}

class _HeatmapSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: context.accent,
          ),
        ),
      ),
    );
  }
}

class _HeatmapError extends StatelessWidget {
  const _HeatmapError();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      alignment: Alignment.center,
      child: Text(
        'Could not load execution history',
        style: TextStyle(color: context.fgSub, fontSize: 13),
      ),
    );
  }
}
