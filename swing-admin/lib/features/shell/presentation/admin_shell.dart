import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/theme/app_theme.dart';

class NavItem {
  const NavItem(this.path, this.label, this.icon, this.selectedIcon);
  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class NavGroup {
  const NavGroup({
    required this.id,
    required this.label,
    required this.icon,
    required this.children,
  });

  final String id;
  final String label;
  final IconData icon;
  final List<NavItem> children;
}

const kExpandedSidebarBreakpoint = 760.0;

const List<NavGroup> kNavGroups = <NavGroup>[
  NavGroup(
    id: 'overview',
    label: 'Overview',
    icon: Icons.space_dashboard_outlined,
    children: [
      NavItem('/dashboard', 'Dashboard', Icons.insights_outlined, Icons.insights),
    ],
  ),
  NavGroup(
    id: 'operations',
    label: 'Operations',
    icon: Icons.work_outline,
    children: [
      NavItem('/users', 'Users', Icons.people_alt_outlined, Icons.people_alt),
      NavItem('/arenas', 'Arenas', Icons.stadium_outlined, Icons.stadium),
      NavItem('/matches', 'Matches', Icons.sports_cricket_outlined,
          Icons.sports_cricket),
      NavItem('/tournaments', 'Tournaments', Icons.emoji_events_outlined,
          Icons.emoji_events),
    ],
  ),
];

final List<NavItem> kDestinations = [
  for (final group in kNavGroups) ...group.children,
];

NavItem _bestMatchingNavItem(String location) {
  NavItem best = kDestinations.first;
  var bestScore = -1;
  for (final item in kDestinations) {
    final isMatch =
        location == item.path || location.startsWith('${item.path}/');
    if (!isMatch) continue;
    final score = item.path.length;
    if (score > bestScore) {
      best = item;
      bestScore = score;
    }
  }
  return best;
}

int destinationIndexFor(String location) {
  final best = _bestMatchingNavItem(location);
  return kDestinations.indexOf(best);
}

String groupIdForLocation(String location) {
  final selected = _bestMatchingNavItem(location);
  for (final group in kNavGroups) {
    if (group.children.contains(selected)) return group.id;
  }
  return kNavGroups.first.id;
}

String labelForLocation(String location) {
  return _bestMatchingNavItem(location).label;
}

class AdminShell extends ConsumerWidget {
  const AdminShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < kExpandedSidebarBreakpoint;
        if (compact) {
          return _CompactShell(
            location: location,
            child: child,
          );
        }
        return _WideShell(
          location: location,
          child: child,
        );
      },
    );
  }
}

