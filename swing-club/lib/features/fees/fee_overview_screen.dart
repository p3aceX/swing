import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../shared/widgets.dart';
import 'fee_provider.dart';
import 'record_payment_sheet.dart';
import 'fee_structure_sheet.dart';

class FeeOverviewScreen extends ConsumerStatefulWidget {
  const FeeOverviewScreen({super.key});

  @override
  ConsumerState<FeeOverviewScreen> createState() => _FeeOverviewScreenState();
}

class _FeeOverviewScreenState extends ConsumerState<FeeOverviewScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fees'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Payments'),
            Tab(text: 'Pending'),
            Tab(text: 'Structures'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _PaymentsTab(),
          _PendingTab(),
          _StructuresTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          builder: (_) => const RecordPaymentSheet(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PaymentsTab extends ConsumerWidget {
  const _PaymentsTab();

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
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, i) => _PaymentTile(payment: payments[i]),
          ),
        );
      },
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
        final pending = payments
            .where((p) => p['status'] == 'PENDING' || p['feeStatus'] == 'OVERDUE')
            .toList();
        if (pending.isEmpty) return emptyBody('No pending payments');
        return ListView.separated(
          itemCount: pending.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, i) => _PendingTile(payment: pending[i]),
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: state.when(
        loading: loadingBody,
        error: (e, _) => errorBody(e, () => ref.invalidate(feeStructuresProvider)),
        data: (structures) => structures.isEmpty
            ? emptyBody('No fee structures yet')
            : ListView.separated(
                itemCount: structures.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, i) => _StructureTile(structure: structures[i]),
              ),
      ),
      floatingActionButton: FloatingActionButton.small(
        heroTag: null,
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          builder: (_) => const FeeStructureSheet(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final Map<String, dynamic> payment;

  const _PaymentTile({required this.payment});

  @override
  Widget build(BuildContext context) {
    final enrollment = payment['enrollment'] as Map<String, dynamic>? ?? {};
    final user = enrollment['user'] as Map<String, dynamic>? ?? {};
    final amount = rupeesFromPaise(payment['amountPaise']);
    final status = payment['status'] as String? ?? '';

    String dateLabel = '';
    final paidAt = payment['paidAt'] as String?;
    if (paidAt != null) {
      try {
        dateLabel = DateFormat('d MMM yyyy').format(DateTime.parse(paidAt).toLocal());
      } catch (_) {}
    }

    return ListTile(
      title: Text(user['name'] as String? ?? '—',
          style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text('$dateLabel · ${payment['paymentMode'] ?? ''}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(amount, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          statusBadge(status),
        ],
      ),
    );
  }
}

class _PendingTile extends ConsumerWidget {
  final Map<String, dynamic> payment;

  const _PendingTile({required this.payment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrollment = payment['enrollment'] as Map<String, dynamic>? ?? {};
    final user = enrollment['user'] as Map<String, dynamic>? ?? {};
    final amount = rupeesFromPaise(payment['amountPaise'] ?? enrollment['feeAmountPaise']);

    return ListTile(
      title: Text(user['name'] as String? ?? '—',
          style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(amount),
      trailing: TextButton(
        onPressed: () async {
          try {
            await ref.read(paymentsProvider.notifier).sendReminder(payment['id'] as String);
            if (context.mounted) showSnack(context, 'Reminder sent');
          } catch (_) {
            if (context.mounted) showSnack(context, 'Failed to send reminder');
          }
        },
        child: const Text('Remind'),
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
      subtitle: Text('${rupeesFromPaise(structure['amountPaise'])} · ${structure['frequency'] ?? ''}'),
      trailing: batch != null
          ? Text(batch['name'] as String? ?? '',
              style: const TextStyle(color: Colors.grey, fontSize: 12))
          : null,
    );
  }
}
