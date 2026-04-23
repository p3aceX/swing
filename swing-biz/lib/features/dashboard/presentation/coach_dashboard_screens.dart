import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/router/app_router.dart';
import '../data/coach_dashboard_data.dart';

const _coachBg = Color(0xFF121212);
const _coachCard = Color(0xFF1E1E1E);
const _coachRed = Color(0xFF8B0000);
const _coachText = Color(0xFFFFFFFF);
const _coachMuted = Color(0xFFBDBDBD);

class CoachHomeScreen extends ConsumerWidget {
  const CoachHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: _coachBg,
      appBar: AppBar(
        backgroundColor: _coachBg,
        foregroundColor: _coachText,
        title: const Text('Coach Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () =>
                ref.read(sessionControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        children: const [
          _CoachProfileCard(),
          SizedBox(height: 16),
          _CoachDashboardCards(),
          SizedBox(height: 22),
          _SectionLabel('Upcoming Sessions'),
          SizedBox(height: 10),
          _UpcomingSessionBanners(),
        ],
      ),
      bottomNavigationBar: const _CoachBottomNav(currentIndex: 0),
    );
  }
}

class CoachProfilePlanScreen extends StatelessWidget {
  const CoachProfilePlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _CoachScaffold(
      title: 'Profile & Plan',
      currentIndex: 4,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _CoachProfileCard(compact: false),
          const SizedBox(height: 16),
          _DarkCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionLabel('Personal Details'),
                const SizedBox(height: 12),
                const _InfoRow('Name', coachName),
                const _InfoRow('Academy', coachAcademy),
                const _InfoRow('Phone', '+91 98765 43210'),
                const _InfoRow('Role', 'Head Coach'),
                const SizedBox(height: 16),
                const _SectionLabel('Selected Plan'),
                const SizedBox(height: 12),
                const _PlanBadge(plan: coachPlan),
                if (coachPlan == 'FREE') ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _coachRed,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.payment_rounded),
                    label: const Text('Upgrade to Pro'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CoachTodaySessionsScreen extends StatelessWidget {
  const CoachTodaySessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = coachSessions.take(2).toList();
    return _CoachScaffold(
      title: "Today's Sessions",
      currentIndex: 1,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: today.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final session = today[index];
          return _SessionListTile(session: session);
        },
      ),
    );
  }
}

