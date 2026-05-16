import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/payment/razorpay_stub.dart';
import '../../../core/theme/app_colors.dart';
import '../../academy/controller/academy_detail_controller.dart';
import '../../academy/domain/academy_detail_models.dart';
import '../controller/profile_controller.dart';
import '../domain/profile_models.dart';

class AcademyScreen extends ConsumerStatefulWidget {
  const AcademyScreen({super.key, this.academyIndex = 0});
  final int academyIndex;

  @override
  ConsumerState<AcademyScreen> createState() => _AcademyScreenState();
}

class _AcademyScreenState extends ConsumerState<AcademyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    final detailAsync = ref.watch(academyDetailProvider);

    return Scaffold(
      backgroundColor: context.bg,
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _AcademyError(
                  message: state.error!,
                  onRetry: () => ref.read(profileControllerProvider.notifier).load(),
                )
              : state.data == null
                  ? _AcademyError(
                      message: 'No data found.',
                      onRetry: () => ref.read(profileControllerProvider.notifier).load(),
                    )
                  : Builder(builder: (context) {
                      final academies = state.data!.academies;
                      final idx = widget.academyIndex.clamp(0, (academies.length - 1).clamp(0, 999));
                      final academy = academies.isNotEmpty ? academies[idx] : state.data!.academy;
                      final identity = state.data!.identity;

                      return NestedScrollView(
                        headerSliverBuilder: (context, _) => [
                          SliverAppBar(
                            backgroundColor: context.bg,
                            title: Text(academy.isLinked ? (academy.academyName ?? 'My Academy') : 'My Academy'),
                            pinned: true,
                            floating: false,
                            expandedHeight: _cardHeight(academy),
                            flexibleSpace: FlexibleSpaceBar(
                              collapseMode: CollapseMode.pin,
                              background: Padding(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    _IdCard(
                                      academy: academy,
                                      playerName: identity.fullName,
                                      swingId: identity.swingId,
                                      avatarUrl: identity.avatarUrl,
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ),
                            bottom: PreferredSize(
                              preferredSize: const Size.fromHeight(44),
                              child: TabBar(
                                controller: _tabs,
                                isScrollable: true,
                                tabAlignment: TabAlignment.start,
                                indicatorColor: context.accent,
                                labelColor: context.accent,
                                unselectedLabelColor: context.fgSub,
                                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                tabs: const [
                                  Tab(text: 'Overview'),
                                  Tab(text: 'Schedule'),
                                  Tab(text: 'Fees'),
                                  Tab(text: 'Drills'),
                                  Tab(text: 'Reports'),
                                  Tab(text: 'Notices'),
                                ],
                              ),
                            ),
                          ),
                        ],
                        body: RefreshIndicator(
                          color: context.accent,
                          onRefresh: () async {
                            await ref.read(profileControllerProvider.notifier).refresh();
                            ref.invalidate(academyDetailProvider);
                          },
                          child: TabBarView(
                            controller: _tabs,
                            children: [
                              _OverviewTab(academy: academy),
                              _ScheduleTab(detailAsync: detailAsync),
                              _FeesTab(data: academy),
                              _DrillsTab(detailAsync: detailAsync),
                              _ReportsTab(detailAsync: detailAsync),
                              _NoticesTab(detailAsync: detailAsync),
                            ],
                          ),
                        ),
                      );
                    }),
    );
  }

  double _cardHeight(AcademySummary a) => a.isLinked ? 310 : 240;
}

// ── Digital ID Card ───────────────────────────────────────────────────────────

class _IdCard extends StatelessWidget {
  const _IdCard({
    required this.academy,
    required this.playerName,
    required this.swingId,
    required this.avatarUrl,
  });

  final AcademySummary academy;
  final String playerName;
  final String swingId;
  final String? avatarUrl;

