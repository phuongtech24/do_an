import '../../../../core/network/api_client.dart';
import '../models/admin_patient_profile_model.dart';

class AdminPatientProfileRepository {
  final ApiClient _api = ApiClient();

  Future<List<AdminPatientProfileModel>> listPatients({
    required String token,
    bool redFlagOnly = false,
    bool triageOnly = false,
    String? q,
  }) async {
    final query = <String, String>{
      'redFlagOnly': redFlagOnly.toString(),
      'triageOnly': triageOnly.toString(),
    };
    if (q != null && q.trim().isNotEmpty) {
      query['q'] = q.trim();
    }

    final qs = query.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    final path = '/admin/patients?$qs';

    final res = await _api.get<List<AdminPatientProfileModel>>(
      path,
      headers: {'Authorization': 'Bearer $token'},
      parseData: (raw) {
        final list = (raw as List<dynamic>? ?? []);
        return list
            .map((e) => AdminPatientProfileModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Cannot load patients');
    }
    return res.data!;
  }

  Future<void> assignTherapist({
    required String token,
    required String patientId,
    required String therapistId,
  }) async {
    final res = await _api.post<Object>(
      '/admin/patients/$patientId/assign-therapist',
      headers: {'Authorization': 'Bearer $token'},
      body: {'therapistId': therapistId},
      parseData: (_) => null,
    );
    if (res.status != 200) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Cannot assign therapist');
    }
  }

  Future<String> triageAction({
    required String token,
    required String patientId,
    required String action,
    Map<String, dynamic>? body,
  }) async {
    final res = await _api.post<Map<String, dynamic>>(
      '/admin/triage/$patientId/$action',
      headers: {'Authorization': 'Bearer $token'},
      body: body,
      parseData: (raw) => raw as Map<String, dynamic>? ?? <String, dynamic>{},
    );
    if (res.status != 200) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Triage action failed');
    }
    return res.message;
  }

  Future<String> runDemoAction({
    required String token,
    required String patientId,
    required String action,
    Map<String, String>? query,
  }) async {
    final queryString = query == null || query.isEmpty
        ? ''
        : '?${query.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}';
    final res = await _api.post<Map<String, dynamic>>(
      '/admin/demo/patients/$patientId/$action$queryString',
      headers: {'Authorization': 'Bearer $token'},
      parseData: (raw) => raw as Map<String, dynamic>? ?? <String, dynamic>{},
    );
    if (res.status != 200) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Demo action failed');
    }
    final dataMessage = res.data?['message']?.toString();
    return dataMessage?.isNotEmpty == true ? dataMessage! : res.message;
  }
}
