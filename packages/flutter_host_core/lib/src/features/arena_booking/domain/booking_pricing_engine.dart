import 'arena_booking_models.dart';

// ── Value types ───────────────────────────────────────────────────────────────

class BookingDurationOption {
  const BookingDurationOption({
    required this.durationMins,
    required this.label,
    required this.pricePaise,
  });

  final int durationMins;
  final String label;
  final int pricePaise;
}

class BookingAvailability {
  const BookingAvailability({
    this.bookings = const [],
    this.timeBlocks = const [],
    this.availableStartTimes,
    this.durationMins,
  });

  final List<ArenaReservation> bookings;
  final List<ArenaTimeBlock> timeBlocks;

  /// Authoritative bookable start times for [durationMins] on the loaded
  /// date+unit, sourced from the backend's `booking-context` endpoint. When
  /// populated, this is what the slot picker should trust — it already
  /// accounts for held slots, monthly passes, parent/child unit conflicts,
  /// and turnaround buffers that the raw `bookings` + `timeBlocks` lists
  /// don't expose.
  ///
  /// `null` means the caller didn't request a server-side check (legacy
  /// mode) — use [BookingPricingEngine.isSlotBusy] against [bookings] +
  /// [timeBlocks] instead.
  final Set<String>? availableStartTimes;

  /// The duration the server resolved [availableStartTimes] for. Re-fetch
  /// if the UI's selected duration changes.
  final int? durationMins;

  static const empty = BookingAvailability();
}

// ── Engine ────────────────────────────────────────────────────────────────────

/// Pure static pricing + slot logic — the single source of truth for booking
/// calculations. Mirrors the reference implementation in swing-biz AddBookingSheet.
///
/// All frontends (biz, player, web) should use this instead of re-implementing
/// the same rules locally.
class BookingPricingEngine {
  BookingPricingEngine._();

  // ── Duration options ────────────────────────────────────────────────────────

  /// Returns the available duration choices for [unit], with correct prices.
  ///
  /// For grounds: prefers explicit bundle prices (4hr, 8hr, full-day) over
  /// hourly math. For nets: steps from minSlot up to maxSlot.
  /// Pass [variantPricePaise] to override with a net variant's per-hour rate.
  /// Pass [date] so weekend multiplier is applied when the date is Sat/Sun.
  static List<BookingDurationOption> durationOptions(
    ArenaUnitOption unit, {
    int? variantPricePaise,
    DateTime? date,
  }) {
    final pricePerHour =
        (variantPricePaise != null && variantPricePaise > 0)
            ? variantPricePaise
            : unit.pricePerHourPaise;
    final minMins = unit.minSlotMins > 0 ? unit.minSlotMins : 60;
    final increment = minMins >= 60
        ? minMins
        : (unit.slotIncrementMins > 0 ? unit.slotIncrementMins : 60);

    // Grounds: show only explicit bundle prices when any are configured and
    // no variant override is active.
    if (unit.isGround &&
        (variantPricePaise == null || variantPricePaise == 0)) {
      final bundles = <BookingDurationOption>[];
      if (unit.price4HrPaise != null)
        bundles.add(BookingDurationOption(
            durationMins: 240, label: '4 hrs', pricePaise: unit.price4HrPaise!));
      if (unit.price8HrPaise != null)
        bundles.add(BookingDurationOption(
            durationMins: 480, label: '8 hrs', pricePaise: unit.price8HrPaise!));
      if (unit.priceFullDayPaise != null)
        bundles.add(BookingDurationOption(
            durationMins: 720,
            label: 'Full day',
            pricePaise: unit.priceFullDayPaise!));
      // Only return bundles-only when no hourly rate — if pricePerHourPaise > 0
      // fall through so the loop generates all hourly slots (bundle prices are
      // substituted at their specific durations inside the loop below).
      if (bundles.isNotEmpty && unit.pricePerHourPaise == 0)
        return _applyWeekend(bundles, unit, date);
    }

    final configuredMax = unit.maxSlotMins > minMins ? unit.maxSlotMins : 0;
    final autoMax = (minMins * 3).clamp(240, 720);
    final maxMins =
        configuredMax > 0 ? configuredMax : (unit.isGround ? 720 : autoMax);

    final opts = <BookingDurationOption>[];
    for (var m = minMins; m <= maxMins; m += increment) {
      // Prefer explicit bundle prices unless a variant override is active
      if (variantPricePaise == null || variantPricePaise == 0) {
        if (m == 240 && unit.price4HrPaise != null) {
          opts.add(BookingDurationOption(
              durationMins: m,
              label: _durationLabel(m),
              pricePaise: unit.price4HrPaise!));
          continue;
        }
        if (m == 480 && unit.price8HrPaise != null) {
          opts.add(BookingDurationOption(
              durationMins: m,
              label: _durationLabel(m),
              pricePaise: unit.price8HrPaise!));
          continue;
        }
        if (m >= 720 && unit.priceFullDayPaise != null) {
          opts.add(BookingDurationOption(
              durationMins: m,
              label: 'Full day',
              pricePaise: unit.priceFullDayPaise!));
          continue;
        }
      }
      final pricePaise = ((pricePerHour * m) / 60).round();
      final label =
          (m >= 720 && unit.priceFullDayPaise != null &&
                  (variantPricePaise == null || variantPricePaise == 0))
              ? 'Full day'
              : _durationLabel(m);
      opts.add(BookingDurationOption(
          durationMins: m, label: label, pricePaise: pricePaise));
    }

    if (opts.isEmpty) {
      final fallback = [
        BookingDurationOption(
          durationMins: minMins,
          label: _durationLabel(minMins),
          pricePaise: ((pricePerHour * minMins) / 60).round(),
        )
      ];
      return _applyWeekend(fallback, unit, date);
    }
    return _applyWeekend(opts, unit, date);
  }

