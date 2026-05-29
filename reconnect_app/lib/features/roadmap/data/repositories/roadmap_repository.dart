import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';
import '../models/patient_quest_model.dart';
import '../models/roadmap_safety_overlay_model.dart';
import '../models/verify_quest_proof_result.dart';

class RoadmapRepository {
  void _handleHttpError(http.Response response, String actionName) {
    if (response.statusCode == 401) {
      throw Exception('Phiên đăng nhập hết hạn hoặc không hợp lệ. Vui lòng đăng nhập lại.');
    } else if (response.statusCode == 403) {
      throw Exception('Bạn không có quyền thực hiện hành động này (403 Forbidden).');
    } else if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Máy chủ phản hồi lỗi ${response.statusCode} khi $actionName.');
    }
  }

  Future<List<PatientQuestModel>> getDailyQuests(String patientId, {String? token}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.getDailyQuests}?patientId=$patientId'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      _handleHttpError(response, 'tải nhiệm vụ hôm nay');

      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json['status'] == 200 && json['data'] != null) {
        final List<dynamic> list = json['data'] as List<dynamic>;
        return list.map((e) => PatientQuestModel.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception(json['message'] ?? 'Không thể tải nhiệm vụ hôm nay');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<RoadmapSafetyOverlayModel> getSafetyOverlay(String patientId, {String? token}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.roadmapSafetyOverlay}?patientId=$patientId'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      _handleHttpError(response, 'tải cảnh báo an toàn');

      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json['status'] == 200 && json['data'] != null) {
        return RoadmapSafetyOverlayModel.fromJson(json['data'] as Map<String, dynamic>);
      } else {
        throw Exception(json['message'] ?? 'Không thể tải cảnh báo an toàn');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<PatientQuestModel> completeQuest(
    String patientId,
    String questId, {
    required int masteryScore,
    required int pleasureScore,
    String? proofImageUrl,
    String? token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.completeQuest(questId)}?patientId=$patientId'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'masteryScore': masteryScore,
          'pleasureScore': pleasureScore,
          if (proofImageUrl != null) 'proofImageUrl': proofImageUrl,
        }),
      );

      _handleHttpError(response, 'hoàn thành nhiệm vụ');

      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json['status'] == 200 && json['data'] != null) {
        return PatientQuestModel.fromJson(json['data']);
      } else {
        throw Exception(json['message'] ?? 'Không thể hoàn thành nhiệm vụ');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<VerifyQuestProofResult> verifyQuestProof(
    String patientId,
    String questId, {
    required File imageFile,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.verifyQuestProof(questId)}?patientId=$patientId');
      final request = http.MultipartRequest('POST', uri);

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      _handleHttpError(response, 'xác minh minh chứng ảnh');

      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json['status'] == 200 && json['data'] != null) {
        return VerifyQuestProofResult.fromJson(json['data'] as Map<String, dynamic>);
      } else {
        throw Exception(json['message'] ?? 'Không thể xác minh minh chứng');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
