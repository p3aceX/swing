import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/rendering.dart';

import '../../arena/services/arena_profile_providers.dart';
import '../../../core/router/app_router.dart';
import 'record_payment_sheet.dart';

// ─── Theme Overrides ─────────────────────────────────────────────────────────
class _C {
  const _C({
    required this.bg,
    required this.surface,
    required this.border,
    required this.text,
    required this.muted,
    required this.accent,
    required this.accentLight,
    required this.onAccent,
  });
  final Color bg;
  final Color surface;
  final Color border;
  final Color text;
  final Color muted;
  final Color accent;
  final Color accentLight;
  final Color onAccent;
  factory _C.of(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return _C(
      bg: s.surface,
      surface: s.surfaceContainerHighest,
      border: s.outline,
      text: s.onSurface,
      muted: s.onSurface.withValues(alpha: 0.6),
      accent: s.primary,
      accentLight: s.primary.withValues(alpha: 0.12),
      onAccent: s.onPrimary,
    );
  }
}

late _C _c;

// ─── Providers ───────────────────────────────────────────────────────────────

final _selectedArenaProvider = StateProvider.autoDispose<String?>((ref) => null);

final _bookingsProvider =
    FutureProvider.autoDispose<List<ArenaReservation>>((ref) async {
  final selectedId = ref.watch(_selectedArenaProvider);
  final arenasAsync = ref.watch(ownedArenasProvider);
  final arenas = arenasAsync.valueOrNull ?? [];

  final repo = ref.watch(hostArenaBookingRepositoryProvider);

  if (selectedId != null) {
    return repo.listArenaBookings(selectedId);
  } else {
    if (arenas.isEmpty) return [];
    final results =
        await Future.wait(arenas.map((a) => repo.listArenaBookings(a.id)));
    return results.expand((x) => x).toList();
  }
});

/// Inner tab on the Bookings page. 0=Match-Up Requests, 1=Bookings.
/// Exposed so the home screen "See all" link can jump straight to Bookings.

// ─── Main page ───────────────────────────────────────────────────────────────

class BookingsPage extends ConsumerWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _c = _C.of(context);
    final arenasAsync = ref.watch(ownedArenasProvider);

    return arenasAsync.when(
      loading: () =>
          Center(child: CircularProgressIndicator(color: _c.accent)),
      error: (e, _) => _ErrorView(message: '$e'),
      data: (arenas) {
        if (arenas.isEmpty) return const _EmptyArenas();

        final selectedId = ref.watch(_selectedArenaProvider);
        final arena = selectedId == null
            ? null
            : arenas.firstWhere((a) => a.id == selectedId,
                orElse: () => arenas.first);

        return Scaffold(
          backgroundColor: _c.bg,
          body: _BookingsBody(arena: arena, arenas: arenas),
        );
      },
    );
  }
}

// ─── Main body ───────────────────────────────────────────────────────────────

class _BookingsBody extends ConsumerStatefulWidget {
  const _BookingsBody({required this.arena, required this.arenas});
  final ArenaListing? arena;
  final List<ArenaListing> arenas;

  @override
  ConsumerState<_BookingsBody> createState() => _BookingsBodyState();
}

class _BookingsBodyState extends ConsumerState<_BookingsBody> {
  String _selectedFilter = 'All';
  String _selectedUnitId = 'All';
  late DateTime _calendarMonth;
  bool _calendarExpanded = false;

  // Snapshot of booking IDs seen the last time the list rendered.
  // Anything new on the next render → "NEW" badge for ~30s.
  Set<String> _seenIds = const <String>{};
  final Set<String> _recentlyAddedIds = <String>{};
  final Map<String, Timer> _badgeTimers = <String, Timer>{};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _calendarMonth = DateTime(now.year, now.month);
  }

  @override
  void dispose() {
    for (final t in _badgeTimers.values) {
      t.cancel();
    }
    _badgeTimers.clear();
    super.dispose();
  }

  void _markNewIfNeeded(List<ArenaReservation> bookings) {
    if (_seenIds.isEmpty) {
      _seenIds = bookings.map((b) => b.id).toSet();
      return;
    }
    final currentIds = bookings.map((b) => b.id).toSet();
    final added = currentIds.difference(_seenIds);
    for (final id in added) {
      _recentlyAddedIds.add(id);
      _badgeTimers[id]?.cancel();
      _badgeTimers[id] = Timer(const Duration(seconds: 30), () {
        if (!mounted) return;
        setState(() {
          _recentlyAddedIds.remove(id);
          _badgeTimers.remove(id);
        });
      });
    }
    _seenIds = currentIds;
  }

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final today = DateTime.now();
    final allBookingsAsync = ref.watch(_bookingsProvider);

    return Scaffold(
      backgroundColor: _c.bg,
      body: Column(
        children: [
          _BigTabHeader(
            arena: widget.arena,
            arenas: widget.arenas,
          ),

          Expanded(
            child: _buildBookingsTab(context, today, allBookingsAsync),
          ),
        ],
      ),
      bottomNavigationBar: widget.arenas.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: () => _showAddBookingSheet(context, today),
                    style: FilledButton.styleFrom(
                      backgroundColor: _c.accent,
                      foregroundColor: _c.onAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 22),
                    label: const Text(
                      'Add Booking',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildBookingsTab(BuildContext context, DateTime today,
      AsyncValue<List<ArenaReservation>> allBookingsAsync) {
    return Column(
      key: ValueKey('bookings'),
      children: [
        // Status filter
        allBookingsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (e, _) => const SizedBox.shrink(),
          data: (rawBookings) => _FilterBar(
            selected: _selectedFilter,
            counts: {
              'All': rawBookings.length,
              'Confirmed':
                  rawBookings.where((b) => b.status == 'CONFIRMED').length,
              'Paid':
                  rawBookings.where((b) => b.balancePaise == 0).length,
              'Cancelled':
                  rawBookings.where((b) => b.status == 'CANCELLED').length,
            },
            onSelect: (v) => setState(() => _selectedFilter = v),
            arena: widget.arena,
            arenas: widget.arenas,
          ),
        ),

        const SizedBox(height: 8),

        _UnitFilterBar(
          units: widget.arena?.units ??
              widget.arenas.expand((a) => a.units).toList(),
          selectedId: _selectedUnitId,
          onSelect: (id) => setState(() => _selectedUnitId = id),
        ),
        const SizedBox(height: 8),
        Container(height: 1, color: _c.border),

        Expanded(
          child: allBookingsAsync.when(
            loading: () => Center(
                child:
                    CircularProgressIndicator(strokeWidth: 2, color: _c.accent)),
            error: (e, _) => _ErrorView(message: '$e'),
            data: (rawBookings) {
              final filtered = rawBookings.where((b) {
                if (_selectedFilter == 'Confirmed' && b.status != 'CONFIRMED')
                  return false;
                if (_selectedFilter == 'Paid' && b.balancePaise != 0)
                  return false;
                if (_selectedFilter == 'Cancelled' && b.status != 'CANCELLED')
                  return false;
                if (_selectedUnitId != 'All' && b.unitId != _selectedUnitId)
                  return false;
                return true;
              }).toList();

              // Track newly-arrived booking IDs across rebuilds so we can
              // flash a "NEW" badge for ~30s after creation.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _markNewIfNeeded(rawBookings);
              });

              final groups = <String, List<ArenaReservation>>{};
              for (final b in filtered) {
                final key = b.bookingDate == null
                    ? DateFormat('yyyy-MM-dd').format(today)
                    : DateFormat('yyyy-MM-dd').format(b.bookingDate!);
                groups.putIfAbsent(key, () => []).add(b);
              }
              // Pure descending: latest date first → today → past, then within
              // each date, latest start time first.
              final dateKeys = groups.keys.toList()
                ..sort((a, b) => b.compareTo(a));
              for (final dk in dateKeys) {
                groups[dk]!.sort((a, b) => b.startTime.compareTo(a.startTime));
              }

              // Build the flat list: [monthHeader, ticket, ticket, monthHeader, ticket, …]
              final items = <_TicketItem>[];
              String? lastMonthKey;
              for (final dk in dateKeys) {
                final d = DateFormat('yyyy-MM-dd').parse(dk);
                final monthKey = DateFormat('yyyy-MM').format(d);
                if (monthKey != lastMonthKey) {
                  items.add(_TicketItem.month(d));
                  lastMonthKey = monthKey;
                }
                items.add(_TicketItem.date(d, groups[dk]!));
              }

              return Column(children: [
                _MonthCalendar(
                  bookings: rawBookings,
                  month: _calendarMonth,
                  expanded: _calendarExpanded,
                  onMonthChanged: (m) => setState(() => _calendarMonth = m),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? _EmptyBookings(
                          onAdd: widget.arenas.isEmpty
                              ? null
                              : () => _showAddBookingSheet(context, today),
                          isFiltered: rawBookings.isNotEmpty,
                        )
                      : RefreshIndicator(
                          color: _c.accent,
                          backgroundColor: _c.surface,
                          onRefresh: () =>
                              ref.refresh(_bookingsProvider.future),
                          child: ListView.builder(
                            padding:
                                const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            itemCount: items.length,
                            itemBuilder: (context, i) {
                              final item = items[i];
                              if (item.isMonthHeader) {
                                return _MonthSectionHeader(date: item.date);
                              }
                              return _DateTicket(
                                date: item.date,
                                today: today,
                                bookings: item.bookings,
                                arenas: widget.arenas,
                                newIds: _recentlyAddedIds,
                                onAdd: () =>
                                    _showAddBookingSheet(context, item.date),
                                onBookingTap: (b) => _showBookingDetail(
                                  context,
                                  b,
                                  widget.arenas
                                      .firstWhere((a) => a.id == b.arenaId,
                                          orElse: () => widget.arenas.first)
                                      .name,
                                  b.arenaId,
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ]);
            },
          ),
        ),
      ],
    );
  }

  void _showAddBookingSheet(BuildContext context, DateTime date) {
    final arena = widget.arena ?? widget.arenas.first;
    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => AddBookingSheet(arena: arena, date: date),
        ))
        .then((_) => ref.invalidate(_bookingsProvider));
  }

  void _showBookingDetail(BuildContext context, ArenaReservation booking,
      String arenaName, String arenaId) {
    context.push(AppRoutes.bookingDetailPath(booking.id)).then((_) {
      ref.invalidate(_bookingsProvider);
    });
  }

}

// ─── Tab bar ─────────────────────────────────────────────────────────────────

class _BigTabHeader extends ConsumerWidget {
  const _BigTabHeader({
    required this.arena,
    required this.arenas,
  });
  final ArenaListing? arena;
  final List<ArenaListing> arenas;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _c = _C.of(context);
    final top = MediaQuery.of(context).padding.top;
    return SizedBox(height: top, child: ColoredBox(color: _c.bg));
  }

  void _showArenaPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _c.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Switch Arena',
              style: TextStyle(
                  color: _c.text, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 16),
            ...arenas.map(
              (a) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.stadium_rounded, color: _c.accent),
                title: Text(a.name,
                    style: TextStyle(
                        color: _c.text, fontWeight: FontWeight.w600)),
                trailing: a.id == arena?.id
                    ? Icon(Icons.check_rounded, color: _c.accent)
                    : null,
                onTap: () {
                  ref
                      .read(_selectedArenaProvider.notifier)
                      .state = a.id;
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Booking type option ──────────────────────────────────────────────────────

class _BookingTypeOption extends StatelessWidget {
  const _BookingTypeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _c.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _c.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _c.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _c.border),
              ),
              child: Icon(icon, color: _c.text, size: 20),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: _c.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  SizedBox(height: 2),
                  Text(subtitle,
                      style:
                          TextStyle(color: _c.muted, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: _c.muted, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Calendar ────────────────────────────────────────────────────────────────

// ─── Month Grid Calendar ─────────────────────────────────────────────────────

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.bookings,
    required this.month,
    required this.expanded,
    required this.onMonthChanged,
  });
  final List<ArenaReservation> bookings;
  final DateTime month;
  final bool expanded;
  final ValueChanged<DateTime> onMonthChanged;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final today = DateTime.now();
    final isCurrentMonth =
        month.year == today.year && month.month == today.month;

    // Count non-cancelled bookings per date
    final counts = <String, int>{};
    for (final b in bookings) {
      if (b.status == 'CANCELLED' || b.bookingDate == null) continue;
      final key = DateFormat('yyyy-MM-dd').format(b.bookingDate!);
      counts[key] = (counts[key] ?? 0) + 1;
    }

    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstDay = DateTime(month.year, month.month, 1);
    final startOffset = (firstDay.weekday - 1) % 7; // Mon=0 … Sun=6
    final totalCells = startOffset + daysInMonth;
    final numWeeks = (totalCells / 7).ceil();

    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      color: _c.bg,
      child: Column(children: [
        // Collapsible grid
        AnimatedCrossFade(
          duration: Duration(milliseconds: 220),
          crossFadeState:
              expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Column(children: [
              // Month nav
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                child: Row(children: [
                  Text(DateFormat('MMMM yyyy').format(month),
                      style: TextStyle(
                          color: _c.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w800)),
                  Spacer(),
                  GestureDetector(
                    onTap: () =>
                        onMonthChanged(DateTime(month.year, month.month - 1)),
                    child: Icon(Icons.chevron_left_rounded,
                        color: _c.muted, size: 20),
                  ),
                  SizedBox(width: 4),
                  GestureDetector(
                    onTap: () =>
                        onMonthChanged(DateTime(month.year, month.month + 1)),
                    child: Icon(Icons.chevron_right_rounded,
                        color: _c.muted, size: 20),
                  ),
                ]),
              ),

              // Day-of-week headers
              Row(
                children: dayLabels
                    .map((d) => Expanded(
                          child: Center(
                            child: Text(d,
                                style: TextStyle(
                                    color: _c.muted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ))
                    .toList(),
              ),
              SizedBox(height: 4),

              // Week rows
              for (var w = 0; w < numWeeks; w++)
                Row(
                  children: List.generate(7, (dow) {
                    final cellIdx = w * 7 + dow;
                    final day = cellIdx - startOffset + 1;

                    // Blank cell: before month start, after month end,
                    // or before today in current month
                    if (day < 1 ||
                        day > daysInMonth ||
                        (isCurrentMonth && day < today.day)) {
                      return Expanded(child: SizedBox(height: 38));
                    }

                    final date = DateTime(month.year, month.month, day);
                    final dateKey = DateFormat('yyyy-MM-dd').format(date);
                    final count = counts[dateKey] ?? 0;
                    final isToday = DateUtils.isSameDay(date, today);

                    return Expanded(
                      child: Container(
                        height: 38,
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isToday
                              ? _c.accent
                              : count > 0
                                  ? _c.accentLight
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('$day',
                                style: TextStyle(
                                    color: isToday ? Colors.white : _c.text,
                                    fontSize: 12,
                                    fontWeight: isToday
                                        ? FontWeight.w900
                                        : FontWeight.w600)),
                            if (count > 0)
                              Text('$count',
                                  style: TextStyle(
                                      color: isToday
                                          ? Colors.white.withValues(alpha: .85)
                                          : _c.accent,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
            ]),
          ),
        ),

      ]),
    );
  }
}

class _CompactCalendar extends StatelessWidget {
  const _CompactCalendar({
    required this.month,
    required this.selectedDate,
    required this.summary,
    required this.onDateSelected,
    required this.onMonthChanged,
  });

  final DateTime month;
  final DateTime selectedDate;
  final Map<String, ArenaDaySummary> summary;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<DateTime> onMonthChanged;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final today = DateTime.now();
    final isCurrentMonth =
        month.year == today.year && month.month == today.month;
    final startDay = isCurrentMonth ? today.day : 1;
    final itemCount = daysInMonth - startDay + 1;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(month),
                  style: TextStyle(
                      color: _c.text, fontSize: 18, fontWeight: FontWeight.w900),
                ),
                Row(
                  children: [
                    _NavBtn(
                        Icons.chevron_left_rounded,
                        () => onMonthChanged(
                            DateTime(month.year, month.month - 1))),
                    SizedBox(width: 12),
                    _NavBtn(
                        Icons.chevron_right_rounded,
                        () => onMonthChanged(
                            DateTime(month.year, month.month + 1))),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 82,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: itemCount,
              separatorBuilder: (_, __) => SizedBox(width: 12),
              itemBuilder: (context, i) {
                final day = startDay + i;
                final date = DateTime(month.year, month.month, day);
                final sel = DateUtils.isSameDay(date, selectedDate);
                final isToday = DateUtils.isSameDay(date, today);
                final key = DateFormat('yyyy-MM-dd').format(date);
                final has = (summary[key]?.count ?? 0) > 0;

                return GestureDetector(
                  onTap: () => onDateSelected(date),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: 54,
                    decoration: BoxDecoration(
                      color: sel
                          ? _c.accent
                          : (isToday
                              ? _c.accent.withValues(alpha: .08)
                              : _c.surface),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: sel
                              ? _c.accent
                              : (isToday
                                  ? _c.accent.withValues(alpha: .4)
                                  : _c.border)),
                      boxShadow: sel
                          ? [
                              BoxShadow(
                                color: _c.accent.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              )
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEE').format(date).toUpperCase(),
                          style: TextStyle(
                              color: sel ? Colors.white : _c.muted,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5),
                        ),
                        SizedBox(height: 6),
                        Text(
                          '$day',
                          style: TextStyle(
                              color: sel ? Colors.white : _c.text,
                              fontSize: 18,
                              fontWeight: FontWeight.w900),
                        ),
                        if (has) ...[
                          SizedBox(height: 6),
                          Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                  color: sel ? Colors.white : _c.accent,
                                  shape: BoxShape.circle)),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  const _NavBtn(this.icon, this.onTap);
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: _c.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _c.border)),
        child: Icon(icon, color: _c.text, size: 18),
      ),
    );
  }
}

// ─── Booking Tile ────────────────────────────────────────────────────────────

class BookingCard extends ConsumerStatefulWidget {
  BookingCard({
    super.key,
    required this.booking,
    required this.onTap,
    required this.arenas,
    this.isNextUp = false,
  });
  final ArenaReservation booking;
  final VoidCallback onTap;
  final List<ArenaListing> arenas;
  final bool isNextUp;

  @override
  ConsumerState<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends ConsumerState<BookingCard> {
  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final booking = widget.booking;
    final amount = booking.totalAmountPaise / 100;
    final isCancelled = booking.status == 'CANCELLED';
    final isPaid = booking.balancePaise == 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paidCardColor =
        isDark ? const Color(0xFF2D0F0F) : const Color(0xFFFEE2E2);
    final paidBorderColor =
        isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFCA5A5);

    final String? unitLabel;
    final isAllSelected = ref.watch(_selectedArenaProvider) == null;
    if (!isAllSelected) {
      unitLabel = booking.unitName;
    } else {
      final arena = widget.arenas
          .where((a) => a.id == booking.arenaId)
          .firstOrNull;
      unitLabel = arena?.name.split(' ').first;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isPaid ? paidCardColor : _c.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isPaid
                  ? paidBorderColor
                  : widget.isNextUp
                      ? _c.accent
                      : _c.border,
            ),
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Time
              SizedBox(
                width: 52,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      booking.startTime,
                      style: TextStyle(
                          color: isCancelled ? _c.muted : _c.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          decoration: isCancelled
                              ? TextDecoration.lineThrough
                              : null),
                    ),
                    Text(
                      _durationLabel(_durationMins(
                          booking.startTime, booking.endTime)),
                      style: TextStyle(
                          color: _c.muted,
                          fontSize: 10,
                          height: 1.2,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              // Name + meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      booking.displayName,
                      style: TextStyle(
                          color: isCancelled ? _c.muted : _c.text,
                          fontSize: 13,
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                          decoration: isCancelled
                              ? TextDecoration.lineThrough
                              : null),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (unitLabel != null && unitLabel.isNotEmpty)
                      Text(
                        unitLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: _c.muted,
                            fontSize: 10,
                            height: 1.2,
                            fontWeight: FontWeight.w700),
                      ),
                  ],
                ),
              ),
              // Amount + dot
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: booking.isPaid
                          ? _c.accent
                          : const Color(0xFFD97706),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₹${amount.toStringAsFixed(0)}',
                    style: TextStyle(
                        color: isCancelled ? _c.muted : _c.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w900),
                  ),
                  if (booking.displayPhone.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    _QuickAction(
                        Icons.phone_rounded,
                        () => launchUrl(Uri.parse(
                            'tel:${booking.displayPhone}'))),
                    const SizedBox(width: 4),
                    _QuickAction(
                        Icons.chat_bubble_rounded,
                        () => launchUrl(Uri.parse(
                            'https://wa.me/${booking.displayPhone.replaceAll(RegExp(r'[^0-9]'), '')}'))),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.replaceAll('_', ' '),
        style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction(this.icon, this.onTap);
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: _c.bg,
            shape: BoxShape.circle,
            border: Border.all(color: _c.border)),
        child: Icon(icon, color: _c.accent, size: 13),
      ),
    );
  }
}

