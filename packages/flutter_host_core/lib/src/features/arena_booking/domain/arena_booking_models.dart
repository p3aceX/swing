import 'package:intl/intl.dart';

class ArenaListing {
  const ArenaListing({
    required this.id,
    required this.name,
    required this.address,
    required this.openTime,
    required this.closeTime,
    required this.units,
    this.photoUrls = const [],
    this.description = '',
    this.sports = const ['Cricket'],
    this.bufferMins = 0,
    this.cancellationHours = 0,
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
  final String openTime;
  final String closeTime;
  final List<String> photoUrls;
  final String description;
  final List<String> sports;
  final int bufferMins;
  final int cancellationHours;
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
      openTime: '${json['openTime'] ?? '06:00'}',
      closeTime: '${json['closeTime'] ?? '23:00'}',
      photoUrls: ((json['photoUrls'] as List?) ?? const [])
          .map((e) => '$e')
          .where((e) => e.isNotEmpty)
          .toList(),
      description: '${json['description'] ?? ''}',
      sports: ((json['sports'] as List?) ?? const ['Cricket'])
          .map((e) => '$e')
          .where((e) => e.isNotEmpty)
          .toList(),
      bufferMins: _intValue(json['bufferMins']),
      cancellationHours: _intValue(json['cancellationHours']),
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
    this.boundarySize,
  });

  final String id;
  final String name;
  final String unitType;
  final int pricePerHourPaise;
  final int? boundarySize;

  factory ArenaUnitOption.fromJson(Map<String, dynamic> json) {
    return ArenaUnitOption(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? 'Unit'}',
      unitType: '${json['unitType'] ?? json['type'] ?? 'OTHER'}',
      pricePerHourPaise: _intValue(json['pricePerHourPaise'] ?? json['price']),
      boundarySize: _intOrNull(json['boundarySize']),
    );
  }
}

class ArenaAddon {
  const ArenaAddon({
    required this.id,
    required this.name,
    required this.pricePaise,
    this.unit = 'per_session',
  });

  final String id;
  final String name;
  final int pricePaise;
  final String unit;

  factory ArenaAddon.fromJson(Map<String, dynamic> json) {
    return ArenaAddon(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? 'Addon'}',
      pricePaise: _intValue(json['pricePaise'] ?? json['price']),
      unit: '${json['unit'] ?? 'per_session'}',
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
    this.baseAmountPaise,
    this.gstPaise,
    this.addonAmountPaise,
    this.notes,
    this.paymentMode,
  });

  final String id;
  final String status;
  final int totalAmountPaise;
  final DateTime? bookingDate;
  final String startTime;
  final String endTime;
  final String arenaId;
  final String unitId;
  final int? baseAmountPaise;
  final int? gstPaise;
  final int? addonAmountPaise;
  final String? notes;
  final String? paymentMode;

  factory ArenaReservation.fromJson(Map<String, dynamic> json) {
    return ArenaReservation(
      id: '${json['id'] ?? ''}',
      status: '${json['status'] ?? 'PENDING_PAYMENT'}'.trim(),
      totalAmountPaise:
          _intValue(json['totalAmountPaise'] ?? json['totalPricePaise']),
      bookingDate: _dateOrNull(json['date']),
      startTime: '${json['startTime'] ?? ''}'.trim(),
      endTime: '${json['endTime'] ?? ''}'.trim(),
      arenaId: '${json['arenaId'] ?? ''}',
      unitId: '${json['unitId'] ?? ''}',
      baseAmountPaise: _intOrNull(json['baseAmountPaise']),
      gstPaise: _intOrNull(json['gstPaise']),
      addonAmountPaise: _intOrNull(json['addonAmountPaise']),
      notes: _stringOrNull(json['notes']),
      paymentMode: _stringOrNull(json['paymentMode']),
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
