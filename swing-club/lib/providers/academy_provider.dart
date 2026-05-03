import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import 'auth_provider.dart';

class AcademyState {
  final String academyId;
  final Map<String, dynamic> data;
  const AcademyState({required this.academyId, required this.data});
}

class AcademyNotifier extends AsyncNotifier<AcademyState> {
  @override
  Future<AcademyState> build() async {
    final auth = ref.watch(authProvider);
    if (!auth.isAuthenticated) throw Exception('Not authenticated');

    final api = ref.read(apiClientProvider);
    final res = await api.get('/biz/me');
    final bizData = res.data['data'] as Map<String, dynamic>;
    final academies = (bizData['businessAccount']?['academyOwnerProfile']?['academies'] as List?) ?? [];
    if (academies.isEmpty) throw Exception('No academy found');

    final academy = Map<String, dynamic>.from(academies.first as Map);
    final academyId = academy['id'] as String;
    await ref.read(tokenStorageProvider).saveAcademyId(academyId);
    return AcademyState(academyId: academyId, data: academy);
  }
}

final academyProvider = AsyncNotifierProvider<AcademyNotifier, AcademyState>(AcademyNotifier.new);
