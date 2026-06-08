import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:reconnect_app/core/constants/api_constants.dart';
import 'package:reconnect_app/features/auth/data/models/login_request.dart';
import 'package:reconnect_app/features/auth/data/models/login_response.dart';

class AuthRepository {
  Map<String, dynamic> _decodeApiResponse(http.Response response, String endpointName) {
    final body = utf8.decode(response.bodyBytes);
    if (body.trim().isEmpty) {
      throw Exception('Không nhận được phản hồi hợp lệ từ máy chủ ở bước $endpointName.');
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      throw Exception('Phản hồi từ máy chủ ở bước $endpointName không đúng định dạng.');
    } on FormatException {
      throw Exception('Phản hồi từ máy chủ ở bước $endpointName bị lỗi định dạng.');
    }
  }

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    final json = _decodeApiResponse(response, 'đăng nhập');
    if (json['status'] == 200 && json['data'] != null) {
      return LoginResponse.fromJson(json['data']);
    }
    throw Exception(json['message'] ?? 'Đăng nhập thất bại.');
  }

  Future<void> register({
    required String email,
    required String password,
    String? nickname,
    String? avatarIcon,
    String role = 'PATIENT',
    bool isAnonymous = false,
    bool anonymousModeEnabled = true,
    String? realFullName,
    String? dateOfBirth,
    String? gender,
    String? phoneNumber,
    String? emergencyContactPhone,
    String? educationLevel,
    String? occupation,
    String? relationshipStatus,
    String? medicalHistory,
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
        'anonymousModeEnabled': anonymousModeEnabled,
        'realFullName': realFullName,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'phoneNumber': phoneNumber,
        'emergencyContactPhone': emergencyContactPhone,
        'educationLevel': educationLevel,
        'occupation': occupation,
        'relationshipStatus': relationshipStatus,
        'medicalHistory': medicalHistory,
      }),
    );

    final json = _decodeApiResponse(response, 'đăng ký');
    if (json['status'] != 200) {
      throw Exception(json['message'] ?? 'Đăng ký thất bại.');
    }
  }

  Future<LoginResponse> loginAnonymous(String deviceId) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/api/auth/register-anonymous?deviceId=$deviceId'),
      headers: {'Content-Type': 'application/json'},
    );

    final json = _decodeApiResponse(response, 'đăng nhập ẩn danh');
    if (json['status'] == 200 && json['data'] != null) {
      return LoginResponse.fromJson(json['data']);
    }
    throw Exception(json['message'] ?? 'Đăng nhập ẩn danh thất bại.');
  }
}
