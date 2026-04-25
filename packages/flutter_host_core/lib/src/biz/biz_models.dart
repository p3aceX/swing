enum BizProfileType { academy, coach, arena, arenaManager, store }

BizProfileType? bizProfileTypeFromString(String value) {
  switch (value.toUpperCase()) {
    case 'ACADEMY':
      return BizProfileType.academy;
    case 'COACH':
      return BizProfileType.coach;
    case 'ARENA':
      return BizProfileType.arena;
    case 'ARENA_MANAGER':
      return BizProfileType.arenaManager;
    case 'STORE':
      return BizProfileType.store;
    default:
      return null;
  }
}

String bizProfileTypeToString(BizProfileType type) {
  return type.name.toUpperCase();
}

class BizUser {
  const BizUser({
    required this.id,
    required this.phone,
    this.name,
    this.email,
    this.photoUrl,
  });

  final String id;
  final String phone;
  final String? name;
  final String? email;
  final String? photoUrl;

  factory BizUser.fromJson(Map<String, dynamic> json) => BizUser(
        id: _string(json['id']),
        phone: _string(json['phone']),
        name: _nullableString(json['name']),
        email: _nullableString(json['email']),
        photoUrl: _nullableString(json['photoUrl']),
      );
}

class BusinessAccount {
  const BusinessAccount({
    required this.id,
    required this.ownerId,
    required this.businessName,
    this.description,
    this.contactName,
    this.phone,
    this.email,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.gstNumber,
    this.panNumber,
    this.onboardingComplete = false,
  });

  final String id;
  final String ownerId;
  final String businessName;
  final String? description;
  final String? contactName;
  final String? phone;
  final String? email;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? gstNumber;
  final String? panNumber;
  final bool onboardingComplete;

  factory BusinessAccount.fromJson(Map<String, dynamic> json) =>
      BusinessAccount(
        id: _string(json['id']),
        ownerId: _string(json['ownerId']),
        businessName: _string(json['businessName']),
        description: _nullableString(json['description']),
        contactName: _nullableString(json['contactName']),
        phone: _nullableString(json['phone']),
        email: _nullableString(json['email']),
        address: _nullableString(json['address']),
        city: _nullableString(json['city']),
        state: _nullableString(json['state']),
        pincode: _nullableString(json['pincode']),
        gstNumber: _nullableString(json['gstNumber']),
        panNumber: _nullableString(json['panNumber']),
        onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      );
}

class BusinessStatus {
  const BusinessStatus({
    required this.hasBusinessAccount,
    this.businessAccountId,
    this.availableProfiles = const [],
    this.academyId,
    this.coachProfileId,
    this.arenaId,
    this.arenaIds = const [],
    this.managedArenaId,
    this.storeIds = const [],
    this.storeAvailable = false,
  });

  final bool hasBusinessAccount;
  final String? businessAccountId;
  final List<BizProfileType> availableProfiles;
  final String? academyId;
  final String? coachProfileId;
  final String? arenaId;
  final List<String> arenaIds;
  final String? managedArenaId;
  final List<String> storeIds;
  final bool storeAvailable;

  factory BusinessStatus.fromJson(Map<String, dynamic> json) {
    final rawProfiles =
        (json['availableProfiles'] as List?)?.cast<String>() ?? const [];
    return BusinessStatus(
      hasBusinessAccount: json['hasBusinessAccount'] as bool? ?? false,
      businessAccountId: _nullableString(json['businessAccountId']),
      availableProfiles: rawProfiles
          .map(bizProfileTypeFromString)
          .whereType<BizProfileType>()
          .toList(),
      academyId: _nullableString(json['academyId']),
      coachProfileId: _nullableString(json['coachProfileId']),
      arenaId: _nullableString(json['arenaId']),
      arenaIds: (json['arenaIds'] as List?)
              ?.map((item) => '$item')
              .where((item) => item.isNotEmpty)
              .toList() ??
          const [],
      managedArenaId: _nullableString(json['managedArenaId']),
      storeIds: (json['storeIds'] as List?)?.cast<String>() ?? const [],
      storeAvailable: json['storeAvailable'] as bool? ?? false,
    );
  }
}

class BizMeResponse {
  const BizMeResponse({
    required this.user,
    required this.businessStatus,
    this.businessAccount,
  });

  final BizUser user;
  final BusinessStatus businessStatus;
  final BusinessAccount? businessAccount;

  factory BizMeResponse.fromJson(Map<String, dynamic> json) => BizMeResponse(
        user: BizUser.fromJson(json['user'] as Map<String, dynamic>),
        businessStatus: BusinessStatus.fromJson(
            json['businessStatus'] as Map<String, dynamic>),
        businessAccount: json['businessAccount'] is Map<String, dynamic>
            ? BusinessAccount.fromJson(
                json['businessAccount'] as Map<String, dynamic>)
            : null,
      );
}

