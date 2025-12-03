import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phptravels/core/services/search_history_model.dart';
import 'package:phptravels/core/services/hotel_search_history_model.dart';
import 'package:phptravels/core/services/recent_destination_model.dart';

class SearchHistoryService {
  static const String _storageKey = 'flight_search_history';
  static const int _maxHistoryItems = 10;

  // Save search to history
  static Future<void> saveSearch(FlightSearchHistory search) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? existingData = prefs.getStringList(_storageKey);

      List<Map<String, dynamic>> history = existingData
              ?.map((item) => jsonDecode(item) as Map<String, dynamic>)
              .toList() ??
          [];

      // Add new search to the beginning
      history.insert(0, search.toJson());

      // Keep only recent searches and remove duplicates
      history = _removeDuplicates(history);
      if (history.length > _maxHistoryItems) {
        history = history.sublist(0, _maxHistoryItems);
      }

      // Save back to storage
      final jsonList = history.map((item) => jsonEncode(item)).toList();
      await prefs.setStringList(_storageKey, jsonList);
    } catch (e) {
      print('Error saving search history: $e');
    }
  }

  // Get all searches
  static Future<List<FlightSearchHistory>> getSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? data = prefs.getStringList(_storageKey);

      if (data == null || data.isEmpty) return [];

      return data
          .map((item) => FlightSearchHistory.fromJson(jsonDecode(item)))
          .toList();
    } catch (e) {
      print('Error retrieving search history: $e');
      return [];
    }
  }

  // Delete a specific search
  static Future<void> deleteSearch(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? existingData = prefs.getStringList(_storageKey);

      if (existingData == null) return;

      List<Map<String, dynamic>> history = existingData
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();

      history.removeWhere((item) => item['id'] == id);

      final jsonList = history.map((item) => jsonEncode(item)).toList();
      await prefs.setStringList(_storageKey, jsonList);
    } catch (e) {
      print('Error deleting search: $e');
    }
  }

  // Clear all history
  static Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      print('Error clearing history: $e');
    }
  }

  // Remove duplicate searches (same route, date, passengers)
  static List<Map<String, dynamic>> _removeDuplicates(
      List<Map<String, dynamic>> history) {
    final seen = <String>{};
    return history.where((item) {
      String key;
      if (item['tripType'] == 'multiCity' && item['segments'] != null) {
        // Create unique key for multi-city based on all segments
        final segments = item['segments'] as List;
        final segmentsKey = segments
            .map((s) => '${s['from']}_${s['to']}_${s['date']}')
            .join('|');
        key = 'multiCity_$segmentsKey';
      } else {
        key = '${item['from']}_${item['to']}_${item['departureDate']}';
      }

      if (seen.contains(key)) return false;
      seen.add(key);
      return true;
    }).toList();
  }

  // ==================== Hotel Search History ====================

  static const String _hotelStorageKey = 'hotel_search_history';

  // Save hotel search to history
  static Future<void> saveHotelSearch(HotelSearchHistory search) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? existingData = prefs.getStringList(_hotelStorageKey);

      List<Map<String, dynamic>> history = existingData
              ?.map((item) => jsonDecode(item) as Map<String, dynamic>)
              .toList() ??
          [];

      // Add new search to the beginning
      history.insert(0, search.toJson());

      // Keep only recent searches and remove duplicates
      history = _removeHotelDuplicates(history);
      if (history.length > _maxHistoryItems) {
        history = history.sublist(0, _maxHistoryItems);
      }

      // Save back to storage
      final jsonList = history.map((item) => jsonEncode(item)).toList();
      await prefs.setStringList(_hotelStorageKey, jsonList);
    } catch (e) {
      print('Error saving hotel search history: $e');
    }
  }

  // Get all hotel searches
  static Future<List<HotelSearchHistory>> getHotelSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? data = prefs.getStringList(_hotelStorageKey);

      if (data == null || data.isEmpty) return [];

      return data
          .map((item) => HotelSearchHistory.fromJson(jsonDecode(item)))
          .toList();
    } catch (e) {
      print('Error retrieving hotel search history: $e');
      return [];
    }
  }

  // Delete a specific hotel search
  static Future<void> deleteHotelSearch(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? existingData = prefs.getStringList(_hotelStorageKey);

      if (existingData == null) return;

      List<Map<String, dynamic>> history = existingData
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();

      history.removeWhere((item) => item['id'] == id);

      final jsonList = history.map((item) => jsonEncode(item)).toList();
      await prefs.setStringList(_hotelStorageKey, jsonList);
    } catch (e) {
      print('Error deleting hotel search: $e');
    }
  }

  // Clear all hotel history
  static Future<void> clearHotelHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_hotelStorageKey);
    } catch (e) {
      print('Error clearing hotel history: $e');
    }
  }

  // Remove duplicate hotel searches (same location, check-in date)
  static List<Map<String, dynamic>> _removeHotelDuplicates(
      List<Map<String, dynamic>> history) {
    final seen = <String>{};
    return history.where((item) {
      final key = '${item['location']}_${item['checkInDate']}';
      if (seen.contains(key)) return false;
      seen.add(key);
      return true;
    }).toList();
  }

  // ==================== Recent Destinations ====================

  static const String _destinationStorageKey = 'recent_destinations';
  static const int _maxDestinations = 5;

  // Save recent destination
  static Future<void> saveRecentDestination(
      RecentDestination destination) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? existingData =
          prefs.getStringList(_destinationStorageKey);

      List<Map<String, dynamic>> destinations = existingData
              ?.map((item) => jsonDecode(item) as Map<String, dynamic>)
              .toList() ??
          [];

      // Add new destination to the beginning
      destinations.insert(0, destination.toJson());

      // Remove duplicates (same city+country)
      destinations = _removeDestinationDuplicates(destinations);
      if (destinations.length > _maxDestinations) {
        destinations = destinations.sublist(0, _maxDestinations);
      }

      // Save back to storage
      final jsonList = destinations.map((item) => jsonEncode(item)).toList();
      await prefs.setStringList(_destinationStorageKey, jsonList);
    } catch (e) {
      print('Error saving recent destination: $e');
    }
  }

  // Get recent destinations
  static Future<List<RecentDestination>> getRecentDestinations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? data = prefs.getStringList(_destinationStorageKey);

      if (data == null || data.isEmpty) return [];

      return data
          .map((item) => RecentDestination.fromJson(jsonDecode(item)))
          .toList();
    } catch (e) {
      print('Error retrieving recent destinations: $e');
      return [];
    }
  }

  // Clear recent destinations
  static Future<void> clearRecentDestinations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_destinationStorageKey);
    } catch (e) {
      print('Error clearing recent destinations: $e');
    }
  }

  // Remove duplicate destinations (same city+country)
  static List<Map<String, dynamic>> _removeDestinationDuplicates(
      List<Map<String, dynamic>> destinations) {
    final seen = <String>{};
    return destinations.where((item) {
      final key = '${item['city']}_${item['country']}';
      if (seen.contains(key)) return false;
      seen.add(key);
      return true;
    }).toList();
  }
}