  void _showQr(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(playerName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF071B3D))),
            Text('@$swingId',
                style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            QrImageView(
              data: swingId,
              version: QrVersions.auto,
              size: 220,
              eyeStyle: const QrEyeStyle(color: Color(0xFF071B3D), eyeShape: QrEyeShape.square),
              dataModuleStyle: const QrDataModuleStyle(color: Color(0xFF071B3D), dataModuleShape: QrDataModuleShape.square),
            ),
            const SizedBox(height: 16),
            Text('Show this at the academy',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initial = playerName.isNotEmpty ? playerName[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: () => _showQr(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        decoration: BoxDecoration(color: const Color(0xFF071B3D), borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: avatarUrl != null
                  ? ClipRRect(borderRadius: BorderRadius.circular(14),
                      child: Image.network(avatarUrl!, fit: BoxFit.cover))
                  : Center(child: Text(initial,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(playerName,
                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text('@$swingId',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.w600)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: QrImageView(
                data: swingId,
                version: QrVersions.auto,
                size: 52,
                eyeStyle: const QrEyeStyle(color: Color(0xFF071B3D), eyeShape: QrEyeShape.square),
                dataModuleStyle: const QrDataModuleStyle(color: Color(0xFF071B3D), dataModuleShape: QrDataModuleShape.square),
              ),
            ),
          ]),
          if (academy.isLinked) ...[
            const SizedBox(height: 18),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _cardField('ACADEMY', academy.academyName ?? '—')),
              if ((academy.batchName ?? '').isNotEmpty)
                Expanded(child: _cardField('BATCH', academy.batchName!)),
            ]),
            if ((academy.batchSchedule ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              _cardField('SCHEDULE', academy.batchSchedule!),
            ],
          ],
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.touch_app_rounded, size: 12, color: Colors.white.withValues(alpha: 0.3)),
            const SizedBox(width: 4),
            Text('Tap to expand QR',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11, fontWeight: FontWeight.w600)),
          ]),
        ]),
      ),
    );
  }

  Widget _cardField(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
    const SizedBox(height: 3),
    Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
  ]);
}

