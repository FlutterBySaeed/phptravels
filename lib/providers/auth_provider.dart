import 'package:flutter/foundation.dart';
import 'package:phptravels/core/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;
  String? get error => _error;

  // Initialize token from secure storage
  Future<void> initialize() async {
    try {
      _setLoading(true);
      final token = await SecureStorage.getToken();
      final userData = await SecureStorage.getUserData();

      if (token != null && userData != null) {
        _isAuthenticated = true;
        _user = userData;
      }
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      print('Initialization error: $e');
    }
  }

  // Login with email and password
  Future<void> login(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await ApiService.login(email, password);

      await SecureStorage.saveToken(response['token']);
      await SecureStorage.saveUserData(response['user']);

      _isAuthenticated = true;
      _user = response['user'];

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Signup new user
  Future<void> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await ApiService.signup(
        name: '$firstName $lastName',
        email: email,
        gender: 'male', // You can add gender selection in UI
        status: 'active',
      );

      // Auto-login after signup
      await login(email, password);
    } catch (e) {
      _setLoading(false);
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);

    try {
      await ApiService.deleteToken();

      _isAuthenticated = false;
      _user = null;

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    _setLoading(true);
    _error = null;

    try {
      await ApiService.resetPassword(email);
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_user == null) return;

    _setLoading(true);
    _error = null;

    try {
      final updatedUser = await ApiService.updateProfile(_user!['id'], data);

      _user = updatedUser;
      await SecureStorage.saveUserData(updatedUser);

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
