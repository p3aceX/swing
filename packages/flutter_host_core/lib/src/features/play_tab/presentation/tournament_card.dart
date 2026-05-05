import 'package:flutter/material.dart';

import '../../../theme/host_colors.dart';
import '../domain/play_tab_models.dart';

class TournamentCard extends StatelessWidget {
  const TournamentCard({
    super.key,
    required this.tournament,
    this.onTap,
    this.isAlternate = false,
    this.compact = false,
  });

  final PlayTournament tournament;
  final VoidCallback? onTap;
  final bool isAlternate;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = tournament;
    final statusColor = _statusColor(t.status, context);
    final statusLabel = _statusLabel(t.status);
    final isLive = t.status.toUpperCase() == 'ONGOING' ||
        t.status.toUpperCase() == 'LIVE' ||
        t.status.toUpperCase() == 'IN_PROGRESS';

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: context.stroke.withValues(alpha: 0.65),
              width: 0.8,
            ),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Ink(
              decoration: BoxDecoration(
                color: isAlternate ? context.panel : context.surf,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(12, compact ? 11 : 12, 12, compact ? 11 : 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Logo(url: t.logoUrl, size: compact ? 38 : 42),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.name,
                              style: TextStyle(
                                color: context.fg,
                                fontSize: compact ? 13.5 : 15,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              [
                                _formatLabel(t.format),
                                '${t.teamCount}/${t.maxTeams} teams',
                                if (t.entryFee != null && t.entryFee! > 0) '₹${t.entryFee}',
                              ].join('  •  '),
                              style: TextStyle(
                                color: context.fgSub,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      _StatusPill(
                        label: statusLabel,
                        color: statusColor,
                        isLive: isLive,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 11, color: context.fgSub),
                      const SizedBox(width: 4),
                      Text(
                        t.dateRange,
                        style: TextStyle(
                          color: context.fgSub,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (t.city != null || t.venueName != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: context.fgSub.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.location_on_rounded, size: 11, color: context.fgSub),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _locationLabel(t),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: context.fgSub,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(width: 6),
                      Icon(Icons.chevron_right_rounded, size: 16, color: context.fgSub),
                    ],
                  ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _locationLabel(PlayTournament t) {
    if (t.venueName != null && t.city != null) return '${t.venueName}, ${t.city}';
    return t.venueName ?? t.city ?? '';
  }

  String _formatLabel(String format) => switch (format.toUpperCase()) {
        'ONE_DAY' => 'ODI',
        'TWO_INNINGS' => 'Test',
        _ => format,
      };
}

// ─── Logo ─────────────────────────────────────────────────────────────────────

class _Logo extends StatelessWidget {
  const _Logo({required this.url, required this.size});
  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.accentBg,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: url != null
          ? Image.network(url!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback(context))
          : _fallback(context),
    );
  }

  Widget _fallback(BuildContext context) => Center(
        child: Icon(Icons.emoji_events_rounded, color: context.accent, size: size * 0.48),
      );
}

// ─── Status pill ──────────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color, required this.isLive});
  final String label;
  final Color color;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLive) ...[
            Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ],
          Text(
            label,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ─── Badge ────────────────────────────────────────────────────────────────────

// ─── Helpers ──────────────────────────────────────────────────────────────────

Color _statusColor(String status, BuildContext context) => switch (status.toUpperCase()) {
      'ONGOING' || 'LIVE' || 'IN_PROGRESS' => context.success,
      'UPCOMING' => context.sky,
      'COMPLETED' => context.fgSub,
      'CANCELLED' => context.danger,
      _ => context.fgSub,
    };

String _statusLabel(String status) => switch (status.toUpperCase()) {
      'ONGOING' || 'LIVE' || 'IN_PROGRESS' => 'Live',
      'UPCOMING' => 'Upcoming',
      'COMPLETED' => 'Completed',
      'CANCELLED' => 'Cancelled',
      _ => status,
    };
