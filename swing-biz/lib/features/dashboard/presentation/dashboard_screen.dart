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
final _graphRangeProvider = StateProvider<String>((ref) => 'Month');

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

final _homeYearSummaryProvider = FutureProvider.autoDispose
    .family<List<(String, int)>, String>((ref, arenaId) async {
  final repo = ref.watch(hostArenaBookingRepositoryProvider);
  final now = DateTime.now();
  final results = <(String, int)>[];
  for (int i = 5; i >= 0; i--) {
    final d = DateTime(now.year, now.month - i);
    final monthKey = '${d.year}-${d.month.toString().padLeft(2, '0')}';
    final summary = await repo.fetchMonthSummary(arenaId, monthKey);
    final total = summary.values.fold(0, (s, e) => s + e.revenuePaise);
    results.add((DateFormat('MMM').format(d), total));
  }
  return results;
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
    final pages = [const _HomeTab(), const _ArenasTab(), const _BookingsTab(), const _PaymentsTab()];
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: _BottomNav(currentIndex: _index, items: _navItems, onTap: _setIndex),
    );
  }
}

class _NavItem {
  const _NavItem(this.activeIcon, this.inactiveIcon, this.label);
  final IconData activeIcon, inactiveIcon;
  final String label;
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.items, required this.onTap});
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;
  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))]),
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, 0, 8, bottom),
        child: Row(children: List.generate(items.length, (i) => Expanded(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => onTap(i), child: _NavTile(item: items[i], selected: i == currentIndex))))),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: Colors.transparent, border: Border(top: BorderSide(color: selected ? primary : Colors.transparent, width: 2.5))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(selected ? item.activeIcon : item.inactiveIcon, size: 24, color: selected ? primary : const Color(0xFF98A2B3)), const SizedBox(height: 5), Text(item.label, style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.w800 : FontWeight.w600, color: selected ? primary : const Color(0xFF98A2B3), letterSpacing: 0.2))]),
    );
  }
}

void _showProfileSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (_) => _ProfileSheet(ref: ref));
}

class _ProfileAvatar extends ConsumerWidget {
  const _ProfileAvatar();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meProvider).valueOrNull;
    final initial = (me?.user.name ?? 'U').isNotEmpty ? (me?.user.name ?? 'U')[0].toUpperCase() : 'U';
    return Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), alignment: Alignment.center, child: Text(initial, style: const TextStyle(color: Color(0xFF101828), fontSize: 14, fontWeight: FontWeight.w800)));
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
      expand: false, initialChildSize: 0.75, minChildSize: 0.4, maxChildSize: 0.95,
      builder: (ctx, controller) => meAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (me) {
          if (me == null) return const SizedBox();
          final b = me.businessAccount;
          return ListView(
            controller: controller, padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottom),
            children: [
              Center(child: Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)))),
              Row(children: [Container(width: 52, height: 52, decoration: BoxDecoration(color: const Color(0xFF101828), borderRadius: BorderRadius.circular(26)), alignment: Alignment.center, child: Text((me.user.name ?? 'U').isNotEmpty ? me.user.name![0].toUpperCase() : 'U', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800))), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(me.user.name ?? 'User', style: const TextStyle(color: Color(0xFF101828), fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(me.user.phone, style: const TextStyle(color: Color(0xFF667085), fontSize: 13, fontWeight: FontWeight.w600))]))]),
              const SizedBox(height: 24),
              _SheetSection(title: 'Account', rows: [_SheetRow(Icons.person_outline_rounded, 'Name', me.user.name ?? 'Not set'), _SheetRow(Icons.phone_outlined, 'Phone', me.user.phone), _SheetRow(Icons.mail_outline_rounded, 'Email', me.user.email ?? 'Not set')]),
              const SizedBox(height: 16),
              _SheetSection(title: 'Business', rows: [_SheetRow(Icons.business_outlined, 'Name', b?.businessName ?? 'Not set'), _SheetRow(Icons.badge_outlined, 'Contact', b?.contactName ?? 'Not set'), _SheetRow(Icons.location_on_outlined, 'Address', b?.address ?? 'Not set'), _SheetRow(Icons.receipt_outlined, 'GST', b?.gstNumber ?? 'Not set'), _SheetRow(Icons.credit_card_outlined, 'PAN', b?.panNumber ?? 'Not set')]),
              const SizedBox(height: 24),
              _SheetActionRow(icon: Icons.switch_account_rounded, label: 'Switch Profile', onTap: () { Navigator.pop(context); context.push(AppRoutes.roleSelection); }),
              const SizedBox(height: 8),
              _SheetActionRow(icon: Icons.logout_rounded, label: 'Logout', destructive: true, onTap: () => widgetRef.read(sessionControllerProvider.notifier).signOut()),
            ],
          );
        },
      ),
    );
  }
}