// ── Overview Tab ──────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.academy});
  final AcademySummary academy;

  @override
  Widget build(BuildContext context) {
    if (!academy.isLinked) return _notLinked(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        // Fee quick status
        _feeStatusRow(context),
        const SizedBox(height: 16),
        // Academy details
        _Section(title: 'Academy Details', child: Column(children: [
          if ((academy.coachName ?? '').isNotEmpty)
            _Row(icon: Icons.sports_rounded, label: 'Coach', value: academy.coachName!),
          if ((academy.academyCity ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            _Row(icon: Icons.location_on_outlined, label: 'City', value: academy.academyCity!),
          ],
          if ((academy.nextSessionLabel ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            _Row(icon: Icons.access_time_rounded, label: 'Next Session', value: academy.nextSessionLabel!),
          ],
          if ((academy.latestReportSummary ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            _Row(icon: Icons.notes_rounded, label: 'Latest Report', value: academy.latestReportSummary!),
          ],
        ])),
      ],
    );
  }

  Widget _feeStatusRow(BuildContext context) {
    final isDue = academy.feeDuePaise > 0;
    final color = isDue ? const Color(0xFFF59E0B) : const Color(0xFF16A34A);
    final label = isDue ? 'Fee Due  ${_currency(academy.feeDuePaise)}' : 'Fee Paid';
    final icon = isDue ? Icons.warning_amber_rounded : Icons.check_circle_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
        const Spacer(),
        Text(_currency(academy.feeAmountPaise),
            style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _notLinked(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.school_outlined, color: context.accent, size: 40),
        const SizedBox(height: 16),
        Text('No Academy Yet', style: TextStyle(color: context.fg, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('Your coach will link you once you enroll.',
            style: TextStyle(color: context.fgSub, fontSize: 13, height: 1.5), textAlign: TextAlign.center),
      ]),
    ),
  );

  String _currency(int p) => NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(p / 100);
}

// ── Schedule Tab ──────────────────────────────────────────────────────────────

class _ScheduleTab extends StatelessWidget {
  const _ScheduleTab({required this.detailAsync});
  final AsyncValue<AcademyDetailData> detailAsync;

  @override
  Widget build(BuildContext context) {
    return detailAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _errorWidget(context, e.toString()),
      data: (d) {
        final s = d.schedule;
        if (s.schedules.isEmpty && s.upcomingSessions.isEmpty) {
          return _empty(context, 'No schedule set yet.', Icons.calendar_today_outlined);
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            // Weekly recurring schedule
            if (s.schedules.isNotEmpty) ...[
              _Section(
                title: 'Weekly Schedule${s.batchName != null ? ' · ${s.batchName}' : ''}',
                child: Column(children: s.schedules.asMap().entries.map((e) {
                  final i = e.key;
                  final sc = e.value;
                  final isLast = i == s.schedules.length - 1;
                  return Container(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
                    margin: EdgeInsets.only(bottom: isLast ? 0 : 14),
                    decoration: BoxDecoration(
                      border: isLast ? null : Border(bottom: BorderSide(color: context.stroke)),
                    ),
                    child: Row(children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: context.accentBg, borderRadius: BorderRadius.circular(12)),
                        child: Center(child: Text(sc.day,
                            style: TextStyle(color: context.accent, fontSize: 12, fontWeight: FontWeight.w800))),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${sc.startTime} – ${sc.endTime}',
                            style: TextStyle(color: context.fg, fontSize: 15, fontWeight: FontWeight.w700)),
                        if ((sc.groundNote ?? '').isNotEmpty)
                          Text(sc.groundNote!, style: TextStyle(color: context.fgSub, fontSize: 12)),
                      ])),
                    ]),
                  );
                }).toList()),
              ),
              const SizedBox(height: 16),
            ],

            // Upcoming sessions
            if (s.upcomingSessions.isNotEmpty)
              _Section(
                title: 'Upcoming Sessions',
                child: Column(children: s.upcomingSessions.asMap().entries.map((e) {
                  final i = e.key;
                  final session = e.value;
                  final isLast = i == s.upcomingSessions.length - 1;
                  final cancelled = session.isCancelled;
                  final date = DateFormat('EEE, d MMM').format(session.scheduledAt);
                  final time = DateFormat('h:mm a').format(session.scheduledAt);

                  return Container(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
                    margin: EdgeInsets.only(bottom: isLast ? 0 : 14),
                    decoration: BoxDecoration(
                      border: isLast ? null : Border(bottom: BorderSide(color: context.stroke)),
                    ),
                    child: Row(children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: cancelled
                              ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                              : context.accentBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          cancelled ? Icons.cancel_outlined : Icons.sports_cricket_rounded,
                          size: 20,
                          color: cancelled ? const Color(0xFFEF4444) : context.accent,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(date,
                            style: TextStyle(
                              color: cancelled ? context.fgSub : context.fg,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              decoration: cancelled ? TextDecoration.lineThrough : null,
                            )),
                        Text(
                          cancelled
                              ? (session.cancelReason ?? 'Cancelled')
                              : '$time · ${session.durationMins} mins${session.locationName != null ? ' · ${session.locationName}' : ''}',
                          style: TextStyle(
                            color: cancelled ? const Color(0xFFEF4444) : context.fgSub,
                            fontSize: 12,
                          ),
                        ),
                      ])),
                      if (!cancelled)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.accentBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(session.sessionType,
                              style: TextStyle(color: context.accent, fontSize: 10, fontWeight: FontWeight.w700)),
                        ),
                    ]),
                  );
                }).toList()),
              ),
          ],
        );
      },
    );
  }
}

// ── Fees Tab ──────────────────────────────────────────────────────────────────

class _FeesTab extends ConsumerStatefulWidget {
  const _FeesTab({required this.data});
  final AcademySummary data;

  @override
  ConsumerState<_FeesTab> createState() => _FeesTabState();
}

