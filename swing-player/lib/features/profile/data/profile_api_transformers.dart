import '../domain/profile_field_mappings.dart';
import '../domain/profile_models.dart';

class ProfileUpdatePayloadTransformer {
  const ProfileUpdatePayloadTransformer._();

  static Map<String, dynamic> toApi(PlayerProfileUpdateRequest request) {
    final trimmedAvatarUrl = request.avatarUrl?.trim();
    final trimmedCoverUrl = request.coverUrl?.trim();

    final payload = <String, dynamic>{
      if (request.name != null) 'name': request.name!.trim(),
      if (request.username != null) 'username': request.username!.trim(),
      if (request.dateOfBirth != null) 'dateOfBirth': request.dateOfBirth,
      if (request.gender != null) 'gender': request.gender,
      if (request.city != null) 'city': request.city!.trim(),
      if (request.state != null) 'state': request.state!.trim(),
      if (trimmedAvatarUrl != null) 'avatarUrl': trimmedAvatarUrl,
      if (trimmedAvatarUrl != null) 'avatar_url': trimmedAvatarUrl,
      if (trimmedCoverUrl != null) 'coverUrl': trimmedCoverUrl,
      if (trimmedCoverUrl != null) 'cover_url': trimmedCoverUrl,
      if (request.playerRole != null)
        'playerRole':
            ProfileFieldMappings.normalizeApiValue(ProfileFieldKey.role, request.playerRole) ??
                request.playerRole,
      if (request.battingStyle != null)
        'battingStyle': ProfileFieldMappings.normalizeApiValue(
              ProfileFieldKey.battingStyle,
              request.battingStyle,
            ) ??
            request.battingStyle,
      if (request.bowlingStyle != null)
        'bowlingStyle': ProfileFieldMappings.normalizeApiValue(
              ProfileFieldKey.bowlingStyle,
              request.bowlingStyle,
            ) ??
            request.bowlingStyle,
      if (request.level != null)
        'level':
            ProfileFieldMappings.normalizeApiValue(ProfileFieldKey.level, request.level) ??
                request.level,
      if (request.goals != null) 'goals': request.goals!.trim(),
      if (request.bio != null) 'bio': request.bio!.trim(),
      if (request.availableDays != null) 'availableDays': request.availableDays,
      if (request.preferredTimes != null)
        'preferredTimes': request.preferredTimes,
      if (request.locationRadius != null) 'locationRadius': request.locationRadius,
      if (request.isPublic != null) 'isPublic': request.isPublic,
      if (request.showStats != null) 'showStats': request.showStats,
      if (request.showLocation != null) 'showLocation': request.showLocation,
      if (request.scoutingOptIn != null) 'scoutingOptIn': request.scoutingOptIn,
    };

    if (request.includeJerseyNumber) {
      payload['jerseyNumber'] = request.jerseyNumber;
      payload['jerseyNo'] = request.jerseyNumber;
    }

    return payload;
  }
}

class ProfileIdentityResponseTransformer {
  const ProfileIdentityResponseTransformer._();

  static Map<String, dynamic> normalize(Map<String, dynamic> identity) {
    final normalizedRole =
        ProfileFieldMappings.normalizeApiValue(ProfileFieldKey.role, '${identity['playerRole'] ?? ''}');
    final normalizedBatting = ProfileFieldMappings.normalizeApiValue(
      ProfileFieldKey.battingStyle,
      '${identity['battingStyle'] ?? ''}',
    );
    final normalizedBowling = ProfileFieldMappings.normalizeApiValue(
      ProfileFieldKey.bowlingStyle,
      '${identity['bowlingStyle'] ?? ''}',
    );
    final normalizedLevel =
        ProfileFieldMappings.normalizeApiValue(ProfileFieldKey.level, '${identity['level'] ?? ''}');
    final normalizedJersey = _parseJersey(identity['jerseyNumber']) ??
        _parseJersey(identity['jerseyNo']);

    return <String, dynamic>{
      ...identity,
      if (normalizedRole != null) 'playerRole': normalizedRole,
      if (normalizedBatting != null) 'battingStyle': normalizedBatting,
      if (normalizedBowling != null) 'bowlingStyle': normalizedBowling,
      if (normalizedLevel != null) 'level': normalizedLevel,
      'jerseyNumber': normalizedJersey,
      'jerseyNo': normalizedJersey,
    };
  }

  static int? _parseJersey(dynamic value) {
    if (value is int) return value.clamp(0, 999);
    if (value is num) return value.toInt().clamp(0, 999);
    if (value is String) {
      final parsed = int.tryParse(value.trim());
      if (parsed == null) return null;
      return parsed.clamp(0, 999);
    }
    return null;
  }
}
