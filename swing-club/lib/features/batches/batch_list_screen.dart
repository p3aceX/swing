import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets.dart';
import 'batch_provider.dart';

const _kNavy  = Color(0xFF071B3D);
const _kIvory = Color(0xFFF4F2EB);

class BatchListScreen extends ConsumerWidget {
  const BatchListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(batchesProvider);

    return Scaffold(
      backgroundColor: _kIvory,
      body: state.when(
        loading: loadingBody,
        error: (e, _) => errorBody(e, () => ref.invalidate(batchesProvider)),
        data: (batches) => batches.isEmpty
            ? _EmptyBatches(onAdd: () => context.push('/batches/new'))
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(batchesProvider),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  itemCount: batches.length,
                  itemBuilder: (_, i) => _BatchCard(batch: batches[i]),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _kNavy,
        onPressed: () => context.push('/batches/new'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _BatchCard extends StatelessWidget {
  final Map<String, dynamic> batch;
  const _BatchCard({required this.batch});

  @override
  Widget build(BuildContext context) {
    final name     = batch['name']   as String? ?? 'Batch';
    final ageGroup = batch['ageGroup'] as String?;
    final enrolled = batch['_count']?['enrollments'] ?? batch['studentCount'] ?? 0;
    final maxStuds = batch['maxStudents'] as int? ?? 0;
    final isActive = batch['isActive'] as bool? ?? true;

    return GestureDetector(
      onTap: () => context.push('/batches/${batch['id']}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF0057C8).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.groups_rounded, size: 22, color: Color(0xFF0057C8)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15, color: _kNavy)),
                      ),
                      if (!isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Inactive',
                              style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      if (ageGroup != null) ...[
                        _Chip(label: ageGroup, color: const Color(0xFFD97706)),
                        const SizedBox(width: 8),
                      ],
                      Icon(Icons.people_outline_rounded,
                          size: 13, color: Colors.grey.shade500),
                      const SizedBox(width: 3),
                      Text('$enrolled / $maxStuds',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
    );
  }
}

class _EmptyBatches extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyBatches({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.groups_outlined, size: 40, color: Color(0xFF0057C8)),
            const SizedBox(height: 16),
            const Text('No batches yet',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _kNavy)),
            const SizedBox(height: 8),
            const Text('Create your first batch to start organising students by group.',
                style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500, height: 1.5)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create Batch'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
