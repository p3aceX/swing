import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/profile_models.dart';
import 'profile_section_card.dart';

class RecentPerformanceCarousel extends StatelessWidget {
  const RecentPerformanceCarousel({
    super.key,
    required this.performances,
  });

  final List<PlayerRecentPerformance> performances;

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'Recent Performance',
      subtitle: 'Latest matches, impact gained, and where the profile moved.',
      child: performances.isEmpty
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.panel,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: context.stroke),
              ),
              child: Text(
                'Recent matches will appear here once your latest scorecards sync in.',
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            )
          : SizedBox(
              height: 184,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: performances.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final performance = performances[index];
                  return _RecentPerformanceCard(performance: performance);
                },
              ),
            ),
    );
  }
}

class _RecentPerformanceCard extends StatelessWidget {
  const _RecentPerformanceCard({
    required this.performance,
  });

  final PlayerRecentPerformance performance;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 214,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.panel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.stroke),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxHeight <= 148 || constraints.maxWidth <= 182;
          final leadingDelta =
              performance.deltas.isEmpty ? null : performance.deltas.first;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        performance.opponent,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.fg,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (performance.mvpWon)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.gold.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'MVP',
                          style: TextStyle(
                            color: context.gold,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '+${performance.impactPoints} IP',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.accent,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _metaLine(leadingDelta),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      performance.opponent,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (performance.mvpWon)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: context.gold.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'MVP',
                        style: TextStyle(
                          color: context.gold,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _metaLine(leadingDelta),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '+${performance.impactPoints} IP',
                style: TextStyle(
                  color: context.accent,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                performance.summary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
              if (leadingDelta != null) ...[
                const SizedBox(height: 10),
                _PerformanceDeltaChip(
                  delta: leadingDelta,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  String _metaLine(PlayerPerformanceDelta? delta) {
    if (delta == null) return performance.outcomeLabel;
    return '${performance.outcomeLabel} • ${delta.label} +${delta.value}';
  }
}

class _PerformanceDeltaChip extends StatelessWidget {
  const _PerformanceDeltaChip({
    required this.delta,
  });

  final PlayerPerformanceDelta delta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: context.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            delta.label.length > 8 ? delta.label.substring(0, 8) : delta.label,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '+${delta.value}',
            style: TextStyle(
              color: context.accent,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
