import 'package:flutter/material.dart';

import '../network/api_client.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  String? _token;
  String? _role;
  String? _userId;
  String? _email;

  String? get token => _token;
  String? get role => _role;
  String? get userId => _userId;
  String? get email => _email;

  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  Future<void> login({required String email, required String password}) async {
    final res = await _api.post<Map<String, dynamic>>(
      '/auth/login',
      body: {'email': email, 'password': password},
      parseData: (raw) => raw as Map<String, dynamic>?,
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Login failed');
    }
    final data = res.data!;
    final token = (data['token'] ?? '').toString();
    final user = (data['user'] as Map<String, dynamic>?);
    _token = token;
    _email = (user?['email'] ?? email).toString();
    _role = (user?['role'] ?? '').toString();
    _userId = (user?['id'] ?? '').toString();
    notifyListeners();
  }

  void logout() {
    _token = null;
    _role = null;
    _userId = null;
    _email = null;
    notifyListeners();
  }
}

