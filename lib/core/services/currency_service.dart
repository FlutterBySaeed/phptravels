import 'package:intl/intl.dart';

class CurrencyService {
  static String formatNumber(double amount) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return formatter.format(amount.round());
  }

  static String formatDecimal(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(amount);
  }

  static double parsePrice(String priceString) {
    final numericString = priceString.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(numericString) ?? 0.0;
  }

  static double calculatePercentageChange(double original, double current) {
    if (original == 0) return 0;
    return ((current - original) / original) * 100;
  }

  static String formatWithCode(String currencyCode, double amount) {
    return '$currencyCode ${formatNumber(amount)}';
  }

  static String formatWithSymbol(String symbol, double amount) {
    return '$symbol ${formatNumber(amount)}';
  }
}
