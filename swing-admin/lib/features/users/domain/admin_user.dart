enum UserType {
  player('Player', 'PLAYER'),
  coach('Coach', 'COACH'),
  academyOwner('Academy Owner', 'ACADEMY_OWNER'),
  businessOwner('Business', 'BUSINESS_OWNER'),
  admin('Admin', 'SWING_ADMIN'),
  support('Support', 'SWING_SUPPORT');

  const UserType(this.label, this.apiRole);
  final String label;
  final String apiRole;

  static UserType? fromApi(String? role) {
    if (role == null) return null;
    final up = role.toUpperCase();
    for (final t in UserType.values) {
      if (t.apiRole == up) return t;
    }
    return null;
  }
}

class AdminUser {
  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.type,
    required this.roles,
    required this.activeRole,
    required this.city,
    required this.isBlocked,
    required this.isVerified,
    required this.isActive,
    required this.isBanned,
    required this.blockedReason,
    required this.language,
    required this.avatarUrl,
    required this.lastLoginAt,
    required this.joinedAt,
    required this.updatedAt,
    required this.playerProfile,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final UserType type;
  final List<String> roles;
  final String activeRole;
  final String city;
  final bool isBlocked;
  final bool isVerified;
  final bool isActive;
  final bool isBanned;
  final String blockedReason;
  final String language;
  final String avatarUrl;
  final DateTime? lastLoginAt;
  final DateTime joinedAt;
  final DateTime? updatedAt;
  final PlayerProfileDetail? playerProfile;

  factory AdminUser.fromJson(Map<String, dynamic> j) {
    UserType type = UserType.player;
    final mapped = UserType.fromApi(j['activeRole']?.toString());
    if (mapped != null) {
      type = mapped;
    } else if (j['roles'] is List) {
      for (final r in j['roles'] as List) {
        final m = UserType.fromApi(r?.toString());
        if (m != null) {
          type = m;
          break;
        }
      }
    } else {
      final raw = (j['role'] ?? j['userType'] ?? j['type'])?.toString();
      type = UserType.fromApi(raw) ?? UserType.player;
    }

    final name = (j['name'] ??
            j['displayName'] ??
            j['fullName'] ??
            [j['firstName'], j['lastName']]
                .where((e) => e != null && e.toString().isNotEmpty)
                .join(' '))
        ?.toString();

    final roles = ((j['roles'] as List?) ?? const [])
        .map((e) => e?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();

    final created = _tryParseDate(j['createdAt'] ?? j['joinedAt']) ?? DateTime.now();
    final updated = _tryParseDate(j['updatedAt']);
    final lastLogin = _tryParseDate(j['lastLoginAt']);

    final nestedPlayer = j['playerProfile'] ??
        j['player'] ??
        j['player_profile'] ??
        (j['profiles'] is Map ? (j['profiles'] as Map)['player'] : null);
    final playerProfile = nestedPlayer is Map
        ? PlayerProfileDetail.fromJson(Map<String, dynamic>.from(nestedPlayer))
        : null;

    final city = playerProfile?.city ?? j['city']?.toString() ?? '';

    return AdminUser(
      id: j['id']?.toString() ?? '',
      name: (name == null || name.isEmpty) ? '—' : name,
      email: j['email']?.toString() ?? '',
      phone: j['phone']?.toString() ?? j['phoneNumber']?.toString() ?? '',
      type: type,
      roles: roles,
      activeRole: j['activeRole']?.toString() ?? type.apiRole,
      city: city,
      isBlocked: j['isBlocked'] == true || j['blocked'] == true,
      isVerified: j['isVerified'] == true,
      isActive: j['isActive'] != false,
      isBanned: j['isBanned'] == true,
      blockedReason: j['blockedReason']?.toString() ?? '',
      language: j['language']?.toString() ?? '',
      avatarUrl: j['avatarUrl']?.toString() ?? '',
      lastLoginAt: lastLogin,
      joinedAt: created,
      updatedAt: updated,
      playerProfile: playerProfile,
    );
  }
}

DateTime? _tryParseDate(Object? raw) {
  if (raw is String) return DateTime.tryParse(raw);
  return null;
}

class PlayerProfileDetail {
  const PlayerProfileDetail({
    required this.username,
    required this.gender,
    required this.city,
    required this.state,
    required this.playerRole,
    required this.battingStyle,
    required this.bowlingStyle,
    required this.level,
    required this.bio,
    required this.swingIndex,
    required this.matchesPlayed,
    required this.matchesWon,
    required this.totalRuns,
    required this.highestScore,
    required this.totalWickets,
    required this.verificationLevel,
    required this.followersCount,
    required this.followingCount,
    required this.dateOfBirth,
  });

  final String username;
  final String gender;
  final String city;
  final String state;
  final String playerRole;
  final String battingStyle;
  final String bowlingStyle;
  final String level;
  final String bio;
  final double swingIndex;
  final int matchesPlayed;
  final int matchesWon;
  final int totalRuns;
  final int highestScore;
  final int totalWickets;
  final String verificationLevel;
  final int followersCount;
  final int followingCount;
  final DateTime? dateOfBirth;

  factory PlayerProfileDetail.fromJson(Map<String, dynamic> j) {
    return PlayerProfileDetail(
      username: j['username']?.toString() ?? '',
      gender: j['gender']?.toString() ?? '',
      city: j['city']?.toString() ?? '',
      state: j['state']?.toString() ?? '',
      playerRole: j['playerRole']?.toString() ?? '',
      battingStyle: j['battingStyle']?.toString() ?? '',
      bowlingStyle: j['bowlingStyle']?.toString() ?? '',
      level: j['level']?.toString() ?? '',
      bio: j['bio']?.toString() ?? '',
      swingIndex: (j['swingIndex'] is num) ? (j['swingIndex'] as num).toDouble() : 0,
      matchesPlayed: (j['matchesPlayed'] is int) ? j['matchesPlayed'] as int : 0,
      matchesWon: (j['matchesWon'] is int) ? j['matchesWon'] as int : 0,
      totalRuns: (j['totalRuns'] is int) ? j['totalRuns'] as int : 0,
      highestScore: (j['highestScore'] is int) ? j['highestScore'] as int : 0,
      totalWickets: (j['totalWickets'] is int) ? j['totalWickets'] as int : 0,
      verificationLevel: j['verificationLevel']?.toString() ?? '',
      followersCount: (j['followersCount'] is int) ? j['followersCount'] as int : 0,
      followingCount: (j['followingCount'] is int) ? j['followingCount'] as int : 0,
      dateOfBirth: _tryParseDate(j['dateOfBirth']),
    );
  }
}

enum UserTab {
  all('All', null),
  player('Player', 'PLAYER'),
  biz('Biz', 'BUSINESS_OWNER');

  const UserTab(this.label, this.apiRole);
  final String label;
  final String? apiRole;
}

class UsersPage {
  const UsersPage({
    required this.users,
    required this.total,
    required this.page,
    required this.limit,
  });
  final List<AdminUser> users;
  final int total;
  final int page;
  final int limit;

  int get totalPages =>
      limit <= 0 ? 1 : ((total + limit - 1) ~/ limit).clamp(1, 1 << 30);
  bool get hasPrev => page > 1;
  bool get hasNext => page < totalPages;
}
