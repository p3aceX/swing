import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/admin_detail_widgets.dart';
import '../data/matches_repository.dart';
import '../domain/admin_match.dart';

enum _MatchTab {
  overview('Overview'),
  scoreboard('Scoreboard'),
  balls('Ball by ball'),
  players('Players'),
  liveOps('Live Ops'),
  highlights('Highlights');

  const _MatchTab(this.label);
  final String label;
}

class MatchDetailScreen extends ConsumerStatefulWidget {
  const MatchDetailScreen({super.key, required this.matchId});

  final String matchId;

  @override
  ConsumerState<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends ConsumerState<MatchDetailScreen> {
  _MatchTab _tab = _MatchTab.overview;

  Future<void> _deleteMatch() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hard delete match'),
        content: const Text(
          'This permanently deletes the match and related scoring data. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
              child: const Text('Hard delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ref.read(matchesRepositoryProvider).delete(widget.matchId);
      ref.invalidate(matchesSummaryProvider);
      ref.invalidate(matchesTrendItemsProvider);
      ref.invalidate(matchDetailProvider(widget.matchId));
      ref.invalidate(matchPlayersProvider(widget.matchId));
      ref.invalidate(matchStreamProvider(widget.matchId));
      ref.invalidate(matchStudioProvider(widget.matchId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Match deleted')),
        );
        context.go('/matches');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;
    final matchAsync = ref.watch(matchDetailProvider(widget.matchId));
    final playersAsync = ref.watch(matchPlayersProvider(widget.matchId));
    final streamAsync = ref.watch(matchStreamProvider(widget.matchId));
    final studioAsync = ref.watch(matchStudioProvider(widget.matchId));

    return Scaffold(
      appBar: compact
          ? null
          : AppBar(
              leading: IconButton(
                onPressed: () => context.go('/matches'),
                icon: const Icon(Icons.arrow_back),
              ),
              title: const Text('Match workspace'),
              actions: [
                IconButton(
                  onPressed: _deleteMatch,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Hard delete match',
                ),
                const SizedBox(width: 8),
              ],
            ),
      body: SafeArea(
        top: false,
        child: matchAsync.when(
          data: (match) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                if (compact) ...[
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.go('/matches'),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Text(
                          'Match workspace',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _deleteMatch,
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Hard delete match',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                _MatchHero(match: match),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final item in _MatchTab.values) ...[
                        _TabChip(
                          label: item.label,
                          selected: _tab == item,
                          onTap: () => setState(() => _tab = item),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _buildTabBody(
                  match: match,
                  playersAsync: playersAsync,
                  streamAsync: streamAsync,
                  studioAsync: studioAsync,
                ),
              ],
            );
          },
          loading: () => const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                error.toString(),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.danger,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBody({
    required AdminMatch match,
    required AsyncValue<Map<String, dynamic>> playersAsync,
    required AsyncValue<Map<String, dynamic>?> streamAsync,
    required AsyncValue<Map<String, dynamic>> studioAsync,
  }) {
    switch (_tab) {
      case _MatchTab.overview:
        return _MatchOverviewTab(match: match);
      case _MatchTab.scoreboard:
        return _ScoreboardTab(match: match);
      case _MatchTab.balls:
        return _BallByBallTab(match: match);
      case _MatchTab.players:
        return _PlayersTab(async: playersAsync);
      case _MatchTab.liveOps:
        return _LiveOpsTab(
          match: match,
          streamAsync: streamAsync,
          studioAsync: studioAsync,
        );
      case _MatchTab.highlights:
        return _HighlightsTab(match: match);
    }
  }
}

class _MatchHero extends StatelessWidget {
  const _MatchHero({required this.match});

  final AdminMatch match;

  @override
  Widget build(BuildContext context) {
    final scheduled = match.scheduledAt ?? match.createdAt;
    return AdminSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            match.displayTitle,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            scheduled == null
                ? 'Time pending'
                : DateFormat('dd MMM yyyy, h:mm a').format(scheduled.toLocal()),
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AdminInfoPill(label: _pretty(match.status)),
              if (match.format.isNotEmpty) AdminInfoPill(label: _pretty(match.format)),
              if (match.matchType.isNotEmpty)
                AdminInfoPill(label: _pretty(match.matchType)),
              if (match.venueName.trim().isNotEmpty)
                AdminInfoPill(label: match.venueName.trim()),
              if (match.round.trim().isNotEmpty)
                AdminInfoPill(label: match.round.trim()),
            ],
          ),
        ],
      ),
    );
  }
}

class _MatchOverviewTab extends StatelessWidget {
  const _MatchOverviewTab({required this.match});

  final AdminMatch match;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 860;
        final info = AdminKeyValueCard(
          title: 'Match info',
          rows: [
            AdminKeyValueRowData('Status', _pretty(match.status)),
            AdminKeyValueRowData('Format', _pretty(match.format)),
            AdminKeyValueRowData('Type', _pretty(match.matchType)),
            AdminKeyValueRowData('Venue', _fallback(match.venueName)),
            AdminKeyValueRowData('Round', _fallback(match.round)),
            AdminKeyValueRowData(
              'Scheduled',
              match.scheduledAt == null
                  ? 'Pending'
                  : DateFormat('dd MMM yyyy, h:mm a')
                      .format(match.scheduledAt!.toLocal()),
            ),
          ],
        );
        final ops = AdminKeyValueCard(
          title: 'Match ops',
          rows: [
            AdminKeyValueRowData('Verification', _fallback(match.verificationLevel)),
            AdminKeyValueRowData('Live code', _fallback(match.liveCode)),
            AdminKeyValueRowData('Live pin', _fallback(match.livePin)),
            AdminKeyValueRowData('Toss won by', _fallback(match.tossWonBy)),
            AdminKeyValueRowData('Toss decision', _pretty(match.tossDecision)),
            AdminKeyValueRowData('Stream', match.hasLiveStream ? 'Linked' : 'Not linked'),
          ],
        );
        final result = AdminKeyValueCard(
          title: 'Result',
          rows: [
            AdminKeyValueRowData('Winner', _fallback(match.resultText)),
            AdminKeyValueRowData('Win margin', _fallback(match.winMargin)),
          ],
        );

        if (stacked) {
          return Column(
            children: [
              info,
              const SizedBox(height: 12),
              ops,
              const SizedBox(height: 12),
              result,
            ],
          );
        }

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: info),
                const SizedBox(width: 12),
                Expanded(child: ops),
              ],
            ),
            const SizedBox(height: 12),
            result,
          ],
        );
      },
    );
  }
}

