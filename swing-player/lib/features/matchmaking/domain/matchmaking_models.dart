import '../../teams/domain/team_models.dart';

// ── Team ──────────────────────────────────────────────────────────────────────

class MmTeam {
  const MmTeam({
    required this.id,
    required this.name,
    required this.ageGroupLabel,
    this.logoUrl,
    this.memberCount = 0,
    this.matchesPlayed = 0,
  });

  final String id;
  final String name;
  final String ageGroupLabel;
  final String? logoUrl;
  final int memberCount;
  final int matchesPlayed;

  static MmTeam fromPlayerTeam(PlayerTeam t) {
    final type = (t.teamType ?? '').toUpperCase().trim();
    final ageGroup = switch (true) {
      _ when type.contains('U12') => 'U-12',
      _ when type.contains('U14') => 'U-14',
      _ when type.contains('U16') => 'U-16',
      _ when type.contains('U19') => 'U-19',
      _ when type.contains('CORP') => 'Corporate',
      _ when type.contains('VETERAN') => 'Veterans',
      _ => 'Open',
    };
    return MmTeam(
      id: t.id,
      name: t.name,
      ageGroupLabel: ageGroup,
      logoUrl: t.logoUrl,
      memberCount: t.members.length,
    );
  }
}

// ── Ground & slot ─────────────────────────────────────────────────────────────

class MmSlot {
  const MmSlot({
    required this.time,
    required this.unitId,
    required this.hasOpponent,
    required this.pricePerTeamPaise,
    this.endTime,
  });

  final String time;      // "07:00" 24h start
  final String? endTime;  // "15:00" 24h end
  final String unitId;
  final bool hasOpponent;
  final int pricePerTeamPaise;

  int get priceRupees => pricePerTeamPaise ~/ 100;

  String get displayTime {
    final start = _fmt(time);
    if (endTime != null && endTime!.isNotEmpty) {
      return '$start – ${_fmt(endTime!)}';
    }
    return start;
  }

  static String _fmt(String t) {
    try {
      final parts = t.split(':');
      final hour = int.parse(parts[0]);
      final min = parts[1];
      final ampm = hour < 12 ? 'AM' : 'PM';
      final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      return '$h:$min $ampm';
    } catch (_) {
      return t;
    }
  }

  factory MmSlot.fromJson(Map<String, dynamic> j, {String? fallbackUnitId}) =>
      MmSlot(
        time: j['time'] as String,
        endTime: j['endTime'] as String?,
        unitId: (j['unitId'] as String?) ?? fallbackUnitId ?? '',
        hasOpponent: (j['hasOpponent'] as bool?) ?? false,
        pricePerTeamPaise: (j['pricePerTeam'] as num?)?.toInt() ?? 90000,
      );
}

class MmGround {
  const MmGround({
    required this.id,
    required this.name,
    required this.area,
    required this.slots,
    this.photoUrl,
  });

  final String id;
  final String name;
  final String area;
  final String? photoUrl;
  final List<MmSlot> slots;

  factory MmGround.fromJson(Map<String, dynamic> j) {
    final unitId = j['unitId'] as String?;
    return MmGround(
      id: j['id'] as String,
      name: j['name'] as String,
      area: (j['area'] as String?) ?? '',
      photoUrl: j['photoUrl'] as String?,
      slots: ((j['slots'] as List?) ?? [])
          .whereType<Map<String, dynamic>>()
          .map((s) => MmSlot.fromJson(s, fallbackUnitId: unitId))
          .toList(),
    );
  }
}

class MmGroundSlotPick {
  const MmGroundSlotPick({required this.ground, required this.slot});
  final MmGround ground;
  final MmSlot slot;
}

// ── Lobby / match ─────────────────────────────────────────────────────────────

class MmOpenLobby {
  const MmOpenLobby({
    required this.lobbyId,
    required this.teamName,
    required this.ageGroup,
    required this.format,
    required this.groundName,
    required this.slotTime,
    required this.date,
    required this.daysFromNow,
  });

  final String lobbyId;
  final String teamName;
  final String ageGroup;
  final String format;
  final String groundName;
  final String slotTime;   // "07:00"
  final String date;       // "YYYY-MM-DD"
  final int daysFromNow;

