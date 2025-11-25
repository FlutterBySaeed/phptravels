import 'package:flutter/material.dart';

class AppColors {
  
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color darkBlue = Color(0xFF1D4ED8);
  static const Color lightBlue = Color(0xFFE0F2FE);
  static const Color veryLightBlue = Color(0xFFEFF6FF);
  static const Color background = Color(0xFFFFFFFF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textPrimary = Color.fromARGB(255, 0, 0, 0);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color successGreen = Color(0xFF22C55E);

  // Dark Theme Colors
  static const Color darkBg = Color.fromARGB(255, 0, 0, 0);
  static const Color darkSurfaceHigh = Color(0xFF2A2A2A);
  static const Color darkSurface = Color(0xFF333333);
  static const Color darkTextPrimary = Color(0xFFFFFFFF); // White for primary text
  static const Color darkTextSecondary = Color(0xFFA1A1AA); // Light gray for secondary text
  static const Color darkBorder = Color(0xFF3F3F46);
  static const Color darkError = Color(0xFFEF4444);
}
class AppTextStyles {
  static const TextStyle title = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
  );

  static const TextStyle bodySmall = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    fontFamily: 'Inter',
  );

  static const TextStyle bodyMedium = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    fontFamily: 'Inter',
  );

  static const TextStyle bodyMediumBold = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
  );

  static const TextStyle button = TextStyle(
    color: AppColors.white,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
    letterSpacing: 0.2,
  );
}

class AppThemes {
  /// Light Theme
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: AppColors.white,
      dividerColor: AppColors.borderLight,
      hintColor: AppColors.textSecondary, // Consistent light divider color
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlue,
        secondary: AppColors.darkBlue,
        surface: AppColors.white,
        background: AppColors.background,
        error: Color(0xFFDC2626),
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          fontFamily: 'Inter',
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          fontFamily: 'Inter',
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          fontFamily: 'Inter',
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          fontFamily: 'Inter',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          fontFamily: 'Inter',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          fontFamily: 'Inter',
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          fontFamily: 'Inter',
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkBorder,
          side: const BorderSide(color: AppColors.borderLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        // fillColor: AppColors.veryLightBlue,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: const BorderSide(color: AppColors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.white, width: 2),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight, // Consistent with dividerColor
        thickness: 1,
        space: 0,
      ),
    );
  }

  /// Dark Theme - White Text Only
  static ThemeData darkTheme() {
    return ThemeData(
      hintColor: AppColors.textSecondary,
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: AppColors.darkBg,
      dividerColor: AppColors.darkBorder, // Consistent dark divider color
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryBlue,
        secondary: AppColors.darkBlue,
        surface: AppColors.darkSurface,
        background: AppColors.darkBg,
        error: AppColors.darkError,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.darkTextPrimary,
        onBackground: AppColors.darkTextPrimary,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
          fontFamily: 'Inter',
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
          fontFamily: 'Inter',
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
          fontFamily: 'Inter',
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
          fontFamily: 'Inter',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
          fontFamily: 'Inter',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
          fontFamily: 'Inter',
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          fontFamily: 'Inter',
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurfaceHigh,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.white),
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          side: const BorderSide(color: AppColors.darkBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder, 
        thickness: 1,
        space: 0,
      ),
    );
  }
}