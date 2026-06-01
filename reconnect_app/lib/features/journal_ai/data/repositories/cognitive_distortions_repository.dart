import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reconnect_app/core/constants/api_constants.dart';

class CognitiveDistortionsRepository {
  void _handleHttpError(http.Response response, String actionName) {
    if (response.statusCode == 401) {
      throw Exception('Phiên đăng nhập hết hạn hoặc không hợp lệ. Vui lòng đăng nhập lại.');
    } else if (response.statusCode == 403) {
      throw Exception('Bạn không có quyền thực hiện hành động này (403 Forbidden).');
    } else if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Máy chủ phản hồi lỗi ${response.statusCode} khi $actionName.');
    }
  }

  Future<Map<String, dynamic>> detect({
    required String situation,
    required String automaticThought,
    String? token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.cognitiveDistortions),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'situation': situation,
          'automaticThought': automaticThought,
        }),
      );

      _handleHttpError(response, 'nhận diện lỗi tư duy');

      final bodyStr = utf8.decode(response.bodyBytes);
      if (bodyStr.isEmpty) {
        throw Exception('Phản hồi từ máy chủ trống rỗng.');
      }

      final json = jsonDecode(bodyStr);
      if (json['status'] == 200 && json['data'] != null) {
        return (json['data'] as Map<String, dynamic>);
      }
      throw Exception(json['message'] ?? 'Không thể nhận diện lỗi tư duy');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
