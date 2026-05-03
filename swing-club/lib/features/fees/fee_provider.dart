import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../providers/academy_provider.dart';

class PaymentsNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final s = await ref.watch(academyProvider.future);
    final res = await ref.read(apiClientProvider)
        .get('/academy/${s.academyId}/fee-payments', params: {'limit': 50});
    final data = res.data['data'];
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data['items'] != null) {
      return (data['items'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> recordPayment(Map<String, dynamic> payload) async {
    final s = await ref.read(academyProvider.future);
    await ref.read(apiClientProvider).post('/academy/${s.academyId}/fee-payments', data: payload);
    ref.invalidateSelf();
  }

  Future<void> sendReminder(String paymentId) async {
    final s = await ref.read(academyProvider.future);
    await ref.read(apiClientProvider)
        .post('/academy/${s.academyId}/fee-payments/$paymentId/remind');
  }
}

final paymentsProvider =
    AsyncNotifierProvider<PaymentsNotifier, List<Map<String, dynamic>>>(PaymentsNotifier.new);

class FeeStructuresNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final s = await ref.watch(academyProvider.future);
    final res =
        await ref.read(apiClientProvider).get('/academy/${s.academyId}/fee-structures');
    final data = res.data['data'];
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data['items'] != null) {
      return (data['items'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> create(Map<String, dynamic> payload) async {
    final s = await ref.read(academyProvider.future);
    await ref.read(apiClientProvider).post('/academy/${s.academyId}/fee-structures', data: payload);
    ref.invalidateSelf();
  }
}

final feeStructuresProvider =
    AsyncNotifierProvider<FeeStructuresNotifier, List<Map<String, dynamic>>>(FeeStructuresNotifier.new);
