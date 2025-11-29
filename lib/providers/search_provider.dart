import 'package:flutter/material.dart';

class SearchProvider extends ChangeNotifier {
  String _destination = '';
  String _destinationCity = '';
  String _destinationCountry = '';
  String _origin = 'Lahore (LHE)'; // Default origin

  String get destination => _destination;
  String get destinationCity => _destinationCity;
  String get destinationCountry => _destinationCountry;
  String get origin => _origin;

  // Get formatted destination for hotels (City, Country)
  String get hotelDestination {
    if (_destinationCity.isNotEmpty && _destinationCountry.isNotEmpty) {
      return '$_destinationCity, $_destinationCountry';
    }
    // Fallback: try to extract city from destination
    if (_destination.isNotEmpty) {
      // Remove airport code if present (e.g., "Dubai (DXB)" -> "Dubai")
      final match = RegExp(r'^([^(]+)').firstMatch(_destination);
      if (match != null) {
        return match.group(1)!.trim();
      }
    }
    return _destination;
  }

  void setDestination(String newDestination, {String? city, String? country}) {
    if (_destination != newDestination) {
      _destination = newDestination;
      _destinationCity = city ?? '';
      _destinationCountry = country ?? '';
      notifyListeners();
    }
  }

  void setOrigin(String newOrigin) {
    if (_origin != newOrigin) {
      _origin = newOrigin;
      notifyListeners();
    }
  }
}
