import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phptravels/providers/theme_provider.dart';

void main() {
  group('ThemeProvider', () {
    late ThemeProvider themeProvider;

    setUp(() {
      // Reset SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      themeProvider = ThemeProvider();
    });

    test('initial theme mode should be system', () {
      expect(themeProvider.themeMode, AppThemeMode.system);
    });

    test('theme mode label should return correct strings', () {
      expect(themeProvider.themeModeLabel, 'Automatic');
    });

    test('should initialize and load saved theme mode', () async {
      // Set up mock with saved theme
      SharedPreferences.setMockInitialValues({
        'app_theme_mode': 'dark',
      });

      final provider = ThemeProvider();
      await provider.init();

      expect(provider.themeMode, AppThemeMode.dark);
      expect(provider.themeModeLabel, 'Dark');
    });

    test('should set theme mode to light', () async {
      await themeProvider.init();
      await themeProvider.setThemeMode(AppThemeMode.light);

      expect(themeProvider.themeMode, AppThemeMode.light);
      expect(themeProvider.themeModeLabel, 'Light');

      // Verify it was saved to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_theme_mode'), 'light');
    });

    test('should set theme mode to dark', () async {
      await themeProvider.init();
      await themeProvider.setThemeMode(AppThemeMode.dark);

      expect(themeProvider.themeMode, AppThemeMode.dark);
      expect(themeProvider.themeModeLabel, 'Dark');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_theme_mode'), 'dark');
    });

    test('should set theme mode to system', () async {
      await themeProvider.init();
      await themeProvider.setThemeMode(AppThemeMode.system);

      expect(themeProvider.themeMode, AppThemeMode.system);
      expect(themeProvider.themeModeLabel, 'Automatic');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_theme_mode'), 'system');
    });

    test('should notify listeners when theme mode changes', () async {
      await themeProvider.init();

      var notified = false;
      themeProvider.addListener(() {
        notified = true;
      });

      await themeProvider.setThemeMode(AppThemeMode.dark);

      expect(notified, true);
    });

    test('should handle missing saved theme by defaulting to system', () async {
      SharedPreferences.setMockInitialValues({});

      final provider = ThemeProvider();
      await provider.init();

      expect(provider.themeMode, AppThemeMode.system);
    });

    test('should handle invalid saved theme by defaulting to system', () async {
      SharedPreferences.setMockInitialValues({
        'app_theme_mode': 'invalid_mode',
      });

      final provider = ThemeProvider();
      await provider.init();

      expect(provider.themeMode, AppThemeMode.system);
    });

    test('isDarkMode should return false for light mode', () async {
      await themeProvider.init();
      await themeProvider.setThemeMode(AppThemeMode.light);

      expect(themeProvider.isDarkMode, false);
    });

    test('isDarkMode should return true for dark mode', () async {
      await themeProvider.init();
      await themeProvider.setThemeMode(AppThemeMode.dark);

      expect(themeProvider.isDarkMode, true);
    });

    test('isDarkMode should return false for system mode (default)', () async {
      await themeProvider.init();
      await themeProvider.setThemeMode(AppThemeMode.system);

      // System mode falls back to light in the implementation
      expect(themeProvider.isDarkMode, false);
    });

    test('should persist theme mode across provider instances', () async {
      // First provider sets dark mode
      final provider1 = ThemeProvider();
      await provider1.init();
      await provider1.setThemeMode(AppThemeMode.dark);

      // Second provider should load dark mode
      final provider2 = ThemeProvider();
      await provider2.init();

      expect(provider2.themeMode, AppThemeMode.dark);
    });
  });
}
