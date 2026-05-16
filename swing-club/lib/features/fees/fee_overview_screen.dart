import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/academy_provider.dart';
import '../../shared/widgets.dart';
import '../staff/staff_provider.dart';
import '../students/student_provider.dart';
import 'fee_provider.dart';
import 'fee_structure_sheet.dart';
import 'add_expense_sheet.dart';
import 'finance_add_sheet.dart';

// ── Palette ───────────────────────────────────────────────────────────────────

class _C {
  static const green  = Color(0xFF16A34A);
  static const red    = Color(0xFFDC2626);
  static const blue   = Color(0xFF2563EB);
  static const orange = Color(0xFFEA580C);
  static const wa     = Color(0xFF25D366);

  static const mint  = Color(0xFFC4E8D4);
  static const coral = Color(0xFFFFD5D5);
  static const beige = Color(0xFFEDE0C4);
  static const sky   = Color(0xFFC8DCF0);
}

String _fmt(int paise) {
  final r = paise / 100;
  if (r >= 100000) return '₹${(r / 100000).toStringAsFixed(1)}L';
  if (r >= 1000)   return '₹${(r / 1000).toStringAsFixed(1)}K';
  return '₹${r.toStringAsFixed(0)}';
}

// ── Screen ────────────────────────────────────────────────────────────────────

class FeeOverviewScreen extends ConsumerStatefulWidget {
  const FeeOverviewScreen({super.key});

  @override
  ConsumerState<FeeOverviewScreen> createState() => _FeeOverviewScreenState();
}

class _FeeOverviewScreenState extends ConsumerState<FeeOverviewScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 6, vsync: this);

  @override
  void initState() {
    super.initState();
    _tabs.addListener(() { if (mounted) setState(() {}); });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _openAdd() => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (_) => const FinanceAddSheet(),
      );

  void _openStructure() => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (_) => const FeeStructureSheet(),
      );

  void _refresh() {
    ref.invalidate(financeSummaryProvider);
    ref.invalidate(expensesProvider);
    ref.invalidate(paymentsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final cs           = Theme.of(context).colorScheme;
    final summaryState = ref.watch(financeSummaryProvider);
    final month        = DateFormat('MMMM yyyy').format(DateTime.now());
    final divColor     = cs.onSurface.withValues(alpha: 0.08);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Finance',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
                              color: cs.onSurface, letterSpacing: -0.5)),
                      const SizedBox(height: 2),
                      Text(month,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                              color: cs.onSurface.withValues(alpha: 0.45))),
                    ],
                  ),
                ),
                _BoxedIcon(icon: Icons.refresh_rounded, onTap: _refresh),
                if (_tabs.index != 1 && _tabs.index != 4) ...[
                  const SizedBox(width: 8),
                  _OutlineBtn(
                    icon: _tabs.index == 3 ? Icons.account_tree_outlined : Icons.add_rounded,
                    label: _tabs.index == 3 ? 'Structure' : 'Add',
                    onTap: _tabs.index == 3 ? _openStructure : _openAdd,
                  ),
                ],
              ]),
            ),

            // ── Summary cards (async) ─────────────────────────────────────
            summaryState.when(
              loading: () => const SizedBox(height: 130,
                  child: Center(child: SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)))),
              error: (_, _) => const SizedBox(height: 130),
              data: (s) {
                final revenue  = (s['revenuePaise']  as num? ?? 0).toInt();
                final expenses = (s['expensesPaise'] as num? ?? 0).toInt();
                final net      = (s['netPaise']      as num? ?? 0).toInt();
                final netPos   = net >= 0;
                final collRate = (revenue + expenses) > 0
                    ? (revenue / (revenue + expenses)).clamp(0.0, 1.0) : 0.0;
                final collPct  = (collRate * 100).round();

                return Column(children: [
                  // Cards
                  SizedBox(
                    height: 130,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      children: [
                        _SummaryCard(color: _C.mint,  label: 'Revenue',    value: _fmt(revenue),                        sub: 'collected'),
                        const SizedBox(width: 12),
                        _SummaryCard(color: _C.coral, label: 'Expenses',   value: _fmt(expenses),                       sub: 'spent'),
                        const SizedBox(width: 12),
                        _SummaryCard(color: _C.beige, label: 'Net P&L',    value: '${netPos ? '+' : ''}${_fmt(net)}',   sub: netPos ? 'profit' : 'loss'),
                        const SizedBox(width: 12),
                        _SummaryCard(color: _C.sky,   label: 'Collection', value: '$collPct%',                          sub: 'rate'),
                      ],
                    ),
                  ),
                  // Progress bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LayoutBuilder(builder: (_, box) => SizedBox(
                        height: 4,
                        child: Stack(children: [
                          Container(width: box.maxWidth, height: 4,
                              color: cs.onSurface.withValues(alpha: 0.07)),
                          Container(width: box.maxWidth * collRate, height: 4,
                              color: netPos ? _C.green : _C.red),
                        ]),
                      )),
                    ),
                  ),
                ]);
              },
            ),

            // ── Divider ───────────────────────────────────────────────────
            Divider(height: 1, thickness: 0.5, color: divColor),

            // ── Tab bar ───────────────────────────────────────────────────
            TabBar(
              controller: _tabs,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: const [
                Tab(text: 'Wallet'),
                Tab(text: 'Fees'),
                Tab(text: 'Pending'),
                Tab(text: 'Expenses'),
                Tab(text: 'Structures'),
                Tab(text: 'Payroll'),
              ],
            ),

            // ── Tab content ───────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: const [
                  _WalletTab(),
                  _FeesTab(),
                  _PendingTab(),
                  _ExpensesTab(),
                  _StructuresTab(),
                  _PayrollTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Summary Card ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final String sub;
  const _SummaryCard({required this.color, required this.label,
      required this.value, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0x99000000))),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
              color: Color(0xD9000000), letterSpacing: -1, height: 1)),
          const SizedBox(height: 3),
          Text(sub, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0x80000000))),
        ],
      ),
    );
  }
}

