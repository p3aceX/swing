import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../repositories/host_tournament_repository.dart';
import '../../../theme/host_colors.dart';
import '../../create_match/presentation/team_search_sheet.dart';

class TournamentDetailScreen extends ConsumerStatefulWidget {
  const TournamentDetailScreen({
    super.key,
    required this.tournamentId,
    this.initialData,
    this.repository,
    this.permissions = const TournamentPermissions(),
    this.isOwner = false,
    this.onBack,
  });

  final String tournamentId;
  final Map<String, dynamic>? initialData;
  final SharedTournamentRepository? repository;
  final TournamentPermissions permissions;
  final bool isOwner;
  final VoidCallback? onBack;

  @override
  ConsumerState<TournamentDetailScreen> createState() =>
      _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends ConsumerState<TournamentDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _manualTeamController;
  Map<String, dynamic>? _tournament;
  List<Map<String, dynamic>> _teams = const [];
  List<Map<String, dynamic>> _groups = const [];
  Map<String, List<Map<String, dynamic>>> _standings = const {};
  List<Map<String, dynamic>> _schedule = const [];
  bool _isLoading = true;
  bool _isBusy = false;
  String? _error;

  SharedTournamentRepository get _repository =>
      widget.repository ?? ref.read(hostTournamentRepositoryProvider);

