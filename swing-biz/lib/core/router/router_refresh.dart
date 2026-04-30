import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/me_providers.dart';
import '../auth/session_controller.dart';
import '../../features/auth/controller/auth_controller.dart';

/// Triggers GoRouter.redirect whenever session, /biz/me, or auth flow changes.
class RouterRefreshStream extends ChangeNotifier {
  RouterRefreshStream(this._ref) {
    _ref.listen(sessionControllerProvider, (_, __) => notifyListeners());
    _ref.listen(meProvider, (_, __) => notifyListeners());
    _ref.listen(authControllerProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}
