import 'package:intl/intl.dart';

/// Formatting utilities for the Gold Scheme app.
/// Always use these — never format currency/dates/gold inline.
abstract class AppFormatters {
  // ── Currency (Indian format ₹1,00,000) ───────────────────────
  static final _currencyFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final _currencyFormatterDecimal = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// Format amount as ₹1,00,000
  static String currency(num amount) =>
      _currencyFormatter.format(amount);

  /// Format amount as ₹1,00,000.00
  static String currencyDecimal(num amount) =>
      _currencyFormatterDecimal.format(amount);

  // ── Gold weight (3 decimal places) ───────────────────────────
  static String goldWeight(double grams) =>
      '${grams.toStringAsFixed(3)} g';

  static String goldWeightShort(double grams) =>
      '${grams.toStringAsFixed(2)}g';

  // ── Gold rate per gram ────────────────────────────────────────
  static String goldRate(num ratePerGram) =>
      '${_currencyFormatter.format(ratePerGram)}/g';

  // ── Dates ─────────────────────────────────────────────────────
  static final _dateFormatter = DateFormat('dd MMM yyyy');
  static final _dateShortFormatter = DateFormat('dd MMM');
  static final _dateTimeFormatter = DateFormat('dd MMM yyyy, hh:mm a');
  static final _monthYearFormatter = DateFormat('MMM yyyy');
  static final _timeFormatter = DateFormat('hh:mm a');

  static String date(DateTime dt) => _dateFormatter.format(dt);
  static String dateShort(DateTime dt) => _dateShortFormatter.format(dt);
  static String dateTime(DateTime dt) => _dateTimeFormatter.format(dt);
  static String monthYear(DateTime dt) => _monthYearFormatter.format(dt);
  static String time(DateTime dt) => _timeFormatter.format(dt);

  /// Relative time: "2 days ago", "Just now", "In 3 days"
  static String relativeDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.isNegative) {
      final futureDiff = dt.difference(now);
      if (futureDiff.inDays == 0) return 'Today';
      if (futureDiff.inDays == 1) return 'Tomorrow';
      if (futureDiff.inDays < 7) return 'In ${futureDiff.inDays} days';
      return date(dt);
    }
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return date(dt);
  }

  // ── Phone number formatting ───────────────────────────────────
  static String phoneNumber(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      return '+91 ${digits.substring(0, 5)} ${digits.substring(5)}';
    }
    return phone;
  }

  /// Mask phone number for display: +91 98765 ****
  static String maskedPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 10) {
      return '+91 ${digits.substring(0, 5)} ****';
    }
    return '****';
  }

  // ── Progress / percentages ────────────────────────────────────
  static String percent(double value, {int decimals = 0}) =>
      '${value.toStringAsFixed(decimals)}%';

  static String installmentProgress(int paid, int total) =>
      '$paid/$total installments';

  // ── Duration formatting ───────────────────────────────────────
  static String months(int count) =>
      '$count ${count == 1 ? 'month' : 'months'}';
}