import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:reconnect_app/core/constants/api_constants.dart';
import 'package:reconnect_app/features/assessment/data/models/lsas_progress_model.dart';
import 'package:reconnect_app/features/assessment/data/models/lsas_situation_model.dart';
import 'package:reconnect_app/features/assessment/data/models/lsas_submission_model.dart';
import 'package:reconnect_app/features/assessment/data/models/user_mood_model.dart';

class AssessmentRepository {
  Map<String, String> _headers(String? token) {
    return {
      'Content-Type': 'application/json; charset=utf-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  dynamic _decode(http.Response response) => jsonDecode(utf8.decode(response.bodyBytes));

  Future<List<LsasSituationModel>> getLsasSituations({String? token}) async {
    final response = await http.get(
      Uri.parse(ApiConstants.getLsasSituations),
      headers: _headers(token),
    );
    final json = _decode(response);
    if (json['status'] == 200 && json['data'] != null) {
      final list = json['data'] as List<dynamic>;
      return list.map((item) => LsasSituationModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    throw Exception(json['message'] ?? 'Không thể tải bộ tình huống LSAS');
  }

  Future<LsasSubmissionModel> submitLsas({
    required String patientId,
    required String submissionType,
    required List<LsasAnswerInput> answers,
    String? token,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.submitLsas),
      headers: _headers(token),
      body: jsonEncode({
        'patientId': patientId,
        'submissionType': submissionType,
        'answers': answers.map((answer) => answer.toJson()).toList(),
      }),
    );
    final json = _decode(response);
    if (json['status'] == 200 && json['data'] != null) {
      return LsasSubmissionModel.fromJson(json['data'] as Map<String, dynamic>);
    }
    throw Exception(json['message'] ?? 'Nộp LSAS thất bại');
  }

  Future<bool> isLsasOnCooldown(String patientId, {String? token}) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.lsasCooldown}?patientId=$patientId'),
      headers: _headers(token),
    );
    final json = _decode(response);
    if (json['status'] == 200) {
      return json['data'] == true;
    }
    throw Exception(json['message'] ?? 'Không thể kiểm tra thời gian LSAS');
  }

  Future<List<LsasSubmissionModel>> getLsasHistory(String patientId, {String? token}) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.lsasHistory}?patientId=$patientId'),
      headers: _headers(token),
    );
    final json = _decode(response);
    if (json['status'] == 200 && json['data'] != null) {
      final list = json['data'] as List<dynamic>;
      return list.map((item) => LsasSubmissionModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    throw Exception(json['message'] ?? 'Không thể tải lịch sử LSAS');
  }

  Future<UserMoodModel> submitUserMood(UserMoodModel mood, {String? token}) async {
    final response = await http.post(
      Uri.parse(ApiConstants.submitMood),
      headers: _headers(token),
      body: jsonEncode(mood.toJson()),
    );
    final json = _decode(response);
    if (json['status'] == 200 && json['data'] != null) {
      return UserMoodModel.fromJson(json['data']);
    }
    throw Exception(json['message'] ?? 'Ghi nhận tâm trạng thất bại');
  }

  Future<LsasProgressResponseModel> getLsasProgress({String? token}) async {
    final response = await http.get(
      Uri.parse(ApiConstants.lsasProgress),
      headers: _headers(token),
    );
    final json = _decode(response);
    if (json['status'] == 200 && json['data'] != null) {
      return LsasProgressResponseModel.fromJson(json['data'] as Map<String, dynamic>);
    }
    throw Exception(json['message'] ?? 'Không thể tải tiến trình phục hồi LSAS');
  }
}