// ── Circle / Boxed buttons ────────────────────────────────────────────────────

class _BoxedIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _BoxedIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: cs.onSurface.withValues(alpha: 0.12), width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 18, color: cs.onSurface.withValues(alpha: 0.6)),
      ),
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _OutlineBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          border: Border.all(color: cs.onSurface.withValues(alpha: 0.12), width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: cs.onSurface),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
              color: cs.onSurface)),
        ]),
      ),
    );
  }
}

// ── Wallet Tab ────────────────────────────────────────────────────────────────

class _Txn {
  final DateTime date;
  final String title;
  final String subtitle;
  final int amountPaise;
  final bool isIncome;
  const _Txn({required this.date, required this.title, required this.subtitle,
      required this.amountPaise, required this.isIncome});
}

class _WalletTab extends ConsumerWidget {
  const _WalletTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs           = Theme.of(context).colorScheme;
    final summaryState = ref.watch(financeSummaryProvider);
    final paymentsState = ref.watch(paymentsProvider);
    final expensesState = ref.watch(expensesProvider);

    if (paymentsState.isLoading || expensesState.isLoading) return loadingBody();

    final payments = paymentsState.valueOrNull ?? [];
    final expenses = expensesState.valueOrNull ?? [];

    // Flatten individual payment records from enrollment history
    final txns = <_Txn>[];
    for (final e in payments) {
      final name  = e['studentName'] as String? ?? '—';
      final batch = e['batchName']   as String? ?? '';
      for (final h in (e['history'] as List? ?? []).cast<Map>()) {
        final raw = h['date'] as String?;
        if (raw == null) continue;
        DateTime? dt;
        try { dt = DateTime.parse(raw).toLocal(); } catch (_) { continue; }
        txns.add(_Txn(
          date: dt,
          title: name,
          subtitle: batch,
          amountPaise: (h['amount'] as num? ?? 0).toInt(),
          isIncome: true,
        ));
      }
    }

    // Add expense records
    for (final e in expenses) {
      final raw = e['date'] as String?;
      DateTime dt;
      try { dt = DateTime.parse(raw ?? '').toLocal(); } catch (_) { dt = DateTime.now(); }
      txns.add(_Txn(
        date: dt,
        title: e['description'] as String? ?? '—',
        subtitle: e['payee'] as String? ?? (e['category'] as String? ?? ''),
        amountPaise: (e['amountPaise'] as num? ?? 0).toInt(),
        isIncome: false,
      ));
    }

    txns.sort((a, b) => b.date.compareTo(a.date));

