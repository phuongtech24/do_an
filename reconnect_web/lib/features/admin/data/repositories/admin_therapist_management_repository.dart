import '../../../../core/network/api_client.dart';
import '../models/therapist_applicant_model.dart';

class AdminTherapistManagementRepository {
  final ApiClient _api = ApiClient();

  Future<TherapistApplicantModel> updateProfile({
    required String token,
    required String therapistId,
    String? fullName,
    String? specialization,
    String? bio,
    String? meetingLink,
  }) async {
    final res = await _api.put<TherapistApplicantModel>(
      '/admin/therapists/$therapistId',
      headers: {'Authorization': 'Bearer $token'},
      body: {
        'fullName': fullName,
        'specialization': specialization,
        'bio': bio,
        'meetingLink': meetingLink,
      },
      parseData: (raw) => raw is Map<String, dynamic> ? TherapistApplicantModel.fromJson(raw) : null,
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Cannot update therapist');
    }
    return res.data!;
  }

  Future<String> resetPassword({
    required String token,
    required String therapistId,
    String? newPassword,
  }) async {
    final res = await _api.post<Map<String, dynamic>>(
      '/admin/therapists/$therapistId/reset-password',
      headers: {'Authorization': 'Bearer $token'},
      body: {'newPassword': newPassword},
      parseData: (raw) => raw as Map<String, dynamic>?,
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Cannot reset password');
    }
    return (res.data?['newPassword'] ?? '').toString();
  }
}

