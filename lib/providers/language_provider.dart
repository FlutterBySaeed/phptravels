import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  
  Locale _currentLocale = const Locale('en');
  late SharedPreferences _prefs;

  Locale get currentLocale => _currentLocale;

  String get currentLanguageCode => _currentLocale.languageCode;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final savedLanguage = _prefs.getString(_languageKey) ?? 'en';
    _currentLocale = Locale(savedLanguage);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    if (languageCode == _currentLocale.languageCode) {
      return; // No change needed
    }
    
    _currentLocale = Locale(languageCode);
    await _prefs.setString(_languageKey, languageCode);
    notifyListeners();
  }

  String getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'ar':
        return 'العربية';
      default:
        return 'English';
    }
  }
}