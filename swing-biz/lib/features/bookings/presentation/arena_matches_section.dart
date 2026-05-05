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
    this.groundFeePaise = 0,
    this.remainingFeePaise = 0,
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
  final int groundFeePaise;
  final int remainingFeePaise;

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
        groundFeePaise: (j['groundFeePaise'] as num?)?.toInt() ?? 0,
        remainingFeePaise: (j['remainingFeePaise'] as num?)?.toInt() ?? 0,
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

class _MatchRow extends StatelessWidget {
  const _MatchRow({required this.match, required this.arenaId});
  final ArenaMatch match;
  final String arenaId;

  @override
  Widget build(BuildContext context) {
    final isPending = !match.isConfirmed;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _MatchDetailSheet(match: match, arenaId: arenaId),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: date column
            SizedBox(
              width: 44,
              child: Column(
                children: [
                  Text(
                    match.dateLabel,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    match.displaySlot,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Center: teams + meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'VS',
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
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
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      if (match.format.isNotEmpty) ...[
                        Text(
                          match.format,
                          style: const TextStyle(
                              color: Color(0xFF6B7280), fontSize: 11),
                        ),
                        const SizedBox(width: 6),
                        const Text('·',
                            style: TextStyle(
                                color: Color(0xFFD1D5DB), fontSize: 11)),
                        const SizedBox(width: 6),
                      ],
                      if (match.groundName.isNotEmpty)
                        Flexible(
                          child: Text(
                            match.groundName,
                            style: const TextStyle(
                                color: Color(0xFF6B7280), fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _PayDot(paid: match.teamAConfirmed, label: match.teamAName),
                      const SizedBox(width: 8),
                      _PayDot(paid: match.teamBConfirmed, label: match.teamBName),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Right: status + chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: isPending
                        ? const Color(0xFFFEF3C7)
                        : const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    isPending ? 'Pending' : 'Confirmed',
                    style: TextStyle(
                      color: isPending
                          ? const Color(0xFFD97706)
                          : const Color(0xFF059669),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Icon(Icons.chevron_right_rounded,
                    size: 16, color: Color(0xFFD1D5DB)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PayDot extends StatelessWidget {
  const _PayDot({required this.paid, required this.label});
  final bool paid;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: paid ? const Color(0xFF059669) : const Color(0xFFD1D5DB),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 90),
          child: Text(
            label,
            style: TextStyle(
              color: paid ? const Color(0xFF374151) : const Color(0xFF9CA3AF),
              fontSize: 10,
              fontWeight: paid ? FontWeight.w600 : FontWeight.w400,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─── Match Detail Sheet ───────────────────────────────────────────────────────

class _MatchDetailSheet extends ConsumerStatefulWidget {
  const _MatchDetailSheet({required this.match, required this.arenaId});
  final ArenaMatch match;
  final String arenaId;

  @override
  ConsumerState<_MatchDetailSheet> createState() => _MatchDetailSheetState();
}

class _MatchDetailSheetState extends ConsumerState<_MatchDetailSheet> {
  bool _markingA = false;
  bool _markingB = false;
  bool _cancelling = false;
  String? _error;

  Future<void> _markPaid(String lobbyId, String teamName, bool isA) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mark as Paid'),
        content: Text('Confirm that $teamName has paid offline (cash / UPI)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm',
                style: TextStyle(color: Color(0xFF059669))),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      if (isA) _markingA = true; else _markingB = true;
      _error = null;
    });
    try {
      final dio = ref.read(hostDioProvider);
      debugPrint('[markPaid] POST /matchmaking/matches/${widget.match.matchId}/mark-paid lobbyId=$lobbyId');
      final resp = await dio.post(
        '/matchmaking/matches/${widget.match.matchId}/mark-paid',
        data: {'lobbyId': lobbyId},
      );
      debugPrint('[markPaid] response: ${resp.statusCode} ${resp.data}');
      if (mounted) {
        ref.invalidate(arenaMatchesProvider(widget.arenaId));
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('[markPaid] ERROR: $e');
      String msg = e.toString();
      final s = e.toString();
      final m = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(s);
      if (m != null) msg = m.group(1)!;
      if (mounted) setState(() => _error = msg);
    } finally {
      if (mounted) setState(() { _markingA = false; _markingB = false; });
    }
  }

  Future<void> _cancelMatch() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Match'),
        content: Text(
          'Cancel the match between ${widget.match.teamAName} and ${widget.match.teamBName}? '
          'Both teams will be notified.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel Match',
                style: TextStyle(color: Color(0xFFDC2626))),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() { _cancelling = true; _error = null; });
    try {
      final dio = ref.read(hostDioProvider);
      await dio.delete('/matchmaking/matches/${widget.match.matchId}');
      if (mounted) {
        ref.invalidate(arenaMatchesProvider(widget.arenaId));
        Navigator.pop(context);
      }
    } catch (e) {
      String msg = e.toString();
      final m = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(msg);
      if (m != null) msg = m.group(1)!;
      if (mounted) setState(() => _error = msg);
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final match = widget.match;
    final remainingRupees = match.remainingFeePaise ~/ 100;
    final hasRemaining = remainingRupees > 0;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
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
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  '${match.teamAName}  vs  ${match.teamBName}',
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: match.isConfirmed
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  match.isConfirmed ? 'Confirmed' : 'Pending Payment',
                  style: TextStyle(
                    color: match.isConfirmed
                        ? const Color(0xFF059669)
                        : const Color(0xFFD97706),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            [
              match.format,
              match.dateLabel,
              match.displaySlot,
              if (match.groundName.isNotEmpty) match.groundName,
            ].join('  ·  '),
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
          ),
          const SizedBox(height: 20),

          // Remaining balance callout (confirmed matches)
          if (match.isConfirmed && hasRemaining) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      size: 18, color: Color(0xFFD97706)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Remaining Ground Fee',
                          style: TextStyle(
                            color: Color(0xFF92400E),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '₹$remainingRupees per team to collect at check-in',
                          style: const TextStyle(
                            color: Color(0xFFB45309),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Team payment rows
          _TeamPayRow(
            teamName: match.teamAName,
            confirmed: match.teamAConfirmed,
            loading: _markingA,
            showButton: !match.teamAConfirmed && !match.isConfirmed,
            onMarkPaid: () => _markPaid(match.teamALobbyId, match.teamAName, true),
          ),
          const SizedBox(height: 8),
          _TeamPayRow(
            teamName: match.teamBName,
            confirmed: match.teamBConfirmed,
            loading: _markingB,
            showButton: !match.teamBConfirmed && !match.isConfirmed,
            onMarkPaid: () => _markPaid(match.teamBLobbyId, match.teamBName, false),
          ),

          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!,
                style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13)),
          ],

          const SizedBox(height: 20),
          GestureDetector(
            onTap: _cancelling ? null : _cancelMatch,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: _cancelling
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 1.5, color: Color(0xFFDC2626)),
                    )
                  : const Text(
                      'Cancel Match',
                      style: TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Team Pay Row ─────────────────────────────────────────────────────────────

class _TeamPayRow extends StatelessWidget {
  const _TeamPayRow({
    required this.teamName,
    required this.confirmed,
    required this.loading,
    required this.showButton,
    required this.onMarkPaid,
  });
  final String teamName;
  final bool confirmed;
  final bool loading;
  final bool showButton;
  final VoidCallback onMarkPaid;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            confirmed
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 18,
            color: confirmed
                ? const Color(0xFF059669)
                : const Color(0xFF9CA3AF),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              teamName,
              style: TextStyle(
                color: confirmed
                    ? const Color(0xFF111827)
                    : const Color(0xFF6B7280),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (confirmed)
            const Text(
              'Confirmed',
              style: TextStyle(
                color: Color(0xFF059669),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            )
          else if (showButton)
            GestureDetector(
              onTap: loading ? null : onMarkPaid,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: loading
                      ? const Color(0xFF059669).withValues(alpha: 0.6)
                      : const Color(0xFF059669),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: loading
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                            strokeWidth: 1.5, color: Colors.white),
                      )
                    : const Text(
                        'Mark Paid',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            )
          else
            const Text(
              'Awaiting',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
