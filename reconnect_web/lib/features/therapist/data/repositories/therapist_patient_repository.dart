import '../../../../core/network/api_client.dart';
import '../../../admin/data/models/quest_template_model.dart';
import '../models/therapist_patient_list_item.dart';

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

  Future<List<QuestTemplateModel>> listQuestTemplates({required String token}) async {
    final res = await _api.get<List<QuestTemplateModel>>(
      '/therapist/quest-templates',
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
}
