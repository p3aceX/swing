import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../data/player_booking_repository.dart';
import '../domain/booking_models.dart';

final myBookingsProvider =
    FutureProvider.family<List<PlayerBooking>, String>((ref, status) {
  return ref
      .read(playerBookingRepositoryProvider)
      .fetchMyBookings(status: status);
});

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          backgroundColor: context.bg,
          elevation: 0,
          title: Text(
            'My Bookings',
            style: TextStyle(color: context.fg, fontWeight: FontWeight.w900),
          ),
          bottom: TabBar(
            indicatorColor: context.accent,
            labelColor: context.fg,
            unselectedLabelColor: context.fgSub,
            tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Past')],
          ),
        ),
        body: const TabBarView(
          children: [
            _BookingsList(status: 'upcoming'),
            _BookingsList(status: 'past'),
          ],
        ),
      ),
    );
  }
}

class _BookingsList extends ConsumerWidget {
  const _BookingsList({required this.status});
  final String status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myBookingsProvider(status));
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          ref.read(playerBookingRepositoryProvider).messageFor(error),
          style: TextStyle(color: context.fgSub),
        ),
      ),
      data: (bookings) {
        if (bookings.isEmpty) {
          return Center(
            child: Text('No $status bookings.',
                style: TextStyle(color: context.fgSub)),
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(myBookingsProvider(status).future),
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 120 + MediaQuery.of(context).padding.bottom),
            itemCount: bookings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _BookingCard(
              booking: bookings[index],
              upcoming: status == 'upcoming',
            ),
          ),
        );
      },
    );
  }
}

class _BookingCard extends ConsumerWidget {
  const _BookingCard({required this.booking, required this.upcoming});
  final PlayerBooking booking;
  final bool upcoming;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final confirmed = booking.status == 'CONFIRMED';
    return InkWell(
      onTap: () => context.push('/bookings/${booking.id}'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.stroke.withOpacity(0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    booking.arenaName ?? 'Arena',
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _StatusBadge(status: booking.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${booking.unitName ?? 'Unit'} • ${DateFormat('d MMM').format(booking.date)} • ${booking.startTime}-${booking.endTime}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.fgSub,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  _currency(booking.totalAmountPaise),
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                if (upcoming && confirmed && booking.otp.isNotEmpty)
                  Text(
                    'OTP ${booking.otp}',
                    style: TextStyle(
                      color: context.accent,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
              ],
            ),
            if (upcoming && confirmed) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () async {
                  final repo = ref.read(playerBookingRepositoryProvider);
                  try {
                    await repo.cancelBooking(booking.id);
                    ref.invalidate(myBookingsProvider);
                  } catch (error) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(repo.messageFor(error))),
                    );
                  }
                },
                child: const Text('Cancel'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'CONFIRMED' => const Color(0xFF16A34A),
      'PENDING_PAYMENT' => const Color(0xFFF59E0B),
      'CANCELLED' => const Color(0xFFDC2626),
      'CHECKED_IN' => const Color(0xFF2563EB),
      _ => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900),
      ),
    );
  }
}

String _currency(int paise) => '₹${(paise / 100).toStringAsFixed(0)}';
