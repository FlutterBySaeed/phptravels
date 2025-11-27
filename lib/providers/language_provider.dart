import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  static const String _countryKey = 'app_country';
  
  Locale _currentLocale = const Locale('en', 'US');
  late SharedPreferences _prefs;

  // List of supported locales with their display names
  final Map<String, Map<String, String>> supportedLocales = {
    'en': {
      'US': 'English (US)',
      'GB': 'English (UK)',
    },
    'es': {
      'ES': 'Español (España)',
      'MX': 'Español (México)',
    },
    'ar': {
      'SA': 'العربية (المملكة العربية السعودية)',
      'EG': 'العربية (مصر)',
    },
  };

  Locale get currentLocale => _currentLocale;
  String get currentLanguageCode => _currentLocale.languageCode;
  String? get currentCountryCode => _currentLocale.countryCode;

  // Get all supported locales as Locale objects
  List<Locale> get supportedLocalesList {
    final List<Locale> locales = [];
    supportedLocales.forEach((languageCode, countries) {
      countries.forEach((countryCode, _) {
        locales.add(Locale(languageCode, countryCode));
      });
    });
    return locales;
  }

  // Get display name for a locale
  String getDisplayName(String languageCode, [String? countryCode]) {
    if (countryCode != null && countryCode.isNotEmpty) {
      return supportedLocales[languageCode]?[countryCode] ?? languageCode;
    }
    return supportedLocales[languageCode]?.values.first.split(' ')[0] ?? languageCode;
  }

  // Get current locale display name
  String get currentLocaleDisplayName {
    return getDisplayName(_currentLocale.languageCode, _currentLocale.countryCode);
  }

  // Get all available languages
  List<String> get availableLanguages => supportedLocales.keys.toList();

  // Get countries for a specific language
  Map<String, String>? getCountriesForLanguage(String languageCode) {
    return supportedLocales[languageCode];
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final savedLanguage = _prefs.getString(_languageKey) ?? 'en';
    final savedCountry = _prefs.getString(_countryKey) ?? 'US';
    _currentLocale = Locale(savedLanguage, savedCountry);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode, [String? countryCode]) async {
    // If no country code is provided, use the first available one for the language
    countryCode ??= supportedLocales[languageCode]?.keys.first;
    
    if (languageCode == _currentLocale.languageCode && 
        countryCode == _currentLocale.countryCode) {
      return; // No change needed
    }
    
    _currentLocale = Locale(languageCode, countryCode);
    await _prefs.setString(_languageKey, languageCode);
    await _prefs.setString(_countryKey, countryCode ?? '');
    notifyListeners();
  }

  // Get all available locales as a list of display names
  List<String> getAvailableLocales() {
    final List<String> locales = [];
    supportedLocales.forEach((languageCode, countries) {
      countries.forEach((countryCode, displayName) {
        locales.add('$languageCode-$countryCode');
      });
    });
    return locales;
  }
}