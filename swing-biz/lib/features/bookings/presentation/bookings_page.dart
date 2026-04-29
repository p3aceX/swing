import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../../arena/widgets/arena_widgets.dart';

// ─── Theme Overrides ─────────────────────────────────────────────────────────
const _bg = Color(0xFFF9FAFB);
const _surface = Color(0xFFFFFFFF);
const _border = Color(0xFFE5E7EB);
const _accent = Color(0xFF059669);
const _accentLight = Color(0xFFD1FAE5);
const _text = Color(0xFF111827);
const _muted = Color(0xFF6B7280);

// ─── Providers ───────────────────────────────────────────────────────────────

final _selectedArenaProvider = StateProvider<String?>((ref) => null);

final _allBookingsProvider = FutureProvider.autoDispose
    .family<List<ArenaReservation>, String>((ref, arenaId) async {
  final repo = ref.watch(hostArenaBookingRepositoryProvider);
  return repo.listArenaBookings(arenaId);
});

// ─── Main page ───────────────────────────────────────────────────────────────

class BookingsPage extends ConsumerWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arenasAsync = ref.watch(ownedArenasProvider);

    return arenasAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: _accent)),
      error: (e, _) => _ErrorView(message: '$e'),
      data: (arenas) {
        if (arenas.isEmpty) return const _EmptyArenas();

        final selectedId = ref.watch(_selectedArenaProvider) ?? arenas.first.id;
        final arena = arenas.firstWhere((a) => a.id == selectedId,
            orElse: () => arenas.first);

        return Scaffold(
          backgroundColor: _bg,
          body: _BookingsBody(arena: arena, arenas: arenas),
        );
      },
    );
  }
}

// ─── Main body ───────────────────────────────────────────────────────────────

class _BookingsBody extends ConsumerStatefulWidget {
  const _BookingsBody({required this.arena, required this.arenas});
  final ArenaListing arena;
  final List<ArenaListing> arenas;

  @override
  ConsumerState<_BookingsBody> createState() => _BookingsBodyState();
}

class _BookingsBodyState extends ConsumerState<_BookingsBody> {
  String _selectedFilter = 'All';
  String _selectedUnitId = 'All';
  late DateTime _calendarMonth;
  bool _calendarExpanded = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _calendarMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final allBookingsAsync =
        ref.watch(_allBookingsProvider(widget.arena.id));

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          // Header
          allBookingsAsync.when(
            loading: () => const Padding(
                padding: EdgeInsets.all(20), child: LinearProgressIndicator()),
            error: (e, _) => const SizedBox.shrink(),
            data: (rawBookings) {
              final totalCount = rawBookings.length;
              final totalRev =
                  rawBookings.fold(0, (sum, b) => sum + b.totalAmountPaise);
              final collectedRev = rawBookings.fold(
                  0,
                  (sum, b) =>
                      sum + (b.isPaid ? b.totalAmountPaise : b.advancePaise));
              return _ModernHeader(
                arena: widget.arena,
                arenas: widget.arenas,
                totalCount: totalCount,
                totalRevenue: totalRev,
                collectedRevenue: collectedRev,
              );
            },
          ),

