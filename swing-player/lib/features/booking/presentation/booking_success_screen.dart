import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/booking_models.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({
    super.key,
    required this.arena,
    required this.unit,
    required this.date,
    required this.slot,
    required this.total,
    required this.otp,
  });

  final ArenaListing arena;
  final ArenaUnitOption unit;
  final DateTime date;
  final AvailabilitySlot slot;
  final double total;
  final String otp;

  @override
  Widget build(BuildContext context) {
    final subtotal = total / 1.18;
    final tax = total - subtotal;
    final refNo = 'SW-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: context.fg),
          onPressed: () => context.go('/home'),
        ),
        title: Text('Booking Details', style: TextStyle(color: context.fg, fontWeight: FontWeight.w800, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            _TicketWidget(
              arena: arena,
              unit: unit,
              date: date,
              slot: slot,
              otp: otp,
              refNo: refNo,
              subtotal: subtotal,
              tax: tax,
              total: total,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.accent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Go to Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketWidget extends StatelessWidget {
  const _TicketWidget({
    required this.arena,
    required this.unit,
    required this.date,
    required this.slot,
    required this.otp,
    required this.refNo,
    required this.subtotal,
    required this.tax,
    required this.total,
  });

  final ArenaListing arena;
  final ArenaUnitOption unit;
  final DateTime date;
  final AvailabilitySlot slot;
  final String otp, refNo;
  final double subtotal, tax, total;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF84CC16), borderRadius: BorderRadius.circular(6)),
                      child: const Text('ACTIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                    ),
                    Icon(Icons.ios_share_rounded, color: Colors.grey.shade400, size: 20),
                  ],
                ),
                const SizedBox(height: 20),
                Text(arena.name, style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Text(arena.address, style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                const Text('directions', style: TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          _DottedDivider(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    _InfoBlock(label: 'Date', value: DateFormat('dd-MM-yyyy').format(date)),
                    _InfoBlock(label: 'Time', value: slot.startTime),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _InfoBlock(label: 'Unit', value: unit.name),
                    _InfoBlock(label: 'Verification OTP', value: otp, valueColor: context.accent),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _InfoBlock(label: 'Ref #', value: refNo),
                    _InfoBlock(label: 'Status', value: 'Confirmed'),
                  ],
                ),
                const SizedBox(height: 32),
                const Divider(height: 1),
                const SizedBox(height: 20),
                _PriceRow(label: 'Subtotal', value: '₹${subtotal.toStringAsFixed(0)}'),
                _PriceRow(label: 'Discount (SWINGZERO)', value: '-₹${tax.toStringAsFixed(0)}', isDiscount: true),
                _PriceRow(label: 'Tax (18%)', value: '₹${tax.toStringAsFixed(0)}'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900)),
                    Text('₹${subtotal.toStringAsFixed(0)}', style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.label, required this.value, this.valueColor});
  final String label, value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: valueColor ?? Colors.black, fontSize: 16, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.value, this.isDiscount = false});
  final String label, value;
  final bool isDiscount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDiscount ? context.accent : Colors.grey.shade600, fontSize: 14, fontWeight: isDiscount ? FontWeight.w700 : FontWeight.w500)),
          Text(value, style: TextStyle(color: isDiscount ? context.accent : Colors.black87, fontSize: 14, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _DottedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SemiCircle(isLeft: true),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    (constraints.constrainWidth() / 8).floor(),
                    (index) => SizedBox(width: 4, height: 1, child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey.shade300))),
                  ),
                );
              },
            ),
          ),
        ),
        _SemiCircle(isLeft: false),
      ],
    );
  }
}

class _SemiCircle extends StatelessWidget {
  const _SemiCircle({required this.isLeft});
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 24,
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: BorderRadius.only(
          topRight: isLeft ? const Radius.circular(12) : Radius.zero,
          bottomRight: isLeft ? const Radius.circular(12) : Radius.zero,
          topLeft: !isLeft ? const Radius.circular(12) : Radius.zero,
          bottomLeft: !isLeft ? const Radius.circular(12) : Radius.zero,
        ),
      ),
    );
  }
}
