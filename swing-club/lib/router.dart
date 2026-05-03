import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'shell.dart';
import 'features/auth/splash_screen.dart';
import 'features/auth/phone_screen.dart';
import 'features/auth/name_screen.dart';
import 'features/auth/otp_screen.dart';
import 'features/auth/business_details_screen.dart';
import 'features/auth/academy_registration_screen.dart';
import 'features/home/home_screen.dart';
import 'features/students/student_list_screen.dart';
import 'features/students/student_detail_screen.dart';
import 'features/sessions/session_list_screen.dart';
import 'features/sessions/session_detail_screen.dart';
import 'features/sessions/attendance_report_screen.dart';
import 'features/more/more_screen.dart';
import 'features/batches/batch_list_screen.dart';
import 'features/batches/batch_detail_screen.dart';
import 'features/coaches/coach_list_screen.dart';
import 'features/coaches/coach_detail_screen.dart';
import 'features/fees/fee_overview_screen.dart';
import 'features/announcements/announcement_list_screen.dart';
import 'features/announcements/create_announcement_screen.dart';
import 'features/inventory/inventory_list_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/settings/academy_profile_screen.dart';

// Auth-only paths — never redirect away from these
const _authPaths = {'/splash', '/phone', '/name', '/otp', '/business-details', '/academy-setup'};

class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  _RouterNotifier(this._ref) {
    _ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final isAuth = _ref.read(authProvider).isAuthenticated;
    final path   = state.uri.path;
    final onAuth = _authPaths.contains(path);

    // Not authenticated → send to phone screen (unless already on an auth path)
    if (!isAuth && !onAuth) return '/phone';

    // Authenticated → bounce away from auth screens (except onboarding screens that need auth)
    if (isAuth && (path == '/phone' || path == '/splash')) return '/home';

    return null;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  return GoRouter(
    refreshListenable: notifier,
    redirect: notifier.redirect,
    initialLocation: '/splash',
    routes: [
      // ── Auth flow ────────────────────────────────────────────────────────
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/phone',  builder: (_, __) => const PhoneScreen()),
      GoRoute(
        path: '/name',
        builder: (_, state) => NameScreen(
          phone: (state.extra as Map<String, dynamic>)['phone'] as String,
        ),
      ),
      GoRoute(
        path: '/otp',
        builder: (_, state) {
          final args      = state.extra as Map<String, dynamic>;
          return OtpScreen(
            phone:     args['phone']     as String,
            sessionId: args['sessionId'] as String,
            isNewUser: args['isNewUser'] as bool? ?? false,
            name:      args['name']      as String?,
          );
        },
      ),
      GoRoute(path: '/business-details', builder: (_, __) => const BusinessDetailsScreen()),
      GoRoute(path: '/academy-setup',    builder: (_, __) => const AcademyRegistrationScreen()),

      // ── Main app ─────────────────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/students',
              builder: (_, __) => const StudentListScreen(),
              routes: [
                GoRoute(
                  path: ':enrollmentId',
                  builder: (_, state) => StudentDetailScreen(
                    enrollmentId: state.pathParameters['enrollmentId']!,
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/sessions',
              builder: (_, __) => const SessionListScreen(),
              routes: [
                GoRoute(path: 'report', builder: (_, __) => const AttendanceReportScreen()),
                GoRoute(
                  path: ':sessionId',
                  builder: (_, state) => SessionDetailScreen(
                    sessionId: state.pathParameters['sessionId']!,
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/more',
              builder: (_, __) => const MoreScreen(),
              routes: [
                GoRoute(
                  path: 'batches',
                  builder: (_, __) => const BatchListScreen(),
                  routes: [
                    GoRoute(
                      path: ':batchId',
                      builder: (_, state) => BatchDetailScreen(
                        batchId: state.pathParameters['batchId']!,
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'coaches',
                  builder: (_, __) => const CoachListScreen(),
                  routes: [
                    GoRoute(
                      path: ':coachId',
                      builder: (_, state) => CoachDetailScreen(
                        coachId: state.pathParameters['coachId']!,
                      ),
                    ),
                  ],
                ),
                GoRoute(path: 'fees',          builder: (_, __) => const FeeOverviewScreen()),
                GoRoute(
                  path: 'announcements',
                  builder: (_, __) => const AnnouncementListScreen(),
                  routes: [
                    GoRoute(path: 'create', builder: (_, __) => const CreateAnnouncementScreen()),
                  ],
                ),
                GoRoute(path: 'inventory', builder: (_, __) => const InventoryListScreen()),
                GoRoute(
                  path: 'settings',
                  builder: (_, __) => const SettingsScreen(),
                  routes: [
                    GoRoute(path: 'profile', builder: (_, __) => const AcademyProfileScreen()),
                  ],
                ),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
});
