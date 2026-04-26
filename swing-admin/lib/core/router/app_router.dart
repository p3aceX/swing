import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/arenas/presentation/arenas_screen.dart';
import '../../features/arenas/presentation/arena_create_screen.dart';
import '../../features/arenas/presentation/arena_workspace_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/matches/presentation/match_detail_screen.dart';
import '../../features/matches/presentation/matches_screen.dart';
import '../../features/shell/presentation/admin_shell.dart';
import '../../features/tournaments/presentation/tournaments_screen.dart';
import '../../features/tournaments/presentation/tournament_detail_screen.dart';
import '../../features/users/presentation/user_profile_screen.dart';
import '../../features/users/presentation/users_screen.dart';
import '../auth/auth_controller.dart';

class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authControllerProvider, (_, _) => notifyListeners());
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshable = _AuthListenable(ref);
  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: refreshable,
    redirect: (context, state) {
      final loggedIn = ref.read(authControllerProvider).isLoggedIn;
      final atLogin = state.matchedLocation == '/login';
      if (!loggedIn && !atLogin) return '/login';
      if (loggedIn && atLogin) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, _) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (_, _) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/users',
            builder: (_, _) => const UsersScreen(),
          ),
          GoRoute(
            path: '/users/:id',
            builder: (_, state) =>
                UserProfileScreen(userId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/arenas',
            builder: (_, _) => const ArenasScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (_, _) => const ArenaCreateScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (_, state) => ArenaWorkspaceScreen(
                  arenaId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/matches',
            builder: (_, _) => const MatchesScreen(),
            routes: [
              GoRoute(
                path: 'live',
                builder: (_, _) =>
                    const MatchesScreen(status: MatchStatusFilter.live),
              ),
              GoRoute(
                path: 'scheduled',
                builder: (_, _) =>
                    const MatchesScreen(status: MatchStatusFilter.scheduled),
              ),
              GoRoute(
                path: 'complete',
                builder: (_, _) =>
                    const MatchesScreen(status: MatchStatusFilter.complete),
              ),
              GoRoute(
                path: ':id',
                builder: (_, state) =>
                    MatchDetailScreen(matchId: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/tournaments',
            builder: (_, _) => const TournamentsScreen(),
            routes: [
              GoRoute(
                path: 'live',
                builder: (_, _) => const TournamentsScreen(
                    status: TournamentStatusFilter.live),
              ),
              GoRoute(
                path: 'scheduled',
                builder: (_, _) => const TournamentsScreen(
                    status: TournamentStatusFilter.scheduled),
              ),
              GoRoute(
                path: 'complete',
                builder: (_, _) => const TournamentsScreen(
                    status: TournamentStatusFilter.complete),
              ),
              GoRoute(
                path: ':id',
                builder: (_, state) => TournamentDetailScreen(
                    tournamentId: state.pathParameters['id']!),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
