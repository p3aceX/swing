import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/store_models.dart';

enum StoreCartMutationResult {
  added,
  updated,
  removed,
  blockedByAnotherStore,
}

class StoreCartItem {
  const StoreCartItem({
    required this.inventory,
    required this.quantity,
  });

  final StoreInventoryItem inventory;
  final int quantity;

  int get totalPricePaise => inventory.effectivePricePaise * quantity;

  StoreCartItem copyWith({
    StoreInventoryItem? inventory,
    int? quantity,
  }) {
    return StoreCartItem(
      inventory: inventory ?? this.inventory,
      quantity: quantity ?? this.quantity,
    );
  }
}

class StoreCartState {
  const StoreCartState({
    this.storeId,
    this.storeName,
    this.items = const [],
  });

  final String? storeId;
  final String? storeName;
  final List<StoreCartItem> items;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  int get subtotalPaise =>
      items.fold(0, (sum, item) => sum + item.totalPricePaise);
  bool get isEmpty => items.isEmpty;

  int quantityFor(String inventoryId) {
    for (final item in items) {
      if (item.inventory.id == inventoryId) return item.quantity;
    }
    return 0;
  }

  StoreCartState copyWith({
    String? storeId,
    String? storeName,
    List<StoreCartItem>? items,
  }) {
    return StoreCartState(
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      items: items ?? this.items,
    );
  }
}

class StoreCartController extends StateNotifier<StoreCartState> {
  StoreCartController() : super(const StoreCartState());

  StoreCartMutationResult addItem({
    required StoreListing store,
    required StoreInventoryItem inventory,
  }) {
    if (!inventory.isInStock) return StoreCartMutationResult.removed;
    if (state.storeId != null &&
        state.storeId != store.id &&
        state.items.isNotEmpty) {
      return StoreCartMutationResult.blockedByAnotherStore;
    }

    final current = state.quantityFor(inventory.id);
    return setQuantity(
      store: store,
      inventory: inventory,
      quantity: current + 1,
    );
  }

  StoreCartMutationResult decrementItem({
    required StoreListing store,
    required StoreInventoryItem inventory,
  }) {
    final current = state.quantityFor(inventory.id);
    if (current <= 0) return StoreCartMutationResult.removed;
    return setQuantity(
      store: store,
      inventory: inventory,
      quantity: current - 1,
    );
  }

  StoreCartMutationResult setQuantity({
    required StoreListing store,
    required StoreInventoryItem inventory,
    required int quantity,
  }) {
    if (state.storeId != null &&
        state.storeId != store.id &&
        state.items.isNotEmpty) {
      return StoreCartMutationResult.blockedByAnotherStore;
    }

    final nextItems = [...state.items];
    final index =
        nextItems.indexWhere((item) => item.inventory.id == inventory.id);
    if (quantity <= 0) {
      if (index >= 0) {
        nextItems.removeAt(index);
      }
      state = state.copyWith(
        storeId: nextItems.isEmpty ? null : store.id,
        storeName: nextItems.isEmpty ? null : store.name,
        items: nextItems,
      );
      return StoreCartMutationResult.removed;
    }

    final safeQuantity =
        quantity > inventory.quantity ? inventory.quantity : quantity;
    final item = StoreCartItem(inventory: inventory, quantity: safeQuantity);
    if (index >= 0) {
      nextItems[index] = item;
    } else {
      nextItems.add(item);
    }
    state = StoreCartState(
      storeId: store.id,
      storeName: store.name,
      items: nextItems,
    );
    return index >= 0
        ? StoreCartMutationResult.updated
        : StoreCartMutationResult.added;
  }

  void clear() => state = const StoreCartState();
}

final storeCartControllerProvider =
    StateNotifierProvider<StoreCartController, StoreCartState>(
  (ref) => StoreCartController(),
);
