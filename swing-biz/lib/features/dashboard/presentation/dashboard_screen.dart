import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/me_providers.dart';
import '../../../core/auth/session_controller.dart';
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
        title: const Text('Owner Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await ref.read(sessionControllerProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: meAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Could not load your account: $err',
              style: const TextStyle(color: _ownerText),
            ),
          ),
        ),
        data: (me) => _OwnerDashboardBody(me: me),
      ),
    );
  }
}

class _OwnerDashboardBody extends StatelessWidget {
  const _OwnerDashboardBody({required this.me});

  final BizMeResponse? me;

  @override
  Widget build(BuildContext context) {
    final business = me?.businessAccount;
    final academyName = business?.businessName ?? 'Swing Academy';
    final location = [
      business?.city,
      business?.state,
    ].where((item) => item != null && item.trim().isNotEmpty).join(', ');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _AcademyHeader(
          academyName: academyName,
          location: location.isEmpty ? 'Mumbai, Maharashtra' : location,
        ),
        const _OwnerSectionTitle('Summary'),
        const _SummaryGrid(),
        const _OwnerSectionTitle('Manage'),
        const _MainNavigationGrid(
          items: [
            _NavItem(
              label: 'Students',
              caption: 'Fees & profiles',
              icon: Icons.groups_rounded,
              route: AppRoutes.students,
            ),
            _NavItem(
              label: 'Batches',
              caption: 'Timing & coach',
              icon: Icons.calendar_month_rounded,
              route: AppRoutes.batches,
            ),
            _NavItem(
              label: 'Coaches',
              caption: 'Salary & batches',
              icon: Icons.sports_rounded,
              route: AppRoutes.coaches,
            ),
          ],
        ),
        const _OwnerSectionTitle('Quick Actions'),
        const _QuickActionGrid(),
      ],
    );
  }
}

class _AcademyHeader extends StatelessWidget {
  const _AcademyHeader({
    required this.academyName,
    required this.location,
  });

  final String academyName;
  final String location;

  @override
  Widget build(BuildContext context) {
    return _OwnerPanel(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _OwnerIcon(
            icon: Icons.school_rounded,
            size: 48,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  academyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: _ownerText,
                      ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: _ownerMuted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _ownerMuted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => context.push(AppRoutes.planUpgrade),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: _ownerBlue.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: _ownerBlue.withValues(alpha: .42)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded, size: 15, color: _ownerBlue),
                  SizedBox(width: 4),
                  Text(
                    'Free',
                    style: TextStyle(
                      color: _ownerText,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid();

  @override
  Widget build(BuildContext context) {
    final metrics = [
      const DashboardMetric(
        label: 'Total Fee Collection',
        amount: 'Rs 2.8L',
        icon: Icons.account_balance_wallet_rounded,
        color: _ownerBlue,
      ),
      const DashboardMetric(
        label: 'Pending Fees',
        amount: 'Rs 42k',
        icon: Icons.pending_actions_rounded,
        color: _ownerBlue,
      ),
      const DashboardMetric(
        label: 'Salary Paid',
        amount: 'Rs 98k',
        icon: Icons.payments_rounded,
        color: _ownerBlue,
      ),
      const DashboardMetric(
        label: 'Gross Revenue',
        amount: 'Rs 3.9L',
        icon: Icons.trending_up_rounded,
        color: _ownerBlue,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.12,
      ),
      itemBuilder: (context, index) => _MetricCard(metric: metrics[index]),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final DashboardMetric metric;

  @override
  Widget build(BuildContext context) {
    return _OwnerPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OwnerIcon(icon: metric.icon),
          const Spacer(),
          Text(
            metric.amount,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: _ownerText,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            metric.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _ownerMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _MainNavigationGrid extends StatelessWidget {
  const _MainNavigationGrid({required this.items});

  final List<_NavItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _OwnerPanel(
                onTap: () => context.push(item.route),
                child: Row(
                  children: [
                    _OwnerIcon(icon: item.icon),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: _ownerText,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.caption,
                            style: const TextStyle(color: _ownerMuted),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: _ownerMuted,
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _QuickActionGrid extends StatelessWidget {
  const _QuickActionGrid();

  @override
  Widget build(BuildContext context) {
    const actions = [
      QuickAction(
        label: 'Add Student',
        icon: Icons.person_add_alt_1_rounded,
        color: _ownerBlue,
        route: AppRoutes.createStudent,
      ),
      QuickAction(
        label: 'New Batch',
        icon: Icons.add_box_rounded,
        color: _ownerBlue,
        route: AppRoutes.createBatch,
      ),
      QuickAction(
        label: 'Fees',
        icon: Icons.receipt_long_rounded,
        color: _ownerBlue,
        route: AppRoutes.fees,
      ),
      QuickAction(
        label: 'Coaches',
        icon: Icons.sports_rounded,
        color: _ownerBlue,
        route: AppRoutes.coaches,
      ),
      QuickAction(
        label: 'Announce',
        icon: Icons.campaign_rounded,
        color: _ownerBlue,
        route: AppRoutes.announcements,
      ),
      QuickAction(
        label: 'Inventory',
        icon: Icons.inventory_2_rounded,
        color: _ownerBlue,
        route: AppRoutes.inventory,
      ),
      QuickAction(
        label: 'Profile',
        icon: Icons.storefront_rounded,
        color: _ownerBlue,
        route: AppRoutes.academyProfile,
      ),
      QuickAction(
        label: 'Payroll',
        icon: Icons.account_balance_rounded,
        color: _ownerBlue,
        route: AppRoutes.payroll,
      ),
      QuickAction(
        label: 'Settings',
        icon: Icons.settings_rounded,
        color: _ownerBlue,
        route: AppRoutes.settings,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: .86,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return _OwnerPanel(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          onTap: () => context.push(action.route),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _OwnerIcon(icon: action.icon, size: 44),
              const SizedBox(height: 10),
              Text(
                action.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: _ownerText,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.caption,
    required this.icon,
    required this.route,
  });

  final String label;
  final String caption;
  final IconData icon;
  final String route;
}

class _OwnerSectionTitle extends StatelessWidget {
  const _OwnerSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: _ownerText,
            ),
      ),
    );
  }
}

class _OwnerPanel extends StatelessWidget {
  const _OwnerPanel({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
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

class _OwnerIcon extends StatelessWidget {
  const _OwnerIcon({
    required this.icon,
    this.size = 42,
  });

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
