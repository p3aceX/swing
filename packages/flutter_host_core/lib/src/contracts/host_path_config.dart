import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Logical API paths used by shared repositories.
///
/// The Fastify backend namespaces routes per-host (`/player/teams`,
/// `/admin/teams`, `/biz/...`). Repositories in this package stay
/// host-agnostic by taking the concrete paths from this config, which each
/// Flutter client overrides in its `ProviderScope`.
///
/// Defaults resolve to the player-facing endpoints — the primary consumer
/// today — so `swing-player` works without an explicit override. Admin or
/// other hosts provide `HostPathConfig.admin()` (or a hand-rolled config)
/// when bootstrapping.
class HostPathConfig {
  const HostPathConfig({
    required this.teamsBase,
    required this.teamsMutationBase,
    required this.tournamentsBase,
    required this.matchesBase,
    required this.arenasBase,
    required this.playerSearchPath,
    this.matchHistoryPath,
  });

  /// Collection root for teams read endpoints (e.g. `/player/teams`, `/admin/teams`).
  final String teamsBase;

  /// Collection root for team mutation endpoints (add/remove members, join, update, delete).
  /// For player this is `/player/teams`; for admin `/admin/teams`.
  final String teamsMutationBase;

  /// Collection root for tournaments.
  final String tournamentsBase;

  /// Collection root for matches.
  final String matchesBase;

  /// Collection root for venues / arenas.
  final String arenasBase;

  /// Full path for the player search endpoint.
  final String playerSearchPath;

  /// Override for the current user's match history endpoint.
  /// Defaults to `$matchesBase/me` when null.
  final String? matchHistoryPath;

  // ── Teams ───────────────────────────────────────────────────────────────
  String get myTeams => teamsBase;
  String get teamSearch => '$teamsBase/search';
  // Read routes (use teamsBase: /player/teams or /admin/teams)
  String team(String teamId) => '$teamsBase/$teamId';
  String teamPublic(String teamId) => '$teamsBase/$teamId/public';
  String teamMatches(String teamId) => '$teamsBase/$teamId/matches';
  String teamPlayers(String teamId) => '$teamsBase/$teamId/players';
  String teamQuickAdd(String teamId) => '$teamsBase/$teamId/players/quick-add';
  String teamPlayer(String teamId, String playerId) =>
      '$teamsBase/$teamId/players/$playerId';
  // Mutation routes (use teamsMutationBase: /player/teams or /admin/teams)
  String teamMember(String teamId, String profileId) =>
      '$teamsMutationBase/$teamId/players/$profileId';
  String teamJoin(String teamId) => '$teamsMutationBase/$teamId/join';
  String teamUpdate(String teamId) => '$teamsMutationBase/$teamId';
  String teamDelete(String teamId) => '$teamsMutationBase/$teamId';
  String teamAnalytics(String teamId) => '/v1/elite/team/$teamId/analytics';
  String teamFollow(String teamId) => '/player/follow/team/$teamId';
  String teamFollowStatus(String teamId) =>
      '/player/follow/team/$teamId/status';

  // ── Tournaments ─────────────────────────────────────────────────────────
  String get myTournaments => tournamentsBase;
  String tournament(String tournamentId) => '$tournamentsBase/$tournamentId';

  // ── Matches ─────────────────────────────────────────────────────────────
  String get createMatch => matchesBase;
  // Player match history lives at /player/matches (separate from public /matches/:id).
  String get myMatches => matchHistoryPath ?? '$matchesBase/me';
  String match(String matchId) => '$matchesBase/$matchId';
  String matchPlayers(String matchId) => '$matchesBase/$matchId/players';
  String matchScorecard(String matchId) => '$matchesBase/$matchId/scorecard';
  String matchPreview(String matchId) => '$matchesBase/$matchId/preview';
  String matchCommentary(String matchId) => '$matchesBase/$matchId/commentary';
  String matchAnalysis(String matchId) => '$matchesBase/$matchId/analysis';
  String matchOverlay(String matchId) => '/public/overlay/$matchId';
  String matchOverlayStream(String matchId) =>
      '/public/overlay/$matchId/stream';
  String publicPlayerMatches(String playerId) =>
      '/player/profile/$playerId/matches';
  String matchToss(String matchId) => '$matchesBase/$matchId/toss';
  String matchOvers(String matchId) => '$matchesBase/$matchId/overs';
  String matchWicketkeeper(String matchId) => '$matchesBase/$matchId/wicketkeeper';
  String matchScorer(String matchId) => '$matchesBase/$matchId/scorer';
  String matchStart(String matchId) => '$matchesBase/$matchId/start';
  String matchCancel(String matchId) => '$matchesBase/$matchId/cancel';
  String matchComplete(String matchId) => '$matchesBase/$matchId/complete';
  String matchContinueInnings(String matchId) =>
      '$matchesBase/$matchId/continue-innings';
  String inningsBall(String matchId, int innings) =>
      '$matchesBase/$matchId/innings/$innings/ball';
  String inningsComplete(String matchId, int innings) =>
      '$matchesBase/$matchId/innings/$innings/complete';
  String inningsUndo(String matchId, int innings) =>
      '$matchesBase/$matchId/innings/$innings/last-ball';
  String inningsState(String matchId, int innings) =>
      '$matchesBase/$matchId/innings/$innings/state';