class _SheetSection extends StatelessWidget {
  const _SheetSection({required this.title, required this.rows});
  final String title; final List<_SheetRow> rows;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF98A2B3), letterSpacing: 0.6)), const SizedBox(height: 8), ...rows.map((r) => _SheetRowTile(row: r))]);
}

class _SheetRow { const _SheetRow(this.icon, this.label, this.value); final IconData icon; final String label; final String value; }

class _SheetRowTile extends StatelessWidget {
  const _SheetRowTile({required this.row}); final _SheetRow row;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 9), child: Row(children: [Icon(row.icon, size: 18, color: const Color(0xFF98A2B3)), const SizedBox(width: 12), SizedBox(width: 80, child: Text(row.label, style: const TextStyle(fontSize: 13, color: Color(0xFF667085), fontWeight: FontWeight.w600))), Expanded(child: Text(row.value, style: const TextStyle(fontSize: 13, color: Color(0xFF101828), fontWeight: FontWeight.w600)))]));
}

class _SheetActionRow extends StatelessWidget {
  const _SheetActionRow({required this.icon, required this.label, required this.onTap, this.destructive = false});
  final IconData icon; final String label; final VoidCallback onTap; final bool destructive;
  @override
  Widget build(BuildContext context) {
    final color = destructive ? const Color(0xFFD92D20) : const Color(0xFF101828);
    return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Row(children: [Icon(icon, size: 20, color: color), const SizedBox(width: 12), Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color))])));
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
        final selId = ref.watch(_homeArenaProvider) ?? arenas.first.id;
        final arena = arenas.firstWhere((a) => a.id == selId, orElse: () => arenas.first);
        return _HomeDashboard(arena: arena, arenas: arenas, me: me);
      },
    );
  }
}

