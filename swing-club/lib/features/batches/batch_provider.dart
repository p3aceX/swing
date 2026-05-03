import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../providers/academy_provider.dart';

class BatchesNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final s = await ref.watch(academyProvider.future);
    final res = await ref.read(apiClientProvider).get('/academy/${s.academyId}/batches');
    final data = res.data['data'];
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data['items'] != null) {
      return (data['items'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> create(Map<String, dynamic> payload) async {
    final s = await ref.read(academyProvider.future);
    await ref.read(apiClientProvider).post('/academy/${s.academyId}/batches', data: payload);
    ref.invalidateSelf();
  }

  Future<void> updateBatch(String batchId, Map<String, dynamic> payload) async {
    final s = await ref.read(academyProvider.future);
    await ref.read(apiClientProvider).patch('/academy/${s.academyId}/batches/$batchId', data: payload);
    ref.invalidateSelf();
  }
}

final batchesProvider =
    AsyncNotifierProvider<BatchesNotifier, List<Map<String, dynamic>>>(BatchesNotifier.new);

final batchDetailProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, batchId) async {
  final s = await ref.watch(academyProvider.future);
  final res = await ref.read(apiClientProvider).get('/academy/${s.academyId}/batches/$batchId');
  return Map<String, dynamic>.from(res.data['data'] as Map);
});

class BatchSchedulesNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<Map<String, dynamic>>, String> {
  @override
  Future<List<Map<String, dynamic>>> build(String arg) async {
    final s = await ref.watch(academyProvider.future);
    final res =
        await ref.read(apiClientProvider).get('/academy/${s.academyId}/batches/$arg/schedules');
    final data = res.data['data'];
    if (data is List) return data.cast<Map<String, dynamic>>();
    return [];
  }

  Future<void> add(Map<String, dynamic> payload) async {
    final s = await ref.read(academyProvider.future);
    await ref.read(apiClientProvider).post('/academy/${s.academyId}/batches/$arg/schedules', data: payload);
    ref.invalidateSelf();
  }

  Future<void> remove(String scheduleId) async {
    final s = await ref.read(academyProvider.future);
    await ref.read(apiClientProvider).delete('/academy/${s.academyId}/batches/$arg/schedules/$scheduleId');
    ref.invalidateSelf();
  }
}

final batchSchedulesProvider =
    AsyncNotifierProvider.autoDispose.family<BatchSchedulesNotifier, List<Map<String, dynamic>>, String>(
  BatchSchedulesNotifier.new,
);
