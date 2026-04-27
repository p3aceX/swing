import 'package:flutter/material.dart';
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
final _selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final _monthSummaryProvider = FutureProvider.autoDispose
    .family<Map<String, ArenaDaySummary>, _SummaryKey>((ref, key) async {
  final repo = ref.watch(hostArenaBookingRepositoryProvider);
  return repo.fetchMonthSummary(key.arenaId, key.month);
});

final _dayBookingsProvider = FutureProvider.autoDispose
    .family<List<ArenaReservation>, _BookingsKey>((ref, key) async {
  final repo = ref.watch(hostArenaBookingRepositoryProvider);
  return repo.listArenaBookings(key.arenaId, date: key.date);
});

class _SummaryKey {
  const _SummaryKey(this.arenaId, this.month);
  final String arenaId;
  final String month;
  @override
  bool operator ==(Object other) =>
      other is _SummaryKey && arenaId == other.arenaId && month == other.month;
  @override
  int get hashCode => Object.hash(arenaId, month);
}

class _BookingsKey {
  const _BookingsKey(this.arenaId, this.date);
  final String arenaId;
  final String date;
  @override
  bool operator ==(Object other) =>
      other is _BookingsKey && arenaId == other.arenaId && date == other.date;
  @override
  int get hashCode => Object.hash(arenaId, date);
}

// ─── Main page ───────────────────────────────────────────────────────────────

