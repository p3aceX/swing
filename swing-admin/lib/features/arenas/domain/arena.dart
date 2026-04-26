class Arena {
  const Arena({
    required this.id,
    required this.name,
    required this.city,
    required this.state,
    required this.address,
    required this.photoUrl,
    required this.verified,
    required this.swingEnabled,
    required this.rating,
    required this.totalRatings,
    required this.unitCount,
    required this.openTime,
    required this.closeTime,
    this.description,
    this.photoUrls = const [],
    this.sports = const [],
    this.ownerId,
    this.ownerName,
    this.ownerPhone,
    this.ownerBusinessName,
    this.ownerGstNumber,
    this.ownerPanNumber,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String city;
  final String state;
  final String address;
  final String? photoUrl;
  final bool verified;
  final bool swingEnabled;
  final double rating;
  final int totalRatings;
  final int unitCount;
  final String openTime;
  final String closeTime;
  final String? description;
  final List<String> photoUrls;
  final List<String> sports;
  final String? ownerId;
  final String? ownerName;
  final String? ownerPhone;
  final String? ownerBusinessName;
  final String? ownerGstNumber;
  final String? ownerPanNumber;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Arena.fromJson(Map<String, dynamic> j) {
    final photos = j['photoUrls'];
    String? photo;
    if (photos is List && photos.isNotEmpty) {
      photo = photos.first?.toString();
    }
    final units = j['units'];
    final owner = j['owner'];
    String? ownerName;
    String? ownerPhone;
    String? ownerBusinessName;
    String? ownerGstNumber;
    String? ownerPanNumber;
    String? ownerId;
    if (owner is Map) {
      final ownerMap = Map<String, dynamic>.from(owner);
      ownerId = ownerMap['id']?.toString();
      ownerBusinessName = ownerMap['businessName']?.toString();
      ownerGstNumber = ownerMap['gstNumber']?.toString();
      ownerPanNumber = ownerMap['panNumber']?.toString();
      final ownerUser = ownerMap['user'];
      if (ownerUser is Map) {
        final userMap = Map<String, dynamic>.from(ownerUser);
        ownerName = userMap['name']?.toString();
        ownerPhone = userMap['phone']?.toString();
      }
    }
    return Arena(
      id: j['id']?.toString() ?? '',
      name: j['name']?.toString() ?? '—',
      city: j['city']?.toString() ?? '',
      state: j['state']?.toString() ?? '',
      address: j['address']?.toString() ?? '',
      photoUrl: photo,
      verified: j['isVerified'] == true,
      swingEnabled: j['isSwingArena'] == true,
      rating: (j['rating'] is num) ? (j['rating'] as num).toDouble() : 0.0,
      totalRatings: (j['totalRatings'] is int) ? j['totalRatings'] as int : 0,
      unitCount: units is List ? units.length : 0,
      openTime: j['openTime']?.toString() ?? '',
      closeTime: j['closeTime']?.toString() ?? '',
      description: j['description']?.toString(),
      photoUrls: photos is List
          ? photos.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList()
          : const [],
      sports: j['sports'] is List
          ? (j['sports'] as List).map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList()
          : const [],
      ownerId: ownerId,
      ownerName: ownerName,
      ownerPhone: ownerPhone,
      ownerBusinessName: ownerBusinessName,
      ownerGstNumber: ownerGstNumber,
      ownerPanNumber: ownerPanNumber,
      isActive: j['isActive'] != false,
      createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(j['updatedAt']?.toString() ?? ''),
    );
  }
}
