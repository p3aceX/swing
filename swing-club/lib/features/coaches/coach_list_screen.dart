import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets.dart';
import 'coach_provider.dart';
import 'invite_coach_sheet.dart';

class CoachListScreen extends ConsumerWidget {
  const CoachListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(coachesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Coaches')),
      body: state.when(
        loading: loadingBody,
        error: (e, _) => errorBody(e, () => ref.invalidate(coachesProvider)),
        data: (coaches) => coaches.isEmpty
            ? emptyBody('No coaches yet. Invite one!')
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(coachesProvider),
                child: ListView.separated(
                  itemCount: coaches.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, i) => _CoachTile(coach: coaches[i]),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          builder: (_) => const InviteCoachSheet(),
        ),
        child: const Icon(Icons.person_add_outlined),
      ),
    );
  }
}

class _CoachTile extends StatelessWidget {
  final Map<String, dynamic> coach;

  const _CoachTile({required this.coach});

  @override
  Widget build(BuildContext context) {
    final user = coach['user'] as Map<String, dynamic>? ?? {};
    final batches = (coach['batches'] as List? ?? []).cast<Map<String, dynamic>>();
    final batchNames = batches.map((b) => b['name'] as String? ?? '').join(', ');

    return ListTile(
      title: Text(user['name'] as String? ?? '—',
          style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: batchNames.isNotEmpty ? Text(batchNames) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (coach['isHeadCoach'] == true) statusBadge('HEAD COACH'),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        ],
      ),
      onTap: () => context.push('/more/coaches/${coach['id']}'),
    );
  }
}
