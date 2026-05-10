enum MatchLifecycle {
  upcoming,
  live,
  past
}

class MatchModel {
  final String id;
  final String title;
  final MatchLifecycle lifecycle;
  final String swingId;
  final String swingPass;
  final DateTime startTime;
  final bool involvesTeam;
  final String role;

  MatchModel({
    required this.id,
    required this.title,
    required this.lifecycle,
    required this.swingId,
    required this.swingPass,
    required this.startTime,
    this.involvesTeam = true,
    this.role = "owner",
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'],
      title: json['title'],
      lifecycle: _parseLifecycle(json['lifecycle']),
      swingId: json['swingId'] ?? "",
      swingPass: json['swingPass'] ?? "",
      startTime: DateTime.parse(json['startTime'] ?? DateTime.now().toIso8601String()),
      involvesTeam: json['involvesTeam'] ?? true,
      role: json['role'] ?? "owner",
    );
  }

  static MatchLifecycle _parseLifecycle(String? status) {
    switch (status?.toLowerCase()) {
      case 'live': return MatchLifecycle.live;
      case 'past': return MatchLifecycle.past;
      default: return MatchLifecycle.upcoming;
    }
  }
}
