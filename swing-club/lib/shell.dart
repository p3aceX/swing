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
    _TabInfo(Icons.home_outlined,    Icons.home_rounded,        'Home'),
    _TabInfo(Icons.people_outline_rounded, Icons.people_rounded, 'Students'),
    _TabInfo(Icons.calendar_today_outlined, Icons.today_rounded, 'Sessions'),
    _TabInfo(Icons.grid_view_outlined, Icons.grid_view_rounded,  'More'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = navigationShell.currentIndex;

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
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F2EB),
        appBar: _SwingAppBar(
          currentIndex: idx,
          academyName: academyName,
          userInitial: userInitial,
        ),
        body: navigationShell,
        bottomNavigationBar: _SwingBottomNav(
          currentIndex: idx,
          tabs: _tabs,
          onTap: (i) => navigationShell.goBranch(i, initialLocation: i == idx),
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
  final String academyName;
  final String userInitial;

  const _SwingAppBar({
    required this.currentIndex,
    required this.academyName,
    required this.userInitial,
  });

  static const _titles = ['', 'Students', 'Sessions', 'More'];

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
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF071B3D),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => context.push('/profile'),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF071B3D),
                child: Text(
                  userInitial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
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
        border: Border(top: BorderSide(color: Color(0xFFE0DED6), width: 0.5)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      selected ? tab.activeIcon : tab.icon,
                      size: 24,
                      color: selected ? const Color(0xFF071B3D) : const Color(0xFFAAAAAA),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tab.label,
                      style: TextStyle(
                        fontSize: 11,
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
