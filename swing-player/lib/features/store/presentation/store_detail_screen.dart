import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../controller/store_cart_controller.dart';
import '../data/store_payment_service.dart';
import '../domain/store_models.dart';
import 'storefront_screen.dart';

final storePaymentServiceProvider = Provider<StorePaymentService>((ref) {
  return StorePaymentService();
});

class StoreDetailScreen extends ConsumerStatefulWidget {
  const StoreDetailScreen({
    super.key,
    required this.storeId,
    this.initialArgs,
  });

  final String storeId;
  final StoreScreenArgs? initialArgs;

  @override
  ConsumerState<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends ConsumerState<StoreDetailScreen> {
  late final Razorpay _razorpay;
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  bool _isCheckingOut = false;
  String? _error;
  StoreListing? _store;
  List<StoreCategory> _categories = const [];
  List<StoreInventoryItem> _inventory = const [];
  String? _selectedCategoryId;
  String? _pendingOrderId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialArgs?.preferredCategoryId;
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
    _searchController.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    _razorpay.clear();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final repository = ref.read(storeRepositoryProvider);
    try {
      final results = await Future.wait<dynamic>([
        repository.getStore(widget.storeId),
        repository.getStoreInventory(widget.storeId),
        repository.listCategories(),
      ]);
      if (!mounted) return;
      setState(() {
        _store = results[0] as StoreListing;
        _inventory = results[1] as List<StoreInventoryItem>;
        _categories = results[2] as List<StoreCategory>;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = repository.messageFor(
          error,
          fallback: 'Could not load this store.',
        );
        _isLoading = false;
      });
    }
  }

