// lib/providers/currency_provider.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Currency {
  final String code;
  final String symbol;
  final String name;
  final double rateFromPKR;

  Currency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.rateFromPKR,
  });
}

class CurrencyProvider extends ChangeNotifier {
  static const String _currencyKey = 'app_currency';

  // List of supported currencies with exchange rates (as of demo - use API for production)
  // All rates are relative to PKR (Pakistani Rupee) as the base currency
  final List<Currency> _supportedCurrencies = [
    Currency(
        code: 'PKR', symbol: 'PKR', name: 'Pakistani Rupee', rateFromPKR: 1.0),
    Currency(
        code: 'USD',
        symbol: '\$',
        name: 'US Dollar',
        rateFromPKR: 0.0036), // ~280 PKR = 1 USD
    Currency(
        code: 'EUR',
        symbol: '€',
        name: 'Euro',
        rateFromPKR: 0.0033), // ~304 PKR = 1 EUR
    Currency(
        code: 'GBP', symbol: '£', name: 'British Pound', rateFromPKR: 0.0028),
    Currency(
        code: 'SAR', symbol: 'ر.س', name: 'Saudi Riyal', rateFromPKR: 0.0135),
    Currency(
        code: 'EGP', symbol: 'ج.م', name: 'Egyptian Pound', rateFromPKR: 0.176),
  ];

  late Currency _currentCurrency;
  late SharedPreferences _prefs;

  Currency get currentCurrency => _currentCurrency;
  List<Currency> get supportedCurrencies => _supportedCurrencies;
  String get currencyCode => _currentCurrency.code;
  String get currencySymbol => _currentCurrency.symbol;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final savedCurrencyCode = _prefs.getString(_currencyKey) ?? 'PKR';
    _currentCurrency = _supportedCurrencies.firstWhere(
      (currency) => currency.code == savedCurrencyCode,
      orElse: () => _supportedCurrencies.first,
    );
    notifyListeners();
  }

  Future<void> setCurrency(String currencyCode) async {
    if (currencyCode == _currentCurrency.code) return;

    final newCurrency = _supportedCurrencies.firstWhere(
      (currency) => currency.code == currencyCode,
      orElse: () => _currentCurrency,
    );

    _currentCurrency = newCurrency;
    await _prefs.setString(_currencyKey, currencyCode);
    notifyListeners();
  }

  /// Convert amount from PKR to the current currency
  double convertFromPKR(double pkrAmount) {
    return pkrAmount * _currentCurrency.rateFromPKR;
  }

  /// Convert amount from PKR to a specific currency
  double convertFromPKRTo(double pkrAmount, String targetCurrencyCode) {
    final targetCurrency = _supportedCurrencies.firstWhere(
      (currency) => currency.code == targetCurrencyCode,
      orElse: () => _currentCurrency,
    );
    return pkrAmount * targetCurrency.rateFromPKR;
  }

  /// Format price with currency symbol and proper number formatting
  String formatPrice(double pkrAmount, {bool compact = false}) {
    final convertedAmount = convertFromPKR(pkrAmount);

    if (compact) {
      // For compact display (e.g., in cards)
      return '${_currentCurrency.code} ${_formatNumber(convertedAmount)}';
    } else {
      // For detailed display
      return '${_currentCurrency.symbol} ${_formatNumber(convertedAmount)}';
    }
  }

  /// Format price with a specific currency
  String formatPriceWithCurrency(double pkrAmount, String targetCurrencyCode) {
    final targetCurrency = _supportedCurrencies.firstWhere(
      (currency) => currency.code == targetCurrencyCode,
      orElse: () => _currentCurrency,
    );
    final convertedAmount = pkrAmount * targetCurrency.rateFromPKR;
    return '${targetCurrency.code} ${_formatNumber(convertedAmount)}';
  }

  /// Format number with thousands separators
  String _formatNumber(double amount) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return formatter.format(amount.round());
  }

  /// Get currency symbol for a specific currency code
  String getSymbolForCode(String code) {
    final currency = _supportedCurrencies.firstWhere(
      (c) => c.code == code,
      orElse: () => _currentCurrency,
    );
    return currency.symbol;
  }
}
