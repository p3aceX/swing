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

    final api  = ref.read(apiClientProvider);
    final res  = await api.get('/academy/my');
    final raw  = res.data['data'];
    if (raw == null) throw Exception('NO_ACADEMY');

    final academy   = Map<String, dynamic>.from(raw as Map);
    final academyId = academy['id'] as String;
    await ref.read(secureStorageProvider).saveAcademyId(academyId);
    return AcademyState(academyId: academyId, data: academy);
  }
}

final academyProvider = AsyncNotifierProvider<AcademyNotifier, AcademyState>(AcademyNotifier.new);
