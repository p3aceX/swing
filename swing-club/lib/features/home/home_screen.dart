import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
        data: (data) => data.hasNoAcademy
            ? const _NoAcademyBody()
            : _HomeBody(
                data: data,
                onRefresh: () => ref.read(homeProvider.notifier).refresh(),
              ),
      ),
    );
  }
}

// ── No Academy ────────────────────────────────────────────────────────────────

class _NoAcademyBody extends StatelessWidget {
  const _NoAcademyBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.school_outlined, size: 40, color: Color(0xFF0057C8)),
            const SizedBox(height: 16),
            const Text(
              'Set up your Academy',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF071B3D)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your academy to start managing students, batches, coaches, and sessions.',
              style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/academy-setup'),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create Academy'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Main home body ────────────────────────────────────────────────────────────

class _HomeBody extends StatelessWidget {
  final HomeData data;
  final Future<void> Function() onRefresh;

  const _HomeBody({required this.data, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final academy = data.academy;
    final stats   = academy['stats'] as Map<String, dynamic>? ?? {};

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatsRow(
                  students: stats['totalStudents'] as int? ?? 0,
                  coaches:  stats['totalCoaches']  as int? ?? 0,
                  batches:  stats['totalBatches']  as int? ?? 0,
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
                      onPressed: () => context.go('/more/fees'),
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

// ── Stats ─────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final int students, coaches, batches;
  const _StatsRow({required this.students, required this.coaches, required this.batches});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
        child: Row(
          children: [
            _StatCard(value: '$students', label: 'Students', icon: Icons.people_rounded,        color: const Color(0xFF0057C8)),
            const SizedBox(width: 12),
            _StatCard(value: '$coaches',  label: 'Coaches',  icon: Icons.sports_cricket_rounded, color: const Color(0xFF1B8A5A)),
            const SizedBox(width: 12),
            _StatCard(value: '$batches',  label: 'Batches',  icon: Icons.groups_rounded,         color: const Color(0xFFD97706)),
          ],
        ),
      );
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;

  const _StatCard({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0DED6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w900,
                  color: Color(0xFF071B3D), letterSpacing: -0.5,
                ),
              ),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;
  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w800,
                  color: Color(0xFF071B3D), letterSpacing: -0.3,
                ),
              ),
            ),
            if (trailing != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF0057C8).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  trailing!,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF0057C8), fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
      );
}

// ── Session tile ──────────────────────────────────────────────────────────────

class _SessionTile extends StatelessWidget {
  final Map<String, dynamic> session;
  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final batch  = session['batch'] as Map<String, dynamic>? ?? {};
    final coach  = (session['coach'] as Map?)?.cast<String, dynamic>() ?? {};
    final coachUser = (coach['user'] as Map?)?.cast<String, dynamic>() ?? {};
    final time   = session['scheduledAt'] as String? ?? session['startTime'] as String? ?? '';
    final status = session['status'] as String? ?? '';

    final timeLabel = time.isNotEmpty
        ? TimeOfDay.fromDateTime(DateTime.parse(time)).format(context)
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0DED6)),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF0057C8).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.sports_cricket_rounded, size: 20, color: Color(0xFF0057C8)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    batch['name'] as String? ?? session['sessionType'] as String? ?? 'Session',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF071B3D)),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${coachUser['name'] ?? coach['name'] ?? 'Unassigned'} · $timeLabel',
                    style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            statusBadge(status),
          ],
        ),
      ),
    );
  }
}

// ── Quick actions ─────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Row(
          children: [
            _ActionChip(
              icon: Icons.person_add_rounded, label: 'Add Student',
              color: const Color(0xFF0057C8), onTap: () => context.go('/students'),
            ),
            const SizedBox(width: 12),
            _ActionChip(
              icon: Icons.campaign_rounded, label: 'Announce',
              color: const Color(0xFF7C3AED), onTap: () => context.go('/more/announcements/create'),
            ),
            const SizedBox(width: 12),
            _ActionChip(
              icon: Icons.groups_rounded, label: 'Batches',
              color: const Color(0xFFD97706), onTap: () => context.go('/more/batches'),
            ),
          ],
        ),
      );
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0DED6)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF071B3D)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
}
