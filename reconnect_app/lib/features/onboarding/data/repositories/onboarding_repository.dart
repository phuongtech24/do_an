import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';
import '../models/onboarding_status_model.dart';

class OnboardingRepository {
  Future<List<String>> saveGoals(String patientId, List<String> goals, {String? token}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.saveGoals),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'patientId': patientId,
          'goals': goals,
        }),
      );

      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json['status'] == 200 && json['data'] != null) {
        final data = json['data'];
        final List<dynamic> list = (data['goals'] ?? []) as List<dynamic>;
        return list.map((e) => e.toString()).toList();
      } else {
        throw Exception(json['message'] ?? 'Không thể lưu mục tiêu trị liệu');
      }
    } catch (e) {
      throw Exception('Lỗi mạng khi lưu mục tiêu: $e');
    }
  }

  Future<List<String>> getGoals(String patientId, {String? token}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.saveGoals}?patientId=$patientId'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json['status'] == 200 && json['data'] != null) {
        final data = json['data'];
        final List<dynamic> list = (data['goals'] ?? []) as List<dynamic>;
        return list.map((e) => e.toString()).toList();
      } else {
        throw Exception(json['message'] ?? 'Không thể tải mục tiêu trị liệu');
      }
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

      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json['status'] == 200 && json['data'] != null) {
        return OnboardingStatusModel.fromJson(json['data']);
      } else {
        throw Exception(json['message'] ?? 'Không thể tải onboarding status');
      }
    } catch (e) {
      throw Exception('Lỗi mạng khi tải onboarding status: $e');
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

      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json['status'] == 200) {
        return;
      } else {
        throw Exception(json['message'] ?? 'Không thể cập nhật psychoeducation');
      }
    } catch (e) {
      throw Exception('Lỗi mạng khi cập nhật psychoeducation: $e');
    }
  }
}
