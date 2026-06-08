import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';
import '../models/patient_profile_model.dart';

class PatientProfileRepository {
  Future<PatientProfileModel> getProfile(String patientId, {String? token}) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.patientProfile}?patientId=$patientId'),
      headers: _headers(token),
    );
    final json = jsonDecode(utf8.decode(response.bodyBytes));
    if (json['status'] == 200 && json['data'] != null) {
      return PatientProfileModel.fromJson(json['data'] as Map<String, dynamic>);
    }
    throw Exception(json['message'] ?? 'Không thể tải hồ sơ bệnh nhân');
  }

  Future<PatientProfileModel> updateProfile(Map<String, dynamic> body, {String? token}) async {
    final response = await http.post(
      Uri.parse(ApiConstants.patientProfile),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    final json = jsonDecode(utf8.decode(response.bodyBytes));
    if (json['status'] == 200 && json['data'] != null) {
      return PatientProfileModel.fromJson(json['data'] as Map<String, dynamic>);
    }
    throw Exception(json['message'] ?? 'Không thể cập nhật hồ sơ bệnh nhân');
  }

  Future<PatientProfileModel> completeSafetyGate({
    required String patientId,
    required String realFullName,
    required String phoneNumber,
    String? token,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.patientProfileSafetyGate),
      headers: _headers(token),
      body: jsonEncode({
        'patientId': patientId,
        'realFullName': realFullName,
        'phoneNumber': phoneNumber,
      }),
    );
    final json = jsonDecode(utf8.decode(response.bodyBytes));
    if (json['status'] == 200 && json['data'] != null) {
      return PatientProfileModel.fromJson(json['data'] as Map<String, dynamic>);
    }
    throw Exception(json['message'] ?? 'Không thể lưu cam kết an toàn y tế');
  }

  Map<String, String> _headers(String? token) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}
