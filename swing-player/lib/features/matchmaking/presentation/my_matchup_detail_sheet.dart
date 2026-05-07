import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../core/api/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../data/matchmaking_repository.dart';
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
  });

  final String matchId;
  final String? myLobbyId;
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
  final RefreshFn onRefresh;

  @override
  ConsumerState<MyMatchupDetailSheet> createState() =>
      _MyMatchupDetailSheetState();
}

class _MyMatchupDetailSheetState extends ConsumerState<MyMatchupDetailSheet> {
  late final Razorpay _razorpay;
  bool _busy = false;
  String? _error;
  String? _activeOrderId;

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
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
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
    try {
      final repo = ref.read(matchmakingRepositoryProvider);
      final order = await repo.createMatchPaymentOrder(widget.matchId);
      _activeOrderId = order.orderId;
      _razorpay.open({
        'key': order.key,
        'amount': order.amountPaise,
        'currency': order.currency,
        'name': 'Swing',
        'description': 'Match-Up advance — ${widget.opponentTeamName}',
        'order_id': order.orderId,
      });
    } catch (e) {
      debugPrint('[MyMatchupDetail] createOrder error: $e');
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Could not start payment. Please try again.';
        });
      }
    }
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final repo = ref.read(matchmakingRepositoryProvider);
      await repo.verifyMatchPayment(
        razorpayPaymentId: response.paymentId ?? '',
        razorpayOrderId: response.orderId ?? _activeOrderId ?? '',
        razorpaySignature: response.signature ?? '',
      );
      widget.onRefresh();
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Advance paid — match confirmed.')),
      );
    } catch (e) {
      debugPrint('[MyMatchupDetail] verify error: $e');
      if (mounted) {
        setState(() {
          _busy = false;
          _error =
              "Payment captured but couldn't confirm. Pull-to-refresh; if it persists, contact support.";
        });
      }
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = response.message?.isNotEmpty == true
          ? response.message
          : 'Payment was not completed.';
    });
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionArea(BuildContext context) {
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
            child: Column(
              children: [
                _TeamRow(
                  name: myTeamName,
                  logoUrl: myTeamLogoUrl,
                  side: 'YOU',
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 0.5,
                        color: context.stroke.withValues(alpha: 0.18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
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
                      child: Container(
                        height: 0.5,
                        color: context.stroke.withValues(alpha: 0.18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _TeamRow(
                  name: opponentTeamName,
                  logoUrl: opponentTeamLogoUrl,
                  side: 'OPPONENT',
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      dateLabel.toUpperCase(),
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      displaySlot,
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
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