// ─── Filter Bar ──────────────────────────────────────────────────────────────

class _FilterBar extends ConsumerWidget {
  const _FilterBar({
    required this.selected,
    required this.onSelect,
    required this.counts,
    required this.arena,
    required this.arenas,
  });
  final String selected;
  final ValueChanged<String> onSelect;
  final Map<String, int> counts;
  final ArenaListing? arena;
  final List<ArenaListing> arenas;

  void _showArenaPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Switch arena',
                style: TextStyle(
                  color: _c.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('All arenas',
                    style: TextStyle(
                        color: _c.text, fontWeight: FontWeight.w600)),
                trailing: arena == null
                    ? Icon(Icons.check_rounded, color: _c.accent)
                    : null,
                onTap: () {
                  ref.read(_selectedArenaProvider.notifier).state = null;
                  Navigator.pop(context);
                },
              ),
              for (final a in arenas)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(a.name,
                      style: TextStyle(
                          color: _c.text, fontWeight: FontWeight.w600)),
                  trailing: a.id == arena?.id
                      ? Icon(Icons.check_rounded, color: _c.accent)
                      : null,
                  onTap: () {
                    ref.read(_selectedArenaProvider.notifier).state = a.id;
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _c = _C.of(context);
    final filters = ['All', 'Confirmed', 'Paid', 'Cancelled'];
    final arenaLabel = arena?.name ?? 'All arenas';
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: arenas.isEmpty
                ? null
                : () => _showArenaPicker(context, ref),
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      arenaLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: _c.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      size: 18, color: _c.muted),
                ],
              ),
            ),
          ),
          Container(
            width: 1,
            height: 14,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: _c.border,
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(right: 16),
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, i) {
                final f = filters[i];
                final count = counts[f] ?? 0;
                final sel = f == selected;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelect(f),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            f,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight:
                                  sel ? FontWeight.w800 : FontWeight.w600,
                              letterSpacing: -0.1,
                              color: sel ? _c.accent : _c.muted,
                            ),
                          ),
                          if (count > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: sel
                                    ? _c.accent.withValues(alpha: 0.7)
                                    : _c.muted.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        height: 2,
                        width: sel ? 18 : 0,
                        decoration: BoxDecoration(
                          color: _c.accent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitFilterBar extends StatelessWidget {
  const _UnitFilterBar(
      {required this.units, required this.selectedId, required this.onSelect});
  final List<ArenaUnitOption> units;
  final String selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: units.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final String id;
          final String label;
          if (i == 0) {
            id = 'All';
            label = 'All Nets';
          } else {
            final u = units[i - 1];
            id = u.id;
            label = u.name;
          }
          final sel = id == selectedId;
          return GestureDetector(
            onTap: () => onSelect(id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: sel ? _c.accent : _c.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: sel ? _c.accent : _c.border),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: sel ? _c.onAccent : _c.muted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Detail Sheet ────────────────────────────────────────────────────────────

class BookingDetailSheet extends ConsumerStatefulWidget {
  BookingDetailSheet(
      {super.key,
      required this.booking,
      required this.arenaName,
      required this.arenaId});
  final ArenaReservation booking;
  final String arenaName;
  final String arenaId;
  @override
  ConsumerState<BookingDetailSheet> createState() => _BookingDetailSheetState();
}

class _BookingDetailSheetState extends ConsumerState<BookingDetailSheet> {
  final GlobalKey _boundaryKey = GlobalKey();
  bool _loading = false;
  late ArenaReservation _booking;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
  }

  Future<void> _action(
      Future<ArenaReservation> Function() fn, String msg) async {
    setState(() => _loading = true);
    try {
      final updated = await fn();
      setState(() => _booking = updated);
      if (mounted) _snack(msg);
    } catch (e) {
      if (mounted) _snack('Error: $e', err: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String m, {bool err = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(m), backgroundColor: err ? Colors.red : _c.bg));

  Future<void> _sharePassImage() async {
    try {
      final boundary = _boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file =
          await File('${tempDir.path}/swing-pass-${_booking.id}.png').create();
      await file.writeAsBytes(bytes);

      await Share.shareXFiles([XFile(file.path)],
          text: 'Check out your Swing Arena Pass!');
    } catch (e) {
      _snack('Sharing failed: $e', err: true);
    }
  }

  Future<void> _shareTicketPdf() async {
    final pdf = pw.Document();

    final dateStr = _booking.bookingDate != null
        ? DateFormat('EEEE, d MMMM yyyy').format(_booking.bookingDate!)
        : 'Scheduled Date';

    final shortId = _booking.id.length > 7
        ? _booking.id.substring(_booking.id.length - 7).toUpperCase()
        : _booking.id.toUpperCase();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(32),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(20),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('SWING ARENA PASS',
                    style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey700,
                        letterSpacing: 2)),
                pw.SizedBox(height: 24),
                pw.Text('CUSTOMER',
                    style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey500,
                        fontWeight: pw.FontWeight.bold)),
                pw.Text(_booking.displayName.toUpperCase(),
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 32),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('DATE',
                              style: pw.TextStyle(
                                  fontSize: 8, color: PdfColors.grey500)),
                          pw.Text(dateStr,
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ]),
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('TIME',
                              style: pw.TextStyle(
                                  fontSize: 8, color: PdfColors.grey500)),
                          pw.Text('${_booking.startTime} - ${_booking.endTime}',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ]),
                  ],
                ),
                pw.SizedBox(height: 24),
                pw.Divider(color: PdfColors.grey300),
                pw.SizedBox(height: 24),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('ARENA',
                              style: pw.TextStyle(
                                  fontSize: 8, color: PdfColors.grey500)),
                          pw.Text(widget.arenaName.toUpperCase(),
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ]),
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('UNIT',
                              style: pw.TextStyle(
                                  fontSize: 8, color: PdfColors.grey500)),
                          pw.Text(_booking.unitName?.toUpperCase() ?? 'GENERAL',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ]),
                  ],
                ),
                pw.SizedBox(height: 40),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('BOOKING REFERENCE',
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Text(shortId,
                          style: pw.TextStyle(
                              fontSize: 11, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
                pw.Spacer(),
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text('THANK YOU FOR CHOOSING SWING',
                      style: pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey400,
                          fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(
        bytes: await pdf.save(), filename: 'swing-pass-${_booking.id}.pdf');
  }

  void _sendWhatsApp() {
    var phone = _booking.displayPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.isEmpty) return;

    if (phone.length == 10) phone = '91$phone';

    final date = _booking.bookingDate != null
        ? DateFormat('EEEE, d MMM').format(_booking.bookingDate!)
        : 'scheduled date';

    final shortId = _booking.id.length > 7
        ? _booking.id.substring(_booking.id.length - 7).toUpperCase()
        : _booking.id.toUpperCase();

    final msg = '''
*BOOKING CONFIRMED* ✅
---------------------------
👤 *Customer:* ${_booking.displayName}
📅 *Date:* $date
⏰ *Time:* ${_booking.startTime} - ${_booking.endTime}
🏟️ *Arena:* ${widget.arenaName.toUpperCase()}
📍 *Unit:* ${_booking.unitName ?? 'General'}
---------------------------
🆔 *Ref:* $shortId
💰 *Amount:* ₹${(_booking.totalAmountPaise / 100).toStringAsFixed(0)}
---------------------------
_See you at the arena!_ 🏏
''';

    final uri = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: phone,
      queryParameters: {'text': msg},
    );

    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _recordPayment() async {
    await showRecordPaymentSheet(
      context,
      booking: _booking,
      onRecorded: () async {
        final repo = ref.read(hostArenaBookingRepositoryProvider);
        final updated = await repo.listArenaBookings(_booking.arenaId,
            date: _fmtDate(_booking.bookingDate!));
        if (mounted) {
          setState(() {
            _booking = updated.firstWhere((b) => b.id == _booking.id,
                orElse: () => _booking);
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final repo = ref.read(hostArenaBookingRepositoryProvider);
    final statusColor = _statusColor(_booking.status);
    final duration =
        _durationLabel(_durationMins(_booking.startTime, _booking.endTime));

    final shortId = _booking.id.length > 7
        ? _booking.id.substring(_booking.id.length - 7).toUpperCase()
        : _booking.id.toUpperCase();

    final remainingPaise = _booking.totalAmountPaise - _booking.advancePaise;

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 24),
      decoration: BoxDecoration(
        color: _c.border,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                  color: _c.border,
                  borderRadius: BorderRadius.circular(10))),
          SizedBox(height: 24),

          // PREMIUM TICKET CARD (Capturable as Image)
          RepaintBoundary(
            key: _boundaryKey,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _c.surface,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 20,
                      offset: Offset(0, 10))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BRANDING HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _c.accent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.bolt_rounded,
                                color: _c.surface, size: 14),
                          ),
                          SizedBox(width: 10),
                          Text('SWING ARENA',
                              style: TextStyle(
                                  color: _c.text,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _c.border,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _c.border),
                        ),
                        child: Text('OFFICIAL PASS',
                            style: TextStyle(
                                color: _c.muted,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5)),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Divider(height: 1, color: _c.border),
                  SizedBox(height: 24),

                  Text('CUSTOMER',
                      style: TextStyle(
                          color: _c.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2)),
                  SizedBox(height: 6),
                  Text(_booking.displayName.toUpperCase(),
                      style: TextStyle(
                          color: _c.text,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5)),

                  SizedBox(height: 32),

                  // TIME PATH
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_booking.startTime,
                          style: TextStyle(
                              color: _c.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w800)),
                      Text(duration,
                          style: TextStyle(
                              color: _c.text,
                              fontSize: 13,
                              fontWeight: FontWeight.w900)),
                      Text(_booking.endTime,
                          style: TextStyle(
                              color: _c.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                          radius: 3, backgroundColor: _c.text),
                      Expanded(
                          child: Container(
                              height: 1.5, color: _c.text)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.sports_cricket_rounded,
                            size: 20, color: _c.accent),
                      ),
                      Expanded(
                          child: Container(
                              height: 1.5, color: _c.border)),
                      CircleAvatar(
                          radius: 3,
                          backgroundColor: _c.border,
                          child: CircleAvatar(
                              radius: 2, backgroundColor: Colors.white)),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ARENA',
                                style: TextStyle(
                                    color: _c.muted,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700)),
                            Text(widget.arenaName.toUpperCase(),
                                style: TextStyle(
                                    color: _c.text,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('UNIT/COURT',
                              style: TextStyle(
                                  color: _c.muted,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700)),
                          Text(_booking.unitName?.toUpperCase() ?? 'GENERAL',
                              style: TextStyle(
                                  color: _c.text,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 32),
                  Divider(height: 1, color: _c.border),
                  SizedBox(height: 24),

                  Text('BOOKING REFERENCE',
                      style: TextStyle(
                          color: _c.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2)),
                  SizedBox(height: 6),
                  Text(shortId,
                      style: TextStyle(
                          color: _c.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0)),

                  SizedBox(height: 32),

                  // BOTTOM GRID
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _TicketStat(
                          label: 'STATUS',
                          value: _booking.status.replaceAll('_', ' '),
                          color: statusColor),
                      _TicketStat(
                          label: 'PAYMENT',
                          value: _booking.paymentMode ?? 'PENDING'),
                      _TicketStat(
                          label: 'AMOUNT',
                          value:
                              '₹${(_booking.totalAmountPaise / 100).toStringAsFixed(0)}',
                          isBold: true),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // QUICK ACTIONS
          if (_booking.displayPhone.isNotEmpty)
            Row(
              children: [
                Expanded(
                  child: _ActionTile(
                    onTap: () =>
                        launchUrl(Uri.parse('tel:${_booking.displayPhone}')),
                    icon: Icons.phone_rounded,
                    label: 'Call',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _ActionTile(
                    onTap: _sendWhatsApp,
                    icon: Icons.chat_bubble_rounded,
                    label: 'WhatsApp',
                    iconColor: Color(0xFF25D366),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _ActionTile(
                    onTap: _sharePassImage,
                    icon: Icons.badge_rounded,
                    label: 'Pass',
                    iconColor: _c.accent,
                  ),
                ),
              ],
            ),

          SizedBox(height: 24),

          if (_loading)
            CircularProgressIndicator(color: _c.accent)
          else ...[
            if (!_booking.isPaid && _booking.status != 'CANCELLED')
              Column(
                children: [
                  if (remainingPaise > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Color(0xFFFEE2E2)),
                        ),
                        child: Text(
                            'BALANCE DUE: ₹${(remainingPaise / 100).toStringAsFixed(0)}',
                            style: TextStyle(
                                color: Color(0xFFDC2626),
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                letterSpacing: 0.5)),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _recordPayment,
                      style: FilledButton.styleFrom(
                        backgroundColor: _c.accent,
                        foregroundColor: _c.onAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Record Payment & Checkout'),
                    ),
                  ),
                ],
              )
            else if (_booking.isPaid)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _c.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _c.accent.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, color: _c.accent, size: 20),
                    SizedBox(width: 10),
                    Text('BOOKING SETTLED',
                        style: TextStyle(
                            color: _c.accent,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 1.0)),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _PaymentResult {
  const _PaymentResult({required this.mode, required this.amountPaise});
  final String mode;
  final int amountPaise;
}

class _CheckoutSheet extends StatefulWidget {
  const _CheckoutSheet({required this.booking});
  final ArenaReservation booking;

  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet> {
  final _amountCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();

  late int _remainingPaise;

  @override
  void initState() {
    super.initState();
    _remainingPaise =
        widget.booking.totalAmountPaise - widget.booking.advancePaise;
    _amountCtrl.text = (_remainingPaise / 100).toStringAsFixed(0);
  }

  void _updateCalculations() {
    final discount = (double.tryParse(_discountCtrl.text) ?? 0);
    final discountPaise = (discount * 100).round();
    final toCollect = (_remainingPaise - discountPaise).clamp(0, 99999999);
    _amountCtrl.text = (toCollect / 100).toStringAsFixed(0);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final total = widget.booking.totalAmountPaise / 100;
    final advance = widget.booking.advancePaise / 100;
    final discount = (double.tryParse(_discountCtrl.text) ?? 0);

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(
            24,
            12,
            24,
            MediaQuery.of(context).viewInsets.bottom +
                MediaQuery.of(context).padding.bottom +
                32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: _c.border,
                        borderRadius: BorderRadius.circular(2)))),
            SizedBox(height: 24),
            Text('Checkout',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w900, color: _c.text)),
            SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: _c.bg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _c.border)),
              child: Column(
                children: [
                  _CheckoutRow('Booking Total', '₹${total.toStringAsFixed(0)}'),
                  if (advance > 0) ...[
                    SizedBox(height: 12),
                    _CheckoutRow(
                        'Advance Paid', '- ₹${advance.toStringAsFixed(0)}',
                        color: _c.accent),
                  ],
                  Divider(height: 32),
                  Row(
                    children: [
                      Text('Discount (₹)',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _c.muted)),
                      Spacer(),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _discountCtrl,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.right,
                          onChanged: (_) => _updateCalculations(),
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 15),
                          decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: '0'),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 32),
                  _CheckoutRow('Net Payable',
                      '₹${(_remainingPaise / 100 - discount).toStringAsFixed(0)}',
                      isTotal: true),
                ],
              ),
            ),
            SizedBox(height: 32),
            Text('AMOUNT TO COLLECT',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _c.muted,
                    letterSpacing: 1.0)),
            SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w900, color: _c.text),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w900, color: _c.muted),
                filled: true,
                fillColor: _c.bg,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
              ),
            ),
            SizedBox(height: 32),
            Text('PAYMENT MODE',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _c.muted,
                    letterSpacing: 1.0)),
            SizedBox(height: 16),
            Row(
              children: [
                _ModeTile(
                    icon: Icons.payments_rounded,
                    label: 'CASH',
                    color: Colors.blue,
                    onTap: () => _done('CASH')),
                SizedBox(width: 12),
                _ModeTile(
                    icon: Icons.qr_code_scanner_rounded,
                    label: 'UPI',
                    color: Color(0xFF6366F1),
                    onTap: () => _done('UPI')),
                SizedBox(width: 12),
                _ModeTile(
                    icon: Icons.account_balance_rounded,
                    label: 'ONLINE',
                    color: _c.accent,
                    onTap: () => _done('ONLINE')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _done(String mode) {
    final amount = (double.tryParse(_amountCtrl.text) ?? 0);
    Navigator.pop(context,
        _PaymentResult(mode: mode, amountPaise: (amount * 100).round()));
  }
}

class _CheckoutRow extends StatelessWidget {
  const _CheckoutRow(this.label, this.value,
      {this.color, this.isTotal = false});
  final String label;
  final String value;
  final Color? color;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return Row(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: isTotal ? 15 : 13,
                fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
                color: isTotal ? _c.text : _c.muted)),
        Spacer(),
        Text(value,
            style: TextStyle(
                fontSize: isTotal ? 20 : 15,
                fontWeight: FontWeight.w900,
                color: color ?? _c.text)),
      ],
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: _c.bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _c.border),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: .1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(height: 12),
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: _c.text,
                      letterSpacing: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.onTap,
    required this.icon,
    required this.label,
    this.iconColor,
  });

  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: iconColor ?? _c.text),
            SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _c.text)),
          ],
        ),
      ),
    );
  }
}

