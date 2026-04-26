import 'package:fl_chart/fl_chart.dart';
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

// ─── Home tab providers ───────────────────────────────────────────────────────

final _homeArenaProvider = StateProvider<String?>((ref) => null);

final _homeTodayBookingsProvider = FutureProvider.autoDispose
    .family<List<ArenaReservation>, String>((ref, arenaId) async {
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  return ref.watch(hostArenaBookingRepositoryProvider)
      .listArenaBookings(arenaId, date: today);
});

final _homeMonthPaymentsProvider = FutureProvider.autoDispose
    .family<ArenaPaymentsData, String>((ref, arenaId) async {
  final now = DateTime.now();
  final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
  return ref.watch(hostArenaBookingRepositoryProvider)
      .fetchArenaPayments(arenaId, month: month);
});

final _homeMonthSummaryProvider = FutureProvider.autoDispose
    .family<Map<String, ArenaDaySummary>, String>((ref, arenaId) async {
  final now = DateTime.now();
  final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
  return ref.watch(hostArenaBookingRepositoryProvider)
      .fetchMonthSummary(arenaId, month);
});

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _index = 0;

  void _setIndex(int i) => setState(() => _index = i);

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
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, 0, 8, bottom),
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
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.item, required this.selected});

  final _NavItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    const inactive = Color(0xFF98A2B3);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          top: BorderSide(
            color: selected ? primary : Colors.transparent,
            width: 2.5,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            selected ? item.activeIcon : item.inactiveIcon,
            size: 24,
            color: selected ? primary : inactive,
          ),
          const SizedBox(height: 5),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected ? primary : inactive,
              letterSpacing: 0.2,
            ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Color(0xFF101828),
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
    final arenasAsync = ref.watch(ownedArenasProvider);
    final me = ref.watch(meProvider).valueOrNull;

    return arenasAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (e, _) => Center(child: Text('$e')),
      data: (arenas) {
        if (arenas.isEmpty) return _HomeSplash(me: me);
        final selectedId = ref.watch(_homeArenaProvider) ?? arenas.first.id;
        final arena = arenas.firstWhere((a) => a.id == selectedId, orElse: () => arenas.first);
        return _HomeDashboard(arena: arena, arenas: arenas, me: me);
      },
    );
  }
}

// ─── No arena splash ─────────────────────────────────────────────────────────

class _HomeSplash extends ConsumerWidget {
  const _HomeSplash({this.me});
  final dynamic me;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Welcome!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF101828)),
              ),
            ),
            GestureDetector(
              onTap: () => _showProfileSheet(context, ref),
              child: const _ProfileAvatar(),
            ),
          ],
        ),
        const SizedBox(height: 60),
        const Icon(Icons.stadium_outlined, size: 64, color: Color(0xFFD0D5DD)),
        const SizedBox(height: 20),
        const Text('No arenas yet', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF101828))),
        const SizedBox(height: 8),
        const Text('Add your first arena to start managing bookings, payments and customers.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF667085))),
        const SizedBox(height: 28),
        Center(
          child: FilledButton.icon(
            onPressed: () => context.push(AppRoutes.createArena),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Arena'),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF101828)),
          ),
        ),
      ],
    );
  }
}

// ─── Main dashboard ───────────────────────────────────────────────────────────

class _HomeDashboard extends ConsumerWidget {
  const _HomeDashboard({required this.arena, required this.arenas, this.me});
  final ArenaListing arena;
  final List<ArenaListing> arenas;
  final dynamic me;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final greeting = now.hour < 12 ? 'Good morning' : now.hour < 17 ? 'Good afternoon' : 'Good evening';
    final businessName = me?.businessAccount?.businessName ?? me?.user.name ?? 'Arena';

    final todayAsync = ref.watch(_homeTodayBookingsProvider(arena.id));
    final monthAsync = ref.watch(_homeMonthPaymentsProvider(arena.id));
    final summaryAsync = ref.watch(_homeMonthSummaryProvider(arena.id));

