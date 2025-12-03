import 'dart:convert';
import 'package:http/http.dart' as http;

class AirportService {
  static const String _baseUrl = 'https://www.kayak.com/mvm/smartyv2/search';

  static Future<List<Map<String, dynamic>>> fetchAirports(String query) async {
    if (query.isEmpty) return [];

    try {
      final uri = Uri.parse('$_baseUrl?f=j&s=airportonly&where=$query');

      final response = await http.get(
        uri,
        headers: {
          'User-Agent':
              'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1',
          'Accept': 'application/json, text/plain, */*',
          'Accept-Language': 'en-US,en;q=0.9',
          'Referer': 'https://www.kayak.com/flights',
          'Origin': 'https://www.kayak.com',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonBody = json.decode(response.body);

        if (jsonBody.isEmpty) {
          return [];
        }

        return jsonBody
            .where((item) {
              final loctype = item['loctype'] ?? '';

              // Keep all entries with loctype == 'ap' (both individual airports and "All airports" aggregates)
              return loctype == 'ap';
            })
            .map<Map<String, dynamic>>(_parseAirportData)
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Map<String, dynamic> _parseAirportData(dynamic airport) {
    String airportName = '';
    if (airport['entityKey'] != null) {
      final entityKey = airport['entityKey'].toString();
      if (entityKey.startsWith('place:')) {
        airportName = entityKey
            .substring(6) // Remove "place:" prefix
            .replaceAll('_', ' '); // Replace underscores with spaces
      }
    }

    // Fallback to other fields if entityKey doesn't work
    if (airportName.isEmpty) {
      airportName = airport['displayname'] ??
          airport['airportname'] ??
          airport['name'] ??
          airport['cityname'] ??
          '';
    }

    final cityName =
        airport['cityonly'] ?? airport['cityname'] ?? airport['name'] ?? '';

    final countryName = airport['country'] ?? '';

    final airportCode =
        airport['apicode'] ?? airport['ap'] ?? airport['id'] ?? '';

    final countryCode = (airport['cc'] ?? '').toString().toLowerCase();

    // Get loctype to distinguish cities from airports ('ap' = airport)
    final loctype = airport['loctype'] ?? '';

    return {
      'city': cityName,
      'country': countryName,
      'code': airportCode,
      'countryCode': countryCode.toUpperCase(),
      'displayName': '$cityName\\n$countryName',
      'isSelected': false,
      'fullName': airportName,
      'loctype': loctype, // 'ap' for airport, other values for cities
    };
  }
}
