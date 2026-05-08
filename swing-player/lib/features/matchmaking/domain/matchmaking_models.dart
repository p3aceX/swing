import '../../teams/domain/team_models.dart';

// ── Match format ──────────────────────────────────────────────────────────────

enum MatchFormat {
  t10('T10'),
  t20('T20'),
  odi('ODI'),
  test('Test'),
  custom('Custom Over');

  const MatchFormat(this.label);
  final String label;
}

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

  // Short label used when stacking start/end in a tile: "7:00 AM"
  String get startLabel => _fmt(time);
  // Short label for the end time: "3:00 PM"
  String get endLabel => endTime != null && endTime!.isNotEmpty ? _fmt(endTime!) : '';

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
    this.isArenaLobby = false,
    this.arenaName = '',
    this.ballType,
    this.unitId,
    this.pricePerTeamPaise = 90000,
    this.timeWindow,
    this.preferredArenaId,
    this.preferredArenaName,
    this.windowsRanked = const [],
    this.windowsMatched = const [],
    this.groundsRanked = const [],
    this.teamId,
    this.status,
    this.slotLabel,
  });

  final String lobbyId;
  final String teamName;
  final String ageGroup;
  final String format;
  final String groundName;
  final String slotTime;
  final String date;
  final int daysFromNow;
  final bool isArenaLobby;
  final String arenaName;
  final String? ballType;
  final String? unitId;
  final int pricePerTeamPaise;
  // Legacy single-window field kept for back-compat. Null on V2 multi-window
  // lobbies; consumers in the discover flow read [windowsRanked] instead.
  final String? timeWindow; // 'MORNING' | 'AFTERNOON' | 'EVENING'
  final String? preferredArenaId;
  final String? preferredArenaName;
  // V2: ranked time-window preferences (order = preference, first strongest).
  final List<String> windowsRanked;
  // V2: subset of [windowsRanked] already consumed by partial matches.
  final List<String> windowsMatched;
  // V2: ranked grounds (arenaId list, max 3, first = preferred).
  final List<String> groundsRanked;
  // Optional V2 fields (not always present on legacy responses).
  final String? teamId;
  final String? status;
  // Backend-rendered display label combining bucket + clock window. Examples:
  // "MORNING · 10:00 AM – 1:00 PM" (arena/picks-based), "MORNING window"
  // (pure-preference). Null on legacy responses; clients fall back to slotTime.
  final String? slotLabel;

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
      isArenaLobby: (j['isArenaLobby'] as bool?) ?? false,
      arenaName: (j['arenaName'] as String?) ?? '',
      ballType: j['ballType'] as String?,
      unitId: j['unitId'] as String?,
      pricePerTeamPaise: (j['pricePerTeam'] as num?)?.toInt() ?? 90000,
      timeWindow: j['timeWindow'] as String?,
      preferredArenaId: j['preferredArenaId'] as String?,
      preferredArenaName: j['preferredArenaName'] as String?,
      windowsRanked: ((j['windowsRanked'] as List?) ?? const [])
          .whereType<String>()
          .toList(),
      windowsMatched: ((j['windowsMatched'] as List?) ?? const [])
          .whereType<String>()
          .toList(),
      groundsRanked: ((j['groundsRanked'] as List?) ?? const [])
          .whereType<String>()
          .toList(),
      teamId: j['teamId'] as String?,
      status: j['status'] as String?,
      slotLabel: j['slotLabel'] as String?,
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
    this.status = 'pending_payment',
    this.confirmationFeePaise = 50000,
    this.groundFeePaise = 0,
    this.remainingFeePaise = 0,
    this.myTeamPaid = false,
    this.opponentPaid = false,
    this.myTeamConfirmed = false,
    this.opponentConfirmed = false,
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
  final String status;
  final int confirmationFeePaise;
  final int groundFeePaise;
  final int remainingFeePaise;
  final bool myTeamPaid;
  final bool opponentPaid;
  final bool myTeamConfirmed;
  final bool opponentConfirmed;

  int get priceRupees => pricePerTeamPaise ~/ 100;
  int get confirmationFeeRupees => confirmationFeePaise ~/ 100;
  int get groundFeeRupees => groundFeePaise ~/ 100;
  int get remainingFeeRupees => remainingFeePaise ~/ 100;

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
        pricePerTeamPaise: (j['pricePerTeam'] as num?)?.toInt() ?? 50000,
        confirmDeadline: DateTime.parse(j['confirmDeadline'] as String),
        status: (j['status'] as String?) ?? 'pending_payment',
        confirmationFeePaise: (j['confirmationFeePaise'] as num?)?.toInt() ?? 50000,
        groundFeePaise: (j['groundFeePaise'] as num?)?.toInt() ?? 0,
        remainingFeePaise: (j['remainingFeePaise'] as num?)?.toInt() ?? 0,
        myTeamPaid: (j['myTeamPaid'] as bool?) ?? false,
        opponentPaid: (j['opponentPaid'] as bool?) ?? false,
        myTeamConfirmed: (j['myTeamConfirmed'] as bool?) ?? false,
        opponentConfirmed: (j['opponentConfirmed'] as bool?) ?? false,
      );
}