class _FeesTabState extends ConsumerState<_FeesTab> {
  late final Razorpay _razorpay;
  bool _isPaying = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (_) {});
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final isDue = d.feeDuePaise > 0;
    final isPaid = !isDue && d.feePaidPaise > 0;
    final statusColor = isPaid ? const Color(0xFF16A34A) : const Color(0xFFF59E0B);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        // Fee status card
        _Section(
          title: 'Fee Status',
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(
                  isPaid ? 'PAID' : (isDue ? 'DUE' : (d.feeStatus?.toUpperCase() ?? '—')),
                  style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.w800),
                ),
              ),
              const Spacer(),
              if ((d.feeFrequency ?? '').isNotEmpty)
                Text(d.feeFrequency!,
                    style: TextStyle(color: context.fgSub, fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              _FeeStat('Total', _currency(d.feeAmountPaise)),
              const SizedBox(width: 24),
              _FeeStat('Paid', _currency(d.feePaidPaise)),
              const SizedBox(width: 24),
              _FeeStat('Due', _currency(d.feeDuePaise), highlight: isDue),
            ]),
            if (isDue && d.enrollmentId != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, height: 46,
                child: ElevatedButton(
                  onPressed: _isPaying ? null : _payFee,
                  child: _isPaying
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Pay Now  ${_currency(d.feeDuePaise)}',
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ]),
        ),
        const SizedBox(height: 16),

        // Payment history
        _Section(
          title: 'Payment History',
          child: d.transactions.isEmpty
              ? Text('No transactions yet.', style: TextStyle(color: context.fgSub, fontSize: 13))
              : Column(children: d.transactions.asMap().entries.map((e) {
                  final i = e.key;
                  final tx = e.value;
                  final isLast = i == d.transactions.length - 1;
                  final ok = _isOk(tx.status);
                  final pending = _isPending(tx.status);
                  final c = ok ? const Color(0xFF16A34A) : (pending ? const Color(0xFFF59E0B) : const Color(0xFFEF4444));
                  final icon = ok ? Icons.check_circle_rounded : (pending ? Icons.schedule_rounded : Icons.cancel_rounded);

                  return Container(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
                    margin: EdgeInsets.only(bottom: isLast ? 0 : 14),
                    decoration: BoxDecoration(
                        border: isLast ? null : Border(bottom: BorderSide(color: context.stroke))),
                    child: Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        child: Icon(icon, size: 18, color: c),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(_currency(tx.amountPaise),
                            style: TextStyle(color: context.fg, fontSize: 15, fontWeight: FontWeight.w800)),
                        Text(
                          [tx.status, if ((tx.mode ?? '').isNotEmpty) tx.mode!].join(' · '),
                          style: TextStyle(color: context.fgSub, fontSize: 12),
                        ),
                      ])),
                      if (tx.createdAt != null)
                        Text(DateFormat('d MMM yy').format(tx.createdAt!),
                            style: TextStyle(color: context.fgSub, fontSize: 11, fontWeight: FontWeight.w600)),
                    ]),
                  );
                }).toList()),
        ),
      ],
    );
  }

  bool _isOk(String s) {
    final n = s.toLowerCase();
    return n.contains('paid') || n.contains('success') || n.contains('completed') || n.contains('captured');
  }

  bool _isPending(String s) => s.toLowerCase().contains('pending') || s.toLowerCase().contains('processing');

  Future<void> _payFee() async {
    final enrollmentId = widget.data.enrollmentId;
    if (enrollmentId == null) return;
    setState(() => _isPaying = true);
    try {
      final order = await ref.read(academyFeeServiceProvider).createFeeOrder(enrollmentId);
      if (order.amountPaise <= 0 || order.orderId.isEmpty) throw Exception('No payable fee');
      _razorpay.open({
        'key': order.key,
        'amount': order.amountPaise,
        'currency': order.currency,
        'name': 'Swing',
        'description': 'Academy Fee',
        'order_id': order.orderId,
        'prefill': {},
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPaying = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    }
  }

  Future<void> _onSuccess(PaymentSuccessResponse r) async {
    try {
      await ref.read(academyFeeServiceProvider).verifyFeePayment(
          orderId: r.orderId ?? '', paymentId: r.paymentId ?? '', signature: r.signature ?? '');
      await ref.read(profileControllerProvider.notifier).refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment successful')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _isPaying = false);
    }
  }

  void _onError(PaymentFailureResponse r) {
    if (!mounted) return;
    setState(() => _isPaying = false);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(r.message?.isNotEmpty == true ? r.message! : 'Payment failed')));
  }

  String _currency(int p) => NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(p / 100);
}

// ── Drills Tab ────────────────────────────────────────────────────────────────

