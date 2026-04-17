class ProfileFieldOption {
  const ProfileFieldOption({
    required this.apiValue,
    required this.label,
    this.aliases = const <String>[],
    this.legacyApiValue,
  });

  final String apiValue;
  final String label;
  final List<String> aliases;
  final String? legacyApiValue;
}

enum ProfileFieldKey {
  role,
  battingStyle,
  bowlingStyle,
  level,
}

class ProfileFieldMappings {
  ProfileFieldMappings._();

  static const List<ProfileFieldOption> roleOptions = [
    ProfileFieldOption(apiValue: 'BATSMAN', label: 'Batter', aliases: ['BATTER']),
    ProfileFieldOption(apiValue: 'BOWLER', label: 'Bowler'),
    ProfileFieldOption(
      apiValue: 'ALL_ROUNDER',
      label: 'All Rounder',
      aliases: ['ALLROUNDER', 'All_rounder'],
    ),
    ProfileFieldOption(
      apiValue: 'WICKET_KEEPER',
      label: 'Wicket Keeper',
      aliases: ['WICKETKEEPER', 'KEEPER'],
    ),
    ProfileFieldOption(
      apiValue: 'WICKET_KEEPER_BATSMAN',
      label: 'Wicket Keeper Batter',
      aliases: ['WICKETKEEPERBATSMAN', 'WICKET_KEEPER_BATTER'],
    ),
  ];

  static const List<ProfileFieldOption> battingStyleOptions = [
    ProfileFieldOption(
      apiValue: 'RIGHT_HAND',
      label: 'Right Hand',
      aliases: ['RIGHTHAND', 'Right_hand'],
    ),
    ProfileFieldOption(
      apiValue: 'LEFT_HAND',
      label: 'Left Hand',
      aliases: ['LEFTHAND', 'Left_hand'],
    ),
  ];

  static const List<ProfileFieldOption> bowlingStyleOptions = [
    ProfileFieldOption(
      apiValue: 'RIGHT_ARM_FAST',
      label: 'Right Arm Fast',
      aliases: ['RIGHTARMFAST', 'Right_arm_fast'],
    ),
    ProfileFieldOption(
      apiValue: 'RIGHT_ARM_MEDIUM',
      label: 'Right Arm Medium',
      aliases: ['RIGHTARMMEDIUM', 'Right_arm_medium'],
    ),
    ProfileFieldOption(
      apiValue: 'RIGHT_ARM_OFFBREAK',
      label: 'Offbreak',
      aliases: [
        'RIGHT_ARM_OFF_BREAK',
        'RIGHTARMOFFBREAK',
        'Right_arm_off break',
      ],
    ),
    ProfileFieldOption(
      apiValue: 'RIGHT_ARM_LEGBREAK',
      label: 'Legbreak',
      aliases: [
        'RIGHT_ARM_LEG_BREAK',
        'RIGHTARMLEGBREAK',
        'Right_arm_leg break',
      ],
    ),
    ProfileFieldOption(
      apiValue: 'LEFT_ARM_FAST',
      label: 'Left Arm Fast',
      aliases: ['LEFTARMFAST', 'Left_arm_fast'],
    ),
    ProfileFieldOption(
      apiValue: 'LEFT_ARM_MEDIUM',
      label: 'Left Arm Medium',
      aliases: ['LEFTARMMEDIUM', 'Left_arm_medium'],
    ),
    ProfileFieldOption(
      apiValue: 'LEFT_ARM_ORTHODOX',
      label: 'Left Arm Orthodox',
      aliases: ['LEFTARMORTHODOX', 'Left_arm_orthodox'],
    ),
    ProfileFieldOption(
      apiValue: 'LEFT_ARM_CHINAMAN',
      label: 'Chinaman',
      aliases: ['LEFTARMCHINAMAN', 'Left_arm_chinaman'],
    ),
    ProfileFieldOption(
      apiValue: 'NOT_A_BOWLER',
      label: 'Not a Bowler',
      aliases: ['NOTABOWLER'],
    ),
  ];

  static const List<ProfileFieldOption> levelOptions = [
    ProfileFieldOption(apiValue: 'CLUB', label: 'Club', aliases: ['BEGINNER']),
    ProfileFieldOption(apiValue: 'CORPORATE', label: 'Corporate'),
    ProfileFieldOption(
      apiValue: 'DIVISION',
      label: 'Division',
      aliases: ['DISTRICT'],
      legacyApiValue: 'DISTRICT',
    ),
    ProfileFieldOption(apiValue: 'STATE', label: 'State'),
    ProfileFieldOption(apiValue: 'IPL', label: 'IPL'),
    ProfileFieldOption(
      apiValue: 'INTERNATIONAL',
      label: 'International',
      aliases: ['NATIONAL'],
      legacyApiValue: 'NATIONAL',
    ),
  ];

  static List<ProfileFieldOption> optionsFor(ProfileFieldKey key) {
    return switch (key) {
      ProfileFieldKey.role => roleOptions,
      ProfileFieldKey.battingStyle => battingStyleOptions,
      ProfileFieldKey.bowlingStyle => bowlingStyleOptions,
      ProfileFieldKey.level => levelOptions,
    };
  }

  static String? normalizeApiValue(ProfileFieldKey key, String? raw) {
    final input = _normalizedToken(raw);
    if (input == null) return null;

    for (final option in optionsFor(key)) {
      final candidates = <String>[option.apiValue, ...option.aliases];
      for (final candidate in candidates) {
        final token = _normalizedToken(candidate);
        if (token != null && token == input) {
          return option.apiValue;
        }
      }
    }
    return null;
  }

  static String displayLabel(ProfileFieldKey key, String? raw) {
    final normalizedApi = normalizeApiValue(key, raw);
    if (normalizedApi == null) return _humanize(raw);

    final option = optionsFor(key)
        .where((entry) => entry.apiValue == normalizedApi)
        .firstOrNull;
    return option?.label ?? _humanize(raw);
  }

  static Map<String, String> dropdownItems(ProfileFieldKey key) {
    final map = <String, String>{};
    for (final option in optionsFor(key)) {
      map[option.apiValue] = option.label;
    }
    return map;
  }

  static String? legacyLevelFallback(String? apiValue) {
    if (apiValue == null) return null;
    final option = levelOptions.where((entry) => entry.apiValue == apiValue).firstOrNull;
    return option?.legacyApiValue;
  }

  static String _humanize(String? raw) {
    final trimmed = raw?.trim() ?? '';
    if (trimmed.isEmpty) return '-';
    if (trimmed.toLowerCase() == 'null') return '-';

    final spaced = trimmed
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (spaced.isEmpty) return '-';

    return spaced
        .split(' ')
        .map((part) {
          if (part.isEmpty) return part;
          if (part.toUpperCase() == part && part.length <= 4) {
            return part;
          }
          return '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}';
        })
        .join(' ');
  }

  static String? _normalizedToken(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}

extension _FirstOrNullExtension<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
