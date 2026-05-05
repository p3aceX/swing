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
    return Scaffold(
      body: state.when(
        loading: loadingBody,
        error: (e, _) => errorBody(e, () => ref.invalidate(homeProvider)),
        data: (data) => data.hasNoAcademy
            ? const _NoAcademyBody()
            : _HomeBody(data: data, onRefresh: () => ref.read(homeProvider.notifier).refresh()),
      ),
    );
  }
}

class _HomePalette {
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
    final city = data.academy['city'] as String? ?? '';
    final today = DateFormat('EEEE, d MMM').format(DateTime.now());

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: _HomePalette.neonBlue,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(child: _buildHero(context, today, city)),
          SliverToBoxAdapter(child: _StatsRow(academy: data.academy)),
          SliverToBoxAdapter(child: _KpiSection(data: data)),
          SliverToBoxAdapter(child: _BatchRevenueCard(stats: data.batchRevenueStats)),
          if (data.pendingFeesCount > 0) SliverToBoxAdapter(child: _buildFeesBanner(context)),
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

}



// ── Stats Row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final Map<String, dynamic> academy;
  const _StatsRow({required this.academy});

  @override
  Widget build(BuildContext context) {
    final batches  = (academy['totalBatches']  as num? ?? (academy['batches']  as List?)?.length ?? 0).toInt();
    final students = (academy['totalStudents'] as num? ?? 0).toInt();
    final coaches  = (academy['totalCoaches']  as num? ?? (academy['coaches']  as List?)?.length ?? 0).toInt();

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      child: Row(children: [
        _StatChip(icon: Icons.groups_rounded,         color: _HomePalette.orange,   value: '$batches',  label: 'Batches'),
        const SizedBox(width: 10),
        _StatChip(icon: Icons.people_alt_rounded,     color: _HomePalette.neonBlue, value: '$students', label: 'Students'),
        const SizedBox(width: 10),
        _StatChip(icon: Icons.sports_cricket_rounded, color: _HomePalette.lime,     value: '$coaches',  label: 'Coaches'),
      ]),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  const _StatChip({required this.icon, required this.color, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: cs.onSurface, letterSpacing: -0.3)),
                Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.55))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── KPI Section ───────────────────────────────────────────────────────────────

class _KpiSection extends StatelessWidget {
  final HomeData data;
  const _KpiSection({required this.data});

  static String _fmtRevenue(int paise) {
    final r = paise / 100;
    if (r >= 100000) return '₹${(r / 100000).toStringAsFixed(1)}L';
    if (r >= 1000)   return '₹${(r / 1000).toStringAsFixed(1)}K';
    return '₹${r.toStringAsFixed(0)}';
  }

  static String _fmtPct(double v) => '${(v * 100).toStringAsFixed(0)}%';

  @override
  Widget build(BuildContext context) {
    final row1 = [
      _KpiItem(icon: Icons.currency_rupee_rounded,       color: _HomePalette.neonBlue,        value: _fmtRevenue(data.monthlyRevenuePaise), label: 'Monthly Revenue'),
      _KpiItem(icon: Icons.people_alt_rounded,           color: _HomePalette.lime,             value: '${data.activeStudents}',              label: 'Active Students'),
      _KpiItem(icon: Icons.check_circle_outline_rounded, color: const Color(0xFF43A047),       value: _fmtPct(data.feeCollectionRate),       label: 'Fee Collection'),
    ];
    final row2 = [
      _KpiItem(icon: Icons.groups_rounded,               color: _HomePalette.orange,           value: _fmtPct(data.avgBatchOccupancy),       label: 'Batch Occupancy'),
      _KpiItem(icon: Icons.person_add_alt_1_rounded,     color: _HomePalette.violet,           value: '+${data.newStudentsThisMonth}',        label: 'New Joins This Month'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(children: [
              Expanded(child: _KpiTile(item: row1[0])),
              const SizedBox(width: 10),
              Expanded(child: _KpiTile(item: row1[1])),
              const SizedBox(width: 10),
              Expanded(child: _KpiTile(item: row1[2])),
            ]),
          ),
          const SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(children: [
              Expanded(child: _KpiTile(item: row2[0])),
              const SizedBox(width: 10),
              Expanded(child: _KpiTile(item: row2[1])),
            ]),
          ),
        ],
      ),
    );
  }
}

class _KpiItem {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  const _KpiItem({required this.icon, required this.color, required this.value, required this.label});
}

class _KpiTile extends StatelessWidget {
  final _KpiItem item;
  const _KpiTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: item.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, size: 18, color: item.color),
          const SizedBox(height: 8),
          Text(
            item.value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: cs.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Batch Snapshot Chart ──────────────────────────────────────────────────────

class _BatchRevenueCard extends StatelessWidget {
  final List<BatchRevenueStat> stats;
  const _BatchRevenueCard({required this.stats});

  static String _fmt(int paise) {
    final r = paise / 100;
    if (r >= 100000) return '₹${(r / 100000).toStringAsFixed(1)}L';
    if (r >= 1000)   return '₹${(r / 1000).toStringAsFixed(1)}K';
    return '₹${r.toStringAsFixed(0)}';
  }

  static const Color _colCapacity  = Color(0xFFBBCFF8);   // light blue — full capacity
  static const Color _colOccupancy = Color(0xFFDD925A);   // orange    — enrolled × fee
  static const Color _colCollected = Color(0xFF43A047);   // green     — actual collected

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (stats.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _HomePalette.neonBlue.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text('No batch data yet',
              style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.w600)),
        ),
      );
    }

    final maxPaise = stats.fold<int>(1, (m, s) => math.max(m, s.expectedPaise));
    const chartH = 100.0;
    const barW   = 9.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: _HomePalette.neonBlue.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Batch Snapshot',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: cs.onSurface)),
            const SizedBox(height: 8),
            Row(children: [
              _Legend(color: _colCapacity,  label: 'Capacity'),
              const SizedBox(width: 10),
              _Legend(color: _colOccupancy, label: 'Occ. Revenue'),
              const SizedBox(width: 10),
              _Legend(color: _colCollected, label: 'Collected'),
            ]),
            const SizedBox(height: 14),
            // Bars
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: stats.map((s) {
                final expH = (s.expectedPaise / maxPaise) * chartH;
                final occH = (s.occupancyRevenuePaise / maxPaise) * chartH;
                final colH = (s.collectedPaise / maxPaise) * chartH;
                final occPct = s.maxStudents > 0
                    ? '${((s.enrolled / s.maxStudents) * 100).round()}%'
                    : '-';
                final label = s.name.length > 8 ? '${s.name.substring(0, 7)}…' : s.name;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: chartH,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: barW,
                                height: expH.clamp(3.0, chartH),
                                decoration: BoxDecoration(
                                  color: _colCapacity,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Container(
                                width: barW,
                                height: occH.clamp(0.0, chartH),
                                decoration: BoxDecoration(
                                  color: _colOccupancy,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Container(
                                width: barW,
                                height: colH.clamp(0.0, chartH),
                                decoration: BoxDecoration(
                                  color: _colCollected,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          label,
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.7)),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${s.maxStudents} · $occPct',
                          style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.45)),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          _fmt(s.collectedPaise),
                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: _colCollected),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.6))),
      ],
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
                textAlign: TextAlign.left,
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
            mainAxisAlignment: MainAxisAlignment.start,
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
