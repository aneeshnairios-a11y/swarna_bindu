/// Real scheme catalog model — mirrors `GET /schemes` and `GET /schemes/:id`.
///
/// Phase 2 replacement for the Phase 1 mock model. Field names follow the
/// server response exactly (`maturityBenefitPercent`, `minGoldGram`,
/// `termsAndConditions` as a single `\n`-joined string) so `fromJson` needs
/// no renaming/guessing.
class SchemeModel {
  const SchemeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.monthlyInvestment,
    required this.durationMonths,
    required this.maturityBenefitPercent,
    required this.minGoldGram,
    required this.termsAndConditions,
    required this.isActive,
  });

  final String id;
  final String name;
  final String description;
  final double monthlyInvestment;
  final int durationMonths;
  final double maturityBenefitPercent;
  final double minGoldGram;

  /// Raw server string, e.g. "1. ...\n2. ...\n3. ...". Use [termsList] for
  /// bullet-point UI rendering.
  final String termsAndConditions;
  final bool isActive;

  factory SchemeModel.fromJson(Map<String, dynamic> json) => SchemeModel(
    id: json['_id'] as String? ?? json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
    monthlyInvestment: (json['monthlyInvestment'] as num?)?.toDouble() ?? 0,
    durationMonths: (json['durationMonths'] as num?)?.toInt() ?? 0,
    maturityBenefitPercent: (json['maturityBenefitPercent'] as num?)?.toDouble() ?? 0,
    minGoldGram: (json['minGoldGram'] as num?)?.toDouble() ?? 0,
    termsAndConditions: json['termsAndConditions'] as String? ?? '',
    isActive: json['isActive'] as bool? ?? true,
  );

  /// Splits the server's newline-separated terms string into a clean bullet
  /// list for [SchemeDetailScreen]. Strips the leading "1. " / "2. " index
  /// prefixes the server includes, since the UI renders its own bullet dot.
  List<String> get termsList => termsAndConditions
      .split('\n')
      .map((line) => line.trim().replaceFirst(RegExp(r'^\d+\.\s*'), ''))
      .where((line) => line.isNotEmpty)
      .toList();

  /// Cosmetic "best for" tag shown on the scheme card footer. The API has
  /// no equivalent field — this is a local UI heuristic derived from the
  /// investment tier, not server data. Adjust thresholds as product
  /// guidance dictates, or remove if this messaging should come from the
  /// backend later.
  String get bestFor {
    if (monthlyInvestment <= 2500) return 'Best for Beginners';
    if (monthlyInvestment >= 8000) return 'Best for High Returns';
    return 'Best for Long Term';
  }
}