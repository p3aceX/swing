import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart'
    show HostTournamentDetailScreen;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/theme/app_colors.dart';

enum _ManageFilter { live, completed }

class HostScreen extends StatelessWidget {
  const HostScreen({
    super.key,
    this.showBackButton = true,
  });

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: context.bg,
        body: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    if (showBackButton) ...[
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: context.panel,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(color: context.stroke),
                          ),
                          child: Icon(Icons.arrow_back_ios_new_rounded,
                              color: context.fg, size: 17),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: context.cardBg,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: context.stroke),
                        ),
                        child: TabBar(
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          labelPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 2),
                          indicator: BoxDecoration(
                            color: context.accentBg,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelColor: context.accent,
                          unselectedLabelColor: context.fgSub,
                          labelStyle:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                          unselectedLabelStyle:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                          tabs: const [
                            Tab(text: 'Match'),
                            Tab(text: 'Tournament'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  _HostedMatchesTab(),
                  _HostedTournamentsTab(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: _GoLiveFab(),
      ),
    );
  }
}

// ── Go Live FAB ───────────────────────────────────────────────────────────────

class _GoLiveFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showHostSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.accent,
              context.accent.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: context.accent.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sensors_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              'Host Now',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHostSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _HostSheet(),
    );
  }
}

// ── Host bottom sheet ─────────────────────────────────────────────────────────

class _HostSheet extends StatelessWidget {
  const _HostSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: context.stroke),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.stroke,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Host',
            style: TextStyle(
              color: context.fg,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            'What would you like to create?',
            style: TextStyle(color: context.fgSub, fontSize: 14),
          ),
          const SizedBox(height: 24),
          _HostOption(
            icon: Icons.sports_cricket_rounded,
            title: 'Host a Match',
            subtitle: 'Create a friendly, ranked or academy match',
            onTap: () {
              Navigator.pop(context);
              context.push('/create-match');
            },
          ),
          const SizedBox(height: 12),
          _HostOption(
            icon: Icons.emoji_events_rounded,
            title: 'Host a Tournament',
            subtitle: 'Organise a T10, T20 or One Day tournament',
            onTap: () {
              Navigator.pop(context);
              context.push('/create-tournament');
            },
          ),
        ],
      ),
    );
  }
}

class _HostOption extends StatelessWidget {
  const _HostOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.panel,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.stroke),
          ),
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
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(color: context.fgSub, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: context.fgSub, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Hosted matches tab ──────────────────────────────────────────────────────

class _HostedMatchesTab extends StatefulWidget {
  const _HostedMatchesTab();

  @override
  State<_HostedMatchesTab> createState() => _HostedMatchesTabState();
}

class _HostedMatchesTabState extends State<_HostedMatchesTab> {
  List<Map<String, dynamic>> _matches = [];
  bool _loading = true;
  String? _error;
  _ManageFilter _filter = _ManageFilter.live;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final responses = await Future.wait<dynamic>([
        ApiClient.instance.dio.get(ApiEndpoints.playerProfile),
        ApiClient.instance.dio
            .get(ApiEndpoints.playerMatches, queryParameters: {'limit': 50}),
      ]);
      final profile = _unwrapMap(responses[0].data);
      final profileIds = _extractProfileIds(profile);
      final rows = _unwrapList(responses[1].data);
      final hosted = rows
          .whereType<Map>()
          .map((item) => item.cast<String, dynamic>())
          .where((item) => _isHostedMatch(item, profileIds))
          .toList(growable: false);

      setState(() {
        _matches = hosted;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Could not load hosted matches';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return _DiscoverFeedback(message: _error!, onRetry: _load);
    }

    final filtered = _matches
        .where((item) => _matchesHostFilter(item, _filter))
        .toList(growable: false);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        children: [
          _ManageFilterRow(
            selected: _filter,
            onChanged: (value) => setState(() => _filter = value),
          ),
          const SizedBox(height: 14),
          if (filtered.isEmpty)
            _InlineEmptyState(
              message: _filter == _ManageFilter.live
                  ? 'No live matches you are managing right now.'
                  : 'No completed matches you managed yet.',
            )
          else
            ...List.generate(
              filtered.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                  bottom: index == filtered.length - 1 ? 0 : 12,
                ),
                child: _HostedMatchCard(raw: filtered[index]),
              ),
            ),
        ],
      ),
    );
  }
}

