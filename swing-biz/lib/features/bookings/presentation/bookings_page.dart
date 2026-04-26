import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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
              final collectedRev = rawBookings
                  .where((b) => b.status == 'CHECKED_IN')
                  .fold(0, (sum, b) => sum + b.totalAmountPaise);

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
                      onTap: () => _showBookingDetail(context, bookings[i], widget.arena.id),
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
        foregroundColor: Colors.black,
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

  void _showBookingDetail(BuildContext context, ArenaReservation booking, String arenaId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => BookingDetailSheet(booking: booking, arenaId: arenaId),
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
                        _StatusBadge(label: booking.status, color: statusColor),
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
  const BookingDetailSheet({super.key, required this.booking, required this.arenaId});
  final ArenaReservation booking;
  final String arenaId;
  @override
  ConsumerState<BookingDetailSheet> createState() => _BookingDetailSheetState();
}

class _BookingDetailSheetState extends ConsumerState<BookingDetailSheet> {
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

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(hostArenaBookingRepositoryProvider);
    final statusColor = _statusColor(_booking.status);

    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).padding.bottom + 24),
      decoration: const BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 44, height: 5, decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: _accent.withValues(alpha: .1), borderRadius: BorderRadius.circular(16)),
                child: Icon(Icons.person_rounded, color: _accent, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_booking.displayName, style: const TextStyle(color: _text, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                    Text(_booking.displayPhone, style: const TextStyle(color: _muted, fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              _StatusBadge(label: _booking.status, color: statusColor),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _border),
            ),
            child: Column(
              children: [
                _DetailInfoRow('Schedule', '\${_booking.startTime} - \${_booking.endTime}', Icons.access_time_rounded),
                const Divider(height: 32),
                _DetailInfoRow('Asset/Unit', _booking.unitName ?? 'General', Icons.stadium_rounded),
                const Divider(height: 32),
                _DetailInfoRow('Total Amount', '₹\${(_booking.totalAmountPaise / 100).toStringAsFixed(0)}', Icons.payments_rounded, isBold: true),
                if (_booking.paymentMode != null) ...[
                  const Divider(height: 32),
                  _DetailInfoRow('Payment Via', _booking.paymentMode!, Icons.account_balance_wallet_rounded),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
          if (_loading) const CircularProgressIndicator(color: _accent)
          else ...[
            if (!_booking.isPaid && _booking.status != 'CANCELLED')
              ArenaPrimaryButton(label: 'Mark as Paid', onPressed: () => _action(() => repo.markBookingPaid(_booking.id, paymentMode: 'CASH'), 'Paid')),
            const SizedBox(height: 12),
            if (_booking.status == 'CONFIRMED')
              ArenaPrimaryButton(label: 'Check In Guest', onPressed: () => _action(() => repo.checkinByOwner(_booking.id), 'Checked In')),
          ],
        ],
      ),
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
      children: [
        Icon(icon, size: 18, color: _muted),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w600)),
        const Spacer(),
        Text(value, style: TextStyle(color: _text, fontSize: 14, fontWeight: isBold ? FontWeight.w900 : FontWeight.w700)),
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

  String? _unitId;
  String? _startTime;
  List<_SlotOption> _allSlots = [];
  List<_SlotOption> _availableSlots = [];
  int _selectedSlotIdx = 0;
  String _paymentMode = 'CASH';
  bool _loading = false;
  bool _totalEdited = false;
  List<String> _startOptions = [];
  List<ArenaReservation> _existingBookings = [];
  bool _loadingAvail = true;

  ArenaUnitOption? get _unit => widget.arena.units.where((u) => u.id == _unitId).firstOrNull;
  String get _endTime => (_startTime == null || _availableSlots.isEmpty) ? '' : _addMinutes(_startTime!, _availableSlots[_selectedSlotIdx].durationMins);
  int get _totalPaise => _totalEdited ? ((double.tryParse(_totalCtrl.text) ?? 0) * 100).round() : (_availableSlots.isEmpty ? 0 : _availableSlots[_selectedSlotIdx].paise);
  int get _advancePaise => ((double.tryParse(_advanceCtrl.text) ?? 0) * 100).round().clamp(0, _totalPaise);
  int get _minAdvancePaise => _unit?.minAdvancePaise ?? 0;
  bool get _advanceOk => _minAdvancePaise == 0 || _advancePaise >= _minAdvancePaise;

  @override
  void initState() {
    super.initState();
    _unitId = widget.lockedUnitId ?? widget.arena.units.firstOrNull?.id;
    _rebuildUnit();
    _loadAvailability();
  }

  void _rebuildUnit() {
    final unit = _unit;
    if (unit == null) { _allSlots = []; _startOptions = []; return; }
    _allSlots = _buildSlotOptions(unit);
    _startOptions = _buildStartTimes(unit);
    _startTime = null; _availableSlots = []; _selectedSlotIdx = 0; _totalEdited = false;
    _totalCtrl.clear(); _advanceCtrl.clear();
  }

  List<String> _buildStartTimes(ArenaUnitOption unit) {
    final arena = widget.arena;
    final openStr = unit.openTime ?? arena.openTime;
    final closeStr = unit.closeTime ?? arena.closeTime;
    final openMins = _toMins(openStr);
    final closeMins = _toMins(closeStr);
    final minDur = _allSlots.isEmpty ? 60 : _allSlots.first.durationMins;
    final times = <String>[];
    for (var m = openMins; m + minDur <= closeMins; m += 60) times.add(_fromMins(m));
    return times;
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
      final bookings = await ref.read(hostArenaBookingRepositoryProvider).listArenaBookings(widget.arena.id, date: _fmtDate(widget.date), unitId: _unitId);
      if (mounted) setState(() => _existingBookings = bookings);
    } catch (_) { if (mounted) setState(() => _existingBookings = []); }
    finally { if (mounted) setState(() => _loadingAvail = false); }
  }

  bool _isBusy(String time) {
    final tMins = _toMins(time);
    return _existingBookings.any((b) {
      if (b.status == 'CANCELLED') return false;
      return _toMins(b.startTime) < tMins + 60 && _toMins(b.endTime) > tMins;
    });
  }

  void _onStartTimeTapped(String time) {
    if (_isBusy(time)) return;
    setState(() {
      _startTime = time; _selectedSlotIdx = 0; _totalEdited = false;
      _availableSlots = _filterSlots(time);
      _syncTotalCtrl();
    });
  }

  List<_SlotOption> _filterSlots(String startTime) {
    final unit = _unit; if (unit == null) return [];
    final closeMins = _toMins(unit.closeTime ?? widget.arena.closeTime);
    final startMins = _toMins(startTime);
    return _allSlots.where((slot) {
      final endMins = startMins + slot.durationMins;
      if (endMins > closeMins) return false;
      return !_existingBookings.any((b) {
        if (b.status == 'CANCELLED') return false;
        return _toMins(b.startTime) < endMins && _toMins(b.endTime) > startMins;
      });
    }).toList();
  }

  void _syncTotalCtrl() {
    if (!_totalEdited && _availableSlots.isNotEmpty) {
      _totalCtrl.text = (_availableSlots[_selectedSlotIdx].paise / 100).toStringAsFixed(0);
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty) { _snack('Required fields missing', err: true); return; }
    if (!_advanceOk) { _snack('Min advance ₹${(_minAdvancePaise / 100).toStringAsFixed(0)} required for this unit', err: true); return; }
    setState(() => _loading = true);
    try {
      await ref.read(hostArenaBookingRepositoryProvider).createManualBooking(
        widget.arena.id, unitId: _unitId!, date: _fmtDate(widget.date),
        startTime: _startTime!, endTime: _endTime, guestName: _nameCtrl.text.trim(),
        guestPhone: _phoneCtrl.text.trim(), paymentMode: _paymentMode,
        amountPaise: _totalPaise, advancePaise: _advancePaise,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) { if (mounted) _snack('$e', err: true); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  void _snack(String m, {bool err = false}) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: err ? Colors.red : _bg));

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('New Booking', style: TextStyle(color: _text, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            const SizedBox(height: 24),
            _FormTextField(label: 'Guest Name', controller: _nameCtrl, icon: Icons.person_outline_rounded),
            const SizedBox(height: 16),
            _FormTextField(label: 'Phone Number', controller: _phoneCtrl, icon: Icons.phone_android_rounded, keyboardType: TextInputType.phone),
            const SizedBox(height: 24),
            if (widget.arena.units.length > 1) ...[
              const Text('Select Unit', style: TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              _SegmentPicker(options: widget.arena.units.map((u) => (u.id, u.name)).toList(), selected: _unitId ?? '', onSelect: (id) { setState(() { _unitId = id; _rebuildUnit(); }); _loadAvailability(); }),
              const SizedBox(height: 24),
            ],
            const Text('Start Time', style: TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _StartTimeGrid(times: _startOptions, selected: _startTime, busyTimes: {for (final t in _startOptions) if (_isBusy(t)) t}, onSelect: _onStartTimeTapped),
            if (_startTime != null && _availableSlots.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text('Duration', style: TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _SlotPicker(slots: _availableSlots, selectedIdx: _selectedSlotIdx, onSelect: (i) => setState(() { _selectedSlotIdx = i; _syncTotalCtrl(); })),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _FormTextField(label: 'Total (₹)', controller: _totalCtrl, keyboardType: TextInputType.number, onChanged: (_) => _totalEdited = true)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _FormTextField(
                      label: _minAdvancePaise > 0
                          ? 'Advance (₹)  ·  min ₹${(_minAdvancePaise / 100).toStringAsFixed(0)}'
                          : 'Advance (₹)',
                      controller: _advanceCtrl,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              if (_minAdvancePaise > 0 && !_advanceOk) ...[
                const SizedBox(height: 6),
                Text(
                  'Min advance ₹${(_minAdvancePaise / 100).toStringAsFixed(0)} required',
                  style: const TextStyle(fontSize: 11, color: Color(0xFFDC2626), fontWeight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: 32),
              ArenaPrimaryButton(label: 'Confirm Booking', onPressed: _loading ? () {} : _save),
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
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _accent, width: 1.5)),
          ),
        ),
      ],
    );
  }
}

class _StartTimeGrid extends StatelessWidget {
  const _StartTimeGrid({required this.times, required this.selected, required this.busyTimes, required this.onSelect});
  final List<String> times; final String? selected; final Set<String> busyTimes; final ValueChanged<String> onSelect;
  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 8, children: times.map((t) {
      final busy = busyTimes.contains(t); final sel = t == selected;
      return GestureDetector(
        onTap: busy ? null : () => onSelect(t),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: sel ? _accent : (busy ? Colors.transparent : _surface), borderRadius: BorderRadius.circular(10), border: Border.all(color: sel ? _accent : (busy ? _border.withValues(alpha: .3) : _border))),
          child: Text(t, style: TextStyle(color: sel ? Colors.black : (busy ? _muted.withValues(alpha: .3) : _text), fontSize: 12, fontWeight: FontWeight.w700, decoration: busy ? TextDecoration.lineThrough : null)),
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
