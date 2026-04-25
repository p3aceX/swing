import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/controller/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/create_event/presentation/create_event_screen.dart';
import 'package:flutter_host_core/flutter_host_core.dart'
    show
        TossScreen,
        ScoringScreen,
        HostTournamentDetailScreen,
        HostTeamDetailScreen,
        TeamDetailCallbacks,
        HostMatchDetailScreen,
        MatchDetailCallbacks,
        HostCreateTeamScreen;
import '../../features/create_match/presentation/create_match_screen.dart';
import '../../features/create_tournament/presentation/create_tournament_screen.dart';
import '../../features/create_tournament/presentation/tournament_detail_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/recommended_connections_screen.dart';
import '../../features/host/presentation/host_screen.dart';
import 'package:image_picker/image_picker.dart';
import '../../features/teams/controller/teams_controller.dart';
import '../../core/storage/supabase_storage_service.dart';
import '../../features/profile/controller/profile_controller.dart';
import '../../features/profile/presentation/academy_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/player_follow_list_screen.dart';
import '../../features/elite/presentation/my_plan_screen.dart';
import '../../features/health/presentation/health_module_screen.dart';
import '../../features/health/presentation/wellness_checkin_screen.dart';
import '../../features/health/presentation/workload_log_screen.dart';
import '../../features/booking/presentation/arena_detail_screen.dart';
import '../../features/booking/domain/booking_models.dart';
import '../../features/search/search_screen.dart';
import '../../features/store/domain/store_models.dart';
import '../../features/store/presentation/store_detail_screen.dart';
import '../../features/store/presentation/store_order_detail_screen.dart';
import '../../features/store/presentation/storefront_screen.dart';
import '../../features/subscription/presentation/pro_plan_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/chat/presentation/conversations_screen.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/chat/domain/chat_models.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authControllerProvider.notifier);
  final currentPlayerId = ref.watch(currentPlayerIdProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: RouterRefreshStream(authNotifier.stream),
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final location = state.matchedLocation;

      if (authState.status == AuthStatus.loading) return null;

      if (location == '/splash') {
        return authState.isAuthenticated ? '/home' : '/login';
      }

      const authOpenRoutes = {'/login', '/otp', '/register'};

      if (!authState.isAuthenticated && !authOpenRoutes.contains(location)) {
        return '/login';
      }

      if (authState.isAuthenticated &&
          {'/login', '/register', '/otp'}.contains(location)) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, state) => RegisterScreen(
          phoneNumber: state.uri.queryParameters['phone'] ?? '',
        ),
      ),
      GoRoute(
        path: '/otp',
        builder: (_, state) => OtpScreen(
          phoneNumber: state.uri.queryParameters['phone'] ?? '',
        ),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/recommended-connections',
        builder: (_, __) => const RecommendedConnectionsScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (_, state) => SearchScreen(
          initialQuery: state.uri.queryParameters['q'] ?? '',
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (_, __) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/player/:id',
        builder: (_, state) => ProfileScreen(
          profileId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: '/player/:id/followers',
        builder: (_, state) => PlayerFollowListScreen(
          profileId: state.pathParameters['id'] ?? '',
          mode: FollowListMode.followers,
        ),
      ),
      GoRoute(
        path: '/player/:id/following',
        builder: (_, state) => PlayerFollowListScreen(
          profileId: state.pathParameters['id'] ?? '',
          mode: FollowListMode.following,
        ),
      ),
      GoRoute(
        path: '/academy',
        builder: (_, __) => const AcademyScreen(),
      ),
      GoRoute(
        path: '/storefront',
        builder: (_, state) => StorefrontScreen(
          location: state.extra is StorefrontLocation
              ? state.extra as StorefrontLocation
              : null,
        ),
      ),
      GoRoute(
        path: '/storefront/:id',
        builder: (_, state) => StoreDetailScreen(
          storeId: state.pathParameters['id'] ?? '',
          initialArgs: state.extra is StoreScreenArgs
              ? state.extra as StoreScreenArgs
              : null,
        ),
      ),
      GoRoute(
        path: '/store-order/:id',
        builder: (_, state) => StoreOrderDetailScreen(
          orderId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/pro-plans',
        builder: (_, __) => const ProPlanScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),

      // ── Elite ─────────────────────────────────────────────────────────────
      GoRoute(
        path: '/elite/my-plan',
        builder: (_, __) => const MyPlanScreen(),
      ),

      // ── Health ────────────────────────────────────────────────────────────
      GoRoute(
        path: '/health',
        builder: (_, __) => const HealthModuleScreen(),
      ),
      GoRoute(
        path: '/wellness-checkin',
        builder: (_, __) => const WellnessCheckInScreen(),
      ),
      GoRoute(
        path: '/workload-log',
        builder: (_, __) => const WorkloadLogScreen(),
      ),

      // ── Host / Discover ───────────────────────────────────────────────────
      GoRoute(
        path: '/host',
        builder: (_, __) => const HostScreen(),
      ),

      // ── Create flows ──────────────────────────────────────────────────────
      GoRoute(
        path: '/create-match',
        builder: (_, state) {
          final matchId = state.uri.queryParameters['matchId'];
          final teamA = state.uri.queryParameters['teamA'];
          final teamB = state.uri.queryParameters['teamB'];
          return CreateMatchScreen(
            existingMatchId: matchId,
            existingTeamAName: teamA,
            existingTeamBName: teamB,
          );
        },
      ),
      GoRoute(
        path: '/match/:id',
        builder: (context, state) => HostMatchDetailScreen(
          matchId: state.pathParameters['id'] ?? '',
          currentUserId: ref.read(currentPlayerIdProvider),
          callbacks: MatchDetailCallbacks(
            onScoreMatch: (ctx, id) => ctx.push('/score-match/$id'),
            onNavigateToPlayer: (ctx, playerId) =>
                ctx.push('/player/$playerId'),
            onNavigateBack: (ctx) =>
                Navigator.of(ctx).canPop() ? Navigator.of(ctx).pop() : ctx.go('/home'),
          ),
        ),
      ),
      GoRoute(
        path: '/create-tournament',
        builder: (_, __) => const CreateTournamentScreen(),
      ),
      GoRoute(
        path: '/tournament/:id',
        builder: (_, state) => TournamentDetailScreen(
          tournamentId: state.pathParameters['id'] ?? '',
          initialData: state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : null,
        ),
      ),
      GoRoute(
        path: '/host-tournament/:id',
        builder: (_, state) => HostTournamentDetailScreen(
          tournamentId: state.pathParameters['id'] ?? '',
          initialData: state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : null,
        ),
      ),
      GoRoute(
        path: '/create-event',
        builder: (_, __) => const CreateEventScreen(),
      ),
      GoRoute(
        path: '/arena/:id',
        builder: (_, state) => ArenaDetailScreen(
          arenaId: state.pathParameters['id'] ?? '',
          initialArena:
              state.extra is ArenaListing ? state.extra as ArenaListing : null,
        ),
      ),
      GoRoute(
        path: '/create-team',
        builder: (_, __) => HostCreateTeamScreen(
          onPickLogo: () async {
            final picker = ImagePicker();
            final file = await picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 85,
                maxWidth: 1200);
            if (file == null) return null;
            final bytes = await file.readAsBytes();
            final dot = file.name.lastIndexOf('.');
            final ext = (dot != -1 && dot < file.name.length - 1)
                ? file.name.substring(dot + 1).toLowerCase()
                : 'jpg';
            return (bytes: bytes, extension: ext);
          },
          onUploadLogo: (bytes, ext) =>
              SupabaseStorageService().uploadTeamLogoBytes(bytes, ext),
          onSuccess: () => ref.invalidate(teamsControllerProvider),
        ),
      ),
      GoRoute(
        path: '/team/:id',
        builder: (context, state) => HostTeamDetailScreen(
          teamId: state.pathParameters['id'] ?? '',
          currentUserId: ref.read(currentPlayerIdProvider),
          callbacks: TeamDetailCallbacks(
            onNavigateToMatch: (ctx, matchId) => ctx.push('/match/$matchId'),
            onScoreMatch: (ctx, matchId) => ctx.push('/score-match/$matchId'),
            onNavigateToPlayer: (ctx, playerId) =>
                ctx.push('/player/$playerId'),
            onUploadLogo: (ctx) async {
              // Image upload handled by swing-player via its own storage service
              return null;
            },
            onNavigateBack: (ctx) =>
                Navigator.of(ctx).canPop() ? Navigator.of(ctx).pop() : null,
          ),
        ),
      ),
      // Deep-link route shared via WhatsApp — auto-shows join sheet on load
      GoRoute(
        path: '/team/:id/join',
        builder: (context, state) => HostTeamDetailScreen(
          teamId: state.pathParameters['id'] ?? '',
          currentUserId: ref.read(currentPlayerIdProvider),
          autoJoin: true,
          callbacks: TeamDetailCallbacks(
            onNavigateBack: (ctx) =>
                Navigator.of(ctx).canPop() ? Navigator.of(ctx).pop() : null,
          ),
        ),
      ),
      GoRoute(
        path: '/score-match/:id',
        builder: (_, state) {
          final matchId = state.pathParameters['id'] ?? '';
          return ScoringScreen(
            matchId: matchId,
            currentPlayerId: currentPlayerId,
            onNavigateBack: (context, id) => context.go('/match/$id'),
            onNavigateToPlaying11: (context, id, teamA, teamB) =>
                context.push(
                  '/create-match?matchId=${Uri.encodeQueryComponent(id)}'
                  '&teamA=${Uri.encodeQueryComponent(teamA)}'
                  '&teamB=${Uri.encodeQueryComponent(teamB)}',
                ),
          );
        },
      ),
      GoRoute(
        path: '/match-toss/:id',
        builder: (_, state) {
          final extra = state.extra as Map<String, String>? ?? {};
          return TossScreen(
            matchId: state.pathParameters['id'] ?? '',
            teamAName: extra['teamAName'] ?? 'Team A',
            teamBName: extra['teamBName'] ?? 'Team B',
          );
        },
      ),
      GoRoute(
        path: '/chat',
        builder: (_, __) => const ConversationsScreen(),
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (_, state) => ChatScreen(
          conversationId: state.pathParameters['id'] ?? '',
          conversation:
              state.extra is Conversation ? state.extra as Conversation : null,
        ),
      ),
    ],
  );
});

class RouterRefreshStream extends ChangeNotifier {
  RouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
