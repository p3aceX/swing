import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets.dart';
import 'batch_provider.dart';
import 'batch_form_sheet.dart';

class BatchListScreen extends ConsumerWidget {
  const BatchListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(batchesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Batches')),
      body: state.when(
        loading: loadingBody,
        error: (e, _) => errorBody(e, () => ref.invalidate(batchesProvider)),
        data: (batches) => batches.isEmpty
            ? emptyBody('No batches yet. Create one!')
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(batchesProvider),
                child: ListView.separated(
                  itemCount: batches.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, i) => _BatchTile(batch: batches[i]),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showForm(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => const BatchFormSheet(),
    );
  }
}

class _BatchTile extends StatelessWidget {
  final Map<String, dynamic> batch;

  const _BatchTile({required this.batch});

  @override
  Widget build(BuildContext context) {
    final enrollmentCount = batch['_count']?['enrollments'] ?? batch['studentCount'] ?? 0;
    return ListTile(
      title: Text(
        batch['name'] as String? ?? '',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '${batch['ageGroup'] ?? ''} · $enrollmentCount students'
            .replaceAll(RegExp(r'^ · '), ''),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: () => context.push('/batches/${batch['id']}'),
    );
  }
}
