// Mock classes for services used in testing
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:phptravels/core/services/location_service.dart';

// Generate mocks by running: flutter pub run build_runner build
@GenerateMocks([
  http.Client,
  LocationService,
])
void main() {}
