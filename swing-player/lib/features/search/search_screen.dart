import "package:cached_network_image/cached_network_image.dart";
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/theme/app_colors.dart';

const _minSearchChars = 2;
const _minResultChars = 4;

enum _SearchType { all, players, teams, venues, tournaments, events }

extension _SearchTypeX on _SearchType {
  String get queryValue => switch (this) {
        _SearchType.all => 'all',
        _SearchType.players => 'players',
        _SearchType.teams => 'teams',
        _SearchType.venues => 'venues',
        _SearchType.tournaments => 'tournaments',
        _SearchType.events => 'events',
      };

  String get label => switch (this) {
        _SearchType.all => 'All',
        _SearchType.players => 'Players',
        _SearchType.teams => 'Teams',
        _SearchType.venues => 'Venues',
        _SearchType.tournaments => 'Tournaments',
        _SearchType.events => 'Events',
      };

  IconData get icon => switch (this) {
        _SearchType.all => Icons.travel_explore_rounded,
        _SearchType.players => Icons.person_outline_rounded,
        _SearchType.teams => Icons.groups_rounded,
        _SearchType.venues => Icons.stadium_rounded,
        _SearchType.tournaments => Icons.emoji_events_outlined,
        _SearchType.events => Icons.event_outlined,
      };
}

enum _EntityKind { players, teams, venues, tournaments, events }

extension _EntityKindX on _EntityKind {
  String get label => switch (this) {
        _EntityKind.players => 'Players',
        _EntityKind.teams => 'Teams',
        _EntityKind.venues => 'Venues',
        _EntityKind.tournaments => 'Tournaments',
        _EntityKind.events => 'Events',
      };

  IconData get icon => switch (this) {
        _EntityKind.players => Icons.person_outline_rounded,
        _EntityKind.teams => Icons.groups_rounded,
        _EntityKind.venues => Icons.stadium_rounded,
        _EntityKind.tournaments => Icons.emoji_events_outlined,
        _EntityKind.events => Icons.event_outlined,
      };
}

class _SearchItem {
  const _SearchItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    this.avatarUrl,
    this.idCandidates = const [],
  });

  final String id;
  final _EntityKind kind;
  final String title;
  final String subtitle;
  final String? avatarUrl;
  final List<String> idCandidates;
}

class _SearchFilters {
  const _SearchFilters({
    this.city,
    this.playerRole,
    this.playerLevel,
    this.teamType,
    this.format,
    this.sport,
    this.tournamentStatus,
  });

  final String? city;
  final String? playerRole;
  final String? playerLevel;
  final String? teamType;
  final String? format;
  final String? sport;
  final String? tournamentStatus;

  bool get hasAny =>
      _isFilled(city) ||
      _isFilled(playerRole) ||
      _isFilled(playerLevel) ||
      _isFilled(teamType) ||
      _isFilled(format) ||
      _isFilled(sport) ||
      _isFilled(tournamentStatus);

  Map<String, dynamic> toQueryParameters(_SearchType type) {
    final params = <String, dynamic>{};
    if (_isFilled(city)) params['city'] = city!.trim();

    final includePlayers =
        type == _SearchType.all || type == _SearchType.players;
    if (includePlayers && _isFilled(playerRole)) {
      params['playerRole'] = playerRole!.trim();
    }
    if (includePlayers && _isFilled(playerLevel)) {
      params['playerLevel'] = playerLevel!.trim();
    }

    final includeTeams = type == _SearchType.all || type == _SearchType.teams;
    if (includeTeams && _isFilled(teamType)) {
      params['teamType'] = teamType!.trim();
    }

    final includeTournaments =
        type == _SearchType.all || type == _SearchType.tournaments;
    if (includeTournaments && _isFilled(format)) {
      params['format'] = format!.trim();
    }
    if (includeTournaments && _isFilled(sport)) {
      params['sport'] = sport!.trim();
    }
    if (includeTournaments && _isFilled(tournamentStatus)) {
      params['tournamentStatus'] = tournamentStatus!.trim();
    }

    return params;
  }

  List<_FilterTag> toTags() {
    final tags = <_FilterTag>[];
    if (_isFilled(city)) tags.add(_FilterTag('City', city!.trim()));
    if (_isFilled(playerRole)) {
      tags.add(_FilterTag('Role', _labelize(playerRole!)));
    }
    if (_isFilled(playerLevel)) {
      tags.add(_FilterTag('Level', _labelize(playerLevel!)));
    }
    if (_isFilled(teamType)) {
      tags.add(_FilterTag('Team', _labelize(teamType!)));
    }
    if (_isFilled(format)) tags.add(_FilterTag('Format', _labelize(format!)));
    if (_isFilled(sport)) tags.add(_FilterTag('Sport', _labelize(sport!)));
    if (_isFilled(tournamentStatus)) {
      tags.add(_FilterTag('Status', _labelize(tournamentStatus!)));
    }
    return tags;
  }
}

