import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// ─── Helpers ─────────────────────────────────────────────────────────────────

String _ballTypeLabel(String bt) => switch (bt) {
      'LEATHER' => 'Leather',
      'TENNIS' => 'Tennis',
      'TAPE' => 'Tape Ball',
      'RUBBER' => 'Rubber',
      _ => bt,
    };

// ─── Model ───────────────────────────────────────────────────────────────────

class ArenaLobbyPick {
  const ArenaLobbyPick({
    required this.slotTime,
    required this.unitId,
    this.groundName,
    this.preferenceOrder = 1,
  });
  final String slotTime;
  final String unitId;
  final String? groundName;
  final int preferenceOrder;

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

  factory ArenaLobbyPick.fromJson(Map<String, dynamic> j) => ArenaLobbyPick(
        slotTime: (j['slotTime'] as String?) ?? '',
        unitId: (j['unitId'] as String?) ?? '',
        groundName: j['groundName'] as String?,
        preferenceOrder: (j['preferenceOrder'] as num?)?.toInt() ?? 1,
      );
}

class ArenaLobby {
  const ArenaLobby({
    required this.lobbyId,
    required this.teamName,
    required this.ageGroup,
    required this.format,
    this.ballType,
    required this.groundName,
    required this.slotTime,
    required this.date,
    required this.daysFromNow,
    this.picks = const [],
    this.accepted = false,
    this.confirmedSlot,
  });

  final String lobbyId;
  final String teamName;
  final String ageGroup;
  final String format;
  final String? ballType;
  final String groundName;
  final String slotTime;
  final String date;
  final int daysFromNow;
  final List<ArenaLobbyPick> picks;
  final bool accepted;
  final String? confirmedSlot;

  String get dateLabel {
    if (daysFromNow == 0) return 'Today';
    if (daysFromNow == 1) return 'Tomorrow';
    try {
      final d = DateTime.parse(date);
      return DateFormat('MMM d').format(d);
    } catch (_) {
      return date;
    }
  }

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

  factory ArenaLobby.fromJson(Map<String, dynamic> j) {
    final date = (j['date'] as String?) ?? '';
    final today = DateTime.now();
    int daysFromNow = 0;
    try {
      final d = DateTime.parse(date);
      daysFromNow =
          d.difference(DateTime(today.year, today.month, today.day)).inDays;
    } catch (_) {}
    final picks = ((j['picks'] as List?) ?? [])
        .whereType<Map<String, dynamic>>()
        .map(ArenaLobbyPick.fromJson)
        .toList();
    return ArenaLobby(
      lobbyId: (j['lobbyId'] as String?) ?? '',
      teamName: (j['teamName'] as String?) ?? 'Unknown Team',
      ageGroup: (j['ageGroup'] as String?) ?? 'Open',
      format: (j['format'] as String?) ?? 'T20',
      ballType: j['ballType'] as String?,
      groundName: (j['groundName'] as String?) ?? '',
      slotTime: (j['slotTime'] as String?) ?? '',
      date: date,
      daysFromNow: daysFromNow,
      picks: picks,
      accepted: (j['accepted'] as bool?) ?? false,
      confirmedSlot: j['confirmedSlot'] as String?,
    );
  }
}

// ─── Provider ────────────────────────────────────────────────────────────────

final arenaLobbiesProvider =
    FutureProvider.family.autoDispose<List<ArenaLobby>, String>(
  (ref, arenaId) async {
    final dio = ref.watch(hostDioProvider);
    final resp = await dio.get(
      '/matchmaking/lobbies',
      queryParameters: {'arenaId': arenaId},
    );
    final body = resp.data;
    final data = (body is Map) ? (body['data'] ?? body) : body;
    final list = (data is Map) ? (data['lobbies'] as List?) : (data as List?);
    return (list ?? [])
        .whereType<Map<String, dynamic>>()
        .map(ArenaLobby.fromJson)
        .toList();
  },
);

// ─── Section Widget ───────────────────────────────────────────────────────────

class ArenaLobbiesSection extends ConsumerWidget {
  const ArenaLobbiesSection({
    super.key,
    required this.arenaId,
    required this.arenaName,
  });

  final String arenaId;
  final String arenaName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(arenaLobbiesProvider(arenaId));

    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (lobbies) {
        if (lobbies.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'MATCHUP REQUESTS',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${lobbies.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...lobbies.map((lobby) => _LobbyCard(
                  lobby: lobby,
                  arenaId: arenaId,
                  arenaName: arenaName,
                  onRefresh: () => ref.invalidate(arenaLobbiesProvider(arenaId)),
                )),
            const SizedBox(height: 4),
            Divider(height: 1, color: Colors.grey.shade200),
          ],
        );
      },
    );
  }
}

// ─── Lobby Card ───────────────────────────────────────────────────────────────

class _LobbyCard extends StatelessWidget {
  const _LobbyCard({
    required this.lobby,
    required this.arenaId,
    required this.arenaName,
    required this.onRefresh,
  });

  final ArenaLobby lobby;
  final String arenaId;
  final String arenaName;
  final VoidCallback onRefresh;

