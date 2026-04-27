import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../data/player_booking_repository.dart';
import '../domain/booking_models.dart';

final bookingDetailProvider =
    FutureProvider.family<PlayerBooking, String>((ref, bookingId) {
  return ref
      .read(playerBookingRepositoryProvider)
      .fetchBookingDetail(bookingId);
});

class BookingDetailScreen extends ConsumerStatefulWidget {
  const BookingDetailScreen({super.key, required this.bookingId});
  final String bookingId;

  @override
  ConsumerState<BookingDetailScreen> createState() =>
      _BookingDetailScreenState();
}

class _BookingDetailScreenState extends ConsumerState<BookingDetailScreen> {
  late final Razorpay _razorpay;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingDetailProvider(widget.bookingId));
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        title: Text('Booking Detail',
            style: TextStyle(color: context.fg, fontWeight: FontWeight.w900)),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            ref.read(playerBookingRepositoryProvider).messageFor(error),
            style: TextStyle(color: context.fgSub),
          ),
        ),
        data: (booking) => ListView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 120 + MediaQuery.of(context).padding.bottom),
          children: [
            _HeroTile(booking: booking),
            if ((booking.status == 'CONFIRMED' ||
                    booking.status == 'CHECKED_IN') &&
                booking.otp.isNotEmpty) ...[
              const SizedBox(height: 14),
              _OtpTile(otp: booking.otp),
            ],
            const SizedBox(height: 14),
            _AmountTile(booking: booking),
            const SizedBox(height: 14),
            _TimelineTile(status: booking.status),
            const SizedBox(height: 20),
            if (booking.status == 'PENDING_PAYMENT')
              ElevatedButton(
                onPressed: _busy ? null : () => _completePayment(booking),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.accent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                ),
                child: Text(_busy ? 'Opening...' : 'Complete Payment'),
              ),
            if (booking.status == 'CONFIRMED')
              OutlinedButton(
                onPressed: _busy ? null : () => _cancelBooking(booking),
                child: const Text('Cancel Booking'),
              ),
            if (booking.status == 'CANCELLED')
              ElevatedButton(
                onPressed: booking.arenaId.isEmpty
                    ? null
                    : () => context.push('/arena-booking/${booking.arenaId}'),
                child: const Text('Book Again'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _completePayment(PlayerBooking booking) async {
    setState(() => _busy = true);
    try {
      final order = await ref
          .read(playerBookingRepositoryProvider)
          .createPaymentOrder(booking.id);
      _razorpay.open({
        'key': order.key,
        'amount': order.amountPaise,
        'currency': order.currency,
        'name': 'Swing Arena Booking',
        'description': booking.arenaName ?? 'Arena booking',
        'order_id': order.orderId,
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      _showSnack(ref.read(playerBookingRepositoryProvider).messageFor(error));
    }
  }

  Future<void> _cancelBooking(PlayerBooking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel booking?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _busy = true);
    try {
      await ref.read(playerBookingRepositoryProvider).cancelBooking(booking.id);
      ref.invalidate(bookingDetailProvider(widget.bookingId));
    } catch (error) {
      _showSnack(ref.read(playerBookingRepositoryProvider).messageFor(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final booking =
          await ref.read(playerBookingRepositoryProvider).verifyPayment(
                bookingId: widget.bookingId,
                razorpayPaymentId: response.paymentId ?? '',
                razorpayOrderId: response.orderId ?? '',
                razorpaySignature: response.signature ?? '',
              );
      if (!mounted) return;
      context.go('/booking/success', extra: booking);
    } catch (error) {
      _showSnack(ref.read(playerBookingRepositoryProvider).messageFor(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    if (mounted) setState(() => _busy = false);
    _showSnack(response.message ?? 'Payment was not completed.');
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    _showSnack('${response.walletName ?? 'Wallet'} selected');
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _HeroTile extends StatelessWidget {
  const _HeroTile({required this.booking});
  final PlayerBooking booking;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusPill(status: booking.status),
          const SizedBox(height: 14),
          Text(booking.arenaName ?? 'Arena',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: context.fg,
                  fontSize: 22,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(
            '${booking.unitName ?? 'Unit'} • ${DateFormat('EEEE, d MMM yyyy').format(booking.date)} • ${booking.startTime}-${booking.endTime}',
            style: TextStyle(
                color: context.fgSub,
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _OtpTile extends StatelessWidget {
  const _OtpTile({required this.otp});
  final String otp;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Check-in OTP',
              style:
                  TextStyle(color: context.fgSub, fontWeight: FontWeight.w700)),
          Text(otp,
              style: TextStyle(
                  color: context.accent,
                  fontSize: 30,
                  fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _AmountTile extends StatelessWidget {
  const _AmountTile({required this.booking});
  final PlayerBooking booking;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        children: [
          _Row('Base amount', _currency(booking.baseAmountPaise)),
          _Row('Addons', _currency(booking.addonAmountPaise)),
          if (booking.addonNames.isNotEmpty)
            _Row('Addon names', booking.addonNames.join(', ')),
          _Row('GST', _currency(booking.gstPaise)),
          _Row('Payment mode', booking.paymentMode ?? '-'),
          const Divider(height: 24),
          _Row('Total', _currency(booking.totalAmountPaise), strong: true),
        ],
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final stages = ['Booked', 'Confirmed', 'Checked In'];
    final active = switch (status) {
      'CHECKED_IN' => 3,
      'CONFIRMED' => 2,
      'PENDING_PAYMENT' => 1,
      _ => 0,
    };
    return _Panel(
      child: Row(
        children: [
          for (var i = 0; i < stages.length; i++) ...[
            Icon(
              i < active ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: i < active ? context.accent : context.fgSub,
              size: 18,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(stages[i],
                  style: TextStyle(
                      color: context.fg,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.stroke.withValues(alpha: 0.35)),
      ),
      child: child,
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.strong = false});
  final String label, value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: context.fgSub,
                  fontWeight: strong ? FontWeight.w900 : FontWeight.w600)),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: TextStyle(
                    color: context.fg,
                    fontWeight: strong ? FontWeight.w900 : FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
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
    return Text(status,
        style:
            TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w900));
  }
}

String _currency(int paise) => '₹${(paise / 100).toStringAsFixed(0)}';
