import '../domain/arena_booking_models.dart';
import '../domain/booking_pricing_engine.dart';
import '../../../repositories/host_arena_repository.dart';

/// Fetches the authoritative slot availability for a unit on a given date.
///
/// When [durationMins] is provided (preferred path), it queries the backend's
/// `GET /arenas/:id/booking-context?date=…&durationMins=…` — the same
/// endpoint the player wizard uses. That endpoint already accounts for held
/// slots, monthly passes, turnaround buffers, and parent/child unit
/// conflicts, so its `availableStartTimes` match exactly what the booking
/// POST will accept. This eliminates the "I picked a free slot but got a
/// 409" mismatch.
///
/// The loader also fetches raw bookings + time blocks for [bookings] /
/// [timeBlocks] in [BookingAvailability] — useful for UI that wants to
/// render who/why a slot is busy.
class BookingAvailabilityLoader {
  static Future<BookingAvailability> load({
    required HostArenaBookingRepository repo,
    required String arenaId,
    required String unitId,
    required DateTime date,
    List<ArenaUnitOption> allUnits = const [],
    int? durationMins,
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

    final futures = <Future<dynamic>>[
      Future.wait(
        relatedIds.map((id) =>
            repo.listArenaBookings(arenaId, date: dateStr, unitId: id)),
      ),
      repo
          .listUnitTimeBlocks(arenaId, unitId: unitId)
          .catchError((_) => <ArenaTimeBlock>[]),
      if (durationMins != null && durationMins > 0)
        repo
            .fetchPlayerSlots(
                arenaId: arenaId, date: date, durationMins: durationMins)
            .then<Object?>((v) => v)
            .catchError((_) => null),
    ];
    final results = await Future.wait(futures);

    final bookings = (results[0] as List<List<ArenaReservation>>)
        .expand((b) => b)
        .toList();
    final allBlocks = results[1] as List<ArenaTimeBlock>;
    final blocks = allBlocks.where((b) {
      if (b.isRecurring && b.weekdays.contains(weekday)) return true;
      if (b.isHoliday && b.date != null && b.date!.startsWith(dateStr)) {
        return true;
      }
      if (!b.isRecurring &&
          !b.isHoliday &&
          b.date != null &&
          b.date!.startsWith(dateStr)) {
        return true;
      }
      return false;
    }).toList();

    Set<String>? availableStartTimes;
    if (durationMins != null && durationMins > 0) {
      final ctx = results.length >= 3 ? results[2] : null;
      if (ctx is PlayerSlotsData) {
        availableStartTimes = _extractAvailableStartTimes(
          ctx,
          unitId: unitId,
          allUnits: allUnits,
        );
      }
    }

    return BookingAvailability(
      bookings: bookings,
      timeBlocks: blocks,
      availableStartTimes: availableStartTimes,
      durationMins: durationMins,
    );
  }

  /// Find the unit group in [ctx] that matches [unitId] (directly or via the
  /// shared NETS group when the unit is a net) and return the set of
  /// bookable start times.
  static Set<String>? _extractAvailableStartTimes(
    PlayerSlotsData ctx,
    {required String unitId, List<ArenaUnitOption> allUnits = const []}) {
    // 1) Direct unitId match — works for grounds and named units.
    final direct = ctx.unitGroups
        .where((g) => g.unitId == unitId)
        .firstOrNull;
    if (direct != null) {
      return direct.availableSlots.map((s) => s.startTime).toSet();
    }

    // 2) NETS rollup: slot-level assignedUnitId matches our unit.
    for (final g in ctx.unitGroups) {
      final matching = g.availableSlots
          .where((s) => s.assignedUnitId == unitId)
          .toList();
      if (matching.isNotEmpty) {
        return matching.map((s) => s.startTime).toSet();
      }
    }

    // 3) NETS rollup: same netType as our unit.
    final mine = allUnits.where((u) => u.id == unitId).firstOrNull;
    if (mine != null && mine.isNet) {
      for (final g in ctx.unitGroups) {
        if (!g.isNetsGroup) continue;
        if (g.netTypes != null &&
            mine.netType != null &&
            g.netTypes!.contains(mine.netType)) {
          return g.availableSlots.map((s) => s.startTime).toSet();
        }
      }
    }

    // No clear match — return null so caller can fall back to legacy overlap
    // checking (avoids accidentally locking the picker for unknown units).
    return null;
  }

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
