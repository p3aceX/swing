import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/admin_detail_widgets.dart';
import '../data/tournaments_repository.dart';

enum _TournamentTab {
  overview('Overview'),
  teams('Teams'),
  groups('Groups'),
  standings('Standings'),
  fixtures('Fixtures');

  const _TournamentTab(this.label);
  final String label;
}

class TournamentDetailScreen extends ConsumerStatefulWidget {
  const TournamentDetailScreen({super.key, required this.tournamentId});

  final String tournamentId;

  @override
  ConsumerState<TournamentDetailScreen> createState() =>
      _TournamentDetailScreenState();
}

class _TournamentDetailScreenState
    extends ConsumerState<TournamentDetailScreen> {
  _TournamentTab _tab = _TournamentTab.overview;

  Future<void> _deleteTournament() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete tournament'),
        content: const Text(
          'This removes the tournament, its schedule, standings, teams, and linked matches. This cannot be undone.',
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ref.read(tournamentsRepositoryProvider).delete(widget.tournamentId);
      ref.invalidate(tournamentsSummaryProvider);
      ref.invalidate(tournamentsTrendItemsProvider);
      ref.invalidate(tournamentDetailProvider(widget.tournamentId));
      ref.invalidate(tournamentTeamsProvider(widget.tournamentId));
      ref.invalidate(tournamentGroupsProvider(widget.tournamentId));
      ref.invalidate(tournamentStandingsProvider(widget.tournamentId));
      ref.invalidate(tournamentScheduleProvider(widget.tournamentId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tournament deleted')),
        );
        context.go('/tournaments');
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
    final detailAsync = ref.watch(tournamentDetailProvider(widget.tournamentId));
    final teamsAsync = ref.watch(tournamentTeamsProvider(widget.tournamentId));
    final groupsAsync = ref.watch(tournamentGroupsProvider(widget.tournamentId));
    final standingsAsync =
        ref.watch(tournamentStandingsProvider(widget.tournamentId));
    final scheduleAsync =
        ref.watch(tournamentScheduleProvider(widget.tournamentId));

    return Scaffold(
      appBar: compact
          ? null
          : AppBar(
              leading: IconButton(
                onPressed: () => context.go('/tournaments'),
                icon: const Icon(Icons.arrow_back),
              ),
              title: const Text('Tournament workspace'),
              actions: [
                IconButton(
                  onPressed: _deleteTournament,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete tournament',
                ),
                const SizedBox(width: 8),
              ],
            ),
      body: SafeArea(
        top: false,
        child: detailAsync.when(
          data: (detail) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              if (compact) ...[
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go('/tournaments'),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Text(
                        'Tournament workspace',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _deleteTournament,
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              _TournamentHero(detail: detail),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final item in _TournamentTab.values) ...[
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
                detail: detail,
                teamsAsync: teamsAsync,
                groupsAsync: groupsAsync,
                standingsAsync: standingsAsync,
                scheduleAsync: scheduleAsync,
              ),
            ],
          ),
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
                style: const TextStyle(fontSize: 13, color: AppColors.danger),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBody({
    required Map<String, dynamic> detail,
    required AsyncValue<List<dynamic>> teamsAsync,
    required AsyncValue<List<dynamic>> groupsAsync,
    required AsyncValue<Map<String, dynamic>> standingsAsync,
    required AsyncValue<List<dynamic>> scheduleAsync,
  }) {
    switch (_tab) {
      case _TournamentTab.overview:
        return _TournamentOverviewTab(detail: detail);
      case _TournamentTab.teams:
        return _TeamsTab(async: teamsAsync);
      case _TournamentTab.groups:
        return _GroupsTab(async: groupsAsync);
      case _TournamentTab.standings:
        return _StandingsTab(async: standingsAsync);
      case _TournamentTab.fixtures:
        return _FixturesTab(async: scheduleAsync);
    }
  }
}

class _TournamentHero extends StatelessWidget {
  const _TournamentHero({required this.detail});

  final Map<String, dynamic> detail;

  @override
  Widget build(BuildContext context) {
    final title = _string(detail['name']).isEmpty
        ? 'Untitled tournament'
        : _string(detail['name']);
    final startDate = _parseDate(detail['startDate']);
    final endDate = _parseDate(detail['endDate']);
    return AdminSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _dateRange(startDate, endDate),
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
              AdminInfoPill(label: _pretty(_string(detail['status']))),
              if (_string(detail['format']).isNotEmpty)
                AdminInfoPill(label: _pretty(_string(detail['format']))),
              if (_string(detail['tournamentFormat']).isNotEmpty)
                AdminInfoPill(
                    label: _pretty(_string(detail['tournamentFormat']))),
              if (_string(detail['venueName']).isNotEmpty)
                AdminInfoPill(label: _string(detail['venueName'])),
              if (_string(detail['city']).isNotEmpty)
                AdminInfoPill(label: _string(detail['city'])),
            ],
          ),
        ],
      ),
    );
  }
}

