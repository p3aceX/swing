import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../arena/services/arena_profile_providers.dart';
import '../../bookings/presentation/bookings_page.dart';

// ─── Theme Overrides ─────────────────────────────────────────────────────────
const _bg = Color(0xFFF9FAFB);
const _surface = Color(0xFFFFFFFF);
const _border = Color(0xFFE5E7EB);
const _accent = Color(0xFF059669);
const _text = Color(0xFF111827);
const _muted = Color(0xFF6B7280);

// ─── Providers ────────────────────────────────────────────────────────────────

final _payArenaProvider = StateProvider<String?>((ref) => null);

class _PayKey {
  const _PayKey(this.arenaId, this.month);
  final String arenaId;
  final String month;
  @override
  bool operator ==(Object o) => o is _PayKey && arenaId == o.arenaId && month == o.month;
  @override
  int get hashCode => Object.hash(arenaId, month);
}

class _GuestKey {
  const _GuestKey(this.arenaId, this.search);
  final String arenaId;
  final String search;
  @override
  bool operator ==(Object o) => o is _GuestKey && arenaId == o.arenaId && search == o.search;
  @override
  int get hashCode => Object.hash(arenaId, search);
}

final _arenaPaymentsProvider = FutureProvider.autoDispose
    .family<ArenaPaymentsData, _PayKey>((ref, key) async {
  return ref.watch(hostArenaBookingRepositoryProvider)
      .fetchArenaPayments(key.arenaId, month: key.month);
});

final _arenaGuestsProvider = FutureProvider.autoDispose
    .family<List<ArenaGuest>, _GuestKey>((ref, key) async {
  return ref.watch(hostArenaBookingRepositoryProvider)
      .fetchArenaGuests(key.arenaId, search: key.search.isEmpty ? null : key.search);
});

// ─── Root page ────────────────────────────────────────────────────────────────

class PaymentsPage extends ConsumerWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arenasAsync = ref.watch(ownedArenasProvider);
    return arenasAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (arenas) {
        if (arenas.isEmpty) return const _Empty('No arenas yet.');
        final selectedId = ref.watch(_payArenaProvider) ?? arenas.first.id;
        final arena = arenas.firstWhere((a) => a.id == selectedId, orElse: () => arenas.first);
        return _PaymentsBody(arena: arena, arenas: arenas, selectedId: selectedId);
      },
    );
  }
}

// ─── Body with DefaultTabController ──────────────────────────────────────────

class _PaymentsBody extends StatelessWidget {
  const _PaymentsBody({required this.arena, required this.arenas, required this.selectedId});
  final ArenaListing arena;
  final List<ArenaListing> arenas;
  final String selectedId;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12),
              decoration: const BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                boxShadow: [BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Payments',
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: _text, letterSpacing: -0.8)),
                        if (arenas.length > 1)
                          Consumer(builder: (ctx, ref, _) => GestureDetector(
                            onTap: () => _showArenaPicker(ctx, ref),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: _bg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: _border),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.stadium_rounded, color: _accent, size: 18),
                                  const SizedBox(width: 10),
                                  Text(arena.name,
                                      style: const TextStyle(color: _text, fontSize: 13, fontWeight: FontWeight.w800)),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.unfold_more_rounded, color: _muted, size: 16),
                                ],
                              ),
                            ),
                          )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const TabBar(
                    labelColor: _text,
                    unselectedLabelColor: _muted,
                    labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    unselectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    indicatorColor: _accent,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorPadding: EdgeInsets.symmetric(horizontal: 16),
                    dividerColor: Colors.transparent,
                    tabs: [Tab(text: 'Collections'), Tab(text: 'Customers')],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _CollectionsTab(arena: arena),
                  _CustomersTab(arena: arena),
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
  const _CollectionsTab({required this.arena});
  final ArenaListing arena;

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
    super.build(context);
    final key = _PayKey(widget.arena.id, _month);
    final async = ref.watch(_arenaPaymentsProvider(key));

    return Scaffold(
      backgroundColor: _bg,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2, color: _accent)),
        error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: Color(0xFF667085)))),
        data: (data) => _CollectionsList(
          data: data,
          month: _month,
          arena: widget.arena,
          onMonthChanged: (m) => setState(() => _month = m),
          onRefresh: () => ref.invalidate(_arenaPaymentsProvider(key)),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickPay(context),
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_card_rounded),
        label: const Text('Record Payment', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }

  void _showQuickPay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (_) => _QuickPaySheet(arena: widget.arena),
    ).then((_) => ref.invalidate(_arenaPaymentsProvider));
  }
}