class _FilterTag {
  const _FilterTag(this.key, this.value);
  final String key;
  final String value;
}

class _ParsedSearchPayload {
  const _ParsedSearchPayload({
    required this.sections,
    required this.counts,
  });

  final Map<_EntityKind, List<_SearchItem>> sections;
  final Map<_EntityKind, int> counts;
}

class _SearchState {
  const _SearchState({
    this.query = '',
    this.type = _SearchType.all,
    this.filters = const _SearchFilters(),
    this.isLoading = false,
    this.sections = const {},
    this.counts = const {},
    this.hasSearched = false,
    this.error,
  });

  final String query;
  final _SearchType type;
  final _SearchFilters filters;
  final bool isLoading;
  final Map<_EntityKind, List<_SearchItem>> sections;
  final Map<_EntityKind, int> counts;
  final bool hasSearched;
  final String? error;

  bool get hasAnyResults => sections.values.any((items) => items.isNotEmpty);

  _SearchState copyWith({
    String? query,
    _SearchType? type,
    _SearchFilters? filters,
    bool? isLoading,
    Map<_EntityKind, List<_SearchItem>>? sections,
    Map<_EntityKind, int>? counts,
    bool? hasSearched,
    String? error,
    bool clearError = false,
  }) {
    return _SearchState(
      query: query ?? this.query,
      type: type ?? this.type,
      filters: filters ?? this.filters,
      isLoading: isLoading ?? this.isLoading,
      sections: sections ?? this.sections,
      counts: counts ?? this.counts,
      hasSearched: hasSearched ?? this.hasSearched,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class _SearchNotifier extends StateNotifier<_SearchState> {
  _SearchNotifier() : super(const _SearchState());

  final Dio _client = ApiClient.instance.dio;
  Timer? _debounce;
  CancelToken? _cancelToken;
  int _requestId = 0;

  void setQuery(String query) {
    if (query == state.query) return;
    state = state.copyWith(query: query);
    _scheduleSearch();
  }

  void setType(_SearchType type) {
    if (type == state.type) return;
    state = state.copyWith(type: type);
    _scheduleSearch(immediate: true);
  }

  void setFilters(_SearchFilters filters) {
    state = state.copyWith(filters: filters);
    _scheduleSearch(immediate: true);
  }

  void clearFilters() {
    setFilters(const _SearchFilters());
  }

  Future<List<_SearchItem>> fetchSuggestions(
    String query, {
    _SearchType? type,
    _SearchFilters? filters,
    int limit = 6,
  }) async {
    final trimmed = query.trim();
    if (trimmed.length < _minSearchChars) return const [];

    final useType = type ?? state.type;
    final useFilters = filters ?? state.filters;
    final params = <String, dynamic>{
      'q': trimmed,
      'type': useType.queryValue,
      'limit': limit,
      ...useFilters.toQueryParameters(useType),
    };

    try {
      final response = await _client.get(
        ApiEndpoints.playerSearch,
        queryParameters: params,
      );
      final parsed = _parsePayload(response.data);
      return _flattenSuggestions(parsed.sections, useType, max: limit);
    } catch (_) {
      return const [];
    }
  }

  void runNow() {
    _scheduleSearch(immediate: true);
  }

  Future<void> refresh() => _performSearch();

  void _scheduleSearch({bool immediate = false}) {
    _debounce?.cancel();
    final trimmed = state.query.trim();
    if (trimmed.length < _minSearchChars) {
      _cancelToken?.cancel('query-too-short');
      state = state.copyWith(
        isLoading: false,
        sections: const {},
        counts: const {},
        hasSearched: false,
        clearError: true,
      );
      return;
    }
    if (immediate) {
      _performSearch();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 280), _performSearch);
  }

  Future<void> _performSearch() async {
    final trimmed = state.query.trim();
    if (trimmed.length < _minSearchChars) return;

    _cancelToken?.cancel('new-request');
    final token = CancelToken();
    _cancelToken = token;
    final requestId = ++_requestId;

    state =
        state.copyWith(isLoading: true, hasSearched: true, clearError: true);

    final params = <String, dynamic>{
      'q': trimmed,
      'type': state.type.queryValue,
      'limit': 12,
      ...state.filters.toQueryParameters(state.type),
    };

    try {
      final response = await _client.get(
        ApiEndpoints.playerSearch,
        queryParameters: params,
        cancelToken: token,
      );
      if (requestId != _requestId || token.isCancelled) return;

      final parsed = _parsePayload(response.data);
      state = state.copyWith(
        isLoading: false,
        sections: parsed.sections,
        counts: parsed.counts,
        hasSearched: true,
        clearError: true,
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e) || requestId != _requestId) return;
      state = state.copyWith(
        isLoading: false,
        hasSearched: true,
        error: _errorMessage(e),
      );
    } catch (_) {
      if (requestId != _requestId) return;
      state = state.copyWith(
        isLoading: false,
        hasSearched: true,
        error: 'Search failed. Try again.',
      );
    }
  }

  _ParsedSearchPayload _parsePayload(dynamic body) {
    final root = _asMap(body);
    final data = _asMap(root['data'] ?? root);

    final players = _parsePlayers(_asListMap(data['players']));
    final teams = _parseTeams(_asListMap(data['teams']));
    final venues = _parseVenues(_asListMap(data['venues'] ?? data['arenas']));
    final tournaments = _parseTournaments(_asListMap(data['tournaments']));
    final events = _parseEvents(_asListMap(data['events']));

    final sections = <_EntityKind, List<_SearchItem>>{
      _EntityKind.players: players,
      _EntityKind.teams: teams,
      _EntityKind.venues: venues,
      _EntityKind.tournaments: tournaments,
      _EntityKind.events: events,
    };

    final countMap = _asMap(data['counts']);
    final counts = <_EntityKind, int>{
      _EntityKind.players: _extractCount(
        countMap,
        const [
          'players',
          'player',
          'playersCount',
          'playerCount',
          'totalPlayers'
        ],
        players.length,
      ),
      _EntityKind.teams: _extractCount(
        countMap,
        const ['teams', 'team', 'teamsCount', 'teamCount', 'totalTeams'],
        teams.length,
      ),
      _EntityKind.venues: _extractCount(
        countMap,
        const ['venues', 'venue', 'arenas', 'venueCount', 'totalVenues'],
        venues.length,
      ),
      _EntityKind.tournaments: _extractCount(
        countMap,
        const [
          'tournaments',
          'tournament',
          'tournamentsCount',
          'tournamentCount',
          'totalTournaments'
        ],
        tournaments.length,
      ),
      _EntityKind.events: _extractCount(
        countMap,
        const ['events', 'event', 'eventsCount', 'eventCount', 'totalEvents'],
        events.length,
      ),
    };

    return _ParsedSearchPayload(sections: sections, counts: counts);
  }

  List<_SearchItem> _flattenSuggestions(
    Map<_EntityKind, List<_SearchItem>> sections,
    _SearchType type, {
    required int max,
  }) {
    final items = <_SearchItem>[];
    final orderedKinds = type == _SearchType.all
        ? const [
            _EntityKind.players,
            _EntityKind.teams,
            _EntityKind.venues,
            _EntityKind.tournaments,
            _EntityKind.events,
          ]
        : <_EntityKind>[
            type == _SearchType.players
                ? _EntityKind.players
                : type == _SearchType.teams
                    ? _EntityKind.teams
                    : type == _SearchType.venues
                        ? _EntityKind.venues
                        : type == _SearchType.tournaments
                            ? _EntityKind.tournaments
                            : _EntityKind.events,
          ];

    for (final kind in orderedKinds) {
      for (final entry in sections[kind] ?? const <_SearchItem>[]) {
        items.add(entry);
        if (items.length >= max) return items;
      }
    }
    return items;
  }

  List<_SearchItem> _parsePlayers(List<Map<String, dynamic>> raw) {
    return raw.map((item) {
      final user = _asMap(item['user'] ?? item['profile']);
      final playerProfile = _asMap(item['playerProfile']);
      final profile = _asMap(item['profile']);
      final player = _asMap(item['player']);
      final title = _firstFilled([
        _string(user['name']),
        _string(item['name']),
        _string(item['displayName']),
        'Player',
      ]);
      final subtitle = _joinParts([
        _labelize(_string(item['playerRole'])),
        _labelize(_string(item['playerLevel'])),
        _string(item['city']),
      ]);
      final candidateIds = _uniqueNonEmpty([
        _string(item['playerProfileId']),
        _string(item['profileId']),
        _string(item['playerId']),
        _string(playerProfile['id']),
        _string(profile['id']),
        _string(player['id']),
        _string(user['playerProfileId']),
        _string(user['profileId']),
        _string(item['id']),
        _string(item['userId']),
        _string(user['id']),
      ]);
      final profileId = candidateIds.isNotEmpty ? candidateIds.first : '';
      if (kDebugMode && profileId.isEmpty) {
        debugPrint('[Search] player result missing profile id: $item');
      }
      return _SearchItem(
        id: profileId,
        kind: _EntityKind.players,
        title: title,
        subtitle: subtitle,
        avatarUrl: _stringOrNull(user['avatarUrl']) ??
            _stringOrNull(item['avatarUrl']),
        idCandidates: candidateIds,
      );
    }).toList();
  }

  List<_SearchItem> _parseTeams(List<Map<String, dynamic>> raw) {
    return raw.map((item) {
      final subtitle = _joinParts([
        _labelize(_string(item['teamType'])),
        _string(item['city']),
      ]);
      return _SearchItem(
        id: _firstFilled([_string(item['id']), _string(item['teamId'])]),
        kind: _EntityKind.teams,
        title: _firstFilled([_string(item['name']), 'Team']),
        subtitle: subtitle,
        avatarUrl:
            _stringOrNull(item['logoUrl']) ?? _stringOrNull(item['avatarUrl']),
      );
    }).toList();
  }

  List<_SearchItem> _parseVenues(List<Map<String, dynamic>> raw) {
    return raw.map((item) {
      final subtitle = _joinParts([
        _string(item['city']),
        _string(item['area']),
        _string(item['address']),
      ]);
      return _SearchItem(
        id: _firstFilled([_string(item['id']), _string(item['venueId'])]),
        kind: _EntityKind.venues,
        title: _firstFilled([_string(item['name']), 'Venue']),
        subtitle: subtitle,
        avatarUrl: _stringOrNull(item['imageUrl']),
      );
    }).toList();
  }

  List<_SearchItem> _parseTournaments(List<Map<String, dynamic>> raw) {
    return raw.map((item) {
      final subtitle = _joinParts([
        _labelize(_string(item['sport'])),
        _labelize(_string(item['format'])),
        _labelize(_string(item['tournamentStatus'])),
        _string(item['city']),
      ]);
      return _SearchItem(
        id: _firstFilled([_string(item['id']), _string(item['tournamentId'])]),
        kind: _EntityKind.tournaments,
        title: _firstFilled([_string(item['name']), 'Tournament']),
        subtitle: subtitle,
        avatarUrl: _stringOrNull(item['bannerUrl']),
      );
    }).toList();
  }

  List<_SearchItem> _parseEvents(List<Map<String, dynamic>> raw) {
    return raw.map((item) {
      final subtitle = _joinParts([
        _labelize(_string(item['eventType'])),
        _labelize(_string(item['status'])),
        _string(item['city']),
      ]);
      return _SearchItem(
        id: _firstFilled([_string(item['id']), _string(item['eventId'])]),
        kind: _EntityKind.events,
        title: _firstFilled([_string(item['name']), 'Event']),
        subtitle: subtitle,
        avatarUrl: _stringOrNull(item['coverUrl']),
      );
    }).toList();
  }

  int _extractCount(
      Map<String, dynamic> counts, List<String> keys, int fallback) {
    for (final key in keys) {
      final raw = counts[key];
      if (raw is num) return raw.toInt();
      if (raw is String) {
        final parsed = int.tryParse(raw.trim());
        if (parsed != null) return parsed;
      }
    }
    return fallback;
  }

  String _errorMessage(DioException error) {
    final body = error.response?.data;
    if (body is Map) {
      final data = _asMap(body['data'] ?? body);
      final message = _string(data['message']);
      if (message.isNotEmpty) return message;
    }
    return 'Search failed. Try again.';
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _cancelToken?.cancel('notifier-dispose');
    super.dispose();
  }
}

final _searchProvider =
    StateNotifierProvider.autoDispose<_SearchNotifier, _SearchState>(
  (_) => _SearchNotifier(),
);

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  Timer? _suggestDebounce;
  int _suggestRequestId = 0;
  bool _suggestionLoading = false;
  List<_SearchItem> _liveSuggestions = const [];