class _TicketStat extends StatelessWidget {
  const _TicketStat(
      {required this.label,
      required this.value,
      this.color,
      this.isBold = false});
  final String label;
  final String value;
  final Color? color;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: _c.muted,
                fontSize: 9,
                fontWeight: FontWeight.w700)),
        SizedBox(height: 4),
        Text(value.toUpperCase(),
            style: TextStyle(
                color: color ?? _c.text,
                fontSize: 13,
                fontWeight: isBold ? FontWeight.w900 : FontWeight.w800)),
      ],
    );
  }
}

class _DetailInfoRow extends StatelessWidget {
  const _DetailInfoRow(this.label, this.value, this.icon,
      {this.isBold = false});
  final String label;
  final String value;
  final IconData icon;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: _c.muted),
        SizedBox(width: 12),
        Text(label,
            style: TextStyle(
                color: _c.muted, fontSize: 13, fontWeight: FontWeight.w600)),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: _c.text,
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

Color _statusColor(String s) => switch (s.toUpperCase()) {
      'CONFIRMED' => _c.accent,
      'PENDING_PAYMENT' => Colors.orange,
      'CANCELLED' => Colors.red,
      'CHECKED_IN' => Colors.blue,
      _ => _c.muted,
    };

String _moneyShort(int p) {
  final n = (p / 100).round();
  final s = n.toString();
  if (s.length <= 3) return '₹$s';
  final last3 = s.substring(s.length - 3);
  String rest = s.substring(0, s.length - 3);
  final groups = <String>[];
  while (rest.length > 2) {
    groups.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) groups.insert(0, rest);
  return '₹${groups.join(',')},$last3';
}

int _toMins(String t) {
  final p = t.split(':').map(int.parse).toList();
  return p[0] * 60 + p[1];
}

int _durationMins(String s, String e) => _toMins(e) - _toMins(s);

String _durationLabel(int m) {
  if (m < 60) return '${m}m';
  return '${m ~/ 60}h ${m % 60 > 0 ? '${m % 60}m' : ''}';
}

