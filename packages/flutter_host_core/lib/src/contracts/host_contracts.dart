class HostContracts {
  static const arenas = '/public/arenas';
  static String arenaAddons(String arenaId) => '/arenas/$arenaId/addons';
  static String arenaAvailability(String arenaId) =>
      '/arenas/$arenaId/availability';
  static const myTournaments = '/tournaments/me';
  static String tournament(String id) => '/tournaments/$id';
  static const myMatches = '/matches/me';
  static String match(String id) => '/matches/$id';
  static String matchPlayers(String id) => '/matches/$id/players';
  static String matchToss(String id) => '/matches/$id/toss';
  static String matchScorer(String id) => '/matches/$id/scorer';
  static String inningsBall(String id, int innings) =>
      '/matches/$id/innings/$innings/ball';
  static String inningsComplete(String id, int innings) =>
      '/matches/$id/innings/$innings/complete';
  static String inningsUndo(String id, int innings) =>
      '/matches/$id/innings/$innings/last-ball';
  static String inningsState(String id, int innings) =>
      '/matches/$id/innings/$innings/state';
  static const playerSearch = '/player/search';
  static const myTeams = '/teams';
  static const teamSearch = '/teams/search';
  static String teamPlayers(String teamId) => '/teams/$teamId/players';
  static String teamQuickAdd(String teamId) =>
      '/teams/$teamId/players/quick-add';
  static String teamPlayer(String teamId, String playerId) =>
      '/teams/$teamId/players/$playerId';
  static String createEvent() => '/events';

  // Biz (swing-biz app)
  static const bizLogin = '/auth/biz/login';
  static const authRefresh = '/auth/refresh';
  static const bizMe = '/biz/me';
  static const bizBusinessDetails = '/biz/business-details';
  static const bizAcademy = '/biz/academy';
  static const bizCoach = '/biz/coach';
  static const bizArena = '/biz/arena';
  static const bizStores = '/biz/stores';
}
