import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../repositories/host_tournament_repository.dart';
import '../../../theme/host_colors.dart';
import '../../create_match/presentation/team_search_sheet.dart';

// ---------------------------------------------------------------------------
// Public entry points
// ---------------------------------------------------------------------------

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
    _tabController = TabController(length: 3, vsync: this);
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

  // ── Data loading ──────────────────────────────────────────────────────────

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

  // ── Dialogs / sheets ──────────────────────────────────────────────────────

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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final appBarTitle =
        _canManage ? 'Manage Tournament' : '${_tournament?['name'] ?? widget.initialData?['name'] ?? 'Tournament'}';

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: context.fg),
          onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          appBarTitle,
          style: TextStyle(
            color: context.fg,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: ColoredBox(
            color: context.bg,
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              indicatorColor: context.accent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 2,
              labelColor: context.accent,
              unselectedLabelColor: context.fgSub,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              dividerColor: context.stroke,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Teams'),
                Tab(text: 'Groups'),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _canManage && _tabController.index == 1
          ? FloatingActionButton.extended(
              backgroundColor: context.accent,
              foregroundColor: context.bg,
              onPressed: _isBusy
                  ? null
                  : () async {
                      await showModalBottomSheet<void>(
                        context: context,
                        backgroundColor: context.panel,
                        builder: (context) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(Icons.groups_outlined,
                                    color: context.fg),
                                title: Text('Add existing team',
                                    style: TextStyle(color: context.fg)),
                                onTap: () async {
                                  Navigator.of(context).pop();
                                  await _showAddTeamSheet();
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.add_circle_outline,
                                    color: context.fg),
                                title: Text('Create team entry manually',
                                    style: TextStyle(color: context.fg)),
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
            ColoredBox(
              color: context.danger.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded,
                        color: context.danger, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: context.danger, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: context.accent))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _OverviewTab(
                        tournament: _tournament ?? const {},
                        teams: _teams,
                        groups: _groups,
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

// ---------------------------------------------------------------------------
// Overview tab
// ---------------------------------------------------------------------------

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.tournament,
    required this.teams,
    required this.groups,
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
    final name = '${tournament['name'] ?? 'Tournament'}';
    final status = '${tournament['status'] ?? 'UPCOMING'}';
    final location = [
      '${tournament['city'] ?? ''}'.trim(),
      '${tournament['venueName'] ?? ''}'.trim(),
    ].where((v) => v.isNotEmpty).join(' • ');

    final startDate = _formatDate(tournament['startDate']);
    final endDate = tournament['endDate'] != null
        ? _formatDate(tournament['endDate'])
        : null;
    final dateRange =
        endDate != null ? '$startDate – $endDate' : startDate;

    final confirmed =
        teams.where((t) => t['isConfirmed'] == true).length;
    final maxTeams = tournament['maxTeams'];
    final format = '${tournament['format'] ?? 'T20'}';
    final structure = '${tournament['tournamentFormat'] ?? 'LEAGUE'}';

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // ── Header ────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _StatusPill(status: status),
                ],
              ),
              const SizedBox(height: 12),
              if (location.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.place_outlined,
                        size: 15, color: context.fgSub),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(location,
                          style: TextStyle(
                              color: context.fgSub, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 15, color: context.fgSub),
                  const SizedBox(width: 6),
                  Text(dateRange,
                      style:
                          TextStyle(color: context.fgSub, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Stats row ─────────────────────────────────────────────────────
        SizedBox(
          height: 68,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _StatChip(
                label: 'Teams',
                value: maxTeams != null
                    ? '${teams.length}/$maxTeams'
                    : '${teams.length}',
              ),
              const SizedBox(width: 8),
              _StatChip(label: 'Confirmed', value: '$confirmed'),
              const SizedBox(width: 8),
              _StatChip(label: 'Format', value: format),
              const SizedBox(width: 8),
              _StatChip(label: 'Structure', value: structure),
            ],
          ),
        ),

        // ── Divider ───────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Divider(height: 1, color: context.stroke),
        ),

        // ── Summary rows ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _SummaryInfoRow(
                icon: Icons.group_work_outlined,
                label: 'Groups',
                value: '${groups.length}',
              ),
              const SizedBox(height: 8),
              _SummaryInfoRow(
                icon: Icons.event_note_outlined,
                label: 'Fixtures',
                value: schedule.isEmpty ? 'Not generated' : '${schedule.length}',
              ),
              if (schedule.isNotEmpty) ...[
                const SizedBox(height: 8),
                _SummaryInfoRow(
                  icon: Icons.sports_cricket_outlined,
                  label: 'Next match',
                  value:
                      '${schedule.first['teamAName'] ?? 'TBD'} vs ${schedule.first['teamBName'] ?? 'TBD'}',
                ),
              ],
            ],
          ),
        ),

        // ── Management actions ────────────────────────────────────────────
        if (canManage) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Divider(height: 1, color: context.stroke),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Actions',
              style: TextStyle(
                color: context.fgSub,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
          ),
          _ActionBtn(
            icon: Icons.group_work_outlined,
            label: 'Create groups',
            onTap: isBusy ? null : onCreateGroups,
          ),
          _ActionBtn(
            icon: Icons.event_repeat_outlined,
            label: 'Auto generate schedule',
            onTap: isBusy ? null : onAutoGenerate,
          ),
          _ActionBtn(
            icon: Icons.calculate_outlined,
            label: 'Recalculate standings',
            onTap: isBusy ? null : onRecalculate,
          ),
          _ActionBtn(
            icon: Icons.skip_next_outlined,
            label: 'Advance round',
            onTap: isBusy ? null : onAdvanceRound,
          ),
          _ActionBtn(
            icon: Icons.delete_sweep_outlined,
            label: 'Delete schedule',
            onTap: isBusy || schedule.isEmpty ? null : onDeleteSchedule,
            destructive: true,
          ),
          const SizedBox(height: 24),
        ] else
          const SizedBox(height: 24),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Teams tab
