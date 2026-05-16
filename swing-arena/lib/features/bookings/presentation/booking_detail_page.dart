import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api/providers.dart';
import 'record_payment_sheet.dart';

// ─── Theme ────────────────────────────────────────────────────────────────────
class _C {
  const _C({
    required this.text,
    required this.muted,
    required this.faint,
    required this.accent,
    required this.onAccent,
    required this.green,
    required this.red,
    required this.surface,
    required this.bg,
    required this.divider,
  });
  final Color text;
  final Color muted;
  final Color faint;
  final Color accent;
  final Color onAccent;
  final Color green;
  final Color red;
  final Color surface;
  final Color bg;
  final Color divider;

  factory _C.of(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return _C(
      text: s.onSurface,
      muted: s.onSurface.withValues(alpha: 0.6),
      faint: s.onSurface.withValues(alpha: 0.12),
      accent: s.primary,
      onAccent: s.onPrimary,
      green: const Color(0xFF22C55E),
      red: s.error,
      surface: s.surfaceContainerHighest,
      bg: s.surface,
      divider: s.outlineVariant,
    );
  }
}

late _C _c;

// ─── Provider ─────────────────────────────────────────────────────────────────

final _bookingDetailProvider =
    FutureProvider.autoDispose.family<ArenaReservation, String>(
  (ref, bookingId) async {
    final repo = ref.watch(hostArenaBookingRepositoryProvider);
    return repo.getOwnerBookingDetail(bookingId);
  },
);

// ─── Page ─────────────────────────────────────────────────────────────────────

class BookingDetailPage extends ConsumerWidget {
  const BookingDetailPage({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _c = _C.of(context);
    final async = ref.watch(_bookingDetailProvider(bookingId));
    return Scaffold(
      backgroundColor: _c.bg,
      appBar: AppBar(
        backgroundColor: _c.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: _c.text),
        title: Text('Booking Detail',
            style: TextStyle(
                color: _c.text, fontSize: 17, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: _c.muted),
            onPressed: () => ref.invalidate(_bookingDetailProvider(bookingId)),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Failed to load',
                    style: TextStyle(
                        color: _c.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('$e',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _c.muted, fontSize: 12)),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(_bookingDetailProvider(bookingId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (booking) => _BookingDetailBody(booking: booking),
      ),
      floatingActionButton: async.valueOrNull != null &&
              async.valueOrNull!.status != 'CANCELLED'
          ? _BottomActions(
              booking: async.valueOrNull!,
              dio: ref.read(dioProvider),
              onRecorded: () => ref.invalidate(_bookingDetailProvider(bookingId)),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _BookingDetailBody extends ConsumerWidget {
  const _BookingDetailBody({required this.booking});
  final ArenaReservation booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _c = _C.of(context);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _HeaderCard(booking: booking)),
        SliverToBoxAdapter(child: _PaymentSummaryCard(booking: booking)),
        if (booking.isSplit)
          SliverToBoxAdapter(child: _SplitBadge()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text('Payments Ledger',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _c.muted,
                    letterSpacing: 0.5)),
          ),
        ),
        if (booking.bookingPayments.isEmpty)
          SliverToBoxAdapter(child: _EmptyLedger())
        else if (booking.isSplit && booking.matchInfo != null)
          SliverToBoxAdapter(
            child: _GroupedLedger(booking: booking, ref: ref),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _PaymentRow(
                payment: booking.bookingPayments[i],
                bookingId: booking.id,
                onDeleted: () => ref
                    .invalidate(_bookingDetailProvider(booking.id)),
              ),
              childCount: booking.bookingPayments.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}

// ─── Header card ─────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.booking});
  final ArenaReservation booking;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final date = booking.bookingDate != null
        ? DateFormat('EEE, d MMM yyyy').format(booking.bookingDate!)
        : '—';
    final total = booking.totalAmountPaise / 100;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _c.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (booking.isSplit && booking.matchInfo != null)
            _SplitTeamsBlock(matchInfo: booking.matchInfo!, status: booking.status)
          else ...[
            Row(
              children: [
                Expanded(
                  child: Text(booking.displayName,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _c.text)),
                ),
                _StatusChip(status: booking.status),
              ],
            ),
            if (booking.displayPhone.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(booking.displayPhone,
                  style: TextStyle(fontSize: 12, color: _c.muted)),
            ],
          ],
          const SizedBox(height: 16),
          _InfoRow(
              icon: Icons.calendar_today_rounded,
              label: date),
          const SizedBox(height: 8),
          _InfoRow(
              icon: Icons.access_time_rounded,
              label: '${booking.startTime} – ${booking.endTime}'),
          if (booking.unitName != null) ...[
            const SizedBox(height: 8),
            _InfoRow(
                icon: Icons.sports_cricket_rounded,
                label: booking.unitName!),
          ],
          const SizedBox(height: 16),
          Divider(color: _c.divider, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _c.muted)),
              Text('₹${total.toStringAsFixed(0)}',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: _c.text)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return Row(
      children: [
        Icon(icon, size: 15, color: _c.muted),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _c.text)),
      ],
    );
  }
}

