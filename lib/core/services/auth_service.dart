// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'https://gorest.co.in/public/v2';
  static final SecureStorage _storage = SecureStorage();
  static Future<String?> get accessToken async {
    return await SecureStorage.getToken();
  }

  static Future<void> setAccessToken(String token) async {
    await SecureStorage.saveToken(token);
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final token = await accessToken;

    if (token == null) {
      throw Exception('Please set your GoRest token first');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/users?page=1&per_page=1'),
      headers: _getHeaders(token),
    );

    if (response.statusCode == 200) {
      return {
        'success': true,
        'token': token,
        'user': {
          'id': 1,
          'name': 'Test User',
          'email': email,
        }
      };
    } else {
      throw Exception('Invalid token or authentication failed');
    }
  }

  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String gender,
    required String status,
  }) async {
    final token = await accessToken;

    if (token == null) {
      throw Exception('Please set your GoRest token first');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: _getHeaders(token),
      body: jsonEncode({
        'name': name,
        'email': email,
        'gender': gender,
        'status': status,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return {
        'success': true,
        'message': 'User created successfully',
        'user': data,
      };
    } else if (response.statusCode == 422) {
      final error = jsonDecode(response.body);
      throw Exception(
          'Validation error: ${error[0]['field']} ${error[0]['message']}');
    } else {
      throw Exception('Signup failed: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    final token = await accessToken;

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/users?page=1&per_page=1'),
      headers: _getHeaders(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data[0]; // Return first user
    } else {
      throw Exception('Failed to fetch user: ${response.statusCode}');
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateProfile(
      int userId, Map<String, dynamic> data) async {
    final token = await accessToken;

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId'),
      headers: _getHeaders(token),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Update failed: ${response.statusCode}');
    }
  }

  // Delete user account
  static Future<void> deleteAccount(int userId) async {
    final token = await accessToken;

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/users/$userId'),
      headers: _getHeaders(token),
    );

    if (response.statusCode != 204) {
      throw Exception('Delete failed: ${response.statusCode}');
    }
  }

  // Password reset (simulated - GoRest doesn't have this)
  static Future<void> resetPassword(String email) async {
    // In real app, this would call your backend
    await Future.delayed(Duration(seconds: 2));

    // Simulate API call
    return;
  }

  // =========== HELPER METHODS ===========

  static Map<String, String> _getHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  static Future<void> deleteToken() async {
    await SecureStorage.deleteToken();
    await SecureStorage.deleteUserData();
  }
}

// Secure Storage Helper
class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }

  static Future<void> saveUserData(Map<String, dynamic> user) async {
    await _storage.write(key: 'user_data', value: jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final data = await _storage.read(key: 'user_data');
    return data != null ? jsonDecode(data) : null;
  }

  static Future<void> deleteUserData() async {
    await _storage.delete(key: 'user_data');
  }
}
