import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'features/home/home_provider.dart';
import 'features/settings/settings_provider.dart';
import 'core/theme_mode_provider.dart';

final _clockProvider = StreamProvider<DateTime>((ref) {
  return (() async* {
    yield DateTime.now();
    while (true) {
      await Future<void>.delayed(const Duration(minutes: 1));
      yield DateTime.now();
    }
  })();
});

class AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const AppShell({super.key, required this.navigationShell});

  static const _tabs = [
    _Tab(Icons.home_outlined,           Icons.home_rounded,            'Home'),
    _Tab(Icons.groups_outlined,         Icons.groups_rounded,          'Batches'),
    _Tab(Icons.people_outline_rounded,  Icons.people_rounded,          'Students'),
    _Tab(Icons.sports_cricket_outlined, Icons.sports_cricket_rounded,  'Play'),
    _Tab(Icons.payments_outlined,       Icons.payments_rounded,        'Finance'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(_clockProvider);
    final idx = navigationShell.currentIndex;
    final scaffoldKey = GlobalKey<ScaffoldState>();

    final homeAsync     = ref.watch(homeProvider);
    final settingsAsync = ref.watch(settingsProvider);

    final academyName = homeAsync.maybeWhen(
      data: (d) => d.academy['name'] as String? ?? 'Swing Academy',
      orElse: () => 'Swing Academy',
    );
    final h = DateTime.now().hour;
    final greeting = h < 5
        ? 'Good night'
        : h < 12
            ? 'Good morning'
            : h < 17
                ? 'Good afternoon'
                : h < 21
                    ? 'Good evening'
                    : 'Good night';

    final userName = settingsAsync.maybeWhen(
      data: (d) => ((d['user'] as Map?)?.cast<String, dynamic>() ?? {})['name'] as String? ?? '',
      orElse: () => '',
    );
    final userPhone = settingsAsync.maybeWhen(
      data: (d) => ((d['user'] as Map?)?.cast<String, dynamic>() ?? {})['phone'] as String? ?? '',
      orElse: () => '',
    );
    final bizName = settingsAsync.maybeWhen(
      data: (d) => ((d['businessAccount'] as Map?)?.cast<String, dynamic>() ?? {})['businessName'] as String? ?? '',
      orElse: () => '',
    );
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final navBg   = Color.alphaBlend(
      isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
      bgColor,
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: navBg,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: idx == 0
            ? _AppBar(
                greeting: greeting,
                academyName: academyName,
                userInitial: userInitial,
                background: navBg,
                onMenuTap: () => scaffoldKey.currentState?.openDrawer(),
              )
            : null,
        drawer: _SideDrawer(
          userName: userName,
          userPhone: userPhone,
          userInitial: userInitial,
          bizName: bizName,
        ),
        body: navigationShell,
        bottomNavigationBar: _BottomNav(
          currentIndex: idx,
          tabs: _tabs,
          background: navBg,
          onTap: (i) => navigationShell.goBranch(i, initialLocation: i == idx),
        ),
      ),
    );
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final String greeting;
  final String academyName;
  final String userInitial;
  final Color background;
  final VoidCallback onMenuTap;

  const _AppBar({
    required this.greeting,
    required this.academyName,
    required this.userInitial,
    required this.background,
    required this.onMenuTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final top   = MediaQuery.of(context).padding.top;
    final dividerColor = cs.onSurface.withValues(alpha: isDark ? 0.10 : 0.08);

    return Container(
      height: preferredSize.height + top,
      padding: EdgeInsets.only(top: top),
      decoration: BoxDecoration(
        color: background,
        border: Border(bottom: BorderSide(color: dividerColor, width: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile avatar on the LEFT
            GestureDetector(
              onTap: onMenuTap,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: cs.primary,
                child: Text(userInitial,
                    style: TextStyle(color: cs.onPrimary, fontSize: 14, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(width: 12),

            // Greeting + academy name
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(greeting,
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.45),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      )),
                  const SizedBox(height: 1),
                  Text(academyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      )),
                ],
              ),
            ),

            // Boxed icon buttons on the RIGHT
            _BoxedIcon(
              icon: Icons.calendar_month_outlined,
              cs: cs,
            ),
            const SizedBox(width: 8),
            _BoxedIcon(
              icon: Icons.notifications_none_rounded,
              cs: cs,
            ),
          ],
        ),
      ),
    );
  }
}

class _BoxedIcon extends StatelessWidget {
  final IconData icon;
  final ColorScheme cs;
  final VoidCallback? onTap;