class _TournamentOverviewTab extends StatelessWidget {
  const _TournamentOverviewTab({required this.detail});

  final Map<String, dynamic> detail;

  @override
  Widget build(BuildContext context) {
    final teams = _toList(detail['teams']);
    final groups = _toList(detail['groups']);
    final overview = AdminKeyValueCard(
      title: 'Tournament info',
      rows: [
        AdminKeyValueRowData('Status', _pretty(_string(detail['status']))),
        AdminKeyValueRowData('Format', _pretty(_string(detail['format']))),
        AdminKeyValueRowData(
            'Tournament type', _pretty(_string(detail['tournamentFormat']))),
        AdminKeyValueRowData('Venue', _fallback(_string(detail['venueName']))),
        AdminKeyValueRowData('City', _fallback(_string(detail['city']))),
        AdminKeyValueRowData(
            'Teams', '${teams.length}/${_int(detail['maxTeams']) == 0 ? 'NA' : _int(detail['maxTeams'])}'),
      ],
    );
    final config = AdminKeyValueCard(
      title: 'Competition config',
      rows: [
        AdminKeyValueRowData('Points for win', '${_int(detail['pointsForWin'])}'),
        AdminKeyValueRowData('Points for loss', '${_int(detail['pointsForLoss'])}'),
        AdminKeyValueRowData('Points for tie', '${_int(detail['pointsForTie'])}'),
        AdminKeyValueRowData(
            'Points for no result', '${_int(detail['pointsForNoResult'])}'),
        AdminKeyValueRowData('Groups', '${groups.length}'),
        AdminKeyValueRowData(
            'Series matches', _nullableInt(detail['seriesMatchCount']) ?? 'Not set'),
      ],
    );
    final meta = AdminKeyValueCard(
      title: 'Public / media',
      rows: [
        AdminKeyValueRowData(
            'Verified', detail['isVerified'] == true ? 'Yes' : 'No'),
        AdminKeyValueRowData('Public', detail['isPublic'] == true ? 'Yes' : 'No'),
        AdminKeyValueRowData('Slug', _fallback(_string(detail['slug']))),
        AdminKeyValueRowData(
            'Logo URL', _fallback(_string(detail['logoUrl']))),
        AdminKeyValueRowData(
            'Cover URL', _fallback(_string(detail['coverUrl']))),
        AdminKeyValueRowData('Prize pool', _fallback(_string(detail['prizePool']))),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 860;
        if (stacked) {
          return Column(
            children: [
              overview,
              const SizedBox(height: 12),
              config,
              const SizedBox(height: 12),
              meta,
            ],
          );
        }
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: overview),
                const SizedBox(width: 12),
                Expanded(child: config),
              ],
            ),
            const SizedBox(height: 12),
            meta,
          ],
        );
      },
    );
  }
}

class _TeamsTab extends StatelessWidget {
  const _TeamsTab({required this.async});

  final AsyncValue<List<dynamic>> async;

