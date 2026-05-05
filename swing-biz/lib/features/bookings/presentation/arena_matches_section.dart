import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// ─── Model ───────────────────────────────────────────────────────────────────

class ArenaMatch {
  const ArenaMatch({
    required this.matchId,
    required this.teamAName,
    required this.teamBName,
    required this.teamALobbyId,
    required this.teamBLobbyId,
    required this.groundName,
    required this.slotTime,
    required this.date,
    required this.daysFromNow,
    required this.format,
    required this.status,
    required this.teamAConfirmed,
    required this.teamBConfirmed,
    required this.confirmationFeePaise,
  });

  final String matchId;
  final String teamAName;
  final String teamBName;
  final String teamALobbyId;
  final String teamBLobbyId;
  final String groundName;
  final String slotTime;
  final String date;
  final int daysFromNow;
  final String format;
  final String status;
  final bool teamAConfirmed;
  final bool teamBConfirmed;
  final int confirmationFeePaise;

  bool get isConfirmed => status == 'confirmed';
  bool get bothPaid => teamAConfirmed && teamBConfirmed;

  String get dateLabel {
    if (daysFromNow == 0) return 'Today';
    if (daysFromNow == 1) return 'Tomorrow';
    try {
      return DateFormat('MMM d').format(DateTime.parse(date));
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

  factory ArenaMatch.fromJson(Map<String, dynamic> j) => ArenaMatch(
        matchId: (j['matchId'] as String?) ?? '',
        teamAName: (j['teamAName'] as String?) ?? 'Team A',
        teamBName: (j['teamBName'] as String?) ?? 'Team B',
        teamALobbyId: (j['teamALobbyId'] as String?) ?? '',
        teamBLobbyId: (j['teamBLobbyId'] as String?) ?? '',
        groundName: (j['groundName'] as String?) ?? '',
        slotTime: (j['slotTime'] as String?) ?? '',
        date: (j['date'] as String?) ?? '',
        daysFromNow: (j['daysFromNow'] as num?)?.toInt() ?? 0,
        format: (j['format'] as String?) ?? '',
        status: (j['status'] as String?) ?? 'pending_payment',
        teamAConfirmed: (j['teamAConfirmed'] as bool?) ?? false,
        teamBConfirmed: (j['teamBConfirmed'] as bool?) ?? false,
        confirmationFeePaise: (j['confirmationFeePaise'] as num?)?.toInt() ?? 50000,
      );
}

// ─── Provider ────────────────────────────────────────────────────────────────

final arenaMatchesProvider =
    FutureProvider.family.autoDispose<List<ArenaMatch>, String>(
  (ref, arenaId) async {
    final dio = ref.watch(hostDioProvider);
    final resp = await dio.get(
      '/matchmaking/matches',
      queryParameters: {'arenaId': arenaId},
    );
    final body = resp.data;
    final data = (body is Map) ? (body['data'] ?? body) : body;
    final list = (data is Map) ? (data['matches'] as List?) : null;
    return (list ?? [])
        .whereType<Map<String, dynamic>>()
        .map(ArenaMatch.fromJson)
        .toList();
  },
);

// ─── Section Widget ───────────────────────────────────────────────────────────

class ArenaMatchesSection extends ConsumerWidget {
  const ArenaMatchesSection({super.key, required this.arenaId});
  final String arenaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(arenaMatchesProvider(arenaId));

    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (matches) {
        if (matches.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'CONFIRMED MATCHES',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${matches.length}',
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
            ...matches.map((m) => _MatchRow(match: m, arenaId: arenaId)),
            const SizedBox(height: 4),
            Divider(height: 1, color: Colors.grey.shade200),
          ],
        );
      },
    );
  }
}

// ─── Match Row ────────────────────────────────────────────────────────────────

class _MatchRow extends ConsumerStatefulWidget {
  const _MatchRow({required this.match, required this.arenaId});
  final ArenaMatch match;
  final String arenaId;

  @override
  ConsumerState<_MatchRow> createState() => _MatchRowState();
}

class _MatchRowState extends ConsumerState<_MatchRow> {
  bool _markingA = false;
  bool _markingB = false;

  Future<void> _markPaid(String lobbyId, String teamName, bool isA) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mark as Paid'),
        content: Text('Confirm that $teamName has paid offline (cash/UPI)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm', style: TextStyle(color: Color(0xFF059669))),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => isA ? _markingA = true : _markingB = true);
    try {
      final dio = ref.read(hostDioProvider);
      await dio.post(
        '/matchmaking/matches/${widget.match.matchId}/mark-paid',
        data: {'lobbyId': lobbyId},
      );
      if (mounted) ref.invalidate(arenaMatchesProvider(widget.arenaId));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not mark as paid. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => isA ? _markingA = false : _markingB = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final match = widget.match;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Teams + status badge
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        match.teamAName,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('vs',
                          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                    ),
                    Flexible(
                      child: Text(
                        match.teamBName,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: match.isConfirmed
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  match.isConfirmed ? 'Confirmed' : 'Pending',
                  style: TextStyle(
                    color: match.isConfirmed
                        ? const Color(0xFF059669)
                        : const Color(0xFFD97706),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            [
              match.format,
              match.dateLabel,
              match.displaySlot,
              if (match.groundName.isNotEmpty) match.groundName,
            ].join('  ·  '),
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11),
          ),
          const SizedBox(height: 10),
          // Payment status + mark-paid buttons
          Row(
            children: [
              _PayBadge(teamName: match.teamAName, confirmed: match.teamAConfirmed),
              if (!match.teamAConfirmed && !match.isConfirmed) ...[
                const SizedBox(width: 6),
                _MarkPaidButton(
                  loading: _markingA,
                  onTap: () => _markPaid(match.teamALobbyId, match.teamAName, true),
                ),
              ],
              const SizedBox(width: 10),
              _PayBadge(teamName: match.teamBName, confirmed: match.teamBConfirmed),
              if (!match.teamBConfirmed && !match.isConfirmed) ...[
                const SizedBox(width: 6),
                _MarkPaidButton(
                  loading: _markingB,
                  onTap: () => _markPaid(match.teamBLobbyId, match.teamBName, false),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Mark Paid button ─────────────────────────────────────────────────────────

class _MarkPaidButton extends StatelessWidget {
  const _MarkPaidButton({required this.loading, required this.onTap});
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF059669),
          borderRadius: BorderRadius.circular(6),
        ),
        child: loading
            ? const SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white),
              )
            : const Text(
                'Mark Paid',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

// ─── Payment badge ────────────────────────────────────────────────────────────

class _PayBadge extends StatelessWidget {
  const _PayBadge({required this.teamName, required this.confirmed});
  final String teamName;
  final bool confirmed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: confirmed
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            confirmed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 12,
            color: confirmed ? const Color(0xFF059669) : const Color(0xFF9CA3AF),
          ),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 100),
            child: Text(
              teamName,
              style: TextStyle(
                color: confirmed ? const Color(0xFF059669) : const Color(0xFF6B7280),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