class _QuickPaySheet extends ConsumerStatefulWidget {
  const _QuickPaySheet({required this.arena});
  final ArenaListing arena;
  @override
  ConsumerState<_QuickPaySheet> createState() => _QuickPaySheetState();
}

class _QuickPaySheetState extends ConsumerState<_QuickPaySheet> {
  String _search = '';
  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_arenaGuestsProvider(_GuestKey(widget.arena.id, _search)));
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottom),
      child: Column(
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          const Text('Record Payment', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _text)),
          const SizedBox(height: 20),
          TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Search customer name or phone...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true, fillColor: _surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (guests) {
                // 1. Extract all unpaid bookings
                final unpaid = <(ArenaGuest, ArenaReservation)>[];
                for (final g in guests) {
                  for (final b in g.recentBookings) {
                    if (!b.isPaid && b.status != 'CANCELLED') {
                      unpaid.add((g, b));
                    }
                  }
                }

                if (unpaid.isEmpty) {
                  return const Center(
                    child: Text('No pending balances found.',
                        style: TextStyle(color: _muted, fontWeight: FontWeight.w600)),
                  );
                }

                // 2. Sort and Categorize
                final now = DateTime.now();
                final nowMins = now.hour * 60 + now.minute;

                final upcoming = <(ArenaGuest, ArenaReservation)>[];
                final recent = <(ArenaGuest, ArenaReservation)>[];

                for (final item in unpaid) {
                  final b = item.$2;
                  final isFutureDate = b.bookingDate != null && b.bookingDate!.isAfter(DateTime(now.year, now.month, now.day));
                  final isToday = b.bookingDate != null && DateUtils.isSameDay(b.bookingDate, now);
                  
                  bool isUpcoming = false;
                  if (isFutureDate) {
                    isUpcoming = true;
                  } else if (isToday) {
                    final startMins = _toMins(b.startTime);
                    if (startMins > nowMins) isUpcoming = true;
                  }

                  if (isUpcoming) upcoming.add(item); else recent.add(item);
                }

                // Sort: Recent (newest past first), Upcoming (closest first)
                recent.sort((a, b) {
                  final da = a.$2.bookingDate ?? DateTime(2000);
                  final db = b.$2.bookingDate ?? DateTime(2000);
                  if (da != db) return db.compareTo(da);
                  return _toMins(b.$2.startTime).compareTo(_toMins(a.$2.startTime));
                });
                upcoming.sort((a, b) {
                  final da = a.$2.bookingDate ?? DateTime(2100);
                  final db = b.$2.bookingDate ?? DateTime(2100);
                  if (da != db) return da.compareTo(db);
                  return _toMins(a.$2.startTime).compareTo(_toMins(b.$2.startTime));
                });

                return ListView(
                  children: [
                    if (recent.isNotEmpty) ...[
                      const _SectionLabel('RECENT & COMPLETED'),
                      const SizedBox(height: 12),
                      ...recent.map((item) => _QuickPayRow(
                            guest: item.$1,
                            booking: item.$2,
                            arena: widget.arena,
                          )),
                      const SizedBox(height: 24),
                    ],
                    if (upcoming.isNotEmpty) ...[
                      const _SectionLabel('UPCOMING'),
                      const SizedBox(height: 12),
                      ...upcoming.map((item) => _QuickPayRow(
                            guest: item.$1,
                            booking: item.$2,
                            arena: widget.arena,
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
  const _QuickPayRow({required this.guest, required this.booking, required this.arena});
  final ArenaGuest guest;
  final ArenaReservation booking;
  final ArenaListing arena;

  @override
  Widget build(BuildContext context) {
    final date = booking.bookingDate != null ? DateFormat('EEE d MMM').format(booking.bookingDate!) : '—';
    final balance = booking.totalAmountPaise - booking.advancePaise;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
            builder: (_) => BookingDetailSheet(booking: booking, arenaName: arena.name, arenaId: arena.id),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border),
            boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: _text, borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: Text(guest.name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(guest.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _text)),
                    const SizedBox(height: 2),
                    Text('$date · ${booking.startTime} · ${booking.unitName ?? 'General'}',
                        style: const TextStyle(fontSize: 11, color: _muted, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${(balance / 100).toStringAsFixed(0)}',
                      style: const TextStyle(color: Color(0xFFDC2626), fontSize: 14, fontWeight: FontWeight.w900)),
                  const Text('DUE', style: TextStyle(color: Color(0xFFDC2626), fontSize: 8, fontWeight: FontWeight.w900)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollectionsList extends StatelessWidget {
  const _CollectionsList({
    required this.data,
    required this.month,
    required this.arena,
    required this.onMonthChanged,
    required this.onRefresh,
  });

  final ArenaPaymentsData data;
  final String month;
  final ArenaListing arena;
  final ValueChanged<String> onMonthChanged;
  final VoidCallback onRefresh;

  String _fmtMonth(String m) {
    final parts = m.split('-');
    return DateFormat('MMMM yyyy').format(DateTime(int.parse(parts[0]), int.parse(parts[1])));
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
    return month == '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  void _showBookingList(BuildContext context, String title, List<ArenaReservation> bookings, Color accent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _BookingListSheet(
        title: title,
        bookings: bookings,
        arena: arena,
        accent: accent,
        onRefresh: onRefresh,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Re-filter data to ensure PAID bookings move to the 'Collected' section immediately
    final unpaidBookings = data.pendingBookings.where((b) => !b.isPaid).toList();
    final collectedBookings = [
      ...data.checkedInBookings,
      ...data.pendingBookings.where((b) => b.isPaid),
    ];
    
    final collected = collectedBookings.fold(0, (sum, b) => sum + b.totalAmountPaise);
    final balance = unpaidBookings.fold(0, (sum, b) => sum + (b.totalAmountPaise - b.advancePaise));

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          // Month nav
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _NavBtn(icon: Icons.chevron_left_rounded, onTap: () => onMonthChanged(_prevMonth())),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border),
                ),
                child: Text(_fmtMonth(month),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _text)),
              ),
              const SizedBox(width: 12),
              _NavBtn(
                icon: Icons.chevron_right_rounded, 
                onTap: _isCurrentMonth ? null : () => onMonthChanged(_nextMonth()),
                disabled: _isCurrentMonth,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tappable summary cards
          Row(children: [
            _SummaryCard(
              label: 'Collected',
              paise: collected,
              count: collectedBookings.length,
              icon: Icons.check_circle_rounded,
              color: _accent,
              onTap: () => _showBookingList(
                context, 'Collected', collectedBookings, _accent),
            ),
            const SizedBox(width: 12),
            _SummaryCard(
              label: 'Balance due',
              paise: balance,
              count: unpaidBookings.length,
              icon: Icons.error_rounded,
              color: const Color(0xFFDC2626),
              onTap: () => _showBookingList(
                context, 'Balance Due', unpaidBookings, const Color(0xFFDC2626)),
            ),
          ]),
          const SizedBox(height: 28),

          // Pending check-ins (most actionable)
          if (unpaidBookings.isNotEmpty) ...[
            _SectionLabel('PENDING COLLECTION (${unpaidBookings.length})'),
            const SizedBox(height: 12),
            ...unpaidBookings.map((b) => _BookingRow(
              booking: b,
              arenaName: arena.name,
              arenaId: arena.id,
              onRefresh: onRefresh,
              showStatusBadge: true,
            )),
            const SizedBox(height: 24),
          ],

          // Checked-in bookings
          if (collectedBookings.isNotEmpty) ...[
            _SectionLabel('RECENTLY COLLECTED (${collectedBookings.length})'),
            const SizedBox(height: 12),
            ...collectedBookings.map((b) => _BookingRow(
              booking: b,
              arenaName: arena.name,
              arenaId: arena.id,
              onRefresh: onRefresh,
              showStatusBadge: false,
            )),
          ],

          if (collectedBookings.isEmpty && unpaidBookings.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: Text('No payment activity this month',
                    style: TextStyle(color: _muted, fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  const _NavBtn({required this.icon, required this.onTap, this.disabled = false});
  final IconData icon;
  final VoidCallback? onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _border),
        ),
        child: Icon(icon, color: disabled ? _border : _text, size: 20),
      ),
    );
  }
}

// ─── Summary card (tappable) ─────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.paise,
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String label;
  final int paise;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border),
            boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: color.withValues(alpha: .1), shape: BoxShape.circle),
                    child: Icon(icon, color: color, size: 16),
                  ),
                  if (count > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(10)),
                      child: Text('$count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text('₹${(paise / 100).toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _text, letterSpacing: -0.5)),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _muted, letterSpacing: 0.2)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Booking row (used in both collections list and booking list sheet) ───────

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
    final dateStr = booking.bookingDate != null
        ? DateFormat('EEE d MMM').format(booking.bookingDate!)
        : '—';
    final isPaid = booking.isPaid;
    final color = isPaid ? _accent : const Color(0xFFD97706);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
          builder: (_) => BookingDetailSheet(booking: booking, arenaName: arenaName, arenaId: arenaId),
        ).then((_) => onRefresh()),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border),
            boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4))],
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(booking.startTime,
                      style: const TextStyle(color: _text, fontSize: 15, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text(dateStr,
                      style: const TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(width: 16),
              Container(height: 36, width: 1, color: _border),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.displayName,
                        style: const TextStyle(color: _text, fontSize: 14, fontWeight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (booking.unitName != null) ...[
                          Text(booking.unitName!,
                              style: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                        ],
                        if (showStatusBadge)
                          _Badge(
                            isPaid ? 'Paid' : 'Unpaid',
                            color,
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
                      '₹${((isPaid ? booking.totalAmountPaise : (booking.totalAmountPaise - booking.advancePaise)) / 100).toStringAsFixed(0)}',
                      style: const TextStyle(color: _text, fontSize: 15, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  if (!isPaid)
                    const Text('DUE',
                        style: TextStyle(color: Color(0xFFDC2626), fontSize: 8, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFFD1D5DB), size: 18),
                ],
              ),
            ],
          ),
        ),
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
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5)),
  );
}

