import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
            : _HomeBody(data: data, onRefresh: () => ref.read(homeProvider.notifier).refresh()),
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
            const Text('Set up your Academy',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF071B3D))),
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

// ── Main body ─────────────────────────────────────────────────────────────────

class _HomeBody extends StatelessWidget {
  final HomeData data;
  final Future<void> Function() onRefresh;
  const _HomeBody({required this.data, required this.onRefresh});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final academy = data.academy;
    final stats   = academy['stats'] as Map<String, dynamic>? ?? {};
    final students = stats['totalStudents'] as int? ?? 0;
    final coaches  = stats['totalCoaches']  as int? ?? 0;
    final batches  = stats['totalBatches']  as int? ?? 0;
    final city     = academy['city']        as String? ?? '';
    final today    = DateFormat('EEEE, d MMM').format(DateTime.now());

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildGreeting(today, city)),
          SliverToBoxAdapter(child: _buildStats(students, coaches, batches)),
          if (data.pendingFeesCount > 0)
            SliverToBoxAdapter(child: _buildFeesBanner(context)),
          SliverToBoxAdapter(child: _buildSectionTitle("Today's Sessions", data.todaySessions.length)),
          if (data.todaySessions.isEmpty)
            const SliverToBoxAdapter(child: _EmptySessionsCard())
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _SessionCard(session: data.todaySessions[i]),
                childCount: data.todaySessions.length,
              ),
            ),
          SliverToBoxAdapter(child: _buildSectionTitle('Quick Actions', 0)),
          SliverToBoxAdapter(child: _buildQuickActions(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildGreeting(String today, String city) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _greeting(),
            style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 13, color: Colors.grey),
              const SizedBox(width: 5),
              Text(today, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
              if (city.isNotEmpty) ...[
                const SizedBox(width: 10),
                const Icon(Icons.location_on_outlined, size: 13, color: Colors.grey),
                const SizedBox(width: 3),
                Text(city, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats(int students, int coaches, int batches) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          _StatTile(value: students, label: 'Students', icon: Icons.people_rounded,         color: const Color(0xFF0057C8)),
          const SizedBox(width: 10),
          _StatTile(value: coaches,  label: 'Coaches',  icon: Icons.sports_cricket_rounded,  color: const Color(0xFF1B8A5A)),
          const SizedBox(width: 10),
          _StatTile(value: batches,  label: 'Batches',  icon: Icons.groups_rounded,          color: const Color(0xFFD97706)),
        ],
      ),
    );
  }

  Widget _buildFeesBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GestureDetector(
        onTap: () => context.go('/more/fees'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3CD),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFFD600).withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFF57F17), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${data.pendingFeesCount} pending fee payment${data.pendingFeesCount > 1 ? 's' : ''}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF7A4F00)),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF7A4F00), size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF071B3D), letterSpacing: -0.3)),
          ),
          if (count > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF0057C8).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('$count',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF0057C8), fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.4,
        children: [
          _ActionTile(icon: Icons.person_add_rounded,   label: 'Add Student',  color: const Color(0xFF0057C8), onTap: () => context.go('/students')),
          _ActionTile(icon: Icons.groups_rounded,        label: 'Batches',      color: const Color(0xFFD97706), onTap: () => context.go('/more/batches')),
          _ActionTile(icon: Icons.campaign_rounded,      label: 'Announcement', color: const Color(0xFF7C3AED), onTap: () => context.go('/more/announcements/create')),
          _ActionTile(icon: Icons.payments_outlined,     label: 'Fees',         color: const Color(0xFF1B8A5A), onTap: () => context.go('/more/fees')),
        ],
      ),
    );
  }
}

// ── Stat tile ─────────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  final int value;
  final String label;
  final IconData icon;
  final Color color;
  const _StatTile({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 10),
              Text(
                '$value',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: color, letterSpacing: -0.5),
              ),
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
}

// ── Session card ──────────────────────────────────────────────────────────────

class _SessionCard extends StatelessWidget {
  final Map<String, dynamic> session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final batch     = session['batch']  as Map<String, dynamic>? ?? {};
    final coach     = (session['coach'] as Map?)?.cast<String, dynamic>() ?? {};
    final coachUser = (coach['user']    as Map?)?.cast<String, dynamic>() ?? {};
    final rawTime   = session['scheduledAt'] as String? ?? session['startTime'] as String? ?? '';
    final status    = session['status'] as String? ?? '';

    String timeLabel = '';
    if (rawTime.isNotEmpty) {
      try { timeLabel = DateFormat('h:mm a').format(DateTime.parse(rawTime)); } catch (_) {}
    }

    final coachName = coachUser['name'] as String? ?? coach['name'] as String? ?? 'Unassigned';
    final batchName = batch['name'] as String? ?? session['sessionType'] as String? ?? 'Session';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF0057C8).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.sports_cricket_rounded, size: 22, color: Color(0xFF0057C8)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(batchName,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF071B3D))),
                  const SizedBox(height: 3),
                  Text('$coachName · $timeLabel',
                      style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
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

// ── Empty sessions ────────────────────────────────────────────────────────────

class _EmptySessionsCard extends StatelessWidget {
  const _EmptySessionsCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0057C8).withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.event_available_outlined, size: 20, color: Color(0xFF0057C8)),
            ),
            const SizedBox(width: 14),
            const Text('No sessions scheduled for today',
                style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ── Quick action tile ─────────────────────────────────────────────────────────

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF071B3D))),
            ],
          ),
        ),
      );
}
