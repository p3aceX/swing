import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../providers/academy_provider.dart';

class StaffNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final s = await ref.watch(academyProvider.future);
    final res = await ref.read(apiClientProvider).get('/academy/${s.academyId}/staff');
    final data = res.data['data'];
    if (data is List) return data.cast<Map<String, dynamic>>();
    return [];
  }

  Future<void> create(Map<String, dynamic> payload) async {
    final s = await ref.read(academyProvider.future);
    await ref.read(apiClientProvider).post('/academy/${s.academyId}/staff', data: payload);
    ref.invalidateSelf();
  }

  Future<void> edit(String staffId, Map<String, dynamic> payload) async {
    final s = await ref.read(academyProvider.future);
    await ref.read(apiClientProvider).patch('/academy/${s.academyId}/staff/$staffId', data: payload);
    ref.invalidateSelf();
  }

  Future<void> remove(String staffId) async {
    final s = await ref.read(academyProvider.future);
    await ref.read(apiClientProvider).delete('/academy/${s.academyId}/staff/$staffId');
    ref.invalidateSelf();
  }
}

final staffProvider =
    AsyncNotifierProvider<StaffNotifier, List<Map<String, dynamic>>>(StaffNotifier.new);

class PayrollNotifier extends AutoDisposeFamilyAsyncNotifier<Map<String, dynamic>, ({int year, int month})> {
  @override
  Future<Map<String, dynamic>> build(({int year, int month}) arg) async {
    final s = await ref.watch(academyProvider.future);
    final res = await ref.read(apiClientProvider).get(
      '/academy/${s.academyId}/payroll',
      params: {'year': arg.year.toString(), 'month': arg.month.toString()},
    );
    return res.data['data'] as Map<String, dynamic>? ?? {};
  }
}

final payrollProvider = AsyncNotifierProvider.autoDispose
    .family<PayrollNotifier, Map<String, dynamic>, ({int year, int month})>(
  PayrollNotifier.new,
);