  @override
  void initState() {
    super.initState();
    final initial = widget.initialQuery.trim();
    if (initial.isNotEmpty) {
      _controller.text = initial;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final notifier = ref.read(_searchProvider.notifier);
        notifier.setQuery(initial);
        notifier.runNow();
        _scheduleSuggestionLookup(initial);
      });
    }
    _controller.addListener(() {
      ref.read(_searchProvider.notifier).setQuery(_controller.text);
      _scheduleSuggestionLookup(_controller.text);
      if (mounted) setState(() {});
    });
    _focus.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.initialQuery.trim().isEmpty) {
        _focus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _suggestDebounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_searchProvider);
    final notifier = ref.read(_searchProvider.notifier);
    final filterTags = state.filters.toTags();
    final query = state.query.trim();
    final canShowSuggestions =
        query.length >= _minSearchChars && _liveSuggestions.isNotEmpty;

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: context.fg),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Search',
          style: TextStyle(
            color: context.fg,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: _SearchInput(
              controller: _controller,
              focusNode: _focus,
              onSubmitted: (_) => notifier.runNow(),
              onClear: () {
                _controller.clear();
                notifier.setQuery('');
              },
            ),
          ),
          if (query.length >= _minSearchChars && _suggestionLoading)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: _InlineSearching(),
            )
          else if (canShowSuggestions)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: _SuggestionsPanel(
                items: _liveSuggestions,
                onTap: (item) {
                  _focus.unfocus();
                  _navigateToResult(item);
                },
              ),
            ),
          _TypeSelector(
            active: state.type,
            onChanged: (type) {
              notifier.setType(type);
              _scheduleSuggestionLookup(_controller.text);
            },
          ),
          const SizedBox(height: 8),
          _FilterStrip(
            tags: filterTags,
            hasFilters: state.filters.hasAny,
            onOpenFilters: () async {
              final next = await showModalBottomSheet<_SearchFilters>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => _FiltersSheet(
                  current: state.filters,
                  type: state.type,
                ),
              );
              if (next != null) {
                notifier.setFilters(next);
                _scheduleSuggestionLookup(_controller.text);
              }
            },
            onClearFilters: notifier.clearFilters,
          ),
          if (state.isLoading && state.hasAnyResults)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(
                minHeight: 2,
                color: context.accent,
                backgroundColor: context.cardBg,
              ),
            ),
          const SizedBox(height: 6),
          Expanded(
            child: _ResultsBody(
              state: state,
              onRetry: notifier.runNow,
              onRefresh: notifier.refresh,
              onTapResult: _navigateToResult,
            ),
          ),
        ],
      ),
    );
  }

  void _scheduleSuggestionLookup(String query) {
    _suggestDebounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.length < _minSearchChars) {
      if (_liveSuggestions.isNotEmpty || _suggestionLoading) {
        setState(() {
          _liveSuggestions = const [];
          _suggestionLoading = false;
        });
      }
      return;
    }
    _suggestDebounce = Timer(const Duration(milliseconds: 180), () async {
      if (!mounted) return;
      final requestId = ++_suggestRequestId;
      setState(() => _suggestionLoading = true);
      final notifier = ref.read(_searchProvider.notifier);
      final suggestions = await notifier.fetchSuggestions(
        trimmed,
        limit: 6,
      );
      if (!mounted || requestId != _suggestRequestId) return;
      setState(() {
        _liveSuggestions = suggestions;
        _suggestionLoading = false;
      });
    });
  }

  Future<void> _navigateToResult(_SearchItem item) async {
    if (item.id.isEmpty) return;
    switch (item.kind) {
      case _EntityKind.players:
        final resolvedId = await _resolvePlayerProfileId(item);
        if (!mounted) return;
        if (resolvedId == null || resolvedId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open this profile right now.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        final id = Uri.encodeComponent(resolvedId);
        context.push('/player/$id');
        return;
      case _EntityKind.teams:
        final id = Uri.encodeComponent(item.id);
        context.push('/team/$id');
        return;
      case _EntityKind.venues:
        final id = Uri.encodeComponent(item.id);
        context.push('/arena/$id');
        return;
      case _EntityKind.tournaments:
        final id = Uri.encodeComponent(item.id);
        context.push('/tournament/$id');
        return;
      case _EntityKind.events:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event detail screen is coming soon.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
    }
  }

  Future<String?> _resolvePlayerProfileId(_SearchItem item) async {
    final candidates = _uniqueNonEmpty([item.id, ...item.idCandidates]);
    if (candidates.isEmpty) return null;

    bool sawNon404Failure = false;
    for (final candidate in candidates) {
      try {
        final response = await ApiClient.instance.dio.get(
          ApiEndpoints.publicPlayerProfile(candidate),
        );
        final root = _asMap(response.data);
        final data = _asMap(root['data'] ?? root);
        final resolved = _firstFilled([
          _string(data['id']),
          _string(_asMap(data['profile'])['id']),
          _string(_asMap(data['playerProfile'])['id']),
          candidate,
        ]);
        if (kDebugMode) {
          debugPrint(
            '[Search] resolved player profile id=$resolved via candidate=$candidate',
          );
        }
        return resolved;
      } on DioException catch (error) {
        final code = error.response?.statusCode;
        if (kDebugMode) {
          debugPrint(
            '[Search] candidate=$candidate profile resolve failed status=$code',
          );
        }
        if (code != 404) {
          sawNon404Failure = true;
        }
      } catch (_) {
        sawNon404Failure = true;
      }
    }

    // If resolution failed due to transient/network errors, preserve old behavior.
    if (sawNon404Failure) return candidates.first;
    return null;
  }
}

