enum BizProfileType { academy, coach, arena, arenaManager, store }

BizProfileType? bizProfileTypeFromString(String raw) {
  switch (raw) {
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
  }
  return null;
}

String bizProfileTypeLabel(BizProfileType type) {
  switch (type) {
    case BizProfileType.academy:
      return 'Academy Owner';
    case BizProfileType.coach:
      return 'Coach';
    case BizProfileType.arena:
      return 'Arena Owner';
    case BizProfileType.arenaManager:
      return 'Arena Manager';
    case BizProfileType.store:
      return 'Store Owner';
  }
}

class BizUser {
  const BizUser({
    required this.id,
    required this.phone,
    this.name,
    this.email,
    this.activeRole,
    this.roles = const [],
  });

  final String id;
  final String phone;
  final String? name;
  final String? email;
  final String? activeRole;
  final List<String> roles;

  factory BizUser.fromJson(Map<String, dynamic> json) => BizUser(
        id: json['id'] as String,
        phone: json['phone'] as String? ?? '',
        name: json['name'] as String?,
        email: json['email'] as String?,
        activeRole: json['activeRole'] as String?,
        roles: (json['roles'] as List?)?.cast<String>() ?? const [],
      );
}

class BusinessAccount {
  const BusinessAccount({
    required this.id,
    required this.businessName,
    this.contactName,
    this.phone,
    this.email,
    this.city,
    this.state,
    this.address,
    this.pincode,
    this.gstNumber,
    this.panNumber,
    this.onboardingComplete = false,
  });

  final String id;
  final String businessName;
  final String? contactName;
  final String? phone;
  final String? email;
  final String? city;
  final String? state;
  final String? address;
  final String? pincode;
  final String? gstNumber;
  final String? panNumber;
  final bool onboardingComplete;

  factory BusinessAccount.fromJson(Map<String, dynamic> json) =>
      BusinessAccount(
        id: json['id'] as String,
        businessName: json['businessName'] as String? ?? '',
        contactName: json['contactName'] as String?,
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        city: json['city'] as String?,
        state: json['state'] as String?,
        address: json['address'] as String?,
        pincode: json['pincode'] as String?,
        gstNumber: json['gstNumber'] as String?,
        panNumber: json['panNumber'] as String?,
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
  final String? managedArenaId;
  final List<String> storeIds;
  final bool storeAvailable;

  factory BusinessStatus.fromJson(Map<String, dynamic> json) {
    final rawProfiles =
        (json['availableProfiles'] as List?)?.cast<String>() ?? const [];
    return BusinessStatus(
      hasBusinessAccount: json['hasBusinessAccount'] as bool? ?? false,
      businessAccountId: json['businessAccountId'] as String?,
      availableProfiles: rawProfiles
          .map(bizProfileTypeFromString)
          .whereType<BizProfileType>()
          .toList(),
      academyId: json['academyId'] as String?,
      coachProfileId: json['coachProfileId'] as String?,
      arenaId: json['arenaId'] as String?,
      managedArenaId: json['managedArenaId'] as String?,
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
        businessStatus:
            BusinessStatus.fromJson(json['businessStatus'] as Map<String, dynamic>),
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
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
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

class BusinessDetailsInput {
  const BusinessDetailsInput({
    required this.businessName,
    this.contactName,
    this.phone,
    this.email,
    this.city,
    this.state,
    this.address,
    this.pincode,
    this.gstNumber,
    this.panNumber,
  });

  final String businessName;
  final String? contactName;
  final String? phone;
  final String? email;
  final String? city;
  final String? state;
  final String? address;
  final String? pincode;
  final String? gstNumber;
  final String? panNumber;

  Map<String, dynamic> toJson() => {
        'businessName': businessName,
        if (_hasValue(contactName)) 'contactName': contactName,
        if (_hasValue(phone)) 'phone': phone,
        if (_hasValue(email)) 'email': email,
        if (_hasValue(city)) 'city': city,
        if (_hasValue(state)) 'state': state,
        if (_hasValue(address)) 'address': address,
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
    this.description,
    this.address,
    this.pincode,
    this.tagline,
    this.phone,
    this.email,
  });

  final String name;
  final String city;
  final String state;
  final String? description;
  final String? address;
  final String? pincode;
  final String? tagline;
  final String? phone;
  final String? email;

  Map<String, dynamic> toJson() => {
        'name': name,
        'city': city,
        'state': state,
        if (_hasValue(description)) 'description': description,
        if (_hasValue(address)) 'address': address,
        if (_hasValue(pincode)) 'pincode': pincode,
        if (_hasValue(tagline)) 'tagline': tagline,
        if (_hasValue(phone)) 'phone': phone,
        if (_hasValue(email)) 'email': email,
      };
}

class CoachProfileInput {
  const CoachProfileInput({
    this.bio,
    this.specializations = const [],
    this.certifications = const [],
    this.experienceYears = 0,
    this.city,
    this.state,
    this.hourlyRate,
    this.gigEnabled = false,
    this.oneOnOneEnabled = false,
  });

  final String? bio;
  final List<String> specializations;
  final List<String> certifications;
  final int experienceYears;
  final String? city;
  final String? state;
  final int? hourlyRate;
  final bool gigEnabled;
  final bool oneOnOneEnabled;

  Map<String, dynamic> toJson() => {
        'specializations': specializations,
        'certifications': certifications,
        'experienceYears': experienceYears,
        'gigEnabled': gigEnabled,
        'oneOnOneEnabled': oneOnOneEnabled,
        if (_hasValue(bio)) 'bio': bio,
        if (_hasValue(city)) 'city': city,
        if (_hasValue(state)) 'state': state,
        if (hourlyRate != null) 'hourlyRate': hourlyRate,
      };
}

class ArenaProfileInput {
  const ArenaProfileInput({
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    this.description,
    this.phone,
    this.sports = const ['CRICKET'],
    this.photoUrls = const [],
    this.hasParking = false,
    this.hasLights = false,
    this.hasWashrooms = false,
    this.hasCanteen = false,
    this.hasCCTV = false,
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
        if (_hasValue(description)) 'description': description,
        if (_hasValue(phone)) 'phone': phone,
      };
}

bool _hasValue(String? v) => v != null && v.trim().isNotEmpty;
