import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../arena/services/arena_profile_providers.dart';
import '../../../core/router/app_router.dart';
import '../../bookings/presentation/bookings_page.dart';

// ─── Theme ────────────────────────────────────────────────────────────────────
class _C {
  const _C({
    required this.text,
    required this.muted,
    required this.accent,
    required this.divider,
    required this.red,
    required this.surface,
    required this.bg,
    required this.onAccent,
  });
  final Color text;
  final Color muted;
  final Color accent;
  final Color divider;
  final Color red;
  final Color surface;
  final Color bg;
  final Color onAccent;
  factory _C.of(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return _C(
      text: s.onSurface,
      muted: s.onSurface.withValues(alpha: 0.6),
      accent: s.primary,
      divider: s.outline,
      red: s.error,
      surface: s.surfaceContainerHighest,
      bg: s.surface,
      onAccent: s.onPrimary,
    );
  }
}

late _C _c;

// ─── Providers ────────────────────────────────────────────────────────────────

final _payArenaProvider = StateProvider<String?>((ref) => null);

class _PayKey {
  const _PayKey(this.arenaId, this.month);
  final String arenaId;
  final String month;
  @override
  bool operator ==(Object o) =>
      o is _PayKey && arenaId == o.arenaId && month == o.month;
  @override
  int get hashCode => Object.hash(arenaId, month);
}

class _GuestKey {
  const _GuestKey(this.arenaId, this.search);
  final String arenaId;
  final String search;
  @override
  bool operator ==(Object o) =>
      o is _GuestKey && arenaId == o.arenaId && search == o.search;
  @override
  int get hashCode => Object.hash(arenaId, search);
}

final _arenaPaymentsProvider =
    FutureProvider.autoDispose.family<ArenaPaymentsData, _PayKey>((ref, key) async {
  return ref
      .watch(hostArenaBookingRepositoryProvider)
      .fetchArenaPayments(key.arenaId, month: key.month);
});

final _arenaGuestsProvider =
    FutureProvider.autoDispose.family<List<ArenaGuest>, _GuestKey>((ref, key) async {
  return ref.watch(hostArenaBookingRepositoryProvider).fetchArenaGuests(
      key.arenaId,
      search: key.search.isEmpty ? null : key.search);
});

AsyncValue<ArenaPaymentsData> _combinePayments(
    List<AsyncValue<ArenaPaymentsData>> values) {
  if (values.any((v) => v.isLoading)) return const AsyncValue.loading();
  final error = values.where((v) => v.hasError).firstOrNull;
  if (error != null) return AsyncValue.error(error.error!, error.stackTrace!);
  final rows = values.map((v) => v.value).whereType<ArenaPaymentsData>();
  return AsyncValue.data(ArenaPaymentsData(
    checkedInBookings: rows.expand((r) => r.checkedInBookings).toList(),
    pendingBookings: rows.expand((r) => r.pendingBookings).toList(),
  ));
}

AsyncValue<List<ArenaGuest>> _combineGuests(
    List<AsyncValue<List<ArenaGuest>>> values) {
  if (values.any((v) => v.isLoading)) return const AsyncValue.loading();
  final error = values.where((v) => v.hasError).firstOrNull;
  if (error != null) return AsyncValue.error(error.error!, error.stackTrace!);
  final byPhone = <String, ArenaGuest>{};
  for (final guest in values.expand((v) => v.value ?? const <ArenaGuest>[])) {
    final key =
        guest.phone.trim().isEmpty ? guest.name : guest.phone.trim();
    final current = byPhone[key];
    if (current == null) {
      byPhone[key] = guest;
      continue;
    }
    final bookings = [...current.recentBookings, ...guest.recentBookings]
      ..sort((a, b) {
        final ad = a.bookingDate ?? DateTime(2000);
        final bd = b.bookingDate ?? DateTime(2000);
        return bd.compareTo(ad);
      });
    final lastDate = [
      current.lastDate,
      guest.lastDate,
      ...bookings.map((b) => b.bookingDate),
    ].whereType<DateTime>().fold<DateTime?>(
          null,
          (latest, date) =>
              latest == null || date.isAfter(latest) ? date : latest,
        );
    byPhone[key] = ArenaGuest(
      phone: current.phone.isNotEmpty ? current.phone : guest.phone,
      name: current.name.isNotEmpty ? current.name : guest.name,
      totalBookings: current.totalBookings + guest.totalBookings,
      totalSpentPaise: current.totalSpentPaise + guest.totalSpentPaise,
      balanceDuePaise: current.balanceDuePaise + guest.balanceDuePaise,
      lastDate: lastDate,
      recentBookings: bookings,
    );
  }
  final guests = byPhone.values.toList()
    ..sort((a, b) =>
        (b.lastDate ?? DateTime(2000)).compareTo(a.lastDate ?? DateTime(2000)));
  return AsyncValue.data(guests);
}

