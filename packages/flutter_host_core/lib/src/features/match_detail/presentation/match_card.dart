import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../theme/host_colors.dart';
import '../domain/match_models.dart';

bool _hasText(String? v) => v != null && v.trim().isNotEmpty;

/// Flat reusable match card. Wire [onTap] to navigate to match detail.
class HostMatchCard extends StatelessWidget {
  const HostMatchCard({
    super.key,
    required this.match,
    this.onTap,
    this.showHostingTag = false,
  });

  final PlayerMatch match;
  final VoidCallback? onTap;
  final bool showHostingTag;

  @override
  Widget build(BuildContext context) {
    final isLive = match.lifecycle == MatchLifecycle.live;
    final isUpcoming = match.lifecycle == MatchLifecycle.upcoming;
    final isPast = match.lifecycle == MatchLifecycle.past;

    final resultColor = switch (match.result) {
      MatchResult.win => context.success,
      MatchResult.loss => context.danger,
      MatchResult.draw => context.warn,
      MatchResult.unknown => context.fgSub,
    };

    final statusColor = isLive ? context.success : isPast ? resultColor : context.sky;

    final statusLabel = isUpcoming
        ? 'UPCOMING'
        : switch (match.result) {
            MatchResult.win => 'WON',
            MatchResult.loss => 'LOST',
            MatchResult.draw => 'DRAW',
            MatchResult.unknown => isLive ? 'LIVE' : '–',
          };

    // Parse innings rows and optional result line from scoreSummary.
    final parsed = _parseScore(match.scoreSummary);
    final inningsRows = parsed.$1;
    final resultLine = parsed.$2;

    // Fallback status text when no score is available.
    final statusLine = inningsRows.isEmpty ? _buildStatusLine(match) : null;

    final tossLine = _buildTossLine(match);

    // Left-border accent color: pulsing green for live, sky for upcoming, faded for past
    final borderColor = isLive
        ? context.success
        : isUpcoming
            ? context.sky
            : context.stroke;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: context.stroke.withValues(alpha: 0.6),
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: IntrinsicHeight(
              child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Lifecycle accent — left strip drawn inside the clip
                Container(width: 3.5, color: borderColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 14, 14, 14),
                    child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Meta row: status · format · date ─────────────────────────
            Row(
              children: [
                if (isLive) ...[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                        color: context.success, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 5),
                ],
                Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                if (_hasText(match.formatLabel)) ...[
                  _dot(context),
                  Text(
                    match.formatLabel!,
                    style: TextStyle(
                        color: context.fgSub,
                        fontSize: 10,
                        fontWeight: FontWeight.w600),
                  ),
                ],
                if (_hasText(match.ballType)) ...[
                  _dot(context),
                  Text(
                    match.ballType!,
                    style: TextStyle(color: context.fgSub, fontSize: 10),
                  ),
                ],
                const Spacer(),
                if (match.scheduledAt != null)
                  Text(
                    DateFormat('d MMM yyyy').format(match.scheduledAt!),
                    style: TextStyle(color: context.fgSub, fontSize: 10),
                  ),
                if (showHostingTag && match.canScore && match.lifecycle != MatchLifecycle.past) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.accentBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Hosting',
                      style: TextStyle(
                        color: context.accent,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),

            // ── Innings score rows ────────────────────────────────────────
            if (inningsRows.isNotEmpty) ...[
              ...inningsRows.map((row) => Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            row.$1,
                            style: TextStyle(
                              color: context.fg,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          row.$2,
                          style: TextStyle(
                            color: context.fg,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  )),
              if (_hasText(resultLine)) ...[
                const SizedBox(height: 2),
                Text(
                  resultLine!,
                  style: TextStyle(
                    color: resultColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ] else ...[
              // No score: show team names and optional status hint.
              Row(
                children: [
                  Expanded(
                    child: Text(
                      match.playerTeamName.isNotEmpty
                          ? match.playerTeamName
                          : match.title.split(' vs ').firstOrNull ?? match.title,
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'vs',
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      match.opponentTeamName.isNotEmpty
                          ? match.opponentTeamName
                          : 'TBD',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: context.fg.withValues(alpha: 0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (_hasText(statusLine)) ...[
                const SizedBox(height: 6),
                Text(
                  statusLine!,
                  style: TextStyle(
                    color: isLive ? context.success : context.fgSub,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],

            // ── Detail footer: toss · venue · arrow ──────────────────────
            if (_hasText(tossLine) || _hasText(match.venueLabel) || onTap != null) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_hasText(tossLine))
                          _DetailLine(
                            icon: Icons.sports_cricket_rounded,
                            text: tossLine!,
                            context: context,
                          ),
                        if (_hasText(tossLine) && _hasText(match.venueLabel))
                          const SizedBox(height: 3),
                        if (_hasText(match.venueLabel))
                          _DetailLine(
                            icon: Icons.location_on_outlined,
                            text: match.venueLabel!,
                            context: context,
                          ),
                      ],
                    ),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: context.fgSub, size: 13),
                  ],
                ],
              ),
            ],
          ],
                    ),
                  ),
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dot(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Text('·',
            style: TextStyle(color: context.fgSub, fontSize: 10)),
      );

  /// Splits scoreSummary (newline-separated) into innings rows + optional result line.
  /// Each innings line format: "Team Name  runs/wkts (overs)"
  (List<(String, String)>, String?) _parseScore(String? summary) {
    if (summary == null || summary.trim().isEmpty) return ([], null);
    final lines = summary.trim().split('\n');
    final rows = <(String, String)>[];
    String? resultLine;

    for (final line in lines) {
      // Result lines contain "won", "draw", "tied", "abandoned".
      final lower = line.toLowerCase();
      if (lower.contains(' won') ||
          lower.contains('draw') ||
          lower.contains('tied') ||
          lower.contains('abandoned')) {
        resultLine = line.trim();
        continue;
      }
      // Split on 2+ consecutive spaces to separate team name from score.
      final parts = line.trim().split(RegExp(r'\s{2,}'));
      if (parts.length >= 2) {
        rows.add((parts[0].trim(), parts[1].trim()));
      } else if (parts.length == 1 && parts[0].isNotEmpty) {
        rows.add((parts[0].trim(), ''));
      }
    }
    return (rows, resultLine);
  }

  String? _buildTossLine(PlayerMatch m) {
    if (!_hasText(m.tossWinner)) return null;
    if (m.tossDecision == null || m.tossDecision!.isEmpty) return m.tossWinner;
    final decision = m.tossDecision!.toUpperCase();
    if (decision == 'BAT' || decision == 'BATTING') {
      return '${m.tossWinner} won toss · elected to bat';
    } else if (decision == 'BOWL' || decision == 'BOWLING' || decision == 'FIELD') {
      return '${m.tossWinner} won toss · elected to bowl';
    }
    return '${m.tossWinner} won the toss';
  }

  String? _buildStatusLine(PlayerMatch m) {
    return switch (m.statusLabel.toUpperCase()) {
      'TOSS_DONE' => 'Toss done · match in progress',
      'IN_PROGRESS' => 'Match in progress',
      'STUMPS' => 'Stumps · day play ended',
      'INNINGS_BREAK' => 'Innings break',
      'RAIN_DELAY' => 'Rain delay',
      _ => null,
    };
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.icon,
    required this.text,
    required this.context,
  });

  final IconData icon;
  final String text;
  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    return Row(
      children: [
        Icon(icon, color: context.fgSub, size: 11),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: context.fgSub, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
