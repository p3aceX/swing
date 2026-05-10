import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/me_providers.dart';
import '../../../core/router/app_router.dart';
import '../../arena/screens/arena_profile_page.dart';
import '../../arena/services/arena_profile_providers.dart';
import '../../../core/notifications/notifications_screen.dart';
import '../../bookings/presentation/bookings_page.dart' as bookings;
import '../../bookings/presentation/arena_lobbies_section.dart';
import '../../bookings/presentation/arena_matches_section.dart';
import '../../bookings/presentation/matchups_tab.dart';
import '../../bookings/presentation/split_booking_sheet.dart';
import '../../payments/presentation/payments_page.dart';
import '../../play/presentation/biz_play_tab.dart';
import 'app_drawer.dart';

// ─── Dashboard tab + home providers ──────────────────────────────────────────

/// Currently-selected tab in [DashboardScreen]. Exposed so the side drawer can
/// jump directly to a tab (e.g. Payments).
final dashboardTabIndexProvider = StateProvider<int>((ref) => 0);

final _homeArenaProvider = StateProvider<String?>((ref) => null);

final _homeAllBookingsProvider = FutureProvider.autoDispose
    .family<List<ArenaReservation>, String>((ref, arenaId) async {
  return ref
      .watch(hostArenaBookingRepositoryProvider)
      .listArenaBookings(arenaId);
});

final _homeTodayAvailabilityProvider = FutureProvider.autoDispose
    .family<Map<String, List<AvailabilitySlot>>, String>((ref, arenaId) async {
  try {
    return await ref
        .watch(hostArenaBookingRepositoryProvider)
        .fetchAvailability(arenaId: arenaId, date: DateTime.now());
  } catch (_) {
    return const {};
  }
});

final _homeMonthSummaryProvider = FutureProvider.autoDispose.family<
    Map<String, ArenaDaySummary>,
    ({String arenaId, String month})>((ref, key) async {
  try {
    return await ref
        .watch(hostArenaBookingRepositoryProvider)
        .fetchMonthSummary(key.arenaId, key.month);
  } catch (_) {
    return const {};
  }
});

final _homeMonthPaymentsProvider = FutureProvider.autoDispose.family<
    ArenaPaymentsData,
    ({String arenaId, String month})>((ref, key) async {
  try {
    return await ref
        .watch(hostArenaBookingRepositoryProvider)
        .fetchArenaPayments(key.arenaId, month: key.month);
  } catch (_) {
    return const ArenaPaymentsData(
      checkedInBookings: [],
      pendingBookings: [],
    );
  }
});

AsyncValue<List<T>> _combineAsyncLists<T>(List<AsyncValue<List<T>>> values) {
  if (values.any((v) => v.isLoading)) return const AsyncValue.loading();
  final error = values.where((v) => v.hasError).firstOrNull;
  if (error != null) return AsyncValue.error(error.error!, error.stackTrace!);
  return AsyncValue.data(values.expand((v) => v.value ?? <T>[]).toList());
}

AsyncValue<ArenaPaymentsData> _combineAsyncPaymentData(
  List<AsyncValue<ArenaPaymentsData>> values,
) {
  if (values.any((v) => v.isLoading)) return const AsyncValue.loading();
  final error = values.where((v) => v.hasError).firstOrNull;
  if (error != null) return AsyncValue.error(error.error!, error.stackTrace!);
  final combined = values.fold(
    const ArenaPaymentsData(checkedInBookings: [], pendingBookings: []),
    (acc, v) {
      final data = v.value ??
          const ArenaPaymentsData(checkedInBookings: [], pendingBookings: []);
      return ArenaPaymentsData(
        checkedInBookings: [...acc.checkedInBookings, ...data.checkedInBookings],
        pendingBookings: [...acc.pendingBookings, ...data.pendingBookings],
      );
    },
  );
  return AsyncValue.data(combined);
}

AsyncValue<Map<String, ArenaDaySummary>> _combineAsyncSummaryMaps(
  List<AsyncValue<Map<String, ArenaDaySummary>>> values,
) {
  if (values.any((v) => v.isLoading)) return const AsyncValue.loading();
  final error = values.where((v) => v.hasError).firstOrNull;
  if (error != null) return AsyncValue.error(error.error!, error.stackTrace!);

  final merged = <String, ArenaDaySummary>{};
  for (final value in values) {
    final map = value.value ?? const <String, ArenaDaySummary>{};
    for (final entry in map.entries) {
      final current = merged[entry.key];
      merged[entry.key] = ArenaDaySummary(
        count: (current?.count ?? 0) + entry.value.count,
        revenuePaise: (current?.revenuePaise ?? 0) + entry.value.revenuePaise,
      );
    }
  }
  return AsyncValue.data(merged);
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const _navItems = [
    _NavItem(Icons.home_rounded, Icons.home_outlined, 'Home'),
    _NavItem(Icons.stadium_rounded, Icons.stadium_outlined, 'Arenas'),
    _NavItem(Icons.calendar_month_rounded, Icons.calendar_month_outlined,
        'Bookings'),
    _NavItem(Icons.bolt_rounded, Icons.bolt_outlined, 'Match-Up'),
    _NavItem(
        Icons.sports_cricket_rounded, Icons.sports_cricket_outlined, 'Play'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(dashboardTabIndexProvider);
    final scheme = Theme.of(context).colorScheme;
    final pages = [
      const _HomeTab(),
      const _ArenasTab(),
      const _BookingsTab(),
      const _MatchUpsTab(),
      const BizPlayTab(),
    ];
    return Scaffold(
      backgroundColor: scheme.surface,
      endDrawer: const AppDrawer(),
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: _BottomNav(
        currentIndex: index,
        items: _navItems,
        onTap: (i) =>
            ref.read(dashboardTabIndexProvider.notifier).state = i,
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.activeIcon, this.inactiveIcon, this.label);
  final IconData activeIcon, inactiveIcon;
  final String label;
}

class _BottomNav extends StatelessWidget {
  const _BottomNav(
      {required this.currentIndex, required this.items, required this.onTap});
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outline, width: 1)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, 6, 8, 6 + bottom),
        child: Row(
          children: List.generate(
            items.length,
            (i) => Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(i),
                child: _NavTile(
                  item: items[i],
                  selected: i == currentIndex,
                ),
              ),
            ),
          ),
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
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.55);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            selected ? item.activeIcon : item.inactiveIcon,
            size: 24,
            color: selected ? scheme.primary : muted,
          ),
          const SizedBox(height: 5),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected ? scheme.primary : muted,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends ConsumerWidget {
  const _ProfileAvatar();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meProvider).valueOrNull;
    final scheme = Theme.of(context).colorScheme;
    final initial = (me?.user.name ?? 'U').isNotEmpty
        ? (me?.user.name ?? 'U')[0].toUpperCase()
        : 'U';
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.primary.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: scheme.onPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ─── Home tab ────────────────────────────────────────────────────────────────

