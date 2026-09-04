/// A single scheme's due summary, as returned inside
/// `GET /payments/dues` → `data.schemes[]`.
class DueSchemeModel {
  const DueSchemeModel({
    required this.userSchemeId,
    required this.schemeName,
    required this.monthlyInvestment,
    required this.paidInstallments,
    required this.totalInstallments,
    required this.pendingDuesCount,
    required this.pendingAmount,
    required this.nextDueAmount,
    required this.nextDueDate,
    required this.status,
    required this.isMatured,
  });

  final String userSchemeId;
  final String schemeName;
  final num monthlyInvestment;
  final int paidInstallments;
  final int totalInstallments;
  final int pendingDuesCount;
  final num pendingAmount;
  final num nextDueAmount;
  final String? nextDueDate;
  final String status;
  final bool isMatured;

  bool get hasPendingDues => pendingDuesCount > 0;

  /// Not provided by the API — advance payment is always 3 months of the
  /// scheme's monthly investment, computed client-side.
  num get advanceAmount => monthlyInvestment * 3;

  static const int advanceMonths = 3;

  DateTime? get nextDueDateTime => nextDueDate == null ? null : DateTime.tryParse(nextDueDate!);

  factory DueSchemeModel.fromJson(Map<String, dynamic> json) {
    return DueSchemeModel(
      userSchemeId: json['userSchemeId'] as String? ?? '',
      schemeName: json['schemeName'] as String? ?? '',
      monthlyInvestment: (json['monthlyInvestment'] as num?) ?? 0,
      paidInstallments: (json['paidInstallments'] as num?)?.toInt() ?? 0,
      totalInstallments: (json['totalInstallments'] as num?)?.toInt() ?? 0,
      pendingDuesCount: (json['pendingDuesCount'] as num?)?.toInt() ?? 0,
      pendingAmount: (json['pendingAmount'] as num?) ?? 0,
      nextDueAmount: (json['nextDueAmount'] as num?) ?? 0,
      nextDueDate: json['nextDueDate'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      isMatured: json['isMatured'] as bool? ?? false,
    );
  }
}

/// `GET /payments/dues` → `data`.
class PaymentDuesModel {
  const PaymentDuesModel({
    required this.totalPendingAmount,
    required this.nextDueAmount,
    required this.nextDueDate,
    required this.schemes,
  });

  final num totalPendingAmount;
  final num nextDueAmount;
  final String? nextDueDate;
  final List<DueSchemeModel> schemes;

  DateTime? get nextDueDateTime => nextDueDate == null ? null : DateTime.tryParse(nextDueDate!);

  bool get isEmpty => schemes.isEmpty;

  factory PaymentDuesModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PaymentDuesModel(
        totalPendingAmount: 0,
        nextDueAmount: 0,
        nextDueDate: null,
        schemes: [],
      );
    }
    final list = json['schemes'] as List<dynamic>? ?? const [];
    return PaymentDuesModel(
      totalPendingAmount: (json['totalPendingAmount'] as num?) ?? 0,
      nextDueAmount: (json['nextDueAmount'] as num?) ?? 0,
      nextDueDate: json['nextDueDate'] as String?,
      schemes: list.whereType<Map<String, dynamic>>().map(DueSchemeModel.fromJson).toList(),
    );
  }

  /// Look up a specific scheme's due info by its `userSchemeId`.
  DueSchemeModel? schemeById(String userSchemeId) {
    for (final s in schemes) {
      if (s.userSchemeId == userSchemeId) return s;
    }
    return null;
  }

  /// The scheme that matches the top-level aggregate `nextDueAmount` /
  /// `nextDueDate` — used by the Payments landing screen's hero "Pay Now"
  /// button when no specific scheme has been chosen yet. Falls back to the
  /// first scheme in the list.
  DueSchemeModel? get primaryDueScheme {
    if (schemes.isEmpty) return null;
    for (final s in schemes) {
      if (s.nextDueDate == nextDueDate && s.nextDueAmount == nextDueAmount) {
        return s;
      }
    }
    return schemes.first;
  }
}