class _InlineSearching extends StatelessWidget {
  const _InlineSearching();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.stroke),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: context.accent,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Searching suggestions...',
            style: TextStyle(color: context.fgSub, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

class _SuggestionsPanel extends StatelessWidget {
  const _SuggestionsPanel({
    required this.items,
    required this.onTap,
  });

  final List<_SearchItem> items;
  final ValueChanged<_SearchItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onTap(items[i]),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    children: [
                      Icon(
                        items[i].kind.icon,
                        color: context.fgSub,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          items[i].title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.fg,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        items[i].kind.label,
                        style: TextStyle(
                          color: context.fgSub,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (i < items.length - 1) Divider(height: 1, color: context.stroke),
          ],
        ],
      ),
    );
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.stroke),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: TextInputAction.search,
        onSubmitted: onSubmitted,
        style: TextStyle(color: context.fg, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search players, teams, venues, tournaments, events',
          hintStyle: TextStyle(
            color: context.fgSub.withValues(alpha: 0.85),
            fontSize: 14,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search_rounded, color: context.fgSub),
          suffixIcon: controller.text.trim().isEmpty
              ? null
              : IconButton(
                  onPressed: onClear,
                  icon:
                      Icon(Icons.close_rounded, size: 18, color: context.fgSub),
                ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({
    required this.active,
    required this.onChanged,
  });

  final _SearchType active;
  final ValueChanged<_SearchType> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (_, index) {
          final type = _SearchType.values[index];
          final selected = type == active;
          return InkWell(
            onTap: () => onChanged(type),
            borderRadius: BorderRadius.circular(999),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? Color.alphaBlend(
                        context.accent.withValues(alpha: 0.16), context.cardBg)
                    : context.cardBg,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selected
                      ? context.accent.withValues(alpha: 0.5)
                      : context.stroke,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    type.icon,
                    size: 15,
                    color: selected ? context.accent : context.fgSub,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    type.label,
                    style: TextStyle(
                      color: selected ? context.accent : context.fgSub,
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: _SearchType.values.length,
      ),
    );
  }
}

class _FilterStrip extends StatelessWidget {
  const _FilterStrip({
    required this.tags,
    required this.hasFilters,
    required this.onOpenFilters,
    required this.onClearFilters,
  });

  final List<_FilterTag> tags;
  final bool hasFilters;
  final VoidCallback onOpenFilters;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: onOpenFilters,
            icon: Icon(Icons.tune_rounded, size: 16, color: context.fgSub),
            label: Text(
              'Filters',
              style:
                  TextStyle(color: context.fgSub, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 34),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              side: BorderSide(color: context.stroke),
              backgroundColor: context.cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: hasFilters
                ? SizedBox(
                    height: 32,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, i) => _TagChip(tag: tags[i]),
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemCount: tags.length,
                    ),
                  )
                : Text(
                    'No filters applied',
                    style: TextStyle(color: context.fgSub, fontSize: 12.5),
                  ),
          ),
          if (hasFilters) ...[
            const SizedBox(width: 6),
            TextButton(
              onPressed: onClearFilters,
              style: TextButton.styleFrom(
                foregroundColor: context.accent,
                visualDensity: VisualDensity.compact,
              ),
              child: const Text('Clear'),
            ),
          ],
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.tag});
  final _FilterTag tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
            context.accent.withValues(alpha: 0.1), context.cardBg),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.accent.withValues(alpha: 0.22)),
      ),
      child: Text(
        '${tag.key}: ${tag.value}',
        style: TextStyle(
          color: context.accent,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ResultsBody extends StatelessWidget {
  const _ResultsBody({
    required this.state,
    required this.onRetry,
    required this.onRefresh,
    required this.onTapResult,
  });

  final _SearchState state;
  final VoidCallback onRetry;
  final Future<void> Function() onRefresh;
  final ValueChanged<_SearchItem> onTapResult;

  @override
  Widget build(BuildContext context) {
    final query = state.query.trim();
    if (query.isEmpty) {
      return const _InfoState(
        icon: Icons.search_rounded,
        title: 'Find Anything Fast',
        subtitle: 'Search players, teams, venues, tournaments, or events.',
      );
    }
    if (query.length < _minResultChars) {
      return const _InfoState(
        icon: Icons.keyboard_rounded,
        title: 'Type More',
        subtitle: 'Enter at least 4 characters for full results.',
      );
    }
    if (state.isLoading && !state.hasAnyResults) {
      return Center(
        child: CircularProgressIndicator(color: context.accent),
      );
    }
    if (state.error != null && !state.hasAnyResults) {
      return _ErrorState(error: state.error!, onRetry: onRetry);
    }
    if (!state.hasAnyResults && state.hasSearched && !state.isLoading) {
      return _InfoState(
        icon: Icons.search_off_rounded,
        title: 'No Results',
        subtitle: 'No results found for "$query". Try different keywords.',
      );
    }

    final visibleKinds = _visibleKinds(state);
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: context.accent,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 18),
        itemCount: visibleKinds.length,
        itemBuilder: (_, index) {
          final kind = visibleKinds[index];
          final items = state.sections[kind] ?? const <_SearchItem>[];
          if (items.isEmpty) return const SizedBox.shrink();
          return _SearchSection(
            kind: kind,
            items: items,
            totalCount: state.counts[kind] ?? items.length,
            onTapResult: onTapResult,
          );
        },
      ),
    );
  }

  List<_EntityKind> _visibleKinds(_SearchState state) {
    if (state.type == _SearchType.all) {
      return _EntityKind.values
          .where((kind) => (state.sections[kind] ?? const []).isNotEmpty)
          .toList();
    }
    final kind = state.type == _SearchType.players
        ? _EntityKind.players
        : state.type == _SearchType.teams
            ? _EntityKind.teams
            : state.type == _SearchType.venues
                ? _EntityKind.venues
                : state.type == _SearchType.tournaments
                    ? _EntityKind.tournaments
                    : _EntityKind.events;
    return [kind];
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection({
    required this.kind,
    required this.items,
    required this.totalCount,
    required this.onTapResult,
  });

  final _EntityKind kind;
  final List<_SearchItem> items;
  final int totalCount;
  final ValueChanged<_SearchItem> onTapResult;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 8, 2, 8),
            child: Row(
              children: [
                Icon(kind.icon, size: 16, color: context.accent),
                const SizedBox(width: 6),
                Text(
                  kind.label,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '$totalCount',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SearchResultTile(
                item: item,
                onTap: () => onTapResult(item),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.item,
    required this.onTap,
  });

  final _SearchItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.stroke),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                _ResultLeading(item: item),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.fg,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (item.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          item.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.fgSub,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: context.fgSub),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultLeading extends StatelessWidget {
  const _ResultLeading({required this.item});
  final _SearchItem item;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = item.avatarUrl?.trim();
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 19,
        backgroundColor: context.panel,
        backgroundImage: CachedNetworkImageProvider(avatarUrl),
      );
    }
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: context.panel,
        shape: BoxShape.circle,
      ),
      child: Icon(
        item.kind.icon,
        color: context.accent,
        size: 18,
      ),
    );
  }
}

