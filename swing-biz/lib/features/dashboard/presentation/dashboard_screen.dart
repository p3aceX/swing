import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/me_providers.dart';
import '../../../core/auth/session_controller.dart';
import '../../../core/router/app_router.dart';
import '../../arena/services/arena_profile_providers.dart';
import '../../bookings/presentation/bookings_page.dart';
import '../../payments/presentation/payments_page.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _index = 0;

  static const _navItems = [
    _NavItem(Icons.home_rounded, Icons.home_outlined, 'Home'),
    _NavItem(Icons.stadium_rounded, Icons.stadium_outlined, 'Arenas'),
    _NavItem(Icons.calendar_month_rounded, Icons.calendar_month_outlined, 'Bookings'),
    _NavItem(Icons.account_balance_wallet_rounded, Icons.account_balance_wallet_outlined, 'Payments'),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _HomeTab(),
      const _ArenasTab(),
      const _BookingsTab(),
      const _PaymentsTab(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: _BottomNav(
        currentIndex: _index,
        items: _navItems,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.activeIcon, this.inactiveIcon, this.label);
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1, thickness: 1, color: Color(0xFFF2F4F7)),
          Padding(
            padding: EdgeInsets.fromLTRB(8, 6, 8, 6 + bottom),
            child: Row(
              children: List.generate(items.length, (i) {
                final item = items[i];
                final selected = i == currentIndex;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(i),
                    child: _NavTile(item: item, selected: selected),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.item, required this.selected});

  final _NavItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF101828) : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              selected ? item.activeIcon : item.inactiveIcon,
              size: 22,
              color: selected ? Colors.white : const Color(0xFF98A2B3),
            ),
          ),
          const SizedBox(height: 3),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            style: TextStyle(
              fontSize: 10,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? const Color(0xFF101828) : const Color(0xFF98A2B3),
            ),
            child: Text(item.label),
          ),
        ],
      ),
    );
  }
}

void _showProfileSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _ProfileSheet(ref: ref),
  );
}

class _ProfileAvatar extends ConsumerWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meProvider).valueOrNull;
    final initial = (me?.user.name ?? 'U').isNotEmpty
        ? (me?.user.name ?? 'U')[0].toUpperCase()
        : 'U';
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF101828),
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ProfileSheet extends ConsumerWidget {
  const _ProfileSheet({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final meAsync = widgetRef.watch(meProvider);
    final bottom = MediaQuery.of(context).padding.bottom;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (ctx, controller) => meAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (me) {
          if (me == null) return const SizedBox();
          final business = me.businessAccount;
          return ListView(
            controller: controller,
            padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottom),
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF101828),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      (me.user.name ?? 'U').isNotEmpty
                          ? (me.user.name ?? 'U')[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          me.user.name ?? 'User',
                          style: const TextStyle(
                            color: Color(0xFF101828),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          me.user.phone,
                          style: const TextStyle(
                            color: Color(0xFF667085),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _SheetSection(
                title: 'Account',
                rows: [
                  _SheetRow(Icons.person_outline_rounded, 'Name', me.user.name ?? 'Not set'),
                  _SheetRow(Icons.phone_outlined, 'Phone', me.user.phone),
                  _SheetRow(Icons.mail_outline_rounded, 'Email', me.user.email ?? 'Not set'),
                ],
              ),
              const SizedBox(height: 16),
              _SheetSection(
                title: 'Business',
                rows: [
                  _SheetRow(Icons.business_outlined, 'Name', business?.businessName ?? 'Not set'),
                  _SheetRow(Icons.badge_outlined, 'Contact', business?.contactName ?? 'Not set'),
                  _SheetRow(Icons.location_on_outlined, 'Address', business?.address ?? 'Not set'),
                  _SheetRow(Icons.receipt_outlined, 'GST', business?.gstNumber ?? 'Not set'),
                  _SheetRow(Icons.credit_card_outlined, 'PAN', business?.panNumber ?? 'Not set'),
                ],
              ),
              const SizedBox(height: 24),
              _SheetActionRow(
                icon: Icons.switch_account_rounded,
                label: 'Switch Profile',
                onTap: () {
                  Navigator.pop(context);
                  context.push(AppRoutes.roleSelection);
                },
              ),
              const SizedBox(height: 8),
              _SheetActionRow(
                icon: Icons.logout_rounded,
                label: 'Logout',
                destructive: true,
                onTap: () => widgetRef.read(sessionControllerProvider.notifier).signOut(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SheetSection extends StatelessWidget {
  const _SheetSection({required this.title, required this.rows});

  final String title;
  final List<_SheetRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF98A2B3),
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        ...rows.map((r) => _SheetRowTile(row: r)),
      ],
    );
  }
}

class _SheetRow {
  const _SheetRow(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;
}

class _SheetRowTile extends StatelessWidget {
  const _SheetRowTile({required this.row});
  final _SheetRow row;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Icon(row.icon, size: 18, color: const Color(0xFF98A2B3)),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              row.label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF667085),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              row.value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF101828),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetActionRow extends StatelessWidget {
  const _SheetActionRow({
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
    final color = destructive ? const Color(0xFFD92D20) : const Color(0xFF101828);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meProvider).valueOrNull;
    final name =
        me?.businessAccount?.businessName ?? me?.user.name ?? 'Your Arena';
    final dateStr = DateFormat('EEEE, d MMM').format(DateTime.now());

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome to Arena',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF667085),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF101828),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF667085),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _showProfileSheet(context, ref),
              child: const _ProfileAvatar(),
            ),
          ],
        ),
      ],
    );
  }
}

