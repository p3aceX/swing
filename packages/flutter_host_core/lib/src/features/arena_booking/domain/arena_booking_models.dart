import 'package:intl/intl.dart';

class ArenaListing {
  const ArenaListing({
    required this.id,
    required this.name,
    required this.address,
    this.city = '',
    this.state = '',
    this.pincode = '',
    required this.openTime,
    required this.closeTime,
    required this.units,
    this.photoUrls = const [],
    this.description = '',
    this.phone,
    this.sports = const ['Cricket'],
    this.advanceBookingDays = 0,
    this.bufferMins = 0,
    this.cancellationHours = 0,
    this.operatingDays = const [],
    this.hasParking = false,
    this.hasLights = false,
    this.hasWashrooms = false,
    this.hasCanteen = false,
    this.hasCCTV = false,
    this.hasScorer = false,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String name;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String openTime;
  final String closeTime;
  final List<String> photoUrls;
  final String description;
  final String? phone;
  final List<String> sports;
  final int advanceBookingDays;
  final int bufferMins;
  final int cancellationHours;
  final List<int> operatingDays;
  final bool hasParking;
  final bool hasLights;
  final bool hasWashrooms;
  final bool hasCanteen;
  final bool hasCCTV;
  final bool hasScorer;
  final List<ArenaUnitOption> units;
  final double? latitude;
  final double? longitude;

  factory ArenaListing.fromJson(Map<String, dynamic> json) {
    final rawUnits = (json['units'] as List?) ?? const [];
    return ArenaListing(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? 'Arena'}',
      address: '${json['address'] ?? json['location'] ?? ''}',
      city: '${json['city'] ?? ''}',
      state: '${json['state'] ?? ''}',
      pincode: '${json['pincode'] ?? ''}',
      openTime: '${json['openTime'] ?? '06:00'}',
      closeTime: '${json['closeTime'] ?? '23:00'}',
      photoUrls: ((json['photoUrls'] as List?) ?? const [])
          .map((e) => '$e')
          .where((e) => e.isNotEmpty)
          .toList(),
      description: '${json['description'] ?? ''}',
      phone: _stringOrNull(json['phone']),
      sports: ((json['sports'] as List?) ?? const ['Cricket'])
          .map((e) => '$e')
          .where((e) => e.isNotEmpty)
          .toList(),
      advanceBookingDays: _intValue(json['advanceBookingDays']),
      bufferMins: _intValue(json['bufferMins']),
      cancellationHours: _intValue(json['cancellationHours']),
      operatingDays: ((json['operatingDays'] as List?) ?? const [])
          .map((e) => _intValue(e))
          .where((e) => e >= 1 && e <= 7)
          .toList(),
      hasParking: json['hasParking'] == true,
      hasLights: json['hasLights'] == true,
      hasWashrooms: json['hasWashrooms'] == true,
      hasCanteen: json['hasCanteen'] == true,
      hasCCTV: json['hasCCTV'] == true,
      hasScorer: json['hasScorer'] == true,
      units: rawUnits
          .whereType<Map>()
          .map((e) => ArenaUnitOption.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      latitude: _doubleOrNull(json['latitude']),
      longitude: _doubleOrNull(json['longitude']),
    );
  }
}

class ArenaUnitOption {
  const ArenaUnitOption({
    required this.id,
    required this.name,
    required this.unitType,
    required this.pricePerHourPaise,
    this.unitTypeLabel,
    this.netType,
    this.sport = 'CRICKET',
    this.description = '',
    this.photoUrls = const [],
    this.peakPricePaise,
    this.peakHoursStart,
    this.peakHoursEnd,
    this.price4HrPaise,
    this.price8HrPaise,
    this.priceFullDayPaise,
    this.weekendMultiplier = 1,
    this.minSlotMins = 60,
    this.maxSlotMins = 240,
    this.slotIncrementMins = 60,
    this.minAdvancePaise = 0,
    this.boundarySize,
    this.addons = const [],
    this.openTime,
    this.closeTime,
    this.operatingDays = const [],
    this.hasFloodlights = false,
  });

  final String id;
  final String name;
  final String unitType;
  final String? unitTypeLabel;
  final String? netType;
  final String sport;
  final String description;
  final List<String> photoUrls;
  final int pricePerHourPaise;
  final int? peakPricePaise;
  final String? peakHoursStart;
  final String? peakHoursEnd;
  final int? price4HrPaise;
  final int? price8HrPaise;
  final int? priceFullDayPaise;
  final double weekendMultiplier;
  final int minSlotMins;
  final int maxSlotMins;
  final int slotIncrementMins;
  final int minAdvancePaise;
  final int? boundarySize;
  final List<ArenaAddon> addons;
  final String? openTime;
  final String? closeTime;
  final List<int> operatingDays;
  final bool hasFloodlights;

  factory ArenaUnitOption.fromJson(Map<String, dynamic> json) {
    return ArenaUnitOption(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? 'Unit'}',
      unitType: '${json['unitType'] ?? json['type'] ?? 'OTHER'}',
      unitTypeLabel: _stringOrNull(json['unitTypeLabel']),
      netType: _stringOrNull(json['netType']),
      sport: '${json['sport'] ?? 'CRICKET'}',
      description: '${json['description'] ?? ''}',
      photoUrls: ((json['photoUrls'] as List?) ?? const [])
          .map((e) => '$e')
          .where((e) => e.isNotEmpty)
          .toList(),
      pricePerHourPaise: _intValue(json['pricePerHourPaise'] ?? json['price']),
      peakPricePaise: _intOrNull(json['peakPricePaise']),
      peakHoursStart: _stringOrNull(json['peakHoursStart']),
      peakHoursEnd: _stringOrNull(json['peakHoursEnd']),
      price4HrPaise: _intOrNull(json['price4HrPaise']),
      price8HrPaise: _intOrNull(json['price8HrPaise']),
      priceFullDayPaise: _intOrNull(json['priceFullDayPaise']),
      weekendMultiplier: _doubleValue(json['weekendMultiplier'], fallback: 1),
      minSlotMins: _intValue(json['minSlotMins'] ?? 60),
      maxSlotMins: _intValue(json['maxSlotMins'] ?? 240),
      slotIncrementMins: _intValue(json['slotIncrementMins'] ?? 60),
      minAdvancePaise: _intValue(json['minAdvancePaise']),
      boundarySize: _intOrNull(json['boundarySize']),
      addons: ((json['addons'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => ArenaAddon.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      openTime: _stringOrNull(json['openTime']),
      closeTime: _stringOrNull(json['closeTime']),
      operatingDays: ((json['operatingDays'] as List?) ?? const [])
          .map((e) => _intValue(e))
          .toList(),
      hasFloodlights: json['hasFloodlights'] == true,
    );
  }
}

class ArenaAddon {
  const ArenaAddon({
    required this.id,
    required this.name,
    required this.pricePaise,
    this.unitId,
    this.addonType,
    this.description = '',
    this.unit = 'per_session',
    this.isAvailable = true,
  });

  final String id;
  final String? unitId;
  final String name;
  final String? addonType;
  final String description;
  final int pricePaise;
  final String unit;
  final bool isAvailable;

  factory ArenaAddon.fromJson(Map<String, dynamic> json) {
    return ArenaAddon(
      id: '${json['id'] ?? ''}',
      unitId: _stringOrNull(json['unitId']),
      name: '${json['name'] ?? 'Addon'}',
      addonType: _stringOrNull(json['addonType']),
      description: '${json['description'] ?? ''}',
      pricePaise: _intValue(json['pricePaise'] ?? json['price']),
      unit: '${json['unit'] ?? 'per_session'}',
      isAvailable: json['isAvailable'] != false,
    );
  }
}

class AvailabilitySlot {
  const AvailabilitySlot({
    required this.startTime,
    required this.endTime,
    required this.available,
    required this.pricePerHourPaise,
    this.id,
    this.status,
    this.bookingId,
    this.customerName,
    this.reason,
  });

  final String startTime;
  final String endTime;
  final bool available;
  final int pricePerHourPaise;
  final String? id;
  final String? status;
  final String? bookingId;
  final String? customerName;
  final String? reason;

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) {
    final status = _stringOrNull(json['status']);
    final available =
        json['available'] == true || status == null || status == 'AVAILABLE';
    final booking = (json['booking'] as Map?)?.cast<String, dynamic>();
    return AvailabilitySlot(
      id: _stringOrNull(json['id']),
      startTime: '${json['start'] ?? json['startTime'] ?? ''}'.trim(),
      endTime: '${json['end'] ?? json['endTime'] ?? ''}'.trim(),
      available: available,
      pricePerHourPaise: _intValue(json['pricePerHourPaise']),
      status: status,
      bookingId:
          _stringOrNull(json['bookingId']) ?? _stringOrNull(booking?['id']),
      customerName: _stringOrNull(json['customerName']) ??
          _stringOrNull(booking?['customerName']),
      reason: _stringOrNull(json['reason']) ?? _stringOrNull(json['label']),
    );
  }
}

class ArenaReservation {
  const ArenaReservation({
    required this.id,
    required this.status,
    required this.totalAmountPaise,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.arenaId,
    required this.unitId,
    this.unitName,
    this.baseAmountPaise,
    this.gstPaise,
    this.addonAmountPaise,
    this.notes,
    this.paymentMode,
    this.customerName,
    this.customerPhone,
    this.guestName,
    this.guestPhone,
    this.isOfflineBooking = false,
    this.checkedInAt,
    this.paidAt,
    this.cancellationReason,
    this.advancePaise = 0,
  });

  final String id;
  final String status;
  final int totalAmountPaise;
  final DateTime? bookingDate;
  final String startTime;
  final String endTime;
  final String arenaId;
  final String unitId;
  final String? unitName;
  final int? baseAmountPaise;
  final int? gstPaise;
  final int? addonAmountPaise;
  final String? notes;
  final String? paymentMode;
  final String? customerName;
  final String? customerPhone;
  final String? guestName;
  final String? guestPhone;
  final bool isOfflineBooking;
  final DateTime? checkedInAt;
  final DateTime? paidAt;
  final String? cancellationReason;
  final int advancePaise;

  int get balancePaise => (totalAmountPaise - advancePaise).clamp(0, totalAmountPaise);
  bool get hasBalance => balancePaise > 0 && paidAt == null;

  String get displayName =>
      guestName ?? customerName ?? (isOfflineBooking ? 'Walk-in' : 'Player');

  String get displayPhone => guestPhone ?? customerPhone ?? '';

  bool get isPaid =>
      paidAt != null ||
      status == 'CHECKED_IN' ||
      status == 'COMPLETED';

  factory ArenaReservation.fromJson(Map<String, dynamic> json) {
    final bookedBy = (json['bookedBy'] as Map?)?.cast<String, dynamic>();
    final user = (bookedBy?['user'] as Map?)?.cast<String, dynamic>();
    final unit = (json['unit'] as Map?)?.cast<String, dynamic>();
    return ArenaReservation(
      id: '${json['id'] ?? ''}',
      status: '${json['status'] ?? 'PENDING_PAYMENT'}'.trim(),
      totalAmountPaise:
          _intValue(json['totalAmountPaise'] ?? json['totalPricePaise']),
      bookingDate: _dateOrNull(json['date'] ?? json['bookingDate']),
      startTime: '${json['startTime'] ?? ''}'.trim(),
      endTime: '${json['endTime'] ?? ''}'.trim(),
      arenaId: '${json['arenaId'] ?? ''}',
      unitId: '${json['unitId'] ?? ''}',
      unitName: _stringOrNull(unit?['name']),
      baseAmountPaise: _intOrNull(json['baseAmountPaise']),
      gstPaise: _intOrNull(json['gstPaise']),
      addonAmountPaise: _intOrNull(json['addonAmountPaise']),
      notes: _stringOrNull(json['notes']),
      paymentMode: _stringOrNull(json['paymentMode']),
      customerName: _stringOrNull(user?['name']),
      customerPhone: _stringOrNull(user?['phone']),
      guestName: _stringOrNull(json['guestName']),
      guestPhone: _stringOrNull(json['guestPhone']),
      isOfflineBooking: json['isOfflineBooking'] == true,
      checkedInAt: _dateOrNull(json['checkedInAt']),
      paidAt: _dateOrNull(json['paidAt']),
      cancellationReason: _stringOrNull(json['cancellationReason']),
      advancePaise: _intValue(json['advancePaise']),
    );
  }
}

class PlayerBooking {
  const PlayerBooking({
    required this.id,
    required this.arenaName,
    required this.unitName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.otp,
    required this.totalAmountPaise,
  });

  final String id;
  final String arenaName;
  final String unitName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String status;
  final String otp;
  final int totalAmountPaise;

  factory PlayerBooking.fromJson(Map<String, dynamic> json) {
    final arena = (json['arena'] as Map?)?.cast<String, dynamic>() ?? {};
    final unit = (json['unit'] as Map?)?.cast<String, dynamic>() ?? {};
    return PlayerBooking(
      id: '${json['id'] ?? ''}',
      arenaName: '${arena['name'] ?? 'Arena'}',
      unitName: '${unit['name'] ?? 'Unit'}',
      date: _dateOrNull(json['date']) ?? DateTime.now(),
      startTime: '${json['startTime'] ?? ''}',
      endTime: '${json['endTime'] ?? ''}',
      status: '${json['status'] ?? ''}',
      otp: '${json['otp'] ?? '0000'}',
      totalAmountPaise: _intValue(json['totalAmountPaise']),
    );
  }
}

class BookingPaymentOrder {
  const BookingPaymentOrder({
    required this.paymentId,
    required this.orderId,
    required this.amountPaise,
    required this.currency,
    required this.key,
  });

  final String paymentId;
  final String orderId;
  final int amountPaise;
  final String currency;
  final String? key;

  factory BookingPaymentOrder.fromJson(Map<String, dynamic> json) {
    final payment = (json['payment'] as Map?)?.cast<String, dynamic>() ?? {};
    final order =
        (json['razorpayOrder'] as Map?)?.cast<String, dynamic>() ?? {};
    return BookingPaymentOrder(
      paymentId: '${payment['id'] ?? ''}',
      orderId: '${order['id'] ?? ''}',
      amountPaise: _intValue(order['amount']),
      currency: '${order['currency'] ?? 'INR'}'.trim(),
      key: _stringOrNull(order['key']),
    );
  }
}

class ArenaPaymentsData {
  const ArenaPaymentsData({
    required this.checkedInBookings,
    required this.pendingBookings,
  });
  // Bookings where customer checked in = collection realized
  final List<ArenaReservation> checkedInBookings;
  // Confirmed bookings not yet checked in = balance pending
  final List<ArenaReservation> pendingBookings;

  int get totalCollectedPaise => checkedInBookings.fold(0, (s, b) => s + b.totalAmountPaise);
  int get totalBalancePaise => pendingBookings.fold(0, (s, b) => s + b.totalAmountPaise);
}

class ArenaGuest {
  const ArenaGuest({
    required this.phone,
    required this.name,
    required this.totalBookings,
    required this.totalSpentPaise,
    required this.balanceDuePaise,
    this.lastDate,
    this.recentBookings = const [],
  });

  final String phone;
  final String name;
  final int totalBookings;
  final int totalSpentPaise;
  final int balanceDuePaise;
  final DateTime? lastDate;
  final List<ArenaReservation> recentBookings;

  factory ArenaGuest.fromJson(Map<String, dynamic> json) {
    final bookingsList = (json['bookings'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => ArenaReservation.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return ArenaGuest(
      phone: '${json['phone'] ?? ''}',
      name: '${json['name'] ?? 'Guest'}',
      totalBookings: _intValue(json['totalBookings']),
      totalSpentPaise: _intValue(json['totalSpentPaise']),
      balanceDuePaise: _intValue(json['balanceDuePaise']),
      lastDate: _dateOrNull(json['lastDate']),
      recentBookings: bookingsList,
    );
  }
}

class ArenaSelectedAddon {
  const ArenaSelectedAddon({
    required this.id,
    required this.name,
    required this.pricePaise,
    this.unit = 'per_session',
    this.quantity = 1,
  });

  final String id;
  final String name;
  final int pricePaise;
  final String unit;
  final int quantity;

  int get totalPaise => pricePaise * quantity;
}

class ArenaBookingQuote {
  const ArenaBookingQuote({
    required this.baseAmountPaise,
    required this.addonAmountPaise,
    required this.gstPaise,
    required this.totalAmountPaise,
    required this.durationMins,
  });

  final int baseAmountPaise;
  final int addonAmountPaise;
  final int gstPaise;
  final int totalAmountPaise;
  final int durationMins;
}

class ArenaBookingPricing {
  static ArenaBookingQuote quote({
    required ArenaUnitOption unit,
    required DateTime start,
    required int durationMins,
    List<ArenaSelectedAddon> addons = const [],
  }) {
    final hours = (durationMins / 60).clamp(0, 24);
    final baseAmountPaise = (unit.pricePerHourPaise * hours).round();
    final addonAmountPaise =
        addons.fold<int>(0, (sum, addon) => sum + addon.totalPaise);
    final gstPaise = ((baseAmountPaise + addonAmountPaise) * 0.18).round();
    return ArenaBookingQuote(
      baseAmountPaise: baseAmountPaise,
      addonAmountPaise: addonAmountPaise,
      gstPaise: gstPaise,
      totalAmountPaise: baseAmountPaise + addonAmountPaise + gstPaise,
      durationMins: durationMins,
    );
  }
}

class ArenaAvailabilityEngine {
  static List<AvailabilitySlot> buildUnitSlots({
    required DateTime date,
    required ArenaUnitOption unit,
    required String arenaOpenTime,
    required String arenaCloseTime,
    List<AvailabilitySlot> apiSlots = const [],
  }) {
    if (apiSlots.isNotEmpty) {
      return apiSlots;
    }

    final start = _timeMinutes(arenaOpenTime) ?? (6 * 60);
    final end = _timeMinutes(arenaCloseTime) ?? (23 * 60);
    final slots = <AvailabilitySlot>[];
    for (var current = start; current + 60 <= end; current += 60) {
      slots.add(
        AvailabilitySlot(
          startTime: _formatTime(current),
          endTime: _formatTime(current + 60),
          available: true,
          pricePerHourPaise: unit.pricePerHourPaise,
        ),
      );
    }
    return slots;
  }

  static List<AvailabilitySlot> selectableStartSlots({
    required List<AvailabilitySlot> slots,
    required int durationMins,
  }) {
    if (durationMins <= 60) {
      return slots.where((slot) => slot.available).toList();
    }
    final segmentsNeeded = (durationMins / 60).ceil();
    final result = <AvailabilitySlot>[];
    for (var i = 0; i < slots.length; i++) {
      var ok = true;
      for (var j = 0; j < segmentsNeeded; j++) {
        final idx = i + j;
        if (idx >= slots.length || !slots[idx].available) {
          ok = false;
          break;
        }
      }
      if (ok) {
        final first = slots[i];
        final last = slots[i + segmentsNeeded - 1];
        result.add(
          AvailabilitySlot(
            startTime: first.startTime,
            endTime: last.endTime,
            available: true,
            pricePerHourPaise: first.pricePerHourPaise,
          ),
        );
      }
    }
    return result;
  }
}

class ArenaTimeBlock {
  const ArenaTimeBlock({
    required this.id,
    required this.arenaId,
    required this.unitId,
    required this.startTime,
    required this.endTime,
    this.date,
    this.weekdays = const [],
    this.reason,
    this.isRecurring = false,
    this.isHoliday = false,
  });

  final String id;
  final String arenaId;
  final String unitId;
  final String? date;
  final List<int> weekdays;
  final String startTime;
  final String endTime;
  final String? reason;
  final bool isRecurring;
  final bool isHoliday;

  factory ArenaTimeBlock.fromJson(Map<String, dynamic> json) {
    return ArenaTimeBlock(
      id: '${json['id'] ?? ''}',
      arenaId: '${json['arenaId'] ?? ''}',
      unitId: '${json['unitId'] ?? ''}',
      date: _stringOrNull(json['date']),
      weekdays: ((json['weekdays'] as List?) ?? const [])
          .map((e) => _intValue(e))
          .toList(),
      startTime: '${json['startTime'] ?? ''}',
      endTime: '${json['endTime'] ?? ''}',
      reason: _stringOrNull(json['reason']),
      isRecurring: json['isRecurring'] == true,
      isHoliday: json['isHoliday'] == true,
    );
  }
}

String? _stringOrNull(Object? value) {
  final raw = '$value'.trim();
  if (raw.isEmpty || raw == 'null') return null;
  return raw;
}

int _intValue(Object? value) => _intOrNull(value) ?? 0;

int? _intOrNull(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('${value ?? ''}');
}

double? _doubleOrNull(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse('${value ?? ''}');
}

double _doubleValue(Object? value, {double fallback = 0}) {
  return _doubleOrNull(value) ?? fallback;
}

DateTime? _dateOrNull(Object? value) {
  final raw = _stringOrNull(value);
  if (raw == null) return null;
  return DateTime.tryParse(raw);
}

int? _timeMinutes(String? value) {
  final raw = _stringOrNull(value);
  if (raw == null) return null;
  try {
    if (raw.toUpperCase().contains('AM') || raw.toUpperCase().contains('PM')) {
      final dt = DateFormat('h:mm a').parse(raw);
      return (dt.hour * 60) + dt.minute;
    }
  } catch (_) {}
  final parts = raw.split(':');
  if (parts.length < 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  return (hour * 60) + minute;
}

String _formatTime(int minutes) {
  final safe = minutes.clamp(0, 24 * 60);
  final hour = safe ~/ 60;
  final minute = safe % 60;
  return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
