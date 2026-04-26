class ArenaOwnerProfile {
  const ArenaOwnerProfile({
    required this.id,
    required this.businessName,
    required this.gstNumber,
    required this.panNumber,
    required this.userName,
    required this.userPhone,
  });

  final String id;
  final String? businessName;
  final String? gstNumber;
  final String? panNumber;
  final String? userName;
  final String? userPhone;

  factory ArenaOwnerProfile.fromJson(Map<String, dynamic> j) {
    final user = j['user'];
    String? userName;
    String? userPhone;
    if (user is Map) {
      final m = Map<String, dynamic>.from(user);
      userName = m['name']?.toString();
      userPhone = m['phone']?.toString();
    }
    return ArenaOwnerProfile(
      id: j['id']?.toString() ?? '',
      businessName: j['businessName']?.toString(),
      gstNumber: j['gstNumber']?.toString(),
      panNumber: j['panNumber']?.toString(),
      userName: userName,
      userPhone: userPhone,
    );
  }
}

class ArenaUnitDetail {
  const ArenaUnitDetail({
    required this.id,
    required this.name,
    required this.unitType,
    required this.pricePerHourPaise,
    required this.isActive,
    this.sport,
    this.capacity,
    this.description,
    this.photoUrls = const [],
    this.peakPricePaise,
    this.peakHoursStart,
    this.peakHoursEnd,
    this.price4HrPaise,
    this.price8HrPaise,
    this.priceFullDayPaise,
    this.boundarySize,
    this.weekendMultiplier,
    this.minSlotMins,
    this.maxSlotMins,
    this.slotIncrementMins,
  });

  final String id;
  final String name;
  final String unitType;
  final String? sport;
  final int? capacity;
  final String? description;
  final List<String> photoUrls;
  final int pricePerHourPaise;
  final int? peakPricePaise;
  final String? peakHoursStart;
  final String? peakHoursEnd;
  final int? price4HrPaise;
  final int? price8HrPaise;
  final int? priceFullDayPaise;
  final int? boundarySize;
  final double? weekendMultiplier;
  final int? minSlotMins;
  final int? maxSlotMins;
  final int? slotIncrementMins;
  final bool isActive;

  factory ArenaUnitDetail.fromJson(Map<String, dynamic> j) {
    return ArenaUnitDetail(
      id: j['id']?.toString() ?? '',
      name: j['name']?.toString() ?? '—',
      unitType: j['unitType']?.toString() ?? '',
      sport: j['sport']?.toString(),
      capacity: j['capacity'] is int ? j['capacity'] as int : null,
      description: j['description']?.toString(),
      photoUrls: j['photoUrls'] is List
          ? (j['photoUrls'] as List)
              .map((e) => e?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList()
          : const [],
      pricePerHourPaise:
          j['pricePerHourPaise'] is int ? j['pricePerHourPaise'] as int : 0,
      peakPricePaise: j['peakPricePaise'] is int ? j['peakPricePaise'] as int : null,
      peakHoursStart: j['peakHoursStart']?.toString(),
      peakHoursEnd: j['peakHoursEnd']?.toString(),
      price4HrPaise: j['price4HrPaise'] is int ? j['price4HrPaise'] as int : null,
      price8HrPaise: j['price8HrPaise'] is int ? j['price8HrPaise'] as int : null,
      priceFullDayPaise:
          j['priceFullDayPaise'] is int ? j['priceFullDayPaise'] as int : null,
      boundarySize: j['boundarySize'] is int ? j['boundarySize'] as int : null,
      weekendMultiplier: j['weekendMultiplier'] is num
          ? (j['weekendMultiplier'] as num).toDouble()
          : null,
      minSlotMins: j['minSlotMins'] is int ? j['minSlotMins'] as int : null,
      maxSlotMins: j['maxSlotMins'] is int ? j['maxSlotMins'] as int : null,
      slotIncrementMins:
          j['slotIncrementMins'] is int ? j['slotIncrementMins'] as int : null,
      isActive: j['isActive'] != false,
    );
  }
}

class ArenaTimeBlockDetail {
  const ArenaTimeBlockDetail({
    required this.id,
    required this.unitId,
    required this.unitName,
    required this.startTime,
    required this.endTime,
    required this.isRecurring,
    this.reason,
    this.date,
    this.weekdays = const [],
  });

  final String id;
  final String unitId;
  final String unitName;
  final DateTime? date;
  final String startTime;
  final String endTime;
  final String? reason;
  final bool isRecurring;
  final List<int> weekdays;