  List<StoreGroup> get _groups {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _inventory.where((item) {
      if (_selectedCategoryId != null &&
          item.product.categoryId != _selectedCategoryId) {
        return false;
      }
      if (query.isEmpty) return true;
      final haystack = [
        item.product.name,
        item.product.brand ?? '',
        item.variant.name,
        item.product.description ?? '',
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();

    final grouped = <String, List<StoreInventoryItem>>{};
    for (final item in filtered) {
      grouped.putIfAbsent(item.product.id, () => []).add(item);
    }
    final groups = grouped.entries
        .map((entry) => StoreGroup(
              product: entry.value.first.product,
              items: entry.value,
            ))
        .toList();
    groups.sort((a, b) => a.product.name.compareTo(b.product.name));
    return groups;
  }

  Future<void> _startCheckout() async {
    final store = _store;
    if (store == null) return;
    final cart = ref.read(storeCartControllerProvider);
    if (cart.items.isEmpty) return;

    final addressController = TextEditingController(
      text: widget.initialArgs?.location?.city?.trim().isNotEmpty == true
          ? '${widget.initialArgs!.location!.city}, '
          : '',
    );
    final notesController = TextEditingController();

    final result = await showModalBottomSheet<_CheckoutDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _CheckoutSheet(
          subtotalPaise: cart.subtotalPaise,
          addressController: addressController,
          notesController: notesController,
          onConfirm: () {
            final address = addressController.text.trim();
            if (address.isEmpty) return;
            Navigator.of(context).pop(
              _CheckoutDraft(
                address: address,
                notes: notesController.text.trim(),
              ),
            );
          },
        );
      },
    );

    addressController.dispose();
    notesController.dispose();

    if (result == null) return;

    setState(() => _isCheckingOut = true);
    final repository = ref.read(storeRepositoryProvider);
    final paymentService = ref.read(storePaymentServiceProvider);
    try {
      final order = await repository.createOrder(
        storeId: store.id,
        items: cart.items
            .map((item) => {
                  'productVariantId': item.inventory.productVariantId,
                  'quantity': item.quantity,
                })
            .toList(),
        deliveryAddress: result.address,
        deliveryLat: widget.initialArgs?.location?.latitude,
        deliveryLng: widget.initialArgs?.location?.longitude,
        notes: result.notes,
      );
      _pendingOrderId = order.id;
      final payment = await paymentService.createStoreOrderPayment(order.id);
      if (payment.amountPaise <= 0 || payment.orderId.isEmpty) {
        throw Exception('This order could not be opened for payment.');
      }
      _razorpay.open({
        'key': payment.key,
        'amount': payment.amountPaise,
        'currency': payment.currency,
        'name': 'Swing Store',
        'description': 'Order from ${store.name}',
        'order_id': payment.orderId,
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isCheckingOut = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(repository.messageFor(error))),
      );
    }
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
    final orderId = _pendingOrderId;
    if (orderId == null) return;
    try {
      await ref.read(storePaymentServiceProvider).verifyStoreOrderPayment(
            orderId: response.orderId ?? '',
            paymentId: response.paymentId ?? '',
            signature: response.signature ?? '',
          );
      ref.read(storeCartControllerProvider.notifier).clear();
      if (!mounted) return;
      context.push('/store-order/$orderId');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully')),
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
        setState(() => _isCheckingOut = false);
      }
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    final orderId = _pendingOrderId;
    if (mounted) {
      setState(() => _isCheckingOut = false);
    }
    if (!mounted) return;
    final message = response.message?.trim().isNotEmpty == true
        ? response.message!.trim()
        : 'Payment was not completed.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$message You can retry from the order screen.')),
    );
    if (orderId != null) {
      context.push('/store-order/$orderId');
    }
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${response.walletName ?? 'Wallet'} selected'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = _store;
    final cart = ref.watch(storeCartControllerProvider);
    final storeCart = cart.storeId == store?.id ? cart : const StoreCartState();

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        titleSpacing: 16,
        title: Text(
          store?.name ?? widget.initialArgs?.store.name ?? 'Store',
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
              : store == null
                  ? const SizedBox.shrink()
                  : Stack(
                      children: [
                        ListView(
                          padding: EdgeInsets.fromLTRB(
                            16,
                            8,
                            16,
                            storeCart.isEmpty ? 32 : 118,
                          ),
                          children: [
                            _StoreHeaderCard(store: store),
                            const SizedBox(height: 14),
                            _StoreSearchBar(controller: _searchController),
                            if (_categories.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              SizedBox(
                                height: 42,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _categories.length + 1,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 8),
                                  itemBuilder: (context, index) {
                                    if (index == 0) {
                                      return _FilterChip(
                                        label: 'All',
                                        active: _selectedCategoryId == null,
                                        onTap: () {
                                          setState(
                                              () => _selectedCategoryId = null);
                                        },
                                      );
                                    }
                                    final category = _categories[index - 1];
                                    return _FilterChip(
                                      label: category.name,
                                      active:
                                          _selectedCategoryId == category.id,
                                      onTap: () {
                                        setState(() {
                                          _selectedCategoryId =
                                              _selectedCategoryId == category.id
                                                  ? null
                                                  : category.id;
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                            const SizedBox(height: 18),
                            ..._groups.map(
                              (group) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _StoreProductGroupCard(
                                  store: store,
                                  group: group,
                                ),
                              ),
                            ),
                            if (_groups.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: context.cardBg,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(color: context.stroke),
                                ),
                                child: Text(
                                  'No products match this filter yet.',
                                  style: TextStyle(color: context.fgSub),
                                ),
                              ),
                          ],
                        ),
                        if (!storeCart.isEmpty)
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: _CartFooter(
                              state: storeCart,
                              isLoading: _isCheckingOut,
                              onTap: _startCheckout,
                            ),
                          ),
                      ],
                    ),
    );
  }
}

class _StoreHeaderCard extends StatelessWidget {
  const _StoreHeaderCard({required this.store});

  final StoreListing store;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: context.stroke),
      ),
      child: Row(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                colors: [
                  context.accent.withValues(alpha: 0.24),
                  context.gold.withValues(alpha: 0.18),
                ],
              ),
            ),
            child: Icon(Icons.storefront_rounded, color: context.fg, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.name,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  store.description ?? store.address,
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoPill(
                      icon: Icons.location_on_outlined,
                      label: store.shortAddress,
                    ),
                    const _InfoPill(
                      icon: Icons.flash_on_rounded,
                      label: 'Fast local delivery',
                    ),
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

class _StoreSearchBar extends StatelessWidget {
  const _StoreSearchBar({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.stroke),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Search inside this store',
          hintStyle: TextStyle(color: context.fgSub, fontSize: 13),
          prefixIcon: Icon(Icons.search_rounded, color: context.fgSub),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? context.accent : context.cardBg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? context.accent : context.stroke),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : context.fgSub,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _StoreProductGroupCard extends ConsumerWidget {
  const _StoreProductGroupCard({
    required this.store,
    required this.group,
  });

  final StoreListing store;
  final StoreGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: context.panel,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: group.product.imageUrl?.isNotEmpty == true
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.network(
                          group.product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.inventory_2_outlined,
                            color: context.fgSub,
                          ),
                        ),
                      )
                    : Icon(Icons.inventory_2_outlined, color: context.fgSub),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.product.name,
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if ((group.product.brand ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        group.product.brand!,
                        style: TextStyle(
                          color: context.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    if ((group.product.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        group.product.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.fgSub,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...group.items.map((item) => Padding(
                padding: const EdgeInsets.only(top: 10),
                child: _VariantRow(store: store, item: item),
              )),
        ],
      ),
    );
  }
}

class _VariantRow extends ConsumerWidget {
  const _VariantRow({
    required this.store,
    required this.item,
  });

  final StoreListing store;
  final StoreInventoryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(storeCartControllerProvider);
    final quantity = cart.storeId == store.id ? cart.quantityFor(item.id) : 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.panel,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.variant.name,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      NumberFormat.currency(
                        locale: 'en_IN',
                        symbol: 'Rs ',
                        decimalDigits: 0,
                      ).format(item.effectivePricePaise / 100),
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (item.hasDiscount) ...[
                      const SizedBox(width: 6),
                      Text(
                        NumberFormat.currency(
                          locale: 'en_IN',
                          symbol: 'Rs ',
                          decimalDigits: 0,
                        ).format(item.pricePaise / 100),
                        style: TextStyle(
                          color: context.fgSub,
                          fontSize: 11,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                    const SizedBox(width: 10),
                    Text(
                      item.isInStock ? '${item.quantity} left' : 'Out of stock',
                      style: TextStyle(
                        color:
                            item.isInStock ? context.success : context.danger,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          quantity <= 0
              ? _AddButton(store: store, item: item)
              : _Stepper(store: store, item: item, quantity: quantity),
        ],
      ),
    );
  }
}

class _AddButton extends ConsumerWidget {
  const _AddButton({
    required this.store,
    required this.item,
  });

  final StoreListing store;
  final StoreInventoryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: item.isInStock
          ? () {
              final result = ref
                  .read(storeCartControllerProvider.notifier)
                  .addItem(store: store, inventory: item);
              if (result == StoreCartMutationResult.blockedByAnotherStore) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Finish or clear the current store cart before switching stores.',
                    ),
                  ),
                );
              }
            }
          : null,
      child: Container(
        width: 78,
        height: 36,
        decoration: BoxDecoration(
          color: item.isInStock ? context.accent : context.stroke,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'ADD',
            style: TextStyle(
              color: Colors.white.withValues(alpha: item.isInStock ? 1 : 0.6),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _Stepper extends ConsumerWidget {
  const _Stepper({
    required this.store,
    required this.item,
    required this.quantity,
  });

  final StoreListing store;
  final StoreInventoryItem item;
  final int quantity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(storeCartControllerProvider.notifier);
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: context.accent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: Icons.remove_rounded,
            onTap: () =>
                controller.decrementItem(store: store, inventory: item),
          ),
          SizedBox(
            width: 28,
            child: Center(
              child: Text(
                '$quantity',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.add_rounded,
            onTap: quantity >= item.quantity
                ? null
                : () => controller.addItem(store: store, inventory: item),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 32,
        child: Icon(
          icon,
          size: 16,
          color: Colors.white.withValues(alpha: onTap == null ? 0.45 : 1),
        ),
      ),
    );
  }
}

class _CartFooter extends StatelessWidget {
  const _CartFooter({
    required this.state,
    required this.isLoading,
    required this.onTap,
  });

  final StoreCartState state;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${state.itemCount} item${state.itemCount == 1 ? '' : 's'} in cart',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  NumberFormat.currency(
                    locale: 'en_IN',
                    symbol: 'Rs ',
                    decimalDigits: 0,
                  ).format(state.subtotalPaise / 100),
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: isLoading ? null : onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Checkout',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutSheet extends StatelessWidget {
  const _CheckoutSheet({
    required this.subtotalPaise,
    required this.addressController,
    required this.notesController,
    required this.onConfirm,
  });

  final int subtotalPaise;
  final TextEditingController addressController;
  final TextEditingController notesController;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confirm delivery',
            style: TextStyle(
              color: context.fg,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: addressController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Delivery address',
              hintText: 'Flat, street, landmark, city',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: notesController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Notes',
              hintText: 'Gate, landmark, delivery note',
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pay ${NumberFormat.currency(locale: 'en_IN', symbol: 'Rs ', decimalDigits: 0).format(subtotalPaise / 100)}',
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: onConfirm,
                child: const Text('Continue to pay'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CheckoutDraft {
  const _CheckoutDraft({
    required this.address,
    required this.notes,
  });

  final String address;
  final String notes;
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: context.panel,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: context.fgSub),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
