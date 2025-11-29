// lib/SERVICES/hotel_api_service.dart

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:phptravels/MODELS/hotel_result.dart';

class HotelAPIService {
  static const String _baseUrl = 'https://www.kayak.com/mvm/smartyv2/search';

  /// Search for hotels in a given location
  static Future<List<HotelResult>> searchHotels({
    required String location,
  }) async {
    try {
      // Build API URL
      final url = Uri.parse(_baseUrl).replace(
        queryParameters: {
          'f': 'j',
          's': 'hotelsonly',
          'where': location.toLowerCase(),
        },
      );

      print('Fetching hotels from API: $url');

      // Make API request with timeout
      final response = await http.get(url).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        if (jsonData.isEmpty) {
          print('No hotels found from API, using fallback data');
          return _getMockHotels();
        }

        // Convert API data to HotelResult objects
        final hotels = jsonData
            .map((hotelData) => _convertToHotelResult(hotelData))
            .where((hotel) => hotel != null)
            .cast<HotelResult>()
            .toList();

        print('Successfully fetched ${hotels.length} hotels from API');
        return hotels.isNotEmpty ? hotels : _getMockHotels();
      } else {
        print('API request failed with status: ${response.statusCode}');
        return _getMockHotels();
      }
    } catch (e) {
      print('Error fetching hotels from API: $e');
      return _getMockHotels();
    }
  }

  /// Convert Kayak API response to HotelResult model
  static HotelResult? _convertToHotelResult(Map<String, dynamic> data) {
    try {
      final id = data['id']?.toString() ?? '';
      final name = data['hotelname']?.toString() ??
          data['displayname']?.toString() ??
          'Unknown Hotel';
      final lat = (data['lat'] as num?)?.toDouble() ?? 0.0;
      final lng = (data['lng'] as num?)?.toDouble() ?? 0.0;

      // Determine category from display type
      String category = 'HOTEL';
      final displayType = data['displayType'];
      if (displayType != null && displayType is Map) {
        final typeName = displayType['displayName']?.toString() ?? 'Hotel';
        category = typeName.toUpperCase();
      }

      // Generate mock data for fields not in API
      final mockPrice = _generateMockPrice();
      final mockRating = _generateMockRating();
      final mockStars = _generateMockStars();

      return HotelResult(
        id: id,
        name: name,
        category: category,
        latitude: lat,
        longitude: lng,
        mainImage: 'https://via.placeholder.com/400x200',
        thumbnailImages: [
          'https://via.placeholder.com/150x100',
          'https://via.placeholder.com/150x100',
        ],
        starRating: mockStars,
        reviewScore: mockRating,
        reviewLabel: _getRatingLabel(mockRating),
        rawPricePKR: mockPrice,
        amenities: _generateMockAmenities(),
        badges: [],
      );
    } catch (e) {
      print('Error converting hotel data: $e');
      return null;
    }
  }

  /// Generate mock price (API doesn't provide pricing)
  static double _generateMockPrice() {
    final random = Random();
    // Generate price between PKR 8,000 and 45,000
    return 8000 + random.nextDouble() * 37000;
  }

  /// Generate mock star rating (1-5 stars)
  static int _generateMockStars() {
    final random = Random();
    final weights = [0.0, 0.1, 0.2, 0.3, 0.4]; // Higher chance for more stars
    final value = random.nextDouble();

    if (value < weights[0]) return 1;
    if (value < weights[1]) return 2;
    if (value < weights[2]) return 3;
    if (value < weights[3]) return 4;
    return random.nextBool() ? 4 : 5; // Mix of 4 and 5 stars
  }

  /// Generate mock review score (0-10)
  static double _generateMockRating() {
    final random = Random();
    // Generate rating between 5.0 and 9.5
    return 5.0 + random.nextDouble() * 4.5;
  }

  /// Get rating label based on score
  static String _getRatingLabel(double score) {
    if (score >= 9.0) return 'Excellent';
    if (score >= 8.0) return 'Very Good';
    if (score >= 7.0) return 'Good';
    if (score >= 6.0) return 'Fair';
    return 'Poor';
  }

  /// Generate mock amenities
  static List<String> _generateMockAmenities() {
    final random = Random();
    final allAmenities = [
      'Breakfast Included',
      'Free WiFi',
      'Pool',
      'Gym',
      'Parking',
      'Restaurant',
    ];

    final count = 1 + random.nextInt(3); // 1-3 amenities
    allAmenities.shuffle(random);
    return allAmenities.take(count).toList();
  }

  /// Fallback mock data
  static List<HotelResult> _getMockHotels() {
    return [
      HotelResult(
        id: '1',
        name: 'Pearl Continental Lahore',
        category: 'HOTEL',
        latitude: 31.5204,
        longitude: 74.3587,
        mainImage: 'https://via.placeholder.com/400x200',
        thumbnailImages: [
          'https://via.placeholder.com/150x100',
          'https://via.placeholder.com/150x100',
        ],
        starRating: 4,
        reviewScore: 6.8,
        reviewLabel: 'Poor',
        rawPricePKR: 37946,
        amenities: ['Breakfast Included'],
        badges: [],
      ),
      HotelResult(
        id: '2',
        name: 'Professional Lahore Hostels',
        category: 'HOSTEL / BACKPACKERS',
        latitude: 31.5497,
        longitude: 74.3436,
        mainImage: 'https://via.placeholder.com/400x200',
        thumbnailImages: [
          'https://via.placeholder.com/150x100',
          'https://via.placeholder.com/150x100',
        ],
        starRating: 0,
        reviewScore: 0,
        reviewLabel: '',
        rawPricePKR: 9794,
        amenities: [],
        badges: [],
      ),
      HotelResult(
        id: '3',
        name: 'Rose Palace Hotel Gulberg',
        category: 'HOTEL',
        latitude: 31.5097,
        longitude: 74.3440,
        mainImage: 'https://via.placeholder.com/400x200',
        thumbnailImages: [
          'https://via.placeholder.com/150x100',
          'https://via.placeholder.com/150x100',
        ],
        starRating: 3,
        reviewScore: 8.2,
        reviewLabel: 'Very Good',
        rawPricePKR: 15450,
        amenities: ['Breakfast Included'],
        badges: [],
      ),
    ];
  }
}