class _ScoreboardTab extends StatelessWidget {
  const _ScoreboardTab({required this.match});

  final AdminMatch match;

  @override
  Widget build(BuildContext context) {
    return AdminSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionHeader(
            title: 'Scoreboard',
            subtitle: 'Innings totals, overs, and current scoring state.',
          ),
          const SizedBox(height: 14),
          if (match.innings.isEmpty)
            const Text(
              'No innings recorded yet.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            )
          else
            for (var index = 0; index < match.innings.length; index++) ...[
              _InningsScoreTile(innings: match.innings[index]),
              if (index < match.innings.length - 1) const Divider(height: 18),
            ],
        ],
      ),
    );
  }
}

class _InningsScoreTile extends StatelessWidget {
  const _InningsScoreTile({required this.innings});

  final MatchInningsSummary innings;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Innings ${innings.inningsNumber} · ${innings.battingTeam.isEmpty ? 'Team ${innings.inningsNumber}' : innings.battingTeam}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${innings.totalRuns}/${innings.totalWickets} in ${innings.totalOvers} overs · Extras ${innings.extras}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        AdminInfoPill(label: innings.isCompleted ? 'Complete' : 'Open'),
      ],
    );
  }
}

class _BallByBallTab extends StatelessWidget {
  const _BallByBallTab({required this.match});

  final AdminMatch match;

  @override
  Widget build(BuildContext context) {
    return AdminSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionHeader(
            title: 'Ball by ball',
            subtitle: 'Every recorded delivery from the innings timeline.',
          ),
          const SizedBox(height: 14),
          if (match.innings.every((innings) => innings.ballEvents.isEmpty))
            const Text(
              'No ball events available yet.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            )
          else
            for (final innings in match.innings) ...[
              if (innings.ballEvents.isNotEmpty) ...[
                Text(
                  'Innings ${innings.inningsNumber}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                for (var index = 0; index < innings.ballEvents.length; index++) ...[
                  _BallEventTile(event: innings.ballEvents[index]),
                  if (index < innings.ballEvents.length - 1)
                    const Divider(height: 16),
                ],
                const SizedBox(height: 14),
              ],
            ],
        ],
      ),
    );
  }
}

class _BallEventTile extends StatelessWidget {
  const _BallEventTile({required this.event});

  final MatchBallEvent event;

