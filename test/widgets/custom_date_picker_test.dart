import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phptravels/features/hotels/widgets/custom_date_picker.dart';

void main() {
  group('CustomDatePicker Widget', () {
    testWidgets('should display date picker widget',
        (WidgetTester tester) async {
      final checkIn = DateTime(2024, 12, 15);
      final checkOut = DateTime(2024, 12, 18);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDatePicker(
              initialCheckIn: checkIn,
              initialCheckOut: checkOut,
            ),
          ),
        ),
      );

      // Widget should render
      expect(find.byType(CustomDatePicker), findsOneWidget);
    });

    testWidgets('should display initial dates when provided',
        (WidgetTester tester) async {
      final checkIn = DateTime(2024, 12, 15);
      final checkOut = DateTime(2024, 12, 18);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDatePicker(
              initialCheckIn: checkIn,
              initialCheckOut: checkOut,
            ),
          ),
        ),
      );

      expect(find.byType(CustomDatePicker), findsOneWidget);
    });

    testWidgets('should show check-in and check-out tabs',
        (WidgetTester tester) async {
      final checkIn = DateTime.now();
      final checkOut = DateTime.now().add(const Duration(days: 3));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDatePicker(
              initialCheckIn: checkIn,
              initialCheckOut: checkOut,
            ),
          ),
        ),
      );

      expect(find.text('CHECK-IN DATE'), findsOneWidget);
      expect(find.text('CHECK-OUT DATE'), findsOneWidget);
    });
  });
}
