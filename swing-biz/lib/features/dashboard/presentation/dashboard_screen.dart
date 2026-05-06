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
  } catch (error, stackTrace) {
    debugPrint(
      '[dashboard] availability load failed for arena=$arenaId: $error',
    );
    debugPrintStack(stackTrace: stackTrace);
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
  } catch (error, stackTrace) {
    debugPrint(
      '[dashboard] month summary load failed for arena=${key.arenaId} month=${key.month}: $error',
    );
    debugPrintStack(stackTrace: stackTrace);
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
  } catch (error, stackTrace) {
    debugPrint(
      '[dashboard] month payments load failed for arena=${key.arenaId} month=${key.month}: $error',
    );
    debugPrintStack(stackTrace: stackTrace);
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
    _NavItem(Icons.account_balance_wallet_rounded,
        Icons.account_balance_wallet_outlined, 'Payments'),
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
      const _PaymentsTab(),
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
              _homeMonthSummaryProvider((arenaId: a.id, month: currentMonthKey)),
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
        final trendSummary = _combineAsyncSummaryMaps([
          ...selectedArenas.map(
            (a) => ref.watch(
              _homeMonthSummaryProvider(
                (arenaId: a.id, month: currentMonthKey),
              ),
            ),
          ),
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
        final todayAvailability = _combineAsyncLists(
          selectedArenas
              .map((a) => ref
                  .watch(_homeTodayAvailabilityProvider(a.id))
                  .whenData((slotsByUnit) =>
                      slotsByUnit.values.expand((slots) => slots).toList()))
              .toList(),
        );
        return Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              _HeroHeader(businessName: businessName, ref: ref),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _HomeArenaFilter(
                      arenas: arenas,
                      selectedArenaId: selectedArenaId,
                      onSelected: (id) =>
                          ref.read(_homeArenaProvider.notifier).state = id,
                    ),
                    _TodaySection(
                      currentMonthSummaryAsync: currentMonthSummary,
                      previousMonthSummaryAsync: previousMonthSummary,
                      currentMonthPaymentsAsync: currentMonthPayments,
                      slotsAsync: todayAvailability,
                    ),
                    _BookingsSummaryCard(bookingsAsync: allBookings),
                    const _ThinDivider(),
                    _BookingsTrendSection(summaryAsync: currentMonthSummary),
                    const _ThinDivider(),
                    _SlotsDonutSection(slotsAsync: todayAvailability),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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

// ─── Today section ───────────────────────────────────────────────────────────

class _TodaySection extends StatelessWidget {
  const _TodaySection({
    required this.currentMonthSummaryAsync,
    required this.previousMonthSummaryAsync,
    required this.currentMonthPaymentsAsync,
    required this.slotsAsync,
  });
  final AsyncValue<Map<String, ArenaDaySummary>> currentMonthSummaryAsync;
  final AsyncValue<Map<String, ArenaDaySummary>> previousMonthSummaryAsync;
  final AsyncValue<ArenaPaymentsData> currentMonthPaymentsAsync;
  final AsyncValue<List<AvailabilitySlot>> slotsAsync;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THIS MONTH',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
              color: scheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 12),
          if (currentMonthSummaryAsync.isLoading ||
              previousMonthSummaryAsync.isLoading ||
              currentMonthPaymentsAsync.isLoading ||
              slotsAsync.isLoading)
            const _BlockSkeleton(height: 92)
          else if (currentMonthSummaryAsync.hasError ||
              previousMonthSummaryAsync.hasError ||
              currentMonthPaymentsAsync.hasError)
            Text('Could not load',
                style: Theme.of(context).textTheme.bodyMedium)
          else
            _buildContent(
              context,
              currentMonthSummaryAsync.value ?? const {},
              previousMonthSummaryAsync.value ?? const {},
              currentMonthPaymentsAsync.value ??
                  const ArenaPaymentsData(
                    checkedInBookings: [],
                    pendingBookings: [],
                  ),
              slotsAsync.value ?? const [],
            ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Map<String, ArenaDaySummary> currentMonthSummary,
    Map<String, ArenaDaySummary> previousMonthSummary,
    ArenaPaymentsData currentMonthPayments,
    List<AvailabilitySlot> slots,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final monthKey = DateFormat('yyyy-MM').format(today);
    final currentSummary = currentMonthSummary.values.fold<int>(
      0,
      (sum, day) => sum + day.count,
    );
    final currentRevenuePaise = currentMonthSummary.values.fold<int>(
      0,
      (sum, day) => sum + day.revenuePaise,
    );
    final previousRevenuePaise = previousMonthSummary.values.fold<int>(
      0,
      (sum, day) => sum + day.revenuePaise,
    );
    final delta = previousRevenuePaise <= 0
        ? null
        : (((currentRevenuePaise - previousRevenuePaise) /
                previousRevenuePaise) *
            100);
    final checkedIn = currentMonthPayments.checkedInBookings.length;
    final pendingCollectionsPaise = currentMonthPayments.totalBalancePaise;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _KpiGrid(
          items: [
            _KpiCard(
              label: 'Revenue this month',
              value: '₹${_compactAmount(currentRevenuePaise / 100)}',
              helper: delta == null
                  ? 'vs last month unavailable'
                  : '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(0)}% vs last month',
              accent: scheme.primary,
            ),
            _KpiCard(
              label: 'Bookings this month',
              value: currentSummary.toString(),
              helper: 'Confirmed bookings in $monthKey',
              accent: const Color(0xFF2563EB),
            ),
            _KpiCard(
              label: 'Check-ins',
              value: '$checkedIn',
              helper: 'Checked in this month',
              accent: const Color(0xFF059669),
            ),
            _KpiCard(
              label: 'Pending collections',
              value: '₹${_compactAmount(pendingCollectionsPaise / 100)}',
              helper: 'Outstanding from this month',
              accent: const Color(0xFFF97316),
            ),
          ],
        ),
      ],
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.items});
  final List<_KpiCard> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 520 ? 3 : 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final item in items)
              SizedBox(
                width: (width - ((columns - 1) * 12)) / columns,
                child: item,
              ),
          ],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.helper,
    required this.accent,
  });

  final String label;
  final String value;
  final String helper;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.auto_graph_rounded, size: 18, color: accent),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            helper,
            style: TextStyle(
              fontSize: 11,
              height: 1.35,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Recent bookings (horizontal carousel) ───────────────────────────────────

class _BookingsSummaryCard extends ConsumerWidget {
  const _BookingsSummaryCard({required this.bookingsAsync});
  final AsyncValue<List<ArenaReservation>> bookingsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 6, 0, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Recent bookings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    ref
                        .read(bookings.bookingsInnerTabProvider.notifier)
                        .state = 1; // Bookings sub-tab
                    ref.read(dashboardTabIndexProvider.notifier).state = 2;
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 2),
                    child: Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 116,
            child: bookingsAsync.when(
              loading: () => const _RecentBookingsSkeleton(),
              error: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Could not load bookings',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              data: (bookings) => _RecentBookingsCarousel(bookings: bookings),
            ),
          ),
        ],
      ),
    );
  }
}

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
    switch (status) {
      case 'CHECKED_IN':
      case 'COMPLETED':
        badge = (
          fg: const Color(0xFF059669),
          bg: const Color(0xFF059669).withValues(alpha: 0.14),
          label: 'Paid',
        );
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

// ─── Bookings + Revenue combo chart ──────────────────────────────────────────

class _BookingsTrendSection extends StatelessWidget {
  const _BookingsTrendSection({required this.summaryAsync});
  final AsyncValue<Map<String, ArenaDaySummary>> summaryAsync;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bookings & Revenue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Last 7 days',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              _LegendChip(
                color: scheme.primary.withValues(alpha: 0.55),
                label: 'Bookings',
                square: true,
              ),
              const SizedBox(width: 12),
              _LegendChip(
                color: scheme.onSurface,
                label: 'Revenue',
                square: false,
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 220,
            child: summaryAsync.when(
              loading: () => const _ChartLoading(),
              error: (e, _) => const _ChartMessage('Could not load graph'),
              data: (summary) => _BookingsRevenueComboChart(summary: summary),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.color,
    required this.label,
    required this.square,
  });
  final Color color;
  final String label;
  final bool square;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: square ? 10 : 14,
          height: square ? 10 : 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius:
                BorderRadius.circular(square ? 2.5 : 2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _BookingsRevenueComboChart extends StatelessWidget {
  const _BookingsRevenueComboChart({required this.summary});
  final Map<String, ArenaDaySummary> summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final days = List.generate(
      7,
      (i) => DateTime(today.year, today.month, today.day - (6 - i)),
    );

    final bookingCounts = <double>[];
    final revenue = <double>[];
    for (final d in days) {
      final daily = summary[DateFormat('yyyy-MM-dd').format(d)];
      bookingCounts.add((daily?.count ?? 0).toDouble());
      revenue.add((daily?.revenuePaise ?? 0) / 100);
    }

    final maxBookings =
        bookingCounts.fold<double>(0, (m, v) => v > m ? v : m);
    final maxRevenue = revenue.fold<double>(0, (m, v) => v > m ? v : m);
    if (maxBookings == 0 && maxRevenue == 0) {
      return const _ChartMessage('No data yet');
    }

    const maxY = 110.0;
    double normBooking(double v) =>
        maxBookings == 0 ? 0 : (v / maxBookings) * 100;
    double normRevenue(double v) =>
        maxRevenue == 0 ? 0 : (v / maxRevenue) * 100;

    final lineColor = scheme.onSurface;

    final commonTitles = FlTitlesData(
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final i = value.toInt();
            if (i < 0 || i >= days.length) return const SizedBox();
            final d = days[i];
            final isToday = d.day == today.day &&
                d.month == today.month &&
                d.year == today.year;
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                DateFormat('E').format(d),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      isToday ? FontWeight.w900 : FontWeight.w700,
                  color: isToday
                      ? scheme.primary
                      : scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            );
          },
        ),
      ),
    );

    final barChart = BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        alignment: BarChartAlignment.spaceAround,
        titlesData: commonTitles,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => scheme.onSurface,
            tooltipRoundedRadius: 10,
            tooltipPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            getTooltipItem: (group, _, rod, __) {
              final i = group.x;
              final d = days[i];
              return BarTooltipItem(
                '${DateFormat('EEE, d MMM').format(d)}\n'
                '${bookingCounts[i].toInt()} bookings · '
                '₹${_compactAmount(revenue[i])}',
                TextStyle(
                  color: scheme.surface,
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
                toY: normBooking(bookingCounts[i]),
                width: 22,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: isToday
                      ? [
                          scheme.primary,
                          scheme.primary.withValues(alpha: 0.7),
                        ]
                      : [
                          scheme.primary.withValues(alpha: 0.55),
                          scheme.primary.withValues(alpha: 0.25),
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
      ),
    );

    final spots = List.generate(
      days.length,
      (i) => FlSpot(i.toDouble(), normRevenue(revenue[i])),
    );

    final lineChart = LineChart(
      LineChartData(
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
            curveSmoothness: 0.4,
            preventCurveOverShooting: true,
            barWidth: 3,
            isStrokeCapRound: true,
            color: lineColor,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final isLast = index == spots.length - 1;
                return FlDotCirclePainter(
                  radius: isLast ? 5 : 3.5,
                  color: scheme.surface,
                  strokeWidth: isLast ? 3 : 2,
                  strokeColor: lineColor,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  lineColor.withValues(alpha: 0.10),
                  lineColor.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Stack(
      children: [
        barChart,
        Padding(
          // line chart gets extra horizontal padding so the line sits in the
          // middle of each bar's slot rather than at the edges
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
          child: IgnorePointer(child: lineChart),
        ),
      ],
    );
  }
}

// ─── Slots donut ─────────────────────────────────────────────────────────────

class _SlotsDonutSection extends StatelessWidget {
  const _SlotsDonutSection({required this.slotsAsync});
  final AsyncValue<List<AvailabilitySlot>> slotsAsync;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Slot utilization',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Today across selected arenas',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 180,
            child: slotsAsync.when(
              loading: () => const _ChartLoading(),
              error: (e, _) => const _ChartMessage('Could not load'),
              data: (slots) => _SlotsDonut(slots: slots),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotsDonut extends StatelessWidget {
  const _SlotsDonut({required this.slots});
  final List<AvailabilitySlot> slots;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (slots.isEmpty) return const _ChartMessage('No slots today');
    final total = slots.length;
    final booked = slots.where((s) => !s.available).length;
    final available = total - booked;
    final pct = total == 0 ? 0 : (booked / total * 100).round();
    return Row(
      children: [
        SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  startDegreeOffset: -90,
                  sectionsSpace: 3,
                  centerSpaceRadius: 52,
                  sections: [
                    PieChartSectionData(
                      value: booked.toDouble().clamp(0.0001, double.infinity),
                      color: scheme.primary,
                      radius: 22,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value:
                          available.toDouble().clamp(0.0001, double.infinity),
                      color: scheme.surfaceContainerHighest,
                      radius: 22,
                      showTitle: false,
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$pct%',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                      color: scheme.onSurface,
                    ),
                  ),
                  Text('booked',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _LegendRow(
                color: scheme.primary,
                label: 'Booked',
                value: booked.toString(),
              ),
              const SizedBox(height: 16),
              _LegendRow(
                color: scheme.surfaceContainerHighest,
                label: 'Available',
                value: available.toString(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
  });
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Helpers shared by home tab ──────────────────────────────────────────────

class _ChartLoading extends StatelessWidget {
  const _ChartLoading();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(strokeWidth: 2),
    );
  }
}

class _ChartMessage extends StatelessWidget {
  const _ChartMessage(this.message);
  final String message;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        message,
        style: TextStyle(
          color: scheme.onSurface.withValues(alpha: 0.55),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

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
  if (value >= 100000) return '${(value / 100000).toStringAsFixed(1)}L';
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
  return value.toStringAsFixed(0);
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
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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
                    backgroundColor: scheme.onSurface,
                    foregroundColor: scheme.surface,
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

class _PaymentsTab extends StatelessWidget {
  const _PaymentsTab();
  @override
  Widget build(BuildContext context) => const PaymentsPage();
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