class _HostedMatchCard extends StatelessWidget {
  const _HostedMatchCard({required this.raw});

  final Map<String, dynamic> raw;

  @override
  Widget build(BuildContext context) {
    final match =
        raw['match'] is Map<String, dynamic> ? raw['match'] as Map : raw;
    final matchId =
        '${match['id'] ?? match['_id'] ?? raw['matchId'] ?? raw['id'] ?? ''}';
    final teamA = '${match['teamAName'] ?? 'Team A'}';
    final teamB = '${match['teamBName'] ?? 'Team B'}';
    final format = _displayFormat('${match['format'] ?? ''}');
    final status = '${match['status'] ?? ''}';
    final score = '${match['scoreSummary'] ?? ''}';
    final scheduledAt = _formatDate(match['scheduledAt']);
    final isLive = _isLiveStatus(status);
    final isCompleted = _isCompletedStatus(status);
    final isResumable = _isResumableScoringStatus(status);
    final actionLabel = isCompleted
        ? 'View Summary'
        : (isResumable ? 'Resume Scoring' : 'Start Scoring');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$teamA vs $teamB',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              _Chip(
                label: _displayStatus(status),
                bg: isLive ? context.accentBg : context.panel,
                fg: isLive ? context.accent : context.fg,
              ),
            ],
          ),
          if (scheduledAt.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              scheduledAt,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: context.fgSub),
            ),
          ],
          if (score.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              score,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: context.fg,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (format.isNotEmpty)
                _Chip(label: format, bg: context.panel, fg: context.fg),
              _Chip(
                label: isResumable ? 'Scoring On You' : 'Managed by You',
                bg: context.gold.withValues(alpha: 0.12),
                fg: context.gold,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (!isCompleted) {
                      if (matchId.isNotEmpty) {
                        context.push('/score-match/$matchId');
                      } else {
                        _showManagePlaceholder(context, 'Scoring flow');
                      }
                    } else {
                      if (matchId.isNotEmpty) {
                        context.push('/match/$matchId');
                      } else {
                        _showManagePlaceholder(context, 'Match summary');
                      }
                    }
                  },
                  icon: Icon(
                    isCompleted
                        ? Icons.receipt_long_rounded
                        : isResumable
                            ? Icons.sports_score_rounded
                            : Icons.play_arrow_rounded,
                  ),
                  label: Text(actionLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Hosted tournaments tab ──────────────────────────────────────────────────

class _HostedTournamentsTab extends StatefulWidget {
  const _HostedTournamentsTab();

  @override
  State<_HostedTournamentsTab> createState() => _HostedTournamentsTabState();
}

class _HostedTournamentsTabState extends State<_HostedTournamentsTab> {
  List<Map<String, dynamic>> _tournaments = [];
  bool _loading = true;
  String? _error;
  _ManageFilter _filter = _ManageFilter.live;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiClient.instance.dio.get(ApiEndpoints.myTournaments);
      final data = res.data is Map
          ? res.data as Map<String, dynamic>
          : <String, dynamic>{};
      final inner = data['data'] is Map
          ? data['data'] as Map<String, dynamic>
          : <String, dynamic>{};
      final rows =
          (inner['tournaments'] is List ? inner['tournaments'] as List : [])
              .whereType<Map>()
              .map((item) => item.cast<String, dynamic>())
              .toList(growable: false);
      setState(() {
        _tournaments = rows;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Could not load hosted tournaments';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return _DiscoverFeedback(message: _error!, onRetry: _load);
    }

    final filtered = _tournaments
        .where((item) => _tournamentHostFilter(item, _filter))
        .toList(growable: false);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        children: [
          _ManageFilterRow(
            selected: _filter,
            onChanged: (value) => setState(() => _filter = value),
          ),
          const SizedBox(height: 14),
          if (filtered.isEmpty)
            _InlineEmptyState(
              message: _filter == _ManageFilter.live
                  ? 'No live tournaments you are managing right now.'
                  : 'No completed tournaments you managed yet.',
            )
          else
            ...List.generate(
              filtered.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                  bottom: index == filtered.length - 1 ? 0 : 12,
                ),
                child: _HostedTournamentCard(data: filtered[index]),
              ),
            ),
        ],
      ),
    );
  }
}

