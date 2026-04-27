/// Static API paths that don't vary per host.
///
/// Per-host paths (`/player/teams`, `/admin/matches`, etc.) live in
/// [HostPathConfig] which each Flutter app overrides. What remains here is
/// the handful of endpoints that are the same regardless of which host
/// surfaces them — the biz bootstrap endpoints and the shared auth refresh
/// route.
class HostContracts {
  // Auth
  static const authRefresh = '/auth/refresh';

  // Biz (swing-biz app)
  static const bizLogin = '/auth/biz/login';
  static const bizPhoneLogin = '/auth/biz/phone-login';
  static const bizCheckPhone = '/auth/check-phone';
  static const bizMe = '/biz/me';
  static const bizBusinessDetails = '/biz/business-details';
  static const bizAcademy = '/biz/academy';
  static const bizCoach = '/biz/coach';
  static const bizArena = '/biz/arena';
  static const bizStores = '/biz/stores';
}
