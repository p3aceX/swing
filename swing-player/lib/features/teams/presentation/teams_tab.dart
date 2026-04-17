import "package:cached_network_image/cached_network_image.dart";
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../create_match/presentation/form_widgets.dart';
import '../controller/teams_controller.dart';
import '../domain/team_models.dart';

class TeamsTab extends ConsumerWidget {
  const TeamsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Squads',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                _CreateTeamButton(
                  onTap: () => context.push('/create-team'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: context.stroke),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: context.accentBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: context.accent,
                unselectedLabelColor: context.fgSub,
                labelStyle: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
                unselectedLabelStyle: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
                tabs: const [
                  Tab(text: 'My Squads'),
                  Tab(text: 'Playing For'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Expanded(
              child: TabBarView(
                children: [
                  _TeamsList(section: _TeamsSection.mySquads),
                  _TeamsList(section: _TeamsSection.playingFor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _TeamsSection { mySquads, playingFor }

// ── Create team button ────────────────────────────────────────────────────────

class _CreateTeamButton extends StatelessWidget {
  const _CreateTeamButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: context.accentBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.accent.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: context.accent, size: 18),
            const SizedBox(width: 6),
            Text(
              'New Squad',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: context.accent,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Teams list ────────────────────────────────────────────────────────────────

class _TeamsList extends ConsumerWidget {
  const _TeamsList({required this.section});
  final _TeamsSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teamsControllerProvider);
    final controller = ref.read(teamsControllerProvider.notifier);

    final teams =
        section == _TeamsSection.mySquads ? state.mySquads : state.playingFor;

    if (state.isLoading && state.teams.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.teams.isEmpty) {
      return _TeamFeedback(
        icon: Icons.wifi_off_rounded,
        title: 'Could not load squads',
        message: state.error!,
        actionLabel: 'Retry',
        onPressed: controller.load,
      );
    }

    if (teams.isEmpty) {
      final isMySquads = section == _TeamsSection.mySquads;
      return RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.12),
            _TeamFeedback(
              icon: isMySquads
                  ? Icons.shield_outlined
                  : Icons.people_outline_rounded,
              title: isMySquads ? 'No squads yet' : 'Not in any teams',
              message: isMySquads
                  ? 'Create your first squad and manage every role from there.'
                  : 'You\'re not listed in any team yet.\nAsk a team owner to add you.',
              actionLabel: isMySquads ? 'Create Squad' : 'Refresh',
              onPressed: isMySquads
                  ? () => context.push('/create-team')
                  : controller.refresh,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: teams.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _TeamListCard(team: teams[index]),
      ),
    );
  }
}

// ── Team list card ────────────────────────────────────────────────────────────

class _TeamListCard extends StatelessWidget {
  const _TeamListCard({required this.team});

  final PlayerTeam team;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/team/${team.id}', extra: team),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.stroke),
        ),
        child: Row(
          children: [
            _TeamLogo(team: team),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (team.shortName != null) team.shortName,
                      if (team.city != null) team.city,
                      if (team.teamType != null) team.teamType,
                    ].whereType<String>().join(' · '),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: context.fgSub),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${team.members.length} ${team.members.length == 1 ? 'member' : 'members'}',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: context.fgSub),
                ),
                const SizedBox(height: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.fgSub,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Legacy accordion card (unused) ───────────────────────────────────────────

class _TeamCard extends StatefulWidget {
  const _TeamCard({required this.team});
  final PlayerTeam team;

  @override
  State<_TeamCard> createState() => _TeamCardState();
}

class _TeamCardState extends State<_TeamCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  void _toggle() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    final team = widget.team;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _expanded
              ? context.accent.withValues(alpha: 0.4)
              : context.stroke,
          width: _expanded ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // ── Header (always visible, tappable) ───────────────────────────
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(
                children: [
                  _TeamLogo(team: team),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                team.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [
                            if (team.shortName != null) team.shortName,
                            if (team.city != null) team.city,
                            if (team.teamType != null) team.teamType,
                          ].whereType<String>().join(' · '),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: context.fgSub),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Member count + chevron
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${team.members.length} ${team.members.length == 1 ? 'member' : 'members'}',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: context.fgSub),
                      ),
                      const SizedBox(height: 4),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(Icons.keyboard_arrow_down_rounded,
                            color: context.fgSub, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded members section ─────────────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Divider(color: context.stroke, height: 1, thickness: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Members',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          Text(
                            '${team.members.length}',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: context.fgSub),
                          ),
                        ],
                      ),
                      if (team.isOwner) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _OwnerActionButton(
                                icon: Icons.person_add_alt_1_rounded,
                                label: 'Add Player',
                                onTap: () => showModalBottomSheet<void>(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => _AddPlayerSheet(team: team),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _OwnerActionButton(
                                icon: Icons.delete_outline_rounded,
                                label: 'Delete Team',
                                isDanger: true,
                                onTap: () => _confirmDeleteTeam(context, team),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      if (team.members.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'No members added yet.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: context.fgSub),
                          ),
                        )
                      else
                        ...team.members.map((m) => _TeamMemberRow(member: m)),
                    ],
                  ),
                ),
              ],
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteTeam(BuildContext context, PlayerTeam team) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete team?'),
        content: Text(
          'Delete "${team.name}" permanently? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final container = ProviderScope.containerOf(context, listen: false);
    final ok = await container
        .read(teamsControllerProvider.notifier)
        .deleteTeam(team.id);
    if (!context.mounted) return;

    final message = ok
        ? 'Team deleted'
        : container.read(teamsControllerProvider).error ??
            'Could not delete team';
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _OwnerActionButton extends StatelessWidget {
  const _OwnerActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDanger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final fg = isDanger ? context.danger : context.accent;
    final bg =
        isDanger ? context.danger.withValues(alpha: 0.08) : context.accentBg;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: fg.withValues(alpha: 0.22)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: fg, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPlayerSheet extends ConsumerStatefulWidget {
  const _AddPlayerSheet({required this.team});

  final PlayerTeam team;

  @override
  ConsumerState<_AddPlayerSheet> createState() => _AddPlayerSheetState();
}

class _AddPlayerSheetState extends ConsumerState<_AddPlayerSheet> {
  final _controller = TextEditingController();
  List<TeamPlayerSearchResult> _results = const [];
  bool _isSearching = false;
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.length < 2) {
      setState(() {
        _results = const [];
        _error = 'Enter at least 2 characters';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _error = null;
    });
    final results =
        await ref.read(teamsControllerProvider.notifier).searchPlayers(query);
    if (!mounted) return;
    setState(() {
      _isSearching = false;
      _results = results
          .where(
            (player) =>
                !widget.team.members.any((m) => m.userId == player.userId),
          )
          .toList();
      if (_results.isEmpty) {
        _error = 'No players found';
      }
    });
  }

  Future<void> _addPlayer(TeamPlayerSearchResult player) async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    final ok = await ref.read(teamsControllerProvider.notifier).addPlayerToTeam(
          teamId: widget.team.id,
          playerIdOrUserId: player.userId,
        );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (ok) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${player.name} added to ${widget.team.name}')),
      );
      return;
    }
    setState(() {
      _error =
          ref.read(teamsControllerProvider).error ?? 'Could not add player';
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(top: 80, bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: context.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: context.stroke,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Add Player',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Search by player name or phone number.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: context.fgSub),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SwingTextField(
                        controller: _controller,
                        hint: 'Search player',
                        prefixIcon: Icons.search_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _isSearching || _isSubmitting ? null : _search,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: context.accent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _isSearching
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.arrow_forward_rounded,
                                color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      _error!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: context.danger),
                    ),
                  ),
                Flexible(
                  child: _results.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'Search results will appear here.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: context.fgSub),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: _results.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final player = _results[index];
                            return _PlayerSearchTile(
                              player: player,
                              isSubmitting: _isSubmitting,
                              onAdd: () => _addPlayer(player),
                            );
                          },
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

class _PlayerSearchTile extends StatelessWidget {
  const _PlayerSearchTile({
    required this.player,
    required this.isSubmitting,
    required this.onAdd,
  });