    // Group by date label
    final groups = <String, List<_Txn>>{};
    final today     = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    for (final t in txns) {
      String label;
      if (_sameDay(t.date, today))     label = 'Today';
      else if (_sameDay(t.date, yesterday)) label = 'Yesterday';
      else label = DateFormat('d MMM yyyy').format(t.date);
      groups.putIfAbsent(label, () => []).add(t);
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(financeSummaryProvider);
        ref.invalidate(paymentsProvider);
        ref.invalidate(expensesProvider);
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: [
          // ── Balance strip ──────────────────────────────────────────────
          summaryState.when(
            loading: () => const SizedBox(height: 72),
            error: (_, __) => const SizedBox.shrink(),
            data: (s) {
              final revenue  = (s['revenuePaise']  as num? ?? 0).toInt();
              final expTotal = (s['expensesPaise'] as num? ?? 0).toInt();
              final net      = (s['netPaise']      as num? ?? 0).toInt();
              final isPos    = net >= 0;
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Net this month',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                            color: cs.onSurface.withValues(alpha: 0.45))),
                    const SizedBox(height: 4),
                    Text('${isPos ? '+' : ''}${_fmt(net)}',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                            color: isPos ? _C.green : _C.red)),
                    const SizedBox(height: 3),
                    Text('₹${_fmt(revenue)} in  ·  ₹${_fmt(expTotal)} out',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                            color: cs.onSurface.withValues(alpha: 0.4))),
                  ])),
                ]),
              );
            },
          ),

          Divider(height: 28, thickness: 0.5,
              color: cs.onSurface.withValues(alpha: 0.08)),

          if (txns.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Center(child: Text('No transactions yet',
                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.35),
                      fontSize: 14, fontWeight: FontWeight.w500))),
            )
          else
            for (final entry in groups.entries) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Text(entry.key,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: cs.onSurface.withValues(alpha: 0.4))),
              ),
              ...entry.value.map((t) => _TxnTile(txn: t)),
              Divider(height: 1, thickness: 0.5,
                  color: cs.onSurface.withValues(alpha: 0.06)),
            ],
        ],
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _TxnTile extends StatelessWidget {
  final _Txn txn;
  const _TxnTile({required this.txn});

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final color  = txn.isIncome ? _C.green : _C.red;
    final sign   = txn.isIncome ? '+' : '−';
    final icon   = txn.isIncome
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(txn.title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                  color: cs.onSurface)),
          if (txn.subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(txn.subtitle,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                    color: cs.onSurface.withValues(alpha: 0.4))),
          ],
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('$sign${rupeesFromPaise(txn.amountPaise)}',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                  color: color)),
          const SizedBox(height: 2),
          Text(DateFormat('h:mm a').format(txn.date),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
                  color: cs.onSurface.withValues(alpha: 0.35))),
        ]),
      ]),
    );
  }
}

// ── Fees Tab ──────────────────────────────────────────────────────────────────

class _FeesTab extends ConsumerWidget {
  const _FeesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs    = Theme.of(context).colorScheme;
    final state = ref.watch(paymentsProvider);
    return state.when(
      loading: loadingBody,
      error: (e, _) => errorBody(e, () => ref.invalidate(paymentsProvider)),
      data: (payments) {
        if (payments.isEmpty) return emptyBody('No payments recorded yet');
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(paymentsProvider),
          child: ListView.separated(
            itemCount: payments.length,
            separatorBuilder: (_, __) => Divider(height: 1, thickness: 0.5,
                indent: 72, color: cs.onSurface.withValues(alpha: 0.07)),
            itemBuilder: (_, i) => _PaymentTile(payment: payments[i]),
          ),
        );
      },
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final Map<String, dynamic> payment;
  const _PaymentTile({required this.payment});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final name    = payment['studentName'] as String? ?? '—';
    final batch   = payment['batchName']   as String? ?? '';
    final status  = payment['status']      as String? ?? '';
    final amount  = rupeesFromPaise(payment['amount']);
    final history = (payment['history'] as List? ?? []).cast<Map>();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final color   = _avatarColor(name);

    String dateLabel = '';
    if (history.isNotEmpty) {
      final d = history.first['date'] as String?;
      if (d != null) {
        try { dateLabel = DateFormat('d MMM').format(DateTime.parse(d).toLocal()); } catch (_) {}
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      child: Row(children: [
        // Avatar
        CircleAvatar(
          radius: 22,
          backgroundColor: color.withValues(alpha: 0.12),
          child: Text(initial,
              style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 15)),
        ),
        const SizedBox(width: 14),

        // Name + batch/date
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14,
                  color: cs.onSurface)),
          const SizedBox(height: 3),
          Text(
            [if (batch.isNotEmpty) batch, if (dateLabel.isNotEmpty) dateLabel].join('  ·  '),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                color: cs.onSurface.withValues(alpha: 0.45)),
          ),
        ])),

        // Amount + status
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(amount,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15,
                  color: cs.onSurface)),
          const SizedBox(height: 4),
          statusBadge(status),
        ]),
      ]),
    );
  }
}