ArenaListing _arenaForBooking(
    List<ArenaListing> arenas, ArenaListing fallback, ArenaReservation booking) {
  for (final arena in arenas) {
    if (arena.id == booking.arenaId) return arena;
  }
  return fallback;
}

// ─── Root page ────────────────────────────────────────────────────────────────

class PaymentsPage extends ConsumerStatefulWidget {
  const PaymentsPage({super.key});
  @override
  ConsumerState<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends ConsumerState<PaymentsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) ref.read(_payArenaProvider.notifier).state = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final arenasAsync = ref.watch(ownedArenasProvider);
    return arenasAsync.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (arenas) {
        if (arenas.isEmpty) return const _Empty('No arenas yet.');
        final selectedId = ref.watch(_payArenaProvider);
        final arena = selectedId == null
            ? null
            : arenas.firstWhere((a) => a.id == selectedId,
                orElse: () => arenas.first);
        return _PaymentsBody(
            arena: arena, arenas: arenas, selectedId: selectedId);
      },
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _PaymentsBody extends StatelessWidget {
  const _PaymentsBody(
      {required this.arena, required this.arenas, required this.selectedId});
  final ArenaListing? arena;
  final List<ArenaListing> arenas;
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _c.bg,
        body: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 10),
            // Arena filter — only shown when owner has multiple arenas
            if (arenas.length > 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Consumer(
                  builder: (ctx, ref, _) => GestureDetector(
                    onTap: () => _showArenaPicker(ctx, ref),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stadium_rounded,
                            color: _c.accent, size: 15),
                        SizedBox(width: 6),
                        Text(
                          arena?.name ?? 'All arenas',
                          style: TextStyle(
                              color: _c.text,
                              fontSize: 13,
                              fontWeight: FontWeight.w800),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.unfold_more_rounded,
                            color: _c.muted, size: 14),
                      ],
                    ),
                  ),
                ),
              ),
            TabBar(
              labelColor: _c.text,
              unselectedLabelColor: _c.muted,
              labelStyle:
                  TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              unselectedLabelStyle:
                  TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              indicatorColor: _c.accent,
              indicatorWeight: 2.5,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorPadding: EdgeInsets.symmetric(horizontal: 12),
              dividerColor: _c.divider,
              tabs: [Tab(text: 'Collections'), Tab(text: 'Customers')],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _CollectionsTab(arena: arena, arenas: arenas),
                  _CustomersTab(arena: arena, arenas: arenas),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showArenaPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _c.bg,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Arena',
                style: TextStyle(
                    color: _c.text, fontSize: 18, fontWeight: FontWeight.w900)),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.select_all_rounded, color: _c.accent),
              title: Text('All arenas',
                  style: TextStyle(
                      color: _c.text, fontWeight: FontWeight.w800)),
              selected: selectedId == null,
              onTap: () {
                ref.read(_payArenaProvider.notifier).state = null;
                Navigator.pop(context);
              },
            ),
            ...arenas.map((a) => ListTile(
                  leading: Icon(Icons.stadium_outlined, color: _c.accent),
                  title: Text(a.name,
                      style: TextStyle(
                          color: _c.text, fontWeight: FontWeight.w700)),
                  selected: selectedId == a.id,
                  onTap: () {
                    ref.read(_payArenaProvider.notifier).state = a.id;
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }
}

// ─── Collections tab ──────────────────────────────────────────────────────────

class _CollectionsTab extends ConsumerStatefulWidget {
  const _CollectionsTab({required this.arena, required this.arenas});
  final ArenaListing? arena;
  final List<ArenaListing> arenas;
  @override
  ConsumerState<_CollectionsTab> createState() => _CollectionsTabState();
}

class _CollectionsTabState extends ConsumerState<_CollectionsTab>
    with AutomaticKeepAliveClientMixin {
  late String _month;
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    super.build(context);
    final async = widget.arena != null
        ? ref.watch(
            _arenaPaymentsProvider(_PayKey(widget.arena!.id, _month)))
        : _combinePayments(widget.arenas
            .map((a) =>
                ref.watch(_arenaPaymentsProvider(_PayKey(a.id, _month))))
            .toList());

    return Scaffold(
      backgroundColor: _c.bg,
      body: async.when(
        loading: () => Center(
            child: CircularProgressIndicator(
                strokeWidth: 2, color: _c.accent)),
        error: (e, _) => Center(
            child: Text('$e',
                style: TextStyle(color: _c.muted))),
        data: (data) => _CollectionsList(
          data: data,
          month: _month,
          arena: widget.arena,
          arenas: widget.arenas,
          onMonthChanged: (m) => setState(() => _month = m),
          onRefresh: _invalidatePayments,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: () => _showQuickPay(context),
              style: FilledButton.styleFrom(
                backgroundColor: _c.accent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: Icon(Icons.add_card_rounded, size: 18),
              label: Text('Record Payment',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      ),
    );
  }

  void _showQuickPay(BuildContext context) {
    final fallbackArena = widget.arena ?? widget.arenas.first;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _c.bg,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _QuickPaySheet(
          arena: widget.arena,
          arenas: widget.arenas,
          fallbackArena: fallbackArena),
    ).then((_) {
      _invalidatePayments();
      ref.invalidate(_arenaGuestsProvider);
    });
  }

  void _invalidatePayments() {
    if (widget.arena != null) {
      ref.invalidate(
          _arenaPaymentsProvider(_PayKey(widget.arena!.id, _month)));
      return;
    }
    for (final arena in widget.arenas) {
      ref.invalidate(_arenaPaymentsProvider(_PayKey(arena.id, _month)));
    }
  }
}

// ─── Quick-pay sheet ──────────────────────────────────────────────────────────

class _QuickPaySheet extends ConsumerStatefulWidget {
  const _QuickPaySheet(
      {required this.arena,
      required this.arenas,
      required this.fallbackArena});
  final ArenaListing? arena;
  final List<ArenaListing> arenas;
  final ArenaListing fallbackArena;
  @override
  ConsumerState<_QuickPaySheet> createState() => _QuickPaySheetState();
}

class _QuickPaySheetState extends ConsumerState<_QuickPaySheet> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final async = widget.arena != null
        ? ref.watch(
            _arenaGuestsProvider(_GuestKey(widget.arena!.id, _search)))
        : _combineGuests(widget.arenas
            .map((a) => ref.watch(
                _arenaGuestsProvider(_GuestKey(a.id, _search))))
            .toList());
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: _c.divider,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          SizedBox(height: 20),
          Text('Record Payment',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: _c.text)),
          SizedBox(height: 16),
          TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Search customer name or phone...',
              prefixIcon: Icon(Icons.search_rounded,
                  color: _c.muted, size: 20),
              filled: true,
              fillColor: _c.surface,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: _c.accent, width: 1.5)),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: async.when(
              loading: () =>
                  Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (guests) {
                final unpaid = <(ArenaGuest, ArenaReservation)>[];
                for (final g in guests) {
                  for (final b in g.recentBookings) {
                    if (!b.isPaid && b.status != 'CANCELLED') {
                      unpaid.add((g, b));
                    }
                  }
                }
                if (unpaid.isEmpty) {
                  return Center(
                    child: Text('No pending balances found.',
                        style: TextStyle(
                            color: _c.muted, fontWeight: FontWeight.w600)),
                  );
                }
                final now = DateTime.now();
                final nowMins = now.hour * 60 + now.minute;
                final upcoming = <(ArenaGuest, ArenaReservation)>[];
                final recent = <(ArenaGuest, ArenaReservation)>[];
                for (final item in unpaid) {
                  final b = item.$2;
                  final isFutureDate = b.bookingDate != null &&
                      b.bookingDate!.isAfter(
                          DateTime(now.year, now.month, now.day));
                  final isToday = b.bookingDate != null &&
                      DateUtils.isSameDay(b.bookingDate, now);
                  bool isUpcoming = false;
                  if (isFutureDate) {
                    isUpcoming = true;
                  } else if (isToday) {
                    if (_toMins(b.startTime) > nowMins) isUpcoming = true;
                  }
                  if (isUpcoming) {
                    upcoming.add(item);
                  } else {
                    recent.add(item);
                  }
                }
                recent.sort((a, b) {
                  final da = a.$2.bookingDate ?? DateTime(2000);
                  final db = b.$2.bookingDate ?? DateTime(2000);
                  if (da != db) return db.compareTo(da);
                  return _toMins(b.$2.startTime)
                      .compareTo(_toMins(a.$2.startTime));
                });
                upcoming.sort((a, b) {
                  final da = a.$2.bookingDate ?? DateTime(2100);
                  final db = b.$2.bookingDate ?? DateTime(2100);
                  if (da != db) return da.compareTo(db);
                  return _toMins(a.$2.startTime)
                      .compareTo(_toMins(b.$2.startTime));
                });
                return ListView(
                  children: [
                    if (recent.isNotEmpty) ...[
                      const _SectionLabel('RECENT & COMPLETED'),
                      SizedBox(height: 8),
                      ...recent.map((item) => _QuickPayRow(
                            guest: item.$1,
                            booking: item.$2,
                            arena: _arenaForBooking(widget.arenas,
                                widget.fallbackArena, item.$2),
                          )),
                      SizedBox(height: 20),
                    ],
                    if (upcoming.isNotEmpty) ...[
                      const _SectionLabel('UPCOMING'),
                      SizedBox(height: 8),
                      ...upcoming.map((item) => _QuickPayRow(
                            guest: item.$1,
                            booking: item.$2,
                            arena: _arenaForBooking(widget.arenas,
                                widget.fallbackArena, item.$2),
                          )),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickPayRow extends StatelessWidget {
  const _QuickPayRow(
      {required this.guest,
      required this.booking,
      required this.arena});
  final ArenaGuest guest;
  final ArenaReservation booking;
  final ArenaListing arena;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final date = booking.bookingDate != null
        ? DateFormat('EEE d MMM').format(booking.bookingDate!)
        : '—';
    final balance = booking.totalAmountPaise - booking.advancePaise;
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        context.push(AppRoutes.bookingDetailPath(booking.id));
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            _Avatar(guest.name, size: 40, radius: 10),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(guest.name,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _c.text)),
                  SizedBox(height: 2),
                  Text(
                      '$date · ${booking.startTime} · ${booking.unitName ?? 'General'}',
                      style: TextStyle(
                          fontSize: 11,
                          color: _c.muted,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${(balance / 100).toStringAsFixed(0)}',
                    style: TextStyle(
                        color: _c.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w900)),
                Text('DUE',
                    style: TextStyle(
                        color: _c.red,
                        fontSize: 9,
                        fontWeight: FontWeight.w900)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Collections list ─────────────────────────────────────────────────────────

class _CollectionsList extends StatelessWidget {
  const _CollectionsList({
    required this.data,
    required this.month,
    required this.arena,
    required this.arenas,
    required this.onMonthChanged,
    required this.onRefresh,
  });
  final ArenaPaymentsData data;
  final String month;
  final ArenaListing? arena;
  final List<ArenaListing> arenas;
  final ValueChanged<String> onMonthChanged;
  final VoidCallback onRefresh;

  String _fmtMonth(String m) {
    final parts = m.split('-');
    return DateFormat('MMMM yyyy')
        .format(DateTime(int.parse(parts[0]), int.parse(parts[1])));
  }

  String _prevMonth() {
    final parts = month.split('-');
    final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]) - 1);
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
  }

  String _nextMonth() {
    final parts = month.split('-');
    final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]) + 1);
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return month ==
        '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  void _showBookingList(BuildContext context, String title,
      List<ArenaReservation> bookings, Color accent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _c.bg,
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _BookingListSheet(
        title: title,
        bookings: bookings,
        arena: arena,
        arenas: arenas,
        accent: accent,
        onRefresh: onRefresh,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final unpaidBookings =
        data.pendingBookings.where((b) => !b.isPaid).toList();
    final collectedBookings = [
      ...data.checkedInBookings,
      ...data.pendingBookings.where((b) => b.isPaid),
    ];
    final collected = collectedBookings.fold(
        0, (sum, b) => sum + b.totalAmountPaise);
    final balance = unpaidBookings.fold(
        0, (sum, b) => sum + (b.totalAmountPaise - b.advancePaise));

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: EdgeInsets.only(
            bottom: 100 + MediaQuery.of(context).padding.bottom),
        children: [
          // Month navigator
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => onMonthChanged(_prevMonth()),
                  child: Icon(Icons.chevron_left_rounded,
                      size: 22, color: _c.text),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _fmtMonth(month),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: _c.text,
                        letterSpacing: -0.3),
                  ),
                ),
                if (!_isCurrentMonth)
                  GestureDetector(
                    onTap: () => onMonthChanged(_nextMonth()),
                    child: Icon(Icons.chevron_right_rounded,
                        size: 22, color: _c.text),
                  )
                else
                  Icon(Icons.chevron_right_rounded,
                      size: 22, color: Color(0xFFD1D5DB)),
              ],
            ),
          ),

          // Summary strip
          _PaySummaryStrip(
            collected: collected,
            balance: balance,
            collectedCount: collectedBookings.length,
            balanceCount: unpaidBookings.length,
            onTapCollected: () => _showBookingList(
                context, 'Collected', collectedBookings, _c.accent),
            onTapBalance: () => _showBookingList(
                context, 'Balance Due', unpaidBookings, _c.red),
          ),

          Divider(height: 1, color: _c.divider),
          SizedBox(height: 20),

          // Pending collection
          if (unpaidBookings.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: _SectionLabel(
                  'PENDING COLLECTION (${unpaidBookings.length})'),
            ),
            ...unpaidBookings.map((b) => _BookingRow(
                  booking: b,
                  arenaName: _arenaForBooking(
                          arenas, arena ?? arenas.first, b)
                      .name,
                  arenaId: _arenaForBooking(
                          arenas, arena ?? arenas.first, b)
                      .id,
                  onRefresh: onRefresh,
                  showStatusBadge: true,
                )),
            Divider(height: 1, color: _c.divider),
            SizedBox(height: 20),
          ],

          // Collected
          if (collectedBookings.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: _SectionLabel(
                  'RECENTLY COLLECTED (${collectedBookings.length})'),
            ),
            ...collectedBookings.map((b) => _BookingRow(
                  booking: b,
                  arenaName: _arenaForBooking(
                          arenas, arena ?? arenas.first, b)
                      .name,
                  arenaId: _arenaForBooking(
                          arenas, arena ?? arenas.first, b)
                      .id,
                  onRefresh: onRefresh,
                  showStatusBadge: false,
                )),
          ],

          if (collectedBookings.isEmpty && unpaidBookings.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: Text('No payment activity this month',
                    style: TextStyle(
                        color: _c.muted,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Summary strip ────────────────────────────────────────────────────────────

class _PaySummaryStrip extends StatelessWidget {
  const _PaySummaryStrip({
    required this.collected,
    required this.balance,
    required this.collectedCount,
    required this.balanceCount,
    required this.onTapCollected,
    required this.onTapBalance,
  });
  final int collected;
  final int balance;
  final int collectedCount;
  final int balanceCount;
  final VoidCallback onTapCollected;
  final VoidCallback onTapBalance;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final total = collected + balance;
    final ratio = total == 0 ? 0.0 : collected / total;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onTapCollected,
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Collected',
                          style: TextStyle(
                              fontSize: 11,
                              color: _c.muted,
                              fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text(
                        '₹${(collected / 100).toStringAsFixed(0)}',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: _c.accent,
                            letterSpacing: -1),
                      ),
                      Text(
                        '$collectedCount booking${collectedCount == 1 ? '' : 's'}',
                        style: TextStyle(
                            fontSize: 11,
                            color: _c.muted,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              Container(width: 1, height: 60, color: _c.divider),
              SizedBox(width: 20),
              GestureDetector(
                onTap: onTapBalance,
                behavior: HitTestBehavior.opaque,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Balance Due',
                        style: TextStyle(
                            fontSize: 11,
                            color: _c.muted,
                            fontWeight: FontWeight.w600)),
                    SizedBox(height: 4),
                    Text(
                      '₹${(balance / 100).toStringAsFixed(0)}',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: _c.red,
                          letterSpacing: -1),
                    ),
                    Text(
                      '$balanceCount pending',
                      style: TextStyle(
                          fontSize: 11,
                          color: _c.muted,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (total > 0) ...[
            SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                backgroundColor: Color(0xFFFEE2E2),
                valueColor: AlwaysStoppedAnimation(_c.accent),
                minHeight: 6,
              ),
            ),
            SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(ratio * 100).toStringAsFixed(0)}% collected',
                  style: TextStyle(
                      fontSize: 10,
                      color: _c.accent,
                      fontWeight: FontWeight.w700),
                ),
                if (balance > 0)
                  Text(
                    '₹${(balance / 100).toStringAsFixed(0)} remaining',
                    style: TextStyle(
                        fontSize: 10,
                        color: _c.red,
                        fontWeight: FontWeight.w700),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Booking row (flat) ───────────────────────────────────────────────────────

class _BookingRow extends StatelessWidget {
  const _BookingRow({
    required this.booking,
    required this.arenaName,
    required this.arenaId,
    required this.onRefresh,
    this.showStatusBadge = true,
  });
  final ArenaReservation booking;
  final String arenaName;
  final String arenaId;
  final VoidCallback onRefresh;
  final bool showStatusBadge;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final dateStr = booking.bookingDate != null
        ? DateFormat('EEE d MMM').format(booking.bookingDate!)
        : '—';
    final isPaid = booking.isPaid;
    final badgeColor =
        isPaid ? _c.accent : Color(0xFFD97706);
    final amount = isPaid
        ? booking.totalAmountPaise
        : (booking.totalAmountPaise - booking.advancePaise);

    return GestureDetector(
      onTap: () => context
          .push(AppRoutes.bookingDetailPath(booking.id))
          .then((_) => onRefresh()),
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 52,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.startTime,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: _c.text)),
                      SizedBox(height: 2),
                      Text(dateStr,
                          style: TextStyle(
                              fontSize: 10,
                              color: _c.muted,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Container(
                    width: 1,
                    height: 32,
                    color: _c.divider,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 14)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.displayName,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _c.text),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      SizedBox(height: 3),
                      Row(
                        children: [
                          if (booking.unitName != null) ...[
                            Text(booking.unitName!,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: _c.muted,
                                    fontWeight: FontWeight.w600)),
                            if (showStatusBadge)
                              SizedBox(width: 6),
                          ],
                          if (showStatusBadge)
                            _Badge(
                                isPaid ? 'Paid' : 'Unpaid',
                                badgeColor),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                        '₹${(amount / 100).toStringAsFixed(0)}',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: isPaid ? _c.text : _c.red)),
                    if (!isPaid)
                      Text('DUE',
                          style: TextStyle(
                              fontSize: 9,
                              color: _c.red,
                              fontWeight: FontWeight.w900)),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: _c.divider, indent: 20),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: 0.4)),
      );
}

