import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../arena/services/arena_profile_providers.dart';
import '../../bookings/presentation/bookings_page.dart';

// ─── Providers ───────────────────────────────────────────────────────────────

final _crmArenaProvider = StateProvider<String?>((ref) => null);

final _crmSearchProvider = StateProvider<String>((ref) => '');

class _GuestsKey {
  const _GuestsKey(this.arenaId, this.search);
  final String arenaId;
  final String search;
  @override
  bool operator ==(Object other) =>
      other is _GuestsKey && arenaId == other.arenaId && search == other.search;
  @override
  int get hashCode => Object.hash(arenaId, search);
}

final _guestsProvider = FutureProvider.autoDispose
    .family<List<ArenaGuest>, _GuestsKey>((ref, key) async {
  final repo = ref.watch(hostArenaBookingRepositoryProvider);
  return repo.fetchArenaGuests(key.arenaId, search: key.search.isEmpty ? null : key.search);
});

// ─── Page ─────────────────────────────────────────────────────────────────────

class CrmPage extends ConsumerWidget {
  const CrmPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arenasAsync = ref.watch(ownedArenasProvider);
    return arenasAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (arenas) {
        if (arenas.isEmpty) {
          return const _Empty(message: 'No arenas yet.');
        }
        final selectedId = ref.watch(_crmArenaProvider) ?? arenas.first.id;
        final arena = arenas.firstWhere((a) => a.id == selectedId, orElse: () => arenas.first);
        return _CrmBody(arena: arena, arenas: arenas, selectedId: selectedId);
      },
    );
  }
}

class _CrmBody extends ConsumerStatefulWidget {
  const _CrmBody({required this.arena, required this.arenas, required this.selectedId});
  final ArenaListing arena;
  final List<ArenaListing> arenas;
  final String selectedId;

  @override
  ConsumerState<_CrmBody> createState() => _CrmBodyState();
}

class _CrmBodyState extends ConsumerState<_CrmBody> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final search = ref.watch(_crmSearchProvider);
    final guestsAsync = ref.watch(_guestsProvider(_GuestsKey(widget.arena.id, search)));

    return Container(
      color: const Color(0xFFF3F4F6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Customers',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF101828))),
                const SizedBox(height: 4),
                Text('Walk-in & offline booking guests',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF667085), fontWeight: FontWeight.w500)),
                const SizedBox(height: 14),

                // Arena picker (if multiple)
                if (widget.arenas.length > 1) ...[
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.arenas.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final a = widget.arenas[i];
                        final sel = a.id == widget.selectedId;
                        return GestureDetector(
                          onTap: () => ref.read(_crmArenaProvider.notifier).state = a.id,
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
                  ),
                  const SizedBox(height: 12),
                ],

                // Search bar
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => ref.read(_crmSearchProvider.notifier).state = v,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF101828)),
                  decoration: InputDecoration(
                    hintText: 'Search by name or phone...',
                    hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontWeight: FontWeight.w400),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF98A2B3), size: 20),
                    suffixIcon: search.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchCtrl.clear();
                              ref.read(_crmSearchProvider.notifier).state = '';
                            },
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
                const SizedBox(height: 16),
              ],
            ),
          ),

          // ── Guest list ──
          Expanded(
            child: guestsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: Color(0xFF667085)))),
              data: (guests) {
                if (guests.isEmpty) {
                  return _Empty(
                    icon: Icons.people_outline_rounded,
                    message: search.isEmpty
                        ? 'No customers yet.\nWalk-in bookings will appear here.'
                        : 'No results found.',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(_guestsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                    itemCount: guests.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) => _GuestCard(
                      guest: guests[i],
                      arena: widget.arena,
                      onTap: () => _openDetail(ctx, guests[i]),
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

  void _openDetail(BuildContext context, ArenaGuest guest) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _GuestDetailSheet(guest: guest, arena: widget.arena),
    );
  }
}

// ─── Guest card ───────────────────────────────────────────────────────────────

class _GuestCard extends StatelessWidget {
  const _GuestCard({required this.guest, required this.arena, required this.onTap});
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF101828),
                borderRadius: BorderRadius.circular(22),
              ),
              alignment: Alignment.center,
              child: Text(
                (guest.name.isNotEmpty ? guest.name[0] : '?').toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(guest.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF101828))),
                  const SizedBox(height: 2),
                  Text(guest.phone,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF667085), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Row(children: [
                    _Chip('${guest.totalBookings} booking${guest.totalBookings == 1 ? '' : 's'}'),
                    const SizedBox(width: 6),
                    _Chip('₹${(guest.totalSpentPaise / 100).toStringAsFixed(0)} total'),
                    if (hasBalance) ...[
                      const SizedBox(width: 6),
                      _Chip('₹${(guest.balanceDuePaise / 100).toStringAsFixed(0)} due',
                          color: const Color(0xFFFEF2F2), textColor: const Color(0xFFDC2626)),
                    ],
                  ]),
                ],
              ),
            ),

            // Last date + arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (guest.lastDate != null)
                  Text(
                    DateFormat('d MMM').format(guest.lastDate!),
                    style: const TextStyle(fontSize: 11, color: Color(0xFF98A2B3), fontWeight: FontWeight.w600),
                  ),
                const SizedBox(height: 4),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFFD1D5DB), size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, {this.color, this.textColor});
  final String label;
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color ?? const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textColor ?? const Color(0xFF344054))),
    );
  }
}

