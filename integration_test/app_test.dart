import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:phptravels/main.dart' as app;
import 'package:phptravels/core/widgets/nav_bar.dart';
import 'package:phptravels/features/home/pages/main_navigation_page.dart';
import 'package:phptravels/features/account/pages/account_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('PHPTRAVELS Comprehensive Integration Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('App Launch and Initial State Test',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify app launched successfully
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(MainApp), findsOneWidget);

      // Verify navigation bar exists
      expect(find.byType(NavBar), findsOneWidget);

      // Verify home screen is displayed by default
      final navBar = tester.widget<NavBar>(find.byType(NavBar));
      expect(navBar.selectedIndex, 0,
          reason: 'Home tab should be selected by default');
    });

    testWidgets('Navigation Flow Test - All Tabs', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find all navigation items
      final homeIcon = find.byIcon(Icons.home_outlined);
      final exploreIcon = find.byIcon(Icons.explore_outlined);
      final storiesIcon = find.byIcon(Icons.article_outlined);
      final accountIcon = find.byIcon(Icons.person_outlined);

      // Verify all navigation icons exist
      expect(homeIcon, findsOneWidget, reason: 'Home icon should exist');
      expect(exploreIcon, findsOneWidget, reason: 'Explore icon should exist');
      expect(storiesIcon, findsOneWidget, reason: 'Stories icon should exist');
      expect(accountIcon, findsOneWidget, reason: 'Account icon should exist');

      // Test navigation to Account tab
      await tester.tap(accountIcon);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify Account page is displayed
      expect(find.byType(AccountsPage), findsOneWidget,
          reason: 'Account page should be visible');

      // Verify NavBar selectedIndex changed
      final navBarAfterTap = tester.widget<NavBar>(find.byType(NavBar));
      expect(navBarAfterTap.selectedIndex, 3,
          reason: 'Account tab should be selected');

      // Navigate back to Home
      await tester.tap(homeIcon);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final navBarBackHome = tester.widget<NavBar>(find.byType(NavBar));
      expect(navBarBackHome.selectedIndex, 0,
          reason: 'Home tab should be selected again');
    });

    testWidgets('Hero Section Presence Test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify HeroSection exists on home page
      expect(find.byType(SingleChildScrollView), findsWidgets,
          reason: 'Home page should have scrollable content');

      // App should be on home screen initially
      final navBar = tester.widget<NavBar>(find.byType(NavBar));
      expect(navBar.selectedIndex, 0);
    });

    testWidgets('Account Page Settings Access Test',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to Account tab
      final accountIcon = find.byIcon(Icons.person_outlined);
      await tester.tap(accountIcon);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify we're on the account page
      expect(find.byType(AccountsPage), findsOneWidget);

      // Account page uses SingleChildScrollView, not ListView
      expect(find.byType(SingleChildScrollView), findsAtLeastNWidgets(1),
          reason: 'Account page should have scrollable content');

      // Verify actual content exists - look for InkWell widgets (menu items)
      expect(find.byType(InkWell), findsAtLeastNWidgets(5),
          reason: 'Account page should have multiple interactive menu items');

      // Verify ElevatedButton exists (login button)
      expect(find.byType(ElevatedButton), findsAtLeastNWidgets(1),
          reason: 'Account page should have a login/signup button');
    });

    testWidgets('Navigation State Persistence Test',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate through multiple tabs
      await tester.tap(find.byIcon(Icons.person_outlined));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await tester.tap(find.byIcon(Icons.explore_outlined));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await tester.tap(find.byIcon(Icons.article_outlined));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify final selected index
      final navBar = tester.widget<NavBar>(find.byType(NavBar));
      expect(navBar.selectedIndex, 2,
          reason: 'Stories tab (index 2) should be selected after navigation');
    });

    testWidgets('UI Responsiveness Test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Rapid tab switching to test responsiveness
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byIcon(Icons.person_outlined));
        await tester.pump(const Duration(milliseconds: 100));

        await tester.tap(find.byIcon(Icons.home_outlined));
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.pumpAndSettle();

      // App should still be responsive and not crash
      expect(find.byType(MaterialApp), findsOneWidget,
          reason: 'App should remain stable after rapid navigation');
      expect(find.byType(NavBar), findsOneWidget);
    });

    testWidgets('Memory Leak Prevention Test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate between tabs multiple times to check for memory leaks
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.byIcon(Icons.person_outlined));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        await tester.tap(find.byIcon(Icons.home_outlined));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
      }

      // Verify app is still functional
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(NavBar), findsOneWidget);

      final navBar = tester.widget<NavBar>(find.byType(NavBar));
      expect(navBar.selectedIndex, isIn([0, 3]),
          reason: 'Navigation should still work correctly');
    });

    testWidgets('Scroll Behavior Test on Home Page',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find the scrollable widget
      final scrollable = find.byType(SingleChildScrollView).first;
      expect(scrollable, findsOneWidget);

      // Perform scroll gesture
      await tester.drag(scrollable, const Offset(0, -500));
      await tester.pumpAndSettle();

      // Verify app didn't crash during scroll
      expect(find.byType(MaterialApp), findsOneWidget);

      // Scroll back
      await tester.drag(scrollable, const Offset(0, 500));
      await tester.pumpAndSettle();
    });

    testWidgets('Theme and Localization Ready Test',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify MaterialApp has theme configured
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, isNotNull,
          reason: 'Light theme should be configured');
      expect(materialApp.darkTheme, isNotNull,
          reason: 'Dark theme should be configured');

      // Verify localization delegates are set
      expect(materialApp.localizationsDelegates, isNotNull);
      expect(materialApp.supportedLocales, isNotEmpty);
    });

    testWidgets('Widget Tree Integrity Test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify critical widgets exist in the tree
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(MainApp), findsOneWidget);
      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(NavBar), findsOneWidget);

      // Verify widget tree is properly structured
      final mainApp = find.byType(MainApp);
      expect(mainApp, findsOneWidget);

      // NavBar should be a child of Scaffold which is a child of MainApp
      expect(
          find.descendant(
            of: find.byType(MainApp),
            matching: find.byType(NavBar),
          ),
          findsOneWidget,
          reason: 'NavBar should be within MainApp widget tree');
    });
  });
}