// ─── Booking list bottom sheet ────────────────────────────────────────────────

class _BookingListSheet extends StatelessWidget {
  const _BookingListSheet({
    required this.title,
    required this.bookings,
    required this.arena,
    required this.accent,
    required this.onRefresh,
  });
  final String title;
  final List<ArenaReservation> bookings;
  final ArenaListing arena;
  final Color accent;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (ctx, ctrl) => ListView(
        controller: ctrl,
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 24),
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Row(children: [
            Expanded(
              child: Text(title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF101828))),
            ),
            Text('${bookings.length} booking${bookings.length == 1 ? '' : 's'}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF667085))),
          ]),
          const SizedBox(height: 6),
          Text('₹${(bookings.fold(0, (s, b) => s + b.totalAmountPaise) / 100).toStringAsFixed(0)} total',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: accent)),
          const SizedBox(height: 16),
          if (bookings.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text('No bookings', style: TextStyle(color: Color(0xFF98A2B3)))),
            )
          else
            ...bookings.map((b) => _BookingRow(
              booking: b,
              arenaName: arena.name,
              arenaId: arena.id,
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
  const _CustomersTab({required this.arena});
  final ArenaListing arena;

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
    super.build(context);
    final key = _GuestKey(widget.arena.id, _search);
    final async = ref.watch(_arenaGuestsProvider(key));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _search = v),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _text),
            decoration: InputDecoration(
              hintText: 'Search by name or phone...',
              hintStyle: const TextStyle(color: _muted, fontWeight: FontWeight.w500),
              prefixIcon: const Icon(Icons.search_rounded, color: _muted, size: 20),
              suffixIcon: _search.isNotEmpty
                  ? GestureDetector(
                      onTap: () { _searchCtrl.clear(); setState(() => _search = ''); },
                      child: const Icon(Icons.close_rounded, color: _muted, size: 18))
                  : null,
              filled: true,
              fillColor: _bg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: _accent, width: 1.5)),
            ),
          ),
        ),
        Expanded(
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2, color: _accent)),
            error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: _muted))),
            data: (guests) {
              if (guests.isEmpty) {
                return _Empty(_search.isEmpty
                    ? 'No customers yet.\nWalk-in bookings appear here.'
                    : 'No results for "$_search".');
              }
              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(_arenaGuestsProvider(key)),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: guests.length,
                  itemBuilder: (ctx, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CustomerCard(
                      guest: guests[i],
                      arena: widget.arena,
                      onTap: () => _openCustomer(ctx, guests[i]),
                    ),
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _CustomerDetailSheet(guest: guest, arena: widget.arena),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.guest, required this.arena, required this.onTap});
  final ArenaGuest guest;
  final ArenaListing arena;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unpaidBookings = guest.recentBookings.where((b) => !b.isPaid && b.status != 'CANCELLED');
    final actualBalancePaise = unpaidBookings.fold(0, (sum, b) => sum + (b.totalAmountPaise - b.advancePaise));
    final hasBalance = actualBalancePaise > 0;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface, 
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border),
          boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: _text, borderRadius: BorderRadius.circular(16)),
            alignment: Alignment.center,
            child: Text(
              (guest.name.isNotEmpty ? guest.name[0] : '?').toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(guest.name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _text, letterSpacing: -0.2)),
              const SizedBox(height: 2),
              Text(guest.phone,
                  style: const TextStyle(fontSize: 12, color: _muted, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(children: [
                _Tag('${guest.totalBookings}'),
                const SizedBox(width: 8),
                _Tag('₹${(guest.totalSpentPaise / 100).toStringAsFixed(0)}'),
                if (hasBalance) ...[
                  const SizedBox(width: 8),
                  _Tag('₹${(actualBalancePaise / 100).toStringAsFixed(0)} DUE',
                      bg: const Color(0xFFFEF2F2), fg: const Color(0xFFDC2626)),
                ],
              ]),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFD1D5DB), size: 22),
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
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: bg ?? _bg,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: bg != null ? fg!.withValues(alpha: .1) : _border),
    ),
    child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: fg ?? _text, letterSpacing: 0.2)),
  );
}

