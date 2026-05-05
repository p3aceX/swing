import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets.dart';
import 'coach_provider.dart';
import 'invite_coach_sheet.dart';

const _kNavy = Color(0xFF071B3D);
const _kBlue = Color(0xFF0057C8);

class CoachListScreen extends ConsumerWidget {
  const CoachListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(coachesProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('Coaches', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
      ),
      body: state.when(
        loading: loadingBody,
        error: (e, _) => errorBody(e, () => ref.invalidate(coachesProvider)),
        data: (coaches) {
          final active = coaches.where((c) => c['isActive'] != false).toList();
          return active.isEmpty
              ? _empty(context)
              : RefreshIndicator(
                  onRefresh: () async => ref.invalidate(coachesProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    itemCount: active.length,
                    itemBuilder: (_, i) => _CoachCard(coach: active[i]),
                  ),
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        backgroundColor: _kNavy,
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => const InviteCoachSheet(),
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
          const Icon(Icons.sports_cricket_outlined, size: 40, color: _kBlue),
          const SizedBox(height: 16),
          const Text('No coaches yet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _kNavy)),
          const SizedBox(height: 8),
          const Text('Add coaches to manage their roles and salary.',
              style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5)),
        ],
      ),
    ),
  );
}

class _CoachCard extends ConsumerWidget {
  final Map<String, dynamic> coach;
  const _CoachCard({required this.coach});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user   = (coach['user'] as Map?)?.cast<String, dynamic>() ?? {};
    final name   = user['name'] as String? ?? '—';
    final phone  = user['phone'] as String? ?? '';
    final role   = coach['role'] as String? ?? (coach['isHeadCoach'] == true ? 'Head Coach' : 'Coach');
    final salary = coach['salaryPaise'] as int?;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => context.push('/coaches/${coach['id']}'),
      child: Container(
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
              backgroundColor: const Color(0xFF0057C8).withValues(alpha: 0.1),
              child: Text(initial,
                  style: const TextStyle(color: _kBlue, fontWeight: FontWeight.w700, fontSize: 16)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: cs.onSurface)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      _tag(role, const Color(0xFF0057C8)),
                      if (salary != null) ...[
                        const SizedBox(width: 8),
                        _tag('₹${(salary / 100).toStringAsFixed(0)}/mo', Colors.green.shade700),
                      ],
                    ],
                  ),
                  if (phone.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(phone,
                        style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5))),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: cs.onSurface.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }

  Widget _tag(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
  );
}
