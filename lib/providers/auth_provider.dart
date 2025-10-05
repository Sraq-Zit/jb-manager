import 'package:flutter/material.dart';
import 'package:jbmanager/exceptions/http_exception.dart';
import 'package:jbmanager/models/user.dart';
import 'package:jbmanager/services/user_storage.dart';

import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = true;
  bool _isLoadingUser = true;
  String? _error;

  AuthProvider();
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isLoadingUser => _isLoadingUser;
  bool get isLoggedIn => user != null;
  User? get user => UserStorage.user;

  Future<bool> loadUser() async {
    _isLoading = true;
    _isLoadingUser = true;
    notifyListeners();
    await UserStorage().getUser();
    if (user != null) {
      try {
        final userJson = user!.toJson();
        userJson['settings'] = await _fetchSettings(user!.token);
        await UserStorage().saveUser(User.fromJson(userJson));
      } on HttpException catch (_) {}
    }
    _isLoading = false;
    _isLoadingUser = false;
    notifyListeners();
    return user != null;
  }

  Future<Map<String, dynamic>> _fetchSettings(String? token) async {
    if (token == null && user != null) {
      token = user!.token;
    }

    final settingResponse = await apiService.post(
      '/settings',
      body: {'token': token},
    );

    if (settingResponse['status'] != true || settingResponse['data'] == null) {
      throw HttpException('Erreur de récupération des paramètres');
    }

    return settingResponse['data'];
  }

  Future<void> login(String username, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      final response = await apiService.post(
        '/login',
        body: {'email': username, 'password': password},
      );
      if (!response.containsKey('token')) {
        throw HttpException('Erreur de connexion');
      }
      response['settings'] = await _fetchSettings(response['token']);

      await UserStorage().saveUser(User.fromJson(response), username);
    } on HttpException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await UserStorage().clearUser();
    notifyListeners();
  }
}
