import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user.dart';

class AuthSessionStore {
  static const String _accessTokenKey = 'auth_access_token';
  static const String _currentUserKey = 'auth_current_user';

  Future<SharedPreferences> get _prefs async {
    return SharedPreferences.getInstance();
  }

  Future<void> saveSession({
    required User user,
    required String accessToken,
  }) async {
    final prefs = await _prefs;
    final encodedUser = jsonEncode({
      ...user.toMap(),
      'accessToken': accessToken,
    });
    await prefs.setString(_currentUserKey, encodedUser);
    await prefs.setString(_accessTokenKey, accessToken);
  }

  Future<User?> readCurrentUser() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_currentUserKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    return User.fromMap(decoded);
  }

  Future<String?> readAccessToken() async {
    final prefs = await _prefs;
    return prefs.getString(_accessTokenKey);
  }

  Future<bool> hasValidAccessToken() async {
    final token = await readAccessToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    final parts = token.split('.');
    if (parts.length != 3) {
      return false;
    }

    try {
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      if (payload is! Map<String, dynamic>) {
        return false;
      }

      final expiration = payload['exp'];
      return expiration is num &&
          DateTime.now().millisecondsSinceEpoch < expiration * 1000;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearSession() async {
    final prefs = await _prefs;
    await prefs.remove(_currentUserKey);
    await prefs.remove(_accessTokenKey);
  }
}
