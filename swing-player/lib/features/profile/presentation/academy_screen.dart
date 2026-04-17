import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../controller/profile_controller.dart';
import '../domain/profile_models.dart';
import 'widgets/profile_section_card.dart';

class AcademyScreen extends ConsumerWidget {
  const AcademyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileControllerProvider);

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        title: const Text('Academy'),
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.error != null
                ? _AcademyError(
                    message: state.error!,
                    onRetry: () =>
                        ref.read(profileControllerProvider.notifier).load(),
                  )
                : state.data == null
                    ? _AcademyError(
                        message: 'No academy data found.',
                        onRetry: () =>
                            ref.read(profileControllerProvider.notifier).load(),
                      )
                    : RefreshIndicator(
                        color: context.accent,
                        onRefresh: () => ref
                            .read(profileControllerProvider.notifier)
                            .refresh(),
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            _AcademyHero(data: state.data!.academy),
                            const SizedBox(height: 16),
                            _AcademyContent(data: state.data!.academy),
                          ],
                        ),
                      ),
      ),
    );
  }
}

class _AcademyError extends StatelessWidget {
  const _AcademyError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, color: context.danger, size: 38),
            const SizedBox(height: 16),
            Text(
              'Could not load academy',
              style: TextStyle(
                color: context.fg,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: context.fgSub,
                fontSize: 13,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AcademyHero extends StatelessWidget {
  const _AcademyHero({required this.data});

  final AcademySummary data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.stroke),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: context.accentBg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.school_rounded,
              color: context.accent,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.isLinked ? (data.academyName ?? 'Academy') : 'Academy',
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.isLinked
                      ? (data.academyCity ?? 'Academy linked')
                      : 'No linked academy yet',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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

class _AcademyContent extends ConsumerStatefulWidget {
  const _AcademyContent({required this.data});

  final AcademySummary data;

  @override
  ConsumerState<_AcademyContent> createState() => _AcademyContentState();
}

class _AcademyContentState extends ConsumerState<_AcademyContent> {
  late final Razorpay _razorpay;
  bool _isPaying = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final totalTransactions = data.transactions.length;
    final settledTransactions = data.transactions
        .where((transaction) => _isSettledStatus(transaction.status))
        .length;
    final latestTransaction =
        data.transactions.isEmpty ? null : data.transactions.first;

    return Column(
      children: [
        ProfileSectionCard(
          title: 'Academy',
          child: data.isLinked
              ? Column(
                  children: [
                    _AcademyMetricGrid(
                      items: [
                        _AcademyMetricItem('Status', data.feeStatus ?? '-'),
                        _AcademyMetricItem(
                            'Fee', _currency(data.feeAmountPaise)),
                        _AcademyMetricItem(
                            'Paid', _currency(data.feePaidPaise)),
                        _AcademyMetricItem('Due', _currency(data.feeDuePaise)),
                        if ((data.feeFrequency ?? '').isNotEmpty)
                          _AcademyMetricItem('Cycle', data.feeFrequency!),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _AcademyInfoLine(
                      icon: Icons.school_outlined,
                      label: 'Academy',
                      value: data.academyName ?? '-',
                    ),
                    if ((data.academyCity ?? '').isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _AcademyInfoLine(
                        icon: Icons.location_city_outlined,
                        label: 'City',
                        value: data.academyCity!,
                      ),
                    ],
                    if ((data.batchName ?? '').isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _AcademyInfoLine(
                        icon: Icons.groups_2_outlined,
                        label: 'Batch',
                        value: data.batchName!,
                      ),
                    ],
                    if ((data.batchSchedule ?? '').isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _AcademyInfoLine(
                        icon: Icons.calendar_today_outlined,
                        label: 'Schedule',
                        value: data.batchSchedule!,
                      ),
                    ],
                    const SizedBox(height: 12),
                    _AcademyInfoLine(
                      icon: Icons.sports_rounded,
                      label: 'Coach',
                      value: data.coachName ?? 'Coach not mapped yet',
                    ),
                    const SizedBox(height: 12),
                    _AcademyInfoLine(
                      icon: Icons.schedule_rounded,
                      label: 'Next Session',
                      value: data.nextSessionLabel ?? 'No session scheduled',
                    ),
                    if ((data.feeStatus ?? '').isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _AcademyInfoLine(
                        icon: Icons.receipt_long_outlined,
                        label: 'Fee Status',
                        value: data.feeStatus!,
                      ),
                    ],
                    if ((data.latestReportSummary ?? '').isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _AcademyInfoLine(
                        icon: Icons.notes_rounded,
                        label: 'Latest Report',
                        value: data.latestReportSummary!,
                      ),
                    ],
                    if (data.enrollmentId != null) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isPaying || data.feeDuePaise <= 0
                              ? null
                              : _payFee,
                          icon: _isPaying
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                )
                              : const Icon(
                                  Icons.account_balance_wallet_outlined,
                                ),
                          label: Text(_isPaying ? 'Processing' : 'Pay Fee'),
                        ),
                      ),
                    ],
                  ],
                )
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: context.panel,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.school_outlined, color: context.accent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No linked academy yet.',
                          style: TextStyle(
                            color: context.fg,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        if (data.isLinked) ...[
          const SizedBox(height: 16),
          ProfileSectionCard(
            title: 'Transactions',
            child: data.transactions.isEmpty
                ? Text(
                    'No fee transactions yet.',
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 13,
                    ),
                  )
                : Column(
                    children: [
                      _AcademyMetricGrid(
                        items: [
                          _AcademyMetricItem('Payments', '$totalTransactions'),
                          _AcademyMetricItem('Settled', '$settledTransactions'),
                          _AcademyMetricItem(
                            'Last Paid',
                            latestTransaction == null
                                ? '-'
                                : _currency(latestTransaction.amountPaise),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Column(
                        children: data.transactions.map((transaction) {
                          final isLast = identical(
                            transaction,
                            data.transactions.last,
                          );
                          return Container(
                            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                            margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
                            decoration: BoxDecoration(
                              border: isLast
                                  ? null
                                  : Border(
                                      bottom: BorderSide(color: context.stroke),
                                    ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: context.panel,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    Icons.receipt_long_outlined,
                                    size: 18,
                                    color: context.accent,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _currency(transaction.amountPaise),
                                        style: TextStyle(
                                          color: context.fg,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        [
                                          transaction.status,
                                          if ((transaction.mode ?? '')
                                              .isNotEmpty)
                                            transaction.mode!,
                                          if (transaction.createdAt != null)
                                            DateFormat('d MMM yyyy').format(
                                              transaction.createdAt!,
                                            ),
                                        ].join(' · '),
                                        style: TextStyle(
                                          color: context.fgSub,
                                          fontSize: 12,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
          ),
        ],
      ],
    );
  }

  bool _isSettledStatus(String status) {
    final normalized = status.toLowerCase();
    return normalized.contains('paid') ||
        normalized.contains('captured') ||
        normalized.contains('success') ||
        normalized.contains('completed');
  }

  Future<void> _payFee() async {
    final enrollmentId = widget.data.enrollmentId;
    if (enrollmentId == null || enrollmentId.isEmpty) return;

    setState(() => _isPaying = true);
    try {
      final order = await ref.read(academyFeeServiceProvider).createFeeOrder(
            enrollmentId,
          );
      if (order.amountPaise <= 0 || order.orderId.isEmpty) {
        throw Exception('No payable fee available right now');
      }

      _razorpay.open({
        'key': order.key,
        'amount': order.amountPaise,
        'currency': order.currency,
        'name': 'Swing',
        'description': 'Academy Fee',
        'order_id': order.orderId,
        'prefill': {},
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isPaying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
    try {
      await ref.read(academyFeeServiceProvider).verifyFeePayment(
            orderId: response.orderId ?? '',
            paymentId: response.paymentId ?? '',
            signature: response.signature ?? '',
          );
      await ref.read(profileControllerProvider.notifier).refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fee payment successful')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isPaying = false);
      }
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    setState(() => _isPaying = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response.message?.isNotEmpty == true
              ? response.message!
              : 'Payment failed',
        ),
      ),
    );
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${response.walletName ?? 'Wallet'} selected')),
    );
  }

  String _currency(int paise) {
    final amount = paise / 100;
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: 'Rs ',
      decimalDigits: 0,
    ).format(amount);
  }
}

class _AcademyMetricGrid extends StatelessWidget {
  const _AcademyMetricGrid({required this.items});

  final List<_AcademyMetricItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.75,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.panel,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.stroke),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label.toUpperCase(),
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.9,
                ),
              ),
              const Spacer(),
              Text(
                item.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.fg,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AcademyMetricItem {
  const _AcademyMetricItem(this.label, this.value);

  final String label;
  final String value;
}

class _AcademyInfoLine extends StatelessWidget {
  const _AcademyInfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: context.panel,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 16, color: context.accent),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: context.fg,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
