import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, system }

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';
  
  AppThemeMode _themeMode = AppThemeMode.system;
  SharedPreferences? _prefs;
  
  AppThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode {
    if (_themeMode == AppThemeMode.system) {
      return _getSystemBrightness() == Brightness.dark;
    }
    return _themeMode == AppThemeMode.dark;
  }
  
  String get themeModeLabel {
    switch (_themeMode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'Automatic';
    }
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadThemeMode();
  }
  
  Future<void> _loadThemeMode() async {
    if (_prefs == null) return;
    
    final savedMode = _prefs!.getString(_themeKey) ?? 'system';
    _themeMode = _stringToThemeMode(savedMode);
    notifyListeners();
  }
  
  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    
    if (_prefs != null) {
      await _prefs!.setString(_themeKey, _themeModeToString(mode));
    }
    
    notifyListeners();
  }
  
  /// Get system brightness
  Brightness _getSystemBrightness() {
    // final brightness = WidgetsBinding.instance.platformDispatcher.views.first.view.platformDispatcher.implicitView?.window.platformDispatcher.views.first.view.window.physicalSize ?? Size.zero;
    // Fallback to light mode if can't determine
    return Brightness.light;
  }
  
  /// Convert string to AppThemeMode
  AppThemeMode _stringToThemeMode(String value) {
    switch (value.toLowerCase()) {
      case 'dark':
        return AppThemeMode.dark;
      case 'light':
        return AppThemeMode.light;
      case 'system':
      default:
        return AppThemeMode.system;
    }
  }
  
  /// Convert AppThemeMode to string
  String _themeModeToString(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
      case AppThemeMode.system:
        return 'system';
    }
  }
}