class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arenasAsync = ref.watch(ownedArenasProvider);
    final me = ref.watch(meProvider).valueOrNull;
    return arenasAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (e, _) => Center(child: Text('$e')),
      data: (arenas) {
        final businessName =
            me?.businessAccount?.businessName ?? me?.user.name ?? 'Arena';
        final selectedArenaId = ref.watch(_homeArenaProvider);
        final selectedArenas = selectedArenaId == null
            ? arenas
            : arenas.where((a) => a.id == selectedArenaId).toList();
        final allBookings = _combineAsyncLists(
          selectedArenas
              .map((a) => ref.watch(_homeAllBookingsProvider(a.id)))
              .toList(),
        );
        final now = DateTime.now();
        final currentMonthKey = DateFormat('yyyy-MM').format(now);
        final previousMonthKey = DateFormat('yyyy-MM')
            .format(DateTime(now.year, now.month - 1, 1));
        final currentMonthSummary = _combineAsyncSummaryMaps([
          ...selectedArenas.map(
            (a) => ref.watch(
              _homeMonthSummaryProvider(
                  (arenaId: a.id, month: currentMonthKey)),
            ),
          ),
        ]);
        final previousMonthSummary = _combineAsyncSummaryMaps([
          ...selectedArenas.map(
            (a) => ref.watch(
              _homeMonthSummaryProvider(
                (arenaId: a.id, month: previousMonthKey),
              ),
            ),
          ),
        ]);
        final currentMonthPayments = _combineAsyncPaymentData(
          selectedArenas
              .map(
                (a) => ref.watch(
                  _homeMonthPaymentsProvider(
                    (arenaId: a.id, month: currentMonthKey),
                  ),
                ),
              )
              .toList(),
        );
        Future<void> onRefresh() async {
          for (final a in selectedArenas) {
            ref.invalidate(_homeAllBookingsProvider(a.id));
            ref.invalidate(_homeTodayAvailabilityProvider(a.id));
            ref.invalidate(_homeMonthSummaryProvider(
                (arenaId: a.id, month: currentMonthKey)));
            ref.invalidate(_homeMonthSummaryProvider(
                (arenaId: a.id, month: previousMonthKey)));
            ref.invalidate(_homeMonthPaymentsProvider(
                (arenaId: a.id, month: currentMonthKey)));
          }
        }

        return Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              _HeroHeader(businessName: businessName, ref: ref),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: onRefresh,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _HomeArenaFilter(
                        arenas: arenas,
                        selectedArenaId: selectedArenaId,
                        onSelected: (id) =>
                            ref.read(_homeArenaProvider.notifier).state = id,
                      ),
                      const _ThinDivider(),
                      _PerformanceSection(
                        bookingsAsync: allBookings,
                        arenas: selectedArenas,
                        currentMonthSummaryAsync: currentMonthSummary,
                        previousMonthSummaryAsync: previousMonthSummary,
                        currentMonthPaymentsAsync: currentMonthPayments,
                      ),
                      SizedBox(
                        height: 116,
                        child: allBookings.when(
                          loading: () => const _RecentBookingsSkeleton(),
                          error: (_, __) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Could not load bookings',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          data: (bookings) =>
                              _RecentBookingsCarousel(bookings: bookings),
                        ),
                      ),
                      const _ThinDivider(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: _HeatmapUtilizationTabs(
                          bookingsAsync: allBookings,
                          arenas: selectedArenas,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PerformanceSection extends ConsumerStatefulWidget {
  const _PerformanceSection({
    required this.bookingsAsync,
    required this.arenas,
    required this.currentMonthSummaryAsync,
    required this.previousMonthSummaryAsync,
    required this.currentMonthPaymentsAsync,
  });
  final AsyncValue<List<ArenaReservation>> bookingsAsync;
  final List<ArenaListing> arenas;
  final AsyncValue<Map<String, ArenaDaySummary>> currentMonthSummaryAsync;
  final AsyncValue<Map<String, ArenaDaySummary>> previousMonthSummaryAsync;
  final AsyncValue<ArenaPaymentsData> currentMonthPaymentsAsync;

  @override
  ConsumerState<_PerformanceSection> createState() =>
      _PerformanceSectionState();
}

class _PerformanceSectionState extends ConsumerState<_PerformanceSection> {
  int _tab = 0; // 0=Today, 1=Month

  static int _toMin(String t) {
    final p = t.split(':');
    return (int.tryParse(p[0]) ?? 0) * 60 +
        (p.length > 1 ? (int.tryParse(p[1]) ?? 0) : 0);
  }

  List<_MonthlyKpi> _todayCells() {
    final today = DateTime.now();
    final todayKey = DateFormat('yyyy-MM-dd').format(today);
    final totalAvailMin = widget.arenas.fold(0, (sum, arena) {
      final unitCount = arena.units.length;
      if (unitCount == 0) return sum;
      final open = _toMin(arena.openTime);
      final close = _toMin(arena.closeTime);
      return sum + (close - open).clamp(0, 24 * 60) * unitCount;
    });
    final bookings = widget.bookingsAsync.valueOrNull ?? const [];
    int count = 0;
    int revenuePaise = 0;
    int mins = 0;
    for (final b in bookings) {
      final date = b.bookingDate;
      if (date == null) continue;
      final key = DateFormat('yyyy-MM-dd')
          .format(DateTime(date.year, date.month, date.day));
      if (key != todayKey) continue;
      if (!_isActiveBooking(b)) continue;
      count++;
      mins += (_toMin(b.endTime) - _toMin(b.startTime)).clamp(0, 24 * 60);
      if (_countsAsRevenue(b)) revenuePaise += b.totalAmountPaise;
    }
    final util = totalAvailMin == 0
        ? 0
        : ((mins / totalAvailMin) * 100).clamp(0, 100).round();
    return [
      _MonthlyKpi(
        value: '₹${_compactAmount(revenuePaise / 100)}',
        label: 'REVENUE',
      ),
      _MonthlyKpi(value: '$count', label: 'BOOKINGS'),
      _MonthlyKpi(value: '$util%', label: 'UTIL'),
    ];
  }

  List<_MonthlyKpi> _monthCells() {
    final currentSummary = widget.currentMonthSummaryAsync.valueOrNull ?? const {};
    final previousSummary =
        widget.previousMonthSummaryAsync.valueOrNull ?? const {};
    final payments = widget.currentMonthPaymentsAsync.valueOrNull ??
        const ArenaPaymentsData(checkedInBookings: [], pendingBookings: []);
    final count = currentSummary.values.fold<int>(0, (s, d) => s + d.count);
    final revenuePaise =
        currentSummary.values.fold<int>(0, (s, d) => s + d.revenuePaise);
    final prevRevenuePaise =
        previousSummary.values.fold<int>(0, (s, d) => s + d.revenuePaise);
    final delta = prevRevenuePaise <= 0
        ? null
        : ((revenuePaise - prevRevenuePaise) / prevRevenuePaise) * 100;
    final checkedIn = payments.checkedInBookings.length;
    final pendingPaise = payments.totalBalancePaise;
    return [
      _MonthlyKpi(
        value: '₹${_compactAmount(revenuePaise / 100)}',
        label: 'REVENUE',
        trailing: delta == null
            ? null
            : '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(0)}%',
        trailingPositive: (delta ?? 0) >= 0,
      ),
      _MonthlyKpi(value: '$count', label: 'BOOKINGS'),
      _MonthlyKpi(value: '$checkedIn', label: 'PAID'),
      _MonthlyKpi(
        value: '₹${_compactAmount(pendingPaise / 100)}',
        label: 'PENDING',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final loading = _tab == 0
        ? widget.bookingsAsync.isLoading
        : (widget.currentMonthSummaryAsync.isLoading ||
            widget.currentMonthPaymentsAsync.isLoading);
    final cells = _tab == 0 ? _todayCells() : _monthCells();

    Widget tabPill(int index, String label) {
      final selected = _tab == index;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _tab = index),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: selected
                  ? scheme.primary
                  : scheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'PERFORMANCE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const Spacer(),
              tabPill(0, 'TODAY'),
              Container(
                width: 1,
                height: 10,
                color: scheme.onSurface.withValues(alpha: 0.15),
              ),
              tabPill(1, 'MONTH'),
            ],
          ),
          const SizedBox(height: 14),
          if (loading)
            const _BlockSkeleton(height: 56)
          else
            _MonthlyKpiRow(cells: cells),
          const SizedBox(height: 18),
          Container(
            height: 1,
            color: scheme.onSurface.withValues(alpha: 0.08),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recent bookings',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  ref.read(dashboardTabIndexProvider.notifier).state = 2;
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'See all',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeArenaFilter extends StatelessWidget {
  const _HomeArenaFilter({
    required this.arenas,
    required this.selectedArenaId,
    required this.onSelected,
  });

  final List<ArenaListing> arenas;
  final String? selectedArenaId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final items = <({String? id, String label})>[
      (id: null, label: 'All'),
      ...arenas.map((arena) => (id: arena.id, label: arena.name)),
    ];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 6),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 22),
        itemBuilder: (context, index) {
          final item = items[index];
          final selected = item.id == selectedArenaId;
          return GestureDetector(
            onTap: () => onSelected(item.id),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        selected ? FontWeight.w800 : FontWeight.w600,
                    letterSpacing: -0.1,
                    color: selected
                        ? scheme.primary
                        : scheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  height: 2.5,
                  width: selected ? 22 : 0,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ThinDivider extends StatelessWidget {
  const _ThinDivider();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: Theme.of(context).colorScheme.outline,
    );
  }
}

class _MonthlyKpi {
  const _MonthlyKpi({
    required this.value,
    required this.label,
    this.trailing,
    this.trailingPositive = true,
  });
  final String value;
  final String label;
  final String? trailing;
  final bool trailingPositive;
}

class _MonthlyKpiRow extends StatelessWidget {
  const _MonthlyKpiRow({required this.cells});
  final List<_MonthlyKpi> cells;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < cells.length; i++) ...[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        cells[i].value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                    if (cells[i].trailing != null) ...[
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          cells[i].trailing!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: cells[i].trailingPositive
                                ? const Color(0xFF059669)
                                : scheme.error,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  cells[i].label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: scheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          if (i < cells.length - 1)
            Container(
              width: 1,
              height: 26,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              color: scheme.onSurface.withValues(alpha: 0.08),
            ),
        ],
      ],
    );
  }
}

// ─── Recent bookings (horizontal carousel) ───────────────────────────────────

class _RecentBookingsCarousel extends StatelessWidget {
  const _RecentBookingsCarousel({required this.bookings});
  final List<ArenaReservation> bookings;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final sorted = [...bookings.where((b) => b.bookingDate != null)]
      ..sort((a, b) {
        final aDelta = a.bookingDate!.difference(now).abs();
        final bDelta = b.bookingDate!.difference(now).abs();
        return aDelta.compareTo(bDelta);
      });
    final recent = sorted.take(3).toList();

    if (recent.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          'No bookings yet',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: recent.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, i) => _RecentBookingCard(booking: recent[i]),
    );
  }
}

