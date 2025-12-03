// lib/config/api_config.dart

class APIConfig {
  static const String aviationStackBaseUrl = 'https://api.aviationstack.com/v1';
  static const String aviationStackApiKey = 'f58520e8632de24b1d9a3050bcea1a19';

  static const String flightsEndpoint = '/flights';
  static const String routesEndpoint = '/routes';
  static const String airlinesEndpoint = '/airlines';

  static const Duration requestTimeout = Duration(seconds: 10);
}
