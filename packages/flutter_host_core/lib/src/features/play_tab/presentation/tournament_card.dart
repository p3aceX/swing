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

    return Material(
      color: isAlternate ? context.panel : context.bg,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Status strip
            Container(width: 3, color: statusColor),

            // Main content
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(14, compact ? 12 : 14, 16, compact ? 12 : 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Logo(url: t.logoUrl, size: compact ? 40 : 46),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name + status pill
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  t.name,
                                  style: TextStyle(
                                    color: context.fg,
                                    fontSize: compact ? 13 : 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _StatusPill(
                                label: statusLabel,
                                color: statusColor,
                                isLive: isLive,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Badges
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _Badge(
                                label: _formatLabel(t.format),
                                color: context.sky,
                                bg: context.sky.withValues(alpha: 0.1),
                              ),
                              if (t.isHost)
                                _Badge(
                                  label: 'Hosting',
                                  color: context.gold,
                                  bg: context.gold.withValues(alpha: 0.12),
                                  icon: Icons.star_rounded,
                                ),
                              if (t.ballType != null)
                                _Badge(
                                  label: t.ballType!,
                                  color: context.fgSub,
                                  bg: context.stroke.withValues(alpha: 0.5),
                                ),
                              if (t.entryFee != null && t.entryFee! > 0)
                                _Badge(
                                  label: '₹${t.entryFee}',
                                  color: context.success,
                                  bg: context.success.withValues(alpha: 0.1),
                                  icon: Icons.confirmation_number_rounded,
                                ),
                            ],
                          ),

                          if (!compact) ...[
                            const SizedBox(height: 10),
                            _TeamsBar(current: t.teamCount, max: t.maxTeams, context: context),
                          ],

                          const SizedBox(height: 8),

                          // Footer
                          Row(
                            children: [
                              if (t.city != null || t.venueName != null) ...[
                                Icon(Icons.location_on_rounded, size: 11, color: context.fgSub),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    _locationLabel(t),
                                    style: TextStyle(color: context.fgSub, fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 10),
                              ],
                              Icon(Icons.calendar_today_rounded, size: 11, color: context.fgSub),
                              const SizedBox(width: 3),
                              Text(
                                t.dateRange,
                                style: TextStyle(color: context.fgSub, fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded, size: 16, color: context.fgSub),
                  ],
                ),
              ),
            ),
          ],
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

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color, required this.bg, this.icon});
  final String label;
  final Color color;
  final Color bg;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(5)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 3),
          ],
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ─── Teams bar ────────────────────────────────────────────────────────────────

class _TeamsBar extends StatelessWidget {
  const _TeamsBar({required this.current, required this.max, required this.context});
  final int current;
  final int max;
  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    final pct = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;
    final isFull = current >= max;
    final barColor = isFull ? context.danger : context.accent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.groups_rounded, size: 12, color: context.fgSub),
            const SizedBox(width: 4),
            Text(
              '$current / $max teams',
              style: TextStyle(color: context.fgSub, fontSize: 11, fontWeight: FontWeight.w500),
            ),
            if (isFull) ...[
              const SizedBox(width: 6),
              Text('Full',
                  style: TextStyle(color: context.danger, fontSize: 10, fontWeight: FontWeight.w700)),
            ],
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 3,
            backgroundColor: context.stroke,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}

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
