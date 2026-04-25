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
        Container(
          padding: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: context.surf,
            border: Border(bottom: BorderSide(color: context.stroke)),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: context.accent,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent,
            labelColor: context.fg,
            unselectedLabelColor: context.fgSub,
            labelPadding: const EdgeInsets.symmetric(horizontal: 20),
            labelStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
            tabs: const [
              Tab(text: 'Teams'),
              Tab(text: 'Matches'),
              Tab(text: 'Tournaments'),
            ],
          ),
        ),

        // ── Tab content ─────────────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              PlayTeamsTab(
                callbacks: widget.callbacks,
                currentUserId: widget.currentUserId,
              ),
              PlayMatchesTab(callbacks: widget.callbacks),
              PlayTournamentsTab(
                callbacks: widget.callbacks,
                currentCity: widget.currentCity,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
