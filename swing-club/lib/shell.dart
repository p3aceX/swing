import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/home/home_provider.dart';
import 'features/settings/settings_provider.dart';

class AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const AppShell({super.key, required this.navigationShell});

  static const _tabs = [
    _Tab(Icons.home_outlined,           Icons.home_rounded,            'Home'),
    _Tab(Icons.groups_outlined,         Icons.groups_rounded,          'Batches'),
    _Tab(Icons.people_outline_rounded,  Icons.people_rounded,          'Students'),
    _Tab(Icons.sports_cricket_outlined, Icons.sports_cricket_rounded,  'Play'),
    _Tab(Icons.payments_outlined,       Icons.payments_rounded,        'Payments'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = navigationShell.currentIndex;
    final scaffoldKey = GlobalKey<ScaffoldState>();

    final homeAsync     = ref.watch(homeProvider);
    final settingsAsync = ref.watch(settingsProvider);

    final academyName = homeAsync.maybeWhen(
      data: (d) => d.academy['name'] as String? ?? 'Swing Academy',
      orElse: () => 'Swing Academy',
    );
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF4F2EB),
        appBar: _AppBar(
          currentIndex: idx,
          academyName: academyName,
          userInitial: userInitial,
          onMenuTap: () => scaffoldKey.currentState?.openEndDrawer(),
        ),
        endDrawer: _SideDrawer(
          userName: userName,
          userPhone: userPhone,
          userInitial: userInitial,
          bizName: bizName,
        ),
        body: navigationShell,
        bottomNavigationBar: _BottomNav(
          currentIndex: idx,
          tabs: _tabs,
          onTap: (i) => navigationShell.goBranch(i, initialLocation: i == idx),
        ),
      ),
    );
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;
  final String academyName;
  final String userInitial;
  final VoidCallback onMenuTap;

  const _AppBar({
    required this.currentIndex,
    required this.academyName,
    required this.userInitial,
    required this.onMenuTap,
  });

  static const _titles = ['', 'Batches', 'Students', 'Play', 'Payments'];

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final title = currentIndex == 0 ? academyName : _titles[currentIndex];
    return Container(
      height: preferredSize.height + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(
        color: Color(0xFFF4F2EB),
        border: Border(bottom: BorderSide(color: Color(0xFFE0DED6), width: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                    color: Color(0xFF071B3D), fontSize: 22,
                    fontWeight: FontWeight.w900, letterSpacing: -0.5,
                  )),
            ),
            GestureDetector(
              onTap: onMenuTap,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF071B3D),
                child: Text(userInitial,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
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
    return Drawer(
      backgroundColor: const Color(0xFFF4F2EB),
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
                    backgroundColor: const Color(0xFF071B3D),
                    child: Text(userInitial,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName.isNotEmpty ? userName : 'User',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF071B3D))),
                        if (userPhone.isNotEmpty)
                          Text(userPhone,
                              style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
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
            _DrawerItem(icon: Icons.campaign_outlined, label: 'Announcements',
                onTap: () { Navigator.pop(context); context.push('/announcements'); }),
            _DrawerItem(icon: Icons.inventory_2_outlined, label: 'Inventory',
                onTap: () { Navigator.pop(context); context.push('/inventory'); }),
            _DrawerItem(icon: Icons.settings_outlined, label: 'Settings',
                onTap: () { Navigator.pop(context); context.push('/settings'); }),

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
    final c = color ?? const Color(0xFF071B3D);
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
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.tabs, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF4F2EB),
        border: Border(top: BorderSide(color: Color(0xFFE0DED6), width: 0.5)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: SizedBox(
        height: 58,
        child: Row(
          children: List.generate(tabs.length, (i) {
            final tab = tabs[i];
            final selected = i == currentIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      selected ? tab.activeIcon : tab.icon,
                      size: 22,
                      color: selected ? const Color(0xFF071B3D) : const Color(0xFFAAAAAA),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tab.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? const Color(0xFF071B3D) : const Color(0xFFAAAAAA),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
