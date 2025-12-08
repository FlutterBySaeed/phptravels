// Test fixtures and sample data for testing
import 'package:phptravels/features/hotels/models/hotel_result.dart';
import 'package:phptravels/features/hotels/models/hotel_room.dart';
import 'package:phptravels/core/services/search_history_model.dart';
import 'package:phptravels/core/services/hotel_search_history_model.dart';
import 'package:phptravels/core/services/recent_destination_model.dart';

class TestData {
  // Sample Hotel Data
  static final hotel1 = HotelResult(
    id: 'hotel_1',
    name: 'Grand Plaza Hotel',
    category: 'Luxury Hotel',
    latitude: 24.8607,
    longitude: 67.0011,
    mainImage: 'https://example.com/hotel1.jpg',
    thumbnailImages: [
      'https://example.com/hotel1_thumb1.jpg',
      'https://example.com/hotel1_thumb2.jpg',
    ],
    starRating: 5,
    reviewScore: 8.9,
    reviewLabel: 'Excellent',
    rawPricePKR: 15000.0,
    amenities: ['WiFi', 'Pool', 'Spa', 'Restaurant'],
    badges: ['Popular', 'Best Value'],
  );

  static final hotel2 = HotelResult(
    id: 'hotel_2',
    name: 'City View Inn',
    category: 'Budget Hotel',
    latitude: 24.8700,
    longitude: 67.0100,
    mainImage: 'https://example.com/hotel2.jpg',
    thumbnailImages: [
      'https://example.com/hotel2_thumb1.jpg',
    ],
    starRating: 3,
    reviewScore: 7.5,
    reviewLabel: 'Good',
    rawPricePKR: 5000.0,
    amenities: ['WiFi', 'Breakfast'],
    badges: ['Budget Friendly'],
  );

  static List<HotelResult> get sampleHotels => [hotel1, hotel2];

  // Sample Hotel Room Configuration Data
  static final room1 = HotelRoom(
    adults: 2,
    children: 0,
    childAges: [],
  );

  static final room2 = HotelRoom(
    adults: 2,
    children: 2,
    childAges: [5, 8],
  );

  static List<HotelRoom> get sampleRooms => [room1, room2];

  // Sample Search History
  static final flightSearch1 = FlightSearchHistory(
    id: 'flight_1',
    from: 'KHI',
    to: 'DXB',
    departureDate: DateTime(2024, 12, 15),
    returnDate: DateTime(2024, 12, 22),
    passengers: 2,
    cabinClass: 'Economy',
    tripType: 'Round Trip',
    createdAt: DateTime(2024, 12, 1),
  );

  static final hotelSearch1 = HotelSearchHistory(
    id: 'hotel_search_1',
    location: 'Karachi, Pakistan',
    checkInDate: DateTime(2024, 12, 15),
    checkOutDate: DateTime(2024, 12, 18),
    guests: 2,
    rooms: 1,
    createdAt: DateTime(2024, 12, 1),
  );

  static final recentDestination1 = RecentDestination(
    city: 'Karachi',
    country: 'Pakistan',
    searchedAt: DateTime(2024, 12, 1),
  );

  // Currency Test Data
  static const Map<String, double> currencyRates = {
    'PKR': 1.0,
    'USD': 0.0036,
    'EUR': 0.0033,
    'GBP': 0.0028,
    'SAR': 0.0135,
    'EGP': 0.176,
  };

  // Sample JSON for hotel result
  static final hotel1Json = {
    'id': 'hotel_1',
    'name': 'Grand Plaza Hotel',
    'category': 'Luxury Hotel',
    'latitude': 24.8607,
    'longitude': 67.0011,
    'mainImage': 'https://example.com/hotel1.jpg',
    'thumbnailImages': [
      'https://example.com/hotel1_thumb1.jpg',
      'https://example.com/hotel1_thumb2.jpg',
    ],
    'starRating': 5,
    'reviewScore': 8.9,
    'reviewLabel': 'Excellent',
    'rawPricePKR': 15000.0,
    'amenities': ['WiFi', 'Pool', 'Spa', 'Restaurant'],
    'badges': ['Popular', 'Best Value'],
  };
}
