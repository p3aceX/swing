import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/academy_provider.dart';
import '../../shared/widgets.dart';
import 'fee_provider.dart';
import 'fee_structure_sheet.dart';
import 'add_expense_sheet.dart';
import 'finance_add_sheet.dart';

class FeeOverviewScreen extends ConsumerStatefulWidget {
  const FeeOverviewScreen({super.key});

  @override
  ConsumerState<FeeOverviewScreen> createState() => _FeeOverviewScreenState();
}

class _FeeOverviewScreenState extends ConsumerState<FeeOverviewScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 4, vsync: this);

  @override
  void initState() {
    super.initState();
    _tabs.addListener(_onTabChange);
  }

  void _onTabChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabs.removeListener(_onTabChange);
    _tabs.dispose();
    super.dispose();
  }

  void _showFinanceAddSheet() => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (_) => const FinanceAddSheet(),
      );

  void _showFeeStructureSheet() => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (_) => const FeeStructureSheet(),
      );


  @override
  Widget build(BuildContext context) {
    final summaryState = ref.watch(financeSummaryProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _FinanceSummaryStrip(summaryState: summaryState),
            TabBar(
              controller: _tabs,
              tabs: const [
                Tab(text: 'Fees'),
                Tab(text: 'Pending'),
                Tab(text: 'Expenses'),
                Tab(text: 'Structures'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: const [
                  _FeesTab(),
                  _PendingTab(),
                  _ExpensesTab(),
                  _StructuresTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _tabs.index == 1
          ? null
          : FloatingActionButton.extended(
              heroTag: 'finance_fab',
              onPressed: () {
                if (_tabs.index == 3) {
                  _showFeeStructureSheet();
                } else {
                  _showFinanceAddSheet();
                }
              },
              icon: const Icon(Icons.add),
              label: Text(_tabs.index == 3 ? 'Add Structure' : 'Add'),
            ),
    );
  }
}

class _FinanceSummaryStrip extends ConsumerWidget {
  final AsyncValue<Map<String, dynamic>> summaryState;

  const _FinanceSummaryStrip({required this.summaryState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = DateFormat('MMMM yyyy').format(DateTime.now());

    return summaryState.when(
      loading: () => const SizedBox(
        height: 88,
        child: Center(child: SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2))),
      ),
      error: (_, _) => const SizedBox(
        height: 88,
        child: Center(child: Text('—', style: TextStyle(color: Colors.grey))),
      ),
      data: (summary) {
        final revenue  = (summary['revenuePaise']  as num? ?? 0).toInt();
        final expenses = (summary['expensesPaise'] as num? ?? 0).toInt();
        final net      = (summary['netPaise']      as num? ?? 0).toInt();
        final netPos   = net >= 0;
        final collRate = revenue > 0
            ? (revenue / (revenue + expenses)).clamp(0.0, 1.0)
            : 0.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
              child: Row(
                children: [
                  Text('Finance',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.onSurface)),
                  const Spacer(),
                  Text(month,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      ref.invalidate(financeSummaryProvider);
                      ref.invalidate(expensesProvider);
                      ref.invalidate(paymentsProvider);
                    },
                    child: Icon(Icons.refresh_rounded, size: 16,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            IntrinsicHeight(
              child: Row(
                children: [
                  _SummaryCell(
                    label: 'Revenue',
                    value: rupeesFromPaise(revenue),
                    accent: const Color(0xFF2E7D32),
                    bg: const Color(0xFFE8F5E9),
                  ),
                  const VerticalDivider(width: 1, thickness: 1),
                  _SummaryCell(
                    label: 'Expenses',
                    value: rupeesFromPaise(expenses),
                    accent: const Color(0xFFC62828),
                    bg: const Color(0xFFFFEBEE),
                  ),
                  const VerticalDivider(width: 1, thickness: 1),
                  _SummaryCell(
                    label: 'Net P&L',
                    value: '${netPos ? '+' : ''}${rupeesFromPaise(net)}',
                    accent: netPos ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    bg: netPos
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFEBEE),
                  ),
                ],
              ),
            ),
            // Collection progress bar
            LinearProgressIndicator(
              value: collRate,
              minHeight: 3,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: AlwaysStoppedAnimation(
                  netPos ? const Color(0xFF43A047) : const Color(0xFFEF5350)),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCell extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final Color bg;

  const _SummaryCell({
    required this.label,
    required this.value,
    required this.accent,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: bg,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 3),
            Text(value,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: accent,
                    letterSpacing: -0.3)),
          ],
        ),
      ),
    );
  }
}

class _FeesTab extends ConsumerWidget {
  const _FeesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            separatorBuilder: (_, _) => const Divider(height: 1),
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
    final name    = payment['studentName'] as String? ?? '—';
    final batch   = payment['batchName']   as String? ?? '';
    final status  = payment['status']      as String? ?? '';
    final amount  = rupeesFromPaise(payment['amount']);
    final history = (payment['history'] as List? ?? []).cast<Map>();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    String dateLabel = '';
    if (history.isNotEmpty) {
      final d = history.first['date'] as String?;
      if (d != null) {
        try { dateLabel = DateFormat('d MMM').format(DateTime.parse(d).toLocal()); } catch (_) {}
      }
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: const Color(0xFF2E63D9).withValues(alpha: 0.1),
        child: Text(initial, style: const TextStyle(
            color: Color(0xFF2E63D9), fontWeight: FontWeight.w800, fontSize: 15)),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      subtitle: Text(
        [if (batch.isNotEmpty) batch, if (dateLabel.isNotEmpty) dateLabel].join('  ·  '),
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(amount, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 3),
          statusBadge(status),
        ],
      ),
    );
  }
}