// ── Pending Tab ───────────────────────────────────────────────────────────────

class _PendingTab extends ConsumerWidget {
  const _PendingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs    = Theme.of(context).colorScheme;
    final state = ref.watch(paymentsProvider);
    return state.when(
      loading: loadingBody,
      error: (e, _) => errorBody(e, () => ref.invalidate(paymentsProvider)),
      data: (payments) {
        final pending = payments.where((e) => e['status'] != 'PAID').toList();
        if (pending.isEmpty) return emptyBody('All fees are collected 🎉');
        return ListView.separated(
          itemCount: pending.length,
          separatorBuilder: (_, __) => Divider(height: 1, thickness: 0.5,
              indent: 72, color: cs.onSurface.withValues(alpha: 0.07)),
          itemBuilder: (_, i) => _PendingTile(enrollment: pending[i]),
        );
      },
    );
  }
}

class _PendingTile extends ConsumerStatefulWidget {
  final Map<String, dynamic> enrollment;
  const _PendingTile({required this.enrollment});
  @override
  ConsumerState<_PendingTile> createState() => _PendingTileState();
}

class _PendingTileState extends ConsumerState<_PendingTile> {
  bool _loading = false;

  Future<void> _sendReminder() async {
    final enrollment  = widget.enrollment;
    final enrollmentId = enrollment['enrollmentId'] as String? ?? enrollment['id'] as String? ?? '';
    final studentName  = enrollment['studentName'] as String? ?? '—';
    final batchName    = enrollment['batchName']   as String? ?? '';
    final amount       = rupeesFromPaise(enrollment['amount']);

    if (enrollmentId.isEmpty) { showSnack(context, 'No enrollment ID'); return; }
    final amountPaise = (widget.enrollment['amount'] as num?)?.toInt() ?? 0;
    if (amountPaise == 0) {
      showSnack(context, 'No fee set for this student — edit their enrollment first');
      return;
    }

    final academyName = ref.read(academyProvider).maybeWhen(
      data: (s) => s.data['name'] as String? ?? 'your academy',
      orElse: () => 'your academy',
    );
    final notifier = ref.read(paymentsProvider.notifier);

    setState(() => _loading = true);
    try {
      final link = await notifier.getPaymentLink(enrollmentId);
      final url  = link['url'] as String? ?? '';

      final studentPhone = ((enrollment['studentPhone'] as String? ?? '')
          .replaceAll(RegExp(r'\D'), ''));
      final parentPhone  = ((enrollment['parentPhone']  as String? ?? '')
          .replaceAll(RegExp(r'\D'), ''));
      final parentName   = enrollment['parentName'] as String? ?? '';

      final greeting = parentName.isNotEmpty ? 'Hi $parentName 👋' : 'Hi 👋';
      final msg = '$greeting\n\n'
          'This is a friendly reminder from *$academyName*.\n\n'
          '*Fee Due for $studentName*\n'
          'Batch: $batchName\n'
          'Amount: *$amount*\n\n'
          'Pay securely via the link below:\n'
          '$url\n\n'
          'Thank you! 🙏';

      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => _SendLinkSheet(
            studentName: studentName,
            studentPhone: studentPhone,
            parentName: parentName,
            parentPhone: parentPhone,
            amount: amount,
            paymentUrl: url,
            message: msg,
          ),
        );
      }
    } catch (e, st) {
      debugPrint('=== getPaymentLink error ===');
      debugPrint(e.toString());
      if (e is DioException) {
        debugPrint('status: ${e.response?.statusCode}');
        debugPrint('body: ${e.response?.data}');
      }
      debugPrint(st.toString());
      if (mounted) {
        String msg = 'Failed to generate link';
        if (e is DioException) {
          final body = e.response?.data;
          if (body is Map) {
            msg = (body['message'] ?? body['error']?['message'] ?? msg) as String;
          }
        }
        showSnack(context, msg);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markPaid() async {
    final enrollment  = widget.enrollment;
    final enrollmentId = enrollment['enrollmentId'] as String? ?? enrollment['id'] as String? ?? '';
    final amountPaise  = (enrollment['amount'] as num?)?.toInt() ?? 0;
    if (enrollmentId.isEmpty) return;

    final notifier = ref.read(paymentsProvider.notifier);
    setState(() => _loading = true);
    try {
      await notifier.recordPayment({
        'enrollmentId': enrollmentId,
        'amountPaise': amountPaise,
        'paymentMode': 'CASH',
      });
      if (mounted) showSnack(context, 'Marked as paid');
    } catch (_) {
      if (mounted) showSnack(context, 'Failed to update');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _removeEnrollment() async {
    final enrollment  = widget.enrollment;
    final enrollmentId = enrollment['enrollmentId'] as String? ?? enrollment['id'] as String? ?? '';
    if (enrollmentId.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Entry',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
            'This will remove the student from the active list. Their history is kept.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFDC2626)),
            child: const Text('Remove', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _loading = true);
    try {
      await ref.read(studentsProvider.notifier).remove(enrollmentId);
      ref.invalidate(paymentsProvider);
    } catch (_) {
      if (mounted) showSnack(context, 'Failed to remove');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showActions() {
    final enrollment  = widget.enrollment;
    final studentName = enrollment['studentName'] as String? ?? '—';
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Text(studentName,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface)),
          ),
          ListTile(
            leading: const Icon(Icons.send_rounded, color: _C.wa, size: 20),
            title: const Text('Send Payment Link',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            onTap: () { Navigator.pop(context); _sendReminder(); },
          ),
          Divider(height: 1, thickness: 0.5, indent: 56,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.07)),
          ListTile(
            leading: const Icon(Icons.check_circle_outline_rounded,
                color: _C.green, size: 20),
            title: const Text('Mark as Paid',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            onTap: () { Navigator.pop(context); _markPaid(); },
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs          = Theme.of(context).colorScheme;
    final enrollment  = widget.enrollment;
    final studentName = enrollment['studentName'] as String? ?? '—';
    final batchName   = enrollment['batchName']   as String? ?? '';
    final amount      = rupeesFromPaise(enrollment['amount']);
    final status      = enrollment['status'] as String? ?? '';
    final initial     = studentName.isNotEmpty ? studentName[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 13, 16, 13),
      child: Row(children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: _C.red.withValues(alpha: 0.10),
          child: Text(initial,
              style: const TextStyle(color: _C.red,
                  fontWeight: FontWeight.w800, fontSize: 15)),
        ),
        const SizedBox(width: 14),

        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(studentName,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14,
                  color: cs.onSurface)),
          const SizedBox(height: 3),
          Row(children: [
            if (batchName.isNotEmpty) ...[
              Text(batchName,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                      color: cs.onSurface.withValues(alpha: 0.45))),
              const SizedBox(width: 6),
            ],
            Text(amount,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    color: _C.red)),
          ]),
        ])),

        Row(mainAxisSize: MainAxisSize.min, children: [
          statusBadge(status),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _loading ? null : _sendReminder,
            child: Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                border: Border.all(color: _C.wa.withValues(alpha: 0.35), width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _loading
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(strokeWidth: 2, color: _C.wa),
                    )
                  : const Icon(Icons.send_rounded, size: 16, color: _C.wa),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: _loading ? null : _showActions,
            child: Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
                    width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.more_vert_rounded, size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _SendLinkSheet extends StatelessWidget {
  final String studentName;
  final String studentPhone;
  final String parentName;
  final String parentPhone;
  final String amount;
  final String paymentUrl;
  final String message;
  const _SendLinkSheet({
    required this.studentName, required this.studentPhone,
    required this.parentName,  required this.parentPhone,
    required this.amount,      required this.paymentUrl,
    required this.message,
  });

  Future<void> _openWa(BuildContext context, String phone) async {
    if (phone.isEmpty) return;
    final num = phone.length == 10 ? '91$phone' : phone;
    await launchUrl(
      Uri.parse('https://wa.me/$num?text=${Uri.encodeComponent(message)}'),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _copyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: paymentUrl));
    if (context.mounted) {
      showSnack(context, 'Link copied to clipboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final noPhones = parentPhone.isEmpty && studentPhone.isEmpty;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + MediaQuery.of(context).padding.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        // drag handle
        Center(
          child: Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: cs.onSurface.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Header
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(studentName,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: cs.onSurface)),
              const SizedBox(height: 2),
              Text('Fee reminder', style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.45))),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(amount,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF16A34A))),
          ),
        ]),
        const SizedBox(height: 20),

        // Message preview bubble
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(message,
              style: TextStyle(fontSize: 12, height: 1.55, color: cs.onSurface.withValues(alpha: 0.7))),
        ),
        const SizedBox(height: 20),

        // Copy link row
        GestureDetector(
          onTap: () => _copyLink(context),
          child: Row(children: [
            Icon(Icons.link_rounded, size: 18, color: cs.onSurface.withValues(alpha: 0.4)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(paymentUrl,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.4))),
            ),
            const SizedBox(width: 8),
            Text('Copy', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: cs.primary)),
          ]),
        ),
        const SizedBox(height: 20),

        // Send buttons
        if (noPhones)
          Text('No phone number on file.', style: TextStyle(color: cs.error, fontSize: 13)),
        if (parentPhone.isNotEmpty) ...[
          _WaRow(
            label: parentName.isNotEmpty ? parentName : 'Parent',
            sublabel: parentPhone,
            onTap: () => _openWa(context, parentPhone),
          ),
          const SizedBox(height: 12),
        ],
        if (studentPhone.isNotEmpty)
          _WaRow(
            label: studentName,
            sublabel: studentPhone,
            onTap: () => _openWa(context, studentPhone),
          ),
      ]),
    );
  }
}

