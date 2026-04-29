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
    this.citySlug,
    this.arenaSlug,
    this.customSlug,
    this.isPublicPage = true,
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
  final String? citySlug;
  final String? arenaSlug;
  final String? customSlug;
  final bool isPublicPage;

  factory ArenaListing.fromJson(Map<String, dynamic> json) {
    final rawUnits = (json['units'] as List?) ?? const [];
    final units = rawUnits
        .whereType<Map>()
        .map((e) => ArenaUnitOption.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    // Derive arena hours from units: earliest open → latest close
    final arenaOpen = '${json['openTime'] ?? '06:00'}';
    final arenaClose = '${json['closeTime'] ?? '23:00'}';
    final unitOpenTimes = units.map((u) => u.openTime).whereType<String>().toList();
    final unitCloseTimes = units.map((u) => u.closeTime).whereType<String>().toList();
    final effectiveOpen = unitOpenTimes.isEmpty
        ? arenaOpen
        : unitOpenTimes.reduce((a, b) => a.compareTo(b) <= 0 ? a : b);
    final effectiveClose = unitCloseTimes.isEmpty
        ? arenaClose
        : unitCloseTimes.reduce((a, b) => a.compareTo(b) >= 0 ? a : b);

    return ArenaListing(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? 'Arena'}',
      address: '${json['address'] ?? json['location'] ?? ''}',
      city: '${json['city'] ?? ''}',
      state: '${json['state'] ?? ''}',
      pincode: '${json['pincode'] ?? ''}',
      openTime: effectiveOpen,
      closeTime: effectiveClose,
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
      units: units,
      latitude: _doubleOrNull(json['latitude']),
      longitude: _doubleOrNull(json['longitude']),
      citySlug: _stringOrNull(json['citySlug']),
      arenaSlug: _stringOrNull(json['arenaSlug']),
      customSlug: _stringOrNull(json['customSlug']),
      isPublicPage: json['isPublicPage'] != false,
    );
  }
}

class NetVariant {
  const NetVariant({
    required this.type,
    required this.label,
    this.count = 1,
    this.pricePaise,
    this.hasFloodlights = false,
  });

  final String type;
  final String label;
  final int count;
  final int? pricePaise;
  final bool hasFloodlights;

  factory NetVariant.fromJson(Map<String, dynamic> json) {
    return NetVariant(
      type: '${json['type'] ?? ''}',
      label: '${json['label'] ?? json['type'] ?? ''}',
      count: _intValue(json['count'] ?? 1),
      pricePaise: _intOrNull(json['pricePaise']),
      hasFloodlights: json['hasFloodlights'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'label': label,
    'count': count,
    if (pricePaise != null) 'pricePaise': pricePaise,
    'hasFloodlights': hasFloodlights,
  };
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
    this.turnaroundMins = 0,
    this.minAdvancePaise = 0,
    this.boundarySize,
    this.parentUnitId,
    this.addons = const [],
    this.openTime,
    this.closeTime,
    this.operatingDays = const [],
    this.hasFloodlights = false,
    this.advanceBookingDays,
    this.bufferMins,
    this.cancellationHours,
    this.minBulkDays,
    this.bulkDayRatePaise,
    this.monthlyPassEnabled = false,
    this.monthlyPassRatePaise,
    this.netVariants = const [],
  });

  final String id;
  final String name;
  final String unitType;
  final String? unitTypeLabel;
  final String? netType;
  final List<NetVariant> netVariants;
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
  final int turnaroundMins;
  final int minAdvancePaise;
  final int? boundarySize;
  final String? parentUnitId;
  final List<ArenaAddon> addons;
  final String? openTime;
  final String? closeTime;
  final List<int> operatingDays;
  final bool hasFloodlights;
  final int? advanceBookingDays;
  final int? bufferMins;
  final int? cancellationHours;
  final int? minBulkDays;
  final int? bulkDayRatePaise;
  final bool monthlyPassEnabled;
  final int? monthlyPassRatePaise;

