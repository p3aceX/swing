import 'package:intl/intl.dart';

// ─── Tournament ───────────────────────────────────────────────────────────────

class PlayTournament {
  const PlayTournament({
    required this.id,
    required this.name,
    required this.status,
    required this.format,
    required this.startDate,
    required this.teamCount,
    required this.maxTeams,
    required this.isHost,
    required this.isParticipating,
    this.slug,
    this.city,
    this.venueName,
    this.logoUrl,
    this.entryFee,
    this.endDate,
    this.ballType,
  });

  final String id;
  final String name;
  final String status;
  final String format;
  final DateTime startDate;
  final DateTime? endDate;
  final int teamCount;
  final int maxTeams;
  final bool isHost;
  final bool isParticipating;
  final String? slug;
  final String? city;
  final String? venueName;
  final String? logoUrl;
  final int? entryFee;
  final String? ballType;

  factory PlayTournament.fromJson(
    Map<String, dynamic> json, {
    bool forceHost = false,
    bool forceParticipating = false,
  }) {
    final count = json['_count'];
    final teamCount = count is Map
        ? (_n(count['teams']) ?? _n(count['registrations']) ?? 0)
        : (_n(json['teamCount']) ?? _n(json['registrationCount']) ?? 0);

    return PlayTournament(
      id: _s(json['id']),
      name: _s(json['name'], fallback: 'Tournament'),
      status: _s(json['status'], fallback: 'UPCOMING'),
      format: _s(json['format'], fallback: 'T20'),
      startDate: _dt(json['startDate']) ?? DateTime.now(),
      endDate: _dt(json['endDate']),
      teamCount: teamCount,
      maxTeams: _n(json['maxTeams']) ?? 16,
      isHost: forceHost || json['isHost'] == true,
      isParticipating:
          forceParticipating || json['isParticipating'] == true || json['isHost'] == true,
      slug: _ns(json['slug']),
      city: _ns(json['city']),
      venueName: _ns(json['venueName']),
      logoUrl: _ns(json['logoUrl']),
      entryFee: _n(json['entryFee']),
      ballType: _ns(json['ballType']),
    );
  }

  PlayTournament copyWith({bool? isHost, bool? isParticipating}) {
    return PlayTournament(
      id: id, name: name, status: status, format: format,
      startDate: startDate, endDate: endDate, teamCount: teamCount,
      maxTeams: maxTeams, slug: slug, city: city, venueName: venueName,
      logoUrl: logoUrl, entryFee: entryFee, ballType: ballType,
      isHost: isHost ?? this.isHost,
      isParticipating: isParticipating ?? this.isParticipating,
    );
  }

  String get dateRange {
    final fmt = DateFormat('d MMM');
    if (endDate == null) return fmt.format(startDate);
    return '${fmt.format(startDate)} – ${fmt.format(endDate!)}';
  }
}

// ─── Parsing helpers ──────────────────────────────────────────────────────────

String _s(dynamic v, {String fallback = ''}) {
  final t = '$v'.trim();
  return (v == null || t == 'null') ? fallback : t;
}

String? _ns(dynamic v) {
  final t = _s(v);
  return t.isEmpty ? null : t;
}

int? _n(dynamic v) => (v as num?)?.toInt();

DateTime? _dt(dynamic v) {
  if (v == null) return null;
  try {
    return DateTime.parse('$v').toLocal();
  } catch (_) {
    return null;
  }
}
