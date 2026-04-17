import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../domain/store_models.dart';

class StoreRepository {
  final _client = ApiClient.instance.dio;

  Future<List<StoreCategory>> listCategories() async {
    try {
      final response = await _client.get(ApiEndpoints.storeCategories);
      return _unwrapList(response.data).map(_mapCategory).toList();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return const [];
      }
      rethrow;
    }
  }

  Future<List<StoreListing>> searchStores({
    String? city,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.storeSearch,
        queryParameters: {
          if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
          if (latitude != null) 'lat': latitude,
          if (longitude != null) 'lng': longitude,
        },
      );
      return _unwrapList(response.data).map(_mapStore).toList();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return const [];
      }
      rethrow;
    }
  }

  Future<StoreListing> getStore(String storeId) async {
    final response = await _client.get(ApiEndpoints.storeById(storeId));
    return _mapStore(_unwrapMap(response.data));
  }

  Future<List<StoreInventoryItem>> getStoreInventory(String storeId) async {
    final response = await _client.get(ApiEndpoints.storeInventory(storeId));
    return _unwrapList(response.data).map(_mapInventoryItem).toList();
  }

  Future<StoreOrder> createOrder({
    required String storeId,
    required List<Map<String, dynamic>> items,
    required String deliveryAddress,
    double? deliveryLat,
    double? deliveryLng,
    String? notes,
  }) async {
    final response = await _client.post(
      ApiEndpoints.storeOrders,
      data: {
        'storeId': storeId,
        'items': items,
        'deliveryAddress': deliveryAddress,
        if (deliveryLat != null) 'deliveryLat': deliveryLat,
        if (deliveryLng != null) 'deliveryLng': deliveryLng,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
    );
    return _mapOrder(_unwrapMap(response.data));
  }

  Future<StoreOrder> getOrder(String orderId) async {
    final response = await _client.get(ApiEndpoints.storeOrderById(orderId));
    return _mapOrder(_unwrapMap(response.data));
  }

  Future<List<StoreOrder>> listRecentOrders({int limit = 8}) async {
    final response = await _client.get(
      ApiEndpoints.payments,
      queryParameters: {'page': 1, 'limit': limit * 2},
    );
    final data = _unwrapMap(response.data);
    final payments = _unwrapList(data['payments']);
    final orderIds = payments
        .whereType<Map<String, dynamic>>()
        .where((payment) => (payment['entityType'] as String?) == 'STORE_ORDER')
        .map((payment) => payment['entityId'] as String?)
        .whereType<String>()
        .toSet()
        .take(limit)
        .toList();

    final orders = <StoreOrder>[];
    for (final id in orderIds) {
      try {
        orders.add(await getOrder(id));
      } catch (_) {}
    }
    orders.sort((a, b) {
      final left = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final right = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return right.compareTo(left);
    });
    return orders;
  }

  String messageFor(Object error, {String fallback = 'Something went wrong.'}) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final nested = data['error'];
        if (nested is Map<String, dynamic> &&
            nested['message'] is String &&
            (nested['message'] as String).trim().isNotEmpty) {
          return (nested['message'] as String).trim();
        }
        if (data['message'] is String &&
            (data['message'] as String).trim().isNotEmpty) {
          return (data['message'] as String).trim();
        }
      }
      return error.message ?? fallback;
    }
    final text = error.toString().trim();
    return text.isEmpty ? fallback : text.replaceFirst('Exception: ', '');
  }

  List<dynamic> _unwrapList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      final inner = data['data'];
      if (inner is List) return inner;
      if (inner is Map<String, dynamic>) {
        final payments = inner['payments'];
        if (payments is List) return payments;
      }
    }
    return const [];
  }

  Map<String, dynamic> _unwrapMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      final inner = data['data'];
      if (inner is Map<String, dynamic>) return inner;
      return data;
    }
    return const {};
  }

  StoreCategory _mapCategory(dynamic raw) {
    final json = _toMap(raw);
    return StoreCategory(
      id: _string(json['id']),
      name: _string(json['name']),
      description: _nullableString(json['description']),
      iconUrl: _nullableString(json['iconUrl']),
    );
  }

  StoreListing _mapStore(dynamic raw) {
    final json = _toMap(raw);
    return StoreListing(
      id: _string(json['id']),
      name: _string(json['name']),
      description: _nullableString(json['description']),
      address: _string(json['address']),
      city: _string(json['city']),
      state: _string(json['state']),
      pincode: _string(json['pincode']),
      latitude: _doubleOrNull(json['latitude']),
      longitude: _doubleOrNull(json['longitude']),
      isFeatured: _bool(json['isFeatured']),
    );
  }

  StoreInventoryItem _mapInventoryItem(dynamic raw) {
    final json = _toMap(raw);
    final variant = _toMap(json['productVariant']);
    final product = _toMap(variant['product']);
    return StoreInventoryItem(
      id: _string(json['id']),
      storeId: _string(json['storeId']),
      productVariantId: _string(json['productVariantId']),
      quantity: _int(json['quantity']),
      pricePaise: _int(json['pricePaise']),
      discountPricePaise: _intOrNull(json['discountPricePaise']),
      isActive: _bool(json['isActive'], fallback: true),
      variant: StoreProductVariant(
        id: _string(variant['id']),
        productId: _string(variant['productId']),
        name: _string(variant['name']),
        sku: _nullableString(variant['sku']),
        imageUrl: _nullableString(variant['imageUrl']),
        attributes: _toMap(variant['attributes']),
      ),
      product: StoreProduct(
        id: _string(product['id']),
        categoryId: _string(product['categoryId']),
        name: _string(product['name']),
        description: _nullableString(product['description']),
        brand: _nullableString(product['brand']),
        imageUrl: _nullableString(product['imageUrl']),
        tags: _stringList(product['tags']),
      ),
    );
  }

  StoreOrder _mapOrder(dynamic raw) {
    final json = _toMap(raw);
    return StoreOrder(
      id: _string(json['id']),
      storeId: _string(json['storeId']),
      userId: _string(json['userId']),
      status: _string(json['status']),
      totalAmountPaise: _int(json['totalAmountPaise']),
      deliveryFeePaise: _int(json['deliveryFeePaise']),
      taxAmountPaise: _int(json['taxAmountPaise']),
      discountAmountPaise: _int(json['discountAmountPaise']),
      finalAmountPaise: _int(json['finalAmountPaise']),
      paymentId: _nullableString(json['paymentId']),
      deliveryAddress: _string(json['deliveryAddress']),
      deliveryLat: _doubleOrNull(json['deliveryLat']),
      deliveryLng: _doubleOrNull(json['deliveryLng']),
      notes: _nullableString(json['notes']),
      createdAt: _date(json['createdAt']),
      updatedAt: _date(json['updatedAt']),
      store: _mapStore(json['store']),
      items: _unwrapList(json['items']).map(_mapOrderItem).toList(),
      delivery:
          json['delivery'] == null ? null : _mapDelivery(json['delivery']),
      invoice: json['invoice'] == null ? null : _mapInvoice(json['invoice']),
    );
  }

  StoreOrderItem _mapOrderItem(dynamic raw) {
    final json = _toMap(raw);
    final variant = _toMap(json['productVariant']);
    final product = _toMap(variant['product']);
    return StoreOrderItem(
      id: _string(json['id']),
      productVariantId: _string(json['productVariantId']),
      quantity: _int(json['quantity']),
      pricePaise: _int(json['pricePaise']),
      totalPricePaise: _int(json['totalPricePaise']),
      variant: StoreProductVariantSnapshot(
        id: _string(variant['id']),
        name: _string(variant['name']),
        imageUrl: _nullableString(variant['imageUrl']),
        product: StoreProductSnapshot(
          id: _string(product['id']),
          name: _string(product['name']),
          brand: _nullableString(product['brand']),
          imageUrl: _nullableString(product['imageUrl']),
        ),
      ),
    );
  }

  DeliveryTracking _mapDelivery(dynamic raw) {
    final json = _toMap(raw);
    return DeliveryTracking(
      id: _string(json['id']),
      status: _string(json['status']),
      trackingUrl: _nullableString(json['trackingUrl']),
      estimatedDelivery: _date(json['estimatedDelivery']),
      assignedAt: _date(json['assignedAt']),
      pickedUpAt: _date(json['pickedUpAt']),
      deliveredAt: _date(json['deliveredAt']),
    );
  }

  StoreInvoice _mapInvoice(dynamic raw) {
    final json = _toMap(raw);
    return StoreInvoice(
      id: _string(json['id']),
      invoiceNumber: _string(json['invoiceNumber']),
      invoiceUrl: _nullableString(json['invoiceUrl']),
      issuedAt: _date(json['issuedAt']),
    );
  }

  Map<String, dynamic> _toMap(dynamic value) =>
      value is Map ? value.cast<String, dynamic>() : <String, dynamic>{};

  String _string(dynamic value) => value?.toString() ?? '';
  String? _nullableString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text == 'null') return null;
    return text;
  }

  int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse(_string(value)) ?? 0;
  int? _intOrNull(dynamic value) {
    if (value == null) return null;
    final parsed = _int(value);
    return parsed == 0 && value.toString() != '0' ? null : parsed;
  }

  double? _doubleOrNull(dynamic value) {
    if (value == null) return null;
    return value is num ? value.toDouble() : double.tryParse(_string(value));
  }

  bool _bool(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    final text = value?.toString().toLowerCase();
    if (text == 'true') return true;
    if (text == 'false') return false;
    return fallback;
  }

  DateTime? _date(dynamic value) {
    final text = _nullableString(value);
    return text == null ? null : DateTime.tryParse(text);
  }

  List<String> _stringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const [];
  }
}