// ─── Booking list sheet ───────────────────────────────────────────────────────

class _BookingListSheet extends StatelessWidget {
  const _BookingListSheet({
    required this.title,
    required this.bookings,
    required this.arena,
    required this.arenas,
    required this.accent,
    required this.onRefresh,
  });
  final String title;
  final List<ArenaReservation> bookings;
  final ArenaListing? arena;
  final List<ArenaListing> arenas;
  final Color accent;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final bottom = MediaQuery.of(context).padding.bottom;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (ctx, ctrl) => ListView(
        controller: ctrl,
        padding: EdgeInsets.fromLTRB(0, 16, 0, bottom + 24),
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: _c.divider,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.fromLTRB(20, 0, 20, 4),
            child: Row(children: [
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: _c.text)),
              ),
              Text(
                  '${bookings.length} booking${bookings.length == 1 ? '' : 's'}',
                  style: TextStyle(
                      fontSize: 13, color: _c.muted)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Text(
              '₹${(bookings.fold(0, (s, b) => s + (b.isPaid ? b.totalAmountPaise : (b.totalAmountPaise - b.advancePaise))) / 100).toStringAsFixed(0)} total',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: accent),
            ),
          ),
          Divider(height: 1, color: _c.divider),
          if (bookings.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                  child: Text('No bookings',
                      style: TextStyle(color: _c.muted))),
            )
          else
            ...bookings.map((b) => _BookingRow(
                  booking: b,
                  arenaName: _arenaForBooking(
                          arenas, arena ?? arenas.first, b)
                      .name,
                  arenaId: _arenaForBooking(
                          arenas, arena ?? arenas.first, b)
                      .id,
                  onRefresh: onRefresh,
                  showStatusBadge: true,
                )),
        ],
      ),
    );
  }
}

