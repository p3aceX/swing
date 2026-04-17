import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

class AcademyFeeOrderResult {
  const AcademyFeeOrderResult({
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

class AcademyFeeService {
  final _client = ApiClient.instance.dio;

  Future<AcademyFeeOrderResult> createFeeOrder(String enrollmentId) async {
    final response = await _client.post(
      ApiEndpoints.paymentOrders,
      data: {
        'entityType': 'ACADEMY_FEE',
        'entityId': enrollmentId,
      },
    );

    final payload = response.data as Map<String, dynamic>;
    final data = (payload['data'] ?? payload) as Map<String, dynamic>;
    final payment =
        (data['payment'] ?? <String, dynamic>{}) as Map<String, dynamic>;
    final order =
        (data['razorpayOrder'] ?? <String, dynamic>{}) as Map<String, dynamic>;

    return AcademyFeeOrderResult(
      paymentId: payment['id'] as String? ?? '',
      orderId: order['id'] as String? ?? '',
      amountPaise: (order['amount'] as num?)?.toInt() ?? 0,
      currency: order['currency'] as String? ?? 'INR',
      key: order['key'] as String?,
    );
  }

  Future<void> verifyFeePayment({
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
