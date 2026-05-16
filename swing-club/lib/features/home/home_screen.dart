import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../shared/widgets.dart';
import '../coaches/invite_coach_sheet.dart';
import '../fees/fee_provider.dart';
import '../fees/finance_add_sheet.dart';
import '../students/enroll_student_sheet.dart';
import 'home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(homeProvider);
    final finState = ref.watch(financeSummaryProvider);

    final expensePaise = finState.maybeWhen(
      data: (s) => (s['expensesPaise'] as num? ?? 0).toInt(),
      orElse: () => 0,
    );
    final netPaise = finState.maybeWhen(
      data: (s) => (s['netPaise'] as num? ?? 0).toInt(),
      orElse: () => 0,
    );

    return Scaffold(
      body: state.when(
        loading: loadingBody,
        error: (e, _) => errorBody(e, () => ref.invalidate(homeProvider)),
        data: (data) => data.hasNoAcademy
            ? const _NoAcademyBody()
            : _HomeBody(
                data: data,
                expensePaise: expensePaise,
                netPaise: netPaise,
                onRefresh: () async {
                  ref.invalidate(homeProvider);
                  ref.invalidate(financeSummaryProvider);
                  await ref.read(homeProvider.future);
                },
              ),
      ),
    );
  }
}

// ─── Palette ──────────────────────────────────────────────────────────────────

class _C {
  static const blue   = Color(0xFF2563EB);
  static const green  = Color(0xFF16A34A);
  static const orange = Color(0xFFEA580C);
  static const violet = Color(0xFF7C3AED);
  static const lime   = Color(0xFF059669);
  static const red    = Color(0xFFDC2626);

  // Pastel card backgrounds
  static const cardPink  = Color(0xFFEDD5F0);
  static const cardBeige = Color(0xFFEDE0C4);
  static const cardBlue  = Color(0xFFC8DCF0);
  static const cardMint  = Color(0xFFC4E8D4);
}

// ─── No Academy ───────────────────────────────────────────────────────────────

class _NoAcademyBody extends StatelessWidget {
  const _NoAcademyBody();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                  color: _C.blue, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.school_rounded, size: 26, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text('Set up your Academy',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900,
                    color: cs.onSurface, letterSpacing: -0.5)),
            const SizedBox(height: 8),
            Text('Create your academy to manage students, batches, and coaches.',
                style: TextStyle(fontSize: 14, color: cs.onSurface.withValues(alpha: 0.55),
                    fontWeight: FontWeight.w500, height: 1.5)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.go('/academy-setup'),
                style: FilledButton.styleFrom(
                  backgroundColor: _C.blue,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Create Academy',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Home Body ────────────────────────────────────────────────────────────────

class _HomeBody extends StatelessWidget {
  final HomeData data;
  final int expensePaise;
  final int netPaise;
  final Future<void> Function() onRefresh;
  const _HomeBody({
    required this.data,
    required this.expensePaise,
    required this.netPaise,
    required this.onRefresh,
  });

  static Widget _divider(BuildContext context) => Divider(
        height: 1,
        thickness: 0.5,
        indent: 20,
        endIndent: 20,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
      );

  @override
  Widget build(BuildContext context) {
    final city = data.academy['city'] as String? ?? '';
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: _C.blue,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: _HeroBlock(
              data: data,
              city: city,
              expensePaise: expensePaise,
              netPaise: netPaise,
            ),
          ),
          SliverToBoxAdapter(child: _divider(context)),
          SliverToBoxAdapter(child: _MetricCards(data: data)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _divider(context),
            ),
          ),
          SliverToBoxAdapter(child: _AddBlock(data: data)),
          SliverToBoxAdapter(child: _divider(context)),
          SliverToBoxAdapter(child: _AcademyBlock(academy: data.academy)),
          if (data.batchRevenueStats.isNotEmpty) ...[
            SliverToBoxAdapter(child: _divider(context)),
            SliverToBoxAdapter(child: _BatchBarChart(stats: data.batchRevenueStats)),
          ],
          if (data.pendingFeesCount > 0) ...[
            SliverToBoxAdapter(child: _divider(context)),
            SliverToBoxAdapter(child: _FeesBanner(count: data.pendingFeesCount)),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

// ─── Hero Block ───────────────────────────────────────────────────────────────

class _HeroBlock extends StatelessWidget {
  final HomeData data;
  final String city;
  final int expensePaise;
  final int netPaise;
  const _HeroBlock({
    required this.data,
    required this.city,
    required this.expensePaise,
    required this.netPaise,
  });

  static String _fmt(int paise) {
    final r = paise / 100;
    if (r >= 100000) return '₹${(r / 100000).toStringAsFixed(1)}L';
    if (r >= 1000)   return '₹${(r / 1000).toStringAsFixed(1)}K';
    return '₹${r.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final today = DateFormat('EEE, d MMM').format(DateTime.now());
    final meta  = city.trim().isNotEmpty ? '$today · $city' : today;
    final netPositive = netPaise >= 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row — full width so date truly hugs the right edge
          Row(
            children: [
              Text('Revenue this month',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                      color: cs.onSurface.withValues(alpha: 0.5))),
              const Spacer(),
              Text(meta,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: cs.onSurface.withValues(alpha: 0.65))),
            ],
          ),
          const SizedBox(height: 2),

          // Big revenue number + action buttons
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(_fmt(data.monthlyRevenuePaise),
                    style: TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface,
                      letterSpacing: -2.5,
                      height: 1.1,
                    )),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  _CircleBtn(
                    icon: Icons.add_rounded,
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (_) => const FinanceAddSheet(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _CircleBtn(
                    icon: Icons.payments_outlined,
                    onTap: () => context.push('/payments'),
                  ),
                ],
              ),
            ],
          ),

          // Expense + P&L row (smaller, below revenue)
          if (expensePaise > 0 || netPaise != 0) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                if (expensePaise > 0) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Expense',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
                              color: cs.onSurface.withValues(alpha: 0.45))),
                      const SizedBox(height: 1),
                      Text(_fmt(expensePaise),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                              color: _C.red, letterSpacing: -0.5, height: 1)),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    width: 1, height: 28,
                    color: Colors.black.withValues(alpha: 0.08),
                  ),
                ],
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Net P&L',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
                            color: cs.onSurface.withValues(alpha: 0.45))),
                    const SizedBox(height: 1),
                    Text(
                      '${netPositive ? '+' : ''}${_fmt(netPaise)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: netPositive ? _C.green : _C.red,
                        letterSpacing: -0.5,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
            color: cs.surfaceContainerLow, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: cs.onSurface),
      ),
    );
  }
}