class BizLoginResponse {
  const BizLoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.isNewUser,
    required this.user,
    required this.businessStatus,
    this.businessAccount,
  });

  final String accessToken;
  final String refreshToken;
  final bool isNewUser;
  final BizUser user;
  final BusinessStatus businessStatus;
  final BusinessAccount? businessAccount;

  factory BizLoginResponse.fromJson(Map<String, dynamic> json) =>
      BizLoginResponse(
        accessToken: _string(json['accessToken']),
        refreshToken: _string(json['refreshToken']),
        isNewUser: json['isNewUser'] as bool? ?? false,
        user: BizUser.fromJson(json['user'] as Map<String, dynamic>),
        businessStatus: BusinessStatus.fromJson(
            json['businessStatus'] as Map<String, dynamic>),
        businessAccount: json['businessAccount'] is Map<String, dynamic>
            ? BusinessAccount.fromJson(
                json['businessAccount'] as Map<String, dynamic>)
            : null,
      );
}

String _string(Object? value) => value is String ? value : '';

String? _nullableString(Object? value) => value is String ? value : null;

class PhoneCheckResult {
  const PhoneCheckResult({
    required this.exists,
    required this.normalizedPhone,
  });

  final bool exists;
  final String normalizedPhone;
}

class BusinessDetailsInput {
  const BusinessDetailsInput({
    required this.businessName,
    this.contactName,
    this.phone,
    this.email,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.gstNumber,
    this.panNumber,
  });

  final String businessName;
  final String? contactName;
  final String? phone;
  final String? email;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? gstNumber;
  final String? panNumber;

  Map<String, dynamic> toJson() => {
        'businessName': businessName,
        if (_hasValue(contactName)) 'contactName': contactName,
        if (_hasValue(phone)) 'phone': phone,
        if (_hasValue(email)) 'email': email,
        if (_hasValue(address)) 'address': address,
        if (_hasValue(city)) 'city': city,
        if (_hasValue(state)) 'state': state,
        if (_hasValue(pincode)) 'pincode': pincode,
        if (_hasValue(gstNumber)) 'gstNumber': gstNumber,
        if (_hasValue(panNumber)) 'panNumber': panNumber,
      };
}

class AcademyProfileInput {
  const AcademyProfileInput({
    required this.name,
    required this.city,
    required this.state,
    this.address,
    this.phone,
    this.email,
    this.tagline,
  });

  final String name;
  final String city;
  final String state;
  final String? address;
  final String? phone;
  final String? email;
  final String? tagline;

  Map<String, dynamic> toJson() => {
        'name': name,
        'city': city,
        'state': state,
        if (_hasValue(address)) 'address': address,
        if (_hasValue(phone)) 'phone': phone,
        if (_hasValue(email)) 'email': email,
        if (_hasValue(tagline)) 'tagline': tagline,
      };
}

class CoachProfileInput {
  const CoachProfileInput({
    this.name,
    this.city,
    this.state,
    this.bio,
    this.specialization,
    this.specializations = const [],
    this.certifications = const [],
    this.experienceYears = 0,
    this.phone,
    this.hourlyRate,
    this.gigEnabled = false,
    this.oneOnOneEnabled = false,
  });

  final String? name;
  final String? city;
  final String? state;
  final String? bio;
  final String? specialization;
  final List<String> specializations;
  final List<String> certifications;
  final int experienceYears;
  final String? phone;
  final int? hourlyRate;
  final bool gigEnabled;
  final bool oneOnOneEnabled;

  Map<String, dynamic> toJson() => {
        if (_hasValue(name)) 'name': name,
        if (_hasValue(city)) 'city': city,
        if (_hasValue(state)) 'state': state,
        if (_hasValue(bio)) 'bio': bio,
        if (_hasValue(specialization)) 'specialization': specialization,
        'specializations': specializations,
        'certifications': certifications,
        'experienceYears': experienceYears,
        if (_hasValue(phone)) 'phone': phone,
        if (hourlyRate != null) 'hourlyRate': hourlyRate,
        'gigEnabled': gigEnabled,
        'oneOnOneEnabled': oneOnOneEnabled,
      };
}

class ArenaProfileInput {
  const ArenaProfileInput({
    required this.name,
    required this.address,
    this.city = 'Bhopal',
    this.state = 'Madhya Pradesh',
    this.pincode = '462041',
    this.description,
    this.phone,
    this.sports = const ['CRICKET'],
    this.photoUrls = const [],
    this.hasParking = false,
    this.hasLights = false,
    this.hasWashrooms = false,
    this.hasCanteen = false,
    this.hasCCTV = false,
    this.hasScorer = false,
    this.openTime = '06:00',
    this.closeTime = '22:00',
    this.latitude,
    this.longitude,
  });

  final String name;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String? description;
  final String? phone;
  final List<String> sports;
  final List<String> photoUrls;
  final bool hasParking;
  final bool hasLights;
  final bool hasWashrooms;
  final bool hasCanteen;
  final bool hasCCTV;
  final bool hasScorer;
  final String openTime;
  final String closeTime;
  final double? latitude;
  final double? longitude;

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'city': city,
        'state': state,
        'pincode': pincode,
        'sports': sports,
        'photoUrls': photoUrls,
        'hasParking': hasParking,
        'hasLights': hasLights,
        'hasWashrooms': hasWashrooms,
        'hasCanteen': hasCanteen,
        'hasCCTV': hasCCTV,
        'hasScorer': hasScorer,
        'openTime': openTime,
        'closeTime': closeTime,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (_hasValue(description)) 'description': description,
        if (_hasValue(phone)) 'phone': phone,
      };
}

bool _hasValue(String? v) => v != null && v.trim().isNotEmpty;
