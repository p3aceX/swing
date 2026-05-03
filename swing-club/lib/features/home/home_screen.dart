import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import 'home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);

    return Scaffold(
      body: state.when(
        loading: loadingBody,
        error: (e, _) => errorBody(e, () => ref.invalidate(homeProvider)),
        data: (data) => _HomeBody(data: data, onRefresh: () => ref.read(homeProvider.notifier).refresh()),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final HomeData data;
  final Future<void> Function() onRefresh;

  const _HomeBody({required this.data, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final academy = data.academy;
    final stats = academy['stats'] as Map<String, dynamic>? ?? {};

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppTheme.deepBlue,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppTheme.deepBlue,
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      academy['name'] as String? ?? 'My Academy',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          academy['city'] as String? ?? '',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        if (academy['planTier'] != null) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              academy['planTier'] as String,
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatsRow(
                  students: stats['totalStudents'] as int? ?? 0,
                  coaches: stats['totalCoaches'] as int? ?? 0,
                  batches: stats['totalBatches'] as int? ?? 0,
                ),
                const Divider(),
                _SectionHeader(
                  title: "Today's Sessions",
                  trailing: data.todaySessions.isEmpty ? null : '${data.todaySessions.length}',
                ),
                if (data.todaySessions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Text('No sessions today', style: TextStyle(color: Colors.grey)),
                  )
                else
                  ...data.todaySessions.map((s) => _SessionTile(session: s)),
                const Divider(),
                if (data.pendingFeesCount > 0) ...[
                  ListTile(
                    leading: const Icon(Icons.warning_amber_rounded, color: Color(0xFFF57F17)),
                    title: Text(
                      '${data.pendingFeesCount} pending fee payment${data.pendingFeesCount > 1 ? 's' : ''}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: TextButton(
                      onPressed: () => context.go('/fees'),
                      child: const Text('View'),
                    ),
                  ),
                  const Divider(),
                ],
                const _SectionHeader(title: 'Quick Actions'),
                _QuickActions(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int students;
  final int coaches;
  final int batches;

  const _StatsRow({required this.students, required this.coaches, required this.batches});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          _StatTile(value: '$students', label: 'Students'),
          _VerticalDivider(),
          _StatTile(value: '$coaches', label: 'Coaches'),
          _VerticalDivider(),
          _StatTile(value: '$batches', label: 'Batches'),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const SizedBox(width: 1, height: 40, child: VerticalDivider());
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;

  const _StatTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepNavy,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      );
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;

  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          children: [
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            if (trailing != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.deepBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(trailing!,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.deepBlue, fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      );
}

class _SessionTile extends StatelessWidget {
  final Map<String, dynamic> session;

  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final batch = session['batch'] as Map<String, dynamic>? ?? {};
    final coach = session['coach'] as Map<String, dynamic>? ?? {};
    final startTime = session['startTime'] as String? ?? '';
    final status = session['status'] as String? ?? '';

    return Column(
      children: [
        ListTile(
          title: Text(
            batch['name'] as String? ?? session['sessionType'] as String? ?? 'Session',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            '${coach['name'] ?? 'Unassigned'} · $startTime',
            style: const TextStyle(fontSize: 13),
          ),
          trailing: statusBadge(status),
        ),
        const Divider(),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _ActionChip(
            icon: Icons.person_add_outlined,
            label: 'Add Student',
            onTap: () => context.go('/students'),
          ),
          const SizedBox(width: 10),
          _ActionChip(
            icon: Icons.campaign_outlined,
            label: 'Announce',
            onTap: () => context.go('/more/announcements/create'),
          ),
          const SizedBox(width: 10),
          _ActionChip(
            icon: Icons.groups_outlined,
            label: 'Batches',
            onTap: () => context.go('/more/batches'),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Icon(icon, size: 22, color: AppTheme.deepBlue),
                const SizedBox(height: 6),
                Text(label,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
}
