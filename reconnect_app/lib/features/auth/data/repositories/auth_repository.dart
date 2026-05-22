import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reconnect_app/core/constants/api_constants.dart';
import 'package:reconnect_app/features/auth/data/models/login_request.dart';
import 'package:reconnect_app/features/auth/data/models/login_response.dart';

class AuthRepository {
  // ========================================
  // ĐĂNG NHẬP
  // ========================================
  Future<LoginResponse> login(LoginRequest request) async {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    final json = jsonDecode(utf8.decode(response.bodyBytes));

    if (json['status'] == 200 && json['data'] != null) {
      return LoginResponse.fromJson(json['data']);
    } else {
      throw Exception(json['message'] ?? 'Đăng nhập thất bại');
    }
  }

  // ========================================
  // ĐĂNG KÝ
  // ========================================
  Future<void> register({
    required String email,
    required String password,
    String? nickname,
    String? avatarIcon,
    String role = 'PATIENT',
    bool isAnonymous = false,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'nickname': nickname,
        'avatarIcon': avatarIcon,
        'role': role,
        'isAnonymous': isAnonymous,
      }),
    );

    final json = jsonDecode(utf8.decode(response.bodyBytes));

  if (json['status'] != 200) {
      throw Exception(json['message'] ?? 'Đăng ký thất bại');
    }
  }

  // ========================================
  // ĐĂNG NHẬP ẨN DANH
  // ========================================
  Future<LoginResponse> loginAnonymous(String deviceId) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/api/auth/register-anonymous?deviceId=$deviceId'),
      headers: {'Content-Type': 'application/json'},
    );

    final json = jsonDecode(utf8.decode(response.bodyBytes));

    if (json['status'] == 200 && json['data'] != null) {
      return LoginResponse.fromJson(json['data']);
    } else {
      throw Exception(json['message'] ?? 'Đăng nhập ẩn danh thất bại');
    }
  }
}
