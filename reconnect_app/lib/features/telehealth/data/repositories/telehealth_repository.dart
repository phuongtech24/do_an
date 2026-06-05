import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';
import '../models/available_slot_model.dart';
import '../models/appointment_model.dart';
import '../models/therapist_assignment_status_model.dart';

class TelehealthRepository {
  void _handleHttpError(http.Response response, String actionName) {
    if (response.statusCode == 401) {
      throw Exception('Phiên đăng nhập hết hạn hoặc không hợp lệ. Vui lòng đăng nhập lại.');
    } else if (response.statusCode == 403) {
      throw Exception('Bạn không có quyền thực hiện hành động này (403 Forbidden).');
    } else if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Máy chủ phản hồi lỗi ${response.statusCode} khi $actionName.');
    }
  }

  Future<TherapistAssignmentStatusModel> getTherapistAssignmentStatus(String patientId, {String? token}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.therapistAssignmentStatus}?patientId=$patientId'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      _handleHttpError(response, 'kiểm tra bác sĩ phụ trách');
      final json = jsonDecode(utf8.decode(response.bodyBytes));

      if (json['status'] == 200 && json['data'] != null) {
        return TherapistAssignmentStatusModel.fromJson(json['data'] as Map<String, dynamic>);
      }
      throw Exception(json['message'] ?? 'Không thể kiểm tra bác sĩ phụ trách');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<List<AvailableSlotModel>> getAvailableSlots(String patientId, DateTime date, {String? token}) async {
    try {
      final dateStr =
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final response = await http.get(
        Uri.parse('${ApiConstants.getAvailableSlots}?patientId=$patientId&date=$dateStr'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      _handleHttpError(response, 'tải danh sách slot');
      final json = jsonDecode(utf8.decode(response.bodyBytes));

      if (json['status'] == 200 && json['data'] != null) {
        final List<dynamic> list = json['data'] as List<dynamic>;
        return list.map((e) => AvailableSlotModel.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception(json['message'] ?? 'Không thể tải danh sách slot');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<AppointmentModel> bookAppointment(
    String patientId, {
    required DateTime startAt,
    required bool isAnonymous,
    required int durationMinutes,
    String purpose = 'CBT_SESSION',
    String? token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.bookAppointment),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'patientId': patientId,
          'startAt': startAt.toIso8601String(),
          'isAnonymous': isAnonymous,
          'durationMinutes': durationMinutes,
          'purpose': purpose,
        }),
      );

      _handleHttpError(response, 'đặt lịch khám');
      final json = jsonDecode(utf8.decode(response.bodyBytes));

      if (json['status'] == 200 && json['data'] != null) {
        return AppointmentModel.fromJson(json['data'] as Map<String, dynamic>);
      } else {
        throw Exception(json['message'] ?? 'Không thể đặt lịch khám');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<List<AppointmentModel>> getMyAppointments(String patientId, {String? token}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.myAppointments}?patientId=$patientId'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      _handleHttpError(response, 'tải lịch hẹn của tôi');
      final json = jsonDecode(utf8.decode(response.bodyBytes));

      if (json['status'] == 200 && json['data'] != null) {
        final List<dynamic> list = json['data'] as List<dynamic>;
        return list.map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception(json['message'] ?? 'Không thể tải lịch hẹn');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
