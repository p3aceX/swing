import 'package:dio/dio.dart';
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
    if (data is Map) {
      if (data['items'] != null) return (data['items'] as List).cast<Map<String, dynamic>>();
      if (data['data']  != null) return (data['data']  as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> enroll(String batchId, Map<String, dynamic> payload) async {
    final s = await ref.read(academyProvider.future);
    try {
      await ref.read(apiClientProvider)
          .post('/academy/${s.academyId}/batches/$batchId/students', data: payload);
    } on DioException catch (e) {
      final body   = e.response?.data as Map?;
      final errObj = body?['error'] as Map?;
      final msg    = (body?['message'] ?? errObj?['message'] ?? 'Enrollment failed') as String;
      throw Exception(msg);
    }
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
  final list = await ref.watch(studentsProvider.future);
  try {
    return list.firstWhere((e) => e['id'] == enrollmentId);
  } catch (_) {
    throw Exception('Student not found');
  }
});
