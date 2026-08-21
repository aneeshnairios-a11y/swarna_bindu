/// Response model for `GET /gold-rate/today`.
///
/// Server payload (already unwrapped from the `{success,message,data}`
/// envelope by [ApiClient]):
/// ```json
/// {
///   "rate22K_per_g": 6744.91,
///   "rate24K_per_8g": 56124.06,
///   "lastUpdated": "2026-08-21T19:13:20.000Z"
/// }
/// ```
class GoldRateModel {
  const GoldRateModel({
    required this.rate22KPerGram,
    required this.rate24KPer8Gram,
    required this.lastUpdated,
  });

  final double rate22KPerGram;
  final double rate24KPer8Gram;
  final DateTime lastUpdated;

  factory GoldRateModel.fromJson(Map<String, dynamic> json) {
    return GoldRateModel(
      rate22KPerGram: _toDouble(json['rate22K_per_g']),
      rate24KPer8Gram: _toDouble(json['rate24K_per_8g']),
      lastUpdated: DateTime.tryParse(json['lastUpdated'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}