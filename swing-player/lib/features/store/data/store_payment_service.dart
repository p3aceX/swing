import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../domain/store_models.dart';

class StorePaymentService {
  final _client = ApiClient.instance.dio;

  Future<StorePaymentOrder> createStoreOrderPayment(String orderId) async {
    final response = await _client.post(
      ApiEndpoints.paymentOrders,
      data: {
        'entityType': 'STORE_ORDER',
        'entityId': orderId,
      },
    );

    final payload = response.data as Map<String, dynamic>;
    final data = (payload['data'] ?? payload) as Map<String, dynamic>;
    final payment =
        (data['payment'] ?? <String, dynamic>{}) as Map<String, dynamic>;
    final razorpayOrder =
        (data['razorpayOrder'] ?? <String, dynamic>{}) as Map<String, dynamic>;

    return StorePaymentOrder(
      paymentId: payment['id'] as String? ?? '',
      orderId: razorpayOrder['id'] as String? ?? '',
      amountPaise: (razorpayOrder['amount'] as num?)?.toInt() ?? 0,
      currency: razorpayOrder['currency'] as String? ?? 'INR',
      key: razorpayOrder['key'] as String?,
    );
  }

  Future<void> verifyStoreOrderPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    await _client.post(
      ApiEndpoints.paymentVerify,
      data: {
        'razorpayOrderId': orderId,
        'razorpayPaymentId': paymentId,
        'razorpaySignature': signature,
      },
    );
  }
}
