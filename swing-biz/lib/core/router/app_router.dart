import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/session_controller.dart';
import '../presentation/shared_screens.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/otp_verification_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../auth/me_providers.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/dashboard/presentation/coach_dashboard_screens.dart';
import '../../features/onboarding/presentation/business_details_screen.dart';
import '../../features/onboarding/presentation/create_arena_screen.dart';
import '../../features/arena/screens/arena_profile_page.dart';
import '../../features/arena/screens/unit_detail_page.dart';
import '../../features/auth/presentation/biometric_screen.dart';
import '../../features/create_match/presentation/biz_create_match_screen.dart';
import '../../features/create_tournament/presentation/biz_create_tournament_screen.dart';
import '../../features/play/presentation/biz_play_tab.dart';
import 'router_refresh.dart';

class AppRoutes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const login = '/phone';
  static const register = '/register';
  static const otp = '/otp';
  static const businessDetails = '/onboarding/business-details';
  static const createAcademy = '/onboarding/academy';
  static const createCoach = '/onboarding/coach';
  static const createArena = '/onboarding/arena';
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
  static const arenaProfile = '/arena/profile';
  static const arenaUnitDetail = '/arena/units';
  static const arenaAccount = '/arena/account';
  static const arenaNotifications = '/arena/notifications';
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
  static const feeReminderHistory = '/dashboard/fees/reminders/history';
  static const feePlanDetails = '/dashboard/fees/plan/details';
  static const feePlanDelete = '/dashboard/fees/plan/delete';
  static const planUpgrade = '/dashboard/plan-upgrade';
  static const announcements = '/dashboard/announcements';
  static const documents = '/dashboard/documents';
  static const documentAdd = '/dashboard/documents/add';
  static const documentView = '/dashboard/documents/view';
  static const documentDelete = '/dashboard/documents/delete';
  static const inventory = '/dashboard/inventory';
  static const inventoryItem = '/dashboard/inventory/item';
  static const inventoryBilling = '/dashboard/inventory/billing';
  static const inventoryIssue = '/dashboard/inventory/issue';
  static const inventoryIssueHistory = '/dashboard/inventory/issue-history';
  static const academyProfile = '/dashboard/academy-profile';
  static const payroll = '/dashboard/payroll';
  static const payrollSendSlip = '/dashboard/payroll/send-slip';
  static const payrollIncentives = '/dashboard/payroll/incentives';
  static const payrollAddIncentive = '/dashboard/payroll/incentives/add';
  static const payrollReport = '/dashboard/payroll/report';
  static const reports = '/dashboard/reports';
  static const studentSchedule = '/dashboard/students/schedule';
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

  // ── Play (matches / teams / tournaments) ────────────────────────────────
  static const play = '/play';
  static const createTeam = '/play/create-team';
  static const team = '/play/teams';
  static const createMatch = '/play/create-match';
  static const match = '/play/matches';
  static const scoreMatch = '/play/score';
  static const createTournament = '/play/create-tournament';
  static const tournament = '/play/tournaments';
  static const hostTournament = '/play/host-tournament';

  // ── Auth ────────────────────────────────────────────────────────────────
  static const biometric = '/biometric';
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
      final onRegister = loc == AppRoutes.register;
      final onOtp = loc == AppRoutes.otp;
      final onBiometric = loc == AppRoutes.biometric;
      final onPublic = onSplash ||
          onWelcome ||
          onPhone ||
          onOtp ||
          onRegister ||
          onBiometric;

      debugPrint(
        '[biz router] loc=$loc status=${session.status.name} role=${selectedRole?.name} '
        'meLoading=${meAsync.isLoading} meReady=${meAsync.valueOrNull != null}',
      );

      if (session.status == AuthStatus.unknown) return null;

      if (!loggedIn) {
        if (onPublic) return null;
        return AppRoutes.login;
      }

      if (onPublic) return AppRoutes.dashboard;

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
        path: AppRoutes.register,
        builder: (_, state) =>
            RegisterScreen(phone: state.uri.queryParameters['phone'] ?? ''),
      ),
      GoRoute(
          path: AppRoutes.otp,
          builder: (_, __) => const OtpVerificationScreen()),
      GoRoute(
        path: AppRoutes.businessDetails,
        builder: (_, __) => const BusinessDetailsScreen(),
      ),
      GoRoute(
        path: AppRoutes.createAcademy,
        builder: (_, __) => const _DeferredScreen('Create Academy'),
      ),
      GoRoute(
        path: AppRoutes.createCoach,
        builder: (_, __) => const _DeferredScreen('Create Coach'),
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
        path: AppRoutes.arenaProfile,
        builder: (_, __) => const ArenaProfilePage(),
      ),
      GoRoute(
        path: '${AppRoutes.arenaProfile}/:arenaId',
        builder: (_, state) => ArenaProfilePage(
          arenaId: state.pathParameters['arenaId'],
          startEditing:
              (state.extra as Map<String, dynamic>?)?['startEditing'] == true,
        ),
      ),
      GoRoute(
        path: '${AppRoutes.arenaUnitDetail}/:arenaId/:unitId',
        builder: (_, state) => UnitDetailPage(
          arenaId: state.pathParameters['arenaId']!,
          unitId: state.pathParameters['unitId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.arenaAccount,
        builder: (_, __) => const ArenaProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.arenaNotifications,
        builder: (_, __) => const _ArenaNotificationsScreen(),
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
        path: AppRoutes.feeReminderHistory,
        builder: (_, __) => const ReminderHistoryScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.feePlanDetails}/:planName',
        builder: (_, state) => FeePlanDetailsScreen(
          planName: Uri.decodeComponent(state.pathParameters['planName']!),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.feePlanDelete}/:planName',
        builder: (_, state) => FeePlanDeleteScreen(
          planName: Uri.decodeComponent(state.pathParameters['planName']!),
        ),
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
        path: AppRoutes.documents,
        builder: (_, __) => const DocumentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.documentAdd,
        builder: (_, __) => const AddDocumentScreen(),
      ),
      GoRoute(
        path: AppRoutes.documentView,
        builder: (_, __) => const ViewDocumentsScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.documentDelete}/:documentName',
        builder: (_, state) => DeleteDocumentScreen(
          documentName:
              Uri.decodeComponent(state.pathParameters['documentName']!),
        ),
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
        path: AppRoutes.inventoryBilling,
        builder: (_, __) => const InventoryBillingScreen(),
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
        path: AppRoutes.studentSchedule,
        builder: (_, __) => const StudentScheduleScreen(),
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
      // ── Auth ─────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.biometric,
        builder: (_, __) => const BiometricScreen(),
      ),
      // ── Play ─────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.play,
        builder: (_, __) => const _PlayScreen(),
      ),
      GoRoute(
        path: AppRoutes.createTeam,
        builder: (_, __) => const HostCreateTeamScreen(),
      ),
      GoRoute(
        path: AppRoutes.createMatch,
        builder: (_, state) => BizCreateMatchScreen(
          existingMatchId: state.uri.queryParameters['matchId'],
        ),
      ),
      GoRoute(
        path: AppRoutes.createTournament,
        builder: (_, __) => const BizCreateTournamentScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.scoreMatch}/:matchId',
        builder: (_, state) => ScoringScreen(
          matchId: state.pathParameters['matchId']!,
        ),
      ),
      GoRoute(
        path: '${AppRoutes.match}/:matchId',
        builder: (_, state) => HostMatchDetailScreen(
          matchId: state.pathParameters['matchId']!,
        ),
      ),
      GoRoute(
        path: '${AppRoutes.team}/:teamId',
        builder: (ctx, state) {
          final userId = ProviderScope.containerOf(ctx)
              .read(meProvider)
              .valueOrNull
              ?.user
              .id;
          return HostTeamDetailScreen(
            teamId: state.pathParameters['teamId']!,
            currentUserId: userId,
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.tournament}/:slug',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return HostTournamentViewerScreen(
            slug: state.pathParameters['slug']!,
            isHost: extra?['isHost'] as bool? ?? false,
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.hostTournament}/:tournamentId',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return HostTournamentDetailScreen(
            tournamentId: state.pathParameters['tournamentId']!,
            initialData: extra,
          );
        },
      ),
    ],
  );
});

