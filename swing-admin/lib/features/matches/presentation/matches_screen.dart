import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../data/matches_repository.dart';
import '../domain/admin_match.dart';

enum _TrendGranularity {
  day('Day'),
  month('Month'),
  year('Year');

  const _TrendGranularity(this.label);
  final String label;
}

enum MatchStatusFilter {
  all('All', null, '/matches'),
  live('Live', 'IN_PROGRESS', '/matches/live'),
  scheduled('Scheduled', 'SCHEDULED', '/matches/scheduled'),
  complete('Complete', 'COMPLETED', '/matches/complete');

  const MatchStatusFilter(this.label, this.apiStatus, this.path);

  final String label;
  final String? apiStatus;
  final String path;
}

class MatchesScreen extends ConsumerStatefulWidget {
  const MatchesScreen({super.key, this.status = MatchStatusFilter.all});

  final MatchStatusFilter status;

  @override
  ConsumerState<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends ConsumerState<MatchesScreen> {
  String _search = '';

  void _showTrendSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (_) => const _MatchesTrendSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;
    final query = MatchesQuery(
      status: widget.status.apiStatus,
      search: _search.isEmpty ? null : _search,
    );
    final asyncPage = ref.watch(matchesListProvider(query));
    final summary = ref.watch(matchesSummaryProvider);

    return Scaffold(
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(matchesSummaryProvider);
            ref.invalidate(matchesTrendItemsProvider);
            ref.invalidate(matchesListProvider(query));
            await ref.read(matchesListProvider(query).future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              _PageHeader(
                title: 'Matches',
                actionLabel: compact ? 'Trend' : null,
                onTrendTap: _showTrendSheet,
              ),
              const SizedBox(height: 12),
              _SummaryStrip(async: summary),
              const SizedBox(height: 12),
              _StatusTabs(
                currentPath: widget.status.path,
                tabs: MatchStatusFilter.values
                    .map((filter) => _StatusTabItem(
                          label: filter.label,
                          path: filter.path,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 10),
              _SearchField(
                hintText: 'Search teams, venue, round, or match id',
                onChanged: (value) => setState(() => _search = value.trim()),
              ),
              const SizedBox(height: 12),
              asyncPage.when(
                data: (page) => _MatchesList(page: page),
                loading: () => const _LoadingCard(),
                error: (error, _) => _ErrorCard(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(matchesListProvider(query)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    required this.onTrendTap,
    this.actionLabel,
  });

  final String title;
  final VoidCallback onTrendTap;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Track match operations from one queue.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (actionLabel == null)
          IconButton(
            onPressed: onTrendTap,
            icon: const Icon(Icons.show_chart_rounded, size: 20),
            tooltip: 'Growth trend',
          )
        else
          OutlinedButton.icon(
            onPressed: onTrendTap,
            icon: const Icon(Icons.show_chart_rounded, size: 16),
            label: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.async});

  final AsyncValue<MatchOpsSummary> async;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: async.when(
        data: (data) {
          final cards = [
            _SummaryCell(label: 'Total', value: '${data.total}'),
            _SummaryCell(label: 'Live', value: '${data.live}'),
            _SummaryCell(label: 'Scheduled', value: '${data.scheduled}'),
            _SummaryCell(label: 'Complete', value: '${data.complete}'),
          ];
          return Row(
            children: [
              for (var index = 0; index < cards.length; index++) ...[
                Expanded(child: cards[index]),
                if (index < cards.length - 1) const SizedBox(width: 8),
              ],
            ],
          );
        },
        loading: () => const SizedBox(
          height: 48,
          child: Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        error: (_, _) => const SizedBox.shrink(),
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  const _SummaryCell({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTabItem {
  const _StatusTabItem({
    required this.label,
    required this.path,
  });

  final String label;
  final String path;
}

class _StatusTabs extends StatelessWidget {
  const _StatusTabs({
    required this.currentPath,
    required this.tabs,
  });

  final String currentPath;
  final List<_StatusTabItem> tabs;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final tab in tabs) ...[
            _StatusTabChip(
              label: tab.label,
              selected: currentPath == tab.path,
              onTap: () => context.go(tab.path),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _StatusTabChip extends StatelessWidget {
  const _StatusTabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.textPrimary : AppColors.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.textPrimary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _GranularityTabs extends StatelessWidget {
  const _GranularityTabs({
    required this.current,
    required this.onChanged,
  });

  final _TrendGranularity current;
  final ValueChanged<_TrendGranularity> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in _TrendGranularity.values)
          _StatusTabChip(
            label: item.label,
            selected: current == item,
            onTap: () => onChanged(item),
          ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.hintText,
    required this.onChanged,
  });

  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(
          Icons.search,
          size: 18,
          color: AppColors.textMuted,
        ),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 38, minHeight: 38),
        isDense: true,
        filled: true,
        fillColor: AppColors.surface,
      ),
    );
  }
}

class _MatchesList extends StatelessWidget {
  const _MatchesList({required this.page});

  final AdminMatchesPage page;

  @override
  Widget build(BuildContext context) {
    if (page.matches.isEmpty) {
      return const _EmptyCard(message: 'No matches found for this state.');
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Match list',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '${page.total} total',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          for (var index = 0; index < page.matches.length; index++) ...[
            _MatchRow(match: page.matches[index]),
            if (index < page.matches.length - 1)
              const Divider(height: 1, indent: 18, endIndent: 18),
          ],
        ],
      ),
    );
  }
}

class _MatchRow extends StatelessWidget {
  const _MatchRow({required this.match});

  final AdminMatch match;

  @override
  Widget build(BuildContext context) {
    final scheduled = match.scheduledAt ?? match.createdAt;
    final timeLabel = scheduled == null
        ? 'Time pending'
        : DateFormat('dd MMM, h:mm a').format(scheduled.toLocal());
    final venueLabel = match.venueName.trim().isEmpty
        ? 'Venue pending'
        : match.venueName.trim();
    final inningsText = match.innings.isEmpty
        ? 'No innings yet'
        : match.innings
            .map((entry) =>
                'I${entry.inningsNumber} ${entry.totalRuns}/${entry.totalWickets}')
            .join(' • ');

    return InkWell(
      onTap: () => context.go('/matches/${match.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match.displayTitle,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$venueLabel • $timeLabel',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(
                  label: _formatStatus(match.status),
                  tone: _toneForMatch(match.status),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (match.round.trim().isNotEmpty)
                  _MetaPill(icon: Icons.flag_outlined, label: match.round.trim()),
                if (match.matchType.trim().isNotEmpty)
                  _MetaPill(
                    icon: Icons.category_outlined,
                    label: _prettyLabel(match.matchType),
                  ),
                if (match.format.trim().isNotEmpty)
                  _MetaPill(
                    icon: Icons.view_week_outlined,
                    label: _prettyLabel(match.format),
                  ),
                if (match.hasLiveStream)
                  const _MetaPill(
                    icon: Icons.live_tv_outlined,
                    label: 'Stream linked',
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              inningsText,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchesTrendSheet extends ConsumerStatefulWidget {
  const _MatchesTrendSheet();

  @override
  ConsumerState<_MatchesTrendSheet> createState() => _MatchesTrendSheetState();
}

class _MatchesTrendSheetState extends ConsumerState<_MatchesTrendSheet> {
  _TrendGranularity _granularity = _TrendGranularity.day;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(matchesTrendItemsProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        child: async.when(
          data: (items) {
            final points = _buildMatchTrendPoints(items, _granularity);
            final total = points.fold<int>(0, (sum, point) => sum + point.count);
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Match growth',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$total matches in the selected trend window',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                _GranularityTabs(
                  current: _granularity,
                  onChanged: (next) => setState(() => _granularity = next),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: _TrendChart(points: points),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final point in points)
                      _TrendChip(
                        label: point.label,
                        value: point.count.toString(),
                      ),
                  ],
                ),
              ],
            );
          },
          loading: () => const SizedBox(
            height: 180,
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (e, _) => Text(
            e.toString(),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.danger,
            ),
          ),
        ),
      ),
    );
  }
}

class _TrendPoint {
  const _TrendPoint({
    required this.bucket,
    required this.label,
    required this.count,
  });

  final DateTime bucket;
  final String label;
  final int count;
}

List<_TrendPoint> _buildMatchTrendPoints(
  List<AdminMatch> items,
  _TrendGranularity granularity,
) {
  final now = DateTime.now();
  late final List<DateTime> buckets;
  late final String Function(DateTime) labelFor;
  switch (granularity) {
    case _TrendGranularity.day:
      buckets = List.generate(7, (index) {
        final target = now.subtract(Duration(days: 6 - index));
        return DateTime(target.year, target.month, target.day);
      });
      labelFor = (date) => DateFormat('d MMM').format(date);
      break;
    case _TrendGranularity.month:
      buckets = List.generate(6, (index) {
        final target = DateTime(now.year, now.month - (5 - index), 1);
        return DateTime(target.year, target.month, 1);
      });
      labelFor = (date) => DateFormat('MMM yy').format(date);
      break;
    case _TrendGranularity.year:
      buckets = List.generate(4, (index) {
        final year = now.year - (3 - index);
        return DateTime(year, 1, 1);
      });
      labelFor = (date) => DateFormat('yyyy').format(date);
      break;
  }
  final counts = <DateTime, int>{for (final bucket in buckets) bucket: 0};
  for (final item in items) {
    final source = item.scheduledAt ?? item.createdAt;
    if (source == null) continue;
    late final DateTime bucket;
    switch (granularity) {
      case _TrendGranularity.day:
        bucket = DateTime(source.year, source.month, source.day);
        break;
      case _TrendGranularity.month:
        bucket = DateTime(source.year, source.month, 1);
        break;
      case _TrendGranularity.year:
        bucket = DateTime(source.year, 1, 1);
        break;
    }
    if (counts.containsKey(bucket)) {
      counts[bucket] = counts[bucket]! + 1;
    }
  }
  return [
    for (final bucket in buckets)
      _TrendPoint(
        bucket: bucket,
        label: labelFor(bucket),
        count: counts[bucket] ?? 0,
      ),
  ];
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.points});

  final List<_TrendPoint> points;

  @override
  Widget build(BuildContext context) {
    final maxValue =
        points.isEmpty ? 1 : points.map((e) => e.count).reduce(math.max).clamp(1, 1 << 30);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 28,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$maxValue',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              Text('${(maxValue / 2).round()}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              const Text('0',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final point in points)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          point.count.toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: point.count / maxValue,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFFF0C2A8),
                                      Color(0xFFDD7E58),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          point.label,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TrendChip extends StatelessWidget {
  const _TrendChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F1E8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label  $value',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.tone,
  });

  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: tone,
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

String _formatStatus(String status) {
  return status.replaceAll('_', ' ').trim();
}

String _prettyLabel(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return 'Not available';
  return trimmed
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0]}${part.substring(1).toLowerCase()}')
      .join(' ');
}

Color _toneForMatch(String status) {
  switch (status) {
    case 'IN_PROGRESS':
      return const Color(0xFFBE5A3A);
    case 'COMPLETED':
      return const Color(0xFF2E7D32);
    case 'SCHEDULED':
      return const Color(0xFF8A6A42);
    default:
      return AppColors.textSecondary;
  }
}
