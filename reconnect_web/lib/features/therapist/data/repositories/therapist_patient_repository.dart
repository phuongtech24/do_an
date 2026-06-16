import '../../../../core/network/api_client.dart';
import '../../../../core/models/paged_result.dart';
import '../../../admin/data/models/quest_template_model.dart';
import '../models/therapist_patient_list_item.dart';
import '../models/therapist_pre_session_review_model.dart';
import '../models/therapist_quest_progress_model.dart';
import '../models/therapist_risk_analytics_model.dart';

class TherapistPatientRepository {
  final ApiClient _api = ApiClient();

  Future<List<TherapistPatientListItem>> listPatients({
    required String token,
    required bool redFlagOnly,
  }) async {
    final res = await _api.get<List<TherapistPatientListItem>>(
      '/therapist/patients?redFlagOnly=$redFlagOnly',
      headers: {'Authorization': 'Bearer $token'},
      parseData: (raw) {
        final list = (raw as List<dynamic>? ?? []);
        return list.map((e) => TherapistPatientListItem.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Cannot load patients');
    }
    return res.data!;
  }

  Future<PagedResult<TherapistPatientListItem>> listPatientsPaged({
    required String token,
    required bool redFlagOnly,
    String? keyword,
    int pageIndex = 1,
    int pageSize = 8,
  }) async {
    final res = await _api.post<PagedResult<TherapistPatientListItem>>(
      '/therapist/patients/paging',
      headers: {'Authorization': 'Bearer $token'},
      body: {
        'redFlagOnly': redFlagOnly,
        'keyword': keyword?.trim(),
        'pageIndex': pageIndex,
        'pageSize': pageSize,
      },
      parseData: (raw) => raw is Map<String, dynamic>
          ? PagedResult<TherapistPatientListItem>.fromJson(
              raw,
              itemParser: TherapistPatientListItem.fromJson,
            )
          : null,
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Cannot load patients');
    }
    return res.data!;
  }

  Future<List<QuestTemplateModel>> listQuestTemplates({
    required String token,
    String? patientId,
  }) async {
    final res = await _api.get<List<QuestTemplateModel>>(
      '/therapist/quest-templates${patientId != null ? '?patientId=$patientId' : ''}',
      headers: {'Authorization': 'Bearer $token'},
      parseData: (raw) {
        final list = (raw as List<dynamic>? ?? []);
        return list.map((e) => QuestTemplateModel.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Cannot load CBT templates');
    }
    return res.data!;
  }

  Future<void> assignQuest({
    required String token,
    required String patientId,
    required String questTemplateId,
  }) async {
    final res = await _api.post<Object?>(
      '/therapist/patients/$patientId/quests',
      headers: {'Authorization': 'Bearer $token'},
      body: {'questTemplateId': questTemplateId},
    );
    if (res.status != 200) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Cannot assign CBT quest');
    }
  }

  Future<TherapistQuestProgressModel> getQuestProgress({
    required String token,
    required String patientId,
  }) async {
    final res = await _api.get<TherapistQuestProgressModel>(
      '/therapist/patients/$patientId/quest-progress',
      headers: {'Authorization': 'Bearer $token'},
      parseData: (raw) => raw is Map<String, dynamic> ? TherapistQuestProgressModel.fromJson(raw) : null,
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Cannot load CBT progress');
    }
    return res.data!;
  }

  Future<TherapistRiskAnalyticsModel> getRiskAnalytics({
    required String token,
    required String patientId,
    int days = 14,
  }) async {
    final res = await _api.get<TherapistRiskAnalyticsModel>(
      '/therapist/patients/$patientId/risk-analytics?days=$days',
      headers: {'Authorization': 'Bearer $token'},
      parseData: (raw) => raw is Map<String, dynamic> ? TherapistRiskAnalyticsModel.fromJson(raw) : null,
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Cannot load risk analytics');
    }
    return res.data!;
  }

  Future<TherapistPreSessionReviewModel> getPreSessionReview({
    required String token,
    required String patientId,
  }) async {
    final res = await _api.get<TherapistPreSessionReviewModel>(
      '/therapist/patients/$patientId/pre-session-review',
      headers: {'Authorization': 'Bearer $token'},
      parseData: (raw) =>
          raw is Map<String, dynamic> ? TherapistPreSessionReviewModel.fromJson(raw) : null,
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Cannot load pre-session review');
    }
    return res.data!;
  }
}