// ─── Guest detail sheet ───────────────────────────────────────────────────────

class _GuestDetailSheet extends ConsumerStatefulWidget {
  const _GuestDetailSheet({required this.guest, required this.arena});
  final ArenaGuest guest;
  final ArenaListing arena;

  @override
  ConsumerState<_GuestDetailSheet> createState() => _GuestDetailSheetState();
}

class _GuestDetailSheetState extends ConsumerState<_GuestDetailSheet> {
  bool _refreshing = false;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final guest = widget.guest;
    final totalRs = (guest.totalSpentPaise / 100).toStringAsFixed(0);
    final balanceRs = (guest.balanceDuePaise / 100).toStringAsFixed(0);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (ctx, ctrl) => ListView(
        controller: ctrl,
        padding: EdgeInsets.fromLTRB(20, 16, 20, bottom + 24),
        children: [
          // Handle
          Center(
            child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)),
            ),
          ),

          // ── Guest header ──
          Row(children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(color: const Color(0xFF101828), borderRadius: BorderRadius.circular(26)),
              alignment: Alignment.center,
              child: Text(
                (guest.name.isNotEmpty ? guest.name[0] : '?').toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(guest.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF101828))),
                const SizedBox(height: 2),
                Text(guest.phone,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF667085), fontWeight: FontWeight.w500)),
              ]),
            ),
          ]),
          const SizedBox(height: 20),

          // ── Stats row ──
          Row(children: [
            _StatBox('Total bookings', '${guest.totalBookings}'),
            const SizedBox(width: 8),
            _StatBox('Total spent', '₹$totalRs'),
            const SizedBox(width: 8),
            _StatBox('Balance due', '₹$balanceRs',
                highlight: guest.balanceDuePaise > 0),
          ]),
          const SizedBox(height: 20),

          // ── Booking history ──
          const Text('Booking history',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF344054))),
          const SizedBox(height: 10),
          if (guest.recentBookings.isEmpty)
            const Text('No bookings found.',
                style: TextStyle(color: Color(0xFF98A2B3), fontSize: 13))
          else
            ...guest.recentBookings.map((b) => _HistoryRow(booking: b, arena: widget.arena, onRefresh: _refresh)),
        ],
      ),
    );
  }

  Future<void> _refresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    ref.invalidate(_guestsProvider);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() => _refreshing = false);
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox(this.label, this.value, {this.highlight = false});
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: highlight ? const Color(0xFFFEF2F2) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: highlight ? const Color(0xFFFCA5A5) : const Color(0xFFE5E7EB)),
        ),
        child: Column(children: [
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800,
                  color: highlight ? const Color(0xFFDC2626) : const Color(0xFF101828))),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF667085))),
        ]),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.booking, required this.arena, required this.onRefresh});
  final ArenaReservation booking;
  final ArenaListing arena;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final date = booking.bookingDate != null
        ? DateFormat('EEE d MMM').format(booking.bookingDate!)
        : '—';
    final balancePaise = booking.balancePaise;
    final hasBalance = balancePaise > 0;

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
          // Date column
          SizedBox(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF101828))),
                Text('${booking.startTime} – ${booking.endTime}',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF667085))),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Unit
          Expanded(
            child: Text(booking.unitName ?? '—',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF344054))),
          ),
          // Amount + balance
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('₹${(booking.totalAmountPaise / 100).toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF101828))),
            if (hasBalance)
              Text('₹${(balancePaise / 100).toStringAsFixed(0)} due',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFDC2626))),
          ]),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFD1D5DB), size: 18),
        ]),
      ),
    );
  }
}

// ─── Empty state ─────────────────────────────────────────────────────────────

class _Empty extends StatelessWidget {
  const _Empty({this.icon = Icons.people_outline_rounded, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 48, color: const Color(0xFFD0D5DD)),
          const SizedBox(height: 16),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF667085), fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}
