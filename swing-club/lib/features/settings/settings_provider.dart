import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../providers/academy_provider.dart';
import '../../providers/auth_provider.dart';

class SettingsNotifier extends AsyncNotifier<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> build() async {
    ref.watch(authProvider);
    final res = await ref.read(apiClientProvider).get('/biz/me');
    return Map<String, dynamic>.from(res.data['data'] as Map);
  }

  Future<void> updateAcademy(String academyId, Map<String, dynamic> payload) async {
    await ref.read(apiClientProvider).put('/academy/$academyId', data: payload);
    ref.invalidate(academyProvider);
    ref.invalidateSelf();
  }

  Future<void> updateBusinessDetails(Map<String, dynamic> payload) async {
    final res = await ref.read(apiClientProvider).put('/biz/business-details', data: payload);
    // Update in-place so the UI doesn't flicker through loading (which dismisses snacks).
    final current = state.valueOrNull;
    final updated = (res.data['data'] as Map?)?.cast<String, dynamic>();
    if (current != null && updated != null) {
      state = AsyncData({...current, 'businessAccount': updated});
    } else {
      ref.invalidateSelf();
    }
  }

  Future<void> logout() async {
    try {
      await ref.read(apiClientProvider).post('/auth/logout');
    } catch (_) {}
    await ref.read(authProvider.notifier).logout();
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, Map<String, dynamic>>(SettingsNotifier.new);