  String get displaySlot {
    try {
      final parts = slotTime.split(':');
      final hour = int.parse(parts[0]);
      final min = parts[1];
      final ampm = hour < 12 ? 'AM' : 'PM';
      final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      return '$h:$min $ampm';
    } catch (_) {
      return slotTime;
    }
  }

  String get dateLabel {
    if (daysFromNow == 0) return 'Today';
    if (daysFromNow == 1) return 'Tomorrow';
    try {
      final d = DateTime.parse(date);
      const m = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${m[d.month]} ${d.day}';
    } catch (_) {
      return date;
    }
  }

  factory MmOpenLobby.fromJson(Map<String, dynamic> j) {
    final date = (j['date'] as String?) ?? '';
    final today = DateTime.now();
    int daysFromNow = 0;
    try {
      final d = DateTime.parse(date);
      daysFromNow = d
          .difference(DateTime(today.year, today.month, today.day))
          .inDays;
    } catch (_) {}
    return MmOpenLobby(
      lobbyId: j['lobbyId'] as String,
      teamName: (j['teamName'] as String?) ?? 'Unknown',
      ageGroup: (j['ageGroup'] as String?) ?? 'Open',
      format: (j['format'] as String?) ?? 'T20',
      groundName: (j['groundName'] as String?) ?? '',
      slotTime: (j['slotTime'] as String?) ?? '',
      date: date,
      daysFromNow: daysFromNow,
    );
  }
}

class MmMatchSummary {
  const MmMatchSummary({
    required this.matchId,
    required this.groundId,
    required this.groundName,
    required this.groundArea,
    required this.slotTime,
    required this.date,
    required this.format,
    required this.opponentTeamName,
    required this.pricePerTeamPaise,
    required this.confirmDeadline,
  });

  final String matchId;
  final String groundId;
  final String groundName;
  final String groundArea;
  final String slotTime;
  final String date;
  final String format;
  final String opponentTeamName;
  final int pricePerTeamPaise;
  final DateTime confirmDeadline;

  int get priceRupees => pricePerTeamPaise ~/ 100;

  String get displaySlot {
    try {
      final parts = slotTime.split(':');
      final hour = int.parse(parts[0]);
      final min = parts[1];
      final ampm = hour < 12 ? 'AM' : 'PM';
      final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      return '$h:$min $ampm';
    } catch (_) {
      return slotTime;
    }
  }

  factory MmMatchSummary.fromJson(Map<String, dynamic> j) => MmMatchSummary(
        matchId: j['matchId'] as String,
        groundId: j['groundId'] as String,
        groundName: (j['groundName'] as String?) ?? '',
        groundArea: (j['groundArea'] as String?) ?? '',
        slotTime: (j['slotTime'] as String?) ?? '',
        date: (j['date'] as String?) ?? '',
        format: (j['format'] as String?) ?? '',
        opponentTeamName: (j['opponentTeamName'] as String?) ?? 'Opponent',
        pricePerTeamPaise:
            (j['pricePerTeam'] as num?)?.toInt() ?? 90000,
        confirmDeadline:
            DateTime.parse(j['confirmDeadline'] as String),
      );
}

class MmLobbyStatus {
  const MmLobbyStatus({
    required this.lobbyId,
    required this.status,
    this.match,
  });

  final String lobbyId;
  final String status; // searching | matched | confirmed | expired | cancelled
  final MmMatchSummary? match;

  factory MmLobbyStatus.fromJson(Map<String, dynamic> j) => MmLobbyStatus(
        lobbyId: j['lobbyId'] as String,
        status: j['status'] as String,
        match: j['match'] != null
            ? MmMatchSummary.fromJson(j['match'] as Map<String, dynamic>)
            : null,
      );
}

class MmCreateLobbyResult {
  const MmCreateLobbyResult({
    required this.lobbyId,
    required this.status,
    this.match,
  });

  final String lobbyId;
  final String status;
  final MmMatchSummary? match;

  factory MmCreateLobbyResult.fromJson(Map<String, dynamic> j) =>
      MmCreateLobbyResult(
        lobbyId: j['lobbyId'] as String,
        status: j['status'] as String,
        match: j['match'] != null
            ? MmMatchSummary.fromJson(j['match'] as Map<String, dynamic>)
            : null,
      );
}
