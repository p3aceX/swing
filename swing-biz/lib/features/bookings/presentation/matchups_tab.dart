import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'arena_lobbies_section.dart';
import 'arena_matches_section.dart';
import 'manage_listing_sheet.dart';

class _C {
  const _C({
    required this.text,
    required this.muted,
    required this.faint,
    required this.hair,
    required this.surface,
    required this.bg,
    required this.accent,
    required this.onAccent,
  });
  final Color text;
  final Color muted;
  final Color faint;
  final Color hair;
  final Color surface;
  final Color bg;
  final Color accent;
  final Color onAccent;
  factory _C.of(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return _C(
      text: s.onSurface,
      muted: s.onSurface.withValues(alpha: 0.6),
      faint: s.onSurface.withValues(alpha: 0.4),
      hair: s.outline,
      surface: s.surfaceContainerHighest,
      bg: s.surface,
      accent: s.primary,
      onAccent: s.onPrimary,
    );
  }
}

late _C _c;

enum _Lane { requests, findTeam, matchups }

// ─── MatchUps tab ─────────────────────────────────────────────────────────────

class MatchUpsTab extends ConsumerStatefulWidget {
  const MatchUpsTab({super.key, required this.arenas});
  final List<ArenaListing> arenas;

  @override
  ConsumerState<MatchUpsTab> createState() => _MatchUpsTabState();
}

class _MatchUpsTabState extends ConsumerState<MatchUpsTab> {
  _Lane _lane = _Lane.requests;

  Future<void> _refresh() async {
    for (final a in widget.arenas) {
      ref.invalidate(arenaLobbiesProvider(a.id));
      ref.invalidate(arenaMatchesProvider(a.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final lobbyAsyncs = [
      for (final a in widget.arenas) (a, ref.watch(arenaLobbiesProvider(a.id)))
    ];
    final matchAsyncs = [
      for (final a in widget.arenas) (a, ref.watch(arenaMatchesProvider(a.id)))
    ];

    // Requests  = inbound player lobbies in any pre-pairing state
    //              - !accepted → "Pick a slot"
    //              -  accepted (slot locked, no rival yet) → "Assign rival"
    // Find Team = owner-originated listings only — this is where the owner
    //             is hunting for a rival on a slot they put up themselves.
    final requests = <(ArenaLobby, String, String)>[];
    final findTeam = <(ArenaLobby, String, String)>[];
    final seen = <String>{};
    for (final (arena, async) in lobbyAsyncs) {
      if (!async.hasValue) continue;
      for (final l in async.value!) {
        if (!seen.add(l.lobbyId)) continue;
        if (l.isOwnerOriginated) {
          findTeam.add((l, arena.id, arena.name));
        } else {
          requests.add((l, arena.id, arena.name));
        }
      }
    }

    final matches = <(ArenaMatch, String)>[];
    final seenMatchIds = <String>{};
    for (final (arena, async) in matchAsyncs) {
      if (!async.hasValue) continue;
      for (final m in async.value!) {
        if (seenMatchIds.add(m.matchId)) matches.add((m, arena.id));
      }
    }

    final isLoading =
        lobbyAsyncs.any((r) => r.$2.isLoading) ||
        matchAsyncs.any((r) => r.$2.isLoading);

    return Column(
      children: [
        _LaneTabs(
          selected: _lane,
          requestsCount: requests.length,
          findTeamCount: findTeam.length,
          matchupsCount: matches.length,
          onSelect: (l) => setState(() => _lane = l),
        ),
        Expanded(
          child: RefreshIndicator(
            color: Theme.of(context).colorScheme.primary,
            backgroundColor: _c.bg,
            onRefresh: _refresh,
            child: switch (_lane) {
              _Lane.requests => _RequestsLane(
                  items: requests,
                  isLoading: isLoading,
                  onRefresh: _refresh,
                ),
              _Lane.findTeam => _FindTeamLane(
                  items: findTeam,
                  isLoading: isLoading,
                  onRefresh: _refresh,
                ),
              _Lane.matchups =>
                _MatchupsLane(items: matches, isLoading: isLoading),
            },
          ),
        ),
      ],
    );
  }
}

// ─── Lane tabs (flat, underline) ──────────────────────────────────────────────

class _LaneTabs extends StatelessWidget {
  const _LaneTabs({
    required this.selected,
    required this.requestsCount,
    required this.findTeamCount,
    required this.matchupsCount,
    required this.onSelect,
  });

  final _Lane selected;
  final int requestsCount;
  final int findTeamCount;
  final int matchupsCount;
  final ValueChanged<_Lane> onSelect;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _c.hair, width: 0.5)),
      ),
      child: Row(
        children: [
          _LaneTab(
            label: 'Requests',
            count: requestsCount,
            active: selected == _Lane.requests,
            onTap: () => onSelect(_Lane.requests),
          ),
          _LaneTab(
            label: 'Find Team',
            count: findTeamCount,
            active: selected == _Lane.findTeam,
            onTap: () => onSelect(_Lane.findTeam),
          ),
          _LaneTab(
            label: 'Match-Up',
            count: matchupsCount,
            active: selected == _Lane.matchups,
            onTap: () => onSelect(_Lane.matchups),
          ),
        ],
      ),
    );
  }
}

