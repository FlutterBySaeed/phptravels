import 'package:flutter_test/flutter_test.dart';
import 'package:phptravels/features/hotels/models/hotel_result.dart';
import '../fixtures/test_data.dart';

void main() {
  group('HotelResult Model', () {
    test('should create hotel result from JSON', () {
      final json = TestData.hotel1Json;
      final hotel = HotelResult.fromJson(json);

      expect(hotel.id, 'hotel_1');
      expect(hotel.name, 'Grand Plaza Hotel');
      expect(hotel.category, 'Luxury Hotel');
      expect(hotel.starRating, 5);
      expect(hotel.reviewScore, 8.9);
      expect(hotel.rawPricePKR, 15000.0);
      expect(hotel.amenities.length, 4);
      expect(hotel.badges.length, 2);
    });

    test('should convert hotel result to JSON', () {
      final hotel = TestData.hotel1;
      final json = hotel.toJson();

      expect(json['id'], 'hotel_1');
      expect(json['name'], 'Grand Plaza Hotel');
      expect(json['category'], 'Luxury Hotel');
      expect(json['starRating'], 5);
      expect(json['reviewScore'], 8.9);
      expect(json['rawPricePKR'], 15000.0);
      expect(json['amenities'], isA<List>());
      expect(json['badges'], isA<List>());
    });

    test('should handle latitude and longitude correctly', () {
      final hotel = TestData.hotel1;

      expect(hotel.latitude, 24.8607);
      expect(hotel.longitude, 67.0011);
    });

    test('should handle images correctly', () {
      final hotel = TestData.hotel1;

      expect(hotel.mainImage, 'https://example.com/hotel1.jpg');
      expect(hotel.thumbnailImages.length, 2);
      expect(
          hotel.thumbnailImages.first, 'https://example.com/hotel1_thumb1.jpg');
    });

    test('should handle amenities list correctly', () {
      final hotel = TestData.hotel1;

      expect(hotel.amenities.contains('WiFi'), true);
      expect(hotel.amenities.contains('Pool'), true);
      expect(hotel.amenities.contains('Spa'), true);
      expect(hotel.amenities.contains('Restaurant'), true);
    });

    test('should handle badges list correctly', () {
      final hotel = TestData.hotel1;

      expect(hotel.badges.contains('Popular'), true);
      expect(hotel.badges.contains('Best Value'), true);
    });

    test('should serialize and deserialize correctly', () {
      final originalHotel = TestData.hotel1;
      final json = originalHotel.toJson();
      final deserializedHotel = HotelResult.fromJson(json);

      expect(deserializedHotel.id, originalHotel.id);
      expect(deserializedHotel.name, originalHotel.name);
      expect(deserializedHotel.category, originalHotel.category);
      expect(deserializedHotel.latitude, originalHotel.latitude);
      expect(deserializedHotel.longitude, originalHotel.longitude);
      expect(deserializedHotel.starRating, originalHotel.starRating);
      expect(deserializedHotel.reviewScore, originalHotel.reviewScore);
      expect(deserializedHotel.rawPricePKR, originalHotel.rawPricePKR);
    });

    test('should handle multiple hotels with different data', () {
      final hotel1 = TestData.hotel1;
      final hotel2 = TestData.hotel2;

      expect(hotel1.id, isNot(equals(hotel2.id)));
      expect(hotel1.starRating, greaterThan(hotel2.starRating));
      expect(hotel1.rawPricePKR, greaterThan(hotel2.rawPricePKR));
    });
  });
}
