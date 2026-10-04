class PaymentDetailModel {
  const PaymentDetailModel({
    required this.transactionId,
    required this.invoiceNo,
    required this.razorpayOrderId,
    required this.amountPaid,
    required this.goldGained,
    required this.paidAt,
    required this.paymentMethod,
    required this.status,
  });

  final String transactionId;
  final String? invoiceNo;
  final String? razorpayOrderId;
  final num amountPaid;
  final num goldGained;
  final String? paidAt;
  final String paymentMethod;
  final String status;

  DateTime? get paidAtDateTime => paidAt == null ? null : DateTime.tryParse(paidAt!);

  factory PaymentDetailModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PaymentDetailModel(
        transactionId: '',
        invoiceNo: null,
        razorpayOrderId: null,
        amountPaid: 0,
        goldGained: 0,
        paidAt: null,
        paymentMethod: '',
        status: '',
      );
    }
    return PaymentDetailModel(
      transactionId: json['transactionId'] as String? ?? '',
      invoiceNo: json['invoiceNo'] as String?,
      razorpayOrderId: json['razorpayOrderId'] as String?,
      amountPaid: (json['amountPaid'] as num?) ?? 0,
      goldGained: (json['goldGained'] as num?) ?? 0,
      paidAt: json['paidAt'] as String?,
      paymentMethod: json['paymentMethod'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}

class VerifyUserSchemeModel {
  const VerifyUserSchemeModel({
    required this.id,
    required this.goldAccumulated,
    required this.totalPaid,
  });

  final String id;
  final num goldAccumulated;
  final num totalPaid;

  factory VerifyUserSchemeModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const VerifyUserSchemeModel(id: '', goldAccumulated: 0, totalPaid: 0);
    }
    return VerifyUserSchemeModel(
      id: json['id'] as String? ?? '',
      goldAccumulated: (json['goldAccumulated'] as num?) ?? 0,
      totalPaid: (json['totalPaid'] as num?) ?? 0,
    );
  }
}

/// `POST /payments/verify` → `data`.
class PaymentVerifyModel {
  const PaymentVerifyModel({required this.payment, required this.userScheme});

  final PaymentDetailModel payment;
  final VerifyUserSchemeModel userScheme;

  factory PaymentVerifyModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return PaymentVerifyModel(
        payment: PaymentDetailModel.fromJson(null),
        userScheme: VerifyUserSchemeModel.fromJson(null),
      );
    }
    return PaymentVerifyModel(
      payment: PaymentDetailModel.fromJson(json['payment'] as Map<String, dynamic>?),
      userScheme: VerifyUserSchemeModel.fromJson(json['userScheme'] as Map<String, dynamic>?),
    );
  }
}