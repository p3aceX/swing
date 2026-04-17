import 'package:flutter/foundation.dart';

@immutable
class StorefrontLocation {
  const StorefrontLocation({
    this.city,
    this.latitude,
    this.longitude,
  });

  final String? city;
  final double? latitude;
  final double? longitude;
}

@immutable
class StoreCategory {
  const StoreCategory({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
  });

  final String id;
  final String name;
  final String? description;
  final String? iconUrl;
}

@immutable
class StoreListing {
  const StoreListing({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    this.description,
    this.latitude,
    this.longitude,
    this.isFeatured = false,
  });

  final String id;
  final String name;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String? description;
  final double? latitude;
  final double? longitude;
  final bool isFeatured;

  String get shortAddress => '$city, $state';
}

@immutable
class StoreProduct {
  const StoreProduct({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    this.brand,
    this.imageUrl,
    this.tags = const [],
  });

  final String id;
  final String categoryId;
  final String name;
  final String? description;
  final String? brand;
  final String? imageUrl;
  final List<String> tags;
}

@immutable
class StoreProductVariant {
  const StoreProductVariant({
    required this.id,
    required this.productId,
    required this.name,
    this.sku,
    this.imageUrl,
    this.attributes = const {},
  });

  final String id;
  final String productId;
  final String name;
  final String? sku;
  final String? imageUrl;
  final Map<String, dynamic> attributes;
}

@immutable
class StoreInventoryItem {
  const StoreInventoryItem({
    required this.id,
    required this.storeId,
    required this.productVariantId,
    required this.quantity,
    required this.pricePaise,
    this.discountPricePaise,
    required this.isActive,
    required this.variant,
    required this.product,
  });

  final String id;
  final String storeId;
  final String productVariantId;
  final int quantity;
  final int pricePaise;
  final int? discountPricePaise;
  final bool isActive;
  final StoreProductVariant variant;
  final StoreProduct product;

  int get effectivePricePaise => discountPricePaise ?? pricePaise;
  bool get isInStock => quantity > 0 && isActive;
  bool get hasDiscount =>
      discountPricePaise != null && discountPricePaise! < pricePaise;
  String get imageUrl => variant.imageUrl ?? product.imageUrl ?? '';
}

@immutable
class StoreGroup {
  const StoreGroup({
    required this.product,
    required this.items,
  });

  final StoreProduct product;
  final List<StoreInventoryItem> items;
}

@immutable
class StoreOrder {
  const StoreOrder({
    required this.id,
    required this.storeId,
    required this.userId,
    required this.status,
    required this.totalAmountPaise,
    required this.finalAmountPaise,
    required this.deliveryAddress,
    required this.items,
    required this.store,
    this.deliveryFeePaise = 0,
    this.taxAmountPaise = 0,
    this.discountAmountPaise = 0,
    this.paymentId,
    this.deliveryLat,
    this.deliveryLng,
    this.notes,
    this.delivery,
    this.invoice,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String storeId;
  final String userId;
  final String status;
  final int totalAmountPaise;
  final int finalAmountPaise;
  final int deliveryFeePaise;
  final int taxAmountPaise;
  final int discountAmountPaise;
  final String? paymentId;
  final String deliveryAddress;
  final double? deliveryLat;
  final double? deliveryLng;
  final String? notes;
  final List<StoreOrderItem> items;
  final StoreListing store;
  final DeliveryTracking? delivery;
  final StoreInvoice? invoice;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isActive =>
      !{'DELIVERED', 'CANCELLED'}.contains(status.toUpperCase());
  bool get isPayable => status.toUpperCase() == 'PENDING';
}

@immutable
class StoreOrderItem {
  const StoreOrderItem({
    required this.id,
    required this.productVariantId,
    required this.quantity,
    required this.pricePaise,
    required this.totalPricePaise,
    required this.variant,
  });

  final String id;
  final String productVariantId;
  final int quantity;
  final int pricePaise;
  final int totalPricePaise;
  final StoreProductVariantSnapshot variant;
}

@immutable
class StoreProductVariantSnapshot {
  const StoreProductVariantSnapshot({
    required this.id,
    required this.name,
    required this.product,
    this.imageUrl,
  });

  final String id;
  final String name;
  final StoreProductSnapshot product;
  final String? imageUrl;
}

@immutable
class StoreProductSnapshot {
  const StoreProductSnapshot({
    required this.id,
    required this.name,
    this.brand,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String? brand;
  final String? imageUrl;
}

@immutable
class DeliveryTracking {
  const DeliveryTracking({
    required this.id,
    required this.status,
    this.trackingUrl,
    this.estimatedDelivery,
    this.assignedAt,
    this.pickedUpAt,
    this.deliveredAt,
  });

  final String id;
  final String status;
  final String? trackingUrl;
  final DateTime? estimatedDelivery;
  final DateTime? assignedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
}

@immutable
class StoreInvoice {
  const StoreInvoice({
    required this.id,
    required this.invoiceNumber,
    this.invoiceUrl,
    this.issuedAt,
  });

  final String id;
  final String invoiceNumber;
  final String? invoiceUrl;
  final DateTime? issuedAt;
}

@immutable
class StorePaymentOrder {
  const StorePaymentOrder({
    required this.paymentId,
    required this.orderId,
    required this.amountPaise,
    required this.currency,
    required this.key,
  });

  final String paymentId;
  final String orderId;
  final int amountPaise;
  final String currency;
  final String? key;
}

@immutable
class StoreScreenArgs {
  const StoreScreenArgs({
    required this.store,
    this.location,
    this.preferredCategoryId,
  });

  final StoreListing store;
  final StorefrontLocation? location;
  final String? preferredCategoryId;
}