// ─── Payment summary card ─────────────────────────────────────────────────────

class _PaymentSummaryCard extends StatelessWidget {
  const _PaymentSummaryCard({required this.booking});
  final ArenaReservation booking;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final received = booking.effectivePaidPaise / 100;
    final total = booking.totalAmountPaise / 100;
    final balance = booking.balancePaise / 100;
    final pct = total > 0 ? (received / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _c.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Received',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _c.muted,
                            letterSpacing: 0.4)),
                    const SizedBox(height: 2),
                    Text('₹${received.toStringAsFixed(0)}',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: _c.green)),
                  ],
                ),
              ),
              if (balance > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Balance Due',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _c.muted,
                            letterSpacing: 0.4)),
                    const SizedBox(height: 2),
                    Text('₹${balance.toStringAsFixed(0)}',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: _c.red)),
                  ],
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _c.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('PAID IN FULL',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _c.green,
                          letterSpacing: 0.5)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: _c.faint,
              valueColor: AlwaysStoppedAnimation(_c.green),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${booking.paymentsCount > 0 ? booking.paymentsCount : (booking.advancePaise > 0 ? 1 : 0)} payment${booking.paymentsCount != 1 ? 's' : ''} recorded · ₹${received.toStringAsFixed(0)} of ₹${total.toStringAsFixed(0)}',
            style: TextStyle(fontSize: 11, color: _c.muted),
          ),
        ],
      ),
    );
  }
}

// ─── Split badge ──────────────────────────────────────────────────────────────

class _SplitTeamsBlock extends StatelessWidget {
  const _SplitTeamsBlock({required this.matchInfo, required this.status});
  final MatchupContext matchInfo;
  final String status;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _TeamLine(
                teamName: matchInfo.teamAName,
                captain: matchInfo.teamACaptain,
                confirmed: matchInfo.teamAConfirmed,
              ),
            ),
            _StatusChip(status: status),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            'vs',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _c.muted,
              letterSpacing: 0.4,
            ),
          ),
        ),
        const SizedBox(height: 6),
        if (matchInfo.hasOpponent)
          _TeamLine(
            teamName: matchInfo.teamBName,
            captain: matchInfo.teamBCaptain,
            confirmed: matchInfo.teamBConfirmed,
          )
        else
          Text(
            'Looking for opponent',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _c.muted,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }
}

class _TeamLine extends StatelessWidget {
  const _TeamLine({
    required this.teamName,
    required this.captain,
    required this.confirmed,
  });
  final String teamName;
  final TeamCaptainContact? captain;
  final bool confirmed;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final captainName = captain?.name?.trim() ?? '';
    final captainPhone = captain?.phone?.trim() ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                teamName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _c.text,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (confirmed) ...[
              const SizedBox(width: 6),
              Icon(Icons.check_circle_rounded, color: _c.green, size: 14),
            ],
          ],
        ),
        if (captainName.isNotEmpty || captainPhone.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              [
                if (captainName.isNotEmpty) 'Captain · $captainName',
                if (captainPhone.isNotEmpty) captainPhone,
              ].join('  ·  '),
              style: TextStyle(fontSize: 11, color: _c.muted),
            ),
          ),
      ],
    );
  }
}

class _GroupedLedger extends StatelessWidget {
  const _GroupedLedger({required this.booking, required this.ref});
  final ArenaReservation booking;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final mi = booking.matchInfo!;
    final perTeamShare = (booking.totalAmountPaise / 2).round();
    final groupA = <BookingPayment>[];
    final groupB = <BookingPayment>[];
    final unattributed = <BookingPayment>[];
    for (final p in booking.bookingPayments) {
      if (p.payerTeamId == mi.teamAId && mi.teamAId != null) {
        groupA.add(p);
      } else if (p.payerTeamId == mi.teamBId && mi.teamBId != null) {
        groupB.add(p);
      } else {
        unattributed.add(p);
      }
    }
    int sum(List<BookingPayment> ps) =>
        ps.fold(0, (a, p) => a + p.amountPaise);

