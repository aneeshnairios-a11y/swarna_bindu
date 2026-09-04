/// `POST /payments/initialize` → `data`.
class PaymentInitializeModel {
  const PaymentInitializeModel({
    required this.transactionId,
    required this.razorpayOrderId,
    required this.amount,
    required this.gst,
    required this.convenienceFee,
    required this.totalPayable,
    required this.schemeName,
  });

  final String transactionId;
  final String? razorpayOrderId;
  final num amount;
  final num gst;
  final num convenienceFee;
  final num totalPayable;
  final String schemeName;

  factory PaymentInitializeModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PaymentInitializeModel(
        transactionId: '',
        razorpayOrderId: null,
        amount: 0,
        gst: 0,
        convenienceFee: 0,
        totalPayable: 0,
        schemeName: '',
      );
    }
    return PaymentInitializeModel(
      transactionId: json['transactionId'] as String? ?? '',
      razorpayOrderId: json['razorpayOrderId'] as String?,
      amount: (json['amount'] as num?) ?? 0,
      gst: (json['gst'] as num?) ?? 0,
      convenienceFee: (json['convenienceFee'] as num?) ?? 0,
      totalPayable: (json['totalPayable'] as num?) ?? 0,
      schemeName: json['schemeName'] as String? ?? '',
    );
  }
}