class _LaneTab extends StatelessWidget {
  const _LaneTab({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
  });
  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final accent = Theme.of(context).colorScheme.primary;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? accent : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: label,
                      style: TextStyle(
                        color: active ? accent : _c.muted,
                        fontSize: 14,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        letterSpacing: 0.1,
                      ),
                    ),
                    TextSpan(
                      text: '  $count',
                      style: TextStyle(
                        color: active ? _c.muted : _c.faint,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (count > 0 && !active)
                Positioned(
                  top: -3,
                  right: -6,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Lanes ────────────────────────────────────────────────────────────────────

class _RequestsLane extends ConsumerWidget {
  const _RequestsLane({
    required this.items,
    required this.isLoading,
    required this.onRefresh,
  });
  final List<(ArenaLobby, String, String)> items;
  final bool isLoading;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _c = _C.of(context);
    if (isLoading && items.isEmpty) return const _LoadingView();
    if (items.isEmpty) {
      return const _EmptyView(
        title: 'No new requests',
        subtitle: 'Player requests for your grounds will appear here.',
      );
    }

    final pickSlot = items.where((e) => !e.$1.accepted).toList();
    final assignRival = items.where((e) => e.$1.accepted).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        if (pickSlot.isNotEmpty) ...[
          const _SectionHeader(label: 'PICK A SLOT'),
          for (final (lobby, arenaId, arenaName) in pickSlot)
            _LobbyRow(
              lobby: lobby,
              arenaId: arenaId,
              arenaName: arenaName,
              actionLabel: 'Accept',
              onTap: () => _openAccept(context, lobby, arenaId, arenaName, ref),
            ),
        ],
        if (assignRival.isNotEmpty) ...[
          const _SectionHeader(label: 'ASSIGN RIVAL'),
          for (final (lobby, arenaId, arenaName) in assignRival)
            _LobbyRow(
              lobby: lobby,
              arenaId: arenaId,
              arenaName: arenaName,
              actionLabel: 'Assign',
              secondary: 'slot locked',
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) =>
                    AssignTeamSheet(lobby: lobby, onAssigned: onRefresh),
              ),
            ),
        ],
      ],
    );
  }

  void _openAccept(
    BuildContext context,
    ArenaLobby lobby,
    String arenaId,
    String arenaName,
    WidgetRef ref,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AcceptLobbySheet(
        lobby: lobby,
        arenaId: arenaId,
        arenaName: arenaName,
        onAccepted: onRefresh,
      ),
    );
  }

}

class _FindTeamLane extends ConsumerWidget {
  const _FindTeamLane({
    required this.items,
    required this.isLoading,
    required this.onRefresh,
  });
  final List<(ArenaLobby, String, String)> items;
  final bool isLoading;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _c = _C.of(context);
    if (isLoading && items.isEmpty) return const _LoadingView();
    if (items.isEmpty) {
      return const _EmptyView(
        title: 'No active listings',
        subtitle:
            'Tap Book → Match-Up Request to list a slot for an offline team. Players in the app will see it.',
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        const _SectionHeader(label: 'MY LISTINGS'),
        for (final (lobby, arenaId, arenaName) in items)
          _LobbyRow(
            lobby: lobby,
            arenaId: arenaId,
            arenaName: arenaName,
            actionLabel: 'Manage',
            secondary: lobby.interestCount > 0
                ? '${lobby.interestCount} interested'
                : 'searching for a rival…',
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => ManageListingSheet(
                lobby: lobby,
                onChanged: onRefresh,
              ),
            ),
          ),
      ],
    );
  }
}

class _MatchupsLane extends StatelessWidget {
  const _MatchupsLane({required this.items, required this.isLoading});
  final List<(ArenaMatch, String)> items;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    if (isLoading && items.isEmpty) return const _LoadingView();
    if (items.isEmpty) {
      return const _EmptyView(
        title: 'No Match-Ups yet',
        subtitle: 'Paired matches show up here, ready to collect payment and play.',
      );
    }

