import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phptravels/providers/currency_provider.dart';

void main() {
  group('CurrencyProvider', () {
    late CurrencyProvider currencyProvider;

    setUp(() {
      // Reset SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      currencyProvider = CurrencyProvider();
    });

    test('should initialize with PKR as default currency', () async {
      await currencyProvider.init();

      expect(currencyProvider.currencyCode, 'PKR');
      expect(currencyProvider.currencySymbol, 'PKR');
      expect(currencyProvider.currentCurrency.name, 'Pakistani Rupee');
    });

    test('should load saved currency from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'app_currency': 'USD',
      });

      final provider = CurrencyProvider();
      await provider.init();

      expect(provider.currencyCode, 'USD');
      expect(provider.currencySymbol, '\$');
    });

    test('should switch currency to USD', () async {
      await currencyProvider.init();
      await currencyProvider.setCurrency('USD');

      expect(currencyProvider.currencyCode, 'USD');
      expect(currencyProvider.currencySymbol, '\$');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_currency'), 'USD');
    });

    test('should switch currency to EUR', () async {
      await currencyProvider.init();
      await currencyProvider.setCurrency('EUR');

      expect(currencyProvider.currencyCode, 'EUR');
      expect(currencyProvider.currencySymbol, '€');
    });

    test('should switch currency to GBP', () async {
      await currencyProvider.init();
      await currencyProvider.setCurrency('GBP');

      expect(currencyProvider.currencyCode, 'GBP');
      expect(currencyProvider.currencySymbol, '£');
    });

    test('should notify listeners when currency changes', () async {
      await currencyProvider.init();

      var notified = false;
      currencyProvider.addListener(() {
        notified = true;
      });

      await currencyProvider.setCurrency('USD');

      expect(notified, true);
    });

    test('should not notify listeners when setting same currency', () async {
      await currencyProvider.init();
      await currencyProvider.setCurrency('USD');

      var notified = false;
      currencyProvider.addListener(() {
        notified = true;
      });

      await currencyProvider.setCurrency('USD');

      expect(notified, false);
    });

    test('should convert PKR to USD correctly', () async {
      await currencyProvider.init();
      await currencyProvider.setCurrency('USD');

      // 280 PKR ≈ 1 USD (rate: 0.0036)
      final converted = currencyProvider.convertFromPKR(280);

      expect(converted, closeTo(1.0, 0.01));
    });

    test('should convert PKR to EUR correctly', () async {
      await currencyProvider.init();
      await currencyProvider.setCurrency('EUR');

      // Test conversion
      final converted = currencyProvider.convertFromPKR(1000);

      expect(converted, closeTo(3.3, 0.1));
    });

    test('should format price in PKR without conversion', () async {
      await currencyProvider.init();

      final formatted = currencyProvider.formatPrice(15000);

      expect(formatted, 'PKR 15,000');
    });

    test('should format price in USD with conversion', () async {
      await currencyProvider.init();
      await currencyProvider.setCurrency('USD');

      // 15000 PKR * 0.0036 = 54 USD
      final formatted = currencyProvider.formatPrice(15000);

      expect(formatted, contains('\$'));
      expect(formatted, contains('54'));
    });

    test('should format price with compact flag', () async {
      await currencyProvider.init();
      await currencyProvider.setCurrency('USD');

      final formatted = currencyProvider.formatPrice(15000, compact: true);

      expect(formatted, contains('USD'));
      expect(formatted, contains('54'));
    });

    test('should format numbers with thousands separator', () async {
      await currencyProvider.init();

      final formatted = currencyProvider.formatPrice(1500000);

      // Should have comma separators
      expect(formatted, contains(','));
      expect(formatted, contains('1,500,000'));
    });

    test('should convert from PKR to specific currency', () async {
      await currencyProvider.init();

      final convertedUSD = currencyProvider.convertFromPKRTo(280, 'USD');
      final convertedEUR = currencyProvider.convertFromPKRTo(1000, 'EUR');

      expect(convertedUSD, closeTo(1.0, 0.01));
      expect(convertedEUR, closeTo(3.3, 0.1));
    });

    test('should format price with specific currency', () async {
      await currencyProvider.init();

      final formattedUSD = currencyProvider.formatPriceWithCurrency(280, 'USD');

      expect(formattedUSD, contains('USD'));
      expect(formattedUSD, contains('1'));
    });

    test('should get symbol for specific currency code', () async {
      await currencyProvider.init();

      expect(currencyProvider.getSymbolForCode('USD'), '\$');
      expect(currencyProvider.getSymbolForCode('EUR'), '€');
      expect(currencyProvider.getSymbolForCode('GBP'), '£');
      expect(currencyProvider.getSymbolForCode('PKR'), 'PKR');
    });

    test('should return all supported currencies', () async {
      await currencyProvider.init();

      final currencies = currencyProvider.supportedCurrencies;

      expect(currencies.length, greaterThanOrEqualTo(6));
      expect(currencies.any((c) => c.code == 'PKR'), true);
      expect(currencies.any((c) => c.code == 'USD'), true);
      expect(currencies.any((c) => c.code == 'EUR'), true);
      expect(currencies.any((c) => c.code == 'GBP'), true);
    });

    test('should handle invalid currency code gracefully', () async {
      await currencyProvider.init();
      await currencyProvider.setCurrency('INVALID');

      // Should remain at current currency (PKR)
      expect(currencyProvider.currencyCode, 'PKR');
    });

    test('should persist currency across provider instances', () async {
      // First provider sets EUR
      final provider1 = CurrencyProvider();
      await provider1.init();
      await provider1.setCurrency('EUR');

      // Second provider should load EUR
      final provider2 = CurrencyProvider();
      await provider2.init();

      expect(provider2.currencyCode, 'EUR');
    });
  });
}
