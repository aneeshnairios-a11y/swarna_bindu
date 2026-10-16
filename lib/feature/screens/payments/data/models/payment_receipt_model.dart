/// `GET /payments/receipt/:transactionId` → `data.receipt`.
class PaymentReceiptModel {
  const PaymentReceiptModel({
    required this.schemeName,
    required this.schemeStatus,
    required this.installmentType,
    required this.paidAt,
    required this.amountPaid,
    required this.gst,
    required this.convenienceFee,
    required this.totalPaid,
    required this.transactionId,
    required this.invoiceNo,
    required this.razorpayOrderId,
    required this.paymentMethod,
  });

  final String schemeName;
  final String schemeStatus;
  final String installmentType;
  final String? paidAt;
  final num amountPaid;
  final num gst;
  final num convenienceFee;
  final num totalPaid;
  final String transactionId;
  final String? invoiceNo;
  final String? razorpayOrderId;
  final String paymentMethod;

  DateTime? get paidAtDateTime {
    final raw = paidAt;
    if (raw == null) return null;
    return DateTime.tryParse(raw)?.toLocal();
  }

  /// CURRENT_MONTH -> "Current Month", PENDING_DUES -> "Pending Dues", ...
  String get installmentLabel => _titleCase(installmentType);

  /// ACTIVE -> "Active"
  String get schemeStatusLabel => _titleCase(schemeStatus);

  bool get isSchemeActive => schemeStatus.toUpperCase() == 'ACTIVE';

  static String _titleCase(String raw) {
    if (raw.isEmpty) return '—';
    return raw
        .split(RegExp(r'[_\s]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  /// Receives `data` (i.e. `{ "receipt": { ... } }`).
  factory PaymentReceiptModel.fromJson(Map<String, dynamic>? json) {
    final r = (json?['receipt'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    return PaymentReceiptModel(
      schemeName: r['schemeName'] as String? ?? '',
      schemeStatus: r['schemeStatus'] as String? ?? '',
      installmentType: r['installmentType'] as String? ?? '',
      paidAt: r['paidAt'] as String?,
      amountPaid: (r['amountPaid'] as num?) ?? 0,
      gst: (r['gst'] as num?) ?? 0,
      convenienceFee: (r['convenienceFee'] as num?) ?? 0,
      totalPaid: (r['totalPaid'] as num?) ?? 0,
      transactionId: r['transactionId'] as String? ?? '',
      invoiceNo: r['invoiceNo'] as String?,
      razorpayOrderId: r['razorpayOrderId'] as String?,
      paymentMethod: r['paymentMethod'] as String? ?? '',
    );
  }
}