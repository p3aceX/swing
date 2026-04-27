import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/arena_slots_models.dart';

class UnitGroupCard extends StatelessWidget {
  const UnitGroupCard({
    super.key,
    required this.group,
    required this.durationMins,
    required this.selected,
    required this.onTap,
  });

  final UnitGroupSlots group;
  final int durationMins;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = group.photoUrls.isNotEmpty ? group.photoUrls.first : null;

    // Duration mismatch: slots may exist but not for the current durationMins
    final durationTooShort = durationMins < group.minSlotMins;
    final durationTooLong = group.maxSlotMins > 0 && durationMins > group.maxSlotMins;
    final durationMismatch = durationTooShort || durationTooLong;

    // Only "fully booked" if duration is valid but no slots came back
    final booked = !durationMismatch && group.isFullyBooked;

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
      bottomColor = null; // fgSub
    } else if (booked) {
      bottomLabel = 'Fully booked';
      bottomColor = null;
    } else if (group.availableSlots.isNotEmpty) {
      final price = group.availableSlots.first.totalAmountPaise;
      bottomLabel = '₹${(price / 100).toStringAsFixed(0)} · ${durationMins}min';
      bottomColor = context.accent;
    }

    return GestureDetector(
      onTap: booked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        color: selected
            ? context.accent.withValues(alpha: 0.07)
            : Colors.transparent,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 64,
                height: 64,
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _SportPlaceholder(faded: booked),
                      )
                    : _SportPlaceholder(faded: booked),
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
                            color: booked ? context.fgSub : context.fg,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (!booked && group.hasFloodlights == true)
                        Icon(Icons.light_mode_rounded,
                            size: 13, color: context.gold),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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
              selected
                  ? Icons.keyboard_arrow_down_rounded
                  : Icons.chevron_right_rounded,
              color: selected
                  ? context.accent
                  : context.fgSub.withValues(alpha: 0.4),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _SportPlaceholder extends StatelessWidget {
  const _SportPlaceholder({this.faded = false});
  final bool faded;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.panel.withValues(alpha: faded ? 0.25 : 0.55),
      child: Center(
        child: Icon(
          Icons.sports_cricket_rounded,
          color: context.fgSub.withValues(alpha: faded ? 0.25 : 0.4),
          size: 24,
        ),
      ),
    );
  }
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