  factory ArenaTimeBlockDetail.fromJson(Map<String, dynamic> j) {
    return ArenaTimeBlockDetail(
      id: j['id']?.toString() ?? '',
      unitId: j['unitId']?.toString() ?? '',
      unitName: (j['unit'] is Map)
          ? (j['unit']['name']?.toString() ?? 'Unit')
          : 'Unit',
      date: DateTime.tryParse(j['date']?.toString() ?? ''),
      startTime: j['startTime']?.toString() ?? '',
      endTime: j['endTime']?.toString() ?? '',
      reason: j['reason']?.toString(),
      isRecurring: j['isRecurring'] == true,
      weekdays: j['weekdays'] is List
          ? (j['weekdays'] as List)
              .whereType<num>()
              .map((e) => e.toInt())
              .toList()
          : const [],
    );
  }
}

class ArenaBookingDetail {
  const ArenaBookingDetail({
    required this.id,
    required this.unitName,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.totalAmountPaise,
    this.date,
    this.customerName,
    this.customerPhone,
    this.notes,
    this.paidAt,
    this.checkedInAt,
  });

  final String id;
  final String unitName;
  final String status;
  final DateTime? date;
  final String startTime;
  final String endTime;
  final int totalAmountPaise;
  final String? customerName;
  final String? customerPhone;
  final String? notes;
  final DateTime? paidAt;
  final DateTime? checkedInAt;

  factory ArenaBookingDetail.fromJson(Map<String, dynamic> j) {
    final bookedBy = j['bookedBy'];
    String? customerName;
    String? customerPhone;
    if (bookedBy is Map) {
      final bookedByMap = Map<String, dynamic>.from(bookedBy);
      final user = bookedByMap['user'];
      if (user is Map) {
        final userMap = Map<String, dynamic>.from(user);
        customerName = userMap['name']?.toString();
        customerPhone = userMap['phone']?.toString();
      }
    }
    return ArenaBookingDetail(
      id: j['id']?.toString() ?? '',
      unitName: (j['unit'] is Map)
          ? (j['unit']['name']?.toString() ?? 'Unit')
          : 'Unit',
      status: j['status']?.toString() ?? '',
      date: DateTime.tryParse(j['date']?.toString() ?? ''),
      startTime: j['startTime']?.toString() ?? '',
      endTime: j['endTime']?.toString() ?? '',
      totalAmountPaise:
          j['totalAmountPaise'] is int ? j['totalAmountPaise'] as int : 0,
      customerName: customerName,
      customerPhone: customerPhone,
      notes: j['notes']?.toString(),
      paidAt: DateTime.tryParse(j['paidAt']?.toString() ?? ''),
      checkedInAt: DateTime.tryParse(j['checkedInAt']?.toString() ?? ''),
    );
  }
}

class ArenaManagerDetail {
  const ArenaManagerDetail({
    required this.id,
    required this.name,
    required this.phone,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String phone;
  final bool isActive;
  final DateTime? createdAt;

  factory ArenaManagerDetail.fromJson(Map<String, dynamic> j) {
    return ArenaManagerDetail(
      id: j['id']?.toString() ?? '',
      name: j['name']?.toString() ?? '—',
      phone: j['phone']?.toString() ?? '',
      isActive: j['isActive'] == true,
      createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? ''),
    );
  }
}

class ArenaAvailabilitySlotDetail {
  const ArenaAvailabilitySlotDetail({
    required this.start,
    required this.end,
    required this.available,
    required this.status,
    required this.pricePerHourPaise,
    this.reason,
    this.bookingId,
    this.customerName,
  });

  final String start;
  final String end;
  final bool available;
  final String status;
  final int pricePerHourPaise;
  final String? reason;
  final String? bookingId;
  final String? customerName;

  factory ArenaAvailabilitySlotDetail.fromJson(Map<String, dynamic> j) {
    return ArenaAvailabilitySlotDetail(
      start: j['start']?.toString() ?? '',
      end: j['end']?.toString() ?? '',
      available: j['available'] == true,
      status: j['status']?.toString() ?? '',
      pricePerHourPaise:
          j['pricePerHourPaise'] is int ? j['pricePerHourPaise'] as int : 0,
      reason: j['reason']?.toString(),
      bookingId: j['bookingId']?.toString(),
      customerName: j['customerName']?.toString(),
    );
  }
}

class ArenaAvailabilityUnitDetail {
  const ArenaAvailabilityUnitDetail({
    required this.unitId,
    required this.unitName,
    required this.slots,
  });

  final String unitId;
  final String unitName;
  final List<ArenaAvailabilitySlotDetail> slots;

