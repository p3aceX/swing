import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../controller/store_cart_controller.dart';
import '../data/store_repository.dart';
import '../domain/store_models.dart';

final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  return StoreRepository();
});

class StorefrontScreen extends ConsumerStatefulWidget {
  const StorefrontScreen({super.key, this.location});

  final StorefrontLocation? location;

  @override
  ConsumerState<StorefrontScreen> createState() => _StorefrontScreenState();
}

class _StorefrontScreenState extends ConsumerState<StorefrontScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _error;
  List<StoreListing> _stores = const [];
  List<_FrontStoreProduct> _products = const [];
  List<StoreOrder> _recentOrders = const [];
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
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
        repository.searchStores(
          city: widget.location?.city,
          latitude: widget.location?.latitude,
          longitude: widget.location?.longitude,
        ),
        repository.listRecentOrders(),
      ]);
      final stores = results[0] as List<StoreListing>;
      final products = await _loadProducts(
        stores: stores,
        repository: repository,
      );
      if (!mounted) return;
      setState(() {
        _stores = stores;
        _products = products;
        _recentOrders = results[1] as List<StoreOrder>;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = repository.messageFor(
          error,
          fallback: 'Could not load the store right now.',
        );
        _isLoading = false;
      });
    }
  }

  Future<List<_FrontStoreProduct>> _loadProducts({
    required List<StoreListing> stores,
    required StoreRepository repository,
  }) async {
    final storefrontStores = stores.take(12).toList();
    final inventoryResults = await Future.wait(
      storefrontStores.map((store) async {
        try {
          final items = await repository.getStoreInventory(store.id);
          return items
              .where((item) => item.isActive)
              .map((item) => _FrontStoreProduct(store: store, inventory: item))
              .toList();
        } catch (_) {
          return const <_FrontStoreProduct>[];
        }
      }),
    );
    final products = inventoryResults.expand((items) => items).toList();
    products.sort((a, b) {
      final aScore = (a.inventory.isInStock ? 1000 : 0) +
          (a.inventory.hasDiscount ? 100 : 0) +
          (a.store.isFeatured ? 10 : 0);
      final bScore = (b.inventory.isInStock ? 1000 : 0) +
          (b.inventory.hasDiscount ? 100 : 0) +
          (b.store.isFeatured ? 10 : 0);
      if (aScore != bScore) return bScore.compareTo(aScore);
      return a.inventory.product.name.compareTo(b.inventory.product.name);
    });
    return products;
  }

  List<_FrontStoreProduct> get _visibleProducts {
    final query = _searchController.text.trim().toLowerCase();
    return _products.where((entry) {
      if (_selectedCategoryId != null) {
        final category = _frontCategories.firstWhere(
          (item) => item.id == _selectedCategoryId,
          orElse: () => _allCategory,
        );
        if (!_matchesCategory(entry.inventory, category)) {
          return false;
        }
      }
      if (query.isEmpty) return true;
      final haystack = [
        entry.inventory.product.name,
        entry.inventory.product.brand ?? '',
        entry.inventory.product.description ?? '',
        entry.inventory.variant.name,
        entry.store.name,
        ...entry.inventory.product.tags,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  bool _matchesCategory(StoreInventoryItem inventory, _FrontCategory category) {
    if (category.id == _allCategory.id) return true;
    final haystack = [
      inventory.product.name,
      inventory.product.brand ?? '',
      inventory.product.description ?? '',
      inventory.variant.name,
      inventory.product.categoryId,
      ...inventory.product.tags,
    ].join(' ').toLowerCase();
    return category.keywords.any(haystack.contains);
  }

  void _openStore(StoreListing store) {
    context.push(
      '/storefront/${store.id}',
      extra: StoreScreenArgs(
        store: store,
        location: widget.location,
        preferredCategoryId: null,
      ),
    );
  }

  void _updateCart({
    required StoreListing store,
    required StoreInventoryItem inventory,
    required bool increment,
  }) {
    final notifier = ref.read(storeCartControllerProvider.notifier);
    final result = increment
        ? notifier.addItem(store: store, inventory: inventory)
        : notifier.decrementItem(store: store, inventory: inventory);
    if (result == StoreCartMutationResult.blockedByAnotherStore) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Finish or clear the current store cart first.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(storeCartControllerProvider);
    StoreListing? cartStore;
    if (cart.storeId != null) {
      for (final store in _stores) {
        if (store.id == cart.storeId) {
          cartStore = store;
          break;
        }
      }
    }
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Swing Store',
              style: TextStyle(
                color: context.fg,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              widget.location?.city?.trim().isNotEmpty == true
                  ? 'Fast cricket picks in ${widget.location!.city}'
                  : 'Gear, supplements and training essentials',
              style: TextStyle(
                color: context.fgSub,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _StorefrontErrorState(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                    children: [
                      _SearchBar(controller: _searchController),
                      const SizedBox(height: 16),
                      _StorefrontHero(
                        orderCount:
                            _recentOrders.where((o) => o.isActive).length,
                      ),
                      const SizedBox(height: 18),
                      const _SectionTitle('Shop By Category'),
                      const SizedBox(height: 10),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          const spacing = 10.0;
                          final tileWidth =
                              (constraints.maxWidth - (spacing * 2)) / 3;
                          return Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            children: _frontCategories.map((category) {
                              final active = _selectedCategoryId == category.id;
                              return SizedBox(
                                width: tileWidth,
                                height: 104,
                                child: _CategoryTile(
                                  category: category,
                                  isActive: active,
                                  onTap: () {
                                    setState(() {
                                      _selectedCategoryId =
                                          active ? null : category.id;
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      const _PromoBanner(),
                      const SizedBox(height: 18),
                      const _FirstPurchaseBanner(),
                      const SizedBox(height: 22),
                      const _SectionTitle('Featured Products'),
                      const SizedBox(height: 6),
                      Text(
                        'Quick picks from academy stores and local sports shops.',
                        style: TextStyle(
                          color: context.fgSub,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_visibleProducts.isEmpty)
                        const _EmptyStoreState()
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _visibleProducts.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.68,
                          ),
                          itemBuilder: (context, index) {
                            final entry = _visibleProducts[index];
                            return _ProductCard(
                              entry: entry,
                              quantity: cart.quantityFor(entry.inventory.id),
                              onTap: () => _openStore(entry.store),
                              onAdd: () => _updateCart(
                                store: entry.store,
                                inventory: entry.inventory,
                                increment: true,
                              ),
                              onRemove: () => _updateCart(
                                store: entry.store,
                                inventory: entry.inventory,
                                increment: false,
                              ),
                            );
                          },
                        ),
                      if (cartStore != null && cart.items.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Builder(
                          builder: (context) {
                            final activeStore = cartStore!;
                            return _CartDock(
                              cart: cart,
                              onTap: () => _openStore(activeStore),
                            );
                          },
                        ),
                      ],
                      if (_recentOrders.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const _SectionTitle('Track Orders'),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 122,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final order = _recentOrders[index];
                              return _OrderRailCard(order: order);
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemCount: _recentOrders.length,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
          const _StoreComingSoonOverlay(),
        ],
      ),
    );
  }
}

class _StorefrontHero extends StatelessWidget {
  const _StorefrontHero({required this.orderCount});

  final int orderCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF173629),
            Color.alphaBlend(
              context.accent.withValues(alpha: 0.25),
              context.panel,
            ),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: context.accent.withValues(alpha: 0.14),
            blurRadius: 22,
            offset: const Offset(0, 14),
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
                  'QUICK CRICKET COMMERCE',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Buy match gear\nlike groceries.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  orderCount > 0
                      ? '$orderCount live store order${orderCount == 1 ? '' : 's'} moving right now.'
                      : 'Bats, balls, supplements and training essentials from local academy stores.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.84),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: const Icon(
              Icons.shopping_bag_rounded,
              size: 36,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.stroke),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Search bats, balls, supplements, grips',
          hintStyle: TextStyle(color: context.fgSub, fontSize: 13),
          prefixIcon: Icon(Icons.search_rounded, color: context.fgSub),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        style: TextStyle(color: context.fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3C2415),
            Color(0xFF7D3E1D),
            Color(0xFFCB6A2E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCB6A2E).withValues(alpha: 0.24),
            blurRadius: 20,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'MATCH DAY DROP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Power hitting kits, recovery fuel and quick-grab essentials.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Exclusive academy deals, fast local dispatch and athlete-first picks.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.84),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 82,
            height: 98,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: const Icon(
              Icons.campaign_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }
}

class _FirstPurchaseBanner extends StatelessWidget {
  const _FirstPurchaseBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: context.stroke),
        gradient: LinearGradient(
          colors: [
            context.accent.withValues(alpha: 0.16),
            context.gold.withValues(alpha: 0.18),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FLAT 30% OFF',
                  style: TextStyle(
                    color: context.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'First purchase advantage for every player.',
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Grab your first local order with a stronger launch offer.',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.44),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.local_offer_rounded,
              color: context.accent,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: context.fg,
        fontSize: 18,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.3,
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.isActive,
    required this.onTap,
  });

  final _FrontCategory category;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 102,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive
              ? category.color.withValues(alpha: 0.22)
              : context.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? category.color : context.stroke,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive
                    ? category.color.withValues(alpha: 0.18)
                    : context.panel,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                category.icon,
                color: isActive ? category.color : context.fg,
                size: 20,
              ),
            ),
            Text(
              category.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isActive ? context.fg : context.fgSub,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.entry,
    required this.quantity,
    required this.onTap,
    required this.onAdd,
    required this.onRemove,
  });

  final _FrontStoreProduct entry;
  final int quantity;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final item = entry.inventory;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.stroke),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: [
                          context.accent.withValues(alpha: 0.18),
                          context.sky.withValues(alpha: 0.12),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: item.imageUrl.trim().isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _ProductFallback(
                                productName: item.product.name,
                              ),
                            ),
                          )
                        : _ProductFallback(productName: item.product.name),
                  ),
                  if (item.hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: context.success.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'SAVE ${_discountPercent(item)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.fg,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.variant.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.fgSub,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              entry.store.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.accent,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _money(item.effectivePricePaise),
                        style: TextStyle(
                          color: context.fg,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (item.hasDiscount)
                        Text(
                          _money(item.pricePaise),
                          style: TextStyle(
                            color: context.fgSub,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                ),
                if (!item.isInStock)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: context.panel,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Sold Out',
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                else if (quantity > 0)
                  Container(
                    decoration: BoxDecoration(
                      color: context.panel,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: onRemove,
                          icon: Icon(
                            Icons.remove_rounded,
                            color: context.fg,
                            size: 18,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        Text(
                          '$quantity',
                          style: TextStyle(
                            color: context.fg,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        IconButton(
                          onPressed: onAdd,
                          icon: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: context.accent,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  FilledButton(
                    onPressed: onAdd,
                    style: FilledButton.styleFrom(
                      backgroundColor: context.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    child: const Text('ADD'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductFallback extends StatelessWidget {
  const _ProductFallback({required this.productName});

  final String productName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        _iconForProductName(productName),
        size: 34,
        color: context.fg,
      ),
    );
  }
}

class _OrderRailCard extends StatelessWidget {
  const _OrderRailCard({required this.order});

  final StoreOrder order;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/store-order/${order.id}'),
      child: Container(
        width: 228,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: context.stroke),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatusPill(status: order.status),
                const Spacer(),
                Text(
                  _money(order.finalAmountPaise),
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              order.store.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.fg,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${order.items.length} item${order.items.length == 1 ? '' : 's'} · ${_relativeTime(order.createdAt)}',
              style: TextStyle(
                color: context.fgSub,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              order.delivery?.estimatedDelivery != null
                  ? 'ETA ${DateFormat('h:mm a').format(order.delivery!.estimatedDelivery!.toLocal())}'
                  : 'Tap for live order details',
              style: TextStyle(
                color: context.accent,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartDock extends StatelessWidget {
  const _CartDock({
    required this.cart,
    required this.onTap,
  });

  final StoreCartState cart;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.accent,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: context.accent.withValues(alpha: 0.22),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.shopping_bag_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${cart.itemCount} item${cart.itemCount == 1 ? '' : 's'} ready',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Open cart and continue checkout',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.84),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _money(cart.subtotalPaise),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StorefrontErrorState extends StatelessWidget {
  const _StorefrontErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront_outlined, color: context.fgSub, size: 42),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.fg),
            ),
            const SizedBox(height: 14),
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

class _EmptyStoreState extends StatelessWidget {
  const _EmptyStoreState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, color: context.fgSub, size: 36),
          const SizedBox(height: 12),
          Text(
            'No products match this filter yet.',
            style: TextStyle(
              color: context.fg,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try another search or category. New local stock will appear here as stores update inventory.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase();
    final Color color = switch (normalized) {
      'DELIVERED' => context.success,
      'DISPATCHED' || 'READY' => context.sky,
      'PREPARING' || 'PAID' => context.gold,
      'CANCELLED' => context.danger,
      _ => context.warn,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        normalized,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _FrontStoreProduct {
  const _FrontStoreProduct({
    required this.store,
    required this.inventory,
  });

  final StoreListing store;
  final StoreInventoryItem inventory;
}

class _FrontCategory {
  const _FrontCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.keywords,
  });

  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final List<String> keywords;
}

const _FrontCategory _allCategory = _FrontCategory(
  id: 'all',
  label: 'All Gear',
  icon: Icons.grid_view_rounded,
  color: Color(0xFF2D9CDB),
  keywords: [],
);

const List<_FrontCategory> _frontCategories = [
  _allCategory,
  _FrontCategory(
    id: 'bat',
    label: 'Bat',
    icon: Icons.sports_cricket_rounded,
    color: Color(0xFFB66A28),
    keywords: ['bat', 'english willow', 'kashmir willow', 'blade'],
  ),
  _FrontCategory(
    id: 'ball',
    label: 'Ball',
    icon: Icons.sports_baseball_rounded,
    color: Color(0xFFC43A30),
    keywords: ['ball', 'leather', 'tennis ball', 'season'],
  ),
  _FrontCategory(
    id: 'accessories',
    label: 'Cricket Accessories',
    icon: Icons.inventory_2_rounded,
    color: Color(0xFF7B61FF),
    keywords: ['grip', 'guard', 'helmet', 'glove', 'pad', 'bag', 'accessor'],
  ),
  _FrontCategory(
    id: 'supplements',
    label: 'Protein & Supplement',
    icon: Icons.local_drink_rounded,
    color: Color(0xFF2E9E5B),
    keywords: ['protein', 'supplement', 'whey', 'hydration', 'electrolyte'],
  ),
  _FrontCategory(
    id: 'fitness',
    label: 'Fitness & Training',
    icon: Icons.fitness_center_rounded,
    color: Color(0xFFE09F1F),
    keywords: ['fitness', 'training', 'resistance', 'strength', 'mobility'],
  ),
];

int _discountPercent(StoreInventoryItem item) {
  if (!item.hasDiscount || item.pricePaise <= 0) return 0;
  return (((item.pricePaise - item.effectivePricePaise) / item.pricePaise) *
          100)
      .round();
}

IconData _iconForProductName(String value) {
  final name = value.toLowerCase();
  if (name.contains('bat')) return Icons.sports_cricket_rounded;
  if (name.contains('ball')) return Icons.sports_baseball_rounded;
  if (name.contains('protein') ||
      name.contains('supplement') ||
      name.contains('shake')) {
    return Icons.local_drink_rounded;
  }
  if (name.contains('fitness') ||
      name.contains('training') ||
      name.contains('band')) {
    return Icons.fitness_center_rounded;
  }
  return Icons.inventory_2_rounded;
}

String _money(int paise) => NumberFormat.currency(
      locale: 'en_IN',
      symbol: 'Rs ',
      decimalDigits: 0,
    ).format(paise / 100);

String _relativeTime(DateTime? value) {
  if (value == null) return 'Recently';
  final diff = DateTime.now().difference(value.toLocal());
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hr ago';
  return '${diff.inDays} day ago';
}

class _StoreComingSoonOverlay extends StatelessWidget {
  const _StoreComingSoonOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.94),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15), width: 1.5),
                    ),
                    child: const Icon(Icons.storefront_rounded,
                        color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Store Coming Soon',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Great things take time.\nKeep playing — every match earns you IP that unlocks exclusive store rewards the moment we go live.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.offline_bolt_rounded,
                            color: Color(0xFFFFD700), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Your IP is your head start',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
