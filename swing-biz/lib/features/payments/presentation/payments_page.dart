import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../arena/services/arena_profile_providers.dart';
import '../../bookings/presentation/bookings_page.dart';

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
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Payments',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF101828))),
                      if (arenas.length > 1) ...[
                        const SizedBox(height: 12),
                        Consumer(builder: (ctx, ref, _) => SizedBox(
                          height: 36,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: arenas.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (_, i) {
                              final a = arenas[i];
                              final sel = a.id == selectedId;
                              return GestureDetector(
                                onTap: () => ref.read(_payArenaProvider.notifier).state = a.id,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: sel ? const Color(0xFF101828) : const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: sel ? const Color(0xFF101828) : const Color(0xFFE5E7EB)),
                                  ),
                                  child: Text(a.name,
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                                          color: sel ? Colors.white : const Color(0xFF344054))),
                                ),
                              );
                            },
                          ),
                        )),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const TabBar(
                  labelColor: Color(0xFF101828),
                  unselectedLabelColor: Color(0xFF98A2B3),
                  labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  unselectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  indicatorColor: Color(0xFF101828),
                  indicatorWeight: 2,
                  tabs: [Tab(text: 'Collections'), Tab(text: 'Customers')],
                ),
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

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: Color(0xFF667085)))),
      data: (data) => _CollectionsList(
        data: data,
        month: _month,
        arena: widget.arena,
        onMonthChanged: (m) => setState(() => _month = m),
        onRefresh: () => ref.invalidate(_arenaPaymentsProvider(key)),
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
    final collected = data.totalCollectedPaise;
    final balance = data.totalBalancePaise;

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          // Month nav
          Row(children: [
            GestureDetector(
              onTap: () => onMonthChanged(_prevMonth()),
              child: const Icon(Icons.chevron_left_rounded, color: Color(0xFF344054)),
            ),
            Expanded(
              child: Text(_fmtMonth(month),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF101828))),
            ),
            GestureDetector(
              onTap: _isCurrentMonth ? null : () => onMonthChanged(_nextMonth()),
              child: Icon(Icons.chevron_right_rounded,
                  color: _isCurrentMonth ? const Color(0xFFD1D5DB) : const Color(0xFF344054)),
            ),
          ]),
          const SizedBox(height: 14),

          // Tappable summary cards
          Row(children: [
            _SummaryCard(
              label: 'Collected',
              paise: collected,
              count: data.checkedInBookings.length,
              icon: Icons.check_circle_outline_rounded,
              positive: true,
              onTap: () => _showBookingList(
                context, 'Collected', data.checkedInBookings, const Color(0xFF059669)),
            ),
            const SizedBox(width: 10),
            _SummaryCard(
              label: 'Balance due',
              paise: balance,
              count: data.pendingBookings.length,
              icon: Icons.pending_outlined,
              positive: false,
              onTap: () => _showBookingList(
                context, 'Balance Due', data.pendingBookings, const Color(0xFFDC2626)),
            ),
          ]),
          const SizedBox(height: 20),

          // Pending check-ins (most actionable)
          if (data.pendingBookings.isNotEmpty) ...[
            _SectionLabel('Pending check-in (${data.pendingBookings.length})'),
            const SizedBox(height: 8),
            ...data.pendingBookings.map((b) => _BookingRow(
              booking: b,
              arenaId: arena.id,
              onRefresh: onRefresh,
              showCheckinBadge: true,
            )),
            const SizedBox(height: 16),
          ],

          // Checked-in bookings
          if (data.checkedInBookings.isNotEmpty) ...[
            _SectionLabel('Checked in (${data.checkedInBookings.length})'),
            const SizedBox(height: 8),
            ...data.checkedInBookings.map((b) => _BookingRow(
              booking: b,
              arenaId: arena.id,
              onRefresh: onRefresh,
              showCheckinBadge: false,
            )),
          ],

          if (data.checkedInBookings.isEmpty && data.pendingBookings.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text('No bookings this month',
                    style: TextStyle(color: Color(0xFF98A2B3), fontSize: 14)),
              ),
            ),
        ],
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
    required this.positive,
    required this.onTap,
  });
  final String label;
  final int paise;
  final int count;
  final IconData icon;
  final bool positive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = positive ? const Color(0xFF059669) : const Color(0xFFDC2626);
    final bg = positive ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(icon, size: 16, color: color),
              const Spacer(),
              if (count > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(10)),
                  child: Text('$count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
                ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, size: 14, color: color.withAlpha(128)),
            ]),
            const SizedBox(height: 8),
            Text('₹${(paise / 100).toStringAsFixed(0)}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF667085))),
          ]),
        ),
      ),
    );
  }
}

// ─── Booking row (used in both collections list and booking list sheet) ───────

class _BookingRow extends StatelessWidget {
  const _BookingRow({
    required this.booking,
    required this.arenaId,
    required this.onRefresh,
    this.showCheckinBadge = true,
  });
  final ArenaReservation booking;
  final String arenaId;
  final VoidCallback onRefresh;
  final bool showCheckinBadge;