  // ── Arenas / venues ─────────────────────────────────────────────────────
  String get arenas => arenasBase;
  String get ownedArenas => '$arenasBase/mine';
  String arena(String arenaId) => '$arenasBase/$arenaId';
  String arenaUnits(String arenaId) => '$arenasBase/$arenaId/units';
  String arenaUnit(String unitId) => '$arenasBase/u/$unitId';
  String arenaAddons(String arenaId) => '$arenasBase/$arenaId/addons';
  String arenaAddon(String addonId) => '$arenasBase/addons/$addonId';
  String arenaAvailability(String arenaId) =>
      '$arenasBase/$arenaId/availability';
  String arenaSlots(String arenaId) => '$arenasBase/$arenaId/slots';
  String arenaBlocks(String arenaId) => '$arenasBase/$arenaId/blocks';
  String arenaBlock(String blockId) => '$arenasBase/blocks/$blockId';
  String arenaMonthlyPasses(String arenaId) => '$arenasBase/$arenaId/monthly-passes';
  String monthlyPass(String passId) => '$arenasBase/monthly-passes/$passId';
  String monthlyPassCancel(String passId) => '$arenasBase/monthly-passes/$passId/cancel';

  // ── Bookings / reservations ─────────────────────────────────────────────
  String arenaReservations(String arenaId) => '/bookings/arena/$arenaId';
  String arenaBookingSummary(String arenaId) => '/bookings/arena/$arenaId/summary';
  String arenaGuests(String arenaId) => '/bookings/arena/$arenaId/guests';
  String arenaPayments(String arenaId) => '/bookings/arena/$arenaId/payments';
  String arenaManualBooking(String arenaId) => '/bookings/arena/$arenaId/manual';
  String bookingMarkPaid(String bookingId) => '/bookings/$bookingId/mark-paid';
  String bookingCancelByOwner(String bookingId) => '/bookings/$bookingId/cancel-by-owner';
  String bookingCheckinByOwner(String bookingId) => '/bookings/$bookingId/checkin-by-owner';
  String bookingPaymentOrder(String bookingId) => '/bookings/$bookingId/payment-order';
  String get verifyPayment => '/bookings/verify-payment';

  // ── Players ─────────────────────────────────────────────────────────────
  String get playerSearch => playerSearchPath;

  HostPathConfig copyWith({
    String? teamsBase,
    String? teamsMutationBase,
    String? tournamentsBase,
    String? matchesBase,
    String? arenasBase,
    String? playerSearchPath,
    String? matchHistoryPath,
  }) {
    return HostPathConfig(
      teamsBase: teamsBase ?? this.teamsBase,
      teamsMutationBase: teamsMutationBase ?? this.teamsMutationBase,
      tournamentsBase: tournamentsBase ?? this.tournamentsBase,
      matchesBase: matchesBase ?? this.matchesBase,
      arenasBase: arenasBase ?? this.arenasBase,
      playerSearchPath: playerSearchPath ?? this.playerSearchPath,
      matchHistoryPath: matchHistoryPath ?? this.matchHistoryPath,
    );
  }

  /// Paths for the player-facing Fastify module.
  factory HostPathConfig.player() => const HostPathConfig(
        teamsBase: '/player/teams',
        teamsMutationBase: '/player/teams',
        tournamentsBase: '/player/tournaments',
        matchesBase: '/matches',
        arenasBase: '/arenas',
        playerSearchPath: '/player/search',
        matchHistoryPath: '/player/matches',
      );

  /// Paths for the admin console (`/admin/*`).
  factory HostPathConfig.admin() => const HostPathConfig(
        teamsBase: '/admin/teams',
        teamsMutationBase: '/admin/teams',
        tournamentsBase: '/admin/tournaments',
        matchesBase: '/admin/matches',
        arenasBase: '/admin/arenas',
        playerSearchPath: '/admin/players/search',
      );
}

/// Override this in each host's `ProviderScope`. Defaults to the player
/// config so `swing-player` works without extra setup.
final hostPathConfigProvider = Provider<HostPathConfig>(
  (_) => HostPathConfig.player(),
);
