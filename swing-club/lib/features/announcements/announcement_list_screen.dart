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
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, i) => _AnnouncementTile(item: list[i]),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/more/announcements/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AnnouncementTile extends StatelessWidget {
  final Map<String, dynamic> item;

  const _AnnouncementTile({required this.item});

  @override
  Widget build(BuildContext context) {
    String dateLabel = '';
    final createdAt = item['createdAt'] as String?;
    if (createdAt != null) {
      try {
        dateLabel = DateFormat('d MMM yyyy').format(DateTime.parse(createdAt).toLocal());
      } catch (_) {}
    }

    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: Text(item['title'] as String? ?? '—',
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          if (item['isPinned'] == true)
            const Icon(Icons.push_pin_outlined, size: 16, color: Colors.grey),
        ],
      ),
      subtitle: Text(dateLabel, style: const TextStyle(fontSize: 12)),
    );
  }
}
