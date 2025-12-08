import 'package:flutter_test/flutter_test.dart';
import 'package:phptravels/providers/search_provider.dart';

void main() {
  group('SearchProvider', () {
    late SearchProvider searchProvider;

    setUp(() {
      searchProvider = SearchProvider();
    });

    test('should initialize with default values', () {
      expect(searchProvider.destination, '');
      expect(searchProvider.destinationCity, '');
      expect(searchProvider.destinationCountry, '');
      expect(searchProvider.origin, 'Lahore (LHE)');
    });

    test('should set destination', () {
      searchProvider.setDestination('Dubai (DXB)');

      expect(searchProvider.destination, 'Dubai (DXB)');
    });

    test('should set destination with city and country', () {
      searchProvider.setDestination(
        'Dubai (DXB)',
        city: 'Dubai',
        country: 'United Arab Emirates',
      );

      expect(searchProvider.destination, 'Dubai (DXB)');
      expect(searchProvider.destinationCity, 'Dubai');
      expect(searchProvider.destinationCountry, 'United Arab Emirates');
    });

    test('should set origin', () {
      searchProvider.setOrigin('Karachi (KHI)');

      expect(searchProvider.origin, 'Karachi (KHI)');
    });

    test('should notify listeners when destination changes', () {
      var notified = false;
      searchProvider.addListener(() {
        notified = true;
      });

      searchProvider.setDestination('Dubai (DXB)');

      expect(notified, true);
    });

    test('should notify listeners when origin changes', () {
      var notified = false;
      searchProvider.addListener(() {
        notified = true;
      });

      searchProvider.setOrigin('Karachi (KHI)');

      expect(notified, true);
    });

    test('should not notify listeners when setting same destination', () {
      searchProvider.setDestination('Dubai (DXB)');

      var notified = false;
      searchProvider.addListener(() {
        notified = true;
      });

      searchProvider.setDestination('Dubai (DXB)');

      expect(notified, false);
    });

    test('should not notify listeners when setting same origin', () {
      searchProvider.setOrigin('Karachi (KHI)');

      var notified = false;
      searchProvider.addListener(() {
        notified = true;
      });

      searchProvider.setOrigin('Karachi (KHI)');

      expect(notified, false);
    });

    test('should format hotel destination with city and country', () {
      searchProvider.setDestination(
        'Dubai',
        city: 'Dubai',
        country: 'UAE',
      );

      expect(searchProvider.hotelDestination, 'Dubai, UAE');
    });

    test('should extract city from destination with airport code', () {
      searchProvider.setDestination('Dubai (DXB)');

      expect(searchProvider.hotelDestination, 'Dubai');
    });

    test('should return destination as-is if no city/country set', () {
      searchProvider.setDestination('Some Location');

      expect(searchProvider.hotelDestination, 'Some Location');
    });

    test('should handle empty destination', () {
      expect(searchProvider.hotelDestination, '');
    });

    test('should update city and country when destination changes', () {
      searchProvider.setDestination(
        'Karachi',
        city: 'Karachi',
        country: 'Pakistan',
      );

      expect(searchProvider.destinationCity, 'Karachi');
      expect(searchProvider.destinationCountry, 'Pakistan');

      searchProvider.setDestination(
        'Dubai',
        city: 'Dubai',
        country: 'UAE',
      );

      expect(searchProvider.destinationCity, 'Dubai');
      expect(searchProvider.destinationCountry, 'UAE');
    });
  });
}