// ─── Metric Cards ─────────────────────────────────────────────────────────────

class _MetricCards extends StatelessWidget {
  final HomeData data;
  const _MetricCards({required this.data});

  @override
  Widget build(BuildContext context) {
    final occ  = (data.avgBatchOccupancy * 100).round();
    final fees = (data.feeCollectionRate * 100).round();
    return SizedBox(
      height: 138,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _MetricCard(color: _C.cardPink,  label: 'Active Students', value: '${data.activeStudents}', sub: 'enrolled'),
          const SizedBox(width: 12),
          _MetricCard(color: _C.cardBeige, label: 'Batch Occupancy', value: '$occ%',                  sub: 'avg fill rate'),
          const SizedBox(width: 12),
          _MetricCard(color: _C.cardBlue,  label: 'Fee Collected',   value: '$fees%',                 sub: 'this month'),
          if (data.newStudentsThisMonth > 0) ...[
            const SizedBox(width: 12),
            _MetricCard(color: _C.cardMint, label: 'New Joins', value: '+${data.newStudentsThisMonth}', sub: 'this month'),
          ],
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final String sub;
  const _MetricCard({required this.color, required this.label,
      required this.value, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0x99000000))),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900,
              color: Color(0xD9000000), letterSpacing: -1.5, height: 1)),
          const SizedBox(height: 3),
          Text(sub, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0x80000000))),
        ],
      ),
    );
  }
}

// ─── Add Block ────────────────────────────────────────────────────────────────

class _AddBlock extends StatelessWidget {
  final HomeData data;
  const _AddBlock({required this.data});