class MmLobbyStatusPick {
  const MmLobbyStatusPick({
    required this.groundId,
    required this.slotTime,
    this.groundName,
  });
  final String groundId;
  final String slotTime;
  final String? groundName;
  factory MmLobbyStatusPick.fromJson(Map<String, dynamic> j) =>
      MmLobbyStatusPick(
        groundId: j['groundId'] as String,
        slotTime: j['slotTime'] as String? ?? '',
        groundName: j['groundName'] as String?,
      );
}

class MmLobbyStatus {
  const MmLobbyStatus({
    required this.lobbyId,
    required this.status,
    this.match,
    this.format,
    this.ballType,
    this.date,
    this.teamId,
    this.teamName,
    this.picks = const [],
    this.timeWindow,
    this.preferredArenaId,
    this.preferredArenaName,
    this.windowsRanked = const [],
    this.windowsMatched = const [],
    this.groundsRanked = const [],
  });

  final String lobbyId;
  final String status; // searching | matched | confirmed | expired | cancelled
  final MmMatchSummary? match;
  final String? format;
  final String? ballType;
  final String? date;
  final String? teamId;
  final String? teamName;
  final List<MmLobbyStatusPick> picks;
  // Legacy single-window field. V2 multi-window lobbies leave this null and
  // populate [windowsRanked] / [windowsMatched] / [groundsRanked] instead.
  final String? timeWindow;
  final String? preferredArenaId;
  final String? preferredArenaName;
  final List<String> windowsRanked;
  final List<String> windowsMatched;
  final List<String> groundsRanked;

