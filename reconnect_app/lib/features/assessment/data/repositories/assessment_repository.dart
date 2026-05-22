import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reconnect_app/core/constants/api_constants.dart';
import 'package:reconnect_app/features/assessment/data/models/phq9_question_model.dart';
import 'package:reconnect_app/features/assessment/data/models/phq9_submission_model.dart';
import 'package:reconnect_app/features/assessment/data/models/user_mood_model.dart';

class AssessmentRepository {
  // ======================================================
  // 1. LẤY BỘ CÂU HỎI & ĐÁP ÁN ĐỘNG PHQ-9 TỪ BACKEND
  // ======================================================
  Future<Phq9QuestionnaireModel> getPhq9Questionnaire({String? token}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.getPhq9Questions),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final json = jsonDecode(utf8.decode(response.bodyBytes));

      if (json['status'] == 200 && json['data'] != null) {
        return Phq9QuestionnaireModel.fromJson(json['data']);
      } else {
        throw Exception(json['message'] ?? 'Không thể tải bộ câu hỏi PHQ-9');
      }
    } catch (e) {
      throw Exception('Lỗi mạng khi tải câu hỏi PHQ-9: $e');
    }
  }

  // ======================================================
  // 2. NỘP KẾT QUẢ BÀI TEST PHQ-9 LÊN BACKEND
  // ======================================================
  Future<Phq9SubmissionModel> submitPhq9(Phq9SubmissionModel submission, {String? token}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.submitPhq9),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(submission.toJson()),
      );

      final json = jsonDecode(utf8.decode(response.bodyBytes));

      if (json['status'] == 200 && json['data'] != null) {
        return Phq9SubmissionModel.fromJson(json['data']);
      } else {
        throw Exception(json['message'] ?? 'Nộp bài test PHQ-9 thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi mạng khi nộp bài test PHQ-9: $e');
    }
  }

  // ======================================================
  // 3. KIỂM TRA KHÓA COOLDOWN 14 NGÀY CỦA BỆNH NHÂN
  // ======================================================
  Future<bool> isPhq9OnCooldown(String patientId, {String? token}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.phq9Cooldown}?patientId=$patientId'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final json = jsonDecode(utf8.decode(response.bodyBytes));

      if (json['status'] == 200) {
        return json['data'] == true;
      } else {
        throw Exception(json['message'] ?? 'Không thể kiểm tra Cooldown PHQ-9');
      }
    } catch (e) {
      throw Exception('Lỗi mạng khi kiểm tra Cooldown PHQ-9: $e');
    }
  }

  // ======================================================
  // 4. GHI NHẬN TÂM TRẠNG HÀNG NGÀY CỦA BỆNH NHÂN
  // ======================================================
  Future<UserMoodModel> submitUserMood(UserMoodModel mood, {String? token}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.submitMood),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(mood.toJson()),
      );

      final json = jsonDecode(utf8.decode(response.bodyBytes));

      if (json['status'] == 200 && json['data'] != null) {
        return UserMoodModel.fromJson(json['data']);
      } else {
        throw Exception(json['message'] ?? 'Ghi nhận tâm trạng thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi mạng khi ghi nhận tâm trạng: $e');
    }
  }
}