  void _addBatch(BuildContext ctx)   => ctx.push('/batches/new');
  void _addStudent(BuildContext ctx) => showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      useRootNavigator: true,
      useSafeArea: true,
      backgroundColor: Theme.of(ctx).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const EnrollStudentSheet());
  void _addCoach(BuildContext ctx) => showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      useRootNavigator: true,
      useSafeArea: true,
      backgroundColor: Theme.of(ctx).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const InviteCoachSheet());

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
              color: cs.onSurface, letterSpacing: -0.3)),
          const SizedBox(height: 4),
          _AddTile(icon: Icons.groups_rounded, label: 'Batch',
              sub: 'Create a new training batch', color: _C.orange,
              onTap: () => _addBatch(context)),
          Divider(height: 1, indent: 56, color: cs.onSurface.withValues(alpha: 0.08)),
          _AddTile(icon: Icons.person_add_alt_1_rounded, label: 'Student',
              sub: 'Enrol a new student', color: _C.blue,
              onTap: () => _addStudent(context)),
          Divider(height: 1, indent: 56, color: cs.onSurface.withValues(alpha: 0.08)),
          _AddTile(icon: Icons.sports_cricket_rounded, label: 'Coach',
              sub: 'Invite a new coach', color: _C.lime,
              onTap: () => _addCoach(context)),
        ],
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final Color color;
  final VoidCallback onTap;
  const _AddTile({required this.icon, required this.label, required this.sub,
      required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          Container(width: 40, height: 40,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(icon, size: 20, color: color)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: cs.onSurface)),
            const SizedBox(height: 1),
            Text(sub, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                color: cs.onSurface.withValues(alpha: 0.45))),
          ])),
          Icon(Icons.arrow_forward_ios_rounded, size: 13,
              color: cs.onSurface.withValues(alpha: 0.3)),
        ]),
      ),
    );
  }
}

// ─── Academy Block ────────────────────────────────────────────────────────────

class _AcademyBlock extends StatelessWidget {
  final Map<String, dynamic> academy;
  const _AcademyBlock({required this.academy});

  @override
  Widget build(BuildContext context) {
    final cs       = Theme.of(context).colorScheme;
    final batches  = (academy['totalBatches']  as num? ?? (academy['batches']  as List?)?.length ?? 0).toInt();
    final students = (academy['totalStudents'] as num? ?? 0).toInt();
    final coaches  = (academy['totalCoaches']  as num? ?? (academy['coaches']  as List?)?.length ?? 0).toInt();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Academy', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
              color: cs.onSurface, letterSpacing: -0.3)),
          const SizedBox(height: 16),
          Row(children: [
            _StatBox(value: '$batches',  label: 'Batches'),
            const SizedBox(width: 8),
            _StatBox(value: '$students', label: 'Students'),
            const SizedBox(width: 8),
            _StatBox(value: '$coaches',  label: 'Coaches'),
          ]),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        decoration: BoxDecoration(
          border: Border.all(color: cs.onSurface.withValues(alpha: 0.10), width: 1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900,
              color: cs.onSurface, letterSpacing: -1.5, height: 1)),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
              color: cs.onSurface.withValues(alpha: 0.45))),
        ]),
      ),
    );
  }
}

// ─── Batch Area Chart ─────────────────────────────────────────────────────────
// Animated area chart: capacity (grey) vs collected (green) per batch.

class _BatchBarChart extends StatefulWidget {
  const _BatchBarChart({required this.stats});
  final List<BatchRevenueStat> stats;

  @override
  State<_BatchBarChart> createState() => _BatchBarChartState();
}

