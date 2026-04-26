import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../domain/admin_match.dart';

class MatchesQuery {
  const MatchesQuery({
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
      other is MatchesQuery &&
      other.status == status &&
      other.search == search &&
      other.page == page &&
      other.limit == limit;

  @override
  int get hashCode => Object.hash(status, search, page, limit);
}

class MatchOpsSummary {
  const MatchOpsSummary({
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

class MatchesRepository {
  MatchesRepository(this._api);

  final ApiClient _api;

  Future<AdminMatchesPage> list(MatchesQuery query) async {
    final resp = await _api.get('/admin/matches', query: {
      'page': '${query.page}',
      'limit': '${query.limit}',
      if (query.status != null && query.status!.isNotEmpty) 'status': query.status!,
      if (query.search != null && query.search!.isNotEmpty) 'search': query.search!,
    });
    return _parsePage(resp, query.page, query.limit);
  }

  Future<AdminMatch> detail(String id) async {
    final resp = await _api.get('/admin/matches/$id');
    final data = resp is Map<String, dynamic>
        ? resp
        : (resp is Map ? Map<String, dynamic>.from(resp) : <String, dynamic>{});
    if (data.isEmpty) {
      throw ApiException('Unexpected response from /admin/matches/$id');
    }
    return AdminMatch.fromJson(data);
  }

  Future<void> delete(String id) async {
    await _api.delete('/admin/matches/$id');
  }

  Future<Map<String, dynamic>> players(String id) async {
    final resp = await _api.get('/admin/matches/$id/players');
    return _toMap(resp, '/admin/matches/$id/players');
  }

  Future<Map<String, dynamic>?> stream(String id) async {
    final resp = await _api.get('/admin/matches/$id/stream');
    if (resp == null) return null;
    return _toMap(resp, '/admin/matches/$id/stream');
  }

  Future<Map<String, dynamic>> studio(String id) async {
    final resp = await _api.get('/admin/matches/$id/studio');
    return _toMap(resp, '/admin/matches/$id/studio');
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

  Future<int> count(String? status) async {
    final resp = await _api.get('/admin/matches', query: {
      'page': '1',
      'limit': '1',
      if (status != null && status.isNotEmpty) 'status': status,
    });
    return _parsePage(resp, 1, 1).total;
  }

  Future<MatchOpsSummary> summary() async {
    final counts = await Future.wait([
      count(null),
      count('IN_PROGRESS'),
      count('SCHEDULED'),
      count('COMPLETED'),
    ]);
    return MatchOpsSummary(
      total: counts[0],
      live: counts[1],
      scheduled: counts[2],
      complete: counts[3],
    );
  }

  Future<List<AdminMatch>> listAll({String? status, int limit = 100}) async {
    final first = await list(MatchesQuery(status: status, page: 1, limit: limit));
    final items = <AdminMatch>[...first.matches];
    final totalPages = (first.total / first.limit).ceil();
    if (totalPages <= 1) return items;
    for (var page = 2; page <= totalPages; page++) {
      final next = await list(MatchesQuery(status: status, page: page, limit: limit));
      items.addAll(next.matches);
    }
    return items;
  }

  AdminMatchesPage _parsePage(dynamic resp, int fallbackPage, int fallbackLimit) {
    List<dynamic> raw = const [];
    int total = 0;
    int page = fallbackPage;
    int limit = fallbackLimit;

    if (resp is Map) {
      final items = resp['matches'] ?? resp['items'] ?? resp['data'] ?? resp['results'];
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

    return AdminMatchesPage(
      matches: raw
          .whereType<Map>()
          .map((item) => AdminMatch.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      total: total,
      page: page,
      limit: limit,
    );
  }
}

final matchesRepositoryProvider = Provider<MatchesRepository>((ref) {
  return MatchesRepository(ref.watch(apiClientProvider));
});

final matchesListProvider =
    FutureProvider.family<AdminMatchesPage, MatchesQuery>((ref, query) {
  return ref.watch(matchesRepositoryProvider).list(query);
});

final matchesSummaryProvider = FutureProvider<MatchOpsSummary>((ref) {
  return ref.watch(matchesRepositoryProvider).summary();
});

final matchesTrendItemsProvider = FutureProvider<List<AdminMatch>>((ref) {
  return ref.watch(matchesRepositoryProvider).listAll(limit: 100);
});

final matchDetailProvider =
    FutureProvider.family<AdminMatch, String>((ref, matchId) {
  return ref.watch(matchesRepositoryProvider).detail(matchId);
});

final matchPlayersProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, matchId) {
  return ref.watch(matchesRepositoryProvider).players(matchId);
});

final matchStreamProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, matchId) {
  return ref.watch(matchesRepositoryProvider).stream(matchId);
});

final matchStudioProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, matchId) {
  return ref.watch(matchesRepositoryProvider).studio(matchId);
});
