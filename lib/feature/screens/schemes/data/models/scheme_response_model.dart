/// Pagination block returned alongside `GET /schemes` and other list
/// endpoints in this API. Shared shape: `{ page, limit, total, pages }`.
class SchemePagination {
  const SchemePagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  final int page;
  final int limit;
  final int total;
  final int pages;

  factory SchemePagination.fromJson(Map<String, dynamic> json) => SchemePagination(
    page: (json['page'] as num?)?.toInt() ?? 1,
    limit: (json['limit'] as num?)?.toInt() ?? 10,
    total: (json['total'] as num?)?.toInt() ?? 0,
    pages: (json['pages'] as num?)?.toInt() ?? 1,
  );

  bool get hasMore => page < pages;
}

/// Response of `POST /schemes/:id/join` — the freshly created enrollment.
/// A brand-new join always starts at ₹0 paid / 0g gold, which is why those
/// fields aren't part of this payload (only [MySchemeModel], read after at
/// least one payment, carries totals/progress).
class UserSchemeModel {
  const UserSchemeModel({
    required this.id,
    required this.schemeName,
    required this.monthlyInvestment,
    required this.startDate,
    required this.endDate,
    required this.goalGoldGram,
    required this.status,
  });

  final String id;
  final String schemeName;
  final double monthlyInvestment;
  final DateTime startDate;
  final DateTime endDate;
  final double goalGoldGram;
  final String status;

  factory UserSchemeModel.fromJson(Map<String, dynamic> json) => UserSchemeModel(
    id: json['id'] as String? ?? '',
    schemeName: json['schemeName'] as String? ?? '',
    monthlyInvestment: (json['monthlyInvestment'] as num?)?.toDouble() ?? 0,
    startDate: DateTime.tryParse(json['startDate'] as String? ?? '') ?? DateTime.now(),
    endDate: DateTime.tryParse(json['endDate'] as String? ?? '') ?? DateTime.now(),
    goalGoldGram: (json['goalGoldGram'] as num?)?.toDouble() ?? 0,
    status: json['status'] as String? ?? 'ACTIVE',
  );
}

/// A single entry from `GET /schemes/my-schemes`. Unlike [UserSchemeModel],
/// this carries running totals/progress and (when redeemed) payout info.
class MySchemeModel {
  const MySchemeModel({
    required this.id,
    required this.schemeName,
    required this.monthlyInvestment,
    required this.goldAccumulated,
    required this.totalPaid,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.goalGoldGram,
    required this.progressPercent,
    this.redeemedAt,
    this.redeemedGoldGram,
    this.redeemedValue,
  });

  final String id;
  final String schemeName;
  final double monthlyInvestment;
  final double goldAccumulated;
  final double totalPaid;

  /// Observed values: `ACTIVE`, `REDEEMED`. Treat as an open string set —
  /// the server may introduce more (e.g. `DEFAULTED`, `CANCELLED`) later.
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final double goalGoldGram;
  final int progressPercent;

  /// Only non-null when [status] == `REDEEMED`.
  final DateTime? redeemedAt;
  final double? redeemedGoldGram;
  final double? redeemedValue;

  bool get isRedeemed => status == 'REDEEMED';
  bool get isActive => status == 'ACTIVE';

  factory MySchemeModel.fromJson(Map<String, dynamic> json) => MySchemeModel(
    id: json['id'] as String? ?? '',
    schemeName: json['schemeName'] as String? ?? '',
    monthlyInvestment: (json['monthlyInvestment'] as num?)?.toDouble() ?? 0,
    goldAccumulated: (json['goldAccumulated'] as num?)?.toDouble() ?? 0,
    totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0,
    status: json['status'] as String? ?? 'ACTIVE',
    startDate: DateTime.tryParse(json['startDate'] as String? ?? '') ?? DateTime.now(),
    endDate: DateTime.tryParse(json['endDate'] as String? ?? '') ?? DateTime.now(),
    goalGoldGram: (json['goalGoldGram'] as num?)?.toDouble() ?? 0,
    progressPercent: (json['progressPercent'] as num?)?.toInt() ?? 0,
    redeemedAt: json['redeemedAt'] == null ? null : DateTime.tryParse(json['redeemedAt'] as String),
    redeemedGoldGram: (json['redeemedGoldGram'] as num?)?.toDouble(),
    redeemedValue: (json['redeemedValue'] as num?)?.toDouble(),
  );
}