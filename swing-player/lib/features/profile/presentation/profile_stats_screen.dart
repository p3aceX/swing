import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../data/ball_type_stats_provider.dart';
import '../data/stats_extended_provider.dart';
import '../domain/profile_models.dart';

class ProfileStatsScreen extends StatelessWidget {
  const ProfileStatsScreen({
    super.key,
    required this.data,
  });

  final PlayerProfilePageData data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        title: const Text('Stats'),
        backgroundColor: context.bg,
      ),
      body: SafeArea(
        child: ProfileStatsContent(data: data),
      ),
    );
  }
}

class ProfileStatsContent extends ConsumerStatefulWidget {
  const ProfileStatsContent({
    super.key,
    required this.data,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 24),
  });

  final PlayerProfilePageData data;
  final EdgeInsetsGeometry padding;

  @override
  ConsumerState<ProfileStatsContent> createState() =>
      _ProfileStatsContentState();
}

class _ProfileStatsContentState extends ConsumerState<ProfileStatsContent>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(ballTypeStatsProvider(widget.data.identity.id));
    final notifier =
        ref.read(ballTypeStatsProvider(widget.data.identity.id).notifier);
    final extended = ref.watch(statsExtendedProvider(widget.data.identity.id));

    if (!extended.hasLoaded && !extended.isLoading) {
      Future.microtask(
        () => ref
            .read(statsExtendedProvider(widget.data.identity.id).notifier)
            .load(),
      );
    }

    if (s.error != null && !s.hasData) {
      return Padding(
        padding: widget.padding,
        child: Column(
          children: [
            _BallTypeToggle(
              selected: s.ballType,
              onChanged: (bt) => notifier.load(bt),
            ),
            const Spacer(),
            Icon(Icons.bar_chart_rounded, size: 40, color: context.fgSub),
            const SizedBox(height: 12),
            Text(s.error!,
                style: TextStyle(color: context.fgSub, fontSize: 14)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => notifier.load(s.ballType),
              child: const Text('Retry'),
            ),
            const Spacer(),
          ],
        ),
      );
    }

    return Padding(
      padding: widget.padding,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ball type toggle
            _BallTypeToggle(
              selected: s.ballType,
              onChanged: (bt) => notifier.load(bt),
            ),
            const SizedBox(height: 10),
            // Tab bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              alignment: Alignment.center,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.center,
                indicatorColor: context.accent,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: context.fg,
                unselectedLabelColor: context.fgSub,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'Batting'),
                  Tab(text: 'Bowling'),
                  Tab(text: 'Fielding'),
                  Tab(text: 'Match'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _StatsTabContent(
                    children: [
                      _CategorySection(
                        title: 'Batting Stats',
                        isLoading: s.isLoading,
                        rows: [
                          [
                            _MetricData('Total Runs', '${s.totalRuns}'),
                            _MetricData(
                                'Overs Faced', _ballsToOvers(s.totalBallsFaced)),
                            _MetricData(
                                'Highest Score', '${s.highestScore}'),
                          ],
                          [
                            _MetricData(
                                'Average', _oneDecimal(s.battingAverage)),
                            _MetricData(
                                'Strike Rate', _oneDecimal(s.strikeRate)),
                            _MetricData('Fours', '${s.fours}'),
                          ],
                          [
                            _MetricData('Sixes', '${s.sixes}'),
                            _MetricData('Fifties', '${s.fifties}'),
                            _MetricData('Hundreds', '${s.hundreds}'),
                          ],
                        ],
                      ),
                    ],
                  ),
                  _StatsTabContent(
                    children: [
                      _CategorySection(
                        title: 'Bowling Stats',
                        isLoading: s.isLoading,
                        rows: [
                          [
                            _MetricData(
                                'Total Wickets', '${s.totalWickets}'),
                            _MetricData('Overs Bowled',
                                _ballsToOvers(s.totalBallsBowled)),
                            _MetricData('Best Bowling', s.bestBowling),
                          ],
                          [
                            _MetricData(
                                'Average', _oneDecimal(s.bowlingAverage)),
                            _MetricData('Economy', _oneDecimal(s.economy)),
                            _MetricData('Strike Rate',
                                _oneDecimal(s.bowlingStrikeRate)),
                          ],
                          [
                            _MetricData('5W Hauls', '${s.fiveWicketHauls}'),
                            _MetricData('Maidens', '${s.maidens}'),
                            _MetricData('Dot Balls', '${s.dotBalls}'),
                          ],
                        ],
                      ),
                    ],
                  ),
                  _StatsTabContent(
                    children: [
                      _CategorySection(
                        title: 'Fielding Stats',
                        isLoading: s.isLoading,
                        rows: [
                          [
                            _MetricData('Catches', '${s.catches}'),
                            _MetricData('Stumpings', '${s.stumpings}'),
                            _MetricData('Run-Outs', '${s.runOuts}'),
                          ],
                        ],
                      ),
                    ],
                  ),
                  _StatsTabContent(
                    children: [
                      _CategorySection(
                        title: 'Match Summary',
                        isLoading: s.isLoading,
                        rows: [
                          [
                            _MetricData('Total Matches', '${s.totalMatches}'),
                            _MetricData('Wins', '${s.wins}'),
                            _MetricData('Losses', '${s.losses}'),
                          ],
                          [
                            _MetricData(
                                'Win %',
                                '${s.winPct.toStringAsFixed(1)}%'),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      _ExtendedMetricsSection(state: extended),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}

// ─── Ball Type Toggle ─────────────────────────────────────────────────────────

class _BallTypeToggle extends StatelessWidget {
  const _BallTypeToggle({
    required this.selected,
    required this.onChanged,
  });

  final BallType selected;
  final ValueChanged<BallType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: context.panel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.stroke),
      ),
      child: Row(
        children: BallType.values.map((bt) {
          final isSelected = bt == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(bt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: isSelected ? context.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: Text(
                  bt.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : context.fgSub,
                  ),
                ),
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}

// ─── Tab Content ──────────────────────────────────────────────────────────────

class _StatsTabContent extends StatelessWidget {
  const _StatsTabContent({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      children: children,
      physics: const BouncingScrollPhysics(),
      primary: false,
    );
  }
}

// ─── Category Section ─────────────────────────────────────────────────────────

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.title,
    required this.rows,
    this.isLoading = false,
  });

  final String title;
  final List<List<_MetricData>> rows;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.stroke),
      ),
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
          const SizedBox(height: 12),
          for (var i = 0; i < rows.length; i++) ...[
            Row(
              children: rows[i]
                  .map(
                    (metric) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: isLoading
                            ? const _SkeletonTile()
                            : _MetricTile(metric: metric),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
            if (i != rows.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

// ─── Skeleton Tile ────────────────────────────────────────────────────────────

class _SkeletonTile extends StatelessWidget {
  const _SkeletonTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      decoration: BoxDecoration(
        color: context.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.stroke.withValues(alpha: 0.65)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 10,
            width: 48,
            decoration: BoxDecoration(
              color: context.stroke.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Container(
            height: 18,
            width: 36,
            decoration: BoxDecoration(
              color: context.stroke.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Metric Tile ──────────────────────────────────────────────────────────────

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.metric});
  final _MetricData metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      decoration: BoxDecoration(
        color: context.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.stroke.withValues(alpha: 0.65)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            metric.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          Text(
            metric.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.fg,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricData {
  const _MetricData(this.label, this.value);
  final String label;
  final String value;
}

class _ExtendedMetricsSection extends StatelessWidget {
  const _ExtendedMetricsSection({
    required this.state,
  });

  final StatsExtendedState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && !state.hasLoaded) {
      return _extendedShell(
        context,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (state.isLocked) {
      return _extendedShell(
        context,
        child: Row(
          children: [
            Icon(Icons.lock_outline_rounded, color: context.warn, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                state.lockMessage?.trim().isNotEmpty == true
                    ? state.lockMessage!.trim()
                    : 'Unlock the APEX Pack to view extended metrics.',
                style: TextStyle(color: context.fgSub, fontSize: 12.5),
              ),
            ),
          ],
        ),
      );
    }

    if (state.error != null && state.metrics.isEmpty) {
      return _extendedShell(
        context,
        child: Text(
          state.error!,
          style: TextStyle(color: context.fgSub, fontSize: 12.5),
        ),
      );
    }

    if (state.metrics.isEmpty) {
      return _extendedShell(
        context,
        child: Text(
          'No extended metrics available yet.',
          style: TextStyle(color: context.fgSub, fontSize: 12.5),
        ),
      );
    }

    final entries = state.metrics.entries.toList(growable: false)
      ..sort((a, b) => a.key.compareTo(b.key));
    final visible = entries.take(6).toList(growable: false);

    return _extendedShell(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: visible
                .map(
                  (entry) => _ExtendedMetricTile(
                    label: _formatMetricLabel(entry.key),
                    value: _formatMetricValue(entry.value),
                  ),
                )
                .toList(growable: false),
          ),
          if (entries.length > visible.length) ...[
            const SizedBox(height: 10),
            Text(
              '+${entries.length - visible.length} more metrics',
              style: TextStyle(
                color: context.fgSub,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _extendedShell(
    BuildContext context, {
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Premium Metrics',
            style: TextStyle(
              color: context.fg,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  String _formatMetricLabel(String raw) {
    final normalized = raw.replaceAll('_', ' ').trim();
    if (normalized.isEmpty) return '-';
    return normalized
        .split(RegExp(r'\s+'))
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  String _formatMetricValue(Object? value) {
    if (value == null) return '-';
    if (value is num) {
      if (value == value.roundToDouble()) return value.toStringAsFixed(0);
      return value.toStringAsFixed(1);
    }
    final text = '$value'.trim();
    return text.isEmpty ? '-' : text;
  }
}

class _ExtendedMetricTile extends StatelessWidget {
  const _ExtendedMetricTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 142,
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 8),
      decoration: BoxDecoration(
        color: context.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.stroke.withValues(alpha: 0.65)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.fg,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _oneDecimal(num value) => value.toStringAsFixed(1);

String _ballsToOvers(int balls) {
  if (balls <= 0) return '0.0';
  final overs = balls ~/ 6;
  final rem = balls % 6;
  return '$overs.$rem';
}
