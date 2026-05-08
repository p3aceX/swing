import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/host_colors.dart';
import '../data/host_arena_review_repository.dart';
import '../domain/host_arena_review_analytics.dart';
import 'host_arena_rating_badge.dart';

/// Dashboard surface for arena owners — match-context rating, eligibility
/// status (NEW / ACTIVE / SOFT_BANNED), top tags from captain reviews, and
/// the most recent comments. Hosted in the biz app via a flat scroll view.
///
/// Backend: GET /arenas/:id/match-review-analytics (owner-only).
class HostArenaReviewDashboard extends ConsumerStatefulWidget {
  const HostArenaReviewDashboard({
    super.key,
    required this.arenaId,
  });

  final String arenaId;

  @override
  ConsumerState<HostArenaReviewDashboard> createState() =>
      _HostArenaReviewDashboardState();
}

// Maps the raw slug to the display label captains saw when submitting.
const Map<String, String> _tagLabels = {
  'surface_good': 'Good surface',
  'parking_easy': 'Easy parking',
  'lights_bright': 'Bright lights',
  'washroom_clean': 'Clean washroom',
  'well_run': 'Well run',
  'good_pricing': 'Good pricing',
  'surface_bumpy': 'Bumpy surface',
  'parking_hard': 'Hard to park',
  'lights_dim': 'Dim lights',
  'washroom_dirty': 'Dirty washroom',
  'poor_facilities': 'Poor facilities',
  'overpriced': 'Overpriced',
};

class _HostArenaReviewDashboardState
    extends ConsumerState<HostArenaReviewDashboard> {
  late Future<HostArenaReviewAnalytics> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<HostArenaReviewAnalytics> _load() {
    return ref.read(hostArenaReviewRepositoryProvider).loadAnalytics(widget.arenaId);
  }

  Future<void> _refresh() async {
    final next = _load();
    setState(() => _future = next);
    await next;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Match reviews',
          style: TextStyle(
            color: context.fg,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        iconTheme: IconThemeData(color: context.fg),
      ),
      body: FutureBuilder<HostArenaReviewAnalytics>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || snap.data == null) {
            return _ErrorState(onRetry: _refresh);
          }
          final a = snap.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                _HeroCard(analytics: a),
                const SizedBox(height: 18),
                _EligibilityCard(analytics: a),
                const SizedBox(height: 22),
                if (a.topPositive.isNotEmpty || a.topNegative.isNotEmpty) ...[
                  Text(
                    'What captains highlight',
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _TagColumn(tags: a.topPositive, positive: true),
                  if (a.topNegative.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _TagColumn(tags: a.topNegative, positive: false),
                  ],
                  const SizedBox(height: 22),
                ],
                Text(
                  'Recent reviews',
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 10),
                if (a.recentReviews.isEmpty)
                  Text(
                    'No reviews yet. They\'ll show up here as captains rate the ground after matches.',
                    style: TextStyle(color: context.fgSub, fontSize: 13, height: 1.4),
                  )
                else
                  for (final r in a.recentReviews) _ReviewRow(review: r),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.analytics});
  final HostArenaReviewAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final hasData = analytics.matchRatingCount >= 3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          analytics.arenaName.isNotEmpty ? analytics.arenaName : 'Arena',
          style: TextStyle(
            color: context.fg,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Icon(Icons.star_rounded, color: context.gold, size: 36),
            const SizedBox(width: 4),
            Text(
              hasData ? analytics.matchRatingAvg.toStringAsFixed(1) : '—',
              style: TextStyle(
                color: context.fg,
                fontSize: 38,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.0,
                height: 1.0,
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                hasData
                    ? '${analytics.matchRatingCount} ${analytics.matchRatingCount == 1 ? "review" : "reviews"}'
                    : '${analytics.matchRatingCount} so far',
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Stars histogram — flat horizontal bars, one row per star.
        for (var s = 5; s >= 1; s--)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _StarBar(stars: s, count: analytics.starsBreakdown[s] ?? 0, total: analytics.matchRatingCount),
          ),
      ],
    );
  }
}

class _StarBar extends StatelessWidget {
  const _StarBar({required this.stars, required this.count, required this.total});
  final int stars;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : count / total;
    return Row(
      children: [
        SizedBox(
          width: 22,
          child: Text(
            '$stars',
            style: TextStyle(color: context.fgSub, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: context.fgSub.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: pct.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: context.gold,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 28,
          child: Text(
            '$count',
            textAlign: TextAlign.right,
            style: TextStyle(color: context.fgSub, fontSize: 11.5, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _EligibilityCard extends StatelessWidget {
  const _EligibilityCard({required this.analytics});
  final HostArenaReviewAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final ({Color tone, String title, String body}) view;
    switch (analytics.eligibility) {
      case HostArenaEligibility.eligibilitySoftBanned:
        view = (
          tone: context.danger,
          title: 'Match-up allocation paused',
          body:
              'Your average is ${analytics.matchRatingAvg.toStringAsFixed(1)}★ across ${analytics.matchRatingCount} reviews. Until it climbs above 2.5★, players who picked "any ground" won\'t be matched here. Players who name your arena directly are unaffected.',
        );
        break;
      case HostArenaEligibility.eligibilityNew:
        view = (
          tone: context.sky,
          title: 'Gathering reviews',
          body:
              'You\'re currently getting fair allocation. Your rating starts steering match-ups after 5 captain reviews. ${analytics.matchRatingCount} so far — keep delivering.',
        );
        break;
      case HostArenaEligibility.eligibilityActive:
        view = (
          tone: context.success,
          title: 'Active in match-ups',
          body:
              'Your ${analytics.matchRatingAvg.toStringAsFixed(1)}★ rating is steering "any-ground" allocation. Higher ratings = more match-ups.',
        );
        break;
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: view.tone.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: view.tone.withValues(alpha: 0.35), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            view.title,
            style: TextStyle(
              color: view.tone,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            view.body,
            style: TextStyle(
              color: context.fg,
              fontSize: 12.5,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagColumn extends StatelessWidget {
  const _TagColumn({required this.tags, required this.positive});
  final List<HostArenaTagFreq> tags;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final tone = positive ? context.success : context.danger;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final t in tags)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _tagLabels[t.tag] ?? t.tag,
                  style: TextStyle(color: tone, fontSize: 12, fontWeight: FontWeight.w800),
                ),
                const SizedBox(width: 6),
                Text(
                  '${t.count}',
                  style: TextStyle(color: tone.withValues(alpha: 0.7), fontSize: 11.5, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.review});
  final HostArenaReviewSample review;

  String _relTime() {
    final d = DateTime.now().difference(review.createdAt);
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 30) return '${d.inDays}d ago';
    return '${(d.inDays / 30).floor()}mo ago';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HostArenaRatingBadge(
                average: review.stars.toDouble(),
                count: 1,
                minVisibleCount: 1,
                showNewBadge: false,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  review.teamName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                _relTime(),
                style: TextStyle(color: context.fgSub, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (review.tags.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final t in review.tags)
                  Text(
                    _tagLabels[t] ?? t,
                    style: TextStyle(color: context.fgSub, fontSize: 11.5, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ],
          if (review.comment != null && review.comment!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              review.comment!,
              style: TextStyle(
                color: context.fg,
                fontSize: 12.5,
                fontStyle: FontStyle.italic,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Container(height: 1, color: context.fgSub.withValues(alpha: 0.12)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: context.fgSub, size: 32),
            const SizedBox(height: 8),
            Text(
              'Could not load reviews.',
              style: TextStyle(color: context.fgSub, fontSize: 13.5),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
