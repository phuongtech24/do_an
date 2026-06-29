import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';
import '../models/onboarding_status_model.dart';
import '../models/patient_goal_model.dart';
import '../models/therapist_directory_item_model.dart';

class OnboardingRepository {
  Map<String, dynamic> _decodeJsonResponse(http.Response response) {
    final body = utf8.decode(response.bodyBytes);
    if (body.trim().isEmpty) {
      throw Exception('Phản hồi từ máy chủ đang rỗng.');
    }
    return jsonDecode(body) as Map<String, dynamic>;
  }

  Future<PatientGoalModel> saveGoal(String patientId, String goalType, String description, {String? token}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.patientGoals),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'patientId': patientId,
          'goalType': goalType,
          'description': description,
        }),
      );

      final json = _decodeJsonResponse(response);
      if (json['status'] == 200 && json['data'] != null) {
        return PatientGoalModel.fromJson(json['data'] as Map<String, dynamic>);
      }
      throw Exception(json['message'] ?? 'Không thể lưu mục tiêu trị liệu');
    } catch (e) {
      throw Exception('Lỗi mạng khi lưu mục tiêu: $e');
    }
  }

  Future<List<PatientGoalModel>> getGoals(String patientId, {String? token}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.patientGoals}?patientId=$patientId'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final json = _decodeJsonResponse(response);
      if (json['status'] == 200 && json['data'] != null) {
        final list = json['data'] as List<dynamic>;
        return list.map((e) => PatientGoalModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw Exception(json['message'] ?? 'Không thể tải mục tiêu trị liệu');
    } catch (e) {
      throw Exception('Lỗi mạng khi tải mục tiêu: $e');
    }
  }

  Future<OnboardingStatusModel> getOnboardingStatus(String patientId, {String? token}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.getOnboardingStatus}?patientId=$patientId'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final json = _decodeJsonResponse(response);
      if (json['status'] == 200 && json['data'] != null) {
        return OnboardingStatusModel.fromJson(json['data'] as Map<String, dynamic>);
      }
      throw Exception(json['message'] ?? 'Không thể tải onboarding status');
    } catch (e) {
      throw Exception('Lỗi mạng khi tải onboarding status: $e');
    }
  }

  Future<List<TherapistDirectoryItemModel>> getTherapists({String? token}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.patientTherapists),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final json = _decodeJsonResponse(response);
      if (json['status'] == 200 && json['data'] != null) {
        final list = json['data'] as List<dynamic>;
        return list.map((e) => TherapistDirectoryItemModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw Exception(json['message'] ?? 'Không thể tải danh sách chuyên gia');
    } catch (e) {
      throw Exception('Lỗi mạng khi tải danh sách chuyên gia: $e');
    }
  }

  Future<TherapistDirectoryItemModel> getTherapistDetail(String therapistId, {String? token}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.patientTherapistDetail(therapistId)),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final json = _decodeJsonResponse(response);
      if (json['status'] == 200 && json['data'] != null) {
        return TherapistDirectoryItemModel.fromJson(json['data'] as Map<String, dynamic>);
      }
      throw Exception(json['message'] ?? 'Không thể tải chi tiết chuyên gia');
    } catch (e) {
      throw Exception('Lỗi mạng khi tải chi tiết chuyên gia: $e');
    }
  }

  Future<void> selectTherapist(String patientId, String therapistId, {String? token}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.selectTherapist),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'patientId': patientId,
          'therapistId': therapistId,
        }),
      );

      final json = _decodeJsonResponse(response);
      if (json['status'] != 200) {
        throw Exception(json['message'] ?? 'Không thể chọn chuyên gia');
      }
    } catch (e) {
      throw Exception('Lỗi mạng khi chọn chuyên gia: $e');
    }
  }

  Future<void> completePsychoeducation(String patientId, {String? token}) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.completePsychoeducation}?patientId=$patientId'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final json = _decodeJsonResponse(response);
      if (json['status'] != 200) {
        throw Exception(json['message'] ?? 'Không thể cập nhật psychoeducation');
      }
    } catch (e) {
      throw Exception('Lỗi mạng khi cập nhật psychoeducation: $e');
    }
  }
}
