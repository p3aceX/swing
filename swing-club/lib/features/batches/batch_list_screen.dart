import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets.dart';
import 'batch_provider.dart';

class BatchListScreen extends ConsumerWidget {
  const BatchListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(batchesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: state.when(
          loading: loadingBody,
          error: (e, _) => errorBody(e, () => ref.invalidate(batchesProvider)),
          data: (batches) => batches.isEmpty
              ? _EmptyBatches(onAdd: () => context.push('/batches/new'))
              : _BatchList(batches: batches),
        ),
      ),
    );
  }
}

// ─── List ─────────────────────────────────────────────────────────────────────

class _BatchList extends ConsumerWidget {
  final List<Map<String, dynamic>> batches;
  const _BatchList({required this.batches});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final dividerColor = cs.onSurface.withValues(alpha: 0.08);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(batchesProvider),
      color: const Color(0xFF2563EB),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // ── Page header ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Batches',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: cs.onSurface,
                              letterSpacing: -0.5,
                            )),
                        const SizedBox(height: 2),
                        Text('${batches.length} total',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: cs.onSurface.withValues(alpha: 0.45),
                            )),
                      ],
                    ),
                  ),
                  _OutlineBtn(
                    icon: Icons.add_rounded,
                    label: 'Add',
                    onTap: () => context.push('/batches/new'),
                  ),
                ],
              ),
            ),
          ),

          // ── Divider ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, thickness: 0.5,
                  color: dividerColor, indent: 20, endIndent: 20),
            ),
          ),

          // ── Batch items ──────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList.separated(
              itemCount: batches.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _BatchTile(batch: batches[i]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Batch Tile ───────────────────────────────────────────────────────────────

class _BatchTile extends ConsumerWidget {
  final Map<String, dynamic> batch;
  const _BatchTile({required this.batch});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final name = batch['name'] as String? ?? 'Batch';
    final confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Batch'),
        content: Text('Delete "$name"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(batchesProvider.notifier).deleteBatch(batch['id'] as String);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs       = Theme.of(context).colorScheme;
    final name     = batch['name']   as String? ?? 'Batch';
    final ageGroup = batch['ageGroup'] as String?;
    final enrolled = ((batch['_count'] as Map?)?['enrollments'] as num?
            ?? batch['studentCount'] as num? ?? 0)
        .toInt();
    final maxStuds = (batch['maxStudents'] as num? ?? 0).toInt();
    final isActive = batch['isActive'] as bool? ?? true;
    final occFrac  = maxStuds > 0 ? (enrolled / maxStuds).clamp(0.0, 1.0) : 0.0;

    return GestureDetector(
      onTap: () => context.push('/batches/${batch['id']}'),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
        decoration: BoxDecoration(
          border: Border.all(color: cs.onSurface.withValues(alpha: 0.10), width: 1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon box
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: cs.onSurface.withValues(alpha: 0.10), width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.groups_rounded, size: 20,
                      color: cs.onSurface.withValues(alpha: 0.55)),
                ),
                const SizedBox(width: 12),

                // Name + tags
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: Text(name,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                                  color: cs.onSurface)),
                        ),
                        if (!isActive)
                          _Tag(label: 'Inactive',
                              color: cs.onSurface.withValues(alpha: 0.4)),
                      ]),
                      const SizedBox(height: 5),
                      Row(children: [
                        if (ageGroup != null) ...[
                          _Tag(label: ageGroup, color: const Color(0xFFD97706)),
                          const SizedBox(width: 8),
                        ],
                        Icon(Icons.people_outline_rounded, size: 13,
                            color: cs.onSurface.withValues(alpha: 0.4)),
                        const SizedBox(width: 3),
                        Text('$enrolled / $maxStuds',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                                color: cs.onSurface.withValues(alpha: 0.5))),
                      ]),
                    ],
                  ),
                ),

                // Menu
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, size: 18,
                      color: cs.onSurface.withValues(alpha: 0.35)),
                  padding: EdgeInsets.zero,
                  onSelected: (v) {
                    if (v == 'edit') context.push('/batches/${batch['id']}/edit', extra: batch);
                    if (v == 'delete') _confirmDelete(context, ref);
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit',   child: Text('Edit')),
                    const PopupMenuItem(value: 'delete',
                        child: Text('Delete', style: TextStyle(color: Colors.red))),
                  ],
                ),
              ],
            ),

            // Occupancy bar
            if (maxStuds > 0) ...[
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LayoutBuilder(builder: (_, box) => SizedBox(
                  height: 4,
                  child: Stack(children: [
                    Container(width: box.maxWidth, height: 4,
                        color: cs.onSurface.withValues(alpha: 0.07)),
                    Container(width: box.maxWidth * occFrac, height: 4,
                        color: occFrac >= 0.9
                            ? const Color(0xFF16A34A)
                            : const Color(0xFF2563EB).withValues(alpha: 0.7)),
                  ]),
                )),
              ),
              const SizedBox(height: 6),
              Text('${(occFrac * 100).round()}% occupied',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500,
                      color: cs.onSurface.withValues(alpha: 0.4))),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
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
          Text(label,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                  color: cs.onSurface)),
        ]),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyBatches extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyBatches({required this.onAdd});

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
                border: Border.all(color: cs.onSurface.withValues(alpha: 0.12), width: 1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.groups_outlined, size: 24,
                  color: cs.onSurface.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 20),
            Text('No batches yet',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900,
                    color: cs.onSurface, letterSpacing: -0.5)),
            const SizedBox(height: 8),
            Text('Create your first batch to start organising students by group.',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                    color: cs.onSurface.withValues(alpha: 0.5), height: 1.5)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onAdd,
                style: FilledButton.styleFrom(
                  backgroundColor: cs.onSurface,
                  foregroundColor: cs.surface,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Create Batch',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