  @override
  Widget build(BuildContext context) {
    final labels = <String>[
      '${event.overNumber}.${event.ballNumber}',
      '${event.totalRuns} run${event.totalRuns == 1 ? '' : 's'}',
      if (event.extraType.isNotEmpty) _pretty(event.extraType),
      if (event.isWicket) 'Wicket',
      if (event.dismissalType.isNotEmpty) _pretty(event.dismissalType),
    ];
    return Row(
      children: [
        SizedBox(
          width: 68,
          child: Text(
            '${event.overNumber}.${event.ballNumber}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final label in labels.skip(1)) AdminInfoPill(label: label),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlayersTab extends StatelessWidget {
  const _PlayersTab({required this.async});

  final AsyncValue<Map<String, dynamic>> async;

  @override
  Widget build(BuildContext context) {
    return async.when(
      data: (data) {
        return Column(
          children: [
            _SquadCard(
              title: _teamName(data['teamA'], 'Team A'),
              team: _toMap(data['teamA']),
            ),
            const SizedBox(height: 12),
            _SquadCard(
              title: _teamName(data['teamB'], 'Team B'),
              team: _toMap(data['teamB']),
            ),
          ],
        );
      },
      loading: () => const _AsyncCardLoader(),
      error: (error, _) => _AsyncCardError(message: error.toString()),
    );
  }
}

class _SquadCard extends StatelessWidget {
  const _SquadCard({
    required this.title,
    required this.team,
  });

  final String title;
  final Map<String, dynamic> team;

  @override
  Widget build(BuildContext context) {
    final players = _toList(team['players']);
    return AdminSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminSectionHeader(
            title: title,
            subtitle:
                '${players.length} player${players.length == 1 ? '' : 's'} resolved for XI and squad operations.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_string(team['captainId']).isNotEmpty)
                AdminInfoPill(label: 'Captain set'),
              if (_string(team['viceCaptainId']).isNotEmpty)
                AdminInfoPill(label: 'Vice captain set'),
              if (_string(team['wicketKeeperId']).isNotEmpty)
                AdminInfoPill(label: 'Wicket keeper set'),
            ],
          ),
          const SizedBox(height: 12),
          if (players.isEmpty)
            const Text(
              'No players resolved yet.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            )
          else
            for (var index = 0; index < players.length; index++) ...[
              _PlayerRow(player: _toMap(players[index])),
              if (index < players.length - 1) const Divider(height: 16),
            ],
        ],
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({required this.player});

  final Map<String, dynamic> player;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            _string(player['name']).isEmpty ? 'Unnamed player' : _string(player['name']),
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (_string(player['profileId']).isNotEmpty)
          Text(
            _string(player['profileId']),
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.textMuted,
            ),
          ),
      ],
    );
  }
}

class _LiveOpsTab extends StatelessWidget {
  const _LiveOpsTab({
    required this.match,
    required this.streamAsync,
    required this.studioAsync,
  });

  final AdminMatch match;
  final AsyncValue<Map<String, dynamic>?> streamAsync;
  final AsyncValue<Map<String, dynamic>> studioAsync;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AdminKeyValueCard(
          title: 'Live access',
          rows: [
            AdminKeyValueRowData('Live code', _fallback(match.liveCode)),
            AdminKeyValueRowData('Live pin', _fallback(match.livePin)),
            AdminKeyValueRowData('YouTube URL', _fallback(match.liveStreamUrl)),
          ],
        ),
        const SizedBox(height: 12),
        streamAsync.when(
          data: (stream) => AdminKeyValueCard(
            title: 'Stream status',
            rows: [
              AdminKeyValueRowData('State', stream == null ? 'Not running' : 'Available'),
              AdminKeyValueRowData('HLS', _fallback(_string(stream?['hlsUrl']))),
              AdminKeyValueRowData('WebSocket', _fallback(_string(stream?['wsUrl']))),
            ],
          ),
          loading: () => const _AsyncCardLoader(),
          error: (error, _) => _AsyncCardError(message: error.toString()),
        ),
        const SizedBox(height: 12),
        studioAsync.when(
          data: (studio) => AdminKeyValueCard(
            title: 'Studio scene',
            rows: [
              AdminKeyValueRowData('Scene', _fallback(_string(studio['scene']))),
              AdminKeyValueRowData(
                  'Break type', _fallback(_string(studio['breakType']))),
              AdminKeyValueRowData(
                  'Updated', _fallback(_string(studio['updatedAt']))),
            ],
          ),
          loading: () => const _AsyncCardLoader(),
          error: (error, _) => _AsyncCardError(message: error.toString()),
        ),
      ],
    );
  }
}

class _HighlightsTab extends StatelessWidget {
  const _HighlightsTab({required this.match});

  final AdminMatch match;

  @override
  Widget build(BuildContext context) {
    return AdminSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionHeader(
            title: 'Highlights',
            subtitle: 'Match highlight links attached in admin.',
          ),
          const SizedBox(height: 14),
          if (match.highlights.isEmpty)
            const Text(
              'No highlights attached yet.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            )
          else
            for (var index = 0; index < match.highlights.length; index++) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match.highlights[index].title.isEmpty
                              ? 'Untitled highlight'
                              : match.highlights[index].title,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _fallback(match.highlights[index].url),
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (index < match.highlights.length - 1) const Divider(height: 16),
            ],
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.textPrimary : AppColors.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.textPrimary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _AsyncCardLoader extends StatelessWidget {
  const _AsyncCardLoader();

  @override
  Widget build(BuildContext context) {
    return const AdminSurfaceCard(
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _AsyncCardError extends StatelessWidget {
  const _AsyncCardError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AdminSurfaceCard(
      child: Text(
        message,
        style: const TextStyle(fontSize: 13, color: AppColors.danger),
      ),
    );
  }
}

String _pretty(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return 'Not available';
  return trimmed
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0]}${part.substring(1).toLowerCase()}')
      .join(' ');
}

String _fallback(String value) {
  return value.trim().isEmpty ? 'Not available' : value.trim();
}

String _string(dynamic value) => value?.toString() ?? '';

Map<String, dynamic> _toMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

List<dynamic> _toList(dynamic value) => value is List ? value : const [];

String _teamName(dynamic value, String fallback) {
  final map = _toMap(value);
  final name = _string(map['name']);
  return name.isEmpty ? fallback : name;
}