class _InfoState extends StatelessWidget {
  const _InfoState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.cardBg,
              ),
              child: Icon(icon, color: context.fgSub, size: 28),
            ),
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
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                color: context.fgSub,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 40, color: context.fgSub),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.fgSub, fontSize: 13.5),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FiltersSheet extends StatefulWidget {
  const _FiltersSheet({
    required this.current,
    required this.type,
  });

  final _SearchFilters current;
  final _SearchType type;

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late final TextEditingController _cityCtrl;
  String? _playerRole;
  String? _playerLevel;
  String? _teamType;
  String? _format;
  String? _sport;
  String? _tournamentStatus;

  static const _playerRoles = [
    'BATTER',
    'BOWLER',
    'ALL_ROUNDER',
    'WICKET_KEEPER',
  ];
  static const _playerLevels = [
    'BEGINNER',
    'INTERMEDIATE',
    'ADVANCED',
    'PRO',
  ];
  static const _teamTypes = [
    'CLUB',
    'ACADEMY',
    'CORPORATE',
    'SCHOOL',
    'COLLEGE',
  ];
  static const _formats = ['T10', 'T20', 'ODI', 'TEST'];
  static const _sports = ['CRICKET'];
  static const _tournamentStatuses = [
    'UPCOMING',
    'LIVE',
    'COMPLETED',
    'CANCELLED'
  ];

  @override
  void initState() {
    super.initState();
    _cityCtrl = TextEditingController(text: widget.current.city ?? '');
    _playerRole = widget.current.playerRole;
    _playerLevel = widget.current.playerLevel;
    _teamType = widget.current.teamType;
    _format = widget.current.format;
    _sport = widget.current.sport;
    _tournamentStatus = widget.current.tournamentStatus;
  }

  @override
  void dispose() {
    _cityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final includePlayers =
        widget.type == _SearchType.all || widget.type == _SearchType.players;
    final includeTeams =
        widget.type == _SearchType.all || widget.type == _SearchType.teams;
    final includeTournaments = widget.type == _SearchType.all ||
        widget.type == _SearchType.tournaments;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: context.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom + 14,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: context.stroke,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Search Filters',
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _cityCtrl.clear();
                        _playerRole = null;
                        _playerLevel = null;
                        _teamType = null;
                        _format = null;
                        _sport = null;
                        _tournamentStatus = null;
                      });
                    },
                    child: const Text('Clear all'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _cityCtrl,
                textInputAction: TextInputAction.next,
                style: TextStyle(color: context.fg),
                decoration: InputDecoration(
                  labelText: 'City',
                  labelStyle: TextStyle(color: context.fgSub),
                  hintText: 'e.g. Delhi',
                  hintStyle: TextStyle(color: context.fgSub),
                  prefixIcon: Icon(Icons.location_city_rounded,
                      color: context.fgSub, size: 18),
                  filled: true,
                  fillColor: context.cardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.stroke),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.stroke),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (includePlayers) ...[
                        _ChoiceWrap(
                          title: 'Player Role',
                          options: _playerRoles,
                          selected: _playerRole,
                          onChanged: (v) => setState(() => _playerRole = v),
                        ),
                        const SizedBox(height: 8),
                        _ChoiceWrap(
                          title: 'Player Level',
                          options: _playerLevels,
                          selected: _playerLevel,
                          onChanged: (v) => setState(() => _playerLevel = v),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (includeTeams) ...[
                        _ChoiceWrap(
                          title: 'Team Type',
                          options: _teamTypes,
                          selected: _teamType,
                          onChanged: (v) => setState(() => _teamType = v),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (includeTournaments) ...[
                        _ChoiceWrap(
                          title: 'Format',
                          options: _formats,
                          selected: _format,
                          onChanged: (v) => setState(() => _format = v),
                        ),
                        const SizedBox(height: 8),
                        _ChoiceWrap(
                          title: 'Sport',
                          options: _sports,
                          selected: _sport,
                          onChanged: (v) => setState(() => _sport = v),
                        ),
                        const SizedBox(height: 8),
                        _ChoiceWrap(
                          title: 'Tournament Status',
                          options: _tournamentStatuses,
                          selected: _tournamentStatus,
                          onChanged: (v) =>
                              setState(() => _tournamentStatus = v),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop(
                      _SearchFilters(
                        city: _normalized(_cityCtrl.text),
                        playerRole: _playerRole,
                        playerLevel: _playerLevel,
                        teamType: _teamType,
                        format: _format,
                        sport: _sport,
                        tournamentStatus: _tournamentStatus,
                      ),
                    );
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceWrap extends StatelessWidget {
  const _ChoiceWrap({
    required this.title,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final String title;
  final List<String> options;
  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: context.fgSub,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected == option;
            return ChoiceChip(
              label: Text(
                _labelize(option),
                style: TextStyle(
                  color: isSelected ? context.accent : context.fgSub,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onChanged(isSelected ? null : option),
              backgroundColor: context.cardBg,
              selectedColor: Color.alphaBlend(
                  context.accent.withValues(alpha: 0.16), context.cardBg),
              side: BorderSide(
                color: isSelected
                    ? context.accent.withValues(alpha: 0.45)
                    : context.stroke,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),
      ],
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> _asListMap(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((raw) => Map<String, dynamic>.from(raw))
      .toList();
}

String _string(dynamic value) => (value ?? '').toString().trim();

String? _stringOrNull(dynamic value) {
  final normalized = _string(value);
  return normalized.isEmpty ? null : normalized;
}

String _firstFilled(List<String> values) {
  for (final value in values) {
    if (value.trim().isNotEmpty) return value.trim();
  }
  return '';
}

List<String> _uniqueNonEmpty(List<String> values) {
  final out = <String>[];
  final seen = <String>{};
  for (final value in values) {
    final normalized = value.trim();
    if (normalized.isEmpty || !seen.add(normalized)) continue;
    out.add(normalized);
  }
  return out;
}

String _joinParts(List<String> values) {
  return values.where((v) => v.trim().isNotEmpty).join(' • ');
}

bool _isFilled(String? value) => value != null && value.trim().isNotEmpty;

String? _normalized(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _labelize(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return value;
  return value
      .toLowerCase()
      .split(RegExp(r'[_\s]+'))
      .map((part) =>
          part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
