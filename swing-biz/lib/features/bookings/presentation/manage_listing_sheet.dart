import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'arena_lobbies_section.dart';

/// Plan B / V2 — biz-side "Manage" sheet for an owner-originated lobby.
///
/// Shows the live status (searching / N interested / locked) and the
/// chronological list of teams who have expressed interest. Owner can:
///   • watch responses come in
///   • manually assign an offline team (bypasses interest queue)
///   • cancel the listing entirely (releases the slot)
class ManageListingSheet extends ConsumerWidget {
  const ManageListingSheet({
    super.key,
    required this.lobby,
    required this.onChanged,
  });

  final ArenaLobby lobby;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final interestsAsync = ref.watch(arenaLobbyInterestsProvider(lobby.lobbyId));
    final dateLabel = lobby.dateLabel;
    final slotLabel = lobby.confirmedSlot != null
        ? _fmtTime(lobby.confirmedSlot!)
        : lobby.displaySlot;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manage Listing',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${lobby.teamName} · ${lobby.format} · $dateLabel · $slotLabel',
                    style: TextStyle(
                      color: colors.onSurface.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  // ── Status block ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: interestsAsync.when(
                      loading: () => _statusLoading(colors),
                      error: (e, _) => _statusError(colors, e),
                      data: (snap) => _StatusBlock(snapshot: snap),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // ── Interested teams ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
                    child: Text(
                      'INTERESTED TEAMS',
                      style: TextStyle(
                        color: colors.onSurface.withValues(alpha: 0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  interestsAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (snap) {
                      final live = snap.interests
                          .where((i) => i.isLive || i.status == 'won')
                          .toList();
                      if (live.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                          child: Text(
                            'No teams have expressed interest yet. We\'ll '
                            'notify you the moment one does.',
                            style: TextStyle(
                              color: colors.onSurface.withValues(alpha: 0.6),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: [
                          for (final i in live)
                            _InterestRow(interest: i),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 28),
                  // ── Actions ───────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
                    child: Text(
                      'ACTIONS',
                      style: TextStyle(
                        color: colors.onSurface.withValues(alpha: 0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  _ActionRow(
                    icon: Icons.person_add_alt_1_rounded,
                    label: 'Assign a team manually',
                    sublabel: 'Slot in an offline team — overrides interests.',
                    onTap: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) =>
                            AssignTeamSheet(lobby: lobby, onAssigned: onChanged),
                      );
                    },
                  ),
                  _ActionRow(
                    icon: Icons.close_rounded,
                    label: 'Cancel listing',
                    sublabel: 'Removes the slot from the player pool.',
                    danger: true,
                    onTap: () => _confirmAndCancel(context, ref),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAndCancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel listing?'),
        content: const Text(
            'The slot will no longer be visible to players. Anyone who has expressed interest will be notified.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel listing',
                style: TextStyle(color: Color(0xFFDC2626))),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final dio = ref.read(hostDioProvider);
      debugPrint('[manageListing] DELETE /matchmaking/lobbies/${lobby.lobbyId}');
      await dio.delete('/matchmaking/lobbies/${lobby.lobbyId}');
      if (context.mounted) {
        Navigator.pop(context);
        onChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing cancelled')),
        );
      }
    } catch (e) {
      debugPrint('[manageListing] cancel ERROR $e');
      String msg = 'Could not cancel listing.';
      if (e is DioException) {
        final body = e.response?.data;
        if (body is Map) {
          final nested = body['error'];
          if (nested is Map && nested['message'] is String) {
            msg = nested['message'] as String;
          }
        }
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    }
  }

  Widget _statusLoading(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
                strokeWidth: 1.5, color: colors.primary),
          ),
          const SizedBox(width: 10),
          Text(
            'Loading status…',
            style: TextStyle(
              color: colors.onSurface.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusError(ColorScheme colors, Object err) {
    return Text(
      'Could not load interests · ${err.toString()}',
      style: TextStyle(
        color: colors.onSurface.withValues(alpha: 0.6),
        fontSize: 12,
      ),
    );
  }
}

class _StatusBlock extends StatelessWidget {
  const _StatusBlock({required this.snapshot});
  final ArenaLobbyInterestSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final liveInterests =
        snapshot.interests.where((i) => i.isLive).length;
    final hasLock = snapshot.lockedByInterestId != null &&
        (snapshot.lockExpiresAt?.isAfter(DateTime.now()) ?? false);

    final headline = hasLock
        ? 'Locked — a team is paying right now'
        : liveInterests > 0
            ? '$liveInterests team${liveInterests == 1 ? '' : 's'} interested'
            : 'Searching for a rival…';

    final subline = hasLock
        ? 'They have a 120-second window. If they don\'t pay, your slot will reopen.'
        : liveInterests > 0
            ? 'First team to pay locks the slot. Players see your listing in their app.'
            : 'Visible to players in the app. We\'ll notify you the moment a team responds.';

    final accent = hasLock
        ? colors.primary
        : liveInterests > 0
            ? colors.primary
            : colors.onSurface.withValues(alpha: 0.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                headline,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subline,
          style: TextStyle(
            color: colors.onSurface.withValues(alpha: 0.6),
            fontSize: 12.5,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _InterestRow extends StatelessWidget {
  const _InterestRow({required this.interest});
  final ArenaLobbyInterest interest;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final ago = _relativeTime(interest.expressedAt);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.outline, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  interest.teamName,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  [
                    if (interest.teamCity?.isNotEmpty == true) interest.teamCity,
                    'expressed $ago',
                  ].whereType<String>().join(' · '),
                  style: TextStyle(
                    color: colors.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusPill(status: interest.status),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    String label;
    Color fg;
    Color bg;
    switch (status) {
      case 'locked':
        label = 'Paying';
        fg = colors.primary;
        bg = colors.primary.withValues(alpha: 0.1);
        break;
      case 'won':
        label = 'Won';
        fg = const Color(0xFF059669);
        bg = const Color(0xFFDCFCE7);
        break;
      default:
        label = 'Interested';
        fg = colors.onSurface.withValues(alpha: 0.6);
        bg = colors.onSurface.withValues(alpha: 0.06);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.onTap,
    this.danger = false,
  });
  final IconData icon;
  final String label;
  final String sublabel;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fg = danger ? const Color(0xFFDC2626) : colors.onSurface;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colors.outline, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: fg, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: fg,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sublabel,
                    style: TextStyle(
                      color: colors.onSurface.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: colors.onSurface.withValues(alpha: 0.4), size: 18),
          ],
        ),
      ),
    );
  }
}

String _fmtTime(String t) {
  try {
    final parts = t.split(':');
    final hour = int.parse(parts[0]);
    final min = parts[1];
    final ampm = hour < 12 ? 'AM' : 'PM';
    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$h:$min $ampm';
  } catch (_) {
    return t;
  }
}

String _relativeTime(DateTime t) {
  final now = DateTime.now();
  final diff = now.difference(t);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return DateFormat('MMM d').format(t);
}