class _WaRow extends StatelessWidget {
  final String label;
  final String sublabel;
  final VoidCallback onTap;
  const _WaRow({required this.label, required this.sublabel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const wa = Color(0xFF25D366);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: wa.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          const Icon(Icons.chat_rounded, color: wa, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: wa)),
            Text(sublabel,
                style: TextStyle(fontSize: 11, color: wa.withValues(alpha: 0.65))),
          ])),
          const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: wa),
        ]),
      ),
    );
  }
}

// ── Expenses Tab ──────────────────────────────────────────────────────────────

class _ExpensesTab extends ConsumerWidget {
  const _ExpensesTab();

  static const _icons = <String, (IconData, Color)>{
    'SALARY':         (Icons.person_outline_rounded,    Color(0xFFDD925A)),
    'EQUIPMENT':      (Icons.sports_cricket_outlined,   Color(0xFF2563EB)),
    'MAINTENANCE':    (Icons.build_outlined,             Color(0xFF795548)),
    'INFRASTRUCTURE': (Icons.domain_outlined,            Color(0xFF16A34A)),
    'MARKETING':      (Icons.campaign_outlined,          Color(0xFF7C3AED)),
    'UTILITIES':      (Icons.bolt_outlined,              Color(0xFF0891B2)),
    'OTHER':          (Icons.receipt_long_outlined,      Color(0xFF6B7280)),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs    = Theme.of(context).colorScheme;
    final state = ref.watch(expensesProvider);
    return state.when(
      loading: loadingBody,
      error: (e, _) => errorBody(e, () => ref.invalidate(expensesProvider)),
      data: (expenses) {
        if (expenses.isEmpty) return emptyBody('No expenses yet — tap Add to record one');
        return ListView.separated(
          itemCount: expenses.length,
          separatorBuilder: (_, __) => Divider(height: 1, thickness: 0.5,
              indent: 72, color: cs.onSurface.withValues(alpha: 0.07)),
          itemBuilder: (_, i) {
            final expense  = expenses[i];
            final id       = expense['id'] as String;
            final category = expense['category'] as String? ?? 'OTHER';
            final iconData = _icons[category] ?? _icons['OTHER']!;

            return Dismissible(
              key: ValueKey(id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete_outline, color: Colors.white),
              ),
              onDismissed: (_) => ref.read(expensesProvider.notifier).remove(id),
              child: GestureDetector(
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                  builder: (_) => AddExpenseSheet(existing: expense),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                  child: Row(children: [
                    // Icon circle
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: iconData.$2.withValues(alpha: 0.12),
                      child: Icon(iconData.$1, color: iconData.$2, size: 19),
                    ),
                    const SizedBox(width: 14),

                    // Description + category
                    Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(expense['description'] as String? ?? '—',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,
                              color: cs.onSurface)),
                      const SizedBox(height: 3),
                      Text(
                        [category,
                          if ((expense['payee'] as String?)?.isNotEmpty == true)
                            expense['payee'] as String,
                        ].join(' · '),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                            color: cs.onSurface.withValues(alpha: 0.45)),
                      ),
                    ])),

                    // Amount + date
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(rupeesFromPaise(expense['amountPaise']),
                          style: const TextStyle(fontWeight: FontWeight.w800,
                              fontSize: 15, color: _C.red)),
                      const SizedBox(height: 4),
                      if ((expense['date'] as String?) != null)
                        Text(
                          () {
                            try {
                              return DateFormat('d MMM').format(
                                  DateTime.parse(expense['date'] as String).toLocal());
                            } catch (_) { return ''; }
                          }(),
                          style: TextStyle(fontSize: 11,
                              color: cs.onSurface.withValues(alpha: 0.4),
                              fontWeight: FontWeight.w500),
                        ),
                    ]),
                  ]),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Structures Tab ────────────────────────────────────────────────────────────