class _EmptyArenas extends StatelessWidget {
  const _EmptyArenas();
  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return Center(
        child: Text('No arenas found', style: TextStyle(color: _c.muted)));
  }
}

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings({required this.onAdd, this.isFiltered = false});
  final VoidCallback? onAdd;
  final bool isFiltered;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: _c.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: _c.border)),
              child: Icon(Icons.event_note_rounded,
                  size: 36, color: _c.muted.withValues(alpha: .5)),
            ),
            SizedBox(height: 16),
            Text(
              isFiltered ? 'No matching bookings' : 'No bookings yet',
              style: TextStyle(
                  color: _c.text, fontSize: 15, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 6),
            Text(
              isFiltered
                  ? 'Try changing the filter above'
                  : 'Tap + to add your first booking',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _c.muted, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            if (!isFiltered && onAdd != null) ...[
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onAdd,
                  style: FilledButton.styleFrom(
                    backgroundColor: _c.accent,
                    foregroundColor: _c.onAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Add New Booking'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Date ticket list (vertical, NBA-ticket style) ──────────────────────────

class _TicketItem {
  _TicketItem._({
    required this.isMonthHeader,
    required this.date,
    this.bookings = const [],
  });
  factory _TicketItem.month(DateTime d) =>
      _TicketItem._(isMonthHeader: true, date: d);
  factory _TicketItem.date(DateTime d, List<ArenaReservation> bs) =>
      _TicketItem._(isMonthHeader: false, date: d, bookings: bs);

  final bool isMonthHeader;
  final DateTime date;
  final List<ArenaReservation> bookings;
}

class _MonthSectionHeader extends StatelessWidget {
  const _MonthSectionHeader({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 18, 2, 10),
      child: Row(
        children: [
          Text(
            DateFormat('MMMM yyyy').format(date).toUpperCase(),
            style: TextStyle(
              color: _c.muted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              color: _c.border.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateTicket extends StatelessWidget {
  const _DateTicket({
    required this.date,
    required this.today,
    required this.bookings,
    required this.arenas,
    required this.onBookingTap,
    required this.onAdd,
    this.newIds = const <String>{},
  });

  final DateTime date;
  final DateTime today;
  final List<ArenaReservation> bookings;
  final List<ArenaListing> arenas;
  final ValueChanged<ArenaReservation> onBookingTap;
  final VoidCallback onAdd;
  final Set<String> newIds;

  static int _timeToMins(String t) {
    final p = t.split(':');
    if (p.length < 2) return 0;
    return (int.tryParse(p[0]) ?? 0) * 60 + (int.tryParse(p[1]) ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final isToday = DateUtils.isSameDay(date, today);
    final isPast = date.isBefore(DateTime(today.year, today.month, today.day));
    final accent = isToday ? _c.accent : _c.text;
    final stubBg = isToday
        ? _c.accent
        : (isPast
            ? _c.surface
            : _c.bg);
    final stubText = isToday
        ? _c.onAccent
        : (isPast ? _c.muted : _c.text);

    final sorted = [...bookings]
      ..sort((a, b) => _timeToMins(a.startTime).compareTo(_timeToMins(b.startTime)));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isToday ? _c.accent.withValues(alpha: 0.5) : _c.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Left stub: day number + weekday ─────────────
            Container(
              width: 64,
              decoration: BoxDecoration(
                color: stubBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(13),
                  bottomLeft: Radius.circular(13),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('d').format(date),
                    style: TextStyle(
                      color: stubText,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEE').format(date).toUpperCase(),
                    style: TextStyle(
                      color: stubText.withValues(alpha: 0.75),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 14,
                      height: 2,
                      decoration: BoxDecoration(
                        color: _c.onAccent.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // ── Perforation (dashed vertical line) ───────
            _Perforation(color: _c.border),
            // ── Right content: booking rows ──────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < sorted.length; i++) ...[
                      _TicketBookingRow(
                        booking: sorted[i],
                        arenas: arenas,
                        isNew: newIds.contains(sorted[i].id),
                        onTap: () => onBookingTap(sorted[i]),
                      ),
                      if (i < sorted.length - 1)
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          child: Container(
                              height: 1,
                              color: _c.border.withValues(alpha: 0.5)),
                        ),
                    ],
                    // + Add booking footer
                    Material(
                      color: Colors.transparent,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(13),
                        bottomRight: Radius.circular(13),
                      ),
                      child: InkWell(
                        onTap: onAdd,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(13),
                          bottomRight: Radius.circular(13),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Icon(Icons.add_rounded,
                                  size: 14, color: accent),
                              const SizedBox(width: 4),
                              Text(
                                sorted.isEmpty
                                    ? 'Add booking'
                                    : 'Add another',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: accent,
                                  letterSpacing: -0.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketBookingRow extends StatelessWidget {
  const _TicketBookingRow({
    required this.booking,
    required this.arenas,
    required this.onTap,
    this.isNew = false,
  });
  final ArenaReservation booking;
  final List<ArenaListing> arenas;
  final VoidCallback onTap;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final isCancelled = booking.status == 'CANCELLED';
    final isPaid = booking.balancePaise == 0;
    final amount = (booking.totalAmountPaise / 100).round();
    final unitName = booking.unitName ?? '—';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // status dot
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isCancelled
                      ? _c.muted
                      : (isPaid
                          ? _c.accent
                          : const Color(0xFFD97706)),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              // guest + time + court
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            booking.displayName.isEmpty
                                ? 'Guest'
                                : booking.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              color: isCancelled ? _c.muted : _c.text,
                              decoration: isCancelled
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        if (isNew) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: _c.accent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'NEW',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                                color: _c.onAccent,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${booking.startTime} · $unitName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.2,
                        color: _c.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '₹$amount',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: isCancelled ? _c.muted : _c.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Perforation extends StatelessWidget {
  const _Perforation({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: 1,
        child: CustomPaint(painter: _DashedLinePainter(color: color)),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const dashH = 3.0;
    const gapH = 3.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    var y = 0.0;
    while (y < size.height) {
      final endY = (y + dashH).clamp(0.0, size.height);
      canvas.drawLine(Offset(0.5, y), Offset(0.5, endY), paint);
      y += dashH + gapH;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}

// ─── Date group card ──────────────────────────────────────────────────────────

class _DateGroupCard extends StatelessWidget {
  const _DateGroupCard({
    required this.date,
    required this.today,
    required this.bookings,
    required this.onTap,
    required this.onAdd,
  });

  final DateTime date;
  final DateTime today;
  final List<ArenaReservation> bookings;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  static String _fmt(int paise) {
    final n = (paise / 100).round();
    final s = n.toString();
    if (s.length <= 3) return '₹$s';
    final last3 = s.substring(s.length - 3);
    String rest = s.substring(0, s.length - 3);
    final groups = <String>[];
    while (rest.length > 2) {
      groups.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) groups.insert(0, rest);
    return '₹${groups.join(',')},$last3';
  }

  static int _timeToMins(String t) {
    final p = t.split(':');
    if (p.length < 2) return 0;
    return (int.tryParse(p[0]) ?? 0) * 60 + (int.tryParse(p[1]) ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final isToday = DateUtils.isSameDay(date, today);
    final isPast = date.isBefore(DateTime(today.year, today.month, today.day));

    // ── Derived stats ──────────────────────────────────────────────────────
    final active = bookings.where((b) => b.status != 'CANCELLED').toList();
    final total = active.length;
    final confirmed = active.where((b) => b.status == 'CONFIRMED' || b.status == 'CHECKED_IN').length;
    final paidPaise = active.where((b) => b.isPaid).fold(0, (s, b) => s + b.totalAmountPaise);
    final duePaise = active.where((b) => !b.isPaid).fold(0, (s, b) => s + b.totalAmountPaise);
    final fillRatio = total > 0 ? (confirmed / total).clamp(0.0, 1.0) : 0.0;

    // Time-of-day heat (morning < 12, afternoon 12–17, evening ≥ 17)
    bool hasMorning = false, hasAfternoon = false, hasEvening = false;
    for (final b in active) {
      final m = _timeToMins(b.startTime);
      if (m < 720) hasMorning = true;
      else if (m < 1020) hasAfternoon = true;
      else hasEvening = true;
    }

    // Unit pills (distinct, max 2 visible)
    final unitNames = active.map((b) => b.unitName ?? '').where((n) => n.isNotEmpty).toSet().toList();

    // Density label
    final String densityLabel = total == 0
        ? 'Free'
        : total <= 2
            ? 'Light'
            : total <= 4
                ? 'Busy'
                : 'Full';
    final Color densityColor = isToday
        ? Colors.white.withValues(alpha: 0.85)
        : total == 0
            ? _c.muted
            : total <= 2
                ? Color(0xFF059669)
                : total <= 4
                    ? Color(0xFFF59E0B)
                    : Color(0xFFDC2626);

    // Next booking countdown (today only)
    String? nextLabel;
    if (isToday && active.isNotEmpty) {
      final nowMins = DateTime.now().hour * 60 + DateTime.now().minute;
      final upcoming = active
          .where((b) => b.status == 'CONFIRMED' && _timeToMins(b.startTime) > nowMins)
          .toList()
        ..sort((a, b) => _timeToMins(a.startTime).compareTo(_timeToMins(b.startTime)));
      if (upcoming.isNotEmpty) {
        final diff = _timeToMins(upcoming.first.startTime) - nowMins;
        nextLabel = diff < 60 ? 'Next in ${diff}m' : 'Next in ${diff ~/ 60}h ${diff % 60}m';
      }
    }

    // ── Colour tokens ──────────────────────────────────────────────────────
    final Color bg = isToday ? _c.accent : isPast ? Color(0xFFF5F6F8) : _c.surface;
    final Color primaryText = isToday ? Colors.white : isPast ? _c.muted : _c.text;
    final Color mutedText = isToday ? Colors.white.withValues(alpha: 0.65) : _c.muted;
    final Color barBg = isToday ? Colors.white.withValues(alpha: 0.25) : _c.border;
    final Color barFill = isToday ? Colors.white : _c.accent;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onAdd,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: isToday ? null : Border.all(color: _c.border, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Row 1: day · date number · month ────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(DateFormat('d').format(date),
                      style: TextStyle(
                          color: primaryText,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          height: 1,
                          letterSpacing: -0.6)),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(DateFormat('EEE').format(date).toUpperCase(),
                            style: TextStyle(
                                color: mutedText,
                                fontSize: 9,
                                height: 1,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4)),
                        const SizedBox(height: 1),
                        Text(DateFormat('MMM').format(date).toUpperCase(),
                            style: TextStyle(
                                color: mutedText,
                                fontSize: 9,
                                height: 1,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),

              // ── Row 2: fill bar ─────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SizedBox(
                  height: 3,
                  child: Stack(children: [
                    Container(color: barBg),
                    if (total > 0)
                      FractionallySizedBox(
                          widthFactor: fillRatio,
                          child: Container(color: barFill)),
                  ]),
                ),
              ),
              const SizedBox(height: 5),

              // ── Row 3: density · heat dots ──────────────────────────────
              Row(
                children: [
                  Text(densityLabel,
                      style: TextStyle(
                          color: densityColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w800)),
                  const Spacer(),
                  _HeatDot(active: hasMorning, isToday: isToday),
                  const SizedBox(width: 2),
                  _HeatDot(active: hasAfternoon, isToday: isToday),
                  const SizedBox(width: 2),
                  _HeatDot(active: hasEvening, isToday: isToday),
                ],
              ),
              const SizedBox(height: 4),

              // ── Row 4: revenue / due / next / hold-to-add ───────────────
              if (paidPaise > 0 || duePaise > 0)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        _fmt(paidPaise > 0 ? paidPaise : duePaise),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: primaryText,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            height: 1),
                      ),
                    ),
                    if (duePaise > 0 && paidPaise > 0) ...[
                      const SizedBox(width: 4),
                      Text('+${_fmt(duePaise)}',
                          style: TextStyle(
                              color: const Color(0xFFF59E0B),
                              fontSize: 9,
                              fontWeight: FontWeight.w800)),
                    ] else if (paidPaise == 0 && duePaise > 0) ...[
                      const SizedBox(width: 4),
                      Text('due',
                          style: TextStyle(
                              color: mutedText,
                              fontSize: 9,
                              fontWeight: FontWeight.w700)),
                    ],
                  ],
                )
              else if (nextLabel != null)
                Row(
                  children: [
                    Icon(Icons.schedule_rounded,
                        size: 9, color: Colors.white),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(nextLabel,
                          style: TextStyle(
                              color: _c.surface,
                              fontSize: 9,
                              fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                )
              else if (total == 0)
                Text('Hold to add',
                    style: TextStyle(
                        color: mutedText,
                        fontSize: 9,
                        fontWeight: FontWeight.w600))
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeatDot extends StatelessWidget {
  const _HeatDot({required this.active, required this.isToday});
  final bool active;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final color = active
        ? (isToday ? Colors.white : _c.accent)
        : (isToday ? Colors.white.withValues(alpha: 0.25) : _c.border);
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}


// ─── Date bookings bottom sheet ───────────────────────────────────────────────

class _DateBookingsSheet extends StatelessWidget {
  const _DateBookingsSheet({
    required this.date,
    required this.bookings,
    required this.arenas,
    required this.onBookingTap,
  });

  final DateTime date;
  final List<ArenaReservation> bookings;
  final List<ArenaListing> arenas;
  final ValueChanged<ArenaReservation> onBookingTap;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    final isTomorrow =
        DateUtils.isSameDay(date, DateTime.now().add(Duration(days: 1)));
    final dateLabel = isToday
        ? 'Today'
        : isTomorrow
            ? 'Tomorrow'
            : DateFormat('EEEE, d MMMM yyyy').format(date);
    final revenue = bookings.fold(0, (s, b) => s + b.totalAmountPaise);
    final collected = bookings.fold(
        0, (s, b) => s + (b.isPaid ? b.totalAmountPaise : b.advancePaise));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (ctx, ctrl) => Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
                color: _c.border, borderRadius: BorderRadius.circular(2)),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateLabel,
                        style: TextStyle(
                            color: _c.text,
                            fontSize: 18,
                            fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 4),
                      Row(children: [
                        Text(
                          '${bookings.length} booking${bookings.length == 1 ? '' : 's'}',
                          style: TextStyle(
                              color: _c.muted,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                        if (revenue > 0) ...[
                          Text(' · ',
                              style: TextStyle(color: _c.muted, fontSize: 13)),
                          Text(
                            '₹${revenue ~/ 100} total',
                            style: TextStyle(
                                color: _c.muted,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                          if (collected < revenue) ...[
                            Text(' · ',
                                style: TextStyle(color: _c.muted, fontSize: 13)),
                            Text(
                              '₹${collected ~/ 100} collected',
                              style: TextStyle(
                                  color: _c.accent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ],
                      ]),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: Icon(Icons.close_rounded, color: _c.muted),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Divider(height: 1, color: _c.border),
          // Booking list
          Expanded(
            child: ListView.builder(
              controller: ctrl,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: bookings.length,
              itemBuilder: (_, i) {
                final b = bookings[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: BookingCard(
                    booking: b,
                    arenas: arenas,
                    onTap: () {
                      Navigator.pop(ctx);
                      onBookingTap(b);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return Center(
        child: Text(message, style: TextStyle(color: Colors.red)));
  }
}

// ─── Add Booking Sheet ────────────────────────────────────────────────────────

// Thin adapter so existing call sites don't need changing.
class _SlotOption {
  const _SlotOption(
      {required this.durationMins, required this.label, required this.paise});
  final int durationMins;
  final String label;
  final int paise;
}

List<_SlotOption> _buildSlotOptions(ArenaUnitOption unit,
    {int? pricePerHourOverride, DateTime? date}) {
  final opts = BookingPricingEngine.durationOptions(
    unit,
    variantPricePaise: pricePerHourOverride,
    date: date,
  ).map((o) => _SlotOption(durationMins: o.durationMins, label: o.label, paise: o.pricePaise)).toList();
  return opts;
}

String _fmtDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

String _addMinutes(String time, int mins) {
  final parts = time.split(':').map(int.parse).toList();
  final total = parts[0] * 60 + parts[1] + mins;
  final h = (total ~/ 60).clamp(0, 23);
  final m = total % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}

class AddBookingSheet extends ConsumerStatefulWidget {
  AddBookingSheet(
      {super.key, required this.arena, required this.date, this.lockedUnitId});
  final ArenaListing arena;
  final DateTime date;
  final String? lockedUnitId;
  @override
  ConsumerState<AddBookingSheet> createState() => _AddBookingSheetState();
}

class _AddBookingSheetState extends ConsumerState<AddBookingSheet> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();
  final _advanceCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _dateStripCtrl = ScrollController();

  // Wizard step state
  int _step = 0;
  bool _stepForward = true;
  int _durationMins = 0;

  late DateTime _selectedDate;
  late DateTime _endDate;
  bool _isMultiDay = false;
  bool _endDatePicked = false;
  bool _isCustomDates = false;
  final Set<DateTime> _customDates = {};
  final Map<String, bool> _dateBusyMap = {};
  bool _loadingBusyMap = false;
  String? _unitId;
  String? _netVariantType;

  // Monthly pass state
  bool _isMonthlyPass = false;
  List<int> _mpDays = [1, 2, 3, 4, 5, 6, 7];
  DateTime? _mpStartDate;
  DateTime? _mpEndDate;
  String _mpStartTime = '06:00';
  String _mpEndTime = '07:00';
  int _variantInstanceIdx =
      0; // which instance (0-based) within the selected variant
  final List<String> _selectedSlots = [];
  int _selectedDurationIdx = -1;
  String _paymentMode = 'CASH';
  bool _loading = false;
  bool _totalEdited = false;
  List<String> _allDaySlots = [];
  List<ArenaReservation> _existingBookings = [];
  List<ArenaTimeBlock> _activeTimeBlocks = [];

  /// Authoritative bookable start times from `booking-context`. When this is
  /// non-null, the slot picker uses it directly (matching what the booking
  /// POST will accept). When null we fall back to client-side overlap math
  /// against [_existingBookings] + [_activeTimeBlocks].
  Set<String>? _availableStartTimes;
  int? _availableForDurationMins;
  bool _loadingAvail = true;
  List<ArenaAddon> _addons = [];
  final Set<ArenaAddon> _selectedAddons = {};
  bool _searchingUser = false;
  ArenaGuest? _foundGuest;
  ArenaCustomerLookup? _customerLookup;
  bool _guestResultExpanded = true;
  bool _lookupDone = false;

  ArenaUnitOption? get _unit =>
      widget.arena.units.where((u) => u.id == _unitId).firstOrNull;

  bool get _isNetsFlow {
    final u = _unit;
    return u?.unitType == 'CRICKET_NET' || u?.unitType == 'INDOOR_NET';
  }

  NetVariant? get _selectedVariant => _netVariantType == null
      ? null
      : _unit?.netVariants.where((v) => v.type == _netVariantType).firstOrNull;

  int? get _mpVariantRate => _selectedVariant?.monthlyPassRatePaise;
  bool get _variantHasPass => (_mpVariantRate ?? 0) > 0;

  List<String> get _stepLabels {
    if (_isNetsFlow && _isMonthlyPass) return const ['Setup', 'Schedule', 'Confirm'];
    if (_isNetsFlow) return const ['Add-ons', 'Date & Time', 'Confirm'];
    return const ['Court', 'Slot', 'Confirm'];
  }

  int get _netsDurMin {
    final u = _unit;
    if (u == null) return 60;
    return u.minSlotMins > 0 ? u.minSlotMins : 60;
  }

  int get _netsDurMax {
    final u = _unit;
    if (u == null) return 480;
    if (u.maxSlotMins > u.minSlotMins) return u.maxSlotMins;
    // Default: full operating window
    final openStr = u.openTime ?? widget.arena.openTime ?? '06:00';
    final closeStr = u.closeTime ?? widget.arena.closeTime ?? '23:00';
    return _toMins(closeStr) - _toMins(openStr);
  }

  int get _netsDurStep {
    final u = _unit;
    if (u == null) return 30;
    return u.slotIncrementMins > 0 ? u.slotIncrementMins : 30;
  }

  int get _currentDurationMins {
    if (_isNetsFlow) return _durationMins > 0 ? _durationMins : _netsDurMin;
    final unit = _unit;
    if (unit == null) return 60;
    final opts = _buildSlotOptions(unit, date: _selectedDate);
    final idx = _selectedDurationIdx.clamp(0, opts.length - 1);
    return opts[idx].durationMins;
  }

  bool get _isFullDay => _currentDurationMins >= 720;

  String get _fullDayOpen {
    final unit = _unit;
    return unit?.openTime ?? widget.arena.openTime ?? '06:00';
  }

  String get _fullDayClose {
    final unit = _unit;
    return unit?.closeTime ?? widget.arena.closeTime ?? '23:00';
  }

  bool get _fullDayBusy =>
      _existingBookings.any((b) => b.status != 'CANCELLED');

  // For full day, the slot is always "selected" (the whole day)
  String get _startTime {
    if (_isMultiDay || _isFullDay) return _fullDayOpen;
    return _selectedSlots.isEmpty ? '' : _selectedSlots.first;
  }

  String get _endTime {
    if (_isMultiDay || _isFullDay) return _fullDayClose;
    if (_selectedSlots.isEmpty) return '';
    return _addMinutes(_selectedSlots.first, _currentDurationMins);
  }

  int get _addonPaise => _selectedAddons.fold(0, (s, a) => s + a.pricePaise);

  List<ArenaAddon> get _unitAddons {
    final unitId = _unitId;
    return _addons
        .where((a) => a.unitId == null || a.unitId == unitId)
        .toList();
  }

  bool get _isBulkApplied {
    final unit = _unit;
    if (!_isMultiDay || unit == null) return false;
    final days = _endDate.difference(_selectedDate).inDays + 1;
    return unit.minBulkDays != null &&
        unit.bulkDayRatePaise != null &&
        days >= unit.minBulkDays!;
  }

  int get _bulkDays => _endDate.difference(_selectedDate).inDays + 1;

  int get _variantPricePerHour {
    final unit = _unit;
    if (unit == null) return 0;
    return BookingPricingEngine.variantPricePerHour(unit, _netVariantType);
  }

  // Flat list of all variant instances expanded by count.
  // e.g. Turf(count=2) + Cement(count=1) → [Turf/0, Turf/1, Cement/0]
  List<({String type, String label, int instance, int count, int? pricePaise})>
      get _variantTabs {
    final unit = _unit;
    if (unit == null) return [];
    return BookingPricingEngine.variantTabs(unit)
        .map((t) => (
              type: t.type,
              label: t.label,
              instance: t.instanceIndex,
              count: t.count,
              pricePaise: t.pricePaise,
            ))
        .toList();
  }

  bool _isTabSlotBusy(String time, String variantType, int instanceIndex) {
    return BookingPricingEngine.isSlotBusy(
      time,
      _currentDurationMins,
      bookings: _existingBookings,
      timeBlocks: _activeTimeBlocks,
      variantType: variantType,
      variantInstanceIndex: instanceIndex,
    );
  }

  int get _totalPaise {
    if (_totalEdited)
      return ((double.tryParse(_totalCtrl.text) ?? 0) * 100).round();
    final unit = _unit;
    if (unit == null) return 0;
    if (_isNetsFlow) {
      if (_selectedSlots.isEmpty) return 0;
      final pricePerHour = _variantPricePerHour > 0
          ? _variantPricePerHour
          : unit.pricePerHourPaise;
      final isWeekend = _selectedDate.weekday == 6 || _selectedDate.weekday == 7;
      final wMult = (isWeekend && unit.weekendMultiplier > 1.0) ? unit.weekendMultiplier : 1.0;
      return (((pricePerHour * _currentDurationMins) / 60) * wMult).round() + _addonPaise;
    }
    final opts =
        _buildSlotOptions(unit, pricePerHourOverride: _variantPricePerHour, date: _selectedDate);
    final idx = _selectedDurationIdx.clamp(0, opts.length - 1);
    if (_isMultiDay) {
      final days = _isCustomDates ? _customDates.length : _bulkDays;
      if (unit.bulkDayRatePaise != null && _variantPricePerHour == 0)
        return unit.bulkDayRatePaise! * days + _addonPaise;
      return opts[idx].paise * days + _addonPaise;
    }
    if (_isFullDay || _selectedSlots.isNotEmpty) {
      return opts[idx].paise + _addonPaise;
    }
    return 0;
  }

  int get _discountPaise => ((double.tryParse(_discountCtrl.text) ?? 0) * 100)
      .round()
      .clamp(0, _totalPaise);
  int get _finalPaise => (_totalPaise - _discountPaise).clamp(0, _totalPaise);
  int get _advancePaise => ((double.tryParse(_advanceCtrl.text) ?? 0) * 100)
      .round()
      .clamp(0, _finalPaise);
  int get _minAdvancePaise => _unit?.minAdvancePaise ?? 0;
  // Owner booking — no minimum advance enforcement
  bool get _advanceOk => true;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.date;
    _endDate = widget.date;
    _unitId = widget.lockedUnitId ?? widget.arena.units.firstOrNull?.id;
    _initDuration();
    _rebuildTimes();
    _loadAvailability();
    _loadAddons();

    _phoneCtrl.addListener(_onPhoneChanged);
  }

  void _onPhoneChanged() {
    final phone = _phoneCtrl.text.trim();
    final lookupPhone = _normalisedLookupPhone(phone);
    if (_foundGuest != null || _lookupDone) {
      setState(() {
        _foundGuest = null;
        _customerLookup = null;
        _guestResultExpanded = true;
        _lookupDone = false;
        _nameCtrl.clear();
      });
    }
    if (lookupPhone.length == 10 && !_searchingUser) {
      _lookupUser(lookupPhone);
    }
  }

  String _normalisedLookupPhone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 10 && digits.startsWith('91')) {
      return digits.substring(digits.length - 10);
    }
    return digits;
  }

  bool get _hasSelectedGuest =>
      _customerLookup?.exists == true || _foundGuest != null;

  bool get _showGuestNameInput =>
      _phoneCtrl.text.trim().isNotEmpty || _lookupDone || _hasSelectedGuest;

  void _selectFetchedGuest() {
    final name = _customerLookup?.name ?? _foundGuest?.name ?? '';
    if (name.isEmpty) return;
    setState(() {
      _nameCtrl.text = name;
      _lookupDone = true;
      _guestResultExpanded = false;
    });
  }

  Future<void> _lookupUser(String phone) async {
    setState(() => _searchingUser = true);
    try {
      final repo = ref.read(hostArenaBookingRepositoryProvider);
      final lookup =
          await repo.lookupArenaCustomer(widget.arena.id, phone: phone);
      if (!mounted) return;
      if (lookup.exists) {
        _nameCtrl.text = lookup.name ?? '';
        setState(() {
          _customerLookup = lookup;
          _foundGuest = null;
          _guestResultExpanded = true;
          _lookupDone = true;
        });
      } else if (lookup.guest != null) {
        _nameCtrl.text = lookup.guest!.name;
        setState(() {
          _customerLookup = lookup;
          _foundGuest = lookup.guest;
          _guestResultExpanded = true;
          _lookupDone = true;
        });
      } else {
        setState(() {
          _customerLookup = lookup;
          _foundGuest = null;
          _guestResultExpanded = true;
          _lookupDone = true;
        });
      }
    } catch (_) {
      if (mounted)
        setState(() {
          _foundGuest = null;
          _customerLookup = null;
          _guestResultExpanded = true;
          _lookupDone = true;
        });
    } finally {
      if (mounted) setState(() => _searchingUser = false);
    }
  }

  void _clearGuest() {
    setState(() {
      _foundGuest = null;
      _customerLookup = null;
      _guestResultExpanded = true;
      _lookupDone = false;
      _nameCtrl.clear();
      _phoneCtrl.clear();
    });
  }

  @override
  void dispose() {
    _phoneCtrl.removeListener(_onPhoneChanged);
    for (final ctrl in [
      _nameCtrl,
      _phoneCtrl,
      _notesCtrl,
      _totalCtrl,
      _advanceCtrl,
      _discountCtrl,
    ]) {
      ctrl.dispose();
    }
    _scrollCtrl.dispose();
    _dateStripCtrl.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) _scrollCtrl.jumpTo(0);
    });
  }

  bool get _canAdvance {
    if (_isNetsFlow && _isMonthlyPass) {
      switch (_step) {
        case 0:
          return _netVariantType != null;
        case 1:
          return _mpDays.isNotEmpty && _mpStartDate != null && _mpEndDate != null;
        default:
          return true;
      }
    }
    if (_isNetsFlow) {
      switch (_step) {
        case 0:
          if (_unit?.hasVariants == true && _netVariantType == null)
            return false;
          return true;
        case 1:
          return _selectedSlots.isNotEmpty;
        default:
          return true;
      }
    }
    switch (_step) {
      case 0:
        if (_unitId == null) return false;
        if (_unit?.hasVariants == true && _netVariantType == null) return false;
        return _isMultiDay || _selectedDurationIdx >= 0;
      case 1:
        if (_isMultiDay)
          return _isCustomDates ? _customDates.isNotEmpty : _endDatePicked;
        if (_isFullDay) return !_loadingAvail && !_fullDayBusy;
        return _selectedSlots.isNotEmpty;
      default:
        return true;
    }
  }

  void _nextStep() {
    if (!_canAdvance) return;
    setState(() {
      _stepForward = true;
      _step++;
    });
    _scrollToTop();
  }

  void _prevStep() {
    if (_step == 0) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _stepForward = false;
      _step--;
    });
    _scrollToTop();
  }

  Widget _stepTransition(Widget child, Animation<double> animation) {
    final isEntering = (child.key as ValueKey?)?.value == _step;
    final enterOffset =
        _stepForward ? Offset(1.0, 0) : Offset(-1.0, 0);
    final exitOffset =
        _stepForward ? Offset(-1.0, 0) : Offset(1.0, 0);
    final slide = Tween<Offset>(
      begin: isEntering ? enterOffset : exitOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
    return SlideTransition(
      position: slide,
      child: FadeTransition(opacity: animation, child: child),
    );
  }

  Future<void> _loadAddons() async {
    try {
      final addons = await ref
          .read(hostArenaBookingRepositoryProvider)
          .fetchArenaAddons(widget.arena.id);
      if (mounted) setState(() => _addons = addons);
    } catch (_) {}
  }

  void _initDuration() {
    final unit = _unit;
    if (unit == null) {
      _selectedDurationIdx = -1;
      _durationMins = 0;
      return;
    }
    if (_isNetsFlow) {
      if (_durationMins == 0) _durationMins = _netsDurMin;
      // Auto-select first variant tab if none selected
      if (_netVariantType == null &&
          unit.hasVariants &&
          unit.netVariants.isNotEmpty) {
        _netVariantType = unit.netVariants.first.type;
        _variantInstanceIdx = 0;
      }
    } else {
      _selectedDurationIdx = -1;
    }
  }

  void _rebuildTimes() {
    final unit = _unit;
    final arena = widget.arena;
    if (unit == null) {
      _allDaySlots = [];
      return;
    }

    final openStr = unit.openTime ?? arena.openTime ?? '06:00';
    final closeStr = unit.closeTime ?? arena.closeTime ?? '23:00';
    final openMins = _toMins(openStr);
    final closeMins = _toMins(closeStr);
    final durMins = _currentDurationMins;
    // Grounds are single-capacity: step by durMins so slots are non-overlapping
    final increment = unit.isGround
        ? durMins
        : (unit.slotIncrementMins > 0 ? unit.slotIncrementMins : 60);

    List<String> _slotsForDate(DateTime date) {
      final isToday = DateUtils.isSameDay(date, DateTime.now());
      final bufferMins = arena.bufferMins;
      final nowMins = DateTime.now().hour * 60 + DateTime.now().minute;
      final slots = <String>[];
      for (var m = openMins; m + durMins <= closeMins; m += increment) {
        if (isToday && m < nowMins + bufferMins) continue;
        slots.add(_fromMins(m));
      }
      return slots;
    }

    var slots = _slotsForDate(_selectedDate);

    // If today yields no slots (full-ground late in the day), advance to tomorrow
    if (slots.isEmpty && DateUtils.isSameDay(_selectedDate, DateTime.now())) {
      final tomorrow = DateTime.now().add(Duration(days: 1));
      final tomorrowSlots = _slotsForDate(tomorrow);
      if (tomorrowSlots.isNotEmpty) {
        _selectedDate = tomorrow;
        slots = tomorrowSlots;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _loadAvailability();
        });
      }
    }

    _allDaySlots = slots;
    _selectedSlots.clear();
    _selectedAddons.clear();
    _totalEdited = false;
    _totalCtrl.clear();
    _advanceCtrl.clear();
  }

  String _fromMins(int mins) {
    final h = mins ~/ 60;
    final m = mins % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  Future<void> _loadAvailability() async {
    if (_unitId == null) {
      setState(() => _loadingAvail = false);
      return;
    }
    final durForLoad = _currentDurationMins;
    setState(() => _loadingAvail = true);
    try {
      final repo = ref.read(hostArenaBookingRepositoryProvider);
      final avail = await BookingAvailabilityLoader.load(
        repo: repo,
        arenaId: widget.arena.id,
        unitId: _unitId!,
        date: _selectedDate,
        allUnits: widget.arena.units,
        durationMins: durForLoad,
      );
      if (mounted)
        setState(() {
          _existingBookings = avail.bookings;
          _activeTimeBlocks = avail.timeBlocks;
          _availableStartTimes = avail.availableStartTimes;
          _availableForDurationMins = avail.durationMins;
          // When the server gave us an authoritative list, use it as the
          // visible slot grid. The local _rebuildTimes generator uses a
          // fixed increment that misses turnaround-shifted starts (e.g.
          // 06:00 + 4h + 1h turnaround → 11:00, not 10:00).
          if (avail.availableStartTimes != null &&
              avail.durationMins == durForLoad) {
            final list = avail.availableStartTimes!.toList()
              ..sort((a, b) => _toMins(a).compareTo(_toMins(b)));
            // If the previously-selected slot is no longer available
            // (e.g. duration change), drop the selection.
            _selectedSlots
                .removeWhere((s) => !avail.availableStartTimes!.contains(s));
            _allDaySlots = list;
          }
        });
    } catch (_) {
      if (mounted)
        setState(() {
          _existingBookings = [];
          _activeTimeBlocks = [];
          _availableStartTimes = null;
          _availableForDurationMins = null;
        });
    } finally {
      if (mounted) setState(() => _loadingAvail = false);
    }
  }

  Future<void> _loadBusyDates() async {
    if (_unitId == null || _loadingBusyMap) return;
    setState(() => _loadingBusyMap = true);
    try {
      final repo = ref.read(hostArenaBookingRepositoryProvider);
      final results = await Future.wait([
        repo.listArenaBookings(widget.arena.id, unitId: _unitId),
        repo.listUnitTimeBlocks(widget.arena.id, unitId: _unitId!),
      ]);
      final bookings = results[0] as List<ArenaReservation>;
      final blocks = results[1] as List<ArenaTimeBlock>;
      final busy = <String, bool>{};
      for (final b in bookings) {
        if (b.status == 'CANCELLED') continue;
        if (b.bookingDate != null) busy[_fmtDate(b.bookingDate!)] = true;
      }
      for (final bl in blocks) {
        if (bl.date != null && bl.date!.length >= 10) {
          busy[bl.date!.substring(0, 10)] = true;
        } else if (bl.isRecurring && bl.weekdays.isNotEmpty) {
          // Mark recurring block weekdays for the next 42 days
          final today = DateTime.now();
          for (var i = 0; i < 42; i++) {
            final d = today.add(Duration(days: i));
            if (bl.weekdays.contains(d.weekday)) {
              busy[_fmtDate(d)] = true;
            }
          }
        } else if (bl.isHoliday) {
          if (bl.date != null) busy[bl.date!.substring(0, 10)] = true;
        }
      }
      if (mounted)
        setState(() => _dateBusyMap
          ..clear()
          ..addAll(busy));
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingBusyMap = false);
    }
  }

  // A slot is busy when the backend's booking-context didn't list it as
  // bookable for the currently-selected duration. This matches the rules
  // POST /bookings/arena/:id/manual enforces — held slots, monthly passes,
  // turnaround buffers, and parent/child unit conflicts are all baked in.
  //
  // Falls back to client-side overlap math when the server-side check is
  // unavailable (offline / load error / unknown unit grouping).
  bool _isBusy(String time) {
    final durMins = _currentDurationMins;
    final serverSet = _availableStartTimes;
    if (serverSet != null && _availableForDurationMins == durMins) {
      return !serverSet.contains(time);
    }

    // Legacy overlap fallback.
    final tMins = _toMins(time);
    final hasBooking = _existingBookings.any((b) {
      if (b.status == 'CANCELLED') return false;
      return _toMins(b.startTime) < tMins + durMins &&
          _toMins(b.endTime) > tMins;
    });
    final hasBlock = _activeTimeBlocks.any((b) {
      return _toMins(b.startTime) < tMins + durMins &&
          _toMins(b.endTime) > tMins;
    });
    return hasBooking || hasBlock;
  }

  void _onSlotTapped(String time) {
    if (_isBusy(time)) return;
    final wasEmpty = _selectedSlots.isEmpty;
    setState(() {
      if (_selectedSlots.length == 1 && _selectedSlots.first == time) {
        _selectedSlots.clear();
        _totalCtrl.clear();
      } else {
        _selectedSlots
          ..clear()
          ..add(time);
        if (!_totalEdited)
          _totalCtrl.text = (_totalPaise / 100).toStringAsFixed(0);
      }
    });
    if (wasEmpty && _selectedSlots.isNotEmpty) _scrollToTop();
  }

  Future<void> _save() async {
    if (_phoneCtrl.text.trim().isEmpty) {
      _snack('Enter guest mobile number', err: true);
      return;
    }
    final guestName =
        _customerLookup?.name ?? _foundGuest?.name ?? _nameCtrl.text.trim();
    if (guestName.isEmpty) {
      _snack('Enter guest name', err: true);
      return;
    }

    // ── Monthly pass flow ──
    if (_isMonthlyPass) {
      if (_mpStartDate == null || _mpEndDate == null || _mpDays.isEmpty) {
        _snack('Complete the schedule before saving', err: true);
        return;
      }
      setState(() => _loading = true);
      try {
        final repo = ref.read(hostArenaBookingRepositoryProvider);
        await repo.createMonthlyPass(widget.arena.id, {
          'unitId': _unitId,
          'guestName': guestName,
          'guestPhone': _phoneCtrl.text.trim(),
          'startTime': _mpStartTime,
          'endTime': _mpEndTime,
          'daysOfWeek': _mpDays,
          'startDate': DateFormat('yyyy-MM-dd').format(_mpStartDate!),
          'endDate': DateFormat('yyyy-MM-dd').format(_mpEndDate!),
          'totalAmountPaise': _totalPaise,
          'advancePaise': _advancePaise,
          'paymentMode': _paymentMode,
          if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
        });
        if (mounted) {
          Navigator.pop(context);
          _snack('Monthly pass created');
        }
      } catch (e) {
        if (mounted) _snack('Failed: $e', err: true);
      } finally {
        if (mounted) setState(() => _loading = false);
      }
      return;
    }

    if (!_isMultiDay && !_isFullDay && _selectedSlots.isEmpty) {
      _snack('Please select a start time', err: true);
      return;
    }
    if (_isFullDay && (_loadingAvail || _fullDayBusy)) {
      _snack('This day is already booked', err: true);
      return;
    }
    if (!_advanceOk) {
      _snack(
          'Min advance ₹${(_minAdvancePaise / 100).toStringAsFixed(0)} required',
          err: true);
      return;
    }
    if (_loading) {
      return;
    }
    setState(() => _loading = true);
    try {
      final repo = ref.read(hostArenaBookingRepositoryProvider);
      final guestName =
          _customerLookup?.name ?? _foundGuest?.name ?? _nameCtrl.text.trim();
      final guestPhone = _phoneCtrl.text.trim();
      final notes =
          _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim();

      if (_isMultiDay && _isCustomDates) {
        final sortedDates = _customDates.toList()..sort();
        final perDayPaise = _customDates.isNotEmpty
            ? (_totalPaise / _customDates.length).round()
            : _totalPaise;
        final perDayDiscount = _customDates.isNotEmpty
            ? (_discountPaise / _customDates.length).round()
            : _discountPaise;
        final perDayAdvance = _customDates.isNotEmpty
            ? (_advancePaise / _customDates.length).round()
            : _advancePaise;
        final skipped = <String>[];
        for (final d in sortedDates) {
          try {
            await repo.createManualBooking(
              widget.arena.id,
              unitId: _unitId!,
              date: _fmtDate(d),
              startTime: _startTime,
              endTime: _endTime,
              guestName: guestName,
              guestPhone: guestPhone,
              paymentMode: _paymentMode,
              amountPaise: perDayPaise,
              discountPaise: perDayDiscount,
              advancePaise: perDayAdvance,
              notes: notes,
              bookingSource: 'BIZ',
              netVariantType: _netVariantType,
              guestUserId: _customerLookup?.userId,
              guestPlayerProfileId: _customerLookup?.playerProfileId,
              createGuestUser: _customerLookup?.exists != true,
            );
          } catch (e) {
            skipped.add(DateFormat('d MMM').format(d));
          }
        }
        if (mounted) {
          Navigator.pop(context);
          if (skipped.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'Skipped ${skipped.length} conflicting date(s): ${skipped.join(', ')}'),
              backgroundColor: Color(0xFFD97706),
            ));
          }
        }
        return;
      } else {
        await repo.createManualBooking(
          widget.arena.id,
          unitId: _unitId!,
          date: _fmtDate(_selectedDate),
          startTime: _startTime,
          endTime: _endTime,
          guestName: guestName,
          guestPhone: guestPhone,
          paymentMode: _paymentMode,
          amountPaise: _totalPaise,
          discountPaise: _discountPaise,
          advancePaise: _advancePaise,
          notes: notes,
          endDate: _isMultiDay ? _fmtDate(_endDate) : null,
          isBulkBooking: _isBulkApplied,
          bulkDayRatePaise: _isBulkApplied ? _unit?.bulkDayRatePaise : null,
          bookingSource: 'BIZ',
          netVariantType: _netVariantType,
          guestUserId: _customerLookup?.userId,
          guestPlayerProfileId: _customerLookup?.playerProfileId,
          createGuestUser: _customerLookup?.exists != true,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      final msg = _humanizeBookingError(e);
      if (mounted) _snack(msg, err: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _humanizeBookingError(Object e) {
    if (e is DioException) {
      final code = e.response?.statusCode;
      final data = e.response?.data;
      // Try to surface the backend's `{ error: { code, message } }` payload.
      String? serverMsg;
      if (data is Map) {
        final nested = data['error'];
        if (nested is Map && nested['message'] is String) {
          serverMsg = nested['message'] as String;
        } else if (data['message'] is String) {
          serverMsg = data['message'] as String;
        }
      }
      if (code == 409) {
        return serverMsg ??
            'This slot conflicts with an existing booking or block.';
      }
      if (serverMsg != null) return serverMsg;
      if (code != null) return 'Request failed ($code). Try again.';
    }
    return '$e';
  }

  void _snack(String m, {bool err = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(m), backgroundColor: err ? Colors.red : _c.bg));

  Future<void> _selectStartDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: today,
      lastDate: today.add(Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
                primary: _c.accent, onPrimary: Colors.white, onSurface: _c.text)),
        child: child!,
      ),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        if (_endDate.isBefore(_selectedDate)) _endDate = _selectedDate;
        _rebuildTimes();
        if (!_totalEdited) _syncPrice();
      });
      _loadAvailability();
      // Scroll the date strip to the picked date
      final today = DateTime.now();
      final dayOffset = picked
          .difference(DateTime(today.year, today.month, today.day))
          .inDays;
      if (dayOffset >= 0 && _dateStripCtrl.hasClients) {
        _dateStripCtrl.animateTo(
          (dayOffset * 60.0).clamp(0, _dateStripCtrl.position.maxScrollExtent),
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate.isBefore(_selectedDate) ? _selectedDate : _endDate,
      firstDate: _selectedDate,
      lastDate: _selectedDate.add(Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
                primary: _c.accent, onPrimary: Colors.white, onSurface: _c.text)),
        child: child!,
      ),
    );
    if (picked != null) {
      final wasShowing = _endDatePicked;
      setState(() {
        _endDate = picked;
        _endDatePicked = true;
        if (!_totalEdited) _syncPrice();
      });
      if (!wasShowing) _scrollToTop();
    }
  }

  void _syncPrice() {
    if (_totalEdited) return;
    if (_isMonthlyPass && _mpVariantRate != null) {
      _totalCtrl.text = (_mpVariantRate! ~/ 100).toString();
      return;
    }
    final unit = _unit;
    if (unit == null) return;
    if (_isMultiDay) {
      final days = _isCustomDates ? _customDates.length : _bulkDays;
      if (unit.bulkDayRatePaise != null && _variantPricePerHour == 0) {
        _totalCtrl.text =
            (unit.bulkDayRatePaise! * days / 100).toStringAsFixed(0);
      } else {
        final opts =
            _buildSlotOptions(unit, pricePerHourOverride: _variantPricePerHour, date: _selectedDate);
        final opt = opts[_selectedDurationIdx.clamp(0, opts.length - 1)];
        _totalCtrl.text = (opt.paise * days / 100).toStringAsFixed(0);
      }
    } else if (_isFullDay) {
      final opts =
          _buildSlotOptions(unit, pricePerHourOverride: _variantPricePerHour, date: _selectedDate);
      final opt = opts[_selectedDurationIdx.clamp(0, opts.length - 1)];
      _totalCtrl.text = (opt.paise / 100).toStringAsFixed(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final isLastStep = _step == _stepLabels.length - 1;

    return Scaffold(
      backgroundColor: _c.bg,
      body: Column(children: [
        // ── Ticket header ──────────────────────────────────
        _TicketHeader(
          arenaName: widget.arena.name,
          step: _step,
          stepLabels: _stepLabels,
          selectedDate: _selectedDate,
          onBack: _prevStep,
          isFirstStep: _step == 0,
        ),
        // ── Perforated stub line ───────────────────────────
        _PerforatedDivider(),
        // ── Scrollable content ─────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollCtrl,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
            child: _buildStepContent(),
          ),
        ),
      ]),
      bottomNavigationBar: Container(
        color: _c.bg,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: isLastStep
                ? _BookingActionButton(
                    label: _loading ? 'Saving…' : _confirmLabel,
                    enabled: !_loading &&
                        !(!_isMultiDay &&
                            _isFullDay &&
                            (_loadingAvail || _fullDayBusy)),
                    onTap: _save,
                  )
                : _BookingActionButton(
                    label: 'Continue',
                    enabled: _canAdvance,
                    onTap: _nextStep,
                    trailing: Icons.arrow_forward_rounded,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    if (_isNetsFlow && _isMonthlyPass) {
      switch (_step) {
        case 0: return _buildNetsSetupStep();
        case 1: return _buildMonthlyPassScheduleStep();
        case 2: return _buildConfirmStep();
        default: return const SizedBox.shrink();
      }
    }
    if (_isNetsFlow) {
      switch (_step) {
        case 0: return _buildNetsSetupStep();
        case 1: return _buildNetsDateTimeStep();
        case 2: return _buildConfirmStep();
        default: return const SizedBox.shrink();
      }
    }
    switch (_step) {
      case 0: return _buildCourtStep();
      case 1: return _buildSlotStep();
      case 2: return _buildConfirmStep();
      default: return const SizedBox.shrink();
    }
  }

  String _formatTimeRange(String start, String end) {
    String fmt(String t) {
      final parts = t.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final suffix = h >= 12 ? 'PM' : 'AM';
      final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
      return m == 0
          ? '$h12 $suffix'
          : '$h12:${m.toString().padLeft(2, '0')} $suffix';
    }

    return '${fmt(start)} – ${fmt(end)}';
  }

  // ── Nets Step 0: Add-ons (surface/variant selection moved to tabs in step 1)
  Widget _buildNetsSetupStep() {
    final unit = _unit;
    final units = widget.arena.units;
    final hasGrounds = units
        .any((u) => u.unitType == 'FULL_GROUND' || u.unitType == 'HALF_GROUND');
    final hasNets = units
        .any((u) => u.unitType == 'CRICKET_NET' || u.unitType == 'INDOOR_NET');
    final addons = unit != null ? _unitAddons : <ArenaAddon>[];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Court type tiles (only when arena has both)
      if (hasGrounds && hasNets) ...[
        Row(children: [
          Expanded(
              child: _BizTypeTile(
            icon: Icons.grass_rounded,
            label: 'Full Ground',
            sublabel: _groundPriceLabel(units),
            selected: false,
            onTap: () {
              final g = units.firstWhere((u) =>
                  u.unitType == 'FULL_GROUND' || u.unitType == 'HALF_GROUND');
              setState(() {
                _unitId = g.id;
                _netVariantType = null;
                _variantInstanceIdx = 0;
                _selectedAddons.clear();
                _selectedSlots.clear();
                _durationMins = 0;
                _initDuration();
                _rebuildTimes();
              });
              _loadAvailability();
            },
          )),
          SizedBox(width: 12),
          Expanded(
              child: _BizTypeTile(
            icon: Icons.sports_cricket_rounded,
            label: 'Nets',
            sublabel: _netPriceLabel(units),
            selected: true,
            onTap: () {},
          )),
        ]),
        SizedBox(height: 24),
      ],

      // Net types
      if (unit != null && unit.hasVariants) ...[
        Text('NET TYPE',
            style: TextStyle(
                color: _c.muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
        SizedBox(height: 10),
        ...unit.netVariants.map((v) {
          final isSel = _netVariantType == v.type;
          return GestureDetector(
            onTap: () => setState(() {
              _netVariantType = v.type;
              _variantInstanceIdx = 0;
              _selectedSlots.clear();
              _totalEdited = false;
              _totalCtrl.clear();
            }),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 160),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSel ? _c.accent : _c.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isSel ? _c.accent : _c.border, width: isSel ? 2 : 1),
              ),
              child: Row(children: [
                Expanded(
                    child: Row(children: [
                  Text(v.label,
                      style: TextStyle(
                          color: isSel ? Colors.white : _c.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                  if (v.count > 1) ...[
                    SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSel
                            ? Colors.white.withValues(alpha: .2)
                            : _c.border,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('${v.count} nets',
                          style: TextStyle(
                              color: isSel ? Colors.white : _c.muted,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                  if (v.hasFloodlights) ...[
                    SizedBox(width: 8),
                    Icon(Icons.wb_incandescent_rounded,
                        size: 13, color: isSel ? Colors.white70 : _c.muted),
                  ],
                ])),
                if (v.pricePaise != null)
                  Text('₹${(v.pricePaise! / 100).toStringAsFixed(0)}/hr',
                      style: TextStyle(
                          color: isSel ? Colors.white : _c.accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                SizedBox(width: 10),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isSel ? Colors.white : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isSel ? Colors.white : _c.border, width: 2),
                  ),
                  child: isSel
                      ? Icon(Icons.check_rounded, size: 12, color: _c.accent)
                      : null,
                ),
              ]),
            ),
          );
        }),
        SizedBox(height: 8),
      ],

      // Monthly pass toggle — shown when selected variant has a pass rate configured
      if (_variantHasPass) ...[
        SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _isMonthlyPass ? _c.accentLight : _c.bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _isMonthlyPass ? _c.accent : _c.border),
          ),
          child: Row(children: [
            Icon(Icons.card_membership_rounded, size: 18, color: _isMonthlyPass ? _c.accent : _c.muted),
            SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Monthly Pass', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _isMonthlyPass ? _c.accent : _c.text)),
              Text('₹${(_mpVariantRate! / 100).toStringAsFixed(0)}/month · recurring slot', style: TextStyle(fontSize: 12, color: _c.muted, fontWeight: FontWeight.w500)),
            ])),
            Switch.adaptive(
              value: _isMonthlyPass,
              activeColor: _c.accent,
              onChanged: (v) => setState(() {
                _isMonthlyPass = v;
                _selectedSlots.clear();
                _totalEdited = false;
                _totalCtrl.text = v && _mpVariantRate != null ? (_mpVariantRate! ~/ 100).toString() : '';
              }),
            ),
          ]),
        ),
        SizedBox(height: 8),
      ],

      if (addons.isNotEmpty) ...[
        SizedBox(height: 12),
        Text('ADD-ONS',
            style: TextStyle(
                color: _c.muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
        SizedBox(height: 10),
        ...addons.map((a) {
          final isSel = _selectedAddons.contains(a);
          return GestureDetector(
            onTap: () => setState(() {
              if (isSel)
                _selectedAddons.remove(a);
              else
                _selectedAddons.add(a);
            }),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSel ? _c.accent.withValues(alpha: .08) : _c.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSel ? _c.accent : _c.border),
              ),
              child: Row(children: [
                Icon(
                    isSel
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    color: isSel ? _c.accent : _c.muted,
                    size: 20),
                SizedBox(width: 10),
                Expanded(
                    child: Text(a.name,
                        style: TextStyle(
                            color: _c.text,
                            fontWeight: FontWeight.w700,
                            fontSize: 13))),
                Text('₹${(a.pricePaise / 100).toStringAsFixed(0)}/${a.unit}',
                    style: TextStyle(color: _c.muted, fontSize: 12)),
              ]),
            ),
          );
        }),
      ] else ...[
        SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
              color: _c.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _c.border)),
          child: Row(children: [
            Icon(Icons.arrow_forward_rounded, color: _c.muted, size: 16),
            SizedBox(width: 10),
            Text('Select date, duration and time on the next step',
                style: TextStyle(
                    color: _c.muted, fontSize: 13, fontWeight: FontWeight.w500)),
          ]),
        ),
      ],
      SizedBox(height: 24),
    ]);
  }

  // ── Nets Step 1: Surface chips + count tabs + date + duration + slots ──────
  Future<void> _pickMpTime(BuildContext context, {required bool isStart}) async {
    final current = isStart ? _mpStartTime : _mpEndTime;
    final parts = current.split(':');
    final h = int.tryParse(parts[0]) ?? (isStart ? 6 : 7);
    final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: h, minute: m),
      builder: (ctx, child) => MediaQuery(data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true), child: child!),
    );
    if (picked == null) return;
    final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    setState(() {
      if (isStart) _mpStartTime = formatted;
      else _mpEndTime = formatted;
    });
  }

  Widget _buildMonthlyPassScheduleStep() {
    const days = [(1, 'Mon'), (2, 'Tue'), (3, 'Wed'), (4, 'Thu'), (5, 'Fri'), (6, 'Sat'), (7, 'Sun')];
    final variant = _selectedVariant;

    String fmt(DateTime d) => DateFormat('d MMM yyyy').format(d);

    Widget timeChip(String label, String time, {required bool isStart}) {
      return GestureDetector(
        onTap: () => _pickMpTime(context, isStart: isStart),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: _c.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: _c.border)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.schedule_rounded, size: 16, color: _c.accent),
            SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(fontSize: 11, color: _c.muted, fontWeight: FontWeight.w600)),
              Text(time, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _c.text)),
            ]),
          ]),
        ),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Variant summary
      if (variant != null)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(color: _c.accentLight, borderRadius: BorderRadius.circular(10), border: Border.all(color: _c.accent.withValues(alpha: .3))),
          child: Row(children: [
            Icon(Icons.card_membership_rounded, size: 16, color: _c.accent),
            SizedBox(width: 8),
            Text('${variant.label} Monthly Pass', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _c.accent)),
            Spacer(),
            Text('₹${(_mpVariantRate! ~/ 100)}/mo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _c.accent)),
          ]),
        ),

      // Time slot
      Text('RECURRING TIME SLOT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _c.muted, letterSpacing: 0.5)),
      SizedBox(height: 10),
      Row(children: [
        timeChip('Start', _mpStartTime, isStart: true),
        Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('–', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _c.muted))),
        timeChip('End', _mpEndTime, isStart: false),
      ]),
      SizedBox(height: 20),

      // Days of week
      Text('RECURRING DAYS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _c.muted, letterSpacing: 0.5)),
      SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: days.map((d) {
        final sel = _mpDays.contains(d.$1);
        return GestureDetector(
          onTap: () => setState(() {
            if (sel) { if (_mpDays.length > 1) _mpDays = _mpDays.where((x) => x != d.$1).toList(); }
            else _mpDays = [..._mpDays, d.$1]..sort();
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: sel ? _c.accent : _c.bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: sel ? _c.accent : _c.border),
            ),
            child: Text(d.$2, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: sel ? Colors.white : _c.text)),
          ),
        );
      }).toList()),
      SizedBox(height: 20),

      // Date range
      Text('PASS DURATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _c.muted, letterSpacing: 0.5)),
      SizedBox(height: 10),
      Row(children: [
        Expanded(child: GestureDetector(
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: _mpStartDate ?? DateTime.now(),
              firstDate: DateTime.now().subtract(Duration(days: 1)),
              lastDate: DateTime.now().add(Duration(days: 365)),
            );
            if (d != null) setState(() { _mpStartDate = d; if (_mpEndDate != null && _mpEndDate!.isBefore(d)) _mpEndDate = null; });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: _c.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: _mpStartDate != null ? _c.accent : _c.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Start date', style: TextStyle(fontSize: 11, color: _c.muted, fontWeight: FontWeight.w600)),
              SizedBox(height: 2),
              Text(_mpStartDate != null ? fmt(_mpStartDate!) : 'Pick date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _mpStartDate != null ? _c.text : _c.muted)),
            ]),
          ),
        )),
        SizedBox(width: 10),
        Expanded(child: GestureDetector(
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: _mpEndDate ?? (_mpStartDate ?? DateTime.now()).add(Duration(days: 29)),
              firstDate: _mpStartDate ?? DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 730)),
            );
            if (d != null) setState(() => _mpEndDate = d);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: _c.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: _mpEndDate != null ? _c.accent : _c.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('End date', style: TextStyle(fontSize: 11, color: _c.muted, fontWeight: FontWeight.w600)),
              SizedBox(height: 2),
              Text(_mpEndDate != null ? fmt(_mpEndDate!) : 'Pick date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _mpEndDate != null ? _c.text : _c.muted)),
            ]),
          ),
        )),
      ]),
    ]);
  }

  Widget _buildNetsDateTimeStep() {
    final unit = _unit;
    if (unit == null) return const SizedBox.shrink();
    final today = DateTime.now();
    final stripDates = List.generate(
        60, (i) => DateTime(today.year, today.month, today.day + i));
    final dur = _currentDurationMins;
    final min = _netsDurMin;
    final max = _netsDurMax;
    final stepMins = _netsDurStep;
    // Price: use variant price if set, else unit base price
    final variantPrice = _variantPricePerHour;
    final pricePerHour =
        variantPrice > 0 ? variantPrice : unit.pricePerHourPaise;

    // Selected variant and its count tabs
    final selectedVariant = _netVariantType != null
        ? unit.netVariants.where((v) => v.type == _netVariantType).firstOrNull
        : null;
    final countTabs = (selectedVariant != null && selectedVariant.count > 1)
        ? List.generate(selectedVariant.count, (i) => i)
        : <int>[];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Count tabs (Turf 1, Turf 2 …) — shown when selected variant has count > 1
      if (countTabs.length > 1) ...[
        Text('NET',
            style: TextStyle(
                color: _c.muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
        SizedBox(height: 10),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: countTabs.length,
            separatorBuilder: (_, __) => SizedBox(width: 8),
            itemBuilder: (ctx, i) {
              final isSel = _variantInstanceIdx == i;
              final label = '${selectedVariant!.label} ${i + 1}';
              return GestureDetector(
                onTap: () => setState(() {
                  _variantInstanceIdx = i;
                  _selectedSlots.clear();
                  _totalEdited = false;
                  _totalCtrl.clear();
                }),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isSel ? _c.accent : _c.bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSel ? _c.accent : _c.border),
                  ),
                  child: Center(
                    child: Text(label,
                        style: TextStyle(
                          color: isSel ? Colors.white : _c.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        )),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 20),
      ],

      // Date strip
      Text('DATE',
          style: TextStyle(
              color: _c.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5)),
      SizedBox(height: 12),
      SizedBox(
        height: 80,
        child: ListView.separated(
          controller: _dateStripCtrl,
          scrollDirection: Axis.horizontal,
          itemCount: stripDates.length,
          separatorBuilder: (_, __) => SizedBox(width: 8),
          itemBuilder: (ctx, i) {
            final d = stripDates[i];
            final isSel = DateUtils.isSameDay(d, _selectedDate);
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = d;
                  _selectedSlots.clear();
                  _totalEdited = false;
                  _totalCtrl.clear();
                });
                _rebuildTimes();
                _loadAvailability();
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 180),
                width: 56,
                decoration: BoxDecoration(
                  color: isSel ? _c.accent : _c.bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isSel ? _c.accent : _c.border),
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(i == 0 ? 'Today' : DateFormat('EEE').format(d),
                          style: TextStyle(
                              color: isSel ? Colors.white : _c.muted,
                              fontSize: i == 0 ? 9 : 10,
                              fontWeight: FontWeight.w700)),
                      SizedBox(height: 2),
                      Text('${d.day}',
                          style: TextStyle(
                              color: isSel ? Colors.white : _c.text,
                              fontSize: 20,
                              fontWeight: FontWeight.w900)),
                      Text(DateFormat('MMM').format(d),
                          style: TextStyle(
                              color: isSel
                                  ? Colors.white.withValues(alpha: .8)
                                  : _c.muted,
                              fontSize: 9,
                              fontWeight: FontWeight.w600)),
                    ]),
              ),
            );
          },
        ),
      ),
      SizedBox(height: 20),

      // Duration stepper
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
            color: _c.bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _c.border)),
        child: Row(children: [
          Text('Duration',
              style: TextStyle(
                  color: _c.text, fontSize: 15, fontWeight: FontWeight.w700)),
          Spacer(),
          GestureDetector(
            onTap: dur > min
                ? () {
                    setState(() {
                      _durationMins = dur - stepMins;
                      _rebuildTimes();
                    });
                  }
                : null,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  color: dur > min ? _c.text : _c.border,
                  borderRadius: BorderRadius.circular(9)),
              child: Icon(Icons.remove_rounded,
                  color: _c.surface, size: 17),
            ),
          ),
          SizedBox(
            width: 72,
            child: Text(_durationLabel(dur),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _c.text, fontSize: 16, fontWeight: FontWeight.w900)),
          ),
          GestureDetector(
            onTap: dur < max
                ? () {
                    setState(() {
                      _durationMins = dur + stepMins;
                      _rebuildTimes();
                    });
                  }
                : null,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  color: dur < max ? _c.text : _c.border,
                  borderRadius: BorderRadius.circular(9)),
              child:
                  Icon(Icons.add_rounded, color: _c.surface, size: 17),
            ),
          ),
        ]),
      ),
      SizedBox(height: 20),

      // Time slot cards
      Text('START TIME',
          style: TextStyle(
              color: _c.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5)),
      SizedBox(height: 10),

      if (_loadingAvail)
        Center(
            child: Padding(
          padding: EdgeInsets.symmetric(vertical: 28),
          child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2, color: _c.accent)),
        ))
      else if (_allDaySlots.isEmpty)
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
              color: _c.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _c.border)),
          child: Row(children: [
            Icon(Icons.info_outline_rounded, color: _c.muted, size: 18),
            SizedBox(width: 10),
            Text('No slots available for this date.',
                style: TextStyle(
                    color: _c.muted, fontSize: 13, fontWeight: FontWeight.w600)),
          ]),
        )
      else
        ...(_allDaySlots.map((time) {
          final busy = (_netVariantType != null)
              ? _isTabSlotBusy(time, _netVariantType!, _variantInstanceIdx)
              : _isBusy(time);
          final isSel = _selectedSlots.contains(time);
          final endTime = _addMinutes(time, dur);
          // Compute price for this duration at per-hour rate (paise)
          final slotPaise = pricePerHour > 0
              ? ((pricePerHour * dur) / 60).round() + _addonPaise
              : 0;
          return GestureDetector(
            onTap: busy ? null : () => _onSlotTapped(time),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: busy ? Color(0xFFFEF2F2) : (isSel ? _c.accent : _c.bg),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: busy
                      ? Color(0xFFFCA5A5)
                      : (isSel ? _c.accent : _c.border),
                  width: isSel ? 2 : 1,
                ),
              ),
              child: Row(children: [
                Expanded(
                    child: Text(_formatTimeRange(time, endTime),
                        style: TextStyle(
                          color: busy
                              ? Color(0xFFEF4444)
                              : (isSel ? Colors.white : _c.text),
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ))),
                if (busy)
                  Text('Booked',
                      style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 11,
                          fontWeight: FontWeight.w600))
                else if (slotPaise > 0)
                  Text('₹${(slotPaise / 100).toStringAsFixed(0)}',
                      style: TextStyle(
                          color: isSel ? Colors.white : _c.accent,
                          fontWeight: FontWeight.w900,
                          fontSize: 14)),
              ]),
            ),
          );
        })),
      SizedBox(height: 24),
    ]);
  }

  // ── Step 0: Court + Duration ───────────────────────────────────────────────
  Widget _buildCourtStep() {
    final units = widget.arena.units;
    final unit = _unit;
    final bulkAvailable = unit != null &&
        (unit.minBulkDays ?? 0) > 0 &&
        unit.bulkDayRatePaise != null;
    final isWeekend =
        _selectedDate.weekday == 6 || _selectedDate.weekday == 7;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(
          child: Text(
            'Select Court',
            style: TextStyle(
                color: _c.text,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5),
          ),
        ),
        Text(
          DateFormat('EEE, MMM d').format(_selectedDate),
          style: TextStyle(
              color: _c.muted, fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ]),

      const SizedBox(height: 20),

      // No units configured
      if (units.isEmpty)
        Text(
          'No courts configured. Please add units in Arena Settings.',
          style: TextStyle(color: _c.muted, fontSize: 14),
        ),

      // Court cards
      if (units.isNotEmpty) ...[
        for (final u in units) ...[
          _CourtCard(
            unit: u,
            selected: u.id == _unitId,
            isWeekend: isWeekend,
            onTap: () {
              setState(() {
                _unitId = u.id;
                _netVariantType = null;
                _variantInstanceIdx = 0;
                _selectedAddons.clear();
                _selectedSlots.clear();
                _initDuration();
                _rebuildTimes();
              });
              _loadAvailability();
            },
          ),
          const SizedBox(height: 12),
        ],
      ],

      // Net variant picker
      if (unit != null && unit.hasVariants) ...[
        const SizedBox(height: 20),
        Text('SURFACE',
            style: TextStyle(
                color: _c.muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
        const SizedBox(height: 10),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: unit.netVariants.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final v = unit.netVariants[i];
              final isSel = _netVariantType == v.type;
              final rate = v.pricePaise != null
                  ? '₹${(v.pricePaise! / 100).toStringAsFixed(0)}/hr'
                  : '';
              return GestureDetector(
                onTap: () => setState(() {
                  _netVariantType = v.type;
                  _variantInstanceIdx = 0;
                  _selectedSlots.clear();
                  _totalEdited = false;
                  _totalCtrl.clear();
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSel ? _c.accent : _c.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: isSel ? _c.accent : _c.border),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(v.label,
                        style: TextStyle(
                            color: isSel ? _c.onAccent : _c.text,
                            fontSize: 11,
                            fontWeight: FontWeight.w800)),
                    if (rate.isNotEmpty) ...[
                      const SizedBox(width: 5),
                      Text(rate,
                          style: TextStyle(
                              color: isSel
                                  ? _c.onAccent.withValues(alpha: 0.7)
                                  : _c.muted,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ],
                  ]),
                ),
              );
            },
          ),
        ),
      ],

      // Duration cards
      AnimatedSize(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
        child: (unit == null || _isMultiDay)
            ? const SizedBox(width: double.infinity)
            : Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Builder(builder: (_) {
                  final opts = _buildSlotOptions(unit,
                      pricePerHourOverride: _variantPricePerHour,
                      date: _selectedDate);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DURATION',
                          style: TextStyle(
                              color: _c.muted,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 80,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: opts.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (_, i) {
                            final sel = i == _selectedDurationIdx;
                            final opt = opts[i];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDurationIdx = i;
                                  _isMultiDay = false;
                                  _endDatePicked = false;
                                  _selectedSlots.clear();
                                  _totalEdited = false;
                                  _totalCtrl.clear();
                                  _rebuildTimes();
                                  if (opt.durationMins >= 720 && !_totalEdited)
                                    _totalCtrl.text =
                                        (opt.paise / 100).toStringAsFixed(0);
                                });
                                _loadAvailability();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                width: 96,
                                decoration: BoxDecoration(
                                  color: sel ? _c.accent : _c.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: sel ? _c.accent : _c.border,
                                    width: sel ? 0 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      opt.label,
                                      style: TextStyle(
                                        color: sel ? _c.onAccent : _c.text,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₹${(opt.paise / 100).toStringAsFixed(0)}',
                                      style: TextStyle(
                                        color: sel
                                            ? _c.onAccent.withValues(alpha: 0.75)
                                            : _c.accent,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }),
              ),
      ),

      // Multi-day toggle
      if (unit != null && bulkAvailable) ...[
        const SizedBox(height: 20),
        _MultiDayToggle(
          isActive: _isMultiDay,
          pricePerDayRupees: unit.bulkDayRatePaise! ~/ 100,
          minDays: unit.minBulkDays ?? 0,
          onTap: () => setState(() {
            _isMultiDay = !_isMultiDay;
            _totalEdited = false;
            _totalCtrl.clear();
            _selectedSlots.clear();
            if (!_isMultiDay) {
              _endDatePicked = false;
              _isCustomDates = false;
              _customDates.clear();
            }
          }),
        ),
      ],

      // Add-ons
      if (unit != null && _unitAddons.isNotEmpty) ...[
        const SizedBox(height: 20),
        Text('ADD-ONS',
            style: TextStyle(
                color: _c.muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: _c.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: List.generate(_unitAddons.length, (i) {
              final a = _unitAddons[i];
              final isSel = _selectedAddons.contains(a);
              return Column(children: [
                if (i > 0)
                  Divider(height: 1, thickness: 0.5, color: _c.border),
                InkWell(
                  borderRadius: BorderRadius.vertical(
                    top: i == 0 ? const Radius.circular(14) : Radius.zero,
                    bottom: i == _unitAddons.length - 1
                        ? const Radius.circular(14)
                        : Radius.zero,
                  ),
                  onTap: () => setState(() {
                    if (isSel)
                      _selectedAddons.remove(a);
                    else
                      _selectedAddons.add(a);
                  }),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(children: [
                      Icon(
                          isSel
                              ? Icons.check_box_rounded
                              : Icons.check_box_outline_blank_rounded,
                          color: isSel ? _c.accent : _c.muted,
                          size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(a.name,
                              style: TextStyle(
                                  color: _c.text,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14))),
                      Text(
                          '₹${(a.pricePaise / 100).toStringAsFixed(0)}/${a.unit}',
                          style: TextStyle(color: _c.muted, fontSize: 12)),
                    ]),
                  ),
                ),
              ]);
            }),
          ),
        ),
      ],

      const SizedBox(height: 24),
    ]);
  }

  // ── Step 2: Date & Slot ────────────────────────────────────────────────────
  Widget _buildSlotStep() {
    if (_isMultiDay) {
      final today = DateTime.now();
      final gridDates = List.generate(
          42, (i) => DateTime(today.year, today.month, today.day + i));
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Pick dates',
            style: TextStyle(
                color: _c.text,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5)),
        SizedBox(height: 12),
        // Mode toggle
        Row(children: [
          _ModeChip(
              label: 'Date Range',
              selected: !_isCustomDates,
              onTap: () => setState(() {
                    _isCustomDates = false;
                    _customDates.clear();
                    _syncPrice();
                  })),
          SizedBox(width: 8),
          _ModeChip(
              label: 'Custom Dates',
              selected: _isCustomDates,
              onTap: () {
                setState(() {
                  _isCustomDates = true;
                  _endDatePicked = false;
                  _customDates.clear();
                  _syncPrice();
                });
                _loadBusyDates();
              }),
        ]),
        SizedBox(height: 20),
        if (!_isCustomDates) ...[
          Row(children: [
            Expanded(
                child: _BizDateTile(
                    label: 'START DATE',
                    date: _selectedDate,
                    onTap: _selectStartDate)),
            SizedBox(width: 12),
            Expanded(
                child: _BizDateTile(
                    label: 'END DATE',
                    date: _endDate,
                    onTap: _selectEndDate,
                    highlight: !_endDatePicked)),
          ]),
          if (_unit != null && _endDatePicked) ...[
            SizedBox(height: 12),
            _BizBulkRateInfo(unit: _unit!, days: _bulkDays),
          ],
        ] else ...[
          Row(children: [
            Expanded(
                child: Text(
                    'Tap dates to select · ${_customDates.length} selected',
                    style: TextStyle(
                        color: _c.muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600))),
            if (_loadingBusyMap)
              SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: _c.accent)),
          ]),
          SizedBox(height: 12),
          Wrap(
              spacing: 8,
              runSpacing: 8,
              children: gridDates.map((d) {
                final dateKey = _fmtDate(d);
                final isSel = _customDates.any((c) =>
                    c.year == d.year && c.month == d.month && c.day == d.day);
                final isBusy = _dateBusyMap[dateKey] == true;
                final isToday = d.year == today.year &&
                    d.month == today.month &&
                    d.day == today.day;
                return GestureDetector(
                  onTap: isBusy
                      ? null
                      : () {
                          setState(() {
                            final key = _customDates.firstWhere(
                                (c) =>
                                    c.year == d.year &&
                                    c.month == d.month &&
                                    c.day == d.day,
                                orElse: () => DateTime(0));
                            if (key.year == 0)
                              _customDates.add(d);
                            else
                              _customDates.remove(key);
                            _totalEdited = false;
                            _syncPrice();
                          });
                        },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 150),
                    width: 52,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isBusy
                          ? Color(0xFFFEF2F2)
                          : (isSel ? _c.accent : _c.bg),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isBusy
                              ? Color(0xFFFCA5A5)
                              : (isSel
                                  ? _c.accent
                                  : (isToday
                                      ? _c.accent.withValues(alpha: .5)
                                      : _c.border))),
                    ),
                    child: Stack(children: [
                      Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            Text(DateFormat('EEE').format(d),
                                style: TextStyle(
                                    color: isBusy
                                        ? Color(0xFFEF4444)
                                        : (isSel ? Colors.white : _c.muted),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700)),
                            SizedBox(height: 2),
                            Text('${d.day}',
                                style: TextStyle(
                                    color: isBusy
                                        ? Color(0xFFEF4444)
                                        : (isSel ? Colors.white : _c.text),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900)),
                            Text(DateFormat('MMM').format(d),
                                style: TextStyle(
                                    color: isBusy
                                        ? Color(0xFFEF4444)
                                            .withValues(alpha: .7)
                                        : (isSel
                                            ? Colors.white.withValues(alpha: .8)
                                            : _c.muted),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600)),
                          ])),
                      if (isBusy)
                        Positioned(
                            top: 4,
                            right: 4,
                            child: Icon(Icons.block_rounded,
                                size: 10, color: Color(0xFFEF4444))),
                    ]),
                  ),
                );
              }).toList()),
          if (_customDates.isNotEmpty) ...[
            SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                  color: _c.accent.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _c.accent.withValues(alpha: .3))),
              child: Row(children: [
                Icon(Icons.calculate_outlined, color: _c.accent, size: 18),
                SizedBox(width: 10),
                Expanded(
                    child: Text(
                        '${_customDates.length} days × ₹${(_totalPaise ~/ _customDates.length / 100).toStringAsFixed(0)}/day',
                        style: TextStyle(
                            color: _c.accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 13))),
                Text('₹${(_totalPaise / 100).toStringAsFixed(0)}',
                    style: TextStyle(
                        color: _c.accent,
                        fontWeight: FontWeight.w900,
                        fontSize: 15)),
              ]),
            ),
          ],
        ],
        SizedBox(height: 24),
      ]);
    }

    final today = DateTime.now();
    final stripDates = List.generate(
        30, (i) => DateTime(today.year, today.month, today.day + i));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Pick a date',
              style: TextStyle(
                  color: _c.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5)),
          SizedBox(height: 2),
          Text('${_durationLabel(_currentDurationMins)} · ${_unit?.name ?? ''}',
              style: TextStyle(
                  color: _c.muted, fontSize: 13, fontWeight: FontWeight.w500)),
        ])),
        GestureDetector(
          onTap: _selectStartDate,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: _c.bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _c.border)),
            child: Icon(Icons.calendar_month_rounded, color: _c.muted, size: 20),
          ),
        ),
      ]),
      SizedBox(height: 16),

      // Horizontal date strip
      SizedBox(
        height: 70,
        child: ListView.separated(
          controller: _dateStripCtrl,
          scrollDirection: Axis.horizontal,
          itemCount: stripDates.length,
          separatorBuilder: (_, __) => SizedBox(width: 8),
          itemBuilder: (ctx, i) {
            final d = stripDates[i];
            final isSel = d.year == _selectedDate.year &&
                d.month == _selectedDate.month &&
                d.day == _selectedDate.day;
            final isToday = i == 0;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = d;
                  _selectedSlots.clear();
                  _totalEdited = false;
                });
                _loadAvailability();
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 180),
                width: 52,
                decoration: BoxDecoration(
                  color: isSel ? _c.accent : _c.bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isSel ? _c.accent : _c.border),
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isToday ? 'Today' : DateFormat('EEE').format(d),
                        style: TextStyle(
                            color: isSel ? Colors.white : _c.muted,
                            fontSize: isToday ? 9 : 11,
                            fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${d.day}',
                        style: TextStyle(
                            color: isSel ? Colors.white : _c.text,
                            fontSize: 18,
                            fontWeight: FontWeight.w900),
                      ),
                      Text(
                        DateFormat('MMM').format(d),
                        style: TextStyle(
                            color: isSel
                                ? Colors.white.withValues(alpha: .8)
                                : _c.muted,
                            fontSize: 10,
                            fontWeight: FontWeight.w600),
                      ),
                    ]),
              ),
            );
          },
        ),
      ),
      SizedBox(height: 20),

      // Slot or full-day status
      if (_isFullDay) ...[
        if (_loadingAvail)
          Center(
              child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _c.accent))))
        else if (_fullDayBusy)
          Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFFFCA5A5))),
              child: Row(children: [
                Icon(Icons.block_rounded,
                    color: Color(0xFFEF4444), size: 18),
                SizedBox(width: 12),
                Expanded(
                    child: Text(
                        'Already booked · $_fullDayOpen – $_fullDayClose',
                        style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 13,
                            fontWeight: FontWeight.w700))),
              ]))
        else
          Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: _c.accent.withValues(alpha: .06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _c.accent.withValues(alpha: .3))),
              child: Row(children: [
                Icon(Icons.check_circle_rounded, color: _c.accent, size: 18),
                SizedBox(width: 12),
                Expanded(
                    child: Text('Available · $_fullDayOpen to $_fullDayClose',
                        style: TextStyle(
                            color: _c.accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w700))),
              ])),
      ] else ...[
        Text('SELECT START TIME',
            style: TextStyle(
                color: _c.muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
        SizedBox(height: 12),
        if (_loadingAvail)
          Center(
              child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _c.accent))))
        else if (_allDaySlots.isEmpty)
          Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: _c.bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _c.border)),
              child: Row(children: [
                Icon(Icons.info_outline_rounded, color: _c.muted, size: 18),
                SizedBox(width: 12),
                Text('No slots available for this date.',
                    style: TextStyle(
                        color: _c.muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ]))
        else
          _StartTimeGrid(
            times: _allDaySlots,
            selected: _selectedSlots,
            busyTimes: {
              for (final t in _allDaySlots)
                if (_isBusy(t)) t
            },
            onSelect: _onSlotTapped,
            isGround: (_unit?.unitType == 'FULL_GROUND' ||
                _unit?.unitType == 'HALF_GROUND' ||
                (_unit?.minSlotMins ?? 0) >= 240),
            durationMins: _currentDurationMins,
            slotPricePaise: _unit != null
                ? BookingPricingEngine.computeTotal(
                    _unit!,
                    durationMins: _currentDurationMins,
                    variantPricePaise: _variantPricePerHour,
                    date: _selectedDate,
                  )
                : 0,
          ),
        if (_selectedSlots.isNotEmpty) ...[
          SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
                color: _c.accent.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _c.accent.withValues(alpha: .25))),
            child: Row(children: [
              Icon(Icons.schedule_rounded, color: _c.accent, size: 18),
              SizedBox(width: 12),
              Text('$_startTime → $_endTime',
                  style: TextStyle(
                      color: _c.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w800)),
              SizedBox(width: 8),
              Text('· ${_durationLabel(_currentDurationMins)}',
                  style: TextStyle(
                      color: _c.muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
        ],
      ],
      SizedBox(height: 24),
    ]);
  }

  // ── Step 2: Confirm (Guest + Payment) ────────────────────────────────────
  Widget _buildConfirmStep() {
    if (!_totalEdited && _totalCtrl.text.isEmpty) _syncPrice();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Phone lookup
      TextField(
        controller: _phoneCtrl,
        keyboardType: TextInputType.phone,
        maxLength: 13,
        autofocus: true,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
          LengthLimitingTextInputFormatter(13),
        ],
        style: TextStyle(
            color: _c.text, fontSize: 16, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          hintText: 'Guest mobile number',
          prefixIcon:
              Icon(Icons.phone_android_rounded, size: 18, color: _c.accent),
          suffixIcon: _searchingUser
              ? Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _c.accent)))
              : (_customerLookup?.exists == true || _foundGuest != null)
                  ? Icon(Icons.check_circle_rounded,
                      color: Colors.green, size: 20)
                  : (_lookupDone &&
                          _normalisedLookupPhone(_phoneCtrl.text).length == 10)
                      ? Icon(Icons.person_add_rounded,
                          color: _c.muted, size: 20)
                      : null,
          filled: true,
          fillColor: _c.bg,
          counterText: '',
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                  color: _hasSelectedGuest
                      ? Colors.green.withValues(alpha: .4)
                      : _c.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                  color: _hasSelectedGuest ? Colors.green : _c.accent,
                  width: 1.8)),
        ),
      ),
      SizedBox(height: 10),
      // Found guest card
      AnimatedSize(
        duration: Duration(milliseconds: 240),
        curve: Curves.easeInOut,
        child: _hasSelectedGuest && _guestResultExpanded
            ? GestureDetector(
                onTap: _selectFetchedGuest,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: .06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.green.withValues(alpha: .25))),
                  child: Row(children: [
                    Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: .12),
                            shape: BoxShape.circle),
                        child: Center(
                            child: Text(
                                (_customerLookup?.name ?? _foundGuest!.name)
                                        .isNotEmpty
                                    ? (_customerLookup?.name ??
                                            _foundGuest!.name)[0]
                                        .toUpperCase()
                                    : '?',
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16)))),
                    SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(_customerLookup?.name ?? _foundGuest!.name,
                              style: TextStyle(
                                  color: _c.text,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14)),
                          SizedBox(height: 2),
                          Row(children: [
                            Text(
                                _customerLookup?.exists == true
                                    ? 'Swing user selected'
                                    : '${_foundGuest!.totalBookings} booking${_foundGuest!.totalBookings != 1 ? "s" : ""}',
                                style: TextStyle(
                                    color: _c.muted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                            if ((_foundGuest?.balanceDuePaise ?? 0) > 0) ...[
                              SizedBox(width: 6),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(6)),
                                  child: Text(
                                      '₹${(_foundGuest!.balanceDuePaise / 100).toStringAsFixed(0)} due',
                                      style: TextStyle(
                                          color: Color(0xFFEF4444),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800))),
                            ],
                          ]),
                        ])),
                    GestureDetector(
                        onTap: _clearGuest,
                        child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                color: _c.bg,
                                borderRadius: BorderRadius.circular(8)),
                            child: Icon(Icons.close_rounded,
                                color: _c.muted, size: 15))),
                  ]),
                ))
            : SizedBox(width: double.infinity, height: 0),
      ),
      // New customer name
      AnimatedSize(
        duration: Duration(milliseconds: 240),
        curve: Curves.easeInOut,
        child: _showGuestNameInput
            ? Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!_hasSelectedGuest)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                              color: _c.accent.withValues(alpha: .08),
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.person_add_rounded,
                                size: 13, color: _c.accent),
                            SizedBox(width: 5),
                            Text('New customer',
                                style: TextStyle(
                                    color: _c.accent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ]),
                        ),
                      _FormTextField(
                          label: 'Guest Name',
                          controller: _nameCtrl,
                          icon: Icons.person_outline_rounded),
                    ]),
              )
            : SizedBox(width: double.infinity, height: 0),
      ),
      const SizedBox(height: 20),
      // ── Pricing review block ──────────────────────────────────────────────
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _c.border),
        ),
        child: Column(children: [
          Row(children: [
            Text('Base price',
                style: TextStyle(color: _c.muted, fontSize: 14, fontWeight: FontWeight.w600)),
            const Spacer(),
            Text(
              '₹${(_totalPaise / 100).toStringAsFixed(0)}',
              style: TextStyle(color: _c.text, fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ]),
          if (_discountPaise > 0) ...[
            const SizedBox(height: 10),
            Row(children: [
              Text('Discount',
                  style: TextStyle(color: _c.muted, fontSize: 14, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(
                '-₹${(_discountPaise / 100).toStringAsFixed(0)}',
                style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ]),
            const SizedBox(height: 10),
            Divider(color: _c.border, height: 1),
            const SizedBox(height: 10),
            Row(children: [
              Text('Total',
                  style: TextStyle(color: _c.text, fontSize: 16, fontWeight: FontWeight.w800)),
              const Spacer(),
              Text(
                '₹${(_finalPaise / 100).toStringAsFixed(0)}',
                style: TextStyle(color: _c.accent, fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ]),
          ] else ...[
            const SizedBox(height: 10),
            Divider(color: _c.border, height: 1),
            const SizedBox(height: 10),
            Row(children: [
              Text('Total',
                  style: TextStyle(color: _c.text, fontSize: 16, fontWeight: FontWeight.w800)),
              const Spacer(),
              Text(
                '₹${(_totalPaise / 100).toStringAsFixed(0)}',
                style: TextStyle(color: _c.accent, fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ]),
          ],
        ]),
      ),
      const SizedBox(height: 12),
      // ── Discount ──────────────────────────────────────────────────────────
      _FormTextField(
        label: 'Discount (₹) — optional',
        controller: _discountCtrl,
        icon: Icons.discount_outlined,
        keyboardType: TextInputType.number,
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 12),
      // ── Advance ───────────────────────────────────────────────────────────
      _FormTextField(
        label: _minAdvancePaise > 0
            ? 'Advance (min ₹${(_minAdvancePaise / 100).toStringAsFixed(0)})'
            : 'Advance collected (₹)',
        controller: _advanceCtrl,
        icon: Icons.payments_outlined,
        keyboardType: TextInputType.number,
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 20),
      // ── Payment mode — big boxes ──────────────────────────────────────────
      Row(children: [
        _PayMethodBox(
          label: 'Cash',
          icon: Icons.payments_rounded,
          selected: _paymentMode == 'CASH',
          onTap: () => setState(() => _paymentMode = 'CASH'),
        ),
        const SizedBox(width: 12),
        _PayMethodBox(
          label: 'Online / UPI',
          icon: Icons.qr_code_rounded,
          selected: _paymentMode == 'UPI' || _paymentMode == 'ONLINE',
          onTap: () => setState(() => _paymentMode = 'UPI'),
        ),
      ]),
      const SizedBox(height: 14),
      _FormTextField(
          label: 'Notes (optional)',
          controller: _notesCtrl,
          icon: Icons.notes_rounded),
      const SizedBox(height: 24),
    ]);
  }

  String get _confirmLabel {
    if (_isNetsFlow) return 'Book  $_startTime – $_endTime';
    if (_isMultiDay && _isCustomDates)
      return 'Confirm ${_customDates.length}-Day Booking';
    if (_isMultiDay) return 'Confirm $_bulkDays-Day Booking';
    if (_isFullDay) return 'Confirm Full Day';
    return 'Confirm $_startTime – $_endTime';
  }
}

String _groundPriceLabel(List<ArenaUnitOption> units) {
  final u = units
      .where((u) => u.unitType == 'FULL_GROUND' || u.unitType == 'HALF_GROUND')
      .firstOrNull;
  if (u == null) return '';
  final paise = u.price4HrPaise ?? (u.pricePerHourPaise * 4);
  return '₹${paise ~/ 100}/4hr';
}

String _netPriceLabel(List<ArenaUnitOption> units) {
  final u = units
      .where((u) => u.unitType == 'CRICKET_NET' || u.unitType == 'INDOOR_NET')
      .firstOrNull;
  if (u == null) return '';
  if (u.hasVariants) {
    final prices =
        u.netVariants.map((v) => v.pricePaise).whereType<int>().toList();
    if (prices.isNotEmpty) {
      final min = prices.reduce((a, b) => a < b ? a : b);
      return 'from ₹${min ~/ 100}/hr';
    }
  }
  if (u.pricePerHourPaise > 0) return '₹${u.pricePerHourPaise ~/ 100}/hr';
  return '';
}

// ── Ticket header ─────────────────────────────────────────────────────────────
class _TicketHeader extends StatelessWidget {
  const _TicketHeader({
    required this.arenaName,
    required this.step,
    required this.stepLabels,
    required this.selectedDate,
    required this.onBack,
    required this.isFirstStep,
  });
  final String arenaName;
  final int step;
  final List<String> stepLabels;
  final DateTime selectedDate;
  final VoidCallback onBack;
  final bool isFirstStep;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final top = MediaQuery.of(context).padding.top;
    final accent = _c.accent;
    return Container(
      color: _c.bg,
      padding: EdgeInsets.fromLTRB(20, top + 12, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Top row: back + step dots
        Row(children: [
          GestureDetector(
            onTap: onBack,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 4, top: 4),
              child: Icon(
                isFirstStep ? Icons.close_rounded : Icons.arrow_back_rounded,
                color: _c.text,
                size: 22,
              ),
            ),
          ),
          const Spacer(),
          // Dot progress
          Row(
            children: List.generate(stepLabels.length, (i) {
              final done = i < step;
              final cur = i == step;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(left: 6),
                width: cur ? 20 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: done || cur ? accent : _c.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ]),
        const SizedBox(height: 20),
        // Venue name
        Text(
          arenaName.toUpperCase(),
          style: TextStyle(
            color: _c.muted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 6),
        // Step label — big ticket title
        Text(
          stepLabels[step],
          style: TextStyle(
            color: _c.text,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 10),
        // Date row
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              DateFormat('EEE, MMM d').format(selectedDate),
              style: TextStyle(
                color: accent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${step + 1} of ${stepLabels.length}',
            style: TextStyle(
              color: _c.muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ]),
      ]),
    );
  }
}

// ── Perforated stub divider ───────────────────────────────────────────────────
class _PerforatedDivider extends StatelessWidget {
  const _PerforatedDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Stack(children: [
        Positioned(
          left: 0,
          right: 0,
          top: 11,
          child: LayoutBuilder(builder: (_, constraints) {
            final dashW = 6.0;
            final gapW = 5.0;
            final count = (constraints.maxWidth / (dashW + gapW)).floor();
            _c = _C.of(_);
            return Row(
              children: List.generate(count, (__) => Padding(
                padding: EdgeInsets.only(right: gapW),
                child: Container(
                  width: dashW,
                  height: 1.5,
                  color: _c.border,
                ),
              )),
            );
          }),
        ),
        Positioned(
          left: -12,
          top: 0,
          child: _HalfCircle(left: true),
        ),
        Positioned(
          right: -12,
          top: 0,
          child: _HalfCircle(left: false),
        ),
      ]),
    );
  }
}

class _HalfCircle extends StatelessWidget {
  const _HalfCircle({required this.left});
  final bool left;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Align(
        alignment: left ? Alignment.centerRight : Alignment.centerLeft,
        widthFactor: 0.5,
        child: Builder(builder: (ctx) {
          _c = _C.of(ctx);
          return Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _c.bg,
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}

// ── Step indicator ────────────────────────────────────────────────────────────
class _BookingStepBar extends StatelessWidget {
  const _BookingStepBar({required this.step, required this.labels});
  final int step;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
          children: List.generate(labels.length * 2 - 1, (i) {
        if (i.isOdd) {
          final idx = i ~/ 2;
          final done = idx < step;
          return Expanded(
              child: Container(
            height: 2,
            color: done ? _c.accent : _c.border,
          ));
        }
        final idx = i ~/ 2;
        final done = idx < step;
        final current = idx == step;
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: current ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: done || current ? _c.accent : _c.border,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      })),
      SizedBox(height: 10),
      Row(children: [
        Text(labels[step].toUpperCase(),
            style: TextStyle(
                color: _c.accent,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0)),
        SizedBox(width: 8),
        Text('${step + 1} of ${labels.length}',
            style: TextStyle(
                color: _c.muted, fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    ]);
  }
}

// ── Multi-day bulk-discount toggle ────────────────────────────────────────────

class _MultiDayToggle extends StatelessWidget {
  const _MultiDayToggle({
    required this.isActive,
    required this.pricePerDayRupees,
    required this.minDays,
    required this.onTap,
  });

  final bool isActive;
  final int pricePerDayRupees;
  final int minDays;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final accent = _c.accent;
    final onAccent = _c.onAccent;
    final tile = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: isActive
            ? accent.withValues(alpha: 0.10)
            : _c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? accent : _c.border,
          width: isActive ? 1.4 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Lead icon — primary tint when active
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive
                  ? accent
                  : accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              size: 20,
              color: isActive ? onAccent : accent,
            ),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Bulk rental',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.1,
                        color: _c.text,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isActive ? accent : _c.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isActive ? 'ACTIVE' : 'SAVE',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: isActive ? onAccent : _c.muted,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _c.muted,
                      letterSpacing: -0.1,
                    ),
                    children: [
                      TextSpan(
                        text: '₹$pricePerDayRupees',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isActive ? accent : _c.text,
                        ),
                      ),
                      const TextSpan(text: '/day  ·  '),
                      TextSpan(text: 'min $minDays days'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Switch indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: 36,
            height: 22,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isActive ? accent : _c.border,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  alignment: isActive
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: _c.surface,
                      shape: BoxShape.circle,
                    ),
                    child: isActive
                        ? Center(
                            child: Icon(Icons.check_rounded,
                                size: 12, color: accent),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: tile,
    );
  }
}

// ── Next / Confirm button with disabled state ─────────────────────────────────
class _BookingActionButton extends StatelessWidget {
  const _BookingActionButton(
      {required this.label,
      required this.enabled,
      required this.onTap,
      this.trailing});
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: enabled ? _c.accent : _c.border,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(label,
              style: TextStyle(
                  color: enabled ? Colors.white : _c.muted,
                  fontWeight: FontWeight.w800,
                  fontSize: 15)),
          if (trailing != null) ...[
            SizedBox(width: 8),
            Icon(trailing, size: 18, color: enabled ? Colors.white : _c.muted),
          ],
        ]),
      ),
    );
  }
}

