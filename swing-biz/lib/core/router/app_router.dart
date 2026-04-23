import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/session_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/role_selection_screen.dart';
import '../../features/arena/screens/arena_screens.dart';
import '../../features/dashboard/presentation/coach_dashboard_screens.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/dashboard/presentation/owner_dashboard_screens.dart';
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
  static const roleSelection = '/role-selection';
  static const dashboard = '/dashboard';
  static const coachHome = '/coach-home';
  static const coachSessions = '/coach-home/sessions';
  static const coachStudents = '/coach-home/students';
  static const coachEarnings = '/coach-home/earnings';
  static const coachProfile = '/coach-home/profile';
  static const arenaHome = '/arena-home';
  static const arenaBookings = '/arena-home/bookings';
  static const arenaManageSlots = '/arena-home/manage-slots';
  static const arenaPricingManual = '/arena-home/pricing-manual';
  static const arenaCalendar = '/arena-home/calendar';
  static const arenaBlockSlot = '/arena-home/block-slot';
  static const arenaMaintenance = '/arena-home/maintenance';
  static const arenaAssets = '/arena-home/assets';
  static const arenaAddEditAsset = '/arena-home/assets/edit';
  static const arenaEarnings = '/arena-home/earnings';
  static const arenaTodaySchedule = '/arena-home/today-schedule';
  static const arenaSlots = '/arena-home/slots';
  static const arenaPayments = '/arena-home/payments';
  static const arenaProfile = '/arena-home/profile';
  static const students = '/dashboard/students';
  static const batches = '/dashboard/batches';
  static const coaches = '/dashboard/coaches';
  static const fees = '/dashboard/fees';
  static const createStudent = '/dashboard/create-student';
  static const createBatch = '/dashboard/create-batch';
  static const planUpgrade = '/dashboard/plan-upgrade';
  static const announcements = '/dashboard/announcements';
  static const inventory = '/dashboard/inventory';
  static const academyProfile = '/dashboard/academy-profile';
  static const payroll = '/dashboard/payroll';
  static const settings = '/dashboard/settings';
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: RouterRefreshStream(ref),
    redirect: (context, state) {
      final session = ref.read(sessionControllerProvider);
      final loggedIn = session.status == AuthStatus.authenticated;
      final selectedRole = session.activeProfile;

      final loc = state.matchedLocation;
      final onAuth = loc == AppRoutes.login;
      final onRoleSelection = loc == AppRoutes.roleSelection;

      if (session.status == AuthStatus.unknown) return null;

      if (!loggedIn) return onAuth ? null : AppRoutes.login;

      if (selectedRole == null) {
        return onRoleSelection ? null : AppRoutes.roleSelection;
      }

      final roleHome = _homeForRole(selectedRole);
      if (onAuth || onRoleSelection) return roleHome;

      if (!_isRouteAllowedForRole(loc, selectedRole)) {
        return roleHome;
      }

      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: AppRoutes.roleSelection,
        builder: (_, __) => const RoleSelectionScreen(),
      ),
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
      GoRoute(
        path: AppRoutes.coachHome,
        builder: (_, __) => const CoachHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.coachSessions,
        builder: (_, __) => const CoachTodaySessionsScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.coachSessions}/:sessionId',
        builder: (_, state) => CoachSessionDetailsScreen(
          sessionId: state.pathParameters['sessionId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.coachStudents,
        builder: (_, __) => const CoachStudentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.coachEarnings,
        builder: (_, __) => const CoachEarningsScreen(),
      ),
      GoRoute(
        path: AppRoutes.coachProfile,
        builder: (_, __) => const CoachProfilePlanScreen(),
      ),
      GoRoute(
        path: AppRoutes.arenaHome,
        builder: (_, __) => const ArenaHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.arenaBookings,
        builder: (_, __) => const ArenaBookingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.arenaManageSlots,
        builder: (_, __) => const ArenaManageSlotsScreen(),
      ),
      GoRoute(
        path: AppRoutes.arenaPricingManual,
        builder: (_, __) => const ArenaPricingManualScreen(),
      ),
      GoRoute(
        path: AppRoutes.arenaCalendar,
        builder: (_, __) => const ArenaCalendarScreen(),
      ),
      GoRoute(
        path: AppRoutes.arenaBlockSlot,
        builder: (_, __) => const ArenaBlockSlotScreen(),
      ),
      GoRoute(
        path: AppRoutes.arenaMaintenance,
        builder: (_, __) => const ArenaMaintenanceScreen(),
      ),
      GoRoute(
        path: AppRoutes.arenaAssets,
        builder: (_, __) => const ArenaAssetsScreen(),
      ),
      GoRoute(
        path: AppRoutes.arenaAddEditAsset,
        builder: (_, __) => const ArenaAddEditAssetScreen(),
      ),
      GoRoute(
        path: AppRoutes.arenaEarnings,
        builder: (_, __) => const ArenaEarningsScreen(),
      ),
      GoRoute(
        path: AppRoutes.arenaTodaySchedule,
        builder: (_, __) => const ArenaTodayScheduleScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.arenaBookings}/:bookingId',
        builder: (_, state) => ArenaBookingDetailScreen(
          bookingId: state.pathParameters['bookingId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.arenaSlots,
        builder: (_, __) => const ArenaSlotsScreen(),
      ),
      GoRoute(
        path: AppRoutes.arenaPayments,
        builder: (_, __) => const ArenaPaymentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.arenaProfile,
        builder: (_, __) => const ArenaProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.students,
        builder: (_, __) => const StudentsScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.students}/:studentId',
        builder: (_, state) => StudentProfileScreen(
          studentId: state.pathParameters['studentId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.batches,
        builder: (_, __) => const BatchesScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.batches}/:batchId',
        builder: (_, state) => BatchDetailsScreen(
          batchId: state.pathParameters['batchId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.coaches,
        builder: (_, __) => const CoachesScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.coaches}/:coachId',
        builder: (_, state) => CoachProfileScreen(
          coachId: state.pathParameters['coachId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.fees,
        builder: (_, __) => const FeeManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.createStudent,
        builder: (_, __) => const CreateStudentScreen(),
      ),
      GoRoute(
        path: AppRoutes.createBatch,
        builder: (_, __) => const CreateBatchScreen(),
      ),
      GoRoute(
        path: AppRoutes.planUpgrade,
        builder: (_, __) => const PlanUpgradeScreen(),
      ),
      GoRoute(
        path: AppRoutes.announcements,
        builder: (_, __) => const AnnouncementsScreen(),
      ),
      GoRoute(
        path: AppRoutes.inventory,
        builder: (_, __) => const InventoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.academyProfile,
        builder: (_, __) => const AcademyProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.payroll,
        builder: (_, __) => const PayrollScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, __) => const DevelopmentSettingsScreen(),
      ),
    ],
  );
});

String _homeForRole(BizProfileType role) {
  return switch (role) {
    BizProfileType.academy => AppRoutes.dashboard,
    BizProfileType.coach => AppRoutes.coachHome,
    BizProfileType.arena || BizProfileType.arenaManager => AppRoutes.arenaHome,
    BizProfileType.store => AppRoutes.dashboard,
  };
}

bool _isRouteAllowedForRole(String loc, BizProfileType role) {
  final isOwnerRoute =
      loc == AppRoutes.dashboard || loc.startsWith('${AppRoutes.dashboard}/');
  final isCoachRoute =
      loc == AppRoutes.coachHome || loc.startsWith('${AppRoutes.coachHome}/');
  final isArenaRoute =
      loc == AppRoutes.arenaHome || loc.startsWith('${AppRoutes.arenaHome}/');

  return switch (role) {
    BizProfileType.academy => isOwnerRoute,
    BizProfileType.coach => isCoachRoute,
    BizProfileType.arena || BizProfileType.arenaManager => isArenaRoute,
    BizProfileType.store => isOwnerRoute,
  };
}