    // Four distinct stages so a Setup Match action visibly *moves* the row:
    //   pending_payment → ADVANCE PENDING
    //   confirmed       → READY FOR SETUP   (advance in, awaiting Setup Match)
    //   setup + today   → TODAY
    //   setup + future  → UPCOMING
    final advancePending =
        items.where((e) => e.$1.status == 'pending_payment').toList();
    final readyForSetup =
        items.where((e) => e.$1.isConfirmed).toList();
    final today = items
        .where((e) => e.$1.isSetUp && e.$1.daysFromNow == 0)
        .toList();
    final upcoming = items
        .where((e) => e.$1.isSetUp && e.$1.daysFromNow != 0)
        .toList();

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      children: [
        if (advancePending.isNotEmpty) ...[
          const _SectionHeader(label: 'ADVANCE PENDING'),
          for (final (m, arenaId) in advancePending)
            _MatchRow(match: m, arenaId: arenaId),
        ],
        if (readyForSetup.isNotEmpty) ...[
          const _SectionHeader(label: 'READY FOR SETUP'),
          for (final (m, arenaId) in readyForSetup)
            _MatchRow(match: m, arenaId: arenaId),
        ],
        if (today.isNotEmpty) ...[
          const _SectionHeader(label: 'TODAY'),
          for (final (m, arenaId) in today)
            _MatchRow(match: m, arenaId: arenaId),
        ],
        if (upcoming.isNotEmpty) ...[
          const _SectionHeader(label: 'UPCOMING'),
          for (final (m, arenaId) in upcoming)
            _MatchRow(match: m, arenaId: arenaId),
        ],
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.match, required this.paidCount});
  final ArenaMatch match;
  final int paidCount;

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color bg;
    final Color fg;

    if (match.isSetUp) {
      label = 'Setup Done';
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF059669);
    } else if (match.isConfirmed) {
      label = 'Ready to Setup';
      bg = const Color(0xFFEFF6FF);
      fg = const Color(0xFF2563EB);
    } else {
      label = '$paidCount/2 Paid';
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFD97706);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── Flat row primitives ──────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
      child: Text(
        label,
        style: TextStyle(
          color: _c.faint,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _LobbyRow extends StatelessWidget {
  const _LobbyRow({
    required this.lobby,
    required this.arenaId,
    required this.arenaName,
    required this.actionLabel,
    required this.onTap,
    this.secondary,
  });

  final ArenaLobby lobby;
  final String arenaId;
  final String arenaName;
  final String actionLabel;
  final String? secondary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final slot = lobby.confirmedSlot != null
        ? _formatTime(lobby.confirmedSlot!)
        : (lobby.picks.length > 1
            ? '${lobby.picks.length} slots'
            : lobby.displaySlot);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: _c.hair, width: 0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    lobby.teamName,
                    style: TextStyle(
                      color: _c.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3),
                  Text(
                    [
                      lobby.format,
                      lobby.dateLabel,
                      slot,
                      if (secondary != null) secondary!,
                    ].join(' · '),
                    style: TextStyle(
                      color: _c.muted,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            Text(
              actionLabel,
              style: TextStyle(
                color: _c.text,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: _c.faint),
          ],
        ),
      ),
    );
  }
}

class _MatchRow extends StatelessWidget {
  const _MatchRow({required this.match, required this.arenaId});
  final ArenaMatch match;
  final String arenaId;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final paidCount =
        (match.teamAConfirmed ? 1 : 0) + (match.teamBConfirmed ? 1 : 0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => MatchDetailSheet(match: match, arenaId: arenaId),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _c.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: status + chevron
            Row(
              children: [
                _StatusPill(match: match, paidCount: paidCount),
                const Spacer(),
                Icon(Icons.chevron_right_rounded, size: 16, color: _c.faint),
              ],
            ),
            const SizedBox(height: 14),
            // Teams face-off
            Row(
              children: [
                Expanded(
                  child: Text(
                    match.teamAName,
                    style: TextStyle(
                      color: _c.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: _c.bg,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    'VS',
                    style: TextStyle(
                      color: _c.faint,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    match.teamBName,
                    style: TextStyle(
                      color: _c.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Pay status per team
            Row(
              children: [
                _PayChip(paid: match.teamAConfirmed, label: match.teamAName),
                const Spacer(),
                _PayChip(paid: match.teamBConfirmed, label: match.teamBName, alignEnd: true),
              ],
            ),
            const SizedBox(height: 12),
            // Divider
            Divider(height: 1, color: _c.hair),
            const SizedBox(height: 10),
            // Meta: format · date · slot · ground
            Text(
              [
                if (match.format.isNotEmpty) match.format,
                match.dateLabel,
                match.displaySlot,
                if (match.groundName.isNotEmpty) match.groundName,
              ].join('  ·  '),
              style: TextStyle(
                color: _c.muted,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _PayChip extends StatelessWidget {
  const _PayChip({required this.paid, required this.label, this.alignEnd = false});
  final bool paid;
  final String label;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!alignEnd) ...[
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: paid ? const Color(0xFF059669) : _c.hair,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
        ],
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 90),
          child: Text(
            paid ? 'Paid' : 'Pending',
            style: TextStyle(
              color: paid ? const Color(0xFF059669) : _c.muted,
              fontSize: 11,
              fontWeight: paid ? FontWeight.w700 : FontWeight.w400,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          ),
        ),
        if (alignEnd) ...[
          const SizedBox(width: 5),
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: paid ? const Color(0xFF059669) : _c.hair,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Empty / loading ──────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) => Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return ListView(
      physics: AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _c.text,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(color: _c.muted, fontSize: 13, height: 1.4),
        ),
      ],
    );
  }
}

String _formatTime(String t) {
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