    void invalidateAll() {
      ref.invalidate(_homeTodayBookingsProvider(arena.id));
      ref.invalidate(_homeMonthPaymentsProvider(arena.id));
      ref.invalidate(_homeMonthSummaryProvider(arena.id));
    }

    return RefreshIndicator(
      color: const Color(0xFF101828),
      onRefresh: () async => invalidateAll(),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [

          // ── Dark hero header ──────────────────────────────────────────────
          _HeroHeader(
            greeting: greeting,
            businessName: businessName,
            todayAsync: todayAsync,
            arena: arena,
            arenas: arenas,
            ref: ref,
          ),

          // ── Quick actions ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Row(children: [
              _QuickAction(
                icon: Icons.add_rounded,
                label: 'New Booking',
                accent: true,
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  builder: (_) => AddBookingSheet(arena: arena, date: now),
                ).then((_) => invalidateAll()),
              ),
              const SizedBox(width: 10),
              _QuickAction(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Payments',
                onTap: () => context.findAncestorStateOfType<_DashboardScreenState>()?._setIndex(3),
              ),
              const SizedBox(width: 10),
              _QuickAction(
                icon: Icons.stadium_outlined,
                label: 'Manage',
                onTap: () => context.push('${AppRoutes.arenaProfile}/${arena.id}'),
              ),
            ]),
          ),

          // ── Revenue chart ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
            child: Row(children: [
              const Expanded(
                child: Text('Estimated revenue',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF101828))),
              ),
              summaryAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (summary) {
                  final total = summary.values.fold(0, (s, d) => s + d.revenuePaise);
                  return Text('₹${_compactRupees(total)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF059669)));
                },
              ),
            ]),
          ),
          const SizedBox(height: 12),
          summaryAsync.when(
            loading: () => const _ChartSkeleton(),
            error: (_, __) => const SizedBox.shrink(),
            data: (summary) => _RevenueBarChart(summary: summary, now: now),
          ),

          // ── Today's schedule ──────────────────────────────────────────────
          todayAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (bookings) {
              final nowMins = now.hour * 60 + now.minute;
              final active = bookings.where((b) => b.status != 'CANCELLED').toList();
              final inProgress = active.where((b) => b.checkedInAt != null).toList();
              final upcoming = active
                  .where((b) => b.checkedInAt == null)
                  .where((b) {
                    final p = b.startTime.split(':');
                    if (p.length < 2) return true;
                    return (int.tryParse(p[0])! * 60 + int.tryParse(p[1])!) >= nowMins;
                  })
                  .toList()
                ..sort((a, b) => a.startTime.compareTo(b.startTime));

              if (active.isEmpty) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (inProgress.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'In progress',
                      badge: '${inProgress.length}',
                      badgeColor: const Color(0xFF059669),
                    ),
                    const SizedBox(height: 10),
                    ...inProgress.take(3).map((b) => _ScheduleRow(
                      booking: b, arenaId: arena.id, onRefresh: invalidateAll)),
                    const SizedBox(height: 20),
                  ],
                  if (upcoming.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'Upcoming today',
                      badge: '${upcoming.length}',
                      onSeeAll: () => context.findAncestorStateOfType<_DashboardScreenState>()?._setIndex(2),
                    ),
                    const SizedBox(height: 10),
                    ...upcoming.take(4).map((b) => _ScheduleRow(
                      booking: b, arenaId: arena.id, onRefresh: invalidateAll)),
                  ],
                ]),
              );
            },
          ),

          // ── Month summary strip ───────────────────────────────────────────
          monthAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (data) {
              final totalBookings = data.checkedInBookings.length + data.pendingBookings.length;
              if (totalBookings == 0 && data.totalCollectedPaise == 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('This month',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF101828))),
                  const SizedBox(height: 12),
                  Row(children: [
                    _MiniStatCard(
                      label: 'Collected',
                      value: '₹${_compactRupees(data.totalCollectedPaise)}',
                      icon: Icons.check_circle_outline_rounded,
                      color: const Color(0xFF059669),
                      bg: const Color(0xFFF0FDF4),
                    ),
                    const SizedBox(width: 10),
                    _MiniStatCard(
                      label: 'Balance',
                      value: '₹${_compactRupees(data.totalBalancePaise)}',
                      icon: Icons.pending_outlined,
                      color: const Color(0xFFDC2626),
                      bg: const Color(0xFFFEF2F2),
                    ),
                    const SizedBox(width: 10),
                    _MiniStatCard(
                      label: 'Bookings',
                      value: '$totalBookings',
                      icon: Icons.book_online_rounded,
                      color: const Color(0xFF101828),
                      bg: const Color(0xFFF9FAFB),
                    ),
                  ]),
                ]),
              );
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─── Hero header ──────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.greeting,
    required this.businessName,
    required this.todayAsync,
    required this.arena,
    required this.arenas,
    required this.ref,
  });
  final String greeting;
  final String businessName;
  final AsyncValue<List<ArenaReservation>> todayAsync;
  final ArenaListing arena;
  final List<ArenaListing> arenas;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEE, d MMM').format(now);

    final todayRevenue = todayAsync.valueOrNull
        ?.where((b) => b.status != 'CANCELLED')
        .fold(0, (s, b) => s + b.totalAmountPaise) ?? 0;
    final checkedInCount = todayAsync.valueOrNull
        ?.where((b) => b.checkedInAt != null).length ?? 0;
    final totalCount = todayAsync.valueOrNull
        ?.where((b) => b.status != 'CANCELLED').length ?? 0;

    return Container(
      color: const Color(0xFF101828),
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting row
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(greeting,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(businessName,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
              ]),
            ),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.notifications_outlined, size: 20, color: Color(0xFF101828)),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _showProfileSheet(context, ref),
              child: const _ProfileAvatar(),
            ),
          ]),

          // Arena picker chips
          if (arenas.length > 1) ...[
            const SizedBox(height: 14),
            SizedBox(
              height: 30,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: arenas.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final a = arenas[i];
                  final sel = a.id == arena.id;
                  return GestureDetector(
                    onTap: () => ref.read(_homeArenaProvider.notifier).state = a.id,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: sel ? Colors.white : Colors.white.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(a.name,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                              color: sel ? const Color(0xFF101828) : Colors.white70)),
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Revenue hero number
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("Today's revenue",
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('₹${_compactRupees(todayRevenue)}',
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white,
                        letterSpacing: -1)),
              ]),
            ),
            Text(dateStr,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
          ]),

          const SizedBox(height: 16),

          // Stat chips row
          Row(children: [
            _HeroChip(label: '$totalCount bookings', icon: Icons.calendar_today_rounded),
            const SizedBox(width: 8),
            _HeroChip(label: '$checkedInCount checked in', icon: Icons.check_circle_outline_rounded,
                color: const Color(0xFF059669)),
            const SizedBox(width: 8),
            _HeroChip(label: '${totalCount - checkedInCount} pending',
                icon: Icons.schedule_rounded, color: const Color(0xFFD97706)),
          ]),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.label, required this.icon, this.color = const Color(0xFF9CA3AF)});
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withAlpha(15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: color),
      const SizedBox(width: 5),
      Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    ]),
  );
}

