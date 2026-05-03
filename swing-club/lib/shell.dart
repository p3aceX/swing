import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';

class AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const AppShell({super.key, required this.navigationShell});

  static const _tabs = [
    _TabInfo(Icons.home_outlined, Icons.home_rounded, 'Home'),
    _TabInfo(Icons.people_outline_rounded, Icons.people_rounded, 'Students'),
    _TabInfo(Icons.groups_outlined, Icons.groups_rounded, 'Batches'),
    _TabInfo(Icons.payments_outlined, Icons.payments_rounded, 'Payments'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = navigationShell.currentIndex;
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF4F2EB),
        appBar: _SwingAppBar(
          currentIndex: idx,
          onProfileTap: () => scaffoldKey.currentState?.openEndDrawer(),
        ),
        body: navigationShell,
        endDrawer: _ProfileDrawer(),
        bottomNavigationBar: _SwingBottomNav(
          currentIndex: idx,
          tabs: _tabs,
          onTap: (i) => navigationShell.goBranch(
            i,
            initialLocation: i == idx,
          ),
        ),
      ),
    );
  }
}

class _ProfileDrawer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: const Color(0xFFF4F2EB),
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFFF4F2EB),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE0DED6), width: 0.5),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0057C8).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      size: 32,
                      color: Color(0xFF0057C8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Academy Admin',
                    style: TextStyle(
                      color: Color(0xFF071B3D),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              context.pop(); // Close drawer
              context.push('/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text('Inventory'),
            onTap: () {
              context.pop();
              context.push('/inventory');
            },
          ),
          ListTile(
            leading: const Icon(Icons.campaign_outlined),
            title: const Text('Announcements'),
            onTap: () {
              context.pop();
              context.push('/announcements');
            },
          ),
          ListTile(
            leading: const Icon(Icons.sports_cricket_outlined),
            title: const Text('Coaches'),
            onTap: () {
              context.pop();
              context.push('/coaches');
            },
          ),
          const Spacer(),
          const Divider(color: Color(0xFFE0DED6), thickness: 0.5),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: Colors.red.withOpacity(0.1),
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Logout', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  ref.read(authProvider.notifier).logout();
                }
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _TabInfo {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _TabInfo(this.icon, this.activeIcon, this.label);
}

// ─── Top App Bar ──────────────────────────────────────────────────────────────

class _SwingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;
  final VoidCallback onProfileTap;
  const _SwingAppBar({required this.currentIndex, required this.onProfileTap});

  static const _titles = ['Swing Academy', 'Students', 'Batches', 'Payments'];

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(
        color: Color(0xFFF4F2EB),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0DED6), width: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                _titles[currentIndex],
                style: const TextStyle(
                  color: Color(0xFF071B3D),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            // Notification bell
            _NavAction(
              icon: Icons.notifications_outlined,
              onTap: () {},
            ),
            const SizedBox(width: 8),
            // Profile avatar
            GestureDetector(
              onTap: onProfileTap,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF0057C8).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: 20,
                  color: Color(0xFF0057C8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 22, color: const Color(0xFF071B3D)),
      ),
    );
  }
}

// ─── Bottom Navigation ────────────────────────────────────────────────────────

class _SwingBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<_TabInfo> tabs;
  final ValueChanged<int> onTap;

  const _SwingBottomNav({
    required this.currentIndex,
    required this.tabs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF4F2EB),
        border: Border(
          top: BorderSide(color: Color(0xFFE0DED6), width: 0.5),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      child: SizedBox(
        height: 60,
        child: Row(
          children: List.generate(tabs.length, (i) {
            final tab = tabs[i];
            final selected = i == currentIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selected ? tab.activeIcon : tab.icon,
                        size: 24,
                        color: selected
                            ? const Color(0xFF071B3D)
                            : const Color(0xFFAAAAAA),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected
                              ? const Color(0xFF071B3D)
                              : const Color(0xFFAAAAAA),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