  factory MmLobbyStatus.fromJson(Map<String, dynamic> j) => MmLobbyStatus(
        lobbyId: j['lobbyId'] as String,
        status: j['status'] as String,
        match: j['match'] != null
            ? MmMatchSummary.fromJson(j['match'] as Map<String, dynamic>)
            : null,
        format: j['format'] as String?,
        ballType: j['ballType'] as String?,
        date: j['date'] as String?,
        teamId: j['teamId'] as String?,
        teamName: j['teamName'] as String?,
        picks: (j['picks'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .map(MmLobbyStatusPick.fromJson)
                .toList() ??
            [],
        timeWindow: j['timeWindow'] as String?,
        preferredArenaId: j['preferredArenaId'] as String?,
        preferredArenaName: j['preferredArenaName'] as String?,
        windowsRanked: ((j['windowsRanked'] as List?) ?? const [])
            .whereType<String>()
            .toList(),
        windowsMatched: ((j['windowsMatched'] as List?) ?? const [])
            .whereType<String>()
            .toList(),
        groundsRanked: ((j['groundsRanked'] as List?) ?? const [])
            .whereType<String>()
            .toList(),
      );
}

// ── Discover-flow models ───────────────────────────────────────────────────

/// One open lobby with its match score and which factors matched/differed.
/// Returned by POST /matchmaking/discover. The V2 wire shape wraps the
/// lobby JSON under a `lobby` key alongside `score` / `matchedOn` / `differs`,
/// e.g. `{ lobby: {...}, score, matchedOn, differs }`. Older responses
/// inlined the lobby fields at the top level — both shapes are accepted here.
class MmRankedLobby {
  const MmRankedLobby({
    required this.lobby,
    required this.score,
    required this.matchedOn,
    required this.differs,
  });

  final MmOpenLobby lobby;
  final double score;
  final List<String> matchedOn; // e.g. ['date', 'window', 'ground']
  final List<String> differs;   // e.g. ['date'] when an alternative

  factory MmRankedLobby.fromJson(Map<String, dynamic> j) {
    // V2 wraps lobby fields under `lobby`; legacy shape inlines them.
    final lobbyJson = (j['lobby'] is Map<String, dynamic>)
        ? j['lobby'] as Map<String, dynamic>
        : j;
    return MmRankedLobby(
      lobby: MmOpenLobby.fromJson(lobbyJson),
      score: ((j['score'] as num?) ?? 0).toDouble(),
      matchedOn:
          ((j['matchedOn'] as List?) ?? []).whereType<String>().toList(),
      differs: ((j['differs'] as List?) ?? []).whereType<String>().toList(),
    );
  }
}

class MmDiscoverResponse {
  const MmDiscoverResponse({
    required this.yourLobbyId,
    required this.primary,
    required this.alternatives,
    this.alternativeReason,
  });

  final String yourLobbyId;
  // V2 wire-contract: lobbies whose rank-1 window+ground both intersect.
  // Backend field name is `primary` (was `closest` in the legacy response).
  final List<MmRankedLobby> primary;
  final List<MmRankedLobby> alternatives;
  final String? alternativeReason; // 'no_exact_matches' | 'few_exact_matches' | null

  factory MmDiscoverResponse.fromJson(Map<String, dynamic> j) {
    // Accept both V2 (`primary`) and legacy (`closest`) field names.
    final primaryRaw = (j['primary'] as List?) ?? (j['closest'] as List?) ?? [];
    return MmDiscoverResponse(
      yourLobbyId: j['yourLobbyId'] as String,
      primary: primaryRaw
          .whereType<Map<String, dynamic>>()
          .map(MmRankedLobby.fromJson)
          .toList(),
      alternatives: ((j['alternatives'] as List?) ?? [])
          .whereType<Map<String, dynamic>>()
          .map(MmRankedLobby.fromJson)
          .toList(),
      alternativeReason: j['alternativeReason'] as String?,
    );
  }
}

/// One team-active-lobby summary for the team-switcher chip.
class MmTeamLobbySummary {
  const MmTeamLobbySummary({
    required this.lobbyId,
    required this.teamId,
    required this.teamName,
    required this.status,
    required this.date,
    required this.format,
    this.ballType,
    this.timeWindow,
    this.preferredArenaId,
    this.windowsRanked = const [],
    this.windowsMatched = const [],
    this.groundsRanked = const [],
  });

  final String lobbyId;
  final String teamId;
  final String? teamName;
  final String status;
  final String date;
  final String format;
  final String? ballType;
  // Legacy back-compat single-window string. Null on V2 multi-window lobbies.
  final String? timeWindow;
  final String? preferredArenaId;
  // V2 ranked preferences. Used by the Discover wizard to pre-fill on edit.
  final List<String> windowsRanked;
  final List<String> windowsMatched;
  final List<String> groundsRanked;

  factory MmTeamLobbySummary.fromJson(Map<String, dynamic> j) =>
      MmTeamLobbySummary(
        lobbyId: j['lobbyId'] as String,
        teamId: j['teamId'] as String,
        teamName: j['teamName'] as String?,
        status: (j['status'] as String?) ?? 'searching',
        date: (j['date'] as String?) ?? '',
        format: (j['format'] as String?) ?? 'T20',
        ballType: j['ballType'] as String?,
        timeWindow: j['timeWindow'] as String?,
        preferredArenaId: j['preferredArenaId'] as String?,
        windowsRanked: ((j['windowsRanked'] as List?) ?? const [])
            .whereType<String>()
            .toList(),
        windowsMatched: ((j['windowsMatched'] as List?) ?? const [])
            .whereType<String>()
            .toList(),
        groundsRanked: ((j['groundsRanked'] as List?) ?? const [])
            .whereType<String>()
            .toList(),
      );
}

/// Response body for GET /matchmaking/lobbies/active-all.
class MmActiveLobbiesResponse {
  const MmActiveLobbiesResponse({
    required this.teams,
    required this.lobbies,
  });

  /// Compact info for every team the user belongs to (whether searching or not).
  final List<({String id, String name, String? logoUrl})> teams;

  /// Active lobbies, deduped to one per team.
  final List<MmTeamLobbySummary> lobbies;

  factory MmActiveLobbiesResponse.fromJson(Map<String, dynamic> j) =>
      MmActiveLobbiesResponse(
        teams: ((j['teams'] as List?) ?? [])
            .whereType<Map<String, dynamic>>()
            .map((t) => (
                  id: t['id'] as String,
                  name: (t['name'] as String?) ?? 'Team',
                  logoUrl: t['logoUrl'] as String?,
                ))
            .toList(),
        lobbies: ((j['lobbies'] as List?) ?? [])
            .whereType<Map<String, dynamic>>()
            .map(MmTeamLobbySummary.fromJson)
            .toList(),
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

// ─── Plan B / V2 — first-to-pay models ──────────────────────────────────────

/// Returned by `expressInterest`. Server creates an Interest row and the
/// player can then call `lockAndPay` on its id.
class MmInterest {
  const MmInterest({
    required this.interestId,
    required this.lobbyId,
    required this.teamId,
    required this.status,
    required this.expressedAt,
  });
  final String interestId;
  final String lobbyId;
  final String teamId;
  final String status; // interested | locked | won | lost | lock_expired
  final DateTime expressedAt;

  factory MmInterest.fromJson(Map<String, dynamic> j) => MmInterest(
        interestId: (j['interestId'] as String?) ?? '',
        lobbyId: (j['lobbyId'] as String?) ?? '',
        teamId: (j['teamId'] as String?) ?? '',
        status: (j['status'] as String?) ?? 'interested',
        expressedAt: DateTime.tryParse(
                (j['expressedAt'] as String?) ?? '') ??
            DateTime.now(),
      );
}

/// Returned by `lockAndPay`. The interest now holds the lobby's 120s payment
/// lock; player must complete Razorpay flow before `lockExpiresAt`.
class MmInterestLock {
  const MmInterestLock({
    required this.interestId,
    required this.razorpayOrderId,
    required this.razorpayKey,
    required this.amountPaise,
    required this.currency,
    required this.groundFeePaise,
    required this.lockExpiresAt,
    required this.lockSeconds,
  });
  final String interestId;
  final String razorpayOrderId;
  final String razorpayKey;
  final int amountPaise;
  final String currency;
  final int groundFeePaise;
  final DateTime lockExpiresAt;
  final int lockSeconds;

  factory MmInterestLock.fromJson(Map<String, dynamic> j) => MmInterestLock(
        interestId: (j['interestId'] as String?) ?? '',
        razorpayOrderId: (j['razorpayOrderId'] as String?) ?? '',
        razorpayKey: (j['razorpayKey'] as String?) ?? '',
        amountPaise: (j['amountPaise'] as num?)?.toInt() ?? 0,
        currency: (j['currency'] as String?) ?? 'INR',
        groundFeePaise: (j['groundFeePaise'] as num?)?.toInt() ?? 0,
        lockExpiresAt: DateTime.tryParse(
                (j['lockExpiresAt'] as String?) ?? '') ??
            DateTime.now().add(const Duration(seconds: 120)),
        lockSeconds: (j['lockSeconds'] as num?)?.toInt() ?? 120,
      );
}

/// Returned by `verifyInterestPayment` after a successful Razorpay capture.
/// `matchId` is set when this team won the slot; null if SLOT_TAKEN raced.
class MmInterestVerifyResult {
  const MmInterestVerifyResult({
    required this.interestId,
    required this.lobbyId,
    required this.status,
    this.matchId,
  });
  final String interestId;
  final String lobbyId;
  final String status; // won | lost
  final String? matchId;

  factory MmInterestVerifyResult.fromJson(Map<String, dynamic> j) =>
      MmInterestVerifyResult(
        interestId: (j['interestId'] as String?) ?? '',
        lobbyId: (j['lobbyId'] as String?) ?? '',
        status: (j['status'] as String?) ?? 'won',
        matchId: j['matchId'] as String?,
      );
}