class _DrillsTab extends ConsumerWidget {
  const _DrillsTab({required this.detailAsync});
  final AsyncValue<AcademyDetailData> detailAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return detailAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _errorWidget(context, e.toString()),
      data: (d) {
        final active = d.drillAssignments.where((x) => !x.isCompleted).toList();
        final done = d.drillAssignments.where((x) => x.isCompleted).toList();

        if (d.drillAssignments.isEmpty) {
          return _empty(context, 'No drills assigned yet.', Icons.fitness_center_rounded);
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            if (active.isNotEmpty) ...[
              _Section(
                title: 'Active Drills',
                child: Column(children: active.asMap().entries.map((e) {
                  final isLast = e.key == active.length - 1;
                  return _DrillCard(drill: e.value, isLast: isLast, onLog: (id, qty) async {
                    await ref.read(academyDetailRepositoryProvider).logDrillProgress(id, qty);
                    ref.invalidate(academyDetailProvider);
                  });
                }).toList()),
              ),
              const SizedBox(height: 16),
            ],
            if (done.isNotEmpty)
              _Section(
                title: 'Completed',
                child: Column(children: done.asMap().entries.map((e) {
                  final isLast = e.key == done.length - 1;
                  return _DrillCard(drill: e.value, isLast: isLast, onLog: null);
                }).toList()),
              ),
          ],
        );
      },
    );
  }
}

class _DrillCard extends StatelessWidget {
  const _DrillCard({required this.drill, required this.isLast, required this.onLog});
  final DrillAssignmentItem drill;
  final bool isLast;
  final Future<void> Function(String id, int qty)? onLog;

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF16A34A);

    return Container(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      margin: EdgeInsets.only(bottom: isLast ? 0 : 14),
      decoration: BoxDecoration(
          border: isLast ? null : Border(bottom: BorderSide(color: context.stroke))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: drill.isCompleted ? green.withValues(alpha: 0.1) : context.accentBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            drill.isCompleted ? Icons.check_rounded : Icons.fitness_center_rounded,
            size: 18,
            color: drill.isCompleted ? green : context.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(drill.drillName,
              style: TextStyle(color: context.fg, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(
            '${drill.targetQuantity} ${drill.targetUnit.toLowerCase()}'
            '${drill.skillArea != null ? ' · ${drill.skillArea}' : ''}'
            '${drill.difficulty != null ? ' · ${drill.difficulty}' : ''}',
            style: TextStyle(color: context.fgSub, fontSize: 12),
          ),
          if (drill.dueDate != null) ...[
            const SizedBox(height: 2),
            Text(
              'Due ${DateFormat('d MMM').format(drill.dueDate!)}',
              style: TextStyle(
                color: drill.dueDate!.isBefore(DateTime.now())
                    ? const Color(0xFFEF4444)
                    : context.fgSub,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (onLog != null) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _logDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: context.accentBg, borderRadius: BorderRadius.circular(8)),
                child: Text('Log Progress',
                    style: TextStyle(color: context.accent, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ])),
      ]),
    );
  }

  void _logDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(drill.drillName),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              labelText: 'How many ${drill.targetUnit.toLowerCase()}?'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final qty = int.tryParse(ctrl.text.trim());
              if (qty != null && qty > 0) {
                Navigator.pop(context);
                onLog?.call(drill.id, qty);
              }
            },
            child: const Text('Log'),
          ),
        ],
      ),
    );
  }
}

// ── Reports Tab ───────────────────────────────────────────────────────────────

class _ReportsTab extends StatelessWidget {
  const _ReportsTab({required this.detailAsync});
  final AsyncValue<AcademyDetailData> detailAsync;

