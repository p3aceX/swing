import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/arena_slots_models.dart';

class DurationPicker extends StatelessWidget {
  const DurationPicker({
    super.key,
    required this.selectedMins,
    required this.groups,
    required this.onChanged,
  });

  final int selectedMins;
  final List<UnitGroupSlots> groups;
  final ValueChanged<int> onChanged;

  static const _durations = [60, 120, 240, 480];

  List<int> get _validDurations {
    if (groups.isEmpty) return _durations;
    return _durations.where((mins) => groups.every(
          (g) => mins >= g.minSlotMins && mins <= g.maxSlotMins,
        )).toList();
  }

  @override
  Widget build(BuildContext context) {
    final valid = _validDurations;
    // Single valid duration — nothing to pick, hide the widget
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
            disabled: false,
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
    for (final group in groups) {
      final packagePrice =
          mins == 240 ? group.price4HrPaise : group.price8HrPaise;
      if (packagePrice == null || packagePrice <= 0) continue;
      final regular = group.pricePerHourPaise * hours;
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
    required this.disabled,
    required this.saving,
    required this.onTap,
  });

  final int mins;
  final bool selected;
  final bool disabled;
  final int? saving;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = disabled
        ? context.fgSub.withValues(alpha: 0.35)
        : selected
            ? Colors.white
            : context.fg;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        decoration: BoxDecoration(
          color: disabled
              ? context.panel.withValues(alpha: 0.2)
              : selected
                  ? context.accent
                  : context.panel.withValues(alpha: 0.45),
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
                decoration: disabled ? TextDecoration.lineThrough : null,
                decorationColor: textColor,
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