  @override
  Widget build(BuildContext context) {
    return async.when(
      data: (items) => AdminSurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminSectionHeader(
              title: 'Registered teams',
              subtitle:
                  '${items.length} team${items.length == 1 ? '' : 's'} in the tournament pool.',
            ),
            const SizedBox(height: 14),
            if (items.isEmpty)
              const Text(
                'No teams registered yet.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              )
            else
              for (var index = 0; index < items.length; index++) ...[
                _TeamTile(team: _toMap(items[index])),
                if (index < items.length - 1) const Divider(height: 16),
              ],
          ],
        ),
      ),
      loading: () => const _AsyncCardLoader(),
      error: (error, _) => _AsyncCardError(message: error.toString()),
    );
  }
}

class _TeamTile extends StatelessWidget {
  const _TeamTile({required this.team});

  final Map<String, dynamic> team;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _fallback(_string(team['teamName'])),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            AdminInfoPill(
              label: team['isConfirmed'] == true ? 'Confirmed' : 'Pending',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (_string(team['groupId']).isNotEmpty)
              AdminInfoPill(label: 'Grouped'),
            if (_string(team['teamId']).isNotEmpty)
              AdminInfoPill(label: 'Linked team'),
            if (_string(team['captainId']).isNotEmpty)
              AdminInfoPill(label: 'Captain set'),
            AdminInfoPill(
                label:
                    '${_toList(team['playerIds']).length} player${_toList(team['playerIds']).length == 1 ? '' : 's'}'),
          ],
        ),
      ],
    );
  }
}

class _GroupsTab extends StatelessWidget {
  const _GroupsTab({required this.async});

  final AsyncValue<List<dynamic>> async;

  @override
  Widget build(BuildContext context) {
    return async.when(
      data: (items) => Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            _GroupCard(group: _toMap(items[index])),
            if (index < items.length - 1) const SizedBox(height: 12),
          ],
          if (items.isEmpty)
            const _AsyncCardError(message: 'No groups created yet.'),
        ],
      ),
      loading: () => const _AsyncCardLoader(),
      error: (error, _) => _AsyncCardError(message: error.toString()),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group});

  final Map<String, dynamic> group;

  @override
  Widget build(BuildContext context) {
    final teams = _toList(group['teams']);
    return AdminSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminSectionHeader(
            title: _fallback(_string(group['name'])),
            subtitle:
                '${teams.length} team${teams.length == 1 ? '' : 's'} assigned',
          ),
          const SizedBox(height: 12),
          if (teams.isEmpty)
            const Text(
              'No teams assigned yet.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            )
          else
            for (var index = 0; index < teams.length; index++) ...[
              _GroupTeamRow(team: _toMap(teams[index])),
              if (index < teams.length - 1) const Divider(height: 16),
            ],
        ],
      ),
    );
  }
}

class _GroupTeamRow extends StatelessWidget {
  const _GroupTeamRow({required this.team});

  final Map<String, dynamic> team;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            _fallback(_string(team['teamName'])),
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (_nullableInt(team['seed']) != null)
          AdminInfoPill(label: 'Seed ${_nullableInt(team['seed'])}'),
        const SizedBox(width: 8),
        AdminInfoPill(
          label: team['isConfirmed'] == true ? 'Confirmed' : 'Pending',
        ),
      ],
    );
  }
}

class _StandingsTab extends StatelessWidget {
  const _StandingsTab({required this.async});

  final AsyncValue<Map<String, dynamic>> async;

  @override
  Widget build(BuildContext context) {
    return async.when(
      data: (groups) {
        final entries = groups.entries.toList();
        if (entries.isEmpty) {
          return const _AsyncCardError(message: 'No standings available yet.');
        }
        return Column(
          children: [
            for (var index = 0; index < entries.length; index++) ...[
              _StandingGroupCard(
                title: entries[index].key == 'overall'
                    ? 'Overall'
                    : entries[index].key,
                rows: _toList(entries[index].value),
              ),
              if (index < entries.length - 1) const SizedBox(height: 12),
            ],
          ],
        );
      },
      loading: () => const _AsyncCardLoader(),
      error: (error, _) => _AsyncCardError(message: error.toString()),
    );
  }
}

