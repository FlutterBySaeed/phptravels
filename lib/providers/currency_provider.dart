// lib/providers/currency_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Currency {
  final String code;
  final String symbol;
  final String name;

  Currency({
    required this.code,
    required this.symbol,
    required this.name,
  });
}

class CurrencyProvider extends ChangeNotifier {
  static const String _currencyKey = 'app_currency';
  
  // List of supported currencies
  final List<Currency> _supportedCurrencies = [
    Currency(code: 'USD', symbol: '\$', name: 'US Dollar'),
    Currency(code: 'EUR', symbol: '€', name: 'Euro'),
    Currency(code: 'GBP', symbol: '£', name: 'British Pound'),
    Currency(code: 'SAR', symbol: 'ر.س', name: 'Saudi Riyal'),
    Currency(code: 'EGP', symbol: 'ج.م', name: 'Egyptian Pound'),
  ];

  late Currency _currentCurrency;
  late SharedPreferences _prefs;

  Currency get currentCurrency => _currentCurrency;
  List<Currency> get supportedCurrencies => _supportedCurrencies;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final savedCurrencyCode = _prefs.getString(_currencyKey) ?? 'USD';
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

  String formatPrice(double amount) {
    // You can implement more sophisticated formatting based on locale if needed
    return '${_currentCurrency.symbol} ${amount.toStringAsFixed(2)}';
  }
}