// ─── Customer detail sheet ────────────────────────────────────────────────────

class _CustomerDetailSheet extends ConsumerStatefulWidget {
  const _CustomerDetailSheet({required this.guest, required this.arena});
  final ArenaGuest guest;
  final ArenaListing arena;

  @override
  ConsumerState<_CustomerDetailSheet> createState() => _CustomerDetailSheetState();
}

class _CustomerDetailSheetState extends ConsumerState<_CustomerDetailSheet> {
  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final guest = widget.guest;

    // Split bookings by check-in status
    final checkedIn = guest.recentBookings.where((b) => b.isPaid).toList();
    final pending = guest.recentBookings.where((b) => !b.isPaid && b.status != 'CANCELLED').toList();
    
    final actualBalancePaise = pending.fold(0, (sum, b) => sum + (b.totalAmountPaise - b.advancePaise));

    return Container(
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (ctx, ctrl) => ListView(
          controller: ctrl,
          padding: EdgeInsets.fromLTRB(20, 12, 20, bottom + 24),
          children: [
            Center(
              child: Container(
                width: 44, height: 5,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            
            // PROFILE HEADER
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: _text, 
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: _text.withValues(alpha: .2), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      (guest.name.isNotEmpty ? guest.name[0] : '?').toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 32),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(guest.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: _text, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text(guest.phone,
                      style: const TextStyle(fontSize: 15, color: _muted, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // STATS ROW
            Row(children: [
              _StatPill('Bookings', '${guest.totalBookings}', Icons.confirmation_number_rounded),
              const SizedBox(width: 12),
              _StatPill('Collected', '₹${(guest.totalSpentPaise / 100).toStringAsFixed(0)}', Icons.check_circle_rounded,
                  color: _accent),
              const SizedBox(width: 12),
              _StatPill('Balance', '₹${(actualBalancePaise / 100).toStringAsFixed(0)}', Icons.error_rounded,
                  highlight: actualBalancePaise > 0),
            ]),
            const SizedBox(height: 32),

            if (pending.isNotEmpty) ...[
              _SectionLabel('PENDING CHECK-IN (${pending.length})'),
              const SizedBox(height: 12),
              ...pending.map((b) => _BookingHistoryRow(
                booking: b, arena: widget.arena,
                onRefresh: () => ref.invalidate(_arenaGuestsProvider),
              )),
              const SizedBox(height: 24),
            ],

            if (checkedIn.isNotEmpty) ...[
              _SectionLabel('HISTORY (${checkedIn.length})'),
              const SizedBox(height: 12),
              ...checkedIn.map((b) => _BookingHistoryRow(
                booking: b, arena: widget.arena,
                onRefresh: () => ref.invalidate(_arenaGuestsProvider),
              )),
            ],

            if (guest.recentBookings.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text('No recent bookings found.',
                      style: TextStyle(color: _muted, fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill(this.label, this.value, this.icon, {this.highlight = false, this.color});
  final String label;
  final String value;
  final IconData icon;
  final bool highlight;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final fg = color ?? (highlight ? const Color(0xFFDC2626) : _text);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: highlight ? const Color(0xFFFCA5A5) : _border),
          boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: fg.withValues(alpha: .1), shape: BoxShape.circle),
            child: Icon(icon, color: fg, size: 14),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: fg, letterSpacing: -0.5)),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _muted, letterSpacing: 0.2)),
        ]),
      ),
    );
  }
}