class _StructuresTab extends ConsumerWidget {
  const _StructuresTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs    = Theme.of(context).colorScheme;
    final state = ref.watch(feeStructuresProvider);
    return state.when(
      loading: loadingBody,
      error: (e, _) => errorBody(e, () => ref.invalidate(feeStructuresProvider)),
      data: (structures) => structures.isEmpty
          ? emptyBody('No fee structures yet — tap Add to create one')
          : ListView.separated(
              itemCount: structures.length,
              separatorBuilder: (_, __) => Divider(height: 1, thickness: 0.5,
                  indent: 20, color: cs.onSurface.withValues(alpha: 0.07)),
              itemBuilder: (_, i) => _StructureTile(structure: structures[i]),
            ),
    );
  }
}

class _StructureTile extends StatelessWidget {
  final Map<String, dynamic> structure;
  const _StructureTile({required this.structure});

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final batch = structure['batch'] as Map<String, dynamic>?;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(structure['name'] as String? ?? '—',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14,
                  color: cs.onSurface)),
          const SizedBox(height: 3),
          Text('${rupeesFromPaise(structure['amountPaise'])} · ${structure['frequency'] ?? ''}',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                  color: cs.onSurface.withValues(alpha: 0.45))),
        ])),
        if (batch != null)
          Text(batch['name'] as String? ?? '',
              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4),
                  fontSize: 12, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