  bool get isNet => unitType == 'CRICKET_NET' || unitType == 'INDOOR_NET';
  bool get isGround => unitType == 'FULL_GROUND' || unitType == 'HALF_GROUND';

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
      turnaroundMins: _intValue(json['turnaroundMins'] ?? 0),
      minAdvancePaise: _intValue(json['minAdvancePaise']),
      boundarySize: _intOrNull(json['boundarySize']),
      parentUnitId: _stringOrNull(json['parentUnitId']),
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
      advanceBookingDays: _intOrNull(json['advanceBookingDays']),
      bufferMins: _intOrNull(json['bufferMins']),
      cancellationHours: _intOrNull(json['cancellationHours']),
      minBulkDays: _intOrNull(json['minBulkDays']),
      bulkDayRatePaise: _intOrNull(json['bulkDayRatePaise']),
      monthlyPassEnabled: json['monthlyPassEnabled'] == true,
      monthlyPassRatePaise: _intOrNull(json['monthlyPassRatePaise']),
      netVariants: ((json['netVariants'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => NetVariant.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  bool get hasVariants => netVariants.isNotEmpty;
}

// ── Monthly Pass ──────────────────────────────────────────────────────────────

class MonthlyPass {
  const MonthlyPass({
    required this.id,
    required this.arenaId,
    required this.unitId,
    required this.guestName,
    required this.guestPhone,
    required this.startTime,
    required this.endTime,
    required this.daysOfWeek,
    required this.startDate,
    required this.endDate,
    required this.totalAmountPaise,
    required this.advancePaise,
    required this.paymentMode,
    required this.status,
    this.notes,
    this.sessionCount = 0,
    this.skippedDates = const [],
    this.bookings = const [],
  });

  final String id;
  final String arenaId;
  final String unitId;
  final String guestName;
  final String guestPhone;
  final String startTime;
  final String endTime;
  final List<int> daysOfWeek;
  final String startDate;
  final String endDate;
  final int totalAmountPaise;
  final int advancePaise;
  final String paymentMode;
  final String status;
  final String? notes;
  final int sessionCount;
  final List<String> skippedDates;
  final List<ArenaReservation> bookings;

  bool get isActive => status == 'ACTIVE';
  int get balancePaise => (totalAmountPaise - advancePaise).clamp(0, totalAmountPaise);

  static const _dayNames = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  String get daysLabel => daysOfWeek
      .where((d) => d >= 1 && d <= 7)
      .map((d) => _dayNames[d])
      .join(' / ');

  factory MonthlyPass.fromJson(Map<String, dynamic> json) {
    return MonthlyPass(
      id: '${json['id'] ?? ''}',
      arenaId: '${json['arenaId'] ?? ''}',
      unitId: '${json['unitId'] ?? ''}',
      guestName: '${json['guestName'] ?? ''}',
      guestPhone: '${json['guestPhone'] ?? ''}',
      startTime: '${json['startTime'] ?? ''}',
      endTime: '${json['endTime'] ?? ''}',
      daysOfWeek: ((json['daysOfWeek'] as List?) ?? const [])
          .map((e) => _intValue(e))
          .where((d) => d >= 1 && d <= 7)
          .toList(),
      startDate: '${json['startDate'] ?? ''}'.substring(0, 10),
      endDate: '${json['endDate'] ?? ''}'.substring(0, 10),
      totalAmountPaise: _intValue(json['totalAmountPaise']),
      advancePaise: _intValue(json['advancePaise']),
      paymentMode: '${json['paymentMode'] ?? 'CASH'}',
      status: '${json['status'] ?? 'ACTIVE'}',
      notes: _stringOrNull(json['notes']),
      sessionCount: _intValue(json['sessionCount']),
      skippedDates: ((json['skippedDates'] as List?) ?? const [])
          .map((e) => '$e')
          .toList(),
      bookings: ((json['bookings'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => ArenaReservation.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
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
    this.totalSlotPaise,
    this.assignedUnitId,
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
  /// Backend-computed total for the full slot duration (base only, no GST). Populated from /slots endpoint.
  final int? totalSlotPaise;
  /// The specific unit assigned for this slot (used for NETS grouping). Populated from /slots endpoint.
  final String? assignedUnitId;

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

  int get balancePaise =>
      (totalAmountPaise - advancePaise).clamp(0, totalAmountPaise);
  bool get hasBalance => balancePaise > 0 && paidAt == null;

  String get displayName =>
      guestName ?? customerName ?? (isOfflineBooking ? 'Walk-in' : 'Player');

  String get displayPhone => guestPhone ?? customerPhone ?? '';

  bool get isPaid =>
      paidAt != null || status == 'CHECKED_IN' || status == 'COMPLETED';

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
    required this.arenaId,
    required this.unitId,
    this.arenaName,
    this.unitName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.otp,
    required this.baseAmountPaise,
    required this.gstPaise,
    required this.addonAmountPaise,
    required this.totalAmountPaise,
    this.paymentMode,
    this.cancellationReason,
    this.checkedInAt,
    this.paidAt,
    this.addonNames = const [],
  });

  final String id;
  final String arenaId;
  final String unitId;
  final String? arenaName;
  final String? unitName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String status;
  final String otp;
  final int baseAmountPaise;
  final int gstPaise;
  final int addonAmountPaise;
  final int totalAmountPaise;
  final String? paymentMode;
  final String? cancellationReason;
  final DateTime? checkedInAt;
  final DateTime? paidAt;
  final List<String> addonNames;

  factory PlayerBooking.fromJson(Map<String, dynamic> json) {
    final arena = (json['arena'] as Map?)?.cast<String, dynamic>() ?? {};
    final unit = (json['unit'] as Map?)?.cast<String, dynamic>() ?? {};
    final addons =
        ((json['addons'] ?? json['bookingAddons']) as List?) ?? const [];
    return PlayerBooking(
      id: '${json['id'] ?? ''}',
      arenaId: '${json['arenaId'] ?? arena['id'] ?? ''}',
      unitId: '${json['unitId'] ?? unit['id'] ?? ''}',
      arenaName:
          _stringOrNull(json['arenaName']) ?? _stringOrNull(arena['name']),
      unitName: _stringOrNull(json['unitName']) ?? _stringOrNull(unit['name']),
      date: _dateOrNull(json['date'] ?? json['bookingDate']) ?? DateTime.now(),
      startTime: '${json['startTime'] ?? ''}',
      endTime: '${json['endTime'] ?? ''}',
      status: '${json['status'] ?? ''}',
      otp: '${json['otp'] ?? json['checkInOtp'] ?? ''}',
      baseAmountPaise: _intValue(json['baseAmountPaise']),
      gstPaise: _intValue(json['gstPaise']),
      addonAmountPaise: _intValue(json['addonAmountPaise']),
      totalAmountPaise:
          _intValue(json['totalAmountPaise'] ?? json['totalPricePaise']),
      paymentMode: _stringOrNull(json['paymentMode']),
      cancellationReason: _stringOrNull(json['cancellationReason']),
      checkedInAt: _dateOrNull(json['checkedInAt']),
      paidAt: _dateOrNull(json['paidAt']),
      addonNames: addons
          .whereType<Map>()
          .map((e) => _stringOrNull(e['name'] ?? (e['addon'] as Map?)?['name']))
          .whereType<String>()
          .toList(),
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
      paymentId: '${payment['id'] ?? json['paymentId'] ?? ''}',
      orderId: '${order['id'] ?? json['orderId'] ?? ''}',
      amountPaise: _intValue(order['amount'] ?? json['amountPaise']),
      currency: '${order['currency'] ?? json['currency'] ?? 'INR'}'.trim(),
      key: _stringOrNull(order['key']) ?? _stringOrNull(json['key']),
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

  int get totalCollectedPaise =>
      checkedInBookings.fold(0, (s, b) => s + b.totalAmountPaise);
  int get totalBalancePaise =>
      pendingBookings.fold(0, (s, b) => s + b.totalAmountPaise);
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
    int? precomputedBasePaise,
  }) {
    final int baseAmountPaise;
    if (precomputedBasePaise != null) {
      baseAmountPaise = precomputedBasePaise;
    } else {
      int base;
      if (durationMins == 240 && unit.price4HrPaise != null) {
        base = unit.price4HrPaise!;
      } else if (durationMins == 480 && unit.price8HrPaise != null) {
        base = unit.price8HrPaise!;
      } else if (durationMins == 720 && unit.priceFullDayPaise != null) {
        base = unit.priceFullDayPaise!;
      } else {
        final hours = (durationMins / 60).clamp(0.0, 24.0);
        base = (unit.pricePerHourPaise * hours).round();
      }
      final weekday = start.weekday; // 1=Mon, 7=Sun
      final isWeekend = weekday == 6 || weekday == 7;
      if (isWeekend && unit.weekendMultiplier != 1.0) {
        base = (base * unit.weekendMultiplier).round();
      }
      baseAmountPaise = base;
    }
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

class PlayerAvailableSlot {
  const PlayerAvailableSlot({
    required this.startTime,
    required this.endTime,
    required this.totalAmountPaise,
    required this.assignedUnitId,
    this.isWeekendRate = false,
    this.availableCount,
    this.netTypeOptions,
  });

  final String startTime;
  final String endTime;
  final int totalAmountPaise;
  final String assignedUnitId;
  final bool isWeekendRate;
  final int? availableCount;
  final List<Map<String, dynamic>>? netTypeOptions;

  factory PlayerAvailableSlot.fromJson(Map<String, dynamic> json) {
    final opts = (json['netTypeOptions'] as List?)
        ?.whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    return PlayerAvailableSlot(
      startTime: '${json['startTime'] ?? ''}',
      endTime: '${json['endTime'] ?? ''}',
      totalAmountPaise: _intValue(json['totalAmountPaise']),
      assignedUnitId: '${json['assignedUnitId'] ?? ''}',
      isWeekendRate: json['isWeekendRate'] == true,
      availableCount: _intOrNull(json['availableCount']),
      netTypeOptions: opts,
    );
  }
}

class PlayerUnitGroup {
  const PlayerUnitGroup({
    required this.groupKey,
    required this.displayName,
    required this.unitType,
    required this.pricePerHourPaise,
    required this.minSlotMins,
    required this.maxSlotMins,
    required this.minAdvancePaise,
    required this.availableSlots,
    this.unitId,
    this.netTypes,
    this.totalCount = 1,
    this.price4HrPaise,
    this.price8HrPaise,
    this.weekendMultiplier = 1.0,
    this.hasFloodlights = false,
    this.photoUrls = const [],
    this.description,
  });

  final String groupKey;
  final String displayName;
  final String unitType;
  final String? unitId;
  final List<String>? netTypes;
  final int totalCount;
  final int pricePerHourPaise;
  final int? price4HrPaise;
  final int? price8HrPaise;
  final double weekendMultiplier;
  final int minSlotMins;
  final int maxSlotMins;
  final int minAdvancePaise;
  final bool hasFloodlights;
  final List<String> photoUrls;
  final String? description;
  final List<PlayerAvailableSlot> availableSlots;

  bool get isNetsGroup => groupKey == 'NETS';

  factory PlayerUnitGroup.fromJson(Map<String, dynamic> json) {
    final slots = (json['availableSlots'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => PlayerAvailableSlot.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final netTypes = (json['netTypes'] as List?)
        ?.map((e) => '$e')
        .toList();
    return PlayerUnitGroup(
      groupKey: '${json['groupKey'] ?? ''}',
      displayName: '${json['displayName'] ?? ''}',
      unitType: '${json['unitType'] ?? ''}',
      unitId: _stringOrNull(json['unitId']),
      netTypes: netTypes,
      totalCount: _intValue(json['totalCount'] ?? 1),
      pricePerHourPaise: _intValue(json['pricePerHourPaise']),
      price4HrPaise: _intOrNull(json['price4HrPaise']),
      price8HrPaise: _intOrNull(json['price8HrPaise']),
      weekendMultiplier: _doubleValue(json['weekendMultiplier'], fallback: 1),
      minSlotMins: _intValue(json['minSlotMins'] ?? 60),
      maxSlotMins: _intValue(json['maxSlotMins'] ?? 480),
      minAdvancePaise: _intValue(json['minAdvancePaise'] ?? 0),
      hasFloodlights: json['hasFloodlights'] == true,
      photoUrls: (json['photoUrls'] as List? ?? const []).map((e) => '$e').toList(),
      description: _stringOrNull(json['description']),
      availableSlots: slots,
    );
  }
}

class PlayerSlotsData {
  const PlayerSlotsData({
    required this.unitGroups,
  });

  final List<PlayerUnitGroup> unitGroups;

  factory PlayerSlotsData.fromJson(Map<String, dynamic> json) {
    final groups = (json['unitGroups'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => PlayerUnitGroup.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return PlayerSlotsData(unitGroups: groups);
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