class _HomeSplash extends ConsumerWidget {
  const _HomeSplash({this.me}); final dynamic me;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ListView(padding: const EdgeInsets.fromLTRB(24, 24, 24, 40), children: [Row(children: [const Expanded(child: Text('Welcome!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF101828)))), GestureDetector(onTap: () => _showProfileSheet(context, ref), child: const _ProfileAvatar())]), const SizedBox(height: 60), const Icon(Icons.stadium_outlined, size: 64, color: Color(0xFFD0D5DD)), const SizedBox(height: 20), const Text('No arenas yet', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF101828))), const SizedBox(height: 8), const Text('Add your first arena to start managing bookings, payments and customers.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Color(0xFF667085))), const SizedBox(height: 28), Center(child: FilledButton.icon(onPressed: () => context.push(AppRoutes.createArena), icon: const Icon(Icons.add_rounded, size: 18), label: const Text('Add Arena'), style: FilledButton.styleFrom(backgroundColor: const Color(0xFF101828))))]);
}

// ─── Main dashboard ───────────────────────────────────────────────────────────

class _HomeDashboard extends ConsumerWidget {
  const _HomeDashboard({required this.arena, required this.arenas, this.me});
  final ArenaListing arena; final List<ArenaListing> arenas; final dynamic me;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final greeting = now.hour < 12 ? 'Good morning' : now.hour < 17 ? 'Good afternoon' : 'Good evening';
    final businessName = me?.businessAccount?.businessName ?? me?.user.name ?? 'Arena';
    final todayAsync = ref.watch(_homeTodayBookingsProvider(arena.id));
    final monthAsync = ref.watch(_homeMonthPaymentsProvider(arena.id));
    final summaryAsync = ref.watch(_homeMonthSummaryProvider(arena.id));
    final range = ref.watch(_graphRangeProvider);

    void invalidateAll() {
      ref.invalidate(_homeTodayBookingsProvider(arena.id));
      ref.invalidate(_homeMonthPaymentsProvider(arena.id));
      ref.invalidate(_homeMonthSummaryProvider(arena.id));
    }

    return RefreshIndicator(
      color: const Color(0xFF101828), onRefresh: () async => invalidateAll(),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _HeroHeader(greeting: greeting, businessName: businessName, todayAsync: todayAsync, arena: arena, arenas: arenas, ref: ref),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Row(children: [
              _QuickAction(icon: Icons.add_rounded, label: 'New Booking', accent: true, onTap: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))), builder: (_) => AddBookingSheet(arena: arena, date: now)).then((_) => invalidateAll())),
              const SizedBox(width: 12),
              _QuickAction(icon: Icons.account_balance_wallet_outlined, label: 'Record Payment', onTap: () => context.findAncestorStateOfType<_DashboardScreenState>()?._setIndex(3)),
            ]),
          ),
          const SizedBox(height: 32),
          _RangePicker(selected: range, onSelect: (v) => ref.read(_graphRangeProvider.notifier).state = v),
          const SizedBox(height: 16),
          _ProRevenueChart(range: range, arenaId: arena.id, now: now),
          _buildBreakdown(range, todayAsync, monthAsync),
          if (range == 'Today')
            todayAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (bookings) {
                final nowMins = now.hour * 60 + now.minute;
                final active = bookings.where((b) => b.status != 'CANCELLED').toList();
                final inProgress = active.where((b) => b.paidAt == null && _toMins(b.startTime) <= nowMins && _toMins(b.endTime) >= nowMins).toList();
                final upcoming = active.where((b) => b.paidAt == null && _toMins(b.startTime) > nowMins).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
                if (active.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (inProgress.isNotEmpty) ...[_SectionHeader(title: 'In progress', badge: '${inProgress.length}', badgeColor: const Color(0xFFDC2626)), const SizedBox(height: 12), ...inProgress.map((b) => _ScheduleRow(booking: b, arenaName: arena.name, arenaId: arena.id, onRefresh: invalidateAll)), const SizedBox(height: 24)],
                    if (upcoming.isNotEmpty) ...[_SectionHeader(title: 'Upcoming today', badge: '${upcoming.length}', onSeeAll: () => context.findAncestorStateOfType<_DashboardScreenState>()?._setIndex(2)), const SizedBox(height: 12), ...upcoming.take(4).map((b) => _ScheduleRow(booking: b, arenaName: arena.name, arenaId: arena.id, onRefresh: invalidateAll))],
                  ]),
                );
              },
            ),
          _buildPerformance(range, todayAsync, monthAsync),
        ],
      ),
    );
  }

  Widget _buildBreakdown(String range, AsyncValue<List<ArenaReservation>> todayAsync, AsyncValue<ArenaPaymentsData> monthAsync) {
    if (range == 'Year') return const SizedBox.shrink();
    final bookingsAsync = range == 'Today' ? todayAsync : monthAsync.whenData((p) => [...p.checkedInBookings, ...p.pendingBookings]);
    return bookingsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (bookings) {
        final active = bookings.where((b) => b.status != 'CANCELLED').toList();
        if (active.isEmpty) return const SizedBox.shrink();
        return Padding(padding: const EdgeInsets.fromLTRB(20, 32, 20, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_SectionHeader(title: '${range.toUpperCase()} BREAKDOWN'), const SizedBox(height: 16), _TodayBreakdownChart(bookings: active)]));
      },
    );
  }

  Widget _buildPerformance(String range, AsyncValue<List<ArenaReservation>> todayAsync, AsyncValue<ArenaPaymentsData> monthAsync) {
    final bookingsAsync = range == 'Today' ? todayAsync : monthAsync.whenData((p) => [...p.checkedInBookings, ...p.pendingBookings]);
    return bookingsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (bookings) {
        final totalBookings = bookings.length;
        if (totalBookings == 0) return const SizedBox.shrink();
        final totalPaise = bookings.fold(0, (s, b) => s + b.totalAmountPaise);
        final collectedPaise = bookings.fold(0, (s, b) => s + (b.paidAt != null ? b.totalAmountPaise : b.advancePaise));
        final balancePaise = bookings.fold(0, (s, b) => s + (b.paidAt != null ? 0 : (b.totalAmountPaise - b.advancePaise)));
        final percent = totalPaise > 0 ? (collectedPaise / totalPaise) : 0.0;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
          child: Container(
            padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: const Color(0xFF101828), borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: const Color(0xFF101828).withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${range.toUpperCase()} PERFORMANCE', style: const TextStyle(color: Color(0xFF98A2B3), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.0)), Text('${(percent * 100).toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900))]),
              const SizedBox(height: 12), ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: percent, minHeight: 6, backgroundColor: Colors.white.withValues(alpha: 0.1), valueColor: const AlwaysStoppedAnimation(Color(0xFF059669)))),
              const SizedBox(height: 24), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_MonthStat(label: 'COLLECTED', value: '₹${_compactRupees(collectedPaise)}', color: const Color(0xFF059669)), _MonthStat(label: 'PENDING', value: '₹${_compactRupees(balancePaise)}', color: const Color(0xFFDC2626)), _MonthStat(label: 'BOOKINGS', value: '$totalBookings', color: Colors.white)]),
            ]),
          ),
        );
      },
    );
  }
}

