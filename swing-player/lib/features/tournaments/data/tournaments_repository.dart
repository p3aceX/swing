import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../domain/tournament_models.dart';

class TournamentsRepository {
  final _client = ApiClient.instance.dio;

  Future<List<PlayerTournament>> fetchMyTournaments() async {
    final tournamentsResponse = await _client.get(ApiEndpoints.myTournaments);
    dynamic teamsData;
    dynamic publicTournamentsData;
    try {
      final teamsResponse = await _client.get(ApiEndpoints.myTeams);
      teamsData = teamsResponse.data;
    } catch (_) {
      teamsData = null;
    }
    try {
      final publicResponse = await _client.get(ApiEndpoints.publicTournaments);
      publicTournamentsData = publicResponse.data;
    } catch (_) {
      publicTournamentsData = null;
    }

    final tournamentsData = tournamentsResponse.data;
    final root = tournamentsData is Map ? tournamentsData : <String, dynamic>{};
    final membership = _extractMyTeams(teamsData);

    final publicRoot = publicTournamentsData is Map
        ? publicTournamentsData as Map<String, dynamic>
        : <String, dynamic>{};

    // The backend may return data as:
    //   (a) a Map with named buckets: { participatedTournaments: [...], hostedTournaments: [...], ... }
    //   (b) a flat List: [ { id, isParticipating, isHost, ... }, ... ]
    final dataField = root['data'];
    final Map<dynamic, dynamic> inner =
        dataField is Map ? dataField : const <String, dynamic>{};
    // Flat array — trust isParticipating / isHost flags in each item.
    final List<Map<String, dynamic>> flatPlayerRows =
        dataField is List ? _asTournamentMaps(dataField) : const [];

    final sources = [
      // ── Named buckets from /player/tournaments (map response) ──────────
      (
        rows: _asTournamentMaps(inner['participatedTournaments']),
        forceHosted: false,
        forceParticipating: true,
      ),
      (
        rows: _asTournamentMaps(inner['joinedTournaments']),
        forceHosted: false,
        forceParticipating: true,
      ),
      (
        rows: _asTournamentMaps(inner['registeredTournaments']),
        forceHosted: false,
        forceParticipating: true,
      ),
      (
        rows: _asTournamentMaps(inner['teamTournaments']),
        forceHosted: false,
        forceParticipating: true,
      ),
      (
        rows: _asTournamentMaps(inner['myTournaments']),
        forceHosted: false,
        forceParticipating: true,
      ),
      (
        rows: _asTournamentMaps(inner['hostedTournaments']),
        forceHosted: true,
        forceParticipating: false,
      ),
      // Generic bucket — any tournament returned by the player's authenticated
      // endpoint is player-associated; treat as participated (isHost filter
      // in the UI prevents hosted-only ones from leaking into Participated).
      (
        rows: _asTournamentMaps(inner['tournaments']),
        forceHosted: false,
        forceParticipating: true,
      ),
      // ── Flat-array response from /player/tournaments ───────────────────
      // isParticipating / isHost flags already set by the backend.
      (
        rows: flatPlayerRows,
        forceHosted: false,
        forceParticipating: false,
      ),
      // ── Public tournaments (fallback / team-name matching) ─────────────
      (
        rows: _asTournamentMaps(publicRoot['data']),
        forceHosted: false,
        forceParticipating: false,
      ),
    ];

    final merged = <String, PlayerTournament>{};
    for (final source in sources) {
      for (final raw in source.rows) {
        final tournament = PlayerTournament.fromJson(
          raw,
          myTeamIds: membership.ids,
          myTeamNames: membership.names,
          forceHosted: source.forceHosted,
          forceParticipating: source.forceParticipating,
        );
        final key = tournament.id.isNotEmpty
            ? tournament.id
            : '${tournament.slug ?? ''}:${tournament.name}';
        final existing = merged[key];
        merged[key] = existing == null
            ? tournament
            : existing.copyWith(
                isHost: existing.isHost || tournament.isHost,
                isParticipating:
                    existing.isParticipating || tournament.isParticipating,
              );
      }
    }

    // ── Detail-based participation check ──────────────────────────────
    // The public tournament list doesn't include team data. If the player's
    // team membership is known but participation couldn't be detected from
    // the list, fetch each tournament's detail (which includes full teams)
    // and cross-reference. Run in parallel, capped to avoid excess calls.
    if (membership.ids.isNotEmpty || membership.names.isNotEmpty) {
      final publicList = _asTournamentMaps(publicRoot['data']);
      final toCheck = publicList.where((raw) {
        final id = '${raw['id'] ?? ''}'.trim();
        final slug = '${raw['slug'] ?? ''}'.trim();
        final key = id.isNotEmpty ? id : '$slug:${raw['name'] ?? ''}';
        return !(merged[key]?.isParticipating ?? false);
      }).take(20).toList();

      if (toCheck.isNotEmpty) {
        await Future.wait(toCheck.map((raw) async {
          final slug = '${raw['slug'] ?? raw['id'] ?? ''}'.trim();
          if (slug.isEmpty) return;
          try {
            final res = await _client
                .get(ApiEndpoints.publicTournamentBySlug(slug));
            final data = res.data;
            final dr = data is Map ? data as Map<String, dynamic> : {};
            final di = dr['data'] is Map
                ? dr['data'] as Map<String, dynamic>
                : dr;
            final teams = di['teams'] is List ? di['teams'] as List : [];

            final found = teams.whereType<Map>().any((t) {
              // Check nested team object (most common structure)
              final nested = t['team'];
              if (nested is Map) {
                if (membership.ids.contains(
                    '${nested['id'] ?? ''}'.trim().toLowerCase())) {
                  return true;
                }
                if (membership.names.contains(
                    '${nested['name'] ?? ''}'.trim().toLowerCase())) {
                  return true;
                }
                if (membership.names.contains(
                    '${nested['shortName'] ?? ''}'.trim().toLowerCase())) {
                  return true;
                }
              }
              // Fallback: flat fields on the entry
              if (membership.ids.contains(
                  '${t['teamId'] ?? ''}'.trim().toLowerCase())) return true;
              if (membership.names.contains(
                  '${t['teamName'] ?? ''}'.trim().toLowerCase())) return true;
              return false;
            });

            if (found) {
              final id = '${raw['id'] ?? ''}'.trim();
              final key = id.isNotEmpty
                  ? id
                  : '${raw['slug'] ?? ''}:${raw['name'] ?? ''}';
              final existing = merged[key];
              if (existing != null) {
                merged[key] = existing.copyWith(isParticipating: true);
              }
            }
          } catch (_) {}
        }));
      }
    }

    return merged.values.toList();
  }

