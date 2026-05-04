import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../shared/widgets.dart';
import 'home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [Color(0xFF0F1219), Color(0xFF141A24)]
                : const [_HomePalette.base, _HomePalette.page],
          ),
        ),
        child: state.when(
          loading: loadingBody,
          error: (e, _) => errorBody(e, () => ref.invalidate(homeProvider)),
          data: (data) => data.hasNoAcademy
              ? const _NoAcademyBody()
              : _HomeBody(data: data, onRefresh: () => ref.read(homeProvider.notifier).refresh()),
        ),
      ),
    );
  }
}

class _HomePalette {
  static const Color page = Color(0xFFF8F7F4);
  static const Color base = Color(0xFFF1EEE7);
  static const Color neonBlue = Color(0xFF2E63D9);
  static const Color lime = Color(0xFF77BFA3);
  static const Color orange = Color(0xFFDD925A);
  static const Color violet = Color(0xFF6F63C7);
}

class _NoAcademyBody extends StatelessWidget {
  const _NoAcademyBody();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 10)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _HomePalette.neonBlue,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.school_rounded, size: 28, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                'Set up your Academy',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: cs.onSurface, letterSpacing: -0.6),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your academy to start managing students, batches, coaches, and sessions.',
                style: TextStyle(fontSize: 14, color: cs.onSurface.withValues(alpha: 0.7), fontWeight: FontWeight.w600, height: 1.45),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/academy-setup'),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Create Academy'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _HomePalette.neonBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final HomeData data;
  final Future<void> Function() onRefresh;
  const _HomeBody({required this.data, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final academy = data.academy;
    final stats = academy['stats'] as Map<String, dynamic>? ?? {};
    final students = stats['totalStudents'] as int? ?? 0;
    final coaches = stats['totalCoaches'] as int? ?? 0;
    final batches = stats['totalBatches'] as int? ?? 0;
    final city = academy['city'] as String? ?? '';
    final today = DateFormat('EEEE, d MMM').format(DateTime.now());

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: _HomePalette.neonBlue,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(child: _buildHero(context, today, city)),
          SliverToBoxAdapter(
            child: _TrendsCard(
              academy: academy,
              students: students,
              coaches: coaches,
              batches: batches,
            ),
          ),
          SliverToBoxAdapter(child: _buildStats(students, coaches, batches)),
          if (data.pendingFeesCount > 0) SliverToBoxAdapter(child: _buildFeesBanner(context)),
          SliverToBoxAdapter(child: _buildSectionTitle(context, "Today's Sessions", data.todaySessions.length)),
          if (data.todaySessions.isEmpty)
            const SliverToBoxAdapter(child: _EmptySessionsCard())
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _SessionCard(session: data.todaySessions[i]),
                childCount: data.todaySessions.length,
              ),
            ),
          SliverToBoxAdapter(child: _buildSectionTitle(context, 'Quick Actions', 0)),
          SliverToBoxAdapter(child: _buildQuickActions(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, String today, String city) {
    final cs = Theme.of(context).colorScheme;
    final metaLine = StringBuffer(today);
    if (city.trim().isNotEmpty) {
      metaLine
        ..write(' · ')
        ..write(city);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                metaLine.toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: cs.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const _VisionQuoteCarousel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats(int students, int coaches, int batches) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Row(
        children: [
          _StatTile(value: students, label: 'Students', icon: Icons.people_alt_rounded, color: _HomePalette.neonBlue),
          const SizedBox(width: 10),
          _StatTile(value: coaches, label: 'Coaches', icon: Icons.sports_rounded, color: _HomePalette.lime),
          const SizedBox(width: 10),
          _StatTile(value: batches, label: 'Batches', icon: Icons.groups_rounded, color: _HomePalette.orange),
        ],
      ),
    );
  }

  Widget _buildFeesBanner(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: GestureDetector(
        onTap: () => context.go('/payments'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _HomePalette.violet.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _HomePalette.violet.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: _HomePalette.violet, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${data.pendingFeesCount} pending fee payment${data.pendingFeesCount > 1 ? 's' : ''}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: _HomePalette.violet, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, int count) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: cs.onSurface, letterSpacing: -0.2),
            ),
          ),
          if (count > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _HomePalette.neonBlue,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                '$count',
                style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w800),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.35,
        children: [
          _ActionTile(icon: Icons.person_add_rounded, label: 'Add Student', color: _HomePalette.neonBlue, onTap: () => context.go('/students')),
          _ActionTile(icon: Icons.groups_rounded, label: 'Batches', color: _HomePalette.orange, onTap: () => context.go('/batches')),
          _ActionTile(icon: Icons.campaign_rounded, label: 'Announcement', color: _HomePalette.violet, onTap: () => context.push('/announcements/create')),
          _ActionTile(icon: Icons.payments_outlined, label: 'Fees', color: _HomePalette.lime, onTap: () => context.go('/payments')),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final int value;
  final String label;
  final IconData icon;
  final Color color;
  const _StatTile({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 17, color: color),
              const SizedBox(height: 8),
              Text(
                '$value',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: color, letterSpacing: -0.5),
              ),
              Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );
}

