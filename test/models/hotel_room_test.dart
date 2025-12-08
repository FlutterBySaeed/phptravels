import 'package:flutter_test/flutter_test.dart';
import 'package:phptravels/features/hotels/models/hotel_room.dart';

void main() {
  group('HotelRoom Model', () {
    test('should create hotel room with default values', () {
      final room = HotelRoom();

      expect(room.adults, 2);
      expect(room.children, 0);
      expect(room.childAges, isEmpty);
      expect(room.totalGuests, 2);
    });

    test('should create hotel room with custom values', () {
      final room = HotelRoom(
        adults: 3,
        children: 2,
        childAges: [5, 8],
      );

      expect(room.adults, 3);
      expect(room.children, 2);
      expect(room.childAges.length, 2);
      expect(room.totalGuests, 5);
    });

    test('should calculate total guests correctly', () {
      final room1 = HotelRoom(adults: 2, children: 0);
      expect(room1.totalGuests, 2);

      final room2 = HotelRoom(adults: 2, children: 2);
      expect(room2.totalGuests, 4);

      final room3 = HotelRoom(adults: 1, children: 3);
      expect(room3.totalGuests, 4);
    });

    test('should handle child ages correctly', () {
      final room = HotelRoom(
        adults: 2,
        children: 3,
        childAges: [4, 7, 10],
      );

      expect(room.childAges.length, 3);
      expect(room.childAges[0], 4);
      expect(room.childAges[1], 7);
      expect(room.childAges[2], 10);
    });

    test('should copy hotel room correctly', () {
      final original = HotelRoom(
        adults: 3,
        children: 1,
        childAges: [6],
      );

      final copy = original.copy();

      expect(copy.adults, original.adults);
      expect(copy.children, original.children);
      expect(copy.childAges.length, original.childAges.length);
      expect(copy.childAges.first, original.childAges.first);
    });

    test('should create independent copy', () {
      final original = HotelRoom(
        adults: 2,
        children: 1,
        childAges: [5],
      );

      final copy = original.copy();

      // Modify copy
      copy.adults = 3;
      copy.children = 2;
      copy.childAges.add(8);

      // Original should remain unchanged
      expect(original.adults, 2);
      expect(original.children, 1);
      expect(original.childAges.length, 1);
    });

    test('should handle empty child ages when no children', () {
      final room = HotelRoom(
        adults: 2,
        children: 0,
      );

      expect(room.childAges, isEmpty);
    });

    test('should allow modifying adults count', () {
      final room = HotelRoom(adults: 2);

      room.adults = 4;
      expect(room.adults, 4);
      expect(room.totalGuests, 4);
    });

    test('should allow modifying children count', () {
      final room = HotelRoom(children: 1);

      room.children = 3;
      expect(room.children, 3);
    });

    test('should handle maximum occupancy scenario', () {
      final room = HotelRoom(
        adults: 4,
        children: 2,
        childAges: [3, 6],
      );

      expect(room.totalGuests, 6);
      expect(room.adults, 4);
      expect(room.children, 2);
    });
  });
}
