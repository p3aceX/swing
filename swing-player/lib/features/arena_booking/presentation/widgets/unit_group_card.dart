import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart' show ArenaUnitOption;

import '../../../../core/theme/app_colors.dart';
import '../../domain/arena_slots_models.dart';
import '../../domain/player_booking_types.dart';

/// Legacy card for old booking screens that use [UnitGroupSlots].
class UnitGroupCard extends StatelessWidget {
  const UnitGroupCard({
    super.key,
    required this.group,
    required this.durationMins,
    required this.selected,
    required this.onTap,
    this.availableCount,
  });

  final UnitGroupSlots group;
  final int durationMins;
  final bool selected;
  final VoidCallback onTap;
  final int? availableCount;

  @override
  Widget build(BuildContext context) {
    final imageUrl = group.photoUrls.isNotEmpty ? group.photoUrls.first : null;

    final durationTooShort = durationMins < group.minSlotMins;
    final durationTooLong = group.maxSlotMins > 0 && durationMins > group.maxSlotMins;
    final durationMismatch = durationTooShort || durationTooLong;

    final subtitle = group.isNetGroup
        ? '${group.totalCount ?? 0} nets'
        : _formatUnitType(group.unitType);

    String? bottomLabel;
    Color? bottomColor;
    if (durationMismatch) {
      final minH = group.minSlotMins ~/ 60;
      final maxH = group.maxSlotMins ~/ 60;
      bottomLabel = group.minSlotMins == group.maxSlotMins
          ? '${minH}hr slot'
          : '${minH}–${maxH}hr slots';
    } else {
      final approxPrice = (group.pricePerHourPaise * durationMins / 60).round();
      bottomLabel = 'from ₹${(approxPrice / 100).toStringAsFixed(0)}';
      bottomColor = context.accent;
    }

    return GestureDetector(
      onTap: durationMismatch ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        color: selected ? context.accent.withValues(alpha: 0.07) : Colors.transparent,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 64,
                height: 64,
                child: imageUrl != null
                    ? Image.network(imageUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const _SportPlaceholder())
                    : const _SportPlaceholder(),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          group.displayName,
                          style: TextStyle(
                            color: context.fg,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (group.hasFloodlights == true)
                        Icon(Icons.light_mode_rounded, size: 13, color: context.gold),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(color: context.fgSub, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  if (bottomLabel != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      bottomLabel,
                      style: TextStyle(
                        color: bottomColor ?? context.fgSub,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              selected ? Icons.keyboard_arrow_down_rounded : Icons.chevron_right_rounded,
              color: selected ? context.accent : context.fgSub.withValues(alpha: 0.4),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

/// New card for [PlayerBookingSheet] that uses [BookingGroup].
class BookingGroupCard extends StatelessWidget {
  const BookingGroupCard({
    super.key,
    required this.group,
    required this.durationMins,
    required this.selected,
    required this.onTap,
    this.priceForDuration,
  });

  final BookingGroup group;
  final int durationMins;
  final bool selected;
  final VoidCallback onTap;
  final int? priceForDuration;

  @override
  Widget build(BuildContext context) {
    final imageUrl = group.photoUrls.isNotEmpty ? group.photoUrls.first : null;

    final durationTooShort = durationMins < group.minSlotMins;
    final durationTooLong = group.maxSlotMins > 0 && durationMins > group.maxSlotMins;
    final durationMismatch = durationTooShort || durationTooLong;

    final subtitle = group.isNetGroup
        ? '${group.totalCount ?? 0} nets'
        : _formatUnitType(group.unitType);

    String? bottomLabel;
    Color? bottomColor;
    if (durationMismatch) {
      final minH = group.minSlotMins ~/ 60;
      final maxH = group.maxSlotMins ~/ 60;
      bottomLabel = group.minSlotMins == group.maxSlotMins
          ? '${minH}hr slot'
          : '${minH}–${maxH}hr slots';
    } else if (priceForDuration != null && !group.isNetGroup) {
      bottomLabel = '₹${(priceForDuration! / 100).toStringAsFixed(0)} · ${durationMins ~/ 60}hr';
      bottomColor = context.accent;
    } else if (group.isNetGroup) {
      final range = _netPriceRange(group.units);
      bottomLabel = range;
      bottomColor = context.accent;
    } else {
      final approxPrice = (group.pricePerHourPaise * durationMins / 60).round();
      bottomLabel = 'from ₹${(approxPrice / 100).toStringAsFixed(0)}';
      bottomColor = context.accent;
    }

    return GestureDetector(
      onTap: durationMismatch ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        color: selected ? context.accent.withValues(alpha: 0.07) : Colors.transparent,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 64,
                height: 64,
                child: imageUrl != null
                    ? Image.network(imageUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const _SportPlaceholder())
                    : const _SportPlaceholder(),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          group.displayName,
                          style: TextStyle(
                            color: context.fg,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (group.hasFloodlights)
                        Icon(Icons.light_mode_rounded, size: 13, color: context.gold),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(color: context.fgSub, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  if (bottomLabel != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      bottomLabel,
                      style: TextStyle(
                        color: bottomColor ?? context.fgSub,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              selected ? Icons.keyboard_arrow_down_rounded : Icons.chevron_right_rounded,
              color: selected ? context.accent : context.fgSub.withValues(alpha: 0.4),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _SportPlaceholder extends StatelessWidget {
  const _SportPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.panel.withValues(alpha: 0.55),
      child: Center(
        child: Icon(Icons.sports_cricket_rounded,
            color: context.fgSub.withValues(alpha: 0.4), size: 24),
      ),
    );
  }
}

/// Returns "₹220/hr" when all net variants share the same price,
/// or "₹220–₹367/hr" when they differ.
String _netPriceRange(List<ArenaUnitOption> units) {
  final prices = <int>[];
  for (final u in units) {
    if (u.netVariants.isEmpty) {
      if (u.pricePerHourPaise > 0) prices.add(u.pricePerHourPaise);
    } else {
      for (final v in u.netVariants) {
        final p = v.pricePaise ?? u.pricePerHourPaise;
        if (p > 0) prices.add(p);
      }
    }
  }
  if (prices.isEmpty) return '';
  final lo = prices.reduce((a, b) => a < b ? a : b);
  final hi = prices.reduce((a, b) => a > b ? a : b);
  final loStr = '₹${(lo / 100).toStringAsFixed(0)}';
  if (lo == hi) return '$loStr/hr';
  final hiStr = '₹${(hi / 100).toStringAsFixed(0)}';
  return '$loStr–$hiStr/hr';
}

String _formatUnitType(String raw) {
  final t = raw.trim().toUpperCase();
  if (t.contains('TURF')) return 'Turf';
  if (t.contains('GROUND')) return 'Ground';
  if (t.contains('NET')) return 'Nets';
  if (t.contains('INDOOR')) return 'Indoor';
  if (t.contains('CENTER') || t.contains('CENTRE')) return 'Center wicket';
  return raw.isEmpty ? 'Unit' : raw;
}
