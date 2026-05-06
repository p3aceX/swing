import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/me_providers.dart';
import '../../../core/auth/session_controller.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/theme_mode_controller.dart';
import 'dashboard_screen.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meProvider).valueOrNull;
    final scheme = Theme.of(context).colorScheme;
    final title = me?.businessAccount?.businessName ?? me?.user.name ?? 'Account';
    final subtitle = me?.user.phone ?? '';
    final initial = title.isNotEmpty ? title[0].toUpperCase() : 'A';

    return Drawer(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _DrawerHeader(initial: initial, title: title, subtitle: subtitle),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Profile',
                    onTap: () {
                      Navigator.pop(context);
                      context.push(AppRoutes.profile);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Payments',
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(dashboardTabIndexProvider.notifier).state = 3;
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.auto_awesome_rounded,
                    label: "What's New",
                    onTap: () {
                      Navigator.pop(context);
                      _showWhatsNew(context);
                    },
                  ),
                ],
              ),
            ),
            const _DarkModeToggle(),
            _DrawerItem(
              icon: Icons.help_outline_rounded,
              label: 'Help & Support',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon')),
                );
              },
            ),
            Divider(color: scheme.outline, height: 1),
            _DrawerItem(
              icon: Icons.logout_rounded,
              label: 'Logout',
              destructive: true,
              onTap: () {
                Navigator.pop(context);
                ref.read(sessionControllerProvider.notifier).signOut();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({
    required this.initial,
    required this.title,
    required this.subtitle,
  });
  final String initial;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [scheme.primary, scheme.primary.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: TextStyle(
                color: scheme.onPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = destructive ? scheme.error : scheme.onSurface;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DarkModeToggle extends ConsumerWidget {
  const _DarkModeToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeControllerProvider);
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final isDark = mode == ThemeMode.dark ||
        (mode == ThemeMode.system && platformBrightness == Brightness.dark);
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => ref
          .read(themeModeControllerProvider.notifier)
          .set(isDark ? ThemeMode.light : ThemeMode.dark),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Icon(
              isDark
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
              size: 22,
              color: scheme.onSurface,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Dark mode',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ),
            Switch.adaptive(
              value: isDark,
              onChanged: (v) => ref
                  .read(themeModeControllerProvider.notifier)
                  .set(v ? ThemeMode.dark : ThemeMode.light),
            ),
          ],
        ),
      ),
    );
  }
}

void _showWhatsNew(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _WhatsNewSheet(),
  );
}

class _WhatsNewSheet extends StatelessWidget {
  const _WhatsNewSheet();

  static const _items = [
    (
      Icons.calendar_month_rounded,
      'Booking Check-ins',
      'Collect payments at check-in — mark bookings paid on the spot.'
    ),
    (
      Icons.layers_rounded,
      'Unit Management',
      'Add courts, nets and grounds with per-slot pricing and lead times.'
    ),
    (
      Icons.link_rounded,
      'Linked Units',
      'Link nets inside a ground — booking the ground blocks linked nets automatically.'
    ),
    (
      Icons.bar_chart_rounded,
      'Revenue Dashboard',
      'Monthly and daily revenue charts now live on the Home tab.'
    ),
    (
      Icons.sports_rounded,
      'Play Tab',
      'Create and manage matches and tournaments directly from the app.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bottom = MediaQuery.of(context).padding.bottom;
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottom),
      children: [
        Center(
          child: Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: scheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Row(
          children: [
            Icon(Icons.auto_awesome_rounded,
                size: 22, color: scheme.primary),
            const SizedBox(width: 10),
            Text("What's New",
                style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        const SizedBox(height: 4),
        Text('Latest updates to Swing Biz',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 20),
        ..._items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.$1,
                      size: 20, color: scheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.$2,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(item.$3,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