  // ── Slot busy check ─────────────────────────────────────────────────────────

  /// Returns true if the [startTime] slot (lasting [durationMins]) is
  /// unavailable.
  ///
  /// For nets with [variantType], counts bookings of that specific variant;
  /// [variantInstanceIndex] (0-based) lets you check individual lanes when
  /// count > 1. A booking with null netVariantType blocks all variants (legacy).
  static bool isSlotBusy(
    String startTime,
    int durationMins, {
    required List<ArenaReservation> bookings,
    required List<ArenaTimeBlock> timeBlocks,
    String? variantType,
    int variantInstanceIndex = 0,
  }) {
    final tMins = _toMins(startTime);

    // Time blocks block all variants
    if (timeBlocks.any((b) =>
        _toMins(b.startTime) < tMins + durationMins &&
        _toMins(b.endTime) > tMins)) return true;

    int count = 0;
    for (final b in bookings) {
      if (b.status == 'CANCELLED') continue;
      if (_toMins(b.startTime) >= tMins + durationMins ||
          _toMins(b.endTime) <= tMins) continue;
      if (variantType != null) {
        // null netVariantType = legacy booking — blocks all variant types
        if (b.netVariantType == null || b.netVariantType == variantType) count++;
      } else {
        count++;
      }
    }
    return count > variantInstanceIndex;
  }

  // ── Price computation ───────────────────────────────────────────────────────

  /// Computes total price for a booking.
  ///
  /// For nets: [variantPricePaise] is the per-hour rate from the selected
  /// [NetVariant]. For grounds: falls back to bundle prices then hourly.
  static int computeTotal(
    ArenaUnitOption unit, {
    required int durationMins,
    int variantPricePaise = 0,
    int addonPaise = 0,
    DateTime? date,
  }) {
    if (unit.isNet) {
      final rate = variantPricePaise > 0
          ? variantPricePaise
          : unit.pricePerHourPaise;
      final base = ((rate * durationMins) / 60).round();
      final isWeekend = date != null && (date.weekday == 6 || date.weekday == 7);
      final mult = (isWeekend && unit.weekendMultiplier > 1.0) ? unit.weekendMultiplier : 1.0;
      return (base * mult).round() + addonPaise;
    }
    // Ground: use bundle price if available
    final opts = durationOptions(unit, variantPricePaise: variantPricePaise, date: date);
    final match = opts.where((o) => o.durationMins == durationMins).firstOrNull;
    return (match?.pricePaise ?? 0) + addonPaise;
  }

