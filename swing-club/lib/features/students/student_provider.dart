import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../providers/academy_provider.dart';

class StudentsNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final s = await ref.watch(academyProvider.future);
    final res = await ref.read(apiClientProvider)
        .get('/academy/${s.academyId}/students', params: {'limit': 100});
    final data = res.data['data'];
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data['items'] != null) {
      return (data['items'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> enroll(String batchId, Map<String, dynamic> payload) async {
    final s = await ref.read(academyProvider.future);
    await ref.read(apiClientProvider)
        .post('/academy/${s.academyId}/batches/$batchId/students', data: payload);
    ref.invalidateSelf();
  }

  Future<void> updateEnrollment(String enrollmentId, Map<String, dynamic> payload) async {
    final s = await ref.read(academyProvider.future);
    await ref.read(apiClientProvider)
        .patch('/academy/${s.academyId}/students/$enrollmentId', data: payload);
    ref.invalidateSelf();
  }
}

final studentsProvider =
    AsyncNotifierProvider<StudentsNotifier, List<Map<String, dynamic>>>(StudentsNotifier.new);

final studentDetailProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, enrollmentId) async {
  final s = await ref.watch(academyProvider.future);
  final res =
      await ref.read(apiClientProvider).get('/academy/${s.academyId}/students/$enrollmentId');
  return Map<String, dynamic>.from(res.data['data'] as Map);
});