class _ArenasTab extends ConsumerWidget {
  const _ArenasTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arenasAsync = ref.watch(ownedArenasProvider);

    return Column(
      children: [
        _PageHeader(
          title: 'Arenas',
          subtitle: 'Manage venues, photos, facilities and booking rules.',
          action: FilledButton.icon(
            onPressed: () => context.push(AppRoutes.createArena),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Arena'),
          ),
        ),
        Expanded(
          child: arenasAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _CenteredMessage(
              title: 'Could not load arenas',
              message: '$error',
            ),
            data: (arenas) {
              if (arenas.isEmpty) {
                return _CenteredMessage(
                  title: 'No arenas yet',
                  message: 'Add your first arena to start managing bookings.',
                  action: FilledButton.icon(
                    onPressed: () => context.push(AppRoutes.createArena),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Arena'),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => ref.refresh(ownedArenasProvider.future),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  itemCount: arenas.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final arena = arenas[index];
                    return _ArenaListItem(arena: arena);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ArenaListItem extends StatelessWidget {
  const _ArenaListItem({required this.arena});

  final ArenaListing arena;

  @override
  Widget build(BuildContext context) {
    final location = _joinNonEmpty([arena.city, arena.state, arena.pincode]);
    final imageUrl = arena.photoUrls.isEmpty ? null : arena.photoUrls.first;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => context.push('${AppRoutes.arenaProfile}/${arena.id}'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 56,
                height: 56,
                child: imageUrl == null
                    ? Container(
                        color: const Color(0xFFF2F4F7),
                        child: const Icon(Icons.stadium_rounded),
                      )
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFF2F4F7),
                          child: const Icon(Icons.stadium_rounded),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    arena.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF101828),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location.isEmpty ? 'Location not set' : location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${arena.units.length} units • ${arena.openTime}-${arena.closeTime}',
                    style: const TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF98A2B3)),
          ],
        ),
      ),
    );
  }
}

class _BookingsTab extends StatelessWidget {
  const _BookingsTab();

  @override
  Widget build(BuildContext context) => const BookingsPage();
}

class _PaymentsTab extends StatelessWidget {
  const _PaymentsTab();

  @override
  Widget build(BuildContext context) => const PaymentsPage();
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: const Color(0xFFD0D5DD)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF667085),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    required this.subtitle,
    this.action,
  });

  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Expanded(child: _PageTitle(title: title, subtitle: subtitle)),
          if (action != null) action!,
        ],
      ),
    );
  }
}

class _PageTitle extends StatelessWidget {
  const _PageTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF101828),
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF667085),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({
    required this.title,
    required this.message,
    this.action,
  });

  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF101828),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF667085)),
            ),
            if (action != null) ...[
              const SizedBox(height: 16),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

String _joinNonEmpty(List<String?> values, {String separator = ', '}) {
  return values
      .where((value) => value != null && value.trim().isNotEmpty)
      .map((value) => value!.trim())
      .join(separator);
}