class _HostedTournamentCard extends StatelessWidget {
  const _HostedTournamentCard({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final name = '${data['name'] ?? 'Tournament'}';
    final format = '${data['tournamentFormat'] ?? data['format'] ?? ''}';
    final status = '${data['status'] ?? ''}';
    final city = '${data['city'] ?? ''}';
    final venue = '${data['venueName'] ?? ''}';
    final dateRange = _formatDateRange(data['startDate'], data['endDate']);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              _Chip(
                label: _displayStatus(status),
                bg: _isLiveStatus(status) ? context.accentBg : context.panel,
                fg: _isLiveStatus(status) ? context.accent : context.fg,
              ),
            ],
          ),
          if (dateRange.isNotEmpty || city.isNotEmpty || venue.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              [dateRange, city, venue]
                  .where((item) => item.isNotEmpty)
                  .join(' · '),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: context.fgSub),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (format.isNotEmpty)
                _Chip(label: format, bg: context.panel, fg: context.fg),
              _Chip(
                label: 'Manage Tournament',
                bg: context.gold.withValues(alpha: 0.12),
                fg: context.gold,
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final tournamentId = '${data['id'] ?? ''}';
                if (tournamentId.isEmpty) return;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => HostTournamentDetailScreen(
                      tournamentId: tournamentId,
                      initialData: data,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.tune_rounded),
              label: const Text('Manage Tournament'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hosted events tab ───────────────────────────────────────────────────────

class _HostedEventsTab extends StatefulWidget {
  const _HostedEventsTab();

  @override
  State<_HostedEventsTab> createState() => _HostedEventsTabState();
}

class _HostedEventsTabState extends State<_HostedEventsTab> {
  List<Map<String, dynamic>> _events = [];
  bool _loading = true;
  String? _error;
  _ManageFilter _filter = _ManageFilter.live;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiClient.instance.dio.get(ApiEndpoints.myEvents);
      final data = res.data is Map
          ? res.data as Map<String, dynamic>
          : <String, dynamic>{};
      final inner = data['data'] is Map
          ? data['data'] as Map<String, dynamic>
          : <String, dynamic>{};
      final rows = (inner['events'] is List ? inner['events'] as List : [])
          .whereType<Map>()
          .map((item) => item.cast<String, dynamic>())
          .toList(growable: false);
      setState(() {
        _events = rows;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Could not load hosted events';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return _DiscoverFeedback(message: _error!, onRetry: _load);
    }

    final filtered = _events
        .where((item) => _eventHostFilter(item, _filter))
        .toList(growable: false);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        children: [
          _ManageFilterRow(
            selected: _filter,
            onChanged: (value) => setState(() => _filter = value),
          ),
          const SizedBox(height: 14),
          if (filtered.isEmpty)
            _InlineEmptyState(
              message: _filter == _ManageFilter.live
                  ? 'No live events you are hosting right now.'
                  : 'No completed events yet.',
            )
          else
            ...List.generate(
              filtered.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                  bottom: index == filtered.length - 1 ? 0 : 12,
                ),
                child: _HostedEventCard(data: filtered[index]),
              ),
            ),
        ],
      ),
    );
  }
}

