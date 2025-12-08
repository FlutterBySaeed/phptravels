# PHPTRAVELS Testing Guide

## Overview
This document provides guidance on running tests for the PHPTRAVELS Flutter application.

## Test Categories

### 1. Unit Tests
Unit tests verify individual components in isolation.

**Providers Tests:**
- `test/providers/theme_provider_test.dart` - Theme management
- `test/providers/currency_provider_test.dart` - Currency conversion and formatting
- `test/providers/language_provider_test.dart` - Language/locale management
- `test/providers/search_provider_test.dart` - Search state management

**Services Tests:**
- `test/services/search_history_service_test.dart` - Search history persistence

**Models Tests:**
- `test/models/hotel_result_test.dart` - Hotel result model serialization
- `test/models/hotel_room_test.dart` - Hotel room model logic

### 2. Widget Tests
Widget tests verify UI components and user interactions.

**Core Widgets:**
- `test/widgets/custom_date_picker_test.dart` - Date picker widget

### 3. Integration Tests
Integration tests verify complete user flows end-to-end.

- `integration_test/app_test.dart` - Full app integration tests

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/providers/theme_provider_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

### View Coverage Report (HTML)
```bash
# On Windows (PowerShell)
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
Start-Process coverage/html/index.html

# On macOS/Linux
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
```

### Run Integration Tests
```bash
flutter test integration_test/app_test.dart
```

### Run Tests by Category
```bash
# Run all provider tests
flutter test test/providers/

# Run all service tests
flutter test test/services/

# Run all model tests
flutter test test/models/

# Run all widget tests
flutter test test/widgets/
```

## Test File Structure

```
test/
├── fixtures/
│   └── test_data.dart              # Test data fixtures
├── helpers/
│   └── test_helpers.dart           # Test utility functions
├── mocks/
│   └── mock_services.dart          # Mock service definitions
├── providers/
│   ├── theme_provider_test.dart
│   ├── currency_provider_test.dart
│   ├── language_provider_test.dart
│   └── search_provider_test.dart
├── services/
│   └── search_history_service_test.dart
├── models/
│   ├── hotel_result_test.dart
│   └── hotel_room_test.dart
└── widgets/
    └── custom_date_picker_test.dart

integration_test/
└── app_test.dart
```

## Code Coverage Goals

- **Providers**: 100% coverage (critical business logic)
- **Services**: 80%+ coverage
- **Models**: 90%+ coverage (serialization is critical)
- **Widgets**: 60%+ coverage
- **Overall**: 70%+ coverage

## Continuous Integration

Add this to your CI/CD pipeline:

```yaml
# Example for GitHub Actions
- name: Run Tests
  run: flutter test --coverage

- name: Check Coverage
  run: |
    if [ -f coverage/lcov.info ]; then
      echo "Coverage report generated"
    fi
```

## Troubleshooting

### Tests Failing Due to Missing Dependencies
```bash
flutter pub get
```

### Mock Generation Issues
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Clean and Rebuild
```bash
flutter clean
flutter pub get
flutter test
```

## Best Practices

1. **Write Tests First**: Consider TDD (Test-Driven Development)
2. **Keep Tests Isolated**: Each test should be independent
3. **Use Descriptive Names**: Test names should clearly describe what they test
4. **Mock External Dependencies**: Use mocks for APIs, databases, etc.
5. **Test Edge Cases**: Don't just test the happy path
6. **Maintain Tests**: Update tests when code changes

## Writing New Tests

### Unit Test Template
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ComponentName', () {
    setUp(() {
      // Setup before each test
    });

    test('should do something', () {
      // Arrange
      // Act
      // Assert
    });
  });
}
```

### Widget Test Template
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('should display widget', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: YourWidget(),
      ),
    );

    expect(find.byType(YourWidget), findsOneWidget);
  });
}
```

## Additional Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Integration Testing Guide](https://docs.flutter.dev/testing/integration-tests)