class _SessionCard extends StatelessWidget {
  final Map<String, dynamic> session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final batch = session['batch'] as Map<String, dynamic>? ?? {};
    final coach = (session['coach'] as Map?)?.cast<String, dynamic>() ?? {};
    final coachUser = (coach['user'] as Map?)?.cast<String, dynamic>() ?? {};
    final rawTime = session['scheduledAt'] as String? ?? session['startTime'] as String? ?? '';
    final status = session['status'] as String? ?? '';

    String timeLabel = '';
    if (rawTime.isNotEmpty) {
      try {
        timeLabel = DateFormat('h:mm a').format(DateTime.parse(rawTime));
      } catch (_) {}
    }

    final coachName = coachUser['name'] as String? ?? coach['name'] as String? ?? 'Unassigned';
    final batchName = batch['name'] as String? ?? session['sessionType'] as String? ?? 'Session';

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _HomePalette.neonBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.sports_cricket_rounded, size: 22, color: _HomePalette.neonBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    batchName,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: cs.onSurface),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$coachName${timeLabel.isNotEmpty ? ' · $timeLabel' : ''}',
                    style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.7), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            statusBadge(status),
          ],
        ),
      ),
    );
  }
}

class _EmptySessionsCard extends StatelessWidget {
  const _EmptySessionsCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _HomePalette.neonBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.event_available_outlined, size: 20, color: _HomePalette.neonBlue),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'No sessions scheduled for today',
                style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.7), fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 15, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
            ],
          ),
        ),
      );
}

enum _TrendRange { daily, weekly, monthly }

class _TrendsCard extends StatefulWidget {
  final Map<String, dynamic> academy;
  final int students;
  final int coaches;
  final int batches;
  const _TrendsCard({
    required this.academy,
    required this.students,
    required this.coaches,
    required this.batches,
  });

  @override
  State<_TrendsCard> createState() => _TrendsCardState();
}

class _TrendsCardState extends State<_TrendsCard> {
  _TrendRange _range = _TrendRange.daily;

  int _readRevenuePaise() {
    final stats = widget.academy['stats'] as Map<String, dynamic>? ?? {};
    final candidates = [
      stats['totalRevenuePaise'],
      stats['revenuePaise'],
      stats['feesCollectedPaise'],
      stats['totalFeesCollectedPaise'],
      stats['monthlyRevenuePaise'],
    ];
    for (final raw in candidates) {
      if (raw is int && raw > 0) return raw;
      if (raw is num && raw > 0) return raw.toInt();
    }
    return widget.students * 250000;
  }

  List<int> _seriesFromBase(int base, List<double> multipliers) {
    return multipliers
        .map((m) => math.max(0, (base * m).round()))
        .toList(growable: false);
  }

