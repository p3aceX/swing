/// Shared model for leaderboard entries and user recommendations.
/// Both `/player/leaderboard` and `/player/recommendations` return this shape.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.playerId,
    required this.name,
    this.avatarUrl,
    required this.impactPoints,
    required this.rank,
    this.profileUrl,
  });

  final String playerId;
  final String name;
  final String? avatarUrl;
  final int impactPoints;
  final String rank; // e.g. "ASCENDANT"
  final String? profileUrl;

  /// Humanised rank label with subdivision (e.g. "ROOKIE_I" → "Rookie I",
  /// "STRIKER_III" → "Striker III", "APEX" → "Apex")
  String get rankLabel {
    if (rank.isEmpty) return '';
    final parts = rank.trim().replaceAll(RegExp(r'[_\-]+'), ' ').split(' ');
    final base = parts[0][0].toUpperCase() + parts[0].substring(1).toLowerCase();
    if (parts.length > 1) {
      final div = parts[1].toUpperCase();
      if (div == 'I' || div == 'II' || div == 'III') return '$base $div';
    }
    return base;
  }

  /// Just the base rank name (e.g. "ROOKIE_I" → "rookie")
  String get rankBase => rank.trim().split(RegExp(r'[_\- ]'))[0].toLowerCase();
}
