/// One review row inside the dashboard's "Recent reviews" list.
class HostArenaReviewSample {
  const HostArenaReviewSample({
    required this.id,
    required this.stars,
    required this.tags,
    required this.createdAt,
    required this.teamName,
    this.comment,
    this.teamLogoUrl,
  });

  final String id;
  final int stars;
  final List<String> tags;
  final DateTime createdAt;
  final String teamName;
  final String? comment;
  final String? teamLogoUrl;

  factory HostArenaReviewSample.fromJson(Map<String, dynamic> j) =>
      HostArenaReviewSample(
        id: (j['id'] as String?) ?? '',
        stars: (j['stars'] as num?)?.toInt() ?? 0,
        tags: ((j['tags'] as List?) ?? const [])
            .whereType<String>()
            .toList(),
        comment: j['comment'] as String?,
        createdAt: DateTime.tryParse((j['createdAt'] as String?) ?? '') ??
            DateTime.now(),
        teamName: (j['teamName'] as String?) ?? 'A team',
        teamLogoUrl: j['teamLogoUrl'] as String?,
      );
}

/// One tag in the top-tags rollup. `positive=true` for surface_good /
/// parking_easy / etc.; false for the negative cluster.
class HostArenaTagFreq {
  const HostArenaTagFreq({
    required this.tag,
    required this.count,
    required this.positive,
  });

  final String tag;
  final int count;
  final bool positive;

  factory HostArenaTagFreq.fromJson(Map<String, dynamic> j) => HostArenaTagFreq(
        tag: (j['tag'] as String?) ?? '',
        count: (j['count'] as num?)?.toInt() ?? 0,
        positive: (j['positive'] as bool?) ?? false,
      );
}

/// Eligibility for "any-ground" matchmaking allocation.
///
/// • [eligibilityNew]        — count < 5, gathering reviews. Neutral weight.
/// • [eligibilityActive]     — being weighted normally.
/// • [eligibilitySoftBanned] — count >= 5 AND avg < 2.5. Excluded from the
///                             no-pref pool until rating recovers.
enum HostArenaEligibility { eligibilityNew, eligibilityActive, eligibilitySoftBanned }

HostArenaEligibility _eligibilityFromString(String? s) {
  switch (s) {
    case 'NEW':
      return HostArenaEligibility.eligibilityNew;
    case 'SOFT_BANNED':
      return HostArenaEligibility.eligibilitySoftBanned;
    default:
      return HostArenaEligibility.eligibilityActive;
  }
}

class HostArenaReviewAnalytics {
  const HostArenaReviewAnalytics({
    required this.arenaId,
    required this.arenaName,
    required this.matchRatingAvg,
    required this.matchRatingCount,
    required this.eligibility,
    required this.starsBreakdown,
    required this.topPositive,
    required this.topNegative,
    required this.recentReviews,
  });

  final String arenaId;
  final String arenaName;
  final double matchRatingAvg;
  final int matchRatingCount;
  final HostArenaEligibility eligibility;

  /// Map of stars (1–5) → count.
  final Map<int, int> starsBreakdown;
  final List<HostArenaTagFreq> topPositive;
  final List<HostArenaTagFreq> topNegative;
  final List<HostArenaReviewSample> recentReviews;

  factory HostArenaReviewAnalytics.fromJson(Map<String, dynamic> j) {
    final raw = (j['starsBreakdown'] as Map?) ?? const {};
    final breakdown = <int, int>{};
    raw.forEach((k, v) {
      final key = int.tryParse('$k');
      final val = (v as num?)?.toInt();
      if (key != null && val != null) breakdown[key] = val;
    });
    return HostArenaReviewAnalytics(
      arenaId: (j['arenaId'] as String?) ?? '',
      arenaName: (j['arenaName'] as String?) ?? '',
      matchRatingAvg: ((j['matchRatingAvg'] as num?) ?? 3.0).toDouble(),
      matchRatingCount: (j['matchRatingCount'] as num?)?.toInt() ?? 0,
      eligibility: _eligibilityFromString(j['eligibilityStatus'] as String?),
      starsBreakdown: breakdown,
      topPositive: ((j['topPositive'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(HostArenaTagFreq.fromJson)
          .toList(),
      topNegative: ((j['topNegative'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(HostArenaTagFreq.fromJson)
          .toList(),
      recentReviews: ((j['recentReviews'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(HostArenaReviewSample.fromJson)
          .toList(),
    );
  }
}
