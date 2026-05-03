import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../providers/academy_provider.dart';

class InventoryNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final s = await ref.watch(academyProvider.future);
    final res = await ref.read(apiClientProvider).get('/academy/${s.academyId}/inventory');
    final data = res.data['data'];
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data['items'] != null) {
      return (data['items'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> add(Map<String, dynamic> payload) async {
    final s = await ref.read(academyProvider.future);
    await ref.read(apiClientProvider).post('/academy/${s.academyId}/inventory', data: payload);
    ref.invalidateSelf();
  }
}

final inventoryProvider =
    AsyncNotifierProvider<InventoryNotifier, List<Map<String, dynamic>>>(InventoryNotifier.new);
