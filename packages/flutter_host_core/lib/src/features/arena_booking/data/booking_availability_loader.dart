import 'package:flutter/foundation.dart';

import '../domain/arena_booking_models.dart';
import '../domain/booking_pricing_engine.dart';
import '../../../repositories/host_arena_repository.dart';

/// Fetches bookings + time blocks for a unit on a date, returning a
/// [BookingAvailability] ready to pass into [BookingPricingEngine.isSlotBusy].
///
/// Handles related-unit loading (parent/child units) the same way biz does.
class BookingAvailabilityLoader {
  static Future<BookingAvailability> load({
    required HostArenaBookingRepository repo,
    required String arenaId,
    required String unitId,
    required DateTime date,
    List<ArenaUnitOption> allUnits = const [],
  }) async {
    final dateStr = _fmt(date);
    final weekday = date.weekday;

    // Collect related unit IDs (parent + children) same as biz does
    final relatedIds = <String>{unitId};
    for (final u in allUnits) {
      if (u.id == unitId && u.parentUnitId != null) {
        relatedIds.add(u.parentUnitId!);
      }
      if (u.parentUnitId == unitId) relatedIds.add(u.id);
    }

    final bookingResults = await Future.wait(
      relatedIds.map((id) =>
          repo.listArenaBookings(arenaId, date: dateStr, unitId: id)),
    );
    final bookings = bookingResults.expand((b) => b).toList();
    debugPrint(
        '[BookingAvailabilityLoader] bookings=${bookings.length} for $unitId on $dateStr');

    List<ArenaTimeBlock> blocks = [];
    try {
      final all = await repo.listUnitTimeBlocks(arenaId, unitId: unitId);
      blocks = all.where((b) {
        if (b.isRecurring && b.weekdays.contains(weekday)) return true;
        if (b.isHoliday && b.date != null && b.date!.startsWith(dateStr))
          return true;
        if (!b.isRecurring &&
            !b.isHoliday &&
            b.date != null &&
            b.date!.startsWith(dateStr)) return true;
        return false;
      }).toList();
    } catch (e) {
      debugPrint('[BookingAvailabilityLoader] timeBlocks error: $e');
    }
    debugPrint(
        '[BookingAvailabilityLoader] timeBlocks=${blocks.length} for $unitId on $dateStr');

    return BookingAvailability(bookings: bookings, timeBlocks: blocks);
  }

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
