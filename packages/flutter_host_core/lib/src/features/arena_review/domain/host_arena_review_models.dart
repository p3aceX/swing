/// Captain's draft review of an arena after a match. The captain submits one
/// per (matchId, teamId); both teams in a match can review independently.
class HostArenaReviewDraft {
  const HostArenaReviewDraft({
    required this.stars,
    this.tags = const <String>[],
    this.comment,
  });

  /// 1–5. Reviews with stars outside this range are rejected by the backend.
  final int stars;

  /// Short slug-style tags that summarise the visit. Capped at 12 server-side.
  /// Suggested set: surface_good, parking_easy, lights_bright, washroom_clean,
  /// well_run, good_pricing, surface_bumpy, parking_hard, lights_dim,
  /// washroom_dirty, poor_facilities, overpriced.
  final List<String> tags;

  /// Free text. Max 500 chars server-side; sheet enforces the same.
  final String? comment;

  HostArenaReviewDraft copyWith({
    int? stars,
    List<String>? tags,
    String? comment,
    bool clearComment = false,
  }) =>
      HostArenaReviewDraft(
        stars: stars ?? this.stars,
        tags: tags ?? this.tags,
        comment: clearComment ? null : (comment ?? this.comment),
      );
}

/// Response shape from POST /matchmaking/matches/:matchId/review.
class HostArenaReviewResult {
  const HostArenaReviewResult({
    required this.reviewId,
    required this.arenaId,
    required this.matchRatingAvg,
    required this.matchRatingCount,
  });

  final String reviewId;
  final String arenaId;
  final double matchRatingAvg;
  final int matchRatingCount;

  factory HostArenaReviewResult.fromJson(Map<String, dynamic> j) =>
      HostArenaReviewResult(
        reviewId: (j['reviewId'] as String?) ?? '',
        arenaId: (j['arenaId'] as String?) ?? '',
        matchRatingAvg: ((j['matchRatingAvg'] as num?) ?? 3.0).toDouble(),
        matchRatingCount: (j['matchRatingCount'] as num?)?.toInt() ?? 0,
      );
}