class _RecentBookingCard extends StatelessWidget {
  const _RecentBookingCard({required this.booking});
  final ArenaReservation booking;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = booking.status.toUpperCase();
    // Tapping opens the booking detail page
    final ({Color fg, Color bg, String label}) badge;
    if (booking.balancePaise == 0) {
      badge = (
        fg: const Color(0xFF059669),
        bg: const Color(0xFF059669).withValues(alpha: 0.14),
        label: 'Paid',
      );
    } else {
      switch (status) {
        case 'CANCELLED':
        case 'CANCELLED_BY_OWNER':
          badge = (
            fg: scheme.error,
            bg: scheme.error.withValues(alpha: 0.14),
            label: 'Cancelled',
          );
        case 'HELD':
          badge = (
            fg: scheme.onSurface.withValues(alpha: 0.65),
            bg: scheme.onSurface.withValues(alpha: 0.10),
            label: 'Held',
          );
        default:
          badge = (
            fg: scheme.primary,
            bg: scheme.primary.withValues(alpha: 0.14),
            label: 'Confirmed',
          );
      }
    }

    final dateLabel = DateFormat('d MMM').format(booking.bookingDate!);
    final timeLabel = '${booking.startTime}–${booking.endTime}';

    return GestureDetector(
      onTap: () =>
          context.push(AppRoutes.bookingDetailPath(booking.id)),
      child: Container(
      width: 220,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.1,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badge.bg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: badge.fg,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 12,
                  color: scheme.onSurface.withValues(alpha: 0.55)),
              const SizedBox(width: 5),
              Text(
                dateLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.access_time_rounded,
                  size: 12,
                  color: scheme.onSurface.withValues(alpha: 0.55)),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  timeLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ],
          ),
          if (booking.unitName != null) ...[
            const SizedBox(height: 6),
            Text(
              booking.unitName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ],
        ],
      ),
    ),
    );
  }
}

