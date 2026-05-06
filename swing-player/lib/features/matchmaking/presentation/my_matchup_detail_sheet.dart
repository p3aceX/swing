import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../data/matchmaking_repository.dart';
import 'matchmaking_providers.dart';

typedef RefreshFn = void Function();

/// Bottom sheet showing the full state of a single match in the player's
/// "My MatchUps" tab. If the player still owes their advance, the Pay CTA
/// is the only place they can complete payment — Create tab no longer
/// drives confirmation for already-existing matches.
class MyMatchupDetailSheet extends ConsumerStatefulWidget {
  const MyMatchupDetailSheet({
    super.key,
    required this.matchId,
    required this.myLobbyId,
    required this.opponentTeamName,
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
  final String opponentTeamName;
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

  Future<void> _onPay() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repo = ref.read(matchmakingRepositoryProvider);
      final order = await repo.createMatchPaymentOrder(widget.matchId);
      _activeOrderId = order.orderId;
      _razorpay.open({
        'key': order.key,
        'amount': order.amountPaise,
        'currency': order.currency,
        'name': 'Swing',
        'description':
            'Match-Up advance — ${widget.opponentTeamName}',
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
              'Payment captured but couldn\'t confirm. Pull-to-refresh; if it persists, contact support.';
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
    final colors = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.stroke,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'vs ${widget.opponentTeamName}',
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    [
                      widget.format,
                      widget.dateLabel,
                      widget.displaySlot,
                    ].where((s) => s.isNotEmpty).join('  ·  '),
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (widget.groundName.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      [
                        widget.groundName,
                        if (widget.arenaName.isNotEmpty) widget.arenaName,
                        if (widget.groundArea.isNotEmpty) widget.groundArea,
                      ].join(' · '),
                      style: TextStyle(color: context.fgSub, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 22),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  _PaymentBlock(
                    myTeamPaid: widget.myTeamPaid,
                    opponentPaid: widget.opponentPaid,
                    confirmationRupees: widget.confirmationRupees,
                    remainingRupees: widget.remainingRupees,
                    status: widget.status,
                  ),
                  const SizedBox(height: 24),
                  if (!widget.myTeamPaid) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _busy ? null : _onPay,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: _busy
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colors.onPrimary),
                                )
                              : Text(
                                  widget.confirmationRupees > 0
                                      ? 'Pay ₹${widget.confirmationRupees} advance'
                                      : 'Pay advance',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: Color(0xFFDC2626),
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ] else if (isAwaitingOpponent) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.hourglass_top_rounded,
                                color: colors.primary, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Waiting for ${widget.opponentTeamName} to pay their advance.',
                                style: TextStyle(
                                  color: context.fg,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else if (widget.status == 'pending_payment') ...[
                    // both paid but server hasn't moved status yet
                  ] else ...[
                    // confirmed / setup / started
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        widget.remainingRupees > 0
                            ? '₹${widget.remainingRupees} remaining ground fee per team — collect at the venue.'
                            : 'Match-Up confirmed. See you on match day.',
                        style: TextStyle(color: context.fgSub, fontSize: 13),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── helpers ────────────────────────────────────────────────────────────
  bool get isAwaitingOpponent =>
      widget.myTeamPaid && !widget.opponentPaid;
}

class _PaymentBlock extends StatelessWidget {
  const _PaymentBlock({
    required this.myTeamPaid,
    required this.opponentPaid,
    required this.confirmationRupees,
    required this.remainingRupees,
    required this.status,
  });

  final bool myTeamPaid;
  final bool opponentPaid;
  final int confirmationRupees;
  final int remainingRupees;
  final String status;

  String get _headline {
    if (!myTeamPaid) return 'Your advance is pending';
    if (!opponentPaid) return 'Awaiting opponent\'s advance';
    if (status == 'pending_payment') return 'Both teams paid — confirming…';
    if (status == 'setup' || status == 'started') {
      return 'Match-Up ready';
    }
    return 'Match-Up confirmed';
  }

  String get _subline {
    if (!myTeamPaid) {
      return confirmationRupees > 0
          ? 'Pay ₹$confirmationRupees to lock the slot for your team.'
          : 'Pay the advance to lock the slot for your team.';
    }
    if (!opponentPaid) {
      return 'You\'re paid up. We\'ll notify you the moment the other side pays.';
    }
    if (remainingRupees > 0) {
      return '₹$remainingRupees per team remaining — collect at the venue.';
    }
    return 'Both teams confirmed. Slot is locked.';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _headline,
            style: TextStyle(
              color: context.fg,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _subline,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          _PaidPill(label: 'You', paid: myTeamPaid),
          const SizedBox(height: 6),
          _PaidPill(label: 'Opponent', paid: opponentPaid),
        ],
      ),
    );
  }
}

class _PaidPill extends StatelessWidget {
  const _PaidPill({required this.label, required this.paid});
  final String label;
  final bool paid;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          paid
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          color: paid ? const Color(0xFF059669) : context.fgSub,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: context.fg,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          paid ? 'Advance received' : 'Pending',
          style: TextStyle(
            color: paid ? const Color(0xFF059669) : context.fgSub,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}