  @override
  Widget build(BuildContext context) {
    final dateStr = booking.bookingDate != null
        ? DateFormat('EEE d MMM').format(booking.bookingDate!)
        : '—';
    final isCheckedIn = booking.checkedInAt != null;

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => BookingDetailSheet(booking: booking, arenaId: arenaId),
      ).then((_) => onRefresh()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(booking.displayName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF101828))),
              const SizedBox(height: 2),
              Text('${booking.unitName ?? ''} · $dateStr · ${booking.startTime}–${booking.endTime}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF667085))),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('₹${(booking.totalAmountPaise / 100).toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF101828))),
            const SizedBox(height: 4),
            if (showCheckinBadge)
              _Badge(isCheckedIn ? 'Checked in' : 'Pending',
                  isCheckedIn ? const Color(0xFF059669) : const Color(0xFFD97706))
            else
              _Badge('Checked in', const Color(0xFF059669)),
          ]),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFD1D5DB), size: 18),
        ]),
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
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: color.withAlpha(25),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
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
              arenaId: arena.id,
              onRefresh: onRefresh,
              showCheckinBadge: true,
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
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _search = v),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF101828)),
            decoration: InputDecoration(
              hintText: 'Search by name or phone...',
              hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF98A2B3), size: 20),
              suffixIcon: _search.isNotEmpty
                  ? GestureDetector(
                      onTap: () { _searchCtrl.clear(); setState(() => _search = ''); },
                      child: const Icon(Icons.close_rounded, color: Color(0xFF98A2B3), size: 18))
                  : null,
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF101828), width: 1.5)),
            ),
          ),
        ),
        Expanded(
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: Color(0xFF667085)))),
            data: (guests) {
              if (guests.isEmpty) {
                return _Empty(_search.isEmpty
                    ? 'No customers yet.\nWalk-in bookings appear here.'
                    : 'No results for "$_search".');
              }
              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(_arenaGuestsProvider(key)),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: guests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) => _CustomerCard(
                    guest: guests[i],
                    arena: widget.arena,
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
    final hasBalance = guest.balanceDuePaise > 0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: const Color(0xFF101828), borderRadius: BorderRadius.circular(21)),
            alignment: Alignment.center,
            child: Text(
              (guest.name.isNotEmpty ? guest.name[0] : '?').toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(guest.name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF101828))),
              const SizedBox(height: 2),
              Text(guest.phone,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF667085))),
              const SizedBox(height: 5),
              Row(children: [
                _Tag('${guest.totalBookings} booking${guest.totalBookings == 1 ? '' : 's'}'),
                const SizedBox(width: 6),
                _Tag('₹${(guest.totalSpentPaise / 100).toStringAsFixed(0)} collected'),
                if (hasBalance) ...[
                  const SizedBox(width: 6),
                  _Tag('₹${(guest.balanceDuePaise / 100).toStringAsFixed(0)} due',
                      bg: const Color(0xFFFEF2F2), fg: const Color(0xFFDC2626)),
                ],
              ]),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            if (guest.lastDate != null)
              Text(DateFormat('d MMM').format(guest.lastDate!),
                  style: const TextStyle(fontSize: 11, color: Color(0xFF98A2B3), fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFD1D5DB), size: 20),
          ]),
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
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: bg ?? const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg ?? const Color(0xFF344054))),
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
    final checkedIn = guest.recentBookings.where((b) => b.checkedInAt != null).toList();
    final pending = guest.recentBookings.where((b) => b.checkedInAt == null).toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (ctx, ctrl) => ListView(
        controller: ctrl,
        padding: EdgeInsets.fromLTRB(20, 16, 20, bottom + 24),
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Row(children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: const Color(0xFF101828), borderRadius: BorderRadius.circular(25)),
              alignment: Alignment.center,
              child: Text(
                (guest.name.isNotEmpty ? guest.name[0] : '?').toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(guest.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF101828))),
                Text(guest.phone,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF667085))),
              ]),
            ),
          ]),
          const SizedBox(height: 18),

          Row(children: [
            _StatPill('Bookings', '${guest.totalBookings}'),
            const SizedBox(width: 8),
            _StatPill('Collected', '₹${(guest.totalSpentPaise / 100).toStringAsFixed(0)}',
                color: const Color(0xFF059669)),
            const SizedBox(width: 8),
            _StatPill('Balance', '₹${(guest.balanceDuePaise / 100).toStringAsFixed(0)}',
                highlight: guest.balanceDuePaise > 0),
          ]),
          const SizedBox(height: 20),

          if (pending.isNotEmpty) ...[
            const Text('Pending check-in',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF344054))),
            const SizedBox(height: 8),
            ...pending.map((b) => _BookingHistoryRow(
              booking: b, arena: widget.arena,
              onRefresh: () => ref.invalidate(_arenaGuestsProvider),
            )),
            const SizedBox(height: 16),
          ],

          if (checkedIn.isNotEmpty) ...[
            const Text('Checked in',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF344054))),
            const SizedBox(height: 8),
            ...checkedIn.map((b) => _BookingHistoryRow(
              booking: b, arena: widget.arena,
              onRefresh: () => ref.invalidate(_arenaGuestsProvider),
            )),
          ],

          if (guest.recentBookings.isEmpty)
            const Text('No bookings found.',
                style: TextStyle(color: Color(0xFF98A2B3), fontSize: 13)),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill(this.label, this.value, {this.highlight = false, this.color});
  final String label;
  final String value;
  final bool highlight;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final fg = color ?? (highlight ? const Color(0xFFDC2626) : const Color(0xFF101828));
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: highlight ? const Color(0xFFFEF2F2) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: highlight ? const Color(0xFFFCA5A5) : const Color(0xFFE5E7EB)),
        ),
        child: Column(children: [
          Text(value,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: fg)),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF667085))),
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

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => BookingDetailSheet(booking: booking, arenaId: arena.id),
      ).then((_) => onRefresh()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$date · ${booking.startTime}–${booking.endTime}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF101828))),
              const SizedBox(height: 2),
              Text(booking.unitName ?? '—',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF667085))),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('₹${(booking.totalAmountPaise / 100).toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF101828))),
            const SizedBox(height: 3),
            _Badge(
              isCheckedIn ? 'Checked in' : 'Pending',
              isCheckedIn ? const Color(0xFF059669) : const Color(0xFFD97706),
            ),
          ]),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFD1D5DB), size: 18),
        ]),
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
