/// Models for `GET /user/dashboard`.
/// Plain Dart classes with `fromJson` (no codegen), same convention as KYC/Schemes.

double _toDouble(dynamic v, [double fallback = 0]) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? fallback;
  return fallback;
}

int _toInt(dynamic v, [int fallback = 0]) {
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

DateTime? _toDate(dynamic v) {
  if (v is! String || v.isEmpty) return null;
  return DateTime.tryParse(v);
}

class DashboardUser {
  const DashboardUser({
    required this.id,
    required this.mobileNumber,
    required this.fullName,
    required this.email,
    required this.profilePicture,
    required this.kycStatus,
    required this.isVerified,
  });

  final String id;
  final String mobileNumber;
  final String fullName;
  final String email;

  /// Relative server path, e.g. `/uploads/profiles/profile.png` (may be null/empty).
  final String? profilePicture;

  /// Raw server value (PENDING / SUBMITTED / APPROVED / REJECTED).
  final String kycStatus;
  final bool isVerified;

  factory DashboardUser.fromJson(Map<String, dynamic> json) => DashboardUser(
    id: (json['id'] ?? '').toString(),
    mobileNumber: (json['mobileNumber'] ?? '').toString(),
    fullName: (json['fullName'] ?? '').toString(),
    email: (json['email'] ?? '').toString(),
    profilePicture: json['profilePicture'] as String?,
    kycStatus: (json['kycStatus'] ?? '').toString(),
    isVerified: json['isVerified'] == true,
  );
}

class DashboardGoldRate {
  const DashboardGoldRate({
    required this.rate22kPerGram,
    required this.rate24kPer8g,
    required this.lastUpdated,
  });

  final double rate22kPerGram;
  final double rate24kPer8g;
  final DateTime? lastUpdated;

  factory DashboardGoldRate.fromJson(Map<String, dynamic> json) =>
      DashboardGoldRate(
        rate22kPerGram: _toDouble(json['rate22K_per_g'] ?? json['ratePerGram22K']),
        rate24kPer8g: _toDouble(json['rate24K_per_8g']),
        lastUpdated: _toDate(json['lastUpdated']),
      );
}

class DashboardSummary {
  const DashboardSummary({
    required this.totalSchemes,
    required this.activeSchemes,
    required this.redeemedSchemes,
    required this.totalGramsSaved,
    required this.totalAmountPaid,
    required this.currentGoldValue,
    required this.nextInstallmentDue,
    required this.nextDueDate,
  });

  final int totalSchemes;
  final int activeSchemes;
  final int redeemedSchemes;
  final double totalGramsSaved;
  final double totalAmountPaid;
  final double currentGoldValue;
  final double nextInstallmentDue;

  /// Null when the user has no active scheme / nothing due.
  final DateTime? nextDueDate;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) =>
      DashboardSummary(
        totalSchemes: _toInt(json['totalSchemes']),
        activeSchemes: _toInt(json['activeSchemes']),
        redeemedSchemes: _toInt(json['redeemedSchemes']),
        totalGramsSaved: _toDouble(json['totalGramsSaved']),
        totalAmountPaid: _toDouble(json['totalAmountPaid']),
        currentGoldValue: _toDouble(json['currentGoldValue']),
        nextInstallmentDue: _toDouble(json['nextInstallmentDue']),
        nextDueDate: _toDate(json['nextDueDate']),
      );
}

class PortfolioScheme {
  const PortfolioScheme({
    required this.userSchemeId,
    required this.schemeId,
    required this.schemeName,
    required this.monthlyInvestment,
    required this.durationMonths,
    required this.installmentsPaid,
    required this.totalInstallments,
    required this.remainingInstallments,
    required this.progressPercent,
    required this.goldAccumulated,
    required this.goalGoldGram,
    required this.totalAmountPaid,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.redeemedAt,
    required this.maturityBenefitPercent,
  });

  final String userSchemeId;
  final String schemeId;
  final String schemeName;
  final double monthlyInvestment;
  final int durationMonths;
  final int installmentsPaid;
  final int totalInstallments;
  final int remainingInstallments;
  final double progressPercent; // 0 - 100
  final double goldAccumulated;
  final double goalGoldGram;
  final double totalAmountPaid;
  final String status; // ACTIVE | REDEEMED | ...
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? redeemedAt;
  final double maturityBenefitPercent;

  bool get isActive => status == 'ACTIVE';

  factory PortfolioScheme.fromJson(Map<String, dynamic> json) =>
      PortfolioScheme(
        userSchemeId: (json['userSchemeId'] ?? '').toString(),
        schemeId: (json['schemeId'] ?? '').toString(),
        schemeName: (json['schemeName'] ?? '').toString(),
        monthlyInvestment: _toDouble(json['monthlyInvestment']),
        durationMonths: _toInt(json['durationMonths']),
        installmentsPaid: _toInt(json['installmentsPaid']),
        totalInstallments: _toInt(json['totalInstallments']),
        remainingInstallments: _toInt(json['remainingInstallments']),
        progressPercent: _toDouble(json['progressPercent']),
        goldAccumulated: _toDouble(json['goldAccumulated']),
        goalGoldGram: _toDouble(json['goalGoldGram']),
        totalAmountPaid: _toDouble(json['totalAmountPaid']),
        status: (json['status'] ?? '').toString(),
        startDate: _toDate(json['startDate']),
        endDate: _toDate(json['endDate']),
        redeemedAt: _toDate(json['redeemedAt']),
        maturityBenefitPercent: _toDouble(json['maturityBenefitPercent']),
      );
}

class DashboardData {
  const DashboardData({
    required this.user,
    required this.goldRate,
    required this.summary,
    required this.portfolio,
  });

  final DashboardUser user;
  final DashboardGoldRate goldRate;
  final DashboardSummary summary;
  final List<PortfolioScheme> portfolio;

  factory DashboardData.fromJson(Map<String, dynamic> json) => DashboardData(
    user: DashboardUser.fromJson(
      (json['user'] as Map?)?.cast<String, dynamic>() ?? const {},
    ),
    goldRate: DashboardGoldRate.fromJson(
      (json['goldRate'] as Map?)?.cast<String, dynamic>() ?? const {},
    ),
    summary: DashboardSummary.fromJson(
      (json['summary'] as Map?)?.cast<String, dynamic>() ?? const {},
    ),
    portfolio: ((json['portfolio'] as List?) ?? const [])
        .whereType<Map>()
        .map((e) => PortfolioScheme.fromJson(e.cast<String, dynamic>()))
        .toList(),
  );
}