import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final DateFormat _date = DateFormat('dd MMM yyyy');
  static final DateFormat _month = DateFormat('MMMM yyyy');
  static final DateFormat _shortDate = DateFormat('dd MMM');

  static String formatDate(DateTime date) => _date.format(date);
  static String formatMonth(DateTime date) => _month.format(date);
  static String formatShortDate(DateTime date) => _shortDate.format(date);

  /// Dynamic currency format driven by SettingsProvider values.
  static String formatCurrencyWith(
    double amount, {
    required String locale,
    required String symbol,
  }) {
    return NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: 0,
    ).format(amount);
  }

  /// Compact number label used for chart Y-axis ticks (no currency symbol).
  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      final k = amount / 1000;
      return '${k >= 10 ? k.toStringAsFixed(0) : k.toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}
