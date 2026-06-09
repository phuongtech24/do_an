import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reconnect_app/core/constants/api_constants.dart';

class GuidedDiscoveryRepository {
  void _handleHttpError(http.Response response, String actionName) {
    if (response.statusCode == 401) {
      throw Exception('Phiên đăng nhập hết hạn hoặc không hợp lệ. Vui lòng đăng nhập lại.');
    } else if (response.statusCode == 403) {
      throw Exception('Bạn không có quyền thực hiện hành động này (403 Forbidden).');
    } else if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Máy chủ phản hồi lỗi ${response.statusCode} khi $actionName.');
    }
  }

  Future<List<String>> getQuestions({
    required String situation,
    required String automaticThought,
    String? emotion,
    int? moodScore,
    String? token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.guidedDiscovery),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'situation': situation,
          'automaticThought': automaticThought,
          if (emotion != null) 'emotion': emotion,
          if (moodScore != null) 'moodScore': moodScore,
        }),
      );

      _handleHttpError(response, 'lấy câu hỏi Guided Discovery');

      final bodyStr = utf8.decode(response.bodyBytes);
      if (bodyStr.isEmpty) {
        throw Exception('Phản hồi từ máy chủ trống rỗng.');
      }

      final json = jsonDecode(bodyStr);
      if (json['status'] == 200 && json['data'] != null) {
        final data = json['data'] as Map<String, dynamic>;
        final list = (data['questions'] as List<dynamic>? ?? []);
        return list.map((e) => e.toString()).toList();
      }
      throw Exception(json['message'] ?? 'Không thể lấy câu hỏi');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
