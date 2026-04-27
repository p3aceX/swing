import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../repositories/host_team_repository.dart';
import '../../../repositories/host_tournament_repository.dart';
import '../../../theme/host_colors.dart';

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
    this.onNavigateToMatch,
    this.onStartMatch,
  });

  final String tournamentId;
  final Map<String, dynamic>? initialData;
  final SharedTournamentRepository? repository;
  final TournamentPermissions permissions;
  final bool isOwner;
  final VoidCallback? onBack;
  final void Function(BuildContext context, String matchId)? onNavigateToMatch;
  final void Function(BuildContext context, Map<String, dynamic> match)? onStartMatch;

  @override
  ConsumerState<TournamentDetailScreen> createState() =>
      _TournamentDetailScreenState();
}

class _TournamentDetailScreenState
    extends ConsumerState<TournamentDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Settings form controllers
  late final TextEditingController _nameController;
  late final TextEditingController _organiserNameController;
  late final TextEditingController _organiserPhoneController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _maxTeamsController;
  late final TextEditingController _entryFeeController;
  late final TextEditingController _prizePoolController;
  bool _isPublic = true;

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
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _tournament = widget.initialData;
    _nameController = TextEditingController();
    _organiserNameController = TextEditingController();
    _organiserPhoneController = TextEditingController();
    _descriptionController = TextEditingController();
    _maxTeamsController = TextEditingController();
    _entryFeeController = TextEditingController();
    _prizePoolController = TextEditingController();
    _reload();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _organiserNameController.dispose();
    _organiserPhoneController.dispose();
    _descriptionController.dispose();
    _maxTeamsController.dispose();
    _entryFeeController.dispose();
    _prizePoolController.dispose();
    super.dispose();
  }

  void _syncSettingsControllers(Map<String, dynamic> t) {
    _nameController.text = '${t['name'] ?? ''}';
    _organiserNameController.text = '${t['organiserName'] ?? ''}';
    _organiserPhoneController.text = '${t['organiserPhone'] ?? ''}';
    _descriptionController.text = '${t['description'] ?? ''}';
    _maxTeamsController.text = t['maxTeams'] != null ? '${t['maxTeams']}' : '';
    _entryFeeController.text = t['entryFee'] != null ? '${t['entryFee']}' : '';
    _prizePoolController.text = '${t['prizePool'] ?? ''}';
    _isPublic = t['isPublic'] == true;
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
      final tournament = result[0] as Map<String, dynamic>;
      setState(() {
        _tournament = tournament;
        _teams = result[1] as List<Map<String, dynamic>>;
        _groups = result[2] as List<Map<String, dynamic>>;
        _standings = result[3] as Map<String, List<Map<String, dynamic>>>;
        _schedule = result[4] as List<Map<String, dynamic>>;
      });
      _syncSettingsControllers(tournament);
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
      _showError(_friendlyError(error));
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  String _friendlyError(Object error) {
    if (error is DioException) {
      final body = error.response?.data;
      final code = body is Map ? '${body['error']?['code'] ?? ''}' : '';
      final serverMsg = body is Map ? '${body['error']?['message'] ?? ''}' : '';
      switch (code) {
        case 'TOURNAMENT_FULL':
          final max = _tournament?['maxTeams'];
          return max != null
              ? 'Tournament is full ($max/$max confirmed). Remove a confirmed team to add more.'
              : 'Tournament is full. Remove a confirmed team to add more.';
        case 'ALREADY_REGISTERED':
          return 'This team is already in the tournament.';
        case 'NOT_FOUND':
          return 'Team not found. Check the Team ID and try again.';
        default:
          return serverMsg.isNotEmpty ? serverMsg : 'Something went wrong. Please try again.';
      }
    }
    return error.toString();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.danger,
      ),
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ── Dialogs / sheets ──────────────────────────────────────────────────────

  Future<void> _showAddTeamSheet() async {
    final results = await showModalBottomSheet<List<_AddTeamResult>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollCtrl) => _AddTeamSheet(
          scrollController: scrollCtrl,
          existingIds: {
            for (final t in _teams) '${t['teamId'] ?? t['id'] ?? ''}',
          }..remove(''),
        ),
      ),
    );
    if (results == null || results.isEmpty || !mounted) {
      debugPrint('[AddTeam] sheet dismissed, results=${results?.length ?? 'null'}');
      return;
    }
    debugPrint('[AddTeam] selected ${results.length} team(s): ${results.map((r) => '${r.teamId}(${r.teamName})').join(', ')}');
    await _runAction(() async {
      for (final r in results) {
        debugPrint('[AddTeam] calling addTeam tournamentId=${widget.tournamentId} teamId=${r.teamId} teamName=${r.teamName}');
        try {
          final res = await _repository.addTeam(
            widget.tournamentId,
            teamId: r.teamId,
            teamName: r.teamName,
          );
          debugPrint('[AddTeam] success teamId=${r.teamId} response=$res');
        } catch (e) {
          if (e is DioException) {
            debugPrint('[AddTeam] ERROR teamId=${r.teamId} status=${e.response?.statusCode} body=${e.response?.data}');
          } else {
            debugPrint('[AddTeam] ERROR teamId=${r.teamId} error=$e');
          }
          rethrow;
        }
      }
    });
  }

  Future<void> _showCreateGroupDialog({bool defaultAutoAssign = true}) async {
    final result = await showDialog<(List<String>, bool)>(
      context: context,
      builder: (context) => _CreateGroupsDialog(
        defaultAutoAssign: defaultAutoAssign,
        existingGroupNames: _groups.map((g) => '${g['name']}').toList(),
      ),
    );
    if (result == null) return;
    await _runAction(() async {
      await _repository.createGroups(
        widget.tournamentId,
        groupNames: result.$1,
        autoAssign: result.$2,
      );
    });
  }

  Future<void> _showGenerateFixturesSheet() async {
    final result = await showModalBottomSheet<_GenerateFixturesParams>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _GenerateFixturesSheet(
        tournament: _tournament ?? const {},
      ),
    );
    if (result == null || !mounted) return;
    await _runAction(() => _repository.generateSmartSchedule(
          widget.tournamentId,
          startDate: result.startDate,
          matchStartTime: result.matchStartTime,
          matchesPerDay: result.matchesPerDay,
          gapBetweenMatchesHours: result.gapBetweenMatchesHours,
          validWeekdays: result.validWeekdays,
        ));
  }

  Future<bool?> _confirm(String title, String body) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final titleText = _tournament?['name'] as String? ??
        widget.initialData?['name'] as String? ??
        'Manage Tournament';

    final currentTab = _tabController.index;

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: context.fg),
          onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          titleText,
          style: TextStyle(
            color: context.fg,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: ColoredBox(
            color: context.bg,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: context.accent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 2,
              labelColor: context.accent,
              unselectedLabelColor: context.fgSub,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              dividerColor: context.stroke,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Teams'),
                Tab(text: 'Groups'),
                Tab(text: 'Fixtures'),
                Tab(text: 'Schedule'),
                Tab(text: 'Points Table'),
                Tab(text: 'Settings'),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _canManage && currentTab == 1
          ? FloatingActionButton.extended(
              backgroundColor: context.accent,
              foregroundColor: context.bg,
              onPressed: _isBusy ? null : _showAddTeamSheet,
              label: const Text('Add Team'),
              icon: const Icon(Icons.group_add_rounded),
            )
          : null,
      body: Column(
        children: [
          if (_isLoading) LinearProgressIndicator(color: context.accent),
          if ((_error ?? '').isNotEmpty)
            ColoredBox(
              color: context.danger.withValues(alpha: 0.1),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded,
                        color: context.danger, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style:
                            TextStyle(color: context.danger, fontSize: 13),
                      ),
                    ),
                    GestureDetector(
                      onTap: _reload,
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          color: context.danger,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: _isLoading && _tournament == null
                ? const SizedBox.shrink()
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
                        onRefresh: _reload,
                        onAdvanceRound: () async {
                          final ok = await _confirm(
                            'Advance round',
                            'This will move the tournament to the next knockout round. Continue?',
                          );
                          if (ok != true) return;
                          await _runAction(
                              () => _repository.advanceRound(widget.tournamentId));
                        },
                        onShare: () {
                          final link =
                              'https://swing.app/tournaments/${widget.tournamentId}';
                          Clipboard.setData(ClipboardData(text: link));
                          _showSnack('Invite link copied to clipboard');
                        },
                      ),
                      _TeamsTab(
                        teams: _teams,
                        groups: _groups,
                        canManage: _canManage,
                        isBusy: _isBusy,
                        onRefresh: _reload,
                        onRemove: (tournamentTeamId) async {
                          final ok = await _confirm(
                            'Remove team',
                            'Remove this team from the tournament?',
                          );
                          if (ok != true) return;
                          await _runAction(() => _repository.removeTeam(
                              widget.tournamentId, tournamentTeamId));
                        },
                        onConfirm: (tournamentTeamId, confirmed) =>
                            _runAction(() => _repository.confirmTeam(
                                widget.tournamentId,
                                tournamentTeamId,
                                confirmed)),
                        onAssignGroup: (tournamentTeamId, groupId) =>
                            _runAction(() => _repository.assignTeamToGroup(
                                widget.tournamentId,
                                tournamentTeamId,
                                groupId)),
                        onReject: (tournamentTeamId) async {
                          await _runAction(() async {
                            await _repository.confirmTeam(
                                widget.tournamentId, tournamentTeamId, false);
                            await _repository.removeTeam(
                                widget.tournamentId, tournamentTeamId);
                          });
                        },
                      ),
                      _GroupsTab(
                        tournament: _tournament ?? const {},
                        teams: _teams,
                        groups: _groups,
                        canManage: _canManage,
                        isBusy: _isBusy,
                        onRefresh: _reload,
                        onCreateGroups: () => _showCreateGroupDialog(defaultAutoAssign: false),
                        onAutoAssign: () => _showCreateGroupDialog(defaultAutoAssign: true),
                        onAssignGroup: (tournamentTeamId, groupId) =>
                            _runAction(() => _repository.assignTeamToGroup(
                                widget.tournamentId, tournamentTeamId, groupId)),
                        onDiscardGroups: () async {
                          final ok = await _confirm(
                            'Discard groups',
                            'This will remove all groups and unassign every team. Continue?',
                          );
                          if (ok != true) return;
                          await _runAction(() => _repository.discardGroups(widget.tournamentId));
                        },
                      ),
                      _FixturesTab(
                        tournament: _tournament ?? const {},
                        schedule: _schedule,
                        canManage: _canManage,
                        isBusy: _isBusy,
                        onRefresh: _reload,
                        onShowGenerateSheet: () => _showGenerateFixturesSheet(),
                        onUpdateMatch: (matchId, {scheduledAt, swapTeams = false}) =>
                            _runAction(() => _repository.updateMatch(
                              matchId,
                              scheduledAt: scheduledAt,
                              swapTeams: swapTeams,
                            )),
                        onDeleteSchedule: () async {
                          final ok = await _confirm(
                            'Delete schedule',
                            'This will permanently delete all fixtures. Continue?',
                          );
                          if (ok != true) return;
                          await _runAction(() =>
                              _repository.deleteSchedule(widget.tournamentId));
                        },
                      ),
                      _TournamentScheduleTab(
                        schedule: _schedule,
                        canManage: _canManage,
                        isBusy: _isBusy,
                        onShowGenerateSheet: () => _showGenerateFixturesSheet(),
                        onNavigateToMatch: widget.onNavigateToMatch != null
                            ? (matchId) => widget.onNavigateToMatch!(context, matchId)
                            : null,
                        onStartMatch: widget.onStartMatch != null
                            ? (match) => widget.onStartMatch!(context, match)
                            : null,
                        onRefresh: _reload,
                      ),
                      _PointsTableTab(
                        standings: _standings,
                        canManage: _canManage,
                        isBusy: _isBusy,
                        onRefresh: _reload,
                        onRecalculate: () => _runAction(
                            () => _repository
                                .recalculateStandings(widget.tournamentId)),
                      ),
                      _SettingsTab(
                        tournament: _tournament ?? const {},
                        groups: _groups,
                        canManage: _canManage,
                        isBusy: _isBusy,
                        nameController: _nameController,
                        organiserNameController: _organiserNameController,
                        organiserPhoneController: _organiserPhoneController,
                        descriptionController: _descriptionController,
                        maxTeamsController: _maxTeamsController,
                        entryFeeController: _entryFeeController,
                        prizePoolController: _prizePoolController,
                        isPublic: _isPublic,
                        onIsPublicChanged: (v) =>
                            setState(() => _isPublic = v),
                        onSave: () => _showSnack('Feature coming soon'),
                        onCreateGroups: () => _showCreateGroupDialog(defaultAutoAssign: false),
                        onAutoAssign: () => _showCreateGroupDialog(defaultAutoAssign: true),
                        onDeleteTournament: () async {
                          final ok = await _confirm(
                            'Delete tournament',
                            'This will permanently delete the tournament, all teams, fixtures and standings. This cannot be undone.',
                          );
                          if (ok != true) return;
                          await _runAction(() => _repository.deleteTournament(widget.tournamentId));
                          if (mounted) {
                            if (widget.onBack != null) {
                              widget.onBack!();
                            } else {
                              Navigator.of(context).maybePop();
                            }
                          }
                        },
                        tournamentId: widget.tournamentId,
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
    this.onNavigateToMatch,
    this.onStartMatch,
  });

  final String tournamentId;
  final Map<String, dynamic>? initialData;
  final void Function(BuildContext context, String matchId)? onNavigateToMatch;
  final void Function(BuildContext context, Map<String, dynamic> match)? onStartMatch;

  @override
  Widget build(BuildContext context) {
    return TournamentDetailScreen(
      tournamentId: tournamentId,
      initialData: initialData,
      permissions: const TournamentPermissions.host(),
      isOwner: true,
      onNavigateToMatch: onNavigateToMatch,
      onStartMatch: onStartMatch,
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 1 — Overview
// ---------------------------------------------------------------------------

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.tournament,
    required this.teams,
    required this.groups,
    required this.schedule,
    required this.canManage,
    required this.isBusy,
    required this.onRefresh,
    required this.onAdvanceRound,
    required this.onShare,
  });

  final Map<String, dynamic> tournament;
  final List<Map<String, dynamic>> teams;
  final List<Map<String, dynamic>> groups;
  final List<Map<String, dynamic>> schedule;
  final bool canManage;
  final bool isBusy;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onAdvanceRound;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final status = '${tournament['status'] ?? 'UPCOMING'}'.toUpperCase();
    final confirmedCount =
        teams.where((t) => t['isConfirmed'] == true).length;
    final maxTeams = tournament['maxTeams'];
    final playedCount =
        schedule.where((m) => '${m['status']}'.toUpperCase() == 'COMPLETED').length;
    final totalMatches = schedule.length;

    // Unique rounds in order
    final allRounds = _orderedRounds(schedule);
    final activeRound = _activeRound(schedule);

    final isOngoing = status == 'ONGOING' || status == 'IN_PROGRESS' || status == 'LIVE';

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          // ── Status banner ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                _StatusPill(status: status),
                const SizedBox(width: 12),
                if (canManage) ..._statusCta(context, status),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── 4 stat tiles ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.6,
              children: [
                _StatTile(
                  label: 'Teams',
                  value: maxTeams != null
                      ? '$confirmedCount/$maxTeams'
                      : '$confirmedCount',
                ),
                _StatTile(
                  label: 'Matches',
                  value: totalMatches == 0
                      ? '-'
                      : '$playedCount/$totalMatches',
                ),
                _StatTile(
                  label: 'Groups',
                  value: '${groups.length}',
                ),
                _StatTile(
                  label: 'Status',
                  value: _statusLabel(status),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Tournament details ────────────────────────────────────────────
          _TournamentDetailsSection(tournament: tournament),

          const SizedBox(height: 20),

          // ── Stage pipeline ────────────────────────────────────────────────
          if (allRounds.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'STAGE PIPELINE',
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: allRounds.length,
                separatorBuilder: (_, __) => Row(
                  children: [
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded,
                        size: 16, color: context.fgSub),
                    const SizedBox(width: 4),
                  ],
                ),
                itemBuilder: (context, i) {
                  final round = allRounds[i];
                  final isActive = round == activeRound;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive
                          ? context.accent
                          : context.panel,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      round,
                      style: TextStyle(
                        color: isActive ? context.bg : context.fgSub,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Advance Round ─────────────────────────────────────────────────
          if (canManage && isOngoing) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: context.accent),
                  foregroundColor: context.accent,
                  minimumSize: const Size(double.infinity, 44),
                ),
                onPressed: isBusy ? null : onAdvanceRound,
                child: isBusy
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.accent,
                        ),
                      )
                    : const Text('Advance to Next Round →'),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Share row ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: context.stroke),
                      foregroundColor: context.fg,
                    ),
                    onPressed: onShare,
                    icon: const Icon(Icons.link_rounded, size: 16),
                    label: const Text('Copy invite link'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: context.stroke),
                      foregroundColor: context.fg,
                    ),
                    onPressed: onShare,
                    icon: const Icon(Icons.share_rounded, size: 16),
                    label: const Text('Share'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _statusCta(BuildContext context, String status) {
    String? label;
    switch (status) {
      case 'DRAFT':
        label = 'Publish';
        break;
      case 'UPCOMING':
        label = 'Start Tournament';
        break;
      case 'ONGOING':
      case 'IN_PROGRESS':
      case 'LIVE':
        label = 'End Tournament';
        break;
      default:
        return [];
    }
    return [
      FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: context.accent,
          foregroundColor: context.bg,
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: isBusy ? null : () {},
        child: Text(label, style: const TextStyle(fontSize: 13)),
      ),
    ];
  }

  List<String> _orderedRounds(List<Map<String, dynamic>> schedule) {
    final knownOrder = [
      'Quarter Final',
      'Semi Final',
      'Final',
    ];
    final rounds = schedule.map((m) => '${m['round'] ?? ''}').toSet();
    final knockout = rounds.where(knownOrder.contains).toList()
      ..sort((a, b) =>
          knownOrder.indexOf(a).compareTo(knownOrder.indexOf(b)));
    final other = rounds
        .where((r) => !knownOrder.contains(r) && r.isNotEmpty)
        .toList()
      ..sort();
    return [...other, ...knockout];
  }

  String? _activeRound(List<Map<String, dynamic>> schedule) {
    for (final m in schedule) {
      final s = '${m['status'] ?? ''}'.toUpperCase();
      if (s == 'LIVE' || s == 'IN_PROGRESS') {
        return '${m['round'] ?? ''}';
      }
    }
    // Return last non-completed round
    for (final m in schedule.reversed) {
      final s = '${m['status'] ?? ''}'.toUpperCase();
      if (s != 'COMPLETED') return '${m['round'] ?? ''}';
    }
    return null;
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'UPCOMING':
        return 'Upcoming';
      case 'ONGOING':
      case 'IN_PROGRESS':
        return 'Ongoing';
      case 'LIVE':
        return 'Live';
      case 'COMPLETED':
        return 'Completed';
      case 'DRAFT':
        return 'Draft';
      default:
        return status;
    }
  }
}