          const SizedBox(height: 16),

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
                'Checked In':
                    rawBookings.where((b) => b.status == 'CHECKED_IN').length,
                'Cancelled':
                    rawBookings.where((b) => b.status == 'CANCELLED').length,
              },
              onSelect: (v) => setState(() => _selectedFilter = v),
            ),
          ),

          const SizedBox(height: 12),
          // Unit filter + calendar toggle icon
          Row(children: [
            Expanded(
              child: _UnitFilterBar(
                units: widget.arena.units,
                selectedId: _selectedUnitId,
                onSelect: (id) => setState(() => _selectedUnitId = id),
              ),
            ),
            GestureDetector(
              onTap: () =>
                  setState(() => _calendarExpanded = !_calendarExpanded),
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _calendarExpanded
                      ? _accent.withValues(alpha: .1)
                      : _surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: _calendarExpanded ? _accent : _border),
                ),
                child: Icon(Icons.calendar_month_rounded,
                    size: 17,
                    color: _calendarExpanded ? _accent : _muted),
              ),
            ),
          ]),

          Expanded(
            child: allBookingsAsync.when(
              loading: () => const Center(
                  child:
                      CircularProgressIndicator(strokeWidth: 2, color: _accent)),
              error: (e, _) => _ErrorView(message: '$e'),
              data: (rawBookings) {
                // Apply filters
                final filtered = rawBookings.where((b) {
                  if (_selectedFilter == 'Confirmed' &&
                      b.status != 'CONFIRMED') return false;
                  if (_selectedFilter == 'Checked In' &&
                      b.status != 'CHECKED_IN') return false;
                  if (_selectedFilter == 'Cancelled' &&
                      b.status != 'CANCELLED') return false;
                  if (_selectedUnitId != 'All' && b.unitId != _selectedUnitId)
                    return false;
                  return true;
                }).toList();

                // Sort by date + startTime
                filtered.sort((a, b) {
                  final da = a.bookingDate ?? today;
                  final db = b.bookingDate ?? today;
                  final dateCmp = da.compareTo(db);
                  if (dateCmp != 0) return dateCmp;
                  return a.startTime.compareTo(b.startTime);
                });

                // Group by date for list
                final groups = <String, List<ArenaReservation>>{};
                for (final b in filtered) {
                  final key = b.bookingDate == null
                      ? DateFormat('yyyy-MM-dd').format(today)
                      : DateFormat('yyyy-MM-dd').format(b.bookingDate!);
                  groups.putIfAbsent(key, () => []).add(b);
                }
                final dateKeys = groups.keys.toList()..sort();
                final items = <dynamic>[];
                for (final dk in dateKeys) {
                  items.add(dk);
                  items.addAll(groups[dk]!);
                }

                return Column(children: [
                  // Month calendar (toggle)
                  _MonthCalendar(
                    bookings: rawBookings,
                    month: _calendarMonth,
                    expanded: _calendarExpanded,
                    onMonthChanged: (m) =>
                        setState(() => _calendarMonth = m),
                  ),

                  // List
                  Expanded(
                    child: filtered.isEmpty
                        ? _EmptyBookings(
                            onAdd: () =>
                                _showAddBookingSheet(context, today),
                            isFiltered: rawBookings.isNotEmpty,
                          )
                        : RefreshIndicator(
                            color: _accent,
                            backgroundColor: _surface,
                            onRefresh: () => ref.refresh(
                                _allBookingsProvider(widget.arena.id)
                                    .future),
                            child: ListView.builder(
                              padding: EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  100 +
                                      MediaQuery.of(context).padding.bottom),
                              itemCount: items.length,
                              itemBuilder: (context, i) {
                                final item = items[i];
                                if (item is String) {
                                  final d =
                                      DateFormat('yyyy-MM-dd').parse(item);
                                  final isToday =
                                      DateUtils.isSameDay(d, today);
                                  final isTomorrow = DateUtils.isSameDay(
                                      d,
                                      today.add(
                                          const Duration(days: 1)));
                                  final isPast = d.isBefore(DateTime(
                                      today.year, today.month, today.day));
                                  final label = isToday
                                      ? 'Today'
                                      : isTomorrow
                                          ? 'Tomorrow'
                                          : DateFormat('EEE, d MMM yyyy')
                                              .format(d);
                                  return Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        4, 16, 4, 8),
                                    child: Row(children: [
                                      Text(label,
                                          style: TextStyle(
                                              color:
                                                  isPast ? _muted : _text,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.2)),
                                      if (isPast) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets
                                              .symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                              color: _border,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      4)),
                                          child: const Text('past',
                                              style: TextStyle(
                                                  color: _muted,
                                                  fontSize: 10,
                                                  fontWeight:
                                                      FontWeight.w700)),
                                        ),
                                      ],
                                    ]),
                                  );
                                }
                                final booking = item as ArenaReservation;
                                return BookingCard(
                                  booking: booking,
                                  onTap: () => _showBookingDetail(
                                      context,
                                      booking,
                                      widget.arena.name,
                                      widget.arena.id),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBookingSheet(context, today),
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, size: 32),
      ),
    );
  }

  void _showAddBookingSheet(BuildContext context, DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => AddBookingSheet(arena: widget.arena, date: date),
    ).then((_) {
      ref.invalidate(_allBookingsProvider(widget.arena.id));
    });
  }

  void _showBookingDetail(BuildContext context, ArenaReservation booking,
      String arenaName, String arenaId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => BookingDetailSheet(
          booking: booking, arenaName: arenaName, arenaId: arenaId),
    ).then((_) {
      ref.invalidate(_allBookingsProvider(arenaId));
    });
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _ModernHeader extends ConsumerWidget {
  const _ModernHeader({
    required this.arena,
    required this.arenas,
    required this.totalCount,
    required this.totalRevenue,
    required this.collectedRevenue,
  });

  final ArenaListing arena;
  final List<ArenaListing> arenas;
  final int totalCount;
  final int totalRevenue;
  final int collectedRevenue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (arenas.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => _showArenaPicker(context, ref),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.stadium_rounded,
                            color: _accent, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          arena.name,
                          style: const TextStyle(
                              color: _text,
                              fontSize: 12,
                              fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.unfold_more_rounded,
                            color: _muted, size: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              _HeaderStat(
                label: 'Total Booking',
                value: '$totalCount',
                icon: Icons.confirmation_number_rounded,
                color: Colors.blue,
              ),
              const SizedBox(width: 12),
              _HeaderStat(
                label: 'Total Revenue',
                value: _moneyShort(totalRevenue),
                icon: Icons.payments_rounded,
                color: Colors.orange,
              ),
              const SizedBox(width: 12),
              _HeaderStat(
                label: 'Revenue Collected',
                value: _moneyShort(collectedRevenue),
                icon: Icons.check_circle_rounded,
                color: _accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showArenaPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Arena',
                style: TextStyle(
                    color: _text, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            ...arenas.map((a) => ListTile(
                  leading: const Icon(Icons.stadium_outlined, color: _accent),
                  title: Text(a.name,
                      style: const TextStyle(
                          color: _text, fontWeight: FontWeight.w700)),
                  onTap: () {
                    ref.read(_selectedArenaProvider.notifier).state = a.id;
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
          boxShadow: const [
            BoxShadow(
                color: Color(0x05000000), blurRadius: 8, offset: Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: .1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                  color: _text,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: _muted, fontSize: 9, fontWeight: FontWeight.w700),
            ),
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
      color: _surface,
      child: Column(children: [
        // Collapsible grid
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 220),
          crossFadeState: expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Column(children: [
              // Month nav
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                child: Row(children: [
                  Text(DateFormat('MMMM yyyy').format(month),
                      style: const TextStyle(
                          color: _text,
                          fontSize: 13,
                          fontWeight: FontWeight.w800)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => onMonthChanged(
                        DateTime(month.year, month.month - 1)),
                    child: const Icon(Icons.chevron_left_rounded,
                        color: _muted, size: 20),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => onMonthChanged(
                        DateTime(month.year, month.month + 1)),
                    child: const Icon(Icons.chevron_right_rounded,
                        color: _muted, size: 20),
                  ),
                ]),
              ),

              // Day-of-week headers
              Row(
                children: dayLabels
                    .map((d) => Expanded(
                          child: Center(
                            child: Text(d,
                                style: const TextStyle(
                                    color: _muted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 4),

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
                      return const Expanded(child: SizedBox(height: 38));
                    }

                    final date = DateTime(month.year, month.month, day);
                    final dateKey =
                        DateFormat('yyyy-MM-dd').format(date);
                    final count = counts[dateKey] ?? 0;
                    final isToday = DateUtils.isSameDay(date, today);

                    return Expanded(
                      child: Container(
                        height: 38,
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isToday
                              ? _accent
                              : count > 0
                                  ? _accentLight
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('$day',
                                style: TextStyle(
                                    color: isToday
                                        ? Colors.white
                                        : _text,
                                    fontSize: 12,
                                    fontWeight: isToday
                                        ? FontWeight.w900
                                        : FontWeight.w600)),
                            if (count > 0)
                              Text('$count',
                                  style: TextStyle(
                                      color: isToday
                                          ? Colors.white
                                              .withValues(alpha: .85)
                                          : _accent,
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

        const SizedBox(height: 8),
        const Divider(height: 1, color: _border),
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
                  style: const TextStyle(
                      color: _text, fontSize: 18, fontWeight: FontWeight.w900),
                ),
                Row(
                  children: [
                    _NavBtn(
                        Icons.chevron_left_rounded,
                        () => onMonthChanged(
                            DateTime(month.year, month.month - 1))),
                    const SizedBox(width: 12),
                    _NavBtn(
                        Icons.chevron_right_rounded,
                        () => onMonthChanged(
                            DateTime(month.year, month.month + 1))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 82,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: itemCount,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
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
                    duration: const Duration(milliseconds: 200),
                    width: 54,
                    decoration: BoxDecoration(
                      color: sel
                          ? _accent
                          : (isToday
                              ? _accent.withValues(alpha: .08)
                              : _surface),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: sel
                              ? _accent
                              : (isToday
                                  ? _accent.withValues(alpha: .4)
                                  : _border)),
                      boxShadow: sel
                          ? [
                              BoxShadow(
                                color: _accent.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
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
                              color: sel ? Colors.white : _muted,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$day',
                          style: TextStyle(
                              color: sel ? Colors.white : _text,
                              fontSize: 18,
                              fontWeight: FontWeight.w900),
                        ),
                        if (has) ...[
                          const SizedBox(height: 6),
                          Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                  color: sel ? Colors.white : _accent,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _border)),
        child: Icon(icon, color: _text, size: 18),
      ),
    );
  }
}

// ─── Booking Tile ────────────────────────────────────────────────────────────

class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
    required this.onTap,
    this.isNextUp = false,
  });
  final ArenaReservation booking;
  final VoidCallback onTap;
  final bool isNextUp;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(booking.status);
    final amount = booking.totalAmountPaise / 100;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isNextUp ? _accent : _border),
            boxShadow: [
              BoxShadow(
                color: (isNextUp ? _accent : Colors.black)
                    .withValues(alpha: isNextUp ? 0.08 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.startTime,
                    style: const TextStyle(
                        color: _text,
                        fontSize: 16,
                        fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _durationLabel(
                        _durationMins(booking.startTime, booking.endTime)),
                    style: const TextStyle(
                        color: _muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Container(height: 36, width: 1, color: _border),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.displayName,
                      style: const TextStyle(
                          color: _text,
                          fontSize: 15,
                          fontWeight: FontWeight.w800),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (booking.unitName != null) ...[
                          Text(
                            booking.unitName!,
                            style: const TextStyle(
                                color: _muted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                        ],
                        _StatusBadge(
                            label: booking.isPaid ? 'PAID' : 'UNPAID',
                            color: booking.isPaid
                                ? _accent
                                : const Color(0xFFD97706)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: _text,
                        fontSize: 16,
                        fontWeight: FontWeight.w900),
                  ),
                  if (booking.displayPhone.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _QuickAction(
                            Icons.phone_rounded,
                            () => launchUrl(
                                Uri.parse('tel:${booking.displayPhone}'))),
                        const SizedBox(width: 8),
                        _QuickAction(
                            Icons.chat_bubble_rounded,
                            () => launchUrl(Uri.parse(
                                'https://wa.me/${booking.displayPhone.replaceAll(RegExp(r'[^0-9]'), '')}'))),
                      ],
                    ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: _bg,
            shape: BoxShape.circle,
            border: Border.all(color: _border)),
        child: Icon(icon, color: _accent, size: 14),
      ),
    );
  }
}

// ─── Filter Bar ──────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  const _FilterBar(
      {required this.selected, required this.onSelect, required this.counts});
  final String selected;
  final ValueChanged<String> onSelect;
  final Map<String, int> counts;

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'Confirmed', 'Checked In', 'Cancelled'];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final f = filters[i];
          final count = counts[f] ?? 0;
          final sel = f == selected;
          return ChoiceChip(
            selected: sel,
            onSelected: (_) => onSelect(f),
            label: Text('$f ($count)'),
            backgroundColor: _surface,
            selectedColor: _accent.withValues(alpha: .1),
            side: BorderSide(color: sel ? _accent : _border),
            labelStyle: TextStyle(
              color: sel ? _accent : _muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          );
        },
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
    return SizedBox(
      height: 34,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: units.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final String id;
          final String label;
          if (i == 0) {
            id = 'All';
            label = 'All Units';
          } else {
            final u = units[i - 1];
            id = u.id;
            label = u.name;
          }
          final sel = id == selectedId;
          return GestureDetector(
            onTap: () => onSelect(id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: sel ? _accent : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: sel ? _accent : _border),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: sel ? Colors.white : _muted,
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
  const BookingDetailSheet(
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
          SnackBar(content: Text(m), backgroundColor: err ? Colors.red : _bg));

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
    final result = await showModalBottomSheet<_PaymentResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (_) => _CheckoutSheet(booking: _booking),
    );

    if (result == null) return;

    final repo = ref.read(hostArenaBookingRepositoryProvider);

    setState(() => _loading = true);
    try {
      // 1. Record payment with specific amount and mode
      await repo.markBookingPaid(
        _booking.id,
        paymentMode: result.mode,
        amountPaise: result.amountPaise,
      );

      // 2. Auto-checkin to finalize the occupancy state in one go
      if (_booking.status == 'CONFIRMED') {
        await repo.checkinByOwner(_booking.id);
      }

      // 3. Refresh and update local UI
      final updated = await repo.listArenaBookings(_booking.arenaId,
          date: _fmtDate(_booking.bookingDate!));
      if (mounted) {
        setState(() {
          _booking = updated.firstWhere((b) => b.id == _booking.id);
          _loading = false;
        });
        _snack('Booking settled via ${result.mode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        _snack('Error: $e', err: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
      decoration: const BoxDecoration(
        color: Color(0xFFF2F4F7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                  color: const Color(0xFFD0D5DD),
                  borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 24),

          // PREMIUM TICKET CARD (Capturable as Image)
          RepaintBoundary(
            key: _boundaryKey,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
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
                              color: _accent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.bolt_rounded,
                                color: Colors.white, size: 14),
                          ),
                          const SizedBox(width: 10),
                          const Text('SWING ARENA',
                              style: TextStyle(
                                  color: Color(0xFF101828),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F4F7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFEAECF0)),
                        ),
                        child: const Text('OFFICIAL PASS',
                            style: TextStyle(
                                color: Color(0xFF667085),
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1, color: Color(0xFFF2F4F7)),
                  const SizedBox(height: 24),

                  const Text('CUSTOMER',
                      style: TextStyle(
                          color: Color(0xFF98A2B3),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 6),
                  Text(_booking.displayName.toUpperCase(),
                      style: const TextStyle(
                          color: Color(0xFF101828),
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5)),

                  const SizedBox(height: 32),

                  // TIME PATH
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_booking.startTime,
                          style: const TextStyle(
                              color: Color(0xFF101828),
                              fontSize: 16,
                              fontWeight: FontWeight.w800)),
                      Text(duration,
                          style: const TextStyle(
                              color: Color(0xFF101828),
                              fontSize: 13,
                              fontWeight: FontWeight.w900)),
                      Text(_booking.endTime,
                          style: const TextStyle(
                              color: Color(0xFF101828),
                              fontSize: 16,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const CircleAvatar(
                          radius: 3, backgroundColor: Color(0xFF101828)),
                      Expanded(
                          child: Container(
                              height: 1.5, color: const Color(0xFF101828))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.sports_cricket_rounded,
                            size: 20, color: _accent),
                      ),
                      Expanded(
                          child: Container(
                              height: 1.5, color: const Color(0xFFEAECF0))),
                      const CircleAvatar(
                          radius: 3,
                          backgroundColor: Color(0xFFEAECF0),
                          child: CircleAvatar(
                              radius: 2, backgroundColor: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ARENA',
                                style: TextStyle(
                                    color: Color(0xFF98A2B3),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700)),
                            Text(widget.arenaName.toUpperCase(),
                                style: const TextStyle(
                                    color: Color(0xFF101828),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('UNIT/COURT',
                              style: TextStyle(
                                  color: Color(0xFF98A2B3),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700)),
                          Text(_booking.unitName?.toUpperCase() ?? 'GENERAL',
                              style: const TextStyle(
                                  color: Color(0xFF101828),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  const Divider(height: 1, color: Color(0xFFF2F4F7)),
                  const SizedBox(height: 24),

                  const Text('BOOKING REFERENCE',
                      style: TextStyle(
                          color: Color(0xFF98A2B3),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 6),
                  Text(shortId,
                      style: const TextStyle(
                          color: Color(0xFF101828),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0)),

                  const SizedBox(height: 32),

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

          const SizedBox(height: 24),

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
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionTile(
                    onTap: _sendWhatsApp,
                    icon: Icons.chat_bubble_rounded,
                    label: 'WhatsApp',
                    iconColor: const Color(0xFF25D366),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionTile(
                    onTap: _sharePassImage,
                    icon: Icons.badge_rounded,
                    label: 'Pass',
                    iconColor: _accent,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 24),

          if (_loading)
            const CircularProgressIndicator(color: _accent)
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
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFEE2E2)),
                        ),
                        child: Text(
                            'BALANCE DUE: ₹${(remainingPaise / 100).toStringAsFixed(0)}',
                            style: const TextStyle(
                                color: Color(0xFFDC2626),
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                letterSpacing: 0.5)),
                      ),
                    ),
                  ArenaPrimaryButton(
                      label: 'Record Payment & Checkout',
                      onPressed: _recordPayment),
                ],
              )
            else if (_booking.isPaid)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _accent.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, color: _accent, size: 20),
                    const SizedBox(width: 10),
                    const Text('BOOKING SETTLED',
                        style: TextStyle(
                            color: _accent,
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
    final total = widget.booking.totalAmountPaise / 100;
    final advance = widget.booking.advancePaise / 100;
    final discount = (double.tryParse(_discountCtrl.text) ?? 0);

    return Container(
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
                      color: _border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 24),
          const Text('Checkout',
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w900, color: _text)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _border)),
            child: Column(
              children: [
                _CheckoutRow('Booking Total', '₹${total.toStringAsFixed(0)}'),
                if (advance > 0) ...[
                  const SizedBox(height: 12),
                  _CheckoutRow(
                      'Advance Paid', '- ₹${advance.toStringAsFixed(0)}',
                      color: _accent),
                ],
                const Divider(height: 32),
                Row(
                  children: [
                    const Text('Discount (₹)',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _muted)),
                    const Spacer(),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: _discountCtrl,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        onChanged: (_) => _updateCalculations(),
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 15),
                        decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: '0'),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                _CheckoutRow('Net Payable',
                    '₹${(_remainingPaise / 100 - discount).toStringAsFixed(0)}',
                    isTotal: true),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('AMOUNT TO COLLECT',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: _muted,
                  letterSpacing: 1.0)),
          const SizedBox(height: 12),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.w900, color: _text),
            decoration: InputDecoration(
              prefixText: '₹ ',
              prefixStyle: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w900, color: _muted),
              filled: true,
              fillColor: _bg,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 32),
          const Text('PAYMENT MODE',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: _muted,
                  letterSpacing: 1.0)),
          const SizedBox(height: 16),
          Row(
            children: [
              _ModeTile(
                  icon: Icons.payments_rounded,
                  label: 'CASH',
                  color: Colors.blue,
                  onTap: () => _done('CASH')),
              const SizedBox(width: 12),
              _ModeTile(
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'UPI',
                  color: const Color(0xFF6366F1),
                  onTap: () => _done('UPI')),
              const SizedBox(width: 12),
              _ModeTile(
                  icon: Icons.account_balance_rounded,
                  label: 'ONLINE',
                  color: _accent,
                  onTap: () => _done('ONLINE')),
            ],
          ),
        ],
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
    return Row(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: isTotal ? 15 : 13,
                fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
                color: isTotal ? _text : _muted)),
        const Spacer(),
        Text(value,
            style: TextStyle(
                fontSize: isTotal ? 20 : 15,
                fontWeight: FontWeight.w900,
                color: color ?? _text)),
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
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: .1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: _text,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: iconColor ?? const Color(0xFF101828)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF101828))),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFF98A2B3),
                fontSize: 9,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(value.toUpperCase(),
            style: TextStyle(
                color: color ?? const Color(0xFF101828),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: _muted),
        const SizedBox(width: 12),
        Text(label,
            style: const TextStyle(
                color: _muted, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: _text,
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
      'CONFIRMED' => arenaGreen,
      'PENDING_PAYMENT' => Colors.orange,
      'CANCELLED' => Colors.red,
      'CHECKED_IN' => Colors.blue,
      _ => _muted,
    };

String _moneyShort(int p) {
  final r = p / 100;
  if (r >= 1000) return '₹${(r / 1000).toStringAsFixed(1)}K';
  return '₹${r.toStringAsFixed(0)}';
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
    return const Center(
        child: Text('No arenas found', style: TextStyle(color: _muted)));
  }
}

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings({required this.onAdd, this.isFiltered = false});
  final VoidCallback onAdd;
  final bool isFiltered;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: _surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: _border)),
              child: Icon(Icons.event_note_rounded,
                  size: 36, color: _muted.withValues(alpha: .5)),
            ),
            const SizedBox(height: 16),
            Text(
              isFiltered ? 'No matching bookings' : 'No bookings yet',
              style: const TextStyle(
                  color: _text, fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              isFiltered
                  ? 'Try changing the filter above'
                  : 'Tap + to add your first booking',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: _muted, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            if (!isFiltered) ...[
              const SizedBox(height: 20),
              ArenaPrimaryButton(label: 'Add New Booking', onPressed: onAdd),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text(message, style: const TextStyle(color: Colors.red)));
  }
}

// ─── Add Booking Sheet ────────────────────────────────────────────────────────

class _SlotOption {
  const _SlotOption(
      {required this.durationMins, required this.label, required this.paise});
  final int durationMins;
  final String label;
  final int paise;
}

List<_SlotOption> _buildSlotOptions(ArenaUnitOption unit,
    {int? pricePerHourOverride}) {
  final pricePerHour =
      (pricePerHourOverride != null && pricePerHourOverride > 0)
          ? pricePerHourOverride
          : unit.pricePerHourPaise;
  final minMins = unit.minSlotMins > 0 ? unit.minSlotMins : 60;
  final increment = minMins >= 60
      ? minMins
      : (unit.slotIncrementMins > 0 ? unit.slotIncrementMins : 60);
  final isGround =
      unit.unitType == 'FULL_GROUND' || unit.unitType == 'HALF_GROUND';

  // Ground: show only explicitly-priced bundles when any are configured
  if (isGround && (pricePerHourOverride == null || pricePerHourOverride == 0)) {
    final bundles = <_SlotOption>[];
    if (unit.price4HrPaise != null)
      bundles.add(_SlotOption(
          durationMins: 240, label: '4 hrs', paise: unit.price4HrPaise!));
    if (unit.price8HrPaise != null)
      bundles.add(_SlotOption(
          durationMins: 480, label: '8 hrs', paise: unit.price8HrPaise!));
    if (unit.priceFullDayPaise != null)
      bundles.add(_SlotOption(
          durationMins: 720,
          label: 'Full day',
          paise: unit.priceFullDayPaise!));
    if (bundles.isNotEmpty) return bundles;
  }
  final configuredMax = unit.maxSlotMins > minMins ? unit.maxSlotMins : 0;
  final autoMax = (minMins * 3).clamp(240, 720);
  final maxMins =
      configuredMax > 0 ? configuredMax : (isGround ? 720 : autoMax);
  final opts = <_SlotOption>[];
  for (var m = minMins; m <= maxMins; m += increment) {
    final int paise;
    // Only use fixed bundle prices when no variant override is active
    if (pricePerHourOverride == null || pricePerHourOverride == 0) {
      if (m == 240 && unit.price4HrPaise != null) {
        opts.add(_SlotOption(
            durationMins: m,
            label: _durationLabel(m),
            paise: unit.price4HrPaise!));
        continue;
      }
      if (m == 480 && unit.price8HrPaise != null) {
        opts.add(_SlotOption(
            durationMins: m,
            label: _durationLabel(m),
            paise: unit.price8HrPaise!));
        continue;
      }
      if (m >= 720 && unit.priceFullDayPaise != null) {
        opts.add(_SlotOption(
            durationMins: m,
            label: 'Full day',
            paise: unit.priceFullDayPaise!));
        continue;
      }
    }
    paise = ((pricePerHour * m) / 60).round();
    final label = (m >= 720 &&
            unit.priceFullDayPaise != null &&
            (pricePerHourOverride == null || pricePerHourOverride == 0))
        ? 'Full day'
        : _durationLabel(m);
    opts.add(_SlotOption(durationMins: m, label: label, paise: paise));
  }
  return opts.isEmpty
      ? [
          _SlotOption(
              durationMins: minMins,
              label: _durationLabel(minMins),
              paise: ((pricePerHour * minMins) / 60).round())
        ]
      : opts;
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
  const AddBookingSheet(
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
  int _variantInstanceIdx =
      0; // which instance (0-based) within the selected variant
  final List<String> _selectedSlots = [];
  int _selectedDurationIdx = -1;
  String _paymentMode = 'CASH';
  bool _loading = false;
  bool _totalEdited = false;
  List<String> _allDaySlots = [];
  List<ArenaReservation> _existingBookings = [];
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

  List<String> get _stepLabels => _isNetsFlow
      ? const ['Add-ons', 'Date & Time', 'Confirm']
      : const ['Court', 'Slot', 'Confirm'];

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
    final opts = _buildSlotOptions(unit);
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
    if (unit == null || _netVariantType == null) return 0;
    try {
      return unit.netVariants
              .firstWhere((v) => v.type == _netVariantType)
              .pricePaise ??
          0;
    } catch (_) {
      return 0;
    }
  }

  // Flat list of all variant instances expanded by count.
  // e.g. Turf(count=2) + Cement(count=1) → [Turf/0, Turf/1, Cement/0]
  List<({String type, String label, int instance, int count, int? pricePaise})>
      get _variantTabs {
    final unit = _unit;
    if (unit == null || !unit.hasVariants) return [];
    return [
      for (final v in unit.netVariants)
        for (var i = 0; i < v.count; i++)
          (
            type: v.type,
            label: v.count > 1 ? '${v.label} ${i + 1}' : v.label,
            instance: i,
            count: v.count,
            pricePaise: v.pricePaise
          ),
    ];
  }

  // A time slot is busy for this specific variant instance if the number of
  // existing bookings of that variant type at that time > instanceIndex.
  bool _isTabSlotBusy(String time, String variantType, int instanceIndex) {
    final tMins = _toMins(time);
    final durMins = _currentDurationMins;
    int count = 0;
    for (final b in _existingBookings) {
      if (b.status == 'CANCELLED') continue;
      if (_toMins(b.startTime) >= tMins + durMins ||
          _toMins(b.endTime) <= tMins) continue;
      // Count bookings that are for this variant type (null = legacy, blocks all)
      if (b.netVariantType == null || b.netVariantType == variantType) count++;
    }
    return count > instanceIndex;
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
      return ((pricePerHour * _currentDurationMins) / 60).round() + _addonPaise;
    }
    final opts =
        _buildSlotOptions(unit, pricePerHourOverride: _variantPricePerHour);
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

  int get _advancePaise => ((double.tryParse(_advanceCtrl.text) ?? 0) * 100)
      .round()
      .clamp(0, _totalPaise);
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

  bool get _showGuestNameInput => _lookupDone || _hasSelectedGuest;

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
      _advanceCtrl
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
        _stepForward ? const Offset(1.0, 0) : const Offset(-1.0, 0);
    final exitOffset =
        _stepForward ? const Offset(-1.0, 0) : const Offset(1.0, 0);
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
    final increment = unit.slotIncrementMins > 0 ? unit.slotIncrementMins : 60;
    final durMins = _currentDurationMins;

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
      final tomorrow = DateTime.now().add(const Duration(days: 1));
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
    setState(() => _loadingAvail = true);
    try {
      final repo = ref.read(hostArenaBookingRepositoryProvider);
      final date = _fmtDate(_selectedDate);

      final relatedIds = <String>{_unitId!};
      final parentId = _unit?.parentUnitId;
      if (parentId != null) relatedIds.add(parentId);
      for (final u in widget.arena.units) {
        if (u.parentUnitId == _unitId) relatedIds.add(u.id);
      }

      debugPrint(
          '[booking] _loadAvailability unitId=$_unitId date=$date relatedIds=$relatedIds isFullDay=$_isFullDay');
      final results = await Future.wait(
        relatedIds.map((id) =>
            repo.listArenaBookings(widget.arena.id, date: date, unitId: id)),
      );
      final merged = results.expand((b) => b).toList();
      debugPrint(
          '[booking] _loadAvailability fetched ${merged.length} bookings: ${merged.map((b) => '${b.unitId} ${b.startTime}-${b.endTime} ${b.status}').toList()}');
      if (mounted) setState(() => _existingBookings = merged);
    } catch (e) {
      debugPrint('[booking] _loadAvailability ERROR: $e');
      if (mounted) setState(() => _existingBookings = []);
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
    } catch (e) {
      debugPrint('[booking] _loadBusyDates ERROR: $e');
    } finally {
      if (mounted) setState(() => _loadingBusyMap = false);
    }
  }

  // A start time is busy if any part of [time, time + selectedDuration) overlaps an existing booking.
  bool _isBusy(String time) {
    final tMins = _toMins(time);
    final durMins = _currentDurationMins;
    return _existingBookings.any((b) {
      if (b.status == 'CANCELLED') return false;
      return _toMins(b.startTime) < tMins + durMins &&
          _toMins(b.endTime) > tMins;
    });
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
    debugPrint(
        '[booking] _save isFullDay=$_isFullDay loadingAvail=$_loadingAvail fullDayBusy=$_fullDayBusy existingBookings=${_existingBookings.length} startTime=$_startTime endTime=$_endTime totalPaise=$_totalPaise loading=$_loading advanceOk=$_advanceOk minAdv=$_minAdvancePaise adv=$_advancePaise name="${_nameCtrl.text.trim()}" phone="${_phoneCtrl.text.trim()}"');
    final guestName =
        _customerLookup?.name ?? _foundGuest?.name ?? _nameCtrl.text.trim();
    if (guestName.isEmpty || _phoneCtrl.text.trim().isEmpty) {
      debugPrint('[booking] BLOCKED: name/phone');
      _snack('Required fields missing', err: true);
      return;
    }
    if (!_isMultiDay && !_isFullDay && _selectedSlots.isEmpty) {
      debugPrint('[booking] BLOCKED: no slot');
      _snack('Please select a start time', err: true);
      return;
    }
    if (_isFullDay && (_loadingAvail || _fullDayBusy)) {
      debugPrint('[booking] BLOCKED: fullDay busy');
      _snack('This day is already booked', err: true);
      return;
    }
    if (!_advanceOk) {
      debugPrint(
          '[booking] BLOCKED: advance min=$_minAdvancePaise actual=$_advancePaise');
      _snack(
          'Min advance ₹${(_minAdvancePaise / 100).toStringAsFixed(0)} required',
          err: true);
      return;
    }
    if (_loading) {
      debugPrint('[booking] BLOCKED: already loading');
      return;
    }
    setState(() => _loading = true);
    try {
      final payload = {
        'arenaId': widget.arena.id,
        'unitId': _unitId,
        'date': _fmtDate(_selectedDate),
        'startTime': _startTime,
        'endTime': _endTime,
        'guestName':
            _customerLookup?.name ?? _foundGuest?.name ?? _nameCtrl.text.trim(),
        'guestPhone': _phoneCtrl.text.trim(),
        'paymentMode': _paymentMode,
        'amountPaise': _totalPaise,
        'advancePaise': _advancePaise,
      };
      debugPrint('[booking] createManualBooking payload=$payload');
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
              backgroundColor: const Color(0xFFD97706),
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
      debugPrint('[booking] createManualBooking SUCCESS');
      if (mounted) Navigator.pop(context);
    } catch (e, st) {
      debugPrint('[booking] createManualBooking ERROR: $e\n$st');
      if (mounted) _snack('$e', err: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String m, {bool err = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(m), backgroundColor: err ? Colors.red : _bg));

  Future<void> _selectStartDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
                primary: _accent, onPrimary: Colors.white, onSurface: _text)),
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
          duration: const Duration(milliseconds: 300),
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
      lastDate: _selectedDate.add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
                primary: _accent, onPrimary: Colors.white, onSurface: _text)),
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
    final unit = _unit;
    if (unit == null) return;
    if (_isMultiDay) {
      final days = _isCustomDates ? _customDates.length : _bulkDays;
      if (unit.bulkDayRatePaise != null && _variantPricePerHour == 0) {
        _totalCtrl.text =
            (unit.bulkDayRatePaise! * days / 100).toStringAsFixed(0);
      } else {
        final opts =
            _buildSlotOptions(unit, pricePerHourOverride: _variantPricePerHour);
        final opt = opts[_selectedDurationIdx.clamp(0, opts.length - 1)];
        _totalCtrl.text = (opt.paise * days / 100).toStringAsFixed(0);
      }
    } else if (_isFullDay) {
      final opts =
          _buildSlotOptions(unit, pricePerHourOverride: _variantPricePerHour);
      final opt = opts[_selectedDurationIdx.clamp(0, opts.length - 1)];
      _totalCtrl.text = (opt.paise / 100).toStringAsFixed(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastStep = _step == _stepLabels.length - 1;

    // Progressive visibility gates
    final showBookingType = _unitId != null;
    final showDates = _unitId != null;
    final showDuration = _unitId != null && !_isMultiDay;
    final showSlotGrid = _unitId != null && !_isMultiDay;
    final showGuestPayment = _isMultiDay
        ? _endDatePicked
        : (_isFullDay || _selectedSlots.isNotEmpty);

    return Container(
      decoration: const BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SizedBox(height: 12),
          Center(
              child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                      color: _border,
                      borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 16),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text('Add Booking',
                style: const TextStyle(
                    color: _text,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5)),
          ),
          const SizedBox(height: 16),

          // Step indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _BookingStepBar(step: _step, labels: _stepLabels),
          ),
          const SizedBox(height: 20),

          // Step content — slides horizontally
          Flexible(
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom +
                    MediaQuery.of(context).padding.bottom +
                    24,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: _stepTransition,
                layoutBuilder: (cur, prev) => ClipRect(
                  child: Stack(
                    alignment: Alignment.topLeft,
                    children: [...prev, if (cur != null) cur],
                  ),
                ),
                child: KeyedSubtree(
                  key: ValueKey(_step),
                  child: _buildStepContent(),
                ),
              ),
            ),
          ),

          // Nav buttons
          Padding(
            padding: EdgeInsets.fromLTRB(
                24, 8, 24, MediaQuery.of(context).padding.bottom + 20),
            child: Row(children: [
              GestureDetector(
                onTap: _prevStep,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _border),
                  ),
                  child: Icon(
                    _step == 0 ? Icons.close_rounded : Icons.arrow_back_rounded,
                    color: _text,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
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
                          label: 'Next',
                          enabled: _canAdvance,
                          onTap: _nextStep,
                          trailing: Icons.arrow_forward_rounded,
                        )),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    if (_isNetsFlow) {
      switch (_step) {
        case 0:
          return _buildNetsSetupStep();
        case 1:
          return _buildNetsDateTimeStep();
        case 2:
          return _buildConfirmStep();
        default:
          return const SizedBox.shrink();
      }
    }
    switch (_step) {
      case 0:
        return _buildCourtStep();
      case 1:
        return _buildSlotStep();
      case 2:
        return _buildConfirmStep();
      default:
        return const SizedBox.shrink();
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
          const SizedBox(width: 12),
          Expanded(
              child: _BizTypeTile(
            icon: Icons.sports_cricket_rounded,
            label: 'Nets',
            sublabel: _netPriceLabel(units),
            selected: true,
            onTap: () {},
          )),
        ]),
        const SizedBox(height: 24),
      ],

      // Net types
      if (unit != null && unit.hasVariants) ...[
        const Text('NET TYPE',
            style: TextStyle(
                color: _muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
        const SizedBox(height: 10),
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
              duration: const Duration(milliseconds: 160),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSel ? _accent : _bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isSel ? _accent : _border, width: isSel ? 2 : 1),
              ),
              child: Row(children: [
                Expanded(
                    child: Row(children: [
                  Text(v.label,
                      style: TextStyle(
                          color: isSel ? Colors.white : _text,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                  if (v.count > 1) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSel
                            ? Colors.white.withValues(alpha: .2)
                            : _border,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('${v.count} nets',
                          style: TextStyle(
                              color: isSel ? Colors.white : _muted,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                  if (v.hasFloodlights) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.wb_incandescent_rounded,
                        size: 13, color: isSel ? Colors.white70 : _muted),
                  ],
                ])),
                if (v.pricePaise != null)
                  Text('₹${(v.pricePaise! / 100).toStringAsFixed(0)}/hr',
                      style: TextStyle(
                          color: isSel ? Colors.white : _accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                const SizedBox(width: 10),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isSel ? Colors.white : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isSel ? Colors.white : _border, width: 2),
                  ),
                  child: isSel
                      ? Icon(Icons.check_rounded, size: 12, color: _accent)
                      : null,
                ),
              ]),
            ),
          );
        }),
        const SizedBox(height: 8),
      ],

      if (addons.isNotEmpty) ...[
        const SizedBox(height: 12),
        const Text('ADD-ONS',
            style: TextStyle(
                color: _muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
        const SizedBox(height: 10),
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
                color: isSel ? _accent.withValues(alpha: .08) : _bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSel ? _accent : _border),
              ),
              child: Row(children: [
                Icon(
                    isSel
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    color: isSel ? _accent : _muted,
                    size: 20),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(a.name,
                        style: const TextStyle(
                            color: _text,
                            fontWeight: FontWeight.w700,
                            fontSize: 13))),
                Text('₹${(a.pricePaise / 100).toStringAsFixed(0)}/${a.unit}',
                    style: const TextStyle(color: _muted, fontSize: 12)),
              ]),
            ),
          );
        }),
      ] else ...[
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border)),
          child: const Row(children: [
            Icon(Icons.arrow_forward_rounded, color: _muted, size: 16),
            SizedBox(width: 10),
            Text('Select date, duration and time on the next step',
                style: TextStyle(
                    color: _muted, fontSize: 13, fontWeight: FontWeight.w500)),
          ]),
        ),
      ],
      const SizedBox(height: 24),
    ]);
  }

  // ── Nets Step 1: Surface chips + count tabs + date + duration + slots ──────
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
        const Text('NET',
            style: TextStyle(
                color: _muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
        const SizedBox(height: 10),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: countTabs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
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
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isSel ? _accent : _bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSel ? _accent : _border),
                  ),
                  child: Center(
                    child: Text(label,
                        style: TextStyle(
                          color: isSel ? Colors.white : _text,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        )),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],

      // Date strip
      const Text('DATE',
          style: TextStyle(
              color: _muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5)),
      const SizedBox(height: 12),
      SizedBox(
        height: 80,
        child: ListView.separated(
          controller: _dateStripCtrl,
          scrollDirection: Axis.horizontal,
          itemCount: stripDates.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
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
                duration: const Duration(milliseconds: 180),
                width: 56,
                decoration: BoxDecoration(
                  color: isSel ? _accent : _bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isSel ? _accent : _border),
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(i == 0 ? 'Today' : DateFormat('EEE').format(d),
                          style: TextStyle(
                              color: isSel ? Colors.white : _muted,
                              fontSize: i == 0 ? 9 : 10,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text('${d.day}',
                          style: TextStyle(
                              color: isSel ? Colors.white : _text,
                              fontSize: 20,
                              fontWeight: FontWeight.w900)),
                      Text(DateFormat('MMM').format(d),
                          style: TextStyle(
                              color: isSel
                                  ? Colors.white.withValues(alpha: .8)
                                  : _muted,
                              fontSize: 9,
                              fontWeight: FontWeight.w600)),
                    ]),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 20),

      // Duration stepper
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border)),
        child: Row(children: [
          const Text('Duration',
              style: TextStyle(
                  color: _text, fontSize: 15, fontWeight: FontWeight.w700)),
          const Spacer(),
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
                  color: dur > min ? _text : _border,
                  borderRadius: BorderRadius.circular(9)),
              child: const Icon(Icons.remove_rounded,
                  color: Colors.white, size: 17),
            ),
          ),
          SizedBox(
            width: 72,
            child: Text(_durationLabel(dur),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: _text, fontSize: 16, fontWeight: FontWeight.w900)),
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
                  color: dur < max ? _text : _border,
                  borderRadius: BorderRadius.circular(9)),
              child:
                  const Icon(Icons.add_rounded, color: Colors.white, size: 17),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 20),

      // Time slot cards
      const Text('START TIME',
          style: TextStyle(
              color: _muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5)),
      const SizedBox(height: 10),

      if (_loadingAvail)
        const Center(
            child: Padding(
          padding: EdgeInsets.symmetric(vertical: 28),
          child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2, color: _accent)),
        ))
      else if (_allDaySlots.isEmpty)
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border)),
          child: const Row(children: [
            Icon(Icons.info_outline_rounded, color: _muted, size: 18),
            SizedBox(width: 10),
            Text('No slots available for this date.',
                style: TextStyle(
                    color: _muted, fontSize: 13, fontWeight: FontWeight.w600)),
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
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: busy ? const Color(0xFFFEF2F2) : (isSel ? _accent : _bg),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: busy
                      ? const Color(0xFFFCA5A5)
                      : (isSel ? _accent : _border),
                  width: isSel ? 2 : 1,
                ),
              ),
              child: Row(children: [
                Expanded(
                    child: Text(_formatTimeRange(time, endTime),
                        style: TextStyle(
                          color: busy
                              ? const Color(0xFFEF4444)
                              : (isSel ? Colors.white : _text),
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ))),
                if (busy)
                  const Text('Booked',
                      style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 11,
                          fontWeight: FontWeight.w600))
                else if (slotPaise > 0)
                  Text('₹${(slotPaise / 100).toStringAsFixed(0)}',
                      style: TextStyle(
                          color: isSel ? Colors.white : _accent,
                          fontWeight: FontWeight.w900,
                          fontSize: 14)),
              ]),
            ),
          );
        })),
      const SizedBox(height: 24),
    ]);
  }

  // ── Step 0: Court + Duration ───────────────────────────────────────────────
  Widget _buildCourtStep() {
    final units = widget.arena.units;
    final hasGrounds = units
        .any((u) => u.unitType == 'FULL_GROUND' || u.unitType == 'HALF_GROUND');
    final hasNets = units
        .any((u) => u.unitType == 'CRICKET_NET' || u.unitType == 'INDOOR_NET');
    final selectedIsGround =
        _unit?.unitType == 'FULL_GROUND' || _unit?.unitType == 'HALF_GROUND';
    final selectedIsNet =
        _unit?.unitType == 'CRICKET_NET' || _unit?.unitType == 'INDOOR_NET';
    final netUnits = units
        .where((u) => u.unitType == 'CRICKET_NET' || u.unitType == 'INDOOR_NET')
        .toList();
    final netTypes = <String>{
      for (final u in netUnits)
        if (u.netType != null && u.netType!.isNotEmpty) u.netType!
    }.toList();
    final unit = _unit;
    final bulkAvailable = unit != null &&
        (unit.minBulkDays ?? 0) > 0 &&
        unit.bulkDayRatePaise != null;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Court type
      if (hasGrounds && hasNets) ...[
        Row(children: [
          Expanded(
              child: _BizTypeTile(
            icon: Icons.grass_rounded,
            label: 'Full Ground',
            sublabel: _groundPriceLabel(units),
            selected: selectedIsGround,
            onTap: () {
              final g = units.firstWhere((u) =>
                  u.unitType == 'FULL_GROUND' || u.unitType == 'HALF_GROUND');
              setState(() {
                _unitId = g.id;
                _selectedAddons.clear();
                _selectedSlots.clear();
                _initDuration();
                _rebuildTimes();
              });
              _loadAvailability();
            },
          )),
          const SizedBox(width: 12),
          Expanded(
              child: _BizTypeTile(
            icon: Icons.sports_cricket_rounded,
            label: 'Nets',
            sublabel: _netPriceLabel(units),
            selected: selectedIsNet,
            onTap: () {
              final n = units.firstWhere((u) =>
                  u.unitType == 'CRICKET_NET' || u.unitType == 'INDOOR_NET');
              setState(() {
                _unitId = n.id;
                _selectedAddons.clear();
                _selectedSlots.clear();
                _initDuration();
                _rebuildTimes();
              });
              _loadAvailability();
            },
          )),
        ]),
        if (selectedIsNet && netTypes.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: netTypes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final type = netTypes[i];
                  final isSel = _unit?.netType == type;
                  final count = netUnits.where((u) => u.netType == type).length;
                  return GestureDetector(
                    onTap: () {
                      final m = netUnits.firstWhere((u) => u.netType == type);
                      setState(() {
                        _unitId = m.id;
                        _selectedAddons.clear();
                        _initDuration();
                        _rebuildTimes();
                      });
                      _loadAvailability();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                          color: isSel ? _accent : _bg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSel ? _accent : _border)),
                      child: Text(
                          '${type[0].toUpperCase()}${type.substring(1).toLowerCase()} ($count)',
                          style: TextStyle(
                              color: isSel ? Colors.white : _text,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    ),
                  );
                },
              )),
        ],
        if (selectedIsNet && netTypes.length <= 1 && netUnits.length > 1) ...[
          const SizedBox(height: 12),
          _SegmentPicker(
              options: netUnits.map((u) => (u.id, u.name)).toList(),
              selected: _unitId ?? '',
              onSelect: (id) {
                setState(() {
                  _unitId = id;
                  _netVariantType = null;
                  _selectedAddons.clear();
                  _initDuration();
                  _rebuildTimes();
                });
                _loadAvailability();
              }),
        ],
      ] else if (units.length > 1) ...[
        _SegmentPicker(
            options: units.map((u) => (u.id, u.name)).toList(),
            selected: _unitId ?? '',
            onSelect: (id) {
              setState(() {
                _unitId = id;
                _netVariantType = null;
                _selectedAddons.clear();
                _initDuration();
                _rebuildTimes();
              });
              _loadAvailability();
            }),
      ] else if (units.length == 1) ...[
        Text(units.first.name,
            style: const TextStyle(
                color: _text, fontSize: 16, fontWeight: FontWeight.w700)),
      ],

      // Net variant picker — shown when selected unit has netVariants
      if (unit != null && unit.hasVariants) ...[
        const SizedBox(height: 16),
        const Text('SURFACE TYPE',
            style: TextStyle(
                color: _muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: [
            for (final v in unit.netVariants)
              GestureDetector(
                onTap: () => setState(() => _netVariantType = v.type),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _netVariantType == v.type ? _accent : _surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _netVariantType == v.type ? _accent : _border),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(v.label,
                          style: TextStyle(
                              color: _netVariantType == v.type
                                  ? Colors.white
                                  : _text,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                      if (v.pricePaise != null)
                        Text('₹${(v.pricePaise! / 100).toStringAsFixed(0)}/hr',
                            style: TextStyle(
                                color: _netVariantType == v.type
                                    ? Colors.white70
                                    : _muted,
                                fontSize: 11)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],

      // Duration — revealed after court selected, hidden when multi-day active
      AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: (unit == null || _isMultiDay)
            ? const SizedBox(width: double.infinity)
            : Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('DURATION',
                          style: TextStyle(
                              color: _muted,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 12),
                      Builder(builder: (ctx) {
                        final opts = _buildSlotOptions(unit,
                            pricePerHourOverride: _variantPricePerHour);
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(opts.length, (i) {
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
                                    if (opt.durationMins >= 720 &&
                                        !_totalEdited)
                                      _totalCtrl.text =
                                          (opt.paise / 100).toStringAsFixed(0);
                                  });
                                  _loadAvailability();
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 160),
                                  margin: EdgeInsets.only(
                                      right: i < opts.length - 1 ? 10 : 0),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 22, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: sel ? _accent : _bg,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                        color: sel ? _accent : _border,
                                        width: sel ? 2 : 1),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(opt.label,
                                          style: TextStyle(
                                              color: sel ? Colors.white : _text,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900)),
                                      const SizedBox(height: 4),
                                      Text(
                                          '₹${(opt.paise / 100).toStringAsFixed(0)}',
                                          style: TextStyle(
                                              color:
                                                  sel ? Colors.white70 : _muted,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      }),
                    ]),
              ),
      ),

      // Multi-Day toggle — lives outside the collapsed block so it stays visible
      if (unit != null && bulkAvailable) ...[
        const SizedBox(height: 20),
        Row(children: [
          const Expanded(child: Divider(color: _border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('or book multiple days',
                style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3)),
          ),
          const Expanded(child: Divider(color: _border)),
        ]),
        const SizedBox(height: 12),
        GestureDetector(
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
                color: _isMultiDay ? _accent.withValues(alpha: .08) : _bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _isMultiDay ? _accent : _border)),
            child: Row(children: [
              Icon(Icons.date_range_rounded,
                  color: _isMultiDay ? _accent : _muted, size: 18),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(
                      'Multi-Day · ₹${unit.bulkDayRatePaise! ~/ 100}/day for ${unit.minBulkDays}+ days',
                      style: TextStyle(
                          color: _isMultiDay ? _accent : _text,
                          fontWeight: FontWeight.w700,
                          fontSize: 13))),
              Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                      color: _isMultiDay ? _accent : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: _isMultiDay ? _accent : _border, width: 2)),
                  child: _isMultiDay
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 12)
                      : null),
            ]),
          ),
        ),
      ],

      // Add-ons
      if (unit != null && _unitAddons.isNotEmpty) ...[
        const SizedBox(height: 20),
        const Text('ADD-ONS',
            style: TextStyle(
                color: _muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
        const SizedBox(height: 10),
        ..._unitAddons.map((a) {
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
                  color: isSel ? _accent.withValues(alpha: .08) : _bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSel ? _accent : _border)),
              child: Row(children: [
                Icon(
                    isSel
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    color: isSel ? _accent : _muted,
                    size: 20),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(a.name,
                        style: const TextStyle(
                            color: _text,
                            fontWeight: FontWeight.w700,
                            fontSize: 13))),
                Text('₹${(a.pricePaise / 100).toStringAsFixed(0)}/${a.unit}',
                    style: const TextStyle(color: _muted, fontSize: 12)),
              ]),
            ),
          );
        }),
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
        const Text('Pick dates',
            style: TextStyle(
                color: _text,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5)),
        const SizedBox(height: 12),
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
          const SizedBox(width: 8),
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
        const SizedBox(height: 20),
        if (!_isCustomDates) ...[
          Row(children: [
            Expanded(
                child: _BizDateTile(
                    label: 'START DATE',
                    date: _selectedDate,
                    onTap: _selectStartDate)),
            const SizedBox(width: 12),
            Expanded(
                child: _BizDateTile(
                    label: 'END DATE',
                    date: _endDate,
                    onTap: _selectEndDate,
                    highlight: !_endDatePicked)),
          ]),
          if (_unit != null && _endDatePicked) ...[
            const SizedBox(height: 12),
            _BizBulkRateInfo(unit: _unit!, days: _bulkDays),
          ],
        ] else ...[
          Row(children: [
            Expanded(
                child: Text(
                    'Tap dates to select · ${_customDates.length} selected',
                    style: const TextStyle(
                        color: _muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600))),
            if (_loadingBusyMap)
              const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: _accent)),
          ]),
          const SizedBox(height: 12),
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
                    duration: const Duration(milliseconds: 150),
                    width: 52,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isBusy
                          ? const Color(0xFFFEF2F2)
                          : (isSel ? _accent : _bg),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isBusy
                              ? const Color(0xFFFCA5A5)
                              : (isSel
                                  ? _accent
                                  : (isToday
                                      ? _accent.withValues(alpha: .5)
                                      : _border))),
                    ),
                    child: Stack(children: [
                      Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            Text(DateFormat('EEE').format(d),
                                style: TextStyle(
                                    color: isBusy
                                        ? const Color(0xFFEF4444)
                                        : (isSel ? Colors.white : _muted),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text('${d.day}',
                                style: TextStyle(
                                    color: isBusy
                                        ? const Color(0xFFEF4444)
                                        : (isSel ? Colors.white : _text),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900)),
                            Text(DateFormat('MMM').format(d),
                                style: TextStyle(
                                    color: isBusy
                                        ? const Color(0xFFEF4444)
                                            .withValues(alpha: .7)
                                        : (isSel
                                            ? Colors.white.withValues(alpha: .8)
                                            : _muted),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600)),
                          ])),
                      if (isBusy)
                        Positioned(
                            top: 4,
                            right: 4,
                            child: Icon(Icons.block_rounded,
                                size: 10, color: const Color(0xFFEF4444))),
                    ]),
                  ),
                );
              }).toList()),
          if (_customDates.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                  color: _accent.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _accent.withValues(alpha: .3))),
              child: Row(children: [
                Icon(Icons.calculate_outlined, color: _accent, size: 18),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(
                        '${_customDates.length} days × ₹${(_totalPaise ~/ _customDates.length / 100).toStringAsFixed(0)}/day',
                        style: TextStyle(
                            color: _accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 13))),
                Text('₹${(_totalPaise / 100).toStringAsFixed(0)}',
                    style: TextStyle(
                        color: _accent,
                        fontWeight: FontWeight.w900,
                        fontSize: 15)),
              ]),
            ),
          ],
        ],
        const SizedBox(height: 24),
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
          const Text('Pick a date',
              style: TextStyle(
                  color: _text,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5)),
          const SizedBox(height: 2),
          Text('${_durationLabel(_currentDurationMins)} · ${_unit?.name ?? ''}',
              style: const TextStyle(
                  color: _muted, fontSize: 13, fontWeight: FontWeight.w500)),
        ])),
        GestureDetector(
          onTap: _selectStartDate,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border)),
            child: Icon(Icons.calendar_month_rounded, color: _muted, size: 20),
          ),
        ),
      ]),
      const SizedBox(height: 16),

      // Horizontal date strip
      SizedBox(
        height: 70,
        child: ListView.separated(
          controller: _dateStripCtrl,
          scrollDirection: Axis.horizontal,
          itemCount: stripDates.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
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
                duration: const Duration(milliseconds: 180),
                width: 52,
                decoration: BoxDecoration(
                  color: isSel ? _accent : _bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isSel ? _accent : _border),
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isToday ? 'Today' : DateFormat('EEE').format(d),
                        style: TextStyle(
                            color: isSel ? Colors.white : _muted,
                            fontSize: isToday ? 9 : 11,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${d.day}',
                        style: TextStyle(
                            color: isSel ? Colors.white : _text,
                            fontSize: 18,
                            fontWeight: FontWeight.w900),
                      ),
                      Text(
                        DateFormat('MMM').format(d),
                        style: TextStyle(
                            color: isSel
                                ? Colors.white.withValues(alpha: .8)
                                : _muted,
                            fontSize: 10,
                            fontWeight: FontWeight.w600),
                      ),
                    ]),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 20),

      // Slot or full-day status
      if (_isFullDay) ...[
        if (_loadingAvail)
          const Center(
              child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _accent))))
        else if (_fullDayBusy)
          Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFCA5A5))),
              child: Row(children: [
                const Icon(Icons.block_rounded,
                    color: Color(0xFFEF4444), size: 18),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(
                        'Already booked · $_fullDayOpen – $_fullDayClose',
                        style: const TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 13,
                            fontWeight: FontWeight.w700))),
              ]))
        else
          Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: _accent.withValues(alpha: .06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _accent.withValues(alpha: .3))),
              child: Row(children: [
                Icon(Icons.check_circle_rounded, color: _accent, size: 18),
                const SizedBox(width: 12),
                Expanded(
                    child: Text('Available · $_fullDayOpen to $_fullDayClose',
                        style: TextStyle(
                            color: _accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w700))),
              ])),
      ] else ...[
        const Text('SELECT START TIME',
            style: TextStyle(
                color: _muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
        const SizedBox(height: 12),
        if (_loadingAvail)
          const Center(
              child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _accent))))
        else if (_allDaySlots.isEmpty)
          Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border)),
              child: Row(children: [
                Icon(Icons.info_outline_rounded, color: _muted, size: 18),
                const SizedBox(width: 12),
                const Text('No slots available for this date.',
                    style: TextStyle(
                        color: _muted,
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
          ),
        if (_selectedSlots.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
                color: _accent.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _accent.withValues(alpha: .25))),
            child: Row(children: [
              Icon(Icons.schedule_rounded, color: _accent, size: 18),
              const SizedBox(width: 12),
              Text('$_startTime → $_endTime',
                  style: TextStyle(
                      color: _accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              Text('· ${_durationLabel(_currentDurationMins)}',
                  style: const TextStyle(
                      color: _muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
        ],
      ],
      const SizedBox(height: 24),
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
        style: const TextStyle(
            color: _text, fontSize: 16, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          hintText: 'Guest mobile number',
          prefixIcon:
              const Icon(Icons.phone_android_rounded, size: 18, color: _accent),
          suffixIcon: _searchingUser
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _accent)))
              : (_customerLookup?.exists == true || _foundGuest != null)
                  ? const Icon(Icons.check_circle_rounded,
                      color: Colors.green, size: 20)
                  : (_lookupDone &&
                          _normalisedLookupPhone(_phoneCtrl.text).length == 10)
                      ? const Icon(Icons.person_add_rounded,
                          color: _muted, size: 20)
                      : null,
          filled: true,
          fillColor: _bg,
          counterText: '',
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                  color: _hasSelectedGuest
                      ? Colors.green.withValues(alpha: .4)
                      : _border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                  color: _hasSelectedGuest ? Colors.green : _accent,
                  width: 1.8)),
        ),
      ),
      const SizedBox(height: 10),
      // Found guest card
      AnimatedSize(
        duration: const Duration(milliseconds: 240),
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
                                style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16)))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(_customerLookup?.name ?? _foundGuest!.name,
                              style: const TextStyle(
                                  color: _text,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14)),
                          const SizedBox(height: 2),
                          Row(children: [
                            Text(
                                _customerLookup?.exists == true
                                    ? 'Swing user selected'
                                    : '${_foundGuest!.totalBookings} booking${_foundGuest!.totalBookings != 1 ? "s" : ""}',
                                style: const TextStyle(
                                    color: _muted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                            if ((_foundGuest?.balanceDuePaise ?? 0) > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(6)),
                                  child: Text(
                                      '₹${(_foundGuest!.balanceDuePaise / 100).toStringAsFixed(0)} due',
                                      style: const TextStyle(
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
                                color: _bg,
                                borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.close_rounded,
                                color: _muted, size: 15))),
                  ]),
                ))
            : const SizedBox(width: double.infinity, height: 0),
      ),
      // New customer name
      AnimatedSize(
        duration: const Duration(milliseconds: 240),
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
                              color: _accent.withValues(alpha: .08),
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.person_add_rounded,
                                size: 13, color: _accent),
                            const SizedBox(width: 5),
                            Text('New customer',
                                style: TextStyle(
                                    color: _accent,
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
            : const SizedBox(width: double.infinity, height: 0),
      ),
      const SizedBox(height: 20),
      // Payment
      Row(children: [
        Expanded(
            child: _FormTextField(
                label: 'Total (₹)',
                controller: _totalCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() => _totalEdited = true))),
        const SizedBox(width: 12),
        Expanded(
            child: _FormTextField(
          label: _minAdvancePaise > 0
              ? 'Advance (min ₹${(_minAdvancePaise / 100).toStringAsFixed(0)})'
              : 'Advance (₹)',
          controller: _advanceCtrl,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
        )),
      ]),
      const SizedBox(height: 16),
      _SegmentPicker(
          options: const [
            ('CASH', 'Cash'),
            ('UPI', 'UPI'),
            ('ONLINE', 'Online')
          ],
          selected: _paymentMode,
          onSelect: (m) => setState(() => _paymentMode = m)),
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