  final TeamPlayerSearchResult player;
  final bool isSubmitting;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.stroke),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: context.accentBg,
            backgroundImage: player.avatarUrl != null
                ? CachedNetworkImageProvider(player.avatarUrl!)
                : null,
            child: player.avatarUrl == null
                ? Text(
                    player.name.isEmpty ? '?' : player.name[0].toUpperCase(),
                    style: TextStyle(
                      color: context.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  [
                    if (player.phone != null) player.phone,
                    if (player.playerRole != null) player.playerRole,
                    if (player.playerLevel != null) player.playerLevel,
                  ].whereType<String>().join(' • '),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: context.fgSub),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: isSubmitting ? null : onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: context.accentBg,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: context.accent.withValues(alpha: 0.2)),
              ),
              child: isSubmitting
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.accent,
                      ),
                    )
                  : Text(
                      'Add',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: context.accent,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Team logo ─────────────────────────────────────────────────────────────────

class _TeamLogo extends StatelessWidget {
  const _TeamLogo({required this.team});
  final PlayerTeam team;

  @override
  Widget build(BuildContext context) {
    final initialsSource =
        team.shortName?.trim().isNotEmpty == true ? team.shortName! : team.name;
    final initials = initialsSource.length >= 2
        ? initialsSource.substring(0, 2).toUpperCase()
        : initialsSource.toUpperCase();

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: context.accentBg,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: team.logoUrl != null
          ? Image.network(
              team.logoUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Text(initials,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: context.accent,
                          fontWeight: FontWeight.w800,
                        )),
              ),
            )
          : Center(
              child: Text(initials,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context.accent,
                        fontWeight: FontWeight.w800,
                      )),
            ),
    );
  }
}

// ── Team member row ───────────────────────────────────────────────────────────

class _TeamMemberRow extends StatelessWidget {
  const _TeamMemberRow({required this.member});
  final TeamMember member;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.panel,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: context.accentBg,
              backgroundImage: member.avatarUrl != null
                  ? CachedNetworkImageProvider(member.avatarUrl!)
                  : null,
              child: member.avatarUrl == null
                  ? Text(
                      member.name.isEmpty ? '?' : member.name[0].toUpperCase(),
                      style: TextStyle(
                          color: context.accent, fontWeight: FontWeight.w700),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        member.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: context.fg,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      ...member.roles.map((r) => _RoleChip(label: r)),
                    ],
                  ),
                  if (member.battingStyle != null ||
                      member.bowlingStyle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        [
                          if (member.battingStyle != null) member.battingStyle,
                          if (member.bowlingStyle != null) member.bowlingStyle,
                        ].whereType<String>().join(' • '),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: context.fgSub),
                      ),
                    ),
                ],
              ),
            ),
            if (member.swingIndex != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  member.swingIndex!.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: context.fg,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Role chip ─────────────────────────────────────────────────────────────────

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.accentBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: context.accent,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

// ── Feedback / empty state ────────────────────────────────────────────────────

class _TeamFeedback extends StatelessWidget {
  const _TeamFeedback({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: context.stroke),
            ),
            child: Icon(icon, color: context.fgSub, size: 34),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: context.fgSub),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: context.accent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