class _PendingTab extends ConsumerWidget {
  const _PendingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentsProvider);
    return state.when(
      loading: loadingBody,
      error: (e, _) => errorBody(e, () => ref.invalidate(paymentsProvider)),
      data: (payments) {
        final pending = payments.where((e) => e['status'] != 'PAID').toList();
        if (pending.isEmpty) return emptyBody('No pending payments');
        return ListView.separated(
          itemCount: pending.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, i) => _PendingTile(enrollment: pending[i]),
        );
      },
    );
  }
}

class _PendingTile extends ConsumerWidget {
  final Map<String, dynamic> enrollment;

  const _PendingTile({required this.enrollment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentName = enrollment['studentName'] as String? ?? '—';
    final batchName = enrollment['batchName'] as String? ?? '';
    final amount = rupeesFromPaise(enrollment['amount']);
    final status = enrollment['status'] as String? ?? '';
    final phone = (enrollment['studentPhone'] as String? ?? '').replaceAll('+', '').replaceAll(' ', '');

    final initial = studentName.isNotEmpty ? studentName[0].toUpperCase() : '?';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: const Color(0xFFC62828).withValues(alpha: 0.1),
        child: Text(initial, style: const TextStyle(
            color: Color(0xFFC62828), fontWeight: FontWeight.w800, fontSize: 15)),
      ),
      title: Text(studentName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      subtitle: Row(
        children: [
          if (batchName.isNotEmpty) Text(batchName, style: const TextStyle(fontSize: 12)),
          if (batchName.isNotEmpty) const SizedBox(width: 6),
          Text(amount, style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFC62828))),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          statusBadge(status),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.chat_outlined, color: Color(0xFF25D366)),
            onPressed: () async {
              if (phone.isEmpty) {
                showSnack(context, 'No phone number on file');
                return;
              }
              final academyAsync = ref.read(academyProvider);
              final academyName = academyAsync.maybeWhen(
                data: (s) => s.data['name'] as String? ?? 'your academy',
                orElse: () => 'your academy',
              );
              final msg =
                  'Hi $studentName, this is a friendly reminder for your fee payment of $amount at $academyName. Batch: $batchName. Please clear your dues at the earliest. Thank you!';
              final uri = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(msg)}');
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              final paymentId = enrollment['latestPaymentId'] as String?;
              if (paymentId != null) {
                try {
                  await ref.read(paymentsProvider.notifier).sendReminder(paymentId);
                } catch (_) {}
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ExpensesTab extends ConsumerWidget {
  const _ExpensesTab();

  static const _categoryIcons = <String, (IconData, Color)>{
    'SALARY': (Icons.person_outline_rounded, Color(0xFFDD925A)),
    'EQUIPMENT': (Icons.sports_cricket_outlined, Color(0xFF2E63D9)),
    'MAINTENANCE': (Icons.build_outlined, Color(0xFF795548)),
    'INFRASTRUCTURE': (Icons.domain_outlined, Color(0xFF43A047)),
    'MARKETING': (Icons.campaign_outlined, Color(0xFF6F63C7)),
    'UTILITIES': (Icons.bolt_outlined, Color(0xFF00897B)),
    'OTHER': (Icons.receipt_long_outlined, Color(0xFF9E9E9E)),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expensesProvider);
    return state.when(
      loading: loadingBody,
      error: (e, _) => errorBody(e, () => ref.invalidate(expensesProvider)),
      data: (expenses) {
        if (expenses.isEmpty) return emptyBody('No expenses yet — tap + to add one');
        return ListView.separated(
          itemCount: expenses.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final expense = expenses[i];
            final id = expense['id'] as String;
            final category = expense['category'] as String? ?? 'OTHER';
            final iconData = _categoryIcons[category] ?? _categoryIcons['OTHER']!;

            return Dismissible(
              key: ValueKey(id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete_outline, color: Colors.white),
              ),
              onDismissed: (_) {
                ref.read(expensesProvider.notifier).remove(id);
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: iconData.$2.withValues(alpha: 0.15),
                  child: Icon(iconData.$1, color: iconData.$2, size: 20),
                ),
                title: Text(expense['description'] as String? ?? '—',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(
                  [
                    category,
                    if ((expense['payee'] as String?)?.isNotEmpty == true) expense['payee'] as String,
                  ].join(' · '),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      rupeesFromPaise(expense['amountPaise']),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFC62828)),
                    ),
                    if ((expense['date'] as String?) != null)
                      Text(
                        () {
                          try {
                            return DateFormat('d MMM yyyy')
                                .format(DateTime.parse(expense['date'] as String).toLocal());
                          } catch (_) {
                            return '';
                          }
                        }(),
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                  ],
                ),
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                  builder: (_) => AddExpenseSheet(existing: expense),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _StructuresTab extends ConsumerWidget {
  const _StructuresTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feeStructuresProvider);
    return state.when(
      loading: loadingBody,
      error: (e, _) => errorBody(e, () => ref.invalidate(feeStructuresProvider)),
      data: (structures) => structures.isEmpty
          ? emptyBody('No fee structures yet')
          : ListView.separated(
              itemCount: structures.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
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
    final batch = structure['batch'] as Map<String, dynamic>?;
    return ListTile(
      title: Text(structure['name'] as String? ?? '—',
          style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
          '${rupeesFromPaise(structure['amountPaise'])} · ${structure['frequency'] ?? ''}'),
      trailing: batch != null
          ? Text(batch['name'] as String? ?? '',
              style: const TextStyle(color: Colors.grey, fontSize: 12))
          : null,
    );
  }
}