// ---------------------------------------------------------------------------

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
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: teams.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, indent: 64, color: context.stroke),
      itemBuilder: (context, index) {
        final team = teams[index];
        final teamName = '${team['teamName'] ?? 'Unnamed Team'}';
        final isConfirmed = team['isConfirmed'] == true;
        final groupId = '${team['groupId'] ?? ''}'.trim();

        // Find group name
        String? groupName;
        if (groupId.isNotEmpty) {
          final match = groups.where((g) => '${g['id']}' == groupId).toList();
          if (match.isNotEmpty) {
            groupName = '${match.first['name'] ?? groupId}';
          }
        }

        return InkWell(
          onTap: canManage
              ? () => _showTeamOptions(
                    context,
                    team: team,
                    isConfirmed: isConfirmed,
                  )
              : null,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _TeamAvatar(name: teamName),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teamName,
                        style: TextStyle(
                          color: context.fg,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: isConfirmed
                                  ? context.success
                                  : context.warn,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isConfirmed ? 'Confirmed' : 'Pending',
                            style: TextStyle(
                              color: context.fgSub,
                              fontSize: 12,
                            ),
                          ),
                          if (groupName != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: context.accentBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                groupName,
                                style: TextStyle(
                                  color: context.accent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (canManage)
                  Icon(Icons.more_horiz_rounded,
                      color: context.fgSub, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTeamOptions(
    BuildContext context, {
    required Map<String, dynamic> team,
    required bool isConfirmed,
  }) {
    final teamId = '${team['id'] ?? ''}';
    final groupId = '${team['groupId'] ?? ''}'.trim();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '${team['teamName'] ?? 'Team'}',
                style: TextStyle(
                  color: context.fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            Divider(height: 1, color: context.stroke),
            ListTile(
              leading: Icon(
                isConfirmed
                    ? Icons.check_circle_outline
                    : Icons.check_circle_rounded,
                color: isConfirmed ? context.fgSub : context.success,
              ),
              title: Text(
                isConfirmed ? 'Unconfirm' : 'Confirm',
                style: TextStyle(color: context.fg),
              ),
              onTap: isBusy
                  ? null
                  : () {
                      Navigator.of(ctx).pop();
                      onConfirm(teamId, !isConfirmed);
                    },
            ),
            if (groups.isNotEmpty)
              ListTile(
                leading:
                    Icon(Icons.group_work_outlined, color: context.fgSub),
                title: Text('Assign group',
                    style: TextStyle(color: context.fg)),
                onTap: isBusy
                    ? null
                    : () {
                        Navigator.of(ctx).pop();
                        _showAssignGroupSheet(context,
                            teamId: teamId, currentGroupId: groupId);
                      },
              ),
            ListTile(
              leading: Icon(Icons.person_remove_outlined,
                  color: context.danger),
              title:
                  Text('Remove', style: TextStyle(color: context.danger)),
              onTap: isBusy
                  ? null
                  : () {
                      Navigator.of(ctx).pop();
                      onRemove(teamId);
                    },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showAssignGroupSheet(
    BuildContext context, {
    required String teamId,
    required String currentGroupId,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Assign to group',
                style: TextStyle(
                  color: context.fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            Divider(height: 1, color: context.stroke),
            ListTile(
              title: Text('No group',
                  style: TextStyle(color: context.fgSub)),
              trailing: currentGroupId.isEmpty
                  ? Icon(Icons.check_rounded, color: context.accent)
                  : null,
              onTap: () {
                Navigator.of(ctx).pop();
                onAssignGroup(teamId, null);
              },
            ),
            ...groups.map((g) {
              final gId = '${g['id'] ?? ''}';
              return ListTile(
                title: Text('${g['name'] ?? 'Group'}',
                    style: TextStyle(color: context.fg)),
                trailing: currentGroupId == gId
                    ? Icon(Icons.check_rounded, color: context.accent)
                    : null,
                onTap: () {
                  Navigator.of(ctx).pop();
                  onAssignGroup(teamId, gId);
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Groups tab
// ---------------------------------------------------------------------------

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

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        ...groups.map((group) {
          final groupTeams =
              (group['teams'] as List?)?.whereType<Map>().toList() ??
                  const <Map<dynamic, dynamic>>[];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group header
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${group['name'] ?? 'Group'}',
                        style: TextStyle(
                          color: context.fg,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: context.accentBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${groupTeams.length} team${groupTeams.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          color: context.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Teams in group
              if (groupTeams.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Text(
                    'No teams assigned.',
                    style: TextStyle(color: context.fgSub, fontSize: 13),
                  ),
                )
              else
                ...groupTeams.asMap().entries.map((entry) {
                  final i = entry.key;
                  final team = entry.value;
                  final teamName = '${team['teamName'] ?? 'Team'}';
                  final isConfirmed = team['isConfirmed'] == true;
                  final isLast = i == groupTeams.length - 1;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            _TeamAvatar(name: teamName, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                teamName,
                                style: TextStyle(
                                  color: context.fg,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: isConfirmed
                                    ? context.success
                                    : context.warn,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        Divider(
                            height: 1,
                            indent: 60,
                            color: context.stroke),
                    ],
                  );
                }),
              Divider(height: 1, color: context.stroke),
            ],
          );
        }),
        if (canManage) ...[
          const SizedBox(height: 8),
          _ActionBtn(
            icon: Icons.refresh_rounded,
            label: 'Regenerate groups',
            onTap: isBusy ? null : onCreateGroups,
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Helper widgets
// ---------------------------------------------------------------------------

/// Flat tappable action row button.
class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = onTap == null
        ? context.fgSub.withValues(alpha: 0.4)
        : destructive
            ? context.danger
            : color ?? context.fg;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: effectiveColor, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: effectiveColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: context.fgSub.withValues(alpha: 0.5), size: 18),
          ],
        ),
      ),
    );
  }
}

/// Tournament status pill badge.
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _resolve(context, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  (String, Color) _resolve(BuildContext context, String status) {
    switch (status.toUpperCase()) {
      case 'UPCOMING':
        return ('Upcoming', context.sky);
      case 'REGISTRATION_OPEN':
        return ('Registration Open', context.success);
      case 'IN_PROGRESS':
        return ('In Progress', context.accent);
      case 'COMPLETED':
        return ('Completed', context.fgSub);
      case 'CANCELLED':
        return ('Cancelled', context.danger);
      default:
        return (status, context.warn);
    }
  }
}

/// Team avatar circle with first letter of name.
class _TeamAvatar extends StatelessWidget {
  const _TeamAvatar({required this.name, this.size = 40});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final letter =
        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.accentBg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          color: context.accent,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.42,
        ),
      ),
    );
  }
}

/// Inline stat chip for the overview stats row.
class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: context.fg,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: context.fgSub, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

/// A labelled info row for overview summary section.
class _SummaryInfoRow extends StatelessWidget {
  const _SummaryInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.fgSub),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: TextStyle(color: context.fgSub, fontSize: 13)),
        ),
        Text(
          value,
          style: TextStyle(
            color: context.fg,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Empty state pane with optional action button.
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.fgSub, fontSize: 15),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 11),
                  decoration: BoxDecoration(
                    color: context.accentBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    actionLabel!,
                    style: TextStyle(
                      color: context.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Utility functions
// ---------------------------------------------------------------------------

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

