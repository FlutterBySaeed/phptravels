import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/search_history_model.dart';

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
}
