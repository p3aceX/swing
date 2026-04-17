import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../matches/presentation/matches_tab.dart';
import '../../teams/presentation/teams_tab.dart';
import '../../tournaments/presentation/tournaments_tab.dart';

class PlayTab extends StatefulWidget {
  const PlayTab({super.key, this.currentCity});
  final String? currentCity;

  @override
  State<PlayTab> createState() => _PlayTabState();
}

class _PlayTabState extends State<PlayTab> with SingleTickerProviderStateMixin {
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
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              const TeamsTab(),
              const MatchesTab(),
              TournamentsTab(currentCity: widget.currentCity),
            ],
          ),
        ),
      ],
    );
  }
}