class _HostedEventCard extends StatelessWidget {
  const _HostedEventCard({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final name = '${data['name'] ?? 'Event'}';
    final eventType = '${data['eventType'] ?? ''}';
    final status = '${data['status'] ?? ''}';
    final city = '${data['city'] ?? ''}';
    final venue = '${data['venueName'] ?? ''}';
    final scheduledAt = _formatDate(data['scheduledAt']);
    final isLive = _isLiveStatus(status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              _Chip(
                label: _displayStatus(status),
                bg: isLive ? context.accentBg : context.panel,
                fg: isLive ? context.accent : context.fg,
              ),
            ],
          ),
          if (scheduledAt.isNotEmpty ||
              city.isNotEmpty ||
              venue.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              [scheduledAt, city, venue]
                  .where((item) => item.isNotEmpty)
                  .join(' · '),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: context.fgSub),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (eventType.isNotEmpty && eventType != 'CUSTOM')
                _Chip(
                  label: _displayStatus(eventType),
                  bg: context.panel,
                  fg: context.fg,
                ),
              _Chip(
                label: 'Hosted by You',
                bg: context.gold.withValues(alpha: 0.12),
                fg: context.gold,
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  _showManagePlaceholder(context, 'Event management'),
              icon: const Icon(Icons.event_rounded),
              label: const Text('Manage Event'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _ManageFilterRow extends StatelessWidget {
  const _ManageFilterRow({
    required this.selected,
    required this.onChanged,
  });

  final _ManageFilter selected;
  final ValueChanged<_ManageFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.panel,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.stroke),
          ),
          child: Icon(Icons.tune_rounded, color: context.accent, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _DiscoverFilterChip(
                  icon: Icons.grid_view_rounded,
                  label: 'Hosting Now',
                  selected: selected == _ManageFilter.live,
                  onTap: () => onChanged(_ManageFilter.live),
                ),
                const SizedBox(width: 8),
                _DiscoverFilterChip(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Completed',
                  selected: selected == _ManageFilter.completed,
                  onTap: () => onChanged(_ManageFilter.completed),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DiscoverFilterChip extends StatelessWidget {
  const _DiscoverFilterChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? context.accentBg : context.cardBg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? context.accent.withValues(alpha: 0.26)
                : context.stroke,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? context.accent : context.fgSub,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected ? context.accent : context.fg,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineEmptyState extends StatelessWidget {
  const _InlineEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.stroke),
      ),
      child: Text(
        message,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: context.fgSub),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.bg, required this.fg});
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _DiscoverFeedback extends StatelessWidget {
  const _DiscoverFeedback({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

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
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: context.fgSub),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

Map<String, dynamic> _unwrapMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    final data = value['data'];
    if (data is Map<String, dynamic>) return data;
    return value;
  }
  if (value is Map) {
    return value.cast<String, dynamic>();
  }
  return const {};
}

List<dynamic> _unwrapList(dynamic value) {
  if (value is Map<String, dynamic>) {
    final data = value['data'];
    if (data is List) return data;
    if (data is Map<String, dynamic> && data['data'] is List) {
      return data['data'] as List;
    }
  }
  if (value is List) return value;
  return const [];
}

Set<String> _extractProfileIds(Map<String, dynamic> profile) {
  final ids = <String>{};
  void add(dynamic value) {
    final normalized = '$value'.trim();
    if (normalized.isNotEmpty && normalized != 'null') ids.add(normalized);
  }

  final identity = _unwrapMap(profile['identity']);
  final playerProfile = _unwrapMap(profile['playerProfile']);
  final user = _unwrapMap(profile['user']);

  for (final source in [profile, identity, playerProfile, user]) {
    add(source['id']);
    add(source['_id']);
    add(source['profileId']);
    add(source['playerId']);
    add(source['playerProfileId']);
    add(source['userId']);
  }
  return ids;
}

Set<String> _collectMatchOwnerIds(Map<String, dynamic> source) {
  final out = <String>{};
  void add(dynamic value) {
    final normalized = '$value'.trim();
    if (normalized.isNotEmpty && normalized != 'null') out.add(normalized);
  }

  for (final key in const [
    'scorerId',
    'scorerProfileId',
    'scorerPlayerId',
    'hostId',
    'hostProfileId',
    'hostPlayerId',
    'organizerId',
    'organizerProfileId',
    'organizerPlayerId',
    'createdBy',
    'createdById',
    'createdByProfileId',
    'createdByPlayerId',
    'ownerId',
    'managerId',
  ]) {
    add(source[key]);
  }

  final scorer = _unwrapMap(source['scorer']);
  final host = _unwrapMap(source['host']);
  final createdBy = _unwrapMap(source['createdByUser']);
  for (final nested in [scorer, host, createdBy]) {
    add(nested['id']);
    add(nested['profileId']);
    add(nested['playerId']);
    add(nested['playerProfileId']);
  }

  return out;
}

bool _truthy(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' ||
        normalized == '1' ||
        normalized == 'yes' ||
        normalized == 'y';
  }
  return false;
}

bool _isHostedMatch(Map<String, dynamic> raw, Set<String> profileIds) {
  final match =
      _unwrapMap(raw['match']).isNotEmpty ? _unwrapMap(raw['match']) : raw;
  final stat = _unwrapMap(raw['stat']);

  final hasHostFlag = _truthy(raw['isHost']) ||
      _truthy(raw['canScore']) ||
      _truthy(match['isHost']) ||
      _truthy(match['canScore']) ||
      _truthy(stat['isHost']) ||
      _truthy(stat['canScore']);
  if (hasHostFlag) return true;

  if (profileIds.isEmpty) return false;
  final candidateIds = <String>{}
    ..addAll(_collectMatchOwnerIds(raw))
    ..addAll(_collectMatchOwnerIds(match))
    ..addAll(_collectMatchOwnerIds(stat));

  return profileIds.any(candidateIds.contains);
}

bool _matchesHostFilter(Map<String, dynamic> raw, _ManageFilter filter) {
  final match =
      _unwrapMap(raw['match']).isNotEmpty ? _unwrapMap(raw['match']) : raw;
  final status = '${match['status'] ?? ''}';
  if (filter == _ManageFilter.completed) {
    return _isCompletedStatus(status);
  }
  return _isLiveStatus(status);
}

bool _tournamentHostFilter(Map<String, dynamic> item, _ManageFilter filter) {
  final status = '${item['status'] ?? ''}'.toUpperCase();
  if (filter == _ManageFilter.completed) {
    return status == 'COMPLETED' || status == 'CANCELLED';
  }
  return _isLiveStatus(status);
}

bool _eventHostFilter(Map<String, dynamic> item, _ManageFilter filter) {
  final status = '${item['status'] ?? ''}'.toUpperCase();
  if (filter == _ManageFilter.completed) {
    return status == 'COMPLETED' || status == 'CANCELLED';
  }
  return _isLiveStatus(status);
}

bool _isLiveStatus(String status) {
  final normalized = _normalizeStatus(status);
  return {
    'LIVE',
    'IN_PROGRESS',
    'ONGOING',
    'STARTED',
    'TOSS_DONE',
    'UPCOMING',
    'SCHEDULED',
    'READY_TO_START',
    'READY',
  }.contains(normalized);
}

bool _isResumableScoringStatus(String status) {
  final normalized = _normalizeStatus(status);
  return {
    'LIVE',
    'IN_PROGRESS',
    'ONGOING',
    'STARTED',
    'TOSS_DONE',
  }.contains(normalized);
}

bool _isCompletedStatus(String status) {
  final normalized = _normalizeStatus(status);
  return {
    'COMPLETED',
    'CANCELLED',
    'ABANDONED',
    'ENDED',
    'FINISHED',
  }.contains(normalized);
}

String _normalizeStatus(String value) {
  return value.trim().toUpperCase().replaceAll('-', '_').replaceAll(' ', '_');
}

String _displayStatus(String value) {
  return value
      .split('_')
      .map((word) =>
          word.isEmpty ? '' : '${word[0]}${word.substring(1).toLowerCase()}')
      .join(' ');
}

String _displayFormat(String value) {
  switch (value.toUpperCase()) {
    case 'T10':
      return 'T10';
    case 'T20':
      return 'T20';
    case 'ONE_DAY':
      return 'ODI';
    case 'TWO_INNINGS':
      return 'Test Match';
    case 'CUSTOM':
      return 'Custom';
    default:
      return _displayStatus(value);
  }
}

String _formatDate(dynamic raw) {
  if (raw is! String) return '';
  final date = DateTime.tryParse(raw);
  if (date == null) return '';
  return DateFormat('d MMM · h:mm a').format(date.toLocal());
}

String _formatDateRange(dynamic startRaw, dynamic endRaw) {
  if (startRaw is! String || endRaw is! String) return '';
  final start = DateTime.tryParse(startRaw);
  final end = DateTime.tryParse(endRaw);
  if (start == null || end == null) return '';
  return '${DateFormat('d MMM').format(start)} – ${DateFormat('d MMM yyyy').format(end)}';
}

void _showManagePlaceholder(BuildContext context, String label) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$label will connect here')),
  );
}
