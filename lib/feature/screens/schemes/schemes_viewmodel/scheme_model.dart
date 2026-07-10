/// Mock scheme model for Phase 1 (UI-only). Shape mirrors the eventual
/// `GET /schemes` / `GET /schemes/:id` response so swapping in real data
/// via a repository in Phase 2 only touches the data source, not the UI.
class SchemeModel {
  const SchemeModel({
    required this.id,
    required this.name,
    required this.tagline,
    required this.monthlyInvestment,
    required this.durationMonths,
    required this.maturityBonusPercent,
    required this.minGoldGrams,
    required this.bestFor,
    this.badge,
  });

  final String id;
  final String name;
  final String tagline;
  final double monthlyInvestment;
  final int durationMonths;
  final double maturityBonusPercent;
  final double minGoldGrams;
  final String bestFor;

  /// e.g. "Popular", "New" — null when the scheme has no badge.
  final String? badge;

  /// Generic terms shown on the scheme detail screen, generated from the
  /// scheme's own numbers so every scheme reads correctly without needing
  /// per-scheme copy yet.
  List<String> get termsAndConditions => [
    'Minimum monthly installment for this scheme is ₹${monthlyInvestment.toStringAsFixed(0)}, payable on or before the due date each month.',
    'The scheme runs for $durationMonths months from the date of enrollment. Gold is credited at the day\'s rate on each successful payment.',
    'On maturity, a bonus of up to $maturityBonusPercent% of the accumulated gold value is added, subject to completing all installments on time.',
    'A minimum of ${minGoldGrams.toStringAsFixed(0)} grams must accumulate before redemption as jewellery can be requested.',
    'Missed installments may attract a late fee and can affect eligibility for the maturity bonus — see your store for details.',
    'KYC verification (Aadhaar & PAN) is mandatory before the first redemption request can be processed.',
  ];
}

const mockSchemes = <SchemeModel>[
  SchemeModel(
    id: 'swarna-bindu',
    name: 'Swarna Bindu',
    tagline: 'Ideal for long-term gold savings',
    monthlyInvestment: 5000,
    durationMonths: 11,
    maturityBonusPercent: 8,
    minGoldGrams: 10,
    bestFor: 'Best for Long Term',
    badge: 'Popular',
  ),
  SchemeModel(
    id: 'swarna-lite',
    name: 'Swarna Lite',
    tagline: 'Light, flexible monthly savings',
    monthlyInvestment: 2000,
    durationMonths: 6,
    maturityBonusPercent: 4,
    minGoldGrams: 3,
    bestFor: 'Best for Beginners',
  ),
  SchemeModel(
    id: 'swarna-plus',
    name: 'Swarna Plus',
    tagline: 'Higher returns for committed savers',
    monthlyInvestment: 10000,
    durationMonths: 18,
    maturityBonusPercent: 12,
    minGoldGrams: 25,
    bestFor: 'Best for High Returns',
    badge: 'New',
  ),
];

SchemeModel findScheme(String id) =>
    mockSchemes.firstWhere((s) => s.id == id, orElse: () => mockSchemes.first);