class _RecentBookingsSkeleton extends StatelessWidget {
  const _RecentBookingsSkeleton();
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, __) => Container(
        width: 220,
        decoration: BoxDecoration(
          color: scheme.outline.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

// ─── Bookings + Revenue combo chart (last 14 days) ───────────────────────────

class _BookingsTrendSection extends StatelessWidget {
  const _BookingsTrendSection({
    required this.bookingsAsync,
    this.showTitle = true,
    this.padding = const EdgeInsets.fromLTRB(20, 18, 20, 18),
  });
  final AsyncValue<List<ArenaReservation>> bookingsAsync;
  final bool showTitle;
  final EdgeInsets padding;

  static Map<String, ArenaDaySummary> _summarise(
      List<ArenaReservation> bookings) {
    final today = DateTime.now();
    // window: 6 days back … 7 days forward (14 days centred on today)
    final from = DateTime(today.year, today.month, today.day - 6);
    final to = DateTime(today.year, today.month, today.day + 7);
    final map = <String, ArenaDaySummary>{};
    for (final b in bookings) {
      final date = b.bookingDate;
      if (date == null) continue;
      if (!_isActiveBooking(b)) continue;
      final day = DateTime(date.year, date.month, date.day);
      if (day.isBefore(from) || day.isAfter(to)) continue;
      final key = DateFormat('yyyy-MM-dd').format(day);
      final existing = map[key];
      map[key] = ArenaDaySummary(
        count: (existing?.count ?? 0) + 1,
        revenuePaise: (existing?.revenuePaise ?? 0) +
            (_countsAsRevenue(b) ? b.totalAmountPaise : 0),
      );
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final today = DateTime.now();
    // 14-day window: 6 days ago → today → 7 days ahead
    final days = List.generate(
      14,
      (i) => DateTime(today.year, today.month, today.day - 6 + i),
    );

    return Padding(
      padding: padding,
      child: bookingsAsync.when(
        loading: () => const _BlockSkeleton(height: 240),
        error: (_, __) => const SizedBox.shrink(),
        data: (bookings) {
          final summary = _summarise(bookings);
          final counts = days
              .map((d) =>
                  summary[DateFormat('yyyy-MM-dd').format(d)]?.count ?? 0)
              .toList();
          final revenues = days
              .map((d) =>
                  (summary[DateFormat('yyyy-MM-dd').format(d)]?.revenuePaise ??
                      0) /
                  100.0)
              .toList();
          final totalCount = counts.fold(0, (s, v) => s + v);
          final totalRevenue = revenues.fold(0.0, (s, v) => s + v);
          final peakRevenue = revenues.fold(0.0, (m, v) => v > m ? v : m);

          Widget stat(String value, String label, {double sizeScale = 1.0}) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20 * sizeScale,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: scheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            );
          }

          Widget sep() => Container(
                width: 1,
                height: 26,
                color: scheme.onSurface.withValues(alpha: 0.08),
                margin: const EdgeInsets.symmetric(horizontal: 14),
              );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showTitle) ...[
                Text(
                  'Bookings & Revenue',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Past 6 days · Today · Next 7 days',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: stat(
                      '₹${_compactAmount(totalRevenue)}',
                      'REVENUE',
                    ),
                  ),
                  sep(),
                  Expanded(child: stat('$totalCount', 'BOOKINGS')),
                  sep(),
                  Expanded(
                    child: stat('₹${_compactAmount(peakRevenue)}', 'PEAK DAY'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 200,
                child: _BookingsRevenueChart(
                  days: days,
                  counts: counts,
                  revenues: revenues,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Bookings',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    width: 12,
                    height: 2,
                    decoration: BoxDecoration(
                      color: scheme.onSurface,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Revenue',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BookingsRevenueChart extends StatelessWidget {
  const _BookingsRevenueChart({
    required this.days,
    required this.counts,
    required this.revenues,
  });
  final List<DateTime> days;
  final List<int> counts;
  final List<double> revenues;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final maxCount = counts.fold(0, (m, v) => v > m ? v : m).toDouble();
    final maxRevenue = revenues.fold(0.0, (m, v) => v > m ? v : m);

    if (maxCount == 0 && maxRevenue == 0) {
      return Center(
        child: Text(
          'No bookings in this period',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface.withValues(alpha: 0.40),
          ),
        ),
      );
    }

    const maxY = 100.0;
    double normCount(int v) =>
        maxCount == 0 ? 0 : (v / maxCount) * 96;
    double normRevenue(double v) =>
        maxRevenue == 0 ? 0 : (v / maxRevenue) * 96;

    final barData = BarChartData(
      maxY: maxY,
      minY: 0,
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      alignment: BarChartAlignment.spaceAround,
      titlesData: FlTitlesData(
        leftTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 26,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final i = value.toInt();
              if (i < 0 || i >= days.length) return const SizedBox();
              final d = days[i];
              final isToday = d.day == today.day &&
                  d.month == today.month &&
                  d.year == today.year;
              // label every other bar to avoid crowding
              if (i % 2 != 0 && !isToday) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  isToday ? 'T' : '${d.day}',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight:
                        isToday ? FontWeight.w900 : FontWeight.w600,
                    color: isToday
                        ? scheme.primary
                        : scheme.onSurface.withValues(alpha: 0.40),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => scheme.inverseSurface,
          tooltipRoundedRadius: 8,
          tooltipPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          getTooltipItem: (group, _, rod, __) {
            final i = group.x;
            return BarTooltipItem(
              '${DateFormat('d MMM').format(days[i])}\n'
              '${counts[i]} booking${counts[i] == 1 ? '' : 's'} · '
              '₹${_compactAmount(revenues[i])}',
              TextStyle(
                color: scheme.onInverseSurface,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            );
          },
        ),
      ),
      barGroups: List.generate(days.length, (i) {
        final d = days[i];
        final isToday = d.day == today.day &&
            d.month == today.month &&
            d.year == today.year;
        return BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: normCount(counts[i]),
              width: 13,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: isToday
                    ? [
                        scheme.primary,
                        scheme.primary.withValues(alpha: 0.75),
                      ]
                    : [
                        scheme.primary.withValues(alpha: 0.50),
                        scheme.primary.withValues(alpha: 0.20),
                      ],
              ),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxY,
                color: scheme.surfaceContainerHighest,
              ),
            ),
          ],
        );
      }),
    );

    final spots = List.generate(
      days.length,
      (i) => FlSpot(i.toDouble(), normRevenue(revenues[i])),
    );

    final lineData = LineChartData(
      minX: 0,
      maxX: (days.length - 1).toDouble(),
      minY: 0,
      maxY: maxY,
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: const FlTitlesData(show: false),
      lineTouchData: const LineTouchData(enabled: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.35,
          preventCurveOverShooting: true,
          barWidth: 2.5,
          isStrokeCapRound: true,
          color: scheme.onSurface,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, _, __, index) => FlDotCirclePainter(
              radius: index == spots.length - 1 ? 4.5 : 2.5,
              color: scheme.surface,
              strokeWidth: index == spots.length - 1 ? 2.5 : 1.5,
              strokeColor: scheme.onSurface,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                scheme.onSurface.withValues(alpha: 0.08),
                scheme.onSurface.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ],
    );

    return Stack(
      children: [
        BarChart(barData),
        Padding(
          padding: const EdgeInsets.only(bottom: 26),
          child: IgnorePointer(child: LineChart(lineData)),
        ),
      ],
    );
  }
}

// ─── Daily slot utilization ───────────────────────────────────────────────────

class _DailyUtilizationSection extends StatelessWidget {
  const _DailyUtilizationSection({
    required this.bookingsAsync,
    required this.arenas,
    this.showTitle = true,
    this.padding = const EdgeInsets.fromLTRB(20, 18, 20, 18),
  });
  final AsyncValue<List<ArenaReservation>> bookingsAsync;
  final List<ArenaListing> arenas;
  final bool showTitle;
  final EdgeInsets padding;

  static int _toMin(String t) {
    final p = t.split(':');
    return (int.tryParse(p[0]) ?? 0) * 60 +
        (p.length > 1 ? (int.tryParse(p[1]) ?? 0) : 0);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final days = List.generate(
      14,
      (i) => DateTime(today.year, today.month, today.day - 6 + i),
    );

    // Total bookable minutes per day across all selected arenas.
    // Each unit contributes (closeTime − openTime) minutes per day.
    final totalAvailMin = arenas.fold(0, (sum, arena) {
      final unitCount = arena.units.length;
      if (unitCount == 0) return sum;
      final open = _toMin(arena.openTime);
      final close = _toMin(arena.closeTime);
      return sum + (close - open).clamp(0, 24 * 60) * unitCount;
    });

    return Padding(
      padding: padding,
      child: bookingsAsync.when(
        loading: () => const _BlockSkeleton(height: 170),
        error: (_, __) => const SizedBox.shrink(),
        data: (bookings) {
          // Sum booked minutes per day key
          final bookedByDay = <String, int>{};
          for (final b in bookings) {
            final date = b.bookingDate;
            if (date == null || !_isActiveBooking(b)) continue;
            final key = DateFormat('yyyy-MM-dd')
                .format(DateTime(date.year, date.month, date.day));
            final mins =
                (_toMin(b.endTime) - _toMin(b.startTime)).clamp(0, 24 * 60);
            bookedByDay[key] = (bookedByDay[key] ?? 0) + mins;
          }

          double util(DateTime d) {
            if (totalAvailMin == 0) return 0;
            final key = DateFormat('yyyy-MM-dd').format(d);
            return ((bookedByDay[key] ?? 0) / totalAvailMin * 100)
                .clamp(0.0, 100.0);
          }

          final todayDate = DateTime(today.year, today.month, today.day);
          final todayPct = util(todayDate);
          // Average across past 7 days incl. today
          final past7 = days.where((d) => !d.isAfter(todayDate)).toList();
          final avgPct = past7.isEmpty
              ? 0.0
              : past7.map(util).fold(0.0, (s, v) => s + v) / past7.length;
          // Peak across full window
          final peakPct = days.map(util).fold(0.0, (m, v) => v > m ? v : m);

          Widget stat(String value, String label, {Color? valueColor}) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: valueColor ?? scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: scheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showTitle) ...[
                Text(
                  'Slot utilization',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Booked time vs capacity · ±7 days',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              if (totalAvailMin > 0)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: stat(
                        '${todayPct.round()}%',
                        'TODAY',
                        valueColor: todayPct >= 50
                            ? const Color(0xFF059669)
                            : scheme.error,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 26,
                      color: scheme.onSurface.withValues(alpha: 0.08),
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    Expanded(
                      child: stat('${avgPct.round()}%', 'AVG · 7D'),
                    ),
                    Container(
                      width: 1,
                      height: 26,
                      color: scheme.onSurface.withValues(alpha: 0.08),
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    Expanded(
                      child: stat('${peakPct.round()}%', 'PEAK'),
                    ),
                  ],
                ),
              const SizedBox(height: 18),
              SizedBox(
                height: 200,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < days.length; i++) ...[
                      Expanded(
                        child: _UtilBar(
                          day: days[i],
                          pct: util(days[i]),
                          isToday: DateUtils.isSameDay(days[i], todayDate),
                          isFuture: days[i].isAfter(todayDate),
                        ),
                      ),
                      if (i < days.length - 1) const SizedBox(width: 4),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _UtilBar extends StatelessWidget {
  const _UtilBar({
    required this.day,
    required this.pct,
    required this.isToday,
    this.isFuture = false,
  });
  final DateTime day;
  final double pct;
  final bool isToday;
  final bool isFuture;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color barColor;
    if (pct == 0) {
      barColor = scheme.onSurface.withValues(alpha: 0.08);
    } else if (isFuture) {
      barColor = scheme.primary.withValues(alpha: 0.4);
    } else if (pct >= 50) {
      barColor = const Color(0xFF059669);
    } else {
      barColor = scheme.error.withValues(alpha: 0.75);
    }

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final barH = pct == 0
                    ? 2.0
                    : (pct / 100 * constraints.maxHeight)
                        .clamp(3.0, constraints.maxHeight);
                return Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: double.infinity,
                      color: scheme.onSurface.withValues(alpha: 0.04),
                    ),
                    Container(
                      height: barH,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(3),
                          topRight: Radius.circular(3),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        Text(
          '${day.day}',
          style: TextStyle(
            fontSize: 9,
            fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
            color: isToday
                ? scheme.primary
                : scheme.onSurface.withValues(alpha: 0.40),
          ),
        ),
      ],
    );
  }
}

// ─── Helpers shared by home tab ──────────────────────────────────────────────

class _BlockSkeleton extends StatelessWidget {
  const _BlockSkeleton({required this.height});
  final double height;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

String _compactAmount(double value) {
  final n = value.round();
  if (n < 0) return '-${_compactAmount(-value)}';
  final s = n.toString();
  if (s.length <= 3) return s;
  final last3 = s.substring(s.length - 3);
  String rest = s.substring(0, s.length - 3);
  final groups = <String>[];
  while (rest.length > 2) {
    groups.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) groups.insert(0, rest);
  return '${groups.join(',')},$last3';
}

bool _isActiveBooking(ArenaReservation booking) {
  final status = booking.status.toUpperCase();
  return status != 'CANCELLED' &&
      status != 'CANCELLED_BY_OWNER' &&
      status != 'HELD';
}

bool _countsAsRevenue(ArenaReservation booking) {
  final status = booking.status.toUpperCase();
  return status == 'CONFIRMED' ||
      status == 'CHECKED_IN' ||
      status == 'COMPLETED' ||
      booking.paidAt != null;
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.businessName, required this.ref});
  final String businessName;
  final WidgetRef ref;

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  businessName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _PaymentsButton(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PaymentsRoute(),
              ),
            ),
          ),
          const SizedBox(width: 6),
          _NotificationBell(
            onTap: () => context
                .push(AppRoutes.arenaNotifications)
                .then((_) => ref.invalidate(bizUnreadCountProvider)),
          ),
          const SizedBox(width: 6),
          Builder(
            builder: (ctx) => GestureDetector(
              onTap: () => Scaffold.of(ctx).openEndDrawer(),
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: _ProfileAvatar(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationBell extends ConsumerWidget {
  const _NotificationBell({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final unreadAsync = ref.watch(bizUnreadCountProvider);
    final unread = unreadAsync.maybeWhen(data: (n) => n, orElse: () => 0);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(
              unread > 0
                  ? Icons.notifications_rounded
                  : Icons.notifications_none_rounded,
              size: 22,
              color: scheme.onSurface.withValues(alpha: 0.85),
            ),
            if (unread > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: scheme.error,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: scheme.surface, width: 1.5),
                  ),
                  constraints:
                      const BoxConstraints(minWidth: 16, minHeight: 16),
                  alignment: Alignment.center,
                  child: Text(
                    unread > 99 ? '99+' : '$unread',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
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

class _ArenasTab extends ConsumerWidget {
  const _ArenasTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arenasAsync = ref.watch(ownedArenasProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => ref.refresh(ownedArenasProvider.future),
            child: arenasAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              error: (e, _) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: _CenteredMessage(
                    title: 'Could not load arenas', message: '$e'),
              ),
              data: (arenas) {
                if (arenas.isEmpty) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: _CenteredMessage(
                      title: 'No arenas yet',
                      message:
                          'Add your first arena to start managing bookings.',
                    ),
                  );
                }
                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: arenas.length,
                  itemBuilder: (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _ArenaCard(arena: arenas[i]),
                  ),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Builder(
            builder: (context) {
              final scheme = Theme.of(context).colorScheme;
              return SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () => context.push(AppRoutes.createArena),
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 22),
                  label: const Text(
                    'Add Arena',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ArenaCard extends ConsumerStatefulWidget {
  const _ArenaCard({required this.arena});
  final ArenaListing arena;

  @override
  ConsumerState<_ArenaCard> createState() => _ArenaCardState();
}

class _ArenaCardState extends ConsumerState<_ArenaCard> {
  bool _deleting = false;

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Arena?',
            style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text(
            'This will permanently delete "${widget.arena.name}" and all its units, bookings and data. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _deleting = true);
    try {
      final repo = ref.read(hostArenaBookingRepositoryProvider);
      await repo.deleteArena(widget.arena.id);
      if (!mounted) return;
      ref.invalidate(ownedArenasProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete arena: $e')),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final arena = widget.arena;
    final scheme = Theme.of(context).colorScheme;
    final loc = _joinNonEmpty([arena.city, arena.state]);
    final address = loc.isNotEmpty
        ? loc
        : (arena.address.isNotEmpty ? arena.address : 'Location not set');
    final initial = arena.name.isNotEmpty ? arena.name[0].toUpperCase() : 'A';
    final unitCount = arena.units.length;
    final photoUrl = arena.photoUrls.isNotEmpty ? arena.photoUrls.first : null;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top info row — tappable
          Material(
            color: Colors.transparent,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: InkWell(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              onTap: () =>
                  context.push('${AppRoutes.arenaProfile}/${arena.id}'),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 54,
                        height: 54,
                        child: photoUrl != null
                            ? Image.network(photoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _ArenaInitialBox(initial))
                            : _ArenaInitialBox(initial),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(arena.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: scheme.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.2)),
                          const SizedBox(height: 4),
                          Row(children: [
                            Icon(Icons.location_on_outlined,
                                size: 13,
                                color:
                                    scheme.onSurface.withValues(alpha: 0.5)),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(address,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: scheme.onSurface
                                          .withValues(alpha: 0.65),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ]),
                        ],
                      ),
                    ),
                    if (_deleting)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert_rounded,
                            color: scheme.onSurface.withValues(alpha: 0.4),
                            size: 20),
                        onSelected: (value) {
                          if (value == 'delete') _confirmDelete();
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline_rounded,
                                    color: Colors.red, size: 18),
                                SizedBox(width: 8),
                                Text('Delete Arena',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Stat pills
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _StatPill(Icons.access_time_rounded,
                    '${arena.openTime}–${arena.closeTime}'),
                _StatPill(Icons.layers_outlined,
                    '$unitCount unit${unitCount == 1 ? '' : 's'}'),
                if (arena.sports.isNotEmpty)
                  _StatPill(Icons.sports_cricket_outlined,
                      arena.sports.take(2).join(', ')),
              ],
            ),
          ),
          Divider(height: 1, color: scheme.outline),
          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: _CardAction(
                    icon: Icons.edit_outlined,
                    label: 'Edit Arena',
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      backgroundColor: scheme.surface,
                      builder: (_) => ArenaDetailSheet(
                        arena: arena,
                        startEditing: true,
                      ),
                    ).then((_) => ref.invalidate(ownedArenasProvider)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _CardAction(
                    icon: Icons.layers_rounded,
                    label: 'Manage Units',
                    filled: true,
                    onTap: () =>
                        context.push('${AppRoutes.arenaProfile}/${arena.id}'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArenaInitialBox extends StatelessWidget {
  const _ArenaInitialBox(this.initial);
  final String initial;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.primary.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: scheme.onPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill(this.icon, this.label);
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.65);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: muted),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardAction extends StatelessWidget {
  const _CardAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = filled ? scheme.onSurface : scheme.surface;
    final fg = filled ? scheme.surface : scheme.onSurface;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingsTab extends StatelessWidget {
  const _BookingsTab();
  @override
  Widget build(BuildContext context) => const bookings.BookingsPage();
}

class _PaymentsButton extends StatelessWidget {
  const _PaymentsButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.currency_rupee_rounded,
          size: 22,
          color: scheme.onSurface.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}

class PaymentsRoute extends StatelessWidget {
  const PaymentsRoute();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Payments',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
      ),
      body: const SafeArea(child: PaymentsPage()),
    );
  }
}

class _MatchUpsTab extends ConsumerWidget {
  const _MatchUpsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final top = MediaQuery.of(context).padding.top;
    final arenasAsync = ref.watch(ownedArenasProvider);
    return arenasAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (e, _) => Center(child: Text('$e')),
      data: (arenas) {
        if (arenas.isEmpty) {
          return const _CenteredMessage(
            title: 'No arenas yet',
            message: 'Add an arena to start matching teams.',
          );
        }
        return Scaffold(
          backgroundColor: scheme.surface,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: top + 12),
              Container(height: 1, color: scheme.outline),
              Expanded(
                child: MatchUpsTab(
                  key: ValueKey(arenas.map((a) => a.id).join(',')),
                  arenas: arenas,
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () => _openSplitBookingSheet(context, ref, arenas),
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.bolt_rounded, size: 22),
                  label: const Text(
                    'Add Match-Up',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openSplitBookingSheet(
      BuildContext context, WidgetRef ref, List<ArenaListing> arenas) {
    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => SplitBookingSheet(initialDate: DateTime.now()),
        ))
        .then((created) {
      if (created == true) {
        for (final a in arenas) {
          ref.invalidate(arenaLobbiesProvider(a.id));
          ref.invalidate(arenaMatchesProvider(a.id));
        }
      }
    });
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({required this.title, required this.message});
  final String title, message;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}


String _joinNonEmpty(List<String?> v, {String s = ', '}) => v
    .where((x) => x != null && x.trim().isNotEmpty)
    .map((x) => x!.trim())
    .join(s);

// ─── Heatmap / utilization tabs ──────────────────────────────────────────────

class _HeatmapUtilizationTabs extends StatefulWidget {
  const _HeatmapUtilizationTabs({
    required this.bookingsAsync,
    required this.arenas,
  });

  final AsyncValue<List<ArenaReservation>> bookingsAsync;
  final List<ArenaListing> arenas;

  @override
  State<_HeatmapUtilizationTabs> createState() =>
      _HeatmapUtilizationTabsState();
}

class _HeatmapUtilizationTabsState extends State<_HeatmapUtilizationTabs> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tabs = const [
      (label: 'Heatmap', icon: Icons.calendar_view_month_rounded),
      (label: 'Utilization', icon: Icons.bar_chart_rounded),
      (label: 'Revenue', icon: Icons.show_chart_rounded),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 1,
                color: scheme.onSurface.withValues(alpha: 0.08),
              ),
              Row(
                children: [
                  for (var i = 0; i < tabs.length; i++)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => _index = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: _index == i ? 2 : 1,
                                color: _index == i
                                    ? scheme.primary
                                    : Colors.transparent,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                tabs[i].icon,
                                size: 16,
                                color: _index == i
                                    ? scheme.primary
                                    : scheme.onSurface.withValues(alpha: 0.45),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                tabs[i].label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.1,
                                  color: _index == i
                                      ? scheme.primary
                                      : scheme.onSurface
                                          .withValues(alpha: 0.55),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        if (_index == 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
            child: _WeeklyHeatmapSection(
              bookingsAsync: widget.bookingsAsync,
              arenas: widget.arenas,
              showTitle: false,
            ),
          )
        else if (_index == 1)
          _DailyUtilizationSection(
            bookingsAsync: widget.bookingsAsync,
            arenas: widget.arenas,
            showTitle: false,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          )
        else
          _BookingsTrendSection(
            bookingsAsync: widget.bookingsAsync,
            showTitle: false,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          ),
      ],
    );
  }
}

// ─── Monthly calendar heatmap ─────────────────────────────────────────────────

class _WeeklyHeatmapSection extends StatelessWidget {
  const _WeeklyHeatmapSection({
    required this.bookingsAsync,
    required this.arenas,
    this.showTitle = true,
  });

  final AsyncValue<List<ArenaReservation>> bookingsAsync;
  final List<ArenaListing> arenas;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    return bookingsAsync.when(
      loading: () => const _BlockSkeleton(height: 300),
      error: (_, __) => const SizedBox.shrink(),
      data: (bookings) {
        if (arenas.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No arenas selected'),
            ),
          );
        }
        final scheme = Theme.of(context).colorScheme;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showTitle) ...[
              Text(
                'Heatmap',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
            ],
            for (int i = 0; i < arenas.length; i++) ...[
              _ArenaCalendar(arena: arenas[i], allBookings: bookings),
              if (i < arenas.length - 1) const SizedBox(height: 32),
            ],
            const SizedBox(height: 20),
            _HeatmapLegend(),
          ],
        );
      },
    );
  }
}

class _ArenaCalendar extends StatelessWidget {
  const _ArenaCalendar({required this.arena, required this.allBookings});

  final ArenaListing arena;
  final List<ArenaReservation> allBookings;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final today = DateTime.now();

    // Current month bounds
    final firstOfMonth = DateTime(today.year, today.month, 1);
    final daysInMonth = DateTime(today.year, today.month + 1, 0).day;
    // Mon=1 → offset 0, Sun=7 → offset 6
    final offset = firstOfMonth.weekday - 1;
    final rowCount = ((offset + daysInMonth) / 7).ceil();

    // Tally bookings for this arena this month (no arenaId filter —
    // all bookings are already fetched per-arena from the provider)
    final Map<int, int> activeByDay = {};
    final Map<int, int> cancelledByDay = {};
    final Map<int, int> pendingByDay = {};

    for (final b in allBookings) {
      final date = b.bookingDate;
      if (date == null) continue;
      if (date.year != today.year || date.month != today.month) continue;
      // If multiple arenas selected, only count bookings for this arena
      if (b.arenaId.isNotEmpty && b.arenaId != arena.id) continue;
      final d = date.day;
      final status = b.status.toUpperCase();
      if (status == 'CANCELLED' || status == 'CANCELLED_BY_OWNER') {
        cancelledByDay[d] = (cancelledByDay[d] ?? 0) + 1;
      } else if (status == 'HELD') {
        pendingByDay[d] = (pendingByDay[d] ?? 0) + 1;
      } else {
        activeByDay[d] = (activeByDay[d] ?? 0) + 1;
      }
    }

    final totalBooked = activeByDay.values.fold(0, (s, v) => s + v);
    final totalBlocked = cancelledByDay.values.fold(0, (s, v) => s + v);

    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    const cellGap = 3.0;
    const cellH = 38.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Calendar header ──────────────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              DateFormat('MMMM yyyy').format(today),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                color: scheme.onSurface,
              ),
            ),
            const Spacer(),
            _HeatmapPill(
              dot: const Color(0xFF16A34A),
              value: totalBooked,
              label: 'booked',
              scheme: scheme,
            ),
            const SizedBox(width: 12),
            _HeatmapPill(
              dot: const Color(0xFFDC2626),
              value: totalBlocked,
              label: 'blocked',
              scheme: scheme,
            ),
          ],
        ),
        const SizedBox(height: 12),
        // ── Day-of-week header ───────────────────────────────────────────────
        Row(
          children: List.generate(
            7,
            (i) => Expanded(
              child: Text(
                dayLabels[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface.withValues(alpha: 0.35),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        // ── Calendar grid ────────────────────────────────────────────────────
        for (int row = 0; row < rowCount; row++) ...[
          if (row > 0) const SizedBox(height: cellGap),
          SizedBox(
            height: cellH,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(7, (col) {
                final cellIndex = row * 7 + col;
                final dayNum = cellIndex - offset + 1;
                final isValid = dayNum >= 1 && dayNum <= daysInMonth;

                Widget child;
                if (!isValid) {
                  child = const SizedBox.shrink();
                } else {
                  final dayDate =
                      DateTime(today.year, today.month, dayNum);
                  final isPast = dayDate
                      .isBefore(DateTime(today.year, today.month, today.day));
                  final isToday = dayNum == today.day;
                  final active = activeByDay[dayNum] ?? 0;
                  final cancelled = cancelledByDay[dayNum] ?? 0;
                  final pending = pendingByDay[dayNum] ?? 0;
                  child = _CalendarCell(
                    dayNum: dayNum,
                    active: active,
                    cancelled: cancelled,
                    pending: pending,
                    isPast: isPast,
                    isToday: isToday,
                  );
                }

                return Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.only(right: col < 6 ? cellGap : 0),
                    child: child,
                  ),
                );
              }),
            ),
          ),
        ],
      ],
    );
  }
}