  @override
  Widget build(BuildContext context) {
    return detailAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _errorWidget(context, e.toString()),
      data: (d) {
        if (d.reportCards.isEmpty) {
          return _empty(context, 'No report cards published yet.', Icons.assignment_outlined);
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: d.reportCards.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _Section(
              title: r.month,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Score row
                Row(children: [
                  if (r.attendanceRate != null)
                    _ScoreChip('Attendance', '${r.attendanceRate!.toStringAsFixed(0)}%',
                        const Color(0xFF0057C8)),
                  if (r.drillCompletion != null) ...[
                    const SizedBox(width: 8),
                    _ScoreChip('Drills', '${r.drillCompletion!.toStringAsFixed(0)}%',
                        const Color(0xFF16A34A)),
                  ],
                  if (r.overallScore != null) ...[
                    const SizedBox(width: 8),
                    _ScoreChip('Index', r.overallScore!.toStringAsFixed(1),
                        const Color(0xFFF59E0B)),
                  ],
                ]),
                if (r.summary.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(r.summary,
                      style: TextStyle(color: context.fg, fontSize: 13, height: 1.5)),
                ],
                if (r.highlights.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('Strengths', style: TextStyle(color: context.fgSub, fontSize: 11, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  ...r.highlights.map((h) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('• ', style: TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.w700)),
                      Expanded(child: Text(h, style: TextStyle(color: context.fg, fontSize: 13))),
                    ]),
                  )),
                ],
                if (r.improvements.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Focus Areas', style: TextStyle(color: context.fgSub, fontSize: 11, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  ...r.improvements.map((imp) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('• ', style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w700)),
                      Expanded(child: Text(imp, style: TextStyle(color: context.fg, fontSize: 13))),
                    ]),
                  )),
                ],
              ]),
            ),
          )).toList(),
        );
      },
    );
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
    child: Column(children: [
      Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w800)),
      Text(label, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 10, fontWeight: FontWeight.w600)),
    ]),
  );
}

// ── Notices Tab ───────────────────────────────────────────────────────────────

class _NoticesTab extends StatelessWidget {
  const _NoticesTab({required this.detailAsync});
  final AsyncValue<AcademyDetailData> detailAsync;

  @override
  Widget build(BuildContext context) {
    return detailAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _errorWidget(context, e.toString()),
      data: (d) {
        if (d.announcements.isEmpty) {
          return _empty(context, 'No notices yet.', Icons.campaign_outlined);
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: d.announcements.asMap().entries.map((e) {
            final a = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: a.isPinned ? context.accent.withValues(alpha: 0.4) : context.stroke,
                  ),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    if (a.isPinned) ...[
                      Icon(Icons.push_pin_rounded, size: 14, color: context.accent),
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: Text(a.title,
                          style: TextStyle(color: context.fg, fontSize: 14, fontWeight: FontWeight.w700)),
                    ),
                    Text(DateFormat('d MMM').format(a.createdAt),
                        style: TextStyle(color: context.fgSub, fontSize: 11, fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 8),
                  Text(a.body, style: TextStyle(color: context.fg, fontSize: 13, height: 1.5)),
                ]),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: context.cardBg,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: context.stroke),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title.toUpperCase(),
          style: TextStyle(color: context.fgSub, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
      const SizedBox(height: 14),
      child,
    ]),
  );
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(
      width: 34, height: 34,
      decoration: BoxDecoration(color: context.panel, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, size: 16, color: context.accent),
    ),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 2),
      Text(label, style: TextStyle(color: context.fgSub, fontSize: 11, fontWeight: FontWeight.w700)),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(color: context.fg, fontSize: 14, fontWeight: FontWeight.w600, height: 1.4)),
    ])),
  ]);
}

class _FeeStat extends StatelessWidget {
  const _FeeStat(this.label, this.value, {this.highlight = false});
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label.toUpperCase(),
        style: TextStyle(color: context.fgSub, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
    const SizedBox(height: 4),
    Text(value,
        style: TextStyle(
          color: highlight ? const Color(0xFFF59E0B) : context.fg,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        )),
  ]);
}

Widget _errorWidget(BuildContext context, String msg) => Center(
  child: Padding(
    padding: const EdgeInsets.all(28),
    child: Text(msg, style: TextStyle(color: context.fgSub, fontSize: 13), textAlign: TextAlign.center),
  ),
);

Widget _empty(BuildContext context, String msg, IconData icon) => Center(
  child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 36, color: context.fgSub),
    const SizedBox(height: 12),
    Text(msg, style: TextStyle(color: context.fgSub, fontSize: 14, fontWeight: FontWeight.w600)),
  ]),
);

class _AcademyError extends StatelessWidget {
  const _AcademyError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.school_outlined, color: context.danger, size: 38),
        const SizedBox(height: 16),
        Text('Could not load academy',
            style: TextStyle(color: context.fg, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(message,
            style: TextStyle(color: context.fgSub, fontSize: 13, height: 1.45),
            textAlign: TextAlign.center),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
      ]),
    ),
  );
}