// ─── Revenue bar chart ────────────────────────────────────────────────────────

class _RevenueBarChart extends StatelessWidget {
  const _RevenueBarChart({required this.summary, required this.now});
  final Map<String, ArenaDaySummary> summary;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    // Build last 14 days
    final days = List.generate(14, (i) => now.subtract(Duration(days: 13 - i)));
    final maxRevenue = days
        .map((d) => summary[DateFormat('yyyy-MM-dd').format(d)]?.revenuePaise ?? 0)
        .fold(0, (a, b) => a > b ? a : b)
        .toDouble();
    final maxY = maxRevenue == 0 ? 5000.0 : (maxRevenue * 1.25).ceilToDouble();

    return SizedBox(
      height: 180,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: BarChart(
          BarChartData(
            maxY: maxY,
            minY: 0,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => const Color(0xFF101828),
                tooltipRoundedRadius: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final day = days[group.x];
                  return BarTooltipItem(
                    '${DateFormat('d MMM').format(day)}\n₹${_compactRupees(rod.toY.round())}',
                    const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx < 0 || idx >= days.length) return const SizedBox.shrink();
                    final day = days[idx];
                    // Only show label every other day to avoid crowding
                    if (idx % 2 != 0 && idx != days.length - 1) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        DateFormat('d').format(day),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _isToday(day) ? const Color(0xFF101828) : const Color(0xFFD1D5DB),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxY / 4,
              getDrawingHorizontalLine: (_) => const FlLine(
                color: Color(0xFFF3F4F6),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(days.length, (i) {
              final day = days[i];
              final key = DateFormat('yyyy-MM-dd').format(day);
              final rev = (summary[key]?.revenuePaise ?? 0).toDouble();
              final isToday = _isToday(day);
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: rev,
                    color: isToday
                        ? const Color(0xFF101828)
                        : rev > 0
                            ? const Color(0xFF6EE7B7)
                            : const Color(0xFFF3F4F6),
                    width: 14,
                    borderRadius: BorderRadius.circular(4),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxY,
                      color: const Color(0xFFF9FAFB),
                    ),
                  ),
                ],
              );
            }),
          ),
          swapAnimationDuration: const Duration(milliseconds: 400),
          swapAnimationCurve: Curves.easeOutCubic,
        ),
      ),
    );
  }

  bool _isToday(DateTime d) =>
      d.year == now.year && d.month == now.month && d.day == now.day;
}

