import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';
import '../models/behavioral_experiment_model.dart';
import '../models/fear_ladder_item_model.dart';
import '../models/patient_quest_model.dart';
import '../models/roadmap_program_state_model.dart';
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

  Future<RoadmapProgramStateModel> getProgramState(String patientId, {String? token}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.roadmapProgramState}?patientId=$patientId'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      _handleHttpError(response, 'tải trạng thái lộ trình 14 tuần');
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json['status'] == 200 && json['data'] != null) {
        return RoadmapProgramStateModel.fromJson(json['data'] as Map<String, dynamic>);
      }
      throw Exception(json['message'] ?? 'Không thể tải trạng thái lộ trình 14 tuần');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<List<FearLadderItemModel>> getFearLadder(String patientId, {String? token}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.fearLadder}?patientId=$patientId'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      _handleHttpError(response, 'tải Fear Ladder');
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json['status'] == 200 && json['data'] != null) {
        final list = json['data'] as List<dynamic>;
        return list.map((e) => FearLadderItemModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw Exception(json['message'] ?? 'Không thể tải Fear Ladder');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<BehavioralExperimentModel?> getTodayExperiment(String patientId, {String? token}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.behavioralExperimentToday}?patientId=$patientId'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      _handleHttpError(response, 'tải bài Behavioral Experiment');
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json['status'] == 200 && json['data'] != null) {
        return BehavioralExperimentModel.fromJson(json['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<BehavioralExperimentModel> startBehavioralExperiment(
    String id, {
    required String prediction,
    required int predictionBelief,
    required List<String> safetyBehaviors,
    String? token,
  }) async {
    try {
      final normalizedSafetyBehaviors = safetyBehaviors
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList();
      final response = await http.post(
        Uri.parse(ApiConstants.startBehavioralExperiment(id)),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'prediction': prediction,
          'predictionBelief': predictionBelief,
          'safetyBehaviorsJson': jsonEncode(normalizedSafetyBehaviors),
        }),
      );
      _handleHttpError(response, 'bắt đầu Behavioral Experiment');
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json['status'] == 200 && json['data'] != null) {
        return BehavioralExperimentModel.fromJson(json['data'] as Map<String, dynamic>);
      }
      throw Exception(json['message'] ?? 'Không thể bắt đầu bài thực hành');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<BehavioralExperimentModel> debriefBehavioralExperiment(
    String id, {
    required String executionNotes,
    required String debrief,
    required int postFearScore,
    required int postAvoidanceScore,
    String? token,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse(ApiConstants.debriefBehavioralExperiment(id)),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'executionNotes': executionNotes,
          'debrief': debrief,
          'postFearScore': postFearScore,
          'postAvoidanceScore': postAvoidanceScore,
        }),
      );
      _handleHttpError(response, 'debrief Behavioral Experiment');
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json['status'] == 200 && json['data'] != null) {
        return BehavioralExperimentModel.fromJson(json['data'] as Map<String, dynamic>);
      }
      throw Exception(json['message'] ?? 'Không thể lưu debrief');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<List<PatientQuestModel>> getQuestHistory(String patientId, {String? token}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.roadmapHistory}?patientId=$patientId'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      _handleHttpError(response, 'tải lịch sử bài CBT');

      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json['status'] == 200 && json['data'] != null) {
        final List<dynamic> list = json['data'] as List<dynamic>;
        return list.map((e) => PatientQuestModel.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception(json['message'] ?? 'Không thể tải lịch sử bài CBT');
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
