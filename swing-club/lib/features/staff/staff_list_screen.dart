import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets.dart';
import 'staff_provider.dart';
import 'add_staff_sheet.dart';

class StaffListScreen extends ConsumerWidget {
  const StaffListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(staffProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('Staff', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
      ),
      body: state.when(
        loading: loadingBody,
        error: (e, _) => errorBody(e, () => ref.invalidate(staffProvider)),
        data: (list) => list.isEmpty
            ? _empty(context)
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(staffProvider),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _StaffCard(staff: list[i]),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => const AddStaffSheet(),
        ),
        child: const Icon(Icons.person_add_outlined, color: Colors.white),
      ),
    );
  }

  Widget _empty(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.badge_outlined, size: 40, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          const Text('No staff yet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Add groundsmen, water boys, admin staff and track their salaries.',
              style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5)),
        ],
      ),
    ),
  );
}

class _StaffCard extends ConsumerWidget {
  final Map<String, dynamic> staff;
  const _StaffCard({required this.staff});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name   = staff['name']   as String? ?? '—';
    final role   = staff['role']   as String? ?? '';
    final phone  = staff['phone']  as String? ?? '';
    final salary = staff['salaryPaise'] as int?;
    final mode   = staff['paymentMode'] as String? ?? 'CASH';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: cs.primary.withValues(alpha: 0.1),
            child: Text(initial,
                style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: cs.onSurface)),
                const SizedBox(height: 3),
                Row(children: [
                  _tag(role, cs.primary),
                  const SizedBox(width: 8),
                  _tag(mode.replaceAll('_', ' '), Colors.grey.shade600),
                ]),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(phone, style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5))),
                ],
              ],
            ),
          ),
          if (salary != null)
            Text('₹${(salary / 100).toStringAsFixed(0)}/mo',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.green)),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 20, color: cs.onSurface.withValues(alpha: 0.4)),
            onSelected: (v) async {
              if (v == 'edit') {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (_) => AddStaffSheet(existing: staff),
                );
              } else if (v == 'remove') {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Remove Staff'),
                    content: Text('Remove $name from staff?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Remove', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (ok == true) {
                  await ref.read(staffProvider.notifier).remove(staff['id'] as String);
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit',   child: Text('Edit')),
              PopupMenuItem(value: 'remove', child: Text('Remove', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
  );
}
