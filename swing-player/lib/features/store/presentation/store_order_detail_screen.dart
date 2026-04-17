import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/store_models.dart';
import 'store_detail_screen.dart';
import 'storefront_screen.dart';

class StoreOrderDetailScreen extends ConsumerStatefulWidget {
  const StoreOrderDetailScreen({
    super.key,
    required this.orderId,
  });

  final String orderId;

  @override
  ConsumerState<StoreOrderDetailScreen> createState() =>
      _StoreOrderDetailScreenState();
}

class _StoreOrderDetailScreenState
    extends ConsumerState<StoreOrderDetailScreen> {
  late final Razorpay _razorpay;
  Timer? _pollTimer;

  bool _isLoading = true;
  bool _isPaying = false;
  String? _error;
  StoreOrder? _order;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
    _load();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _load() async {
    final repository = ref.read(storeRepositoryProvider);
    try {
      final order = await repository.getOrder(widget.orderId);
      if (!mounted) return;
      _pollTimer?.cancel();
      if (order.isActive) {
        _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
          if (mounted) {
            _refreshSilently();
          }
        });
      }
      setState(() {
        _order = order;
        _error = null;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = repository.messageFor(
          error,
          fallback: 'Could not load this order.',
        );
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshSilently() async {
    final repository = ref.read(storeRepositoryProvider);
    try {
      final order = await repository.getOrder(widget.orderId);
      if (!mounted) return;
      setState(() => _order = order);
    } catch (_) {}
  }

  Future<void> _retryPayment() async {
    setState(() => _isPaying = true);
    try {
      final payment =
          await ref.read(storePaymentServiceProvider).createStoreOrderPayment(
                widget.orderId,
              );
      _razorpay.open({
        'key': payment.key,
        'amount': payment.amountPaise,
        'currency': payment.currency,
        'name': 'Swing Store',
        'description': 'Complete store order payment',
        'order_id': payment.orderId,
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isPaying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(storeRepositoryProvider).messageFor(error),
          ),
        ),
      );
    }
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
    try {
      await ref.read(storePaymentServiceProvider).verifyStoreOrderPayment(
            orderId: response.orderId ?? '',
            paymentId: response.paymentId ?? '',
            signature: response.signature ?? '',
          );
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment completed')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(storeRepositoryProvider).messageFor(error),
          ),
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
          response.message?.trim().isNotEmpty == true
              ? response.message!.trim()
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

  Future<void> _openUrl(String value) async {
    final uri = Uri.tryParse(value);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        titleSpacing: 16,
        title: Text(
          'Order ${widget.orderId.substring(0, widget.orderId.length.clamp(0, 8))}',
          style: TextStyle(color: context.fg, fontWeight: FontWeight.w900),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _load,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : order == null
                  ? const SizedBox.shrink()
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                        children: [
                          _OrderStatusHero(order: order),
                          const SizedBox(height: 16),
                          _OrderTimeline(order: order),
                          const SizedBox(height: 16),
                          _InfoSection(
                            title: 'Delivery',
                            children: [
                              _InfoRow(
                                icon: Icons.location_on_outlined,
                                title: 'Address',
                                value: order.deliveryAddress,
                              ),
                              if ((order.notes ?? '').isNotEmpty)
                                _InfoRow(
                                  icon: Icons.notes_rounded,
                                  title: 'Notes',
                                  value: order.notes!,
                                ),
                              if (order.delivery?.estimatedDelivery != null)
                                _InfoRow(
                                  icon: Icons.schedule_rounded,
                                  title: 'Estimated delivery',
                                  value: DateFormat('d MMM, h:mm a').format(
                                    order.delivery!.estimatedDelivery!
                                        .toLocal(),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _InfoSection(
                            title: 'Items',
                            children: order.items
                                .map(
                                  (item) => _OrderItemRow(item: item),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                          _InfoSection(
                            title: 'Billing',
                            children: [
                              _PriceRow(
                                label: 'Subtotal',
                                amountPaise: order.totalAmountPaise,
                              ),
                              _PriceRow(
                                label: 'Delivery fee',
                                amountPaise: order.deliveryFeePaise,
                              ),
                              _PriceRow(
                                label: 'Tax',
                                amountPaise: order.taxAmountPaise,
                              ),
                              _PriceRow(
                                label: 'Discount',
                                amountPaise: -order.discountAmountPaise,
                                highlight: true,
                              ),
                              const SizedBox(height: 8),
                              _PriceRow(
                                label: 'Total',
                                amountPaise: order.finalAmountPaise,
                                emphasis: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              if ((order.invoice?.invoiceUrl ?? '').isNotEmpty)
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        _openUrl(order.invoice!.invoiceUrl!),
                                    icon: const Icon(
                                      Icons.receipt_long_rounded,
                                    ),
                                    label: const Text('Invoice'),
                                  ),
                                ),
                              if ((order.invoice?.invoiceUrl ?? '')
                                      .isNotEmpty &&
                                  (order.delivery?.trackingUrl ?? '')
                                      .isNotEmpty)
                                const SizedBox(width: 12),
                              if ((order.delivery?.trackingUrl ?? '')
                                  .isNotEmpty)
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        _openUrl(order.delivery!.trackingUrl!),
                                    icon: const Icon(
                                      Icons.map_outlined,
                                    ),
                                    label: const Text('Tracking'),
                                  ),
                                ),
                            ],
                          ),
                          if (order.isPayable) ...[
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _isPaying ? null : _retryPayment,
                              icon: _isPaying
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.account_balance_wallet_outlined,
                                    ),
                              label: Text(
                                _isPaying
                                    ? 'Opening payment'
                                    : 'Complete Payment',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
    );
  }
}

class _OrderStatusHero extends StatelessWidget {
  const _OrderStatusHero({required this.order});

  final StoreOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: context.stroke),
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
                    Text(
                      order.store.name,
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Placed ${_when(order.createdAt)}',
                      style: TextStyle(color: context.fgSub, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _headline(order.status),
            style: TextStyle(
              color: context.fg,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            NumberFormat.currency(
              locale: 'en_IN',
              symbol: 'Rs ',
              decimalDigits: 0,
            ).format(order.finalAmountPaise / 100),
            style: TextStyle(
              color: context.accent,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderTimeline extends StatelessWidget {
  const _OrderTimeline({required this.order});

  final StoreOrder order;

  @override
  Widget build(BuildContext context) {
    const stages = [
      'PENDING',
      'PAID',
      'PREPARING',
      'READY',
      'DISPATCHED',
      'DELIVERED',
    ];
    final currentIndex =
        stages.indexOf(order.status.toUpperCase()).clamp(0, stages.length - 1);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(stages.length, (index) {
          final stage = stages[index];
          final active = index <= currentIndex;
          return Padding(
            padding:
                EdgeInsets.only(bottom: index == stages.length - 1 ? 0 : 14),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active ? context.accent : context.panel,
                  ),
                  child: Icon(
                    active ? Icons.check_rounded : Icons.circle_outlined,
                    size: 14,
                    color: active ? Colors.white : context.fgSub,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _label(stage),
                    style: TextStyle(
                      color: active ? context.fg : context.fgSub,
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: context.fg,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: context.fgSub),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
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

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({required this.item});

  final StoreOrderItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.panel,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.inventory_2_outlined, color: context.fgSub),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.variant.product.name,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.variant.name} · Qty ${item.quantity}',
                  style: TextStyle(color: context.fgSub, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            NumberFormat.currency(
              locale: 'en_IN',
              symbol: 'Rs ',
              decimalDigits: 0,
            ).format(item.totalPricePaise / 100),
            style: TextStyle(
              color: context.fg,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.amountPaise,
    this.highlight = false,
    this.emphasis = false,
  });

  final String label;
  final int amountPaise;
  final bool highlight;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final amount = NumberFormat.currency(
      locale: 'en_IN',
      symbol: 'Rs ',
      decimalDigits: 0,
    ).format(amountPaise / 100);
    final color = highlight
        ? context.success
        : emphasis
            ? context.fg
            : context.fgSub;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: emphasis ? context.fg : context.fgSub,
                fontWeight: emphasis ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontWeight: emphasis ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase();
    final color = switch (normalized) {
      'DELIVERED' => context.success,
      'DISPATCHED' || 'READY' => context.sky,
      'PREPARING' || 'PAID' => context.gold,
      'CANCELLED' => context.danger,
      _ => context.warn,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        normalized,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

String _headline(String status) {
  return switch (status.toUpperCase()) {
    'PENDING' => 'Waiting for payment confirmation',
    'PAID' => 'Payment received. Store will start packing soon.',
    'PREPARING' => 'Store is preparing your order',
    'READY' => 'Packed and ready for pickup',
    'DISPATCHED' => 'Your order is on the way',
    'DELIVERED' => 'Delivered successfully',
    'CANCELLED' => 'Order cancelled',
    _ => 'Order update available',
  };
}

String _label(String status) {
  return switch (status) {
    'PENDING' => 'Order created',
    'PAID' => 'Payment confirmed',
    'PREPARING' => 'Preparing',
    'READY' => 'Ready for dispatch',
    'DISPATCHED' => 'On the way',
    'DELIVERED' => 'Delivered',
    _ => status,
  };
}

String _when(DateTime? value) {
  if (value == null) return 'recently';
  return DateFormat('d MMM, h:mm a').format(value.toLocal());
}
