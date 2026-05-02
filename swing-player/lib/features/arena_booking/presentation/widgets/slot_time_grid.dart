import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/arena_slots_models.dart';
import '../../domain/player_booking_types.dart';

/// Legacy widget used by arena_booking_screen and booking_wizard_screen.
/// New code should use [PlayerSlotGrid] instead.
class SlotTimeGrid extends StatelessWidget {
  const SlotTimeGrid({
    super.key,
    required this.group,
    required this.selectedSlot,
    required this.onSelected,
    this.selectedNetType,
  });

  final UnitGroupSlots group;
  final AvailableSlot? selectedSlot;
  final ValueChanged<AvailableSlot> onSelected;
  final String? selectedNetType;

  @override
  Widget build(BuildContext context) {
    final slots = group.isNetGroup && selectedNetType != null
        ? group.availableSlots
            .where((s) => s.netTypeOptions.any((o) => o.netType == selectedNetType))
            .toList()
        : group.availableSlots;

    if (slots.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text('No slots available for this selection.',
            style: TextStyle(color: context.fgSub, fontSize: 13)),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final slot in slots)
            _LegacySlotChip(
              slot: slot,
              isNetGroup: group.isNetGroup,
              selectedNetType: selectedNetType,
              selected: selectedSlot == slot,
              onTap: () => onSelected(slot),
            ),
        ],
      ),
    );
  }
}

class _LegacySlotChip extends StatelessWidget {
  const _LegacySlotChip({
    required this.slot,
    required this.isNetGroup,
    required this.selected,
    required this.onTap,
    this.selectedNetType,
  });

  final AvailableSlot slot;
  final bool isNetGroup;
  final bool selected;
  final VoidCallback onTap;
  final String? selectedNetType;

  @override
  Widget build(BuildContext context) {
    int? displayCount;
    if (isNetGroup) {
      displayCount = selectedNetType != null
          ? slot.netTypeOptions
              .where((o) => o.netType == selectedNetType)
              .map((o) => o.availableCount)
              .firstOrNull
          : slot.availableCount;
    }
    final scarce = displayCount != null && displayCount <= 2;
    final showTag = scarce || slot.isWeekendRate;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: showTag ? 8 : 11),
        decoration: BoxDecoration(
          color: selected ? context.accent : context.panel.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(slot.startTime,
                style: TextStyle(
                    color: selected ? Colors.white : context.fg,
                    fontSize: 14,
                    fontWeight: FontWeight.w900)),
            if (showTag) ...[
              const SizedBox(height: 3),
              Text(
                scarce ? '$displayCount left' : 'Weekend',
                style: TextStyle(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.75)
                      : (scarce ? context.warn : context.fgSub),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// New slot grid widget for [PlayerBookingSheet] — uses [PlayerSlot].
class PlayerSlotGrid extends StatelessWidget {
  const PlayerSlotGrid({
    super.key,
    required this.slots,
    required this.selectedSlot,
    required this.isNetGroup,
    required this.onSelected,
    this.selectedNetType,
  });

  final List<PlayerSlot> slots;
  final PlayerSlot? selectedSlot;
  final bool isNetGroup;
  final ValueChanged<PlayerSlot> onSelected;
  final String? selectedNetType;

  @override
  Widget build(BuildContext context) {
    final visible = isNetGroup && selectedNetType != null
        ? slots.where((s) => s.countForType(selectedNetType) > 0).toList()
        : slots;

    if (visible.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text('No slots available for this selection.',
            style: TextStyle(color: context.fgSub, fontSize: 13)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final slot in visible)
            _PlayerSlotChip(
              slot: slot,
              isNetGroup: isNetGroup,
              selectedNetType: selectedNetType,
              selected: selectedSlot?.startTime == slot.startTime,
              onTap: () => onSelected(slot),
            ),
        ],
      ),
    );
  }
}

class _PlayerSlotChip extends StatelessWidget {
  const _PlayerSlotChip({
    required this.slot,
    required this.isNetGroup,
    required this.selected,
    required this.onTap,
    this.selectedNetType,
  });

  final PlayerSlot slot;
  final bool isNetGroup;
  final bool selected;
  final VoidCallback onTap;
  final String? selectedNetType;

  @override
  Widget build(BuildContext context) {
    final displayCount = isNetGroup ? slot.countForType(selectedNetType) : null;
    final scarce = displayCount != null && displayCount <= 2;
    final showTag = scarce || slot.isWeekendRate;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: showTag ? 8 : 11),
        decoration: BoxDecoration(
          color: selected ? context.accent : context.panel.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(slot.startTime,
                style: TextStyle(
                    color: selected ? Colors.white : context.fg,
                    fontSize: 14,
                    fontWeight: FontWeight.w900)),
            if (showTag) ...[
              const SizedBox(height: 3),
              Text(
                scarce ? '$displayCount left' : 'Weekend',
                style: TextStyle(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.75)
                      : (scarce ? context.warn : context.fgSub),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