class BookingsPage extends ConsumerWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arenasAsync = ref.watch(ownedArenasProvider);

    return arenasAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: _accent)),
      error: (e, _) => _ErrorView(message: '$e'),
      data: (arenas) {
        if (arenas.isEmpty) return const _EmptyArenas();

        final selectedId = ref.watch(_selectedArenaProvider) ?? arenas.first.id;
        final arena = arenas.firstWhere((a) => a.id == selectedId, orElse: () => arenas.first);

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
  late DateTime _month;
  String _selectedFilter = 'All';
  String _selectedUnitId = 'All';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  String get _monthKey => '${_month.year}-${_month.month.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(_selectedDateProvider);
    final selectedKey = DateFormat('yyyy-MM-dd').format(selected);

    final summaryAsync = ref.watch(_monthSummaryProvider(_SummaryKey(widget.arena.id, _monthKey)));
    final summary = summaryAsync.valueOrNull ?? {};

    final dayBookingsAsync = ref.watch(_dayBookingsProvider(_BookingsKey(widget.arena.id, selectedKey)));

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          // 1. Calendar at the top
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8),
            decoration: const BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              boxShadow: [BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: _CompactCalendar(
              month: _month,
              selectedDate: selected,
              summary: summary,
              onDateSelected: (d) {
                ref.read(_selectedDateProvider.notifier).state = d;
                if (d.year != _month.year || d.month != _month.month) {
                  setState(() => _month = DateTime(d.year, d.month));
                }
              },
              onMonthChanged: (m) => setState(() => _month = m),
            ),
          ),

          // 2. Metrics (Total Booking, Total Revenue, Revenue Collected)
          dayBookingsAsync.when(
            loading: () => const Padding(padding: EdgeInsets.all(20), child: LinearProgressIndicator()),
            error: (e, _) => const SizedBox.shrink(),
            data: (rawBookings) {
              final totalCount = rawBookings.length;
              final totalRev = rawBookings.fold(0, (sum, b) => sum + b.totalAmountPaise);
              final collectedRev = rawBookings.fold(0, (sum, b) => 
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

          // 3. Filters
          dayBookingsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => const SizedBox.shrink(),
            data: (rawBookings) {
              final allCount = rawBookings.length;
              final confirmedCount = rawBookings.where((b) => b.status == 'CONFIRMED').length;
              final checkedInCount = rawBookings.where((b) => b.status == 'CHECKED_IN').length;
              final cancelledCount = rawBookings.where((b) => b.status == 'CANCELLED').length;

              return _FilterBar(
                selected: _selectedFilter,
                counts: {
                  'All': allCount,
                  'Confirmed': confirmedCount,
                  'Checked In': checkedInCount,
                  'Cancelled': cancelledCount,
                },
                onSelect: (v) => setState(() => _selectedFilter = v),
              );
            },
          ),

          const SizedBox(height: 12),
          _UnitFilterBar(
            units: widget.arena.units,
            selectedId: _selectedUnitId,
            onSelect: (id) => setState(() => _selectedUnitId = id),
          ),

          Expanded(
            child: dayBookingsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2, color: _accent)),
              error: (e, _) => _ErrorView(message: '$e'),
              data: (rawBookings) {
                final bookings = rawBookings.where((b) {
                  // Status Filter
                  if (_selectedFilter != 'All') {
                    final status = b.status.toUpperCase();
                    if (_selectedFilter == 'Confirmed' && status != 'CONFIRMED') return false;
                    if (_selectedFilter == 'Checked In' && status != 'CHECKED_IN') return false;
                    if (_selectedFilter == 'Cancelled' && status != 'CANCELLED') return false;
                  }
                  // Unit Filter
                  if (_selectedUnitId != 'All') {
                    if (b.unitId != _selectedUnitId) return false;
                  }
                  return true;
                }).toList();

                if (bookings.isEmpty) return _EmptyDay(onAdd: () => _showAddBookingSheet(context, selected));

                return RefreshIndicator(
                  color: _accent,
                  backgroundColor: _surface,
                  onRefresh: () => ref.refresh(_dayBookingsProvider(_BookingsKey(widget.arena.id, selectedKey)).future),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: bookings.length,
                    itemBuilder: (context, i) => BookingCard(
                      booking: bookings[i],
                      onTap: () => _showBookingDetail(context, bookings[i], widget.arena.name, widget.arena.id),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBookingSheet(context, selected),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => AddBookingSheet(arena: widget.arena, date: date),
    ).then((_) {
      final key = DateFormat('yyyy-MM-dd').format(date);
      ref.invalidate(_dayBookingsProvider(_BookingsKey(widget.arena.id, key)));
      ref.invalidate(_monthSummaryProvider(_SummaryKey(widget.arena.id, _monthKey)));
    });
  }

  void _showBookingDetail(BuildContext context, ArenaReservation booking, String arenaName, String arenaId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => BookingDetailSheet(booking: booking, arenaName: arenaName, arenaId: arenaId),
    ).then((_) {
      final key = booking.bookingDate == null ? '' : DateFormat('yyyy-MM-dd').format(booking.bookingDate!);
      if (key.isNotEmpty) {
        ref.invalidate(_dayBookingsProvider(_BookingsKey(arenaId, key)));
        ref.invalidate(_monthSummaryProvider(_SummaryKey(arenaId, _monthKey)));
      }
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.stadium_rounded, color: _accent, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          arena.name,
                          style: const TextStyle(color: _text, fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.unfold_more_rounded, color: _muted, size: 14),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Arena', style: TextStyle(color: _text, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            ...arenas.map((a) => ListTile(
              leading: const Icon(Icons.stadium_outlined, color: _accent),
              title: Text(a.name, style: const TextStyle(color: _text, fontWeight: FontWeight.w700)),
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
  const _HeaderStat({required this.label, required this.value, required this.icon, required this.color});
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
          boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: .1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(color: _text, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted, fontSize: 9, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Calendar ────────────────────────────────────────────────────────────────

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
    final isCurrentMonth = month.year == today.year && month.month == today.month;
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
                  style: const TextStyle(color: _text, fontSize: 18, fontWeight: FontWeight.w900),
                ),
                Row(
                  children: [
                    _NavBtn(Icons.chevron_left_rounded, () => onMonthChanged(DateTime(month.year, month.month - 1))),
                    const SizedBox(width: 12),
                    _NavBtn(Icons.chevron_right_rounded, () => onMonthChanged(DateTime(month.year, month.month + 1))),
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
                      color: sel ? _accent : (isToday ? _accent.withValues(alpha: .08) : _surface),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: sel ? _accent : (isToday ? _accent.withValues(alpha: .4) : _border)),
                      boxShadow: sel ? [
                        BoxShadow(
                          color: _accent.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ] : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEE').format(date).toUpperCase(),
                          style: TextStyle(color: sel ? Colors.white : _muted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$day',
                          style: TextStyle(color: sel ? Colors.white : _text, fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                        if (has) ...[
                          const SizedBox(height: 6),
                          Container(width: 5, height: 5, decoration: BoxDecoration(color: sel ? Colors.white : _accent, shape: BoxShape.circle)),
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
        decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: _border)),
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
                color: (isNextUp ? _accent : Colors.black).withValues(alpha: isNextUp ? 0.08 : 0.04),
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
                    style: const TextStyle(color: _text, fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _durationLabel(_durationMins(booking.startTime, booking.endTime)),
                    style: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700),
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
                      style: const TextStyle(color: _text, fontSize: 15, fontWeight: FontWeight.w800),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (booking.unitName != null) ...[
                          Text(
                            booking.unitName!,
                            style: const TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                        ],
                        _StatusBadge(
                          label: booking.isPaid ? 'PAID' : 'UNPAID', 
                          color: booking.isPaid ? _accent : const Color(0xFFD97706)
                        ),
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
                    style: const TextStyle(color: _text, fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  if (booking.displayPhone.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _QuickAction(Icons.phone_rounded, () => launchUrl(Uri.parse('tel:${booking.displayPhone}'))),
                        const SizedBox(width: 8),
                        _QuickAction(Icons.chat_bubble_rounded, () => launchUrl(Uri.parse('https://wa.me/${booking.displayPhone.replaceAll(RegExp(r'[^0-9]'), '')}'))),
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
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
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
        decoration: BoxDecoration(color: _bg, shape: BoxShape.circle, border: Border.all(color: _border)),
        child: Icon(icon, color: _accent, size: 14),
      ),
    );
  }
}

// ─── Filter Bar ──────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelect, required this.counts});
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
  const _UnitFilterBar({required this.units, required this.selectedId, required this.onSelect});
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
  const BookingDetailSheet({super.key, required this.booking, required this.arenaName, required this.arenaId});
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

  Future<void> _action(Future<ArenaReservation> Function() fn, String msg) async {
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

  void _snack(String m, {bool err = false}) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: err ? Colors.red : _bg));

  Future<void> _sharePassImage() async {
    try {
      final boundary = _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/swing-pass-${_booking.id}.png').create();
      await file.writeAsBytes(bytes);

      await Share.shareXFiles([XFile(file.path)], text: 'Check out your Swing Arena Pass!');
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
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ]),
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('TIME',
                              style: pw.TextStyle(
                                  fontSize: 8, color: PdfColors.grey500)),
                          pw.Text('${_booking.startTime} - ${_booking.endTime}',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
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
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ]),
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('UNIT',
                              style: pw.TextStyle(
                                  fontSize: 8, color: PdfColors.grey500)),
                          pw.Text(_booking.unitName?.toUpperCase() ?? 'GENERAL',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
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
      final updated = await repo.listArenaBookings(_booking.arenaId, date: _fmtDate(_booking.bookingDate!));
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
                            child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 14),
                          ),
                          const SizedBox(width: 10),
                          const Text('SWING ARENA', 
                            style: TextStyle(color: Color(0xFF101828), fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F4F7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFEAECF0)),
                        ),
                        child: const Text('OFFICIAL PASS', 
                          style: TextStyle(color: Color(0xFF667085), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
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
                                    fontWeight: FontWeight.w800)),                          ],
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFEE2E2)),
                        ),
                        child: Text('BALANCE DUE: ₹${(remainingPaise / 100).toStringAsFixed(0)}',
                            style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5)),
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
                      style: TextStyle(color: _accent, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.0)),
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
    _remainingPaise = widget.booking.totalAmountPaise - widget.booking.advancePaise;
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
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 24),
          const Text('Checkout', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _text)),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: _border)),
            child: Column(
              children: [
                _CheckoutRow('Booking Total', '₹${total.toStringAsFixed(0)}'),
                if (advance > 0) ...[
                  const SizedBox(height: 12),
                  _CheckoutRow('Advance Paid', '- ₹${advance.toStringAsFixed(0)}', color: _accent),
                ],
                const Divider(height: 32),
                Row(
                  children: [
                    const Text('Discount (₹)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _muted)),
                    const Spacer(),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: _discountCtrl,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        onChanged: (_) => _updateCalculations(),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                        decoration: const InputDecoration(isDense: true, border: InputBorder.none, hintText: '0'),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                _CheckoutRow('Net Payable', '₹${(_remainingPaise / 100 - discount).toStringAsFixed(0)}', isTotal: true),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          const Text('AMOUNT TO COLLECT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _muted, letterSpacing: 1.0)),
          const SizedBox(height: 12),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: _text),
            decoration: InputDecoration(
              prefixText: '₹ ',
              prefixStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: _muted),
              filled: true,
              fillColor: _bg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          
          const SizedBox(height: 32),
          const Text('PAYMENT MODE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _muted, letterSpacing: 1.0)),
          const SizedBox(height: 16),
          Row(
            children: [
              _ModeTile(icon: Icons.payments_rounded, label: 'CASH', color: Colors.blue, onTap: () => _done('CASH')),
              const SizedBox(width: 12),
              _ModeTile(icon: Icons.qr_code_scanner_rounded, label: 'UPI', color: const Color(0xFF6366F1), onTap: () => _done('UPI')),
              const SizedBox(width: 12),
              _ModeTile(icon: Icons.account_balance_rounded, label: 'ONLINE', color: _accent, onTap: () => _done('ONLINE')),
            ],
          ),
        ],
      ),
    );
  }

  void _done(String mode) {
    final amount = (double.tryParse(_amountCtrl.text) ?? 0);
    Navigator.pop(context, _PaymentResult(mode: mode, amountPaise: (amount * 100).round()));
  }
}

class _CheckoutRow extends StatelessWidget {
  const _CheckoutRow(this.label, this.value, {this.color, this.isTotal = false});
  final String label;
  final String value;
  final Color? color;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 15 : 13, fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600, color: isTotal ? _text : _muted)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: isTotal ? 20 : 15, fontWeight: FontWeight.w900, color: color ?? _text)),
      ],
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({required this.icon, required this.label, required this.color, required this.onTap});
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
                decoration: BoxDecoration(color: color.withValues(alpha: .1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: _text, letterSpacing: 0.5)),
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
  const _TicketStat({required this.label, required this.value, this.color, this.isBold = false});
  final String label;
  final String value;
  final Color? color;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF98A2B3), fontSize: 9, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(value.toUpperCase(), 
          style: TextStyle(
            color: color ?? const Color(0xFF101828), 
            fontSize: 13, 
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w800
          )),
      ],
    );
  }
}