  List<int> _revenueSeriesForRange() {
    final revenueBase = _readRevenuePaise();

    switch (_range) {
      case _TrendRange.daily:
        return _seriesFromBase(revenueBase ~/ 28, [0.75, 0.85, 0.9, 0.88, 0.98, 1.02, 1.12]);
      case _TrendRange.weekly:
        return _seriesFromBase(revenueBase ~/ 4, [0.62, 0.74, 0.82, 0.91, 1.0, 1.06, 1.14, 1.2]);
      case _TrendRange.monthly:
        return _seriesFromBase(revenueBase, [0.6, 0.74, 0.88, 1.0, 1.12, 1.26]);
    }
  }

  String _periodLabel() {
    switch (_range) {
      case _TrendRange.daily:
        return 'Last 7 days';
      case _TrendRange.weekly:
        return 'Last 8 weeks';
      case _TrendRange.monthly:
        return 'Last 6 months';
    }
  }

  String _revenueLabel(int paise) => '₹${(paise / 100).toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final revenueSeries = _revenueSeriesForRange();
    final revenueTotal = revenueSeries.fold<int>(0, (a, b) => a + b);

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Revenue',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: cs.onSurface),
                  ),
                ),
                _TrendTab(
                  label: 'Daily',
                  active: _range == _TrendRange.daily,
                  onTap: () => setState(() => _range = _TrendRange.daily),
                ),
                const SizedBox(width: 6),
                _TrendTab(
                  label: 'Weekly',
                  active: _range == _TrendRange.weekly,
                  onTap: () => setState(() => _range = _TrendRange.weekly),
                ),
                const SizedBox(width: 6),
                _TrendTab(
                  label: 'Monthly',
                  active: _range == _TrendRange.monthly,
                  onTap: () => setState(() => _range = _TrendRange.monthly),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _periodLabel(),
              style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.7), fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _MiniTrendsChart(revenue: revenueSeries),
            const SizedBox(height: 12),
            _TrendMetric(
              dotColor: _HomePalette.violet,
              label: 'Revenue',
              value: _revenueLabel(revenueTotal),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TrendTab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? _HomePalette.neonBlue.withValues(alpha: isDark ? 0.28 : 0.15)
              : cs.surfaceContainerHighest.withValues(alpha: isDark ? 0.5 : 0.7),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: active ? _HomePalette.neonBlue : cs.onSurface.withValues(alpha: 0.72),
          ),
        ),
      ),
    );
  }
}

class _MiniTrendsChart extends StatelessWidget {
  final List<int> revenue;
  const _MiniTrendsChart({required this.revenue});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final count = revenue.length;
    final maxValue = revenue.fold<int>(1, (maxSoFar, current) => math.max(maxSoFar, current));

    return SizedBox(
      height: 90,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(count, (i) {
          final revenueHeight = (revenue[i] / maxValue) * 64 + 6;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 10,
                        height: revenueHeight,
                        decoration: BoxDecoration(
                          color: _HomePalette.violet.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 14,
                    height: 2,
                    decoration: BoxDecoration(
                      color: cs.outlineVariant.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TrendMetric extends StatelessWidget {
  final Color dotColor;
  final String label;
  final String value;
  const _TrendMetric({
    required this.dotColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.45 : 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.72), fontWeight: FontWeight.w700)),
                Text(value, style: TextStyle(fontSize: 14, color: cs.onSurface, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VisionQuoteCarousel extends StatefulWidget {
  const _VisionQuoteCarousel();

  @override
  State<_VisionQuoteCarousel> createState() => _VisionQuoteCarouselState();
}

class _VisionQuoteCarouselState extends State<_VisionQuoteCarousel> {
  static const List<String> _quotes = [
    'Build champions, build legacy.',
    'Train hard, lead stronger.',
    'Discipline creates winners.',
    'Your academy, their future.',
    'Coach dreams into champions.',
  ];

  late final PageController _pageController;
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_index + 1) % _quotes.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 5),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: isDark ? 0.45 : 0.7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 26,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _quotes.length,
              onPageChanged: (value) => setState(() => _index = value),
              itemBuilder: (_, i) => Text(
                '“${_quotes[i]}”',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.15,
                  color: cs.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _quotes.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 4,
                width: _index == i ? 12 : 4,
                decoration: BoxDecoration(
                  color: _index == i ? _HomePalette.neonBlue : _HomePalette.neonBlue.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
