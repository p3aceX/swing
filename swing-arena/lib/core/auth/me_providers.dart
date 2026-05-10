import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_controller.dart';

/// Refreshes whenever the authenticated session flips on/off.
final meProvider = FutureProvider<BizMeResponse?>((ref) async {
  final session = ref.watch(sessionControllerProvider);
  if (session.status != AuthStatus.authenticated) return null;
  final repo = ref.watch(hostBizRepositoryProvider);
  return repo.getMe();
});
