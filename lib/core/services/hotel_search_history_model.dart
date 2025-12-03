import 'package:intl/intl.dart';

class HotelSearchHistory {
  final String id;
  final String location;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int rooms;
  final int guests;
  final DateTime createdAt;

  HotelSearchHistory({
    required this.id,
    required this.location,
    required this.checkInDate,
    required this.checkOutDate,
    required this.rooms,
    required this.guests,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location': location,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'rooms': rooms,
      'guests': guests,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory HotelSearchHistory.fromJson(Map<String, dynamic> json) {
    return HotelSearchHistory(
      id: json['id'],
      location: json['location'],
      checkInDate: DateTime.parse(json['checkInDate']),
      checkOutDate: DateTime.parse(json['checkOutDate']),
      rooms: json['rooms'],
      guests: json['guests'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  String get formattedDateRange {
    final format = DateFormat('d MMM');
    return '${format.format(checkInDate)} - ${format.format(checkOutDate)}';
  }

  String get displayLocation {
    return location;
  }

  String get guestSummary {
    return '$guests 👤 $rooms 🚪';
  }
}