  factory ArenaAvailabilityUnitDetail.fromJson(Map<String, dynamic> j) {
    return ArenaAvailabilityUnitDetail(
      unitId: (j['unit'] is Map)
          ? (j['unit']['id']?.toString() ?? j['unitId']?.toString() ?? '')
          : j['unitId']?.toString() ?? '',
      unitName: (j['unit'] is Map)
          ? (j['unit']['name']?.toString() ?? 'Unit')
          : j['unitName']?.toString() ?? 'Unit',
      slots: j['slots'] is List
          ? (j['slots'] as List)
              .whereType<Map>()
              .map((e) => ArenaAvailabilitySlotDetail.fromJson(
                  Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }
}

class ArenaStatsDetail {
  const ArenaStatsDetail({
    required this.totalBookings,
    required this.completedBookings,
    required this.totalRevenuePaise,
  });

  final int totalBookings;
  final int completedBookings;
  final int totalRevenuePaise;

  factory ArenaStatsDetail.fromJson(Map<String, dynamic> j) {
    return ArenaStatsDetail(
      totalBookings: j['totalBookings'] is int ? j['totalBookings'] as int : 0,
      completedBookings:
          j['completedBookings'] is int ? j['completedBookings'] as int : 0,
      totalRevenuePaise:
          j['totalRevenuePaise'] is int ? j['totalRevenuePaise'] as int : 0,
    );
  }
}

class ArenaDetail {
  const ArenaDetail({
    required this.id,
    required this.name,
    required this.city,
    required this.state,
    required this.address,
    required this.photoUrls,
    required this.sports,
    required this.openTime,
    required this.closeTime,
    required this.operatingDays,
    required this.verified,
    required this.swingEnabled,
    required this.isActive,
    required this.unitCount,
    this.description,
    this.pincode,
    this.latitude,
    this.longitude,
    this.phone,
    this.hasParking = false,
    this.hasLights = false,
    this.hasWashrooms = false,
    this.hasCanteen = false,
    this.hasCCTV = false,
    this.hasScorer = false,
    this.advanceBookingDays,
    this.bufferMins,
    this.cancellationHours,
    this.planTier,
    this.planExpiresAt,
    this.arenaGrade,
    this.verifiedAt,
    this.rating = 0,
    this.totalRatings = 0,
    this.owner,
    this.units = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String city;
  final String state;
  final String address;
  final List<String> photoUrls;
  final List<String> sports;
  final String openTime;
  final String closeTime;
  final List<int> operatingDays;
  final bool verified;
  final bool swingEnabled;
  final bool isActive;
  final int unitCount;
  final String? description;
  final String? pincode;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final bool hasParking;
  final bool hasLights;
  final bool hasWashrooms;
  final bool hasCanteen;
  final bool hasCCTV;
  final bool hasScorer;
  final int? advanceBookingDays;
  final int? bufferMins;
  final int? cancellationHours;
  final String? planTier;
  final DateTime? planExpiresAt;
  final String? arenaGrade;
  final DateTime? verifiedAt;
  final double rating;
  final int totalRatings;
  final ArenaOwnerProfile? owner;
  final List<ArenaUnitDetail> units;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ArenaDetail.fromJson(Map<String, dynamic> j) {
    final owner = j['owner'];
    final units = j['units'];
    return ArenaDetail(
      id: j['id']?.toString() ?? '',
      name: j['name']?.toString() ?? '—',
      city: j['city']?.toString() ?? '',
      state: j['state']?.toString() ?? '',
      address: j['address']?.toString() ?? '',
      photoUrls: j['photoUrls'] is List
          ? (j['photoUrls'] as List)
              .map((e) => e?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList()
          : const [],
      sports: j['sports'] is List
          ? (j['sports'] as List)
              .map((e) => e?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList()
          : const [],
      openTime: j['openTime']?.toString() ?? '',
      closeTime: j['closeTime']?.toString() ?? '',
      operatingDays: j['operatingDays'] is List
          ? (j['operatingDays'] as List)
              .whereType<num>()
              .map((e) => e.toInt())
              .toList()
          : const [],
      verified: j['isVerified'] == true,
      swingEnabled: j['isSwingArena'] == true,
      isActive: j['isActive'] != false,
      unitCount: units is List ? units.length : 0,
      description: j['description']?.toString(),
      pincode: j['pincode']?.toString(),
      latitude: j['latitude'] is num ? (j['latitude'] as num).toDouble() : null,
      longitude:
          j['longitude'] is num ? (j['longitude'] as num).toDouble() : null,
      phone: j['phone']?.toString(),
      hasParking: j['hasParking'] == true,
      hasLights: j['hasLights'] == true,
      hasWashrooms: j['hasWashrooms'] == true,
      hasCanteen: j['hasCanteen'] == true,
      hasCCTV: j['hasCCTV'] == true,
      hasScorer: j['hasScorer'] == true,
      advanceBookingDays:
          j['advanceBookingDays'] is int ? j['advanceBookingDays'] as int : null,
      bufferMins: j['bufferMins'] is int ? j['bufferMins'] as int : null,
      cancellationHours:
          j['cancellationHours'] is int ? j['cancellationHours'] as int : null,
      planTier: j['planTier']?.toString(),
      planExpiresAt: DateTime.tryParse(j['planExpiresAt']?.toString() ?? ''),
      arenaGrade: j['arenaGrade']?.toString(),
      verifiedAt: DateTime.tryParse(j['verifiedAt']?.toString() ?? ''),
      rating: j['rating'] is num ? (j['rating'] as num).toDouble() : 0,
      totalRatings:
          j['totalRatings'] is int ? j['totalRatings'] as int : 0,
      owner: owner is Map
          ? ArenaOwnerProfile.fromJson(Map<String, dynamic>.from(owner))
          : null,
      units: units is List
          ? units
              .whereType<Map>()
              .map((e) => ArenaUnitDetail.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(j['updatedAt']?.toString() ?? ''),
    );
  }
}
