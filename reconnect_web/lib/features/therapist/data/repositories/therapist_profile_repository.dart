import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../models/therapist_profile_model.dart';

class TherapistProfileRepository {
  final ApiClient _api = ApiClient();

  Future<TherapistProfileModel> getMyProfile({required String token}) async {
    final ApiResponse<TherapistProfileModel> res = await _api.get<TherapistProfileModel>(
      '/therapist/profile',
      headers: {'Authorization': 'Bearer $token'},
      parseData: (raw) => raw == null ? null : TherapistProfileModel.fromJson(raw as Map<String, dynamic>),
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Không thể tải hồ sơ chuyên gia');
    }
    return res.data!;
  }

  Future<TherapistProfileModel> updateMyProfile({
    required String token,
    required String fullName,
    required String phoneNumber,
    required String hometown,
    required String birthYear,
    required String voiceDescription,
    required String specialization,
    required String therapyStyle,
    required String bio,
    required String meetingLink,
  }) async {
    final ApiResponse<TherapistProfileModel> res = await _api.put<TherapistProfileModel>(
      '/therapist/profile',
      headers: {'Authorization': 'Bearer $token'},
      body: {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'hometown': hometown,
        'birthYear': birthYear.trim().isEmpty ? null : int.tryParse(birthYear.trim()),
        'voiceDescription': voiceDescription,
        'specialization': specialization,
        'therapyStyle': therapyStyle,
        'bio': bio,
        'meetingLink': meetingLink,
      },
      parseData: (raw) => raw == null ? null : TherapistProfileModel.fromJson(raw as Map<String, dynamic>),
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Không thể lưu hồ sơ chuyên gia');
    }
    return res.data!;
  }

  Future<TherapistProfileModel> uploadAvatar({
    required String token,
    required List<int> bytes,
    required String fileName,
    required String contentType,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/therapist/profile/avatar');
    final req = http.MultipartRequest('POST', uri);
    req.headers['Authorization'] = 'Bearer $token';
    req.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
        contentType: MediaType.parse(contentType),
      ),
    );

    final streamed = await req.send();
    final bodyBytes = await streamed.stream.toBytes();
    final json = jsonDecode(utf8.decode(bodyBytes)) as Map<String, dynamic>;
    final api = ApiResponse<TherapistProfileModel>.fromJson(
      json,
      parseData: (raw) => raw == null ? null : TherapistProfileModel.fromJson(raw as Map<String, dynamic>),
    );
    if (api.status != 200 || api.data == null) {
      throw Exception(api.message.isNotEmpty ? api.message : 'Không thể upload ảnh đại diện');
    }
    return api.data!;
  }
}
