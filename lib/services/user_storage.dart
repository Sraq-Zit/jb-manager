import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class UserStorage {
  static const String _userKey = 'user';
  static User? _user;
  static User? get user => _user;

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    _user = user;
    await prefs.setString(_userKey, userJson);
  }

  Future<User?> getUser() async {
    if (_user != null) {
      return _user;
    }
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      final userMap = jsonDecode(userJson);
      _user = User.fromJson(userMap);
      return _user;
    }
    return null;
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    _user = null;
  }

  void updateToken(String token) {
    if (_user == null) return;
    saveUser(_user!.copyWith(token: token));
  }
}
