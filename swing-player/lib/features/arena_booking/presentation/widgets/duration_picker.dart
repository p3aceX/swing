import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart' show ArenaUnitOption;

import '../../../../core/theme/app_colors.dart';
import '../../domain/arena_slots_models.dart';

/// Neutral constraint model — create from either [ArenaUnitOption] or
/// [UnitGroupSlots] so both old and new code can use the same picker.
class DurationConstraints {
  const DurationConstraints({
    required this.minSlotMins,
    required this.maxSlotMins,
    required this.pricePerHourPaise,
    this.price4HrPaise,
    this.price8HrPaise,
  });

  factory DurationConstraints.fromUnit(ArenaUnitOption u) => DurationConstraints(
        minSlotMins: u.minSlotMins,
        maxSlotMins: u.maxSlotMins,
        pricePerHourPaise: u.pricePerHourPaise,
        price4HrPaise: u.price4HrPaise,
        price8HrPaise: u.price8HrPaise,
      );

  factory DurationConstraints.fromGroup(UnitGroupSlots g) => DurationConstraints(
        minSlotMins: g.minSlotMins,
        maxSlotMins: g.maxSlotMins,
        pricePerHourPaise: g.pricePerHourPaise,
        price4HrPaise: g.price4HrPaise,
        price8HrPaise: g.price8HrPaise,
      );

  final int minSlotMins;
  final int maxSlotMins;
  final int pricePerHourPaise;
  final int? price4HrPaise;
  final int? price8HrPaise;
}

class DurationPicker extends StatelessWidget {
  const DurationPicker({
    super.key,
    required this.selectedMins,
    required this.constraints,
    required this.onChanged,
  });

  final int selectedMins;
  final List<DurationConstraints> constraints;
  final ValueChanged<int> onChanged;

  static const _durations = [60, 120, 240, 480];

  List<int> get _validDurations {
    if (constraints.isEmpty) return _durations;
    return _durations.where((mins) => constraints.every((c) {
      final min = c.minSlotMins > 0 ? c.minSlotMins : 60;
      final withinMin = mins >= min;
      final withinMax = c.maxSlotMins <= 0 || mins <= c.maxSlotMins;
      return withinMin && withinMax;
    })).toList();
  }

  @override
  Widget build(BuildContext context) {
    final valid = _validDurations;
    if (valid.length <= 1) return const SizedBox.shrink();
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: valid.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final mins = valid[index];
          final selected = selectedMins == mins;
          final saving = _savingPercent(mins);
          return _DurationChip(
            mins: mins,
            selected: selected,
            saving: saving,
            onTap: () => onChanged(mins),
          );
        },
      ),
    );
  }

  int? _savingPercent(int mins) {
    if (mins != 240 && mins != 480) return null;
    final hours = mins ~/ 60;
    int best = 0;
    for (final c in constraints) {
      final packagePrice = mins == 240 ? c.price4HrPaise : c.price8HrPaise;
      if (packagePrice == null || packagePrice <= 0) continue;
      final regular = c.pricePerHourPaise * hours;
      if (regular <= 0 || packagePrice >= regular) continue;
      final saving = (((regular - packagePrice) / regular) * 100).round();
      if (saving > best) best = saving;
    }
    return best > 0 ? best : null;
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({
    required this.mins,
    required this.selected,
    required this.saving,
    required this.onTap,
  });

  final int mins;
  final bool selected;
  final int? saving;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = selected ? Colors.white : context.fg;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        decoration: BoxDecoration(
          color: selected ? context.accent : context.panel.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(23),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${mins ~/ 60} hr',
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (saving != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.2)
                      : context.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'save $saving%',
                  style: TextStyle(
                    color: selected ? Colors.white : context.success,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