// ── Payroll Tab ───────────────────────────────────────────────────────────────

class _PayrollTab extends ConsumerStatefulWidget {
  const _PayrollTab();
  @override
  ConsumerState<_PayrollTab> createState() => _PayrollTabState();
}

class _PayrollTabState extends ConsumerState<_PayrollTab> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year  = now.year;
    _month = now.month;
  }

  void _prevMonth() => setState(() {
    if (_month == 1) { _month = 12; _year--; } else { _month--; }
  });

  void _nextMonth() {
    final now = DateTime.now();
    if (_year > now.year || (_year == now.year && _month >= now.month)) return;
    setState(() {
      if (_month == 12) { _month = 1; _year++; } else { _month++; }
    });
  }

  Future<void> _markPaid(BuildContext ctx, Map<String, dynamic> person) async {
    final name        = person['name'] as String? ?? '—';
    final salaryPaise = person['salaryPaise'] as int? ?? 0;
    final type        = person['type'] as String;
    final confirm = await showDialog<bool>(
      context: ctx,
      builder: (dlgCtx) => AlertDialog(
        title: const Text('Mark as Paid'),
        content: Text('Record salary payment of ₹${(salaryPaise / 100).toStringAsFixed(0)} to $name?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dlgCtx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(dlgCtx, true),  child: const Text('Confirm')),
        ],
      ),
    );
    if (confirm != true || !ctx.mounted) return;

    try {
      final payload = {
        'category':    'SALARY',
        'description': 'Monthly Salary - $name',
        'amountPaise': salaryPaise,
        'date':        DateTime(_year, _month, 1).toIso8601String(),
        'payee':       name,
        if (type == 'STAFF') 'staffId':     person['id'] as String,
        if (type == 'COACH') 'coachLinkId': person['id'] as String,
      };
      await ref.read(expensesProvider.notifier).create(payload);
      ref.invalidate(payrollProvider((year: _year, month: _month)));
      if (ctx.mounted) showSnack(ctx, 'Salary paid ✓');
    } catch (_) {
      if (ctx.mounted) showSnack(ctx, 'Failed to record payment');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs       = Theme.of(context).colorScheme;
    final state    = ref.watch(payrollProvider((year: _year, month: _month)));
    final monthStr = DateFormat('MMMM yyyy').format(DateTime(_year, _month));
    final isCurrentMonth = DateTime.now().year == _year && DateTime.now().month == _month;

    return Column(
      children: [
        // Month navigator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(children: [
            GestureDetector(
              onTap: _prevMonth,
              child: Icon(Icons.chevron_left_rounded, color: cs.onSurface),
            ),
            const SizedBox(width: 8),
            Text(monthStr,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: cs.onSurface)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: isCurrentMonth ? null : _nextMonth,
              child: Icon(Icons.chevron_right_rounded,
                  color: isCurrentMonth
                      ? cs.onSurface.withValues(alpha: 0.25)
                      : cs.onSurface),
            ),
          ]),
        ),
        Divider(height: 1, thickness: 0.5, color: cs.onSurface.withValues(alpha: 0.08)),
        Expanded(
          child: state.when(
            loading: loadingBody,
            error: (e, _) => errorBody(e, () => ref.invalidate(
                payrollProvider((year: _year, month: _month)))),
            data: (data) {
              final staff   = (data['staff']   as List? ?? []).cast<Map<String, dynamic>>();
              final coaches = (data['coaches'] as List? ?? []).cast<Map<String, dynamic>>();
              final all     = [...staff, ...coaches];
              if (all.isEmpty) return emptyBody('No staff or coaches added yet');

              final paid   = all.where((p) => p['isPaid'] == true).length;
              final total  = all.length;
              final totalPaise = all.fold<int>(0, (s, p) => s + (p['salaryPaise'] as int? ?? 0));
              final paidPaise  = all.where((p) => p['isPaid'] == true)
                  .fold<int>(0, (s, p) => s + (p['salaryPaise'] as int? ?? 0));

              return RefreshIndicator(
                onRefresh: () async =>
                    ref.invalidate(payrollProvider((year: _year, month: _month))),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  children: [
                    // Summary row
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('$paid / $total paid',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: cs.onSurface)),
                          const SizedBox(height: 2),
                          Text('₹${(paidPaise / 100).toStringAsFixed(0)} of ₹${(totalPaise / 100).toStringAsFixed(0)}',
                              style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5))),
                        ])),
                        // progress bar
                        SizedBox(
                          width: 80,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: total > 0 ? paid / total : 0,
                              minHeight: 6,
                              color: _C.green,
                              backgroundColor: cs.onSurface.withValues(alpha: 0.08),
                            ),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 16),

                    if (staff.isNotEmpty) ...[
                      _payrollSection('Staff', cs),
                      ...staff.map((p) => _PayrollPersonTile(
                        person: p,
                        onMarkPaid: () => _markPaid(context, p),
                      )),
                      const SizedBox(height: 12),
                    ],

                    if (coaches.isNotEmpty) ...[
                      _payrollSection('Coaches', cs),
                      ...coaches.map((p) => _PayrollPersonTile(
                        person: p,
                        onMarkPaid: () => _markPaid(context, p),
                      )),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _payrollSection(String title, ColorScheme cs) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(title,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            color: cs.onSurface.withValues(alpha: 0.45), letterSpacing: 0.8)),
  );
}