// ─── Hero header ──────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.greeting, required this.businessName, required this.todayAsync, required this.arena, required this.arenas, required this.ref});
  final String greeting, businessName; final AsyncValue<List<ArenaReservation>> todayAsync; final ArenaListing arena; final List<ArenaListing> arenas; final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now(); final dateStr = DateFormat('EEEE, d MMMM').format(now);
    final active = todayAsync.valueOrNull?.where((b) => b.status != 'CANCELLED').toList() ?? [];
    final col = active.fold(0, (s, b) => s + (b.paidAt != null ? b.totalAmountPaise : b.advancePaise));
    final bal = active.fold(0, (s, b) => s + (b.paidAt != null ? 0 : (b.totalAmountPaise - b.advancePaise)));
    final cash = active.where((b) => b.isPaid && b.paymentMode == 'CASH').fold(0, (s, b) => s + b.totalAmountPaise);
    final upi = active.where((b) => b.isPaid && b.paymentMode == 'UPI').fold(0, (s, b) => s + b.totalAmountPaise);
    final online = active.where((b) => b.isPaid && b.paymentMode == 'ONLINE').fold(0, (s, b) => s + b.totalAmountPaise);

    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 24),
      decoration: const BoxDecoration(color: Color(0xFF101828), borderRadius: BorderRadius.vertical(bottom: Radius.circular(32))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(greeting, style: const TextStyle(fontSize: 12, color: Color(0xFF98A2B3), fontWeight: FontWeight.w600)), Text(businessName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white))]), Row(children: [GestureDetector(onTap: () {}, child: Container(width: 38, height: 38, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.notifications_outlined, size: 20, color: Colors.white))), const SizedBox(width: 10), GestureDetector(onTap: () => _showProfileSheet(context, ref), child: Container(width: 38, height: 38, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), alignment: Alignment.center, child: const _ProfileAvatar()))])]),
        if (arenas.length > 1) ...[const SizedBox(height: 20), SizedBox(height: 32, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: arenas.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (_, i) { final a = arenas[i]; final sel = a.id == arena.id; return GestureDetector(onTap: () => ref.read(_homeArenaProvider.notifier).state = a.id, child: AnimatedContainer(duration: const Duration(milliseconds: 150), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: sel ? Colors.white : Colors.white.withAlpha(20), borderRadius: BorderRadius.circular(12)), child: Text(a.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: sel ? const Color(0xFF101828) : Colors.white70)))); }))],
        const SizedBox(height: 28),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('₹${_compactRupees(col)}', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1.5)), const SizedBox(height: 4), const Text('COLLECTED TODAY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF059669), letterSpacing: 1.0))]), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [_StatBadge(label: '₹${_compactRupees(bal)} DUE', color: const Color(0xFFFDA29B), large: true), const SizedBox(height: 8), GestureDetector(onTap: () => context.findAncestorStateOfType<_DashboardScreenState>()?._setIndex(2), child: _StatBadge(label: 'Today booking - ${active.length}', color: Colors.white, large: true))])]),
        const SizedBox(height: 24), Text(dateStr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF667085), letterSpacing: 0.5)),
        const SizedBox(height: 24), const Divider(color: Colors.white10), const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_MiniMode(label: 'CASH', value: _compactRupees(cash), color: Colors.blue), _MiniMode(label: 'UPI', value: _compactRupees(upi), color: const Color(0xFF6366F1)), _MiniMode(label: 'ONLINE', value: _compactRupees(online), color: const Color(0xFF059669))]),
      ]),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.label, required this.color, this.large = false}); 
  final String label; final Color color; final bool large;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: large ? 14 : 10, vertical: large ? 8 : 6), 
    decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(large ? 10 : 8), border: Border.all(color: color.withValues(alpha: 0.1))), 
    child: Text(label, style: TextStyle(fontSize: large ? 13 : 10, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.3))
  );
}