// ─── Customers tab ────────────────────────────────────────────────────────────

class _CustomersTab extends ConsumerStatefulWidget {
  const _CustomersTab({required this.arena, required this.arenas});
  final ArenaListing? arena;
  final List<ArenaListing> arenas;
  @override
  ConsumerState<_CustomersTab> createState() => _CustomersTabState();
}

class _CustomersTabState extends ConsumerState<_CustomersTab>
    with AutomaticKeepAliveClientMixin {
  final _searchCtrl = TextEditingController();
  String _search = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    super.build(context);
    final async = widget.arena != null
        ? ref.watch(
            _arenaGuestsProvider(_GuestKey(widget.arena!.id, _search)))
        : _combineGuests(widget.arenas
            .map((a) => ref.watch(
                _arenaGuestsProvider(_GuestKey(a.id, _search))))
            .toList());

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _search = v),
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: _c.text),
            decoration: InputDecoration(
              hintText: 'Search by name or phone...',
              hintStyle: TextStyle(
                  color: _c.muted, fontWeight: FontWeight.w500),
              prefixIcon: Icon(Icons.search_rounded,
                  color: _c.muted, size: 20),
              suffixIcon: _search.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        setState(() => _search = '');
                      },
                      child: Icon(Icons.close_rounded,
                          color: _c.muted, size: 18))
                  : null,
              filled: true,
              fillColor: _c.surface,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: _c.accent, width: 1.5)),
            ),
          ),
        ),
        Divider(height: 1, color: _c.divider),
        Expanded(
          child: async.when(
            loading: () => Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: _c.accent)),
            error: (e, _) => Center(
                child: Text('$e',
                    style: TextStyle(color: _c.muted))),
            data: (guests) {
              if (guests.isEmpty) {
                return _Empty(_search.isEmpty
                    ? 'No customers yet.\nWalk-in bookings appear here.'
                    : 'No results for "$_search".');
              }
              return RefreshIndicator(
                onRefresh: () async => _invalidateGuests(),
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: guests.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: _c.divider),
                  itemBuilder: (ctx, i) => _CustomerRow(
                    guest: guests[i],
                    onTap: () => _openCustomer(ctx, guests[i]),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openCustomer(BuildContext context, ArenaGuest guest) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _c.bg,
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _CustomerDetailSheet(
          guest: guest,
          arena: widget.arena,
          arenas: widget.arenas),
    );
  }

  void _invalidateGuests() {
    if (widget.arena != null) {
      ref.invalidate(
          _arenaGuestsProvider(_GuestKey(widget.arena!.id, _search)));
      return;
    }
    for (final arena in widget.arenas) {
      ref.invalidate(
          _arenaGuestsProvider(_GuestKey(arena.id, _search)));
    }
  }
}

