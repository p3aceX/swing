import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const AppShell({super.key, required this.navigationShell});

  static const _tabs = [
    _TabInfo(Icons.home_outlined, Icons.home_rounded, 'Home'),
    _TabInfo(Icons.people_outline_rounded, Icons.people_rounded, 'Students'),
    _TabInfo(Icons.groups_outlined, Icons.groups_rounded, 'Batches'),
    _TabInfo(Icons.payments_outlined, Icons.payments_rounded, 'Payments'),
  ];

  @override
  Widget build(BuildContext context) {
    final idx = navigationShell.currentIndex;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F2EB),
        appBar: _SwingAppBar(currentIndex: idx),
        body: navigationShell,
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

class _TabInfo {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _TabInfo(this.icon, this.activeIcon, this.label);
}

// ─── Top App Bar ──────────────────────────────────────────────────────────────

class _SwingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;
  const _SwingAppBar({required this.currentIndex});

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
              onTap: () {},
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
