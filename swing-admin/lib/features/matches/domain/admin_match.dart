class AdminMatch {
  const AdminMatch({
    required this.id,
    required this.status,
    required this.teamAName,
    required this.teamBName,
    required this.venueName,
    required this.matchType,
    required this.format,
    required this.round,
    required this.scheduledAt,
    required this.createdAt,
    required this.verificationLevel,
    required this.liveStreamUrl,
    required this.liveCode,
    required this.livePin,
    required this.tossWonBy,
    required this.tossDecision,
    required this.winMargin,
    required this.resultText,
    required this.highlights,
    required this.innings,
  });

  final String id;
  final String status;
  final String teamAName;
  final String teamBName;
  final String venueName;
  final String matchType;
  final String format;
  final String round;
  final DateTime? scheduledAt;
  final DateTime? createdAt;
  final String verificationLevel;
  final String liveStreamUrl;
  final String liveCode;
  final String livePin;
  final String tossWonBy;
  final String tossDecision;
  final String winMargin;
  final String resultText;
  final List<MatchHighlight> highlights;
  final List<MatchInningsSummary> innings;

  String get displayTitle {
    final teamA = teamAName.trim().isEmpty ? 'Team A' : teamAName.trim();
    final teamB = teamBName.trim().isEmpty ? 'Team B' : teamBName.trim();
    return '$teamA vs $teamB';
  }

  bool get hasLiveStream => liveStreamUrl.trim().isNotEmpty;

  factory AdminMatch.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
      return null;
    }

    final inningsRaw = json['innings'];
    final innings = inningsRaw is List
        ? inningsRaw
            .whereType<Map>()
            .map((entry) =>
                MatchInningsSummary.fromJson(Map<String, dynamic>.from(entry)))
            .toList()
        : const <MatchInningsSummary>[];
    final highlightsRaw = json['highlights'];
    final highlights = highlightsRaw is List
        ? highlightsRaw
            .whereType<Map>()
            .map((entry) =>
                MatchHighlight.fromJson(Map<String, dynamic>.from(entry)))
            .toList()
        : const <MatchHighlight>[];

    return AdminMatch(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'UNKNOWN',
      teamAName: json['teamAName']?.toString() ?? '',
      teamBName: json['teamBName']?.toString() ?? '',
      venueName: json['venueName']?.toString() ?? '',
      matchType: json['matchType']?.toString() ?? '',
      format: json['format']?.toString() ?? '',
      round: json['round']?.toString() ?? '',
      scheduledAt: parseDate(json['scheduledAt']),
      createdAt: parseDate(json['createdAt']),
      verificationLevel: json['verificationLevel']?.toString() ?? '',
      liveStreamUrl: json['youtubeLiveUrl']?.toString() ?? '',
      liveCode: json['liveCode']?.toString() ?? '',
      livePin: json['livePin']?.toString() ?? '',
      tossWonBy: json['tossWonBy']?.toString() ?? '',
      tossDecision: json['tossDecision']?.toString() ?? '',
      winMargin: json['winMargin']?.toString() ?? '',
      resultText: json['resultText']?.toString() ?? '',
      highlights: highlights,
      innings: innings,
    );
  }
}

class MatchInningsSummary {
  const MatchInningsSummary({
    required this.inningsNumber,
    required this.totalRuns,
    required this.totalWickets,
    required this.totalOvers,
    required this.extras,
    required this.isCompleted,
    required this.battingTeam,
    required this.ballEvents,
  });

  final int inningsNumber;
  final int totalRuns;
  final int totalWickets;
  final double totalOvers;
  final int extras;
  final bool isCompleted;
  final String battingTeam;
  final List<MatchBallEvent> ballEvents;

  factory MatchInningsSummary.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    final rawBallEvents = json['ballEvents'];
    final ballEvents = rawBallEvents is List
        ? rawBallEvents
            .whereType<Map>()
            .map((entry) =>
                MatchBallEvent.fromJson(Map<String, dynamic>.from(entry)))
            .toList()
        : const <MatchBallEvent>[];

    return MatchInningsSummary(
      inningsNumber: parseInt(json['inningsNumber']),
      totalRuns: parseInt(json['totalRuns']),
      totalWickets: parseInt(json['totalWickets']),
      totalOvers: parseDouble(json['totalOvers']),
      extras: parseInt(json['extras']),
      isCompleted: json['isCompleted'] == true,
      battingTeam: json['battingTeam']?.toString() ?? '',
      ballEvents: ballEvents,
    );
  }
}

class MatchBallEvent {
  const MatchBallEvent({
    required this.overNumber,
    required this.ballNumber,
    required this.runsOffBat,
    required this.extras,
    required this.extraType,
    required this.isWicket,
    required this.dismissalType,
    required this.batterId,
    required this.bowlerId,
    required this.dismissedPlayerId,
  });

  final int overNumber;
  final int ballNumber;
  final int runsOffBat;
  final int extras;
  final String extraType;
  final bool isWicket;
  final String dismissalType;
  final String batterId;
  final String bowlerId;
  final String dismissedPlayerId;

  int get totalRuns => runsOffBat + extras;

  factory MatchBallEvent.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return MatchBallEvent(
      overNumber: parseInt(json['overNumber']),
      ballNumber: parseInt(json['ballNumber']),
      runsOffBat: parseInt(json['runsOffBat']),
      extras: parseInt(json['extras']),
      extraType: json['extraType']?.toString() ?? '',
      isWicket: json['isWicket'] == true,
      dismissalType: json['dismissalType']?.toString() ?? '',
      batterId: json['batterId']?.toString() ?? '',
      bowlerId: json['bowlerId']?.toString() ?? '',
      dismissedPlayerId: json['dismissedPlayerId']?.toString() ?? '',
    );
  }
}

class MatchHighlight {
  const MatchHighlight({
    required this.id,
    required this.title,
    required this.url,
  });

  final String id;
  final String title;
  final String url;

  factory MatchHighlight.fromJson(Map<String, dynamic> json) {
    return MatchHighlight(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
    );
  }
}

class AdminMatchesPage {
  const AdminMatchesPage({
    required this.matches,
    required this.total,
    required this.page,
    required this.limit,
  });

  final List<AdminMatch> matches;
  final int total;
  final int page;
  final int limit;
}
