import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../shared/widgets.dart';
import 'announcement_provider.dart';

class AnnouncementListScreen extends ConsumerWidget {
  const AnnouncementListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(announcementsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: state.when(
        loading: loadingBody,
        error: (e, _) => errorBody(e, () => ref.invalidate(announcementsProvider)),
        data: (list) => list.isEmpty
            ? emptyBody('No announcements yet')
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(announcementsProvider),
                child: ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) => _AnnouncementTile(item: list[i]),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/announcements/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AnnouncementTile extends ConsumerWidget {
  final Map<String, dynamic> item;

  const _AnnouncementTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = item['id'] as String;
    final isPinned = item['isPinned'] as bool? ?? false;

    String dateLabel = '';
    final createdAt = item['createdAt'] as String?;
    if (createdAt != null) {
      try {
        dateLabel = DateFormat('d MMM yyyy').format(DateTime.parse(createdAt).toLocal());
      } catch (_) {}
    }

    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Announcement'),
            content: Text('Delete "${item['title'] ?? 'this announcement'}"?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) {
        ref.read(announcementsProvider.notifier).remove(id);
      },
      child: ListTile(
        title: Text(item['title'] as String? ?? '—',
            style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(dateLabel, style: const TextStyle(fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                size: 18,
                color: isPinned ? Theme.of(context).colorScheme.primary : Colors.grey,
              ),
              onPressed: () {
                ref.read(announcementsProvider.notifier).edit(id, {'isPinned': !isPinned});
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              onPressed: () => context.push('/announcements/create', extra: item),
            ),
          ],
        ),
      ),
    );
  }
}
