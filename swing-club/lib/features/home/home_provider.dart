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

    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final results = await Future.wait([
      api.get('/academy/my'),
      api.get('/academy/$id/sessions', params: {'from': todayStr, 'to': todayStr}),
      api.get('/academy/$id/fee-payments', params: {'status': 'PENDING', 'limit': 1}),
    ]);

    final academyData = results[0].data['data'] as Map<String, dynamic>;
    final sessionsRaw = results[1].data['data'];
    final feesRaw = results[2].data['data'];

    final sessions = sessionsRaw is List
        ? sessionsRaw.cast<Map<String, dynamic>>()
        : (sessionsRaw?['items'] as List? ?? []).cast<Map<String, dynamic>>();

    int pendingCount = 0;
    if (feesRaw is Map && feesRaw['total'] != null) {
      pendingCount = feesRaw['total'] as int;
    } else if (feesRaw is List) {
      pendingCount = feesRaw.length;
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
