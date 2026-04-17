class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String checkPhone = '/auth/check-phone';
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh';

  // Player
  static const String playerProfile = '/player/profile';
  static const String playerProfileAvatar = '/player/profile/avatar';
  static const String playerProfileFull = '/player/profile/full';
  static const String completeOnboarding =
      '/player/profile/complete-onboarding';
  static const String playerStats = '/player/stats';
  static const String playerStatsTrend = '/player/stats/trend';
  static const String playerMatches = '/player/matches';
  static const String playerBadges = '/player/badges';
  static const String playerIpLog = '/player/ip-log';
  static const String playerCompetitive = '/player/competitive';
  static const String playerDrills = '/player/drills';
  static const String playerDrillAssignments = '/player/drill-assignments';
  static const String playerTrainingPlans = '/player/training-plans';
  static const String playerFeedback = '/player/feedback';
  static const String playerReportCards = '/player/report-cards';
  static const String playerSessions = '/player/sessions';
  static const String playerEnrollments = '/player/enrollments';
  static const String playerCard = '/player/card';
  static const String playerWeeklyReview = '/player/weekly-review';
  static const String playerLiveSession = '/player/sessions/live';
  static const String playerSearch = '/player/search';
  static const String playerLeaderboard = '/player/leaderboard';
  static const String playerRecommendations = '/player/recommendations';
  static const String playerFollowers = '/player/followers';
  static const String playerFollowing = '/player/following';
  static const String playerShowcase = '/player/showcase';
  static String publicPlayerProfile(String id) => '/player/profile/$id';
  static String publicPlayerProfileFull(String id) =>
      '/player/profile/$id/full';
  static String publicPlayerMatches(String id) => '/player/profile/$id/matches';
  static String playerFollow(String id) => '/player/follow/player/$id';
  static String playerFollowStatus(String id) =>
      '/player/follow/player/$id/status';

  // Chat
  static const String chatConversations = '/chat/conversations';
  static String chatConversation(String id) => '/chat/conversations/$id';
  static String chatDirect(String playerId) => '/chat/direct/$playerId';
  static String chatConversationMessages(String id) =>
      '/chat/conversations/$id/messages';
  static String chatConversationRead(String id) =>
      '/chat/conversations/$id/read';
  static String chatTeam(String teamId) => '/chat/team/$teamId';
  static String chatTeamLeave(String teamId) => '/chat/team/$teamId/leave';

  // Elite Analytics
  static String elitePlayerProfile(String id) => '/v1/elite/player/$id/profile';
  static String elitePlayerJournal(String id) => '/v1/elite/player/$id/journal';
  static String elitePlayerGoal(String id) => '/v1/elite/player/$id/goal';
  static String elitePlayerStatsExtended(String id) =>
      '/v1/elite/player/$id/stats-extended';
  static const String playerGrowthInsights = '/v1/player/growth-insights';
  static const String playerNearbyCoaches = '/v1/player/nearby-coaches';
  static String elitePlayerAnalytics(String id) => '/v1/elite/player/$id/analytics';
  static String elitePlayerApexState(String id) => '/v1/elite/player/$id/apex-state';
  static String elitePlayerBenchmarks(String id) =>
      '/v1/elite/player/$id/benchmarks';
  static String elitePlayerExecuteSummary(String id) =>
      '/v1/elite/player/$id/execute-summary';
  static String elitePlayerSwot(String id) => '/v1/elite/player/$id/swot';
  static String elitePlayerSignals(String id) => '/v1/elite/player/$id/signals';
  static String elitePlayerPrecision(String id) =>
      '/v1/elite/player/$id/precision';
  static String eliteTeamAnalytics(String id) => '/v1/elite/team/$id/analytics';
  static const String eliteTeamCompare = '/v1/elite/team/compare';
  static const String elitePlayerCompare = '/v1/elite/analytics/compare';

  // My Plan
  static const String eliteMyPlan = '/v1/elite/my-plan';

  // Elite Plan → Execution
  static String eliteDayLog(String date) => '/v1/elite/day-log/$date';
  static String eliteDayLogPlan(String date) => '/v1/elite/day-log/$date/plan';
  static String eliteDayLogExecute(String date) =>
      '/v1/elite/day-log/$date/execute';
  static const String eliteExecutionStreak = '/v1/elite/stats/execution-streak';
  static String elitePlayerJournalStreak(String id, {int days = 30}) =>
      '/v1/elite/player/$id/journal-streak?days=$days';
  static const String eliteWeeklyTemplates = '/v1/elite/weekly-templates';

  // Payments
  static const String payments = '/payments';
  static const String paymentOrders = '/payments/orders';
  static const String paymentVerify = '/payments/verify';
  static const String bookings = '/bookings';

  // Matches
  static const String matches = '/matches';
  static String matchById(String id) => '/matches/$id';
  static String matchToss(String id) => '/matches/$id/toss';
  static String matchStart(String id) => '/matches/$id/start';
  static String matchBall(String id, int inningsNumber) =>
      '/matches/$id/innings/$inningsNumber/ball';
  static String matchInningsComplete(String id, int inningsNumber) =>
      '/matches/$id/innings/$inningsNumber/complete';
  static String matchComplete(String id) => '/matches/$id/complete';
  static String matchLastBall(String id, int inningsNumber) =>
      '/matches/$id/innings/$inningsNumber/last-ball';
  static String matchPreview(String id) => '/matches/$id/preview';
  static String matchScorecard(String id) => '/matches/$id/scorecard';
  static String matchHighlights(String id) => '/matches/$id/highlights';
  static String matchCommentary(String id) => '/matches/$id/commentary';
  static String matchAnalysis(String id) => '/matches/$id/analysis';
  static String matchPlayers(String id) => '/matches/$id/players';
  static String publicOverlay(String id) => '/public/overlay/$id';
  static String publicOverlayStream(String id) => '/public/overlay/$id/stream';

  // Arenas
  static const String arenas = '/arenas';
  static String arenaById(String id) => '/arenas/$id';
  static String arenaAvailability(String id) => '/arenas/$id/availability';
  static String arenaBookings(String id) => '/arenas/$id/bookings';
  static String bookingPay(String id) => '/bookings/$id/pay';

  // Admin – Arenas
  static const String adminArenas = '/admin/arenas';
  static String adminArenaVerify(String id) => '/admin/arenas/$id/verify';
  static String adminArenaToggleSwing(String id) =>
      '/admin/arenas/$id/toggle-swing';

  // Gigs (coaching)
  static const String gigs = '/gigs';
  static String gigById(String id) => '/gigs/$id';
  static String gigBook(String id) => '/gigs/$id/book';

  // Matchmaking
  static const String matchmakingQueue = '/matchmaking/queue';
  static String matchmakingQueueById(String id) => '/matchmaking/queue/$id';
  static String matchmakingConfirm(String id) => '/matchmaking/confirm/$id';

  // Sessions
  static const String sessionsScan = '/sessions/scan';
  static String sessionJoinApp(String id) => '/sessions/$id/join-app';
  static String sessionJoinQr(String id) => '/sessions/$id/join-qr';

  // Drills
  static String drillComplete(String id) => '/player/drills/$id/complete';
  static String drillLog(String id) => '/player/drills/$id/log';

  // Teams
  static const String teams = '/teams';
  static const String myTeams = '/player/teams';
  static const String searchTeams = '/player/teams/search';
  static String teamById(String id) => '/teams/$id';
  static String teamJoin(String id) => '/teams/$id/join';
  static String teamLeave(String id) => '/teams/$id/leave';
  static String teamFollow(String id) => '/player/follow/team/$id';
  static String teamFollowStatus(String id) => '/player/follow/team/$id/status';
  static String teamMembers(String id) => '/teams/$id/members';
  static String teamMember(String teamId, String profileId) =>
      '/teams/$teamId/members/$profileId';
  static String playerTeamPlayers(String id) => '/player/teams/$id/players';
  static String playerTeamPublic(String id) => '/player/teams/$id/public';
  static String playerTeamMatches(String id) => '/player/teams/$id/matches';
  static String playerTeamQuickAdd(String id) =>
      '/player/teams/$id/players/quick-add';
  static String playerTeamRoles(String id) => '/player/teams/$id/roles';
  static const String adminTeams = '/admin/teams';
  static String adminTeamById(String id) => '/admin/teams/$id';
  static String adminTeamPlayers(String id) => '/admin/teams/$id/players';
  static String adminTeamPlayer(String teamId, String playerId) =>
      '/admin/teams/$teamId/players/$playerId';

  // Health
  static const String healthDashboard = '/player/health/dashboard';
  static const String wellness = '/player/wellness';
  static const String wellnessLatest = '/player/wellness/latest';
  static const String wellnessHistory = '/player/wellness/history';
  static const String workload = '/player/workload';
  static const String workloadRecent = '/player/workload/recent';
  static const String workloadSummary = '/player/workload/summary';
  static const String workloadHistory = '/player/workload/history';
  static const String wearablesIngest = '/wearables/ingest';

  // Diet & Nutrition (v1)
  static const String dietLog = '/diet/log';
  static const String dietSummary = '/diet/summary';
  static const String fitnessLog = '/fitness/log';
  static const String fitnessSummary = '/fitness/summary';
  static const String nutritionLibrary = '/library/nutrition-items';
  static const String fitnessLibrary = '/library/fitness-exercises';


  // Storefront
  static const String storeSearch = '/store/search';
  static const String storeOrders = '/store/orders';
  static const String storeCategories = '/store/categories';
  static String storeById(String id) => '/store/$id';
  static String storeInventory(String id) => '/store/$id/inventory';
  static String storeOrderById(String id) => '/store/orders/$id';

  // Player-hosted
  static const String myTournaments = '/player/tournaments';
  static const String myEvents = '/player/events';

  // Tournaments
  static const String publicTournaments = '/public/tournaments';
  static const String publicCities = '/public/cities';
  static const String notifications = '/notifications';
  static const String notificationsSummary = '/notifications/summary';
  static const String notificationPreferences = '/notifications/preferences';
  static const String notificationsReadAll = '/notifications/read-all';
  static const String fcmToken = '/notifications/fcm-token';
  static String notificationRead(String id) => '/notifications/$id/read';
  static String publicTournamentBySlug(String slug) =>
      '/public/tournament/$slug';
  static String publicTournamentMatches(String slug) =>
      '/public/tournament/$slug/matches';
  static String publicTournamentStandings(String slug) =>
      '/public/tournament/$slug/standings';
  static String publicTournamentLeaderboard(String slug) =>
      '/public/tournament/$slug/leaderboard';
  static String tournamentFollow(String id) => '/player/follow/tournament/$id';
  static String tournamentFollowStatus(String id) =>
      '/player/follow/tournament/$id/status';
  static const String playerFollowFollowing = '/player/follow/following';
  static const String playerFollowingTeams = '/player/following/teams';
  static const String playerFollowingTournaments =
      '/player/following/tournaments';
  static String adminTournamentById(String id) => '/admin/tournaments/$id';
}