  Future<List<PlayerTournament>> fetchPublicTournaments({
    String? query,
    String? city,
    String? format,
    String? status,
  }) async {
    final params = <String, dynamic>{};
    if (query != null && query.isNotEmpty) params['q'] = query;
    if (city != null && city.isNotEmpty) params['city'] = city;
    if (format != null && format.isNotEmpty) params['format'] = format;
    if (status != null && status.isNotEmpty) params['status'] = status;

    final response = await _client.get(
      ApiEndpoints.publicTournaments,
      queryParameters: params.isNotEmpty ? params : null,
    );
    final data = response.data;
    final root =
        data is Map ? data as Map<String, dynamic> : <String, dynamic>{};
    final list = root['data'] is List ? root['data'] as List : [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(PlayerTournament.fromJson)
        .toList();
  }

  Future<TournamentDetail> fetchTournamentDetail(String slug) async {
    if (kDebugMode) debugPrint('[TD] fetching detail slug=$slug');
    try {
      final response =
          await _client.get(ApiEndpoints.publicTournamentBySlug(slug));
      if (kDebugMode) debugPrint('[TD] status=${response.statusCode}');
      final data = response.data;
      final root =
          data is Map ? data as Map<String, dynamic> : <String, dynamic>{};
      final inner =
          root['data'] is Map ? root['data'] as Map<String, dynamic> : root;
      if (kDebugMode) {
        debugPrint('[TD] name=${inner['name']} id=${inner['id']}');
      }
      return TournamentDetail.fromJson(inner);
    } catch (e) {
      if (kDebugMode) debugPrint('[TD] error: $e');
      rethrow;
    }
  }

  Future<List<TournamentMatch>> fetchTournamentMatches(String slug) async {
    try {
      final response =
          await _client.get(ApiEndpoints.publicTournamentMatches(slug));
      final data = response.data;
      final root =
          data is Map ? data as Map<String, dynamic> : <String, dynamic>{};
      final list = root['data'] is List ? root['data'] as List : [];
      final result = list
          .whereType<Map<String, dynamic>>()
          .map(TournamentMatch.fromJson)
          .toList();
      if (kDebugMode) debugPrint('[TD] matches count=${result.length} slug=$slug');
      return result;
    } catch (e) {
      if (kDebugMode) debugPrint('[TD] matches error: $e slug=$slug');
      return [];
    }
  }

  Future<List<TournamentStanding>> fetchTournamentStandings(String slug) async {
    try {
      final response =
          await _client.get(ApiEndpoints.publicTournamentStandings(slug));
      final data = response.data;
      final root =
          data is Map ? data as Map<String, dynamic> : <String, dynamic>{};
      final list = root['data'] is List ? root['data'] as List : [];
      final result = list
          .whereType<Map<String, dynamic>>()
          .map(TournamentStanding.fromJson)
          .toList();
      if (kDebugMode) debugPrint('[TD] standings count=${result.length} slug=$slug');
      return result;
    } catch (e) {
      if (kDebugMode) debugPrint('[TD] standings error: $e slug=$slug');
      return [];
    }
  }

  Future<TournamentLeaderboard> fetchTournamentLeaderboard(String slug) async {
    try {
      final response =
          await _client.get(ApiEndpoints.publicTournamentLeaderboard(slug));
      final data = response.data;
      final root =
          data is Map ? data as Map<String, dynamic> : <String, dynamic>{};
      final inner =
          root['data'] is Map ? root['data'] as Map<String, dynamic> : root;
      final lb = TournamentLeaderboard.fromJson(inner);
      if (kDebugMode) {
        debugPrint('[TD] leaderboard batsmen=${lb.topBatsmen.length} bowlers=${lb.topBowlers.length} slug=$slug');
      }
      return lb;
    } catch (e) {
      if (kDebugMode) debugPrint('[TD] leaderboard error: $e slug=$slug');
      return const TournamentLeaderboard(
        topBatsmen: [],
        topBowlers: [],
        topFielders: [],
        tournamentTotals: TournamentTotals(),
      );
    }
  }
}

typedef _TeamMembership = ({Set<String> ids, Set<String> names});

List<Map<String, dynamic>> _asTournamentMaps(dynamic value) {
  if (value is List) {
    return value.whereType<Map<String, dynamic>>().toList();
  }
  return const [];
}

_TeamMembership _extractMyTeams(dynamic value) {
  final root = value is Map ? value : const <String, dynamic>{};
  final inner = root['data'] is Map ? root['data'] as Map : root;
  final rows = inner['teams'] is List ? inner['teams'] as List : const [];

  final ids = <String>{};
  final names = <String>{};
  for (final item in rows.whereType<Map>()) {
    final map = item.cast<String, dynamic>();
    final id = '${map['id'] ?? ''}'.trim().toLowerCase();
    final name = '${map['name'] ?? ''}'.trim().toLowerCase();
    final shortName = '${map['shortName'] ?? ''}'.trim().toLowerCase();
    if (id.isNotEmpty) ids.add(id);
    if (name.isNotEmpty) names.add(name);
    if (shortName.isNotEmpty) names.add(shortName);
  }

  return (ids: ids, names: names);
}

final tournamentsRepositoryProvider =
    Provider<TournamentsRepository>((_) => TournamentsRepository());
