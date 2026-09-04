/// A single entry inside `GET /payments/history` → `data.history[]`.
class PaymentHistoryItemModel {
  const PaymentHistoryItemModel({
    required this.transactionId,
    required this.schemeName,
    required this.amountPaid,
    required this.paymentMethod,
    required this.paidAt,
    required this.status,
    required this.installmentType,
  });

  final String transactionId;
  final String schemeName;
  final num amountPaid;
  final String paymentMethod;
  final String? paidAt;
  final String status;
  final String installmentType;

  DateTime? get paidAtDateTime => paidAt == null ? null : DateTime.tryParse(paidAt!);

  factory PaymentHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryItemModel(
      transactionId: json['transactionId'] as String? ?? '',
      schemeName: json['schemeName'] as String? ?? '',
      amountPaid: (json['amountPaid'] as num?) ?? 0,
      paymentMethod: json['paymentMethod'] as String? ?? '',
      paidAt: json['paidAt'] as String?,
      status: json['status'] as String? ?? '',
      installmentType: json['installmentType'] as String? ?? '',
    );
  }
}

/// Shared pagination envelope shape used by the payments endpoints.
class PaymentPaginationModel {
  const PaymentPaginationModel({
    this.page = 1,
    this.limit = 10,
    this.total = 0,
    this.pages = 1,
  });

  final int page;
  final int limit;
  final int total;
  final int pages;

  bool get hasMore => page < pages;

  factory PaymentPaginationModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PaymentPaginationModel();
    return PaymentPaginationModel(
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      total: (json['total'] as num?)?.toInt() ?? 0,
      pages: (json['pages'] as num?)?.toInt() ?? 1,
    );
  }
}

/// `GET /payments/history` → `data`.
class PaymentHistoryPageModel {
  const PaymentHistoryPageModel({required this.items, required this.pagination});

  final List<PaymentHistoryItemModel> items;
  final PaymentPaginationModel pagination;

  factory PaymentHistoryPageModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PaymentHistoryPageModel(items: [], pagination: PaymentPaginationModel());
    }
    final list = json['history'] as List<dynamic>? ?? const [];
    return PaymentHistoryPageModel(
      items: list.whereType<Map<String, dynamic>>().map(PaymentHistoryItemModel.fromJson).toList(),
      pagination: PaymentPaginationModel.fromJson(json['pagination'] as Map<String, dynamic>?),
    );
  }
}