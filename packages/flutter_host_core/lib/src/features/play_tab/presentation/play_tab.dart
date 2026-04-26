import 'package:flutter/material.dart';

import '../../../theme/host_colors.dart';
import 'play_matches_tab.dart';
import 'play_teams_tab.dart';
import 'play_tournaments_tab.dart';

/// Callbacks passed from the host app to handle navigation.
class PlayTabCallbacks {
  const PlayTabCallbacks({
    this.onCreateTeam,
    this.onNavigateToTeam,
    this.onCreateMatch,
    this.onNavigateToMatch,
    this.onScoreMatch,
    this.onSetPlayingXI,
    this.onCreateTournament,
    this.onNavigateToTournament,
  });

  final void Function(BuildContext context)? onCreateTeam;
  final void Function(BuildContext context, String teamId, String teamName)?
      onNavigateToTeam;
  final void Function(BuildContext context)? onCreateMatch;
  final void Function(BuildContext context, String matchId)? onNavigateToMatch;
  final void Function(BuildContext context, String matchId)? onScoreMatch;

  /// Navigate to Playing XI setup for a hosted match that hasn't completed toss.
  /// [teamAName] and [teamBName] are used to pre-fill the team names.
  final void Function(
    BuildContext context,
    String matchId,
    String teamAName,
    String teamBName,
  )? onSetPlayingXI;

  final void Function(BuildContext context)? onCreateTournament;
  final void Function(
    BuildContext context,
    String tournamentId,
    String? slug,
    bool isHost,
  )? onNavigateToTournament;
}

class HostPlayTab extends StatefulWidget {
  const HostPlayTab({
    super.key,
    required this.callbacks,
    this.currentCity,
    this.currentUserId,
  });

  final PlayTabCallbacks callbacks;
  final String? currentCity;
  final String? currentUserId;

  @override
  State<HostPlayTab> createState() => _PlayTabState();
}

class _PlayTabState extends State<HostPlayTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Tab bar ─────────────────────────────────────────────────────────
        TabBar(
          controller: _tabController,
          indicatorColor: context.accent,
          indicatorWeight: 2,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
          labelColor: context.fg,
          unselectedLabelColor: context.fgSub,
          labelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.3,
          ),
          tabs: const [
            Tab(text: 'Matches'),
            Tab(text: 'Teams'),
            Tab(text: 'Tournaments'),
          ],
        ),

        // ── Tab content + FAB ───────────────────────────────────────────────
        Expanded(
          child: Stack(
            children: [
              TabBarView(
                controller: _tabController,
                children: [
                  PlayMatchesTab(callbacks: widget.callbacks),
                  PlayTeamsTab(
                    callbacks: widget.callbacks,
                    currentUserId: widget.currentUserId,
                  ),
                  PlayTournamentsTab(
                    callbacks: widget.callbacks,
                    currentCity: widget.currentCity,
                  ),
                ],
              ),
              Positioned(
                right: 20,
                bottom: 20,
                child: _HostFab(callbacks: widget.callbacks),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Host FAB ─────────────────────────────────────────────────────────────────

class _HostFab extends StatelessWidget {
  const _HostFab({required this.callbacks});
  final PlayTabCallbacks callbacks;

  void _show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateSheet(callbacks: callbacks),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _show(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        decoration: BoxDecoration(
          color: context.fg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: context.bg, size: 18),
            const SizedBox(width: 6),
            Text(
              'Host',
              style: TextStyle(
                color: context.bg,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Create sheet ─────────────────────────────────────────────────────────────

class _CreateSheet extends StatelessWidget {
  const _CreateSheet({required this.callbacks});
  final PlayTabCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Container(
          decoration: BoxDecoration(
            color: context.surf,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: context.stroke,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              if (callbacks.onCreateMatch != null)
                _SheetOption(
                  icon: Icons.sports_cricket_rounded,
                  label: 'Host Match',
                  color: context.sky,
                  onTap: () {
                    Navigator.pop(context);
                    callbacks.onCreateMatch!(context);
                  },
                ),
              if (callbacks.onCreateTeam != null)
                _SheetOption(
                  icon: Icons.shield_rounded,
                  label: 'Create Team',
                  color: context.success,
                  onTap: () {
                    Navigator.pop(context);
                    callbacks.onCreateTeam!(context);
                  },
                ),
              if (callbacks.onCreateTournament != null)
                _SheetOption(
                  icon: Icons.emoji_events_rounded,
                  label: 'Host Tournament',
                  color: context.gold,
                  onTap: () {
                    Navigator.pop(context);
                    callbacks.onCreateTournament!(context);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: context.fg,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: context.fgSub, size: 14),
          ],
        ),
      ),
    );
  }
}
