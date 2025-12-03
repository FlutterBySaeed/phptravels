// lib/SERVICES/flight_api_service.dart

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:phptravels/core/config/api_config.dart';
import 'package:phptravels/features/flights/models/api_flight_response.dart';
import 'package:phptravels/features/flights/models/flight_result.dart';

class FlightAPIService {
  // Search for flights between two airports
  static Future<List<FlightResult>> searchFlights({
    required String fromIATA,
    required String toIATA,
    required DateTime date,
  }) async {
    try {
      // Build API URL
      final url = Uri.parse(
              '${APIConfig.aviationStackBaseUrl}${APIConfig.flightsEndpoint}')
          .replace(
        queryParameters: {
          'access_key': APIConfig.aviationStackApiKey,
          'dep_iata': fromIATA,
          'arr_iata': toIATA,
          'flight_date': date.toIso8601String().split('T')[0],
          'limit': '20',
        },
      );

      print('Fetching flights from API: $url');

      // Make API request with timeout
      final response = await http.get(url).timeout(APIConfig.requestTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final apiResponse = AviationStackResponse.fromJson(jsonData);

        if (apiResponse.data.isEmpty) {
          print('No flights found from API, using fallback data');
          return _getMockFlights();
        }

        // Convert API data to FlightResult objects
        final flights = apiResponse.data
            .map((flightData) {
              return _convertToFlightResult(flightData);
            })
            .where((flight) => flight != null)
            .cast<FlightResult>()
            .toList();

        print('Successfully fetched ${flights.length} flights from API');
        return flights.isNotEmpty ? flights : _getMockFlights();
      } else {
        print('API request failed with status: ${response.statusCode}');
        return _getMockFlights();
      }
    } catch (e) {
      print('Error fetching flights from API: $e');
      return _getMockFlights();
    }
  }

  // Convert Aviation Stack FlightData to our FlightResult model
  static FlightResult? _convertToFlightResult(FlightData flightData) {
    try {
      // Extract times from scheduled field (format: "2024-01-15T14:30:00+00:00")
      final depTime = _extractTime(flightData.departure?.scheduled);
      final arrTime = _extractTime(flightData.arrival?.scheduled);

      if (depTime == null || arrTime == null) return null;

      // Calculate duration
      final depDateTime = DateTime.parse(flightData.departure!.scheduled!);
      final arrDateTime = DateTime.parse(flightData.arrival!.scheduled!);
      final duration = arrDateTime.difference(depDateTime);
      final durationStr = '${duration.inHours}h ${duration.inMinutes % 60}m';

      // Generate mock price (since API doesn't provide it)
      final mockPrice = _generateMockPrice();

      // Determine if flight is next day
      final isNextDay = arrDateTime.day != depDateTime.day;

      // Determine badges based on flight status
      final badges = <String>[];
      if (flightData.flightStatus == 'scheduled') {
        // Randomly assign badges for demonstration
        if (mockPrice < 26000) badges.add('Cheapest');
        if (duration.inMinutes < 120) badges.add('Fastest');
        if (badges.isNotEmpty) badges.add('Best Value');
      }

      return FlightResult(
        airline: flightData.airline?.name ?? 'Unknown Airline',
        departureTime: depTime,
        arrivalTime: arrTime,
        departureCode: flightData.departure?.iata ?? '',
        arrivalCode: flightData.arrival?.iata ?? '',
        duration: durationStr,
        layoverInfo: 'Direct',
        rawPricePKR: mockPrice,
        badges: badges,
        isNextDay: isNextDay,
        airlineLogo: _getAirlineLogo(flightData.airline?.name),
        flightNumber:
            flightData.flight?.iata ?? flightData.flight?.number ?? 'Unknown',
      );
    } catch (e) {
      print('Error converting flight data: $e');
      return null;
    }
  }

  // Extract time from ISO 8601 string (e.g., "14:30" from "2024-01-15T14:30:00+00:00")
  static String? _extractTime(String? isoString) {
    if (isoString == null) return null;
    try {
      final dateTime = DateTime.parse(isoString);
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (e) {
      return null;
    }
  }

  // Generate mock price (API doesn't provide pricing)
  static double _generateMockPrice() {
    final random = Random();
    // Generate price between PKR 20,000 and 35,000
    return 20000 + random.nextDouble() * 15000;
  }

  // Map airline name to logo identifier
  static String _getAirlineLogo(String? airlineName) {
    if (airlineName == null) return 'default';

    final name = airlineName.toLowerCase();
    if (name.contains('jinnah')) return 'flyjinnah';
    if (name.contains('pia') || name.contains('pakistan international')) {
      return 'pia';
    }
    if (name.contains('airblue')) return 'airblue';
    if (name.contains('serene')) return 'serene';

    return 'default';
  }

  // Fallback mock data (existing sample flights)
  static List<FlightResult> _getMockFlights() {
    return [
      FlightResult(
        airline: 'Fly Jinnah',
        departureTime: '07:05',
        arrivalTime: '09:00',
        departureCode: 'LHE',
        arrivalCode: 'KHI',
        duration: '1h 55m',
        layoverInfo: 'Direct',
        rawPricePKR: 24474,
        badges: ['Cheapest', 'Best Value'],
        isNextDay: false,
        airlineLogo: 'flyjinnah',
      ),
      FlightResult(
        airline: 'Pakistan International Airlines',
        departureTime: '19:00',
        arrivalTime: '20:45',
        departureCode: 'LHE',
        arrivalCode: 'KHI',
        duration: '1h 45m',
        layoverInfo: 'Direct',
        rawPricePKR: 28536,
        badges: [],
        isNextDay: false,
        airlineLogo: 'pia',
      ),
      FlightResult(
        airline: 'Pakistan International Airlines',
        departureTime: '17:00',
        arrivalTime: '18:45',
        departureCode: 'LHE',
        arrivalCode: 'KHI',
        duration: '1h 45m',
        layoverInfo: 'Direct',
        rawPricePKR: 28536,
        badges: [],
        isNextDay: false,
        airlineLogo: 'pia',
      ),
      FlightResult(
        airline: 'Pakistan International Airlines',
        departureTime: '11:00',
        arrivalTime: '12:45',
        departureCode: 'LHE',
        arrivalCode: 'KHI',
        duration: '1h 45m',
        layoverInfo: 'Direct',
        rawPricePKR: 28536,
        badges: [],
        isNextDay: false,
        airlineLogo: 'pia',
      ),
    ];
  }
}