class _DeferredScreen extends StatelessWidget {
  const _DeferredScreen(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '$title is not available in this arena-focused build.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _PlayScreen extends StatelessWidget {
  const _PlayScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: BizPlayTab()),
    );
  }
}

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Students');
}

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key, required this.studentId});
  final String studentId;
  @override
  Widget build(BuildContext context) =>
      const _DeferredScreen('Student Profile');
}

class EditStudentScreen extends StatelessWidget {
  const EditStudentScreen({super.key, required this.studentId});
  final String studentId;
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Edit Student');
}

class DeleteStudentConfirmationScreen extends StatelessWidget {
  const DeleteStudentConfirmationScreen({super.key, required this.studentId});
  final String studentId;
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Delete Student');
}

class BatchesScreen extends StatelessWidget {
  const BatchesScreen({super.key});
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Batches');
}

class BatchDetailsScreen extends StatelessWidget {
  const BatchDetailsScreen({super.key, required this.batchId});
  final String batchId;
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Batch Details');
}

class CoachesScreen extends StatelessWidget {
  const CoachesScreen({super.key});
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Coaches');
}

class CoachProfileScreen extends StatelessWidget {
  const CoachProfileScreen({super.key, required this.coachId});
  final String coachId;
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Coach Profile');
}

class EditCoachProfileScreen extends StatelessWidget {
  const EditCoachProfileScreen({super.key, required this.coachId});
  final String coachId;
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Edit Coach');
}

