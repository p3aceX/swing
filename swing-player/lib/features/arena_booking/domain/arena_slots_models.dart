class ArenaSlots {
  const ArenaSlots({
    required this.arena,
    required this.unitGroups,
  });

  final ArenaInfo arena;
  final List<UnitGroupSlots> unitGroups;

  factory ArenaSlots.fromJson(Map<String, dynamic> j) => ArenaSlots(
        arena: ArenaInfo.fromJson(_map(j['arena'])),
        unitGroups: ((j['unitGroups'] as List?) ?? const [])
            .whereType<Map>()
            .map((e) => UnitGroupSlots.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

class ArenaInfo {
  const ArenaInfo({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.photoUrls,
    this.phone,
    this.description,
    required this.hasParking,
    required this.hasLights,
    required this.hasWashrooms,
    required this.hasCanteen,
    required this.hasCCTV,
    required this.hasScorer,
    required this.advanceBookingDays,
    required this.cancellationHours,
  });

  final String id, name, address, city;
  final List<String> photoUrls;
  final String? phone, description;
  final bool hasParking,
      hasLights,
      hasWashrooms,
      hasCanteen,
      hasCCTV,
      hasScorer;
  final int advanceBookingDays, cancellationHours;

  factory ArenaInfo.fromJson(Map<String, dynamic> j) => ArenaInfo(
        id: '${j['id'] ?? ''}',
        name: '${j['name'] ?? 'Arena'}',
        address: '${j['address'] ?? ''}',
        city: '${j['city'] ?? ''}',
        photoUrls: ((j['photoUrls'] as List?) ?? const [])
            .map((e) => '$e')
            .where((e) => e.isNotEmpty)
            .toList(),
        phone: _stringOrNull(j['phone']),
        description: _stringOrNull(j['description']),
        hasParking: j['hasParking'] == true,
        hasLights: j['hasLights'] == true,
        hasWashrooms: j['hasWashrooms'] == true,
        hasCanteen: j['hasCanteen'] == true,
        hasCCTV: j['hasCCTV'] == true,
        hasScorer: j['hasScorer'] == true,
        advanceBookingDays: _intValue(j['advanceBookingDays']),
        cancellationHours: _intValue(j['cancellationHours']),
      );
}

class UnitGroupSlots {
  const UnitGroupSlots({
    required this.groupKey,
    required this.displayName,
    required this.unitType,
    this.unitId,
    this.netType,
    this.netTypes = const [],
    this.totalCount,
    this.description,
    required this.photoUrls,
    required this.minAdvancePaise,
    required this.minSlotMins,
    required this.maxSlotMins,
    required this.pricePerHourPaise,
    this.price4HrPaise,
    this.price8HrPaise,
    required this.weekendMultiplier,
    this.hasFloodlights,
    required this.availableSlots,
    this.minBulkDays,
    this.bulkDayRatePaise,
    this.monthlyPassEnabled = false,
    this.monthlyPassRatePaise,
  });

  final String groupKey, displayName, unitType;
  final String? unitId;
  final String? netType;
  final List<String> netTypes;
  final int? totalCount;
  final String? description;
  final List<String> photoUrls;
  final int minAdvancePaise, minSlotMins, maxSlotMins, pricePerHourPaise;
  final int? price4HrPaise, price8HrPaise;
  final double weekendMultiplier;
  final bool? hasFloodlights;
  final List<AvailableSlot> availableSlots;
  final int? minBulkDays, bulkDayRatePaise;
  final bool monthlyPassEnabled;
  final int? monthlyPassRatePaise;

  bool get isNetGroup => netType != null || netTypes.isNotEmpty;
  bool get isFullyBooked => availableSlots.isEmpty;

  factory UnitGroupSlots.fromJson(Map<String, dynamic> j) => UnitGroupSlots(
        groupKey: '${j['groupKey'] ?? ''}',
        displayName: '${j['displayName'] ?? j['name'] ?? 'Unit'}',
        unitType: '${j['unitType'] ?? ''}',
        unitId: _stringOrNull(j['unitId']),
        netType: _stringOrNull(j['netType']),
        netTypes: ((j['netTypes'] as List?) ?? const [])
            .map((e) => '$e')
            .where((e) => e.isNotEmpty)
            .toList(),
        totalCount: _intOrNull(j['totalCount']),
        description: _stringOrNull(j['description']),
        photoUrls: ((j['photoUrls'] as List?) ?? const [])
            .map((e) => '$e')
            .where((e) => e.isNotEmpty)
            .toList(),
        minAdvancePaise: _intValue(j['minAdvancePaise']),
        minSlotMins: _intValue(j['minSlotMins']),
        maxSlotMins: _intValue(j['maxSlotMins']),
        pricePerHourPaise: _intValue(j['pricePerHourPaise']),
        price4HrPaise: _intOrNull(j['price4HrPaise']),
        price8HrPaise: _intOrNull(j['price8HrPaise']),
        weekendMultiplier: _doubleValue(j['weekendMultiplier'], fallback: 1),
        hasFloodlights: j['hasFloodlights'] as bool?,
        availableSlots: ((j['availableSlots'] as List?) ?? const [])
            .whereType<Map>()
            .map((e) => AvailableSlot.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        minBulkDays: _intOrNull(j['minBulkDays']),
        bulkDayRatePaise: _intOrNull(j['bulkDayRatePaise']),
        monthlyPassEnabled: j['monthlyPassEnabled'] == true,
        monthlyPassRatePaise: _intOrNull(j['monthlyPassRatePaise']),
      );
}

class NetTypeOption {
  const NetTypeOption({
    required this.netType,
    required this.availableCount,
    required this.assignedUnitId,
    required this.totalAmountPaise,
  });

  final String netType;
  final int availableCount;
  final String assignedUnitId;
  final int totalAmountPaise;

  factory NetTypeOption.fromJson(Map<String, dynamic> j) => NetTypeOption(
        netType: '${j['netType'] ?? 'Standard'}',
        availableCount: _intValue(j['availableCount']),
        assignedUnitId: '${j['assignedUnitId'] ?? ''}',
        totalAmountPaise: _intValue(j['totalAmountPaise']),
      );
}

class AvailableSlot {
  const AvailableSlot({
    required this.startTime,
    required this.endTime,
    required this.totalAmountPaise,
    required this.isWeekendRate,
    this.availableCount,
    this.assignedUnitId,
    this.netTypeOptions = const [],
  });

  final String startTime, endTime;
  final int totalAmountPaise;
  final bool isWeekendRate;
  final int? availableCount;
  final String? assignedUnitId;
  final List<NetTypeOption> netTypeOptions;

  factory AvailableSlot.fromJson(Map<String, dynamic> j) => AvailableSlot(
        startTime: '${j['startTime'] ?? ''}',
        endTime: '${j['endTime'] ?? ''}',
        totalAmountPaise: _intValue(j['totalAmountPaise']),
        isWeekendRate: j['isWeekendRate'] == true,
        availableCount: _intOrNull(j['availableCount']),
        assignedUnitId: _stringOrNull(j['assignedUnitId']),
        netTypeOptions: ((j['netTypeOptions'] as List?) ?? const [])
            .whereType<Map>()
            .map((e) => NetTypeOption.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

class SlotHold {
  const SlotHold({required this.holdId, this.expiresInSecs});

  final String holdId;
  final int? expiresInSecs;

  factory SlotHold.fromJson(Map<String, dynamic> j) => SlotHold(
        holdId: '${j['holdId'] ?? j['id'] ?? ''}',
        expiresInSecs: _intOrNull(j['expiresInSecs'] ?? j['expiresIn']),
      );
}

class ArenaPaymentOrder {
  const ArenaPaymentOrder({
    required this.orderId,
    required this.token,
    required this.amountPaise,
    this.redirectUrl,
  });

  final String orderId;
  final String token;
  final int amountPaise;
  final String? redirectUrl;

  factory ArenaPaymentOrder.fromJson(Map<String, dynamic> j) {
    final pp = _map(j['phonePeOrder'] ?? j['phonepeOrder']);
    return ArenaPaymentOrder(
      orderId:
          '${pp['orderId'] ?? pp['merchantOrderId'] ?? j['orderId'] ?? j['merchantOrderId'] ?? ''}',
      token:
          '${pp['token'] ?? pp['orderToken'] ?? j['token'] ?? j['orderToken'] ?? ''}',
      amountPaise: _intValue(pp['amountPaise'] ?? j['amountPaise']),
      redirectUrl: _stringOrNull(pp['redirectUrl'] ?? j['redirectUrl']),
    );
  }
}

Map<String, dynamic> _map(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

String? _stringOrNull(Object? value) {
  final raw = '${value ?? ''}'.trim();
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
