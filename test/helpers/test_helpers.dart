// Test helper functions and utilities
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phptravels/providers/theme_provider.dart';
import 'package:phptravels/providers/currency_provider.dart';
import 'package:phptravels/providers/language_provider.dart';
import 'package:phptravels/providers/search_provider.dart';

class TestHelpers {
  static Future<void> setupMockSharedPreferences({
    Map<String, Object>? initialValues,
  }) async {
    SharedPreferences.setMockInitialValues(initialValues ?? {});
  }

  /// Create a MaterialApp wrapper for widget testing with all providers
  static Widget createTestApp({
    required Widget child,
    ThemeProvider? themeProvider,
    CurrencyProvider? currencyProvider,
    LanguageProvider? languageProvider,
    SearchProvider? searchProvider,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => themeProvider ?? ThemeProvider(),
        ),
        ChangeNotifierProvider<CurrencyProvider>(
          create: (_) => currencyProvider ?? CurrencyProvider(),
        ),
        ChangeNotifierProvider<LanguageProvider>(
          create: (_) => languageProvider ?? LanguageProvider(),
        ),
        ChangeNotifierProvider<SearchProvider>(
          create: (_) => searchProvider ?? SearchProvider(),
        ),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  /// Create a simple MaterialApp wrapper for basic widget testing
  static Widget createSimpleTestApp({required Widget child}) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  /// Pump widget and settle all animations
  static Future<void> pumpAndSettleWidget(
    WidgetTester tester,
    Widget widget, {
    Duration? duration,
  }) async {
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle(duration ?? const Duration(seconds: 1));
  }

  /// Wait for a specific duration during tests
  static Future<void> wait(Duration duration) async {
    await Future.delayed(duration);
  }

  /// Find text in widget tree
  static Finder findTextWidget(String text) {
    return find.text(text);
  }

  /// Find widget by key
  static Finder findByKey(Key key) {
    return find.byKey(key);
  }

  /// Find widget by type
  static Finder findByType<T>() {
    return find.byType(T);
  }

  /// Tap on widget and settle
  static Future<void> tapAndSettle(
    WidgetTester tester,
    Finder finder,
  ) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Enter text and settle
  static Future<void> enterTextAndSettle(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  /// Verify widget exists
  static void verifyWidgetExists(Finder finder, {int count = 1}) {
    expect(finder, findsNWidgets(count));
  }

  /// Verify text exists
  static void verifyTextExists(String text, {int count = 1}) {
    expect(find.text(text), findsNWidgets(count));
  }

  /// Verify widget doesn't exist
  static void verifyWidgetNotExists(Finder finder) {
    expect(finder, findsNothing);
  }
}

/// Mock data builders for testing
class TestDataBuilders {
  /// Build a mock hotel result JSON
  static Map<String, dynamic> buildHotelJson({
    String id = 'test_hotel',
    String name = 'Test Hotel',
    double price = 10000.0,
    int starRating = 4,
    double reviewScore = 8.0,
  }) {
    return {
      'id': id,
      'name': name,
      'category': 'Hotel',
      'latitude': 24.8607,
      'longitude': 67.0011,
      'mainImage': 'https://example.com/hotel.jpg',
      'thumbnailImages': ['https://example.com/thumb.jpg'],
      'starRating': starRating,
      'reviewScore': reviewScore,
      'reviewLabel': 'Good',
      'rawPricePKR': price,
      'amenities': ['WiFi'],
      'badges': ['Popular'],
    };
  }
}