class _MiniMode extends StatelessWidget {
  const _MiniMode({required this.label, required this.value, required this.color}); final String label, value; final Color color;
  @override
  Widget build(BuildContext context) => Row(children: [Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 6), Text(label, style: const TextStyle(color: Color(0xFF98A2B3), fontSize: 9, fontWeight: FontWeight.w700)), const SizedBox(width: 4), Text('₹$value', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800))]);
}

class _RangePicker extends StatelessWidget {
  const _RangePicker({required this.selected, required this.onSelect}); final String selected; final ValueChanged<String> onSelect;
  @override
  Widget build(BuildContext context) {
    const options = ['Today', 'Month', 'Year'];
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(children: options.map((o) { final isSel = o == selected; return GestureDetector(onTap: () => onSelect(o), child: AnimatedContainer(duration: const Duration(milliseconds: 200), margin: const EdgeInsets.only(right: 12), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: isSel ? const Color(0xFF101828) : const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12), border: Border.all(color: isSel ? const Color(0xFF101828) : const Color(0xFFE5E7EB))), child: Text(o, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: isSel ? Colors.white : const Color(0xFF667085))))); }).toList()));
  }
}

class _ProRevenueChart extends ConsumerWidget {
  const _ProRevenueChart({required this.range, required this.arenaId, required this.now}); final String range, arenaId; final DateTime now;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (range == 'Today') {
      final todayAsync = ref.watch(_homeTodayBookingsProvider(arenaId));
      return todayAsync.when(loading: () => const _ChartSkeleton(), error: (_, __) => const SizedBox.shrink(), data: (bookings) {
        final hourlyData = <int, double>{}; for (int i = 6; i <= 22; i++) hourlyData[i] = 0;
        for (final b in bookings.where((b) => b.status != 'CANCELLED')) { final startH = int.tryParse(b.startTime.split(':').first) ?? 0; if (startH >= 6 && startH <= 22) { hourlyData[startH] = (hourlyData[startH] ?? 0) + (b.paidAt != null ? b.totalAmountPaise : b.advancePaise).toDouble(); } }
        return _BaseBarChart(spots: hourlyData.entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(), xLabels: {6: '6am', 12: '12pm', 18: '6pm', 22: '10pm'}, maxYScale: 1.3);
      });
    } else if (range == 'Year') {
      final yearAsync = ref.watch(_homeYearSummaryProvider(arenaId));
      return yearAsync.when(loading: () => const _ChartSkeleton(), error: (_, __) => const SizedBox.shrink(), data: (results) {
        return _BaseBarChart(spots: List.generate(results.length, (i) => FlSpot(i.toDouble(), results[i].$2.toDouble())), xLabels: {for (int i = 0; i < results.length; i++) i: results[i].$1}, maxYScale: 1.2);
      });
    } else {
      final summaryAsync = ref.watch(_homeMonthSummaryProvider(arenaId));
      return summaryAsync.when(loading: () => const _ChartSkeleton(), error: (_, __) => const SizedBox.shrink(), data: (summary) {
        final days = List.generate(14, (i) => now.subtract(Duration(days: 13 - i)));
        final spots = List.generate(days.length, (i) => FlSpot(i.toDouble(), (summary[DateFormat('yyyy-MM-dd').format(days[i])]?.revenuePaise ?? 0).toDouble()));
        return _BaseBarChart(spots: spots, xLabels: {0: DateFormat('d MMM').format(days.first), 7: DateFormat('d').format(days[7]), 13: 'Today'}, maxYScale: 1.2);
      });
    }
  }
}

