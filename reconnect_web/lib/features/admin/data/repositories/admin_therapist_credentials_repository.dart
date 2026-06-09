import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../models/therapist_credential_model.dart';

class AdminTherapistCredentialsRepository {
  final ApiClient _api = ApiClient();

  Future<List<AdminTherapistCredentialModel>> list({
    required String token,
    required String therapistId,
  }) async {
    final res = await _api.get<List<AdminTherapistCredentialModel>>(
      '/admin/therapists/$therapistId/credentials',
      headers: {'Authorization': 'Bearer $token'},
      parseData: (raw) {
        final list = (raw as List<dynamic>? ?? []);
        return list.map((e) => AdminTherapistCredentialModel.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Cannot load therapist credentials');
    }
    return res.data!;
  }

  Future<List<int>> downloadBytes({
    required String token,
    required String therapistId,
    required String credentialId,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/admin/therapists/$therapistId/credentials/$credentialId/download');
    final resp = await http.get(uri, headers: {'Authorization': 'Bearer $token'});
    if (resp.statusCode != 200) {
      // backend returns raw bytes, not ApiResponse. Try decode if possible for better message.
      try {
        final body = utf8.decode(resp.bodyBytes);
        throw Exception(body.isNotEmpty ? body : 'Download failed (${resp.statusCode})');
      } catch (_) {
        throw Exception('Download failed (${resp.statusCode})');
      }
    }
    return resp.bodyBytes;
  }
}
