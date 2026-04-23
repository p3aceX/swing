import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/me_providers.dart';
import '../auth/session_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/onboarding/presentation/business_details_screen.dart';
import '../../features/onboarding/presentation/choose_profile_screen.dart';
import '../../features/onboarding/presentation/create_academy_screen.dart';
import '../../features/onboarding/presentation/create_arena_screen.dart';
import '../../features/onboarding/presentation/create_coach_screen.dart';
import 'router_refresh.dart';

class AppRoutes {
  static const login = '/login';
  static const businessDetails = '/onboarding/business-details';
  static const chooseProfile = '/onboarding/choose-profile';
  static const createAcademy = '/onboarding/academy';
  static const createCoach = '/onboarding/coach';
  static const createArena = '/onboarding/arena';
  static const dashboard = '/dashboard';
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: RouterRefreshStream(ref),
    redirect: (context, state) {
      final session = ref.read(sessionControllerProvider);
      final loggedIn = session.status == AuthStatus.authenticated;
      final me = ref.read(meProvider).valueOrNull;

      final loc = state.matchedLocation;
      final onAuth = loc == AppRoutes.login;

      if (session.status == AuthStatus.unknown) return null;

      if (!loggedIn) return onAuth ? null : AppRoutes.login;

      if (loggedIn && onAuth) {
        return _landingRoute(me);
      }

      if (me == null) return null;

      final status = me.businessStatus;
      if (!status.hasBusinessAccount) {
        return loc == AppRoutes.businessDetails ? null : AppRoutes.businessDetails;
      }

      if (status.availableProfiles.isEmpty) {
        final allowed = {
          AppRoutes.chooseProfile,
          AppRoutes.createAcademy,
          AppRoutes.createCoach,
          AppRoutes.createArena,
        };
        return allowed.contains(loc) ? null : AppRoutes.chooseProfile;
      }

      if (loc == AppRoutes.businessDetails) return AppRoutes.dashboard;

      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: AppRoutes.businessDetails,
        builder: (_, __) => const BusinessDetailsScreen(),
      ),
      GoRoute(
        path: AppRoutes.chooseProfile,
        builder: (_, __) => const ChooseProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.createAcademy,
        builder: (_, __) => const CreateAcademyScreen(),
      ),
      GoRoute(
        path: AppRoutes.createCoach,
        builder: (_, __) => const CreateCoachScreen(),
      ),
      GoRoute(
        path: AppRoutes.createArena,
        builder: (_, __) => const CreateArenaScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (_, __) => const DashboardScreen(),
      ),
    ],
  );
});

String _landingRoute(BizMeResponse? me) {
  if (me == null) return AppRoutes.dashboard;
  final status = me.businessStatus;
  if (!status.hasBusinessAccount) return AppRoutes.businessDetails;
  if (status.availableProfiles.isEmpty) return AppRoutes.chooseProfile;
  return AppRoutes.dashboard;
}
