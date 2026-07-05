import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:reconnect_app/core/constants/api_constants.dart';
import 'package:reconnect_app/features/journal_ai/data/models/guide_chat_response_model.dart';

class GuideChatRepository {
  Future<GuideChatResponseModel> sendGuideMessage({
    required String userMessage,
    required String screenContext,
    required String patientRoute,
    int? programWeek,
    String? programPhaseCode,
    required bool redFlagActive,
    required int currentRiskScore,
    String? token,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.guideChat),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'userMessage': userMessage,
        'screenContext': screenContext,
        'patientRoute': patientRoute,
        'programWeek': programWeek,
        'programPhaseCode': programPhaseCode,
        'redFlagActive': redFlagActive,
        'currentRiskScore': currentRiskScore,
      }),
    );

    final body = utf8.decode(response.bodyBytes);
    final json = jsonDecode(body);

    if (response.statusCode != 200 || json['status'] != 200 || json['data'] == null) {
      throw Exception(json['message']?.toString() ?? 'Không thể tải phản hồi từ Trợ lý đồng hành.');
    }

    return GuideChatResponseModel.fromJson(json['data'] as Map<String, dynamic>);
  }
}