// ─── Customer row (flat) ──────────────────────────────────────────────────────

class _CustomerRow extends StatelessWidget {
  const _CustomerRow({required this.guest, required this.onTap});
  final ArenaGuest guest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final unpaid = guest.recentBookings
        .where((b) => !b.isPaid && b.status != 'CANCELLED');
    final balancePaise = unpaid.fold(
        0, (s, b) => s + (b.totalAmountPaise - b.advancePaise));
    final hasBalance = balancePaise > 0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(children: [
          _Avatar(guest.name, size: 38, radius: 10),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(guest.name,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _c.text,
                        letterSpacing: -0.2)),
                if (guest.phone.isNotEmpty) ...[
                  SizedBox(height: 2),
                  Text(guest.phone,
                      style: TextStyle(
                          fontSize: 12,
                          color: _c.muted,
                          fontWeight: FontWeight.w500)),
                ],
                SizedBox(height: 6),
                Row(children: [
                  _Tag('${guest.totalBookings} bookings'),
                  SizedBox(width: 6),
                  _Tag(
                      '₹${(guest.totalSpentPaise / 100).toStringAsFixed(0)} spent'),
                  if (hasBalance) ...[
                    SizedBox(width: 6),
                    _Tag(
                        '₹${(balancePaise / 100).toStringAsFixed(0)} due',
                        bg: Color(0xFFFEF2F2),
                        fg: _c.red),
                  ],
                ]),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: Color(0xFFD1D5DB), size: 20),
        ]),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text, {this.bg, this.fg});
  final String text;
  final Color? bg;
  final Color? fg;

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: bg ?? _c.surface,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: fg ?? _c.muted,
                letterSpacing: 0.1)),
      );
}