class DeleteCoachConfirmationScreen extends StatelessWidget {
  const DeleteCoachConfirmationScreen({super.key, required this.coachId});
  final String coachId;
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Delete Coach');
}

class CoachAssignedBatchesScreen extends StatelessWidget {
  const CoachAssignedBatchesScreen({super.key, required this.coachId});
  final String coachId;
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Coach Batches');
}

class CoachMessageScreen extends StatelessWidget {
  const CoachMessageScreen({super.key, required this.coachId});
  final String coachId;
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Coach Message');
}

class FeeManagementScreen extends StatelessWidget {
  const FeeManagementScreen({super.key});
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Fees');
}

class AcademyOverviewScreen extends StatelessWidget {
  const AcademyOverviewScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const _DeferredScreen('Academy Overview');
}

class CreateStudentScreen extends StatelessWidget {
  const CreateStudentScreen({super.key});
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Create Student');
}

class CreateCoachProfileScreen extends StatelessWidget {
  const CreateCoachProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Create Coach');
}

class CreateBatchScreen extends StatelessWidget {
  const CreateBatchScreen({super.key});
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Create Batch');
}

class FeePlanScreen extends StatelessWidget {
  const FeePlanScreen({super.key});
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Fee Plan');
}

class FeeInvoiceScreen extends StatelessWidget {
  const FeeInvoiceScreen({super.key, required this.studentId});
  final String studentId;
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Fee Invoice');
}

class RecordPaymentScreen extends StatelessWidget {
  const RecordPaymentScreen({super.key, required this.studentId});
  final String studentId;
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Record Payment');
}

class PaymentStatusScreen extends StatelessWidget {
  const PaymentStatusScreen({super.key, required this.studentId});
  final String studentId;
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Payment Status');
}

class StudentPaymentHistoryScreen extends StatelessWidget {
  const StudentPaymentHistoryScreen({super.key, required this.studentId});
  final String studentId;
  @override
  Widget build(BuildContext context) =>
      const _DeferredScreen('Payment History');
}

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key, required this.studentId});
  final String studentId;
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Receipt');
}

class ReminderManagementScreen extends StatelessWidget {
  const ReminderManagementScreen({super.key});
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Reminders');
}

class ReminderFormScreen extends StatelessWidget {
  const ReminderFormScreen({super.key});
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Reminder Form');
}

class ReminderHistoryScreen extends StatelessWidget {
  const ReminderHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const _DeferredScreen('Reminder History');
}