class _BatchBarChartState extends State<_BatchBarChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  static String _fmt(int paise) {
    final r = paise / 100;
    if (r >= 100000) return '₹${(r / 100000).toStringAsFixed(1)}L';
    if (r >= 1000)   return '₹${(r / 1000).toStringAsFixed(1)}K';
    return '₹${r.toStringAsFixed(0)}';
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stats.isEmpty) return const SizedBox.shrink();
    final cs    = Theme.of(context).colorScheme;
    final stats = widget.stats;

    final maxVal = stats
        .map((s) => s.expectedPaise)
        .fold(0, (a, b) => b > a ? b : a)
        .toDouble();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text('Batch Snapshot',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                      color: cs.onSurface, letterSpacing: -0.3)),
            ),
            Text(_fmt(stats.fold(0, (s, b) => s + b.collectedPaise)),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
                    color: _C.green, letterSpacing: -0.5)),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            _AreaLegend(color: cs.onSurface.withValues(alpha: 0.22), label: 'Capacity'),
            const SizedBox(width: 16),
            const _AreaLegend(color: _C.green, label: 'Collected'),
          ]),
          const SizedBox(height: 16),

          AnimatedBuilder(
            animation: _anim,
            builder: (context, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 160,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _AreaChartPainter(
                      stats: stats,
                      maxVal: maxVal == 0 ? 1 : maxVal,
                      progress: _anim.value,
                      gridColor: cs.onSurface.withValues(alpha: 0.07),
                      capacityColor: cs.onSurface.withValues(alpha: 0.20),
                      collectColor: _C.green,
                      dotBg: cs.surface,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: stats.map((s) => Expanded(
                    child: Column(children: [
                      Text(s.name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                              color: cs.onSurface.withValues(alpha: 0.45))),
                      const SizedBox(height: 2),
                      Text('${s.enrolled}/${s.maxStudents}',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                              color: cs.onSurface.withValues(alpha: 0.60))),
                    ]),
                  )).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _AreaChartPainter extends CustomPainter {
  const _AreaChartPainter({
    required this.stats,
    required this.maxVal,
    required this.progress,
    required this.gridColor,
    required this.capacityColor,
    required this.collectColor,
    required this.dotBg,
  });

  final List<BatchRevenueStat> stats;
  final double maxVal;
  final double progress;
  final Color gridColor;
  final Color capacityColor;
  final Color collectColor;
  final Color dotBg;

  Offset _pt(int i, List<double> vals, Size size) {
    final n = vals.length;
    final x = n <= 1 ? size.width / 2 : (i / (n - 1)) * size.width;
    final y = size.height - (vals[i] / maxVal) * size.height * 0.92;
    return Offset(x, y);
  }

  void _drawArea(Canvas canvas, List<double> vals, Size size, Paint fill, Paint stroke) {
    if (vals.isEmpty) return;

    // Build smooth cubic bezier line path
    final line = Path()
      ..moveTo(_pt(0, vals, size).dx, _pt(0, vals, size).dy);
    for (int i = 1; i < vals.length; i++) {
      final p = _pt(i - 1, vals, size);
      final c = _pt(i, vals, size);
      final cpX = (p.dx + c.dx) / 2;
      line.cubicTo(cpX, p.dy, cpX, c.dy, c.dx, c.dy);
    }

    // Area = line + close to bottom corners
    final area = Path.from(line)
      ..lineTo(_pt(vals.length - 1, vals, size).dx, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(area, fill);
    canvas.drawPath(line, stroke);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (stats.isEmpty) return;

    final expected  = stats.map((s) => s.expectedPaise.toDouble()).toList();
    final collected = stats.map((s) => s.collectedPaise.toDouble()).toList();
    final rect      = Rect.fromLTWH(0, 0, size.width, size.height);

    // Clip to animated reveal width
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * progress, size.height + 2));

    // Horizontal grid lines
    final gridPaint = Paint()..color = gridColor..strokeWidth = 0.5;
    for (final f in [0.25, 0.5, 0.75]) {
      final y = size.height - f * size.height * 0.92;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // ── Capacity area ─────────────────────────────────────────────
    final capFill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [capacityColor.withValues(alpha: 0.22), capacityColor.withValues(alpha: 0.0)],
      ).createShader(rect)
      ..style = PaintingStyle.fill;
    final capLine = Paint()
      ..color = capacityColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    _drawArea(canvas, expected, size, capFill, capLine);

    // ── Collected area ────────────────────────────────────────────
    final colFill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [collectColor.withValues(alpha: 0.38), collectColor.withValues(alpha: 0.03)],
      ).createShader(rect)
      ..style = PaintingStyle.fill;
    final colLine = Paint()
      ..color = collectColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    _drawArea(canvas, collected, size, colFill, colLine);

    // Dots on collected line
    final dotFill = Paint()..color = collectColor..style = PaintingStyle.fill;
    final dotRing = Paint()
      ..color = dotBg
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    for (int i = 0; i < collected.length; i++) {
      final pt = _pt(i, collected, size);
      if (pt.dx <= size.width * progress + 1) {
        canvas.drawCircle(pt, 5, dotFill);
        canvas.drawCircle(pt, 5, dotRing);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_AreaChartPainter old) =>
      old.progress != progress || old.stats != stats;
}

class _AreaLegend extends StatelessWidget {
  const _AreaLegend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 18, height: 3,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 5),
      Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
          color: cs.onSurface.withValues(alpha: 0.50))),
    ]);
  }
}


// ─── Fees Banner ──────────────────────────────────────────────────────────────

class _FeesBanner extends StatelessWidget {
  final int count;
  const _FeesBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: GestureDetector(
        onTap: () => context.push('/payments'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
              color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            const Icon(Icons.warning_amber_rounded, color: _C.orange, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text('$count pending fee payment${count > 1 ? 's' : ''}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: cs.onSurface)),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 13,
                color: cs.onSurface.withValues(alpha: 0.3)),
          ]),
        ),
      ),
    );
  }
}
