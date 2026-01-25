import 'dart:async';
import 'dart:convert';

import 'package:drms/model/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Session {
  Session._();
  static final Session instance = Session._();

  static const _userKey = 'UserDetails';
  static const _tokenKey = 'token';

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  Future<User?> getUserSession() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_userKey);
    if (raw == null || raw.isEmpty || raw == 'null') return null;
    try {
      return User.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  Future<bool> saveSession(User user) async {
    final prefs = await _prefs;
    return prefs.setString(_userKey, jsonEncode(user));
  }

  Future<User?> getUserDetails() async {
    return getUserSession();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await _prefs;
    final token = prefs.getString(_tokenKey);
    final user = await getUserSession();

    final hasToken = token != null && token.isNotEmpty;
    final hasUser = user != null && ((user.username ?? '').isNotEmpty || (user.roles ?? '').isNotEmpty);

    return hasToken || hasUser;
  }

  Future<bool> logoutUserSession() async {
    final prefs = await _prefs;

    return await prefs.remove(_userKey) && await prefs.remove(_tokenKey);
  }

  Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(_tokenKey);
  }

  Future<bool> putToken(String token) async {
    final prefs = await _prefs;
    return prefs.setString(_tokenKey, token);
  }

  Future<bool> clearToken() async {
    final prefs = await _prefs;
    return prefs.remove(_tokenKey);
  }
}
