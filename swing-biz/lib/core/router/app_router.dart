import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/session_controller.dart';
import '../presentation/shared_screens.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/otp_verification_screen.dart';
import '../../features/auth/presentation/role_selection_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/arena/screens/arena_screens.dart';
import '../../features/dashboard/presentation/coach_dashboard_screens.dart';
import '../auth/me_providers.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/dashboard/presentation/owner_dashboard_screens.dart';
import '../../features/onboarding/presentation/business_details_screen.dart';
import '../../features/onboarding/presentation/choose_profile_screen.dart';
import '../../features/onboarding/presentation/create_academy_screen.dart';
import '../../features/onboarding/presentation/create_arena_screen.dart';
import '../../features/onboarding/presentation/create_coach_screen.dart';
import 'router_refresh.dart';

class AppRoutes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const login = '/phone';
  static const otp = '/otp';
  static const businessDetails = '/onboarding/business-details';
  static const chooseProfile = '/onboarding/choose-profile';
  static const createAcademy = '/onboarding/academy';
  static const createCoach = '/onboarding/coach';
  static const createArena = '/onboarding/arena';
  static const roleSelection = '/role-selection';
  static const dashboard = '/dashboard';
  static const coachHome = '/coach-home';
  static const coachSessions = '/coach-home/sessions';
  static const coachSchedule = '/coach-home/schedule';
  static const coachStudents = '/coach-home/students';
  static const coachAttendance = '/coach-home/attendance';
  static const coachTraining = '/coach-home/training';
  static const coachEarnings = '/coach-home/earnings';
  static const coachProfile = '/coach-home/profile';
  static const coachProfileEdit = '/coach-home/profile/edit';
  static const coachTrainingForm = '/coach-home/training/form';
  static const coachSettings = '/coach-home/settings';
  static const arenaHome = '/arena-home';
  static const arenaBookings = '/arena-home/bookings';
  static const arenaManageSlots = '/arena-home/manage-slots';
  static const arenaPricingManual = '/arena-home/pricing-manual';
  static const arenaCalendar = '/arena-home/calendar';
  static const arenaBlockSlot = '/arena-home/block-slot';
  static const arenaMaintenance = '/arena-home/maintenance';
  static const arenaAssets = '/arena-home/assets';
  static const arenaCourtDetail = '/arena-home/assets/detail';
  static const arenaAddEditAsset = '/arena-home/assets/edit';
  static const arenaEarnings = '/arena-home/earnings';
  static const arenaTodaySchedule = '/arena-home/today-schedule';
  static const arenaSlots = '/arena-home/slots';
  static const arenaSlotDetail = '/arena-home/slots/detail';
  static const arenaSlotForm = '/arena-home/slots/form';
  static const arenaPayments = '/arena-home/payments';
  static const arenaBookingForm = '/arena-home/bookings/new';
  static const arenaReviews = '/arena-home/reviews';
  static const arenaProfile = '/arena-home/profile';
  static const students = '/dashboard/students';
  static const editStudent = '/dashboard/students/edit';
  static const deleteStudent = '/dashboard/students/delete';
  static const batches = '/dashboard/batches';
  static const coaches = '/dashboard/coaches';
  static const editCoach = '/dashboard/coaches/edit';
  static const deleteCoach = '/dashboard/coaches/delete';
  static const coachBatches = '/dashboard/coaches/batches';
  static const coachMessage = '/dashboard/coaches/message';
  static const fees = '/dashboard/fees';
  static const academyOverview = '/dashboard/overview';
  static const createStudent = '/dashboard/create-student';
  static const createCoachProfile = '/dashboard/create-coach';
  static const createBatch = '/dashboard/create-batch';
  static const feePlan = '/dashboard/fees/plan';
  static const feeInvoice = '/dashboard/fees/invoice';
  static const feeRecordPayment = '/dashboard/fees/record-payment';
  static const feePaymentStatus = '/dashboard/fees/payment-status';
  static const feePaymentHistory = '/dashboard/fees/payment-history';
  static const feeReceipt = '/dashboard/fees/receipt';
  static const feeReminderList = '/dashboard/fees/reminders';
  static const feeReminderForm = '/dashboard/fees/reminders/form';
  static const planUpgrade = '/dashboard/plan-upgrade';
  static const announcements = '/dashboard/announcements';
  static const inventory = '/dashboard/inventory';
  static const inventoryItem = '/dashboard/inventory/item';
  static const inventoryIssue = '/dashboard/inventory/issue';
  static const inventoryIssueHistory = '/dashboard/inventory/issue-history';
  static const academyProfile = '/dashboard/academy-profile';
  static const payroll = '/dashboard/payroll';
  static const payrollSendSlip = '/dashboard/payroll/send-slip';
  static const payrollIncentives = '/dashboard/payroll/incentives';
  static const payrollAddIncentive = '/dashboard/payroll/incentives/add';
  static const payrollReport = '/dashboard/payroll/report';
  static const reports = '/dashboard/reports';
  static const settings = '/dashboard/settings';
  static const ownerNotifications = '/dashboard/notifications';
  static const ownerNotificationDetail = '/dashboard/notifications/detail';
  static const ownerSearch = '/dashboard/search';
  static const ownerLogoutConfirm = '/dashboard/logout-confirmation';
  static const sharedNotifications = '/shared/notifications';
  static const sharedNotificationPrefs = '/shared/notification-preferences';
  static const sharedSearch = '/shared/search';
  static const sharedProfileMenu = '/shared/profile-menu';
  static const sharedLogoutConfirm = '/shared/logout-confirmation';
  static const sharedFeedback = '/shared/messages';
  static const sharedEmptyStates = '/shared/empty-states';
  static const sharedLoadingStates = '/shared/loading-states';
  static const sharedNoInternet = '/shared/no-internet';
  static const sharedSessionExpired = '/shared/session-expired';
  static const sharedPermissionRequest = '/shared/permission-request';
  static const sharedUpgrade = '/shared/upgrade';
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: RouterRefreshStream(ref),
    redirect: (context, state) {
      final session = ref.read(sessionControllerProvider);
      final loggedIn = session.status == AuthStatus.authenticated;
      final selectedRole = session.activeProfile;
      final meAsync = ref.read(meProvider);

      final loc = state.matchedLocation;
      final onSplash = loc == AppRoutes.splash;
      final onWelcome = loc == AppRoutes.welcome;
      final onPhone = loc == AppRoutes.login;
      final onOtp = loc == AppRoutes.otp;
      final onRoleSelection = loc == AppRoutes.roleSelection;
      final onPublic = onSplash || onWelcome || onPhone || onOtp;

      if (session.status == AuthStatus.unknown) return null;

      if (!loggedIn) return onPublic ? null : AppRoutes.welcome;

      if (selectedRole == null) {
        return onRoleSelection ? null : AppRoutes.roleSelection;
      }

      if (meAsync.isLoading) return null;
      final me = meAsync.valueOrNull;
      final requiredSetup = _setupRouteForRole(selectedRole, me);
      if (requiredSetup != null) {
        return loc == requiredSetup ? null : requiredSetup;
      }

      final roleHome = _homeForRole(selectedRole);
      if (onPublic || onRoleSelection) return roleHome;

      if (!_isRouteAllowedForRole(loc, selectedRole)) {
        return roleHome;
      }

      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (_, __) => const WelcomeScreen(),
      ),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(
          path: AppRoutes.otp,
          builder: (_, __) => const OtpVerificationScreen()),
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
        path: AppRoutes.coachSchedule,
        builder: (_, __) => const CoachScheduleScreen(),
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
        path: '${AppRoutes.coachStudents}/:studentId',
        builder: (_, state) => CoachStudentDetailScreen(
          studentId: state.pathParameters['studentId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.coachAttendance,
        builder: (_, __) => const CoachAttendanceScreen(),
      ),
      GoRoute(
        path: AppRoutes.coachTraining,
        builder: (_, __) => const CoachTrainingPlansScreen(),
      ),
      GoRoute(
        path: AppRoutes.coachTrainingForm,
        builder: (_, __) => const CoachTrainingPlanFormScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.coachTraining}/:planId',
        builder: (_, state) => CoachTrainingPlanDetailScreen(
          planId: state.pathParameters['planId']!,
        ),
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
        path: AppRoutes.coachProfileEdit,
        builder: (_, __) => const CoachEditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.coachSettings,
        builder: (_, __) => const CoachSettingsScreen(),
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
        path: '${AppRoutes.arenaCourtDetail}/:courtId',
        builder: (_, state) =>
            ArenaCourtDetailScreen(courtId: state.pathParameters['courtId']!),
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
        path: '${AppRoutes.arenaSlotDetail}/:slotId',
        builder: (_, state) =>
            ArenaSlotDetailScreen(slotId: state.pathParameters['slotId']!),
      ),
      GoRoute(
        path: AppRoutes.arenaSlotForm,
        builder: (_, __) => const ArenaSlotFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.arenaPayments,
        builder: (_, __) => const ArenaPaymentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.arenaBookingForm,
        builder: (_, __) => const ArenaBookingFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.arenaReviews,
        builder: (_, __) => const ArenaReviewsScreen(),
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
        path: '${AppRoutes.editStudent}/:studentId',
        builder: (_, state) => EditStudentScreen(
          studentId: state.pathParameters['studentId']!,
        ),
      ),
      GoRoute(
        path: '${AppRoutes.deleteStudent}/:studentId',
        builder: (_, state) => DeleteStudentConfirmationScreen(
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
        path: '${AppRoutes.editCoach}/:coachId',
        builder: (_, state) => EditCoachProfileScreen(
          coachId: state.pathParameters['coachId']!,
        ),
      ),
      GoRoute(
        path: '${AppRoutes.deleteCoach}/:coachId',
        builder: (_, state) => DeleteCoachConfirmationScreen(
          coachId: state.pathParameters['coachId']!,
        ),
      ),
      GoRoute(
        path: '${AppRoutes.coachBatches}/:coachId',
        builder: (_, state) => CoachAssignedBatchesScreen(
          coachId: state.pathParameters['coachId']!,
        ),
      ),
      GoRoute(
        path: '${AppRoutes.coachMessage}/:coachId',
        builder: (_, state) => CoachMessageScreen(
          coachId: state.pathParameters['coachId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.fees,
        builder: (_, __) => const FeeManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.academyOverview,
        builder: (_, __) => const AcademyOverviewScreen(),
      ),
      GoRoute(
        path: AppRoutes.createStudent,
        builder: (_, __) => const CreateStudentScreen(),
      ),
      GoRoute(
        path: AppRoutes.createCoachProfile,
        builder: (_, __) => const CreateCoachProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.createBatch,
        builder: (_, __) => const CreateBatchScreen(),
      ),
      GoRoute(
        path: AppRoutes.feePlan,
        builder: (_, __) => const FeePlanScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.feeInvoice}/:studentId',
        builder: (_, state) => FeeInvoiceScreen(
          studentId: state.pathParameters['studentId']!,
        ),
      ),
      GoRoute(
        path: '${AppRoutes.feeRecordPayment}/:studentId',
        builder: (_, state) => RecordPaymentScreen(
          studentId: state.pathParameters['studentId']!,
        ),
      ),
      GoRoute(
        path: '${AppRoutes.feePaymentStatus}/:studentId',
        builder: (_, state) => PaymentStatusScreen(
          studentId: state.pathParameters['studentId']!,
        ),
      ),
      GoRoute(
        path: '${AppRoutes.feePaymentHistory}/:studentId',
        builder: (_, state) => StudentPaymentHistoryScreen(
          studentId: state.pathParameters['studentId']!,
        ),
      ),
      GoRoute(
        path: '${AppRoutes.feeReceipt}/:studentId',
        builder: (_, state) => ReceiptScreen(
          studentId: state.pathParameters['studentId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.feeReminderList,
        builder: (_, __) => const ReminderManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.feeReminderForm,
        builder: (_, __) => const ReminderFormScreen(),
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
        path: AppRoutes.inventoryItem,
        builder: (_, __) => const InventoryItemScreen(),
      ),
      GoRoute(
        path: AppRoutes.inventoryIssue,
        builder: (_, __) => const IssueInventoryItemScreen(),
      ),
      GoRoute(
        path: AppRoutes.inventoryIssueHistory,
        builder: (_, __) => const IssuedItemsHistoryScreen(),
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
        path: '${AppRoutes.payroll}/:coachId',
        builder: (_, state) => CoachSalaryDetailsScreen(
          coachId: state.pathParameters['coachId']!,
        ),
      ),
      GoRoute(
        path: '${AppRoutes.payrollSendSlip}/:coachId',
        builder: (_, state) => SendSalarySlipScreen(
          coachId: state.pathParameters['coachId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.payrollIncentives,
        builder: (_, __) => const IncentivesScreen(),
      ),
      GoRoute(
        path: AppRoutes.payrollAddIncentive,
        builder: (_, __) => const AddIncentiveScreen(),
      ),
      GoRoute(
        path: AppRoutes.payrollReport,
        builder: (_, __) => const PayrollReportScreen(),
      ),
      GoRoute(
        path: AppRoutes.reports,
        builder: (_, __) => const ReportsScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.reports}/:reportId',
        builder: (_, state) => ReportDetailScreen(
          reportId: state.pathParameters['reportId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, __) => const DevelopmentSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.ownerNotifications,
        builder: (_, __) => const OwnerNotificationsScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.ownerNotificationDetail}/:index',
        builder: (_, state) => OwnerNotificationDetailScreen(
          notificationIndex: int.parse(state.pathParameters['index']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.ownerSearch,
        builder: (_, __) => const OwnerSearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.ownerLogoutConfirm,
        builder: (_, __) => const OwnerLogoutConfirmationScreen(),
      ),
      GoRoute(
        path: AppRoutes.sharedNotifications,
        builder: (_, __) => const NotificationsHubScreen(),
      ),
      GoRoute(
        path: AppRoutes.sharedNotificationPrefs,
        builder: (_, __) => const NotificationPreferencesScreen(),
      ),
      GoRoute(
        path: AppRoutes.sharedSearch,
        builder: (_, __) => const GlobalSearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.sharedProfileMenu,
        builder: (_, __) => const UserProfileMenuScreen(),
      ),
      GoRoute(
        path: AppRoutes.sharedLogoutConfirm,
        builder: (_, __) => const LogoutConfirmationScreen(),
      ),
      GoRoute(
        path: AppRoutes.sharedFeedback,
        builder: (_, __) => const FeedbackMessagesScreen(),
      ),
      GoRoute(
        path: AppRoutes.sharedEmptyStates,
        builder: (_, __) => const EmptyStatesScreen(),
      ),
      GoRoute(
        path: AppRoutes.sharedLoadingStates,
        builder: (_, __) => const LoadingStatesScreen(),
      ),
      GoRoute(
        path: AppRoutes.sharedNoInternet,
        builder: (_, __) => const NoInternetScreen(),
      ),
      GoRoute(
        path: AppRoutes.sharedSessionExpired,
        builder: (_, __) => const SessionExpiredScreen(),
      ),
      GoRoute(
        path: AppRoutes.sharedPermissionRequest,
        builder: (_, __) => const PermissionRequestScreen(),
      ),
      GoRoute(
        path: AppRoutes.sharedUpgrade,
        builder: (_, __) => const PremiumUpgradeScreen(),
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

String? _setupRouteForRole(BizProfileType role, BizMeResponse? me) {
  final status = me?.businessStatus;
  return switch (role) {
    BizProfileType.academy =>
      status?.academyId == null ? AppRoutes.createAcademy : null,
    BizProfileType.coach =>
      status?.coachProfileId == null ? AppRoutes.createCoach : null,
    BizProfileType.arena ||
    BizProfileType.arenaManager =>
      status?.arenaId == null ? AppRoutes.createArena : null,
    BizProfileType.store => null,
  };
}

bool _isRouteAllowedForRole(String loc, BizProfileType role) {
  final isOwnerRoute =
      loc == AppRoutes.dashboard || loc.startsWith('${AppRoutes.dashboard}/');
  final isCoachRoute =
      loc == AppRoutes.coachHome || loc.startsWith('${AppRoutes.coachHome}/');
  final isArenaRoute =
      loc == AppRoutes.arenaHome || loc.startsWith('${AppRoutes.arenaHome}/');
  final isSharedRoute = loc.startsWith('/shared/');

  return switch (role) {
    BizProfileType.academy => isOwnerRoute || isSharedRoute,
    BizProfileType.coach => isCoachRoute || isSharedRoute,
    BizProfileType.arena ||
    BizProfileType.arenaManager =>
      isArenaRoute || isSharedRoute,
    BizProfileType.store => isOwnerRoute || isSharedRoute,
  };
}
