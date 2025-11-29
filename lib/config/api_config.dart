// lib/config/api_config.dart

class APIConfig {
  // Aviation Stack API
  static const String aviationStackBaseUrl = 'https://api.aviationstack.com/v1';
  static const String aviationStackApiKey = 'f58520e8632de24b1d9a3050bcea1a19';

  // API Endpoints
  static const String flightsEndpoint = '/flights';
  static const String routesEndpoint = '/routes';
  static const String airlinesEndpoint = '/airlines';

  // Request timeout
  static const Duration requestTimeout = Duration(seconds: 10);

  // NOTE: In production, move API key to environment variables
  // Use flutter_dotenv or --dart-define for security
}
