import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart' show HostArenaReviewSheet;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../data/matchmaking_repository.dart';
import '../domain/matchmaking_models.dart';
import 'matchmaking_providers.dart';

typedef RefreshFn = void Function();

/// Vertical-ticket detail sheet shown when a player taps a match on the
/// My Match-Up tab. Mirrors a sports ticket: stacked teams with logos,
/// perforation, then date/venue and meta footer.
class MyMatchupDetailSheet extends ConsumerStatefulWidget {
  const MyMatchupDetailSheet({
    super.key,
    required this.matchId,
    required this.myLobbyId,
    this.myTeamId,
    required this.myTeamName,
    required this.opponentTeamName,
    this.myTeamLogoUrl,
    this.opponentTeamLogoUrl,
    required this.groundName,
    required this.arenaName,
    required this.groundArea,
    required this.dateLabel,
    required this.displaySlot,
    required this.format,
    required this.confirmationRupees,
    required this.remainingRupees,
    required this.myTeamPaid,
    required this.opponentPaid,
    required this.status,
    required this.onRefresh,
    this.bookingId,
    this.isCandidate = false,
    this.onBook,
  });

  /// Pre-booking preview: same vertical-ticket layout, but the action area
  /// surfaces a "Book this match-up" CTA instead of payment / cancel rows.
  /// Booking is delegated to [onBook] — typically the parent's existing
  /// expressInterest → lockAndPay flow.
  factory MyMatchupDetailSheet.forCandidate({
    Key? key,
    required MmOpenLobby candidate,
    required String myTeamId,
    required String myTeamName,
    String? myTeamLogoUrl,
    required RefreshFn onRefresh,
    required VoidCallback onBook,
  }) {
    final priceRupees = (candidate.pricePerTeamPaise / 100).round();
    return MyMatchupDetailSheet(
      key: key,
      matchId: '',
      myLobbyId: null,
      myTeamId: myTeamId,
      myTeamName: myTeamName,
      myTeamLogoUrl: myTeamLogoUrl,
      opponentTeamName: candidate.teamName,
      opponentTeamLogoUrl: null,
      groundName: candidate.groundName,
      arenaName: candidate.arenaName,
      groundArea: '',
      dateLabel: candidate.dateLabel,
      displaySlot: candidate.slotLabel ?? candidate.displaySlot,
      format: candidate.format,
      // Candidate preview: in test mode the advance is 0, so the user
      // pays the full share at the venue. When CONFIRMATION_FEE_PAISE
      // flips to a real value, the real (lock advance, remainder) split
      // surfaces post-lockAndPay; this preview doesn't lie.
      confirmationRupees: 0,
      remainingRupees: priceRupees,
      myTeamPaid: false,
      opponentPaid: false,
      status: 'preview',
      onRefresh: onRefresh,
      bookingId: null,
      isCandidate: true,
      onBook: onBook,
    );
  }

  final String matchId;
  final String? myLobbyId;
  final String? myTeamId;
  final String myTeamName;
  final String? myTeamLogoUrl;
  final String opponentTeamName;
  final String? opponentTeamLogoUrl;
  final String groundName;
  final String arenaName;
  final String groundArea;
  final String dateLabel;
  final String displaySlot;
  final String format;
  final int confirmationRupees;
  final int remainingRupees;
  final bool myTeamPaid;
  final bool opponentPaid;
  final String status;
  final String? bookingId;
  final RefreshFn onRefresh;
  /// True when the sheet is rendering a Discover candidate (pre-booking).
  /// In candidate mode the action area shows a Book CTA and the cancel /
  /// payment rows are suppressed (no match exists yet).
  final bool isCandidate;
  /// Fires when the user taps the candidate-mode Book CTA. Parent runs the
  /// expressInterest → lockAndPay flow and pops this sheet on success.
  final VoidCallback? onBook;

  @override
  ConsumerState<MyMatchupDetailSheet> createState() =>
      _MyMatchupDetailSheetState();
}

class _MyMatchupDetailSheetState extends ConsumerState<MyMatchupDetailSheet> {
  bool _busy = false;
  String? _error;

  bool get _isFree => widget.confirmationRupees == 0;
  bool get _isAwaitingOpponent => widget.myTeamPaid && !widget.opponentPaid;
  bool get _bothPaid => widget.myTeamPaid && widget.opponentPaid;

  String get _formatDuration =>
      (widget.format == 'ODI' || widget.format == 'Test') ? '8hr' : '4hr';

