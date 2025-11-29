// lib/SERVICES/currency_service.dart
import 'package:intl/intl.dart';

class CurrencyService {
  /// Format a number with thousands separators
  static String formatNumber(double amount) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return formatter.format(amount.round());
  }

  /// Format a decimal number with 2 decimal places
  static String formatDecimal(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(amount);
  }

  /// Parse price string to extract numeric value
  /// e.g., "PKR 24,474" -> 24474.0
  static double parsePrice(String priceString) {
    final numericString = priceString.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(numericString) ?? 0.0;
  }

  /// Calculate percentage change between two amounts
  static double calculatePercentageChange(double original, double current) {
    if (original == 0) return 0;
    return ((current - original) / original) * 100;
  }

  /// Format currency code with amount
  static String formatWithCode(String currencyCode, double amount) {
    return '$currencyCode ${formatNumber(amount)}';
  }

  /// Format currency symbol with amount
  static String formatWithSymbol(String symbol, double amount) {
    return '$symbol ${formatNumber(amount)}';
  }
}