class FeePlanDetailsScreen extends StatelessWidget {
  const FeePlanDetailsScreen({super.key, required this.planName});
  final String planName;
  @override
  Widget build(BuildContext context) =>
      const _DeferredScreen('Fee Plan Details');
}

class FeePlanDeleteScreen extends StatelessWidget {
  const FeePlanDeleteScreen({super.key, required this.planName});
  final String planName;
  @override
  Widget build(BuildContext context) =>
      const _DeferredScreen('Delete Fee Plan');
}

class PlanUpgradeScreen extends StatelessWidget {
  const PlanUpgradeScreen({super.key});
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Plan Upgrade');
}

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Announcements');
}

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Documents');
}

class AddDocumentScreen extends StatelessWidget {
  const AddDocumentScreen({super.key});
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Add Document');
}

class ViewDocumentsScreen extends StatelessWidget {
  const ViewDocumentsScreen({super.key});
  @override
  Widget build(BuildContext context) => const _DeferredScreen('View Documents');
}

class DeleteDocumentScreen extends StatelessWidget {
  const DeleteDocumentScreen({super.key, required this.documentName});
  final String documentName;
  @override
  Widget build(BuildContext context) =>
      const _DeferredScreen('Delete Document');
}

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Inventory');
}

class InventoryItemScreen extends StatelessWidget {
  const InventoryItemScreen({super.key});
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Inventory Item');
}

class InventoryBillingScreen extends StatelessWidget {
  const InventoryBillingScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const _DeferredScreen('Inventory Billing');
}

class IssueInventoryItemScreen extends StatelessWidget {
  const IssueInventoryItemScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const _DeferredScreen('Issue Inventory');
}

class IssuedItemsHistoryScreen extends StatelessWidget {
  const IssuedItemsHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const _DeferredScreen('Issued Inventory History');
}

class AcademyProfileScreen extends StatelessWidget {
  const AcademyProfileScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const _DeferredScreen('Academy Profile');
}

class PayrollScreen extends StatelessWidget {
  const PayrollScreen({super.key});
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Payroll');
}

class CoachSalaryDetailsScreen extends StatelessWidget {
  const CoachSalaryDetailsScreen({super.key, required this.coachId});
  final String coachId;
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Coach Salary');
}

class SendSalarySlipScreen extends StatelessWidget {
  const SendSalarySlipScreen({super.key, required this.coachId});
  final String coachId;
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Salary Slip');
}

class IncentivesScreen extends StatelessWidget {
  const IncentivesScreen({super.key});
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Incentives');
}

class AddIncentiveScreen extends StatelessWidget {
  const AddIncentiveScreen({super.key});
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Add Incentive');
}

class PayrollReportScreen extends StatelessWidget {
  const PayrollReportScreen({super.key});
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Payroll Report');
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Reports');
}

class ReportDetailScreen extends StatelessWidget {
  const ReportDetailScreen({super.key, required this.reportId});
  final String reportId;
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Report Detail');
}

class StudentScheduleScreen extends StatelessWidget {
  const StudentScheduleScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const _DeferredScreen('Student Schedule');
}

class DevelopmentSettingsScreen extends StatelessWidget {
  const DevelopmentSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Settings');
}

class OwnerNotificationsScreen extends StatelessWidget {
  const OwnerNotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Notifications');
}

class OwnerNotificationDetailScreen extends StatelessWidget {
  const OwnerNotificationDetailScreen({
    super.key,
    required this.notificationIndex,
  });
  final int notificationIndex;
  @override
  Widget build(BuildContext context) =>
      const _DeferredScreen('Notification Detail');
}

class OwnerSearchScreen extends StatelessWidget {
  const OwnerSearchScreen({super.key});
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Search');
}

class OwnerLogoutConfirmationScreen extends StatelessWidget {
  const OwnerLogoutConfirmationScreen({super.key});
  @override
  Widget build(BuildContext context) => const _DeferredScreen('Logout');
}

class _ArenaNotificationsScreen extends StatelessWidget {
  const _ArenaNotificationsScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const Center(
        child: Text('Notifications coming soon'),
      ),
    );
  }
}