  String get _venueLine {
    final parts = <String>[];
    if (widget.groundName.isNotEmpty) parts.add(widget.groundName);
    if (widget.arenaName.isNotEmpty && !parts.contains(widget.arenaName)) {
      parts.add(widget.arenaName);
    }
    if (widget.groundArea.isNotEmpty) parts.add(widget.groundArea);
    return parts.isEmpty ? 'TBD' : parts.join(' · ');
  }

  ({String label, Color color}) _statusTone(BuildContext context) {
    if (!widget.myTeamPaid) {
      return (label: 'PAY DUE', color: context.danger);
    }
    if (_isAwaitingOpponent) {
      return (label: 'WAITING', color: context.warn);
    }
    switch (widget.status) {
      case 'started':
        return (label: 'LIVE', color: context.ctaBg);
      case 'setup':
        return (label: 'READY', color: context.ctaBg);
      default:
        return (label: 'CONFIRMED', color: context.ctaBg);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _onAction() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    if (_isFree) {
      await _confirmFree();
    } else {
      await _payAdvance();
    }
  }

  bool get _canCancel => widget.status != 'started' && !widget.isCandidate;
  bool get _isPostPayment => _bothPaid;

  // Early bird = match date is at least 2 days out from today. Visual
  // nudge only — no actual discount applied yet (would need backend
  // pricing tier support).
  bool get _isEarlyBird {
    DateTime? matchDay;
    try {
      // dateLabel is a friendly string ("Today", "Tomorrow", "May 10").
      // Parse the friendly cases first; for "May 10" we leave matchDay
      // null and skip the early-bird treatment.
      final l = widget.dateLabel.toLowerCase().trim();
      if (l == 'today') matchDay = DateTime.now();
      if (l == 'tomorrow') {
        matchDay = DateTime.now().add(const Duration(days: 1));
      }
      if (l == 'yesterday') return false;
    } catch (_) {}
    if (matchDay == null) {
      // No reliable date parse — assume eligible if not today/tomorrow.
      // (The friendly labels above already reject those.)
      return widget.dateLabel.toLowerCase().trim() != 'today' &&
          widget.dateLabel.toLowerCase().trim() != 'tomorrow';
    }
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    return matchDay.difference(start).inDays >= 2;
  }

  Future<void> _openReviewSheet() async {
    final teamId = widget.myTeamId;
    if (teamId == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.bg,
      builder: (_) => HostArenaReviewSheet(
        matchId: widget.matchId,
        teamId: teamId,
        arenaName: widget.arenaName.isNotEmpty
            ? widget.arenaName
            : (widget.groundName.isNotEmpty ? widget.groundName : 'this ground'),
        onSubmitted: (_) {
          if (!mounted) return;
          Navigator.of(context).maybePop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review submitted. Thanks!')),
          );
        },
      ),
    );
  }

