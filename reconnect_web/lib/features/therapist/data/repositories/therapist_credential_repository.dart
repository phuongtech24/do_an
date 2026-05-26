import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../models/therapist_credential_model.dart';
import '../models/therapist_profile_status_model.dart';

class TherapistCredentialRepository {
  final ApiClient _api = ApiClient();

  Future<TherapistProfileStatusModel> myStatus({required String token}) async {
    final res = await _api.get<TherapistProfileStatusModel>(
      '/therapist/credentials/status',
      headers: {'Authorization': 'Bearer $token'},
      parseData: (raw) => raw is Map<String, dynamic> ? TherapistProfileStatusModel.fromJson(raw) : null,
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Cannot load therapist status');
    }
    return res.data!;
  }

  Future<List<TherapistCredentialModel>> listMine({required String token}) async {
    final res = await _api.get<List<TherapistCredentialModel>>(
      '/therapist/credentials',
      headers: {'Authorization': 'Bearer $token'},
      parseData: (raw) {
        final list = (raw as List<dynamic>? ?? []);
        return list.map((e) => TherapistCredentialModel.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Cannot load credentials');
    }
    return res.data!;
  }

  Future<TherapistCredentialModel> upload({
    required String token,
    required List<int> bytes,
    required String fileName,
    required String contentType,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/therapist/credentials');
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
    final api = ApiResponse<TherapistCredentialModel>.fromJson(
      json,
      parseData: (raw) => raw is Map<String, dynamic> ? TherapistCredentialModel.fromJson(raw) : null,
    );

    if (api.status != 200 || api.data == null) {
      throw Exception(api.message.isNotEmpty ? api.message : 'Upload failed');
    }
    return api.data!;
  }

  Future<List<int>> downloadBytes({
    required String token,
    required String credentialId,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/therapist/credentials/$credentialId/download');
    final resp = await http.get(uri, headers: {'Authorization': 'Bearer $token'});
    if (resp.statusCode != 200) {
      throw Exception('Download failed (${resp.statusCode})');
    }
    return resp.bodyBytes;
  }

  Future<void> deleteCredential({
    required String token,
    required String credentialId,
  }) async {
    final res = await _api.delete<Object?>(
      '/therapist/credentials/$credentialId',
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.status != 200) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Cannot delete credential');
    }
  }
}
