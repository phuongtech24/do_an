import '../../../../core/network/api_client.dart';
import '../models/therapist_applicant_model.dart';

class AdminTherapistApprovalRepository {
  final ApiClient _api = ApiClient();

  Future<List<TherapistApplicantModel>> list({required String token, String? status}) async {
    final path = status == null || status.isEmpty ? '/admin/therapists' : '/admin/therapists?status=$status';
    final res = await _api.get<List<TherapistApplicantModel>>(
      path,
      headers: {'Authorization': 'Bearer $token'},
      parseData: (raw) {
        final list = (raw as List<dynamic>? ?? []);
        return list.map((e) => TherapistApplicantModel.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Cannot load therapist applicants');
    }
    return res.data!;
  }

  Future<TherapistApplicantModel> create({
    required String token,
    required String fullName,
    required String email,
    required String password,
    String? specialization,
  }) async {
    final res = await _api.post<TherapistApplicantModel>(
      '/admin/therapists/create',
      headers: {'Authorization': 'Bearer $token'},
      body: {
        'fullName': fullName,
        'email': email,
        'password': password,
        'specialization': specialization,
      },
      parseData: (raw) => raw is Map<String, dynamic> ? TherapistApplicantModel.fromJson(raw) : null,
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Cannot create therapist account');
    }
    return res.data!;
  }

  Future<TherapistApplicantModel> setApproval({
    required String token,
    required String therapistId,
    required String status,
  }) async {
    final res = await _api.patch<TherapistApplicantModel>(
      '/admin/therapists/$therapistId/approval?status=$status',
      headers: {'Authorization': 'Bearer $token'},
      parseData: (raw) => raw is Map<String, dynamic> ? TherapistApplicantModel.fromJson(raw) : null,
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Cannot update approval status');
    }
    return res.data!;
  }
}