class _BookingHistoryRow extends StatelessWidget {
  const _BookingHistoryRow({required this.booking, required this.arena, required this.onRefresh});
  final ArenaReservation booking;
  final ArenaListing arena;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final date = booking.bookingDate != null ? DateFormat('EEE d MMM').format(booking.bookingDate!) : '—';
    final isCheckedIn = booking.checkedInAt != null;
    final color = isCheckedIn ? _accent : const Color(0xFFD97706);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
          builder: (_) => BookingDetailSheet(booking: booking, arenaName: arena.name, arenaId: arena.id),
        ).then((_) => onRefresh()),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('$date · ${booking.startTime}–${booking.endTime}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _text)),
                const SizedBox(height: 4),
                Text(booking.unitName ?? '—',
                    style: const TextStyle(fontSize: 11, color: _muted, fontWeight: FontWeight.w600)),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('₹${(booking.totalAmountPaise / 100).toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: _text)),
              const SizedBox(height: 4),
              _Badge(
                isCheckedIn ? 'Checked in' : 'Pending',
                color,
              ),
            ]),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFD1D5DB), size: 18),
          ]),
        ),
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF344054), letterSpacing: 0.3));
}

class _Empty extends StatelessWidget {
  const _Empty(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Text(message, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Color(0xFF98A2B3), fontWeight: FontWeight.w500)),
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

String _moneyShort(int p) {
  final r = p / 100;
  if (r >= 1000) return '₹${(r / 1000).toStringAsFixed(1)}K';
  return '₹${r.toStringAsFixed(0)}';
}
