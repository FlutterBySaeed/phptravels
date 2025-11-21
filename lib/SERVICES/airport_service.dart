import 'dart:convert';
import 'package:http/http.dart' as http;

class AirportService {
  
  static const String _apiKey = '6ea602eb97mshc615bbce6ae965bp10985fjsn4bb364c35aff';
  static const String _baseUrl = 'https://wft-geo-db.p.rapidapi.com/v1/geo/cities';

  static Future<List<Map<String, String>>> fetchCities(String query) async {
    if (query.isEmpty) return [];

    try {
      final uri = Uri.parse('$_baseUrl?namePrefix=$query&limit=10');
      final response = await http.get(uri, headers: {
        'X-RapidAPI-Key': _apiKey,
        'X-RapidAPI-Host': 'wft-geo-db.p.rapidapi.com',
      });

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List data = jsonBody['data'];

        return data.map<Map<String, String>>((city) {
          final countryCode = (city['countryCode'] ?? '').toString().toLowerCase();
          final cityName = city['name'] ?? '';
          final countryName = city['country'] ?? '';
          final flagUrl = countryCode.isNotEmpty
              ? 'https://flagcdn.com/w40/$countryCode.png'
              : '';

          return {
            'name': '$cityName, $countryName',
            'city': cityName,
            'country': countryName,
            'flag': flagUrl,
            'code': countryCode.toUpperCase(),
          };
        }).toList();
      } else {
        // print('🌐 API error: ${response.statusCode}, body: ${response.body}');
        return [];
      }
    } catch (e) {
      // print('⚠️ City fetch error: $e');
      return [];
    }
  }
}
