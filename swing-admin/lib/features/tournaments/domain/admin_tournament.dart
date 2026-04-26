class AdminTournament {
  const AdminTournament({
    required this.id,
    required this.name,
    required this.status,
    required this.format,
    required this.sport,
    required this.city,
    required this.venueName,
    required this.maxTeams,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.isVerified,
    required this.isPublic,
    required this.seriesMatchCount,
    required this.teamCount,
  });

  final String id;
  final String name;
  final String status;
  final String format;
  final String sport;
  final String city;
  final String venueName;
  final int maxTeams;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final bool isVerified;
  final bool isPublic;
  final int? seriesMatchCount;
  final int teamCount;

  factory AdminTournament.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
      return null;
    }

    int? parseNullableInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    final teamsRaw = json['teams'];
    final teamCount = teamsRaw is List ? teamsRaw.length : 0;

    return AdminTournament(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'UNKNOWN',
      format: json['format']?.toString() ?? '',
      sport: json['sport']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      venueName: json['venueName']?.toString() ?? '',
      maxTeams: parseNullableInt(json['maxTeams']) ?? 0,
      startDate: parseDate(json['startDate']),
      endDate: parseDate(json['endDate']),
      createdAt: parseDate(json['createdAt']),
      isVerified: json['isVerified'] == true,
      isPublic: json['isPublic'] == true,
      seriesMatchCount: parseNullableInt(json['seriesMatchCount']),
      teamCount: teamCount,
    );
  }
}

class AdminTournamentsPage {
  const AdminTournamentsPage({
    required this.tournaments,
    required this.total,
    required this.page,
    required this.limit,
  });

  final List<AdminTournament> tournaments;
  final int total;
  final int page;
  final int limit;
}