    return Column(
      children: [
        _TeamLedgerSection(
          teamLabel: mi.teamAName,
          paidPaise: sum(groupA),
          sharePaise: perTeamShare,
          payments: groupA,
          bookingId: booking.id,
          onChanged: () =>
              ref.invalidate(_bookingDetailProvider(booking.id)),
        ),
        if (mi.hasOpponent)
          _TeamLedgerSection(
            teamLabel: mi.teamBName,
            paidPaise: sum(groupB),
            sharePaise: perTeamShare,
            payments: groupB,
            bookingId: booking.id,
            onChanged: () =>
                ref.invalidate(_bookingDetailProvider(booking.id)),
          ),
        if (unattributed.isNotEmpty)
          _TeamLedgerSection(
            teamLabel: 'Unassigned',
            paidPaise: sum(unattributed),
            sharePaise: null,
            payments: unattributed,
            bookingId: booking.id,
            onChanged: () =>
                ref.invalidate(_bookingDetailProvider(booking.id)),
          ),
      ],
    );
  }
}

class _TeamLedgerSection extends StatelessWidget {
  const _TeamLedgerSection({
    required this.teamLabel,
    required this.paidPaise,
    required this.sharePaise,
    required this.payments,
    required this.bookingId,
    required this.onChanged,
  });
  final String teamLabel;
  final int paidPaise;
  final int? sharePaise;
  final List<BookingPayment> payments;
  final String bookingId;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final paid = paidPaise / 100;
    final share = sharePaise == null ? null : sharePaise! / 100;
    final fullyPaid = sharePaise != null && paidPaise >= sharePaise!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  teamLabel.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _c.muted,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              Text(
                share == null
                    ? '₹${paid.toStringAsFixed(0)}'
                    : '₹${paid.toStringAsFixed(0)} / ₹${share.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: fullyPaid ? _c.green : _c.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (payments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'No payments yet',
                style: TextStyle(fontSize: 12, color: _c.muted),
              ),
            )
          else
            ...payments.map((p) => Padding(
                  padding: EdgeInsets.zero,
                  child: _PaymentRow(
                    payment: p,
                    bookingId: bookingId,
                    onDeleted: onChanged,
                    flat: true,
                  ),
                )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SplitBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _c.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _c.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.people_rounded, size: 16, color: _c.accent),
          const SizedBox(width: 8),
          Text('Split Booking — cost shared between teams',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _c.accent)),
        ],
      ),
    );
  }
}

// ─── Empty ledger ─────────────────────────────────────────────────────────────

class _EmptyLedger extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Center(
        child: Text('No payments recorded yet',
            style: TextStyle(fontSize: 14, color: _c.muted)),
      ),
    );
  }
}

// ─── Payment row ─────────────────────────────────────────────────────────────

