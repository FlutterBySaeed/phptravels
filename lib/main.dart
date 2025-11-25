import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phptravels/SCREENS/navigation.dart';
import 'package:phptravels/providers/theme_provider.dart';
import 'package:phptravels/providers/language_provider.dart';
import 'package:phptravels/THEMES/app_theme.dart';
import 'package:phptravels/l10n/app_localizations.dart'; // Import your generated localizations

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final languageProvider = LanguageProvider();
  await languageProvider.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ThemeProvider()..init(),
        ),
        ChangeNotifierProvider(
          create: (context) => languageProvider,
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
          supportedLocales: AppLocalizations.supportedLocales,
          locale: languageProvider.currentLocale,
          
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