class _BaseBarChart extends StatelessWidget {
  const _BaseBarChart({required this.spots, required this.xLabels, this.maxYScale = 1.2}); final List<FlSpot> spots; final Map<int, String> xLabels; final double maxYScale;
  @override
  Widget build(BuildContext context) {
    final maxVal = spots.isEmpty ? 0.0 : spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final maxY = maxVal == 0 ? 5000.0 : (maxVal * maxYScale).ceilToDouble();
    return SizedBox(height: 200, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: BarChart(BarChartData(maxY: maxY, minY: 0, barTouchData: BarTouchData(touchTooltipData: BarTouchTooltipData(getTooltipColor: (_) => const Color(0xFF101828), getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem('₹${_compactRupees(rod.toY.round())}', const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)))), gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFFF2F4F7), strokeWidth: 1)), titlesData: FlTitlesData(leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22, getTitlesWidget: (value, meta) { final label = xLabels[value.toInt()]; if (label == null) return const SizedBox.shrink(); return Padding(padding: const EdgeInsets.only(top: 8), child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF98A2B3)))); }))), borderData: FlBorderData(show: false), barGroups: spots.map((s) => BarChartGroupData(x: s.x.toInt(), barRods: [BarChartRodData(toY: s.y, color: const Color(0xFF059669), width: 14, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)), backDrawRodData: BackgroundBarChartRodData(show: true, toY: maxY, color: const Color(0xFFF9FAFB)))] )).toList()))));
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.badge, this.badgeColor, this.onSeeAll}); final String title; final String? badge; final Color? badgeColor; final VoidCallback? onSeeAll;
  @override
  Widget build(BuildContext context) => Row(children: [Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF101828))), if (badge != null) ...[const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: (badgeColor ?? const Color(0xFF667085)).withAlpha(25), borderRadius: BorderRadius.circular(10)), child: Text(badge!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: badgeColor ?? const Color(0xFF667085))))], const Spacer(), if (onSeeAll != null) GestureDetector(onTap: onSeeAll, child: const Text('See all', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF98A2B3))))]);
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap, this.accent = false}); final IconData icon; final String label; final VoidCallback onTap; final bool accent;
  @override
  Widget build(BuildContext context) => Expanded(child: GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: accent ? const Color(0xFF101828) : const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12), border: accent ? null : Border.all(color: const Color(0xFFE5E7EB))), child: Column(children: [Icon(icon, size: 22, color: accent ? Colors.white : const Color(0xFF101828)), const SizedBox(height: 6), Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: accent ? Colors.white : const Color(0xFF344054)))]))));
}

