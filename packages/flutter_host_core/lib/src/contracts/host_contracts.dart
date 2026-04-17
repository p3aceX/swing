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
}
