import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phptravels/core/services/search_history_service.dart';
import 'package:phptravels/core/services/search_history_model.dart';
import 'package:phptravels/core/services/hotel_search_history_model.dart';
import 'package:phptravels/core/services/recent_destination_model.dart';

void main() {
  group('SearchHistoryService - Flight Search', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('should save flight search history', () async {
      final search = FlightSearchHistory(
        id: 'test_1',
        from: 'KHI',
        to: 'DXB',
        departureDate: DateTime(2024, 12, 15),
        returnDate: DateTime(2024, 12, 22),
        passengers: 2,
        cabinClass: 'Economy',
        tripType: 'Round Trip',
        createdAt: DateTime.now(),
      );

      await SearchHistoryService.saveSearch(search);

      final history = await SearchHistoryService.getSearchHistory();
      expect(history.length, 1);
      expect(history.first.from, 'KHI');
      expect(history.first.to, 'DXB');
    });

    test('should retrieve flight search history', () async {
      // Save multiple searches
      await SearchHistoryService.saveSearch(FlightSearchHistory(
        id: 'test_1',
        from: 'KHI',
        to: 'DXB',
        departureDate: DateTime(2024, 12, 15),
        passengers: 2,
        cabinClass: 'Economy',
        tripType: 'Round Trip',
        createdAt: DateTime.now(),
      ));

      await SearchHistoryService.saveSearch(FlightSearchHistory(
        id: 'test_2',
        from: 'LHE',
        to: 'ISB',
        departureDate: DateTime(2024, 12, 20),
        passengers: 1,
        cabinClass: 'Business',
        tripType: 'One Way',
        createdAt: DateTime.now(),
      ));

      final history = await SearchHistoryService.getSearchHistory();
      expect(history.length, 2);
    });

    test('should delete specific flight search', () async {
      await SearchHistoryService.saveSearch(FlightSearchHistory(
        id: 'test_1',
        from: 'KHI',
        to: 'DXB',
        departureDate: DateTime(2024, 12, 15),
        passengers: 2,
        cabinClass: 'Economy',
        tripType: 'Round Trip',
        createdAt: DateTime.now(),
      ));

      await SearchHistoryService.deleteSearch('test_1');

      final history = await SearchHistoryService.getSearchHistory();
      expect(history.length, 0);
    });

    test('should clear all flight search history', () async {
      await SearchHistoryService.saveSearch(FlightSearchHistory(
        id: 'test_1',
        from: 'KHI',
        to: 'DXB',
        departureDate: DateTime(2024, 12, 15),
        passengers: 2,
        cabinClass: 'Economy',
        tripType: 'Round Trip',
        createdAt: DateTime.now(),
      ));

      await SearchHistoryService.clearHistory();

      final history = await SearchHistoryService.getSearchHistory();
      expect(history.length, 0);
    });

    test('should remove duplicate flight searches', () async {
      final search = FlightSearchHistory(
        id: 'test_1',
        from: 'KHI',
        to: 'DXB',
        departureDate: DateTime(2024, 12, 15),
        passengers: 2,
        cabinClass: 'Economy',
        tripType: 'Round Trip',
        createdAt: DateTime.now(),
      );

      // Save same search twice
      await SearchHistoryService.saveSearch(search);
      await SearchHistoryService.saveSearch(search);

      final history = await SearchHistoryService.getSearchHistory();
      // Should only have one entry due to duplicate removal
      expect(history.length, 1);
    });
  });

  group('SearchHistoryService - Hotel Search', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('should save hotel search history', () async {
      final search = HotelSearchHistory(
        id: 'hotel_1',
        location: 'Karachi, Pakistan',
        checkInDate: DateTime(2024, 12, 15),
        checkOutDate: DateTime(2024, 12, 18),
        guests: 2,
        rooms: 1,
        createdAt: DateTime.now(),
      );

      await SearchHistoryService.saveHotelSearch(search);

      final history = await SearchHistoryService.getHotelSearchHistory();
      expect(history.length, 1);
      expect(history.first.location, 'Karachi, Pakistan');
    });

    test('should retrieve hotel search history', () async {
      await SearchHistoryService.saveHotelSearch(HotelSearchHistory(
        id: 'hotel_1',
        location: 'Karachi, Pakistan',
        checkInDate: DateTime(2024, 12, 15),
        checkOutDate: DateTime(2024, 12, 18),
        guests: 2,
        rooms: 1,
        createdAt: DateTime.now(),
      ));

      await SearchHistoryService.saveHotelSearch(HotelSearchHistory(
        id: 'hotel_2',
        location: 'Dubai, UAE',
        checkInDate: DateTime(2024, 12, 20),
        checkOutDate: DateTime(2024, 12, 25),
        guests: 3,
        rooms: 2,
        createdAt: DateTime.now(),
      ));

      final history = await SearchHistoryService.getHotelSearchHistory();
      expect(history.length, 2);
    });

    test('should delete specific hotel search', () async {
      await SearchHistoryService.saveHotelSearch(HotelSearchHistory(
        id: 'hotel_1',
        location: 'Karachi, Pakistan',
        checkInDate: DateTime(2024, 12, 15),
        checkOutDate: DateTime(2024, 12, 18),
        guests: 2,
        rooms: 1,
        createdAt: DateTime.now(),
      ));

      await SearchHistoryService.deleteHotelSearch('hotel_1');

      final history = await SearchHistoryService.getHotelSearchHistory();
      expect(history.length, 0);
    });

    test('should clear all hotel search history', () async {
      await SearchHistoryService.saveHotelSearch(HotelSearchHistory(
        id: 'hotel_1',
        location: 'Karachi, Pakistan',
        checkInDate: DateTime(2024, 12, 15),
        checkOutDate: DateTime(2024, 12, 18),
        guests: 2,
        rooms: 1,
        createdAt: DateTime.now(),
      ));

      await SearchHistoryService.clearHotelHistory();

      final history = await SearchHistoryService.getHotelSearchHistory();
      expect(history.length, 0);
    });
  });

  group('SearchHistoryService - Recent Destinations', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('should save recent destination', () async {
      final destination = RecentDestination(
        city: 'Karachi',
        country: 'Pakistan',
        searchedAt: DateTime.now(),
      );

      await SearchHistoryService.saveRecentDestination(destination);

      final destinations = await SearchHistoryService.getRecentDestinations();
      expect(destinations.length, 1);
      expect(destinations.first.city, 'Karachi');
    });

    test('should retrieve recent destinations', () async {
      await SearchHistoryService.saveRecentDestination(RecentDestination(
        city: 'Karachi',
        country: 'Pakistan',
        searchedAt: DateTime.now(),
      ));

      await SearchHistoryService.saveRecentDestination(RecentDestination(
        city: 'Dubai',
        country: 'UAE',
        searchedAt: DateTime.now(),
      ));

      final destinations = await SearchHistoryService.getRecentDestinations();
      expect(destinations.length, 2);
    });

    test('should clear recent destinations', () async {
      await SearchHistoryService.saveRecentDestination(RecentDestination(
        city: 'Karachi',
        country: 'Pakistan',
        searchedAt: DateTime.now(),
      ));

      await SearchHistoryService.clearRecentDestinations();

      final destinations = await SearchHistoryService.getRecentDestinations();
      expect(destinations.length, 0);
    });
  });
}