class _ScheduleRow extends ConsumerWidget {
  const _ScheduleRow({required this.booking, required this.arenaName, required this.arenaId, required this.onRefresh}); final ArenaReservation booking; final String arenaName, arenaId; final VoidCallback onRefresh;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPaid = booking.isPaid; final statusColor = isPaid ? const Color(0xFF059669) : const Color(0xFFDC2626); final statusLabel = isPaid ? 'Paid' : 'Unpaid'; final balance = booking.totalAmountPaise - booking.advancePaise;
    return GestureDetector(onTap: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))), builder: (_) => BookingDetailSheet(booking: booking, arenaName: arenaName, arenaId: arenaId)).then((_) => onRefresh()), child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isPaid ? const Color(0xFFE5E7EB) : const Color(0xFFFEE2E2)), boxShadow: const [BoxShadow(color: Color(0x03000000), blurRadius: 10, offset: Offset(0, 4))]), child: Row(children: [SizedBox(width: 54, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(booking.startTime, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF101828))), Text(booking.endTime, style: const TextStyle(fontSize: 11, color: Color(0xFF98A2B3), fontWeight: FontWeight.w700))])), Container(width: 1, height: 32, color: const Color(0xFFE5E7EB), margin: const EdgeInsets.symmetric(horizontal: 16)), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(booking.displayName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF101828))), const SizedBox(height: 2), Text(booking.unitName ?? '—', style: const TextStyle(fontSize: 12, color: Color(0xFF667085), fontWeight: FontWeight.w600))])), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('₹${((isPaid ? booking.totalAmountPaise : balance) / 100).toStringAsFixed(0)}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: isPaid ? const Color(0xFF101828) : const Color(0xFFDC2626))), const SizedBox(height: 4), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)), child: Text(statusLabel, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: statusColor, letterSpacing: 0.5)))])])));
  }
}

class _MonthStat extends StatelessWidget {
  const _MonthStat({required this.label, required this.value, required this.color}); final String label, value; final Color color;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF98A2B3), fontWeight: FontWeight.w700, letterSpacing: 0.5)), const SizedBox(height: 4), Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color))]);
}

class _TodayBreakdownChart extends StatelessWidget {
  const _TodayBreakdownChart({required this.bookings}); final List<ArenaReservation> bookings;
  @override
  Widget build(BuildContext context) {
    final unitStats = <String, (int, int)>{}; for (final b in bookings) { final unit = b.unitName ?? 'General'; final current = unitStats[unit] ?? (0, 0); unitStats[unit] = (current.$1 + 1, current.$2 + (b.paidAt != null ? b.totalAmountPaise : b.advancePaise)); }
    final sorted = unitStats.entries.toList()..sort((a, b) => b.value.$1.compareTo(a.value.$1));
    return Column(children: sorted.map((entry) {
      final unit = entry.key; final count = entry.value.$1; final rev = entry.value.$2; final pct = (count / bookings.length) * 100;
      return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))), child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF101828), borderRadius: BorderRadius.circular(10)), alignment: Alignment.center, child: const Icon(Icons.sports_cricket_rounded, color: Colors.white, size: 20)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(unit.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF101828), letterSpacing: 0.5)), const SizedBox(height: 2), Text('$count Booking${count == 1 ? '' : 's'} · ${pct.toStringAsFixed(0)}% of total', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF667085)))] )), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('₹${_compactRupees(rev)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF059669))), const Text('COLLECTED', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF98A2B3), letterSpacing: 0.5))])]));
    }).toList());
  }
}

class _ChartSkeleton extends StatelessWidget {
  const _ChartSkeleton();
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Container(height: 180, decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12))));
}

String _compactRupees(int paise) {
  final r = paise / 100; if (r >= 100000) return '${(r / 100000).toStringAsFixed(1)}L'; if (r >= 1000) return '${(r / 1000).toStringAsFixed(1)}k'; return r.toStringAsFixed(0);
}

