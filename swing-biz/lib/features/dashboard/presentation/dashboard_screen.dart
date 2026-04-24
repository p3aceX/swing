import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/me_providers.dart';
import '../../../core/router/app_router.dart';
import '../data/academy_dashboard_data.dart';

const _ownerBg = Color(0xFF08111F);
const _ownerCard = Color(0xFF151F2E);
const _ownerBorder = Color(0xFF243246);
const _ownerBlue = Color(0xFF38BDF8);
const _ownerText = Color(0xFFFFFFFF);
const _ownerMuted = Color(0xFFB6C2D1);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meAsync = ref.watch(meProvider);
    return Scaffold(
      backgroundColor: _ownerBg,
      appBar: AppBar(
        backgroundColor: _ownerBg,
        foregroundColor: _ownerText,
        title: const Text('Academy Manager'),
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Icon(Icons.sports_cricket_rounded),
        ),
        leadingWidth: 42,
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.ownerSearch),
            icon: const Icon(Icons.search_rounded),
          ),
          Stack(
            children: [
              IconButton(
                onPressed: () => context.push(AppRoutes.ownerNotifications),
                icon: const Icon(Icons.notifications_none_rounded),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('3',
                        style: TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              radius: 16,
              child: Text('OM'),
            ),
            onSelected: (value) {
              if (value == 'profile') {
                context.push(AppRoutes.academyProfile);
              } else if (value == 'settings') {
                context.push(AppRoutes.settings);
              } else if (value == 'logout') {
                context.push(AppRoutes.ownerLogoutConfirm);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'profile', child: Text('Account')),
              PopupMenuItem(value: 'settings', child: Text('Settings')),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: meAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('Could not load owner dashboard: $err',
              style: const TextStyle(color: _ownerText)),
        ),
        data: (me) => _OwnerDashboardBody(me: me),
      ),
      bottomNavigationBar: const _OwnerBottomNav(index: 0),
    );
  }
}

class _OwnerDashboardBody extends StatelessWidget {
  const _OwnerDashboardBody({required this.me});

  final BizMeResponse? me;

  @override
  Widget build(BuildContext context) {
    final name = me?.user.name ?? 'Owner';
    final academyName = me?.businessAccount?.businessName ?? 'Swing Academy';
    final modules = [
      _ModuleItem('Academy Overview', Icons.apartment_rounded,
          AppRoutes.academyOverview),
      _ModuleItem('Players', Icons.groups_rounded, AppRoutes.students),
      _ModuleItem('Coaches', Icons.sports_rounded, AppRoutes.coaches),
      _ModuleItem('Batches', Icons.calendar_month_rounded, AppRoutes.batches),
      _ModuleItem('Fee Management', Icons.account_balance_wallet_rounded,
          AppRoutes.fees),
      _ModuleItem('Reminders', Icons.notifications_active_rounded,
          AppRoutes.feeReminderList),
      _ModuleItem('Documents', Icons.folder_open_rounded, AppRoutes.documents),
      _ModuleItem(
          'Salary Management', Icons.payments_rounded, AppRoutes.payroll),
      _ModuleItem('Inventory', Icons.inventory_2_rounded, AppRoutes.inventory),
      _ModuleItem('Reports', Icons.bar_chart_rounded, AppRoutes.reports),
      _ModuleItem('Settings', Icons.settings_rounded, AppRoutes.settings),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _panel(
          child: Row(
            children: [
              const _OwnerIcon(Icons.waving_hand_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome back, $name',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: _ownerText,
                              fontWeight: FontWeight.w900,
                            )),
                    const SizedBox(height: 4),
                    Text(
                      '$academyName â€¢ 23 Apr 2026 â€¢ 6:30 PM',
                      style: const TextStyle(color: _ownerMuted),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'You have 3 unpaid fees pending',
                      style: TextStyle(color: _ownerBlue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: const [
            Expanded(child: _MetricCard('Rs 1,45,000', 'Total Revenue')),
            SizedBox(width: 10),
            Expanded(child: _MetricCard('48', 'Total Players')),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: const [
            Expanded(child: _MetricCard('5', 'Total Coaches')),
            SizedBox(width: 10),
            Expanded(child: _MetricCard('Rs 32,500', 'Pending Fees')),
          ],
        ),
        const SizedBox(height: 18),
        const _SectionTitle('Quick Access'),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: modules.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: .92,
          ),
          itemBuilder: (context, index) {
            final item = modules[index];
            return _panel(
              onTap: () => context.push(item.route),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _OwnerIcon(item.icon, size: 42),
                  const SizedBox(height: 10),
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _ownerText,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 18),
        const _SectionTitle('Recent Activity'),
        ...academyActivities.map(
          (activity) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _panel(
              child: Row(
                children: [
                  const _OwnerIcon(Icons.history_rounded),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(activity.text,
                            style: const TextStyle(
                              color: _ownerText,
                              fontWeight: FontWeight.w700,
                            )),
                        const SizedBox(height: 4),
                        Text(activity.time,
                            style: const TextStyle(color: _ownerMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => context.push(AppRoutes.academyOverview),
            child: const Text('View More Metrics'),
          ),
        ),
      ],
    );
  }

  Widget _panel({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    VoidCallback? onTap,
  }) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _ownerCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ownerBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: content,
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _ownerCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ownerBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _ownerText,
                    fontWeight: FontWeight.w900,
                  )),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: _ownerMuted)),
        ],
      ),
    );
  }
}

class _OwnerBottomNav extends StatelessWidget {
  const _OwnerBottomNav({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavTarget('Home', Icons.home_rounded, AppRoutes.dashboard),
      _NavTarget('Players', Icons.groups_rounded, AppRoutes.students),
      _NavTarget('Coaches', Icons.sports_rounded, AppRoutes.coaches),
      _NavTarget(
          'Finance', Icons.account_balance_wallet_rounded, AppRoutes.fees),
      _NavTarget('Settings', Icons.settings_rounded, AppRoutes.settings),
    ];
    return NavigationBar(
      backgroundColor: _ownerCard,
      indicatorColor: _ownerBlue.withValues(alpha: .2),
      selectedIndex: index,
      onDestinationSelected: (value) => context.go(items[value].route),
      destinations: items
          .map(
            (item) => NavigationDestination(
              icon: Icon(item.icon, color: _ownerMuted),
              selectedIcon: Icon(item.icon, color: _ownerBlue),
              label: item.label,
            ),
          )
          .toList(),
    );
  }
}

class _OwnerIcon extends StatelessWidget {
  const _OwnerIcon(this.icon, {this.size = 42});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _ownerBlue.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: _ownerBlue, size: size * .52),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: _ownerText,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

class _ModuleItem {
  const _ModuleItem(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;
}

class _NavTarget {
  const _NavTarget(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;
}
