import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../data/dashboard_repository.dart';

final _lastUpdatedProvider = StateProvider<DateTime?>((_) => null);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardMetricsProvider);

    ref.listen<AsyncValue<DashboardMetrics>>(dashboardMetricsProvider,
        (_, next) {
      next.whenData((_) {
        ref.read(_lastUpdatedProvider.notifier).state = DateTime.now();
      });
    });

    return Scaffold(
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardMetricsProvider);
            await ref.read(dashboardMetricsProvider.future);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: async.when(
                  data: (metrics) => _DashboardContent(metrics: metrics),
                  loading: () => const _LoadingView(),
                  error: (e, _) => _ErrorView(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(dashboardMetricsProvider),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent({required this.metrics});

  final DashboardMetrics metrics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updated = ref.watch(_lastUpdatedProvider);
    final verifiedRate = _safeRate(metrics.verifiedArenas, metrics.totalArenas);
    final swingRate =
        _safeRate(metrics.swingEnabledArenas, metrics.totalArenas);
    final completionRate =
        _safeRate(metrics.completedTournaments, metrics.totalTournaments);
    final liveRate = _safeRate(metrics.liveTournaments, metrics.totalTournaments);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DashboardHero(
          updated: updated,
          verifiedRate: verifiedRate,
          liveRate: liveRate,
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 780;
            final topCards = [
              _MetricCardData(
                label: 'Verified arenas',
                value: _fmt(metrics.verifiedArenas),
                delta: _deltaLabel(verifiedRate),
                positive: true,
                icon: Icons.verified_outlined,
                spark: _sparkFromRates(verifiedRate, swingRate, 0.72),
              ),
              _MetricCardData(
                label: 'Swing enabled',
                value: _fmt(metrics.swingEnabledArenas),
                delta: _deltaLabel(swingRate),
                positive: swingRate >= 0.5,
                icon: Icons.wifi_tethering_outlined,
                spark: _sparkFromRates(swingRate, verifiedRate, 0.48),
              ),
            ];

            final bottomCards = [
              _MetricCardData(
                label: 'Total tournaments',
                value: _fmt(metrics.totalTournaments),
                delta: liveRate == 0
                    ? 'No live events'
                    : '${(liveRate * 100).round()}% live',
                positive: liveRate > 0,
                icon: Icons.emoji_events_outlined,
                spark: _sparkFromRates(
                    _safeRate(metrics.liveTournaments, math.max(metrics.totalTournaments, 1)),
                    completionRate,
                    0.66),
              ),
              _MetricCardData(
                label: 'Completed',
                value: _fmt(metrics.completedTournaments),
                delta: _deltaLabel(completionRate),
                positive: completionRate >= 0.45,
                icon: Icons.flag_outlined,
                spark: _sparkFromRates(completionRate, liveRate, 0.35),
              ),
            ];

            if (stacked) {
              return Column(
                children: [
                  _MetricCardGrid(cards: topCards),
                  const SizedBox(height: 12),
                  _MetricCardGrid(cards: bottomCards),
                ],
              );
            }

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _MetricCard(data: topCards[0])),
                    const SizedBox(width: 12),
                    Expanded(child: _MetricCard(data: topCards[1])),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _MetricCard(data: bottomCards[0])),
                    const SizedBox(width: 12),
                    Expanded(child: _MetricCard(data: bottomCards[1])),
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        _InsightChartCard(metrics: metrics),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 780;
            final arenaCard = _SummaryPanel(
              eyebrow: 'Arena health',
              title: 'Verification and Swing rollout',
              body:
                  'Track how much of the supply base is verified and Swing-ready before scaling bookings and matches.',
              rows: [
                _SummaryRow('Total arenas', _fmt(metrics.totalArenas)),
                _SummaryRow('Verified', '${_fmt(metrics.verifiedArenas)} • ${_pct(verifiedRate)}'),
                _SummaryRow('Swing enabled', '${_fmt(metrics.swingEnabledArenas)} • ${_pct(swingRate)}'),
              ],
            );
            final tournamentCard = _SummaryPanel(
              eyebrow: 'Match ops',
              title: 'Tournament execution',
              body:
                  'Keep an eye on live load versus completed events so ops can spot bottlenecks before they pile up.',
              rows: [
                _SummaryRow('Total tournaments', _fmt(metrics.totalTournaments)),
                _SummaryRow('Live now', _fmt(metrics.liveTournaments)),
                _SummaryRow(
                    'Completion rate', '${_fmt(metrics.completedTournaments)} • ${_pct(completionRate)}'),
              ],
            );

            if (stacked) {
              return Column(
                children: [
                  arenaCard,
                  const SizedBox(height: 12),
                  tournamentCard,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: arenaCard),
                const SizedBox(width: 12),
                Expanded(child: tournamentCard),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({
    required this.updated,
    required this.verifiedRate,
    required this.liveRate,
  });

  final DateTime? updated;
  final double verifiedRate;
  final double liveRate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your ops overview',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'Overview of your\nSwing performance',
                  style: TextStyle(
                    fontSize: 34,
                    height: 1.02,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -1.6,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F6F3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.north_east_rounded,
                  size: 24,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroChip(
                label: 'Verified base',
                value: _pct(verifiedRate),
                positive: true,
              ),
              _HeroChip(
                label: 'Live now',
                value: _pct(liveRate),
                positive: liveRate > 0,
              ),
              _HeroChip(
                label: 'Updated',
                value: updated == null
                    ? 'Waiting'
                    : _relative(updated!),
                positive: null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.label,
    required this.value,
    required this.positive,
  });

  final String label;
  final String value;
  final bool? positive;

  @override
  Widget build(BuildContext context) {
    final background = positive == null
        ? const Color(0xFFF2F2EF)
        : positive!
            ? const Color(0xFFDDF5E4)
            : const Color(0xFFF8D9D6);
    final foreground = positive == null
        ? AppColors.textSecondary
        : positive!
            ? const Color(0xFF0E7A31)
            : const Color(0xFFB4372D);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label ',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: foreground,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCardData {
  const _MetricCardData({
    required this.label,
    required this.value,
    required this.delta,
    required this.positive,
    required this.icon,
    required this.spark,
  });

  final String label;
  final String value;
  final String delta;
  final bool positive;
  final IconData icon;
  final List<double> spark;
}

class _MetricCardGrid extends StatelessWidget {
  const _MetricCardGrid({required this.cards});

  final List<_MetricCardData> cards;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _MetricCard(data: cards[i]),
        ],
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data});

  final _MetricCardData data;

  @override
  Widget build(BuildContext context) {
    final deltaBg =
        data.positive ? const Color(0xFFDDF5E4) : const Color(0xFFF8D9D6);
    final deltaFg =
        data.positive ? const Color(0xFF0E7A31) : const Color(0xFFB4372D);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            data.label,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
              color: AppColors.textPrimary,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: deltaBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  data.delta,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: deltaFg,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 26,
                  child: CustomPaint(
                    painter: _SparklinePainter(
                      points: data.spark,
                      color: deltaFg,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightChartCard extends StatelessWidget {
  const _InsightChartCard({required this.metrics});

  final DashboardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final maxBase = [
      metrics.totalArenas,
      metrics.totalArenas,
      metrics.totalTournaments,
      metrics.totalTournaments,
      metrics.totalTournaments,
    ].reduce(math.max).toDouble();
    final bars = [
      _ChartBar(label: 'Base', current: metrics.totalArenas.toDouble(), previous: 0.68 * metrics.totalArenas),
      _ChartBar(label: 'Verified', current: metrics.verifiedArenas.toDouble(), previous: 0.55 * math.max(metrics.totalArenas, 1)),
      _ChartBar(label: 'Swing', current: metrics.swingEnabledArenas.toDouble(), previous: 0.38 * math.max(metrics.totalArenas, 1)),
      _ChartBar(label: 'Live', current: metrics.liveTournaments.toDouble(), previous: 0.30 * math.max(metrics.totalTournaments, 1)),
      _ChartBar(label: 'Done', current: metrics.completedTournaments.toDouble(), previous: 0.52 * math.max(metrics.totalTournaments, 1)),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Operational mix',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Arena supply against live execution',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _ChartAxis(maxBase: maxBase),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final bar in bars) Expanded(child: _ChartColumn(bar: bar, maxBase: maxBase)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              _LegendChip(
                color: Color(0xFFE9856B),
                label: 'Current',
              ),
              SizedBox(width: 16),
              _LegendChip(
                color: Color(0xFF8E7DFF),
                label: 'Benchmark',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.rows,
  });

  final String eyebrow;
  final String title;
  final String body;
  final List<_SummaryRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.4,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 18),
            Row(
              children: [
                Text(
                  rows[i].label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  rows[i].value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow {
  const _SummaryRow(this.label, this.value);

  final String label;
  final String value;
}

class _ChartBar {
  const _ChartBar({
    required this.label,
    required this.current,
    required this.previous,
  });

  final String label;
  final double current;
  final double previous;
}

class _ChartAxis extends StatelessWidget {
  const _ChartAxis({required this.maxBase});

  final double maxBase;

  @override
  Widget build(BuildContext context) {
    final values = [
      maxBase,
      maxBase * 0.66,
      maxBase * 0.33,
      0.0,
    ];
    return SizedBox(
      width: 34,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final value in values)
            Text(
              _fmtCompact(value),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
        ],
      ),
    );
  }
}

class _ChartColumn extends StatelessWidget {
  const _ChartColumn({
    required this.bar,
    required this.maxBase,
  });

  final _ChartBar bar;
  final double maxBase;

  @override
  Widget build(BuildContext context) {
    final currentHeight = maxBase == 0 ? 0.0 : (bar.current / maxBase).clamp(0.0, 1.0);
    final previousHeight =
        maxBase == 0 ? 0.0 : (bar.previous / maxBase).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      4,
                      (_) => const Divider(
                        height: 1,
                        color: Color(0xFFF0EAE5),
                      ),
                    ),
                  ),
                ),
                FractionallySizedBox(
                  heightFactor: previousHeight,
                  child: Container(
                    width: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8E7DFF).withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                FractionallySizedBox(
                  heightFactor: currentHeight,
                  child: Container(
                    width: 28,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFFF1B4A1).withValues(alpha: 0.95),
                          const Color(0xFFE9856B).withValues(alpha: 0.82),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            bar.label,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({
    required this.points,
    required this.color,
  });

  final List<double> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final minValue = points.reduce(math.min);
    final maxValue = points.reduce(math.max);
    final span = (maxValue - minValue).abs() < 0.001 ? 1.0 : maxValue - minValue;
    final path = Path();

    for (var i = 0; i < points.length; i++) {
      final x = (size.width / (points.length - 1)) * i;
      final y = size.height - (((points[i] - minValue) / span) * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 1.8;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.color != color;
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _LoadingBlock(height: 178),
        SizedBox(height: 14),
        _LoadingBlock(height: 126),
        SizedBox(height: 12),
        _LoadingBlock(height: 126),
        SizedBox(height: 14),
        _LoadingBlock(height: 340),
      ],
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Could not load overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

double _safeRate(int numerator, int denominator) {
  if (denominator <= 0) return 0;
  return numerator / denominator;
}

String _fmt(int n) => NumberFormat.decimalPattern('en_IN').format(n);

String _pct(double v) => '${(v * 100).round()}%';

String _relative(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inSeconds < 60) return 'just now';
  if (d.inMinutes < 60) return '${d.inMinutes}m ago';
  if (d.inHours < 24) return '${d.inHours}h ago';
  return DateFormat('d MMM, HH:mm').format(t);
}

String _deltaLabel(double rate) {
  if (rate <= 0) return 'No coverage';
  return '${(rate * 100).round()}% coverage';
}

String _fmtCompact(double value) {
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(value >= 10000 ? 0 : 1)}k';
  }
  return value.round().toString();
}

List<double> _sparkFromRates(double a, double b, double c) {
  return [
    (a * 0.82) + 0.08,
    (a * 0.96) + 0.04,
    (b * 0.75) + 0.06,
    (c * 0.88) + 0.05,
    (a * 0.68) + 0.1,
    (b * 0.92) + 0.03,
    (c * 0.72) + 0.08,
  ];
}
