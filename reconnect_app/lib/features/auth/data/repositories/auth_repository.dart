import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:reconnect_app/core/constants/api_constants.dart';
import 'package:reconnect_app/features/auth/data/models/email_verification_response.dart';
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

  Future<LoginResponse> refreshToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    final json = _decodeApiResponse(response, 'làm mới phiên đăng nhập');
    if (json['status'] == 200 && json['data'] != null) {
      return LoginResponse.fromJson(json['data']);
    }
    throw Exception(json['message'] ?? 'Làm mới phiên đăng nhập thất bại.');
  }

  Future<void> requestPasswordReset(String email) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    final json = _decodeApiResponse(response, 'yêu cầu đặt lại mật khẩu');
    if (json['status'] != 200) {
      throw Exception(json['message'] ?? 'Không thể tạo yêu cầu đặt lại mật khẩu.');
    }
  }

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'resetToken': resetToken,
        'newPassword': newPassword,
      }),
    );

    final json = _decodeApiResponse(response, 'đặt lại mật khẩu');
    if (json['status'] != 200) {
      throw Exception(json['message'] ?? 'Đặt lại mật khẩu thất bại.');
    }
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

  Future<EmailVerificationResponse> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.verifyEmailOtp),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
      }),
    );

    final json = _decodeApiResponse(response, 'xác minh OTP email');
    if (json['status'] == 200 && json['data'] != null) {
      return EmailVerificationResponse.fromJson(json['data']);
    }
    throw Exception(json['message'] ?? 'Xác minh OTP thất bại.');
  }

  Future<EmailVerificationResponse> resendEmailOtp(String email) async {
    final response = await http.post(
      Uri.parse(ApiConstants.resendEmailOtp),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    final json = _decodeApiResponse(response, 'gửi lại OTP email');
    if (json['status'] == 200 && json['data'] != null) {
      return EmailVerificationResponse.fromJson(json['data']);
    }
    throw Exception(json['message'] ?? 'Gửi lại OTP thất bại.');
  }

  Future<LoginResponse> loginAnonymous(String deviceId) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.registerAnonymous}?deviceId=$deviceId'),
      headers: {'Content-Type': 'application/json'},
    );

    final json = _decodeApiResponse(response, 'đăng nhập ẩn danh');
    if (json['status'] == 200 && json['data'] != null) {
      return LoginResponse.fromJson(json['data']);
    }
    throw Exception(json['message'] ?? 'Đăng nhập ẩn danh thất bại.');
  }

  Future<EmailVerificationResponse> linkGuestAccount({
    required String guestId,
    required String email,
    required String password,
    required String realFullName,
    required String phoneNumber,
    String? token,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.guestLinkAccount),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'guestId': guestId,
        'email': email,
        'password': password,
        'realFullName': realFullName,
        'phoneNumber': phoneNumber,
      }),
    );

    final json = _decodeApiResponse(response, 'liên kết tài khoản guest');
    if (json['status'] == 200 && json['data'] != null) {
      return EmailVerificationResponse.fromJson(json['data']);
    }
    throw Exception(json['message'] ?? 'Không thể liên kết tài khoản guest.');
  }

  Future<void> deletePatientAccount({
    required String patientId,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.patientDeleteAccount),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'patientId': patientId,
        'confirmDelete': true,
      }),
    );

    final json = _decodeApiResponse(response, 'xoá tài khoản');
    if (json['status'] != 200) {
      throw Exception(json['message'] ?? 'Xoá tài khoản thất bại.');
    }
  }
}