class _CourtCard extends StatelessWidget {
  const _CourtCard({
    required this.unit,
    required this.selected,
    required this.isWeekend,
    required this.onTap,
  });
  final ArenaUnitOption unit;
  final bool selected;
  final bool isWeekend;
  final VoidCallback onTap;

  bool get _isNet =>
      unit.unitType == 'CRICKET_NET' || unit.unitType == 'INDOOR_NET';

  String _groundPricing() {
    final parts = <String>[];
    if (unit.price4HrPaise != null)
      parts.add('4hr · ₹${unit.price4HrPaise! ~/ 100}');
    if (unit.price8HrPaise != null)
      parts.add('8hr · ₹${unit.price8HrPaise! ~/ 100}');
    if (unit.priceFullDayPaise != null)
      parts.add('Full day · ₹${unit.priceFullDayPaise! ~/ 100}');
    if (parts.isEmpty && unit.pricePerHourPaise > 0)
      parts.add('₹${unit.pricePerHourPaise ~/ 100}/hr');
    return parts.join('   ');
  }

  String _netPricing() {
    if (unit.netVariants.isNotEmpty) {
      return unit.netVariants
          .map((v) =>
              '${v.label} · ₹${((v.pricePaise ?? unit.pricePerHourPaise) / 100).toStringAsFixed(0)}/hr')
          .join('   ');
    }
    return '₹${unit.pricePerHourPaise ~/ 100}/hr';
  }

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final weekendActive = isWeekend && unit.weekendMultiplier > 1.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? _c.accent : _c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? _c.accent : _c.border,
            width: selected ? 0 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected
                    ? _c.onAccent.withValues(alpha: 0.15)
                    : _c.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _isNet ? Icons.sports_cricket_rounded : Icons.grass_rounded,
                size: 24,
                color: selected ? _c.onAccent : _c.accent,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(
                      unit.name,
                      style: TextStyle(
                        color: selected ? _c.onAccent : _c.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (weekendActive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: selected
                              ? _c.onAccent.withValues(alpha: 0.2)
                              : _c.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${((unit.weekendMultiplier - 1) * 100).round()}% weekend',
                          style: TextStyle(
                            color: selected ? _c.onAccent : _c.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ]),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? _c.onAccent : _c.border,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _BizTypeTile extends StatelessWidget {
  const _BizTypeTile(
      {required this.icon,
      required this.label,
      required this.sublabel,
      required this.selected,
      required this.onTap});
  final IconData icon;
  final String label;
  final String sublabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? _c.accent : _c.bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? _c.accent : _c.border),
        ),
        child: Row(children: [
          Icon(icon, size: 22, color: selected ? Colors.white : _c.muted),
          SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(label,
                    style: TextStyle(
                        color: selected ? Colors.white : _c.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 14)),
                if (sublabel.isNotEmpty)
                  Text(sublabel,
                      style: TextStyle(
                          color: selected ? Colors.white70 : _c.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
              ])),
          if (selected)
            Icon(Icons.check_circle_rounded,
                color: _c.surface, size: 18),
        ]),
      ),
    );
  }
}

