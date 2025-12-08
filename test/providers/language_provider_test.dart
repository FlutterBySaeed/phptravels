import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phptravels/providers/language_provider.dart';

void main() {
  group('LanguageProvider', () {
    late LanguageProvider languageProvider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      languageProvider = LanguageProvider();
    });

    test('should initialize with English (US) as default', () async {
      await languageProvider.init();

      expect(languageProvider.currentLocale, const Locale('en', 'US'));
      expect(languageProvider.currentLanguageCode, 'en');
      expect(languageProvider.currentCountryCode, 'US');
    });

    test('should load saved language from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'app_language': 'es',
        'app_country': 'ES',
      });

      final provider = LanguageProvider();
      await provider.init();

      expect(provider.currentLocale, const Locale('es', 'ES'));
      expect(provider.currentLanguageCode, 'es');
      expect(provider.currentCountryCode, 'ES');
    });

    test('should change language to Spanish (Spain)', () async {
      await languageProvider.init();
      await languageProvider.setLanguage('es', 'ES');

      expect(languageProvider.currentLocale, const Locale('es', 'ES'));
      expect(languageProvider.currentLanguageCode, 'es');
      expect(languageProvider.currentCountryCode, 'ES');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_language'), 'es');
      expect(prefs.getString('app_country'), 'ES');
    });

    test('should change language to Arabic (Saudi Arabia)', () async {
      await languageProvider.init();
      await languageProvider.setLanguage('ar', 'SA');

      expect(languageProvider.currentLocale, const Locale('ar', 'SA'));
    });

    test('should use first country if country code not provided', () async {
      await languageProvider.init();
      await languageProvider.setLanguage('es'); // No country code

      expect(languageProvider.currentLanguageCode, 'es');
      expect(languageProvider.currentCountryCode, isNotNull);
    });

    test('should notify listeners when language changes', () async {
      await languageProvider.init();

      var notified = false;
      languageProvider.addListener(() {
        notified = true;
      });

      await languageProvider.setLanguage('es', 'ES');

      expect(notified, true);
    });

    test('should not notify listeners when setting same language', () async {
      await languageProvider.init();
      await languageProvider.setLanguage('en', 'US');

      var notified = false;
      languageProvider.addListener(() {
        notified = true;
      });

      await languageProvider.setLanguage('en', 'US');

      expect(notified, false);
    });

    test('should return correct supported locales list', () async {
      await languageProvider.init();

      final locales = languageProvider.supportedLocalesList;

      expect(locales.length, greaterThanOrEqualTo(6));
      expect(locales.contains(const Locale('en', 'US')), true);
      expect(locales.contains(const Locale('en', 'GB')), true);
      expect(locales.contains(const Locale('es', 'ES')), true);
      expect(locales.contains(const Locale('ar', 'SA')), true);
    });

    test('should get display name for locale', () async {
      await languageProvider.init();

      expect(languageProvider.getDisplayName('en', 'US'), 'English (US)');
      expect(languageProvider.getDisplayName('es', 'ES'), contains('Español'));
      expect(languageProvider.getDisplayName('ar', 'SA'), contains('العربية'));
    });

    test('should get current locale display name', () async {
      await languageProvider.init();

      expect(languageProvider.currentLocaleDisplayName, 'English (US)');

      await languageProvider.setLanguage('es', 'MX');
      expect(languageProvider.currentLocaleDisplayName, contains('México'));
    });

    test('should get available languages list', () async {
      await languageProvider.init();

      final languages = languageProvider.availableLanguages;

      expect(languages.contains('en'), true);
      expect(languages.contains('es'), true);
      expect(languages.contains('ar'), true);
    });

    test('should get countries for specific language', () async {
      await languageProvider.init();

      final englishCountries = languageProvider.getCountriesForLanguage('en');

      expect(englishCountries, isNotNull);
      expect(englishCountries!['US'], 'English (US)');
      expect(englishCountries['GB'], 'English (UK)');
    });

    test('should get available locales as strings', () async {
      await languageProvider.init();

      final locales = languageProvider.getAvailableLocales();

      expect(locales.contains('en-US'), true);
      expect(locales.contains('en-GB'), true);
      expect(locales.contains('es-ES'), true);
      expect(locales.contains('ar-SA'), true);
    });

    test('should persist language across provider instances', () async {
      // First provider sets Spanish
      final provider1 = LanguageProvider();
      await provider1.init();
      await provider1.setLanguage('es', 'MX');

      // Second provider should load Spanish
      final provider2 = LanguageProvider();
      await provider2.init();

      expect(provider2.currentLanguageCode, 'es');
      expect(provider2.currentCountryCode, 'MX');
    });
  });
}