class _StandingGroupCard extends StatelessWidget {
  const _StandingGroupCard({
    required this.title,
    required this.rows,
  });

  final String title;
  final List<dynamic> rows;

  @override
  Widget build(BuildContext context) {
    return AdminSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminSectionHeader(title: title, subtitle: 'Points table and NRR'),
          const SizedBox(height: 12),
          for (var index = 0; index < rows.length; index++) ...[
            _StandingRow(row: _toMap(rows[index])),
            if (index < rows.length - 1) const Divider(height: 16),
          ],
        ],
      ),
    );
  }
}

class _StandingRow extends StatelessWidget {
  const _StandingRow({required this.row});

  final Map<String, dynamic> row;

  @override
  Widget build(BuildContext context) {
    final team = _toMap(row['team']);
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            _fallback(_string(team['teamName'])),
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(child: _miniStat('P', '${_int(row['played'])}')),
        Expanded(child: _miniStat('W', '${_int(row['won'])}')),
        Expanded(child: _miniStat('L', '${_int(row['lost'])}')),
        Expanded(child: _miniStat('Pts', '${_int(row['points'])}')),
        Expanded(
          flex: 2,
          child: _miniStat('NRR', (_double(row['nrr'])).toStringAsFixed(3)),
        ),
      ],
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _FixturesTab extends StatelessWidget {
  const _FixturesTab({required this.async});

  final AsyncValue<List<dynamic>> async;

  @override
  Widget build(BuildContext context) {
    return async.when(
      data: (items) => AdminSurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminSectionHeader(
              title: 'Fixtures',
              subtitle:
                  '${items.length} scheduled match${items.length == 1 ? '' : 'es'} for this tournament.',
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const Text(
                'No fixtures generated yet.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              )
            else
              for (var index = 0; index < items.length; index++) ...[
                _FixtureTile(match: _toMap(items[index])),
                if (index < items.length - 1) const Divider(height: 16),
              ],
          ],
        ),
      ),
      loading: () => const _AsyncCardLoader(),
      error: (error, _) => _AsyncCardError(message: error.toString()),
    );
  }
}

class _FixtureTile extends StatelessWidget {
  const _FixtureTile({required this.match});

  final Map<String, dynamic> match;

  @override
  Widget build(BuildContext context) {
    final innings = _toList(match['innings']);
    final score = innings
        .map((entry) {
          final inningsMap = _toMap(entry);
          return 'I${_int(inningsMap['inningsNumber'])} ${_int(inningsMap['totalRuns'])}/${_int(inningsMap['totalWickets'])}';
        })
        .join(' • ');
    return InkWell(
      onTap: () {
        final id = _string(match['id']);
        if (id.isNotEmpty) context.go('/matches/$id');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_fallback(_string(match['teamAName']))} vs ${_fallback(_string(match['teamBName']))}',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              AdminInfoPill(label: _pretty(_string(match['status']))),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _parseDate(match['scheduledAt']) == null
                ? 'Time pending'
                : DateFormat('dd MMM yyyy, h:mm a')
                    .format(_parseDate(match['scheduledAt'])!.toLocal()),
            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
          if (score.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              score,
              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
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

String _string(dynamic value) => value?.toString() ?? '';
Map<String, dynamic> _toMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
List<dynamic> _toList(dynamic value) => value is List ? value : const [];
int _int(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _double(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

String? _nullableInt(dynamic value) {
  if (value == null) return null;
  return _int(value).toString();
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

DateTime? _parseDate(dynamic value) {
  final raw = _string(value);
  if (raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}

String _dateRange(DateTime? start, DateTime? end) {
  if (start == null && end == null) return 'Dates pending';
  final startLabel =
      start == null ? 'TBD' : DateFormat('dd MMM yyyy').format(start.toLocal());
  final endLabel =
      end == null ? 'TBD' : DateFormat('dd MMM yyyy').format(end.toLocal());
  return '$startLabel - $endLabel';
}