class _BizBookingTypeTile extends StatelessWidget {
  const _BizBookingTypeTile(
      {required this.label,
      required this.icon,
      required this.selected,
      required this.onTap,
      this.badge});
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? _c.accent : _c.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? _c.accent : _c.border),
        ),
        child: Row(children: [
          Icon(icon, size: 18, color: selected ? Colors.white : _c.muted),
          SizedBox(width: 8),
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: selected ? Colors.white : _c.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 13))),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color:
                    selected ? Colors.white24 : _c.accent.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(badge!,
                  style: TextStyle(
                      color: selected ? Colors.white : _c.accent,
                      fontSize: 9,
                      fontWeight: FontWeight.w800)),
            ),
        ]),
      ),
    );
  }
}

class _BizDateTile extends StatelessWidget {
  const _BizDateTile(
      {required this.label,
      required this.date,
      required this.onTap,
      this.highlight = false});
  final String label;
  final DateTime date;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: highlight ? _c.accent.withValues(alpha: .06) : _c.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: highlight ? _c.accent.withValues(alpha: .5) : _c.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text(label,
                    style: TextStyle(
                        color: highlight ? _c.accent : _c.muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700))),
            if (highlight)
              Icon(Icons.touch_app_rounded,
                  size: 14, color: _c.accent.withValues(alpha: .6)),
          ]),
          SizedBox(height: 4),
          Text(DateFormat('d MMM yyyy').format(date),
              style: TextStyle(
                  color: highlight ? _c.accent : _c.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w800)),
          Text(DateFormat('EEEE').format(date),
              style: TextStyle(
                  color: highlight ? _c.accent.withValues(alpha: .7) : _c.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class _BizBulkRateInfo extends StatelessWidget {
  const _BizBulkRateInfo({required this.unit, required this.days});
  final ArenaUnitOption unit;
  final int days;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final hasBulkConfig =
        unit.minBulkDays != null && unit.bulkDayRatePaise != null;
    if (!hasBulkConfig) return const SizedBox.shrink();
    if (days < unit.minBulkDays!) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
            'Add ${unit.minBulkDays! - days} more day${unit.minBulkDays! - days > 1 ? 's' : ''} to unlock bulk rate',
            style: TextStyle(
                color: _c.muted, fontSize: 12, fontWeight: FontWeight.w600)),
      );
    }
    final bulkTotal = (unit.bulkDayRatePaise! * days) ~/ 100;
    final normalPaise = unit.price4HrPaise ?? (unit.pricePerHourPaise * 4);
    final normalTotal = (normalPaise * days) ~/ 100;
    final saving = normalTotal - bulkTotal;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.withValues(alpha: .2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.check_circle_rounded, size: 15, color: Colors.green),
          SizedBox(width: 6),
          Text('Bulk rate unlocked — $days days',
              style: TextStyle(
                  color: Colors.green,
                  fontSize: 13,
                  fontWeight: FontWeight.w800)),
        ]),
        SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('₹${unit.bulkDayRatePaise! ~/ 100}/day × $days days',
              style: TextStyle(
                  color: _c.muted, fontSize: 12, fontWeight: FontWeight.w600)),
          Text('₹$bulkTotal total',
              style: TextStyle(
                  color: _c.text, fontSize: 13, fontWeight: FontWeight.w900)),
        ]),
        if (saving > 0) ...[
          SizedBox(height: 4),
          Text('Save ₹$saving vs normal rate',
              style: TextStyle(
                  color: Colors.green,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ],
      ]),
    );
  }
}

