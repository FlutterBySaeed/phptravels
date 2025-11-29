import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phptravels/SCREENS/navigation.dart';
import 'package:phptravels/providers/theme_provider.dart';
import 'package:phptravels/providers/language_provider.dart';
import 'package:phptravels/THEMES/app_theme.dart';
import 'package:phptravels/l10n/app_localizations.dart';
import 'package:phptravels/providers/currency_provider.dart';
import 'package:phptravels/providers/search_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final languageProvider = LanguageProvider();
  await languageProvider.init();

  final currencyProvider = CurrencyProvider();
  await currencyProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ThemeProvider()..init(),
        ),
        ChangeNotifierProvider(
          create: (context) => languageProvider,
        ),
        ChangeNotifierProvider(
          create: (context) => currencyProvider,
        ),
        ChangeNotifierProvider(
          create: (context) => SearchProvider(),
        ),
      ],
      child: const PHPTRAVELS(),
    ),
  );
}

class PHPTRAVELS extends StatelessWidget {
  const PHPTRAVELS({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        return MaterialApp(
          title: "PHPTRAVELS",
          theme: AppThemes.lightTheme(),
          darkTheme: AppThemes.darkTheme(),
          themeMode: _getThemeMode(themeProvider.themeMode),
          debugShowCheckedModeBanner: false,

          // Localization Configuration
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: languageProvider.supportedLocalesList,
          locale: languageProvider.currentLocale,
          localeResolutionCallback: (locale, supportedLocales) {
            // Check if the current device locale is supported
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale?.languageCode) {
                // If we have a matching language code, use it
                // If we also have a matching country code, use that exact locale
                if (supportedLocale.countryCode == locale?.countryCode) {
                  return supportedLocale;
                }
                // Otherwise, use the first locale for this language
                return supportedLocales.firstWhere(
                  (l) => l.languageCode == locale?.languageCode,
                  orElse: () => supportedLocale,
                );
              }
            }
            // If the locale is not supported, use the first one from the supported locales
            return supportedLocales.first;
          },

          home: const MainApp(),
        );
      },
    );
  }

  ThemeMode _getThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