class _CalendarCell extends StatelessWidget {
  const _CalendarCell({
    required this.dayNum,
    required this.active,
    required this.cancelled,
    required this.pending,
    required this.isPast,
    required this.isToday,
  });

  final int dayNum;
  final int active;
  final int cancelled;
  final int pending;
  final bool isPast;
  final bool isToday;

  Color _bgColor() {
    if (active > 0) {
      if (active >= 6) return const Color(0xFF166534);
      if (active >= 4) return const Color(0xFF16A34A);
      if (active >= 2) return const Color(0xFF4ADE80);
      return const Color(0xFF86EFAC);
    }
    if (cancelled > 0) return const Color(0xFFFCA5A5);
    if (pending > 0) return const Color(0xFFFDE68A);
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasBooking = active > 0 || cancelled > 0 || pending > 0;
    final bg = _bgColor();
    const radius = BorderRadius.all(Radius.circular(6));

    if (!hasBooking && isPast) {
      return ClipRRect(
        borderRadius: radius,
        child: CustomPaint(
          painter: const _HatchPainter(),
          child: Container(
            color: const Color(0xFFF3F4F6),
            alignment: Alignment.center,
            child: Text(
              '$dayNum',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface.withValues(alpha: 0.25),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: hasBooking
            ? bg
            : scheme.onSurface.withValues(alpha: 0.05),
        borderRadius: radius,
        border: isToday && !hasBooking
            ? Border.all(color: scheme.primary, width: 2)
            : null,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$dayNum',
            style: TextStyle(
              fontSize: 12,
              fontWeight: isToday ? FontWeight.w900 : FontWeight.w700,
              color: hasBooking
                  ? (active >= 4
                      ? Colors.white
                      : const Color(0xFF064E3B))
                  : isToday
                      ? scheme.primary
                      : scheme.onSurface.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _HatchPainter extends CustomPainter {
  const _HatchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 1.0;
    const spacing = 5.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
          Offset(i, size.height), Offset(i + size.height, 0), paint);
    }
  }

  @override
  bool shouldRepaint(_HatchPainter oldDelegate) => false;
}

class _HeatmapPill extends StatelessWidget {
  const _HeatmapPill({
    required this.dot,
    required this.value,
    required this.label,
    required this.scheme,
  });
  final Color dot;
  final int value;
  final String label;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: dot,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.1,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _HeatmapLegend extends StatelessWidget {
  const _HeatmapLegend();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const scale = [
      Color(0xFF86EFAC),
      Color(0xFF4ADE80),
      Color(0xFF16A34A),
      Color(0xFF166534),
    ];
    return Row(
      children: [
        Text(
          'Less',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface.withValues(alpha: 0.45),
          ),
        ),
        const SizedBox(width: 6),
        for (final c in scale) ...[
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 3),
        ],
        const SizedBox(width: 3),
        Text(
          'More',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface.withValues(alpha: 0.45),
          ),
        ),
        const Spacer(),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFFFCA5A5),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          'Blocked',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFFFDE68A),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          'Pending',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

