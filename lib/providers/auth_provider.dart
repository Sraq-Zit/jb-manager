import 'package:flutter/material.dart';
import 'package:flutter_app/exceptions/http_exception.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService apiService;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;

  AuthProvider({required this.apiService});

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> login(String username, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      final response = await apiService.post('/login', {
        'email': username,
        'password': password,
      });
      if (response.containsKey('token')) {
        _isLoggedIn = true;
      } else {
        _error = 'Invalid response structure';
      }
    } on HttpException catch (e) {
      _error = e.message;
    }
    // sleep 2 seconds to simulate loading
    await Future.delayed(const Duration(seconds: 1));
    _isLoading = false;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}