  String _fmtSlot(String t) {
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

  @override
  Widget build(BuildContext context) {
    return lobby.accepted ? _buildAccepted(context) : _buildPending(context);
  }

  // ── State A: slot confirmed, needs rival ───────────────────────────────────
  Widget _buildAccepted(BuildContext context) {
    final slot = lobby.confirmedSlot != null
        ? _fmtSlot(lobby.confirmedSlot!)
        : lobby.displaySlot;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF86EFAC)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'SLOT CONFIRMED',
                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    lobby.format,
                    style: const TextStyle(color: Color(0xFF059669), fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              lobby.teamName,
              style: const TextStyle(color: Color(0xFF111827), fontSize: 13, fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '${lobby.dateLabel}  ·  $slot',
              style: const TextStyle(color: Color(0xFF059669), fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _showAssignSheet(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Assign Rival', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 13),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── State B: fresh request, needs acceptance ───────────────────────────────
  Widget _buildPending(BuildContext context) {
    final slots = lobby.picks.isNotEmpty
        ? lobby.picks
        : [ArenaLobbyPick(slotTime: lobby.slotTime, unitId: '', groundName: lobby.groundName)];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    lobby.teamName,
                    style: const TextStyle(color: Color(0xFF111827), fontSize: 13, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(4)),
                  child: Text(lobby.format, style: const TextStyle(color: Color(0xFF374151), fontSize: 10, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Text(lobby.dateLabel, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
                if (lobby.ballType != null) ...[
                  const Text('  ·  ', style: TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(4)),
                    child: Text(_ballTypeLabel(lobby.ballType!), style: const TextStyle(color: Color(0xFF374151), fontSize: 9, fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            ...slots.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: [
                    Container(width: 5, height: 5, margin: const EdgeInsets.only(right: 6, top: 1),
                        decoration: const BoxDecoration(color: Color(0xFF059669), shape: BoxShape.circle)),
                    Text(p.displaySlot, style: const TextStyle(color: Color(0xFF111827), fontSize: 12, fontWeight: FontWeight.w600)),
                  ]),
                )),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showAcceptSheet(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFF059669), borderRadius: BorderRadius.circular(6)),
                alignment: Alignment.center,
                child: const Text('Accept', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAcceptSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AcceptLobbySheet(
        lobby: lobby,
        arenaId: arenaId,
        arenaName: arenaName,
        onAccepted: onRefresh,
      ),
    );
  }

  void _showAssignSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AssignTeamSheet(
        lobby: lobby,
        onAssigned: onRefresh,
      ),
    );
  }
}

// ─── Accept Sheet ─────────────────────────────────────────────────────────────

class AcceptLobbySheet extends ConsumerStatefulWidget {
  const AcceptLobbySheet({
    super.key,
    required this.lobby,
    required this.arenaId,
    required this.arenaName,
    required this.onAccepted,
  });

  final ArenaLobby lobby;
  final String arenaId;
  final String arenaName;
  final VoidCallback onAccepted;

  @override
  ConsumerState<AcceptLobbySheet> createState() => _AcceptLobbySheetState();
}

class _AcceptLobbySheetState extends ConsumerState<AcceptLobbySheet> {
  bool _loading = false;
  String? _error;
  late String _selectedSlot;

  @override
  void initState() {
    super.initState();
    // Default to first pick (or top-level slotTime if no picks)
    _selectedSlot = widget.lobby.picks.isNotEmpty
        ? widget.lobby.picks.first.slotTime
        : widget.lobby.slotTime;
  }

  Future<void> _confirm() async {
    setState(() { _loading = true; _error = null; });
    try {
      final dio = ref.read(hostDioProvider);
      await dio.post(
        '/matchmaking/lobbies/${widget.lobby.lobbyId}/accept',
        data: {'arenaId': widget.arenaId, 'slotTime': _selectedSlot},
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onAccepted();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Slot locked — now searching for a rival team'),
            backgroundColor: Color(0xFF059669),
          ),
        );
      }
    } catch (e) {
      setState(() { _error = 'Something went wrong. Please try again.'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lobby = widget.lobby;
    final slots = lobby.picks.isNotEmpty
        ? lobby.picks
        : [ArenaLobbyPick(slotTime: lobby.slotTime, unitId: '', groundName: lobby.groundName)];
    final multiSlot = slots.length > 1;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            lobby.teamName,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Team willing to play',
            style: TextStyle(color: Color(0xFF059669), fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            multiSlot
                ? 'They requested ${slots.length} time slots — pick one to lock in.'
                : 'Confirm the slot to start searching for a rival team.',
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
          ),
          const SizedBox(height: 20),
          // Summary rows
          _DetailRow(label: 'Team', value: lobby.teamName),
          const SizedBox(height: 8),
          _DetailRow(label: 'Format', value: lobby.format),
          const SizedBox(height: 8),
          _DetailRow(label: 'Date', value: lobby.dateLabel),
          if (lobby.groundName.isNotEmpty) ...[
            const SizedBox(height: 8),
            _DetailRow(label: 'Ground', value: lobby.groundName),
          ],
          const SizedBox(height: 20),
          // Slot selector
          const Text(
            'PICK A SLOT TO OFFER',
            style: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          ...slots.map((p) {
            final selected = _selectedSlot == p.slotTime;
            return GestureDetector(
              onTap: () => setState(() => _selectedSlot = p.slotTime),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF059669).withValues(alpha: 0.07)
                      : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF059669)
                        : const Color(0xFFE5E7EB),
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF059669)
                              : const Color(0xFFD1D5DB),
                          width: 1.5,
                        ),
                      ),
                      child: selected
                          ? Center(
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF059669),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      p.displaySlot,
                      style: TextStyle(
                        color: selected
                            ? const Color(0xFF059669)
                            : const Color(0xFF111827),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (p.preferenceOrder == 1) ...[
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '1st choice',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13)),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _loading ? null : _confirm,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _loading
                      ? const Color(0xFF059669).withValues(alpha: 0.6)
                      : const Color(0xFF059669),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Confirm & Search for Rival',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Assign Team Sheet ────────────────────────────────────────────────────────

class AssignTeamSheet extends ConsumerStatefulWidget {
  const AssignTeamSheet({
    super.key,
    required this.lobby,
    required this.onAssigned,
  });
  final ArenaLobby lobby;
  final VoidCallback onAssigned;

  @override
  ConsumerState<AssignTeamSheet> createState() => _AssignTeamSheetState();
}

class _AssignTeamSheetState extends ConsumerState<AssignTeamSheet> {
  final _searchCtrl = TextEditingController();
  List<_TeamResult> _results = [];
  _TeamResult? _selected;
  bool _searching = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search(String q) async {
    if (q.trim().length < 2) {
      setState(() { _results = []; });
      return;
    }
    setState(() { _searching = true; });
    try {
      final dio = ref.read(hostDioProvider);
      final resp = await dio.get('/player/teams/search', queryParameters: {'q': q.trim(), 'limit': '20'});
      final body = resp.data;
      final data = (body is Map) ? (body['data'] ?? body) : body;
      final list = (data is Map) ? (data['teams'] as List?) : null;
      if (mounted) {
        setState(() {
          _results = (list ?? [])
              .whereType<Map<String, dynamic>>()
              .map(_TeamResult.fromJson)
              .toList();
          _searching = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _searching = false; });
    }
  }

  Future<void> _confirm() async {
    if (_selected == null) return;
    setState(() { _loading = true; _error = null; });
    try {
      final dio = ref.read(hostDioProvider);
      await dio.post(
        '/matchmaking/lobbies/${widget.lobby.lobbyId}/assign',
        data: {'teamId': _selected!.id, 'teamName': _selected!.name},
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onAssigned();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selected!.name} assigned — match is live!'),
            backgroundColor: const Color(0xFF059669),
          ),
        );
      }
    } catch (_) {
      setState(() { _error = 'Could not assign team. Try again.'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Assign Rival Team',
            style: TextStyle(color: Color(0xFF111827), fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Search and assign an opponent for ${widget.lobby.teamName}.',
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
          ),
          const SizedBox(height: 16),
          // Search field
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.search, color: Color(0xFF9CA3AF), size: 18),
                ),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Search team name...',
                      hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    onChanged: _search,
                  ),
                ),
                if (_searching)
                  const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF6B7280))),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Results
          if (_results.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _results.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                itemBuilder: (_, i) {
                  final t = _results[i];
                  final sel = _selected?.id == t.id;
                  return GestureDetector(
                    onTap: () => setState(() => _selected = sel ? null : t),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t.name,
                                    style: TextStyle(
                                      color: sel ? const Color(0xFF059669) : const Color(0xFF111827),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    )),
                                if (t.city != null)
                                  Text(t.city!, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
                              ],
                            ),
                          ),
                          if (t.memberCount > 0)
                            Text('${t.memberCount} players',
                                style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
                          const SizedBox(width: 8),
                          Container(
                            width: 18, height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: sel ? const Color(0xFF059669) : const Color(0xFFD1D5DB),
                                width: 1.5,
                              ),
                            ),
                            child: sel
                                ? Center(
                                    child: Container(
                                      width: 9, height: 9,
                                      decoration: const BoxDecoration(color: Color(0xFF059669), shape: BoxShape.circle),
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13)),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: (_selected == null || _loading) ? null : _confirm,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _selected == null
                      ? const Color(0xFF059669).withValues(alpha: 0.35)
                      : _loading
                          ? const Color(0xFF059669).withValues(alpha: 0.6)
                          : const Color(0xFF059669),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: _loading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(
                        _selected != null ? 'Assign ${_selected!.name}' : 'Select a team first',
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamResult {
  const _TeamResult({required this.id, required this.name, this.city, this.memberCount = 0});
  final String id;
  final String name;
  final String? city;
  final int memberCount;

  factory _TeamResult.fromJson(Map<String, dynamic> j) => _TeamResult(
        id: j['id'] as String,
        name: (j['name'] as String?) ?? '',
        city: j['city'] as String?,
        memberCount: (j['memberCount'] as num?)?.toInt() ?? 0,
      );
}

// ─── Detail Row ───────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