// ─── Customer detail sheet ────────────────────────────────────────────────────

class _CustomerDetailSheet extends ConsumerStatefulWidget {
  const _CustomerDetailSheet(
      {required this.guest, required this.arena, required this.arenas});
  final ArenaGuest guest;
  final ArenaListing? arena;
  final List<ArenaListing> arenas;
  @override
  ConsumerState<_CustomerDetailSheet> createState() =>
      _CustomerDetailSheetState();
}

class _CustomerDetailSheetState
    extends ConsumerState<_CustomerDetailSheet> {
  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final bottom = MediaQuery.of(context).padding.bottom;
    final guest = widget.guest;
    final checkedIn =
        guest.recentBookings.where((b) => b.isPaid).toList();
    final pending = guest.recentBookings
        .where((b) => !b.isPaid && b.status != 'CANCELLED')
        .toList();
    final actualBalancePaise = pending.fold(
        0, (sum, b) => sum + (b.totalAmountPaise - b.advancePaise));

    return Container(
      decoration: BoxDecoration(
        color: _c.surface,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (ctx, ctrl) => ListView(
          controller: ctrl,
          padding:
              EdgeInsets.fromLTRB(20, 12, 20, bottom + 24),
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                    color: _c.divider,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),

            // Profile header
            Row(
              children: [
                _Avatar(guest.name, size: 52, radius: 14),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(guest.name,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: _c.text,
                              letterSpacing: -0.5)),
                      if (guest.phone.isNotEmpty) ...[
                        SizedBox(height: 3),
                        Text(guest.phone,
                            style: TextStyle(
                                fontSize: 13,
                                color: _c.muted,
                                fontWeight: FontWeight.w600)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Divider(height: 1, color: _c.divider),
            SizedBox(height: 20),

            // Stats
            Row(children: [
              _StatTile('Bookings', '${guest.totalBookings}', null),
              Container(width: 1, height: 40, color: _c.divider),
              _StatTile(
                  'Collected',
                  '₹${(guest.totalSpentPaise / 100).toStringAsFixed(0)}',
                  _c.accent),
              Container(width: 1, height: 40, color: _c.divider),
              _StatTile(
                  'Balance',
                  '₹${(actualBalancePaise / 100).toStringAsFixed(0)}',
                  actualBalancePaise > 0 ? _c.red : null),
            ]),
            SizedBox(height: 20),
            Divider(height: 1, color: _c.divider),
            SizedBox(height: 20),

            if (pending.isNotEmpty) ...[
              _SectionLabel('PENDING CHECK-IN (${pending.length})'),
              SizedBox(height: 12),
              ...pending.map((b) => _BookingHistoryRow(
                    booking: b,
                    arena: _arenaForBooking(widget.arenas,
                        widget.arena ?? widget.arenas.first, b),
                    onRefresh: () =>
                        ref.invalidate(_arenaGuestsProvider),
                  )),
              SizedBox(height: 20),
            ],

            if (checkedIn.isNotEmpty) ...[
              _SectionLabel('HISTORY (${checkedIn.length})'),
              SizedBox(height: 12),
              ...checkedIn.map((b) => _BookingHistoryRow(
                    booking: b,
                    arena: _arenaForBooking(widget.arenas,
                        widget.arena ?? widget.arenas.first, b),
                    onRefresh: () =>
                        ref.invalidate(_arenaGuestsProvider),
                  )),
            ],

            if (guest.recentBookings.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text('No recent bookings found.',
                      style: TextStyle(
                          color: _c.muted,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: color ?? _c.text,
                    letterSpacing: -0.5)),
            SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _c.muted)),
          ],
        ),
      );
}

// ─── Booking history row (flat) ───────────────────────────────────────────────

class _BookingHistoryRow extends StatelessWidget {
  const _BookingHistoryRow(
      {required this.booking,
      required this.arena,
      required this.onRefresh});
  final ArenaReservation booking;
  final ArenaListing arena;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final date = booking.bookingDate != null
        ? DateFormat('EEE d MMM').format(booking.bookingDate!)
        : '—';
    final isCheckedIn = booking.checkedInAt != null;
    final color =
        isCheckedIn ? _c.accent : Color(0xFFD97706);

    return GestureDetector(
      onTap: () => context
          .push(AppRoutes.bookingDetailPath(booking.id))
          .then((_) => onRefresh()),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$date · ${booking.startTime}–${booking.endTime}',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _c.text)),
                  SizedBox(height: 3),
                  Text(booking.unitName ?? '—',
                      style: TextStyle(
                          fontSize: 11,
                          color: _c.muted,
                          fontWeight: FontWeight.w600)),
                ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
                '₹${(booking.totalAmountPaise / 100).toStringAsFixed(0)}',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: _c.text)),
            SizedBox(height: 4),
            _Badge(isCheckedIn ? 'Paid' : 'Pending', color),
          ]),
          SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded,
              color: Color(0xFFD1D5DB), size: 18),
        ]),
      ),
    );
  }
}

// ─── Shared avatar ────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar(this.name, {required this.size, required this.radius});
  final String name;
  final double size;
  final double radius;

  static const _colors = [
    Color(0xFF6366F1), Color(0xFF0EA5E9), Color(0xFF10B981),
    Color(0xFFF59E0B), Color(0xFFEC4899), Color(0xFF8B5CF6),
  ];

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final initial =
        (name.isNotEmpty ? name[0] : '?').toUpperCase();
    final color = _colors[name.codeUnitAt(0) % _colors.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(radius)),
      alignment: Alignment.center,
      child: Text(initial,
          style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: size * 0.42)),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _c.muted,
          letterSpacing: 0.4));
}

class _Empty extends StatelessWidget {
  const _Empty(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  color: _c.muted,
                  fontWeight: FontWeight.w500)),
        ),
      );
}

int _toMins(String t) {
  try {
    final p = t.split(':').map(int.parse).toList();
    return p[0] * 60 + p[1];
  } catch (_) {
    return 0;
  }
}