class _ArenasTab extends ConsumerWidget {
  const _ArenasTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arenasAsync = ref.watch(ownedArenasProvider);
    return Column(children: [_PageHeader(title: 'Arenas', subtitle: 'Manage venues, photos, facilities and booking rules.', action: FilledButton.icon(onPressed: () => context.push(AppRoutes.createArena), icon: const Icon(Icons.add_rounded, size: 18), label: const Text('Add Arena'))), Expanded(child: arenasAsync.when(loading: () => const Center(child: CircularProgressIndicator()), error: (e, _) => _CenteredMessage(title: 'Could not load arenas', message: '$e'), data: (arenas) { if (arenas.isEmpty) return _CenteredMessage(title: 'No arenas yet', message: 'Add your first arena to start managing bookings.', action: FilledButton.icon(onPressed: () => context.push(AppRoutes.createArena), icon: const Icon(Icons.add_rounded, size: 18), label: const Text('Add Arena'))); return RefreshIndicator(onRefresh: () async => ref.refresh(ownedArenasProvider.future), child: ListView.separated(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), itemCount: arenas.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (context, index) => _ArenaListItem(arena: arenas[index]))); }))]);
  }
}

class _ArenaListItem extends StatelessWidget {
  const _ArenaListItem({required this.arena}); final ArenaListing arena;
  @override
  Widget build(BuildContext context) {
    final loc = _joinNonEmpty([arena.city, arena.state, arena.pincode]); final url = arena.photoUrls.isEmpty ? null : arena.photoUrls.first;
    return InkWell(borderRadius: BorderRadius.circular(8), onTap: () => context.push('${AppRoutes.arenaProfile}/${arena.id}'), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE5E7EB))), child: Row(children: [ClipRRect(borderRadius: BorderRadius.circular(6), child: SizedBox(width: 56, height: 56, child: url == null ? Container(color: const Color(0xFFF2F4F7), child: const Icon(Icons.stadium_rounded)) : Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFFF2F4F7), child: const Icon(Icons.stadium_rounded))))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(arena.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF101828), fontSize: 15, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(loc.isEmpty ? 'Location not set' : loc, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF667085), fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 6), Text('${arena.units.length} units • ${arena.openTime}-${arena.closeTime}', style: const TextStyle(color: Color(0xFF667085), fontSize: 12, fontWeight: FontWeight.w500))])), const Icon(Icons.chevron_right_rounded, color: Color(0xFF98A2B3))])));
  }
}

class _BookingsTab extends StatelessWidget { const _BookingsTab(); @override Widget build(BuildContext context) => const BookingsPage(); }
class _PaymentsTab extends StatelessWidget { const _PaymentsTab(); @override Widget build(BuildContext context) => const PaymentsPage(); }

class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.icon, required this.title, required this.subtitle}); final IconData icon; final String title, subtitle;
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(40), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 48, color: const Color(0xFFD0D5DD)), const SizedBox(height: 16), Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF101828))), const SizedBox(height: 8), Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Color(0xFF667085), fontWeight: FontWeight.w500))])));
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title, required this.subtitle, this.action}); final String title, subtitle; final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 12), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Color(0xFF101828), fontSize: 22, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: Color(0xFF667085), fontSize: 13, fontWeight: FontWeight.w600))])), if (action != null) action!]));
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({required this.title, required this.message, this.action}); final String title, message; final Widget? action;
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF101828), fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 8), Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF667085))), if (action != null) ...[const SizedBox(height: 16), action!]])));
}

String _joinNonEmpty(List<String?> v, {String s = ', '}) => v.where((x) => x != null && x.trim().isNotEmpty).map((x) => x!.trim()).join(s);
int _toMins(String t) { try { final p = t.split(':').map(int.parse).toList(); return p[0] * 60 + p[1]; } catch (_) { return 0; } }

class _EmptyArenas extends StatelessWidget {
  const _EmptyArenas();
  @override
  Widget build(BuildContext context) => const Center(child: Text('No arenas found.'));
}