// ─── Home widgets ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.badge, this.badgeColor, this.onSeeAll});
  final String title;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) => Row(children: [
    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF101828))),
    if (badge != null) ...[
      const SizedBox(width: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: (badgeColor ?? const Color(0xFF667085)).withAlpha(25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(badge!,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                color: badgeColor ?? const Color(0xFF667085))),
      ),
    ],
    const Spacer(),
    if (onSeeAll != null)
      GestureDetector(
        onTap: onSeeAll,
        child: const Text('See all',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF98A2B3))),
      ),
  ]);
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap, this.accent = false});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: accent ? const Color(0xFF101828) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: accent ? null : Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(children: [
          Icon(icon, size: 22, color: accent ? Colors.white : const Color(0xFF101828)),
          const SizedBox(height: 6),
          Text(label, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                  color: accent ? Colors.white : const Color(0xFF344054))),
        ]),
      ),
    ),
  );
}

class _ScheduleRow extends ConsumerWidget {
  const _ScheduleRow({required this.booking, required this.arenaId, required this.onRefresh});
  final ArenaReservation booking;
  final String arenaId;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCheckedIn = booking.checkedInAt != null;
    final statusColor = isCheckedIn ? const Color(0xFF059669) : const Color(0xFF667085);
    final statusLabel = isCheckedIn ? 'In progress' : 'Confirmed';

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context, isScrollControlled: true, backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => BookingDetailSheet(booking: booking, arenaId: arenaId),
      ).then((_) => onRefresh()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(children: [
          SizedBox(
            width: 52,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(booking.startTime,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF101828))),
              Text(booking.endTime,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF98A2B3), fontWeight: FontWeight.w600)),
            ]),
          ),
          Container(width: 1, height: 32, color: const Color(0xFFE5E7EB),
              margin: const EdgeInsets.symmetric(horizontal: 12)),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(booking.displayName,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF101828))),
              const SizedBox(height: 2),
              Text(booking.unitName ?? '—',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF667085))),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('₹${(booking.totalAmountPaise / 100).toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF101828))),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                  color: statusColor.withAlpha(25), borderRadius: BorderRadius.circular(6)),
              child: Text(statusLabel,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.label, required this.value, required this.icon,
    required this.color, required this.bg,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF98A2B3))),
      ]),
    ),
  );
}

class _ChartSkeleton extends StatelessWidget {
  const _ChartSkeleton();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      height: 180,
      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
    ),
  );
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _compactRupees(int paise) {
  final rupees = paise / 100;
  if (rupees >= 100000) return '${(rupees / 100000).toStringAsFixed(1)}L';
  if (rupees >= 1000) return '${(rupees / 1000).toStringAsFixed(1)}k';
  return rupees.toStringAsFixed(0);
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

