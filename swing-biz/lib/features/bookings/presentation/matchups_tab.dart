import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'arena_lobbies_section.dart';
import 'arena_matches_section.dart';

const _text = Color(0xFF111827);
const _muted = Color(0xFF6B7280);
const _faint = Color(0xFF9CA3AF);
const _hair = Color(0xFFE5E7EB);

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
            backgroundColor: Colors.white,
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
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _hair, width: 0.5)),
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
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: label,
                  style: TextStyle(
                    color: active ? accent : _muted,
                    fontSize: 14,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: 0.1,
                  ),
                ),
                TextSpan(
                  text: '  $count',
                  style: TextStyle(
                    color: active ? _muted : _faint,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
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
            actionLabel: 'Assign',
            secondary: 'open to players',
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) =>
                  AssignTeamSheet(lobby: lobby, onAssigned: onRefresh),
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
    if (isLoading && items.isEmpty) return const _LoadingView();
    if (items.isEmpty) {
      return const _EmptyView(
        title: 'No Match-Ups yet',
        subtitle: 'Paired matches show up here, ready to collect payment and play.',
      );
    }

    final pendingPay = items
        .where((e) => !e.$1.isReadyToPlay && !e.$1.isSetUp)
        .toList();
    final today = items
        .where((e) => e.$1.isReadyToPlay && e.$1.daysFromNow == 0)
        .toList();
    final upcoming = items
        .where((e) => e.$1.isReadyToPlay && e.$1.daysFromNow != 0)
        .toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        if (pendingPay.isNotEmpty) ...[
          const _SectionHeader(label: 'ADVANCE PENDING'),
          for (final (m, arenaId) in pendingPay)
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

// ─── Flat row primitives ──────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
      child: Text(
        label,
        style: const TextStyle(
          color: _faint,
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
    final slot = lobby.confirmedSlot != null
        ? _formatTime(lobby.confirmedSlot!)
        : (lobby.picks.length > 1
            ? '${lobby.picks.length} slots'
            : lobby.displaySlot);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: _hair, width: 0.5)),
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
                    style: const TextStyle(
                      color: _text,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    [
                      lobby.format,
                      lobby.dateLabel,
                      slot,
                      if (secondary != null) secondary!,
                    ].join(' · '),
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              actionLabel,
              style: const TextStyle(
                color: _text,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: _faint),
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
    final paidCount =
        (match.teamAConfirmed ? 1 : 0) + (match.teamBConfirmed ? 1 : 0);

    final String stateMeta;
    if (match.isSetUp) {
      stateMeta = 'setup done';
    } else if (match.isConfirmed) {
      stateMeta = 'advance received · ready to setup';
    } else {
      stateMeta = '$paidCount of 2 advance received';
    }
    final meta = [
      match.format,
      match.dateLabel,
      match.displaySlot,
      stateMeta,
    ].join(' · ');

    return InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => MatchDetailSheet(match: match, arenaId: arenaId),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: _hair, width: 0.5)),
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
                    '${match.teamAName}  vs  ${match.teamBName}',
                    style: const TextStyle(
                      color: _text,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    meta,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 12.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              match.isSetUp
                  ? 'Open'
                  : match.isConfirmed
                      ? 'Setup'
                      : 'Manage',
              style: const TextStyle(
                color: _text,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 18, color: _faint),
          ],
        ),
      ),
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
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _text,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: _muted, fontSize: 13, height: 1.4),
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