class _PayrollPersonTile extends StatelessWidget {
  final Map<String, dynamic> person;
  final VoidCallback onMarkPaid;
  const _PayrollPersonTile({required this.person, required this.onMarkPaid});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final name    = person['name']        as String? ?? '—';
    final role    = (person['role'] as String?) ??
        (person['isHeadCoach'] == true ? 'Head Coach' : 'Coach');
    final salary  = person['salaryPaise'] as int? ?? 0;
    final isPaid  = person['isPaid']      as bool? ?? false;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: isPaid
              ? _C.green.withValues(alpha: 0.1)
              : cs.onSurface.withValues(alpha: 0.07),
          child: Text(initial,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: isPaid ? _C.green : cs.onSurface.withValues(alpha: 0.6),
              )),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: cs.onSurface)),
          Text(role,
              style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5))),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('₹${(salary / 100).toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 4),
          if (isPaid)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _C.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Paid', style: TextStyle(fontSize: 11,
                  color: _C.green, fontWeight: FontWeight.w700)),
            )
          else
            GestureDetector(
              onTap: onMarkPaid,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _C.orange.withValues(alpha: 0.1),
                  border: Border.all(color: _C.orange.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Mark Paid', style: TextStyle(fontSize: 11,
                    color: _C.orange, fontWeight: FontWeight.w700)),
              ),
            ),
        ]),
      ]),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Color _avatarColor(String name) {
  const colors = [
    Color(0xFF2563EB), Color(0xFF7C3AED), Color(0xFF059669),
    Color(0xFFEA580C), Color(0xFF0891B2), Color(0xFF16A34A),
  ];
  return colors[name.codeUnits.fold(0, (a, b) => a + b) % colors.length];
}
