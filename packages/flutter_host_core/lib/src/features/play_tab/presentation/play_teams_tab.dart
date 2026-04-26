import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/host_colors.dart';
import '../../my_teams/controller/my_teams_controller.dart';
import '../../my_teams/domain/my_teams_models.dart';
import 'play_tab.dart';

class PlayTeamsTab extends ConsumerStatefulWidget {
  const PlayTeamsTab({
    super.key,
    required this.callbacks,
    this.currentUserId,
  });

  final PlayTabCallbacks callbacks;
  final String? currentUserId;

  @override
  ConsumerState<PlayTeamsTab> createState() => _PlayTeamsTabState();
}

enum _TeamsFilter { all, owner, member }

class _PlayTeamsTabState extends ConsumerState<PlayTeamsTab> {
  _TeamsFilter _filter = _TeamsFilter.all;

  void _load() {
    ref
        .read(hostMyTeamsControllerProvider.notifier)
        .load(currentUserId: widget.currentUserId);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  @override
  void didUpdateWidget(PlayTeamsTab old) {
    super.didUpdateWidget(old);
    // Re-load when userId resolves (null → real ID) so isOwner is computed
    if (old.currentUserId != widget.currentUserId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _load();
      });
    }
  }

  List<HostMyTeam> _filtered(List<HostMyTeam> all) {
    return switch (_filter) {
      _TeamsFilter.all => all,
      _TeamsFilter.owner => all.where((t) => t.isOwner).toList(),
      _TeamsFilter.member => all.where((t) => !t.isOwner).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hostMyTeamsControllerProvider);
    final ctrl = ref.read(hostMyTeamsControllerProvider.notifier);
    final allTeams = state.data?.all ?? [];
    final visibleTeams = _filtered(allTeams);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ────────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'My Squads',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                ),
              ),
              _NewSquadButton(
                onTap: widget.callbacks.onCreateTeam != null
                    ? () => widget.callbacks.onCreateTeam!(context)
                    : null,
              ),
            ],
          ),
        ),

        // ── Filter pills ──────────────────────────────────────────────────────
        if (allTeams.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                _FilterPill(
                  label: 'All',
                  count: allTeams.length,
                  selected: _filter == _TeamsFilter.all,
                  onTap: () => setState(() => _filter = _TeamsFilter.all),
                ),
                const SizedBox(width: 8),
                _FilterPill(
                  label: 'Owner',
                  count: allTeams.where((t) => t.isOwner).length,
                  selected: _filter == _TeamsFilter.owner,
                  onTap: () => setState(() => _filter = _TeamsFilter.owner),
                ),
                const SizedBox(width: 8),
                _FilterPill(
                  label: 'Member',
                  count: allTeams.where((t) => !t.isOwner).length,
                  selected: _filter == _TeamsFilter.member,
                  onTap: () => setState(() => _filter = _TeamsFilter.member),
                ),
              ],
            ),
          ),

        Divider(height: 1, color: context.stroke),

        // ── Body ──────────────────────────────────────────────────────────────
        Expanded(child: _body(context, state, ctrl, visibleTeams, allTeams)),
      ],
    );
  }

  Widget _body(
    BuildContext context,
    HostMyTeamsState state,
    HostMyTeamsController ctrl,
    List<HostMyTeam> visibleTeams,
    List<HostMyTeam> allTeams,
  ) {
    if (state.isLoading && state.data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.data == null) {
      return Center(
        child: _EmptyState(
          icon: Icons.wifi_off_rounded,
          title: 'Could not load squads',
          body: state.error!,
          actionLabel: 'Retry',
          onAction: _load,
        ),
      );
    }

    if (allTeams.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => _load(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.1),
            _EmptyState(
              icon: Icons.shield_outlined,
              title: 'No squads yet',
              body: 'Create your first squad and invite players.',
              actionLabel: 'New Squad',
              onAction: widget.callbacks.onCreateTeam != null
                  ? () => widget.callbacks.onCreateTeam!(context)
                  : null,
            ),
          ],
        ),
      );
    }

    if (visibleTeams.isEmpty) {
      return Center(
        child: Text(
          'No ${_filter == _TeamsFilter.owner ? 'owned' : 'member'} squads',
          style: TextStyle(color: context.fgSub, fontSize: 14),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _load(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 40),
        itemCount: visibleTeams.length,
        itemBuilder: (context, i) {
          final team = visibleTeams[i];
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TeamRow(
                team: team,
                onTap: widget.callbacks.onNavigateToTeam != null
                    ? () => widget.callbacks.onNavigateToTeam!(
                        context, team.id, team.name)
                    : null,
              ),
              if (i < visibleTeams.length - 1)
                Divider(height: 1, indent: 76, color: context.stroke),
            ],
          );
        },
      ),
    );
  }
}

// ─── Filter pill ──────────────────────────────────────────────────────────────

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? context.accent : context.panel,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          count > 0 ? '$label  $count' : label,
          style: TextStyle(
            color: selected ? context.bg : context.fgSub,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─── New squad button ─────────────────────────────────────────────────────────

class _NewSquadButton extends StatelessWidget {
  const _NewSquadButton({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: context.accentBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: context.accent, size: 16),
            const SizedBox(width: 4),
            Text(
              'New Squad',
              style: TextStyle(
                color: context.accent,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Team row ─────────────────────────────────────────────────────────────────

class _TeamRow extends StatelessWidget {
  const _TeamRow({required this.team, this.onTap});
  final HostMyTeam team;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final meta = [
      if (team.city?.isNotEmpty == true) team.city!,
      if (team.teamType?.isNotEmpty == true) team.teamType!,
    ].join(' · ');

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            _TeamAvatar(team: team),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          team.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _RoleBadge(isOwner: team.isOwner),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    meta.isNotEmpty ? meta : '${team.playerCount} players',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: context.fgSub),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${team.playerCount}',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  team.playerCount == 1 ? 'player' : 'players',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: context.fgSub),
                ),
              ],
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: context.fgSub, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Team avatar ──────────────────────────────────────────────────────────────

class _TeamAvatar extends StatelessWidget {
  const _TeamAvatar({required this.team});
  final HostMyTeam team;

  @override
  Widget build(BuildContext context) {
    final src = team.shortName?.trim().isNotEmpty == true
        ? team.shortName!
        : team.name;
    final initials = src.length >= 2
        ? src.substring(0, 2).toUpperCase()
        : src.toUpperCase();

    Widget fallback = Center(
      child: Text(
        initials,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: context.accent,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
      ),
    );

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: context.accentBg,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: team.logoUrl != null
          ? Image.network(
              team.logoUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => fallback,
            )
          : fallback,
    );
  }
}

// ─── Role badge ───────────────────────────────────────────────────────────────

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.isOwner});
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isOwner ? context.accentBg : context.panel,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isOwner ? 'Owner' : 'Member',
        style: TextStyle(
          color: isOwner ? context.accent : context.fgSub,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: context.fgSub, size: 48),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
                color: context.fgSub, fontSize: 14, height: 1.5),
            textAlign: TextAlign.center,
          ),
          if (onAction != null) ...[
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onAction,
              child: Text(actionLabel),
            ),
          ],
        ],
      ),
    );
  }
}