// ---------------------------------------------------------------------------
// Tournament details section (Overview)
// ---------------------------------------------------------------------------

class _TournamentDetailsSection extends StatelessWidget {
  const _TournamentDetailsSection({required this.tournament});
  final Map<String, dynamic> tournament;

  @override
  Widget build(BuildContext context) {
    final format = '${tournament['format'] ?? ''}';
    final tFormat = '${tournament['tournamentFormat'] ?? ''}';
    final startDate = _parseDate(tournament['startDate']);
    final endDate = _parseDate(tournament['endDate']);
    final city = '${tournament['city'] ?? ''}'.trim();
    final venue = '${tournament['venueName'] ?? ''}'.trim();
    final ballType = '${tournament['ballType'] ?? ''}'.trim();
    final isPublic = tournament['isPublic'] != false;
    final entryFee = tournament['entryFee'];
    final earlyBirdFee = tournament['earlyBirdFee'];
    final earlyBirdDeadline = _parseDate(tournament['earlyBirdDeadline']);
    final prizePool = '${tournament['prizePool'] ?? ''}'.trim();
    final description = '${tournament['description'] ?? ''}'.trim();
    final organiserName = '${tournament['organiserName'] ?? ''}'.trim();
    final organiserPhone = '${tournament['organiserPhone'] ?? ''}'.trim();

    final locationParts = [if (venue.isNotEmpty) venue, if (city.isNotEmpty) city];
    final dateText = _dateRange(startDate, endDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Text(
            'TOURNAMENT DETAILS',
            style: TextStyle(
              color: context.fgSub,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ),
        _DetailRow(
          icon: Icons.sports_cricket_rounded,
          label: 'Format',
          value: '${_formatLabel(format)} · ${_tFormatLabel(tFormat)}',
        ),
        if (dateText.isNotEmpty)
          _DetailRow(
            icon: Icons.calendar_today_rounded,
            label: 'Dates',
            value: dateText,
          ),
        if (locationParts.isNotEmpty)
          _DetailRow(
            icon: Icons.location_on_rounded,
            label: 'Venue',
            value: locationParts.join(', '),
          ),
        if (ballType.isNotEmpty)
          _DetailRow(
            icon: Icons.circle_rounded,
            label: 'Ball',
            value: ballType,
          ),
        _DetailRow(
          icon: isPublic ? Icons.public_rounded : Icons.lock_outline_rounded,
          label: 'Visibility',
          value: isPublic ? 'Public' : 'Private',
        ),
        if (entryFee != null && entryFee != 0) ...[
          _DetailRow(
            icon: Icons.confirmation_number_rounded,
            label: 'Entry Fee',
            value: '₹$entryFee${earlyBirdFee != null && earlyBirdFee != 0 ? ' (Early bird: ₹$earlyBirdFee${earlyBirdDeadline != null ? ' till ${DateFormat('d MMM').format(earlyBirdDeadline)}' : ''})' : ''}',
          ),
        ],
        if (prizePool.isNotEmpty)
          _DetailRow(
            icon: Icons.emoji_events_rounded,
            label: 'Prize Pool',
            value: prizePool,
          ),
        if (organiserName.isNotEmpty)
          _DetailRow(
            icon: Icons.person_outline_rounded,
            label: 'Organiser',
            value: organiserName,
          ),
        if (organiserPhone.isNotEmpty)
          _DetailRow(
            icon: Icons.phone_outlined,
            label: 'Contact',
            value: organiserPhone,
          ),
        if (description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: context.fg, fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    try { return DateTime.parse('$v').toLocal(); } catch (_) { return null; }
  }

  String _dateRange(DateTime? start, DateTime? end) {
    if (start == null) return '';
    final fmt = DateFormat('d MMM yyyy');
    if (end == null || end.difference(start).inDays < 1) return fmt.format(start);
    return '${fmt.format(start)} – ${fmt.format(end)}';
  }

  String _formatLabel(String f) => switch (f.toUpperCase()) {
    'ONE_DAY' => 'ODI',
    'T20' => 'T20',
    'T10' => 'T10',
    'TWO_INNINGS' => 'Test',
    _ => f.isEmpty ? '—' : f,
  };

  String _tFormatLabel(String f) => switch (f.toUpperCase()) {
    'LEAGUE' => 'League',
    'KNOCKOUT' => 'Knockout',
    'GROUP_STAGE_KNOCKOUT' => 'Group + Knockout',
    'SUPER_LEAGUE' => 'Super League',
    'SERIES' => 'Series',
    _ => f.isEmpty ? '—' : f,
  };
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: context.fgSub),
          const SizedBox(width: 10),
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: TextStyle(color: context.fgSub, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: context.fg,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 2 — Teams
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
    required this.onReject,
  });

  final List<Map<String, dynamic>> teams;
  final List<Map<String, dynamic>> groups;
  final bool canManage;
  final bool isBusy;
  final Future<void> Function() onRefresh;
  final Future<void> Function(String tournamentTeamId) onRemove;
  final Future<void> Function(String tournamentTeamId, bool confirmed)
      onConfirm;
  final Future<void> Function(String tournamentTeamId, String? groupId)
      onAssignGroup;
  final Future<void> Function(String tournamentTeamId) onReject;

  @override
  Widget build(BuildContext context) {
    final pending =
        teams.where((t) => t['isConfirmed'] != true).toList();
    final confirmed =
        teams.where((t) => t['isConfirmed'] == true).toList();

    if (teams.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          children: [
            const SizedBox(height: 80),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.groups_outlined,
                        size: 48, color: context.fgSub),
                    const SizedBox(height: 16),
                    Text(
                      'No teams yet',
                      style: TextStyle(
                        color: context.fg,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add a team using the button below.',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: context.fgSub, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: [
          // Requests section
          if (pending.isNotEmpty) ...[
            _SectionHeader(
              title: 'REQUESTS',
              count: pending.length,
            ),
            ...pending.map((team) {
              final ttId = '${team['id'] ?? ''}';
              final name =
                  '${team['teamName'] ?? team['team']?['name'] ?? 'Unnamed'}';
              final logoUrl =
                  '${team['team']?['logoUrl'] ?? ''}';
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        _TeamAvatar(name: name, logoUrl: logoUrl),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  color: context.fg,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: context.warn
                                      .withValues(alpha: 0.15),
                                  borderRadius:
                                      BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Pending',
                                  style: TextStyle(
                                    color: context.warn,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (canManage) ...[
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side:
                                  BorderSide(color: context.danger),
                              foregroundColor: context.danger,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed:
                                isBusy ? null : () => onReject(ttId),
                            child: const Text('Reject',
                                style: TextStyle(fontSize: 12)),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: context.accent,
                              foregroundColor: context.bg,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: isBusy
                                ? null
                                : () => onConfirm(ttId, true),
                            child: const Text('Approve',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Divider(
                      height: 1, indent: 64, color: context.stroke),
                ],
              );
            }),
            const SizedBox(height: 8),
          ],

          // Confirmed section
          _SectionHeader(
            title: 'CONFIRMED',
            count: confirmed.length,
          ),
          if (confirmed.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(
                'No confirmed teams yet.',
                style:
                    TextStyle(color: context.fgSub, fontSize: 13),
              ),
            )
          else
            ...confirmed.map((team) {
              final ttId = '${team['id'] ?? ''}';
              final name =
                  '${team['teamName'] ?? team['team']?['name'] ?? 'Unnamed'}';
              final logoUrl =
                  '${team['team']?['logoUrl'] ?? ''}';
              final groupId =
                  '${team['groupId'] ?? ''}'.trim();
              String? groupName;
              if (groupId.isNotEmpty) {
                final match = groups
                    .where((g) => '${g['id']}' == groupId)
                    .toList();
                if (match.isNotEmpty) {
                  groupName = '${match.first['name'] ?? groupId}';
                }
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        _TeamAvatar(name: name, logoUrl: logoUrl),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  color: context.fg,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              if (groupName != null) ...[
                                const SizedBox(height: 3),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: context.accentBg,
                                    borderRadius:
                                        BorderRadius.circular(4),
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
                        ),
                        if (canManage)
                          IconButton(
                            icon: Icon(Icons.more_horiz_rounded,
                                color: context.fgSub, size: 20),
                            onPressed: isBusy
                                ? null
                                : () => _showConfirmedOptions(
                                      context,
                                      team: team,
                                      ttId: ttId,
                                      groupId: groupId,
                                    ),
                          ),
                      ],
                    ),
                  ),
                  Divider(
                      height: 1, indent: 64, color: context.stroke),
                ],
              );
            }),
        ],
      ),
    );
  }

  void _showConfirmedOptions(
    BuildContext context, {
    required Map<String, dynamic> team,
    required String ttId,
    required String groupId,
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
              leading:
                  Icon(Icons.group_work_outlined, color: context.fg),
              title: Text('Assign to Group',
                  style: TextStyle(color: context.fg)),
              onTap: groups.isEmpty
                  ? null
                  : () {
                      Navigator.of(ctx).pop();
                      _showAssignGroupSheet(context,
                          ttId: ttId, currentGroupId: groupId);
                    },
            ),
            ListTile(
              leading: Icon(Icons.person_remove_outlined,
                  color: context.danger),
              title: Text('Remove',
                  style: TextStyle(color: context.danger)),
              onTap: () {
                Navigator.of(ctx).pop();
                onRemove(ttId);
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
    required String ttId,
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
              title:
                  Text('No group', style: TextStyle(color: context.fgSub)),
              trailing: currentGroupId.isEmpty
                  ? Icon(Icons.check_rounded, color: context.accent)
                  : null,
              onTap: () {
                Navigator.of(ctx).pop();
                onAssignGroup(ttId, null);
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
                  onAssignGroup(ttId, gId);
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
// Tab 3 — Groups
// ---------------------------------------------------------------------------

class _GroupsTab extends StatefulWidget {
  const _GroupsTab({
    required this.tournament,
    required this.teams,
    required this.groups,
    required this.canManage,
    required this.isBusy,
    required this.onRefresh,
    required this.onCreateGroups,
    required this.onAutoAssign,
    required this.onAssignGroup,
    required this.onDiscardGroups,
  });

  final Map<String, dynamic> tournament;
  final List<Map<String, dynamic>> teams;
  final List<Map<String, dynamic>> groups;
  final bool canManage;
  final bool isBusy;
  final Future<void> Function() onRefresh;
  final VoidCallback onCreateGroups;
  final VoidCallback onAutoAssign;
  final Future<void> Function(String tournamentTeamId, String? groupId) onAssignGroup;
  final VoidCallback onDiscardGroups;

  @override
  State<_GroupsTab> createState() => _GroupsTabState();
}

class _GroupsTabState extends State<_GroupsTab> {
  bool get _hasGroups => widget.groups.isNotEmpty;
  List<Map<String, dynamic>> get _confirmedTeams =>
      widget.teams.where((t) => t['isConfirmed'] == true).toList();

  bool get _requiresGroups {
    final f = '${widget.tournament['tournamentFormat'] ?? ''}'.toUpperCase();
    return f == 'GROUP_STAGE_KNOCKOUT' || f == 'SUPER_LEAGUE';
  }

  String get _formatLabel {
    final f = '${widget.tournament['tournamentFormat'] ?? ''}'.toUpperCase();
    return switch (f) {
      'LEAGUE' => 'League',
      'KNOCKOUT' => 'Knockout',
      'SERIES' => 'Series',
      'DOUBLE_ELIMINATION' => 'Double Elimination',
      _ => 'this format',
    };
  }

  @override
  Widget build(BuildContext context) {
    if (!_requiresGroups) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        children: [
          Text(
            'Groups not used',
            style: TextStyle(
              color: context.fg,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$_formatLabel tournaments do not use groups. All confirmed teams compete directly.',
            style: TextStyle(color: context.fgSub, fontSize: 14, height: 1.5),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        children: [
          if (!_hasGroups) _buildSetupSection(context),
          if (_hasGroups) ..._buildGroupCards(context),
          if (_hasGroups && widget.canManage) ...[
            const SizedBox(height: 16),
            _buildManageActions(context),
          ],
        ],
      ),
    );
  }

  Widget _buildSetupSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'No groups yet',
          style: TextStyle(
            color: context.fg,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Set up groups to organise confirmed teams into pools before fixtures are generated.',
          style: TextStyle(color: context.fgSub, fontSize: 14, height: 1.5),
        ),
        if (widget.canManage) ...[
          const SizedBox(height: 24),
          // Auto option
          _OptionCard(
            icon: Icons.auto_awesome_rounded,
            title: 'Auto assign',
            subtitle: 'Automatically distribute all confirmed teams across groups evenly.',
            onTap: widget.isBusy ? null : widget.onAutoAssign,
          ),
          const SizedBox(height: 12),
          // Manual option
          _OptionCard(
            icon: Icons.drag_indicator_rounded,
            title: 'Manual assign',
            subtitle: 'Create groups yourself and drag teams into each pool.',
            onTap: widget.isBusy ? null : widget.onCreateGroups,
          ),
        ],
      ],
    );
  }

  List<Widget> _buildGroupCards(BuildContext context) {
    // Teams not yet assigned to any group
    final unassigned = _confirmedTeams
        .where((t) => (t['groupId'] ?? '').toString().isEmpty)
        .toList();

    final items = <Widget>[];

    // Unassigned pool
    if (unassigned.isNotEmpty) {
      items.add(_GroupSection(
        name: 'Unassigned',
        teams: unassigned,
        groups: widget.groups,
        canManage: widget.canManage,
        isBusy: widget.isBusy,
        onAssignGroup: widget.onAssignGroup,
        isUnassigned: true,
      ));
      items.add(const SizedBox(height: 16));
    }

    for (final group in widget.groups) {
      final gId = '${group['id'] ?? ''}';
      final gTeams = _confirmedTeams
          .where((t) => '${t['groupId'] ?? ''}' == gId)
          .toList();
      items.add(_GroupSection(
        name: '${group['name'] ?? gId}',
        teams: gTeams,
        groups: widget.groups,
        canManage: widget.canManage,
        isBusy: widget.isBusy,
        onAssignGroup: widget.onAssignGroup,
        isUnassigned: false,
      ));
      items.add(const SizedBox(height: 16));
    }

    return items;
  }

  Widget _buildManageActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(color: context.stroke),
        const SizedBox(height: 12),
        Text(
          'Manage groups',
          style: TextStyle(
            color: context.fgSub,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.danger,
                  side: BorderSide(color: context.danger.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: widget.isBusy ? null : widget.onDiscardGroups,
                icon: const Icon(Icons.delete_outline_rounded, size: 16),
                label: const Text('Discard groups'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: context.accent,
                  foregroundColor: context.ctaFg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: widget.isBusy ? null : widget.onAutoAssign,
                icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                label: const Text('Re-auto assign'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GroupSection extends StatelessWidget {
  const _GroupSection({
    required this.name,
    required this.teams,
    required this.groups,
    required this.canManage,
    required this.isBusy,
    required this.onAssignGroup,
    required this.isUnassigned,
  });

  final String name;
  final List<Map<String, dynamic>> teams;
  final List<Map<String, dynamic>> groups;
  final bool canManage;
  final bool isBusy;
  final Future<void> Function(String tournamentTeamId, String? groupId) onAssignGroup;
  final bool isUnassigned;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isUnassigned
                    ? context.stroke.withValues(alpha: 0.5)
                    : context.accentBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                name.toUpperCase(),
                style: TextStyle(
                  color: isUnassigned ? context.fgSub : context.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${teams.length} team${teams.length == 1 ? '' : 's'}',
              style: TextStyle(color: context.fgSub, fontSize: 12),
            ),
          ],
        ),
        if (teams.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 2),
            child: Text(
              'No teams assigned',
              style: TextStyle(color: context.fgSub, fontSize: 13),
            ),
          )
        else
          const SizedBox(height: 8),
        ...teams.map((team) {
          final ttId = '${team['id'] ?? ''}';
          final name = '${team['teamName'] ?? team['team']?['name'] ?? 'Unnamed'}';
          final logo = '${team['team']?['logoUrl'] ?? ''}'.trim();
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                _TeamAvatar(name: name, logoUrl: logo.isEmpty ? null : logo),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (canManage)
                  GestureDetector(
                    onTap: isBusy ? null : () => _showGroupPicker(context, ttId, team),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.swap_horiz_rounded,
                        color: context.fgSub,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _showGroupPicker(BuildContext context, String ttId, Map<String, dynamic> team) {
    final currentGroupId = '${team['groupId'] ?? ''}'.trim();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Move to group',
                style: TextStyle(
                  color: context.fg,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${team['teamName'] ?? team['team']?['name'] ?? ''}',
                style: TextStyle(color: context.fgSub, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ...groups.map((g) {
                final gId = '${g['id'] ?? ''}';
                final selected = gId == currentGroupId;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: selected ? context.accent : context.accentBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.groups_rounded,
                      color: selected ? context.ctaFg : context.accent,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    '${g['name'] ?? gId}',
                    style: TextStyle(
                      color: context.fg,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  trailing: selected
                      ? Icon(Icons.check_rounded, color: context.accent, size: 18)
                      : null,
                  onTap: () {
                    Navigator.of(context).pop();
                    onAssignGroup(ttId, gId);
                  },
                );
              }),
              if (currentGroupId.isNotEmpty) ...[
                Divider(height: 1, color: context.stroke),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: context.stroke.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.remove_circle_outline_rounded,
                        color: context.fgSub, size: 18),
                  ),
                  title: Text('Remove from group',
                      style: TextStyle(color: context.fgSub)),
                  onTap: () {
                    Navigator.of(context).pop();
                    onAssignGroup(ttId, null);
                  },
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateGroupsDialog extends StatefulWidget {
  const _CreateGroupsDialog({
    this.defaultAutoAssign = true,
    this.existingGroupNames = const [],
  });

  final bool defaultAutoAssign;
  final List<String> existingGroupNames;

  @override
  State<_CreateGroupsDialog> createState() => _CreateGroupsDialogState();
}

class _CreateGroupsDialogState extends State<_CreateGroupsDialog> {
  late final TextEditingController _ctrl;
  late bool _autoAssign;

  @override
  void initState() {
    super.initState();
    final initial = widget.existingGroupNames.isNotEmpty
        ? widget.existingGroupNames.join(', ')
        : 'Group A, Group B';
    _ctrl = TextEditingController(text: initial);
    _autoAssign = widget.defaultAutoAssign;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create groups'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _ctrl,
              decoration: const InputDecoration(
                labelText: 'Group names',
                hintText: 'Group A, Group B',
                helperText: 'Separate names with commas',
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _autoAssign,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) => setState(() => _autoAssign = v),
              title: const Text('Auto-assign confirmed teams'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final groups = _ctrl.text
                .split(',')
                .map((v) => v.trim())
                .where((v) => v.isNotEmpty)
                .toList();
            if (groups.isEmpty) return;
            Navigator.of(context).pop((groups, _autoAssign));
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.accentBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: context.accent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.arrow_forward_ios_rounded, color: context.fgSub, size: 14),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 4 — Fixtures
// ---------------------------------------------------------------------------

class _FixturesTab extends StatefulWidget {
  const _FixturesTab({
    required this.tournament,
    required this.schedule,
    required this.canManage,
    required this.isBusy,
    required this.onRefresh,
    required this.onShowGenerateSheet,
    required this.onUpdateMatch,
    required this.onDeleteSchedule,
  });

  final Map<String, dynamic> tournament;
  final List<Map<String, dynamic>> schedule;
  final bool canManage;
  final bool isBusy;
  final Future<void> Function() onRefresh;
  final VoidCallback onShowGenerateSheet;
  final Future<void> Function(String matchId,
      {DateTime? scheduledAt, bool swapTeams}) onUpdateMatch;
  final Future<void> Function() onDeleteSchedule;

  @override
  State<_FixturesTab> createState() => _FixturesTabState();
}

class _FixturesTabState extends State<_FixturesTab> {
  String? _selectedRound;
  bool _bracketMode = false;

  List<String> _orderedRounds(List<Map<String, dynamic>> schedule) {
    final knownOrder = ['Quarter Final', 'Semi Final', 'Final'];
    final rounds = schedule.map((m) => '${m['round'] ?? ''}').toSet();
    final knockout = rounds.where(knownOrder.contains).toList()
      ..sort((a, b) =>
          knownOrder.indexOf(a).compareTo(knownOrder.indexOf(b)));
    final other = rounds
        .where((r) => !knownOrder.contains(r) && r.isNotEmpty)
        .toList()
      ..sort();
    return [...other, ...knockout];
  }

  @override
  Widget build(BuildContext context) {
    final rounds = _orderedRounds(widget.schedule);
    final filteredSchedule = _selectedRound == null
        ? widget.schedule
        : widget.schedule
            .where((m) => '${m['round']}' == _selectedRound)
            .toList();

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: Column(
        children: [
          // Top bar: round filter + view toggle
          ColoredBox(
            color: context.bg,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          _RoundChip(
                            label: 'All',
                            selected: _selectedRound == null,
                            onTap: () =>
                                setState(() => _selectedRound = null),
                          ),
                          ...rounds.map((r) => Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: _RoundChip(
                                  label: r,
                                  selected: _selectedRound == r,
                                  onTap: () =>
                                      setState(() => _selectedRound = r),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _bracketMode
                          ? Icons.view_list_rounded
                          : Icons.account_tree_rounded,
                      color: _bracketMode
                          ? context.accent
                          : context.fgSub,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _bracketMode = !_bracketMode),
                    tooltip: _bracketMode ? 'List view' : 'Bracket view',
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: context.stroke),

          // Content
          Expanded(
            child: _bracketMode
                ? _BracketView(schedule: widget.schedule)
                : _FixturesListView(
                    schedule: filteredSchedule,
                    rounds: rounds,
                    selectedRound: _selectedRound,
                    canManage: widget.canManage,
                    isBusy: widget.isBusy,
                    onShowGenerateSheet: widget.onShowGenerateSheet,
                    onUpdateMatch: widget.onUpdateMatch,
                    onDeleteSchedule: widget.onDeleteSchedule,
                  ),
          ),
        ],
      ),
    );
  }
}

class _FixturesListView extends StatelessWidget {
  const _FixturesListView({
    required this.schedule,
    required this.rounds,
    required this.selectedRound,
    required this.canManage,
    required this.isBusy,
    required this.onShowGenerateSheet,
    required this.onUpdateMatch,
    required this.onDeleteSchedule,
  });

  final List<Map<String, dynamic>> schedule;
  final List<String> rounds;
  final String? selectedRound;
  final bool canManage;
  final bool isBusy;
  final VoidCallback onShowGenerateSheet;
  final Future<void> Function(String matchId,
      {DateTime? scheduledAt, bool swapTeams}) onUpdateMatch;
  final Future<void> Function() onDeleteSchedule;

  @override
  Widget build(BuildContext context) {
    if (schedule.isEmpty && canManage) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'No fixtures yet',
            style: TextStyle(
              color: context.fg,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Generate fixtures with custom scheduling — pick match days, start time, and matches per day.',
            style: TextStyle(color: context.fgSub, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: context.accent,
              foregroundColor: context.bg,
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: isBusy ? null : onShowGenerateSheet,
            icon: const Icon(Icons.calendar_month_rounded, size: 18),
            label: const Text('Generate Fixtures'),
          ),
        ],
      );
    }

    if (schedule.isEmpty) {
      return const Center(child: Text('No fixtures found.'));
    }

    // Group matches by round (preserving order)
    final activeRounds = selectedRound != null
        ? [selectedRound!]
        : rounds.where(
            (r) => schedule.any((m) => '${m['round']}' == r)).toList();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 32),
      itemCount: activeRounds.length + (canManage ? 1 : 0),
      itemBuilder: (context, index) {
        if (canManage && index == activeRounds.length) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: context.danger.withValues(alpha: 0.5)),
                foregroundColor: context.danger,
                minimumSize: const Size(double.infinity, 44),
              ),
              onPressed: isBusy ? null : onDeleteSchedule,
              icon: const Icon(Icons.delete_sweep_outlined, size: 16),
              label: const Text('Delete Schedule'),
            ),
          );
        }
        final round = activeRounds[index];
        final matches =
            schedule.where((m) => '${m['round']}' == round).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: round.toUpperCase(), count: matches.length),
            ...matches.map((match) => _MatchCard(
                  match: match,
                  canManage: canManage,
                  isBusy: isBusy,
                  onUpdateMatch: onUpdateMatch,
                )),
          ],
        );
      },
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({
    required this.match,
    this.canManage = false,
    this.isBusy = false,
    this.onUpdateMatch,
  });

  final Map<String, dynamic> match;
  final bool canManage;
  final bool isBusy;
  final Future<void> Function(String matchId,
      {DateTime? scheduledAt, bool swapTeams})? onUpdateMatch;

  Future<void> _showRescheduleSheet(BuildContext context) async {
    final matchId = '${match['id'] ?? ''}';
    if (matchId.isEmpty || onUpdateMatch == null) return;
    final existing = match['scheduledAt'];
    DateTime initial = DateTime.now();
    if (existing != null) {
      try {
        initial = DateTime.parse('$existing').toLocal();
      } catch (_) {}
    }

    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _RescheduleSheet(initial: initial),
    );
    if (picked == null) return;
    await onUpdateMatch!(matchId, scheduledAt: picked);
  }

  Future<void> _swapTeams(BuildContext context) async {
    final matchId = '${match['id'] ?? ''}';
    if (matchId.isEmpty || onUpdateMatch == null) return;
    await onUpdateMatch!(matchId, swapTeams: true);
  }

  @override
  Widget build(BuildContext context) {
    final teamA = '${match['teamAName'] ?? 'TBD'}';
    final teamB = '${match['teamBName'] ?? 'TBD'}';
    final logoA = '${match['teamALogoUrl'] ?? ''}';
    final logoB = '${match['teamBLogoUrl'] ?? ''}';
    final status = '${match['status'] ?? 'SCHEDULED'}'.toUpperCase();
    final innings = (match['innings'] as List?)
            ?.whereType<Map>()
            .map((i) => Map<String, dynamic>.from(i))
            .toList() ??
        const [];

    final isCompleted = status == 'COMPLETED';
    final isEditable = status == 'SCHEDULED' || status == 'TOSS_DONE';
    String? scoreStr;
    if (isCompleted && innings.isNotEmpty) {
      scoreStr = _buildScoreString(innings);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ColoredBox(
        color: context.bg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Team A
                Expanded(
                  child: Row(
                    children: [
                      _TeamAvatar(name: teamA, logoUrl: logoA, size: 32),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          teamA,
                          style: TextStyle(
                            color: context.fg,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // vs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'vs',
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Team B
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          teamB,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: context.fg,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _TeamAvatar(name: teamB, logoUrl: logoB, size: 32),
                    ],
                  ),
                ),
                if (canManage && isEditable && !isBusy) ...[
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert,
                        size: 18, color: context.fgSub),
                    onSelected: (v) {
                      if (v == 'reschedule') _showRescheduleSheet(context);
                      if (v == 'swap') _swapTeams(context);
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'reschedule',
                        child: Row(children: [
                          Icon(Icons.schedule_rounded, size: 16),
                          SizedBox(width: 10),
                          Text('Reschedule'),
                        ]),
                      ),
                      const PopupMenuItem(
                        value: 'swap',
                        child: Row(children: [
                          Icon(Icons.swap_horiz_rounded, size: 16),
                          SizedBox(width: 10),
                          Text('Swap teams'),
                        ]),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            if (scoreStr != null) ...[
              const SizedBox(height: 4),
              Text(
                scoreStr,
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            Divider(
                height: 1,
                color: context.stroke.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  String _buildScoreString(List<Map<String, dynamic>> innings) {
    innings.sort((a, b) {
      final ia = (a['inningsNumber'] as num?)?.toInt() ?? 0;
      final ib = (b['inningsNumber'] as num?)?.toInt() ?? 0;
      return ia.compareTo(ib);
    });
    final parts = innings.map((inn) {
      final runs = inn['totalRuns'] ?? 0;
      final wickets = inn['totalWickets'] ?? 0;
      final overs = inn['totalOvers'] ?? 0;
      return '$runs/$wickets ($overs)';
    }).toList();
    return parts.join(' — ');
  }
}

// ---------------------------------------------------------------------------
// Generate Fixtures sheet
// ---------------------------------------------------------------------------

class _GenerateFixturesParams {
  const _GenerateFixturesParams({
    required this.startDate,
    required this.matchStartTime,
    required this.matchesPerDay,
    required this.gapBetweenMatchesHours,
    required this.validWeekdays,
  });
  final String startDate;
  final String matchStartTime;
  final int matchesPerDay;
  final double gapBetweenMatchesHours;
  final List<int> validWeekdays;
}

class _GenerateFixturesSheet extends StatefulWidget {
  const _GenerateFixturesSheet({required this.tournament});
  final Map<String, dynamic> tournament;

  @override
  State<_GenerateFixturesSheet> createState() => _GenerateFixturesSheetState();
}

class _GenerateFixturesSheetState extends State<_GenerateFixturesSheet> {
  // JS weekday convention: 0=Sun, 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat
  static const _dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  late Set<int> _selectedDays;
  late DateTime _startDate;
  late TimeOfDay _startTime;
  int _matchesPerDay = 2;
  double _gapHours = 3;

  @override
  void initState() {
    super.initState();
    // Default: Fri + Sat + Sun
    _selectedDays = {5, 6, 0};
    // Use tournament start date if available
    final raw = widget.tournament['startDate'];
    try {
      _startDate = DateTime.parse('$raw').toLocal();
    } catch (_) {
      _startDate = DateTime.now();
    }
    _startTime = const TimeOfDay(hour: 9, minute: 0);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  void _submit() {
    if (_selectedDays.isEmpty) return;
    final dateStr =
        '${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}';
    final timeStr =
        '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}';
    Navigator.of(context).pop(_GenerateFixturesParams(
      startDate: dateStr,
      matchStartTime: timeStr,
      matchesPerDay: _matchesPerDay,
      gapBetweenMatchesHours: _gapHours,
      validWeekdays: _selectedDays.toList(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('EEE, d MMM yyyy').format(_startDate);
    final timeLabel = _startTime.format(context);

    return Container(
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Text('Generate Fixtures',
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  )),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.close, color: context.fgSub),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ]),
            const SizedBox(height: 20),

            // Match days
            Text('Match days',
                style: TextStyle(
                    color: context.fg,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(
              children: List.generate(7, (i) {
                final selected = _selectedDays.contains(i);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      if (selected) {
                        _selectedDays.remove(i);
                      } else {
                        _selectedDays.add(i);
                      }
                    }),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? context.accent
                            : context.panel,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          _dayLabels[i],
                          style: TextStyle(
                            color: selected ? context.bg : context.fgSub,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Start date + time
            Text('Schedule start',
                style: TextStyle(
                    color: context.fg,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    color: context.panel,
                    child: Row(children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 16, color: context.fgSub),
                      const SizedBox(width: 8),
                      Text(dateLabel,
                          style:
                              TextStyle(color: context.fg, fontSize: 14)),
                    ]),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _pickTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  color: context.panel,
                  child: Row(children: [
                    Icon(Icons.access_time_rounded,
                        size: 16, color: context.fgSub),
                    const SizedBox(width: 8),
                    Text(timeLabel,
                        style: TextStyle(color: context.fg, fontSize: 14)),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 20),

            // Matches per day
            Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Matches per day',
                        style: TextStyle(
                            color: context.fg,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    Text('Max matches on the same day',
                        style:
                            TextStyle(color: context.fgSub, fontSize: 12)),
                  ],
                ),
              ),
              Row(children: [
                IconButton(
                  icon: Icon(Icons.remove_circle_outline,
                      color: _matchesPerDay > 1
                          ? context.accent
                          : context.fgSub),
                  onPressed: _matchesPerDay > 1
                      ? () => setState(() => _matchesPerDay--)
                      : null,
                ),
                Text('$_matchesPerDay',
                    style: TextStyle(
                        color: context.fg,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                IconButton(
                  icon: Icon(Icons.add_circle_outline,
                      color: _matchesPerDay < 10
                          ? context.accent
                          : context.fgSub),
                  onPressed: _matchesPerDay < 10
                      ? () => setState(() => _matchesPerDay++)
                      : null,
                ),
              ]),
            ]),

            // Gap between matches
            Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gap between matches',
                        style: TextStyle(
                            color: context.fg,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    Text('Hours between back-to-back matches',
                        style:
                            TextStyle(color: context.fgSub, fontSize: 12)),
                  ],
                ),
              ),
              Row(children: [
                IconButton(
                  icon: Icon(Icons.remove_circle_outline,
                      color: _gapHours > 1
                          ? context.accent
                          : context.fgSub),
                  onPressed: _gapHours > 1
                      ? () => setState(() => _gapHours--)
                      : null,
                ),
                Text('${_gapHours.toInt()}h',
                    style: TextStyle(
                        color: context.fg,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                IconButton(
                  icon: Icon(Icons.add_circle_outline,
                      color: _gapHours < 12
                          ? context.accent
                          : context.fgSub),
                  onPressed: _gapHours < 12
                      ? () => setState(() => _gapHours++)
                      : null,
                ),
              ]),
            ]),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor:
                      _selectedDays.isEmpty ? context.fgSub : context.accent,
                  foregroundColor: context.bg,
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: _selectedDays.isEmpty ? null : _submit,
                child: const Text('Generate'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reschedule sheet
// ---------------------------------------------------------------------------

class _RescheduleSheet extends StatefulWidget {
  const _RescheduleSheet({required this.initial});
  final DateTime initial;

  @override
  State<_RescheduleSheet> createState() => _RescheduleSheetState();
}

class _RescheduleSheetState extends State<_RescheduleSheet> {
  late DateTime _date;
  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    _date = widget.initial;
    _time = TimeOfDay(hour: widget.initial.hour, minute: widget.initial.minute);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) setState(() => _time = picked);
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('EEE, d MMM yyyy').format(_date);
    final timeLabel = _time.format(context);

    return Container(
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Reschedule Match',
                style: TextStyle(
                  color: context.fg,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                )),
            const Spacer(),
            IconButton(
              icon: Icon(Icons.close, color: context.fgSub),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ]),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  color: context.panel,
                  child: Row(children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 16, color: context.fgSub),
                    const SizedBox(width: 10),
                    Text(dateLabel,
                        style: TextStyle(color: context.fg, fontSize: 14)),
                  ]),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                color: context.panel,
                child: Row(children: [
                  Icon(Icons.access_time_rounded,
                      size: 16, color: context.fgSub),
                  const SizedBox(width: 10),
                  Text(timeLabel,
                      style: TextStyle(color: context.fg, fontSize: 14)),
                ]),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: context.accent,
                foregroundColor: context.bg,
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () {
                final result = DateTime(
                  _date.year,
                  _date.month,
                  _date.day,
                  _time.hour,
                  _time.minute,
                );
                Navigator.of(context).pop(result);
              },
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _BracketView extends StatelessWidget {
  const _BracketView({required this.schedule});

  final List<Map<String, dynamic>> schedule;

  @override
  Widget build(BuildContext context) {
    final knockoutRounds = ['Quarter Final', 'Semi Final', 'Final'];
    final columns = knockoutRounds
        .map((r) => schedule.where((m) => '${m['round']}' == r).toList())
        .where((list) => list.isNotEmpty)
        .toList();

    if (columns.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No knockout bracket yet. Advance from group stage first.',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.fgSub, fontSize: 14),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columns.asMap().entries.map((entry) {
          final i = entry.key;
          final col = entry.value;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (i > 0)
                SizedBox(
                  width: 24,
                  child: Center(
                    child: Container(
                      width: 1,
                      height: 60,
                      color: context.stroke,
                    ),
                  ),
                ),
              Column(
                children: col.map((match) {
                  final teamA = '${match['teamAName'] ?? 'TBD'}';
                  final teamB = '${match['teamBName'] ?? 'TBD'}';
                  final status =
                      '${match['status'] ?? ''}'.toUpperCase();
                  return Container(
                    width: 160,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: context.stroke),
                      borderRadius: BorderRadius.circular(8),
                      color: context.panel,
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            teamA,
                            style: TextStyle(
                              color: context.fg,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Divider(
                            height: 1, color: context.stroke),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            teamB,
                            style: TextStyle(
                              color: context.fg,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (status == 'COMPLETED')
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: context.success
                                  .withValues(alpha: 0.1),
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(7),
                              ),
                            ),
                            child: Text(
                              'Completed',
                              style: TextStyle(
                                color: context.success,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 5 — Schedule (Today / Upcoming / Completed with Start/Resume)
// ---------------------------------------------------------------------------

class _TournamentScheduleTab extends StatelessWidget {
  const _TournamentScheduleTab({
    required this.schedule,
    required this.canManage,
    required this.isBusy,
    required this.onRefresh,
    required this.onShowGenerateSheet,
    this.onNavigateToMatch,
    this.onStartMatch,
  });

  final List<Map<String, dynamic>> schedule;
  final bool canManage;
  final bool isBusy;
  final Future<void> Function() onRefresh;
  final VoidCallback onShowGenerateSheet;
  final void Function(String matchId)? onNavigateToMatch;
  final void Function(Map<String, dynamic> match)? onStartMatch;

  @override
  Widget build(BuildContext context) {
    if (schedule.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
          children: [
            Text('No schedule yet',
                style: TextStyle(
                    color: context.fg,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3)),
            const SizedBox(height: 6),
            Text(
                canManage
                    ? 'Generate fixtures with custom scheduling — pick match days, start time, and matches per day.'
                    : 'No fixtures have been generated yet.',
                style: TextStyle(
                    color: context.fgSub, fontSize: 14, height: 1.5)),
            if (canManage) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: context.accent,
                  foregroundColor: context.bg,
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: isBusy ? null : onShowGenerateSheet,
                icon: const Icon(Icons.calendar_month_rounded, size: 18),
                label: const Text('Generate Fixtures'),
              ),
            ],
          ],
        ),
      );
    }

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final live = <Map<String, dynamic>>[];
    final today = <Map<String, dynamic>>[];
    final upcoming = <Map<String, dynamic>>[];
    final completed = <Map<String, dynamic>>[];

    for (final m in schedule) {
      final id = '${m['id'] ?? '?'}';
      final status = '${m['status'] ?? ''}'.toUpperCase();
      final raw = m['scheduledAt'];
      debugPrint('[Schedule] id=$id status=$status scheduledAt=$raw');
      if (status == 'COMPLETED') {
        completed.add(m);
        debugPrint('[Schedule]   → completed');
        continue;
      }
      if (status == 'IN_PROGRESS' || status == 'TOSS_DONE') {
        live.add(m);
        debugPrint('[Schedule]   → live');
        continue;
      }
      DateTime? dt;
      if (raw != null) {
        try { dt = DateTime.parse('$raw').toLocal(); } catch (e) {
          debugPrint('[Schedule]   parse error: $e');
        }
      }
      if (dt != null && dt.isAfter(todayStart) && dt.isBefore(todayEnd)) {
        today.add(m);
        debugPrint('[Schedule]   → today (dt=$dt)');
      } else if (dt != null && dt.isAfter(todayEnd)) {
        upcoming.add(m);
        debugPrint('[Schedule]   → upcoming (dt=$dt)');
      } else {
        today.add(m);
        debugPrint('[Schedule]   → today-fallback (no/past date dt=$dt)');
      }
    }
    debugPrint('[Schedule] live=${live.length} today=${today.length} upcoming=${upcoming.length} completed=${completed.length}');

    today.sort((a, b) => _dt(a).compareTo(_dt(b)));
    upcoming.sort((a, b) => _dt(a).compareTo(_dt(b)));
    completed.sort((a, b) => _dt(b).compareTo(_dt(a)));

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 48),
        children: [
          if (live.isNotEmpty) ...[
            _ScheduleSectionHeader(label: 'Live', count: live.length, color: context.success),
            ...live.map((m) {
              final id = '${m['id'] ?? ''}';
              final cb = onStartMatch != null ? () {
                debugPrint('[Schedule] Resume tapped id=$id teamAId=${m['teamAId']} teamBId=${m['teamBId']}');
                onStartMatch!(m);
              } : null;
              return _TournamentMatchRow(
                match: m,
                onTap: cb,
                actionLabel: 'Resume',
                actionColor: context.success,
                onAction: cb,
              );
            }),
          ],
          if (today.isNotEmpty) ...[
            _ScheduleSectionHeader(label: 'Today', count: today.length, color: context.accent),
            ...today.map((m) {
              final id = '${m['id'] ?? ''}';
              final cb = onStartMatch != null ? () {
                debugPrint('[Schedule] Start tapped id=$id teamAId=${m['teamAId']} teamBId=${m['teamBId']}');
                onStartMatch!(m);
              } : null;
              return _TournamentMatchRow(
                match: m,
                onTap: cb,
                actionLabel: 'Start',
                actionColor: context.accent,
                onAction: cb,
              );
            }),
          ],
          if (upcoming.isNotEmpty) ...[
            _ScheduleSectionHeader(label: 'Upcoming', count: upcoming.length, color: context.fgSub),
            ...upcoming.map((m) {
              final id = '${m['id'] ?? ''}';
              final cb = onStartMatch != null ? () {
                debugPrint('[Schedule] Start tapped id=$id teamAId=${m['teamAId']} teamBId=${m['teamBId']}');
                onStartMatch!(m);
              } : null;
              return _TournamentMatchRow(
                match: m,
                onTap: cb,
                actionLabel: 'Start',
                actionColor: context.accent,
                onAction: cb,
              );
            }),
          ],
          if (completed.isNotEmpty) ...[
            _ScheduleSectionHeader(label: 'Completed', count: completed.length, color: context.fgSub),
            ...completed.map((m) {
              final id = '${m['id'] ?? ''}';
              return _TournamentMatchRow(
                match: m,
                onTap: onNavigateToMatch != null ? () {
                  debugPrint('[Schedule] Completed tap id=$id');
                  onNavigateToMatch!(id);
                } : null,
              );
            }),
          ],
        ],
      ),
    );
  }

  DateTime _dt(Map<String, dynamic> m) {
    try { return DateTime.parse('${m['scheduledAt']}').toLocal(); } catch (_) { return DateTime(2099); }
  }
}

class _ScheduleSectionHeader extends StatelessWidget {
  const _ScheduleSectionHeader({required this.label, required this.count, required this.color});
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(children: [
        Container(width: 3, height: 14, color: color),
        const SizedBox(width: 8),
        Text(label.toUpperCase(),
            style: TextStyle(
                color: context.fg, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6)),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4)),
          child: Text('$count',
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}

class _TournamentMatchRow extends StatelessWidget {
  const _TournamentMatchRow({
    required this.match,
    this.onTap,
    this.onAction,
    this.actionLabel,
    this.actionColor,
  });
  final Map<String, dynamic> match;
  final VoidCallback? onTap;
  final VoidCallback? onAction;
  final String? actionLabel;
  final Color? actionColor;

  @override
  Widget build(BuildContext context) {
    final teamA = '${match['teamAName'] ?? 'TBD'}';
    final teamB = '${match['teamBName'] ?? 'TBD'}';
    final status = '${match['status'] ?? 'SCHEDULED'}'.toUpperCase();
    final round = '${match['round'] ?? ''}';
    final isLive = status == 'IN_PROGRESS' || status == 'TOSS_DONE';
    final isCompleted = status == 'COMPLETED';

    String? dateStr;
    final raw = match['scheduledAt'];
    if (raw != null) {
      try {
        dateStr = DateFormat('EEE, d MMM · HH:mm')
            .format(DateTime.parse('$raw').toLocal());
      } catch (_) {}
    }

    Color statusColor = context.fgSub;
    String statusLabel = 'Scheduled';
    if (isLive) { statusColor = context.success; statusLabel = 'Live'; }
    if (isCompleted) { statusColor = context.fgSub; statusLabel = 'Done'; }

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: ColoredBox(
          color: context.bg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                if (round.isNotEmpty)
                  Text(round,
                      style: TextStyle(
                          color: context.fgSub,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                const Spacer(),
                if (isLive) ...[
                  Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(color: context.success, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                ],
                Text(statusLabel,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4)),
                if (onTap != null && !isCompleted) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right_rounded, size: 16, color: context.accent),
                ],
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                    child: Text(teamA,
                        style: TextStyle(
                            color: context.fg,
                            fontWeight: FontWeight.w700,
                            fontSize: 14),
                        overflow: TextOverflow.ellipsis)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('vs',
                      style: TextStyle(
                          color: context.fgSub,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ),
                Expanded(
                    child: Text(teamB,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            color: context.fg,
                            fontWeight: FontWeight.w700,
                            fontSize: 14),
                        overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (dateStr != null)
                    Text(dateStr,
                        style: TextStyle(color: context.fgSub, fontSize: 11))
                  else
                    const SizedBox.shrink(),
                  if (onAction != null)
                    GestureDetector(
                      onTap: onAction,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: actionColor ?? context.accent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          actionLabel ?? 'Start',
                          style: TextStyle(
                            color: context.bg,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Divider(height: 1, color: context.stroke.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 6 — Points Table
// ---------------------------------------------------------------------------

class _PointsTableTab extends StatefulWidget {
  const _PointsTableTab({
    required this.standings,
    required this.canManage,
    required this.isBusy,
    required this.onRefresh,
    required this.onRecalculate,
  });

  final Map<String, List<Map<String, dynamic>>> standings;
  final bool canManage;
  final bool isBusy;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onRecalculate;

  @override
  State<_PointsTableTab> createState() => _PointsTableTabState();
}

class _PointsTableTabState extends State<_PointsTableTab> {
  String? _selectedGroup;

  @override
  void didUpdateWidget(_PointsTableTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedGroup != null &&
        !widget.standings.containsKey(_selectedGroup)) {
      _selectedGroup = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = widget.standings.keys.toList();

    if (groups.isEmpty) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: ListView(
          children: [
            const SizedBox(height: 80),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No standings data yet. Play some matches first.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: context.fgSub, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final activeGroup = _selectedGroup ?? groups.first;
    final rows = List<Map<String, dynamic>>.from(
        widget.standings[activeGroup] ?? [])
      ..sort((a, b) {
        final pa = (a['points'] as num?)?.toDouble() ?? 0.0;
        final pb = (b['points'] as num?)?.toDouble() ?? 0.0;
        if (pb != pa) return pb.compareTo(pa);
        final na = (a['nrr'] as num?)?.toDouble() ?? 0.0;
        final nb = (b['nrr'] as num?)?.toDouble() ?? 0.0;
        return nb.compareTo(na);
      });

    final qualifyingCount = _qualifyingCount(rows.length);

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: Column(
        children: [
          // Group selector
          if (groups.length > 1) ...[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: groups.map((g) {
                    final isSelected = g == activeGroup;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _RoundChip(
                        label: g == 'overall' ? 'Overall' : g,
                        selected: isSelected,
                        onTap: () =>
                            setState(() => _selectedGroup = g),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Divider(height: 1, color: context.stroke),
          ],

          // Table header
          ColoredBox(
            color: context.panel,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text('#',
                        style: TextStyle(
                            color: context.fgSub,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Team',
                        style: TextStyle(
                            color: context.fgSub,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ),
                  ...[
                    ('M', 24.0),
                    ('W', 24.0),
                    ('L', 24.0),
                    ('NR', 28.0),
                    ('Pts', 32.0),
                    ('NRR', 48.0),
                  ].map(
                    (col) => SizedBox(
                      width: col.$2,
                      child: Text(
                        col.$1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: context.fgSub,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: context.stroke),

          // Table rows
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 32),
              itemCount: rows.length + 1, // +1 for recalculate button
              itemBuilder: (context, index) {
                if (index == rows.length) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: context.stroke),
                        foregroundColor: context.fgSub,
                      ),
                      onPressed: widget.isBusy
                          ? null
                          : widget.onRecalculate,
                      child: widget.isBusy
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: context.fgSub,
                              ),
                            )
                          : const Text('Recalculate Standings'),
                    ),
                  );
                }

                final row = rows[index];
                final isQualifying = index < qualifyingCount;
                final nrr =
                    (row['nrr'] as num?)?.toDouble() ?? 0.0;
                final nrrStr =
                    nrr >= 0 ? '+${nrr.toStringAsFixed(3)}' : nrr.toStringAsFixed(3);
                final nrrColor =
                    nrr >= 0 ? context.success : context.danger;

                return Column(
                  children: [
                    ColoredBox(
                      color: isQualifying
                          ? context.success.withValues(alpha: 0.06)
                          : context.bg,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: context.fgSub,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _TeamAvatar(
                              name: '${row['teamName'] ?? '?'}',
                              logoUrl:
                                  '${row['teamLogoUrl'] ?? ''}',
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${row['teamName'] ?? '-'}',
                                style: TextStyle(
                                  color: context.fg,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            ...[
                              row['matchesPlayed'],
                              row['wins'],
                              row['losses'],
                              row['noResults'],
                              row['points'],
                            ].map((v) {
                              final width = v == row['noResults']
                                  ? 28.0
                                  : v == row['points']
                                      ? 32.0
                                      : 24.0;
                              return SizedBox(
                                width: width,
                                child: Text(
                                  '${v ?? 0}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: context.fg,
                                    fontSize: 13,
                                  ),
                                ),
                              );
                            }),
                            SizedBox(
                              width: 48,
                              child: Text(
                                nrrStr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: nrrColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Qualification line divider
                    if (index == qualifyingCount - 1 &&
                        qualifyingCount < rows.length) ...[
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Divider(
                            height: 1,
                            color: context.accent
                                .withValues(alpha: 0.4),
                            indent: 0,
                            endIndent: 0,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            color: context.bg,
                            child: Text(
                              'Qualification line',
                              style: TextStyle(
                                color: context.fgSub,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else
                      Divider(
                          height: 1,
                          indent: 56,
                          color: context.stroke),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int _qualifyingCount(int total) {
    if (total <= 0) return 0;
    if (total <= 4) return (total / 2).ceil();
    if (total <= 8) return 4;
    return (total * 0.5).floor();
  }
}

// ---------------------------------------------------------------------------
// Tab 5 — Settings
// ---------------------------------------------------------------------------

class _SettingsTab extends StatefulWidget {
  const _SettingsTab({
    required this.tournament,
    required this.groups,
    required this.canManage,
    required this.isBusy,
    required this.nameController,
    required this.organiserNameController,
    required this.organiserPhoneController,
    required this.descriptionController,
    required this.maxTeamsController,
    required this.entryFeeController,
    required this.prizePoolController,
    required this.isPublic,
    required this.onIsPublicChanged,
    required this.onSave,
    required this.onCreateGroups,
    required this.onAutoAssign,
    required this.onDeleteTournament,
    required this.tournamentId,
  });

  final Map<String, dynamic> tournament;
  final List<Map<String, dynamic>> groups;
  final bool canManage;
  final bool isBusy;
  final TextEditingController nameController;
  final TextEditingController organiserNameController;
  final TextEditingController organiserPhoneController;
  final TextEditingController descriptionController;
  final TextEditingController maxTeamsController;
  final TextEditingController entryFeeController;
  final TextEditingController prizePoolController;
  final bool isPublic;
  final ValueChanged<bool> onIsPublicChanged;
  final VoidCallback onSave;
  final Future<void> Function() onCreateGroups;
  final Future<void> Function() onAutoAssign;
  final VoidCallback onDeleteTournament;
  final String tournamentId;

  @override
  State<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<_SettingsTab> {
  final _deleteConfirmController = TextEditingController();
  bool _deleteEnabled = false;

  @override
  void initState() {
    super.initState();
    _deleteConfirmController.addListener(() {
      final name = '${widget.tournament['name'] ?? ''}';
      setState(() =>
          _deleteEnabled = _deleteConfirmController.text.trim() == name);
    });
  }

  @override
  void dispose() {
    _deleteConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 48),
      children: [
        // ── Edit section ──────────────────────────────────────────────────
        _SectionHeader(title: 'TOURNAMENT DETAILS'),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _SettingsField(
                label: 'Tournament name',
                controller: widget.nameController,
              ),
              const SizedBox(height: 12),
              _SettingsField(
                label: 'Organiser name',
                controller: widget.organiserNameController,
              ),
              const SizedBox(height: 12),
              _SettingsField(
                label: 'Organiser phone',
                controller: widget.organiserPhoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _SettingsField(
                label: 'Description',
                controller: widget.descriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              _SettingsField(
                label: 'Max teams',
                controller: widget.maxTeamsController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              _SettingsField(
                label: 'Entry fee',
                controller: widget.entryFeeController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              _SettingsField(
                label: 'Prize pool',
                controller: widget.prizePoolController,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Public tournament',
                      style: TextStyle(color: context.fg, fontSize: 14),
                    ),
                  ),
                  Switch(
                    value: widget.isPublic,
                    onChanged: widget.onIsPublicChanged,
                    activeThumbColor: context.accent,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: context.accent,
                  foregroundColor: context.bg,
                  minimumSize: const Size(double.infinity, 44),
                ),
                onPressed: widget.isBusy ? null : widget.onSave,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        Divider(height: 1, color: context.stroke),

        // ── Groups section ─────────────────────────────────────────────────
        if (widget.canManage) ...[
          const SizedBox(height: 8),
          _SectionHeader(title: 'GROUPS'),
          if (widget.groups.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                'No groups created yet.',
                style: TextStyle(color: context.fgSub, fontSize: 13),
              ),
            )
          else
            ...widget.groups.map((g) {
              final teams = (g['teams'] as List?)?.length ?? 0;
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Icon(Icons.group_work_outlined,
                        size: 18, color: context.fgSub),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${g['name'] ?? 'Group'}',
                        style: TextStyle(
                            color: context.fg, fontSize: 14),
                      ),
                    ),
                    Text(
                      '$teams team${teams == 1 ? '' : 's'}',
                      style: TextStyle(
                          color: context.fgSub, fontSize: 12),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: context.accent),
                    foregroundColor: context.accent,
                    minimumSize: const Size(double.infinity, 44),
                  ),
                  onPressed: widget.isBusy ? null : widget.onCreateGroups,
                  icon: const Icon(Icons.add_circle_outline, size: 16),
                  label: const Text('Create Groups'),
                ),
                if (widget.groups.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: context.stroke),
                      foregroundColor: context.fgSub,
                      minimumSize: const Size(double.infinity, 44),
                    ),
                    onPressed:
                        widget.isBusy ? null : widget.onAutoAssign,
                    icon: const Icon(Icons.shuffle_rounded, size: 16),
                    label: const Text('Auto-assign teams'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Divider(height: 1, color: context.stroke),
        ],

        // ── Danger zone ────────────────────────────────────────────────────
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
            'DANGER ZONE',
            style: TextStyle(
              color: context.danger,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delete Tournament',
                style: TextStyle(
                  color: context.fg,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'This will permanently delete the tournament and all its data. Type the tournament name to confirm.',
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _deleteConfirmController,
                decoration: InputDecoration(
                  hintText: widget.tournament['name'] ?? 'Tournament name',
                  hintStyle:
                      TextStyle(color: context.fgSub.withValues(alpha: 0.5)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: context.stroke),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: context.stroke),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: context.danger),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                ),
                style: TextStyle(color: context.fg, fontSize: 14),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: _deleteEnabled
                          ? context.danger
                          : context.danger.withValues(alpha: 0.4)),
                  foregroundColor: context.danger,
                  minimumSize: const Size(double.infinity, 44),
                ),
                onPressed: _deleteEnabled
                    ? () {
                        _deleteConfirmController.clear();
                        widget.onDeleteTournament();
                      }
                    : null,
                child: const Text('Delete Tournament'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Add Team Sheet
// ---------------------------------------------------------------------------

class _AddTeamResult {
  const _AddTeamResult({required this.teamId, this.teamName});
  final String teamId;
  final String? teamName;
}

class _AddTeamSheet extends ConsumerStatefulWidget {
  const _AddTeamSheet({this.scrollController, this.existingIds = const {}});
  final ScrollController? scrollController;
  final Set<String> existingIds;

  @override
  ConsumerState<_AddTeamSheet> createState() => _AddTeamSheetState();
}

class _AddTeamSheetState extends ConsumerState<_AddTeamSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _searchCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  Timer? _debounce;
  List<Map<String, dynamic>> _results = const [];
  bool _searching = false;
  String? _searchError;
  final Set<String> _selectedIds = {};
  final Map<String, String> _selectedNames = {};

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchCtrl.dispose();
    _idCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), () => _runSearch(q));
  }

  Future<void> _runSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() { _results = const []; _searching = false; _searchError = null; });
      return;
    }
    setState(() { _searching = true; _searchError = null; });
    try {
      final rows = await ref.read(hostTeamRepositoryProvider).searchTeams(q);
      if (!mounted) return;
      setState(() { _results = rows; _searching = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _searching = false; _searchError = e.toString(); });
    }
  }

  void _toggleTeam(Map<String, dynamic> team) {
    final id = '${team['id'] ?? ''}';
    if (id.isEmpty || widget.existingIds.contains(id)) return;
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        _selectedNames.remove(id);
      } else {
        _selectedIds.add(id);
        _selectedNames[id] = '${team['name'] ?? team['teamName'] ?? ''}';
      }
    });
  }

  void _confirmSelection() {
    if (_selectedIds.isEmpty) return;
    final results = _selectedIds
        .map((id) => _AddTeamResult(teamId: id, teamName: _selectedNames[id]))
        .toList();
    Navigator.of(context).pop(results);
  }

  void _addById() {
    final id = _idCtrl.text.trim();
    if (id.isEmpty) return;
    Navigator.of(context).pop([_AddTeamResult(teamId: id)]);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: bottomPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Drag handle ──────────────────────────────────────────────────
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.stroke,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 16, 0),
            child: Row(
              children: [
                Text(
                  'Add Team',
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close_rounded, color: context.fgSub, size: 20),
                ),
              ],
            ),
          ),

          // ── Tabs ─────────────────────────────────────────────────────────
          TabBar(
            controller: _tabs,
            indicatorColor: context.accent,
            indicatorWeight: 2,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: context.stroke,
            labelColor: context.fg,
            unselectedLabelColor: context.fgSub,
            labelPadding: const EdgeInsets.symmetric(horizontal: 20),
            labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            tabs: const [
              Tab(text: 'Search'),
              Tab(text: 'Team ID'),
            ],
          ),

          // ── Tab content ──────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _buildSearchTab(context),
                _buildIdTab(context),
              ],
            ),
          ),

          // ── Confirm multi-select ─────────────────────────────────────────
          if (_selectedIds.isNotEmpty)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: context.accent,
                      foregroundColor: context.ctaFg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _confirmSelection,
                    icon: const Icon(Icons.group_add_rounded, size: 18),
                    label: Text(
                      'Add ${_selectedIds.length} Team${_selectedIds.length == 1 ? '' : 's'}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchTab(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: context.fgSub, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  onChanged: _onSearchChanged,
                  cursorColor: context.accent,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by name or city…',
                    hintStyle: TextStyle(color: context.fgSub, fontSize: 15),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (_searching)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: context.accent),
                )
              else if (_searchCtrl.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _searchCtrl.clear();
                    setState(() { _results = const []; _searchError = null; });
                  },
                  child: Icon(Icons.close_rounded, color: context.fgSub, size: 18),
                ),
            ],
          ),
        ),
        Divider(height: 1, color: context.stroke),
        const SizedBox(height: 10),

        // Results
        Expanded(child: _buildSearchResults(context)),
      ],
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    if (_searchError != null) {
      return _SheetState(
        icon: Icons.error_outline_rounded,
        iconColor: context.danger,
        title: 'Search failed',
        subtitle: _searchError,
        action: OutlinedButton(
          onPressed: () => _runSearch(_searchCtrl.text),
          child: const Text('Retry'),
        ),
      );
    }
    if (_searchCtrl.text.trim().isEmpty) {
      return _SheetState(
        icon: Icons.groups_rounded,
        title: 'Search teams',
        subtitle: 'Type a team name or city to find teams from across Swing',
      );
    }
    if (!_searching && _results.isEmpty) {
      return _SheetState(
        icon: Icons.search_off_rounded,
        title: 'No results',
        subtitle: 'No teams matched "${_searchCtrl.text.trim()}"',
      );
    }

    return ListView.separated(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 1),
      itemBuilder: (_, i) {
        final team = _results[i];
        final id = '${team['id'] ?? ''}';
        final alreadyAdded = widget.existingIds.contains(id);
        return _TeamRow(
          team: team,
          isSelected: _selectedIds.contains(id),
          isAlreadyAdded: alreadyAdded,
          onTap: alreadyAdded ? null : () => _toggleTeam(team),
        );
      },
    );
  }

  Widget _buildIdTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Team ID',
            style: TextStyle(
              color: context.fg,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Paste the team\'s unique ID. You can find this in the team\'s profile page.',
            style: TextStyle(color: context.fgSub, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _idCtrl,
            onChanged: (_) => setState(() {}),
            style: TextStyle(
              color: context.fg,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'monospace',
            ),
            decoration: InputDecoration(
              hintText: 'e.g. cmofs0cmb000ypy4a…',
              hintStyle: TextStyle(color: context.fgSub, fontSize: 13),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              suffixIcon: _idCtrl.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _idCtrl.clear();
                        setState(() {});
                      },
                      child: Icon(Icons.close_rounded, color: context.fgSub, size: 18),
                    )
                  : null,
            ),
          ),
          Divider(height: 1, color: context.stroke),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: _idCtrl.text.trim().isEmpty
                    ? context.stroke
                    : context.accent,
                foregroundColor: _idCtrl.text.trim().isEmpty
                    ? context.fgSub
                    : context.ctaFg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _idCtrl.text.trim().isEmpty ? null : _addById,
              icon: const Icon(Icons.group_add_rounded, size: 18),
              label: const Text(
                'Add Team',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Team row (used in Add Team Sheet) ─────────────────────────────────────────

class _TeamRow extends StatelessWidget {
  const _TeamRow({
    required this.team,
    this.onTap,
    this.isSelected = false,
    this.isAlreadyAdded = false,
  });
  final Map<String, dynamic> team;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isAlreadyAdded;

  @override
  Widget build(BuildContext context) {
    final name = '${team['name'] ?? team['teamName'] ?? 'Unnamed Team'}';
    final shortName = '${team['shortName'] ?? ''}'.trim();
    final city = '${team['city'] ?? ''}'.trim();
    final teamType = '${team['teamType'] ?? ''}'.trim();
    final logo = '${team['logoUrl'] ?? ''}'.trim();
    final memberCount = team['memberCount'];

    return InkWell(
      onTap: isAlreadyAdded ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            _TeamLogoAvatar(name: name, logoUrl: logo.isEmpty ? null : logo),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 3,
                    children: [
                      if (shortName.isNotEmpty) _MiniChip(label: shortName),
                      if (city.isNotEmpty)
                        _MiniChip(label: city, icon: Icons.location_on_rounded),
                      if (teamType.isNotEmpty)
                        _MiniChip(label: _ttLabel(teamType)),
                      if (memberCount != null && memberCount > 0)
                        _MiniChip(
                          label: '$memberCount players',
                          icon: Icons.person_rounded,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isAlreadyAdded)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: context.stroke.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Added',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isSelected ? context.accent : context.accentBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isSelected ? Icons.check_rounded : Icons.add_rounded,
                  color: isSelected ? context.ctaFg : context.accent,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _ttLabel(String t) => switch (t.toUpperCase()) {
    'CLUB' => 'Club', 'CORPORATE' => 'Corporate', 'ACADEMY' => 'Academy',
    'SCHOOL' => 'School', 'COLLEGE' => 'College', 'DISTRICT' => 'District',
    'GULLY' => 'Gully', 'FRIENDLY' => 'Friendly', _ => t,
  };
}

class _TeamLogoAvatar extends StatelessWidget {
  const _TeamLogoAvatar({required this.name, this.logoUrl});
  final String name;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(name);
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: context.accentBg,
        borderRadius: BorderRadius.circular(12),
        image: logoUrl != null
            ? DecorationImage(
                image: NetworkImage(logoUrl!),
                fit: BoxFit.cover,
                onError: (_, __) {},
              )
            : null,
      ),
      child: logoUrl == null
          ? Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: context.accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          : null,
    );
  }

  String _initials(String v) {
    final p = v.trim().split(RegExp(r'\s+'));
    if (p.isEmpty) return '?';
    if (p.length == 1) return p.first.characters.first.toUpperCase();
    return '${p.first.characters.first}${p.last.characters.first}'.toUpperCase();
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, this.icon});
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: context.panel,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: context.fgSub),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetState extends StatelessWidget {
  const _SheetState({
    required this.icon,
    required this.title,
    this.iconColor,
    this.subtitle,
    this.action,
  });
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: iconColor ?? context.fgSub),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                color: context.fg,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: TextStyle(color: context.fgSub, fontSize: 13, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helper widgets
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.count});

  final String title;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: context.accentBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: context.accent,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RoundChip extends StatelessWidget {
  const _RoundChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? context.accent : context.panel,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? context.bg : context.fgSub,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.panel,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                color: context.fg,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: context.fgSub,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
      case 'ONGOING':
      case 'IN_PROGRESS':
        return ('Ongoing', context.success);
      case 'LIVE':
        return ('Live', context.success);
      case 'COMPLETED':
        return ('Completed', context.fgSub);
      case 'DRAFT':
        return ('Draft', context.gold);
      case 'CANCELLED':
        return ('Cancelled', context.danger);
      default:
        return (status, context.warn);
    }
  }
}

class _TeamAvatar extends StatelessWidget {
  const _TeamAvatar({
    required this.name,
    this.logoUrl,
    this.size = 40,
  });

  final String name;
  final String? logoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final letter =
        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    final hasLogo = (logoUrl ?? '').isNotEmpty;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.accentBg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      child: hasLogo
          ? Image.network(
              logoUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Text(
                letter,
                style: TextStyle(
                  color: context.accent,
                  fontWeight: FontWeight.w700,
                  fontSize: size * 0.42,
                ),
              ),
            )
          : Text(
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

class _SettingsField extends StatelessWidget {
  const _SettingsField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(color: context.fg, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: context.fgSub, fontSize: 13),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: context.stroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.accent),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
