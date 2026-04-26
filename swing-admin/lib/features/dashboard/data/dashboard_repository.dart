import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';

class DashboardMetrics {
  const DashboardMetrics({
    required this.totalArenas,
    required this.verifiedArenas,
    required this.swingEnabledArenas,
    required this.totalTournaments,
    required this.liveTournaments,
    required this.completedTournaments,
  });

  final int totalArenas;
  final int verifiedArenas;
  final int swingEnabledArenas;
  final int totalTournaments;
  final int liveTournaments;
  final int completedTournaments;
}

class DashboardRepository {
  DashboardRepository(this._api);
  final ApiClient _api;

  Future<DashboardMetrics> fetch() async {
    int totalArenas = 0;
    int verifiedArenas = 0;
    int swingEnabledArenas = 0;
    int totalTournaments = 0;
    int liveTournaments = 0;
    int completedTournaments = 0;

    final arenasResp = await _api.get('/arenas', query: {'limit': '100'});
    final arenaList = _extractList(arenasResp, 'arenas');
    totalArenas = _extractTotal(arenasResp) ?? arenaList.length;
    for (final a in arenaList) {
      if (a is Map) {
        if (a['isVerified'] == true) verifiedArenas++;
        if (a['isSwingArena'] == true) swingEnabledArenas++;
      }
    }

    try {
      final tResp = await _api.get('/public/tournaments', query: {'limit': '100'});
      final tList = tResp is List
          ? tResp
          : _extractList(tResp, 'tournaments');
      totalTournaments = tList.length;
      for (final t in tList) {
        if (t is Map) {
          final status = t['status']?.toString().toUpperCase() ?? '';
          if (status == 'IN_PROGRESS' || status == 'LIVE' || status == 'ACTIVE') {
            liveTournaments++;
          } else if (status == 'COMPLETED' || status == 'COMPLETE') {
            completedTournaments++;
          }
        }
      }
    } catch (_) {
      // tournaments call is optional
    }

    return DashboardMetrics(
      totalArenas: totalArenas,
      verifiedArenas: verifiedArenas,
      swingEnabledArenas: swingEnabledArenas,
      totalTournaments: totalTournaments,
      liveTournaments: liveTournaments,
      completedTournaments: completedTournaments,
    );
  }

  List<dynamic> _extractList(dynamic resp, String key) {
    if (resp is List) return resp;
    if (resp is Map) {
      final v = resp[key];
      if (v is List) return v;
      final items = resp['items'];
      if (items is List) return items;
    }
    return const [];
  }

  int? _extractTotal(dynamic resp) {
    if (resp is Map) {
      final t = resp['total'] ?? resp['count'];
      if (t is int) return t;
      if (t is String) return int.tryParse(t);
    }
    return null;
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(apiClientProvider));
});

final dashboardMetricsProvider = FutureProvider<DashboardMetrics>((ref) {
  return ref.watch(dashboardRepositoryProvider).fetch();
});