  // ── Time slot list ──────────────────────────────────────────────────────────

  /// Returns selectable start times for [unit] on [date], respecting
  /// [durationMins], arena open/close, and buffer from now.
  static List<String> buildDaySlots(
    ArenaUnitOption unit,
    String arenaOpenTime,
    String arenaCloseTime,
    DateTime date, {
    required int durationMins,
    int bufferMins = 30,
  }) {
    final openStr = unit.openTime ?? arenaOpenTime;
    final closeStr = unit.closeTime ?? arenaCloseTime;
    final openMins = _toMins(openStr);
    final closeMins = _toMins(closeStr);
    // Ground units are single-capacity: step by durationMins so slots are non-overlapping
    final increment = unit.isGround
        ? durationMins
        : (unit.slotIncrementMins > 0 ? unit.slotIncrementMins : 60);
    final isToday = _isSameDay(date, DateTime.now());
    final nowMins = DateTime.now().hour * 60 + DateTime.now().minute;

    final slots = <String>[];
    for (var m = openMins; m + durationMins <= closeMins; m += increment) {
      if (isToday && m < nowMins + bufferMins) continue;
      slots.add(_fromMins(m));
    }
    return slots;
  }

  // ── Net variant helpers ─────────────────────────────────────────────────────

  /// Expands [unit.netVariants] into individual lane tabs.
  ///
  /// e.g. Turf(count=2) + Cement(count=1) → [Turf/0, Turf/1, Cement/0]
  static List<NetVariantTab> variantTabs(ArenaUnitOption unit) {
    if (!unit.hasVariants) return const [];
    return [
      for (final v in unit.netVariants)
        for (var i = 0; i < v.count; i++)
          NetVariantTab(
            type: v.type,
            label: v.count > 1 ? '${v.label} ${i + 1}' : v.label,
            instanceIndex: i,
            count: v.count,
            pricePaise: v.pricePaise,
          ),
    ];
  }

  /// Returns the per-hour price for [variantType] in [unit], or 0 if not found.
  static int variantPricePerHour(ArenaUnitOption unit, String? variantType) {
    if (variantType == null) return 0;
    try {
      return unit.netVariants
              .firstWhere((v) => v.type == variantType)
              .pricePaise ??
          0;
    } catch (_) {
      return 0;
    }
  }

  // ── Internals ───────────────────────────────────────────────────────────────

  static int _toMins(String t) {
    final parts = t.split(':');
    if (parts.length < 2) return 0;
    return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
  }

  static String _fromMins(int mins) {
    final h = mins ~/ 60;
    final m = mins % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  static String _durationLabel(int mins) {
    if (mins < 60) return '${mins}m';
    final h = mins ~/ 60;
    final rem = mins % 60;
    return rem == 0 ? '$h hr' : '$h hr ${rem}m';
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static List<BookingDurationOption> _applyWeekend(
    List<BookingDurationOption> opts,
    ArenaUnitOption unit,
    DateTime? date,
  ) {
    if (date == null) return opts;
    final isWeekend = date.weekday == 6 || date.weekday == 7;
    if (!isWeekend || unit.weekendMultiplier <= 1.0) return opts;
    final m = unit.weekendMultiplier;
    return opts
        .map((o) => BookingDurationOption(
              durationMins: o.durationMins,
              label: o.label,
              pricePaise: (o.pricePaise * m).round(),
            ))
        .toList();
  }
}

// ── Supporting types ──────────────────────────────────────────────────────────

class NetVariantTab {
  const NetVariantTab({
    required this.type,
    required this.label,
    required this.instanceIndex,
    required this.count,
    this.pricePaise,
  });

  final String type;
  final String label;
  final int instanceIndex;
  final int count;
  final int? pricePaise;
}