  bool get _canManage => widget.permissions.canManage || widget.isOwner;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _manualTeamController = TextEditingController();
    _tournament = widget.initialData;
    _reload();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _manualTeamController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await Future.wait([
        _repository.getTournament(widget.tournamentId),
        _repository.listTeams(widget.tournamentId),
        _repository.listGroups(widget.tournamentId),
        _repository.getStandings(widget.tournamentId),
        _repository.getSchedule(widget.tournamentId),
      ]);
      if (!mounted) return;
      setState(() {
        _tournament = result[0] as Map<String, dynamic>;
        _teams = result[1] as List<Map<String, dynamic>>;
        _groups = result[2] as List<Map<String, dynamic>>;
        _standings = result[3] as Map<String, List<Map<String, dynamic>>>;
        _schedule = result[4] as List<Map<String, dynamic>>;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _runAction(Future<void> Function() action) async {
    setState(() {
      _isBusy = true;
      _error = null;
    });
    try {
      await action();
      await _reload();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _showAddTeamSheet() async {
    final selected = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const FractionallySizedBox(
        heightFactor: 0.84,
        child: TeamSearchSheet(title: 'Add Team to Tournament'),
      ),
    );
    if (selected == null) return;
    await _runAction(() async {
      await _repository.addTeam(
        widget.tournamentId,
        teamId: '${selected['id'] ?? ''}',
        teamName: '${selected['name'] ?? ''}',
      );
    });
  }

  Future<void> _showCreateGroupDialog() async {
    final controller = TextEditingController(text: 'Group A, Group B');
    var autoAssign = true;
    final result = await showDialog<(List<String>, bool)>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create groups'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Group names',
                      hintText: 'Group A, Group B',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: autoAssign,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) =>
                        setDialogState(() => autoAssign = value),
                    title: const Text('Auto-assign confirmed teams'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final groups = controller.text
                        .split(',')
                        .map((value) => value.trim())
                        .where((value) => value.isNotEmpty)
                        .toList();
                    if (groups.isEmpty) return;
                    Navigator.of(context).pop((groups, autoAssign));
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
    controller.dispose();
    if (result == null) return;
    await _runAction(() async {
      await _repository.createGroups(
        widget.tournamentId,
        groupNames: result.$1,
        autoAssign: result.$2,
      );
    });
  }

  Future<void> _showManualTeamDialog() async {
    _manualTeamController.clear();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add team manually'),
        content: TextField(
          controller: _manualTeamController,
          decoration: const InputDecoration(labelText: 'Team name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final name = _manualTeamController.text.trim();
    if (name.isEmpty) return;
    await _runAction(() async {
      await _repository.addTeam(widget.tournamentId, teamName: name);
    });
  }

  @override
  Widget build(BuildContext context) {
    final name =
        '${_tournament?['name'] ?? widget.initialData?['name'] ?? 'Tournament'}';
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Teams'),
            Tab(text: 'Groups'),
            Tab(text: 'Standings'),
            Tab(text: 'Schedule'),
          ],
        ),
      ),
      floatingActionButton: _canManage && _tabController.index == 1
          ? FloatingActionButton.extended(
              onPressed: _isBusy
                  ? null
                  : () async {
                      await showModalBottomSheet<void>(
                        context: context,
                        builder: (context) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.groups_outlined),
                                title: const Text('Add existing team'),
                                onTap: () async {
                                  Navigator.of(context).pop();
                                  await _showAddTeamSheet();
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.add_circle_outline),
                                title: const Text('Create team entry manually'),
                                onTap: () async {
                                  Navigator.of(context).pop();
                                  await _showManualTeamDialog();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
              label: const Text('Add team'),
              icon: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          if ((_error ?? '').isNotEmpty)
            Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.errorContainer,
              padding: const EdgeInsets.all(12),
              child: Text(
                _error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _OverviewTab(
                        tournament: _tournament ?? const {},
                        teams: _teams,
                        groups: _groups,
                        standings: _standings,
                        schedule: _schedule,
                        canManage: _canManage,
                        isBusy: _isBusy,
                        onCreateGroups: _showCreateGroupDialog,
                        onAutoGenerate: () => _runAction(
                          () => _repository
                              .autoGenerateSchedule(widget.tournamentId),
                        ),
                        onDeleteSchedule: () => _runAction(
                          () => _repository.deleteSchedule(widget.tournamentId),
                        ),
                        onRecalculate: () => _runAction(
                          () => _repository
                              .recalculateStandings(widget.tournamentId),
                        ),
                        onAdvanceRound: () => _runAction(
                          () => _repository.advanceRound(widget.tournamentId),
                        ),
                      ),
                      _TeamsTab(
                        teams: _teams,
                        groups: _groups,
                        canManage: _canManage,
                        isBusy: _isBusy,
                        onRefresh: _reload,
                        onRemove: (teamId) => _runAction(
                          () => _repository.removeTeam(
                              widget.tournamentId, teamId),
                        ),
                        onConfirm: (teamId, confirmed) => _runAction(
                          () => _repository.confirmTeam(
                            widget.tournamentId,
                            teamId,
                            confirmed,
                          ),
                        ),
                        onAssignGroup: (teamId, groupId) => _runAction(
                          () => _repository.assignTeamToGroup(
                            widget.tournamentId,
                            teamId,
                            groupId,
                          ),
                        ),
                      ),
                      _GroupsTab(
                        groups: _groups,
                        canManage: _canManage,
                        isBusy: _isBusy,
                        onCreateGroups: _showCreateGroupDialog,
                      ),
                      _StandingsTab(
                        standings: _standings,
                        canManage: _canManage,
                        isBusy: _isBusy,
                        onRecalculate: () => _runAction(
                          () => _repository
                              .recalculateStandings(widget.tournamentId),
                        ),
                      ),
                      _ScheduleTab(
                        schedule: _schedule,
                        canManage: _canManage,
                        isBusy: _isBusy,
                        onGenerate: () => _runAction(
                          () => _repository
                              .autoGenerateSchedule(widget.tournamentId),
                        ),
                        onDelete: () => _runAction(
                          () => _repository.deleteSchedule(widget.tournamentId),
                        ),
                        onAdvanceRound: () => _runAction(
                          () => _repository.advanceRound(widget.tournamentId),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class HostTournamentDetailScreen extends StatelessWidget {
  const HostTournamentDetailScreen({
    super.key,
    required this.tournamentId,
    this.initialData,
  });

  final String tournamentId;
  final Map<String, dynamic>? initialData;

  @override
  Widget build(BuildContext context) {
    return TournamentDetailScreen(
      tournamentId: tournamentId,
      initialData: initialData,
      permissions: const TournamentPermissions.host(),
      isOwner: true,
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.tournament,
    required this.teams,
    required this.groups,
    required this.standings,
    required this.schedule,
    required this.canManage,
    required this.isBusy,
    required this.onCreateGroups,
    required this.onAutoGenerate,
    required this.onDeleteSchedule,
    required this.onRecalculate,
    required this.onAdvanceRound,
  });

  final Map<String, dynamic> tournament;
  final List<Map<String, dynamic>> teams;
  final List<Map<String, dynamic>> groups;
  final Map<String, List<Map<String, dynamic>>> standings;
  final List<Map<String, dynamic>> schedule;
  final bool canManage;
  final bool isBusy;
  final Future<void> Function() onCreateGroups;
  final Future<void> Function() onAutoGenerate;
  final Future<void> Function() onDeleteSchedule;
  final Future<void> Function() onRecalculate;
  final Future<void> Function() onAdvanceRound;

  @override
  Widget build(BuildContext context) {
    final location = [
      '${tournament['city'] ?? ''}'.trim(),
      '${tournament['venueName'] ?? ''}'.trim(),
    ].where((value) => value.isNotEmpty).join(' • ');
    final stats = [
      ('Status', '${tournament['status'] ?? 'UPCOMING'}'),
      ('Format', '${tournament['format'] ?? 'T20'}'),
      ('Tournament', '${tournament['tournamentFormat'] ?? 'LEAGUE'}'),
      ('Teams', '${teams.length}/${tournament['maxTeams'] ?? '-'}'),
      (
        'Confirmed',
        '${teams.where((team) => team['isConfirmed'] == true).length}'
      ),
      ('Fixtures', '${schedule.length}'),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${tournament['name'] ?? 'Tournament'}',
                style: TextStyle(
                  color: context.fg,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                location.ifEmpty('Venue details not set'),
                style: TextStyle(color: context.fgSub),
              ),
              const SizedBox(height: 8),
              Text(
                'Start: ${_formatDate(tournament['startDate'])}',
                style: TextStyle(color: context.fgSub),
              ),
              if (tournament['endDate'] != null)
                Text(
                  'End: ${_formatDate(tournament['endDate'])}',
                  style: TextStyle(color: context.fgSub),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: stats
              .map(
                (item) => SizedBox(
                  width: 164,
                  child: _MetricCard(label: item.$1, value: item.$2),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Summary',
                style: TextStyle(
                  color: context.fg,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              _SummaryRow(label: 'Groups', value: '${groups.length}'),
              _SummaryRow(
                  label: 'Standings buckets', value: '${standings.length}'),
              _SummaryRow(
                label: 'Next fixture',
                value: schedule.isEmpty
                    ? 'Not generated'
                    : '${schedule.first['teamAName'] ?? 'TBD'} vs ${schedule.first['teamBName'] ?? 'TBD'}',
              ),
            ],
          ),
        ),
        if (canManage) ...[
          const SizedBox(height: 12),
          _Panel(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: isBusy ? null : onCreateGroups,
                  icon: const Icon(Icons.group_work_outlined),
                  label: const Text('Create groups'),
                ),
                FilledButton.icon(
                  onPressed: isBusy ? null : onAutoGenerate,
                  icon: const Icon(Icons.event_repeat),
                  label: const Text('Auto generate'),
                ),
                OutlinedButton.icon(
                  onPressed: isBusy ? null : onRecalculate,
                  icon: const Icon(Icons.calculate_outlined),
                  label: const Text('Recalculate'),
                ),
                OutlinedButton.icon(
                  onPressed: isBusy ? null : onAdvanceRound,
                  icon: const Icon(Icons.skip_next_outlined),
                  label: const Text('Advance round'),
                ),
                OutlinedButton.icon(
                  onPressed:
                      isBusy || schedule.isEmpty ? null : onDeleteSchedule,
                  icon: const Icon(Icons.delete_sweep_outlined),
                  label: const Text('Delete schedule'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TeamsTab extends StatelessWidget {
  const _TeamsTab({
    required this.teams,
    required this.groups,
    required this.canManage,
    required this.isBusy,
    required this.onRefresh,
    required this.onRemove,
    required this.onConfirm,
    required this.onAssignGroup,
  });

  final List<Map<String, dynamic>> teams;
  final List<Map<String, dynamic>> groups;
  final bool canManage;
  final bool isBusy;
  final Future<void> Function() onRefresh;
  final Future<void> Function(String teamId) onRemove;
  final Future<void> Function(String teamId, bool confirmed) onConfirm;
  final Future<void> Function(String teamId, String? groupId) onAssignGroup;

  @override
  Widget build(BuildContext context) {
    if (teams.isEmpty) {
      return _EmptyPane(
        message: 'No teams registered yet.',
        actionLabel: 'Refresh',
        onAction: onRefresh,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: teams.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final team = teams[index];
        final groupId = '${team['groupId'] ?? ''}'.trim();
        return _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${team['teamName'] ?? 'Unnamed Team'}',
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _StatusChip(
                    label:
                        team['isConfirmed'] == true ? 'Confirmed' : 'Pending',
                    color: team['isConfirmed'] == true
                        ? Colors.green
                        : Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(label: 'Seed ${team['seed'] ?? '-'}'),
                  _InfoChip(
                      label:
                          'Players ${((team['playerIds'] as List?) ?? const []).length}'),
                  _InfoChip(
                      label: 'Registered ${_formatDate(team['registeredAt'])}'),
                ],
              ),
              if (canManage) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        initialValue: groupId.isEmpty ? null : groupId,
                        decoration: const InputDecoration(labelText: 'Group'),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('No group'),
                          ),
                          ...groups.map(
                            (group) => DropdownMenuItem<String?>(
                              value: '${group['id'] ?? ''}',
                              child: Text('${group['name'] ?? 'Group'}'),
                            ),
                          ),
                        ],
                        onChanged: isBusy
                            ? null
                            : (value) =>
                                onAssignGroup('${team['id'] ?? ''}', value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Switch(
                      value: team['isConfirmed'] == true,
                      onChanged: isBusy
                          ? null
                          : (value) => onConfirm('${team['id'] ?? ''}', value),
                    ),
                    IconButton(
                      onPressed:
                          isBusy ? null : () => onRemove('${team['id'] ?? ''}'),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _GroupsTab extends StatelessWidget {
  const _GroupsTab({
    required this.groups,
    required this.canManage,
    required this.isBusy,
    required this.onCreateGroups,
  });

  final List<Map<String, dynamic>> groups;
  final bool canManage;
  final bool isBusy;
  final Future<void> Function() onCreateGroups;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return _EmptyPane(
        message: 'No groups created yet.',
        actionLabel: canManage ? 'Create groups' : null,
        onAction: canManage ? onCreateGroups : null,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final group = groups[index];
        final teams =
            (group['teams'] as List?)?.whereType<Map>().toList() ?? const [];
        return _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${group['name'] ?? 'Group'}',
                    style: TextStyle(
                      color: context.fg,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  _InfoChip(label: '${teams.length} teams'),
                ],
              ),
              const SizedBox(height: 10),
              if (teams.isEmpty)
                Text(
                  'No teams assigned.',
                  style: TextStyle(color: context.fgSub),
                )
              else
                ...teams.map(
                  (team) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${team['teamName'] ?? 'Team'}',
                            style: TextStyle(color: context.fg),
                          ),
                        ),
                        _StatusChip(
                          label: team['isConfirmed'] == true
                              ? 'Confirmed'
                              : 'Pending',
                          color: team['isConfirmed'] == true
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ),
              if (canManage) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: isBusy ? null : onCreateGroups,
                    child: const Text('Regenerate groups'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _StandingsTab extends StatelessWidget {
  const _StandingsTab({
    required this.standings,
    required this.canManage,
    required this.isBusy,
    required this.onRecalculate,
  });

  final Map<String, List<Map<String, dynamic>>> standings;
  final bool canManage;
  final bool isBusy;
  final Future<void> Function() onRecalculate;

  @override
  Widget build(BuildContext context) {
    if (standings.isEmpty) {
      return _EmptyPane(
        message: 'No standings available yet.',
        actionLabel: canManage ? 'Recalculate' : null,
        onAction: canManage ? onRecalculate : null,
      );
    }
    final buckets = standings.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: buckets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final bucket = buckets[index];
        return _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    bucket.key == 'overall' ? 'Overall' : 'Group ${bucket.key}',
                    style: TextStyle(
                      color: context.fg,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  if (canManage)
                    OutlinedButton(
                      onPressed: isBusy ? null : onRecalculate,
                      child: const Text('Recalculate'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ...bucket.value.map(
                (row) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${(row['team'] as Map?)?['teamName'] ?? row['teamName'] ?? 'Team'}',
                          style: TextStyle(
                            color: context.fg,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 44,
                        child: Text('P ${row['played'] ?? 0}'),
                      ),
                      SizedBox(
                        width: 44,
                        child: Text('W ${row['won'] ?? 0}'),
                      ),
                      SizedBox(
                        width: 56,
                        child: Text('Pts ${row['points'] ?? 0}'),
                      ),
                      SizedBox(
                        width: 72,
                        child: Text(
                          'NRR ${_nrr(row['nrr'])}',
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  const _ScheduleTab({
    required this.schedule,
    required this.canManage,
    required this.isBusy,
    required this.onGenerate,
    required this.onDelete,
    required this.onAdvanceRound,
  });

  final List<Map<String, dynamic>> schedule;
  final bool canManage;
  final bool isBusy;
  final Future<void> Function() onGenerate;
  final Future<void> Function() onDelete;
  final Future<void> Function() onAdvanceRound;

  @override
  Widget build(BuildContext context) {
    final scheduleRows = schedule
        .map(
          (match) => (
            match: match,
            innings: (match['innings'] as List?)?.whereType<Map>().toList() ??
                const <Map<dynamic, dynamic>>[],
          ),
        )
        .toList();
    if (schedule.isEmpty) {
      return _EmptyPane(
        message: 'No fixtures generated yet.',
        actionLabel: canManage ? 'Generate schedule' : null,
        onAction: canManage ? onGenerate : null,
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (canManage)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: isBusy ? null : onGenerate,
                icon: const Icon(Icons.event_repeat),
                label: const Text('Regenerate'),
              ),
              OutlinedButton.icon(
                onPressed: isBusy ? null : onAdvanceRound,
                icon: const Icon(Icons.skip_next_outlined),
                label: const Text('Advance round'),
              ),
              OutlinedButton.icon(
                onPressed: isBusy ? null : onDelete,
                icon: const Icon(Icons.delete_sweep_outlined),
                label: const Text('Delete schedule'),
              ),
            ],
          ),
        if (canManage) const SizedBox(height: 12),
        ...scheduleRows.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${entry.match['teamAName'] ?? 'TBD'} vs ${entry.match['teamBName'] ?? 'TBD'}',
                          style: TextStyle(
                            color: context.fg,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      _StatusChip(
                        label: '${entry.match['status'] ?? 'SCHEDULED'}',
                        color:
                            _matchStatusColor('${entry.match['status'] ?? ''}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDateTime(entry.match['scheduledAt']),
                    style: TextStyle(color: context.fgSub),
                  ),
                  if ((entry.match['venueName'] ?? '')
                      .toString()
                      .trim()
                      .isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${entry.match['venueName']}',
                        style: TextStyle(color: context.fgSub),
                      ),
                    ),
                  if (entry.innings.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...entry.innings.map(
                      (inningsRow) => Text(
                        'Innings ${inningsRow['inningsNumber']}: ${inningsRow['totalRuns'] ?? 0}/${inningsRow['totalWickets'] ?? 0} in ${inningsRow['totalOvers'] ?? 0}',
                        style: TextStyle(color: context.fgSub),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.stroke),
      ),
      child: child,
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: context.fgSub, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: context.fg,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: context.fgSub))),
          Text(value,
              style: TextStyle(color: context.fg, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.stroke),
      ),
      child: Text(label, style: TextStyle(color: context.fgSub, fontSize: 12)),
    );
  }
}

class _EmptyPane extends StatelessWidget {
  const _EmptyPane({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final Future<void> Function()? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.fgSub),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 12),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _formatDate(Object? value) {
  final parsed = DateTime.tryParse('${value ?? ''}');
  if (parsed == null) return '-';
  return DateFormat('dd MMM yyyy').format(parsed.toLocal());
}

String _formatDateTime(Object? value) {
  final parsed = DateTime.tryParse('${value ?? ''}');
  if (parsed == null) return 'Unscheduled';
  return DateFormat('dd MMM yyyy, hh:mm a').format(parsed.toLocal());
}

String _nrr(Object? value) {
  final parsed = double.tryParse('${value ?? 0}') ?? 0;
  return parsed >= 0
      ? '+${parsed.toStringAsFixed(3)}'
      : parsed.toStringAsFixed(3);
}

Color _matchStatusColor(String status) {
  switch (status) {
    case 'COMPLETED':
      return Colors.green;
    case 'IN_PROGRESS':
      return Colors.red;
    case 'TOSS_DONE':
      return Colors.blue;
    default:
      return Colors.orange;
  }
}

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}