  Future<void> _onCancel() async {
    if (_busy) return;
    if (widget.myLobbyId == null) {
      setState(() => _error = 'Could not resolve your lobby.');
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.bg,
        title: Text(
          'Cancel match-up?',
          style: TextStyle(
            color: ctx.fg,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        content: Text(
          _isPostPayment
              ? "Both teams have already confirmed. Cancelling now affects ${widget.opponentTeamName} and may lead to your account being banned from match-ups."
              : "This will end the match-up and notify ${widget.opponentTeamName}.",
          style: TextStyle(color: ctx.fgSub, fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Keep match-up',
                style: TextStyle(color: ctx.fgSub)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Yes, cancel',
              style: TextStyle(
                color: ctx.danger,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final dio = ApiClient.instance.dio;
      await dio.post(
        '/matchmaking/matches/${widget.matchId}/cancel-by-player',
        data: {'lobbyId': widget.myLobbyId},
      );
      widget.onRefresh();
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match-up cancelled.')),
      );
    } catch (e) {
      debugPrint('[MyMatchupDetail] cancel error: $e');
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Could not cancel. Try again.';
        });
      }
    }
  }

  Future<void> _confirmFree() async {
    if (widget.myLobbyId == null) {
      setState(() {
        _busy = false;
        _error = 'Could not resolve your lobby. Pull-to-refresh and retry.';
      });
      return;
    }
    try {
      final dio = ApiClient.instance.dio;
      await dio.post(
        '/matchmaking/matches/${widget.matchId}/confirm-free',
        data: {'lobbyId': widget.myLobbyId},
      );
      widget.onRefresh();
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match confirmed.')),
      );
    } catch (e) {
      debugPrint('[MyMatchupDetail] confirmFree error: $e');
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Could not confirm. Try again.';
        });
      }
    }
  }

  Future<void> _payAdvance() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Online payment coming soon.')),
      );
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.fgSub.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── The Ticket ─────────────────────────────────────────────
              _Ticket(
                myTeamName: widget.myTeamName,
                myTeamLogoUrl: widget.myTeamLogoUrl,
                opponentTeamName: widget.opponentTeamName,
                opponentTeamLogoUrl: widget.opponentTeamLogoUrl,
                dateLabel: widget.dateLabel,
                displaySlot: widget.displaySlot,
                venueLine: _venueLine,
                format: widget.format,
                formatDuration: _formatDuration,
                statusLabel: _statusTone(context).label,
                statusColor: _statusTone(context).color,
              ),

              const SizedBox(height: 16),

              _PricingCard(
                yourShareRupees:
                    widget.confirmationRupees + widget.remainingRupees,
                lockNowRupees: widget.confirmationRupees,
                payAtVenueRupees: widget.remainingRupees,
                format: widget.format,
                formatDuration: _formatDuration,
                isEarlyBird: _isEarlyBird,
              ),

              const SizedBox(height: 18),

              _buildActionArea(context),

              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontSize: 12.5,
                  ),
                ),
              ],

              if (widget.bookingId != null) ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go('/bookings/${widget.bookingId}');
                    },
                    icon: Icon(Icons.receipt_long_rounded,
                        size: 16, color: context.fg),
                    label: Text(
                      'View booking details',
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
              // L2 — captain rates the ground after match has started/completed.
              // Only the captain can submit (backend gates), but we show the
              // CTA to anyone post-start; the sheet's submit will 403 if the
              // caller isn't the captain.
              if (widget.myTeamId != null &&
                  (widget.status == 'started' || widget.status == 'completed')) ...[
                const SizedBox(height: 6),
                Center(
                  child: TextButton.icon(
                    onPressed: _busy ? null : _openReviewSheet,
                    icon: Icon(Icons.star_rounded,
                        size: 18, color: context.gold),
                    label: Text(
                      'Rate ground',
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
              if (_canCancel) ...[
                const SizedBox(height: 6),
                Center(
                  child: TextButton(
                    onPressed: _busy ? null : _onCancel,
                    child: Text(
                      'Cancel match-up',
                      style: TextStyle(
                        color: context.danger,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionArea(BuildContext context) {
    // Candidate preview — single Book CTA. No match exists yet, so we
    // suppress the cancel / payment-status branches that follow.
    if (widget.isCandidate) {
      return GestureDetector(
        onTap: _busy
            ? null
            : () {
                widget.onBook?.call();
                Navigator.of(context).maybePop();
              },
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.ctaBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            widget.confirmationRupees > 0
                ? 'Book — ₹${widget.confirmationRupees}'
                : 'Book this match-up',
            style: TextStyle(
              color: context.ctaFg,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
        ),
      );
    }
    if (_bothPaid && widget.status == 'started') {
      return _ActionStatus(
        title: 'Match is live',
        subtitle: 'Open the scorecard to follow ball-by-ball.',
        accent: context.ctaBg,
      );
    }
    if (_bothPaid && widget.status == 'setup') {
      return _ActionStatus(
        title: 'Match is set up',
        subtitle: 'Pick your playing XI on match day.',
        accent: context.ctaBg,
      );
    }
    if (_bothPaid && widget.status == 'confirmed') {
      return _ActionStatus(
        title: 'Venue is preparing your match',
        subtitle:
            "${widget.groundName.isNotEmpty ? widget.groundName : 'The venue'} will set the slot up. We'll notify you when it's ready.",
        accent: context.warn,
      );
    }
    if (_isAwaitingOpponent) {
      return _ActionStatus(
        title: 'Awaiting opponent',
        subtitle:
            "You're paid up. We'll notify you the moment ${widget.opponentTeamName} confirms.",
        accent: context.warn,
      );
    }

    // !myTeamPaid → CTA
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.shield_outlined, size: 16, color: context.warn),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Confirming locks this slot for both teams. ',
                      ),
                      TextSpan(
                        text:
                            'Cancelling after this can lead to your account being banned from match-ups.',
                        style: TextStyle(
                          color: context.warn,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _busy ? null : _onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.ctaBg,
              foregroundColor: context.ctaFg,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _busy
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.ctaFg,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isFree
                            ? 'Confirm match-up'
                            : 'Pay ₹${widget.confirmationRupees} advance',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

// ─── Vertical ticket ─────────────────────────────────────────────────────────

class _Ticket extends StatelessWidget {
  const _Ticket({
    required this.myTeamName,
    required this.myTeamLogoUrl,
    required this.opponentTeamName,
    required this.opponentTeamLogoUrl,
    required this.dateLabel,
    required this.displaySlot,
    required this.venueLine,
    required this.format,
    required this.formatDuration,
    required this.statusLabel,
    required this.statusColor,
  });

  final String myTeamName;
  final String? myTeamLogoUrl;
  final String opponentTeamName;
  final String? opponentTeamLogoUrl;
  final String dateLabel;
  final String displaySlot;
  final String venueLine;
  final String format;
  final String formatDuration;
  final String statusLabel;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          context.fg.withValues(alpha: 0.04),
          context.bg,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'MATCH-UP',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _TeamCol(
                    name: myTeamName,
                    logoUrl: myTeamLogoUrl,
                    side: 'YOU',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: context.fg.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'VS',
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _TeamCol(
                    name: opponentTeamName,
                    logoUrl: opponentTeamLogoUrl,
                    side: 'OPPONENT',
                  ),
                ),
              ],
            ),
          ),
          const _Perforation(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Big date + slot label stacked, NBA-card style. Stacking
                // (instead of one Row) keeps the slotLabel — which can be
                // a long string like "MORNING · 10:00 AM – 1:00 PM" —
                // from overflowing on small screens.
                Text(
                  dateLabel.toUpperCase(),
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displaySlot,
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.place_rounded,
                        size: 14, color: context.fgSub),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        venueLine,
                        style: TextStyle(
                          color: context.fgSub,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _Tag(label: format),
                    const SizedBox(width: 6),
                    _Tag(label: formatDuration),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// NBA-style vertical team block: logo on top (centered), team name, side
// label below. Used inside the ticket header in a Row of two — one per
// side, with VS in the middle.
class _TeamCol extends StatelessWidget {
  const _TeamCol({
    required this.name,
    required this.logoUrl,
    required this.side,
  });
  final String name;
  final String? logoUrl;
  final String side;

  String _initials(String n) {
    final parts =
        n.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }

  Color _avatarColor(String n) {
    const palette = <Color>[
      Color(0xFFE76F51),
      Color(0xFF2A9D8F),
      Color(0xFFE9C46A),
      Color(0xFF8AB17D),
      Color(0xFF6B5B95),
      Color(0xFF457B9D),
      Color(0xFFD64550),
    ];
    return palette[n.hashCode.abs() % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final hasLogo = logoUrl != null && logoUrl!.isNotEmpty;
    final logo = ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 64,
        height: 64,
        child: hasLogo
            ? Image.network(
                logoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _initialsBadge(context),
              )
            : _initialsBadge(context),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        logo,
        const SizedBox(height: 10),
        Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.fg,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          side,
          style: TextStyle(
            color: context.fgSub,
            fontSize: 9.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _initialsBadge(BuildContext context) {
    return Container(
      color: _avatarColor(name),
      alignment: Alignment.center,
      child: Text(
        _initials(name),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.4,
        ),
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  const _TeamRow({
    required this.name,
    required this.logoUrl,
    required this.side,
  });
  final String name;
  final String? logoUrl;
  final String side;

  String _initials(String n) {
    final parts =
        n.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }

  Color _avatarColor(String n) {
    const palette = <Color>[
      Color(0xFFE76F51),
      Color(0xFF2A9D8F),
      Color(0xFFE9C46A),
      Color(0xFF8AB17D),
      Color(0xFF6B5B95),
      Color(0xFF457B9D),
      Color(0xFFD64550),
    ];
    return palette[n.hashCode.abs() % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final hasLogo = logoUrl != null && logoUrl!.isNotEmpty;
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 56,
            height: 56,
            child: hasLogo
                ? Image.network(
                    logoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _initialsBadge(context),
                  )
                : _initialsBadge(context),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                side,
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.fg,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _initialsBadge(BuildContext context) {
    return Container(
      color: _avatarColor(name),
      alignment: Alignment.center,
      child: Text(
        _initials(name),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.4,
        ),
      ),
    );
  }
}

class _Perforation extends StatelessWidget {
  const _Perforation();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Center(
              child: LayoutBuilder(
                builder: (_, c) {
                  final dashCount = (c.maxWidth / 8).floor();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(dashCount, (_) {
                      return Container(
                        width: 4,
                        height: 1,
                        color: context.fgSub.withValues(alpha: 0.35),
                      );
                    }),
                  );
                },
              ),
            ),
          ),
          Positioned(
            left: -11,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: context.bg,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            right: -11,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: context.bg,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.fg.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: context.fg,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _ActionStatus extends StatelessWidget {
  const _ActionStatus({
    required this.title,
    required this.subtitle,
    required this.accent,
  });
  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Pricing breakdown card.
//
// Type scale used throughout (kept narrow on purpose so nothing reads as
// off-by-a-pixel):
//   eyebrow   — 11/w900/uppercase/letterspaced     (PRICING, T20 · 4hr)
//   helper    — 12/w600                            ("Full unit ₹600 · split 50/50")
//   row label — 13/w700                            ("Lock now" / "Pay at venue")
//   row amt   — 14/w800                            ("Free" / "₹300")
//   hero label — 13/w800                           ("Your share")
//   hero amt   — 30/w900/letterspacing -1.0        (the big ₹300)
class _PricingCard extends StatelessWidget {
  const _PricingCard({
    required this.yourShareRupees,
    required this.lockNowRupees,
    required this.payAtVenueRupees,
    required this.format,
    required this.formatDuration,
    required this.isEarlyBird,
  });

  final int yourShareRupees;
  final int lockNowRupees;
  final int payAtVenueRupees;
  final String format;
  final String formatDuration;
  final bool isEarlyBird;

  int get _groundFeeRupees => yourShareRupees * 2;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              context.fg.withValues(alpha: 0.04),
              context.bg,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Eyebrow row — PRICING / format tag.
              Row(
                children: [
                  Text(
                    'PRICING',
                    style: _eyebrow(context.fgSub),
                  ),
                  const Spacer(),
                  Text(
                    '$format · $formatDuration',
                    style: _eyebrow(context.fgSub),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Hero — Full unit + Your share as side-by-side stat blocks.
              // Both render equally bold so the user reads the venue's
              // quoted price next to their actual obligation.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _HeroStat(
                      label: 'FULL UNIT',
                      amountStr: '₹$_groundFeeRupees',
                      muted: true,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 44,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    color: context.fgSub.withValues(alpha: 0.15),
                  ),
                  Expanded(
                    child: _HeroStat(
                      label: 'YOUR SHARE',
                      amountStr:
                          yourShareRupees == 0 ? 'Free' : '₹$yourShareRupees',
                      muted: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Split 50/50 with opponent',
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 14),
              Container(
                height: 1,
                color: context.fgSub.withValues(alpha: 0.12),
              ),
              const SizedBox(height: 12),

              _PriceRow(
                label: 'Lock now',
                amountStr: lockNowRupees == 0 ? 'Free' : '₹$lockNowRupees',
                amountIsPositive: lockNowRupees == 0,
              ),
              const SizedBox(height: 8),
              _PriceRow(
                label: 'Pay at venue',
                amountStr: payAtVenueRupees == 0
                    ? 'Free'
                    : '₹$payAtVenueRupees',
                amountIsPositive: false,
              ),
            ],
          ),
        ),
        if (isEarlyBird) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: context.gold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: context.gold.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.bolt_rounded, color: context.gold, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Early bird booking — lock the slot ahead of time.',
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  TextStyle _eyebrow(Color color) => TextStyle(
        color: color,
        fontSize: 10.5,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.4,
        height: 1.0,
      );
}

// Stat-block hero for the pricing card. Big bold amount on top, eyebrow
// label below. Two of these sit side-by-side: Full unit and Your share.
// `muted` dims the amount one notch (used for the venue's full quote so
// the player's share gets visual primacy).
class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.amountStr,
    required this.muted,
  });

  final String label;
  final String amountStr;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          amountStr,
          style: TextStyle(
            color: muted ? context.fgSub : context.fg,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.9,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: context.fgSub,
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.amountStr,
    this.amountIsPositive = false,
  });

  final String label;
  final String amountStr;
  final bool amountIsPositive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ),
        Text(
          amountStr,
          style: TextStyle(
            color: amountIsPositive ? context.success : context.fg,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
