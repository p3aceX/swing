import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// ─── Model ───────────────────────────────────────────────────────────────────

class ArenaLobby {
  const ArenaLobby({
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
  final String slotTime;
  final String date;
  final int daysFromNow;

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
    return ArenaLobby(
      lobbyId: (j['lobbyId'] as String?) ?? '',
      teamName: (j['teamName'] as String?) ?? 'Unknown Team',
      ageGroup: (j['ageGroup'] as String?) ?? 'Open',
      format: (j['format'] as String?) ?? 'T20',
      groundName: (j['groundName'] as String?) ?? '',
      slotTime: (j['slotTime'] as String?) ?? '',
      date: date,
      daysFromNow: daysFromNow,
    );
  }
}

// ─── Provider ────────────────────────────────────────────────────────────────

final arenaLobbiesProvider =
    FutureProvider.family.autoDispose<List<ArenaLobby>, String>(
  (ref, arenaId) async {
    final dio = ref.watch(hostDioProvider);
    debugPrint('[arenaLobbiesProvider] GET /matchmaking/lobbies?arenaId=$arenaId');
    final resp = await dio.get(
      '/matchmaking/lobbies',
      queryParameters: {'arenaId': arenaId},
    );
    final body = resp.data;
    debugPrint('[arenaLobbiesProvider] raw response: $body');
    final data = (body is Map) ? (body['data'] ?? body) : body;
    final list = (data is Map) ? (data['lobbies'] as List?) : (data as List?);
    debugPrint('[arenaLobbiesProvider] parsed list: $list');
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
                    'TEAMS LOOKING TO PLAY',
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
            SizedBox(
              height: 124,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                itemCount: lobbies.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) => _LobbyCard(
                  lobby: lobbies[i],
                  arenaId: arenaId,
                  arenaName: arenaName,
                  onAccepted: () => ref.invalidate(arenaLobbiesProvider(arenaId)),
                ),
              ),
            ),
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
    required this.onAccepted,
  });

  final ArenaLobby lobby;
  final String arenaId;
  final String arenaName;
  final VoidCallback onAccepted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
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
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  lobby.format,
                  style: const TextStyle(
                    color: Color(0xFF374151),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${lobby.dateLabel}  ·  ${lobby.displaySlot}',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 11,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _showAcceptSheet(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF059669),
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Accept',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
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
        onAccepted: onAccepted,
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

  Future<void> _confirm() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dio = ref.read(hostDioProvider);
      await dio.post(
        '/matchmaking/lobbies/${widget.lobby.lobbyId}/accept',
        data: {'arenaId': widget.arenaId},
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onAccepted();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Split booking created — searching for rival team'),
            backgroundColor: Color(0xFF059669),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lobby = widget.lobby;
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
          const Text(
            'Accept Team',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'This will create a split booking. The system will find a rival team — or the team can find one themselves.',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
          ),
          const SizedBox(height: 20),
          // Details block
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                _DetailRow(label: 'Team', value: lobby.teamName),
                const SizedBox(height: 8),
                _DetailRow(label: 'Format', value: lobby.format),
                const SizedBox(height: 8),
                _DetailRow(
                    label: 'Date',
                    value: '${lobby.dateLabel} · ${lobby.displaySlot}'),
                if (lobby.groundName.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _DetailRow(label: 'Ground', value: lobby.groundName),
                ],
                const SizedBox(height: 8),
                _DetailRow(label: 'Arena', value: widget.arenaName),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!,
                style:
                    const TextStyle(color: Color(0xFFDC2626), fontSize: 13)),
          ],
          const SizedBox(height: 20),
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
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Confirm Split Booking',
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