class _FormTextField extends StatelessWidget {
  const _FormTextField(
      {required this.label,
      required this.controller,
      this.icon,
      this.keyboardType,
      this.onChanged,
      this.maxLength});
  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: _c.muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          maxLength: maxLength,
          inputFormatters: maxLength != null
              ? [LengthLimitingTextInputFormatter(maxLength)]
              : null,
          style: TextStyle(
              color: _c.text, fontSize: 14, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            prefixIcon: icon != null
                ? Icon(icon, size: 18, color: _c.accent.withValues(alpha: .5))
                : null,
            filled: true,
            fillColor: _c.surface,
            counterText: '',
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _c.border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _c.accent, width: 1.6)),
          ),
        ),
      ],
    );
  }
}

class _StartTimeGrid extends StatelessWidget {
  const _StartTimeGrid(
      {required this.times,
      required this.selected,
      required this.busyTimes,
      required this.onSelect,
      this.isGround = false,
      this.durationMins = 60,
      this.slotPricePaise = 0});
  final List<String> times;
  final dynamic selected;
  final Set<String> busyTimes;
  final ValueChanged<String> onSelect;
  final bool isGround;
  final int durationMins;
  final int slotPricePaise;

  String _periodLabel(String hhmm) {
    final h = int.tryParse(hhmm.split(':').first) ?? 0;
    if (h < 4) return 'Late Night';
    if (h < 12) return 'Morning';
    if (h < 16) return 'Afternoon';
    if (h < 20) return 'Evening';
    return 'Night';
  }