class CoachStudentsScreen extends StatelessWidget {
  const CoachStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _CoachScaffold(
      title: 'My Students',
      currentIndex: 2,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            style: const TextStyle(color: _coachText),
            decoration: InputDecoration(
              hintText: 'Search students',
              hintStyle: const TextStyle(color: _coachMuted),
              prefixIcon: const Icon(Icons.search_rounded, color: _coachMuted),
              filled: true,
              fillColor: _coachCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            children: [
              _FilterChip(label: 'All'),
              _FilterChip(label: 'Beginner'),
              _FilterChip(label: 'Advanced'),
            ],
          ),
          const SizedBox(height: 16),
          ...coachStudents.map(
            (student) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _DarkCard(
                child: Row(
                  children: [
                    const _SoftCircleIcon(Icons.person_rounded),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.name,
                            style: const TextStyle(
                              color: _coachText,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${student.ageGroup} | ${student.skillLevel}',
                            style: const TextStyle(color: _coachMuted),
                          ),
                          Text(
                            student.assignedSession,
                            style: const TextStyle(color: _coachMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CoachEarningsScreen extends StatelessWidget {
  const CoachEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _CoachScaffold(
      title: 'Earnings',
      currentIndex: 3,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DarkCard(
            child: Column(
              children: [
                const _InfoRow('Salary', 'Rs 48.0k'),
                const _InfoRow('Gigs', 'Rs 8.5k'),
                const _InfoRow('1-on-1 sessions', 'Rs 12.0k'),
                const _InfoRow('Bonus', 'Rs 4.0k'),
                const Divider(color: Color(0xFF333333)),
                _InfoRow(
                  'Total earnings',
                  coachMoney(coachEarnings.total),
                  highlight: true,
                ),
                _InfoRow('Payout status', coachEarnings.payoutStatus),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CoachSessionDetailsScreen extends StatelessWidget {
  const CoachSessionDetailsScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    final session = coachSessions.firstWhere(
      (item) => item.id == sessionId,
      orElse: () => coachSessions.first,
    );
    return _CoachScaffold(
      title: 'Session Details',
      currentIndex: 1,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DarkCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _SoftCircleIcon(session.icon),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        session.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: _coachText,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _InfoRow('Type', session.type),
                _InfoRow('Date & time', session.dateTime),
                _InfoRow('Location', session.location),
                _InfoRow('Format', session.format),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _SectionLabel('Students'),
          const SizedBox(height: 10),
          ...session.students.map(
            (student) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _DarkCard(
                child: Row(
                  children: [
                    const Icon(Icons.person_rounded, color: _coachMuted),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        student,
                        style: const TextStyle(color: _coachText),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const _SectionLabel('Session Plan'),
          const SizedBox(height: 10),
          _DarkCard(
            child: Text(
              session.notes,
              style: const TextStyle(color: _coachMuted, height: 1.45),
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _coachRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () {},
            icon: const Icon(Icons.fact_check_rounded),
            label: const Text('Mark Attendance'),
          ),
        ],
      ),
    );
  }
}

class _CoachDashboardCards extends StatelessWidget {
  const _CoachDashboardCards();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.08,
      children: [
        _DashboardCard(
          title: "Today's Sessions",
          value: '2',
          icon: Icons.event_available_rounded,
          onTap: () => context.push(AppRoutes.coachSessions),
        ),
        _DashboardCard(
          title: 'My Students',
          value: '${coachStudents.length}',
          icon: Icons.groups_rounded,
          onTap: () => context.push(AppRoutes.coachStudents),
        ),
        _DashboardCard(
          title: 'This Month Earnings',
          value: coachMoney(coachEarnings.total),
          icon: Icons.payments_rounded,
          onTap: () => context.push(AppRoutes.coachEarnings),
        ),
        _DashboardCard(
          title: 'Plan',
          value: coachPlan,
          icon: Icons.workspace_premium_rounded,
          onTap: () => context.push(AppRoutes.coachProfile),
        ),
      ],
    );
  }
}

class _CoachProfileCard extends StatelessWidget {
  const _CoachProfileCard({this.compact = true});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return _DarkCard(
      onTap: () => context.push(AppRoutes.coachProfile),
      child: Row(
        children: [
          CircleAvatar(
            radius: compact ? 26 : 34,
            backgroundColor: _coachRed,
            child: const Text(
              'RM',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coachName,
                  style: TextStyle(
                    color: _coachText,
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
                SizedBox(height: 3),
                Text(coachAcademy, style: TextStyle(color: _coachMuted)),
              ],
            ),
          ),
          const _PlanBadge(plan: coachPlan),
        ],
      ),
    );
  }
}

class _UpcomingSessionBanners extends StatelessWidget {
  const _UpcomingSessionBanners();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 154,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: coachSessions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final session = coachSessions[index];
          return SizedBox(
            width: 270,
            child: _DarkCard(
              onTap: () =>
                  context.push('${AppRoutes.coachSessions}/${session.id}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _SoftCircleIcon(session.icon),
                      const Spacer(),
                      Text(
                        session.type,
                        style: const TextStyle(
                          color: _coachMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    session.name,
                    style: const TextStyle(
                      color: _coachText,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session.dateTime,
                    style: const TextStyle(color: _coachMuted),
                  ),
                  Text(
                    session.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _coachMuted),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SessionListTile extends StatelessWidget {
  const _SessionListTile({required this.session});

  final CoachSession session;

  @override
  Widget build(BuildContext context) {
    return _DarkCard(
      onTap: () => context.push('${AppRoutes.coachSessions}/${session.id}'),
      child: Row(
        children: [
          _SoftCircleIcon(session.icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.type,
                  style: const TextStyle(
                    color: _coachText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${session.time} | ${session.location}',
                  style: const TextStyle(color: _coachMuted),
                ),
                Text(session.format,
                    style: const TextStyle(color: _coachMuted)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: _coachMuted),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _DarkCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SoftCircleIcon(icon),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: _coachText,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _coachMuted),
          ),
        ],
      ),
    );
  }
}

class _CoachScaffold extends StatelessWidget {
  const _CoachScaffold({
    required this.title,
    required this.child,
    required this.currentIndex,
  });

  final String title;
  final Widget child;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _coachBg,
      appBar: AppBar(
        backgroundColor: _coachBg,
        foregroundColor: _coachText,
        title: Text(title),
      ),
      body: child,
      bottomNavigationBar: _CoachBottomNav(currentIndex: currentIndex),
    );
  }
}

class _CoachBottomNav extends StatelessWidget {
  const _CoachBottomNav({required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavTarget('Dashboard', Icons.dashboard_rounded, AppRoutes.coachHome),
      _NavTarget('Sessions', Icons.event_rounded, AppRoutes.coachSessions),
      _NavTarget('Students', Icons.groups_rounded, AppRoutes.coachStudents),
      _NavTarget('Earnings', Icons.payments_rounded, AppRoutes.coachEarnings),
      _NavTarget('Profile', Icons.person_rounded, AppRoutes.coachProfile),
    ];
    return NavigationBar(
      backgroundColor: _coachCard,
      indicatorColor: _coachRed.withValues(alpha: .28),
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => context.go(items[index].route),
      destinations: items
          .map(
            (item) => NavigationDestination(
              icon: Icon(item.icon, color: _coachMuted),
              selectedIcon: Icon(item.icon, color: Colors.white),
              label: item.label,
            ),
          )
          .toList(),
    );
  }
}

class _NavTarget {
  const _NavTarget(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;
}

class _DarkCard extends StatelessWidget {
  const _DarkCard({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _coachCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return box;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: box,
      ),
    );
  }
}

class _SoftCircleIcon extends StatelessWidget {
  const _SoftCircleIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: _coachRed.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: const Color(0xFFFFB4B4), size: 22),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  const _PlanBadge({required this.plan});

  final String plan;

  @override
  Widget build(BuildContext context) {
    final isPro = plan == 'PRO';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isPro ? _coachRed : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: isPro ? _coachRed : _coachMuted),
      ),
      child: Text(
        plan,
        style: TextStyle(
          color: isPro ? Colors.white : _coachMuted,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value, {this.highlight = false});

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: _coachMuted)),
          ),
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: highlight ? const Color(0xFFFFB4B4) : _coachText,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _coachText,
        fontWeight: FontWeight.w900,
        fontSize: 16,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: _coachCard,
      labelStyle: const TextStyle(color: _coachMuted),
      side: BorderSide(color: _coachRed.withValues(alpha: .5)),
    );
  }
}