class _CompactShell extends ConsumerWidget {
  const _CompactShell({
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    return Scaffold(
      drawer: _CompactDrawer(
        location: location,
        userName: user?.displayName ?? '',
        userEmail: user?.email ?? '',
        onGo: (path) => context.go(path),
        onLogout: () => ref.read(authControllerProvider.notifier).logout(),
      ),
      body: Column(
        children: [
          _CompactTopBar(title: labelForLocation(location)),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _CompactTopBar extends StatelessWidget {
  const _CompactTopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Builder(
                builder: (context) {
                  return IconButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: const Icon(Icons.menu, size: 20),
                    color: AppColors.textPrimary,
                    tooltip: 'Open navigation',
                  );
                },
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactDrawer extends StatelessWidget {
  const _CompactDrawer({
    required this.location,
    required this.userName,
    required this.userEmail,
    required this.onGo,
    required this.onLogout,
  });

  final String location;
  final String userName;
  final String userEmail;
  final ValueChanged<String> onGo;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Swing Admin ERP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Operations workspace',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  for (final group in kNavGroups)
                    _CompactDrawerGroup(
                      group: group,
                      location: location,
                      onGo: (path) {
                        Navigator.of(context).pop();
                        onGo(path);
                      },
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 10, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName.isEmpty ? 'Signed in' : userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          userEmail,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onLogout();
                    },
                    icon: const Icon(
                      Icons.logout,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    tooltip: 'Sign out',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactDrawerGroup extends StatelessWidget {
  const _CompactDrawerGroup({
    required this.group,
    required this.location,
    required this.onGo,
  });

  final NavGroup group;
  final String location;
  final ValueChanged<String> onGo;

  @override
  Widget build(BuildContext context) {
    final selectedPath = _bestMatchingNavItem(location).path;
    final isActiveGroup = group.children.any((item) => item.path == selectedPath);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isActiveGroup ? AppColors.bg : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpansionTile(
        key: PageStorageKey(group.id),
        initiallyExpanded: isActiveGroup,
        tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Icon(
          group.icon,
          size: 16,
          color: isActiveGroup
              ? AppColors.textPrimary
              : AppColors.textSecondary,
        ),
        title: Text(
          group.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActiveGroup
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
        ),
        children: [
          for (final item in group.children)
            _ChildNavTile(
              item: item,
              selected: item.path == selectedPath,
              onTap: () => onGo(item.path),
            ),
        ],
      ),
    );
  }
}

class _WideShell extends ConsumerStatefulWidget {
  const _WideShell({
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  @override
  ConsumerState<_WideShell> createState() => _WideShellState();
}

class _WideShellState extends ConsumerState<_WideShell> {
  late Set<String> _expandedGroups;

  @override
  void initState() {
    super.initState();
    _expandedGroups = {
      groupIdForLocation(widget.location),
      kNavGroups.first.id,
    };
  }

  @override
  void didUpdateWidget(covariant _WideShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final activeGroup = groupIdForLocation(widget.location);
    if (!_expandedGroups.contains(activeGroup)) {
      _expandedGroups = {..._expandedGroups, activeGroup};
    }
  }

  void _toggleGroup(String groupId) {
    setState(() {
      if (_expandedGroups.contains(groupId)) {
        if (groupId == groupIdForLocation(widget.location)) return;
        _expandedGroups = {..._expandedGroups}..remove(groupId);
      } else {
        _expandedGroups = {..._expandedGroups, groupId};
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    return Scaffold(
      body: Row(
        children: [
          _Sidebar(
            location: widget.location,
            expandedGroups: _expandedGroups,
            userName: user?.displayName ?? '',
            userEmail: user?.email ?? '',
            onToggleGroup: _toggleGroup,
            onGo: (path) => context.go(path),
            onLogout: () => ref.read(authControllerProvider.notifier).logout(),
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.location,
    required this.expandedGroups,
    required this.userName,
    required this.userEmail,
    required this.onToggleGroup,
    required this.onGo,
    required this.onLogout,
  });

  final String location;
  final Set<String> expandedGroups;
  final String userName;
  final String userEmail;
  final ValueChanged<String> onToggleGroup;
  final ValueChanged<String> onGo;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 272,
      decoration: const BoxDecoration(
        color: Color(0xFFF7F4EF),
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0C000000),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _BrandBadge(),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Swing Admin ERP',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Operations workspace',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14),
                  _SidebarMetaPill(
                    icon: Icons.hub_outlined,
                    label: 'Left navigation',
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final group in kNavGroups)
                  _NavGroupCard(
                    group: group,
                    location: location,
                    expanded: expandedGroups.contains(group.id),
                    onToggle: () => onToggleGroup(group.id),
                    onGo: onGo,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEE8DD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      (userName.isEmpty ? 'S' : userName.characters.first)
                          .toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName.isEmpty ? 'Signed in' : userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userEmail,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onLogout,
                    icon: const Icon(
                      Icons.logout_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    tooltip: 'Sign out',
                    style: IconButton.styleFrom(
                      minimumSize: const Size(36, 36),
                      padding: EdgeInsets.zero,
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

class _BrandBadge extends StatelessWidget {
  const _BrandBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF161514),
            Color(0xFF46413B),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: const Text(
        'S',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

class _SidebarMetaPill extends StatelessWidget {
  const _SidebarMetaPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F1E8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavGroupCard extends StatelessWidget {
  const _NavGroupCard({
    required this.group,
    required this.location,
    required this.expanded,
    required this.onToggle,
    required this.onGo,
  });

  final NavGroup group;
  final String location;
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<String> onGo;

  bool get isActiveGroup =>
      group.children.any((item) => item.path == _bestMatchingNavItem(location).path);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isActiveGroup ? AppColors.surface : const Color(0x40FFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActiveGroup ? AppColors.borderStrong : const Color(0xFFE8E1D7),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isActiveGroup
                          ? const Color(0xFFF4EFE6)
                          : Colors.white.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      group.icon,
                      size: 16,
                      color: isActiveGroup
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isActiveGroup
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${group.children.length} module${group.children.length > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F1E8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      expanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (isActiveGroup) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.textPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: [
                  for (final item in group.children)
                    _ChildNavTile(
                      item: item,
                      selected: item.path == _bestMatchingNavItem(location).path,
                      onTap: () => onGo(item.path),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ChildNavTile extends StatelessWidget {
  const _ChildNavTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              gradient: selected
                  ? const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFFF6F2EA),
                        Color(0xFFFFFFFF),
                      ],
                    )
                  : null,
              color: selected ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? AppColors.borderStrong : Colors.transparent,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                if (selected)
                  Container(
                    width: 3,
                    height: 24,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  )
                else
                  const SizedBox(width: 13),
                Icon(
                  selected ? item.selectedIcon : item.icon,
                  size: 16,
                  color: selected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.arrow_outward_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
