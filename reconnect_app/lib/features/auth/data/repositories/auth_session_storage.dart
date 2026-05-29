import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/login_response.dart';

class AuthSessionStorage {
  static const _sessionKey = 'reconnect.auth.session';

  final FlutterSecureStorage _storage;

  AuthSessionStorage({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  Future<void> saveSession(LoginResponse response) {
    return _storage.write(
      key: _sessionKey,
      value: jsonEncode(response.toJson()),
    );
  }

  Future<LoginResponse?> readSession() async {
    final raw = await _storage.read(key: _sessionKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final response = LoginResponse.fromJson(json);
      if (response.token.isEmpty || response.user.id.isEmpty) return null;
      return response;
    } catch (_) {
      await clearSession();
      return null;
    }
  }

  Future<void> clearSession() {
    return _storage.delete(key: _sessionKey);
  }
}
