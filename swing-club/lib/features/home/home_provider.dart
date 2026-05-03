import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../providers/academy_provider.dart';

class HomeData {
  final Map<String, dynamic> academy;
  final List<Map<String, dynamic>> todaySessions;
  final int pendingFeesCount;
  final bool hasNoAcademy;

  const HomeData({
    required this.academy,
    required this.todaySessions,
    required this.pendingFeesCount,
    this.hasNoAcademy = false,
  });

  static const empty = HomeData(academy: {}, todaySessions: [], pendingFeesCount: 0, hasNoAcademy: true);
}

class HomeNotifier extends AsyncNotifier<HomeData> {
  @override
  Future<HomeData> build() async {
    AcademyState academyState;
    try {
      academyState = await ref.watch(academyProvider.future);
    } catch (_) {
      return HomeData.empty;
    }

    final api = ref.read(apiClientProvider);
    final id = academyState.academyId;

    final now   = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).toIso8601String();
    final end   = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    List<Map<String, dynamic>> sessions = [];
    int pendingCount = 0;
    Map<String, dynamic> academyData = academyState.data;

    try {
      final results = await Future.wait([
        api.get('/academy/my'),
        api.get('/academy/$id/sessions', params: {'from': start, 'to': end}),
        api.get('/academy/$id/fee-payments', params: {'limit': '1'}),
      ]);

      final raw = results[0].data['data'];
      if (raw != null) academyData = Map<String, dynamic>.from(raw as Map);

      final sessionsRaw = results[1].data['data'];
      sessions = sessionsRaw is List
          ? sessionsRaw.cast<Map<String, dynamic>>()
          : (sessionsRaw?['items'] as List? ?? []).cast<Map<String, dynamic>>();

      final feesRaw = results[2].data['data'];
      if (feesRaw is Map && feesRaw['total'] != null) {
        pendingCount = feesRaw['total'] as int;
      } else if (feesRaw is List) {
        pendingCount = feesRaw.length;
      }
    } catch (_) {
      // Partial failure — show academy info with empty sessions/fees
    }

    return HomeData(
      academy: academyData,
      todaySessions: sessions,
      pendingFeesCount: pendingCount,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final homeProvider = AsyncNotifierProvider<HomeNotifier, HomeData>(HomeNotifier.new);
