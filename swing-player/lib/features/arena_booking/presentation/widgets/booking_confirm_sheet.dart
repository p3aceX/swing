import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/arena_slots_models.dart';

class BookingConfirmSheet extends StatelessWidget {
  const BookingConfirmSheet({
    super.key,
    required this.arena,
    required this.group,
    required this.slot,
    required this.date,
    required this.durationMins,
    required this.loading,
    required this.onConfirm,
    this.selectedNetType,
  });

  final ArenaInfo arena;
  final UnitGroupSlots group;
  final AvailableSlot slot;
  final DateTime date;
  final int durationMins;
  final bool loading;
  final VoidCallback onConfirm;
  final String? selectedNetType;

  @override
  Widget build(BuildContext context) {
    // For net bookings, use the type-specific amount if a type was selected
    final effectiveAmountPaise = (group.isNetGroup && selectedNetType != null)
        ? (slot.netTypeOptions
                .where((o) => o.netType == selectedNetType)
                .map((o) => o.totalAmountPaise)
                .firstOrNull ??
            slot.totalAmountPaise)
        : slot.totalAmountPaise;

    final payNowPaise = group.minAdvancePaise > 0
        ? group.minAdvancePaise
        : effectiveAmountPaise;
    final remainingPaise =
        (effectiveAmountPaise - payNowPaise).clamp(0, effectiveAmountPaise);
    final cancelUntil = DateTime(
      date.year,
      date.month,
      date.day,
      _hour(slot.startTime),
      _minute(slot.startTime),
    ).subtract(Duration(hours: arena.cancellationHours));
    final basePaise = _basePaise(effectiveAmountPaise, slot, group);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.stroke.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            // Header
            Text(
              arena.name,
              style: TextStyle(
                color: context.fg,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              [
              DateFormat('EEE, d MMM').format(date),
              if (selectedNetType != null) '$selectedNetType Net' else group.displayName,
            ].join(' · '),
              style: TextStyle(
                color: context.fgSub,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 22),
            // Detail rows
            _Row('Time', '${slot.startTime} – ${slot.endTime}'),
            _Row('Duration', _formatDuration(durationMins)),
            _gap(),
            _Row('Base price', _currency(basePaise)),
            if (slot.isWeekendRate)
              _Row(
                'Weekend rate',
                '+${((group.weekendMultiplier - 1) * 100).round()}%',
                accent: context.warn,
              ),
            _Row('Total', _currency(effectiveAmountPaise), strong: true),
            _gap(),
            // Payment
            if (group.minAdvancePaise > 0) ...[
              _Row(
                'Pay now',
                _currency(payNowPaise),
                strong: true,
                accent: context.accent,
              ),
              _Row(
                'At venue',
                _currency(remainingPaise),
              ),
            ] else
              _Row(
                'Full payment',
                _currency(slot.totalAmountPaise),
                strong: true,
              ),
            const SizedBox(height: 10),
            // Cancellation
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 13,
                    color: context.fgSub.withValues(alpha: 0.6)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Cancel free before ${DateFormat('HH:mm, d MMM').format(cancelUntil)}',
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // CTA
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: loading ? null : onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'Pay ${_currency(payNowPaise)} & Confirm',
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.strong = false, this.accent});

  final String label, value;
  final bool strong;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 13,
              fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: accent ?? context.fg,
              fontSize: strong ? 15 : 13,
              fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _gap() => const SizedBox(height: 4);

int _basePaise(int totalAmountPaise, AvailableSlot slot, UnitGroupSlots group) {
  if (!slot.isWeekendRate || group.weekendMultiplier <= 1) {
    return totalAmountPaise;
  }
  return (totalAmountPaise / group.weekendMultiplier).round();
}

String _formatDuration(int mins) {
  if (mins < 60) return '${mins}min';
  final h = mins ~/ 60;
  final m = mins % 60;
  return m == 0 ? '${h}h' : '${h}h ${m}min';
}

int _hour(String time) => int.tryParse(time.split(':').first) ?? 0;

int _minute(String time) {
  final parts = time.split(':');
  return parts.length < 2 ? 0 : (int.tryParse(parts[1]) ?? 0);
}

String _currency(int paise) => '₹${(paise / 100).toStringAsFixed(0)}';
