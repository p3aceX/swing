import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    _tabController = TabController(length: 5, vsync: this);
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
      _showError(error.toString());
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
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
    Map<String, dynamic>? selected;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.84,
        child: TeamSearchSheet(
          title: 'Add Team to Tournament',
          onSelected: (team) {
            selected = team;
            Navigator.of(ctx).pop();
          },
        ),
      ),
    );
    if (selected == null || !mounted) return;
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
                    onChanged: (v) => setDialogState(() => autoAssign = v),
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
                        .map((v) => v.trim())
                        .where((v) => v.isNotEmpty)
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
                Tab(text: 'Fixtures'),
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
              label: const Text('Add team'),
              icon: const Icon(Icons.add),
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
                      _FixturesTab(
                        schedule: _schedule,
                        canManage: _canManage,
                        isBusy: _isBusy,
                        onRefresh: _reload,
                        onAutoGenerate: () => _runAction(
                            () => _repository
                                .autoGenerateSchedule(widget.tournamentId)),
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
                        onCreateGroups: _showCreateGroupDialog,
                        onAutoAssign: () => _runAction(() =>
                            _repository.createGroups(
                              widget.tournamentId,
                              groupNames:
                                  _groups.map((g) => '${g['name']}').toList(),
                              autoAssign: true,
                            )),
                        onDeleteTournament: () =>
                            _showSnack('Delete not yet supported'),
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
// Tab 3 — Fixtures
// ---------------------------------------------------------------------------

class _FixturesTab extends StatefulWidget {
  const _FixturesTab({
    required this.schedule,
    required this.canManage,
    required this.isBusy,
    required this.onRefresh,
    required this.onAutoGenerate,
    required this.onDeleteSchedule,
  });

  final List<Map<String, dynamic>> schedule;
  final bool canManage;
  final bool isBusy;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onAutoGenerate;
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
                    onAutoGenerate: widget.onAutoGenerate,
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
    required this.onAutoGenerate,
    required this.onDeleteSchedule,
  });

  final List<Map<String, dynamic>> schedule;
  final List<String> rounds;
  final String? selectedRound;
  final bool canManage;
  final bool isBusy;
  final Future<void> Function() onAutoGenerate;
  final Future<void> Function() onDeleteSchedule;

  @override
  Widget build(BuildContext context) {
    if (schedule.isEmpty && canManage) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ColoredBox(
            color: context.panel,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'No fixtures yet',
                      style:
                          TextStyle(color: context.fgSub, fontSize: 14),
                    ),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: context.accent,
                      foregroundColor: context.bg,
                    ),
                    onPressed: isBusy ? null : onAutoGenerate,
                    child: isBusy
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.bg,
                            ),
                          )
                        : const Text('Auto-generate'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (schedule.isEmpty) {
      return const Center(
        child: Text('No fixtures found.'),
      );
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
            ...matches.map((match) => _MatchCard(match: match)),
          ],
        );
      },
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match});

  final Map<String, dynamic> match;

  @override
  Widget build(BuildContext context) {
    final teamA = '${match['teamAName'] ?? 'TBD'}';
    final teamB = '${match['teamBName'] ?? 'TBD'}';
    final logoA = '${match['teamALogoUrl'] ?? ''}';
    final logoB = '${match['teamBLogoUrl'] ?? ''}';
    final status = '${match['status'] ?? 'SCHEDULED'}'.toUpperCase();
    final scheduledAt = match['scheduledAt'];
    final dateStr = _formatMatchDate(scheduledAt);
    final innings = (match['innings'] as List?)
            ?.whereType<Map>()
            .map((i) => Map<String, dynamic>.from(i))
            .toList() ??
        const [];

    final isCompleted = status == 'COMPLETED';
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
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  dateStr,
                  style: TextStyle(color: context.fgSub, fontSize: 12),
                ),
                const Spacer(),
                _MatchStatusPill(status: status),
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
// Tab 4 — Points Table
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
                    activeColor: context.accent,
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

class _MatchStatusPill extends StatelessWidget {
  const _MatchStatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'COMPLETED':
        color = context.fgSub;
        label = 'Done';
        break;
      case 'LIVE':
      case 'IN_PROGRESS':
        color = context.success;
        label = 'Live';
        break;
      case 'SCHEDULED':
        color = context.sky;
        label = 'Scheduled';
        break;
      default:
        color = context.fgSub;
        label = status.toLowerCase();
    }
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
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
// Utility functions
// ---------------------------------------------------------------------------

String _formatMatchDate(Object? value) {
  final parsed = DateTime.tryParse('${value ?? ''}');
  if (parsed == null) return 'Unscheduled';
  return DateFormat('d MMM, h:mm a').format(parsed.toLocal());
}