class _DetailInfoRow extends StatelessWidget {
  const _DetailInfoRow(this.label, this.value, this.icon, {this.isBold = false});
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
        Text(label, style: const TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w600)),
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
    return const Center(child: Text('No arenas found', style: TextStyle(color: _muted)));
  }
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay({required this.onAdd});
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: _surface, shape: BoxShape.circle, border: Border.all(color: _border)),
            child: Icon(Icons.event_note_rounded, size: 48, color: _muted.withValues(alpha: .5)),
          ),
          const SizedBox(height: 24),
          const Text('No bookings for this day', style: TextStyle(color: _text, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Tap the button below to add a manual entry', style: TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 32),
          ArenaPrimaryButton(label: 'Add New Booking', onPressed: onAdd),
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
    return Center(child: Text(message, style: const TextStyle(color: Colors.red)));
  }
}

// ─── Add Booking Sheet ────────────────────────────────────────────────────────

class _SlotOption {
  const _SlotOption({required this.durationMins, required this.label, required this.paise});
  final int durationMins;
  final String label;
  final int paise;
}

List<_SlotOption> _buildSlotOptions(ArenaUnitOption unit) {
  final increment = unit.slotIncrementMins > 0 ? unit.slotIncrementMins : 60;
  final minMins = unit.minSlotMins > 0 ? unit.minSlotMins : increment;
  final isGround = unit.unitType == 'FULL_GROUND' || unit.unitType == 'HALF_GROUND';
  final maxMins = unit.maxSlotMins > 0 ? unit.maxSlotMins : (isGround ? 720 : 240);
  final opts = <_SlotOption>[];
  for (var m = minMins; m <= maxMins; m += increment) {
    final int paise;
    if (m == 240 && unit.price4HrPaise != null) paise = unit.price4HrPaise!;
    else if (m == 480 && unit.price8HrPaise != null) paise = unit.price8HrPaise!;
    else if (m >= 720 && unit.priceFullDayPaise != null) paise = unit.priceFullDayPaise!;
    else paise = ((unit.pricePerHourPaise * m) / 60).round();
    final label = (m >= 720 && unit.priceFullDayPaise != null) ? 'Full day' : _durationLabel(m);
    opts.add(_SlotOption(durationMins: m, label: label, paise: paise));
  }
  return opts.isEmpty ? [_SlotOption(durationMins: 60, label: '1 hr', paise: unit.pricePerHourPaise)] : opts;
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
  const AddBookingSheet({super.key, required this.arena, required this.date, this.lockedUnitId});
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

  late DateTime _selectedDate;
  String? _unitId;
  // Holds the single selected start time (duration-first model)
  final List<String> _selectedSlots = [];
  int _selectedDurationIdx = 0;
  String _paymentMode = 'CASH';
  bool _loading = false;
  bool _totalEdited = false;
  List<String> _allDaySlots = [];
  List<ArenaReservation> _existingBookings = [];
  bool _loadingAvail = true;

  ArenaUnitOption? get _unit => widget.arena.units.where((u) => u.id == _unitId).firstOrNull;

  int get _currentDurationMins {
    final unit = _unit;
    if (unit == null) return 60;
    final opts = _buildSlotOptions(unit);
    final idx = _selectedDurationIdx.clamp(0, opts.length - 1);
    return opts[idx].durationMins;
  }

  String get _startTime => _selectedSlots.isEmpty ? '' : _selectedSlots.first;
  String get _endTime {
    if (_selectedSlots.isEmpty) return '';
    return _addMinutes(_selectedSlots.first, _currentDurationMins);
  }

  int get _totalPaise {
    if (_totalEdited) return ((double.tryParse(_totalCtrl.text) ?? 0) * 100).round();
    final unit = _unit;
    if (unit == null || _selectedSlots.isEmpty) return 0;
    final opts = _buildSlotOptions(unit);
    final idx = _selectedDurationIdx.clamp(0, opts.length - 1);
    return opts[idx].paise;
  }

  int get _advancePaise => ((double.tryParse(_advanceCtrl.text) ?? 0) * 100).round().clamp(0, _totalPaise);
  int get _minAdvancePaise => _unit?.minAdvancePaise ?? 0;
  bool get _advanceOk => _minAdvancePaise == 0 || _advancePaise >= _minAdvancePaise;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.date;
    _unitId = widget.lockedUnitId ?? widget.arena.units.firstOrNull?.id;
    _initDuration();
    _rebuildTimes();
    _loadAvailability();
  }

  void _initDuration() {
    final unit = _unit;
    if (unit == null) { _selectedDurationIdx = 0; return; }
    final opts = _buildSlotOptions(unit);
    // Start at the option whose duration matches minSlotMins
    final idx = opts.indexWhere((o) => o.durationMins >= unit.minSlotMins);
    _selectedDurationIdx = idx >= 0 ? idx : 0;
  }

  void _rebuildTimes() {
    final unit = _unit;
    final arena = widget.arena;
    if (unit == null) { _allDaySlots = []; return; }

    final openStr = unit.openTime ?? arena.openTime ?? '06:00';
    final closeStr = unit.closeTime ?? arena.closeTime ?? '23:00';
    final openMins = _toMins(openStr);
    final closeMins = _toMins(closeStr);
    final increment = unit.slotIncrementMins > 0 ? unit.slotIncrementMins : 60;
    final durMins = _currentDurationMins;

    final isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());
    final bufferMins = arena.bufferMins;
    final nowMins = DateTime.now().hour * 60 + DateTime.now().minute;

    _allDaySlots = [];
    for (var m = openMins; m + durMins <= closeMins; m += increment) {
      if (isToday && m < nowMins + bufferMins) continue;
      _allDaySlots.add(_fromMins(m));
    }
    _selectedSlots.clear();
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
    if (_unitId == null) { setState(() => _loadingAvail = false); return; }
    setState(() => _loadingAvail = true);
    try {
      final repo = ref.read(hostArenaBookingRepositoryProvider);
      final date = _fmtDate(_selectedDate);

      // Collect related unit IDs: the unit itself + parent + children
      final relatedIds = <String>{_unitId!};
      final parentId = _unit?.parentUnitId;
      if (parentId != null) relatedIds.add(parentId);
      for (final u in widget.arena.units) {
        if (u.parentUnitId == _unitId) relatedIds.add(u.id);
      }

      final results = await Future.wait(
        relatedIds.map((id) => repo.listArenaBookings(widget.arena.id, date: date, unitId: id)),
      );
      final merged = results.expand((b) => b).toList();
      if (mounted) setState(() => _existingBookings = merged);
    } catch (_) { if (mounted) setState(() => _existingBookings = []); }
    finally { if (mounted) setState(() => _loadingAvail = false); }
  }

  // A start time is busy if any part of [time, time + selectedDuration) overlaps an existing booking.
  bool _isBusy(String time) {
    final tMins = _toMins(time);
    final durMins = _currentDurationMins;
    return _existingBookings.any((b) {
      if (b.status == 'CANCELLED') return false;
      return _toMins(b.startTime) < tMins + durMins && _toMins(b.endTime) > tMins;
    });
  }

  void _onSlotTapped(String time) {
    if (_isBusy(time)) return;
    setState(() {
      if (_selectedSlots.length == 1 && _selectedSlots.first == time) {
        _selectedSlots.clear();
        _totalCtrl.clear();
      } else {
        _selectedSlots..clear()..add(time);
        if (!_totalEdited) _totalCtrl.text = (_totalPaise / 100).toStringAsFixed(0);
      }
    });
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty) { _snack('Required fields missing', err: true); return; }
    if (_selectedSlots.isEmpty) { _snack('Please select a start time', err: true); return; }
    if (!_advanceOk) { _snack('Min advance ₹${(_minAdvancePaise / 100).toStringAsFixed(0)} required', err: true); return; }
    
    setState(() => _loading = true);
    try {
      await ref.read(hostArenaBookingRepositoryProvider).createManualBooking(
        widget.arena.id, unitId: _unitId!, date: _fmtDate(_selectedDate),
        startTime: _startTime, endTime: _endTime, guestName: _nameCtrl.text.trim(),
        guestPhone: _phoneCtrl.text.trim(), paymentMode: _paymentMode,
        amountPaise: _totalPaise, advancePaise: _advancePaise,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) { if (mounted) _snack('$e', err: true); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  void _snack(String m, {bool err = false}) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: err ? Colors.red : _bg));

  Future<void> _selectDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: _accent, onPrimary: Colors.white, onSurface: _text)),
        child: child!,
      ),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _rebuildTimes();
      });
      _loadAvailability();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 44, height: 5, decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 24),
            const Text('New Booking', style: TextStyle(color: _text, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.8)),
            const SizedBox(height: 16),
            
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _border)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: _accent.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.calendar_today_rounded, color: _accent, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('BOOKING DATE', style: TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(DateFormat('EEEE, d MMMM yyyy').format(_selectedDate), style: const TextStyle(color: _text, fontSize: 15, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                    Icon(Icons.unfold_more_rounded, color: _muted, size: 20),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            _FormTextField(label: 'Guest Name', controller: _nameCtrl, icon: Icons.person_outline_rounded),
            const SizedBox(height: 16),
            _FormTextField(label: 'Phone Number', controller: _phoneCtrl, icon: Icons.phone_android_rounded, keyboardType: TextInputType.phone),
            const SizedBox(height: 24),
            
            if (widget.arena.units.length > 1) ...[
              const Text('Select Unit', style: TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
              const SizedBox(height: 12),
              _SegmentPicker(options: widget.arena.units.map((u) => (u.id, u.name)).toList(), selected: _unitId ?? '', onSelect: (id) { setState(() { _unitId = id; _initDuration(); _rebuildTimes(); }); _loadAvailability(); }),
              const SizedBox(height: 24),
            ],

            if (_unit != null) ...[
              const Text('Duration', style: TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
              const SizedBox(height: 12),
              _SlotPicker(
                slots: _buildSlotOptions(_unit!),
                selectedIdx: _selectedDurationIdx,
                onSelect: (idx) {
                  setState(() { _selectedDurationIdx = idx; _rebuildTimes(); });
                  _loadAvailability();
                },
              ),
              const SizedBox(height: 24),
            ],

            const Text('Select Start Time', style: TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            if (_allDaySlots.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: _muted, size: 18),
                    const SizedBox(width: 12),
                    const Text('No slots available.', style: TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              )
            else
              _StartTimeGrid(times: _allDaySlots, selected: _selectedSlots, busyTimes: {for (final t in _allDaySlots) if (_isBusy(t)) t}, onSelect: _onSlotTapped, isGround: _unit?.unitType == 'FULL_GROUND' || _unit?.unitType == 'HALF_GROUND', durationMins: _currentDurationMins),

            if (_selectedSlots.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: _accent.withValues(alpha: .08), borderRadius: BorderRadius.circular(12), border: Border.all(color: _accent.withValues(alpha: .25))),
                child: Row(children: [
                  Icon(Icons.schedule_rounded, color: _accent, size: 18),
                  const SizedBox(width: 12),
                  Text('$_startTime → $_endTime', style: TextStyle(color: _accent, fontSize: 14, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 8),
                  Text('· ${_durationLabel(_currentDurationMins)}', style: const TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w600)),
                ]),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _FormTextField(label: 'Total (₹)', controller: _totalCtrl, keyboardType: TextInputType.number, onChanged: (_) => _totalEdited = true)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _FormTextField(
                      label: _minAdvancePaise > 0 ? 'Advance (min ₹${(_minAdvancePaise / 100).toStringAsFixed(0)})' : 'Advance (₹)',
                      controller: _advanceCtrl,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Payment Mode', style: TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
              const SizedBox(height: 12),
              _SegmentPicker(
                options: const [('CASH', 'Cash'), ('UPI', 'UPI'), ('ONLINE', 'Online')],
                selected: _paymentMode,
                onSelect: (m) => setState(() => _paymentMode = m),
              ),
              const SizedBox(height: 16),
              _FormTextField(label: 'Notes (optional)', controller: _notesCtrl, icon: Icons.notes_rounded),
              const SizedBox(height: 32),
              ArenaPrimaryButton(
                label: _loading ? 'Saving…' : 'Confirm $_startTime – $_endTime Booking',
                onPressed: _loading ? () {} : _save,
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _FormTextField extends StatelessWidget {
  const _FormTextField({required this.label, required this.controller, this.icon, this.keyboardType, this.onChanged});
  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: const TextStyle(color: _text, fontSize: 14, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, size: 18, color: _accent.withValues(alpha: .5)) : null,
            filled: true,
            fillColor: _surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _accent, width: 1.6)),
          ),
        ),
      ],
    );
  }
}

class _StartTimeGrid extends StatelessWidget {
  const _StartTimeGrid({required this.times, required this.selected, required this.busyTimes, required this.onSelect, this.isGround = false, this.durationMins = 60});
  final List<String> times; final dynamic selected; final Set<String> busyTimes; final ValueChanged<String> onSelect;
  final bool isGround; final int durationMins;

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
    return m == 0 ? '$h12$suffix' : '$h12:${m.toString().padLeft(2, '0')}$suffix';
  }

  @override
  Widget build(BuildContext context) {
    final selList = selected is List<String> ? selected as List<String> : [selected as String];

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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: sel ? _accent : (busy ? _bg : _surface),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sel ? _accent : (busy ? _border.withValues(alpha: .3) : _border)),
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 18, color: sel ? Colors.white : (busy ? _muted.withValues(alpha: .3) : _accent)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(period, style: TextStyle(color: sel ? Colors.white : (busy ? _muted.withValues(alpha: .3) : _text), fontSize: 13, fontWeight: FontWeight.w800, decoration: busy ? TextDecoration.lineThrough : null)),
                          Text('${_fmt12(t)} – ${_fmt12(_endTime(t))}', style: TextStyle(color: sel ? Colors.white.withOpacity(0.8) : (busy ? _muted.withValues(alpha: .25) : _muted), fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    if (busy) const Icon(Icons.block_rounded, size: 16, color: _muted),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    return Wrap(spacing: 8, runSpacing: 8, children: times.map((t) {
      final busy = busyTimes.contains(t);
      final sel = selList.contains(t);
      return GestureDetector(
        onTap: busy ? null : () => onSelect(t),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: sel ? _accent : (busy ? Colors.transparent : _surface),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: sel ? _accent : (busy ? _border.withValues(alpha: .3) : _border))
          ),
          child: Text(t, style: TextStyle(color: sel ? Colors.white : (busy ? _muted.withValues(alpha: .3) : _text), fontSize: 12, fontWeight: FontWeight.w700, decoration: busy ? TextDecoration.lineThrough : null)),
        ),
      );
    }).toList());
  }
}

class _SlotPicker extends StatelessWidget {
  const _SlotPicker({required this.slots, required this.selectedIdx, required this.onSelect});
  final List<_SlotOption> slots; final int selectedIdx; final ValueChanged<int> onSelect;
  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 8, children: List.generate(slots.length, (i) {
      final sel = i == selectedIdx;
      return GestureDetector(
        onTap: () => onSelect(i),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: sel ? _accent : _surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: sel ? _accent : _border)),
          child: Text(slots[i].label, style: TextStyle(color: sel ? Colors.black : _text, fontSize: 12, fontWeight: FontWeight.w700)),
        ),
      );
    }));
  }
}

class _SegmentPicker extends StatelessWidget {
  const _SegmentPicker({required this.options, required this.selected, required this.onSelect});
  final List<(String, String)> options; final String selected; final ValueChanged<String> onSelect;
  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 8, children: options.map((o) {
      final sel = o.$1 == selected;
      return GestureDetector(
        onTap: () => onSelect(o.$1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: sel ? _accent : _surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: sel ? _accent : _border)),
          child: Text(o.$2, style: TextStyle(color: sel ? Colors.black : _text, fontSize: 12, fontWeight: FontWeight.w700)),
        ),
      );
    }).toList());
  }
}
