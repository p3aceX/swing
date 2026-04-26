import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../domain/admin_tournament.dart';

class TournamentsQuery {
  const TournamentsQuery({
    this.status,
    this.search,
    this.page = 1,
    this.limit = 20,
  });

  final String? status;
  final String? search;
  final int page;
  final int limit;

  @override
  bool operator ==(Object other) =>
      other is TournamentsQuery &&
      other.status == status &&
      other.search == search &&
      other.page == page &&
      other.limit == limit;

  @override
  int get hashCode => Object.hash(status, search, page, limit);
}

class TournamentOpsSummary {
  const TournamentOpsSummary({
    required this.total,
    required this.live,
    required this.scheduled,
    required this.complete,
  });

  final int total;
  final int live;
  final int scheduled;
  final int complete;
}

class TournamentsRepository {
  TournamentsRepository(this._api);

  final ApiClient _api;

  Future<AdminTournamentsPage> list(TournamentsQuery query) async {
    final resp = await _api.get('/admin/tournaments', query: {
      'page': '${query.page}',
      'limit': '${query.limit}',
      if (query.status != null && query.status!.isNotEmpty) 'status': query.status!,
      if (query.search != null && query.search!.isNotEmpty) 'search': query.search!,
    });
    return _parsePage(resp, query.page, query.limit);
  }

  Future<int> count(String? status) async {
    final resp = await _api.get('/admin/tournaments', query: {
      'page': '1',
      'limit': '1',
      if (status != null && status.isNotEmpty) 'status': status,
    });
    return _parsePage(resp, 1, 1).total;
  }

  Future<TournamentOpsSummary> summary() async {
    final counts = await Future.wait([
      count(null),
      count('LIVE'),
      count('UPCOMING'),
      count('COMPLETED'),
    ]);
    return TournamentOpsSummary(
      total: counts[0],
      live: counts[1],
      scheduled: counts[2],
      complete: counts[3],
    );
  }

  Future<List<AdminTournament>> listAll({String? status, int limit = 100}) async {
    final first =
        await list(TournamentsQuery(status: status, page: 1, limit: limit));
    final items = <AdminTournament>[...first.tournaments];
    final totalPages = (first.total / first.limit).ceil();
    if (totalPages <= 1) return items;
    for (var page = 2; page <= totalPages; page++) {
      final next =
          await list(TournamentsQuery(status: status, page: page, limit: limit));
      items.addAll(next.tournaments);
    }
    return items;
  }

  Future<Map<String, dynamic>> detail(String id) async {
    final resp = await _api.get('/admin/tournaments/$id');
    return _toMap(resp, '/admin/tournaments/$id');
  }

  Future<List<dynamic>> teams(String id) async {
    return _toList(await _api.get('/admin/tournaments/$id/teams'));
  }

  Future<List<dynamic>> groups(String id) async {
    return _toList(await _api.get('/admin/tournaments/$id/groups'));
  }

  Future<Map<String, dynamic>> standings(String id) async {
    final resp = await _api.get('/admin/tournaments/$id/standings');
    return _toMap(resp, '/admin/tournaments/$id/standings');
  }

  Future<List<dynamic>> schedule(String id) async {
    return _toList(await _api.get('/admin/tournaments/$id/schedule'));
  }

  Future<void> delete(String id) async {
    await _api.delete('/admin/tournaments/$id');
  }

  Map<String, dynamic> _toMap(dynamic resp, String path) {
    final data = resp is Map<String, dynamic>
        ? resp
        : (resp is Map ? Map<String, dynamic>.from(resp) : <String, dynamic>{});
    if (data.isEmpty) {
      throw ApiException('Unexpected response from $path');
    }
    return data;
  }

  List<dynamic> _toList(dynamic resp) {
    if (resp is List) return resp;
    if (resp is Map) {
      final items = resp['items'] ?? resp['data'] ?? resp['results'];
      if (items is List) return items;
    }
    return const [];
  }

  AdminTournamentsPage _parsePage(
      dynamic resp, int fallbackPage, int fallbackLimit) {
    List<dynamic> raw = const [];
    int total = 0;
    int page = fallbackPage;
    int limit = fallbackLimit;

    if (resp is Map) {
      final items =
          resp['tournaments'] ?? resp['items'] ?? resp['data'] ?? resp['results'];
      if (items is List) raw = items;
      final rawTotal = resp['total'] ?? resp['count'];
      if (rawTotal is int) total = rawTotal;
      if (rawTotal is String) total = int.tryParse(rawTotal) ?? 0;
      final rawPage = resp['page'];
      if (rawPage is int) page = rawPage;
      if (rawPage is String) page = int.tryParse(rawPage) ?? page;
      final rawLimit = resp['limit'] ?? resp['pageSize'];
      if (rawLimit is int) limit = rawLimit;
      if (rawLimit is String) limit = int.tryParse(rawLimit) ?? limit;
    } else if (resp is List) {
      raw = resp;
      total = resp.length;
    }

    if (total == 0) total = raw.length;

    return AdminTournamentsPage(
      tournaments: raw
          .whereType<Map>()
          .map((item) =>
              AdminTournament.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      total: total,
      page: page,
      limit: limit,
    );
  }
}

final tournamentsRepositoryProvider = Provider<TournamentsRepository>((ref) {
  return TournamentsRepository(ref.watch(apiClientProvider));
});

final tournamentsListProvider =
    FutureProvider.family<AdminTournamentsPage, TournamentsQuery>((ref, query) {
  return ref.watch(tournamentsRepositoryProvider).list(query);
});

final tournamentsSummaryProvider = FutureProvider<TournamentOpsSummary>((ref) {
  return ref.watch(tournamentsRepositoryProvider).summary();
});

final tournamentsTrendItemsProvider = FutureProvider<List<AdminTournament>>((ref) {
  return ref.watch(tournamentsRepositoryProvider).listAll(limit: 100);
});

final tournamentDetailProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, tournamentId) {
  return ref.watch(tournamentsRepositoryProvider).detail(tournamentId);
});

final tournamentTeamsProvider =
    FutureProvider.family<List<dynamic>, String>((ref, tournamentId) {
  return ref.watch(tournamentsRepositoryProvider).teams(tournamentId);
});

final tournamentGroupsProvider =
    FutureProvider.family<List<dynamic>, String>((ref, tournamentId) {
  return ref.watch(tournamentsRepositoryProvider).groups(tournamentId);
});

final tournamentStandingsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, tournamentId) {
  return ref.watch(tournamentsRepositoryProvider).standings(tournamentId);
});

final tournamentScheduleProvider =
    FutureProvider.family<List<dynamic>, String>((ref, tournamentId) {
  return ref.watch(tournamentsRepositoryProvider).schedule(tournamentId);
});
