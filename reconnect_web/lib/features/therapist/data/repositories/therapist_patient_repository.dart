import '../../../core/network/api_client.dart';
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
}

