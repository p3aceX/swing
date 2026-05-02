import 'package:flutter_host_core/flutter_host_core.dart';

/// A display group in the player booking wizard.
/// Nets collapse into one group; each ground is its own group.
class BookingGroup {
  const BookingGroup({
    required this.key,
    required this.displayName,
    required this.unitType,
    required this.isNetGroup,
    required this.units,
    required this.netTypes,
    required this.pricePerHourPaise,
    required this.minAdvancePaise,
    required this.minSlotMins,
    required this.maxSlotMins,
    required this.photoUrls,
    required this.hasFloodlights,
    this.totalCount,
  });

  final String key;
  final String displayName;
  final String unitType;
  final bool isNetGroup;
  final List<ArenaUnitOption> units;
  final List<String> netTypes;
  final int pricePerHourPaise;
  final int minAdvancePaise;
  final int minSlotMins;
  final int maxSlotMins;
  final List<String> photoUrls;
  final bool hasFloodlights;
  final int? totalCount;

  String? get singleUnitId => isNetGroup ? null : units.firstOrNull?.id;
}

/// A computed available time slot for a [BookingGroup] on a specific date.
class PlayerSlot {
  const PlayerSlot({
    required this.startTime,
    required this.endTime,
    required this.totalCount,
    this.variantCounts = const {},
    this.isWeekendRate = false,
  });

  final String startTime;
  final String endTime;
  final int totalCount;
  final Map<String, int> variantCounts; // netVariantType → available count
  final bool isWeekendRate;

  int countForType(String? type) =>
      type == null ? totalCount : (variantCounts[type] ?? 0);
}
