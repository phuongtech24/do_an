import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../models/appointment_model.dart';
import '../models/therapist_schedule_slot_model.dart';

class TherapistBoosterRepository {
  final ApiClient _api = ApiClient();

  Future<List<TherapistScheduleSlotModel>> getSchedule({
    required String token,
    required String therapistId,
    required String date, // YYYY-MM-DD
  }) async {
    final ApiResponse<List<TherapistScheduleSlotModel>> res = await _api.get<List<TherapistScheduleSlotModel>>(
      '/booster/schedule?therapistId=$therapistId&date=$date',
      headers: {'Authorization': 'Bearer $token'},
      parseData: (raw) {
        final list = (raw as List<dynamic>? ?? const []);
        return list.map((e) => TherapistScheduleSlotModel.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Không thể tải lịch làm việc');
    }
    return res.data!;
  }

  Future<TherapistScheduleSlotModel> toggleSlot({
    required String token,
    required String therapistId,
    required String slotDate, // YYYY-MM-DD
    required String startTime, // HH:mm:ss
    required bool open,
  }) async {
    final ApiResponse<TherapistScheduleSlotModel> res = await _api.post<TherapistScheduleSlotModel>(
      '/booster/schedule/toggle',
      headers: {'Authorization': 'Bearer $token'},
      body: {
        'therapistId': therapistId,
        'slotDate': slotDate,
        'startTime': startTime,
        'open': open,
      },
      parseData: (raw) => raw == null ? null : TherapistScheduleSlotModel.fromJson(raw as Map<String, dynamic>),
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Không thể thay đổi slot');
    }
    return res.data!;
  }

  Future<List<AppointmentModel>> getAppointments({
    required String token,
    required String therapistId,
  }) async {
    final ApiResponse<List<AppointmentModel>> res = await _api.get<List<AppointmentModel>>(
      '/booster/appointments/therapist?therapistId=$therapistId',
      headers: {'Authorization': 'Bearer $token'},
      parseData: (raw) {
        final list = (raw as List<dynamic>? ?? const []);
        return list.map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Không thể tải lịch hẹn');
    }
    return res.data!;
  }
}
