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

  Future<String> create(Map<String, dynamic> payload) async {
    final s = await ref.read(academyProvider.future);
    final res = await ref.read(apiClientProvider)
        .post('/academy/${s.academyId}/batches', data: payload);
    ref.invalidateSelf();
    return (res.data['data'] as Map<String, dynamic>)['id'] as String;
  }

  Future<void> updateBatch(String batchId, Map<String, dynamic> payload) async {
    final s = await ref.read(academyProvider.future);
    await ref.read(apiClientProvider)
        .patch('/academy/${s.academyId}/batches/$batchId', data: payload);
    ref.invalidateSelf();
  }

  Future<void> addSchedule(String batchId, Map<String, dynamic> payload) async {
    final s = await ref.read(academyProvider.future);
    await ref.read(apiClientProvider)
        .post('/academy/${s.academyId}/batches/$batchId/schedules', data: payload);
  }

  Future<void> createFeeStructure(String batchId, Map<String, dynamic> payload) async {
    final s = await ref.read(academyProvider.future);
    final body = Map<String, dynamic>.from(payload);
    body['batchId'] = batchId;
    await ref.read(apiClientProvider)
        .post('/academy/${s.academyId}/fee-structures', data: body);
  }

  Future<Map<String, dynamic>?> inviteAndAssignCoach({
    required String batchId,
    required String phone,
    String? name,
    required bool isHeadCoach,
  }) async {
    final s = await ref.read(academyProvider.future);
    final res = await ref.read(apiClientProvider).post(
      '/academy/${s.academyId}/coaches',
      data: {
        'phone': phone,
        if (name != null && name.isNotEmpty) 'name': name,
        'isHeadCoach': isHeadCoach,
      },
    );
    return res.data['data'] as Map<String, dynamic>?;
  }

  Future<void> assignCoachToBatch(String batchId, String coachProfileId) async {
    final s = await ref.read(academyProvider.future);
    await ref.read(apiClientProvider).post(
      '/academy/${s.academyId}/batches/$batchId/coaches',
      data: {'coachId': coachProfileId},
    );
  }

  Future<void> removeCoachFromBatch(String batchId, String coachProfileId) async {
    final s = await ref.read(academyProvider.future);
    await ref.read(apiClientProvider)
        .delete('/academy/${s.academyId}/batches/$batchId/coaches/$coachProfileId');
  }

  Future<Map<String, dynamic>?> lookupCoach(String phone) async {
    final s = await ref.read(academyProvider.future);
    try {
      final res = await ref.read(apiClientProvider)
          .get('/academy/${s.academyId}/coaches');
      final data = res.data['data'];
      final list = data is List
          ? data.cast<Map<String, dynamic>>()
          : data is Map && data['items'] != null
              ? (data['items'] as List).cast<Map<String, dynamic>>()
              : <Map<String, dynamic>>[];
      final tail = phone.length >= 10 ? phone.substring(phone.length - 10) : phone;
      for (final coach in list) {
        final user = (coach['user'] as Map?)?.cast<String, dynamic>() ?? {};
        final userPhone = user['phone'] as String? ?? '';
        if (userPhone.endsWith(tail)) {
          return {
            'userName': user['name'] as String? ?? '',
            'coachProfileId': coach['coachProfileId'] as String? ?? coach['id'] as String? ?? '',
          };
        }
      }
    } catch (_) {}
    return null;
  }
}

final batchesProvider =
    AsyncNotifierProvider<BatchesNotifier, List<Map<String, dynamic>>>(BatchesNotifier.new);

final batchDetailProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, batchId) async {
  final s = await ref.watch(academyProvider.future);
  final res = await ref.read(apiClientProvider)
      .get('/academy/${s.academyId}/batches/$batchId');
  return Map<String, dynamic>.from(res.data['data'] as Map);
});

class BatchSchedulesNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<Map<String, dynamic>>, String> {
  @override
  Future<List<Map<String, dynamic>>> build(String arg) async {
    final s = await ref.watch(academyProvider.future);
    final res = await ref.read(apiClientProvider)
        .get('/academy/${s.academyId}/batches/$arg/schedules');
    final data = res.data['data'];
    if (data is List) return data.cast<Map<String, dynamic>>();
    return [];
  }

  Future<void> add(Map<String, dynamic> payload) async {
    final s = await ref.read(academyProvider.future);
    await ref.read(apiClientProvider)
        .post('/academy/${s.academyId}/batches/$arg/schedules', data: payload);
    ref.invalidateSelf();
  }

  Future<void> remove(String scheduleId) async {
    final s = await ref.read(academyProvider.future);
    await ref.read(apiClientProvider)
        .delete('/academy/${s.academyId}/batches/$arg/schedules/$scheduleId');
    ref.invalidateSelf();
  }
}

final batchSchedulesProvider =
    AsyncNotifierProvider.autoDispose
        .family<BatchSchedulesNotifier, List<Map<String, dynamic>>, String>(
  BatchSchedulesNotifier.new,
);
