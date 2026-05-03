import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../providers/academy_provider.dart';

class SessionFilter {
  final DateTime from;
  final DateTime to;
  final String? batchId;

  const SessionFilter({required this.from, required this.to, this.batchId});

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toParams() => {
        'from': _fmt(from),
        'to': _fmt(to),
        if (batchId != null) 'batchId': batchId,
      };
}

class SessionsNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<Map<String, dynamic>>, SessionFilter> {
  @override
  Future<List<Map<String, dynamic>>> build(SessionFilter arg) async {
    final s = await ref.watch(academyProvider.future);
    final res = await ref.read(apiClientProvider)
        .get('/academy/${s.academyId}/sessions', params: arg.toParams());
    final data = res.data['data'];
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data['items'] != null) {
      return (data['items'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }
}

final sessionsProvider =
    AsyncNotifierProvider.autoDispose.family<SessionsNotifier, List<Map<String, dynamic>>, SessionFilter>(
  SessionsNotifier.new,
);

final sessionDetailProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, sessionId) async {
  final s = await ref.watch(academyProvider.future);
  final res =
      await ref.read(apiClientProvider).get('/academy/${s.academyId}/sessions/$sessionId');
  return Map<String, dynamic>.from(res.data['data'] as Map);
});

final attendanceReportProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, SessionFilter>((ref, filter) async {
  final s = await ref.watch(academyProvider.future);
  final res = await ref.read(apiClientProvider).get(
    '/academy/${s.academyId}/attendance-report',
    params: filter.toParams(),
  );
  return Map<String, dynamic>.from(res.data['data'] as Map);
});
