import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/host_colors.dart';
import '../../match_detail/data/match_detail_repository.dart';
import '../../match_detail/domain/match_models.dart';
import '../../match_detail/presentation/match_card.dart';

class HostScheduleCallbacks {
  const HostScheduleCallbacks({
    this.onNavigateToMatch,
    this.onStartMatch,
  });

  /// Navigate to match detail (read-only view).
  final void Function(BuildContext context, String matchId)? onNavigateToMatch;

  /// Start scoring a match (toss → scoring). Used for live + today's hosted matches.
  final void Function(BuildContext context, String matchId)? onStartMatch;
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final _hostScheduleProvider = FutureProvider.autoDispose<List<PlayerMatch>>(
  (ref) => ref.watch(hostMatchDetailRepositoryProvider).fetchMyMatches(),
);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class HostScheduleScreen extends ConsumerStatefulWidget {
  const HostScheduleScreen({super.key, required this.callbacks});

  final HostScheduleCallbacks callbacks;

  @override
  ConsumerState<HostScheduleScreen> createState() => _HostScheduleScreenState();
}

class _HostScheduleScreenState extends ConsumerState<HostScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_hostScheduleProvider);

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        foregroundColor: context.fg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Schedule',
          style: TextStyle(
            color: context.fg,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load schedule.\n$e',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.fgSub),
            ),
          ),
        ),
        data: (matches) {
          final now = DateTime.now();
          final todayStart = DateTime(now.year, now.month, now.day);
          final todayEnd = todayStart.add(const Duration(days: 1));

          final today = matches.where((m) {
            final s = m.scheduledAt;
            if (s == null) return false;
            return s.isAfter(todayStart) &&
                s.isBefore(todayEnd) &&
                m.lifecycle != MatchLifecycle.past;
          }).toList()
            ..sort((a, b) =>
                (a.scheduledAt ?? now).compareTo(b.scheduledAt ?? now));

          final upcoming = matches.where((m) {
            final s = m.scheduledAt;
            if (s == null) return false;
            return s.isAfter(todayEnd) &&
                m.lifecycle == MatchLifecycle.upcoming;
          }).toList()
            ..sort((a, b) =>
                (a.scheduledAt ?? now).compareTo(b.scheduledAt ?? now));

          final live = matches
              .where((m) => m.lifecycle == MatchLifecycle.live)
              .toList();

          final completed = matches
              .where((m) => m.lifecycle == MatchLifecycle.past)
              .toList()
            ..sort((a, b) =>
                (b.scheduledAt ?? now).compareTo(a.scheduledAt ?? now));

          if (matches.isEmpty) {
            return _EmptyState(
              onRefresh: () => ref.invalidate(_hostScheduleProvider),
            );
          }

          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(_hostScheduleProvider),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 48),
              children: [
                if (live.isNotEmpty) ...[
                  _SectionHeader(
                    label: 'Live',
                    count: live.length,
                    color: context.success,
                  ),
                  ...live.map((m) => _ScheduleMatchCard(
                        match: m,
                        showStart: false,
                        showContinue: m.canScore,
                        onTap: () => widget.callbacks.onNavigateToMatch
                            ?.call(context, m.id),
                        onAction: m.canScore
                            ? () => widget.callbacks.onStartMatch
                                ?.call(context, m.id)
                            : null,
                      )),
                ],
                if (today.isNotEmpty) ...[
                  _SectionHeader(
                    label: 'Today',
                    count: today.length,
                    color: context.accent,
                  ),
                  ...today.map((m) => _ScheduleMatchCard(
                        match: m,
                        showStart: m.canScore &&
                            m.lifecycle == MatchLifecycle.upcoming,
                        showContinue: false,
                        onTap: () => widget.callbacks.onNavigateToMatch
                            ?.call(context, m.id),
                        onAction: m.canScore
                            ? () => widget.callbacks.onStartMatch
                                ?.call(context, m.id)
                            : null,
                      )),
                ],
                if (upcoming.isNotEmpty) ...[
                  _SectionHeader(
                    label: 'Upcoming',
                    count: upcoming.length,
                    color: context.fgSub,
                  ),
                  ...upcoming.map((m) => _ScheduleMatchCard(
                        match: m,
                        showStart: false,
                        showContinue: false,
                        onTap: () => widget.callbacks.onNavigateToMatch
                            ?.call(context, m.id),
                        onAction: null,
                      )),
                ],
                if (completed.isNotEmpty) ...[
                  _SectionHeader(
                    label: 'Completed',
                    count: completed.length,
                    color: context.fgSub,
                  ),
                  ...completed.map((m) => _ScheduleMatchCard(
                        match: m,
                        showStart: false,
                        showContinue: false,
                        onTap: () => widget.callbacks.onNavigateToMatch
                            ?.call(context, m.id),
                        onAction: null,
                      )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Schedule match card with optional action button
// ---------------------------------------------------------------------------

class _ScheduleMatchCard extends StatelessWidget {
  const _ScheduleMatchCard({
    required this.match,
    required this.showStart,
    required this.showContinue,
    required this.onTap,
    this.onAction,
  });

  final PlayerMatch match;
  final bool showStart;
  final bool showContinue;
  final VoidCallback? onTap;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    if (!showStart && !showContinue) {
      return HostMatchCard(
        match: match,
        onTap: onTap,
        showHostingTag: true,
      );
    }

    final actionLabel = showContinue ? 'Continue' : 'Start';
    final actionIcon = showContinue
        ? Icons.play_circle_filled_rounded
        : Icons.sports_cricket_rounded;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Stack(
        children: [
          HostMatchCard(
            match: match,
            onTap: onTap,
            showHostingTag: true,
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: GestureDetector(
              onTap: onAction,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: showContinue ? context.success : context.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(actionIcon,
                        size: 14,
                        color: showContinue ? context.bg : context.bg),
                    const SizedBox(width: 5),
                    Text(
                      actionLabel,
                      style: TextStyle(
                        color: context.bg,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Container(width: 3, height: 14, color: color),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: context.fg,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_rounded,
                size: 48, color: context.fgSub),
            const SizedBox(height: 16),
            Text(
              'No matches yet',
              style: TextStyle(
                color: context.fg,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate fixtures in a tournament to see the schedule here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: context.fgSub, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