  const _BoxedIcon({required this.icon, required this.cs, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(
            color: cs.onSurface.withValues(alpha: 0.12),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: cs.onSurface.withValues(alpha: 0.65)),
      ),
    );
  }
}

// ── Side drawer ───────────────────────────────────────────────────────────────

class _SideDrawer extends ConsumerWidget {
  final String userName;
  final String userPhone;
  final String userInitial;
  final String bizName;

  const _SideDrawer({
    required this.userName,
    required this.userPhone,
    required this.userInitial,
    required this.bizName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final cs = Theme.of(context).colorScheme;
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── User header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: cs.primary,
                    child: Text(userInitial,
                        style: TextStyle(color: cs.onPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName.isNotEmpty ? userName : 'User',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: cs.onSurface)),
                        if (userPhone.isNotEmpty)
                          Text(userPhone,
                              style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.65), fontWeight: FontWeight.w500)),
                        if (bizName.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0057C8).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(bizName,
                                style: const TextStyle(fontSize: 11, color: Color(0xFF0057C8), fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // ── Nav items ────────────────────────────────────────────────────
            _DrawerItem(icon: Icons.person_outline_rounded, label: 'Profile',
                onTap: () { Navigator.pop(context); context.push('/profile'); }),
            _DrawerItem(icon: Icons.sports_cricket_outlined, label: 'Coaches',
                onTap: () { Navigator.pop(context); context.push('/coaches'); }),
            _DrawerItem(icon: Icons.badge_outlined, label: 'Staff',
                onTap: () { Navigator.pop(context); context.push('/staff'); }),
            _DrawerItem(icon: Icons.campaign_outlined, label: 'Announcements',
                onTap: () { Navigator.pop(context); context.push('/announcements'); }),
            _DrawerItem(icon: Icons.inventory_2_outlined, label: 'Inventory',
                onTap: () { Navigator.pop(context); context.push('/inventory'); }),
            _DrawerItem(icon: Icons.settings_outlined, label: 'Settings',
                onTap: () { Navigator.pop(context); context.push('/settings'); }),
            ListTile(
              leading: Icon(Icons.dark_mode_outlined, size: 22, color: cs.onSurface),
              title: Text(
                'Dark Mode',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: cs.onSurface),
              ),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (value) => ref.read(themeModeProvider.notifier).setDarkMode(value),
              ),
            ),

            const Spacer(),
            const Divider(height: 1),

            // ── Logout ───────────────────────────────────────────────────────
            _DrawerItem(
              icon: Icons.logout_rounded,
              label: 'Logout',
              color: Colors.red,
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Logout', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  // ignore: use_build_context_synchronously
                  ref.read(settingsProvider.notifier).logout();
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerItem({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.onSurface;
    return ListTile(
      leading: Icon(icon, color: c, size: 22),
      title: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: c, fontSize: 15)),
      onTap: onTap,
      horizontalTitleGap: 8,
      visualDensity: VisualDensity.compact,
    );
  }
}

// ── Bottom nav ────────────────────────────────────────────────────────────────

class _Tab {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _Tab(this.icon, this.activeIcon, this.label);
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final List<_Tab> tabs;
  final Color background;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.tabs,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = cs.onSurface.withValues(alpha: 0.55);
    final divider = cs.onSurface.withValues(alpha: isDark ? 0.10 : 0.08);

    return Container(
      decoration: BoxDecoration(
        color: background,
        border: Border(top: BorderSide(color: divider, width: 0.5)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      child: SizedBox(
        height: 72,
        child: Row(
          children: List.generate(tabs.length, (i) {
            final tab = tabs[i];
            final selected = i == currentIndex;
            return Expanded(
              child: _NavItem(
                tab: tab,
                selected: selected,
                accent: cs.primary,
                muted: muted,
                onTap: () => onTap(i),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.accent,
    required this.muted,
    required this.onTap,
  });

  final _Tab tab;
  final bool selected;
  final Color accent;
  final Color muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const duration = Duration(milliseconds: 220);
    const curve = Curves.easeOutCubic;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: duration,
            switchInCurve: curve,
            switchOutCurve: curve,
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: Tween<double>(begin: 0.85, end: 1).animate(anim),
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: Icon(
              selected ? tab.activeIcon : tab.icon,
              key: ValueKey(selected),
              size: 22,
              color: selected ? accent : muted,
            ),
          ),
          const SizedBox(height: 3),
          AnimatedDefaultTextStyle(
            duration: duration,
            curve: curve,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: -0.1,
              color: selected ? accent : muted,
            ),
            child: Text(tab.label),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: duration,
            curve: curve,
            width: selected ? 4 : 0,
            height: selected ? 4 : 0,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