// ── Step indicator ────────────────────────────────────────────────────────────
class _BookingStepBar extends StatelessWidget {
  const _BookingStepBar({required this.step, required this.labels});
  final int step;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
          children: List.generate(labels.length * 2 - 1, (i) {
        if (i.isOdd) {
          final idx = i ~/ 2;
          final done = idx < step;
          return Expanded(
              child: Container(
            height: 2,
            color: done ? _accent : _border,
          ));
        }
        final idx = i ~/ 2;
        final done = idx < step;
        final current = idx == step;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: current ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: done || current ? _accent : _border,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      })),
      const SizedBox(height: 10),
      Row(children: [
        Text(labels[step].toUpperCase(),
            style: const TextStyle(
                color: _accent,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0)),
        const SizedBox(width: 8),
        Text('${step + 1} of ${labels.length}',
            style: const TextStyle(
                color: _muted, fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    ]);
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
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: enabled ? _accent : _border,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(label,
              style: TextStyle(
                  color: enabled ? Colors.white : _muted,
                  fontWeight: FontWeight.w800,
                  fontSize: 15)),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            Icon(trailing, size: 18, color: enabled ? Colors.white : _muted),
          ],
        ]),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? _accent : _bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? _accent : _border),
        ),
        child: Row(children: [
          Icon(icon, size: 22, color: selected ? Colors.white : _muted),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(label,
                    style: TextStyle(
                        color: selected ? Colors.white : _text,
                        fontWeight: FontWeight.w800,
                        fontSize: 14)),
                if (sublabel.isNotEmpty)
                  Text(sublabel,
                      style: TextStyle(
                          color: selected ? Colors.white70 : _muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
              ])),
          if (selected)
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 18),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? _accent : _bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? _accent : _border),
        ),
        child: Row(children: [
          Icon(icon, size: 18, color: selected ? Colors.white : _muted),
          const SizedBox(width: 8),
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: selected ? Colors.white : _text,
                      fontWeight: FontWeight.w800,
                      fontSize: 13))),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color:
                    selected ? Colors.white24 : _accent.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(badge!,
                  style: TextStyle(
                      color: selected ? Colors.white : _accent,
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: highlight ? _accent.withValues(alpha: .06) : _bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: highlight ? _accent.withValues(alpha: .5) : _border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text(label,
                    style: TextStyle(
                        color: highlight ? _accent : _muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700))),
            if (highlight)
              Icon(Icons.touch_app_rounded,
                  size: 14, color: _accent.withValues(alpha: .6)),
          ]),
          const SizedBox(height: 4),
          Text(DateFormat('d MMM yyyy').format(date),
              style: TextStyle(
                  color: highlight ? _accent : _text,
                  fontSize: 14,
                  fontWeight: FontWeight.w800)),
          Text(DateFormat('EEEE').format(date),
              style: TextStyle(
                  color: highlight ? _accent.withValues(alpha: .7) : _muted,
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
    final hasBulkConfig =
        unit.minBulkDays != null && unit.bulkDayRatePaise != null;
    if (!hasBulkConfig) return const SizedBox.shrink();
    if (days < unit.minBulkDays!) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
            'Add ${unit.minBulkDays! - days} more day${unit.minBulkDays! - days > 1 ? 's' : ''} to unlock bulk rate',
            style: const TextStyle(
                color: _muted, fontSize: 12, fontWeight: FontWeight.w600)),
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
          const Icon(Icons.check_circle_rounded, size: 15, color: Colors.green),
          const SizedBox(width: 6),
          Text('Bulk rate unlocked — $days days',
              style: const TextStyle(
                  color: Colors.green,
                  fontSize: 13,
                  fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('₹${unit.bulkDayRatePaise! ~/ 100}/day × $days days',
              style: const TextStyle(
                  color: _muted, fontSize: 12, fontWeight: FontWeight.w600)),
          Text('₹$bulkTotal total',
              style: const TextStyle(
                  color: _text, fontSize: 13, fontWeight: FontWeight.w900)),
        ]),
        if (saving > 0) ...[
          const SizedBox(height: 4),
          Text('Save ₹$saving vs normal rate',
              style: const TextStyle(
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: _muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          maxLength: maxLength,
          inputFormatters: maxLength != null
              ? [LengthLimitingTextInputFormatter(maxLength)]
              : null,
          style: const TextStyle(
              color: _text, fontSize: 14, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            prefixIcon: icon != null
                ? Icon(icon, size: 18, color: _accent.withValues(alpha: .5))
                : null,
            filled: true,
            fillColor: _surface,
            counterText: '',
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _accent, width: 1.6)),
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
      this.durationMins = 60});
  final List<String> times;
  final dynamic selected;
  final Set<String> busyTimes;
  final ValueChanged<String> onSelect;
  final bool isGround;
  final int durationMins;

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
                  color: sel ? _accent : (busy ? _bg : _surface),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: sel
                          ? _accent
                          : (busy ? _border.withValues(alpha: .3) : _border)),
                ),
                child: Row(
                  children: [
                    Icon(icon,
                        size: 18,
                        color: sel
                            ? Colors.white
                            : (busy ? _muted.withValues(alpha: .3) : _accent)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(period,
                              style: TextStyle(
                                  color: sel
                                      ? Colors.white
                                      : (busy
                                          ? _muted.withValues(alpha: .3)
                                          : _text),
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
                                          ? _muted.withValues(alpha: .25)
                                          : _muted),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    if (busy)
                      const Icon(Icons.block_rounded, size: 16, color: _muted),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: sel ? _accent : (busy ? Colors.transparent : _surface),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: sel
                          ? _accent
                          : (busy ? _border.withValues(alpha: .3) : _border))),
              child: Text(_fmt12(t),
                  style: TextStyle(
                      color: sel
                          ? Colors.white
                          : (busy ? _muted.withValues(alpha: .3) : _text),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      decoration: busy ? TextDecoration.lineThrough : null)),
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
                  color: sel ? _accent : _surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sel ? _accent : _border)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(slots[i].label,
                    style: TextStyle(
                        color: sel ? Colors.black : _text,
                        fontSize: 13,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(price,
                    style: TextStyle(
                        color:
                            sel ? Colors.black.withValues(alpha: .6) : _muted,
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _accent : _bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? _accent : _border),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.black : _text,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
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
                  color: sel ? _accent : _surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: sel ? _accent : _border)),
              child: Text(o.$2,
                  style: TextStyle(
                      color: sel ? Colors.black : _text,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
          );
        }).toList());
  }
}