class _PaymentRow extends ConsumerWidget {
  const _PaymentRow({
    required this.payment,
    required this.bookingId,
    required this.onDeleted,
    this.flat = false,
  });
  final BookingPayment payment;
  final String bookingId;
  final VoidCallback onDeleted;
  // When true, the row sits inside a section that already provides outer
  // horizontal padding (the grouped ledger). Avoids double-indenting.
  final bool flat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _c = _C.of(context);
    final amt = payment.amountPaise / 100;
    final date = DateFormat('d MMM, hh:mm a').format(payment.recordedAt.toLocal());

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: flat ? 0 : 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _c.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _c.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _modeIcon(payment.paymentMode),
                size: 18,
                color: _c.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(payment.payerName,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _c.text)),
                  const SizedBox(height: 2),
                  Text(
                    '${payment.paymentMode} · $date',
                    style:
                        TextStyle(fontSize: 11, color: _c.muted),
                  ),
                  if (payment.reference != null) ...[
                    const SizedBox(height: 2),
                    Text('Ref: ${payment.reference}',
                        style: TextStyle(
                            fontSize: 10, color: _c.muted)),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${amt.toStringAsFixed(0)}',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: _c.green)),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _confirmDelete(context, ref),
                  child: Text('Remove',
                      style: TextStyle(
                          fontSize: 11,
                          color: _c.red,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _modeIcon(String mode) {
    switch (mode) {
      case 'UPI':
        return Icons.account_balance_wallet_rounded;
      case 'CARD':
        return Icons.credit_card_rounded;
      case 'BANK_TRANSFER':
        return Icons.account_balance_rounded;
      default:
        return Icons.payments_rounded;
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove payment?'),
        content: Text(
            'Remove ₹${(payment.amountPaise / 100).toStringAsFixed(0)} from ${payment.payerName}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Remove',
                  style: TextStyle(color: Theme.of(context).colorScheme.error))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(hostArenaBookingRepositoryProvider)
          .deleteBookingPayment(bookingId, payment.id);
      onDeleted();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }
}

// ─── Status chip ─────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    Color bg;
    Color fg;
    String label;
    switch (status) {
      case 'CONFIRMED':
        bg = _c.green.withValues(alpha: 0.12);
        fg = _c.green;
        label = 'CONFIRMED';
        break;
      case 'CHECKED_IN':
        bg = _c.green.withValues(alpha: 0.12);
        fg = _c.green;
        label = 'PAID';
        break;
      case 'CANCELLED':
        bg = _c.red.withValues(alpha: 0.12);
        fg = _c.red;
        label = 'CANCELLED';
        break;
      default:
        bg = _c.muted.withValues(alpha: 0.12);
        fg = _c.muted;
        label = status.replaceAll('_', ' ');
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w800, color: fg, letterSpacing: 0.5)),
    );
  }
}

// ─── Record Payment FAB ───────────────────────────────────────────────────────

// ─── Bottom actions (Record Payment + Send Link) ─────────────────────────────

class _BottomActions extends StatefulWidget {
  const _BottomActions({required this.booking, required this.dio, required this.onRecorded});
  final ArenaReservation booking;
  final Dio dio;
  final VoidCallback onRecorded;

  @override
  State<_BottomActions> createState() => _BottomActionsState();
}

class _BottomActionsState extends State<_BottomActions> {
  bool _linkLoading = false;

  Future<void> _sendPaymentLink() async {
    setState(() => _linkLoading = true);
    try {
      final res = await widget.dio.post('/bookings/${widget.booking.id}/payment-link');
      final data = (res.data['data'] as Map).cast<String, dynamic>();
      final url  = data['url'] as String? ?? '';
      final phone = widget.booking.displayPhone.replaceAll(RegExp(r'\D'), '');

      final amount = widget.booking.totalAmountPaise / 100;
      final msg = 'Hi ${widget.booking.displayName}, your arena booking payment of '
          '₹${amount.toStringAsFixed(0)} is pending.\nPay securely here: $url';

      if (mounted && phone.isNotEmpty) {
        final num = phone.length == 10 ? '91$phone' : phone;
        await launchUrl(
          Uri.parse('https://wa.me/$num?text=${Uri.encodeComponent(msg)}'),
          mode: LaunchMode.externalApplication,
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Link: $url')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate payment link')),
        );
      }
    } finally {
      if (mounted) setState(() => _linkLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final balanceDue = widget.booking.balancePaise;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        if (balanceDue > 0) ...[
          Expanded(
            child: FloatingActionButton.extended(
              heroTag: 'sendLink',
              onPressed: _linkLoading ? null : _sendPaymentLink,
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              icon: _linkLoading
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send_rounded, size: 18),
              label: const Text('Send Link',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: FloatingActionButton.extended(
            heroTag: 'recordPayment',
            onPressed: () => _showSheet(context),
            backgroundColor: _c.accent,
            foregroundColor: _c.onAccent,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Record Payment',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          ),
        ),
      ]),
    );
  }

  void _showSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RecordPaymentSheet(
        booking: widget.booking,
        onRecorded: widget.onRecorded,
      ),
    );
  }
}

class _RecordPaymentFab extends StatelessWidget {
  const _RecordPaymentFab({required this.booking, required this.onRecorded});
  final ArenaReservation booking;
  final VoidCallback onRecorded;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: FloatingActionButton.extended(
          onPressed: () => _showSheet(context),
          backgroundColor: _c.accent,
          foregroundColor: _c.onAccent,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Record Payment',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        ),
      ),
    );
  }

  void _showSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RecordPaymentSheet(
        booking: booking,
        onRecorded: onRecorded,
      ),
    );
  }
}

