import 'package:intl/intl.dart';

class FlightSearchHistory {
  final String id;
  final String from;
  final String to;
  final DateTime departureDate;
  final DateTime? returnDate;
  final int passengers;
  final String cabinClass;
  final String tripType;
  final DateTime createdAt;
  final List<Map<String, dynamic>>? segments;

  FlightSearchHistory({
    required this.id,
    required this.from,
    required this.to,
    required this.departureDate,
    this.returnDate,
    required this.passengers,
    required this.cabinClass,
    required this.tripType,
    required this.createdAt,
    this.segments,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from': from,
      'to': to,
      'departureDate': departureDate.toIso8601String(),
      'returnDate': returnDate?.toIso8601String(),
      'passengers': passengers,
      'cabinClass': cabinClass,
      'tripType': tripType,
      'createdAt': createdAt.toIso8601String(),
      'segments': segments,
    };
  }

  // Create from JSON
  factory FlightSearchHistory.fromJson(Map<String, dynamic> json) {
    return FlightSearchHistory(
      id: json['id'],
      from: json['from'],
      to: json['to'],
      departureDate: DateTime.parse(json['departureDate']),
      returnDate: json['returnDate'] != null
          ? DateTime.parse(json['returnDate'])
          : null,
      passengers: json['passengers'],
      cabinClass: json['cabinClass'],
      tripType: json['tripType'],
      createdAt: DateTime.parse(json['createdAt']),
      segments: json['segments'] != null
          ? List<Map<String, dynamic>>.from(json['segments'])
          : null,
    );
  }

  String get formattedDateRange {
    final format = DateFormat('d MMM');
    if (tripType == 'multiCity' && segments != null && segments!.isNotEmpty) {
      // For multi-city, show first and last date if different, or just first
      final firstDate = DateTime.parse(segments!.first['date']);
      final lastDate = DateTime.parse(segments!.last['date']);
      if (firstDate.year == lastDate.year &&
          firstDate.month == lastDate.month &&
          firstDate.day == lastDate.day) {
        return format.format(firstDate);
      }
      return '${format.format(firstDate)} - ${format.format(lastDate)}';
    }

    if (returnDate == null) {
      return format.format(departureDate);
    }
    return '${format.format(departureDate)} - ${format.format(returnDate!)}';
  }

  String get displayRoute {
    if (tripType == 'multiCity' && segments != null && segments!.isNotEmpty) {
      // Show each segment on a new line with arrow
      return segments!.map((s) => '${s['from']} → ${s['to']}').join('\n');
    }
    return '$from → $to';
  }
}