  IconData _periodIcon(String hhmm) {
    final h = int.tryParse(hhmm.split(':').first) ?? 0;
    if (h < 4) return Icons.bedtime_rounded;
    if (h < 12) return Icons.wb_sunny_rounded;
    if (h < 16) return Icons.wb_cloudy_rounded;
    if (h < 20) return Icons.wb_twilight_rounded;
    return Icons.nights_stay_rounded;
  }

  String _endTime(String start) => _addMinutes(start, durationMins);

  String _fmt12(String hhmm) {
    final parts = hhmm.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    final suffix = h < 12 ? 'am' : 'pm';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return m == 0
        ? '$h12$suffix'
        : '$h12:${m.toString().padLeft(2, '0')}$suffix';
  }

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final selList = selected is List<String>
        ? selected as List<String>
        : [selected as String];

    if (isGround) {
      return Column(
        children: times.map((t) {
          final busy = busyTimes.contains(t);
          final sel = selList.contains(t);
          final period = _periodLabel(t);
          final icon = _periodIcon(t);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: busy ? null : () => onSelect(t),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: sel ? _c.accent : (busy ? _c.bg : _c.surface),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: sel
                          ? _c.accent
                          : (busy ? _c.border.withValues(alpha: .3) : _c.border)),
                ),
                child: Row(
                  children: [
                    Icon(icon,
                        size: 18,
                        color: sel
                            ? Colors.white
                            : (busy ? _c.muted.withValues(alpha: .3) : _c.accent)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(period,
                              style: TextStyle(
                                  color: sel
                                      ? Colors.white
                                      : (busy
                                          ? _c.muted.withValues(alpha: .3)
                                          : _c.text),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  decoration: busy
                                      ? TextDecoration.lineThrough
                                      : null)),
                          Text('${_fmt12(t)} – ${_fmt12(_endTime(t))}',
                              style: TextStyle(
                                  color: sel
                                      ? Colors.white.withOpacity(0.8)
                                      : (busy
                                          ? _c.muted.withValues(alpha: .25)
                                          : _c.muted),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    if (busy)
                      Icon(Icons.block_rounded, size: 16, color: _c.muted)
                    else if (slotPricePaise > 0)
                      Text(
                        '₹${(slotPricePaise / 100).toStringAsFixed(0)}',
                        style: TextStyle(
                          color: sel ? _c.onAccent.withValues(alpha: 0.85) : _c.accent,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: times.map((t) {
          final busy = busyTimes.contains(t);
          final sel = selList.contains(t);
          return GestureDetector(
            onTap: busy ? null : () => onSelect(t),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                  color: sel ? _c.accent : (busy ? Colors.transparent : _c.surface),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: sel
                          ? _c.accent
                          : (busy ? _c.border.withValues(alpha: .3) : _c.border))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_fmt12(t),
                      style: TextStyle(
                          color: sel
                              ? _c.onAccent
                              : (busy ? _c.muted.withValues(alpha: .3) : _c.text),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          decoration: busy ? TextDecoration.lineThrough : null)),
                  if (slotPricePaise > 0 && !busy) ...[
                    const SizedBox(height: 2),
                    Text(
                      '₹${(slotPricePaise / 100).toStringAsFixed(0)}',
                      style: TextStyle(
                        color: sel
                            ? _c.onAccent.withValues(alpha: 0.75)
                            : _c.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList());
  }
}

class _SlotPicker extends StatelessWidget {
  const _SlotPicker(
      {required this.slots, required this.selectedIdx, required this.onSelect});
  final List<_SlotOption> slots;
  final int selectedIdx;
  final ValueChanged<int> onSelect;
  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(slots.length, (i) {
          final sel = i == selectedIdx;
          final price = '₹${(slots[i].paise / 100).toStringAsFixed(0)}';
          return GestureDetector(
            onTap: () => onSelect(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                  color: sel ? _c.accent : _c.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sel ? _c.accent : _c.border)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(slots[i].label,
                    style: TextStyle(
                        color: sel ? Colors.black : _c.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w800)),
                SizedBox(height: 2),
                Text(price,
                    style: TextStyle(
                        color:
                            sel ? Colors.black.withValues(alpha: .6) : _c.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          );
        }));
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _c.accent : _c.bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? _c.accent : _c.border),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.black : _c.text,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// ── Big payment method selector ───────────────────────────────────────────────
class _PayMethodBox extends StatelessWidget {
  const _PayMethodBox({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 88,
          decoration: BoxDecoration(
            color: selected ? _c.accent : _c.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? _c.accent : _c.border,
              width: selected ? 0 : 1,
            ),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: selected ? _c.onAccent : _c.text, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? _c.onAccent : _c.text,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _SegmentPicker extends StatelessWidget {
  const _SegmentPicker(
      {required this.options, required this.selected, required this.onSelect});
  final List<(String, String)> options;
  final String selected;
  final ValueChanged<String> onSelect;
  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((o) {
          final sel = o.$1 == selected;
          return GestureDetector(
            onTap: () => onSelect(o.$1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: sel ? _c.accent : _c.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: sel ? _c.accent : _c.border)),
              child: Text(o.$2,
                  style: TextStyle(
                      color: sel ? Colors.black : _c.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
          );
        }).toList());
  }
}
