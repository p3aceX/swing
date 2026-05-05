import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../providers/academy_provider.dart';

class PaymentsNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final s = await ref.watch(academyProvider.future);
    final res = await ref.read(apiClientProvider)
        .get('/academy/${s.academyId}/fee-payments', params: {'limit': '200'});
    final data = res.data['data'];
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map) {
      final inner = data['data'] ?? data['items'];
      if (inner is List) return inner.cast<Map<String, dynamic>>();
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
    // No GET fee-structures endpoint exists; extract from batches
    final res = await ref.read(apiClientProvider).get('/academy/${s.academyId}/batches');
    final raw = res.data['data'];
    final batches = raw is List ? raw.cast<Map<String, dynamic>>() : <Map<String, dynamic>>[];
    final out = <Map<String, dynamic>>[];
    for (final batch in batches) {
      for (final fee in (batch['feeStructures'] as List? ?? []).cast<Map<String, dynamic>>()) {
        out.add({...fee, 'batch': {'name': batch['name'] as String? ?? ''}});
      }
    }
    return out;
  }

  Future<void> create(Map<String, dynamic> payload) async {
    final s = await ref.read(academyProvider.future);
    await ref.read(apiClientProvider).post('/academy/${s.academyId}/fee-structures', data: payload);
    ref.invalidateSelf();
  }
}

final feeStructuresProvider =
    AsyncNotifierProvider<FeeStructuresNotifier, List<Map<String, dynamic>>>(FeeStructuresNotifier.new);

class BatchPaymentsNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<Map<String, dynamic>>, String> {
  @override
  Future<List<Map<String, dynamic>>> build(String batchId) async {
    final s = await ref.watch(academyProvider.future);
    final res = await ref.read(apiClientProvider).get(
      '/academy/${s.academyId}/fee-payments',
      params: {'batchId': batchId, 'limit': 200},
    );
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
}

final batchPaymentsProvider = AsyncNotifierProvider.autoDispose
    .family<BatchPaymentsNotifier, List<Map<String, dynamic>>, String>(
  BatchPaymentsNotifier.new,
);

class ExpensesNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final s = await ref.watch(academyProvider.future);
    final res = await ref.read(apiClientProvider).get('/academy/${s.academyId}/expenses');
    final data = res.data['data'];
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data['items'] != null) {
      return (data['items'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> create(Map<String, dynamic> payload) async {
    final s = await ref.read(academyProvider.future);
    await ref.read(apiClientProvider).post('/academy/${s.academyId}/expenses', data: payload);
    ref.invalidateSelf();
  }

  Future<void> edit(String id, Map<String, dynamic> payload) async {
    final s = await ref.read(academyProvider.future);
    await ref.read(apiClientProvider).patch('/academy/${s.academyId}/expenses/$id', data: payload);
    ref.invalidateSelf();
  }

  Future<void> remove(String id) async {
    final s = await ref.read(academyProvider.future);
    await ref.read(apiClientProvider).delete('/academy/${s.academyId}/expenses/$id');
    ref.invalidateSelf();
  }
}

final expensesProvider =
    AsyncNotifierProvider<ExpensesNotifier, List<Map<String, dynamic>>>(ExpensesNotifier.new);

class FinanceSummaryNotifier extends AsyncNotifier<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> build() async {
    final s = await ref.watch(academyProvider.future);
    final now = DateTime.now();
    final res = await ref.read(apiClientProvider).get(
      '/academy/${s.academyId}/finance-summary',
      params: {'year': now.year.toString(), 'month': now.month.toString()},
    );
    return res.data['data'] as Map<String, dynamic>? ?? {};
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final financeSummaryProvider =
    AsyncNotifierProvider<FinanceSummaryNotifier, Map<String, dynamic>>(FinanceSummaryNotifier.new);
