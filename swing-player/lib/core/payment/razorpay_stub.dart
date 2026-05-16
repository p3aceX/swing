// Razorpay removed — all payments go through Cashfree.
// This stub keeps dependent screens compiling until they are rewritten.

class Razorpay {
  static const String EVENT_PAYMENT_SUCCESS = 'payment.success';
  static const String EVENT_PAYMENT_ERROR = 'payment.error';
  static const String EVENT_EXTERNAL_WALLET = 'payment.external_wallet';

  void on(String event, Function handler) {}
  void open(Map<String, dynamic> options) {}
  void clear() {}
}

class PaymentSuccessResponse {
  final String? paymentId;
  final String? orderId;
  final String? signature;
  PaymentSuccessResponse({this.paymentId, this.orderId, this.signature});
}

class PaymentFailureResponse {
  final String? message;
  final int? code;
  PaymentFailureResponse({this.message, this.code});
}

class ExternalWalletResponse {
  final String? walletName;
  ExternalWalletResponse({this.walletName});
}
