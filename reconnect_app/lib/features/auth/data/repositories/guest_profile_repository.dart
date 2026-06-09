import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';
import '../models/guest_profile_model.dart';

class GuestProfileRepository {
  Future<GuestProfileModel> getProfile(String guestId, {String? token}) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.guestProfile}?guestId=$guestId'),
      headers: _headers(token),
    );
    final json = jsonDecode(utf8.decode(response.bodyBytes));
    if (json['status'] == 200 && json['data'] != null) {
      return GuestProfileModel.fromJson(json['data'] as Map<String, dynamic>);
    }
    throw Exception(json['message'] ?? 'Không thể tải hồ sơ guest');
  }

  Future<GuestProfileModel> updateProfile(Map<String, dynamic> body, {String? token}) async {
    final response = await http.post(
      Uri.parse(ApiConstants.guestProfile),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    final json = jsonDecode(utf8.decode(response.bodyBytes));
    if (json['status'] == 200 && json['data'] != null) {
      return GuestProfileModel.fromJson(json['data'] as Map<String, dynamic>);
    }
    throw Exception(json['message'] ?? 'Không thể cập nhật hồ sơ guest');
  }

  Map<String, String> _headers(String? token) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}
