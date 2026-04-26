/// Slim team summary used by host-shared screens that need a "pick from my
/// teams" picker. The full roster is fetched separately via
/// [HostTeamRepository.getTeamRoster] when needed.
class HostMyTeam {
  const HostMyTeam({
    required this.id,
    required this.name,
    required this.playerCount,
    required this.isOwner,
    this.shortName,
    this.city,
    this.logoUrl,
    this.teamType,
  });

  final String id;
  final String name;
  final String? shortName;
  final String? city;
  final String? logoUrl;
  final String? teamType;
  final int playerCount;
  final bool isOwner;
}

class HostMyTeams {
  const HostMyTeams({
    required this.mySquads,
    required this.playingFor,
  });

  /// Teams I created.
  final List<HostMyTeam> mySquads;

  /// Teams I belong to but didn't create.
  final List<HostMyTeam> playingFor;

  List<HostMyTeam> get all => [...mySquads, ...playingFor];
}
